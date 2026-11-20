import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 604: VM 스냅샷과 qemu-img. 명세: docs/specs/spec_gap_set604.md
# 샌드박스 linux(libvirt·qemu-img 없음). virsh snapshot-list·qemu-img info 의 샘플 출력을 읽고 명령을 파일에 적는다.

S104 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/snap_list.log <<'EOF'
 Name             Creation Time               State
------------------------------------------------------------
 after-upgrade    2026-11-20 10:15:00 +0900   disk-snapshot
 base-install     2026-11-18 09:00:00 +0900   shutoff
 before-upgrade   2026-11-19 14:30:00 +0900   running
EOF
cat > /tmp/qinfo.log <<'EOF'
image: web01.qcow2
file format: qcow2
virtual size: 20 GiB (21474836480 bytes)
disk size: 3.2 GiB
cluster_size: 65536
backing file: base.qcow2
EOF
true"""

b = SetBuilder(604, 'VM 스냅샷과 qemu-img: 목록 읽기, 만들기·되돌리기 명령, 크기 확장·형식 변환, 스냅샷은 백업이 아니다',
               'VM 을 안전하게 바꾸기 위한 스냅샷과 디스크 이미지 도구(qemu-img)를 다룹니다. virsh snapshot-list 에서 스냅샷 수와 가장 최근 것을 읽고, qemu-img info 에서 가상 크기와 실제 크기를 읽고, 스냅샷 만들기·되돌리기·이미지 확장·형식 변환 명령을 적고, 스냅샷이 백업이 아닌 이유와 외부 스냅샷의 체인 부담을 정리합니다. 샌드박스에는 libvirt·qemu-img 가 없어 샘플을 읽고 명령을 파일에 적는 방식입니다.',
               'linux', '가상화', 72, 864, '📸',
               [{"title": "libvirt 스냅샷", "url": "https://libvirt.org/kbase/snapshots.html"}, {"title": "qemu-img 문서", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}], 5)

b.nt('스냅샷 목록 읽기', '`/tmp/snap_list.log` 는 `virsh snapshot-list web01` 의 출력입니다. **스냅샷의 개수**와 **가장 최근에 만든 스냅샷의 이름**을 저장하세요. (값만)\n- `/tmp/snap_cnt.txt` : 스냅샷 수\n- `/tmp/snap_last.txt` : 가장 최근 스냅샷 이름',
     '헤더와 구분선을 제외한 줄이 스냅샷입니다. 생성 시각이 가장 늦은 줄을 고르세요.',
     "cat /tmp/snap_list.log\nawk 'NR>2 && NF>0' /tmp/snap_list.log | wc -l | tr -d ' ' > /tmp/snap_cnt.txt\nawk 'NR>2 && NF>0 {print $2\" \"$3\" \"$1}' /tmp/snap_list.log | sort | tail -1 | awk '{print $3}' > /tmp/snap_last.txt\ncat /tmp/snap_cnt.txt /tmp/snap_last.txt\n\n# 스냅샷이 쌓일수록 디스크 체인이 길어져 읽기가 느려지고 관리가 어려워진다. 필요 없는 스냅샷은 snapshot-delete 로 정리한다",
     S104, [chk('3 개다', '[ "$(cat /tmp/snap_cnt.txt)" = 3 ]'), chk('가장 최근이 after-upgrade 다', '[ "$(cat /tmp/snap_last.txt)" = after-upgrade ]')])
b.nt('가상 크기와 실제 크기', '`/tmp/qinfo.log` 는 `qemu-img info web01.qcow2` 의 출력입니다. `virtual size` 는 게스트가 보는 디스크 크기, `disk size` 는 호스트에서 **실제로 차지한 크기**입니다. 아래 값을 GiB 숫자만 저장하세요.\n- `/tmp/vsize.txt` : virtual size\n- `/tmp/dsize.txt` : disk size',
     '두 줄의 콜론 뒤 첫 숫자입니다. `disk size` 에는 소수점이 있습니다.',
     "cat /tmp/qinfo.log\ngrep '^virtual size' /tmp/qinfo.log | awk '{print $3}' > /tmp/vsize.txt\ngrep '^disk size' /tmp/qinfo.log | awk '{print $3}' > /tmp/dsize.txt\ncat /tmp/vsize.txt /tmp/dsize.txt\n\n# 20GiB 짜리 디스크지만 실제로는 3.2GiB 만 쓴다(thin provisioning). 게스트가 쓰면 점점 늘어나 호스트 풀이 가득 찰 수 있다. backing file 이 있으면 이 파일은 base.qcow2 위의 변경분만 담는 오버레이다",
     S104, [chk('20 이다', '[ "$(cat /tmp/vsize.txt)" = 20 ]'), chk('3.2 다', '[ "$(cat /tmp/dsize.txt)" = 3.2 ]')])
b.nt('바탕 이미지 찾기', '같은 `qemu-img info` 출력에서 이 이미지가 **어떤 이미지 위의 변경분인지**(`backing file`)를 이름만 `/tmp/backing.txt` 에 저장하세요.',
     '`backing file` 줄의 콜론 뒤입니다.',
     "grep '^backing file' /tmp/qinfo.log | awk '{print $3}' > /tmp/backing.txt\ncat /tmp/backing.txt\n\n# base.qcow2 가 지워지거나 옮겨지면 이 이미지는 읽을 수 없다. 체인이 길어지면 commit 으로 합치거나 rebase 로 정리한다",
     S104, [chk('base.qcow2 다', '[ "$(cat /tmp/backing.txt)" = base.qcow2 ]')])
b.nt('스냅샷 만들기 명령', '업그레이드 전에 VM `web01` 의 상태를 되돌릴 수 있도록 **이름 `before-patch` 인 스냅샷**을 만드는 `virsh` 명령 한 줄을 `/tmp/snap_create.txt` 에 적으세요. (샌드박스에는 libvirt 가 없어 실행하지 않습니다)',
     '스냅샷을 이름과 함께 간단히 만드는 하위 명령이 있습니다.',
     "echo 'virsh snapshot-create-as web01 before-patch' > /tmp/snap_create.txt\ncat /tmp/snap_create.txt\n\n# --disk-only 를 붙이면 메모리 상태 없이 디스크만 외부 스냅샷으로 만든다. 메모리를 포함하면 되돌릴 때 실행 상태까지 복원된다",
     S104, [chk('스냅샷 생성 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? snapshot-create-as( |$)" /tmp/snap_create.txt && grep -qw web01 /tmp/snap_create.txt && grep -qw before-patch /tmp/snap_create.txt')])
b.nt('스냅샷으로 되돌리기 명령', '패치가 실패해 VM `web01` 을 앞에서 만든 `before-patch` 스냅샷 상태로 **되돌리는** `virsh` 명령 한 줄을 `/tmp/snap_revert.txt` 에 적으세요.',
     '스냅샷 하위 명령 중 되돌리는 것을 고르고, 도메인과 스냅샷 이름을 차례로 적습니다.',
     "echo 'virsh snapshot-revert web01 before-patch' > /tmp/snap_revert.txt\ncat /tmp/snap_revert.txt\n\n# 되돌리면 그 시점 이후의 변경은 사라진다. 필요한 데이터는 먼저 꺼내 둔다. 외부(디스크 전용) 스냅샷은 되돌리기가 제한될 수 있어 만들 때 방식을 정한다",
     S104, [chk('snapshot-revert 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? snapshot-revert( .*)? web01( .*)? before-patch( .*)?$" /tmp/snap_revert.txt')])
b.nt('이미지 확장과 형식 변환 명령', '`qemu-img` 로 두 가지를 하려 합니다. 명령을 각각 한 줄씩 `/tmp/img_cmds.txt` 에 적으세요. (두 줄, 샌드박스에는 qemu-img 가 없어 실행하지 않습니다)\n1. `disk.qcow2` 의 가상 크기를 **10GiB 더 늘리기**\n2. `disk.raw`(raw 형식)를 **qcow2 형식의 `disk.qcow2`** 로 변환',
     '크기 변경은 resize 하위 명령에 증가량을 `+` 로 줍니다. 변환은 convert 하위 명령에 원본 형식과 출력 형식을 옵션으로 줍니다.',
     "printf '%s\\n' 'qemu-img resize disk.qcow2 +10G' 'qemu-img convert -f raw -O qcow2 disk.raw disk.qcow2' > /tmp/img_cmds.txt\ncat /tmp/img_cmds.txt\n\n# resize 만으로는 이미지만 커지고 게스트 안의 파티션·파일시스템은 그대로다. 게스트에서 growpart 와 resize2fs 로 확장해야 한다. 줄일 때는 데이터 손상 위험이 커 반드시 파일시스템을 먼저 줄이고 백업한다",
     S104, [chk('resize 명령이 있다', 'grep -Eq "^[[:space:]]*(sudo )?qemu-img resize( .*)? disk\\.qcow2 \\+10(G|GiB)[[:space:]]*$" /tmp/img_cmds.txt'), chk('convert 명령이 있다', 'grep -E "^[[:space:]]*(sudo )?qemu-img convert " /tmp/img_cmds.txt | grep -Eq -- "-f raw" && grep -E "^[[:space:]]*(sudo )?qemu-img convert " /tmp/img_cmds.txt | grep -Eq -- "-O qcow2" && grep -q "disk.raw" /tmp/img_cmds.txt'), chk('원본·대상 파일명이 맞다', r'''grep -Eq "disk\.raw[[:space:]]+disk\.qcow2([[:space:]]|$)" /tmp/img_cmds.txt''')])
b.choice('스냅샷은 백업이 아니다', '"VM 에 스냅샷을 찍어 두었으니 따로 백업은 필요 없다"는 의견이 나왔습니다. 가장 알맞은 평가는?', '스냅샷이 원본 디스크와 어떤 관계인지 생각해 보세요.',
         ['스냅샷은 같은 저장소에 의존해 손상·삭제를 막지 못하니 백업이 아니다', '스냅샷이 완전한 복사본이므로 백업과 같다', '스냅샷은 호스트가 고장나도 다른 곳에서 복구할 수 있다', '스냅샷은 시간이 지나면 자동으로 외부에 복제된다'], 0,
         '스냅샷은 원본 이미지(또는 바탕 이미지)에 의존하는 변경 기록이라 저장소 손상·삭제·호스트 장애에는 함께 사라집니다. 별도 저장소에 복사된 백업이 있어야 장애 복구가 됩니다. 스냅샷은 변경 전 되돌리기 용도입니다.')
b.choice('스냅샷이 오래 쌓일 때', 'VM 에 외부(디스크 전용) 스냅샷을 여러 개 찍고 몇 달 방치했습니다. 나타날 수 있는 문제로 알맞은 것은?', '체인이 길어지면 읽는 경로가 어떻게 달라지는지 생각해 보세요.',
         ['체인이 길어져 읽기 성능이 떨어지고 관리가 어려워진다', '스냅샷이 자동으로 합쳐져서 아무 문제가 없다', '스냅샷은 시간이 지나도 호스트 디스크를 쓰지 않는다', '스냅샷 개수와 VM 성능은 전혀 무관하다'], 0,
         '외부 스냅샷은 오버레이 파일이 쌓여 체인이 되고, 읽을 때 여러 파일을 거쳐야 해 느려지며 중간 파일 하나가 사라지면 복구가 어렵습니다. 필요 없는 스냅샷은 blockcommit 등으로 합쳐 정리합니다.')
b.fill('스냅샷 목록 보기', 'VM `web01` 의 스냅샷 목록을 보는 virsh 하위 명령을 채우세요.', '스냅샷 하위 명령 중 목록을 보여 주는 것입니다.',
       'virsh {0} web01', ['snapshot-list', 'snapshot-delete', 'snapshot-revert', 'snapshot-current'], [0],
       '`snapshot-list` 는 목록을 보여 줍니다. `snapshot-delete` 는 삭제, `snapshot-revert` 는 되돌리기, `snapshot-current` 는 현재 스냅샷 정보를 보여 줍니다.')
b.order('패치 전후 스냅샷 활용', '운영 VM 에 위험한 패치를 적용하려 합니다. 스냅샷을 활용해 안전하게 진행하는 순서로 놓으세요.', '되돌릴 지점이 먼저 있어야 하고, 결과를 본 뒤에 되돌릴지 정합니다.',
        ['패치를 적용한다', '문제가 있으면 스냅샷으로 되돌리고, 없으면 스냅샷을 정리한다', '패치 전에 스냅샷을 만든다', '패치 결과를 확인한다'], [2, 0, 3, 1],
        '스냅샷을 만들고 패치를 적용한 뒤 결과를 확인합니다. 문제가 있으면 되돌리고 문제가 없으면 스냅샷을 정리해 체인이 길어지지 않게 합니다. 이 흐름에서도 별도 백업은 따로 필요합니다.')

if __name__ == '__main__':
    preview(b)
