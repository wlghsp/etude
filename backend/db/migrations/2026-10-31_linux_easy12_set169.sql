-- 리눅스 세트 169. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set169.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 169, '찾아서 처리하기: find 조건, -exec 와 xargs, tee·tr·uniq 한 줄씩', '파일을 찾아 한꺼번에 처리하는 기본기를 한 개념씩 반복합니다. find 의 -name 은 이름만 비교한다는 것과 -iname·-path, -type·-maxdepth·-mindepth, -size 의 올림과 바이트 단위, -empty, 부정(!)과 OR(-o)·괄호, -newer, -exec 의 세미콜론 형식과 + 형식의 실행 횟수 차이, -delete 를 조건 앞에 쓰면 전부 지워지는 위험, xargs 의 기본 동작과 공백이 든 이름의 문제, -print0 과 -0, -n·-r, tee 의 화면·파일 동시 출력과 -a, tr 로 글자 바꾸기·지우기, uniq 는 이웃한 줄만 합친다는 것과 sort | uniq -c 집계를 짧은 객관식·빈칸·순서 문제로 익히고, 안전하게 찾아서 지우기, 공백 이름 때문에 실패한 xargs 고치기, 가장 많이 나온 줄 찾기, 화면에 보면서 저장하고 이어 쓰기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 169);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🔎' WHERE id = 169;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 1, '-name 은 이름만 본다', '`find d -name ''sub/b.txt''` 는 `d/sub/b.txt` 를 찾을 수 있을까요? 경로까지 조건으로 쓰려면 무엇을 쓸까요?', '`-name` 은 경로의 마지막 부분만 비교해요.', NULL, NULL, '[]', 'choice', '["찾는다 (`-name` 은 전체 경로를 비교한다)", "오류가 나서 실행되지 않는다", "찾지 못한다 (`-name` 은 경로가 아닌 파일 이름만 비교한다). 경로까지 비교하려면 `-path ''*/sub/*''` 처럼 쓴다", "찾지 못하고, 경로 조건은 `find` 에서 쓸 수 없다"]', 2, '대소문자를 무시하려면 `-iname` 을 씁니다. `-name ''*.txt''` 는 `UP.TXT` 를 찾지 못하지만 `-iname ''*.txt''` 는 찾아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 2, '-mindepth 1', '`find d` 와 `find d -mindepth 1` 의 차이는 무엇일까요?', '시작 위치 자신을 포함하는지가 달라요.', NULL, NULL, '[]', 'choice', '["`-mindepth 1` 은 하위 폴더를 제외한다", "`find d` 는 시작 위치 `d` 자신도 결과에 포함하고, `-mindepth 1` 은 `d` 자신을 빼고 그 안의 항목만 보여 준다", "`-mindepth 1` 은 첫 번째 파일만 보여 준다", "둘은 완전히 같다"]', 1, '`-maxdepth 1` 은 반대로 너무 깊이 들어가지 않게 제한합니다. 둘을 함께 써서 깊이를 정확히 정할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 3, '-size 의 올림', '크기가 2바이트인 파일에 `find -size -1k` 는 어떻게 동작할까요? 그리고 `-size +1k` 는 2048바이트 파일을 찾을까요?', '단위 크기로 올림해서 비교해요.', NULL, NULL, '[]', 'choice', '["`-size -1k` 는 올림한 크기가 1k 보다 작은 0바이트 파일만 찾아서 2바이트 파일은 찾지 못하고, `-size +1k` 는 2048바이트 파일을 찾는다", "`-size -1k` 는 1k 보다 작은 모든 파일을 찾아 2바이트 파일도 찾는다", "`-size +1k` 는 2048바이트 파일을 찾지 못한다", "`-size` 는 바이트 단위만 쓸 수 있다"]', 0, '작은 파일을 정확히 가리려면 `-size -100c` 처럼 바이트(`c`)를 쓰세요. 단위(k, M)를 쓰면 올림해서 비교해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 4, '-empty', '`find d -empty` 는 무엇을 찾을까요?', '내용이 아무것도 없는 것이에요.', NULL, NULL, '[]', 'choice', '["빈 파일만 찾는다", "빈 폴더만 찾는다", "이름이 없는 파일을 찾는다", "내용이 없는 빈 파일(0바이트)과 비어 있는 폴더를 모두 찾는다"]', 3, '`-type f -empty` 처럼 종류를 함께 쓰면 빈 파일만 고를 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 5, '조건 부정과 OR', '`.log` 나 `.dat` 파일을 찾으려면 어떻게 쓰고, `.txt` 가 아닌 파일은 어떻게 찾을까요?', 'OR 는 `-o`, 부정은 `!` 예요. OR 를 묶을 때는 괄호가 필요해요.', NULL, NULL, '[]', 'choice', '["`-name ''*.log'' + ''*.dat''` 로 쓰고, 부정은 `-not-name` 이다", "`-name ''*.log'' | ''*.dat''` 로 쓰고, 부정은 `~` 이다", "`-type f \\\\( -name ''*.log'' -o -name ''*.dat'' \\\\)` 처럼 괄호로 묶어 `-o` 를 쓰고, `.txt` 가 아닌 파일은 `-type f ! -name ''*.txt''` 로 찾는다", "OR 와 부정은 `find` 에서 쓸 수 없다"]', 2, '괄호는 쉘이 먼저 해석하지 않게 `\\( \\)` 로 이스케이프합니다. `-o` 를 괄호 없이 `-type` 과 섞으면 의도와 다르게 묶일 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 6, '-newer', '`find d -type f -newer d/old.txt` 는 무엇을 찾을까요?', '기준이 되는 파일과 수정 시각을 비교해요.', NULL, NULL, '[]', 'choice', '["`d/old.txt` 와 이름이 같은 파일", "`d/old.txt` 보다 수정 시각이 더 최근인 파일", "`d/old.txt` 보다 크기가 큰 파일", "`d/old.txt` 보다 오래된 파일"]', 1, '`-mtime +365` 처럼 날짜로 고르는 방법도 있습니다. 기준 파일을 `touch -d` 로 만들어 두면 ''이 시각 이후''를 고르기 편해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 7, '-exec 의 \\; 와 +', '`find d -type f -exec 명령 {} \\;` 와 `find d -type f -exec 명령 {} +` 는 파일 8개를 처리할 때 명령을 몇 번 실행할까요?', '하나는 파일마다, 하나는 모아서예요.', NULL, NULL, '[]', 'choice', '["`\\\\;` 는 파일마다 한 번씩 총 8번 실행하고, `+` 는 파일 이름을 모아 한 번에(여기서는 1번) 실행한다", "둘 다 8번 실행한다", "둘 다 1번 실행한다", "`\\\\;` 는 1번, `+` 는 8번 실행한다"]', 0, '`+` 는 실행 횟수가 적어 빠릅니다. 단, 파일마다 따로 실행해야 하는 명령에는 `\\;` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 8, '-exec 와 공백이 든 이름', '파일 이름이 `with space.txt` 처럼 공백을 포함해도 `find -name ''with*'' -exec wc -c {} \\;` 는 정상 동작합니다. 왜일까요?', 'find 가 이름을 직접 명령에 넘겨요.', NULL, NULL, '[]', 'choice', '["공백이 자동으로 밑줄로 바뀐다", "공백이 있는 파일은 건너뛴다", "따옴표를 알아서 붙여 주는 쉘이 처리한다", "`find` 가 파일 이름을 하나의 인자로 그대로 `{}` 자리에 넘기기 때문에 공백이 있어도 쪼개지지 않는다"]', 3, '`find ... | xargs 명령` 은 다르게 동작합니다. 공백에서 쪼개져 `No such file` 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 9, '-delete 의 위치', '`find d4 -delete -name ''*.log''` 처럼 `-delete` 를 조건보다 앞에 쓰면 어떻게 될까요?', 'find 는 식을 왼쪽부터 평가해요.', NULL, NULL, '[]', 'choice', '["`.log` 파일만 삭제된다", "오류가 나서 아무것도 삭제되지 않는다", "`-delete` 가 `-name` 조건보다 먼저 평가되어 조건과 상관없이 `d4` 안의 모든 것(`d4` 자신까지)이 삭제된다", "삭제 대신 목록만 출력한다"]', 2, '`-delete` 는 항상 맨 뒤에 쓰세요. 먼저 `-delete` 를 뺀 같은 명령으로 목록을 확인하는 습관이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 10, 'xargs 의 기본 동작', '`printf ''a b c\\n'' | xargs echo X` 는 무엇을 출력할까요? 입력에 공백이 든 파일 이름이 있다면요?', '입력을 공백과 줄바꿈으로 나눠 인자로 써요.', NULL, NULL, '[]', 'choice', '["`X a b c` 가 한 줄로 합쳐진 하나의 인자로 전달된다", "`X a b c` 가 출력된다 (입력을 공백·줄바꿈으로 나눠 명령의 인자로 붙인다). 공백이 든 이름은 둘로 쪼개져 `No such file` 오류가 날 수 있다", "입력 한 줄마다 `echo X` 를 따로 실행한다", "입력을 무시하고 `X` 만 출력한다"]', 1, '한 줄씩 따로 실행하려면 `-n 1` 이나 `-I{}` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 11, '-print0 과 -0', '공백이 든 파일 이름도 안전하게 `xargs` 로 넘기려면 어떻게 할까요?', '이름 사이를 NUL 문자로 구분해요.', NULL, NULL, '[]', 'choice', '["`find ... -print0 | xargs -0 명령` 처럼 NUL 문자로 구분해서 넘긴다 (공백이나 줄바꿈이 있어도 쪼개지지 않는다)", "`xargs` 앞에 `sort` 를 붙인다", "`xargs -s` 를 쓴다", "파일 이름의 공백을 모두 지운 뒤 처리한다"]', 0, '`find -print0` 과 `xargs -0` 은 항상 짝으로 씁니다. 하나만 쓰면 이름이 엉망으로 읽혀요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 12, 'xargs 에 입력이 없으면', 'GNU `xargs` 에 입력이 하나도 없을 때 `xargs echo ran` 과 `xargs -r echo ran` 은 각각 어떻게 동작할까요?', '하나는 빈 입력으로도 실행해요.', NULL, NULL, '[]', 'choice', '["둘 다 실행하지 않는다", "둘 다 한 번 실행한다", "`-r` 은 입력이 없으면 오류로 종료한다", "`xargs echo ran` 은 입력이 없어도 명령을 한 번 실행해 `ran` 을 출력하고, `-r` 을 붙이면 입력이 없을 때 실행하지 않는다"]', 3, '`find` 결과가 없을 때 `xargs rm` 이 인자 없이 실행되는 일을 막으려면 `-r` 을 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 13, 'tee 의 역할', '`echo hello | tee out.txt` 는 무엇을 할까요? `tee -a` 와 옵션이 없는 `tee` 는 어떻게 다를까요?', 'T자 모양 배관처럼 두 곳으로 흘려요.', NULL, NULL, '[]', 'choice', '["파일에만 저장하고 화면에는 아무것도 보이지 않는다", "화면에만 보이고 파일은 만들지 않는다", "입력을 화면(표준 출력)에 보여 주면서 동시에 `out.txt` 에도 저장한다. 옵션이 없으면 파일을 덮어쓰고 `-a` 를 붙이면 파일 끝에 이어 쓴다", "`-a` 는 파일을 삭제한다"]', 2, '`>` 는 화면에 나오지 않지만 `tee` 는 파이프를 이어 가기 때문에 `tee 파일 | tr a-z A-Z` 처럼 뒤에 다른 명령을 붙일 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 14, 'uniq 는 이웃한 줄만', '`b a b a b` (한 줄씩)가 든 파일을 정렬 없이 `uniq -c` 하면 결과는 어떨까요? `sort` 를 먼저 하면요?', '이웃한 같은 줄만 합쳐요.', NULL, NULL, '[]', 'choice', '["정렬 없이도 `2 a`, `3 b` 가 나온다", "정렬하지 않으면 이웃한 줄만 합치므로 `1 b`, `1 a`, `1 b`, `1 a`, `1 b` 처럼 합쳐지지 않고, `sort | uniq -c` 로 하면 `2 a`, `3 b` 가 된다", "오류가 나서 실행되지 않는다", "첫 줄만 남는다"]', 1, '''많이 나온 순'' 집계는 `sort | uniq -c | sort -rn` 이 정석입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 15, '종류로 고르기', '**파일만** 고르는 `find` 조건 이름을 채우세요.', '"종류"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["type", "kind", "mode", "is"]', NULL, '`d` 는 폴더, `f` 는 일반 파일입니다.', '[0]', 'find d -{0} f', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 16, '깊이 제한', '`d` 바로 아래 항목만 보도록 **깊이를 1로 제한**하는 조건을 채우세요.', '"최대 깊이"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["maxdepth", "depth", "limit", "level"]', NULL, '`-maxdepth 1` 이면 `d` 바로 아래의 항목만 봅니다(폴더 안으로는 들어가지 않아요).', '[0]', 'find d -{0} 1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 17, '대소문자 무시', '이름을 **대소문자 구분 없이** 비교하는 조건을 채우세요.', '`-name` 앞에 "i"가 붙어요.', NULL, NULL, '[]', 'fill', '["iname", "nocase", "name -i", "lname"]', NULL, '`UP.TXT` 와 `a.txt` 를 모두 찾습니다.', '[0]', 'find d -{0} ''*.txt''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 18, '파일마다 한 번씩 실행', '`-exec` 로 **파일마다 한 번씩** 명령을 실행하게 하는 끝 표시를 채우세요.', '백슬래시와 세미콜론이에요.', NULL, NULL, '[]', 'fill', '["\\\\;", "&&", "|", ">"]', NULL, '세미콜론은 쉘이 먼저 해석하지 않도록 백슬래시로 이스케이프합니다.', '[0]', 'find d -name ''*.log'' -exec rm {} {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 19, 'NUL 로 구분해 출력', '`find` 가 결과를 **NUL 문자로 구분해 출력**하는 동작을 채우세요.', '"출력"과 숫자 0 을 붙여요.', NULL, NULL, '[]', 'fill', '["print0", "printnull", "nul", "zero"]', NULL, '공백이 든 이름을 안전하게 넘기는 방법입니다.', '[0]', 'find d -name ''with*'' -{0} | xargs -0 wc -c', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 20, 'NUL 로 구분된 입력 읽기', 'NUL 로 구분된 입력을 읽도록 `xargs` 에 주는 옵션을 채우세요.', '숫자 0 이에요.', NULL, NULL, '[]', 'fill', '["-0", "-z", "-n", "-s"]', NULL, '`find -print0` 과 짝으로 씁니다.', '[0]', 'find d -print0 | xargs {0} rm', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 21, '몇 개씩 묶어 실행', '`xargs` 가 입력을 **2개씩 묶어** 명령에 넘기도록 옵션을 채우세요.', '"개수"를 뜻하는 영어 단어의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-c", "-s", "-m"]', NULL, '`a b`, `c` 처럼 두 번에 나눠 `echo` 가 실행됩니다.', '[0]', 'printf ''a\\nb\\nc\\n'' | xargs {0} 2 echo', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 22, '입력 없으면 실행 안 함', '입력이 없을 때 `xargs` 가 **명령을 실행하지 않도록** 옵션을 채우세요.', '"실행하지 않음"을 뜻하는 단어 `no-run-if-empty` 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["-r", "-e", "-x", "-q"]', NULL, '빈 입력에도 `rm` 이 인자 없이 실행되는 것을 막습니다.', '[0]', 'find d -name ''*.tmp'' -print0 | xargs -0 {0} rm', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 23, '화면과 파일에 동시에', '출력을 **화면에 보여 주면서 파일에도 저장**하는 명령을 채우세요.', '배관의 T자 연결관과 같은 이름이에요.', NULL, NULL, '[]', 'fill', '["tee", "cat", "dup", "split"]', NULL, '`-a` 를 붙이면 파일 끝에 이어 씁니다.', '[0]', 'echo hi | {0} out.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 24, '소문자를 대문자로', '`tr` 로 **소문자를 대문자로** 바꿀 때 뒤쪽 범위를 채우세요.', '대문자 알파벳 범위예요.', NULL, NULL, '[]', 'fill', '["A-Z", "a-Z", "Z-A", "0-9"]', NULL, '`tr -d ''\\r''` 처럼 `-d` 로 지정한 글자를 지울 수도 있습니다.', '[0]', 'echo hi | tr a-z {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 25, '같은 줄 개수 세기', '정렬된 입력에서 같은 줄이 **몇 번 나왔는지 세어** 앞에 붙이는 `uniq` 옵션을 채우세요.', '"count"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-c", "-d", "-u", "-n"]', NULL, '`-d` 는 중복된 줄만, `-u` 는 한 번만 나온 줄만 보여 줍니다.', '[0]', 'sort w.txt | uniq {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 26, '안전하게 찾아서 지우기', '조건에 맞는 파일을 `find -delete` 로 지울 때 실수를 줄이는 순서입니다. 순서에 맞게 놓아 보세요.', '목록 → 확인 → 같은 조건에 삭제 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`-delete` 없이 조건만으로 `find d -name ''*.log''` 를 실행해 목록을 본다", "목록이 지울 파일만 정확히 가리키는지 확인한다", "같은 명령 맨 뒤에 `-delete` 를 붙여 실행한다", "같은 `find` 를 다시 실행해 남은 것이 없는지 확인한다"]', NULL, '`-delete` 가 조건보다 앞에 오면 모든 것이 지워집니다. 삭제 옵션은 항상 마지막에 쓰세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 27, '공백 이름 때문에 실패한 xargs 고치기', '`find | xargs 명령` 이 공백이 든 파일 이름에서 실패할 때 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 원인 → 고치기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`find d -name ''with*'' | xargs wc -c` 가 `No such file` 오류를 내는 것을 본다", "`xargs` 가 공백에서 이름을 쪼갠다는 것을 파악한다", "`find` 에 `-print0` 을, `xargs` 에 `-0` 을 붙인다", "다시 실행해 공백이 든 이름도 정상 처리되는지 확인한다"]', NULL, '또는 `-exec 명령 {} +` 를 쓰면 파이프 없이도 이름이 쪼개지지 않아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 28, '가장 많이 나온 줄 찾기', '파일에서 가장 많이 나온 줄과 횟수를 찾는 순서입니다. 순서에 맞게 놓아 보세요.', '정렬 → 세기 → 많은 순 정렬 → 맨 위 순서예요.', NULL, NULL, '[]', 'order', '["`sort 파일` 로 같은 줄을 이웃하게 모은다", "`uniq -c` 로 줄마다 횟수를 센다", "`sort -rn` 으로 횟수가 큰 순서로 정렬한다", "`head -1` 로 맨 위 한 줄만 본다"]', NULL, '첫 `sort` 를 빼먹으면 이웃한 줄만 세어 결과가 틀립니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 29, '화면에 보면서 저장하고 이어 쓰기', '명령의 출력을 화면에서 확인하며 파일에 저장하고 다음 결과를 이어 붙이는 순서입니다. 순서에 맞게 놓아 보세요.', '처음 저장 → 확인 → 이어쓰기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`echo hello | tee out.txt` 로 화면에 보면서 파일에 저장한다", "`cat out.txt` 로 한 줄이 저장되었는지 확인한다", "`echo again | tee -a out.txt` 로 파일 끝에 이어 쓴다", "`cat out.txt` 로 두 줄이 모두 남아 있는지 확인한다"]', NULL, '`-a` 없이 다시 `tee out.txt` 를 하면 앞의 내용이 덮어써져 사라집니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 29);
