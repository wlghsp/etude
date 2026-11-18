# 명세 — 도커 컨테이너 수명주기 실습 세트 (478)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md). 기존 도커 실습 16개가 다루지 않은 `create`·`pause`·`stop -t`·`kill -s`·`wait`·`events`·`exec -u`·`logs --tail` 를 손으로 해 본다. 짝 퀴즈: 171/244(상태와 종료 신호), 191/249(실행 중 컨테이너), 212/255(종료 코드), 199/251(exec·attach).

## 구성 (12문제, 세트 478, sandbox `docker`, 분야 도커)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `create` → 상태 created → `start` | q1=created, running |
| 2 | 터미널 | `pause` → `unpause` | q2=paused, running |
| 3 | 터미널 | SIGTERM 무시 컨테이너 `stop -t 2` | 종료 코드 137, exited |
| 4 | 터미널 | `kill -s USR1` | 로그 got-usr1, 계속 실행 |
| 5 | 터미널 | `wait` 종료 코드 | 7 |
| 6 | 터미널 | 없는 명령 종료 코드 | 127 |
| 7 | 터미널 | `exec -u -w -e` | `hi nobody /tmp` |
| 8 | 터미널 | `logs -t --tail 2` | 시각 + line5·line6 |
| 9 | 터미널 | `events --filter` | die 1줄, evt |
| 10 | 객관식 | `docker stop` 기본 동작 | |
| 11 | 빈칸 | `docker {0} -s USR1` (kill) | |
| 12 | 순서 | stop 이 끝내는 순서 | |

- 컨테이너 setup 은 기존 컨테이너를 지우고 `alpine` 이 없으면 받는다. 신호·종료 코드는 결정적이도록 `sh -c` 의 `trap` 과 `exit` 로 만든다.
- 근거: 도커 공식 CLI 레퍼런스(container create·pause·stop·kill·wait·exec·logs·run exit status, system events).

## 알려진 한계

`docker attach` 의 detach 키, `--stop-signal`·`--stop-timeout`, `docker update`, `restart` 정책의 재시작 횟수 읽기, 컨테이너 `rename` 은 다루지 않았다 (후속 세트 후보).

## 배치

도커 단원 `컨테이너 조회·종료 코드·실습`(66) 끝, display_order 201, 아이콘 ⏯️. 단원이 12세트가 되었다.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`).
- [x] 객관식 정답을 DB 에서 확인한다.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 도커 탭에서 보이고 1~12번이 풀린다 (수동 확인).
