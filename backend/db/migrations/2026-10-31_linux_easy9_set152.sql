-- 리눅스 세트 152. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set152.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 152, '쉘 스크립트 조건, 반복, 함수, 백그라운드 한 줄씩', '쉘 스크립트의 제어 구조를 한 개념씩 쉬운 문제로 반복합니다. [ ] 검사(-f·-d·-z·-n), 숫자(-gt)와 문자열(=) 비교의 차이, 대괄호 사이 공백과 빈 변수 따옴표 오류, if·fi, for 와 와일드카드, 무한 반복 막기, continue·break, $(( )) 정수 산술, 함수의 return·local, $#·$@·$0·shift, case, &·$!·wait 를 짧은 객관식·빈칸·순서 문제로 익히고, 파일 검사 스크립트, 로그 압축 반복문, 백그라운드 작업 다루기, 대괄호 오류 풀기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 152);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🧾' WHERE id = 152;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 1, '파일 검사 -f 와 -d', '`if [ -f f.txt ]` 와 `if [ -d d ]` 의 `-f` 와 `-d` 는 각각 무엇을 검사할까요?', 'file 과 directory 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["`-f` 는 폴더, `-d` 는 일반 파일", "둘 다 파일 크기를 검사한다", "`-f` 는 일반 파일이 있는지, `-d` 는 폴더가 있는지", "`-f` 는 읽기 권한, `-d` 는 쓰기 권한"]', 2, '`-f` 는 폴더에 대해서는 거짓입니다. 이름이 있는지만 보려면 `-e` 를 쓸 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 2, '-z 와 -n', '`[ -z "$x" ]` 와 `[ -n "$x" ]` 는 각각 언제 참일까요?', 'z 는 zero(길이 0), n 은 non-zero 예요.', NULL, NULL, '[]', 'choice', '["`-z` 는 숫자일 때, `-n` 은 문자일 때", "`-z` 는 문자열이 비어 있을 때, `-n` 은 비어 있지 않을 때", "둘 다 비어 있을 때 참이다", "`-z` 는 파일이 없을 때, `-n` 은 있을 때"]', 1, '인자를 받았는지 검사할 때 `if [ -z "$1" ]; then echo "사용법..."; fi` 처럼 자주 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 3, '숫자와 문자열 비교', '`[ 10 -gt 9 ]` 와 `[ "10" \\> "9" ]` 의 결과는 각각 어떻게 될까요?', '하나는 숫자, 하나는 글자(사전순)로 비교해요.', NULL, NULL, '[]', 'choice', '["`-gt` 는 숫자로 비교해 참이고, `\\\\>` 는 문자열(사전순)로 비교해 \\"1\\" 이 \\"9\\" 보다 앞이라 거짓이다", "둘 다 참이다", "둘 다 거짓이다", "`-gt` 는 거짓, `\\\\>` 는 참이다"]', 0, '숫자는 `-eq -ne -lt -le -gt -ge`, 문자열은 `=`, `!=` 로 비교하세요. 섞어 쓰면 엉뚱한 결과가 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 4, '대괄호 사이 공백', '`[-f f.txt]` 와 `[ -f f.txt]` 를 실행하면 각각 어떤 오류가 날까요?', '대괄호는 사실 하나의 명령이에요.', NULL, NULL, '[]', 'choice', '["둘 다 정상 동작한다", "둘 다 `Permission denied` 가 난다", "앞은 `missing ]`, 뒤는 `command not found`", "앞은 `[-f: command not found`, 뒤는 `missing ]` 오류. `[` 뒤와 `]` 앞에 공백이 필요하다"]', 3, '`[` 는 `test` 와 같은 명령이라 인자를 공백으로 구분해야 합니다. 마지막 인자로 `]` 가 와야 하고요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 5, '빈 변수와 따옴표', '`y=""` 일 때 `[ $y = a ]` 를 실행하면 어떻게 될까요?', '변수가 비면 쉘이 인자를 통째로 없애 버려요.', NULL, NULL, '[]', 'choice', '["정상적으로 거짓이 된다", "정상적으로 참이 된다", "`unary operator expected` 오류가 난다. `[ \\"$y\\" = a ]` 처럼 변수를 따옴표로 감싸야 한다", "스크립트가 멈추지 않고 무시한다"]', 2, '따옴표가 없으면 `[ = a ]` 가 되어 문법이 깨집니다. 변수는 항상 따옴표로 감싸는 습관이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 6, 'if 문의 끝', '`if ...; then ...` 으로 시작한 조건문은 무엇으로 끝낼까요?', 'if 를 거꾸로 쓴 글자예요.', NULL, NULL, '[]', 'choice', '["`end`", "`fi`", "`done`", "`esac`"]', 1, '`for`/`while` 은 `done`, `case` 는 `esac` 로 끝납니다. 시작과 끝이 짝이 되는 규칙을 외워 두세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 7, 'for 와 와일드카드', '`for f in *.txt; do echo "$f"; done` 은 어떻게 동작할까요?', '쉘이 별표를 파일 목록으로 펼쳐 줘요.', NULL, NULL, '[]', 'choice', '["쉘이 `*.txt` 를 현재 폴더의 `.txt` 파일 목록으로 펼치고, 파일마다 한 번씩 반복한다", "`*.txt` 라는 이름의 파일 하나만 처리한다", "모든 파일을 한 번에 처리한다", "폴더의 이름만 반복한다"]', 0, '파일이 하나도 없으면 `*.txt` 가 글자 그대로 한 번 처리되니 주의하세요. 파일 이름에 공백이 있으면 `"$f"` 로 따옴표를 꼭 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 8, '무한 반복 막기', '`i=1; while [ $i -le 3 ]; do echo $i; done` 을 실행하면 어떻게 될까요?', '반복할 때마다 i 가 바뀌는지 보세요.', NULL, NULL, '[]', 'choice', '["세 번 출력되고 끝난다", "한 번 출력되고 끝난다", "문법 오류가 난다", "`i` 가 변하지 않아 `1` 이 계속 출력되는 무한 반복이 된다. Ctrl+C 로 멈추고 `i=$((i+1))` 을 넣어야 한다"]', 3, '`while` 은 조건이 거짓이 될 때까지 반복합니다. 조건에 쓰는 값이 반복 안에서 바뀌도록 꼭 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 9, 'continue 와 break', '반복문 안에서 `continue` 와 `break` 의 차이로 알맞은 것은 무엇일까요?', '하나는 건너뛰고, 하나는 반복을 끝내요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`continue` 는 스크립트를 끝내고 `break` 는 건너뛴다", "`continue` 는 이번 차례를 건너뛰고 다음 차례로, `break` 는 반복 자체를 끝낸다", "`break` 는 이번 차례를 건너뛴다"]', 2, '조건에 맞지 않는 파일을 건너뛸 때는 `continue`, 원하는 것을 찾았을 때 그만둘 때는 `break` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 10, '산술 $(( ))', '`echo $((7/2))` 와 `echo "1+2"` 의 출력은 각각 무엇일까요?', '쉘은 계산식을 따로 써야 계산해요.', NULL, NULL, '[]', 'choice', '["`3.5` 와 `3`", "`3`(정수 나눗셈) 과 `1+2`(계산하지 않고 글자 그대로)", "`3` 과 `3`", "`3.5` 와 `1+2`"]', 1, '쉘의 `$(( ))` 는 정수 연산만 합니다. 소수점이 필요하면 `bc` 같은 다른 도구를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 11, '함수와 return', '함수 안에서 `return 3` 을 쓰면 무엇이 일어날까요?', '값을 돌려주는 것이 아니라 상태를 정해요.', NULL, NULL, '[]', 'choice', '["함수가 끝나고 종료 코드가 3 이 된다 (`$?` 로 읽는다). 출력값을 돌려주는 것이 아니다", "`3` 이 화면에 출력된다", "스크립트 전체가 종료 코드 3 으로 끝난다", "함수가 3번 실행된다"]', 0, '값을 돌려받으려면 함수 안에서 `echo` 로 출력하고 `$(함수)` 로 받습니다. `exit` 는 스크립트 전체를 끝내니 구분하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 12, 'local 변수', '함수 안에서 `local v=inner` 로 변수를 만들면 어떻게 될까요?', '함수 밖의 같은 이름과 섞이지 않아요.', NULL, NULL, '[]', 'choice', '["밖의 `v` 가 `inner` 로 바뀐다", "함수가 끝나도 계속 남는다", "오류가 난다", "함수 안에서만 쓰이고, 밖의 같은 이름 변수 `v` 는 바뀌지 않는다"]', 3, '`local` 이 없으면 함수 안의 변수가 전역이라 밖의 값을 덮어쓸 수 있습니다. 함수 안의 변수는 `local` 로 만드는 습관이 좋아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 13, '인자 변수들', '`./run.sh a b c` 로 실행했을 때 스크립트 안에서 `$#`, `$@`, `$0` 은 각각 무엇일까요?', '개수, 모두, 이름이에요.', NULL, NULL, '[]', 'choice', '["`$#` 은 첫 인자, `$@` 는 마지막 인자, `$0` 은 개수", "`$#` 은 스크립트 이름, `$@` 는 개수, `$0` 은 모든 인자", "`$#` 은 인자의 개수(3), `$@` 는 모든 인자(`a b c`), `$0` 은 스크립트 이름", "셋 모두 첫 번째 인자이다"]', 2, '`shift` 는 인자를 한 칸 앞으로 밀어 `$1` 을 버리고 `$2` 를 `$1` 로 만듭니다. 인자가 여러 개일 때 하나씩 처리하는 데 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 14, 'case 문', '`case $x in a) echo A;; b|c) echo BC;; *) echo other;; esac` 에서 `x=b` 이면 무엇이 출력될까요?', '`|` 는 "또는"이에요.', NULL, NULL, '[]', 'choice', '["`A`", "`BC` (`b|c` 갈래에 해당한다)", "`other`", "아무것도 출력되지 않는다"]', 1, '`;;` 는 각 갈래의 끝, `*` 는 나머지 모든 경우입니다. 여러 값에 따라 분기할 때 `if` 보다 읽기 쉬워요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 15, '& 와 $! 와 wait', '`sleep 100 &` 에서 `&`, 그리고 직후의 `$!` 와 `wait` 는 각각 무엇일까요?', '뒤에 붙는 것은 백그라운드, $! 는 방금 띄운 PID 예요.', NULL, NULL, '[]', 'choice', '["`&` 는 백그라운드로 실행해 쉘을 바로 돌려주고, `$!` 는 마지막 백그라운드 작업의 PID, `wait` 는 그 작업이 끝날 때까지 기다린다", "`&` 는 두 명령을 잇고, `$!` 는 종료 코드, `wait` 는 삭제한다", "`&` 는 파일을 만들고, `$!` 는 이름, `wait` 는 이동한다", "셋 모두 같은 일을 한다"]', 0, '`pgrep -x sleep` 으로 실제로 떠 있는지 볼 수 있고, `kill PID` 로 끝낼 수 있습니다. `wait` 를 쓰면 백그라운드 작업의 결과를 이어서 확인할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 16, '일반 파일인지 검사', '`f.txt` 가 **일반 파일로 존재하는지** 검사하는 옵션입니다. 빈칸을 채우세요.', 'file 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-d", "-z", "-n"]', NULL, '`-d` 는 폴더입니다. 대괄호 안에서 `[` 뒤와 `]` 앞에 공백을 빼먹지 마세요.', '[0]', 'if [ {0} f.txt ]; then echo yes; fi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 17, '빈 문자열인지 검사', '변수 `x` 가 **비어 있는지** 검사하는 옵션입니다. 빈칸을 채우세요.', 'zero 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-z", "-n", "-e", "-d"]', NULL, '`-n` 은 반대로 비어 있지 않을 때 참입니다. 변수는 따옴표로 감싸세요.', '[0]', 'if [ {0} "$x" ]; then echo empty; fi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 18, '숫자가 더 큰지 검사', '`n` 이 10 **보다 큰지** 숫자로 비교하는 연산자를 채우세요.', 'greater than 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["-gt", ">", "-lt", "=="]', NULL, '`>` 는 문자열 비교(사전순)가 되어 결과가 어긋납니다. 숫자는 `-gt`, `-lt`, `-eq` 를 쓰세요.', '[0]', 'if [ $n {0} 10 ]; then echo big; fi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 19, '문자열이 같은지 검사', '두 문자열이 **같은지** 비교하는 연산자를 채우세요.', '등호 하나예요.', NULL, NULL, '[]', 'fill', '["=", "-eq", "=>", "~"]', NULL, '`-eq` 는 숫자 비교입니다. 문자열을 `-eq` 로 비교하면 오류가 나요.', '[0]', 'if [ "$a" {0} "$b" ]; then echo same; fi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 20, '조건문 끝내기', '`if` 문을 끝내는 키워드를 채우세요.', 'if 를 거꾸로 쓴 글자예요.', NULL, NULL, '[]', 'fill', '["fi", "end", "done", "esac"]', NULL, '`done` 은 `for`/`while` 의 끝, `esac` 는 `case` 의 끝입니다.', '[0]', 'if [ -f f.txt ]; then echo y; {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 21, '1부터 3까지 반복', '1 부터 3 까지 숫자를 차례로 만드는 `seq` 의 끝 값을 채우세요.', '끝 값은 3 이에요.', NULL, NULL, '[]', 'fill', '["3", "to 3", "..3", "3-"]', NULL, '`seq 1 3` 은 `1 2 3` 을 만듭니다. `seq 1 2 9` 처럼 가운데 값은 증가폭이에요.', '[0]', 'for i in $(seq 1 {0}); do echo $i; done', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 22, '값을 1 늘리기', '반복마다 `i` 를 **1 늘리는** 식의 연산자를 채우세요.', '더하기 기호예요.', NULL, NULL, '[]', 'fill', '["+", "plus", "add", "inc"]', NULL, '`$(( ))` 안에서는 일반 산술 연산자(`+ - * / %`)를 씁니다. 변수 앞의 `$` 는 생략해도 돼요.', '[0]', 'i=$((i{0}1))', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 23, '함수의 첫 인자', '함수 안에서 **첫 번째 인자**를 꺼내는 표현을 채우세요.', '스크립트의 첫 인자와 같은 기호예요.', NULL, NULL, '[]', 'fill', '["$", "#", "%", "@"]', NULL, '함수 안의 `$1` 은 스크립트의 인자가 아니라 함수를 부를 때 넘긴 인자입니다. `greet kim` 이면 `kim` 이에요.', '[0]', 'greet() { echo "hi {0}1"; }', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 24, '함수의 종료 코드', '함수에서 종료 코드 3 으로 **빠져나오는** 키워드를 채우세요.', '"돌아가다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["return", "exit", "break", "stop"]', NULL, '`exit 3` 은 함수가 아니라 스크립트 전체를 끝냅니다. 함수만 끝낼 때는 `return` 이에요.', '[0]', 'ret() { {0} 3; }', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 25, 'case 갈래 끝', '`case` 의 한 갈래를 끝내는 기호를 채우세요.', '세미콜론 두 개예요.', NULL, NULL, '[]', 'fill', '[";;", ";", "&&", "||"]', NULL, '`;;` 를 빼먹으면 문법 오류가 납니다. 마지막 갈래에서는 생략할 수 있지만 습관으로 붙이는 것이 좋아요.', '[0]', 'case $x in a) echo A{0} b) echo B;; esac', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 26, '백그라운드로 실행', '`sleep 100` 을 **백그라운드로** 실행하려고 합니다. 뒤에 붙일 기호를 채우세요.', '앰퍼샌드 하나예요.', NULL, NULL, '[]', 'fill', '["&", "&&", "|", ";"]', NULL, '`&&` 는 앞이 성공하면 이어서 실행하는 연결 기호라 목적이 다릅니다. 하나(`&`)만 쓰면 백그라운드입니다.', '[0]', 'sleep 100 {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 27, '파일이 있으면 알리는 스크립트', '첫 인자로 받은 파일이 있으면 알리는 스크립트의 줄 순서입니다. 순서에 맞게 놓아 보세요.', 'shebang → 조건 시작 → 할 일 → 조건 끝 순서예요.', NULL, NULL, '[]', 'order', '["`#!/bin/bash`", "`if [ -f \\"$1\\" ]; then`", "`  echo \\"파일이 있습니다\\"`", "`fi`"]', NULL, '들여쓰기는 필수는 아니지만 읽기 쉬워집니다. 실행하기 전에 `chmod +x` 를 잊지 마세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 28, '로그 파일을 하나씩 압축하는 반복문', '현재 폴더의 `.log` 파일을 하나씩 안내하며 압축하는 반복문의 줄 순서입니다. 순서에 맞게 놓아 보세요.', '반복 시작 → 안내 → 할 일 → 반복 끝 순서예요.', NULL, NULL, '[]', 'order', '["`for f in *.log; do`", "`  echo \\"압축: $f\\"`", "`  gzip \\"$f\\"`", "`done`"]', NULL, '`"$f"` 처럼 따옴표로 감싸면 공백이 든 파일 이름도 안전합니다. `gzip` 은 원본을 압축 파일로 바꿉니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 29, '백그라운드 작업 다루기', '오래 걸리는 명령을 백그라운드로 돌리고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → PID 확인 → 떠 있는지 확인 → 마무리 순서예요.', NULL, NULL, '[]', 'order', '["`sleep 100 &` 로 백그라운드에서 실행한다", "`echo $!` 로 방금 띄운 작업의 PID 를 확인한다", "`pgrep -x sleep` 으로 실제로 떠 있는지 확인한다", "`kill PID` 로 끝내거나 `wait PID` 로 끝나기를 기다린다"]', NULL, '터미널을 닫아도 계속 돌려야 한다면 `nohup` 을 앞에 붙이세요. 그냥 `&` 는 터미널이 닫히면 같이 끝날 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 29);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 30, '대괄호 오류 풀기', '`[: missing ]` 또는 `command not found` 오류가 났을 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '오류 읽기 → 공백 확인 → 따옴표 확인 → 다시 실행 순서예요.', NULL, NULL, '[]', 'order', '["오류 메시지(`missing ]`, `command not found`)를 읽는다", "`[` 뒤와 `]` 앞에 공백이 있는지 확인한다", "빈 변수가 있을 수 있다면 `\\"$변수\\"` 처럼 따옴표로 감싼다", "고친 뒤 스크립트를 다시 실행해 확인한다"]', NULL, '대괄호 오류의 대부분은 공백과 따옴표 문제입니다. 이 두 가지를 먼저 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 30);
