# 명세 — 세트 531 도커 문제 해결 상황집: compose 가 안 올라올 때

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 의 compose 문제 해결 항목. 샌드박스 `docker`(dind, compose 포함), 카테고리 `도커`, 단원 26, display_order 752. 선행: 세트 237·175·245·490(compose 기본·변수·config). 생성: `scripts/content-gen/new_sets/set531.py`.

오류 메시지 → 원인 → 고치기를 재현된 상황에서 직접 한다. 이미지는 `alpine`, `nginx:alpine` 만 쓴다. 각 문제의 setup 은 앞 문제의 컨테이너·네트워크·`/tmp/work` 를 먼저 지운다. 기존 compose 세트가 다룬 문법·`config`·변수 우선순위는 사전지식으로 쓰고, 여기서는 "안 올라오는 상황"의 진단에 집중한다.

## 구성

| # | 형식 | 상황 | 고치면 |
|---|---|---|---|
| 1 | 실습 | YAML 들여쓰기 오류 (`did not find expected key`) | `config -q` 통과, 서비스 목록 저장 |
| 2 | 실습 | `${APP_IMAGE:?...}` 필수 변수 누락 | `.env` 로 값을 주고 web 실행 (compose.yaml 유지) |
| 3 | 실습 | 변수 이름 오타(`TAGS`)로 태그가 조용히 빈 값 | `config` 로 풀린 결과 확인·저장, `.env` 수정 후 `nginx:1.27-alpine` |
| 4 | 실습 | `port is already allocated` | blocker 유지, 호스트 포트만 변경해 web 실행 |
| 5 | 실습 | `container name ... already in use` | 옛 컨테이너 삭제 후 compose 로 web 실행 |
| 6 | 실습 | `depends_on` 만으로는 준비 보장 안 됨 | healthcheck + `condition: service_healthy`, 로그에 CONNECTED |
| 7 | 실습 | `Found orphan containers` | `up -d --remove-orphans` |
| 8 | 객관식 | 짧은 `depends_on` 이 보장하는 것 = 시작 순서 | |
| 9 | 객관식 | `port is already allocated` = 호스트 포트 중복 | |
| 10 | 빈칸 | `docker compose up -d {--remove-orphans}` | |
| 11 | 순서 | 점검 순서: 문법 → 풀린 값 → ps -a → logs | |

## 수용 조건

- [ ] `verify:quests --set 531` 실습 7개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(터미널·객관식·빈칸·순서), 터미널 7/11
- [ ] hint 는 방향만(정답 값·명령 전체·순서를 알려 주지 않음)
- [ ] `check-content.sh` 통과, 현장 정보 없음 (`example` 수준의 일반 이름만)
