import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 598: 스토리지 장애 상황집(LVM·RAID·NFS). 명세: docs/specs/spec_gap_set598.md
# 샌드박스 linux(비특권, LVM·mdadm·NFS 없음). 현장에서 모은 출력(샘플)을 읽고 원인을 좁힌다.

S98 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/vgs_warn.log <<'EOF'
  WARNING: Couldn't find device with uuid aB3dEf-0000-1111-2222-3333-4444-5555Gh.
  WARNING: VG vg0 is missing PV aB3dEf-0000-1111-2222-3333-4444-5555Gh (last written to /dev/sdc).
  VG  #PV #LV #SN Attr   VSize   VFree
  vg0   3   2   0 wz-pn- 299.99g 129.99g
EOF
cat > /tmp/lvs_state.log <<'EOF'
  LV   VG  Attr       LSize
  data vg0 -wi-------  150.00g
  logs vg0 -wi-ao----   20.00g
EOF
cat > /tmp/boot_md.log <<'EOF'
Personalities : [raid1]
md0 : active (auto-read-only) raid1 sdb1[0]
      104792064 blocks super 1.2 [2/1] [U_]
      bitmap: 1/1 pages [4KB], 65536KB chunk

unused devices: <none>
EOF
cat > /tmp/nfs_hang.log <<'EOF'
$ df -h
(응답 없이 멈춤. Ctrl-C 로 중단)
$ mount | grep nfs
nfs01.example.com:/data on /mnt/data type nfs4 (rw,relatime,vers=4.2,hard,timeo=600,retrans=2,sec=sys)
$ dmesg | tail -2
nfs: server nfs01.example.com not responding, still trying
nfs: server nfs01.example.com not responding, still trying
EOF
true"""

b = SetBuilder(598, '스토리지 장애 상황집(2): VG 의 PV 누락, 비활성 LV, 성능 저하 RAID, 멈춘 NFS',
               'LVM·RAID·NFS 장애를 현장 출력(샘플)에서 읽고 원인을 좁히는 상황집입니다. VG 에서 사라진 PV 와 `p` 속성, 활성화되지 않은 LV 와 활성화 명령, 부팅 뒤 한쪽 디스크만 남은 RAID, 서버 응답이 없어 df 까지 멈추는 NFS hard 마운트를 짚고, 데이터부터 지키는 대응 순서를 정리합니다. 샌드박스에는 해당 서비스가 없어 샘플 출력을 읽는 방식입니다.',
               'linux', '스토리지', 21, 858, '🧯',
               [{"title": "LVM 복구", "url": "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_logical_volumes/index"}, {"title": "mdadm 문서", "url": "https://raid.wiki.kernel.org/index.php/A_guide_to_mdadm"}], 5)

b.nt('누락된 PV 의 UUID', '`/tmp/vgs_warn.log` 는 `vgs` 실행 때 나온 출력입니다. 경고에 **찾을 수 없는 장치의 UUID** 가 나옵니다. 이 UUID 를 한 번만 `/tmp/missing_uuid.txt` 에 저장하세요. (UUID 만)',
     '`uuid` 바로 뒤의 문자열이고 끝의 마침표는 UUID 가 아닙니다. 첫 경고 줄에서 뽑으세요.',
     "cat /tmp/vgs_warn.log\ngrep -m1 'with uuid' /tmp/vgs_warn.log | awk '{print $NF}' | tr -d '.' > /tmp/missing_uuid.txt\ncat /tmp/missing_uuid.txt\n\n# 디스크(PV)가 연결되지 않았거나 고장나서 VG 가 완전하지 않다. 케이블·컨트롤러부터 확인하고 PV 가 돌아오면 vgextend --restoremissing 등으로 복구한다",
     S98, [chk('UUID 가 맞다', '[ "$(cat /tmp/missing_uuid.txt)" = "aB3dEf-0000-1111-2222-3333-4444-5555Gh" ]')])
b.nt('VG 속성 읽기', '같은 출력의 `Attr` 열 `wz-pn-` 은 VG 의 상태를 글자별로 나타냅니다. **네 번째 글자 `p`** 는 **partial**(일부 PV 누락)을 뜻합니다. `VG` 의 **PV 개수(`#PV`)와 LV 개수(`#LV`)** 를 각각 `/tmp/pv.txt`, `/tmp/lv.txt` 에 숫자만 저장하세요.',
     '`vg0` 로 시작하는 줄에서 두 번째, 세 번째 칸입니다.',
     "grep '^  vg0' /tmp/vgs_warn.log\ngrep '^  vg0' /tmp/vgs_warn.log | awk '{print $2}' > /tmp/pv.txt\ngrep '^  vg0' /tmp/vgs_warn.log | awk '{print $3}' > /tmp/lv.txt\ncat /tmp/pv.txt /tmp/lv.txt\n\n# 3 개의 PV 중 하나가 없다. VG 가 partial 이면 LV 활성화가 거부되거나 데이터 일부를 읽지 못할 수 있다. 쓰기 전에 원인부터 파악한다",
     S98, [chk('PV 가 3 이다', '[ "$(cat /tmp/pv.txt)" = 3 ]'), chk('LV 가 2 이다', '[ "$(cat /tmp/lv.txt)" = 2 ]')])
b.nt('활성화되지 않은 LV', '`/tmp/lvs_state.log` 는 `lvs` 출력입니다. `Attr` 의 **다섯 번째 글자가 `a`** 이면 활성(active)이고 `-` 이면 비활성입니다. **비활성인 LV 의 이름**을 `/tmp/inactive.txt` 에 저장하세요.',
     '다섯 번째 글자가 `a` 가 아닌 LV 를 찾으세요. 헤더 줄은 제외합니다.',
     "cat /tmp/lvs_state.log\nawk 'NR>1 && substr($3,5,1) != \"a\" {print $1}' /tmp/lvs_state.log > /tmp/inactive.txt\ncat /tmp/inactive.txt\n\n# data LV 는 활성화되지 않아 마운트할 수 없다. 원인(PV 누락 등)을 해결한 뒤 활성화한다",
     S98, [chk('data 다', '[ "$(cat /tmp/inactive.txt)" = data ]')])
b.nt('LV 활성화 명령 적기', '`vg0` 의 비활성 LV `data` 를 활성화하는 `lvchange` 명령 한 줄을 `/tmp/activate.txt` 에 적으세요. (샌드박스에는 LVM 이 없어 실행하지 않습니다)',
     '대상은 `VG명/LV명` 으로 적고, 상태를 바꾸는 옵션은 activate 의 약자입니다.',
     "echo 'lvchange -ay vg0/data' > /tmp/activate.txt\ncat /tmp/activate.txt\n\n# VG 가 partial 이면 거부될 수 있다. 데이터 보호가 우선이고 누락 PV 를 먼저 복구한다. 급하면 --activationmode partial 이 있으나 일부 데이터를 읽지 못할 수 있다",
     S98, [chk('lvchange 명령이고 대상이 vg0/data 다', 'grep -Eq "^[[:space:]]*(sudo )?lvchange( .*)?[ /]vg0/data( .*)?$" /tmp/activate.txt'), chk('활성화(y) 옵션이 있다', 'grep -Eq -- "(-a[ ]?y|--activate[= ]y)( |$)" /tmp/activate.txt')])
b.nt('성능 저하 RAID', '`/tmp/boot_md.log` 는 서버를 재부팅한 뒤의 `/proc/mdstat` 입니다. 상태 표기 `[2/1] [U_]` 는 디스크 2 개 중 1 개만 동작합니다. **남아 있는 디스크의 이름**(`sdX1` 형태의 이름, 대괄호 번호 제외)을 `/tmp/alive.txt` 에 저장하세요.',
     '`md0` 줄에서 `raid1` 뒤에 나오는 장치 이름입니다.',
     "cat /tmp/boot_md.log\ngrep '^md0' /tmp/boot_md.log | grep -o 'sd[a-z0-9]*\\[[0-9]*\\]' | cut -d'[' -f1 > /tmp/alive.txt\ncat /tmp/alive.txt\n\n# 미러 한쪽이 빠져 중복이 없다. 나머지 한 디스크가 고장나면 데이터를 잃으니 먼저 백업을 확인하고 새 디스크를 --add 해 재구축한다. auto-read-only 는 처음 쓰기 전까지 읽기 전용이라는 뜻이다",
     S98, [chk('sdb1 이다', '[ "$(cat /tmp/alive.txt)" = sdb1 ]')])
b.nt('NFS 서버가 응답하지 않는 증상', '`/tmp/nfs_hang.log` 는 `df -h` 가 멈추는 서버의 점검 기록입니다. 마운트 옵션 중 **응답이 없을 때 계속 기다리게 하는 옵션**과, 커널이 남긴 **응답 없음 메시지가 몇 줄**인지를 저장하세요.\n- `/tmp/opt.txt` : 해당 옵션 (`hard` 또는 `soft` 한 단어)\n- `/tmp/msgs.txt` : `not responding` 메시지 줄 수',
     '마운트 옵션 줄에서 계속 기다리는 쪽을 고르고, `not responding` 이 들어간 줄을 세세요.',
     "cat /tmp/nfs_hang.log\ngrep -o 'hard\\|soft' /tmp/nfs_hang.log | head -1 > /tmp/opt.txt\ngrep -c 'not responding' /tmp/nfs_hang.log > /tmp/msgs.txt\ncat /tmp/opt.txt /tmp/msgs.txt\n\n# hard 마운트는 서버가 돌아올 때까지 무한히 재시도해 df·ls 같은 명령까지 멈춘다. 서버·네트워크를 복구하거나 필요하면 lazy 언마운트(umount -l)로 프로세스를 풀어 준다",
     S98, [chk('hard 다', '[ "$(cat /tmp/opt.txt)" = hard ]'), chk('2 줄이다', '[ "$(cat /tmp/msgs.txt)" = 2 ]')])
b.choice('partial VG 에서 하지 말아야 할 일', 'VG 에서 PV 하나가 사라져 `partial` 입니다. 데이터를 지키는 관점에서 하지 말아야 할 일은?', '원인을 모르는 채로 구조를 바꾸면 되돌릴 수 없을 수 있습니다.',
         ['원인을 확인하지 않고 누락 PV 를 VG 에서 강제로 제거한다', '케이블과 컨트롤러 연결 상태를 먼저 확인한다', '가능하면 남은 LV 의 데이터를 먼저 백업한다', '누락 PV 가 돌아왔는지 `pvs` 로 확인한다'], 0,
         '누락 PV 를 강제로 제거(vgreduce --removemissing)하면 그 PV 에 있던 데이터가 영구히 사라질 수 있습니다. 먼저 연결·장치 인식을 확인하고, 백업을 확보한 뒤 단계적으로 복구합니다.')
b.choice('hard 마운트의 대응', 'NFS 서버가 점검 중이라 응답하지 않아 `hard` 마운트를 쓰는 서버의 프로세스들이 멈췄습니다. 가장 알맞은 대응은?', '서버가 돌아오면 재개되는 성질을 이해해야 합니다.',
         ['NFS 서버를 복구하면 멈춘 프로세스가 이어서 동작한다', '프로세스를 kill -9 로 모두 종료해도 즉시 사라진다', '서버를 재부팅하지 않으면 영원히 해결할 수 없다', '마운트 옵션이 hard 라서 서버를 복구해도 소용없다'], 0,
         'hard 마운트는 서버가 돌아오면 요청이 이어져 데이터 무결성이 유지됩니다. D 상태의 프로세스는 kill -9 로도 바로 종료되지 않을 수 있고, 급하면 `umount -f`/`-l` 을 쓰지만 데이터 손실 위험이 있습니다.')
b.fill('LV 활성화 옵션', 'LV 를 **활성화(active)** 로 바꾸는 `lvchange` 의 `-a` 옵션 값을 채우세요.', '`-a` 옵션 뒤에 활성화인지 비활성화인지를 한 글자로 적습니다.',
       'lvchange -a{0} vg0/data', ['y', 'n', 'l', 'e'], [0],
       '`-ay` 는 활성화, `-an` 은 비활성화입니다. `ly`·`ey` 처럼 `l`(로컬)·`e`(배타)를 앞에 붙이는 형태는 클러스터에서 씁니다.')
b.order('디스크 장애 때 데이터를 지키는 순서', 'RAID 어레이가 성능 저하 상태가 되고 LV 도 일부 문제가 있습니다. 데이터를 잃지 않도록 하는 순서로 놓으세요. (문제를 파악한 뒤 보호하고 조치하며 마지막에 검증하는 흐름입니다.)', '디스크를 바꾸거나 재구축하는 작업은 그 전에 준비가 끝난 뒤에 합니다.',
        ['고장난 디스크를 교체하고 재구축을 진행한다', '교체 전에 남은 데이터를 백업하거나 복제해 확보한다', '교체 전에 어느 디스크·어레이가 문제인지 상태를 확인한다', '재구축이 끝나고 정상인지 확인한다'], [2, 1, 0, 3],
        '상태를 파악하고, 남은 데이터를 먼저 확보한 뒤, 교체와 재구축을 하고, 마지막에 정상 여부를 확인합니다. 재구축 중에는 남은 디스크에 부하가 커서 백업 없이 진행하면 위험합니다.')

if __name__ == '__main__':
    preview(b)
