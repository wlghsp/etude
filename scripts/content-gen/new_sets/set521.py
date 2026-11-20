import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 521 도커 문제 해결 상황집: 이미지 받기·빌드가 실패할 때. 명세: docs/specs/spec_gap_set521.md
# 이미지는 alpine 만 쓴다(기존 도커 세트와 같은 패턴: 없으면 pull). 각 setup 은 앞 문제의 컨테이너·이미지·작업 폴더를 먼저 지운다.

PRE = ("docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t4 t5 t6 t7 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; "
       "docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true\n")


def F(path, body):
    return f"mkdir -p $(dirname {path}); cat > {path} <<'EOF'\n{body}\nEOF\n"


def OUT(n, expect):
    return chk(f'출력이 {expect} 다', f'[ "$(cat /tmp/q{n}.txt)" = "{expect}" ]')


b = SetBuilder(521, '도커 문제 해결 상황집: 이미지 받기·빌드가 실패할 때',
               '없는 태그(manifest unknown), 빌드 컨텍스트 밖을 가리키는 COPY, .dockerignore 에 걸린 COPY, 실패한 RUN, 캐시 때문에 바뀌지 않는 빌드(--no-cache), 실행할 때 나는 exec format error 와 no such file or directory(스크립트 shebang), 시작하자마자 종료되는 컨테이너를 오류 메시지부터 읽고 직접 고칩니다.',
               'docker', '도커', 26, 742, '🛠️',
               [{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "빌드 캐시", "url": "https://docs.docker.com/build/cache/"}, {"title": ".dockerignore", "url": "https://docs.docker.com/build/concepts/context/#dockerignore-files"}], 3)

# 1 ------------------------------------------------------------
b.nt('없는 태그 때문에 이미지를 못 받을 때',
     '**상황** — 빌드하면 이렇게 실패합니다.\n```\nERROR: failed to solve: alpine:lastest: ... not found\n```\n(`docker pull` 이라면 `manifest unknown` 이 같이 나옵니다.) 레지스트리에 **그 이름의 태그가 없다**는 뜻입니다. 이미지 이름은 맞는데 **태그가 오타**인 경우가 가장 흔합니다.\n\n`/tmp/work/q1/Dockerfile` 의 `FROM` 줄을 고쳐 빌드하세요.\n- 이미지 이름: `t1`\n- 실행 결과(`docker run --rm t1`)를 `/tmp/q1.txt` 에 저장',
     '`FROM` 줄의 태그를 보세요. 어떤 태그가 실제로 있는지는 `docker images` 로 내 컴퓨터에 받아 둔 태그를 먼저 확인할 수 있습니다.',
     "sed -i 's/alpine:lastest/alpine:latest/' /tmp/work/q1/Dockerfile\ndocker build -t t1 /tmp/work/q1\ndocker run --rm t1 > /tmp/q1.txt\ncat /tmp/q1.txt\n\n# 태그 오타(lastest)를 latest 로 고친다",
     PRE + F('/tmp/work/q1/Dockerfile', 'FROM alpine:lastest\nCMD ["echo", "base-ok"]'),
     [OUT(1, 'base-ok')])

# 2 ------------------------------------------------------------
b.nt('COPY 가 빌드 컨텍스트 밖을 가리킬 때',
     '**상황** — 빌드하면 파일을 못 찾습니다.\n```\nCOPY ../shared/app.conf /etc/app.conf\nERROR: failed to compute cache key: "/shared/app.conf": not found\n```\n`docker build` 는 **컨텍스트(마지막에 적은 폴더) 안의 파일만** 이미지로 복사할 수 있습니다. `../` 로 폴더 밖을 가리킬 수 없습니다.\n\n`/tmp/work/q2` 에는 `app/Dockerfile` 과 `shared/app.conf` 가 있습니다. 빌드가 되게 고친 뒤 이미지 `t2` 를 만들고, 실행 결과를 `/tmp/q2.txt` 에 저장하세요.',
     '컨텍스트를 한 단계 위(`/tmp/work/q2`)로 잡고 Dockerfile 은 `-f` 로 지정하는 방법과, 파일을 컨텍스트 안으로 가져오는 방법이 있습니다. 어느 쪽이든 `COPY` 의 경로가 컨텍스트 기준이 되도록 맞추세요.',
     "cd /tmp/work/q2\nsed -i 's#COPY ../shared/app.conf#COPY shared/app.conf#' app/Dockerfile\ndocker build -f app/Dockerfile -t t2 .\ndocker run --rm t2 > /tmp/q2.txt\ncat /tmp/q2.txt\n\n# 컨텍스트를 q2 로 올리고 COPY 경로를 컨텍스트 기준(shared/...)으로 바꾼다",
     PRE + F('/tmp/work/q2/app/Dockerfile', 'FROM alpine\nCOPY ../shared/app.conf /etc/app.conf\nCMD ["cat", "/etc/app.conf"]') + F('/tmp/work/q2/shared/app.conf', 'port=8080'),
     [OUT(2, 'port=8080')])

# 3 ------------------------------------------------------------
b.nt('.dockerignore 가 COPY 할 파일을 숨길 때',
     '**상황** — 파일이 분명히 폴더에 있는데 빌드가 이렇게 실패합니다.\n```\nCOPY config.txt /config.txt\n... "/config.txt": not found\n```\n`.dockerignore` 에 적힌 파일은 **빌드 컨텍스트에서 아예 빠지기** 때문에 `COPY` 가 찾지 못합니다. 오류 메시지에는 `.dockerignore` 이야기가 없을 수도 있습니다.\n\n`/tmp/work/q3` 의 `config.txt` 가 이미지에 들어가도록 고쳐 `t3` 로 빌드하고, 실행 결과를 `/tmp/q3.txt` 에 저장하세요. (`*.md` 파일은 계속 제외해도 됩니다.)',
     '컨텍스트 폴더의 숨김 파일 목록(`ls -a`)에서 `.dockerignore` 를 열어 보세요. 어떤 줄이 `config.txt` 를 가리는지 찾아 그 줄을 고치면 됩니다.',
     "cd /tmp/work/q3\nsed -i '/^\\*\\.txt$/d' .dockerignore\ndocker build -t t3 .\ndocker run --rm t3 > /tmp/q3.txt\ncat /tmp/q3.txt\n\n# *.txt 가 config.txt 를 가리고 있었다. 그 줄을 지우면 COPY 가 파일을 찾는다",
     PRE + F('/tmp/work/q3/Dockerfile', 'FROM alpine\nCOPY config.txt /config.txt\nCMD ["cat", "/config.txt"]') + F('/tmp/work/q3/config.txt', 'mode=prod') + F('/tmp/work/q3/.dockerignore', '*.md\n*.txt') + F('/tmp/work/q3/README.md', 'notes'),
     [OUT(3, 'mode=prod')])

# 4 ------------------------------------------------------------
b.nt('RUN 단계가 실패했을 때',
     '**상황** — 빌드가 중간 단계에서 멈춥니다.\n```\n=> ERROR [3/3] RUN cp /conf.default /etc/myapp/app.conf\ncp: can\'t create \'/etc/myapp/app.conf\': No such file or directory\n... did not complete successfully: exit code: 1\n```\n`RUN` 은 **이미지 안에서 명령을 실행**합니다. 명령이 0 이 아닌 종료 코드로 끝나면 빌드가 멈춥니다. 위 오류는 복사할 **대상 폴더가 이미지 안에 없다**는 뜻입니다.\n\n`/tmp/work/q4/Dockerfile` 을 고쳐 `t4` 로 빌드하고, 실행 결과를 `/tmp/q4.txt` 에 저장하세요.',
     '`RUN` 을 실행하기 전에 대상 폴더가 있어야 합니다. 폴더를 만드는 명령을 어디에 넣을지 생각해 보세요. 한 줄로 잇고 싶다면 `&&` 를 씁니다.',
     "cd /tmp/work/q4\nsed -i 's#^RUN cp#RUN mkdir -p /etc/myapp \\&\\& cp#' Dockerfile\ndocker build -t t4 .\ndocker run --rm t4 > /tmp/q4.txt\ncat /tmp/q4.txt\n\n# cp 하기 전에 mkdir -p 로 대상 폴더를 만든다",
     PRE + F('/tmp/work/q4/Dockerfile', 'FROM alpine\nCOPY conf.default /conf.default\nRUN cp /conf.default /etc/myapp/app.conf\nCMD ["cat", "/etc/myapp/app.conf"]') + F('/tmp/work/q4/conf.default', 'mode=default'),
     [OUT(4, 'mode=default')])

# 5 ------------------------------------------------------------
b.nt('다시 빌드했는데 그대로일 때: 캐시',
     '**상황** — 빌드 출력에 `CACHED` 가 찍히고, 다시 빌드해도 결과가 **전혀 바뀌지 않습니다**. 번호도 그대로입니다.\n\n도커는 Dockerfile 줄과 복사한 파일이 **그대로면 이전 결과를 재사용**합니다. 그런데 `RUN` 이 바깥에서 바뀌는 것(외부 서버의 파일 등)을 가져오면, 줄이 그대로라서 새 내용이 반영되지 않습니다. 여기서는 `RUN` 이 **빌드할 때마다 달라지는 번호**(무작위 값)를 기록하는 것으로 흉내 냅니다.\n\n`/tmp/work/q5` 의 이미지 `t5` 는 이미 한 번 빌드되어 있고, 그때 번호가 `/tmp/work/q5/old.txt` 에 있습니다. **캐시를 쓰지 않고** `t5` 를 다시 빌드한 뒤, 실행 결과를 `/tmp/q5.txt` 에 저장하세요. (옛 번호와 달라야 합니다.)',
     '`docker build` 에 캐시를 끄는 옵션이 있습니다. 옵션 목록은 `docker build --help` 에서 "cache" 로 찾아 보세요.',
     "docker build --no-cache -t t5 /tmp/work/q5\ndocker run --rm t5 > /tmp/q5.txt\ncat /tmp/q5.txt\n\n# --no-cache 는 모든 단계를 캐시 없이 다시 실행한다",
     PRE + F('/tmp/work/q5/Dockerfile', 'FROM alpine\nRUN cat /proc/sys/kernel/random/uuid > /stamp\nCMD ["cat", "/stamp"]') + "docker build -q -t t5 /tmp/work/q5 >/dev/null && docker run --rm t5 > /tmp/work/q5/old.txt\n",
     [chk('실행 결과가 저장되어 있다', '[ -s /tmp/q5.txt ]'), chk('옛 번호와 다르다', '[ -s /tmp/q5.txt ] && ! cmp -s /tmp/q5.txt /tmp/work/q5/old.txt')])

# 6 ------------------------------------------------------------
b.nt('exec format error: 스크립트 첫 줄이 없을 때',
     '**상황** — 빌드는 되는데 실행하면 이렇게 나옵니다.\n```\nexec /run.sh: exec format error\n```\n`ENTRYPOINT ["/run.sh"]` 처럼 스크립트를 **직접 실행**하려면 커널이 "어떤 프로그램으로 읽을지"를 알아야 합니다. 스크립트 **첫 줄**(`#!` 로 시작, shebang)이 그 역할을 합니다. 이미지 CPU 구조가 다를 때도 같은 메시지가 나지만, 여기서는 스크립트가 원인입니다.\n\n`/tmp/work/q6` 의 스크립트를 고쳐 `t6` 로 빌드하고, 실행 결과를 `/tmp/q6.txt` 에 저장하세요. (이 이미지에는 `sh` 만 있습니다.)',
     '`run.sh` 의 첫 줄을 보세요. 스크립트를 읽어 줄 프로그램의 **전체 경로**를 `#!` 뒤에 적습니다. 고친 뒤에는 이미지를 다시 빌드해야 합니다.',
     "cd /tmp/work/q6\nsed -i '1i #!/bin/sh' run.sh\ndocker build -t t6 .\ndocker run --rm t6 > /tmp/q6.txt\ncat /tmp/q6.txt\n\n# 첫 줄에 #!/bin/sh 를 넣어 인터프리터를 알려 준다",
     PRE + F('/tmp/work/q6/Dockerfile', 'FROM alpine\nCOPY run.sh /run.sh\nENTRYPOINT ["/run.sh"]') + F('/tmp/work/q6/run.sh', 'echo hello-from-script') + "chmod +x /tmp/work/q6/run.sh\n",
     [OUT(6, 'hello-from-script')])

# 7 ------------------------------------------------------------
b.nt('스크립트는 있는데 no such file or directory',
     '**상황** — 파일이 분명히 이미지 안에 있는데 실행하면 이렇게 나옵니다.\n```\nexec /run.sh: no such file or directory\n```\n이 메시지는 **스크립트 파일**이 아니라, **스크립트 첫 줄이 가리키는 프로그램**이 이미지에 없다는 뜻일 수 있습니다. 작은 이미지(alpine)에는 `bash` 가 없고 `sh` 만 있습니다.\n\n`/tmp/work/q7` 의 스크립트를 고쳐 `t7` 로 빌드하고, 실행 결과를 `/tmp/q7.txt` 에 저장하세요.',
     '스크립트 첫 줄의 `#!` 뒤 프로그램을 이미지 안에서 확인해 보세요. (`docker run --rm alpine ls /bin` 으로 어떤 쉘이 있는지 볼 수 있습니다.) 이미지에 있는 쉘로 바꾸면 됩니다.',
     "cd /tmp/work/q7\nsed -i '1s#.*#\\#!/bin/sh#' run.sh\ndocker build -t t7 .\ndocker run --rm t7 > /tmp/q7.txt\ncat /tmp/q7.txt\n\n# alpine 에는 bash 가 없으니 shebang 을 #!/bin/sh 로 바꾼다",
     PRE + F('/tmp/work/q7/Dockerfile', 'FROM alpine\nCOPY run.sh /run.sh\nENTRYPOINT ["/run.sh"]') + F('/tmp/work/q7/run.sh', '#!/bin/bash\necho hello-from-bash') + "chmod +x /tmp/work/q7/run.sh\n",
     [OUT(7, 'hello-from-bash')])

# 8 ------------------------------------------------------------
b.nt('컨테이너가 시작하자마자 종료될 때',
     '**상황** — 컨테이너를 띄웠는데 `docker ps` 에 보이지 않습니다. `docker ps -a` 에는 `Exited (0)` 로 나옵니다.\n\n컨테이너는 **메인 프로세스(CMD)가 끝나면 함께 종료**됩니다. 이 Dockerfile 의 CMD 는 서버를 **백그라운드(`&`)로 보내고 곧바로 끝나서**, 메인 프로세스가 사라집니다.\n\n`/tmp/work/q8/Dockerfile` 을 고쳐 `t8` 로 빌드한 뒤, 이름이 `q8` 인 컨테이너를 **백그라운드(`-d`)로** 실행해 계속 떠 있게 하세요.',
     'CMD 에서 백그라운드로 보내는 표시를 없애면 그 명령이 **앞에서(foreground)** 계속 실행됩니다. 컨테이너 이름은 `--name` 으로 정합니다.',
     "cd /tmp/work/q8\nsed -i 's/ &\"\\]/\"]/' Dockerfile\ndocker build -t t8 .\ndocker run -d --name q8 t8\ndocker ps\n\n# 메인 프로세스를 앞에서 실행하면 컨테이너가 살아 있다",
     PRE + F('/tmp/work/q8/Dockerfile', 'FROM alpine\nCMD ["sh", "-c", "sleep 600 &"]'),
     [chk('q8 컨테이너가 실행 중이다', '[ "$(docker inspect -f "{{.State.Running}}" q8 2>/dev/null)" = true ]')])

# 9 ------------------------------------------------------------
b.choice('manifest unknown 읽기',
         '`docker pull nginx:1.99.99` 를 실행했더니 아래 오류가 났습니다. 가장 알맞은 원인은 무엇인가요?\n```\nError response from daemon: manifest for nginx:1.99.99 not found: manifest unknown\n```',
         '메시지가 "무엇을 찾지 못했다"고 하는지 읽어 보세요. 이미지 이름과 태그 중 어느 쪽 이야기인가요?',
         ['레지스트리에 nginx 이미지는 있지만 1.99.99 라는 태그가 없다 (태그 오타·없는 버전)', '레지스트리에 로그인하지 않았다', '내 컴퓨터의 디스크가 가득 찼다', '도커 데몬이 꺼져 있다'], 0,
         '`manifest unknown`(not found)은 요청한 이름:태그의 이미지 정보가 레지스트리에 없다는 뜻입니다. 이미지 이름은 있고 태그만 없는 경우가 대표적입니다. 로그인 문제는 `pull access denied`·`unauthorized`, 디스크는 `no space left on device`, 데몬이 꺼진 경우는 `Cannot connect to the Docker daemon` 으로 나옵니다.')

# 10 -----------------------------------------------------------
b.choice('apt-get: not found 의 원인',
         'alpine 이미지로 빌드하던 중 아래 오류가 났습니다. 원인은 무엇인가요?\n```\n/bin/sh: apt-get: not found\n... did not complete successfully: exit code: 127\n```',
         '종료 코드 127 은 "명령을 찾을 수 없음"입니다. 이 이미지가 어떤 배포판 계열인지 생각해 보세요.',
         ['alpine 에는 apt-get 이 없다 (패키지 관리자는 apk)', '인터넷이 끊겨서 apt-get 이 응답하지 않는다', 'Dockerfile 에 USER 를 지정하지 않았다', '빌드 캐시가 오래되었다'], 0,
         '`not found`·종료 코드 127 은 그 이름의 실행 파일이 이미지에 없다는 뜻입니다. alpine 은 `apk add` 를, Debian·Ubuntu 계열은 `apt-get` 을 씁니다. 네트워크 문제는 다운로드 단계에서 다른 메시지로 실패합니다.')

# 11 -----------------------------------------------------------
b.fill('캐시 없이 빌드',
       '빌드 캐시를 **쓰지 않고** 모든 단계를 다시 실행해 `app` 이미지를 만드는 명령입니다. 빌드 폴더는 현재 위치입니다. 빈칸을 채우세요.',
       '캐시를 끄는 `docker build` 옵션입니다.',
       'docker build {0} -t app .', ['--no-cache', '--force', '--rebuild', '--fresh'], [0],
       '`--no-cache` 는 모든 단계를 캐시 없이 새로 실행합니다. 나머지 옵션은 `docker build` 에 없습니다. 특정 줄부터만 다시 하고 싶다면 그 줄 앞에서 내용이 바뀌도록 Dockerfile 을 고칩니다.')

# 12 -----------------------------------------------------------
b.order('빌드가 실패했을 때 고치는 순서',
        '`docker build` 가 실패했습니다. 원인을 찾아 고치고 결과를 확인하는 순서대로 카드를 놓으세요.',
        '문제를 찾는 단계, 고치는 단계, 확인하는 단계로 나뉩니다. 고친 것이 맞는지는 맨 끝에서 봅니다.',
        ['고친 Dockerfile 로 다시 docker build', '오류 메시지의 마지막 줄을 읽고 원인을 짐작한다', '해당 줄을 고친다', '빌드한 이미지를 docker run 으로 실행해 본다', '빌드 출력에서 실패한 단계(어느 줄인지)를 찾는다'], [4, 1, 2, 0, 3],
        '실패한 단계를 먼저 찾고, 그 단계의 오류 메시지를 읽어 원인을 짐작한 뒤 해당 줄을 고칩니다. 다시 빌드해 통과하는지 보고, 마지막으로 실행해 기대한 결과가 나오는지 확인합니다.')

if __name__ == '__main__':
    preview(b)
