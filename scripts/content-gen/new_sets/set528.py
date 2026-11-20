import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 528 사설 레지스트리 쓰기: 이름 구조·tag·push·pull·login. 명세: docs/specs/spec_gap_set528.md
# 레지스트리는 registry:2 를 localhost:5000 으로 띄운다(localhost 는 http 허용). 확인은 샌드박스 기본 도구인 wget 으로 한다.

PRE = ("docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker volume rm regdata >/dev/null 2>&1; "
       "docker rmi -f myapp:local localhost:5000/myalpine:1.0 localhost:5000/app:1.0 localhost:5000/app:2.0 localhost:5000/tools:1.0 >/dev/null 2>&1; rm -f /tmp/q*.txt; "
       "docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; "
       "docker image inspect registry:2 >/dev/null 2>&1 || docker pull -q registry:2 >/dev/null 2>&1; true\n")
WAIT = "for i in $(seq 1 40); do wget -qO- -T 1 http://localhost:5000/v2/ >/dev/null 2>&1 && break; sleep 0.5; done\n"
REG = "docker run -d --name reg -p 5000:5000 registry:2 >/dev/null\n" + WAIT
PUSH_APP = ("docker tag alpine localhost:5000/app:1.0; docker tag alpine localhost:5000/app:2.0; docker tag alpine localhost:5000/tools:1.0; "
            "docker push -q localhost:5000/app:1.0 >/dev/null; docker push -q localhost:5000/app:2.0 >/dev/null; docker push -q localhost:5000/tools:1.0 >/dev/null\n")

b = SetBuilder(528, '사설 레지스트리 쓰기: 이름 구조·tag·push·pull·login',
               '이미지 이름의 구조(주소:포트/저장소:태그)를 읽고, registry:2 로 내 컴퓨터에 레지스트리를 띄워 tag → push → pull 하고, 카탈로그와 태그 목록을 확인하고, 데이터를 볼륨에 보관하고, docker login 이 하는 일을 이해합니다.',
               'docker', '도커', 33, 749, '🏪',
               [{"title": "Docker Registry 배포", "url": "https://distribution.github.io/distribution/about/deploying/"}, {"title": "docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "docker login", "url": "https://docs.docker.com/reference/cli/docker/login/"}], 5)

# 1 ------------------------------------------------------------
b.choice('이미지 이름 읽기',
         '이미지 이름 `registry.example.com:5000/team/web:2.1` 에서 **레지스트리 서버의 주소**에 해당하는 부분은 어디인가요?',
         '이름은 `/` 로 나뉩니다. 맨 앞 조각이 서버처럼 보이는지(도메인·포트) 살펴보세요.',
         ['registry.example.com:5000', 'team/web', 'web:2.1', '2.1'], 0,
         '이미지 이름은 `주소:포트/저장소:태그` 구조입니다. `registry.example.com:5000` 이 레지스트리 주소, `team/web` 이 저장소(이미지 이름), `2.1` 이 태그입니다. 주소를 생략하면 도커는 Docker Hub(`docker.io`)로 간주합니다.')

# 2 ------------------------------------------------------------
b.nt('내 컴퓨터에 레지스트리 띄우기',
     '레지스트리도 **컨테이너로 실행하는 프로그램**입니다. 공식 이미지 `registry:2` 는 컨테이너 안의 **5000번 포트**에서 이미지를 받아 보관합니다.\n\n`registry:2` 이미지로 컨테이너를 만들어 다음 조건을 맞추세요.\n- 이름: `reg`\n- 백그라운드(`-d`)로 실행\n- 호스트의 5000번 포트와 컨테이너의 5000번 포트를 연결(`-p 호스트:컨테이너`)',
     '`docker run` 에 이름(`--name`), 백그라운드(`-d`), 포트(`-p`) 옵션을 붙이고 마지막에 이미지 이름을 적습니다.',
     "docker run -d --name reg -p 5000:5000 registry:2\n\n# 호스트 5000 번을 컨테이너 5000 번(레지스트리)에 연결한다",
     PRE,
     [chk('reg 컨테이너가 실행 중이다', '[ "$(docker inspect -f "{{.State.Running}}" reg 2>/dev/null)" = true ]'),
      chk('localhost:5000 이 레지스트리 API 에 답한다', 'wget -qO- -T 3 http://localhost:5000/v2/ | grep -q "{}"')])

# 3 ------------------------------------------------------------
b.nt('레지스트리 주소를 이름에 붙이기: docker tag',
     '로컬에 있는 `alpine` 이미지를 내 레지스트리에 올리려면, 이미지 **이름 앞에 레지스트리 주소가 붙어야** 합니다. 이름만 바꿔 별명을 하나 더 만드는 명령이 `docker tag 원래이름 새이름` 입니다. (이미지 내용은 복사되지 않고 이름표만 늘어납니다.)\n\n`alpine` 에 `localhost:5000/myalpine:1.0` 이라는 이름을 붙이세요.',
     '`docker tag` 는 원래 이름과 새 이름 두 개를 받습니다. 결과는 `docker images` 로 확인할 수 있습니다.',
     "docker tag alpine localhost:5000/myalpine:1.0\ndocker images | grep myalpine\n\n# 주소:포트/저장소:태그 형태의 새 이름을 붙인다",
     PRE,
     [chk('localhost:5000/myalpine:1.0 이름이 있다', 'docker image inspect localhost:5000/myalpine:1.0 >/dev/null 2>&1')])

# 4 ------------------------------------------------------------
b.nt('레지스트리에 올리기: docker push',
     '`reg` 레지스트리가 이미 5000번 포트에서 떠 있고, `alpine` 에는 `localhost:5000/myalpine:1.0` 이름이 붙어 있습니다. `docker push` 는 이름 앞의 **주소로 접속해서** 이미지를 올립니다.\n\n`localhost:5000/myalpine:1.0` 을 레지스트리에 올리세요.',
     '`docker push` 뒤에 올릴 이미지의 **전체 이름**을 적습니다. 올라갔는지는 다음 문제에서 확인합니다.',
     "docker push localhost:5000/myalpine:1.0\n\n# 이름 앞의 localhost:5000 서버로 올라간다",
     PRE + REG + "docker tag alpine localhost:5000/myalpine:1.0\n",
     [chk('레지스트리 카탈로그에 myalpine 이 있다', 'wget -qO- -T 3 http://localhost:5000/v2/_catalog | grep -q myalpine')])

# 5 ------------------------------------------------------------
b.nt('레지스트리 안의 저장소 목록 보기: _catalog',
     '레지스트리는 HTTP API 를 제공합니다. `/v2/_catalog` 주소를 열면 올라간 **저장소(이미지 이름) 목록**이 JSON 으로 나옵니다. 샌드박스에서는 `wget -qO- 주소` 로 내용을 화면에 출력할 수 있습니다. (`-q` 는 진행 표시 끄기, `-O-` 는 파일 대신 화면 출력)\n\n`reg` 레지스트리에는 이미지 몇 개가 올라가 있습니다. 카탈로그 응답을 `/tmp/q5.txt` 에 저장하세요.',
     '주소는 `http://localhost:5000/v2/` 뒤에 `_catalog` 를 붙입니다. 출력은 `>` 로 파일에 저장합니다.',
     "wget -qO- http://localhost:5000/v2/_catalog > /tmp/q5.txt\ncat /tmp/q5.txt\n\n# {\"repositories\":[...]} 형태로 저장소 이름 목록이 나온다",
     PRE + REG + PUSH_APP,
     [chk('저장 파일에 저장소 목록이 있다', 'grep -q repositories /tmp/q5.txt'), chk('app 과 tools 가 보인다', 'grep -q app /tmp/q5.txt && grep -q tools /tmp/q5.txt')])

# 6 ------------------------------------------------------------
b.fill('카탈로그 주소',
       '레지스트리에 올라간 저장소 목록을 보는 API 주소입니다. 빈칸을 채우세요.',
       '앞 문제에서 직접 쓴 주소의 마지막 조각입니다. 앞 문제의 출력 설명을 다시 보세요.',
       'wget -qO- http://localhost:5000/v2/{0}', ['_catalog', 'catalog', 'repositories', 'list'], [0],
       '`/v2/_catalog` 가 저장소 목록 API 입니다. 앞의 밑줄(`_`)까지 이름의 일부입니다. 특정 저장소의 태그 목록은 `/v2/저장소이름/tags/list` 입니다.')

# 7 ------------------------------------------------------------
b.nt('저장소의 태그 목록 보기: tags/list',
     '한 저장소 안에 **어떤 태그가 올라가 있는지** 보려면 `/v2/저장소이름/tags/list` 주소를 엽니다. 예를 들어 저장소 이름이 `tools` 라면 `/v2/tools/tags/list` 입니다.\n\n`reg` 레지스트리의 `app` 저장소에 태그가 몇 개 올라가 있습니다. 그 태그 목록 응답을 `/tmp/q7.txt` 에 저장하세요.',
     '`wget -qO-` 뒤 주소는 `http://localhost:5000/v2/` + 저장소 이름 + `/tags/list` 입니다. 저장소 이름은 `app` 입니다.',
     "wget -qO- http://localhost:5000/v2/app/tags/list > /tmp/q7.txt\ncat /tmp/q7.txt\n\n# {\"name\":\"app\",\"tags\":[...]} 형태로 태그 목록이 나온다",
     PRE + REG + PUSH_APP,
     [chk('저장 파일에 app 의 태그 목록이 있다', 'grep -q \'"tags"\' /tmp/q7.txt && grep -q \'"app"\' /tmp/q7.txt'), chk('두 태그가 모두 보인다', 'grep -q "1.0" /tmp/q7.txt && grep -q "2.0" /tmp/q7.txt')])

# 8 ------------------------------------------------------------
b.nt('레지스트리에서 받아 다른 이름으로 쓰기',
     '레지스트리에 `localhost:5000/app:1.0` 이 올라가 있고, 이 컴퓨터에는 그 이미지가 **없습니다**. 다른 컴퓨터에서 받아 쓰는 상황을 흉내 낸 것입니다.\n\n1. `docker pull` 로 `localhost:5000/app:1.0` 을 받으세요.\n2. 받은 이미지에 짧은 이름 `myapp:local` 을 `docker tag` 로 추가하세요.',
     '`docker pull` 에도 전체 이름이 필요합니다. 받은 뒤에는 `docker tag` 로 이름표를 하나 더 붙입니다.',
     "docker pull localhost:5000/app:1.0\ndocker tag localhost:5000/app:1.0 myapp:local\ndocker images | grep -E 'app'\n\n# 레지스트리에서 받은 이미지에 짧은 이름을 더 붙인다",
     PRE + REG + PUSH_APP + "docker rmi localhost:5000/app:1.0 localhost:5000/app:2.0 localhost:5000/tools:1.0 >/dev/null 2>&1; true\n",
     [chk('myapp:local 이 있다', 'docker image inspect myapp:local >/dev/null 2>&1'), chk('레지스트리에서 받은 이미지다', 'docker image inspect -f "{{.RepoDigests}}" myapp:local | grep -q "localhost:5000/app"')])

# 9 ------------------------------------------------------------
b.choice('주소를 생략하면',
         '레지스트리 주소 없이 `docker pull nginx` 만 실행하면 도커는 실제로 어디서 어떤 이름으로 받나요?',
         '주소·네임스페이스·태그를 모두 생략했을 때의 기본값을 떠올려 보세요.',
         ['docker.io/library/nginx:latest (Docker Hub 의 공식 이미지, 태그 latest)', 'localhost:5000/nginx:latest (내 컴퓨터 레지스트리)', '가장 최근에 받은 레지스트리의 nginx', '현재 폴더의 nginx 파일'], 0,
         '주소를 생략하면 Docker Hub(`docker.io`), 공식 이미지는 `library/` 네임스페이스, 태그를 생략하면 `latest` 가 기본입니다. 그래서 `nginx` 는 `docker.io/library/nginx:latest` 와 같습니다.')

# 10 -----------------------------------------------------------
b.choice('push 가 거부될 때',
         '`docker tag alpine myapp:1.0` 만 한 뒤 `docker push myapp:1.0` 을 실행했더니 아래처럼 실패했습니다. 가장 알맞은 원인은?\n```\ndenied: requested access to the resource is denied\n```',
         '`myapp:1.0` 에는 레지스트리 주소가 있나요? 주소가 없을 때 도커가 어디로 올리려는지 생각해 보세요.',
         ['이름에 레지스트리 주소가 없어 Docker Hub 로 올리려다 권한이 없어서 거부되었다 (localhost:5000/myapp:1.0 으로 tag 해야 한다)', '내 레지스트리 컨테이너가 꺼져 있다', '이미지 크기가 너무 크다', '태그가 숫자라서 올릴 수 없다'], 0,
         '주소가 없는 이름은 Docker Hub 로 간주되므로, 로그인하지 않았거나 그 네임스페이스 권한이 없으면 거부됩니다. 내 레지스트리로 보내려면 먼저 `docker tag alpine localhost:5000/myapp:1.0` 처럼 주소를 붙인 뒤 push 합니다. 레지스트리가 꺼져 있으면 `connection refused` 류의 다른 메시지가 나옵니다.')

# 11 -----------------------------------------------------------
b.nt('레지스트리 데이터를 볼륨에 보관하기',
     '레지스트리 컨테이너는 올라온 이미지를 컨테이너 안의 `/var/lib/registry` 에 저장합니다. 볼륨 없이 띄우면 **컨테이너를 지우는 순간 이미지도 모두 사라집니다.**\n\n`registry:2` 로 다음 조건의 컨테이너를 만드세요.\n- 이름: `reg`, 백그라운드 실행, 호스트 5000 → 컨테이너 5000 포트\n- 이름이 `regdata` 인 **볼륨**을 컨테이너의 `/var/lib/registry` 에 마운트(`-v 볼륨이름:경로`)',
     '`-v` 의 왼쪽에 볼륨 이름, 오른쪽에 컨테이너 안 경로를 적습니다. 볼륨 이름은 미리 만들지 않아도 처음 쓸 때 만들어집니다.',
     "docker run -d --name reg -p 5000:5000 -v regdata:/var/lib/registry registry:2\n\n# 이미지 데이터가 regdata 볼륨에 저장되어 컨테이너를 지워도 남는다",
     PRE,
     [chk('reg 컨테이너가 실행 중이다', '[ "$(docker inspect -f "{{.State.Running}}" reg 2>/dev/null)" = true ]'),
      chk('regdata 볼륨이 /var/lib/registry 에 마운트되어 있다', 'docker inspect -f "{{range .Mounts}}{{.Name}}:{{.Destination}} {{end}}" reg | grep -q "regdata:/var/lib/registry"')])

# 12 -----------------------------------------------------------
b.choice('docker login 이 하는 일',
         '비밀번호가 필요한 레지스트리에 `docker login registry.example.com` 으로 로그인했습니다. 이에 대한 설명으로 알맞은 것은?',
         '로그인은 한 번 하면 다음 push·pull 에서 다시 묻지 않습니다. 그 정보가 어딘가에 남아 있어야 합니다.',
         ['인증 정보가 사용자 홈의 ~/.docker/config.json 에 레지스트리 주소별로 저장되고, docker logout 으로 지운다', '로그인하면 그 서버의 모든 이미지가 내 컴퓨터로 자동으로 내려받아진다', '로그인 정보는 컨테이너 안에만 저장되어 컨테이너를 지우면 로그아웃된다', '로그인은 push 에만 필요하고 비공개 이미지를 pull 할 때는 필요 없다'], 0,
         '`docker login` 은 서버 주소별로 인증 정보를 `~/.docker/config.json` 에 저장하며(자격 증명 도우미를 설정하지 않으면 base64 로 인코딩된 형태라 암호화는 아니므로 파일 권한에 주의), `docker logout 주소` 로 지웁니다. 비공개 이미지는 pull 할 때도 로그인이 필요합니다. 이 실습 레지스트리(`localhost:5000`)는 인증이 없어 로그인이 필요 없습니다.')

# 13 -----------------------------------------------------------
b.order('내 레지스트리에 올리고 다시 받는 순서',
        '내 컴퓨터에서 레지스트리를 띄우고, `alpine` 을 올린 뒤, 정말 올라갔는지 **로컬 이미지를 지우고 다시 받아서** 확인하려 합니다. 알맞은 순서대로 카드를 놓으세요. (지우는 것은 올린 뒤 로컬 이름입니다.) (레지스트리 컨테이너를 띄우는 것으로 시작하고, 이름표는 레지스트리가 뜬 뒤에 붙이는 것으로 합니다.)',
        '푸시하기 전에 필요한 준비물이 무엇인지, 로컬을 지운 뒤에 무엇을 해야 올라간 것이 증명되는지 생각해 보세요.',
        ['docker push localhost:5000/myalpine:1.0', 'docker pull localhost:5000/myalpine:1.0', 'docker run -d --name reg -p 5000:5000 registry:2', 'docker rmi localhost:5000/myalpine:1.0', 'docker tag alpine localhost:5000/myalpine:1.0'], [2, 4, 0, 3, 1],
        '레지스트리 컨테이너를 먼저 띄우고, `docker tag` 로 주소가 붙은 이름을 만들고, `docker push` 로 올립니다. 로컬 이름을 `docker rmi` 로 지운 뒤 `docker pull` 로 다시 받아 오면 레지스트리에 정말 올라갔다는 확인이 됩니다.')

if __name__ == '__main__':
    preview(b)
