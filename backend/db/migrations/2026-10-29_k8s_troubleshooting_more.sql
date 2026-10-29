-- 세트 23(k8s 트러블슈팅 실전)에 시나리오 4개 추가: Liveness 프로브, replicas 0, OOMKilled, 환경변수 누락 (order 9~12). 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 03_quest_set23.sql).
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23,  9, '컨테이너가 계속 재시작될 때: Liveness 프로브 경로 고치기',
   '`$NS` 의 Deployment `live-app` 의 컨테이너가 시작된 직후부터 계속 재시작됩니다. 컨테이너 자체는 정상 실행되는데 쿠버네티스가 스스로 죽이고 있습니다. 원인을 찾아 고치세요.
(`nginx` 는 `/` 경로에서 응답합니다.)

완료 조건: `live-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl get pods -n <ns>` : `RESTARTS` 숫자가 계속 늘어나는지 확인
2) `kubectl describe pod <Pod이름> -n <ns>` 의 Events 에서 `Liveness probe failed: HTTP probe failed with statuscode: 404` 와 `will be restarted` 를 찾습니다.
3) **livenessProbe** 는 컨테이너가 살아 있는지 주기적으로 확인하고, 실패하면 컨테이너를 재시작시킵니다. 확인하는 경로(`livenessProbe.httpGet.path`)가 실제로 응답하는 경로인지 보고 `kubectl edit deployment live-app -n <ns>` 로 고치세요.',
   'kubectl get pods -n $NS                          # RESTARTS 가 계속 증가
kubectl describe pod -l app=live-app -n $NS      # Liveness probe failed ... 404

# 프로브가 확인하는 경로를 실제 응답하는 경로(/)로 수정
kubectl patch deployment live-app -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/"}]''',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: live-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: live-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: live-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: main''; echo ''        image: nginx''; echo ''        livenessProbe:''; echo ''          httpGet:''; echo ''            path: /nope''; echo ''            port: 80''; echo ''          initialDelaySeconds: 1''; echo ''          periodSeconds: 2''; echo ''          failureThreshold: 1''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy live-app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].livenessProbe.httpGet.path}'')\\\" = / ] && kubectl wait --for=condition=Available deployment/live-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23, 10, '서비스가 응답이 없을 때: Pod 가 0개인 Deployment 복구하기',
   '`$NS` 의 Deployment `idle-app` 으로 접속이 안 됩니다. 에러도 없고 Pod 가 죽은 것도 아닌데 응답이 없습니다. 원인을 찾아 **Pod 가 2개 실행**되도록 고치세요.

완료 조건: `idle-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl get deployment idle-app -n <ns>` : `READY` 가 `0/0` 이면 Pod 가 하나도 없습니다.
2) `kubectl get pods -n <ns>` 에 Pod 가 보이지 않는지 확인합니다. 에러가 없는 이유는 ''원하는 개수(replicas)''가 0 이라 쿠버네티스가 할 일이 없기 때문입니다.
3) 복제본 수를 되돌립니다: `kubectl scale deployment/<이름> --replicas=<개수> -n <ns>`',
   'kubectl get deployment idle-app -n $NS          # READY 0/0 → 원하는 Pod 수가 0

# 복제본을 2개로 복구
kubectl scale deployment/idle-app --replicas=2 -n $NS',
   '["sh", "-c", "kubectl create deployment idle-app --image=nginx -n $NS 2>/dev/null; kubectl scale deployment/idle-app --replicas=0 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy idle-app -n $NS -o jsonpath=''{.spec.replicas}'')\\\" = 2 ] && kubectl wait --for=condition=Available deployment/idle-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23, 11, '메모리 제한이 너무 작아 죽는 Pod 고치기 (OOMKilled)',
   '`$NS` 의 Deployment `mem-app` 의 Pod 가 시작하자마자 죽고 다시 시작하기를 반복합니다. 원인을 찾아 고치세요.
(`nginx` 는 메모리 `128Mi` 정도면 충분합니다.)

완료 조건: `mem-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl describe pod <Pod이름> -n <ns>` 의 `Last State` 에서 `Reason: OOMKilled` 를 찾습니다. OOMKilled 는 컨테이너가 **메모리 제한(limits)을 넘어 강제 종료**되었다는 뜻입니다.
2) `limits.memory` 가 너무 작게 설정되어 있습니다. `kubectl set resources deployment/<이름> -n <ns> --limits=memory=<크기>` 로 늘리세요. (`Mi` 는 메비바이트 단위)',
   'kubectl describe pod -l app=mem-app -n $NS      # Last State: Terminated, Reason: OOMKilled

# 메모리 limit 을 충분히 늘림
kubectl set resources deployment/mem-app -n $NS --limits=memory=128Mi',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: mem-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: mem-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: mem-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: main''; echo ''        image: nginx''; echo ''        resources:''; echo ''          limits:''; echo ''            memory: 4Mi''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy mem-app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].resources.limits.memory}'')\\\" != 4Mi ] && kubectl wait --for=condition=Available deployment/mem-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 23, 12, '환경변수가 없어 종료되는 Pod 고치기',
   '`$NS` 의 Deployment `mode-app` 의 Pod 가 시작되자마자 종료되며 재시작을 반복합니다. 로그에서 원인을 찾아 정상 실행되게 고치세요.

완료 조건: `mode-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl logs <Pod이름> -n <ns>` : 앱이 남긴 에러 메시지를 읽습니다. (재시작 직후 비어 있으면 `--previous` 로 직전 컨테이너의 로그를 봅니다)
2) 앱이 필요로 하는 환경변수가 없다는 메시지가 나옵니다. `kubectl set env deployment/<이름> <키>=<값> -n <ns>` 로 환경변수를 추가하세요. (값은 아무거나 괜찮습니다)',
   'kubectl logs -l app=mode-app -n $NS             # ''MODE is required''

# 필요한 환경변수 추가
kubectl set env deployment/mode-app MODE=prod -n $NS',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: mode-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: mode-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: mode-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: main''; echo ''        image: busybox''; echo ''        command: [\\\"sh\\\", \\\"-c\\\", \\\"[ -z $MODE ] && { echo MODE is required; exit 1; }; sleep 3600\\\"]''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "[ -n \\\"$(kubectl get deploy mode-app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[?(@.name==\\\"MODE\\\")].value}'')\\\" ] && kubectl wait --for=condition=Available deployment/mode-app -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 23 AND order_index = 12);
