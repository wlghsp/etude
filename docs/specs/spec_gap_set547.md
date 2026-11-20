# 명세 — 세트 547 systemd 한 걸음 더: 로그 조합·실패 유닛·부팅 시간·일회성 실행

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N21. `linux-systemd` 샌드박스, 리눅스, 단원 58, display_order 806. 선행: 세트 382(systemd 서비스 만들기·timer), 515(서비스 기동 실패 상황집). 세트 541(부팅·target)의 `-b -p err`·`-k`·`list-dependencies graphical.target` 과는 겹치지 않게 `-t`·`-p 범위`·`--since`·`--reverse`·`--failed`·blame·systemd-run 에 집중.
> 환경 확인(직접 실행): `rockylinux/rockylinux:9-ubi-init` 에서 journalctl·systemd-analyze blame/critical-chain·systemd-run(`--unit`, `--on-active`)·list-units --failed·reset-failed·list-dependencies --reverse 모두 동작. 영구 저널이 없어 `-b -1` 은 동작하지 않으므로 실습 대신 해설로만 언급.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `-t` 와 `-p warning..err` 범위 | warning·err 만, crit·notice·info 제외 |
| 2 | 실습 | `--since "시각"` 로 신고 시각 이후만 | new-event 만, old-event 제외 |
| 3 | 객관식 | `--since yesterday --until today` 구간 | |
| 4 | 실습 | `list-units --failed --plain --no-legend` 이름 뽑기 | 실패 유닛 2개 정확 |
| 5 | 실습 | `reset-failed 유닛` 으로 하나만 정리 | fa 정리, fb 유지 |
| 6 | 실습 | `list-dependencies --reverse` | app547 이 나옴 |
| 7 | 객관식 | `Requires=` 의 stop 전파 | |
| 8 | 실습 | `systemd-analyze blame` 상위 3줄 | 3줄, slow547 포함 |
| 9 | 객관식 | blame 과 critical-chain 의 차이 | |
| 10 | 실습 | `systemd-run --unit --collect` 일회성 실행과 저널 | 저널·파일에 출력, 유닛 파일 없음 |
| 11 | 실습 | `systemd-run --on-active` 예약 | timer 대기 중, 아직 미실행 |
| 12 | 빈칸 | `journalctl -r` | |

## 수용 조건

- [ ] `verify:quests --set 547` 실습 8개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 형식 3종(실습·객관식·빈칸), 현장 정보 없음
- [ ] 힌트가 정답 전체를 알려 주지 않고, 객관식·빈칸의 정답이 하나
