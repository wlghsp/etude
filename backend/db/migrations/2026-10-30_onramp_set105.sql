-- 입문 세트 105. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_friendly_audit.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 105, '반복 입문: 같은 일을 컴퓨터에게 맡기기', '반복 작업 세트(35) 전에 가볍게 보는 입문입니다. 같은 일을 여러 번 시키는 이유, for 문의 모양, 와일드카드(*.log), seq, 한 줄씩 읽는 while read, 공백 파일 이름의 함정, 지우기 전에 echo 로 미리보기하는 습관을 쉬운 문제로 익힙니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 105);
UPDATE quest_set SET display_order = 90, unit_id = (SELECT id FROM unit WHERE id = 2), icon = '🪜' WHERE id = 105;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 1, '같은 일을 여러 번 시킬 때', '파일 100개에 똑같은 명령을 해야 합니다. 명령을 100번 직접 입력하는 대신 어떻게 하면 좋을까요?', '컴퓨터는 반복을 잘합니다. 반복을 시키는 문법이 있어요.', NULL, NULL, '[]', 'choice', '["100번 복사해서 붙여넣는다", "파일을 하나씩 지운다", "반복문(`for`)으로 컴퓨터에게 반복을 맡긴다", "컴퓨터를 재부팅한다"]', 2, '잘했어요! 반복문은 "같은 일을 여러 번"을 짧게 쓰게 해 줍니다. 오타도 줄고 속도도 빨라져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 2, 'for 반복문 빈칸 채우기', '`a`, `b`, `c` 를 하나씩 `f` 라는 이름으로 받아 출력하는 반복문입니다. 빈칸을 채워 보세요.', '반복 중인 값은 변수 이름 앞에 `$` 를 붙여 읽고, 끝은 `done` 입니다.', NULL, NULL, '[]', 'fill', '["$f", "f", "done", "end", "fi"]', NULL, '`for 변수 in 목록; do 할 일; done` 이 기본 모양이에요. 반복 중인 값은 `$f` 처럼 `$` 를 붙여 꺼냅니다. 끝을 알리는 `done` 을 잊지 마세요.', '[0, 2]', 'for f in a b c; do echo {0}; {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 3, '몇 번 출력될까?', '`for i in 1 2 3; do echo hi; done` 을 실행하면 `hi` 는 몇 번 출력될까요?', '목록에 값이 몇 개 있는지 세어 보세요.', NULL, NULL, '[]', 'choice', '["1번", "3번", "0번", "무한 반복"]', 1, '맞아요! 목록의 값 하나당 한 번씩 반복합니다. 값이 3개(1 2 3)라서 3번이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 4, 'for 문의 모양 순서 놓기', 'for 반복문을 쓰는 순서를 **앞에서 뒤**로 놓아 보세요.', '시작을 알리고, do 로 열고, 할 일을 쓰고, done 으로 닫아요.', NULL, NULL, '[]', 'order', '["`do`", "`for f in a b c` (무엇을 반복할지)", "`done`", "`echo $f` (할 일)"]', NULL, '`for …` → `do` → 할 일 → `done` 순서예요. `do` 와 `done` 이 반복할 내용을 감싸는 괄호라고 생각하면 쉬워요.', '[1, 0, 3, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 5, '*.log 가 뜻하는 것', '`for f in *.log` 에서 `*.log` 는 무엇을 뜻할까요?', '`*` 는 "아무 글자나 여러 개" 입니다.', NULL, NULL, '[]', 'choice', '["`*.log` 라는 이름의 파일 하나", "`.log` 폴더 안의 파일", "숨김 파일만", "이름이 `.log` 로 끝나는 모든 파일"]', 3, '좋아요! `*` 는 와일드카드라서 `a.log`, `b.log`, `error.log` 처럼 `.log` 로 끝나는 파일을 한꺼번에 가리켜요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 6, 'seq 로 숫자 만들기', '`seq 1 5` 는 `1 2 3 4 5` 를 한 줄에 하나씩 출력합니다. **1부터 3까지**를 만드는 명령은 `seq 1 ___` 입니다.', '끝 숫자를 쓰면 돼요.', NULL, NULL, '[]', 'fill', '["3", "1", "5", "10"]', NULL, '`seq 시작 끝` 은 그 범위의 숫자를 차례로 출력합니다. `for i in $(seq 1 3)` 처럼 반복 횟수를 정할 때 유용해요.', '[0]', 'seq 1 {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 7, '반복문과 seq 합치기', '`for i in $(seq 1 ___)` 로 **5번** 반복해 `$i` 를 출력하려 합니다. 빈칸의 숫자는 무엇일까요?', '1부터 몇까지 세야 5번일까요?', NULL, NULL, '[]', 'fill', '["5", "4", "6", "$i"]', NULL, '`seq 1 5` 는 1,2,3,4,5 로 5개라서 5번 반복해요. `$(...)` 는 안쪽 명령의 결과를 그 자리에 넣어 줍니다.', '[0]', 'for i in $(seq 1 {0}); do echo $i; done', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 8, '파일을 한 줄씩 읽어 처리하기', '서버 목록이 든 파일을 **한 줄씩** 읽으며 처리하고 싶을 때 자주 쓰는 형태는 무엇일까요?', '"줄을 읽는 동안 반복"이라는 뜻의 영어입니다.', NULL, NULL, '[]', 'choice', '["`for line in 파일`", "`if 파일`", "`while read line; do ... done < 파일`", "`echo 파일`"]', 2, '네! `while read` 는 입력에서 줄을 하나 읽어 처리하는 일을 줄이 끝날 때까지 반복해요. 파일 뒤의 `< 파일` 이 입력을 연결합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 9, '공백이 든 파일 이름', '파일 이름에 **공백**이 있으면 `for f in $(ls)` 가 이름을 둘로 쪼갭니다. 안전한 방법은 무엇일까요?', '`ls` 의 출력을 쪼개지 말고 쉘이 직접 파일 이름을 펼치게 하세요.', NULL, NULL, '[]', 'choice', '["`for f in *` 로 쓰고 사용할 때 `\\"$f\\"` 처럼 따옴표로 감싼다", "`ls` 를 더 자주 실행한다", "파일 이름을 전부 지운다", "공백은 문제가 안 된다"]', 0, '잘 알아냈어요! `*` 는 쉘이 파일 이름 하나하나를 정확히 넘겨 주고, `"$f"` 의 따옴표는 공백이 있어도 한 덩어리로 지켜 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 105, 10, '반복 명령을 안전하게 시험하는 순서', '파일을 지우는 반복문을 처음 쓸 때는 **실수를 막는 순서**가 있습니다. 앞에서 뒤로 놓아 보세요.', '지우기 전에 어떤 파일이 대상인지 먼저 눈으로 확인해요.', NULL, NULL, '[]', 'order', '["`echo` 를 지우고 진짜 명령으로 바꿔 실행한다", "`rm` 앞에 `echo` 를 붙여 **어떤 명령이 실행될지만 출력**해 본다", "결과를 보고 대상 파일이 맞는지 확인한다"]', NULL, '**echo 로 미리보기 → 대상 확인 → 진짜 실행** 입니다. 지우는 명령은 되돌리기 어려우니 이 습관 하나로 사고를 크게 줄일 수 있어요.', '[1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 105 AND order_index = 10);
