import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 608: OpenStack 이미지 올리기와 서버 이동 절차. 명세: docs/specs/spec_gap_set608.md
# 샌드박스 linux(OpenStack 없음). image·hypervisor 출력 샘플을 읽고 명령을 파일에 적는다.

S108 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/image_show.log <<'EOF'
+------------------+------------------------------------+
| Field            | Value                              |
+------------------+------------------------------------+
| disk_format      | qcow2                              |
| name             | ubuntu-22.04                       |
| size             | 0                                  |
| status           | queued                             |
+------------------+------------------------------------+
EOF
cat > /tmp/hypervisors.log <<'EOF'
+----+---------------------+-------+----------+-------------+-------------+
| ID | Hypervisor Hostname | State | Status   | Memory MB   | Memory Used |
+----+---------------------+-------+----------+-------------+-------------+
|  1 | comp-a.example      | up    | enabled  |      131072 |       40000 |
|  2 | comp-b.example      | up    | enabled  |      131072 |       90000 |
|  3 | comp-c.example      | up    | disabled |      131072 |       10000 |
|  4 | comp-d.example      | up    | enabled  |      131072 |       60000 |
+----+---------------------+-------+----------+-------------+-------------+
EOF
true"""

b = SetBuilder(608, 'OpenStack 이미지 올리기와 서버 이동: image create·속성, 상태 읽기, 호스트 점검 절차',
               'OpenStack 운영의 두 가지 반복 작업을 다룹니다. 클라우드 이미지를 Glance 에 올리는 명령(형식 옵션)과 장치 모델 같은 이미지 속성 설정, 업로드가 끝나지 않은 이미지(queued, 크기 0)의 상태 읽기, 컴퓨트 호스트를 점검하려고 서버를 옮기는 절차(서비스 비활성화 → 라이브 마이그레이션 → evacuate 와의 차이)와 이동할 호스트 고르기를 샘플에서 읽고 명령을 적어 봅니다. 샌드박스에는 OpenStack 이 없어 샘플을 읽고 명령은 파일에 적습니다.',
               'linux', 'OpenStack', 39, 868, '🖼️',
               [{"title": "Glance 이미지 가이드", "url": "https://docs.openstack.org/glance/latest/user/"}, {"title": "Nova 호스트 유지보수", "url": "https://docs.openstack.org/nova/latest/admin/live-migration-usage.html"}], 5)

b.nt('이미지 올리기 명령', '`ubuntu-22.04.qcow2` 파일을 이름 `ubuntu-22.04` 인 이미지로 Glance 에 올리는 `openstack` 명령 한 줄을 `/tmp/img_create.txt` 에 적으세요. **디스크 형식은 `qcow2`, 컨테이너 형식은 `bare`** 로 지정합니다. (실행하지 않습니다)',
     '`openstack image create` 에 파일·디스크 형식·컨테이너 형식을 지정하는 옵션이 각각 있습니다. 이미지 이름도 적습니다.',
     "echo 'openstack image create --file ubuntu-22.04.qcow2 --disk-format qcow2 --container-format bare ubuntu-22.04' > /tmp/img_create.txt\ncat /tmp/img_create.txt\n\n# 올린 형식이 실제 파일 형식과 다르면 부팅이 안 된다. qemu-img info 로 실제 형식을 먼저 확인한다. 공개하려면 --public, 프로젝트별 공유는 image add project 를 쓴다",
     S108, [chk('image create 명령이다', 'grep -Eq "^[[:space:]]*openstack( --[a-z-]+[= ][^ ]+)* image create( |$)" /tmp/img_create.txt'), chk('파일과 형식이 맞다', r'''grep -Eq -- "--file[ =][^ ]*ubuntu-22\.04\.qcow2( |$)" /tmp/img_create.txt && grep -Eq -- "--disk-format[ =]qcow2( |$)" /tmp/img_create.txt && grep -Eq -- "--container-format[ =]bare( |$)" /tmp/img_create.txt'''), chk('이름이 ubuntu-22.04 다', r'''grep -Eq "(^| )ubuntu-22\.04( |$)" /tmp/img_create.txt''')])
b.nt('이미지 속성 설정 명령', '이 이미지로 만드는 서버가 디스크를 **virtio 버스**로 쓰게 하려고 이미지 속성 `hw_disk_bus` 를 `virtio` 로 설정합니다. 이미지 `ubuntu-22.04` 에 대한 `openstack` 명령 한 줄을 `/tmp/img_prop.txt` 에 적으세요. (실행하지 않습니다)',
     '이미지의 속성을 바꾸는 하위 명령이 있고, 그 옵션 이름은 `openstack image set --help` 로 찾을 수 있습니다.',
     "echo 'openstack image set --property hw_disk_bus=virtio ubuntu-22.04' > /tmp/img_prop.txt\ncat /tmp/img_prop.txt\n\n# hw_ 로 시작하는 속성은 서버를 만들 때 하이퍼바이저가 장치 모델을 고르는 힌트다(hw_vif_model, hw_scsi_model, hw_qemu_guest_agent 등). 이미 만든 서버에는 적용되지 않는다",
     S108, [chk('image set 명령이다', 'grep -Eq "^[[:space:]]*openstack( --[a-z-]+[= ][^ ]+)* image set( |$)" /tmp/img_prop.txt'), chk('속성이 맞다', r'''grep -Eq -- "--property[ =]hw_disk_bus=virtio( |$)" /tmp/img_prop.txt && grep -Eq "(^| )ubuntu-22\.04( |$)" /tmp/img_prop.txt''')])
b.nt('업로드가 끝나지 않은 이미지', '`/tmp/image_show.log` 는 방금 올린 이미지의 `openstack image show` 출력입니다. 서버를 만들려는데 이 이미지를 쓸 수 없습니다. 아래 두 값을 저장하세요. (값만)\n- `/tmp/status.txt` : 이미지 `status`\n- `/tmp/size.txt` : 이미지 `size`',
     '표에서 두 필드의 값 칸을 뽑으세요. 공백을 정리해야 합니다.',
     "cat /tmp/image_show.log\ngrep '| status' /tmp/image_show.log | awk -F'|' '{gsub(/ /,\"\",$3); print $3}' > /tmp/status.txt\ngrep '| size' /tmp/image_show.log | awk -F'|' '{gsub(/ /,\"\",$3); print $3}' > /tmp/size.txt\ncat /tmp/status.txt /tmp/size.txt\n\n# queued 에 size 0 이면 이미지 메타데이터만 만들어지고 데이터 업로드가 시작되지 않았거나 중단되었다. 업로드가 실패하면 killed 가 된다. active 가 되어야 서버를 만들 수 있다",
     S108, [chk('queued 다', '[ "$(cat /tmp/status.txt)" = queued ]'), chk('크기가 0 이다', '[ "$(cat /tmp/size.txt)" = 0 ]')])
b.nt('옮겨 갈 호스트 고르기', '`/tmp/hypervisors.log` 는 여러 명령의 출력을 한 표로 합친 요약 샘플입니다. `comp-b.example` 을 점검하려고 서버를 옮기려 합니다. **`Status` 가 `enabled` 이고 `State` 가 `up` 이며, comp-b 를 제외한 호스트 중 사용 메모리(`Memory Used`)가 가장 적은 호스트**의 이름을 `/tmp/dest.txt` 에 저장하세요. (이름만)',
     '`disabled` 호스트는 새 서버를 받지 못합니다. 조건에 맞는 줄 중에서 마지막 칸의 숫자가 가장 작은 줄을 고르세요.',
     "cat /tmp/hypervisors.log\ngrep 'comp-' /tmp/hypervisors.log | grep -v 'comp-b' | grep ' enabled ' | grep ' up ' | awk -F'|' '{gsub(/ /,\"\",$3); gsub(/ /,\"\",$7); print $7, $3}' | sort -n | head -1 | awk '{print $2}' > /tmp/dest.txt\ncat /tmp/dest.txt\n\n# comp-c 는 사용 메모리가 가장 적지만 disabled 라 받을 수 없다. comp-a 로 옮긴다. 실제로는 스케줄러가 고르게 두는 것도 가능하지만 대상 지정이 필요하면 --host 를 준다",
     S108, [chk('comp-a.example 이다', '[ "$(cat /tmp/dest.txt)" = comp-a.example ]')])
b.nt('호스트 점검 준비 명령', '`comp-b.example` 에 **새 서버가 배치되지 않도록** `nova-compute` 서비스를 **비활성화**하는 `openstack` 명령 한 줄을 `/tmp/disable.txt` 에 적으세요. (실행하지 않습니다)',
     '`compute service` 의 하위 명령으로 비활성화를 하고, 호스트 이름과 바이너리 이름(`nova-compute`)을 인자로 줍니다.',
     "echo 'openstack compute service set --disable comp-b.example nova-compute' > /tmp/disable.txt\ncat /tmp/disable.txt\n\n# 비활성화하면 새 서버가 오지 않지만 이미 있는 서버는 계속 실행된다. --disable-reason 으로 이유를 남기면 좋다. 점검 뒤에는 --enable 로 되돌린다",
     S108, [chk('서비스 비활성화 명령이다', 'grep -Eq "^[[:space:]]*openstack( --[a-z-]+[= ][^ ]+)* compute service set( .*)? --disable( |$)" /tmp/disable.txt'), chk('호스트와 서비스가 맞다', 'grep -q "comp-b.example" /tmp/disable.txt && grep -q "nova-compute" /tmp/disable.txt')])
b.nt('서버 라이브 마이그레이션 명령', '서버 `web01` 을 **실행 중인 채로** 호스트 `comp-a.example` 로 옮기는 `openstack` 명령 한 줄을 `/tmp/migrate.txt` 에 적으세요. (실행하지 않습니다)',
     '`server migrate` 에 라이브 방식과 대상 호스트를 지정하는 옵션이 있습니다.',
     "echo 'openstack server migrate --live-migration --host comp-a.example web01' > /tmp/migrate.txt\ncat /tmp/migrate.txt\n\n# 공유 스토리지가 없으면 --block-migration 이 필요하다. --live-migration 은 중단이 거의 없지만 --live-migration 없이 migrate 하면 서버를 멈추고 옮기는 콜드 마이그레이션이다",
     S108, [chk('server migrate 명령이다', 'grep -Eq "^[[:space:]]*openstack( --[a-z-]+[= ][^ ]+)* server migrate( |$)" /tmp/migrate.txt'), chk('라이브·대상·서버가 맞다', 'grep -Eq -- "--live-migration( |$)" /tmp/migrate.txt && grep -Eq -- "--host[ =]comp-a\\.example( |$)" /tmp/migrate.txt && grep -Eq "(^| )web01( |$)" /tmp/migrate.txt')])
b.choice('migrate 와 evacuate', '`server migrate`(라이브 마이그레이션)와 `server evacuate` 의 차이로 알맞은 것은?', '원래 호스트가 살아 있는지에 따라 쓰임이 다릅니다.',
         ['migrate 는 정상 서버를 옮기고, evacuate 는 죽은 호스트의 서버를 복구한다', 'migrate 는 서버를 삭제하고 evacuate 는 서버를 통째로 복제한다', '두 명령은 같은 동작에 붙은 서로 다른 이름일 뿐이다', 'evacuate 는 살아 있는 호스트에서만 쓸 수 있다'], 0,
         '라이브 마이그레이션은 정상 호스트에서 서버 상태를 넘기는 계획된 이동입니다. evacuate 는 호스트가 죽은 상황에서 다른 호스트에 서버를 다시 만드는 복구 동작(원래 호스트가 확실히 꺼져 있어야 함)입니다.')
b.choice('Ceph 를 함께 쓰는 이유', 'Glance 이미지, Cinder 볼륨, Nova 임시 디스크를 같은 Ceph 클러스터에 두면 서버를 빠르게 만들 수 있는 이유로 알맞은 것은?', '같은 저장소 안에서 복사를 어떻게 처리하는지 생각해 보세요.',
         ['이미지를 복사 없이 copy-on-write 복제로 바로 서버 디스크로 쓴다', '이미지 데이터를 전부 네트워크로 새로 내려받아도 빨라서 문제없다', '서버 디스크가 항상 메모리에 올라가기 때문이다', 'Ceph 가 서버를 자동으로 삭제해 공간을 확보하기 때문이다'], 0,
         '같은 Ceph 풀에서는 이미지의 스냅샷을 copy-on-write 로 복제해 서버 디스크를 만들 수 있어 데이터를 실제로 복사하지 않습니다. 그래서 큰 이미지로도 서버 생성이 빠르고 공간도 절약됩니다.')
b.fill('이미지 속성 바꾸기', '이미 올려 둔 이미지의 속성을 **바꾸는** `openstack image` 하위 명령을 채우세요.', '값을 설정한다는 뜻의 단어입니다.',
       'openstack image {0} --property hw_vif_model=virtio ubuntu-22.04', ['set', 'create', 'delete', 'list'], [0],
       '`image set` 은 기존 이미지의 속성·이름·공개 여부 등을 바꿉니다. `create` 는 새로 만들기, `delete` 는 삭제, `list` 는 목록 조회입니다.')
b.order('컴퓨트 호스트 점검 절차', '컴퓨트 호스트 하나를 점검하려 합니다. 서비스 중단을 최소화하는 순서로 놓으세요.', '새로 오는 서버를 막고 기존 서버를 옮긴 뒤에 손댑니다.',
        ['점검을 마치고 컴퓨트 서비스를 다시 활성화한다', '그 호스트의 컴퓨트 서비스를 비활성화해 새 서버를 막는다', '호스트 위 서버를 다른 호스트로 라이브 마이그레이션한다', '호스트에 서버가 남아 있지 않은지 확인하고 점검한다'], [1, 2, 3, 0],
        '새 서버 배치를 막은 뒤 기존 서버를 옮기고, 비었는지 확인하고 점검하고, 끝나면 서비스를 다시 켭니다. 서버가 있는 채로 호스트를 끄면 중단이 생깁니다.')

if __name__ == '__main__':
    preview(b)
