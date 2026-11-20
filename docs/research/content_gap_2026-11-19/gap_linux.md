# 리눅스 분야 콘텐츠 빈틈 분석

분석 기준일 2026-11-19. 대상: `quest_set.category='리눅스'` 114개 세트 / 13개 단원(`audit/merged.json`). DB·저장소는 읽기만 했다.
검증 방법: 세트 제목·형식 집계, 단원별 `new_concepts`, 그리고 리눅스 전 문제(제목·본문·해설·정답·선택지)에 대한 키워드 포함 검색. 키워드가 `0`인 항목은 "문제 본문에 한 번도 나오지 않음"이다.

## 요약

- **현재 수준**: 쉘·파일·권한·텍스트 처리·스크립트·네트워크 점검·systemd 기본은 폭도 깊이도 충분하다(오히려 과밀). 그러나 **시스템 관리 영역(스토리지, 패키지, 보안, 부팅)이 사실상 비어 있어** 지금 상태로 "리눅스 코스 공개"는 곤란하다.
- **가장 큰 빈틈 3개**
  1. **스토리지**: 파티션·파일시스템 생성·mount·fstab·LVM·swap·loop. `lvm`, `fdisk`, `mkfs`, `parted`, `blkid`, `mkswap`, `losetup`, `mount -o`, `resize2fs`, `xfs_growfs` 전부 검색 결과 0건. mount/fstab 은 NFS(27·75)와 한 줄 퀴즈(135·263)에서 스치는 정도.
  2. **보안 기본**: SELinux(`selinux`·`getenforce`·`restorecon` 0건), 방화벽 `firewall-cmd`·`iptables`·`nft` 0건(ufw 가 퀴즈 1개 세트에서 한 줄), `sshd_config`·`/etc/sudoers` 편집, `chage`·PAM 0건. sudo 는 읽기형 퀴즈(426)뿐, ACL 도 읽기형(427)뿐이다.
  3. **패키지 관리 + 부팅·커널**: 패키지는 rpm 조회(24)와 apt 한 줄 퀴즈(263)만 있고 `dnf/yum install·remove·repo`, `dpkg` 실습이 없다(yum 0, dpkg 0). 부팅(GRUB, target 전환, rescue, 커널 로그 `dmesg`, `systemd-analyze`)은 0건 또는 1건.
- **구조 문제**: 114개 중 70개(61%)가 퀴즈이고 그중 약 60개가 "한 줄씩 (1/2)(2/2)" 복습형. 터미널 문제는 전체 1,534문항 중 379개(약 25%). 선행 개념을 가르치지 않고 복습만 있는 세트가 많아(audit `prereq_gap`) 신규 세트는 "가르치는 터미널 실습"이어야 한다.
- 상황집은 SSH(124)·진단(16)·원리(32)가 있으나 **"서비스가 안 뜬다 / 디스크가 꽉 찼다·읽기 전용이 됐다 / 마운트가 안 된다 / 패키지가 안 깔린다 / OOM"** 계열이 없다.

## 참고 커리큘럼

LPIC-1(101/102)과 RHCSA(EX200)의 공통 범위를 사내 인프라 운영자 관점으로 재구성했다. 활용도가 낮은 것(레거시 init, X11, 프린터(CUPS), 메일 서버 설정, 로컬라이제이션 세부, 하드웨어 설정 ISA/PCI 세부)은 제외했다. 컨테이너·k8s·가상화는 각자의 분야가 있으므로 제외한다.

| # | 영역 | 핵심 주제 |
|---|------|----------|
| D1 | 쉘과 파일 시스템 탐색 | pwd/cd/ls, 경로(절대·상대), FHS(`/etc /var /usr /home /tmp /proc`), man·--help·which·type, 도움말 읽기 |
| D2 | 파일·디렉터리 조작 | cp/mv/rm/mkdir, 링크(하드·심볼릭), inode, find, locate, 압축·아카이브(tar/gzip/zip), 파일 비교, vim/nano |
| D3 | 텍스트 처리 | cat/head/tail/less, grep(정규식 BRE/ERE), sed, awk, sort/uniq/cut/paste/join/tr/wc, tee, diff |
| D4 | 입출력 연결과 쉘 확장 | 리다이렉션, 파이프, 파일 디스크립터, 와일드카드·인용·치환, 환경 변수·PATH, 쉘 설정 파일(`.bashrc`/profile), alias, history |
| D5 | 권한과 접근 제어 | rwx·숫자, chmod/chown/chgrp, umask, setuid/setgid/sticky, ACL(getfacl/setfacl), chattr, sudo·sudoers |
| D6 | 사용자·그룹·인증 | `/etc/passwd·shadow·group`, useradd/usermod/userdel/groupadd, passwd·chage(만료 정책), su/sudo, 로그인 이력(last/who/lastlog), PAM 개념 |
| D7 | 프로세스와 작업 제어 | ps/top/pgrep, 시그널·kill, 포그라운드/백그라운드/nohup/tmux, nice/renice, 종료 코드, 좀비·고아, /proc, cgroup 개념 |
| D8 | 패키지 관리 | rpm/dnf(yum), dpkg/apt, 저장소 설정, 설치·제거·업데이트·검색, 패키지↔파일 매핑, 서명/GPG, 의존성 문제 해결 |
| D9 | systemd | 유닛 종류, systemctl(start/stop/enable/mask), 유닛 파일 작성·drop-in, target, timer, journalctl, systemd-analyze |
| D10 | 부팅과 커널 | 부팅 과정(BIOS/UEFI→GRUB→커널→init), GRUB 설정, default target·rescue/emergency, 커널 로그(dmesg), 모듈(lsmod/modprobe), sysctl, uname/버전 |
| D11 | 스토리지 | lsblk/blkid, 파티션(fdisk/parted, MBR/GPT), mkfs(ext4/xfs), mount/umount/fstab(UUID·옵션), swap, LVM(PV/VG/LV·확장), loop 장치, fsck/xfs_repair, df/du, RAID·quota 개념, NFS 클라이언트 |
| D12 | 네트워크 설정과 진단 | ip a/route/link, 호스트명, NetworkManager(nmcli)/netplan, `/etc/hosts·resolv.conf·nsswitch`, DNS(dig), ss/nc/curl/ping/traceroute/tcpdump, 정적 IP·게이트웨이·DNS 설정 |
| D13 | 방화벽과 보안 기본 | firewalld(firewall-cmd)/iptables·nft/ufw 개념과 기본 규칙, SELinux(모드·컨텍스트·boolean·restorecon·audit 로그 읽기), SSH 강화(키 인증, sshd_config, 루트 로그인 금지), 파일 무결성(체크섬/gpg), 최소 권한 |
| D14 | 로그·시간·스케줄 | `/var/log`, rsyslog 개념, journald, logrotate, cron/at/anacron, systemd timer, chrony/timedatectl, hostnamectl |
| D15 | 성능 진단 | top/htop, free, vmstat, iostat/sar, load average 해석, lsof, strace, ulimit, OOM killer, 디스크 I/O·inode·메모리·CPU 병목 판별 |
| D16 | 쉘 스크립트 | shebang, 변수·인용, 조건·반복·case·함수, 인자·getopts, 종료 코드·set -e, trap, 배열, 디버깅(`bash -x`), here-doc, 실무 스크립트(백업·점검) |
| D17 | 원격 접속과 전송 | ssh(옵션·포트포워딩 개념), 키 인증·agent·config, scp/rsync, tmux/screen, 호스트 키 관리 |
| D18 | 장애 대응(상황집) | 오류 메시지→원인→해결 형식: 서비스 기동 실패, 디스크 가득/읽기 전용, 마운트 실패, 권한·SELinux 거부, 패키지 의존성, 부팅 실패, 네트워크 단절, OOM |

## 커버리지 표

깊이: 없음 / 얕음 / 보통 / 충분. 형식: Q = 개념·한 줄 퀴즈만, T = 터미널 실습 포함.
세트 id 는 DB id. 반복 복습 퀴즈는 "(복습 퀴즈: …)"로 묶어 적었다.

### D1 쉘과 파일 시스템 탐색 — 충분
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| pwd/cd/ls/mkdir/touch/cp/mv, 상대경로 | 1, 2 | 충분 | T |
| 리눅스 기초 개념, 명령어 해부 | 42, 45, 47 | 충분 | Q+T(47 만 T) |
| man·--help 읽기 | 47 | 보통 | T |
| FHS 디렉터리 구조·역할 | 85(파일시스템 계층 일부), 42 | 얕음 | Q |
| 파일 한 줄씩 복습 | 127, 259, 193, 277 | 충분 | Q |

### D2 파일·디렉터리 조작 — 충분
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| rm·find·du | 2, 44, 347, 216·284 | 충분 | T/Q |
| 링크·inode·diff | 370, 193, 144 | 충분 | T/Q |
| tar·gzip·zip·체크섬 | 7, 338, 181·274 | 충분 | T/Q |
| vim | 9 | 보통(nano 없음, 영향 낮음) | T |
| locate/updatedb | 없음(0건) | 없음 | - |

### D3 텍스트 처리 — 충분(과밀)
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| grep·정규식 | 48, 185·275, 480 | 충분 | T/Q |
| sed·awk | 177·273, 344, 341, 15 | 충분 | T/Q |
| sort/uniq/cut/paste/join/tr/wc | 49, 189·276, 344, 480 | 충분 | T/Q |
| 로그 분석 파이프라인 | 15, 341 | 충분 | T |

### D4 입출력 연결·쉘 확장·환경 — 충분
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| 리다이렉션·파이프 | 43, 34, 150·266 | 충분 | Q/T |
| 와일드카드·인용·치환 | 50, 21, 150·266 | 충분 | T/Q |
| 환경 변수·PATH·`.bashrc`·alias | 350, 21, 204·280 | 충분 | T/Q |
| 로그인 쉘 vs 비로그인 쉘(profile 로딩 순서) | 없음 | 얕음(350 일부 추정) | - |

### D5 권한과 접근 제어 — 보통
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| rwx·chmod·chown·umask | 65, 2, 10, 16, 173·272 | 충분 | T/Q |
| setuid/setgid/sticky | 173·272 | 얕음(퀴즈만) | Q |
| ACL | 427 | 얕음(읽기형 퀴즈만, getfacl/setfacl 0건) | Q |
| sudo·sudoers | 426 | 얕음(읽기형 퀴즈만, 실제 설정 없음) | Q |
| chattr/lsattr | 없음 | 없음 | - |

### D6 사용자·그룹·인증 — 보통
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| useradd/usermod -aG/userdel, id, su | 232, 21, 207·281, 135·263 | 보통 | T/Q |
| `/etc/passwd` 읽기 | 232 | 보통 | T |
| `/etc/shadow`·chage·비밀번호 정책 | 135(shadow 1건) | 없음(chage 0건) | - |
| 로그인 이력(last/lastlog/who) | 135·263(who), 426(last 1건) | 얕음 | Q |
| PAM·ssh 로그인 제한 | 없음(pam 0건) | 없음 | - |

### D7 프로세스와 작업 제어 — 충분
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| ps/pgrep/kill/pkill | 3, 229, 162·269 | 충분 | T/Q |
| 백그라운드·nohup·jobs | 3, 204·280, 152·267, 173·272 | 충분 | T/Q |
| nice/renice | 173·272 | 얕음(퀴즈) | Q |
| fork·exec·/proc·좀비 | 85, 32, 162 | 보통 | Q+T 일부 |
| tmux/screen | 없음 | 없음 | - |
| cgroup 개념 | 없음 | 없음(k8s/도커 분야에서 다룰 가능성, 추정) | - |

### D8 패키지 관리 — 얕음
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| rpm -q/-qf/-qi/-V | 24(q1~6) | 보통 | T |
| apt update/upgrade/install/search | 135·263(q7~13) | 얕음 | Q |
| dnf/yum 설치·제거·업데이트·history | 263(dnf 1건), yum 0 | 없음 | - |
| 저장소(repo) 파일·GPG 서명 | 없음 | 없음 | - |
| dpkg -l/-i/-S/-L | 없음(0건) | 없음 | - |
| 의존성 오류 해결·잠금(lock) | 없음 | 없음 | - |

### D9 systemd — 보통~충분
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| systemctl status/start/enable | 10, 24, 28, 133·262 | 충분 | T/Q |
| 유닛 파일 작성·drop-in·timer·mask | 24(q10), 382, 430, 431 | 충분 | T/Q |
| journalctl(-u, -p, --since) | 24, 123, 124, 144·264 | 보통 | T/Q |
| `journalctl -f`/-b/-k, 보존 설정 | 없음(-f 0건) | 얕음 | - |
| target(default.target 변경, isolate) | 431(default.target 1건만) | 없음 | - |
| systemd-analyze, systemd-run | 없음(0건) | 없음 | - |

### D10 부팅과 커널 — 없음~얕음
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| 부팅 과정 개념(GRUB→커널→init) | 없음(grub 0건) | 없음 | - |
| rescue/emergency 모드, 루트 비밀번호 복구 | 없음 | 없음 | - |
| dmesg·커널 로그 읽기 | 144·264 | 얕음 | Q |
| sysctl·modprobe | 432, 433 | 보통(읽기형 퀴즈, 직접 실습 없음) | Q |
| lsmod·uname·os-release | 146·265, 433 | 얕음 | Q |
| 커널 업데이트·initramfs | 없음 | 없음 | - |

### D11 스토리지 — 없음 (최대 빈틈)
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| df/du/inode 점검 | 226, 27, 129·260, 144 | 충분 | T/Q |
| lsblk | 135(1건) | 얕음 | Q |
| 파티션 만들기(fdisk/parted), MBR/GPT | 없음(0건) | 없음 | - |
| mkfs(ext4/xfs), blkid, UUID | 없음(0건) | 없음 | - |
| mount/umount, `mount -o`, `/etc/fstab` 항목 읽기·쓰기 | 27(NFS fstab), 75(NFS 언마운트), 135·263(마운트 한 줄) | 얕음 | T(NFS 한정)/Q |
| swap(mkswap/swapon, 스왑 사용량) | 27·162(free 의 swap 읽기만) | 없음 | - |
| LVM(pv/vg/lv, lvextend, resize) | 없음(0건) | 없음 | - |
| loop 장치·tmpfs·bind mount | 없음(0건) | 없음 | - |
| fsck·xfs_repair | 27, 263(fsck 한 줄) | 얕음 | Q |
| RAID(mdadm)·quota 개념 | 없음 | 없음(선택) | - |
| NFS 클라이언트·exports | 27, 75, 28 | 보통 | T |

### D12 네트워크 설정과 진단 — 충분(설정 쪽만 얕음)
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| ip a/route, ss, nc, curl, ping | 235, 18, 4, 131·261, 156·268 | 충분 | T/Q |
| hosts·resolv.conf·nsswitch·DNS | 36, 81, 106, 235 | 충분 | T/Q |
| tcpdump | 429 | 얕음(필터 읽기 퀴즈) | Q |
| 호스트명 변경(hostnamectl) | 없음(0건) | 없음 | - |
| 영구 네트워크 설정(nmcli/netplan, 정적 IP·게이트웨이) | 없음(0건) | 없음 | - |
| traceroute/mtr | 261 | 얕음 | Q |
| ip neigh/arp, ethtool, bond/vlan | 없음 | 없음 | 선택 |
| ipv6 | 없음 | 없음 | 선택 |

### D13 방화벽·보안 기본 — 없음
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| 방화벽 개념·firewalld/iptables | 146·265(ufw·방화벽 한 줄), 32·36·81·156(원인으로 언급) | 얕음 | Q |
| SELinux | 없음(0건) | 없음 | - |
| SSH 키 인증·접속 문제 | 75, 124, 4 | 충분 | T |
| sshd_config 강화(루트 로그인·비밀번호 인증 끄기) | 없음(0건) | 없음 | - |
| sudo/sudoers 실제 설정 | 426 | 얕음 | Q |
| 파일 무결성·GPG | 181·274, 338(sha256sum) | 얕음(체크섬만) | T/Q |

### D14 로그·시간·스케줄 — 보통
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| 로그 분석(grep/awk) | 15, 341, 144·264 | 충분 | T/Q |
| cron | 123, 165·270, 10 | 충분 | T/Q |
| `/var/log` 구성, rsyslog, `/var/log/messages·secure` | 없음(0건), auth 1건 | 얕음 | - |
| logrotate | 없음(0건) | 없음 | - |
| at/anacron | 없음 | 없음 | 선택 |
| chrony·timedatectl | 75, 24 | 보통 | T |
| logger | 24 | 보통 | T |

### D15 성능 진단 — 보통
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| top/free/vmstat/uptime/load | 27, 162·269, 144 | 충분 | T/Q |
| lsof | 75, 226(삭제 후 열린 파일) | 얕음 | T 일부 |
| strace | 428 | 얕음(읽기형) | Q |
| ulimit·too many open files | 173·272 | 얕음(Q), 오류 메시지 상황 없음 | Q |
| iostat/sar/pidstat/mpstat | 없음(0건) | 없음 | - |
| OOM killer·dmesg 의 oom 로그 | 없음(oom 0건), 32 의 137 코드 | 얕음 | Q |
| lscpu/메모리·CPU 정보 | 27(코어 수) | 얕음 | T |

### D16 쉘 스크립트 — 충분(과밀)
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| 기초(변수·조건·반복·함수) | 17, 105, 35, 335, 207·281, 152·267, 213·283 | 충분 | T/Q |
| 인자·getopts·set -e·trap·배열 | 197·278, 201·279, 479 | 충분 | T/Q |
| 디버깅(`bash -x`) | 207, 278 | 보통 | Q |
| 실무형 스크립트(백업·점검·로그 로테이션 자체 구현) | 338, 341 일부 | 얕음 | T |
| shellcheck, select | 없음 | 없음 | 선택 |

### D17 원격 접속과 전송 — 보통
| 주제 | 세트 | 깊이 | 형식 |
|------|------|------|------|
| ssh 키·scp·rsync | 4, 75, 124 | 충분 | T |
| ssh config·호스트 키 경고 | 124 | 보통 | T |
| 포트 포워딩(-L/-R)·점프 호스트(-J) | 없음 | 없음 | 권장 |
| tmux/screen | 없음 | 없음 | 권장 |

### D18 장애 대응(상황집) — 얕음
| 시나리오 | 세트 | 깊이 | 형식 |
|----------|------|------|------|
| SSH 접속 실패 | 124 | 충분 | T |
| 디스크 가득·CPU 독점·포트 점유·Permission denied | 16, 226, 229 | 보통 | T |
| 원리로 푸는 증상(137·inode·좀비 등) | 32 | 보통 | Q(터미널 없음) |
| 이름 해석 장애 | 36, 81, 235 | 보통 | T/Q |
| 서비스 기동 실패(Failed to start, 의존성, 포트 충돌) | 382·24 일부 | 얕음 | T 일부 |
| 읽기 전용 파일시스템, 마운트 실패, fstab 오류 | 없음 | 없음 | - |
| SELinux 거부 | 없음 | 없음 | - |
| OOM Killed, too many open files | 없음 | 없음 | - |
| 패키지 설치 실패(의존성·저장소·lock) | 없음 | 없음 | - |
| 부팅 실패(emergency 모드 진입) | 없음 | 없음 | - |

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)
| # | 빈틈 | 근거 |
|---|------|------|
| G1 | 블록 장치·파티션·파일시스템 생성(lsblk/blkid, fdisk·parted, mkfs) | 키워드 0건. LPIC-1·RHCSA 필수 영역이며 현장에서 디스크 증설 때마다 필요 |
| G2 | mount/umount·fstab(UUID, 옵션 defaults/noatime/nofail) 실습 | 27·75 는 NFS 한정, 135·263 은 퀴즈 한 줄. 부팅 불능 사고의 주된 원인(fstab 오기)을 실습할 곳이 없음 |
| G3 | LVM(PV→VG→LV, lvextend + 파일시스템 확장) | `lvm`·`pvcreate`·`lvextend`·`resize2fs`·`xfs_growfs` 전부 0건. RHCSA 핵심이며 현장 디스크 부족의 표준 해법 |
| G4 | swap 만들기·확인(mkswap/swapon, /etc/fstab 등록) | 0건(free 의 Swap 열 읽기만 존재) |
| G5 | 패키지 관리 실습(dnf/yum 설치·제거·검색·history, 저장소 파일, dpkg/apt 대응) | yum 0, dpkg 0, dnf 1(퀴즈). rpm 조회(24)만 터미널 |
| G6 | 방화벽 기본(firewalld 존·서비스·포트 추가·영구 반영, iptables/nft·ufw 개념과 대응) | firewall-cmd·iptables·nft 0건. 포트를 열었는데 접속이 안 되는 사례가 가장 흔함 |
| G7 | SELinux 기본(모드 확인·전환, 컨텍스트 ls -Z, restorecon, boolean, 거부 로그 읽기) | 0건. RHCSA 필수, 현장 "권한은 맞는데 접근 거부"의 대표 원인 |
| G8 | 부팅·복구 기본(부팅 순서, default target, rescue/emergency, GRUB 항목, 커널 로그) | grub·rescue·isolate 0건 |
| G9 | 상황집 부족: 서비스 기동 실패 / 읽기 전용·가득 찬 디스크·마운트 실패 / 패키지 의존성 / OOM | 장애 대응 표(D18) 참고. 가르친 도구를 현장 오류 메시지로 연결하는 세트가 없음 |

### 권장
| # | 빈틈 | 근거 |
|---|------|------|
| G10 | sudoers 실제 편집(visudo, 그룹 위임, NOPASSWD 위험)·su·권한 위임 실습 | 426 은 읽기형 퀴즈(터미널 0) |
| G11 | ACL·특수 비트(setuid/setgid/sticky) 실습 | 427·173 은 퀴즈만, getfacl/setfacl 0건 |
| G12 | 사용자 계정 정책: `/etc/shadow`, chage(만료), 비밀번호 잠금, last/lastlog | chage 0건, shadow 1건(퀴즈) |
| G13 | 네트워크 영구 설정: 호스트명, nmcli(또는 netplan), 정적 IP·게이트웨이·DNS | hostnamectl·nmcli·netplan 0건. 진단(ss/ip/curl)은 풍부하나 설정은 없음 |
| G14 | 로그 체계: `/var/log` 파일 역할, rsyslog 흐름, journald 보존, logrotate 설정 읽기·강제 실행 | logrotate·rsyslog·`/var/log/messages` 0건 |
| G15 | systemd target·journal 심화: default target 전환, `journalctl -b/-f/-k`, systemd-analyze blame | 해당 키워드 0건 |
| G16 | 성능 진단 심화: iostat/sar/pidstat, OOM killer 로그 읽기, lsof 활용, ulimit 오류 재현 | iostat·sar·oom 0건. strace(428)는 읽기형 |
| G17 | SSH 강화(sshd_config: PermitRootLogin·PasswordAuthentication), 포트 포워딩, tmux | sshd_config 0건, tmux/screen 0건 |
| G18 | 커널·모듈·sysctl 직접 실습(현재 읽기형 퀴즈) | 432·433 은 터미널 0, "한 번 써 보는" 입문 세트 없음(audit 가 `missing_bridge` 높음으로 지적) |
| G19 | 읽기 전용 퀴즈(426~433)에 대응하는 입문 실습 세트 | audit 단원 59: 도구 설명서 기반 객관식으로 시작하고 입문이 없음 |

### 선택
| # | 빈틈 | 근거 |
|---|------|------|
| G20 | RAID(mdadm) 개념, quota | 현장 사용 빈도 낮음(스토리지 분야와 중복 가능성, 추정) |
| G21 | loop/tmpfs/bind mount, chattr | G1·G2 계단 마지막 응용으로 흡수 가능 |
| G22 | at/anacron, locate, ethtool/bond/vlan, IPv6, nano | 활용도 낮거나 대체 도구 존재 |
| G23 | cgroup 개념(systemd 자원 제한) | 도커·k8s 분야에서 다뤄지는지 확인 필요(추정) |
| G24 | FHS 디렉터리 구조 전용 정리 세트, 로그인/비로그인 쉘 설정 파일 로딩 순서 | 42·85·350 에서 일부 다룸, 필수는 아님 |

## 신규 세트 백로그

원칙: 한 세트 새 개념 1~3개(계단식), 가르치는 터미널 실습 우선, 기존 세트와 겹치지 않게. 단원 id 는 `merged.json` 의 unit_id(예: 4 운영과 장애 대응, 58 운영 실습과 systemd, 59 권한·진단·커널 설정 읽기, 3 네트워크와 통신). **새 단원** 제안은 아래 "신규 단원 제안"에서 설명한다.
샌드박스 제약: 실제 블록 장치가 없을 수 있어 스토리지 실습은 **loop 파일 기반**(`truncate -s` + `losetup`/`mkfs` 대상 파일, 필요 시 컨테이너 권한 확인)으로 설계해야 한다. 컨테이너에서 `losetup`/`mount` 권한이 없으면 대안(파일 이미지에 `mkfs.ext4 -F`, `mount -o loop`는 불가 시 명령 읽기·출력 고정형 문제)이 필요하다 — **추정, 제작 전 샌드박스(linux 이미지)에서 권한 확인 필요**. 패키지는 이미지 배포판(rpm 사용 흔적으로 보아 RHEL 계열, 추정)에 맞추되 apt 대응표를 함께 가르친다.

### 신규 단원 제안
- **U-A "디스크와 파일시스템"** (새 단원): 단원 4 "운영과 장애 대응" 뒤, 단원 58 앞에 배치(= 현장 운영 기본기 이후). 세트 N1~N6.
- **U-B "서비스·패키지·보안 기본"** (새 단원): U-A 뒤. 세트 N7~N14.
- **U-C "리눅스 장애 대응 상황집"** (새 단원): 맨 뒤. 세트 N15~N20.

### 필수
| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P0 | N1 블록 장치와 파티션 읽기: lsblk, blkid, 디스크 이름 | 터미널 실습 | U-A (첫 세트) | 226(df/du), 85 | lsblk 열 읽기(NAME·SIZE·TYPE·MOUNTPOINT) → 디스크/파티션/loop 구분 → blkid UUID·TYPE → 장치 이름 규칙(sda1, nvme0n1p1) | 8~10 |
| P0 | N2 파일시스템 만들고 마운트하기: mkfs, mount, umount | 터미널 실습 | U-A | N1 | 파일 이미지 만들기(truncate) → mkfs.ext4/xfs → mount·umount → df 로 확인 → "target is busy" 의미 | 10 |
| P0 | N3 fstab 으로 영구 마운트: UUID, 옵션, 오기 방지 | 터미널 실습 | U-A | N2 | fstab 6열 → UUID 로 쓰는 이유 → defaults/noatime/nofail → `mount -a` 로 검증 → 오류 줄이 부팅에 미치는 영향 | 10 |
| P0 | N4 파티션 나누기 입문: fdisk·parted 흐름, MBR vs GPT | 터미널 실습(이미지 파일 대상) + 개념 | U-A | N1 | 파티션 테이블 개념 → fdisk 대화 흐름(n/p/w) → GPT/MBR 차이와 2TB 제한 → partprobe/lsblk 로 인식 확인 | 8 |
| P0 | N5 LVM 첫걸음: PV, VG, LV 만들기와 확장 | 터미널 실습 | U-A | N2, N3 | PV/VG/LV 3계층 개념 → pvcreate·vgcreate·lvcreate → pvs/vgs/lvs 읽기 → lvextend -r 로 온라인 확장 → ext4 resize2fs/xfs_growfs 구분 | 12 |
| P0 | N6 스왑 만들기와 확인: mkswap, swapon, swap 부족 판단 | 터미널 실습 | U-A | N2, N3, 162(free) | swap 역할 → 스왑 파일 생성(fallocate·chmod 600) → mkswap·swapon → fstab 등록 → swapon --show/free | 8 |
| P0 | N7 패키지 관리 입문 1: dnf(yum)로 설치·제거·검색 | 터미널 실습 | U-B | 24(rpm 조회) | dnf search/info → install·remove → 의존성 설치 목록 읽기 → dnf history·로컬 rpm 설치 | 10 |
| P0 | N8 패키지 관리 입문 2: 저장소와 서명, apt·dpkg 대응표 | 터미널 실습 + 개념 | U-B | N7 | `/etc/yum.repos.d` 읽기·repo 추가 → GPG 서명 확인 → dpkg -l/-S/-L 과 rpm 명령 대응 → apt update/install/remove → 잠금(lock) 의미 | 10 |
| P0 | N9 방화벽 기본: firewalld 존·서비스·포트, iptables/ufw 대응 | 터미널 실습 + 개념 | U-B | 106(포트), 235(ss) | firewall-cmd --state·--list-all → 포트/서비스 허용 → runtime vs permanent·--reload → iptables -L 읽기 → ufw 명령 대응(실행 불가 시 읽기형) | 10 |
| P0 | N10 SELinux 입문: 모드, 컨텍스트, restorecon | 터미널 실습 | U-B | 65(권한) | getenforce/setenforce → ls -Z·ps -Z → 컨텍스트 불일치 재현 → restorecon·chcon → boolean(getsebool/setsebool) → 거부 로그(ausearch/audit.log) 읽기 | 10 |
| P0 | N11 부팅과 복구 기본: 부팅 순서, target, 커널 로그 | 개념 퀴즈 + 터미널(가능한 범위) | U-B | 24, 382 | 부팅 단계 순서(order 형) → default target 확인·변경(set-default) → isolate rescue 개념 → dmesg·journalctl -b/-k → GRUB 항목·커널 파라미터 읽기(편집은 읽기형) | 10 |

### 필수(상황집)
| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념 | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P0 | N15 서비스가 뜨지 않을 때 상황집 | 상황집(터미널) | U-C | 382, N11 | Failed to start → status·journalctl -xeu 로 원인 → ExecStart 경로 오류 / 포트 충돌(Address already in use) / 환경 파일 없음 / 권한·SELinux 거부 / 의존 서비스 | 8~10 |
| P0 | N16 디스크 문제 상황집: 가득 참, 읽기 전용, 마운트 실패 | 상황집(터미널) | U-C | N2, N3, 226 | No space left(블록 vs inode) / 삭제했는데 용량 안 줄음(lsof) / Read-only file system(마운트 옵션·fsck 단서) / fstab 오기 / wrong fs type·can't find UUID | 8~10 |
| P0 | N17 접근 거부 상황집: 권한 vs ACL vs SELinux vs 방화벽 | 상황집(터미널) | U-C | N9, N10, 65, 427 | Permission denied 단계별 점검 순서(소유권→모드→ACL→SELinux) / Connection refused vs timeout(서비스 vs 방화벽) | 8 |
| P0 | N18 패키지 설치 실패 상황집 | 상황집(터미널) | U-C | N7, N8 | 저장소 접근 불가·서명 오류·의존성 충돌·lock 점유(다른 dnf/apt 프로세스) | 6~8 |

### 권장
| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념 | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P1 | N12 sudo 위임 실습: visudo, 그룹 위임, 안전하게 쓰기 | 터미널 실습 | 단원 59 앞(입문)·또는 U-B | 232, 426 | visudo·문법 검사 → `%group` 위임 → 특정 명령만 허용 → sudo -l → NOPASSWD 의 위험 | 8 |
| P1 | N13 ACL과 특수 권한 직접 해 보기 | 터미널 실습 | 단원 59(427 앞) | 65, 232 | getfacl/setfacl -m → 특정 사용자 허용 → default ACL → setgid 디렉터리 협업 → sticky(/tmp) | 10 |
| P1 | N14 계정 정책: shadow, chage, 잠금, 로그인 이력 | 터미널 실습 | 단원 58 | 232 | /etc/shadow 필드 읽기 → passwd -l/-u·usermod -L → chage -l/-M 만료 → nologin 계정 → last/lastlog 읽기 | 8 |
| P1 | N19 네트워크 영구 설정: 호스트명, nmcli, 정적 IP | 터미널 실습(가능 범위) + 개념 | 단원 3 뒤 | 235 | hostnamectl → ip 임시 vs 영구 → nmcli connection show/modify → IP·게이트웨이·DNS 설정 → 설정 검증 순서 | 8 |
| P1 | N20 로그 체계 한눈에: /var/log, rsyslog, logrotate | 터미널 실습 | 단원 4 또는 58 | 15, 24 | /var/log 주요 파일 역할(messages·secure·dnf) → rsyslog 가 파일에 쓰는 흐름 → logrotate 설정 읽기·`-d`/`-f` → 보존 개수·압축 | 8 |
| P1 | N21 systemd 한 걸음 더: target, journalctl 활용, 부팅 시간 | 터미널 실습 | 단원 58 | 382, N11 | journalctl -b/-f/-k/-p·--since 조합 → systemctl list-units --failed/list-dependencies → systemd-analyze blame → systemd-run 로 일회성 실행 | 8 |
| P1 | N22 성능 병목 찾기 심화: iostat·sar, OOM, lsof | 터미널 실습(출력 고정 가능) | 단원 4 | 162, 27 | iostat -x 읽기(await·%util) → sar 로 과거 값 → OOM killer 로그(dmesg) 읽기 → lsof 로 열린 파일·포트 → ulimit -n 으로 too many open files 재현 | 10 |
| P1 | N23 SSH 강화와 활용: sshd_config, 포트 포워딩, tmux | 터미널 실습 | 단원 4(75·124 뒤) | 75, 124 | sshd_config 핵심 항목 읽기(PermitRootLogin, PasswordAuthentication) → sshd -t 검증 → -L 포워딩 개념 → tmux 세션 유지·분리 | 8 |
| P1 | N24 커널 매개변수·모듈 한 번 써 보기 | 터미널 실습 | 단원 59(432 앞) | 85 | sysctl 읽기·임시 변경 → /etc/sysctl.d 영구화 → lsmod·modinfo → modprobe 사용 → 모듈 설정 파일 | 8 |
| P1 | N25 리눅스 시스템 관리 복습(시험형) | 복습 | 마지막 | N1~N11 | 스토리지·패키지·보안·부팅 종합(터미널 3 : 퀴즈 2 비율) | 15 |

### 선택
| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념 | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P2 | N26 RAID·quota 개념 읽기 | 개념 퀴즈 | U-A 끝 | N5 | RAID 레벨 개념·mdstat 읽기·quota 개념 | 8 |
| P2 | N27 loop·tmpfs·bind mount 응용 | 터미널 실습 | U-A 끝 | N2 | tmpfs 용도 → bind mount → 이미지 파일 마운트 | 8 |
| P2 | N28 부팅 문제 상황집: 마운트 오류로 emergency 진입 | 상황집(읽기형 가능) | U-C | N3, N11 | emergency 모드 메시지 → fstab 수정 → 재부팅 | 6 |
| P2 | N29 cgroup 으로 자원 제한 개념(systemd slice) | 개념 퀴즈 | 단원 58 | 382 | MemoryMax/CPUQuota 읽기 | 6 |

백로그 합계: 필수 11(+상황집 4=15), 권장 14(번호 12~25), 선택 4. 세트 수가 많아 보이면 **P0(N1~N11, N15~N18)** 만 1차 목표로 하고, 한 세트가 12문제를 넘지 않도록 유지한다.

> 참고: 이 분야의 기존 audit 는 "한 세트 새 개념 과다"를 반복 지적했다(201·177·133 등). 위 세트는 개념을 3개 안팎으로 나눴으니 문제 수를 늘리기보다 세트를 나누는 쪽을 택할 것.

## 형식 균형

현황(리눅스 114세트, 1,534문항):
- 세트 형식: 터미널 실습형(linux/linux-systemd/linux-ssh) 44개, 퀴즈 70개(61%).
- 문항 형식: 터미널 379(24.7%), 객관식 619(40.4%), 빈칸 361(23.5%), 순서 174(11.3%).
- "한 줄씩 (1/2)(2/2)" 복습 퀴즈가 약 60세트로 가르치는 터미널 세트보다 많다. 복습은 이미 풍부하므로 **더 늘리지 않는다**.

영역별 판단과 권고 비율(문항 기준):
| 영역 | 현재 | 문제점 | 권고 터미널 비율 |
|------|------|--------|------------------|
| 스토리지(D11) | 터미널은 NFS 한정(27·75), 나머지 퀴즈 | 핵심 도구(mkfs·LVM·mount)를 직접 쳐 보는 곳이 없음 | 70% 이상 |
| 패키지(D8) | rpm 조회 6문항(24) + 퀴즈 | 설치·제거·저장소 실습 없음 | 70% |
| 보안(D13: 방화벽·SELinux) | 퀴즈 1~2문항 | 설정 → 확인 → 오류 재현 흐름은 반드시 실습 | 60~70% (실행 환경 한계 시 출력 고정형 읽기 문제 병행) |
| 권한 확장(D5: sudoers·ACL) | 426·427 퀴즈 전용 | 읽기형 퀴즈는 입문 실습 뒤에 두어야 함 | 입문 세트 터미널 80%, 기존 퀴즈는 유지 |
| 커널·모듈(D10) | 432·433 퀴즈 전용 | audit `missing_bridge` 높음 | 입문 터미널 60% |
| 부팅(D10) | 없음 | 실제 재부팅 실습은 컨테이너에서 불가(추정) | 개념 퀴즈(순서 문제) 위주 + 읽기형 터미널 40% |
| 성능(D15) | 162·269 퀴즈, 27·16 터미널 | iostat/sar/OOM 은 출력 해석이므로 출력 고정 파일 + 터미널 | 50% |
| 텍스트·스크립트·네트워크 점검(D1~D4, D12, D16) | 터미널 풍부 | 문제 없음 | 유지 |

일반 권고: 신규 "가르치는 세트"는 터미널 60~80% + 개념 확인 객관식/순서 20~40%(한 세트에 형식 3종 이상). 상황집은 터미널 100%에 가깝게(오류 재현 → 해결 확인 grade_cmd).
리눅스 전체 터미널 비율은 25% → 신규 세트 반영 시 35% 전후가 목표.
`32 리눅스 증상의 원인을 원리로 풀기`와 `30 터미널로 확인하고 고르기`는 터미널 0문항의 객관식 세트인데 제목은 실습처럼 읽힌다. 터미널 문제로 일부 전환하거나 제목을 퀴즈로 바꾸는 것을 권고(코스 신뢰도 문제).

## 상황집

기존:
- **124 SSH 접속 문제 해결 상황집**(터미널 3 + 퀴즈 8): publickey, 권한, 호스트 키, config. 양호.
- **16 리눅스 장애 진단 실전**(터미널 11): 디스크·CPU·포트·권한·종료 코드·깨진 링크. 양호하나 "오류 메시지를 보고 원인을 추정"하는 형식은 약함(증상 → 해결 지시형에 가까움, 코드상 확인).
- **32 증상의 원인을 원리로 풀기**: 오류 원인 퀴즈 8문항이지만 터미널 실습이 아님.
- **36·81 이름 해석**: 이름 해석 장애 전용으로 양호.
- 그 외에는 "상황집"으로 부를 세트가 없다.

부족한 시나리오(오류 메시지 → 원인 → 해결, 재현 실습 필요):
| # | 시나리오 | 대표 오류 메시지 | 가르칠 점검 순서 | 대응 백로그 |
|---|----------|-----------------|------------------|-------------|
| S1 | 서비스 기동 실패 | `Failed to start …`, `Address already in use`, `status=203/EXEC`, `code=exited, status=1` | status → journalctl -xeu → ExecStart 경로·환경 파일·포트·권한 | N15 |
| S2 | 디스크 가득 | `No space left on device`(블록 vs inode), 삭제 후 용량 그대로 | df -h/-i → du 로 범인 → lsof +L1 | N16 |
| S3 | 읽기 전용 파일시스템 | `Read-only file system` | mount 옵션 확인 → dmesg 오류 단서 → 재마운트/fsck 개념 | N16 |
| S4 | 마운트·fstab 오류 | `wrong fs type, bad option`, `mount point does not exist`, `can't find UUID` | blkid 와 대조 → mount -a 로 검증 → nofail 의미 | N16, N28 |
| S5 | 권한은 맞는데 거부 | `Permission denied`(SELinux), `AVC denied` | ls -Z → ausearch → restorecon | N17 |
| S6 | 포트는 열렸는데 접속 불가 | `Connection refused` vs `timed out`, firewall 미반영 | ss -ltn → firewall-cmd --list-all → permanent/reload | N17 |
| S7 | 패키지 설치 실패 | `Cannot find a valid baseurl`, `GPG check FAILED`, `Could not get lock`, 의존성 충돌 | 저장소 설정 → 키 → 다른 프로세스 확인 | N18 |
| S8 | 메모리 부족·프로세스 강제 종료 | `Killed`, `Out of memory: Killed process` | dmesg·journalctl -k → free/ps 정렬 → 원인 프로세스 | N22 |
| S9 | 열린 파일 한도 | `Too many open files` | ulimit -n → lsof -p 개수 → 한도 조정 위치 | N22 |
| S10 | 로그인 불가 | 계정 만료/잠금 `Your account has expired`, `nologin`, `Permission denied (publickey)` | chage -l → passwd -S → sshd 설정 | N14·N23 |
| S11 | 부팅 중 emergency 진입(읽기형 허용) | `Dependency failed for /data`, `You are in emergency mode` | journalctl -xb → fstab 오기 → 수정 | N28 |
| S12 | cron 이 안 돌 때 | 환경(PATH)·권한·메일/로그 | 이미 123 에서 다룸(보강 불필요) | - |

상황집 세트는 모두 `setup_cmd` 로 장애를 재현하고 `grade_cmd` 로 복구를 검증하는 터미널 형식이어야 하며, 오류 메시지 원문을 먼저 보여 주고 "무엇이 원인인가 → 어떻게 고치는가" 순서로 문제를 쌓는다. 상황집은 해당 도구를 가르치는 세트(N1~N11)가 끝난 뒤에 배치한다.

---
마지막 확인: 영역 18개 중 완전 공백은 D11(스토리지)·D13(보안)·D10(부팅)·D8(패키지 실습)이다. 이 4개 영역에 P0 세트 11개(N1~N11)와 상황집 4개(N15~N18)를 우선 채우면 LPIC-1/RHCSA 핵심 범위가 닫힌다. 샌드박스 권한(loop·mount·firewalld·SELinux 가능 여부)은 제작 전에 반드시 확인한다(추정 항목).
