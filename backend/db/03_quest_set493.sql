-- 세트 493: k8s Job·프로브·수명주기 설정 손연습: backoffLimit, activeDeadlineSeconds, ttlSecondsAfterFinished, Indexed Job, exec·tcpSocket 프로브, postStart, imagePullPolicy 기본값, 종료 메시지
-- 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다. docs/specs/spec_k8s_job_probe_lifecycle_lab_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (493, 1, '실패한 Job 을 몇 번까지 다시 시도할까 (backoffLimit)', '**배경** — Job 의 Pod 가 실패하면 컨트롤러가 **새 Pod 로 재시도**합니다. 재시도 횟수 상한이 **`backoffLimit`**(기본 6)이고, 넘으면 Job 이 `Failed` 가 됩니다. 재시도 간격은 10초, 20초… 로 늘어납니다. 항상 실패하는 작업은 상한을 낮춰 빨리 포기하게 합니다.

**문제** — 명령 `sh -c "exit 1"`(항상 실패)을 `busybox:1.36` 으로 실행하는 Job **`bo`** 를 **`backoffLimit: 1`**, `restartPolicy: Never` 로 만드세요.', 'YAML 의 `spec.backoffLimit: 1` 과 Pod 템플릿의 `restartPolicy: Never` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: batch/v1
kind: Job
metadata: {name: bo}
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: c
        image: busybox:1.36
        command: ["sh", "-c", "exit 1"]
EOF
kubectl wait --for=condition=Failed job/bo -n $NS --timeout=120s

# 첫 시도 + 재시도 1번이 모두 실패하면 BackoffLimitExceeded', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get job bo -n $NS -o jsonpath=''{.spec.backoffLimit}'' 2>/dev/null)\\" = 1 ] ) && ( kubectl get job bo -n $NS -o jsonpath=''{.spec.template.spec.containers[0].command[2]}'' 2>/dev/null | grep -q \\"exit 1\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "backoffLimit 이 1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get job bo -n $NS -o jsonpath=''{.spec.backoffLimit}'' 2>/dev/null)\\" = 1 ]"]}, {"label": "명령이 exit 1 이다", "cmd": ["sh", "-c", "kubectl get job bo -n $NS -o jsonpath=''{.spec.template.spec.containers[0].command[2]}'' 2>/dev/null | grep -q \\"exit 1\\""]}]', '[{"title": "Job", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/job/"}]'),
  (493, 2, '너무 오래 걸리면 Job 포기시키기 (activeDeadlineSeconds)', '**배경** — Job 의 **`activeDeadlineSeconds`** 는 Job 이 **시작한 뒤 허용하는 총 시간**입니다. 넘으면 실행 중인 Pod 를 모두 종료하고 Job 을 `DeadlineExceeded` 로 실패시킵니다. 끝나지 않는 작업이 자원을 붙잡는 것을 막습니다.

**문제** — `busybox:1.36` 으로 `sleep 3600` 을 실행하는 Job **`dl`** 을 **`activeDeadlineSeconds: 20`**, `restartPolicy: Never` 로 만드세요.', 'YAML 의 `spec.activeDeadlineSeconds: 20` 을 적어요. (Job 스펙이지 Pod 스펙이 아니에요.)', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: batch/v1
kind: Job
metadata: {name: dl}
spec:
  activeDeadlineSeconds: 20
  template:
    spec:
      restartPolicy: Never
      terminationGracePeriodSeconds: 0
      containers:
      - name: c
        image: busybox:1.36
        command: ["sleep", "3600"]
EOF
kubectl wait --for=condition=Failed job/dl -n $NS --timeout=90s
kubectl get job dl -n $NS -o jsonpath=''{.status.conditions[0].reason}''

# 20초가 지나면 DeadlineExceeded', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get job dl -n $NS -o jsonpath=''{.spec.activeDeadlineSeconds}'' 2>/dev/null)\\" = 20 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "activeDeadlineSeconds 가 20 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get job dl -n $NS -o jsonpath=''{.spec.activeDeadlineSeconds}'' 2>/dev/null)\\" = 20 ]"]}]', '[{"title": "Job", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/job/"}]'),
  (493, 3, '끝난 Job 을 자동으로 치우기 (ttlSecondsAfterFinished)', '**배경** — 끝난 Job 과 Pod 는 지우기 전까지 남아 쌓입니다. **`ttlSecondsAfterFinished`** 를 주면 Job 이 **끝난 뒤 그 시간이 지나 자동 삭제**됩니다. 로그를 볼 시간을 남기려고 너무 짧게 잡지 않습니다.

**문제** — `busybox:1.36` 으로 `echo hi` 를 실행하는 Job **`ttl`** 을 **`ttlSecondsAfterFinished: 600`**(10분), `restartPolicy: Never` 로 만드세요.', 'YAML 의 `spec.ttlSecondsAfterFinished: 600` 을 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: batch/v1
kind: Job
metadata: {name: ttl}
spec:
  ttlSecondsAfterFinished: 600
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: c
        image: busybox:1.36
        command: ["echo", "hi"]
EOF
kubectl get job ttl -n $NS -o jsonpath=''{.spec.ttlSecondsAfterFinished}''

# 끝난 지 600초 뒤 Job 과 Pod 가 자동으로 지워진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get job ttl -n $NS -o jsonpath=''{.spec.ttlSecondsAfterFinished}'' 2>/dev/null)\\" = 600 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "ttlSecondsAfterFinished 가 600 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get job ttl -n $NS -o jsonpath=''{.spec.ttlSecondsAfterFinished}'' 2>/dev/null)\\" = 600 ]"]}]', '[{"title": "Job", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/job/"}]'),
  (493, 4, 'Pod 마다 번호를 받는 Job (Indexed)', '**배경** — `completionMode: Indexed` 인 Job 은 Pod 마다 **0, 1, 2… 번호**를 환경 변수 `JOB_COMPLETION_INDEX` 로 줍니다. 같은 이미지로 **입력을 나눠 처리**할 때(번호 = 조각 번호) 씁니다. `completions` 가 번호의 개수입니다.

**문제** — `busybox:1.36` 으로 `echo idx=$JOB_COMPLETION_INDEX` 를 실행하는 Job **`idx`** 를 **`completionMode: Indexed`**, `completions: 3`, `parallelism: 3`, `restartPolicy: Never` 로 만들고 **3개가 모두 성공할 때까지** 기다리세요.', 'YAML 의 `spec` 에 `completionMode: Indexed`, `completions: 3`, `parallelism: 3` 을 적고 `kubectl wait --for=condition=Complete` 로 기다려요. 명령은 `sh -c` 로 감싸요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: batch/v1
kind: Job
metadata: {name: idx}
spec:
  completionMode: Indexed
  completions: 3
  parallelism: 3
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: c
        image: busybox:1.36
        command: ["sh", "-c", "echo idx=$JOB_COMPLETION_INDEX"]
EOF
kubectl wait --for=condition=Complete job/idx -n $NS --timeout=120s
kubectl logs -l job-name=idx -n $NS

# 로그에 idx=0, idx=1, idx=2 가 나온다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get job idx -n $NS -o jsonpath=''{.spec.completionMode}'' 2>/dev/null)\\" = Indexed ] ) && ( [ \\"$(kubectl get job idx -n $NS -o jsonpath=''{.status.succeeded}'' 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "completionMode 가 Indexed 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get job idx -n $NS -o jsonpath=''{.spec.completionMode}'' 2>/dev/null)\\" = Indexed ]"]}, {"label": "3개가 성공했다", "cmd": ["sh", "-c", "[ \\"$(kubectl get job idx -n $NS -o jsonpath=''{.status.succeeded}'' 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "인덱스 Job 으로 병렬 처리", "url": "https://kubernetes.io/docs/tasks/job/indexed-parallel-processing-static/"}, {"title": "Job", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/job/"}]'),
  (493, 5, '파일이 생겨야 준비 완료로 보기 (exec readinessProbe)', '**배경** — `readinessProbe` 는 컨테이너가 **트래픽을 받을 준비가 됐는지** 점검합니다. 실패하면 Pod 는 `Ready` 가 아니라 Service 엔드포인트에서 빠집니다(재시작은 안 함). `exec` 프로브는 **명령의 종료 코드가 0** 이면 성공입니다. 앱이 준비되면 표시 파일을 만드는 방식에 자주 씁니다.

**문제** — Pod **`rp`**(`busybox:1.36`)를 만드세요. 컨테이너는 **5초 뒤 `/tmp/ready` 파일을 만들고** 계속 실행하며, `readinessProbe` 는 `exec` 로 `cat /tmp/ready`, `periodSeconds: 2` 입니다. Pod 가 **Ready 가 되어야** 합니다.', 'command 는 `sh -c "sleep 5; touch /tmp/ready; sleep 3600"`, `readinessProbe.exec.command: ["cat","/tmp/ready"]` 로 해요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: rp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "sleep 5; touch /tmp/ready; sleep 3600"]
    readinessProbe:
      exec: {command: ["cat", "/tmp/ready"]}
      periodSeconds: 2
EOF
kubectl get pod rp -n $NS
kubectl wait --for=condition=Ready pod/rp -n $NS --timeout=90s

# 처음 몇 초는 READY 0/1, 파일이 생기면 1/1', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( kubectl get pod rp -n $NS -o jsonpath=''{.spec.containers[0].readinessProbe.exec.command[0]}'' 2>/dev/null | grep -q cat ) && ( [ \\"$(kubectl get pod rp -n $NS -o jsonpath=''{.status.conditions[?(@.type==\\"Ready\\")].status}'' 2>/dev/null)\\" = True ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "readinessProbe 명령이 cat 이다", "cmd": ["sh", "-c", "kubectl get pod rp -n $NS -o jsonpath=''{.spec.containers[0].readinessProbe.exec.command[0]}'' 2>/dev/null | grep -q cat"]}, {"label": "Pod 가 Ready 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod rp -n $NS -o jsonpath=''{.status.conditions[?(@.type==\\"Ready\\")].status}'' 2>/dev/null)\\" = True ]"]}]', '[{"title": "라이브니스·레디니스·스타트업 프로브", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/"}]'),
  (493, 6, '포트가 열려 있는지로 살아 있음 판단하기 (tcpSocket livenessProbe)', '**배경** — `livenessProbe` 는 컨테이너가 **살아 있는지** 점검하고, 실패하면 kubelet 이 **컨테이너를 재시작**합니다(readiness 와의 차이). 프로브 방식은 `httpGet`, `exec`, **`tcpSocket`**(포트에 연결되면 성공) 중에서 고릅니다. HTTP 엔드포인트가 없는 DB·캐시에 tcpSocket 을 씁니다.

**문제** — `nginx:1.25` Pod **`lp`** 를 만들고 `livenessProbe` 를 **`tcpSocket` 포트 `80`**, `periodSeconds: 5` 로 설정하세요. Pod 는 Running 이어야 합니다.', 'containers 항목 안에 `livenessProbe: {tcpSocket: {port: 80}, periodSeconds: 5}` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: lp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: web
    image: nginx:1.25
    livenessProbe:
      tcpSocket: {port: 80}
      periodSeconds: 5
EOF
kubectl wait --for=condition=Ready pod/lp -n $NS --timeout=90s

# 연결이 실패하면 컨테이너가 재시작된다. readiness 와 달리 트래픽 제외가 아니라 재시작이다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod lp -n $NS -o jsonpath=''{.spec.containers[0].livenessProbe.tcpSocket.port}'' 2>/dev/null)\\" = 80 ] ) && ( [ \\"$(kubectl get pod lp -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "tcpSocket 포트가 80 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod lp -n $NS -o jsonpath=''{.spec.containers[0].livenessProbe.tcpSocket.port}'' 2>/dev/null)\\" = 80 ]"]}, {"label": "Pod 가 Running 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod lp -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ]"]}]', '[{"title": "라이브니스·레디니스·스타트업 프로브", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/"}]'),
  (493, 7, '컨테이너가 시작되자마자 실행할 일 (postStart 훅)', '**배경** — **`lifecycle.postStart`** 는 컨테이너가 **생성된 직후** 실행되는 훅이고, `preStop` 은 종료 직전에 실행됩니다. `exec` 로 명령을 줄 수 있습니다. postStart 가 실패하면 컨테이너는 종료되어 재시작 정책을 따릅니다. (메인 프로세스와 **동시에** 시작하므로 순서는 보장되지 않습니다.)

**문제** — Pod **`hk`**(`busybox:1.36`, `sleep 3600`)를 만들되 **postStart 훅**이 `/tmp/started` 파일에 `hook-ran` 을 쓰도록 하세요. (Pod 가 Ready 가 된 뒤 파일 내용이 `hook-ran` 이어야 합니다.)', 'containers 항목 안에 `lifecycle: {postStart: {exec: {command: ["sh","-c","echo hook-ran > /tmp/started"]}}}` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: hk}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    lifecycle:
      postStart:
        exec:
          command: ["sh", "-c", "echo hook-ran > /tmp/started"]
EOF
kubectl wait --for=condition=Ready pod/hk -n $NS --timeout=90s
kubectl exec hk -n $NS -- cat /tmp/started

# postStart 가 끝나야 컨테이너가 Running 으로 표시된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec hk -n $NS -- cat /tmp/started 2>/dev/null)\\" = hook-ran ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/tmp/started 가 hook-ran 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec hk -n $NS -- cat /tmp/started 2>/dev/null)\\" = hook-ran ]"]}]', '[{"title": "컨테이너 라이프사이클 훅", "url": "https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/"}]'),
  (493, 8, '이미지 태그에 따라 달라지는 기본 pull 정책 (imagePullPolicy)', '**배경** — `imagePullPolicy` 를 적지 않으면 **이미지 태그에 따라** 기본값이 정해집니다. 태그가 **`:latest`**(또는 태그 없음)이면 **`Always`**(항상 레지스트리 확인), 그 밖의 **고정 태그**면 **`IfNotPresent`**(노드에 없을 때만 받기) 입니다. 그래서 운영에서는 고정 태그를 권합니다.

**문제** — Pod **`latestpod`**(`busybox:latest`)와 **`fixedpod`**(`busybox:1.36`)를 `sleep 3600` 으로 만들고, 둘의 `imagePullPolicy` 를 이 순서대로 **`/tmp/q8.txt`** 에 **두 줄**로 저장하세요.', '`kubectl run latestpod --image=busybox:latest -- sleep 3600` 처럼 만들고 `kubectl get pod … -o jsonpath=''{.spec.containers[0].imagePullPolicy}''` 로 읽어요.', 'kubectl run latestpod -n $NS --image=busybox:latest --restart=Never -- sleep 3600
kubectl run fixedpod -n $NS --image=busybox:1.36 --restart=Never -- sleep 3600
kubectl get pod latestpod -n $NS -o jsonpath=''{.spec.containers[0].imagePullPolicy}{"\\n"}'' > /tmp/q8.txt
kubectl get pod fixedpod -n $NS -o jsonpath=''{.spec.containers[0].imagePullPolicy}{"\\n"}'' >> /tmp/q8.txt
cat /tmp/q8.txt

# latest → Always, 1.36 → IfNotPresent', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(sed -n 1p /tmp/q8.txt 2>/dev/null)\\" = Always ] ) && ( [ \\"$(sed -n 2p /tmp/q8.txt 2>/dev/null)\\" = IfNotPresent ] ) && ( kubectl get pod latestpod fixedpod -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "첫 줄이 Always 다", "cmd": ["sh", "-c", "[ \\"$(sed -n 1p /tmp/q8.txt 2>/dev/null)\\" = Always ]"]}, {"label": "둘째 줄이 IfNotPresent 다", "cmd": ["sh", "-c", "[ \\"$(sed -n 2p /tmp/q8.txt 2>/dev/null)\\" = IfNotPresent ]"]}, {"label": "두 Pod 가 있다", "cmd": ["sh", "-c", "kubectl get pod latestpod fixedpod -n $NS >/dev/null 2>&1"]}]', '[{"title": "이미지 (imagePullPolicy)", "url": "https://kubernetes.io/docs/concepts/containers/images/"}]'),
  (493, 9, '종료 이유를 한 줄 남기기 (terminationMessagePath)', '**배경** — 컨테이너가 죽을 때 `/dev/termination-log` 파일에 쓴 내용은 Pod 의 **`lastState/state.terminated.message`** 로 올라옵니다. 로그를 뒤지지 않고 `describe`·`get -o jsonpath` 에서 **왜 죽었는지 한 줄**을 바로 볼 수 있습니다.

**문제** — Pod **`tm`**(`busybox:1.36`, `restartPolicy: Never`)을 만들어 `echo oops > /dev/termination-log; exit 1` 을 실행하게 하고, **종료 메시지**를 jsonpath 로 읽어 **`/tmp/q9.txt`** 에 저장하세요. (`oops`)', '종료 후 `kubectl get pod tm -o jsonpath=''{.status.containerStatuses[0].state.terminated.message}''`', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: tm}
spec:
  restartPolicy: Never
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "echo oops > /dev/termination-log; exit 1"]
EOF
kubectl wait --for=jsonpath=''{.status.phase}''=Failed pod/tm -n $NS --timeout=90s
kubectl get pod tm -n $NS -o jsonpath=''{.status.containerStatuses[0].state.terminated.message}'' > /tmp/q9.txt
cat /tmp/q9.txt

# 재시작되는 Pod 는 lastState.terminated.message 에서 읽는다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete job bo dl ttl idx -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete pod rp lp hk latestpod fixedpod tm -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q9.txt 2>/dev/null)\\" = oops ] ) && ( [ \\"$(kubectl get pod tm -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Failed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "메시지가 oops 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q9.txt 2>/dev/null)\\" = oops ]"]}, {"label": "tm 이 Failed 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod tm -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Failed ]"]}]', '[{"title": "종료 메시지 확인", "url": "https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/"}]'),
  (493, 10, 'livenessProbe 와 readinessProbe 의 차이', '프로브가 **실패**했을 때 `livenessProbe` 와 `readinessProbe` 는 각각 어떻게 동작할까요?', '하나는 재시작, 하나는 트래픽이에요.', NULL, NULL, '[]', 'choice', '["liveness 는 트래픽에서 제외하고 readiness 는 컨테이너를 재시작한다", "liveness 는 컨테이너를 재시작하고 readiness 는 트래픽에서 제외한다", "둘 다 Pod 를 삭제하고 새로 만든다", "둘 다 이벤트만 남기고 아무 동작도 하지 않는다"]', 1, 'livenessProbe 실패는 kubelet 이 컨테이너를 재시작하게 하고, readinessProbe 실패는 Pod 를 Ready 아님으로 표시해 Service 엔드포인트에서 뺍니다. 재시작은 하지 않습니다.', NULL, NULL, NULL, '[{"title": "라이브니스·레디니스·스타트업 프로브", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/"}]'),
  (493, 11, '끝난 Job 자동 삭제', '끝난 Job 을 일정 시간 뒤 자동으로 지우는 필드입니다. 빈칸을 채우세요.', '"끝난 뒤" 라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["Finished", "Created", "Started", "Deleted"]', NULL, 'ttlSecondsAfterFinished 는 Job 이 완료(Complete)나 실패(Failed)로 끝난 뒤 해당 초가 지나면 Job 과 Pod 를 삭제합니다.', '[0]', 'ttlSecondsAfter{0}: 600', NULL, '[{"title": "Job", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/job/"}]'),
  (493, 12, 'Pod 가 트래픽을 받기까지의 순서', '프로브와 훅이 있는 Pod 가 시작해서 Service 트래픽을 받기까지의 일반적인 순서입니다. 순서에 맞게 놓아 보세요.', '준비 컨테이너 → 앱 시작 → 시작 프로브 → 준비 프로브예요.', NULL, NULL, '[]', 'order', '["initContainers 가 차례로 끝까지 실행된다", "앱 컨테이너가 시작되고 `postStart` 훅이 실행된다", "`startupProbe` 가 성공한다", "`readinessProbe` 가 성공해 Pod 가 Ready 가 되고 트래픽을 받는다"]', NULL, 'initContainers 가 모두 끝나야 앱 컨테이너가 시작됩니다. startupProbe 가 성공해야 liveness·readiness 가 시작되고, readiness 가 성공해야 Service 가 트래픽을 보냅니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "라이브니스·레디니스·스타트업 프로브", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/"}, {"title": "컨테이너 라이프사이클 훅", "url": "https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/"}]');
