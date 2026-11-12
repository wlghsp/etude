# 명세 — 도커 Dockerfile 직접 쓰기 실습 세트 (FROM·RUN·LABEL·WORKDIR·CMD·ENV·ARG·캐시·.dockerignore·멀티 스테이지·USER)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 근거: Dockerfile 은 퀴즈형 세트 11·38·154·167·187·218·221(및 짝 세트)이 개념으로 다루고, 터미널 세트 234 가 `Dockerfile 쓰기·ENV·ARG·COPY·ENTRYPOINT·.dockerignore·history` 의 기본을 한 번 훑는다. 이 세트는 **WORKDIR, run 에서 CMD·ENV 덮어쓰기, ARG→ENV 이어 담기, 빌드 캐시 재사용, `.dockerignore` 의 `!` 예외, 멀티 스테이지, USER** 처럼 234 가 다루지 않은 부분에 집중한 심화 드릴이다.

## 목표

`/tmp/work` 에서 `alpine` 만 써서 Dockerfile 을 직접 쓰고 빌드한다. `FROM`·`RUN`·`LABEL` 로 첫 이미지를 만들고, `WORKDIR` 로 작업 폴더를 정하고, `docker run` 에서 `CMD` 와 `ENV` 를 덮어쓴다. `--build-arg` 로 받은 `ARG` 를 `ENV` 에 이어 담고, 레이어 순서와 캐시 재사용을 `RootFS.Layers` 로 확인하고, `.dockerignore` 의 `!` 예외를 쓰고, 멀티 스테이지 `COPY --from` 으로 결과 파일만 담고, `USER` 로 root 가 아닌 사용자로 실행한다.

## 원칙

- 터미널 실습은 **이미지·컨테이너의 결과 상태**(`docker image inspect` 의 `Config.Env`·`Config.User`·`Config.WorkingDir`·`Labels`·`RootFS.Layers`, 컨테이너 출력, 이미지 안 파일 유무)로 채점한다. 빌드 로그 글자(`CACHED` 등)는 BuildKit 버전에 따라 달라 채점에 쓰지 않는다.
- setup 만 한 상태에서는 반드시 실패한다. 캐시 문제(8번)는 `--no-cache` 로 풀면 실패하도록 레이어 ID 비교로 채점한다.
- 새 개념은 한 문제에 하나. 쉬운 것에서 어려운 것으로.
- 이미지는 `alpine` 만 쓴다. setup 은 컨테이너·이미지·`/tmp/work` 를 비우고 `alpine` 을 다시 받아 여러 번 실행해도 안전하다.
- 빈칸 7번 칩에는 두 번째 정답이 없다 (`builder` 만 유효). 객관식 4번은 정답을 첫 보기로 쓰고 헬퍼가 위치를 섞는다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | FROM, RUN, LABEL 로 첫 이미지 만들기 | `FROM`·`RUN`(빌드 때 실행)·`LABEL`, `docker build -t` |
| 2 | 터미널 | WORKDIR 로 작업 폴더 정하기 | `WORKDIR`, 상대 경로 `COPY .`, `Config.WorkingDir` |
| 3 | 터미널 | CMD 는 실행할 때 갈아끼울 수 있다 | `docker run 이미지 명령` 이 `CMD` 를 대체 |
| 4 | 객관식 | ENTRYPOINT 가 있을 때 run 인자는 | ENTRYPOINT + CMD 조합에서 run 인자는 CMD 를 대체 |
| 5 | 터미널 | ENV 기본값과 run 에서 덮어쓰기 | `ENV` 는 기본값, `docker run -e` 가 덮어씀 |
| 6 | 터미널 | ARG 값을 ENV 로 이어서 남기기 | `--build-arg`, `ARG`→`ENV`, ARG 는 이미지에 안 남음 |
| 7 | 빈칸 | 다른 단계에서 파일 가져오기 | `COPY --from=단계이름` |
| 8 | 터미널 | 캐시가 살아 있는 재빌드 | 변경 줄 위쪽 레이어 재사용, `docker history`, `--no-cache` 금지 |
| 9 | 터미널 | .dockerignore 로 빼고 예외 두기 | `*.log`, `!예외`, 폴더 제외 |
| 10 | 터미널 | 멀티 스테이지로 결과 파일만 담기 | `AS builder`, `COPY --from`, 최종 이미지에 중간 산출물 없음 |
| 11 | 터미널 | root 가 아닌 사용자로 실행하기 | `USER`, `Config.User` |
| 12 | 순서 | Dockerfile 을 캐시에 좋은 순서로 쓰기 | FROM → WORKDIR → COPY(의존성) → RUN → COPY(소스) → CMD |

## 겹침 점검

- **세트 234(터미널, 같은 계열)와 가장 겹친다.** 234 는 Dockerfile 쓰기(1)·ENV(4)·ENV vs ARG(5)·`--build-arg`(6)·COPY(7)·ENTRYPOINT 인자(8)·`--entrypoint` 빈칸(9)·`.dockerignore`(10)·history 레이어 수(11)를 다룬다. 이 세트의 1번(RUN·LABEL 중심), 6번(ARG→ENV 이어 담기), 9번(`!` 예외·폴더 제외)은 같은 주제의 다른 각도이고, 2·3·5·8·10·11번(WORKDIR, CMD 덮어쓰기, ENV 덮어쓰기, 캐시 재사용, 멀티 스테이지, USER)과 객관식 4번(ENTRYPOINT+CMD 조합)은 새롭다. 통합 시 234 바로 뒤에 두거나 234 와 순서를 맞춘다.
- 세트 337(이미지 관리: pull·tag·rmi·prune·commit·save·load)과는 주제가 겹치지 않는다. 이 세트는 이미지 **만들기**(Dockerfile)만 다루고 이미지 목록 관리는 하지 않는다.
- 퀴즈형 세트 11·38·154·167·187·218·221(및 짝)은 지시어·캐시·`.dockerignore` 를 읽고 고르는 개념 문제다. 이 세트는 직접 쓰고 빌드해 상태로 채점하는 점이 다르다. 세트 343 5번(HEALTHCHECK 빌드)과는 지시어가 다르다.

## 배치

- 세트 346, `sandbox_type = docker`, 분야 `도커`. 단원·display_order 는 통합 시 정한다. 구현: 스크래치패드 `gen346.py`(산출물은 `backend/db/03_quest_set346.sql`, `02_quest_set.sql` 한 줄, `backend/verify/set346.json`, `backend/db/migrations/2026-11-13_docker_dockerfile_set346.sql`), 검증 하네스 `h346.py`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 346`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [ ] 8번은 `--no-cache` 로 빌드하면 채점이 실패한다 (캐시 재사용을 레이어 ID 로 확인).
- [x] 객관식 4번 정답 번호를 DB 에서 보기 글자로 확인한다.
- [x] 빈칸 7번 칩에 두 번째 정답이 없다 (`builder` 만 유효).
- [ ] 채점이 빌드 로그 글자에 의존하지 않는다 (`docker image inspect`·컨테이너 출력·파일 유무만 사용).
- [ ] 각 문제 `docs` 의 Docker 공식 문서 링크가 HTTP 200 이다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 도커 탭에 보이고 1~12번이 순서대로 풀린다 (수동 확인, 배치 후).
