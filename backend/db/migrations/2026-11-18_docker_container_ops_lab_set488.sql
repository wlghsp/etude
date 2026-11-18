-- Git 실습 세트 488. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_docker_container_ops_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 488, '도커 컨테이너 다루기 손연습: exec -u·-w·-e, rename, --volumes-from, --add-host, --cidfile, --init, --ulimit, --shm-size, --network container:', '컨테이너를 만들고 다루는 옵션을 직접 써 봅니다. exec 에서 사용자·위치·환경 변수 바꾸기, rename, --volumes-from 으로 볼륨 이어 받기, --add-host 로 hosts 추가, --cidfile 로 ID 남기기, --init, --ulimit, --shm-size, --network container: 로 네트워크 공유를 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 488);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 1, '실행 중인 컨테이너에서 사용자·위치·변수 바꿔 명령 실행 (exec -u -w -e)', '**배경** — `docker exec` 는 **이미 실행 중인** 컨테이너 안에서 명령을 하나 더 실행합니다. `-u 사용자` 로 실행 사용자를, `-w 경로` 로 작업 디렉터리를, `-e 이름=값` 으로 그 명령에만 쓰는 환경 변수를 정합니다. 컨테이너 **`ex`** 가 실행 중입니다.

**문제** — `ex` 안에서 사용자 **`nobody`**, 작업 디렉터리 **`/tmp`**, 환경 변수 **`GREET=hi`** 로 `echo $GREET $(pwd) $(id -un)` 을 실행해 그 출력(`hi /tmp nobody`)을 **`/tmp/q1.txt`** 에 저장하세요. (`$` 가 호스트 쉘에서 풀리지 않도록 `sh -c` 와 작은따옴표를 쓰세요.)', '`docker exec -u nobody -w /tmp -e GREET=hi ex sh -c ''echo $GREET $(pwd) $(id -un)'' > /tmp/q1.txt`', 'docker exec -u nobody -w /tmp -e GREET=hi ex sh -c ''echo $GREET $(pwd) $(id -un)'' > /tmp/q1.txt
cat /tmp/q1.txt

# 작은따옴표로 감싸야 컨테이너 안의 쉘이 변수와 명령을 푼다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name ex alpine sleep 300 >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/q1.txt)\\" = \\"hi /tmp nobody\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 hi /tmp nobody 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q1.txt)\\" = \\"hi /tmp nobody\\" ]"]}]', '[{"title": "docker container exec", "url": "https://docs.docker.com/reference/cli/docker/container/exec/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 2, '컨테이너 이름 바꾸기 (rename)', '**배경** — `docker rename 옛이름 새이름` 은 컨테이너를 **다시 만들지 않고 이름만** 바꿉니다. 실행 중에도 되고 프로세스는 그대로입니다. 이름을 잘못 지었거나 역할이 바뀌었을 때 씁니다. 컨테이너 **`oldname`** 이 실행 중입니다.

**문제** — `oldname` 의 이름을 **`newname`** 으로 바꾸세요.', '`docker rename oldname newname`', 'docker rename oldname newname
docker ps

# 이름만 바뀐다. 같은 컨테이너 ID, 계속 running', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name oldname alpine sleep 300 >/dev/null"]', '["sh", "-c", "( [ \\"$(docker inspect -f ''{{.State.Status}}'' newname 2>/dev/null)\\" = running ] ) && ( ! docker inspect oldname >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "newname 이 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Status}}'' newname 2>/dev/null)\\" = running ]"]}, {"label": "oldname 은 더 이상 없다", "cmd": ["sh", "-c", "! docker inspect oldname >/dev/null 2>&1"]}]', '[{"title": "docker container rename", "url": "https://docs.docker.com/reference/cli/docker/container/rename/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 3, '다른 컨테이너의 볼륨을 이어 받기 (--volumes-from)', '**배경** — `--volumes-from 컨테이너` 는 그 컨테이너가 가진 **볼륨 마운트를 그대로** 새 컨테이너에 붙입니다. 볼륨 이름이나 경로를 다시 적지 않고 데이터를 공유하거나 백업할 때 씁니다. 컨테이너 **`data`** 의 `/data` 볼륨에 `f.txt`(`seed-123`)가 있습니다.

**문제** — 새 컨테이너가 **`data` 의 볼륨을 이어 받아** `/data/f.txt` 를 읽게 해서 그 내용을 **`/tmp/q3.txt`** 에 저장하세요. (`--rm` 으로 임시 실행하세요.)', '`docker run --rm --volumes-from data alpine cat /data/f.txt > /tmp/q3.txt`', 'docker run --rm --volumes-from data alpine cat /data/f.txt > /tmp/q3.txt
cat /tmp/q3.txt

# data 의 마운트 지점(/data)이 그대로 보인다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name data -v /data alpine sh -c ''echo seed-123 > /data/f.txt; sleep 300'' >/dev/null; sleep 1"]', '["sh", "-c", "( [ \\"$(cat /tmp/q3.txt)\\" = seed-123 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "seed-123 이 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q3.txt)\\" = seed-123 ]"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 4, '컨테이너 hosts 에 이름 추가하기 (--add-host)', '**배경** — `--add-host 이름:IP` 는 컨테이너의 **`/etc/hosts`** 에 항목을 넣어, DNS 없이 그 이름을 IP 로 풀게 합니다. 테스트용 가짜 호스트를 만들 때 씁니다.

**문제** — `alpine` 임시 컨테이너(`--rm`)에 **`db.local` → `10.1.2.3`** 을 추가해 `/etc/hosts` 내용을 **`/tmp/q4.txt`** 에 저장하세요.', '`docker run --rm --add-host db.local:10.1.2.3 alpine cat /etc/hosts > /tmp/q4.txt`', 'docker run --rm --add-host db.local:10.1.2.3 alpine cat /etc/hosts > /tmp/q4.txt
cat /tmp/q4.txt

# /etc/hosts 에 ''10.1.2.3 db.local'' 줄이 생긴다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( grep -Eq \\"^10\\\\.1\\\\.2\\\\.3[[:space:]]+db\\\\.local\\" /tmp/q4.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "hosts 에 db.local 항목이 있다", "cmd": ["sh", "-c", "grep -Eq \\"^10\\\\.1\\\\.2\\\\.3[[:space:]]+db\\\\.local\\" /tmp/q4.txt"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 5, '컨테이너 ID 를 파일에 남기기 (--cidfile)', '**배경** — `--cidfile 파일` 은 컨테이너를 시작할 때 **전체 컨테이너 ID 를 그 파일에** 씁니다. 스크립트가 이름 없이 컨테이너를 추적하거나 나중에 정리할 때 씁니다. (파일이 이미 있으면 오류가 납니다.)

**문제** — 이름 **`cidc`**, `alpine sleep 300` 컨테이너를 백그라운드로 실행하되 ID 를 **`/tmp/work/cid`** 파일에 남기세요.', '`docker run -d --name cidc --cidfile /tmp/work/cid alpine sleep 300`', 'docker run -d --name cidc --cidfile /tmp/work/cid alpine sleep 300
cat /tmp/work/cid

# 파일에는 64자 전체 ID 가 들어 있다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( [ -s /tmp/work/cid ] && [ \\"$(cat /tmp/work/cid)\\" = \\"$(docker inspect -f ''{{.Id}}'' cidc 2>/dev/null)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "cid 파일 값이 cidc 의 ID 와 같다", "cmd": ["sh", "-c", "[ -s /tmp/work/cid ] && [ \\"$(cat /tmp/work/cid)\\" = \\"$(docker inspect -f ''{{.Id}}'' cidc 2>/dev/null)\\" ]"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 6, '좀비 정리와 신호 전달을 맡기기 (--init)', '**배경** — 컨테이너의 첫 프로세스(PID 1)는 신호를 특별하게 다루고 끝난 자식 프로세스(좀비)를 거두지 않을 수 있습니다. **`--init`** 은 아주 작은 init 프로세스를 PID 1 로 두어 **신호를 전달하고 좀비를 정리**하게 합니다.

**문제** — 이름 **`ini`**, `alpine sleep 300` 컨테이너를 `--init` 으로 백그라운드 실행하세요.', '`docker run -d --init --name ini alpine sleep 300`', 'docker run -d --init --name ini alpine sleep 300
docker inspect -f ''{{.HostConfig.Init}}'' ini

# HostConfig.Init 이 true 다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( [ \\"$(docker inspect -f ''{{.HostConfig.Init}}'' ini 2>/dev/null)\\" = true ] ) && ( [ \\"$(docker inspect -f ''{{.State.Status}}'' ini 2>/dev/null)\\" = running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Init 이 true 다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.HostConfig.Init}}'' ini 2>/dev/null)\\" = true ]"]}, {"label": "ini 가 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Status}}'' ini 2>/dev/null)\\" = running ]"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 7, '열 수 있는 파일 수 제한하기 (--ulimit)', '**배경** — `--ulimit 종류=소프트:하드` 는 컨테이너 프로세스의 **자원 한도**(열 수 있는 파일 수 `nofile`, 프로세스 수 `nproc` 등)를 정합니다. 쉘에서는 `ulimit -n` 으로 현재 값을 읽습니다.

**문제** — `alpine` 임시 컨테이너(`--rm`)를 열 수 있는 파일 수 **`1024:1024`** 로 제한해 실행하고, 그 안에서 `ulimit -n` 이 출력한 값을 **`/tmp/q7.txt`** 에 저장하세요.', '`docker run --rm --ulimit nofile=1024:1024 alpine sh -c ''ulimit -n'' > /tmp/q7.txt`', 'docker run --rm --ulimit nofile=1024:1024 alpine sh -c ''ulimit -n'' > /tmp/q7.txt
cat /tmp/q7.txt

# 1024 가 출력된다. 기본값은 환경마다 훨씬 크다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( [ \\"$(cat /tmp/q7.txt)\\" = 1024 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 1024 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q7.txt)\\" = 1024 ]"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 8, '공유 메모리 크기 키우기 (--shm-size)', '**배경** — 컨테이너의 `/dev/shm`(공유 메모리) 기본 크기는 **64MB** 입니다. 브라우저·DB 처럼 공유 메모리를 많이 쓰는 프로그램이 부족하다고 죽을 때는 **`--shm-size`** 로 키웁니다. 크기는 `df -h /dev/shm` 으로 읽습니다.

**문제** — `alpine` 임시 컨테이너(`--rm`)의 공유 메모리를 **`128m`** 으로 키우고 `df -h /dev/shm` 출력을 **`/tmp/q8.txt`** 에 저장하세요.', '`docker run --rm --shm-size=128m alpine df -h /dev/shm > /tmp/q8.txt`', 'docker run --rm --shm-size=128m alpine df -h /dev/shm > /tmp/q8.txt
cat /tmp/q8.txt

# Size 칸이 128.0M 으로 나온다 (기본은 64.0M)', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; "]', '["sh", "-c", "( grep -q \\"128.0M\\" /tmp/q8.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "크기가 128.0M 이다", "cmd": ["sh", "-c", "grep -q \\"128.0M\\" /tmp/q8.txt"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 9, '다른 컨테이너와 네트워크를 통째로 공유하기 (--network container:)', '**배경** — `--network container:이름` 은 새 컨테이너가 **그 컨테이너의 네트워크 공간(IP·포트·localhost)을 함께** 쓰게 합니다. 그래서 새 컨테이너의 `localhost` 가 상대 컨테이너입니다. 사이드카·디버깅 컨테이너를 붙일 때 씁니다. 컨테이너 **`web`** 은 8080 포트에서 `ok` 를 응답합니다.

**문제** — `web` 과 네트워크를 공유하는 임시 `alpine` 컨테이너(`--rm`)에서 `wget -qO- http://localhost:8080/index.html` 을 실행해 그 응답을 **`/tmp/q9.txt`** 에 저장하세요.', '`docker run --rm --network container:web alpine wget -qO- http://localhost:8080/index.html > /tmp/q9.txt`', 'docker run --rm --network container:web alpine wget -qO- http://localhost:8080/index.html > /tmp/q9.txt
cat /tmp/q9.txt

# 네트워크를 공유하므로 새 컨테이너에서 localhost 로 web 에 닿는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name web alpine sh -c ''while true; do printf \\"HTTP/1.0 200 OK\\\\r\\\\n\\\\r\\\\nok\\\\n\\" | nc -l -p 8080; done'' >/dev/null; sleep 2"]', '["sh", "-c", "( [ \\"$(cat /tmp/q9.txt)\\" = ok ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "응답 ok 가 저장됐다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q9.txt)\\" = ok ]"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 10, '--volumes-from 이 하는 일', '`docker run --volumes-from data ...` 로 새 컨테이너를 만들면 무엇이 일어날까요?', '볼륨 정의를 다시 쓰지 않아도 돼요.', NULL, NULL, '[]', 'choice', '["`data` 컨테이너의 파일시스템 전체가 복사된다", "`data` 컨테이너의 볼륨 마운트가 새 컨테이너에도 붙는다", "`data` 컨테이너의 네트워크를 함께 쓴다", "`data` 컨테이너가 새 컨테이너 안으로 합쳐진다"]', 1, '--volumes-from 은 지정한 컨테이너에 마운트된 볼륨을 같은 경로로 새 컨테이너에 붙입니다. 파일시스템 전체를 복사하지도, 네트워크를 공유하지도 않습니다(네트워크 공유는 --network container:).', NULL, NULL, NULL, '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 11, '컨테이너와 네트워크 공유', '새 컨테이너가 `web` 컨테이너의 네트워크 공간을 함께 쓰게 하는 옵션입니다. 빈칸을 채우세요.', '"컨테이너" 의 영어예요.', NULL, NULL, '[]', 'fill', '["container", "host", "bridge", "none"]', NULL, '--network container:이름 은 그 컨테이너의 네트워크 네임스페이스를 공유합니다. host 는 호스트 네트워크, bridge 는 기본 브리지, none 은 네트워크 없음입니다.', '[0]', 'docker run --rm --network {0}:web alpine wget -qO- http://localhost:8080', NULL, '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 488, 12, '컨테이너를 만들어 쓰고 치우는 순서', '컨테이너를 따로 만들고, 시작해 쓰고, 정리하는 일반적인 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 시작 → 안에서 실행 → 정지 → 삭제예요.', NULL, NULL, '[]', 'order', '["`docker create` 로 컨테이너를 만든다", "`docker start` 로 시작한다", "`docker exec` 로 안에서 명령을 실행한다", "`docker stop` 으로 정지하고 `docker rm` 으로 삭제한다"]', NULL, 'create 는 만들기만 하고, start 로 시작합니다. 실행 중인 컨테이너에 exec 로 명령을 더 실행할 수 있고, 끝나면 stop 으로 정지한 뒤 rm 으로 지웁니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 488 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 192 WHERE id = 212;
UPDATE quest_set SET display_order = 193 WHERE id = 255;
UPDATE quest_set SET display_order = 194 WHERE id = 215;
UPDATE quest_set SET display_order = 195 WHERE id = 256;
UPDATE quest_set SET display_order = 196 WHERE id = 160;
UPDATE quest_set SET display_order = 197 WHERE id = 242;
UPDATE quest_set SET display_order = 198 WHERE id = 225;
UPDATE quest_set SET display_order = 199 WHERE id = 231;
UPDATE quest_set SET display_order = 200 WHERE id = 340;
UPDATE quest_set SET display_order = 201 WHERE id = 343;
UPDATE quest_set SET display_order = 202 WHERE id = 349;
UPDATE quest_set SET display_order = 203 WHERE id = 478;
UPDATE quest_set SET display_order = 204 WHERE id = 11;
UPDATE quest_set SET display_order = 205 WHERE id = 167;
UPDATE quest_set SET display_order = 206 WHERE id = 243;
UPDATE quest_set SET display_order = 207 WHERE id = 218;
UPDATE quest_set SET display_order = 208 WHERE id = 257;
UPDATE quest_set SET display_order = 209 WHERE id = 183;
UPDATE quest_set SET display_order = 210 WHERE id = 247;
UPDATE quest_set SET display_order = 211 WHERE id = 221;
UPDATE quest_set SET display_order = 212 WHERE id = 258;
UPDATE quest_set SET display_order = 213 WHERE id = 485;
UPDATE quest_set SET display_order = 215 WHERE id = 154;
UPDATE quest_set SET display_order = 216 WHERE id = 241;
UPDATE quest_set SET display_order = 217 WHERE id = 187;
UPDATE quest_set SET display_order = 218 WHERE id = 248;
UPDATE quest_set SET display_order = 219 WHERE id = 8;
UPDATE quest_set SET display_order = 220 WHERE id = 234;
UPDATE quest_set SET display_order = 221 WHERE id = 337;
UPDATE quest_set SET display_order = 222 WHERE id = 346;
UPDATE quest_set SET display_order = 223 WHERE id = 142;
UPDATE quest_set SET display_order = 224 WHERE id = 239;
UPDATE quest_set SET display_order = 225 WHERE id = 179;
UPDATE quest_set SET display_order = 226 WHERE id = 246;
UPDATE quest_set SET display_order = 227 WHERE id = 209;
UPDATE quest_set SET display_order = 228 WHERE id = 254;
UPDATE quest_set SET display_order = 229 WHERE id = 228;
UPDATE quest_set SET display_order = 230 WHERE id = 352;
UPDATE quest_set SET display_order = 231 WHERE id = 148;
UPDATE quest_set SET display_order = 232 WHERE id = 240;
UPDATE quest_set SET display_order = 233 WHERE id = 175;
UPDATE quest_set SET display_order = 234 WHERE id = 245;
UPDATE quest_set SET display_order = 235 WHERE id = 206;
UPDATE quest_set SET display_order = 236 WHERE id = 253;
UPDATE quest_set SET display_order = 237 WHERE id = 237;
UPDATE quest_set SET display_order = 238 WHERE id = 38;
UPDATE quest_set SET display_order = 239 WHERE id = 39;
UPDATE quest_set SET display_order = 240 WHERE id = 97;
UPDATE quest_set SET display_order = 190, unit_id = (SELECT id FROM unit WHERE id = 32), icon = '🔧' WHERE id = 488;
