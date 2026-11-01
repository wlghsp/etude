-- 도커 세트 171. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set171.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 171, '컨테이너 상태와 종료 신호: create·pause, stop 의 SIGTERM, PID 1, 포트 공개', '컨테이너가 살고 멈추는 과정을 한 개념씩 반복합니다. create·start·pause·stop 에 따른 Created·Up·Paused·Exited 상태, stop 이 SIGTERM 을 보내고 기본 10초 뒤 SIGKILL 하는 것, PID 1 이 신호를 처리하지 않을 때 10초가 걸리고 137 로 끝나는 것, --init 과 신호를 처리하는 앱, 쉘 형식과 exec 형식 CMD 의 PID 1, kill 과 -s 로 보내는 신호, start 와 run 의 차이, 실행 중인 컨테이너를 rm 할 때의 거부, docker wait, EXPOSE 는 공개가 아니라는 것과 -P·docker port, docker commit 을 짧은 객관식·빈칸·순서 문제로 익히고, 느린 stop 고치기, 상태 따라가기, 포트가 열리지 않을 때 확인, 컨테이너 변경을 이미지로 남기기의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 171);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🚦' WHERE id = 171;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 1, '컨테이너의 상태', '`docker create` 만 하고 `docker start` 는 하지 않은 컨테이너는 `docker ps` 와 `docker ps -a` 에서 어떻게 보일까요?', '만들어졌지만 아직 실행되지 않았어요.', NULL, NULL, '[]', 'choice', '["`docker ps` 에 `Up` 으로 보인다", "만들어지지 않아 어디에도 보이지 않는다", "`docker ps` 에는 보이지 않고 `docker ps -a` 에 `Created` 상태로 보인다. `docker start` 를 하면 `Up` 이 되고, 멈추면 `Exited` 가 된다", "`Exited (0)` 으로 보인다"]', 2, '`docker run` 은 `create` 와 `start` 를 한 번에 하는 명령입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 2, 'pause 와 unpause', '`docker pause 이름` 을 실행하면 컨테이너는 어떻게 될까요?', '종료가 아니라 얼려 두는 거예요.', NULL, NULL, '[]', 'choice', '["컨테이너가 종료되어 `Exited` 가 된다", "컨테이너 안의 프로세스가 멈춘 채로 유지되고(`docker ps` 에 `(Paused)` 로 표시), `docker unpause` 를 하면 이어서 실행된다", "컨테이너가 삭제된다", "이미지가 일시 삭제된다"]', 1, '종료(`stop`)와 달리 메모리 상태가 그대로 남아 있고 같은 프로세스가 이어서 동작합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 3, 'stop 이 하는 일', '`docker stop 이름` 은 컨테이너를 어떻게 멈출까요?', '먼저 정중히 요청하고, 안 되면 강제로 종료해요.', NULL, NULL, '[]', 'choice', '["먼저 `SIGTERM` 으로 종료를 요청하고, 기본 10초 안에 끝나지 않으면 `SIGKILL` 로 강제 종료한다 (`-t` 로 기다리는 시간을 바꿀 수 있다)", "바로 `SIGKILL` 로 강제 종료한다", "컨테이너를 삭제한다", "한 시간 동안 기다린 뒤 종료한다"]', 0, '앱이 `SIGTERM` 을 받고 정리한 뒤 스스로 종료하면 기다리지 않고 바로 끝납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 4, 'stop 이 10초 걸리고 137', '`sleep 600` 을 실행한 컨테이너에 `docker stop` 을 했더니 약 10초 뒤에 `Exited (137)` 로 끝났습니다. 왜일까요?', 'PID 1 프로세스는 신호 처리를 직접 해 줘야 해요.', NULL, NULL, '[]', 'choice', '["`sleep` 이 정상 종료되어 137 이 기록되었다", "도커가 느려서 종료 코드가 잘못 기록되었다", "컨테이너 이미지가 손상되었다", "컨테이너의 PID 1 인 `sleep` 이 `SIGTERM` 을 처리하지 않아 종료되지 않았고, 10초 뒤 `SIGKILL`(128 + 9 = 137)로 강제 종료되었다"]', 3, 'PID 1 은 핸들러가 없는 신호를 무시하는 특별한 프로세스입니다. 그래서 `stop` 이 느려지는 일이 생겨요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 5, '--init', '`docker run --init` 으로 `sleep 600` 을 실행한 뒤 `docker stop` 을 하면 어떻게 될까요?', '작은 init 프로세스가 신호를 대신 전달해 줘요.', NULL, NULL, '[]', 'choice', '["똑같이 10초 뒤 137 로 끝난다", "컨테이너가 시작되지 않는다", "init 프로세스가 PID 1 이 되어 `SIGTERM` 을 앱에 전달하므로 기다리지 않고 바로 종료되고, 종료 코드는 `143`(128 + 15)이다", "`--init` 은 `docker stop` 에 영향을 주지 않는다"]', 2, '신호를 처리하지 않는 앱이나 자식 프로세스를 정리하지 못하는 앱을 실행할 때 `--init` 이 도움이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 6, '신호를 처리하는 앱', '쉘 스크립트가 `trap "echo got-TERM; exit 0" TERM` 으로 신호를 처리하도록 짜여 있습니다. `docker stop` 을 하면 어떻게 될까요?', '앱이 `SIGTERM` 을 직접 받고 스스로 종료해요.', NULL, NULL, '[]', 'choice', '["10초 뒤 137 로 끝난다", "기다리지 않고 바로 종료되고(`got-TERM` 이 로그에 남는다) 스크립트가 `exit 0` 으로 끝났으므로 종료 코드는 0 이다", "`trap` 은 도커에서 동작하지 않는다", "종료 코드가 항상 143 이다"]', 1, '정상 종료를 위해서는 앱이 `SIGTERM` 을 받아 정리하고 끝내도록 만드는 것이 가장 좋습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 7, 'CMD 형식과 PID 1', '`CMD sleep 600 && echo done` (쉘 형식)과 `CMD ["sleep","600"]` (exec 형식)로 실행한 컨테이너에서 PID 1 은 각각 무엇일까요?', '쉘 형식은 쉘을 거쳐 실행해요.', NULL, NULL, '[]', 'choice', '["쉘 형식은 `/bin/sh -c sleep 600 && echo done` 이 PID 1 이고, exec 형식은 `sleep 600` 이 PID 1 이다. 신호를 직접 받아야 하는 앱은 exec 형식이어야 PID 1 이 되어 신호를 직접 받는다", "둘 다 `sleep` 이 PID 1 이다", "둘 다 `/bin/sh` 가 PID 1 이다", "PID 1 은 도커가 만든 프로세스이다"]', 0, '`/proc/1/cmdline` 을 읽으면 PID 1 의 실행 명령을 볼 수 있습니다. 쉘이 PID 1 이면 신호가 앱에 닿지 않을 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 8, 'kill 과 다른 신호', '`docker kill 이름` 과 `docker kill -s HUP 이름` 은 각각 무엇을 할까요?', '기본 신호는 강제 종료예요.', NULL, NULL, '[]', 'choice', '["`kill` 은 컨테이너를 삭제하고 `-s` 는 이름을 바꾼다", "둘 다 항상 컨테이너를 종료시킨다", "`-s HUP` 은 컨테이너를 일시 정지한다", "`docker kill` 은 기본으로 `SIGKILL` 을 보내 강제 종료(종료 코드 137)하고, `-s HUP` 은 `SIGHUP` 을 보낸다. 앱이 그 신호를 처리하면 종료되지 않고 계속 실행된다"]', 3, '설정 다시 읽기처럼 신호로 앱에 일을 시키는 방법입니다. 앱이 어떤 신호를 처리하는지 확인하고 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 9, 'start 와 run 의 차이', '컨테이너 안에 파일을 만든 뒤 `docker stop`, `docker start` 를 하면 파일은 남아 있을까요? 새로 `docker run` 한 컨테이너에는요?', 'start 는 같은 컨테이너를 다시 켜요.', NULL, NULL, '[]', 'choice', '["`start` 후에도 파일이 사라지고 `run` 한 컨테이너에는 남아 있다", "둘 다 파일이 남아 있다", "`docker start` 는 같은 컨테이너를 다시 시작하므로 파일이 남아 있고, `docker run` 은 이미지에서 새 컨테이너를 만들어 그 파일이 없다", "둘 다 파일이 사라진다"]', 2, '컨테이너를 삭제(`rm`)하면 그 안의 변경도 함께 사라집니다. 지워지면 안 되는 데이터는 볼륨에 두세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 10, '실행 중인 컨테이너 rm', '실행 중인 컨테이너에 `docker rm 이름` 을 하면 어떻게 될까요?', '먼저 멈춰야 해요.', NULL, NULL, '[]', 'choice', '["아무 오류 없이 바로 삭제된다", "`container is running: stop the container before removing or force remove` 오류로 거부된다. 먼저 `docker stop` 을 하거나 `docker rm -f` 로 강제로 지운다", "컨테이너가 일시 정지된다", "이미지가 함께 삭제된다"]', 1, '정리할 시간이 필요한 앱에는 `stop` 으로 정상 종료한 뒤 `rm` 하는 것이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 11, 'docker wait', '`docker wait 이름` 은 무엇을 할까요?', '끝날 때까지 기다린 뒤 결과를 알려 줘요.', NULL, NULL, '[]', 'choice', '["컨테이너가 종료될 때까지 기다린 뒤 그 종료 코드를 출력한다 (예: `exit 7` 로 끝나면 `7`)", "컨테이너를 일정 시간 멈춘다", "컨테이너의 로그를 출력한다", "컨테이너를 10초 뒤에 시작한다"]', 0, '스크립트에서 작업 컨테이너의 성공 여부를 판단할 때 유용합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 12, 'EXPOSE 는 공개가 아니다', 'Dockerfile 에 `EXPOSE 8080` 이 있는 이미지를 `-p` 없이 `docker run -d` 로 실행했습니다. `docker port 이름` 과 `docker ps` 의 PORTS 열은 어떻게 보일까요?', 'EXPOSE 는 안내일 뿐이에요.', NULL, NULL, '[]', 'choice', '["`8080` 이 호스트에 자동으로 공개된다", "컨테이너가 시작되지 않는다", "`EXPOSE` 가 있으면 `-p` 는 필요 없다", "`docker port` 는 아무것도 출력하지 않고 `docker ps` 의 PORTS 에는 `8080/tcp` 만 보인다 (호스트로 공개되지 않았다). 공개하려면 `-p` 나 `-P` 를 써야 한다"]', 3, '`docker inspect` 의 `ExposedPorts` 에 기록될 뿐 실제 접속 통로는 `-p` 로 만들어야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 13, '-P 와 docker port', '`EXPOSE 8080` 이 있는 이미지를 `docker run -d -P` 로 실행하면 어떻게 될까요? 결과는 어디서 확인할까요?', '대문자 P 는 알아서 골라 줘요.', NULL, NULL, '[]', 'choice', '["호스트의 8080 에 고정으로 공개한다", "아무것도 공개하지 않는다", "`EXPOSE` 된 포트를 호스트의 임의의 높은 포트(보통 32768 이상)에 공개하고, `docker port 이름` 이나 `docker ps` 의 PORTS 열에서 매핑을 확인한다", "컨테이너의 모든 포트를 막는다"]', 2, '소문자 `-p 18171:8080` 은 호스트 포트를 직접 정하는 방식입니다. 포트가 겹칠 때 `-P` 가 편해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 14, 'docker commit', '컨테이너 안에서 파일을 바꾼 뒤 `docker commit 컨테이너 새이미지` 를 하면 어떻게 될까요?', '컨테이너의 현재 상태를 이미지로 만들어요.', NULL, NULL, '[]', 'choice', '["컨테이너가 삭제된다", "컨테이너의 변경 사항이 포함된 새 이미지가 만들어지고, 그 이미지로 실행하면 바꾼 파일이 들어 있다", "원래 이미지가 덮어써진다", "변경 사항은 버려지고 빈 이미지가 만들어진다"]', 1, '손으로 바꾼 내용이 기록에 남지 않으므로 반복 가능한 방법은 Dockerfile 입니다. 급할 때 상태를 보존하는 용도로 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 15, '만들기만 하기', '컨테이너를 **만들기만 하고 실행하지 않는** 하위 명령을 채우세요.', '"만들다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["create", "make", "new", "init"]', NULL, '이후 `docker start a` 로 실행합니다.', '[0]', 'docker {0} --name a alpine sleep 600', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 16, '일시 정지', '컨테이너의 프로세스를 **얼려 두는** 하위 명령을 채우세요.', '"잠시 멈춤"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["pause", "stop", "hold", "freeze"]', NULL, '`docker ps` 에 `(Paused)` 로 표시됩니다.', '[0]', 'docker {0} a', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 17, '일시 정지 풀기', '일시 정지한 컨테이너를 **이어서 실행**하는 하위 명령을 채우세요.', 'pause 의 반대말이에요.', NULL, NULL, '[]', 'fill', '["unpause", "resume", "continue", "restart"]', NULL, '`restart` 는 컨테이너를 종료했다가 다시 시작합니다.', '[0]', 'docker {0} a', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 18, '기다리는 시간 정하기', '`docker stop` 이 **강제 종료 전에 기다리는 시간**을 3초로 정하는 옵션을 채우세요.', '"timeout"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-w", "-s", "-n"]', NULL, '기본값은 10초입니다.', '[0]', 'docker stop {0} 3 a', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 19, '신호 지정해 보내기', '컨테이너에 `SIGHUP` 신호를 **지정해서** 보내는 `kill` 옵션을 채우세요.', '"signal"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-t", "-n", "-p"]', NULL, '옵션이 없으면 기본으로 `SIGKILL` 을 보냅니다.', '[0]', 'docker kill {0} HUP a', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 20, 'init 프로세스 쓰기', '컨테이너의 PID 1 로 **작은 init 프로세스**를 쓰도록 하는 `run` 옵션을 채우세요.', '"초기화"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--init", "--pid", "--boot", "--tini-off"]', NULL, '신호를 앱에 전달하고 자식 프로세스를 정리해 줍니다.', '[0]', 'docker run -d {0} alpine sleep 600', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 21, '종료 코드 기다리기', '컨테이너가 끝날 때까지 기다린 뒤 **종료 코드를 출력**하는 하위 명령을 채우세요.', '"기다리다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["wait", "sleep", "join", "result"]', NULL, '스크립트에서 성공 여부를 판단할 때 씁니다.', '[0]', 'docker {0} job', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 22, '임의 포트로 공개', '`EXPOSE` 된 포트를 **호스트의 임의 포트**에 공개하는 `run` 옵션을 채우세요.', '대문자 한 글자예요.', NULL, NULL, '[]', 'fill', '["-P", "-p", "-L", "-A"]', NULL, '소문자 `-p` 는 호스트 포트를 직접 정하는 옵션입니다.', '[0]', 'docker run -d {0} myimg', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 23, '포트 매핑 확인', '컨테이너의 **포트 매핑을 보는** 하위 명령을 채우세요.', '"포트"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["port", "ports", "net", "expose"]', NULL, '공개된 포트가 없으면 아무것도 출력하지 않습니다.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 24, '이름 바꾸기', '컨테이너의 **이름을 바꾸는** 하위 명령을 채우세요.', '"이름을 바꾸다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["rename", "mv", "name", "tag"]', NULL, '실행 중에도 바꿀 수 있습니다.', '[0]', 'docker {0} old new', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 25, '로그에 시각 붙이기', '`docker logs` 출력의 **줄마다 시각을 붙이는** 옵션을 채우세요.', '"timestamps"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-f", "-n", "-s"]', NULL, '`-f` 는 로그를 계속 따라가는 옵션입니다.', '[0]', 'docker logs {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 26, 'stop 이 느린 컨테이너 고치기', '`docker stop` 이 10초 걸리고 `Exited (137)` 로 끝날 때 원인을 찾아 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 코드 확인 → 원인 → 고치고 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker stop` 이 기본 10초가 걸리는 것을 확인한다", "`docker ps -a` 의 `Exited (137)` 로 강제 종료(SIGKILL)된 것을 확인한다", "`docker exec` 로 `/proc/1/cmdline` 을 읽어 PID 1 이 신호를 처리하지 않는 프로세스(또는 쉘)임을 파악한다", "`--init` 을 쓰거나 exec 형식 `CMD` 와 신호 처리를 적용한 뒤 `docker stop` 이 바로 끝나는지 확인한다"]', NULL, '종료 코드 137 은 128 + 9 (SIGKILL) 입니다. 정상 종료는 0 이나 143 처럼 신호에 따른 코드가 나와요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 27, '컨테이너 상태 따라가기', '컨테이너를 만들고 실행해 일시 정지하기까지 상태를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 확인 → 실행 → 정지 순서예요.', NULL, NULL, '[]', 'order', '["`docker create --name a alpine sleep 600` 으로 컨테이너를 만든다", "`docker ps -a` 에서 상태가 `Created` 인지 확인한다", "`docker start a` 로 실행해 `docker ps` 에 `Up` 으로 보이는지 확인한다", "`docker pause a` 로 일시 정지하고 `docker ps` 에 `(Paused)` 가 보이는지 확인한다"]', NULL, '`docker unpause a` 로 이어서 실행하고 `docker stop a` 로 멈출 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 28, '포트가 열리지 않을 때 확인', '컨테이너에 접속할 수 없어서 포트 공개 여부를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', 'PORTS 열 → port 명령 → 다시 실행 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker ps` 의 PORTS 열에 `8080/tcp` 만 있고 호스트 포트 매핑이 없는 것을 본다", "`docker port 이름` 이 아무것도 출력하지 않아 공개되지 않았음을 확인한다", "컨테이너를 지우고 `-p 호스트포트:8080` 을 붙여 다시 실행한다", "`docker port 이름` 으로 `8080/tcp` 의 매핑이 생겼는지 확인한다"]', NULL, '`EXPOSE` 만으로는 공개되지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 29, '컨테이너의 변경을 이미지로 남기기', '컨테이너 안에서 바꾼 내용을 이미지로 보존하고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '변경 → commit → 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`docker exec` 로 컨테이너 안에 파일을 만든다", "`docker commit 컨테이너 새이미지` 로 이미지를 만든다", "`docker run --rm 새이미지 cat 파일` 로 파일이 들어 있는지 확인한다", "필요 없어지면 `docker rmi 새이미지` 로 이미지를 정리한다"]', NULL, '오래 쓸 이미지는 Dockerfile 로 다시 만들 수 있게 관리하는 것이 좋습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 29);
