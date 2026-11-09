-- 도커 세트 221. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set221.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 221, 'Dockerfile 실행 설정: CMD·ENTRYPOINT 와 run 인자, --entrypoint, 셸·exec 형식, .dockerignore, COPY --chown', 'Dockerfile 이 컨테이너의 실행 방식을 정하는 방법을 한 개념씩 반복합니다. docker run 의 인자가 CMD 를 덮어쓴다는 점, ENTRYPOINT 와 CMD 를 함께 쓸 때의 결합, --entrypoint 가 CMD 를 쓰지 않게 한다는 점, 셸 형식과 exec 형식의 변수 처리와 저장 모양, 셸 형식 ENTRYPOINT 가 인자를 받지 않는다는 점, CMD 를 두 번 쓰면 마지막만 효력이 있다는 점, .dockerignore 와 ! 예외, COPY --chown, LABEL 과 label 필터, build --label, RUN 과 CMD 의 실행 시점을 짧은 객관식·빈칸·순서 문제로 익히고, CMD 덮어쓰기, ENTRYPOINT 와 CMD, .dockerignore, 셸 형식과 exec 형식 비교의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 221);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🥾' WHERE id = 221;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 1, 'docker run 의 인자는 CMD 를 덮어쓴다', '`CMD ["echo","default-cmd"]` 만 있는 이미지에 `docker run 이미지 echo x` 를 실행하면 무엇이 출력될까요?', 'run 뒤의 명령은 CMD 를 대신해요.', NULL, NULL, '[]', 'choice', '["`default-cmd x` 가 출력된다. 뒤에 적은 인자가 `CMD` 뒤에 이어 붙는다", "`default-cmd` 가 출력된다. `docker run` 뒤에 적은 명령은 무시된다", "`x` 만 출력된다. 이미지의 `CMD` 는 실행되지 않는다", "오류가 나서 아무것도 출력되지 않고 `CMD` 가 있으면 명령을 더 줄 수 없다"]', 2, '`CMD` 는 기본값이라서 `docker run` 뒤에 명령을 적으면 통째로 바뀝니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 2, 'ENTRYPOINT 와 CMD 함께 쓰기', '`ENTRYPOINT ["echo","base"]` 와 `CMD ["default"]` 가 있는 이미지에서 `docker run 이미지` 와 `docker run 이미지 b` 는 각각 무엇을 출력할까요?', 'ENTRYPOINT 는 고정, CMD 는 뒤에 붙는 기본 인자예요.', NULL, NULL, '[]', 'choice', '["앞은 `base default`, 뒤는 `b` 만 출력되어 `ENTRYPOINT` 도 덮어써진다", "앞은 `base default`, 뒤는 `base b` 가 출력된다", "앞은 `default`, 뒤는 `b` 가 출력되어 `ENTRYPOINT` 는 쓰이지 않는다", "앞은 `base`, 뒤는 `base b` 가 출력되어 `CMD` 는 `docker run` 에서 쓰이지 않는다"]', 1, '`ENTRYPOINT` 는 고정된 실행 파일이고 `CMD` 는 그 뒤에 붙는 기본 인자입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 3, '--entrypoint 와 CMD', '위 이미지(`ENTRYPOINT ["echo","base"]`, `CMD ["default"]`)에서 `docker run --entrypoint echo 이미지` 는 무엇을 출력할까요?', 'ENTRYPOINT 를 바꾸면 CMD 는 어떻게 될까요?', NULL, NULL, '[]', 'choice', '["빈 줄만 출력된다. `--entrypoint` 를 주면 이미지의 `CMD` 는 쓰이지 않는다", "`default` 가 출력된다. 이미지의 `CMD` 는 새 진입점 뒤에 그대로 붙는다", "`base default` 가 출력된다. `--entrypoint` 는 이미 있는 값은 바꾸지 않는다", "오류가 나서 아무것도 출력되지 않고 `--entrypoint` 는 `ENTRYPOINT` 가 없을 때만 쓸 수 있다"]', 0, '새 진입점에 인자를 주려면 `docker run --entrypoint echo 이미지 zz` 처럼 이미지 뒤에 적습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 4, '셸 형식과 exec 형식의 변수', '`ENV HOME=/home/x` 가 있을 때 `CMD echo $HOME` 와 `CMD ["echo","$HOME"]` 은 각각 무엇을 출력할까요?', '셸이 변수를 풀어 줄까요?', NULL, NULL, '[]', 'choice', '["둘 다 `/home/x` 를 풀어서 출력하고 두 형식의 차이는 없다", "앞은 `$HOME` 글자 그대로, 뒤는 `/home/x` 를 풀어서 출력한다", "둘 다 `$HOME` 글자 그대로 출력하고 변수는 `RUN` 에서만 풀린다", "앞은 `/home/x` 를 풀어서, 뒤는 `$HOME` 글자 그대로 출력한다"]', 3, 'exec 형식은 셸을 거치지 않아서 변수를 풀려면 `["sh","-c","echo $HOME"]` 처럼 셸을 직접 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 5, '셸 형식 ENTRYPOINT', '`ENTRYPOINT echo base` (셸 형식)와 `CMD ["default"]` 가 있는 이미지에서 `docker run 이미지 extra` 는 무엇을 출력할까요?', '셸 형식 ENTRYPOINT 는 인자를 받지 못해요.', NULL, NULL, '[]', 'choice', '["`base extra` 가 출력된다. 셸 형식도 `docker run` 의 인자를 뒤에 붙여 준다", "`base default` 가 출력된다. `CMD` 는 쓰이고 `docker run` 의 인자만 무시된다", "`base` 만 출력된다. 셸 형식 `ENTRYPOINT` 는 `CMD` 와 `docker run` 의 인자를 모두 무시한다", "`extra` 만 출력된다. `docker run` 의 인자가 `ENTRYPOINT` 를 대신한다"]', 2, '인자를 받게 하려면 `ENTRYPOINT ["echo","base"]` 처럼 exec 형식으로 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 6, '셸 형식의 저장 모양', '`CMD echo hi` 처럼 셸 형식으로 쓴 명령은 `docker image inspect --format ''{{.Config.Cmd}}''` 에 어떻게 저장되어 보일까요?', '앞에 셸이 붙어요.', NULL, NULL, '[]', 'choice', '["`echo hi` 만 보이고 셸 형식과 exec 형식은 저장 모양이 같다", "`/bin/sh -c echo hi` 처럼 `/bin/sh -c` 가 앞에 붙은 형태로 보인다", "`bash -c echo hi` 처럼 `bash` 가 앞에 붙은 형태로 보인다", "`CMD echo hi` 처럼 입력한 글자 그대로 한 줄로 보인다"]', 1, 'exec 형식은 `[echo exec:$HOME]` 처럼 셸 없이 바로 저장됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 7, 'CMD 를 두 번 쓰면', 'Dockerfile 에 `CMD ["echo","first"]` 와 `CMD ["echo","second"]` 가 차례로 있으면 `docker run` 은 무엇을 출력할까요?', '하나만 효력이 있어요.', NULL, NULL, '[]', 'choice', '["`second` 만 출력된다. 마지막 `CMD` 만 효력이 있다", "`first` 만 출력된다. 먼저 나온 `CMD` 가 우선이고 뒤의 것은 무시된다", "`first` 와 `second` 가 차례로 출력된다. 모든 `CMD` 가 순서대로 실행된다", "빌드가 실패한다. `CMD` 는 Dockerfile 에 한 번만 쓸 수 있다"]', 0, '`docker image inspect --format ''{{.Config.Cmd}}''` 로 저장된 값을 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 8, '.dockerignore 로 제외', '`.dockerignore` 에 `secret.txt` 와 `sub` 를 적고 `COPY . /ctx/` 로 빌드하면 이미지 안 `/ctx` 에는 무엇이 들어갈까요?', '목록에 적은 것은 컨텍스트에 안 실려요.', NULL, NULL, '[]', 'choice', '["`secret.txt` 와 `sub` 만 들어가고 나머지 파일은 모두 빠진다", "모든 파일이 들어가고 `.dockerignore` 는 `docker run` 때만 쓰인다", "`.dockerignore` 와 `Dockerfile` 도 빠져서 나머지 파일만 들어간다", "`secret.txt` 와 `sub` 폴더는 빠지고 나머지 파일이 들어간다"]', 3, '`.dockerignore` 와 `Dockerfile` 자신도 따로 적지 않으면 `COPY . /ctx/` 로 복사됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 9, '.dockerignore 의 ! 예외', '`.dockerignore` 에 `*.log` 다음 줄에 `!keep.log` 를 적으면 `a.log` 와 `keep.log` 는 이미지에 들어갈까요?', '! 는 제외 목록에서 되살려요.', NULL, NULL, '[]', 'choice', '["둘 다 빠진다. `!` 는 `.dockerignore` 에서 쓰이지 않는 기호이다", "`a.log` 는 들어가고 `keep.log` 는 빠진다. `!` 는 그 줄을 제외 대상으로 만든다", "`a.log` 는 빠지고 `keep.log` 는 들어간다", "둘 다 들어간다. 패턴이 겹치면 `.dockerignore` 전체가 무시된다"]', 2, '`!` 줄은 앞에 있는 제외 패턴에서 일부를 다시 포함시킵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 10, 'COPY --chown', '`COPY --chown=1000:1000 app.txt /own/app.txt` 와 `COPY app.txt /own/root.txt` 로 복사한 두 파일의 소유자는 각각 누구일까요?', '옵션을 쓰지 않으면 root 예요.', NULL, NULL, '[]', 'choice', '["둘 다 `0`(root) 이고 `--chown` 은 `RUN chown` 으로만 적용된다", "앞은 UID `1000`, GID `1000` 이고 뒤는 `0`(root) 이다", "앞은 `0`(root) 이고 뒤는 UID `1000` 이라서 순서가 반대로 적용된다", "둘 다 UID `1000` 이다. 빌드한 사용자의 UID 가 자동으로 쓰인다"]', 1, '컨테이너 안에서 `ls -ln` 으로 소유자 숫자를 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 11, 'LABEL 과 label 필터', '`LABEL team=blue` 로 만든 이미지가 있을 때 `docker images --filter label=team=blue` 와 `label=team=red` 는 각각 무엇을 보여 줄까요?', '필터는 값까지 비교해요.', NULL, NULL, '[]', 'choice', '["앞은 그 이미지를 보여 주고, 뒤는 아무것도 보여 주지 않는다", "앞과 뒤 모두 그 이미지를 보여 주고 `label` 은 키만 비교한다", "앞은 아무것도 보여 주지 않고 뒤는 그 이미지를 보여 준다", "둘 다 오류가 나서 `label` 필터는 컨테이너에서만 쓸 수 있다"]', 0, '값을 빼고 `label=team` 으로 쓰면 키만 비교합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 12, 'RUN 과 CMD 의 시점', '`RUN echo build-time-msg` 와 `CMD ["echo","run-time-msg"]` 가 있을 때 두 메시지는 언제 보일까요?', '하나는 빌드, 하나는 실행이에요.', NULL, NULL, '[]', 'choice', '["`build-time-msg` 는 `docker run` 할 때, `run-time-msg` 는 빌드 로그에 보인다", "둘 다 빌드 로그에 보이고 `docker run` 은 아무것도 출력하지 않는다", "둘 다 `docker run` 할 때 보이고 빌드 로그에는 아무것도 보이지 않는다", "`build-time-msg` 는 빌드 로그에, `run-time-msg` 는 `docker run` 할 때 보인다"]', 3, '`RUN` 은 빌드 때 한 번 실행되어 결과가 이미지에 남고 `CMD` 는 컨테이너를 시작할 때 실행됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 13, 'build --label', '`docker build --label owner=me -t x .` 로 만든 이미지의 라벨은 어떻게 확인할까요?', 'Dockerfile 을 고치지 않아도 붙어요.', NULL, NULL, '[]', 'choice', '["Dockerfile 에 같은 `LABEL` 을 적어야만 붙고 없으면 무시된다", "컨테이너를 `docker run` 할 때만 붙고 이미지에는 남지 않는다", "Dockerfile 에 `LABEL` 이 없어도 `docker image inspect` 의 라벨에 `owner=me` 가 들어 있다", "빌드 로그에만 보이고 `docker image inspect` 에는 나오지 않는다"]', 2, '`docker images --filter label=owner=me` 로 찾을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 14, 'ENTRYPOINT sleep 과 CMD 1', '`ENTRYPOINT ["sleep"]`, `CMD ["1"]` 이미지에서 `docker run 이미지 echo hi` 를 실행하면 어떻게 될까요?', 'run 뒤의 내용은 sleep 의 인자가 돼요.', NULL, NULL, '[]', 'choice', '["`echo hi` 가 실행되어 `hi` 가 출력되고 종료 코드는 `0` 이다", "`sleep echo hi` 가 되어 `invalid number` 오류와 함께 종료 코드 `1` 로 끝난다", "`sleep 1` 이 실행되고 `echo hi` 는 무시되어 종료 코드는 `0` 이다", "`hi` 가 출력된 뒤 `sleep 1` 이 이어서 실행되고 종료 코드는 `0` 이다"]', 1, '`docker run 이미지 2` 는 `sleep 2` 가 되어 2초 쉬고 끝납니다. 다른 명령을 실행하려면 `--entrypoint` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 15, '기본 실행 명령', 'Dockerfile 에서 **컨테이너를 시작할 때 실행할 기본 명령을 적는** 지시어를 채우세요.', '"명령"을 뜻하는 command 의 약자예요.', NULL, NULL, '[]', 'fill', '["RUN", "START", "EXEC", "CMD"]', NULL, '`docker run` 뒤에 명령을 적으면 바뀝니다.', '[3]', '{0} ["echo","hi"]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 16, '빌드 중 실행', 'Dockerfile 에서 **이미지를 만드는 동안 명령을 실행하는** 지시어를 채우세요.', '"실행하다"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["RUN", "CMD", "DO", "EXEC"]', NULL, '결과는 이미지의 한 층으로 남습니다.', '[0]', '{0} apk add curl', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 17, '고정 진입점', 'Dockerfile 에서 **컨테이너가 시작할 때 늘 실행되는 실행 파일을 정하는** 지시어를 채우세요.', '"진입점"을 영어로 이어 써요.', NULL, NULL, '[]', 'fill', '["CMD", "ENTRYPOINT", "BOOT", "INIT"]', NULL, '`CMD` 는 그 뒤에 붙는 기본 인자가 됩니다.', '[1]', '{0} ["echo","base"]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 18, '진입점 바꾸기', '`docker run` 에서 **이미지의 진입점을 바꾸는** 옵션을 채우세요.', '"진입점"을 영어로 써요.', NULL, NULL, '[]', 'fill', '["command", "exec", "entrypoint", "cmd"]', NULL, '이 옵션을 주면 이미지의 `CMD` 는 쓰이지 않습니다.', '[2]', 'docker run --{0} sh 이미지', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 19, '라벨 붙이기', 'Dockerfile 에서 **이미지에 `key=value` 정보를 붙이는** 지시어를 채우세요.', '"이름표"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["TAG", "NAME", "META", "LABEL"]', NULL, '`docker image inspect` 로 확인할 수 있습니다.', '[3]', '{0} team=blue', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 20, '라벨로 이미지 거르기', '`docker images` 에서 **라벨 값으로 이미지를 거르는** 필터 이름을 채우세요.', '"이름표"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["label", "tag", "name", "meta"]', NULL, '값 없이 `label=team` 으로 쓰면 키만 비교합니다.', '[0]', 'docker images --filter {0}=team=blue', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 21, '빌드 때 라벨', '`docker build` 에서 **Dockerfile 을 고치지 않고 라벨을 붙이는** 옵션을 채우세요.', '"이름표"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["tag", "label", "meta", "set"]', NULL, '여러 개는 옵션을 반복합니다.', '[1]', 'docker build --{0} owner=me -t x .', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 22, '복사하면서 소유자 정하기', '`COPY` 에서 **복사한 파일의 소유자를 정하는** 옵션을 채우세요.', '"소유자 바꾸기" 명령과 같아요.', NULL, NULL, '[]', 'fill', '["owner", "user", "chown", "uid"]', NULL, '옵션을 쓰지 않으면 소유자는 root 입니다.', '[2]', 'COPY --{0}=1000:1000 app.txt /own/', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 23, '빌드 제외 목록 파일', '빌드 컨텍스트에서 **제외할 이름을 적는** 파일 이름의 빠진 부분을 채우세요.', '"도커"와 "무시"를 이어 써요.', NULL, NULL, '[]', 'fill', '["buildignore", "ignoredocker", "dockerskip", "dockerignore"]', NULL, '컨텍스트 폴더 맨 위에 둡니다.', '[3]', '.{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 24, '제외에서 되살리기', '`.dockerignore` 에서 **앞 패턴으로 제외된 파일을 다시 포함시키는** 줄머리 기호를 채우세요.', '"아님"을 뜻하는 기호예요.', NULL, NULL, '[]', 'fill', '["!", "-", "+", "~"]', NULL, '`*.log` 같은 제외 패턴 다음 줄에 씁니다.', '[0]', '{0}keep.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 25, '셸 형식이 쓰는 셸', '셸 형식으로 쓴 `CMD` 가 저장될 때 **앞에 붙는 셸** 이름을 채우세요.', '"/bin/" 다음에 가장 기본 셸이 와요.', NULL, NULL, '[]', 'fill', '["bash", "sh", "zsh", "exec"]', NULL, 'exec 형식은 이런 셸 없이 바로 실행됩니다.', '[1]', '[/bin/{0} -c echo hi]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 26, 'CMD 덮어쓰기 확인', '`CMD` 가 기본값이라는 것을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '빌드 → 기본 실행 → 덮어쓰기 → 저장값 순서예요.', NULL, NULL, '[]', 'order', '["`docker image inspect` 로 이미지에 저장된 `CMD` 는 그대로인지 확인한다", "`docker run 이미지 echo x` 로 `x` 만 나오는지 확인한다", "`CMD [\\"echo\\",\\"default-cmd\\"]` 가 든 이미지를 빌드한다", "`docker run 이미지` 로 `default-cmd` 가 나오는지 확인한다"]', NULL, '`docker run` 에서 덮어쓴 값은 이미지에 저장되지 않습니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 27, 'ENTRYPOINT 와 CMD 확인', '`ENTRYPOINT` 와 `CMD` 의 역할을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '빌드 → 기본 → 인자 → 진입점 변경 순서예요.', NULL, NULL, '[]', 'order', '["`docker run 이미지 b` 로 `base b` 가 나오는지 확인한다", "`docker run --entrypoint echo 이미지` 로 빈 줄만 나오는지 확인한다", "`docker run 이미지` 로 `base default` 가 나오는지 확인한다", "`ENTRYPOINT [\\"echo\\",\\"base\\"]` 와 `CMD [\\"default\\"]` 이미지를 빌드한다"]', NULL, '`--entrypoint` 를 주면 이미지의 `CMD` 는 쓰이지 않습니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 28, '.dockerignore 확인', '`.dockerignore` 가 제외하는 것을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '파일 만들기 → 목록 → 빌드 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`COPY . /ctx/` 가 든 Dockerfile 로 이미지를 빌드한다", "`secret.txt`, `app.txt` 와 `sub` 폴더를 만든다", "`docker run 이미지 ls -A /ctx` 로 `app.txt` 만 있고 `secret.txt` 는 없는지 확인한다", "`.dockerignore` 에 `secret.txt` 와 `sub` 를 적는다"]', NULL, '`.dockerignore` 와 `Dockerfile` 도 함께 복사되므로 목록에 같이 보입니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 29, '셸 형식과 exec 형식 비교', '두 형식의 차이를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '빌드 → 셸 형식 → exec 형식 → 저장 모양 순서예요.', NULL, NULL, '[]', 'order', '["셸 형식 이미지를 실행해 `/home/x` 가 출력되는지 확인한다", "`docker image inspect` 로 셸 형식에만 `/bin/sh -c` 가 붙어 있는지 확인한다", "`ENV HOME=/home/x` 와 두 형식의 `CMD` 로 이미지를 각각 빌드한다", "exec 형식 이미지를 실행해 `$HOME` 이 그대로 출력되는지 확인한다"]', NULL, 'exec 형식에서 변수를 풀려면 `["sh","-c","echo $HOME"]` 처럼 씁니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 29);
