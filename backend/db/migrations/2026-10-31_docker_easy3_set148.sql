-- 도커 세트 148. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set148.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 148, 'compose 운영 명령, Dockerfile 한 줄, 자원 제한, 상태 점검 한 줄씩', '도커를 운영하며 자주 쓰는 명령과 Dockerfile 줄을 한 개념씩 쉬운 문제로 반복합니다. docker compose 의 ps·logs·stop 과 down 의 차이·down -v 의 위험·restart·exec·config, .dockerignore 와 .gitignore 의 차이, Dockerfile 의 ENV·WORKDIR·USER, --memory 한도와 OOMKilled(종료 코드 137), docker stats --no-stream, healthcheck 와 (healthy) 를 짧은 객관식·빈칸·순서 문제로 익히고, compose 서비스 점검, 볼륨은 남기고 내렸다 올리기, 메모리 부족 컨테이너 조사, .dockerignore 로 빌드 정리의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 148);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🧯' WHERE id = 148;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 1, 'compose ps', '`docker compose ps` 는 `docker ps` 와 무엇이 다를까요?', 'compose 로 띄운 묶음만 따로 봐요.', NULL, NULL, '[]', 'choice', '["내 컴퓨터의 모든 컨테이너를 보여 준다", "이미지 목록을 보여 준다", "현재 compose 프로젝트의 서비스 컨테이너만 서비스 이름과 상태로 보여 준다", "볼륨 목록을 보여 준다"]', 2, '여러 컨테이너로 이루어진 앱의 상태를 한눈에 볼 때 씁니다. 멈춘 것까지 보려면 `-a` 를 붙여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 2, 'compose logs', '`docker compose logs --tail 20 web` 에서 `web` 은 무엇일까요?', 'compose 파일에 적힌 이름이에요.', NULL, NULL, '[]', 'choice', '["컨테이너의 ID", "compose 파일에 정의된 서비스의 이름", "이미지 이름", "네트워크 이름"]', 1, '컨테이너 이름(`프로젝트-web-1`)이 아니라 서비스 이름을 씁니다. 서비스 이름을 생략하면 모든 서비스의 로그가 섞여 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 3, 'stop 과 down', '`docker compose stop` 과 `docker compose down` 의 차이로 알맞은 것은 무엇일까요?', '하나는 멈추기만, 하나는 정리까지 해요.', NULL, NULL, '[]', 'choice', '["`stop` 은 컨테이너를 멈추기만 하고 남겨 두며, `down` 은 컨테이너와 네트워크를 삭제한다 (이름 붙은 볼륨은 남는다)", "둘은 완전히 같다", "`stop` 은 볼륨까지 삭제한다", "`down` 은 이미지를 삭제한다"]', 0, '다시 시작하려면 `stop` 한 것은 `start`, `down` 한 것은 `up` 을 씁니다. 볼륨의 데이터는 `down` 으로 지워지지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 4, 'down -v 의 위험', '`docker compose down -v` 를 실행하면 무엇이 달라질까요?', 'v 는 volume 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["아무 차이가 없다", "이미지도 함께 삭제된다", "로그만 지워진다", "컨테이너와 네트워크뿐 아니라 compose 가 만든 볼륨까지 삭제한다 (데이터가 사라진다)"]', 3, '데이터베이스의 볼륨이 지워질 수 있어서 운영 환경에서는 특히 조심해야 합니다. 실행하기 전에 지울 볼륨이 무엇인지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 5, '서비스 하나만 재시작', '`docker compose restart a` 는 무엇을 할까요?', '서비스 이름을 지정했어요.', NULL, NULL, '[]', 'choice', '["모든 서비스를 다시 시작한다", "서비스 `a` 를 삭제한다", "서비스 `a` 의 컨테이너만 다시 시작한다", "이미지를 다시 받는다"]', 2, '서비스 이름을 생략하면 모두 재시작합니다. 설정(compose 파일)을 바꾼 경우에는 `up -d` 로 다시 만들어야 반영돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 6, 'compose exec', '`docker compose exec web sh` 는 무엇을 할까요?', '이미 떠 있는 서비스 안으로 들어가요.', NULL, NULL, '[]', 'choice', '["`web` 서비스를 새로 만든다", "실행 중인 `web` 서비스의 컨테이너 안에서 쉘을 연다", "`web` 이미지를 빌드한다", "`web` 서비스를 삭제한다"]', 1, '`docker exec` 와 같지만 컨테이너 이름 대신 서비스 이름을 쓸 수 있어 편합니다. 서비스가 떠 있지 않으면 실패해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 7, 'compose config', '`docker compose config` 는 무엇을 보여 줄까요?', '파일과 환경 변수를 합친 최종 모습이에요.', NULL, NULL, '[]', 'choice', '["환경 변수까지 채워진 최종 compose 설정과 문법 검사 결과", "실행 중인 컨테이너의 CPU 사용량", "컨테이너의 로그", "설치된 도커의 버전"]', 0, '설정이 의도대로 해석되는지 확인할 때 씁니다. `--services` 를 붙이면 서비스 이름만 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 8, '.dockerignore', '`.dockerignore` 파일에 `secret.txt` 를 적으면 어떤 일이 일어날까요?', '빌드에 쓸 파일 목록에서 빠져요.', NULL, NULL, '[]', 'choice', '["빌드가 실패한다", "Git 이 그 파일을 추적하지 않는다", "이미지에서 그 파일이 암호화된다", "`docker build` 때 그 파일이 빌드 대상에서 제외되어 이미지에 들어가지 않는다"]', 3, '비밀 파일, `node_modules`, `.git` 같은 불필요한 파일을 빼면 빌드가 빨라지고 이미지도 작아집니다. `.gitignore` 와는 별개의 파일이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 9, 'ENV 의 쓰임', 'Dockerfile 의 `ENV APP_MODE=prod` 는 무엇을 할까요?', '컨테이너 안의 환경 변수 기본값이에요.', NULL, NULL, '[]', 'choice', '["이미지의 이름을 정한다", "호스트의 환경 변수를 바꾼다", "컨테이너 안에서 `APP_MODE` 환경 변수의 기본값을 `prod` 로 정한다 (`docker run -e` 로 덮어쓸 수 있다)", "컨테이너를 prod 모드로 빌드만 한다"]', 2, '기본값을 이미지에 넣어 두고 실행할 때 필요하면 `-e APP_MODE=dev` 처럼 바꿉니다. 비밀번호는 이미지에 넣지 마세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 10, 'WORKDIR 의 쓰임', 'Dockerfile 의 `WORKDIR /srv/app` 은 무엇을 할까요?', '`cd` 와 비슷하지만 폴더도 만들어 줘요.', NULL, NULL, '[]', 'choice', '["호스트의 `/srv/app` 을 컨테이너에 연결한다", "이후의 `RUN`, `COPY`, `CMD` 가 실행되는 기본 작업 폴더를 `/srv/app` 로 정한다 (없으면 만든다)", "이미지의 이름을 정한다", "컨테이너를 재시작한다"]', 1, '`RUN cd 폴더` 는 그 줄에서만 유효해서 다음 줄에는 영향이 없습니다. 폴더를 바꾸려면 `WORKDIR` 을 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 11, 'USER 의 쓰임', 'Dockerfile 에 `USER worker` 를 쓰는 이유는 무엇일까요?', '컨테이너 안에서 누구 권한으로 실행할지 정해요.', NULL, NULL, '[]', 'choice', '["컨테이너 안의 프로그램을 root 가 아닌 일반 사용자 권한으로 실행해 보안 위험을 줄이려고", "빌드 속도를 높이려고", "이미지의 크기를 줄이려고", "호스트의 사용자를 만들려고"]', 0, '기본은 root 로 실행됩니다. 프로그램이 해킹당해도 피해 범위를 줄이려면 일반 사용자로 실행하는 것이 좋아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 12, '메모리 한도를 넘으면', '`docker run --memory=10m` 로 제한한 컨테이너가 10MB 를 넘게 쓰려 하면 어떻게 될까요?', '커널이 강제로 정리해요.', NULL, NULL, '[]', 'choice', '["한도가 자동으로 늘어난다", "컨테이너가 일시 정지된다", "아무 일도 일어나지 않는다", "커널이 프로세스를 강제 종료한다 (OOMKilled=true, 종료 코드 137)"]', 3, '`docker inspect -f ''{{.State.OOMKilled}}'' 이름` 으로 확인할 수 있습니다. 종료 코드 137 은 강제 종료(KILL)를 뜻해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 13, 'docker stats', '`docker stats` 는 무엇을 보여 줄까요?', '실시간으로 자원을 보여 줘요.', NULL, NULL, '[]', 'choice', '["컨테이너의 로그", "이미지의 크기", "실행 중인 컨테이너의 CPU, 메모리, 네트워크 사용량 (실시간으로 갱신)", "컨테이너의 환경 변수"]', 2, '`--no-stream` 을 붙이면 한 번만 출력하고 끝납니다. `MEM USAGE / LIMIT` 로 한도 대비 사용량을 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 14, 'healthcheck 와 healthy', '컨테이너가 `Up` 이고 `docker ps` 의 상태에 `(healthy)` 가 붙었습니다. 무슨 뜻일까요?', '실행 중인 것과 정상인 것은 다른 이야기예요.', NULL, NULL, '[]', 'choice', '["프로세스가 방금 시작되었다", "healthcheck 로 정한 점검 명령이 성공하고 있다 (프로세스가 떠 있는 것보다 한 단계 더 확인한 것이다)", "디스크 점검이 끝났다", "컨테이너가 삭제될 예정이다"]', 1, '실패가 이어지면 `(unhealthy)` 로 바뀝니다. 앱이 떠 있어도 응답하지 않는 상황을 잡을 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 15, 'compose 서비스 상태', '현재 compose 프로젝트의 **서비스 상태**를 보는 명령입니다. 빈칸을 채우세요.', '`docker ps` 와 같은 이름이에요.', NULL, NULL, '[]', 'fill', '["ps", "list", "status", "show"]', NULL, '서비스 이름과 상태(`running`, `exited`)와 포트가 나옵니다.', '[0]', 'docker compose {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 16, '로그 끝부분만', '서비스 `web` 의 로그에서 **마지막 20줄만** 보는 옵션입니다. 빈칸을 채우세요.', '꼬리를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--tail", "--last", "--head", "--recent"]', NULL, '`-f` 를 함께 쓰면 최근 20줄부터 계속 따라갑니다.', '[0]', 'docker compose logs {0} 20 web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 17, '멈추기만 하기', '컨테이너를 **삭제하지 않고 멈추기만** 하는 명령입니다. 빈칸을 채우세요.', '"멈추다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["stop", "pause", "halt", "end"]', NULL, '`stop` 한 컨테이너는 `docker compose start` 로 다시 시작할 수 있습니다. `pause` 는 프로세스를 얼리는 다른 명령이에요.', '[0]', 'docker compose {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 18, '볼륨까지 지우기', '`down` 할 때 **볼륨까지** 지우는 옵션입니다. 빈칸을 채우세요.', 'volume 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-v", "-f", "-a", "-d"]', NULL, '볼륨의 데이터가 지워지니 신중하게 쓰세요. 보통은 `down` 만 쓰고 데이터는 남겨 둡니다.', '[0]', 'docker compose down {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 19, '서비스 안에서 명령 실행', '실행 중인 서비스 `web` 안에서 **쉘을 여는** 명령입니다. 빈칸을 채우세요.', '"실행하다(execute)"의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["exec", "enter", "run-in", "shell"]', NULL, '`docker compose run` 은 새 컨테이너를 만드는 다른 명령입니다. 이미 떠 있는 서비스에는 `exec` 를 쓰세요.', '[0]', 'docker compose {0} web sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 20, '최종 설정 확인', '환경 변수까지 채워진 **최종 compose 설정**을 확인하는 명령입니다. 빈칸을 채우세요.', '"설정"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["config", "check", "show", "render"]', NULL, '파일에 문법 오류가 있으면 여기서 먼저 알려 줍니다. 적용하기 전에 한 번 돌려 보세요.', '[0]', 'docker compose {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 21, '빌드에서 제외하는 파일', '빌드할 때 **제외할 파일**을 적는 파일의 이름입니다. 빈칸을 채우세요.', 'Docker 의 이름이 들어가요.', NULL, NULL, '[]', 'fill', '[".dockerignore", ".gitignore", ".dockerfile", "ignore.docker"]', NULL, '`.gitignore` 는 Git 용이라 도커 빌드에는 영향을 주지 않습니다. 빌드 컨텍스트의 최상위에 두세요.', '[0]', 'echo "node_modules" >> {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 22, '작업 폴더 정하기', 'Dockerfile 에서 이후 명령이 실행될 **작업 폴더**를 `/srv/app` 으로 정하는 줄입니다. 빈칸을 채우세요.', '"작업 디렉터리"의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["WORKDIR", "CD", "FOLDER", "PWD"]', NULL, '`WORKDIR` 로 정한 폴더는 없으면 자동으로 만들어집니다.', '[0]', '{0} /srv/app', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 23, '일반 사용자로 실행', 'Dockerfile 에서 프로그램을 `worker` 사용자로 **실행하게 하는** 줄입니다. 빈칸을 채우세요.', '"사용자"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["USER", "RUNAS", "LOGIN", "SU"]', NULL, '`USER` 앞에 `RUN adduser ...` 로 사용자를 먼저 만들어 두어야 합니다.', '[0]', '{0} worker', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 24, '메모리 한도 정하기', '컨테이너의 **메모리 한도**를 256MB 로 정하는 옵션입니다. 빈칸을 채우세요.', '"기억 장치"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["memory", "mem-limit", "ram", "size"]', NULL, '한도를 넘으면 컨테이너가 강제 종료(OOM)될 수 있습니다. `--cpus=0.5` 로 CPU 도 제한할 수 있어요.', '[0]', 'docker run --{0}=256m alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 25, '한 번만 출력', '`docker stats` 를 **한 번만 출력하고 끝내는** 옵션입니다. 빈칸을 채우세요.', '"흐름 없음"을 뜻해요.', NULL, NULL, '[]', 'fill', '["--no-stream", "--once", "--single", "--static"]', NULL, '옵션이 없으면 계속 갱신되며 Ctrl+C 로 끝내야 합니다. 스크립트에서는 `--no-stream` 이 필수예요.', '[0]', 'docker stats {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 26, 'compose 서비스 상태 점검하기', 'compose 로 띄운 서비스에 문제가 있을 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → 로그 → 안에서 확인 → 재시작 순서예요.', NULL, NULL, '[]', 'order', '["`docker compose ps` 로 서비스의 상태를 본다", "`docker compose logs --tail 20 서비스` 로 최근 로그를 본다", "`docker compose exec 서비스 sh` 로 안에 들어가 상태를 확인한다", "원인을 고치고 `docker compose restart 서비스` 로 다시 시작한다"]', NULL, '상태에서 문제 있는 서비스를 찾고, 로그로 이유를 보고, 필요하면 안에서 확인하는 순서가 효율적입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 27, '볼륨은 남기고 내렸다 올리기', '데이터는 남기고 서비스를 내렸다가 다시 올리는 순서입니다. 순서에 맞게 놓아 보세요.', '내리기 → 볼륨 확인 → 올리기 → 데이터 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker compose down` 으로 서비스를 내린다 (`-v` 는 쓰지 않는다)", "`docker volume ls` 로 볼륨이 남아 있는지 확인한다", "`docker compose up -d` 로 다시 올린다", "서비스 안에서 데이터가 그대로 있는지 확인한다"]', NULL, '`-v` 를 붙이면 볼륨이 지워져 데이터가 사라집니다. 평소에는 `down` 만 쓰세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 28, '메모리 부족으로 죽은 컨테이너 조사', '컨테이너가 이유 없이 종료됐을 때 메모리 부족인지 조사하는 순서입니다. 순서에 맞게 놓아 보세요.', '종료 코드 → OOM 여부 → 사용량 → 한도 조정 순서예요.', NULL, NULL, '[]', 'order', '["`docker ps -a` 로 `Exited (137)` 인지 확인한다", "`docker inspect -f ''{{.State.OOMKilled}}'' 이름` 으로 메모리 부족인지 확인한다", "`docker stats --no-stream` 으로 평소 메모리 사용량을 본다", "`--memory` 한도를 올리거나 앱의 메모리 사용을 줄이고 다시 실행한다"]', NULL, '137 은 강제 종료를 뜻하지만 메모리 부족 외의 이유도 있으니 `OOMKilled` 값으로 확정하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 29, '.dockerignore 로 빌드 정리하기', '비밀 파일을 이미지에서 빼는 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 적기 → 빌드 → 이미지 확인 순서예요.', NULL, NULL, '[]', 'order', '["빌드 폴더에서 이미지에 들어가면 안 되는 파일(비밀, 불필요한 폴더)을 찾는다", "`.dockerignore` 에 그 파일 이름을 적는다", "`docker build -t myapp .` 로 이미지를 다시 만든다", "`docker run --rm myapp ls /app` 로 제외된 파일이 없는지 확인한다"]', NULL, '이미 이미지에 들어간 비밀은 새로 만든 이미지로 교체하고, 비밀이 유출됐다면 값을 바꾸는 것이 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 29);
