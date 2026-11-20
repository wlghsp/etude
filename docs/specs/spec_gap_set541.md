# 세트 541 명세: 부팅 과정과 복구 기본 (부팅 순서·target·로그)

- 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N11. 생성: `scripts/content-gen/new_sets/set541.py`
- 샌드박스 linux-systemd (Rocky 9 컨테이너, 실제 부팅 아님). category 리눅스, unit 59, display_order 762, 12문제(실습 7).
- 선행: 세트 24·382(systemd 기본). 후속: N15 상황집, N21, N28.
- 컨테이너에서 직접 확인한 동작: `get-default` 기본값 graphical, `set-default` 로 `/etc/systemd/system/default.target` 링크 변경, `list-units --type=target`, `list-dependencies`, `journalctl -b/-k/-p`, `/proc/cmdline` 모두 동작. GRUB 설정 도구(`grubby`, `grub2-mkconfig`)와 `/boot/grub2` 는 없음, `dmesg`·`/proc/cmdline` 은 호스트 커널 값.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 순서 | 펌웨어 → GRUB → 커널 → systemd → target | 순서 고정 |
| 2 | 객관식 | multi-user vs graphical | |
| 3 | 실습 | `systemctl get-default` 저장 | 현재 값과 일치 |
| 4 | 실습 | `set-default multi-user.target` | get-default·링크 |
| 5 | 실습 | `list-units --type=target` | multi-user·basic 포함, service 없음 |
| 6 | 실습 | `list-dependencies graphical.target` | 첫 줄·multi-user 포함 |
| 7 | 객관식 | rescue vs emergency | |
| 8 | 빈칸 | isolate(즉시) vs set-default(다음 부팅) | |
| 9 | 실습 | `journalctl -b -p err` | err 줄 포함·info 줄 제외 |
| 10 | 실습 | `journalctl -k` | kernel 줄 포함·서비스 로그 제외 |
| 11 | 실습 | `/proc/cmdline` (GRUB 파라미터는 읽기형) | 현재 값과 일치 |
| 12 | 객관식 | 부팅 실패 시 어디부터 (journalctl, fstab) | |

## 수용 조건

- [x] 12문제, 형식 4종(실습·객관식·빈칸·순서)
- [x] 실습 7개 모두 아무것도 안 하면 실패(검사가 초기에 없는 파일·상태를 봄), `verify:quests` 7/7 통과
- [x] 힌트는 방향만, 현장 정보 없음
- [x] 컨테이너에서 불가능한 것(실제 재부팅·rescue 진입·GRUB 편집·`isolate`)은 객관식·빈칸·읽기형으로 대체
