-- 세트 12: k8s ConfigMap과 Secret (order 1~8)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (12, 1, 'ConfigMap 생성하기',
   '$NS 네임스페이스에 app-config 이름의 ConfigMap을 생성하세요. APP_ENV=production, APP_PORT=8080 두 값을 포함해야 합니다.',
   'kubectl create configmap <name> --from-literal=<key>=<value> -n <namespace> 형식을 사용합니다.',
   'kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS',
   NULL,
   '["sh", "-c", "kubectl get configmap app-config -n $NS -o jsonpath=''{.data.APP_ENV}'' | grep -q production"]'),

  (12, 2, 'ConfigMap 내용 확인하기',
   '$NS 네임스페이스의 app-config ConfigMap 전체 내용을 확인하고 /tmp/cm_result.txt 에 저장하세요.',
   'kubectl get configmap <name> -n <namespace> -o yaml 로 전체 내용을 확인합니다.',
   'kubectl get configmap app-config -n $NS -o yaml > /tmp/cm_result.txt',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''APP_ENV'' /tmp/cm_result.txt"]'),

  (12, 3, 'ConfigMap을 환경변수로 Pod에 주입하기',
   'app-config ConfigMap의 값을 환경변수로 주입한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 cm-pod, 이미지는 nginx 로 하세요.',
   'envFrom.configMapRef 를 사용하면 ConfigMap 전체를 환경변수로 주입할 수 있습니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cm-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod cm-pod -n $NS | grep -q cm-pod"]'),

  (12, 4, 'ConfigMap을 볼륨으로 마운트하기',
   'app-config ConfigMap을 /etc/config 경로에 볼륨으로 마운트한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 cm-vol-pod 로 하세요.',
   'volumes.configMap 과 volumeMounts 를 함께 사용합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cm-vol-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod cm-vol-pod -n $NS | grep -q cm-vol-pod"]'),

  (12, 5, 'Secret 생성하기',
   '$NS 네임스페이스에 db-secret 이름의 Secret을 생성하세요. DB_USER=admin, DB_PASSWORD=s3cur3 두 값을 포함해야 합니다.',
   'kubectl create secret generic <name> --from-literal=<key>=<value> -n <namespace> 형식을 사용합니다. Secret은 base64로 인코딩되어 저장됩니다.',
   'kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS',
   NULL,
   '["sh", "-c", "kubectl get secret db-secret -n $NS | grep -q db-secret"]'),

  (12, 6, 'Secret 값 확인하기',
   '$NS 네임스페이스의 db-secret 에서 DB_USER 값을 디코딩해서 /tmp/secret_result.txt 에 저장하세요.',
   'kubectl get secret <name> -n <namespace> -o jsonpath=''{.data.DB_USER}'' 로 값을 꺼낸 뒤 base64 --decode 로 디코딩합니다.',
   'kubectl get secret db-secret -n $NS -o jsonpath=''{.data.DB_USER}'' | base64 --decode > /tmp/secret_result.txt',
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''admin'' /tmp/secret_result.txt"]'),

  (12, 7, 'Secret을 환경변수로 Pod에 주입하기',
   'db-secret 의 DB_USER, DB_PASSWORD 를 환경변수로 주입한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 secret-pod 로 하세요.',
   'env.valueFrom.secretKeyRef 를 사용해서 Secret의 특정 키를 환경변수로 주입합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASSWORD
EOF',
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod secret-pod -n $NS | grep -q secret-pod"]'),

  (12, 8, 'ConfigMap과 Secret 함께 사용하기',
   'app-config ConfigMap과 db-secret Secret을 모두 환경변수로 주입한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 full-pod 로 하세요.',
   'envFrom 에 configMapRef 와 secretRef 를 함께 나열할 수 있습니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: full-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: db-secret
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod full-pod -n $NS | grep -q full-pod"]');
