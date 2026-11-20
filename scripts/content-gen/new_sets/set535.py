# 세트 535: 파일시스템 만들고 점검하기: mkfs·마운트 개념. 명세: docs/specs/spec_gap_set535.md
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from gen_pilot_sets import *

# 샌드박스는 mount·losetup 이 막혀 있다(비특권 컨테이너). 이미지 파일에 파일시스템을 만들고 읽고 점검하는 것까지는 실제로 하고,
# mount·umount·busy 오류·df 확인은 출력 읽기 객관식·순서·빈칸으로 다룬다.
BASE = CLEAN + "; rm -rf /tmp/lab; mkdir -p /tmp/lab"
IMG = BASE + "; truncate -s 16M /tmp/lab/disk.img"
UUID = '3f9a6c10-7b2e-4d85-a1c4-9e0b5d2f7a68'
FS_UUID = IMG + f"; mkfs.ext4 -F -q -U {UUID} /tmp/lab/disk.img"
FS_BLK = BASE + "; truncate -s 8M /tmp/lab/disk.img; mkfs.ext4 -F -q -b 1024 /tmp/lab/disk.img"
FS_DATA = IMG + "; mkfs.ext4 -F -q -L data /tmp/lab/disk.img"

b = SetBuilder(535, '파일시스템 만들고 점검하기: mkfs·마운트 개념',
               '디스크를 쓰려면 먼저 파일시스템을 만들어야 합니다. 샌드박스에서는 진짜 디스크 대신 이미지 파일(truncate)을 만들어 mkfs.ext4 -F 로 ext4 를 만들고, tune2fs 로 레이블을 붙이고, blkid 로 UUID 를 읽고, dumpe2fs 로 블록 크기를 읽고, e2fsck 로 점검합니다. 마운트 순서(mkfs → mount → 사용 → umount), mount 빈칸, df -hT 읽기, umount 의 target is busy 오류는 출력을 읽는 문제로 익힙니다.',
               'linux', '리눅스', 4, 756, '💽',
               [{"title": "mount(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/mount.8.html"}, {"title": "truncate(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/truncate.1.html"}], 3)

# 1 파일시스템이란
b.choice('새 디스크에 파일을 저장하려면 먼저',
         '서버에 새 디스크를 꽂았더니 `/dev/sdb` 라는 장치가 보입니다. 디스크는 아직 **아무 것도 적히지 않은 빈 저장 공간**입니다. 여기에 파일과 폴더를 저장하려면 먼저 **파일시스템**(ext4, xfs 같은 "파일을 어디에 어떻게 적어 둘지 정한 규칙과 목록")을 만들어야 합니다. 이 일을 하는 명령은 무엇일까요?',
         '"파일시스템을 만든다"는 뜻의 영어 단어(make file system)를 줄인 이름입니다.',
         ['`mkfs.ext4 /dev/sdb` 처럼 `mkfs` 로 파일시스템 만들기', '`chmod 755 /dev/sdb` 로 권한 주기', '`df -h /dev/sdb` 로 용량 확인하기', '`ls /dev/sdb` 로 폴더 열어 보기'], 0,
         '파일시스템은 파일 이름·위치·크기를 기록하는 목록과 규칙입니다. 이것이 없는 디스크에는 파일을 저장할 수 없고, `mkfs`(make file system) 로 만듭니다. 리눅스에서 많이 쓰는 종류는 `ext4` 와 `xfs` 이고 각각 `mkfs.ext4`, `mkfs.xfs` 명령을 씁니다. 주의: `mkfs` 는 그 장치에 있던 내용을 지웁니다.')

# 2 truncate
b.nt('연습용 이미지 파일 만들기',
     '진짜 디스크 대신 **이미지 파일**(디스크처럼 쓰는 일반 파일)로 연습합니다. 리눅스는 파일시스템을 장치뿐 아니라 일반 파일 안에도 만들 수 있습니다. 먼저 크기만 정해 둔 빈 파일을 만듭니다. `truncate -s 크기 파일` 은 지정한 크기의 파일을 만들어 줍니다(크기 단위: `K`, `M`, `G`).\n\n**문제** — `/tmp/lab/disk.img` 를 **16MiB**(16M) 크기로 만드세요. (`/tmp/lab` 폴더는 이미 있습니다)',
     '`truncate` 의 `-s`(size) 옵션에 크기를 `숫자M` 형태로 주면 됩니다. 만든 뒤 `ls -l` 로 바이트 크기를 확인해 보세요.',
     "truncate -s 16M /tmp/lab/disk.img\nls -l /tmp/lab/disk.img\n\n# 16M = 16 x 1024 x 1024 = 16777216 바이트 크기의 파일이 생긴다",
     BASE,
     [chk('disk.img 가 16MiB 다', '[ -f /tmp/lab/disk.img ] && [ "$(stat -c %s /tmp/lab/disk.img)" = 16777216 ]')])

# 3 -F
b.choice('mkfs.ext4 가 "Proceed anyway?" 라고 물을 때',
         '이미지 파일에 `mkfs.ext4 disk.img` 를 하면 다음처럼 확인을 묻습니다.\n\n```\ndisk.img is not a block special device.\nProceed anyway? (y,N)\n```\n\n"블록 장치(진짜 디스크)가 아닌 일반 파일인데 계속할까요?"라는 뜻입니다. 이 질문 없이 **일반 파일에도 바로 파일시스템을 만들게** 하는 옵션은 무엇일까요?',
         '"강제로"를 뜻하는 영어 단어(force)의 첫 글자입니다. 대문자입니다.',
         ['`-F` (force, 강제로 진행)', '`-L` (label, 이름 붙이기)', '`-q` (quiet, 메시지 줄이기)', '`-b` (block size, 블록 크기 정하기)'], 0,
         '`mkfs.ext4 -F` 는 대상이 일반 파일이거나 이미 파일시스템이 있어 보여도 확인 없이 진행합니다. 이미지 파일 실습에서 필수입니다. 하지만 **진짜 디스크에서는 지울 내용이 없는지 확인한 뒤에** 써야 합니다. `-L` 은 레이블, `-q` 는 출력 줄이기, `-b` 는 블록 크기 지정이며 "Proceed anyway?" 와는 관계가 없습니다.')

# 4 mkfs.ext4
b.nt('이미지 파일에 ext4 파일시스템 만들기',
     '앞에서 만든 것과 같은 16MiB 이미지 파일 `/tmp/lab/disk.img` 가 준비돼 있습니다(아직 파일시스템이 없습니다). 이 이미지 파일 안에 **ext4** 파일시스템을 만드세요. 확인 질문 없이 진행되도록 방금 배운 옵션을 쓰고, 메시지가 길면 `-q`(quiet) 를 같이 써도 됩니다.\n\n만든 뒤에는 `blkid /tmp/lab/disk.img` 로 `TYPE="ext4"` 가 보이는지 직접 확인해 보세요.',
     '명령 이름은 `mkfs.` 뒤에 파일시스템 이름을 붙입니다. 이미지 파일은 장치 이름 자리에 경로를 그대로 적습니다.',
     "mkfs.ext4 -F -q /tmp/lab/disk.img\nblkid /tmp/lab/disk.img\n\n# -F 로 일반 파일에도 확인 없이 만든다. blkid 에 TYPE=\"ext4\" 가 나오면 성공이다",
     IMG,
     [chk('disk.img 에 ext4 파일시스템이 있다', '[ "$(blkid -p -s TYPE -o value /tmp/lab/disk.img)" = ext4 ]')])

# 5 레이블
b.nt('파일시스템에 레이블(이름표) 붙이기',
     '파일시스템에는 사람이 알아보기 쉬운 **레이블**(이름표)을 붙일 수 있습니다. 장치 이름(`sdb1` 등)은 꽂는 순서에 따라 바뀔 수 있지만 레이블은 그대로여서 `LABEL=backup` 처럼 쓸 수 있습니다. ext4 의 레이블은 `tune2fs -L 이름 장치` 로 붙입니다. 이미 `/tmp/lab/disk.img` 에 ext4 파일시스템이 있고 레이블은 비어 있습니다.\n\n**문제** — 이 파일시스템의 레이블을 `backup` 으로 정하세요. (이미지 파일은 다시 만들지 않습니다)',
     '`tune2fs` 는 이미 만들어진 ext4 의 설정을 바꾸는 명령입니다. 레이블을 정하는 옵션을 `-L` 로 지정하세요. 결과는 `blkid` 에서 `LABEL=` 로 보입니다.',
     "tune2fs -L backup /tmp/lab/disk.img\nblkid /tmp/lab/disk.img\n\n# mkfs 때 -L 로 붙여도 되지만, 이미 만든 뒤에는 tune2fs -L 로 바꾼다",
     IMG + "; mkfs.ext4 -F -q /tmp/lab/disk.img",
     [chk('레이블이 backup 이다', '[ "$(blkid -p -s LABEL -o value /tmp/lab/disk.img)" = backup ]')])

# 6 blkid UUID
b.nt('blkid 로 UUID 읽기',
     '파일시스템에는 만들 때 자동으로 정해지는 **UUID**(전 세계에서 겹치지 않는 긴 식별 번호)도 있습니다. 장치 이름이 바뀌어도 UUID 는 같아서 설정 파일(`/etc/fstab` 등)에서 많이 씁니다. `blkid 장치` 는 레이블·UUID·파일시스템 형식을 한 줄로 보여 줍니다.\n\n**문제** — `/tmp/lab/disk.img` 파일시스템의 **UUID 값만** 읽어 `/tmp/uuid.txt` 에 저장하세요. (값만, 한 줄. `UUID=` 나 따옴표는 빼세요)',
     '`blkid` 출력에서 UUID 값만 골라야 합니다. 필요한 부분만 출력하는 옵션이 있는지 `blkid --help` 를 보거나, 출력을 `grep`·`sed` 로 가공해도 됩니다.',
     "blkid /tmp/lab/disk.img\nblkid -s UUID -o value /tmp/lab/disk.img > /tmp/uuid.txt\ncat /tmp/uuid.txt\n\n# -s UUID 로 항목을 고르고 -o value 로 값만 출력한다",
     FS_UUID,
     [chk('UUID 값만 저장했다', f'[ "$(cat /tmp/uuid.txt)" = {UUID} ]')])

# 7 dumpe2fs
b.nt('dumpe2fs 로 블록 크기와 개수 읽기',
     '`dumpe2fs -h 장치` 는 ext4 파일시스템의 **기본 정보**(슈퍼블록: 파일시스템의 설계도 같은 맨 앞 영역)를 보여 줍니다. 파일시스템은 디스크를 **블록**이라는 일정한 크기 조각으로 나눠 씁니다. `Block size`(블록 하나의 크기, 바이트)와 `Block count`(블록 전체 개수)가 그 정보입니다.\n\n`/tmp/lab/disk.img`(8MiB)에 ext4 가 이미 만들어져 있습니다. (`-h` 는 앞부분 요약만 보는 옵션이라 출력이 짧습니다)\n\n**문제** — `Block size` 값을 `/tmp/bs.txt` 에, `Block count` 값을 `/tmp/blocks.txt` 에 저장하세요. (숫자만)',
     '`dumpe2fs -h` 출력에서 각 항목 이름이 있는 줄을 `grep` 으로 찾고, 마지막 칸(콜론 뒤 값)만 골라 쓰세요. 블록 수 x 블록 크기가 전체 크기와 맞는지도 계산해 보세요.',
     "dumpe2fs -h /tmp/lab/disk.img 2>/dev/null | egrep 'Block (size|count)'\ndumpe2fs -h /tmp/lab/disk.img 2>/dev/null | awk '/^Block size:/ {print $3}' > /tmp/bs.txt\ndumpe2fs -h /tmp/lab/disk.img 2>/dev/null | awk '/^Block count:/ {print $3}' > /tmp/blocks.txt\ncat /tmp/bs.txt /tmp/blocks.txt\n\n# 8MiB = 8388608 바이트 = 블록 8192개 x 1024 바이트",
     FS_BLK,
     [chk('블록 크기를 적었다', '[ "$(cat /tmp/bs.txt)" = 1024 ]'),
      chk('블록 개수를 적었다', '[ "$(cat /tmp/blocks.txt)" = 8192 ]')])

# 8 e2fsck
b.nt('e2fsck 로 파일시스템 점검하기',
     '`e2fsck` 는 ext4 파일시스템에 **깨진 곳이 없는지 점검**합니다. 점검은 **마운트하지 않은(언마운트된) 상태에서** 해야 안전합니다. 옵션 `-f` 는 "깨끗해 보여도 강제로 끝까지 점검", `-n` 은 "아무것도 고치지 않고 읽기만"(no) 입니다. 모두 "yes"로 고치는 `-y` 는 점검 결과를 확인한 뒤에 씁니다.\n\n`/tmp/lab/disk.img` 에 레이블이 `data` 인 ext4 가 있습니다.\n\n**문제** — 이 파일시스템을 **강제로, 고치지 않고** 점검하고, 그 **출력을** `/tmp/fsck.txt` 에 저장하세요. (출력에는 `Pass 1`~`Pass 5` 단계와 마지막에 `data: 11/...` 로 시작하는 요약 줄이 들어 있어야 합니다)',
     '`e2fsck` 에 강제 점검 옵션과 읽기만 하는 옵션을 같이 주고, 결과를 파일로 보내세요. 일부 버전은 메시지를 표준 출력으로 보냅니다. 빈 파일이 되었다면 어느 쪽 출력이 비었는지 확인해 보세요.',
     "e2fsck -f -n /tmp/lab/disk.img > /tmp/fsck.txt 2>&1\ncat /tmp/fsck.txt\n\n# 종료 코드 0 은 오류 없음이다. 요약 줄은 '레이블: 사용 inode/전체 inode files, 사용 블록/전체 블록 blocks' 형태다",
     FS_DATA,
     [chk('5단계 점검 출력이 저장됐다', 'grep -q "Pass 5" /tmp/fsck.txt'),
      chk('data 파일시스템 요약 줄이 있다', 'grep -q "^data: 11/" /tmp/fsck.txt')])

# 9 순서
b.order('파일시스템 사용 순서', '이미지 파일 하나를 디스크처럼 써서 파일을 저장하고 뺄 때의 **올바른 순서**로 카드를 놓으세요. (마운트할 폴더는 이미 있다고 가정합니다)',
        '쓸 수 있는 상태가 되기 전과 후, 뺄 때를 생각해 보세요. 안 만들어 둔 것은 마운트할 수 없고, 마운트된 것은 먼저 떼야 안전합니다.',
        ['`mount` 로 폴더에 연결하기', '`umount` 로 폴더에서 떼기', '`truncate` 로 이미지 파일 만들기', '연결된 폴더에 파일 저장하고 읽기', '`mkfs.ext4 -F` 로 파일시스템 만들기'], [2, 4, 0, 3, 1],
        '이미지 파일(장치) 준비 → `mkfs` 로 파일시스템 만들기 → `mount` 로 폴더에 연결 → 연결된 폴더에서 사용 → `umount` 로 안전하게 떼기 순서입니다. 파일시스템이 없으면 `mount` 가 `wrong fs type` 으로 실패하고, 마운트한 채 빼면 아직 디스크에 쓰지 못한 데이터를 잃을 수 있습니다. 샌드박스는 `mount` 를 막아 두어 이 순서는 읽기 문제로만 확인합니다.')

# 10 mount 빈칸
b.fill('만든 파일시스템을 폴더에 연결하기',
       '`/dev/sdb1` 에 `mkfs.ext4` 로 파일시스템을 만들었습니다. 이제 이 파일시스템을 **`/mnt/data` 폴더에 연결**해서 그 폴더 안에서 파일을 읽고 쓰려고 합니다. 연결하는 명령을 채우세요. (`/mnt/data` 폴더는 이미 있습니다. 연결 뒤 이 폴더를 열면 디스크의 내용이 보이고, 이 폴더를 **마운트 지점**이라고 부릅니다)',
       '"올려 놓다, 장착하다"를 뜻하는 영어 단어입니다. 떼는 명령은 반대로 un 이 붙습니다.',
       '{0} /dev/sdb1 /mnt/data', ['mount', 'umount', 'mkfs.ext4', 'e2fsck'], [0],
       '`mount 장치 마운트지점` 이 연결 명령입니다. `umount` 는 떼는 명령(철자에 n 이 없습니다), `mkfs.ext4` 는 파일시스템 만들기(데이터 삭제), `e2fsck` 는 점검입니다. 마운트 지점 폴더의 원래 내용은 연결된 동안 가려집니다.')

# 11 busy
b.choice('umount: target is busy',
         '작업을 마치고 디스크를 떼려는데 다음 오류가 납니다. 담당자가 `fuser -vm /mnt/data`(그 마운트 지점을 쓰는 프로세스 목록)를 실행해 둔 결과도 같이 있습니다.\n\n```\n$ umount /mnt/data\numount: /mnt/data: target is busy.\n\n$ fuser -vm /mnt/data\n                     USER   PID ACCESS COMMAND\n/mnt/data:           kim   2201 ..c.. bash\n                     root  3310 F.... rsync\n```\n\n(ACCESS 의 `c` 는 "현재 작업 폴더가 거기 안", `F` 는 "파일을 열고 있음" 입니다) 이 상황의 올바른 해석과 조치는 무엇일까요?',
         '"busy" 는 파일시스템이 고장 났다는 뜻이 아니라, 누군가 아직 쓰고 있다는 뜻입니다. 누가 쓰는지 목록에 나와 있습니다.',
         ['`bash` 가 그 폴더 안에 들어가 있고 `rsync` 는 파일을 쓰고 있으니, 폴더에서 나오고 `rsync` 를 마친 뒤 다시 `umount` 한다', '파일시스템이 깨져 있으니 `mkfs.ext4` 로 다시 만든다', '`rm -rf /mnt/data` 로 폴더를 지워서 해결한다', '`umount` 는 항상 한 번 실패하므로 같은 명령을 계속 반복한다'], 0,
         '`target is busy` 는 그 마운트 지점을 **프로세스가 쓰고 있어서** 뗄 수 없다는 뜻입니다. 위 결과에서 `bash` 는 작업 폴더가 `/mnt/data` 안이라서(`cd` 로 나오면 해결), `rsync` 는 파일을 열고 있어서(끝나길 기다리거나 정상 종료) 걸립니다. 사용 중인 걸 정리한 뒤 다시 `umount` 합니다. `mkfs` 는 데이터를 지우고, `rm -rf` 는 마운트된 디스크의 파일을 지우므로 둘 다 틀렸습니다. 강제(`umount -f`, `-l`)는 데이터 손실 위험이 있어 마지막 수단입니다.')

# 12 df -hT 읽기
b.choice('df -hT 로 마운트 확인하기',
         '마운트가 잘 됐는지 `df -hT`(`-T` 는 파일시스템 형식 열 추가) 로 확인했습니다.\n\n```\nFilesystem     Type  Size  Used Avail Use% Mounted on\n/dev/sda2      ext4   50G   21G   27G  44% /\n/dev/sdb1      xfs   200G  120G   80G  60% /data\n/dev/sdc1      ext4  100G   10G   90G  10% /backup\n```\n\n`/data` 폴더에 연결된 파일시스템의 **형식과 남은 용량**은 무엇일까요?',
         '`Mounted on` 열이 `/data` 인 줄을 찾고, 그 줄의 `Type` 과 `Avail`(남은 용량) 열을 보세요.',
         ['xfs, 80G 남음', 'ext4, 80G 남음', 'xfs, 120G 남음', 'ext4, 90G 남음'], 0,
         '`Mounted on` 이 `/data` 인 줄은 `/dev/sdb1`, `Type` 은 `xfs`, `Avail`(남은 용량)은 `80G` 입니다. `120G` 는 사용한(`Used`) 용량이고, `ext4`/`90G` 는 `/backup` 줄의 값입니다. `df` 에 마운트 지점이 보이면 연결된 상태이고, 보이지 않으면 연결되지 않은 것입니다.')

if __name__ == '__main__':
    preview(b)
