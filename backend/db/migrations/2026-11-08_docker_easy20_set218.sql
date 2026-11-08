-- 도커 세트 218. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set218.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 218, '이미지 목록과 빌드: images -q·--format·--filter, tag·rmi, build -q·-f·--build-arg·--target, image inspect', '이미지를 찾고 만들고 정리하는 기본 동작을 한 개념씩 반복합니다. docker images 의 -q 와 --no-trunc, --format 템플릿, 저장소 이름과 reference 필터, docker tag 가 이름만 더 붙이는 동작, 별칭을 rmi 로 지울 때의 Untagged 와 컨테이너가 쓰는 이미지의 conflict, docker image rm 이 rmi 와 같다는 점, build -q 의 출력, --build-arg 와 ARG 기본값, -f 와 빌드 컨텍스트, 멀티 스테이지의 --target, image inspect 의 --format 을 짧은 객관식·빈칸·순서 문제로 익히고, 빌드하고 실행하기, 별칭 이름 달고 떼기, 빌드 인자 바꿔 보기, 단계별로 끊어 빌드의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 218);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🪆' WHERE id = 218;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 1, 'images -q', '`docker images -q` 는 무엇을 출력할까요?', 'q 는 quiet 이에요.', NULL, NULL, '[]', 'choice', '["이미지 이름과 태그를 `이름:태그` 모양으로 한 줄에 하나씩 출력한다", "이미지의 전체 크기를 숫자만 한 줄에 하나씩 출력한다", "이미지 ID 를 앞 12자리만 한 줄에 하나씩 출력한다", "이미지 ID 와 이름을 표로 묶어 머리글과 함께 출력한다"]', 2, '`--no-trunc` 를 함께 쓰면 `sha256:` 로 시작하는 전체 ID 가 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 2, 'images --no-trunc', '`docker images -q --no-trunc` 로 출력한 ID 는 어떤 모양일까요?', '잘리지 않은 전체 ID 예요.', NULL, NULL, '[]', 'choice', '["`latest` 처럼 태그 이름이 ID 대신 출력된다", "`sha256:` 로 시작하는 전체 ID 가 출력된다", "12자리 ID 가 그대로 두 번씩 반복되어 출력된다", "ID 가 `0x` 로 시작하는 16진수 주소로 출력된다"]', 1, '앞 12자리는 `sha256:` 뒤의 처음 12자리와 같습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 3, 'images --format', '`docker images --format ''{{.Repository}}:{{.Tag}}''` 는 무엇을 출력할까요?', '템플릿에 적은 열만 나와요.', NULL, NULL, '[]', 'choice', '["머리글 없이 `이름:태그` 모양을 한 줄에 하나씩 출력한다", "이름과 태그를 표로 묶어 머리글과 함께 한 줄씩 출력한다", "이미지 ID 와 만든 시각을 `이름:태그` 옆에 함께 출력한다", "이름이 같은 이미지를 하나로 합쳐서 한 줄만 출력한다"]', 0, '`table ` 을 앞에 붙이면 머리글이 함께 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 4, '저장소 이름으로 거르기', '`docker images alpine` 은 무엇을 보여 줄까요?', '이미지 이름을 인자로 줬어요.', NULL, NULL, '[]', 'choice', '["이름에 `alpine` 이 들어간 컨테이너만 모아서 보여 준다", "`alpine` 이미지를 내려받은 뒤 그 목록을 보여 준다", "`alpine` 이 없으면 로컬의 모든 이미지를 대신 보여 준다", "저장소 이름이 `alpine` 인 이미지의 태그들만 보여 준다"]', 3, '태그까지 쓰면 `docker images alpine:3.20` 처럼 더 좁힐 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 5, 'reference 필터', '`docker images --filter reference=''app*''` 은 무엇을 보여 줄까요?', '와일드카드를 쓸 수 있어요.', NULL, NULL, '[]', 'choice', '["이름에 `app` 이 정확히 한 번만 든 이미지를 보여 준다", "레이블이 `app` 으로 시작하는 이미지를 보여 준다", "이름이 `app` 으로 시작하는 이미지를 보여 준다", "`app` 이미지를 참조하는 컨테이너만 보여 준다"]', 2, '`*` 는 어떤 글자든 여러 개와 일치하는 와일드카드입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 6, 'docker tag', '`docker tag app:1 alias:x` 를 하면 이미지는 어떻게 될까요?', '복사인지 이름 추가인지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["이미지가 통째로 복사되어 새 ID 를 가진 이미지가 하나 더 생긴다", "이미지는 복사되지 않고 같은 ID 에 이름이 하나 더 생긴다", "`app:1` 의 이름이 `alias:x` 로 바뀌고 옛 이름은 사라진다", "`alias:x` 라는 이름의 빈 이미지가 새로 만들어진다"]', 1, '`docker images` 에서 두 이름의 IMAGE ID 가 같게 보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 7, '별칭 이름만 지우면', '`docker tag` 로 만든 별칭 `alias:x` 를 `docker rmi alias:x` 로 지우면 어떻게 될까요?', '이름을 떼는 것과 이미지를 지우는 것은 달라요.', NULL, NULL, '[]', 'choice', '["`Untagged` 로 이름만 떼고 원래 이름의 이미지는 남는다", "이미지가 통째로 지워져서 원래 이름도 함께 사라진다", "별칭과 같은 ID 의 이미지가 모두 지워질 때까지 거부된다", "별칭만 지워지고 `docker images` 에서는 계속 보인다"]', 0, '마지막 이름까지 떼면 이미지 자체가 지워집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 8, '컨테이너가 쓰는 이미지', '컨테이너가 하나 남아 있는 이미지를 `docker rmi app:1` 로 지우면 어떻게 될까요?', '컨테이너가 이미지를 쓰고 있어요.', NULL, NULL, '[]', 'choice', '["경고만 나오고 이미지가 곧바로 지워지며 컨테이너는 이미지 없이 남는다", "컨테이너가 자동으로 먼저 지워진 뒤에 이미지가 지워진다", "오류 없이 이름만 떼어지고 이미지와 컨테이너는 그대로 남는다", "`conflict` 오류로 거부되고, 컨테이너를 지우거나 `-f` 로 강제해야 한다"]', 3, '먼저 `docker rm` 으로 컨테이너를 지우면 이미지를 지울 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 9, 'docker image rm', '`docker image rm app:1` 은 `docker rmi app:1` 과 어떤 관계일까요?', '같은 일을 하는 다른 이름이에요.', NULL, NULL, '[]', 'choice', '["`docker rm` 과 같아서 컨테이너를 지우는 명령이다", "`docker rmi` 는 이름만 떼고 `docker image rm` 은 항상 이미지를 지운다", "같은 명령이다. 둘 다 이미지의 이름을 떼고 마지막 이름이면 이미지를 지운다", "`docker image rm` 은 이미지의 레이어만 지우고 이름은 남긴다"]', 2, '`docker image ls` 와 `docker images` 도 같은 관계입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 10, 'build -q 의 출력', '`docker build -q -t app:1 .` 는 빌드가 끝나면 무엇을 출력할까요?', 'q 는 quiet 이에요.', NULL, NULL, '[]', 'choice', '["각 단계의 진행 상황을 한 줄로 줄여서 출력한다", "빌드한 이미지의 ID 를 `sha256:` 로 시작하는 한 줄로 출력한다", "`Successfully built` 와 이미지 이름을 두 줄로 출력한다", "아무것도 출력하지 않고 종료 코드로만 결과를 알린다"]', 1, '스크립트에서 `ID=$(docker build -q .)` 처럼 ID 를 변수에 담을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 11, '--build-arg', 'Dockerfile 에 `ARG GREET=hi` 가 있고 `RUN echo "$GREET" > /g.txt` 로 쓰는 이미지를 `--build-arg GREET=hello` 로 빌드해서 실행하면 무엇이 나올까요? 인자 없이 빌드하면요?', 'ARG 의 기본값이 있어요.', NULL, NULL, '[]', 'choice', '["`hello` 가 나오고, 인자 없이 빌드하면 기본값인 `hi` 가 나온다", "`hi` 가 나오고, 인자 없이 빌드하면 오류로 빌드가 중단된다", "`hello` 가 나오고, 인자 없이 빌드하면 빈 줄이 나온다", "항상 `hi` 가 나오고 `--build-arg` 값은 무시된다"]', 0, '인자 값은 빌드할 때 `ARG` 로 선언한 이름에만 전달됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 12, '-f 와 빌드 컨텍스트', '`docker build -f other.Dockerfile -t app:2 .` 에서 `-f` 와 마지막의 `.` 은 각각 무엇일까요?', '파일 이름과 폴더는 달라요.', NULL, NULL, '[]', 'choice', '["`-f` 는 강제로 다시 빌드하는 옵션이고 `.` 은 결과를 저장할 폴더이다", "`-f` 는 이미지 이름이고 `.` 은 쓸 Dockerfile 의 경로이다", "`-f` 는 캐시를 끄는 옵션이고 `.` 은 이미지 태그의 일부이다", "`-f` 는 쓸 Dockerfile 의 이름이고 `.` 은 빌드 컨텍스트 폴더이다"]', 3, '`-f` 를 생략하면 컨텍스트 폴더의 `Dockerfile` 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 13, '--target', '두 단계(`base`, `final`) 로 된 Dockerfile 을 `docker build --target base -t m:base .` 로 빌드하면 무엇이 만들어질까요?', '단계 이름을 지정했어요.', NULL, NULL, '[]', 'choice', '["`final` 단계까지 모두 실행하고 `base` 는 이름만 붙는다", "`base` 단계만 건너뛰고 `final` 만 실행한 이미지가 된다", "`base` 단계까지만 실행한 결과가 이미지 `m:base` 가 된다", "두 단계가 각각 별개의 이미지로 `m:base` 와 `m:final` 이 된다"]', 2, '`--target` 없이 빌드하면 마지막 단계까지 만들어집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 14, 'image inspect', '`docker image inspect --format ''{{.Config.Cmd}}'' app:2` 는 무엇을 출력할까요?', '이미지에 정해 둔 값이에요.', NULL, NULL, '[]', 'choice', '["이미지를 만들 때 쓴 `docker build` 명령이 한 줄로 출력된다", "이미지에 정해 둔 기본 실행 명령이 `[echo from-other]` 처럼 출력된다", "이미지 안에 있는 파일 목록이 `[...]` 안에 출력된다", "이미지를 가장 최근에 실행한 컨테이너의 명령이 출력된다"]', 1, '`{{.Config.Labels}}` 로 이미지에 붙인 레이블도 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 15, 'ID 만 보기', '`docker images` 에서 **이미지 ID 만 출력하는** 옵션을 채우세요.', '"quiet"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-s", "-o", "-q"]', NULL, '`--no-trunc` 를 더하면 전체 ID 가 나옵니다.', '[3]', 'docker images {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 16, '출력 모양 정하기', '`docker images` 에서 **출력 모양을 Go 템플릿으로 정하는** 옵션을 채우세요.', '"모양, 형식"을 영어로 써요.', NULL, NULL, '[]', 'fill', '["format", "style", "layout", "template"]', NULL, '짧은 이름은 없습니다.', '[0]', 'docker images --{0} ''{{.Repository}}:{{.Tag}}''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 17, '조건으로 거르기', '`docker images` 에서 **조건에 맞는 이미지만 고르는** 옵션을 채우세요.', '"거르다"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["grep", "filter", "match", "where"]', NULL, '`reference`, `label`, `dangling` 같은 조건이 있습니다.', '[1]', 'docker images --{0} reference=''app*''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 18, '이름 하나 더 붙이기', '이미지에 **이름을 하나 더 붙이는** 하위 명령을 채우세요.', '"꼬리표"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["alias", "name", "tag", "link"]', NULL, '새 이미지가 복사되지 않고 같은 ID 에 이름만 늘어납니다.', '[2]', 'docker {0} app:1 alias:x', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 19, '이미지 지우기', '**이미지를 지우는** 하위 명령을 채우세요.', '"remove image"의 줄임이에요.', NULL, NULL, '[]', 'fill', '["rmim", "imgrm", "delete", "rmi"]', NULL, '컨테이너를 지우는 `docker rm` 과 다릅니다.', '[3]', 'docker {0} alias:x', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 20, 'image 아래의 삭제', '`docker image` 아래에서 **이미지를 지우는** 하위 명령을 채우세요.', '"remove"의 두 글자 줄임이에요.', NULL, NULL, '[]', 'fill', '["rm", "del", "drop", "kill"]', NULL, '`docker rmi` 와 같은 명령입니다.', '[0]', 'docker image {0} alias:x', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 21, '이름과 태그 붙여 빌드', '`docker build` 에서 **만들 이미지의 이름과 태그를 정하는** 옵션을 채우세요.', '"tag"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-t", "-f", "-o"]', NULL, '긴 이름은 `--tag` 입니다.', '[1]', 'docker build {0} app:1 .', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 22, 'Dockerfile 이름 정하기', '`docker build` 에서 **쓸 Dockerfile 의 이름을 정하는** 옵션을 채우세요.', '"file"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-n", "-f", "-d"]', NULL, '긴 이름은 `--file` 입니다.', '[2]', 'docker build {0} other.Dockerfile .', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 23, '빌드 인자 넘기기', '`docker build` 에서 **`ARG` 로 선언한 값을 넘기는** 옵션을 채우세요.', '"빌드의 인자"를 이어 써요.', NULL, NULL, '[]', 'fill', '["arg", "env", "set", "build-arg"]', NULL, 'Dockerfile 에 `ARG GREET` 이 선언되어 있어야 쓰입니다.', '[3]', 'docker build --{0} GREET=hello .', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 24, '단계까지만 빌드', '멀티 스테이지 빌드에서 **지정한 단계까지만 빌드하는** 옵션을 채우세요.', '"목표"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["target", "stage", "until", "to"]', NULL, '`--target` 없이 빌드하면 마지막 단계까지 만듭니다.', '[0]', 'docker build --{0} base .', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 25, '이미지 자세히 보기', '이미지의 **설정을 JSON 으로 보여 주는** `docker image` 하위 명령을 채우세요.', '"검사하다"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["info", "inspect", "show", "detail"]', NULL, '`--format` 으로 한 값만 뽑을 수 있습니다.', '[1]', 'docker image {0} app:2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 26, '빌드하고 실행하기', '이미지를 빌드해서 실행해 보는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → 빌드 → 확인 → 실행 순서예요.', NULL, NULL, '[]', 'order', '["`docker run --rm app:1` 이 `one` 을 출력하는지 확인한다", "`docker images app` 에서 `app` 의 태그 `1` 이 보이는지 확인한다", "`FROM alpine`, `RUN echo one > /one.txt`, `CMD [\\"cat\\", \\"/one.txt\\"]` 로 Dockerfile 을 쓴다", "`docker build -t app:1 .` 로 이미지를 빌드한다"]', NULL, '`--rm` 을 붙였으니 컨테이너는 남지 않습니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 27, '별칭 이름 달고 떼기', '이미지에 이름을 하나 더 붙였다가 떼는 순서입니다. 순서에 맞게 놓아 보세요.', '붙이기 → ID 비교 → 떼기 → 남았는지 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker rmi alias:x` 로 별칭을 지워 `Untagged` 가 나오는지 본다", "`docker images app` 에서 원래 이름 `app:1` 이 그대로 남아 있는지 확인한다", "`docker images` 에서 두 이름의 IMAGE ID 가 같은지 확인한다", "`docker tag app:1 alias:x` 로 같은 이미지에 이름을 하나 더 붙인다"]', NULL, '마지막 이름까지 떼면 이미지도 지워집니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 28, '빌드 인자 바꿔 보기', '`ARG` 값을 바꿔 가며 빌드하는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → 인자 주고 → 인자 없이 → 마지막 빌드 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker build -t arg:1 .` 로 인자 없이 다시 빌드해 실행하면 `hi` 가 나온다", "`ARG GREET=hi` 와 `RUN echo \\"$GREET\\" > /g.txt`, `CMD [\\"cat\\", \\"/g.txt\\"]` 로 Dockerfile 을 쓴다", "같은 태그 `arg:1` 은 마지막으로 빌드한 이미지를 가리키므로 `docker run --rm arg:1` 이 `hi` 를 출력하는지 확인한다", "`docker build -t arg:1 --build-arg GREET=hello .` 로 빌드해 실행하면 `hello` 가 나온다"]', NULL, '`ARG` 의 기본값은 인자가 없을 때만 쓰입니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 29, '단계별로 끊어 빌드', '멀티 스테이지 Dockerfile 을 단계별로 빌드하는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → target → 전체 → 비교 순서예요.', NULL, NULL, '[]', 'order', '["`docker build --target base -t m:base .` 로 `base` 단계까지만 빌드한다", "두 이미지를 실행해 `/stage.txt` 가 `base` 와 `final` 로 서로 다른지 확인한다", "`FROM alpine AS base` 와 `FROM base AS final` 두 단계로 Dockerfile 을 쓴다", "`docker build -t m:final .` 로 마지막 단계까지 빌드한다"]', NULL, '끝나면 `docker rmi m:base m:final` 로 지웁니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 29);
