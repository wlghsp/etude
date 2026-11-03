-- 리눅스 세트 197. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set197.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 197, '쉘 스크립트 인자와 상태: "$@", shift, getopts, set -e·-u, pipefail, PIPESTATUS, [[ ]], 산술, read', '쉘 스크립트가 인자와 종료 상태를 다루는 동작을 한 개념씩 반복합니다. "$@" 와 "$*" 와 따옴표 없는 $@ 의 차이, shift, getopts 의 옵션 문자열과 OPTARG·OPTIND, 오류 처리와 앞에 붙이는 콜론, 옵션이 멈추는 곳과 --, set -e 가 멈추지 않는 경우, set -u 와 기본값, pipefail 과 PIPESTATUS 를 바로 읽어야 하는 이유, 파이프 안의 while 이 만든 서브쉘과 프로세스 치환, [ ] 와 [[ ]] 의 빈 변수 차이, 산술의 8진수와 10# 접두어, read 의 필드 나누기, mapfile -t, bash -n·-x 와 command -v 를 짧은 객관식·빈칸·순서 문제로 익히고, 옵션과 인자 처리하기, 스크립트 점검하기, 파이프 실패 잡기, 백그라운드 작업 기다리기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 197);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🪛' WHERE id = 197;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 1, '"$@" 와 "$*" 의 차이', '인자 `"a b" c` 로 실행한 스크립트에서 `for x in "$@"` 와 `for x in "$*"` 는 각각 몇 번 반복할까요?', '인자마다 따로인지, 하나로 이어 붙였는지 봐요.', NULL, NULL, '[]', 'choice', '["둘 다 2번 반복한다", "`\\"$@\\"` 는 1번, `\\"$*\\"` 는 2번 반복한다", "`\\"$@\\"` 는 인자마다 한 번씩 2번(`a b`, `c`), `\\"$*\\"` 는 모두 이어 붙인 하나(`a b c`)로 1번 반복한다", "`\\"$@\\"` 는 3번 반복한다"]', 2, '`IFS=,` 로 바꾸면 `"$*"` 는 첫 글자 `,` 로 이어 붙여 `a b,c` 가 되고 `"$@"` 는 영향이 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 2, '따옴표 없는 $@', '인자 `"a b" c` 로 실행한 스크립트에서 따옴표 없이 `for x in $@` 로 반복하면 몇 번 반복할까요?', '쉘이 공백으로 다시 쪼개요.', NULL, NULL, '[]', 'choice', '["2번 반복한다", "공백이 든 인자 `a b` 가 다시 `a` 와 `b` 로 쪼개져 3번(`a`, `b`, `c`) 반복한다", "1번 반복한다", "따옴표가 없으면 오류가 난다"]', 1, '공백이 든 인자를 그대로 넘기려면 항상 `"$@"` 처럼 따옴표로 감쌉니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 3, 'shift 로 인자 밀기', '스크립트의 인자가 `a b c d` 일 때 `shift` 를 한 번 하고, 이어서 `shift 2` 를 하면 `$#` 와 `$1` 은 어떻게 될까요?', '앞에서부터 버려져요.', NULL, NULL, '[]', 'choice', '["`shift` 뒤에는 `$#` 가 3, `$1` 이 `b` 이고, 이어서 `shift 2` 뒤에는 `$#` 가 1, `$1` 이 `d` 가 된다", "`shift` 뒤에도 `$#` 는 4 이고 `$1` 만 `b` 가 된다", "`shift 2` 뒤에는 `$#` 가 2 이고 `$1` 은 `c` 이다", "`shift` 는 마지막 인자를 지운다"]', 0, '인자가 없을 때 `shift 5` 처럼 더 많이 밀면 종료 코드 1 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 4, 'getopts 문자열과 OPTARG·OPTIND', '`while getopts "ab:" o` 루프가 `-a -b val file1 file2` 를 처리합니다. `b` 를 처리할 때 `OPTARG` 와 루프가 끝난 뒤 `OPTIND` 는 무엇일까요?', '콜론이 붙은 옵션만 값을 받아요.', NULL, NULL, '[]', 'choice', '["`a` 가 값을 받아 `OPTARG` 는 `-b` 이고 `OPTIND` 는 2 이다", "`OPTIND` 는 옵션 개수인 2 이다", "`-bval` 처럼 붙여 쓰면 `OPTARG` 가 비어 있다", "`b` 뒤의 `:` 때문에 `-b` 는 값을 받아 `OPTARG` 가 `val` 이 되고, 루프 뒤 `OPTIND` 는 4 라서 `shift $((OPTIND-1))` 을 하면 `file1 file2` 만 남는다"]', 3, '`-ab val` 처럼 옵션을 붙여 써도 `OPTARG` 는 `val` 이고, `-bval` 도 `OPTARG` 가 `val` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 5, 'getopts 의 오류 처리', '`getopts "ab:" o` 에 알 수 없는 옵션 `-z` 나 값이 없는 `-b` 가 들어오면 어떻게 될까요? 문자열 앞에 `:` 를 붙인 `":ab:"` 이면요?', '메시지를 쉘이 내는지, 스크립트가 직접 처리하는지 봐요.', NULL, NULL, '[]', 'choice', '["두 경우 모두 스크립트가 즉시 종료된다", "`:` 를 앞에 붙이면 모든 오류가 `?` 로만 온다", "`ab:` 는 `illegal option -- z`, `option requires an argument -- b` 메시지를 내고 `o` 가 `?` 가 된다. `:ab:` 는 메시지가 없고 알 수 없는 옵션은 `?`, 값 없는 옵션은 `:` 로 오며 `OPTARG` 에 그 옵션 문자가 든다", "값 없는 `-b` 는 `OPTARG` 가 빈 채로 정상 처리된다"]', 2, '`case` 에서 `\\?)` 와 `:)` 를 나눠 두면 오류 안내를 직접 만들 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 6, 'getopts 가 멈추는 곳', '`getopts "ab:" o` 루프가 `go.sh file1 -a` 와 `go.sh -a -- -b x` 를 처리하면 각각 어떻게 될까요?', '옵션은 앞쪽에만 올 수 있어요.', NULL, NULL, '[]', 'choice', '["앞은 `-a` 도 옵션으로 처리한다", "앞은 첫 인자 `file1` 이 옵션이 아니어서 바로 멈추고 `-a` 는 처리되지 않으며 `OPTIND` 는 1 이다. 뒤는 `--` 에서 옵션이 끝나 `-b` 는 옵션이 아니라 남는 인자 `-b x` 가 된다", "`getopts` 는 순서와 상관없이 모든 옵션을 처리한다", "뒤는 `--` 뒤의 `-b` 도 옵션으로 처리한다"]', 1, '그래서 옵션은 파일 이름보다 앞에 쓰는 것이 규칙입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 7, 'set -e 가 멈추지 않는 경우', '`set -e` 를 켠 스크립트에서 `false` 를 단독으로 실행하면 어떻게 될까요? `if false`, `false || echo handled`, `false && echo x` 는요?', '조건으로 쓰인 실패는 검사하는 중이에요.', NULL, NULL, '[]', 'choice', '["`false` 단독은 스크립트가 종료 코드 1 로 멈추지만, `if` 조건, `||`·`&&` 의 앞쪽 같은 조건 안의 실패는 멈추지 않고 다음 줄로 간다", "`if false` 도 항상 스크립트를 종료시킨다", "`false || echo handled` 는 `handled` 를 출력하기 전에 종료된다", "`set -e` 는 `false` 단독 실행도 무시한다"]', 0, '`false | true` 처럼 파이프 중간의 실패도 `set -e` 로는 멈추지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 8, 'set -u 와 기본값', '`set -u` 를 켠 상태에서 정의하지 않은 변수로 `echo "$nope"` 와 `echo "${nope:-dflt}"` 를 하면 각각 어떻게 될까요?', '정의되지 않은 변수를 오류로 만드는 옵션이에요.', NULL, NULL, '[]', 'choice', '["앞은 빈 문자열을 출력하고 계속하며 뒤는 오류가 난다", "둘 다 `dflt` 를 출력한다", "둘 다 `unbound variable` 오류가 난다", "앞은 `nope: unbound variable` 오류로 스크립트가 멈추고, 뒤는 기본값 `dflt` 를 출력한다. `set -u` 가 없으면 앞은 빈 문자열을 출력하고 계속한다"]', 3, '오타가 난 변수 이름이 빈 값으로 지나가 `rm -rf "$DIR/"` 같은 명령이 위험해지는 것을 막아 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 9, 'PIPESTATUS 읽기', '`false | true | false` 를 실행한 직후 `echo "${PIPESTATUS[*]}"` 는 무엇을 출력할까요? 설정 없이 `false | true` 만 실행했을 때 `$?` 는요?', '파이프의 단계마다 종료 코드가 남아요.', NULL, NULL, '[]', 'choice', '["`1` 만 출력하고 `false | true` 의 `$?` 도 1 이다", "`0 0 0` 을 출력한다", "`1 0 1` 을 출력한다. `false | true` 의 `$?` 는 마지막 명령 `true` 의 종료 코드인 0 이다", "`1 0 1` 을 출력하고 `false | true` 의 `$?` 는 1 이다"]', 2, '`set -o pipefail` 을 켜면 `false | true` 의 `$?` 는 1 이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 10, 'PIPESTATUS 는 바로 읽기', '`false | true; echo "$?"; echo "${PIPESTATUS[*]}"` 는 무엇을 출력할까요?', '첫 `echo` 가 새 명령이에요.', NULL, NULL, '[]', 'choice', '["`0` 과 `1 0` 을 출력한다", "`0` 과 `0` 을 출력한다. 첫 `echo` 가 새 명령이라 `PIPESTATUS` 가 그 `echo` 하나의 상태로 바뀌어 버린다", "`1` 과 `1 0` 을 출력한다", "`1` 과 `0` 을 출력한다"]', 1, '필요하면 파이프 직후에 `st=("${PIPESTATUS[@]}")` 처럼 배열로 복사해 둡니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 11, '파이프 안의 while 과 변수', '`n=0` 에서 시작해 `printf ''a\\nb\\nc\\n'' | while read -r l; do n=$((n+1)); done` 뒤의 `n` 과, `while ...; done < <(printf ''a\\nb\\nc\\n'')` 뒤의 `n` 은 각각 얼마일까요?', '파이프 오른쪽은 별도의 서브쉘에서 돌아요.', NULL, NULL, '[]', 'choice', '["앞은 서브쉘에서 올린 값이 사라져 `n` 이 0 이고, 뒤는 현재 쉘에서 돌아 `n` 이 3 이다. `<<<` 로 읽어도 3 이다", "앞도 3 이다", "앞은 3, 뒤는 0 이다", "둘 다 0 이다"]', 0, '프로세스 치환 `<(명령)` 은 `/dev/fd/번호` 같은 경로로 바뀌어 파일처럼 읽힙니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 12, '[ ] 와 [[ ]] 의 빈 변수', '`x=` (빈 값)일 때 `[ $x = a ]`, `[ "$x" = a ]`, `[[ $x = a ]]` 는 각각 어떻게 될까요?', '따옴표 없는 변수는 사라질 수 있어요.', NULL, NULL, '[]', 'choice', '["셋 모두 오류 없이 거짓이다", "`[[ $x = a ]]` 만 오류가 난다", "`[ \\"$x\\" = a ]` 는 종료 코드 2 이다", "`[ $x = a ]` 는 `unary operator expected` 오류와 종료 코드 2 이고, 나머지 둘은 오류 없이 거짓(종료 코드 1)이다"]', 3, '`x="a b"` 일 때 `[ $x = a ]` 는 `too many arguments` 오류이고 `[[ $x = "a b" ]]` 는 참입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 13, '산술의 진법', '`echo $((010))`, `echo $((10#010))`, `echo $((08))` 은 각각 무엇을 출력할까요?', '앞에 0 이 붙으면 8진수로 봐요.', NULL, NULL, '[]', 'choice', '["`10`, `10`, `8` 을 출력한다", "`8`, `8`, `8` 을 출력한다", "`8`, `10` 을 출력하고 `$((08))` 은 `value too great for base` 오류가 난다. `10#` 를 붙이면 10진수로 읽는다", "`10`, `10` 을 출력하고 `$((08))` 은 `8` 이다"]', 2, '`$((0x1f))` 는 16진수라 31 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 14, 'read 의 필드 나누기', '`read a b <<< "x y z"` 와 `IFS=, read -r a b <<< "1,2,3"` 에서 `b` 는 각각 무엇일까요?', '변수보다 필드가 많으면 마지막 변수가 나머지를 가져요.', NULL, NULL, '[]', 'choice', '["앞은 `y`, 뒤는 `2` 이다", "앞은 `y z`, 뒤는 `2,3` 이다. 마지막 변수가 남은 부분을 모두 받는다", "앞은 `y z`, 뒤는 `2` 이다", "앞은 `y`, 뒤는 `2,3` 이다"]', 1, '`read -r` 은 백슬래시를 그대로 두고, `-r` 이 없으면 `back\\slash` 가 `backslash` 가 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 15, '공백이 든 인자를 그대로 넘기기', '인자에 공백이 있어도 인자마다 하나씩 그대로 반복하도록 알맞은 표현을 채우세요.', '따옴표로 감싼 "모든 인자" 예요.', NULL, NULL, '[]', 'fill', '["\\"$@\\"", "$@", "\\"$*\\"", "$#"]', NULL, '`$@` 처럼 따옴표가 없으면 공백에서 다시 쪼개집니다.', '[0]', 'for f in {0}; do echo "$f"; done', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 16, '인자 개수', '스크립트에 넘어온 인자의 개수를 출력하는 특수 변수를 채우세요.', '"number" 를 뜻하는 기호예요.', NULL, NULL, '[]', 'fill', '["$#", "$@", "$$", "$?"]', NULL, '`bash a.sh x y z` 이면 3 입니다.', '[0]', 'echo {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 17, '백그라운드 작업 기다리기', '방금 백그라운드로 보낸 작업의 PID 를 가리키는 특수 변수를 채우세요.', '느낌표 모양이에요.', NULL, NULL, '[]', 'fill', '["$!", "$$", "$?", "$0"]', NULL, '`wait` 는 그 작업의 종료 코드를 `$?` 로 남깁니다.', '[0]', 'sleep 1 & wait {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 18, '옵션 문자열', '`-a`(값 없음)와 `-b 값`(값을 받음)을 받도록 `getopts` 의 옵션 문자열을 채우세요.', '값을 받는 옵션 뒤에 콜론을 붙여요.', NULL, NULL, '[]', 'fill', '["\\"ab:\\"", "\\"a:b\\"", "\\"-ab\\"", "\\"a,b\\""]', NULL, '`"a:b"` 는 반대로 `-a` 가 값을 받습니다.', '[0]', 'while getopts {0} opt; do :; done', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 19, '파이프의 실패를 잡기', '파이프라인의 어느 단계가 실패해도 전체 종료 코드가 실패가 되도록 옵션 이름을 채우세요.', '"pipe" 와 "fail" 을 합친 이름이에요.', NULL, NULL, '[]', 'fill', '["pipefail", "pipeerr", "failpipe", "pipestatus"]', NULL, '`false | true` 의 `$?` 가 1 이 됩니다.', '[0]', 'set -o {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 20, '단계별 종료 코드', '파이프라인 각 단계의 종료 코드를 담은 배열 전체를 출력하도록 채우세요.', '"파이프의 상태" 를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["\\"${PIPESTATUS[*]}\\"", "\\"$PIPE\\"", "\\"$?[*]\\"", "\\"${PIPESTAT[*]}\\""]', NULL, '`1 0 1` 이 출력됩니다.', '[0]', 'false | true | false; echo {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 21, '출력을 파일처럼 비교', '정렬한 결과를 임시 파일 없이 파일처럼 `diff` 에 넘기도록 알맞은 표현을 채우세요.', '소괄호 앞에 꺾쇠를 붙여요.', NULL, NULL, '[]', 'fill', '["<(sort f2)", "$(sort f2)", "(sort f2)", ">(sort f2)"]', NULL, '`$(sort f2)` 는 출력 내용이 인자로 들어가 파일 이름이 되지 못합니다.', '[0]', 'diff <(sort f1) {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 22, '10진수로 읽기', '앞에 0 이 붙은 `08` 을 10진수로 읽어 `9` 가 나오게 접두어를 채우세요.', '진법을 # 앞에 적어요.', NULL, NULL, '[]', 'fill', '["10#", "0x", "d#", "base10:"]', NULL, '접두어가 없으면 `08` 은 8진수 오류가 납니다.', '[0]', 'echo $(( {0}08 + 1 ))', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 23, '줄 끝 개행 없이 배열에 담기', '파일의 각 줄을 개행 문자 없이 배열 원소로 담도록 `mapfile` 옵션을 채우세요.', '"trim" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-s", "-n", "-O"]', NULL, '`-t` 가 없으면 각 원소 끝에 개행이 남습니다.', '[0]', 'mapfile {0} lines < file.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 24, '문법만 검사', '스크립트를 실행하지 않고 문법만 검사하는 `bash` 옵션을 채우세요.', '"no execution" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-c", "-x", "-e"]', NULL, '문법 오류가 있으면 `unexpected end of file` 같은 메시지와 종료 코드 2 입니다.', '[0]', 'bash {0} script.sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 25, '명령 경로만 확인', '명령이 있으면 경로나 이름을 출력하고 없으면 조용히 실패(종료 코드 1)하는 `command` 옵션을 채우세요.', '"v" 한 글자예요.', NULL, NULL, '[]', 'fill', '["-v", "-e", "-f", "-w"]', NULL, '`command -v ls` 는 `/usr/bin/ls` 를 출력합니다.', '[0]', 'command {0} ls', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 26, '옵션과 인자 처리하기', '`-v` 옵션과 파일 인자를 받는 스크립트의 처리 순서입니다. 순서에 맞게 놓아 보세요.', '옵션 읽기 → 옵션 버리기 → 검사 → 반복 순서예요.', NULL, NULL, '[]', 'order', '["`while getopts \\"v\\" o; do ...; done` 으로 옵션을 읽는다", "`shift $((OPTIND-1))` 로 옵션을 버리고 파일 인자만 남긴다", "`[ \\"$#\\" -ge 1 ] || { echo usage; exit 2; }` 로 남은 인자가 있는지 검사한다", "`for f in \\"$@\\"; do ...; done` 으로 파일을 하나씩 처리한다"]', NULL, '`getopts` 는 첫 비옵션 인자에서 멈추므로 `shift` 뒤에는 파일 인자만 남습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 27, '스크립트 점검하기', '스크립트가 이상하게 동작할 때 점검하는 순서입니다. 순서에 맞게 놓아 보세요.', '문법 → 실행 → 추적 → 재검사 순서예요.', NULL, NULL, '[]', 'order', '["`bash -n script.sh` 로 실행하지 않고 문법을 검사한다", "`bash script.sh; echo $?` 로 실행하고 종료 코드를 확인한다", "`bash -x script.sh` 로 실행되는 명령을 하나씩 추적한다", "문제의 줄을 고친 뒤 `bash -n script.sh` 로 다시 검사한다"]', NULL, '`-x` 는 `+ x=1` 처럼 실행하는 명령 앞에 `+` 를 붙여 보여 줍니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 28, '파이프 실패 잡기', '`printf ''a\\n'' | grep zzz | sort | head -1` 에서 실패한 단계를 찾고 잡는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 복사 → 확인 → 설정 순서예요.', NULL, NULL, '[]', 'order', '["파이프라인을 실행한다. 마지막 `head` 가 성공해 `$?` 는 0 이다", "`st=(\\"${PIPESTATUS[@]}\\")` 로 단계별 종료 코드를 바로 복사한다", "`echo \\"${st[*]}\\"` 로 `0 1 0 0` 을 보고 두 번째 단계 `grep` 이 실패한 것을 확인한다", "`set -o pipefail` 을 켜고 다시 실행하면 `$?` 가 1 이 된다"]', NULL, '`grep` 은 일치하는 줄이 없으면 종료 코드 1 입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 29, '백그라운드 작업 기다리기', '백그라운드 작업의 종료 코드를 받는 순서입니다. 순서에 맞게 놓아 보세요.', '시작 → PID 저장 → 기다리기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`(sleep 1; exit 3) &` 로 작업을 백그라운드로 시작한다", "`pid=$!` 로 방금 시작한 작업의 PID 를 저장한다", "`wait \\"$pid\\"` 로 그 작업이 끝나기를 기다린다", "`echo $?` 로 종료 코드 3 을 확인한다"]', NULL, '자식이 아닌 PID 를 `wait` 하면 `is not a child of this shell` 오류와 종료 코드 127 입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 29);
