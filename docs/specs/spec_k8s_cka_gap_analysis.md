# k8s 콘텐츠 갭 분석 — CKA 방향

> 상태: **초안 — 사용자 우선순위 결정 대기** (2026-10-29). 코드 변경 없음. 읽기 전용 분석.
>
> 방향: 리눅스와 k8s가 핵심이고, k8s는 CKA 준비로 이어진다. 현장 업무가 거의 k8s라서 Docker는 확장하지 않는다 (이미지 push/pull/tag는 세트 5, 8, 11이 이미 다룸).

## 전제 (확인한 사실)

- `k8s` 샌드박스의 학습자 권한은 **자기 네임스페이스의 `edit`** + 노드·네임스페이스 읽기다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Pod Security `baseline`이 강제된다.
- `edit`에는 일반적으로 Role/RoleBinding 생성이 없다 (코드상 쿠버네티스 기본 ClusterRole 정의 기준, 이 클러스터에서 실행해 확인하지 않음 = `미검증`).
- 기존 k8s 세트 4개, 퀘스트 38개 중 k8s 본체는 세트 6, 12, 13 (30개), 세트 14는 Helm (8개).

## CKA 영역별 현황

CKA 시험 비중은 제 기억 기준이며 **최신 CNCF 커리큘럼으로 확인하지 않았다 (`미검증`)**. 착수 전에 확인한다. 기억 기준: 클러스터 아키텍처·설치·구성 25%, 워크로드·스케줄링 15%, 서비스·네트워킹 20%, 스토리지 10%, 트러블슈팅 30%.

| 영역 (기억 기준 비중) | 현재 커버 | 이 플랫폼에서 가능 | 판단 |
|---|---|---|---|
| 워크로드·스케줄링 (15%) | Pod, Deployment, 스케일, 롤링 업데이트, 롤백, ConfigMap/Secret 주입 (6, 12) | 대부분 가능 | 갭: 프로브, 리소스 requests/limits, nodeSelector·affinity·taint(노드 변경 권한이 없어 일부 제한), Job/CronJob, DaemonSet, init 컨테이너, HPA |
| 서비스·네트워킹 (20%) | Service 생성, port-forward (6.9, 13.5) | 대부분 가능 | 갭: Service 유형(NodePort/ClusterIP), 서비스 DNS, Ingress, NetworkPolicy. Ingress 컨트롤러와 NetworkPolicy 적용 여부는 클러스터 설정에 달림 (`미검증`) |
| 스토리지 (10%) | PVC, 마운트, emptyDir (13) | 가능 (PV 직접 생성은 불가, 동적 프로비저닝) | 갭: StorageClass 개념, accessModes·reclaimPolicy 설명, PV 정적 생성은 불가 |
| 트러블슈팅 (30%) | 로그, describe (13.6, 13.7) | 앱 수준은 가능 | 아래 "가장 큰 갭" 참고 |
| 클러스터 아키텍처·설치·구성 (25%) | 없음 | **대부분 불가** | etcd 백업·복구, kubeadm 설치·업그레이드, 노드 관리(cordon/drain), 클러스터 범위 RBAC는 현재 권한·구조로 불가. 네임스페이스 RBAC(Role/RoleBinding/ServiceAccount)도 `edit`로는 막혔을 가능성이 있어 확인 필요 |

## 가장 큰 갭: "고치는" 트러블슈팅이 없다

- 세트 13.6, 13.7은 **이미 깨진 Pod의 로그와 describe 결과를 파일에 저장**하면 통과한다 (채점이 `test -s`, `grep -E "Events|State"`). 원인을 찾아 고치는 과정이 없다.
- CKA와 현장 모두에서 점수와 가치는 "증상 관찰 → 원인 → 수정 → 정상 확인"에 있다. 시나리오: ImagePullBackOff(이미지 이름 오타), CrashLoopBackOff(잘못된 명령), Pending(과도한 resources 요청), Service에 엔드포인트 없음(셀렉터 불일치), ConfigMap 키 오타, 프로브 실패.
- 채점은 상태 기반으로 할 수 있다 (예: Deployment의 가용 레플리카가 정상, 엔드포인트가 비어 있지 않음). 아직 풀기 전에는 실패해야 하는 조건도 자연스럽게 성립한다.

## 두 번째 갭: kubectl 속도·손기술

- CKA는 시간 제한 실기라, 개념보다 `kubectl`을 빠르게 쓰는 능력이 결과를 가른다: `--dry-run=client -o yaml`로 뼈대 만들기, 명령형 생성(`create`, `run`, `expose`, `set`), `-o jsonpath`·`custom-columns`, `kubectl explain`, 컨텍스트·네임스페이스 전환, `alias`·자동완성.
- 현재 세트는 대부분 YAML을 통째로 쓰거나 한 줄 명령을 따라 하는 방식이라 이 능력을 훈련하지 않는다 (제목 기준 확인).
- 구현 비용이 낮다 (새 샌드박스 불필요, 자원 부담 작음).

## 제안 후보 (우선순위는 사용자 결정)

| 후보 | 내용 | 추정 규모 | 비고 |
|---|---|---|---|
| **A. k8s 트러블슈팅 실전** | 깨진 워크로드를 고치는 시나리오 10~12개 | 퀘스트 10~12 | **12개 구현됨: 세트 23, 로컬 검증 12/12** (9~12번은 2026-10-29 추가) (2026-10-29, 세트당 약 2분). 설계 규칙: 장애는 Deployment로 주입(고칠 수 있게), 노드에 캐시된 nginx/busybox만 사용(429 회피), 채점은 spec 확인 + 상한 있는 `kubectl wait`. 서버 동작은 `미검증` |
| **B. kubectl 속도·실전** | dry-run YAML, jsonpath, explain, 명령형 생성, 컨텍스트 | 퀘스트 8~10 | **구현됨: 세트 19 (10개), 로컬 검증 10/10** (2026-10-29). 채점은 리소스 상태 기준, 이미지 pull에 의존하지 않음 |
| **C. 워크로드 확장** | 프로브, requests/limits, Job/CronJob, DaemonSet, HPA | 퀘스트 8~10 | **구현됨: 세트 22 (11개), 로컬 검증 11/11** (2026-10-29). Job/CronJob, DaemonSet, requests/limits, livenessProbe, nodeSelector(Pending이 정상), initContainers, downward API, HPA. 채점은 API 객체 상태 기준으로 Pod 실행에 의존하지 않는다. taint는 노드 변경 권한이 없어 제외 |
| **D. 서비스·네트워킹** | Service 유형, DNS, Ingress, NetworkPolicy | 퀘스트 6~8 | **구현됨: 세트 25 (10개), 로컬 검증 10/10** (2026-10-29). Ingress 컨트롤러·NetworkPolicy 적용 여부는 `미검증`이라 채점은 리소스 설정(API 객체) 기준, 실제 통신은 DNS 접근 1개만 확인 |
| **E. 네임스페이스 RBAC** | ServiceAccount, Role/RoleBinding, `auth can-i` | 퀘스트 4~6 | 현재 `edit`로는 Role 생성이 안 될 가능성 → 권한 설계 변경 필요, 보안 검토 대상 |

추천 순서: **B → A → C → D**, E는 권한 모델을 건드리므로 마지막에 별도 명세로 다룬다.

## 확인이 필요한 것 (착수 전)

1. 최신 CKA 커리큘럼과 비중 (위 표는 `미검증`).
2. 서버 클러스터의 Ingress 컨트롤러·NetworkPolicy 적용 여부 (D의 선행 조건).
3. `edit`로 Role/RoleBinding 생성 가능 여부 (E).
4. 장애 주입(setup_cmd)이 `baseline` Pod Security를 통과하는지 (A의 구현 중 검증 러너로 확인).

## 범위 밖

- etcd 백업·복구, kubeadm, 노드·컨트롤 플레인 장애, 클러스터 범위 RBAC: 별도 VM 환경이 필요해 이 플랫폼 구조 밖이다. 필요하면 실습 환경을 따로 두는 별도 프로젝트로 본다.

## 기본기 점검 (2026-10-29, 세트 6·12·13·14·19 정답 텍스트 검색)

방법: 로컬 DB의 `quest.solution` 키워드 검색 (`검증됨`). 오탐 1건: 세트 13의 `requests:`는 PVC 용량이라 Pod 리소스 requests/limits는 사실상 0건이다.

- **0건 → 세트 20에서 채움(네임스페이스 생성은 권한상 제외):** 네임스페이스 생성, `exec -it`(세트 6.12는 `-it` 없이 `exec`만), `logs -f`, `get -o wide`, `get events`, `rollout status`/`history`, `kubectl cp`, `kubectl edit`, 라벨 셀렉터(`-l`), `config use-context`/`get-contexts`, Job, CronJob, DaemonSet, StatefulSet, 프로브(liveness/readiness), Pod 리소스 requests/limits, nodeSelector·taint, initContainers, Ingress, NetworkPolicy, ServiceAccount/RBAC, HPA
- **1건:** `describe`, `logs --previous`, `delete`
- **충분함:** ConfigMap, Secret, PVC, Helm

→ 가장 기본인 "일상 운영 명령"(네임스페이스, exec -it, logs -f, -o wide, events, rollout status/history, edit, 라벨 셀렉터, delete, context)이 비어 있다. 이것이 갭 분석의 A(트러블슈팅)·C(워크로드) 앞에 와야 한다.

## 세트 23 시나리오 (트러블슈팅)

이미지 오타(ImagePullBackOff), Service 셀렉터 불일치, CrashLoopBackOff(잘못된 command), Pending(과도한 requests), ConfigMap 키 오타(CreateContainerConfigError), 프로브 경로 오류(Ready 안 됨), Service targetPort 오류, 없는 Secret 참조. 추가 구현(9~12): Liveness 프로브 경로 오류(재시작 반복), replicas 0, 메모리 limit 과소(OOMKilled), 환경변수 누락. 후속 후보: PVC Pending(StorageClass 오타, 재생성이 필요해 채점이 무거움), 라벨 오타.

## 세트 26 (스케줄링과 배포 전략)

toleration, nodeAffinity, podAntiAffinity, 롤링 업데이트 전략(maxSurge/maxUnavailable), rollout pause, revisionHistoryLimit, StatefulSet, PodDisruptionBudget, graceful shutdown(terminationGracePeriodSeconds, preStop), kubectl diff — 10개, 로컬 검증 10/10을 연속 2회 통과 (2026-10-29). 노드를 바꿀 권한이 없어 taint 부여 자체는 하지 않고, toleration·affinity 같은 Pod 쪽 설정만 다룬다. 채점은 API 객체 기준.
