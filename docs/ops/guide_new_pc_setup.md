# 새 PC 개발 환경 구축 가이드

다른 PC에서 레포를 받아 같은 환경으로 작업을 이어갈 때 따라 하는 순서. 기동·초기화의 세부 설명은 [guide_local_dev_env.md](guide_local_dev_env.md), DB 변경 규칙은 [guide_db_migrations.md](guide_db_migrations.md)를 본다. 지금 작업 상태와 규칙 요약은 [handoff_2026-10-31.md](handoff_2026-10-31.md).

> 이 가이드의 명령은 작성한 PC(macOS, Apple Silicon, colima)에서 쓰던 것이다. 다른 환경에서 실행해 확인한 것은 아니다(`미검증`).

## 1. 준비물

| 도구 | 비고 |
|---|---|
| Docker | colima 또는 Docker Desktop. 데몬이 실행 중이어야 한다 (`docker ps` 로 확인) |
| Node.js 20 | 작성 PC는 v20.19.6, npm 10.8.2 |
| git, gh(선택) | 푸시 인증용. 레포는 `https://github.com/wlghsp/etude.git` |
| k3d | k8s 샌드박스용 (`brew install k3d`, 작성 PC는 v5.9.0). k8s 실습을 안 쓰면 생략 가능 |
| 아키텍처 | `backend/docker/Dockerfile.k8s` 가 **arm64** kubectl 을 받는다. x86 PC 라면 이 파일의 `arm64` 를 `amd64` 로 바꿔야 한다(미검증) |

## 2. 코드 받고 의존성 설치

```bash
git clone https://github.com/wlghsp/etude.git
cd etude
(cd backend && npm install)
(cd frontend && npm install)
```

## 3. 비밀 파일 만들기 (레포에 없는 파일)

다음 파일은 `.gitignore` 로 제외돼 있어 레포에 없다. 값은 채팅·메신저로 보내지 말고 각자 만든다.

| 파일 | 만드는 법 |
|---|---|
| `backend/.env` | `cp backend/.env.example backend/.env` 후 값을 채운다. DB 값은 `backend/docker-compose.yml`(DB 이름 `etude`, 루트 비밀번호 `root`, 포트 3306)과 맞추고, `JWT_SECRET` 은 `openssl rand -hex 32` 로 만든다. `KUBECONFIG_PATH` 는 아래 5절의 `~/.kube/config-etude` |
| `backend/db/04_users.sql` | `cp backend/db/04_users.sql.example backend/db/04_users.sql` 후 로컬에서 쓸 로그인 계정으로 고친다 |
| `frontend/.env.development` | 레포에 포함돼 있다 (`VITE_API_BASE=http://localhost:3001`, `VITE_WS_BASE=ws://localhost:3001`) |

`.env*`, `04_users.sql`, `backend/db/users/users.txt`, Terraform `terraform.tfvars`·state 는 **커밋하지 않는다** (CLAUDE.md 의 민감 파일 규칙).

## 4. 샌드박스 이미지 만들기

배포 파이프라인(`.github/workflows/deploy.yml`)과 같은 명령이다. 처음 한 번, 그리고 `backend/docker/Dockerfile.*` 가 바뀔 때 다시 한다.

```bash
docker build -q -f backend/docker/Dockerfile.linux    -t etude-linux:latest    backend   # 리눅스·퀴즈 실습 (약 320MB)
docker build -q -f backend/docker/Dockerfile.linux-db -t etude-linux-db:latest backend   # MariaDB 포함 (DB 실습 세트용, 약 +280MB)
docker build -q -f backend/docker/Dockerfile.k8s      -t etude-k8s:latest      backend   # kubectl, helm
docker build -q -f backend/docker/Dockerfile.ssh      -t etude-ssh:latest      backend   # SSH 서버 실습
```

`mariadb:11`(DB 컨테이너)과 `docker:dind`(도커 실습)는 처음 쓸 때 자동으로 받는다. `linux-db` 이미지는 `etude-linux` 위에 쌓이므로 **linux 를 먼저** 빌드한다.

## 5. 기동

```bash
scripts/dev-up.sh            # MariaDB(etude-db) + k3d 클러스터(etude). k8s 를 안 쓰면 --no-k8s
scripts/migrate.sh           # 아직 적용 안 한 마이그레이션 적용 (새 DB 에도 안전하다)
```

`etude-db` 가 처음 만들어질 때 `backend/db/00~09_*.sql` 이 자동 실행돼 스키마와 세트가 들어간다. 그 뒤에 추가된 변경은 `migrate.sh` 가 이름순으로 적용한다.

k8s 실습을 쓰려면 컨테이너 안에서 닿는 kubeconfig 가 필요하다. 클러스터 `etude` 를 만든 뒤 서버 주소만 바꿔 `~/.kube/config-etude` 로 저장한다. 서버 주소가 `https://k3d-etude-server-0:6443` 이어야 한다 (생성 절차는 [../specs/spec_phase8_deploy.md](../specs/spec_phase8_deploy.md) 의 "kubeconfig 생성" 절 참고. 아래는 추정 명령이며 `미검증`).

```bash
k3d kubeconfig get etude | sed 's#https://0.0.0.0:[0-9]*#https://k3d-etude-server-0:6443#' > ~/.kube/config-etude
grep server ~/.kube/config-etude
```

백엔드와 프론트를 각각 실행한다.

```bash
cd backend  && KUBECONFIG_PATH=$HOME/.kube/config-etude npm run dev   # http://localhost:3001
cd frontend && npm run dev                                            # Vite 개발 서버
```

## 6. 점검 명령 (작업 전후에 돌린다)

```bash
scripts/check-migrations.sh                       # 마지막 배포 DB 를 흉내 내 새 마이그레이션 적용 검증
scripts/check-content.sh                          # 깨진 명령, 환경 없는 안내, 정답 범위
(cd backend && npx vitest run)                    # 백엔드 테스트 (현재 331개)
(cd backend && npm run verify:quests -- --set N)  # 실습 세트 N 의 정답이 채점을 통과하는지 (컨테이너 실행)
(cd frontend && npx tsc -b -f && npm run build)   # 프론트 타입과 빌드
```

`verify:quests` 는 **객관식 정답은 검사하지 않는다.** 객관식은 DB 에 저장된 정답 보기 텍스트를 직접 출력해 눈으로 확인한다.

## 7. 새 세트 만드는 법

세트는 `quest_set`(세트) 행과 `quest`(문제) 행들이고, 여러 파일에 같은 내용이 들어간다.

| 파일 | 내용 |
|---|---|
| `backend/db/03_quest_setNNN.sql` | 문제 INSERT (원본) |
| `backend/db/02_quest_set.sql` | 세트 행 추가 |
| `backend/db/05_display_order.sql`, `06_units.sql`, `08_set_icons.sql` | 표시 순서, 단원, 아이콘 한 줄씩 |
| `backend/db/migrations/날짜_이름.sql` | 이미 배포된 DB 에 넣는 가드(`NOT EXISTS`) 있는 SQL |
| `backend/verify/setNNN.json` | 실습 문제의 정답 명령 (퀴즈 세트는 빈 값) |

이 파일들을 한 번에 만드는 예시 생성기가 `scripts/content-gen/` 에 있다.

- `example_quiz_set.py` — 퀴즈 세트 (객관식·빈칸·순서, 컨테이너 없음). 세트 131 을 만든 스크립트.
- `example_practice_set.py` — 실습 세트 (터미널 문제, `linux-db`). 세트 126 을 만든 스크립트.

**예시를 그대로 실행하지 않는다** (같은 행이 중복으로 붙는다). 복사해서 `SID`, 제목, 설명, `display_order`, 단원, 아이콘, 문제 목록을 바꾼다. 이미 만든 세트를 다시 만들려면 먼저 그 세트가 붙인 줄(02 마지막 행, 05·06·08 의 `WHERE id = N;` 줄)과 마이그레이션 파일을 지우고 DB 행도 지운 뒤 생성한다.

문제 작성 규칙(요약, 전체는 CLAUDE.md 와 `docs/specs/spec_content_reinforcement.md`):

- 한 세트에 형식을 3종 이상 섞는다 (퀴즈 전용 세트는 객관식이 절반 이하).
- 객관식 정답은 항상 **보기 원래 위치(첫 보기)** 로 쓰고 생성기가 위치를 섞는다. 최종 위치를 정답 인덱스로 넘기면 틀린 보기가 정답이 된다 (실제 사고 사례).
- 문제·해설에 IP, 도메인, 회사·센터·기관·내부 시스템 이름 같은 현장 정보를 넣지 않는다 (예시 주소는 `192.0.2.x` 같은 문서용 대역만).
- 쉽고 친절하게. 한 문제는 한 개념, 힌트는 정답이 아니라 "찾는 방법".
