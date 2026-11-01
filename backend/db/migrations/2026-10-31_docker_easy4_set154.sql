-- 도커 세트 154. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set154.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 154, 'Dockerfile 심화, 변수와 명령, 멀티스테이지, 이미지 옮기기 한 줄씩', 'Dockerfile 과 이미지를 다루는 기본기를 한 개념씩 반복합니다. COPY 와 ADD 의 차이, ARG 와 ENV(빌드 때만 보이는 변수), --build-arg, CMD 의 쉘 형식과 exec 형식, CMD 와 ENTRYPOINT 의 차이와 함께 쓸 때의 인자, --entrypoint, 멀티스테이지 빌드로 이미지 줄이기, 같은 RUN 에서 지워야 크기가 주는 이유, docker history, save 와 load 로 이미지 옮기기, --env-file 을 짧은 객관식·빈칸·순서 문제로 익히고, 빌드 변수 확인, 멀티스테이지로 줄이기, 인터넷 없는 서버로 옮기기, 큰 이미지 원인 찾기의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 154);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🧊' WHERE id = 154;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 1, 'COPY 와 ADD', 'Dockerfile 의 `COPY pkg.tgz /c/` 와 `ADD pkg.tgz /a/` 의 차이로 알맞은 것은 무엇일까요?', '하나는 그대로 복사하고, 하나는 풀어 줘요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`COPY` 는 압축을 풀고 `ADD` 는 그대로 복사한다", "`COPY` 는 파일을 그대로 복사하고, `ADD` 는 로컬 tar 압축 파일을 풀어 넣는다 (그래서 단순 복사에는 `COPY` 를 권장한다)", "`ADD` 는 파일을 삭제한다"]', 2, '`ADD` 는 압축 해제 같은 부가 기능이 있어 의도치 않은 동작이 생기기 쉽습니다. 특별한 이유가 없으면 `COPY` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 2, 'ARG 란', 'Dockerfile 의 `ARG VER=1` 은 무엇일까요?', '이미지를 만들 때만 쓰는 변수예요.', NULL, NULL, '[]', 'choice', '["컨테이너를 실행할 때만 쓰는 변수", "이미지를 빌드할 때만 쓰는 변수 (`--build-arg` 로 값을 바꿀 수 있다)", "이미지의 이름을 정하는 변수", "컨테이너의 인자를 정하는 변수"]', 1, '빌드 중 `RUN` 에서는 `$VER` 로 쓸 수 있지만, 만들어진 이미지로 컨테이너를 실행하면 `ARG` 값은 보이지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 3, 'ARG 와 ENV', '`ARG VER` 로 받은 값을 컨테이너가 실행 중에도 읽게 하려면 어떻게 할까요?', 'ARG 는 빌드가 끝나면 사라져요.', NULL, NULL, '[]', 'choice', '["`ENV APP_VER=$VER` 처럼 `ENV` 로 넘겨야 실행 중에도 환경 변수로 보인다", "`ARG` 만 쓰면 실행 중에도 자동으로 보인다", "`CMD` 에 적으면 보인다", "`ARG` 값은 항상 실행 중에도 보이므로 아무것도 안 해도 된다"]', 0, '비밀번호를 `ARG` 나 `ENV` 로 넣으면 `docker history` 에 남을 수 있으니 이미지에 넣지 마세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 4, '--build-arg', '`docker build --build-arg VER=2 -t app .` 의 `--build-arg VER=2` 는 무엇을 할까요?', '빌드에서 쓰는 변수의 값을 정해요.', NULL, NULL, '[]', 'choice', '["컨테이너를 2개 실행한다", "이미지 이름을 VER 로 바꾼다", "빌드를 2번 반복한다", "Dockerfile 의 `ARG VER` 의 값을 `2` 로 정해서 빌드한다"]', 3, 'Dockerfile 에 `ARG VER` 가 선언되어 있어야 값이 전달됩니다. 선언이 없으면 경고가 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 5, 'CMD 의 두 가지 형식', '`ENV N=etude` 가 있을 때 `CMD echo shell-$N` 과 `CMD ["echo","exec-$N"]` 의 출력은 각각 무엇일까요?', '쉘을 거치는 형식과 거치지 않는 형식이에요.', NULL, NULL, '[]', 'choice', '["둘 다 `etude` 가 치환된다", "둘 다 `$N` 이 그대로 나온다", "`shell-etude`(쉘 형식은 변수가 치환됨) 와 `exec-$N`(exec 형식은 쉘을 거치지 않아 글자 그대로)", "`exec-etude` 와 `shell-$N`"]', 2, '변수 치환이 필요하면 쉘 형식이거나 `["sh","-c","echo $N"]` 으로 직접 쉘을 호출해야 합니다. exec 형식은 종료 신호를 앱이 직접 받는 장점이 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 6, 'CMD 와 ENTRYPOINT', 'Dockerfile 의 `CMD` 와 `ENTRYPOINT` 의 차이로 알맞은 것은 무엇일까요?', '하나는 바꾸기 쉬운 기본값, 하나는 고정된 실행 파일이에요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`CMD` 는 `docker run` 뒤에 명령을 주면 쉽게 대체되는 기본 명령이고, `ENTRYPOINT` 는 컨테이너가 항상 실행할 고정된 프로그램이다", "`ENTRYPOINT` 가 대체되기 쉽고 `CMD` 는 고정이다", "둘 다 빌드할 때만 실행된다"]', 1, '실행 파일은 `ENTRYPOINT`, 기본 인자는 `CMD` 로 나눠 쓰는 패턴이 흔합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 7, 'ENTRYPOINT 와 CMD 함께', '`ENTRYPOINT ["echo","entry:"]` 와 `CMD ["default"]` 인 이미지를 `docker run 이미지 custom-arg` 로 실행하면 무엇이 출력될까요?', '이미지 이름 뒤의 값은 CMD 를 대체해요.', NULL, NULL, '[]', 'choice', '["`entry: custom-arg` (뒤에 준 값이 `CMD` 를 대체해 `ENTRYPOINT` 의 인자가 된다)", "`entry: default`", "`custom-arg` 만", "오류가 난다"]', 0, '인자를 주지 않으면 `entry: default` 가 나옵니다. `CMD` 는 `ENTRYPOINT` 의 기본 인자 역할을 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 8, '--entrypoint', '`docker run --entrypoint sh 이미지 -c "echo x"` 는 무엇을 할까요?', '고정된 실행 파일을 일시적으로 바꿔요.', NULL, NULL, '[]', 'choice', '["`ENTRYPOINT` 를 영구히 지운다", "이미지를 새로 빌드한다", "컨테이너를 삭제한다", "이미지의 `ENTRYPOINT` 를 `sh` 로 바꿔 실행한다 (문제가 있는 이미지를 안에서 살펴볼 때 유용하다)"]', 3, '`ENTRYPOINT` 가 앱을 바로 실행해서 컨테이너가 계속 죽을 때 `sh` 로 들어가 확인하는 용도로 자주 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 9, 'run 뒤의 명령', '`CMD ["echo","from-cmd"]` 인 이미지를 `docker run 이미지 echo overridden` 으로 실행하면 어떻게 될까요?', '이미지 이름 뒤에 쓴 것이 우선해요.', NULL, NULL, '[]', 'choice', '["`from-cmd` 가 출력된다", "둘 다 출력된다", "`overridden` 이 출력된다. 이미지 이름 뒤의 명령이 `CMD` 를 대체한다", "오류가 난다"]', 2, '`CMD` 는 "기본값"이라 실행할 때 언제든 대체할 수 있습니다. 고정하고 싶다면 `ENTRYPOINT` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 10, '멀티스테이지 빌드', '멀티스테이지 빌드(`FROM ... AS builder` 와 `COPY --from=builder`)를 쓰는 가장 큰 이유는 무엇일까요?', '빌드에만 필요한 것을 최종 이미지에 남기지 않아요.', NULL, NULL, '[]', 'choice', '["빌드를 더 빠르게 만들려고", "빌드 도구와 중간 파일을 최종 이미지에 남기지 않고 결과물만 가져와 이미지를 작게 만들려고", "컨테이너를 여러 개 동시에 실행하려고", "이미지를 암호화하려고"]', 1, '큰 중간 파일(예: 30MB)을 만든 뒤 결과물만 복사하면 최종 이미지는 알파인 기본 크기(약 4MB)로 남습니다. 한 단계로 만들면 중간 파일 때문에 훨씬 커져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 11, 'RUN 에서 지워도', '앞의 `RUN` 에서 만든 큰 파일을 다음 `RUN rm /big` 으로 지웠습니다. 최종 이미지의 크기는 어떨까요?', '레이어는 쌓이기만 해요.', NULL, NULL, '[]', 'choice', '["크기가 줄지 않는다. 앞 레이어에는 파일이 그대로 남아 있다. 만든 줄과 같은 `RUN` 에서 `&& rm` 으로 지워야 크기가 준다", "지운 만큼 줄어든다", "삭제한 레이어가 앞 레이어를 덮어써서 항상 작아진다", "이미지가 깨진다"]', 0, '파일은 보이지 않을 뿐 이전 레이어에 남아 있습니다. 설치 후 캐시를 지울 때도 같은 `RUN` 안에서 정리하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 12, 'docker history', '`docker history 이미지` 는 무엇을 보여 줄까요?', '이미지가 어떻게 쌓였는지 보여 줘요.', NULL, NULL, '[]', 'choice', '["컨테이너의 실행 기록", "이미지를 내려받은 시각만", "레지스트리의 주소", "이미지를 이루는 레이어별로 만든 명령과 크기"]', 3, '크기가 큰 레이어가 어떤 `RUN` 에서 생겼는지 찾을 때 씁니다. 그 줄을 줄이면 이미지가 작아져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 13, 'docker save 와 load', '인터넷이 없는 서버로 이미지를 옮기려면 어떤 명령 조합을 쓸까요?', '이미지를 파일 하나로 묶었다 푸는 명령이에요.', NULL, NULL, '[]', 'choice', '["`docker copy` 와 `docker paste`", "`docker push` 만 하면 인터넷 없이도 된다", "`docker save -o app.tar 이미지` 로 파일로 묶고, 옮긴 서버에서 `docker load -i app.tar` 로 불러온다", "`docker build` 를 서버에서 다시 한다"]', 2, '파일은 USB 나 `scp` 로 옮깁니다. 불러온 뒤 `docker images` 로 이미지가 들어왔는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 14, '--env-file', '`docker run --env-file app.env 이미지` 는 무엇을 할까요?', '환경 변수를 파일 하나에 모아 둘 수 있어요.', NULL, NULL, '[]', 'choice', '["`app.env` 를 컨테이너 안으로 복사한다", "`app.env` 파일에 적힌 `이름=값` 줄들을 환경 변수로 한꺼번에 전달한다", "환경 변수를 모두 삭제한다", "이미지의 `ENV` 를 영구히 바꾼다"]', 1, '변수가 많을 때 `-e` 를 여러 번 쓰지 않아도 됩니다. 비밀번호가 든 파일은 Git 에 올리지 않게 조심하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 15, '압축 풀며 넣기', '로컬 `pkg.tgz` 를 **압축을 풀면서** 이미지에 넣는 Dockerfile 명령어를 채우세요.', '"더하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["ADD", "COPY", "PUT", "UNPACK"]', NULL, '`COPY` 는 압축 파일을 그대로 둡니다. 압축을 풀어야 한다면 `ADD` 를 쓰되, 그렇지 않으면 `COPY` 가 안전해요.', '[0]', '{0} pkg.tgz /a/', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 16, '빌드 변수 선언', '이미지를 만들 때만 쓰는 **변수를 선언**하는 Dockerfile 명령어를 채우세요.', '"인자"를 뜻하는 argument 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["ARG", "ENV", "VAR", "PARAM"]', NULL, '`ENV` 는 실행 중에도 남는 환경 변수입니다. 빌드 중에만 필요하면 `ARG` 를 쓰세요.', '[0]', '{0} VER=1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 17, '빌드할 때 값 넘기기', '`docker build` 에서 `ARG VER` 의 값을 `2` 로 **넘기는** 옵션 이름을 채우세요.', '"빌드"와 "인자"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["build-arg", "arg", "env", "set"]', NULL, '`--env` 는 `docker build` 에 없는 옵션입니다. 빌드 변수는 `--build-arg` 로 넘겨요.', '[0]', 'docker build --{0} VER=2 -t app .', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 18, '고정 실행 파일', '컨테이너가 **항상 실행할 프로그램**을 정하는 Dockerfile 명령어를 채우세요.', '"진입점"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["ENTRYPOINT", "CMD", "RUN", "START"]', NULL, '`RUN` 은 빌드 중에 한 번 실행하는 명령입니다. 컨테이너를 시작할 때 실행하는 것과 혼동하지 마세요.', '[0]', '{0} ["echo","entry:"]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 19, '실행 파일 바꿔 들어가기', '`ENTRYPOINT` 를 **쉘로 바꿔서** 컨테이너 안을 살펴보려고 합니다. 옵션 이름을 채우세요.', '"진입점"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["entrypoint", "cmd", "shell", "exec"]', NULL, '`docker run 이미지 sh` 처럼 이름 뒤에 쓰면 `CMD` 만 바뀌어 `ENTRYPOINT` 의 인자가 됩니다. 실행 파일을 바꾸려면 `--entrypoint` 예요.', '[0]', 'docker run --{0} sh app -c "echo x"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 20, '빌드 단계에 이름 붙이기', '멀티스테이지에서 첫 단계에 **`builder` 라는 이름**을 붙이는 키워드를 채우세요.', '"~로서"라는 뜻의 아주 짧은 영어 단어예요.', NULL, NULL, '[]', 'fill', '["AS", "NAME", "IS", "TAG"]', NULL, '이름을 붙여 두면 다음 단계에서 `COPY --from=builder` 로 이 단계의 결과물을 가져올 수 있습니다.', '[0]', 'FROM alpine {0} builder', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 21, '앞 단계에서 가져오기', '이름 붙인 앞 단계 `builder` 에서 **결과물을 가져오는** 옵션 이름을 채우세요.', '"~로부터"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["from", "stage", "src", "of"]', NULL, '`COPY --from=builder` 로 가져온 것만 최종 이미지에 들어갑니다. 중간 파일은 빌드 단계에 남아 버려져요.', '[0]', 'COPY --{0}=builder /app.txt /app.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 22, '이미지 레이어 보기', '이미지의 **레이어별 명령과 크기**를 보는 명령입니다. 빈칸을 채우세요.', '"역사"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["history", "layers", "log", "steps"]', NULL, '어느 줄에서 이미지가 커졌는지 찾는 데 쓰입니다. 큰 레이어를 만든 `RUN` 을 줄이세요.', '[0]', 'docker {0} app', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 23, '이미지를 파일로 묶기', '이미지를 `app.tar` 파일 하나로 **묶는** 명령입니다. 빈칸을 채우세요.', '"저장하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["save", "export", "dump", "pack"]', NULL, '`docker export` 는 컨테이너의 파일 시스템만 내보내는 다른 명령입니다. 이미지를 통째로 옮길 때는 `save` 예요.', '[0]', 'docker {0} -o app.tar app', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 24, '파일에서 이미지 불러오기', '`app.tar` 파일에서 이미지를 **불러오는** 명령입니다. 빈칸을 채우세요.', '"적재하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["load", "import", "restore", "open"]', NULL, '`docker import` 는 파일 시스템 tar 를 이미지로 만드는 다른 명령입니다. `save` 로 만든 파일은 `load` 로 불러와요.', '[0]', 'docker {0} -i app.tar', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 25, '환경 변수 파일', '파일 `app.env` 의 변수들을 **한꺼번에 전달**하는 옵션 이름을 채우세요.', '"환경"과 "파일"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["env-file", "envfile", "env", "file"]', NULL, '파일의 각 줄은 `이름=값` 모양이어야 합니다. 따옴표는 값의 일부로 들어가니 주의하세요.', '[0]', 'docker run --{0} app.env alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 26, '빌드 변수를 쓰고 확인하기', '`ARG` 로 받은 값이 실행 중에 쓰이는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '선언 → 빌드 → 실행 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["Dockerfile 에 `ARG VER=1` 과 `ENV APP_VER=$VER` 를 쓴다", "`docker build --build-arg VER=2 -t app .` 로 빌드한다", "`docker run --rm app env` 로 `APP_VER=2` 가 들어갔는지 본다", "실행 중에 필요한 값은 `ENV` 로 넘겼는지 한 번 더 확인한다"]', NULL, '`ARG` 만 쓰면 컨테이너에서는 보이지 않습니다. 실행 중에 쓸 값은 `ENV` 로 넘겨야 해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 27, '멀티스테이지로 이미지 줄이기', '이미지를 멀티스테이지로 다시 만들어 크기를 줄이는 순서입니다. 순서에 맞게 놓아 보세요.', '크기 확인 → 단계 나누기 → 결과만 복사 → 다시 비교 순서예요.', NULL, NULL, '[]', 'order', '["`docker image ls` 로 현재 이미지의 크기를 확인한다", "빌드 단계를 `FROM ... AS builder` 로 나눈다", "최종 단계에서 `COPY --from=builder` 로 결과물만 가져온다", "다시 빌드해 `docker image ls` 로 크기가 줄었는지 비교한다"]', NULL, '결과물이 실제로 실행되는지도 꼭 확인하세요. 빠뜨린 파일이 있으면 최종 이미지에서 실행이 실패해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 28, '인터넷 없는 서버로 이미지 옮기기', '인터넷이 없는 서버로 이미지를 옮겨 쓰는 순서입니다. 순서에 맞게 놓아 보세요.', '묶기 → 옮기기 → 불러오기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker save -o app.tar app:1.0` 로 이미지를 파일로 묶는다", "`scp` 나 USB 로 `app.tar` 를 서버로 옮긴다", "서버에서 `docker load -i app.tar` 로 이미지를 불러온다", "`docker images` 로 이미지가 들어왔는지 확인한다"]', NULL, '옮긴 뒤 파일의 크기나 해시를 비교하면 전송이 깨지지 않았는지 알 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 29, '이미지가 왜 큰지 찾기', '이미지가 필요 이상으로 클 때 원인을 찾는 순서입니다. 순서에 맞게 놓아 보세요.', '크기 확인 → 레이어 보기 → 원인 줄 찾기 → 고치고 비교 순서예요.', NULL, NULL, '[]', 'order', '["`docker image ls` 로 이미지의 크기를 확인한다", "`docker history 이미지` 로 레이어별 크기를 본다", "큰 레이어를 만든 `RUN` 줄에서 지운 파일이 같은 `RUN` 안에서 정리됐는지 확인한다", "고쳐서 다시 빌드하고 크기를 비교한다"]', NULL, '앞 레이어에 남은 파일은 다음 줄에서 지워도 크기가 줄지 않습니다. 같은 `RUN` 안에서 정리하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 29);
