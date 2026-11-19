-- Git 실습 세트 498. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_docker_net_log_opts_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 498, '도커 네트워크·로그·종료·보안 옵션 손연습: --network-alias, --ip, --dns, --log-opt, --stop-signal, --mount readonly, --sysctl, ps --no-trunc, no-new-privileges', '컨테이너 별명, 고정 IP, DNS 서버 지정, 로그 크기 제한, 종료 신호와 대기 시간, --mount 읽기 전용 볼륨, --sysctl, 전체 컨테이너 ID, no-new-privileges 와 capability 최소화를 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 498);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 1, '같은 네트워크에서 별명으로 부르기 (--network-alias)', '**배경** — 사용자 정의 네트워크에서는 컨테이너 **이름**으로 서로를 찾습니다. **`--network-alias`** 를 더하면 **같은 컨테이너에 다른 이름(별명)**을 줄 수 있어, 앱 설정에는 `db` 같은 고정 이름을 쓰고 실제 컨테이너 이름은 자유롭게 둘 수 있습니다. 네트워크 `net1` 과 그 안에서 실행 중인 컨테이너 `c2` 가 있습니다.

**문제** — `net1` 에 컨테이너 **`c1`**(`alpine`, `sleep 3600`, 백그라운드)을 **별명 `db`** 로 연결해 실행하세요. (`c2` 에서 `db` 로 `ping` 이 되어야 합니다.)', '`docker run -d --name c1 --network net1 --network-alias db alpine sleep 3600`', 'docker run -d --name c1 --network net1 --network-alias db alpine sleep 3600
docker exec c2 ping -c1 -W2 db

# c1 에게 이름이 둘(c1, db)이다. 별명은 사용자 정의 네트워크에서만 풀린다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker network create net1 >/dev/null; docker run -d --name c2 --network net1 alpine sleep 3600 >/dev/null"]', '["sh", "-c", "( docker exec c2 ping -c1 -W2 db >/dev/null 2>&1 ) && ( docker inspect -f ''{{json .NetworkSettings.Networks.net1.Aliases}}'' c1 2>/dev/null | grep -q ''\\"db\\"'' )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "c2 에서 db 가 풀린다", "cmd": ["sh", "-c", "docker exec c2 ping -c1 -W2 db >/dev/null 2>&1"]}, {"label": "c1 의 별명에 db 가 있다", "cmd": ["sh", "-c", "docker inspect -f ''{{json .NetworkSettings.Networks.net1.Aliases}}'' c1 2>/dev/null | grep -q ''\\"db\\"''"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}, {"title": "컨테이너 네트워킹", "url": "https://docs.docker.com/engine/network/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 2, '컨테이너에 고정 IP 주기 (--subnet, --ip)', '**배경** — 컨테이너 IP 는 기본으로 시작할 때마다 바뀔 수 있습니다. **직접 만든 네트워크**에 **`--subnet`** 으로 대역을 정하면 그 안에서 **`--ip`** 로 컨테이너의 IP 를 고정할 수 있습니다(기본 `bridge` 네트워크에서는 `--ip` 를 쓸 수 없습니다).

**문제** — 대역 **`172.30.0.0/24`** 의 네트워크 **`net2`** 를 만들고, 컨테이너 **`fixed`**(`alpine`, `sleep 3600`, 백그라운드)를 그 네트워크의 **`172.30.0.10`** 으로 실행하세요.', '`docker network create --subnet 172.30.0.0/24 net2` → `docker run -d --name fixed --network net2 --ip 172.30.0.10 alpine sleep 3600`', 'docker network create --subnet 172.30.0.0/24 net2
docker run -d --name fixed --network net2 --ip 172.30.0.10 alpine sleep 3600
docker inspect -f ''{{.NetworkSettings.Networks.net2.IPAddress}}'' fixed

# --ip 는 --subnet 을 직접 준 네트워크에서만 쓸 수 있다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; true"]', '["sh", "-c", "( [ \\"$(docker inspect -f ''{{.NetworkSettings.Networks.net2.IPAddress}}'' fixed 2>/dev/null)\\" = 172.30.0.10 ] ) && ( [ \\"$(docker inspect -f ''{{.State.Running}}'' fixed 2>/dev/null)\\" = true ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "IP 가 172.30.0.10 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.NetworkSettings.Networks.net2.IPAddress}}'' fixed 2>/dev/null)\\" = 172.30.0.10 ]"]}, {"label": "실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.State.Running}}'' fixed 2>/dev/null)\\" = true ]"]}]', '[{"title": "docker network create", "url": "https://docs.docker.com/reference/cli/docker/network/create/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 3, '컨테이너가 쓸 DNS 서버 정하기 (--dns)', '**배경** — 컨테이너의 `/etc/resolv.conf` 는 기본으로 호스트 설정을 따릅니다. **`--dns 서버IP`** 로 **그 컨테이너만** 다른 DNS 서버를 쓰게 할 수 있습니다. 사내 DNS 에서만 풀리는 이름을 쓰거나 DNS 를 바꿔 문제를 가려낼 때 씁니다.

**문제** — 컨테이너 **`d1`**(`alpine`, `sleep 3600`, 백그라운드)을 **DNS 서버 `1.1.1.1`** 로 실행하세요. (`/etc/resolv.conf` 에 `nameserver 1.1.1.1` 이 있어야 합니다.)', '`docker run -d --name d1 --dns 1.1.1.1 alpine sleep 3600`', 'docker run -d --name d1 --dns 1.1.1.1 alpine sleep 3600
docker exec d1 cat /etc/resolv.conf

# nameserver 1.1.1.1 이 보인다. 데몬 전체에 적용하려면 daemon.json 의 dns 를 쓴다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; true"]', '["sh", "-c", "( docker exec d1 cat /etc/resolv.conf 2>/dev/null | grep -q \\"nameserver 1.1.1.1\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "resolv.conf 에 1.1.1.1 이 있다", "cmd": ["sh", "-c", "docker exec d1 cat /etc/resolv.conf 2>/dev/null | grep -q \\"nameserver 1.1.1.1\\""]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 4, '로그 파일이 무한정 커지지 않게 하기 (--log-opt)', '**배경** — 기본 로깅 드라이버 `json-file` 은 컨테이너 출력을 호스트의 파일에 **한도 없이** 쌓아 디스크를 채울 수 있습니다. **`--log-opt max-size=크기`** 로 파일 하나의 크기를, **`--log-opt max-file=개수`** 로 보관할 파일 수를 정하면 오래된 로그가 순환해 지워집니다.

**문제** — 컨테이너 **`lg`**(`alpine`, `sleep 3600`, 백그라운드)를 **로그 파일 하나 최대 `1m`, 최대 `3`개**로 제한해 실행하세요.', '`docker run -d --name lg --log-opt max-size=1m --log-opt max-file=3 alpine sleep 3600`', 'docker run -d --name lg --log-opt max-size=1m --log-opt max-file=3 alpine sleep 3600
docker inspect -f ''{{json .HostConfig.LogConfig}}'' lg

# {"Type":"json-file","Config":{"max-file":"3","max-size":"1m"}}. 제한이 없으면 로그가 디스크를 채울 수 있다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; true"]', '["sh", "-c", "( [ \\"$(docker inspect -f ''{{index .HostConfig.LogConfig.Config \\"max-size\\"}}'' lg 2>/dev/null)\\" = 1m ] ) && ( [ \\"$(docker inspect -f ''{{index .HostConfig.LogConfig.Config \\"max-file\\"}}'' lg 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "max-size 가 1m 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{index .HostConfig.LogConfig.Config \\"max-size\\"}}'' lg 2>/dev/null)\\" = 1m ]"]}, {"label": "max-file 이 3 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{index .HostConfig.LogConfig.Config \\"max-file\\"}}'' lg 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "JSON 파일 로깅 드라이버", "url": "https://docs.docker.com/engine/logging/drivers/json-file/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 5, '종료 신호와 기다리는 시간 정하기 (--stop-signal, --stop-timeout)', '**배경** — `docker stop` 은 컨테이너의 1번 프로세스에 **종료 신호(기본 `SIGTERM`)**를 보내고, **기다리는 시간(기본 10초)** 안에 끝나지 않으면 **`SIGKILL`** 로 강제 종료합니다. 이 신호는 **`--stop-signal`**, 대기 시간은 **`--stop-timeout`**(초)으로 컨테이너마다 정할 수 있습니다(예: nginx 는 정상 종료 신호가 `SIGQUIT`).

**문제** — 컨테이너 **`sg`**(`alpine`, `sleep 3600`, 백그라운드)를 종료 신호 **`SIGINT`**, 대기 시간 **`3`초**로 실행하세요.', '`docker run -d --name sg --stop-signal SIGINT --stop-timeout 3 alpine sleep 3600`', 'docker run -d --name sg --stop-signal SIGINT --stop-timeout 3 alpine sleep 3600
docker inspect -f ''{{.Config.StopSignal}} {{.Config.StopTimeout}}'' sg

# SIGINT 3. 신호를 못 받는 프로세스는 3초 뒤 SIGKILL 로 끝난다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; true"]', '["sh", "-c", "( [ \\"$(docker inspect -f ''{{.Config.StopSignal}}'' sg 2>/dev/null)\\" = SIGINT ] ) && ( [ \\"$(docker inspect -f ''{{.Config.StopTimeout}}'' sg 2>/dev/null)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "종료 신호가 SIGINT 다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.Config.StopSignal}}'' sg 2>/dev/null)\\" = SIGINT ]"]}, {"label": "대기 시간이 3 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.Config.StopTimeout}}'' sg 2>/dev/null)\\" = 3 ]"]}]', '[{"title": "docker container stop", "url": "https://docs.docker.com/reference/cli/docker/container/stop/"}, {"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 6, '볼륨을 읽기 전용으로 붙이기 (--mount, readonly)', '**배경** — `-v 볼륨:경로:ro` 대신 **`--mount`** 는 `type=`, `src=`, `dst=`, `readonly` 처럼 **이름이 있는 항목**으로 적어 읽기 쉽고, 없는 경로를 만들어 버리지 않고 오류를 냅니다. `readonly` 를 주면 컨테이너가 그 경로에 **쓸 수 없습니다**. 볼륨 `v1` 에 파일 `hello.txt`(내용 `hi`)가 들어 있습니다.

**문제** — 볼륨 `v1` 을 **`--mount` 로 `/data` 에 읽기 전용**으로 붙인 컨테이너 **`ro`**(`alpine`, `sleep 3600`, 백그라운드)를 실행하세요. (`/data/hello.txt` 는 읽히고 쓰기는 실패해야 합니다.)', '`docker run -d --name ro --mount type=volume,src=v1,dst=/data,readonly alpine sleep 3600`', 'docker run -d --name ro --mount type=volume,src=v1,dst=/data,readonly alpine sleep 3600
docker exec ro cat /data/hello.txt
docker exec ro sh -c ''echo x > /data/new.txt''   # Read-only file system 오류

# --mount 는 항목 이름이 있어 -v 의 콜론 순서를 외울 필요가 없다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker volume create v1 >/dev/null; docker run --rm -v v1:/d alpine sh -c ''echo hi > /d/hello.txt'' >/dev/null"]', '["sh", "-c", "( [ \\"$(docker exec ro cat /data/hello.txt 2>/dev/null)\\" = hi ] ) && ( ! docker exec ro sh -c \\"echo x > /data/new.txt\\" >/dev/null 2>&1 ) && ( [ \\"$(docker inspect -f ''{{(index .Mounts 0).Name}}'' ro 2>/dev/null)\\" = v1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/data/hello.txt 가 읽힌다", "cmd": ["sh", "-c", "[ \\"$(docker exec ro cat /data/hello.txt 2>/dev/null)\\" = hi ]"]}, {"label": "/data 에 쓸 수 없다", "cmd": ["sh", "-c", "! docker exec ro sh -c \\"echo x > /data/new.txt\\" >/dev/null 2>&1"]}, {"label": "볼륨 v1 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{(index .Mounts 0).Name}}'' ro 2>/dev/null)\\" = v1 ]"]}]', '[{"title": "바인드 마운트·볼륨 (--mount)", "url": "https://docs.docker.com/engine/storage/volumes/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 7, '컨테이너 커널 설정 하나 바꾸기 (--sysctl)', '**배경** — 컨테이너는 호스트와 커널을 공유하지만 **네트워크 네임스페이스에 속한 일부 sysctl** 은 컨테이너마다 따로 가질 수 있습니다. **`--sysctl 키=값`** 으로 시작할 때 설정하며, `net.core.somaxconn`(연결 대기열 크기) 같은 것이 대표적입니다. 호스트 전체에 영향을 주는 키는 거부됩니다.

**문제** — 컨테이너 **`sy`**(`alpine`, `sleep 3600`, 백그라운드)를 **`net.core.somaxconn=1024`** 로 실행하세요. (컨테이너 안 `/proc/sys/net/core/somaxconn` 이 `1024` 여야 합니다.)', '`docker run -d --name sy --sysctl net.core.somaxconn=1024 alpine sleep 3600`', 'docker run -d --name sy --sysctl net.core.somaxconn=1024 alpine sleep 3600
docker exec sy cat /proc/sys/net/core/somaxconn

# 1024. 컨테이너마다 독립이라 호스트 값은 그대로다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; true"]', '["sh", "-c", "( [ \\"$(docker exec sy cat /proc/sys/net/core/somaxconn 2>/dev/null)\\" = 1024 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "somaxconn 이 1024 다", "cmd": ["sh", "-c", "[ \\"$(docker exec sy cat /proc/sys/net/core/somaxconn 2>/dev/null)\\" = 1024 ]"]}]', '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 8, '잘리지 않은 컨테이너 ID 저장하기 (ps --no-trunc)', '**배경** — `docker ps` 의 ID 는 앞 **12자리만** 보여 줍니다. 스크립트에서 정확히 지정하거나 파일·로그 이름과 맞출 때는 **64자리 전체 ID** 가 필요하며, **`--no-trunc`** 로 줄이지 않은 값을 얻습니다. `-q` 는 ID 만, `--filter name=` 은 이름으로 거릅니다. 컨테이너 `target` 이 실행 중입니다.

**문제** — 컨테이너 `target` 의 **전체 ID(64자리)** 를 **`/tmp/q8.txt`** 에 저장하세요.', '`docker ps -q --no-trunc --filter name=target > /tmp/q8.txt`', 'docker ps -q --no-trunc --filter name=target > /tmp/q8.txt
cat /tmp/q8.txt

# --no-trunc 가 없으면 12자리다. 이름 필터는 부분 일치라 다른 컨테이너가 섞이지 않게 주의한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name target alpine sleep 3600 >/dev/null"]', '["sh", "-c", "( [ \\"$(tr -d ''\\\\n'' < /tmp/q8.txt 2>/dev/null | wc -c | tr -d '' '')\\" = 64 ] ) && ( [ \\"$(cat /tmp/q8.txt 2>/dev/null)\\" = \\"$(docker inspect -f ''{{.Id}}'' target)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "64자리 ID 다", "cmd": ["sh", "-c", "[ \\"$(tr -d ''\\\\n'' < /tmp/q8.txt 2>/dev/null | wc -c | tr -d '' '')\\" = 64 ]"]}, {"label": "target 의 ID 와 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q8.txt 2>/dev/null)\\" = \\"$(docker inspect -f ''{{.Id}}'' target)\\" ]"]}]', '[{"title": "docker container ls", "url": "https://docs.docker.com/reference/cli/docker/container/ls/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 9, '권한 상승을 막고 필요한 능력만 주기 (--security-opt no-new-privileges)', '**배경** — **`--security-opt no-new-privileges`** 는 컨테이너 안 프로세스가 `setuid` 바이너리나 파일 능력으로 **자기 권한을 더 높이지 못하게** 막습니다. `--cap-drop ALL` 로 모든 리눅스 capability 를 버리고 `--cap-add` 로 **필요한 것만** 주는 방식과 함께 최소 권한 실행의 기본이 됩니다.

**문제** — 컨테이너 **`sec`**(`alpine`, `sleep 3600`, 백그라운드)를 **`no-new-privileges`** 로, **모든 capability 를 버리고 `NET_BIND_SERVICE` 만** 추가해 실행하세요.', '`docker run -d --name sec --security-opt no-new-privileges --cap-drop ALL --cap-add NET_BIND_SERVICE alpine sleep 3600`', 'docker run -d --name sec --security-opt no-new-privileges --cap-drop ALL --cap-add NET_BIND_SERVICE alpine sleep 3600
docker inspect -f ''{{.HostConfig.SecurityOpt}} {{.HostConfig.CapAdd}} {{.HostConfig.CapDrop}}'' sec

# 권한을 쓰지 않는 앱이라면 --cap-drop ALL 만으로도 충분한 경우가 많다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network rm net1 net2 >/dev/null 2>&1; docker volume rm -f v1 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; true"]', '["sh", "-c", "( [ \\"$(docker inspect -f ''{{.HostConfig.SecurityOpt}}'' sec 2>/dev/null)\\" = [no-new-privileges] ] ) && ( [ \\"$(docker inspect -f ''{{.HostConfig.CapDrop}}'' sec 2>/dev/null)\\" = [ALL] ] ) && ( docker inspect -f ''{{.HostConfig.CapAdd}}'' sec 2>/dev/null | grep -q NET_BIND_SERVICE )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "no-new-privileges 가 있다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.HostConfig.SecurityOpt}}'' sec 2>/dev/null)\\" = [no-new-privileges] ]"]}, {"label": "CapDrop 이 ALL 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f ''{{.HostConfig.CapDrop}}'' sec 2>/dev/null)\\" = [ALL] ]"]}, {"label": "CapAdd 가 NET_BIND_SERVICE 다", "cmd": ["sh", "-c", "docker inspect -f ''{{.HostConfig.CapAdd}}'' sec 2>/dev/null | grep -q NET_BIND_SERVICE"]}]', '[{"title": "Docker 보안", "url": "https://docs.docker.com/engine/security/"}, {"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 10, 'docker stop 의 대기 시간', '`docker stop` 이 컨테이너를 끝낼 때 `--stop-timeout` 시간이 지나도록 프로세스가 종료되지 않으면 어떻게 될까요?', '종료 신호 다음 단계를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`SIGTERM` 을 한 번 더 보내고 계속 기다린다", "`SIGKILL` 로 강제 종료된다", "컨테이너가 일시 정지 상태로 남는다", "`docker stop` 이 오류를 내고 아무 일도 하지 않는다"]', 1, 'stop 은 먼저 종료 신호(기본 SIGTERM)를 보내고, 대기 시간이 지나면 SIGKILL 로 강제 종료합니다. SIGKILL 은 프로세스가 막을 수 없습니다.', NULL, NULL, NULL, '[{"title": "docker container stop", "url": "https://docs.docker.com/reference/cli/docker/container/stop/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 11, '네트워크에서 쓰는 다른 이름', '같은 컨테이너에 사용자 정의 네트워크 안에서 쓸 다른 이름을 주는 옵션입니다. 빈칸을 채우세요.', '"별칭" 과 같은 뜻의 영어예요.', NULL, NULL, '[]', 'fill', '["alias", "name", "host", "link"]', NULL, '--network-alias 는 그 네트워크 안에서만 풀리는 추가 이름을 줍니다. --network-name, --network-host 는 없는 옵션이고, --link 는 낡은 방식입니다.', '[0]', 'docker run --network net1 --network-{0} db alpine', NULL, '[{"title": "docker container run 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/container/run/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 498, 12, '고정 IP 컨테이너를 만드는 순서', '대역을 정한 네트워크에서 컨테이너 IP 를 고정해 실행하는 순서입니다. 순서에 맞게 놓아 보세요.', '네트워크 → 컨테이너 → 확인이에요.', NULL, NULL, '[]', 'order', '["`docker network create --subnet 172.30.0.0/24 net2` 로 대역을 정한 네트워크를 만든다", "`docker run -d --network net2 --ip 172.30.0.10 ...` 로 IP 를 지정해 실행한다", "`docker inspect` 로 컨테이너의 IP 를 확인한다", "다른 컨테이너에서 그 IP 로 `ping` 해 연결을 확인한다"]', NULL, '--ip 는 --subnet 을 직접 준 네트워크에서만 쓸 수 있으므로 네트워크를 먼저 만듭니다. 실행한 뒤 inspect 로 IP 를 확인하고 다른 컨테이너에서 접근해 봅니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "docker network create", "url": "https://docs.docker.com/reference/cli/docker/network/create/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 498 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 233 WHERE id = 148;
UPDATE quest_set SET display_order = 234 WHERE id = 240;
UPDATE quest_set SET display_order = 235 WHERE id = 175;
UPDATE quest_set SET display_order = 236 WHERE id = 245;
UPDATE quest_set SET display_order = 237 WHERE id = 206;
UPDATE quest_set SET display_order = 238 WHERE id = 253;
UPDATE quest_set SET display_order = 239 WHERE id = 237;
UPDATE quest_set SET display_order = 240 WHERE id = 38;
UPDATE quest_set SET display_order = 241 WHERE id = 39;
UPDATE quest_set SET display_order = 242 WHERE id = 490;
UPDATE quest_set SET display_order = 245 WHERE id = 97;
UPDATE quest_set SET display_order = 231, unit_id = (SELECT id FROM unit WHERE id = 34), icon = '🛰' WHERE id = 498;
