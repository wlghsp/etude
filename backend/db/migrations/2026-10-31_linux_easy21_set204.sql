-- 리눅스 세트 204. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set204.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 204, '쉘 편의 기능과 작업 제어: echo -e, cat -n, tail -f, basename, pushd, jobs·kill %1, pkill, alias, history', '터미널에서 자주 쓰는 편의 명령과 작업 제어를 한 개념씩 반복합니다. echo -n 과 -e, cat -n 과 -b 의 빈 줄 처리와 tac, tail -n +2 와 -f 와 head -c, basename 과 dirname, rmdir 의 빈 폴더 조건, pushd·popd 스택, 백그라운드 작업의 jobs 와 kill %1, wait 가 돌려주는 종료 코드, pgrep·pkill 의 -f 와 종료 코드, 스크립트 안에서 alias 가 확장되지 않는 것, history 와 !! 와 !1, 한 명령에만 주는 환경 변수와 export 의 차이를 짧은 객관식·빈칸·순서 문제로 익히고, 백그라운드 작업 정리, 폴더 위치 쌓고 돌아오기, alias 만들고 해제하기, 로그 따라보기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 204);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '📟' WHERE id = 204;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 1, 'echo -n 의 줄바꿈', 'bash 에서 `echo -n "ab"` 와 `echo "ab"` 의 출력은 어떻게 다를까요?', '`-n` 은 줄바꿈을 빼요.', NULL, NULL, '[]', 'choice', '["`-n` 을 쓰면 글자 수를 세어 함께 출력한다", "`-n` 을 쓰면 줄 앞에 줄 번호를 붙인다", "`-n` 을 쓰면 끝에 줄바꿈을 붙이지 않아 다음 출력이 같은 줄에 이어진다. 쓰지 않으면 줄바꿈이 붙는다", "둘 다 줄바꿈이 붙어 결과가 같다"]', 2, '프롬프트처럼 같은 줄에 이어서 쓰고 싶을 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 2, 'echo -e 와 백슬래시', 'bash 에서 `echo "a\\nb"` 와 `echo -e "a\\nb"` 는 각각 무엇을 출력할까요?', '`-e` 가 백슬래시 표기를 해석해요.', NULL, NULL, '[]', 'choice', '["둘 다 두 줄로 나온다", "앞의 것은 `a\\\\nb` 가 글자 그대로 한 줄로 나오고, `-e` 를 붙인 것은 `\\\\n` 이 줄바꿈이 되어 두 줄로 나온다", "둘 다 `a\\\\nb` 가 한 줄로 그대로 나온다", "`-e` 를 붙이면 오류가 난다"]', 1, '탭도 같습니다. `-e` 를 쓰면 `\\t` 가 탭 문자가 됩니다. 줄바꿈이 필요하면 `printf` 도 편합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 3, 'cat -n 의 빈 줄', '내용이 `l1`, 빈 줄, `l3` 인 파일에 `cat -n` 과 `cat -b` 를 쓰면 번호가 어떻게 붙을까요?', '`-b` 는 비어 있지 않은 줄만 세요.', NULL, NULL, '[]', 'choice', '["`cat -n` 은 빈 줄까지 모든 줄에 1, 2, 3 을 붙이고, `cat -b` 는 빈 줄은 건너뛰고 내용이 있는 줄에만 1, 2 를 붙인다", "`cat -n` 은 빈 줄을 건너뛰고, `cat -b` 는 모든 줄에 번호를 붙인다", "둘 다 모든 줄에 같은 번호를 붙인다", "둘 다 줄 번호를 붙이지 않고 글자 수만 센다"]', 0, '`nl` 도 기본으로 빈 줄에는 번호를 붙이지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 4, 'tail -n +2 의 뜻', '`tail -n +2 data.txt` 는 무엇을 출력할까요?', '숫자 앞의 `+` 에 주목해요.', NULL, NULL, '[]', 'choice', '["마지막 2줄만 출력한다", "처음 2줄만 출력한다", "2번째 줄 한 줄만 출력한다", "2번째 줄부터 끝까지 모두 출력한다. 첫 줄(제목줄)을 건너뛸 때 쓴다"]', 3, '`+` 없이 `tail -n 2` 는 마지막 2줄입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 5, 'tail -f 로 따라보기', '`tail -n 2 -f app.log` 는 어떻게 동작할까요?', '끝나지 않고 새 줄을 기다려요.', NULL, NULL, '[]', 'choice', '["마지막 2줄을 출력하고 바로 끝난다", "파일의 처음 2줄만 계속 반복해서 출력한다", "마지막 2줄을 먼저 출력하고 끝나지 않은 채 기다리면서, 파일에 새로 붙는 줄을 계속 출력한다. `Ctrl+C` 로 끝낸다", "파일을 2초마다 처음부터 다시 출력한다"]', 2, '로그가 쌓이는 모습을 볼 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 6, 'basename 과 dirname', '`basename /var/log/syslog.txt` 와 `dirname /var/log/syslog.txt` 는 각각 무엇을 출력할까요?', '파일 이름과 그 앞의 폴더로 나눠요.', NULL, NULL, '[]', 'choice', '["`basename` 은 `/var/log`, `dirname` 은 `syslog.txt` 를 출력한다", "`basename` 은 `syslog.txt`, `dirname` 은 `/var/log` 를 출력한다", "둘 다 `syslog.txt` 를 출력한다", "`basename` 은 `syslog`, `dirname` 은 `txt` 를 출력한다"]', 1, '`basename /var/log/syslog.txt .txt` 처럼 끝에 확장자를 주면 `syslog` 만 남습니다. 경로 없이 `dirname file.txt` 는 `.` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 7, 'rmdir 의 조건', '`rmdir ne` 로 안에 파일이 있는 폴더를 지우려 하면 어떻게 될까요? 비어 있는 폴더는요?', '`rmdir` 은 빈 폴더 전용이에요.', NULL, NULL, '[]', 'choice', '["안에 파일이 있으면 `Directory not empty` 오류로 지워지지 않고, 비어 있는 폴더만 지워진다. 파일이 있는 폴더는 `rm -r` 로 지운다", "안의 파일까지 함께 지워진다", "파일이 있어도 폴더만 지우고 파일은 상위 폴더로 옮긴다", "빈 폴더도 `-r` 없이는 지워지지 않는다"]', 0, '`rmdir -p a/b/c` 는 비게 된 상위 폴더까지 차례로 지웁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 8, 'pushd 와 popd', '현재 위치가 `/tmp` 일 때 `pushd /etc` 를 하고 `popd` 를 하면 현재 위치는 어디일까요?', '쌓아 두었다가 꺼내서 돌아가요.', NULL, NULL, '[]', 'choice', '["`/etc` 에 그대로 머문다", "`/` 로 이동한다", "`popd` 는 폴더를 삭제하는 명령이라 `/etc` 가 지워진다", "`pushd` 가 이전 위치를 스택에 쌓고 이동하고, `popd` 가 그 위치를 꺼내 돌아가므로 `/tmp` 가 된다. 스택이 비었는데 `popd` 를 하면 `directory stack empty` 오류가 난다"]', 3, '`dirs -v` 로 쌓인 위치를 번호와 함께 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 9, '백그라운드 작업 목록', '`sleep 301 &` 를 실행한 뒤 `jobs` 를 하고 `kill %1` 을 하면 어떻게 될까요?', '`%1` 은 작업 번호예요.', NULL, NULL, '[]', 'choice', '["`jobs` 에는 아무것도 나오지 않는다", "`kill %1` 은 PID 가 1 인 프로세스를 종료한다", "`jobs` 에 `[1]` 번 작업이 `Running` 으로 보이고, `kill %1` 로 그 작업이 종료되어 `Terminated` 로 바뀐다", "`&` 로 실행한 작업은 `kill` 로 종료할 수 없다"]', 2, '작업 번호는 그 쉘에서만 쓰는 번호이고 PID 와 다릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 10, 'wait 와 종료 코드', '`(exit 3) & wait $!` 를 실행한 직후 `echo $?` 는 무엇을 출력할까요?', '`$!` 는 마지막 백그라운드 작업의 PID 예요.', NULL, NULL, '[]', 'choice', '["항상 `0` 이 출력된다", "`3` 이 출력된다. `wait PID` 는 그 백그라운드 작업이 끝날 때까지 기다리고 그 작업의 종료 코드를 돌려준다", "백그라운드 작업의 PID 가 출력된다", "`wait` 에 PID 를 주면 오류가 난다"]', 1, '`wait` 에 아무 인자도 주지 않으면 모든 백그라운드 작업이 끝나기를 기다립니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 11, 'pgrep 와 pkill', '`sleep 777` 과 `sleep 778` 이 떠 있을 때 `pkill -f "sleep 777"` 를 하면 무엇이 종료될까요? 일치하는 프로세스가 없으면 종료 코드는요?', '`-f` 는 전체 명령줄에서 찾아요.', NULL, NULL, '[]', 'choice', '["명령줄에 `sleep 777` 이 들어 있는 프로세스만 종료되고 `sleep 778` 은 남는다. 일치하는 것이 없으면 종료 코드 1 이다", "`sleep` 으로 시작하는 모든 프로세스가 종료된다", "일치하는 프로세스가 없으면 오류 없이 종료 코드 0 이다", "`-f` 는 프로세스를 강제로 지우는 옵션이라 둘 다 종료된다"]', 0, '종료시키기 전에 `pgrep -f` 로 어떤 PID 가 걸리는지 먼저 확인하는 것이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 12, '스크립트 안의 alias', '`alias gg=''echo hi''` 와 `gg` 를 적은 스크립트 파일을 `bash s.sh` 로 실행하면 어떻게 될까요?', '스크립트는 비대화형 쉘이에요.', NULL, NULL, '[]', 'choice', '["`hi` 가 출력된다", "alias 를 정의하는 줄에서 문법 오류가 난다", "`gg` 가 영구 저장되어 다음 로그인에서도 쓸 수 있다", "기본으로는 alias 가 확장되지 않아 `gg: command not found` 가 난다. 스크립트 안에서 쓰려면 `shopt -s expand_aliases` 를 먼저 켜거나 함수로 만든다"]', 3, '터미널에서 직접 정의한 alias 는 그 쉘이 끝나면 사라집니다. 계속 쓰려면 `~/.bashrc` 에 적습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 13, 'history 와 !!', '대화형 bash 에서 `history` 를 하면 무엇이 보일까요? `!!` 와 `!1` 은 각각 무엇을 할까요?', '이전에 입력한 명령을 다시 불러내요.', NULL, NULL, '[]', 'choice', '["`history` 는 파일의 변경 이력을 보여 주고 `!!` 는 파일을 되돌린다", "`!!` 는 모든 명령 기록을 지운다", "`history` 는 입력했던 명령을 번호와 함께 보여 주고, `!!` 는 바로 직전 명령을, `!1` 은 1번 명령을 다시 실행한다", "`!1` 은 마지막 명령의 종료 코드를 출력한다"]', 2, '`!echo` 처럼 쓰면 `echo` 로 시작하는 가장 최근 명령을 다시 실행합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 14, '환경 변수를 한 명령에만', '`FOO=x sh -c ''echo $FOO''` 를 실행한 뒤 같은 쉘에서 `echo "[$FOO]"` 를 하면 무엇이 나올까요? `export FOO=x` 로 했다면요?', '앞에 붙인 변수는 그 명령에만 적용돼요.', NULL, NULL, '[]', 'choice', '["두 방식 모두 이후에도 `[x]` 가 나온다", "앞의 방식은 그 명령에만 값이 전달되어 이후에는 `[]` 로 비어 있다. `export` 로 정의하면 이후의 자식 프로세스에도 값이 전달된다", "두 방식 모두 이후에는 `[]` 로 비어 있다", "앞의 방식은 오류가 난다"]', 1, '`env FOO=x 명령` 도 같은 효과이고, `env -u FOO 명령` 은 그 변수를 빼고 실행합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 15, '줄바꿈 없이 출력', '`echo` 가 **끝에 줄바꿈을 붙이지 않게** 하는 옵션을 채우세요.', '"no newline"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-e", "-r", "-s"]', NULL, '다음 출력이 같은 줄에 이어집니다.', '[0]', 'echo {0} "ab"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 16, '백슬래시 해석', '`echo` 가 `\\n`, `\\t` 같은 **백슬래시 표기를 해석하게** 하는 옵션을 채우세요.', '"escape"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-e", "-n", "-x", "-t"]', NULL, 'bash 의 `echo` 는 이 옵션이 없으면 글자 그대로 출력합니다.', '[0]', 'echo {0} "a\\nb"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 17, '줄 번호 붙이기', '파일의 **모든 줄에 번호를 붙여** 출력하는 `cat` 옵션을 채우세요.', '"number"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-l", "-c", "-t"]', NULL, '빈 줄을 건너뛰려면 `-b` 를 씁니다.', '[0]', 'cat {0} f.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 18, '거꾸로 출력', '파일의 **마지막 줄부터 첫 줄까지 거꾸로** 출력하는 명령을 채우세요.', '`cat` 을 뒤집은 이름이에요.', NULL, NULL, '[]', 'fill', '["tac", "rev", "flip", "back"]', NULL, '`rev` 는 줄 순서가 아니라 각 줄의 글자 순서를 뒤집습니다.', '[0]', '{0} f.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 19, '앞쪽 바이트만 보기', '파일의 **앞 5바이트만** 출력하도록 `head` 옵션을 채우세요.', '"character"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-c", "-n", "-b", "-w"]', NULL, '`-n` 은 줄 수를 정합니다.', '[0]', 'head {0} 5 g.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 20, '새 줄 계속 보기', '파일 끝에 **새로 붙는 줄을 계속 따라 출력하는** `tail` 옵션을 채우세요.', '"follow"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-w", "-l", "-r"]', NULL, '`Ctrl+C` 로 끝냅니다.', '[0]', 'tail {0} app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 21, '경로에서 이름만', '`/var/log/syslog.txt` 에서 **파일 이름 부분만** 출력하는 명령을 채우세요.', '"base"와 "name"을 이어요.', NULL, NULL, '[]', 'fill', '["basename", "dirname", "filename", "pathname"]', NULL, '`dirname` 은 반대로 폴더 부분만 출력합니다.', '[0]', '{0} /var/log/syslog.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 22, '빈 폴더 지우기', '**빈 폴더만 지우는** 명령을 채우세요.', '"remove"와 "dir"을 이어요.', NULL, NULL, '[]', 'fill', '["rmdir", "rd", "deldir", "remdir"]', NULL, '안에 파일이 있으면 `rm -r` 을 씁니다.', '[0]', '{0} emptydir', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 23, '이름으로 PID 찾기', '명령줄에 `sleep 777` 이 들어 있는 **프로세스의 PID 목록만 출력하는** 명령을 채우세요.', '"process grep"의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["pgrep", "pkill", "pidof", "pfind"]', NULL, '`pkill` 은 찾은 프로세스에 신호를 보내 종료합니다.', '[0]', '{0} -f "sleep 777"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 24, '명령에 별명 붙이기', '긴 명령에 **짧은 별명을 붙이는** 쉘 내장 명령을 채우세요.', '"별칭"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["alias", "define", "shortcut", "bind"]', NULL, '해제는 `unalias ll` 입니다.', '[0]', '{0} ll=''ls -l''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 25, '위치를 쌓고 이동', '현재 위치를 **스택에 쌓아 두고 다른 폴더로 이동하는** 명령을 채우세요.', '"push"와 "directory"를 이어요.', NULL, NULL, '[]', 'fill', '["pushd", "popd", "dirs", "stack"]', NULL, '`popd` 로 쌓아 둔 위치로 돌아옵니다.', '[0]', '{0} /tmp', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 26, '백그라운드 작업 정리', '백그라운드로 돌리던 작업을 확인하고 끝내는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 목록 → 종료 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`sleep 301 &` 로 작업을 백그라운드로 실행한다", "`jobs` 로 `[1]` 번 작업이 `Running` 인지 확인한다", "`kill %1` 로 그 작업을 종료한다", "`jobs` 로 작업이 `Terminated` 로 바뀌었는지 확인한다"]', NULL, 'PID 로 끝내려면 실행 직후 `$!` 값을 `kill` 에 줍니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 27, '폴더 위치 쌓고 돌아오기', '`pushd` 와 `popd` 로 폴더를 옮겨 다니는 순서입니다. 순서에 맞게 놓아 보세요.', '쌓으며 이동 → 한 번 더 → 돌아오기 → 위치 확인 순서예요.', NULL, NULL, '[]', 'order', '["`pushd /etc` 로 현재 위치를 쌓아 두고 `/etc` 로 이동한다", "`pushd /var` 로 `/etc` 를 쌓아 두고 `/var` 로 이동한다", "`popd` 로 쌓아 둔 `/etc` 로 돌아온다", "`pwd` 로 현재 위치가 `/etc` 인지 확인한다"]', NULL, '`popd` 를 한 번 더 하면 처음 위치로 돌아오고, 그다음 `popd` 는 스택이 비었다는 오류가 납니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 28, 'alias 만들고 해제하기', '터미널에서 alias 를 만들어 쓰고 해제하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 확인 → 쓰기 → 해제 순서예요.', NULL, NULL, '[]', 'order', '["`alias ll=''ls -l''` 로 별명을 만든다", "`alias ll` 로 별명이 `ls -l` 로 등록됐는지 확인한다", "`ll` 을 입력해 `ls -l` 처럼 동작하는지 본다", "`unalias ll` 로 별명을 해제한다"]', NULL, '계속 쓰려면 `~/.bashrc` 에 같은 줄을 적습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 29, '로그 따라보기', '로그 파일의 끝부분을 보고 새로 쌓이는 줄을 따라보는 순서입니다. 순서에 맞게 놓아 보세요.', '끝부분 보기 → 따라보기 → 새 줄 쓰기 → 끝내기 순서예요.', NULL, NULL, '[]', 'order', '["`tail -n 3 app.log` 로 마지막 3줄을 확인한다", "`tail -f app.log` 로 새로 붙는 줄을 따라본다", "다른 터미널에서 `echo new >> app.log` 로 줄을 추가하고 `new` 가 보이는지 확인한다", "`Ctrl+C` 로 `tail -f` 를 끝낸다"]', NULL, '`tail -n 3 -f app.log` 처럼 한 번에 쓸 수도 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 29);
