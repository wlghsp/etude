import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 553 도커 이미지 작게·안전하게 만들기. 명세: docs/specs/spec_gap_set553.md
# 이미지는 alpine:3.19, nginx:1.27, nginx:1.27-alpine 만 쓴다(미러에 있음). 패키지 설치·빌드 도구는 dd 로 만든 큰 파일로 흉내 내 네트워크 없이 크기만 본다.

PRE = ("docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t3 t4 t6 t8 t11 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; "
       "for i in alpine:3.19; do docker image inspect $i >/dev/null 2>&1 || docker pull -q $i >/dev/null 2>&1; done; true\n")


def F(path, body):
    return f"mkdir -p $(dirname {path}); cat > {path} <<'EOF'\n{body}\nEOF\n"


def SMALL(img):  # 저장소 종류와 무관하게 history 의 레이어(비압축) 크기로 본다: 20MB 넘는 레이어가 없다
    return chk('이미지에 20MB 를 넘는 큰 레이어가 남아 있지 않다', f"docker image inspect {img} >/dev/null 2>&1 && docker history --format '{{{{.Size}}}}' {img} | awk '/GB/{{exit 1}} /MB/{{v=$0; sub(/MB/,\"\",v); if (v+0>20) exit 1}}'")


b = SetBuilder(553, '이미지 작게·안전하게 만들기: 크기 비교·캐시 정리·멀티 스테이지·비루트·고정 태그',
               '이미지 크기 비교(docker image ls·inspect), docker history 로 큰 레이어 찾기, 패키지 캐시를 같은 RUN 에서 지우기, 멀티 스테이지로 빌드 도구 빼기, 비루트 실행(--user·USER·COPY --chown), latest 대신 고정 태그·digest 를 직접 해 봅니다.',
               'docker', '도커', 67, 813, '🪶',
               [{"title": "Dockerfile 모범 사례", "url": "https://docs.docker.com/build/building/best-practices/"}, {"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}, {"title": "docker history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}], 1)

# 1 ------------------------------------------------------------
b.nt('같은 프로그램, 이미지 크기는 얼마나 다를까',
     '**배경** — 같은 nginx 라도 바탕(base) 이미지가 무엇이냐에 따라 크기가 크게 달라집니다. 이미지가 크면 받는 시간·디스크·보안 점검 대상이 모두 늘어납니다. 크기는 `docker image ls` 로 보고, 정확한 바이트는 `docker image inspect -f \'{{.Size}}\' 이미지` 로 볼 수 있습니다.\n\n**할 일** — `nginx:1.27`(기본)과 `nginx:1.27-alpine` 두 이미지가 내려받아져 있습니다. 둘 중 **더 큰 쪽**의 크기(바이트, 숫자만)를 `/tmp/q1.txt` 에 저장하세요.',
     '`docker image inspect` 에는 `-f` 로 원하는 항목만 뽑는 형식 옵션이 있고, 크기 항목의 이름은 `Size` 입니다. 두 이미지 중 큰 쪽을 골라 한 줄만 저장하세요.',
     "docker image ls nginx\ndocker image inspect -f '{{.Size}}' nginx:1.27 > /tmp/q1.txt\ncat /tmp/q1.txt\n\n# 기본 nginx(Debian 계열)가 alpine 판보다 훨씬 크다. inspect 의 Size 는 바이트 단위",
     PRE + "for i in nginx:1.27 nginx:1.27-alpine; do docker image inspect $i >/dev/null 2>&1 || docker pull -q $i >/dev/null 2>&1; done; true\n",
     [chk('저장된 값이 더 큰 이미지의 크기다', '[ -s /tmp/q1.txt ] && [ "$(cat /tmp/q1.txt)" = "$(docker image inspect -f \'{{.Size}}\' nginx:1.27)" ]')])

# 2 ------------------------------------------------------------
b.choice('alpine · slim · 기본 이미지',
         '같은 프로그램을 올릴 수 있는 세 종류의 바탕 이미지가 있습니다. 설명으로 **맞는 것**은 무엇인가요?',
         '크기가 작은 이유는 "빼 놓은 것"이 있어서입니다. 빠진 것이 무엇인지, 그래서 어떤 점을 조심해야 하는지 생각해 보세요.',
         ['alpine 은 musl·busybox 로 아주 작게 만든 배포판이라 작지만, 기본 이미지에 있던 도구(bash 등)가 없을 수 있다', 'slim 은 alpine 과 똑같은 배포판을 압축만 더 한 것이다', '기본 이미지(예: nginx)가 가장 작고 안전해서 tag 를 붙이면 더 커진다', '이미지가 작을수록 항상 더 빨리 실행된다'], 0,
         'alpine 은 musl libc 와 busybox 를 쓰는 별도 배포판이라 몇 MB 에 불과하지만, 기본 이미지에 있는 도구(bash 등)가 없을 수 있고 glibc 를 전제로 한 프로그램은 안 돌 수 있습니다. slim 은 Debian 에서 문서·부가 도구를 덜어 낸 변형으로 alpine 과 다른 배포판입니다. 이미지 크기는 받는 시간·저장 공간에 영향을 주지만 실행 속도와는 직접 관계가 없습니다.')

# 3 ------------------------------------------------------------
b.nt('docker history 로 큰 레이어 찾기',
     '**배경** — 이미지가 왜 큰지 알려면 **어느 레이어(Dockerfile 한 줄의 결과)가 큰지** 봐야 합니다. `docker history 이미지` 는 레이어마다 만든 명령(`CREATED BY`)과 크기(`SIZE`)를 보여 줍니다. 명령이 잘려 보이면 `--no-trunc` 를 붙입니다.\n\n**할 일** — 이미지 `t3` 이 이미 만들어져 있습니다(Dockerfile 은 없습니다). **가장 큰 레이어**가 만든 파일의 이름(`/opt/` 아래, 파일 이름만)을 `/tmp/q3.txt` 에 저장하세요.',
     '`docker history` 의 SIZE 열에서 가장 큰 줄을 찾고, 그 줄의 CREATED BY 를 읽어 보세요. 잘리면 `--no-trunc` 를 붙입니다.',
     "docker history --no-trunc t3\necho assets.dat > /tmp/q3.txt\ncat /tmp/q3.txt\n\n# SIZE 가 가장 큰 레이어(40MB)의 명령이 /opt/assets.dat 를 만들었다",
     PRE + F('/tmp/work/q3/Dockerfile', 'FROM alpine:3.19\nRUN dd if=/dev/zero of=/opt/notes.txt bs=1M count=2 2>/dev/null\nRUN dd if=/dev/zero of=/opt/assets.dat bs=1M count=40 2>/dev/null\nRUN dd if=/dev/zero of=/opt/index.db bs=1M count=5 2>/dev/null') + "docker build -q -t t3 /tmp/work/q3 >/dev/null; rm -rf /tmp/work/q3\n",
     [chk('가장 큰 레이어가 만든 파일 이름이다', '[ "$(cat /tmp/q3.txt 2>/dev/null)" = "assets.dat" ]')])

# 4 ------------------------------------------------------------
b.nt('패키지 캐시는 설치와 같은 RUN 에서 지운다',
     '**배경** — 패키지를 설치하면 내려받은 파일·목록 캐시(예: `/var/lib/apt/lists`)가 남습니다. 그런데 **다음 RUN 줄에서 지워도** 앞 레이어에 이미 들어간 파일은 그대로라 이미지는 줄지 않습니다. **설치한 같은 RUN 안에서 지워야** 레이어에 남지 않습니다. 여기서는 설치를 `dd` 로 30MB 캐시를 만드는 줄로 흉내 냅니다(실제로는 `apt-get install` 뒤 `rm -rf /var/lib/apt/lists/*`, alpine 은 `apk add --no-cache`).\n\n`/tmp/work/q4/Dockerfile` 을 고쳐 `t4` 로 빌드하세요. `docker history t4` 에 20MB 를 넘는 레이어가 남지 않아야 하고(크기는 압축 전 레이어 기준), 실행 결과(`docker run --rm t4`)를 `/tmp/q4.txt` 에 저장하세요.',
     '캐시를 만드는 RUN 과 지우는 RUN 이 따로 있습니다. 두 줄을 한 레이어로 묶는 방법(`&&`)을 떠올려 보세요. 고친 뒤 `docker history t4` 로 레이어 크기를 확인합니다.',
     "cd /tmp/work/q4\nsed -i -e '/^RUN dd/{N;s#\\nRUN # \\&\\& #}' Dockerfile\ncat Dockerfile\ndocker build -t t4 .\ndocker run --rm t4 > /tmp/q4.txt\ncat /tmp/q4.txt\n\n# 캐시를 만든 RUN 안에서 곧바로 지우면 레이어에 남지 않는다",
     PRE + F('/tmp/work/q4/Dockerfile', 'FROM alpine:3.19\nRUN dd if=/dev/zero of=/var/cache/pkg.tmp bs=1M count=30 2>/dev/null && echo ready > /opt.txt\nRUN rm -f /var/cache/pkg.tmp\nCMD ["cat", "/opt.txt"]'),
     [SMALL('t4'), chk('실행 결과가 ready 다', '[ "$(cat /tmp/q4.txt 2>/dev/null)" = ready ]')])

# 5 ------------------------------------------------------------
b.choice('가장 작게 남는 Dockerfile 줄',
         'Debian 계열 이미지에서 curl 을 설치하는 줄입니다. **최종 이미지가 가장 작게** 남는 것은 무엇인가요? (모두 설치는 성공한다고 가정합니다)',
         '캐시 파일이 "어느 레이어에" 들어가는지 생각해 보세요. 지우는 명령이 같은 레이어에 있어야 합니다.',
         ['RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*', 'RUN apt-get update && apt-get install -y curl\nRUN rm -rf /var/lib/apt/lists/*', 'RUN rm -rf /var/lib/apt/lists/*\nRUN apt-get update && apt-get install -y curl', 'RUN apt-get update\nRUN apt-get install -y curl'], 0,
         '파일이 들어간 레이어는 이후 레이어에서 지워도 이미지에 그대로 남습니다(가려질 뿐). 설치와 정리를 한 RUN 으로 묶어야 캐시가 최종 레이어에 남지 않습니다. 두 번째 줄은 지우기가 다음 레이어라 효과가 없고, 세 번째는 지운 뒤 설치해서 목록이 다시 생기며, 네 번째는 정리를 아예 하지 않습니다.')

# 6 ------------------------------------------------------------
b.nt('멀티 스테이지로 빌드 도구 빼기',
     '**배경** — 빌드할 때만 필요한 컴파일러·도구가 최종 이미지에 남으면 이미지가 커지고 공격 대상도 늘어납니다. 멀티 스테이지 빌드는 빌드용 단계에서 결과물만 만들어 **실행용 단계로 그 결과물만 복사**합니다. 여기서는 빌드 도구를 `/opt/toolchain.bin`(40MB)로 흉내 냅니다.\n\n`/tmp/work/q6/Dockerfile` 은 한 단계라 도구가 이미지에 남습니다. 두 단계로 바꿔 `t6` 로 빌드하세요. 조건은 셋입니다.\n- `docker run --rm t6` 의 결과 `built-app` 을 `/tmp/q6.txt` 에 저장\n- 이미지에 `/opt/toolchain.bin` 이 **없을 것**\n- `docker history t6` 에 20MB 를 넘는 레이어가 없을 것(크기는 압축 전 레이어 기준)\n- Dockerfile 이 `FROM` 두 개 이상과 `COPY --from` 을 쓰는 멀티 스테이지일 것',
     '`FROM` 을 두 번 쓰고, 첫 단계에 이름(`AS`)을 붙인 뒤 둘째 단계에서 `COPY --from=이름` 으로 결과물(`/app.sh`)만 가져옵니다. `CMD` 는 둘째 단계에 둡니다.',
     "cd /tmp/work/q6\ncat > Dockerfile <<'EOF'\nFROM alpine:3.19 AS build\nRUN dd if=/dev/zero of=/opt/toolchain.bin bs=1M count=40 2>/dev/null\nRUN echo '#!/bin/sh' > /app.sh && echo 'echo built-app' >> /app.sh && chmod +x /app.sh\n\nFROM alpine:3.19\nCOPY --from=build /app.sh /app.sh\nCMD [\"/app.sh\"]\nEOF\ndocker build -t t6 .\ndocker run --rm t6 > /tmp/q6.txt\ncat /tmp/q6.txt\n\n# 도구는 build 단계에만 있고, 최종 이미지에는 app.sh 만 복사된다",
     PRE + F('/tmp/work/q6/Dockerfile', 'FROM alpine:3.19\nRUN dd if=/dev/zero of=/opt/toolchain.bin bs=1M count=40 2>/dev/null\nRUN echo \'#!/bin/sh\' > /app.sh && echo \'echo built-app\' >> /app.sh && chmod +x /app.sh\nCMD ["/app.sh"]'),
     [chk('실행 결과가 built-app 이다', '[ "$(cat /tmp/q6.txt 2>/dev/null)" = built-app ]'),
      chk('이미지에 빌드 도구가 없다', 'docker image inspect t6 >/dev/null 2>&1 && ! docker run --rm --entrypoint ls t6 /opt/toolchain.bin >/dev/null 2>&1'),
      SMALL('t6'),
      chk('Dockerfile 이 두 단계 이상(COPY --from)이다', '[ "$(grep -ci "^FROM" /tmp/work/q6/Dockerfile)" -ge 2 ] && grep -q "COPY --from" /tmp/work/q6/Dockerfile')])

# 7 ------------------------------------------------------------
b.nt('컨테이너를 root 로 돌리면 생기는 일',
     '**배경** — 컨테이너 안 프로세스는 따로 지정하지 않으면 **root(uid 0)** 로 실행됩니다. 호스트 폴더를 붙여(`-v`) 파일을 만들면 그 파일이 **호스트에서도 root 소유**가 되고, 탈출 취약점이 있을 때 피해도 커집니다. 실행할 때 `--user 번호:번호` 로 일반 사용자를 줄 수 있습니다.\n\n**할 일** — 호스트 폴더 `/tmp/work/q7/out`(누구나 쓸 수 있게 열려 있음)을 컨테이너의 `/out` 에 붙이고, **uid 1000, gid 1000** 으로 `alpine:3.19` 컨테이너를 실행해 `/out/result.txt` 에 `done` 을 쓰세요. 호스트에서 그 파일의 소유자가 1000 이어야 합니다.',
     '`docker run` 에 사용자를 지정하는 옵션이 있고, 값은 `uid:gid` 모양입니다. 폴더는 `-v 호스트경로:컨테이너경로` 로 붙입니다. 실행 뒤 `ls -ln` 으로 소유자 번호를 확인하세요.',
     "docker run --rm --user 1000:1000 -v /tmp/work/q7/out:/out alpine:3.19 sh -c 'echo done > /out/result.txt'\nls -ln /tmp/work/q7/out\n\n# --user 를 주면 컨테이너 안 프로세스가 uid 1000 으로 돌아 호스트 파일도 1000 소유가 된다",
     PRE + "mkdir -p /tmp/work/q7/out && chmod 777 /tmp/work/q7/out\n",
     [chk('result.txt 에 done 이 있다', '[ "$(cat /tmp/work/q7/out/result.txt 2>/dev/null)" = done ]'),
      chk('파일 소유자가 uid 1000 이다', '[ "$(stat -c %u /tmp/work/q7/out/result.txt 2>/dev/null)" = 1000 ]')])

# 8 ------------------------------------------------------------
b.nt('비루트로 바꿨더니 Permission denied',
     '**상황** — 보안을 위해 Dockerfile 에 `USER app` 을 넣었더니 컨테이너가 이렇게 실패합니다.\n```\nsh: can\'t create /data/out.txt: Permission denied\n```\n`COPY`·`RUN mkdir` 로 만든 파일·폴더는 기본적으로 **root 소유**입니다. 일반 사용자 `app` 은 그 폴더에 쓸 수 없습니다. `COPY --chown=사용자:그룹 원본 대상` 이나 `USER` 앞의 `chown` 으로 주인을 바꿔 줍니다.\n\n`/tmp/work/q8/Dockerfile` 을 고쳐 `t8` 로 빌드하세요. 사용자는 그대로 `app` 이어야 하고, 실행 결과(`docker run --rm t8`)를 `/tmp/q8.txt` 에 저장하세요.',
     '`/data` 폴더를 `app` 이 쓸 수 있어야 합니다. `RUN` 으로 폴더를 만드는 줄을 보고, 그 폴더의 소유자를 `USER app` 보다 **앞에서** 바꿀 방법을 찾으세요.',
     "cd /tmp/work/q8\nsed -i 's#^RUN mkdir -p /data#RUN mkdir -p /data \\&\\& chown app /data#' Dockerfile\ncat Dockerfile\ndocker build -t t8 .\ndocker run --rm t8 > /tmp/q8.txt\ncat /tmp/q8.txt\n\n# 폴더 주인을 app 으로 바꾼 뒤 USER app 으로 전환한다 (chown 은 USER 앞에서 root 로)",
     PRE + F('/tmp/work/q8/Dockerfile', 'FROM alpine:3.19\nRUN adduser -D app\nRUN mkdir -p /data\nUSER app\nCMD ["sh", "-c", "echo saved > /data/out.txt && cat /data/out.txt"]'),
     [chk('실행 결과가 saved 다', '[ "$(cat /tmp/q8.txt 2>/dev/null)" = saved ]'),
      chk('app 사용자로 /data 에 쓸 수 있다', 'docker run --rm --entrypoint sh t8 -c "touch /data/x" >/dev/null 2>&1'),
      chk('이미지가 비루트(app)로 실행된다', '[ "$(docker image inspect -f \'{{.Config.User}}\' t8 2>/dev/null)" = app ]')])

# 9 ------------------------------------------------------------
b.choice('FROM alpine:latest 의 문제',
         'Dockerfile 이 `FROM alpine:latest` 로 시작합니다(태그 생략도 같은 뜻입니다). 이 방식의 **가장 큰 문제**는 무엇인가요?',
         '`latest` 는 "가장 최신 버전"이라는 이름표이지 특정 버전이 아닙니다. 몇 달 뒤 같은 Dockerfile 을 빌드하면 어떻게 될지 생각해 보세요.',
         ['빌드하는 시점마다 가리키는 이미지가 달라져 같은 Dockerfile 이 다른 결과를 만들 수 있다', 'latest 태그는 레지스트리에서 받을 수 없다', 'latest 는 이미지 크기가 항상 가장 크다', 'latest 를 쓰면 컨테이너가 root 로만 실행된다'], 0,
         '`latest` 는 그냥 태그 이름이며 레지스트리 운영자가 새 버전을 올릴 때 옮겨 갑니다. 그래서 시점마다 다른 베이스가 들어가 재현성이 깨지고, 갑작스러운 버전 변경으로 빌드가 깨지거나 보안 이슈가 섞일 수 있습니다. 버전 태그(예: `alpine:3.19`)로 고정하고, 더 엄격하게는 digest 로 고정합니다. 크기·사용자와는 관계가 없습니다.')

# 10 -----------------------------------------------------------
b.fill('이미지의 digest 확인하기',
       '태그와 달리 **digest**(`sha256:...`)는 이미지 내용 자체의 지문이라 바뀌지 않습니다. `FROM alpine@sha256:...` 처럼 쓰면 내용이 고정됩니다. 내 컴퓨터의 alpine 이미지 목록에 digest 열을 함께 보여 주는 명령입니다. 빈칸을 채우세요.',
       '`docker image ls` 의 옵션 중 digest 를 같이 보여 주는 것입니다. 복수형인지 단수형인지 주의하세요.',
       'docker image ls {0} alpine', ['--digests', '--digest', '--sha', '--hash'], [0],
       '`docker image ls --digests` 는 DIGEST 열을 추가로 보여 줍니다. 나머지 옵션은 없습니다. 이 값을 `FROM alpine@sha256:...` 에 쓰면 태그가 다른 이미지로 옮겨 가도 같은 내용만 받게 됩니다.')

# 11 -----------------------------------------------------------
b.nt('latest 를 고정 태그로 바꾸기',
     '**상황** — `/tmp/work/q11/Dockerfile` 이 `FROM alpine` (= `alpine:latest`)로 되어 있어 빌드 시점마다 베이스가 달라질 수 있습니다. alpine **3.19** 로 고정하세요.\n\n`t11` 로 빌드하고, 실행 결과(`docker run --rm t11`, alpine 의 버전 번호)를 `/tmp/q11.txt` 에 저장하세요. Dockerfile 에 `latest` 나 태그 없는 `FROM` 이 남아 있으면 안 됩니다.',
     '`FROM 이미지:태그` 형식입니다. 고친 뒤 다시 빌드해야 하고, 결과 번호가 3.19 로 시작하는지 확인하세요.',
     "cd /tmp/work/q11\nsed -i 's#^FROM alpine.*#FROM alpine:3.19#' Dockerfile\ndocker build -t t11 .\ndocker run --rm t11 > /tmp/q11.txt\ncat /tmp/q11.txt\n\n# 태그를 3.19 로 고정하면 같은 베이스를 반복해서 받는다",
     PRE + F('/tmp/work/q11/Dockerfile', 'FROM alpine\nCMD ["cat", "/etc/alpine-release"]'),
     [chk('Dockerfile 이 3.19 로 고정되어 있다', 'grep -q "^FROM alpine:3\\.19" /tmp/work/q11/Dockerfile && ! grep -qi latest /tmp/work/q11/Dockerfile'),
      chk('실행 결과가 3.19 버전이다', 'case "$(cat /tmp/q11.txt 2>/dev/null)" in 3.19.*) true;; *) false;; esac')])

if __name__ == '__main__':
    preview(b)
