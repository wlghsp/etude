# 명세 — 세트 552 Compose 구성 실습: 네트워크 분리·healthcheck·이미지 갱신·override 파일

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 의 "Compose 구성 실습" 행. 샌드박스 `docker`(dind, compose 포함), 카테고리 `도커`, 단원 35, display_order 812. 선행: 세트 237·175·245(compose 기본·변수·depends_on). 531(compose 상황집)과는 겹치지 않게, 531 이 "안 올라올 때 진단"이라면 여기는 "구성을 직접 바꾸기"다. 생성: `scripts/content-gen/new_sets/set552.py`.

이미지는 `alpine`, `nginx:alpine` 만 쓴다. 각 문제의 setup 은 앞 문제의 컨테이너·네트워크·`q6-app` 이미지·`/tmp/work` 를 먼저 지운다. 자원 제한(5번째 개념)은 12번에서 `Memory`·`NanoCpus` 로 확인한다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 최상위 `networks` 로 frontend/backend 분리 | api 는 web·db 를 찾고, web↔db 는 서로 안 보임 (ping) |
| 2 | 객관식 | 네트워크 이름 `프로젝트_네트워크` | |
| 3 | 실습 | healthcheck 쓰기 + `service_healthy` | db healthy, Healthcheck.Test 에 /tmp/ready, config 에 condition |
| 4 | 실습 | unhealthy 상태·`.State.Health.Log` 읽기 | 저장한 출력, `/tmp/ok` 생성 후 healthy |
| 5 | 빈칸 | `up -d --wait` | |
| 6 | 순서 | db 시작 → starting → healthy → app 시작 | |
| 7 | 실습 | `up -d --build` 로 이미지 갱신 | 실행 중 컨테이너의 `/msg.txt` = v2 |
| 8 | 객관식 | 옵션 없는 `up -d` 는 이미 있는 이미지를 다시 빌드하지 않음 | |
| 9 | 실습 | `-f` 두 개 병합 결과(`config`) | MODE prod, TZ UTC 유지 |
| 10 | 객관식 | override 에서 `ports`(목록)는 이어 붙임 | |
| 11 | 실습 | 이름 오타 난 `compose.override.yaml` 자동 적용 | `-f` 없이 LOG_LEVEL=debug |
| 12 | 실습 | `mem_limit`·`cpus`(또는 deploy.resources) | Memory 67108864, NanoCpus 500000000 |

## 수용 조건

- [x] `verify:quests --set 552` 실습 7개 전부 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종(터미널·객관식·빈칸·순서), 터미널 7/12
- [x] hint 는 방향만(정답 값·명령 전체·순서를 알려 주지 않음)
- [x] 복수 정답 없음: 10번 ports 병합은 Compose 로 직접 확인(이어 붙임)
- [x] `check-content.sh` 통과, 현장 정보 없음
