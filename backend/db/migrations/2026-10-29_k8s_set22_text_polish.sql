-- 세트 22 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='Job 만들기', description='**Job** 은 한 번 실행하고 끝나는 작업(백업, 데이터 처리 등)을 위한 리소스입니다. 계속 떠 있는 Deployment 와 다릅니다.

`$NS` 네임스페이스에 `busybox` 이미지로 `echo hi` 를 한 번 실행하는 Job `hello-job` 을 만드세요.', hint='`kubectl create job <이름> --image=<이미지> -n <네임스페이스> -- <명령>` 입니다. `--` 뒤가 컨테이너에서 실행할 명령입니다.', solution='kubectl create job hello-job --image=busybox -n $NS -- echo hi

# 확인
kubectl get job hello-job -n $NS' WHERE quest_set_id = 22 AND order_index = 1;
UPDATE quest SET title='Job 의 완료 횟수와 재시작 정책 정하기', description='Job 은 **몇 번 성공해야 끝나는지**(completions)와 실패했을 때의 동작(restartPolicy)을 정할 수 있습니다. 이 설정은 명령어 옵션이 없어 YAML 이 필요합니다.

`$NS` 에 아래 조건의 Job `batch-job` 을 만드세요.
- 이미지 `busybox`, 명령 `echo work`
- 총 **3번** 성공해야 완료 (`completions: 3`)
- `restartPolicy: Never`', hint='뼈대는 `kubectl create job batch-job --image=busybox --dry-run=client -o yaml -n <네임스페이스> -- echo work > job.yaml` 로 만들 수 있습니다. 파일의 `spec` 아래에 `completions: 3` 을, `spec.template.spec` 아래에 `restartPolicy: Never` 를 넣은 뒤 `kubectl apply -f job.yaml` 하세요.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3          # 총 3번 성공해야 완료
  template:
    spec:
      restartPolicy: Never # 실패해도 같은 Pod 를 재시작하지 않음
      containers:
      - name: work
        image: busybox
        command: ["echo", "work"]
EOF' WHERE quest_set_id = 22 AND order_index = 2;
UPDATE quest SET title='CronJob 으로 주기적으로 실행하기', description='**CronJob** 은 정해진 시각마다 Job 을 만들어 실행합니다(정기 백업, 정리 작업 등). 시각은 cron 형식(`분 시 일 월 요일`)으로 씁니다.

`$NS` 에 5분마다 `echo backup` 을 실행하는 CronJob `backup` 을 `busybox` 이미지로 만드세요.', hint='`kubectl create cronjob <이름> --image=<이미지> --schedule="<cron 식>" -n <네임스페이스> -- <명령>` 입니다. `*/5 * * * *` 는 ''5분마다''를 뜻합니다.', solution='kubectl create cronjob backup --image=busybox --schedule=''*/5 * * * *'' -n $NS -- echo backup

# */5 * * * * : 5분마다 (분 시 일 월 요일)' WHERE quest_set_id = 22 AND order_index = 3;
UPDATE quest SET title='CronJob 일시 중지하기', description='점검 중에 정기 작업이 돌지 않게 하려면 **삭제하지 않고 일시 중지**(suspend)합니다.

`$NS` 의 CronJob `backup` 이 더 이상 실행되지 않도록 일시 중지하세요. 삭제하면 안 됩니다.', hint='`kubectl patch cronjob <이름> -n <네임스페이스> -p ''{"spec":{"suspend":true}}''` 형식입니다. 확인: `kubectl get cronjob backup -n <네임스페이스>` 의 `SUSPEND` 열이 `True` 인지 보세요.', solution='kubectl patch cronjob backup -n $NS -p ''{"spec":{"suspend":true}}''

# 다시 켜려면 suspend 를 false 로 바꿉니다' WHERE quest_set_id = 22 AND order_index = 4;
UPDATE quest SET title='DaemonSet 으로 모든 노드에 하나씩 띄우기', description='**DaemonSet** 은 클러스터의 **모든 노드에 Pod 를 하나씩** 띄웁니다. 로그 수집기, 모니터링 에이전트 같은 노드별 프로그램에 씁니다.

`$NS` 에 `nginx` 를 모든 노드에 하나씩 띄우는 DaemonSet `node-agent` 를 만드세요. (Pod 라벨은 `app: node-agent`)', hint='DaemonSet 은 `kubectl create` 로 만들 수 없어 YAML 이 필요합니다. Deployment YAML 뼈대(`kubectl create deployment ... --dry-run=client -o yaml`)에서 `kind` 를 `DaemonSet` 으로 바꾸고 `replicas` 와 `strategy` 를 지우면 됩니다. `selector.matchLabels` 와 Pod 템플릿의 라벨은 같아야 합니다.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
spec:
  selector:
    matchLabels:
      app: node-agent     # 아래 template 의 라벨과 같아야 함
  template:
    metadata:
      labels:
        app: node-agent
    spec:
      containers:
      - name: agent
        image: nginx
EOF' WHERE quest_set_id = 22 AND order_index = 5;
UPDATE quest SET title='CPU·메모리 requests 와 limits 설정하기', description='**requests** 는 스케줄러가 보장해 주는 최소 자원, **limits** 는 넘어서면 안 되는 최대 자원입니다. 설정하지 않으면 한 Pod 가 노드 자원을 독점할 수 있습니다.

`$NS` 의 `app` Deployment 컨테이너에 아래를 설정하세요.
- requests: CPU `50m`, 메모리 `32Mi`
- limits: CPU `100m`, 메모리 `64Mi`', hint='`kubectl set resources deployment/<이름> -n <네임스페이스> --requests=cpu=50m,memory=32Mi --limits=cpu=100m,memory=64Mi` 한 줄로 됩니다. (`m` 은 1/1000 CPU 단위입니다)', solution='kubectl set resources deployment/app -n $NS \\
  --requests=cpu=50m,memory=32Mi --limits=cpu=100m,memory=64Mi

# 50m = 0.05 CPU' WHERE quest_set_id = 22 AND order_index = 6;
UPDATE quest SET title='livenessProbe 로 컨테이너 상태 점검하기', description='**livenessProbe** 는 컨테이너가 살아 있는지 주기적으로 확인하고, 실패하면 쿠버네티스가 컨테이너를 재시작합니다.

`$NS` 에 `nginx` 이미지의 Pod `probe-pod` 를 만들고, 아래 livenessProbe 를 설정하세요.
- HTTP GET `/` (포트 `80`)
- 시작 5초 뒤부터 확인 (`initialDelaySeconds: 5`)', hint='YAML 의 `spec.containers[]` 아래에 `livenessProbe.httpGet`(`path`, `port`)과 `initialDelaySeconds` 를 씁니다. 뼈대는 `kubectl run probe-pod --image=nginx --dry-run=client -o yaml` 로 만드세요.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: probe-pod
spec:
  containers:
  - name: nginx
    image: nginx
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5   # 시작 5초 뒤부터 점검
EOF' WHERE quest_set_id = 22 AND order_index = 7;
UPDATE quest SET title='nodeSelector 로 배치할 노드 조건 걸기', description='**nodeSelector** 는 특정 라벨이 붙은 노드에만 Pod 를 배치하게 합니다(예: SSD 노드, GPU 노드).

`$NS` 에 `nginx` 이미지의 Pod `ssd-pod` 를 만들되, 노드 라벨 `disktype=ssd` 인 노드에만 배치되도록 `nodeSelector` 를 지정하세요.
(이 환경의 노드에는 해당 라벨이 없어 Pod 가 **Pending** 으로 남는 것이 정상입니다)', hint='`spec.nodeSelector` 아래에 `disktype: ssd` 를 씁니다. 조건에 맞는 노드가 없으면 Pod 는 `Pending` 이고, `kubectl describe pod ssd-pod` 의 Events 에 그 이유가 나옵니다. 한번 읽어 보세요.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ssd-pod
spec:
  nodeSelector:
    disktype: ssd      # 이 라벨이 붙은 노드에만 배치
  containers:
  - name: nginx
    image: nginx
EOF

# Pending 이유 확인
kubectl describe pod ssd-pod -n $NS' WHERE quest_set_id = 22 AND order_index = 8;
UPDATE quest SET title='initContainer 로 사전 작업하기', description='**initContainer** 는 메인 컨테이너가 시작되기 **전에** 먼저 실행되어 끝나야 하는 준비 컨테이너입니다(설정 파일 생성, 의존 서비스 대기 등).

`$NS` 에 Pod `init-pod` 를 만드세요.
- 볼륨: `emptyDir` 볼륨 `work`
- initContainer: 이름 `prep`, 이미지 `busybox`, 명령 `sh -c "echo ready > /work/ready"`, 볼륨을 `/work` 에 마운트
- 메인 컨테이너: 이름 `main`, 이미지 `nginx`, 같은 볼륨을 `/work` 에 마운트', hint='`spec.initContainers` 와 `spec.containers` 는 같은 레벨의 목록입니다. 두 컨테이너 모두 `volumeMounts` 에 `name: work`, `mountPath: /work` 를 넣고, `spec.volumes` 에 `emptyDir: {}` 볼륨을 정의하세요.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  volumes:
  - name: work
    emptyDir: {}
  initContainers:            # 메인보다 먼저 실행되어 끝나야 함
  - name: prep
    image: busybox
    command: ["sh", "-c", "echo ready > /work/ready"]
    volumeMounts:
    - name: work
      mountPath: /work
  containers:
  - name: main
    image: nginx
    volumeMounts:
    - name: work
      mountPath: /work
EOF' WHERE quest_set_id = 22 AND order_index = 9;
UPDATE quest SET title='Pod 자신의 이름을 환경변수로 받기', description='Pod 는 자신의 이름, 네임스페이스, IP 같은 정보를 환경변수로 전달받을 수 있습니다(**Downward API**). 로그에 Pod 이름을 남길 때 유용합니다.

`$NS` 에 `nginx` 이미지의 Pod `env-pod` 를 만들고, 환경변수 `MY_POD` 에 **Pod 자신의 이름**이 들어가게 하세요.', hint='`env` 항목에 값(`value`) 대신 `valueFrom.fieldRef.fieldPath: metadata.name` 을 씁니다. 구조는 `env` → `name: MY_POD` → `valueFrom` → `fieldRef` → `fieldPath` 순서로 들여쓰기가 깊어집니다.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: MY_POD
      valueFrom:
        fieldRef:
          fieldPath: metadata.name   # Pod 자신의 이름
EOF' WHERE quest_set_id = 22 AND order_index = 10;
UPDATE quest SET title='오토스케일러(HPA) 만들기', description='**HPA** 는 부하(CPU 사용률)에 따라 Pod 개수를 자동으로 늘리고 줄입니다.

`$NS` 의 `app` Deployment 가 CPU 사용률 80% 를 기준으로 **최소 1개, 최대 3개** Pod 로 자동 확장되게 HPA 를 만드세요.', hint='`kubectl autoscale deployment <이름> -n <네임스페이스> --min=1 --max=3 --cpu-percent=80` 한 줄이면 됩니다.', solution='kubectl autoscale deployment app -n $NS --min=1 --max=3 --cpu-percent=80

# 확인
kubectl get hpa -n $NS' WHERE quest_set_id = 22 AND order_index = 11;
