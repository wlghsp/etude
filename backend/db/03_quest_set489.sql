-- 세트 489: k8s 서비스 노출과 볼륨 설정 손연습: Ingress 규칙·pathType, ExternalName·NodePort, hostAliases, downwardAPI 볼륨, Secret defaultMode, StatefulSet PVC, concurrencyPolicy
-- 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다. docs/specs/spec_k8s_expose_volume_lab_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (489, 1, 'Ingress 로 도메인 하나 연결하기 (create ingress)', '**배경** — **Ingress** 는 클러스터 밖 HTTP 요청을 **도메인·경로 규칙**에 따라 Service 로 보냅니다. `kubectl create ingress 이름 --rule="호스트/경로=서비스:포트"` 로 만들고, 경로가 `*` 로 끝나지 않으면 `pathType` 은 `Exact` 입니다. Service `web`(포트 80)이 있습니다.

**문제** — `app.example.com` 의 경로 `/` 요청을 Service `web` 포트 `80` 으로 보내는 Ingress **`web-ing`** 을 만드세요.', '`kubectl create ingress web-ing --rule="app.example.com/=web:80"`', 'kubectl create ingress web-ing -n $NS --rule="app.example.com/=web:80"
kubectl get ingress web-ing -n $NS

# rule 형식은 호스트/경로=서비스:포트', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl expose deployment web -n $NS --port=80 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].host}'' 2>/dev/null)\\" = app.example.com ] ) && ( [ \\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].backend.service.name}:{.spec.rules[0].http.paths[0].backend.service.port.number}'' 2>/dev/null)\\" = web:80 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "호스트가 app.example.com 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].host}'' 2>/dev/null)\\" = app.example.com ]"]}, {"label": "백엔드가 web:80 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].backend.service.name}:{.spec.rules[0].http.paths[0].backend.service.port.number}'' 2>/dev/null)\\" = web:80 ]"]}]', '[{"title": "Ingress", "url": "https://kubernetes.io/docs/concepts/services-networking/ingress/"}]'),
  (489, 2, '경로 접두어로 보내기 (pathType Prefix)', '**배경** — `pathType` 이 `Exact` 면 경로가 정확히 같을 때만, **`Prefix`** 면 그 경로로 **시작하는** 모든 요청(`/api`, `/api/users`)이 맞습니다. `kubectl create ingress` 의 규칙에서 경로 끝에 **`*`** 를 붙이면 `Prefix` 가 됩니다.

**문제** — `app.example.com` 의 `/api` 로 시작하는 요청을 Service `web` 포트 `80` 으로 보내는 Ingress **`api-ing`** 을 만드세요. (`pathType` 이 `Prefix`, 경로가 `/api` 여야 합니다.)', '`kubectl create ingress api-ing --rule="app.example.com/api*=web:80"`', 'kubectl create ingress api-ing -n $NS --rule="app.example.com/api*=web:80"
kubectl get ingress api-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].pathType}''

# 끝의 * 가 Prefix 를 뜻한다. 없으면 Exact', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl expose deployment web -n $NS --port=80 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get ingress api-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].pathType}'' 2>/dev/null)\\" = Prefix ] ) && ( [ \\"$(kubectl get ingress api-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].path}'' 2>/dev/null)\\" = /api ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "pathType 이 Prefix 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get ingress api-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].pathType}'' 2>/dev/null)\\" = Prefix ]"]}, {"label": "경로가 /api 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get ingress api-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].path}'' 2>/dev/null)\\" = /api ]"]}]', '[{"title": "Ingress", "url": "https://kubernetes.io/docs/concepts/services-networking/ingress/"}]'),
  (489, 3, '밖의 도메인을 안의 이름으로 (ExternalName Service)', '**배경** — **`ExternalName`** Service 는 Pod 를 고르지 않고 클러스터 안 DNS 이름을 **바깥 도메인의 별칭(CNAME)** 으로 만듭니다. 앱은 `db` 라는 이름만 쓰고, 실제 주소는 나중에 Service 만 바꿔 교체할 수 있습니다.

**문제** — 외부 도메인 **`db.example.com`** 을 가리키는 `ExternalName` Service **`db`** 를 만드세요.', '`kubectl create service externalname db --external-name=db.example.com`', 'kubectl create service externalname db -n $NS --external-name=db.example.com
kubectl get svc db -n $NS

# TYPE 이 ExternalName, EXTERNAL-IP 칸에 도메인이 보인다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get svc db -n $NS -o jsonpath=''{.spec.type}'' 2>/dev/null)\\" = ExternalName ] ) && ( [ \\"$(kubectl get svc db -n $NS -o jsonpath=''{.spec.externalName}'' 2>/dev/null)\\" = db.example.com ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "타입이 ExternalName 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get svc db -n $NS -o jsonpath=''{.spec.type}'' 2>/dev/null)\\" = ExternalName ]"]}, {"label": "externalName 이 db.example.com 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get svc db -n $NS -o jsonpath=''{.spec.externalName}'' 2>/dev/null)\\" = db.example.com ]"]}]', '[{"title": "Service", "url": "https://kubernetes.io/docs/concepts/services-networking/service/"}]'),
  (489, 4, 'NodePort 로 열고 번호 읽기', '**배경** — **`NodePort`** Service 는 모든 노드의 **높은 포트(기본 30000–32767)** 를 열어 밖에서 `노드IP:포트` 로 접속하게 합니다. 포트를 지정하지 않으면 자동 배정됩니다. Deployment `web` 이 있습니다.

**문제** — `web` 을 **`NodePort`** 타입, 서비스 포트 `80` 으로 노출하는 Service **`web-np`** 를 만들고, **배정된 노드 포트 번호**를 **`/tmp/q4.txt`** 에 저장하세요.', '`kubectl expose deployment web --name=web-np --type=NodePort --port=80` 후 `kubectl get svc web-np -o jsonpath=''{.spec.ports[0].nodePort}''`', 'kubectl expose deployment web -n $NS --name=web-np --type=NodePort --port=80
kubectl get svc web-np -n $NS -o jsonpath=''{.spec.ports[0].nodePort}'' > /tmp/q4.txt
cat /tmp/q4.txt

# PORT(S) 칸의 80:3xxxx/TCP 에서 뒤의 값이 노드 포트', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get svc web-np -n $NS -o jsonpath=''{.spec.type}'' 2>/dev/null)\\" = NodePort ] ) && ( [ -n \\"$(cat /tmp/q4.txt)\\" ] && [ \\"$(cat /tmp/q4.txt)\\" = \\"$(kubectl get svc web-np -n $NS -o jsonpath=''{.spec.ports[0].nodePort}'' 2>/dev/null)\\" ] ) && ( [ \\"$(cat /tmp/q4.txt)\\" -ge 30000 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "타입이 NodePort 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get svc web-np -n $NS -o jsonpath=''{.spec.type}'' 2>/dev/null)\\" = NodePort ]"]}, {"label": "파일 값이 실제 nodePort 다", "cmd": ["sh", "-c", "[ -n \\"$(cat /tmp/q4.txt)\\" ] && [ \\"$(cat /tmp/q4.txt)\\" = \\"$(kubectl get svc web-np -n $NS -o jsonpath=''{.spec.ports[0].nodePort}'' 2>/dev/null)\\" ]"]}, {"label": "30000 이상이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q4.txt)\\" -ge 30000 ]"]}]', '[{"title": "Service", "url": "https://kubernetes.io/docs/concepts/services-networking/service/"}]'),
  (489, 5, 'Pod 의 /etc/hosts 에 항목 넣기 (hostAliases)', '**배경** — Pod 스펙의 **`hostAliases`** 는 컨테이너의 `/etc/hosts` 에 **IP 와 호스트 이름**을 추가합니다. DNS 에 없는 이름을 테스트용으로 풀거나 임시로 우회할 때 씁니다.

**문제** — `busybox:1.36`(`sleep 3600`) Pod **`hapod`** 를 만들되 `hostAliases` 로 **`10.9.8.7` → `cache.local`** 을 넣으세요. (Pod 가 Ready 가 된 뒤 `/etc/hosts` 에 보여야 합니다.)', 'Pod 스펙(`spec:` 바로 아래)에 `hostAliases:` 로 `- ip: "10.9.8.7"` 와 `hostnames: ["cache.local"]` 을 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: hapod}
spec:
  terminationGracePeriodSeconds: 0
  hostAliases:
  - ip: "10.9.8.7"
    hostnames: ["cache.local"]
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
EOF
kubectl wait --for=condition=Ready pod/hapod -n $NS --timeout=90s
kubectl exec hapod -n $NS -- cat /etc/hosts

# kubelet 이 /etc/hosts 를 관리하므로 컨테이너 안에서 직접 고친 것은 재시작하면 사라진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( kubectl exec hapod -n $NS -- cat /etc/hosts 2>/dev/null | grep -Eq \\"^10\\\\.9\\\\.8\\\\.7[[:space:]]+cache\\\\.local\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/etc/hosts 에 cache.local 이 있다", "cmd": ["sh", "-c", "kubectl exec hapod -n $NS -- cat /etc/hosts 2>/dev/null | grep -Eq \\"^10\\\\.9\\\\.8\\\\.7[[:space:]]+cache\\\\.local\\""]}]', '[{"title": "hostAliases 로 /etc/hosts 항목 추가", "url": "https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/"}]'),
  (489, 6, 'Pod 자신의 라벨을 파일로 받기 (downwardAPI 볼륨)', '**배경** — **Downward API** 는 Pod 자신의 메타데이터(이름·라벨·어노테이션 등)를 앱에 알려 줍니다. 환경 변수로 줄 수도 있지만 **볼륨**으로 주면 **라벨이 바뀔 때 파일이 갱신**됩니다. `items` 에 `path` 와 `fieldRef.fieldPath: metadata.labels` 를 적습니다.

**문제** — 라벨 `app=demo` 가 붙은 Pod **`dapod`**(`busybox:1.36`, `sleep 3600`)를 만들어, 자신의 라벨을 **`/etc/podinfo/labels`** 파일로 볼 수 있게 하세요.', 'volumes 에 `downwardAPI:` → `items:` → `path: labels`, `fieldRef: {fieldPath: metadata.labels}` 를 적고 `/etc/podinfo` 에 마운트해요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: dapod
  labels: {app: demo}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - {name: info, mountPath: /etc/podinfo}
  volumes:
  - name: info
    downwardAPI:
      items:
      - path: labels
        fieldRef: {fieldPath: metadata.labels}
EOF
kubectl wait --for=condition=Ready pod/dapod -n $NS --timeout=90s
kubectl exec dapod -n $NS -- cat /etc/podinfo/labels

# 파일에는 app="demo" 형태로 한 줄씩 들어 있다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( kubectl exec dapod -n $NS -- cat /etc/podinfo/labels 2>/dev/null | grep -q ''app=\\"demo\\"'' )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "labels 파일에 app=\\"demo\\" 가 있다", "cmd": ["sh", "-c", "kubectl exec dapod -n $NS -- cat /etc/podinfo/labels 2>/dev/null | grep -q ''app=\\"demo\\"''"]}]', '[{"title": "Downward API 볼륨으로 Pod 정보 노출", "url": "https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/"}]'),
  (489, 7, 'Secret 파일을 소유자만 읽게 (defaultMode)', '**배경** — Secret 을 볼륨으로 마운트하면 파일 권한은 기본 `0644` 입니다. 볼륨의 **`defaultMode`** 로 `0400`(소유자 읽기 전용)처럼 **더 엄격하게** 줄 수 있습니다. 키 파일·인증서에 중요합니다. Secret `db-pass` 에 `pw` 키가 있습니다.

**문제** — Pod **`secpod`**(`busybox:1.36`, `sleep 3600`)에 `db-pass` 를 `/etc/sec` 로 마운트하되 **`defaultMode: 0400`** 으로 하세요. (`/etc/sec/pw` 의 권한이 `400` 이어야 합니다.)', 'secret 볼륨 아래에 `secretName: db-pass` 와 `defaultMode: 0400` 을 적어요. (YAML 의 `0400` 은 8진수로 읽혀요.)', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: secpod}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - {name: sec, mountPath: /etc/sec}
  volumes:
  - name: sec
    secret:
      secretName: db-pass
      defaultMode: 0400
EOF
kubectl wait --for=condition=Ready pod/secpod -n $NS --timeout=90s
kubectl exec secpod -n $NS -- stat -L -c %a /etc/sec/pw

# 기본 0644 → 0400. 컨테이너가 다른 사용자로 돌면 읽지 못하므로 fsGroup 과 함께 설계한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create secret generic db-pass -n $NS --from-literal=pw=s3cret >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec secpod -n $NS -- stat -L -c %a /etc/sec/pw 2>/dev/null)\\" = 400 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/etc/sec/pw 권한이 400 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec secpod -n $NS -- stat -L -c %a /etc/sec/pw 2>/dev/null)\\" = 400 ]"]}]', '[{"title": "Secret", "url": "https://kubernetes.io/docs/concepts/configuration/secret/"}]'),
  (489, 8, 'StatefulSet 과 Pod 별 볼륨 (volumeClaimTemplates)', '**배경** — **StatefulSet** 은 Pod 에 **고정된 이름**(`이름-0`, `이름-1`)과 **Pod 마다 따로 만들어지는 볼륨**을 줍니다. `volumeClaimTemplates` 의 템플릿마다 PVC `템플릿이름-스테이트풀셋이름-번호` 가 생기고, Pod 를 지워도 PVC 는 남습니다.

**문제** — 이름 **`kv`**, 이미지 `nginx:1.25`, 복제 `1`, `serviceName: kv` 인 StatefulSet 을 만들되 `volumeClaimTemplates` 로 **`data`**(`100Mi`, `ReadWriteOnce`)를 `/data` 에 마운트하세요. PVC `data-kv-0` 이 **Bound** 가 되어야 합니다.', 'YAML 의 `spec.volumeClaimTemplates` 에 `metadata.name: data`, `accessModes: [ReadWriteOnce]`, `resources.requests.storage: 100Mi` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: kv}
spec:
  serviceName: kv
  replicas: 1
  selector:
    matchLabels: {app: kv}
  template:
    metadata:
      labels: {app: kv}
    spec:
      terminationGracePeriodSeconds: 0
      containers:
      - name: web
        image: nginx:1.25
        volumeMounts:
        - {name: data, mountPath: /data}
  volumeClaimTemplates:
  - metadata: {name: data}
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests: {storage: 100Mi}
EOF
kubectl wait --for=condition=Ready pod/kv-0 -n $NS --timeout=120s
kubectl get pvc -n $NS

# PVC 이름 = data-kv-0. StatefulSet 을 지워도 PVC 는 남으므로 따로 지워야 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pvc data-kv-0 -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Bound ] ) && ( [ \\"$(kubectl get pod kv-0 -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "PVC data-kv-0 이 Bound 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pvc data-kv-0 -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Bound ]"]}, {"label": "Pod kv-0 이 Running 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod kv-0 -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ]"]}]', '[{"title": "StatefulSet", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/"}]'),
  (489, 9, '이전 실행이 안 끝났으면 건너뛰기 (concurrencyPolicy)', '**배경** — CronJob 의 **`concurrencyPolicy`** 는 이전 Job 이 아직 도는데 다음 시각이 되었을 때를 정합니다. 기본 `Allow` 는 겹쳐 실행하고, **`Forbid`** 는 새 실행을 **건너뛰고**, `Replace` 는 이전 것을 지우고 새로 시작합니다. CronJob `tick`(5분마다)이 있습니다.

**문제** — `tick` 의 `concurrencyPolicy` 를 **`Forbid`** 로 바꾸세요.', '`kubectl patch cronjob tick -p ''{"spec":{"concurrencyPolicy":"Forbid"}}''`', 'kubectl patch cronjob tick -n $NS -p ''{"spec":{"concurrencyPolicy":"Forbid"}}''
kubectl get cronjob tick -n $NS -o jsonpath=''{.spec.concurrencyPolicy}''

# 오래 걸리는 배치가 겹쳐 쌓이는 것을 막을 때 Forbid', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete ingress web-ing api-ing -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc web web-np db -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete sts kv -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pvc data-kv-0 -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod hapod dapod secpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete secret db-pass -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cronjob tick -n $NS --image=busybox:1.36 --schedule=''*/5 * * * *'' -- echo hi >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get cronjob tick -n $NS -o jsonpath=''{.spec.concurrencyPolicy}'' 2>/dev/null)\\" = Forbid ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "concurrencyPolicy 가 Forbid 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get cronjob tick -n $NS -o jsonpath=''{.spec.concurrencyPolicy}'' 2>/dev/null)\\" = Forbid ]"]}]', '[{"title": "CronJob", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/"}]'),
  (489, 10, 'create ingress 규칙의 경로 끝 *', '`kubectl create ingress --rule="app.example.com/api*=web:80"` 에서 경로 끝의 `*` 는 무엇을 뜻할까요?', 'pathType 과 관련 있어요.', NULL, NULL, '[]', 'choice', '["요청 호스트가 모든 도메인과 맞음", "pathType 이 Prefix 가 됨", "서비스 포트를 자동으로 골라 줌", "이 경로에 TLS 암호화를 켜 줌"]', 1, 'kubectl create ingress 는 경로가 *로 끝나면 pathType 을 Prefix 로, 아니면 Exact 로 만듭니다. Prefix 는 그 경로로 시작하는 모든 요청에 맞습니다.', NULL, NULL, NULL, '[{"title": "Ingress", "url": "https://kubernetes.io/docs/concepts/services-networking/ingress/"}]'),
  (489, 11, '외부 도메인 별칭 Service', '바깥 도메인을 클러스터 안의 이름으로 연결하는 Service 를 만드는 명령입니다. 빈칸을 채우세요.', '"외부 이름" 이에요.', NULL, NULL, '[]', 'fill', '["externalname", "nodeport", "clusterip", "loadbalancer"]', NULL, 'externalname 타입은 --external-name 으로 바깥 도메인을 지정해 CNAME 처럼 동작합니다. nodeport·clusterip·loadbalancer 는 Pod 를 선택해 노출하는 타입입니다.', '[0]', 'kubectl create service {0} db --external-name=db.example.com', NULL, '[{"title": "Service", "url": "https://kubernetes.io/docs/concepts/services-networking/service/"}]'),
  (489, 12, 'Ingress 로 들어온 요청의 흐름', '바깥에서 온 HTTP 요청이 Pod 까지 가는 순서입니다. 순서에 맞게 놓아 보세요.', '밖에서 안쪽으로 한 단계씩이에요.', NULL, NULL, '[]', 'order', '["클라이언트가 도메인으로 요청을 보낸다", "Ingress 컨트롤러가 요청을 받는다", "컨트롤러가 Ingress 규칙의 호스트·경로로 Service 를 고른다", "Service 가 준비된 Pod 중 하나로 전달한다"]', NULL, 'Ingress 오브젝트는 규칙일 뿐이고 실제로 요청을 받아 처리하는 것은 Ingress 컨트롤러입니다. 컨트롤러가 규칙에 맞는 Service 를 고르고 Service 가 Pod 로 전달합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Ingress", "url": "https://kubernetes.io/docs/concepts/services-networking/ingress/"}]');
