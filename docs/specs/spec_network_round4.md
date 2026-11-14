# 명세 — 네트워크 4차 퀴즈 세트 408·409 (ip route, 정책 라우팅)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). [spec_network_round3.md](spec_network_round3.md)에 이어 단원 47 `네트워크 기초` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 408 | 47 (631, 🗺️) | ip route 깊게 | 타입 생략 시 unicast, unreachable·blackhole·prohibit·throw 의 처리와 오류, metric(낮을수록 우선), scope 기본값, proto 생략 시 boot, default·onlink, ip route get(조회만), 추가·확인·조회 순서 |
| 409 | 47 (632, 🚦) | 정책 라우팅 | RPDB, priority 낮은 순 처리, 기본 규칙 0·32766·32767 과 테이블 255·254·253, fwmark·iif lo·oif 선택자, prohibit 동작, priority·to 빈칸, 출발지별 테이블 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 뒤 세트 1개(117)의 display_order 는 밀렸다.

## 근거 문서

man7.org 의 ip-route(8), ip-rule(8). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(36개) 통과, 네트워크 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- man 페이지가 2012-12 판 iproute2 기준이라 라우팅 캐시 같은 옛 내용은 뺐다. scope 의 host·link·global 정의는 원문에 없어 기본값만 다뤘다.
- ip-rule 문서에는 완성된 명령 예시가 없어, 빈칸 문제는 문법(synopsis)에 맞춰 구성했다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 샌드박스에서 실제 경로·규칙을 만들지 않아 퀴즈로만 다룬다.
