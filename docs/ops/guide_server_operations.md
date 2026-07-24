# 운영 가이드 — 서버 운영 명령어 모음

배포된 OCI 서버(`~/etude`)에서 반복적으로 쓰는 명령어를 정리한다. 배포 자체는 [guide_phase8_deploy.md](../guides/guide_phase8_deploy.md), CI/CD는 [guide_phase8b_cicd.md](../guides/guide_phase8b_cicd.md) 참고.

모든 `docker compose` 명령은 `~/etude`(프로젝트 루트)에서 실행한다. `--project-directory .`는 `deploy/` 안의 compose 파일 내부 상대경로(`.env.prod` 등)가 프로젝트 루트 기준으로 해석되도록 하는 데 필수다.

---

## SSH 접속

```bash
ssh -i ~/.ssh/etude_oci ubuntu@{공인IP}
```

---

## 서비스 상태 확인

```bash
docker ps
docker compose -f deploy/docker-compose.prod.yml --project-directory . ps
```

## 로그 확인

```bash
# 실시간 tail
docker compose -f deploy/docker-compose.prod.yml --project-directory . logs -f backend

# 최근 N줄만
docker compose -f deploy/docker-compose.prod.yml --project-directory . logs --tail=50 backend
```

`backend` 대신 `db`, `nginx`로 바꿔서 다른 서비스 로그도 확인 가능.

---

## 재배포 (코드 변경 후 서버 반영)

### 방법 1 — GitHub Actions CI/CD (권장)

로컬 터미널에서 `gh` CLI로 브라우저 없이 바로 트리거할 수 있다 ([guide_phase8b_cicd.md](../guides/guide_phase8b_cicd.md) 참고).

```bash
gh workflow run deploy.yml

# 실행 상태 확인
gh run list --workflow=deploy.yml --limit 3

# 특정 실행의 상세 로그 확인 (run id는 위 목록에서 확인)
gh run view {run-id} --log
```

### 방법 2 — 서버에서 수동 실행

```bash
cd ~/etude
git pull

# 프론트 변경 시
cd frontend && npm run build && cd ..

# 서비스 재시작
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

nginx.conf를 변경했다면 nginx도 함께 재시작 대상에 포함 (`--build`는 불필요, nginx는 이미지 빌드 없이 설정만 마운트):

```bash
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend nginx
```

### nginx.conf만 바꿨을 때

nginx.conf는 볼륨 마운트라 이미지 재빌드는 필요 없지만, Docker Compose가 파일 내용 변경을 자동으로 감지하지 못해 컨테이너를 그대로 유지하는 경우가 있다. 강제로 재생성해야 한다.

```bash
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --force-recreate nginx
```

---

## 서비스 개별 재시작

```bash
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d db
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d backend
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d nginx
```

---

## 전체 중지 / DB 초기화

```bash
# 전체 서비스 중지 (볼륨 유지)
docker compose -f deploy/docker-compose.prod.yml --project-directory . down

# DB 초기화 (주의: 데이터 전부 삭제)
docker compose -f deploy/docker-compose.prod.yml --project-directory . down -v
```

---

## k3d 클러스터

```bash
k3d cluster stop etude
k3d cluster start etude

# VM 재부팅 후에는 k3d가 자동으로 안 올라오므로 수동 시작 필요, 이후 docker compose up
```

---

## 고아 리소스 정리

```bash
# 고아 컨테이너 (etude- prefix)
docker ps -a --filter "name=etude-" --format "{{.ID}}" | xargs docker rm -f

# 고아 vcluster (Phase 10) — backend 재시작 시 initPool()이 자동으로 정리하므로 수동 정리는 보통 불필요
kubectl get ns | grep vcluster-
```

---

## DB 직접 접속

### 컨테이너 안에서 mysql 클라이언트로

```bash
docker exec -it etude-db mysql -u {DB_USER} -p etude
```

`.env.prod`의 `DB_USER`/`DB_PASSWORD` 값 사용.

### 로컬 DBeaver 등 GUI 클라이언트로 (SSH 터널)

기본적으로 `db` 서비스는 `127.0.0.1:3306:3306`으로 서버 로컬에만 바인딩되어 있어 외부에서 직접 접속할 수 없다. SSH 터널을 거쳐야 한다.

DBeaver 연결 설정:

| 탭 | 항목 | 값 |
|---|------|-----|
| Main | Server Host | `localhost` |
| Main | Port | `3306` |
| Main | Database | `etude` |
| Main | Username / Password | `.env.prod`의 `DB_USER`/`DB_PASSWORD` |
| SSH | Host/IP | 공인 IP |
| SSH | Port | `22` |
| SSH | User Name | `ubuntu` |
| SSH | Authentication Method | Public Key |
| SSH | Private Key | `~/.ssh/etude_oci`의 **절대경로** (예: `/Users/{계정}/.ssh/etude_oci`) |

> Private Key 경로는 `~`(물결표) 표기를 DBeaver가 자동으로 홈 디렉토리로 확장하지 못해 `private key file does not exist` 에러가 날 수 있다. 절대경로를 직접 입력하거나 파일 탐색기로 선택할 것.

---

## 퀘스트 데이터 수정 원칙

`backend/db/03_quest_set*.sql`은 DB가 처음 만들어질 때(볼륨 최초 생성)만 자동 실행된다. 이미 데이터가 들어있는 로컬/서버 DB는 SQL 파일을 고쳐도 반영되지 않으므로, 퀘스트 내용(제목/힌트/setup_cmd/grade_cmd 등)을 고칠 때는 항상 두 가지를 함께 한다.

1. **원본 SQL 파일 수정** — 다음에 DB를 초기화하거나 서버를 새로 세팅할 때 자동 반영되도록 (단일 진실 공급원 유지)
2. **UPDATE 문 작성 + 실행** — 지금 이미 떠 있는 로컬/서버 DB에 즉시 반영

DB를 통째로 초기화(`down -v`)하는 방식은 팀원 계정, 진행 기록(`quest_attempt`), 피드백 등 실사용 데이터가 전부 날아가므로 팀원 오픈 이후에는 쓰지 않는다.

---

## 유저 관리

[guide_user_management.md](guide_user_management.md) 참고.

---

## 퀘스트 터미널이 "환경 준비 중"에서 안 넘어갈 때

브라우저에서 퀘스트에 들어갔는데 터미널 화면이 "환경 준비 중..."에 멈춰 있으면, 아래 순서대로 확인한다. 각 단계는 "무엇을 보는 명령인지"와 "정상/비정상 기준"을 같이 적어뒀다. 사례는 [troubleshooting_2026-07-24_k8s_quest_env_prep.md](troubleshooting_2026-07-24_k8s_quest_env_prep.md) 참고.

### 1단계 — 서버 로그를 실시간으로 켜둔다

```bash
docker logs etude-backend --tail 50 -f
```

이 상태에서 브라우저로 돌아가 문제가 되는 퀘스트에 다시 들어간다. 로그에 새로 찍히는 줄을 본다.
- 아무것도 안 찍히면 → 요청이 백엔드까지 아예 안 왔다는 뜻. nginx나 네트워크 쪽 문제일 가능성.
- `terminal error: ...` 같은 에러 스택이 찍히면 → 그 메시지를 그대로 복사해서 다음 단계로.

`Ctrl+C`로 로그 tail을 멈출 수 있다.

### 2단계 — 에러 메시지로 원인 유형 판별

**`No such image: {이미지이름}:latest`** 가 보이면 → 그 이미지가 서버에 없다는 뜻.

```bash
docker images | grep etude
```

여기 목록에 에러에 나온 이미지 이름이 없으면, 해당 Dockerfile(`backend/docker/Dockerfile.*`)로 서버에서 직접 빌드해야 한다.

```bash
cd ~/etude/backend
docker build -f docker/Dockerfile.{종류} -t {이미지이름}:latest .
```

**`config: is a directory` / `no such file or directory`** 같은 kubeconfig 관련 에러가 보이면 → 환경변수(`KUBECONFIG_PATH`)가 최신 값으로 반영이 안 됐을 가능성.

```bash
docker exec etude-backend printenv KUBECONFIG_PATH
```

이 값이 `backend/.env.prod`에 적힌 값과 다르면, 재기동이 안 된 것 — 3단계로.

### 3단계 — `.env.prod`를 고쳤다면 반드시 재기동

`.env.prod` 파일 내용만 고치는 걸로는 이미 떠 있는 컨테이너에 반영되지 않는다. `--build`로 다시 띄워야 한다.

```bash
cd ~/etude
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

재기동 후 다시 2단계의 `printenv` 명령으로 값이 바뀌었는지 확인하고, 브라우저에서 퀘스트를 다시 열어본다.

### 참고 — 처음 들어갈 때 로딩이 오래 걸리는 건 정상일 수 있다

k3d 클러스터나 컨테이너가 초기화되는 데 몇 초에서 수십 초 걸릴 수 있다. 로그에 에러가 안 찍히는데 그냥 느리기만 하다면 잠시 기다려본다. 1~2분 넘게 아무 반응이 없는데 로그도 조용하면 그때 1단계부터 다시 확인.
