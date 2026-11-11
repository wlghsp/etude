# 명세 — 도커 헬스체크와 재시작 정책 실습 세트 (--health-cmd·State.Health·health 필터·HEALTHCHECK·--restart·RestartCount·update)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 근거: 헬스체크·재시작 정책은 퀴즈형 세트 187·248(HEALTHCHECK), 191·249(재시작 정책)가 개념으로 다루고, 세트 231 11번이 `RestartCount` 읽기 한 문제를 다룬다. 이 세트는 **`alpine` 컨테이너에 헬스체크와 재시작 정책을 직접 걸고, 상태가 바뀌는 것(starting → unhealthy → healthy, 재시작 횟수 증가)을 읽고 고쳐서 상태로 채점**하는 드릴이라는 점에서 다르다.

## 목표

`--health-cmd`·`--health-interval`·`--health-retries` 로 헬스체크를 달고 `docker inspect -f '{{.State.Health.Status}}'` 로 상태(starting/healthy/unhealthy)를 읽고, `docker exec` 로 원인을 고쳐 healthy 로 만들고, `docker ps --filter health=...` 로 거르고, Dockerfile 의 `HEALTHCHECK` 를 빌드해 확인한다. 이어서 `--restart on-failure:3`·`unless-stopped`·`always` 가 종료·kill·stop 에서 어떻게 다르게 동작하는지 `RestartCount` 와 `HostConfig.RestartPolicy` 로 확인하고, `docker update --restart` 로 실행 중에 바꾼다.

## 원칙

- 터미널 실습은 **결과 상태**(`State.Health.Status`, `RestartPolicy`, `RestartCount`, 실행 여부)로 채점한다. setup 만 한 상태에서는 반드시 실패한다.
- 헬스체크 간격은 2초, 재시도 1회로 짧게 둔다. 채점은 최대 약 24~30초까지 **폴링**하고, `RestartCount` 는 정확한 값이 아니라 `>= 1` 로만 본다 (읽어 저장하는 문제는 "현재 값과 같은가" 로 본다).
- 새 개념은 한 문제에 하나. 쉬운 것에서 어려운 것으로.
- 이미지는 `alpine` 만 쓴다(Dockerfile 도 `FROM alpine`, `/tmp/work` 에서 빌드). setup 은 컨테이너·이미지·`/tmp/work` 를 비우고 `alpine` 을 다시 받아 여러 번 실행해도 안전하다.
- 데몬 재시작이 필요한 `always` vs `unless-stopped` 차이는 터미널로 채점하지 않는다(해설로만 언급).
- 기존 퀴즈 세트와 겹치지 않도록 터미널은 상태 채점 드릴에 집중하고, 빈칸·객관식·순서는 최소한만 둔다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | 헬스체크를 달아 컨테이너 띄우기 | `--health-cmd`, `--health-interval 2s`, `--health-retries 1` |
| 2 | 빈칸 | 헬스 상태를 읽는 템플릿 | `.State.Health.Status` (`.State.Status` 와 구분) |
| 3 | 터미널 | unhealthy 컨테이너를 healthy 로 만들기 | `docker exec` 로 검사 대상 파일 만들기 |
| 4 | 터미널 | unhealthy 컨테이너 이름만 모으기 | `docker ps --filter health=unhealthy --format` |
| 5 | 터미널 | Dockerfile 에 HEALTHCHECK 넣기 | `HEALTHCHECK --interval --retries CMD`, `docker build` |
| 6 | 객관식 | unhealthy 가 되면 도커는 무엇을 할까 | 헬스체크는 표시만, 재시작은 정책의 일 |
| 7 | 터미널 | 실패하면 최대 3번까지만 재시작 | `--restart on-failure:3`, `RestartCount` |
| 8 | 터미널 | 죽어도 되살아나는 컨테이너 | `unless-stopped`, `docker kill` 후 재시작 |
| 9 | 터미널 | 재시작 횟수를 읽어 저장하기 | `inspect -f '{{.RestartCount}}'` |
| 10 | 터미널 | always 컨테이너를 stop 하면 | `docker stop` 은 정책이 되살리지 않는다 |
| 11 | 터미널 | 돌고 있는 컨테이너의 재시작 정책 바꾸기 | `docker update --restart` (컨테이너 ID 유지) |
| 12 | 순서 | 헬스체크와 재시작 정책을 점검하는 흐름 | run → inspect → exec → ps --filter → update |

## 겹침 점검

- 퀴즈 세트 187·248(HEALTHCHECK·헬스체크 끄기·상태 변화), 191·249(재시작 정책 바꾸기·`--health-*`), 세트 97(장애 점검의 재시작 정책)과 주제가 겹친다. 이 세트는 터미널 상태 채점 드릴이고, 객관식은 "unhealthy 여도 재시작하지 않는다" 한 문제만 두어 기존 퀴즈의 반복을 피한다.
- 세트 231 11번(`RestartCount` 읽기)과 이 세트 9번이 비슷하다. 9번은 `on-failure:3` 로 멈춘 컨테이너를 읽는 한 문제로 두고, 나머지는 정책별 동작 차이에 쓴다.

## 배치

- 세트 343, `sandbox_type = docker`, 분야 `도커`. 단원·display_order 는 통합 시 정한다. 구현: 스크래치패드 `gen343.py`(산출물은 `backend/db/03_quest_set343.sql`, `02_quest_set.sql` 한 줄, `backend/verify/set343.json`, `backend/db/migrations/2026-11-13_docker_health_restart_set343.sql`), 검증 하네스 `h343.py`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 343`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] 객관식 6번 정답 번호를 DB 에서 보기 글자로 확인한다.
- [x] 빈칸 2번 칩에 두 번째 정답이 없다 (`Health` 만 유효).
- [x] 채점이 타이밍에 흔들리지 않는다 (폴링 상한 내 통과, `RestartCount` 는 `>= 1`).
- [x] 각 문제 `docs` 의 Docker 공식 문서 링크가 HTTP 200 이다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 도커 탭에 보이고 1~12번이 순서대로 풀린다 (수동 확인, 배치 후).
