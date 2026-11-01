-- 도커 세트 142. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set142.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 142, '볼륨, 네트워크, 이미지 만들기, 정리 한 줄씩', '도커 운영에 자주 쓰는 명령을 한 개념씩 쉬운 문제로 반복합니다. 볼륨과 바인드 마운트의 차이, 컨테이너를 지워도 남는 데이터, 사용자 정의 네트워크에서 이름으로 통신하기와 기본 네트워크의 한계, 컨테이너 안의 localhost, docker build 의 빌드 컨텍스트와 Dockerfile 줄 순서(캐시), tag·push, --restart unless-stopped, inspect·cp·logs --tail·system df, system prune 의 주의점을 짧은 객관식·빈칸·순서 문제로 익히고, 볼륨으로 데이터 지키기, 네트워크 연결, 이미지 빌드, 디스크 정리의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 142);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🚢' WHERE id = 142;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 1, '볼륨은 무엇일까', '도커의 볼륨(volume)은 무엇일까요?', '컨테이너가 사라져도 남겨 두고 싶은 데이터를 보관하는 곳이에요.', NULL, NULL, '[]', 'choice', '["컨테이너 안의 임시 메모리", "이미지를 내려받는 레지스트리", "컨테이너와 별개로 도커가 관리하는 저장 공간", "컨테이너의 CPU 사용량"]', 2, '볼륨에 쓴 데이터는 컨테이너를 지워도 남습니다. `docker volume ls` 로 목록을 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 2, '볼륨을 쓰는 이유', '데이터베이스 컨테이너에 볼륨을 연결하는 가장 큰 이유는 무엇일까요?', '컨테이너를 지웠다 다시 만들 때를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["컨테이너가 더 빨리 시작되게 하려고", "컨테이너를 지우고 새로 만들어도 데이터가 남아 있게 하려고", "이미지의 크기를 줄이려고", "컨테이너가 포트를 쓰지 않게 하려고"]', 1, '볼륨 없이 쓴 데이터는 컨테이너와 함께 사라집니다. 업데이트로 컨테이너를 교체할 때도 볼륨이 있으면 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 3, '볼륨과 바인드 마운트', '`-v data:/data` 와 `-v /srv/data:/data` 의 차이로 알맞은 것은 무엇일까요?', '왼쪽 모양이 이름인지 경로인지 보세요.', NULL, NULL, '[]', 'choice', '["앞은 이름이 있는 볼륨(도커가 관리), 뒤는 호스트의 특정 폴더를 그대로 연결(바인드 마운트)", "둘은 완전히 같다", "앞은 호스트 폴더, 뒤는 도커 볼륨이다", "둘 다 이미지 안에 파일을 만든다"]', 0, '왼쪽이 `/` 로 시작하는 경로이면 호스트 폴더를 그대로 연결하고, 이름이면 도커가 관리하는 볼륨입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 4, '컨테이너끼리 이름으로 통신', '같은 사용자 정의 네트워크에 있는 컨테이너 `db` 에 다른 컨테이너가 접속하려면 어떻게 부를까요?', '이름으로 찾아 주는 기능이 있어요.', NULL, NULL, '[]', 'choice', '["IP 주소를 매번 직접 찾아야만 한다", "`localhost` 로 부른다", "컨테이너 ID 의 앞 두 글자로 부른다", "컨테이너 이름 `db` 를 호스트 이름처럼 쓴다"]', 3, '사용자 정의 네트워크에서는 도커가 컨테이너 이름을 주소로 풀어 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 5, '기본 네트워크에서는', '네트워크를 따로 만들지 않고 기본(bridge) 네트워크에서 `docker run` 한 두 컨테이너가 서로 이름으로 접속하려 하면 어떻게 될까요?', '이름 풀이는 사용자 정의 네트워크에서만 돼요.', NULL, NULL, '[]', 'choice', '["항상 성공한다", "컨테이너가 자동으로 재시작한다", "이름을 찾지 못해 실패한다 (`bad address` 같은 오류)", "이미지가 새로 받아진다"]', 2, '이름으로 통신하려면 `docker network create` 로 네트워크를 만들고 두 컨테이너를 모두 그 네트워크에 연결하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 6, '컨테이너 안의 localhost', '웹 컨테이너 안의 앱이 `localhost:5432` 로 DB 에 접속하려는데 DB 는 다른 컨테이너에 있습니다. 결과는 어떨까요?', 'localhost 는 "나 자신"을 뜻해요.', NULL, NULL, '[]', 'choice', '["`localhost` 는 같은 서버의 모든 컨테이너를 가리켜서 접속된다", "`localhost` 는 웹 컨테이너 자신을 가리켜서 접속이 안 된다. DB 컨테이너의 이름을 써야 한다", "자동으로 DB 컨테이너를 찾아 준다", "호스트 컴퓨터의 DB 로 접속된다"]', 1, '컨테이너마다 자기만의 `localhost` 가 있습니다. 다른 컨테이너는 같은 네트워크에서 그 컨테이너의 이름으로 부르세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 7, '빌드 마지막의 점', '`docker build -t myapp:1.0 .` 끝의 `.` 은 무엇을 뜻할까요?', '빌드에 쓸 파일들이 어디 있는지 알려 줘요.', NULL, NULL, '[]', 'choice', '["빌드에 쓸 파일들의 위치(빌드 컨텍스트), 즉 현재 폴더", "이미지 이름의 마지막 글자", "빌드가 끝났다는 표시", "태그를 생략한다는 표시"]', 0, '`.` 대신 `Dockerfile` 같은 파일 이름을 쓰면 폴더가 아니라서 오류가 납니다. `-f` 로 Dockerfile 의 이름을 따로 줄 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 8, 'Dockerfile 의 줄 순서', 'Dockerfile 에서 의존성 설치(`RUN npm install`)를 소스 복사(`COPY . .`)보다 먼저 쓰는 이유는 무엇일까요?', '자주 바뀌는 줄이 뒤에 오면 앞의 결과를 재사용해요.', NULL, NULL, '[]', 'choice', '["소스가 먼저 있으면 설치가 안 되기 때문이다", "이미지의 크기가 항상 커지기 때문이다", "문법상 항상 그 순서여야 하기 때문이다", "소스만 바뀌었을 때 앞 단계(설치)의 캐시를 다시 쓰기 위해"]', 3, '도커는 줄마다 결과를 캐시합니다. 자주 바뀌는 줄을 뒤에 둘수록 빌드가 빨라져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 9, 'docker tag 는 무엇일까', '`docker tag myapp:1.0 myapp:latest` 는 무엇을 할까요?', '이미지를 복사하는 것이 아니라 이름을 하나 더 붙여요.', NULL, NULL, '[]', 'choice', '["이미지를 새로 빌드한다", "이미지를 레지스트리에 올린다", "같은 이미지에 이름(태그)을 하나 더 붙인다 (이미지가 복사되지는 않는다)", "이미지를 삭제한다"]', 2, '두 이름은 같은 이미지 ID 를 가리킵니다. `docker images` 로 보면 두 이름의 이미지 ID 가 같아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 10, 'push 하기 전에', '이미지를 레지스트리에 올리려면(`docker push`) 보통 무엇이 필요할까요?', '이름에 어디로 보낼지가 들어가야 해요.', NULL, NULL, '[]', 'choice', '["컨테이너를 먼저 삭제해야 한다", "레지스트리 주소가 포함된 이미지 이름과 로그인(`docker login`)", "이미지 이름이 `latest` 여야 한다", "아무것도 필요 없다"]', 1, '이름이 `레지스트리/계정/이미지:태그` 모양이어야 어디로 보낼지 알 수 있습니다. 권한이 없으면 `denied` 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 11, 'restart 정책', '`docker run --restart unless-stopped` 는 무엇을 뜻할까요?', '직접 멈추지 않는 한 계속 살려 두는 설정이에요.', NULL, NULL, '[]', 'choice', '["컨테이너가 죽거나 도커/서버가 재시작되면 다시 시작하고, 사람이 직접 멈춘 경우에는 그대로 둔다", "컨테이너를 절대 시작하지 않는다", "한 번 종료되면 영원히 삭제한다", "이미지를 매번 다시 받는다"]', 0, '서비스용 컨테이너에는 `unless-stopped` 나 `always` 를 흔히 씁니다. 적용됐는지는 `docker inspect` 로 확인할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 12, 'docker inspect', '`docker inspect web` 은 무엇을 보여 줄까요?', '자세한 설정 전체를 JSON 으로 알려 줘요.', NULL, NULL, '[]', 'choice', '["컨테이너가 쓴 로그만", "컨테이너 안의 파일 목록", "이미지의 변경 이력만", "컨테이너의 자세한 설정과 상태(네트워크, 마운트, 환경 변수 등)를 JSON 으로"]', 3, '원하는 값만 보려면 `-f` 로 포맷을 줍니다. 예: `docker inspect -f ''{{.HostConfig.RestartPolicy.Name}}'' web`.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 13, 'docker cp', '`docker cp web:/etc/hosts ./hosts` 는 무엇을 할까요?', 'cp 는 copy 예요. 방향은 앞에서 뒤로예요.', NULL, NULL, '[]', 'choice', '["호스트의 파일을 컨테이너로 복사한다", "컨테이너를 복제한다", "컨테이너 `web` 안의 파일을 호스트의 현재 폴더로 복사한다", "파일을 삭제한다"]', 2, '앞쪽이 원본, 뒤쪽이 복사 위치입니다. 호스트에서 컨테이너로 보내려면 두 인자의 순서를 바꾸세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 14, 'system prune 주의', '`docker system prune` 을 실행하면 어떤 일이 일어날까요?', '쓰지 않는 것들을 한꺼번에 정리해요. 확인 질문이 나옵니다.', NULL, NULL, '[]', 'choice', '["실행 중인 컨테이너를 모두 멈춘다", "멈춘 컨테이너, 쓰지 않는 네트워크, 이름 없는 이미지 등을 한꺼번에 지운다 (볼륨은 기본에서 제외)", "모든 이미지를 삭제한다", "아무것도 지우지 않는다"]', 1, '지우기 전에 `docker ps -a` 와 `docker system df` 로 무엇이 있는지 확인하세요. 볼륨까지 지우려면 별도 옵션이 필요하니 데이터 유실에 조심해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 15, '볼륨 만들기', '`data` 라는 이름의 **볼륨을 만드는** 명령입니다. 빈칸을 채우세요.', '"만들다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["create", "make", "new", "add"]', NULL, '`docker volume create` 로 미리 만들 수도 있고, `-v data:/data` 로 실행하면서 자동으로 만들 수도 있습니다.', '[0]', 'docker volume {0} data', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 16, '볼륨 연결 경로', '볼륨 `data` 를 컨테이너 안의 **`/data` 에 연결**하려고 합니다. 빈칸을 채우세요.', '컨테이너 안의 경로는 슬래시로 시작해요.', NULL, NULL, '[]', 'fill', '["/data", "data", "./data", "~data"]', NULL, '오른쪽은 컨테이너 안의 절대 경로여야 합니다. 상대 경로를 쓰면 오류가 나요.', '[0]', 'docker run -v data:{0} alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 17, '네트워크 만들기', '컨테이너끼리 이름으로 통신할 **네트워크를 만드는** 명령입니다. 빈칸을 채우세요.', '"통신망"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["network", "net", "link", "bridge"]', NULL, '`docker network create mynet` 으로 만든 뒤 컨테이너를 그 네트워크에 붙입니다. `docker network ls` 로 목록을 볼 수 있어요.', '[0]', 'docker {0} create mynet', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 18, '네트워크에 붙이기', '컨테이너를 `mynet` 네트워크에 **붙여서 실행**하는 옵션입니다. 빈칸을 채우세요.', '"네트워크"의 영어 단어 그대로예요.', NULL, NULL, '[]', 'fill', '["network", "net", "link", "join"]', NULL, '같은 네트워크에 붙인 컨테이너끼리는 컨테이너 이름으로 서로를 찾을 수 있습니다.', '[0]', 'docker run --{0} mynet alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 19, '이미지 만들기', '현재 폴더의 Dockerfile 로 `myapp:1.0` 이미지를 **만드는** 명령의 마지막 부분을 채우세요.', '현재 폴더를 뜻하는 기호예요.', NULL, NULL, '[]', 'fill', '[".", "..", "Dockerfile", "-"]', NULL, '마지막 인자는 빌드 컨텍스트(폴더)입니다. 파일 이름이 아니라 폴더를 가리켜요.', '[0]', 'docker build -t myapp:1.0 {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 20, '이름 하나 더 붙이기', '`myapp:1.0` 이미지에 `myapp:latest` 라는 **이름을 더 붙이는** 명령입니다. 빈칸을 채우세요.', '"꼬리표"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["tag", "rename", "copy", "alias"]', NULL, '`docker tag` 는 이미지를 복사하지 않고 이름만 더합니다. 레지스트리에 올리기 전에 이름을 맞출 때 써요.', '[0]', 'docker {0} myapp:1.0 myapp:latest', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 21, '자동 재시작 정하기', '사람이 직접 멈추지 않는 한 **계속 다시 시작되게** 하는 값을 채우세요.', '"멈춘 경우가 아니면"을 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["unless-stopped", "forever", "always-on", "keep"]', NULL, '`unless-stopped` 는 서버가 재부팅되어도 컨테이너를 다시 띄웁니다. 직접 `docker stop` 한 컨테이너는 그대로 둬요.', '[0]', 'docker run --restart {0} alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 22, '자세한 정보 보기', '컨테이너 `web` 의 **자세한 설정**을 JSON 으로 보는 명령입니다. 빈칸을 채우세요.', '"살펴보다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["inspect", "detail", "show", "info"]', NULL, '네트워크 주소, 마운트, 환경 변수를 한 번에 볼 수 있습니다. 출력이 길면 `-f` 로 필요한 값만 뽑으세요.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 23, '파일 복사하기', '컨테이너 `web` 안의 `/etc/hosts` 를 호스트로 **복사하는** 명령입니다. 빈칸을 채우세요.', 'copy 의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["cp", "copy", "move", "pull"]', NULL, '`docker cp 원본 대상` 순서입니다. 컨테이너 쪽 경로에는 `컨테이너이름:` 을 앞에 붙여요.', '[0]', 'docker {0} web:/etc/hosts ./hosts', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 24, '로그 끝부분만 보기', '컨테이너 `web` 의 로그에서 **마지막 20줄만** 보는 옵션입니다. 빈칸을 채우세요.', '`tail` 과 같은 이름이에요.', NULL, NULL, '[]', 'fill', '["tail", "last", "head", "recent"]', NULL, '로그가 많을 때 `--tail` 로 줄이면 화면이 빨리 뜹니다. `-f` 와 함께 쓰면 최근 줄부터 따라가요.', '[0]', 'docker logs --{0} 20 web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 25, '디스크 사용량 보기', '도커가 쓰는 **디스크 사용량**을 보는 명령입니다. 빈칸을 채우세요.', 'disk free 의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["df", "du", "size", "free"]', NULL, '이미지, 컨테이너, 볼륨, 빌드 캐시가 각각 얼마나 쓰는지 보여 줍니다. 정리하기 전에 가장 먼저 확인해 보세요.', '[0]', 'docker system {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 26, '볼륨으로 데이터 지키기', '볼륨을 연결한 컨테이너를 지워도 데이터가 남는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '볼륨 만들기 → 쓰기 → 컨테이너 삭제 → 새 컨테이너로 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker volume create data` 로 볼륨을 만든다", "`docker run --name a -v data:/data alpine sh -c \\"echo hi > /data/a\\"` 로 데이터를 쓴다", "`docker rm a` 로 컨테이너를 지운다", "새 컨테이너에 `-v data:/data` 를 붙여 `cat /data/a` 로 데이터가 남았는지 본다"]', NULL, '컨테이너를 지워도 `hi` 가 남아 있으면 볼륨이 제대로 동작하는 것입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 27, '두 컨테이너를 네트워크로 연결', '두 컨테이너를 이름으로 통신하게 만드는 순서입니다. 순서에 맞게 놓아 보세요.', '네트워크 → 첫 컨테이너 → 두 번째 컨테이너 → 이름으로 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker network create mynet` 으로 네트워크를 만든다", "`docker run -d --name db --network mynet ...` 로 첫 컨테이너를 띄운다", "`docker run --network mynet ...` 로 두 번째 컨테이너를 같은 네트워크에 띄운다", "두 번째 컨테이너에서 `ping db` 로 이름이 풀리는지 확인한다"]', NULL, '두 컨테이너가 같은 네트워크에 있어야 이름으로 통신됩니다. 하나라도 빠지면 이름을 찾지 못해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 28, '이미지 빌드하고 실행', 'Dockerfile 로 이미지를 만들고 실행해 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → 빌드 → 실행 → 접속 확인 순서예요.', NULL, NULL, '[]', 'order', '["폴더에 `Dockerfile` 을 작성한다", "`docker build -t myapp:1.0 .` 로 이미지를 만든다", "`docker run -d --name myapp -p 8080:80 myapp:1.0` 로 실행한다", "`curl localhost:8080` 으로 응답을 확인한다"]', NULL, '빌드가 실패하면 마지막 줄의 오류부터 읽으세요. 어느 단계(줄)에서 멈췄는지 알려 줍니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 29, '디스크가 부족할 때 정리', '도커가 디스크를 많이 쓸 때의 정리 순서입니다. 순서에 맞게 놓아 보세요.', '사용량 확인 → 대상 확인 → 삭제 → 다시 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker system df` 로 무엇이 얼마나 쓰는지 본다", "`docker ps -a` 로 멈춘 컨테이너, `docker images` 로 쓰지 않는 이미지를 확인한다", "필요 없는 것만 `docker rm`, `docker rmi` 로 지운다", "`docker system df` 로 줄어들었는지 다시 확인한다"]', NULL, '한꺼번에 `prune` 을 하기 전에 무엇이 지워질지 먼저 확인하세요. 볼륨의 데이터는 지우면 되돌릴 수 없어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 29);
