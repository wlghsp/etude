# Phase 6 명세 — k8s 기초 실습 세트

## 목표

kubectl이 동작하는 샌드박스 환경을 구성하고, k8s 기초 퀘스트 세트를 제공한다.
로컬 k3d 클러스터 위에 `etude-k8s` 컨테이너를 연결하는 방식으로 구현한다.

---

## 샌드박스 구조

```
[k3d 로컬 클러스터]  ← 서버 기동 시 존재해야 함
       ↑ kubeconfig 볼륨 마운트 (read-only)
[etude-k8s 컨테이너]  ← 사용자 터미널 접속
  kubectl get pods → k3d API server에 실제 요청
```

### 구성 요소

| 항목 | 내용 |
|------|------|
| 클러스터 | k3d로 로컬에 단일 노드 k3s 클러스터 구동 |
| 이미지 | `etude-k8s` — kubectl 바이너리 + bash만 포함 (경량) |
| kubeconfig 주입 | 컨테이너 시작 시 볼륨 마운트 (`/root/.kube/config`) |
| namespace 격리 | 세션마다 `quest-{containerId}` namespace 생성, grade_cmd는 해당 namespace 기준 |

---

## 사전 요구사항

서버 실행 전 로컬에 k3d 클러스터가 기동되어 있어야 한다.

```bash
# k3d 설치 (최초 1회)
brew install k3d

# 클러스터 생성 (최초 1회)
k3d cluster create etude

# kubeconfig 병합 확인
kubectl get nodes  # 정상이면 etude-k8s 환경 준비 완료
```

kubeconfig 위치: `~/.kube/config` (k3d가 자동으로 병합)

---

## Dockerfile.k8s

`backend/docker/Dockerfile.k8s`

```dockerfile
FROM alpine:3.19

# kubectl 설치
RUN apk add --no-cache curl bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

WORKDIR /root
CMD ["bash"]
```

> M3 Mac (ARM64) 기준. amd64 환경이면 `arm64` → `amd64` 로 변경.

---

## sandbox 테이블

`init.sql`에 아래 행 추가:

```sql
INSERT INTO sandbox (type, image, binds, description) VALUES (
  'k8s',
  'etude-k8s',
  '["{KUBECONFIG_HOST_PATH}:/root/.kube/config:ro"]',
  'kubectl 실습 환경 (k3d 클러스터 연결)'
);
```

> `KUBECONFIG_HOST_PATH`는 런타임에 환경변수로 주입. 하드코딩 금지.

---

## 백엔드 변경 — 수정 포인트 요약

| 파일 | 수정 내용 |
|------|-----------|
| `terminal.ts` | `SandboxType`에 `'k8s'` 추가, k8s 분기 처리, namespace 생성/삭제 |
| `sandbox.ts` | binds 플레이스홀더 치환 (`{KUBECONFIG_HOST_PATH}` → 실제 경로) |
| `quest.ts` | `gradeQuest()`에서 `$NS` 치환 + setup_cmd `$NS` 치환 |

---

### 환경변수

`backend/.env`에 추가:

```
KUBECONFIG_PATH=/Users/{username}/.kube/config
```

### sandbox.ts

`getSandboxConfig()` 에서 `k8s` type 처리 시 binds의 `{KUBECONFIG_HOST_PATH}` 를 환경변수로 치환.

```typescript
// binds 내 플레이스홀더 치환
const kubeconfig = process.env.KUBECONFIG_PATH ?? `${process.env.HOME}/.kube/config`
binds = binds.map(b => b.replace('{KUBECONFIG_HOST_PATH}', kubeconfig))
```

### terminal.ts

`k8s` sandbox_type은 DinD처럼 별도 대기 없이 바로 exec shell 연결.
`waitForDocker` 같은 준비 대기 불필요 (kubectl은 즉시 사용 가능).

### namespace 격리

컨테이너 생성 직후 namespace를 생성하고, 세션 종료 시 삭제.

```typescript
// 컨테이너 생성 후
const ns = `quest-${containerId.slice(0, 8)}`
await exec(`kubectl create namespace ${ns}`)

// 컨테이너 제거 전
await exec(`kubectl delete namespace ${ns} --ignore-not-found`)
```

---

## 퀘스트 세트 6 — k8s 기초

sandbox_type: `k8s` / 이미지: `etude-k8s`

모든 퀘스트는 `quest-{ns}` namespace 안에서 실행.

| order | 제목 | 명령어 | setup_cmd | grade_cmd |
|-------|------|--------|-----------|-----------|
| 1 | 클러스터 노드 확인하기 | kubectl get nodes | — | `kubectl get nodes \| grep -i ready` |
| 2 | 네임스페이스 목록 확인하기 | kubectl get namespaces | — | `kubectl get ns \| grep quest-` |
| 3 | Pod 실행하기 | kubectl run | — | `kubectl get pod nginx -n $NS \| grep Running` |
| 4 | Pod 목록 확인하기 | kubectl get pods | `kubectl run nginx --image=nginx -n $NS` | `kubectl get pods -n $NS \| grep nginx` |
| 5 | Pod 로그 확인하기 | kubectl logs | `kubectl run nginx --image=nginx -n $NS` | `kubectl logs nginx -n $NS` |
| 6 | Pod 삭제하기 | kubectl delete pod | `kubectl run nginx --image=nginx -n $NS` | `! kubectl get pod nginx -n $NS 2>/dev/null` |
| 7 | Deployment 생성하기 | kubectl create deployment | — | `kubectl get deploy my-app -n $NS` |
| 8 | Deployment 스케일 조정하기 | kubectl scale | `kubectl create deployment my-app --image=nginx -n $NS` | `kubectl get deploy my-app -n $NS \| grep '3/3'` |
| 9 | Service 생성하기 | kubectl expose | `kubectl create deployment my-app --image=nginx -n $NS` | `kubectl get svc my-app -n $NS` |
| 10 | 리소스 전체 확인하기 | kubectl get all | `kubectl create deployment my-app --image=nginx -n $NS && kubectl expose deployment my-app --port=80 -n $NS` | `kubectl get all -n $NS \| grep -c 'my-app'` |

> `$NS` = 세션 namespace (`quest-{containerId 앞 8자리}`)
> grade_cmd에서 `$NS`는 서버가 실제 namespace 값으로 치환 후 실행.

---

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/docker/Dockerfile.k8s` | kubectl + bash 포함 경량 이미지 |
| `backend/db/init.sql` | sandbox k8s 행 추가, 세트 6 퀘스트 추가 |
| `backend/.env` | `KUBECONFIG_PATH` 추가 |
| `backend/src/sandbox.ts` | binds 플레이스홀더 치환 로직 추가 |
| `backend/src/terminal.ts` | k8s namespace 생성/삭제 |

---

## 검증 기준

- [ ] `k3d cluster create etude` 후 `kubectl get nodes` 정상 동작
- [ ] `docker build -f Dockerfile.k8s` 빌드 성공
- [ ] etude-k8s 컨테이너 터미널에서 `kubectl get nodes` 실행 가능
- [ ] 세트 6 퀘스트 10개 grade_cmd 직접 검증 완료
- [ ] 세션 종료 시 namespace 자동 삭제 확인
