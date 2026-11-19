-- Git 실습 세트 497. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_pod_sts_cron_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 497, 'k8s Pod·StatefulSet·CronJob 설정 손연습: enableServiceLinks, optional 키, hostname·subdomain, Parallel, partition, suspend, schedulerName, activeDeadlineSeconds, exec -i', 'Service 환경 변수 끄기, 선택적 ConfigMap 키, hostname·subdomain, StatefulSet 병렬 생성과 partition 카나리, CronJob 정지와 수동 실행, 없는 스케줄러로 Pending 된 Pod 복구, activeDeadlineSeconds 를 실습합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 497);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 1, 'Service 정보가 환경 변수로 들어오지 않게 하기 (enableServiceLinks)', '**배경** — Pod 가 뜰 때 같은 네임스페이스의 **Service 마다 `이름_SERVICE_HOST`·`_PORT` 같은 환경 변수**가 자동으로 들어갑니다. Service 가 많으면 환경 변수가 수백 개가 되고, 앱 변수와 이름이 겹칠 수도 있습니다. Pod 의 **`enableServiceLinks: false`** 로 이 주입을 끌 수 있습니다(서비스 접속은 DNS 로 하면 됩니다). Service `svc-demo` 가 있습니다.

**문제** — Pod **`nolink`**(`busybox:1.36`, `sleep 3600`)를 만들되 **Service 환경 변수가 주입되지 않게** 하세요. (`env` 에 `SVC_DEMO_` 로 시작하는 변수가 없어야 합니다.)', 'Pod 스펙 최상위에 `enableServiceLinks: false` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: nolink}
spec:
  terminationGracePeriodSeconds: 0
  enableServiceLinks: false
  containers:
  - {name: c, image: "busybox:1.36", command: ["sleep", "3600"]}
EOF
kubectl wait --for=condition=Ready pod/nolink -n $NS --timeout=90s
kubectl exec nolink -n $NS -- env | grep -c SVC_DEMO

# 0 이다. 기본(true)이면 SVC_DEMO_SERVICE_HOST 등이 보인다(KUBERNETES_SERVICE_HOST 는 항상 있다). 이름 풀이는 DNS(svc-demo) 로 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create service clusterip svc-demo -n $NS --tcp=80:80 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod nolink -n $NS -o jsonpath=''{.spec.enableServiceLinks}'' 2>/dev/null)\\" = false ] ) && ( [ \\"$(kubectl exec nolink -n $NS -- env 2>/dev/null | grep -c SVC_DEMO)\\" = 0 ] && kubectl get pod nolink -n $NS >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "enableServiceLinks 가 false 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod nolink -n $NS -o jsonpath=''{.spec.enableServiceLinks}'' 2>/dev/null)\\" = false ]"]}, {"label": "SVC_DEMO 변수가 없다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec nolink -n $NS -- env 2>/dev/null | grep -c SVC_DEMO)\\" = 0 ] && kubectl get pod nolink -n $NS >/dev/null 2>&1"]}]', '[{"title": "Service 환경 변수", "url": "https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 2, '없어도 뜨는 설정 키 (configMapKeyRef optional)', '**배경** — `configMapKeyRef` 로 가리킨 ConfigMap 이나 키가 **없으면 Pod 가 시작하지 못하고** `CreateContainerConfigError` 가 납니다. **`optional: true`** 를 주면 없어도 **환경 변수만 생략하고 Pod 는 정상 시작**합니다. 선택 설정(있으면 쓰고 없으면 기본값)에 씁니다. ConfigMap `none-cm` 은 **존재하지 않습니다**.

**문제** — Pod **`optp`**(`busybox:1.36`, `sleep 3600`)를 만들되 환경 변수 `OPT` 가 ConfigMap `none-cm` 의 키 `k` 를 **선택적으로** 참조하게 하세요. (ConfigMap 이 없어도 Pod 는 **Running** 이어야 합니다.)', '`valueFrom.configMapKeyRef: {name: none-cm, key: k, optional: true}`', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: optp}
spec:
  terminationGracePeriodSeconds: 0
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    env:
    - name: OPT
      valueFrom:
        configMapKeyRef: {name: none-cm, key: k, optional: true}
EOF
kubectl wait --for=condition=Ready pod/optp -n $NS --timeout=90s
kubectl get pod optp -n $NS

# optional 이 없으면 CreateContainerConfigError 로 멈춘다. 이때 OPT 변수는 만들어지지 않는다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cm none-cm -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod optp -n $NS -o jsonpath=''{.spec.containers[0].env[0].valueFrom.configMapKeyRef.optional}'' 2>/dev/null)\\" = true ] ) && ( [ \\"$(kubectl get pod optp -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "optional 이 true 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod optp -n $NS -o jsonpath=''{.spec.containers[0].env[0].valueFrom.configMapKeyRef.optional}'' 2>/dev/null)\\" = true ]"]}, {"label": "Pod 가 Running 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod optp -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ]"]}]', '[{"title": "ConfigMap 을 환경 변수로 (optional)", "url": "https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 3, 'Pod 이름 대신 정해 준 호스트 이름 쓰기 (hostname·subdomain)', '**배경** — Pod 의 호스트 이름은 기본으로 Pod 이름입니다. `spec.hostname` 으로 바꾸고 **`spec.subdomain` 을 같은 이름의 headless Service 와 맞추면** `호스트명.서브도메인.네임스페이스.svc.cluster.local` 이라는 **고정 DNS 이름**이 생깁니다. StatefulSet 이 자동으로 하는 일을 Pod 하나에 직접 하는 셈입니다. headless Service `hs` 가 있습니다.

**문제** — Pod **`hostp`**(`busybox:1.36`, `sleep 3600`)를 호스트 이름 **`app1`**, 서브도메인 **`hs`** 로 만드세요. (`hostname` 명령이 `app1` 을 출력해야 합니다.)', 'Pod 스펙에 `hostname: app1` 과 `subdomain: hs` 를 적어요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: hostp}
spec:
  terminationGracePeriodSeconds: 0
  hostname: app1
  subdomain: hs
  containers:
  - {name: c, image: "busybox:1.36", command: ["sleep", "3600"]}
EOF
kubectl wait --for=condition=Ready pod/hostp -n $NS --timeout=90s
kubectl exec hostp -n $NS -- hostname

# 호스트 이름은 app1. DNS 이름은 app1.hs.<네임스페이스>.svc.cluster.local', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create service clusterip hs -n $NS --clusterip=None --tcp=80:80 >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec hostp -n $NS -- hostname 2>/dev/null)\\" = app1 ] ) && ( [ \\"$(kubectl get pod hostp -n $NS -o jsonpath=''{.spec.subdomain}'' 2>/dev/null)\\" = hs ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "hostname 이 app1 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec hostp -n $NS -- hostname 2>/dev/null)\\" = app1 ]"]}, {"label": "subdomain 이 hs 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod hostp -n $NS -o jsonpath=''{.spec.subdomain}'' 2>/dev/null)\\" = hs ]"]}]', '[{"title": "Pod 의 hostname·subdomain", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-hostname-and-subdomain-fields"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 4, 'Pod 를 한꺼번에 띄우는 StatefulSet (podManagementPolicy: Parallel)', '**배경** — StatefulSet 은 기본(`OrderedReady`)으로 Pod 를 **0번부터 하나씩, 앞 Pod 가 Ready 가 돼야 다음**을 만듭니다. 순서가 필요 없는 상태 저장 앱은 **`podManagementPolicy: Parallel`** 로 **전부 동시에** 올려 시작을 빠르게 합니다. 이 값은 **만든 뒤 바꿀 수 없으므로** 생성할 때 정해야 합니다.

**문제** — StatefulSet **`ss`**(`nginx:1.24`, replicas 3, headless Service `ss` 와 연결)를 **`Parallel`** 정책으로 만들고 3개가 모두 **준비**될 때까지 기다리세요.', 'StatefulSet 스펙에 `podManagementPolicy: Parallel` 을 적어요. (Service `ss` 는 `clusterIP: None`)', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Service
metadata: {name: ss}
spec:
  clusterIP: None
  selector: {app: ss}
  ports: [{port: 80}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: ss}
spec:
  serviceName: ss
  replicas: 3
  podManagementPolicy: Parallel
  selector:
    matchLabels: {app: ss}
  template:
    metadata:
      labels: {app: ss}
    spec:
      terminationGracePeriodSeconds: 0
      containers:
      - {name: web, image: "nginx:1.24"}
EOF
kubectl rollout status sts/ss -n $NS --timeout=120s

# 기본값 OrderedReady 와 달리 ss-0, ss-1, ss-2 가 동시에 만들어진다. 이 필드는 만든 뒤 수정할 수 없다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get sts ss -n $NS -o jsonpath=''{.spec.podManagementPolicy}'' 2>/dev/null)\\" = Parallel ] ) && ( [ \\"$(kubectl get sts ss -n $NS -o jsonpath=''{.status.readyReplicas}'' 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "정책이 Parallel 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get sts ss -n $NS -o jsonpath=''{.spec.podManagementPolicy}'' 2>/dev/null)\\" = Parallel ]"]}, {"label": "3개가 준비됐다", "cmd": ["sh", "-c", "[ \\"$(kubectl get sts ss -n $NS -o jsonpath=''{.status.readyReplicas}'' 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "StatefulSet 병렬 관리", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#parallel-pod-management"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 5, '일부 Pod 만 먼저 새 버전으로 (StatefulSet partition)', '**배경** — StatefulSet 의 `updateStrategy.rollingUpdate.partition` 은 **번호가 partition 이상인 Pod 만** 업데이트하게 합니다. 예를 들어 `partition: 2` 면 3개 중 **`-2` 번만 새 버전**이 되고 나머지는 옛 버전으로 남아, **카나리처럼 일부만 먼저 검증**할 수 있습니다. 검증이 끝나면 partition 을 `0` 으로 내려 전체를 올립니다. StatefulSet `ssp`(`nginx:1.24`, 3개)가 있습니다.

**문제** — `ssp` 의 **partition 을 `2`** 로 정한 뒤 컨테이너 `web` 의 이미지를 **`nginx:1.25`** 로 바꿔, **`ssp-2` 만 `nginx:1.25`** 가 되고 `ssp-0`·`ssp-1` 은 `nginx:1.24` 로 남게 하세요.', '`kubectl patch sts ssp -p ''{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}''` → `kubectl set image sts/ssp web=nginx:1.25` → `ssp-2` 가 Ready 가 될 때까지 대기', 'kubectl patch sts ssp -n $NS -p ''{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}''
kubectl set image sts/ssp web=nginx:1.25 -n $NS
sleep 5
kubectl wait --for=condition=Ready pod/ssp-2 -n $NS --timeout=90s
kubectl get pod -n $NS -l app=ssp -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image

# partition 을 0 으로 내리면 ssp-1, ssp-0 도 차례로 올라간다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - <<''EOF''\\napiVersion: v1\\nkind: Service\\nmetadata: {name: ssp}\\nspec:\\n  clusterIP: None\\n  selector: {app: ssp}\\n  ports: [{port: 80}]\\n---\\napiVersion: apps/v1\\nkind: StatefulSet\\nmetadata: {name: ssp}\\nspec:\\n  serviceName: ssp\\n  replicas: 3\\n  selector:\\n    matchLabels: {app: ssp}\\n  template:\\n    metadata:\\n      labels: {app: ssp}\\n    spec:\\n      terminationGracePeriodSeconds: 0\\n      containers:\\n      - {name: web, image: \\"nginx:1.24\\"}\\nEOF\\nkubectl rollout status sts/ssp -n $NS --timeout=120s >/dev/null 2>&1; sleep 1\\n"]', '["sh", "-c", "( [ \\"$(kubectl get sts ssp -n $NS -o jsonpath=''{.spec.updateStrategy.rollingUpdate.partition}'' 2>/dev/null)\\" = 2 ] ) && ( [ \\"$(kubectl get pod ssp-2 -n $NS -o jsonpath=''{.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.25 ] ) && ( [ \\"$(kubectl get pod ssp-0 -n $NS -o jsonpath=''{.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.24 ] ) && ( [ \\"$(kubectl get pod ssp-1 -n $NS -o jsonpath=''{.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.24 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "partition 이 2 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get sts ssp -n $NS -o jsonpath=''{.spec.updateStrategy.rollingUpdate.partition}'' 2>/dev/null)\\" = 2 ]"]}, {"label": "ssp-2 가 1.25 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod ssp-2 -n $NS -o jsonpath=''{.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.25 ]"]}, {"label": "ssp-0 이 1.24 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod ssp-0 -n $NS -o jsonpath=''{.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.24 ]"]}, {"label": "ssp-1 이 1.24 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod ssp-1 -n $NS -o jsonpath=''{.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.24 ]"]}]', '[{"title": "StatefulSet 롤링 업데이트 partition", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#partitions"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 6, '정기 작업을 멈추고 한 번만 직접 돌리기 (suspend, create job --from)', '**배경** — CronJob 을 지우지 않고 **`spec.suspend: true`** 로 **일시 정지**할 수 있습니다(이미 도는 Job 은 영향 없음). 정지 중에도 **`kubectl create job 이름 --from=cronjob/이름`** 으로 같은 템플릿의 Job 을 **한 번 수동 실행**할 수 있어, 점검 중 정기 실행은 막고 필요할 때만 돌릴 때 씁니다. CronJob `tick`(`* * * * *`)이 있습니다.

**문제** — `tick` 을 **정지**하고, 같은 템플릿으로 **`manual`** 이라는 Job 을 **수동 실행**하세요.', '`kubectl patch cronjob tick -p ''{"spec":{"suspend":true}}''` 와 `kubectl create job manual --from=cronjob/tick`', 'kubectl patch cronjob tick -n $NS -p ''{"spec":{"suspend":true}}''
kubectl create job manual --from=cronjob/tick -n $NS
kubectl get cronjob tick -n $NS
kubectl get job manual -n $NS

# SUSPEND True 이지만 수동 Job 은 실행된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl create cronjob tick -n $NS --image=busybox:1.36 --schedule=''* * * * *'' -- echo tick >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(kubectl get cronjob tick -n $NS -o jsonpath=''{.spec.suspend}'' 2>/dev/null)\\" = true ] ) && ( kubectl get job manual -n $NS >/dev/null 2>&1 ) && ( [ \\"$(kubectl get job manual -n $NS -o jsonpath=''{.metadata.annotations.cronjob\\\\.kubernetes\\\\.io/instantiate}'' 2>/dev/null)\\" = manual ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "suspend 가 true 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get cronjob tick -n $NS -o jsonpath=''{.spec.suspend}'' 2>/dev/null)\\" = true ]"]}, {"label": "manual Job 이 있다", "cmd": ["sh", "-c", "kubectl get job manual -n $NS >/dev/null 2>&1"]}, {"label": "manual Job 이 tick 에서 만들어졌다", "cmd": ["sh", "-c", "[ \\"$(kubectl get job manual -n $NS -o jsonpath=''{.metadata.annotations.cronjob\\\\.kubernetes\\\\.io/instantiate}'' 2>/dev/null)\\" = manual ]"]}]', '[{"title": "CronJob (suspend)", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 7, 'Pending 에서 멈춘 Pod 다시 만들기 (schedulerName)', '**배경** — Pod 의 **`schedulerName`** 은 어느 스케줄러가 배치할지 정합니다. 기본은 `default-scheduler` 이고, **없는 스케줄러 이름**을 적으면 아무도 배치하지 않아 Pod 가 **영원히 `Pending`** 입니다(Events 에도 단서가 거의 없습니다). 이 필드는 **실행 중 Pod 에서 수정할 수 없어** 지우고 다시 만들어야 합니다. Pod `sched` 가 Pending 입니다.

**문제** — `sched`(`nginx:1.25`)를 **기본 스케줄러로 배치되도록** 다시 만들어 **Running** 이 되게 하세요. (이름은 그대로 `sched`.)', '`kubectl get pod sched -o yaml` 로 `schedulerName` 확인 → 지우고 `schedulerName` 없이 다시 만들어요.', 'kubectl get pod sched -n $NS -o jsonpath=''{.spec.schedulerName}''; echo
kubectl delete pod sched -n $NS --grace-period=1
kubectl run sched -n $NS --image=nginx:1.25
kubectl wait --for=condition=Ready pod/sched -n $NS --timeout=90s
kubectl get pod sched -n $NS -o jsonpath=''{.spec.schedulerName}''

# my-scheduler 는 없어서 Pending 이었다. 새로 만든 Pod 는 default-scheduler 로 배치된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: sched}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  schedulerName: my-scheduler\\n  containers:\\n  - {name: web, image: \\"nginx:1.25\\"}\\nEOF\\nsleep 3\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod sched -n $NS -o jsonpath=''{.spec.schedulerName}'' 2>/dev/null)\\" = default-scheduler ] ) && ( [ \\"$(kubectl get pod sched -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "스케줄러가 default-scheduler 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sched -n $NS -o jsonpath=''{.spec.schedulerName}'' 2>/dev/null)\\" = default-scheduler ]"]}, {"label": "Running 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod sched -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Running ]"]}]', '[{"title": "스케줄러 지정", "url": "https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 8, '시간이 지나면 스스로 끝나는 Pod (activeDeadlineSeconds)', '**배경** — Pod 의 **`activeDeadlineSeconds`** 는 Pod 가 **살아 있어도 되는 최대 시간(초)**입니다. 넘으면 쿠버네티스가 컨테이너를 종료하고 Pod 를 **`Failed`**, 이유를 **`DeadlineExceeded`** 로 표시합니다. 끝나지 않는 작업이 자원을 오래 붙잡는 일을 막는 안전장치입니다.

**문제** — Pod **`dl`**(`busybox:1.36`, `sleep 3600`)을 **`activeDeadlineSeconds: 10`** 으로 만들고, **`Failed`(`DeadlineExceeded`)** 가 될 때까지 기다리세요.', 'Pod 스펙에 `activeDeadlineSeconds: 10` 을 적고, 약 10~15초 뒤 `kubectl get pod dl -o jsonpath=''{.status.reason}''` 로 확인해요.', 'kubectl apply -n $NS -f - <<''EOF''
apiVersion: v1
kind: Pod
metadata: {name: dl}
spec:
  terminationGracePeriodSeconds: 0
  activeDeadlineSeconds: 10
  containers:
  - {name: c, image: "busybox:1.36", command: ["sleep", "3600"]}
EOF
kubectl wait --for=jsonpath=''{.status.phase}''=Failed pod/dl -n $NS --timeout=60s
kubectl get pod dl -n $NS -o jsonpath=''{.status.reason}''

# 10초가 지나면 DeadlineExceeded. Job 에도 같은 이름의 필드가 있어 Job 전체에 적용된다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; true\\n"]', '["sh", "-c", "( [ \\"$(kubectl get pod dl -n $NS -o jsonpath=''{.spec.activeDeadlineSeconds}'' 2>/dev/null)\\" = 10 ] ) && ( [ \\"$(kubectl get pod dl -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Failed ] ) && ( [ \\"$(kubectl get pod dl -n $NS -o jsonpath=''{.status.reason}'' 2>/dev/null)\\" = DeadlineExceeded ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "activeDeadlineSeconds 가 10 이다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod dl -n $NS -o jsonpath=''{.spec.activeDeadlineSeconds}'' 2>/dev/null)\\" = 10 ]"]}, {"label": "Failed 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod dl -n $NS -o jsonpath=''{.status.phase}'' 2>/dev/null)\\" = Failed ]"]}, {"label": "이유가 DeadlineExceeded 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get pod dl -n $NS -o jsonpath=''{.status.reason}'' 2>/dev/null)\\" = DeadlineExceeded ]"]}]', '[{"title": "Pod 수명주기 (activeDeadlineSeconds)", "url": "https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 9, '내 컴퓨터 파일을 Pod 안으로 흘려 넣기 (exec -i)', '**배경** — `kubectl exec -i` 는 **표준 입력을 컨테이너 명령에 연결**합니다. `kubectl cp` 가 `tar` 에 의존하는 것과 달리, `tar` 가 없는 이미지에서도 `cat > 파일` 같은 명령으로 **내 컴퓨터의 파일을 Pod 안에 쓸 수** 있습니다. 리다이렉션 `<` 로 파일을 입력에 연결합니다. Pod `st`(`busybox:1.36`)가 떠 있고 `/tmp/lab/in.txt`(내용 `from-host`)가 있습니다.

**문제** — `/tmp/lab/in.txt` 의 내용을 Pod `st` 안의 **`/tmp/in.txt`** 로 보내세요. (Pod 안 `/tmp/in.txt` 가 `from-host` 여야 합니다.)', '`kubectl exec -i st -- sh -c ''cat > /tmp/in.txt'' < /tmp/lab/in.txt`', 'kubectl exec -i st -n $NS -- sh -c ''cat > /tmp/in.txt'' < /tmp/lab/in.txt
kubectl exec st -n $NS -- cat /tmp/in.txt

# -i 가 없으면 표준 입력이 전달되지 않아 빈 파일이 만들어진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; mkdir -p /tmp/lab; kubectl delete sts ss ssp -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cronjob tick -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete job manual -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete pod nolink optp hostp sched dl st -n $NS --ignore-not-found --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete svc hs svc-demo ss -n $NS --ignore-not-found >/dev/null 2>&1; kubectl apply -n $NS -f - <<''EOF''\\napiVersion: v1\\nkind: Pod\\nmetadata: {name: st}\\nspec:\\n  terminationGracePeriodSeconds: 0\\n  containers:\\n  - {name: c, image: \\"busybox:1.36\\", command: [\\"sleep\\", \\"3600\\"]}\\nEOF\\nkubectl wait --for=condition=Ready pod/st -n $NS --timeout=90s\\necho from-host > /tmp/lab/in.txt\\n"]', '["sh", "-c", "( [ \\"$(kubectl exec st -n $NS -- cat /tmp/in.txt 2>/dev/null)\\" = from-host ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Pod 안 파일이 from-host 다", "cmd": ["sh", "-c", "[ \\"$(kubectl exec st -n $NS -- cat /tmp/in.txt 2>/dev/null)\\" = from-host ]"]}]', '[{"title": "kubectl exec", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 10, 'StatefulSet partition 의 쓰임', 'StatefulSet 의 `rollingUpdate.partition: 2` (replicas 3)로 이미지를 바꾸면 어떻게 될까요?', '"번호가 partition 이상인 Pod" 만 대상이에요.', NULL, NULL, '[]', 'choice', '["`-0`, `-1` 만 새 버전이 되고 `-2` 는 남는다", "`-2` 만 새 버전이 되고 나머지는 옛 버전이다", "세 Pod 가 모두 즉시 새 버전이 된다", "아무것도 바뀌지 않고 업데이트가 거부된다"]', 1, 'partition 은 업데이트 대상의 시작 번호입니다. 2 면 번호가 2 이상인 Pod 만 바뀌어 일부만 먼저 검증하는 카나리로 쓸 수 있고, 0 으로 내리면 나머지가 차례로 올라갑니다.', NULL, NULL, NULL, '[{"title": "StatefulSet 롤링 업데이트 partition", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#partitions"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 11, 'Pod 를 한꺼번에 만드는 정책', 'StatefulSet 이 Pod 를 순서 없이 동시에 만들게 하는 설정입니다. 빈칸을 채우세요.', '"병렬" 의 영어예요.', NULL, NULL, '[]', 'fill', '["Parallel", "OrderedReady", "Concurrent", "Async"]', NULL, 'podManagementPolicy 의 값은 OrderedReady(기본, 순서대로)와 Parallel(동시)뿐입니다. 만든 뒤에는 바꿀 수 없습니다. Concurrent·Async 는 이 필드의 값이 아닙니다.', '[0]', 'podManagementPolicy: {0}', NULL, '[{"title": "StatefulSet 병렬 관리", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#parallel-pod-management"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 497, 12, 'CronJob 을 점검 중에 멈추고 한 번만 돌리는 순서', '점검 중 정기 실행은 막고 필요한 만큼만 수동으로 돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '정지 → 수동 실행 → 확인 → 점검 후 재개예요.', NULL, NULL, '[]', 'order', '["`spec.suspend` 를 true 로 패치해 정기 실행을 멈춘다", "`kubectl create job manual --from=cronjob/tick` 으로 한 번 수동 실행한다", "`kubectl get job` 으로 수동 Job 의 완료를 확인한다", "점검이 끝나면 `suspend` 를 false 로 되돌려 정기 실행을 재개한다"]', NULL, 'suspend 는 이후 정기 실행만 막고 이미 도는 Job 은 건드리지 않습니다. 정지 중에도 --from 으로 수동 Job 을 만들 수 있고, 끝나면 suspend 를 false 로 되돌립니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "CronJob (suspend)", "url": "https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 497 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 244 WHERE id = 170;
UPDATE quest_set SET display_order = 245 WHERE id = 299;
UPDATE quest_set SET display_order = 246 WHERE id = 174;
UPDATE quest_set SET display_order = 247 WHERE id = 300;
UPDATE quest_set SET display_order = 248 WHERE id = 178;
UPDATE quest_set SET display_order = 249 WHERE id = 301;
UPDATE quest_set SET display_order = 250 WHERE id = 182;
UPDATE quest_set SET display_order = 251 WHERE id = 302;
UPDATE quest_set SET display_order = 252 WHERE id = 186;
UPDATE quest_set SET display_order = 253 WHERE id = 303;
UPDATE quest_set SET display_order = 254 WHERE id = 484;
UPDATE quest_set SET display_order = 255 WHERE id = 492;
UPDATE quest_set SET display_order = 256 WHERE id = 190;
UPDATE quest_set SET display_order = 257 WHERE id = 304;
UPDATE quest_set SET display_order = 258 WHERE id = 194;
UPDATE quest_set SET display_order = 259 WHERE id = 305;
UPDATE quest_set SET display_order = 260 WHERE id = 198;
UPDATE quest_set SET display_order = 261 WHERE id = 306;
UPDATE quest_set SET display_order = 262 WHERE id = 202;
UPDATE quest_set SET display_order = 263 WHERE id = 307;
UPDATE quest_set SET display_order = 264 WHERE id = 205;
UPDATE quest_set SET display_order = 265 WHERE id = 308;
UPDATE quest_set SET display_order = 266 WHERE id = 482;
UPDATE quest_set SET display_order = 267 WHERE id = 494;
UPDATE quest_set SET display_order = 269 WHERE id = 208;
UPDATE quest_set SET display_order = 270 WHERE id = 309;
UPDATE quest_set SET display_order = 271 WHERE id = 211;
UPDATE quest_set SET display_order = 272 WHERE id = 310;
UPDATE quest_set SET display_order = 273 WHERE id = 214;
UPDATE quest_set SET display_order = 274 WHERE id = 311;
UPDATE quest_set SET display_order = 275 WHERE id = 217;
UPDATE quest_set SET display_order = 276 WHERE id = 312;
UPDATE quest_set SET display_order = 277 WHERE id = 220;
UPDATE quest_set SET display_order = 278 WHERE id = 313;
UPDATE quest_set SET display_order = 279 WHERE id = 483;
UPDATE quest_set SET display_order = 280 WHERE id = 493;
UPDATE quest_set SET display_order = 281 WHERE id = 496;
UPDATE quest_set SET display_order = 282 WHERE id = 223;
UPDATE quest_set SET display_order = 283 WHERE id = 314;
UPDATE quest_set SET display_order = 284 WHERE id = 12;
UPDATE quest_set SET display_order = 285 WHERE id = 22;
UPDATE quest_set SET display_order = 286 WHERE id = 236;
UPDATE quest_set SET display_order = 287 WHERE id = 351;
UPDATE quest_set SET display_order = 288 WHERE id = 375;
UPDATE quest_set SET display_order = 289 WHERE id = 383;
UPDATE quest_set SET display_order = 290 WHERE id = 420;
UPDATE quest_set SET display_order = 291 WHERE id = 421;
UPDATE quest_set SET display_order = 294 WHERE id = 80;
UPDATE quest_set SET display_order = 295 WHERE id = 13;
UPDATE quest_set SET display_order = 296 WHERE id = 122;
UPDATE quest_set SET display_order = 297 WHERE id = 25;
UPDATE quest_set SET display_order = 298 WHERE id = 108;
UPDATE quest_set SET display_order = 299 WHERE id = 37;
UPDATE quest_set SET display_order = 300 WHERE id = 26;
UPDATE quest_set SET display_order = 301 WHERE id = 348;
UPDATE quest_set SET display_order = 302 WHERE id = 422;
UPDATE quest_set SET display_order = 303 WHERE id = 489;
UPDATE quest_set SET display_order = 305 WHERE id = 23;
UPDATE quest_set SET display_order = 306 WHERE id = 31;
UPDATE quest_set SET display_order = 307 WHERE id = 29;
UPDATE quest_set SET display_order = 308 WHERE id = 227;
UPDATE quest_set SET display_order = 309 WHERE id = 230;
UPDATE quest_set SET display_order = 310 WHERE id = 233;
UPDATE quest_set SET display_order = 311 WHERE id = 339;
UPDATE quest_set SET display_order = 312 WHERE id = 345;
UPDATE quest_set SET display_order = 313 WHERE id = 423;
UPDATE quest_set SET display_order = 314 WHERE id = 425;
UPDATE quest_set SET display_order = 315 WHERE id = 119;
UPDATE quest_set SET display_order = 316 WHERE id = 120;
UPDATE quest_set SET display_order = 317 WHERE id = 121;
UPDATE quest_set SET display_order = 318 WHERE id = 424;
UPDATE quest_set SET display_order = 319 WHERE id = 14;
UPDATE quest_set SET display_order = 242, unit_id = (SELECT id FROM unit WHERE id = 61), icon = '🕹️' WHERE id = 497;
