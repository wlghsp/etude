# 명세 — 세트 554 로그·이벤트·자원 보기로 운영하기

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 의 '로그·이벤트·자원 보기' 행. 샌드박스 `docker`(dind), 카테고리 `도커`, 단원 66, display_order 814. 선행: 세트 183/247(로그 로테이션·events·system df 개념), 231(logs·stats·RestartCount 읽기), 478(events die). 생성: `scripts/content-gen/new_sets/set554.py`.

겹침 방지: 기존 세트는 `max-size` 빈칸·로테이션 개념 퀴즈, `stats` 메모리 한 번 읽기, `RestartCount` 읽기, `events` die 저장을 다뤘다. 여기서는 드라이버 확인(엔진 기본 vs 컨테이너별), `--log-opt` 를 직접 적용·효과 확인, 정책 재시작이 events 에 남는 모양, `docker update --restart`, CPU·쓰기 레이어로 범인 찾기를 다룬다. 샌드박스에서 데몬 설정은 못 바꾸므로 컨테이너 단위 `--log-opt` 만 쓴다. 이 환경에서 정책 재시작은 `restart` 사건이 아니라 `die`→`start` 로 남는 것을 확인했다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `docker info` / `inspect` 로 로그 드라이버 확인 | 엔진 기본·logd 드라이버를 한 줄로 저장 |
| 2 | 실습 | `--log-opt max-size/max-file` 적용 | capped 컨테이너의 LogConfig |
| 3 | 실습 | 로테이션 효과(오래된 줄 소실) | 저장한 첫 줄이 logs 첫 줄과 같고 line-0 아님 |
| 4 | 실습 | `events` 필터로 재시작 추적(die 종료 코드) | die 횟수 = RestartCount + 1 |
| 5 | 실습 | `docker update --restart` | 정책 변경, 같은 컨테이너 |
| 6 | 실습 | `stats --no-stream --format` 로 CPU 범인 | 이름 저장 |
| 7 | 실습 | `ps -s` 로 쓰기 레이어 큰 컨테이너 | 이름 저장 |
| 8 | 객관식 | max-size × max-file 상한 | |
| 9 | 빈칸 | `docker stats --no-stream` | |
| 10 | 순서 | 재시작 반복 추적 순서(상태→횟수→시점→원인) | |

## 수용 조건

- [ ] `verify:quests --set 554` 실습 7개 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종, 터미널 7/10
- [ ] hint 는 방향만, 복수 정답 없음
- [ ] `check-content.sh` 통과, 현장 정보 없음
