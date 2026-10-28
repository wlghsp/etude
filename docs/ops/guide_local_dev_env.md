# 로컬 개발 환경 기동 가이드

로컬에서 Node.js 백엔드(`backend/`)와 프론트엔드를 띄워 브라우저로 확인할 때 필요한
인프라(MariaDB, 선택적으로 k3d)를 한 번에 올리고 내리는 방법.

## 한 줄 요약

```bash
scripts/dev-up.sh            # DB + k3d 클러스터 (기본)
scripts/dev-up.sh --no-k8s   # DB만 (k8s 샌드박스를 안 쓸 때)
scripts/dev-down.sh          # 정지 (데이터는 보존)
```

그다음 백엔드와 프론트를 각각 실행한다.

```bash
cd backend && npm run dev                               # http://localhost:3001
cd frontend && npm run dev                              # .env.development 가 localhost:3001 을 가리킨다
```

## 스크립트가 하는 일

| 단계 | `dev-up.sh` | `dev-down.sh` |
|---|---|---|
| DB | `backend/docker-compose.yml`의 `db`(컨테이너 `etude-db`)를 띄우고 접속 가능해질 때까지 대기 | `db` 정지 |
| 스키마 확인 | `etude` 스키마의 테이블 수를 출력 (0이면 초기화 SQL이 안 돈 것) | - |
| k3d (기본, `--no-k8s`로 생략) | 클러스터 `etude`가 있으면 start, 없으면 create | 실행 중이면 stop |

백엔드와 프론트는 IDE에서 자주 재시작하므로 스크립트에 넣지 않았다.
k3d는 Docker 네트워크(`k3d-etude`)를 자체 CLI로 관리해서 compose에 넣지 않고 스크립트로 다룬다.
기본으로 켜는 이유는 k8s 퀘스트셋을 항상 검증할 수 있게 하려는 것이다. 필요 없으면
`--no-k8s`를 줘서 메모리를 절약한다.

## 사전 조건

- Docker 데몬이 실행 중일 것 (이 머신은 colima 사용)
- 이미지가 로컬에 있을 것: `mariadb:11`, 샌드박스용 `etude-linux`
- `k3d` 설치 (`brew install k3d`). 없으면 `--no-k8s`로 실행
- `backend/db/04_users.sql` 이 있어야 로그인용 계정이 들어간다
  (`04_users.sql.example` 참고)

## k8s 샌드박스를 쓸 때 — kubeconfig 경로

k8s 계열 퀘스트셋은 컨테이너에 kubeconfig를 마운트해 `kubectl`을 쓴다. 백엔드의 기본 경로
(`~/.kube/config`)는 서버 주소가 `https://127.0.0.1:6443`이라 **컨테이너 안에서는 클러스터에 닿지
않는다.** 컨테이너가 k3d 네트워크로 접속하려면 서버 주소가 `https://k3d-etude-server-0:6443`인
kubeconfig(`~/.kube/config-etude`)를 써야 하므로 백엔드를 이렇게 띄운다.

```bash
cd backend
KUBECONFIG_PATH=$HOME/.kube/config-etude npm run dev
```

IDE에서 실행한다면 실행 설정의 환경변수에 `KUBECONFIG_PATH`를 추가한다.
자세한 배경은 [../glossary/kubeconfig.md](../glossary/kubeconfig.md)를 참고한다.

## DB 초기화 (스키마가 맞지 않을 때)

초기화 SQL(`backend/db/*.sql`)은 **볼륨이 비어 있을 때만** 실행된다. 스키마를 처음부터
다시 만들 필요가 있을 때는 볼륨을 지우고 다시 만든다.

```bash
docker compose -f backend/docker-compose.yml down -v   # 주의: DB 데이터가 모두 삭제된다
scripts/dev-up.sh
```

`-v`는 데이터를 지우므로 필요한 데이터가 있는지 먼저 확인한다.

## 문제 해결

| 증상 | 확인 |
|---|---|
| `Docker 데몬에 연결할 수 없습니다` | colima/Docker Desktop 실행 여부. `docker context show` |
| `DB가 120초 안에 준비되지 않았습니다` | `docker logs etude-db` — 초기화 SQL 오류가 대부분 |
| 테이블 수가 0 | 초기화 SQL 실행이 실패한 것. `docker logs etude-db` 확인 후 "DB 초기화" 절로 다시 만든다 |
| 3306 포트 충돌 | 다른 MariaDB/MySQL이 3306을 쓰는 중. `docker ps`, `lsof -i :3306` |
| 새 초기화 SQL이 반영되지 않음 | 기존 볼륨에는 초기화 SQL이 재실행되지 않는다. 위 "DB 초기화" 절 참고 |

## 관련 문서

- [guide_server_operations.md](guide_server_operations.md) — 운영 서버 절차 (배포용 compose는 `deploy/docker-compose.prod.yml`)
- [../specs/spec_phase6_k8s.md](../specs/spec_phase6_k8s.md) — k3d 클러스터 구성
