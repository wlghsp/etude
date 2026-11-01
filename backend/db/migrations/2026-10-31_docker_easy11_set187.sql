-- 도커 세트 187. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set187.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 187, 'Dockerfile 지시어와 헬스체크·정지: HEALTHCHECK, STOPSIGNAL, ONBUILD, SHELL, VOLUME, ARG, WORKDIR', 'Dockerfile 지시어와 실행 옵션의 동작을 한 개념씩 반복합니다. HEALTHCHECK 의 starting·healthy·unhealthy 변화와 inspect 에 저장되는 모양, unhealthy 여도 컨테이너가 계속 실행되는 것, FailingStreak 과 Log, --start-period, --no-healthcheck 와 HEALTHCHECK NONE, docker run 의 --health-* 와 상태 필터, STOPSIGNAL 과 --stop-signal, --stop-timeout 과 종료 코드 137, ONBUILD 가 자식 빌드에서만 실행되는 것, SHELL 로 RUN 의 쉘을 바꾸고 -e 로 중간 실패를 잡는 것, VOLUME 지시어와 익명 볼륨, FROM 앞의 ARG 의 범위, WORKDIR 의 상대 경로와 -w, COPY 의 --chown·--chmod 를 짧은 객관식·빈칸·순서 문제로 익히고, 헬스체크 상태 변화 확인하기, 정상 종료 신호 맞추기, ONBUILD 베이스 이미지 만들고 쓰기, 빌드 중 실패를 놓치지 않게 하기의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 187);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🩺' WHERE id = 187;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 1, 'HEALTHCHECK 지시어', 'Dockerfile 에 `HEALTHCHECK --interval=1s --timeout=1s --retries=2 CMD test -f /tmp/ok` 를 쓰고 컨테이너를 실행하면 상태는 어떻게 바뀔까요? 이미지 설정에는 어떻게 저장될까요?', '처음에는 아직 판단 전이에요.', NULL, NULL, '[]', 'choice', '["시작 직후부터 항상 `healthy` 이다", "실패하면 컨테이너가 즉시 종료된다", "시작 직후에는 `starting`(`docker ps` 에 `(health: starting)`)이고, 검사가 연속으로 실패해 재시도 횟수를 넘으면 `unhealthy`, 성공하면 `healthy` 가 된다. 이미지 설정의 `Config.Healthcheck.Test` 에는 `[\\"CMD-SHELL\\",\\"test -f /tmp/ok\\"]` 로 저장된다", "`CMD` 뒤의 명령은 이미지 설정에 저장되지 않는다"]', 2, '검사 명령의 종료 코드가 0 이면 성공, 1 이면 실패로 취급합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 2, 'unhealthy 여도 계속 실행된다', '헬스체크가 계속 실패해 `unhealthy` 가 된 컨테이너를 Docker 는 어떻게 할까요? 파일을 만들어 검사를 통과시키면요?', '상태만 표시하고 직접 조치하지는 않아요.', NULL, NULL, '[]', 'choice', '["`unhealthy` 가 되면 Docker 가 컨테이너를 자동으로 재시작한다", "컨테이너는 계속 실행되고(`Running` true, 재시작 횟수 0) Docker 가 스스로 재시작하거나 삭제하지 않는다. 검사가 다시 성공하면 `healthy` 로 돌아오고 `FailingStreak` 은 0 이 된다", "한 번 `unhealthy` 가 되면 `healthy` 로 돌아올 수 없다", "`unhealthy` 가 되면 컨테이너가 삭제된다"]', 1, '`docker inspect` 의 `RestartCount` 가 0 이어서 재시작되지 않았음을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 3, '헬스체크 기록 읽기', '`docker inspect` 의 `State.Health` 에서 `FailingStreak` 과 `Log` 는 무엇을 보여 줄까요? 최근 검사 결과가 실패, 실패, 성공, 성공, 성공 순서였다면 종료 코드는 어떻게 나올까요?', '연속 실패 횟수와 최근 결과예요.', NULL, NULL, '[]', 'choice', '["`FailingStreak` 은 지금까지 연속으로 실패한 횟수(성공하면 0), `Log` 는 최근 검사 결과를 최대 5개까지 보여 준다. 실패 둘 뒤 성공 셋이면 종료 코드는 `1 1 0 0 0` 으로 나온다", "`Log` 는 모든 검사 기록을 무제한 보관한다", "`FailingStreak` 은 전체 실패 횟수이다", "성공의 종료 코드는 1 이다"]', 0, '문제가 생겼을 때 `Log` 의 출력 메시지로 어느 검사가 실패했는지 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 4, '--start-period', '`HEALTHCHECK --interval=1s --start-period=4s --retries=1 CMD false` 인 컨테이너는 2초 뒤와 9초 뒤에 상태가 어떨까요?', '시작 유예 동안은 실패를 세지 않아요.', NULL, NULL, '[]', 'choice', '["2초 뒤에 이미 `unhealthy` 이다", "9초 뒤에도 `starting` 이다", "`--start-period` 는 검사 간격을 늘린다", "시작 유예 시간(4초) 안에는 검사가 실패해도 `starting` 으로 남고, 그 시간이 지난 뒤 실패가 반영되어 `unhealthy` 가 된다 (2초 뒤 `starting`, 9초 뒤 `unhealthy`)"]', 3, '시작 후 2초와 9초에 `State.Health.Status` 를 읽어 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 5, '헬스체크 끄기', '이미지에 헬스체크가 있을 때 `docker run --no-healthcheck` 와 Dockerfile 의 `HEALTHCHECK NONE` 은 각각 어떤 효과가 있을까요?', '하나는 실행할 때, 하나는 이미지에서 꺼요.', NULL, NULL, '[]', 'choice', '["`HEALTHCHECK NONE` 은 모든 검사를 `healthy` 로 만든다", "`--no-healthcheck` 는 이미지의 설정을 영구히 지운다", "`--no-healthcheck` 로 실행하면 그 컨테이너에는 `State.Health` 가 없고, `HEALTHCHECK NONE` 은 부모 이미지에서 이어받은 헬스체크를 이미지 설정(`Test: [\\"NONE\\"]`)에서 해제해 컨테이너에도 헬스체크가 없다", "두 방법 모두 컨테이너를 정지시킨다"]', 2, '`docker image inspect` 의 `Config.Healthcheck` 로 이미지 설정을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 6, 'docker run 의 --health-*', '`docker run --health-cmd ''test -f /tmp/ok'' --health-interval 1s --health-retries 1 --health-timeout 1s` 로 실행하면 어떻게 될까요? 이미지에 이미 헬스체크가 있으면요? `docker ps` 에서 걸러 보려면?', '실행할 때도 정할 수 있어요.', NULL, NULL, '[]', 'choice', '["실행할 때는 헬스체크를 정할 수 없다", "이미지에 헬스체크가 없어도 실행할 때 정할 수 있고(`Test` 가 `[\\"CMD-SHELL\\",\\"test -f /tmp/ok\\"]` 로 저장됨), 이미지에 이미 있으면 실행할 때 준 값이 덮어쓴다. `--health-start-period` 도 쓸 수 있고, `docker ps -f health=healthy` 로 상태별 필터를 걸 수 있으며 STATUS 열에 `(healthy)` 가 보인다", "이미지의 헬스체크가 항상 우선한다", "`docker ps` 에는 헬스체크 상태가 나오지 않는다"]', 1, '`--health-cmd` 는 쉘 형식(`CMD-SHELL`)으로 저장됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 7, 'STOPSIGNAL', '`STOPSIGNAL SIGINT` 가 있는 이미지의 컨테이너(SIGINT 와 SIGTERM 을 각각 처리하는 스크립트)에 `docker stop` 을 하면 어떻게 될까요? 지시어가 없을 때는요? `docker run --stop-signal SIGINT` 는요?', 'stop 이 보내는 신호를 정해요.', NULL, NULL, '[]', 'choice', '["`STOPSIGNAL SIGINT` 면 `docker stop` 이 SIGINT 를 보내 `got-INT` 가 로그에 남고 기다리지 않고 종료 코드 0 으로 끝난다. 지시어가 없으면 기본 SIGTERM 이라 `got-TERM` 이 남는다. `docker run --stop-signal SIGINT` 도 같은 효과를 내며 `docker inspect` 의 `Config.StopSignal` 에 `SIGINT` 로 보인다", "`STOPSIGNAL` 이 있어도 항상 SIGTERM 을 보낸다", "`docker run --stop-signal` 은 이미지에서만 쓸 수 있다", "`STOPSIGNAL` 은 `docker kill` 에만 적용된다"]', 0, '`docker image inspect` 의 `Config.StopSignal` 로 이미지에 정해진 신호를 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 8, '--stop-timeout', '`docker run --stop-timeout 2 ... sleep 600` 으로 실행한 컨테이너에 `docker stop` 을 하면 얼마나 걸리고 종료 코드는 얼마일까요?', '신호를 무시하면 강제 종료돼요.', NULL, NULL, '[]', 'choice', '["기본 10초를 기다린 뒤 종료된다", "즉시 종료 코드 0 으로 끝난다", "`--stop-timeout` 은 `docker run` 에서 쓸 수 없다", "`sleep` 이 SIGTERM 을 처리하지 않아 약 2초 기다린 뒤 SIGKILL 로 종료되어 종료 코드가 137 이다. 이 값은 `docker inspect` 의 `Config.StopTimeout`(2)에 보인다"]', 3, '`--stop-timeout` 을 주지 않은 컨테이너의 `Config.StopTimeout` 은 `null`(설정 없음)이고 기본 대기 시간은 10초입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 9, 'ONBUILD', '부모 Dockerfile 에 `ONBUILD RUN echo triggered > /t.txt` 와 `ONBUILD COPY f.txt /f.txt` 가 있습니다. 부모 이미지와 `FROM 부모` 로 만든 자식 이미지에서는 각각 어떻게 될까요?', '나중에 이 이미지를 쓰는 빌드를 위한 예약이에요.', NULL, NULL, '[]', 'choice', '["부모를 빌드할 때 바로 실행된다", "자식 이미지에도 `OnBuild` 가 그대로 이어진다", "부모 이미지를 빌드할 때는 실행되지 않아 부모에는 `/t.txt` 가 없고, 설정의 `OnBuild` 에 두 명령이 저장된다. 자식을 빌드할 때 그 명령들이 실행되어 `/t.txt`(`triggered`)와, 자식 빌드 컨텍스트의 `f.txt` 를 복사한 `/f.txt` 가 생기며 자식 이미지의 `OnBuild` 는 비어 있다(상속되지 않는다)", "`ONBUILD COPY` 는 부모의 컨텍스트에서 파일을 가져온다"]', 2, '`docker image inspect` 의 `Config.OnBuild` 에서 예약된 명령 목록을 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 10, 'SHELL 지시어', '`RUN false; echo reached > /a.txt` 는 기본 쉘에서 빌드가 성공할까요? `SHELL ["/bin/sh","-ec"]` 를 먼저 쓰면요? `$0` 은 `SHELL ["/bin/ash","-c"]` 전후에 어떻게 달라질까요?', '기본은 sh -c 라서 마지막 명령의 결과만 봐요.', NULL, NULL, '[]', 'choice', '["기본 쉘에서도 `false` 에서 빌드가 멈춘다", "기본 쉘(`/bin/sh -c`)에서는 마지막 명령(`echo`)이 성공해 빌드가 성공하고 `/a.txt` 가 만들어진다. `SHELL [\\"/bin/sh\\",\\"-ec\\"]` 를 쓰면 `false` 에서 멈춰 `did not complete successfully: exit code: 1` 로 빌드가 실패한다. `$0` 은 `SHELL` 앞의 `RUN` 에서는 `/bin/sh`, 뒤의 `RUN` 에서는 `/bin/ash` 이다", "`SHELL` 은 앞에 있는 `RUN` 에도 적용된다", "`SHELL` 은 `FROM` 앞에만 쓸 수 있다"]', 1, '`RUN echo $0` 으로 그 단계에서 쓰는 쉘 이름을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 11, 'VOLUME 지시어', '`VOLUME /data` 가 있는 이미지로 컨테이너를 실행하면 무슨 일이 생길까요? 이미지의 `Config.Volumes` 는요? `docker rm` 만 하면 볼륨은요? 이 환경(BuildKit)에서 `VOLUME` 뒤의 `RUN echo after > /data/after.txt` 는 어떻게 되었을까요?', '실행할 때 익명 볼륨이 붙어요.', NULL, NULL, '[]', 'choice', '["이미지 설정의 `Config.Volumes` 에 `/data` 가 저장되고, 실행하면 64자 이름의 익명 볼륨이 `/data` 에 자동으로 붙으며 이미지의 `/data` 내용이 복사된다. `docker rm` 만 하면 볼륨은 남는다(`-v` 로 함께 삭제). `-v 이름:/data` 로 이름 있는 볼륨으로 바꿀 수 있고, 이 환경에서는 `VOLUME` 뒤에 `RUN` 으로 쓴 `after.txt` 도 이미지에 남아 `before.txt` 와 함께 보였다", "`VOLUME` 은 호스트 폴더를 자동으로 연결한다", "`docker rm` 만으로 익명 볼륨도 항상 삭제된다", "`VOLUME` 지시어는 실행할 때 아무 일도 하지 않는다"]', 0, '이 환경의 관찰 결과이므로 `VOLUME` 뒤의 변경 처리는 빌더에 따라 다를 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 12, 'FROM 앞의 ARG', '`ARG BASE=alpine:latest` 를 `FROM` 앞에 쓰고 `FROM ${BASE}` 로 베이스를 정했습니다. 스테이지 안의 `RUN echo "[$BASE]"` 는 무엇을 출력할까요? 다시 `ARG BASE` 를 쓰면요? `--build-arg` 와 없는 태그는요?', 'FROM 앞의 ARG 는 FROM 줄에서만 보여요.', NULL, NULL, '[]', 'choice', '["스테이지 안에서도 `FROM` 앞의 값이 자동으로 보인다", "`FROM` 앞의 `ARG` 는 `--build-arg` 로 바꿀 수 없다", "없는 태그도 경고만 나오고 빌드된다", "스테이지 안에서는 값이 비어 `[]` 가 출력된다. `FROM` 뒤에 `ARG BASE` 를 다시 선언하면 `[alpine:latest]` 가 출력된다. `--build-arg BASE=이미지` 로 베이스를 바꿀 수 있고, 없는 태그는 `not found` 로 빌드가 실패한다"]', 3, '베이스 이미지의 버전을 빌드 때 바꾸고 싶을 때 이 방식을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 13, 'WORKDIR', '`WORKDIR /a` 다음에 `WORKDIR b` 를 쓰고 `RUN pwd > /pwd.txt` 와 `COPY f.txt .` 를 하면 현재 위치와 파일은 어디에 생길까요? 없는 폴더는요? `docker run -w` 는요?', '상대 경로는 이전 WORKDIR 에 이어져요.', NULL, NULL, '[]', 'choice', '["`WORKDIR b` 는 루트 아래 `/b` 가 된다", "없는 폴더는 `WORKDIR` 에서 오류가 난다", "상대 경로는 이전 `WORKDIR` 에 이어져 `/a/b` 가 되고, 폴더가 없으면 자동으로 만들어진다. `RUN pwd` 는 `/a/b` 를 기록하고 `COPY f.txt .` 의 `.` 도 `/a/b` 이다. `docker run -w /tmp` 로 실행할 때 덮어쓸 수 있고 없는 경로(`/nonexist/dir`)를 주면 만들어서 쓴다", "`docker run -w` 는 없는 경로를 만들지 못한다"]', 2, '`docker run -w /tmp 이미지 pwd` 는 `/tmp` 를 출력합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 14, 'COPY 의 --chown 과 --chmod', '`COPY f.txt /plain.txt`, `COPY --chown=1234:5678 f.txt /own.txt`, `COPY --chmod=600 f.txt /perm.txt` 로 복사한 파일의 소유자와 권한은 각각 어떻게 될까요?', '기본은 root 소유 644 예요.', NULL, NULL, '[]', 'choice', '["`COPY` 는 항상 현재 사용자의 소유로 만든다", "기본은 소유자 `0:0`(root)에 권한 644 이고, `--chown=1234:5678` 은 소유자를 `1234:5678` 로, `--chmod=600` 은 권한을 600 으로 정한다", "`--chmod` 는 `RUN chmod` 와 달리 쓸 수 없다", "기본 권한은 777 이다"]', 1, '`stat -c ''%u:%g %a'' 파일` 로 소유자와 권한을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 15, '검사 명령 표기', 'Dockerfile 의 `HEALTHCHECK` 에서 **검사할 명령 앞에 붙이는** 키워드를 채우세요.', '"명령"을 뜻하는 `RUN` 과 비슷하지만 다른 단어예요.', NULL, NULL, '[]', 'fill', '["CMD", "RUN", "EXEC", "TEST"]', NULL, '`inspect` 에는 `["CMD-SHELL", ...]` 로 저장됩니다.', '[0]', 'HEALTHCHECK --interval=1s --retries=2 {0} test -f /tmp/ok', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 16, '실행 시 검사 명령', '`docker run` 에서 **헬스체크 명령**을 정하는 옵션 이름을 채우세요.', '"health"와 "cmd"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["health-cmd", "check-cmd", "health-test", "probe"]', NULL, '`--health-interval` 같은 옵션과 함께 씁니다.', '[0]', 'docker run --{0} ''test -f /tmp/ok'' alpine sleep 600', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 17, '헬스체크 끄기', '이미지의 헬스체크를 **실행할 때 끄는** 옵션을 채우세요.', '"no"와 "healthcheck"를 이어요.', NULL, NULL, '[]', 'fill', '["no-healthcheck", "health-off", "skip-health", "no-health"]', NULL, '컨테이너에는 `State.Health` 가 생기지 않습니다.', '[0]', 'docker run --{0} alpine sleep 600', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 18, '헬스체크 해제 지시어', '부모 이미지에서 이어받은 헬스체크를 **해제하는** `HEALTHCHECK` 값을 채우세요.', '"없음"이라는 뜻의 영어 단어(대문자)예요.', NULL, NULL, '[]', 'fill', '["NONE", "OFF", "DISABLE", "SKIP"]', NULL, '이미지 설정에 `Test: ["NONE"]` 로 저장됩니다.', '[0]', 'HEALTHCHECK {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 19, '시작 유예', '시작 직후 일정 시간 동안 **실패를 세지 않게** 하는 `HEALTHCHECK` 옵션을 채우세요.', '"시작"과 "기간"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["start-period", "grace", "warmup", "delay"]', NULL, '유예 시간 안에는 `starting` 으로 남습니다.', '[0]', 'HEALTHCHECK --{0}=5s CMD test -f /tmp/ok', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 20, '인터럽트 신호', 'Ctrl+C 와 같은 **인터럽트 신호**를 정하는 `STOPSIGNAL` 값을 채우세요.', '"SIG"로 시작하고 "INT"로 끝나요.', NULL, NULL, '[]', 'fill', '["SIGINT", "INTERRUPT", "CTRL-C", "BREAK"]', NULL, '기본값은 `SIGTERM` 입니다.', '[0]', 'STOPSIGNAL {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 21, '정지 대기 시간', '`docker stop` 이 **강제 종료 전에 기다리는 시간**을 컨테이너별로 정하는 `run` 옵션을 채우세요.', '"stop"과 "timeout"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["stop-timeout", "kill-after", "grace-period", "wait"]', NULL, '초과하면 SIGKILL 로 종료됩니다.', '[0]', 'docker run --{0} 2 alpine sleep 600', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 22, '실행 시 정지 신호', '`docker stop` 이 보내는 신호를 **실행할 때 정하는** 옵션을 채우세요.', '"stop"과 "signal"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["stop-signal", "kill-signal", "term-signal", "signal"]', NULL, '이미지의 `STOPSIGNAL` 을 덮어씁니다.', '[0]', 'docker run --{0} SIGINT alpine /run.sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 23, '자식 빌드에서 실행', '나중에 이 이미지를 베이스로 쓰는 **자식 빌드 때 실행될 명령**을 예약하는 지시어를 채우세요.', '"빌드 시"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["ONBUILD", "ATBUILD", "DEFER", "LATER"]', NULL, '부모를 빌드할 때는 실행되지 않습니다.', '[0]', '{0} RUN echo hi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 24, 'RUN 의 쉘 바꾸기', '`RUN` 이 쓰는 **기본 쉘을 바꾸는** 지시어를 채우세요.', '"껍데기"라는 뜻의 영어 단어(대문자)예요.', NULL, NULL, '[]', 'fill', '["SHELL", "BASH", "ENTRY", "TERM"]', NULL, '이후의 `RUN` 부터 적용됩니다.', '[0]', '{0} ["/bin/sh","-ec"]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 25, '복사 소유자 지정', '`COPY` 로 복사한 파일의 **소유자와 그룹을 정하는** 옵션을 채우세요.', '"소유자 변경"을 뜻하는 명령 `chown` 과 같은 이름이에요.', NULL, NULL, '[]', 'fill', '["--chown", "--owner", "--user", "--uid"]', NULL, '`--chmod` 로 권한도 정할 수 있습니다.', '[0]', 'COPY {0}=1234:5678 f.txt /own.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 26, '헬스체크 상태 변화 확인하기', '헬스체크가 있는 이미지를 실행해 상태가 바뀌는 과정을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '정의 → 시작 → 실패 → 복구 순서예요.', NULL, NULL, '[]', 'order', '["Dockerfile 에 `HEALTHCHECK --interval=1s --retries=2 CMD test -f /tmp/ok` 를 쓰고 빌드한다", "컨테이너를 실행하고 `docker ps` 에 `(health: starting)` 이 보이는지 확인한다", "파일이 없어 검사가 실패해 `unhealthy` 가 되고 `FailingStreak` 이 늘어나는 것을 `docker inspect` 로 확인한다", "`docker exec` 로 `/tmp/ok` 를 만들어 `healthy` 가 되고 `FailingStreak` 이 0 이 되는 것을 확인한다"]', NULL, '`unhealthy` 인 동안에도 컨테이너는 계속 실행됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 27, '정상 종료 신호 맞추기', '`docker stop` 이 오래 걸리고 137 로 끝나는 컨테이너를 신호에 맞게 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 신호 파악 → 지정 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker stop` 이 기다린 뒤 종료 코드 137 로 끝나는 것을 확인한다", "앱이 처리하는 신호가 SIGTERM 이 아니라 SIGINT 라는 것을 파악한다", "Dockerfile 에 `STOPSIGNAL SIGINT` 를 넣거나 `docker run --stop-signal SIGINT` 로 실행한다", "`docker stop` 이 바로 끝나고 종료 코드가 0 이며 로그에 `got-INT` 가 남는지 확인한다"]', NULL, '기다리는 시간 자체를 줄이려면 `--stop-timeout` 을 쓸 수 있지만 그러면 강제 종료(137)가 됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 28, 'ONBUILD 베이스 이미지 만들고 쓰기', '`ONBUILD` 로 예약한 명령이 자식 빌드에서 실행되는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '부모 작성 → 부모 확인 → 자식 빌드 → 결과 확인 순서예요.', NULL, NULL, '[]', 'order', '["부모 Dockerfile 에 `ONBUILD RUN echo triggered > /t.txt` 를 쓰고 빌드한다", "부모 이미지에는 `/t.txt` 가 없고 `OnBuild` 에 명령이 저장된 것을 확인한다", "`FROM 부모` 로 시작하는 자식 Dockerfile 을 빌드한다", "자식 이미지에서 `/t.txt` 가 만들어졌고 자식의 `OnBuild` 가 비어 있는지 확인한다"]', NULL, '`ONBUILD COPY` 는 자식의 빌드 컨텍스트에서 파일을 가져옵니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 29, '빌드 중 실패를 놓치지 않게 하기', '`RUN` 중간 명령의 실패를 놓치는 문제를 `SHELL` 로 잡는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 확인 → 쉘 지정 → 재빌드 → 실패 확인 순서예요.', NULL, NULL, '[]', 'order', '["`RUN false; echo reached > /a.txt` 가 기본 쉘에서 빌드가 성공하는 것을 확인한다", "Dockerfile 앞쪽에 `SHELL [\\"/bin/sh\\",\\"-ec\\"]` 를 추가한다", "다시 빌드한다", "`did not complete successfully: exit code: 1` 로 `false` 에서 빌드가 멈추는 것을 확인한다"]', NULL, '실패를 확인한 뒤에는 문제의 명령을 고쳐 빌드가 통과하게 합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 29);
