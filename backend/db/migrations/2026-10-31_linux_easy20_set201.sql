-- 리눅스 세트 201. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set201.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 201, '배열과 xargs: 배열 인덱스·+=·unset, 연관 배열, here-string, mapfile -t, xargs -n/-I/-P, printf -v', 'bash 배열과 반복 실행 도구의 동작을 한 개념씩 반복합니다. 배열의 인덱스·개수·음수 인덱스, "${arr[@]}" 와 "${arr[*]}" 와 따옴표 없는 확장의 차이, += 로 추가할 때의 인덱스와 괄호 없는 += 의 함정, unset 후 남는 빈 인덱스, 배열과 문자열 자르기, declare -A 연관 배열과 선언 없이 쓸 때의 함정, -v 와 :- 로 키 확인, here-string 과 파이프 read 의 차이, mapfile -t 와 서브쉘 문제, xargs 의 -n·-I·-r 과 -P 병렬 실행·종료 코드 123, printf -v 와 형식 재사용, seq 의 -s·-w, declare -p·-i·-r 속성을 짧은 객관식·빈칸·순서 문제로 익히고, 배열 만들고 순회하기, 연관 배열로 값 찾기, 파일 줄을 배열로 읽기, xargs 로 명령 반복하기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 201);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🪣' WHERE id = 201;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 1, '배열 꺼내기와 개수', '`arr=(a b c d)` 일 때 `${arr[1]}`, `${#arr[@]}`, `${arr[@]}`, `${arr[-1]}`, `${arr[9]}`, `${arr}` 는 각각 무엇일까요?', '번호는 0 부터 시작해요.', NULL, NULL, '[]', 'choice', '["`${arr[1]}` 은 `a` 이고 `${#arr[@]}` 는 3 이다", "`${arr[-1]}` 은 오류이다", "차례로 `b`, `4`, `a b c d`, `d`, 빈 값, `a` 이다. 인덱스는 0 부터이고 `-1` 은 마지막 원소이며 없는 인덱스는 빈 값이고 `${arr}` 는 첫 번째 원소(`${arr[0]}`)와 같다", "`${arr}` 는 모든 원소를 공백으로 이어 준다"]', 2, '개수는 `${#arr[@]}`, 한 원소의 글자 수는 `${#arr[0]}` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 2, '"${arr[@]}" 와 "${arr[*]}"', '원소가 `"a b"`, `c`, `"d e f"` 세 개인 배열 `w` 를 `for x in "${w[@]}"`, `for x in "${w[*]}"`, `for x in ${w[@]}` 로 돌면 반복 횟수는 각각 몇 번일까요?', '따옴표가 원소 경계를 지켜 줘요.', NULL, NULL, '[]', 'choice', '["셋 모두 3번이다", "차례로 3번, 1번, 6번이다. `\\"${w[@]}\\"` 는 원소 하나가 한 단어로 유지되고, `\\"${w[*]}\\"` 는 전체가 한 단어로 합쳐지며, 따옴표가 없으면 공백 기준으로 다시 쪼개져 6단어가 된다", "`\\"${w[*]}\\"` 가 3번이고 `\\"${w[@]}\\"` 가 1번이다", "따옴표가 없는 `${w[@]}` 도 3번이다"]', 1, '`IFS=,` 로 바꾸면 `"${w[*]}"` 가 쉼표로 이어진 문자열이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 3, '원소 추가와 빈 인덱스', '`s=(a b)` 에서 `s+=(c d)`, `s[7]=z`, 이어서 `s+=(w)` 를 하면 원소 개수와 인덱스는 어떻게 될까요? `t=(x y)` 에 `t+=z`(괄호 없음)는요?', '`+=` 는 뒤에 붙여요.', NULL, NULL, '[]', 'choice', '["`s+=(c d)` 로 4개, `s[7]=z` 를 하면 인덱스가 `0 1 2 3 7` 로 5개(중간은 비어 있음), `s+=(w)` 는 가장 큰 인덱스 다음인 8 에 붙는다. `t+=z` 는 새 원소가 아니라 첫 번째 원소 문자열에 붙어 `xz y` 가 된다", "`s[7]=z` 를 하면 인덱스 4 가 채워지고 개수는 5 이다", "`s+=(w)` 는 인덱스 5 에 붙는다", "`t+=z` 는 원소를 하나 더 추가해 `x y z` 가 된다"]', 0, '인덱스 목록은 `${!s[@]}` 로 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 4, '원소 지우기', '`u=(a b c d)` 에서 `unset ''u[1]''` 을 하면 개수와 인덱스는 어떻게 될까요? `u=("${u[@]}")` 로 다시 만들면요? `unset u` 후에는요?', '지워도 번호는 당겨지지 않아요.', NULL, NULL, '[]', 'choice', '["`unset ''u[1]''` 후 뒤 원소의 인덱스가 자동으로 당겨진다", "`unset ''u[1]''` 은 원소를 빈 문자열로 바꾸고 개수는 4 로 유지한다", "`unset u` 는 첫 번째 원소만 지운다", "`unset ''u[1]''` 후 개수는 3 이고 인덱스는 `0 2 3` 으로 구멍이 남는다. `u=(\\"${u[@]}\\")` 로 다시 만들면 인덱스가 `0 1 2` 로 당겨지고, `unset u` 를 하면 배열 전체가 사라져 개수가 0 이다"]', 3, '`u=()` 도 배열을 비웁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 5, '배열 자르기', '`v=(a b c d e)` 에서 `${v[@]:1:2}`, `${v[@]:3}`, `${v[@]: -2}` 는 각각 무엇일까요? 문자열 `str=abcdef` 의 `${str:1:3}`, `${str: -2}` 는요?', '`:시작:개수` 형식이에요.', NULL, NULL, '[]', 'choice', '["`${v[@]:1:2}` 는 `a b` 이다", "`${str:1:3}` 은 `abc` 이다", "배열은 차례로 `b c`, `d e`, `d e` 이고 문자열은 `bcd`, `ef` 이다. 시작은 0 부터이고 개수를 생략하면 끝까지이며 음수 시작은 `: -2` 처럼 앞에 공백을 두어야 한다", "`${str: -2}` 는 `ab` 이다"]', 2, '음수 앞에 공백을 두지 않으면 `${str:-2}` 처럼 "기본값" 문법으로 읽혀 버립니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 6, '연관 배열 기본', '`declare -A m` 후 `m[apple]=red`, `m[banana]=yellow`, `m["two words"]=ok` 를 넣으면 `${#m[@]}`, `${m[none]}`, `"${!m[@]}"`, `"${m[@]}"` 는 각각 무엇일까요? `declare -A` 없이 `nn[x]=1; nn[y]=2` 를 하면요?', '`${!m[@]}` 는 키 목록이에요.', NULL, NULL, '[]', 'choice', '["`\\"${m[@]}\\"` 는 키 목록이다", "개수는 3, 없는 키는 빈 값, `\\"${!m[@]}\\"` 는 키들(`apple`, `banana`, `two words`), `\\"${m[@]}\\"` 는 값들이다. 순서는 보장되지 않는다. `declare -A` 없이 쓰면 일반 배열이라 `x`, `y` 가 모두 인덱스 0 으로 계산되어 마지막 값 2 하나만 남는다", "`declare -A` 없이도 문자열 키가 잘 동작한다", "키에 공백이 있으면 오류이다"]', 1, '연관 배열은 bash 4 이상에서 쓸 수 있고 `declare -p m` 으로 내용을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 7, '키가 있는지 확인', '`declare -A h=([a]=1 [e]=)` 에서 `[[ -v h[a] ]]`, `[[ -v h[e] ]]`, `[[ -v h[z] ]]` 는 각각 참일까요? `${h[e]:-def}` 와 `${h[e]-def}` 는요?', '값이 비어 있는 것과 키가 없는 것은 달라요.', NULL, NULL, '[]', 'choice', '["차례로 참, 참(값이 비어도 키는 있음), 거짓이다. `${h[e]:-def}` 는 값이 비어도 기본값을 써서 `def`, `${h[e]-def}` 는 키가 있으면 빈 값 그대로 나온다", "`[[ -v h[e] ]]` 는 값이 비어 있으면 거짓이다", "`${h[e]:-def}` 는 빈 값을 그대로 둔다", "`[[ -v h[z] ]]` 는 없는 키여도 참이다"]', 0, '값이 비었는지만 보려면 `[[ -n ${h[e]} ]]` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 8, 'here-string 과 파이프', '`read a b <<< "x y z"` 의 `a`, `b` 는 무엇일까요? `echo hello | read v` 와 `read v <<< hello` 후 `$v` 는요? `wc -c <<< "ab"` 는 몇일까요?', '파이프의 `read` 는 서브쉘에서 실행돼요.', NULL, NULL, '[]', 'choice', '["`b` 는 `y` 이다", "`echo hello | read v` 도 `v` 가 `hello` 가 된다", "`wc -c <<< \\"ab\\"` 는 2 이다", "`a` 는 `x`, `b` 는 `y z` 이다. `echo hello | read v` 는 서브쉘이라 `v` 가 비어 있고 `read v <<< hello` 는 `v` 가 `hello` 이다. here-string 은 끝에 줄바꿈을 붙여 `wc -c` 는 3 이다"]', 3, '`<<<` 는 문자열을 명령의 표준 입력으로 넣는 문법입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 9, 'mapfile 로 줄 읽기', '줄이 3개인 파일에 `mapfile lines < f`, `mapfile -t lines < f` 를 하면 `${lines[0]}` 는 어떻게 다를까요? `printf ''a\\nb\\n'' | mapfile -t r` 는요? `r=($(cat f))` 와는 무엇이 다를까요?', '`-t` 는 줄바꿈을 떼요.', NULL, NULL, '[]', 'choice', '["`-t` 가 없으면 줄바꿈이 자동으로 제거된다", "`printf ... | mapfile -t r` 도 `r` 에 2개가 들어간다", "`-t` 가 없으면 각 원소 끝에 줄바꿈이 남고 `-t` 를 주면 떼어 낸다. 파이프 뒤의 `mapfile` 은 서브쉘에서 실행되어 `r` 이 비게 되므로 `mapfile -t r < <(명령)` 처럼 쓴다. `r=($(cat f))` 는 공백으로도 쪼개서 `a b` 같은 줄이 두 원소가 된다", "`r=($(cat f))` 는 줄 단위로만 쪼갠다"]', 2, '`readarray` 는 `mapfile` 의 다른 이름이고 `-n 2` 로 앞 2줄만, `-s 1` 로 1줄 건너뛰고 읽을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 10, 'xargs 의 묶음과 자리표시자', '`printf ''a\\nb\\nc\\nd\\ne\\n'' | xargs echo`, `xargs -n 2 echo`, `printf ''a b\\nc\\n'' | xargs -I{} echo "[{}]"` 는 각각 어떻게 출력될까요? 입력이 비었을 때 `xargs echo run` 과 `xargs -r echo run` 은요?', '`-I` 는 한 줄 전체를 자리에 넣어요.', NULL, NULL, '[]', 'choice', '["`xargs echo` 는 입력 줄마다 따로 실행한다", "첫째는 `a b c d e` 한 줄, `-n 2` 는 `a b`, `c d`, `e` 세 줄이다. `-I{}` 는 줄마다 한 번씩 실행해 `[a b]`, `[c]` 로 나온다. 입력이 비어도 `xargs echo run` 은 한 번 실행해 `run` 을 출력하고 `-r` 을 주면 실행하지 않는다", "`-I{}` 는 공백마다 나눠 `[a]`, `[b]`, `[c]` 로 나온다", "`-r` 을 줘도 입력이 비면 한 번 실행한다"]', 1, 'GNU `xargs` 기준입니다. macOS 의 `xargs` 는 입력이 비면 실행하지 않는 등 동작이 조금 다릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 11, 'xargs -P 와 종료 코드', '`printf ''1\\n1\\n1\\n1\\n'' | xargs -P 4 -n 1 sleep` 와 `-P 1` 은 걸리는 시간이 어떻게 다를까요? 실행한 명령 중 하나가 실패하면 `xargs` 의 종료 코드는요?', '`-P` 는 동시에 실행할 개수예요.', NULL, NULL, '[]', 'choice', '["`-P 4` 는 4개를 동시에 실행해 약 1초, `-P 1` 은 하나씩 실행해 약 4초 걸린다. 실행한 명령이 하나라도 1~125 로 실패하면 `xargs` 는 종료 코드 123 으로 끝난다", "`-P 4` 와 `-P 1` 은 걸리는 시간이 같다", "실패한 명령의 종료 코드가 그대로 `xargs` 의 종료 코드가 된다", "하나라도 실패하면 나머지는 실행되지 않고 종료 코드 1 이다"]', 0, '병렬로 돌리면 출력 순서가 섞일 수 있어 순서가 중요하면 `sort` 로 정리합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 12, 'printf 의 -v 와 형식 재사용', '`printf -v out ''%05d'' 42` 의 `$out` 은 무엇일까요? `printf ''%s:%s\\n'' a b c` 는 어떻게 출력될까요? `printf ''%d\\n'' 010 0x10` 은요?', '형식은 인자가 남으면 다시 쓰여요.', NULL, NULL, '[]', 'choice', '["`printf -v` 는 변수에 넣지 않고 화면에만 출력한다", "인자가 남으면 `printf` 가 오류로 끝난다", "`%d` 에 `010` 을 주면 10 이 출력된다", "`$out` 은 `00042` 이고 화면에는 나오지 않는다. `printf ''%s:%s\\\\n'' a b c` 는 형식을 다시 써서 `a:b` 와 `c:` 두 줄이 나오고, `%d` 에 `010` 은 8진수 8, `0x10` 은 16진수 16 으로 읽혀 `8` 과 `16` 이 나온다"]', 3, '`printf ''%s\\n'' "${arr[@]}"` 로 배열 원소를 한 줄씩 출력할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 13, 'seq 의 구분자와 간격', '`seq -s, 1 5`, `seq 5 -2 1`, `seq -w 8 11`, `seq 1 0` 은 각각 무엇을 출력할까요?', '`seq 시작 간격 끝` 이에요.', NULL, NULL, '[]', 'choice', '["`seq -s,` 는 마지막에도 쉼표를 붙인다", "`seq 5 -2 1` 은 `5 4 3 2 1` 이다", "차례로 `1,2,3,4,5`, `5 3 1`(줄 단위), `08 09 10 11`(자릿수 맞춤), 아무것도 출력하지 않음이다. 시작이 끝보다 큰데 간격이 양수이면 빈 결과가 나온다", "`seq 1 0` 은 `1 0` 을 출력한다"]', 2, '`seq -s'' '' 3` 은 `1 2 3` 처럼 한 줄로 이어 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 14, 'declare 의 속성', '`declare -p da` 는 무엇을 보여 줄까요? `declare -i n=3+4`, 이어서 `n="2*3"`, `n=abc` 의 `$n` 은요? `declare -r dr=1` 후 `dr=2` 는요?', '`-i` 는 정수로 계산해요.', NULL, NULL, '[]', 'choice', '["`-i` 변수에 `\\"2*3\\"` 을 대입하면 문자열 `2*3` 이 그대로 저장된다", "`-p` 는 `declare -a da=([0]=\\"a\\" [1]=\\"b\\")` 처럼 선언 형태로 보여 준다. `-i` 변수는 대입을 산술로 계산해 `7`, `6`, 숫자가 아닌 `abc` 는 `0` 이 된다(`-i` 없이는 `3+4` 문자열 그대로). `-r` 변수에 다시 대입하면 `readonly variable` 오류가 난다", "`-r` 변수는 다시 대입할 수 있다", "`declare -p` 는 값만 출력한다"]', 1, '`declare -l` 은 소문자, `declare -u` 는 대문자로 바꿔 저장합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 15, '연관 배열 선언', 'bash 에서 **연관 배열(문자열 키)** 을 선언하는 `declare` 옵션을 채우세요.', '"Associative"의 머리글자(대문자)예요.', NULL, NULL, '[]', 'fill', '["-A", "-a", "-i", "-r"]', NULL, '소문자 `-a` 는 일반 배열입니다.', '[0]', 'declare {0} m', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 16, '배열에 이어 붙이기', '배열 `arr` 에 **원소 두 개를 뒤에 추가하는** 연산자를 채우세요.', '덧셈 대입과 같은 모양이에요.', NULL, NULL, '[]', 'fill', '["+=", "=+", "<<", "++"]', NULL, '괄호 없이 쓰면 첫 원소 문자열에 붙으니 주의하세요.', '[0]', 'arr{0}(d e)', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 17, '줄바꿈 떼고 배열로', '`mapfile` 이 읽은 **각 줄 끝의 줄바꿈을 제거하게** 하는 옵션을 채우세요.', '"trim"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-n", "-s", "-d"]', NULL, '`readarray` 도 같은 옵션을 씁니다.', '[0]', 'mapfile {0} lines < list.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 18, 'here-string', '문자열을 명령의 **표준 입력으로 바로 넣는** 연산자를 채우세요.', '`<` 가 세 개예요.', NULL, NULL, '[]', 'fill', '["<<<", "<<", "<(", "<&"]', NULL, '문자열 끝에 줄바꿈이 붙습니다.', '[0]', 'grep -c x {0} "a x b"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 19, '자리표시자 옵션', '`xargs` 에서 **입력 한 줄을 지정한 자리에 넣어** 명령을 줄마다 실행하게 하는 옵션을 채우세요.', '"Insert"의 머리글자(대문자)예요.', NULL, NULL, '[]', 'fill', '["-I", "-n", "-P", "-0"]', NULL, '`X` 가 입력 줄로 바뀝니다.', '[0]', 'printf ''a\\nb\\n'' | xargs {0} X echo X.bak', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 20, '병렬 실행 개수', '`xargs` 가 **동시에 실행할 프로세스 수**를 정하는 옵션을 채우세요.', '"Parallel"의 머리글자(대문자)예요.', NULL, NULL, '[]', 'fill', '["-P", "-n", "-L", "-t"]', NULL, '병렬이면 출력 순서가 섞일 수 있습니다.', '[0]', 'printf ''1\\n1\\n'' | xargs {0} 4 -n 1 sleep', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 21, '입력이 비면 실행 안 함', '입력이 비어 있으면 `xargs` 가 **명령을 실행하지 않게** 하는 옵션을 채우세요.', '"run"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-r", "-e", "-i", "-z"]', NULL, '긴 이름은 `--no-run-if-empty` 입니다.', '[0]', 'printf '''' | xargs {0} echo run', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 22, '변수에 출력 담기', '`printf` 의 결과를 화면이 아니라 **변수에 담는** 옵션을 채우세요.', '"variable"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-v", "-o", "-s", "-t"]', NULL, '`$out` 은 `00042` 가 됩니다.', '[0]', 'printf {0} out ''%05d'' 42', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 23, '구분자를 정하는 seq', '`seq` 의 **숫자 사이 구분자를 바꾸는** 옵션을 채우세요.', '"separator"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-d", "-t", "-f"]', NULL, '기본 구분자는 줄바꿈입니다.', '[0]', 'seq {0} , 1 5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 24, '선언 형태로 보기', '변수나 배열이 **어떻게 선언되어 있는지** 보여 주는 `declare` 옵션을 채우세요.', '"print"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-p", "-l", "-s", "-x"]', NULL, '`declare -a arr=([0]="a" ...)` 처럼 나옵니다.', '[0]', 'declare {0} arr', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 25, '정수 속성', '대입을 **산술로 계산해 정수로 저장하는** `declare` 옵션을 채우세요.', '"integer"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-n", "-x", "-r"]', NULL, '`echo $n` 은 7 입니다.', '[0]', 'declare {0} n=3+4', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 26, '배열 만들고 순회하기', '배열을 만들고 원소를 추가해 순회하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 추가 → 개수 확인 → 순회 순서예요.', NULL, NULL, '[]', 'order', '["`arr=(a b c)` 로 배열을 만든다", "`arr+=(d)` 로 원소를 하나 추가한다", "`echo \\"${#arr[@]}\\"` 로 개수가 4 인지 확인한다", "`for x in \\"${arr[@]}\\"; do echo \\"$x\\"; done` 으로 원소를 하나씩 출력한다"]', NULL, '공백이 든 원소가 있으면 순회할 때 따옴표가 필수입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 27, '연관 배열로 값 찾기', '연관 배열에 값을 넣고 키를 확인해 순회하는 순서입니다. 순서에 맞게 놓아 보세요.', '선언 → 저장 → 키 확인 → 순회 순서예요.', NULL, NULL, '[]', 'order', '["`declare -A m` 으로 연관 배열을 선언한다", "`m[apple]=red` 로 키와 값을 저장한다", "`[[ -v m[apple] ]] && echo yes` 로 키가 있는지 확인한다", "`for k in \\"${!m[@]}\\"; do echo \\"$k=${m[$k]}\\"; done` 으로 키와 값을 출력한다"]', NULL, '`declare -A` 를 빼먹으면 일반 배열이 되어 키가 모두 인덱스 0 으로 계산됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 28, '파일 줄을 배열로 읽기', '파일의 줄을 배열로 읽어 쓰는 순서입니다. 순서에 맞게 놓아 보세요.', '읽기 → 개수 → 첫 줄 → 순회 순서예요.', NULL, NULL, '[]', 'order', '["`mapfile -t lines < list.txt` 로 파일의 줄을 배열에 읽는다", "`echo \\"${#lines[@]}\\"` 로 줄 수를 확인한다", "`echo \\"${lines[0]}\\"` 로 첫 줄에 줄바꿈이 붙지 않았는지 확인한다", "`for l in \\"${lines[@]}\\"; do echo \\"$l\\"; done` 으로 줄마다 처리한다"]', NULL, '`cmd | mapfile` 은 서브쉘이라 `mapfile -t lines < <(cmd)` 로 씁니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 29, 'xargs 로 명령 반복하기', '입력 목록으로 명령을 반복 실행해 보는 순서입니다. 순서에 맞게 놓아 보세요.', '입력 만들기 → 하나씩 → 자리표시자 → 병렬 순서예요.', NULL, NULL, '[]', 'order', '["`printf ''a\\\\nb\\\\nc\\\\n''` 으로 한 줄에 하나씩 입력 목록을 만든다", "`| xargs -n 1 echo got` 로 하나씩 실행되는지 확인한다", "`| xargs -I{} echo \\"[{}]\\"` 로 입력이 자리에 들어가는지 확인한다", "`| xargs -P 4 -n 1 sleep` 으로 병렬 실행하고 걸리는 시간을 비교한다"]', NULL, '입력이 비어도 실행되는 것을 막으려면 `-r` 을 붙입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 29);
