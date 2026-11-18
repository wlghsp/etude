-- 세트 487: k8s 워크로드 관계와 설정 손연습: ownerReferences, envFrom prefix, ConfigMap items, docker-registry Secret, immutable, startupProbe, 이벤트·로그 걸러 보기, ServiceAccount
-- 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다. docs/specs/spec_k8s_workload_config_lab_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (487, 1, 'Pod 의 주인을 거슬러 올라가기 (ownerReferences)', '**배경** — Deployment 가 만든 Pod 는 사실 **ReplicaSet** 이 만들고, ReplicaSet 은 다시 **Deployment** 가 만듭니다. 각 오브젝트의 `metadata.ownerReferences` 에 **자기를 만든 주인**의 종류(`kind`)와 이름이 적혀 있습니다. Pod 가 왜 사라졌다 다시 생기는지, 지워도 되는지 따질 때 이 사슬을 읽습니다. Deployment `tool`(라벨 `app=tool`)이 떠 있습니다.

**문제** — `tool` 의 Pod 한 개에서 시작해 **Pod 의 주인 종류**와 **그 주인(ReplicaSet)의 주인 종류**를 차례로 **`/tmp/q1.txt`** 에 한 줄씩 저장하세요. (두 줄이 되어야 합니다.)', '`kubectl get pod -l app=tool -o jsonpath=...` 로 Pod 의 `ownerReferences[0].kind` 를 얻고, 그 `name` 으로 ReplicaSet 을 조회해 같은 필드를 읽어요.', 'POD=$(kubectl get pod -l app=tool -n $NS -o name | head -1)
kubectl get $POD -n $NS -o jsonpath=''{.metadata.ownerReferences[0].kind}{"\\n"}'' > /tmp/q1.txt
RS=$(kubectl get $POD -n $NS -o jsonpath=''{.metadata.ownerReferences[0].name}'')
kubectl get rs $RS -n $NS -o jsonpath=''{.metadata.ownerReferences[0].kind}{"\\n"}'' >> /tmp/q1.txt
cat /tmp/q1.txt

# Pod → ReplicaSet → Deployment. 주인이 지워지면 종속 오브젝트도 함께 지워진다(가비지 컬렉션)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(sed -n 1p /tmp/q1.txt 2>/dev/null)\\" = ReplicaSet ] ) && ( [ \\"$(sed -n 2p /tmp/q1.txt 2>/dev/null)\\" = Deployment ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "첫 줄이 ReplicaSet 이다", "cmd": ["sh", "-c", "[ \\"$(sed -n 1p /tmp/q1.txt 2>/dev/null)\\" = ReplicaSet ]"]}, {"label": "둘째 줄이 Deployment 이다", "cmd": ["sh", "-c", "[ \\"$(sed -n 2p /tmp/q1.txt 2>/dev/null)\\" = Deployment ]"]}]', '[{"title": "소유자와 종속 오브젝트", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/"}]'),
  (487, 2, 'ConfigMap 전체를 접두어 붙여 주입하기 (envFrom + prefix)', '**배경** — 환경 변수 하나씩 `valueFrom` 으로 꺼내는 대신 `envFrom` 으로 **ConfigMap 의 모든 키를 한꺼번에** 환경 변수로 넣을 수 있습니다. `prefix` 를 주면 이름 앞에 붙어(예: `APP_`) 다른 변수와 겹치는 것을 피합니다. ConfigMap `app-cfg` 에는 `A=1`, `B=2` 가 있습니다.

**문제** — 이미지 `busybox:1.36`, 명령 `sleep 3600` 인 Pod **`envpod`** 를 만들되, `app-cfg` 의 **모든 키를 접두어 `APP_` 로** 환경 변수에 넣으세요. (Pod 가 Ready 가 된 뒤 `APP_A` 가 `1` 이어야 합니다.)', 'YAML 의 `envFrom:` 아래에 `- prefix: APP_` 와 `configMapRef: {name: app-cfg}` 를 적어요. 만든 뒤 `kubectl wait --for=condition=Ready` 로 기다리세요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: envpod}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    envFrom:
    - prefix: APP_
      configMapRef: {name: app-cfg}
EOF
kubectl wait --for=condition=Ready pod/envpod -n $NS --timeout=90s
kubectl exec envpod -n $NS -- printenv | grep APP_

# envFrom 은 키를 모두 가져온다. prefix 가 없으면 A, B 라는 이름 그대로 들어간다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm app-cfg -n $NS --from-literal=A=1 --from-literal=B=2 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec envpod -n $NS -- printenv APP_A 2>/dev/null)\\" = 1 ] ) && ( [ \\"$(kubectl exec envpod -n $NS -- printenv APP_B 2>/dev/null)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "APP_A 가 1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec envpod -n $NS -- printenv APP_A 2>/dev/null)\\" = 1 ]"]}, {"label": "APP_B 가 2 다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec envpod -n $NS -- printenv APP_B 2>/dev/null)\\" = 2 ]"]}]', '[{"title": "ConfigMap 으로 Pod 설정하기", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/"}]'),
  (487, 3, 'ConfigMap 에서 파일 하나만 골라 마운트하기 (volume items)', '**배경** — ConfigMap 을 볼륨으로 마운트하면 기본은 **모든 키가 파일**이 됩니다. 볼륨의 `items` 에 `key` 와 `path` 를 적으면 **필요한 키만, 원하는 파일 이름으로** 넣을 수 있습니다. ConfigMap `site-cfg` 에는 `app.conf`(`mode=prod`)와 `debug.conf` 두 키가 있습니다.

**문제** — Pod **`cmpod`**(`busybox:1.36`, `sleep 3600`)를 만들어 `site-cfg` 의 **`app.conf` 만** `/etc/site/site.conf` 파일로 마운트하세요. (`/etc/site` 안에는 `site.conf` 하나만 있어야 합니다.)', 'volumes 의 `configMap` 아래에 `items:` 로 `key: app.conf` 와 `path: site.conf` 를 적고, volumeMounts 의 `mountPath` 는 `/etc/site` 로 해요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: cmpod}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - {name: cfg, mountPath: /etc/site}
  volumes:
  - name: cfg
    configMap:
      name: site-cfg
      items:
      - {key: app.conf, path: site.conf}
EOF
kubectl wait --for=condition=Ready pod/cmpod -n $NS --timeout=90s
kubectl exec cmpod -n $NS -- ls /etc/site

# items 에 적은 키만 파일이 된다. 나머지(debug.conf)는 마운트되지 않는다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm site-cfg -n $NS --from-literal=app.conf=mode=prod --from-literal=debug.conf=debug=1 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec cmpod -n $NS -- cat /etc/site/site.conf 2>/dev/null)\\" = mode=prod ] ) && ( [ \\"$(kubectl exec cmpod -n $NS -- ls /etc/site 2>/dev/null)\\" = site.conf ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "site.conf 내용이 mode=prod 다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec cmpod -n $NS -- cat /etc/site/site.conf 2>/dev/null)\\" = mode=prod ]"]}, {"label": "/etc/site 에는 site.conf 만 있다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec cmpod -n $NS -- ls /etc/site 2>/dev/null)\\" = site.conf ]"]}]', '[{"title": "ConfigMap 으로 Pod 설정하기", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/"}]'),
  (487, 4, '사설 레지스트리용 Secret 만들기 (docker-registry)', '**배경** — 사설 이미지 저장소에서 이미지를 받으려면 접속 정보를 담은 **`docker-registry` 타입 Secret** 이 필요하고, Pod 의 `imagePullSecrets` 가 이를 가리킵니다. `kubectl create secret docker-registry 이름 --docker-server=… --docker-username=… --docker-password=…` 로 만들며, 타입은 `kubernetes.io/dockerconfigjson` 이 됩니다.

**문제** — 서버 `registry.example.com`, 사용자 `dev`, 비밀번호 `pw123` 인 Secret **`regcred`** 를 만드세요.', '`kubectl create secret docker-registry regcred --docker-server=registry.example.com --docker-username=dev --docker-password=pw123`', 'kubectl create secret docker-registry regcred -n $NS --docker-server=registry.example.com --docker-username=dev --docker-password=pw123
kubectl get secret regcred -n $NS -o jsonpath=''{.type}''

# generic 이 아니라 docker-registry 로 만들면 type 이 dockerconfigjson 이 된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get secret regcred -n $NS -o jsonpath=''{.type}'' 2>/dev/null)\\" = kubernetes.io/dockerconfigjson ] ) && ( kubectl get secret regcred -n $NS -o jsonpath=''{.data.\\\\.dockerconfigjson}'' 2>/dev/null | base64 -d | grep -q registry.example.com )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "타입이 dockerconfigjson 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get secret regcred -n $NS -o jsonpath=''{.type}'' 2>/dev/null)\\" = kubernetes.io/dockerconfigjson ]"]}, {"label": "서버 주소가 들어 있다", "cmd": ["sh", "-c", "kubectl get secret regcred -n $NS -o jsonpath=''{.data.\\\\.dockerconfigjson}'' 2>/dev/null | base64 -d | grep -q registry.example.com"]}]', '[{"title": "사설 레지스트리 이미지 가져오기", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/"}]'),
  (487, 5, 'ConfigMap 을 바꿀 수 없게 잠그기 (immutable)', '**배경** — ConfigMap·Secret 에 `immutable: true` 를 주면 이후 **내용 수정이 거부**됩니다(지우고 다시 만들어야 함). 실수로 설정이 바뀌는 사고를 막고, kubelet 이 변경을 감시하지 않아 클러스터 부하도 줄입니다. 한 번 잠그면 되돌릴 수 없습니다. ConfigMap `fixed-cfg` 에 `VERSION=1` 이 있습니다.

**문제** — `fixed-cfg` 를 **immutable** 로 바꾸세요. (`VERSION` 값은 그대로 `1` 이어야 합니다.)', '`kubectl patch cm fixed-cfg -p ''{"immutable":true}''`', 'kubectl patch cm fixed-cfg -n $NS -p ''{"immutable":true}''
kubectl get cm fixed-cfg -n $NS -o jsonpath=''{.immutable}''

# 잠근 뒤 data 를 바꾸려 하면 ''field is immutable'' 오류가 난다. 고치려면 삭제 후 재생성', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm fixed-cfg -n $NS --from-literal=VERSION=1 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get cm fixed-cfg -n $NS -o jsonpath=''{.immutable}'' 2>/dev/null)\\" = true ] ) && ( [ \\"$(kubectl get cm fixed-cfg -n $NS -o jsonpath=''{.data.VERSION}'' 2>/dev/null)\\" = 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "immutable 이 true 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get cm fixed-cfg -n $NS -o jsonpath=''{.immutable}'' 2>/dev/null)\\" = true ]"]}, {"label": "VERSION 은 그대로 1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get cm fixed-cfg -n $NS -o jsonpath=''{.data.VERSION}'' 2>/dev/null)\\" = 1 ]"]}]', '[{"title": "ConfigMap", "url": "https://kubernetes.io/docs/concepts/configuration/configmap/"}]'),
  (487, 6, '느리게 뜨는 앱을 위한 startupProbe', '**배경** — 시작이 오래 걸리는 앱에 `livenessProbe` 만 두면 **뜨기 전에 죽은 것으로 판단**해 계속 재시작될 수 있습니다. `startupProbe` 는 **시작이 끝날 때까지 liveness·readiness 를 보류**하고, 성공해야 그 뒤부터 다른 프로브가 동작합니다. 허용 시간은 `failureThreshold × periodSeconds` 입니다.

**문제** — Pod **`probepod`**(`nginx:1.25`)를 만들되, **startupProbe** 를 `httpGet` 경로 `/` 포트 `80`, `periodSeconds: 2`, `failureThreshold: 30`(최대 60초)으로 설정하세요. Pod 가 Running 이어야 합니다.', 'containers 항목 안에 `startupProbe:` 를 적고 `httpGet: {path: /, port: 80}`, `periodSeconds: 2`, `failureThreshold: 30` 을 넣어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: probepod}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: web
    image: nginx:1.25
    startupProbe:
      httpGet: {path: /, port: 80}
      periodSeconds: 2
      failureThreshold: 30
EOF
kubectl wait --for=condition=Ready pod/probepod -n $NS --timeout=90s

# 60초 안에 startupProbe 가 성공하면 그때부터 liveness·readiness 가 시작된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod probepod -n $NS -o jsonpath=''{.spec.containers[0].startupProbe.periodSeconds}'' 2>/dev/null)\\" = 2 ] ) && ( [ \\"$(kubectl get pod probepod -n $NS -o jsonpath=''{.spec.containers[0].startupProbe.failureThreshold}'' 2>/dev/null)\\" = 30 ] ) && ( [ \\"$(kubectl get pod probepod -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "startupProbe periodSeconds 가 2 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod probepod -n $NS -o jsonpath=''{.spec.containers[0].startupProbe.periodSeconds}'' 2>/dev/null)\\" = 2 ]"]}, {"label": "failureThreshold 가 30 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod probepod -n $NS -o jsonpath=''{.spec.containers[0].startupProbe.failureThreshold}'' 2>/dev/null)\\" = 30 ]"]}, {"label": "Pod 가 Running 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod probepod -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ]"]}]', '[{"title": "라이브니스·레디니스·스타트업 프로브", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/"}]'),
  (487, 7, '한 Pod 의 이벤트만 걸러 보기 (--field-selector)', '**배경** — `kubectl get events` 는 네임스페이스의 이벤트를 **모두** 보여 줍니다. `--field-selector involvedObject.name=이름` 을 붙이면 **한 오브젝트와 관련된 이벤트만** 걸러 냅니다. Pod 가 어디에 배치되고 이미지를 어떻게 받았는지(`Scheduled`, `Pulled`, `Started`)가 보입니다. Pod `evpod` 와 `evother` 가 떠 있습니다.

**문제** — **`evpod` 의 이벤트만** **`/tmp/q6.txt`** 에 저장하세요. (`evother` 의 이벤트는 섞이면 안 됩니다.)', '`kubectl get events --field-selector involvedObject.name=evpod > /tmp/q6.txt`', 'kubectl get events -n $NS --field-selector involvedObject.name=evpod > /tmp/q6.txt
cat /tmp/q6.txt

# involvedObject.kind=Pod 처럼 여러 조건을 쉼표로 이을 수도 있다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl run evpod -n $NS --image=busybox:1.36 --restart=Never  -- sleep 3600 >/dev/null\\nkubectl run evother -n $NS --image=busybox:1.36 --restart=Never  -- sleep 3600 >/dev/null\\nkubectl wait --for=condition=Ready pod/evpod -n $NS --timeout=90s >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/evother -n $NS --timeout=90s >/dev/null 2>&1; \\n"]', '["sh", "-c", "( grep -q \\"pod/evpod\\" /tmp/q6.txt 2>/dev/null ) && ( grep -q Scheduled /tmp/q6.txt 2>/dev/null ) && ( ! grep -q evother /tmp/q6.txt 2>/dev/null )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "evpod 이벤트가 있다", "cmd": ["sh", "-c", "grep -q \\"pod/evpod\\" /tmp/q6.txt 2>/dev/null"]}, {"label": "Scheduled 이벤트가 있다", "cmd": ["sh", "-c", "grep -q Scheduled /tmp/q6.txt 2>/dev/null"]}, {"label": "evother 이벤트는 없다", "cmd": ["sh", "-c", "! grep -q evother /tmp/q6.txt 2>/dev/null"]}]', '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'),
  (487, 8, 'Deployment 의 모든 Pod 로그를 이름 표시와 함께 보기 (logs -l --prefix)', '**배경** — `kubectl logs -l 라벨` 은 **라벨에 맞는 모든 Pod 의 로그**를 한 번에 가져옵니다. 이때 `--prefix` 를 주면 각 줄 앞에 **`[pod/이름/컨테이너]`** 가 붙어 **어느 Pod 가 쓴 로그인지** 구분됩니다. Deployment `tool`(2개 Pod, 라벨 `app=tool`)이 시작할 때 `hello-호스트명` 을 한 줄씩 출력했습니다.

**문제** — 라벨 `app=tool` 인 **모든 Pod 의 로그**를 **Pod 이름 표시와 함께** **`/tmp/q7.txt`** 에 저장하세요.', '`kubectl logs -l app=tool --prefix > /tmp/q7.txt`', 'kubectl logs -l app=tool -n $NS --prefix > /tmp/q7.txt
cat /tmp/q7.txt

# [pod/tool-…/busybox] hello-tool-… 형태. 기본 동시 요청 한도는 --max-log-requests 5', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=busybox:1.36 --replicas=2 -- sh -c ''echo hello-$HOSTNAME; sleep 3600'' >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1; sleep 2\\n"]', '["sh", "-c", "( [ \\"$(grep -c \\"^\\\\[pod/tool-\\" /tmp/q7.txt 2>/dev/null)\\" = 2 ] ) && ( [ \\"$(grep -c \\"hello-tool-\\" /tmp/q7.txt 2>/dev/null)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Pod 이름 접두어 줄이 2개다", "cmd": ["sh", "-c", "[ \\"$(grep -c \\"^\\\\[pod/tool-\\" /tmp/q7.txt 2>/dev/null)\\" = 2 ]"]}, {"label": "hello 로그가 들어 있다", "cmd": ["sh", "-c", "[ \\"$(grep -c \\"hello-tool-\\" /tmp/q7.txt 2>/dev/null)\\" = 2 ]"]}]', '[{"title": "kubectl logs", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/"}]'),
  (487, 9, 'Pod 에 서비스 어카운트 지정하기 (serviceAccountName)', '**배경** — Pod 는 API 서버에 접근할 때 **서비스 어카운트**의 신원을 씁니다. 지정하지 않으면 `default` 입니다. 앱마다 권한을 따로 주려면 전용 서비스 어카운트를 만들어 Pod 의 `spec.serviceAccountName` 에 적습니다. 이미 있는 Pod 의 서비스 어카운트는 바꿀 수 없어 새로 만들어야 합니다.

**문제** — 서비스 어카운트 **`robot`** 을 만들고, 이를 쓰는 Pod **`sapod`**(`busybox:1.36`, `sleep 3600`)를 만드세요.', '`kubectl create sa robot` 다음, Pod YAML 의 `spec.serviceAccountName: robot` 으로 지정해요. (`kubectl run … --overrides` 로도 가능해요.)', 'kubectl create sa robot -n $NS
kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: sapod}
spec:
  serviceAccountName: robot
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
kubectl get pod sapod -n $NS -o jsonpath=''{.spec.serviceAccountName}''

# Pod 가 만들어지려면 서비스 어카운트가 먼저 있어야 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod envpod cmpod probepod evpod evother sapod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm app-cfg site-cfg fixed-cfg secret regcred sa robot -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( kubectl get sa robot -n $NS >/dev/null 2>&1 ) && ( [ \\"$(kubectl get pod sapod -n $NS -o jsonpath=''{.spec.serviceAccountName}'' 2>/dev/null)\\" = robot ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "서비스 어카운트 robot 이 있다", "cmd": ["sh", "-c", "kubectl get sa robot -n $NS >/dev/null 2>&1"]}, {"label": "sapod 가 robot 을 쓴다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sapod -n $NS -o jsonpath=''{.spec.serviceAccountName}'' 2>/dev/null)\\" = robot ]"]}]', '[{"title": "Pod 에 서비스 어카운트 지정하기", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/"}]'),
  (487, 10, 'Deployment 가 만든 Pod 를 직접 만든 주인은?', 'Deployment `web` 이 만든 Pod 의 `metadata.ownerReferences` 에는 어떤 종류의 오브젝트가 적혀 있을까요?', 'Deployment 는 중간 단계를 거쳐 Pod 를 만들어요.', NULL, NULL, '[]', 'choice', '["Deployment — Pod 를 직접 만들고 소유한다", "ReplicaSet — Deployment 가 만든 ReplicaSet", "Node — Pod 가 배치된 노드가 소유한다", "Namespace — 같은 네임스페이스가 소유한다"]', 1, 'Deployment 는 ReplicaSet 을 만들고, ReplicaSet 이 Pod 를 만들어 ownerReferences 에 ReplicaSet 이 적힙니다. 이 사슬 덕분에 롤아웃 때 새 ReplicaSet 으로 Pod 를 교체하고, 주인이 지워지면 Pod 도 가비지 컬렉션으로 지워집니다.', NULL, NULL, NULL, '[{"title": "소유자와 종속 오브젝트", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/"}]'),
  (487, 11, '사설 레지스트리 접속 정보 Secret', '사설 이미지 저장소 접속 정보를 담은 Secret 을 만드는 명령입니다. 빈칸을 채우세요.', '서버·사용자·비밀번호 옵션이 붙어요.', NULL, NULL, '[]', 'fill', '["docker-registry", "generic", "tls", "opaque"]', NULL, 'docker-registry 타입은 --docker-server·--docker-username·--docker-password 옵션을 받아 kubernetes.io/dockerconfigjson Secret 을 만듭니다. generic 은 임의 키-값, tls 는 인증서·키용입니다.', '[0]', 'kubectl create secret {0} regcred --docker-server=registry.example.com --docker-username=dev --docker-password=pw123', NULL, '[{"title": "사설 레지스트리 이미지 가져오기", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/"}]'),
  (487, 12, '느리게 뜨는 앱의 프로브 순서', '`startupProbe` 가 있는 Pod 에서 프로브가 동작하는 순서입니다. 순서에 맞게 놓아 보세요.', '시작 프로브가 성공해야 나머지가 시작돼요.', NULL, NULL, '[]', 'order', '["컨테이너가 시작되고 `startupProbe` 가 반복 점검된다", "`startupProbe` 가 성공하기 전까지 liveness·readiness 는 실행되지 않는다", "`startupProbe` 가 성공하면 liveness·readiness 프로브가 시작된다", "readiness 가 성공하면 Service 가 트래픽을 보낸다"]', NULL, 'startupProbe 가 성공할 때까지 liveness·readiness 는 보류되고, 성공 후 둘이 시작됩니다. readiness 가 성공하면 Pod 가 Service 엔드포인트에 포함되어 트래픽을 받습니다. 시간 안에 성공하지 못하면 컨테이너가 재시작됩니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "라이브니스·레디니스·스타트업 프로브", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/"}]');
