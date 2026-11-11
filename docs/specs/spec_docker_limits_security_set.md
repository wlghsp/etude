# 명세 — 도커 자원 제한과 컨테이너 보안 기본 실습 세트 (--memory·--cpus·--pids-limit·update·--read-only·--tmpfs·--user·--cap-drop)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11, 구현 전 검증만 완료). 근거: 자원 제한과 보안 기본은 퀴즈형 세트 148·160·195·240·242·250(분할판 포함)이 개념으로 다루고, 세트 231 은 `docker stats`·cgroup 읽기에 가깝다. 이 세트는 **`alpine` 컨테이너에 제한·보안 옵션을 직접 걸고 `inspect` 값과 컨테이너 안의 실제 동작으로 채점**하는 드릴이라는 점에서 다르다.

## 목표

`--memory`, `--cpus`, `--pids-limit` 을 걸고 `docker inspect -f` 로 읽어 보고(바이트·NanoCpus 단위), `docker update` 로 실행 중에 바꾸고(memory 와 memory-swap 은 한 쌍), `--read-only`·`--tmpfs`, `--user`, `--cap-drop ALL`/`--cap-add`, `--security-opt no-new-privileges` 가 컨테이너 안에서 어떤 결과를 내는지 확인한다.

## 원칙

- 터미널 실습은 **결과 상태**(`HostConfig` 값, 실행 여부, `docker exec` 로 시험한 쓰기·`id`·`CapEff`)로 채점한다. setup 만 한 상태에서는 반드시 실패한다.
- 새 개념은 한 문제에 하나. 쉬운 것에서 어려운 것으로.
- 이미지는 `alpine` 만 쓴다. setup 은 컨테이너·이미지·`/tmp/work` 를 비우고 `alpine` 을 다시 받아 여러 번 실행해도 안전하다.
- 타이밍·메모리 사용량에 의존하지 않는다. OOM 은 결과가 환경에 따라 달라질 수 있어 터미널이 아닌 객관식으로 둔다.
- 기존 퀴즈 세트와 겹치지 않도록 터미널은 상태 채점 드릴에 집중하고, 객관식·빈칸·순서는 최소한만 둔다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | 메모리 상한을 걸고 컨테이너 띄우기 | `--memory 64m`, `HostConfig.Memory`(바이트) |
| 2 | 터미널 | CPU 를 절반만 쓰게 제한하기 | `--cpus 0.5`, `NanoCpus` |
| 3 | 터미널 | 프로세스 개수 제한하기 | `--pids-limit 50`, `PidsLimit` |
| 4 | 터미널 | 걸려 있는 메모리 제한 읽어서 저장하기 | `inspect -f` 로 값 읽기 |
| 5 | 객관식 | 메모리를 넘겨 쓰면 컨테이너는 어떻게 될까 | OOM kill, 종료 코드 137, `State.OOMKilled` |
| 6 | 터미널 | 돌고 있는 컨테이너의 메모리 한도 올리기 | `docker update --memory` + `--memory-swap` |
| 7 | 터미널 | 루트 파일시스템을 읽기 전용으로 | `--read-only`, `Read-only file system` |
| 8 | 터미널 | 읽기 전용인데 /tmp 만 쓸 수 있게 | `--tmpfs /tmp` |
| 9 | 터미널 | root 가 아닌 사용자로 실행하기 | `--user 1000:1000`, `id -u` |
| 10 | 터미널 | 권한(capability)을 다 빼고 필요한 것만 주기 | `--cap-drop ALL`, `--cap-add CHOWN`, `CapEff` |
| 11 | 빈칸 | 권한 상승을 막는 보안 옵션 | `--security-opt no-new-privileges` |
| 12 | 순서 | 제한을 걸고 확인하고 고치는 흐름 | run → inspect → exec → update → rm |

`--restart unless-stopped`, `--rm` 은 12번 순서 문제 밖에서 다루지 않는다(재시작 정책은 값별 차이가 데몬 재시작 시점에만 드러나 상태 채점이 어렵다).

## 배치

- 세트 340, `sandbox_type = docker`, 분야 `도커`. 단원·display_order 는 통합 시 정한다. 구현: 스크래치패드 `gen340.py`(산출물은 `backend/db/03_quest_set340.sql`, `02_quest_set.sql` 한 줄, `backend/verify/set340.json`, `backend/db/migrations/2026-11-13_docker_limits_security_set340.sql`), 검증 하네스 `h340.py`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 340`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] 객관식 5번 정답 번호를 DB 에서 보기 글자로 확인한다.
- [x] 빈칸 11번 칩에 두 번째 정답이 없다 (`no-new-privileges` 만 유효).
- [x] 채점이 타이밍·메모리 사용량·진행 출력에 의존하지 않는다.
- [x] 각 문제 `docs` 의 Docker 공식 문서 링크가 HTTP 200 이다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 도커 탭에 보이고 1~12번이 순서대로 풀린다 (수동 확인, 배치 후).
