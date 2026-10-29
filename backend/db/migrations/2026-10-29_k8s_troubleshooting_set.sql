-- 세트 23(k8s 트러블슈팅 실전) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set23.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 23, 'k8s 트러블슈팅 실전', '깨진 워크로드의 원인을 describe·logs·events 로 찾아 직접 고칩니다. 이미지 오타, 셀렉터·포트 불일치, CrashLoopBackOff, Pending, 설정 참조 오류 등.', 'k8s', 'k8s' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  1, '이미지 이름 오타 고치기',
   '$NS 의 Deployment web 의 Pod 가 시작되지 않습니다. 원인을 찾아 정상적으로 실행되게 고치세요. (이미지는 nginx 입니다.)',
   'kubectl get pods 로 상태(ImagePullBackOff)를 보고, kubectl describe pod 의 Events 에서 이유를 찾으세요. kubectl set image deployment/web 컨테이너이름=이미지 로 고칩니다.',
   'kubectl set image deployment/web ngnix=nginx -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=ngnix -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'')\\\" = nginx ] && kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  2, 'Service 로 접속이 안 되는 이유 찾기',
   '$NS 의 Service api-svc 로 요청이 가지 않습니다 (엔드포인트가 비어 있음). 원인을 찾아 api-svc 가 Deployment api 의 Pod 로 연결되게 고치세요.',
   'kubectl get endpoints api-svc 가 비어 있으면 Service 의 selector 가 Pod 의 라벨과 맞지 않는 것입니다. kubectl get pods --show-labels 와 kubectl describe svc api-svc 를 비교하세요.',
   'kubectl patch service api-svc -n $NS -p ''{"spec":{"selector":{"app":"api"}}}''',
   '["sh", "-c", "kubectl create deployment api --image=nginx -n $NS 2>/dev/null; kubectl create service clusterip api-svc --tcp=80:80 -n $NS 2>/dev/null; kubectl patch service api-svc -n $NS -p ''{\\\"spec\\\":{\\\"selector\\\":{\\\"app\\\":\\\"apii\\\"}}}'' 2>/dev/null; kubectl wait --for=condition=Available deployment/api -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get svc api-svc -n $NS -o jsonpath=''{.spec.selector.app}'')\\\" = api ] && for i in $(seq 1 30); do [ -n \\\"$(kubectl get endpoints api-svc -n $NS -o jsonpath=''{.subsets[0].addresses[0].ip}'')\\\" ] && exit 0; sleep 2; done; exit 1"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  3, '계속 재시작하는 Pod 고치기',
   '$NS 의 Deployment crash 의 Pod 가 계속 재시작(CrashLoopBackOff)합니다. 로그와 describe 로 원인을 찾아 정상적으로 Running 이 되게 고치세요. (컨테이너는 sleep 3600 을 실행해야 합니다.)',
   'kubectl logs 와 kubectl describe pod 를 보세요. 명령이 잘못되어 컨테이너가 바로 종료되고 있습니다. kubectl edit deployment crash 또는 kubectl patch 로 command 를 고칩니다.',
   'kubectl patch deployment crash -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/command","value":["sleep","3600"]}]''',
   '["sh", "-c", "kubectl create deployment crash --image=busybox -n $NS -- sleep 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/crash -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  4, 'Pending 에서 안 넘어가는 Pod 고치기',
   '$NS 의 Deployment bigmem 의 Pod 가 Pending 에서 넘어가지 않습니다. 원인을 찾아 실행되게 고치세요. (nginx 는 메모리 32Mi 면 충분합니다.)',
   'kubectl describe pod 의 Events 에 Insufficient memory 같은 스케줄링 실패 이유가 나옵니다. 요청(requests)이 노드가 가진 것보다 큽니다. kubectl set resources 로 고칩니다.',
   'kubectl set resources deployment/bigmem -n $NS --requests=memory=32Mi',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: bigmem''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: bigmem''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: bigmem''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        resources:''; echo ''          requests:''; echo ''            memory: 100Gi''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/bigmem -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  5, 'ConfigMap 키 오타로 시작 못 하는 Pod 고치기',
   '$NS 의 Deployment cfg-app 의 Pod 가 시작되지 않습니다(CreateContainerConfigError). ConfigMap app-cfg 에는 APP_MODE 키가 있습니다. 원인을 찾아 정상 실행되게 고치세요.',
   'kubectl describe pod 의 Events 에 couldn''t find key 가 나옵니다. Deployment 가 참조하는 키 이름과 ConfigMap 의 실제 키를 비교하세요 (kubectl get cm app-cfg -o yaml).',
   'kubectl patch deployment cfg-app -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/key","value":"APP_MODE"}]''',
   '["sh", "-c", "kubectl create configmap app-cfg --from-literal=APP_MODE=prod -n $NS 2>/dev/null; { echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: cfg-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: cfg-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: cfg-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        env:''; echo ''        - name: MODE''; echo ''          valueFrom:''; echo ''            configMapKeyRef:''; echo ''              name: app-cfg''; echo ''              key: APP_MODEE''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/cfg-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  6, 'Ready 가 되지 않는 Pod 고치기',
   '$NS 의 Deployment health-app 의 Pod 가 Running 인데 Ready(1/1)가 되지 않아 Available 이 되지 않습니다. 원인을 찾아 고치세요.',
   'kubectl describe pod 의 Events 에 Readiness probe failed: HTTP probe failed with statuscode: 404 가 보입니다. 프로브가 확인하는 경로가 실제로 응답하는 경로인지 보세요. nginx 의 기본 경로는 / 입니다.',
   'kubectl patch deployment health-app -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]''',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: health-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: health-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: health-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        readinessProbe:''; echo ''          httpGet:''; echo ''            path: /healthz''; echo ''            port: 80''; echo ''          periodSeconds: 2''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/health-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  7, 'Service 포트가 틀려 연결이 안 되는 문제 고치기',
   '$NS 의 Service api2-svc 는 80 포트로 받아서 Pod 로 넘기는데 연결이 되지 않습니다. nginx 는 80 포트에서 응답합니다. 원인을 찾아 고치세요.',
   'kubectl describe svc api2-svc 의 TargetPort 와 컨테이너가 실제로 열고 있는 포트를 비교하세요. Service 의 port 는 받는 포트, targetPort 는 Pod 로 넘기는 포트입니다.',
   'kubectl patch service api2-svc -n $NS --type=json -p ''[{"op":"replace","path":"/spec/ports/0/targetPort","value":80}]''',
   '["sh", "-c", "kubectl create deployment api2 --image=nginx -n $NS 2>/dev/null; kubectl create service clusterip api2-svc --tcp=80:8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get svc api2-svc -n $NS -o jsonpath=''{.spec.ports[0].targetPort}'')\\\" = 80 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  8, '없는 Secret 을 참조하는 Pod 고치기',
   '$NS 의 Deployment db-app 의 Pod 가 시작되지 않습니다. 원인을 찾아, 필요한 Secret db-pass (키 PASS, 값 임의)를 만들어 정상 실행되게 하세요.',
   'kubectl describe pod 의 Events 에 secret "db-pass" not found 가 나옵니다. kubectl create secret generic db-pass --from-literal=PASS=값 으로 만들면 kubelet 이 자동으로 다시 시도합니다.',
   'kubectl create secret generic db-pass --from-literal=PASS=s3cret -n $NS',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: db-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: db-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: db-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        envFrom:''; echo ''        - secretRef:''; echo ''            name: db-pass''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/db-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 8);
