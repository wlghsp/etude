# 배포 직후 체크리스트

서버를 새로 세팅하거나(`setup.sh` 재실행), `docker compose up -d --build`로 backend를 재기동한 뒤 매번 확인한다. 절차 상세는 [guide_phase8_deploy.md](../guides/guide_phase8_deploy.md) 참고 — 여기는 "뭘 놓쳤는지"만 빠르게 훑는 용도.

이 체크리스트가 생긴 이유: 이미지 빌드 누락([troubleshooting_2026-07-03](troubleshooting_2026-07-03_missing_sandbox_images.md))과 환경변수 미반영([troubleshooting_2026-07-24](troubleshooting_2026-07-24_k8s_quest_env_prep.md))이 각각 별개 시점에 재발했다. 둘 다 "배포는 끝났다고 생각했는데 특정 퀘스트 타입만 안 되더라" 패턴.

---

## 1. sandbox 이미지가 전부 빌드/존재하는가

```bash
docker images | grep etude
```

`backend/db/01_sandbox.sql`에 등록된 이미지 전부와 대조한다.

| sandbox 타입 | 이미지 | 확보 방법 |
|---|---|---|
| `linux` | `etude-linux` | 서버에서 직접 빌드 (`Dockerfile.linux`) |
| `linux-ssh` | `etude-ssh` | 서버에서 직접 빌드 (`Dockerfile.ssh`) |
| `docker`, `docker-persistent` | `docker:dind` | `docker pull` (setup.sh에 포함) |
| `k8s`, `k8s-isolated` | `etude-k8s` | 서버에서 직접 빌드 (`Dockerfile.k8s`) |
| `linux-systemd` | `rockylinux/rockylinux:9-ubi-init` | `docker pull` |

목록에 없는 게 있으면:

```bash
cd ~/etude/backend
docker build -f docker/Dockerfile.{종류} -t {이미지이름}:latest .
```

> `01_sandbox.sql`에 새 sandbox 타입을 추가했다면 이 표와 `infra/scripts/setup.sh`의 사전 pull 목록도 함께 업데이트한다.

---

## 2. `.env.prod`를 고쳤다면 컨테이너가 그 값을 반영했는가

`.env.prod` 파일 내용을 바꾸는 것과, 실행 중인 `etude-backend` 컨테이너가 그 값을 쓰는 것은 별개다. `--build`로 재기동해야 반영된다.

```bash
# 서버에 저장된 값
cat ~/etude/backend/.env.prod | grep KUBECONFIG_PATH

# 실행 중인 컨테이너가 실제로 들고 있는 값
docker exec etude-backend printenv KUBECONFIG_PATH
```

두 값이 다르면 재기동:

```bash
cd ~/etude
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

`KUBECONFIG_PATH`는 반드시 **호스트 기준 경로**(`/home/ubuntu/.kube/config-etude`)여야 한다 — `/root/...`처럼 컨테이너 내부 경로를 넣으면 k8s 퀘스트가 "환경 준비 중"에서 멈춘다. 이유는 [guide_phase8_deploy.md Step 6-3](../guides/guide_phase8_deploy.md)에 설명되어 있다.

---

## 3. k3d 클러스터가 떠 있는가

```bash
k3d cluster list
docker network ls | grep k3d
```

VM을 재부팅한 직후라면 k3d가 자동으로 안 올라올 수 있다 (`k3d-etude.service`가 있으면 자동 시작되지만, 서비스 자체가 없거나 실패했을 수 있음).

```bash
k3d cluster start etude
```

---

## 4. 실제로 퀘스트를 하나씩 열어서 확인

이미지/환경변수가 맞아도 실제 터미널 연결까지 확인해야 안심할 수 있다.

1. 리눅스 퀘스트 — 터미널 연결 + 명령어 실행
2. 도커 퀘스트 — DinD 터미널 연결
3. k8s 퀘스트 — `kubectl get nodes` 실행 확인

문제가 생기면 [guide_server_operations.md의 "퀘스트 터미널이 '환경 준비 중'에서 안 넘어갈 때"](guide_server_operations.md) 섹션을 따라간다.
