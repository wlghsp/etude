-- 기본기 사다리 1: 세트 43(명령 연결 개념, 세트 3 앞)·44(find 천천히, 단원 2 맨 앞). 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set43/44.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 43, '명령 연결 개념 먼저 이해하기: 출력·오류·파이프', '명령의 정상 출력과 오류가 어디로 나가는지, `>`·`>>`·`2>&1`·파이프(`|`)·`&&`·`||` 가 무엇을 하는지 터미널 없이 먼저 이해합니다. 이 개념은 뒤의 프로세스·로그·find 실습에서 계속 쓰입니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 43);
UPDATE quest_set SET display_order = 25, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🚰' WHERE id = 43;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 1, '명령의 세 통로: 입력, 출력, 오류 알기', '명령이 실행되면 기본으로 **세 개의 통로**가 열립니다. 번호와 이름이 알맞게 짝지어진 것은 무엇일까요?', '키보드로 들어오는 것이 입력, 화면으로 나가는 정상 결과가 출력, 화면으로 나가는 에러 메시지가 오류입니다. 번호는 0, 1, 2 순서입니다.', NULL, NULL, '[]', 'choice', '["0번 표준 입력(stdin), 1번 표준 출력(stdout), 2번 표준 오류(stderr)", "0번 표준 출력, 1번 표준 입력, 2번 표준 오류", "1번 표준 입력, 2번 표준 출력, 3번 표준 오류", "0번 표준 오류, 1번 표준 출력, 2번 표준 입력"]', 0, '명령에는 **0번 표준 입력**(들어오는 것), **1번 표준 출력**(정상 결과), **2번 표준 오류**(에러 메시지) 통로가 있습니다. `2>&1` 에서 보이는 1 과 2 가 바로 이 번호입니다. 아무 설정이 없으면 1번과 2번이 모두 화면으로 나옵니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 2, '화면에 같이 보이는 정상 출력과 오류의 차이 알기', '`ls /etc /nonexistent` 를 실행하면 `/etc` 의 목록과 `/nonexistent` 의 에러 메시지가 **한 화면에 함께** 보입니다. 이 둘은 어떤 관계일까요?', '화면에 같이 나오지만 나가는 통로는 서로 다릅니다. 통로가 다르면 따로 파일로 보낼 수 있습니다.', NULL, NULL, '[]', 'choice', '["같은 통로로 나오는 같은 종류의 출력이다", "서로 다른 통로(1번 정상 출력, 2번 오류)로 나오지만 둘 다 화면에 연결돼 있어서 같이 보인다", "에러 메시지는 화면에 나오지 않고 로그 파일에만 저장된다", "정상 출력은 화면에, 오류는 항상 파일에 저장된다"]', 1, '정상 결과(1번)와 에러 메시지(2번)는 **다른 통로**지만 기본값으로 둘 다 화면에 연결돼 있어서 섞여 보입니다. 통로가 다르기 때문에 `>` 와 `2>` 로 따로 파일에 보낼 수 있습니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 3, '> 와 >> 로 파일에 보내는 빈칸 채우기', '아래 두 줄을 실행하려고 합니다. 첫 줄은 `list.txt` 를 **새로 만들며** `ls /etc` 결과를 넣고, 둘째 줄은 `list.txt` 의 **기존 내용을 지우지 않고 뒤에** `date` 결과를 붙입니다. 빈칸을 채우세요.', '`>` 는 파일을 새로 만들어 덮어쓰고, `>>` 는 파일 끝에 이어 붙입니다. 파이프(`|`)는 다른 명령으로 넘기는 것이라 파일 저장과는 다릅니다.', NULL, NULL, '[]', 'fill', '[">", ">>", "|", "2>"]', NULL, '`>` 는 파일을 **덮어씁니다.** (없으면 새로 만듭니다.) `>>` 는 기존 내용 **뒤에 이어 씁니다.** 로그처럼 계속 쌓아야 하는 내용에는 `>>` 를 써야 이전 내용이 사라지지 않습니다. `|` 는 명령 사이를 잇는 파이프이고, `2>` 는 오류 통로만 파일로 보냅니다.', '[0, 1]', 'ls /etc {0} list.txt
date {1} list.txt', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 4, '파이프로 로그에서 ERROR 줄 수 세는 명령 조립하기', '로그 파일 `app.log` 에서 `ERROR` 가 들어 있는 줄이 **몇 줄인지** 세려고 합니다. 앞 명령의 출력을 뒤 명령의 입력으로 넘기는 파이프(`|`)로 이어서 **왼쪽에서 오른쪽 순서**대로 놓으세요.', '먼저 파일 내용을 꺼내고, ERROR 가 있는 줄만 거르고, 마지막에 줄 수를 셉니다. 한 단계의 출력이 다음 단계의 입력이 됩니다.', NULL, NULL, '[]', 'order', '["`| wc -l` (줄 수 세기)", "`cat app.log` (파일 내용 꺼내기)", "`| grep ERROR` (ERROR 줄만 거르기)"]', NULL, '`cat app.log | grep ERROR | wc -l` 입니다. `cat` 이 내용을 내보내면 `grep` 이 ERROR 줄만 남기고, `wc -l` 이 그 줄 수를 셉니다. 파이프는 **앞 명령의 출력을 뒤 명령의 입력으로** 넘기는 통로입니다.', '[1, 2, 0]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 5, '파이프(|)와 리다이렉션(>)의 차이 구분하기', '`ls | wc -l` 과 `ls > out.txt` 에서 `|` 와 `>` 는 무엇이 다를까요?', '`|` 의 오른쪽에는 **명령**이 오고, `>` 의 오른쪽에는 **파일**이 옵니다.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같은 기능이다", "`|` 는 출력을 다른 명령의 입력으로 넘기고, `>` 는 출력을 파일로 보낸다", "`|` 는 파일에 쓰고, `>` 는 다른 명령으로 넘긴다", "`|` 는 오류만, `>` 는 정상 출력만 처리한다"]', 1, '`|`(파이프)는 앞 명령의 출력을 **뒤 명령의 입력**으로, `>`(리다이렉션)는 출력을 **파일**로 보냅니다. 파이프는 명령을 이어 붙이는 도구이고, 리다이렉션은 결과를 저장하는 도구입니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 6, '> 로는 오류 메시지가 파일에 담기지 않는 이유 알기', '`ls /nonexistent > out.txt` 를 실행했습니다. `/nonexistent` 는 없는 경로입니다. 결과는 어떻게 될까요?', '`>` 는 1번(정상 출력) 통로만 파일로 보냅니다. 에러 메시지는 몇 번 통로로 나올까요?', NULL, NULL, '[]', 'choice', '["`out.txt` 에 에러 메시지가 저장되고 화면에는 아무것도 안 나온다", "`out.txt` 는 비어 있고, 에러 메시지는 그대로 화면에 나온다", "`out.txt` 와 화면 둘 다에 에러 메시지가 나온다", "명령이 실행되지 않는다"]', 1, '`>` 는 **1번(정상 출력)** 만 파일로 보냅니다. 에러 메시지는 **2번(오류)** 통로라서 그대로 화면에 나오고 `out.txt` 는 비어 있습니다. 오류도 파일에 담으려면 `2>` 나 `2>&1` 이 필요합니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 7, '2>&1 로 오류를 같은 파일에 합쳐 담는 빈칸 채우기', '`/etc` 의 목록(정상 출력)과 `/nonexistent` 의 에러 메시지(오류)를 **둘 다 `all.txt` 에** 담으려고 합니다. 명령의 빈칸을 채우세요.', '`2>&1` 은 "2번(오류)을 1번(정상 출력)이 가는 곳으로 보내라"는 뜻입니다. 1번이 먼저 파일로 가도록 `> all.txt` 뒤에 씁니다.', NULL, NULL, '[]', 'fill', '["2>&1", "1>&2", "2>", "|"]', NULL, '`2>&1` 은 오류(2번)를 정상 출력(1번)이 가는 곳으로 보냅니다. 먼저 `> all.txt` 로 1번이 파일로 가게 해 두었으니, 2번도 같은 파일로 갑니다. `1>&2` 는 반대 방향이고, `2>` 만 쓰면 파일 이름이 필요하며, `|` 는 파일이 아니라 명령으로 보냅니다.', '[0]', 'ls /etc /nonexistent > all.txt {0}', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 8, '출력과 오류를 한 파일에 담는 올바른 순서 고르기', '정상 출력과 오류를 **모두** `all.txt` 에 담으려고 합니다. `ls /etc /nonexistent` 뒤에 붙일 올바른 형태는 무엇일까요?', '리다이렉션은 **왼쪽에서 오른쪽** 순서로 처리됩니다. 1번이 파일로 간 **다음에** 2번을 "1번이 있는 곳"으로 보내야 합니다.', NULL, NULL, '[]', 'choice', '["`> all.txt 2>&1`", "`2>&1 > all.txt` (오류는 아직 화면을 가리키는 1번을 따라가서 화면에 남는다)", "`| all.txt`", "`> all.txt 2> all.txt` (두 통로가 같은 파일을 따로 열어 서로 덮어쓸 수 있다)"]', 0, '`> all.txt 2>&1` 이 올바른 순서입니다. 먼저 1번을 파일로 보낸 뒤 2번을 1번이 가는 곳(파일)으로 보냅니다. `2>&1 > all.txt` 는 순서가 반대라서 2번이 **그 시점의 1번(아직 화면)** 을 따라가 오류가 화면에 남습니다. `| all.txt` 는 파일이 아니라 명령으로 보내는 문법입니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 43, 9, '&& 와 || 와 ; 의 설명 중 틀린 것 찾기', '세 가지 연결 기호를 설명한 문장 중 **틀린 것**을 고르세요.', '`&&` 는 "앞이 성공하면", `||` 는 "앞이 실패하면", `;` 는 "상관없이 그냥 이어서"입니다.', NULL, NULL, '[]', 'choice', '["`A && B` 는 A 가 성공해야 B 를 실행한다", "`A || B` 는 A 가 실패했을 때만 B 를 실행한다", "`A ; B` 는 A 의 성공·실패와 상관없이 B 를 실행한다", "`A && B` 는 A 가 실패해도 B 를 실행한다"]', 3, '틀린 것은 마지막입니다. `A && B` 는 A 가 **성공해야만** B 를 실행합니다. `||` 는 실패했을 때만, `;` 는 결과와 상관없이 실행합니다. 예: `mkdir data && cd data` 는 폴더 만들기에 성공했을 때만 이동합니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 43 AND order_index = 9);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 44, 'find 천천히 익히기: 찾고, 걸러내고, 실행하기', '파일을 찾는 `find` 를 옵션 하나씩 익힙니다. 구조 이해부터 이름·종류·크기·시간·깊이 조건, 조건 조합(`-o`, `!`), 찾은 파일에 명령 실행(`-exec`), 삭제(`-delete`), `xargs` 연결, 여러 조건을 한꺼번에 만족하는 종합 문제까지 단계별로 연습합니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 44);
UPDATE quest_set SET display_order = 45, unit_id = (SELECT id FROM unit WHERE id = 2), icon = '🔍' WHERE id = 44;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 1, 'find 명령의 기본 구조 읽기', '`find /var/log -name "*.log"` 는 어떤 뜻일까요?', '`find` 는 **어디서 / 어떤 조건의 것을** 찾을지 순서대로 적습니다: `find 시작위치 조건`.', NULL, NULL, '[]', 'choice', '["`/var/log` 아래(하위 폴더까지)에서 이름이 `.log` 로 끝나는 파일이나 폴더를 찾는다", "`/var/log` 에서 `.log` 라는 글자가 든 **줄**을 찾는다", "현재 폴더에서 `/var/log` 를 찾는다", "`.log` 파일을 `/var/log` 로 복사한다"]', 0, '`find 시작위치 조건` 형태입니다. 시작 위치(`/var/log`)부터 **하위 폴더까지 모두** 뒤져서 조건(`-name "*.log"`)에 맞는 것을 찾아 경로를 출력합니다. 파일 **안의 글자**를 찾는 것은 `grep` 이고, `find` 는 파일·폴더의 **이름과 속성**을 찾습니다.', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 2, 'find 명령 한 줄을 올바른 순서로 조립하기', '`/var/log` 아래에서 이름이 `.log` 로 끝나는 것을 찾는 명령의 조각이 섞여 있습니다. **왼쪽에서 오른쪽 순서**대로 놓으세요.', '명령 이름, 어디서 찾을지, 어떤 조건으로 찾을지 순서입니다.', NULL, NULL, '[]', 'order', '["`-name \\"*.log\\"` (조건)", "`find` (명령)", "`/var/log` (시작 위치)"]', NULL, '`find /var/log -name "*.log"` 순서입니다. 명령, 시작 위치, 조건 순서이고, 조건은 `-name`, `-type`, `-size` 처럼 `-` 로 시작하는 옵션으로 적습니다.', '[1, 2, 0]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 3, 'find 의 -name 패턴에 따옴표를 붙이는 이유 알기', '`find . -name *.txt` 처럼 **따옴표 없이** 쓰면, 현재 폴더에 `.txt` 파일이 이미 있을 때 이상하게 동작할 수 있습니다. 올바른 쓰기와 그 이유는 무엇일까요?', '`*` 는 쉘(터미널)이 먼저 해석해서 파일 이름으로 바꿔 버릴 수 있습니다. find 가 직접 해석하게 하려면 쉘이 건드리지 못하게 해야 합니다.', NULL, NULL, '[]', 'choice', '["`-name \\"*.txt\\"` 처럼 따옴표로 감싸야 쉘이 `*` 를 미리 펼치지 않고 find 가 패턴으로 해석한다", "따옴표는 장식이라 있든 없든 같다", "따옴표가 있어야 숨김 파일도 찾는다", "따옴표를 붙이면 대소문자를 구분하지 않는다"]', 0, '따옴표가 없으면 쉘이 먼저 `*.txt` 를 현재 폴더의 파일 이름들로 펼쳐서 `find` 에 넘겨 엉뚱한 인자가 됩니다. `"*.txt"` 처럼 감싸면 패턴 그대로 `find` 에 전달되고, **find 가 하위 폴더까지 직접 매칭**합니다. (대소문자를 구분하지 않으려면 `-iname` 을 씁니다.)', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 4, '이름 패턴으로 파일 찾아 저장하기 (-name)', '여러 폴더에 흩어진 파일 중 **이름이 `.txt` 로 끝나는 것**만 찾고 싶을 때 `find` 의 `-name` 을 씁니다.

1. `/tmp/lab` 아래(하위 폴더 포함)에서 이름이 `.txt` 로 끝나는 파일을 찾으세요.
2. 찾은 경로를 `/tmp/found_txt.txt` 에 저장하세요.', '형태: `find <시작위치> -name "<패턴>" > <파일>`
`-name` 은 이름이 패턴과 맞는 것을 찾고, `*` 는 "아무 글자나 여러 개"입니다. 패턴은 쉘이 먼저 펼치지 않도록 따옴표로 감쌉니다. `>` 는 출력을 파일로 저장합니다.
확인: `cat /tmp/found_txt.txt`', 'find /tmp/lab -name "*.txt" > /tmp/found_txt.txt

# /tmp/lab        : 이 폴더 아래(하위 폴더까지)에서 찾는다
# -name "*.txt"   : 이름이 .txt 로 끝나는 것 (따옴표로 쉘이 * 를 펼치지 않게 한다)
# > 파일          : 찾은 경로를 파일에 저장', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log"]', '["sh", "-c", "( [ -s /tmp/found_txt.txt ] ) && ( grep -qx /tmp/lab/docs/readme.txt /tmp/found_txt.txt && grep -qx /tmp/lab/docs/notes.txt /tmp/found_txt.txt ) && ( ! grep -qE ''[.](py|log)$'' /tmp/found_txt.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/found_txt.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/found_txt.txt ]"]}, {"label": "docs/readme.txt 와 docs/notes.txt 가 둘 다 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/docs/readme.txt /tmp/found_txt.txt && grep -qx /tmp/lab/docs/notes.txt /tmp/found_txt.txt"]}, {"label": ".py, .log 파일은 들어 있지 않다", "cmd": ["sh", "-c", "! grep -qE ''[.](py|log)$'' /tmp/found_txt.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 5, '폴더만 골라 찾기 (-type d)', '`find` 는 파일과 폴더를 모두 찾습니다. **종류**로 걸러 내려면 `-type` 을 씁니다.

1. `/tmp/lab` 아래에서 **폴더(디렉터리)만** 찾으세요.
2. 경로를 `/tmp/found_dirs.txt` 에 저장하세요.', '형태: `find <시작위치> -type d > <파일>`
`-type d` 는 폴더(directory), `-type f` 는 일반 파일(file)만 고릅니다. 시작 위치 자신도 폴더라서 결과에 포함됩니다.
확인: `cat /tmp/found_dirs.txt`', 'find /tmp/lab -type d > /tmp/found_dirs.txt

# -type d : 폴더만 (-type f 는 일반 파일만)', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log"]', '["sh", "-c", "( [ -s /tmp/found_dirs.txt ] ) && ( grep -qx /tmp/lab/src/lib /tmp/found_dirs.txt ) && ( ! grep -qE ''[.](txt|py|log)$'' /tmp/found_dirs.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/found_dirs.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/found_dirs.txt ]"]}, {"label": "깊이 있는 폴더 src/lib 까지 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/src/lib /tmp/found_dirs.txt"]}, {"label": "파일 경로는 들어 있지 않다", "cmd": ["sh", "-c", "! grep -qE ''[.](txt|py|log)$'' /tmp/found_dirs.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 6, '큰 파일만 찾기 (-size)', '디스크를 많이 차지하는 파일을 찾을 때는 `-size` 로 크기 조건을 줍니다.

`/tmp/lab` 아래에는 `data` 폴더에 크기가 다른 파일이 있습니다.

1. **10KB 보다 큰 파일**(일반 파일)만 찾으세요.
2. 경로를 `/tmp/big_files.txt` 에 저장하세요.', '형태: `find <시작위치> -type f -size +10k > <파일>`
`-size +10k` 는 "10KB 보다 큰"(`+` 는 보다 큼, `-` 는 보다 작음)이고, 단위는 `k`(킬로바이트), `M`(메가바이트), `G`(기가바이트)입니다.
확인: `ls -l` 로 파일 크기를 비교해 보세요.', 'find /tmp/lab -type f -size +10k > /tmp/big_files.txt

# -size +10k : 10KB 보다 큰 것 (+ 는 보다 큼, - 는 보다 작음)
# -type f    : 폴더 말고 일반 파일만', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log && mkdir -p /tmp/lab/data && head -c 20000 /dev/zero > /tmp/lab/data/big1.bin && head -c 15000 /dev/zero > /tmp/lab/data/big2.bin && echo x > /tmp/lab/data/tiny.bin"]', '["sh", "-c", "( [ -s /tmp/big_files.txt ] ) && ( grep -qx /tmp/lab/data/big1.bin /tmp/big_files.txt && grep -qx /tmp/lab/data/big2.bin /tmp/big_files.txt ) && ( ! grep -q tiny.bin /tmp/big_files.txt && ! grep -qE ''[.](txt|py|log)$'' /tmp/big_files.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/big_files.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/big_files.txt ]"]}, {"label": "big1.bin, big2.bin 이 둘 다 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/data/big1.bin /tmp/big_files.txt && grep -qx /tmp/lab/data/big2.bin /tmp/big_files.txt"]}, {"label": "작은 파일(tiny.bin 등)은 들어 있지 않다", "cmd": ["sh", "-c", "! grep -q tiny.bin /tmp/big_files.txt && ! grep -qE ''[.](txt|py|log)$'' /tmp/big_files.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 7, '오래된 파일 찾기 (-mtime)', '오래된 로그를 정리하려면 **수정한 지 얼마나 됐는지**로 찾습니다.

`/tmp/lab/logs` 에는 최근 로그와 오래된 로그가 섞여 있습니다.

1. 이름이 `.log` 로 끝나고 **수정한 지 7일보다 오래된** 파일을 찾으세요.
2. 경로를 `/tmp/old_logs.txt` 에 저장하세요.', '형태: `find <시작위치> -name "<패턴>" -mtime +7 > <파일>`
`-mtime +7` 은 마지막 수정이 7일보다 더 오래전인 것, `-mtime -7` 은 최근 7일 안, `-mtime 0` 은 오늘입니다. 조건을 여러 개 쓰면 **모두 만족**하는 것만 나옵니다.
확인: `ls -l /tmp/lab/logs`', 'find /tmp/lab/logs -name "*.log" -mtime +7 > /tmp/old_logs.txt

# -mtime +7 : 마지막 수정이 7일보다 오래된 것 (-7 은 최근 7일 안)
# 조건을 여러 개 쓰면 모두 만족하는 것만 나온다', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log && touch -d ''30 days ago'' /tmp/lab/logs/app.log && touch -d ''10 days ago'' /tmp/lab/logs/db.log && touch /tmp/lab/logs/today.log"]', '["sh", "-c", "( [ -s /tmp/old_logs.txt ] ) && ( grep -qx /tmp/lab/logs/app.log /tmp/old_logs.txt && grep -qx /tmp/lab/logs/db.log /tmp/old_logs.txt ) && ( ! grep -q today.log /tmp/old_logs.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/old_logs.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/old_logs.txt ]"]}, {"label": "30일 된 app.log 와 10일 된 db.log 가 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/logs/app.log /tmp/old_logs.txt && grep -qx /tmp/lab/logs/db.log /tmp/old_logs.txt"]}, {"label": "오늘 만든 today.log 는 들어 있지 않다", "cmd": ["sh", "-c", "! grep -q today.log /tmp/old_logs.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 8, '바로 아래 파일만 찾기 (-maxdepth)', '`find` 는 기본으로 하위 폴더 끝까지 내려갑니다. **깊이를 제한**하려면 `-maxdepth` 를 씁니다.

1. `/tmp/lab` **바로 아래에 있는 일반 파일**만 찾으세요 (`docs`, `src` 같은 하위 폴더 안은 제외).
2. 경로를 `/tmp/top_files.txt` 에 저장하세요.', '형태: `find <시작위치> -maxdepth 1 -type f > <파일>`
`-maxdepth 1` 은 시작 위치에서 한 단계(바로 아래)까지만 내려갑니다. `-maxdepth 2` 면 두 단계입니다. 이 옵션은 다른 조건보다 **앞쪽에** 쓰는 것이 좋습니다.
확인: `ls /tmp/lab`', 'find /tmp/lab -maxdepth 1 -type f > /tmp/top_files.txt

# -maxdepth 1 : 바로 아래 한 단계까지만 내려간다
# -type f     : 일반 파일만', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log && echo 1 > /tmp/lab/top1.txt && echo 2 > /tmp/lab/top2.txt"]', '["sh", "-c", "( [ -s /tmp/top_files.txt ] ) && ( grep -qx /tmp/lab/top1.txt /tmp/top_files.txt && grep -qx /tmp/lab/top2.txt /tmp/top_files.txt ) && ( ! grep -qE ''/(docs|src|logs)/'' /tmp/top_files.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/top_files.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/top_files.txt ]"]}, {"label": "top1.txt 와 top2.txt 가 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/top1.txt /tmp/top_files.txt && grep -qx /tmp/lab/top2.txt /tmp/top_files.txt"]}, {"label": "하위 폴더(docs, src, logs) 안의 파일은 들어 있지 않다", "cmd": ["sh", "-c", "! grep -qE ''/(docs|src|logs)/'' /tmp/top_files.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 9, '또는 조건으로 두 종류 한꺼번에 찾기 (-o)', '조건을 둘 이상 쓰면 기본은 "그리고(모두 만족)"입니다. **"A 이거나 B"** 로 찾으려면 `-o`(or)를 씁니다.

1. `/tmp/lab` 아래에서 이름이 `.log` 로 끝나거나 `.txt` 로 끝나는 **일반 파일**을 찾으세요.
2. 경로를 `/tmp/log_or_txt.txt` 에 저장하세요.', '형태: `find <위치> -type f \\( -name "A" -o -name "B" \\) > <파일>`
`-o` 는 "또는"입니다. 괄호 `\\( ... \\)` 로 묶어야 `-type f` 가 두 조건 모두에 적용됩니다. 쉘이 괄호를 해석하지 않도록 앞에 `\\` 를 붙입니다.
확인: `cat /tmp/log_or_txt.txt`', 'find /tmp/lab -type f \\( -name "*.log" -o -name "*.txt" \\) > /tmp/log_or_txt.txt

# \\( ... \\) : 조건을 묶는다 (\\ 는 쉘이 괄호를 해석하지 못하게)
# -o         : 또는', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log"]', '["sh", "-c", "( [ -s /tmp/log_or_txt.txt ] ) && ( grep -qx /tmp/lab/docs/readme.txt /tmp/log_or_txt.txt && grep -qx /tmp/lab/docs/notes.txt /tmp/log_or_txt.txt ) && ( grep -qx /tmp/lab/logs/app.log /tmp/log_or_txt.txt && grep -qx /tmp/lab/logs/db.log /tmp/log_or_txt.txt ) && ( ! grep -q ''[.]py$'' /tmp/log_or_txt.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/log_or_txt.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/log_or_txt.txt ]"]}, {"label": ".txt 파일 2개가 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/docs/readme.txt /tmp/log_or_txt.txt && grep -qx /tmp/lab/docs/notes.txt /tmp/log_or_txt.txt"]}, {"label": ".log 파일 2개가 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/lab/logs/app.log /tmp/log_or_txt.txt && grep -qx /tmp/lab/logs/db.log /tmp/log_or_txt.txt"]}, {"label": ".py 파일은 들어 있지 않다", "cmd": ["sh", "-c", "! grep -q ''[.]py$'' /tmp/log_or_txt.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 10, '특정 파일을 빼고 찾기 (! 부정)', '"~가 **아닌** 것"을 찾을 때는 조건 앞에 `!` 를 붙입니다.

1. `/tmp/lab` 아래에서 이름이 `.py` 로 끝나지 **않는** 일반 파일을 찾으세요.
2. 경로를 `/tmp/not_py.txt` 에 저장하세요.', '형태: `find <위치> -type f ! -name "<패턴>" > <파일>`
`!` 는 바로 뒤 조건을 뒤집습니다("아닌 것"). 쉘이 `!` 를 특별하게 해석하는 환경이 있으면 `\\!` 로 쓰기도 합니다.
확인: `cat /tmp/not_py.txt`', 'find /tmp/lab -type f ! -name "*.py" > /tmp/not_py.txt

# !  : 뒤에 오는 조건을 뒤집는다 ("~가 아닌")', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log"]', '["sh", "-c", "( [ -s /tmp/not_py.txt ] ) && ( [ \\"$(grep -cE \\"[.](txt|log)$\\" /tmp/not_py.txt)\\" -eq 4 ] ) && ( ! grep -q ''[.]py$'' /tmp/not_py.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/not_py.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/not_py.txt ]"]}, {"label": ".txt 와 .log 파일 4개가 들어 있다", "cmd": ["sh", "-c", "[ \\"$(grep -cE \\"[.](txt|log)$\\" /tmp/not_py.txt)\\" -eq 4 ]"]}, {"label": ".py 파일은 들어 있지 않다", "cmd": ["sh", "-c", "! grep -q ''[.]py$'' /tmp/not_py.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 11, '찾은 파일 각각에 명령 실행하기 (-exec)', '찾기만 하지 않고 **찾은 파일마다 명령을 실행**할 수 있습니다. `-exec` 입니다.

`/tmp/lab/logs` 의 로그 파일들은 줄 수가 다릅니다.

1. 이름이 `.log` 로 끝나는 파일을 찾아, 각 파일에 `wc -l`(줄 수 세기)을 실행하세요.
2. 결과를 `/tmp/log_lines.txt` 에 저장하세요.', '형태: `find <위치> -name "<패턴>" -exec <명령> {} \\; > <파일>`
`-exec` 뒤에 실행할 명령을 쓰고, `{}` 는 찾은 파일 이름이 들어갈 자리, `\\;` 는 명령의 끝을 뜻합니다. `wc -l <파일>` 은 줄 수와 파일 이름을 함께 출력합니다.
확인: `cat /tmp/log_lines.txt`', 'find /tmp/lab -name "*.log" -exec wc -l {} \\; > /tmp/log_lines.txt

# -exec 명령 {} \\; : 찾은 파일마다 명령을 실행 ({} 는 파일 이름 자리, \\; 는 끝)', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log"]', '["sh", "-c", "( [ -s /tmp/log_lines.txt ] ) && ( grep -q \\"^ *3 /tmp/lab/logs/app.log$\\" /tmp/log_lines.txt ) && ( grep -q \\"^ *2 /tmp/lab/logs/db.log$\\" /tmp/log_lines.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/log_lines.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/log_lines.txt ]"]}, {"label": "app.log 의 줄 수 3 이 기록됐다", "cmd": ["sh", "-c", "grep -q \\"^ *3 /tmp/lab/logs/app.log$\\" /tmp/log_lines.txt"]}, {"label": "db.log 의 줄 수 2 가 기록됐다", "cmd": ["sh", "-c", "grep -q \\"^ *2 /tmp/lab/logs/db.log$\\" /tmp/log_lines.txt"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 12, '찾은 파일을 안전하게 삭제하기 (-delete)', '임시 파일을 한꺼번에 지울 때 `find` 의 `-delete` 를 씁니다. **삭제는 되돌릴 수 없으니** 먼저 `-print`(또는 옵션 없이)로 무엇이 잡히는지 확인한 뒤 지우는 습관을 들이세요.

1. `/tmp/lab` 아래의 `.tmp` 파일을 모두 삭제하세요.
2. `.tmp` 가 아닌 파일은 그대로 남아 있어야 합니다.', '먼저 확인: `find /tmp/lab -name "*.tmp"` 로 무엇이 잡히는지 봅니다.
삭제: 같은 명령 끝에 `-delete` 를 붙입니다.
`-delete` 는 조건에 맞는 항목을 지웁니다. 조건 **뒤에** 써야 합니다(앞에 쓰면 모든 것이 지워질 수 있습니다).
확인: `find /tmp/lab -name "*.tmp"` 가 아무것도 안 나와야 합니다.', 'find /tmp/lab -name "*.tmp"           # 먼저 무엇이 잡히는지 확인
find /tmp/lab -name "*.tmp" -delete   # 확인한 뒤 삭제

# -delete : 조건에 맞는 항목을 지운다 (반드시 조건 뒤에 쓴다)', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log && touch /tmp/lab/a.tmp /tmp/lab/docs/b.tmp /tmp/lab/src/lib/c.tmp"]', '["sh", "-c", "( [ -z \\"$(find /tmp/lab -name \\"*.tmp\\")\\" ] ) && ( [ -f /tmp/lab/docs/readme.txt ] && [ -f /tmp/lab/src/main.py ] && [ -f /tmp/lab/logs/app.log ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": ".tmp 파일이 하나도 남아 있지 않다", "cmd": ["sh", "-c", "[ -z \\"$(find /tmp/lab -name \\"*.tmp\\")\\" ]"]}, {"label": "다른 파일(readme.txt, main.py, app.log)은 그대로 남아 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/docs/readme.txt ] && [ -f /tmp/lab/src/main.py ] && [ -f /tmp/lab/logs/app.log ]"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 13, 'find 결과를 파이프로 넘겨 줄 수 합계 구하기 (xargs)', '`find` 가 찾은 파일 **목록 전체를 다른 명령의 인자로** 넘길 때 `xargs` 를 씁니다.

`/tmp/lab` 에는 `.py` 파일이 두 개 있습니다.

1. 이름이 `.py` 로 끝나는 파일을 모두 찾으세요.
2. 그 파일들의 내용을 합쳐서 **전체 줄 수**를 세고, 숫자만 `/tmp/py_total.txt` 에 저장하세요.', '형태: `find <위치> -name "<패턴>" | xargs cat | wc -l > <파일>`
`|` 는 앞 명령의 출력을 뒤로 넘기고, `xargs <명령>` 은 넘어온 줄들을 그 명령의 인자로 바꿔 실행합니다(`xargs cat` 은 `cat 파일1 파일2 ...`). `wc -l` 은 줄 수를 셉니다.
확인: `cat /tmp/py_total.txt`', 'find /tmp/lab -name "*.py" | xargs cat | wc -l > /tmp/py_total.txt

# find ... : .py 파일 목록을 출력
# | xargs cat : 그 목록을 cat 의 인자로 바꿔 실행 (내용을 이어서 출력)
# | wc -l : 줄 수를 셈', '["sh", "-c", "mkdir -p /tmp/lab/docs /tmp/lab/src/lib /tmp/lab/logs && cd /tmp/lab && echo hello > docs/readme.txt && echo notes > docs/notes.txt && printf ''a\\\\nb\\\\nc\\\\n'' > src/main.py && printf ''x\\\\ny\\\\n'' > src/lib/util.py && printf ''a\\\\nb\\\\nc\\\\n'' > logs/app.log && printf ''x\\\\ny\\\\n'' > logs/db.log"]', '["sh", "-c", "( [ -s /tmp/py_total.txt ] ) && ( [ \\"$(tr -d \\"[:space:]\\" < /tmp/py_total.txt)\\" = 5 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/py_total.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/py_total.txt ]"]}, {"label": ".py 파일 두 개의 줄 수 합계 5 가 들어 있다", "cmd": ["sh", "-c", "[ \\"$(tr -d \\"[:space:]\\" < /tmp/py_total.txt)\\" = 5 ]"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks)
SELECT 44, 14, '여러 조건을 한꺼번에 만족하는 파일 찾기 (종합)', '서버 정리 작업입니다. `/tmp/proj` 에는 로그와 기타 파일이 섞여 있습니다. **네 가지 조건을 모두 만족하는** 파일만 지울 후보로 골라야 합니다.

1. 일반 **파일**이고
2. 이름이 **`.log`** 로 끝나며
3. 수정한 지 **7일보다 오래됐고**
4. 크기가 **1KB 보다 큰** 파일

이 조건에 맞는 파일의 경로를 `/tmp/cleanup.txt` 에 저장하세요 (지우지는 않습니다).', '조건을 여러 개 이어 쓰면 **모두 만족**하는 것만 나옵니다: `find <위치> -type f -name "<패턴>" -mtime +7 -size +1k > <파일>`
`-type f` 일반 파일, `-name` 이름, `-mtime +7` 7일보다 오래됨, `-size +1k` 1KB 보다 큼.
확인: `ls -l /tmp/proj/logs` 로 크기와 날짜를 비교해 보세요.', 'find /tmp/proj -type f -name "*.log" -mtime +7 -size +1k > /tmp/cleanup.txt

# -type f        : 일반 파일
# -name "*.log"  : 이름이 .log 로 끝남
# -mtime +7      : 7일보다 오래됨
# -size +1k      : 1KB 보다 큼
# 조건을 이어 쓰면 모두 만족하는 것만 나온다', '["sh", "-c", "mkdir -p /tmp/proj/logs && cd /tmp/proj && head -c 3000 /dev/zero > logs/a.log && head -c 5000 /dev/zero > logs/b.log && echo tiny > logs/c.log && head -c 5000 /dev/zero > logs/new.log && head -c 5000 /dev/zero > notes.txt && touch -d ''30 days ago'' logs/a.log logs/c.log notes.txt && touch -d ''20 days ago'' logs/b.log"]', '["sh", "-c", "( [ -s /tmp/cleanup.txt ] ) && ( grep -qx /tmp/proj/logs/a.log /tmp/cleanup.txt && grep -qx /tmp/proj/logs/b.log /tmp/cleanup.txt ) && ( ! grep -q c.log /tmp/cleanup.txt ) && ( ! grep -q new.log /tmp/cleanup.txt ) && ( ! grep -q notes.txt /tmp/cleanup.txt ) && ( [ \\"$(wc -l < /tmp/cleanup.txt)\\" -eq 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/cleanup.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/cleanup.txt ]"]}, {"label": "오래되고 큰 a.log, b.log 가 들어 있다", "cmd": ["sh", "-c", "grep -qx /tmp/proj/logs/a.log /tmp/cleanup.txt && grep -qx /tmp/proj/logs/b.log /tmp/cleanup.txt"]}, {"label": "너무 작은 c.log 는 들어 있지 않다 (1KB 이하)", "cmd": ["sh", "-c", "! grep -q c.log /tmp/cleanup.txt"]}, {"label": "최근 파일 new.log 는 들어 있지 않다 (7일 이내)", "cmd": ["sh", "-c", "! grep -q new.log /tmp/cleanup.txt"]}, {"label": ".log 가 아닌 notes.txt 는 들어 있지 않다", "cmd": ["sh", "-c", "! grep -q notes.txt /tmp/cleanup.txt"]}, {"label": "정확히 2개만 들어 있다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/cleanup.txt)\\" -eq 2 ]"]}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 44 AND order_index = 14);
