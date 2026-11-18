-- Git 실습 세트 490. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_docker_read_fix_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 490, 'Dockerfile·compose 읽고 고치기 손연습: COPY 경로, exec 형식 CMD, ENTRYPOINT·CMD, ${변수:-기본값}, profiles, -f 병합, FROM 앞 ARG, env_file 우선순위', '틀린 Dockerfile 과 compose 파일을 직접 고치고 확인합니다. COPY 경로 오류, exec 형식 CMD 의 변수 문제, ENTRYPOINT 와 CMD 의 인자 대체, compose config 로 변수·profiles·파일 병합 읽기, FROM 앞 ARG 로 베이스 태그 바꾸기, env_file 과 environment 우선순위를 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 490);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 1, 'COPY 경로가 틀려 빌드가 실패하는 Dockerfile 고치기', '**배경** — `COPY 원본 대상` 의 **원본은 빌드 컨텍스트 기준 경로**입니다. 폴더 안에 있는 파일을 루트처럼 적으면 `not found` 로 빌드가 실패합니다. `/tmp/work/q1` 에 Dockerfile 과 `src/app.txt`(내용 `from-src`)가 있는데, Dockerfile 은 `COPY app.txt ...` 로 잘못 적혀 있습니다.

**문제** — Dockerfile 을 고쳐 이미지 **`t1`** 로 빌드하고, 컨테이너를 실행한 출력(`from-src`)을 **`/tmp/q1.txt`** 에 저장하세요.', '`sed -i` 나 편집기로 `COPY src/app.txt /data/app.txt` 로 고치고 `docker build -t t1 /tmp/work/q1` → `docker run --rm t1 > /tmp/q1.txt`', 'sed -i ''s#COPY app.txt#COPY src/app.txt#'' /tmp/work/q1/Dockerfile
docker build -t t1 /tmp/work/q1
docker run --rm t1 > /tmp/q1.txt
cat /tmp/q1.txt

# 원본 경로는 컨텍스트(/tmp/work/q1) 기준이다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q1; cat > /tmp/work/q1/Dockerfile <<''EOF''\\nFROM alpine\\nCOPY app.txt /data/app.txt\\nCMD [\\"cat\\", \\"/data/app.txt\\"]\\nEOF\\nmkdir -p /tmp/work/q1/src; echo from-src > /tmp/work/q1/src/app.txt"]', '["sh", "-c", "( [ \\"$(cat /tmp/q1.txt)\\" = from-src ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 from-src 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q1.txt)\\" = from-src ]"]}]', '[{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 2, '$변수가 그대로 찍히는 CMD 고치기 (exec 형식)', '**배경** — `CMD ["echo", "$GREETING"]` 같은 **exec 형식**(JSON 배열)은 쉘을 거치지 않아 `$GREETING` 이 **풀리지 않고 글자 그대로** 출력됩니다. 변수를 쓰려면 `["sh", "-c", "echo $GREETING"]` 처럼 쉘을 명시하거나 쉘 형식(`CMD echo $GREETING`)을 씁니다. `/tmp/work/q2` 의 Dockerfile 은 `ENV GREETING=hello` 인데 CMD 가 exec 형식입니다.

**문제** — Dockerfile 을 고쳐 이미지 **`t2`** 를 빌드하고, 실행 출력(`hello`)을 **`/tmp/q2.txt`** 에 저장하세요.', '`CMD ["sh", "-c", "echo $GREETING"]` 로 고쳐요.', 'sed -i ''s#^CMD .*#CMD ["sh", "-c", "echo $GREETING"]#'' /tmp/work/q2/Dockerfile
docker build -t t2 /tmp/work/q2
docker run --rm t2 > /tmp/q2.txt
cat /tmp/q2.txt

# exec 형식은 쉘이 없어 $VAR 가 안 풀린다. sh -c 로 쉘을 거친다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q2; cat > /tmp/work/q2/Dockerfile <<''EOF''\\nFROM alpine\\nENV GREETING=hello\\nCMD [\\"echo\\", \\"$GREETING\\"]\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q2.txt)\\" = hello ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 hello 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q2.txt)\\" = hello ]"]}]', '[{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 3, 'ENTRYPOINT 는 두고 CMD 만 바꿔 실행하기', '**배경** — `ENTRYPOINT` 는 **항상 실행되는 명령**이고 `CMD` 는 그 뒤에 붙는 **기본 인자**입니다. `docker run 이미지 인자…` 로 적은 인자는 **CMD 만 대체**합니다. 이미지 **`t3`** 는 `ENTRYPOINT ["echo", "arg:"]`, `CMD ["default"]` 로 빌드되어 있습니다.

**문제** — `t3` 를 **다시 빌드하지 않고** 인자 `custom` 을 주어 실행하고, 출력(`arg: custom`)을 **`/tmp/q3.txt`** 에 저장하세요.', '`docker run --rm t3 custom > /tmp/q3.txt`', 'docker run --rm t3 custom > /tmp/q3.txt
cat /tmp/q3.txt

# 인자 없이 실행하면 arg: default. 인자를 주면 CMD(default)만 바뀐다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q3; cat > /tmp/work/q3/Dockerfile <<''EOF''\\nFROM alpine\\nENTRYPOINT [\\"echo\\", \\"arg:\\"]\\nCMD [\\"default\\"]\\nEOF\\ndocker build -q -t t3 /tmp/work/q3 >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/q3.txt)\\" = \\"arg: custom\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 arg: custom 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q3.txt)\\" = \\"arg: custom\\" ]"]}]', '[{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 4, '환경 변수로 compose 의 포트 바꿔 확인하기 (${PORT:-8080})', '**배경** — compose 파일의 **`${변수:-기본값}`** 은 변수가 있으면 그 값을, 없으면 기본값을 씁니다. `docker compose config` 는 변수를 **풀어 합친 최종 설정**을 출력하므로 실행 없이 값을 확인할 수 있습니다. `/tmp/work/q4` 에 `ports: ["${PORT:-8080}:80"]` 인 `compose.yaml` 이 있습니다.

**문제** — 환경 변수 **`PORT=9090`** 으로 `/tmp/work/q4` 의 최종 설정을 출력해 **`/tmp/q4.txt`** 에 저장하세요. (게시 포트가 `9090` 이어야 합니다.)', '`cd /tmp/work/q4 && PORT=9090 docker compose config > /tmp/q4.txt`', 'cd /tmp/work/q4 && PORT=9090 docker compose config > /tmp/q4.txt
grep -n published /tmp/q4.txt

# PORT 가 없으면 8080. 변수 한 줄을 앞에 붙여 이 명령에만 적용한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q4; cat > /tmp/work/q4/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:1.25\\n    ports:\\n      - \\"${PORT:-8080}:80\\"\\nEOF\\n"]', '["sh", "-c", "( grep -q 9090 /tmp/q4.txt ) && ( ! grep -q 8080 /tmp/q4.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "게시 포트가 9090 이다", "cmd": ["sh", "-c", "grep -q 9090 /tmp/q4.txt"]}, {"label": "8080 은 없다", "cmd": ["sh", "-c", "! grep -q 8080 /tmp/q4.txt"]}]', '[{"title": "docker compose config", "url": "https://docs.docker.com/reference/cli/docker/compose/config/"}, {"title": "Compose 파일 레퍼런스", "url": "https://docs.docker.com/reference/compose-file/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 5, 'profiles 로 숨은 서비스 포함해 목록 보기', '**배경** — 서비스에 **`profiles: [이름]`** 을 붙이면 평소 `up` 에서는 **제외**되고, `--profile 이름` 을 줘야 포함됩니다. 디버그·마이그레이션 같은 선택 서비스에 씁니다. `docker compose config --services` 는 서비스 이름만 나열합니다. `/tmp/work/q6` 의 compose 에는 `web` 과 `debug`(profile `debug`)가 있습니다.

**문제** — **`debug` 프로필을 켠 상태**의 서비스 이름 목록을 **`/tmp/q6.txt`** 에 저장하세요. (`web` 과 `debug` 모두 나와야 합니다.)', '`docker compose --profile debug config --services > /tmp/q6.txt` (compose 파일이 있는 폴더에서)', 'cd /tmp/work/q6 && docker compose --profile debug config --services > /tmp/q6.txt
cat /tmp/q6.txt

# --profile 이 없으면 web 만 나온다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q6; cat > /tmp/work/q6/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:1.25\\n  debug:\\n    image: alpine\\n    profiles: [\\"debug\\"]\\nEOF\\n"]', '["sh", "-c", "( grep -qx web /tmp/q6.txt ) && ( grep -qx debug /tmp/q6.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web 이 있다", "cmd": ["sh", "-c", "grep -qx web /tmp/q6.txt"]}, {"label": "debug 가 있다", "cmd": ["sh", "-c", "grep -qx debug /tmp/q6.txt"]}]', '[{"title": "Compose profiles", "url": "https://docs.docker.com/compose/how-tos/profiles/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 6, '파일 두 개를 합친 최종 설정 읽기 (-f -f)', '**배경** — `docker compose -f 기본.yaml -f 덮어쓰기.yaml` 은 **뒤 파일이 앞 파일을 덮어쓰며 합칩니다**. 환경별 차이(이미지 태그 등)만 따로 두는 방식입니다. `config` 로 합친 결과를 확인합니다. `/tmp/work/q7` 에 `base.yaml`(image `nginx:1.24`)과 `prod.yaml`(image `nginx:1.25`)이 있습니다.

**문제** — 두 파일을 **`base.yaml` 다음 `prod.yaml`** 순서로 합친 최종 설정의 `image` 줄을 **`/tmp/q7.txt`** 에 저장하세요. (`nginx:1.25` 만 나와야 합니다.)', '`docker compose -f base.yaml -f prod.yaml config | grep image > /tmp/q7.txt`', 'cd /tmp/work/q7 && docker compose -f base.yaml -f prod.yaml config | grep image > /tmp/q7.txt
cat /tmp/q7.txt

# 뒤에 적은 파일이 우선한다. 순서를 바꾸면 1.24 가 나온다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q7; cat > /tmp/work/q7/base.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:1.24\\nEOF\\ncat > /tmp/work/q7/prod.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:1.25\\nEOF\\n"]', '["sh", "-c", "( grep -q \\"nginx:1.25\\" /tmp/q7.txt ) && ( ! grep -q \\"nginx:1.24\\" /tmp/q7.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "nginx:1.25 가 있다", "cmd": ["sh", "-c", "grep -q \\"nginx:1.25\\" /tmp/q7.txt"]}, {"label": "nginx:1.24 는 없다", "cmd": ["sh", "-c", "! grep -q \\"nginx:1.24\\" /tmp/q7.txt"]}]', '[{"title": "Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 7, 'FROM 의 태그를 빌드 인자로 바꾸기 (ARG 를 FROM 앞에)', '**배경** — **`FROM` 앞에 선언한 `ARG`** 는 `FROM` 줄에서 쓸 수 있어 **베이스 이미지 태그를 빌드 때 바꿀 수** 있습니다(`FROM alpine:${TAG}`). `--build-arg TAG=값` 으로 넘깁니다. `/tmp/work/q8` 의 Dockerfile 은 `ARG TAG=3.18` 입니다.

**문제** — `TAG` 를 **`3.19`** 로 주어 이미지 **`t8`** 을 빌드하고, 실행 출력(`/etc/alpine-release`)을 **`/tmp/q8.txt`** 에 저장하세요. (`3.19` 로 시작해야 합니다.)', '`docker build --build-arg TAG=3.19 -t t8 /tmp/work/q8` → `docker run --rm t8 > /tmp/q8.txt`', 'docker build --build-arg TAG=3.19 -t t8 /tmp/work/q8
docker run --rm t8 > /tmp/q8.txt
cat /tmp/q8.txt

# FROM 뒤의 ARG 는 FROM 줄에서 못 쓴다. FROM 앞에 선언해야 한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q8; cat > /tmp/work/q8/Dockerfile <<''EOF''\\nARG TAG=3.18\\nFROM alpine:${TAG}\\nCMD [\\"cat\\", \\"/etc/alpine-release\\"]\\nEOF\\n"]', '["sh", "-c", "( grep -q \\"^3\\\\.19\\" /tmp/q8.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 3.19 로 시작한다", "cmd": ["sh", "-c", "grep -q \\"^3\\\\.19\\" /tmp/q8.txt"]}]', '[{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 8, 'env_file 과 environment 중 이기는 값 확인하기', '**배경** — compose 서비스에서 `environment:` 에 직접 적은 값은 `env_file:` 의 값보다 **우선**합니다. 같은 변수가 두 곳에 있을 때 최종 값을 직접 실행해 확인합니다. `/tmp/work/q9` 의 서비스 `app` 은 `env_file` 에 `A=1`, `environment` 에 `A=2` 이고 명령은 `printenv A` 입니다.

**문제** — 서비스 `app` 을 한 번 실행(`run --rm -T`)해 출력된 `A` 값을 **`/tmp/q9.txt`** 에 저장하세요.', '`docker compose run --rm -T app > /tmp/q9.txt` (compose 파일이 있는 폴더에서)', 'cd /tmp/work/q9 && docker compose run --rm -T app > /tmp/q9.txt
cat /tmp/q9.txt

# environment 가 env_file 을 이겨 2 가 출력된다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q9; cat > /tmp/work/q9/compose.yaml <<''EOF''\\nservices:\\n  app:\\n    image: alpine\\n    command: printenv A\\n    env_file: env.app\\n    environment:\\n      A: \\"2\\"\\nEOF\\ncat > /tmp/work/q9/env.app <<''EOF''\\nA=1\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q9.txt)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 2 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q9.txt)\\" = 2 ]"]}]', '[{"title": "Compose 환경 변수 우선순위", "url": "https://docs.docker.com/compose/how-tos/environment-variables/envvars-precedence/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 9, '오타 때문에 검증에 실패하는 compose 파일 고치기', '**배경** — `docker compose config -q` 는 파일을 **읽어 문법과 키 이름만 검증**하고 조용히(`-q`) 끝납니다. 오류가 있으면 종료 코드가 0 이 아니라 `&&` 로 이으면 다음 일을 막습니다. `/tmp/work/q10` 의 `compose.yaml` 은 키 이름이 `imag:` 로 잘못 적혀 있어 검증이 실패합니다.

**문제** — 파일을 고친 뒤 `docker compose config -q` 가 **성공했을 때만** **`/tmp/q10.txt`** 에 `valid` 를 쓰세요. (`&&` 로 이으세요.)', '`imag` 를 `image` 로 고친 뒤 `docker compose config -q && echo valid > /tmp/q10.txt`', 'cd /tmp/work/q10 && sed -i ''s/imag:/image:/'' compose.yaml
docker compose config -q && echo valid > /tmp/q10.txt
cat /tmp/q10.txt

# 오타가 있으면 additional properties ''imag'' not allowed 오류가 난다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3 t8 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q10; cat > /tmp/work/q10/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    imag: nginx:1.25\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q10.txt)\\" = valid ] ) && ( cd /tmp/work/q10 && docker compose config -q )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "q10.txt 에 valid 가 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q10.txt)\\" = valid ]"]}, {"label": "compose.yaml 이 검증을 통과한다", "cmd": ["sh", "-c", "cd /tmp/work/q10 && docker compose config -q"]}]', '[{"title": "docker compose config", "url": "https://docs.docker.com/reference/cli/docker/compose/config/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 10, 'docker run 이미지 인자 의 효과', 'ENTRYPOINT 와 CMD 가 모두 있는 이미지를 `docker run 이미지 custom` 으로 실행하면 `custom` 은 무엇을 대체할까요?', 'ENTRYPOINT 는 따로 바꾸는 옵션이 있어요.', NULL, NULL, '[]', 'choice', '["ENTRYPOINT 만 대체한다", "CMD 만 대체한다", "ENTRYPOINT 와 CMD 를 모두 대체한다", "둘 다 그대로이고 무시된다"]', 1, 'run 뒤에 적은 인자는 CMD 를 대체합니다. ENTRYPOINT 를 바꾸려면 --entrypoint 옵션을 써야 합니다.', NULL, NULL, NULL, '[{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 11, '프로필을 켜고 서비스 목록 보기', 'profile 이 붙은 서비스까지 포함해 이름을 나열하는 명령입니다. 빈칸을 채우세요.', '"프로필" 의 영어예요.', NULL, NULL, '[]', 'fill', '["profile", "env-file", "project-name", "file"]', NULL, '--profile 이름 은 해당 프로필의 서비스를 활성화합니다. --env-file 은 변수 파일, --project-name 은 프로젝트 이름, --file 은 compose 파일 경로를 지정합니다.', '[0]', 'docker compose --{0} debug config --services', NULL, '[{"title": "Compose profiles", "url": "https://docs.docker.com/compose/how-tos/profiles/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 490, 12, 'Dockerfile 고쳐서 확인하는 순서', '빌드가 안 되는 Dockerfile 을 고쳐 결과까지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '고치기 → 빌드 → 실행 → 확인이에요.', NULL, NULL, '[]', 'order', '["오류 메시지를 읽고 Dockerfile 의 틀린 줄을 고친다", "`docker build -t 이름 .` 으로 다시 빌드한다", "`docker run --rm 이름` 으로 실행한다", "출력이 기대와 같은지 확인한다"]', NULL, '빌드 오류 메시지가 가리키는 줄을 고치고 다시 빌드한 뒤, 실행해서 출력이 의도와 맞는지 확인하는 것이 기본 반복입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Dockerfile 레퍼런스", "url": "https://docs.docker.com/reference/dockerfile/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 490 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 243 WHERE id = 97;
UPDATE quest_set SET display_order = 240, unit_id = (SELECT id FROM unit WHERE id = 10), icon = '🧾' WHERE id = 490;
