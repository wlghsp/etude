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

## 유저 관리

[guide_user_management.md](guide_user_management.md) 참고.
