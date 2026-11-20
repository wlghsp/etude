# 세트 536: fstab 영구 마운트와 스왑 파일 만들기. 명세: docs/specs/spec_gap_set536.md
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from gen_pilot_sets import *

# 샌드박스는 비특권이라 mount·swapon 이 막혀 있다(Operation not permitted).
# fstab 은 연습용 사본 파일을 편집하고, 스왑 파일은 만들기(fallocate·chmod·mkswap)까지 직접 하며, 켜기·마운트는 읽기형 문제로 대체한다.
BASE = CLEAN + "; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report"

U_A = '5d2c9f1e-3b7a-4c1d-9e0a-1f6b8a7c2d01'
U_B = '8e41a7c3-92d0-4f55-b3a6-7c10e9d4f802'
U_C = 'c7f03b9a-1e64-48b2-a5d7-02be3f6a9c53'

FSTAB_READ = BASE + f"""
cat > /tmp/lab/fstab <<'EOF'
# <장치> <마운트 지점> <형식> <옵션> <dump> <pass>
UUID={U_A} / ext4 defaults 0 1
UUID={U_B} /data xfs defaults,noatime 0 2
UUID={U_C} /backup ext4 defaults,nofail 0 2
EOF
"""

FSTAB_DEV = BASE + f"""
cat > /tmp/report/blkid.txt <<'EOF'
/dev/sda2: UUID="{U_A}" TYPE="ext4"
/dev/sdb1: UUID="{U_B}" TYPE="ext4"
/dev/sdc1: UUID="{U_C}" TYPE="ext4"
EOF
cat > /tmp/lab/fstab <<'EOF'
# <장치> <마운트 지점> <형식> <옵션> <dump> <pass>
UUID={U_A} / ext4 defaults 0 1
/dev/sdb1 /data ext4 defaults 0 2
/dev/sdc1 /backup ext4 defaults,nofail 0 2
EOF
"""

FSTAB_BROKEN = BASE + f"""
cat > /tmp/lab/fstab <<'EOF'
# <장치> <마운트 지점> <형식> <옵션> <dump> <pass>
UUID={U_A} / ext4 defaults 0 1
UUID={U_B} /data xfs defaults,noatime 0
UUID={U_C} /backup ext4 defaults nofail 0 2
EOF
"""

FREE = BASE + r"""
cat > /tmp/report/free.txt <<'EOF'
               total        used        free      shared  buff/cache   available
Mem:            7961        3120         812         210        4028        4330
Swap:           2047        1530         517
EOF
"""

SWAP_READY = BASE + f"""
fallocate -l 32M /tmp/lab/swapfile; chmod 600 /tmp/lab/swapfile; mkswap /tmp/lab/swapfile >/dev/null
cat > /tmp/lab/fstab <<'EOF'
# <장치> <마운트 지점> <형식> <옵션> <dump> <pass>
UUID={U_A} / ext4 defaults 0 1
UUID={U_B} /data xfs defaults,noatime 0 2
EOF
"""

b = SetBuilder(536, 'fstab 영구 마운트와 스왑 파일 만들기',
               '재부팅해도 디스크가 자동으로 붙게 하는 /etc/fstab 을 6개 열로 읽고, 장치 이름 대신 UUID 로 적는 이유와 defaults·noatime·nofail 옵션을 익힙니다. 줄을 잘못 적으면 부팅에 어떤 영향이 있는지 확인하고 문법 오류를 고칩니다. 스왑이 하는 일과 free 출력을 읽는 법, 스왑 파일을 만드는 절차(파일 생성, 권한 600, mkswap, swapon, fstab 등록)를 직접 따라 합니다.',
               'linux', '리눅스', 4, 757, '💾',
               [{"title": "fstab(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}, {"title": "swapon(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/swapon.8.html"}], 3)

# 1 6열 읽기
b.nt('fstab 한 줄은 6개 열이다',
     '`/etc/fstab` 은 "부팅할 때 어떤 디스크를 어디에 붙일지" 적어 두는 설정 파일입니다. `#` 으로 시작하는 줄은 설명이고, 나머지는 한 줄에 **공백으로 나뉜 6개 열**입니다.\n\n`1 장치` `2 마운트 지점`(붙일 폴더) `3 파일시스템 형식` `4 옵션`(`defaults` 는 기본 옵션 묶음) `5 dump`(옛 백업 도구용, 보통 0) `6 pass`(부팅 때 파일시스템 검사 순서: 루트는 1, 나머지는 2, 검사 안 함은 0)\n\n연습용 사본 `/tmp/lab/fstab` 을 읽고 **`/data` 줄**에서 **3열(형식)** 을 `/tmp/fstype.txt` 에, **6열(pass)** 을 `/tmp/pass.txt` 에 저장하세요. (값만)',
     '`awk` 는 열을 `$1`, `$2` ... 로 부르고, 조건에 맞는 줄만 골라 `{print $번호}` 할 수 있습니다. 마운트 지점은 2열입니다.',
     "cat /tmp/lab/fstab\nawk '$2==\"/data\" {print $3}' /tmp/lab/fstab > /tmp/fstype.txt\nawk '$2==\"/data\" {print $6}' /tmp/lab/fstab > /tmp/pass.txt\ncat /tmp/fstype.txt /tmp/pass.txt\n\n# awk 의 $3 = 형식 열, $6 = pass 열",
     FSTAB_READ,
     [chk('형식을 적었다', '[ "$(cat /tmp/fstype.txt)" = xfs ]'),
      chk('pass 값을 적었다', '[ "$(cat /tmp/pass.txt)" = 2 ]')])

# 2 UUID 이유
b.choice('장치 이름 대신 UUID 로 적는 이유',
         'fstab 의 첫 열에는 `/dev/sdb1` 같은 장치 이름도 쓸 수 있지만, 서버에서는 보통 `UUID=...` 로 적습니다. 그 이유는 무엇일까요?',
         '디스크를 한 개 더 꽂거나 연결 순서가 달라지면 `sdb`, `sdc` 가 어떻게 될지 생각해 보세요.',
         ['`/dev/sdb1` 같은 장치 이름은 디스크를 추가하거나 부팅 순서가 바뀌면 다른 디스크를 가리킬 수 있지만, UUID 는 그 파일시스템 자체에 붙어 있어 바뀌지 않는다', 'UUID 로 적으면 마운트 속도가 훨씬 빨라진다', 'UUID 는 사용자 비밀번호 역할을 해서 다른 사람이 마운트하지 못하게 한다', '`/dev/sdb1` 형태로는 fstab 에 쓸 수 없고 UUID 만 허용된다'], 0,
         '`sda`, `sdb` 같은 이름은 커널이 디스크를 발견한 순서대로 붙여서, 디스크를 추가하거나 연결 순서가 바뀌면 이름이 달라질 수 있습니다. 그러면 엉뚱한 디스크가 `/data` 에 붙을 수 있습니다. UUID 는 파일시스템을 만들 때 그 안에 기록되는 고유 번호라 이름이 바뀌어도 같은 디스크를 정확히 찾습니다. 속도나 보안과는 관계가 없고, 장치 이름도 문법상 쓸 수는 있습니다. (UUID 는 `blkid` 로 확인합니다)')

# 3 장치 이름 -> UUID
b.nt('장치 이름 줄을 UUID 줄로 바꾸기',
     '`/tmp/lab/fstab` 의 `/data` 줄이 `/dev/sdb1` 장치 이름으로 적혀 있습니다. 디스크를 추가하면 이 이름이 바뀔 수 있어 위험합니다. `blkid` 명령의 결과를 저장해 둔 `/tmp/report/blkid.txt` 에서 해당 디스크의 UUID 를 찾아, **`/data` 줄의 첫 열만 `UUID=<값>` 으로 바꾸세요.** 줄의 나머지 열과 다른 줄은 그대로 둡니다.',
     '`blkid.txt` 에서 장치 이름이 `/dev/sdb1` 인 줄의 `UUID="..."` 부분을 보세요. 따옴표는 fstab 에 쓰지 않습니다. `sed -i` 로 그 줄만 바꾸거나 편집기로 고칩니다.',
     f"cat /tmp/report/blkid.txt\nsed -i 's#^/dev/sdb1 #UUID={U_B} #' /tmp/lab/fstab\ncat /tmp/lab/fstab\n\n# blkid 의 UUID 값(따옴표 제외)을 첫 열에 넣는다. 나머지 열은 그대로",
     FSTAB_DEV,
     [chk('/data 줄의 장치가 blkid 의 UUID 다', f'[ "$(awk \'$2=="/data" {{print $1}}\' /tmp/lab/fstab)" = "UUID={U_B}" ]'),
      chk('/data 줄의 나머지 열은 그대로다', '[ "$(awk \'$2=="/data" {print $2,$3,$4,$5,$6}\' /tmp/lab/fstab)" = "/data ext4 defaults 0 2" ]'),
      chk('다른 줄은 바뀌지 않았다', f'grep -qx "UUID={U_A} / ext4 defaults 0 1" /tmp/lab/fstab && grep -qx "/dev/sdc1 /backup ext4 defaults,nofail 0 2" /tmp/lab/fstab')])

# 4 noatime 빈칸
b.fill('읽을 때마다 시각을 기록하지 않기',
       '파일을 읽을 때마다 "마지막 접근 시각(atime)"을 디스크에 기록하면 쓰기가 늘어납니다. 기본 옵션 묶음 `defaults` 에 **접근 시각을 기록하지 않는 옵션**을 덧붙이려고 합니다. 4열에 들어갈 값을 채우세요.',
       '옵션 이름은 \'접근 시각(access time)\'을 줄인 단어가 들어 있고, \'기록하지 않기\'를 뜻하는 접두어가 붙습니다. 보기 중 이름만 읽고 골라 보세요.',
       'UUID=8e41... /data xfs defaults,{0} 0 2', ['noatime', 'nofail', 'noexec', 'ro'], [0],
       '`noatime` 은 파일을 읽어도 접근 시각을 갱신하지 않아 불필요한 디스크 쓰기를 줄입니다. 옵션은 쉼표로 이어 쓰고 공백을 넣지 않습니다. `nofail` 은 디스크가 없어도 부팅을 계속하는 옵션, `noexec` 는 그 위의 프로그램 실행을 막는 옵션, `ro` 는 읽기 전용 마운트입니다.')

# 5 오기와 부팅 영향
b.choice('fstab 을 잘못 적으면 부팅이 어떻게 될까',
         '새 디스크를 `/data` 에 붙이려고 fstab 에 줄을 추가했는데, UUID 를 한 글자 틀리게 적고 **재부팅**했습니다. 이 줄에는 `nofail` 옵션이 없습니다. 어떤 일이 생길 가능성이 가장 높을까요?',
         '부팅 때 시스템은 fstab 의 줄을 "반드시 붙어야 하는 것"으로 다룹니다. 옵션에 예외가 없다면 어떻게 될까요.',
         ['없는 UUID 의 디스크를 찾지 못해 마운트가 실패하고, 부팅이 중단되어 긴급(emergency) 모드로 들어갈 수 있다', '잘못된 줄은 자동으로 무시되어 부팅은 정상이다', '시스템이 알아서 가장 비슷한 UUID 의 디스크를 붙여 준다', '서버가 자동으로 fstab 을 이전 버전으로 되돌린다'], 0,
         'fstab 에 적힌 마운트는 `nofail` 이 없으면 부팅에 필요한 것으로 취급됩니다. 존재하지 않는 UUID 는 마운트에 실패하고, 부팅이 멈춰 긴급(emergency) 모드의 쉘로 떨어질 수 있습니다. 원격 서버는 콘솔 접근이 없으면 곤란해집니다. 그래서 fstab 을 수정한 뒤에는 재부팅 전에 문법과 마운트를 점검하고(`mount -a`), 꼭 필요하지 않은 디스크에는 `nofail` 을 붙입니다. 시스템은 잘못된 줄을 무시하지도, 비슷한 디스크를 대신 붙이지도, 되돌리지도 않습니다.')

# 6 열 개수 고치기
b.nt('열이 모자라거나 넘치는 줄 고치기',
     '재부팅 전에 `/tmp/lab/fstab` 사본을 점검합니다. 설명이 아닌 줄은 **정확히 6개 열**이어야 하는데, 두 줄이 문법이 틀렸습니다. 열 개수 검사는 `awk` 의 `NF`(한 줄의 열 개수)로 할 수 있습니다.\n\n두 줄을 고치세요. `/data` 줄은 열이 빠졌으니 **pass 를 2** 로 채우고, `/backup` 줄은 옵션을 `defaults,nofail` 로 올바르게 쓰세요. (옵션은 공백 없이 쉼표로 잇습니다) 다른 줄은 그대로 둡니다.',
     '`awk \'!/^#/ && NF!=6\' /tmp/lab/fstab` 처럼 6열이 아닌 줄만 출력해 보세요. 어느 줄은 열이 모자라고 어느 줄은 넘칩니다.',
     "awk '!/^#/ && NF!=6' /tmp/lab/fstab\nsed -i 's#^\\(UUID=" + U_B + " /data xfs defaults,noatime 0\\)$#\\1 2#' /tmp/lab/fstab\nsed -i 's/defaults nofail/defaults,nofail/' /tmp/lab/fstab\nawk '!/^#/ && NF!=6' /tmp/lab/fstab\ncat /tmp/lab/fstab\n\n# 5열짜리는 pass 를 채우고, 7열짜리(공백으로 끊긴 옵션)는 쉼표로 잇는다",
     FSTAB_BROKEN,
     [chk('설명이 아닌 모든 줄이 6열이다', '[ -z "$(awk \'!/^#/ && NF && NF!=6\' /tmp/lab/fstab)" ]'),
      chk('/data 줄의 pass 가 2 다', f'grep -qx "UUID={U_B} /data xfs defaults,noatime 0 2" /tmp/lab/fstab'),
      chk('/backup 줄의 옵션이 defaults,nofail 이다', f'grep -qx "UUID={U_C} /backup ext4 defaults,nofail 0 2" /tmp/lab/fstab'),
      chk('루트 줄은 그대로다', f'grep -qx "UUID={U_A} / ext4 defaults 0 1" /tmp/lab/fstab')])

# 7 스왑 역할
b.choice('스왑은 무슨 일을 할까',
         '서버의 `free` 결과에 `Swap` 줄이 있습니다. 스왑(swap)의 역할을 가장 알맞게 설명한 것은 무엇일까요?',
         '메모리(RAM)가 부족할 때 시스템이 "당장 안 쓰는 것"을 어디에 잠시 치워 둘지 생각해 보세요.',
         ['메모리가 부족할 때 당장 쓰지 않는 메모리 내용을 디스크로 옮겨 두어, 메모리 공간을 확보하는 영역이다', '디스크가 가득 찼을 때 파일을 임시로 보관하는 영역이다', 'CPU 사용량이 높을 때 일을 나눠 맡는 보조 프로세서다', '네트워크 패킷을 저장해 두는 버퍼다'], 0,
         '스왑은 RAM 이 모자랄 때 당장 쓰지 않는 메모리 페이지를 디스크로 내려 보내 RAM 을 비우는 공간입니다. 갑자기 메모리가 부족해 프로세스가 강제 종료되는 일(OOM)을 늦춰 주지만, 디스크는 RAM 보다 훨씬 느려서 스왑을 많이 쓰면 서버가 눈에 띄게 느려집니다. 디스크 용량 부족이나 CPU, 네트워크와는 관계가 없습니다.')

# 8 free 읽기
b.nt('free 출력에서 스왑 읽기',
     '`free -m`(MiB 단위) 결과가 `/tmp/report/free.txt` 에 있습니다. `Mem` 줄은 RAM, `Swap` 줄은 스왑입니다. 열은 `total`(전체) `used`(사용 중) `free`(비어 있음) 등입니다.\n\n**스왑의 전체 크기(total)** 를 `/tmp/swap_total.txt` 에, **스왑에서 사용 중인 양(used)** 을 `/tmp/swap_used.txt` 에 저장하세요. (숫자만)',
     '`Mem:` 줄이 아니라 `Swap:` 줄입니다. `awk \'/^Swap:/ {print $열번호}\'` 로 뽑을 수 있고, 첫 열은 `Swap:` 이라는 글자입니다.',
     "cat /tmp/report/free.txt\nawk '/^Swap:/ {print $2}' /tmp/report/free.txt > /tmp/swap_total.txt\nawk '/^Swap:/ {print $3}' /tmp/report/free.txt > /tmp/swap_used.txt\ncat /tmp/swap_total.txt /tmp/swap_used.txt\n\n# 첫 열은 'Swap:' 이므로 total 은 2열, used 는 3열이다. 스왑을 이만큼 쓰고 있으면 메모리가 빠듯하다는 신호다",
     FREE,
     [chk('스왑 전체 크기를 적었다', '[ "$(cat /tmp/swap_total.txt)" = 2047 ]'),
      chk('스왑 사용량을 적었다', '[ "$(cat /tmp/swap_used.txt)" = 1530 ]')])

# 9 스왑 파일 만들기
b.nt('스왑 파일 만들기: 파일, 권한 600, mkswap',
     '디스크를 새로 나누지 않아도 **일반 파일을 스왑으로 쓸 수 있습니다.** 연습으로 `/tmp/lab/swapfile` 에 만들어 봅니다. (실제 서버에서는 보통 `/swapfile` 에 만들고 `swapon` 으로 켜지만, 이 실습 환경은 권한이 없어 켜기(`swapon`)는 할 수 없습니다)\n\n1. **32MiB 크기**의 파일을 만듭니다. (`fallocate -l 32M 파일` 로 크기만큼 공간을 확보합니다)\n2. 다른 사용자가 읽지 못하도록 **권한을 600** 으로 바꿉니다. (스왑에는 메모리 내용이 담기므로 root 만 읽어야 합니다)\n3. `mkswap 파일` 로 스왑 형식으로 **포맷**합니다.',
     '크기를 만드는 명령 → 권한 변경 명령 → 포맷 명령 순입니다. 권한은 포맷 전에 정리해 두면 `mkswap` 이 경고하지 않습니다.',
     "fallocate -l 32M /tmp/lab/swapfile\nchmod 600 /tmp/lab/swapfile\nmkswap /tmp/lab/swapfile\nls -l /tmp/lab/swapfile\n\n# 32M 은 33554432 바이트. 권한이 600 이 아니면 mkswap·swapon 이 insecure permissions 경고를 낸다",
     BASE,
     [chk('크기가 32MiB 다', '[ "$(stat -c %s /tmp/lab/swapfile)" = 33554432 ]'),
      chk('권한이 600 이다', '[ "$(stat -c %a /tmp/lab/swapfile)" = 600 ]'),
      chk('스왑 형식으로 포맷됐다', 'grep -aq SWAPSPACE2 /tmp/lab/swapfile')])

# 10 순서
# 정답 순서: fallocate → chmod 600 → mkswap → swapon → fstab
b.order('스왑 파일을 만들어 영구 적용하는 순서', '스왑 파일을 만들어 **지금 켜고**, 재부팅 뒤에도 유지되게 하는 올바른 순서로 카드를 놓으세요. (파일이 있어야 권한을 바꿀 수 있고, 권한을 닫은 뒤 포맷합니다. fstab 등록은 켜기를 확인한 뒤 마지막에 합니다)',
        '각 단계가 앞 단계의 결과물을 필요로 하는지 확인해 보세요. 파일이 있어야 권한을 바꿀 수 있고, 켜는 것과 영구 등록하는 것은 다른 일입니다.',
        ['`mkswap /swapfile` 로 스왑 형식 포맷', '`/etc/fstab` 에 `/swapfile none swap sw 0 0` 줄 추가', '`fallocate -l 2G /swapfile` 로 파일 생성', '`swapon /swapfile` 로 스왑 켜기', '`chmod 600 /swapfile` 로 권한 제한'], [2, 4, 0, 3, 1],
        '파일을 만든 다음(`fallocate`) 권한을 600 으로 제한하고(`chmod`) 스왑 형식으로 포맷(`mkswap`)한 뒤 `swapon` 으로 지금 켭니다. 마지막에 `/etc/fstab` 에 줄을 추가해야 재부팅해도 다시 켜집니다. 권한을 열어 둔 채 켜면 다른 사용자가 메모리 내용을 읽을 수 있어 `swapon` 이 경고합니다.')

# 11 fstab 에 스왑 등록
b.nt('스왑 파일을 fstab 에 등록하기',
     '`/tmp/lab/swapfile` 은 이미 만들고 `mkswap` 까지 끝난 상태입니다. 재부팅 뒤에도 자동으로 켜지게 하려면 fstab 에 한 줄을 추가해야 합니다. 스왑 줄은 마운트 지점이 없으므로 **2열에 `none`, 3열(형식)에 `swap`, 4열(옵션)에 `sw`**, dump 와 pass 는 **둘 다 0** 으로 적습니다.\n\n`/tmp/lab/fstab` 사본 **맨 아래에 스왑 줄을 추가**하세요. (장치 열에는 스왑 파일의 경로를 씁니다. 기존 줄은 지우지 않습니다)',
     '6열을 하나씩 채워 보세요: 장치(파일 경로) → 마운트 지점 → 형식 → 옵션 → dump → pass. 기존 줄에 덧붙이려면 `>>` 를 씁니다.',
     "echo '/tmp/lab/swapfile none swap sw 0 0' >> /tmp/lab/fstab\ncat /tmp/lab/fstab\nawk '!/^#/ && NF!=6' /tmp/lab/fstab\n\n# 스왑은 붙일 폴더가 없어 2열이 none 이다. >> 는 기존 내용 뒤에 덧붙인다",
     SWAP_READY,
     [chk('스왑 줄이 6열로 적혔다', '[ "$(awk \'$1=="/tmp/lab/swapfile" {print $2,$3,$4,$5,$6}\' /tmp/lab/fstab)" = "none swap sw 0 0" ]'),
      chk('기존 두 줄은 그대로다', f'grep -qx "UUID={U_A} / ext4 defaults 0 1" /tmp/lab/fstab && grep -qx "UUID={U_B} /data xfs defaults,noatime 0 2" /tmp/lab/fstab')])

# 12 재부팅 뒤 스왑 사라짐
b.choice('재부팅했더니 스왑이 사라졌다',
         '어제 `fallocate` → `chmod 600` → `mkswap` → `swapon /swapfile` 로 스왑 파일을 만들어 `free -h` 에서 Swap 이 보였습니다. 서버를 재부팅한 뒤 `free -h` 의 Swap 이 `0B` 입니다. `/swapfile` 파일은 그대로 있습니다. 가장 가능성이 높은 원인은 무엇일까요?',
         '`swapon` 은 "지금 켜는" 명령입니다. 부팅 때 다시 켜 주려면 어떤 설정 파일이 있어야 할까요.',
         ['`swapon` 은 현재 부팅에만 적용되므로, `/etc/fstab` 에 스왑 줄을 등록하지 않아 부팅 때 켜지지 않았다', '`mkswap` 의 효과는 재부팅하면 모두 사라진다', '스왑 파일은 재부팅 때마다 자동으로 삭제된다', '`chmod 600` 이 재부팅 때 `777` 로 바뀌어 스왑이 거부됐다'], 0,
         '`swapon` 은 지금 실행 중인 시스템에서 스왑을 켜는 명령이라 재부팅하면 풀립니다. 부팅 때 자동으로 켜려면 `/etc/fstab` 에 `/swapfile none swap sw 0 0` 줄이 있어야 합니다. `mkswap` 으로 입힌 형식은 파일에 남아 있고, 파일도 삭제되지 않으며, 권한도 저절로 바뀌지 않습니다. 줄을 추가한 뒤에는 `swapon --show`(또는 `free -h`)로 켜졌는지 확인합니다.')

if __name__ == '__main__':
    preview(b)
