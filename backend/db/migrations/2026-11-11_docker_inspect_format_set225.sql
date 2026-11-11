-- 도커 세트 225. 여러 번 실행해도 안전하다 (NOT EXISTS 가드, 순서는 절대값 UPDATE). 원본: 02_quest_set.sql, 03_quest_set225.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_docker_inspect_format_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 225, '도커 출력에서 원하는 값만 뽑기: inspect -f, range, index, ps --format·--filter', 'docker inspect 가 주는 JSON 의 구조를 읽고 -f 템플릿으로 값 하나만 뽑는 연습입니다. 상태·이미지·IP·종료 코드, range 로 환경 변수 한 줄씩, index 로 레이블 값, ps --format 표와 --filter 로 종료된 컨테이너만 고르기를 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 225);
UPDATE quest_set SET display_order = 188 WHERE id = 11;
UPDATE quest_set SET display_order = 189 WHERE id = 167;
UPDATE quest_set SET display_order = 190 WHERE id = 218;
UPDATE quest_set SET display_order = 191 WHERE id = 183;
UPDATE quest_set SET display_order = 192 WHERE id = 221;
UPDATE quest_set SET display_order = 193 WHERE id = 154;
UPDATE quest_set SET display_order = 194 WHERE id = 187;
UPDATE quest_set SET display_order = 195 WHERE id = 8;
UPDATE quest_set SET display_order = 196 WHERE id = 142;
UPDATE quest_set SET display_order = 197 WHERE id = 179;
UPDATE quest_set SET display_order = 198 WHERE id = 209;
UPDATE quest_set SET display_order = 199 WHERE id = 148;
UPDATE quest_set SET display_order = 200 WHERE id = 175;
UPDATE quest_set SET display_order = 201 WHERE id = 206;
UPDATE quest_set SET display_order = 187, unit_id = (SELECT id FROM unit WHERE id = 32), icon = '🔎' WHERE id = 225;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 1, '상태만 뽑기', '컨테이너 `web` 의 **상태**(`running` 같은 한 단어)만 뽑아 `/tmp/status.txt` 에 저장하세요. 컨테이너 `web`, `db` 는 실행 중이고 `job` 은 이미 끝났습니다.', '`docker inspect 이름` 은 긴 JSON 을 줍니다. `-f ''{{.State.Status}}''` 처럼 경로를 주면 그 값만 나와요. 먼저 `docker inspect web | head -n 30` 으로 구조를 구경해 보세요.', 'docker inspect web | head -n 30
docker inspect -f ''{{.State.Status}}'' web > /tmp/status.txt
cat /tmp/status.txt

# -f 는 Go 템플릿. {{.State.Status}} : State 안의 Status 값만 출력한다', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( [ -s /tmp/status.txt ] ) && ( [ \\"$(cat /tmp/status.txt)\\" = running ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/status.txt ]"]}, {"label": "값이 running 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/status.txt)\\" = running ]"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 2, '이미지 이름', '컨테이너 `web` 이 **어떤 이미지로 만들어졌는지** 이름만 `/tmp/image.txt` 에 저장하세요.', '이미지 정보는 `Config` 아래에 있어요. `docker inspect web | grep -n Image` 로 위치를 찾아봐도 됩니다.', 'docker inspect -f ''{{.Config.Image}}'' web > /tmp/image.txt
cat /tmp/image.txt

# 상태는 State, 실행 설정(이미지·명령·환경 변수·레이블)은 Config 아래에 있다', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(cat /tmp/image.txt)\\" = alpine ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 alpine 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/image.txt)\\" = alpine ]"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 3, 'IP 주소', '컨테이너 `web` 의 **IP 주소**만 `/tmp/ip.txt` 에 저장하세요. (숫자와 점으로 된 주소 한 줄)', '네트워크 정보는 `NetworkSettings.Networks` 아래에 네트워크 이름별로 들어 있어요. 이름을 몰라도 `{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}` 로 돌며 꺼낼 수 있습니다.', 'docker inspect -f ''{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'' web > /tmp/ip.txt
cat /tmp/ip.txt

# 네트워크마다 주소가 따로라 Networks 를 range 로 돈다. 컨테이너끼리 연결할 때, 장애 때 "어느 주소로 뜨나" 볼 때 가장 자주 쓰는 값', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( grep -Eq \\"^[0-9]+\\\\.[0-9]+\\\\.[0-9]+\\\\.[0-9]+$\\" /tmp/ip.txt ) && ( [ \\"$(cat /tmp/ip.txt)\\" = \\"$(docker inspect -f ''{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'' web)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "IP 모양이다", "cmd": ["sh", "-c", "grep -Eq \\"^[0-9]+\\\\.[0-9]+\\\\.[0-9]+\\\\.[0-9]+$\\" /tmp/ip.txt"]}, {"label": "web 의 실제 IP 와 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/ip.txt)\\" = \\"$(docker inspect -f ''{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'' web)\\" ]"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 4, '종료 코드', '이미 끝난 컨테이너 `job` 의 **종료 코드**만 `/tmp/exit.txt` 에 저장하세요.', '종료와 관련된 값은 `State` 아래에 모여 있어요.', 'docker inspect -f ''{{.State.ExitCode}}'' job > /tmp/exit.txt
cat /tmp/exit.txt

# 0 은 정상 종료, 그 밖의 숫자는 오류 (137 = SIGKILL, 143 = SIGTERM)', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(cat /tmp/exit.txt)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 3 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/exit.txt)\\" = 3 ]"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 5, '실행 중인지 true/false 로 뽑기', '컨테이너 `web` 이 **실행 중인지** `true` 또는 `false` 한 단어로만 뽑는 명령입니다. 경로의 빈칸을 채우세요.', '`State` 안에 `Running` 이 있어요. 점(.)으로 한 칸씩 내려갑니다.', NULL, NULL, '[]', 'fill', '["State", "Config", "HostConfig", "Running", "Image", "Cmd"]', NULL, '경로는 JSON 의 위에서 아래로 점으로 이어 씁니다. `State` 아래 `Running` 이 true/false 입니다. 스크립트에서 `if [ "$(docker inspect -f ''{{.State.Running}}'' web)" = true ]` 처럼 상태를 확인할 때 씁니다.', '[0, 3]', 'docker inspect -f ''{{.{0}.{1}}}'' web', NULL, '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 6, '환경 변수를 한 줄씩', '컨테이너 `web` 의 **환경 변수**를 한 줄에 하나씩 `/tmp/env.txt` 에 저장하세요. `APP_ENV=prod` 줄이 보여야 합니다.', '환경 변수는 `.Config.Env` 배열이에요. 배열은 `{{range .Config.Env}}…{{end}}` 로 하나씩 돌고, 줄바꿈은 `{{println .}}` 입니다.', 'docker inspect -f ''{{range .Config.Env}}{{println .}}{{end}}'' web > /tmp/env.txt
cat /tmp/env.txt

# range 는 배열의 원소를 하나씩 돌며 안쪽 식을 실행한다 (kubectl jsonpath 의 range 와 같은 생각)', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( grep -qx APP_ENV=prod /tmp/env.txt ) && ( [ \\"$(wc -l < /tmp/env.txt)\\" -ge 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "APP_ENV=prod 줄이 있다", "cmd": ["sh", "-c", "grep -qx APP_ENV=prod /tmp/env.txt"]}, {"label": "한 줄에 하나씩이다 (2줄 이상)", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/env.txt)\\" -ge 2 ]"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 7, '레이블 값', '컨테이너 `web` 의 레이블 **`tier`** 의 값만 `/tmp/tier.txt` 에 저장하세요.', '레이블은 `.Config.Labels` 맵입니다. 키로 값을 꺼내려면 `{{index .Config.Labels "tier"}}` 처럼 `index` 를 씁니다. (키 이름에 점이 있어도 이 방법이 통합니다)', 'docker inspect -f ''{{index .Config.Labels "tier"}}'' web > /tmp/tier.txt
cat /tmp/tier.txt

# 맵(키-값)은 index 맵 "키" 로 꺼낸다. com.example.app 처럼 점이 든 키도 같다', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(cat /tmp/tier.txt)\\" = frontend ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 frontend 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/tier.txt)\\" = frontend ]"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 8, '모든 컨테이너 이름만', '종료된 것까지 **모든 컨테이너의 이름**만 한 줄에 하나씩 `/tmp/names.txt` 에 저장하세요. `web`, `db`, `job` 이 보여야 합니다.', '`docker ps` 는 종료된 것을 빼니 `-a` 가 필요해요. 열을 고르려면 `--format ''{{.Names}}''` 입니다.', 'docker ps -a --format ''{{.Names}}'' > /tmp/names.txt
cat /tmp/names.txt

# --format 으로 ps 의 열을 고른다. 쓸 수 있는 이름: .ID .Names .Image .Status .Ports 등', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( grep -qx web /tmp/names.txt ) && ( grep -qx db /tmp/names.txt ) && ( grep -qx job /tmp/names.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web 이 있다", "cmd": ["sh", "-c", "grep -qx web /tmp/names.txt"]}, {"label": "db 가 있다", "cmd": ["sh", "-c", "grep -qx db /tmp/names.txt"]}, {"label": "job 이 있다 (종료된 것 포함)", "cmd": ["sh", "-c", "grep -qx job /tmp/names.txt"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 9, '이름과 상태를 표로', '모든 컨테이너의 **이름과 상태**를 제목 줄이 있는 표로 `/tmp/table.txt` 에 저장하세요. (제목은 `NAMES`, `STATUS` 가 됩니다)', '`--format` 의 맨 앞에 `table ` 을 붙이면 제목 줄이 생겨요. 열 사이는 `\\t`(탭)로 나눕니다.', 'docker ps -a --format ''table {{.Names}}\\t{{.Status}}'' > /tmp/table.txt
cat /tmp/table.txt

# table 로 시작하면 제목 줄이 붙고 열이 정렬된다. 사람이 읽을 표가 필요할 때 쓴다', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( head -n 1 /tmp/table.txt | grep -q NAMES && head -n 1 /tmp/table.txt | grep -q STATUS ) && ( grep -E \\"^web\\" /tmp/table.txt | grep -q Up ) && ( grep -E \\"^job\\" /tmp/table.txt | grep -q \\"Exited (3)\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "제목 줄에 NAMES 와 STATUS 가 있다", "cmd": ["sh", "-c", "head -n 1 /tmp/table.txt | grep -q NAMES && head -n 1 /tmp/table.txt | grep -q STATUS"]}, {"label": "web 줄에 Up 이 보인다", "cmd": ["sh", "-c", "grep -E \\"^web\\" /tmp/table.txt | grep -q Up"]}, {"label": "job 줄에 Exited (3) 이 보인다", "cmd": ["sh", "-c", "grep -E \\"^job\\" /tmp/table.txt | grep -q \\"Exited (3)\\""]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 10, '종료된 것까지 ID 만 뽑기', '종료된 컨테이너까지 **모든 컨테이너의 ID 만** 한 줄에 하나씩 뽑으려고 합니다. (스크립트에서 `docker rm $(…)` 처럼 쓸 값) 알맞은 명령은 무엇일까요?', '`-q` 는 ID 만, `-a` 는 종료된 것까지입니다.', NULL, NULL, '[]', 'choice', '["`docker ps -q`", "`docker ps -aq`", "`docker ps -a --no-trunc`", "`docker inspect -aq`"]', 1, '`-a`(종료된 것까지)와 `-q`(ID 만)를 합친 `docker ps -aq` 가 정답입니다. `docker ps -q` 는 실행 중인 것만, `--no-trunc` 는 ID 를 줄이지 않고 길게 보일 뿐이며, `docker inspect` 에는 `-q` 옵션이 없습니다.', NULL, NULL, NULL, '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 11, '종료된 컨테이너 이름만', '**종료된(exited) 컨테이너의 이름만** `/tmp/exited.txt` 에 저장하세요. 한 줄에 하나, `job` 만 나와야 합니다.', '조건으로 고르는 것은 `--filter status=exited`, 모양을 고르는 것은 `--format` 입니다. `-a` 도 잊지 마세요.', 'docker ps -a --filter status=exited --format ''{{.Names}}'' > /tmp/exited.txt
cat /tmp/exited.txt

# --filter 는 "어떤 컨테이너를", --format 은 "어떤 모양으로". 둘을 같이 쓰면 장애 컨테이너만 뽑을 수 있다', '["sh", "-c", "rm -f /tmp/*.txt; docker run -d --name web -p 8080:80 -e APP_ENV=prod --label tier=frontend alpine sleep 3600 >/dev/null 2>&1; docker run -d --name db -e APP_ENV=prod --label tier=backend alpine sleep 3600 >/dev/null 2>&1; docker run --name job alpine sh -c ''exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( grep -qx job /tmp/exited.txt ) && ( ! grep -qx web /tmp/exited.txt ) && ( ! grep -qx db /tmp/exited.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "job 이 있다", "cmd": ["sh", "-c", "grep -qx job /tmp/exited.txt"]}, {"label": "실행 중인 web 은 없다", "cmd": ["sh", "-c", "! grep -qx web /tmp/exited.txt"]}, {"label": "실행 중인 db 는 없다", "cmd": ["sh", "-c", "! grep -qx db /tmp/exited.txt"]}]', '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 225, 12, '값 하나를 찾아내는 흐름', '컨테이너 `web` 의 레이블 값을 스크립트에 쓰려고 합니다. 값을 찾아 쓰기까지의 흐름을 **앞에서 뒤**로 놓으세요.', '이름 확인 → 구조 구경 → 한 값으로 좁히기 → 쓰기 순서입니다.', NULL, NULL, '[]', 'order', '["`docker ps -a` 로 대상 컨테이너 이름을 확인한다", "`docker inspect 이름` 으로 JSON 전체를 보고 값이 어느 경로에 있는지 찾는다", "`docker inspect -f ''{{…}}'' 이름` 으로 그 경로의 값 하나만 뽑아 본다", "`$(docker inspect -f …)` 형태로 스크립트·명령에 끼워 넣는다"]', NULL, '**이름 확인 → 전체 구조에서 경로 찾기 → `-f` 로 한 값만 → `$(…)` 로 사용** 입니다. 처음부터 `-f` 를 쓰면 경로를 모르니 먼저 전체 JSON 을 한 번 봅니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Docker 공식 문서: 출력 형식 지정", "url": "https://docs.docker.com/engine/cli/formatting/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 225 AND order_index = 12);
