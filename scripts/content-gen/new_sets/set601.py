import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 601: 도메인 XML 읽기와 안전하게 고치기. 명세: docs/specs/spec_gap_set601.md
# 샌드박스 linux(libvirt 없음). 일반 파일에 저장한 도메인 XML 을 sed·grep 으로 읽고 고치는 실습이다. XML 파서가 없어 태그 짝 검사를 perl 로 직접 한다.

XML = """cat > /tmp/vm.xml <<'EOF'
<domain type='kvm'>
  <name>web01</name>
  <memory unit='KiB'>2097152</memory>
  <currentMemory unit='KiB'>2097152</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-6.2'>hvm</type>
  </os>
  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/web01.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='e1000'/>
    </interface>
  </devices>
</domain>
EOF
"""
BROKEN = """cat > /tmp/broken.xml <<'EOF'
<domain type='kvm'>
  <name>web01</name>
  <memory unit='KiB'>2097152</memory>
  <vcpu placement='static'>2</vcpu
  <devices>
    <disk type='file' device='disk'>
      <source file='/var/lib/libvirt/images/web01.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
</domain>
EOF
"""
S101 = "rm -f /tmp/*.txt /tmp/*.xml\n" + XML + "true"
S101B = "rm -f /tmp/*.txt /tmp/*.xml\n" + BROKEN + "true"
BAL = r'''perl -e 'my $s=do{local $/;<STDIN>}; my @st; while($s=~m{<(/?)([A-Za-z][\w-]*)[^<>]*?(/?)>}g){ my($c,$n,$sc)=($1,$2,$3); next if $sc; if($c){ exit 1 if !@st || pop(@st) ne $n } else { push @st,$n } } exit(@st?1:0)' < '''

b = SetBuilder(601, '도메인 XML 읽기와 안전하게 고치기: vCPU·메모리·NIC 모델·디스크 경로, 문법 오류, 영구 정의',
               'libvirt 는 VM 의 구성을 도메인 XML 로 관리합니다. XML 골격을 읽고, vCPU 수와 메모리(memory 와 currentMemory)를 바꾸고, NIC 모델을 e1000 에서 virtio 로 바꾸고, 디스크 이미지 경로를 찾고, 태그가 맞지 않는 깨진 XML 을 고치고, 수정한 XML 을 영구 정의로 등록하는 명령을 적습니다. 샌드박스에는 libvirt 가 없어 일반 파일로 연습합니다.',
               'linux', '가상화', 72, 861, '📝',
               [{"title": "libvirt 도메인 XML 형식", "url": "https://libvirt.org/formatdomain.html"}, {"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}], 5)

b.nt('vCPU 수 바꾸기', '`/tmp/vm.xml` 은 VM `web01` 의 도메인 XML 입니다. `<vcpu>` 요소의 값이 이 VM 의 vCPU 수입니다. **vCPU 를 4 로** 바꿔 파일에 저장하세요. (다른 내용은 그대로 둡니다)',
     '`sed` 로 해당 줄의 숫자만 바꾸는 방법이 있습니다. 줄에 속성이 붙어 있으니 태그 모양을 유지하세요.',
     "grep '<vcpu' /tmp/vm.xml\nsed -i \"s:\\(<vcpu[^>]*>\\)[0-9]*\\(</vcpu>\\):\\14\\2:\" /tmp/vm.xml\ngrep '<vcpu' /tmp/vm.xml\n\n# 실제로는 virsh edit web01 로 고친다(저장할 때 XML 문법을 검사해 준다). 파일을 직접 고치면 libvirt 가 모르고 덮어쓸 수 있다. XML 을 고친 값은 재정의 후 재시작해야 반영된다",
     S101, [chk('vCPU 가 4 다', r'''[ "$(sed -n 's:.*<vcpu[^>]*>\([0-9]*\)</vcpu>.*:\1:p' /tmp/vm.xml)" = 4 ]'''), chk('다른 설정이 유지됐다', 'grep -q "<name>web01</name>" /tmp/vm.xml && grep -q "web01.qcow2" /tmp/vm.xml')])
b.nt('메모리를 4GiB 로', 'VM 메모리를 **4GiB** 로 늘리려 합니다. XML 에는 최대 메모리 `<memory>` 와 현재 메모리 `<currentMemory>` 가 있고, 단위 속성(`unit`)이 붙어 있습니다. **두 요소 모두 4GiB** 가 되게 고치세요. (단위 속성에 맞는 숫자로 쓰면 되고, `KiB` 가 아닌 다른 단위로 바꿔 써도 같은 4GiB 면 됩니다)',
     '메모리를 KiB 로 쓸 때의 숫자는 GiB × 1024 × 1024 입니다. 두 요소를 모두 고쳐야 합니다.',
     "sed -i \"s:\\(<memory unit='KiB'>\\)[0-9]*:\\14194304:; s:\\(<currentMemory unit='KiB'>\\)[0-9]*:\\14194304:\" /tmp/vm.xml\ngrep -E 'memory' /tmp/vm.xml\n\n# currentMemory 가 memory(최대)보다 클 수 없다. memory 만 올리면 현재 메모리는 그대로라 게스트에 반영되지 않는다. 실행 중이면 setmem 으로 상한 안에서 조정한다",
     S101, [chk('memory 가 4GiB 다', r'''grep -Eq "<memory unit=.(KiB.>4194304|MiB.>4096|GiB.>4)</memory>" /tmp/vm.xml'''), chk('currentMemory 가 4GiB 다', r'''grep -Eq "<currentMemory unit=.(KiB.>4194304|MiB.>4096|GiB.>4)</currentMemory>" /tmp/vm.xml''')])
b.nt('NIC 모델을 virtio 로', '`<interface>` 의 `<model type=.../>` 가 가상 NIC 의 종류입니다. 지금은 `e1000`(에뮬레이션)입니다. 성능이 좋은 **`virtio`** 로 바꿔 저장하세요.',
     '`model` 줄의 `type` 속성 값만 바꾸세요.',
     "sed -i \"s:<model type='e1000'/>:<model type='virtio'/>:\" /tmp/vm.xml\ngrep '<model' /tmp/vm.xml\n\n# 게스트에 virtio 드라이버가 있어야 한다(리눅스는 대부분 기본). 바꾼 뒤에는 VM 을 재시작해야 반영되며 NIC 이름이 바뀔 수 있어 게스트 네트워크 설정을 확인한다",
     S101, [chk('NIC 모델이 virtio 다', r'''grep -q "<model type=.virtio.\s*/>" /tmp/vm.xml'''), chk('e1000 이 남아 있지 않다', '! grep -q "e1000" /tmp/vm.xml')])
b.nt('디스크 이미지 경로 읽기', '`/tmp/vm.xml` 의 `<disk>` 에서 이 VM 의 **디스크 이미지 파일 경로**(`<source file=...>`)를 읽어 경로만 `/tmp/disk_path.txt` 에 저장하세요.',
     '`source` 요소의 `file` 속성 값입니다. 따옴표 안만 남기세요.',
     "grep '<source file=' /tmp/vm.xml\ngrep -o \"<source file='[^']*'\" /tmp/vm.xml | cut -d\"'\" -f2 > /tmp/disk_path.txt\ncat /tmp/disk_path.txt\n\n# 이미지 경로가 바뀌거나 파일이 사라지면 VM 이 시작되지 않는다. <source network='...'> 는 네트워크 이름이라 헷갈리면 안 된다",
     S101, [chk('경로가 맞다', '[ "$(cat /tmp/disk_path.txt)" = /var/lib/libvirt/images/web01.qcow2 ]')])
b.nt('깨진 XML 고치기', '`/tmp/broken.xml` 은 편집하다 태그를 잘못 쓴 XML 입니다. 이대로는 libvirt 에 등록할 수 없습니다(문법 오류). **모든 태그가 짝이 맞도록** 고치세요. (`<vcpu>` 의 값 2, `<devices>` 와 디스크 설정은 그대로 둡니다)',
     '위에서부터 여는 태그마다 닫는 태그가 있는지 짝을 맞춰 보세요. `cat -n` 으로 줄 번호를 보면 편합니다.',
     "cat -n /tmp/broken.xml\nsed -i 's:</vcpu$:</vcpu>:' /tmp/broken.xml\nsed -i 's:^</domain>:  </devices>\\n</domain>:' /tmp/broken.xml\ncat /tmp/broken.xml\n\n# virsh edit 는 저장할 때 문법을 검사해 이런 파일을 거부한다. 파일을 직접 고칠 때는 virsh define 으로 검증한다. xmllint 가 있으면 xmllint --noout 도 쓴다",
     S101B, [chk('태그 짝이 맞다', BAL + '/tmp/broken.xml'), chk('vCPU 값 2 가 유지됐다', r'''[ "$(sed -n 's:.*<vcpu[^>]*>\([0-9]*\)</vcpu>.*:\1:p' /tmp/broken.xml)" = 2 ]'''), chk('디스크 설정이 유지됐다', 'grep -q "web01.qcow2" /tmp/broken.xml && grep -q "</devices>" /tmp/broken.xml')])
b.nt('수정한 XML 을 영구 정의로', '고친 `/tmp/vm.xml` 을 libvirt 에 **영구 정의로 등록**(재정의)하는 `virsh` 명령 한 줄을 `/tmp/define.txt` 에 적으세요. (샌드박스에는 libvirt 가 없어 실행하지 않습니다)',
     '파일로 도메인을 정의하는 하위 명령이 있습니다.',
     "echo 'virsh define /tmp/vm.xml' > /tmp/define.txt\ncat /tmp/define.txt\n\n# define 은 정의(영구 설정)만 바꾸고 실행 중인 VM 에는 즉시 적용되지 않는다. 적용하려면 종료 후 다시 시작한다. 임시로만 띄우려면 create 를 쓴다",
     S101, [chk('virsh define 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? define( .*)?[ =]/tmp/vm\\.xml( .*)?$" /tmp/define.txt')])
b.choice('--config 와 --live', '실행 중인 VM 의 vCPU 를 `virsh setvcpus web01 4 --live` 로만 바꿨습니다. VM 을 종료했다가 다시 시작하면 어떻게 될까요?', '--live 는 지금 실행 중인 상태에만, --config 는 영구 정의에 적용합니다.',
         ['영구 정의에는 없어 이전 설정으로 돌아간다', '영구 정의에도 자동으로 반영되어 4 가 유지된다', 'VM 이 삭제되어 정의까지 사라진다', '설정 파일이 비어 있는 상태가 되어 버린다'], 0,
         '`--live` 는 실행 중인 상태만, `--config` 는 영구 정의(XML)만 바꿉니다. 둘 다 바꾸려면 `--live --config` 를 함께 줍니다. 그렇지 않으면 재시작 때 옛 설정으로 돌아갑니다.')
b.choice('XML 파일을 직접 고치면', '`/etc/libvirt/qemu/web01.xml` 파일을 에디터로 직접 고쳤습니다. 그 뒤에 일어날 수 있는 일로 알맞은 것은?', 'libvirt 는 자신이 가진 정의를 기준으로 파일을 쓸 수 있습니다.',
         ['libvirt 가 몰라 반영되지 않거나 덮어써질 수 있다', 'libvirt 가 즉시 변경을 감지해 안전하게 반영한다', '파일을 고친 시점에 VM 이 자동으로 재시작된다', '파일 수정은 어떤 경우에도 항상 거부된다'], 0,
         'libvirt 는 도메인 정의를 메모리에도 들고 있어 파일을 직접 고치면 반영되지 않거나 다음 저장 때 덮어써질 수 있습니다. `virsh edit` 이나 `virsh define` 으로 고쳐야 문법 검사와 등록이 함께 됩니다.')
b.fill('현재 XML 출력', 'VM 의 **현재 구성(XML)을 그대로 출력**하는 virsh 하위 명령을 채우세요. (고치기 전에 백업해 둘 때 씁니다)', '현재 구성을 XML 로 꺼내 보는 명령입니다.',
       'virsh {0} web01 > web01-backup.xml', ['dumpxml', 'define', 'edit', 'undefine'], [0],
       '`dumpxml` 은 도메인 XML 을 출력합니다. `define` 은 XML 로 정의 등록, `edit` 은 에디터로 정의를 고치고 저장, `undefine` 은 정의를 삭제합니다.')
b.order('XML 구성 변경 절차', 'VM 의 구성을 XML 로 바꾸려 합니다. 되돌릴 수 있게 먼저 준비하고, 수정 전에 사전 조사를 마친 뒤 수정하고, 마지막으로 반영을 확인하는 순서로 놓으세요.', '각 단계는 앞 단계의 결과를 근거로 합니다.',
        ['VM 을 재시작해 변경이 반영되었는지 확인한다', '`virsh dumpxml` 로 현재 구성을 백업해 둔다', '`virsh edit`(또는 define)으로 수정하고 문법 검사를 통과한다', '수정에 앞서, 바꾸려는 항목이 재시작 뒤에 적용되는 종류인지 문서로 확인한다'], [1, 3, 2, 0],
        '먼저 백업하고, 바꾸려는 항목이 재시작이 필요한지 확인한 뒤, edit/define 으로 문법 검사를 통과하며 수정하고, 마지막에 재시작해 반영을 확인합니다.')

if __name__ == '__main__':
    preview(b)
