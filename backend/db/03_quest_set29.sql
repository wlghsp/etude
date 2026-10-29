-- 세트 29: k8s CKA 개념·명령 퀴즈 (객관식 12문제, 터미널 없음)
-- 정답(answer_index)과 해설(explanation)은 서버만 안다. docs/specs/spec_quiz_sets.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation) VALUES
  (29,  1, 'Pod 가 사라져도 자동으로 다시 만들어 주는 리소스 고르기',
   'Pod 를 `kubectl run web --image=nginx` 로 직접 만들었습니다. 노드 장애로 이 Pod 가 사라지면 다시 만들어 줄까요? 사라져도 **자동으로 다시 만들어 주도록** 하려면 무엇으로 배포해야 할까요?',
   'Pod 개수를 원하는 수로 **유지**해 주는 상위 리소스를 떠올려 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["Service", "Deployment", "ConfigMap", "Namespace"]',
   1,
   '정답은 **B Deployment** 입니다. Deployment 는 ReplicaSet 을 통해 Pod 개수를 원하는 수로 유지하고 롤링 업데이트와 롤백도 관리합니다. 단독으로 만든 Pod 는 사라져도 되살아나지 않습니다.

**원리:** 쿠버네티스는 **원하는 상태(desired)와 현재 상태(current)** 를 계속 비교해 같게 맞추는 컨트롤러 루프로 동작합니다. Deployment 가 만든 ReplicaSet 이 "Pod 3개"라는 선언을 보고 부족하면 새로 만듭니다. 단독으로 만든 Pod 에는 이 선언이 없어서, 지켜 줄 컨트롤러가 없습니다.

- A Service 는 Pod 앞의 고정 접속 지점(로드밸런싱)입니다.
- C ConfigMap 은 설정값을 담는 리소스입니다.
- D Namespace 는 리소스를 논리적으로 나누는 공간입니다.'),

  (29,  2, 'Pod 를 만들지 않고 YAML 뼈대만 출력하는 명령 고르기',
   'Pod 를 **실제로 만들지 않고** YAML 뼈대만 파일로 저장하려고 합니다. 올바른 명령은 무엇일까요? (CKA 에서 자주 쓰는 방법입니다)',
   '만들지 않고 시험만 하는 옵션과, 출력 형식을 YAML 로 바꾸는 옵션이 둘 다 필요합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kubectl run web --image=nginx > web.yaml`", "`kubectl create web.yaml`", "`kubectl get pod web -o yaml > web.yaml`", "`kubectl run web --image=nginx --dry-run=client -o yaml > web.yaml`"]',
   3,
   '정답은 **D** 입니다. `--dry-run=client` 는 서버에 요청하지 않고 객체만 만들어 보고, `-o yaml` 은 그 결과를 YAML 로 출력합니다. 이 출력을 파일로 저장하면 뼈대가 됩니다.

**원리:** `kubectl` 은 YAML 을 만들어 **API 서버로 보내는** 도구이고, `--dry-run=client` 는 마지막 전송만 생략합니다. 쿠버네티스의 모든 리소스는 선언 YAML 로 표현되므로, 빈 파일에서 쓰기보다 뼈대를 뽑아 고치는 편이 빠르고 오타도 적습니다. (CKA 에서 시간을 아끼는 기본 기술입니다)

- A 는 Pod 를 **실제로 만들고**, 파일에는 `pod/web created` 한 줄만 저장됩니다.
- B 는 `create` 에 파일을 쓰려면 `-f web.yaml` 이 필요하고, 그 파일이 먼저 있어야 합니다.
- C 는 **이미 있는** Pod 의 YAML 을 가져오는 것이라 없는 Pod 에는 오류가 납니다.'),

  (29,  3, '클러스터 밖에서 노드 IP 와 포트로 접근하는 Service 유형 고르기',
   '클러스터 **밖**에서 `노드IP:포트` 로 서비스에 접근할 수 있게 하려면 Service 유형을 무엇으로 해야 할까요?',
   '기본값 `ClusterIP` 는 클러스터 **안**에서만 접근됩니다. 노드의 포트를 여는 유형이 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["NodePort", "ClusterIP", "Headless (`clusterIP: None`)", "ExternalName"]',
   0,
   '정답은 **A NodePort** 입니다. 각 노드의 지정된 포트(기본 30000~32767)를 열어 외부에서 접근하게 합니다.

**원리:** Service 는 프로세스가 아니라 `kube-proxy` 가 각 노드의 네트워크 규칙(iptables/IPVS)에 만들어 둔 **"가상 IP → Pod IP" 변환 규칙**입니다. `NodePort` 는 그 규칙을 모든 노드의 같은 포트에도 열어서, 밖에서 `노드IP:포트` 로 들어오면 Pod 로 전달되게 합니다. (ClusterIP 는 실제 네트워크 인터페이스가 없는 가상 IP 라 보통 `ping` 에 응답하지 않습니다)

- B ClusterIP(기본값)는 클러스터 내부 전용입니다.
- C Headless 는 가상 IP 없이 Pod IP 를 직접 돌려주는 방식(StatefulSet 등)입니다.
- D ExternalName 은 외부 DNS 이름으로 연결해 주는 별칭입니다.'),

  (29,  4, 'CrashLoopBackOff 의 의미와 가장 먼저 볼 곳 알기',
   '`kubectl get pods` 에서 Pod 상태가 `CrashLoopBackOff` 입니다. 이 상태가 의미하는 것과 **가장 먼저 볼 곳**으로 맞는 것은?',
   '''Crash''(충돌)와 ''Loop''(반복)입니다. 컨테이너가 **시작된 뒤**에 어떻게 되는지 생각해 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["이미지를 받지 못하고 있다 → 레지스트리 접속을 확인한다", "스케줄링을 기다리고 있다 → 노드 자원을 확인한다", "컨테이너가 시작하자마자 종료되기를 반복한다 → `kubectl logs` 와 `describe` 의 종료 코드·이벤트를 확인한다", "정상이며 곧 Running 이 된다"]',
   2,
   '정답은 **C** 입니다. `CrashLoopBackOff` 는 컨테이너가 시작 후 계속 종료되어, 쿠버네티스가 **재시작 간격을 점점 늘리며** 다시 띄우는 상태입니다. `kubectl logs`(필요하면 `--previous`)로 앱 오류를, `kubectl describe pod` 로 `Exit Code` 와 이벤트를 확인합니다.

**원리:** 컨테이너는 **PID 1 프로세스가 살아 있는 동안만** 존재합니다. 그 프로세스가 끝나면 컨테이너도 끝나고, kubelet 이 `restartPolicy` 에 따라 다시 시작합니다. 계속 실패하면 재시작 간격을 10초, 20초, 40초 … 최대 5분까지 늘려 부하를 막는데, 이 대기 구간이 `BackOff` 입니다.

- A 는 `ErrImagePull`/`ImagePullBackOff` 입니다.
- B 는 `Pending` 입니다.
- D 는 아닙니다. 원인을 고치지 않으면 계속 반복합니다.'),

  (29,  5, 'ImagePullBackOff 의 원인이 아닌 것 고르기',
   '`ImagePullBackOff` 상태의 원인으로 **가능성이 가장 낮은 것**은 무엇일까요?',
   '이 상태는 컨테이너가 시작되기 **전에** 이미지를 받는 단계에서 생깁니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["이미지 이름이나 태그의 오타", "컨테이너 안 애플리케이션 코드의 버그", "사설 레지스트리 인증 정보(`imagePullSecrets`) 누락", "노드에서 레지스트리로의 네트워크 접속 불가"]',
   1,
   '정답은 **B** 입니다. 애플리케이션 버그는 이미지를 받은 **뒤** 컨테이너가 실행되면서 드러나므로 `CrashLoopBackOff` 같은 상태가 됩니다.

**원리:** Pod 가 시작되는 순서는 **스케줄링 → 이미지 받기 → 컨테이너 실행**입니다. 이미지를 받는 단계(레지스트리 주소, 태그, 인증, 네트워크)에서 막히면 `ImagePullBackOff`, 받은 뒤 앱이 죽으면 `CrashLoopBackOff` 입니다. 상태 이름은 **어느 단계에서 막혔는지**를 알려 줍니다.

- A, C, D 는 모두 이미지를 **받는 단계**에서 실패하는 대표 원인입니다. `kubectl describe pod` 의 Events 에서 `Failed to pull image` 의 이유를 확인합니다.'),

  (29,  6, 'Pending 과 Insufficient memory 이벤트의 원인 알기',
   'Pod 가 `Pending` 이고, `kubectl describe pod` 의 Events 에 `0/1 nodes are available: 1 Insufficient memory` 가 있습니다. 원인은 무엇일까요?',
   '스케줄러는 Pod 가 **요청한 자원**을 보장할 수 있는 노드에만 배치합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["컨테이너의 memory `limits` 가 너무 낮다", "이미지가 너무 크다", "`livenessProbe` 가 실패하고 있다", "Pod 의 memory `requests` 가 노드에 남은 메모리보다 커서 배치할 곳이 없다"]',
   3,
   '정답은 **D** 입니다. 스케줄러는 `requests`(요청량)를 기준으로 노드를 고릅니다. 어느 노드에도 그만큼 남은 메모리가 없으면 `Pending` 으로 남고 `Insufficient memory` 가 기록됩니다. `requests` 를 줄이거나 노드 자원을 늘립니다.

- A `limits` 는 실행 중 상한이라 스케줄링과 무관합니다(초과 시 `OOMKilled`).
- B 이미지 크기는 `ContainerCreating` 시간에 영향을 줍니다.
- C 프로브는 Pod 가 **실행된 뒤**의 문제입니다.'),

  (29,  7, 'Readiness Probe 와 Liveness Probe 구분하기',
   '컨테이너는 시작했지만 아직 요청을 받을 준비가 되지 않았을 때, **Service 로 트래픽을 보내지 않게** 하는 장치는 무엇일까요? (컨테이너를 재시작하지는 않습니다)',
   '두 프로브의 실패 결과가 다릅니다. 하나는 ''트래픽에서 빼기'', 다른 하나는 ''컨테이너 재시작''입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["readinessProbe", "livenessProbe", "restartPolicy", "resources.limits"]',
   0,
   '정답은 **A readinessProbe** 입니다. 실패하면 Pod 가 Service 의 엔드포인트에서 빠져 트래픽을 받지 않습니다(`READY 0/1`). 컨테이너는 그대로 둡니다.

**원리:** **준비됨(ready)** 과 **살아 있음(alive)** 은 다른 질문입니다. Readiness 는 "지금 트래픽을 받아도 되나"를 묻고, 실패하면 Service 엔드포인트에서 **빼기만** 합니다. Liveness 는 "스스로 회복 못 할 만큼 멈췄나"를 묻고, 실패하면 컨테이너를 **재시작**합니다. 그래서 기동이 느린 앱에는 readiness 를, 멈춤(교착)을 잡으려면 liveness 를 씁니다.

- B livenessProbe 는 실패하면 컨테이너를 **재시작**합니다.
- C restartPolicy 는 종료된 컨테이너를 다시 시작할지 정합니다.
- D limits 는 자원 상한입니다.'),

  (29,  8, '이전 버전으로 즉시 되돌리는 명령 고르기',
   '새 이미지로 롤링 업데이트를 했더니 장애가 났습니다. Deployment `app` 을 **이전 버전으로 즉시 되돌리는** 명령은 무엇일까요?',
   '배포 이력(revision)을 관리하는 명령 그룹이 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kubectl rollout restart deployment/app`", "`kubectl delete deployment app`", "`kubectl rollout undo deployment/app`", "`kubectl scale deployment app --replicas=0`"]',
   2,
   '정답은 **C** 입니다. `rollout undo` 는 직전 revision 으로 되돌립니다(`--to-revision=N` 으로 특정 버전도 가능). 이력은 `kubectl rollout history` 로 봅니다.

**원리:** Deployment 는 배포할 때마다 **ReplicaSet 을 새로 만들고, 이전 ReplicaSet 은 0개로 남겨 둡니다.** `rollout undo` 는 새로 만드는 것이 아니라 이전 ReplicaSet 의 개수를 되살리고 현재 것을 줄이는 것이라 빠릅니다. 이 이력은 `revisionHistoryLimit`(기본 10개)까지 남습니다.

- A `restart` 는 **같은 버전**의 Pod 를 새로 띄울 뿐입니다.
- B 는 Deployment 자체를 삭제합니다.
- D 는 Pod 를 모두 0개로 만들어 서비스가 중단됩니다.'),

  (29,  9, 'Secret 의 base64 가 의미하는 것 알기',
   '`kubectl get secret db-secret -o yaml` 을 보면 값이 알아볼 수 없는 문자열로 보입니다. 올바른 설명은 무엇일까요?',
   '''알아볼 수 없다''와 ''안전하다''는 다른 말입니다. 그 문자열을 어떻게 풀 수 있는지 생각해 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["AES 로 암호화되어 있어서 누구도 읽을 수 없다", "base64 로 인코딩된 것일 뿐 암호화가 아니라서 `base64 -d` 로 누구나 풀 수 있다. 그래서 접근 권한(RBAC) 관리가 중요하다", "해시라서 원문을 복원할 수 없다", "ConfigMap 과 완전히 같아서 차이가 없다"]',
   1,
   '정답은 **B** 입니다. Secret 의 값은 **base64 인코딩**이라 암호화가 아닙니다. `echo 값 | base64 -d` 로 바로 복원됩니다. 그래서 Secret 을 읽을 수 있는 사람(RBAC)을 제한하고, 필요하면 etcd 암호화(encryption at rest)를 켭니다.

- A 기본 설정에서는 암호화가 아닙니다.
- C 해시가 아니라 가역적인 인코딩입니다.
- D ConfigMap 과 쓰임새는 비슷하지만, 민감 정보용으로 분리되어 접근 제어와 마스킹을 다르게 다룹니다.'),

  (29, 10, 'OOMKilled 의 원인 알기',
   '컨테이너가 `OOMKilled` 로 종료되었습니다. 원인은 무엇일까요?',
   'OOM 은 Out Of Memory 입니다. 어느 자원의 어떤 한도를 넘었을지 생각해 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["CPU `limits` 를 초과했다", "노드 디스크가 가득 찼다", "readinessProbe 가 실패했다", "컨테이너가 memory `limits` 를 넘어서 커널이 강제 종료했다"]',
   3,
   '정답은 **D** 입니다. 컨테이너가 설정한 memory `limits` 보다 많이 쓰면 커널의 OOM killer 가 프로세스를 종료하고, `kubectl describe pod` 의 `Last State` 에 `OOMKilled` 가 남습니다. `limits` 를 늘리거나 앱의 메모리 사용을 줄입니다.

- A CPU 는 한도를 넘으면 종료가 아니라 **느려질 뿐**(throttling)입니다.
- B 디스크는 `Evicted` 등 다른 증상입니다.
- C readinessProbe 는 트래픽에서 빼기만 합니다.'),

  (29, 11, '모든 네임스페이스의 Pod 를 한 번에 보는 명령 고르기',
   '모든 네임스페이스의 Pod 를 **한 번에** 보려면 어떤 명령을 써야 할까요?',
   '기본으로는 현재 네임스페이스의 것만 보입니다. 짧은 옵션과 긴 옵션이 둘 다 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kubectl get pods --all`", "`kubectl get pods -n all`", "`kubectl get pods -A`", "`kubectl get pods --namespace=*`"]',
   2,
   '정답은 **C** 입니다. `-A`(긴 형태 `--all-namespaces`)는 모든 네임스페이스를 대상으로 합니다.

**원리:** 네임스페이스는 리소스 이름을 나누는 **논리적 구획**이고, `kubectl get` 은 기본적으로 현재 네임스페이스 하나만 조회합니다. Pod 가 어디에 있는지 모를 때는 `-A` 로 전체를 훑고, 문제가 되는 Pod 를 찾으면 그 네임스페이스로 좁힙니다. `kube-system` 같은 시스템 구성요소도 기본 조회에서는 보이지 않습니다.

- A `--all` 은 존재하지 않는 옵션입니다(`unknown flag`).
- B `-n all` 은 이름이 `all` 인 네임스페이스를 찾습니다.
- D 는 `*` 를 와일드카드로 해석하지 않습니다.'),

  (29, 12, 'Service 의 endpoints 가 비어 있는 흔한 원인 찾기',
   'Service 를 만들었는데 `kubectl get endpoints` 의 ENDPOINTS 가 `<none>` 입니다. Pod 는 `Running` 입니다. 가장 흔한 원인은 무엇일까요?',
   'Service 는 **어떤 Pod 로 보낼지**를 라벨 조건으로 찾습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["Pod 이미지가 오래되었다", "Service 의 `selector` 가 Pod 의 `labels` 와 맞지 않는다", "Service 의 type 이 ClusterIP 다", "네임스페이스에 Pod 가 너무 많다"]',
   1,
   '정답은 **B** 입니다. Service 는 `selector` 와 일치하는 라벨을 가진 Ready 상태의 Pod 를 엔드포인트로 삼습니다. 오타나 불일치가 있으면 엔드포인트가 비어, 접속해도 연결이 안 됩니다. `kubectl describe svc` 의 `Selector` 와 `kubectl get pods --show-labels` 를 비교해 확인합니다.

- A 이미지 버전은 연결과 무관합니다.
- C ClusterIP 는 기본 유형이라 문제가 아닙니다.
- D Pod 개수와 무관합니다.');
