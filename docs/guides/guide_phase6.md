# Phase 6 구현 가이드 — k8s 기초 실습 세트

명세: [specs/spec_phase6_k8s.md](../specs/spec_phase6_k8s.md)

---

## 전체 흐름

```
Step 1. k3d 설치 + 클러스터 기동 (로컬 환경 준비)
Step 2. Dockerfile.k8s 작성 + 이미지 빌드
Step 3. 수동 연결 테스트 (컨테이너에서 kubectl 동작 확인)
Step 4. sandbox.ts — binds 플레이스홀더 치환
Step 5. terminal.ts — k8s namespace 생성/삭제
Step 6. init.sql — sandbox + 퀘스트 세트 6 추가
Step 7. 전체 사이클 검증
```

---

## Step 1. k3d 설치 + 클러스터 기동

```bash
# k3d 설치
brew install k3d

# 클러스터 생성
k3d cluster create etude

# 확인
kubectl get nodes
# 출력 예: etude-server-0   Ready   ...
```

kubeconfig는 `~/.kube/config`에 자동 병합된다.

---

## Step 2. Dockerfile.k8s 작성

`backend/docker/Dockerfile.k8s` 파일 생성:

```dockerfile
FROM alpine:3.19

RUN apk add --no-cache curl bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

WORKDIR /root
CMD ["bash"]
```

빌드:

```bash
cd backend
docker build -f docker/Dockerfile.k8s -t etude-k8s .
```

빌드 성공 확인:

```bash
docker images | grep etude-k8s
```

---

## Step 3. 수동 연결 테스트

컨테이너를 직접 띄워서 kubectl이 클러스터에 접근되는지 먼저 확인한다.

```bash
docker run -it --rm \
  -v ~/.kube/config:/root/.kube/config:ro \
  etude-k8s \
  kubectl get nodes
```

`Ready` 상태 노드가 보이면 샌드박스 연결 성공.

> 안 되는 경우 체크:
> - kubeconfig 안의 server 주소가 `127.0.0.1` 또는 `localhost`이면 컨테이너에서 접근 불가
> - k3d는 기본적으로 `0.0.0.0`으로 포트를 바인딩하므로 대부분 동작함
> - 안 되면 `kubectl config view --raw`로 server 주소 확인

---

## Step 4. sandbox.ts — binds 플레이스홀더 치환

`backend/.env`에 추가:

```
KUBECONFIG_PATH=/Users/{본인계정}/.kube/config
```

`backend/src/sandbox.ts`의 `getSandboxConfig()` 함수에서 binds를 반환하기 전에 치환 로직 추가:

```typescript
const kubeconfig = process.env.KUBECONFIG_PATH ?? `${process.env.HOME}/.kube/config`
config.binds = (config.binds ?? []).map(b =>
  b.replace('{KUBECONFIG_HOST_PATH}', kubeconfig)
)
```

검증: `sandbox` 테이블에서 k8s 행을 조회했을 때 binds가 실제 경로로 치환되어 나오는지 로그로 확인.

---

## Step 5. terminal.ts — k8s namespace 관리

`backend/src/terminal.ts`에서 k8s sandbox_type일 때 컨테이너 생성 직후 namespace를 만들고, 컨테이너 제거 전에 삭제한다.

```typescript
// 컨테이너 생성 후 (k8s 전용)
if (sandboxType === 'k8s') {
  const ns = `quest-${containerId.slice(0, 8)}`
  const nsExec = await container.exec({
    Cmd: ['kubectl', 'create', 'namespace', ns],
    AttachStdout: true,
    AttachStderr: true,
  })
  await nsExec.start({})
}
```

```typescript
// 컨테이너 제거 전 (k8s 전용)
if (sandboxType === 'k8s') {
  const ns = `quest-${containerId.slice(0, 8)}`
  const nsExec = await container.exec({
    Cmd: ['kubectl', 'delete', 'namespace', ns, '--ignore-not-found'],
    AttachStdout: true,
    AttachStderr: true,
  })
  await nsExec.start({})
}
```

grade_cmd에서 `$NS` 플레이스홀더를 실제 namespace로 치환해서 실행.
`gradeQuest()`는 `containerId`에서 namespace를 파생할 수 있으므로 함수 내부에서 처리:

```typescript
// quest.ts — gradeQuest() 함수 내부
const ns = `quest-${containerId.slice(0, 8)}`
const resolvedCmd = cmd.map((s: string) => s.replace(/\$NS/g, ns))
return execCheck(docker.getContainer(containerId), resolvedCmd)
```

setup_cmd도 동일하게 치환 필요. `getSetupCmd()` 또는 `runSetupCmd()` 호출 전에 처리.

---

## Step 6. init.sql — sandbox + 퀘스트 세트 추가

`backend/db/init.sql`에 두 가지를 추가한다.

### sandbox 행

```sql
INSERT INTO sandbox (type, image, binds, description) VALUES (
  'k8s',
  'etude-k8s',
  '["{KUBECONFIG_HOST_PATH}:/root/.kube/config:ro"]',
  'kubectl 실습 환경 (k3d 클러스터 연결)'
);
```

### quest_set 행

```sql
INSERT INTO quest_set (id, title, description, sandbox_type) VALUES
(6, 'k8s 기초', 'kubectl로 Pod, Deployment, Service를 직접 조작해봅니다.', 'k8s');
```

### quest 행 (세트 6)

컬럼 순서: `(quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)`

grade_cmd / setup_cmd는 JSON 배열 형식. `$NS`는 런타임에 실제 namespace로 치환됨.

```sql
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (6, 1,
   '클러스터 노드 확인하기',
   '현재 클러스터에 어떤 노드가 있는지 확인하세요.',
   'kubectl get nodes 명령어를 사용하세요.',
   'kubectl get nodes',
   NULL,
   '["sh", "-c", "kubectl get nodes | grep -i ready"]'),

  (6, 2,
   '네임스페이스 목록 확인하기',
   '클러스터에 존재하는 네임스페이스 목록을 확인하세요.',
   'kubectl get namespaces 또는 kubectl get ns',
   'kubectl get namespaces',
   NULL,
   '["sh", "-c", "kubectl get ns | grep quest-"]'),

  (6, 3,
   'Pod 실행하기',
   '실습 네임스페이스에 nginx 이미지로 nginx라는 이름의 Pod를 실행하세요.',
   'kubectl run <name> --image=<image> -n <namespace>',
   'kubectl run nginx --image=nginx -n $NS',
   NULL,
   '["sh", "-c", "kubectl get pod nginx -n $NS 2>/dev/null | grep -E ''Running|ContainerCreating''"]'),

  (6, 4,
   'Pod 목록 확인하기',
   '실습 네임스페이스의 Pod 목록을 확인하세요.',
   'kubectl get pods -n <namespace>',
   'kubectl get pods -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pods -n $NS | grep nginx"]'),

  (6, 5,
   'Pod 로그 확인하기',
   '실습 네임스페이스의 nginx Pod 로그를 확인하세요.',
   'kubectl logs <pod-name> -n <namespace>',
   'kubectl logs nginx -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=ready pod/nginx -n $NS --timeout=30s 2>/dev/null; true"]',
   '["sh", "-c", "kubectl logs nginx -n $NS 2>/dev/null; exit 0"]'),

  (6, 6,
   'Pod 삭제하기',
   '실습 네임스페이스의 nginx Pod를 삭제하세요.',
   'kubectl delete pod <name> -n <namespace>',
   'kubectl delete pod nginx -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "! kubectl get pod nginx -n $NS 2>/dev/null | grep -q nginx"]'),

  (6, 7,
   'Deployment 생성하기',
   '실습 네임스페이스에 nginx 이미지로 my-app이라는 Deployment를 생성하세요.',
   'kubectl create deployment <name> --image=<image> -n <namespace>',
   'kubectl create deployment my-app --image=nginx -n $NS',
   NULL,
   '["sh", "-c", "kubectl get deploy my-app -n $NS | grep my-app"]'),

  (6, 8,
   'Deployment 스케일 조정하기',
   '실습 네임스페이스의 my-app Deployment를 3개로 스케일 아웃하세요.',
   'kubectl scale deployment <name> --replicas=<n> -n <namespace>',
   'kubectl scale deployment my-app --replicas=3 -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get deploy my-app -n $NS | grep -E ''3/3|3 ''"]'),

  (6, 9,
   'Service 생성하기',
   '실습 네임스페이스의 my-app Deployment를 포트 80으로 노출하는 Service를 생성하세요.',
   'kubectl expose deployment <name> --port=<port> -n <namespace>',
   'kubectl expose deployment my-app --port=80 -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get svc my-app -n $NS | grep my-app"]'),

  (6, 10,
   '리소스 전체 확인하기',
   '실습 네임스페이스의 모든 리소스를 한 번에 확인하세요.',
   'kubectl get all -n <namespace>',
   'kubectl get all -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; kubectl expose deployment my-app --port=80 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get all -n $NS | grep -c my-app | xargs -I{} test {} -ge 2"]');
```

반영:

```bash
docker-compose down -v && docker-compose up -d
```

---

## Step 7. 전체 사이클 검증

```
1. 세트 선택 화면에서 "k8s 기초" 세트 선택
2. 터미널 연결 — kubectl get nodes 실행해서 노드 보이는지 확인
3. 퀘스트 1번부터 순서대로 진행
4. 각 퀘스트 채점 버튼으로 grade_cmd 실행 확인
5. 세션 종료 후 kubectl get ns | grep quest- 로 namespace 삭제 확인
```

---

## 주의사항

- kubeconfig의 server 주소가 `127.0.0.1`이면 컨테이너 내부에서 접근 불가. Step 3에서 먼저 검증할 것.
- k3d 클러스터가 내려가 있으면 etude 서버 기동 전에 `k3d cluster start etude` 실행.
- `$NS` 치환은 grade_cmd와 setup_cmd 둘 다 적용해야 함.
- Pod가 Running 상태가 되기까지 수 초 소요. grade_cmd 실행 타이밍에 따라 채점 실패할 수 있음 — `kubectl wait --for=condition=ready pod` 를 setup_cmd에 추가하거나, grade_cmd에 재시도 로직 검토.
