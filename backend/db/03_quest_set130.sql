-- 세트 130: k8s 쉬운 문제 2: YAML 필드와 Pod 상태 읽기
-- 기본기 사다리(docs/specs/spec_foundations_ladder.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (130, 1, 'YAML 들여쓰기', 'YAML 에서 항목의 상하 관계(어느 항목 아래에 속하는지)는 무엇으로 정해질까요?', '눈에 보이는 공백이 의미를 가져요.', NULL, NULL, '[]', 'choice', '["중괄호 { }", "세미콜론 ;", "들여쓰기(공백 개수)", "줄 번호"]', 2, 'YAML 은 공백 두 칸 정도로 계층을 나타냅니다. 탭을 쓰면 안 되고, 칸이 하나만 어긋나도 의미나 오류가 달라져요.', NULL, NULL, NULL, NULL),
  (130, 2, '목록은 어떻게 쓸까', 'YAML 에서 `containers:` 아래에 컨테이너 여러 개를 나열할 때 각 항목 앞에 붙이는 기호는 무엇일까요?', '글머리 기호처럼 생겼어요.', NULL, NULL, '[]', 'choice', '["별표 `*`", "하이픈 `-`", "샵 `#`", "물결 `~`"]', 1, '`- name: web` 처럼 하이픈으로 목록 항목을 시작합니다. 하이픈 뒤의 항목들이 한 묶음(한 컨테이너)이에요.', NULL, NULL, NULL, NULL),
  (130, 3, 'apiVersion 과 kind', '매니페스트의 `kind: Deployment` 는 무엇을 뜻할까요?', '어떤 종류의 리소스인지 알려 줘요.', NULL, NULL, '[]', 'choice', '["만들려는 리소스의 종류(여기서는 Deployment)", "리소스의 이름", "이미지 이름", "네임스페이스 이름"]', 0, '`apiVersion` 은 어느 API 그룹·버전인지, `kind` 는 종류, `metadata` 는 이름·라벨, `spec` 은 원하는 상태입니다. 모든 매니페스트의 기본 뼈대예요.', NULL, NULL, NULL, NULL),
  (130, 4, 'metadata 에 들어가는 것', 'YAML 의 `metadata:` 아래에 주로 적는 것은 무엇일까요?', '리소스를 가리키는 "이름표"예요.', NULL, NULL, '[]', 'choice', '["컨테이너 실행 명령", "원하는 복제본 수", "볼륨의 크기", "이름(name), 네임스페이스(namespace), 라벨(labels) 같은 식별 정보"]', 3, '`spec` 은 "어떻게 동작해야 하는지"이고, `metadata` 는 "무엇인지"입니다. 이름과 라벨은 다른 리소스가 이 리소스를 찾을 때 쓰여요.', NULL, NULL, NULL, NULL),
  (130, 5, 'selector 와 template 의 라벨', 'Deployment 의 `selector.matchLabels` 와 Pod 템플릿의 `labels` 가 서로 다르면 어떻게 될까요?', 'Deployment 가 자기 Pod 를 찾을 수 없어요.', NULL, NULL, '[]', 'choice', '["아무 문제 없다", "Pod 가 두 배로 만들어진다", "생성이 거부되거나 Deployment 가 Pod 를 자기 것으로 인식하지 못한다. 두 값은 같아야 한다", "이미지가 자동으로 바뀐다"]', 2, 'selector 는 "이 라벨을 가진 Pod 를 내가 관리한다"는 선언이라 Pod 템플릿의 라벨과 일치해야 합니다. 가장 흔한 YAML 실수 중 하나예요.', NULL, NULL, NULL, NULL),
  (130, 6, 'replicas 와 containers', 'Deployment YAML 의 `replicas: 3` 과 `containers:` 목록의 컨테이너 1개는 합쳐서 어떤 모습일까요?', 'replicas 는 Pod 개수, containers 는 Pod 안의 컨테이너 목록이에요.', NULL, NULL, '[]', 'choice', '["컨테이너 3개가 하나의 Pod 에 들어간다", "Pod 3개가 만들어지고 각 Pod 안에 컨테이너가 1개씩 있다", "Pod 1개와 컨테이너 3개", "컨테이너가 없다"]', 1, 'replicas 는 Pod 의 복제 수이고, 컨테이너 목록은 Pod 한 개의 구성입니다. Pod 3개 × 컨테이너 1개 = 컨테이너 3개가 실행돼요.', NULL, NULL, NULL, NULL),
  (130, 7, 'requests 와 limits', '컨테이너의 `resources.requests.memory: 128Mi` 와 `limits.memory: 256Mi` 의 의미로 알맞은 것은 무엇일까요?', 'requests 는 최소 보장, limits 는 최대 허용이에요.', NULL, NULL, '[]', 'choice', '["requests 는 스케줄링할 때 보장받아야 하는 양, limits 는 넘으면 제한(또는 종료)되는 상한", "둘 다 같은 뜻이다", "requests 는 상한, limits 는 하한이다", "디스크 크기를 정한다"]', 0, '스케줄러는 requests 를 기준으로 노드를 고르고, 메모리가 limits 를 넘으면 컨테이너가 OOMKilled 될 수 있습니다.', NULL, NULL, NULL, NULL),
  (130, 8, 'Service 의 port 와 targetPort', 'Service 의 `port: 80`, `targetPort: 8080` 의 의미로 알맞은 것은 무엇일까요?', '앞은 서비스의 입구, 뒤는 Pod 안 컨테이너의 포트예요.', NULL, NULL, '[]', 'choice', '["Service 는 8080 으로 받아 80 으로 전달한다", "두 포트가 모두 같아야 한다", "targetPort 는 노드의 포트다", "Service 는 80 포트로 요청을 받아 Pod 의 8080 포트로 전달한다"]', 3, 'targetPort 가 컨테이너가 실제로 듣는 포트와 다르면 연결이 안 됩니다. 연결 문제에서 가장 먼저 확인하는 값이에요.', NULL, NULL, NULL, NULL),
  (130, 9, 'Running 과 Completed', 'Job 이 만든 Pod 의 상태가 `Completed` 입니다. 무슨 뜻일까요?', 'Job 은 한 번 일하고 끝나는 작업이에요.', NULL, NULL, '[]', 'choice', '["Pod 가 고장 났다", "이미지를 받는 중이다", "작업이 정상적으로 끝나 종료되었다 (오류가 아니다)", "노드가 부족하다"]', 2, '웹 서버는 계속 `Running` 이어야 하지만, Job 의 Pod 는 일을 끝내면 `Completed` 가 정상입니다.', NULL, NULL, NULL, NULL),
  (130, 10, 'Terminating 에서 멈췄어요', 'Pod 를 지웠는데 `Terminating` 이 오래 유지됩니다. 가장 알맞은 설명은 무엇일까요?', '종료 시간을 주는 설정이 있어요.', NULL, NULL, '[]', 'choice', '["이미 완전히 삭제된 것이다", "프로세스가 종료 신호에 바로 끝나지 않거나 종료 유예 시간(grace period)을 기다리는 중일 수 있다", "새로 만들어지는 중이다", "이미지가 다운로드되는 중이다"]', 1, '기본 유예 시간은 30초입니다. 훨씬 오래 걸리면 `kubectl describe` 로 이유를 보고, 마지막 수단으로 `--force --grace-period=0` 을 신중히 씁니다.', NULL, NULL, NULL, NULL),
  (130, 11, 'OOMKilled', 'Pod 의 마지막 종료 사유가 `OOMKilled` 입니다. 무슨 뜻일까요?', 'OOM 은 Out Of Memory 예요.', NULL, NULL, '[]', 'choice', '["컨테이너가 메모리 limits 를 넘거나 노드 메모리가 부족해 강제 종료되었다", "컨테이너가 정상 종료했다", "디스크가 가득 찼다", "이미지가 없었다"]', 0, '`kubectl describe pod` 의 Last State 에서 Reason 을 확인합니다. memory limits 를 올리거나 앱의 메모리 사용을 줄여야 해요.', NULL, NULL, NULL, NULL),
  (130, 12, 'RESTARTS 숫자', '`kubectl get pods` 의 RESTARTS 가 계속 늘어납니다. 무슨 뜻일까요?', '컨테이너가 죽었다가 다시 시작된 횟수예요.', NULL, NULL, '[]', 'choice', '["Pod 가 새 노드로 이동했다", "이미지가 새 버전으로 바뀌었다", "정상이다. 숫자는 의미가 없다", "컨테이너가 반복해서 죽고 다시 시작되고 있다. 로그와 종료 사유를 확인해야 한다"]', 3, 'RESTARTS 가 증가하면 앱이 죽고 있다는 신호입니다. `kubectl logs --previous` 로 직전 컨테이너의 마지막 로그를 볼 수 있어요.', NULL, NULL, NULL, NULL),
  (130, 13, 'FailedScheduling 이벤트', '`describe pod` 의 Events 에 `Warning FailedScheduling ... 0/3 nodes are available: Insufficient memory` 가 보입니다. 해석으로 알맞은 것은 무엇일까요?', '노드 3대 중 이 Pod 를 올릴 수 있는 곳이 없어요.', NULL, NULL, '[]', 'choice', '["이미지 이름이 틀렸다", "네트워크가 끊겼다", "요청한 메모리를 줄 수 있는 노드가 없어 스케줄되지 못했다. requests 를 줄이거나 노드 자원을 늘린다", "권한이 없다"]', 2, '`Insufficient memory`/`cpu` 는 자원 부족입니다. `kubectl describe node` 의 Allocated resources 로 각 노드의 여유를 비교해 보세요.', NULL, NULL, NULL, NULL),
  (130, 14, 'Evicted 는 무엇일까', 'Pod 의 상태가 `Evicted` 입니다. 가장 알맞은 설명은 무엇일까요?', '노드가 Pod 를 쫓아냈어요.', NULL, NULL, '[]', 'choice', '["사용자가 정상 삭제했다", "노드의 자원(디스크, 메모리)이 부족해 kubelet 이 Pod 를 내보냈다", "이미지가 업데이트됐다", "라벨이 바뀌었다"]', 1, '`describe pod` 에 이유가 있습니다. 노드의 `DiskPressure`, `MemoryPressure` 를 확인하세요. Deployment 의 Pod 는 다른 노드에 새로 만들어져요.', NULL, NULL, NULL, NULL),
  (130, 15, 'YAML 뼈대의 네 줄', '모든 매니페스트의 위쪽에 있는 네 가지 최상위 키 중 **원하는 상태**를 적는 칸의 이름을 채우세요.', '"명세"를 뜻하는 영어 단어(specification)의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["spec", "status", "data", "rules"]', NULL, '`spec` 은 사용자가 원하는 상태, `status` 는 클러스터가 기록하는 현재 상태입니다. status 는 직접 적지 않아요.', '[0]', 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
{0}:
  replicas: 2', NULL, NULL),
  (130, 16, '복제본 수 적기', 'Deployment 가 Pod 를 **3개** 유지하도록 빈칸을 채우세요.', '복제본의 영어 이름이에요.', NULL, NULL, '[]', 'fill', '["replicas", "copies", "count", "pods"]', NULL, '`spec.replicas` 가 원하는 Pod 개수입니다. `kubectl scale` 은 이 값을 바꿔요.', '[0]', 'spec:
  {0}: 3', NULL, NULL),
  (130, 17, '이미지 지정하기', '컨테이너가 사용할 이미지를 지정하는 키를 채우세요. (이미지는 `nginx:1.25`)', '이미지의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["image", "from", "source", "pull"]', NULL, '`image` 에는 `이름:태그` 를 적습니다. 태그를 생략하면 `latest` 가 쓰이는데 운영에서는 버전을 고정하는 것이 좋아요.', '[0]', 'containers:
- name: web
  {0}: nginx:1.25', NULL, NULL),
  (130, 18, '컨테이너 포트 적기', '컨테이너가 80 포트로 듣는다고 알리는 키를 채우세요.', '"컨테이너의 포트"라는 영어 이름이에요.', NULL, NULL, '[]', 'fill', '["containerPort", "port", "targetPort", "nodePort"]', NULL, '`containerPort` 는 정보 표시에 가깝고 열어 주는 것은 아닙니다. Service 의 `targetPort` 와 맞춰야 해요.', '[0]', 'ports:
- {0}: 80', NULL, NULL),
  (130, 19, '라벨로 Pod 찾기', 'Deployment 가 **`app: web` 라벨을 가진 Pod** 를 자기 것으로 관리하게 하는 칸입니다. 빈칸을 채우세요.', '"라벨이 일치하는 것"이라는 뜻의 이름이에요.', NULL, NULL, '[]', 'fill', '["matchLabels", "labels", "selectors", "findLabels"]', NULL, '`selector.matchLabels` 는 Pod 템플릿의 `metadata.labels` 와 같아야 합니다. Service 의 `selector` 는 `matchLabels` 없이 바로 라벨을 적어요.', '[0]', 'selector:
  {0}:
    app: web', NULL, NULL),
  (130, 20, 'Service 가 Pod 를 찾는 칸', 'Service 가 **`app: web` 라벨을 가진 Pod** 로 요청을 보내게 하는 칸입니다. 빈칸을 채우세요.', '"선택하는 것"이라는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["selector", "match", "labels", "target"]', NULL, 'Service 의 `selector` 가 어긋나면 엔드포인트가 비어 연결이 안 됩니다. `kubectl get endpoints` 로 확인해요.', '[0]', 'kind: Service
spec:
  {0}:
    app: web
  ports:
  - port: 80', NULL, NULL),
  (130, 21, 'Service 유형', '클러스터 **밖에서도 노드의 포트로 접속**할 수 있게 하는 Service 유형을 채우세요.', '노드의 포트를 연다는 뜻이에요.', NULL, NULL, '[]', 'fill', '["NodePort", "ClusterIP", "ExternalName", "Headless"]', NULL, '`ClusterIP` 는 클러스터 안에서만, `NodePort` 는 각 노드의 포트로 밖에서도 접근, `LoadBalancer` 는 외부 로드밸런서를 붙입니다.', '[0]', 'spec:
  type: {0}', NULL, NULL),
  (130, 22, '자원 요청과 상한', '컨테이너가 최소 보장받을 메모리와 넘으면 안 되는 상한을 적는 칸 이름입니다. 빈칸을 채우세요.', '하나는 요청, 하나는 한도예요.', NULL, NULL, '[]', 'fill', '["requests", "minimum", "reserve", "ask"]', NULL, '`requests` 는 스케줄링 기준, `limits` 는 상한입니다. limits 만 적으면 requests 도 같은 값으로 취급돼요.', '[0]', 'resources:
  {0}:
    memory: 128Mi
  limits:
    memory: 256Mi', NULL, NULL),
  (130, 23, '환경 변수 넣기', '컨테이너에 환경 변수 `MODE=prod` 를 넣는 칸입니다. 빈칸을 채우세요.', '"환경"을 뜻하는 영어 단어의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["env", "vars", "config", "set"]', NULL, '`env` 목록에 `name`/`value` 로 적습니다. 값이 길거나 민감하면 ConfigMap, Secret 에서 가져오게 해요.', '[0]', 'containers:
- name: web
  {0}:
  - name: MODE
    value: prod', NULL, NULL),
  (130, 24, 'YAML 전체 보기', '이미 만들어진 Pod `web-1` 의 **현재 정의와 상태**를 YAML 로 출력하는 옵션을 채우세요.', '출력 형식을 고르는 옵션이에요.', NULL, NULL, '[]', 'fill', '["yaml", "text", "full", "raw"]', NULL, '`-o yaml` 로 status 까지 포함한 전체를 볼 수 있습니다. 필드의 뜻은 `kubectl explain pod.spec` 으로 찾아요.', '[0]', 'kubectl get pod web-1 -o {0}', NULL, NULL),
  (130, 25, '필드 설명서 보기', '`pod.spec.containers` 필드가 무엇인지 **설명을 보는** 명령입니다. 빈칸을 채우세요.', '"설명하다"를 뜻하는 영어 단어예요. describe 와 다릅니다.', NULL, NULL, '[]', 'fill', '["explain", "describe", "help", "doc"]', NULL, '`kubectl explain` 은 API 필드의 의미와 타입을 알려 줍니다. 인터넷 없이 YAML 을 쓸 때 가장 큰 도움이 돼요.', '[0]', 'kubectl {0} pod.spec.containers', NULL, NULL),
  (130, 26, 'YAML 뼈대 만들기', '실제로 만들지 않고 **YAML 만 출력**해 뼈대를 얻는 옵션을 채우세요.', '"예행연습"을 뜻하는 옵션이에요.', NULL, NULL, '[]', 'fill', '["dry-run", "test", "preview", "simulate"]', NULL, '`--dry-run=client -o yaml > app.yaml` 로 뼈대를 만들어 고쳐 쓰면 빠릅니다.', '[0]', 'kubectl create deployment web --image=nginx --{0}=client -o yaml', NULL, NULL),
  (130, 27, 'YAML 파일 쓰는 순서', '새 Deployment YAML 을 처음부터 쓰는 순서입니다. 순서에 맞게 놓아 보세요.', '뼈대 → 이름 → 원하는 상태 → 컨테이너 순서예요.', NULL, NULL, '[]', 'order', '["`apiVersion` 과 `kind` 를 쓴다", "`metadata` 에 이름과 라벨을 쓴다", "`spec` 에 replicas 와 selector 를 쓴다", "`template` 아래에 컨테이너(이미지, 포트)를 쓴다"]', NULL, '바깥에서 안쪽으로 쓰면 들여쓰기도 자연스럽게 맞습니다. 쓴 뒤에는 `kubectl apply --dry-run=client -f` 로 문법을 먼저 확인할 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL),
  (130, 28, 'Pod 상태를 읽는 순서', 'Pod 가 Running 이 아닐 때 STATUS 에서 원인을 좁히는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 이름 → 상세 → 로그 → 수정 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 의 STATUS(Pending, ImagePullBackOff, CrashLoopBackOff)를 본다", "`kubectl describe pod` 의 Events 를 본다", "필요하면 `kubectl logs` 로 앱의 출력을 본다", "YAML 을 고쳐 다시 `apply` 한다"]', NULL, '상태 이름이 어느 단계에서 막혔는지 알려 줍니다. 단계(스케줄, 이미지, 시작)에 따라 볼 곳이 달라져요.', '[0, 1, 2, 3]', NULL, NULL, NULL),
  (130, 29, 'Service 가 연결 안 될 때', 'Service 로 접속이 안 될 때 점검 순서입니다. 순서에 맞게 놓아 보세요.', 'Service → 엔드포인트 → Pod 라벨 → 포트 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get svc` 로 Service 가 있는지 본다", "`kubectl get endpoints` 로 연결된 Pod 가 있는지 본다", "Service 의 selector 와 Pod 라벨이 같은지 본다", "`port` 와 `targetPort` 가 컨테이너 포트와 맞는지 본다"]', NULL, '엔드포인트가 비어 있으면 대부분 selector 와 라벨 불일치입니다. 이 순서로 보면 거의 원인이 나와요.', '[0, 1, 2, 3]', NULL, NULL, NULL),
  (130, 30, '이미지 업데이트하고 확인', 'Deployment 의 이미지를 새 버전으로 바꾸고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '변경 → 진행 확인 → 결과 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl set image deployment/web web=nginx:1.26`", "`kubectl rollout status deployment web`", "`kubectl get pods`", "문제가 있으면 `kubectl rollout undo deployment web`"]', NULL, '업데이트 후에는 진행 상황과 결과를 확인하고, 문제가 있으면 바로 되돌릴 준비를 해 두는 것이 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL);
