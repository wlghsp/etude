# k8s 샌드박스 격리 설계 검토

## 배경

현재 Phase 6에서는 클러스터 1개를 공유하고 세션마다 namespace를 분리하는 방식을 쓴다.
이 문서는 향후 클러스터 per user 방식으로 전환할 때의 설계를 검토한다.

---

## 현재 방식 — 공유 클러스터 + namespace 격리

```
[k3d etude 클러스터 1개]
  ├── quest-aabb1122 (유저 A 세션)
  ├── quest-ccdd3344 (유저 B 세션)
  └── quest-eeff5566 (유저 C 세션)
```

### 격리되는 것

- Pod / Deployment / Service / ConfigMap 등 — namespace 단위 분리
- grade_cmd에서 `$NS` 치환으로 각자 namespace만 조회

### 격리되지 않는 것

- `kubectl get nodes` — 모든 세션에서 동일한 클러스터 노드 보임
- `kubectl get ns --all-namespaces` — 다른 세션 namespace 보임
- 노드 CPU/메모리 — 한 세션의 heavy workload가 전체에 영향
- ClusterRole, CRD, StorageClass — 클러스터 레벨 리소스

### 채택 이유

서버 자원 제약. k3d 클러스터 1개 기준 ~512MB RAM이므로 20명이면 20개 → 10GB 추가 필요.
기초 실습 수준에서는 namespace 격리로 충분하다.

---

## 향후 방식 — 유저당 독립 클러스터

```
[k3d etude-user-a 클러스터]  ← 유저 A 전용
[k3d etude-user-b 클러스터]  ← 유저 B 전용
[k3d etude-user-c 클러스터]  ← 유저 C 전용
```

### 리소스 추정

유저 1명당 k3d 클러스터 1개 기준:

| 항목 | 필요량 |
|------|--------|
| RAM | ~512MB (클러스터) + ~512MB (실습 워크로드) = ~1GB |
| CPU | 0.5~1 core |
| Disk | ~5GB (이미지 캐시 포함) |

동시 접속자 수별 서버 스펙:

| 동시 사용자 | RAM | CPU | Disk |
|-------------|-----|-----|------|
| 5명 | 8GB | 4 core | 100GB |
| 10명 | 16GB | 8 core | 200GB |
| 20명 | 32GB | 16 core | 400GB |
| 30명 | 48~64GB | 24~32 core | 500GB |

오케스트로 사내 사용(10~20명 동시) 기준이면 32GB RAM / 16 core / 500GB SSD 서버 1대로 충분.
클라우드 기준으로는 AWS m6i.4xlarge (16 vCPU / 64GB) 수준.

### 완전 격리 — 가능해지는 것

- `kubectl get nodes` — 자기 클러스터만 보임
- RBAC 실습 — ClusterRole, ClusterRoleBinding 직접 생성 가능
- CRD 실습 — 다른 사용자와 충돌 없음
- 클러스터 레벨 트러블슈팅 — node taint, cordon, drain

---

## 구현 방향

### 클러스터 수명 선택

| 방식 | 설명 | 리소스 | 현재 sandbox와 정합 |
|------|------|--------|---------------------|
| 세션형 | 퀘스트 시작 시 `k3d cluster create`, 종료 시 `k3d cluster delete` | 효율 좋음 | O (sandbox 방식과 동일) |
| 영속형 | 유저별 고정 클러스터, 로그인 시 생성 | 리소스 낭비 | X |

**권장: 세션형.** 현재 컨테이너 생성/삭제 패턴과 동일하고 리소스 효율이 좋다.

### 백엔드 변경 포인트

현재 `dockerode`로 컨테이너를 생성하듯, k3d CLI를 백엔드에서 호출하는 방식으로 sandbox 레이어를 확장한다.

```
현재:  dockerode.createContainer() → 컨테이너 생성
향후:  exec('k3d cluster create etude-{sessionId}') → 클러스터 생성
       → k3d가 생성한 kubeconfig를 etude-k8s 컨테이너에 주입
       → 세션 종료 시 k3d cluster delete
```

변경이 필요한 파일:

| 파일 | 변경 내용 |
|------|-----------|
| `terminal.ts` | k8s sandbox type에서 클러스터 생성/삭제 분기 |
| `sandbox.ts` | `k8s-isolated` 신규 타입 처리 — 클러스터 이름 주입 |
| `init.sql` | sandbox 테이블에 `k8s-isolated` 행 추가 |

### 기동 시간 최적화

기본 k3d 클러스터 기동은 30~45초. 아래 최적화를 조합하면 **10~15초**, 체감은 5~8초까지 줄일 수 있다.

#### 병목 1 — 이미지 pull

서버 시작 시 1회 미리 pull해두면 이 단계는 0초.

```bash
docker pull rancher/k3s:latest
docker pull rancher/k3d-proxy:latest
```

#### 병목 2 — API 서버 ready 대기 (15~20초)

`--wait=0`으로 ready 대기 없이 즉시 반환하고, 백엔드가 별도로 폴링한다.
터미널은 미리 열어두고 API server가 ready되면 kubectl을 사용할 수 있게 되므로 체감 대기가 줄어든다.

```bash
k3d cluster create etude-{id} --wait=0
```

#### 병목 3 — 로드밸런서 컨테이너

k3d 기본 구성에 포함된 `k3d-proxy` (HAProxy) 컨테이너는 퀘스트 실습에 불필요.

```bash
k3d cluster create etude-{id} --no-lb
```

#### 병목 4 — 불필요한 컴포넌트

traefik, metrics-server, local-storage를 끄면 기동 컴포넌트 수가 줄어서 ready 시간이 단축된다.

```bash
k3d cluster create etude-{id} \
  --no-lb \
  --k3s-arg "--disable=traefik@server:0" \
  --k3s-arg "--disable=metrics-server@server:0" \
  --k3s-arg "--disable=local-storage@server:0"
```

#### 수치 정리

| 최적화 조합 | 기동 시간 |
|-------------|-----------|
| 기본 | 30~45초 |
| 이미지 캐시 + `--no-lb` + 컴포넌트 disable | 10~15초 |
| 위 + `--wait=0` + 백엔드 폴링 병렬처리 | 체감 5~8초 |

---

### 대안 — vcluster

k3d 대신 [vcluster](https://www.vcluster.com/)를 쓰면 기동이 **3~5초** 수준이다.
호스트 k8s 클러스터 위에 가상 클러스터를 Pod 형태로 띄우는 방식으로, k3d처럼 컨테이너 여러 개를 올릴 필요 없이 완전한 k8s API를 제공한다.

```
[호스트 k3d 클러스터 1개 — 상시 가동]
  ├── vcluster-user-a  (Pod, ~3~5초 기동)
  ├── vcluster-user-b  (Pod, ~3~5초 기동)
  └── vcluster-user-c  (Pod, ~3~5초 기동)
```

리소스도 훨씬 가볍기 때문에 클러스터 per user 방식을 현실적으로 만들어주는 옵션이다.
단, 호스트 k3d 클러스터가 상시 가동 상태여야 한다는 전제가 있다.

| 구분 | k3d per user | vcluster |
|------|-------------|----------|
| 기동 시간 | 10~15초 (최적화 후) | 3~5초 |
| 리소스 | ~1GB RAM/user | ~200MB RAM/user |
| 완전 격리 | O | O |
| 호스트 클러스터 필요 | X (직접 k3d 실행) | O (k3d 1개 상시 가동) |
| 구현 복잡도 | 낮음 | 중간 |

---

## 결론

| 구분 | 현재 (namespace) | 향후 k3d per user | 향후 vcluster |
|------|-----------------|-------------------|---------------|
| 서버 스펙 | 기존 서버로 충분 | 32GB / 16core 이상 | 16GB / 8core 이상 |
| 격리 수준 | namespace 레벨 | 클러스터 레벨 (완전) | 클러스터 레벨 (완전) |
| 가능한 퀘스트 | pod/deploy/svc 기초 | RBAC, CRD, 클러스터 운영 | RBAC, CRD, 클러스터 운영 |
| 기동 시간 | 즉시 (컨테이너만) | 5~15초 | 3~5초 |
| 구현 복잡도 | 낮음 (현재 구현됨) | 중간 (k3d CLI 호출) | 중간~높음 (vcluster CLI) |
| 전환 조건 | — | 32GB 이상 서버 확보 시 | 16GB 이상 서버 확보 시 |

서버 자원이 확보되면 sandbox 타입을 `k8s-isolated`로 추가하고 세션형으로 구현하는 것이 자연스러운 전환 경로다.
기존 `k8s` 타입(namespace 격리)은 그대로 유지하면서 병행 운영 가능.
자원이 넉넉하면 vcluster가 기동 시간과 리소스 효율 모두에서 유리하다.
