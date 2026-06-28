# 퀘스트 생성 백로그

`docs/sources/` 가이드에서 추출한 퀘스트 후보 목록.
리눅스 / 도커 / k8s 기초 → 실무 응용 순으로 구성.

> **범례**
> - 난이도: 🟢 초급 / 🟡 중급 / 🔴 고급
> - 상태: `[ ]` 미작성 / `[x]` 완료

---

## 우선순위 높음 — KLID CMP 배포 (KLID_CMP_deploy_guide.md)

실제 현장 배포 흐름을 그대로 실습. 이 가이드는 반복 사용 예정.

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| CMP-01 | 컨테이너 이미지 오프라인 로드 | `nerdctl load -i *.tar`, `docker-tag.sh`로 레지스트리 푸시 | 🟡 | [ ] |
| CMP-02 | /etc/hosts 도메인 매핑 | 다수 서비스 도메인을 단일 IP로 매핑하는 이유 이해 + 설정 | 🟢 | [ ] |
| CMP-03 | 사설 인증서 생성 및 TLS Secret 등록 | `create-tls.sh deploy`, k8s TLS Secret 구조 이해 | 🟡 | [ ] |
| CMP-04 | Istio Gateway Helm 배포 | `helm install cmp-gateway`, namespace 분리 전략 | 🔴 | [ ] |
| CMP-05 | Redis 배포 및 상태 확인 | `redis-deploy.sh deploy`, Pod 상태 확인, CLI ping 테스트 | 🟡 | [ ] |
| CMP-06 | RabbitMQ 배포 및 상태 확인 | `rabbitmq-deploy.sh deploy`, 관리 콘솔 접근 | 🟡 | [ ] |
| CMP-07 | Vault 배포 및 Unseal | transit-vault → unseal → service-vault 순서 이해 | 🔴 | [ ] |
| CMP-08 | Vault 데이터 Import | `safe` CLI 도구, `safe import < vault-data.json` | 🔴 | [ ] |
| CMP-09 | Keycloak + PostgreSQL 배포 | `CREATE_CONFIG_REALM` 1회 설정 이유 이해, upgrade 흐름 | 🔴 | [ ] |
| CMP-10 | IaaS CMP Helm 배포 | `values.yaml` 환경별 수정 포인트, 배포 후 Pod 확인 | 🔴 | [ ] |
| CMP-11 | PaaS CMP Helm 배포 | IaaS와 배포 방식 비교, 네임스페이스 격리 | 🔴 | [ ] |
| CMP-12 | Gateway 및 서비스 브로커 기동 | `application.yml` 수정 포인트, `sh gateway start/stop` | 🔴 | [ ] |

---

## Vim 기초

현장에서 vi/vim 없이 서버 파일을 편집할 수 없다. 가장 자주 막히는 상황 위주로 구성.

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| VIM-01 | vim 열고 저장하고 나가기 | `i` 입력 모드, `ESC`, `:wq` / `:q!` | 🟢 | [ ] |
| VIM-02 | 커서 이동과 텍스트 탐색 | `hjkl`, `gg` / `G`, `/검색어`, `n` / `N` | 🟢 | [ ] |
| VIM-03 | 줄 편집 — 삭제·복사·붙여넣기 | `dd`, `yy`, `p`, `u` (undo), `Ctrl+r` (redo) | 🟢 | [ ] |
| VIM-04 | 파일 전체 교체 | `gg` → `dG`로 전체 삭제 → `i`로 붙여넣기. 설정 파일을 통째로 갈아끼울 때 가장 빠른 패턴 | 🟢 | [ ] |
| VIM-05 | 설정 파일 특정 줄 수정 | `:숫자` 줄 이동, `cw` 단어 교체, `:set number` | 🟡 | [ ] |
| VIM-06 | 치환 (sed 없이 vim으로) | `:%s/old/new/g`, 범위 지정 치환 | 🟡 | [ ] |
| VIM-07 | 검색 후 수정 | `/검색어` → `n`으로 이동 → `cw`로 교체. 긴 설정 파일에서 특정 값만 찾아 바꾸기 | 🟡 | [ ] |
| VIM-08 | 비주얼 모드로 여러 줄 처리 | `V`로 줄 선택, `d` 삭제 / `y` 복사 / `>` 들여쓰기. 블록 주석 처리 | 🟡 | [ ] |

---

## 리눅스 기초

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| LNX-01 | systemd 서비스 등록 및 관리 | unit 파일 작성, `systemctl enable/start/status` | 02, 08, 11 | 🟢 | [ ] |
| LNX-02 | 오프라인 RPM 설치 | `rpm -ivh`, 의존성 순서 처리 | 02, 08 | 🟢 | [ ] |
| LNX-03 | 환경변수 설정 (JAVA_HOME) | `/etc/profile.d/`, `source`, `which java` | 08 | 🟢 | [ ] |
| LNX-04 | 바이너리 설치 및 권한 설정 | tar 압축 해제, `chown`, `chmod`, PATH 등록 | 01, 02 | 🟢 | [ ] |
| LNX-05 | /etc/hosts 파일 편집 | 도메인 해석 순서 이해, 다수 엔트리 관리 | CMP | 🟢 | [ ] |
| LNX-06 | 시스템 계정 생성 | `useradd -r -s /sbin/nologin`, 서비스 계정 목적 이해 | 11, 12 | 🟢 | [ ] |
| LNX-07 | 포트 상태 확인 및 방화벽 | `ss -tlnp`, `firewall-cmd`, 서비스 간 포트 구조 파악 | 01, 02 | 🟡 | [ ] |
| LNX-08 | NTP 시간 동기화 | `chronyc tracking`, 분산 시스템에서 시간 동기화 중요성 | 11 | 🟢 | [ ] |

---

## 도커 / 컨테이너

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| DCK-01 | 이미지 tar 로드 및 태깅 | `nerdctl load`, `docker tag`, 레지스트리 push | CMP, 13 | 🟢 | [ ] |
| DCK-02 | 컨테이너 런타임 비교 | containerd vs crio, `nerdctl` vs `podman` 차이 | 02 | 🟡 | [ ] |
| DCK-03 | 사설 레지스트리 TLS 우회 | containerd `insecure_skip_verify` 설정, 자체 서명 인증서 | 13 | 🟡 | [ ] |
| DCK-04 | 오프라인 환경 이미지 배포 | 에어갭 환경에서 이미지 이동 전략 | 02, CMP | 🟡 | [ ] |

---

## Kubernetes

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| K8S-01 | Namespace 생성 및 격리 | `kubectl create ns`, ResourceQuota, 서비스 간 격리 이유 | CMP | 🟢 | [ ] |
| K8S-02 | Pod 상태 진단 | `kubectl get pods`, `describe`, `logs`, CrashLoopBackOff 대응 | 13 | 🟡 | [ ] |
| K8S-03 | PersistentVolume 연결 | PV/PVC 구조, storageClass, `kubectl get pvc` | 13 | 🟡 | [ ] |
| K8S-04 | Helm 배포 기초 | `helm install/upgrade/rollback`, `values.yaml` 구조 | CMP | 🟡 | [ ] |
| K8S-05 | Helm values.yaml 환경별 분리 | `-f values.yaml` 오버라이드 패턴 | CMP | 🟡 | [ ] |
| K8S-06 | ECK Operator로 Elasticsearch 배포 | CRD 적용, Operator 배포, 클러스터 상태 확인 | 13 | 🔴 | [ ] |
| K8S-07 | k8s RBAC — ServiceAccount 토큰 | ServiceAccount 생성, Role/ClusterRole, 토큰 발급 | 11, 13 | 🟡 | [ ] |
| K8S-08 | port-forward로 서비스 접근 | `kubectl port-forward`, 클러스터 내부 서비스 임시 접근 | 13 | 🟢 | [ ] |
| K8S-09 | ImagePullBackOff 트러블슈팅 | 이미지 경로 오류, pull secret, 레지스트리 인증 | 13 | 🟡 | [ ] |
| K8S-10 | vm.max_map_count 커널 파라미터 | `sysctl -w`, `/etc/sysctl.conf` 영구 적용, ES 요구사항 | 13 | 🟢 | [ ] |
| K8S-11 | Istio Gateway 트래픽 흐름 | Gateway + VirtualService 구조, 도메인 기반 라우팅 | CMP | 🔴 | [ ] |

---

## 서버 접속 패턴

"서비스를 띄웠는데 어떻게 접속하나?" — 레이어별 접속 구조를 순서대로 이해하는 시리즈.
같은 서비스에 접속하는 방법이 레이어마다 다르다는 것을 체득하는 것이 목표.

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| ACC-01 | Pod 기동 후 URL로 접속 | Pod 띄우고 `kubectl port-forward`로 로컬 접속. 가장 기본적인 접속 확인 방법 | 🟢 | [ ] |
| ACC-02 | /etc/hosts로 도메인 접속 | 서비스 IP를 `/etc/hosts`에 등록 → 도메인으로 `curl`. DNS 없이 도메인 매핑하는 현장 패턴 | 🟢 | [ ] |
| ACC-03 | HAProxy로 포트 포워딩 접속 | HAProxy TCP 모드로 외부 포트 → 내부 서비스 연결. 미들웨어 레이어에서 접속 경로 만들기 | 🟡 | [ ] |
| ACC-04 | ClusterIP + port-forward 접속 | ClusterIP Service 생성 → `kubectl port-forward`로 접속. 클러스터 내부 서비스 접근 구조 이해 | 🟢 | [ ] |
| ACC-05 | NodePort로 외부 접속 | NodePort Service 생성 → 노드 IP:포트로 직접 접속. ClusterIP와 NodePort의 차이 이해 | 🟡 | [ ] |
| ACC-06 | Ingress로 도메인 기반 라우팅 | Ingress 리소스 생성 → 도메인으로 접속. `/etc/hosts` + Ingress 조합 | 🟡 | [ ] |
| ACC-07 | Istio Gateway + VirtualService로 접속 | Gateway/VirtualService 생성 → 도메인 라우팅. Ingress와 Istio 방식 비교 | 🔴 | [ ] |
| ACC-08 | 접속 안 될 때 트러블슈팅 | `curl -v`, `kubectl describe`, `kubectl logs`, 포트/셀렉터/엔드포인트 확인 순서 | 🟡 | [ ] |

---

## 네트워크 / 로드밸런서

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| NET-01 | HAProxy TCP 모드 설정 | listen 섹션, 포트 포워딩, 헬스체크 | 16 | 🟡 | [ ] |
| NET-02 | HAProxy HTTP 모드 + ACL | frontend/backend 분리, Host 헤더 기반 라우팅 | 16 | 🟡 | [ ] |
| NET-03 | HAProxy SSL Termination | 인증서 설정, HTTPS → HTTP 변환 | 16 | 🔴 | [ ] |
| NET-04 | HAProxy 무중단 reload | master-worker 모드, `systemctl reload` | 16 | 🟡 | [ ] |
| NET-05 | HAProxy 통계 페이지 | stats 설정, 백엔드 상태 모니터링 | 16 | 🟢 | [ ] |
| NET-06 | HAProxy 트러블슈팅 | 503/502/400 에러 원인 분석 | 16 | 🟡 | [ ] |

---

## Kafka / 메시지 큐

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| KFK-01 | Kafka KRaft 단일 브로커 기동 | `kafka-storage.sh`, `server.properties`, systemd 등록 | 02 | 🟡 | [ ] |
| KFK-02 | Kafka 토픽 생성 및 메시지 발행 | `kafka-topics.sh`, `kafka-console-producer/consumer` | 02 | 🟢 | [ ] |
| KFK-03 | Consumer Group lag 확인 | `kafka-consumer-groups.sh`, lag 의미 이해 | 07 | 🟡 | [ ] |
| KFK-04 | Kafka advertised.listeners 설계 | INTERNAL/EXTERNAL 리스너 분리, HAProxy 연동 | 03, 17 | 🔴 | [ ] |
| KFK-05 | Kafka Connect REST API 활용 | 플러그인 목록, 커넥터 상태, 일시정지/재시작 | 07 | 🟡 | [ ] |
| KFK-06 | Debezium Source Connector 등록 | MariaDB 사용자 권한, 커넥터 JSON 작성 | 06 | 🔴 | [ ] |
| KFK-07 | Consumer Offset vs Connector Offset | 두 오프셋의 차이, `auto.offset.reset` | 15 | 🟡 | [ ] |
| KFK-08 | Kafka JVM 힙 튜닝 | `-Xms/-Xmx`, G1GC, PageCache 활용 | 04 | 🟡 | [ ] |

---

## 데이터베이스

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| DB-01 | MariaDB Galera Cluster 부트스트랩 | `galera_new_cluster`, wsrep 설정, 클러스터 합류 순서 | 01 | 🔴 | [ ] |
| DB-02 | Galera 클러스터 상태 확인 | `SHOW STATUS LIKE 'wsrep%'`, `wsrep_cluster_size=3` 검증 | 01 | 🟡 | [ ] |
| DB-03 | Galera 장애 복구 시나리오 | 1노드 다운, 전체 다운 후 `seqno` 기반 복구 | 01 | 🔴 | [ ] |
| DB-04 | AUTO_INCREMENT 센터 간 충돌 방지 | `auto_increment_increment/offset`, `wsrep_auto_increment_control=OFF` | 18 | 🟡 | [ ] |

---

## 모니터링 / 로깅

| # | 퀘스트 제목 | 핵심 실습 내용 | 출처 | 난이도 | 상태 |
|---|-------------|---------------|------|--------|------|
| OBS-01 | Prometheus 설치 및 scrape 설정 | `prometheus.yml`, job 설정, `promtool check` | 11 | 🟡 | [ ] |
| OBS-02 | PromQL 기초 쿼리 | Pod CPU/Memory 조회, Recording rules 이해 | 11 | 🟡 | [ ] |
| OBS-03 | Logstash 설치 및 파이프라인 기동 | `logstash -t` 검증, `/_node/pipelines` API | 08 | 🟡 | [ ] |
| OBS-04 | Elasticsearch ILM 정책 설정 | hot/warm/cold/delete phase, rollover 조건 | 19 | 🔴 | [ ] |
| OBS-05 | log4j2 파이프라인별 로그 분리 | RoutingAppender, MDC pipeline.id | 10 | 🟡 | [ ] |

---

## 미들웨어 설치

바이너리/패키지로 직접 설치하고 기동까지 확인하는 실습. "설치 → 설정 → 기동 → 상태 확인" 한 사이클이 목표.
오프라인 환경(에어갭) 기준으로 구성 — tar/rpm 파일을 가져다 설치하는 패턴이 현장 표준.

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| MID-01 | HAProxy 설치 및 기동 | rpm/바이너리 설치, `haproxy.cfg` 기본 설정, systemd 등록, `haproxy -c`로 설정 검증 | 🟡 | [ ] |
| MID-02 | Nginx 설치 및 기동 | rpm 설치, `nginx.conf` 기본 구조, `nginx -t`, 포트 확인 | 🟢 | [ ] |
| MID-03 | Elasticsearch 설치 및 기동 | tar 압축 해제, `elasticsearch.yml` 설정, `vm.max_map_count` 커널 파라미터, 클러스터 상태 확인 | 🟡 | [ ] |
| MID-04 | Logstash 설치 및 파이프라인 기동 | tar 설치, pipeline.yml, input/filter/output 기본 구성, `logstash -t` 검증 | 🟡 | [ ] |
| MID-05 | Kafka 설치 및 브로커 기동 | tar 설치, KRaft 모드 초기화, `server.properties`, systemd 등록, 토픽 생성으로 기동 확인 | 🟡 | [ ] |
| MID-06 | Jenkins 설치 및 초기 설정 | war/rpm 설치, 초기 admin 패스워드 확인, 플러그인 오프라인 설치 | 🟡 | [ ] |
| MID-07 | Nexus Repository 설치 및 기동 | tar 설치, `nexus.properties`, systemd 등록, 웹 콘솔 접속 확인 | 🟡 | [ ] |
| MID-08 | Harbor 설치 및 기동 | `install.sh` 실행, `harbor.yml` 설정 (hostname, 인증서), Docker Compose 기반 기동 확인 | 🔴 | [ ] |
| MID-09 | Vault 설치 및 초기화 | 바이너리 설치, dev/prod 모드 차이, `vault operator init`, unseal 키 관리 | 🔴 | [ ] |
| MID-10 | Redis 설치 및 기동 | rpm/tar 설치, `redis.conf` 기본 설정, `redis-cli ping`으로 확인 | 🟢 | [ ] |

---

---

## CKA 준비 세트

CNCF CKA 시험 도메인 기준 (2025). 세트 6 (k8s 기초) 이후 난이도.
RBAC, NetworkPolicy, PV 등 클러스터 레벨 리소스가 포함되므로 **vcluster per user 환경 필요**.

> 난이도 표기는 CKA 수험생 기준 (세트 6보다 전체적으로 높음)

### Storage (10%)

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| CKA-ST-01 | StorageClass 생성 | StorageClass 정의, `provisioner`, `reclaimPolicy` 설정 | 🟡 | [ ] |
| CKA-ST-02 | 동적 PV 프로비저닝 | StorageClass 기반 PVC 생성 → PV 자동 바인딩 확인 | 🟡 | [ ] |
| CKA-ST-03 | PV/PVC 수동 연결 | static PV 생성, accessMode, capacity, PVC 바인딩 | 🟡 | [ ] |
| CKA-ST-04 | PV Reclaim Policy | `Retain` / `Delete` / `Recycle` 차이, PV 재사용 시나리오 | 🟡 | [ ] |
| CKA-ST-05 | Pod에 볼륨 마운트 | `emptyDir`, `hostPath`, PVC 마운트 패턴 비교 | 🟢 | [ ] |

### Troubleshooting (30%)

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| CKA-TS-01 | CrashLoopBackOff 진단 | `kubectl logs --previous`, `describe`, exit code 해석 | 🟡 | [ ] |
| CKA-TS-02 | Pod Pending 원인 분석 | 리소스 부족 / nodeSelector 불일치 / PVC 미바인딩 케이스 | 🟡 | [ ] |
| CKA-TS-03 | 노드 NotReady 대응 | `kubectl describe node`, kubelet 상태 확인, 재기동 | 🔴 | [ ] |
| CKA-TS-04 | 클러스터 컴포넌트 진단 | kube-apiserver / scheduler / controller-manager 상태 확인 | 🔴 | [ ] |
| CKA-TS-05 | 리소스 사용량 모니터링 | `kubectl top pod/node`, OOMKilled 원인 파악 | 🟡 | [ ] |
| CKA-TS-06 | 컨테이너 로그 수집 | `kubectl logs`, `-c` 컨테이너 지정, `--since`, 로그 파일 직접 접근 | 🟢 | [ ] |
| CKA-TS-07 | Service → Pod 연결 트러블슈팅 | selector 불일치, endpoint 확인, `curl` 내부 접속 테스트 | 🟡 | [ ] |
| CKA-TS-08 | etcd 백업 및 복원 | `etcdctl snapshot save/restore`, 백업 주기 이해 | 🔴 | [ ] |

### Workloads & Scheduling (15%)

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| CKA-WS-01 | Rolling Update / Rollback | `kubectl rollout`, `--record`, `rollout undo` | 🟢 | [ ] |
| CKA-WS-02 | ConfigMap으로 앱 설정 주입 | `envFrom`, `volumeMount` 두 가지 방식 | 🟢 | [ ] |
| CKA-WS-03 | Secret 생성 및 주입 | `generic` / `tls` / `docker-registry` 타입, base64 인코딩 | 🟡 | [ ] |
| CKA-WS-04 | HorizontalPodAutoscaler | CPU 기반 HPA, `kubectl autoscale`, metrics-server 연동 | 🟡 | [ ] |
| CKA-WS-05 | DaemonSet / StatefulSet | 각 워크로드 특성 비교, 헤드리스 서비스 | 🟡 | [ ] |
| CKA-WS-06 | Liveness / Readiness Probe | HTTP / exec / tcpSocket 방식, 재시작 정책 | 🟡 | [ ] |
| CKA-WS-07 | Resource Limits & Requests | `resources.requests/limits`, LimitRange, QoS 클래스 | 🟡 | [ ] |
| CKA-WS-08 | nodeSelector / nodeAffinity | 라벨 기반 스케줄링, `requiredDuringScheduling` vs `preferred` | 🟡 | [ ] |
| CKA-WS-09 | Taint & Toleration | `kubectl taint`, NoSchedule / NoExecute, Pod 격리 패턴 | 🟡 | [ ] |

### Cluster Architecture, Installation & Configuration (25%)

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| CKA-CA-01 | Role / RoleBinding 생성 | namespace 범위 RBAC, `kubectl create role`, 권한 검증 | 🟡 | [ ] |
| CKA-CA-02 | ClusterRole / ClusterRoleBinding | 클러스터 범위 RBAC, ServiceAccount 연결 | 🟡 | [ ] |
| CKA-CA-03 | kubeadm으로 클러스터 설치 | `kubeadm init`, CNI 설치, `kubeadm join` | 🔴 | [ ] |
| CKA-CA-04 | 클러스터 업그레이드 | `kubeadm upgrade plan/apply`, kubelet/kubectl 업그레이드 순서 | 🔴 | [ ] |
| CKA-CA-05 | 노드 drain / cordon | 노드 유지보수 절차, `kubectl drain --ignore-daemonsets` | 🟡 | [ ] |
| CKA-CA-06 | Helm으로 컴포넌트 설치 | `helm repo add/install/upgrade`, `values.yaml` 오버라이드 | 🟡 | [ ] |
| CKA-CA-07 | Kustomize 기초 | `kustomization.yaml`, `kubectl apply -k`, overlay 패턴 | 🟡 | [ ] |
| CKA-CA-08 | CRD 생성 및 커스텀 리소스 적용 | CRD yaml 작성, CR 생성, `kubectl get <crd>` | 🔴 | [ ] |
| CKA-CA-09 | CNI / CSI / CRI 이해 | 각 인터페이스 역할, 플러그인 교체 시 영향 범위 | 🟡 | [ ] |

### Services & Networking (20%)

| # | 퀘스트 제목 | 핵심 실습 내용 | 난이도 | 상태 |
|---|-------------|---------------|--------|------|
| CKA-SN-01 | Pod 간 통신 확인 | Pod IP 직접 통신, 같은 namespace / 다른 namespace | 🟢 | [ ] |
| CKA-SN-02 | NetworkPolicy로 트래픽 제한 | ingress/egress 규칙, podSelector, namespaceSelector | 🔴 | [ ] |
| CKA-SN-03 | ClusterIP / NodePort / LoadBalancer | 서비스 타입별 동작 차이, endpoint 확인 | 🟢 | [ ] |
| CKA-SN-04 | Ingress 리소스 생성 | Ingress Controller 전제, 호스트/경로 기반 라우팅 | 🟡 | [ ] |
| CKA-SN-05 | Gateway API | HTTPRoute, GatewayClass, Ingress와 차이점 | 🔴 | [ ] |
| CKA-SN-06 | CoreDNS 동작 이해 | `nslookup`, `dig`, 서비스 DNS 규칙 (`svc.cluster.local`) | 🟡 | [ ] |
| CKA-SN-07 | DNS 트러블슈팅 | CoreDNS Pod 상태 확인, `resolv.conf`, 이름 해석 실패 원인 분석 | 🟡 | [ ] |

---

## 메모

- **CMP 시리즈**는 실제 배포 순서(CMP-01 → CMP-12)를 따르면 하나의 스토리 퀘스트 세트가 된다
- LNX-01~LNX-08은 다른 퀘스트들의 사전 요구 조건이 되므로 먼저 완성 권장
- K8S-02(Pod 진단), K8S-09(ImagePullBackOff)는 CMP 퀘스트 실습 중 자연스럽게 연계 가능
- **CKA 세트는 vcluster per user 환경 필요** — RBAC, NetworkPolicy, CRD 등 클러스터 레벨 리소스 포함. Phase 8 이후 vcluster 도입 시점에 구현 시작.
