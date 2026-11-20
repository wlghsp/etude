import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 533 도커 네트워크 안쪽 들여다보기: bridge·서브넷·이름 해석. 명세: docs/specs/spec_gap_set533.md
# 샌드박스 docker(dind). 이미지는 alpine 만 쓴다. 각 문제의 setup 은 앞 문제가 남긴 컨테이너·네트워크·파일을 먼저 정리한다.

CLEAN = "rm -f /tmp/*.txt /tmp/*.sh; docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; "
ALP = lambda name, net='': f"docker run -d --name {name} {('--network ' + net + ' ') if net else ''}alpine sleep 3600 >/dev/null; "
LAB = "docker network create --subnet 198.51.100.0/24 labnet >/dev/null; "
SUB = "{{range .IPAM.Config}}{{.Subnet}}{{end}}"
GW = "{{range .IPAM.Config}}{{.Gateway}}{{end}}"
BRGW = f"$(docker network inspect -f '{GW}' bridge)"

b = SetBuilder(533, '도커 네트워크 안쪽 들여다보기: bridge·서브넷·이름 해석',
               '도커 네트워크가 실제로 어떻게 생겼는지 직접 열어 봅니다. 기본 bridge 의 서브넷·게이트웨이, 컨테이너 안의 IP 와 기본 경로, 호스트 쪽 docker0 와 br- 인터페이스, 기본 bridge 와 사용자 정의 bridge 의 이름 해석 차이, 밖으로 나갈 때의 NAT(MASQUERADE) 규칙, network connect·disconnect, nc 로 하는 접속 확인까지 한 칸씩 확인합니다.',
               'docker', '도커', 34, 754, '🌐',
               [{"title": "Docker 브리지 네트워크", "url": "https://docs.docker.com/engine/network/drivers/bridge/"}, {"title": "docker network inspect", "url": "https://docs.docker.com/reference/cli/docker/network/inspect/"}], 3)

b.nt('기본 bridge 의 서브넷과 게이트웨이 찾기',
     '컨테이너를 따로 네트워크 지정 없이 띄우면 도커가 만들어 둔 **기본 `bridge` 네트워크**에 붙습니다. 이 네트워크가 쓰는 **서브넷**(예: `a.b.c.d/16` 모양)을 `/tmp/subnet.txt` 에, **게이트웨이** 주소를 `/tmp/gw.txt` 에 저장하세요. (값만, 다른 글자 없이)',
     '`docker network inspect bridge` 의 출력에서 IPAM 항목을 찾아 보세요. `-f` 와 Go 템플릿으로 필요한 값만 뽑을 수 있습니다.',
     "docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' bridge > /tmp/subnet.txt\ndocker network inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' bridge > /tmp/gw.txt\ncat /tmp/subnet.txt /tmp/gw.txt\n\n# 네트워크의 IPAM 에 서브넷(주소 범위)과 게이트웨이(밖으로 나가는 문)가 들어 있다",
     CLEAN,
     [chk('서브넷이 저장되어 있다', f'[ "$(tr -d "[:space:]" < /tmp/subnet.txt)" = "$(docker network inspect -f \'{SUB}\' bridge)" ]'),
      chk('게이트웨이가 저장되어 있다', f'[ -n "$(tr -d "[:space:]" < /tmp/gw.txt)" ] && [ "$(tr -d "[:space:]" < /tmp/gw.txt)" = "{BRGW}" ]')])

b.nt('컨테이너 안에서 IP 와 기본 경로 확인하기',
     '`c1` 컨테이너(기본 bridge)가 실행 중입니다. **컨테이너 안에서** `ip addr`·`ip route` 로 `eth0` 의 IPv4 주소(값만)를 `/tmp/c1_ip.txt` 에, 기본 경로(`default via ...`)의 게이트웨이 주소를 `/tmp/c1_gw.txt` 에 저장하세요. `docker exec c1 ...` 로 실행합니다.',
     '컨테이너 안에서 실행하는 `ip` 명령은 주소 정보와 경로 정보를 따로 보여 줍니다. 필요한 줄을 찾은 뒤 값만 남기세요.',
     "docker exec c1 ip -4 addr show eth0 | grep -o 'inet [0-9.]*' | cut -d' ' -f2 > /tmp/c1_ip.txt\ndocker exec c1 ip route | grep default | cut -d' ' -f3 > /tmp/c1_gw.txt\ncat /tmp/c1_ip.txt /tmp/c1_gw.txt\n\n# 컨테이너의 기본 경로(default via)는 bridge 의 게이트웨이(호스트 쪽 docker0 주소)를 가리킨다",
     CLEAN + ALP('c1'),
     [chk('컨테이너 IP 가 저장되어 있다', '[ "$(tr -d "[:space:]" < /tmp/c1_ip.txt)" = "$(docker inspect -f "{{.NetworkSettings.Networks.bridge.IPAddress}}" c1)" ]'),
      chk('기본 경로의 게이트웨이가 저장되어 있다', f'[ -n "$(tr -d "[:space:]" < /tmp/c1_gw.txt)" ] && [ "$(tr -d "[:space:]" < /tmp/c1_gw.txt)" = "{BRGW}" ]')])

b.nt('호스트 쪽 docker0 인터페이스 보기',
     '앞에서 본 게이트웨이 주소는 허공에 있는 것이 아니라, 도커가 돌아가는 **호스트(이 샌드박스) 쪽의 가상 스위치 인터페이스**에 붙어 있습니다. 호스트 쪽에서 `docker0` 인터페이스의 정보(주소 포함)를 보여 주는 `ip` 명령의 출력을 `/tmp/docker0.txt` 에 저장하세요.',
     '`ip` 명령의 `addr` 하위 명령에 인터페이스 이름을 붙이면 그 인터페이스만 보여 줍니다. 컨테이너 안이 아니라 호스트 쪽 셸에서 실행합니다.',
     "ip addr show docker0 > /tmp/docker0.txt\ncat /tmp/docker0.txt\n\n# docker0 는 기본 bridge 의 호스트 쪽 가상 스위치다. 이 인터페이스의 주소가 곧 bridge 의 게이트웨이",
     CLEAN,
     [chk('docker0 정보가 저장되어 있다', 'grep -q docker0 /tmp/docker0.txt'),
      chk('docker0 의 주소가 bridge 의 게이트웨이와 같다', f'grep -q "inet {BRGW}/" /tmp/docker0.txt')])

b.nt('기본 bridge: IP 로는 되고 이름으로는 안 된다',
     '`d1` 과 `d2` 는 둘 다 **기본 bridge** 에 있습니다. `d1` 에서 `d2` 에게 (1) **`d2` 의 IP 주소**로 `ping -c 1` 한 결과를 `/tmp/byip.txt` 에, (2) **`d2` 라는 이름**으로 `ping -c 1` 한 결과(오류 메시지 포함)를 `/tmp/byname.txt` 에 저장하세요. 이름 쪽은 실패하는 것이 정상입니다. `d2` 의 IP 는 `docker inspect` 로 찾습니다.',
     '오류 메시지는 표준 오류(stderr)로 나옵니다. 파일에 함께 담으려면 리다이렉션에 표준 오류도 포함해야 합니다. `d2` 의 IP 는 `docker inspect -f` 로 뽑을 수 있습니다.',
     "D2IP=$(docker inspect -f '{{.NetworkSettings.Networks.bridge.IPAddress}}' d2)\ndocker exec d1 ping -c 1 $D2IP > /tmp/byip.txt 2>&1\ndocker exec d1 ping -c 1 d2 > /tmp/byname.txt 2>&1\ncat /tmp/byip.txt /tmp/byname.txt\n\n# 기본 bridge 에는 이름 해석(DNS)이 없어 IP 로만 통한다",
     CLEAN + ALP('d1') + ALP('d2'),
     [chk('IP 로 ping 이 성공한 기록이 있다', 'grep -q "1 packets received" /tmp/byip.txt && grep -q "$(docker inspect -f "{{.NetworkSettings.Networks.bridge.IPAddress}}" d2)" /tmp/byip.txt'),
      chk('이름으로 ping 이 이름 해석 실패한 기록이 있다', 'grep -q "bad address" /tmp/byname.txt')])

b.nt('사용자 정의 bridge 를 만들면 이름으로 통한다',
     '이번에는 직접 네트워크를 만듭니다. 서브넷을 **`198.51.100.0/24`** 로 정한 `labnet` 이라는 bridge 네트워크를 만들고, 그 안에 `xa`, `yb` 컨테이너(`alpine`, `sleep 3600`)를 실행하세요. 그리고 `xa` 에서 `yb` 를 **이름으로** `ping -c 1` 한 결과를 `/tmp/ping.txt` 에 저장하세요.',
     '`docker network create` 에는 서브넷을 지정하는 옵션이 있습니다(`--help` 로 확인). 컨테이너를 그 네트워크에 붙이는 옵션은 `docker run` 의 `--network` 입니다.',
     "docker network create --subnet 198.51.100.0/24 labnet\ndocker run -d --name xa --network labnet alpine sleep 3600\ndocker run -d --name yb --network labnet alpine sleep 3600\ndocker exec xa ping -c 1 yb > /tmp/ping.txt\ncat /tmp/ping.txt\n\n# 사용자 정의 bridge 에서는 컨테이너 이름이 IP 로 풀린다. --subnet 으로 대역도 직접 정할 수 있다",
     CLEAN,
     [chk('labnet 의 서브넷이 198.51.100.0/24 이다', f'[ "$(docker network inspect -f \'{SUB}\' labnet)" = 198.51.100.0/24 ]'),
      chk('xa 와 yb 가 labnet 에서 실행 중이다', '[ "$(docker network inspect -f "{{range .Containers}}{{.Name}} {{end}}" labnet | tr " " "\\n" | grep -cx -e xa -e yb)" = 2 ]'),
      chk('이름으로 ping 이 성공한 기록이 있다', 'grep -q "1 packets received" /tmp/ping.txt')])

b.choice('사용자 정의 bridge 에서 이름이 풀리는 이유',
         '`labnet` 안의 컨테이너에서 `cat /etc/resolv.conf` 를 하면 `nameserver 127.0.0.11` 이 보입니다. 기본 bridge 의 컨테이너에서는 이 줄이 호스트의 DNS 설정을 따라갑니다. 사용자 정의 bridge 에서 컨테이너 이름이 IP 로 풀리는 이유로 맞는 것은 무엇일까요?',
         '`127.0.0.11` 은 컨테이너 자기 자신 쪽(루프백 대역) 주소입니다. 그 주소에서 누가 질문을 받아 주는지 생각해 보세요.',
         ['도커 데몬이 컨테이너 안에 내장 DNS 서버를 열어, 같은 네트워크 컨테이너의 이름을 IP 로 답해 준다', '도커가 모든 컨테이너의 `/etc/hosts` 에 호스트 전체의 이름을 복사해 넣는다', '`docker0` 인터페이스가 이름을 IP 로 바꿔 준다', '컨테이너들이 서로 브로드캐스트로 이름을 물어본다'], 0,
         '사용자 정의 네트워크의 컨테이너는 도커의 내장 DNS(`127.0.0.11`)를 쓰고, 이 DNS 가 같은 네트워크에 속한 컨테이너 이름과 별칭을 IP 로 답해 줍니다. 기본 bridge 에는 이 기능이 없어 IP 를 직접 써야 합니다. `/etc/hosts` 복사나 브로드캐스트 방식이 아니며, `docker0` 는 패킷을 전달하는 가상 스위치일 뿐 이름을 해석하지 않습니다.')

b.nt('직접 만든 네트워크의 호스트 쪽 인터페이스 (br-...)',
     '`labnet` 을 만들면 호스트에는 `docker0` 와 별개로 **`br-` 로 시작하는 새 인터페이스**가 생깁니다. `labnet` 에 해당하는 인터페이스의 정보(`ip addr`)를 `/tmp/br.txt` 에 저장하세요. 인터페이스 이름은 직접 찾아야 합니다.',
     '전체 인터페이스는 `ip addr` 로 볼 수 있습니다. 인터페이스 이름은 `br-` 뒤에 **네트워크 ID 의 앞부분**이 붙습니다. `docker network ls` 의 ID 와 맞춰 보세요.',
     "ID=$(docker network inspect -f '{{.Id}}' labnet | cut -c1-12)\nip addr show br-$ID > /tmp/br.txt\ncat /tmp/br.txt\n\n# 사용자 정의 bridge 마다 호스트에 br-<네트워크ID 앞 12자> 인터페이스가 생기고, 그 주소가 게이트웨이다",
     CLEAN + LAB + ALP('zed', 'labnet'),
     [chk('labnet 의 br- 인터페이스 정보가 저장되어 있다', 'grep -q "br-$(docker network inspect -f "{{.Id}}" labnet | cut -c1-12)" /tmp/br.txt'),
      chk('게이트웨이 주소(198.51.100.1)가 보인다', 'grep -q "inet 198.51.100.1/24" /tmp/br.txt')])

b.nt('밖으로 나갈 때의 주소 변환 (MASQUERADE) 규칙',
     '컨테이너의 IP(`198.51.100.x`)는 이 호스트 안에서만 쓰는 사설 주소라, 밖으로 나갈 때는 호스트의 주소로 **바꿔서(NAT)** 나갑니다. 도커는 네트워크를 만들 때 이 규칙을 방화벽에 자동으로 넣습니다. `iptables -t nat -S POSTROUTING` 의 규칙 중 `labnet` 의 서브넷(`198.51.100.0/24`)에 해당하는 줄만 골라 `/tmp/nat.txt` 에 저장하세요.',
     '`iptables -t nat -S POSTROUTING` 은 규칙을 한 줄씩 보여 줍니다. 서브넷 문자열로 `grep` 하면 해당 줄만 남습니다. 줄 끝의 `-j` 뒤가 어떤 동작인지 읽어 보세요.',
     "iptables -t nat -S POSTROUTING | grep 198.51.100.0/24 > /tmp/nat.txt\ncat /tmp/nat.txt\n\n# -s 198.51.100.0/24 ! -o br-... -j MASQUERADE : 이 대역에서 나가는 패킷의 출발 주소를 호스트 주소로 바꾼다",
     CLEAN + LAB + ALP('zed', 'labnet'),
     [chk('labnet 서브넷의 NAT 규칙이 저장되어 있다', 'grep -q 198.51.100.0/24 /tmp/nat.txt'),
      chk('규칙의 동작이 MASQUERADE 이다', 'grep -q MASQUERADE /tmp/nat.txt')])

b.nt('실행 중인 컨테이너를 다른 네트워크에도 붙이기',
     '`app` 컨테이너는 기본 bridge 에서 실행 중이고, `labnet`(`198.51.100.0/24`)도 이미 있습니다. `app` 을 **새로 만들지 않고** `labnet` 에도 연결하되, `labnet` 에서의 주소를 **`198.51.100.50`** 으로 고정하세요. 그 뒤 `app` 안에서 `ip addr` 를 실행한 결과를 `/tmp/app_if.txt` 에 저장하세요. (기본 bridge 쪽 연결은 그대로 둡니다)',
     '`docker network connect --help` 에서 주소를 지정하는 옵션을 찾아 보세요. 컨테이너는 네트워크 여러 개에 동시에 붙을 수 있고, 붙을 때마다 인터페이스(`eth0`, `eth1`...)가 하나씩 늘어납니다.',
     "docker network connect --ip 198.51.100.50 labnet app\ndocker exec app ip addr > /tmp/app_if.txt\ncat /tmp/app_if.txt\n\n# connect 하면 컨테이너 안에 인터페이스가 하나 더 생긴다. 기존 연결(bridge)은 그대로 유지된다",
     CLEAN + LAB + ALP('app'),
     [chk('app 이 labnet 에서 198.51.100.50 을 쓴다', '[ "$(docker inspect -f "{{.NetworkSettings.Networks.labnet.IPAddress}}" app)" = 198.51.100.50 ]'),
      chk('app 은 기본 bridge 에도 남아 있다', 'docker inspect -f "{{json .NetworkSettings.Networks}}" app | grep -q "\\"bridge\\""'),
      chk('컨테이너 안 인터페이스 정보가 저장되어 있다', 'grep -q 198.51.100.50 /tmp/app_if.txt && [ "$(grep -c "^[0-9]*: eth" /tmp/app_if.txt)" = 2 ]')])

b.fill('네트워크에서 컨테이너 떼어 내기', '`app` 컨테이너를 **지우지 않고** `labnet` 네트워크와의 연결만 끊는 명령입니다. 빈칸을 채우세요.', '`connect` 의 반대 동작을 하는 하위 명령입니다.',
       'docker network {0} labnet app', ['disconnect', 'detach', 'remove', 'leave'], [0],
       '`docker network disconnect <네트워크> <컨테이너>` 는 컨테이너를 그대로 두고 그 네트워크와의 연결만 끊습니다. 컨테이너 안의 해당 인터페이스도 사라집니다. `detach`·`leave` 는 하위 명령이 아니고, `remove`(`rm`)는 네트워크 자체를 지우는 명령이라 컨테이너 이름을 받지 않습니다.')

b.nt('nc 로 포트 접속 확인하기',
     '`labnet` 에서 `srv` 컨테이너가 **9000 번 포트**를 열어 두고 접속하는 쪽에게 한 줄 인사를 보내는 중입니다. `labnet` 에 붙은 **새 임시 컨테이너**(`alpine`, `--rm`)에서 `nc` 로 `srv` 의 9000 번에 이름으로 접속해, 받은 내용을 `/tmp/nc.txt` 에 저장하세요. (`nc` 는 연결 대기 시간 옵션 `-w 3` 을 붙이면 멈추지 않습니다)',
     '`docker run --rm --network ...` 로 같은 네트워크의 임시 컨테이너를 띄워야 이름이 풀립니다. `nc <호스트> <포트>` 형식입니다. 호스트 쪽 셸에서 바로 이름을 부르면 풀리지 않는 이유도 떠올려 보세요.',
     "docker run --rm --network labnet alpine nc -w 3 srv 9000 > /tmp/nc.txt\ncat /tmp/nc.txt\n\n# nc 호스트 포트 : 해당 포트에서 듣는 서버가 있으면 연결돼 데이터를 받는다. 없으면 Connection refused",
     CLEAN + LAB + "docker run -d --name srv --network labnet alpine sh -c 'while true; do echo hello-from-srv | nc -l -p 9000; done' >/dev/null; sleep 1",
     [chk('srv 가 labnet 에서 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} srv 2>/dev/null)" = true ]'),
      chk('srv 가 보낸 인사가 저장되어 있다', 'grep -q hello-from-srv /tmp/nc.txt')])

b.order('새 네트워크의 이름 해석을 확인하고 끊어 보기', '아래 단계를 **실행해야 하는 순서**대로 놓으세요. `srv` 가 먼저 실행되고, 처음 `ping` 은 성공하며, 연결을 끊은 뒤의 `ping` 은 이름 해석에 실패하는 흐름입니다.', '네트워크가 먼저 있어야 컨테이너를 붙일 수 있습니다. 성공을 먼저 확인해야 끊은 뒤의 실패가 의미를 가집니다.',
        ['`docker network disconnect labnet srv` 로 srv 를 labnet 에서 떼어 낸다', '`docker run --rm --network labnet alpine ping -c 1 srv` 를 다시 실행하면 `bad address` 로 실패한다', '`docker network create --subnet 198.51.100.0/24 labnet` 으로 네트워크를 만든다', '`docker run --rm --network labnet alpine ping -c 1 srv` 를 처음 실행하면 성공한다', '`docker run -d --name srv --network labnet alpine sleep 3600` 으로 srv 를 labnet 에서 실행한다'], [2, 4, 3, 0, 1],
        '네트워크를 만들고, srv 를 그 안에 띄운 뒤, 같은 네트워크의 임시 컨테이너에서 이름으로 ping 해 성공을 확인합니다. 그다음 srv 를 네트워크에서 떼어 내면 내장 DNS 가 더 이상 srv 이름을 답하지 못해 같은 ping 이 `bad address` 로 실패합니다.')

if __name__ == '__main__':
    preview(b)
