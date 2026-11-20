import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 579: 파일시스템 장애 상황집(손상·복구). 명세: docs/specs/spec_gap_set579.md
# 샌드박스 linux(비특권, 마운트 불가). 슈퍼블록이 망가진 ext4 이미지를 백업 슈퍼블록으로 복구하고, 종류를 모르는 이미지를 식별하며, fsck 출력 샘플을 읽는다.

S79 = """rm -f /tmp/*.img /tmp/*.txt /tmp/*.log /tmp/payload /tmp/restored.dat
dd if=/dev/urandom of=/tmp/payload bs=1k count=256 2>/dev/null
truncate -s 16M /tmp/broken.img
mke2fs -q -F -t ext4 -b 1024 /tmp/broken.img
debugfs -w -R "write /tmp/payload keep.dat" /tmp/broken.img >/dev/null 2>&1
dd if=/dev/zero of=/tmp/broken.img bs=1k seek=1 count=1 conv=notrunc 2>/dev/null
dd if=/dev/zero of=/tmp/mystery.img bs=1M count=4 2>/dev/null
chmod 600 /tmp/mystery.img; mkswap /tmp/mystery.img >/dev/null 2>&1
cat > /tmp/fsck_sample.log <<'EOF'
Pass 1: Checking inodes, blocks, and sizes
Inode 12 has illegal block(s).  Clear? yes

Illegal block #3 (4294967295) in inode 12.  CLEARED.
Inode 12, i_blocks is 40, should be 16.  Fix? yes

Inode 15 has illegal block(s).  Clear? yes

Pass 2: Checking directory structure
Entry 'a.dat' in <2> (2) has deleted/unused inode 20.  Clear? yes

Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
Free blocks count wrong for group #0 (7000, counted=6990).
Fix? yes

/dev/vg0/data: ***** FILE SYSTEM WAS MODIFIED *****
/dev/vg0/data: 120/4096 files (0.0% non-contiguous), 2700/16384 blocks
EOF
true"""

S79R = S79[:-4] + "e2fsck -b 8193 -y /tmp/broken.img >/dev/null 2>&1\ntrue"

b = SetBuilder(579, '파일시스템 장애 상황집: 슈퍼블록 손상 복구, 종류 식별, fsck 출력 읽기',
               '"마운트가 안 된다 / bad superblock" 같은 파일시스템 장애를 이미지 파일로 재현해 복구해 보는 상황집입니다. 슈퍼블록이 망가진 ext4 를 백업 슈퍼블록으로 되살리고, 데이터를 꺼내 확인하고, 종류를 모르는 디스크가 실제로 무엇인지 식별하고, fsck 가 남긴 출력에서 손상된 항목을 읽습니다. 마운트 권한이 없어 이미지 파일에서 진행합니다.',
               'linux', '스토리지', 71, 839, '🛟',
               [{"title": "e2fsck 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/e2fsck.8.html"}, {"title": "debugfs 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/debugfs.8.html"}], 5)

# 1
b.nt('오류 메시지 확인', '`/tmp/broken.img` 는 마운트하려고 하면 "bad superblock" 오류가 나는 ext4 이미지입니다. 파일시스템 정보를 읽는 `dumpe2fs -h /tmp/broken.img` 를 실행해 **오류 메시지의 핵심 문구**(`Bad magic number` 가 포함된 줄)를 `/tmp/err.txt` 에 저장하세요. (오류는 표준 에러로 나옵니다)',
     '`dumpe2fs` 는 오류를 표준 에러로 출력합니다. 에러 출력까지 파이프로 넘겨 원하는 줄만 고르세요.',
     "dumpe2fs -h /tmp/broken.img 2>&1 | head -5\ndumpe2fs -h /tmp/broken.img 2>&1 | grep 'Bad magic' > /tmp/err.txt\ncat /tmp/err.txt\n\n# 슈퍼블록(파일시스템의 크기·상태가 적힌 첫 구조)이 읽히지 않는 상태다. 슈퍼블록은 여러 곳에 백업이 있어서 복구할 수 있다",
     S79, [chk('Bad magic number 가 들어 있다', 'grep -q "Bad magic number" /tmp/err.txt')])
# 2
b.nt('백업 슈퍼블록 위치 찾기', '슈퍼블록은 파일시스템의 여러 블록 그룹에 백업이 있습니다. 같은 크기·블록 크기(1024)로 파일시스템을 **새로 만든다면** 백업이 어디에 놓일지 알려 주는 **모의 실행** 옵션이 있습니다(실제로 쓰지 않습니다). 이 이미지의 **첫 번째 백업 슈퍼블록 블록 번호**를 `/tmp/backup_sb.txt` 에 저장하세요. (숫자만) 주의: 모의 실행 옵션 없이 파일시스템 생성 도구를 실행하면 내용이 지워집니다.',
     '파일시스템 생성 도구에는 "실제로 만들지 않고 결과만 보여 주는" 옵션이 있습니다. 블록 크기를 같게 줘야 위치가 같습니다.',
     "mke2fs -n -b 1024 /tmp/broken.img 2>&1 | tail -4\nmke2fs -n -b 1024 /tmp/broken.img 2>&1 | grep -A1 'Superblock backups' | tail -1 | awk '{print $1}' | tr -d ',' > /tmp/backup_sb.txt\ncat /tmp/backup_sb.txt\n\n# 주의: -n 없이 mke2fs 를 실행하면 파일시스템이 새로 만들어져 데이터가 사라진다. 반드시 -n 을 확인한다",
     S79, [chk('8193 이다', '[ "$(cat /tmp/backup_sb.txt)" = 8193 ]')])
# 3
b.nt('백업 슈퍼블록으로 복구', '앞에서 찾은 **백업 슈퍼블록**을 써서 `/tmp/broken.img` 를 복구하세요. 질문에는 모두 yes 로 답하고, 복구 뒤 **점검에서 오류가 없어야** 하며 안에 있던 `keep.dat` 도 살아 있어야 합니다.',
     '파일시스템 점검 도구에 대체 슈퍼블록을 지정하는 옵션이 있습니다. 질문에 자동으로 답하는 옵션도 함께 쓰세요.',
     "e2fsck -b 8193 -y /tmp/broken.img\ne2fsck -fn /tmp/broken.img\ndebugfs -R 'ls -l' /tmp/broken.img | grep keep.dat\n\n# -b 를 안 줘도 e2fsck 가 백업을 자동으로 시도하는 경우가 있다. 실제 디스크에서는 먼저 dd 로 통째 복사본을 만들어 두고 복사본에서 시도하는 것이 안전하다. 복구가 잘못되면 더 망가질 수 있다",
     S79, [chk('점검 결과가 깨끗하다', 'e2fsck -fn /tmp/broken.img >/dev/null 2>&1'), chk('keep.dat 가 있다', 'debugfs -R "ls -l" /tmp/broken.img 2>/dev/null | grep -q keep.dat')])
# 4
b.nt('복구한 데이터 꺼내 검증', '(앞 문제에서 복구를 마친 상태입니다) `/tmp/broken.img` 에서 `keep.dat` 파일을 꺼내 `/tmp/restored.dat` 로 저장하세요. 마운트하지 못하므로 파일시스템 디버깅 도구로 파일을 직접 꺼냅니다. 원본(`/tmp/payload`)과 내용이 같아야 합니다.',
     '`debugfs` 에는 파일시스템 안의 파일을 바깥으로 꺼내는 명령이 있습니다. `-R` 로 명령 하나를 실행할 수 있습니다.',
     "debugfs -R 'dump keep.dat /tmp/restored.dat' /tmp/broken.img\ncmp /tmp/restored.dat /tmp/payload && echo same\n\n# 마운트가 안 되는 파일시스템에서도 debugfs 로 파일을 꺼낼 수 있어 복구 전 데이터부터 구출할 때 쓴다. 복구 후에는 반드시 내용을 원본과 대조한다",
     S79R, [chk('원본과 같다', 'cmp -s /tmp/restored.dat /tmp/payload')])
# 5
b.nt('정체를 모르는 디스크 식별', '`/tmp/mystery.img` 를 `mount -t ext4` 로 마운트하려니 "wrong fs type" 오류가 났다고 합니다. 이 이미지의 **실제 파일시스템(또는 영역) 종류**를 식별해 종류 이름만 `/tmp/type.txt` 에 저장하세요.',
     '블록 장치(이미지)의 내용을 보고 종류를 알려 주는 도구가 있습니다. 필요한 속성만 출력하는 옵션이 있습니다.',
     "blkid /tmp/mystery.img\nblkid -s TYPE -o value /tmp/mystery.img > /tmp/type.txt\ncat /tmp/type.txt\n\n# swap 영역은 파일시스템이 아니라 마운트가 안 된다. 같은 증상이어도 종류를 먼저 확인한다. mkfs 를 다시 하기 전에 내용이 정말 필요 없는지부터 확인한다",
     S79, [chk('swap 이다', '[ "$(cat /tmp/type.txt)" = swap ]')])
# 6
b.nt('fsck 출력에서 손상된 inode', '`/tmp/fsck_sample.log` 는 어떤 서버에서 `e2fsck` 를 수정 모드로 실행한 출력입니다. `Pass 1` 에서 **"has illegal block(s)"** 로 보고된 inode 번호를 **작은 번호부터 한 줄에 하나씩** `/tmp/bad_inodes.txt` 에 저장하세요.',
     '손상 보고 문구가 들어간 줄에서 inode 번호가 몇 번째 칸인지 확인하세요.',
     "cat /tmp/fsck_sample.log\ngrep 'has illegal block' /tmp/fsck_sample.log | awk '{print $2}' | sort -n > /tmp/bad_inodes.txt\ncat /tmp/bad_inodes.txt\n\n# 12 와 15 번 inode 의 블록 정보가 잘못되어 지웠다. 해당 파일의 내용은 일부 잃었을 수 있어 fsck 후 lost+found 와 데이터를 확인한다",
     S79, [chk('12, 15 이다', '[ "$(tr "\\n" " " < /tmp/bad_inodes.txt | xargs)" = "12 15" ]')])
# 7
b.choice('읽기 전용으로 바뀐 파일시스템', '운영 중이던 서버의 데이터 디스크가 갑자기 `Read-only file system` 오류를 냅니다. 마운트 옵션에 `errors=remount-ro` 가 있습니다. 이 상황으로 가장 알맞은 해석은?', '이 옵션이 오류를 만났을 때 하는 일을 생각해 보세요.',
         ['오류를 감지해 읽기 전용으로 전환됐다', '디스크가 가득 차서 쓰기가 막혔다', '파일 권한 설정이 읽기 전용으로 바뀌었다', '서버가 곧 재부팅되는 중이다'], 0,
         '`errors=remount-ro` 는 파일시스템 오류(디스크 I/O 오류 포함)를 만나면 더 이상 손상되지 않도록 읽기 전용으로 바꿉니다. dmesg 로 원인을 보고, 언마운트 후 fsck 로 점검한 뒤 다시 마운트합니다. 디스크 가득 참은 다른 오류 메시지(No space left)입니다.')
# 8
b.choice('마운트 중인 파일시스템에 fsck', '운영 중인 서버에서 마운트된 ext4 파일시스템에 바로 `e2fsck -y` 를 실행하면 안 되는 이유로 가장 알맞은 것은?', '점검하는 도구와 운영 중인 시스템이 같은 구조를 동시에 바꾸면 어떻게 될지 생각해 보세요.',
         ['커널이 쓰고 있는 구조와 점검 도구가 서로 충돌해 오히려 손상될 수 있다', 'fsck 는 읽기만 하므로 디스크 수명이 줄기 때문이다', '마운트된 파일시스템은 fsck 가 지원하지 않는 문법을 쓰기 때문이다', '점검 결과가 항상 거짓이기 때문이다'], 0,
         '마운트된 파일시스템은 커널이 계속 메타데이터를 바꿉니다. 그 위에서 수정 모드 fsck 를 실행하면 두 쪽이 동시에 같은 구조를 바꿔 손상될 수 있어 언마운트(또는 읽기 전용) 상태에서 점검해야 합니다. 읽기 전용 점검(-n)은 참고용으로만 씁니다.')
# 9
b.fill('백업 슈퍼블록 지정 옵션', '슈퍼블록이 손상된 파일시스템을 **블록 8193 의 백업 슈퍼블록**으로 점검·복구하려 합니다. 빈칸에 들어갈 `e2fsck` 옵션을 채우세요.', '대체 슈퍼블록 위치를 지정하는 옵션입니다. 블록 크기를 지정하는 옵션과 헷갈리지 마세요.',
       'e2fsck -{0} 8193 /dev/sdb1', ['b', 'B', 'c', 'l'], [0],
       '`-b` 는 사용할 슈퍼블록(백업) 위치를 지정합니다. `-B` 는 슈퍼블록을 찾을 때 쓸 블록 크기, `-c` 는 불량 블록 검사, `-l` 은 불량 블록 목록 파일 지정입니다.')
# 10
b.order('손상된 파일시스템 복구 순서', '데이터 디스크의 파일시스템이 손상되어 복구해야 합니다. 데이터를 더 잃지 않도록 하는 순서로 놓으세요. (복사본은 언마운트한 상태에서 떠야 일관성이 있습니다.)', '수정은 가장 위험한 단계입니다.',
        ['읽기 전용(`-n`)으로 점검해 문제 범위를 본다', '수정 모드로 fsck 를 실행한다', '디스크를 통째로 이미지로 복사해 둔다', '파일시스템을 언마운트한다', '마운트해 데이터가 정상인지 확인한다'], [3, 2, 0, 1, 4],
        '점검·수리는 마운트를 해제한 상태에서 하고, 고치기 전에 복사본을 만들어 되돌릴 수 있게 합니다. 읽기 전용 점검으로 범위를 본 뒤 수정 모드로 실행하고, 마지막으로 마운트해 데이터를 확인합니다.')

if __name__ == '__main__':
    preview(b)
