import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 556 네트워크 드라이버 개념 정리: none·host·overlay·macvlan·ipvlan, 언제 무엇을, k8s 연결. 명세: docs/specs/spec_gap_set556.md
# 샌드박스 docker(dind). 이미지는 alpine 만 쓴다. overlay 는 swarm 이 필요해 실습 대신 퀴즈로, none·host·macvlan 은 직접 만든다.

CLEAN = "rm -f /tmp/*.txt; docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm lan1 >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; "

b = SetBuilder(556, '네트워크 드라이버 개념 정리: none·host·overlay·macvlan·ipvlan',
               '도커 네트워크 드라이버가 무엇이 다르고 언제 쓰는지 정리합니다. 기본으로 있는 bridge·host·none, 여러 서버를 잇는 overlay, 컨테이너를 공유기 아래 장치처럼 보이게 하는 macvlan·ipvlan, 그리고 쿠버네티스 hostNetwork·CNI 와의 연결까지. none·host·macvlan 은 터미널에서 직접 만들어 확인합니다.',
               'docker', '도커', 34, 816, '🔌',
               [{"title": "Docker 네트워크 드라이버", "url": "https://docs.docker.com/engine/network/drivers/"}, {"title": "Docker macvlan 네트워크", "url": "https://docs.docker.com/engine/network/drivers/macvlan/"}], 3)

b.choice('도커가 기본으로 만들어 두는 네트워크',
         '도커를 설치하고 아무것도 만들지 않은 채 `docker network ls` 를 하면 네트워크가 몇 개 이미 보입니다. 이 기본 네트워크 이름의 조합으로 맞는 것은 무엇일까요?',
         '이름 하나는 컨테이너를 따로 지정하지 않을 때 붙는 곳이고, 나머지 둘은 "호스트와 같이 쓰기", "아예 끊기"에 해당합니다.',
         ['`bridge`, `host`, `none`', '`bridge`, `overlay`, `macvlan`', '`bridge`, `host`, `overlay`', '`bridge`, `none`, `ipvlan`'], 0,
         '기본 네트워크는 `bridge`·`host`·`none` 세 개입니다. 참고로 `none` 네트워크의 DRIVER 열에는 `null` 이 찍힙니다. `overlay` 는 Swarm 을 켜야 만들 수 있고, `macvlan`·`ipvlan` 은 사용자가 직접 만들어야 생깁니다.')

b.nt('네트워크 없이 실행하기 (none)',
     '`isol` 이라는 컨테이너(`alpine`, 명령 `sleep 3600`)를 **네트워크를 전혀 연결하지 않고** 백그라운드로 실행하세요. 그리고 그 컨테이너 **안에서** `ip -o addr` 를 실행한 결과를 `/tmp/none_if.txt` 에 저장하세요. 외부와 통하는 인터페이스가 없다는 것을 눈으로 확인하는 실습입니다.',
     '`docker run --help` 에서 `--network` 옵션의 설명을 찾아 보세요. 값으로 쓸 이름은 `docker network ls` 에 나오는 기본 네트워크 중에 있습니다.',
     "docker run -d --name isol --network none alpine sleep 3600\ndocker exec isol ip -o addr > /tmp/none_if.txt\ncat /tmp/none_if.txt\n\n# none: 컨테이너에는 루프백(lo)만 있고 외부로 나가는 인터페이스(eth0)가 없다",
     CLEAN,
     [chk('isol 이 실행 중이고 네트워크 모드가 none 이다', '[ "$(docker inspect -f "{{.State.Running}} {{.HostConfig.NetworkMode}}" isol)" = "true none" ]'),
      chk('컨테이너 안의 인터페이스 정보가 저장되어 있다', 'grep -q " lo " /tmp/none_if.txt'),
      chk('eth0 가 보이지 않는다', '! grep -q eth0 /tmp/none_if.txt')])

b.choice('host 모드의 성격',
         '`docker run --network host ...` 로 실행한 컨테이너에 대한 설명으로 맞는 것은 무엇일까요?',
         '네트워크를 "나눠 쓰는가, 붙여서 같이 쓰는가"를 생각해 보세요. 별도 주소를 받으면 포트를 따로 열어 줄 필요가 생깁니다.',
         ['컨테이너가 호스트의 네트워크 인터페이스와 포트를 그대로 써서, 컨테이너가 80번 포트를 열면 호스트의 80번 포트로 보인다', '컨테이너가 자기만의 IP 를 받고 호스트를 거쳐 NAT 로 나간다', '`-p` 로 포트를 열어 주어야만 밖에서 접속할 수 있다', '호스트와 완전히 분리되어 `lo` 인터페이스만 보인다'], 0,
         'host 모드는 컨테이너 전용 네트워크 공간을 만들지 않고 호스트의 것을 그대로 씁니다. 그래서 NAT 가 없어 빠르지만, 호스트의 같은 포트를 쓰는 다른 프로세스와 **충돌할 수 있고** 격리도 약합니다. 그래서 `-p` 는 필요 없고(주어도 무시됩니다) 의미도 없습니다. 자기만의 IP 와 NAT 는 bridge 의 특징, `lo` 만 보이는 것은 none 의 특징입니다.')

b.nt('호스트 네트워크로 실행하고 인터페이스 비교하기',
     '`hostweb` 컨테이너(`alpine`, 명령 `sleep 3600`)를 **호스트의 네트워크를 그대로 쓰는 모드**로 백그라운드 실행하세요. 그리고 그 컨테이너 안에서 `ls /sys/class/net` 을 실행한 결과(네트워크 인터페이스 이름 목록)를 `/tmp/host_if.txt` 에 저장하세요. 일반 컨테이너라면 `lo`·`eth0` 정도만 보이지만, 이 모드에서는 호스트 쪽 인터페이스(예: `docker0`)까지 보이게 됩니다.',
     '`--network` 의 값 중 호스트와 같이 쓰는 모드의 이름은 `docker network ls` 에서 볼 수 있습니다. 컨테이너 안에서 실행하려면 `docker exec` 를 씁니다.',
     "docker run -d --name hostweb --network host alpine sleep 3600\ndocker exec hostweb ls /sys/class/net > /tmp/host_if.txt\ncat /tmp/host_if.txt\n\n# host 모드: 컨테이너가 호스트의 인터페이스를 그대로 본다 (docker0 가 보인다)",
     CLEAN,
     [chk('hostweb 이 실행 중이고 네트워크 모드가 host 이다', '[ "$(docker inspect -f "{{.State.Running}} {{.HostConfig.NetworkMode}}" hostweb)" = "true host" ]'),
      chk('호스트의 docker0 인터페이스가 목록에 있다', 'grep -qx docker0 /tmp/host_if.txt')])

b.choice('overlay 를 만들었더니 오류가 난다',
         '서버 한 대에서 `docker network create -d overlay appnet` 을 실행했더니 `This node is not a swarm manager. Use "docker swarm init" or "docker swarm join" ...` 오류가 났습니다. overlay 네트워크의 성격으로 이 오류를 가장 잘 설명하는 것은 무엇일까요?',
         'overlay 가 풀려는 문제가 서버 한 대 안의 연결인지, 서버 여러 대 사이의 연결인지 생각해 보세요.',
         ['overlay 는 여러 서버(노드)의 컨테이너를 하나의 네트워크처럼 잇는 드라이버라서, 노드들을 묶는 Swarm 모드가 켜져 있어야 만들 수 있다', 'overlay 는 이름 해석을 위해 DNS 서버를 따로 설치해야만 만들 수 있다', 'overlay 는 `docker0` 와 같은 대역을 쓰므로 기본 bridge 를 먼저 지워야 한다', 'overlay 는 root 가 아닌 사용자에게 막혀 있어서 `sudo` 를 붙여야 한다'], 0,
         'overlay 는 서로 다른 서버에 있는 컨테이너끼리 같은 사설 네트워크에 있는 것처럼 통신하게 해 줍니다(서버 사이를 VXLAN 터널로 잇는 방식). 이를 위해 노드 정보를 공유하는 Swarm 이 필요해서, Swarm 이 아닌 단독 서버에서는 만들 수 없습니다. 권한·DNS·docker0 와는 상관없는 오류입니다.')

b.fill('독립 컨테이너도 overlay 에 붙이는 옵션',
       'Swarm 서비스가 아니라 평범한 `docker run` 컨테이너도 붙일 수 있는 overlay 네트워크를 만드는 명령입니다. (기본값에서는 Swarm 서비스만 붙일 수 있습니다) 빈칸을 채우세요.',
       '`docker network create --help` 에서 overlay 와 관련된 옵션 설명을 읽어 보세요. 붙이기·내부 전용·ingress 중 이 목적에 맞는 것은 무엇인가요?',
       'docker network create -d overlay {0} appnet', ['--attachable', '--internal', '--scope=local', '--ingress'], [0],
       '`--attachable` 을 주면 Swarm 서비스가 아닌 일반 컨테이너도 `docker run --network appnet` 으로 붙일 수 있습니다. `--internal` 은 외부로 나가는 길을 막는 옵션, `--ingress` 는 Swarm 의 외부 로드밸런싱용 특수 네트워크를 만드는 옵션이고, overlay 의 scope 는 `swarm` 이라 `local` 로 바꿀 수 없습니다.')

b.order('Swarm 에서 overlay 네트워크를 만들고 쓰는 흐름', '단독 서버 한 대에서 overlay 를 쓰려는 흐름입니다. 아래 단계를 **앞에서 뒤**로 놓으세요. SCOPE 확인은 컨테이너를 띄우기 **전에** 합니다.', 'overlay 는 Swarm 이 켜져 있어야 만들 수 있다는 앞 문제를 떠올려 보세요. 네트워크가 있어야 컨테이너를 붙일 수 있습니다.',
        ['`docker network create -d overlay --attachable appnet` 으로 overlay 네트워크를 만든다', '`docker network ls` 로 appnet 의 SCOPE 가 `swarm` 인지 확인한다', '`docker run -d --network appnet alpine sleep 3600` 으로 컨테이너를 붙여 실행한다', '`docker swarm init` 으로 이 서버를 Swarm 으로 켠다'], [3, 0, 1, 2],
        '먼저 `docker swarm init` 으로 Swarm 을 켜야 overlay 를 만들 수 있습니다. 그다음 `--attachable` 로 만들고, `docker network ls` 에서 SCOPE 가 `swarm` 으로 나오는지(local 이 아님) 확인한 뒤, 일반 컨테이너를 `--network appnet` 으로 붙입니다.')

b.nt('macvlan 네트워크 만들기',
     '컨테이너가 **공유기 아래의 별개 장치처럼 자기 MAC·IP 를 갖고** 바깥 네트워크에 직접 나타나게 하는 드라이버가 macvlan 입니다. `lan1` 이라는 macvlan 네트워크를 만드세요. 서브넷은 `192.0.2.0/24`, 게이트웨이는 `192.0.2.1`, 부모 인터페이스는 `eth0` 입니다. 부모 인터페이스를 지정하는 드라이버 옵션(`-o`)의 이름은 `parent` 입니다.',
     '`docker network create --help` 에서 드라이버를 고르는 옵션, 서브넷·게이트웨이 옵션, 드라이버별 옵션(`-o key=value`) 형식을 찾아 보세요.',
     "docker network create -d macvlan --subnet 192.0.2.0/24 --gateway 192.0.2.1 -o parent=eth0 lan1\ndocker network inspect lan1\n\n# macvlan: 부모 NIC(eth0) 위에 가상 NIC 를 얹어 컨테이너가 고유 MAC·IP 로 바깥 대역에 직접 보이게 한다\n# ipvlan 은 macvlan 과 비슷하지만 컨테이너마다 MAC 을 만들지 않고 부모 인터페이스의 MAC 을 공유하고 IP 로만 구분한다",
     CLEAN,
     [chk('lan1 의 드라이버가 macvlan 이다', '[ "$(docker network inspect -f "{{.Driver}}" lan1)" = macvlan ]'),
      chk('서브넷과 게이트웨이가 맞다', '[ "$(docker network inspect -f "{{range .IPAM.Config}}{{.Subnet}} {{.Gateway}}{{end}}" lan1)" = "192.0.2.0/24 192.0.2.1" ]'),
      chk('부모 인터페이스가 eth0 이다', '[ "$(docker network inspect -f "{{index .Options \\"parent\\"}}" lan1)" = eth0 ]')])

b.choice('macvlan 과 ipvlan 의 차이',
         '물리 스위치가 포트 하나에 허용하는 MAC 주소 수를 제한하고 있습니다. 서버의 NIC 하나 위에서 컨테이너 여러 개가 **각자 IP 로** 바깥 대역에 직접 보이게 하려는데, macvlan 으로는 스위치가 MAC 수 때문에 막는다면 대안으로 가장 알맞은 것은 무엇일까요?',
         'MAC 주소를 컨테이너마다 새로 만드는 쪽과 그렇지 않은 쪽이 무엇인지, 앞 문제의 macvlan 설명을 떠올려 보세요.',
         ['ipvlan — 컨테이너들이 부모 인터페이스의 MAC 을 공유하고 IP 만 다르게 가진다', 'host — 컨테이너마다 자기 IP 를 받는다', 'overlay — 부모 NIC 의 MAC 을 공유한다', 'none — 외부와 연결하지 않으므로 MAC 이 필요 없다'], 0,
         'macvlan 은 컨테이너마다 **고유 MAC** 을 만들어 장치처럼 보이게 하는 반면, ipvlan 은 부모 인터페이스의 MAC 을 **공유**하고 IP 로만 구분합니다. MAC 수 제한이나 보안 설정(MAC 필터링) 때문에 macvlan 이 막히는 환경에서 ipvlan 을 씁니다. host 는 컨테이너별 IP 가 없고, overlay 는 여러 서버를 잇는 용도이며, none 은 외부 연결이 없습니다. (참고로 macvlan 은 호스트가 자기 macvlan 컨테이너와 직접 통신하지 못하는 특성도 있습니다.)')

b.choice('어떤 상황에 어떤 드라이버를 쓸까',
         '서버 한 대에서 웹 컨테이너와 DB 컨테이너가 **이름으로** 서로 통신해야 하고, DB 는 밖에 노출하지 않으며 웹만 `-p 8080:80` 으로 열려고 합니다. 가장 알맞은 선택은 무엇일까요?',
         '이름으로 통신이 되려면 어떤 종류의 bridge 여야 하는지, 앞 세트에서 본 내용을 떠올려 보세요.',
         ['직접 만든 사용자 정의 bridge 네트워크에 둘 다 붙인다', '기본 `bridge` 네트워크에 둘 다 붙인다', '둘 다 `--network host` 로 실행한다', '둘 다 `--network none` 으로 실행한다'], 0,
         '서버 한 대에서 이름 통신이 필요하면 **사용자 정의 bridge** 가 기본 선택입니다(내장 DNS, 필요한 컨테이너만 `-p` 로 노출). 기본 bridge 에는 이름 해석이 없고, host 는 DB 포트까지 호스트에 그대로 노출되며 `-p` 가 무의미하고, none 은 통신 자체가 안 됩니다. 정리하면 한 서버·일반 용도는 bridge, 최고 성능이 필요하면 host, 여러 서버는 overlay, 바깥 LAN 에 장치처럼 보여야 하면 macvlan·ipvlan, 완전 격리는 none 입니다.')

b.choice('쿠버네티스 hostNetwork 와 도커',
         '쿠버네티스 Pod 의 `spec.hostNetwork: true` 설정은 도커의 어떤 네트워크 설정과 가장 닮았을까요?',
         '이 설정을 켠 Pod 는 Pod 전용 IP 대신 노드의 네트워크 인터페이스와 IP 를 그대로 씁니다.',
         ['`--network host`', '`--network none`', '`-d overlay`', '`-d macvlan`'], 0,
         '`hostNetwork: true` 인 Pod 는 노드의 네트워크 공간을 그대로 사용하므로, 도커의 `--network host` 와 같은 개념입니다. 그래서 같은 노드에서 포트가 충돌할 수 있고 격리도 약해집니다. 노드 모니터링 에이전트처럼 노드의 네트워크를 직접 봐야 하는 일부 시스템 Pod 에서만 씁니다.')

b.choice('쿠버네티스 CNI 와 overlay',
         '쿠버네티스는 Pod 네트워크를 CNI 플러그인(예: Calico, Flannel)에 맡깁니다. 서로 다른 노드의 Pod 끼리 IP 로 통신하게 해 주는 CNI 의 역할은 도커의 어떤 드라이버가 푸는 문제와 가장 닮았을까요?',
         '"서로 다른 서버에 있는 컨테이너를 하나의 네트워크처럼 잇기"가 어느 드라이버의 이야기였는지 떠올려 보세요.',
         ['overlay — 서버가 달라도 같은 네트워크처럼 통신하게 잇는다', 'none — 네트워크를 끊는다', '기본 bridge — 한 서버 안에서만 쓰이는 `docker0` 에 붙인다', 'host — 호스트 네트워크를 그대로 쓴다'], 0,
         'CNI 플러그인은 Pod 에 IP 를 주고 노드를 가로질러 Pod 끼리 통신하게 잇습니다. 이는 도커 overlay 가 푸는 "여러 서버의 컨테이너를 한 네트워크처럼" 문제와 같은 종류이고, Flannel 의 VXLAN 처럼 실제로 overlay(터널) 방식을 쓰는 CNI 도 많습니다. bridge 와 host 는 한 서버 안의 이야기이고 none 은 연결이 없는 모드입니다. `cni plugin not initialized` 오류가 나면 CNI 가 아직 설치되지 않았다는 뜻입니다.')

if __name__ == '__main__':
    preview(b)
