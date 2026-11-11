-- 도커 세트 234. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 단원·display_order 는 통합 시 별도로 정한다. 원본: 02_quest_set.sql, 03_quest_set234.sql. docs/specs/spec_docker_build_practice_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 234, '도커 이미지 손으로 만들기 실습: Dockerfile, build, tag, ENV·ARG, ENTRYPOINT, .dockerignore, history', '/tmp/app 에 Dockerfile 을 직접 쓰고 빌드해, 이미지가 실제로 만들어졌는지 실행 결과와 파일 내용으로 확인합니다. images 필터와 tag, ENV·ARG, ENTRYPOINT 와 실행 인자, COPY 와 .dockerignore, history 레이어 확인까지 한 단계씩 익힙니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 234);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 1, 'Dockerfile 을 쓰고 이미지 만들기', '`/tmp/app` 디렉터리에 `Dockerfile` 을 만들고, `alpine` 을 기반으로 컨테이너를 실행하면 `hello etude` 를 출력하는 이미지 **`hello:1`** 을 빌드하세요.', '`FROM` 으로 기반 이미지를, `CMD` 로 기본 실행 명령을 정해요. 빌드는 `docker build -t 이름:태그 .` 이고 `.` 은 Dockerfile 이 있는 현재 디렉터리입니다.', 'cd /tmp/app
cat > Dockerfile <<''EOF''
FROM alpine
CMD ["echo", "hello etude"]
EOF
docker build -t hello:1 .
docker run --rm hello:1

# -t 로 이름:태그를 붙이고, 끝의 . 은 빌드 컨텍스트(현재 디렉터리)다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(docker run --rm hello:1)\\" = \\"hello etude\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지가 실행되어 문구를 출력한다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm hello:1)\\" = \\"hello etude\\" ]"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 2, '이미지 목록에서 태그만 골라 저장', '이 머신에는 `demo` 저장소의 이미지가 여러 태그로 있고, 다른 이름의 이미지도 하나 있습니다. `demo` 저장소 이미지의 **태그만** 한 줄에 하나씩 `/tmp/tags.txt` 에 저장하세요. (저장소 이름 없이 태그만)', '`docker images 저장소이름` 으로 그 저장소만 거를 수 있어요. 열을 고르려면 `--format` 에 `{{.Tag}}` 처럼 적습니다.', 'docker images demo
docker images demo --format ''{{.Tag}}'' | sort > /tmp/tags.txt
cat /tmp/tags.txt

# 저장소 이름으로 거르고, --format 으로 원하는 열만 뽑는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; for t in 1 2; do printf ''FROM alpine\\\\nCMD [\\"echo\\",\\"v%s\\"]\\\\n'' $t | docker build -q -t demo:$t - >/dev/null; done; printf ''FROM alpine\\\\nCMD [\\"echo\\",\\"o\\"]\\\\n'' | docker build -q -t other:1 - >/dev/null; true"]', '["sh", "-c", "( [ \\"$(sort /tmp/tags.txt)\\" = \\"$(printf ''1\\\\n2'')\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "demo 의 태그만 들어 있다", "cmd": ["sh", "-c", "[ \\"$(sort /tmp/tags.txt)\\" = \\"$(printf ''1\\\\n2'')\\" ]"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 3, '이미지에 이름 하나 더 붙이기', '이미지 `demo:1` 이 있습니다. **같은 이미지**에 `demo:stable` 이라는 이름을 하나 더 붙이세요. `demo:1` 도 그대로 있어야 합니다.', '`docker tag 원본 새이름` 은 이미지를 복사하지 않고 이름표만 하나 더 붙여요. 붙인 뒤 `docker images demo` 로 확인하세요.', 'docker tag demo:1 demo:stable
docker images demo

# tag 는 이름표만 추가한다. 두 이름의 IMAGE ID 가 같다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; printf ''FROM alpine\\\\nCMD [\\"echo\\",\\"v1\\"]\\\\n'' | docker build -q -t demo:1 - >/dev/null; true"]', '["sh", "-c", "( [ \\"$(docker image inspect -f ''{{.Id}}'' demo:stable)\\" = \\"$(docker image inspect -f ''{{.Id}}'' demo:1)\\" ] ) && ( docker image inspect demo:1 >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "stable 이 demo:1 과 같은 이미지다", "cmd": ["sh", "-c", "[ \\"$(docker image inspect -f ''{{.Id}}'' demo:stable)\\" = \\"$(docker image inspect -f ''{{.Id}}'' demo:1)\\" ]"]}, {"label": "demo:1 이 남아 있다", "cmd": ["sh", "-c", "docker image inspect demo:1 >/dev/null 2>&1"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 4, 'ENV 로 값 넣은 이미지', '`/tmp/app` 에 `Dockerfile` 을 만들어 이미지 **`greet:1`** 을 빌드하세요. 환경 변수 `NAME` 의 값은 `Etude` 이고, 컨테이너를 실행하면 `hello Etude` 를 출력해야 합니다. 값은 `ENV` 로 넣으세요.', '`ENV 이름=값` 은 이미지에 환경 변수를 남겨요. `CMD` 를 셸 형식(`CMD echo hello $NAME`)으로 쓰면 변수가 풀려서 출력됩니다.', 'cd /tmp/app
cat > Dockerfile <<''EOF''
FROM alpine
ENV NAME=Etude
CMD echo hello $NAME
EOF
docker build -t greet:1 .
docker run --rm greet:1

# ENV 는 빌드 뒤 컨테이너 실행 중에도 남는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(docker run --rm greet:1)\\" = \\"hello Etude\\" ] ) && ( docker image inspect -f ''{{range .Config.Env}}{{println .}}{{end}}'' greet:1 | grep -qx NAME=Etude )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "실행하면 hello Etude 가 나온다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm greet:1)\\" = \\"hello Etude\\" ]"]}, {"label": "이미지 환경 변수에 NAME=Etude 가 있다", "cmd": ["sh", "-c", "docker image inspect -f ''{{range .Config.Env}}{{println .}}{{end}}'' greet:1 | grep -qx NAME=Etude"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 5, 'ENV 와 ARG 의 차이', '이미지를 만들 때 쓰는 `ARG` 와 `ENV` 의 차이로 **맞는** 설명은 무엇일까요?', '값이 언제까지 남는지를 생각해 보세요. 빌드 중에만 쓰이는지, 컨테이너가 실행되는 동안에도 보이는지요.', NULL, NULL, '[]', 'choice', '["`ARG` 는 컨테이너 실행 중에만 쓰이고, `ENV` 는 빌드할 때만 쓰인다", "`ARG` 와 `ENV` 는 완전히 같아서 어느 쪽을 써도 결과가 같다", "`ARG` 는 빌드할 때만 쓰이고, `ENV` 는 만들어진 이미지로 컨테이너를 실행할 때도 남는다", "`ENV` 값은 `docker build` 때만 바꿀 수 있고, `ARG` 는 바꿀 수 없다"]', 2, '`ARG` 는 빌드 중에만 있는 변수이고, `ENV` 는 이미지 설정에 저장되어 컨테이너 안에서도 환경 변수로 보입니다. 그래서 실행 중에 필요한 값은 `ENV`, 빌드할 때만 바꿔 넣을 값은 `ARG`(`--build-arg`)가 맞습니다. 반대로 설명하거나 같다고 하는 보기는 틀렸어요. `ENV` 도 `docker run -e` 로 실행할 때 덮어쓸 수 있습니다.', NULL, NULL, NULL, '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 6, '빌드할 때 값 바꿔 넣기', '`/tmp/app/Dockerfile` 이 이미 있습니다. 안에는 `ARG VER=1.0` 이 있고 이 값이 이미지의 `/version` 파일에 기록됩니다. `VER` 에 `2.5` 를 넣어 이미지 **`ver:2`** 를 빌드하세요. (`Dockerfile` 은 고치지 않습니다)', '빌드할 때 `--build-arg 이름=값` 으로 ARG 의 기본값을 바꿀 수 있어요. `docker build` 에 `-t` 와 함께 쓰세요.', 'cd /tmp/app
cat Dockerfile
docker build --build-arg VER=2.5 -t ver:2 .
docker run --rm ver:2

# --build-arg 는 Dockerfile 의 ARG 값을 빌드할 때만 바꾼다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; printf ''FROM alpine\\\\nARG VER=1.0\\\\nRUN echo \\"$VER\\" > /version\\\\nCMD [\\"cat\\",\\"/version\\"]\\\\n'' > /tmp/app/Dockerfile; true"]', '["sh", "-c", "( [ \\"$(docker run --rm ver:2 cat /version)\\" = 2.5 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/version 에 2.5 가 기록됐다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm ver:2 cat /version)\\" = 2.5 ]"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 7, 'COPY 로 파일 넣은 이미지', '`/tmp/app/note.txt` 가 있습니다. 이 파일을 이미지의 `/note.txt` 로 **복사해 넣은** 이미지 **`note:1`** 을 빌드하세요. (`Dockerfile` 은 직접 작성합니다)', '`COPY 원본 대상` 에서 원본은 빌드 컨텍스트(`.`) 안의 경로예요. 확인은 `docker run --rm note:1 cat /note.txt` 로 해 보세요.', 'cd /tmp/app
cat > Dockerfile <<''EOF''
FROM alpine
COPY note.txt /note.txt
EOF
docker build -t note:1 .
docker run --rm note:1 cat /note.txt

# COPY 는 빌드 컨텍스트의 파일을 이미지 안으로 복사한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; echo from-host-42 > /tmp/app/note.txt; true"]', '["sh", "-c", "( [ \\"$(docker run --rm note:1 cat /note.txt)\\" = from-host-42 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 안 /note.txt 의 내용이 맞다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm note:1 cat /note.txt)\\" = from-host-42 ]"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 8, 'ENTRYPOINT 와 실행 인자', '`ENTRYPOINT` 가 `["echo", "say:"]` 인 이미지 **`say:1`** 을 만드세요. 그런 다음 `docker run` 뒤에 인자 `world` 를 붙여 실행하고, 출력(`say: world`)을 `/tmp/out.txt` 에 저장합니다.', '`ENTRYPOINT` 는 고정 실행 파일이라, `docker run 이미지 인자` 의 인자가 그 뒤에 이어 붙어요. 출력은 `>` 로 파일에 저장합니다.', 'cd /tmp/app
cat > Dockerfile <<''EOF''
FROM alpine
ENTRYPOINT ["echo", "say:"]
EOF
docker build -t say:1 .
docker run --rm say:1 world > /tmp/out.txt
cat /tmp/out.txt

# ENTRYPOINT 는 남고 run 뒤의 인자가 붙는다 (CMD 였다면 인자가 CMD 를 통째로 대체한다)', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(cat /tmp/out.txt)\\" = \\"say: world\\" ] ) && ( [ \\"$(docker image inspect -f ''{{json .Config.Entrypoint}}'' say:1)\\" = ''[\\"echo\\",\\"say:\\"]'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 say: world 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/out.txt)\\" = \\"say: world\\" ]"]}, {"label": "이미지의 ENTRYPOINT 가 맞다", "cmd": ["sh", "-c", "[ \\"$(docker image inspect -f ''{{json .Config.Entrypoint}}'' say:1)\\" = ''[\\"echo\\",\\"say:\\"]'' ]"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 9, '실행 파일 바꿔 실행', '이미지 `say:1` 의 `ENTRYPOINT` 대신 `echo` 로 바꾸고, 인자 `overridden` 을 넘겨 실행하는 명령입니다. 빈칸을 채우세요.', '실행할 때 진입점을 바꾸는 옵션은 `--entrypoint 실행파일` 이에요. 이미지 이름 뒤에는 인자가 옵니다.', NULL, NULL, '[]', 'fill', '["echo", "overridden", "-e", "docker"]', NULL, '`--entrypoint` 뒤에는 바꿀 실행 파일(`echo`)이, 이미지 이름 뒤에는 그 실행 파일에 넘길 인자(`overridden`)가 옵니다. `-e` 는 환경 변수 옵션이고, `docker` 는 컨테이너 안에서 실행할 파일이 아니에요.', '[0, 1]', 'docker run --rm --entrypoint {0} say:1 {1}', NULL, '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 10, '.dockerignore 로 파일 빼고 빌드', '`/tmp/app` 에 `Dockerfile`(`COPY . /data/`), `keep.txt`, `secret.txt` 가 있습니다. **`secret.txt` 는 이미지에 들어가지 않게** `.dockerignore` 를 만들고 이미지 **`ign:1`** 을 빌드하세요. `keep.txt` 는 `/data` 에 있어야 합니다.', '`.dockerignore` 는 빌드 컨텍스트와 같은 위치(`/tmp/app`)에 두고, 제외할 파일 이름을 한 줄씩 적어요. 확인은 `docker run --rm ign:1 ls /data` 로 합니다.', 'cd /tmp/app
echo secret.txt > .dockerignore
docker build -t ign:1 .
docker run --rm ign:1 ls /data

# .dockerignore 에 적은 파일은 빌드 컨텍스트에서 빠져 COPY 되지 않는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; printf ''FROM alpine\\\\nCOPY . /data/\\\\n'' > /tmp/app/Dockerfile; echo keep > /tmp/app/keep.txt; echo hidden > /tmp/app/secret.txt; true"]', '["sh", "-c", "( docker run --rm ign:1 ls /data | grep -qx keep.txt ) && ( ! docker run --rm ign:1 ls /data | grep -qx secret.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "keep.txt 는 이미지에 있다", "cmd": ["sh", "-c", "docker run --rm ign:1 ls /data | grep -qx keep.txt"]}, {"label": "secret.txt 는 이미지에 없다", "cmd": ["sh", "-c", "! docker run --rm ign:1 ls /data | grep -qx secret.txt"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 11, '이미지 레이어 내역 세어 보기', '`/tmp/app/Dockerfile` 이 이미 있고 `RUN echo ...` 줄이 여러 개 들어 있습니다. 이미지 **`layers:1`** 을 빌드한 뒤, `docker history` 목록에서 `echo` 가 들어 있는 줄이 **몇 줄인지** 숫자만 `/tmp/runs.txt` 에 저장하세요.', '`docker history 이미지` 는 레이어를 만든 명령을 줄마다 보여 줘요. `--format {{.CreatedBy}}` 로 명령만 뽑고 `grep -c` 로 세어 보세요.', 'cd /tmp/app
cat Dockerfile
docker build -t layers:1 .
docker history layers:1
docker history --format ''{{.CreatedBy}}'' layers:1 | grep -c echo > /tmp/runs.txt
cat /tmp/runs.txt

# RUN 한 줄마다 레이어가 하나 생긴다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f $(docker images -q) >/dev/null 2>&1; rm -rf /tmp/app /tmp/*.txt; mkdir -p /tmp/app; docker pull -q alpine >/dev/null 2>&1; printf ''FROM alpine\\\\nRUN echo a > /a\\\\nRUN echo b > /b\\\\nRUN echo c > /c\\\\n'' > /tmp/app/Dockerfile; true"]', '["sh", "-c", "( docker image inspect layers:1 >/dev/null 2>&1 ) && ( [ \\"$(cat /tmp/runs.txt)\\" = \\"$(docker history --format ''{{.CreatedBy}}'' layers:1 | grep -c echo)\\" ] ) && ( [ \\"$(cat /tmp/runs.txt)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지가 만들어져 있다", "cmd": ["sh", "-c", "docker image inspect layers:1 >/dev/null 2>&1"]}, {"label": "echo 줄 수가 실제와 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/runs.txt)\\" = \\"$(docker history --format ''{{.CreatedBy}}'' layers:1 | grep -c echo)\\" ]"]}, {"label": "값이 3 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/runs.txt)\\" = 3 ]"]}]', '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 234, 12, '손으로 이미지 만들고 확인하는 흐름', '작은 이미지를 손으로 만들어 확인하는 흐름을 **앞에서 뒤**로 놓으세요.', 'Dockerfile 을 쓰고 → 빌드하고 → 목록에서 찾고 → 실행하고 → 설정을 들여다보는 순서입니다.', NULL, NULL, '[]', 'order', '["`/tmp/app` 에 `Dockerfile` 을 작성한다 (`FROM alpine`, `CMD [\\"echo\\", \\"hi\\"]`)", "`docker build -t app:1 .` 으로 이미지를 빌드한다", "`docker images app` 로 이미지가 생겼는지 확인한다", "`docker run --rm app:1` 으로 실행해 출력이 `hi` 인지 본다", "`docker image inspect -f ''{{.Config.Cmd}}'' app:1` 로 저장된 기본 명령을 확인한다"]', NULL, '**Dockerfile 작성 → 빌드 → 목록 확인 → 실행 → inspect** 순서입니다. 이미지가 있어야 실행할 수 있고, 실행으로 동작을 본 뒤 `inspect` 로 이미지에 저장된 설정(`Cmd`)까지 확인하면 의도대로 만들어졌는지 마무리할 수 있어요.', '[0, 1, 2, 3, 4]', NULL, NULL, '[{"title": "Docker 공식 문서: Dockerfile reference", "url": "https://docs.docker.com/reference/dockerfile/"}, {"title": "Docker 공식 문서: docker buildx build", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}, {"title": "Docker 공식 문서: docker image tag", "url": "https://docs.docker.com/reference/cli/docker/image/tag/"}, {"title": "Docker 공식 문서: docker image history", "url": "https://docs.docker.com/reference/cli/docker/image/history/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 234 AND order_index = 12);

UPDATE quest_set SET display_order = 198 WHERE id = 142;
UPDATE quest_set SET display_order = 199 WHERE id = 179;
UPDATE quest_set SET display_order = 200 WHERE id = 209;
UPDATE quest_set SET display_order = 201 WHERE id = 228;
UPDATE quest_set SET display_order = 202 WHERE id = 148;
UPDATE quest_set SET display_order = 203 WHERE id = 175;
UPDATE quest_set SET display_order = 204 WHERE id = 206;
UPDATE quest_set SET display_order = 197, unit_id = (SELECT id FROM unit WHERE id = 33), icon = '🏗️' WHERE id = 234;
