-- 세트 29 객관식 해설에 '원리' 문단을 추가한다 (정답·선택지·채점은 바꾸지 않는다). 여러 번 실행해도 같은 결과다.
UPDATE quest SET explanation='정답은 **B Deployment** 입니다. Deployment 는 ReplicaSet 을 통해 Pod 개수를 원하는 수로 유지하고 롤링 업데이트와 롤백도 관리합니다. 단독으로 만든 Pod 는 사라져도 되살아나지 않습니다.

**원리:** 쿠버네티스는 **원하는 상태(desired)와 현재 상태(current)** 를 계속 비교해 같게 맞추는 컨트롤러 루프로 동작합니다. Deployment 가 만든 ReplicaSet 이 "Pod 3개"라는 선언을 보고 부족하면 새로 만듭니다. 단독으로 만든 Pod 에는 이 선언이 없어서, 지켜 줄 컨트롤러가 없습니다.

- A Service 는 Pod 앞의 고정 접속 지점(로드밸런싱)입니다.
- C ConfigMap 은 설정값을 담는 리소스입니다.
- D Namespace 는 리소스를 논리적으로 나누는 공간입니다.' WHERE quest_set_id=29 AND order_index=1;
UPDATE quest SET explanation='정답은 **D** 입니다. `--dry-run=client` 는 서버에 요청하지 않고 객체만 만들어 보고, `-o yaml` 은 그 결과를 YAML 로 출력합니다. 이 출력을 파일로 저장하면 뼈대가 됩니다.

**원리:** `kubectl` 은 YAML 을 만들어 **API 서버로 보내는** 도구이고, `--dry-run=client` 는 마지막 전송만 생략합니다. 쿠버네티스의 모든 리소스는 선언 YAML 로 표현되므로, 빈 파일에서 쓰기보다 뼈대를 뽑아 고치는 편이 빠르고 오타도 적습니다. (CKA 에서 시간을 아끼는 기본 기술입니다)

- A 는 Pod 를 **실제로 만들고**, 파일에는 `pod/web created` 한 줄만 저장됩니다.
- B 는 `create` 에 파일을 쓰려면 `-f web.yaml` 이 필요하고, 그 파일이 먼저 있어야 합니다.
- C 는 **이미 있는** Pod 의 YAML 을 가져오는 것이라 없는 Pod 에는 오류가 납니다.' WHERE quest_set_id=29 AND order_index=2;
UPDATE quest SET explanation='정답은 **A NodePort** 입니다. 각 노드의 지정된 포트(기본 30000~32767)를 열어 외부에서 접근하게 합니다.

**원리:** Service 는 프로세스가 아니라 `kube-proxy` 가 각 노드의 네트워크 규칙(iptables/IPVS)에 만들어 둔 **"가상 IP → Pod IP" 변환 규칙**입니다. `NodePort` 는 그 규칙을 모든 노드의 같은 포트에도 열어서, 밖에서 `노드IP:포트` 로 들어오면 Pod 로 전달되게 합니다. (ClusterIP 는 실제 네트워크 인터페이스가 없는 가상 IP 라 보통 `ping` 에 응답하지 않습니다)

- B ClusterIP(기본값)는 클러스터 내부 전용입니다.
- C Headless 는 가상 IP 없이 Pod IP 를 직접 돌려주는 방식(StatefulSet 등)입니다.
- D ExternalName 은 외부 DNS 이름으로 연결해 주는 별칭입니다.' WHERE quest_set_id=29 AND order_index=3;
UPDATE quest SET explanation='정답은 **C** 입니다. `CrashLoopBackOff` 는 컨테이너가 시작 후 계속 종료되어, 쿠버네티스가 **재시작 간격을 점점 늘리며** 다시 띄우는 상태입니다. `kubectl logs`(필요하면 `--previous`)로 앱 오류를, `kubectl describe pod` 로 `Exit Code` 와 이벤트를 확인합니다.

**원리:** 컨테이너는 **PID 1 프로세스가 살아 있는 동안만** 존재합니다. 그 프로세스가 끝나면 컨테이너도 끝나고, kubelet 이 `restartPolicy` 에 따라 다시 시작합니다. 계속 실패하면 재시작 간격을 10초, 20초, 40초 … 최대 5분까지 늘려 부하를 막는데, 이 대기 구간이 `BackOff` 입니다.

- A 는 `ErrImagePull`/`ImagePullBackOff` 입니다.
- B 는 `Pending` 입니다.
- D 는 아닙니다. 원인을 고치지 않으면 계속 반복합니다.' WHERE quest_set_id=29 AND order_index=4;
UPDATE quest SET explanation='정답은 **B** 입니다. 애플리케이션 버그는 이미지를 받은 **뒤** 컨테이너가 실행되면서 드러나므로 `CrashLoopBackOff` 같은 상태가 됩니다.

**원리:** Pod 가 시작되는 순서는 **스케줄링 → 이미지 받기 → 컨테이너 실행**입니다. 이미지를 받는 단계(레지스트리 주소, 태그, 인증, 네트워크)에서 막히면 `ImagePullBackOff`, 받은 뒤 앱이 죽으면 `CrashLoopBackOff` 입니다. 상태 이름은 **어느 단계에서 막혔는지**를 알려 줍니다.

- A, C, D 는 모두 이미지를 **받는 단계**에서 실패하는 대표 원인입니다. `kubectl describe pod` 의 Events 에서 `Failed to pull image` 의 이유를 확인합니다.' WHERE quest_set_id=29 AND order_index=5;
UPDATE quest SET explanation='정답은 **A readinessProbe** 입니다. 실패하면 Pod 가 Service 의 엔드포인트에서 빠져 트래픽을 받지 않습니다(`READY 0/1`). 컨테이너는 그대로 둡니다.

**원리:** **준비됨(ready)** 과 **살아 있음(alive)** 은 다른 질문입니다. Readiness 는 "지금 트래픽을 받아도 되나"를 묻고, 실패하면 Service 엔드포인트에서 **빼기만** 합니다. Liveness 는 "스스로 회복 못 할 만큼 멈췄나"를 묻고, 실패하면 컨테이너를 **재시작**합니다. 그래서 기동이 느린 앱에는 readiness 를, 멈춤(교착)을 잡으려면 liveness 를 씁니다.

- B livenessProbe 는 실패하면 컨테이너를 **재시작**합니다.
- C restartPolicy 는 종료된 컨테이너를 다시 시작할지 정합니다.
- D limits 는 자원 상한입니다.' WHERE quest_set_id=29 AND order_index=7;
UPDATE quest SET explanation='정답은 **C** 입니다. `rollout undo` 는 직전 revision 으로 되돌립니다(`--to-revision=N` 으로 특정 버전도 가능). 이력은 `kubectl rollout history` 로 봅니다.

**원리:** Deployment 는 배포할 때마다 **ReplicaSet 을 새로 만들고, 이전 ReplicaSet 은 0개로 남겨 둡니다.** `rollout undo` 는 새로 만드는 것이 아니라 이전 ReplicaSet 의 개수를 되살리고 현재 것을 줄이는 것이라 빠릅니다. 이 이력은 `revisionHistoryLimit`(기본 10개)까지 남습니다.

- A `restart` 는 **같은 버전**의 Pod 를 새로 띄울 뿐입니다.
- B 는 Deployment 자체를 삭제합니다.
- D 는 Pod 를 모두 0개로 만들어 서비스가 중단됩니다.' WHERE quest_set_id=29 AND order_index=8;
UPDATE quest SET explanation='정답은 **C** 입니다. `-A`(긴 형태 `--all-namespaces`)는 모든 네임스페이스를 대상으로 합니다.

**원리:** 네임스페이스는 리소스 이름을 나누는 **논리적 구획**이고, `kubectl get` 은 기본적으로 현재 네임스페이스 하나만 조회합니다. Pod 가 어디에 있는지 모를 때는 `-A` 로 전체를 훑고, 문제가 되는 Pod 를 찾으면 그 네임스페이스로 좁힙니다. `kube-system` 같은 시스템 구성요소도 기본 조회에서는 보이지 않습니다.

- A `--all` 은 존재하지 않는 옵션입니다(`unknown flag`).
- B `-n all` 은 이름이 `all` 인 네임스페이스를 찾습니다.
- D 는 `*` 를 와일드카드로 해석하지 않습니다.' WHERE quest_set_id=29 AND order_index=11;
