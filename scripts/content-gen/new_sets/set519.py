import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 519 도커 문제 해결 상황집: 네트워크가 안 될 때. 명세: docs/specs/spec_gap_set519.md
# 샌드박스 docker(dind). 이미지는 alpine, nginx:alpine 만 쓴다. 각 문제의 setup 은 앞 문제가 남긴 컨테이너·네트워크를 먼저 정리한다.

CLEAN = "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.env; docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; "
ALP = lambda name, net='': f"docker run -d --name {name} {('--network ' + net + ' ') if net else ''}alpine sleep 3600 >/dev/null; "
NGX = lambda name, net='': f"docker run -d --name {name} {('--network ' + net + ' ') if net else ''}nginx:alpine >/dev/null; "

b = SetBuilder(519, '도커 문제 해결 상황집: 네트워크가 안 될 때',
               '컨테이너끼리 이름으로 접속이 안 되거나, 접속 거부·응답 없음이 나는 상황을 직접 재현된 환경에서 고칩니다. bad address(이름 해석 실패), 서로 다른 네트워크, Connection refused(포트·localhost 착각), -p 의 컨테이너 포트 오류, 사용 중인 네트워크 삭제 오류, 서브넷 겹침(Pool overlaps), --internal 로 막힌 외부 통신을 오류 메시지 → 원인 → 고치기 순서로 해결합니다.',
               'docker', '도커', 26, 740, '🔌',
               [{"title": "Docker 네트워크 개요", "url": "https://docs.docker.com/engine/network/"}, {"title": "docker network connect", "url": "https://docs.docker.com/reference/cli/docker/network/connect/"}], 2)

b.nt('bad address: 기본 네트워크에서는 이름이 안 통한다',
     '`client` 컨테이너에서 `db` 컨테이너를 이름으로 부르면 `docker exec client ping -c 1 db` 가 `ping: bad address \'db\'` 로 실패합니다. 두 컨테이너는 모두 **네트워크를 따로 정하지 않고** 만든 것입니다. 두 컨테이너를 **새로 만들지 않고** 그대로 둔 채, 이름으로 통하게 고치세요. 고친 뒤 `client` 에서 `db` 로 ping 한 결과를 `/tmp/ping.txt` 에 저장하세요. (네트워크 이름은 자유)',
     '컨테이너 이름이 IP 로 풀리는 네트워크는 어떤 종류인지 먼저 떠올려 보세요. 이미 실행 중인 컨테이너를 네트워크에 붙이는 하위 명령은 `docker network --help` 에서 찾을 수 있습니다.',
     "docker network create appnet\ndocker network connect appnet db\ndocker network connect appnet client\ndocker exec client ping -c 1 db > /tmp/ping.txt\ncat /tmp/ping.txt\n\n# 기본 bridge 에서는 이름 해석(DNS)이 없다. 사용자 정의 네트워크를 만들어 두 컨테이너를 붙이면 이름이 IP 로 풀린다",
     CLEAN + ALP('db') + ALP('client'),
     [chk('client 가 db 를 이름으로 부를 수 있다', 'docker exec client ping -c 1 -W 2 db >/dev/null 2>&1'),
      chk('ping 결과를 저장했다', 'grep -q "1 packets received" /tmp/ping.txt'),
      chk('두 컨테이너가 모두 실행 중이다', '[ "$(docker ps -q --filter name=^db$ --filter name=^client$ | wc -l)" = 2 ]')])

b.nt('서로 다른 네트워크에 있어서 이름이 안 통한다',
     '`web` 컨테이너에서 `docker exec web ping -c 1 db` 를 하면 `bad address \'db\'` 가 납니다. 이번에는 둘 다 **직접 만든 네트워크**에 있는데도 안 됩니다. `db` 컨테이너가 **어느 네트워크**에 있는지 찾아 그 이름을 `/tmp/dbnet.txt` 에 저장하고, `web` 의 **기존 네트워크는 그대로 둔 채** `web` 이 `db` 를 이름으로 부를 수 있게 만드세요.',
     '`docker inspect` 의 출력에서 네트워크 정보가 들어 있는 부분을 찾아 보세요. `-f` 와 템플릿으로 이름만 뽑을 수도 있습니다. 그 뒤 `web` 을 그 네트워크에 추가로 붙입니다.',
     "docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}' db > /tmp/dbnet.txt\ncat /tmp/dbnet.txt\ndocker network connect $(cat /tmp/dbnet.txt) web\ndocker exec web ping -c 1 db\n\n# 이름은 같은 네트워크 안에서만 풀린다. 컨테이너는 네트워크 여러 개에 동시에 붙을 수 있다",
     CLEAN + "docker network create front >/dev/null; docker network create back >/dev/null; " + ALP('db', 'back') + ALP('web', 'front'),
     [chk('db 의 네트워크 이름이 저장되어 있다', '[ "$(cat /tmp/dbnet.txt)" = back ]'),
      chk('web 이 db 를 이름으로 부를 수 있다', 'docker exec web ping -c 1 -W 2 db >/dev/null 2>&1'),
      chk('web 은 front 네트워크에도 그대로 있다', 'docker inspect -f "{{json .NetworkSettings.Networks}}" web | grep -q front')])

b.nt('Connection refused: 포트가 다르다',
     '`/tmp/check.sh` 는 `appnet` 네트워크에서 `web` 컨테이너(nginx)로 접속해 보는 스크립트입니다. 실행하면 `wget: can\'t connect to remote host (...): Connection refused` 가 납니다. 이름은 풀렸는데 접속이 **거부**됩니다. 원인을 찾아 스크립트를 고치고, 실행한 결과(웹 페이지 내용)를 `/tmp/page.txt` 에 저장하세요.',
     '이름 해석은 되는데 거부된다는 것은 그 주소의 **그 포트에서 듣는 프로세스가 없다**는 뜻입니다. nginx 컨테이너가 실제로 어느 포트에서 듣는지 이미지 정보나 `docker port`·`docker top` 같은 도구로 확인해 보세요.',
     "sed -i 's/web:8080/web:80/' /tmp/check.sh\nsh /tmp/check.sh > /tmp/page.txt\nhead -5 /tmp/page.txt\n\n# nginx 는 80 번에서 듣는다. refused = 주소는 닿았지만 그 포트를 여는 프로세스가 없다 (포트 번호 오류, 서버 미기동 등)",
     CLEAN + "docker network create appnet >/dev/null; " + NGX('web', 'appnet') + "sleep 2; printf '%s\\n' 'docker run --rm --network appnet alpine wget -qO- -T 3 http://web:8080' > /tmp/check.sh",
     [chk('스크립트가 8080 을 더 이상 쓰지 않는다', '! grep -q 8080 /tmp/check.sh'),
      chk('nginx 첫 화면이 저장되어 있다', 'grep -q "Welcome to nginx" /tmp/page.txt')])

b.nt('-p 로 열었는데 응답이 없다',
     '`web` 컨테이너(nginx)를 `-p 8080:8080` 으로 띄웠는데, 서버 쪽에서 `wget http://127.0.0.1:8080` 을 하면 **응답 없이 연결이 끊깁니다**. 컨테이너는 실행 중이고 8080 도 열려 있는 것처럼 보입니다. `web` 을 **같은 이름으로 다시 만들어** 호스트 8080 으로 nginx 첫 화면이 보이게 고치세요.',
     '`docker port web` 은 어느 포트가 어느 포트로 이어지는지 보여 줍니다. 오른쪽 숫자(컨테이너 포트)가 nginx 가 실제로 듣는 포트와 같은지 확인하세요. 설정이 틀린 컨테이너는 포트를 바꿀 수 없으니 지우고 다시 만듭니다.',
     "docker port web\ndocker rm -f web\ndocker run -d --name web -p 8080:80 nginx:alpine\nsleep 2\ndocker port web\n\n# -p 호스트포트:컨테이너포트. 오른쪽은 컨테이너 안 서버가 실제로 듣는 포트여야 한다",
     CLEAN + "docker run -d --name web -p 8080:8080 nginx:alpine >/dev/null; sleep 2",
     [chk('web 의 80 번 포트가 호스트 8080 으로 열려 있다', 'docker port web | grep -q "^80/tcp -> .*:8080"'),
      chk('호스트 8080 으로 nginx 화면이 나온다', 'docker run --rm --network host alpine wget -qO- -T 3 http://127.0.0.1:8080 | grep -q "Welcome to nginx"')])

b.nt('network has active endpoints: 네트워크가 안 지워진다',
     '`docker network rm appnet` 을 하면 `Error response from daemon: error while removing network: network appnet has active endpoints` 가 납니다. `appnet` 은 이제 필요 없지만, 그 안에 있는 `app` 컨테이너는 **지우지 말고 남겨 두어야** 합니다. `appnet` 을 삭제하세요.',
     '오류 메시지의 endpoint 는 그 네트워크에 연결된 컨테이너를 뜻합니다. 컨테이너를 지우지 않고 네트워크 연결만 끊는 하위 명령을 `docker network --help` 에서 찾아 보세요.',
     "docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' appnet\ndocker network disconnect appnet app\ndocker network rm appnet\ndocker ps --format '{{.Names}}'\n\n# 연결된 컨테이너가 있으면 네트워크를 못 지운다. 컨테이너를 지우거나, disconnect 로 연결만 끊는다",
     CLEAN + "docker network create appnet >/dev/null; " + ALP('app', 'appnet'),
     [chk('appnet 네트워크가 없다', '! docker network ls --format "{{.Name}}" | grep -qx appnet'),
      chk('app 컨테이너는 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} app 2>/dev/null)" = true ]')])

b.nt('Pool overlaps: 서브넷이 겹친다',
     '새 네트워크를 `docker network create --subnet 10.77.0.0/24 newnet` 으로 만들려 하면 `Error response from daemon: invalid pool request: Pool overlaps with other one on this address space` 가 납니다. 이미 `oldnet` 이 그 대역을 쓰고 있고, 그 안의 `legacy` 컨테이너는 서비스 중이라 **건드릴 수 없습니다**. `oldnet` 과 `legacy` 는 그대로 두고, `newnet` 네트워크를 겹치지 않게 만든 뒤 그 안에 `app` 컨테이너(`alpine`, `sleep 3600`)를 실행하세요.',
     '`docker network inspect` 의 IPAM 항목에서 `oldnet` 이 쓰는 대역을 확인하세요. 같은 대역만 피하면 됩니다. 대역을 직접 정하지 않고 도커에 맡겨도 됩니다.',
     "docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' oldnet\ndocker network create --subnet 10.78.0.0/24 newnet\ndocker run -d --name app --network newnet alpine sleep 3600\ndocker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' newnet\n\n# 서로 다른 네트워크의 IP 대역은 겹칠 수 없다. 다른 대역을 고르거나 --subnet 을 생략한다",
     CLEAN + "docker network create --subnet 10.77.0.0/24 oldnet >/dev/null; " + ALP('legacy', 'oldnet'),
     [chk('newnet 이 있고 oldnet 과 대역이 다르다', 'S=$(docker network inspect -f "{{range .IPAM.Config}}{{.Subnet}}{{end}}" newnet) && [ -n "$S" ] && [ "$S" != 10.77.0.0/24 ]'),
      chk('app 이 newnet 에서 실행 중이다', '[ "$(docker inspect -f "{{.State.Running}} {{json .NetworkSettings.Networks}}" app | grep -c "true.*newnet")" = 1 ]'),
      chk('oldnet 과 legacy 는 그대로다', 'docker network inspect oldnet >/dev/null && [ "$(docker inspect -f {{.State.Running}} legacy)" = true ]')])

b.nt('바깥으로 못 나간다: --internal 네트워크',
     '`worker` 컨테이너가 `isolated` 네트워크에 있는데, **외부로 나가는 통신이 전혀 안 됩니다**. `docker exec worker ip route` 의 결과에는 **기본 경로(`default via ...`)가 없습니다**. 원인을 찾아 `worker` 가 바깥으로 나갈 길(기본 경로)을 갖게 고치고, 고친 뒤의 `docker exec worker ip route` 결과를 `/tmp/route.txt` 에 저장하세요. (`worker` 는 이 이름으로 실행 중이어야 합니다)',
     '`docker network inspect isolated` 의 출력에서 이 네트워크가 가진 **특별한 속성**을 찾아 보세요. 속성은 만든 뒤 바꿀 수 없습니다. 바깥으로 나가는 길이 있는 다른 네트워크에 붙이거나, 속성 없이 새로 만드는 방법이 있습니다.',
     "docker network inspect -f '{{.Internal}}' isolated\ndocker network connect bridge worker\ndocker exec worker ip route > /tmp/route.txt\ncat /tmp/route.txt\n\n# --internal 로 만든 네트워크는 바깥으로 나가는 기본 경로가 없다. 외부 통신이 필요하면 일반 네트워크(bridge 등)에도 붙인다",
     CLEAN + "docker network create --internal isolated >/dev/null; " + ALP('worker', 'isolated'),
     [chk('worker 에 기본 경로가 있다', 'docker exec worker ip route | grep -q "^default"'),
      chk('결과를 저장했다', 'grep -q "^default" /tmp/route.txt'),
      chk('worker 는 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} worker 2>/dev/null)" = true ]')])

b.nt('localhost 로 적어 놓은 접속 주소',
     '앱 설정 파일 `/tmp/app.env` 에 `DB_HOST=localhost` 라고 적혀 있습니다. 같은 `appnet` 네트워크의 `db` 컨테이너(nginx)로 접속하는 아래 명령이 `Connection refused` 로 실패합니다.\n\n`docker run --rm --network appnet --env-file /tmp/app.env alpine sh -c \'wget -qO- -T 3 http://$DB_HOST\'`\n\n설정 파일을 고친 뒤 같은 명령을 다시 실행해 그 결과(웹 페이지 내용)를 `/tmp/out.txt` 에 저장하세요.',
     '컨테이너 안에서 `localhost` 는 누구를 가리키는지 생각해 보세요. 같은 네트워크의 다른 컨테이너는 무엇으로 부를 수 있었는지 앞 문제를 떠올려 보세요.',
     "sed -i 's/^DB_HOST=.*/DB_HOST=db/' /tmp/app.env\ndocker run --rm --network appnet --env-file /tmp/app.env alpine sh -c 'wget -qO- -T 3 http://$DB_HOST' > /tmp/out.txt\nhead -5 /tmp/out.txt\n\n# 컨테이너 안의 localhost 는 그 컨테이너 자신이다. 다른 컨테이너는 같은 네트워크의 컨테이너 이름으로 부른다",
     CLEAN + "docker network create appnet >/dev/null; " + NGX('db', 'appnet') + "sleep 2; echo DB_HOST=localhost > /tmp/app.env",
     [chk('설정 파일이 db 를 가리킨다', 'grep -qx "DB_HOST=db" /tmp/app.env'),
      chk('nginx 첫 화면이 저장되어 있다', 'grep -q "Welcome to nginx" /tmp/out.txt')])

b.choice('"bad address" 는 무엇이 문제일까',
         '컨테이너 안에서 `wget http://db` 를 했더니 `wget: bad address \'db\'` 가 났습니다. 이 메시지가 가리키는 문제는 무엇일까요?',
         '메시지에 나온 단어가 **주소**입니다. 주소를 얻지 못한 것인지, 주소는 있는데 연결이 안 되는 것인지 구별해 보세요.',
         ['`db` 라는 이름을 IP 주소로 바꾸지 못했다 (같은 사용자 정의 네트워크가 아니거나 이름 오타)', '`db` 의 IP 는 찾았지만 그 포트에서 듣는 서버가 없다', '`db` 컨테이너가 너무 많은 연결을 받아 거부했다', '이미지를 내려받지 못했다'], 0,
         'bad address 는 이름 해석(DNS) 실패입니다. 이름이 IP 로 풀리는 것은 같은 사용자 정의 네트워크 안에서만이므로, 네트워크가 다르거나 기본 bridge 이거나 이름 오타일 때 납니다. IP 는 얻었는데 포트에서 듣는 서버가 없으면 `Connection refused`, 다른 쪽은 이 메시지와 관련이 없습니다.')
b.choice('"Connection refused" 가 났을 때',
         '컨테이너 이름으로 접속했더니 이름은 IP 로 풀렸는데 `Connection refused` 가 납니다. 가장 먼저 의심할 것은 무엇일까요?',
         '이름 해석은 통과했으니 그 단계는 문제가 아닙니다. 접속을 거부한 쪽이 무엇을 못 찾았는지 생각해 보세요.',
         ['DNS 서버 주소가 틀렸다', '접속한 포트 번호가 틀렸거나, 그 포트에서 듣는 프로세스가 없다', '컨테이너 이미지가 너무 크다', '두 컨테이너가 서로 다른 호스트 OS 를 쓴다'], 1,
         '이름이 풀렸다는 것은 네트워크와 DNS 는 문제가 아니라는 뜻입니다. refused 는 그 IP 의 그 포트에서 아무도 듣지 않을 때 돌려받는 응답이라, 포트 번호 오류나 서버 미기동을 의심합니다. 이미지 크기나 호스트 OS 는 관계가 없습니다.')
b.fill('실행 중인 컨테이너를 네트워크에 붙이기', '이미 실행 중인 `db` 컨테이너를 `appnet` 네트워크에 **붙이는** 명령입니다. 빈칸을 채우세요.', '네트워크와 컨테이너를 잇는다는 뜻의 동사입니다.',
       'docker network {0} appnet db', ['connect', 'join', 'attach', 'link'], [0],
       '`docker network connect <네트워크> <컨테이너>` 로 실행 중인 컨테이너를 네트워크에 추가합니다. 반대는 `disconnect` 입니다. `join`·`attach`·`link` 는 `docker network` 의 하위 명령이 아닙니다.')
b.order('이름으로 접속이 안 될 때 확인 순서', '컨테이너 `client` 가 `db` 에 이름으로 접속하지 못할 때, 원인을 좁혀 가는 **점검 순서**대로 카드를 놓으세요.', '문제를 한 겹씩 좁혀 가는 방법을 떠올려 보세요. 앞 단계가 확인되어야 뒤 단계의 결과를 믿을 수 있습니다.',
        ['`docker exec client ping db` 로 이름이 풀리는지 본다', '`docker ps` 로 두 컨테이너가 실행 중인지 본다', '`docker exec client wget db:80` 으로 포트 접속을 본다', '`docker inspect` 로 두 컨테이너가 같은 네트워크에 있는지 본다'], [1, 3, 0, 2],
        '먼저 두 컨테이너가 살아 있는지 확인하고, 같은 네트워크에 있는지 봅니다. 그 다음 이름이 풀리는지, 마지막으로 그 포트에서 접속이 되는지를 봅니다. 앞 단계가 안 되면 뒤 단계의 실패는 의미가 없어 순서대로 좁혀야 합니다.')

if __name__ == '__main__':
    preview(b)
