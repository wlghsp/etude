# 명세 — 도커 출력에서 원하는 값만 뽑기 세트 (inspect -f · ps --format)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 근거: k8s 의 jsonpath 세트(세트 224)에 대응하는 도커 쪽 훈련이 없다. `docker inspect -f` 는 흩어진 문제 몇 개(세트 97 등)에만 나온다. 도커 단원 구조: [spec_docker_unit_split.md](spec_docker_unit_split.md).

## 목표

`docker inspect` 가 주는 JSON 의 구조를 읽고 `-f`(Go 템플릿)로 **값 하나만** 뽑고, `docker ps --format`·`--filter` 로 목록을 원하는 모양으로 만드는 손버릇을 만든다. 장애 때 상태·종료 코드·IP·환경 변수를 빠르게 확인하고, 스크립트에서 값을 이어 쓰는 데 매번 쓰는 기술이다.

## 원칙

- 터미널 실습은 결과 파일(`/tmp/*.txt`)의 **내용**으로 채점한다. 파일이 있는지만 보지 않는다.
- 새 개념은 한 문제에 하나. 앞 문제의 표현을 다음 문제가 한 칸씩 넓힌다.
- 이미지는 `alpine` 하나만 쓴다 (샌드박스마다 새로 받으므로 서버 부담 최소).
- 문제 setup 은 컨테이너 `web`(실행 중, 포트 8080:80, `APP_ENV=prod`, 레이블 `tier=frontend`), `db`(실행 중, 레이블 `tier=backend`), `job`(종료 코드 3 으로 끝난 것)을 만든다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | 상태만 뽑기 | `docker inspect -f '{{.State.Status}}'` |
| 2 | 터미널 | 이미지 이름 | `{{.Config.Image}}` |
| 3 | 터미널 | IP 주소 | `{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}` (새 Docker 는 최상위 IPAddress 가 없다) |
| 4 | 터미널 | 종료 코드 | `{{.State.ExitCode}}` |
| 5 | 빈칸 | 실행 중인지 true/false | `State.Running` 경로 채우기 |
| 6 | 터미널 | 환경 변수를 한 줄씩 | `{{range .Config.Env}}{{println .}}{{end}}` |
| 7 | 터미널 | 레이블 값 | `{{index .Config.Labels "tier"}}` |
| 8 | 터미널 | 모든 컨테이너 이름만 | `docker ps -a --format '{{.Names}}'` |
| 9 | 터미널 | 이름과 상태 표 | `--format 'table {{.Names}}\t{{.Status}}'` |
| 10 | 객관식 | 종료된 것까지 ID 만 | `docker ps -aq` |
| 11 | 터미널 | 종료된 컨테이너 이름만 | `--filter status=exited --format` |
| 12 | 순서 | 값 하나를 찾는 흐름 | ps → inspect 전체 → `-f` 로 좁히기 → 스크립트에 넣기 |

## 배치

- 분야 도커, 단원 **32 컨테이너 다루기** 의 마지막. 세트 225, `display_order` 187, 아이콘 🔎. 한 단원의 `display_order` 가 이어져야 하므로 뒤의 도커 세트(11, 167, 218, 183, 221, 154, 187, 8, 142, 179, 209, 148, 175, 206)를 187~200 → 188~201 로 한 칸씩 민다 (절대값 UPDATE 라 여러 번 실행해도 안전). 201 은 다른 세트가 쓰지 않는다.
- `sandbox_type = docker`, `time_limit_sec` 없음. 구현: `scripts/content-gen/example_practice_set.py` 를 복사해 만든다 (예시를 직접 실행하지 않는다).

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 225`). (검증됨: 9/9)
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다 (거짓 통과 없음). (검증됨)
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다. (10번: docker ps -aq)
- [x] `checks` 가 결과 파일의 내용을 확인한다.
- [x] 각 문제 `docs` 에 Docker 공식 문서 링크가 있다.
- [x] 도커 단원의 `display_order` 가 이어진다 (단원 5개, 32 는 9세트 179~187).
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 홈 도커 탭 `컨테이너 다루기` 단원 끝에 보이고 1~12번이 순서대로 풀린다 (수동 확인).
