-- Git 실습 세트 492. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_apply_delete_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 492, 'k8s 적용·삭제 방식 손연습: apply·server-side, --cascade=orphan, --field-selector 삭제, --now, auth can-i, api-resources, set serviceaccount, finalizer', 'apply 로 선언형 갱신, --server-side 와 field-manager, 삭제할 때 --cascade=orphan, 상태(--field-selector)로 골라 삭제, 신호 무시 Pod 를 --now 로 지우기, auth can-i 로 권한 묻기, api-resources 로 자원 종류 읽기, set serviceaccount, Terminating 에서 멈춘 오브젝트의 finalizer 풀기를 실습합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 492);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 1, '파일을 고쳐 다시 적용하기 (apply)', '**배경** — `kubectl apply -f 파일` 은 **선언형**입니다. 없으면 만들고, 있으면 파일과 달라진 부분만 고칩니다. 반면 `kubectl create -f` 는 이미 있으면 `AlreadyExists` 오류로 실패합니다. `/tmp/lab/web.yaml`(Deployment `web`, replicas 2)을 이미 적용해 두었습니다.

**문제** — 파일의 `replicas` 를 **3** 으로 고쳐 다시 **`apply`** 하세요. (`web` 이 3개가 되어야 합니다.)', '`sed -i` 로 `replicas: 3` 으로 고친 뒤 `kubectl apply -f /tmp/lab/web.yaml`', 'sed -i ''s/replicas: 2/replicas: 3/'' /tmp/lab/web.yaml
kubectl apply -f /tmp/lab/web.yaml -n $NS
kubectl get deploy web -n $NS

# create 는 있는 것을 또 만들 수 없지만 apply 는 차이만 반영한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; cat > /tmp/lab/web.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata: {name: web}\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels: {app: web}\\n  template:\\n    metadata:\\n      labels: {app: web}\\n    spec:\\n      containers:\\n      - {name: nginx, image: \\"nginx:1.25\\"}\\nEOF\\nkubectl apply -f /tmp/lab/web.yaml -n $NS >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "replicas 가 3 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "선언형 오브젝트 관리 (apply)", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 2, '필드 관리자 이름 붙여 서버 쪽 적용하기 (apply --server-side)', '**배경** — **Server-Side Apply**(`--server-side`)는 병합을 **API 서버**가 하고, 각 필드를 **누가 관리하는지**(`managedFields` 의 `manager`)를 기록합니다. 여러 도구가 같은 오브젝트를 고칠 때 충돌을 알려 줍니다. `--field-manager=이름` 으로 관리자 이름을 정합니다. `/tmp/lab/web.yaml` 이 있습니다(아직 적용 전).

**문제** — `web.yaml` 을 **server-side 로, 관리자 이름 `trainer`** 로 적용하세요.', '`kubectl apply --server-side --field-manager=trainer -f /tmp/lab/web.yaml`', 'kubectl apply --server-side --field-manager=trainer -f /tmp/lab/web.yaml -n $NS
kubectl get deploy web -n $NS -o jsonpath=''{.metadata.managedFields[*].manager}''

# 필드 소유자가 trainer 로 기록된다. 다른 관리자와 겹치면 충돌 오류', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; cat > /tmp/lab/web.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata: {name: web}\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels: {app: web}\\n  template:\\n    metadata:\\n      labels: {app: web}\\n    spec:\\n      containers:\\n      - {name: nginx, image: \\"nginx:1.25\\"}\\nEOF\\n"]', '["sh", "-c", "( kubectl get deploy web -n $NS >/dev/null 2>&1 ) && ( kubectl get deploy web -n $NS -o jsonpath=''{.metadata.managedFields[*].manager}'' 2>/dev/null | grep -q trainer )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web 이 있다", "cmd": ["sh", "-c", "kubectl get deploy web -n $NS >/dev/null 2>&1"]}, {"label": "관리자에 trainer 가 있다", "cmd": ["sh", "-c", "kubectl get deploy web -n $NS -o jsonpath=''{.metadata.managedFields[*].manager}'' 2>/dev/null | grep -q trainer"]}]', '[{"title": "Server-Side Apply", "url": "https://kubernetes.io/docs/reference/using-api/server-side-apply/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 3, 'Deployment 만 지우고 Pod 는 남기기 (--cascade=orphan)', '**배경** — Deployment 를 지우면 기본적으로 ReplicaSet·Pod 도 **함께** 지워집니다(가비지 컬렉션). **`--cascade=orphan`** 은 **주인만 지우고 종속 오브젝트는 고아로 남깁니다**. 컨트롤러를 바꾸거나 이전할 때 Pod 를 끊지 않으려고 씁니다. Deployment `web`(Pod 2개)이 떠 있습니다.

**문제** — `web` Deployment 를 **삭제하되 ReplicaSet 과 Pod 는 남기세요.**', '`kubectl delete deployment web --cascade=orphan`', 'kubectl delete deployment web -n $NS --cascade=orphan
kubectl get deploy,rs,pod -n $NS -l app=web

# Deployment 는 사라지고 RS·Pod 는 그대로 남는다 (주인 없음)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/web -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( ! kubectl get deploy web -n $NS >/dev/null 2>&1 ) && ( [ \\"$(kubectl get rs -n $NS -l app=web -o name 2>/dev/null | wc -l)\\" -ge 1 ] ) && ( [ \\"$(kubectl get pod -n $NS -l app=web -o name 2>/dev/null | wc -l)\\" -eq 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Deployment 는 없다", "cmd": ["sh", "-c", "! kubectl get deploy web -n $NS >/dev/null 2>&1"]}, {"label": "ReplicaSet 이 남았다", "cmd": ["sh", "-c", "[ \\"$(kubectl get rs -n $NS -l app=web -o name 2>/dev/null | wc -l)\\" -ge 1 ]"]}, {"label": "Pod 가 2개 남았다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod -n $NS -l app=web -o name 2>/dev/null | wc -l)\\" -eq 2 ]"]}]', '[{"title": "가비지 컬렉션과 cascade", "url": "https://kubernetes.io/docs/concepts/architecture/garbage-collection/"}, {"title": "kubectl delete", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_delete/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 4, '끝난 Pod 만 골라 지우기 (--field-selector)', '**배경** — `kubectl delete` 도 `--field-selector` 로 **상태를 조건**으로 걸 수 있습니다. `status.phase=Succeeded` 는 정상 종료한 Pod, `Failed` 는 실패한 Pod 입니다. 쌓인 완료 Pod 를 정리할 때 씁니다. Pod `done1` 은 이미 끝났고(`Succeeded`), `run1` 은 실행 중입니다.

**문제** — **정상 종료(`Succeeded`)한 Pod 만** 삭제하세요. (`run1` 은 남아야 합니다.)', '`kubectl delete pods --field-selector=status.phase=Succeeded`', 'kubectl delete pods -n $NS --field-selector=status.phase=Succeeded
kubectl get pods -n $NS

# 이름이 아니라 상태로 골라 지운다. 라벨 셀렉터(-l)와 함께 쓸 수도 있다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl run done1 -n $NS --image=busybox:1.36 --restart=Never -- true >/dev/null; kubectl run run1 -n $NS --image=busybox:1.36 --restart=Never -- sleep 3600 >/dev/null; kubectl wait --for=jsonpath=''{.status.phase}''=Succeeded pod/done1 -n $NS --timeout=90s >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/run1 -n $NS --timeout=90s >/dev/null 2>&1\\n"]', '["sh", "-c", "( ! kubectl get pod done1 -n $NS >/dev/null 2>&1 ) && ( kubectl get pod run1 -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "done1 은 없다", "cmd": ["sh", "-c", "! kubectl get pod done1 -n $NS >/dev/null 2>&1"]}, {"label": "run1 은 남았다", "cmd": ["sh", "-c", "kubectl get pod run1 -n $NS >/dev/null 2>&1"]}]', '[{"title": "kubectl delete", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_delete/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 5, '종료 신호를 무시하는 Pod 바로 지우기 (--now)', '**배경** — Pod 를 지우면 `SIGTERM` 을 보내고 `terminationGracePeriodSeconds`(기본 30초) 동안 기다린 뒤 `SIGKILL` 합니다. 신호를 무시하는 앱이나 유예가 긴 Pod 는 한참 `Terminating` 에 머뭅니다. **`--now`**(유예 1초) 또는 `--grace-period=0 --force` 로 **서둘러** 지울 수 있습니다. Pod `slow` 는 `SIGTERM` 을 무시하고 유예 시간이 **300초**입니다.

**문제** — `slow` 를 **기다리지 않고 바로** 삭제하세요. (명령이 끝났을 때 Pod 가 없어야 합니다.)', '`kubectl delete pod slow --now`', 'kubectl delete pod slow -n $NS --now
kubectl get pod slow -n $NS

# --now 는 grace period 1초. --force 는 API 오브젝트만 즉시 지우므로 컨테이너가 남을 수 있어 조심한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: slow}\\nspec:\\n  terminationGracePeriodSeconds: 300\\n  containers:\\n  - name: c\\n    image: busybox:1.36\\n    command: [\\"sh\\", \\"-c\\", \\"trap '''' TERM; while true; do sleep 1; done\\"]\\nEOF\\nkubectl wait --for=condition=Ready pod/slow -n $NS --timeout=90s >/dev/null 2>&1\\n"]', '["sh", "-c", "( ! kubectl get pod slow -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "slow 가 없다", "cmd": ["sh", "-c", "! kubectl get pod slow -n $NS >/dev/null 2>&1"]}]', '[{"title": "kubectl delete", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_delete/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 6, '내가 할 수 있는지 먼저 물어보기 (auth can-i)', '**배경** — `kubectl auth can-i 동사 자원` 은 **지금 내 권한으로 그 일이 허용되는지** `yes`/`no` 로 알려 줍니다. 권한 오류(`Forbidden`)를 만나기 전에 확인할 때 씁니다. 이 실습 계정은 자기 네임스페이스에서는 대부분 되지만 **노드 같은 클러스터 자원은 지울 수 없습니다**.

**문제** — 두 질문의 답을 **`/tmp/q6.txt`** 에 **두 줄**로 저장하세요. 첫 줄은 **Pod 만들기** 가능 여부, 둘째 줄은 **노드 삭제** 가능 여부입니다. (`yes`, `no`)', '`kubectl auth can-i create pods > /tmp/q6.txt` 와 `kubectl auth can-i delete nodes >> /tmp/q6.txt`', 'kubectl auth can-i create pods -n $NS > /tmp/q6.txt
kubectl auth can-i delete nodes >> /tmp/q6.txt
cat /tmp/q6.txt

# 허용이면 yes(종료 코드 0), 아니면 no(종료 코드 1)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(sed -n 1p /tmp/q6.txt 2>/dev/null)\\" = yes ] ) && ( [ \\"$(sed -n 2p /tmp/q6.txt 2>/dev/null)\\" = no ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "첫 줄이 yes 다", "cmd": ["sh", "-c", "[ \\"$(sed -n 1p /tmp/q6.txt 2>/dev/null)\\" = yes ]"]}, {"label": "둘째 줄이 no 다", "cmd": ["sh", "-c", "[ \\"$(sed -n 2p /tmp/q6.txt 2>/dev/null)\\" = no ]"]}]', '[{"title": "kubectl auth can-i", "url": "https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 7, '네임스페이스에 속하는 자원 종류 나열하기 (api-resources)', '**배경** — `kubectl api-resources` 는 이 클러스터가 **지원하는 자원 종류**를 나열합니다. `--namespaced=true` 는 네임스페이스 안에 만드는 것(Pod·Deployment)만, `false` 는 클러스터 전체 자원(Node·PersistentVolume)만 보여 줍니다. `-o name` 은 이름만 출력합니다.

**문제** — **네임스페이스에 속하는** 자원 종류의 이름만 **`/tmp/q7.txt`** 에 저장하세요. (`deployments.apps` 는 있고 `nodes` 는 없어야 합니다.)', '`kubectl api-resources --namespaced=true -o name > /tmp/q7.txt`', 'kubectl api-resources --namespaced=true -o name > /tmp/q7.txt
grep -E ''deployments|nodes'' /tmp/q7.txt

# nodes 는 클러스터 범위라 --namespaced=false 쪽에 나온다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( grep -qx deployments.apps /tmp/q7.txt 2>/dev/null ) && ( ! grep -qx nodes /tmp/q7.txt 2>/dev/null )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "deployments.apps 가 있다", "cmd": ["sh", "-c", "grep -qx deployments.apps /tmp/q7.txt 2>/dev/null"]}, {"label": "nodes 는 없다", "cmd": ["sh", "-c", "! grep -qx nodes /tmp/q7.txt 2>/dev/null"]}]', '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 8, 'Deployment 의 서비스 어카운트 바꾸기 (set serviceaccount)', '**배경** — `kubectl set serviceaccount 대상 이름` 은 Deployment 같은 워크로드의 **Pod 템플릿**에 서비스 어카운트를 지정합니다. Pod 템플릿이 바뀌므로 롤링 업데이트가 일어납니다. 서비스 어카운트 `robot` 과 Deployment `web` 이 있습니다.

**문제** — Deployment `web` 이 서비스 어카운트 **`robot`** 을 쓰게 하세요.', '`kubectl set serviceaccount deployment web robot`', 'kubectl set serviceaccount deployment web robot -n $NS
kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.serviceAccountName}''

# 새 Pod 부터 robot 의 신원으로 API 에 접근한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create deployment web -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/web -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl create sa robot -n $NS >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.serviceAccountName}'' 2>/dev/null)\\" = robot ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "템플릿의 서비스 어카운트가 robot 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.serviceAccountName}'' 2>/dev/null)\\" = robot ]"]}]', '[{"title": "서비스 어카운트 설정", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 9, '지워지지 않고 Terminating 인 오브젝트 풀기 (finalizer)', '**배경** — 오브젝트에 **`finalizers`** 가 남아 있으면 삭제 요청 뒤에도 **`deletionTimestamp` 만 찍힌 채** 지워지지 않고, 담당 컨트롤러가 정리를 끝내고 finalizer 를 빼 줄 때까지 기다립니다. 담당자가 없을 때는 사람이 **원인을 확인한 뒤** finalizer 를 비워 풀어 줄 수 있습니다. ConfigMap `stuck` 에 finalizer 가 걸려 삭제가 멈춰 있습니다.

**문제** — `stuck` 이 **완전히 사라지도록** finalizer 를 비우세요.', '`kubectl patch cm stuck --type=merge -p ''{"metadata":{"finalizers":null}}''`', 'kubectl get cm stuck -n $NS -o jsonpath=''{.metadata.finalizers}{"\\n"}{.metadata.deletionTimestamp}{"\\n"}''
kubectl patch cm stuck -n $NS --type=merge -p ''{"metadata":{"finalizers":null}}''
kubectl get cm stuck -n $NS

# finalizer 를 억지로 비우면 정리 작업을 건너뛰므로 원인(담당 컨트롤러)을 먼저 확인한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete rs,pod -l app=web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod done1 run1 slow -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm stuck -n $NS --ignore-not-found --wait=false >/dev/null 2>&1; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":null}}'' >/dev/null 2>&1; kubectl delete sa robot -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cm stuck -n $NS --from-literal=a=1 >/dev/null; kubectl patch cm stuck -n $NS --type=merge -p ''{\\"metadata\\":{\\"finalizers\\":[\\"example.com/hold\\"]}}'' >/dev/null; kubectl delete cm stuck -n $NS --wait=false >/dev/null\\n"]', '["sh", "-c", "( ! kubectl get cm stuck -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "stuck 이 사라졌다", "cmd": ["sh", "-c", "! kubectl get cm stuck -n $NS >/dev/null 2>&1"]}]', '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 10, '--cascade=orphan 의 효과', '`kubectl delete deployment web --cascade=orphan` 을 실행하면 무엇이 남을까요?', '"고아" 가 된다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["Deployment 와 Pod 가 모두 지워지고 ReplicaSet 만 남는다", "Deployment 만 지워지고 ReplicaSet·Pod 는 남는다", "Pod 만 지워지고 Deployment 는 남는다", "삭제가 취소되어 아무것도 지워지지 않는다"]', 1, 'orphan 은 종속 오브젝트(ReplicaSet·Pod)를 지우지 않고 주인 참조만 끊습니다. 기본값(background)은 주인을 지운 뒤 종속 오브젝트를 가비지 컬렉션이 지웁니다.', NULL, NULL, NULL, '[{"title": "가비지 컬렉션과 cascade", "url": "https://kubernetes.io/docs/concepts/architecture/garbage-collection/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 11, '종속 오브젝트를 남기며 삭제', 'Deployment 를 지우되 Pod 는 남기는 옵션입니다. 빈칸을 채우세요.', '"고아" 의 영어예요.', NULL, NULL, '[]', 'fill', '["orphan", "background", "foreground", "none"]', NULL, '--cascade=orphan 은 종속 오브젝트를 남깁니다. background(기본)는 주인을 먼저 지우고 나중에 종속을 지우고, foreground 는 종속을 먼저 지운 뒤 주인을 지웁니다.', '[0]', 'kubectl delete deployment web --cascade={0}', NULL, '[{"title": "가비지 컬렉션과 cascade", "url": "https://kubernetes.io/docs/concepts/architecture/garbage-collection/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 492, 12, 'Terminating 에서 멈춘 오브젝트 다루는 순서', '삭제했는데 계속 Terminating 인 오브젝트를 다루는 일반적인 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 원인 → 풀기 → 확인이에요.', NULL, NULL, '[]', 'order', '["`kubectl get -o yaml` 로 `deletionTimestamp` 와 `finalizers` 를 확인한다", "finalizer 를 담당하는 컨트롤러가 왜 끝내지 못하는지 확인한다", "담당자가 없거나 정리가 불필요하면 `patch` 로 finalizers 를 비운다", "오브젝트가 사라졌는지 `kubectl get` 으로 확인한다"]', NULL, 'finalizer 는 정리 작업이 끝나야 지워지게 하는 장치입니다. 먼저 상태와 담당자를 확인하고, 정말 필요할 때만 비운 뒤 결과를 확인합니다. 무작정 비우면 외부 리소스가 남을 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 492 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 254 WHERE id = 190;
UPDATE quest_set SET display_order = 255 WHERE id = 304;
UPDATE quest_set SET display_order = 256 WHERE id = 194;
UPDATE quest_set SET display_order = 257 WHERE id = 305;
UPDATE quest_set SET display_order = 258 WHERE id = 198;
UPDATE quest_set SET display_order = 259 WHERE id = 306;
UPDATE quest_set SET display_order = 260 WHERE id = 202;
UPDATE quest_set SET display_order = 261 WHERE id = 307;
UPDATE quest_set SET display_order = 262 WHERE id = 205;
UPDATE quest_set SET display_order = 263 WHERE id = 308;
UPDATE quest_set SET display_order = 264 WHERE id = 482;
UPDATE quest_set SET display_order = 265 WHERE id = 208;
UPDATE quest_set SET display_order = 266 WHERE id = 309;
UPDATE quest_set SET display_order = 267 WHERE id = 211;
UPDATE quest_set SET display_order = 268 WHERE id = 310;
UPDATE quest_set SET display_order = 269 WHERE id = 214;
UPDATE quest_set SET display_order = 270 WHERE id = 311;
UPDATE quest_set SET display_order = 271 WHERE id = 217;
UPDATE quest_set SET display_order = 272 WHERE id = 312;
UPDATE quest_set SET display_order = 273 WHERE id = 220;
UPDATE quest_set SET display_order = 274 WHERE id = 313;
UPDATE quest_set SET display_order = 275 WHERE id = 483;
UPDATE quest_set SET display_order = 276 WHERE id = 223;
UPDATE quest_set SET display_order = 277 WHERE id = 314;
UPDATE quest_set SET display_order = 278 WHERE id = 12;
UPDATE quest_set SET display_order = 279 WHERE id = 22;
UPDATE quest_set SET display_order = 280 WHERE id = 236;
UPDATE quest_set SET display_order = 281 WHERE id = 351;
UPDATE quest_set SET display_order = 282 WHERE id = 375;
UPDATE quest_set SET display_order = 283 WHERE id = 383;
UPDATE quest_set SET display_order = 284 WHERE id = 420;
UPDATE quest_set SET display_order = 285 WHERE id = 421;
UPDATE quest_set SET display_order = 288 WHERE id = 80;
UPDATE quest_set SET display_order = 289 WHERE id = 13;
UPDATE quest_set SET display_order = 290 WHERE id = 122;
UPDATE quest_set SET display_order = 291 WHERE id = 25;
UPDATE quest_set SET display_order = 292 WHERE id = 108;
UPDATE quest_set SET display_order = 293 WHERE id = 37;
UPDATE quest_set SET display_order = 294 WHERE id = 26;
UPDATE quest_set SET display_order = 295 WHERE id = 348;
UPDATE quest_set SET display_order = 296 WHERE id = 422;
UPDATE quest_set SET display_order = 297 WHERE id = 489;
UPDATE quest_set SET display_order = 299 WHERE id = 23;
UPDATE quest_set SET display_order = 300 WHERE id = 31;
UPDATE quest_set SET display_order = 301 WHERE id = 29;
UPDATE quest_set SET display_order = 302 WHERE id = 227;
UPDATE quest_set SET display_order = 303 WHERE id = 230;
UPDATE quest_set SET display_order = 304 WHERE id = 233;
UPDATE quest_set SET display_order = 305 WHERE id = 339;
UPDATE quest_set SET display_order = 306 WHERE id = 345;
UPDATE quest_set SET display_order = 307 WHERE id = 423;
UPDATE quest_set SET display_order = 308 WHERE id = 425;
UPDATE quest_set SET display_order = 309 WHERE id = 119;
UPDATE quest_set SET display_order = 310 WHERE id = 120;
UPDATE quest_set SET display_order = 311 WHERE id = 121;
UPDATE quest_set SET display_order = 312 WHERE id = 424;
UPDATE quest_set SET display_order = 313 WHERE id = 14;
UPDATE quest_set SET display_order = 253, unit_id = (SELECT id FROM unit WHERE id = 62), icon = '🗑️' WHERE id = 492;
