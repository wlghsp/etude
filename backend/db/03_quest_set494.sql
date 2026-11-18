-- 세트 494: k8s Pod·볼륨·네트워크 설정 손연습: port-forward, emptyDir Memory, projected 볼륨, subPath, resourceFieldRef, sessionAffinity, topologySpread, HPA v2 메모리, dnsConfig
-- 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다. docs/specs/spec_k8s_pod_volume_net_lab_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (494, 1, '내 컴퓨터 포트로 클러스터 안의 앱 열어 보기 (port-forward)', '**배경** — `kubectl port-forward 대상 로컬포트:원격포트` 는 **내 컴퓨터의 포트를 클러스터 안의 Pod·Service 로 연결**합니다. Service 를 밖으로 열지 않고 임시로 접속해 확인·디버깅할 때 씁니다. 명령은 **끝나지 않고 계속 실행**되므로 `&` 로 백그라운드에 두거나 다른 터미널에서 접속합니다. Service `web`(포트 80, nginx)이 있습니다.

**문제** — `web` 서비스를 로컬 **`8080`** 으로 포워딩해 두고 `curl` 로 받은 첫 페이지를 **`/tmp/q1.txt`** 에 저장하세요. (`Welcome to nginx` 가 보여야 합니다. 끝나면 포워딩을 종료하세요.)', '`kubectl port-forward svc/web 8080:80 &` → 2~3초 뒤 `curl -s localhost:8080 > /tmp/q1.txt` → `kill %1`', 'kubectl port-forward svc/web 8080:80 -n $NS >/dev/null 2>&1 &
PF=$!
sleep 3
curl -s localhost:8080 > /tmp/q1.txt
kill $PF
grep -o ''Welcome to nginx'' /tmp/q1.txt

# 포워딩은 명령이 살아 있는 동안만 유지된다. 끝나면 kill 로 종료한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl expose deployment web -n $NS --port=80 >/dev/null; kubectl rollout status deployment/web -n $NS --timeout=120s >/dev/null 2>&1; sleep 2\\n"]', '["sh", "-c", "( grep -q \\"Welcome to nginx\\" /tmp/q1.txt 2>/dev/null )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Welcome to nginx 가 있다", "cmd": ["sh", "-c", "grep -q \\"Welcome to nginx\\" /tmp/q1.txt 2>/dev/null"]}]', '[{"title": "port-forward 로 앱에 접근", "url": "https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/"}]'),
  (494, 2, '메모리 위의 임시 폴더 (emptyDir medium: Memory)', '**배경** — `emptyDir` 는 Pod 가 사는 동안만 있는 임시 폴더입니다. **`medium: Memory`** 로 만들면 디스크 대신 **메모리(tmpfs)** 위에 만들어져 빠르지만, 쓴 만큼 **컨테이너 메모리로 계산**됩니다. `sizeLimit` 로 상한을 둡니다. 비밀·캐시처럼 디스크에 남기고 싶지 않은 데이터에 씁니다.

**문제** — Pod **`memp`**(`busybox:1.36`, `sleep 3600`)에 **메모리 기반 emptyDir**(`sizeLimit: 64Mi`)를 `/cache` 에 마운트하세요. (`/cache` 가 `tmpfs` 로 마운트되어야 합니다.)', 'volumes 에 `emptyDir: {medium: Memory, sizeLimit: 64Mi}` 를 적고 `/cache` 에 마운트해요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: memp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - {name: cache, mountPath: /cache}
  volumes:
  - name: cache
    emptyDir: {medium: Memory, sizeLimit: 64Mi}
EOF
kubectl wait --for=condition=Ready pod/memp -n $NS --timeout=90s
kubectl exec memp -n $NS -- mount | grep '' /cache ''

# tmpfs on /cache type tmpfs ... 로 보인다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( kubectl exec memp -n $NS -- sh -c ''mount | grep \\" /cache \\"'' 2>/dev/null | grep -q tmpfs )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/cache 가 tmpfs 다", "cmd": ["sh", "-c", "kubectl exec memp -n $NS -- sh -c ''mount | grep \\" /cache \\"'' 2>/dev/null | grep -q tmpfs"]}]', '[{"title": "볼륨 (emptyDir)", "url": "https://kubernetes.io/docs/concepts/storage/volumes/#emptydir"}]'),
  (494, 3, 'ConfigMap 과 Secret 을 한 폴더에 모으기 (projected 볼륨)', '**배경** — **`projected`** 볼륨은 ConfigMap·Secret·downwardAPI 같은 **여러 출처를 한 폴더에 합쳐** 마운트합니다. 설정과 비밀을 한 경로(`/etc/proj`)에서 읽게 할 때 씁니다. 출처마다 `sources` 항목을 적습니다. ConfigMap `p-cm`(`a=1`)과 Secret `p-sec`(`b=2`)가 있습니다.

**문제** — Pod **`projp`**(`busybox:1.36`, `sleep 3600`)에 `p-cm` 과 `p-sec` 을 **하나의 projected 볼륨**으로 `/etc/proj` 에 마운트하세요. (`/etc/proj` 안에 파일 `a` 와 `b` 가 있어야 합니다.)', 'volumes 에 `projected:` → `sources:` 아래 `- configMap: {name: p-cm}` 과 `- secret: {name: p-sec}` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: projp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - {name: all, mountPath: /etc/proj}
  volumes:
  - name: all
    projected:
      sources:
      - configMap: {name: p-cm}
      - secret: {name: p-sec}
EOF
kubectl wait --for=condition=Ready pod/projp -n $NS --timeout=90s
kubectl exec projp -n $NS -- ls /etc/proj

# 서로 다른 출처의 키가 한 폴더 안의 파일이 된다 (키 이름이 겹치면 안 된다)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm p-cm -n $NS --from-literal=a=1 >/dev/null; kubectl create secret generic p-sec -n $NS --from-literal=b=2 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec projp -n $NS -- cat /etc/proj/a 2>/dev/null)\\" = 1 ] ) && ( [ \\"$(kubectl exec projp -n $NS -- cat /etc/proj/b 2>/dev/null)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "a 파일이 1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec projp -n $NS -- cat /etc/proj/a 2>/dev/null)\\" = 1 ]"]}, {"label": "b 파일이 2 다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec projp -n $NS -- cat /etc/proj/b 2>/dev/null)\\" = 2 ]"]}]', '[{"title": "프로젝티드 볼륨", "url": "https://kubernetes.io/docs/concepts/storage/projected-volumes/"}]'),
  (494, 4, '폴더를 가리지 않고 파일 하나만 끼워 넣기 (subPath)', '**배경** — ConfigMap 을 **폴더에 마운트하면 그 폴더의 기존 파일이 가려집니다**. **`subPath`** 를 쓰면 ConfigMap 의 키 **하나만** 파일 경로에 끼워 넣어 기존 파일이 유지됩니다. 단, subPath 로 마운트한 파일은 ConfigMap 이 바뀌어도 **자동 갱신되지 않습니다**. ConfigMap `extra-cm` 에 `extra.txt`(`hello`)가 있습니다.

**문제** — Pod **`subp`**(`nginx:1.25`)의 `/usr/share/nginx/html/extra.txt` 로 `extra-cm` 의 **`extra.txt` 키만** 마운트하세요. (기존 `index.html` 은 그대로 있어야 합니다.)', 'volumeMounts 에 `mountPath: /usr/share/nginx/html/extra.txt` 와 `subPath: extra.txt` 를 함께 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: subp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: web
    image: nginx:1.25
    volumeMounts:
    - name: extra
      mountPath: /usr/share/nginx/html/extra.txt
      subPath: extra.txt
  volumes:
  - name: extra
    configMap: {name: extra-cm}
EOF
kubectl wait --for=condition=Ready pod/subp -n $NS --timeout=90s
kubectl exec subp -n $NS -- ls /usr/share/nginx/html

# index.html 과 extra.txt 가 함께 있다. 폴더째 마운트했다면 index.html 이 사라진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm extra-cm -n $NS --from-literal=extra.txt=hello >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec subp -n $NS -- cat /usr/share/nginx/html/extra.txt 2>/dev/null)\\" = hello ] ) && ( kubectl exec subp -n $NS -- test -f /usr/share/nginx/html/index.html 2>/dev/null )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "extra.txt 가 hello 다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec subp -n $NS -- cat /usr/share/nginx/html/extra.txt 2>/dev/null)\\" = hello ]"]}, {"label": "index.html 이 남아 있다", "cmd": ["sh", "-c", "kubectl exec subp -n $NS -- test -f /usr/share/nginx/html/index.html 2>/dev/null"]}]', '[{"title": "ConfigMap (subPath)", "url": "https://kubernetes.io/docs/concepts/configuration/configmap/"}]'),
  (494, 5, '한도 값을 환경 변수로 받기 (resourceFieldRef)', '**배경** — **`resourceFieldRef`** 는 컨테이너의 **requests·limits 값**을 환경 변수로 줍니다. 앱이 "내게 허용된 메모리" 에 맞춰 힙 크기를 정할 때 씁니다. `divisor` 로 단위를 정합니다(예: `1Mi` 로 나누면 MiB 숫자).

**문제** — Pod **`rfp`**(`busybox:1.36`, `sleep 3600`)의 컨테이너에 메모리 **limits `128Mi`** 를 주고, 환경 변수 **`MEM_LIMIT`** 가 그 한도를 **MiB 숫자(`128`)**로 갖게 하세요.', '`env` 항목에 `valueFrom.resourceFieldRef: {resource: limits.memory, divisor: 1Mi}` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: rfp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      limits: {memory: 128Mi, cpu: 500m}
    env:
    - name: MEM_LIMIT
      valueFrom:
        resourceFieldRef: {resource: limits.memory, divisor: 1Mi}
EOF
kubectl wait --for=condition=Ready pod/rfp -n $NS --timeout=90s
kubectl exec rfp -n $NS -- printenv MEM_LIMIT

# divisor 가 없으면 바이트 값(134217728)이 들어간다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec rfp -n $NS -- printenv MEM_LIMIT 2>/dev/null)\\" = 128 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "MEM_LIMIT 가 128 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec rfp -n $NS -- printenv MEM_LIMIT 2>/dev/null)\\" = 128 ]"]}]', '[{"title": "컨테이너 필드를 환경 변수로 노출", "url": "https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/"}]'),
  (494, 6, '같은 클라이언트는 같은 Pod 로 (sessionAffinity)', '**배경** — Service 는 기본적으로 요청을 Pod 들에 **분산**합니다. **`sessionAffinity: ClientIP`** 를 주면 **같은 클라이언트 IP 의 요청을 같은 Pod 로** 보냅니다(기본 3시간). 세션 상태를 Pod 메모리에 두는 오래된 앱에 임시로 씁니다. Service `web` 이 있습니다.

**문제** — Service `web` 의 `sessionAffinity` 를 **`ClientIP`** 로 바꾸세요.', '`kubectl patch svc web -p ''{"spec":{"sessionAffinity":"ClientIP"}}''`', 'kubectl patch svc web -n $NS -p ''{"spec":{"sessionAffinity":"ClientIP"}}''
kubectl get svc web -n $NS -o jsonpath=''{.spec.sessionAffinity}''

# 기본값은 None. 가능하면 앱을 상태 없이 만들고 이 설정은 쓰지 않는다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl expose deployment web -n $NS --port=80 >/dev/null; kubectl rollout status deployment/web -n $NS --timeout=120s >/dev/null 2>&1; sleep 2\\n"]', '["sh", "-c", "( [ \\"$(kubectl get svc web -n $NS -o jsonpath=''{.spec.sessionAffinity}'' 2>/dev/null)\\" = ClientIP ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "sessionAffinity 가 ClientIP 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get svc web -n $NS -o jsonpath=''{.spec.sessionAffinity}'' 2>/dev/null)\\" = ClientIP ]"]}]', '[{"title": "Service (sessionAffinity)", "url": "https://kubernetes.io/docs/concepts/services-networking/service/#session-stickiness"}]'),
  (494, 7, 'Pod 를 노드에 고르게 퍼뜨리기 (topologySpreadConstraints)', '**배경** — **`topologySpreadConstraints`** 는 Pod 를 **노드·영역에 고르게** 퍼뜨립니다. `maxSkew` 는 허용 편차, `topologyKey` 는 퍼뜨릴 기준(`kubernetes.io/hostname` = 노드), `whenUnsatisfiable` 은 조건을 못 맞출 때 **`DoNotSchedule`**(배치 안 함) 또는 **`ScheduleAnyway`**(그래도 배치)입니다. 노드가 하나인 실습 클러스터에서는 `ScheduleAnyway` 가 안전합니다.

**문제** — Deployment **`spread`**(`nginx:1.25`, replicas 2, 라벨 `app=spread`)를 만들되 `maxSkew: 1`, `topologyKey: kubernetes.io/hostname`, `whenUnsatisfiable: ScheduleAnyway`, `labelSelector` `app=spread` 인 제약을 Pod 템플릿에 넣고, 2개가 **모두 준비**될 때까지 기다리세요.', 'Pod 템플릿 `spec.topologySpreadConstraints` 에 `maxSkew`, `topologyKey`, `whenUnsatisfiable`, `labelSelector.matchLabels` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: apps/v1
kind: Deployment
metadata: {name: spread}
spec:
  replicas: 2
  selector:
    matchLabels: {app: spread}
  template:
    metadata:
      labels: {app: spread}
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels: {app: spread}
      containers:
      - {name: web, image: "nginx:1.25"}
EOF
kubectl rollout status deployment/spread -n $NS --timeout=120s

# 노드가 둘 이상이면 노드마다 1개씩 퍼진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy spread -n $NS -o jsonpath=''{.spec.template.spec.topologySpreadConstraints[0].maxSkew}'' 2>/dev/null)\\" = 1 ] ) && ( [ \\"$(kubectl get deploy spread -n $NS -o jsonpath=''{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}'' 2>/dev/null)\\" = ScheduleAnyway ] ) && ( [ \\"$(kubectl get deploy spread -n $NS -o jsonpath=''{.status.readyReplicas}'' 2>/dev/null)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "maxSkew 가 1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy spread -n $NS -o jsonpath=''{.spec.template.spec.topologySpreadConstraints[0].maxSkew}'' 2>/dev/null)\\" = 1 ]"]}, {"label": "whenUnsatisfiable 이 ScheduleAnyway 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy spread -n $NS -o jsonpath=''{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}'' 2>/dev/null)\\" = ScheduleAnyway ]"]}, {"label": "2개가 준비됐다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy spread -n $NS -o jsonpath=''{.status.readyReplicas}'' 2>/dev/null)\\" = 2 ]"]}]', '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'),
  (494, 8, '메모리 사용률로 늘리고 줄이기 (HPA autoscaling/v2)', '**배경** — `kubectl autoscale` 은 CPU 기준만 만듭니다. **메모리** 등 다른 지표나 여러 지표는 **`autoscaling/v2`** YAML 로 적습니다. `metrics` 의 `resource` 에 `name: memory`, `target: {type: Utilization, averageUtilization: 80}` 처럼 쓰면 requests 대비 평균 사용률이 80% 를 넘을 때 Pod 를 늘립니다. (사용률 계산을 위해 대상 Pod 에 requests 가 있어야 실제로 동작합니다.)

**문제** — Deployment `web` 을 대상으로 하는 HPA **`web-hpa`** 를 `minReplicas: 1`, `maxReplicas: 4`, **메모리 평균 사용률 80%** 로 만드세요.', 'YAML `apiVersion: autoscaling/v2`, `spec.scaleTargetRef` 로 `web`, `metrics` 에 `resource: {name: memory, target: {type: Utilization, averageUtilization: 80}}`', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: web-hpa}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: web}
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: memory
      target: {type: Utilization, averageUtilization: 80}
EOF
kubectl get hpa web-hpa -n $NS

# 사용률은 requests 대비 비율이라 requests 가 없으면 TARGETS 가 <unknown> 으로 보인다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl expose deployment web -n $NS --port=80 >/dev/null; kubectl rollout status deployment/web -n $NS --timeout=120s >/dev/null 2>&1; sleep 2\\n"]', '["sh", "-c", "( [ \\"$(kubectl get hpa web-hpa -n $NS -o jsonpath=''{.spec.metrics[0].resource.name}'' 2>/dev/null)\\" = memory ] ) && ( [ \\"$(kubectl get hpa web-hpa -n $NS -o jsonpath=''{.spec.metrics[0].resource.target.averageUtilization}'' 2>/dev/null)\\" = 80 ] ) && ( [ \\"$(kubectl get hpa web-hpa -n $NS -o jsonpath=''{.spec.maxReplicas}'' 2>/dev/null)\\" = 4 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "지표가 memory 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get hpa web-hpa -n $NS -o jsonpath=''{.spec.metrics[0].resource.name}'' 2>/dev/null)\\" = memory ]"]}, {"label": "목표 사용률이 80 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get hpa web-hpa -n $NS -o jsonpath=''{.spec.metrics[0].resource.target.averageUtilization}'' 2>/dev/null)\\" = 80 ]"]}, {"label": "maxReplicas 가 4 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get hpa web-hpa -n $NS -o jsonpath=''{.spec.maxReplicas}'' 2>/dev/null)\\" = 4 ]"]}]', '[{"title": "HorizontalPodAutoscaler", "url": "https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/"}]'),
  (494, 9, '이름 풀이 규칙 바꾸기 (dnsConfig ndots)', '**배경** — Pod 의 `/etc/resolv.conf` 에는 기본 `options ndots:5` 가 있어, **점이 5개 미만인 이름**은 먼저 검색 도메인(`svc.cluster.local` 등)을 붙여 여러 번 조회합니다. 외부 도메인을 많이 부르는 앱은 불필요한 DNS 질의가 늘어납니다. Pod 의 **`dnsConfig.options`** 로 `ndots` 를 바꿀 수 있습니다.

**문제** — Pod **`dnsp`**(`busybox:1.36`, `sleep 3600`)를 만들되 `dnsConfig` 로 **`ndots` 를 `2`** 로 설정하세요. (`/etc/resolv.conf` 에 `ndots:2` 가 보여야 합니다.)', 'Pod 스펙 `dnsConfig: {options: [{name: ndots, value: "2"}]}`', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: dnsp}
spec:
  terminationGracePeriodSeconds: 0
  dnsConfig:
    options:
    - {name: ndots, value: "2"}
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
kubectl wait --for=condition=Ready pod/dnsp -n $NS --timeout=90s
kubectl exec dnsp -n $NS -- cat /etc/resolv.conf

# options ndots:2 로 바뀐다. 값이 작을수록 외부 이름을 곧바로 질의한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; pkill -x kubectl >/dev/null 2>&1; kubectl delete hpa web-hpa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web spread -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc web -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod memp projp subp rfp dnsp -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm p-cm extra-cm -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete secret p-sec -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( kubectl exec dnsp -n $NS -- cat /etc/resolv.conf 2>/dev/null | grep -q \\"ndots:2\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "resolv.conf 에 ndots:2 가 있다", "cmd": ["sh", "-c", "kubectl exec dnsp -n $NS -- cat /etc/resolv.conf 2>/dev/null | grep -q \\"ndots:2\\""]}]', '[{"title": "Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'),
  (494, 10, 'topologySpreadConstraints 의 whenUnsatisfiable', '`whenUnsatisfiable: DoNotSchedule` 은 분산 조건을 **맞출 수 없을 때** 어떻게 동작할까요?', '"스케줄 하지 않음" 이라는 이름 그대로예요.', NULL, NULL, '[]', 'choice', '["조건을 무시하고 아무 노드에나 배치한다", "Pod 를 배치하지 않고 Pending 으로 둔다", "이미 떠 있는 다른 Pod 를 삭제한다", "노드를 새로 만들어 조건을 맞춘다"]', 1, 'DoNotSchedule 은 조건을 어기는 배치를 거부해 Pod 가 Pending 으로 남습니다. ScheduleAnyway 는 조건을 어기더라도 배치하되 편차가 적은 노드를 우선합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'),
  (494, 11, '메모리 기반 임시 볼륨', '`emptyDir` 를 디스크 대신 메모리에 만드는 설정입니다. 빈칸을 채우세요.', '"메모리" 의 영어예요.', NULL, NULL, '[]', 'fill', '["Memory", "Disk", "tmpfs", "RAM"]', NULL, 'emptyDir.medium 에 Memory 를 주면 tmpfs 로 만들어집니다. 기본값(빈 문자열)은 노드의 디스크를 씁니다. tmpfs 는 결과 파일시스템 이름이고 medium 값은 Memory 입니다.', '[0]', 'emptyDir: {medium: {0}, sizeLimit: 64Mi}', NULL, '[{"title": "볼륨 (emptyDir)", "url": "https://kubernetes.io/docs/concepts/storage/volumes/#emptydir"}]'),
  (494, 12, 'port-forward 로 앱 확인하는 순서', '임시로 클러스터 안의 앱에 접속해 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '열기 → 접속 → 닫기예요.', NULL, NULL, '[]', 'order', '["`kubectl get svc` 로 대상 Service 와 포트를 확인한다", "`kubectl port-forward svc/이름 8080:80 &` 로 포워딩을 시작한다", "`curl localhost:8080` 으로 접속해 응답을 확인한다", "확인이 끝나면 포워딩 프로세스를 종료한다"]', NULL, 'port-forward 는 실행되는 동안만 로컬 포트를 열어 둡니다. 대상 포트를 확인하고, 포워딩을 시작해 접속해 본 뒤, 끝나면 프로세스를 종료해 포트를 닫습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "port-forward 로 앱에 접근", "url": "https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/"}]');
