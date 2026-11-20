# 명세 — 세트 524 DB 보안 기본: SQL 인젝션·접속 노출·민감 정보 점검 (`linux-db`, 단원 20 MariaDB 운영, display_order 745)

> 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 9. 선행: 세트 507(계정·권한 설계). 생성: `scripts/content-gen/new_sets/set524.py`. 507 의 계정·권한·호스트 제한은 반복하지 않고, 인젝션·노출 범위·기본 계정 점검·TLS 상태·파일 권한을 잇는다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 문자열 이어 붙이기 쿼리에 `' OR '1'='1` → 조건이 항상 참 | 회원 4명 전부 출력 |
| 2 | 실습 | `admin'-- ` 주석으로 비밀번호 검사 제거 | 결과 admin 한 행 |
| 3 | 객관식 | 인젝션의 근본 원인(입력이 문법으로 해석) | |
| 4 | 실습 | `PREPARE`/`EXECUTE ... USING` 바인딩으로 같은 입력 방어 | 일치 0행, Com_prepare_sql 증가 |
| 5 | 빈칸 | `EXECUTE s {USING} @u, @p` | |
| 6 | 실습 | `@@bind_address`·`ss -ltn` 으로 노출 점검(0.0.0.0 상태) | 파일 값 = 현재 값 = 0.0.0.0 |
| 7 | 실습 | 설정 수정 + 서버 재시작으로 127.0.0.1 | 서버 가동, 127.0.0.1 만 리슨 |
| 8 | 실습 | `mysql.user` 에서 비밀번호 없는·익명 계정 찾기 | guest·tmpuser·익명 포함, appuser 제외 |
| 9 | 실습 | 익명·guest 삭제, tmpuser 비밀번호 설정 | 위험 계정 0, 접속 확인 |
| 10 | 실습 | `have_ssl`·`require_secure_transport` 확인 | 현재 값과 일치 |
| 11 | 실습 | 덤프·평문 비밀번호 설정 파일 `chmod 600` | 두 파일 600, 메모 파일 644 유지 |
| 12 | 객관식 | 스크립트의 비밀번호는 600 설정 파일로 | |

## 사실 확인(샌드박스 MariaDB 10.6.23 에서 직접 실행)

- 기본 `bind_address=127.0.0.1`(50-server.cnf), 99-*.cnf 가 나중에 읽혀 덮어씀. `have_ssl=DISABLED`, `require_secure_transport=OFF`.
- `FLUSH GLOBAL STATUS` 는 미지원이라 4번은 시작 시 `Com_prepare_sql` 기준값을 기록해 비교.
- `mysql.user` 의 `mariadb.sys` 는 비밀번호 해시가 빈 잠긴 내부 계정(8번에서 허용·9번에서 제외).

## 수용 조건

- [x] 12문제, 형식 4종(실습 9·객관식 2·빈칸 1), 새 개념 1개씩 계단식
- [x] `verify:quests --set 524` 실습 9개 전부 통과
- [x] 현장 정보 없음(일반 이름만)
- [ ] 정확성 점검(별도 에이전트), 화면 확인(사용자)
