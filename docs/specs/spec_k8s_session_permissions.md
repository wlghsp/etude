# k8s 세션 권한 제한 명세 — 학습자에게 클러스터 관리자 권한을 주지 않는다

> 상태: **구현 완료·로컬 검증 완료, 서버 반영 대기 (안 A 채택)** — 결정은 아래 "결정" 참고. [Phase 8d](spec_phase8d_session_security.md)가 "누가 어떤 컨테이너를 다루는가"를 막았다면, 이 명세는 "컨테이너 안에서 클러스터에 무엇을 할 수 있는가"를 다룬다.

## 목표

`k8s` 샌드박스 세션의 `kubectl`이 **자기 네임스페이스 안에서만** 동작하게 한다. 한 학습자의 실수나 장난이 다른 학습자의 세션이나 플랫폼 전체에 영향을 주지 못하게 한다.

## 현황 (실제로 확인한 사실)

- `k8s` 샌드박스는 backend가 마운트하는 kubeconfig를 학습자 컨테이너의 `/root/.kube/config`에 그대로 준다 ([sandbox.ts](../../backend/src/services/sandbox.ts), [terminal.ts](../../backend/src/services/terminal.ts)의 `handleK8sTerminal`).
- 그 kubeconfig의 신원은 **`system:admin`, 그룹 `system:masters`**다. `kubectl auth can-i '*' '*' --all-namespaces`가 `yes`다. **로컬과 운영 서버 모두 확인했다** (서버는 `/home/ubuntu/.kube/config-etude`).
- 격리는 세션마다 네임스페이스를 만들고 `$NS`를 치환하는 **관례**일 뿐, 권한으로 강제되지 않는다. 학습자는 `kubectl get secrets -A`, 다른 사람의 네임스페이스 삭제, `vcluster-pool-*` 네임스페이스 접근, 노드 변경이 모두 가능하다.
- 클러스터에는 학습자 세션 외에 `vcluster-pool-*`(`k8s-isolated`용 미리 만든 가상 클러스터)가 있다. 운영 서버에서 확인한 네임스페이스는 `default`, `kube-*`, `vcluster-pool-*` 뿐이라, 영향 범위는 **회사 업무 시스템이 아니라 이 플랫폼 자체**(다른 학습자의 세션, pool, 클러스터 가용성)로 보인다.
- 세트 13은 클러스터 범위 `PersistentVolume`을 `hostPath`로 만든다. 권한을 제한하면 이 퀘스트의 설계가 부딪힌다 (아래 "설계 제약").

## 위협 모델

사용자는 **사내 구성원**이다. 악의적 공격자보다는 **실수**(다른 사람 네임스페이스를 지우는 `kubectl delete ns --all`)와 **호기심/장난**이 현실적인 위험이다. 그래도 한 명의 실수로 동시에 실습 중인 다른 구성원의 세션이 끊기거나 pool이 사라질 수 있어, 방치할 이유는 약하다.

## 설계 제약

`hostPath` `PersistentVolume`은 노드의 임의 경로를 마운트할 수 있다. 학습자에게 PV 생성 권한을 주면 `hostPath: /` 로 노드 파일시스템에 닿을 수 있어 **네임스페이스 제한이 무력화**된다. 그래서 "자기 네임스페이스 권한만 주고 PV는 허용"은 안전하지 않다. 세트 13(13.1~13.4)은 이 지점을 해결해야 한다.

## 설계 선택지

| 안 | 방식 | 장점 | 한계 |
|----|------|------|------|
| **A. 세션별 제한 kubeconfig** | 세션 시작 시 backend(관리자 권한)가 네임스페이스와 ServiceAccount, Role, RoleBinding을 만들고, 그 ServiceAccount 토큰으로 만든 kubeconfig를 컨테이너에 준다. 관리자 kubeconfig는 학습자에게 주지 않는다 | 기존 `k8s` 세트를 유지한 채 권한만 좁힌다. 검증 러너(V4)로 퀘스트 38개가 그대로 통과하는지 확인할 수 있다 | 세션마다 리소스가 늘고 정리 대상이 늘어난다. 세트 13은 PV 퀘스트를 다시 설계해야 한다(아래) |
| **B. `k8s`를 `k8s-isolated`(vcluster)로 이전** | 세트 6, 12, 13, 14를 세션별 vcluster에서 실행한다. 학습자는 자기 vcluster 안에서만 관리자다 | 권한 모델을 새로 짤 필요가 없고 격리가 가장 강하다. 이미 pool 구조가 있다 | 세션당 vcluster 비용(메모리, 생성 시간). pool 크기(2)를 넘는 동시 접속은 느려진다. 노드 자원은 호스트와 공유한다 |
| **C. 현상 유지 + 위험 문서화** | 아무것도 바꾸지 않는다 | 비용 없음 | 위 위험이 그대로 남는다 |

### 세트 13의 PV 퀘스트 처리 (A를 택할 경우)

- PV를 직접 만드는 퀘스트의 의도는 "PV와 PVC의 관계 이해"다. 학습자가 `hostPath` PV를 만들게 하지 말고, **backend가 세션 시작 시 해당 세션 전용 PV를 미리 만들어 두거나**, k3s의 기본 `local-path` StorageClass로 **동적 프로비저닝**을 쓰게 바꾼다(PVC만 만들면 PV가 자동 생성).
- 이 경우 13.1(PV 생성)의 내용이 달라진다. 콘텐츠 변경이므로 사용자 확인이 필요하다.

### 추천: A (단, 세트 13 퀘스트 재설계 포함)

격리 강도는 B가 높지만, 현재 퀘스트와 운영 구조를 거의 바꾸지 않으면서 가장 큰 구멍(전체 관리자 권한)을 막는 것은 A다. 그리고 이 프로젝트에는 이미 **변경의 안전망이 있다**: 채점 검증 러너(V4)가 제한된 kubeconfig로 `k8s` 세트 38개가 여전히 통과하는지 자동으로 확인한다.

## 결정

1. **안 A(세션별 제한 kubeconfig)를 채택**한다.
2. 세트 13은 **`local-path` 동적 프로비저닝**으로 바꾼다. 학습자는 PV를 만들지 않고 PVC만 만든다. k3s의 기본 StorageClass가 PV를 자동으로 만들고, PVC(네임스페이스)가 지워지면 `reclaimPolicy: Delete`로 PV도 함께 지워진다. 앞서 고친 PV 누수도 이 방식에서는 생기지 않는다.
3. 학습자 권한은 **자기 네임스페이스의 `edit`** + **노드·네임스페이스 목록 읽기**(퀘스트 6.1, 6.2용)다.

### 설계 세부

- **관리자 kubeconfig를 학습자 컨테이너에 주지 않는다.** `handleK8sTerminal`은 DB의 `binds`(`KUBECONFIG_HOST_PATH` 마운트)를 무시하고 컨테이너를 바인드 없이 만든다.
- 세션 시작(backend가 관리자 권한으로 수행): 네임스페이스 생성(+ `etude=session`, Pod Security `baseline` 강제 라벨) → ServiceAccount → `edit` ClusterRole을 가리키는 RoleBinding(네임스페이스 한정) → 읽기 전용 ClusterRole(`nodes`, `namespaces`: get/list/watch)을 가리키는 ClusterRoleBinding(`etude=session` 라벨) → 토큰(8시간) → 제한 kubeconfig를 컨테이너에 주입(실행 환경 변수로 전달해 `/root/.kube/config`에 쓴다).
- 세션 종료: ClusterRoleBinding 삭제 → 네임스페이스 삭제(`--wait=false`). 기동 시 정리는 `etude=session` 라벨의 고아 ClusterRoleBinding도 지운다.
- **Pod Security `baseline`이 필요한 이유:** 네임스페이스 `edit`만으로는 파드 스펙의 `hostPath` 볼륨이나 `privileged: true`로 노드 파일시스템에 닿아 관리자 권한을 얻을 수 있다. `baseline`은 hostPath, privileged, hostNetwork 등을 막는다. 퀘스트가 쓰는 `nginx`, `ubuntu`, `busybox`, bitnami 차트는 `baseline`을 통과해야 하며, 이는 검증 러너가 확인한다.
- 토큰 만료(8시간)가 지나면 학습자는 재연결해야 한다.

## 수용 조건 (A 기준 초안)

- [x] 학습자 컨테이너의 kubeconfig로 `kubectl auth can-i '*' '*' --all-namespaces`가 `no`다
- [x] 자기 네임스페이스에서는 퀘스트에 필요한 동작이 가능하다 (검증 러너 `k8s` 세트 38개 통과)
- [x] 다른 네임스페이스의 리소스 조회·변경·삭제가 거부된다 (`kube-system` secret, 다른 세션 네임스페이스, `vcluster-pool-*`)
- [x] 클러스터 범위 리소스(노드, `PersistentVolume`, `ClusterRole` 등) 생성·수정이 거부된다
- [x] 세션 종료 시 ServiceAccount, Role, RoleBinding, 토큰이 네임스페이스와 함께 정리된다
- [x] 관리자 kubeconfig가 학습자 컨테이너 파일시스템에 남지 않는다 (DB `binds`에 마운트가 있어도 무시한다)
- [x] `hostPath` 볼륨이나 `privileged` 파드 생성이 거부된다 (Pod Security `baseline`)
- [x] 노드·네임스페이스 목록 읽기(퀘스트 6.1, 6.2)는 가능하다
- [x] 세트 13이 PV를 직접 만들지 않고 PVC만으로 통과한다

## 테스트 전략

- 단위: 세션 시작·종료 때 만드는 리소스 정의와 kubeconfig 생성(서버 주소, CA, 토큰 위치)
- 실제 클러스터: 검증 러너를 제한 권한으로 돌려 `k8s` 세트가 통과하는지, 그리고 권한 부정 케이스(`can-i`가 `no`)를 확인한다

## 범위 밖

- 학습자가 실행하는 파드의 리소스 제한(CPU, 메모리). 단 Pod Security `baseline`은 이 명세의 범위다
- `docker` 계열 샌드박스(DinD)의 격리 (별도로 검토)
- 로그인·세션 인증 (8d에서 처리됨)

## 구현과 검증 결과 (2026-10-29)

**구현:** [k8s-session.ts](../../backend/src/services/k8s-session.ts)(세션 권한 생성·삭제), [container-kubeconfig.ts](../../backend/src/services/container-kubeconfig.ts)(제한 kubeconfig 주입), [terminal.ts](../../backend/src/services/terminal.ts)의 `handleK8sTerminal`(관리자 kubeconfig 마운트 제거), 기동 정리(`etude=session` 고아 ClusterRoleBinding), 검증 러너의 k8s 샌드박스(앱과 같은 제한 권한). 세트 13은 PVC 중심으로 재설계했다.

**검증됨 (로컬 실제 클러스터):**
- 권한 프로브 18/18 (`npm run verify:k8s-permissions`): 허용 6(자기 네임스페이스 파드·디플로이먼트·ConfigMap, baseline을 통과하는 nginx 파드, 노드·네임스페이스 목록), 거부 12(전체 관리자, `kube-system`·전체 네임스페이스 secret, `default` 파드, 노드 변경, PV·ClusterRole·ClusterRoleBinding 생성, hostPath·privileged·hostNetwork 파드, kubeconfig의 관리자 인증서).
- 거부 사유가 실제 정책 위반임을 메시지로 확인했다: `violates PodSecurity "baseline:latest": hostPath volumes / privileged / host namespaces`, `User "system:serviceaccount:…:learner" cannot list resource "secrets" in … "kube-system"`. 정상 파드는 생성된다.
- `k8s` 세트 6, 12, 13, 14의 38개 퀘스트가 모두 제한 권한에서 정답 통과·무행동 실패 (검증 러너). helm 차트 설치도 `baseline`을 통과한다.
- 동적 프로비저닝: PVC는 파드가 쓰기 전까지 `Pending`, 마운트 후 `Bound`, 쓰기·읽기 가능, **네임스페이스를 지우면 동적 PV가 자동 삭제**된다.
- 검증 후 클러스터에 남은 것 없음 (검증 컨테이너, `verify-*` 네임스페이스, `etude=session` ClusterRoleBinding, PV). 공유 ClusterRole `etude-learner-cluster-read` 하나만 의도대로 남는다.
- 단위 테스트: 세션 권한 서비스 12건, 앱 통합 6건, 러너 5건, 프로브 8건, 기동 정리 2건.

**운영 서버 사전 확인 (읽기 전용, 검증됨):** 기본 StorageClass `local-path`(Delete), k3s v1.35.5, `edit` ClusterRole 존재, backend의 kubeconfig에 `certificate-authority-data`가 있고 API 서버 주소가 기본값 `https://k3d-etude-server-0:6443`과 같다. 별도 환경 변수 설정은 필요 없다 (`K8S_SESSION_API_SERVER`로 바꿀 수 있다).

**미검증:**
- 실제 앱 세션(브라우저 → `handleK8sTerminal`)으로 끝까지 돌려 보지는 않았다. 앱 경로는 fake docker 단위 테스트로, 같은 권한 로직은 검증 러너와 프로브로 실제 클러스터에서 확인했다.
- 운영 서버에서의 동작. 배포 후 `npm run verify:k8s-permissions`는 서버에서 돌리기 어렵다(DB·Docker 필요). 대신 배포 후 학습자 계정으로 k8s 세트를 열어 `kubectl auth can-i '*' '*' --all-namespaces`가 `no`인지 확인한다.

## 서버 반영 순서

1. **서버 DB**: `backend/db/update_2026-10-29_k8s_set13_pvc.sql` 실행 (세트 13의 13.1~13.4, `quest.id` 유지). 코드 배포 **전에** 먼저 하면 새 퀘스트 설명이 먼저 보이고, 후에 하면 옛 퀘스트가 PV 생성에서 막힌다. **코드 배포와 같은 시점에 하는 것이 좋다.**
2. **코드 배포**(`gh workflow run deploy.yml`): backend 재시작. 진행 중인 `k8s` 세션은 끊긴다.
3. 배포 후 학습자 계정으로 `k8s` 세트를 열어 권한이 제한됐는지 확인한다.
4. 기존 학습자가 이미 푼 13.x 진행 기록은 그대로 남지만 문제 내용이 바뀐다 (제목·내용이 다름).
5. 운영 `sandbox` 테이블의 `k8s.binds`(관리자 kubeconfig 마운트)는 코드가 무시하므로 바꾸지 않아도 된다. 정리 목적으로 `NULL`로 바꿀 수 있다.

## 알려진 한계

- 토큰 유효기간 8시간. 지나면 `kubectl`이 인증 실패하므로 환경 초기화(재연결)가 필요하다.
- `docker` 계열 샌드박스(DinD, `Privileged`)의 격리는 이 명세의 범위가 아니다.

## 자원 제한 추가 (2026-10-29)

권한을 좁힌 뒤에도 한 학습자가 `kubectl scale --replicas=1000` 같은 요청으로 노드 자원을 소진해 다른 세션과 vcluster pool에 영향을 줄 수 있어, 세션 네임스페이스마다 상한을 둔다.

- **ResourceQuota `etude-quota`**: 파드 12, CPU 요청 2·제한 4, 메모리 요청 2Gi·제한 4Gi, PVC 4, 저장 5Gi, 서비스 10.
- **LimitRange `etude-limits`**: 요청/제한을 쓰지 않은 컨테이너에 기본값(요청 cpu 50m·메모리 64Mi, 제한 cpu 500m·메모리 256Mi)을 채우고, 컨테이너 하나의 상한을 cpu 1·메모리 1Gi로 둔다. LimitRange가 없으면 쿼터 때문에 요청/제한 없는 파드가 모두 거부되므로 필수다.
- 둘 다 권한(ServiceAccount, 바인딩, 토큰)을 주기 **전에** 만든다. `edit` 권한으로는 쿼터와 LimitRange를 조회만 할 수 있고 지우거나 고칠 수 없다.
- **실제 파드 상한은 8개다.** 기본 제한(cpu 500m)으로는 `limits.cpu=4`가 `pods=12`보다 먼저 걸린다. 퀘스트의 최대 워크로드(복제 3개)에는 충분하다. 학습자가 제한을 직접 낮추면 더 많은 작은 파드를 만들 수 있지만 CPU·메모리 합계 상한은 넘지 못한다.

**검증됨 (로컬 실제 클러스터):**
- 권한 프로브 22/22 (자원 제한 프로브 4건 추가: 쿼터 조회 허용, 쿼터 삭제·LimitRange 수정 거부, 상한 초과 요청 거부).
- `replicas=60` 디플로이먼트를 만들어도 파드가 8개에서 멈추고 이벤트에 `exceeded quota: etude-quota … limits.cpu=4`가 남는다. 쿼터·LimitRange 삭제 시도는 `Forbidden`.
- `k8s` 세트 38개 퀘스트가 쿼터 아래에서도 모두 통과 (정상 워크로드가 막히지 않는다).
- **미검증:** 운영 서버. 이 변경은 아직 서버에 반영하지 않았다.
