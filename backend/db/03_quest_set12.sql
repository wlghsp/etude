-- 세트 12: k8s ConfigMap과 Secret (order 1~8)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (12,  1, 'ConfigMap 만들기',
   '**ConfigMap** 은 이미지를 다시 빌드하지 않고도 바꿀 수 있는 **설정값**(환경, 포트 등)을 따로 보관하는 리소스입니다. 같은 이미지를 개발·운영에서 다른 설정으로 쓸 수 있게 해 줍니다.

`$NS` 네임스페이스에 `app-config` 이름의 ConfigMap 을 만드세요. 아래 두 값이 들어가야 합니다.
- `APP_ENV=production`
- `APP_PORT=8080`',
   '`kubectl create configmap <이름> --from-literal=<키>=<값> -n <네임스페이스>` 형식입니다. `--from-literal` 은 ''파일이 아니라 직접 적은 값에서''라는 뜻이며, 값마다 한 번씩 반복해서 씁니다.',
   'kubectl create configmap app-config \\
  --from-literal=APP_ENV=production \\
  --from-literal=APP_PORT=8080 -n $NS

# --from-literal 키=값 : 값을 직접 지정 (여러 번 반복 가능)',
   NULL,
   '["sh", "-c", "kubectl get configmap app-config -n $NS -o jsonpath=''{.data.APP_ENV}'' | grep -q production"]'),

  (12,  2, 'ConfigMap 내용 확인하기',
   'ConfigMap 이 의도한 값으로 만들어졌는지 YAML 로 확인합니다.

`$NS` 네임스페이스의 `app-config` ConfigMap 의 **전체 내용**을 `/tmp/cm_result.txt` 에 저장하세요.',
   '`kubectl get configmap <이름> -n <네임스페이스> -o yaml` 입니다. `-o yaml` 은 출력 형식을 YAML 로 하는 옵션입니다. 결과를 `>` 로 저장하세요.',
   'kubectl get configmap app-config -n $NS -o yaml > /tmp/cm_result.txt

# -o yaml : 리소스 전체를 YAML 로 출력',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''APP_ENV'' /tmp/cm_result.txt"]'),

  (12,  3, 'ConfigMap 을 환경변수로 Pod 에 주입하기',
   '앱은 보통 설정을 **환경변수**로 읽습니다. ConfigMap 의 값을 Pod 의 환경변수로 넣는 가장 흔한 방법입니다.

`app-config` ConfigMap 의 모든 값을 환경변수로 주입한 Pod 를 `$NS` 네임스페이스에 만드세요. Pod 이름은 `cm-pod`, 이미지는 `nginx` 입니다.',
   'YAML 의 컨테이너 항목에 `envFrom` 을 쓰고, 그 아래 `configMapRef.name` 에 ConfigMap 이름을 적으면 **ConfigMap 의 모든 키**가 환경변수가 됩니다. 구조: `containers` → `envFrom` → `- configMapRef` → `name: app-config`',
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
    envFrom:             # ConfigMap 전체를 환경변수로
    - configMapRef:
        name: app-config
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod cm-pod -n $NS | grep -q cm-pod"]'),

  (12,  4, 'ConfigMap 을 파일(볼륨)로 마운트하기',
   '설정 파일 형태로 앱에 넘기고 싶을 때는 ConfigMap 을 **볼륨**으로 마운트합니다. 키 이름이 파일 이름, 값이 파일 내용이 됩니다.

`app-config` ConfigMap 을 컨테이너의 `/etc/config` 경로에 볼륨으로 마운트한 Pod 를 `$NS` 네임스페이스에 만드세요. Pod 이름은 `cm-vol-pod` 입니다.',
   '두 곳을 함께 씁니다.
- `spec.volumes` : 볼륨 정의 — `configMap.name` 으로 어느 ConfigMap 인지 지정
- `containers[].volumeMounts` : 그 볼륨을 컨테이너의 어느 경로(`mountPath`)에 붙일지 지정
두 곳의 볼륨 `name` 이 같아야 연결됩니다.',
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
    - name: config-vol     # 아래 volumes 의 이름과 같아야 함
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod cm-vol-pod -n $NS | grep -q cm-vol-pod"]'),

  (12,  5, 'Secret 만들기',
   '**Secret** 은 비밀번호, 토큰처럼 민감한 값을 보관하는 리소스입니다. ConfigMap 과 쓰임새는 같지만 값이 base64 로 저장되고 접근 권한을 따로 관리할 수 있습니다. (base64 는 암호화가 아니라 인코딩이므로 권한 관리가 중요합니다)

`$NS` 네임스페이스에 `db-secret` 이름의 Secret 을 만드세요. 아래 두 값이 들어가야 합니다.
- `DB_USER=admin`
- `DB_PASSWORD=s3cur3`',
   '`kubectl create secret generic <이름> --from-literal=<키>=<값> -n <네임스페이스>` 형식입니다. `generic` 은 일반 용도의 Secret 종류이고, `--from-literal` 은 값을 직접 지정하는 옵션입니다.',
   'kubectl create secret generic db-secret \\
  --from-literal=DB_USER=admin \\
  --from-literal=DB_PASSWORD=s3cur3 -n $NS

# generic : 일반(Opaque) Secret',
   NULL,
   '["sh", "-c", "kubectl get secret db-secret -n $NS | grep -q db-secret"]'),

  (12,  6, 'Secret 값을 꺼내서 디코딩하기',
   'Secret 의 값은 base64 로 저장되어 있어, 확인하려면 디코딩이 필요합니다.

`$NS` 네임스페이스의 `db-secret` 에서 `DB_USER` 값을 **디코딩**해서 `/tmp/secret_result.txt` 에 저장하세요.',
   '1) `kubectl get secret <이름> -n <네임스페이스> -o jsonpath=''{.data.DB_USER}''` : `-o jsonpath` 는 지정한 경로의 값만 출력합니다 (여기서는 base64 로 인코딩된 값)
2) `| base64 -d` : 파이프(`|`)로 넘겨 디코딩(`-d` 는 decode)합니다.',
   'kubectl get secret db-secret -n $NS -o jsonpath=''{.data.DB_USER}'' | base64 -d > /tmp/secret_result.txt

# jsonpath=''{.data.DB_USER}'' : Secret 의 data 아래 DB_USER 값만
# base64 -d : base64 디코딩',
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''admin'' /tmp/secret_result.txt"]'),

  (12,  7, 'Secret 을 환경변수로 Pod 에 주입하기',
   'Secret 의 값도 환경변수로 넣을 수 있습니다. 이번에는 **원하는 키만 골라서** 이름을 정해 넣습니다.

`db-secret` 의 `DB_USER`, `DB_PASSWORD` 를 각각 같은 이름의 환경변수로 주입한 Pod 를 `$NS` 네임스페이스에 만드세요. Pod 이름은 `secret-pod`, 이미지는 `nginx` 입니다.',
   '환경변수 하나씩 `env` 항목으로 씁니다: `name` 에 환경변수 이름, `valueFrom.secretKeyRef` 에 Secret 이름(`name`)과 키(`key`)를 지정합니다. 환경변수가 두 개이므로 `env` 목록에 두 항목이 필요합니다.',
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
    - name: DB_USER          # Pod 안에서 보일 환경변수 이름
      valueFrom:
        secretKeyRef:
          name: db-secret    # 어느 Secret
          key: DB_USER       # 그 안의 어느 키
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASSWORD
EOF',
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod secret-pod -n $NS | grep -q secret-pod"]'),

  (12,  8, 'ConfigMap 과 Secret 을 함께 주입하기',
   '실제 앱은 일반 설정(ConfigMap)과 비밀 값(Secret)을 함께 씁니다.

`app-config` ConfigMap 과 `db-secret` Secret 을 **모두** 환경변수로 주입한 Pod 를 `$NS` 네임스페이스에 만드세요. Pod 이름은 `full-pod`, 이미지는 `nginx` 입니다.',
   '`envFrom` 은 목록이라서 `configMapRef` 와 `secretRef` 를 함께 나열할 수 있습니다. `configMapRef.name` 에는 ConfigMap 이름, `secretRef.name` 에는 Secret 이름을 씁니다.',
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
    - configMapRef:     # ConfigMap 의 모든 키
        name: app-config
    - secretRef:        # Secret 의 모든 키
        name: db-secret
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod full-pod -n $NS | grep -q full-pod"]');
