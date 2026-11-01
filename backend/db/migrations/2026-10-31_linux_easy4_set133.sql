-- 리눅스 세트 133. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set133.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 133, '쉘 스크립트, 서비스, 압축 한 줄씩', '리눅스 운영에 자주 쓰는 도구를 한 개념씩 쉬운 문제로 반복합니다. 쉘 스크립트의 shebang·실행 권한·변수·인자($1)·종료 코드($?)·&& 와 ||·set -e, systemctl 의 start·enable·status·restart·daemon-reload 와 journalctl -u, tar 로 압축·풀기·목록 보기(-czf, -xzf, -tzf, -C), 그리고 스크립트 작성, 서비스 장애 점검, 압축 백업의 순서를 짧은 객관식·빈칸·순서 문제로 익힙니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 133);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '📦' WHERE id = 133;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 1, '쉘 스크립트 첫 줄', '쉘 스크립트 파일 맨 윗줄의 `#!/bin/bash` 는 무슨 일을 할까요?', '이 파일을 누가 읽고 실행할지 알려 줘요.', NULL, NULL, '[]', 'choice', '["이 줄은 주석이라 아무 의미가 없다", "스크립트를 자동으로 백업한다", "이 파일을 `/bin/bash` 로 실행하라고 알려 준다", "스크립트를 관리자 권한으로 바꾼다"]', 2, '`#!` 로 시작하는 첫 줄을 shebang 이라고 부릅니다. 어떤 해석기로 실행할지 정해 주며, 이 줄이 있어야 `./run.sh` 로 바로 실행할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 2, '스크립트가 실행이 안 될 때', '`./backup.sh` 를 실행했더니 `Permission denied` 가 나왔습니다. 가장 먼저 할 일은 무엇일까요?', '파일에 실행 권한(x)이 있는지 봐요.', NULL, NULL, '[]', 'choice', '["`rm backup.sh` 로 지우고 다시 만든다", "`chmod +x backup.sh` 로 실행 권한을 준다", "`sudo reboot` 으로 재부팅한다", "파일 이름 끝에 `.exe` 를 붙인다"]', 1, '새로 만든 파일에는 실행 권한이 없습니다. `ls -l` 로 `x` 가 있는지 확인하고, 없으면 `chmod +x` 를 쓰세요. 권한 없이도 `bash backup.sh` 로는 실행할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 3, '변수 만들 때 주의', '쉘에서 변수를 만드는 올바른 모양은 무엇일까요?', '`=` 양옆에 공백이 들어가면 안 돼요.', NULL, NULL, '[]', 'choice', '["`NAME=etude`", "`NAME = etude`", "`$NAME=etude`", "`set NAME etude`"]', 0, '쉘은 `NAME = etude` 를 "NAME 이라는 명령을 실행하라"로 읽어 오류가 납니다. 만들 때는 `NAME=값`, 쓸 때는 `$NAME` 이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 4, '스크립트에 값 넘기기', '`./greet.sh kim` 으로 실행했을 때, 스크립트 안에서 `kim` 을 가리키는 것은 무엇일까요?', '첫 번째 인자는 숫자 1 과 관련 있어요.', NULL, NULL, '[]', 'choice', '["`$0`", "`$#`", "`$?`", "`$1`"]', 3, '`$1` 은 첫 번째 인자, `$2` 는 두 번째입니다. `$0` 은 스크립트 이름, `$#` 은 인자의 개수예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 5, '종료 코드', '직전 명령이 성공했는지 숫자로 알려 주는 `$?` 에서, 성공을 뜻하는 값은 무엇일까요?', '이름 그대로 "오류 0개"를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`1`", "`-1`", "`0`", "`100`"]', 2, '쉘에서는 0 이 성공, 0 이 아닌 값이 실패입니다. `if`, `&&`, `||` 가 모두 이 종료 코드를 보고 움직여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 6, '&& 와 || 의 차이', '`mkdir out && cd out` 에서 `&&` 는 무슨 뜻일까요?', '앞 명령이 잘 끝나야 뒤가 실행돼요.', NULL, NULL, '[]', 'choice', '["앞 명령이 실패해야 뒤 명령을 실행한다", "앞 명령이 성공하면 뒤 명령도 실행한다", "두 명령을 동시에 실행한다", "뒤 명령을 먼저 실행한다"]', 1, '`&&` 는 성공하면 이어서, `||` 는 실패하면 대신 실행합니다. 폴더를 만들지 못했는데 그 안으로 들어가려는 사고를 막아 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 7, 'set -e 의 역할', '스크립트 앞부분에 `set -e` 를 넣으면 어떻게 될까요?', 'e 는 error 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["명령이 하나라도 실패하면 스크립트를 바로 멈춘다", "모든 오류 메시지를 숨긴다", "스크립트를 두 번 실행한다", "명령 실행 시간을 늘린다"]', 0, '기본 쉘은 중간 명령이 실패해도 다음 줄을 계속 실행합니다. 백업이나 삭제처럼 순서가 중요한 스크립트에서는 `set -e` 로 실패 즉시 멈추게 하는 편이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 8, '변수는 따옴표로', '`rm -rf $DIR/old` 처럼 변수를 쓰는 줄에서, 변수가 비어 있으면 무슨 일이 생길 수 있을까요?', '`$DIR` 이 빈 값이면 경로가 `/old` 가 돼요.', NULL, NULL, '[]', 'choice', '["아무 일도 생기지 않고 조용히 건너뛴다", "쉘이 자동으로 기본값을 채워 준다", "스크립트가 컴파일 오류를 낸다", "의도하지 않은 경로(`/old`)를 지우려 할 수 있어 위험하다"]', 3, '변수는 `"$DIR"` 처럼 따옴표로 감싸고, 삭제 명령 앞에서는 변수가 비어 있지 않은지 확인하세요. `set -u` 는 정의되지 않은 변수를 쓰면 멈추게 해 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 9, 'systemctl enable 과 start', '`systemctl enable nginx` 와 `systemctl start nginx` 의 차이는 무엇일까요?', '하나는 지금, 하나는 다음 부팅부터예요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같은 명령이다", "`enable` 은 지금 실행하고 `start` 는 부팅 때만 실행한다", "`start` 는 지금 실행하고, `enable` 은 부팅할 때 자동으로 실행되게 등록한다", "`enable` 은 서비스를 삭제한다"]', 2, '`enable` 만 하면 지금은 꺼져 있고, `start` 만 하면 재부팅 뒤에는 다시 꺼집니다. 한 번에 하려면 `systemctl enable --now 서비스` 를 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 10, '서비스 상태 보기', '서비스가 떠 있는지, 최근 로그는 어떤지 한눈에 보는 명령은 무엇일까요?', '이름 그대로 상태(status)를 물어봐요.', NULL, NULL, '[]', 'choice', '["`systemctl list 서비스이름`", "`systemctl status 서비스이름`", "`service show 서비스이름`", "`systemctl look 서비스이름`"]', 1, '`status` 는 `active (running)`, `failed` 같은 상태와 마지막 로그 몇 줄을 보여 줍니다. 장애 때 가장 먼저 치는 명령이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 11, 'journalctl 은 무엇일까', '`journalctl -u nginx` 는 무엇을 보여 줄까요?', '-u 는 unit(서비스) 을 뜻해요.', NULL, NULL, '[]', 'choice', '["nginx 서비스가 남긴 로그", "nginx 설정 파일의 내용", "nginx 가 설치된 위치", "nginx 의 사용 포트 목록"]', 0, '`journalctl -u 서비스` 는 그 서비스의 로그만 모아 보여 줍니다. `-f` 로 실시간 따라가기, `--since "10 min ago"` 로 최근 10분만 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 12, 'daemon-reload 는 언제', '서비스 정의 파일(`*.service`)을 고친 뒤에 `systemctl daemon-reload` 를 하는 이유는 무엇일까요?', 'systemd 가 파일 내용을 다시 읽어야 해요.', NULL, NULL, '[]', 'choice', '["서비스를 자동으로 삭제하려고", "컴퓨터를 재부팅하려고", "서비스의 로그를 지우려고", "systemd 가 바뀐 정의 파일을 다시 읽게 하려고"]', 3, '정의 파일을 고치고 `daemon-reload` 를 하지 않으면 systemd 는 옛 내용을 기억합니다. 그 뒤에 `restart` 로 서비스를 다시 시작하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 13, 'tar 옵션 읽기', '`tar -czf backup.tar.gz data/` 에서 `c` 는 무엇을 뜻할까요?', 'c 는 create 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["묶음 파일을 푼다", "묶음 파일 안을 보여 준다", "새 묶음 파일을 만든다(create)", "묶음 파일을 지운다"]', 2, '`c` 만들기, `z` gzip 압축, `f` 파일 이름 지정입니다. 풀 때는 `x`, 내용만 볼 때는 `t` 를 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 14, '압축 풀 때 옵션', '`backup.tar.gz` 를 푸는 올바른 명령은 무엇일까요?', '풀기는 extract 의 x 예요.', NULL, NULL, '[]', 'choice', '["`tar -czf backup.tar.gz`", "`tar -xzf backup.tar.gz`", "`tar -tzf backup.tar.gz`", "`tar -rm backup.tar.gz`"]', 1, '`x` 는 풀기, `c` 는 만들기입니다. 같은 `z` 와 `f` 를 쓰고 앞의 글자만 달라져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 15, '실행 권한 주기', '스크립트 `run.sh` 에 **실행 권한**을 주는 명령입니다. 빈칸을 채우세요.', '권한 모양에서 x 를 더하는 거예요.', NULL, NULL, '[]', 'fill', '["+x", "-x", "+r", "000"]', NULL, '`+x` 는 실행 권한 추가, `-x` 는 제거입니다. 권한을 준 뒤에는 `./run.sh` 로 실행해요.', '[0]', 'chmod {0} run.sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 16, '스크립트 실행하기', '현재 폴더의 `run.sh` 를 **직접 실행**하는 올바른 모양입니다. 빈칸을 채우세요.', '현재 폴더를 뜻하는 점이 필요해요.', NULL, NULL, '[]', 'fill', '[".", "..", "~", "$"]', NULL, '현재 폴더의 파일은 `./파일` 로 실행합니다. 그냥 `run.sh` 라고만 치면 쉘은 PATH 에 등록된 곳에서만 찾아서 `command not found` 가 나와요.', '[0]', '{0}/run.sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 17, '변수 값 쓰기', '`NAME=etude` 로 만든 변수의 **값을 출력**하는 명령입니다. 빈칸을 채우세요.', '변수를 쓸 때는 앞에 달러 표시가 붙어요.', NULL, NULL, '[]', 'fill', '["$", "#", "&", "%"]', NULL, '만들 때는 `NAME`, 쓸 때는 `$NAME` 입니다. 이름 뒤에 글자를 이어 쓸 때는 `${NAME}_v2` 처럼 중괄호로 구분해요.', '[0]', 'echo {0}NAME', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 18, '성공 여부 확인', '직전 명령의 **종료 코드**를 출력하는 명령입니다. 빈칸을 채우세요.', '물음표가 들어간 특별한 변수예요.', NULL, NULL, '[]', 'fill', '["?", "!", "#", "*"]', NULL, '`$?` 가 0 이면 성공입니다. 스크립트에서는 `if [ $? -ne 0 ]; then ... fi` 로 실패를 처리하곤 해요.', '[0]', 'echo ${0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 19, '파일이 있는지 검사', '`if` 에서 **일반 파일이 존재하는지** 검사하는 부분입니다. 빈칸을 채우세요.', 'file 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-d", "-z", "-n"]', NULL, '`-f` 는 파일, `-d` 는 폴더가 있는지 봅니다. `[` 뒤와 `]` 앞의 공백을 빼먹으면 오류가 나니 주의하세요.', '[0]', 'if [ {0} /etc/hosts ]; then echo yes; fi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 20, '서비스 재시작', 'nginx 서비스를 **다시 시작**하는 명령입니다. 빈칸을 채우세요.', 'stop 하고 start 하는 것과 비슷해요.', NULL, NULL, '[]', 'fill', '["restart", "reset", "reload-all", "rerun"]', NULL, '`restart` 는 껐다 켜고, `reload` 는 끄지 않고 설정만 다시 읽습니다. 접속이 끊기면 안 될 때는 `reload` 를 먼저 고려하세요.', '[0]', 'systemctl {0} nginx', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 21, '부팅 때 자동 실행', 'nginx 서비스가 **부팅할 때 자동으로 실행**되도록 등록하는 명령입니다. 빈칸을 채우세요.', '켜 두다(enable) 라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["enable", "start", "status", "mask-all"]', NULL, '`enable` 은 부팅 때 자동 시작, `disable` 은 그 반대입니다. `enable` 은 지금 당장 켜 주지는 않으니 `--now` 를 붙이면 한 번에 돼요.', '[0]', 'systemctl {0} nginx', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 22, '실시간 로그 따라가기', 'nginx 서비스 로그를 **실시간으로 따라가며** 보는 옵션을 채우세요.', 'tail -f 와 같은 글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-r", "-n", "-x"]', NULL, '`-f` 는 follow 입니다. 서비스를 재시작하면서 로그가 어떻게 쌓이는지 볼 때 편하고, Ctrl+C 로 끝내요.', '[0]', 'journalctl -u nginx {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 23, '압축 묶음 만들기', '`data` 폴더를 gzip 으로 압축해 `data.tar.gz` 로 **만드는** 명령입니다. 빈칸을 채우세요.', '만들기(create), gzip(z), 파일(f) 의 첫 글자를 모았어요.', NULL, NULL, '[]', 'fill', '["czf", "xzf", "tzf", "rzf"]', NULL, '파일 이름을 바로 뒤에 두려면 `f` 를 맨 끝 옵션으로 씁니다. `czf`, `xzf`, `tzf` 는 한 글자만 다르지만 하는 일은 만들기, 풀기, 보기로 달라요.', '[0]', 'tar -{0} data.tar.gz data', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 24, '압축 내용만 보기', '`data.tar.gz` 를 풀지 않고 **안에 든 파일 목록만** 보는 명령입니다. 빈칸을 채우세요.', 'list 를 뜻하는 t 예요.', NULL, NULL, '[]', 'fill', '["tzf", "czf", "xzf", "rzf"]', NULL, '푸는 중 파일을 덮어쓰는 사고를 막으려면 먼저 `tzf` 로 안을 살펴보세요. 특히 경로가 `/` 로 시작하지 않는지 확인하면 좋아요.', '[0]', 'tar -{0} data.tar.gz', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 25, '다른 폴더에 풀기', '`data.tar.gz` 를 `/tmp/restore` 폴더에 **풀도록** 옵션을 채우세요.', '대문자 C 는 change directory 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["-C", "-d", "-o", "-t"]', NULL, '`-C 폴더` 는 그 폴더로 이동한 것처럼 풉니다. 폴더가 미리 만들어져 있어야 하니 `mkdir -p /tmp/restore` 를 먼저 하세요.', '[0]', 'tar -xzf data.tar.gz {0} /tmp/restore', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 26, '스크립트를 만들어 실행하기', '간단한 쉘 스크립트를 만들어 실행하기까지의 순서입니다. 순서에 맞게 놓아 보세요.', '쓰고 → 권한 → 실행 → 결과 확인 순서예요.', NULL, NULL, '[]', 'order', '["`run.sh` 를 만들고 첫 줄에 `#!/bin/bash` 를 쓴다", "`chmod +x run.sh` 로 실행 권한을 준다", "`./run.sh` 로 실행한다", "`echo $?` 로 성공(0)했는지 확인한다"]', NULL, '권한을 주기 전에 실행하면 Permission denied 가 납니다. 스크립트는 작게 만들어 자주 실행해 보는 것이 가장 빠른 학습법이에요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 27, '서비스가 안 뜰 때 점검', '서비스가 떠 있지 않을 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → 로그 → 고치기 → 다시 시작 순서예요.', NULL, NULL, '[]', 'order', '["`systemctl status 서비스` 로 상태와 마지막 로그를 본다", "`journalctl -u 서비스` 로 실패 이유를 자세히 본다", "설정 파일의 오류를 고친다", "`systemctl restart 서비스` 로 다시 시작하고 `status` 로 확인한다"]', NULL, '고치기 전에 이유부터 확인하는 것이 핵심입니다. 이유를 모른 채 재시작만 반복하면 같은 실패가 계속돼요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 28, '폴더를 압축해 백업하기', '폴더를 압축해 백업 파일로 만들고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 크기 → 내용 → 복원 시험 순서예요.', NULL, NULL, '[]', 'order', '["`tar -czf data.tar.gz data` 로 압축 파일을 만든다", "`ls -lh data.tar.gz` 로 파일이 생기고 크기가 정상인지 본다", "`tar -tzf data.tar.gz` 로 안에 든 파일을 확인한다", "다른 폴더에 풀어 보며 복원이 되는지 시험한다"]', NULL, '백업은 풀어 봐야 믿을 수 있습니다. 만들기만 하고 복원 시험을 안 한 백업은 필요할 때 쓸모없는 경우가 많아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 29, '압축 파일 안전하게 풀기', '받은 압축 파일을 안전하게 푸는 순서입니다. 순서에 맞게 놓아 보세요.', '내용 확인 → 폴더 만들기 → 풀기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`tar -tzf pkg.tar.gz` 로 안에 든 파일 목록을 본다", "`mkdir -p /tmp/pkg` 로 풀 폴더를 만든다", "`tar -xzf pkg.tar.gz -C /tmp/pkg` 로 그 폴더에 푼다", "`ls /tmp/pkg` 로 풀린 결과를 확인한다"]', NULL, '현재 폴더에 바로 풀면 파일이 흩어지거나 기존 파일을 덮어쓸 수 있습니다. 빈 폴더에 푸는 습관이 안전해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 29);
