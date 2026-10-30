-- 기본기 사다리 3: 세트 47(도움말로 명령 완성하기). 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set47.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 47, '도움말로 명령 완성하기: --help 읽고 직접 찾기', '옵션을 외우는 것이 아니라 **도움말에서 찾아 쓰는 법**을 익힙니다. 정답 옵션은 알려 주지 않습니다. `명령 --help` 를 읽고, `| grep` 으로 필요한 줄만 골라 보며 명령을 스스로 완성해 보세요.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 47);
UPDATE quest_set SET display_order = 43, unit_id = (SELECT id FROM unit WHERE id = 2), icon = '📖' WHERE id = 47;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 1, '--help 의 사용법 줄 읽는 법 알기', '`cut --help` 의 맨 위에 `Usage: cut OPTION... [FILE]...` 이라고 나옵니다. 이 줄에서 `OPTION...` 과 `[FILE]...` 은 각각 무슨 뜻일까요?', '대괄호 `[ ]` 는 "생략해도 된다", 점 세 개 `...` 는 "여러 개 쓸 수 있다"를 뜻하는 표기입니다.', NULL, NULL, '[]', 'choice', '["`OPTION...` 옵션을 여러 개 쓸 수 있다, `[FILE]...` 파일은 생략할 수 있고 여러 개도 된다", "`OPTION...` 옵션은 반드시 하나, `[FILE]...` 파일은 반드시 하나", "`OPTION...` 은 생략할 수 있고, `[FILE]...` 은 반드시 있어야 한다", "둘 다 글자 그대로 입력해야 한다"]', 0, '사용법(Usage) 줄의 약속입니다. `[ ]` 는 **생략 가능**, `...` 은 **여러 개 가능**, 대문자 이름(`OPTION`, `FILE`)은 **그 자리에 실제 값을 넣으라**는 뜻입니다. 이 표기를 알면 처음 보는 명령의 도움말도 읽을 수 있습니다.', NULL, NULL, NULL, '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 2, '긴 도움말에서 필요한 줄만 찾는 방법 알기', '`sort --help` 는 수십 줄이라 화면이 넘칩니다. 그중 **"numeric"(숫자)** 이 들어 있는 줄만 보려면 어떻게 하면 좋을까요?', '도움말도 결국 화면에 출력되는 글입니다. 출력을 걸러 주는 명령에 파이프(`|`)로 넘겨 보세요.', NULL, NULL, '[]', 'choice', '["`sort --help | grep numeric`", "`sort numeric --help`", "`grep sort numeric`", "`sort --help > numeric`"]', 0, '도움말 출력을 `grep` 에 파이프로 넘기면 원하는 낱말이 있는 줄만 볼 수 있습니다. 앞에서 배운 `|` 의 좋은 사용처입니다. `man` 에서는 `/numeric` 을 입력하면 본문 안에서 검색하고, `n` 으로 다음 결과, `q` 로 종료합니다.', NULL, NULL, NULL, '[{"title": "man 사용법", "url": "https://man7.org/linux/man-pages/man1/man.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 3, '도움말을 보고 CSV 에서 둘째 열만 뽑기 (cut)', '`/tmp/data.csv` 는 쉼표로 열을 나눈 파일입니다.

name,age,city
kim,30,seoul
lee,25,busan

둘째 열(`age`)만 뽑아 `/tmp/ages.txt` 에 저장하세요. 어떤 옵션을 써야 할지는 **`cut --help` 를 읽고 직접 찾아보세요.**', '찾는 방법: `cut --help | grep -i delimiter` (열을 나누는 글자를 정하는 옵션) 와 `cut --help | grep -i field` (몇 번째 열을 뽑을지 정하는 옵션) 를 실행해 보세요. 옵션 뒤에 값을 붙이는 형태도 도움말에 예시가 있습니다.
확인: `cat /tmp/ages.txt`', 'cut -d, -f2 /tmp/data.csv > /tmp/ages.txt

# -d, : 열을 나누는 글자(delimiter)를 쉼표로
# -f2 : 둘째 열(field)만
# > 파일 : 결과를 저장', '["sh", "-c", "printf ''name,age,city\\\\nkim,30,seoul\\\\nlee,25,busan\\\\n'' > /tmp/data.csv"]', '["sh", "-c", "( [ -s /tmp/ages.txt ] ) && ( [ \\"$(head -n 1 /tmp/ages.txt)\\" = age ] ) && ( grep -qx 30 /tmp/ages.txt && grep -qx 25 /tmp/ages.txt ) && ( ! grep -qE \\"kim|lee|seoul|busan\\" /tmp/ages.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/ages.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/ages.txt ]"]}, {"label": "첫 줄이 age 이다", "cmd": ["sh", "-c", "[ \\"$(head -n 1 /tmp/ages.txt)\\" = age ]"]}, {"label": "나이 30 과 25 가 들어 있다", "cmd": ["sh", "-c", "grep -qx 30 /tmp/ages.txt && grep -qx 25 /tmp/ages.txt"]}, {"label": "이름이나 도시는 들어 있지 않다", "cmd": ["sh", "-c", "! grep -qE \\"kim|lee|seoul|busan\\" /tmp/ages.txt"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 4, '도움말을 보고 숫자를 크기 순으로 정렬하기 (sort)', '`/tmp/nums.txt` 에는 숫자가 한 줄에 하나씩 있습니다 (`2`, `9`, `10`, `100`). 이 숫자를 **크기가 큰 것부터(내림차순)** 정렬해 `/tmp/sorted.txt` 에 저장하세요. 그냥 정렬하면 글자 순서가 되어 `9` 가 `10` 보다 앞에 올 수 있다는 점에 주의하세요. 옵션은 **`sort --help` 에서 직접 찾아보세요.**', '찾는 방법: `sort --help | grep -i numeric` (글자가 아니라 숫자 크기로 비교하는 옵션) 와 `sort --help | grep -i reverse` (순서를 뒤집는 옵션) 를 실행해 보세요. 한 글자 옵션은 `-nr` 처럼 붙여 쓸 수 있습니다.
확인: `cat /tmp/sorted.txt`', 'sort -nr /tmp/nums.txt > /tmp/sorted.txt

# -n : 글자가 아니라 숫자 크기로 비교
# -r : 순서를 뒤집어 큰 것부터 (reverse)', '["sh", "-c", "printf ''2\\\\n9\\\\n10\\\\n100\\\\n'' > /tmp/nums.txt"]', '["sh", "-c", "( [ -s /tmp/sorted.txt ] ) && ( [ \\"$(head -n 1 /tmp/sorted.txt)\\" = 100 ] ) && ( [ \\"$(sed -n 2p /tmp/sorted.txt)\\" = 10 ] && [ \\"$(sed -n 3p /tmp/sorted.txt)\\" = 9 ] ) && ( [ \\"$(tail -n 1 /tmp/sorted.txt)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/sorted.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/sorted.txt ]"]}, {"label": "가장 큰 100 이 맨 위에 있다", "cmd": ["sh", "-c", "[ \\"$(head -n 1 /tmp/sorted.txt)\\" = 100 ]"]}, {"label": "숫자 크기 순서이다 (10 이 9 보다 앞)", "cmd": ["sh", "-c", "[ \\"$(sed -n 2p /tmp/sorted.txt)\\" = 10 ] && [ \\"$(sed -n 3p /tmp/sorted.txt)\\" = 9 ]"]}, {"label": "가장 작은 2 가 맨 아래에 있다", "cmd": ["sh", "-c", "[ \\"$(tail -n 1 /tmp/sorted.txt)\\" = 2 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 5, '도움말을 보고 파일의 앞부분 3줄만 저장하기 (head)', '`/tmp/words.txt` 에는 단어가 한 줄에 하나씩 5개 있습니다. **처음 3줄만** `/tmp/first3.txt` 에 저장하세요. 줄 수를 정하는 옵션은 **`head --help` 에서 직접 찾아보세요.**', '찾는 방법: `head --help | grep -i lines` 로 줄 수와 관련된 옵션을 찾습니다. 옵션 뒤에 숫자를 붙입니다.
확인: `cat /tmp/first3.txt`', 'head -n 3 /tmp/words.txt > /tmp/first3.txt

# -n 3 : 처음 3줄만 (lines)', '["sh", "-c", "printf ''apple\\\\nbanana\\\\ncherry\\\\ndate\\\\nelder\\\\n'' > /tmp/words.txt"]', '["sh", "-c", "( [ -s /tmp/first3.txt ] ) && ( [ \\"$(wc -l < /tmp/first3.txt)\\" -eq 3 ] ) && ( [ \\"$(paste -sd, /tmp/first3.txt)\\" = apple,banana,cherry ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/first3.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/first3.txt ]"]}, {"label": "정확히 3줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/first3.txt)\\" -eq 3 ]"]}, {"label": "apple, banana, cherry 순서이다", "cmd": ["sh", "-c", "[ \\"$(paste -sd, /tmp/first3.txt)\\" = apple,banana,cherry ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 6, '도움말을 보고 오늘 날짜를 2026-10-30 모양으로 저장하기 (date)', '`date` 명령은 기본으로 `Fri Oct 30 14:05:11 UTC 2026` 처럼 길게 출력합니다. 오늘 날짜를 **`연-월-일` 모양(예: `2026-10-30`)** 으로 `/tmp/today.txt` 에 저장하세요. 출력 형식을 정하는 방법은 **`date --help` 에서 직접 찾아보세요.**', '찾는 방법: `date --help | grep -i format` 으로 형식 지정에 관한 줄을 찾고, 아래쪽 `FORMAT controls the output` 부분의 `%Y`, `%m`, `%d` 설명을 읽어 보세요. 형식은 `+` 로 시작하는 인자로 줍니다.
확인: `cat /tmp/today.txt`', 'date +%Y-%m-%d > /tmp/today.txt

# +%Y-%m-%d : + 로 시작하면 출력 형식
#   %Y 네 자리 연도, %m 두 자리 월, %d 두 자리 일
# (같은 뜻으로 date +%F 도 된다)', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/today.txt ] ) && ( grep -qxE \\"[0-9]{4}-[0-9]{2}-[0-9]{2}\\" /tmp/today.txt ) && ( [ \\"$(cat /tmp/today.txt)\\" = \\"$(date +%Y-%m-%d)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/today.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/today.txt ]"]}, {"label": "연-월-일 모양이다 (예: 2026-10-30)", "cmd": ["sh", "-c", "grep -qxE \\"[0-9]{4}-[0-9]{2}-[0-9]{2}\\" /tmp/today.txt"]}, {"label": "오늘 날짜와 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/today.txt)\\" = \\"$(date +%Y-%m-%d)\\" ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 7, '도움말을 보고 파일을 큰 것부터 나열하기 (ls)', '`/tmp/sz` 폴더에 크기가 다른 파일 세 개(`small.dat`, `mid.dat`, `big.dat`)가 있습니다. **크기가 큰 파일부터** 이름만 한 줄씩 `/tmp/by_size.txt` 에 저장하세요. 정렬 방법은 **`ls --help` 에서 직접 찾아보세요.**', '찾는 방법: `ls --help | grep -i size` 로 크기와 관련된 옵션을 찾아 보세요. 정렬 기준을 바꾸는 옵션이 있습니다. 파이프나 파일로 출력하면 이름이 한 줄에 하나씩 나옵니다.
확인: `cat /tmp/by_size.txt`', 'ls -S /tmp/sz > /tmp/by_size.txt

# -S : 파일 크기가 큰 것부터 정렬 (Size)', '["sh", "-c", "mkdir -p /tmp/sz && head -c 100 /dev/zero > /tmp/sz/small.dat && head -c 5000 /dev/zero > /tmp/sz/mid.dat && head -c 90000 /dev/zero > /tmp/sz/big.dat"]', '["sh", "-c", "( [ -s /tmp/by_size.txt ] ) && ( [ \\"$(head -n 1 /tmp/by_size.txt)\\" = big.dat ] ) && ( [ \\"$(paste -sd, /tmp/by_size.txt)\\" = big.dat,mid.dat,small.dat ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/by_size.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/by_size.txt ]"]}, {"label": "가장 큰 big.dat 이 맨 위에 있다", "cmd": ["sh", "-c", "[ \\"$(head -n 1 /tmp/by_size.txt)\\" = big.dat ]"]}, {"label": "big.dat, mid.dat, small.dat 순서이다", "cmd": ["sh", "-c", "[ \\"$(paste -sd, /tmp/by_size.txt)\\" = big.dat,mid.dat,small.dat ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 47, 8, '도움말을 보고 로그에서 줄 수만 세기 (grep)', '`/tmp/access.log` 에 접속 기록이 있습니다. 상태 코드 `404` 가 들어 있는 줄이 **몇 줄인지 숫자만** `/tmp/count404.txt` 에 저장하세요. 줄을 출력하지 않고 **개수만** 세는 방법은 **`grep --help` 에서 직접 찾아보세요.**', '찾는 방법: `grep --help | grep -i count` 로 개수를 세는 옵션을 찾으세요. 그 옵션은 맞는 줄을 출력하는 대신 줄 수만 출력합니다.
확인: `cat /tmp/count404.txt`', 'grep -c 404 /tmp/access.log > /tmp/count404.txt

# -c : 맞는 줄을 출력하지 않고 줄 수(count)만 출력', '["sh", "-c", "printf ''GET / 200\\\\nGET /a 404\\\\nGET /b 404\\\\nGET /c 500\\\\nGET /d 404\\\\n'' > /tmp/access.log"]', '["sh", "-c", "( [ -s /tmp/count404.txt ] ) && ( [ \\"$(tr -d \\"[:space:]\\" < /tmp/count404.txt)\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/count404.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/count404.txt ]"]}, {"label": "개수 3 만 들어 있다", "cmd": ["sh", "-c", "[ \\"$(tr -d \\"[:space:]\\" < /tmp/count404.txt)\\" = 3 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 47 AND order_index = 8);
