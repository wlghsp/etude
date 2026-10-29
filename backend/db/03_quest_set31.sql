-- 세트 31: k8s 터미널로 확인하고 고르기 (실습 연계 객관식 8문제)
-- kubectl 로 직접 값을 확인하고 선택지에서 고른다. 시나리오는 setup_cmd 가 $NS 에 항상 같은 상태로 만든다. docs/specs/spec_practice_quiz_sets.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation) VALUES
  (31,  1, 'Pod 가 시작되지 않는 원인을 Events 에서 찾기',
   '배포한 Pod `web` 이 `Running` 이 되지 않습니다. Pod 가 안 뜰 때는 **Events**(쿠버네티스가 그 Pod 에 대해 남긴 기록)에 이유가 적혀 있습니다.

터미널에서 네임스페이스 `$NS` 의 Pod `web` 을 확인하고, **Pod 가 시작되지 않는 원인**을 고르세요.',
   '`kubectl describe pod <이름> -n <네임스페이스>` 를 실행하고, 맨 아래 `Events:` 의 `Reason` 과 `Message` 열을 읽습니다. 처음에는 이벤트가 안 보일 수 있으니 몇 초 뒤 다시 실행해 보세요.',
   NULL,
   '["sh", "-c", "kubectl run web --image=nginx:9.99.99 -n $NS >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["컨테이너가 시작하자마자 계속 종료된다", "메모리가 부족해 강제로 종료됐다", "지정한 이미지 태그를 레지스트리에서 찾을 수 없다", "노드에 Pod 를 올릴 자리가 없다"]',
   2,
   '정답은 **C 지정한 이미지 태그를 레지스트리에서 찾을 수 없다** 입니다. Events 에 `Failed to pull image "nginx:9.99.99"` 와 `not found` 가 나옵니다. 태그 `9.99.99` 가 존재하지 않습니다.

**원리:** Pod 가 시작되는 순서는 **스케줄링 → 이미지 받기 → 컨테이너 실행**입니다. 이 Pod 는 노드에는 배치됐지만 이미지를 받는 단계에서 막혔고, 그 이유(`not found`)가 Events 에 기록됩니다. 상태 이름(`ImagePullBackOff`)보다 Events 의 이유가 어디를 고칠지 알려 줍니다.

- A 컨테이너가 시작하자마자 종료 : `CrashLoopBackOff` 의 원인입니다. 이 Pod 는 이미지를 받는 단계에서 막혀 컨테이너가 시작조차 못 합니다.
- B 메모리 부족으로 종료 : `OOMKilled` 입니다. 컨테이너가 한 번이라도 떠야 나는 상태입니다.
- D 올릴 자리가 없다 : `Pending` + `Insufficient` 계열 메시지입니다. 이 Pod 는 노드에 배치는 됐습니다.

확인 명령: `kubectl describe pod web -n $NS`'),

  (31,  2, 'Pending 상태인 Pod 의 이유 찾기',
   '`$NS` 의 Pod `big` 이 계속 `Pending` 입니다. `Pending` 은 "아직 어느 노드에도 배치되지 못했다"는 뜻이고, 이유는 Events 에 적힙니다.

터미널에서 Pod `big` 을 확인하고, **배치되지 못하는 이유**를 고르세요.',
   '`kubectl describe pod big -n $NS` 의 `Events:` 에서 `FailedScheduling` 줄의 `Message` 를 읽습니다. `0/1 nodes are available:` 뒤에 노드를 못 쓰는 이유가 나옵니다. (`kubectl get pod big -n $NS` 로는 상태만 보이고 이유는 안 나옵니다)',
   NULL,
   '["sh", "-c", "printf ''%s\\\\n'' ''apiVersion: v1'' ''kind: Pod'' ''metadata:'' ''  name: big'' ''spec:'' ''  containers:'' ''  - name: app'' ''    image: nginx'' ''    resources:'' ''      requests:'' ''        memory: 500Gi'' > /tmp/big.yaml && kubectl apply -n $NS -f /tmp/big.yaml >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["이미지를 받아 오지 못한다", "노드에 남은 메모리가 Pod 가 요청한 양보다 적다", "Service 의 라벨이 맞지 않는다", "포트가 이미 다른 곳에서 쓰이고 있다"]',
   1,
   '정답은 **B 노드에 남은 메모리가 Pod 가 요청한 양보다 적다** 입니다. Pod 는 `requests.memory` 로 `500Gi` 를 요청했는데, 그만큼 남은 노드가 없어서 Events 에 `Insufficient memory` 가 나옵니다.

**원리:** 스케줄러는 Pod 가 요구하는 **`requests`(요청량)** 를 기준으로 남은 자원이 충분한 노드를 고릅니다. 어느 노드에도 자리가 없으면 Pod 는 `Pending` 으로 남고 `FailedScheduling` 이벤트에 이유가 적힙니다. 기준은 실제 사용량이 아니라 **요청량**이라는 점이 핵심입니다.

- A 이미지를 받지 못함 : 이미지는 노드에 배치된 **뒤**에 받는 단계라, 이 Pod 는 아직 그 단계에 가지도 못했습니다. (`ImagePullBackOff` 는 `Pending` 이 아닙니다)
- C Service 라벨 : Service 와 Pod 의 연결 문제이고, Pod 가 노드에 배치되는 것과는 무관합니다.
- D 포트 사용 중 : 쿠버네티스에서는 Pod 마다 자기 IP 를 가져서 보통 이유가 되지 않습니다.

확인 명령: `kubectl describe pod big -n $NS`'),

  (31,  3, 'Deployment 의 현재 리비전 번호 읽기',
   'Deployment 는 이미지를 바꿀 때마다 새 **리비전**(배포 이력 번호)이 쌓입니다. `$NS` 의 Deployment `web` 은 이미지를 두 번 바꿔 배포했습니다.

터미널에서 `web` 의 배포 이력을 확인하고, **가장 최근 리비전의 번호**를 고르세요.',
   '`kubectl rollout history deployment/web -n $NS` 는 `REVISION` 열에 번호를 한 줄씩 보여 줍니다. 가장 큰 번호가 현재(가장 최근) 입니다.',
   NULL,
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; sleep 3; kubectl set image deployment/web nginx=nginx:1.25 -n $NS >/dev/null 2>&1; sleep 3; kubectl set image deployment/web nginx=nginx:1.26 -n $NS >/dev/null 2>&1; sleep 3; true"]',
   '[]',
   'choice',
   '["1", "2", "3", "4"]',
   2,
   '정답은 **C 3** 입니다. 처음 만들 때 리비전 1, 이미지를 `1.25` 로 바꿔 2, `1.26` 으로 바꿔 3 이 됩니다.

**원리:** Deployment 는 Pod 템플릿(이미지 등)이 바뀔 때마다 새 ReplicaSet 을 만들고 이를 **리비전 번호**로 기록합니다. 그래서 `rollout history` 의 번호는 "템플릿을 바꾼 횟수 + 1"이고, 이 이력이 `rollout undo` 로 되돌아갈 수 있는 근거입니다.

- A 1 : 처음 만들었을 때의 번호입니다.
- B 2 : 이미지를 한 번 바꿨을 때의 번호입니다. 이 Deployment 는 두 번 바꿨습니다.
- D 4 : 아직 한 번 더 바꾸지 않았습니다.

확인 명령: `kubectl rollout history deployment/web -n $NS`'),

  (31,  4, 'Service 가 Pod 에 연결되지 않는 원인 찾기',
   '`$NS` 에 Deployment `api` 와 Service `api-svc` 가 있는데, Service 로 접속이 안 됩니다. Service 는 **selector**(고를 라벨)가 같은 라벨을 가진 Pod 에만 연결되고, 연결된 Pod 주소 목록이 `Endpoints` 입니다.

터미널에서 Service 의 `Endpoints` 와 `Selector`, Pod 의 라벨을 확인하고, **연결이 안 되는 원인**을 고르세요.',
   '`kubectl describe svc api-svc -n $NS` 에서 `Selector:` 와 `Endpoints:` 줄을 봅니다. Pod 의 라벨은 `kubectl get pods -n $NS --show-labels` 로 `LABELS` 열에서 볼 수 있습니다. 둘이 같아야 연결됩니다.',
   NULL,
   '["sh", "-c", "kubectl create deployment api --image=nginx -n $NS >/dev/null 2>&1; kubectl create service clusterip api-svc --tcp=80:80 -n $NS >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["Service 의 selector 가 Pod 의 라벨과 다르다", "Pod 가 아직 Pending 상태이다", "Service 의 포트 번호가 틀렸다", "이미지 이름이 틀렸다"]',
   0,
   '정답은 **A Service 의 selector 가 Pod 의 라벨과 다르다** 입니다. Service 의 `Selector` 는 `app=api-svc` 인데 Pod 의 라벨은 `app=api` 라서 짝이 안 맞고, `Endpoints` 가 비어 있습니다.

**원리:** Service 는 `selector` 와 일치하는 **라벨**을 가진 Ready 상태의 Pod 를 찾아 그 주소를 Endpoints 로 만듭니다. 연결은 이름이 아니라 라벨로 이뤄져서, 라벨이 안 맞으면 Pod 가 멀쩡해도 Endpoints 가 비어 접속이 안 됩니다. `kubectl create service` 가 selector 를 **서비스 이름**(`app=api-svc`)으로 자동 지정하는 점도 흔한 함정입니다.

- B Pod 가 Pending : Pod 는 정상적으로 뜹니다. (Pod 가 아직 준비 안 됐더라도 `Endpoints` 가 `<none>` 인 이유는 라벨이 맞지 않는 쪽이 먼저입니다.)
- C 포트 번호 : 포트가 틀려도 Endpoints 에는 주소가 잡힙니다. 연결 대상 자체가 비어 있는 것이 아닙니다.
- D 이미지 이름 : 이미지가 틀리면 Pod 가 안 뜰 뿐 Service 의 selector 와는 상관없습니다.

확인 명령: `kubectl describe svc api-svc -n $NS`, `kubectl get pods -n $NS --show-labels`'),

  (31,  5, 'ConfigMap 에 저장된 설정 값 읽기',
   '`$NS` 의 ConfigMap `app-config` 에는 애플리케이션 설정이 `키=값` 으로 들어 있습니다.

터미널에서 ConfigMap 을 확인하고, 키 `MAX_CONN` 의 **값**을 고르세요.',
   '`kubectl get configmap app-config -n $NS -o yaml` 은 `data:` 아래에 키와 값을 모두 보여 줍니다. `kubectl describe configmap app-config -n $NS` 로도 볼 수 있습니다.',
   NULL,
   '["sh", "-c", "kubectl create configmap app-config --from-literal=LOG_LEVEL=debug --from-literal=MAX_CONN=250 --from-literal=REGION=ap-northeast-2 -n $NS >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["25", "100", "250", "2500"]',
   2,
   '정답은 **C 250** 입니다. `data` 에 `MAX_CONN: "250"` 으로 들어 있습니다.

**원리:** ConfigMap 은 설정을 이미지 밖에 **키=값으로 저장**해 두고 Pod 가 환경변수나 파일로 가져다 쓰게 하는 오브젝트입니다. 설정을 이미지에 넣으면 값을 바꿀 때마다 이미지를 새로 만들어야 하므로, 설정을 분리해서 같은 이미지를 환경마다 다른 설정으로 쓰려는 것이 목적입니다.

- A 25, D 2500 : 자릿수를 잘못 읽은 값입니다.
- B 100 : 설정에 없는 값입니다.

확인 명령: `kubectl get configmap app-config -n $NS -o yaml`'),

  (31,  6, 'Secret 에 저장된 값을 풀어서 읽기',
   'Secret 의 값은 화면에 그대로 보이지 않고 **base64** 로 인코딩되어 저장됩니다. (암호화가 아니라 단순 인코딩이라 누구나 풀 수 있습니다.) `$NS` 의 Secret `db-secret` 에 키 `password` 가 있습니다.

터미널에서 Secret 의 값을 확인하고 base64 를 풀어서, **실제 비밀번호**를 고르세요.',
   '`kubectl get secret db-secret -n $NS -o jsonpath=''{.data.password}''` 는 base64 로 인코딩된 값을 보여 줍니다. 이 값을 `| base64 -d` 로 넘기면 원래 값으로 풀립니다. (`-d` 는 디코드, 즉 되돌리기 옵션입니다)',
   NULL,
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=password=S3cret-Pw -n $NS >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["UzNjcmV0LVB3", "S3cret-Pw", "s3cret-pw", "admin1234"]',
   1,
   '정답은 **B S3cret-Pw** 입니다. 저장된 값 `UzNjcmV0LVB3` 을 `base64 -d` 로 풀면 `S3cret-Pw` 입니다. 대소문자도 구분됩니다.

**원리:** Secret 의 값은 **base64 인코딩**일 뿐 암호화가 아닙니다. 인코딩은 특수문자를 안전하게 담기 위한 변환이라 누구나 `base64 -d` 로 되돌릴 수 있습니다. 그래서 Secret 은 값을 숨기는 것이 아니라, 읽을 수 있는 사람(RBAC)을 제한해서 지킵니다.

- A UzNjcmV0LVB3 : `kubectl get secret` 으로 처음 보이는 **인코딩된 값** 그대로입니다. 아직 풀지 않았습니다.
- C s3cret-pw : 대소문자가 다릅니다.
- D admin1234 : Secret 에 없는 값입니다.

확인 명령: `kubectl get secret db-secret -n $NS -o jsonpath=''{.data.password}'' | base64 -d`'),

  (31,  7, '라벨로 Pod 를 골라 개수 세기',
   '`$NS` 에는 Deployment `frontend` 와 `backend` 가 있고, Pod 에는 각각 `app=frontend`, `app=backend` 라벨이 붙어 있습니다. **라벨**은 Pod 를 골라내는 이름표입니다.

터미널에서 라벨로 Pod 를 골라 확인하고, **`app=frontend` 라벨의 Pod 개수**를 고르세요.',
   '`kubectl get pods -n $NS -l app=frontend` 의 `-l` 은 라벨로 거르는 옵션입니다. 전체 Pod 와 거른 Pod 의 개수가 다릅니다. 몇 개인지 세어 보세요. (`--no-headers | wc -l` 로 줄 수를 셀 수도 있습니다)',
   NULL,
   '["sh", "-c", "kubectl create deployment frontend --image=nginx --replicas=3 -n $NS >/dev/null 2>&1; kubectl create deployment backend --image=nginx --replicas=2 -n $NS >/dev/null 2>&1; sleep 3; true"]',
   '[]',
   'choice',
   '["2", "5", "3", "0"]',
   2,
   '정답은 **C 3** 입니다. `frontend` 의 `replicas` 가 3 이라 `app=frontend` 라벨의 Pod 는 3개입니다.

**원리:** 라벨은 오브젝트에 붙이는 **키=값 이름표**이고, 쿠버네티스는 이름이 아니라 라벨로 대상을 고릅니다(Service 의 selector, `kubectl get -l`). `kubectl create deployment` 가 만든 Pod 는 자동으로 `app=<Deployment 이름>` 라벨을 갖고, `-l` 로 거르면 그 라벨의 Pod 만 셀 수 있습니다.

- A 2 : `backend` 의 Pod 개수입니다.
- B 5 : 라벨로 거르지 않은 **전체** Pod 개수입니다.
- D 0 : 라벨 값을 틀리게 썼을 때(`No resources found`) 나오는 결과입니다.

확인 명령: `kubectl get pods -n $NS -l app=frontend`'),

  (31,  8, '실행 중인 컨테이너 안의 환경변수 확인하기',
   '`$NS` 의 Pod `shop` 은 환경변수로 DB 접속 정보를 받습니다. 설정 파일이 아니라 **실행 중인 컨테이너 안에서** 실제로 어떤 값이 들어갔는지 확인해야 할 때가 있습니다.

터미널에서 Pod `shop` 안에서 환경변수를 확인하고, `DB_HOST` 의 **값**을 고르세요.',
   '`kubectl exec <Pod> -n <네임스페이스> -- <명령>` 은 Pod 안에서 명령을 실행합니다. `--` 뒤가 컨테이너 안에서 실행할 명령입니다. `kubectl exec shop -n $NS -- env` 는 환경변수 전체를 보여 주고, `| grep DB_` 로 `DB_` 로 시작하는 줄만 거를 수 있습니다. Pod 가 막 만들어졌다면 `Running` 이 될 때까지 잠시 기다리세요.',
   NULL,
   '["sh", "-c", "kubectl run shop --image=nginx --env=DB_HOST=mysql.prod.svc --env=DB_PORT=3306 -n $NS >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/shop -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["mysql.dev.svc", "mysql.stage.svc", "localhost", "mysql.prod.svc"]',
   3,
   '정답은 **D mysql.prod.svc** 입니다. `kubectl exec shop -n $NS -- env` 의 출력에 `DB_HOST=mysql.prod.svc` 가 있습니다.

**원리:** 컨테이너 안의 환경변수는 **Pod 가 만들어질 때** 값이 정해집니다. 선언(YAML)과 실제로 들어간 값이 다를 수 있는 상황(예: 이후에 ConfigMap 을 바꿨는데 Pod 를 재시작하지 않음)에서는 `exec` 로 컨테이너 안에서 직접 확인하는 것이 가장 확실합니다.

- A, B : 다른 환경(dev, stage)의 주소로, 이 Pod 에 설정되지 않았습니다.
- C localhost : 환경변수에 없는 값입니다.

확인 명령: `kubectl exec shop -n $NS -- env | grep DB_`');
