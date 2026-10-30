-- 도커: Dockerfile·compose 읽기 단원과 세트 38·39 (순서 맞추기·빈칸 채우기·객관식). 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set38/39.sql, 05_display_order.sql, 06_units.sql. docs/specs/spec_question_types.md
INSERT INTO unit (id, category, title, display_order) SELECT 10, '도커', 'Dockerfile·compose 읽기', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 10);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 38, 'Dockerfile 읽고 이해하기', 'Dockerfile 의 각 줄이 무슨 일을 하는지 읽고, 줄 순서와 명령을 직접 맞춰 보며 Dockerfile 을 읽는 눈을 기릅니다. 줄 순서 맞추기, 빈칸 채우기, 객관식으로 터미널 없이 풀어요.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 38);
UPDATE quest_set SET display_order = 210, unit_id = 10 WHERE id = 38;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 1, 'Node.js 앱 Dockerfile 의 줄을 올바른 순서로 놓기', 'Node.js 앱을 이미지로 만드는 Dockerfile 의 줄들이 섞여 있습니다. **위에서부터 실제로 실행되는 순서**대로 놓으세요.

소스 전체를 복사하기 **전에** 의존성부터 설치하는 이유(빌드 캐시)도 함께 생각해 보세요.', '`FROM` 으로 시작하고 컨테이너가 시작할 때 실행할 `CMD` 로 끝납니다. 작업 폴더(`WORKDIR`)를 정한 뒤 `package.json` 만 먼저 복사해서 설치하고, 그다음에 나머지 소스를 복사합니다.', NULL, NULL, '[]', 'order', '["`CMD node server.js`", "`COPY . .`", "`FROM node:20-alpine`", "`RUN npm install`", "`WORKDIR /app`", "`COPY package.json .`"]', NULL, '`FROM` 으로 바탕 이미지를 정하고, `WORKDIR` 로 작업 폴더를 만든 뒤, `package.json` 만 먼저 복사해 `npm install` 을 합니다. 그다음에 소스 전체를 복사하는 이유는 **빌드 캐시** 때문입니다. 소스를 고쳐도 `package.json` 이 그대로면 설치 단계는 캐시를 재사용해서 빌드가 빨라집니다. `CMD` 는 컨테이너를 시작할 때 실행할 기본 명령이라 맨 마지막에 둡니다.', '[2, 4, 5, 3, 1, 0]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 2, 'Dockerfile 의 FROM 줄이 하는 일 고르기', 'Dockerfile 은 이미지를 만드는 설계도입니다. 첫 줄에 `FROM node:20-alpine` 이 있다면, 이 줄은 무슨 일을 할까요?', '`FROM` 은 "어디서부터 만들까"를 정하는 줄입니다. `이름:태그` 는 어떤 이미지의 어떤 버전인지를 나타냅니다.', NULL, NULL, '[]', 'choice', '["`node` 라는 이름의 컨테이너를 바로 실행한다", "이미지를 만들 때 바탕이 되는 **베이스 이미지**(`node:20-alpine`)를 정한다", "내 컴퓨터에 설치된 Node.js 20 을 이미지 안으로 복사한다", "컨테이너가 시작할 때 실행할 명령을 정한다"]', 1, '`FROM` 은 새 이미지의 출발점(베이스 이미지)을 정합니다. `node:20-alpine` 은 `node` 이미지의 `20-alpine` 버전(가벼운 Alpine Linux 기반)이라는 뜻이고, Dockerfile 은 거의 항상 `FROM` 으로 시작합니다. 컨테이너가 시작할 때 실행할 명령은 `CMD`/`ENTRYPOINT` 가 정합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 3, 'docker build 명령의 빈칸 채우기', '현재 디렉터리에 있는 `Dockerfile` 로 이미지를 만들고, 이름을 `myapp`, 태그를 `1.0` 으로 붙이려고 합니다. 명령의 빈칸을 채우세요.', '이미지를 만드는 하위 명령, 이름:태그를 붙이는 옵션, 그리고 Dockerfile 이 있는 폴더(빌드 컨텍스트)를 차례로 씁니다.', NULL, NULL, '[]', 'fill', '["build", "run", "-t", "-f", ".", "myapp"]', NULL, '`docker build` 는 이미지를 만듭니다. `-t` (tag)는 `이름:태그` 를 붙이는 옵션이고, 마지막의 `.` 는 **빌드 컨텍스트**, 즉 Dockerfile 과 복사할 파일이 있는 폴더(현재 폴더)를 뜻합니다. `docker run` 은 이미 만든 이미지로 컨테이너를 실행하는 명령이라 여기서는 맞지 않습니다.', '[0, 2, 4]', 'docker {0} {1} myapp:1.0 {2}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 4, 'COPY . . 의 두 점이 가리키는 곳 구분하기', '`WORKDIR /app` 다음에 `COPY . .` 가 있습니다. 점(`.`)이 두 개 있는데, 각각 무엇을 가리킬까요?', '`COPY <원본> <대상>` 형태입니다. 원본은 빌드할 때 지정한 폴더 기준이고, 대상은 이미지 안의 경로입니다.', NULL, NULL, '[]', 'choice', '["첫 번째는 빌드 컨텍스트(빌드 명령 끝에 적은 내 컴퓨터의 폴더), 두 번째는 이미지 안의 현재 작업 디렉터리(`/app`)", "첫 번째는 이미지 안의 `/app`, 두 번째는 내 컴퓨터의 홈 디렉터리", "둘 다 내 컴퓨터의 현재 디렉터리", "첫 번째는 부모 디렉터리, 두 번째는 현재 디렉터리"]', 0, '`COPY 원본 대상` 에서 원본의 `.` 는 **빌드 컨텍스트**(예: `docker build .` 의 `.`)를, 대상의 `.` 는 **이미지 안의 현재 작업 디렉터리**(`WORKDIR` 로 정한 `/app`)를 가리킵니다. 즉 "내 폴더의 모든 파일을 이미지의 `/app` 으로 복사"하라는 뜻입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 5, 'EXPOSE 8080 줄만으로 일어나는 일 고르기', 'Dockerfile 에 `EXPOSE 8080` 이 있습니다. 이 이미지로 컨테이너를 실행했을 때, 이 줄만으로 일어나는 일은 무엇일까요?', '`EXPOSE` 는 설명서에 가깝습니다. 실제로 바깥과 연결하는 옵션은 `docker run` 에서 씁니다.', NULL, NULL, '[]', 'choice', '["내 컴퓨터의 8080 포트가 자동으로 열려 바깥에서 접속된다", "컨테이너가 8080 포트를 쓴다고 알려 주는 **표시**일 뿐이고, 바깥에서 접속하려면 실행할 때 `-p` 로 포트를 연결해야 한다", "컨테이너 안의 8080 포트가 방화벽으로 막힌다", "같은 이미지의 다른 컨테이너만 8080 으로 접속할 수 있게 된다"]', 1, '`EXPOSE` 는 "이 컨테이너는 8080 포트를 쓴다"는 **문서 역할**의 표시입니다. 포트를 실제로 내 컴퓨터와 연결하는 것은 `docker run -p 8080:8080 ...` 처럼 실행할 때 `-p` 옵션으로 합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 6, 'RUN 과 CMD 가 실행되는 때 구분하기', 'Dockerfile 에 `RUN npm install` 과 `CMD node server.js` 가 있습니다. 두 줄은 각각 언제 실행될까요?', '이미지를 **만들 때**(`docker build`)와 컨테이너를 **시작할 때**(`docker run`)를 구분해 보세요.', NULL, NULL, '[]', 'choice', '["둘 다 `docker build` 할 때 실행된다", "`RUN` 은 이미지를 만들 때(`docker build`), `CMD` 는 컨테이너를 시작할 때(`docker run`) 실행된다", "`RUN` 은 컨테이너를 시작할 때, `CMD` 는 이미지를 만들 때 실행된다", "둘 다 `docker run` 할 때 실행된다"]', 1, '`RUN` 은 이미지를 만드는 동안 실행되고 그 결과가 이미지에 저장됩니다(패키지 설치 등). `CMD` 는 이미지에 "컨테이너가 시작될 때 실행할 기본 명령"으로 기록만 되어 있다가 `docker run` 할 때 실행됩니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 7, '소스를 고칠 때마다 의존성을 다시 설치하는 Dockerfile 고르기', '소스 코드를 한 줄만 고친 뒤 다시 `docker build` 했습니다. 다음 중 **의존성 설치(`RUN npm install`)를 매번 처음부터 다시 하게 되는** 줄 순서는 무엇일까요?

Docker 는 앞쪽 줄의 내용이 그대로면 그 결과를 **캐시**로 재사용하고, 한 줄이 바뀌면 그 줄부터 뒤는 모두 다시 실행합니다.', '소스를 고치면 `COPY . .` 의 결과가 바뀝니다. 그 줄 **뒤**에 있는 줄은 모두 다시 실행됩니다.', NULL, NULL, '[]', 'choice', '["`COPY . .` 다음에 `RUN npm install`", "`COPY package.json .` 다음에 `RUN npm install`, 그다음에 `COPY . .`", "`FROM` 줄을 맨 위에 둔 모든 경우", "순서와 관계없이 항상 캐시를 쓴다"]', 0, '소스를 고치면 `COPY . .` 의 결과가 달라져서 그 **뒤의** `RUN npm install` 캐시가 깨집니다. 반대로 `package.json` 을 먼저 복사해 설치하면, 소스만 고쳤을 때는 `package.json` 이 그대로라서 설치 단계 캐시를 재사용합니다. 그래서 자주 바뀌는 것(소스)을 **뒤쪽에** 두는 것이 좋습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 8, 'Dockerfile 로 앱을 만들고 실행하는 흐름 순서대로 놓기', 'Dockerfile 을 작성해서 앱을 컨테이너로 실행하기까지의 단계가 섞여 있습니다. **실제로 하는 순서대로** 놓으세요.', '먼저 설계도(`Dockerfile`)를 쓰고, 이미지를 만들고, 만들어졌는지 확인한 뒤, 마지막에 실행합니다.', NULL, NULL, '[]', 'order', '["`docker run -p 8080:8080 myapp:1.0` 로 컨테이너 실행", "`docker build -t myapp:1.0 .` 로 이미지 만들기", "`Dockerfile` 작성", "`docker images` 로 만든 이미지 확인"]', NULL, '`Dockerfile`(설계도) → `docker build`(이미지 생성) → `docker images`(생성 확인) → `docker run`(컨테이너 실행) 순서입니다. 이미지는 한 번 만들어 두면 `docker run` 으로 컨테이너를 몇 번이든 띄울 수 있습니다.', '[2, 1, 3, 0]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 38, 9, 'ENTRYPOINT 와 CMD 를 함께 쓸 때 실제 실행되는 명령 고르기', '어떤 이미지(`tool`)의 Dockerfile 에 `ENTRYPOINT` 는 `python`, `CMD` 는 `app.py` 로 적혀 있습니다. 이 이미지를 `docker run tool other.py` 로 실행하면, 컨테이너 안에서 실제로 실행되는 명령은 무엇일까요?', '`ENTRYPOINT` 는 항상 실행되는 고정 명령이고, `CMD` 는 그 뒤에 붙는 **기본** 인자입니다. `docker run` 뒤에 값을 적으면 기본 인자가 바뀝니다.', NULL, NULL, '[]', 'choice', '["`python app.py`", "`python other.py`", "`other.py`", "`app.py other.py`"]', 1, '`ENTRYPOINT` 는 고정 명령(`python`)이고 `CMD` 는 거기에 붙는 기본 인자(`app.py`)입니다. `docker run tool other.py` 처럼 이미지 이름 뒤에 값을 적으면 `CMD` 가 그 값으로 **대체**되어 `python other.py` 가 실행됩니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 38 AND order_index = 9);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 39, 'docker compose 파일 읽고 이해하기', '여러 컨테이너를 한 파일로 정의하는 compose.yaml 을 읽고, 포트·의존성·볼륨·서비스 이름 통신이 무슨 뜻인지 직접 맞춰 봅니다. 빈칸 채우기, 순서 맞추기, 객관식으로 터미널 없이 풀어요.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 39);
UPDATE quest_set SET display_order = 220, unit_id = 10 WHERE id = 39;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 1, 'compose.yaml 에서 이미지와 포트 빈칸 채우기', '`compose.yaml` 로 nginx 웹 서버를 띄우려고 합니다. 내 컴퓨터의 **8080 포트**로 접속하면 컨테이너의 **80 포트**(nginx)에 연결되도록 빈칸을 채우세요.', '`image` 에는 이미지 이름:태그를, `ports` 에는 `내 컴퓨터 포트:컨테이너 포트` 를 씁니다. 컨테이너 쪽 포트는 이미 `80` 으로 적혀 있습니다.', NULL, NULL, '[]', 'fill', '["nginx:1.25", "8080", "80", "redis:7", "3306"]', NULL, '`services:` 아래에 서비스 이름(`web`)을 쓰고, `image` 로 사용할 이미지를 정합니다. `ports` 의 `8080:80` 은 `내 컴퓨터 8080 → 컨테이너 80` 이라는 뜻입니다. `redis:7` 은 다른 서버(Redis)의 이미지이고 `3306` 은 MySQL 의 기본 포트라서 이 문제와는 맞지 않습니다.', '[0, 1]', 'services:
  web:
    image: {0}
    ports:
      - "{1}:80"'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 2, 'ports 의 8080:80 이 뜻하는 방향 구분하기', '`compose.yaml` 의 `ports` 에 `8080:80` 이라고 적혀 있습니다. 이 설정은 무슨 뜻일까요?', '콜론(`:`) 앞이 어느 쪽인지, 뒤가 어느 쪽인지 정해져 있습니다. 바깥에서 들어오는 포트가 앞입니다.', NULL, NULL, '[]', 'choice', '["컨테이너의 8080 포트로 오는 요청을 내 컴퓨터의 80 포트로 보낸다", "컨테이너 안에서 8080 과 80 포트를 모두 연다", "내 컴퓨터(호스트)의 8080 포트로 오는 요청을 컨테이너의 80 포트로 보낸다", "두 서비스가 8080 과 80 포트로 서로 통신한다"]', 2, '`호스트포트:컨테이너포트` 순서입니다. 그래서 `8080:80` 은 내 컴퓨터의 8080 으로 들어온 요청을 컨테이너의 80 으로 넘겨 줍니다. 브라우저에서 `http://localhost:8080` 으로 접속하면 컨테이너 안의 nginx(80)가 응답합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 3, 'depends_on 이 보장하는 것 구분하기', '`web` 서비스에 `depends_on: [db]` 가 적혀 있습니다. 이 설정이 보장하는 것은 무엇일까요?', '"먼저 **시작**된다"와 "준비가 **끝난다**"는 다른 말입니다. DB 는 시작해도 요청을 받기까지 시간이 걸립니다.', NULL, NULL, '[]', 'choice', '["`db` 컨테이너가 먼저 시작된다 (다만 `db` 가 요청을 받을 준비를 마쳤는지는 기다리지 않는다)", "`db` 가 요청을 받을 준비를 마칠 때까지 `web` 이 기다린다", "`web` 이 `db` 에 접속할 수 있는 계정이 자동으로 만들어진다", "`db` 가 죽으면 `web` 도 자동으로 멈춘다"]', 0, '`depends_on` 은 **시작 순서**만 정해 줍니다. `db` 컨테이너가 먼저 시작되지만 DB 가 접속을 받을 준비가 끝났는지까지는 기다리지 않아서, 앱이 처음에 접속에 실패할 수 있습니다. 준비 완료까지 기다리려면 `healthcheck` 와 `condition: service_healthy` 를 함께 씁니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 4, 'docker compose down 뒤에 이름 붙은 볼륨의 데이터가 남는지 고르기', '`db` 서비스에 `volumes: - db-data:/var/lib/mysql` 이 있고, 파일 맨 아래 `volumes:` 에 `db-data` 가 선언되어 있습니다. `docker compose down` 으로 컨테이너를 지운 뒤 다시 `docker compose up -d` 하면, DB 데이터는 어떻게 될까요?', '이름이 붙은 볼륨(named volume)은 컨테이너와 따로 보관됩니다. 볼륨까지 지우는 옵션은 따로 있습니다.', NULL, NULL, '[]', 'choice', '["모두 사라진다", "남아 있다 (이름 붙은 볼륨은 `down` 으로 지워지지 않고, `down -v` 일 때만 지워진다)", "`up` 할 때마다 처음 이미지의 상태로 복사된다", "내 컴퓨터의 `/var/lib/mysql` 에 저장되어 있다"]', 1, '`docker compose down` 은 컨테이너와 네트워크를 지우지만 **이름 붙은 볼륨은 남깁니다.** 그래서 다시 `up` 하면 이전 데이터가 그대로 있습니다. 볼륨까지 지우려면 `docker compose down -v` 를 써야 하고, 이때는 데이터가 사라지니 조심해야 합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 5, '같은 compose 안의 db 서비스에 접속하는 주소 고르기', '같은 `compose.yaml` 에 `web` 과 `db`(포트 3306) 서비스가 있습니다. `web` 컨테이너 안의 앱이 `db` 에 접속하려고 합니다. 접속 주소로 알맞은 것은 무엇일까요?', 'compose 는 서비스끼리 통신하는 네트워크를 만들고, **서비스 이름**을 주소(DNS)로 쓸 수 있게 해 줍니다. `localhost` 는 컨테이너 자기 자신입니다.', NULL, NULL, '[]', 'choice', '["`localhost:3306`", "`db:3306`", "`127.0.0.1:db`", "`compose:db:3306`"]', 1, 'compose 는 서비스들이 함께 쓰는 기본 네트워크를 만들고 **서비스 이름**(`db`)을 주소로 쓸 수 있게 해 줍니다. 그래서 `web` 안에서는 `db:3306` 으로 접속합니다. `localhost` 는 `web` 컨테이너 자기 자신을 가리켜서 `db` 가 아닙니다. 이름으로 통신하는 원리는 리눅스의 `/etc/hosts`, k8s 의 Service 이름과 같은 아이디어입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 6, 'docker compose 로 서비스를 올리고 확인하고 내리는 순서대로 놓기', '`compose.yaml` 로 서비스를 다루는 단계가 섞여 있습니다. **일반적인 작업 순서**대로 놓으세요.', '파일을 쓰고, 올리고, 상태를 보고, 로그를 본 뒤, 마지막에 정리합니다.', NULL, NULL, '[]', 'order', '["`docker compose down` 으로 정리", "`docker compose logs web` 으로 로그 보기", "`compose.yaml` 작성", "`docker compose up -d` 로 백그라운드 실행", "`docker compose ps` 로 상태 확인"]', NULL, '파일 작성 → `up -d` 로 실행 → `ps` 로 상태 확인 → `logs` 로 동작 확인 → 끝나면 `down` 으로 정리합니다. `-d` 는 백그라운드(detached)로 실행하는 옵션입니다.', '[2, 3, 4, 1, 0]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 7, 'docker compose 로 서비스를 백그라운드로 시작하는 명령 채우기', '`compose.yaml` 에 정의한 서비스를 **백그라운드로 시작**하려고 합니다. 명령의 빈칸을 채우세요.', '서비스를 시작하는 하위 명령 하나와, 터미널을 붙잡지 않고 백그라운드로 돌리는 옵션 하나가 필요합니다.', NULL, NULL, '[]', 'fill', '["up", "down", "-d", "-v", "ps"]', NULL, '`docker compose up` 은 서비스를 만들고 시작하고, `-d`(detached)는 백그라운드로 돌려 터미널을 돌려받는 옵션입니다. `down` 은 정리, `ps` 는 상태 확인, `-v` 는 `down` 과 함께 쓰면 볼륨까지 지우는 옵션입니다.', '[0, 2]', 'docker compose {0} {1}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 8, 'environment 줄이 하는 일 고르기', '`db` 서비스에 `environment:` 아래 `- MYSQL_ROOT_PASSWORD=secret` 이 적혀 있습니다. 이 줄은 무슨 일을 할까요?', '이 값은 컨테이너가 시작될 때 안에서 읽을 수 있는 **환경변수**가 됩니다.', NULL, NULL, '[]', 'choice', '["컨테이너 안에 환경변수 `MYSQL_ROOT_PASSWORD` 를 `secret` 값으로 넣어 준다", "내 컴퓨터의 환경변수를 바꾼다", "이미지를 빌드할 때만 쓰이는 값이다", "컨테이너가 시작하면 `secret` 이라는 파일을 만든다"]', 0, '`environment` 는 컨테이너 안의 환경변수를 정합니다. MySQL 이미지는 `MYSQL_ROOT_PASSWORD` 로 root 비밀번호를 정합니다. 실제 비밀번호를 `compose.yaml` 에 그대로 쓰면 저장소에 올라갈 수 있어서, 실무에서는 `env_file` 이나 secrets 로 분리하고 git 에 올리지 않습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 39, 9, 'image 없이 build: . 만 있는 서비스가 하는 일 고르기', '서비스에 `build: .` 이 있고 `image` 는 없습니다. `docker compose up` 을 하면 어떻게 될까요?', '`build` 는 "이 폴더의 Dockerfile 로 이미지를 만들어라"는 뜻입니다.', NULL, NULL, '[]', 'choice', '["Docker Hub 에서 `.` 라는 이미지를 받아 온다", "현재 폴더의 Dockerfile 로 이미지를 **빌드한 뒤** 그 이미지로 컨테이너를 만든다", "오류가 난다 (`image` 는 꼭 있어야 한다)", "기존 컨테이너를 모두 지운다"]', 1, '`build: .` 은 현재 폴더의 `Dockerfile` 로 이미지를 빌드하라는 뜻이라 `image` 가 없어도 됩니다. `docker compose up` 이 이미지가 없으면 빌드한 뒤 컨테이너를 만듭니다. 이미 만든 이미지를 쓰려면 `image:` 로 이름을 적습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 39 AND order_index = 9);
