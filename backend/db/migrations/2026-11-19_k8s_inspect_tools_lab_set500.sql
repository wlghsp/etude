-- Git 실습 세트 500. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_inspect_tools_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 500, 'k8s 점검·출력 도구 손연습: run --rm, QoS Guaranteed, events --for, -o name, jsonpath range, go-template, 직전 종료 코드, rollout history --revision, set env --prefix', '임시 Pod 로 클러스터 안에서 요청 보내기, Guaranteed QoS 만들기, 한 객체의 이벤트 보기, -o name·jsonpath range·go-template 출력 가공, 직전 종료 코드 확인, 개정별 이미지 조회, ConfigMap 을 접두사로 환경 변수 연결을 실습합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 500);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 1, '임시 Pod 로 클러스터 안에서 요청 보내기 (run --rm -i --restart=Never)', '**배경** — Service 가 클러스터 안에서 응답하는지 보려면 **클러스터 안의 Pod 에서** 요청해야 합니다. `kubectl run 이름 --rm -i --restart=Never --image=… -- 명령` 은 **한 번 쓰고 사라지는 임시 Pod** 를 만들어 명령을 실행하고 출력을 돌려준 뒤 **자동 삭제**합니다(`--rm`). `--restart=Never` 라야 Deployment 가 아닌 Pod 하나로 만들어집니다. Service `web`(nginx, 포트 80)이 있습니다.

**문제** — 임시 Pod(`busybox:1.36`)로 `http://web` 에 `wget -qO-` 요청을 보내 받은 페이지를 **`/tmp/q1.txt`** 에 저장하세요. (`Welcome to nginx` 가 보여야 하고 임시 Pod 는 남지 않아야 합니다.)', '`kubectl run tmp --rm -i --restart=Never --image=busybox:1.36 -- wget -qO- http://web > /tmp/q1.txt`', 'kubectl run tmp -n $NS --rm -i --restart=Never --image=busybox:1.36 -- wget -qO- http://web > /tmp/q1.txt
grep -o ''Welcome to nginx'' /tmp/q1.txt
kubectl get pod tmp -n $NS   # NotFound

# -i 가 없으면 출력을 받기 전에 끝날 수 있다. --rm 이 임시 Pod 를 지운다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl expose deployment web -n $NS --port=80 >/dev/null; kubectl rollout status deploy/web -n $NS --timeout=120s >/dev/null 2>&1; sleep 2\\n"]', '["sh", "-c", "( grep -q \\"Welcome to nginx\\" /tmp/q1.txt 2>/dev/null ) && ( ! kubectl get pod tmp -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Welcome to nginx 가 있다", "cmd": ["sh", "-c", "grep -q \\"Welcome to nginx\\" /tmp/q1.txt 2>/dev/null"]}, {"label": "임시 Pod 가 남지 않았다", "cmd": ["sh", "-c", "! kubectl get pod tmp -n $NS >/dev/null 2>&1"]}]', '[{"title": "kubectl run", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 2, 'QoS 를 Guaranteed 로 만들기 (requests = limits)', '**배경** — 노드 자원이 모자라면 쿠버네티스는 **QoS 등급**이 낮은 Pod 부터 쫓아냅니다. 모든 컨테이너에 **cpu·memory 의 requests 와 limits 가 같으면 `Guaranteed`**(마지막에 쫓김), 일부만 설정하면 `Burstable`, 아무것도 없으면 `BestEffort`(가장 먼저 쫓김)입니다. 등급은 `status.qosClass` 로 봅니다.

**문제** — Pod **`qos`**(`nginx:1.25`)를 만들되 **cpu `100m`, memory `64Mi`** 를 requests 와 limits 에 **똑같이** 주어 **`Guaranteed`** 가 되게 하세요.', 'resources 에 `requests: {cpu: 100m, memory: 64Mi}` 와 `limits: {cpu: 100m, memory: 64Mi}` 를 같은 값으로 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: qos}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: web
    image: nginx:1.25
    resources:
      requests: {cpu: 100m, memory: 64Mi}
      limits: {cpu: 100m, memory: 64Mi}
EOF
kubectl wait --for=condition=Ready pod/qos -n $NS --timeout=90s
kubectl get pod qos -n $NS -o jsonpath=''{.status.qosClass}''

# limits 만 적어도 requests 가 같은 값으로 채워져 Guaranteed 가 된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod qos -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=60s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod qos -n $NS -o jsonpath=''{.status.qosClass}'' 2>/dev/null)\\" = Guaranteed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "qosClass 가 Guaranteed 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod qos -n $NS -o jsonpath=''{.status.qosClass}'' 2>/dev/null)\\" = Guaranteed ]"]}]', '[{"title": "Pod 의 QoS 클래스", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 3, '한 객체의 이벤트만 모아 보기 (kubectl events --for)', '**배경** — `kubectl describe` 끝의 Events 는 길어서 찾기 어렵습니다. **`kubectl events --for 종류/이름`** 은 **그 객체에 대한 이벤트만** 시간순으로 보여 주고, `--types=Warning` 으로 경고만 거를 수 있습니다. Pod `app` 의 시작 이벤트가 쌓여 있습니다.

**문제** — Pod `app` 의 이벤트를 **`/tmp/q3.txt`** 에 저장하세요. (`Scheduled` 이벤트가 들어 있어야 합니다.)', '`kubectl events --for pod/app > /tmp/q3.txt`', 'kubectl events --for pod/app -n $NS > /tmp/q3.txt
cat /tmp/q3.txt

# --types=Warning 이면 경고만, -w 면 새 이벤트를 계속 보여 준다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; kubectl run app -n $NS --image=busybox:1.36 --labels=app=app -- sleep 3600 >/dev/null; kubectl wait --for=condition=Ready pod/app -n $NS --timeout=90s >/dev/null\\n"]', '["sh", "-c", "( grep -q Scheduled /tmp/q3.txt 2>/dev/null ) && ( grep -q \\"Pod/app\\" /tmp/q3.txt 2>/dev/null )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Scheduled 이벤트가 있다", "cmd": ["sh", "-c", "grep -q Scheduled /tmp/q3.txt 2>/dev/null"]}, {"label": "app 에 대한 것이다", "cmd": ["sh", "-c", "grep -q \\"Pod/app\\" /tmp/q3.txt 2>/dev/null"]}]', '[{"title": "kubectl events", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_events/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 4, '이름만 뽑아 스크립트에 넘기기 (-o name)', '**배경** — `-o name` 은 객체를 **`종류/이름`** 한 줄씩만 출력해 `xargs`·반복문에 넘기기 좋습니다. 라벨 선택자 `-l` 과 함께 쓰면 "이 라벨의 객체 목록" 을 만듭니다. 라벨 `tier=front` 인 Pod 가 3개(`a1`~`a3`) 있습니다.

**문제** — `tier=front` Pod 들의 **`종류/이름` 목록**을 **`/tmp/q4.txt`** 에 저장하세요. (`pod/a1` 처럼 3줄)', '`kubectl get pods -l tier=front -o name > /tmp/q4.txt`', 'kubectl get pods -n $NS -l tier=front -o name > /tmp/q4.txt
cat /tmp/q4.txt

# kubectl delete $(kubectl get pods -l tier=front -o name) 처럼 다른 명령에 넘긴다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; for p in a1 a2 a3; do kubectl run $p -n $NS --image=nginx:1.25 --labels=tier=front >/dev/null; done; kubectl wait --for=condition=Ready pod -l tier=front -n $NS --timeout=90s >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/q4.txt 2>/dev/null | tr -d '' '')\\" = 3 ] ) && ( [ \\"$(grep -c \\"^pod/a[123]$\\" /tmp/q4.txt 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "3줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/q4.txt 2>/dev/null | tr -d '' '')\\" = 3 ]"]}, {"label": "모두 pod/ 로 시작한다", "cmd": ["sh", "-c", "[ \\"$(grep -c \\"^pod/a[123]$\\" /tmp/q4.txt 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "kubectl 출력 형식", "url": "https://kubernetes.io/docs/reference/kubectl/#output-options"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 5, '이름과 이미지를 탭으로 나눠 뽑기 (jsonpath range)', '**배경** — JSONPath 의 **`{range .items[*]}…{end}`** 는 목록을 돌며 템플릿을 반복해 **한 줄에 필드 여러 개**를 뽑습니다. 줄바꿈은 `{"\\n"}`, 탭은 `{"\\t"}` 로 적습니다. 표 대신 스크립트가 읽기 쉬운 출력이 필요할 때 씁니다.

**문제** — 라벨 `tier=front` Pod 마다 **`이름<탭>이미지`** 한 줄씩을 **`/tmp/q5.txt`** 에 저장하세요. (예: `a1`⇥`nginx:1.25`, 3줄)', '`-o jsonpath=''{range .items[*]}{.metadata.name}{"\\t"}{.spec.containers[0].image}{"\\n"}{end}''`', 'kubectl get pods -n $NS -l tier=front -o jsonpath=''{range .items[*]}{.metadata.name}{"\\t"}{.spec.containers[0].image}{"\\n"}{end}'' > /tmp/q5.txt
cat /tmp/q5.txt

# 홑따옴표 안에서 "\\t" 와 "\\n" 은 kubectl 이 해석한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; for p in a1 a2 a3; do kubectl run $p -n $NS --image=nginx:1.25 --labels=tier=front >/dev/null; done; kubectl wait --for=condition=Ready pod -l tier=front -n $NS --timeout=90s >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/q5.txt 2>/dev/null | tr -d '' '')\\" = 3 ] ) && ( grep -qP \\"^a1\\\\tnginx:1.25$\\" /tmp/q5.txt 2>/dev/null || awk -F\\"\\\\t\\" ''$1==\\"a1\\" && $2==\\"nginx:1.25\\"{f=1} END{exit !f}'' /tmp/q5.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "3줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/q5.txt 2>/dev/null | tr -d '' '')\\" = 3 ]"]}, {"label": "a1 줄이 이름 탭 이미지다", "cmd": ["sh", "-c", "grep -qP \\"^a1\\\\tnginx:1.25$\\" /tmp/q5.txt 2>/dev/null || awk -F\\"\\\\t\\" ''$1==\\"a1\\" && $2==\\"nginx:1.25\\"{f=1} END{exit !f}'' /tmp/q5.txt"]}]', '[{"title": "JSONPath 지원", "url": "https://kubernetes.io/docs/reference/kubectl/jsonpath/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 6, 'Go 템플릿으로 이름만 한 줄씩 (--template)', '**배경** — `-o go-template` 이나 **`--template`** 은 Go 템플릿으로 출력을 만듭니다. `{{range .items}}…{{end}}` 로 반복하고 `{{.metadata.name}}` 처럼 필드를 읽습니다. jsonpath 보다 조건(`if`)·함수를 쓸 수 있어 가공이 복잡할 때 고릅니다.

**문제** — 라벨 `tier=front` Pod 의 **이름만 한 줄씩** **`/tmp/q6.txt`** 에 저장하세요. (`a1` `a2` `a3`, 접두사 없이)', '`kubectl get pods -l tier=front -o go-template=''{{range .items}}{{.metadata.name}}{{"\\n"}}{{end}}''`', 'kubectl get pods -n $NS -l tier=front -o go-template=''{{range .items}}{{.metadata.name}}{{"\\n"}}{{end}}'' > /tmp/q6.txt
cat /tmp/q6.txt

# {{"\\n"}} 이 없으면 이름이 한 줄에 붙어 나온다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; for p in a1 a2 a3; do kubectl run $p -n $NS --image=nginx:1.25 --labels=tier=front >/dev/null; done; kubectl wait --for=condition=Ready pod -l tier=front -n $NS --timeout=90s >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(sort /tmp/q6.txt 2>/dev/null | tr ''\\\\n'' '' '')\\" = \\"a1 a2 a3 \\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이름 3개가 줄마다 있다", "cmd": ["sh", "-c", "[ \\"$(sort /tmp/q6.txt 2>/dev/null | tr ''\\\\n'' '' '')\\" = \\"a1 a2 a3 \\" ]"]}]', '[{"title": "kubectl 출력 형식", "url": "https://kubernetes.io/docs/reference/kubectl/#output-options"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 7, '죽기 직전 종료 코드 확인하기 (lastState.terminated.exitCode)', '**배경** — 재시작을 반복하는 Pod 는 지금 상태가 `Waiting(CrashLoopBackOff)` 라 **왜 죽었는지** 가 보이지 않습니다. 직전 종료는 **`status.containerStatuses[].lastState.terminated`** 에 `exitCode`·`reason` 으로 남습니다. 종료 코드는 원인을 가르는 단서입니다(예: 137 = SIGKILL·메모리 초과, 1·2 = 앱 오류). Pod `crash` 가 계속 재시작합니다.

**문제** — Pod `crash` 의 **직전 종료 코드**를 **`/tmp/q7.txt`** 에 저장하세요.', '`kubectl get pod crash -o jsonpath=''{.status.containerStatuses[0].lastState.terminated.exitCode}''`', 'kubectl get pod crash -n $NS -o jsonpath=''{.status.containerStatuses[0].lastState.terminated.exitCode}'' > /tmp/q7.txt
cat /tmp/q7.txt

# lastState 는 한 번 죽은 뒤에야 채워진다. 코드를 알면 logs --previous 로 이유를 찾는다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: crash}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers:\\n  - {name: c, image: \\"busybox:1.36\\", command: [\\"sh\\", \\"-c\\", \\"exit 3\\"]}\\nEOF\\nfor i in $(seq 1 40); do [ -n \\"$(kubectl get pod crash -n $NS -o jsonpath=''{.status.containerStatuses[0].lastState.terminated.exitCode}'' 2>/dev/null)\\" ] && break; sleep 2; done\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q7.txt 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "종료 코드가 3 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q7.txt 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "Pod 수명주기 (컨테이너 상태)", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-states"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 8, '첫 배포가 쓴 이미지 찾기 (rollout history --revision)', '**배경** — `kubectl rollout history deploy/이름` 은 개정 번호만 보여 줍니다. **`--revision=N`** 을 붙이면 **그 개정의 Pod 템플릿**(이미지, 환경 변수 등)을 보여 주므로, 롤백 전에 "그때 어떤 이미지였나" 를 확인할 수 있습니다. Deployment `web` 은 개정이 2개이고 지금은 1.26 입니다.

**문제** — **개정 1** 이 사용한 이미지 이름(예: `nginx:1.25`)을 **`/tmp/q8.txt`** 에 저장하세요.', '`kubectl rollout history deploy/web --revision=1` 출력의 `Image:` 줄을 잘라요. 예: `... | grep Image: | awk ''{print $2}''`', 'kubectl rollout history deploy/web -n $NS --revision=1 | grep ''Image:'' | awk ''{print $2}'' > /tmp/q8.txt
cat /tmp/q8.txt

# 롤백 대상은 kubectl rollout undo deploy/web --to-revision=1', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null; kubectl rollout status deploy/web -n $NS --timeout=120s >/dev/null 2>&1; kubectl set image deploy/web nginx=nginx:1.26 -n $NS >/dev/null; kubectl rollout status deploy/web -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q8.txt 2>/dev/null)\\" = nginx:1.25 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "q8 이 nginx:1.25 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q8.txt 2>/dev/null)\\" = nginx:1.25 ]"]}]', '[{"title": "Deployment 롤아웃 이력", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#checking-rollout-history-of-a-deployment"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 9, 'ConfigMap 전체를 접두사 붙여 환경 변수로 (set env --from --prefix)', '**배경** — `kubectl set env 대상 --from=configmap/이름` 은 ConfigMap 의 **모든 키를 환경 변수로** 연결하고, **`--prefix=APP_`** 를 주면 변수 이름 앞에 접두사를 붙여 다른 변수와 겹치는 일을 막습니다. YAML 을 직접 고치지 않고 명령 한 줄로 설정합니다. ConfigMap `cfg`(`mode=fast`)와 Deployment `web` 이 있습니다.

**문제** — `web` 에 ConfigMap `cfg` 를 **접두사 `APP_`** 로 환경 변수 연결하세요. (키 `mode` 가 대문자로 바뀌고 접두사가 붙어 `APP_MODE` 가 생깁니다.)', '`kubectl set env deploy/web --from=configmap/cfg --prefix=APP_`', 'kubectl set env deploy/web -n $NS --from=configmap/cfg --prefix=APP_
kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env}''

# 키 mode 가 APP_MODE 로 바뀌어 configMapKeyRef 로 연결된다. 접두사가 없으면 MODE 다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod app app-copy crash a1 a2 a3 -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm cfg -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm cfg -n $NS --from-literal=mode=fast >/dev/null; kubectl create deployment web -n $NS --image=nginx:1.25 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[0].name}'' 2>/dev/null)\\" = APP_MODE ] ) && ( [ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[0].valueFrom.configMapKeyRef.key}'' 2>/dev/null)\\" = mode ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "변수 이름이 APP_MODE 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[0].name}'' 2>/dev/null)\\" = APP_MODE ]"]}, {"label": "cfg 의 mode 키를 참조한다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[0].valueFrom.configMapKeyRef.key}'' 2>/dev/null)\\" = mode ]"]}]', '[{"title": "kubectl set env", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_set/kubectl_set_env/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 10, 'Guaranteed QoS 의 조건', 'Pod 의 QoS 클래스가 **`Guaranteed`** 가 되려면 무엇이 필요할까요?', '"보장" 이라는 이름과 requests·limits 의 관계를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["컨테이너가 하나이고 limits 만 있다", "모든 컨테이너의 requests 와 limits 가 같다", "네임스페이스에 ResourceQuota 가 있다", "컨테이너에 readinessProbe 가 설정되어 있다"]', 1, 'Guaranteed 는 모든 컨테이너의 cpu·memory 에서 requests 와 limits 가 같을 때입니다(limits 만 적으면 requests 가 같은 값으로 채워지기도 합니다). 일부만 설정하면 Burstable, 없으면 BestEffort 이며 자원이 모자라면 BestEffort 부터 쫓겨납니다.', NULL, NULL, NULL, '[{"title": "Pod 의 QoS 클래스", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 11, '한 번 쓰고 사라지는 Pod', '요청만 보내고 끝나면 지워지는 임시 Pod 를 만드는 옵션입니다. 빈칸을 채우세요.', '"다시 시작하지 않음" 이에요.', NULL, NULL, '[]', 'fill', '["Never", "Always", "OnFailure", "Once"]', NULL, '--restart=Never 로 두어야 Pod 하나가 만들어지고 --rm 이 끝난 뒤 지웁니다. Always(기본)는 Deployment 로 만들려 하고, OnFailure 는 Job 에 가깝고, Once 는 없는 값입니다.', '[0]', 'kubectl run tmp --rm -i --restart={0} --image=busybox:1.36 -- wget -qO- http://web', NULL, '[{"title": "kubectl run", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 500, 12, '재시작하는 Pod 원인을 좁혀 가는 순서', '반복해서 죽는 Pod 의 원인을 좁혀 가는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → 이벤트 → 직전 종료 → 로그예요.', NULL, NULL, '[]', 'order', '["`kubectl get pod` 으로 STATUS 와 RESTARTS 를 확인한다", "`kubectl events --for pod/이름` 으로 이벤트의 경고를 본다", "`lastState.terminated.exitCode` 로 직전 종료 코드를 확인한다", "`kubectl logs --previous` 로 죽기 전 로그에서 원인을 찾는다"]', NULL, '현재 상태와 재시작 횟수를 보고, 이벤트로 스케줄·이미지·프로브 문제를 거른 다음, 종료 코드로 성격을 가르고, 직전 컨테이너 로그로 원인을 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Pod 수명주기 (컨테이너 상태)", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-states"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 500 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 258 WHERE id = 190;
UPDATE quest_set SET display_order = 259 WHERE id = 304;
UPDATE quest_set SET display_order = 260 WHERE id = 194;
UPDATE quest_set SET display_order = 261 WHERE id = 305;
UPDATE quest_set SET display_order = 262 WHERE id = 198;
UPDATE quest_set SET display_order = 263 WHERE id = 306;
UPDATE quest_set SET display_order = 264 WHERE id = 202;
UPDATE quest_set SET display_order = 265 WHERE id = 307;
UPDATE quest_set SET display_order = 266 WHERE id = 205;
UPDATE quest_set SET display_order = 267 WHERE id = 308;
UPDATE quest_set SET display_order = 268 WHERE id = 482;
UPDATE quest_set SET display_order = 269 WHERE id = 494;
UPDATE quest_set SET display_order = 271 WHERE id = 208;
UPDATE quest_set SET display_order = 272 WHERE id = 309;
UPDATE quest_set SET display_order = 273 WHERE id = 211;
UPDATE quest_set SET display_order = 274 WHERE id = 310;
UPDATE quest_set SET display_order = 275 WHERE id = 214;
UPDATE quest_set SET display_order = 276 WHERE id = 311;
UPDATE quest_set SET display_order = 277 WHERE id = 217;
UPDATE quest_set SET display_order = 278 WHERE id = 312;
UPDATE quest_set SET display_order = 279 WHERE id = 220;
UPDATE quest_set SET display_order = 280 WHERE id = 313;
UPDATE quest_set SET display_order = 281 WHERE id = 483;
UPDATE quest_set SET display_order = 282 WHERE id = 493;
UPDATE quest_set SET display_order = 283 WHERE id = 496;
UPDATE quest_set SET display_order = 284 WHERE id = 223;
UPDATE quest_set SET display_order = 285 WHERE id = 314;
UPDATE quest_set SET display_order = 286 WHERE id = 12;
UPDATE quest_set SET display_order = 287 WHERE id = 22;
UPDATE quest_set SET display_order = 288 WHERE id = 236;
UPDATE quest_set SET display_order = 289 WHERE id = 351;
UPDATE quest_set SET display_order = 290 WHERE id = 375;
UPDATE quest_set SET display_order = 291 WHERE id = 383;
UPDATE quest_set SET display_order = 292 WHERE id = 420;
UPDATE quest_set SET display_order = 293 WHERE id = 421;
UPDATE quest_set SET display_order = 293 WHERE id = 499;
UPDATE quest_set SET display_order = 297 WHERE id = 80;
UPDATE quest_set SET display_order = 298 WHERE id = 13;
UPDATE quest_set SET display_order = 299 WHERE id = 122;
UPDATE quest_set SET display_order = 300 WHERE id = 25;
UPDATE quest_set SET display_order = 301 WHERE id = 108;
UPDATE quest_set SET display_order = 302 WHERE id = 37;
UPDATE quest_set SET display_order = 303 WHERE id = 26;
UPDATE quest_set SET display_order = 304 WHERE id = 348;
UPDATE quest_set SET display_order = 305 WHERE id = 422;
UPDATE quest_set SET display_order = 306 WHERE id = 489;
UPDATE quest_set SET display_order = 308 WHERE id = 23;
UPDATE quest_set SET display_order = 309 WHERE id = 31;
UPDATE quest_set SET display_order = 310 WHERE id = 29;
UPDATE quest_set SET display_order = 311 WHERE id = 227;
UPDATE quest_set SET display_order = 312 WHERE id = 230;
UPDATE quest_set SET display_order = 313 WHERE id = 233;
UPDATE quest_set SET display_order = 314 WHERE id = 339;
UPDATE quest_set SET display_order = 315 WHERE id = 345;
UPDATE quest_set SET display_order = 316 WHERE id = 423;
UPDATE quest_set SET display_order = 317 WHERE id = 425;
UPDATE quest_set SET display_order = 318 WHERE id = 119;
UPDATE quest_set SET display_order = 319 WHERE id = 120;
UPDATE quest_set SET display_order = 320 WHERE id = 121;
UPDATE quest_set SET display_order = 321 WHERE id = 424;
UPDATE quest_set SET display_order = 322 WHERE id = 14;
UPDATE quest_set SET display_order = 256, unit_id = (SELECT id FROM unit WHERE id = 62), icon = '🔭' WHERE id = 500;
