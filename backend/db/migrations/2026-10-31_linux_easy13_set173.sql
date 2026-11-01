-- 리눅스 세트 173. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set173.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 173, '권한 비트와 프로세스 한도: umask, setuid·sticky, nohup·nice, ulimit, /proc 한 줄씩', '파일 권한의 숨은 부분과 프로세스를 다루는 기본기를 한 개념씩 반복합니다. umask 로 새 파일과 폴더의 권한이 정해지는 계산과 적용 범위, setuid·setgid·sticky 비트의 표시와 대문자 S·T, 공유 폴더에서 남의 파일을 지울 수 있는지, nohup 이 SIGHUP 을 무시하게 하는 것, nice 의 값과 범위와 일반 사용자의 제한, renice, ulimit 의 소프트·하드 한도와 -n 100 및 -Sn 의 차이, CPU 시간과 파일 크기 한도에 걸렸을 때의 종료 코드, /proc/PID 의 fd·cmdline·cwd·exe·status, exec 와 env, heredoc 의 따옴표 차이를 짧은 객관식·빈칸·순서 문제로 익히고, umask 로 새 파일 권한 확인, nohup 작업 확인, 열린 파일 한도 시험, /proc 에서 프로세스 읽기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 173);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🔧' WHERE id = 173;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 1, 'umask 계산', '`umask 022` 일 때 새로 만든 파일과 폴더의 권한은 각각 몇이 될까요? `umask 077` 이면요?', '파일은 666, 폴더는 777 에서 umask 를 빼요.', NULL, NULL, '[]', 'choice', '["`022` 는 파일 022, 폴더 022 이고 `077` 은 077 이다", "`022` 는 파일 755, 폴더 644 이다", "`022` 는 파일 644, 폴더 755 이고, `077` 은 파일 600, 폴더 700 이다 (파일은 666, 폴더는 777 에서 umask 의 비트를 뺀다)", "`umask` 는 이미 있는 파일의 권한만 바꾼다"]', 2, '`027` 이면 파일 640, 폴더 750 입니다. 파일은 실행 권한 없이 만들어지기 때문에 666 에서 시작해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 2, 'umask 의 범위', '`umask 077` 을 실행하기 전에 만들어 둔 파일의 권한은 바뀔까요? 괄호 `( umask 077; ... )` 안에서 바꾼 값은 밖에서도 유지될까요?', 'umask 는 앞으로 만들 파일에만 적용돼요.', NULL, NULL, '[]', 'choice', '["이미 있는 파일의 권한도 모두 바뀐다", "이미 있는 파일의 권한은 바뀌지 않고(644 가 그대로), 괄호(서브쉘) 안에서 바꾼 umask 는 밖에서 유지되지 않는다", "괄호 안에서 바꾼 값이 밖에서도 유지된다", "`umask` 는 재부팅 전까지 모든 사용자에게 적용된다"]', 1, '`umask -S` 는 `u=rwx,g=rx,o=rx` 처럼 기호로 보여 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 3, 'setuid·setgid 표시', '`chmod 4755 파일` 과 `chmod 2755 파일` 을 한 뒤 `ls -l` 에서 권한 문자열은 어떻게 보일까요?', '실행 자리에 s 가 나타나요.', NULL, NULL, '[]', 'choice', '["`4755` 는 `-rwsr-xr-x` (소유자 실행 자리가 `s`), `2755` 는 `-rwxr-sr-x` (그룹 실행 자리가 `s`)로 보인다", "`4755` 는 `-rwxr-xr-x` 로 보이고 표시가 없다", "`4755` 는 `drwsr-xr-x` 로 보인다", "`2755` 는 `-rwsr-xr-x` 로 보인다"]', 0, '`/usr/bin/passwd` 도 `-rwsr-xr-x` 로 보입니다. 기호 모드로는 `chmod u+s`, `chmod g+s` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 4, '대문자 S 와 T', '`chmod 4644 파일` 하면 `-rwSr--r--` 처럼 대문자 `S` 가 보이고, `chmod 1776 폴더` 하면 `drwxrwxrwT` 처럼 대문자 `T` 가 보입니다. 왜 대문자일까요?', '그 자리에 실행 권한이 없다는 신호예요.', NULL, NULL, '[]', 'choice', '["오류가 났다는 표시이다", "대문자는 읽기 전용이라는 뜻이다", "권한이 두 번 설정되었다는 뜻이다", "특수 비트는 켜져 있지만 같은 자리(소유자·그룹·기타)의 실행(x) 권한이 없을 때 소문자 대신 대문자로 표시된다"]', 3, '`s`, `t` 는 x 가 함께 있을 때, `S`, `T` 는 x 가 없을 때입니다. 보통 의도하지 않은 설정이니 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 5, 'sticky 비트', '`chmod 1777` 폴더(`/tmp` 처럼 `drwxrwxrwt`)와 `chmod 777` 폴더에서, 다른 사용자가 만든 파일을 지우려 하면 어떻게 될까요?', 't 가 있으면 파일 주인만 지울 수 있어요.', NULL, NULL, '[]', 'choice', '["두 폴더 모두 지워진다", "두 폴더 모두 거부된다", "sticky 폴더에서는 `rm: cannot remove ...: Operation not permitted` 로 거부되고, 일반 `777` 폴더에서는 지워진다", "sticky 폴더에서는 지워지고 777 폴더에서는 거부된다"]', 2, '여러 사용자가 쓰는 공유 폴더에 sticky 비트를 두어 남의 파일을 지우지 못하게 합니다. 기호 모드는 `chmod +t` 예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 6, 'nohup 의 효과', '`nohup sleep 30 &` 로 실행한 프로세스와 그냥 `sleep 30 &` 로 실행한 프로세스에 `kill -HUP` 을 보내면 어떻게 될까요?', '터미널이 닫힐 때 오는 신호예요.', NULL, NULL, '[]', 'choice', '["둘 다 종료된다", "그냥 실행한 프로세스는 `Hangup` 으로 종료되고, `nohup` 으로 실행한 프로세스는 SIGHUP 을 무시하도록 설정되어 계속 살아 있다 (`/proc/PID/status` 의 `SigIgn` 값에 HUP 비트가 더해진다)", "둘 다 계속 살아 있다", "`nohup` 으로 실행한 쪽만 종료된다"]', 1, 'SSH 연결이 끊겨도 작업이 계속되게 할 때 씁니다. 출력은 `nohup 명령 > out.log 2>&1 &` 처럼 직접 파일로 돌려 두세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 7, 'nice 값', '`nice` 와 `nice -n 10 명령`, `nice -n 25 nice` 는 각각 어떤 값을 보여 줄까요?', '값이 클수록 CPU 를 양보해요.', NULL, NULL, '[]', 'choice', '["그냥 `nice` 는 기본 0 을 보여 주고, `-n 10` 으로 실행한 프로세스의 NI 는 10 이며, 범위를 넘는 25 는 최댓값 19 로 조정된다. 값이 클수록 우선순위가 낮다", "기본값은 10 이고 값이 클수록 우선순위가 높다", "25 는 오류로 거부된다", "NI 는 항상 0 에서 변하지 않는다"]', 0, '`ps -o pid,ni,cmd -p PID` 의 NI 열로 확인합니다. 범위는 -20(가장 높음)부터 19(가장 낮음)까지예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 8, '일반 사용자의 nice 제한', '일반 사용자가 `nice -n -1 명령` 으로 우선순위를 높이거나, `renice -n 5` 한 프로세스를 `renice -n 2` 로 다시 낮은 값으로 되돌리려 하면 어떻게 될까요?', '우선순위를 올리는 일은 권한이 필요해요.', NULL, NULL, '[]', 'choice', '["제한 없이 자유롭게 바꿀 수 있다", "값을 올리는 것도 거부된다", "둘 다 성공하지만 경고가 나온다", "둘 다 `Permission denied` 로 거부된다 (일반 사용자는 niceness 를 높이는 쪽으로만 바꿀 수 있고, 낮추려면 특별한 권한이 필요하다)"]', 3, '이 컨테이너에서는 root 의 `nice -n -5` 도 거부되었습니다. 환경에 따라 권한(capability)이 다를 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 9, 'ulimit 의 소프트와 하드', '일반 사용자의 `ulimit -Sn` 이 1024, `ulimit -Hn` 이 1048576 입니다. 소프트 한도를 200 으로 바꾼 뒤 다시 500 으로 올릴 수 있을까요? 하드 한도는요?', '소프트는 하드까지 오갈 수 있어요.', NULL, NULL, '[]', 'choice', '["소프트와 하드 모두 자유롭게 올릴 수 있다", "소프트는 한 번 낮추면 올릴 수 없다", "소프트 한도는 하드 한도 안에서 올리고 내릴 수 있고, 하드 한도는 낮추기만 가능하며 다시 올리려 하면 `Operation not permitted` 오류가 난다", "하드 한도는 낮추는 것도 불가능하다"]', 2, '소프트 한도가 실제로 적용되는 값이고 하드 한도는 그 상한입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 10, 'ulimit -n 100 과 -Sn', '`ulimit -n 100` 과 `ulimit -Sn 100` 은 어떻게 다를까요? 소프트가 하드보다 큰 상태에서 `ulimit -Hn` 으로 하드를 소프트보다 낮게 정하면요?', '옵션이 없으면 둘 다 바꿔요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같고 하드는 바뀌지 않는다", "`-n 100` 은 소프트와 하드를 모두 100 으로 하고(이후 하드를 올릴 수 없다), `-Sn 100` 은 소프트만 100 으로 한다. 하드를 소프트보다 낮게 정하면 `Invalid argument` 오류가 난다", "`-Sn` 은 하드만 바꾼다", "하드를 소프트보다 낮게 정하면 소프트가 자동으로 낮아진다"]', 1, '하드를 낮추려면 소프트를 먼저 낮추거나 옵션 없이 한 번에 정하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 11, 'ulimit 의 CPU·파일 크기', '`ulimit -St 1` 과 `ulimit -t 1` 로 CPU 를 계속 쓰는 반복문을 실행했을 때, 그리고 `ulimit -f 1` 로 5000바이트를 파일에 쓰려 할 때 각각 어떻게 될까요?', '신호에 따라 종료 코드가 달라요.', NULL, NULL, '[]', 'choice', '["`-St 1`(소프트만)은 `CPU time limit exceeded` 로 종료 코드 152(SIGXCPU), `-t 1`(소프트와 하드)은 `Killed` 로 137 이다. `-f 1` 은 1024바이트에서 멈추고 `File size limit exceeded` 로 종료 코드 153 이다", "모두 종료 코드 0 으로 정상 종료한다", "`-St 1` 과 `-t 1` 은 같은 결과이다", "`-f 1` 은 파일을 한 개만 만들게 한다"]', 0, '`ulimit -f` 의 단위는 1024바이트 블록입니다. 한도를 넘으면 커널이 신호로 프로세스를 종료시켜요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 12, '/proc/PID 읽기', '프로세스 번호가 `PID` 인 프로세스의 정보를 `/proc` 에서 읽을 때, `fd`, `cmdline`, `cwd`, `exe`, `status` 는 각각 무엇을 알려 줄까요?', '프로세스마다 폴더가 있어요.', NULL, NULL, '[]', 'choice', '["`/proc/PID` 는 디스크에 저장된 로그 폴더이다", "프로세스가 끝나도 `/proc/PID` 가 계속 남는다", "`cmdline` 은 환경 변수를 보여 준다", "`fd` 는 열린 파일 번호(0·1·2 와 리다이렉트한 파일 등), `cmdline` 은 실행 명령(인자가 NUL 문자로 구분됨), `cwd` 는 작업 폴더의 링크, `exe` 는 실행 파일의 링크, `status` 는 이름과 상태(`Name`, `State`) 등이다. 프로세스가 끝나면 그 폴더도 사라진다"]', 3, '환경 변수는 `/proc/PID/environ` 에서 NUL 로 구분되어 보입니다. `tr ''\\0'' '' ''` 로 읽기 좋게 바꿀 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 13, 'exec 와 env', '`bash -c ''exec echo replaced; echo not-printed''` 와 `env GREET=hi sh -c ''echo $GREET''` 는 각각 무엇을 보여 줄까요?', 'exec 는 쉘을 대체하고, env 는 그 명령에만 변수를 줘요.', NULL, NULL, '[]', 'choice', '["`exec` 뒤의 명령도 이어서 실행되고, `GREET` 는 쉘에 남는다", "`exec` 는 새 PID 로 실행하고, `env` 는 모든 변수를 지운다", "`exec` 는 쉘을 `echo` 로 바꿔 버려 `replaced` 만 출력하고 뒤의 명령은 실행되지 않으며(PID 는 그대로), `env GREET=hi 명령` 은 그 명령에만 변수를 주고 끝난 뒤에는 현재 쉘에 남지 않는다", "둘 다 오류가 난다"]', 2, '`env -i 명령` 은 환경 변수를 모두 비우고 실행하고, `VAR=값 명령` 형태도 그 명령에만 적용됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 14, 'heredoc', '`cat <<EOF` 와 `cat <<''EOF''` 는 본문의 `$NAME` 과 `$(echo cmd)` 를 어떻게 처리할까요? `<<-EOF` 는요?', '구분자에 따옴표가 있으면 그대로 둬요.', NULL, NULL, '[]', 'choice', '["둘 다 항상 해석한다", "따옴표가 없는 `<<EOF` 는 변수와 명령 치환을 해석해 값으로 바꾸고, `<<''EOF''` 는 그대로 출력한다. `<<-EOF` 는 본문 앞쪽의 탭 들여쓰기를 지운다", "둘 다 항상 그대로 출력한다", "`<<-EOF` 는 모든 공백을 지운다"]', 1, '`\\$NAME` 처럼 백슬래시를 앞에 두면 따옴표 없는 heredoc 에서도 해석하지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 15, '파일 600 이 되는 umask', '새 파일이 **600**, 새 폴더가 **700** 이 되도록 하는 umask 값을 채우세요.', '그룹과 기타의 권한을 모두 빼요.', NULL, NULL, '[]', 'fill', '["077", "022", "700", "600"]', NULL, '`umask` 값은 빼는 권한이고, 결과 권한과 헷갈리지 않게 하세요.', '[0]', 'umask {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 16, '소유자 setuid', '파일의 **소유자 실행 자리에 `s`** 가 보이도록 하는 기호 모드를 채우세요.', '사용자(u)에게 s 를 더해요.', NULL, NULL, '[]', 'fill', '["u+s", "g+s", "+t", "a+x"]', NULL, '`g+s` 는 그룹 자리에 `s` 를 보이게 합니다.', '[0]', 'chmod {0} 파일', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 17, 'sticky 비트', '공유 폴더에 **sticky 비트**를 켜는 기호 모드를 채우세요.', '"t"를 더해요.', NULL, NULL, '[]', 'fill', '["+t", "+s", "+x", "+w"]', NULL, '켜면 `ls -ld` 의 마지막 글자가 `t`(실행 권한이 없으면 `T`)가 됩니다.', '[0]', 'chmod {0} shared_dir', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 18, '로그아웃해도 계속', '터미널 연결이 끊겨도 프로세스가 살아남도록 SIGHUP 을 **무시하게 하는 명령**을 채우세요.', '"no hangup"을 줄인 이름이에요.', NULL, NULL, '[]', 'fill', '["nohup", "nice", "disown-all", "daemon"]', NULL, '출력은 직접 파일로 돌려 두는 것이 안전합니다.', '[0]', '{0} sleep 30 > out.txt 2>&1 &', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 19, 'nice 로 실행', '우선순위 값 10 으로 실행하는 `nice` 의 **옵션**을 채우세요.', '"조정"을 뜻하는 단어 adjustment 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-p", "-t", "-l"]', NULL, '값이 클수록 CPU 를 양보합니다.', '[0]', 'nice {0} 10 sleep 30', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 20, 'NI 열 보기', '`ps` 로 프로세스의 **niceness 열**을 보는 출력 이름을 채우세요.', '"nice"의 줄임이에요.', NULL, NULL, '[]', 'fill', '["ni", "nc", "pri-n", "nv"]', NULL, '`ps -o pid,ni,cmd -p PID` 처럼 여러 열을 함께 볼 수 있습니다.', '[0]', 'ps -o {0} -p 1234', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 21, '실행 중인 프로세스의 nice 바꾸기', '이미 실행 중인 프로세스의 **niceness 를 바꾸는** 명령을 채우세요.', '"다시 nice"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["renice", "nice", "setnice", "chnice"]', NULL, '일반 사용자는 값을 높이는 쪽으로만 바꿀 수 있습니다.', '[0]', '{0} -n 7 -p 1234', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 22, '열린 파일 개수 한도', '프로세스가 한 번에 **열 수 있는 파일 개수**의 한도를 다루는 `ulimit` 옵션을 채우세요.', '"number of open files"의 n 이에요.', NULL, NULL, '[]', 'fill', '["-n", "-f", "-t", "-u"]', NULL, '`-f` 는 파일 크기, `-t` 는 CPU 시간, `-u` 는 프로세스 수 한도입니다.', '[0]', 'ulimit {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 23, '열린 fd 목록', '프로세스가 **열어 둔 파일 번호들**이 있는 `/proc/PID` 아래 폴더 이름을 채우세요.', '"file descriptor"의 줄임이에요.', NULL, NULL, '[]', 'fill', '["fd", "files", "open", "handles"]', NULL, '리다이렉트한 파일은 `1 -> 파일` 처럼 링크로 보입니다.', '[0]', 'ls /proc/1234/{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 24, '쉘을 대체하기', '현재 쉘을 지정한 명령으로 **바꿔 버리는** 쉘 내장 명령을 채우세요.', '"실행하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["exec", "run", "swap", "spawn"]', NULL, '`exec` 뒤의 명령은 실행되지 않고 PID 는 그대로입니다.', '[0]', 'bash -c ''{0} echo replaced; echo not-printed''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 25, '오류만 버리기', '표준 출력은 그대로 두고 **표준 오류만 버리는** 리다이렉트를 채우세요.', '2번 출력을 /dev/null 로 보내요.', NULL, NULL, '[]', 'fill', '["2>/dev/null", ">/dev/null 2>&1", "2>&1", "&>"]', NULL, '`> 파일 2>&1` 은 둘 다 파일로 보내지만 `2>&1 > 파일` 은 오류가 화면으로 남습니다.', '[0]', 'ls nosuchfile {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 26, 'umask 로 새 파일 권한 확인', 'umask 를 바꿔 새 파일과 폴더의 권한을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '현재 값 → 바꾸기 → 만들기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`umask` 로 현재 값(보통 0022)을 확인한다", "`umask 077` 로 값을 바꾼다", "`touch f` 와 `mkdir d` 로 새 파일과 폴더를 만든다", "`stat -c %a f d` 로 권한이 600 과 700 인지 확인한다"]', NULL, '서브쉘 `( umask 077; ... )` 안에서 하면 밖의 umask 를 바꾸지 않고 시험할 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 27, 'nohup 으로 실행한 작업 확인', '작업이 SIGHUP 에 살아남는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 설정 확인 → 신호 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`nohup sleep 30 > out.txt 2>&1 &` 로 실행하고 PID 를 확인한다", "`grep SigIgn /proc/PID/status` 로 SIGHUP 무시 비트가 있는지 본다", "`kill -HUP PID` 를 보낸 뒤 `kill -0 PID` 로 아직 살아 있는지 확인한다", "확인이 끝나면 `kill PID` 로 정리한다"]', NULL, '그냥 실행한 프로세스는 같은 신호에 `Hangup` 으로 종료됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 28, '열린 파일 한도 시험', '서브쉘에서만 한도를 낮춰 시험하는 순서입니다. 순서에 맞게 놓아 보세요.', '현재 값 → 서브쉘에서 낮춤 → 초과 → 밖은 그대로 순서예요.', NULL, NULL, '[]', 'order', '["`ulimit -n` 으로 현재 한도를 확인한다", "괄호 안에서 `ulimit -n 20` 으로 한도를 낮춘다", "한도를 넘는 번호의 파일을 열려 해서 `Too many open files` 같은 오류를 확인한다", "괄호 밖에서 `ulimit -n` 이 처음 값 그대로인지 확인한다"]', NULL, '서브쉘 안에서 바꾼 한도는 밖으로 새지 않으니 시험하기 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 29, '프로세스를 /proc 에서 읽기', '실행 중인 프로세스의 정보를 `/proc` 에서 차례로 읽는 순서입니다. 순서에 맞게 놓아 보세요.', 'PID 얻기 → 상태 → 파일 → 위치 순서예요.', NULL, NULL, '[]', 'order', '["`sleep 30 > out.txt &` 로 실행하고 `$!` 로 PID 를 얻는다", "`grep -E ''^(Name|State):'' /proc/PID/status` 로 이름과 상태를 본다", "`ls /proc/PID/fd` 로 열어 둔 파일 번호를 본다", "`readlink /proc/PID/cwd` 로 작업 폴더를 확인한다"]', NULL, '프로세스가 끝나면 `/proc/PID` 폴더가 사라져 `No such file` 이 됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 29);
