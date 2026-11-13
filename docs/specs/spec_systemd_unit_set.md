# 명세 — systemd 서비스 직접 만들기 (세트 382)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). 세트 24(`리눅스 패키지와 systemd 로그`)가 유닛 만들기·enable·실패 서비스 찾기·로그 보기를 다룬 뒤, **유닛 파일을 쓰고 고치는 기술**을 한 단계 더 깊게 다룬다.

## 구성

- 샌드박스 `linux-systemd`(Rocky 9, 실제 systemd), 분야 리눅스, 단원 4 `리눅스 현장 운영` 끝.
- 12문제: 실습 9 + 객관식 1 + 빈칸 1 + 순서 1. 문제마다 **배경** 설명 포함.

| # | 주제 | 확인하는 것 |
|---|---|---|
| 1 | `Restart=on-failure`·`RestartSec` | 설정값 + 프로세스를 `kill -9` 하면 새 PID 로 다시 뜸 |
| 2 | `EnvironmentFile=` | 파일의 값이 서비스에 전달됨 |
| 3 | 드롭인 `.service.d/override.conf` | 원본은 그대로, 덮어쓴 값이 반영됨 |
| 4 | `systemctl cat` | 원본과 드롭인이 함께 출력됨 |
| 5 | `Type=oneshot` | 한 번 실행하고 inactive 로 돌아옴 |
| 6 | `.timer` + `enable --now` | enabled·active·매일 00:00 달력 조건 |
| 7 | `list-timers` | 타이머와 시작할 서비스가 목록에 있음 |
| 8 | `Requires=` + `After=` | 의존과 순서를 모두 적음 |
| 9 | `mask` | masked 이고 시작이 거부됨 |
| 10 | (객관식) `Restart=on-failure` 에서 `stop` | systemd 작업으로 멈춘 것은 다시 띄우지 않음 |
| 11 | (빈칸) `systemctl daemon-reload` | |
| 12 | (순서) 파일 쓰기 → daemon-reload → enable --now → status | |

근거: freedesktop.org systemd 매뉴얼(service·unit·timer·systemctl·exec). `Restart=` 기본값 `no`, 시스템 작업으로 죽은 경우 재시작 안 함은 원문에서 확인.

## 수용 조건

- [x] `verify:quests --set 382` 실습 9/9 통과 — `검증됨`
- [x] `check-content.sh`, `check-migrations.sh` 통과 — `검증됨`
- [x] 풀지 않으면 각 검사가 실패 — `코드상 확인됨` (검사가 풀이 결과물(설정값·파일·상태)을 직접 보고, 초기 상태에는 없음. 실행으로 확인하지는 않음: 검사 도구가 systemd 없이 돌기 때문)
- [ ] 화면 확인 (`미검증`)

## 알려진 사실

- `OnCalendar=daily` 는 `systemctl show` 에서 `*-*-* 00:00:00` 으로 정규화되어 보인다(6번 검사가 이 형태를 본다).
- `mask` 는 /etc 에 같은 이름의 일반 파일이 있으면 실패하므로 9번은 유닛을 `/usr/lib/systemd/system` 에 둔다.
