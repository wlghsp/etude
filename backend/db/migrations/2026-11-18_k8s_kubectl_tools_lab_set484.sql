-- Git 실습 세트 484. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_kubectl_tools_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 484, 'k8s kubectl 편집·점검 도구 손연습: patch(strategic·json), edit·KUBE_EDITOR, set env, annotate --overwrite, diff, cp, wait, explain', 'YAML 을 통째로 다시 쓰지 않고 바꾸고 확인하는 kubectl 도구를 익힙니다. patch 의 전략적 병합과 JSON Patch, KUBE_EDITOR 로 edit 자동화, set env, annotate --overwrite, diff 로 적용 전 비교, cp 로 Pod 파일 꺼내기, wait 로 Ready 기다리기, explain 으로 필드 찾기를 실습합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 484);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 1, '값 하나만 고치기 (kubectl patch)', '**배경** — `kubectl patch` 는 오브젝트의 **일부만** JSON/YAML 조각으로 고칩니다. 기본(`--type strategic`)은 **전략적 병합**이라 컨테이너처럼 목록 안의 항목을 `name` 으로 짝지어 합칩니다. Deployment `tool`(컨테이너 이름 `nginx`, 이미지 `nginx:1.25`)이 떠 있습니다.

**문제** — `kubectl patch` 로 `tool` 의 컨테이너 `nginx` 의 **이미지를 `nginx:1.26`** 으로 바꾸세요.', '`kubectl patch deployment tool -p ''{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.26"}]}}}}''`', 'kubectl patch deployment tool -n $NS -p ''{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.26"}]}}}}''
kubectl get deploy tool -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}''

# strategic 병합은 containers 목록에서 name 이 같은 항목만 골라 image 를 바꾼다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.26 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지가 nginx:1.26 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.26 ]"]}]', '[{"title": "kubectl patch 로 오브젝트 갱신하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 2, '경로를 지정해 고치기 (patch --type json)', '**배경** — `--type json` 은 **JSON Patch** 를 씁니다. `{"op": "replace", "path": "/spec/replicas", "value": 5}` 처럼 **무엇을(op) 어디에(path) 어떤 값으로** 바꿀지 정확히 지정합니다. 목록 안 항목은 이름이 아니라 **번호**(`/containers/0`)로 가리킵니다.

**문제** — Deployment `tool` 의 `replicas` 를 JSON Patch 로 **5** 로 바꾸세요.', '`kubectl patch deployment tool --type json -p ''[{"op":"replace","path":"/spec/replicas","value":5}]''`', 'kubectl patch deployment tool -n $NS --type json -p ''[{"op":"replace","path":"/spec/replicas","value":5}]''
kubectl get deploy tool -n $NS

# json patch 는 op·path·value 를 모두 적는다. replace 는 있는 값을 바꾼다 (없으면 add)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 5 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "replicas 가 5 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 5 ]"]}]', '[{"title": "kubectl patch 로 오브젝트 갱신하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 3, '편집기로 열지 않고 편집하기 (KUBE_EDITOR)', '**배경** — `kubectl edit` 는 오브젝트를 **편집기로 열어** 저장하면 적용합니다. 편집기는 환경 변수 `KUBE_EDITOR`(없으면 `EDITOR`)가 정합니다. 스크립트에서는 편집기 자리에 **`sed` 명령**을 넣어 대화형 없이 고칠 수 있습니다. (편집기는 임시 파일 경로를 마지막 인자로 받습니다.)

**문제** — `KUBE_EDITOR` 를 `sed` 명령으로 지정해 `kubectl edit deployment tool` 로 `replicas: 2` 를 **`replicas: 4`** 로 바꾸세요.', '`KUBE_EDITOR="sed -i ''s/replicas: 2/replicas: 4/''" kubectl edit deployment tool`', 'KUBE_EDITOR="sed -i ''s/replicas: 2/replicas: 4/''" kubectl edit deployment tool -n $NS
kubectl get deploy tool -n $NS

# 편집기 인자 끝에 임시 파일 경로가 붙는다. sed -i 가 그 파일을 고치면 저장한 것으로 본다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 4 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "replicas 가 4 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 4 ]"]}]', '[{"title": "kubectl 레퍼런스", "url": "https://kubernetes.io/docs/reference/kubectl/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 4, '환경 변수 바로 넣기 (kubectl set env)', '**배경** — `kubectl set env 대상 이름=값` 은 YAML 을 열지 않고 컨테이너의 **환경 변수를 추가·변경**합니다. Pod 템플릿이 바뀌므로 Deployment 는 롤링 업데이트됩니다. 변수 삭제는 `이름-` 형식입니다.

**문제** — Deployment `tool` 에 환경 변수 **`MODE=prod`** 를 넣으세요.', '`kubectl set env deployment/tool MODE=prod`', 'kubectl set env deployment/tool MODE=prod -n $NS
kubectl set env deployment/tool --list -n $NS

# set env 는 Pod 템플릿을 바꾸므로 새 Pod 로 롤아웃된다. --list 로 확인, MODE- 로 삭제', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[?(@.name==\\"MODE\\")].value}'' 2>/dev/null)\\" = prod ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "MODE 가 prod 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[?(@.name==\\"MODE\\")].value}'' 2>/dev/null)\\" = prod ]"]}]', '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 5, '이미 있는 주석 덮어쓰기 (annotate --overwrite)', '**배경** — `kubectl annotate 대상 키=값` 은 **주석**을 붙입니다. 이미 있는 키를 바꾸려면 **`--overwrite`** 가 필요하고, 없이 쓰면 오류가 납니다(실수로 덮어쓰는 것을 막는 안전장치). Deployment `tool` 에는 `owner=team-a` 주석이 있습니다.

**문제** — `owner` 주석을 **`team-b`** 로 바꾸세요.', '`kubectl annotate deployment tool owner=team-b --overwrite`', 'kubectl annotate deployment tool owner=team-b --overwrite -n $NS
kubectl get deploy tool -n $NS -o jsonpath=''{.metadata.annotations.owner}''

# --overwrite 없이는 ''already has a value'' 오류. 주석 삭제는 owner- 로 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl annotate deployment tool owner=team-a -n $NS >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.metadata.annotations.owner}'' 2>/dev/null)\\" = team-b ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "owner 가 team-b 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.metadata.annotations.owner}'' 2>/dev/null)\\" = team-b ]"]}]', '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 6, '적용 전에 바뀔 내용 미리 보기 (kubectl diff)', '**배경** — `kubectl diff -f 파일` 은 파일을 적용했을 때 **클러스터가 어떻게 바뀔지 비교만** 보여 줍니다(적용하지 않습니다). 차이가 있으면 종료 코드가 `1` 입니다. 변경을 반영하기 전에 확인하는 습관입니다. 지금 `tool`(replicas 2)이 떠 있고, `/tmp/lab/new.yaml` 은 replicas 를 3 으로 바꾼 같은 Deployment 입니다.

**문제** — `new.yaml` 을 적용하면 무엇이 바뀌는지 **`/tmp/q6.txt`** 에 저장하세요. (적용은 하지 마세요. `replicas` 는 여전히 2 여야 합니다.)', '`kubectl diff -f /tmp/lab/new.yaml > /tmp/q6.txt` (차이가 있으면 종료 코드 1 은 정상이에요)', 'kubectl diff -f /tmp/lab/new.yaml -n $NS > /tmp/q6.txt
cat /tmp/q6.txt
kubectl get deploy tool -n $NS

# diff 는 클러스터를 바꾸지 않는다. +/- 줄로 replicas 변화가 보인다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment tool -n $NS --image=nginx:1.25 --replicas=2 >/dev/null; kubectl rollout status deployment/tool -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl get deployment tool -n $NS -o yaml | sed ''s/replicas: 2/replicas: 3/'' | grep -v -E ''^\\\\s+(uid|resourceVersion|creationTimestamp|generation):'' > /tmp/lab/new.yaml\\n"]', '["sh", "-c", "( grep -q \\"replicas: 3\\" /tmp/q6.txt ) && ( [ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "diff 결과에 replicas 변화가 있다", "cmd": ["sh", "-c", "grep -q \\"replicas: 3\\" /tmp/q6.txt"]}, {"label": "클러스터 replicas 는 그대로 2 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy tool -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 2 ]"]}]', '[{"title": "kubectl 레퍼런스", "url": "https://kubernetes.io/docs/reference/kubectl/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 7, 'Pod 안의 파일 꺼내 오기 (kubectl cp)', '**배경** — `kubectl cp 네임스페이스/Pod:경로 내려받을경로` 는 **Pod 안의 파일을 내 쪽으로**(또는 반대로) 복사합니다. Pod 안에 `tar` 가 있어야 동작합니다. Pod **`tool-pod`** 안의 `/tmp/data.txt` 에 `secret-data` 가 들어 있습니다.

**문제** — `tool-pod` 의 `/tmp/data.txt` 를 **`/tmp/q7.txt`** 로 복사해 오세요.', '`kubectl cp tool-pod:/tmp/data.txt /tmp/q7.txt` (현재 네임스페이스 기준이라 `-n $NS` 를 붙여요)', 'kubectl cp $NS/tool-pod:/tmp/data.txt /tmp/q7.txt
cat /tmp/q7.txt

# 형식은 [네임스페이스/]Pod:경로. 컨테이너가 여러 개면 -c 로 고른다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl run tool-pod -n $NS --image=busybox:1.36 --restart=Never -- sh -c ''echo secret-data > /tmp/data.txt; sleep 3600'' >/dev/null; kubectl wait --for=condition=Ready pod/tool-pod -n $NS --timeout=90s >/dev/null 2>&1; sleep 1\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q7.txt)\\" = secret-data ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "내용이 secret-data 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q7.txt)\\" = secret-data ]"]}]', '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 8, '준비될 때까지 기다리기 (kubectl wait)', '**배경** — `kubectl wait --for=조건 대상 --timeout=시간` 은 **조건이 될 때까지 막혔다가** 성공하면 0 으로 끝납니다. 배포 직후 "준비됐는지" 를 스크립트가 기다릴 때 씁니다. Pod 의 준비는 `--for=condition=Ready` 입니다. Pod **`slowpod`** 는 시작 후 약 10초가 지나야 준비(Ready)됩니다.

**문제** — `slowpod` 가 **Ready 가 될 때까지 기다린 뒤**, 기다림이 성공했을 때만 **`/tmp/q8.txt`** 에 `ready` 를 쓰세요. (`&&` 로 이으세요. 최대 60초 기다립니다.)', '`kubectl wait --for=condition=Ready pod/slowpod --timeout=60s && echo ready > /tmp/q8.txt`', 'kubectl wait --for=condition=Ready pod/slowpod -n $NS --timeout=60s && echo ready > /tmp/q8.txt
cat /tmp/q8.txt

# wait 는 조건이 충족되면 0, 시간이 지나면 1. && 로 이으면 성공했을 때만 다음 일을 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: slowpod\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers:\\n  - name: c\\n    image: busybox:1.36\\n    command: [\\"sh\\", \\"-c\\", \\"sleep 10; touch /tmp/ok; sleep 3600\\"]\\n    readinessProbe:\\n      exec: {command: [\\"test\\", \\"-f\\", \\"/tmp/ok\\"]}\\n      periodSeconds: 2\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q8.txt)\\" = ready ] ) && ( [ \\"$(kubectl get pod slowpod -n $NS -o jsonpath=''{.status.conditions[?(@.type==\\"Ready\\")].status}'' 2>/dev/null)\\" = True ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "q8.txt 에 ready 가 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q8.txt)\\" = ready ]"]}, {"label": "slowpod 가 Ready 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod slowpod -n $NS -o jsonpath=''{.status.conditions[?(@.type==\\"Ready\\")].status}'' 2>/dev/null)\\" = True ]"]}]', '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 9, '필드 설명 바로 찾기 (kubectl explain)', '**배경** — `kubectl explain 리소스.필드.경로` 는 **그 필드가 무엇이고 어떤 값을 받는지** API 스키마에서 바로 보여 줍니다. 문서를 열지 않고 YAML 을 쓸 때 자주 씁니다.

**문제** — Deployment 의 **배포 전략 종류 필드**(`deployment.spec.strategy.type`)의 설명을 **`/tmp/q9.txt`** 에 저장하세요. 설명에는 `Recreate` 와 `RollingUpdate` 가 나옵니다.', '`kubectl explain deployment.spec.strategy.type > /tmp/q9.txt`', 'kubectl explain deployment.spec.strategy.type > /tmp/q9.txt
cat /tmp/q9.txt

# 점(.)으로 필드 경로를 따라 내려간다. --recursive 는 하위를 모두 펼친다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete deploy tool -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod tool-pod slowpod -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true"]', '["sh", "-c", "( grep -q Recreate /tmp/q9.txt ) && ( grep -q RollingUpdate /tmp/q9.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Recreate 가 설명에 있다", "cmd": ["sh", "-c", "grep -q Recreate /tmp/q9.txt"]}, {"label": "RollingUpdate 가 설명에 있다", "cmd": ["sh", "-c", "grep -q RollingUpdate /tmp/q9.txt"]}]', '[{"title": "kubectl 레퍼런스", "url": "https://kubernetes.io/docs/reference/kubectl/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 10, 'kubectl patch 의 기본 방식', '`kubectl patch` 에 `--type` 을 **지정하지 않으면** 어떤 방식으로 병합할까요?', '쿠버네티스 오브젝트에 맞춘 병합이에요.', NULL, NULL, '[]', 'choice', '["JSON Patch 이며 --type 으로 strategic·merge 를 고른다", "전략적 병합(strategic)이며 --type 으로 json·merge 를 고른다", "JSON Merge Patch 이며 목록은 항목별로 합친다", "전체 교체이며 지정하지 않은 필드는 모두 지운다"]', 1, '쿠버네티스 문서는 kubectl patch 의 --type 기본값이 strategic 이라고 설명합니다. strategic 병합은 목록 항목을 병합 키(예: name)로 합치고, json 은 JSON Patch, merge 는 JSON Merge Patch 입니다.', NULL, NULL, NULL, '[{"title": "kubectl patch 로 오브젝트 갱신하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 11, 'YAML 없이 환경 변수 넣기', 'Deployment 의 **환경 변수를 바로 추가**하는 명령입니다. 빈칸을 채우세요.', '"환경" 의 영어예요.', NULL, NULL, '[]', 'fill', '["env", "image", "selector", "resources"]', NULL, 'kubectl set env 는 컨테이너 환경 변수를 추가·변경하고, set image 는 이미지, set resources 는 requests·limits, set selector 는 셀렉터를 바꿉니다.', '[0]', 'kubectl set {0} deployment/tool MODE=prod', NULL, '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 484, 12, '안전하게 변경 반영하기', '매니페스트를 고쳐 배포할 때의 안전한 순서입니다. 순서에 맞게 놓아 보세요.', '미리 보기 → 적용 → 확인 → (문제 시) 되돌리기예요.', NULL, NULL, '[]', 'order', '["`kubectl diff -f` 로 바뀔 내용을 미리 본다", "`kubectl apply -f` 로 적용한다", "`kubectl rollout status` 로 배포가 끝났는지 확인한다", "문제가 있으면 `kubectl rollout undo` 로 되돌린다"]', NULL, '변경 전에 diff 로 확인하고, 적용 후 rollout status 로 완료를 확인하며, 이상이 있으면 undo 로 이전 리비전으로 되돌리는 것이 일반적인 흐름입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "kubectl 치트 시트", "url": "https://kubernetes.io/docs/reference/kubectl/quick-reference/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 484 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 252 WHERE id = 190;
UPDATE quest_set SET display_order = 253 WHERE id = 304;
UPDATE quest_set SET display_order = 254 WHERE id = 194;
UPDATE quest_set SET display_order = 255 WHERE id = 305;
UPDATE quest_set SET display_order = 256 WHERE id = 198;
UPDATE quest_set SET display_order = 257 WHERE id = 306;
UPDATE quest_set SET display_order = 258 WHERE id = 202;
UPDATE quest_set SET display_order = 259 WHERE id = 307;
UPDATE quest_set SET display_order = 260 WHERE id = 205;
UPDATE quest_set SET display_order = 261 WHERE id = 308;
UPDATE quest_set SET display_order = 262 WHERE id = 482;
UPDATE quest_set SET display_order = 263 WHERE id = 208;
UPDATE quest_set SET display_order = 264 WHERE id = 309;
UPDATE quest_set SET display_order = 265 WHERE id = 211;
UPDATE quest_set SET display_order = 266 WHERE id = 310;
UPDATE quest_set SET display_order = 267 WHERE id = 214;
UPDATE quest_set SET display_order = 268 WHERE id = 311;
UPDATE quest_set SET display_order = 269 WHERE id = 217;
UPDATE quest_set SET display_order = 270 WHERE id = 312;
UPDATE quest_set SET display_order = 271 WHERE id = 220;
UPDATE quest_set SET display_order = 272 WHERE id = 313;
UPDATE quest_set SET display_order = 273 WHERE id = 483;
UPDATE quest_set SET display_order = 274 WHERE id = 223;
UPDATE quest_set SET display_order = 275 WHERE id = 314;
UPDATE quest_set SET display_order = 276 WHERE id = 12;
UPDATE quest_set SET display_order = 277 WHERE id = 22;
UPDATE quest_set SET display_order = 278 WHERE id = 236;
UPDATE quest_set SET display_order = 279 WHERE id = 351;
UPDATE quest_set SET display_order = 280 WHERE id = 375;
UPDATE quest_set SET display_order = 281 WHERE id = 383;
UPDATE quest_set SET display_order = 282 WHERE id = 420;
UPDATE quest_set SET display_order = 283 WHERE id = 421;
UPDATE quest_set SET display_order = 286 WHERE id = 80;
UPDATE quest_set SET display_order = 287 WHERE id = 13;
UPDATE quest_set SET display_order = 288 WHERE id = 122;
UPDATE quest_set SET display_order = 289 WHERE id = 25;
UPDATE quest_set SET display_order = 290 WHERE id = 108;
UPDATE quest_set SET display_order = 291 WHERE id = 37;
UPDATE quest_set SET display_order = 292 WHERE id = 26;
UPDATE quest_set SET display_order = 293 WHERE id = 348;
UPDATE quest_set SET display_order = 294 WHERE id = 422;
UPDATE quest_set SET display_order = 295 WHERE id = 23;
UPDATE quest_set SET display_order = 296 WHERE id = 31;
UPDATE quest_set SET display_order = 297 WHERE id = 29;
UPDATE quest_set SET display_order = 298 WHERE id = 227;
UPDATE quest_set SET display_order = 299 WHERE id = 230;
UPDATE quest_set SET display_order = 300 WHERE id = 233;
UPDATE quest_set SET display_order = 301 WHERE id = 339;
UPDATE quest_set SET display_order = 302 WHERE id = 345;
UPDATE quest_set SET display_order = 303 WHERE id = 423;
UPDATE quest_set SET display_order = 304 WHERE id = 425;
UPDATE quest_set SET display_order = 305 WHERE id = 119;
UPDATE quest_set SET display_order = 306 WHERE id = 120;
UPDATE quest_set SET display_order = 307 WHERE id = 121;
UPDATE quest_set SET display_order = 308 WHERE id = 424;
UPDATE quest_set SET display_order = 309 WHERE id = 14;
UPDATE quest_set SET display_order = 251, unit_id = (SELECT id FROM unit WHERE id = 62), icon = '🪚' WHERE id = 484;
