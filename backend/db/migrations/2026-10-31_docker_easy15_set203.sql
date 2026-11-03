-- 도커 세트 203. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set203.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 203, '컨테이너 복사·재시작·정리: docker cp, restart, kill, rm -f, diff, commit, history, rmi, prune', '컨테이너와 이미지를 다루는 기본 명령의 동작을 한 개념씩 반복합니다. docker cp 로 호스트와 컨테이너 사이 파일을 주고받는 방향과 이름:경로 표기, 정지된 컨테이너에서도 되는 것, 없는 폴더 오류와 폴더 통째 복사, docker version 과 info 의 차이, restart 가 같은 컨테이너를 다시 시작해 파일이 남는 것, kill 이 SIGKILL 로 바로 끝내 종료 코드 137 이 되는 것, 실행 중인 컨테이너의 rm 오류와 -f, 컨테이너 안 파일이 stop·start 에서는 남고 rm 후에는 사라지는 것, diff 의 A·C·D, commit 이 볼륨 파일을 담지 않는 것, history 의 레이어, 컨테이너가 쓰는 이미지의 rmi 충돌, container prune 이 정지된 컨테이너만 지우는 것을 짧은 객관식·빈칸·순서 문제로 익히고, 파일 넣고 꺼내기, 바뀐 파일을 이미지로 남기기, 쓰는 이미지 지우기, 재시작 뒤 파일 확인의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 203);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '📎' WHERE id = 203;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 1, '호스트와 컨테이너 사이 파일 복사', '`docker cp ./a.txt web:/tmp/a.txt` 와 `docker cp web:/tmp/c.txt ./` 는 각각 무엇을 할까요?', '컨테이너 쪽은 `이름:경로` 로 써요.', NULL, NULL, '[]', 'choice', '["둘 다 컨테이너 안에서 파일을 복사한다", "`cp` 는 컨테이너에서 꺼내기만 되고, 넣으려면 `docker exec` 로만 가능하다", "앞의 명령은 내 컴퓨터의 파일을 컨테이너 안으로 넣고, 뒤의 명령은 컨테이너 안의 파일을 내 컴퓨터로 꺼낸다. 컨테이너 쪽 경로는 `이름:경로` 로 쓴다", "컨테이너 쪽 경로는 `이름/경로` 로 쓰고 콜론은 쓰지 않는다"]', 2, '방향은 앞의 인자가 원본, 뒤의 인자가 대상입니다. 어느 쪽이든 컨테이너 쪽에만 `이름:` 이 붙습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 2, '정지된 컨테이너에서 파일 꺼내기', '정지된 컨테이너 `web` 에서 `docker cp web:/tmp/c.txt ./` 를 하면 어떻게 될까요?', '`exec` 와 달리 실행 중일 필요가 없어요.', NULL, NULL, '[]', 'choice', '["정지된 컨테이너에는 `cp` 를 쓸 수 없어 먼저 `docker start` 를 해야 한다", "컨테이너가 정지돼 있어도 파일을 꺼낼 수 있다. `create` 만 하고 시작하지 않은 컨테이너에도 파일을 넣을 수 있다", "꺼내기는 되지만 넣기는 실행 중일 때만 된다", "정지된 컨테이너에서는 이미지의 원본 파일만 복사된다"]', 1, '종료된 컨테이너에 남은 로그 파일이나 결과 파일을 꺼낼 때 유용합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 3, '없는 폴더로 복사하면', '`docker cp a.txt web:/nodir/x/a.txt` 처럼 컨테이너 안에 **없는 폴더**를 대상으로 지정하면 어떻게 될까요?', '대상 폴더는 미리 있어야 해요.', NULL, NULL, '[]', 'choice', '["`Could not find the file` 같은 오류가 나고 복사되지 않는다. 필요하면 `docker exec web mkdir -p` 로 폴더를 먼저 만든다", "폴더를 자동으로 만든 뒤 복사한다", "오류 없이 `/` 아래에 파일을 복사한다", "아무 메시지 없이 건너뛰고 성공으로 끝난다"]', 0, '컨테이너 안에 없는 경로를 원본으로 줄 때도 같은 종류의 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 4, '폴더 통째로 복사하기', '`docker cp ./d web:/tmp/` 처럼 폴더를 지정해 복사하면 컨테이너 안에는 어떻게 만들어질까요?', '폴더 이름도 함께 복사돼요.', NULL, NULL, '[]', 'choice', '["폴더는 복사되지 않고 오류가 난다", "폴더 안의 파일이 하나씩 `/tmp` 바로 아래에 풀려서 들어간다", "폴더 안의 첫 번째 파일만 복사된다", "`/tmp/d` 폴더가 만들어지고 그 안의 파일까지 함께 복사된다"]', 3, '같은 이름의 파일이 이미 있으면 새 내용으로 덮어씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 5, 'docker version 과 docker info', '`docker version` 과 `docker info` 는 각각 무엇을 보여 줄까요?', '하나는 버전, 하나는 엔진 상태예요.', NULL, NULL, '[]', 'choice', '["`docker version` 은 이미지 버전 목록을, `docker info` 는 컨테이너 한 개의 설정을 보여 준다", "둘은 같은 내용을 보여 주고 `info` 가 줄임말이다", "`docker version` 은 클라이언트와 서버(엔진)의 버전을, `docker info` 는 컨테이너 수·이미지 수·스토리지 드라이버 같은 엔진 전체 상태를 보여 준다", "`docker version` 은 서버만, `docker info` 는 클라이언트만 보여 준다"]', 2, '클라이언트 버전만 짧게 보려면 `docker --version` 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 6, 'docker restart 의 동작', '`docker restart web` 을 하면 컨테이너는 어떻게 될까요?', '새로 만드는 게 아니라 멈췄다 다시 시작해요.', NULL, NULL, '[]', 'choice', '["새 컨테이너가 만들어져 ID 가 바뀐다", "같은 컨테이너(ID 그대로)가 멈췄다가 다시 시작되고 시작 시각이 새로 바뀐다. 컨테이너 안에 써 둔 파일은 남아 있다", "컨테이너 안에 써 둔 파일이 모두 사라진다", "이미지를 다시 받아 최신 상태로 바꾼다"]', 1, '정지된 컨테이너에 `restart` 를 하면 그냥 시작됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 7, 'docker kill 의 동작', '`docker kill web` 은 `docker stop web` 과 무엇이 다를까요? 이미 정지된 컨테이너에 `docker kill` 을 하면요?', '기다리지 않고 바로 끝내요.', NULL, NULL, '[]', 'choice', '["`kill` 은 기본으로 SIGKILL 을 바로 보내 종료 코드가 137 이 된다. 이미 정지된 컨테이너에는 `is not running` 오류가 난다", "`kill` 은 SIGTERM 을 보낸 뒤 10초를 기다리고, 정지된 컨테이너에는 아무 일도 하지 않는다", "`kill` 은 컨테이너를 지우기까지 하고, 정지된 컨테이너에도 동작한다", "`kill` 은 종료 코드가 항상 0 이고 정지된 컨테이너에도 성공한다"]', 0, '프로세스가 정리할 시간을 주려면 `stop`, 즉시 끝내려면 `kill` 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 8, '실행 중인 컨테이너 지우기', '실행 중인 컨테이너 `web` 에 `docker rm web` 을 하면 어떻게 될까요?', '먼저 멈추거나 강제로 지워요.', NULL, NULL, '[]', 'choice', '["실행 중이어도 바로 지워진다", "자동으로 멈춘 뒤 지워진다", "컨테이너는 그대로이고 이미지만 지워진다", "컨테이너가 실행 중이라는 오류가 나서 지워지지 않는다. `docker stop` 으로 멈춘 뒤 지우거나 `docker rm -f` 로 강제로 지운다"]', 3, '`-f` 는 `--force` 의 줄임말이고 정지된 컨테이너에 써도 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 9, '컨테이너 안 파일의 수명', '컨테이너 안에 파일을 만든 뒤 `docker stop` 과 `docker start` 를 하면 그 파일은 어떻게 될까요? `docker rm` 후 같은 이미지로 새로 `docker run` 하면요?', '컨테이너를 지우는 순간 쓰기 레이어가 사라져요.', NULL, NULL, '[]', 'choice', '["두 경우 모두 파일이 남아 있다", "멈췄다 시작해도 파일이 사라진다", "멈췄다 다시 시작해도 파일이 남아 있지만, 컨테이너를 지우고 새로 만들면 파일은 없다", "컨테이너를 지워도 같은 이미지로 새로 만들면 파일이 복원된다"]', 2, '남겨야 하는 데이터는 볼륨이나 마운트에 둡니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 10, 'docker diff 의 A, C, D', '`docker diff web` 의 출력에서 줄 앞의 `A`, `C`, `D` 는 각각 무슨 뜻일까요?', '추가, 변경, 삭제의 머리글자예요.', NULL, NULL, '[]', 'choice', '["`A` 는 접근 권한, `C` 는 생성 시각, `D` 는 디렉터리를 뜻한다", "`A` 는 추가된 파일·폴더, `C` 는 변경된 것, `D` 는 삭제된 것이다. 이미지에서 시작한 뒤 컨테이너 안에서 바뀐 목록을 보여 준다", "`A` 는 실행 중, `C` 는 정지됨, `D` 는 삭제됨으로 컨테이너 상태를 뜻한다", "`A` 는 이미지 전체, `C` 는 캐시, `D` 는 데이터 볼륨을 뜻한다"]', 1, '파일을 지우면 `D`, 폴더에 파일이 생기면 그 폴더가 `C` 로도 나타납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 11, 'docker commit 으로 이미지 만들기', '`docker commit web myimg:v1` 은 무엇을 할까요? 볼륨에 쓴 파일은 어떻게 될까요?', '컨테이너 안에서 바뀐 파일이 담겨요.', NULL, NULL, '[]', 'choice', '["컨테이너 안에서 바뀐 파일(쓰기 레이어)을 담은 새 이미지를 만든다. 볼륨에 쓴 파일은 이미지에 담기지 않는다", "컨테이너를 지우고 이미지만 남긴다", "볼륨에 쓴 파일까지 모두 이미지에 담긴다", "Dockerfile 을 만들어 준다"]', 0, '이미지를 반복해서 만들려면 `commit` 보다 Dockerfile 이 낫습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 12, 'docker history 읽기', '`docker history myimg:v1` 은 무엇을 보여 줄까요?', '레이어를 만든 명령이에요.', NULL, NULL, '[]', 'choice', '["이미지를 `pull` 한 날짜와 시각의 기록만 보여 준다", "그 이미지로 실행한 컨테이너의 명령 기록을 보여 준다", "이미지 이름의 태그 변경 기록을 보여 준다", "이미지를 이루는 레이어를 최신 것부터 나열하고, 각 레이어를 만든 명령(`CREATED BY`)과 크기를 보여 준다"]', 3, '`commit` 으로 만든 이미지는 맨 위 레이어가 그 컨테이너의 명령으로 표시됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 13, '쓰고 있는 이미지 지우기', '컨테이너가 쓰고 있는 이미지에 `docker rmi myimg:v1` 을 하면 어떻게 될까요?', '컨테이너를 먼저 지워야 해요.', NULL, NULL, '[]', 'choice', '["컨테이너까지 함께 지워진다", "이미지가 지워지고 컨테이너는 계속 실행된다", "그 이미지로 만든 컨테이너가 남아 있으면 충돌 오류가 난다. 컨테이너를 지운 뒤에 이미지를 지운다", "오류 없이 이미지 이름표만 사라진다"]', 2, '오류를 무시하고 지우는 `-f` 도 있지만 컨테이너 정리가 먼저입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 14, '정지된 컨테이너 한꺼번에 지우기', '`docker container prune -f` 를 하면 무엇이 지워질까요?', '정지된 것만 지워요.', NULL, NULL, '[]', 'choice', '["실행 중인 컨테이너를 포함해 모든 컨테이너가 지워진다", "실행 중이 아닌(정지된·만들기만 한) 컨테이너가 지워지고, 실행 중인 컨테이너는 그대로 남는다", "사용하지 않는 이미지가 지워진다", "사용하지 않는 볼륨이 지워진다"]', 1, '`-f` 는 정말 지울지 묻는 확인을 건너뜁니다. 특정 조건만 지우려면 `--filter` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 15, '파일 복사 명령', '호스트와 컨테이너 사이에서 **파일을 복사하는** 하위 명령을 채우세요.', '"copy"의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["cp", "copy", "put", "push"]', NULL, '컨테이너 쪽 경로에는 `이름:` 을 붙입니다.', '[0]', 'docker {0} ./a.txt web:/tmp/a.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 16, '컨테이너 쪽 경로 표기', '`docker cp` 에서 컨테이너 안의 경로를 쓸 때 **이름과 경로 사이**에 넣는 문자를 채우세요.', '이름 뒤에 붙이는 구분 기호예요.', NULL, NULL, '[]', 'fill', '[":", "/", "@", "="]', NULL, '예: `web:/tmp/c.txt` 는 컨테이너 `web` 의 `/tmp/c.txt` 입니다.', '[0]', 'docker cp web{0}/tmp/c.txt ./', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 17, '클라이언트와 서버 버전', '**클라이언트와 서버(엔진)의 버전**을 함께 보여 주는 하위 명령을 채우세요.', '"version"이에요.', NULL, NULL, '[]', 'fill', '["version", "ver", "about", "release"]', NULL, '클라이언트 버전만 짧게 보려면 `docker --version` 입니다.', '[0]', 'docker {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 18, '엔진 전체 상태', '**컨테이너·이미지 수와 스토리지 드라이버** 같은 엔진 전체 상태를 보여 주는 하위 명령을 채우세요.', '"정보"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["info", "status", "config", "show"]', NULL, '서버 버전, 로깅 드라이버 같은 설정도 함께 나옵니다.', '[0]', 'docker {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 19, '컨테이너 다시 시작', '컨테이너를 **멈췄다가 다시 시작하는** 하위 명령을 채우세요.', '"re"와 "start"를 이어요.', NULL, NULL, '[]', 'fill', '["restart", "reload", "reboot", "reset"]', NULL, '컨테이너 ID 는 그대로이고 안의 파일도 남습니다.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 20, '바로 종료시키기', '컨테이너에 **SIGKILL 을 바로 보내** 종료시키는 하위 명령을 채우세요.', '"죽이다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["kill", "stop", "halt", "end"]', NULL, '종료 코드는 보통 137 입니다.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 21, '강제로 지우기', '실행 중인 컨테이너를 **강제로 지우는** `docker rm` 옵션의 긴 이름을 채우세요.', '"force"예요.', NULL, NULL, '[]', 'fill', '["--force", "--kill", "--now", "--all"]', NULL, '짧은 이름은 `-f` 입니다.', '[0]', 'docker rm {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 22, '바뀐 파일 목록', '컨테이너 안에서 **바뀐 파일의 목록**을 보여 주는 하위 명령을 채우세요.', '"차이"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["diff", "changes", "delta", "status"]', NULL, '`A` 추가, `C` 변경, `D` 삭제로 표시됩니다.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 23, '컨테이너를 이미지로', '컨테이너의 현재 상태를 **새 이미지로 저장하는** 하위 명령을 채우세요.', '"저장하다, 확정하다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["commit", "save", "snapshot", "build"]', NULL, '컨테이너 이름 뒤에 새 이미지 이름과 태그를 씁니다.', '[0]', 'docker {0} web myimg:v1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 24, '레이어 목록 보기', '이미지를 이루는 **레이어와 만든 명령**을 보여 주는 하위 명령을 채우세요.', '"이력"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["history", "layers", "log", "inspect"]', NULL, '`CREATED BY` 열에 각 레이어를 만든 명령이 나옵니다.', '[0]', 'docker {0} myimg:v1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 25, '정지된 컨테이너 정리', '**정지된 컨테이너를 한꺼번에 지우는** 하위 명령을 채우세요.', '"가지치기"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["prune", "clean", "purge", "sweep"]', NULL, '`-f` 는 확인 질문을 건너뜁니다.', '[0]', 'docker container {0} -f', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 26, '컨테이너에 파일 넣고 꺼내기', '컨테이너에 파일을 넣고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 넣기 → 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name web alpine sleep 600` 으로 컨테이너를 실행한다", "`docker cp ./a.txt web:/tmp/a.txt` 로 파일을 컨테이너에 넣는다", "`docker exec web cat /tmp/a.txt` 로 파일 내용이 보이는지 확인한다", "`docker rm -f web` 로 컨테이너를 지운다"]', NULL, '꺼낼 때는 원본과 대상 자리만 바꿔 `docker cp web:/tmp/a.txt ./` 로 씁니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 27, '바뀐 파일을 이미지로 남기기', '컨테이너 안에서 만든 파일을 이미지로 남기는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 변경 → 확인 → 저장 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name web alpine sleep 600` 으로 컨테이너를 실행한다", "`docker exec web sh -c ''echo n > /root/new.txt''` 로 컨테이너 안에 파일을 만든다", "`docker diff web` 에 `A /root/new.txt` 가 보이는지 확인한다", "`docker commit web myimg:v1` 으로 새 이미지를 만든다"]', NULL, '새 이미지로 `docker run` 하면 만들어 둔 파일이 처음부터 들어 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 28, '쓰고 있는 이미지 지우기', '컨테이너가 쓰는 이미지를 지우는 순서입니다. 순서에 맞게 놓아 보세요.', '띄우기 → 막힘 확인 → 컨테이너 지우기 → 이미지 지우기 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name t myimg:v1 sleep 600` 으로 그 이미지를 쓰는 컨테이너를 띄운다", "`docker rmi myimg:v1` 이 컨테이너가 쓰고 있다는 충돌 오류로 막히는지 본다", "`docker rm -f t` 로 컨테이너를 지운다", "`docker rmi myimg:v1` 이 `Untagged` 로 지워지는지 확인한다"]', NULL, '정지된 컨테이너가 남아 있어도 같은 방식으로 먼저 지워야 합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 29, '재시작 뒤 파일 확인', '컨테이너를 다시 시작해도 안의 파일이 남는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 파일 만들기 → 재시작 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name web alpine sleep 600` 으로 컨테이너를 실행한다", "`docker exec web sh -c ''echo keep > /tmp/keep.txt''` 로 안에 파일을 만든다", "`docker restart web` 으로 컨테이너를 다시 시작한다", "`docker exec web cat /tmp/keep.txt` 로 파일이 남아 있는지 확인한다"]', NULL, '`docker rm` 으로 지우고 새로 만들면 이 파일은 사라집니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 29);
