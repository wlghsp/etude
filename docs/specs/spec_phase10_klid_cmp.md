# Phase 10 명세 — vcluster 전환 + KLID CMP 현장실습

## 목표

[KLID_CMP_deploy_guide.md](../sources/KLID_CMP_deploy_guide.md)(오케스트로 CMP 배포 절차)를 현장실습형 퀘스트 세트로 만든다.
이 실습은 여러 namespace, Helm 배포, ClusterRole/CRD 같은 클러스터 레벨 리소스를 다루므로, 기존 [Phase 6](spec_phase6_k8s.md)의 "클러스터 1개 + namespace 격리" 방식으로는 동시 실습이 불가능하다.
따라서 실습자마다 완전히 격리된 k8s 환경(vcluster)을 제공하는 것이 이 Phase의 선행 조건이다.

배경: [docs/research/k8s_cluster_isolation.md](../research/k8s_cluster_isolation.md)

---

## 왜 namespace 격리로 안 되는가

`KLID_CMP_deploy_guide.md`의 실습 내용:

- `helm install -n cmp-gateway`, `-n iaas-cmp`, `-n paas-cmp` 등 **여러 namespace 생성**을 실습자가 직접 함
- cmp-gateway가 Istio Gateway, CRD를 사용 — **클러스터 레벨 리소스**
- Vault unseal, Keycloak realm 설정 — **클러스터 전역 상태**를 실습자가 직접 변경
- 여러 실습자가 동시에 `helm install -n cmp-gateway`를 실행하면 namespace/리소스 이름이 충돌

[k8s_cluster_isolation.md](../research/k8s_cluster_isolation.md) 24-29행에서 정리한 "namespace로 격리 안 되는 것"(ClusterRole, CRD, 클러스터 레벨 리소스, `get nodes`)이 이 실습의 핵심 내용과 정확히 겹친다. 즉 이 실습은 태생적으로 클러스터 레벨 완전 격리가 필요하다.

---

## 인프라 — vcluster 전환

### 방식

[k8s_cluster_isolation.md](../research/k8s_cluster_isolation.md)의 "향후 방식" 중 vcluster를 채택한다 (k3d per user 대비 기동 시간·리소스 효율에서 우위).

```
[호스트 k3d 클러스터 1개 — 상시 가동, Phase 6/8에서 이미 존재]
  ├── vcluster-{sessionId}  (Pod, ~3~5초 기동) ← 실습자 A 세션
  ├── vcluster-{sessionId}  (Pod, ~3~5초 기동) ← 실습자 B 세션
  └── vcluster-{sessionId}  (Pod, ~3~5초 기동) ← 실습자 C 세션
```

### sandbox 타입 추가

기존 `k8s` 타입(namespace 격리, Phase 6)은 그대로 유지한다. 신규 `k8s-isolated` 타입을 추가해 병행 운영한다.

| 항목 | 기존 `k8s` | 신규 `k8s-isolated` |
|------|-----------|---------------------|
| 격리 단위 | namespace | vcluster (완전 격리) |
| `kubectl get nodes` | 공유 클러스터 노드 노출 | 자기 vcluster만 보임 |
| ClusterRole/CRD | 실습 불가 | 실습 가능 |
| 생성/삭제 시점 | 컨테이너 생성/삭제와 함께 namespace 생성/삭제 | 컨테이너 생성/삭제와 함께 vcluster 생성/삭제 (세션형) |
| 리소스 | 거의 없음 | ~200MB RAM/세션 |

### 백엔드 변경 포인트

[k8s_cluster_isolation.md](../research/k8s_cluster_isolation.md) 88-105행 방향을 따른다.

```
현재(k8s):      exec('kubectl create namespace quest-{id}')
k8s-isolated:   exec('vcluster create vcluster-{sessionId} --connect=false')
                → vcluster가 생성한 kubeconfig를 etude-k8s 컨테이너에 주입
                → 세션 종료 시 vcluster delete
```

| 파일 | 변경 내용 |
|------|-----------|
| `terminal.ts` | `k8s-isolated` sandbox type 분기 — vcluster 생성/삭제 |
| `sandbox.ts` | `k8s-isolated` 신규 타입 처리 — vcluster kubeconfig 주입 |
| `backend/db/01_sandbox.sql` | `k8s-isolated` 행 추가 |

### 검증 환경의 제약

vcluster는 24GB RAM 등 서버급 리소스가 전제라 로컬(Colima 등) 환경에서 재현이 어렵다. **로컬에서 코드를 작성하고, 실제 OCI 서버에 배포한 뒤 서버에서 직접 검증**하는 흐름을 취한다. 이는 이 기능의 특성상 발생하는 제약이며, 다른 Phase와 개발 방식이 다르다는 점을 인지하고 진행한다.

---

## 퀘스트 세트 — KLID CMP 배포 실습

sandbox_type: `k8s-isolated` / 이미지: `etude-k8s` (기존 이미지 재사용 가능 여부는 구현 시 확인)

`KLID_CMP_deploy_guide.md`의 순서를 그대로 따른다.

| 단계 | 실습 내용 | 원본 가이드 섹션 |
|------|-----------|------------------|
| 1 | 레포지토리 이미지 업로드 (`nerdctl load`, 태깅/푸시) | 02.images |
| 2 | 인증서 생성 + TLS Secret 생성 | 01.certs |
| 3 | cmp-gateway 생성 (Helm) | 03.cmp-helm/01.cmp-gateway |
| 4 | 미들웨어 배포 — Redis, RabbitMQ, Vault(+unseal), Keycloak(+postgres) | 03.cmp-helm/02.cmp-mdware |
| 5 | IaaS CMP 배포 (Helm) | 03.cmp-helm/03.iaas-cmp |
| 6 | PaaS CMP 배포 (Helm) | 03.cmp-helm/04.paas-cmp |
| 7 | Gateway 및 서비스 브로커 기동 | 04.gateway-broker |

### 미확정 사항

- **패키지 반입 방법** — `99.packages/`(이미지 tar, Helm 차트, 인증서 스크립트)를 실습 서버에 어떻게 반입할지 미정. 사내 레지스트리/파일 서버 연동 방법 결정 후 이 명세에 반영한다.
- **채점 기준(grade_cmd)** — 각 단계별로 "무엇이 성공 조건인지"(예: pod Running, Helm release deployed, Vault unsealed 등) 구체적으로 정의 필요.
- **소요 시간** — Vault unseal, Keycloak realm 생성 등 상태 의존적 단계가 많아 세션 유지 시간을 길게 잡아야 할 가능성. 기존 세션 타임아웃 정책과 충돌 여부 확인 필요.

---

## 범위 밖

- 트러블슈팅형 미션(고장난 상태를 진단/수정) — vcluster 인프라가 자리잡은 뒤 같은 환경 위에서 별도로 검토.
- `k8s-isolated` 환경에서 RBAC/CRD 전용 별도 퀘스트 세트 — 이 Phase는 KLID CMP 실습에 집중하고, 범용 RBAC/CRD 세트는 추후 별도 검토.

---

## 검증 기준

- [ ] vcluster CLI가 서버에 설치되어 `vcluster create` 동작 확인
- [ ] `k8s-isolated` sandbox 타입으로 컨테이너 생성 시 vcluster 자동 생성, kubeconfig 주입 확인
- [ ] 세션 종료 시 vcluster 자동 삭제 확인
- [ ] 두 세션을 동시에 열어 `kubectl get nodes`가 서로 다르게 보이는지 확인 (완전 격리 검증)
- [ ] KLID CMP 배포 절차 7단계를 실제 vcluster 안에서 순서대로 실행해 전체 스택이 기동되는지 확인
- [ ] 각 단계 grade_cmd가 실제 배포 상태를 정확히 판별하는지 확인
