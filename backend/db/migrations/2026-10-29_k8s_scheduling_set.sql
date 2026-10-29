-- 세트 26(k8s 스케줄링과 배포 전략) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set26.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 26, 'k8s 스케줄링과 배포 전략', 'taint·toleration, nodeAffinity, podAntiAffinity, 롤링 업데이트 전략, StatefulSet, PodDisruptionBudget, graceful shutdown, kubectl diff 등 Pod 배치와 배포 방식을 다루는 기본기를 실습합니다.', 'k8s', 'k8s' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  1, '노드의 taint 를 견디도록 toleration 설정하기',
   '**taint** 는 노드에 붙이는 ''출입 제한 표시''로, 이 표시를 견디는(**toleration**) Pod 만 그 노드에 배치됩니다. 특정 노드를 GPU, 전용 워크로드용으로 비워 둘 때 씁니다.

노드에 `dedicated=gpu:NoSchedule` taint 가 걸려 있다고 가정하고, 이를 견디는 Pod 를 만드세요.
- 이름: `gpu-pod`, 이미지: `nginx`, 네임스페이스: `$NS`
- toleration: 키 `dedicated`, 값 `gpu`, 효과 `NoSchedule`',
   'Pod 의 `spec.tolerations` 에 목록으로 씁니다.
- `key` / `value` : taint 의 키와 값
- `operator: Equal` : 키와 값이 모두 같을 때 (`Exists` 는 값은 보지 않고 키만 봅니다)
- `effect: NoSchedule` : 견디려는 taint 의 효과 (`NoSchedule` 은 새 Pod 배치 금지, `NoExecute` 는 이미 있는 Pod 도 내쫓음)',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  tolerations:
  - key: dedicated
    operator: Equal       # 키와 값이 모두 같을 때
    value: gpu
    effect: NoSchedule    # 새 Pod 배치를 막는 taint 를 견딤
  containers:
  - name: nginx
    image: nginx
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod gpu-pod -n $NS -o jsonpath=''{.spec.tolerations[0].key}'')\\\" = dedicated ] && [ \\\"$(kubectl get pod gpu-pod -n $NS -o jsonpath=''{.spec.tolerations[0].value}'')\\\" = gpu ] && [ \\\"$(kubectl get pod gpu-pod -n $NS -o jsonpath=''{.spec.tolerations[0].effect}'')\\\" = NoSchedule ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  2, 'nodeAffinity 로 반드시 지켜야 할 배치 조건 걸기',
   '**nodeAffinity** 는 `nodeSelector` 보다 표현이 풍부한 노드 선택 규칙입니다(`In`, `NotIn` 등). 조건을 ''반드시''로 걸 수도, ''가능하면''으로 걸 수도 있습니다.

`$NS` 에 `nginx` 이미지의 Pod `affinity-pod` 를 만들고, **반드시** 노드 라벨 `disktype` 이 `ssd` 인 노드에만 배치되도록 하세요.
(이 환경의 노드에는 해당 라벨이 없어 Pod 는 `Pending` 으로 남는 것이 정상입니다)',
   '`spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[]` 아래에 `matchExpressions` 를 씁니다.
- `key: disktype`
- `operator: In` : 값이 목록 중 하나일 때 (`NotIn`, `Exists` 도 있습니다)
- `values: [ssd]`
`required...` 는 ''반드시'', `preferred...` 는 ''가능하면''입니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:   # 반드시 만족해야 배치
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In      # 값이 목록 중 하나
            values:
            - ssd
  containers:
  - name: nginx
    image: nginx
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod affinity-pod -n $NS -o jsonpath=''{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key}'')\\\" = disktype ] && [ \\\"$(kubectl get pod affinity-pod -n $NS -o jsonpath=''{.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]}'')\\\" = ssd ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  3, '같은 앱의 Pod 가 한 노드에 몰리지 않게 하기 (podAntiAffinity)',
   '복제본이 모두 같은 노드에 뜨면 그 노드 하나가 죽을 때 서비스가 통째로 멈춥니다. **podAntiAffinity** 로 같은 앱의 Pod 를 **서로 다른 노드에 퍼뜨리도록** 요청합니다.

`$NS` 에 `nginx` Deployment `spread-app`(replicas `2`)을 만들고, 같은 앱(`app=spread-app`)의 Pod 를 **가능하면** 서로 다른 노드(`kubernetes.io/hostname`)에 배치하도록 설정하세요.',
   'Pod 템플릿(`spec.template.spec`)의 `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` 아래에 씁니다.
- `weight` : 선호도 가중치(1~100)
- `podAffinityTerm.labelSelector.matchLabels` : ''피하고 싶은 Pod''의 라벨(`app: spread-app`)
- `podAffinityTerm.topologyKey: kubernetes.io/hostname` : ''같은 노드''를 기준으로 판단
`preferred...` 는 ''가능하면''이라서 노드가 하나뿐이어도 Pod 는 뜹니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spread-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: spread-app
  template:
    metadata:
      labels:
        app: spread-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:   # 가능하면
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: spread-app       # 같은 앱 Pod 를 피함
              topologyKey: kubernetes.io/hostname   # 같은 노드 기준
      containers:
      - name: nginx
        image: nginx
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get deploy spread-app -n $NS -o jsonpath=''{.spec.replicas}'')\\\" = 2 ] && [ \\\"$(kubectl get deploy spread-app -n $NS -o jsonpath=''{.spec.template.spec.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey}'')\\\" = kubernetes.io/hostname ] && [ \\\"$(kubectl get deploy spread-app -n $NS -o jsonpath=''{.spec.template.spec.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels.app}'')\\\" = spread-app ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  4, '롤링 업데이트 속도 조절하기 (maxSurge, maxUnavailable)',
   'Deployment 는 새 버전으로 바꿀 때 Pod 를 하나씩 교체합니다. 한 번에 **얼마나 더 띄울지(maxSurge)** 와 **얼마나 줄어도 되는지(maxUnavailable)** 를 정해 서비스 중단 없이 배포할 수 있습니다.

`$NS` 의 `app` Deployment 의 롤링 업데이트 전략을 아래처럼 바꾸세요.
- `maxSurge`: `1` (새 Pod 를 최대 1개 더 띄움)
- `maxUnavailable`: `0` (배포 중에도 줄어든 Pod 가 없어야 함)',
   '`kubectl patch deployment <이름> -n <ns> -p ''<JSON>''` 으로 `spec.strategy.rollingUpdate` 를 바꿉니다. 구조: `{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}`
- `maxSurge` : 원하는 개수보다 **추가로** 허용하는 Pod 수
- `maxUnavailable` : 배포 중 **줄어들 수 있는** Pod 수 (`0` 이면 항상 원래 개수 이상 유지)',
   'kubectl patch deployment app -n $NS -p ''{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}''

# maxSurge 1        : 교체 중 새 Pod 를 1개까지 더 띄움
# maxUnavailable 0  : 교체 중에도 사용 가능한 Pod 수를 줄이지 않음

# 확인
kubectl get deployment app -n $NS -o jsonpath=''{.spec.strategy}''',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.strategy.rollingUpdate.maxSurge}'')\\\" = 1 ] && [ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.strategy.rollingUpdate.maxUnavailable}'')\\\" = 0 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  5, '배포를 잠시 멈추기 (rollout pause)',
   '배포 도중 이상한 징후가 보이면 **롤아웃을 일시 중지**해서 더 진행되지 않게 할 수 있습니다. 중지된 동안 여러 설정을 한꺼번에 바꾸고 한 번에 배포하는 용도로도 씁니다.

`$NS` 의 `app` Deployment 의 롤아웃을 **일시 중지**하세요.',
   '`kubectl rollout pause deployment/<이름> -n <ns>` 입니다. 다시 진행하려면 `kubectl rollout resume deployment/<이름> -n <ns>` 를 씁니다. 확인: `kubectl get deployment <이름> -n <ns> -o jsonpath=''{.spec.paused}''` 가 `true` 면 중지된 상태입니다.',
   'kubectl rollout pause deployment/app -n $NS

# 재개하려면: kubectl rollout resume deployment/app -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.paused}'')\\\" = true ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  6, '배포 이력을 몇 개까지 보관할지 정하기 (revisionHistoryLimit)',
   'Deployment 는 이전 버전(ReplicaSet)을 **이력**으로 남겨 두어 롤백할 수 있게 합니다. 이력이 너무 많으면 쌓인 ReplicaSet 이 클러스터를 어지럽히므로 보관 개수를 정합니다.

`$NS` 의 `app` Deployment 가 이전 버전을 **최대 3개**까지만 보관하도록 설정하세요.',
   '`spec.revisionHistoryLimit` 필드입니다. `kubectl patch deployment <이름> -n <ns> -p ''{"spec":{"revisionHistoryLimit":<개수>}}''` 로 바꿀 수 있습니다. (이 필드는 `kubectl explain deployment.spec.revisionHistoryLimit` 으로도 설명을 볼 수 있습니다)',
   'kubectl patch deployment app -n $NS -p ''{"spec":{"revisionHistoryLimit":3}}''

# 이전 ReplicaSet(이력)을 최대 3개까지만 보관',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.revisionHistoryLimit}'')\\\" = 3 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  7, 'StatefulSet 만들기',
   '**StatefulSet** 은 DB 처럼 **Pod 마다 고정된 이름과 순서**가 필요한 앱을 위한 리소스입니다. Deployment 와 달리 Pod 이름이 `이름-0`, `이름-1` 처럼 일정하게 붙고 순서대로 뜹니다. 각 Pod 를 이름으로 찾기 위해 Headless Service 와 함께 씁니다.

`$NS` 에 StatefulSet `web-sts` 를 만드세요.
- 복제본 `2`, 이미지 `nginx`
- `serviceName`: `web-headless` (연결할 Headless Service 이름)
- Pod 라벨: `app: web-sts`',
   'StatefulSet 은 `kubectl create` 로 만들 수 없어 YAML 이 필요합니다. Deployment 와 거의 같은 구조에 `spec.serviceName` 이 **필수**로 추가됩니다. `selector.matchLabels` 와 Pod 템플릿 라벨은 같아야 합니다. (`serviceName` 의 Service 는 이 문제에서 만들지 않아도 됩니다)',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-sts
spec:
  serviceName: web-headless    # 각 Pod 의 DNS 이름을 만들 Headless Service
  replicas: 2
  selector:
    matchLabels:
      app: web-sts
  template:
    metadata:
      labels:
        app: web-sts
    spec:
      containers:
      - name: nginx
        image: nginx
EOF

# Pod 이름: web-sts-0, web-sts-1 (순서대로 생성)',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get statefulset web-sts -n $NS -o jsonpath=''{.spec.serviceName}'')\\\" = web-headless ] && [ \\\"$(kubectl get statefulset web-sts -n $NS -o jsonpath=''{.spec.replicas}'')\\\" = 2 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  8, 'PodDisruptionBudget 으로 최소 가용 Pod 보장하기',
   '노드 점검(drain) 같은 **자발적 중단** 때 앱의 Pod 가 한꺼번에 사라지면 서비스가 멈춥니다. **PodDisruptionBudget(PDB)** 는 ''최소 몇 개는 항상 살아 있어야 한다''는 약속을 걸어 둡니다.

`$NS` 에서 라벨 `app=app` 인 Pod 에 대해, 항상 **최소 1개**가 유지되도록 PDB `app-pdb` 를 만드세요.',
   '`kubectl create pdb <이름> --selector=<라벨 조건> --min-available=<개수> -n <ns>` 한 줄로 됩니다.
- `--selector=app=app` : 보호할 Pod 를 고르는 라벨 조건
- `--min-available=1` : 중단 중에도 최소 유지할 Pod 수 (`--max-unavailable` 로 ''최대 몇 개까지 줄어도 되는지''로 쓸 수도 있습니다)',
   'kubectl create pdb app-pdb --selector=app=app --min-available=1 -n $NS

# 확인
kubectl get pdb app-pdb -n $NS',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pdb app-pdb -n $NS -o jsonpath=''{.spec.minAvailable}'')\\\" = 1 ] && [ \\\"$(kubectl get pdb app-pdb -n $NS -o jsonpath=''{.spec.selector.matchLabels.app}'')\\\" = app ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26,  9, '안전하게 종료하기 (terminationGracePeriodSeconds, preStop)',
   'Pod 를 종료할 때 진행 중이던 요청을 마무리할 시간을 주는 것을 **graceful shutdown(우아한 종료)** 이라고 합니다. 유예 시간 안에 `preStop` 훅으로 정리 작업을 실행할 수 있습니다.

`$NS` 에 `nginx` 이미지의 Pod `graceful` 을 만드세요.
- 종료 유예 시간(`terminationGracePeriodSeconds`): `60`
- `preStop` 훅: `sleep 5` 실행',
   '- `spec.terminationGracePeriodSeconds` : 종료 신호(SIGTERM) 후 강제 종료(SIGKILL)까지 기다리는 시간 (기본 30초)
- `containers[].lifecycle.preStop.exec.command` : 종료 직전에 컨테이너 안에서 실행할 명령 (목록 형식: `["sh", "-c", "sleep 5"]`)',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: graceful
spec:
  terminationGracePeriodSeconds: 60   # 종료 신호 후 강제 종료까지 60초 대기
  containers:
  - name: nginx
    image: nginx
    lifecycle:
      preStop:                         # 종료 직전에 실행
        exec:
          command: ["sh", "-c", "sleep 5"]
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod graceful -n $NS -o jsonpath=''{.spec.terminationGracePeriodSeconds}'')\\\" = 60 ] && [ \\\"$(kubectl get pod graceful -n $NS -o jsonpath=''{.spec.containers[0].lifecycle.preStop.exec.command[2]}'')\\\" = ''sleep 5'' ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 26, 10, '적용하기 전에 변경점 미리 확인하기 (kubectl diff)',
   'YAML 파일을 적용(`apply`)하기 전에 **실제로 무엇이 바뀌는지** 미리 보면 사고를 줄일 수 있습니다. 시험과 실무 모두에서 쓰는 습관입니다.

`$NS` 에는 `app` Deployment(replicas `1`)가 있고, 수정된 설정 파일 `/tmp/app-new.yaml`(replicas `3`)이 준비되어 있습니다. 이 파일을 적용했을 때 **달라질 내용**을 `/tmp/diff.txt` 에 저장하세요. (실제로 적용하지는 않습니다)',
   '`kubectl diff -f <파일> -n <ns>` 는 파일 내용과 현재 클러스터 상태의 차이를 출력합니다. 지워질 줄은 `-`, 추가될 줄은 `+` 로 시작합니다. 차이가 있으면 종료 코드가 `1` 이 되는 것이 정상이니, 뒤에 `|| true` 를 붙이면 실패로 보이지 않습니다.',
   'kubectl diff -f /tmp/app-new.yaml -n $NS > /tmp/diff.txt || true

# -  replicas: 1
# +  replicas: 3   (이런 줄이 보입니다)
# diff 는 차이가 있으면 종료 코드 1 이라서 || true 를 붙임',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; kubectl get deployment app -n $NS -o yaml | sed ''s/replicas: 1/replicas: 3/'' > /tmp/app-new.yaml; true"]',
   '["sh", "-c", "grep -q ''replicas: 1'' /tmp/diff.txt && grep -q ''replicas: 3'' /tmp/diff.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 26 AND order_index = 10);
