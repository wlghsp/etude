-- 리눅스 세트 150. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set150.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 150, '와일드카드, 따옴표, 명령 연결, 텍스트 도구 한 줄씩', '쉘의 기본 문법과 텍스트 도구를 한 개념씩 반복합니다. *·?·[ ] 와일드카드와 일치하는 파일이 없을 때의 동작, 중괄호 확장, 작은따옴표와 큰따옴표의 차이, $( ) 명령 치환, 따옴표 없는 공백과 공백이 든 파일 이름, ;·&&·|| 의 차이, cut -d -f, tr, sort -u, xargs, diff 읽기를 짧은 객관식·빈칸·순서 문제로 익히고, 코드별 개수 세기, 와일드카드로 안전하게 지우기, 설정 파일 비교, 공백 이름 문제 풀기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 150);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🔤' WHERE id = 150;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 1, '별표(*) 와일드카드', '`ls *.txt` 에서 `*` 는 무엇을 뜻할까요?', '"아무거나"를 뜻하는 특수 문자예요.', NULL, NULL, '[]', 'choice', '["글자가 정확히 한 개 온다", "별표 글자 자체를 찾는다", "아무 글자가 몇 개든 올 수 있다 (쉘이 `.txt` 로 끝나는 파일 이름들로 펼쳐 준다)", "숫자만 찾는다"]', 2, '`*` 를 펼치는 것은 `ls` 가 아니라 쉘입니다. 그래서 어떤 명령에서든 같은 방식으로 동작해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 2, '물음표(?) 와일드카드', '`ls a?.txt` 가 찾는 파일로 알맞은 것은 무엇일까요?', '`?` 는 글자 하나만 대신해요.', NULL, NULL, '[]', 'choice', '["`a.txt` 만", "`a1.txt`, `a2.txt` 처럼 a 와 .txt 사이에 글자가 정확히 한 개 있는 파일", "`a12345.txt` 처럼 글자가 여러 개인 파일", "이름에 물음표가 들어 있는 파일"]', 1, '`a.txt` 는 글자가 0개라 맞지 않고 `a12.txt` 는 2개라 맞지 않습니다. 개수에 상관없다면 `*` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 3, '대괄호 [ ]', '`ls [ab]1.txt` 와 `ls a[0-9].txt` 에서 대괄호는 무엇을 뜻할까요?', '괄호 안의 글자 중 하나예요.', NULL, NULL, '[]', 'choice', '["괄호 안의 글자(또는 범위) 중 하나와 일치한다", "괄호 안의 글자를 모두 순서대로 찾는다", "괄호 안의 글자를 제외한다", "괄호 자체를 찾는다"]', 0, '`[ab]` 는 a 또는 b, `[0-9]` 는 숫자 하나입니다. 파일 이름의 특정 자리를 정확히 고르고 싶을 때 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 4, '중괄호 확장', '`touch file{1,2,3}.txt` 를 실행하면 어떻게 될까요?', '쉘이 이름을 만들어 줘요. 파일이 이미 있어야 하는 것이 아니에요.', NULL, NULL, '[]', 'choice', '["`file{1,2,3}.txt` 라는 이름의 파일 하나가 만들어진다", "이미 있는 파일만 건드린다", "오류가 난다", "쉘이 `file1.txt file2.txt file3.txt` 로 펼쳐서 세 파일을 만든다"]', 3, '중괄호 확장은 파일이 있는지와 상관없이 이름을 만들어 냅니다. `{a,b}{1,2}` 는 `a1 a2 b1 b2` 가 되어 조합을 쉽게 만들어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 5, '일치하는 파일이 없을 때', '현재 폴더에 `.zzz` 파일이 없을 때 `echo *.zzz` 를 실행하면 무엇이 출력될까요?', '쉘이 펼칠 파일이 없으면 어떻게 할지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["아무것도 출력되지 않는다", "현재 폴더의 모든 파일 이름", "`*.zzz` 가 글자 그대로 출력된다", "오류 메시지만 나온다"]', 2, '그래서 `rm *.zzz` 는 `*.zzz` 라는 이름을 지우려다 "No such file" 오류를 냅니다. 파일이 있는지 먼저 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 6, '작은따옴표와 큰따옴표', 'N=etude 일 때 `echo ''$N''` 와 `echo "$N"` 의 결과는 각각 무엇일까요?', '하나는 글자 그대로, 하나는 값으로 바뀌어요.', NULL, NULL, '[]', 'choice', '["둘 다 `etude`", "`$N`(그대로) 과 `etude`(값으로 치환)", "둘 다 `$N`", "`etude` 와 `$N`"]', 1, '작은따옴표는 안의 내용을 그대로, 큰따옴표는 `$변수` 와 `$( )` 를 치환합니다. 변수를 쓰려면 큰따옴표를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 7, '$( ) 명령 치환', '`echo "오늘은 $(date +%F)"` 에서 `$(date +%F)` 는 어떻게 처리될까요?', '명령을 실행한 결과로 바꿔요.', NULL, NULL, '[]', 'choice', '["`date +%F` 를 실행한 결과(오늘 날짜)로 바뀐다", "글자 그대로 출력된다", "`date` 라는 변수의 값으로 바뀐다", "오류가 난다"]', 0, '`$(명령)` 은 명령의 출력으로 대체됩니다. 백업 파일 이름에 날짜를 붙일 때 `backup-$(date +%F).tar.gz` 처럼 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 8, '따옴표 없는 공백', '`echo a    b` (a 와 b 사이 공백 네 칸) 의 출력은 무엇일까요?', '쉘은 공백을 기준으로 인자를 나눠요.', NULL, NULL, '[]', 'choice', '["`a    b` (공백 그대로)", "`ab`", "오류가 난다", "`a b` (공백이 한 칸으로 줄어든다. 쉘이 a 와 b 를 두 인자로 나눴기 때문)"]', 3, '공백을 그대로 쓰려면 `echo "a    b"` 처럼 큰따옴표로 감쌉니다. 이 원리가 파일 이름의 공백 문제와 이어져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 9, '공백이 든 파일 이름', '`my file.txt` 라는 파일을 `ls my file.txt` 로 보려 하면 어떻게 될까요?', '쉘이 공백으로 둘로 나눠요.', NULL, NULL, '[]', 'choice', '["정상적으로 파일이 보인다", "파일이 삭제된다", "`my` 와 `file.txt` 두 개의 이름으로 쪼개져 \\"No such file\\" 오류가 난다. `ls \\"my file.txt\\"` 처럼 따옴표로 묶어야 한다", "`my file.txt` 가 자동으로 따옴표로 감싸진다"]', 2, '공백이 든 이름은 따옴표로 묶거나 `my\\ file.txt` 처럼 공백 앞에 역슬래시를 씁니다. 공백이 없는 이름을 쓰는 습관도 좋아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 10, '; 와 && 의 차이', '`mkdir out ; cd out` 과 `mkdir out && cd out` 의 차이로 알맞은 것은 무엇일까요?', '앞 명령이 실패했을 때를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`;` 는 앞이 실패해도 뒤를 실행하고, `&&` 는 앞이 성공했을 때만 뒤를 실행한다", "`;` 는 앞이 성공했을 때만, `&&` 는 항상 실행한다", "`&&` 는 두 명령을 동시에 실행한다"]', 1, 'mkdir 이 실패했는데 `cd out` 이 실행되면 엉뚱한 폴더에서 다음 명령이 실행될 수 있습니다. 순서가 중요하면 `&&` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 11, '|| 의 쓰임', '`grep ERROR app.log || echo "없음"` 에서 `||` 의 뒤 명령은 언제 실행될까요?', '"또는"처럼, 앞이 안 되면 뒤를 해요.', NULL, NULL, '[]', 'choice', '["앞 명령이 실패했을 때(여기서는 ERROR 가 한 줄도 없을 때)만 실행된다", "항상 실행된다", "앞 명령이 성공했을 때만 실행된다", "절대 실행되지 않는다"]', 0, '`grep` 은 찾는 것이 없으면 실패(종료 코드 1)로 끝납니다. 이를 이용해 "없으면 알림" 같은 흐름을 만들 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 12, 'cut -d -f', '`cut -d, -f2 p.csv` 는 무엇을 출력할까요?', '-d 는 구분 문자, -f 는 몇 번째 칸이에요.', NULL, NULL, '[]', 'choice', '["각 줄의 두 번째 글자", "각 줄의 쉼표 개수", "파일의 두 번째 줄", "쉼표(,)로 나눈 각 줄의 두 번째 칸"]', 3, '`-d` 로 구분 문자를, `-f` 로 칸 번호를 정합니다. `-f1,3` 처럼 여러 칸을 뽑을 수도 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 13, 'sort -u', '`sort -u p.csv` 는 `sort p.csv | uniq` 와 같은 결과를 줄까요?', 'u 는 unique 예요.', NULL, NULL, '[]', 'choice', '["다르다. `-u` 는 정렬하지 않는다", "다르다. `-u` 는 중복된 줄만 보여 준다", "같다. 정렬하면서 중복된 줄을 하나만 남긴다", "다르다. `-u` 는 파일을 수정한다"]', 2, '`uniq` 는 이웃한 줄만 합치므로 먼저 정렬해야 하는데, `sort -u` 가 두 단계를 한 번에 해 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 14, 'diff 읽기', '`diff old.txt new.txt` 의 출력에서 `<` 와 `>` 로 시작하는 줄은 각각 무엇일까요?', '화살표가 가리키는 방향의 파일 내용이에요.', NULL, NULL, '[]', 'choice', '["`<` 는 삭제 예정, `>` 는 추가 예정이다", "`<` 는 첫 번째 파일(old)의 줄, `>` 는 두 번째 파일(new)의 줄", "둘 다 같은 파일의 줄이다", "`<` 는 오류, `>` 는 경고이다"]', 1, '두 파일이 같으면 아무것도 출력하지 않고 종료 코드 0, 다르면 종료 코드 1 입니다. 보기 좋게 보려면 `diff -u` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 15, '모든 txt 파일', '현재 폴더의 **모든 `.txt` 파일**을 가리키는 와일드카드를 채우세요.', '"아무거나"를 뜻하는 별 모양이에요.', NULL, NULL, '[]', 'fill', '["*", "?", "%", "#"]', NULL, '`?` 는 글자 한 개만 대신합니다. 몇 개든 상관없을 때는 `*` 예요.', '[0]', 'ls {0}.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 16, '여러 이름 한 번에 만들기', '`file1.txt`, `file2.txt`, `file3.txt` 를 **한 번에 만드는** 표현을 채우세요.', '중괄호 안에 쉼표로 나열해요.', NULL, NULL, '[]', 'fill', '["{1,2,3}", "[1,2,3]", "(1,2,3)", "<1,2,3>"]', NULL, '대괄호는 이미 있는 파일 이름을 고를 때 쓰고, 중괄호는 이름을 만들어 낼 때 씁니다.', '[0]', 'touch file{0}.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 17, '변수 값 쓰기', '큰따옴표 안에서 변수 `HOME` 의 **값을 꺼내는** 기호를 채우세요.', '변수 앞에 붙는 기호예요.', NULL, NULL, '[]', 'fill', '["$", "#", "%", "&"]', NULL, '큰따옴표 안에서는 `$HOME` 이 값으로 바뀌고, 작은따옴표 안에서는 글자 그대로 남습니다.', '[0]', 'echo "{0}HOME"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 18, '명령 결과 끼워 넣기', '문장 안에 **명령의 결과**를 끼워 넣는 기호를 채우세요.', '괄호 앞에 붙는 기호예요.', NULL, NULL, '[]', 'fill', '["$", "#", "@", "!"]', NULL, '`$(명령)` 은 명령을 실행한 결과로 바뀝니다. 작은따옴표로 감싸면 치환되지 않아요.', '[0]', 'echo "today: {0}(date +%F)"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 19, '공백이 든 이름 감싸기', '공백이 든 파일 `my file.txt` 를 **한 이름으로** 전달하는 올바른 모양을 채우세요.', '이름 전체를 따옴표로 감싸요.', NULL, NULL, '[]', 'fill', '["\\"my file.txt\\"", "my file.txt", "''my'' ''file.txt''", "(my file.txt)"]', NULL, '따옴표 없이 쓰면 쉘이 두 인자로 나눕니다. 스크립트에서는 변수도 `"$f"` 처럼 따옴표로 감싸는 습관이 필요해요.', '[0]', 'ls {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 20, '성공했을 때만 이어서', '`mkdir out` 이 **성공했을 때만** `cd out` 을 하려고 합니다. 연결 기호를 채우세요.', '"그리고"처럼 앞이 성공해야 뒤가 실행돼요.', NULL, NULL, '[]', 'fill', '["&&", ";", "||", "|"]', NULL, '`;` 는 앞의 성공 여부와 상관없이 다음 명령을 실행합니다. 안전하게 이어 가려면 `&&` 예요.', '[0]', 'mkdir out {0} cd out', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 21, '실패했을 때만 이어서', '`grep` 이 **실패했을 때만(찾는 줄이 없을 때)** 메시지를 출력하려고 합니다. 연결 기호를 채우세요.', '"또는"처럼 앞이 안 되면 뒤를 해요.', NULL, NULL, '[]', 'fill', '["||", "&&", ";", "|"]', NULL, '`&&` 를 쓰면 ERROR 가 있을 때만 메시지가 나옵니다. 의도와 정반대가 되니 주의하세요.', '[0]', 'grep ERROR app.log {0} echo "없음"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 22, '구분 문자 정하기', '쉼표로 나뉜 CSV 에서 두 번째 칸을 뽑으려고 합니다. **구분 문자**를 정하는 옵션을 채우세요.', 'delimiter 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-d", "-c", "-s", "-t"]', NULL, '`-c` 는 글자 위치로 자릅니다. 구분 문자로 자르려면 `-d` 를 쓰세요.', '[0]', 'cut {0} , -f2 p.csv', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 23, '대문자로 바꾸기', '입력의 **소문자를 대문자로** 바꾸는 `tr` 의 두 번째 인자를 채우세요.', '소문자 범위를 대문자 범위로 바꿔요.', NULL, NULL, '[]', 'fill', '["A-Z", "a-z", "UPPER", "^"]', NULL, '`tr` 은 글자를 하나씩 바꿉니다. `tr -d` 로 글자를 지우고, `tr -s` 로 반복된 글자를 줄일 수 있어요.', '[0]', 'echo hello | tr a-z {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 24, '결과를 다른 명령의 인자로', '`find` 로 찾은 파일 목록을 **`rm` 의 인자로 넘기는** 명령을 채우세요.', '표준 입력을 인자로 바꿔 주는 명령이에요.', NULL, NULL, '[]', 'fill', '["xargs", "exec", "args", "each"]', NULL, '파일 이름에 공백이 있으면 깨지므로 `find ... -print0 | xargs -0 rm` 처럼 널 문자로 구분하는 방식이 안전합니다.', '[0]', 'find . -name "*.log" | {0} rm', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 25, '보기 좋은 diff', '두 파일의 차이를 `-` 와 `+` 로 **통합해서 보여 주는** 옵션을 채우세요.', 'unified 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-u", "-r", "-q", "-i"]', NULL, '`-q` 는 다른지 여부만, `-r` 은 폴더를 재귀로 비교합니다. 코드 리뷰에서 흔히 보는 모양이 `-u` 예요.', '[0]', 'diff {0} old.txt new.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 26, '로그에서 코드별 개수 세기', '로그의 3번째 칸(코드)별로 ERROR 줄 개수를 세는 명령입니다. 순서에 맞게 놓아 보세요.', '찾기 → 칸 뽑기 → 정렬 → 세기 순서예요.', NULL, NULL, '[]', 'order', '["`grep ERROR app.log`", "`cut -d\\" \\" -f3`", "`sort`", "`uniq -c`"]', NULL, '`uniq` 는 이웃한 줄만 합치므로 반드시 `sort` 뒤에 둬야 합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 27, '여러 파일 안전하게 지우기', '`.tmp` 파일들을 와일드카드로 지우기 전에 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '목록 → 개수 → 삭제 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`ls *.tmp` 로 지워질 파일 목록을 본다", "`ls *.tmp | wc -l` 로 개수가 예상과 맞는지 본다", "`rm *.tmp` 로 삭제한다", "`ls *.tmp` 를 다시 실행해 \\"No such file\\" 이 나오는지 확인한다"]', NULL, '와일드카드로 지우는 명령은 되돌릴 수 없습니다. 같은 패턴으로 `ls` 를 먼저 해 보는 것이 가장 쉬운 안전장치예요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 28, '두 설정 파일 비교하고 반영하기', '새 설정 파일을 비교한 뒤 반영하는 순서입니다. 순서에 맞게 놓아 보세요.', '비교 → 읽기 → 판단 → 백업 후 반영 순서예요.', NULL, NULL, '[]', 'order', '["`diff -u old.conf new.conf` 로 차이를 본다", "`-` 줄(지워질 것)과 `+` 줄(추가될 것)을 읽는다", "의도한 변경만 있는지 판단한다", "`cp old.conf old.conf.bak` 으로 백업한 뒤 새 파일을 반영한다"]', NULL, '의도하지 않은 변경(공백, 권한, 다른 서버 값)이 섞여 있지 않은지 읽어 보세요. 반영 전 백업은 필수입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 29, '공백 든 이름 문제 풀기', '`ls my file.txt` 가 오류일 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '오류 읽기 → 원인 → 고치기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["\\"cannot access ''my''\\" 오류 메시지를 읽는다", "공백 때문에 이름이 `my` 와 `file.txt` 로 쪼개졌다는 것을 파악한다", "`ls \\"my file.txt\\"` 처럼 따옴표로 묶어 다시 실행한다", "파일이 정상으로 보이는지 확인한다"]', NULL, '오류 메시지에 나온 이름 조각이 단서입니다. 쪼개진 이름이 보이면 따옴표를 의심하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 29);
