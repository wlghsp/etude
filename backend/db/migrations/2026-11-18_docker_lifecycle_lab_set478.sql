-- Git 실습 세트 478. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_docker_lifecycle_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 478, '도커 컨테이너 수명주기 실습: create·start, pause, stop -t, kill -s, wait, 종료 코드, exec -u, logs --tail, events', '컨테이너가 만들어지고 멈추고 끝나는 과정을 직접 다룹니다. create 와 start 의 상태, pause·unpause, stop 의 유예 시간(-t)과 종료 코드 137, kill -s 로 신호만 보내기, wait 로 종료 코드 받기, 127 종료 코드, exec 의 -u·-w·-e, logs 의 --tail·-t, events 필터를 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 478);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 1, '만들기만 하고 시작은 나중에 (create → start)', '**배경** — `docker run` 은 컨테이너를 **만들고 바로 시작**합니다. `docker create` 는 만들기만 해서 상태가 **`created`** 로 남고, `docker start` 로 따로 시작합니다. 상태는 `docker inspect -f ''{{.State.Status}}'' 이름` 으로 읽습니다.

**문제** — `alpine` 으로 이름이 **`lc`** 이고 `sleep 300` 을 실행하는 컨테이너를 **만들기만** 하세요. 그때의 상태를 **`/tmp/q1.txt`** 에 저장한 뒤, 컨테이너를 시작하세요. 끝나면 `lc` 는 실행 중이어야 합니다.', '`docker create --name lc alpine sleep 300` → 상태를 `/tmp/q1.txt` 에 저장 → `docker start lc`', 'docker create --name lc alpine sleep 300
docker inspect -f ''{{.State.Status}}'' lc > /tmp/q1.txt
docker start lc
cat /tmp/q1.txt
docker ps

# create 직후 상태는 created. start 하면 running 이 된다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( [ \\"$(cat /tmp/q1.txt)\\" = created ] ) && ( [ \\"$(docker inspect -f ''{{.State.Status}}'' lc)\\" = running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "시작 전 상태가 created 로 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q1.txt)\\" = created ]"]}, {"label": "lc 가 지금 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Status}}'' lc)\\" = running ]"]}]', '[{"title": "docker container create", "url": "https://docs.docker.com/reference/cli/docker/container/create/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 2, '잠시 멈췄다가 이어 가기 (pause · unpause)', '**배경** — `docker pause` 는 컨테이너의 모든 프로세스를 **얼려 두고**(종료하지 않음), `docker unpause` 로 이어 갑니다. 정지(`stop`)와 달리 프로세스 상태가 그대로 유지됩니다. 상태는 `paused` 로 보입니다.

**문제** — 이미 실행 중인 컨테이너 **`pz`** 를 일시정지하고 그때의 상태를 **`/tmp/q2.txt`** 에 저장하세요. 그다음 다시 이어서 실행 중(`running`) 상태로 되돌리세요.', '`docker pause pz` → 상태를 `/tmp/q2.txt` 에 저장 → `docker unpause pz`', 'docker pause pz
docker inspect -f ''{{.State.Status}}'' pz > /tmp/q2.txt
docker unpause pz
cat /tmp/q2.txt
docker ps

# pause 는 cgroup freezer 로 프로세스를 얼린다. unpause 하면 멈춘 자리에서 계속된다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name pz alpine sleep 300 >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/q2.txt)\\" = paused ] ) && ( [ \\"$(docker inspect -f ''{{.State.Status}}'' pz)\\" = running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "일시정지 때 상태가 paused 로 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q2.txt)\\" = paused ]"]}, {"label": "pz 가 다시 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Status}}'' pz)\\" = running ]"]}]', '[{"title": "docker container pause", "url": "https://docs.docker.com/reference/cli/docker/container/pause/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 3, '끝내 주지 않는 프로세스 정지시키기 (stop -t)', '**배경** — `docker stop` 은 먼저 `SIGTERM` 을 보내고, **유예 시간(기본 10초)** 안에 끝나지 않으면 `SIGKILL` 로 강제 종료합니다. `-t 초` 로 유예 시간을 줄일 수 있습니다. 강제 종료된 컨테이너의 종료 코드는 **`137`**(128 + 9)입니다. 컨테이너 **`stubborn`** 은 `SIGTERM` 을 무시하도록 만들어져 있습니다.

**문제** — `stubborn` 을 **유예 2초**로 정지시키고, 종료 코드를 **`/tmp/q3.txt`** 에 저장하세요. (`docker inspect -f ''{{.State.ExitCode}}'' …`)', '`docker stop -t 2 stubborn` → `docker inspect -f ''{{.State.ExitCode}}'' stubborn > /tmp/q3.txt`', 'docker stop -t 2 stubborn
docker inspect -f ''{{.State.ExitCode}}'' stubborn > /tmp/q3.txt
cat /tmp/q3.txt

# SIGTERM 을 무시하면 유예 시간 뒤 SIGKILL. 종료 코드 137 = 128 + 9(SIGKILL)', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name stubborn alpine sh -c ''trap \\"\\" TERM; while true; do sleep 1; done'' >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/q3.txt)\\" = 137 ] ) && ( [ \\"$(docker inspect -f ''{{.State.Status}}'' stubborn)\\" = exited ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "종료 코드가 137 로 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q3.txt)\\" = 137 ]"]}, {"label": "stubborn 이 종료됐다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Status}}'' stubborn)\\" = exited ]"]}]', '[{"title": "docker container stop", "url": "https://docs.docker.com/reference/cli/docker/container/stop/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 4, '정지하지 않고 신호만 보내기 (kill -s)', '**배경** — `docker kill` 은 이름과 달리 기본은 `SIGKILL` 이지만, **`-s 신호`** 로 원하는 신호를 보낼 수 있습니다. 설정 다시 읽기(`SIGHUP`)나 사용자 정의 신호(`SIGUSR1`)를 컨테이너 안 프로세스에 전달할 때 씁니다. 컨테이너 **`sigbox`** 는 `SIGUSR1` 을 받으면 로그에 `got-usr1` 을 남기고 **계속 실행**됩니다.

**문제** — `sigbox` 에 `SIGUSR1` 을 보내고, 잠시 뒤 로그에 `got-usr1` 이 있는지 확인하세요. 컨테이너는 계속 실행 중이어야 합니다.', '`docker kill -s USR1 sigbox` 후 1~2초 뒤 `docker logs sigbox`', 'docker kill -s USR1 sigbox
sleep 2
docker logs sigbox

# kill -s 는 프로세스를 죽이는 게 아니라 신호를 전달한다. 프로세스가 trap 으로 처리하면 계속 돈다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name sigbox alpine sh -c ''trap \\"echo got-usr1\\" USR1; while true; do sleep 1; done'' >/dev/null"]', '["sh", "-c", "( docker logs sigbox 2>&1 | grep -q got-usr1 ) && ( [ \\"$(docker inspect -f ''{{.State.Status}}'' sigbox)\\" = running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "로그에 got-usr1 이 남았다", "cmd": ["sh", "-c", "docker logs sigbox 2>&1 | grep -q got-usr1"]}, {"label": "sigbox 가 계속 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Status}}'' sigbox)\\" = running ]"]}]', '[{"title": "docker container kill", "url": "https://docs.docker.com/reference/cli/docker/container/kill/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 5, '끝날 때까지 기다리고 종료 코드 받기 (wait)', '**배경** — `docker wait 이름` 은 컨테이너가 **끝날 때까지 기다린 뒤 종료 코드를 출력**합니다. 배치 작업이 성공했는지 스크립트에서 확인할 때 씁니다. 컨테이너 **`job`** 은 3초 뒤 종료 코드 `7` 로 끝납니다.

**문제** — `job` 이 끝나기를 기다려 출력되는 종료 코드를 **`/tmp/q5.txt`** 에 저장하세요.', '`docker wait job > /tmp/q5.txt`', 'docker wait job > /tmp/q5.txt
cat /tmp/q5.txt

# wait 는 종료까지 막혔다가 종료 코드(여기서는 7)를 표준출력으로 내보낸다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name job alpine sh -c ''sleep 3; exit 7'' >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/q5.txt)\\" = 7 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "종료 코드 7 이 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q5.txt)\\" = 7 ]"]}]', '[{"title": "docker container wait", "url": "https://docs.docker.com/reference/cli/docker/container/wait/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 6, '없는 명령을 실행하면 종료 코드는? (127)', '**배경** — `docker run` 의 종료 코드는 규칙이 있습니다. **125** 는 도커 자체 오류, **126** 은 명령을 실행할 수 없음(권한 등), **127** 은 명령을 찾을 수 없음, 그 밖에는 컨테이너 안 프로세스의 종료 코드입니다.

**문제** — 이름을 **`nf`** 로 해서 존재하지 않는 명령 `nosuchcmd` 를 `alpine` 에서 실행하고, `docker run` 이 돌려준 종료 코드(`$?`)를 **`/tmp/q6.txt`** 에 저장하세요.', '`docker run --name nf alpine nosuchcmd` 직후 `echo $? > /tmp/q6.txt`', 'docker run --name nf alpine nosuchcmd
echo $? > /tmp/q6.txt
cat /tmp/q6.txt

# 127 = command not found. 126 은 실행 권한 없음, 125 는 도커 데몬/옵션 오류', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( [ \\"$(cat /tmp/q6.txt)\\" = 127 ] ) && ( docker inspect nf >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "종료 코드 127 이 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q6.txt)\\" = 127 ]"]}, {"label": "nf 컨테이너가 만들어졌었다", "cmd": ["sh", "-c", "docker inspect nf >/dev/null 2>&1"]}]', '[{"title": "docker container run — exit status", "url": "https://docs.docker.com/reference/cli/docker/container/run/#exit-status"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 7, '다른 사용자로 컨테이너 안에서 실행하기 (exec -u -w -e)', '**배경** — `docker exec` 는 실행 중인 컨테이너 안에서 명령을 하나 더 실행합니다. **`-u 사용자`**, **`-w 작업폴더`**, **`-e 이름=값`** 으로 실행 사용자·폴더·환경 변수를 이번 명령에만 바꿀 수 있습니다. 컨테이너 **`ex`** 가 실행 중입니다.

**문제** — `ex` 안에서 사용자 `nobody`, 작업 폴더 `/tmp`, 환경 변수 `GREETING=hi` 로 `echo $GREETING $(id -un) $(pwd)` 를 실행하고 출력(한 줄)을 **`/tmp/q7.txt`** 에 저장하세요. (`hi nobody /tmp` 가 되어야 합니다. 변수는 컨테이너 안 쉘이 풀도록 `sh -c` 를 쓰세요.)', '`docker exec -u nobody -w /tmp -e GREETING=hi ex sh -c ''echo $GREETING $(id -un) $(pwd)'' > /tmp/q7.txt`', 'docker exec -u nobody -w /tmp -e GREETING=hi ex sh -c ''echo $GREETING $(id -un) $(pwd)'' > /tmp/q7.txt
cat /tmp/q7.txt

# 작은따옴표로 감싸야 호스트 쉘이 아니라 컨테이너 안 쉘이 변수를 푼다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name ex alpine sleep 300 >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/q7.txt)\\" = \\"hi nobody /tmp\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 hi nobody /tmp 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q7.txt)\\" = \\"hi nobody /tmp\\" ]"]}]', '[{"title": "docker container exec", "url": "https://docs.docker.com/reference/cli/docker/container/exec/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 8, '로그의 끝부분만 시간표와 함께 보기 (logs --tail -t)', '**배경** — 로그가 길면 `docker logs --tail N 이름` 으로 **마지막 N줄**만, `-t` 로 **줄마다 시각**을 붙여 볼 수 있습니다. `--since 10m` 은 최근 10분만 보여 줍니다. 컨테이너 **`talk`** 는 `line1` 부터 `line6` 까지 출력한 뒤 계속 실행 중입니다.

**문제** — `talk` 의 로그에서 **마지막 2줄**을 **시각과 함께** **`/tmp/q8.txt`** 에 저장하세요. (`line5`, `line6` 두 줄이 시각이 앞에 붙어 저장됩니다.)', '`docker logs -t --tail 2 talk > /tmp/q8.txt`', 'docker logs -t --tail 2 talk > /tmp/q8.txt
cat /tmp/q8.txt

# -t 는 RFC3339 시각을 줄 앞에 붙인다. --tail 은 끝에서 N줄만 가져온다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name talk alpine sh -c ''for i in 1 2 3 4 5 6; do echo line$i; done; sleep 300'' >/dev/null; sleep 1"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/q8.txt)\\" -eq 2 ] ) && ( [ \\"$(grep -c \\"^20\\" /tmp/q8.txt)\\" -eq 2 ] ) && ( sed -n 1p /tmp/q8.txt | grep -q \\"line5$\\" && sed -n 2p /tmp/q8.txt | grep -q \\"line6$\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "2줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/q8.txt)\\" -eq 2 ]"]}, {"label": "각 줄이 시각으로 시작한다", "cmd": ["sh", "-c", "[ \\"$(grep -c \\"^20\\" /tmp/q8.txt)\\" -eq 2 ]"]}, {"label": "line5 와 line6 이다", "cmd": ["sh", "-c", "sed -n 1p /tmp/q8.txt | grep -q \\"line5$\\" && sed -n 2p /tmp/q8.txt | grep -q \\"line6$\\""]}]', '[{"title": "docker container logs", "url": "https://docs.docker.com/reference/cli/docker/container/logs/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 9, '컨테이너가 끝난 사건 찾기 (events)', '**배경** — `docker events` 는 도커 데몬에서 일어난 **사건**(생성·시작·종료 등)을 보여 줍니다. `--since` 와 `--until` 로 기간을, `--filter container=이름` · `--filter event=die` 로 대상을 좁힙니다. `--until` 을 주지 않으면 계속 기다리므로 스크립트에서는 꼭 끝 시각을 줍니다.

**문제** — 컨테이너 **`evt`** 를 `alpine` 의 `true` 명령으로 실행해 끝낸 뒤, `evt` 의 **`die` 사건만** **`/tmp/q9.txt`** 에 저장하세요. (`--since 2m`, `--until` 은 지금보다 1초 뒤의 유닉스 시각 `$(( $(date +%s) + 1 ))`.)', '`docker events --since 2m --until "$(( $(date +%s) + 1 ))" --filter container=evt --filter event=die > /tmp/q9.txt`', 'docker run --name evt alpine true
docker events --since 2m --until "$(( $(date +%s) + 1 ))" --filter container=evt --filter event=die > /tmp/q9.txt
cat /tmp/q9.txt

# events 는 --until 이 없으면 끝나지 않는다. 필터로 대상 컨테이너와 사건 종류를 좁힌다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( grep -q \\" die \\" /tmp/q9.txt || grep -q \\"container die\\" /tmp/q9.txt ) && ( grep -q \\"name=evt\\" /tmp/q9.txt ) && ( [ \\"$(wc -l < /tmp/q9.txt)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "die 사건이 저장됐다", "cmd": ["sh", "-c", "grep -q \\" die \\" /tmp/q9.txt || grep -q \\"container die\\" /tmp/q9.txt"]}, {"label": "evt 컨테이너의 사건이다", "cmd": ["sh", "-c", "grep -q \\"name=evt\\" /tmp/q9.txt"]}, {"label": "die 만 있다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/q9.txt)\\" -eq 1 ]"]}]', '[{"title": "docker events", "url": "https://docs.docker.com/reference/cli/docker/system/events/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 10, 'docker stop 의 기본 동작', '`docker stop 컨테이너` 가 기본으로 하는 동작은 무엇일까요?', '먼저 부드럽게, 안 되면 강제로예요.', NULL, NULL, '[]', 'choice', '["곧바로 SIGKILL 을 보내 컨테이너를 강제로 끝낸다", "SIGTERM 을 보내고 10초 안에 안 끝나면 SIGKILL 을 보낸다", "SIGKILL 을 먼저 보내고 10초 뒤에 SIGTERM 을 보낸다", "SIGSTOP 으로 프로세스를 얼려 두고 아무것도 끝내지 않는다"]', 1, '도커 문서는 docker stop 이 컨테이너의 메인 프로세스에 먼저 SIGTERM(또는 지정한 정지 신호)을 보내고, 유예 시간(기본 10초) 안에 끝나지 않으면 SIGKILL 을 보낸다고 설명합니다. 유예 시간은 -t 로 바꿉니다.', NULL, NULL, NULL, '[{"title": "docker container stop", "url": "https://docs.docker.com/reference/cli/docker/container/stop/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 11, '컨테이너에 신호 보내기', '컨테이너를 끝내지 않고 **`SIGUSR1`** 같은 원하는 신호만 보내는 명령입니다. 빈칸을 채우세요.', '"죽이다" 라는 이름이지만 -s 로 신호를 고를 수 있어요.', NULL, NULL, '[]', 'fill', '["kill", "stop", "pause", "restart"]', NULL, '도커 문서는 docker kill 이 컨테이너의 메인 프로세스에 신호를 보내며 기본은 SIGKILL 이고 -s 로 다른 신호를 지정할 수 있다고 설명합니다. stop 은 정지 신호와 유예 시간을 쓰는 다른 명령입니다.', '[0]', 'docker {0} -s USR1 sigbox', NULL, '[{"title": "docker container kill", "url": "https://docs.docker.com/reference/cli/docker/container/kill/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 478, 12, 'docker stop 이 컨테이너를 끝내는 순서', 'SIGTERM 을 무시하는 컨테이너를 `docker stop` 으로 정지할 때의 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '요청 → 대기 → 강제 → 코드예요.', NULL, NULL, '[]', 'order', '["`docker stop` 이 메인 프로세스(PID 1)에 SIGTERM 을 보낸다", "유예 시간(기본 10초, `-t` 로 변경) 동안 종료를 기다린다", "끝나지 않으면 SIGKILL 로 강제 종료한다", "종료 코드를 확인하면 137(128 + 9)로 보인다"]', NULL, '도커 stop 문서의 동작과 종료 코드 규칙(128 + 신호 번호)을 이은 절차입니다. 프로세스가 SIGTERM 을 처리하면 유예 시간 안에 정상 종료 코드로 끝납니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "docker container stop", "url": "https://docs.docker.com/reference/cli/docker/container/stop/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 478 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 202 WHERE id = 11;
UPDATE quest_set SET display_order = 203 WHERE id = 167;
UPDATE quest_set SET display_order = 204 WHERE id = 243;
UPDATE quest_set SET display_order = 205 WHERE id = 218;
UPDATE quest_set SET display_order = 206 WHERE id = 257;
UPDATE quest_set SET display_order = 207 WHERE id = 183;
UPDATE quest_set SET display_order = 208 WHERE id = 247;
UPDATE quest_set SET display_order = 209 WHERE id = 221;
UPDATE quest_set SET display_order = 210 WHERE id = 258;
UPDATE quest_set SET display_order = 211 WHERE id = 154;
UPDATE quest_set SET display_order = 212 WHERE id = 241;
UPDATE quest_set SET display_order = 213 WHERE id = 187;
UPDATE quest_set SET display_order = 214 WHERE id = 248;
UPDATE quest_set SET display_order = 215 WHERE id = 8;
UPDATE quest_set SET display_order = 216 WHERE id = 234;
UPDATE quest_set SET display_order = 217 WHERE id = 337;
UPDATE quest_set SET display_order = 218 WHERE id = 346;
UPDATE quest_set SET display_order = 219 WHERE id = 142;
UPDATE quest_set SET display_order = 220 WHERE id = 239;
UPDATE quest_set SET display_order = 221 WHERE id = 179;
UPDATE quest_set SET display_order = 222 WHERE id = 246;
UPDATE quest_set SET display_order = 223 WHERE id = 209;
UPDATE quest_set SET display_order = 224 WHERE id = 254;
UPDATE quest_set SET display_order = 225 WHERE id = 228;
UPDATE quest_set SET display_order = 226 WHERE id = 352;
UPDATE quest_set SET display_order = 227 WHERE id = 148;
UPDATE quest_set SET display_order = 228 WHERE id = 240;
UPDATE quest_set SET display_order = 229 WHERE id = 175;
UPDATE quest_set SET display_order = 230 WHERE id = 245;
UPDATE quest_set SET display_order = 231 WHERE id = 206;
UPDATE quest_set SET display_order = 232 WHERE id = 253;
UPDATE quest_set SET display_order = 233 WHERE id = 237;
UPDATE quest_set SET display_order = 234 WHERE id = 38;
UPDATE quest_set SET display_order = 235 WHERE id = 39;
UPDATE quest_set SET display_order = 236 WHERE id = 97;
UPDATE quest_set SET display_order = 201, unit_id = (SELECT id FROM unit WHERE id = 66), icon = '⏯️' WHERE id = 478;
