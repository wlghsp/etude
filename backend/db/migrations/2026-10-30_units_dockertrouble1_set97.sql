-- 도커 세트 97. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set97.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 26, '도커', '문제 해결', 30 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 26);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 97, '도커 문제 해결 상황집: 컨테이너가 안 뜰 때', '컨테이너가 바로 종료되거나, 포트가 충돌하거나, 디스크가 가득 찰 때 원인을 찾아 해결하는 법을 익힙니다. docker ps -a·logs·inspect 로 조사하고, 종료 코드 읽기, 포트·이름 충돌 풀기, 환경 변수 누락 고치기, 쌓인 컨테이너 정리, 재시작 정책을 문제와 실습으로 다룹니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 97);
UPDATE quest_set SET display_order = 230, unit_id = (SELECT id FROM unit WHERE id = 26), icon = '🆘' WHERE id = 97;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 1, '멈춘 컨테이너 조사 명령 채우기', '컨테이너 `web` 이 시작하자마자 멈췄습니다. ① 종료된 것까지 포함한 목록, ② 컨테이너가 남긴 출력(로그), ③ 종료 코드와 설정 같은 상세 정보를 보는 명령입니다. 빈칸을 채우세요.', '목록은 `ps -a`, 출력은 로그, 상세 정보는 "검사"라는 뜻의 단어입니다.', NULL, NULL, '[]', 'fill', '["ps", "logs", "inspect", "images", "rm", "exec"]', NULL, '`docker ps -a` 는 종료된 컨테이너까지 보여 주고(상태에 `Exited (코드)`), `docker logs` 는 그 컨테이너가 출력한 내용을 보여 주며 오류 메시지가 대부분 여기에 있습니다. `docker inspect` 는 종료 코드, 환경 변수, 실행 명령 같은 상세 정보를 JSON 으로 보여 줍니다.', '[0, 1, 2]', 'docker {0} -a
docker {1} web
docker {2} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 2, '컨테이너가 계속 종료될 때 진단 순서', '`docker run -d` 로 띄운 컨테이너가 몇 초 뒤 사라집니다. 원인을 찾아 고치는 흐름을 **앞에서 뒤**로 놓으세요.', '현상 확인 → 출력 읽기 → 설정 확인 → 고쳐서 재실행 순서입니다.', NULL, NULL, '[]', 'order', '["`docker inspect` 로 실행 명령과 환경 변수가 의도대로인지 확인한다", "원인을 고쳐서 컨테이너를 다시 실행한다", "`docker logs` 로 마지막에 남긴 오류 메시지를 읽는다", "`docker ps -a` 로 `Exited (숫자)` 상태와 종료 코드를 확인한다"]', NULL, '**ps -a(상태·코드) → logs(오류 메시지) → inspect(설정) → 수정 후 재실행** 입니다. 컨테이너는 종료돼도 `docker rm` 하기 전까지 로그가 남으므로, 지우기 전에 먼저 읽습니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 3, '종료 코드로 원인 짐작하기', '`docker ps -a` 에 `Exited (137)` 이 보입니다. 가장 가능성이 높은 해석은 무엇일까요?', '128 + 9(SIGKILL) 입니다.', NULL, NULL, '[]', 'choice', '["정상적으로 작업을 끝내고 종료했다", "명령어 문법이 틀려서 시작하지 못했다", "이미지를 찾지 못했다", "강제 종료(SIGKILL)됨 — 메모리 한도 초과(OOM kill)이거나 `docker kill`·타임아웃 후 강제 종료"]', 3, '`0` 은 정상 종료, `1` 등 작은 수는 프로그램이 스스로 낸 오류, `137`(=128+9)은 SIGKILL, `143`(=128+15)은 SIGTERM 으로 종료된 것입니다. `docker inspect -f "{{.State.OOMKilled}}" 이름` 이 true 면 메모리 부족이 원인입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 4, '"port is already allocated" 오류', '`docker run -p 8080:80 ...` 가 `Bind for 0.0.0.0:8080 failed: port is already allocated` 로 실패합니다. 올바른 대응은 무엇일까요?', '호스트의 8080 포트를 이미 누군가 쓰고 있습니다.', NULL, NULL, '[]', 'choice', '["컨테이너 안의 80 포트를 바꾼다", "`docker ps` 로 8080 을 쓰는 컨테이너(또는 호스트 프로세스)를 찾아 정리하거나, 호스트 포트를 다른 번호(`-p 8081:80`)로 바꾼다", "도커를 재설치한다", "`-p` 옵션을 두 번 쓴다"]', 1, '`-p 호스트포트:컨테이너포트` 에서 충돌하는 것은 **호스트** 포트입니다. 컨테이너 안의 포트는 컨테이너마다 독립이라 겹쳐도 됩니다. 호스트 프로세스가 쓰는 경우는 `ss -ltnp` 로 찾습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 5, '"No space left on device" 정리하기', '도커 호스트에서 이미지를 받다가 `no space left on device` 가 납니다. 안전하게 시작할 첫 단계는 무엇일까요?', '무엇이 공간을 쓰는지 먼저 봅니다.', NULL, NULL, '[]', 'choice', '["도커 데몬을 종료하고 기다린다", "`docker volume prune -a` 로 볼륨부터 전부 지운다", "`docker system df` 로 이미지·컨테이너·볼륨별 사용량을 보고, 종료된 컨테이너와 안 쓰는 이미지부터 `prune` 으로 정리한다", "`/var/lib/docker` 폴더를 `rm -rf` 로 지운다"]', 2, '`/var/lib/docker` 를 직접 지우면 이미지·볼륨이 깨집니다. `docker container prune`, `docker image prune` 은 쓰지 않는 것만 지우지만, **볼륨**에는 DB 같은 데이터가 있을 수 있으니 내용을 확인하고 지웁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 6, '"container name is already in use"', '`docker run --name web ...` 가 `The container name "/web" is already in use by container ...` 로 실패합니다. 원인과 해결로 알맞은 것은 무엇일까요?', '종료된 컨테이너도 이름을 차지합니다.', NULL, NULL, '[]', 'choice', '["같은 이름의 컨테이너가 (종료된 상태로라도) 남아 있다. `docker rm web`(실행 중이면 `-f`)으로 지우거나 다른 이름을 쓴다", "이미지 이름이 `web` 이라서 겹쳤다", "포트가 사용 중이다", "이름은 한 번 쓰면 영원히 쓸 수 없다"]', 0, '컨테이너 이름은 종료돼도 `docker rm` 하기 전까지 유지됩니다. 일회성 실행이라면 `docker run --rm` 으로 종료 시 자동 삭제되게 하면 이 오류를 피할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 7, '컨테이너가 바로 끝나는 이유', 'Dockerfile 의 `CMD service nginx start` 로 만든 이미지를 `docker run -d` 하면 컨테이너가 **바로 종료**됩니다. 왜일까요?', '컨테이너는 첫 번째 프로세스(PID 1)가 끝나면 함께 끝납니다.', NULL, NULL, '[]', 'choice', '["nginx 는 도커에서 실행할 수 없다", "`service ... start` 는 서비스를 뒤에서 띄우고 **곧바로 끝나 버려**, 남은 foreground 프로세스가 없어 컨테이너가 종료된다. `nginx -g \\"daemon off;\\"` 처럼 foreground 로 실행한다", "`-d` 옵션과 nginx 가 충돌한다", "이미지 크기가 커서 종료된다"]', 1, '컨테이너의 생명은 메인 프로세스에 달려 있습니다. 서비스는 **foreground 로 실행**하고 로그는 표준 출력으로 내보내야 `docker logs` 로도 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 8, '컨테이너의 종료 코드 확인하기', '`job` 컨테이너가 시작하자마자 종료되었습니다. 종료 코드를 **`/tmp/exit.txt`** 에 저장하세요. (숫자만)', '`docker ps -a` 로 상태를 보거나, `docker inspect -f` 와 Go 템플릿 `{{.State.ExitCode}}` 로 값만 뽑을 수 있습니다.\\n확인: `docker logs job`', 'docker logs job
docker inspect -f ''{{.State.ExitCode}}'' job > /tmp/exit.txt
cat /tmp/exit.txt

# -f : 출력 형식 템플릿, 종료 코드만 뽑는다', '["sh", "-c", "docker run --name job alpine sh -c ''echo starting; echo cannot connect to db >&2; exit 3'' >/dev/null 2>&1; true"]', '["sh", "-c", "( [ -s /tmp/exit.txt ] ) && ( [ \\"$(cat /tmp/exit.txt)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/exit.txt ]"]}, {"label": "종료 코드 3 이 저장되어 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/exit.txt)\\" = 3 ]"]}]', '[{"title": "Docker 공식 문서", "url": "https://docs.docker.com/reference/cli/docker/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 9, '포트 충돌 해결하고 서버 띄우기', '호스트의 8080 포트를 이미 컨테이너 `old` 가 쓰고 있어, 새 서버 `web` 이 같은 포트로 뜨지 못합니다. `old` 는 더 이상 필요 없습니다. `old` 를 정리하고 **`web`** 컨테이너를 호스트 **8080** 포트(컨테이너 80)로 **백그라운드 실행**하세요. (이미지 `alpine`, 명령 `sleep 3600`)', '먼저 `docker ps` 로 누가 8080 을 쓰는지 확인하세요. 실행 중인 컨테이너는 `docker rm -f` 로 지울 수 있습니다.\\n확인: `docker port web`', 'docker ps
docker rm -f old
docker run -d --name web -p 8080:80 alpine sleep 3600
docker port web

# -p 호스트포트:컨테이너포트 (호스트 포트가 충돌한다)', '["sh", "-c", "docker run -d --name old -p 8080:80 alpine sleep 3600 >/dev/null"]', '["sh", "-c", "( [ \\"$(docker inspect -f {{.State.Running}} web 2>/dev/null)\\" = true ] ) && ( docker port web 2>/dev/null | grep -q 8080 ) && ( ! docker ps -a --format {{.Names}} | grep -qx old )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web 컨테이너가 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f {{.State.Running}} web 2>/dev/null)\\" = true ]"]}, {"label": "web 이 호스트 8080 포트를 쓴다", "cmd": ["sh", "-c", "docker port web 2>/dev/null | grep -q 8080"]}, {"label": "old 컨테이너는 없다", "cmd": ["sh", "-c", "! docker ps -a --format {{.Names}} | grep -qx old"]}]', '[{"title": "Docker 공식 문서", "url": "https://docs.docker.com/reference/cli/docker/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 10, '로그를 읽고 환경 변수로 고치기', '이미지 `myapp:1` 로 만든 컨테이너 `app` 이 곧바로 종료됩니다. **로그를 읽고** 원인을 파악한 뒤, 기존 컨테이너를 지우고 같은 이름 `app` 으로 **필요한 환경 변수를 주어 백그라운드로 다시 실행**하세요. (값은 `db.example.com`)', '`docker logs app` 에 무엇이 필요한지 나옵니다. 환경 변수는 `-e 이름=값` 으로 줍니다.', 'docker logs app
docker rm app
docker run -d --name app -e DB_HOST=db.example.com myapp:1
docker ps

# -e : 컨테이너에 환경 변수 전달', '["sh", "-c", "mkdir -p /tmp/img && cd /tmp/img && printf ''%s\\\\n'' ''if [ -z \\"$DB_HOST\\" ]; then echo DB_HOST is required; exit 1; fi'' ''echo connected to $DB_HOST'' ''sleep 3600'' > app.sh && printf ''FROM alpine\\\\nCOPY app.sh /app.sh\\\\nCMD [\\"sh\\",\\"/app.sh\\"]\\\\n'' > Dockerfile && docker build -q -t myapp:1 . >/dev/null && docker run -d --name app myapp:1 >/dev/null; sleep 2; true"]', '["sh", "-c", "( [ \\"$(docker inspect -f {{.State.Running}} app 2>/dev/null)\\" = true ] ) && ( docker inspect -f {{.Config.Env}} app | grep -q DB_HOST=db.example.com )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "app 컨테이너가 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f {{.State.Running}} app 2>/dev/null)\\" = true ]"]}, {"label": "DB_HOST 가 db.example.com 이다", "cmd": ["sh", "-c", "docker inspect -f {{.Config.Env}} app | grep -q DB_HOST=db.example.com"]}]', '[{"title": "Docker 공식 문서", "url": "https://docs.docker.com/reference/cli/docker/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 11, '종료된 컨테이너만 정리하기', '실습하며 종료된 컨테이너가 쌓였습니다. **실행 중인 `keep` 컨테이너는 그대로 두고**, 종료된 컨테이너만 모두 삭제하세요.', '"실행 중이 아닌 컨테이너를 모두 삭제"하는 하위 명령이 있습니다(`-f` 로 확인 질문 생략).\\n확인: `docker ps -a`', 'docker ps -a
docker container prune -f
docker ps -a

# prune : 종료된 컨테이너만 일괄 삭제 (실행 중인 것은 건드리지 않는다)', '["sh", "-c", "docker run -d --name keep alpine sleep 3600 >/dev/null; for i in 1 2 3; do docker run --name t$i alpine true; done >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(docker inspect -f {{.State.Running}} keep 2>/dev/null)\\" = true ] ) && ( [ \\"$(docker ps -aq | wc -l)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "keep 컨테이너가 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f {{.State.Running}} keep 2>/dev/null)\\" = true ]"]}, {"label": "종료된 컨테이너가 없다", "cmd": ["sh", "-c", "[ \\"$(docker ps -aq | wc -l)\\" -eq 1 ]"]}]', '[{"title": "Docker 공식 문서", "url": "https://docs.docker.com/reference/cli/docker/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 97, 12, '재부팅 후에도 컨테이너가 다시 뜨게 하기', '서버를 재부팅하면 컨테이너 `web` 이 올라오지 않아 매번 직접 시작해야 합니다. **실행 중인 `web` 을 지우지 않고** 재시작 정책을 **`unless-stopped`** 로 바꾸세요.', '실행 중인 컨테이너의 설정을 바꾸는 명령이 있습니다.\\n확인: `docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" web`', 'docker update --restart unless-stopped web
docker inspect -f ''{{.HostConfig.RestartPolicy.Name}}'' web

# --restart : no(기본) | on-failure | always | unless-stopped', '["sh", "-c", "docker run -d --name web alpine sleep 3600 >/dev/null"]', '["sh", "-c", "( [ \\"$(docker inspect -f {{.State.Running}} web 2>/dev/null)\\" = true ] ) && ( [ \\"$(docker inspect -f {{.HostConfig.RestartPolicy.Name}} web)\\" = unless-stopped ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web 이 계속 실행 중이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f {{.State.Running}} web 2>/dev/null)\\" = true ]"]}, {"label": "재시작 정책이 unless-stopped 이다", "cmd": ["sh", "-c", "[ \\"$(docker inspect -f {{.HostConfig.RestartPolicy.Name}} web)\\" = unless-stopped ]"]}]', '[{"title": "Docker 공식 문서", "url": "https://docs.docker.com/reference/cli/docker/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 97 AND order_index = 12);
