import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 530 포트 공개 직접 해 보기: -p·-P·바인드 주소. 명세: docs/specs/spec_gap_set530.md
# 샌드박스 docker(dind). 이미지는 nginx:alpine, alpine 만 쓴다. 각 문제의 setup 은 앞 문제가 남긴 컨테이너를 먼저 정리한다.

CLEAN = "rm -f /tmp/*.txt; docker rm -f $(docker ps -aq) >/dev/null 2>&1; true; "

b = SetBuilder(530, '포트 공개 직접 해 보기: -p·-P·바인드 주소',
               '컨테이너 안의 웹 서버를 밖에서 접속하게 만드는 -p 옵션을 단계별로 손에 익힙니다. 호스트:컨테이너 포트 연결, 호스트 포트를 다르게 주어 여러 개 띄우기, 127.0.0.1 로 묶어 내부 전용으로 만들기, -P 와 EXPOSE 로 임의 포트 받기, docker port 로 확인하기, 포트 충돌(port is already allocated)을 재현하고 해결하기를 wget 으로 접속을 확인하며 연습합니다.',
               'docker', '도커', 34, 751, '🚪',
               [{"title": "컨테이너 포트 공개", "url": "https://docs.docker.com/engine/network/port-publishing/"}, {"title": "docker port", "url": "https://docs.docker.com/reference/cli/docker/container/port/"}], 3)

b.nt('-p 호스트:컨테이너 로 웹 서버 열기',
     '`nginx:alpine` 컨테이너는 안에서 **80 번 포트**로 웹 페이지를 보여 줍니다. 하지만 컨테이너 안의 포트는 그냥은 밖에서 접속할 수 없고, `-p 호스트포트:컨테이너포트` 로 **연결(공개)** 해야 합니다.\n\n`web` 이라는 이름으로 `nginx:alpine` 컨테이너를 백그라운드로 실행하되, 호스트의 `8080` 을 컨테이너의 `80` 에 연결하세요. 그런 다음 `wget -qO-` 로 `http://localhost:8080` 에 접속한 결과(웹 페이지 내용)를 `/tmp/page.txt` 에 저장하세요. (이 터미널에는 `curl` 대신 `wget` 이 들어 있습니다. `-qO-` 는 진행 표시 없이 내용을 화면에 출력합니다)',
     '`docker run` 에는 백그라운드 실행(`-d`), 이름(`--name`), 포트 연결(`-p`) 옵션이 있습니다. 콜론 왼쪽이 호스트, 오른쪽이 컨테이너입니다. 서버가 뜨는 데 1~2초 걸릴 수 있습니다.',
     "docker run -d --name web -p 8080:80 nginx:alpine\nsleep 2\nwget -qO- http://localhost:8080 > /tmp/page.txt\nhead -5 /tmp/page.txt\n\n# -p 호스트포트:컨테이너포트. 호스트 8080 으로 온 요청이 컨테이너 80 으로 전달된다",
     CLEAN,
     [chk('web 이 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} web 2>/dev/null)" = true ]'),
      chk('호스트 8080 이 컨테이너 80 에 연결돼 있다', 'docker port web | grep -q "^80/tcp -> .*:8080"'),
      chk('nginx 첫 화면이 저장돼 있다', 'grep -q "Welcome to nginx" /tmp/page.txt')])

b.nt('호스트 포트를 다르게 주면 여러 개를 띄울 수 있다',
     '같은 이미지를 두 개 띄우고 싶습니다. **컨테이너 안의 포트는 모두 80** 이지만, 호스트 포트는 컨테이너마다 달라야 합니다(호스트 포트 하나는 컨테이너 하나만 쓸 수 있습니다).\n\n`web1` 은 호스트 `8081`, `web2` 는 호스트 `8082` 로 연결해 `nginx:alpine` 두 개를 백그라운드로 실행하세요. 그런 다음 `wget -qO-` 로 `http://localhost:8081` 의 결과는 `/tmp/p1.txt`, `http://localhost:8082` 의 결과는 `/tmp/p2.txt` 에 저장하세요.',
     '컨테이너 포트(오른쪽)는 두 개 모두 같고 호스트 포트(왼쪽)만 다릅니다. 같은 `wget` 명령을 주소만 바꿔 두 번 실행합니다.',
     "docker run -d --name web1 -p 8081:80 nginx:alpine\ndocker run -d --name web2 -p 8082:80 nginx:alpine\nsleep 2\nwget -qO- http://localhost:8081 > /tmp/p1.txt\nwget -qO- http://localhost:8082 > /tmp/p2.txt\nhead -3 /tmp/p1.txt /tmp/p2.txt\n\n# 호스트 포트는 컨테이너마다 달라야 한다. 컨테이너 안 포트는 같아도 상관없다 (컨테이너마다 자기만의 네트워크 공간)",
     CLEAN,
     [chk('web1 이 8081 에 연결돼 있다', 'docker port web1 | grep -q "^80/tcp -> .*:8081"'),
      chk('web2 가 8082 에 연결돼 있다', 'docker port web2 | grep -q "^80/tcp -> .*:8082"'),
      chk('두 접속 결과가 저장돼 있다', 'grep -q "Welcome to nginx" /tmp/p1.txt && grep -q "Welcome to nginx" /tmp/p2.txt')])

b.choice('-p 8080:80 은 누구에게 열릴까',
         '`docker run -d -p 8080:80 nginx:alpine` 처럼 **호스트 주소를 적지 않고** 포트만 연결하면, 이 서버는 누가 접속할 수 있을까요? (호스트에 방화벽 규칙이 따로 없다고 가정합니다)',
         '`docker port` 로 결과를 보면 `0.0.0.0:8080` 같은 주소가 붙어 나옵니다. 그 주소의 뜻을 생각해 보세요.',
         ['호스트의 모든 네트워크 주소로 오는 요청 (호스트 자신뿐 아니라 같은 네트워크의 다른 PC 에서도)', '호스트 자신(localhost) 에서 오는 요청만', '같은 호스트의 다른 컨테이너에서 오는 요청만', '아무도 접속할 수 없고 컨테이너 안에서만 보인다'], 0,
         '주소를 생략하면 `0.0.0.0`(모든 주소)에 묶입니다. 그래서 호스트의 IP 로 접속하는 다른 PC 에서도 닿습니다. 내 PC 에서만 쓰고 싶으면 다음 문제처럼 `127.0.0.1:` 을 앞에 붙입니다.')

b.nt('127.0.0.1 에 묶어 내부 전용으로 열기',
     '개발용 관리 화면은 **호스트 자신(localhost) 에서만** 보이고, 다른 PC 에서는 접속할 수 없게 하고 싶습니다. `-p` 의 앞에 **바인드할 호스트 주소**를 붙여 `-p 주소:호스트포트:컨테이너포트` 로 쓰면 됩니다.\n\n`admin` 이라는 이름의 `nginx:alpine` 컨테이너를 백그라운드로 실행하되, 호스트 주소 `127.0.0.1` 의 `8083` 을 컨테이너 `80` 에 연결하세요. 그리고 `wget -qO-` 로 `http://127.0.0.1:8083` 에 접속한 결과를 `/tmp/admin.txt` 에 저장하세요.',
     '`-p` 값은 콜론으로 구분된 세 칸입니다. 제일 앞 칸이 호스트 주소입니다. 확인은 `docker port admin` 에서 주소가 `127.0.0.1` 로 나오는지 보면 됩니다.',
     "docker run -d --name admin -p 127.0.0.1:8083:80 nginx:alpine\nsleep 2\ndocker port admin\nwget -qO- http://127.0.0.1:8083 > /tmp/admin.txt\nhead -5 /tmp/admin.txt\n\n# 127.0.0.1 에 묶으면 호스트 자신에서만 닿는다. 외부 PC 가 호스트 IP 로 접속하면 거부된다",
     CLEAN,
     [chk('8083 이 127.0.0.1 에만 묶여 있다', 'docker port admin | grep -q "^80/tcp -> 127.0.0.1:8083$"'),
      chk('nginx 첫 화면이 저장돼 있다', 'grep -q "Welcome to nginx" /tmp/admin.txt')])

b.fill('바인드 주소를 넣는 빈칸', '`web` 컨테이너를 **호스트 자신에서만** 접속되게 `8084` 로 연결하는 명령입니다. 빈칸에 들어갈 호스트 주소를 고르세요.', '내 컴퓨터 자신을 가리키는 주소(루프백)입니다.',
       'docker run -d -p {0}:8084:80 nginx:alpine', ['127.0.0.1', '0.0.0.0', '192.0.2.1', '255.255.255.255'], [0],
       '`127.0.0.1` 은 호스트 자신(루프백)입니다. `0.0.0.0` 은 모든 주소라서 오히려 외부에도 열립니다. `192.0.2.1` 같은 특정 주소는 호스트에 실제로 있는 주소일 때만 쓸 수 있고, `255.255.255.255` 는 브로드캐스트 주소라 바인드에 쓰지 않습니다.')

b.nt('-P 로 임의 포트에 열기 (EXPOSE)',
     '`nginx:alpine` 이미지는 만들 때 `EXPOSE 80` 이 적혀 있어, **80 번 포트를 쓰는 이미지**라는 표시가 들어 있습니다. 이 표시가 있으면 소문자 `-p` 대신 **대문자 `-P`** 로 모든 표시된 포트를 호스트의 **임의의 빈 포트**에 한꺼번에 연결할 수 있습니다. (호스트 포트 번호는 도커가 알아서 고릅니다)\n\n`auto` 라는 이름으로 `nginx:alpine` 을 `-P` 로 백그라운드 실행하세요. 그리고 도커가 80 번에 붙여 준 **호스트 포트 번호만**(예: `32768`) `/tmp/hostport.txt` 에 저장하세요.',
     '`docker port 컨테이너 80` 은 컨테이너 80 번에 연결된 `주소:포트` 를 한 줄로 보여 줍니다. 그 줄에서 번호만 남기려면 `cut` 이나 `awk` 로 콜론 뒤를 자르면 됩니다. 한 줄에 주소가 여러 개 나오면 그중 하나면 충분합니다.',
     "docker run -d --name auto -P nginx:alpine\nsleep 2\ndocker port auto 80\ndocker port auto 80 | head -1 | awk -F: '{print $NF}' > /tmp/hostport.txt\ncat /tmp/hostport.txt\n\n# -P 는 EXPOSE 된 모든 포트를 호스트의 임의 포트(보통 32768 이상)에 연결한다",
     CLEAN,
     [chk('auto 가 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} auto 2>/dev/null)" = true ]'),
      chk('-P 로 실행했다', '[ "$(docker inspect -f {{.HostConfig.PublishAllPorts}} auto 2>/dev/null)" = true ]'),
      chk('저장한 번호가 실제 연결된 호스트 포트다', 'P=$(cat /tmp/hostport.txt) && [ -n "$P" ] && docker port auto 80 | grep -q ":$P$"'),
      chk('임의 포트로 실제 접속이 된다', 'wget -qO- http://localhost:$(cat /tmp/hostport.txt) | grep -q "Welcome to nginx"')])

b.choice('EXPOSE 만 적으면 열릴까',
         'Dockerfile 에 `EXPOSE 80` 이 있는 이미지를 `docker run -d 이미지` 로 **-p·-P 없이** 실행했습니다. 호스트에서 `wget -qO- localhost:80` 으로 접속하면 어떻게 될까요?',
         '`EXPOSE` 는 "이 이미지는 이 포트를 쓴다"는 설명서에 가깝습니다. 실제로 연결하는 것은 무엇인지 앞 문제에서 쓴 옵션을 떠올려 보세요.',
         ['접속되지 않는다. EXPOSE 는 표시일 뿐이고 -p 나 -P 로 연결해야 호스트에서 접속된다', '자동으로 호스트 80 에 연결돼 접속된다', '임의 포트에 자동 연결되므로 80 이 아닌 다른 포트로 접속된다', '이미지를 실행할 수 없다'], 0,
         '`EXPOSE` 는 문서 역할(이 포트를 쓴다는 표시)이고 `-P` 가 그 표시를 보고 임의 포트에 연결합니다. 옵션 없이 실행하면 호스트에는 아무 연결도 생기지 않아, 컨테이너 안에서는 서버가 떠 있어도 밖에서는 접속이 안 됩니다.')

b.nt('docker port 로 연결 상태 확인하기',
     '`shop` 컨테이너는 이미 실행 중이고 호스트의 어느 포트에 연결되어 있는데, 몇 번인지 모릅니다. 컨테이너를 **다시 만들지 않고** 연결 정보를 확인해서, 컨테이너 `80` 에 연결된 **호스트 포트 번호만** `/tmp/shopport.txt` 에 저장하세요. 그런 다음 그 포트로 `wget -qO-` 접속한 결과를 `/tmp/shop.txt` 에 저장하세요.',
     '`docker ps` 의 PORTS 열이나 `docker port 컨테이너` 로 볼 수 있습니다. 출력은 `컨테이너포트/tcp -> 호스트주소:호스트포트` 형태입니다. 번호만 남기는 방법은 앞 문제를 떠올려 보세요.',
     "docker port shop\ndocker port shop 80 | head -1 | awk -F: '{print $NF}' > /tmp/shopport.txt\ncat /tmp/shopport.txt\nwget -qO- http://localhost:$(cat /tmp/shopport.txt) > /tmp/shop.txt\nhead -5 /tmp/shop.txt\n\n# docker port 는 컨테이너 포트 → 호스트 주소:포트 대응을 보여 준다",
     CLEAN + "docker run -d --name shop -p 8097:80 nginx:alpine >/dev/null; sleep 2",
     [chk('shop 은 그대로 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} shop 2>/dev/null)" = true ]'),
      chk('저장한 번호가 실제 호스트 포트다', '[ "$(cat /tmp/shopport.txt)" = 8097 ]'),
      chk('접속 결과가 저장돼 있다', 'grep -q "Welcome to nginx" /tmp/shop.txt')])

b.nt('port is already allocated: 포트 충돌 해결하기',
     '호스트 `8080` 은 이미 `old` 컨테이너가 쓰고 있습니다. 여기에 새 컨테이너 `new` 를 같은 `8080` 으로 열려고 하면 실패합니다.\n\n1. 아래 명령을 실행해 나오는 **오류 메시지**를 `/tmp/err.txt` 에 저장하세요.\n`docker run -d --name new -p 8080:80 nginx:alpine`\n2. `old` 는 **그대로 둔 채**, `new` 가 호스트 `8081` 로 실행 중이게 만드세요. (실패한 `docker run` 은 `new` 라는 이름의 컨테이너를 만들어 둔 채 끝나서, 그대로 같은 이름으로 다시 만들면 이름 충돌이 납니다.)',
     '오류는 표준 오류이므로 `2>` 로 저장합니다. 실패한 컨테이너는 `docker ps -a` 에 남아 있습니다. 먼저 지운 뒤 호스트 포트만 바꿔 다시 만드세요.',
     "docker run -d --name new -p 8080:80 nginx:alpine 2> /tmp/err.txt\ncat /tmp/err.txt\ndocker rm -f new\ndocker run -d --name new -p 8081:80 nginx:alpine\nsleep 2\nwget -qO- http://localhost:8081 | head -3\n\n# 호스트 포트는 하나에 한 컨테이너만. 충돌하면 다른 호스트 포트를 고르거나, 쓰는 쪽을 먼저 내린다. 컨테이너 안 포트(80)는 그대로여도 된다",
     CLEAN + "docker run -d --name old -p 8080:80 nginx:alpine >/dev/null; sleep 2",
     [chk('오류 메시지가 저장돼 있다', 'grep -q "port is already allocated" /tmp/err.txt'),
      chk('new 가 8081 로 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} new 2>/dev/null)" = true ] && docker port new | grep -q "^80/tcp -> .*:8081"'),
      chk('old 는 8080 으로 그대로 실행 중이다', '[ "$(docker inspect -f {{.State.Running}} old 2>/dev/null)" = true ] && docker port old | grep -q "^80/tcp -> .*:8080"')])

b.order('포트를 열고 확인하는 순서', '새 웹 서버 컨테이너를 밖에서 접속되게 만드는 작업을 **순서대로** 놓으세요. (컨테이너 안 서버의 포트를 모르는 상태에서 시작합니다) (연결이 만들어졌는지 먼저 확인하고, 그다음 실제 응답을 확인합니다.)', '각 단계가 앞 단계의 결과를 필요로 하는지 따져 보세요.',
        ['`docker port` 로 호스트 포트가 연결됐는지 본다', '`wget -qO-` 로 호스트 포트에 접속해 본다', '`docker run -d -p 호스트포트:컨테이너포트` 로 실행한다', '이미지 설명(EXPOSE)에서 서버가 듣는 포트를 확인한다'], [3, 2, 0, 1],
        '먼저 서버가 쓰는 포트(EXPOSE·문서)를 알아야 `-p` 오른쪽 칸을 정할 수 있습니다. 실행한 뒤 `docker port` 로 연결이 만들어졌는지 보고, 마지막에 `wget` 으로 실제 응답을 확인합니다. 연결이 없으면 접속이 실패해도 이유를 알 수 없으므로 연결 확인이 접속 확인보다 먼저입니다.')

if __name__ == '__main__':
    preview(b)
