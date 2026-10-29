-- 세트 23: k8s 트러블슈팅 실전 (order 1~8)
-- 장애는 setup_cmd 가 Deployment 로 만든다 (고칠 수 있도록). 이미지는 노드에 캐시된 nginx/busybox 만 쓴다. 채점은 spec 확인 + 상한 있는 wait 로 한다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (23,  1, 'Pod 가 시작되지 않을 때: 이미지 이름 오타 고치기',
   '`$NS` 네임스페이스의 Deployment `web` 이 배포됐는데 Pod 가 시작되지 않습니다. 원인을 찾아 고치세요.
(올바른 이미지는 `nginx` 입니다.)

완료 조건: `web` Deployment 가 정상 실행(Available)되어야 합니다.',
   '조사 순서입니다.
1) `kubectl get pods -n <ns>` : 상태가 `ErrImagePull` / `ImagePullBackOff` 인지 확인
2) `kubectl describe pod <Pod이름> -n <ns>` : 아래쪽 Events 에서 이미지를 못 받는 이유 확인
3) 이미지 이름이 틀렸으면 `kubectl set image deployment/web <컨테이너이름>=<올바른이미지> -n <ns>`
(컨테이너 이름은 `kubectl get deployment web -n <ns> -o yaml` 에서 확인할 수 있습니다)',
   '# 1) 증상 확인: ImagePullBackOff
kubectl get pods -n $NS
# 2) 원인 확인: Events 의 ''Failed to pull image''
kubectl describe pod -l app=web -n $NS
# 3) 이미지 이름 수정 (컨테이너이름=올바른이미지)
kubectl set image deployment/web ngnix=nginx -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=ngnix -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'')\\" = nginx ] && kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s"]'),

  (23,  2, 'Service 로 접속이 안 될 때: 셀렉터 불일치 고치기',
   '`$NS` 의 Service `api-svc` 로 요청이 가지 않습니다. `api` Deployment 의 Pod 는 정상 실행 중인데 Service 가 연결되지 않습니다.

원인을 찾아 `api-svc` 가 `api` Deployment 의 Pod 로 연결되게 고치세요.

완료 조건: `kubectl get endpoints api-svc` 에 Pod IP 가 나와야 합니다.',
   '1) `kubectl get endpoints api-svc -n <ns>` : `ENDPOINTS` 가 `<none>` 이면 Service 가 Pod 를 못 찾는 것입니다.
2) Service 가 찾는 라벨: `kubectl describe svc api-svc -n <ns>` 의 `Selector`
3) Pod 의 실제 라벨: `kubectl get pods -n <ns> --show-labels`
4) 둘이 다르면 Service 의 셀렉터를 고칩니다: `kubectl patch service api-svc -n <ns> -p ''{"spec":{"selector":{"<키>":"<값>"}}}''`',
   'kubectl get endpoints api-svc -n $NS          # <none> 이면 연결 안 됨
kubectl describe svc api-svc -n $NS            # Selector: app=apii (오타)
kubectl get pods -n $NS --show-labels          # Pod 라벨: app=api

# 셀렉터를 Pod 라벨에 맞게 수정
kubectl patch service api-svc -n $NS -p ''{"spec":{"selector":{"app":"api"}}}''',
   '["sh", "-c", "kubectl create deployment api --image=nginx -n $NS 2>/dev/null; kubectl create service clusterip api-svc --tcp=80:80 -n $NS 2>/dev/null; kubectl patch service api-svc -n $NS -p ''{\\"spec\\":{\\"selector\\":{\\"app\\":\\"apii\\"}}}'' 2>/dev/null; kubectl wait --for=condition=Available deployment/api -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get svc api-svc -n $NS -o jsonpath=''{.spec.selector.app}'')\\" = api ] && for i in $(seq 1 30); do [ -n \\"$(kubectl get endpoints api-svc -n $NS -o jsonpath=''{.subsets[0].addresses[0].ip}'')\\" ] && exit 0; sleep 2; done; exit 1"]'),

  (23,  3, '계속 재시작하는 Pod 고치기 (CrashLoopBackOff)',
   '`$NS` 의 Deployment `crash` 의 Pod 가 시작되자마자 종료되며 계속 재시작합니다(`CrashLoopBackOff`). 원인을 찾아 정상적으로 Running 이 되게 고치세요.
(이 컨테이너는 `sleep 3600` 을 실행해야 합니다.)

완료 조건: `crash` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl get pods -n <ns>` : `CrashLoopBackOff` 확인
2) `kubectl logs <Pod이름> -n <ns>` : 컨테이너가 남긴 에러 메시지 (명령이 잘못되면 사용법 오류가 나옵니다)
3) `kubectl describe pod <Pod이름> -n <ns>` : Exit Code 와 재시작 횟수
4) 실행 명령을 고칩니다: `kubectl edit deployment crash -n <ns>` 에서 `command` 를 수정하거나 `kubectl patch` 를 씁니다.',
   'kubectl logs -l app=crash -n $NS      # ''sleep: missing operand'' 같은 사용법 오류

# command 를 올바르게 교체
kubectl patch deployment crash -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/command","value":["sleep","3600"]}]''',
   '["sh", "-c", "kubectl create deployment crash --image=busybox -n $NS -- sleep 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/crash -n $NS --timeout=90s"]'),

  (23,  4, 'Pending 에서 넘어가지 않는 Pod 고치기',
   '`$NS` 의 Deployment `bigmem` 의 Pod 가 `Pending` 에서 넘어가지 않습니다. 원인을 찾아 실행되게 고치세요.
(`nginx` 는 메모리 `32Mi` 면 충분합니다.)

완료 조건: `bigmem` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl describe pod <Pod이름> -n <ns>` 의 Events 를 보세요. `Insufficient memory`(메모리 부족) 같은 스케줄링 실패 이유가 나옵니다.
2) Pod 가 요청(requests)한 메모리가 노드가 가진 양보다 큽니다. 요청을 적당히 줄이세요: `kubectl set resources deployment/bigmem -n <ns> --requests=memory=32Mi`',
   'kubectl describe pod -l app=bigmem -n $NS   # Insufficient memory

# 요청 메모리를 현실적인 값으로
kubectl set resources deployment/bigmem -n $NS --requests=memory=32Mi',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: bigmem''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: bigmem''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: bigmem''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        resources:''; echo ''          requests:''; echo ''            memory: 100Gi''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/bigmem -n $NS --timeout=90s"]'),

  (23,  5, 'ConfigMap 키 오타로 시작하지 못하는 Pod 고치기',
   '`$NS` 의 Deployment `cfg-app` 의 Pod 가 시작되지 않습니다(`CreateContainerConfigError`). ConfigMap `app-cfg` 에는 `APP_MODE` 키가 있습니다.

원인을 찾아 정상 실행되게 고치세요.

완료 조건: `cfg-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl describe pod <Pod이름> -n <ns>` 의 Events 에 `couldn''t find key ...` 가 나옵니다.
2) ConfigMap 의 실제 키: `kubectl get configmap app-cfg -n <ns> -o yaml`
3) Deployment 가 참조하는 키: `kubectl get deployment cfg-app -n <ns> -o yaml` 의 `configMapKeyRef.key`
4) 둘을 비교해 오타를 고치세요 (`kubectl edit deployment cfg-app -n <ns>`).',
   'kubectl describe pod -l app=cfg-app -n $NS    # couldn''t find key APP_MODEE
kubectl get configmap app-cfg -n $NS -o yaml  # 실제 키: APP_MODE

# Deployment 가 참조하는 키를 고침
kubectl patch deployment cfg-app -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/key","value":"APP_MODE"}]''',
   '["sh", "-c", "kubectl create configmap app-cfg --from-literal=APP_MODE=prod -n $NS 2>/dev/null; { echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: cfg-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: cfg-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: cfg-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        env:''; echo ''        - name: MODE''; echo ''          valueFrom:''; echo ''            configMapKeyRef:''; echo ''              name: app-cfg''; echo ''              key: APP_MODEE''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/cfg-app -n $NS --timeout=90s"]'),

  (23,  6, 'Ready 가 되지 않는 Pod 고치기 (Readiness 실패)',
   '`$NS` 의 Deployment `health-app` 의 Pod 가 `Running` 인데 `READY` 가 `0/1` 이라 서비스에 연결되지 않고 Available 도 되지 않습니다. 원인을 찾아 고치세요.

완료 조건: `health-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl describe pod <Pod이름> -n <ns>` 의 Events 에 `Readiness probe failed: HTTP probe failed with statuscode: 404` 가 보입니다.
2) 프로브가 확인하는 경로(`readinessProbe.httpGet.path`)가 실제로 응답하는 경로가 아닙니다. nginx 의 기본 경로는 `/` 입니다.
3) `kubectl edit deployment health-app -n <ns>` 에서 경로를 고치세요.',
   'kubectl describe pod -l app=health-app -n $NS   # Readiness probe failed ... 404

# 프로브 경로를 실제 응답하는 경로(/)로 수정
kubectl patch deployment health-app -n $NS --type=json -p ''[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]''',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: health-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: health-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: health-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        readinessProbe:''; echo ''          httpGet:''; echo ''            path: /healthz''; echo ''            port: 80''; echo ''          periodSeconds: 2''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/health-app -n $NS --timeout=90s"]'),

  (23,  7, 'Service 포트가 틀려 연결이 안 되는 문제 고치기',
   '`$NS` 의 Service `api2-svc` 는 `80` 포트로 요청을 받아 Pod 로 넘기는데 연결이 되지 않습니다. `nginx` 는 `80` 포트에서 응답합니다.

원인을 찾아 고치세요.

완료 조건: Service 의 `targetPort` 가 `80` 이어야 합니다.',
   'Service 에는 두 가지 포트가 있습니다. `port` 는 Service 가 **받는** 포트이고 `targetPort` 는 요청을 Pod 로 **넘기는** 포트입니다.
1) `kubectl describe svc api2-svc -n <ns>` 의 `TargetPort`
2) 컨테이너가 실제로 여는 포트(nginx 는 80)와 비교
3) `kubectl patch service api2-svc -n <ns> --type=json -p ''[{"op":"replace","path":"/spec/ports/0/targetPort","value":<포트>}]''`',
   'kubectl describe svc api2-svc -n $NS    # TargetPort: 8080 (nginx 는 80 에서 응답)

kubectl patch service api2-svc -n $NS --type=json -p ''[{"op":"replace","path":"/spec/ports/0/targetPort","value":80}]''',
   '["sh", "-c", "kubectl create deployment api2 --image=nginx -n $NS 2>/dev/null; kubectl create service clusterip api2-svc --tcp=80:8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get svc api2-svc -n $NS -o jsonpath=''{.spec.ports[0].targetPort}'')\\" = 80 ]"]'),

  (23,  8, '없는 Secret 을 참조하는 Pod 고치기',
   '`$NS` 의 Deployment `db-app` 의 Pod 가 시작되지 않습니다. 원인을 찾아, 필요한 Secret 을 만들어 정상 실행되게 하세요.
(필요한 Secret 은 이름 `db-pass`, 키 `PASS` 이고 값은 아무거나 괜찮습니다.)

완료 조건: `db-app` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl describe pod <Pod이름> -n <ns>` 의 Events 에 `secret "db-pass" not found` 가 나옵니다.
2) Secret 을 만듭니다: `kubectl create secret generic db-pass --from-literal=PASS=<값> -n <ns>`
3) 만들면 kubelet 이 자동으로 다시 시도해 Pod 가 시작됩니다 (몇 초 걸립니다).',
   'kubectl describe pod -l app=db-app -n $NS    # secret "db-pass" not found

kubectl create secret generic db-pass --from-literal=PASS=s3cret -n $NS',
   '["sh", "-c", "{ echo ''apiVersion: apps/v1''; echo ''kind: Deployment''; echo ''metadata:''; echo ''  name: db-app''; echo ''spec:''; echo ''  replicas: 1''; echo ''  selector:''; echo ''    matchLabels:''; echo ''      app: db-app''; echo ''  template:''; echo ''    metadata:''; echo ''      labels:''; echo ''        app: db-app''; echo ''    spec:''; echo ''      containers:''; echo ''      - name: nginx''; echo ''        image: nginx''; echo ''        envFrom:''; echo ''        - secretRef:''; echo ''            name: db-pass''; } | kubectl apply -n $NS -f - 2>/dev/null; true"]',
   '["sh", "-c", "kubectl wait --for=condition=Available deployment/db-app -n $NS --timeout=90s"]');
