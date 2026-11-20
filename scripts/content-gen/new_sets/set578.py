import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 578: 파일시스템을 이미지 파일로 손연습. 명세: docs/specs/spec_gap_set578.md
# 샌드박스 linux(비특권, 마운트·루프 장치 불가). 일반 파일에 mke2fs·blkid·tune2fs·dumpe2fs·e2fsck·resize2fs·debugfs 를 쓰는 방식으로 파일시스템 생성·식별·확장·축소를 직접 해 본다.

S78 = """rm -f /tmp/*.img /tmp/*.txt /tmp/payload /tmp/out.dat
truncate -s 16M /tmp/grow.img; mke2fs -q -F -t ext4 /tmp/grow.img
dd if=/dev/urandom of=/tmp/payload bs=1k count=512 2>/dev/null
truncate -s 64M /tmp/shrink.img; mke2fs -q -F -t ext4 -b 1024 /tmp/shrink.img
debugfs -w -R "write /tmp/payload keep.dat" /tmp/shrink.img >/dev/null 2>&1
truncate -s 8M /tmp/old.img; mke2fs -q -F -t ext4 -L olddata /tmp/old.img
truncate -s 8M /tmp/pre.img; mke2fs -q -F -t ext4 -b 2048 /tmp/pre.img
true"""

b = SetBuilder(578, '파일시스템 손연습: 만들기, UUID·레이블, 블록 크기, 확장과 축소 (이미지 파일)',
               '디스크 대신 일반 파일에 ext4 파일시스템을 만들며 mke2fs·blkid·tune2fs·dumpe2fs·e2fsck·resize2fs 를 직접 써 봅니다. 파일시스템 만들기, 레이블과 UUID 확인·변경, 블록 크기 읽기, 확장과 축소(점검 → 크기 조정 순서)를 해 보고, 확장과 축소의 방향별 제약(XFS 는 축소 불가)을 정리합니다. 마운트 권한이 없어 이미지 파일을 대상으로 하는 방식입니다.',
               'linux', '스토리지', 70, 838, '🗄️',
               [{"title": "mke2fs 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/mke2fs.8.html"}, {"title": "resize2fs 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/resize2fs.8.html"}, {"title": "blkid 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/blkid.8.html"}], 5)

# 1
b.nt('이미지 파일에 파일시스템 만들기', '디스크 대신 일반 파일로 연습합니다. **`/tmp/disk.img`** 를 만들어 아래 조건을 모두 만족시키세요.\n- 파일 크기: **32MiB**\n- 파일시스템: **ext4**\n- 레이블(label): **data**',
     '파일 크기는 `truncate` 로 정합니다. 파일시스템 생성 도구는 파일에도 쓸 수 있고, 장치가 아니라는 확인을 건너뛰는 옵션과 레이블 옵션이 있습니다.',
     "truncate -s 32M /tmp/disk.img\nmke2fs -q -F -t ext4 -L data /tmp/disk.img\nblkid /tmp/disk.img\n\n# 실제 디스크에서는 /dev/sdb1 같은 장치에 한다. 파일시스템을 만들면 그 장치의 기존 데이터는 사라지므로 대상 확인이 가장 중요하다",
     S78, [chk('크기가 32MiB 다', '[ "$(stat -c %s /tmp/disk.img)" = 33554432 ]'), chk('ext4 다', '[ "$(blkid -s TYPE -o value /tmp/disk.img)" = ext4 ]'), chk('레이블이 data 다', '[ "$(blkid -s LABEL -o value /tmp/disk.img)" = data ]')])
# 2
b.nt('UUID 읽기', '`/etc/fstab` 에 장치를 적을 때는 장치 이름(`/dev/sdb1`)이 바뀔 수 있어 **UUID** 를 씁니다. `/tmp/pre.img` 파일시스템의 **UUID** 를 읽어 값만 `/tmp/uuid.txt` 에 저장하세요.',
     '블록 장치(또는 이미지)의 속성을 한 줄로 보여 주는 도구가 있습니다. 필요한 값만 출력하는 옵션도 있습니다.',
     "blkid /tmp/pre.img\nblkid -s UUID -o value /tmp/pre.img > /tmp/uuid.txt\ncat /tmp/uuid.txt\n\n# fstab 에는 UUID=... 로 적으면 디스크 순서가 바뀌어도 올바른 파일시스템이 마운트된다. nofail 옵션으로 없어도 부팅이 막히지 않게 한다",
     S78, [chk('실제 UUID 와 같다', '[ -n "$(cat /tmp/uuid.txt)" ] && [ "$(cat /tmp/uuid.txt)" = "$(blkid -s UUID -o value /tmp/pre.img)" ]')])
# 3
b.nt('레이블 바꾸기', '`/tmp/old.img` 의 파일시스템 레이블이 `olddata` 입니다. 이미 만들어진 파일시스템을 **다시 만들지 않고**(데이터를 지우지 않고) 레이블만 **archive** 로 바꾸세요.',
     'ext 계열 파일시스템의 설정을 나중에 바꾸는 도구가 있습니다. 새로 만드는 도구와 다릅니다.',
     "blkid /tmp/old.img\ne2label /tmp/old.img archive 2>/dev/null || tune2fs -L archive /tmp/old.img\nblkid -s LABEL -o value /tmp/old.img\n\n# mke2fs 는 새로 만들어 데이터가 사라진다. tune2fs 는 기존 파일시스템의 레이블·예약 블록·점검 주기 같은 속성만 바꾼다",
     S78, [chk('레이블이 archive 다', '[ "$(blkid -s LABEL -o value /tmp/old.img)" = archive ]'), chk('여전히 ext4 다', '[ "$(blkid -s TYPE -o value /tmp/old.img)" = ext4 ]')])
# 4
b.nt('블록 크기 읽기', '`/tmp/pre.img` 는 어떤 블록 크기로 만들어진 ext4 입니다. 파일시스템 정보에서 **블록 크기(`Block size`, 바이트)** 를 읽어 숫자만 `/tmp/bs.txt` 에 저장하세요.',
     '파일시스템의 슈퍼블록 정보를 보는 도구가 있습니다. 헤더만 보면 출력이 짧습니다.',
     "dumpe2fs -h /tmp/pre.img 2>/dev/null | grep -E 'Block size|Block count|Inode count'\ndumpe2fs -h /tmp/pre.img 2>/dev/null | awk '/^Block size/{print $3}' > /tmp/bs.txt\ncat /tmp/bs.txt\n\n# 파일시스템의 최소 할당 단위다. 1 바이트 파일도 블록 하나를 쓴다. 작은 파일이 많으면 낭비가 커서 블록 크기를 줄이기도 한다",
     S78, [chk('2048 이다', '[ "$(cat /tmp/bs.txt)" = 2048 ]')])
# 5
b.nt('파일시스템 확장', '`/tmp/grow.img` 는 16MiB 이미지에 만든 ext4 입니다. 공간이 모자라 디스크를 **64MiB** 로 키웠다고 가정하고, 이미지 파일을 64MiB 로 늘린 뒤 **파일시스템도 그 크기까지 확장**하세요. 파일시스템 점검에서 오류가 없어야 합니다.',
     '장치(이미지)를 키워도 파일시스템 크기는 그대로입니다. 확장 도구를 쓰기 전에 파일시스템을 강제로 점검해 두는 것이 안전합니다.',
     "truncate -s 64M /tmp/grow.img\ne2fsck -f -p /tmp/grow.img\nresize2fs /tmp/grow.img\ndumpe2fs -h /tmp/grow.img 2>/dev/null | grep -E 'Block count|Block size'\n\n# 실제로는 디스크·LV 를 먼저 키우고 그 위의 파일시스템을 확장하는 순서다. ext4 는 마운트한 채로도 확장할 수 있다(온라인 확장)",
     S78, [chk('파일시스템이 약 64MiB 다', 'BC=$(dumpe2fs -h /tmp/grow.img 2>/dev/null | awk \'/^Block count/{print $3}\'); BS=$(dumpe2fs -h /tmp/grow.img 2>/dev/null | awk \'/^Block size/{print $3}\'); [ $((BC * BS)) -ge 62914560 ]'), chk('점검 결과가 깨끗하다', 'e2fsck -fn /tmp/grow.img >/dev/null 2>&1')])
# 6
b.nt('파일시스템 축소', '`/tmp/shrink.img` 는 64MiB 파일시스템이고 `keep.dat` 파일이 들어 있습니다. 파일시스템을 **24MiB 로 줄이세요.** 줄인 뒤에도 `keep.dat` 의 내용은 그대로여야 하고, 점검에서 오류가 없어야 합니다. (축소는 데이터를 옮기는 작업이라 먼저 강제 점검을 해 두는 것이 안전합니다)',
     '축소 도구는 확장 도구와 같습니다. 크기를 인자로 줍니다. 데이터를 옮기기 전에 점검을 해 두면 안전합니다.',
     "e2fsck -f -p /tmp/shrink.img\nresize2fs /tmp/shrink.img 24M\ndumpe2fs -h /tmp/shrink.img 2>/dev/null | grep -E 'Block count|Block size'\ndebugfs -R 'ls -l' /tmp/shrink.img 2>/dev/null | grep keep.dat\n\n# ext4 는 언마운트한 상태에서만 줄일 수 있다(오프라인). 순서가 중요하다: 파일시스템을 먼저 줄이고 그다음 LV·파티션을 줄여야 한다. 반대로 하면 데이터가 잘린다. XFS 는 줄일 수 없다",
     S78, [chk('파일시스템이 24MiB 이하다', 'BC=$(dumpe2fs -h /tmp/shrink.img 2>/dev/null | awk \'/^Block count/{print $3}\'); BS=$(dumpe2fs -h /tmp/shrink.img 2>/dev/null | awk \'/^Block size/{print $3}\'); [ $((BC * BS)) -le 25165824 ] && [ $((BC * BS)) -ge 20971520 ]'), chk('점검 결과가 깨끗하다', 'e2fsck -fn /tmp/shrink.img >/dev/null 2>&1'), chk('keep.dat 가 그대로다', 'debugfs -R "dump keep.dat /tmp/out.dat" /tmp/shrink.img >/dev/null 2>&1 && cmp -s /tmp/out.dat /tmp/payload')])
# 7
b.choice('확장과 축소의 제약', '파일시스템을 줄일 필요가 생겼습니다. 다음 중 사실에 맞는 설명은?', '늘리는 것과 줄이는 것의 차이를 생각해 보세요.',
         ['ext4 는 언마운트 후 축소 가능, XFS 는 축소 불가', 'ext4 와 XFS 모두 마운트한 채로 자유롭게 줄일 수 있다', 'XFS 는 줄일 수 있지만 ext4 는 줄일 수 없다', '두 파일시스템 모두 늘리는 것도 줄이는 것도 불가능하다'], 0,
         'ext4 는 언마운트한 상태에서 점검 후 줄일 수 있고(resize2fs), 늘리는 것은 마운트한 채로도 됩니다. XFS 는 늘리기(xfs_growfs)만 되고 줄이기는 지원하지 않아, 줄여야 하면 백업 후 새로 만들어 복원합니다.')
# 8
b.choice('저널링의 목적', 'ext4 는 저널을 사용합니다. 저널링이 해 주는 일로 가장 알맞은 것은?', '정전·비정상 종료 뒤에 무엇이 빨라지는지 생각해 보세요.',
         ['비정상 종료 뒤 메타데이터를 빠르게 복구한다', '모든 파일을 자동으로 백업한다', '디스크 읽기 속도를 두 배로 만든다', '삭제한 파일을 영구 보관한다'], 0,
         '저널은 파일시스템 변경을 먼저 기록해 두는 로그입니다. 정전 같은 비정상 종료 뒤 저널을 재생해 메타데이터를 일관된 상태로 빠르게 되돌립니다(전체 점검이 필요 없음). 백업·속도 향상·삭제 복구용이 아닙니다.')
# 9
b.fill('강제 점검 옵션', '`resize2fs` 로 크기를 바꾸기 전에는 파일시스템이 깨끗하다고 해도 **강제로 점검**해 두는 것이 안전합니다(상태에 따라 도구가 요구하기도 합니다). 빈칸에 들어갈 `e2fsck` 옵션을 채우세요.', '`e2fsck` 는 파일시스템이 깨끗하다고 표시되어 있으면 검사를 건너뜁니다. 그래도 검사하게 만드는 옵션입니다.',
       'e2fsck -{0} /dev/vg0/data', ['f', 'n', 'y', 'v'], [0],
       '`-f` 는 깨끗하다고 표시되어 있어도 강제로 점검합니다. `-n` 은 읽기 전용(고치지 않고 확인만), `-y` 는 모든 질문에 yes, `-v` 는 자세히 출력하는 옵션입니다.')
# 10
b.order('ext4 파일시스템 확장 순서', '용량이 부족한 ext4 볼륨을 언마운트한 상태에서 키우려 합니다. 장치를 키운 뒤 점검과 확장을 거쳐 마지막에 크기를 확인하는 순서로 놓으세요.', '각 단계는 이전 단계의 결과에 의존합니다.',
        ['`resize2fs` 로 파일시스템을 장치 크기까지 확장한다', '`e2fsck -f` 로 파일시스템을 점검한다', '장치(디스크·LV·이미지)를 먼저 키운다', '`df`·`dumpe2fs` 로 확장된 크기를 확인한다'], [2, 1, 0, 3],
        '파일시스템은 장치 크기까지만 쓸 수 있으므로 장치를 먼저 키웁니다. 확장 전에 점검해 이상이 없는지 확인한 뒤 resize2fs 로 늘리고, 마지막에 크기를 확인합니다.')

if __name__ == '__main__':
    preview(b)
