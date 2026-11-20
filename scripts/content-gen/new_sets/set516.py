# 세트 516: 디스크 문제 상황집. 명세: docs/specs/spec_gap_set516.md
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from gen_pilot_sets import *

# 샌드박스는 mount·losetup 이 막혀 있다. 가득 참·읽기 전용은 "출력 파일 읽기"로, inode·삭제 후 안 줄어듦은 직접 재현해서 고친다.
BASE = CLEAN + "; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report"

DF_FILES = BASE + r"""
cat > /tmp/report/df.txt <<'EOF'
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        50G   21G   27G  44% /
/dev/sda1       1.0G  230M  794M  23% /boot
/dev/sdb1       200G  200G     0 100% /data
/dev/sdc1        80G   33G   43G  44% /var
EOF
cat > /tmp/report/df_i.txt <<'EOF'
Filesystem      Inodes IUsed  IFree IUse% Mounted on
/dev/sda2         3.2M  210K   3.0M    7% /
/dev/sda1          64K   340    64K    1% /boot
/dev/sdb1          13M  120K    13M    1% /data
/dev/sdc1         5.2M  5.2M      0  100% /var
EOF
"""

SPOOL = BASE + r"""
mkdir -p /tmp/lab/spool/mail /tmp/lab/spool/print /tmp/lab/spool/session
seq 1 40 | sed 's/^/m/' | (cd /tmp/lab/spool/mail && xargs touch)
seq 1 15 | sed 's/^/p/' | (cd /tmp/lab/spool/print && xargs touch)
seq 1 120000 | sed 's/^/s/' | (cd /tmp/lab/spool/session && xargs touch)
"""

# 로그를 열어 둔 채 계속 쓰는 프로세스. $1 = 파일 경로, $2 = 열어 둔 뒤 지울지(1) 말지(0)
def WRITER(path, pidfile, unlink):
    rm = f"rm {path}; " if unlink else ""
    return (BASE + f"; mkdir -p $(dirname {path}); dd if=/dev/zero of={path} bs=1M count=60 2>/dev/null; "
            f"stat -c %i {path} > /tmp/lab/.ino; "
            f"nohup sh -c 'exec 3>>{path}; {rm}while :; do echo tick >&3; sleep 1; done' >/dev/null 2>&1 & echo $! > {pidfile}; sleep 1")

W4 = WRITER('/tmp/lab/app/app.log', '/tmp/lab/.pid', False)
W5 = WRITER('/tmp/lab/old/app.log', '/tmp/lab/.pid', True)

REPORT_RO = BASE + r"""
cat > /tmp/report/dmesg.txt <<'EOF'
[    4.201733] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
[    4.388120] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    5.012447] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[86412.557019] blk_update_request: I/O error, dev sdb, sector 41943040 op 0x1:(WRITE)
[86412.558203] Buffer I/O error on dev sdb1, logical block 5242624, lost async page write
[86412.771540] EXT4-fs error (device sdb1): ext4_journal_check_start:83: comm app: Detected aborted journal
[86412.772018] EXT4-fs (sdb1): Remounting filesystem read-only
EOF
cat > /tmp/report/mounts.txt <<'EOF'
/dev/sda2 / ext4 rw,relatime 0 0
/dev/sda1 /boot ext4 rw,relatime 0 0
/dev/sdb1 /data ext4 ro,relatime 0 0
/dev/sdc1 /var ext4 rw,relatime 0 0
EOF
"""

U_A = '5d2c9f1e-3b7a-4c1d-9e0a-1f6b8a7c2d01'
U_B = '8e41a7c3-92d0-4f55-b3a6-7c10e9d4f802'
U_C = 'c7f03b9a-1e64-48b2-a5d7-02be3f6a9c53'
U_C_BAD = 'c7f03b9a-1e64-48b2-a5d7-02be3f6a9c35'
FSTAB = BASE + f"""
cat > /tmp/report/blkid.txt <<'EOF'
/dev/sda2: UUID="{U_A}" TYPE="ext4"
/dev/sdb1: UUID="{U_B}" TYPE="ext4"
/dev/sdc1: UUID="{U_C}" TYPE="xfs"
EOF
cat > /tmp/lab/fstab <<'EOF'
# <장치> <마운트 지점> <형식> <옵션> <dump> <pass>
UUID={U_A} / ext4 defaults 0 1
UUID={U_B} /data ext44 defaults 0 2
# 백업 디스크 = sdc1
UUID={U_C_BAD} /backup xfs defaults,nofail 0 0
EOF
"""

b = SetBuilder(516, '디스크 문제 상황집: 가득 참, inode, 삭제했는데 안 줄 때, 읽기 전용',
               '디스크 장애 메시지를 보고 원인을 가려 고칩니다. No space left on device 가 블록 부족인지 inode 부족인지 df -h·df -i 로 가르고, inode 를 먹은 폴더를 찾아 Argument list too long 없이 비우고, 로그를 지우지 않고 비우는 법, 삭제했는데 용량이 안 줄 때 /proc/PID/fd 로 잡고 있는 프로세스를 찾아 공간을 되찾는 법, dmesg 에서 읽기 전용 전환의 단서를 읽는 법, fstab 의 UUID·형식 오기를 blkid 와 대조해 고치는 법을 다룹니다.',
               'linux', '리눅스', 4, 737, '🩺',
               [{"title": "df(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/df.1.html"}, {"title": "fstab(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}], 2)

# 1 증상 판별
b.choice('용량은 남았는데 파일이 안 만들어진다',
         '장애 알림이 왔습니다. 서버에서 `touch /var/spool/a.txt` 를 하면 `touch: cannot touch ... : No space left on device` 가 나옵니다. 그런데 `df -h /var` 는 **사용률 44%** 로 용량이 넉넉합니다. 다음에 가장 먼저 확인할 것은 무엇일까요?',
         '메시지 이름은 "공간"이지만, 파일시스템이 정해 둔 한도는 용량 하나만이 아닙니다.',
         ['`df -i /var` 로 inode(파일 개수 한도) 사용률 보기', '`free -h` 로 메모리 여유 보기', '`ulimit -a` 로 프로세스 파일 한도 보기', '`fsck` 로 파일시스템 바로 검사하기'], 0,
         '`No space left on device` 는 **블록(용량)** 이 찼을 때도, **inode(파일 개수 한도)** 가 찼을 때도 나옵니다. 용량이 넉넉한데 이 메시지가 나오면 `df -i` 로 inode 를 먼저 봅니다. 메모리(`free`)나 프로세스 한도(`ulimit`)는 이 메시지와 관계가 없고, `fsck` 는 점검이 필요한 상태임을 확인한 다음에 합니다.')

# 2 df -h 읽기
b.nt('df -h 에서 용량이 찬 곳 찾기',
     '**상황** — 서버에서 데이터를 저장하던 프로그램이 `No space left on device` 로 멈췄습니다. 담당자가 그때의 `df -h` 결과를 `/tmp/report/df.txt` 로 남겨 두었습니다. (`Use%` 는 용량 사용률, `Avail` 은 남은 용량입니다)\n\n**문제** — 파일을 읽고 **용량(블록)이 가득 찬 파일시스템의 마운트 지점**(`Mounted on` 열 값)을 `/tmp/full.txt` 에 저장하세요. (값만, 한 줄)',
     '`Use%` 가 가장 큰 줄이나 `Avail` 이 0 인 줄을 찾으세요. 마지막 열이 마운트 지점입니다.',
     "cat /tmp/report/df.txt\nawk '$5==\"100%\" {print $6}' /tmp/report/df.txt > /tmp/full.txt\ncat /tmp/full.txt\n\n# 용량 사용률이 100% 인 줄의 마지막 열이 가득 찬 곳이다",
     DF_FILES,
     [chk('가득 찬 마운트 지점을 적었다', '[ "$(cat /tmp/full.txt)" = /data ]')])

# 3 df -i 읽기
b.nt('df -i 에서 inode 가 찬 곳 찾기',
     '같은 서버의 `df -i` 결과가 `/tmp/report/df_i.txt` 에 있습니다. `df -i` 는 용량 대신 **inode(파일·폴더 하나당 하나씩 쓰는 번호표)** 가 얼마나 쓰였는지 보여 줍니다. 열은 `Inodes`(전체), `IUsed`(사용), `IFree`(남음), `IUse%`(사용률) 입니다. inode 가 다 차면 용량이 남아 있어도 새 파일을 만들 수 없습니다.\n\n**문제** — **inode 가 가득 찬 파일시스템의 마운트 지점**을 `/tmp/inode_full.txt` 에 저장하세요. (값만, 한 줄)',
     '앞 문제의 `df.txt` 와 비교하지 말고 이 파일에서 `IUse%` 열만 보세요. 용량이 가득 찬 곳과 같은 곳이라는 보장이 없습니다.',
     "cat /tmp/report/df_i.txt\nawk '$5==\"100%\" {print $6}' /tmp/report/df_i.txt > /tmp/inode_full.txt\ncat /tmp/inode_full.txt\n\n# 용량은 44% 인데 inode 는 100% 인 곳이 있다. 작은 파일이 아주 많을 때 생긴다",
     DF_FILES,
     [chk('inode 가 찬 마운트 지점을 적었다', '[ "$(cat /tmp/inode_full.txt)" = /var ]')])

# 4 inode 범인 찾아 비우기
b.nt('파일이 수십만 개 쌓인 폴더 비우기',
     '`/var` 의 inode 가 찬 원인을 찾아 보니 `/tmp/lab/spool` 아래 여러 하위 폴더 중 한 곳에 **빈 임시 파일이 수십만 개** 쌓여 있습니다. (이 실습에서는 `/tmp/lab/spool` 이 그 폴더입니다)\n\n**문제**\n1. 하위 폴더 중 **파일이 가장 많은 폴더의 이름**을 `/tmp/culprit.txt` 에 저장하세요. (이름만)\n2. 그 폴더 **안의 파일을 모두 지우세요.** 폴더 자체와 다른 폴더의 파일은 그대로 둡니다.\n\n참고: 파일이 너무 많으면 `rm 폴더/*` 는 `Argument list too long` 오류로 실패할 수 있습니다.',
     '폴더마다 파일 개수를 세어 비교하세요(`for` 반복문 + `find`/`ls` + `wc -l`). 지울 때 `*` 가 너무 길다는 오류가 나면, 목록을 셸이 아니라 `find` 가 직접 처리하게 하는 방법을 찾아 보세요.',
     "for d in /tmp/lab/spool/*; do echo \"$(find $d -type f | wc -l) $d\"; done | sort -n\necho session > /tmp/culprit.txt\nfind /tmp/lab/spool/session -type f -delete\nfind /tmp/lab/spool -type f | wc -l\n\n# 폴더별 파일 수를 비교해 범인을 찾고, find -delete 로 지운다 (rm * 는 인자 목록이 너무 길어 실패할 수 있다)",
     SPOOL,
     [chk('범인 폴더 이름을 적었다', '[ "$(basename "$(cat /tmp/culprit.txt)")" = session ]'),
      chk('그 폴더가 비었고 폴더는 남아 있다', '[ -d /tmp/lab/spool/session ] && [ "$(find /tmp/lab/spool/session -type f | wc -l)" = 0 ]'),
      chk('다른 폴더 파일은 그대로다', '[ "$(find /tmp/lab/spool/mail -type f | wc -l)" = 40 ] && [ "$(find /tmp/lab/spool/print -type f | wc -l)" = 15 ]')])

# 5 로그 비우기 (rm 하지 않고)
b.nt('쓰는 중인 로그는 지우지 말고 비운다',
     '`/var` 가 용량 100% 로 찼습니다(이 실습에서는 `/tmp/lab/app` 이 그 폴더입니다). 범인은 `/tmp/lab/app/app.log`(약 60MB)이고, 서비스 하나가 이 파일에 **계속 기록하는 중**입니다. (서비스는 백그라운드에서 파일을 한 번 열고 1초마다 한 줄씩 씁니다)\n\n서비스를 멈추지 않고 이 로그가 차지한 **공간을 되찾으세요.** 단 `app.log` 파일은 **삭제하지 않고 그 자리에 남겨 두어야 합니다.** (파일 이름과 내용 위치를 서비스가 계속 쓰기 때문입니다)',
     '파일을 지우는 대신 **내용만 0 바이트로** 만드는 방법이 있습니다. 리다이렉션이나 `truncate` 명령을 떠올려 보세요.',
     "ls -lh /tmp/lab/app/app.log\n: > /tmp/lab/app/app.log\nls -lh /tmp/lab/app/app.log\n\n# 지우면 서비스는 지워진 파일에 계속 쓰므로 공간이 안 돌아온다. 같은 파일(inode)을 비워야 서비스도 계속 쓰고 공간도 확보된다 (truncate -s 0 도 같다)",
     W4,
     [chk('파일이 그 자리에 있다', '[ -f /tmp/lab/app/app.log ]'),
      chk('공간이 확보됐다(1MB 미만)', '[ "$(stat -c %s /tmp/lab/app/app.log)" -lt 1048576 ]'),
      chk('지우고 새로 만든 것이 아니라 같은 파일이다', '[ "$(stat -c %i /tmp/lab/app/app.log)" = "$(cat /tmp/lab/.ino)" ]'),
      chk('서비스는 계속 돌고 있다', 'kill -0 "$(cat /tmp/lab/.pid)"')])

# 6 삭제된 열린 파일 찾기
b.nt('지웠는데 용량이 안 줄 때: 잡고 있는 프로세스 찾기',
     '누군가 `/tmp/lab/old/app.log`(60MB)를 `rm` 으로 지웠는데 `df -h` 의 사용률은 그대로입니다. `ls` 에도 `du` 에도 파일은 안 보입니다. 이유는 **어떤 프로세스가 그 파일을 열어 둔 채**여서, 파일 이름만 지워지고 데이터 공간은 프로세스가 닫을 때까지 풀리지 않기 때문입니다.\n\n이런 파일은 보통 `lsof +L1`(링크 수 0 인 열린 파일)로 찾지만, 이 환경에는 `lsof` 가 없습니다. 대신 **`/proc/<PID>/fd/`** 에서 열린 파일 목록을 볼 수 있고, 지워진 파일은 `(deleted)` 로 표시됩니다.\n\n**문제** — 지워진 `app.log` 를 열고 있는 프로세스의 **PID** 를 `/tmp/pid.txt` 에, 그 파일의 **fd 번호**(`/proc/PID/fd/` 아래 숫자)를 `/tmp/fd.txt` 에 저장하세요. (숫자만)',
     '`ls -l /proc/*/fd` 의 출력에서 `(deleted)` 가 붙은 줄을 걸러 보세요. 어느 PID 의 폴더 안인지 같이 나오게 하려면 `find /proc/*/fd` 에 링크 대상 이름으로 찾는 옵션을 써도 됩니다.',
     "find /proc/[0-9]*/fd -lname '*(deleted)' 2>/dev/null\nP=$(cat /tmp/lab/.pid)\nls -l /proc/$P/fd | grep deleted\necho $P > /tmp/pid.txt\necho 3 > /tmp/fd.txt\n\n# find 결과가 /proc/PID/fd/번호 형태다. 번호 앞 숫자가 PID, 마지막 숫자가 fd 번호",
     W5,
     [chk('PID 가 맞다', '[ "$(cat /tmp/pid.txt)" = "$(cat /tmp/lab/.pid)" ]'),
      chk('fd 번호가 맞다', '[ "$(cat /tmp/fd.txt)" = 3 ]')])

# 7 프로세스를 죽이지 않고 공간 회수
b.nt('프로세스를 멈추지 않고 삭제된 파일의 공간 되찾기',
     '앞 상황과 같습니다. `/tmp/lab/old/app.log` 는 지워졌고, 서비스 프로세스가 이 파일을 열어 두고 계속 기록하는 중입니다. 서비스를 **재시작할 수 없는 상황**이라고 가정합니다.\n\n프로세스를 **종료하지 않고**, 삭제된 파일이 차지한 공간을 되돌리세요. 프로세스가 열어 둔 파일은 `/proc/<PID>/fd/<번호>` 로 접근할 수 있습니다. (PID 와 번호는 `/proc` 아래에서 직접 찾으세요)',
     '열려 있는 그 파일에 `/proc/.../fd/...` 경로로 접근해 내용을 0 바이트로 만들면 됩니다. 이름이 지워져도 이 경로로는 쓸 수 있습니다.',
     "P=$(find /proc/[0-9]*/fd -lname '*(deleted)' 2>/dev/null | head -1 | cut -d/ -f3)\nls -lL /proc/$P/fd/3\n: > /proc/$P/fd/3\nls -lL /proc/$P/fd/3\n\n# 지워진 파일도 열려 있는 동안은 /proc/PID/fd/번호 로 접근된다. 비우면 프로세스는 그대로 돌고 공간만 돌아온다 (프로세스를 종료해도 풀린다)",
     W5,
     [chk('서비스는 계속 돌고 있다', 'kill -0 "$(cat /tmp/lab/.pid)"'),
      chk('삭제된 파일 크기가 1MB 미만이다', '[ "$(stat -L -c %s /proc/$(cat /tmp/lab/.pid)/fd/3)" -lt 1048576 ]')])

# 8 읽기 전용 단서
b.nt('Read-only file system: 로그에서 원인과 위치 찾기',
     '`/data` 에 파일을 저장하려는데 `cannot create regular file: Read-only file system` 오류가 납니다. 운영 중 갑자기 쓰기가 막힌 경우, 보통 커널이 파일시스템 오류를 만나 **스스로 읽기 전용(`ro`)으로 바꿔** 데이터를 보호한 것입니다. 단서는 커널 로그(`dmesg`)에 남습니다. (이 환경에서는 `mount` 를 쓸 수 없어, 담당자가 저장해 둔 `/tmp/report/dmesg.txt` 와 `/tmp/report/mounts.txt`(마운트 목록)를 읽습니다)\n\n**문제**\n1. `dmesg.txt` 에서 **읽기 전용으로 다시 마운트됐다**(`Remounting filesystem read-only`)고 나온 **장치 이름**(예 `sda1` 형태, `/dev/` 는 빼고)을 `/tmp/dev.txt` 에 저장하세요.\n2. `mounts.txt` 에서 그 장치의 **마운트 지점**을 `/tmp/mp.txt` 에 저장하세요.',
     '`grep` 으로 "read-only" 를 찾으면 그 줄의 괄호 안에 장치가 있습니다. 같은 장치를 `mounts.txt` 에서 찾고, 옵션 열에 `ro` 가 있는지도 확인하세요.',
     "grep -i 'read-only' /tmp/report/dmesg.txt\ngrep 'Remounting filesystem read-only' /tmp/report/dmesg.txt | sed 's/.*(\\(.*\\)).*/\\1/' > /tmp/dev.txt\ngrep sdb1 /tmp/report/mounts.txt\nawk '$1==\"/dev/sdb1\" {print $2}' /tmp/report/mounts.txt > /tmp/mp.txt\ncat /tmp/dev.txt /tmp/mp.txt\n\n# 같은 장치 앞쪽에는 I/O error(디스크 쓰기 실패)가 먼저 찍혀 있다. 이것이 읽기 전용으로 바뀐 직접 원인이다",
     REPORT_RO,
     [chk('장치 이름을 적었다', '[ "$(sed "s#^/dev/##" /tmp/dev.txt)" = sdb1 ]'),
      chk('마운트 지점을 적었다', '[ "$(cat /tmp/mp.txt)" = /data ]')])

# 9 읽기 전용 대처
b.choice('읽기 전용이 된 디스크, 어떻게 다룰까',
         '앞 상황의 `/data`(`/dev/sdb1`)가 `dmesg` 에 `I/O error` 와 `Detected aborted journal` 을 남기고 읽기 전용이 됐습니다. 급하다고 `mount -o remount,rw /data` 로 바로 쓰기를 되살려 서비스를 이어 가도 될까요? 가장 알맞은 대처는 무엇일까요?',
         '읽기 전용은 오류로부터 데이터를 지키려는 커널의 보호 동작입니다. 원인을 모른 채 푸는 것의 위험을 생각해 보세요.',
         ['로그로 디스크 오류 여부를 확인하고, 서비스를 멈춘 뒤 언마운트해서 `fsck` 로 점검·복구한다', '`mount -o remount,rw` 로 바로 쓰기를 열고 서비스를 계속 돌린다', '`chmod -R 777 /data` 로 권한을 모두 열어 준다', '서버를 반복해서 재부팅하면 저절로 해결된다'], 0,
         '커널이 오류 때문에 읽기 전용으로 바꾼 것을 강제로 `rw` 로 되돌리면 손상된 상태에서 계속 써서 더 많은 데이터를 잃을 수 있습니다. 먼저 `dmesg` 로 하드웨어/파일시스템 오류인지 확인하고, 서비스를 멈춘 뒤 언마운트해 `fsck`(XFS 는 `xfs_repair`)로 점검·복구합니다. `chmod` 는 읽기 전용(마운트 상태)과 관계가 없습니다.')

# 10 fstab 오기 고치기
b.nt('fstab 오기: wrong fs type 과 can\'t find UUID 고치기',
     '재부팅하면 `/data` 에서 `mount: wrong fs type, bad option, bad superblock`, `/backup` 에서 `Can\'t find UUID=...` 가 나오며 마운트가 실패합니다. 마운트 설정 파일인 fstab 을 연습용 복사본 `/tmp/lab/fstab` 으로 고쳐 봅니다. 한 줄은 `UUID=<디스크 번호> <마운트 지점> <파일시스템 형식> <옵션> <dump> <pass>` 형태입니다.\n\n각 디스크의 실제 UUID·형식은 `blkid` 출력을 저장한 `/tmp/report/blkid.txt` 에 있습니다. fstab 의 **잘못된 두 줄**을 `blkid.txt` 와 대조해 고치세요. (`/backup` 은 `sdc1` 디스크입니다. 다른 줄은 바꾸지 않습니다)',
     '`/data` 줄은 파일시스템 형식 이름에 오타가 있고, `/backup` 줄은 UUID 가 한 곳 다릅니다. UUID 는 눈으로 대조하지 말고 `blkid.txt` 에서 복사해 와 바꾸는 편이 안전합니다.',
     "cat /tmp/report/blkid.txt\nsed -i 's/ ext44 / ext4 /' /tmp/lab/fstab\nsed -i \"s/^UUID=[^ ]* \\/backup/UUID=" + U_C + " \\/backup/\" /tmp/lab/fstab\ncat /tmp/lab/fstab\n\n# 형식 오타는 wrong fs type, 없는 UUID 는 can't find UUID 로 나타난다. blkid 와 한 줄씩 대조하고, 실제 마운트 전에 mount -a 로 검증하는 것이 좋다",
     FSTAB,
     [chk('/data 줄의 형식이 ext4 다', '[ "$(awk \'$2=="/data" {print $3}\' /tmp/lab/fstab)" = ext4 ]'),
      chk('/backup 줄의 UUID 가 blkid 와 같다', f'[ "$(awk \'$2=="/backup" {{print $1}}\' /tmp/lab/fstab)" = "UUID={U_C}" ]'),
      chk('나머지 줄은 그대로다', f'grep -qx "UUID={U_A} / ext4 defaults 0 1" /tmp/lab/fstab && grep -qx "UUID={U_B} /data ext4 defaults 0 2" /tmp/lab/fstab && grep -qx "UUID={U_C} /backup xfs defaults,nofail 0 0" /tmp/lab/fstab')])

# 11 빈칸
b.fill('백업 디스크가 없어도 부팅은 계속하기',
       '`/backup` 은 가끔 분리해 두는 외장 디스크입니다. 디스크가 연결돼 있지 않아도 **부팅이 멈추지 않고 계속 진행**되도록 fstab 의 옵션 열에 넣을 값을 채우세요.',
       '"없어도 실패로 보지 않는다"는 뜻의 이름을 가진 옵션입니다.',
       'UUID=c7f0... /backup xfs defaults,{0} 0 0', ['nofail', 'noauto', 'ro', 'sync'], [0],
       '`nofail` 은 해당 장치가 없거나 마운트에 실패해도 부팅을 실패 상태로 두지 않고 계속 진행하게 합니다. `noauto` 는 부팅 때 아예 자동으로 마운트하지 않는 옵션이라 "마운트를 시도하되 실패해도 넘어가기"와 다르고, `ro` 는 읽기 전용, `sync` 는 쓰기를 즉시 동기 처리하는 옵션입니다.')

# 12 순서
# 정답 순서: 어느 파일시스템 → 용량 사용률 → inode 사용률 → 범인 찾기 → 정리 → 재확인
b.order('디스크가 찼을 때 점검 순서', '`No space left on device` 장애를 처리하는 올바른 순서로 카드를 놓으세요. (원인을 가르는 단계가 먼저, 정리는 범인을 확인한 뒤입니다)',
        '증상이 난 위치에서 시작해 점점 범위를 좁히고, 손대기 전과 후를 같은 방법으로 봅니다.',
        ['`du` 로 큰 폴더를 따라 내려가 범인을 찾는다', '정리한 뒤 `df` 로 다시 확인한다', '`df -h` 로 용량 사용률을 본다', '`df -i` 로 inode 사용률을 본다', '오류가 난 경로가 속한 파일시스템을 확인한다', '범인만 골라 비우거나 지운다'], [4, 2, 3, 0, 5, 1],
        '먼저 오류가 난 경로가 어느 파일시스템인지 확인하고, 용량(`df -h`)과 inode(`df -i`) 중 어느 쪽이 찼는지 가립니다. 그 다음 `du`(또는 파일 개수 세기)로 범인을 찾아 그것만 정리하고, 마지막에 `df` 로 공간이 돌아왔는지 확인합니다. 지워도 공간이 안 돌아오면 열려 있는 삭제 파일(`/proc/PID/fd`)을 의심합니다.')

if __name__ == '__main__':
    preview(b)
