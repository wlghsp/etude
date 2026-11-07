-- 도커 세트 212. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set212.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 212, '컨테이너 상태와 종료 코드: ps -q·--filter, 125·126·127, wait, rename, pause, stop·kill, logs, exec -w·-e, prune', '컨테이너 상태를 읽고 다루는 기본 동작을 한 개념씩 반복합니다. docker ps 의 -q 와 -aq, --filter 를 여러 번 쓸 때의 조건, 컨테이너 안 명령의 종료 코드와 STATUS 의 Exited, 종료 코드 125·126·127 의 뜻, wait 의 동작, rename 과 이름 충돌, pause 한 컨테이너의 Paused 상태와 exec 오류, stop 과 kill 의 종료 코드 137 과 0, logs 의 --tail 과 -t, exec 의 -w 와 -e, 이름 충돌과 --rm, system df 의 열, container prune 의 확인과 -f, -i 와 파이프 입력을 짧은 객관식·빈칸·순서 문제로 익히고, 종료 코드 확인하기, 멈추고 다시 이어서 실행, 로그 줄여 보기, 정지한 컨테이너 정리의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 212);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🧿' WHERE id = 212;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 1, 'ps -q 와 -aq', '`docker ps -q` 와 `docker ps -aq` 는 무엇을 출력할까요?', 'q 는 quiet, 조용히 ID 만 보여 줘요.', NULL, NULL, '[]', 'choice', '["`-q` 는 이름만, `-aq` 는 이미지 ID 만 출력한다", "`-q` 는 정지된 것만, `-aq` 는 실행 중인 것만 출력한다", "`docker ps -q` 는 실행 중인 컨테이너의 ID(12자리)만 한 줄씩 출력하고, `-aq` 는 정지된 컨테이너까지 모두 포함한다. 다른 명령에 `$(docker ps -aq)` 처럼 넘길 때 쓴다", "둘 다 표 전체를 출력하고 차이는 정렬 순서뿐이다"]', 2, '`docker rm -f $(docker ps -aq)` 는 모든 컨테이너를 지우므로 조심해서 써야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 2, '--filter 를 여러 번 쓰면', '`docker ps -a --filter name=web --filter status=exited` 처럼 `--filter` 를 두 번 쓰면 어떤 컨테이너가 나올까요?', '조건을 모두 만족해야 해요.', NULL, NULL, '[]', 'choice', '["둘 중 하나만 만족해도 모두 나온다", "두 조건을 모두 만족하는 컨테이너만 나온다. 이름 조건에 맞아도 실행 중이면 `status=exited` 조건 때문에 빠진다", "마지막 `--filter` 하나만 적용된다", "`--filter` 는 한 번만 쓸 수 있어서 오류가 난다"]', 1, '`--filter label=키` 처럼 라벨로도 거를 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 3, '컨테이너의 종료 코드', '`docker run alpine sh -c ''exit 3''` 를 하고 바로 `echo $?` 를 하면 무엇이 나올까요? `docker ps -a` 의 STATUS 는 어떻게 보일까요?', '컨테이너 안 명령의 종료 코드가 그대로 와요.', NULL, NULL, '[]', 'choice', '["`3` 이 출력되고 STATUS 는 `Exited (3)` 으로 보인다. `docker run` 은 컨테이너 안 명령의 종료 코드를 그대로 돌려준다", "`0` 이 출력되고 STATUS 는 `Exited (0)` 이다", "`125` 가 출력되고 STATUS 는 `Created` 이다", "`3` 이 출력되지만 STATUS 는 `Up` 으로 보인다"]', 0, '종료 코드 `0` 은 성공, 그 밖의 값은 실패를 뜻합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 4, '125, 126, 127', '`docker run` 이 종료 코드 `125`, `126`, `127` 로 끝났습니다. 각각 무슨 뜻일까요?', '125 는 도커 자체의 문제, 나머지는 컨테이너 안 명령의 문제예요.', NULL, NULL, '[]', 'choice', '["`125` 는 명령을 찾지 못함, `126` 은 도커 오류, `127` 은 실행할 수 없음이다", "셋 모두 이미지를 내려받지 못했다는 뜻이다", "`125`, `126`, `127` 은 컨테이너가 신호로 끝났다는 뜻이다", "`125` 는 도커 자체의 오류(예: 없는 옵션), `126` 은 명령을 찾았지만 실행할 수 없음(예: 실행 파일이 아닌 `/etc/passwd`), `127` 은 명령을 찾지 못함이다"]', 3, '`sh -c ''nosuchcmd''` 로 실행하면 셸이 `not found` 를 알리고 `127` 로 끝납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 5, 'docker wait', '`docker wait c1` 은 무엇을 할까요? 이미 끝난 컨테이너에 쓰면요?', '기다렸다가 종료 코드를 알려 줘요.', NULL, NULL, '[]', 'choice', '["컨테이너를 정지시킨 뒤 `0` 을 출력한다", "컨테이너가 시작할 때까지 기다리고 아무것도 출력하지 않는다", "컨테이너가 끝날 때까지 기다린 뒤 종료 코드를 출력한다. 이미 끝난 컨테이너에는 기다리지 않고 바로 종료 코드를 출력한다", "이미 끝난 컨테이너에는 오류가 난다"]', 2, '스크립트에서 컨테이너 작업의 성공 여부를 확인할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 6, 'docker rename', '`docker rename old new` 를 하면 어떻게 될까요? 이미 있는 이름으로 바꾸려 하면요?', '이름만 바뀌고 컨테이너는 그대로예요.', NULL, NULL, '[]', 'choice', '["컨테이너가 복제되어 `old` 와 `new` 가 둘 다 남는다", "컨테이너의 이름만 바뀌고 옛 이름은 사라진다. 이미 쓰고 있는 이름이면 `Conflict. The container name ... is already in use` 오류가 난다", "컨테이너가 재시작되고 이름이 바뀐다", "이미 있는 이름이면 그 컨테이너를 지우고 바꾼다"]', 1, '실행 중인 컨테이너도 이름을 바꿀 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 7, 'docker pause', '실행 중인 컨테이너에 `docker pause c1` 을 하면 `docker ps` 의 STATUS 는 어떻게 보일까요? 그때 `docker exec c1 echo hi` 를 하면요?', '멈췄지만 종료된 것은 아니에요.', NULL, NULL, '[]', 'choice', '["STATUS 에 `Up ... (Paused)` 로 보이고, `exec` 는 `is paused, unpause the container before exec` 오류가 난다. `docker unpause c1` 을 하면 다시 `exec` 할 수 있다", "STATUS 가 `Exited` 로 바뀌고 `exec` 는 정상으로 된다", "STATUS 는 그대로이고 `exec` 만 몇 초 느려진다", "컨테이너가 지워진다"]', 0, '`pause` 는 컨테이너 안의 프로세스를 멈춰 두는 것이고 `stop` 과 다릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 8, 'stop 과 kill 의 종료 코드', '`sleep 300` 을 실행하는 컨테이너를 `docker stop -t 1` 로 멈추거나 `docker kill` 로 멈추면 종료 코드는 얼마일까요? 신호를 받으면 스스로 `exit 0` 하는 프로그램은요?', '강제로 끝나면 128 에 신호 번호를 더해요.', NULL, NULL, '[]', 'choice', '["둘 다 항상 `0` 이다", "`stop` 은 항상 `143`, `kill` 은 항상 `137` 이다", "컨테이너는 종료 코드를 남기지 않는다", "`sleep` 은 두 경우 모두 `137`(128 + 9) 이고, 신호를 받아 스스로 `exit 0` 하는 프로그램을 `docker stop` 하면 `0` 이다"]', 3, '`docker inspect c1 --format` 의 `.State.ExitCode` 로 종료 코드를 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 9, 'docker logs 옵션', '컨테이너가 `line1` 부터 `line5` 까지 출력했습니다. `docker logs --tail=2 c1` 은 무엇을 보여 주고, `-t` 를 붙이면 어떻게 달라질까요?', 'tail 은 끝에서 몇 줄이에요.', NULL, NULL, '[]', 'choice', '["`--tail=2` 는 처음 두 줄만 보여 주고 `-t` 는 로그를 파일로 저장한다", "`--tail=2` 는 두 번째 줄만 보여 주고 `-t` 는 터미널을 연결한다", "`--tail=2` 는 마지막 두 줄인 `line4`, `line5` 만 보여 주고, `-t` 를 붙이면 각 줄 앞에 날짜와 시간(타임스탬프)이 붙는다", "`--tail=2` 는 로그를 두 줄로 줄여 저장한다"]', 2, '`--since=1h` 는 최근 1시간의 로그만 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 10, 'exec 의 -w 와 -e', '`docker exec -w /tmp c1 pwd` 는 무엇을 출력할까요? `docker exec -e GREET=hello c1 ...` 로 준 변수는 다음 `docker exec` 에도 남아 있을까요?', '-w 는 작업 폴더, -e 는 환경 변수예요.', NULL, NULL, '[]', 'choice', '["`/` 가 출력되고 `-w` 는 무시된다", "`/tmp` 가 출력된다. `-w` 는 명령을 실행할 작업 폴더를 정한다. `-e` 로 준 변수는 그 `exec` 에서만 쓰이고 다음 `exec` 에는 남지 않는다", "`-e` 로 준 변수는 컨테이너에 저장되어 다음 `exec` 에도 남는다", "`-w` 는 컨테이너를 재시작한다"]', 1, '`-u nobody` 처럼 사용자를 정할 수도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 11, '이름 충돌과 --rm', '이미 `web` 이라는 이름의 컨테이너가 있는데 `docker run --name web ...` 를 또 하면 어떻게 될까요? `--rm` 을 붙여 실행한 컨테이너는 끝나면 어떻게 될까요?', '이름은 하나만 쓸 수 있어요.', NULL, NULL, '[]', 'choice', '["`Conflict. The container name \\"/web\\" is already in use` 오류로 실패하고 종료 코드는 `125` 이다. 기존 것을 지우거나 다른 이름을 써야 한다. `--rm` 을 붙인 컨테이너는 끝나면 자동으로 지워진다", "이름 뒤에 번호가 붙어 새 컨테이너가 만들어진다", "기존 컨테이너가 자동으로 지워지고 새로 만들어진다", "`--rm` 컨테이너는 끝나도 `docker ps -a` 에 남는다"]', 0, '일회용 명령은 `docker run --rm` 으로 실행하면 정리할 것이 남지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 12, 'docker system df', '`docker system df` 는 무엇을 보여 줄까요?', 'df 는 디스크 사용량을 뜻해요.', NULL, NULL, '[]', 'choice', '["실행 중인 컨테이너의 CPU 사용량만 보여 준다", "도커 데몬의 설정 파일 내용을 보여 준다", "컨테이너 안의 파일 목록을 보여 준다", "`TYPE`, `TOTAL`, `ACTIVE`, `SIZE`, `RECLAIMABLE` 열로 이미지, 컨테이너, 볼륨, 빌드 캐시가 차지하는 공간과 정리하면 되찾을 수 있는 공간을 보여 준다"]', 3, '공간이 부족할 때 무엇이 많이 차지하는지 먼저 확인하는 용도입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 13, 'docker container prune', '`docker container prune` 을 실행하면 어떤 확인이 나오고, `n` 을 입력하면 어떻게 될까요? `-f` 를 붙이면요?', '정지한 컨테이너를 지우는 명령이에요.', NULL, NULL, '[]', 'choice', '["확인 없이 실행 중인 컨테이너까지 모두 지운다", "`n` 을 입력해도 정지한 컨테이너는 지워진다", "`WARNING! This will remove all stopped containers.` 와 `[y/N]` 확인이 나오고 `n` 이면 아무것도 지우지 않는다. `-f` 를 붙이면 묻지 않고 정지한 컨테이너를 지우며 `Deleted Containers:` 목록을 보여 준다. 실행 중인 컨테이너는 지우지 않는다", "`-f` 를 붙이면 이미지까지 함께 지운다"]', 2, '`--filter label=키` 로 범위를 좁힐 수 있어서 다른 컨테이너를 지우는 실수를 줄입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 14, '-i 와 파이프 입력', '`echo hi | docker run --rm -i alpine cat` 은 무엇을 출력할까요? `-i` 를 빼면요?', '-i 는 표준 입력을 열어 둬요.', NULL, NULL, '[]', 'choice', '["`-i` 가 없어도 `hi` 가 출력된다", "`hi` 가 출력된다. `-i` 로 표준 입력이 연결되어 `cat` 이 파이프 입력을 읽는다. `-i` 를 빼면 입력이 연결되지 않아 아무것도 출력되지 않는다", "`-i` 를 쓰면 `cat` 이 파일 `hi` 를 찾다가 오류가 난다", "`-i` 는 이미지를 대화형으로 만든다"]', 1, '`-t` 는 터미널이 있을 때 쓰는 옵션이라 파이프 입력에는 `-i` 만 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 15, 'ID 만 보기', '`docker ps` 에서 **컨테이너 ID 만 출력하는** 옵션을 채우세요.', '"quiet"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-q", "--ids", "--id-only", "--short"]', NULL, '`-a` 와 함께 `-aq` 로 정지한 것까지 봅니다.', '[0]', 'docker ps {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 16, '조건으로 거르기', '`docker ps` 에서 **조건에 맞는 컨테이너만 보는** 옵션을 채우세요.', '"거르다"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["filter", "where", "match", "select"]', NULL, '조건을 여러 번 쓰면 모두 만족하는 것만 나옵니다.', '[0]', 'docker ps -a --{0} status=exited', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 17, '끝날 때까지 기다리기', '컨테이너가 **끝날 때까지 기다린 뒤 종료 코드를 출력하는** 하위 명령을 채우세요.', '"기다리다"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["wait", "block", "join", "hold"]', NULL, '이미 끝난 컨테이너에는 바로 종료 코드를 출력합니다.', '[0]', 'docker {0} c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 18, '이름 바꾸기', '컨테이너의 **이름을 바꾸는** 하위 명령을 채우세요.', '"이름을 다시"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["rename", "mv", "move", "retag"]', NULL, '이미 쓰는 이름이면 Conflict 오류가 납니다.', '[0]', 'docker {0} old new', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 19, '잠시 멈추기', '컨테이너 안의 프로세스를 **잠시 멈추는** 하위 명령을 채우세요.', '"일시 정지"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["pause", "freeze", "suspend", "sleep"]', NULL, 'STATUS 에 `(Paused)` 가 보입니다.', '[0]', 'docker {0} c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 20, '다시 이어서 실행', '`pause` 한 컨테이너를 **다시 실행하는** 하위 명령을 채우세요.', '"일시 정지를 풀다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["unpause", "resume", "continue", "thaw"]', NULL, '풀기 전에는 `exec` 가 오류가 납니다.', '[0]', 'docker {0} c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 21, '마지막 몇 줄만', '로그의 **마지막 몇 줄만** 보여 주는 옵션을 채우세요.', '"꼬리"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["tail", "last", "lines", "count"]', NULL, '`--tail 0` 이면 아무것도 보이지 않습니다.', '[0]', 'docker logs --{0}=3 c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 22, '타임스탬프 붙이기', '로그의 각 줄 앞에 **날짜와 시간을 붙이는** 옵션을 채우세요.', '"time"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "--date", "--clock", "--stamp"]', NULL, '긴 이름은 `--timestamps` 입니다.', '[0]', 'docker logs {0} c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 23, '작업 폴더 정하기', '`docker exec` 에서 **명령을 실행할 작업 폴더를 정하는** 옵션을 채우세요.', '"work"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-w", "--dir", "--cwd", "--path"]', NULL, '긴 이름은 `--workdir` 입니다.', '[0]', 'docker exec {0} /tmp c1 pwd', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 24, '디스크 사용량', '도커가 **디스크를 얼마나 쓰는지 보여 주는** `docker system` 하위 명령을 채우세요.', '리눅스의 디스크 사용량 명령과 같은 두 글자예요.', NULL, NULL, '[]', 'fill', '["df", "du", "usage", "size"]', NULL, '`RECLAIMABLE` 열이 정리하면 되찾을 공간입니다.', '[0]', 'docker system {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 25, '끝나면 자동 삭제', '컨테이너가 **끝나면 자동으로 지우는** `docker run` 옵션을 채우세요.', '"remove"를 두 글자로 줄여요.', NULL, NULL, '[]', 'fill', '["rm", "delete", "clean", "remove"]', NULL, '일회용 명령에 씁니다.', '[0]', 'docker run --{0} alpine echo hi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 26, '종료 코드 확인하기', '컨테이너의 종료 코드를 여러 방법으로 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 상태 보기 → wait → 삭제 순서예요.', NULL, NULL, '[]', 'order', '["`docker run --name c1 alpine sh -c ''exit 3''` 으로 실행하고 `echo $?` 로 `3` 이 나오는지 본다", "`docker ps -a --filter name=c1` 로 STATUS 가 `Exited (3)` 인지 확인한다", "`docker wait c1` 로 이미 끝난 컨테이너의 종료 코드 `3` 이 바로 출력되는지 본다", "`docker rm c1` 로 컨테이너를 지운다"]', NULL, '`--rm` 을 붙였다면 마지막 삭제는 필요 없습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 27, '멈추고 다시 이어서 실행', '컨테이너를 잠시 멈췄다가 다시 쓰는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → pause → 확인 → unpause 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name c1 alpine sleep 300` 으로 컨테이너를 실행한다", "`docker pause c1` 로 멈추고 `docker ps` 의 STATUS 에 `(Paused)` 가 보이는지 확인한다", "`docker exec c1 echo hi` 가 `is paused` 오류로 실패하는지 확인한다", "`docker unpause c1` 로 풀고 `docker exec c1 echo hi` 가 `hi` 를 출력하는지 확인한다"]', NULL, '끝나면 `docker rm -f c1` 로 지웁니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 28, '로그 줄여 보기', '컨테이너 로그를 여러 방식으로 보는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 전부 → 끝 두 줄 → 시간 붙이기 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name c1 alpine sh -c ''for i in 1 2 3 4 5; do echo line$i; done; sleep 300''` 으로 다섯 줄을 출력하는 컨테이너를 실행한다", "`docker logs c1` 로 `line1` 부터 `line5` 까지 모두 보이는지 확인한다", "`docker logs --tail=2 c1` 로 `line4`, `line5` 두 줄만 보이는지 확인한다", "`docker logs -t c1` 로 각 줄 앞에 날짜와 시간이 붙는지 확인한다"]', NULL, '끝나면 `docker rm -f c1` 로 지웁니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 29, '정지한 컨테이너 정리', '정지한 컨테이너를 확인하고 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '정지 → 확인 → 취소해 보기 → 지우기 순서예요.', NULL, NULL, '[]', 'order', '["컨테이너 두 개를 실행하고 하나를 `docker stop -t 1 c1` 로 정지한다", "`docker ps -a --filter status=exited` 로 정지한 컨테이너만 확인한다", "`docker container prune` 의 `[y/N]` 확인에 `n` 을 입력하면 아무것도 지워지지 않는지 본다", "`docker container prune -f` 로 지우고 `docker ps -a` 에서 정지한 컨테이너가 사라졌는지 확인한다"]', NULL, '실행 중인 컨테이너는 지워지지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 29);
