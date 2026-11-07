-- 리눅스 세트 210. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set210.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 210, '내용 비교와 신호·시간: diff -r·-q·-u, cmp, cat -A, fold, tr -s, kill -l·-0, 종료 코드 128+n, timeout', '파일 내용을 비교하고 숨은 문자를 보고, 신호와 시간 제한을 다루는 기본 동작을 한 개념씩 반복합니다. diff 의 종료 코드 0·1·2 와 기본 출력의 1c1·<·> 읽기, -q 요약, -r 폴더 비교와 Only in, -u 통합 형식, 프로세스 치환 비교, cmp 의 처음 다른 위치와 -s, cat -A 의 ^I·$·^M 와 -s 빈 줄 압축, fold 의 -w 와 -s, tr 의 -s 와 -d, kill -l 로 신호 이름과 번호 바꾸기, kill -0 으로 생존 확인, 신호로 끝난 프로세스의 종료 코드 128 더하기 신호 번호, timeout 의 124 와 -s KILL 의 137 을 짧은 객관식·빈칸·순서 문제로 익히고, 두 파일 비교하기, 두 폴더 비교하기, 윈도식 줄바꿈 정리, 시간 제한과 종료 코드 확인의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 210);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '⏱️' WHERE id = 210;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 1, 'diff 의 종료 코드', '`diff a b` 의 종료 코드는 두 파일이 같을 때, 다를 때, 파일이 없어 오류가 났을 때 각각 얼마일까요?', '같으면 0 이에요.', NULL, NULL, '[]', 'choice', '["같으면 1, 다르면 0, 오류면 2 이다", "같으면 0, 다르거나 오류면 모두 1 이다", "같으면 0, 다르면 1, 오류(예: 없는 파일)가 나면 2 이다. 그래서 스크립트에서 `if diff -q a b` 처럼 쓸 수 있다", "항상 0 이고 출력으로만 구분한다"]', 2, '`cmp` 도 같으면 0, 다르면 1 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 2, 'diff 기본 출력 읽기', '`diff a1 a3` 가 `1c1`, `< hello`, `---`, `> hellp` 를 출력했습니다. 무슨 뜻일까요?', '`<` 는 앞의 파일, `>` 는 뒤의 파일이에요.', NULL, NULL, '[]', 'choice', '["`a3` 의 내용이 `<` 줄이고 `a1` 의 내용이 `>` 줄이다", "첫 번째 파일의 1번째 줄이 두 번째 파일의 1번째 줄로 바뀌었다(`c` = change)는 뜻이다. `<` 줄은 `a1` 의 내용, `>` 줄은 `a3` 의 내용이다", "`1c1` 은 1번째 파일과 1번째 폴더가 같다는 뜻이다", "`hellp` 는 오류 메시지이다"]', 1, '`diff -u` 는 같은 내용을 `@@`, `-`, `+` 표시로 보여 주는 통합 형식입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 3, 'diff -q', '`diff -q a1 a3` 는 무엇을 출력할까요? 같은 파일이면요?', '내용 차이는 숨기고 결과만 알려요.', NULL, NULL, '[]', 'choice', '["다르면 `Files a1 and a3 differ` 한 줄만 출력하고 내용 차이는 보여 주지 않는다. 같은 파일이면 아무것도 출력하지 않는다", "다른 줄의 내용을 모두 출력한다", "같은 파일이어도 `identical` 이라고 출력한다", "다르면 종료 코드 0 으로 끝난다"]', 0, '파일이 같은지만 알고 싶을 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 4, 'diff -r 로 폴더 비교', '`diff -r d1 d2` 는 두 폴더를 어떻게 비교할까요? `diff -rq d1 d2` 는요?', '-r 은 하위까지 재귀적으로 봐요.', NULL, NULL, '[]', 'choice', '["폴더 이름만 비교하고 파일 내용은 보지 않는다", "`-r` 은 한쪽에만 있는 파일을 무시한다", "`-rq` 는 같은 파일의 목록만 보여 준다", "하위 파일까지 비교해 한쪽에만 있는 파일은 `Only in d1: only1` 처럼, 양쪽에 있고 내용이 다른 파일은 그 파일의 차이를 보여 준다. `-q` 를 붙이면 내용 차이 대신 `Files d1/y and d2/y differ` 로 요약한다"]', 3, '다르면 종료 코드 1 이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 5, '프로세스 치환으로 비교', '파일을 만들지 않고 `diff <(printf ''1\\n2\\n'') <(printf ''1\\n3\\n'')` 처럼 쓰면 무엇을 비교할까요?', '`<( )` 는 명령 출력을 파일처럼 만들어요.', NULL, NULL, '[]', 'choice', '["`<` 는 입력 리다이렉션이라 `diff` 가 두 명령의 이름을 비교한다", "`<( )` 는 bash 에서 오류가 난다", "두 명령의 출력을 각각 임시 파일처럼 만들어 비교한다. 결과는 `2c2`, `< 2`, `> 3` 처럼 나온다", "첫 번째 명령만 실행하고 두 번째는 무시한다"]', 2, '정렬한 결과를 비교하려면 `diff <(sort a) <(sort b)` 처럼 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 6, 'cmp 의 출력', '`cmp a1 a3`(`hello` 와 `hellp`) 는 무엇을 출력할까요? `cmp -s` 는요?', '바이트 단위로 처음 다른 곳을 알려 줘요.', NULL, NULL, '[]', 'choice', '["다른 줄 전체를 출력한다", "`a1 a3 differ: char 5, line 1` 처럼 처음 달라지는 바이트 위치를 알려 준다. `-s` 는 아무것도 출력하지 않고 종료 코드(같으면 0, 다르면 1)로만 알려 준다", "`-s` 는 파일 크기를 출력한다", "같은 파일일 때만 위치를 출력한다"]', 1, '`cmp -l` 은 다른 바이트마다 위치와 값(8진수)을 한 줄씩 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 7, 'cat -A 로 숨은 문자 보기', '`cat -A` 로 파일을 보면 탭, 줄 끝, 윈도 줄바꿈은 각각 어떻게 표시될까요?', '눈에 안 보이는 문자를 기호로 바꿔요.', NULL, NULL, '[]', 'choice', '["탭은 `^I`, 줄 끝은 `$`, 윈도식 줄바꿈의 캐리지 리턴은 `^M` 으로 표시된다. 그래서 줄 끝 공백이나 `^M$` 를 찾을 수 있다", "탭은 `$`, 줄 끝은 `^I`, 캐리지 리턴은 `^M` 으로 표시된다", "공백과 탭이 모두 점(`.`)으로 표시된다", "`-A` 는 모든 줄 앞에 번호를 붙인다"]', 0, '`-E` 는 줄 끝 `$` 만, `-T` 는 탭 `^I` 만 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 8, 'cat -s', '`x`, 빈 줄 세 개, `y` 로 된 파일에 `cat -s` 를 쓰면 몇 줄이 나올까요?', '연속된 빈 줄을 줄여요.', NULL, NULL, '[]', 'choice', '["5줄이 나온다", "빈 줄이 모두 사라져 2줄이 나온다", "`-s` 는 파일 크기를 출력해 한 줄이 나온다", "연속된 빈 줄이 하나로 합쳐져 3줄(`x`, 빈 줄, `y`)이 나온다"]', 3, '`-s` 는 squeeze(압축)의 머리글자입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 9, 'fold 로 줄 나누기', '`echo "the quick brown fox jumps" | fold -w 10` 과 `fold -s -w 10` 은 어떻게 다를까요?', '-s 는 공백에서 끊어요.', NULL, NULL, '[]', 'choice', '["둘 다 공백에서만 줄을 나눈다", "`-s` 는 줄 수를 세어 출력한다", "`fold -w 10` 은 10글자마다 무조건 줄을 나눠 단어가 중간에서 잘릴 수 있고, `-s` 를 붙이면 가능하면 공백에서 줄을 나눠 단어를 지킨다", "`-w 10` 은 10줄만 출력한다"]', 2, '긴 한 줄을 화면 너비에 맞춰 볼 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 10, 'tr 의 -s 와 -d', '`echo "aaabbb  c" | tr -s ''ab ''` 와 `echo hello | tr -d l` 은 각각 무엇을 출력할까요?', '-s 는 연속 압축, -d 는 삭제예요.', NULL, NULL, '[]', 'choice', '["앞은 `aaabbb c` 이다", "앞은 `ab c` 로, 지정한 문자 `a`, `b`, 공백이 연속된 곳을 하나로 줄이고, 뒤는 `heo` 로 `l` 을 모두 삭제한다", "뒤는 `hello` 그대로이다", "`-s` 는 문자를 대문자로 바꾼다"]', 1, '`tr -d ''\\r''` 로 윈도식 줄바꿈의 캐리지 리턴을 지울 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 11, 'kill -l', '`kill -l` 과 `kill -l 9`, `kill -l TERM` 은 각각 무엇을 보여 줄까요?', '신호 이름과 번호를 서로 바꿔 줘요.', NULL, NULL, '[]', 'choice', '["`kill -l` 은 신호 이름과 번호 목록을, `kill -l 9` 는 `KILL`, `kill -l TERM` 은 `15` 를 출력한다. 번호와 이름을 서로 바꿔 알려 준다", "`kill -l` 은 실행 중인 프로세스 목록을 보여 준다", "`kill -l 9` 는 PID 9 인 프로세스를 종료한다", "`kill -l TERM` 은 `TERM` 신호를 보낸다"]', 0, '`kill -s HUP PID` 처럼 이름으로 신호를 보낼 수도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 12, 'kill -0', '`kill -0 PID` 는 무엇을 할까요? 없는 PID 에 쓰면요?', '신호를 실제로 보내지는 않아요.', NULL, NULL, '[]', 'choice', '["프로세스를 종료한다", "프로세스를 일시 중지한다", "없는 PID 여도 종료 코드는 0 이다", "프로세스에 신호를 보내지 않고 그 PID 가 존재하는지(보낼 수 있는지)만 확인한다. 있으면 종료 코드 0, 없는 PID 면 `No such process` 오류와 종료 코드 1 이다"]', 3, '스크립트에서 `kill -0 $PID && echo alive` 처럼 생존 확인에 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 13, '신호로 끝난 프로세스의 종료 코드', '백그라운드 `sleep` 을 `kill`(기본 TERM), `kill -9`, `kill -s HUP`, `kill -SIGINT` 로 각각 끝내고 `wait` 로 종료 코드를 보면 얼마일까요?', '신호로 끝나면 128 에 신호 번호를 더해요.', NULL, NULL, '[]', 'choice', '["모두 0 이다", "모두 1 이다", "각각 143, 137, 129, 130 이다. 신호로 끝난 프로세스의 종료 코드는 128 + 신호 번호(TERM 15, KILL 9, HUP 1, INT 2)이다", "신호 번호와 같은 15, 9, 1, 2 이다"]', 2, '컨테이너가 137 로 끝났다면 SIGKILL 을 받았다는 뜻입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 14, 'timeout 의 종료 코드', '`timeout 1 sleep 5`, `timeout 5 false`, `timeout -s KILL 1 sleep 5` 의 종료 코드는 각각 얼마일까요?', '시간이 초과되면 특별한 코드가 나와요.', NULL, NULL, '[]', 'choice', '["모두 0 이다", "각각 124(시간 초과), 1(명령이 제때 끝나 그 명령의 종료 코드가 그대로), 137(KILL 신호로 끝나 128 + 9) 이다", "모두 124 이다", "`timeout 5 false` 는 시간 안에 끝났으므로 0 이다"]', 1, '제때 끝난 명령은 그 명령의 종료 코드를 그대로 돌려줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 15, '파일이 다른지만 확인', '`diff` 가 **다른지 여부만** 한 줄로 알려 주게 하는 옵션을 채우세요.', '"quiet"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-q", "-s", "-b", "-e"]', NULL, '같은 파일이면 아무것도 출력하지 않습니다.', '[0]', 'diff {0} a1 a3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 16, '폴더 안까지 비교', '`diff` 가 **하위 폴더와 파일까지 재귀적으로 비교하게** 하는 옵션을 채우세요.', '"recursive"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-r", "-d", "-a", "-f"]', NULL, '`-q` 와 함께 쓰면 요약만 보입니다.', '[0]', 'diff {0} d1 d2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 17, '통합 형식으로 보기', '`diff` 의 결과를 **`@@`, `-`, `+` 로 보여 주는 통합 형식**으로 바꾸는 옵션을 채우세요.', '"unified"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-u", "-y", "-c", "-q"]', NULL, '코드 리뷰에서 흔히 보는 형식입니다.', '[0]', 'diff {0} a1 a3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 18, 'cmp 조용히', '`cmp` 가 **출력 없이 종료 코드로만** 알려 주게 하는 옵션을 채우세요.', '"silent"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-q", "-n", "-x"]', NULL, '같으면 0, 다르면 1 입니다.', '[0]', 'cmp {0} a1 a3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 19, '숨은 문자 보기', '탭 `^I`, 줄 끝 `$`, `^M` 같은 **숨은 문자를 모두 보여 주는** `cat` 옵션을 채우세요.', '"all"의 머리글자이고 대문자예요.', NULL, NULL, '[]', 'fill', '["-A", "-a", "-n", "-b"]', NULL, '`-E` 는 줄 끝만 보여 줍니다.', '[0]', 'cat {0} file', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 20, '빈 줄 줄이기', '연속된 **빈 줄을 하나로 줄이는** `cat` 옵션을 채우세요.', '"squeeze"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-b", "-n", "-v"]', NULL, '빈 줄이 없어지는 것이 아니라 하나만 남습니다.', '[0]', 'cat {0} file', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 21, '너비로 줄 나누기', '`fold` 에서 **한 줄의 너비를 정하는** 옵션을 채우세요.', '"width"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-w", "-n", "-c", "-l"]', NULL, '기본은 80 글자입니다.', '[0]', 'fold {0} 5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 22, '공백에서 끊기', '`fold` 가 가능하면 **공백에서 줄을 나누게** 하는 옵션을 채우세요.', '"space"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-b", "-x", "-t"]', NULL, '단어가 중간에서 잘리는 것을 줄입니다.', '[0]', 'fold {0} -w 10', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 23, '연속 문자 압축', '`tr` 에서 **같은 문자가 연속되면 하나로 줄이는** 옵션을 채우세요.', '"squeeze"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-d", "-c", "-t"]', NULL, '`-d` 는 지정한 문자를 삭제합니다.', '[0]', 'tr {0} '' ''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 24, '신호 이름 목록', '`kill` 이 **신호 이름과 번호 목록을 보여 주게** 하는 옵션을 채우세요.', '"list"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-l", "-t", "-n", "-a"]', NULL, '`kill -l 9` 는 `KILL` 을 출력합니다.', '[0]', 'kill {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 25, '시간 제한 명령', '명령을 **정해진 시간이 지나면 끝내는** 명령을 채우세요.', '"시간 초과"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["timeout", "limit", "deadline", "expire"]', NULL, '시간이 초과되면 종료 코드 124 입니다.', '[0]', '{0} 3 sleep 10', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 26, '두 파일 비교하기', '두 파일이 어떻게 다른지 단계적으로 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '다른지 확인 → 위치 확인 → 줄 차이 → 통합 형식 순서예요.', NULL, NULL, '[]', 'order', '["`cmp -s a1 a3; echo $?` 로 종료 코드 1 이 나와 다른 파일임을 확인한다", "`cmp a1 a3` 로 처음 달라지는 위치(`char 5, line 1`)를 확인한다", "`diff a1 a3` 로 어느 줄이 어떻게 바뀌었는지(`1c1`) 본다", "`diff -u a1 a3` 로 통합 형식의 `-`, `+` 줄로 다시 확인한다"]', NULL, '같은 파일이면 `cmp` 와 `diff` 모두 종료 코드 0 입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 27, '두 폴더 비교하기', '두 폴더의 차이를 요약에서 상세로 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '요약 → 한쪽에만 있는 파일 → 내용 차이 → 종료 코드 순서예요.', NULL, NULL, '[]', 'order', '["`diff -rq d1 d2` 로 차이가 있는 항목을 요약해서 본다", "`Only in d1: only1` 처럼 한쪽에만 있는 파일을 찾는다", "`diff -r d1 d2` 로 양쪽에 있는 파일의 내용 차이를 본다", "`echo $?` 로 종료 코드가 1 인지 확인한다"]', NULL, '차이가 없으면 종료 코드 0 입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 28, '윈도식 줄바꿈 정리', '파일의 윈도식 줄바꿈을 찾아 지우는 순서입니다. 순서에 맞게 놓아 보세요.', '눈으로 확인 → 지우기 → 다시 확인 → 마무리 순서예요.', NULL, NULL, '[]', 'order', '["`cat -A w.txt` 로 줄 끝에 `^M$` 가 있는지 확인한다", "`tr -d ''\\\\r'' < w.txt > fixed.txt` 로 캐리지 리턴을 지운 파일을 만든다", "`cat -A fixed.txt` 로 `^M` 이 없어지고 `$` 만 남았는지 확인한다", "`cmp -s w.txt fixed.txt` 가 종료 코드 1 이어서 두 파일이 달라졌음을 확인한다"]', NULL, '`cat -A` 의 `$` 는 줄 끝을 뜻합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 29, '시간 제한과 종료 코드', '`timeout` 으로 명령을 제한하고 종료 코드를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '초과 → 정상 → 신호 지정 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`timeout 1 sleep 5; echo $?` 로 시간 초과 시 종료 코드가 124 인지 본다", "`timeout 5 true; echo $?` 로 제때 끝나면 명령의 종료 코드 0 이 나오는지 본다", "`timeout -s KILL 1 sleep 5; echo $?` 로 KILL 신호를 지정해 종료 코드 137 을 본다", "128 + 신호 번호(9)로 137 이 된다는 계산을 확인한다"]', NULL, '`timeout 5 false` 는 명령의 종료 코드인 1 이 그대로 나옵니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 29);
