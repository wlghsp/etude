# 명세 — 리눅스 사용자와 그룹 세트 (id · /etc/passwd · useradd · usermod -aG · chown · chmod g+w · su -c)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 232. 근거: 기존에는 세트 21·65·135·207 이 `id`·`useradd`·`usermod -aG`·`chown`·`chmod` 를 객관식·빈칸·한 줄 실습으로 따로따로 묻는다. "누구인가 → 계정 정보는 어디에 있나 → 만들고 그룹에 넣고 → 파일 권한을 맞추고 → 그 사람 권한으로 확인하고 → 정리한다"를 **살아 있는 계정과 파일 상태로 이어서 확인하는 한 줄기**는 없다.

## 목표

계정·그룹·파일 소유권을 직접 만지며 손버릇으로 만든다. `id` 로 신원을 보고, `/etc/passwd` 의 칸을 `cut`·`awk -F:` 로 읽고, `useradd -m -s` 로 계정을 만들고, `usermod -aG` 로 그룹에 더하고, `chown 사용자:그룹`·`chmod g+w` 로 파일 권한을 맞추고, `su - 사용자 -c` 로 그 사용자 권한으로 실행하고, `userdel -r` 로 정리한다. 쉬운 것부터 차례로 12문제.

## 원칙

- 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1 (형식을 섞는 규칙).
- setup 은 계정 `kim`(홈 `/home/kim`), `lee`(홈 `/data/lee`), `guest`(홈 `/home/guest`, 파일 `note.txt`)와 그룹 `devs`(kim·lee), `audit`(lee)를 만들고, `/tmp/lab/report.txt`(root 소유), `/tmp/lab/team.txt`(kim:devs, 644)를 둔다. 셋 모두 로그인 셸은 `/bin/bash`.
- **재실행해도 안전하다.** setup 첫머리에서 `userdel -r`, `groupdel`, `rm -rf` 로 자신이 만드는 계정·그룹·파일을 먼저 지운다 (`park` 도 포함, 문제 4 에서 풀이로 만들어지므로).
- 채점은 살아 있는 상태와 **내용**을 본다: 계정 존재·셸·홈, `id -nG` 의 그룹 목록, `stat -c %U:%G` 의 소유자, 파일 내용, 실제 쓰기 가능 여부(`runuser -u lee -- test -w`). 고정 UID 숫자를 쓰지 않는다 (`id kim` 의 현재 출력과 비교).
- 함정을 채점에 넣는다: 5번은 `-G` 만 쓰면 `devs` 가 빠지는 것(`-a` 누락)을, 8번은 `chmod 666` 으로 others 까지 여는 것을, 10번은 `>` 를 따옴표 밖에 두면 파일 소유자가 root 가 되는 것을 걸러 낸다.
- 새 개념은 한 문제에 하나만. 객관식은 기존 세트에 없는 `su` 와 `su -` 의 차이. 빈칸은 `passwd -l` (칩 `-l -u -S -e`, 잠그는 옵션은 `-l` 하나뿐).
- 샌드박스는 `linux` (이미지 `etude-linux`, Ubuntu 22.04, systemd 없음, root). 이미지에 `useradd userdel usermod groupadd groupdel gpasswd passwd chage runuser su getent id groups newgrp awk` 는 있고 `sudo` 는 없으므로 쓰지 않는다.

## 세트 구성 (12개, 세트 232)

| # | 형식 | 제목 | 새로 익히는 것 | 채점 |
|---|------|------|----------------|------|
| 1 | 터미널 | 사용자 kim 의 신원 확인하기 (id) | `id 이름` | 파일 == `id kim` 출력, UID 포함 |
| 2 | 터미널 | /etc/passwd 에서 홈 디렉터리 필드 뽑기 | `grep ^이름: \| cut -d: -f6` | 파일 == lee 의 실제 홈(`/data/lee`), 한 줄 |
| 3 | 터미널 | bash 를 쓰는 계정 이름만 모으기 (awk -F:) | `awk -F: '$7=="..."{print $1}'` | 정렬한 목록이 정답과 일치, kim·lee 포함, nologin 제외 |
| 4 | 터미널 | 새 계정 만들기 (useradd -m -s) | `useradd -m -s /bin/bash` | park 존재, 셸 `/bin/bash`, 홈 존재·park 소유 |
| 5 | 터미널 | 기존 그룹에 사용자 더하기 (usermod -aG) | `usermod -aG` (`-a` 없으면 교체) | kim 이 audit·devs 모두 소속, 기본 그룹 kim |
| 6 | 빈칸 | 계정 잠그기 | `passwd -l` (칩 `-l -u -S -e`) | 칸 1개 |
| 7 | 터미널 | 파일 소유자와 그룹 한 번에 바꾸기 (chown 사용자:그룹) | `chown kim:devs` | `kim:devs`, 내용 유지 |
| 8 | 터미널 | 그룹 쓰기 권한 열어 주기 (chmod g+w) | `chmod g+w` | lee 쓰기 가능, 모드 `-rw-rw-r--`, 소유자·그룹 유지 |
| 9 | 객관식 | su 와 su - 의 차이 | 로그인 환경 vs 현재 환경 | 정답: 로그인 환경으로 들어가는 쪽이 `su -` |
| 10 | 터미널 | kim 의 권한으로 명령 실행하기 (su - 사용자 -c) | `su - kim -c '... > 파일'` | 내용 `kim`, 소유자 kim |
| 11 | 터미널 | 계정과 홈 디렉터리 함께 지우기 (userdel -r) | `userdel -r` | guest 계정·홈 없음, kim·lee 유지 |
| 12 | 순서 | 새 팀원이 공유 폴더를 쓰게 만드는 순서 | groupadd → useradd -G → mkdir → chown·chmod → 계정으로 확인 | 5조각 |

- 객관식 정답은 보기 목록의 첫 번째로 적고, 도우미가 섞는다. 해설은 보기와 모순되지 않게 쓴다.
- 빈칸·순서·객관식은 터미널이 필요 없어 터미널 창이 보이지 않는다.
- 12번은 마지막 확인을 root 로 하면 권한과 무관하게 성공한다는 점을 해설에 적는다.

## 배치

단원·display_order 는 통합 시 정한다. 세트 종류: `sandbox_type = linux`, 분야 `리눅스`, `time_limit_sec` 없음.
구현: `scratchpad/gen232.py` 생성기로 `backend/db/03_quest_set232.sql`, 마이그레이션(`2026-11-11_linux_users_groups_set232.sql`), `backend/verify/set232.json`, `02_quest_set.sql` 끝 행을 만든다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (새 컨테이너에서 setup 후, 별도 exec 로).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다 (거짓 통과 없음).
- [x] setup 을 연달아 두 번 실행해도 오류 없이 같은 상태가 된다.
- [x] 5번은 `usermod -G audit` (`-a` 없음)로는 실패하고, 8번은 `chmod 666` 으로는 실패하며, 10번은 `>` 를 따옴표 밖에 두면 실패한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다.
- [x] 빈칸의 칩에 정답이 둘 이상 되는 값이 없다 (`-l` 만 정답).
- [x] 각 문제의 `checks` 가 상태의 **내용**을 확인한다. 고정 UID 를 쓰지 않는다.
- [x] 각 문제 `docs` 에 passwd·group·useradd·usermod 매뉴얼 링크가 달려 있다.
- [x] 내용에 IP·도메인·회사·내부 시스템 이름이 없다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 홈 리눅스 탭에 보이고, 1번부터 12번까지 순서대로 풀린다 (수동 확인).
