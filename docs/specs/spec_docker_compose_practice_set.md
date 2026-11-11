# 명세 — 도커 Compose 손으로 해 보기 실습 세트 (compose.yaml·up·ps·logs·exec·환경 변수·볼륨·-p·depends_on)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 근거: Compose 는 퀴즈형 세트 148·175·206 이 다루지만 전부 객관식·빈칸·순서다. 직접 `compose.yaml` 을 쓰고 올려서 **떠 있는 컨테이너·로그·컨테이너 안 파일·환경 변수**로 채점하는 터미널 실습은 없다. 이 세트가 그 빈자리를 채운다. (`docker:dind` 에 `docker compose` 플러그인이 포함돼 있음을 확인했다: v5.7.0)

## 목표

`/tmp/stack` 에 `compose.yaml` 을 heredoc 으로 쓰고 `docker compose up -d` 로 올린다. `ps --format`, `logs`, `exec` 로 상태를 확인하고, `environment`, `.env` 변수 치환, 이름 있는 볼륨, `-p` 프로젝트 이름, `depends_on` 이 실제 컨테이너 상태에 어떻게 나타나는지 익힌다.

## 원칙

- 터미널 실습은 **스택의 상태**(프로젝트·서비스 라벨이 붙은 실행 중 컨테이너, 컨테이너 안 파일·환경 변수, 저장한 파일 내용)로 채점한다. setup 만 한 상태에서는 반드시 실패한다.
- 새 개념은 한 문제에 하나. 쉬운 것에서 어려운 것으로.
- 이미지는 `alpine` 하나만 쓰고 `apk add` 등 네트워크 설치는 하지 않는다. setup 이 `alpine` 을 미리 받고, 컨테이너·네트워크·볼륨·`/tmp/stack` 을 지우고 다시 만들어 여러 번 실행해도 안전하다.
- 프로젝트 이름은 기본값(디렉터리 이름 `stack`)을 쓰고, 채점은 `com.docker.compose.project`·`service` 라벨로 한다. 출력 문구(진행 표시, 컨테이너 이름 형식)에는 의존하지 않는다.
- 148·175·206 퀴즈 세트와 겹치지 않도록 **직접 만든 스택의 결과로 채점**하는 방식에 집중한다. 객관식·빈칸·순서는 실습을 보완하는 최소한만 둔다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | compose.yaml 쓰고 올리기 | `services`, `image`, `command`, `up -d` |
| 2 | 터미널 | 서비스 이름만 뽑아 저장 | `compose ps --format '{{.Service}}'` |
| 3 | 터미널 | 서비스 로그를 접두사 없이 저장 | `compose logs`, `--no-log-prefix` |
| 4 | 터미널 | 서비스 안에서 명령 실행 | `compose exec 서비스` |
| 5 | 객관식 | command 와 이미지의 CMD | `command` 가 `CMD` 를 대체 |
| 6 | 터미널 | 서비스에 환경 변수 넣기 | `environment`, 수정 후 `up -d` 재적용 |
| 7 | 터미널 | .env 파일로 변수 채우기 | `.env`, `${변수}` 치환, `config` |
| 8 | 터미널 | 내렸다 올려도 남는 데이터 | 이름 있는 볼륨, `down`(`-v` 없이) |
| 9 | 빈칸 | 서비스 로그 마지막 몇 줄만 | `logs --tail N 서비스` |
| 10 | 터미널 | 같은 파일로 프로젝트 하나 더 | `-p`, 프로젝트 분리, `ls` |
| 11 | 터미널 | depends_on 으로 시작 순서 정하기 | `depends_on`, `config` 로 확인 |
| 12 | 순서 | Compose 스택 만들고 정리하는 흐름 | 작성 → config → up -d → ps → logs → down |

## 배치

- 세트 237, `sandbox_type = docker`, 분야 `도커`. 단원·display_order 는 통합 시 정한다. 구현: 스크래치패드 `gen237.py`(산출물은 `backend/db/03_quest_set237.sql`, `02_quest_set.sql` 한 줄, `backend/verify/set237.json`, 마이그레이션), 검증 하네스 `h237.py`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 237`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다. (5번: Compose 의 `command` 가 이미지의 `CMD` 를 대체)
- [x] 빈칸 9번의 칩에 두 번째 정답이 없다 (`5`, `web`).
- [x] 채점이 `compose` 진행 출력·컨테이너 이름 형식에 의존하지 않는다 (라벨·파일 내용·exec 결과만 사용).
- [x] 각 문제 `docs` 에 Docker 공식 문서 링크가 있다 (HTTP 200 확인).
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 홈 도커 탭에 보이고 1~12번이 순서대로 풀린다 (수동 확인, 배치 후).
