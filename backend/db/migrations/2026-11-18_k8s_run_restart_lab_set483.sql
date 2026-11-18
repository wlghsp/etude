-- Git 실습 세트 483. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_run_restart_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 483, 'k8s 컨테이너 실행과 재시작 손연습: command·args, $(VAR), workingDir, restartPolicy, lastState, Deployment 복구, ownerReferences, ReplicaSet', 'Pod 가 어떻게 실행되고 다시 뜨는지 직접 확인합니다. command 와 args 로 ENTRYPOINT·CMD 덮어쓰기, $(VAR) 치환, workingDir, restartPolicy Never·OnFailure 의 차이, lastState 로 죽은 이유 읽기, Pod 삭제 후 Deployment 복구, ownerReferences 로 소유 관계 따라가기, ReplicaSet 직접 조작이 되돌아가는 이유를 실습합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 483);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 1, '이미지의 명령 바꿔 실행하기 (command · args)', '**배경** — 컨테이너가 시작할 때 실행하는 것은 이미지의 `ENTRYPOINT`/`CMD` 이고, Pod 스펙의 **`command`** 는 `ENTRYPOINT` 를, **`args`** 는 `CMD` 를 **덮어씁니다**. 둘 다 문자열 목록으로 씁니다. 한 번 실행하고 끝나는 작업은 `restartPolicy: Never` 로 둡니다.

**문제** — `busybox:1.36` 이미지로 Pod **`ca`** 를 만드세요. `command` 는 **`["echo"]`**, `args` 는 **`["hello", "k8s"]`**, `restartPolicy` 는 **`Never`** 입니다. 실행이 끝나면(Succeeded) 로그가 `hello k8s` 여야 합니다.', '컨테이너 아래 `command: ["echo"]`, `args: ["hello", "k8s"]` 그리고 Pod `restartPolicy: Never`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: ca
spec:
  terminationGracePeriodSeconds: 0
  restartPolicy: Never
  containers:
  - name: c
    image: busybox:1.36
    command: ["echo"]
    args: ["hello", "k8s"]
EOF
sleep 8
kubectl logs ca -n $NS

# command 가 ENTRYPOINT, args 가 CMD 를 덮어쓴다. echo 가 끝나면 Pod 는 Succeeded', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod ca -n $NS -o jsonpath=''{.spec.containers[0].command[0]}'' 2>/dev/null)\\" = echo ] ) && ( [ \\"$(kubectl get pod ca -n $NS -o jsonpath=''{.spec.containers[0].args[*]}'' 2>/dev/null)\\" = \\"hello k8s\\" ] ) && ( ( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod ca -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Succeeded ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( [ \\"$(kubectl logs ca -n $NS 2>/dev/null)\\" = \\"hello k8s\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "command 가 echo 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod ca -n $NS -o jsonpath=''{.spec.containers[0].command[0]}'' 2>/dev/null)\\" = echo ]"]}, {"label": "args 가 hello k8s 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod ca -n $NS -o jsonpath=''{.spec.containers[0].args[*]}'' 2>/dev/null)\\" = \\"hello k8s\\" ]"]}, {"label": "Pod 가 Succeeded 가 됐다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod ca -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Succeeded ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "로그가 hello k8s 다", "cmd": ["sh", "-c", "[ \\"$(kubectl logs ca -n $NS 2>/dev/null)\\" = \\"hello k8s\\" ]"]}]', '[{"title": "컨테이너에 명령과 인자 정의하기", "url": "https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 2, '환경 변수를 인자에 끼워 넣기 ($(VAR))', '**배경** — 컨테이너 `env` 로 정의한 변수는 `command`·`args` 안에서 **`$(변수이름)`** 으로 쓸 수 있습니다. 이것은 쉘이 푸는 `$VAR` 가 아니라 **쿠버네티스가 먼저 치환**하는 문법입니다.

**문제** — Pod **`ev`** (`busybox:1.36`, `restartPolicy: Never`)를 만드세요. 환경 변수 **`GREETING=hi`** 를 정의하고, `command: ["echo"]`, `args: ["$(GREETING) there"]` 로 실행합니다. 로그가 **`hi there`** 여야 합니다.', '`env: [{name: GREETING, value: hi}]` 와 `args: ["$(GREETING) there"]` — 괄호 `$()` 를 써요.', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: ev
spec:
  terminationGracePeriodSeconds: 0
  restartPolicy: Never
  containers:
  - name: c
    image: busybox:1.36
    env:
    - {name: GREETING, value: hi}
    command: ["echo"]
    args: ["$(GREETING) there"]
EOF
sleep 8
kubectl logs ev -n $NS

# $(GREETING) 은 쿠버네티스가 치환한다 (쉘 문법 ${GREETING} 이나 $GREETING 과 다르다)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod ev -n $NS -o jsonpath=''{.spec.containers[0].env[0].value}'' 2>/dev/null)\\" = hi ] ) && ( ( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod ev -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Succeeded ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( [ \\"$(kubectl logs ev -n $NS 2>/dev/null)\\" = \\"hi there\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "GREETING 이 hi 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod ev -n $NS -o jsonpath=''{.spec.containers[0].env[0].value}'' 2>/dev/null)\\" = hi ]"]}, {"label": "Pod 가 Succeeded 가 됐다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod ev -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Succeeded ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "로그가 hi there 다", "cmd": ["sh", "-c", "[ \\"$(kubectl logs ev -n $NS 2>/dev/null)\\" = \\"hi there\\" ]"]}]', '[{"title": "컨테이너에 명령과 인자 정의하기", "url": "https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 3, '작업 폴더 정하기 (workingDir)', '**배경** — `workingDir` 는 컨테이너 안에서 명령이 **실행되는 현재 폴더**를 정합니다(이미지의 `WORKDIR` 을 덮어씁니다). 상대 경로로 파일을 다루는 프로그램에서 중요합니다.

**문제** — Pod **`wd`** (`busybox:1.36`, `restartPolicy: Never`)를 만드세요. `workingDir` 를 **`/etc`** 로 하고 `command: ["pwd"]` 를 실행합니다. 로그가 **`/etc`** 여야 합니다.', '컨테이너 아래 `workingDir: /etc`, `command: ["pwd"]`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: wd
spec:
  terminationGracePeriodSeconds: 0
  restartPolicy: Never
  containers:
  - name: c
    image: busybox:1.36
    workingDir: /etc
    command: ["pwd"]
EOF
sleep 8
kubectl logs wd -n $NS

# workingDir 는 이미지의 WORKDIR 을 덮어쓴다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod wd -n $NS -o jsonpath=''{.spec.containers[0].workingDir}'' 2>/dev/null)\\" = /etc ] ) && ( ( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod wd -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Succeeded ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( [ \\"$(kubectl logs wd -n $NS 2>/dev/null)\\" = /etc ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "workingDir 가 /etc 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod wd -n $NS -o jsonpath=''{.spec.containers[0].workingDir}'' 2>/dev/null)\\" = /etc ]"]}, {"label": "Pod 가 Succeeded 가 됐다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod wd -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Succeeded ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "로그가 /etc 다", "cmd": ["sh", "-c", "[ \\"$(kubectl logs wd -n $NS 2>/dev/null)\\" = /etc ]"]}]', '[{"title": "컨테이너에 명령과 인자 정의하기", "url": "https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 4, '실패해도 다시 안 띄우기 (restartPolicy: Never)', '**배경** — `restartPolicy` 는 컨테이너가 끝났을 때 **kubelet 이 다시 시작할지** 정합니다. `Always`(기본)는 항상, `OnFailure` 는 종료 코드가 0 이 아닐 때만, `Never` 는 **절대 다시 시작하지 않습니다**. `Never` 에서 실패하면 Pod 단계(phase)가 **`Failed`** 가 됩니다.

**문제** — Pod **`rn`** (`busybox:1.36`)을 만드세요. `restartPolicy: Never`, `command: ["sh", "-c", "exit 1"]` 입니다. Pod 가 **`Failed`** 가 되고 **재시작 횟수는 0** 이어야 합니다.', 'Pod `restartPolicy: Never` 와 `command: ["sh", "-c", "exit 1"]`', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: rn
spec:
  terminationGracePeriodSeconds: 0
  restartPolicy: Never
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "exit 1"]
EOF
sleep 8
kubectl get pod rn -n $NS

# Never 면 실패한 컨테이너를 다시 띄우지 않는다. phase 는 Failed, RESTARTS 는 0', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.spec.restartPolicy}'' 2>/dev/null)\\" = Never ] ) && ( ( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Failed ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) ) && ( [ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.status.containerStatuses[0].restartCount}'' 2>/dev/null)\\" = 0 ] ) && ( [ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.status.containerStatuses[0].state.terminated.exitCode}'' 2>/dev/null)\\" = 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "restartPolicy 가 Never 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.spec.restartPolicy}'' 2>/dev/null)\\" = Never ]"]}, {"label": "Pod 가 Failed 가 됐다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Failed ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}, {"label": "재시작 횟수가 0 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.status.containerStatuses[0].restartCount}'' 2>/dev/null)\\" = 0 ]"]}, {"label": "종료 코드가 1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod rn -n $NS -o jsonpath=''{.status.containerStatuses[0].state.terminated.exitCode}'' 2>/dev/null)\\" = 1 ]"]}]', '[{"title": "Pod 수명 주기 — 재시작 정책", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 5, '실패하면 다시 띄우기 (restartPolicy: OnFailure)', '**배경** — `OnFailure` 는 종료 코드가 **0 이 아니면** kubelet 이 컨테이너를 다시 시작합니다. 계속 실패하면 재시작 간격이 점점 늘어나며(10초, 20초, 40초 …) 상태가 `CrashLoopBackOff` 로 보입니다. 재시작 횟수는 `containerStatuses[0].restartCount` 입니다.

**문제** — Pod **`rf`** (`busybox:1.36`)를 만드세요. `restartPolicy: OnFailure`, `command: ["sh", "-c", "exit 1"]` 입니다. 잠시 뒤 재시작 횟수가 **2 이상**이 되어야 합니다. (1분쯤 걸립니다.)', 'Pod `restartPolicy: OnFailure` — `kubectl get pod rf -w` 로 RESTARTS 가 늘어나는 걸 볼 수 있어요.', 'kubectl apply -n $NS -f - >/dev/null <<''EOF''
apiVersion: v1
kind: Pod
metadata:
  name: rf
spec:
  terminationGracePeriodSeconds: 0
  restartPolicy: OnFailure
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "exit 1"]
EOF
sleep 45
kubectl get pod rf -n $NS

# OnFailure 는 실패하면 재시작, 성공(0)하면 끝. 재시작 간격은 점점 길어진다 (CrashLoopBackOff)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(kubectl get pod rf -n $NS -o jsonpath=''{.spec.restartPolicy}'' 2>/dev/null)\\" = OnFailure ] ) && ( ( i=0; while [ $i -lt 60 ]; do [ \\"$(kubectl get pod rf -n $NS -o jsonpath=''{.status.containerStatuses[0].restartCount}'' 2>/dev/null)\\" -ge 2 ] 2>/dev/null && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "restartPolicy 가 OnFailure 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod rf -n $NS -o jsonpath=''{.spec.restartPolicy}'' 2>/dev/null)\\" = OnFailure ]"]}, {"label": "재시작이 2번 이상 일어났다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 60 ]; do [ \\"$(kubectl get pod rf -n $NS -o jsonpath=''{.status.containerStatuses[0].restartCount}'' 2>/dev/null)\\" -ge 2 ] 2>/dev/null && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}]', '[{"title": "Pod 수명 주기 — 재시작 정책", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 6, '죽은 이유를 마지막 상태에서 읽기 (lastState)', '**배경** — 컨테이너가 재시작되면 **직전에 죽은 이유**가 `status.containerStatuses[0].lastState.terminated` 에 남습니다(`exitCode`, `reason` 등). 현재 상태(`state`)는 `Waiting`(재시작 대기)으로 보일 수 있어서 **원인은 lastState 에서** 봅니다. Pod **`crash`** 는 `exit 3` 으로 끝나며 이미 한 번 이상 재시작되었습니다.

**문제** — `crash` 의 **마지막 종료 코드**(`lastState.terminated.exitCode`)를 **`/tmp/q6.txt`** 에 저장하세요. (`3`)', '`kubectl get pod crash -o jsonpath=''{.status.containerStatuses[0].lastState.terminated.exitCode}''`', 'kubectl get pod crash -n $NS -o jsonpath=''{.status.containerStatuses[0].lastState.terminated.exitCode}'' > /tmp/q6.txt
cat /tmp/q6.txt

# state 는 지금, lastState 는 직전. 재시작 원인은 lastState 와 describe 의 Last State 에서 본다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl apply -n $NS -f - >/dev/null <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: crash\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  restartPolicy: Always\\n  containers:\\n  - name: c\\n    image: busybox:1.36\\n    command: [\\"sh\\", \\"-c\\", \\"exit 3\\"]\\nEOF\\ni=0; while [ $i -lt 60 ]; do [ \\"$(kubectl get pod crash -n $NS -o jsonpath=''{.status.containerStatuses[0].restartCount}'' 2>/dev/null)\\" -ge 1 ] 2>/dev/null && break; sleep 2; i=$((i+1)); done\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q6.txt)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 3 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q6.txt)\\" = 3 ]"]}]', '[{"title": "Pod 수명 주기 — 재시작 정책", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 7, 'Pod 가 사라지면 Deployment 가 되살린다', '**배경** — Deployment 는 ReplicaSet 을 통해 **원하는 개수(replicas)만큼 Pod 를 유지**합니다. Pod 하나를 지우면 부족한 것을 감지해 **새 Pod 를 만듭니다**(이름이 달라집니다). 이미 `heal` Deployment(replicas 2)가 떠 있고, 그 Pod 하나의 이름이 `/tmp/lab/orig.txt` 에 적혀 있습니다.

**문제** — `orig.txt` 의 이름을 가진 Pod 를 **삭제**하세요. 잠시 뒤 `heal` 의 Pod 는 다시 **2개**가 되고 **삭제한 이름은 없어야** 합니다.', '`kubectl delete pod $(cat /tmp/lab/orig.txt)` 후 `kubectl get pods -l app=heal`', 'kubectl delete pod $(cat /tmp/lab/orig.txt) -n $NS
kubectl rollout status deployment/heal -n $NS
kubectl get pods -l app=heal -n $NS

# 지운 Pod 와 이름이 다른 새 Pod 가 생겨 2개를 맞춘다. Pod 는 직접 지키지 않고 Deployment 가 지킨다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment heal -n $NS --image=nginx:1.25 --replicas=2 >/dev/null\\nkubectl rollout status deployment/heal -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl get pod -l app=heal -n $NS -o jsonpath=''{.items[0].metadata.name}'' > /tmp/lab/orig.txt\\n"]', '["sh", "-c", "( ! kubectl get pod \\"$(cat /tmp/lab/orig.txt)\\" -n $NS >/dev/null 2>&1 ) && ( ( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pods -l app=heal -n $NS --no-headers 2>/dev/null | grep -c Running)\\" -eq 2 ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 ) )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "삭제한 Pod 는 없다", "cmd": ["sh", "-c", "! kubectl get pod \\"$(cat /tmp/lab/orig.txt)\\" -n $NS >/dev/null 2>&1"]}, {"label": "heal 의 Pod 가 다시 2개다", "cmd": ["sh", "-c", "( i=0; while [ $i -lt 45 ]; do [ \\"$(kubectl get pods -l app=heal -n $NS --no-headers 2>/dev/null | grep -c Running)\\" -eq 2 ] && exit 0; sleep 2; i=$((i+1)); done; exit 1 )"]}]', '[{"title": "디플로이먼트", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/deployment/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 8, 'Pod 의 주인 거슬러 올라가기 (ownerReferences)', '**배경** — 컨트롤러가 만든 오브젝트에는 **누가 만들었는지**가 `metadata.ownerReferences` 에 적힙니다. Pod 의 주인은 **ReplicaSet**, ReplicaSet 의 주인은 **Deployment** 입니다. 주인이 지워지면 가비지 컬렉터가 딸린 것도 지웁니다.

**문제** — `heal` 의 Pod 하나에서 시작해 **Pod 의 주인 종류**와 **그 주인(ReplicaSet)의 주인 종류**를 이 순서대로 공백으로 이어 한 줄로 **`/tmp/q8.txt`** 에 저장하세요. (`ReplicaSet Deployment`)', 'Pod 의 `{.metadata.ownerReferences[0].kind}` 와 `.name` → 그 이름으로 ReplicaSet 을 조회해 같은 필드를 읽어요.', 'pod=$(cat /tmp/lab/orig.txt)
k1=$(kubectl get pod $pod -n $NS -o jsonpath=''{.metadata.ownerReferences[0].kind}'')
rs=$(kubectl get pod $pod -n $NS -o jsonpath=''{.metadata.ownerReferences[0].name}'')
k2=$(kubectl get rs $rs -n $NS -o jsonpath=''{.metadata.ownerReferences[0].kind}'')
echo "$k1 $k2" > /tmp/q8.txt
cat /tmp/q8.txt

# Pod → ReplicaSet → Deployment. 소유 관계가 있어서 Deployment 를 지우면 아래가 모두 지워진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment heal -n $NS --image=nginx:1.25 --replicas=2 >/dev/null\\nkubectl rollout status deployment/heal -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl get pod -l app=heal -n $NS -o jsonpath=''{.items[0].metadata.name}'' > /tmp/lab/orig.txt\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q8.txt)\\" = \\"ReplicaSet Deployment\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "ReplicaSet Deployment 가 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q8.txt)\\" = \\"ReplicaSet Deployment\\" ]"]}]', '[{"title": "소유자와 종속성", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 9, 'ReplicaSet 을 직접 늘려도 되돌아간다', '**배경** — ReplicaSet 은 Deployment 가 관리하므로 **ReplicaSet 을 직접 고쳐도 Deployment 가 곧 원래 값으로 되돌립니다**(Deployment 가 정한 `replicas` 가 진실). 개수는 항상 **Deployment 에서** 바꿔야 합니다.

**문제** — `heal` 이 만든 ReplicaSet 을 `kubectl scale rs` 로 **5개**로 직접 늘린 뒤 **5초 기다렸다가**, 그 ReplicaSet 의 **`spec.replicas`** 를 **`/tmp/q9.txt`** 에 저장하세요. (`2` — 되돌아갔습니다)', '`rs=$(kubectl get rs -l app=heal -o name)` → `kubectl scale $rs --replicas=5` → `sleep 5` → `kubectl get $rs -o jsonpath=''{.spec.replicas}''`', 'rs=$(kubectl get rs -l app=heal -n $NS -o name)
kubectl scale $rs -n $NS --replicas=5
sleep 5
kubectl get $rs -n $NS -o jsonpath=''{.spec.replicas}'' > /tmp/q9.txt
cat /tmp/q9.txt

# Deployment 컨트롤러가 ReplicaSet 의 replicas 를 Deployment 의 값(2)으로 되돌린다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete pod ca ev wd rn rf crash -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete deploy heal -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl create deployment heal -n $NS --image=nginx:1.25 --replicas=2 >/dev/null\\nkubectl rollout status deployment/heal -n $NS --timeout=120s >/dev/null 2>&1\\nkubectl get pod -l app=heal -n $NS -o jsonpath=''{.items[0].metadata.name}'' > /tmp/lab/orig.txt\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q9.txt)\\" = 2 ] ) && ( [ \\"$(kubectl get deploy heal -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "ReplicaSet replicas 가 2 로 되돌아갔다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q9.txt)\\" = 2 ]"]}, {"label": "Deployment replicas 는 그대로 2 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deploy heal -n $NS -o jsonpath=''{.spec.replicas}'' 2>/dev/null)\\" = 2 ]"]}]', '[{"title": "디플로이먼트", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/deployment/"}, {"title": "레플리카셋", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 10, 'Pod 의 restartPolicy 기본값', 'Pod 스펙에서 `restartPolicy` 를 **쓰지 않았을 때**의 기본 동작은 무엇일까요?', '웹 서버처럼 계속 떠 있어야 하는 것이 기본이에요.', NULL, NULL, '[]', 'choice', '["OnFailure — 종료 코드가 0 이 아닐 때만 다시 시작한다", "Always — 종료 코드와 상관없이 컨테이너를 다시 시작한다", "Never — 한 번 끝난 컨테이너는 다시 시작하지 않는다", "Default — 클러스터 설정이 정한 값을 따른다"]', 1, '쿠버네티스 문서는 Pod 의 restartPolicy 기본값이 Always 이며 컨테이너가 어떤 종료 코드로 끝나든 kubelet 이 다시 시작한다고 설명합니다. 일회성 작업(Job)은 OnFailure 나 Never 를 씁니다.', NULL, NULL, NULL, '[{"title": "Pod 수명 주기 — 재시작 정책", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 11, '이미지의 ENTRYPOINT 덮어쓰기', 'Pod 스펙에서 이미지의 **`ENTRYPOINT`** 를 덮어쓰는 필드입니다. 빈칸을 채우세요.', '"명령" 이에요. 인자는 args.', NULL, NULL, '[]', 'fill', '["command", "args", "entrypoint", "exec"]', NULL, '쿠버네티스 문서는 컨테이너의 command 가 이미지의 ENTRYPOINT 를, args 가 이미지의 CMD 를 덮어쓴다고 설명합니다. entrypoint 라는 필드는 없습니다.', '[0]', '{0}: ["echo"]', NULL, '[{"title": "컨테이너에 명령과 인자 정의하기", "url": "https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 483, 12, 'Deployment 가 Pod 를 되살리는 흐름', 'Pod 하나가 삭제됐을 때 Deployment 쪽에서 일어나는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '삭제 → 감지 → 생성 → 회복이에요.', NULL, NULL, '[]', 'order', '["Pod 하나가 삭제되어 실제 개수가 원하는 개수보다 적어진다", "ReplicaSet 컨트롤러가 개수 부족을 감지한다", "ReplicaSet 이 새 Pod 를 만든다 (이름은 새로 정해진다)", "실제 개수가 원하는 개수(replicas)로 회복된다"]', NULL, '쿠버네티스 문서의 ReplicaSet 동작입니다. 컨트롤러는 원하는 상태와 실제 상태의 차이를 계속 줄이는 방향으로 움직입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "레플리카셋", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 483 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 273 WHERE id = 223;
UPDATE quest_set SET display_order = 274 WHERE id = 314;
UPDATE quest_set SET display_order = 275 WHERE id = 12;
UPDATE quest_set SET display_order = 276 WHERE id = 22;
UPDATE quest_set SET display_order = 277 WHERE id = 236;
UPDATE quest_set SET display_order = 278 WHERE id = 351;
UPDATE quest_set SET display_order = 279 WHERE id = 375;
UPDATE quest_set SET display_order = 280 WHERE id = 383;
UPDATE quest_set SET display_order = 281 WHERE id = 420;
UPDATE quest_set SET display_order = 282 WHERE id = 421;
UPDATE quest_set SET display_order = 285 WHERE id = 80;
UPDATE quest_set SET display_order = 286 WHERE id = 13;
UPDATE quest_set SET display_order = 287 WHERE id = 122;
UPDATE quest_set SET display_order = 288 WHERE id = 25;
UPDATE quest_set SET display_order = 289 WHERE id = 108;
UPDATE quest_set SET display_order = 290 WHERE id = 37;
UPDATE quest_set SET display_order = 291 WHERE id = 26;
UPDATE quest_set SET display_order = 292 WHERE id = 348;
UPDATE quest_set SET display_order = 293 WHERE id = 422;
UPDATE quest_set SET display_order = 294 WHERE id = 23;
UPDATE quest_set SET display_order = 295 WHERE id = 31;
UPDATE quest_set SET display_order = 296 WHERE id = 29;
UPDATE quest_set SET display_order = 297 WHERE id = 227;
UPDATE quest_set SET display_order = 298 WHERE id = 230;
UPDATE quest_set SET display_order = 299 WHERE id = 233;
UPDATE quest_set SET display_order = 300 WHERE id = 339;
UPDATE quest_set SET display_order = 301 WHERE id = 345;
UPDATE quest_set SET display_order = 302 WHERE id = 423;
UPDATE quest_set SET display_order = 303 WHERE id = 425;
UPDATE quest_set SET display_order = 304 WHERE id = 119;
UPDATE quest_set SET display_order = 305 WHERE id = 120;
UPDATE quest_set SET display_order = 306 WHERE id = 121;
UPDATE quest_set SET display_order = 307 WHERE id = 424;
UPDATE quest_set SET display_order = 308 WHERE id = 14;
UPDATE quest_set SET display_order = 272, unit_id = (SELECT id FROM unit WHERE id = 64), icon = '♻️' WHERE id = 483;
