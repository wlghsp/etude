# 명세 — 리눅스 보강 퀴즈 세트 426·427 (sudoers, POSIX ACL)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-23). 근거: 사용자 지시("리눅스·k8s 위주로 계속 작업")와 [spec_category_completeness.md](spec_category_completeness.md)의 리눅스 공백 점검(sudoers·ACL 해당 세트 0개). 단원 4 `운영과 장애 대응` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 426 | 4 (109, 🔏) | sudoers 규칙 읽기 | user host = (runas) command, ALL 의 위험, NOPASSWD, 마지막 일치가 이김, %group, includedir 가 무시하는 파일(~ 끝·. 포함), timestamp_timeout 5분, env_reset 기본 on, 와일드카드의 / 처리, NOPASSWD·timestamp_timeout 빈칸, 규칙 추가 순서 |
| 427 | 4 (110, 🗂️) | POSIX ACL 읽기 | 여섯 항목 종류, mask 의 역할과 제외 항목(소유자·other), default ACL 상속, default 가 없을 때 mode·umask, 검사 순서, 필수 세 항목, mask 필수 조건, 그룹 비트와 mask 의 대응, mask·ls -l + 빈칸, 권한 검사 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

sudo.ws 의 sudoers 매뉴얼(앞 약 100KB), man7.org 의 acl(5). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(54개) 통과, 리눅스 분야 display_order 중복 없음, 새 세트 아이콘이 유일 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- sudoers 문서는 뒤 약 83KB 를 읽지 못해 Defaults 목록의 뒷부분은 다루지 않았다. visudo 의 문법 검사·잠금은 읽은 범위의 원문에 없어 순서 문제에 일반 절차로만 넣었다. regex 지원(1.9.10)·넷그룹·`sudo -l -U` 는 문제로 만들지 않았다.
- acl(5) 에는 getfacl·setfacl 의 사용법이 없어 명령 문제는 만들지 않았다. "확장 ACL"의 정의도 원문에 없다. 필수 3항목은 원문이 "최소 3개"라고 쓰지 않고 유효성 조건으로 서술한 것을 따랐다.
- 리눅스 샌드박스에서 실제 sudoers·ACL 동작을 확인하지 않아 퀴즈로만 다룬다. 실습 세트 후보(`setfacl`, `visudo -c`)는 별도 검토 대상이다.
