import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 529 도커 문제 해결 상황집: 레지스트리 오류 읽기. 명세: docs/specs/spec_gap_set529.md
# 샌드박스 docker(dind). 각 setup 이 로컬 레지스트리(registry:2, localhost:5000)를 직접 띄우고 이미지를 올린다. 세트 528 에 의존하지 않는다.
# 인증 문제(7번)는 htpasswd 가 걸린 두 번째 레지스트리(localhost:5001)를 쓴다. 계정 student / etude-pass1 은 실습용 값이다.

# 앞 문제가 남긴 컨테이너(볼륨 포함)·로컬 이미지·로그인 정보·작업 파일을 먼저 지운다.
PRE = ("docker rm -fv $(docker ps -aq) >/dev/null 2>&1; "
       "docker image ls --format '{{.Repository}}:{{.Tag}}' | grep '^localhost:' | xargs -r docker rmi -f >/dev/null 2>&1; "
       "docker logout localhost:5001 >/dev/null 2>&1; rm -rf /tmp/work /tmp/auth /tmp/*.txt /tmp/*.sh; "
       "docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true\n")

WAIT = 'for i in $(seq 1 30); do wget -qO- http://localhost:5000/v2/ >/dev/null 2>&1 && break; sleep 1; done\n'


def PUSH(repo, tag, msg, port=5000):
    """alpine 으로 msg 를 출력하는 이미지를 만들어 레지스트리에 올리고, 내 컴퓨터의 사본은 지운다."""
    ref = f'localhost:{port}/{repo}:{tag}'
    return (f"printf 'FROM alpine\\nCMD [\"echo\",\"{msg}\"]\\n' | docker build -q -t {ref} - >/dev/null && "
            f"docker push -q {ref} >/dev/null && docker rmi {ref} >/dev/null\n")


# 레지스트리 localhost:5000 에 team/app(1.0·1.1), team/worker(1.0), tools/cli(1.0) 이 들어 있다. latest 태그는 일부러 올리지 않는다.
REG = ("docker run -d --name reg -p 5000:5000 registry:2 >/dev/null\n" + WAIT
       + PUSH('team/app', '1.0', 'app-1.0') + PUSH('team/app', '1.1', 'app-1.1')
       + PUSH('team/worker', '1.0', 'worker-1.0') + PUSH('tools/cli', '1.0', 'cli-1.0'))


def OUT(n, expect):
    return chk(f'/tmp/q{n}.txt 에 {expect} 가 있다', f'grep -qx "{expect}" /tmp/q{n}.txt')


b = SetBuilder(529, '도커 문제 해결 상황집: 레지스트리 오류 읽기',
               '이미지를 받을 때 레지스트리가 돌려주는 오류를 직접 재현해 읽고 고칩니다. 태그 오타(not found·manifest unknown), latest 태그가 없는 경우, 저장소 이름 오타와 대문자(invalid reference format), 레지스트리가 꺼진 경우(connection refused), HTTP 레지스트리(server gave HTTP response to HTTPS client)와 insecure-registries, 로그인이 필요한 경우(unauthorized)와 "repository does not exist or may require docker login" 메시지의 뜻을 구분합니다.',
               'docker', '도커', 26, 750, '🔎',
               [{"title": "Docker 레지스트리 개요", "url": "https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-registry/"}, {"title": "안전하지 않은 레지스트리 테스트", "url": "https://docs.docker.com/reference/cli/dockerd/#insecure-registries"}, {"title": "docker login", "url": "https://docs.docker.com/reference/cli/docker/login/"}], 1)

# 1 ------------------------------------------------------------
b.nt('태그 오타: not found / manifest unknown',
     '**상황** — 팀 레지스트리(`localhost:5000`)에서 `team/app` 의 **1.1 버전**을 받으려고 `/tmp/pull1.sh` 를 실행했는데 이렇게 실패합니다.\n```\nError response from daemon: ... localhost:5000/team/app:1.11: not found\n```\n(도커 버전에 따라 `manifest unknown` 이 함께 나옵니다.) 레지스트리에 **저장소는 있는데 그 태그가 없다**는 뜻입니다. 레지스트리는 `http://localhost:5000/v2/<저장소>/tags/list` 주소로 **있는 태그 목록**을 JSON 으로 알려 줍니다.\n\n1. 목록을 `wget -qO-` (주소 내용을 화면에 출력) 로 받아 `/tmp/tags.txt` 에 저장하세요.\n2. `/tmp/pull1.sh` 의 태그 오타를 고쳐 다시 실행해 이미지를 받으세요.',
     '목록 주소의 저장소 부분은 스크립트에 적힌 이미지 이름에서 `localhost:5000/` 뒤의 `team/app` 입니다. 목록에서 1.1 과 가장 비슷한 태그를 찾아 스크립트와 비교해 보세요.',
     "wget -qO- http://localhost:5000/v2/team/app/tags/list > /tmp/tags.txt\ncat /tmp/tags.txt\nsed -i 's/1\\.11/1.1/' /tmp/pull1.sh\nsh /tmp/pull1.sh\n\n# 레지스트리에 있는 태그는 1.0, 1.1 뿐이다. 존재하지 않는 1.11 을 요청해서 not found 였다",
     PRE + REG + "echo 'docker pull localhost:5000/team/app:1.11' > /tmp/pull1.sh\n",
     [chk('태그 목록이 저장되어 있다', 'grep -q "\\"1.0\\"" /tmp/tags.txt && grep -q "\\"1.1\\"" /tmp/tags.txt'),
      chk('team/app:1.1 이미지를 받았다', 'docker image inspect localhost:5000/team/app:1.1 >/dev/null 2>&1')])

# 2 ------------------------------------------------------------
b.nt('latest 태그가 없는 레지스트리',
     '**상황** — 이름만 적고 태그를 **생략**하면 어떻게 될까요?\n```\n$ docker pull localhost:5000/team/app\nError response from daemon: ... localhost:5000/team/app:latest: not found\n```\n태그를 생략하면 도커는 **`latest` 라는 이름의 태그**를 요청합니다. 그런데 이 레지스트리에는 `latest` 를 올린 적이 없어 not found 가 납니다. (`latest` 는 "가장 최신"이 아니라 그냥 **태그 이름 하나**입니다.)\n\n`team/app` 에 **있는 태그를 목록 주소**(`http://localhost:5000/v2/team/app/tags/list`)로 확인하고, **가장 높은 버전**을 실행해서 그 출력을 `/tmp/q2.txt` 에 저장하세요. (이미지를 `docker run --rm 이미지:태그` 로 실행하면 이름이 출력됩니다.)',
     '태그 목록에서 가장 높은 번호를 고른 뒤, `docker run --rm localhost:5000/team/app:<태그>` 의 출력을 파일로 저장합니다.',
     "wget -qO- http://localhost:5000/v2/team/app/tags/list\ndocker run --rm localhost:5000/team/app:1.1 > /tmp/q2.txt 2>/dev/null\ncat /tmp/q2.txt\n\n# latest 는 올린 적이 없다. 목록에서 가장 높은 1.1 을 명시한다",
     PRE + REG,
     [OUT(2, 'app-1.1')])

# 3 ------------------------------------------------------------
b.choice('latest 는 가장 최신 버전인가',
         '레지스트리에 `team/app` 의 1.0, 1.1 두 태그만 올라가 있습니다. 누군가 `docker pull localhost:5000/team/app` 을 실행했더니 `not found` 가 났습니다. 이때 `latest` 에 대한 설명으로 옳은 것은 무엇인가요?',
         '`latest` 를 "자동으로 정해 주는 값"으로 생각하는지, "누가 붙여야 하는 이름"으로 생각하는지 구분해 보세요.',
         ['latest 는 특별한 기능이 없는 태그 이름일 뿐이라, 누군가 latest 로 올리지 않으면 존재하지 않는다', '레지스트리가 가장 나중에 올라온 태그에 latest 를 자동으로 붙여 준다', 'latest 는 항상 가장 높은 버전 번호를 가리킨다', '태그를 생략하면 도커가 레지스트리의 모든 태그 중 하나를 골라 준다'], 0,
         '태그를 생략하면 도커는 `:latest` 를 요청하고, 그 이름의 태그가 없으면 not found 입니다. `latest` 는 **푸시하는 사람이 붙이는** 일반 태그 이름이라 최신 버전이라는 보장도 없습니다. 그래서 운영에서는 `1.1` 처럼 **버전을 명시**하는 것이 안전합니다.')

# 4 ------------------------------------------------------------
b.nt('저장소 이름 오타',
     '**상황** — `/tmp/pull3.sh` 로 워커 이미지를 실행하려는데 이렇게 실패합니다.\n```\nError response from daemon: ... localhost:5000/team/wroker:1.0: not found\n```\n이번에는 태그(`1.0`)가 아니라 **저장소 이름**이 틀렸습니다. 레지스트리에 어떤 저장소가 있는지는 `http://localhost:5000/v2/_catalog` 주소(카탈로그)가 JSON 으로 알려 줍니다.\n\n1. 카탈로그를 `wget -qO-` 로 받아 `/tmp/repos.txt` 에 저장하세요.\n2. `/tmp/pull3.sh` 의 저장소 이름을 고쳐 실행하고, 컨테이너 출력을 `/tmp/q3.txt` 에 저장하세요.',
     '카탈로그에서 `wroker` 와 글자가 비슷한 저장소를 찾으세요. 스크립트 안의 이름만 고치면 됩니다. 실행 출력은 `>` 로 저장합니다.',
     "wget -qO- http://localhost:5000/v2/_catalog > /tmp/repos.txt\ncat /tmp/repos.txt\nsed -i 's/wroker/worker/' /tmp/pull3.sh\nsh /tmp/pull3.sh > /tmp/q3.txt 2>/dev/null\ncat /tmp/q3.txt\n\n# 저장소는 team/app, team/worker, tools/cli. wroker 는 오타",
     PRE + REG + "echo 'docker run --rm localhost:5000/team/wroker:1.0' > /tmp/pull3.sh\n",
     [chk('카탈로그가 저장되어 있다', 'grep -q "team/worker" /tmp/repos.txt'),
      OUT(3, 'worker-1.0')])

# 5 ------------------------------------------------------------
b.nt('invalid reference format: 대문자',
     '**상황** — `/tmp/run4.sh` 를 실행하면 레지스트리에 접속하기도 전에 이렇게 실패합니다.\n```\ndocker: invalid reference format: repository name (Team/app) must be lowercase\n```\n이미지 이름의 **저장소 부분은 소문자**여야 합니다. 이 오류는 레지스트리가 아니라 **도커 명령이 이름 형식을 보고** 내는 것이라 네트워크와 상관없습니다.\n\n스크립트를 고쳐 실행하고 컨테이너 출력을 `/tmp/q4.txt` 에 저장하세요.',
     '스크립트에 적힌 이미지 이름에서 대문자가 들어간 글자를 찾으세요. 레지스트리 주소·태그 모양은 그대로 둡니다.',
     "sed -i 's#Team/app#team/app#' /tmp/run4.sh\nsh /tmp/run4.sh > /tmp/q4.txt 2>/dev/null\ncat /tmp/q4.txt\n\n# 저장소 이름은 소문자만 허용된다 (Team -> team)",
     PRE + REG + "echo 'docker run --rm localhost:5000/Team/app:1.0' > /tmp/run4.sh\n",
     [OUT(4, 'app-1.0')])

# 6 ------------------------------------------------------------
b.nt('connection refused: 레지스트리가 꺼져 있다',
     '**상황** — 어제까지 되던 `/tmp/pull5.sh` 가 오늘은 이렇게 실패합니다.\n```\nError response from daemon: ... Head "https://localhost:5000/v2/team/app/manifests/1.1": dial tcp 127.0.0.1:5000: connect: connection refused\n```\n`not found` 와 달리 **레지스트리 서버까지 연결 자체가 안 된 것**입니다. 이름·태그를 고쳐도 소용없고, 서버(레지스트리 컨테이너)가 살아 있는지 봐야 합니다. 이 레지스트리는 `reg` 라는 컨테이너입니다.\n\n`reg` 컨테이너 상태를 확인하고 **새로 만들지 말고** 그대로 되살린 뒤, `/tmp/pull5.sh` 를 실행해 이미지를 받고 그 이미지의 출력을 `/tmp/q5.txt` 에 저장하세요. (저장된 이미지가 그대로 남아 있습니다.)',
     '`docker ps` 는 실행 중인 컨테이너만 보여 줍니다. 멈춘 것까지 보려면 옵션을 하나 더 붙입니다. 멈춘 컨테이너를 다시 시작하는 명령도 있습니다.',
     "docker ps -a --filter name=reg\ndocker start reg\nsleep 2\nsh /tmp/pull5.sh\ndocker run --rm localhost:5000/team/app:1.1 > /tmp/q5.txt\ncat /tmp/q5.txt\n\n# 컨테이너를 지우지 않고 멈춘 것이라 start 만 하면 이미지가 그대로 있다",
     PRE + REG + "echo 'docker pull localhost:5000/team/app:1.1' > /tmp/pull5.sh\ndocker stop reg >/dev/null\n",
     [chk('reg 컨테이너가 실행 중이다', '[ "$(docker inspect -f "{{.State.Running}}" reg 2>/dev/null)" = true ]'),
      OUT(5, 'app-1.1')])

# 7 ------------------------------------------------------------
b.nt('server gave HTTP response to HTTPS client',
     '**상황** — 레지스트리 `reg` 를 **컨테이너의 IP 주소**로 접근하는 `/tmp/pull6.sh` 가 이렇게 실패합니다.\n```\nError response from daemon: ... Head "https://172.x.x.x:5000/v2/...": http: server gave HTTP response to HTTPS client\n```\n도커는 레지스트리에 기본으로 **HTTPS** 로 접속합니다. 그런데 이 레지스트리는 **HTTP** 로 대답한다는 뜻입니다. 정석 해결은 도커 데몬 설정(`/etc/docker/daemon.json`)의 안전하지 않은 레지스트리 항목에 주소를 적고 **데몬을 재시작**하는 것입니다. 단, 이 실습 환경에서는 데몬을 설정할 수 없습니다. 다행히 도커는 **`localhost` 같은 루프백 주소는 HTTP 도 허용**하므로, 같은 레지스트리를 `localhost:5000` 으로 부르면 됩니다.\n\n1. `sh /tmp/pull6.sh` 를 실행하고 **오류 메시지를 `/tmp/err6.txt` 에** 저장하세요 (`2>` 는 오류 출력만 파일로 보냅니다).\n2. 스크립트의 주소를 `localhost:5000` 으로 고쳐 실행해 `team/app:1.0` 이미지를 받으세요.',
     '오류 출력은 표준 오류(2번)로 나옵니다. 스크립트에 적힌 `IP:5000` 부분만 `localhost:5000` 으로 바꾸면 됩니다.',
     "sh /tmp/pull6.sh 2> /tmp/err6.txt\ncat /tmp/err6.txt\nsed -i 's#[0-9.]*:5000#localhost:5000#' /tmp/pull6.sh\nsh /tmp/pull6.sh\n\n# IP 주소의 HTTP 레지스트리는 기본으로 거부된다. localhost(루프백)는 HTTP 가 허용되어 같은 레지스트리를 받을 수 있다",
     PRE + REG + "IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' reg)\necho \"docker pull $IP:5000/team/app:1.0\" > /tmp/pull6.sh\n",
     [chk('저장한 오류에 HTTPS 클라이언트 메시지가 있다', 'grep -q "HTTP response to HTTPS client" /tmp/err6.txt'),
      chk('localhost:5000 의 team/app:1.0 을 받았다', 'docker image inspect localhost:5000/team/app:1.0 >/dev/null 2>&1')])

# 8 ------------------------------------------------------------
b.fill('insecure-registries 설정 키',
       'HTTP 로 대답하는 사내 레지스트리 `192.0.2.10:5000` 을 도커가 받아들이도록 `/etc/docker/daemon.json` 에 적는 설정입니다. 빈칸에 들어갈 키 이름을 고르세요.',
       '`daemon.json` 에는 이 예외 주소를 목록 형태로 적습니다. 같은 뜻의 명령줄 옵션과 이름이 한 글자 다르다는 점에 주의하세요.',
       '{ "{0}": ["192.0.2.10:5000"] }', ['insecure-registries', 'insecure-registry', 'allow-http-registries', 'unsafe-hosts'], [0],
       '`daemon.json` 의 키는 복수형 `insecure-registries` 이고 값은 `host:port` 배열입니다. 같은 설정을 명령줄 옵션으로 줄 때는 단수형 `--insecure-registry` 라서 헷갈리기 쉽습니다. 나머지 이름은 도커에 없는 키입니다. 적은 뒤에는 데몬을 재시작해야 반영되고, 운영에서는 가능하면 HTTP 대신 TLS 를 쓰는 것이 안전합니다.')

# 9 ------------------------------------------------------------
b.nt('unauthorized: 로그인이 필요한 레지스트리',
     '**상황** — 비공개 레지스트리 `localhost:5001` 의 `private/app:1.0` 을 받으려고 하면 이렇게 실패합니다.\n```\nError response from daemon: Head "http://localhost:5001/v2/private/app/manifests/1.0": no basic auth credentials\n```\n(레지스트리에 따라 `unauthorized: authentication required` 로 나옵니다.) 이미지가 **없는 것이 아니라 로그인(인증)이 필요**하다는 뜻입니다. 이 실습용 레지스트리의 계정은 사용자 `student`, 비밀번호 `etude-pass1` 입니다.\n\n로그인한 뒤 `private/app:1.0` 을 받아 실행하고, 출력을 `/tmp/q7.txt` 에 저장하세요. (비밀번호를 명령줄에 직접 쓰면 이력에 남으므로, 실제로는 `--password-stdin` 을 권장합니다.)',
     '`docker login` 뒤에 **레지스트리 주소**를 적으면 사용자명과 비밀번호를 묻습니다. 사용자명·비밀번호 옵션을 쓰거나 질문에 직접 입력해도 됩니다.',
     "echo etude-pass1 | docker login localhost:5001 -u student --password-stdin\ndocker run --rm localhost:5001/private/app:1.0 > /tmp/q7.txt 2>/dev/null\ncat /tmp/q7.txt\n\n# 로그인하면 자격 증명이 저장되어 pull·run 이 통과한다",
     PRE + REG
     + "mkdir -p /tmp/auth\ncat > /tmp/auth/htpasswd <<'EOF'\nstudent:$2y$05$8KhklZIH03ZZ1lItqrbU4ebl7IpaIVsuDf0H2nHVftvK.3tPu7/lG\nEOF\n"
     + "docker run -d --name regauth -p 5001:5000 -v /tmp/auth:/auth -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM=etude -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd registry:2 >/dev/null\n"
     + "for i in $(seq 1 30); do wget -S -qO- http://localhost:5001/v2/ 2>&1 | grep -q 401 && break; sleep 1; done\n"
     + "echo etude-pass1 | docker login localhost:5001 -u student --password-stdin >/dev/null 2>&1\n"
     + PUSH('private/app', '1.0', 'private-1.0', 5001) + "docker logout localhost:5001 >/dev/null 2>&1\n",
     [OUT(7, 'private-1.0'), chk('private/app:1.0 이미지를 받았다', 'docker image inspect localhost:5001/private/app:1.0 >/dev/null 2>&1')])

# 10 -----------------------------------------------------------
b.choice('repository does not exist or may require docker login',
         '`docker pull mycompany/appp:1.0` 을 실행하자 이런 오류가 났습니다. 메시지가 두 가지 가능성을 함께 말하는 이유로 가장 알맞은 것은 무엇인가요?\n```\npull access denied for mycompany/appp, repository does not exist or may require \'docker login\'\n```',
         '레지스트리가 "없다"와 "권한이 없다"를 구분해서 알려 주면 어떤 정보가 새어 나갈지 생각해 보세요.',
         ['비공개 저장소의 존재 여부를 알리지 않으려고, 저장소가 없을 때와 권한이 없을 때 같은 메시지를 준다', '도커 데몬이 오류 원인을 정확히 몰라서 추측해서 보여 준다', '레지스트리 서버가 꺼져 있을 때 나오는 메시지다', '태그가 없을 때 나오는 메시지다'], 0,
         '레지스트리는 로그인하지 않은 사용자에게 비공개 저장소가 **있는지조차** 알려 주지 않습니다. 그래서 이름 오타(`appp`)와 권한 부족이 같은 `pull access denied` 로 보입니다. 먼저 이름·오타를 확인하고, 비공개 저장소라면 `docker login` 을 하세요. 서버가 꺼진 경우는 `connection refused`, 태그가 없는 경우는 `not found`·`manifest unknown` 이 나옵니다.')

# 11 -----------------------------------------------------------
b.choice('오류 메시지가 가리키는 원인',
         '아래 오류 중 **레지스트리 서버와는 정상적으로 통신했고, 요청한 이름·태그만 없다**는 뜻인 것은 무엇인가요?',
         '서버에 닿지 못한 오류, 프로토콜이 어긋난 오류, 서버가 "그건 없다"고 답한 오류를 나눠 보세요.',
         ['manifest for app:9.9 not found: manifest unknown', 'dial tcp 127.0.0.1:5000: connect: connection refused', 'lookup registry.example.com: no such host', 'http: server gave HTTP response to HTTPS client'], 0,
         '`manifest unknown`·`not found` 는 서버가 요청을 받고 "그 이름:태그는 없다"고 답한 것입니다. `connection refused` 는 서버(또는 포트)에 연결이 안 된 것, `no such host` 는 주소(이름)를 IP 로 풀지 못한 것, `HTTP response to HTTPS client` 는 서버에는 닿았지만 HTTP/HTTPS 방식이 어긋난 것입니다.')

# 12 -----------------------------------------------------------
b.order('HTTP 레지스트리 오류를 정석대로 고치는 순서',
        '`server gave HTTP response to HTTPS client` 오류를 데몬 설정으로 해결하는 순서대로 카드를 놓으세요. (설정 파일을 고친 뒤에는 데몬이 그것을 읽어야 합니다.)',
        '설정 파일을 고치는 것과 그 설정이 데몬에 적용되는 것은 같은 시점이 아닙니다. 어느 쪽이 먼저여야 오류가 사라지는지 생각해 보세요.',
        ['데몬을 재시작한다 (systemctl restart docker)', '같은 docker pull 을 다시 실행한다', '오류 메시지를 읽고 레지스트리가 HTTP 라는 것을 확인한다', 'daemon.json 의 insecure-registries 에 host:port 를 추가한다'], [2, 3, 0, 1],
        '먼저 메시지를 읽어 원인이 HTTP 레지스트리임을 확인합니다. 그다음 `daemon.json` 에 주소를 추가하고, 데몬을 재시작해야 설정이 적용됩니다. 마지막에 다시 pull 해 확인합니다. 재시작 전에 pull 을 해 봐야 같은 오류가 납니다.')

if __name__ == '__main__':
    preview(b)
