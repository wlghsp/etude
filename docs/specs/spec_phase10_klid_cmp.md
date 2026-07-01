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
  ├── vcluster-{sessionId}  (Pod) ← 실습자 A 세션
  ├── vcluster-{sessionId}  (Pod) ← 실습자 B 세션
  └── vcluster-{sessionId}  (Pod) ← 실습자 C 세션
```

> `k8s_cluster_isolation.md`는 vcluster 기동을 3~5초로 추정했으나, 2026-07-01 로컬 실측 결과 이미지가 캐시된 상태에서도 **약 33초**가 걸렸다(k3s 컨트롤 플레인 자체의 부팅 시간이 병목, 이미지 pull은 병목이 아님을 확인). 세션 시작 시 매번 새로 생성하면 이 33초를 그대로 사용자가 기다려야 하므로, 아래 "pre-warming pool"로 이 대기시간을 없앤다.

### sandbox 타입 추가

기존 `k8s` 타입(namespace 격리, Phase 6)은 그대로 유지한다. 신규 `k8s-isolated` 타입을 추가해 병행 운영한다.

| 항목 | 기존 `k8s` | 신규 `k8s-isolated` |
|------|-----------|---------------------|
| 격리 단위 | namespace | vcluster (완전 격리) |
| `kubectl get nodes` | 공유 클러스터 노드 노출 | 자기 vcluster만 보임 |
| ClusterRole/CRD | 실습 불가 | 실습 가능 |
| 생성/삭제 시점 | 컨테이너 생성/삭제와 함께 namespace 생성/삭제 | 컨테이너 생성/삭제와 함께 vcluster 생성/삭제 (세션형) |
| 리소스 | 거의 없음 | ~200MB RAM/세션 |

### Pre-warming pool — 33초 대기 제거

vcluster 생성이 세션 시작 시점에 일어나면 실습자가 33초를 그대로 기다려야 한다. 대신 **미리 만들어둔 유휴 vcluster를 세션에 즉시 배정**하고, 배정으로 줄어든 pool을 백그라운드로 재보충하는 방식을 쓴다.

```
[pool: 유휴 vcluster N개 항상 유지, 기본 N=2]
  vcluster-pool-a  (대기 중)
  vcluster-pool-b  (대기 중)

세션 시작 요청
  → pool에서 1개 꺼내 즉시 세션에 배정 (대기시간 없음)
  → 백그라운드로 새 vcluster 1개 생성해 pool 채움 (다음 요청을 위해)

세션 종료
  → 배정됐던 vcluster는 삭제 (재사용하지 않음 — 실습자가 클러스터 레벨까지 변경했을 상태라 재사용 시 격리 보장 어려움)
```

| 항목 | 값 |
|------|-----|
| pool 크기 (N) | 2 (기본값, 운영 중 트래픽 보고 조정) |
| pool 재보충 방식 | 배정 즉시 비동기로 신규 생성 시작 — 사용자 응답과 분리 |
| pool 부족 시 | 재보충이 33초 안에 못 끝나 pool이 빈 상태로 요청이 들어오면, 기존처럼 그 자리에서 생성 후 대기 (fallback) |
| 세션 종료 후 재사용 | 하지 않음 — 실습자가 vcluster 내부에서 클러스터 레벨 리소스(RBAC, CRD 등)까지 변경 가능해 재사용 시 이전 세션 흔적이 남을 위험. 항상 삭제 후 신규 생성으로 pool 채움 |

### 백엔드 변경 포인트

[k8s_cluster_isolation.md](../research/k8s_cluster_isolation.md) 88-105행 방향을 pool 방식에 맞게 확장한다.

```
현재(k8s):      exec('kubectl create namespace quest-{id}')
k8s-isolated:   pool에서 유휴 vcluster 1개 꺼내 세션에 배정
                → 배정된 vcluster의 kubeconfig를 etude-k8s 컨테이너에 주입
                → 비동기로 신규 vcluster 생성해 pool 재보충
                → 세션 종료 시 배정됐던 vcluster delete (pool에 반납하지 않음)
```

| 파일 | 변경 내용 |
|------|-----------|
| `terminal.ts` | `k8s-isolated` sandbox type 분기 — pool에서 vcluster 배정, 세션 종료 시 삭제 |
| `sandbox.ts` | `k8s-isolated` 신규 타입 처리 — vcluster kubeconfig 주입 (NodePort 기반 server 주소 치환 포함) |
| `services/vcluster-pool.ts` (신규) | pool 상태 관리 — 유휴 목록 유지, 배정, 비동기 재보충 |
| `backend/db/01_sandbox.sql` | `k8s-isolated` 행 추가 |

### vcluster 생성 시 필수 옵션

로컬 검증으로 확정된 옵션 (네트워크 경로 문제 해결에 필수):

```bash
vcluster create vcluster-{poolId} --connect=false \
  --set "controlPlane.proxy.extraSANs={k3d-etude-server-0}"
```

> vcluster 0.35.1부터 전용 `--tls-san` CLI 플래그가 없어졌다(`unknown flag: --tls-san`). Helm values 경로(`controlPlane.proxy.extraSANs`)로 `--set` 옵션을 통해 설정해야 한다.

생성 후 Service를 NodePort로 전환하고 kubeconfig의 `server` 주소를 치환하는 과정은 아래 "네트워크 경로" 절차를 따른다.

### 검증 환경 — 로컬에서 1세션 단위로 검증 가능 (2026-07-01 확인)

애초에 "vcluster는 서버급 리소스가 전제라 로컬 재현 불가"로 판단했으나, 실제로 로컬 k3d 클러스터(`etude`) 위에 vcluster 1개를 직접 띄워 검증한 결과 **1세션 단위 동작은 로컬(Colima)에서도 그대로 재현 가능**하다. 24GB RAM은 "여러 세션을 동시에 운영"하기 위한 서버 스펙이지, vcluster 자체가 로컬에서 못 뜨는 게 아니다.

다만 **동시 다중 세션의 성능/리소스 여유**는 로컬에서 검증할 수 없고 서버에서만 확인 가능하다.

### 네트워크 경로 — 컨테이너에서 vcluster 접속 시 주의사항 (로컬 검증으로 확정)

`etude-k8s` 컨테이너는 Docker 브리지 네트워크(`k3d-etude`)에 있고, vcluster의 API 서버는 k3s **Pod 내부**에서 뜬다. vcluster 생성 직후 기본 kubeconfig의 `server` 주소(`https://localhost:8443`, `vcluster-test.vcluster-vcluster-test.svc` 등 ClusterIP 기반)는 Docker 브리지 네트워크에서 라우팅되지 않아 컨테이너에서 접속 불가.

**해결**: 기존 `k8s` 타입(Phase 6)이 API 서버 주소로 `k3d-etude-server-0`(호스트 노드 컨테이너 이름)을 쓰는 것과 동일한 경로를 확보해야 한다.

1. vcluster의 Service를 **NodePort**로 노출 (`vcluster create --expose` 옵션 또는 생성 후 `kubectl patch svc`)
2. kubeconfig의 `server`를 `https://k3d-etude-server-0:{nodePort}`로 치환
3. vcluster 생성 시 `--set "controlPlane.proxy.extraSANs={k3d-etude-server-0}"` 옵션으로 인증서에 호스트 노드 이름을 SAN으로 포함시켜야 함 (안 하면 TLS 인증서 검증 실패 — `--insecure-skip-tls-verify`로 우회 가능하나 보안상 권장 안 함)

로컬 검증 절차 (재현 가능):
```bash
vcluster create vcluster-test --connect=false
kubectl patch svc vcluster-test -n vcluster-vcluster-test \
  -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"protocol":"TCP","targetPort":8443,"nodePort":30443}]}}'
kubectl get secret vc-vcluster-test -n vcluster-vcluster-test -o jsonpath='{.data.config}' | base64 -d > kubeconfig.yaml
sed -i '' 's|https://localhost:8443|https://k3d-etude-server-0:30443|' kubeconfig.yaml
# 이 kubeconfig를 etude-k8s 컨테이너에 마운트하면 kubectl 사용 가능 (TLS SAN 미설정 시 --insecure-skip-tls-verify 필요)
```

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
