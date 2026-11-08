-- 리눅스 세트 219. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set219.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 219, '파일 크기와 앞뒤 읽기: head -c·-n -N, tail -n +N·-c, wc -l·-L·-w, du 와 ls 크기, truncate, dd, split -l', '파일의 앞뒤와 크기를 읽는 명령을 한 개념씩 반복합니다. head -c 와 -n -N, tail -n +N 과 -c, wc -l 이 줄바꿈 개수를 센다는 점, -L 과 -w, wc 파일 이름 유무와 total 줄, head 와 tail 의 기본 10줄, 여러 파일의 ==> 머리글과 -q, truncate 로 늘리고 줄이기, ls 크기와 du 크기의 차이를 짧은 객관식·빈칸·순서 문제로 익히고, du -s 와 -d, dd bs, split -l 도 빈칸으로 연습하며 앞뒤 줄 확인, 크기 늘리고 줄이기, 나눈 뒤 합치기, 겉보기와 실제 크기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 219);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🪚' WHERE id = 219;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 1, 'head -c', '`hello` 와 줄바꿈이 든 파일에 `head -c 5` 를 실행하면 무엇이 출력될까요?', '-c 는 바이트 수예요.', NULL, NULL, '[]', 'choice', '["`hello` 와 줄바꿈까지 한 줄이 모두 출력되고 `-c` 는 줄 수를 뜻한다", "`hello` 앞의 다섯 줄이 출력되는데 파일에 줄이 하나뿐이라 한 줄이 나온다", "`hello` 다섯 글자만 출력되고 줄바꿈은 출력되지 않는다", "오류가 나서 아무것도 출력되지 않고 `-c` 는 `head` 에 없는 옵션이다"]', 2, '`head -c 5` 는 처음 5바이트를 그대로 출력하므로 줄바꿈이 없어 다음 프롬프트가 같은 줄에 붙습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 2, 'head -n -2', '다섯 줄짜리 파일에 `head -n -2` 를 실행하면 무엇이 출력될까요?', '음수는 끝에서 뺀다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["처음 두 줄만 출력되고 나머지 세 줄은 출력되지 않는다", "마지막 두 줄을 뺀 앞의 세 줄이 출력된다", "오류가 나서 아무것도 출력되지 않고 음수는 쓸 수 없다", "마지막 두 줄만 출력되고 앞의 세 줄은 출력되지 않는다"]', 1, '`head -n 3` 과 결과는 같지만 줄 수를 몰라도 끝에서 몇 줄을 뺄지로 쓸 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 3, 'tail -n +3', '다섯 줄짜리 파일에 `tail -n +3` 을 실행하면 무엇이 출력될까요?', '+ 가 붙으면 시작 줄 번호예요.', NULL, NULL, '[]', 'choice', '["3번째 줄부터 끝까지 세 줄이 출력된다", "마지막 세 줄이 아니라 처음 세 줄이 출력되고 나머지는 출력되지 않는다", "마지막 줄 하나만 출력되고 `+3` 은 세 번 반복하라는 뜻이다", "오류가 나서 아무것도 출력되지 않고 `+` 는 `tail` 에서 쓸 수 없다"]', 0, '`tail -n 3` 은 마지막 세 줄이고 `tail -n +2` 는 헤더 한 줄을 건너뛸 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 4, 'tail -c', '`hello` 와 줄바꿈이 든 파일(6바이트)에 `tail -c 4` 를 실행하면 무엇이 출력될까요?', '줄바꿈도 한 바이트예요.', NULL, NULL, '[]', 'choice', '["`ello` 네 글자가 출력되고 줄바꿈은 세지 않는다", "`hell` 네 글자가 출력되고 파일 앞쪽부터 센다", "`hello` 와 줄바꿈 전체가 출력되고 `-c` 는 무시된다", "`llo` 와 줄바꿈 문자가 출력된다"]', 3, '줄바꿈도 바이트로 세므로 끝의 4바이트는 `l`, `l`, `o`, 줄바꿈입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 5, 'wc -l 은 줄바꿈 개수', '`a`, 줄바꿈, `b` 로 끝나는 파일(마지막 줄에 줄바꿈이 없음)에 `wc -l` 을 실행하면 몇이 나올까요?', '줄바꿈 문자를 세요.', NULL, NULL, '[]', 'choice', '["`2` 가 나온다. 마지막 줄도 한 줄로 세어 준다", "`0` 이 나온다. 줄바꿈이 끝에 없으면 한 줄도 없다고 본다", "`1` 이 나온다. 줄바꿈 문자의 개수를 센다", "`3` 이 나온다. 글자 수를 세어서 보여 준다"]', 2, '마지막 줄 끝에 줄바꿈이 없으면 `wc -l` 은 실제 줄보다 하나 적게 셉니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 6, 'wc -L', '`ab`, `abcdef`, `abc` 세 줄이 든 파일에 `wc -L` 을 실행하면 무엇이 나올까요?', '대문자 L 은 가장 긴 줄이에요.', NULL, NULL, '[]', 'choice', '["`3` 이 나온다. 파일의 줄 수를 보여 주고 소문자 `-l` 과 같다", "`6` 이 나온다. 가장 긴 줄의 글자 수를 보여 준다", "`11` 이 나온다. 세 줄의 글자 수를 모두 더한 값을 보여 준다", "`2` 가 나온다. 가장 짧은 줄의 글자 수를 보여 준다"]', 1, '소문자 `-l` 은 줄 수이고 대문자 `-L` 은 가장 긴 줄의 길이입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 7, 'wc -w', '`a b  c` 와 `d` 두 줄이 든 파일에 `wc -w` 를 실행하면 무엇이 나올까요?', '공백이나 줄바꿈으로 나뉜 덩어리를 세요.', NULL, NULL, '[]', 'choice', '["`4` 가 나온다. 공백과 줄바꿈으로 나뉜 단어를 센다", "`2` 가 나온다. 줄 하나를 단어 하나로 센다", "`6` 가 나온다. 공백 문자 하나하나를 단어로 센다", "`5` 가 나온다. 글자와 공백을 합친 수를 센다"]', 0, '연속된 공백은 하나로 보므로 `a`, `b`, `c`, `d` 네 개입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 8, 'wc -l 파일 이름', '`wc -l f5` 와 `wc -l < f5` 의 출력은 어떻게 다를까요?', '입력을 파일 이름으로 받았는지 보세요.', NULL, NULL, '[]', 'choice', '["앞은 `5` 만 나오고, 뒤는 `5 f5` 로 파일 이름이 붙는다", "둘 다 `5` 만 나오고 파일 이름은 `-H` 를 줘야 붙는다", "앞은 줄 수를 세고, 뒤는 바이트 수를 세어 서로 다른 값이 나온다", "앞은 `5 f5` 로 파일 이름이 붙고, 뒤는 `5` 만 나온다"]', 3, '`cat f5 | wc -l` 도 파일 이름을 모르므로 `5` 만 출력합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 9, 'wc 여러 파일', '`wc -l f5 s12` 처럼 파일을 두 개 주면 출력은 어떻게 될까요?', '마지막 줄을 보세요.', NULL, NULL, '[]', 'choice', '["파일마다 한 줄씩만 나오고 합계 줄은 `-t` 를 줘야 붙는다", "두 파일의 줄 수를 더한 숫자 하나만 한 줄로 나온다", "파일마다 한 줄씩 나오고 마지막에 `total` 합계 줄이 붙는다", "첫 번째 파일의 줄 수만 나오고 두 번째는 무시된다"]', 2, '파일이 하나일 때는 `total` 줄이 붙지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 10, 'head 의 기본 줄 수', '옵션 없이 `head` 와 `tail` 을 열두 줄짜리 파일에 실행하면 각각 몇 줄이 나올까요?', '기본값은 같아요.', NULL, NULL, '[]', 'choice', '["둘 다 5줄이 나오고 `-n` 으로 늘릴 수 있다", "둘 다 10줄이 나온다", "`head` 는 10줄, `tail` 은 전체 12줄이 나온다", "둘 다 12줄이 나오고 `-n` 을 줘야 줄어든다"]', 1, '10줄보다 짧은 파일에서는 있는 만큼만 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 11, 'head 여러 파일', '`head -n 1 f5 h` 처럼 파일을 둘 주면 출력은 어떻게 될까요? 머리글을 없애려면 무엇을 쓸까요?', '==> 로 시작하는 줄을 보세요.', NULL, NULL, '[]', 'choice', '["파일 앞마다 `==> 이름 <==` 머리글이 붙고, `-q` 를 주면 없어진다", "머리글 없이 줄만 이어서 나오고 `-v` 를 주면 이름이 붙는다", "첫 번째 파일의 첫 줄만 나오고 두 번째 파일은 무시된다", "오류가 나서 `head` 는 파일을 하나만 받을 수 있다고 알려 준다"]', 0, '`-v` 는 파일이 하나여도 머리글을 항상 붙입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 12, 'head -c -2', '`hello` 와 줄바꿈이 든 파일(6바이트)에 `head -c -2` 를 실행하면 무엇이 출력될까요?', '음수는 끝에서 뺀다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["`he` 두 글자가 출력된다. 앞의 2바이트만 남긴다", "`llo` 와 줄바꿈이 출력된다. 앞의 2바이트를 뺀다", "아무것도 출력되지 않고 음수 바이트 수는 오류로 처리한다", "`hell` 네 글자가 출력된다. 끝의 2바이트를 뺀다"]', 3, '마지막 줄바꿈과 `o` 가 빠지므로 `hell` 뒤에 줄바꿈도 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 13, 'truncate 로 늘리기', '3바이트인 파일에 `truncate -s 6` 을 실행하면 파일은 어떻게 될까요?', '늘어난 부분이 무엇으로 채워질지 보세요.', NULL, NULL, '[]', 'choice', '["6바이트가 되고 늘어난 부분은 공백 문자로 채워진다", "크기를 줄이는 명령이라서 늘리려 하면 오류가 나고 3바이트로 남는다", "6바이트가 되고 늘어난 부분은 널 문자로 채워진다", "6바이트가 되고 앞의 내용이 3번 반복해서 채워진다"]', 2, '`truncate -s 3` 처럼 작은 값을 주면 뒤가 잘려 나갑니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 14, 'ls 크기와 du 크기', '`truncate -s 1M sp` 로 만든 파일에서 `ls -l` 의 크기와 `du -k` 의 값은 어떻게 다를까요?', '내용을 쓰지 않은 빈 구간이에요.', NULL, NULL, '[]', 'choice', '["`ls -l` 은 0 바이트를 보이고 `du -k` 는 1024 로 둘이 서로 반대로 나온다", "`ls -l` 은 1048576 바이트를 보이고 `du -k` 는 0 으로 디스크 블록을 쓰지 않는다고 보인다", "둘 다 1048576 바이트와 1024 로 실제로 디스크를 그만큼 쓴 것으로 보인다", "`ls -l` 은 1048576 바이트를 보이고 `du -k` 는 오류를 내고 아무 값도 보이지 않는다"]', 1, '`du` 는 실제 쓰는 디스크 블록을, `ls -l` 은 겉보기 크기를 보여 줍니다. `du --apparent-size` 는 겉보기 크기로 셉니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 15, '앞에서 몇 줄', '`head` 에서 **앞의 줄 수를 정하는** 옵션을 채우세요.', '"number"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["c", "l", "w", "n"]', NULL, '`head -3` 처럼 숫자만 써도 같은 뜻입니다.', '[3]', 'head -{0} 3 f5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 16, '앞에서 몇 바이트', '`head` 에서 **앞의 바이트 수를 정하는** 옵션을 채우세요.', '"character"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["c", "b", "k", "s"]', NULL, '줄바꿈도 한 바이트로 세어집니다.', '[0]', 'head -{0} 5 f5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 17, '3번째 줄부터', '`tail` 에서 **3번째 줄부터 끝까지 출력하는** 줄 수 앞의 기호를 채우세요.', '"더하기"예요.', NULL, NULL, '[]', 'fill', '["-", "+", "=", "@"]', NULL, '기호 없이 `3` 만 쓰면 마지막 세 줄입니다.', '[1]', 'tail -n {0}3 f5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 18, '줄 수 세기', '`wc` 에서 **줄 수를 세는** 옵션을 채우세요.', '"line"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["c", "w", "l", "L"]', NULL, '`-c` 는 바이트, `-w` 는 단어입니다.', '[2]', 'wc -{0} f5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 19, '가장 긴 줄', '`wc` 에서 **가장 긴 줄의 길이를 보는** 옵션을 채우세요.', '"line"의 대문자예요.', NULL, NULL, '[]', 'fill', '["l", "m", "c", "L"]', NULL, '소문자 `-l` 은 줄 수입니다.', '[3]', 'wc -{0} f5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 20, '합계만 보기', '`du` 에서 **폴더 전체의 합계만 한 줄로 보는** 옵션을 채우세요.', '"summary"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["s", "a", "c", "d"]', NULL, '하위 폴더까지 보려면 `-d` 로 깊이를 정합니다.', '[0]', 'du -{0}h dd', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 21, '깊이 정해 보기', '`du` 에서 **내려갈 폴더 깊이를 정하는** 옵션을 채우세요.', '"depth"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["s", "d", "n", "l"]', NULL, '`-d 0` 은 `-s` 와 같습니다.', '[1]', 'du -{0} 1 dd', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 22, '크기 바꾸기', '`truncate` 에서 **파일 크기를 지정하는** 옵션을 채우세요.', '"size"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["n", "l", "s", "c"]', NULL, '작은 값은 뒤를 자르고 큰 값은 널 문자로 채웁니다.', '[2]', 'truncate -{0} 10 f', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 23, '블록 크기', '`dd` 에서 **한 번에 읽고 쓰는 덩어리 크기를 정하는** 항목을 채우세요.', '"block size"의 약자예요.', NULL, NULL, '[]', 'fill', '["size", "block", "len", "bs"]', NULL, '`bs=1k count=2` 는 2048바이트입니다.', '[3]', 'dd if=/dev/zero of=z {0}=1k count=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 24, '줄 수로 나누기', '`split` 에서 **파일을 정한 줄 수로 나누는** 옵션을 채우세요.', '"line"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["l", "n", "b", "w"]', NULL, '`-b` 는 바이트 수로 나눕니다.', '[0]', 'split -{0} 5 s12 part_', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 25, '머리글 없애기', '`head` 에서 **여러 파일의 `==>` 머리글을 없애는** 옵션을 채우세요.', '"quiet"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["s", "q", "h", "v"]', NULL, '`-v` 는 머리글을 항상 붙입니다.', '[1]', 'head -{0} -n 1 f5 h', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 26, '앞뒤 줄 확인', '파일의 줄 수를 세고 앞뒤를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 세기 → 앞 → 뒤 순서예요.', NULL, NULL, '[]', 'order', '["`tail -n 3 s12` 로 `10`, `11`, `12` 가 나오는지 확인한다", "`head -n 3 s12` 로 `1`, `2`, `3` 이 나오는지 확인한다", "`seq 1 12 > s12` 로 열두 줄짜리 파일을 만든다", "`wc -l s12` 로 `12 s12` 가 나오는지 확인한다"]', NULL, '`head -n -2` 는 끝의 두 줄을 뺀 나머지입니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 27, '크기 늘리고 줄이기', '파일 크기를 만들고 바꾸는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 확인 → 줄이기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`truncate -s 1k z` 로 파일을 1024바이트로 줄인다", "`wc -c < z` 로 `1024` 가 나오는지 확인한다", "`wc -c < z` 로 `2048` 이 나오는지 확인한다", "`dd if=/dev/zero of=z bs=1k count=2` 로 파일을 만든다"]', NULL, '`truncate` 는 파일의 앞부분만 남기고 뒤를 자릅니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 28, '나눈 뒤 합치기', '파일을 나눈 뒤 다시 합쳐 같은지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 나누기 → 개수 → 합쳐 비교 순서예요.', NULL, NULL, '[]', 'order', '["`wc -l q_*` 로 `5`, `5`, `2` 줄의 조각이 나왔는지 확인한다", "`seq 1 12 > s12` 로 열두 줄짜리 파일을 만든다", "`cat q_* | cmp - s12` 로 합친 결과가 원본과 같은지 확인한다", "`split -l 5 s12 q_` 로 다섯 줄씩 나눈다"]', NULL, '`cmp` 는 같으면 아무것도 출력하지 않습니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 29, '겉보기와 실제 크기', '빈 구간이 있는 파일의 두 가지 크기를 비교하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → ls → du → 겉보기 순서예요.', NULL, NULL, '[]', 'order', '["`ls -l sp` 로 크기가 `1048576` 인지 확인한다", "`du -h --apparent-size sp` 로 겉보기 크기가 `1.0M` 인지 확인한다", "`truncate -s 1M sp` 로 내용 없이 1MB 짜리 파일을 만든다", "`du -k sp` 로 쓰는 디스크가 `0` 으로 나오는지 확인한다"]', NULL, '`du` 는 실제 블록을, `ls -l` 은 겉보기 크기를 봅니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 29);
