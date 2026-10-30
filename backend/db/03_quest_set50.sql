-- 세트 50: 따옴표·변수·치환 익히기: 쉘이 먼저 해석하는 것들
-- 기본기 사다리(docs/specs/spec_foundations_ladder.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (50, 1, '작은따옴표와 큰따옴표의 차이 알기', '`NAME=kim` 을 지정한 뒤 `echo ''hello $NAME''` 와 `echo "hello $NAME"` 를 각각 실행하면 무엇이 출력될까요?', '`$NAME` 을 값으로 바꾸는 일(치환)은 쉘이 합니다. 따옴표 종류에 따라 쉘이 치환을 하기도, 안 하기도 합니다.', NULL, NULL, '[]', 'choice', '["작은따옴표는 `hello $NAME` 그대로, 큰따옴표는 `hello kim`", "둘 다 `hello kim`", "작은따옴표는 `hello kim`, 큰따옴표는 `hello $NAME` 그대로", "둘 다 오류가 난다"]', 0, '**작은따옴표 `'' ''`** 안은 쉘이 아무것도 해석하지 않고 글자 그대로 넘깁니다. **큰따옴표 `" "`** 안에서는 `$변수` 와 `$(명령)` 같은 치환은 하되 공백은 한 덩어리로 묶습니다. 값이 필요하면 큰따옴표, 글자 그대로가 필요하면 작은따옴표를 씁니다.', NULL, NULL, NULL, NULL),
  (50, 2, '변수를 지정할 때 = 양옆에 공백을 두면 안 되는 이유 알기', '`NAME = kim` 이라고 입력하면 `NAME: command not found` 오류가 납니다. 올바른 지정 방법과 이유는 무엇일까요?', '쉘은 맨 앞 낱말을 "실행할 명령"으로 봅니다.', NULL, NULL, '[]', 'choice', '["`NAME=kim` 처럼 붙여 쓴다. 띄어 쓰면 `NAME` 이 명령 이름으로 해석되기 때문이다", "`NAME := kim` 으로 쓴다", "`set NAME kim` 으로만 지정할 수 있다", "변수는 지정할 수 없고 읽기만 된다"]', 0, '쉘 변수 지정은 `이름=값` 을 **붙여** 씁니다. `NAME = kim` 은 `NAME` 이라는 명령에 인자 `=`, `kim` 을 준 것으로 읽혀 "명령을 찾을 수 없다"가 됩니다. 값에 공백이 있으면 `NAME="kim lee"` 처럼 따옴표로 묶습니다.', NULL, NULL, NULL, NULL),
  (50, 3, '$(명령) 이 하는 일 알기', '`echo "today is $(date +%F)"` 에서 `$(date +%F)` 는 어떻게 처리될까요?', '`$( )` 안의 명령이 먼저 실행되고, 그 출력이 그 자리에 들어갑니다.', NULL, NULL, '[]', 'choice', '["`date +%F` 가 먼저 실행되고, 그 출력(오늘 날짜)이 그 자리에 들어간다", "`$(date +%F)` 라는 글자가 그대로 출력된다", "`date` 가 나중에 한 번 더 실행된다", "오류가 난다"]', 0, '`$(명령)` 을 **명령 치환**이라고 합니다. 쉘이 안쪽 명령을 먼저 실행해 출력으로 바꿔 넣은 뒤 바깥 명령을 실행합니다. 그래서 `today is 2026-10-30` 처럼 나옵니다. 작은따옴표 안에서는 치환되지 않습니다.', NULL, NULL, NULL, NULL),
  (50, 4, '변수에 값을 넣고 꺼내 쓰기', '변수 `NAME` 에 `lee` 를 저장한 뒤, 그 변수를 사용해 `hello lee` 라는 한 줄을 `/tmp/hello.txt` 에 저장하세요.', '`NAME=lee` 처럼 붙여 쓰고, 꺼낼 때는 `$NAME` 입니다. 값을 문장 속에 넣으려면 큰따옴표로 감쌉니다.
확인: `cat /tmp/hello.txt`', 'NAME=lee
echo "hello $NAME" > /tmp/hello.txt

# NAME=lee : 변수 지정 (= 양옆 공백 없음)
# "hello $NAME" : 큰따옴표 안에서는 $NAME 이 lee 로 바뀐다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/hello.txt ] ) && ( [ \\"$(cat /tmp/hello.txt)\\" = ''hello lee'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/hello.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/hello.txt ]"]}, {"label": "내용이 `hello lee` 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/hello.txt)\\" = ''hello lee'' ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 5, '치환 없이 글자 그대로 저장하기 (작은따옴표)', '`$HOME` 이라는 **글자 그대로**(값으로 바뀌지 않게) 한 줄을 `/tmp/literal.txt` 에 저장하세요.', '값으로 바뀌면 안 되므로, 쉘이 아무것도 해석하지 않게 하는 따옴표를 쓰세요.
확인: `cat /tmp/literal.txt` (`$HOME` 이라고 보여야 합니다)', 'echo ''$HOME'' > /tmp/literal.txt

# 작은따옴표 안은 글자 그대로', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/literal.txt ] ) && ( [ \\"$(cat /tmp/literal.txt)\\" = ''$HOME'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/literal.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/literal.txt ]"]}, {"label": "내용이 글자 그대로 `$HOME` 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/literal.txt)\\" = ''$HOME'' ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 6, '변수 값을 꺼내서 저장하기 (큰따옴표)', '이번에는 반대로, 환경 변수 `HOME` 의 **값**(홈 디렉터리 경로)을 `/tmp/home_value.txt` 에 저장하세요.', '변수 이름 앞에 `$` 를 붙이면 값으로 바뀝니다. 앞 문제와 달리 치환이 일어나게 하세요.
확인: `cat /tmp/home_value.txt` (`/root` 같은 경로가 보여야 합니다)', 'echo "$HOME" > /tmp/home_value.txt

# 큰따옴표(또는 따옴표 없이) : $HOME 이 값으로 바뀐다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/home_value.txt ] ) && ( [ \\"$(cat /tmp/home_value.txt)\\" = \\"$HOME\\" ] ) && ( ! grep -q \\"[$]\\" /tmp/home_value.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/home_value.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/home_value.txt ]"]}, {"label": "내용이 HOME 값(경로)이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/home_value.txt)\\" = \\"$HOME\\" ]"]}, {"label": "`$` 글자가 남아 있지 않다", "cmd": ["sh", "-c", "! grep -q \\"[$]\\" /tmp/home_value.txt"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 7, '명령 결과를 문장 속에 넣기 ($( ))', '`/tmp/data` 폴더에는 파일이 여러 개 있습니다. `files: 3` 처럼 **파일 개수를 직접 세어 문장에 넣어** `/tmp/count_msg.txt` 에 저장하세요. 숫자를 손으로 적지 말고 명령으로 구하세요.', '파일 개수는 `ls /tmp/data | wc -l` 로 셉니다. 그 명령의 출력을 문장 속에 넣으려면 `$( )` 를 큰따옴표 안에 씁니다.
확인: `cat /tmp/count_msg.txt`', 'echo "files: $(ls /tmp/data | wc -l)" > /tmp/count_msg.txt

# $(...) : 안쪽 명령을 실행한 출력으로 바뀐다', '["sh", "-c", "mkdir -p /tmp/data && touch /tmp/data/a /tmp/data/b /tmp/data/c"]', '["sh", "-c", "( [ -s /tmp/count_msg.txt ] ) && ( [ \\"$(cat /tmp/count_msg.txt)\\" = ''files: 3'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/count_msg.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/count_msg.txt ]"]}, {"label": "내용이 `files: 3` 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/count_msg.txt)\\" = ''files: 3'' ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 8, '공백이 든 이름은 따옴표로 묶기', '`/tmp` 아래에 이름이 **`my docs`** (가운데 공백 포함) 인 폴더 하나를 만드세요.', '따옴표 없이 `mkdir /tmp/my docs` 를 치면 쉘이 공백에서 나눠 `my`, `docs` 폴더 두 개를 만듭니다. 한 이름이 되도록 묶으세요.
확인: `ls /tmp`', 'mkdir "/tmp/my docs"

# 따옴표로 묶으면 공백이 든 한 덩어리가 하나의 인자가 된다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -d \\"/tmp/my docs\\" ] ) && ( [ ! -e /tmp/my ] && [ ! -e /tmp/docs ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "`my docs` 폴더가 있다", "cmd": ["sh", "-c", "[ -d \\"/tmp/my docs\\" ]"]}, {"label": "`my` 나 `docs` 폴더가 따로 만들어지지 않았다", "cmd": ["sh", "-c", "[ ! -e /tmp/my ] && [ ! -e /tmp/docs ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 9, '$ 가 든 글자를 그대로 쓰기', '가격 안내 문장 `Price: $5` 를 **그대로** `/tmp/price.txt` 에 저장하세요. (쉘이 `$5` 를 값으로 바꾸면 `Price: ` 만 남습니다)', '작은따옴표로 감싸거나, `$` 앞에 역슬래시 `\\` 를 붙여 "이 글자는 해석하지 마"라고 알려 줄 수 있습니다.
확인: `cat /tmp/price.txt`', 'echo ''Price: $5'' > /tmp/price.txt

# 또는 echo "Price: \\$5" > /tmp/price.txt (\\ 는 다음 글자의 특수 의미를 없앤다)', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/price.txt ] ) && ( [ \\"$(cat /tmp/price.txt)\\" = ''Price: $5'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/price.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/price.txt ]"]}, {"label": "내용이 `Price: $5` 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/price.txt)\\" = ''Price: $5'' ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 10, '변수를 자식 프로그램에 넘기기 (export)', '변수 `APP_ENV` 에 `prod` 를 저장하고, **새로 실행한 쉘**(`bash -c ''echo $APP_ENV''`)에서도 그 값이 보이게 하여, 그 출력을 `/tmp/env.txt` 에 저장하세요.', '그냥 `APP_ENV=prod` 만 하면 새로 실행한 프로그램에는 전달되지 않아 빈 줄이 나옵니다. 자식 프로그램에도 보이게 하는 명령이 있습니다. (환경 변수로 만들기)
확인: `cat /tmp/env.txt` (`prod` 가 보여야 합니다)', 'export APP_ENV=prod
bash -c ''echo $APP_ENV'' > /tmp/env.txt

# export : 변수를 환경 변수로 만들어 자식 프로그램에도 전달
# 작은따옴표 : $APP_ENV 는 바깥 쉘이 아니라 안쪽 bash 가 해석', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/env.txt ] ) && ( [ \\"$(cat /tmp/env.txt)\\" = ''prod'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/env.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/env.txt ]"]}, {"label": "내용이 `prod` 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/env.txt)\\" = ''prod'' ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]'),
  (50, 11, '합쳐서 쓰기: 호스트 이름과 파일 개수 한 줄 보고', '`/tmp/data` 폴더의 파일 개수와 이 컴퓨터의 이름(호스트 이름)을 `host=이름 files=개수` 형태의 한 줄로 `/tmp/report.txt` 에 저장하세요. 이름과 개수는 모두 **명령으로 구해서** 넣으세요.', '호스트 이름은 `hostname`, 개수는 `ls /tmp/data | wc -l` 입니다. 둘 다 `$( )` 로 문장에 넣고, 전체는 큰따옴표로 감쌉니다.
확인: `cat /tmp/report.txt`', 'echo "host=$(hostname) files=$(ls /tmp/data | wc -l)" > /tmp/report.txt

# $(hostname) : 호스트 이름
# $(ls ... | wc -l) : 파일 개수', '["sh", "-c", "mkdir -p /tmp/data && touch /tmp/data/a /tmp/data/b /tmp/data/c /tmp/data/d"]', '["sh", "-c", "( [ -s /tmp/report.txt ] ) && ( [ \\"$(cat /tmp/report.txt)\\" = \\"host=$(hostname) files=4\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/report.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/report.txt ]"]}, {"label": "내용이 `host=<이 컴퓨터 이름> files=4` 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/report.txt)\\" = \\"host=$(hostname) files=4\\" ]"]}]', '[{"title": "GNU Bash 매뉴얼", "url": "https://www.gnu.org/software/bash/manual/bash.html"}]');
