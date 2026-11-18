-- Git 실습 세트 485. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_docker_build_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 485, '도커 이미지 빌드 손연습: 멀티 스테이지·--target, --build-arg·ARG→ENV, .dockerignore, 빌드 캐시와 --no-cache, 레이어 줄이기, -f, 태그 여러 개', '직접 이미지를 빌드해 구조를 확인합니다. 멀티 스테이지와 COPY --from, --target 으로 중간 단계 빌드, --build-arg 와 ARG·ENV 의 차이, .dockerignore 로 비밀 파일 제외, 캐시와 --no-cache 의 이미지 ID, RUN 을 합쳐 레이어 줄이기, -f 로 다른 Dockerfile 쓰기, 한 번에 여러 태그 붙이기를 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 485);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 1, '두 단계로 빌드해 결과물만 담기 (멀티 스테이지)', '**배경** — 멀티 스테이지 빌드는 `FROM` 을 여러 번 써서 **앞 단계에서 만든 결과물만 마지막 이미지로 가져옵니다**. 컴파일러·소스 같은 빌드 도구는 최종 이미지에 남지 않아 작고 안전해집니다. 단계에는 `FROM 이미지 AS 이름` 으로 이름을 붙이고, `COPY --from=이름 원본 대상` 으로 가져옵니다.

**문제** — `/tmp/work/app/Dockerfile` 을 만드세요. 첫 단계 `FROM alpine AS build` 에서 `RUN echo built > /out.txt`, 둘째 단계 `FROM alpine` 에서 `COPY --from=build /out.txt /app.txt` 하고 `CMD ["cat", "/app.txt"]` 입니다. **`ms:1`** 로 빌드하면 실행했을 때 `built` 가 출력되고, **`/out.txt` 는 최종 이미지에 없어야** 합니다.', '`FROM alpine AS build` → `RUN echo built > /out.txt` → `FROM alpine` → `COPY --from=build /out.txt /app.txt` → `CMD ["cat","/app.txt"]`', 'cat > /tmp/work/app/Dockerfile <<''EOF''
FROM alpine AS build
RUN echo built > /out.txt

FROM alpine
COPY --from=build /out.txt /app.txt
CMD ["cat", "/app.txt"]
EOF
docker build -t ms:1 /tmp/work/app
docker run --rm ms:1

# 둘째 FROM 부터가 최종 이미지다. 앞 단계는 COPY --from 으로 필요한 파일만 넘기고 버려진다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true"]', '["sh", "-c", "( docker image inspect ms:1 >/dev/null 2>&1 ) && ( [ \\"$(docker run --rm ms:1 2>/dev/null)\\" = built ] ) && ( docker run --rm --entrypoint sh ms:1 -c \\"test ! -e /out.txt\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 ms:1 이 있다", "cmd": ["sh", "-c", "docker image inspect ms:1 >/dev/null 2>&1"]}, {"label": "실행하면 built 가 출력된다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm ms:1 2>/dev/null)\\" = built ]"]}, {"label": "최종 이미지에 /out.txt 가 없다", "cmd": ["sh", "-c", "docker run --rm --entrypoint sh ms:1 -c \\"test ! -e /out.txt\\""]}]', '[{"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 2, '중간 단계까지만 빌드하기 (--target)', '**배경** — `docker build --target 단계이름` 은 Dockerfile 의 **지정한 단계까지만** 빌드해 그 단계를 이미지로 만듭니다. 디버깅용 이미지나 테스트 단계만 따로 만들 때 씁니다. `/tmp/work/app/Dockerfile` 에는 `build` 단계(`/out.txt` 생성)와 최종 단계가 준비되어 있습니다.

**문제** — **`build` 단계까지만** 빌드해서 이미지 **`ms:build`** 를 만드세요. 이 이미지 안에는 `/out.txt` 가 **있어야** 합니다.', '`docker build --target build -t ms:build /tmp/work/app`', 'docker build --target build -t ms:build /tmp/work/app
docker run --rm ms:build cat /out.txt

# --target 은 그 단계에서 멈춘다. 최종 단계가 아니므로 CMD 도 최종과 다를 수 있다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine AS build\\nRUN echo built > /out.txt\\n\\nFROM alpine\\nCOPY --from=build /out.txt /app.txt\\nCMD [\\"cat\\", \\"/app.txt\\"]\\nEOF\\n"]', '["sh", "-c", "( docker image inspect ms:build >/dev/null 2>&1 ) && ( docker run --rm ms:build test -f /out.txt ) && ( docker run --rm ms:build test ! -e /app.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 ms:build 가 있다", "cmd": ["sh", "-c", "docker image inspect ms:build >/dev/null 2>&1"]}, {"label": "build 단계라 /out.txt 가 있다", "cmd": ["sh", "-c", "docker run --rm ms:build test -f /out.txt"]}, {"label": "최종 단계의 /app.txt 는 없다", "cmd": ["sh", "-c", "docker run --rm ms:build test ! -e /app.txt"]}]', '[{"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}, {"title": "docker buildx build 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 3, '빌드할 때 값 넘기기 (--build-arg)', '**배경** — Dockerfile 의 `ARG 이름=기본값` 은 **빌드할 때만** 쓰는 변수이고, `docker build --build-arg 이름=값` 으로 바꿀 수 있습니다. 준비된 Dockerfile 은 `ARG VERSION=1.0` 을 `/ver.txt` 에 기록합니다.

**문제** — `VERSION` 을 **`2.5`** 로 넘겨 이미지 **`arg:1`** 을 빌드하세요. 실행하면 `2.5` 가 출력되어야 합니다.', '`docker build --build-arg VERSION=2.5 -t arg:1 /tmp/work/app`', 'docker build --build-arg VERSION=2.5 -t arg:1 /tmp/work/app
docker run --rm arg:1

# 기본값(1.0)은 --build-arg 로 덮어쓴다. ARG 는 빌드가 끝나면 사라진다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine\\nARG VERSION=1.0\\nRUN echo $VERSION > /ver.txt\\nCMD [\\"cat\\", \\"/ver.txt\\"]\\nEOF\\n"]', '["sh", "-c", "( docker image inspect arg:1 >/dev/null 2>&1 ) && ( [ \\"$(docker run --rm arg:1 2>/dev/null)\\" = 2.5 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 arg:1 이 있다", "cmd": ["sh", "-c", "docker image inspect arg:1 >/dev/null 2>&1"]}, {"label": "실행하면 2.5 가 출력된다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm arg:1 2>/dev/null)\\" = 2.5 ]"]}]', '[{"title": "빌드 변수(ARG)", "url": "https://docs.docker.com/build/building/variables/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 4, '빌드 값을 실행 중에도 남기기 (ARG → ENV)', '**배경** — `ARG` 는 빌드가 끝나면 **컨테이너에 남지 않습니다**. 실행 중에도 쓰려면 `ENV 이름=$ARG이름` 으로 **환경 변수에 복사**합니다. 준비된 Dockerfile 은 `ARG V` 를 `ENV APP_V` 로 넘깁니다.

**문제** — `V` 를 **`3`** 으로 넘겨 이미지 **`arg:2`** 를 빌드하고, 그 이미지에서 환경 변수 **`APP_V`** 의 값을 출력해 **`/tmp/q4.txt`** 에 저장하세요. (`3`)', '`docker build --build-arg V=3 -t arg:2 …` 후 `docker run --rm arg:2 printenv APP_V`', 'docker build --build-arg V=3 -t arg:2 /tmp/work/app
docker run --rm arg:2 printenv APP_V > /tmp/q4.txt
cat /tmp/q4.txt

# ARG 단독은 실행 중에 보이지 않는다. ENV 로 옮기면 이미지에 남아 컨테이너에서 보인다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine\\nARG V=0\\nENV APP_V=$V\\nCMD [\\"sh\\", \\"-c\\", \\"echo $APP_V\\"]\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q4.txt)\\" = 3 ] ) && ( docker image inspect arg:2 >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 3 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q4.txt)\\" = 3 ]"]}, {"label": "arg:2 이미지가 있다", "cmd": ["sh", "-c", "docker image inspect arg:2 >/dev/null 2>&1"]}]', '[{"title": "빌드 변수(ARG)", "url": "https://docs.docker.com/build/building/variables/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 5, '이미지에 넣지 않을 파일 정하기 (.dockerignore)', '**배경** — `COPY . /app` 은 빌드 컨텍스트의 **모든 파일**을 이미지에 넣습니다. 비밀번호 파일(`secret.env`)이나 `.git` 이 딸려 들어가면 위험합니다. 컨텍스트 폴더의 **`.dockerignore`** 에 제외할 파일을 적으면 빌드 컨텍스트에서 빠집니다. `/tmp/work/app` 에는 `keep.txt` 와 `secret.env` 가 있습니다.

**문제** — `.dockerignore` 로 **`secret.env` 를 제외**하고 이미지 **`ig:1`** 을 빌드하세요. 이미지 안 `/app` 에는 `keep.txt` 는 있고 `secret.env` 는 **없어야** 합니다.', '`echo secret.env > /tmp/work/app/.dockerignore` 후 `docker build -t ig:1 /tmp/work/app`', 'echo secret.env > /tmp/work/app/.dockerignore
docker build -t ig:1 /tmp/work/app
docker run --rm ig:1

# .dockerignore 는 빌드 컨텍스트에서 파일을 뺀다. 비밀·불필요한 파일이 이미지에 들어가는 것을 막는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine\\nCOPY . /app\\nCMD [\\"ls\\", \\"/app\\"]\\nEOF\\necho keep > /tmp/work/app/keep.txt\\necho password=1234 > /tmp/work/app/secret.env\\n"]', '["sh", "-c", "( docker image inspect ig:1 >/dev/null 2>&1 ) && ( docker run --rm ig:1 | grep -qx keep.txt ) && ( ! docker run --rm ig:1 | grep -qx secret.env )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 ig:1 이 있다", "cmd": ["sh", "-c", "docker image inspect ig:1 >/dev/null 2>&1"]}, {"label": "/app 에 keep.txt 가 있다", "cmd": ["sh", "-c", "docker run --rm ig:1 | grep -qx keep.txt"]}, {"label": "secret.env 는 없다", "cmd": ["sh", "-c", "! docker run --rm ig:1 | grep -qx secret.env"]}]', '[{"title": ".dockerignore 와 빌드 컨텍스트", "url": "https://docs.docker.com/build/concepts/context/#dockerignore-files"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 6, '캐시를 썼는지 빌드 출력으로 알아보기 (CACHED · --no-cache)', '**배경** — 도커는 Dockerfile 의 각 줄 결과를 **캐시**해, 바뀐 것이 없으면 그 줄을 다시 실행하지 않고 재사용합니다. 자세한 진행 출력(`--progress=plain`)에서 캐시를 쓴 줄 아래에는 **`CACHED`** 가 보이고, 캐시를 쓰지 않으면 `DONE` 이 보입니다. 처음부터 다시 만들려면 `--no-cache` 를 줍니다. (이미지 ID 는 캐시를 써도 생성 시각 때문에 달라질 수 있어 비교에 쓰지 않습니다.) `/tmp/work/app` 에 간단한 Dockerfile 이 있습니다.

**문제** — 이름 **`c:1`** 로 먼저 한 번 빌드해 캐시를 만든 뒤, (1) **같은 빌드를 다시** 하고 그 진행 출력을 **`/tmp/q6b.txt`** 에, (2) **`--no-cache`** 로 다시 빌드하고 그 진행 출력을 **`/tmp/q6c.txt`** 에 저장하세요. 두 번 모두 `--progress=plain` 을 쓰고 `2>&1` 로 출력을 모두 저장합니다. (1)에서는 `RUN` 줄이 `CACHED`, (2)에서는 `DONE` 이어야 합니다.', '`docker build --progress=plain -t c:1 … > /tmp/q6b.txt 2>&1`, 그리고 `--no-cache` 를 더해 `/tmp/q6c.txt` 에 저장', 'docker build -t c:1 /tmp/work/app
docker build --progress=plain -t c:1 /tmp/work/app > /tmp/q6b.txt 2>&1
docker build --progress=plain --no-cache -t c:1 /tmp/work/app > /tmp/q6c.txt 2>&1
grep -A1 ''RUN echo'' /tmp/q6b.txt /tmp/q6c.txt

# 캐시를 쓴 단계는 CACHED, --no-cache 면 DONE. 진행 출력은 stderr 로 나와서 2>&1 이 필요하다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine\\nRUN echo hello > /hello.txt\\nEOF\\n"]', '["sh", "-c", "( grep -A1 \\"RUN echo hello\\" /tmp/q6b.txt | grep -q CACHED ) && ( grep -A1 \\"RUN echo hello\\" /tmp/q6c.txt | grep -q DONE && ! grep -A1 \\"RUN echo hello\\" /tmp/q6c.txt | grep -q CACHED )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "두 번째 빌드의 RUN 이 CACHED 다", "cmd": ["sh", "-c", "grep -A1 \\"RUN echo hello\\" /tmp/q6b.txt | grep -q CACHED"]}, {"label": "--no-cache 빌드의 RUN 은 CACHED 가 아니다", "cmd": ["sh", "-c", "grep -A1 \\"RUN echo hello\\" /tmp/q6c.txt | grep -q DONE && ! grep -A1 \\"RUN echo hello\\" /tmp/q6c.txt | grep -q CACHED"]}]', '[{"title": "빌드 캐시", "url": "https://docs.docker.com/build/cache/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 7, 'RUN 줄을 합쳐 레이어 줄이기', '**배경** — Dockerfile 의 `RUN`·`COPY`·`ADD` 한 줄은 **이미지 레이어 하나**를 만듭니다. 관련된 명령을 `&&` 로 이어 **한 줄**로 쓰면 레이어가 줄어들어 이미지가 단순해지고 캐시 관리가 쉬워집니다. 레이어 수는 `docker image inspect -f ''{{len .RootFS.Layers}}'' 이름` 입니다. 준비된 Dockerfile 은 `RUN` 이 3줄(`alpine` 바탕 레이어 1 + 3 = 4개 레이어)입니다.

**문제** — 세 `RUN` 을 **한 줄**(`&&`)로 합쳐 `/a.txt`, `/b.txt`, `/c.txt` 를 만들고, 이미지 **`ly:1`** 로 빌드하세요. 레이어는 **2개**(바탕 1 + RUN 1)가 되어야 합니다.', '`RUN echo a > /a.txt && echo b > /b.txt && echo c > /c.txt`', 'cat > /tmp/work/app/Dockerfile <<''EOF''
FROM alpine
RUN echo a > /a.txt && echo b > /b.txt && echo c > /c.txt
EOF
docker build -t ly:1 /tmp/work/app
docker image inspect -f ''{{len .RootFS.Layers}}'' ly:1

# RUN 한 줄 = 레이어 하나. && 로 합치면 레이어가 줄어든다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine\\nRUN echo a > /a.txt\\nRUN echo b > /b.txt\\nRUN echo c > /c.txt\\nEOF\\n"]', '["sh", "-c", "( docker image inspect ly:1 >/dev/null 2>&1 ) && ( [ \\"$(docker image inspect -f ''{{len .RootFS.Layers}}'' ly:1 2>/dev/null)\\" = 2 ] ) && ( docker run --rm ly:1 sh -c \\"test -f /a.txt && test -f /b.txt && test -f /c.txt\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 ly:1 이 있다", "cmd": ["sh", "-c", "docker image inspect ly:1 >/dev/null 2>&1"]}, {"label": "레이어가 2개다", "cmd": ["sh", "-c", "[ \\"$(docker image inspect -f ''{{len .RootFS.Layers}}'' ly:1 2>/dev/null)\\" = 2 ]"]}, {"label": "세 파일이 모두 있다", "cmd": ["sh", "-c", "docker run --rm ly:1 sh -c \\"test -f /a.txt && test -f /b.txt && test -f /c.txt\\""]}]', '[{"title": "빌드 캐시", "url": "https://docs.docker.com/build/cache/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 8, '다른 이름의 Dockerfile 로 빌드하기 (-f)', '**배경** — `docker build` 는 기본으로 컨텍스트의 `Dockerfile` 을 찾습니다. 환경별로 `Dockerfile.prod`·`Dockerfile.dev` 처럼 나눠 쓰려면 **`-f 파일`** 로 지정합니다. 마지막 인자는 **빌드 컨텍스트** 폴더입니다. `/tmp/work/app` 에는 `Dockerfile` 이 없고 `Dockerfile.prod` 만 있습니다.

**문제** — `Dockerfile.prod` 로 이미지 **`prod:1`** 을 빌드하세요. 실행하면 `prod` 가 출력되어야 합니다.', '`docker build -f /tmp/work/app/Dockerfile.prod -t prod:1 /tmp/work/app`', 'docker build -f /tmp/work/app/Dockerfile.prod -t prod:1 /tmp/work/app
docker run --rm prod:1

# -f 는 Dockerfile 위치, 마지막 인자는 컨텍스트. 둘은 서로 다를 수 있다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile.prod <<''EOF''\\nFROM alpine\\nRUN echo prod > /env.txt\\nCMD [\\"cat\\", \\"/env.txt\\"]\\nEOF\\n"]', '["sh", "-c", "( docker image inspect prod:1 >/dev/null 2>&1 ) && ( [ \\"$(docker run --rm prod:1 2>/dev/null)\\" = prod ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지 prod:1 이 있다", "cmd": ["sh", "-c", "docker image inspect prod:1 >/dev/null 2>&1"]}, {"label": "실행하면 prod 가 출력된다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm prod:1 2>/dev/null)\\" = prod ]"]}]', '[{"title": "docker buildx build 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 9, '한 번에 태그 두 개 붙이기 (-t 여러 번)', '**배경** — `-t 이름:태그` 를 **여러 번** 주면 같은 이미지에 태그가 여러 개 붙습니다(복사가 아니라 이름표만 늘어납니다). 버전 태그와 `latest` 를 함께 붙일 때 자주 씁니다. `/tmp/work/app/Dockerfile` 이 준비되어 있습니다.

**문제** — 한 번의 빌드로 이미지에 **`app:1.0`** 과 **`app:latest`** 두 태그를 붙이세요. 두 태그의 이미지 ID 는 **같아야** 합니다.', '`docker build -t app:1.0 -t app:latest /tmp/work/app`', 'docker build -t app:1.0 -t app:latest /tmp/work/app
docker images app

# 태그는 이름표다. 같은 이미지 ID 에 이름이 둘 붙는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f ms:1 ms:build arg:1 arg:2 ig:1 c:1 ly:1 ly:2 prod:1 app:1.0 app:latest >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/app; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; cat > /tmp/work/app/Dockerfile <<''EOF''\\nFROM alpine\\nRUN echo hello > /hello.txt\\nEOF\\n"]', '["sh", "-c", "( docker image inspect app:1.0 >/dev/null 2>&1 ) && ( docker image inspect app:latest >/dev/null 2>&1 ) && ( [ \\"$(docker image inspect -f ''{{.Id}}'' app:1.0 2>/dev/null)\\" = \\"$(docker image inspect -f ''{{.Id}}'' app:latest 2>/dev/null)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "app:1.0 이 있다", "cmd": ["sh", "-c", "docker image inspect app:1.0 >/dev/null 2>&1"]}, {"label": "app:latest 가 있다", "cmd": ["sh", "-c", "docker image inspect app:latest >/dev/null 2>&1"]}, {"label": "두 태그의 ID 가 같다", "cmd": ["sh", "-c", "[ \\"$(docker image inspect -f ''{{.Id}}'' app:1.0 2>/dev/null)\\" = \\"$(docker image inspect -f ''{{.Id}}'' app:latest 2>/dev/null)\\" ]"]}]', '[{"title": "docker buildx build 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 10, 'ARG 의 유효 범위', 'Dockerfile 의 `ARG` 로 받은 값은 어디까지 남을까요?', '빌드할 때와 실행할 때를 구분해요.', NULL, NULL, '[]', 'choice', '["ARG 는 빌드와 실행 모두에서 환경 변수로 자동으로 보인다", "ARG 는 빌드 중에만 쓰이고 실행 중인 컨테이너에는 남지 않는다", "ARG 는 docker run 으로 컨테이너를 만들 때만 값을 받을 수 있다", "ARG 는 이미지를 pull 한 다른 호스트에서도 그대로 유지된다"]', 1, '도커 문서는 ARG 가 빌드 시점에서만 사용 가능한 변수이고 빌드가 끝난 컨테이너에는 남지 않는다고 설명합니다. 실행 중에도 필요하면 ENV 로 복사해야 합니다.', NULL, NULL, NULL, '[{"title": "빌드 변수(ARG)", "url": "https://docs.docker.com/build/building/variables/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 11, '멀티 스테이지에서 단계까지만 빌드', '멀티 스테이지 Dockerfile 에서 **지정한 단계까지만 빌드**하는 옵션입니다. 빈칸을 채우세요.', '"목표 지점" 이에요.', NULL, NULL, '[]', 'fill', '["target", "from", "stage", "until"]', NULL, '도커 문서는 docker build --target 이 멀티 스테이지 빌드에서 빌드할 대상 단계를 지정한다고 설명합니다. COPY --from 은 다른 단계의 파일을 가져올 때 쓰는 Dockerfile 문법입니다.', '[0]', 'docker build --{0} build -t ms:build .', NULL, '[{"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 485, 12, '멀티 스테이지 이미지 만드는 순서', '빌드 도구가 최종 이미지에 남지 않는 멀티 스테이지 Dockerfile 을 쓰는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '빌드 단계 → 결과물 → 최종 단계 → 가져오기예요.', NULL, NULL, '[]', 'order', '["`FROM 이미지 AS build` 로 빌드용 단계를 시작한다", "그 단계에서 `RUN` 으로 컴파일·빌드해 결과물을 만든다", "새 `FROM` 으로 가볍고 최소한의 최종 단계를 시작한다", "`COPY --from=build` 로 결과물만 최종 단계로 가져온다"]', NULL, '도커 멀티 스테이지 문서의 구조입니다. 빌드 도구는 앞 단계에 남고 최종 이미지에는 결과물만 포함됩니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 485 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 213 WHERE id = 154;
UPDATE quest_set SET display_order = 214 WHERE id = 241;
UPDATE quest_set SET display_order = 215 WHERE id = 187;
UPDATE quest_set SET display_order = 216 WHERE id = 248;
UPDATE quest_set SET display_order = 217 WHERE id = 8;
UPDATE quest_set SET display_order = 218 WHERE id = 234;
UPDATE quest_set SET display_order = 219 WHERE id = 337;
UPDATE quest_set SET display_order = 220 WHERE id = 346;
UPDATE quest_set SET display_order = 221 WHERE id = 142;
UPDATE quest_set SET display_order = 222 WHERE id = 239;
UPDATE quest_set SET display_order = 223 WHERE id = 179;
UPDATE quest_set SET display_order = 224 WHERE id = 246;
UPDATE quest_set SET display_order = 225 WHERE id = 209;
UPDATE quest_set SET display_order = 226 WHERE id = 254;
UPDATE quest_set SET display_order = 227 WHERE id = 228;
UPDATE quest_set SET display_order = 228 WHERE id = 352;
UPDATE quest_set SET display_order = 229 WHERE id = 148;
UPDATE quest_set SET display_order = 230 WHERE id = 240;
UPDATE quest_set SET display_order = 231 WHERE id = 175;
UPDATE quest_set SET display_order = 232 WHERE id = 245;
UPDATE quest_set SET display_order = 233 WHERE id = 206;
UPDATE quest_set SET display_order = 234 WHERE id = 253;
UPDATE quest_set SET display_order = 235 WHERE id = 237;
UPDATE quest_set SET display_order = 236 WHERE id = 38;
UPDATE quest_set SET display_order = 237 WHERE id = 39;
UPDATE quest_set SET display_order = 238 WHERE id = 97;
UPDATE quest_set SET display_order = 211, unit_id = (SELECT id FROM unit WHERE id = 33), icon = '🧅' WHERE id = 485;
