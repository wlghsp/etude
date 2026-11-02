-- 도커 세트 191. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set191.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 191, '실행 중 컨테이너 다루기: rename, update, 재시작 정책, --pids-limit, OOM, wait, top', '실행 중인 컨테이너를 다루는 명령의 동작을 한 개념씩 반복합니다. docker rename 의 오류와 호스트 이름 유지, docker update 로 메모리·CPU·PID 한도와 재시작 정책을 재시작 없이 바꾸고 inspect 로 확인하는 것, 메모리 최소값 오류, on-failure:N 의 재시작 횟수, on-failure 와 no 와 always 의 정상 종료 처리, 직접 정지한 always·unless-stopped 컨테이너, 잘못된 재시도 횟수 오류, --pids-limit 과 can''t fork, --memory 한도와 OOMKilled·종료 코드 137, docker wait 의 종료 코드, docker top 의 열, -it 가 저장하는 Tty·OpenStdin, docker stats --no-stream, ps 의 --no-trunc 와 status 필터를 짧은 객관식·빈칸·순서 문제로 익히고, 재시작 정책 동작 확인하기, 실행 중 자원 한도 조정하기, OOM 으로 죽은 컨테이너 원인 찾기, 이름 바꿔서 정리하기의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 191);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '♻️' WHERE id = 191;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 1, '컨테이너 이름 바꾸기', '실행 중인 컨테이너의 이름을 `docker rename 이전 새이름` 으로 바꾸면 컨테이너는 계속 실행될까요? 이미 있는 이름으로 바꾸면요?', '이름만 바뀌고 컨테이너는 그대로예요.', NULL, NULL, '[]', 'choice', '["컨테이너가 재시작되고 새 이름이 적용된다", "이미 있는 이름으로도 바꿀 수 있어 두 컨테이너가 같은 이름을 쓴다", "실행 중인 채로 이름만 바뀌고 `docker inspect` 의 `Name` 항목(`/새이름`)에 새 이름이 나온다. 이미 쓰는 이름으로 바꾸면 `Conflict. The container name ... is already in use` 오류가 나고, 같은 이름으로 바꾸면 `Renaming a container with the same name` 오류가 난다", "실행 중인 컨테이너는 이름을 바꿀 수 없다"]', 2, '이름을 바꿔도 컨테이너 안의 호스트 이름(기본은 12글자의 짧은 ID)은 그대로입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 2, '실행 중 자원 한도 바꾸기', '실행 중인 컨테이너에 `docker update --memory 64m --memory-swap 64m`, `--cpus 0.5`, `--pids-limit 50` 을 하면 어떻게 될까요? 확인은 어떻게 할까요?', '재시작 없이 바뀌는 설정이 있어요.', NULL, NULL, '[]', 'choice', '["자원 한도는 컨테이너를 만들 때만 정할 수 있어 오류가 난다", "컨테이너를 다시 만들지 않고 설정이 바뀌며 `docker inspect` 의 `HostConfig.Memory` 와 `MemorySwap` 이 `67108864`, `NanoCpus` 가 `500000000`, `PidsLimit` 가 `50` 으로 나온다", "컨테이너가 중지된 뒤에야 값이 반영된다", "`docker update` 는 이미지의 설정을 바꾼다"]', 1, '`docker update` 도 컨테이너 이름이나 ID 를 출력하므로 어느 컨테이너가 바뀌었는지 보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 3, '메모리 최소값', '실행 중인 컨테이너에 `docker update --memory 1m` 을 하면 어떻게 될까요?', '너무 작은 값은 거부돼요.', NULL, NULL, '[]', 'choice', '["`Minimum memory limit allowed is 6MB` 오류로 거부되고 기존 한도는 바뀌지 않는다", "1MB 한도가 적용되어 컨테이너가 바로 종료된다", "오류 없이 무제한으로 바뀐다", "`1m` 은 1바이트로 해석된다"]', 0, '컨테이너가 계속 실행 중이라 `State.Running` 은 `true` 로 유지됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 4, '재시작 정책 바꾸기', '실행 중인 컨테이너에 `docker update --restart on-failure:3` 을 하면 정책은 어디에서 확인하고 어떻게 보일까요?', 'HostConfig 아래에 있어요.', NULL, NULL, '[]', 'choice', '["정책은 이미지에 저장되어 컨테이너에서는 볼 수 없다", "정책을 바꾸려면 컨테이너를 지우고 새로 만들어야 한다", "`on-failure:3` 은 항상 3번 재시작한다는 뜻이다", "`docker inspect` 의 `HostConfig.RestartPolicy` 에서 `Name` 이 `on-failure`, `MaximumRetryCount` 가 `3` 으로 나오고 컨테이너는 계속 실행 중이다"]', 3, '다시 만들지 않고도 `no`, `always`, `unless-stopped` 로 바꿀 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 5, 'on-failure:2', '종료 코드 3 으로 바로 끝나는 컨테이너를 `--restart on-failure:2` 로 실행하면 몇 번 재시작하고 어떤 상태로 끝날까요?', '최대 재시작 횟수가 정해져 있어요.', NULL, NULL, '[]', 'choice', '["계속 재시작을 반복한다", "한 번도 재시작하지 않는다", "최대 2번 재시작한 뒤 `exited` 상태로 멈추고 `RestartCount` 는 2, 종료 코드는 3 이다", "재시작 횟수가 1 로 끝난다"]', 2, '`State.ExitCode` 와 `RestartCount` 는 `docker inspect` 출력에서 읽습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 6, 'on-failure 와 정상 종료', '`--restart on-failure` 로 실행한 컨테이너가 종료 코드 0 으로 끝나면 재시작될까요? `--restart no` 로 종료 코드 3 으로 끝나면요?', '실패일 때만 또는 아예 안 해요.', NULL, NULL, '[]', 'choice', '["`on-failure` 는 종료 코드 0 에서도 재시작한다", "둘 다 재시작되지 않고 `exited`, `RestartCount` 0 이다. `on-failure` 는 0 이 아닌 종료 코드일 때만 재시작하고, `no` 는 재시작하지 않는다", "`no` 는 종료 코드가 3 이면 재시작한다", "둘 다 한 번은 재시작한다"]', 1, '종료 코드 0 은 정상 종료, 0 이 아닌 값은 실패로 다룹니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 7, 'always 와 정상 종료', '종료 코드 0 으로 바로 끝나는 컨테이너를 `--restart always` 로 실행하면 어떻게 될까요?', '정상 종료도 다시 시작해요.', NULL, NULL, '[]', 'choice', '["종료 코드가 0 이어도 계속 다시 시작하므로 `docker ps -a` 에 `Restarting` 상태가 보이고 `RestartCount` 가 1 이상이 된다", "정상 종료이므로 재시작하지 않는다", "한 번만 재시작하고 멈춘다", "종료 코드가 0 이 아닐 때만 재시작한다"]', 0, '`on-failure` 와 달리 `always` 는 종료 코드와 상관없이 다시 시작합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 8, '직접 정지한 컨테이너', '`--restart always` 또는 `unless-stopped` 인 컨테이너를 `docker stop` 으로 직접 멈추고 2초 뒤 상태를 보면 어떨까요?', '사용자가 멈춘 것은 다시 시작하지 않아요.', NULL, NULL, '[]', 'choice', '["둘 다 바로 `running` 으로 돌아온다", "`always` 만 바로 `running` 으로 돌아온다", "`docker stop` 은 재시작 정책이 있으면 실패한다", "둘 다 `exited` 로 멈춘 상태로 남고 바로 다시 시작되지 않는다 (`unless-stopped` 의 `RestartCount` 는 0)"]', 3, '정책이 `no` 인 컨테이너와 같이 `docker start` 로 직접 다시 시작해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 9, '잘못된 재시작 정책', '`docker run --restart on-failure:x alpine true` 처럼 재시도 횟수에 숫자가 아닌 값을 쓰면 어떻게 될까요?', '횟수는 정수여야 해요.', NULL, NULL, '[]', 'choice', '["재시도 횟수가 0 으로 처리되어 실행된다", "`x` 가 무제한이라는 뜻으로 처리된다", "컨테이너를 만들지 않고 `invalid restart policy format: maximum retry count must be an integer` 오류가 난다", "경고만 출력하고 `on-failure` 로 실행된다"]', 2, '`on-failure:3` 처럼 콜론 뒤에 정수를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 10, '프로세스 수 제한', '`docker run --pids-limit 5` 로 만든 컨테이너 안에서 `sleep` 을 백그라운드로 8개 띄우면 어떻게 될까요?', '프로세스 수가 한도를 넘어요.', NULL, NULL, '[]', 'choice', '["`--pids-limit` 은 영향이 없어 8개가 모두 실행된다", "한도를 넘는 시점부터 `can''t fork: Resource temporarily unavailable` 오류가 나서 새 프로세스를 만들지 못한다", "컨테이너가 즉시 삭제된다", "한도를 넘으면 자동으로 한도가 늘어난다"]', 1, '무한 프로세스 생성(포크 폭탄)이 호스트로 번지는 것을 막는 데 쓰는 옵션입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 11, '메모리 한도와 OOM', '`--memory 20m --memory-swap 20m` 컨테이너에서 약 40MB 의 문자열을 만들면 어떻게 될까요? 어떻게 확인할까요?', '한도를 넘으면 커널이 프로세스를 종료해요.', NULL, NULL, '[]', 'choice', '["프로세스가 강제 종료되어 `docker inspect` 의 `State.ExitCode` 가 `137`, `State.OOMKilled` 가 `true` 로 나온다. 컨테이너 안의 `/sys/fs/cgroup/memory.max` 에는 `20971520` 이 보인다", "오류 없이 40MB 를 모두 사용한다", "종료 코드 0 으로 정상 종료한다", "`OOMKilled` 는 항상 `false` 이다"]', 0, '`20m` 은 20 × 1024 × 1024 = 20971520 바이트입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 12, 'docker wait', '`sleep 2; exit 7` 을 실행하는 컨테이너에 `docker wait 이름` 을 하면 무엇이 출력될까요? 없는 컨테이너에는요?', '끝날 때까지 기다렸다가 종료 코드를 알려요.', NULL, NULL, '[]', 'choice', '["즉시 `running` 을 출력하고 끝난다", "컨테이너 ID 를 출력한다", "없는 컨테이너도 `0` 을 출력한다", "컨테이너가 끝날 때까지 기다린 뒤 종료 코드 `7` 을 출력한다. 없는 컨테이너에는 `No such container` 오류가 난다"]', 3, '스크립트에서 컨테이너 작업이 끝나길 기다렸다가 결과를 판단할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 13, 'docker top', '실행 중인 컨테이너에 `docker top 이름` 과 `docker top 이름 -o pid,comm` 을 하면 각각 무엇이 나올까요?', '컨테이너 안의 프로세스 목록이에요.', NULL, NULL, '[]', 'choice', '["컨테이너의 CPU 사용률 그래프를 보여 준다", "`-o` 는 지원하지 않아 오류가 난다", "`docker top 이름` 은 `UID PID PPID C STIME TTY TIME CMD` 열로 프로세스를 보여 주고, `-o pid,comm` 은 `PID COMMAND` 열만 보여 준다 (예: `sleep`). 컨테이너 밖에서 안의 프로세스를 볼 수 있다", "컨테이너를 중지하고 프로세스를 보여 준다"]', 2, '열 이름은 `ps` 옵션과 같은 방식으로 고릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 14, '-it 가 저장하는 값', '`docker run -d -it` 로 만든 컨테이너와 `-it` 없이 만든 컨테이너의 `Config.Tty` 와 `Config.OpenStdin` 은 각각 어떻게 다를까요?', '터미널과 표준 입력을 연다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["둘 다 항상 `true` 이다", "`-it` 컨테이너는 둘 다 `true`, `-it` 없이 만든 컨테이너는 둘 다 `false` 로 저장된다", "`-it` 와 상관없이 `Tty` 만 `true` 이다", "`docker inspect` 로는 이 값을 볼 수 없다"]', 1, '`docker inspect` 의 `Config.Tty`, `Config.OpenStdin` 항목으로 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 15, '이름 바꾸기', '컨테이너 `old` 의 이름을 `new` 로 바꾸는 명령을 채우세요.', '"이름 바꾸기"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["rename", "mv", "name", "update"]', NULL, '실행 중에도 이름만 바뀝니다.', '[0]', 'docker {0} old new', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 16, '실행 중 설정 변경', '실행 중인 컨테이너의 자원 한도나 재시작 정책을 바꾸는 명령을 채우세요.', '"갱신"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["update", "set", "edit", "modify"]', NULL, '컨테이너를 다시 만들지 않고 바뀝니다.', '[0]', 'docker {0} --cpus 0.5 web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 17, '메모리 한도 지정', '컨테이너의 메모리 한도를 64MB 로 정하는 옵션을 채우세요.', '"메모리"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--memory", "--mem-max", "--ram", "--limit"]', NULL, '스왑까지 함께 막으려면 `--memory-swap` 도 같은 값으로 정합니다.', '[0]', 'docker update {0} 64m web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 18, '프로세스 수 제한', '컨테이너 안의 프로세스(PID) 수를 제한하는 옵션을 채우세요.', '"pids" 와 "limit" 을 이은 이름이에요.', NULL, NULL, '[]', 'fill', '["--pids-limit", "--max-procs", "--proc-limit", "--threads"]', NULL, '한도를 넘으면 `can''t fork` 오류가 납니다.', '[0]', 'docker run {0} 50 alpine sleep 60', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 19, '실패 때만 재시작', '비정상 종료일 때만 최대 3번 재시작하는 정책 값을 채우세요.', '"실패 시"라는 뜻의 영어 단어에 횟수를 붙여요.', NULL, NULL, '[]', 'fill', '["on-failure", "always", "unless-stopped", "no"]', NULL, '종료 코드가 0 이면 재시작하지 않습니다.', '[0]', 'docker run --restart {0}:3 alpine sh -c ''exit 1''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 20, '직접 멈추면 유지', '`docker stop` 으로 직접 멈추면 다시 시작하지 않지만 그 밖에는 계속 다시 시작하는 정책 값을 채우세요.', '"멈춘 경우를 제외하고"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["unless-stopped", "on-failure", "no", "once"]', NULL, '`always` 도 직접 멈춘 컨테이너를 바로 다시 시작하지는 않습니다.', '[0]', 'docker run -d --restart {0} alpine sleep 300', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 21, '종료 코드 기다리기', '컨테이너가 끝날 때까지 기다린 뒤 종료 코드를 출력하는 명령을 채우세요.', '"기다리다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["wait", "sleep", "join", "watch"]', NULL, '출력되는 값은 컨테이너의 종료 코드입니다.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 22, '프로세스 목록 보기', '컨테이너 안에서 실행 중인 프로세스 목록을 보는 명령을 채우세요.', '리눅스의 프로세스 확인 명령 이름과 같아요.', NULL, NULL, '[]', 'fill', '["top", "ps-in", "procs", "stat"]', NULL, '`-o pid,comm` 처럼 열을 고를 수 있습니다.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 23, '전체 컨테이너 ID', '`docker ps` 에서 줄여 보이는 컨테이너 ID 를 64자 전체로 보이게 하는 옵션을 채우세요.', '"줄이지 않음"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--no-trunc", "--full", "--long-id", "--wide"]', NULL, '기본 ID 는 12글자로 줄여서 보입니다.', '[0]', 'docker ps -a {0} -q', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 24, '종료된 컨테이너만', '`docker ps -a` 에서 종료된 컨테이너만 걸러 보는 필터를 채우세요.', '`status=` 뒤에 상태 이름을 써요.', NULL, NULL, '[]', 'fill', '["status", "state", "phase", "running"]', NULL, '`Restarting` 상태는 `exited` 로 걸리지 않습니다.', '[0]', 'docker ps -a --filter {0}=exited', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 25, '한 번만 측정', '`docker stats` 가 계속 갱신하지 않고 한 번만 출력하고 끝나게 하는 옵션을 채우세요.', '"스트림 없음"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--no-stream", "--once", "--single", "--static"]', NULL, '한 번 출력하고 바로 끝납니다.', '[0]', 'docker stats {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 26, '재시작 정책 동작 확인하기', '재시작 정책이 의도대로 동작하는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 상태 확인 → 직접 정지 → 재확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name t --restart on-failure:2 alpine sh -c ''exit 3''` 으로 실패하는 컨테이너를 만든다", "몇 초 뒤 `docker inspect t` 의 `State.Status` 가 `exited`, `RestartCount` 가 2 인지 확인한다", "`docker inspect t` 의 `State.ExitCode` 가 3 인지 확인한다", "`docker update --restart no t` 로 정책을 바꾸고 `HostConfig.RestartPolicy` 의 `Name` 이 `no` 인지 확인한다"]', NULL, '`always` 와 `unless-stopped` 는 `docker stop` 으로 직접 멈추면 바로 다시 시작되지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 27, '실행 중 자원 한도 조정하기', '실행 중인 컨테이너의 메모리·프로세스 한도를 조정하고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '현재 값 → 변경 → 확인 → 실행 상태 순서예요.', NULL, NULL, '[]', 'order', '["`docker inspect web` 의 `HostConfig.Memory` 로 현재 한도를 확인한다", "`docker update --memory 64m --memory-swap 64m --pids-limit 50 web` 으로 한도를 바꾼다", "`docker inspect web` 의 `HostConfig.Memory` 가 `67108864`, `PidsLimit` 가 `50` 인지 확인한다", "`docker inspect web` 의 `State.Running` 이 `true` 인지 확인한다"]', NULL, '메모리 한도는 6MB 이상이어야 합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 28, 'OOM 으로 죽은 컨테이너 원인 찾기', '컨테이너가 갑자기 종료 코드 137 로 끝났을 때 메모리 부족 여부를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '종료 코드 → OOM 표시 → 한도 → 조정 순서예요.', NULL, NULL, '[]', 'order', '["`docker ps -a` 로 종료 코드 137 로 끝난 컨테이너를 찾는다", "`docker inspect 이름` 의 `State.ExitCode` 가 `137`, `State.OOMKilled` 가 `true` 인지 확인한다", "`docker inspect 이름` 의 `HostConfig.Memory` 로 설정된 메모리 한도를 확인한다", "필요하면 한도를 늘려 컨테이너를 다시 만든다"]', NULL, '종료 코드 137 은 신호로 강제 종료된 경우이며 `OOMKilled` 가 `true` 이면 메모리 한도 초과입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 29, '이름 바꿔서 정리하기', '컨테이너 이름을 바꾸고 목록에서 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 변경 → 재확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`docker ps --filter name=a` 로 현재 이름을 확인한다", "`docker rename a b` 로 이름을 바꾼다", "`docker inspect b` 의 `Name` 이 `/b` 인지 확인한다", "필요 없어진 컨테이너는 `docker rm -f b` 로 지운다"]', NULL, '이미 쓰는 이름으로는 바꿀 수 없습니다(`Conflict` 오류).', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 29);
