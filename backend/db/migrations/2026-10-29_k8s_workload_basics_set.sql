-- 세트 22(k8s 워크로드 기본) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set22.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 22, 'k8s 워크로드 기본', 'Job·CronJob, DaemonSet, requests/limits, 프로브, nodeSelector, initContainers, HPA 등 워크로드의 기본 구성 요소를 실습합니다.', 'k8s', 'k8s' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  1, 'Job 만들기',
   '$NS 에 busybox 이미지로 echo hi 를 한 번 실행하는 Job hello-job 을 만드세요.',
   'kubectl create job 이름 --image=이미지 -- 명령 형식입니다. Job 은 끝까지 한 번 실행되고 종료되는 작업용입니다.',
   'kubectl create job hello-job --image=busybox -n $NS -- echo hi',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get job hello-job -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'')\\\" = busybox ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  2, 'Job 완료 횟수 지정하기',
   'Job batch-job 을 만드세요. 이미지 busybox, 명령 echo work, 총 3번 성공해야 완료(completions: 3)되도록 설정하고 restartPolicy 는 Never 로 하세요.',
   'kubectl create job 으로는 completions 를 정할 수 없어 YAML 이 필요합니다. spec.completions 와 spec.template.spec.restartPolicy 를 확인하세요. 뼈대는 --dry-run=client -o yaml 로 만드세요.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 3
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: work
        image: busybox
        command: ["echo", "work"]
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get job batch-job -n $NS -o jsonpath=''{.spec.completions}'')\\\" = 3 ] && [ \\\"$(kubectl get job batch-job -n $NS -o jsonpath=''{.spec.template.spec.restartPolicy}'')\\\" = Never ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  3, 'CronJob 만들기',
   '5분마다 echo backup 을 실행하는 CronJob backup 을 busybox 이미지로 만드세요.',
   'kubectl create cronjob 이름 --image=이미지 --schedule="*/5 * * * *" -- 명령 입니다. 스케줄은 분 시 일 월 요일 순서입니다.',
   'kubectl create cronjob backup --image=busybox --schedule=''*/5 * * * *'' -n $NS -- echo backup',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get cronjob backup -n $NS -o jsonpath=''{.spec.schedule}'')\\\" = ''*/5 * * * *'' ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  4, 'CronJob 일시 중지하기',
   'CronJob backup 이 더 이상 실행되지 않도록 일시 중지(suspend)하세요. 삭제하면 안 됩니다.',
   'kubectl patch cronjob backup -p ''{"spec":{"suspend":true}}'' 형식입니다.',
   'kubectl patch cronjob backup -n $NS -p ''{"spec":{"suspend":true}}''',
   '["sh", "-c", "kubectl create cronjob backup --image=busybox --schedule=''*/5 * * * *'' -n $NS -- echo backup 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get cronjob backup -n $NS -o jsonpath=''{.spec.suspend}'')\\\" = true ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  5, 'DaemonSet 만들기',
   '모든 노드에 하나씩 nginx 를 띄우는 DaemonSet node-agent 를 만드세요.',
   'DaemonSet 은 kubectl create 로 만들 수 없어 YAML 이 필요합니다. Deployment YAML 에서 kind 를 바꾸고 replicas 와 strategy 를 지우면 뼈대가 됩니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
spec:
  selector:
    matchLabels:
      app: node-agent
  template:
    metadata:
      labels:
        app: node-agent
    spec:
      containers:
      - name: agent
        image: nginx
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get daemonset node-agent -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'')\\\" = nginx ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  6, 'CPU·메모리 requests 와 limits 설정하기',
   'Deployment app 의 컨테이너에 requests(cpu 50m, memory 32Mi) 와 limits(cpu 100m, memory 64Mi) 를 설정하세요.',
   'kubectl set resources deployment/이름 --requests=cpu=50m,memory=32Mi --limits=cpu=100m,memory=64Mi 형식입니다.',
   'kubectl set resources deployment/app -n $NS --requests=cpu=50m,memory=32Mi --limits=cpu=100m,memory=64Mi',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].resources.requests.cpu}'')\\\" = 50m ] && [ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].resources.limits.memory}'')\\\" = 64Mi ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  7, 'livenessProbe 설정하기',
   'Pod probe-pod (nginx) 를 만들고 livenessProbe 로 HTTP GET / (포트 80), 시작 5초 뒤부터 확인(initialDelaySeconds: 5) 하도록 설정하세요.',
   'spec.containers[].livenessProbe.httpGet 에 path 와 port 를 쓰고 initialDelaySeconds 를 지정합니다. 실패하면 kubelet 이 컨테이너를 재시작합니다.',
   'kubectl apply -n $NS -f - <<EOF
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
      initialDelaySeconds: 5
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod probe-pod -n $NS -o jsonpath=''{.spec.containers[0].livenessProbe.httpGet.port}'')\\\" = 80 ] && [ \\\"$(kubectl get pod probe-pod -n $NS -o jsonpath=''{.spec.containers[0].livenessProbe.initialDelaySeconds}'')\\\" = 5 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  8, 'nodeSelector 로 배치 조건 걸기',
   'Pod ssd-pod (nginx) 를 만들되 노드 라벨 disktype=ssd 인 노드에만 배치되도록 nodeSelector 를 지정하세요. (이 환경의 노드에는 해당 라벨이 없어 Pending 이 정상입니다.)',
   'spec.nodeSelector 에 키: 값을 씁니다. 조건을 만족하는 노드가 없으면 Pod 는 Pending 이고 kubectl describe pod 의 Events 에 이유가 나옵니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ssd-pod
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx
    image: nginx
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod ssd-pod -n $NS -o jsonpath=''{.spec.nodeSelector.disktype}'')\\\" = ssd ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22,  9, 'initContainer 로 사전 작업하기',
   'Pod init-pod 를 만드세요. initContainer(이름 prep, busybox, 명령 sh -c "echo ready > /work/ready") 가 먼저 emptyDir 볼륨 work(/work 에 마운트)에 파일을 쓰고, 메인 컨테이너(이름 main, nginx)도 같은 볼륨을 /work 에 마운트하세요.',
   'spec.initContainers 는 메인 컨테이너보다 먼저 실행되어 끝나야 합니다. 둘 다 같은 volumeMounts 를 가져야 파일을 공유합니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  volumes:
  - name: work
    emptyDir: {}
  initContainers:
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
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod init-pod -n $NS -o jsonpath=''{.spec.initContainers[0].name}'')\\\" = prep ] && [ \\\"$(kubectl get pod init-pod -n $NS -o jsonpath=''{.spec.containers[0].volumeMounts[0].mountPath}'')\\\" = /work ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22, 10, 'Pod 자신의 이름을 환경변수로 받기',
   'Pod env-pod (nginx) 를 만들고 환경변수 MY_POD 에 Pod 자신의 이름이 들어가도록 downward API(fieldRef) 로 설정하세요.',
   'env 항목에 valueFrom.fieldRef.fieldPath: metadata.name 을 씁니다.',
   'kubectl apply -n $NS -f - <<EOF
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
          fieldPath: metadata.name
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get pod env-pod -n $NS -o jsonpath=''{.spec.containers[0].env[0].name}'')\\\" = MY_POD ] && [ \\\"$(kubectl get pod env-pod -n $NS -o jsonpath=''{.spec.containers[0].env[0].valueFrom.fieldRef.fieldPath}'')\\\" = metadata.name ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 22, 11, '오토스케일러 만들기',
   'Deployment app 이 CPU 사용률 80% 를 기준으로 최소 1개, 최대 3개 Pod 로 자동 확장되게 HPA 를 만드세요.',
   'kubectl autoscale deployment/이름 --min=1 --max=3 --cpu-percent=80 형식입니다.',
   'kubectl autoscale deployment app -n $NS --min=1 --max=3 --cpu-percent=80',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get hpa app -n $NS -o jsonpath=''{.spec.maxReplicas}'')\\\" = 3 ] && [ \\\"$(kubectl get hpa app -n $NS -o jsonpath=''{.spec.minReplicas}'')\\\" = 1 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 22 AND order_index = 11);
