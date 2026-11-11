# 명세 — 도커 이미지 손으로 만들기 실습 세트 (Dockerfile·build·tag·ENV/ARG·ENTRYPOINT·.dockerignore·history)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 근거: 이미지 빌드는 세트 11(터미널 6문제, 기본 흐름)과 퀴즈형 세트 154·167·218·221·187 이 다룬다. 이들은 대부분 객관식·빈칸·순서라, 직접 Dockerfile 을 쓰고 **만들어진 이미지의 결과**(실행 출력, 파일 내용, 태그)로 채점하는 실습은 부족하다. 이 세트는 그 빈자리를 더 깊게 채운다.

## 목표

`/tmp/app` 에 Dockerfile 을 heredoc 으로 쓰고 `docker build -t 이름:태그 .` 로 빌드한다. `docker images` 필터와 `docker tag` 로 이름을 다루고, `ENV`·`ARG`(`--build-arg`)의 차이를 익힌다. `COPY`, `ENTRYPOINT` 와 `docker run` 인자, `.dockerignore` 의 효과, `docker history` 레이어 확인으로 이미지가 의도대로 만들어졌는지 검증한다.

## 원칙

- 터미널 실습은 **만들어진 이미지의 상태**(태그 존재, `docker run --rm 이미지` 출력, 이미지 안 파일 내용)로 채점한다. setup 만 한 상태에서는 반드시 실패한다.
- 새 개념은 한 문제에 하나. 쉬운 것에서 어려운 것으로.
- 기반 이미지는 `alpine` 하나만 쓰고, `apk add` 등 네트워크 설치는 하지 않는다. setup 이 `alpine` 을 미리 받아 빌드가 빠르다. setup 은 컨테이너·이미지·`/tmp/app` 을 지우고 다시 만들어 여러 번 실행해도 안전하다.
- 최신 Docker(BuildKit)는 빌드 출력과 `docker history` 열이 다르므로 **출력 문구가 아니라 결과와 구조**만 채점한다.
- 154·167·218·221·187 의 퀴즈형 세트, 11(기본 빌드 흐름)과 겹치지 않도록, 직접 만든 이미지의 결과로 채점하는 방식에 집중한다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | Dockerfile 을 쓰고 이미지 만들기 | heredoc 으로 Dockerfile, `build -t`, `CMD` |
| 2 | 터미널 | 이미지 목록에서 태그만 골라 저장 | `docker images 저장소 --format '{{.Tag}}'` |
| 3 | 터미널 | 이미지에 이름 하나 더 붙이기 | `docker tag` |
| 4 | 터미널 | ENV 로 값 넣은 이미지 | `ENV`, 셸 형식 `CMD` |
| 5 | 객관식 | ENV 와 ARG 의 차이 | 빌드 중 변수 vs 실행 중에도 남는 변수 |
| 6 | 터미널 | 빌드할 때 값 바꿔 넣기 | `ARG`, `--build-arg` |
| 7 | 터미널 | COPY 로 파일 넣은 이미지 | `COPY`, 빌드 컨텍스트 |
| 8 | 터미널 | ENTRYPOINT 와 실행 인자 | `ENTRYPOINT`, `run 이미지 인자`, `inspect` 의 Entrypoint |
| 9 | 빈칸 | 실행 파일 바꿔 실행 | `docker run --entrypoint` |
| 10 | 터미널 | .dockerignore 로 파일 빼고 빌드 | `.dockerignore` |
| 11 | 터미널 | 이미지 레이어 내역 세어 보기 | `docker history --format`, RUN 당 레이어 |
| 12 | 순서 | 손으로 이미지 만들고 확인하는 흐름 | 작성 → build → images → run → inspect |

## 배치

- 세트 234, `sandbox_type = docker`, 분야 `도커`. 단원·display_order 는 통합 시 정한다. 구현: 스크래치패드 `gen234.py`(산출물은 `backend/db/03_quest_set234.sql`, `02_quest_set.sql` 한 줄, `backend/verify/set234.json`, 마이그레이션), 검증 하네스 `h234.py`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 234`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다. (5번: `ARG` 는 빌드 때만, `ENV` 는 실행 때도 남는다)
- [x] 빈칸 9번의 칩에 두 번째 정답이 없다 (`echo`, `overridden`).
- [x] 채점이 빌드 출력·`docker history` 열 문구에 의존하지 않는다 (11번은 `CreatedBy` 의 `echo` 줄 수).
- [x] 각 문제 `docs` 에 Docker 공식 문서 링크가 있다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 홈 도커 탭에 보이고 1~12번이 순서대로 풀린다 (수동 확인, 배치 후).
