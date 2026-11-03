-- 도커 세트 199. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set199.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 199, '컨테이너에 붙기·찾기·만들기: exec -e/-w/-u/-d, attach, create/start, ps 필터, --cidfile, --pull, --network-alias', '실행 중인 컨테이너를 다루는 명령과 옵션의 동작을 한 개념씩 반복합니다. docker exec 의 -e·-w·-u 가 그 명령에만 적용되는 것과 없는 폴더·상대 경로·없는 사용자의 오류, -d 분리 실행, 종료 코드 전달과 정지된 컨테이너의 오류, docker attach 가 붙은 뒤의 출력만 보여 주고 컨테이너 종료 코드로 끝나는 것, create 와 start 와 start -a 의 차이, ps 의 status·exited 필터와 -q·-n·-l, --cidfile 에 적히는 전체 ID, --pull never 와 기본 missing, no-new-privileges 와 NoNewPrivs, --sysctl 이 허용되는 범위, 사용자 정의 네트워크의 --network-alias 와 기본 bridge 의 오류를 짧은 객관식·빈칸·순서 문제로 익히고, exec 로 컨테이너 안 살펴보기, 만들어 두고 실행해 보기, 이름 별칭으로 연결하기, 컨텍스트로 대상 바꾸기의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 199);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🧷' WHERE id = 199;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 1, 'exec 의 환경 변수 -e', '실행 중인 컨테이너에 `docker exec -e FOO=bar web sh -c ''echo $FOO''` 를 하면 무엇이 출력될까요? 이어서 `-e` 없이 같은 명령을 다시 실행하면요?', '그 `exec` 프로세스에만 붙는 값이에요.', NULL, NULL, '[]', 'choice', '["두 번 모두 `bar` 가 출력된다", "처음에도 빈 값이 출력된다", "처음에는 `bar` 가 출력되고, `-e` 없이 다시 실행하면 빈 값이다. `-e` 로 준 변수는 그 `exec` 로 시작한 프로세스에만 있고 컨테이너 본체(PID 1)나 다른 `exec` 에는 남지 않는다", "`-e` 는 `docker run` 에서만 쓸 수 있어 오류가 난다"]', 2, '컨테이너 전체의 환경 변수를 바꾸려면 `docker run -e` 로 새로 만들어야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 2, 'exec 의 작업 위치 -w', '`docker exec -w /tmp web pwd`, `docker exec web pwd`(이미지 `WORKDIR` 없음), `docker exec -w /nodir web pwd`, `docker exec -w rel web pwd` 는 각각 어떻게 될까요?', '위치는 컨테이너 안의 절대 경로로 줘야 해요.', NULL, NULL, '[]', 'choice', '["모두 `/tmp` 를 출력한다", "차례로 `/tmp`, `/`, 폴더가 없다는 `chdir ... no such file or directory` 오류, `Cwd must be an absolute path` 오류가 난다. `-w` 는 컨테이너 안의 존재하는 절대 경로여야 한다", "없는 폴더는 `-w` 가 자동으로 만들어 준다", "상대 경로는 이미지의 `WORKDIR` 기준으로 해석된다"]', 1, '이 옵션은 그 `exec` 에만 적용되고 컨테이너의 기본 작업 위치는 바뀌지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 3, 'exec 의 사용자 -u', '`docker exec -u 1000:2000 web id`, `docker exec -u nobody web id`, `docker exec -u nouser web id` 는 각각 어떻게 될까요? (`-u` 없이는 root 입니다)', '숫자 ID 는 이름이 없어도 쓸 수 있어요.', NULL, NULL, '[]', 'choice', '["차례로 `uid=1000 gid=2000 groups=2000`, `uid=65534(nobody) gid=65534(nobody) ...`, `unable to find user nouser: no matching entries in passwd file` 오류(종료 코드 1)이다. 숫자 UID:GID 는 passwd 에 없어도 되지만 이름은 있어야 한다", "세 명령 모두 root 로 실행된다", "숫자 UID:GID 는 passwd 에 항목이 없으면 오류이다", "없는 사용자 이름은 자동으로 만들어진다"]', 0, '`-u` 도 그 `exec` 에만 적용됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 4, 'exec -d 분리 실행', '`docker exec -d web sh -c ''sleep 3; echo done > /tmp/d.txt; echo hi''` 를 하면 바로 어떤 일이 생길까요? 3초 뒤에는요?', '`-d` 는 기다리지 않고 돌려보내요.', NULL, NULL, '[]', 'choice', '["3초 동안 기다린 뒤 `hi` 를 출력하고 돌아온다", "명령이 취소되어 파일이 생기지 않는다", "`-d` 는 컨테이너 자체를 새로 만든다", "명령이 바로 종료 코드 0 으로 돌아오고 `hi` 는 화면에 나오지 않는다. 명령은 컨테이너 안에서 계속 실행되어 3초 뒤 `/tmp/d.txt` 에 `done` 이 생긴다"]', 3, '오래 걸리는 점검이나 작업을 터미널을 잡지 않고 시작할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 5, 'exec 의 종료 코드와 정지된 컨테이너', '`docker exec web sh -c ''exit 7''` 후 `echo $?`, `docker exec web nosuchcmd`, 정지된 컨테이너에 `docker exec` 는 각각 어떻게 될까요?', '명령의 종료 코드가 그대로 전달돼요.', NULL, NULL, '[]', 'choice', '["항상 0 을 돌려 주고 안의 실패는 숨긴다", "정지된 컨테이너는 `exec` 가 자동으로 시작해 준다", "차례로 `7`, `executable file not found in $PATH`(종료 코드 127), `container ... is not running`(종료 코드 1)이다. `exec` 는 실행 중인 컨테이너에만 쓸 수 있고 안의 명령 종료 코드를 그대로 돌려 준다", "없는 명령은 컨테이너를 종료시킨다"]', 2, '스크립트에서 `docker exec` 의 `$?` 로 안의 명령 성공 여부를 판단할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 6, 'docker attach', '1초마다 `n1`, `n2`, ... `n8` 을 출력하고 코드 3 으로 끝나는 컨테이너를 실행하고 3초쯤 뒤 `docker attach --no-stdin` 을 하면 어떻게 될까요? 이미 종료된 컨테이너에는요?', '붙은 뒤의 출력만 보여요.', NULL, NULL, '[]', 'choice', '["처음부터 `n1` 까지 모든 출력을 다시 보여 준다", "붙은 시점부터의 새 출력(`n1` 이 아닌 이후 줄)만 보이고 컨테이너가 끝나면 `attach` 도 컨테이너의 종료 코드 3 으로 끝난다. 종료된 컨테이너에는 `cannot attach to a stopped container, start it first` 오류가 난다", "`attach` 는 항상 종료 코드 0 으로 끝난다", "종료된 컨테이너도 자동으로 시작해서 붙는다"]', 1, '전체 기록은 `docker logs` 로 봅니다. 위 컨테이너의 `docker logs` 에는 `n1` 부터 `n8` 까지 모두 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 7, 'create 와 start', '`docker create --name c alpine echo hello` 후 `docker ps`, `docker ps -a`, `docker start c`, `docker start -a c` 를 차례로 하면 각각 어떻게 될까요?', '`create` 는 만들기만 해요.', NULL, NULL, '[]', 'choice', '["`create` 만으로는 `Created` 상태라 `docker ps` 에는 안 보이고 `ps -a` 에만 보인다. `docker start c` 는 이름 `c` 만 출력하고 `hello` 는 `docker logs c` 로 봐야 하며, `docker start -a c` 는 출력 `hello` 를 바로 보여 준다", "`create` 는 만든 즉시 명령까지 실행한다", "`docker start c` 도 `hello` 를 화면에 바로 출력한다", "`Created` 상태 컨테이너도 `docker ps` 에 보인다"]', 0, '종료된 컨테이너에 `docker start -a` 를 다시 하면 같은 명령이 처음부터 다시 실행됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 8, 'ps 필터로 찾기', '`docker run` 으로 `exit 1`, `exit 0` 으로 끝나는 컨테이너와 계속 실행되는 컨테이너를 만들었습니다. `docker ps -a --filter status=exited`, `--filter exited=1`, `docker ps --filter status=running` 은 각각 무엇을 보여 줄까요?', '`exited=` 는 종료 코드로 걸러요.', NULL, NULL, '[]', 'choice', '["`exited=1` 은 종료된 컨테이너 모두를 보여 준다", "`status=exited` 는 종료 코드 0 인 컨테이너만 보여 준다", "`status=running` 은 종료된 컨테이너도 포함한다", "`status=exited` 는 종료된 컨테이너 둘(코드 1, 코드 0) 모두, `exited=1` 은 종료 코드가 1 인 컨테이너만, `status=running` 은 실행 중인 컨테이너만 보여 준다. `-a` 가 없으면 종료된 컨테이너는 목록에 나오지 않는다"]', 3, '`--filter ancestor=alpine` 처럼 쓴 이미지로 걸러낼 수도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 9, 'ps 의 -q, -n, -l', '`docker ps -aq`, `docker ps -a -n 1`, `docker ps -a -l` 은 각각 무엇을 출력할까요?', 'ID 만, 그리고 가장 최근 것이에요.', NULL, NULL, '[]', 'choice', '["`-q` 는 컨테이너 이름만 출력한다", "`-l` 은 가장 오래된 컨테이너를 보여 준다", "`-q` 는 컨테이너 ID 만(짧은 12자) 한 줄씩 출력하고, `-n 1` 과 `-l` 은 가장 최근에 만든 컨테이너 하나만 보여 준다. `-aq` 는 종료된 것까지 모든 ID 를 출력하므로 `docker rm $(docker ps -aq)` 같은 스크립트에 쓴다", "`-n 1` 은 실행 중인 컨테이너 중 하나를 무작위로 보여 준다"]', 2, '`--no-trunc` 를 붙이면 ID 가 64자 전체로 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 10, '--cidfile', '`docker run -d --cidfile /tmp/web.cid alpine sleep 60` 후 파일 내용은 무엇일까요? 같은 파일 이름으로 `docker run --cidfile` 을 또 하면요?', '컨테이너 ID 를 파일에 적어 줘요.', NULL, NULL, '[]', 'choice', '["파일에는 컨테이너 이름이 들어간다", "파일에는 컨테이너의 전체 ID(64자, `docker inspect` 의 `Id` 와 같음)가 들어간다. 파일이 이미 있으면 `container ID file found` 오류로 컨테이너를 만들지 않고 종료 코드 125 로 끝난다", "같은 파일이면 내용을 덮어쓰고 새 컨테이너를 시작한다", "파일에는 12자 짧은 ID 만 들어간다"]', 1, '스크립트에서 방금 만든 컨테이너를 정확히 가리킬 때 쓰고, 다시 쓰려면 파일을 먼저 지웁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 11, '--pull 정책', '`docker run --pull never no-such-img:1 true` 와 `docker run --pull never alpine echo ok` 는 로컬에 `alpine` 만 있을 때 각각 어떻게 될까요? `--pull` 의 기본값은요?', '`never` 는 내려받지 않아요.', NULL, NULL, '[]', 'choice', '["앞의 것은 `No such image` 오류로 종료 코드 125 이고, 뒤의 것은 로컬 이미지로 `ok` 를 출력한다. 기본값은 `missing` 으로 이미지가 로컬에 없을 때만 내려받는다", "`never` 는 없는 이미지를 대신 만들어 준다", "기본값은 `always` 라 매번 내려받는다", "`never` 면 로컬에 있어도 실행이 거부된다"]', 0, '`--pull always` 는 로컬에 있어도 최신 여부를 확인하려고 매번 가져옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 12, 'no-new-privileges', '`docker run --rm alpine grep NoNewPrivs /proc/self/status` 와 `--security-opt no-new-privileges` 를 붙인 경우의 값은 각각 무엇일까요? `docker inspect` 에는 어떻게 저장될까요?', '프로세스가 더 높은 권한을 얻지 못하게 하는 플래그예요.', NULL, NULL, '[]', 'choice', '["옵션 없이도 항상 `NoNewPrivs: 1` 이다", "옵션을 붙이면 root 권한이 모두 사라진다", "`inspect` 에는 저장되지 않는다", "기본은 `NoNewPrivs: 0`, 옵션을 붙이면 `NoNewPrivs: 1` 이다. `no-new-privileges:true` 로 지정하면 `HostConfig.SecurityOpt` 에 `no-new-privileges:true` 로 저장된다. setuid 등으로 권한을 새로 얻는 것을 막는다"]', 3, '컨테이너 안에서 `sudo` 나 setuid 바이너리로 권한이 오르는 경로를 줄이는 보안 옵션입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 13, '--sysctl', '`docker run --rm --sysctl net.ipv4.ip_unprivileged_port_start=1000 alpine cat /proc/sys/net/ipv4/ip_unprivileged_port_start` 는 무엇을 출력할까요? (옵션 없이는 0) `--sysctl vm.swappiness=1` 은요?', '컨테이너 격리 범위 안의 값만 바꿀 수 있어요.', NULL, NULL, '[]', 'choice', '["`vm.swappiness` 도 호스트 값을 바꿔 준다", "`--sysctl` 로 준 값은 컨테이너에 적용되지 않는다", "`1000` 이 출력된다. 컨테이너의 네트워크 네임스페이스 안의 값이라 바꿀 수 있다. `vm.swappiness` 는 호스트 전체에 영향을 주는 값이라 `sysctl ''vm.swappiness=1'' is not allowed` 로 시작 전에 거부된다", "`net.ipv4...` 값도 호스트 전체가 바뀐다"]', 2, '네임스페이스 단위로 격리되는 일부 `net.*`, `kernel.shm*` 값만 허용됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 14, '--network-alias', '사용자 정의 네트워크 `app-net` 에서 `docker run -d --name db --network app-net --network-alias database alpine sleep 60` 후 같은 네트워크의 다른 컨테이너에서 `database` 와 `db` 를 찾으면 어떻게 될까요? 기본 `bridge` 에서 `--network-alias` 는요?', '별칭은 이름 하나를 더 붙이는 거예요.', NULL, NULL, '[]', 'choice', '["별칭을 주면 컨테이너 이름은 더 이상 쓸 수 없다", "같은 네트워크에서는 `database` 도 `db` 도 모두 `db` 컨테이너의 주소로 찾아진다(`getent hosts`, `ping` 성공). 기본 `bridge` 에서 쓰면 `network-scoped aliases are only supported for user-defined networks` 오류가 난다", "기본 `bridge` 에서도 별칭이 잘 동작한다", "별칭은 다른 네트워크의 컨테이너에서도 보인다"]', 1, '여러 컨테이너에 같은 별칭을 주면 간단한 이름 기반 분산에 쓸 수도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 15, 'exec 환경 변수 옵션', '`docker exec` 로 **그 명령에만 환경 변수를 주는** 옵션의 긴 이름을 채우세요.', '"env"의 풀네임이에요.', NULL, NULL, '[]', 'fill', '["--env", "--var", "--set", "--export"]', NULL, '짧은 이름은 `-e` 입니다.', '[0]', 'docker exec {0} FOO=bar web env', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 16, 'exec 작업 위치 옵션', '`docker exec` 로 명령을 실행할 **컨테이너 안의 작업 위치**를 정하는 옵션의 긴 이름을 채우세요.', '"work"와 "dir"를 이어요.', NULL, NULL, '[]', 'fill', '["--workdir", "--cwd", "--dir", "--chdir"]', NULL, '짧은 이름은 `-w` 이고 절대 경로여야 합니다.', '[0]', 'docker exec {0} /tmp web pwd', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 17, '분리 키 바꾸기', '`docker attach` 에서 **떼어내는 키 조합을 바꾸는** 옵션을 채우세요.', '"detach"와 "keys"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--detach-keys", "--escape-keys", "--detach-key", "--quit-keys"]', NULL, '기본 조합은 Ctrl+P 다음 Ctrl+Q 입니다.', '[0]', 'docker attach {0} ctrl-x,x web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 18, '입력 연결 끄기', '`docker attach` 에서 **표준 입력을 연결하지 않고** 출력만 보게 하는 옵션을 채우세요.', '"no"와 "stdin"을 이어요.', NULL, NULL, '[]', 'fill', '["--no-stdin", "--no-input", "--read-only", "--detach"]', NULL, '입력은 연결하지 않고 출력만 보고 싶을 때 씁니다.', '[0]', 'docker attach {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 19, '출력을 보며 시작', '만들어 둔 컨테이너를 시작하면서 **출력을 화면에 이어 주는** `docker start` 옵션을 채우세요.', '"attach"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-a", "-d", "-r", "-q"]', NULL, '붙이지 않으면 컨테이너 이름만 출력됩니다.', '[0]', 'docker start {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 20, '만들기만 하는 명령', '컨테이너를 **만들기만 하고 실행하지 않는** 명령을 채우세요.', '상태가 `Created` 가 돼요.', NULL, NULL, '[]', 'fill', '["create", "init", "build", "define"]', NULL, '만든 컨테이너는 `docker start` 로 실행합니다.', '[0]', 'docker {0} --name web alpine echo hi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 21, 'ID 파일 옵션', '`docker run` 으로 만든 **컨테이너 ID 를 파일에 적는** 옵션을 채우세요.', '"container ID file"을 줄인 이름이에요.', NULL, NULL, '[]', 'fill', '["cidfile", "idfile", "pidfile", "write-id"]', NULL, '파일이 이미 있으면 오류로 끝납니다.', '[0]', 'docker run -d --{0} /tmp/web.cid alpine sleep 60', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 22, '내려받지 않는 정책', '이미지를 **절대 내려받지 않고 로컬 것만 쓰게** 하는 `--pull` 값을 채우세요.', '"절대 ~하지 않는다"는 뜻의 단어예요.', NULL, NULL, '[]', 'fill', '["never", "local", "skip", "off"]', NULL, '로컬에 없으면 오류로 끝납니다.', '[0]', 'docker run --pull {0} app:1 true', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 23, '권한 상승 막기', '프로세스가 **새 권한을 얻지 못하게 하는** `--security-opt` 값을 채우세요.', '"no", "new", "privileges"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["no-new-privileges", "no-root", "drop-privileges", "deny-sudo"]', NULL, '`/proc/self/status` 의 `NoNewPrivs` 가 1 이 됩니다.', '[0]', 'docker run --security-opt {0} alpine id', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 24, '컨텍스트 바꾸기', '`docker` 명령이 **보는 대상 환경을 전환하는** `docker context` 하위 명령을 채우세요.', '"쓰다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["use", "switch", "select", "set"]', NULL, '`docker context ls` 로 목록을, `docker context show` 로 현재 컨텍스트를 봅니다.', '[0]', 'docker context {0} dev', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 25, '네트워크 별칭 옵션', '사용자 정의 네트워크에서 컨테이너에 **이름 하나를 더 붙이는** 옵션을 채우세요.', '"network"와 "alias"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["network-alias", "alias", "net-name", "host-alias"]', NULL, '기본 `bridge` 에서는 쓸 수 없습니다.', '[0]', 'docker run -d --network app-net --{0} database alpine sleep 60', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 26, '실행 중인 컨테이너 안을 살펴보기', '실행 중인 컨테이너 안을 `exec` 로 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 확인 → 환경 주기 → 분리 실행 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name web alpine sleep 600` 으로 컨테이너를 실행한다", "`docker exec -w /tmp web pwd` 로 작업 위치를 바꿔 `/tmp` 가 나오는지 확인한다", "`docker exec -e FOO=bar web sh -c ''echo $FOO''` 로 그 명령에만 변수가 적용되는지 확인한다", "`docker exec -d web sh -c ''sleep 3; touch /tmp/d''` 로 분리 실행하고 몇 초 뒤 `/tmp/d` 가 생겼는지 본다"]', NULL, '정지된 컨테이너에는 `exec` 가 `is not running` 오류로 실패합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 27, '만들어 두고 실행해 보기', '`create` 로 만든 컨테이너를 상태와 함께 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 확인 → 실행 → 종료 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker create --name c alpine echo hello` 로 컨테이너를 만든다", "`docker ps -a` 에서 상태가 `Created` 이고 `docker ps` 에는 안 보이는지 확인한다", "`docker start -a c` 로 실행해 `hello` 가 출력되는지 본다", "`docker inspect -f` 로 상태가 `exited` 이고 종료 코드가 0 인지 확인한다"]', NULL, '`docker start` 를 `-a` 없이 쓰면 이름만 출력되고 결과는 `docker logs` 로 봅니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 28, '이름 별칭으로 연결하기', '사용자 정의 네트워크에서 별칭으로 다른 컨테이너를 찾는 순서입니다. 순서에 맞게 놓아 보세요.', '네트워크 → 서버 → 클라이언트 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker network create app-net` 으로 사용자 정의 네트워크를 만든다", "`docker run -d --name db --network app-net --network-alias database alpine sleep 60` 으로 서버를 실행한다", "`docker run --rm --network app-net alpine` 으로 같은 네트워크에서 클라이언트를 실행한다", "클라이언트 안에서 `getent hosts database` 나 `ping database` 로 별칭이 찾아지는지 확인한다"]', NULL, '기본 `bridge` 에서는 별칭 옵션이 오류로 거부됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 29, '컨텍스트로 대상 바꾸기', '`docker context` 로 다른 환경을 가리키게 했다가 되돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 목록 → 전환 → 복구 순서예요.', NULL, NULL, '[]', 'order', '["`docker context create dev --docker host=unix:///var/run/docker.sock` 으로 컨텍스트를 만든다", "`docker context ls` 로 `default` 와 `dev` 가 보이는지 확인한다", "`docker context use dev` 로 전환하고 `docker context show` 로 `dev` 인지 확인한다", "`docker context use default` 로 되돌리고 필요 없으면 `docker context rm dev` 로 지운다"]', NULL, '사용 중인 컨텍스트는 `rm` 이 거부되므로 먼저 다른 것으로 바꿉니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 29);
