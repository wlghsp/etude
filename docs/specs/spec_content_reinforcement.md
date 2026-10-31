# 명세 — 콘텐츠 강화 목록 (dev-notes 자료 기반)

> 상태: **목록 정리 단계** (2026-10-30). 어떤 자료로 어떤 세트를 더 만들지 정하는 문서다. 세트를 만들 때마다 "상태" 열을 갱신한다.
> 계기: "dev-notes 에 책 PDF 와 다른 문서들이 있다. 이것들을 바탕으로 문제를 강화해야 한다. 먼저 강화할 목록을 문서로 정리하자."

## 원칙

1. **근거는 사용자의 노트다.** 문제는 `dev-notes/glossary/**` 와 `dev-notes/blog/**` (사용자가 직접 정리한 요약)를 바탕으로 만든다. `dev-notes/assets/**` 의 책 PDF 는 **원문을 옮기지 않는다** (저작권). 책은 "어느 장을 더 읽을지"를 가리키는 출처로만 쓰고, 세트의 `quest.docs` 에는 공개 공식 문서 링크를 단다.
2. **사내 현실과 맞는 것이 먼저다.** 사내에서 쓰는 도구(HAProxy, Istio, Kafka·Debezium, MariaDB·Galera, OCP·OpenStack·Ceph, Prometheus·Loki·OpenTelemetry)가 위, 일반 이론이 아래다.
3. **형식은 소재가 정한다.** 클러스터·서버가 있어야만 보이는 것은 실습, 구조·역할·용어·읽기는 문제형(객관식·순서·빈칸). 컨테이너 하나로 되는 것은 실습으로 올린다.
4. **정확성 표시.** 노트와 대조한 문제형은 "코드상 확인됨", 컨테이너에서 돌려 본 실습은 "검증됨", 사내 운영과의 일치는 담당자 검수 전까지 "미검증".
5. Etude 범위 밖은 제외한다: Java·Spring·JVM·JPA, 알고리즘·자료구조, 투자, AI·LLM, 면접·커리어 자료.

## 자료 목록과 이미 만든 것

| 자료 (dev-notes) | 내용 | Etude 와의 관계 | 이미 만든 세트 |
|---|---|---|---|
| `glossary/topics/virtualization` (25) + published | RHV·RHOV·OCP·OSP·RHOSO, KVM·KubeVirt, Ceph·ODF·Cinder, Neutron·OVN | 인프라 분류의 핵심 | 55, 61 |
| `glossary/topics/haproxy` (22) | 알고리즘, 연결 관리, TLS·SNI, VIP·Keepalived, rate limiting | 사내 사용 | 51(실습), 63 |
| `glossary/topics/kafka` (24) + `books/kafka-definitive-guide` (13) + `blog/kafka` | 토픽·파티션·복제, 컨슈머 그룹, 멱등·전달 보장, DLQ, AMQP | 사내 사용 | 58, 66 |
| `blog/cdc` (8) + `topics/distributed-systems` | CDC, Debezium·binlog, Connect 내부 토픽, 삭제 이벤트, 양방향 루프 방지, at-least-once | 사내 사용 | 58(일부) |
| `glossary/topics/mysql` (12) + `incident/mariadb-replication-recovery.md` + `blog/database/Galera…` | Galera, certification, wsrep, MaxScale, PITR, 복제 복구 | 사내 사용 | 59 |
| `glossary/topics/elasticsearch` (23) | 역색인, 샤드, refresh·flush, 매핑, 쿼리 | 사내 사용 | 62 |
| `pipeline`, `logging`, `observability`, `opentelemetry-study`, `books/observability-engineering` (17) | Prometheus·Thanos·Loki·Alloy·Vector·Logstash, 신호, 구조화 이벤트, 카디널리티 | 사내 사용 | 57 |
| `glossary/topics/redis` (2) | 분산 락, Lua 스크립트 | 사내 사용 | 60(일부) |
| `work/git-wrong-base-branch-recovery.md` | 잘못 딴 브랜치·공유 브랜치 복구 | Git 현장 사고 | 56 |
| `books/kubernetes-in-action` (14) + `blog/kubernetes` (6) + `topics/os-network` (50) | 컨테이너·cgroup·namespace, 컨트롤 플레인, taint·drain, Ingress, sidecar, kube-proxy, kubelet, CRD·Operator, Istio | k8s 핵심 | **일부 (41, 46 등)** |
| `blog/network` (7) + `blog/julia-evans` (5) + `network-training` | iptables·k8s, 로드밸런싱, CNI, NodePort·Ingress, NFS, DNS 장애, OSI·TCP | 리눅스 네트워크·k8s 네트워킹 | **일부 (4, 18, 25, 37)** |
| `books/csapp` (64), `books/modern-os` (8), `books/mysql-internals` (10), `books/database-internals` (7), `topics/database` (21), `db-internals` | OS·컴퓨터 구조·DB 내부 | 리눅스 이해·DB 심화 | 없음 |
| `topics/devops` (5), `topics/circuit-breaker` (Resilience4j), `topics/shell` | GitOps·ArgoCD·CI/CD on k8s, Pulumi, 장애 격리 패턴, 터미널 단축키 | CI/CD·운영 | 64(Jenkins 등은 노트 없이 작성) |

## 사내 운영 자료 (추가 자료)

노트보다 **운영 현실에 가까운** 자료다 (설치·운영 가이드, 장애 기록, 설계 문서). 읽기 전용으로 참고하고, 문제에는 **현장 정보를 넣지 않는다** (아래 "보안 규칙"). 자료의 위치와 파일 이름도 이 문서에는 적지 않는다.

| 자료 종류 | 활용 |
|---|---|
| 장애 트러블슈팅 기록 (연쇄 장애, 네트워크 정책, 비대칭 라우팅) | 장애 읽기 (세트 69) |
| 파이프라인 운영·장애 대응 매뉴얼, 장애 주입 테스트 | 세트 69 (일부), 이후 확장 |
| 운영 runbook (CDC·로그 파이프라인, 장애 복구 절차) | 세트 68, 73 |
| 메시징(Kafka)·CDC 설치·리스너·보관정책·운영 가이드 | 세트 67, 68 |
| 로드밸런서 설정 케이스 모음, Istio 연동 | 세트 70, 72 |
| 데이터베이스(Galera) 구축·PK 충돌 방지 | 세트 68, 73 |
| 검색·로그 저장소(ILM, StorageClass) 가이드 | 세트 71 |
| 모니터링 파이프라인(Prometheus·Vector·Thanos·Logstash) 설치·개념 | 세트 74, 이후 관측 심화 |
| CI/CD(Jenkins·Nexus) 설치·이전 가이드 | 세트 64 보정에 사용 |
| 리눅스 운영 기본기(NTP, SSH 키, NFS, 라우팅) | 세트 75 |

## 보안 규칙 (필수)

문제·해설·힌트·정답·세트 설명·이 문서에 **현장 정보를 넣지 않는다.** 일반 개념과 일반화한 예시만 쓴다.

- 넣지 않는 것: 실제 IP·도메인·호스트 이름·포트 배치, 계정·비밀번호·토큰, 내부 저장소·프로젝트·네임스페이스·토픽·인덱스 이름, 사이트(센터) 이름과 구성, 제품 배치(어디에 무엇이 있는지)를 드러내는 서술.
- 바꿔 쓰는 방법: 사이트 A·B, 서버 A·B, `example.com`, `10.0.0.x`(예시 대역), 일반 명사(수집용 Prometheus, 입구 서버).
- 실제 사고 사례는 **구조와 원리만 남겨 일반화**하고, "우리 환경에서 겪었다" 같은 서술은 쓰지 않는다.
- 세트를 만든 뒤에는 `scripts/check-content.sh` 와 별도로 IP·도메인·내부 이름·"사내/현장/센터" 표현을 검색해 확인한다.
- 이미 배포된 세트의 표현을 고칠 때는 원본 `03_quest_set*.sql` 과 함께 DB 를 갱신하는 마이그레이션을 추가한다 (예: `2026-10-30_zzzzzz_sanitize_site_info.sql`).

## 강화 후보 (우선순위)

### A. 사내에서 바로 쓰는 것 (먼저)

| # | 세트 후보 | 근거 노트 | 형식 | 상태 |
|---|---|---|---|---|
| A1 | **Kafka 심화**: ISR·acks·컨트롤러, 전달 보장 3종(at-most/at-least/exactly), tombstone, 재처리·offset 되감기, 부트스트랩·advertised listener 오류 | `kafka/published/*`, `kafka-definitive-guide`, `blog/kafka`, 사내 운영 자료 | 문제형 | **완료 (세트 67)**, 이어서 JVM·로그 삭제 테스트 등 확장 가능 |
| A2 | **CDC·Debezium 심화**: 스냅샷, 이벤트 구조, Connect 내부 토픽 3개, 삭제 이벤트(tombstone), 양방향 동기 루프 방지, Galera + CDC 충돌, JDBC sink 멱등 | `blog/cdc/*`, `distributed-systems/*`, `mysql/galera-cluster.md`, 사내 운영 자료 | 문제형 | **완료 (세트 68)** |
| A3 | **Istio·Gateway·VirtualService 읽기** (HAProxy 와 비교) | `os-network/istio.md`, 사내 운영 자료 | 문제형 | **개념 완료 (세트 70)**, YAML 빈칸 실습은 CRD 설치 가능 여부 확인 뒤 |
| A4 | **OpenStack 컴포넌트**: Keystone·Nova·Glance·Horizon, 인스턴스 생성 흐름, 쿼터·테넌트 | `virtualization/openstack.md`, `tenant.md`, `provisioning.md` | 문제형 | 대기 (노트에 Keystone·Glance 상세 없음, 보강 필요) |
| A5 | **Ceph 구조**: MON·OSD·MGR, 풀·PG, RBD·CephFS·RGW, 복제와 장애 | `virtualization/ceph.md` (짧음) | 문제형 | 대기 (노트 보강 필요) |
| A6 | **Prometheus 읽기·PromQL 기초**, 알림, 카디널리티, Thanos 구성, OTel Collector 파이프라인(receivers·processors·exporters) | `pipeline/published`, `observability/*`, `opentelemetry-study`, `books/observability-engineering` | 문제형 (+ PromQL 은 실습 후보) | **1차 완료 (세트 57 관측 입문, 74 사내 메트릭 파이프라인)**, Thanos·Logstash 심화는 남음 |
| A7 | **MariaDB 운영 실습**: 단일 인스턴스에서 복제 설정·binlog·`mysqldump` 옵션·PITR 리허설 | `mysql/*`, `incident/*` | 실습 (MariaDB 서버가 이미지에 필요) | 대기 (이미지 영향 검토) |
| A8 | **Redis 심화**: 분산 락 주의점, Lua 스크립트로 원자성, 영속화(RDB·AOF), Sentinel·Cluster 개념 | `redis/*` | 실습 + 문제 | **완료 (세트 83)**, Sentinel·Cluster 는 개념만 |
| A9 | **Elasticsearch 실습·심화** (ILM·StorageClass 는 세트 71 완료): 매핑 설계, 분석기(analyzer), BM25, 샤드 할당·rebalancing, merge, near-real-time | `elasticsearch/*` (analyzer·bm25·merge·rebalancing·replica 미사용) | 문제형 | 대기 |
| A10 | **HAProxy 심화 2**: 로깅(타이밍 필드로 성능 진단), connection limiting, uri 해시, 설정 오류 찾기 | `haproxy/logging.md`, `connection-limiting.md`, `uri.md` | 실습 + 문제 | **완료 (세트 84)** |

| A11 | **사내 장애 사례 읽기** (연쇄 장애, 증상 vs 원인) | 사내 운영 자료(장애 기록·runbook) | 문제형 | **1차 완료 (세트 69)**, 사례를 더 추가 가능 |
| A12 | **Galera 장애 복구 시나리오 심화**: 단일 노드 복구, `grastate.dat`, `safe_to_bootstrap`, 쿼럼 상실, SST/IST | 사내 운영 자료(복구 runbook, Galera 가이드) | 문제형 | **1차 완료 (세트 73: Galera·Kafka 복구 절차)** |
| A13 | **HAProxy 케이스 실습**: Kafka TCP 포워딩, ACL 도메인 라우팅, stats | 사내 운영 자료(로드밸런서 케이스 모음) | 실습 (haproxy 이미지 있음) | **완료 (세트 72)** |

### B. k8s·리눅스 기본기 확장

| # | 세트 후보 | 근거 노트 | 형식 | 상태 |
|---|---|---|---|---|
| B1 | **컨테이너의 정체**: namespace·cgroup·이미지 레이어·OCI·레지스트리 (도커 개념 보강, "컨테이너는 격리된 프로세스") | `kubernetes-in-action/ch02`, `linux-namespace.md`, `cgroup.md`, `oci.md`, `container-image.md` | 문제형 + 일부 실습(`unshare`, cgroup 파일 읽기) | **완료 (세트 77)** |
| B2 | **k8s 구조**: 컨트롤 플레인·워커 노드·kubelet·kube-proxy·etcd, 선언형 모델, CRD·Operator | `KUBERNETES_ROADMAP.md`, `control-plane.md`, `declarative-model.md`, `os-network/kubelet.md`, `kube-proxy.md`, `crd.md`, `kubernetes-operator.md` | 문제형 | **완료 (세트 78)** |
| B3 | **스케줄링 운영**: taint·toleration, cordon·drain·eviction, sidecar·DaemonSet, Ingress·Egress | `blog/kubernetes/01~04` | 문제형 + 실습(k8s 샌드박스 검증 필요) | **개념 완료 (세트 79)**, 실습은 공유 클러스터 영향 검토 필요 |
| B4 | **k8s 네트워크 이해**: iptables와 kube-proxy, CNI, NodePort·Ingress·Service 경로, NFS 스토리지 | `blog/network/*` | 문제형 | **완료 (세트 80)** |
| B5 | **DNS 장애 진단**: DNS 가 깨지는 방법들, 문제가 DNS 인지 구분하기, OSI 와 TCP/IP, UDP | `blog/julia-evans/*` | 문제형 + 실습(`dig`, `/etc/hosts`) | **완료 (세트 81)** |
| B6 | **리눅스 성능 입문**: CPU·메모리·디스크·네트워크를 보는 기본 명령 (`top`, `vmstat`, `iostat`, `ss`) — 책 *Systems Performance* 의 주제 | (노트 없음, `assets/observability` 책만) | 실습 | 보류 (노트를 먼저 정리해야 함) |
| B7 | **프로세스·메모리 이해**: fork·exec, copy-on-write, 커널·유저 모드, 파일시스템 계층 | `os-network/fork-exec.md`, `copy-on-write.md`, `unix-filesystem-hierarchy.md`, `books/modern-os`, `books/csapp` 일부 | 문제형 | **완료 (세트 85)**, 메모리·페이지는 후속 |
| B9 | **리눅스 운영 기본기**: NTP·chrony, SSH 키 인증, NFS 마운트, 비대칭 라우팅(`ip rule`·`ip route`) | 사내 운영 자료(SSH·NFS·라우팅 가이드) | 실습(일부) + 문제 | **1차 완료 (세트 75)**, NTP·NFS 는 문제로만 다룸 |
| B8 | **GitOps·CI/CD on k8s**: ArgoCD·GitOps 개념, 파이프라인 구조 | `devops/published/argocd.md`, `gitops.md`, `cicd-on-kubernetes.md` | 문제형 | **완료 (세트 82)** |

### C. 장기 (DB·시스템 내부, 우선순위 낮음)

| # | 세트 후보 | 근거 | 형식 | 상태 |
|---|---|---|---|---|
| C1 | DB 인덱스·격리 수준·실행 계획 읽기(`EXPLAIN`) | `topics/database/*`, `db-internals` | 문제형 | **완료 (세트 87)** |
| C2 | 분산 시스템 개념: 합의(Raft·Paxos), eventual consistency, saga, backpressure | `topics/distributed-systems/*` | 문제형 | **완료 (세트 86)** |
| C3 | 장애 격리 패턴: circuit breaker·bulkhead·retry·timeout (언어 비의존 개념만) | `topics/circuit-breaker/*` | 문제형 | 보류 (Spring 의존 노트는 제외) |
| C4 | 장애 대응·SRE 사고 방식 (책 *SRE*, *Release It!*) | 책만, 노트 없음 | 문제형 | 보류 (노트 정리 먼저) |

## 이미 있는 문제를 강화하는 일 (신규 세트와 별개)

- 사내 담당자 검수: 인프라(55, 61), 미들웨어(57~59, 62~64, 66) 세트의 표현이 사내 용어와 맞는지.
- 노트 없이 일반 지식으로 쓴 세트 64(Jenkins·Nexus·Harbor)를 사내 방식에 맞춰 고치기.
- 문제형 세트에 `quest.docs` 공식 문서 링크 달기 (현재 대부분 없음).
- 기존 객관식 정답 위치 쏠림 점검 (이전 확인 사항: index 1 쏠림).
- 문제형 중 실습으로 올릴 수 있는 것 승격 (Kafka CLI, Prometheus `promtool`, `etcdctl` 등은 이미지·클러스터 변경이 필요하므로 별도 검토).

## 문제 형식 다양화 규칙 (2026-10-30)

- 문제가 객관식에만 치우치면 지루하고 추측으로 풀 수 있다. 지금까지 세트 48~87 의 문제는 객관식 68%, 터미널 25%, 순서 맞추기 6%, 빈칸 0% 였다.
- **새 세트는 한 세트 안에 서로 다른 형식을 3가지 이상** 섞는다 (객관식, 순서 맞추기, 빈칸, 터미널 읽기·고치기). 문제형(터미널 없음) 세트도 객관식은 절반 이하로 둔다.
- 소재별 권장 형식: 설정 파일·명령 → **빈칸**, 절차·장애 대응 → **순서 맞추기**, 설정 오류 → **읽고 고치기(터미널)**, 개념·원인 구분 → 객관식.
- 기존 문제형 세트(55~87 중 23개)의 객관식 일부를 빈칸·순서·읽고 고치기로 바꾸거나 형식 변형 세트를 더하는 작업은 후속 과제다. 새 형식(짝 맞추기, 오류 찾기)은 `spec_question_types.md` 후보로 남아 있다.
- 적용 세트: 88(설정 읽고 고치기), 89(Kafka 명령·출력), 90(관측 쿼리·메트릭), 91(MariaDB·Galera 점검), 92(서비스 메시 YAML), 93(Jenkins 운영 실무: PVC 속 결과물, 도구 컨테이너로 git).
- 첫 적용: 세트 88 "설정 파일 읽고 고치기" (빈칸 3, 순서 1, 객관식 2, 터미널 5).

## 진행 방식

1. 한 번에 세트 하나씩: 근거 노트를 읽고 → 문제를 쓰고 → `check-migrations`·`check-content`(+ 실습이면 `verify:quests`) → 이 문서의 "상태" 갱신.
2. 노트가 부족한 항목(A4, A5, B6, C4)은 먼저 노트를 보강하거나, 사용자가 읽을 장을 정해 준다. 부족한 노트를 일반 지식으로 메우면 그 사실을 세트 설명과 보고에 남긴다.
3. 이미지·클러스터 변경이 필요한 항목(A3, A7, B3 실습)은 배포 영향이 있어 별도로 확인받고 진행한다.

## 확인할 결정

1. **A 그룹의 순서**: A1·A2·A3(개념)·A11·ILM 은 완료. 남은 기본 제안은 A6 → A12 → A13 → A9 → A10 (이미 노트가 충분한 것 먼저), 노트 보강이 필요한 A4·A5 는 뒤. 사내에서 더 급한 것이 있으면 당겨 주세요.
2. **Istio(A3)**: 공유 클러스터에 CRD 만 설치하는 것을 허용할지, YAML 읽기·빈칸 형식으로만 갈지.
3. **A7(MariaDB 실습)**: 샌드박스 이미지에 MariaDB 서버를 넣는 것(이미지 크기·배포 시간 증가)을 허용할지.

## 문제 해결 상황 커버리지 (2026-10-30 점검)

원칙: **기본기 먼저, 그다음 상황집.** 상황집을 만들기 전에 그 분야의 기본기 세트가 있는지 점검하고 비어 있으면 먼저 채운다. 모든 애플리케이션·미들웨어 분야에 "문제 해결 상황집"(오류 메시지 → 원인 → 해결, 샌드박스에서 고장 상태를 만들고 복구를 채점)을 둔다. 현장 정보 없이 누구나 만날 일반 상황으로 쓴다.

적용 완료: Elasticsearch REST 기본기 112·상황집 113, Vault 입문 110·백업과 복원 111(읽기·판단형, 이미지에 vault 넣지 않음), MariaDB 백업·복원 109(실습 이미지에 mariadb 추가), Prometheus 기본기 103(up·알림 규칙·Alertmanager), 상황집 104, Redis 상황집 102, 동시성 100(경쟁 상태·락·데드락·멱등성, 실습), 이벤트 스트리밍 101(컨슈머 그룹·오프셋·전달 보장·순서·DLQ·Outbox, 읽기·판단형), Redis 99(접속과 키 관리, 기본기), HAProxy 98(문제 해결 상황집), 도커 97(문제 해결 상황집), Git 94(처음부터 올리기), 95(문제 해결 상황집), 96(`.gitignore`·`git rm --cached`).

| 분야 | 현재 | 빈 곳 (다음 후보) |
|---|---|---|
| 도커 | 97 (완료) | 컨테이너가 바로 종료, 포트 충돌, 이미지 pull 실패, 디스크 가득(prune), 로그 읽기 |
| k8s | 23, 33 | Pending/CrashLoopBackOff/ImagePullBackOff 는 있음. Service 연결 안 됨, PVC Pending 보강 |
| 리눅스 | 16, 18 | 권한 거부, 포트 사용 중 프로세스 찾기, 디스크 가득(inode) |
| HAProxy | 98 (완료) | 503, 백엔드 DOWN, 포트 충돌, 설정 오타, soft reload |
| Redis | 60(자료구조), 99(접속·키 관리), 83(심화) | 상황집 102(OOM·연결 거부·느린 명령·TTL 누락·연결 한도) 완료 (redis-server 있음) |
| Kafka | 73, 88, 89, 114 | consumer lag, under-replicated, advertised listener 오류 (읽기 위주, 실습은 설정 고치기) |
| Elasticsearch | 62·71·76(개념), 88, 112(REST 기본기), 113(상황집) | 완료 (파일·응답 읽기형) |
| MariaDB/Galera | 59, 73, 91, 109(백업·복원 실습) | 연결 수 초과, 느린 쿼리, deadlock, 복제 설정 실습 |
| Prometheus/Loki | 57, 90, 103(알림 기본기), 104(상황집) | Loki/LogQL 상황집 (로그가 안 들어옴, 레이블 폭증) |
| Jenkins/Nexus/Harbor | 93, 116 | 빌드 실패 읽기, agent 연결 실패, 디스크 가득 |
| 인프라 | 55, 61, 117 | 117 완료: 층별 점검, refused/timeout, DNS 지연, 시간 오류, MTU |

### 동시성·이벤트 묶음 (미들웨어 단원 27, 2026-10-30)

기본기 먼저: 100(동시성), 101(이벤트 스트리밍) 완료. 다음 상황집 후보:
- 동시성 상황집: **완료 (세트 115)** — stale lock, 데드락 로그 읽기, 이중 처리, 재시도 폭주.
- 이벤트 스트리밍 상황집: **완료 (세트 114, Kafka 문제 해결 상황집)** — consumer lag 증가, 리밸런싱 폭주, 중복 처리, 순서 뒤바뀜, 컨슈머가 같은 메시지를 계속 재처리(poison pill). Kafka 가 샌드박스에 없어 출력 해석·순서·빈칸 위주.

### 필수 과정: 백업·복원 (사용자 방향 2026-10-31)

"MariaDB, Vault 덤프 복원 등은 필수 과정." 109(MariaDB 덤프·복원)는 실제로 해 본다. 일반 리눅스 이미지(`etude-linux`, 319MB)는 그대로 두고, 그 위에 MariaDB 층만 더한 별도 이미지 `etude-linux-db`(샌드박스 타입 `linux-db`, `Dockerfile.linux-db`)를 DB 세트에서만 쓴다. 층을 공유해 추가 디스크는 약 280MB, 기동·덤프·복원은 512MiB 제한에서 약 2초, 메모리 약 85MB. 부담이 크면 109 를 텍스트 기반으로 되돌리고 `linux-db` 를 제거한다. HashiCorp Vault(110 입문, 111 스냅샷 백업·복원)는 바이너리가 커서(수백 MB) 이미지에 넣지 않고 읽기·판단형으로 만들었다 (사용자 결정 2026-10-31). 그 외 백업·복원 후보: Redis(RDB/AOF 복원), Elasticsearch 스냅샷, etcd 스냅샷(k8s), Git 저장소 백업.

- **Redis 백업·복원 (세트 118, 2026-10-31):** 기본 이미지의 `redis-server`·`redis-check-rdb` 만으로 실습한다(추가 이미지 없음). SAVE/BGSAVE, RDB·AOF 손실 범위, "저장 없이 내리고(`shutdown nosave`) 파일 교체 후 시작" 복원 순서, AOF 가 켜져 있으면 RDB 복원이 무시되는 함정, 백업 파일 검사. 이미지의 Redis 는 6.x 라 AOF 가 `appendonly.aof` 한 파일이다(7 이상은 `appendonlydir`).
- 남은 백업·복원 후보: etcd 스냅샷, Elasticsearch 스냅샷, Git 저장소 백업.

### k8s 클러스터 운영 영역 채우기 (CKA 범위 모음의 선행 작업, 2026-10-31)

CKA 영역 중 클러스터 아키텍처·운영(25%)과 트러블슈팅의 노드·컨트롤 플레인 부분이 비어 있었다. 샌드박스 학습자 권한(자기 네임스페이스 edit)과 도구(`etcdctl`·`kubeadm` 없음) 한계로 직접 실행은 어려워 **읽기·순서·빈칸형**으로 채운다. 새 단원 29 `클러스터 운영·보안`(k8s).

| 세트 | 내용 |
|---|---|
| 119 | RBAC 읽기: Role·RoleBinding·ServiceAccount, ClusterRole, forbidden 오류, can-i, 최소 권한 |
| 120 | 클러스터 관리: etcd snapshot save/restore, kubeadm 업그레이드 순서, 인증서 만료, static Pod |
| 123 | 리눅스 cron(단원 4): 다섯 칸, 환경 차이(PATH), %, 로그, flock 겹침 방지 — 실습 3 |
| 124 | 리눅스 SSH 문제 해결(단원 4): publickey, 호스트 키 변경, 권한 700/600, ssh config — 실습 3 |
| 122 | 스토리지 개념(단원 8): PV·PVC·StorageClass, 접근 모드, reclaimPolicy, 동적 프로비저닝, 볼륨 확장 |
| 121 | 노드·컨트롤 플레인 장애: describe node Conditions, kubelet, apiserver 연결 거부, 스케줄러, DiskPressure, crictl |

다음 단계(콘텐츠 이후): `quest_set` 의 CKA 영역 컬럼과 "CKA 범위 모음" 화면.

- **방향 (2026-10-31):** 쉬운 문제를 대량으로 두어 매일 반복하게 한다. 심화 후보는 데이터베이스, 리눅스, OS, k8s, 컴퓨터 원리. 자료 후보(dev-notes): csapp, modern-os, database-internals, mysql-internals, db-internals.

### 쉬운 문제 대량 세트 (2026-10-31)

쉬운 문제를 많이 두어 매일 반복하게 한다. 세트당 20~30문제, 한 문제는 한 개념, 퀴즈형(컨테이너 없음) 우선.

| 세트 | 내용 |
|---|---|
| 125 | DB 기초 1 개념(퀴즈 23): 행·열, SHOW/USE/DESC, SELECT, LIMIT, AS |
| 126 | DB 기초 1 실습(linux-db 8): 직접 쳐 보며 구경하기 |
| 127 | 리눅스 쉬운 문제 1(퀴즈 31): pwd·ls·cd·mkdir·touch·cp·mv·rm·cat, 옵션, >·>> |
| 132 | k8s 쉬운 문제 3(퀴즈 31, 단원 7): Namespace, ConfigMap·Secret, base64 는 암호화가 아님, 환경 변수·파일 마운트, CreateContainerConfigError, label |
| 131 | 리눅스 쉬운 문제 3(퀴즈 31): IP·포트·DNS, ping·curl·ss·nc, refused, grep 옵션, sort·uniq, sed·awk, tee |
| 130 | k8s 쉬운 문제 2(퀴즈 30): YAML 들여쓰기·뼈대, selector·라벨, requests/limits, Service 포트, OOMKilled·Evicted·FailedScheduling, explain·dry-run |
| 129 | 리눅스 쉬운 문제 2(퀴즈 31): rwx·숫자 권한, chown·sudo, PID·kill, df·du·free, 파이프, wc·sort·uniq·cut |
| 128 | k8s 쉬운 문제 1(퀴즈 31): Pod·Deployment·Service·Namespace, READY·Pending·ImagePullBackOff, kubectl 기본 명령 |

다음: 리눅스·k8s 쉬운 문제 세트를 계속 늘린다(리눅스 2~5: 권한·프로세스·텍스트 도구·네트워크 기본, k8s 1~4: 용어·kubectl·YAML·상태 읽기).
