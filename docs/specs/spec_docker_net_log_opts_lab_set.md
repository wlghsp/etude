# 명세 — 도커 네트워크·로그·종료·보안 옵션 손연습 세트 (498)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (도커 40% 목표). 겹치지 않는 주제: `--network-alias`, `--subnet`·`--ip`, `--dns`, `--log-opt`, `--stop-signal`·`--stop-timeout`, `--mount readonly`, `--sysctl`, `ps --no-trunc`, `no-new-privileges`.

## 구성 (12문제, 세트 498, sandbox `docker`, 분야 도커, 단원 `네트워크와 볼륨`(34) 끝, 🛰)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | `--network-alias db`, 다른 컨테이너에서 `ping db` |
| 2 | 터미널 | `network create --subnet` + `--ip 172.30.0.10` |
| 3 | 터미널 | `--dns 1.1.1.1` |
| 4 | 터미널 | `--log-opt max-size=1m --log-opt max-file=3` |
| 5 | 터미널 | `--stop-signal SIGINT --stop-timeout 3` |
| 6 | 터미널 | `--mount type=volume,...,readonly` |
| 7 | 터미널 | `--sysctl net.core.somaxconn=1024` |
| 8 | 터미널 | `docker ps -q --no-trunc` 로 전체 ID 저장 |
| 9 | 터미널 | `--security-opt no-new-privileges` + `--cap-drop ALL --cap-add` |
| 10 | 객관식 | stop 대기 시간이 지나면 SIGKILL |
| 11 | 빈칸 | `--network-{0}` (alias) |
| 12 | 순서 | 고정 IP 컨테이너 만드는 순서 |

- 이미지는 `alpine` 하나만 써서 Docker Hub 요청 한도 소모를 줄였다.
- 알려진 한계: 로그 순환이 실제로 일어나는지, 종료 신호 처리 결과는 확인하지 않고 설정값만 확인한다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인 (`검증됨`).
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 도커 탭에서 보이고 1~12번이 풀린다 (수동 확인).
