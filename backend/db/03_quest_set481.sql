-- 세트 481: k8s Pod 보안과 NetworkPolicy 손연습: securityContext, readOnlyRootFilesystem, capabilities, ServiceAccount, 기본 거부, 라벨 허용, patch
-- 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다. docs/specs/spec_k8s_security_netpol_lab_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (481, 1, 'root 가 아닌 사용자로 실행하기 (runAsUser)', '**배경** — 컨테이너는 기본적으로 이미지가 정한 사용자(대개 root)로 실행됩니다. Pod 의 `securityContext` 에 `runAsUser` 로 **사용자 번호**를, `runAsNonRoot: true` 로 **root 금지**를 정해 최소 권한으로 실행합니다.

**문제** — `busybox:1.36` 이미지로 `sleep 3600` 을 하는 Pod **`sec-user`** 를 만드세요. Pod 수준 `securityContext` 에 **`runAsUser: 1000`** 과 **`runAsNonRoot: true`** 를 설정합니다. 컨테이너 안에서 `id -u` 가 `1000` 이어야 합니다.', 'Pod `spec.securityContext` 에 `runAsUser: 1000`, `runAsNonRoot: true`. 확인은 `kubectl exec sec-user -- id -u`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: sec-user
  labels: {}
spec:
  terminationGracePeriodSeconds: 0
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
EOF
kubectl wait --for=condition=Ready pod/sec-user -n $NS --timeout=90s
kubectl exec sec-user -n $NS -- id -u

# Pod 수준 securityContext 는 모든 컨테이너에 적용된다. runAsNonRoot 는 root(0)로 뜨려 하면 시작을 막는다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod sec-user -n $NS -o jsonpath=''{.spec.securityContext.runAsUser}'' 2>/dev/null)\\" = 1000 ] ) && ( [ \\"$(kubectl get pod sec-user -n $NS -o jsonpath=''{.spec.securityContext.runAsNonRoot}'' 2>/dev/null)\\" = true ] ) && ( kubectl wait --for=condition=Ready pod/sec-user -n $NS --timeout=90s >/dev/null 2>&1 && [ \\"$(kubectl exec sec-user -n $NS -- id -u 2>/dev/null)\\" = 1000 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "runAsUser 가 1000 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sec-user -n $NS -o jsonpath=''{.spec.securityContext.runAsUser}'' 2>/dev/null)\\" = 1000 ]"]}, {"label": "runAsNonRoot 가 true 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sec-user -n $NS -o jsonpath=''{.spec.securityContext.runAsNonRoot}'' 2>/dev/null)\\" = true ]"]}, {"label": "컨테이너 안 사용자 번호가 1000 이다", "cmd": ["sh", "-c", "kubectl wait --for=condition=Ready pod/sec-user -n $NS --timeout=90s >/dev/null 2>&1 && [ \\"$(kubectl exec sec-user -n $NS -- id -u 2>/dev/null)\\" = 1000 ]"]}]', '[{"title": "Pod·컨테이너 보안 컨텍스트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"}]'),
  (481, 2, '루트 파일시스템을 읽기 전용으로 (readOnlyRootFilesystem)', '**배경** — `readOnlyRootFilesystem: true` 는 컨테이너의 **루트 파일시스템을 읽기 전용**으로 만들어, 침입자가 파일을 바꾸거나 도구를 설치하기 어렵게 합니다. 쓸 곳이 필요하면 그 경로에만 **`emptyDir` 볼륨**을 붙입니다.

**문제** — `busybox:1.36`, `sleep 3600` 의 Pod **`sec-ro`** 를 만드세요. 컨테이너 `securityContext` 에 **`readOnlyRootFilesystem: true`** 를 설정하고, **`/tmp` 에만** `emptyDir` 를 붙여 쓸 수 있게 하세요. `/` 아래에는 쓸 수 없고 `/tmp` 에는 쓸 수 있어야 합니다.', '컨테이너 `securityContext.readOnlyRootFilesystem: true` + `volumes` 의 `emptyDir` 를 `/tmp` 에 `volumeMounts`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: sec-ro
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      readOnlyRootFilesystem: true
    volumeMounts:
    - {name: tmp, mountPath: /tmp}
  volumes:
  - {name: tmp, emptyDir: {}}
EOF
kubectl wait --for=condition=Ready pod/sec-ro -n $NS --timeout=90s
kubectl exec sec-ro -n $NS -- touch /x
kubectl exec sec-ro -n $NS -- touch /tmp/ok && echo tmp-ok

# 루트는 읽기 전용이라 touch /x 가 실패한다. emptyDir 를 붙인 /tmp 만 쓸 수 있다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod sec-ro -n $NS -o jsonpath=''{.spec.containers[0].securityContext.readOnlyRootFilesystem}'' 2>/dev/null)\\" = true ] ) && ( kubectl wait --for=condition=Ready pod/sec-ro -n $NS --timeout=90s >/dev/null 2>&1 && ! kubectl exec sec-ro -n $NS -- touch /x >/dev/null 2>&1 ) && ( kubectl exec sec-ro -n $NS -- touch /tmp/ok >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "readOnlyRootFilesystem 이 true 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sec-ro -n $NS -o jsonpath=''{.spec.containers[0].securityContext.readOnlyRootFilesystem}'' 2>/dev/null)\\" = true ]"]}, {"label": "루트에는 쓸 수 없다", "cmd": ["sh", "-c", "kubectl wait --for=condition=Ready pod/sec-ro -n $NS --timeout=90s >/dev/null 2>&1 && ! kubectl exec sec-ro -n $NS -- touch /x >/dev/null 2>&1"]}, {"label": "/tmp 에는 쓸 수 있다", "cmd": ["sh", "-c", "kubectl exec sec-ro -n $NS -- touch /tmp/ok >/dev/null 2>&1"]}]', '[{"title": "Pod·컨테이너 보안 컨텍스트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"}]'),
  (481, 3, '권한 줄이기 (capabilities drop ALL)', '**배경** — 리눅스 **capability** 는 root 의 권한을 잘게 쪼갠 것입니다. 컨테이너에는 기본으로 일부가 주어지는데, `capabilities.drop: ["ALL"]` 로 **모두 빼고** 필요한 것만 `add` 하는 것이 권장됩니다. `allowPrivilegeEscalation: false` 는 실행 중 권한 상승(setuid 등)을 막습니다.

**문제** — `busybox:1.36`, `sleep 3600` 의 Pod **`sec-cap`** 을 만들되 컨테이너 `securityContext` 에 **`capabilities.drop: ["ALL"]`** 과 **`allowPrivilegeEscalation: false`** 를 설정하세요.', '컨테이너 `securityContext` 아래 `allowPrivilegeEscalation: false`, `capabilities: {drop: ["ALL"]}`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: sec-cap
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
EOF
kubectl wait --for=condition=Ready pod/sec-cap -n $NS --timeout=90s
kubectl get pod sec-cap -n $NS -o jsonpath=''{.spec.containers[0].securityContext}''

# 최소 권한 원칙: 모두 빼고(drop ALL) 필요한 것만 add 한다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod sec-cap -n $NS -o jsonpath=''{.spec.containers[0].securityContext.capabilities.drop[0]}'' 2>/dev/null)\\" = ALL ] ) && ( [ \\"$(kubectl get pod sec-cap -n $NS -o jsonpath=''{.spec.containers[0].securityContext.allowPrivilegeEscalation}'' 2>/dev/null)\\" = false ] ) && ( kubectl wait --for=condition=Ready pod/sec-cap -n $NS --timeout=90s >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "capabilities 를 모두 뺐다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sec-cap -n $NS -o jsonpath=''{.spec.containers[0].securityContext.capabilities.drop[0]}'' 2>/dev/null)\\" = ALL ]"]}, {"label": "권한 상승을 막았다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sec-cap -n $NS -o jsonpath=''{.spec.containers[0].securityContext.allowPrivilegeEscalation}'' 2>/dev/null)\\" = false ]"]}, {"label": "Pod 가 실행 중이다", "cmd": ["sh", "-c", "kubectl wait --for=condition=Ready pod/sec-cap -n $NS --timeout=90s >/dev/null 2>&1"]}]', '[{"title": "Pod·컨테이너 보안 컨텍스트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"}]'),
  (481, 4, '서비스 어카운트 만들고 토큰 자동 마운트 끄기', '**배경** — Pod 는 **ServiceAccount** 의 이름으로 API 서버에 접근합니다. 기본으로 토큰이 `/var/run/secrets/kubernetes.io/serviceaccount` 에 **자동 마운트**되는데, API 를 쓰지 않는 앱에는 불필요한 위험이므로 `automountServiceAccountToken: false` 로 끕니다.

**문제** — ServiceAccount **`app-sa`** 를 만들고, 이를 쓰는 Pod **`sa-pod`**(`busybox:1.36`, `sleep 3600`)를 만드세요. Pod 에 **`automountServiceAccountToken: false`** 를 설정해, 컨테이너 안에 토큰 폴더가 **없어야** 합니다.', '`kubectl create serviceaccount app-sa` → Pod `spec.serviceAccountName: app-sa`, `spec.automountServiceAccountToken: false`', 'kubectl create serviceaccount app-sa -n $NS
kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
spec:
  terminationGracePeriodSeconds: 0
  serviceAccountName: app-sa
  automountServiceAccountToken: false
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "sleep 3600"]
EOF
kubectl wait --for=condition=Ready pod/sa-pod -n $NS --timeout=90s
kubectl exec sa-pod -n $NS -- ls /var/run/secrets/kubernetes.io/serviceaccount

# 토큰을 마운트하지 않으면 위 ls 가 실패한다 (그런 폴더가 없다)', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; true"]', '["sh", "-c", "( kubectl get serviceaccount app-sa -n $NS >/dev/null 2>&1 ) && ( [ \\"$(kubectl get pod sa-pod -n $NS -o jsonpath=''{.spec.serviceAccountName}'' 2>/dev/null)\\" = app-sa ] ) && ( [ \\"$(kubectl get pod sa-pod -n $NS -o jsonpath=''{.spec.automountServiceAccountToken}'' 2>/dev/null)\\" = false ] ) && ( kubectl wait --for=condition=Ready pod/sa-pod -n $NS --timeout=90s >/dev/null 2>&1 && ! kubectl exec sa-pod -n $NS -- ls /var/run/secrets/kubernetes.io/serviceaccount >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "app-sa 가 있다", "cmd": ["sh", "-c", "kubectl get serviceaccount app-sa -n $NS >/dev/null 2>&1"]}, {"label": "Pod 가 app-sa 를 쓴다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sa-pod -n $NS -o jsonpath=''{.spec.serviceAccountName}'' 2>/dev/null)\\" = app-sa ]"]}, {"label": "토큰 자동 마운트가 꺼져 있다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sa-pod -n $NS -o jsonpath=''{.spec.automountServiceAccountToken}'' 2>/dev/null)\\" = false ]"]}, {"label": "컨테이너 안에 토큰 폴더가 없다", "cmd": ["sh", "-c", "kubectl wait --for=condition=Ready pod/sa-pod -n $NS --timeout=90s >/dev/null 2>&1 && ! kubectl exec sa-pod -n $NS -- ls /var/run/secrets/kubernetes.io/serviceaccount >/dev/null 2>&1"]}]', '[{"title": "Pod 에 서비스 어카운트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/"}]'),
  (481, 5, 'Pod 와 컨테이너 설정이 다르면 누가 이길까', '**배경** — `securityContext` 는 **Pod 수준**과 **컨테이너 수준** 모두에 쓸 수 있고, 같은 항목이면 **컨테이너 쪽이 우선**합니다. Pod `sec-prep` 은 Pod 수준 `runAsUser: 2000`, 컨테이너 수준 `runAsUser: 3000` 으로 이미 만들어져 있습니다.

**문제** — 컨테이너 안에서 실제로 실행되는 사용자 번호(`id -u`)를 **`/tmp/q5.txt`** 에 저장하세요.', '`kubectl exec sec-prep -- id -u` 의 결과를 저장하세요.', 'kubectl exec sec-prep -n $NS -- id -u > /tmp/q5.txt
cat /tmp/q5.txt

# 컨테이너 수준 설정이 Pod 수준 설정을 덮어쓴다. 그래서 3000 이다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: sec-prep\\n  labels: {}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  securityContext:\\n    runAsUser: 2000\\n  containers:\\n  - name: c\\n    image: busybox:1.36\\n    securityContext:\\n      runAsUser: 3000\\n    command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]\\nEOF\\nkubectl wait --for=condition=Ready pod/sec-prep -n $NS --timeout=90s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q5.txt)\\" = 3000 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 3000 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q5.txt)\\" = 3000 ]"]}]', '[{"title": "Pod·컨테이너 보안 컨텍스트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"}]'),
  (481, 6, '기본 거부 정책 만들기 (NetworkPolicy deny-all)', '**배경** — NetworkPolicy 가 **없으면 모든 Pod 끼리 통신이 허용**됩니다. 어떤 정책이 Pod 를 **선택하는 순간** 그 Pod 로 들어오는 트래픽은 정책이 허용한 것만 통과합니다. `podSelector: {}` 는 **네임스페이스의 모든 Pod** 를 뜻하므로, 허용 규칙(`ingress`)이 없는 정책 하나로 **수신을 전부 막는** 기본 거부가 됩니다. 이미 `np-server`(nginx, Service `np-server`), `np-client`, `np-other` 가 떠 있고 지금은 `np-client` 에서 `np-server` 로 접속됩니다.

**문제** — 이름이 **`deny-all`** 이고 **모든 Pod 의 수신(Ingress)을 막는** NetworkPolicy 를 만드세요. 적용 후 `np-client` 에서 `np-server` 로의 접속이 **막혀야** 합니다.', '`podSelector: {}`, `policyTypes: [Ingress]`, `ingress` 규칙은 쓰지 않아요.', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all}
spec:
  podSelector: {}
  policyTypes: [Ingress]
EOF
sleep 3
kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server

# ingress 규칙이 없는 정책은 선택한 Pod 로 들어오는 모든 트래픽을 막는다 (접속 시간 초과)', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-server, labels: {app: server}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"nginx:1.25\\"}]\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-client, labels: {role: client}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]}]\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-other, labels: {role: other}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]}]\\n---\\napiVersion: v1\\nkind: Service\\nmetadata: {name: np-server}\\nspec:\\n  selector: {app: server}\\n  ports: [{port: 80}]\\nEOF\\nkubectl wait --for=condition=Ready pod/np-server pod/np-client pod/np-other -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(kubectl get networkpolicy deny-all -n $NS -o jsonpath=''{.spec.podSelector}'' 2>/dev/null)\\" = \\"{}\\" ] ) && ( kubectl get networkpolicy deny-all -n $NS -o jsonpath=''{.spec.policyTypes[*]}'' 2>/dev/null | grep -q Ingress ) && ( ( i=0; while [ $i -lt 20 ]; do kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 || exit 0; sleep 2; i=$((i+1)); done; exit 1 ) )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "deny-all 정책이 있고 모든 Pod 를 선택한다", "cmd": ["sh", "-c", "[ \\"$(kubectl get networkpolicy deny-all -n $NS -o jsonpath=''{.spec.podSelector}'' 2>/dev/null)\\" = \\"{}\\" ]"]}, {"label": "수신을 막는 정책이다", "cmd": ["sh", "-c", "kubectl get networkpolicy deny-all -n $NS -o jsonpath=''{.spec.policyTypes[*]}'' 2>/dev/null | grep -q Ingress"]}, {"label": "np-client 접속이 막혔다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 20 ]; do kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 || exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}]', '[{"title": "네트워크 정책", "url": "https://kubernetes.io/docs/concepts/services-networking/network-policies/"}, {"title": "네트워크 정책 선언하기", "url": "https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/"}]'),
  (481, 7, '라벨로 허용하기 (NetworkPolicy allow)', '**배경** — 기본 거부 위에 **허용 정책**을 더하면 허용된 곳만 열립니다. `ingress.from.podSelector` 로 **어떤 라벨의 Pod 에서 오는 트래픽**을 허용할지, `ports` 로 **어떤 포트**를 허용할지 정합니다. 정책은 **합집합**으로 적용되어(하나라도 허용하면 통과), 기본 거부 정책은 그대로 둔 채 허용 정책만 추가하면 됩니다. 지금 `deny-all` 이 적용되어 두 클라이언트 모두 막혀 있습니다.

**문제** — 이름이 **`allow-client`** 인 NetworkPolicy 를 만들어, 라벨 **`app: server`** 인 Pod 로 **`role: client`** 라벨 Pod 에서 오는 **80번 포트** 수신만 허용하세요. 적용 후 `np-client` 는 접속되고 `np-other` 는 **계속 막혀야** 합니다.', '대상 `podSelector.matchLabels: {app: server}`, `ingress.from.podSelector.matchLabels: {role: client}`, `ports: [{port: 80}]`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-client}
spec:
  podSelector:
    matchLabels: {app: server}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels: {role: client}
    ports:
    - {port: 80}
EOF
sleep 3
kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server && echo client-ok
kubectl exec np-other -n $NS -- wget -q -T 3 -O /dev/null http://np-server || echo other-blocked

# 허용은 ''라벨 + 포트'' 로 좁혀서 한다. role=client 가 아닌 Pod 는 계속 막힌다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-server, labels: {app: server}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"nginx:1.25\\"}]\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-client, labels: {role: client}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]}]\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-other, labels: {role: other}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]}]\\n---\\napiVersion: v1\\nkind: Service\\nmetadata: {name: np-server}\\nspec:\\n  selector: {app: server}\\n  ports: [{port: 80}]\\nEOF\\nkubectl wait --for=condition=Ready pod/np-server pod/np-client pod/np-other -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: networking.k8s.io/v1\\nkind: NetworkPolicy\\nmetadata: {name: deny-all}\\nspec:\\n  podSelector: {}\\n  policyTypes: [Ingress]\\nEOF\\nsleep 3\\n"]', '["sh", "-c", "( ( i=0; while [ $i -lt 20 ]; do kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( ( i=0; while [ $i -lt 20 ]; do kubectl exec np-other -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 || exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( kubectl get networkpolicy deny-all -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "np-client 접속이 된다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 20 ]; do kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "np-other 접속은 막혀 있다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 20 ]; do kubectl exec np-other -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 || exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "기본 거부 정책은 그대로다", "cmd": ["sh", "-c", "kubectl get networkpolicy deny-all -n $NS >/dev/null 2>&1"]}]', '[{"title": "네트워크 정책", "url": "https://kubernetes.io/docs/concepts/services-networking/network-policies/"}, {"title": "네트워크 정책 선언하기", "url": "https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/"}]'),
  (481, 8, '잘못된 포트를 고치기 (kubectl patch)', '**배경** — 정책을 만들었는데 접속이 안 될 때 **허용 포트가 틀렸는지** 가장 먼저 봅니다. `kubectl patch --type json` 으로 값 하나만 바꿀 수 있습니다. 지금 `deny-all` 과 `allow-client` 가 있는데, `allow-client` 가 **8080 포트**로 잘못 적혀 있어 `np-client` 도 `np-server`(80)에 접속하지 못합니다.

**문제** — `allow-client` 의 허용 포트를 **80** 으로 고쳐 `np-client` 가 접속되게 하세요. 정책을 지우고 다시 만들지 말고 **patch** 로 고치세요.', '`kubectl patch networkpolicy allow-client --type json -p ''[{"op":"replace","path":"/spec/ingress/0/ports/0/port","value":80}]''`', 'kubectl patch networkpolicy allow-client -n $NS --type json -p ''[{"op":"replace","path":"/spec/ingress/0/ports/0/port","value":80}]''
sleep 3
kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server && echo client-ok

# patch 의 path 는 JSON 경로다. 정책 전체를 다시 만들지 않고 포트 한 곳만 바꾼다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-server, labels: {app: server}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"nginx:1.25\\"}]\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-client, labels: {role: client}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]}]\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: np-other, labels: {role: other}}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers: [{name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]}]\\n---\\napiVersion: v1\\nkind: Service\\nmetadata: {name: np-server}\\nspec:\\n  selector: {app: server}\\n  ports: [{port: 80}]\\nEOF\\nkubectl wait --for=condition=Ready pod/np-server pod/np-client pod/np-other -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: networking.k8s.io/v1\\nkind: NetworkPolicy\\nmetadata: {name: deny-all}\\nspec:\\n  podSelector: {}\\n  policyTypes: [Ingress]\\nEOF\\nsleep 3\\nkubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: networking.k8s.io/v1\\nkind: NetworkPolicy\\nmetadata: {name: allow-client}\\nspec:\\n  podSelector:\\n    matchLabels: {app: server}\\n  policyTypes: [Ingress]\\n  ingress:\\n  - from:\\n    - podSelector:\\n        matchLabels: {role: client}\\n    ports:\\n    - {port: 8080}\\nEOF\\nsleep 3\\n"]', '["sh", "-c", "( [ \\"$(kubectl get networkpolicy allow-client -n $NS -o jsonpath=''{.spec.ingress[0].ports[0].port}'' 2>/dev/null)\\" = 80 ] ) && ( ( i=0; while [ $i -lt 20 ]; do kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( ( i=0; while [ $i -lt 20 ]; do kubectl exec np-other -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 || exit 0; sleep 2; i=$((i+1)); done; exit 1 ) )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "허용 포트가 80 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get networkpolicy allow-client -n $NS -o jsonpath=''{.spec.ingress[0].ports[0].port}'' 2>/dev/null)\\" = 80 ]"]}, {"label": "np-client 접속이 된다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 20 ]; do kubectl exec np-client -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "np-other 는 막혀 있다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 20 ]; do kubectl exec np-other -n $NS -- wget -q -T 3 -O /dev/null http://np-server >/dev/null 2>&1 || exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}]', '[{"title": "네트워크 정책", "url": "https://kubernetes.io/docs/concepts/services-networking/network-policies/"}]'),
  (481, 9, 'Pod 의 보안 설정을 한 번에 읽기 (jsonpath)', '**배경** — 설정이 실제로 어떻게 들어갔는지 `-o jsonpath` 로 읽어 확인합니다. Pod 수준은 `{.spec.securityContext.runAsUser}`, 컨테이너 수준은 `{.spec.containers[0].securityContext.runAsUser}` 입니다. 여러 값을 한 줄에 쓰려면 중괄호 식 사이에 글자를 넣을 수 있습니다.

**문제** — `sec-prep` Pod 의 **Pod 수준 `runAsUser`** 와 **컨테이너 수준 `runAsUser`** 를 하이픈으로 이어 한 줄로 **`/tmp/q9.txt`** 에 저장하세요. (`2000-3000`)', '`-o jsonpath=''{.spec.securityContext.runAsUser}-{.spec.containers[0].securityContext.runAsUser}''`', 'kubectl get pod sec-prep -n $NS -o jsonpath=''{.spec.securityContext.runAsUser}-{.spec.containers[0].securityContext.runAsUser}'' > /tmp/q9.txt
cat /tmp/q9.txt

# jsonpath 안에 ''-'' 같은 글자를 섞어 한 줄로 만들 수 있다', '["sh", "-c", "rm -f /tmp/*.txt; kubectl delete pod sec-user sec-ro sec-cap sa-pod sec-prep np-server np-client np-other -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete networkpolicy deny-all allow-client -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete svc np-server -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app-sa -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: sec-prep\\n  labels: {}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  securityContext:\\n    runAsUser: 2000\\n  containers:\\n  - name: c\\n    image: busybox:1.36\\n    securityContext:\\n      runAsUser: 3000\\n    command: [\\"sh\\", \\"-c\\", \\"sleep 3600\\"]\\nEOF\\nkubectl wait --for=condition=Ready pod/sec-prep -n $NS --timeout=90s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q9.txt)\\" = 2000-3000 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 2000-3000 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q9.txt)\\" = 2000-3000 ]"]}]', '[{"title": "Pod·컨테이너 보안 컨텍스트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"}]'),
  (481, 10, 'NetworkPolicy 가 없을 때', '어떤 Pod 도 선택하지 않는 상태, 즉 네임스페이스에 **NetworkPolicy 가 하나도 없을 때** Pod 로 들어오는 트래픽은 어떻게 될까요?', '"기본값" 을 떠올려 봐요.', NULL, NULL, '[]', 'choice', '["정책이 없으면 같은 네임스페이스 안에서만 허용된다", "정책이 없으면 모든 트래픽이 허용된다", "정책이 없으면 모든 수신 트래픽이 기본으로 거부된다", "정책이 없으면 Service 를 거친 트래픽만 허용된다"]', 1, '쿠버네티스 문서는 Pod 가 기본적으로 비격리(non-isolated)이며 모든 곳에서 오는 트래픽을 받는다고 설명합니다. 어떤 NetworkPolicy 가 Pod 를 선택하면 그 방향의 트래픽은 정책이 허용한 것만 통과합니다.', NULL, NULL, NULL, '[{"title": "네트워크 정책", "url": "https://kubernetes.io/docs/concepts/services-networking/network-policies/"}]'),
  (481, 11, 'root 로 실행 못하게 하기', '컨테이너가 **root(UID 0) 로 시작하는 것을 막는** `securityContext` 필드입니다. 빈칸을 채우세요.', '"root 가 아니어야 한다" 를 뜻해요.', NULL, NULL, '[]', 'fill', '["Root", "Admin", "User", "Privileged"]', NULL, '쿠버네티스 보안 컨텍스트 문서는 runAsNonRoot: true 가 컨테이너를 root 로 실행하려 하면 kubelet 이 시작을 막도록 한다고 설명합니다. 사용자 번호를 정하려면 runAsUser 를 씁니다.', '[0]', 'runAsNon{0}: true', NULL, '[{"title": "Pod·컨테이너 보안 컨텍스트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/security-context/"}]'),
  (481, 12, 'NetworkPolicy 로 접근 줄이는 순서', '열려 있는 네임스페이스에서 NetworkPolicy 로 접근을 **줄여 가는** 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '막기 → 확인 → 열기 → 확인이에요.', NULL, NULL, '[]', 'order', '["`podSelector: {}` 인 기본 거부(deny-all) 정책을 적용한다", "클라이언트 Pod 에서 접속해 막혔는지 확인한다", "라벨과 포트로 좁힌 허용 정책을 추가한다", "허용된 Pod 는 접속되고 그 밖의 Pod 는 계속 막히는지 확인한다"]', NULL, '쿠버네티스 네트워크 정책 문서의 권장 방식입니다. 기본 거부 위에 필요한 허용만 더하고 결과를 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "네트워크 정책", "url": "https://kubernetes.io/docs/concepts/services-networking/network-policies/"}]');
