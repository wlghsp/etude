# 명세 — 리눅스 보강 퀴즈 세트 430·431 (systemd 서비스·타이머 유닛)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-25). [spec_linux_round_b.md](spec_linux_round_b.md)에 이어 [spec_category_completeness.md](spec_category_completeness.md)의 리눅스 공백(systemd 5개 세트뿐)을 퀴즈로 보강한다. 단원 4 `운영과 장애 대응` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 430 | 4 (113, 🛎️) | systemd 서비스 유닛 읽기 | Type 생략 시 기본(simple·dbus·oneshot), Restart 기본 no, RestartSec 100ms, ExecStart 는 oneshot 외 하나, ExecStartPre 여러 줄, oneshot 의 타임아웃 비활성, RemainAfterExit 기본 no, - 접두사, always·- 빈칸, 서비스 유닛 쓰는 순서 |
| 431 | 4 (114, ⏲️) | systemd 타이머 유닛 읽기 | 같은 이름의 서비스 활성화와 Unit=, OnCalendar(실시간), OnBootSec·OnUnitActiveSec 기준점, Persistent(OnCalendar 에만, 기본 false), AccuracySec 1min, RandomizedDelaySec, WakeSystem false, RemainAfterElapse true, OnCalendar·Persistent 빈칸, 타이머로 주기 실행 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

man7.org 의 systemd.service(5), systemd.timer(5). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(58개) 통과, 리눅스 분야 display_order 중복 없음, 새 세트 아이콘이 유일 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- systemd.service 문서는 뒤 약 4KB 를 읽지 못했다. User·WorkingDirectory·Environment·KillMode 의 기본값은 이 페이지가 아니라 systemd.exec(5)·systemd.kill(5)에 있어 다루지 않았다. Type 값 중 notify-reload 도 문제로 만들지 않았다.
- systemd.timer 문서에는 enable·start 절차와 `systemctl list-timers` 가 없어 빼고, 순서 문제는 문서가 정의한 동작(서비스·타이머 유닛·일정·활성화)만 이었다. OnCalendar 의 달력 표현식 문법은 별도 문서(systemd.time(7))라 다루지 않았다.
- 서비스 유닛 쓰기 순서(Type → ExecStart → Restart → 확인)는 문서가 직접 적지 않은 일반 절차다. 샌드박스(linux-systemd)에서 실제 유닛을 만들어 보지 않아 퀴즈로만 다룬다. 실습 후보는 별도 검토 대상이다.
