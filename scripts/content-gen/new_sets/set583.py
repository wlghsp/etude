import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 583: 가상화 상황집(1) VM 시작 실패. 명세: docs/specs/spec_gap_set583.md
# 샌드박스 linux(비특권, libvirt·KVM 없음). 현장에서 모은 virsh·ps·dmesg 출력(샘플)을 읽고 원인을 좁히는 상황집이다.

S83 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/start_err.log <<'EOF'
error: Failed to start domain 'web01'
error: Cannot access storage file '/var/lib/libvirt/images/web01.qcow2' (as uid:107, gid:107): Permission denied
EOF
cat > /tmp/ls_l.log <<'EOF'
$ ls -l /var/lib/libvirt/images/
-rw------- 1 root root 21474836480 Nov 20 09:00 web01.qcow2
-rw-r----- 1 qemu qemu 10737418240 Nov 20 09:00 db01.qcow2
EOF
cat > /tmp/lock_err.log <<'EOF'
error: Failed to start domain 'vm-b'
error: internal error: process exited while connecting to monitor: Failed to get "write" lock
Is another process using the image [/var/lib/libvirt/images/data.qcow2]?
EOF
cat > /tmp/ps.log <<'EOF'
qemu  4101  1 5 09:00 ?  /usr/libexec/qemu-kvm -name guest=vm-a,debug-threads=on -drive file=/var/lib/libvirt/images/data.qcow2,format=qcow2
qemu  4202  1 3 09:05 ?  /usr/libexec/qemu-kvm -name guest=vm-c,debug-threads=on -drive file=/var/lib/libvirt/images/other.qcow2,format=qcow2
qemu  4303  1 2 09:10 ?  /usr/libexec/qemu-kvm -name guest=vm-d,debug-threads=on -drive file=/var/lib/libvirt/images/data-old.qcow2,format=qcow2
EOF
cat > /tmp/dmesg.log <<'EOF'
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz root=/dev/mapper/vg0-root ro quiet
[    5.123456] kvm: disabled by bios
[    5.200000] systemd[1]: Started Journal Service.
EOF
cat > /tmp/net_list.log <<'EOF'
 Name      State      Autostart   Persistent
--------------------------------------------
 default   inactive   no          yes
 isolated  active     yes         yes
EOF
cat > /tmp/domstate.log <<'EOF'
$ virsh domstate --reason db01
paused (ioerror)
$ df -h /var/lib/libvirt/images
Filesystem      Size  Used Avail Use% Mounted on
/dev/mapper/vg0-images  500G  500G     0 100% /var/lib/libvirt/images
EOF
true"""

b = SetBuilder(583, '가상화 상황집(1): VM 시작 실패 — 파일 권한, 디스크 잠금, KVM, 네트워크, 디스크 가득 참',
               '"VM 이 안 켜진다 / 멈췄다"는 신고를 받고 오류 메시지에서 원인을 좁히는 상황집입니다. virsh 오류와 ls·ps·dmesg·df 출력(샘플)을 읽고 디스크 파일 권한, 같은 이미지를 쓰는 두 프로세스(쓰기 잠금), BIOS 에서 꺼진 KVM, 시작되지 않은 가상 네트워크, 디스크가 가득 차 멈춘 VM(paused ioerror)을 짚고 고치는 명령을 적어 봅니다. 샌드박스에는 libvirt·KVM 이 없어 현장 출력을 읽는 방식입니다.',
               'linux', '가상화', 72, 843, '🧯',
               [{"title": "libvirt 오류 정리", "url": "https://libvirt.org/docs.html"}, {"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}], 5)

# 1
b.nt('접근 거부된 이미지의 소유자', '`/tmp/start_err.log` 는 VM 시작 실패 메시지이고, `/tmp/ls_l.log` 는 이미지 디렉터리의 `ls -l` 입니다. 오류는 VM 프로세스(uid 107)가 디스크 이미지에 접근하지 못했다는 내용입니다. 아래 두 값을 저장하세요. (값만)\n- `/tmp/vm_uid.txt` : 오류 메시지에 나온 **VM 프로세스의 uid 번호**\n- `/tmp/owner.txt` : 문제가 된 `web01.qcow2` 파일의 **현재 소유자 이름**',
     '오류 문구의 괄호 안에서 uid 를, `ls -l` 의 셋째 칸에서 소유자를 찾으세요. 문제가 된 파일이 어느 줄인지 먼저 확인하세요.',
     "cat /tmp/start_err.log /tmp/ls_l.log\ngrep -o 'uid:[0-9]*' /tmp/start_err.log | cut -d: -f2 > /tmp/vm_uid.txt\ngrep 'web01.qcow2' /tmp/ls_l.log | awk '{print $3}' > /tmp/owner.txt\ncat /tmp/vm_uid.txt /tmp/owner.txt\n\n# 보통은 libvirt 가 시작할 때 이미지 소유자를 맞춰 주지만(NFS root squash, dynamic_ownership=0, SELinux·AppArmor 같은 경우에는 직접 맞춰야 한다). VM 은 root 가 아니라 qemu 같은 전용 사용자로 실행된다. 이미지가 root 소유 0600 이면 접근할 수 없다. 소유자를 VM 사용자로 맞춘다(chown). SELinux·AppArmor 컨텍스트도 함께 확인한다",
     S83, [chk('uid 가 107 이다', '[ "$(cat /tmp/vm_uid.txt)" = 107 ]'), chk('소유자가 root 다', '[ "$(cat /tmp/owner.txt)" = root ]')])
# 2
b.nt('같은 이미지를 쓰는 VM', '`/tmp/lock_err.log` 는 VM 시작 시 `Failed to get "write" lock` 오류가 난 기록이고, `/tmp/ps.log` 는 호스트의 qemu 프로세스 목록입니다. `data.qcow2` 이미지의 **쓰기 잠금을 쥐고 있는 VM 의 이름**(`guest=` 값)을 `/tmp/holders.txt` 에 저장하세요. (이름만, 실패한 `vm-b` 는 목록에 없습니다. 비슷한 이름의 다른 이미지에 속지 마세요)',
     '프로세스 줄 중 해당 이미지 파일을 지정한 줄만 고르고, 거기서 VM 이름 부분만 남기세요.',
     "cat /tmp/ps.log\ngrep 'data.qcow2' /tmp/ps.log | grep -o 'guest=[a-z0-9-]*' | cut -d= -f2 | sort > /tmp/holders.txt\ncat /tmp/holders.txt\n\n# 같은 디스크 이미지를 두 VM 이 동시에 쓰기로 열면 파일시스템이 깨진다. qemu 가 이를 막으려고 쓰기 잠금을 건다. 이미지를 분리하거나 한쪽을 끈 뒤 시작한다",
     S83, [chk('vm-a 다', '[ "$(xargs < /tmp/holders.txt)" = "vm-a" ]')])
# 3
b.nt('KVM 이 꺼진 이유', '`/tmp/dmesg.log` 는 호스트 부팅 로그 일부입니다. VM 시작 시 "Domain requires KVM, but it is not available" 오류가 났습니다. 로그에서 **KVM 이 비활성인 이유를 말해 주는 줄**을 `/tmp/why.txt` 에 저장하세요.',
     '부팅 로그에서 하드웨어 가상화와 관련된 메시지를 찾으세요.',
     "cat /tmp/dmesg.log\ngrep -i 'kvm' /tmp/dmesg.log > /tmp/why.txt\ncat /tmp/why.txt\n\n# 하드웨어 가상화(VT-x/AMD-V)가 BIOS/UEFI 에서 꺼져 있다. 서버 설정에서 켠 뒤 재부팅한다. 켜졌는지는 lsmod | grep kvm 과 /dev/kvm 존재로 확인한다",
     S83, [chk('BIOS 때문이라는 줄이다', 'grep -qi "disabled by bios" /tmp/why.txt && ! grep -q "Journal" /tmp/why.txt && [ "$(wc -l < /tmp/why.txt)" -le 2 ]')])
# 4
b.nt('가상 네트워크 상태', '`/tmp/net_list.log` 는 `virsh net-list --all` 의 출력입니다. VM 이 `default` 네트워크를 쓰도록 되어 있는데 시작이 실패합니다. 아래 두 값을 저장하세요. (값만)\n- `/tmp/net_state.txt` : `default` 의 **State**\n- `/tmp/net_auto.txt` : `default` 의 **Autostart**',
     '`default` 로 시작하는 줄에서 두 번째·세 번째 칸입니다.',
     "cat /tmp/net_list.log\nawk '$1==\"default\" {print $2}' /tmp/net_list.log > /tmp/net_state.txt\nawk '$1==\"default\" {print $3}' /tmp/net_list.log > /tmp/net_auto.txt\ncat /tmp/net_state.txt /tmp/net_auto.txt\n\n# 네트워크가 정의만 되어 있고 시작되지 않았다(inactive). Autostart 가 no 라 호스트를 재부팅할 때마다 다시 시작해야 한다",
     S83, [chk('inactive 다', '[ "$(cat /tmp/net_state.txt)" = inactive ]'), chk('no 다', '[ "$(cat /tmp/net_auto.txt)" = no ]')])
# 5
b.nt('멈춘 VM 의 이유와 디스크', '`/tmp/domstate.log` 는 갑자기 멈춘 VM `db01` 의 상태와 이미지 디렉터리의 `df` 출력입니다. 아래 두 값을 저장하세요. (값만)\n- `/tmp/reason.txt` : 일시 정지 **이유**(`paused (...)` 괄호 안의 단어)\n- `/tmp/use.txt` : 이미지 디렉터리의 **사용률**(`%` 포함)',
     '이유는 괄호 안, 사용률은 `Use%` 열입니다.',
     "cat /tmp/domstate.log\ngrep -o 'paused ([a-z]*)' /tmp/domstate.log | tr -d '()' | cut -d' ' -f2 > /tmp/reason.txt\ngrep '^/dev/' /tmp/domstate.log | awk '{print $5}' > /tmp/use.txt\ncat /tmp/reason.txt /tmp/use.txt\n\n# 호스트 디스크가 가득 차 VM 이 쓰기에 실패하면(ioerror) 게스트 손상을 막으려고 VM 이 일시 정지된다. 공간을 확보한 뒤 virsh resume 한다",
     S83, [chk('이유가 ioerror 다', '[ "$(cat /tmp/reason.txt)" = ioerror ]'), chk('사용률이 100% 다', '[ "$(cat /tmp/use.txt)" = "100%" ]')])
# 6
b.nt('네트워크 시작 명령 적기', '`default` 가상 네트워크를 **지금 시작**하고 **호스트가 재부팅해도 자동으로 시작**되게 하려 합니다. 샌드박스에는 libvirt 가 없으니 실행할 `virsh` 명령 두 줄(시작, 자동 시작 설정)을 `/tmp/net_fix.txt` 에 한 줄에 하나씩 적으세요.',
     '네트워크를 다루는 virsh 하위 명령은 `net-` 으로 시작합니다. 시작과 자동 시작 설정은 서로 다른 명령입니다.',
     "printf '%s\\n' 'virsh net-start default' 'virsh net-autostart default' > /tmp/net_fix.txt\ncat /tmp/net_fix.txt\n\n# net-start 는 지금만 시작하고, net-autostart 는 부팅 시 시작을 설정한다. 둘 다 해야 재부팅 후에도 유지된다",
     S83, [chk('net-start default 가 있다', 'grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? net-start( --network)? default[[:space:]]*$" /tmp/net_fix.txt'), chk('net-autostart default 가 있다', 'grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? net-autostart( --network)? default[[:space:]]*$" /tmp/net_fix.txt')])
# 7
b.choice('디스크 잠금 오류의 올바른 대응', '두 VM 이 같은 데이터 디스크 이미지(`data.qcow2`)를 쓰도록 설정되어 있고, 두 번째 VM 시작 때 쓰기 잠금 오류가 납니다. 올바른 대응은?', '같은 이미지에 동시에 쓰기를 허용하면 어떤 일이 생길지 생각해 보세요.',
         ['한쪽을 종료하거나 이미지를 분리해 한 VM 만 쓰게 한다', '잠금 파일을 지우거나 잠금을 무시하는 옵션으로 두 VM 을 모두 켠다', '이미지 파일 권한을 777 로 바꾼다', '호스트의 qemu 를 재설치한다'], 0,
         '일반 파일시스템은 동시에 두 곳에서 쓰기로 열면 메타데이터가 깨집니다. 잠금은 이를 막는 안전장치이므로 한 VM 만 쓰게 하거나 이미지를 분리해야 합니다. 공유 디스크가 정말 필요하면 클러스터 파일시스템과 공유 디스크 설정을 써야 합니다.')
# 8
b.choice('paused (ioerror) 의 처리', '호스트 디스크가 가득 차 VM 이 `paused (ioerror)` 상태입니다. 올바른 처리 순서의 요점으로 알맞은 것은?', '원인을 고치지 않고 재개하면 어떻게 되는지 생각해 보세요.',
         ['공간을 확보한 뒤 VM 을 재개한다', '공간 확보 없이 먼저 재개해 본다', 'VM 을 삭제하고 다시 만든다', '게스트 OS 를 재설치한다'], 0,
         '일시 정지는 쓰기 실패로부터 게스트 데이터를 보호하려는 동작입니다. 원인(공간 부족)을 해결하지 않고 재개하면 다시 같은 오류로 멈추거나 손상될 수 있습니다. 불필요한 이미지·로그를 정리하거나 볼륨을 확장한 뒤 `virsh resume` 으로 재개합니다.')
# 9
b.fill('일시 정지 이유 보기', 'VM 이 왜 일시 정지됐는지(`ioerror` 같은 **이유**)까지 함께 보려면 `domstate` 에 어떤 옵션을 줘야 할까요? 빈칸을 채우세요.', '`virsh help domstate` 에서 옵션 목록을 확인해 보세요.',
       'virsh domstate {0} db01', ['--reason', '--all', '--force', '--live'], [0],
       '`--reason` 은 상태와 함께 그 이유를 출력합니다. `--all` 은 목록 명령의 옵션, `--force` 는 강제 실행, `--live` 는 실행 중인 설정을 대상으로 하는 옵션입니다.')
# 10
b.order('VM 시작 실패 점검 순서', 'VM 이 시작되지 않을 때 원인을 찾아 고치는 일반 순서로 놓으세요.', '오류 메시지가 가리키는 대상부터 시작합니다.',
        ['VM 을 다시 시작해 해결됐는지 확인한다', '원인을 고친다', '오류 메시지에서 문제가 된 자원(파일·네트워크·KVM·메모리)을 읽는다', '그 자원의 상태를 실제로 확인한다(권한·경로·`net-list`·`lsmod` 등)'], [2, 3, 1, 0],
        '오류 메시지가 가리키는 자원이 무엇인지 읽고, 그 자원의 실제 상태를 확인해 원인을 확정한 뒤 고치고, 마지막으로 VM 을 다시 시작해 확인합니다.')

if __name__ == '__main__':
    preview(b)
