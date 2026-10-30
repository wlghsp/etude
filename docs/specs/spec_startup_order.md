# 기동 순서 명세 — DB → 백엔드 → nginx를 "준비 완료" 기준으로 올린다

> 상태: **구현 완료(로컬 검증), 서버 배포 대기** (2026-10-29). 서버 동작은 배포 전까지 `미검증`. 인프라·배포 변경이라 리뷰 대상이나 Codex를 쓸 수 없어 리뷰를 생략한다.

## 목표

컨테이너가 "시작됨"이 아니라 "준비됨"일 때 다음 단계가 올라오게 한다. 배포가 실제로 서비스 가능한 상태일 때만 성공으로 끝나게 한다.

## 현황 (확인한 사실)

- `docker-compose.prod.yml`의 `depends_on`은 조건이 없어 컨테이너 **시작**만 기다린다. 헬스체크가 없다.
- 백엔드는 `listen` **전에** `cleanupOrphanContainers`, `cleanupOrphanQuestNamespaces`(k3d에 `kubectl`), `initPool`(vcluster 풀 생성)을 `await`한다. 처음 띄울 때 풀 생성이 오래 걸린 기록이 있다 ([troubleshooting_2026-10-29_vcluster_first_start.md](../ops/troubleshooting_2026-10-29_vcluster_first_start.md)).
- 백엔드에 상태 확인 주소가 없다. DB 연결 풀은 지연 연결이라 DB가 늦어도 백엔드는 뜨지만 그 사이 요청은 실패한다.
- nginx의 `proxy_pass http://backend:3001`은 시작할 때 이름을 한 번만 풀어 `host not found in upstream`으로 시작에 실패할 수 있고, 백엔드 IP가 바뀌어도 낡은 주소를 쓴다.
- 서버를 **재부팅**하면 Docker는 `depends_on`을 무시하고 `restart: unless-stopped` 컨테이너를 임의 순서로 올린다. 그래서 compose 설정만으로는 재부팅 시 순서가 보장되지 않는다.
- 배포(`deploy.yml`)는 `up -d`의 종료 코드만 보므로, 서비스가 안 떠도 `success`가 될 수 있다.

## 설계

1. **DB 헬스체크:** `mariadb-admin ping -h localhost -uroot -p$MYSQL_ROOT_PASSWORD --silent` (기존 볼륨에서도 root 비밀번호로 동작. 로컬 DB에서 확인함).
2. **백엔드 `GET /health`:** `SELECT 1`로 DB까지 확인해 `200 {status:"ok"}`, 실패하면 `503`. 공개 주소로도 열리지만 아무 정보도 주지 않는다.
3. **백엔드 헬스체크:** `wget -qO- http://127.0.0.1:3001/health` (alpine busybox, 5xx면 종료 코드 비정상). 시작 직후 정리와 풀 생성 시간을 위해 `start_period: 180s`.
4. **대기 조건:** 백엔드는 `db: service_healthy`, nginx는 `backend: service_healthy` 뒤에 올라온다.
5. **nginx가 백엔드 없이도 시작되게:** `resolver 127.0.0.11 valid=5s`(Docker DNS)와 변수 `proxy_pass`로 요청 시점에 이름을 풀게 한다. 백엔드가 아직 없으면 nginx는 죽지 않고 502만 돌려주며, 백엔드 IP가 바뀌어도 따라간다 (재부팅 순서 문제 해결). 변수에 URI를 쓰지 않으므로 요청 경로는 지금과 같게 전달된다 (`/ws/` 접두사 포함).
6. **배포 대기:** `up -d --build --wait --wait-timeout 600`으로 실제 healthy가 되어야 배포가 성공한다.

## 범위 밖

- vcluster 풀 생성을 `listen` 뒤 백그라운드로 옮기는 것 (앱 코드 변경, 후보).
- k3d 클러스터가 죽어 있을 때 백엔드 시작 동작 점검.

## 수용 조건

- [x] `GET /health`가 DB 성공 시 200, 실패 시 503이다 (단위 테스트) — `검증됨`
- [x] `docker compose config`가 유효하고 헬스체크·대기 조건이 들어 있다 — `검증됨` (비밀 파일 없이 임시 env 파일로 확인)
- [x] nginx 설정이 백엔드 이름을 풀 수 없는 상태에서도 `nginx -t`를 통과한다 (이전 설정은 `host not found in upstream`으로 실패) — `검증됨`
- [x] 실제 동작: nginx를 백엔드보다 먼저 띄워도 죽지 않고 502만 돌려주며, 백엔드가 늦게 떠도 재시작 없이 연결되고, 백엔드 컨테이너를 교체(IP 변경)해도 따라가며, `/ws/…?x=1` 같은 경로가 그대로 전달된다 — `검증됨` (임시 Docker 네트워크에서 실행)
- [ ] 서버 배포에서 `--wait`가 healthy를 확인하고 성공한다 (`미검증`, 배포 후 확인)
- [ ] 롤백: 이전 커밋으로 되돌려 재배포

## 위험과 롤백

- 백엔드 시작이 `start_period`+재시도 시간보다 오래 걸리면 `--wait`가 실패한다. 첫 배포는 사용자가 적은 시간에 한다.
- `--wait`는 compose v2.1.1 이상이 필요하다 (서버의 버전은 확인하지 못함, 배포 로그로 확인).
- 문제가 생기면 이 변경 커밋을 되돌려 재배포한다 (설정 파일만 바뀐다).

## vcluster 정리 규칙 (2026-10-30)

- 증상: 개발 중 백엔드를 여러 번 재시작하거나 풀 생성이 실패하면 `vcluster-pool-*` 네임스페이스와 5Gi PVC 가 쌓였다. vcluster 본체(Helm 릴리스)는 이미 없는데 네임스페이스만 남아서 `vcluster delete` 가 "couldn't find vcluster" 로 아무것도 지우지 못했고, 오류를 삼켜서 아무도 알아채지 못했다.
- 규칙: vcluster 를 지우는 모든 경로(기동 시 정리, 사용 후 반납, 생성 도중 실패)는 `vcluster delete` 뒤에 `kubectl delete namespace vcluster-<id> --ignore-not-found --wait=false` 도 실행한다. 네임스페이스 삭제가 실패하면 로그를 남기고 호출한 쪽은 막지 않는다.
- 남은 항목: 풀 생성이 60초 안에 준비되지 않는 경우(동시 생성 부하)는 환경변수 `VCLUSTER_READY_TIMEOUT_SEC` 로 늘릴 수 있다. 풀 생성을 `listen` 뒤 백그라운드로 옮기는 것은 위 후보로 남아 있다.
