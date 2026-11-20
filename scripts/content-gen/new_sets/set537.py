# 세트 537: LVM 첫걸음. 명세: docs/specs/spec_gap_set537.md
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from gen_pilot_sets import *

# 샌드박스(linux)에는 lvm2·xfsprogs 가 없고 device-mapper 도 쓸 수 없다. LVM 출력은 파일로 읽고,
# ext4 확장(resize2fs)은 이미지 파일로 직접 해 본다.
BASE = CLEAN + "; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report"

PVS = BASE + r"""
cat > /tmp/report/pvs.txt <<'EOF'
  PV         VG      Fmt  Attr PSize   PFree
  /dev/sdb1  vg_data lvm2 a--  100.00g     0
  /dev/sdc1  vg_data lvm2 a--  100.00g 50.00g
  /dev/sdd1  vg_app  lvm2 a--  100.00g     0
  /dev/sde1  vg_log  lvm2 a--   50.00g     0
EOF
"""

VGS_LVS = BASE + r"""
cat > /tmp/report/vgs.txt <<'EOF'
  VG      #PV #LV #SN Attr   VSize   VFree
  vg_app    1   1   0 wz--n- 100.00g     0
  vg_data   2   2   0 wz--n- 200.00g 50.00g
  vg_log    1   1   0 wz--n-  50.00g     0
EOF
cat > /tmp/report/lvs.txt <<'EOF'
  LV    VG      Attr       LSize
  web   vg_app  -wi-ao---- 100.00g
  data  vg_data -wi-ao---- 120.00g
  logs  vg_data -wi-ao----  30.00g
  audit vg_log  -wi-ao----  50.00g
EOF
"""

DFT = BASE + r"""
cat > /tmp/report/df_T.txt <<'EOF'
Filesystem                Type  Size  Used Avail Use% Mounted on
/dev/mapper/vg_data-data  ext4  118G   90G   23G  80% /data
/dev/mapper/vg_data-logs  xfs    30G   28G  2.0G  94% /var/log/app
/dev/mapper/vg_app-web    ext4   99G   40G   54G  43% /web
/dev/mapper/vg_log-audit  xfs    50G   10G   40G  20% /audit
EOF
"""

IMG = BASE + "; truncate -s 64M /tmp/lab/disk.img; mkfs.ext4 -q -F /tmp/lab/disk.img"

b = SetBuilder(537, 'LVM 첫걸음: PV·VG·LV 개념과 확장 절차',
               'LVM 의 3계층(PV·VG·LV)을 이해하고, pvs·vgs·lvs 출력에서 여유 공간과 이름을 읽고, 만드는 순서(pvcreate → vgcreate → lvcreate → mkfs → mount)와 확장 순서(VG 여유 확인 → lvextend → 파일시스템 확장)를 익힙니다. ext4(resize2fs)와 xfs(xfs_growfs, 축소 불가)의 차이도 다룹니다. 샌드박스에서는 LVM 장치를 만들 수 없어 출력 파일 읽기와 이미지 파일 확장으로 연습합니다.',
               'linux', '리눅스', 4, 758, '🧱',
               [{"title": "lvm(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lvm.8.html"}, {"title": "lvextend(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lvextend.8.html"}], 3)

# 1 3계층 개념
b.choice('LVM 의 세 층',
         '디스크 공간이 모자랄 때마다 파티션을 다시 나누기는 번거롭습니다. LVM 은 디스크를 **물리 볼륨(PV) → 볼륨 그룹(VG) → 논리 볼륨(LV)** 세 층으로 추상화해 공간을 유연하게 씁니다. 각 층의 역할을 가장 알맞게 설명한 것은 무엇일까요?',
         '물탱크에 비유해 보세요. 재료, 모아 둔 곳, 잘라 쓰는 단위가 각각 무엇인지 생각합니다.',
         ['PV 는 디스크(재료), VG 는 PV 를 모아 둔 공용 저장소, LV 는 VG 에서 잘라 내 파일시스템을 올려 쓰는 단위', 'PV 는 파일시스템, VG 는 디스크, LV 는 마운트 지점', 'LV 는 디스크, VG 는 LV 를 모은 것, PV 는 그 위의 파일시스템', 'PV·VG·LV 는 모두 같은 층이고 이름만 다르다'], 0,
         'PV 는 LVM 에 맡긴 디스크·파티션, VG 는 PV 들을 한데 모은 **공용 풀**, LV 는 풀에서 필요한 만큼 잘라 낸 **사용 단위**입니다. 사용자는 LV 에 `mkfs` 로 파일시스템을 만들어 마운트합니다. 그래서 디스크를 더 붙여 VG 를 키우고 LV 를 늘리면 서비스 중단 없이 공간을 늘릴 수 있습니다.')

# 2 pvs 읽기
b.nt('pvs 출력에서 여유가 남은 디스크 찾기',
     '**상황** — 서버에 LVM 이 구성돼 있습니다. 담당자가 `pvs` 출력(물리 볼륨 목록)을 `/tmp/report/pvs.txt` 에 저장해 뒀습니다. 열은 `PV`(장치), `VG`(속한 볼륨 그룹), `PSize`(전체 크기), `PFree`(**아직 어느 LV 에도 안 쓴 여유**) 입니다. `0` 은 여유가 없다는 뜻입니다.\n\n**문제** — **PFree 가 0 이 아닌 PV 의 장치 이름**(예 `/dev/sdX1` 형태)을 `/tmp/pv_free.txt` 에 저장하세요. (값만, 한 줄)',
     '첫 줄은 제목입니다. `PFree` 는 마지막 열이니 `awk` 로 그 열이 `0` 이 아닌 줄만 고르고 첫 열을 출력해 보세요.',
     "cat /tmp/report/pvs.txt\nawk 'NR>1 && $6!=\"0\" {print $1}' /tmp/report/pvs.txt > /tmp/pv_free.txt\ncat /tmp/pv_free.txt\n\n# 제목 줄(NR==1)은 건너뛰고, PFree(6번째 열)가 0 이 아닌 줄의 장치(1번째 열)를 출력한다",
     PVS,
     [chk('여유가 남은 PV 를 적었다', '[ "$(cat /tmp/pv_free.txt)" = /dev/sdc1 ]')])

# 3 lvs 읽기
b.nt('lvs 출력에서 한 VG 의 LV 이름 뽑기',
     '이어서 `lvs`(논리 볼륨 목록) 출력이 `/tmp/report/lvs.txt` 에 있습니다. 열은 `LV`(이름), `VG`(속한 볼륨 그룹), `Attr`(속성), `LSize`(크기) 입니다. LV 는 `/dev/<VG이름>/<LV이름>` 경로로 접근합니다.\n\n**문제** — 볼륨 그룹 **`vg_data` 에 속한 LV 의 이름**을 한 줄에 하나씩, 이름순으로 `/tmp/lv_data.txt` 에 저장하세요. (VG 이름이나 크기는 빼고 LV 이름만)',
     '두 번째 열이 VG 이름인 줄만 골라 첫 열을 출력하세요. 이름순은 `sort` 로 맞춥니다.',
     "cat /tmp/report/lvs.txt\nawk '$2==\"vg_data\" {print $1}' /tmp/report/lvs.txt | sort > /tmp/lv_data.txt\ncat /tmp/lv_data.txt\n\n# VG 열이 vg_data 인 줄의 LV 이름(1번째 열)만 모은다",
     VGS_LVS,
     [chk('vg_data 의 LV 두 개를 이름순으로 적었다', '[ "$(cat /tmp/lv_data.txt)" = "$(printf "data\\nlogs")" ]')])

# 4 VG 여유 0
b.choice('VG 에 여유가 없을 때',
         '`vgs` 를 보니 `vg_app` 의 `VFree`(VG 여유)가 `0` 입니다. 그런데 `/web`(LV `web`)을 20G 늘려야 합니다. 이 상태에서 `lvextend -L +20G /dev/vg_app/web` 을 하면 `Insufficient free space` 오류가 납니다. 가장 알맞은 해결은 무엇일까요?',
         'LV 는 VG 의 여유 공간에서만 늘어납니다. 그 풀(VG) 자체를 먼저 키워야 합니다.',
         ['새 디스크를 `pvcreate` 로 PV 로 만들고 `vgextend` 로 VG 에 추가한 뒤 `lvextend` 를 한다', '`resize2fs` 를 먼저 실행해 파일시스템을 늘린다', '`lvcreate` 로 같은 이름의 LV 를 하나 더 만든다', '`mkfs` 를 다시 실행해 용량을 새로 계산한다'], 0,
         'LV 는 VG 의 여유(`VFree`)에서 떼어 와 늘어나므로, 여유가 없으면 VG 부터 키워야 합니다. 새 디스크를 `pvcreate` 로 초기화하고 `vgextend vg_app /dev/sdX` 로 VG 에 넣으면 `VFree` 가 생기고, 그 뒤 `lvextend` 가 됩니다. `resize2fs` 는 LV 가 먼저 커진 뒤에 파일시스템을 맞추는 단계이고, `mkfs` 는 기존 데이터를 지웁니다.')

# 5 만드는 순서
b.order('LV 를 만들어 쓰기까지의 순서', '새 디스크(`/dev/sdb`)로 LVM 볼륨을 만들어 `/data` 에 마운트하기까지의 올바른 순서로 카드를 놓으세요. (파일시스템은 LV 가 만들어진 다음에 올립니다)',
        '아래 층(재료)에서 위 층(사용)으로 올라갑니다. 파일시스템과 마운트는 맨 위 층 일입니다.',
        ['`mkfs.ext4` 로 LV 에 파일시스템 만들기', '`vgcreate` 로 PV 를 모아 VG 만들기', '`mount` 로 마운트하기', '`pvcreate` 로 디스크를 PV 로 초기화하기', '`lvcreate` 로 VG 에서 LV 잘라 내기'], [3, 1, 4, 0, 2],
        'PV(`pvcreate`) → VG(`vgcreate`) → LV(`lvcreate`) 로 층을 쌓고, LV 장치(`/dev/<VG>/<LV>`)에 `mkfs` 로 파일시스템을 만든 뒤 `mount` 합니다. 재부팅 후에도 쓰려면 `/etc/fstab` 에도 등록합니다.')

# 6 빈칸 lvcreate -n
b.fill('LV 이름 지정하기',
       'VG `vg_data` 에서 10G 짜리 LV 를 `data` 라는 이름으로 만들려고 합니다. LV 의 **이름을 지정하는 옵션**을 채우세요. (이 옵션이 없으면 `lvol0` 같은 자동 이름이 붙습니다)',
       'LV 이름을 정하는 옵션입니다. `lvcreate --help` 에서 \'name\' 을 찾아 보세요.',
       'lvcreate -L 10G {0} data vg_data', ['-n', '-s', '-t', '-y'], [0],
       '`lvcreate -n <이름>` 이 LV 이름을 정합니다. `-L` 은 크기, 마지막 인자는 LV 를 만들 VG 입니다. `-s` 는 스냅샷, `-t` 는 실제로 만들지 않는 시험 실행, `-y` 는 확인 질문에 모두 yes 로 답하는 옵션입니다.')

# 7 여유 계산
b.nt('늘릴 수 있는지 계산하기',
     '`/data`(LV `data`)에 20G 가 더 필요합니다. 이 LV 는 VG `vg_data` 에서 나옵니다. `vgs` 출력이 `/tmp/report/vgs.txt` 에 있고, `VFree` 열이 VG 의 남은 여유입니다.\n\n**문제** — `vg_data` 의 `VFree` 를 읽어, 20G 를 늘린 **뒤에 남을 여유**를 계산해 `/tmp/left.txt` 에 **숫자만**(단위 g 제외) 저장하세요. (남는 값이 음수라면 늘릴 수 없다는 뜻입니다)',
     '`vg_data` 줄에서 `VFree` 열을 읽고, `g` 단위를 뗀 숫자로 계산하세요. 계산 도구는 학습자가 고릅니다.',
     "cat /tmp/report/vgs.txt\nawk '$1==\"vg_data\" {print $NF+0-20}' /tmp/report/vgs.txt > /tmp/left.txt\ncat /tmp/left.txt\n\n# VFree(50.00g) - 20 = 30 이므로 늘릴 수 있다. 실제로는 lvextend -L +20G 를 실행한다",
     VGS_LVS,
     [chk('남을 여유를 적었다', '[ "$(awk \'{print $1+0}\' /tmp/left.txt)" = 30 ]')])

# 8 확장 순서
b.order('LV 확장 순서 (ext4)', '`/data`(ext4 파일시스템이 올라간 LV)를 서비스 중단 없이 20G 늘리는 올바른 순서로 카드를 놓으세요. (먼저 가능한지 확인하고, 아래 층부터 늘립니다)',
        '각 카드가 \'확인\'인지 \'바꾸기\'인지 구분하세요. 바꾸는 단계는 아래 층(LV)에서 위 층(파일시스템) 순입니다.',
        ['`lvextend -L +20G` 로 LV 늘리기', '`df -h` 로 늘어났는지 확인하기', '`resize2fs` 로 파일시스템 늘리기', '`vgs` 로 VG 의 여유(VFree) 확인하기'], [3, 0, 2, 1],
        '먼저 `vgs` 로 VG 에 여유가 있는지 확인하고, `lvextend` 로 LV 를 늘립니다. LV 만 커졌을 뿐 그 위의 파일시스템은 그대로이므로 `resize2fs`(ext4)로 파일시스템을 LV 크기에 맞추고, `df -h` 로 확인합니다. ext4 와 xfs 는 마운트된 채로 확대할 수 있습니다.')

# 9 빈칸 -r
b.fill('LV 와 파일시스템을 한 번에 늘리기',
       '순서대로 두 단계를 거치지 않고, `lvextend` 한 번으로 **LV 를 늘리면서 그 위의 파일시스템도 함께** 늘리게 하는 옵션을 채우세요.',
       '`lvextend --help` 에서 \'resizefs\'(파일시스템 크기 조정)를 찾아 보세요.',
       'lvextend -L +20G {0} /dev/vg_data/data', ['-r', '-t', '-v', '-y'], [0],
       '`lvextend -r`(`--resizefs`)는 LV 를 늘린 뒤 파일시스템 종류에 맞는 도구(`resize2fs` 또는 `xfs_growfs`)를 알아서 호출합니다. `-t` 는 시험 실행, `-v` 는 자세한 출력, `-y` 는 질문에 yes 로 답하는 옵션이라 파일시스템은 늘어나지 않습니다.')

# 10 ext4 vs xfs 명령
b.nt('파일시스템 종류별 확장 명령 고르기',
     'LV 를 늘린 뒤에는 **파일시스템 종류에 맞는 명령**으로 그 위의 파일시스템을 늘려야 합니다. ext2/3/4 는 `resize2fs`, xfs 는 `xfs_growfs` 를 씁니다. 서버의 `df -hT`(종류 포함, 사람이 읽는 단위) 출력이 `/tmp/report/df_T.txt` 에 있습니다.\n\n**문제** — 각 마운트 지점에 쓸 확장 명령을 `/tmp/grow.txt` 에 한 줄에 하나씩 `마운트지점 명령` 형태로 저장하세요. 예) `/data resize2fs`\n(`Type` 열이 ext4 면 `resize2fs`, xfs 면 `xfs_growfs`. 마운트 지점은 마지막 열입니다)',
     '제목 줄은 빼고, 각 줄의 `Type` 에 따라 명령을 고르세요. 한 줄씩 읽어 처리하는 방법은 학습자가 고릅니다.',
     "cat /tmp/report/df_T.txt\nawk 'NR>1 {print $NF, ($2==\"xfs\" ? \"xfs_growfs\" : \"resize2fs\")}' /tmp/report/df_T.txt > /tmp/grow.txt\ncat /tmp/grow.txt\n\n# 종류가 xfs 면 xfs_growfs, ext4 면 resize2fs",
     DFT,
     [chk('4개 줄이다', '[ "$(grep -c . /tmp/grow.txt)" = 4 ]'),
      chk('ext4 지점은 resize2fs 다', 'grep -qx "/data resize2fs" /tmp/grow.txt && grep -qx "/web resize2fs" /tmp/grow.txt'),
      chk('xfs 지점은 xfs_growfs 다', 'grep -qx "/var/log/app xfs_growfs" /tmp/grow.txt && grep -qx "/audit xfs_growfs" /tmp/grow.txt')])

# 11 resize2fs 직접
b.nt('resize2fs 로 파일시스템 직접 늘려 보기',
     '샌드박스에서는 LVM 장치를 만들 수 없지만, `resize2fs` 는 **이미지 파일**에도 똑같이 쓸 수 있습니다. `/tmp/lab/disk.img`(64MB)에 ext4 파일시스템이 만들어져 있습니다. 실제 LV 를 `lvextend` 로 키우는 것을 **이미지 파일 키우기**로 대신해 봅니다.\n\n**문제**\n1. 이미지 파일의 크기를 **128MB** 로 늘리세요. (`truncate -s 크기 파일`)\n2. 파일시스템 점검(`e2fsck -f -y 파일`)을 한 번 한 뒤, `resize2fs 파일` 로 파일시스템을 파일 크기에 맞게 늘리세요.\n\n(실제 서버에서는 마운트된 채로 `resize2fs` 만 해도 됩니다. 마운트 해제 상태의 오프라인 확장에서는 `e2fsck -f` 를 먼저 하라는 안내가 나옵니다)',
     '먼저 파일 자체를 키워야 합니다. 키운 뒤에 `resize2fs` 에 크기를 따로 주지 않으면 파일 끝까지 늘어납니다. `dumpe2fs -h 파일` 로 블록 수를 볼 수 있습니다.',
     "truncate -s 128M /tmp/lab/disk.img\ne2fsck -f -y /tmp/lab/disk.img\nresize2fs /tmp/lab/disk.img\ndumpe2fs -h /tmp/lab/disk.img 2>/dev/null | grep -E 'Block (count|size)'\n\n# LV 를 늘리는 것에 해당하는 것이 truncate, 파일시스템을 늘리는 것이 resize2fs. 크기를 안 주면 장치 끝까지 늘린다",
     IMG,
     [chk('이미지 파일이 128MB 이상이다', '[ "$(stat -c %s /tmp/lab/disk.img)" -ge 134217728 ]'),
      chk('파일시스템이 120MB 이상으로 늘어났다', 'dumpe2fs -h /tmp/lab/disk.img 2>/dev/null | awk \'/^Block count/{b=$3} /^Block size/{s=$3} END{exit !(b*s>=120*1024*1024)}\''),
      chk('파일시스템에 오류가 없다', 'e2fsck -fn /tmp/lab/disk.img >/dev/null 2>&1')])

# 12 xfs 축소
b.choice('xfs 는 줄일 수 있을까',
         '`/var/log/app`(LV `logs`, **xfs**)가 30G 로 너무 큰 것 같아 10G 로 줄여 VG 에 공간을 돌려주고 싶습니다. 이 xfs 파일시스템에 대해 가장 알맞은 설명은 무엇일까요?',
         'ext4 는 줄일 수 있지만 xfs 는 파일시스템 설계가 다릅니다. 먼저 `xfs_growfs` 의 이름이 무엇을 뜻하는지 생각해 보세요.',
         ['xfs 는 확장만 되고 축소가 안 되므로, 데이터를 백업한 뒤 작은 LV 를 새로 만들어 복원한다', '`xfs_shrinkfs` 로 마운트한 채 바로 줄일 수 있다', '`lvreduce` 만 하면 xfs 가 자동으로 같이 줄어든다', '`resize2fs` 로 줄이면 된다'], 0,
         'xfs 는 **확장만 가능하고 축소는 지원하지 않습니다**(`xfs_growfs` 는 있지만 줄이는 명령은 없습니다). 줄이려면 백업 → 작은 LV 로 새로 `mkfs.xfs` → 복원 순서로 해야 합니다. 파일시스템을 안 맞춘 채 `lvreduce` 만 하면 데이터가 손상될 수 있고, `resize2fs` 는 ext 계열 전용입니다. 그래서 줄일 일이 있을 법한 곳엔 ext4 가 편합니다.')

if __name__ == '__main__':
    preview(b)
