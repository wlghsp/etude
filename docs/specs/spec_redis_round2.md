# 명세 — Redis 2차 퀴즈 세트 400·401 (복제, Sentinel·Cluster)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). 데이터베이스 분야 단원 31 `Redis` 끝에 퀴즈 두 세트를 더한다. 기존 Redis 세트(자료구조·키 관리·심화·문제 해결·백업)에 없던 복제와 고가용성·확장을 다룬다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 400 | 31 Redis (568) | Redis 복제 | 비동기 복제 기본, WAIT 의 한계, replica 읽기 전용 기본, 만료는 마스터가 DEL 전달, PSYNC(복제 ID·오프셋), RDB 전체 동기화, 디스크리스 복제, min-replicas-to-write, 영속성 끈 마스터의 위험, replica 의 maxmemory 무시 |
| 401 | 31 Redis (569) | Sentinel 과 Cluster | Sentinel 포트 26379·최소 3개, quorum(감지)과 과반수(승인), down-after-milliseconds, parallel-syncs, Cluster 16384 슬롯·CRC16, 해시 태그, 버스 포트(+10000), 생성 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

redis.io 의 복제(replication), Sentinel, Cluster 확장(scaling) 문서. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(28개) 통과, 데이터베이스 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- Sentinel 문서에서 SDOWN·ODOWN 용어는 확인되지 않아 뺐다. Cluster 의 MOVED·ASK 리다이렉션 설명도 확인하지 못해 뺐다.
- 데이터베이스 분야에는 아이콘이 겹치는 기존 세트가 있다(이번 작업과 무관, 건드리지 않음).
- 순서 문제(전체 동기화는 문서 순서 그대로, Cluster 생성은 문서 안내를 이은 큰 줄기)와 실제 장애 조치 동작은 샌드박스에서 실습하지 않는다.
