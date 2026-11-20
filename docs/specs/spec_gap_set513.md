# 명세 — 세트 513 MariaDB 문제 해결 상황집 (2): 느린 쿼리 폭주, 에러 로그, 디스크

> 상태: 작성 완료(검증 통과). 근거: `docs/research/content_gap_2026-11-19/gap_db.md` "필수 2". 형식 본보기: 세트 503.
> `linux-db` 샌드박스, 카테고리 데이터베이스, 단원 20(MariaDB 운영), display_order 734. 터미널 9 + 객관식·빈칸·순서 3.
> 선행: 502·503(락·접속 오류), 505·506(EXPLAIN·인덱스). **락·데드락은 다루지 않는다**(502·503 담당).

## 구성

보조 서버(`/tmp/lab`, 소켓 `/tmp/lab/mysql.sock`)는 에러 로그·binlog 연습용으로 setup 이 만든다.

| # | 형식 | 상황 | 고치면(확인) |
|---|---|---|---|
| 1 | 실습 | 서버가 느리다. PROCESSLIST 에서 `report` 계정 세션 Id 찾기 | `/tmp/ids.txt` 가 report 세션 목록과 일치 |
| 2 | 실습 | 폭주한 쿼리만 `KILL QUERY` (`app` 세션은 보존) | report 실행 쿼리 0, app 세션 1 |
| 3 | 실습 | `EXPLAIN` 으로 전체 훑기 확인 (`type`, `rows`) | `type=ALL`, rows ≥ 20만 |
| 4 | 실습 | `customer_id` 인덱스 추가 | `type=ref`, rows ≤ 5000, 30만 건 보존 |
| 5 | 실습 | 느린 쿼리 로그 켜기 (1초, `/tmp/slow.log`) | 변수 값 + 로그에 `SLEEP(2)` |
| 6 | 실습 | 서버가 안 뜸: `/tmp/lab/error.log` 의 `[ERROR]` 읽고 설정 오타 수정 | 접속 성공, `ready for connections`, 버퍼 풀 64M |
| 7 | 실습 | 디스크가 찬다: `du` 로 가장 큰 DB·파일 | `archive`, `events_log.ibd` |
| 8 | 실습 | binlog 5개 쌓임: `PURGE BINARY LOGS` + 보관 기간 3일 | 옛 3개 삭제(서버 목록·디스크), 최근 2개 유지, 259200초 |
| 9 | 실습 | 행 삭제 후에도 `.ibd` 가 안 줄어듦: `OPTIMIZE TABLE` | 20000건 유지, 파일 20MB 미만 |
| 10 | 객관식 | `Errcode: 28 No space left on device` 해석 | |
| 11 | 빈칸 | 느린 쿼리 로그의 `Rows_examined` | |
| 12 | 순서 | 느린 쿼리 폭주 대응 순서 | |

## 수용 조건

- [x] `verify:quests --set 513` 실습 9개 통과 (무행동 실패는 검사가 초기 상태에 없는 결과물을 본다)
- [x] `check-content.sh` 통과
- [x] 형식 4종(터미널·객관식·빈칸·순서), 현장 정보 없음
- [ ] 정확성 점검(별도 에이전트)
- [ ] 화면 확인 (사용자)
