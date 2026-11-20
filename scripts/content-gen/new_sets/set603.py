import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 603: virt-install 과 cloud-init 으로 VM 만들기. 명세: docs/specs/spec_gap_set603.md
# 샌드박스 linux(libvirt·cloud-init 없음). cloud-init 의 user-data·meta-data 는 일반 파일로 실제로 작성·검사하고, virt-install 은 명령을 읽고 적는다.

S103 = """rm -rf /tmp/ci /tmp/*.txt /tmp/*.log /tmp/lab.pub
mkdir -p /tmp/ci
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXAMPLEKEY0000000000000000000000000000 lab@example.com' > /tmp/lab.pub
cat > /tmp/vi_cmd.log <<'EOF'
virt-install \\
  --name web01 \\
  --memory 2048 \\
  --vcpus 2 \\
  --disk path=/var/lib/libvirt/images/web01.qcow2,size=20,format=qcow2 \\
  --os-variant ubuntu22.04 \\
  --network network=default \\
  --import
EOF
true"""

b = SetBuilder(603, 'virt-install 과 cloud-init: 옵션 읽기, user-data·meta-data 작성, seed ISO, 재실행',
               '클라우드 이미지로 VM 을 만들고 첫 부팅에 초기 설정을 넣는 흐름을 연습합니다. virt-install 명령의 옵션을 읽고 직접 적어 보고, cloud-init 의 user-data(호스트 이름·패키지·SSH 키)와 meta-data(인스턴스 ID)를 실제 파일로 작성하며, 이를 seed ISO 로 만드는 명령과 첫 부팅에서만 실행되는 이유, 다시 실행하려면 어떻게 하는지를 다룹니다. 샌드박스에는 libvirt 와 cloud-init 이 없어 설정 파일은 일반 파일로 만들고 명령은 파일에 적는 방식입니다.',
               'linux', '가상화', 48, 863, '☁️',
               [{"title": "virt-install 매뉴얼", "url": "https://man.archlinux.org/man/virt-install.1"}, {"title": "cloud-init 문서", "url": "https://cloudinit.readthedocs.io/en/latest/"}], 5)

b.nt('virt-install 옵션 읽기', '`/tmp/vi_cmd.log` 는 VM 을 만든 `virt-install` 명령입니다. 아래 값을 저장하세요. (값만)\n- `/tmp/mem.txt` : `--memory` 값(MiB)\n- `/tmp/vcpus.txt` : `--vcpus` 값\n- `/tmp/os.txt` : `--os-variant` 값',
     '각 옵션 이름 바로 뒤의 칸입니다. 줄 끝의 백슬래시는 줄 이음 표시입니다.',
     "cat /tmp/vi_cmd.log\ngrep -- '--memory' /tmp/vi_cmd.log | awk '{print $2}' > /tmp/mem.txt\ngrep -- '--vcpus' /tmp/vi_cmd.log | awk '{print $2}' > /tmp/vcpus.txt\ngrep -- '--os-variant' /tmp/vi_cmd.log | awk '{print $2}' > /tmp/os.txt\ncat /tmp/mem.txt /tmp/vcpus.txt /tmp/os.txt\n\n# --os-variant 는 게스트 OS 에 맞는 기본 장치·최적화를 고르는 옵션이다(osinfo-query os 로 목록 확인). --import 는 새로 설치하지 않고 이미 있는 디스크 이미지로 부팅한다",
     S103, [chk('메모리가 2048 이다', '[ "$(cat /tmp/mem.txt)" = 2048 ]'), chk('vCPU 가 2 다', '[ "$(cat /tmp/vcpus.txt)" = 2 ]'), chk('os-variant 가 ubuntu22.04 다', '[ "$(cat /tmp/os.txt)" = ubuntu22.04 ]')])
b.nt('user-data 작성', '`/tmp/ci/user-data` 를 만들어 VM 의 **첫 부팅 설정**을 적으세요. cloud-init 은 첫 줄이 `#cloud-config` 인 YAML 로 읽습니다. 아래를 모두 넣으세요.\n- 호스트 이름 `web01`\n- 설치할 패키지 `nginx`\n- 접속용 SSH 공개키 (`/tmp/lab.pub` 의 내용)',
     'YAML 이라 들여쓰기가 중요합니다. 호스트 이름 키, 패키지 목록 키, SSH 키 목록 키가 각각 있습니다. cloud-init 문서의 예시에서 키 이름을 찾아보세요.',
     "cat > /tmp/ci/user-data <<EOF\n#cloud-config\nhostname: web01\npackages:\n  - nginx\nssh_authorized_keys:\n  - $(cat /tmp/lab.pub)\nEOF\ncat /tmp/ci/user-data\n\n# 사용자별로 넣으려면 users 목록 아래에 ssh_authorized_keys 를 둔다. user-data 는 첫 부팅에서만 실행되며 비밀번호·키는 저장소에 올리지 않는다",
     S103, [chk('첫 줄이 #cloud-config 다', '[ "$(head -1 /tmp/ci/user-data)" = "#cloud-config" ]'), chk('hostname 이 web01 이다', r'''grep -Eq "^hostname:[[:space:]]*['\"]?web01['\"]?[[:space:]]*$" /tmp/ci/user-data'''), chk('nginx 패키지가 있다', r'''grep -q "^packages:" /tmp/ci/user-data && { grep -Eq "^[[:space:]]*-[[:space:]]*nginx[[:space:]]*$" /tmp/ci/user-data || grep -Eq "^packages:[[:space:]]*\[.*nginx" /tmp/ci/user-data; }'''), chk('ssh_authorized_keys 항목에 공개키가 있다', r'''grep -Eq "^[[:space:]]*(- )?ssh_authorized_keys:" /tmp/ci/user-data && sed -n '/ssh_authorized_keys:/,$p' /tmp/ci/user-data | grep -qF "$(cut -d' ' -f2 /tmp/lab.pub)"''')])
b.nt('meta-data 작성', '`/tmp/ci/meta-data` 에는 인스턴스를 식별하는 정보를 적습니다. cloud-init 은 **인스턴스 ID 가 바뀌어야** 새 인스턴스로 보고 첫 부팅 설정을 다시 실행합니다. 아래를 적으세요.\n- 인스턴스 ID: `web01-001`\n- 로컬 호스트 이름: `web01`',
     'cloud-init 의 NoCloud 문서(meta-data)에서 인스턴스를 식별하는 키 이름을 찾아보세요. `키: 값` 한 줄씩입니다.',
     "cat > /tmp/ci/meta-data <<'EOF'\ninstance-id: web01-001\nlocal-hostname: web01\nEOF\ncat /tmp/ci/meta-data\n\n# 같은 이미지를 복제해 새 VM 을 만들 때 instance-id 를 바꿔야 cloud-init 이 다시 실행되어 호스트 이름·키가 새로 설정된다",
     S103, [chk('instance-id 가 맞다', 'grep -Eq "^instance-id:[[:space:]]*web01-001[[:space:]]*$" /tmp/ci/meta-data'), chk('local-hostname 이 맞다', 'grep -Eq "^local-hostname:[[:space:]]*web01[[:space:]]*$" /tmp/ci/meta-data')])
b.nt('seed ISO 만들기', 'user-data 와 meta-data 는 VM 에 **작은 ISO 디스크(seed)** 로 붙여 전달합니다. 이 ISO 의 볼륨 레이블은 **`cidata`** 여야 cloud-init 이 찾습니다. `/tmp/ci` 의 두 파일로 `/tmp/ci/seed.iso` 를 만드는 명령 한 줄을 `/tmp/seed_cmd.txt` 에 적으세요. (`cloud-localds` 또는 `genisoimage`/`mkisofs` 중 편한 것. 샌드박스에는 없어 실행하지 않습니다)',
     '`cloud-localds` 는 출력 파일, user-data, meta-data 순으로 받습니다. ISO 도구를 쓰면 볼륨 레이블 옵션으로 `cidata` 를 줘야 합니다.',
     "echo 'cloud-localds /tmp/ci/seed.iso /tmp/ci/user-data /tmp/ci/meta-data' > /tmp/seed_cmd.txt\ncat /tmp/seed_cmd.txt\n\n# genisoimage 를 쓰면: genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data. 레이블이 cidata 가 아니면 NoCloud 데이터소스가 seed 를 찾지 못한다",
     S103, [chk('seed ISO 를 만드는 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?(cloud-localds .*seed\\.iso.*user-data.*meta-data|(genisoimage|mkisofs|xorriso).*(-volid|-V)[ =]cidata.*user-data.*meta-data|(genisoimage|mkisofs|xorriso).*user-data.*meta-data.*(-volid|-V)[ =]cidata)" /tmp/seed_cmd.txt')])
b.nt('virt-install 명령 쓰기', '이름 `web02`, 메모리 `4096`MiB, vCPU `2`, 디스크 이미지 `/var/lib/libvirt/images/web02.qcow2`, OS 종류 `ubuntu22.04`, 네트워크 `default`(libvirt 기본 네트워크), **이미 있는 이미지로 부팅(새 설치 없음)** 하는 `virt-install` 명령을 `/tmp/vi_new.txt` 에 적으세요. (줄 이음은 쓰지 않고 한 줄로, 실행하지 않습니다)',
     '앞에서 읽은 `/tmp/vi_cmd.log` 에서 이미 있는 디스크로 부팅하게 하는 옵션을 찾으세요.',
     "echo 'virt-install --name web02 --memory 4096 --vcpus 2 --disk path=/var/lib/libvirt/images/web02.qcow2 --os-variant ubuntu22.04 --network network=default --import' > /tmp/vi_new.txt\ncat /tmp/vi_new.txt\n\n# 헤드리스 서버에서는 --graphics none --console pty,target_type=serial 로 터미널로 접속한다. seed ISO 는 --disk path=seed.iso,device=cdrom 으로 붙인다",
     S103, [chk('virt-install 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?virt-install " /tmp/vi_new.txt'), chk('이름이 web02 다', 'grep -Eq -- "--name[ =]web02( |$)" /tmp/vi_new.txt'), chk('메모리·vCPU 가 맞다', 'grep -Eq -- "--memory[ =]4096( |$)" /tmp/vi_new.txt && grep -Eq -- "--vcpus[ =]2( |,|$)" /tmp/vi_new.txt'), chk('디스크 경로가 맞다', 'grep -q "/var/lib/libvirt/images/web02.qcow2" /tmp/vi_new.txt'), chk('os-variant(osinfo) 와 import 가 있다', 'grep -Eq -- "--(os-variant|osinfo)[ =]ubuntu22.04( |$)" /tmp/vi_new.txt && grep -q -- "--import" /tmp/vi_new.txt'), chk('네트워크가 default 다', 'grep -Eq -- "--network[ =](network=)?default" /tmp/vi_new.txt')])
b.nt('cloud-init 다시 실행하기', '이미 한 번 부팅한 VM 의 user-data 를 고쳤는데 다시 부팅해도 반영되지 않습니다. cloud-init 은 **이미 처리한 인스턴스**의 설정을 다시 실행하지 않기 때문입니다. 게스트 안에서 **cloud-init 의 상태를 지워 다음 부팅 때 첫 부팅처럼 다시 실행**하게 하는 명령을 `/tmp/ci_clean.txt` 에 한 줄로 적으세요. (로그까지 지우는 옵션 포함)',
     '`cloud-init` 에는 상태를 정리하는 하위 명령이 있고, 로그를 함께 지우는 옵션이 있습니다.',
     "echo 'cloud-init clean --logs' > /tmp/ci_clean.txt\ncat /tmp/ci_clean.txt\n\n# 이후 재부팅하면 cloud-init 이 처음인 것처럼 다시 실행된다. 운영 중인 VM 에서는 호스트 키·네트워크 설정이 바뀔 수 있으니 주의한다. 이미지를 템플릿으로 만들 때도 같은 명령으로 정리한다",
     S103, [chk('cloud-init clean 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?cloud-init clean( .*)?$" /tmp/ci_clean.txt'), chk('로그도 지운다', 'grep -Eq -- "(--logs|-l)( |$)" /tmp/ci_clean.txt')])
b.choice('cloud-init 이 한 번만 실행되는 이유', 'VM 을 재부팅할 때마다 user-data 의 패키지 설치가 다시 실행되지 않는 이유로 가장 알맞은 것은?', '첫 부팅을 마친 뒤 cloud-init 이 디스크에 무엇을 남겨 두는지 생각해 보세요.',
         ['인스턴스 ID 가 같으면 이미 처리한 것으로 보고 건너뛴다', '재부팅하면 cloud-init 이 항상 삭제되어 버린다', 'user-data 는 하루에 한 번만 읽히도록 되어 있다', 'VM 이 종료되면 user-data 가 자동으로 비워진다'], 0,
         'cloud-init 은 마지막으로 처리한 인스턴스 ID 를 저장해 두고 같으면 once-per-instance 작업(패키지 설치, 사용자 생성 등)을 다시 하지 않습니다. ID 가 바뀌거나 `cloud-init clean` 으로 상태를 지우면 다시 실행됩니다.')
b.choice('seed ISO 의 레이블', 'NoCloud 방식으로 seed ISO 를 만들었는데 VM 이 부팅해도 user-data 가 적용되지 않습니다. seed ISO 의 볼륨 레이블이 `config` 입니다. 가장 알맞은 원인은?', 'seed 디스크를 cloud-init 이 어떤 기준으로 찾는지 생각해 보세요.',
         ['볼륨 레이블이 cidata 가 아니라 cloud-init 이 seed 를 찾지 못한다', 'ISO 파일 이름이 seed.iso 가 아니라서 읽지 못한다', 'meta-data 가 있으면 user-data 는 항상 무시된다', 'ISO 는 한 번 붙이면 이미지를 영구 변경하지 못한다'], 0,
         'NoCloud 데이터소스는 볼륨 레이블이 `cidata` 인 디스크(또는 `CIDATA`)에서 user-data·meta-data 를 읽습니다. 파일 이름은 상관없지만 레이블이 다르면 찾지 못합니다.')
b.fill('OS 종류 지정 옵션', 'virt-install 에서 게스트 OS 종류에 맞는 최적 장치 설정을 고르게 하는 옵션을 채우세요. (예: `ubuntu22.04`)', '게스트 OS 의 종류를 알려 주는 옵션입니다.',
       'virt-install --{0} ubuntu22.04', ['os-variant', 'cpu', 'boot', 'machine'], [0],
       '`--os-variant` 는 OS 에 맞는 디스크·NIC 모델 같은 기본값을 정합니다(`osinfo-query os` 로 이름 확인). `--cpu` 는 CPU 모델, `--boot` 는 부팅 순서·펌웨어, `--machine` 은 머신 타입입니다.')
b.order('클라우드 이미지로 VM 만들기', '클라우드 이미지(cloud image)로 VM 을 만들어 설정까지 끝내려 합니다. 올바른 순서로 놓으세요. (디스크를 먼저 준비하고, 그다음 첫 부팅 설정 데이터를 만듭니다)', '디스크와 설정 데이터가 준비되어야 VM 을 띄울 수 있습니다.',
        ['VM 에 접속해 호스트 이름·패키지·키가 적용됐는지 확인한다', '`virt-install --import` 로 VM 을 만든다', '클라우드 이미지를 복사해 VM 디스크로 준비한다', 'user-data·meta-data 를 작성해 seed ISO 로 만든다'], [2, 3, 1, 0],
        '이미지를 VM 전용 디스크로 복사하고, 첫 부팅 설정을 seed ISO 로 만든 뒤, virt-install 로 VM 을 띄우고, 접속해서 설정이 적용되었는지 확인합니다. 원본 이미지를 직접 쓰면 여러 VM 이 서로 덮어씁니다.')

if __name__ == '__main__':
    preview(b)
