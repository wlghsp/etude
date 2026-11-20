-- 세트 552. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set552.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 552, 'Compose 구성 실습: 네트워크 분리·healthcheck·이미지 갱신·override 파일', 'compose.yaml 을 직접 고쳐 구성을 바꿔 봅니다. 최상위 networks 로 frontend/backend 를 나눠 서로 보이지 않게 만들고, healthcheck 를 쓰고 depends_on 의 service_healthy 로 준비를 기다리며, 상태(starting·healthy·unhealthy)와 점검 출력을 읽습니다. 소스를 바꾼 뒤 up --build 로 이미지를 갱신하고, -f 로 여러 파일을 병합한 결과와 compose.override.yaml 자동 적용을 config 로 확인하며, 메모리·CPU 제한을 걸어 실제 컨테이너에 반영된 값을 확인합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 552);
UPDATE quest_set SET display_order = 812, unit_id = (SELECT id FROM unit WHERE id = 35), icon = '🛠️' WHERE id = 552;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 1, 'frontend/backend 네트워크로 나누기', '`/tmp/work/q1/compose.yaml` 에는 `web`(nginx), `api`, `db` 세 서비스가 있고 네트워크 설정이 없어 **모두 하나의 기본 네트워크**에 있습니다. 그래서 `web` 에서 `db` 로 바로 접속할 수 있습니다. 구성은 이렇게 바꾸려 합니다. **`web` 과 `api` 는 `frontend`, `api` 와 `db` 는 `backend`** 에 두고(`api` 는 두 네트워크 모두), `web` 은 `db` 가 보이지 않아야 합니다. `compose.yaml` 에 최상위 `networks:` 와 서비스별 `networks:` 를 적어 고친 뒤 `docker compose up -d` 로 올리세요.', '최상위 `networks:` 에서 네트워크 이름을 만들고, 각 서비스 아래 `networks:` 에 소속시킬 이름을 목록으로 적습니다. 서비스에 `networks` 를 적으면 기본 네트워크에는 더 이상 자동으로 붙지 않습니다. 결과는 `docker compose exec web ping -c1 db` 처럼 확인할 수 있습니다.', 'cd /tmp/work/q1
cat > compose.yaml <<''EOF''
services:
  web:
    image: nginx:alpine
    networks: [frontend]
  api:
    image: alpine
    command: sleep 3600
    networks: [frontend, backend]
  db:
    image: alpine
    command: sleep 3600
    networks: [backend]
networks:
  frontend:
  backend:
EOF
docker compose up -d
docker compose exec web ping -c1 -W2 db   # bad address 로 실패해야 한다
docker compose exec api ping -c1 -W2 db

# 같은 네트워크에 있는 서비스끼리만 이름으로 서로 찾을 수 있다. api 는 두 네트워크에 걸쳐 중간 다리 역할을 한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q1; cat > /tmp/work/q1/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:alpine\\n  api:\\n    image: alpine\\n    command: sleep 3600\\n  db:\\n    image: alpine\\n    command: sleep 3600\\nEOF\\n"]', '["sh", "-c", "( cd /tmp/work/q1 && [ \\"$(docker compose ps --status running -q | wc -l)\\" = 3 ] ) && ( cd /tmp/work/q1 && docker compose exec -T api ping -c1 -W2 db >/dev/null 2>&1 && docker compose exec -T api ping -c1 -W2 web >/dev/null 2>&1 ) && ( cd /tmp/work/q1 && ! docker compose exec -T web ping -c1 -W2 db >/dev/null 2>&1 ) && ( cd /tmp/work/q1 && ! docker compose exec -T db ping -c1 -W2 web >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web·api·db 가 모두 실행 중이다", "cmd": ["sh", "-c", "cd /tmp/work/q1 && [ \\"$(docker compose ps --status running -q | wc -l)\\" = 3 ]"]}, {"label": "api 가 web 과 db 를 모두 이름으로 찾는다", "cmd": ["sh", "-c", "cd /tmp/work/q1 && docker compose exec -T api ping -c1 -W2 db >/dev/null 2>&1 && docker compose exec -T api ping -c1 -W2 web >/dev/null 2>&1"]}, {"label": "web 에서는 db 가 보이지 않는다", "cmd": ["sh", "-c", "cd /tmp/work/q1 && ! docker compose exec -T web ping -c1 -W2 db >/dev/null 2>&1"]}, {"label": "db 에서도 web 이 보이지 않는다", "cmd": ["sh", "-c", "cd /tmp/work/q1 && ! docker compose exec -T db ping -c1 -W2 web >/dev/null 2>&1"]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 2, 'compose 가 만드는 네트워크의 이름', '프로젝트 이름이 `shop` 이고 compose.yaml 최상위에 `networks:` 로 `backend` 하나만 정의했습니다. `docker compose up -d` 뒤 `docker network ls` 에는 어떤 이름의 네트워크가 보일까요? (서비스 `api`, `db` 가 모두 `networks: [backend]` 로 이 네트워크에 속하므로 기본 네트워크는 쓰지 않습니다.)', '컨테이너 이름이 `프로젝트-서비스-번호` 인 것과 비슷한 규칙을 떠올려 보세요. 같은 호스트의 다른 프로젝트와 이름이 부딪치지 않아야 합니다.', NULL, NULL, '[]', 'choice', '["`shop_backend`", "`backend`", "`shop-backend-1`", "`shop_default`"]', 0, 'compose 는 네트워크 이름 앞에 프로젝트 이름과 밑줄을 붙여 `프로젝트_네트워크` 로 만듭니다. 같은 호스트에 프로젝트가 여럿이어도 이름이 겹치지 않게 하려는 것입니다. 컨테이너가 `프로젝트-서비스-번호` 형태인 것과 다릅니다. `shop_default` 는 네트워크를 정의하지 않았을 때 자동으로 생기는 기본 네트워크입니다. 컨테이너 안에서 서비스끼리 부를 때는 이 이름이 아니라 **서비스 이름**(`db` 등)을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 3, 'healthcheck 를 쓰고 준비될 때까지 기다리기', '`/tmp/work/q3/compose.yaml` 의 `db` 는 시작한 뒤 **약 5초 뒤에야** `/tmp/ready` 파일을 만들며 준비를 끝내는 서비스이고, `app` 은 `db` 가 준비돼야 의미가 있는 서비스입니다. 지금은 `db` 에 `healthcheck` 가 없어 도커가 준비 여부를 알 수 없습니다. 다음 둘을 적어 올리세요. (1) `db` 의 `healthcheck`: `/tmp/ready` 파일이 있는지 검사하고(`test -f /tmp/ready`), 점검 간격은 1초로 합니다. (2) `app` 의 `depends_on` 이 `db` 가 healthy 가 될 때까지 기다리게 합니다. `docker compose up -d` 를 한 뒤 `docker compose ps` 에서 `db` 가 `healthy` 로 보이면 됩니다.', '`healthcheck` 에는 검사 명령·간격·재시도 횟수를 정하는 키가 있고, `depends_on` 은 서비스 이름 아래에 조건을 적는 긴 형태로 바꿔야 합니다. `condition` 에는 서비스가 healthy 가 될 때까지 기다리는 값(`service_healthy`)이 있습니다.', 'cd /tmp/work/q3
cat > compose.yaml <<''EOF''
services:
  db:
    image: alpine
    command: sh -c "sleep 5; touch /tmp/ready; sleep 3600"
    healthcheck:
      test: ["CMD", "test", "-f", "/tmp/ready"]
      interval: 1s
      retries: 20
  app:
    image: alpine
    command: sleep 3600
    depends_on:
      db:
        condition: service_healthy
EOF
docker compose up -d
docker compose ps

# healthcheck 의 test 가 0 으로 끝나면 healthy. depends_on 의 condition: service_healthy 가 그 상태를 기다린다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q3; cat > /tmp/work/q3/compose.yaml <<''EOF''\\nservices:\\n  db:\\n    image: alpine\\n    command: sh -c \\"sleep 5; touch /tmp/ready; sleep 3600\\"\\n  app:\\n    image: alpine\\n    command: sleep 3600\\n    depends_on:\\n      - db\\nEOF\\n"]', '["sh", "-c", "( cd /tmp/work/q3 && docker inspect -f \\"{{json .Config.Healthcheck.Test}}\\" $(docker compose ps -q db) | grep -q /tmp/ready ) && ( cd /tmp/work/q3 && [ \\"$(docker inspect -f \\"{{.State.Health.Status}}\\" $(docker compose ps -q db))\\" = healthy ] && [ \\"$(docker compose ps --status running -q app | wc -l)\\" = 1 ] ) && ( cd /tmp/work/q3 && docker compose config | grep -q \\"condition: service_healthy\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "db 의 healthcheck 가 /tmp/ready 를 검사한다", "cmd": ["sh", "-c", "cd /tmp/work/q3 && docker inspect -f \\"{{json .Config.Healthcheck.Test}}\\" $(docker compose ps -q db) | grep -q /tmp/ready"]}, {"label": "db 가 healthy 이고 app 이 실행 중이다", "cmd": ["sh", "-c", "cd /tmp/work/q3 && [ \\"$(docker inspect -f \\"{{.State.Health.Status}}\\" $(docker compose ps -q db))\\" = healthy ] && [ \\"$(docker compose ps --status running -q app | wc -l)\\" = 1 ]"]}, {"label": "app 이 db 의 healthy 를 기다리도록 적혀 있다", "cmd": ["sh", "-c", "cd /tmp/work/q3 && docker compose config | grep -q \\"condition: service_healthy\\""]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 4, 'unhealthy 상태: 점검 출력을 읽고 고치기', '`/tmp/work/q4` 의 `web` 은 실행 중인데 `docker compose ps` 의 상태에 `(unhealthy)` 가 붙어 있습니다. 이 서비스의 healthcheck 는 `cat /tmp/ok` 가 성공해야 healthy 가 되도록 적혀 있습니다. 컨테이너는 죽지 않았고 **점검이 실패하는 중**입니다. (1) 점검이 실패하며 남긴 **출력 메시지**를 찾아 `/tmp/q4.txt` 에 저장하세요. 출력은 `docker inspect` 의 `.State.Health.Log` 에 점검마다 `Output` 으로 쌓여 있습니다. (2) 컨테이너를 지우거나 compose.yaml 을 바꾸지 말고, 실행 중인 `web` 안에 `/tmp/ok` 파일을 만들어 `healthy` 로 바꾸세요.', '`docker inspect -f` 의 Go 템플릿으로 `.State.Health.Log` 를 꺼내 보세요(전체를 `json` 으로 찍으면 구조가 보입니다). 실행 중 컨테이너 안에서 명령을 실행하는 compose 명령은 앞 실습에서 이미 썼습니다.', 'cd /tmp/work/q4
docker compose ps
docker inspect -f ''{{json .State.Health.Log}}'' $(docker compose ps -q web)
docker inspect -f ''{{(index .State.Health.Log 0).Output}}'' $(docker compose ps -q web) > /tmp/q4.txt
cat /tmp/q4.txt
docker compose exec web touch /tmp/ok
sleep 3; docker compose ps

# Health.Log 에는 점검의 시작 시각·종료 코드·출력이 시간순(최대 5개)으로 남는다. index 0 은 가장 오래된 항목이고, 모두 같은 메시지다. 점검이 기대하는 파일을 만들어 주면 다음 점검부터 통과한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q4; cat > /tmp/work/q4/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: alpine\\n    command: sleep 3600\\n    healthcheck:\\n      test: [\\"CMD\\", \\"cat\\", \\"/tmp/ok\\"]\\n      interval: 1s\\n      timeout: 1s\\n      retries: 2\\nEOF\\ncd /tmp/work/q4 && docker compose up -d >/dev/null 2>&1; sleep 4; "]', '["sh", "-c", "( grep -q \\"/tmp/ok\\" /tmp/q4.txt && grep -qi ''no such file'' /tmp/q4.txt ) && ( cd /tmp/work/q4 && docker compose exec -T web test -f /tmp/ok ) && ( for i in $(seq 1 15); do [ \\"$(docker inspect -f ''{{.State.Health.Status}}'' $(cd /tmp/work/q4 && docker compose ps -q web) 2>/dev/null)\\" = healthy ] && exit 0; sleep 1; done; exit 1 ) && ( grep -q \\"/tmp/ok\\" /tmp/work/q4/compose.yaml && grep -q \\"retries: 2\\" /tmp/work/q4/compose.yaml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "저장한 출력이 /tmp/ok 를 열지 못했다는 메시지다", "cmd": ["sh", "-c", "grep -q \\"/tmp/ok\\" /tmp/q4.txt && grep -qi ''no such file'' /tmp/q4.txt"]}, {"label": "web 안에 /tmp/ok 가 있다", "cmd": ["sh", "-c", "cd /tmp/work/q4 && docker compose exec -T web test -f /tmp/ok"]}, {"label": "web 이 healthy 로 바뀌었다", "cmd": ["sh", "-c", "for i in $(seq 1 15); do [ \\"$(docker inspect -f ''{{.State.Health.Status}}'' $(cd /tmp/work/q4 && docker compose ps -q web) 2>/dev/null)\\" = healthy ] && exit 0; sleep 1; done; exit 1"]}, {"label": "compose.yaml 의 healthcheck 는 그대로다", "cmd": ["sh", "-c", "grep -q \\"/tmp/ok\\" /tmp/work/q4/compose.yaml && grep -q \\"retries: 2\\" /tmp/work/q4/compose.yaml"]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 5, 'healthy 가 될 때까지 기다렸다가 끝내기', '서비스를 백그라운드로 올리되, **healthcheck 가 있는 서비스가 모두 healthy 가 될 때까지 기다렸다가** 명령이 끝나도록 하는 옵션입니다. 배포 스크립트에서 "다 떴다"를 확인한 뒤 다음 단계로 넘어갈 때 씁니다. 빈칸을 채우세요.', '옵션 이름은 영어로 "기다린다"는 동사입니다.', NULL, NULL, '[]', 'fill', '["--wait", "--build", "--force-recreate", "--remove-orphans"]', NULL, '`--wait` 는 서비스가 running(healthcheck 가 있으면 healthy)이 될 때까지 기다린 뒤 끝납니다. `--build` 는 이미지를 다시 빌드하고, `--force-recreate` 는 변경이 없어도 컨테이너를 새로 만들며, `--remove-orphans` 는 파일에서 지운 서비스의 컨테이너를 정리합니다.', '[0]', 'docker compose up -d {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 6, 'healthcheck 가 있는 db 를 기다리는 시작 순서', '`app` 이 `depends_on: db: condition: service_healthy` 로 `db` 를 기다릴 때, `docker compose up -d` 가 일으키는 일을 **시간 순서**대로 놓으세요. (`db` 컨테이너는 만들어진 뒤 시작되고, 그다음에야 점검이 의미를 갖습니다.)', '"기다림"이 어느 단계 사이에 끼는지 생각해 보세요. `app` 은 `db` 의 상태가 정해지기 전에는 시작되지 않습니다.', NULL, NULL, '[]', 'order', '["`app` 컨테이너가 시작된다", "점검이 성공해 `db` 가 `healthy` 가 된다", "`db` 컨테이너가 만들어지고 시작된다", "`db` 의 healthcheck 가 주기적으로 실행되며 상태가 `starting` 이다"]', NULL, '`db` 가 시작되면 healthcheck 가 `interval` 마다 돌고 그동안 상태는 `starting` 입니다. 점검이 성공하면 `healthy` 가 되고, 그때서야 `condition: service_healthy` 를 기다리던 `app` 이 시작됩니다. 점검이 계속 실패해 `retries` 를 넘기면 `unhealthy` 가 되어 `app` 은 시작되지 않고 `up` 이 오류로 끝납니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 7, '소스를 고친 뒤 up --build 로 이미지 갱신', '`/tmp/work/q7` 은 `build: .` 로 `Dockerfile` 에서 이미지를 만드는 서비스 `app` 이 이미 올라와 있습니다. 이미지에는 `msg.txt` 가 `/msg.txt` 로 복사돼 있고 지금 내용은 `v1` 입니다. `msg.txt` 의 내용을 **`v2`** 로 바꾸고, **실행 중인 `app` 컨테이너의 `/msg.txt` 가 `v2` 를 보이게** 만드세요. (고친 뒤 확인은 컨테이너 안에서 합니다.)', '파일은 이미지를 **빌드할 때** 복사됩니다. 이미지를 다시 만들게 하는 옵션이 `docker compose up --help` 에 있습니다. 확인은 `docker compose exec app cat /msg.txt` 로 합니다.', 'cd /tmp/work/q7
echo v2 > msg.txt
docker compose up -d --build
docker compose exec app cat /msg.txt

# up 은 이미지가 이미 있으면 다시 빌드하지 않는다. --build 를 주면 Dockerfile 을 다시 빌드하고, 이미지가 바뀐 서비스의 컨테이너를 새로 만든다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q7; cat > /tmp/work/q7/Dockerfile <<''EOF''\\nFROM alpine\\nCOPY msg.txt /msg.txt\\nCMD [\\"sleep\\", \\"3600\\"]\\nEOF\\ncat > /tmp/work/q7/compose.yaml <<''EOF''\\nservices:\\n  app:\\n    build: .\\nEOF\\necho v1 > /tmp/work/q7/msg.txt; cd /tmp/work/q7 && docker compose up -d --build >/dev/null 2>&1; "]', '["sh", "-c", "( grep -qx v2 /tmp/work/q7/msg.txt ) && ( cd /tmp/work/q7 && [ \\"$(docker compose ps --status running -q app | wc -l)\\" = 1 ] ) && ( cd /tmp/work/q7 && [ \\"$(docker compose exec -T app cat /msg.txt)\\" = v2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "msg.txt 가 v2 다", "cmd": ["sh", "-c", "grep -qx v2 /tmp/work/q7/msg.txt"]}, {"label": "app 이 실행 중이다", "cmd": ["sh", "-c", "cd /tmp/work/q7 && [ \\"$(docker compose ps --status running -q app | wc -l)\\" = 1 ]"]}, {"label": "실행 중인 app 안의 /msg.txt 가 v2 다", "cmd": ["sh", "-c", "cd /tmp/work/q7 && [ \\"$(docker compose exec -T app cat /msg.txt)\\" = v2 ]"]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 8, '빌드 서비스에서 up -d 만 다시 하면', '`build: .` 로 이미지를 만드는 서비스가 있습니다. 이미 빌드해서 올라와 있는 상태에서 **Dockerfile 이 복사하는 소스 파일만 고치고** `docker compose up -d` (옵션 없음)를 하면 어떻게 될까요?', '`up` 은 이미지가 "없을 때" 와 "이미 있을 때"를 다르게 다룹니다. compose.yaml 자체는 바뀌지 않았다는 점도 생각해 보세요.', NULL, NULL, '[]', 'choice', '["소스 파일의 변경을 감지해 이미지를 다시 빌드하고 컨테이너를 새로 만든다", "이미지만 새로 빌드되고 실행 중인 컨테이너는 그대로 남는다", "이미지가 이미 있으므로 다시 빌드하지 않고, 컨테이너도 그대로여서 옛 소스가 계속 쓰인다", "이미지가 없다는 오류가 나며 멈춘다"]', 2, '`up` 은 이미지가 **없을 때만** 빌드하고, 있으면 그대로 씁니다. 설정도 바뀌지 않았으니 컨테이너도 다시 만들지 않습니다. 소스 변경을 반영하려면 `docker compose up -d --build`(또는 `docker compose build` 후 `up -d`)를 해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 9, '-f 로 두 파일을 병합한 결과 보기', '`/tmp/work/q9` 에는 기본 설정 `compose.yaml`(`MODE: dev`, `TZ: UTC`)과 운영용 덧씌우기 파일 `compose.prod.yaml`(`MODE: prod` 만 있음)이 있습니다. 두 파일을 **차례로 겹쳐서** 최종 구성이 어떻게 되는지 `docker compose config` 로 확인하고, 그 출력을 `/tmp/q9.txt` 에 저장하세요. 결과에는 `MODE` 가 `prod` 로, `TZ` 는 그대로 `UTC` 로 보여야 합니다. (서비스를 올리지는 않습니다.)', '`-f` 옵션은 여러 번 줄 수 있고 **뒤에 적은 파일이 앞 파일을 덮어씁니다**. 다만 `-f` 는 `config` 같은 하위 명령 **앞**에 붙입니다. 파일을 직접 합치지 말고 명령으로 병합 결과를 받으세요.', 'cd /tmp/work/q9
docker compose -f compose.yaml -f compose.prod.yaml config > /tmp/q9.txt
cat /tmp/q9.txt

# 맵(environment 등)은 키 단위로 병합된다: 겹친 MODE 는 뒤 파일 값(prod), 겹치지 않은 TZ 는 앞 파일 값이 남는다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q9; cat > /tmp/work/q9/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:alpine\\n    environment:\\n      MODE: dev\\n      TZ: UTC\\nEOF\\ncat > /tmp/work/q9/compose.prod.yaml <<''EOF''\\nservices:\\n  web:\\n    environment:\\n      MODE: prod\\nEOF\\n"]', '["sh", "-c", "( grep -q \\"MODE: prod\\" /tmp/q9.txt && ! grep -q \\"MODE: dev\\" /tmp/q9.txt ) && ( grep -q \\"TZ: UTC\\" /tmp/q9.txt && grep -q \\"image: nginx:alpine\\" /tmp/q9.txt ) && ( grep -q \\"MODE: dev\\" /tmp/work/q9/compose.yaml && ! grep -q TZ /tmp/work/q9/compose.prod.yaml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합 결과에 MODE 가 prod 로 나온다", "cmd": ["sh", "-c", "grep -q \\"MODE: prod\\" /tmp/q9.txt && ! grep -q \\"MODE: dev\\" /tmp/q9.txt"]}, {"label": "앞 파일의 TZ 와 이미지가 남아 있다", "cmd": ["sh", "-c", "grep -q \\"TZ: UTC\\" /tmp/q9.txt && grep -q \\"image: nginx:alpine\\" /tmp/q9.txt"]}, {"label": "원본 파일은 그대로다", "cmd": ["sh", "-c", "grep -q \\"MODE: dev\\" /tmp/work/q9/compose.yaml && ! grep -q TZ /tmp/work/q9/compose.prod.yaml"]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 10, 'override 에서 ports 를 적으면', '`compose.yaml` 의 `web` 은 `ports: ["8080:80"]` 이고, 덧씌우는 파일의 `web` 은 `ports: ["9090:80"]` 입니다. `docker compose -f compose.yaml -f 덧씌우는파일 config` 의 `web` 포트는 어떻게 될까요?', '앞 실습에서 `environment` 같은 **맵**은 키 단위로 겹쳤습니다. 포트처럼 **목록(리스트)** 은 어떻게 합쳐질지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["두 항목이 모두 남아 8080 과 9090 이 함께 공개된다", "9090 만 남는다(뒤 파일이 목록을 통째로 대체)", "8080 만 남는다(앞 파일이 우선)", "같은 컨테이너 포트 80 이라 병합 오류가 난다"]', 0, '`ports` 같은 목록은 **덮어쓰지 않고 이어 붙여** 합쳐집니다. 그래서 8080 과 9090 이 모두 공개됩니다. 기존 항목을 없애고 싶다면 override 파일에서 `ports: !override ["9090:80"]` 처럼 태그를 써야 합니다(Compose 버전이 이 태그를 지원해야 합니다). 맵(`environment`)은 키 단위로 합쳐지고 겹친 키만 뒤 파일 값이 이깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 11, '덧씌우기 파일이 적용되지 않는다', '`/tmp/work/q11` 에는 `compose.yaml`(`LOG_LEVEL: info`)과 개발용 덧씌우기 파일이 있습니다. 덧씌우기 파일은 `LOG_LEVEL: debug` 로 바꿔야 하는데, `-f` 없이 `docker compose up -d` 를 해도 컨테이너의 `LOG_LEVEL` 이 계속 `info` 입니다. 덧씌우기 파일의 **이름이 잘못돼서 자동으로 읽히지 않기** 때문입니다. `-f` 옵션은 쓰지 말고, 파일 이름을 고쳐 `docker compose up -d` 만으로 `web` 컨테이너의 `LOG_LEVEL` 이 `debug` 가 되게 하세요.', '`ls /tmp/work/q11` 로 파일 이름을 보세요. `-f` 를 주지 않으면 compose 는 `compose.yaml` 과 짝이 되는 **정해진 이름의 두 번째 파일**만 자동으로 읽습니다. `docker compose config` 로 어떤 값이 적용되는지 볼 수 있습니다.', 'cd /tmp/work/q11
ls
docker compose config | grep LOG_LEVEL
mv compose.overide.yaml compose.override.yaml
docker compose config | grep LOG_LEVEL
docker compose up -d
docker compose exec web printenv LOG_LEVEL

# -f 없이 up 하면 compose.yaml 과 compose.override.yaml 을 자동으로 읽어 병합한다. 파일 이름의 오타(overide)는 조용히 무시된다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q11; cat > /tmp/work/q11/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: nginx:alpine\\n    environment:\\n      LOG_LEVEL: info\\nEOF\\ncat > /tmp/work/q11/compose.overide.yaml <<''EOF''\\nservices:\\n  web:\\n    environment:\\n      LOG_LEVEL: debug\\nEOF\\n"]', '["sh", "-c", "( [ -f /tmp/work/q11/compose.override.yaml ] || [ -f /tmp/work/q11/compose.override.yml ] ) && ( cd /tmp/work/q11 && [ \\"$(docker compose ps --status running -q web | wc -l)\\" = 1 ] ) && ( cd /tmp/work/q11 && [ \\"$(docker compose exec -T web printenv LOG_LEVEL)\\" = debug ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "자동으로 읽히는 이름의 override 파일이 있다", "cmd": ["sh", "-c", "[ -f /tmp/work/q11/compose.override.yaml ] || [ -f /tmp/work/q11/compose.override.yml ]"]}, {"label": "web 이 실행 중이다", "cmd": ["sh", "-c", "cd /tmp/work/q11 && [ \\"$(docker compose ps --status running -q web | wc -l)\\" = 1 ]"]}, {"label": "web 안의 LOG_LEVEL 이 debug 다", "cmd": ["sh", "-c", "cd /tmp/work/q11 && [ \\"$(docker compose exec -T web printenv LOG_LEVEL)\\" = debug ]"]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 552, 12, '메모리·CPU 제한 걸기', '`/tmp/work/q12` 의 `web` 은 자원 제한 없이 올라와 있습니다. 한 서비스가 호스트 자원을 다 쓰지 못하도록 **메모리 64MB, CPU 0.5개**로 제한하세요. `compose.yaml` 의 `web` 에 제한을 적고 `docker compose up -d` 로 반영하면 설정이 바뀐 컨테이너가 새로 만들어집니다. 실제 반영 여부는 `docker inspect` 의 `HostConfig` 에서 `Memory`(바이트)와 `NanoCpus`(CPU 개수 × 10억)로 확인합니다.', 'compose 파일의 서비스 속성 중 메모리와 CPU 를 제한하는 키를 Compose 문서의 services 항목에서 찾아 보세요. 메모리 단위 표기도 거기 있습니다.', 'cd /tmp/work/q12
cat > compose.yaml <<''EOF''
services:
  web:
    image: alpine
    command: sleep 3600
    mem_limit: 64m
    cpus: 0.5
EOF
docker compose up -d
docker inspect -f ''{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}'' $(docker compose ps -q web)

# 67108864 = 64 * 1024 * 1024, 500000000 = 0.5 * 10억. 설정을 바꾸고 up -d 하면 컨테이너가 새로 만들어진다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker network prune -f >/dev/null 2>&1; docker rmi -f q6-app >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work/q12; cat > /tmp/work/q12/compose.yaml <<''EOF''\\nservices:\\n  web:\\n    image: alpine\\n    command: sleep 3600\\nEOF\\ncd /tmp/work/q12 && docker compose up -d >/dev/null 2>&1; "]', '["sh", "-c", "( cd /tmp/work/q12 && [ \\"$(docker compose ps --status running -q web | wc -l)\\" = 1 ] ) && ( cd /tmp/work/q12 && [ \\"$(docker inspect -f \\"{{.HostConfig.Memory}}\\" $(docker compose ps -q web))\\" = 67108864 ] ) && ( cd /tmp/work/q12 && [ \\"$(docker inspect -f \\"{{.HostConfig.NanoCpus}}\\" $(docker compose ps -q web))\\" = 500000000 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "web 이 실행 중이다", "cmd": ["sh", "-c", "cd /tmp/work/q12 && [ \\"$(docker compose ps --status running -q web | wc -l)\\" = 1 ]"]}, {"label": "메모리 제한이 64MB 다", "cmd": ["sh", "-c", "cd /tmp/work/q12 && [ \\"$(docker inspect -f \\"{{.HostConfig.Memory}}\\" $(docker compose ps -q web))\\" = 67108864 ]"]}, {"label": "CPU 제한이 0.5 개다", "cmd": ["sh", "-c", "cd /tmp/work/q12 && [ \\"$(docker inspect -f \\"{{.HostConfig.NanoCpus}}\\" $(docker compose ps -q web))\\" = 500000000 ]"]}]', '[{"title": "Compose 네트워크", "url": "https://docs.docker.com/reference/compose-file/networks/"}, {"title": "healthcheck / depends_on", "url": "https://docs.docker.com/reference/compose-file/services/#healthcheck"}, {"title": "여러 Compose 파일 병합", "url": "https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 552 AND order_index = 12);
