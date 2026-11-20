# 명세 — 세트 507 계정·권한 설계 실습 (`linux-db`, 단원 20 MariaDB 운영, display_order 728)

> 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 8 (D11·M4). 선행: 세트 158·332(권한 개념 퀴즈). 생성: `scripts/content-gen/new_sets/set507.py`. 개념 퀴즈였던 계정·권한을 **직접 만들고 점검하고 회수**하는 실습으로 잇는다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `CREATE USER 'x'@'localhost'` 호스트 제한 계정 | 계정 존재, 접속 성공 |
| 2 | 실습 | 최소 권한 `GRANT SELECT,INSERT,UPDATE,DELETE ON shop.*` | 스키마 권한 4종, 조회 성공 |
| 3 | 실습 | 읽기 전용 계정, `INSERT` 거부(1142) 확인 | SELECT 만, 오류 파일, 데이터 불변 |
| 4 | 실습 | `SHOW GRANTS` 로 과한 권한 점검 | 파일에 `ALL PRIVILEGES ON *.*` |
| 5 | 실습 | `REVOKE` 후 필요한 권한만 재부여 | `*.*` 은 USAGE 뿐, shop 은 SELECT |
| 6 | 실습 | `DROP USER` 퇴사자 계정 삭제 | 계정 없음, 접속 거부, 다른 계정 유지 |
| 7 | 실습 | ROLE 생성·부여·`SET DEFAULT ROLE` | 두 사용자가 접속 즉시 조회 |
| 8 | 실습 | `ALTER USER ... IDENTIFIED BY` 비밀번호 변경 | 새 비번 성공, 옛 비번 거부 |
| 9 | 실습 | `RENAME USER` 로 `'%'` → `localhost` 호스트 제한 | 호스트·권한·비번 유지 |
| 10 | 객관식 | 호스트·권한 범위를 모두 좁힌 앱 계정 | |
| 11 | 빈칸 | `SET DEFAULT ROLE ... {FOR}` | |
| 12 | 순서 | 퇴사자 계정 정리(확인→회수→삭제→접속 확인) | |

TLS·SQL 인젝션·`bind-address` 는 필수 9 에서 다룬다(9번 해설에서만 언급).

## 수용 조건

- [x] 12문제, 형식 4종(실습 9·객관식·빈칸·순서), 새 개념 1개씩 계단식
- [x] `verify:quests --set 507` 실습 9개 전부 통과 (정답 통과, 무행동 실패)
- [x] `check-content.sh` 통과
- [x] 현장 정보 없음(`192.0.2.10`, 일반 이름만)
- [ ] 정확성 점검(별도 에이전트), 화면 확인(사용자)
