-- 세트 19: kubectl 속도와 실전 (order 1~10)
-- CKA 같은 시간 제한 실기를 염두에 둔 손기술. 채점은 클러스터에 남은 리소스의 상태로 본다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (19,  1, 'Pod YAML 뼈대를 명령어로 만들기',
   'YAML 을 처음부터 손으로 쓰면 느리고 오타가 납니다. 명령어로 뼈대를 뽑아 시작하는 것이 실무와 CKA 시험의 기본 방법입니다.

할 일
1. 이름이 `web`, 이미지가 `nginx` 인 Pod 의 YAML 을 만듭니다.
2. Pod 를 실제로 만들지는 말고, 결과를 `/tmp/web.yaml` 파일로만 저장합니다.

완료 조건: `/tmp/web.yaml` 이 있고, 클러스터에 `web` Pod 는 없어야 합니다.',
   '`kubectl run` 은 Pod 를 만드는 명령입니다. 뒤에 `--dry-run=client` 를 붙이면 실제로 만들지 않고 시험만 하고, `-o yaml` 을 붙이면 그 결과를 YAML 로 출력합니다.

형태: `kubectl run <이름> --image=<이미지> --dry-run=client -o yaml`
출력은 화면에 나오므로 `>` 로 파일에 저장하세요. 저장한 뒤 `cat /tmp/web.yaml` 로 확인할 수 있습니다.',
   '# Pod 를 만들지 않고 YAML 만 출력해서 파일로 저장
kubectl run web --image=nginx --dry-run=client -o yaml > /tmp/web.yaml

# --dry-run=client : 서버에 요청하지 않고 객체만 만들어 봅니다
# -o yaml          : 결과를 YAML 형식으로 출력합니다',
   NULL,
   '["sh", "-c", "grep -q ''kind: Pod'' /tmp/web.yaml && grep -q ''name: web'' /tmp/web.yaml && grep -q ''image: nginx'' /tmp/web.yaml && ! kubectl get pod web -n $NS >/dev/null 2>&1"]'),

  (19,  2, 'Deployment YAML 을 만들어 저장한 뒤 적용하기',
   'Deployment 도 같은 방법으로 YAML 뼈대를 만들 수 있습니다. 이번에는 파일로 저장한 뒤, 그 파일을 클러스터에 적용합니다.

할 일
1. 이름 `api`, 이미지 `nginx`, 복제본(replicas) 3개인 Deployment 의 YAML 을 `/tmp/api.yaml` 에 저장합니다. (이 단계에서는 만들지 않습니다)
2. 저장한 파일을 `$NS` 네임스페이스에 적용합니다.

완료 조건: `$NS` 에 `api` Deployment 가 replicas 3 으로 있고, `/tmp/api.yaml` 도 남아 있어야 합니다.',
   '1단계: `kubectl create deployment <이름> --image=<이미지> --replicas=<개수> --dry-run=client -o yaml > <파일>`
2단계: `kubectl apply -f <파일> -n <네임스페이스>`

`kubectl apply -f` 는 YAML 파일의 내용대로 리소스를 만들거나 수정합니다. 적용한 뒤 `kubectl get deploy -n <네임스페이스>` 로 확인하세요.',
   '# 1단계: YAML 만들어서 저장 (아직 클러스터에는 만들지 않음)
kubectl create deployment api --image=nginx --replicas=3 --dry-run=client -o yaml > /tmp/api.yaml

# 2단계: 저장한 파일을 클러스터에 적용
kubectl apply -f /tmp/api.yaml -n $NS

# 확인
kubectl get deploy api -n $NS',
   NULL,
   '["sh", "-c", "[ -s /tmp/api.yaml ] && [ \\"$(kubectl get deploy api -n $NS -o jsonpath=''{.spec.replicas}'')\\" = 3 ]"]'),

  (19,  3, '명령어 한 줄로 Deployment 설정 바꾸기',
   'YAML 파일을 열어 고치지 않아도, 명령어 한 줄로 실행 중인 Deployment 를 바꿀 수 있습니다. 시험에서 시간을 아끼는 방법입니다.

`$NS` 네임스페이스에 `app` Deployment 가 이미 있습니다. 아래 세 가지를 각각 명령어로 바꾸세요.
1. 복제본(replicas)을 4개로
2. 이미지를 `nginx:1.25-alpine` 으로
3. 환경변수 `APP_ENV=prod` 추가

완료 조건: 세 가지가 모두 반영되어 있어야 합니다.',
   '각각 전용 명령이 있습니다.
- 복제본: `kubectl scale deployment/<이름> --replicas=<개수>`
- 이미지: `kubectl set image deployment/<이름> <컨테이너이름>=<이미지>` (이 Deployment 의 컨테이너 이름은 `nginx` 입니다)
- 환경변수: `kubectl set env deployment/<이름> <키>=<값>`

모든 명령 끝에 `-n <네임스페이스>` 를 붙이세요.',
   '# 1. 복제본 4개로
kubectl scale deployment/app --replicas=4 -n $NS

# 2. 이미지 변경 (컨테이너이름=새이미지)
kubectl set image deployment/app nginx=nginx:1.25-alpine -n $NS

# 3. 환경변수 추가
kubectl set env deployment/app APP_ENV=prod -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.replicas}'')\\" = 4 ] && kubectl get deploy app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' | grep -q alpine && [ \\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[?(@.name==\\"APP_ENV\\")].value}'')\\" = prod ]"]'),

  (19,  4, '라벨과 어노테이션 붙이기',
   '라벨은 리소스를 분류하고 검색할 때, 어노테이션은 담당자 같은 설명성 메모를 남길 때 씁니다.

`$NS` 네임스페이스의 `app` Deployment 에 아래 두 가지를 붙이세요.
1. 라벨 `tier=backend`
2. 어노테이션 `owner=team-a`',
   '형태는 같고 명령만 다릅니다.
- 라벨: `kubectl label <종류> <이름> <키>=<값> -n <네임스페이스>`
- 어노테이션: `kubectl annotate <종류> <이름> <키>=<값> -n <네임스페이스>`

종류는 `deployment`, 이름은 `app` 입니다. 확인: `kubectl get deployment app -n <네임스페이스> --show-labels`',
   '# 라벨 붙이기
kubectl label deployment app tier=backend -n $NS

# 어노테이션 붙이기
kubectl annotate deployment app owner=team-a -n $NS

# 확인
kubectl get deployment app -n $NS --show-labels',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get deploy app -n $NS -o jsonpath=''{.metadata.labels.tier}'')\\" = backend ] && [ \\"$(kubectl get deploy app -n $NS -o jsonpath=''{.metadata.annotations.owner}'')\\" = team-a ]"]'),

  (19,  5, 'Deployment 를 Service 로 노출하기',
   'Pod 는 다시 만들어질 때마다 IP 가 바뀌므로, 앞에 고정된 주소 역할을 하는 Service 를 둡니다. `kubectl expose` 로 한 줄에 만들 수 있습니다.

`$NS` 네임스페이스의 `app` Deployment 를 노출하는 Service 를 만드세요.
- Service 이름: `app-svc`
- 포트: `80`

완료 조건: `app-svc` 가 `app` Deployment 의 Pod 를 가리켜야 합니다.',
   '형태: `kubectl expose deployment <Deployment이름> --port=<포트> --name=<Service이름> -n <네임스페이스>`

`--port` 는 Service 가 받는 포트이고, `--name` 으로 Service 이름을 정합니다. 확인: `kubectl get svc -n <네임스페이스>`',
   '# Deployment 를 80 포트의 Service 로 노출
kubectl expose deployment app --port=80 --name=app-svc -n $NS

# 확인 (Service 가 Pod 를 찾았는지 ENDPOINTS 도 봅니다)
kubectl get svc,endpoints app-svc -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get svc app-svc -n $NS -o jsonpath=''{.spec.ports[0].port}'')\\" = 80 ] && [ \\"$(kubectl get svc app-svc -n $NS -o jsonpath=''{.spec.selector.app}'')\\" = app ]"]'),

  (19,  6, '원하는 값만 뽑아 파일에 저장하기',
   '`kubectl get -o yaml` 은 출력이 너무 깁니다. `-o jsonpath` 를 쓰면 필요한 값만 뽑을 수 있어, 스크립트와 시험에서 유용합니다.

`$NS` 네임스페이스의 `app` Deployment 가 사용하는 **이미지 이름**만 (예: `nginx:1.25`) `/tmp/image.txt` 에 저장하세요.',
   '경로는 YAML 구조를 따라갑니다: spec → template → spec → containers → 첫 번째 → image

형태: `kubectl get deployment <이름> -n <네임스페이스> -o jsonpath=''{.spec.template.spec.containers[0].image}''`

결과가 화면에 나오면 `>` 로 파일에 저장하세요.',
   '# jsonpath 로 이미지 값만 뽑아 저장
kubectl get deployment app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' > /tmp/image.txt

# containers[0] : 컨테이너 목록의 첫 번째',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/image.txt)\\" = nginx:1.25 ]"]'),

  (19,  7, '원하는 열만 골라 표로 보기',
   '`custom-columns` 를 쓰면 보고 싶은 열만 골라 표를 만들 수 있습니다. 기본 `kubectl get` 출력에 없는 값(이미지 등)을 한눈에 볼 때 유용합니다.

`$NS` 네임스페이스의 모든 Deployment 에 대해 **이름과 이미지**를 한 줄에 하나씩 `이름 이미지` 형태로 `/tmp/deploys.txt` 에 저장하세요. 제목 줄(헤더)은 넣지 않습니다.
예: `d-a nginx:1.24`',
   '형태: `kubectl get deploy -n <네임스페이스> -o custom-columns=<열이름>:<경로>,<열이름>:<경로> --no-headers`

- 이름 경로: `.metadata.name`
- 이미지 경로: `.spec.template.spec.containers[0].image`
- `--no-headers` 는 제목 줄을 없앱니다.',
   'kubectl get deploy -n $NS \\
  -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image \\
  --no-headers > /tmp/deploys.txt

# NAME:.metadata.name 은 ''열이름:값의 경로'' 형식입니다',
   '["sh", "-c", "kubectl create deployment d-a --image=nginx:1.24 -n $NS 2>/dev/null; kubectl create deployment d-b --image=nginx:1.25 -n $NS 2>/dev/null; kubectl create deployment d-c --image=busybox:1.36 -n $NS -- sleep 3600 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(awk ''{print $1,$2}'' /tmp/deploys.txt | sort | paste -sd, -)\\" = ''d-a nginx:1.24,d-b nginx:1.25,d-c busybox:1.36'' ]"]'),

  (19,  8, 'kubectl explain 으로 필드 설명 찾기',
   'YAML 을 쓰다 필드 이름이나 가능한 값이 기억나지 않을 때, 인터넷 없이 `kubectl explain` 으로 바로 확인할 수 있습니다. CKA 시험장에서 문서 대신 가장 빠르게 쓰는 방법입니다.

Pod 컨테이너의 `imagePullPolicy` 필드 설명을 `/tmp/explain.txt` 에 저장하세요.',
   '필드 경로를 점(.)으로 이어 씁니다.

형태: `kubectl explain pod.spec.containers.<필드이름>`

출력을 파일로 저장한 뒤 `cat /tmp/explain.txt` 로 내용을 읽어 보세요. 이 필드에 어떤 값을 쓸 수 있는지도 나와 있습니다.',
   'kubectl explain pod.spec.containers.imagePullPolicy > /tmp/explain.txt

# 한 단계씩 내려가며 볼 수도 있습니다
kubectl explain pod.spec
kubectl explain pod.spec.containers',
   NULL,
   '["sh", "-c", "grep -q imagePullPolicy /tmp/explain.txt && grep -q IfNotPresent /tmp/explain.txt"]'),

  (19,  9, 'patch 로 값 하나만 바꾸기',
   '`kubectl patch` 는 리소스의 일부만 골라 바꿉니다. YAML 파일 없이 값 하나를 빠르게 수정할 때 씁니다.

`$NS` 네임스페이스의 `app` Deployment 의 복제본(replicas)을 `kubectl patch` 로 `5` 로 바꾸세요.',
   '형태: `kubectl patch deployment <이름> -n <네임스페이스> -p ''<바꿀 내용(JSON)>''`

바꿀 내용은 원본 구조 그대로 씁니다. replicas 는 `spec` 아래에 있으므로 `{"spec":{"replicas":5}}` 입니다. 작은따옴표로 감싸야 쉘이 따옴표를 해석하지 않습니다.',
   'kubectl patch deployment app -n $NS -p ''{"spec":{"replicas":5}}''

# -p 뒤에는 바꿀 부분만 원본 구조대로 JSON 으로 적습니다',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.replicas}'')\\" = 5 ]"]'),

  (19, 10, '리소스의 줄임말 찾기',
   '`kubectl get deployments` 대신 `kubectl get deploy` 처럼 줄임말을 쓸 수 있습니다. 시험에서 타이핑을 줄여 주고, 줄임말은 `kubectl api-resources` 로 찾습니다.

Deployment 의 **줄임말**을 찾아 줄임말만 (영문 소문자 한 단어) `/tmp/short.txt` 에 저장하세요.',
   '`kubectl api-resources` 를 실행하면 리소스 종류마다 `NAME`, `SHORTNAMES` 열이 보입니다. `deployments` 줄의 `SHORTNAMES` 열이 답입니다.

`grep -w deployments` 로 줄을 고르고 `awk ''{print $2}''` 로 두 번째 열을 뽑으면 한 줄로 끝납니다.',
   '# 전체 목록에서 deployments 줄의 두 번째 열(SHORTNAMES)을 저장
kubectl api-resources | grep -w deployments | awk ''{print $2}'' > /tmp/short.txt

# 먼저 눈으로 확인: kubectl api-resources | head',
   NULL,
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/short.txt)\\" = deploy ]"]');
