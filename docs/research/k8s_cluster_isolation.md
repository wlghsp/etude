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

k3d 이미지를 호스트에 미리 pull해두면 클러스터 기동을 30초 이내로 줄일 수 있다.

```bash
# 서버 시작 시 1회 실행
docker pull rancher/k3s:latest
docker pull rancher/k3d-proxy:latest
```

---

## 결론

| 구분 | 현재 (namespace) | 향후 (클러스터 per user) |
|------|-----------------|--------------------------|
| 서버 스펙 | 기존 서버로 충분 | 32GB / 16core 이상 |
| 격리 수준 | namespace 레벨 | 클러스터 레벨 (완전) |
| 가능한 퀘스트 | pod/deploy/svc 기초 | RBAC, CRD, 클러스터 운영 |
| 구현 복잡도 | 낮음 (현재 구현됨) | 중간 (k3d CLI 호출 추가) |
| 전환 조건 | — | 32GB 이상 서버 확보 시 |

서버 자원이 확보되면 sandbox 타입을 `k8s-isolated`로 추가하고 세션형으로 구현하는 것이 자연스러운 전환 경로다.
기존 `k8s` 타입(namespace 격리)은 그대로 유지하면서 병행 운영 가능.
