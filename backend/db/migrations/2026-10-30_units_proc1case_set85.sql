-- 리눅스 세트 85. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set85.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 85, '프로세스와 파일시스템 이해하기: fork·exec, /proc, 커널 모드', '리눅스를 쓰는 모든 명령의 바탕이 되는 개념을 잡습니다. 프로세스를 만드는 fork 와 exec(PID 가 어떻게 변하나), 쓰기 시 복사(CoW), "모든 것은 파일이다"(/proc, /dev), 파일시스템 계층(/etc, /var, /tmp, /usr), 유저 모드와 커널 모드, 시스템 콜을 개념으로 익히고 샌드박스에서 직접 확인합니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 85);
UPDATE quest_set SET display_order = 6, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '⚙️' WHERE id = 85;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 1, '프로세스를 만드는 두 단계', '유닉스에서 새 프로그램을 실행하는 방식을 가장 정확하게 설명한 것은 무엇일까요?', '"복제"와 "교체" 두 단계입니다.', NULL, NULL, '[]', 'choice', '["`exec()` 로 새 프로세스를 만든 뒤 `fork()` 로 교체한다", "항상 커널이 프로그램을 새로 부팅한다", "`fork()` 로 현재 프로세스를 복제해 자식을 만든 뒤, 자식이 `exec()` 로 원하는 프로그램으로 자신을 교체한다", "프로세스는 만들 수 없고 스레드만 만든다"]', 2, '쉘이 `ls` 를 실행하는 것도 fork(쉘 복제) → 자식에서 exec(`ls` 로 교체) 입니다. 이 두 단계로 나뉘어 있어서 fork 와 exec 사이에 입출력 리다이렉션이나 환경 설정을 끼워 넣을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 2, 'exec 후에 PID 는', '프로세스가 `exec()` 로 다른 프로그램으로 **교체**되면 PID 는 어떻게 될까요?', '프로세스를 새로 만드는 것이 아니라 내용을 바꾸는 것입니다.', NULL, NULL, '[]', 'choice', '["PID 는 그대로이고, 실행 중이던 코드와 데이터만 새 프로그램으로 바뀐다 (exec 이후의 옛 코드는 실행되지 않는다)", "새 PID 가 부여된다", "PID 가 0 이 된다", "부모의 PID 로 바뀐다"]', 0, 'fork 는 새 PID 를 가진 자식을 만들고, exec 는 같은 PID 를 유지한 채 내용을 교체합니다. 컨테이너에서 `exec nginx` 로 PID 1 을 서비스 프로세스로 바꾸는 쉘 스크립트 패턴이 이 원리입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 3, 'fork 의 반환값', 'C 에서 `pid = fork();` 를 호출한 직후, 자식 프로세스에서 `pid` 의 값은 무엇일까요?', '부모와 자식은 같은 코드를 이어서 실행하므로 반환값으로 구분합니다.', NULL, NULL, '[]', 'choice', '["자식 프로세스의 PID", "부모 프로세스의 PID", "-1", "0 (부모에서는 자식의 PID)"]', 3, '자식에서는 0, 부모에서는 자식의 PID 가 반환되어 `if (pid == 0)` 으로 갈라집니다. -1 이면 fork 에 실패한 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 4, 'fork 가 빠른 이유', '`fork()` 로 메모리가 큰 프로세스를 복제해도 **즉시** 끝나는 이유는 무엇일까요?', '실제로 복사하는 시점이 따로 있습니다.', NULL, NULL, '[]', 'choice', '["자식이 부모의 메모리 페이지를 일단 **공유**하고, 어느 쪽이 수정할 때 그 페이지만 복사하기(CoW) 때문이다", "메모리를 전혀 복사하지 않고 프로그램도 복제하지 않기 때문이다", "커널이 복사를 나중에 영구히 미루기 때문이다", "자식에게는 메모리가 없기 때문이다"]', 1, '쓰기 시 복사(Copy-on-Write)는 컨테이너 이미지 레이어, 데이터베이스 스냅샷(MVCC)에도 쓰이는 같은 전략입니다. 쓰기가 드물고 읽기가 많을 때 효과적이고, 수정이 잦으면 복사가 빈번해 오히려 비용이 늘 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 5, '모든 것은 파일이다', '유닉스의 "모든 것은 파일이다"를 가장 잘 보여 주는 예는 무엇일까요?', '파일이 아닌 것들도 읽고 쓰는 인터페이스로 다룹니다.', NULL, NULL, '[]', 'choice', '["디스크 파일뿐 아니라 디바이스(`/dev/null`), 소켓, 프로세스 정보(`/proc`)도 파일 인터페이스로 읽고 쓴다", "모든 프로그램이 하나의 큰 파일로 합쳐져 있다", "파일은 메모리에 올릴 수 없다", "디렉터리는 존재하지 않는다"]', 2, '읽고 쓰는 방식이 통일되어서 `cat`, `grep`, 리다이렉션 같은 도구를 어디에나 쓸 수 있습니다. 예를 들어 `/proc/<PID>/cmdline` 로 프로세스의 명령줄을, `/dev/zero` 로 0 바이트를 읽을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 6, '파일시스템 계층 알기', '다음 중 **로그, 캐시처럼 실행 중에 계속 변하는 데이터**가 쌓이는 표준 위치는 어디일까요?', 'variable(변하는) 데이터라는 이름입니다.', NULL, NULL, '[]', 'choice', '["`/var` (예: `/var/log`)", "`/etc`", "`/usr/bin`", "`/dev`"]', 0, '`/etc` 는 설정, `/var` 는 변하는 데이터(로그, 캐시), `/usr` 는 프로그램과 라이브러리, `/tmp` 는 재부팅하면 지워질 수 있는 임시 파일, `/dev` 는 디바이스, `/home` 은 사용자 홈입니다. 모든 것은 `/` 루트에서 시작합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 7, '유저 모드와 커널 모드', '일반 프로그램이 파일을 읽거나 네트워크로 보내려면 **커널의 도움**이 필요합니다. 이때 프로그램이 커널 기능을 요청하는 통로는 무엇일까요?', '유저 모드에서 커널 모드로 넘어가는 문입니다.', NULL, NULL, '[]', 'choice', '["하드웨어를 직접 조작한다", "다른 프로세스의 메모리에 직접 접근한다", "특권 명령어를 직접 실행한다", "시스템 콜 (trap 으로 유저 모드에서 커널 모드로 진입한다)"]', 3, '유저 모드는 하드웨어와 다른 프로세스의 메모리에 접근할 수 없고, 특권 명령을 실행하면 예외가 납니다. 시스템 콜, 인터럽트, 예외가 모드 전환 시점이며 전환에는 비용이 있어서 시스템 콜이 잦으면 성능에 영향을 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 8, '컨테이너의 PID 1 과 시그널', '컨테이너에서 서비스를 `sh -c "exec myapp"` 처럼 **exec 로 실행**하는 이유로 알맞은 것은 무엇일까요?', 'exec 는 같은 PID 를 유지하며 내용을 교체합니다.', NULL, NULL, '[]', 'choice', '["exec 가 서비스를 더 빠르게 만들기 위해서이다", "exec 하지 않으면 쉘이 PID 1 로 남아 종료 시그널을 서비스에 전달하지 못할 수 있는데, exec 로 서비스가 PID 1 자리를 이어받아 시그널을 직접 받기 위해서이다", "exec 를 쓰면 이미지 크기가 줄기 때문이다", "컨테이너는 exec 로만 실행할 수 있기 때문이다"]', 1, '쉘이 PID 1 이면 `docker stop` 의 SIGTERM 을 자식(서비스)에게 넘기지 않고 쉘이 무시해 강제 종료(SIGKILL)까지 기다릴 수 있습니다. exec 형식(JSON 배열 `CMD ["myapp"]`)은 같은 문제를 피합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 9, 'fork 와 exec 의 PID 비교', '쉘 안에서 **fork**(자식 쉘을 새로 실행)와 **exec**(현재 프로세스를 다른 프로그램으로 교체)의 PID 차이를 확인하세요. ① `/tmp/fork.txt` 에 부모 쉘의 PID 와 자식 쉘의 PID 를 한 줄씩 저장(두 값이 달라야 함) ② `/tmp/exec.txt` 에 교체 전 PID 와 교체 후 PID 를 한 줄씩 저장(두 값이 같아야 함).', '현재 쉘의 PID 는 `$$` 입니다. 자식은 `sh -c "echo \\$\\$"` 처럼 따옴표 안에서 `$$` 가 바깥 쉘에 먼저 해석되지 않게 `\\$\\$` 로 씁니다. exec 는 `exec 명령` 입니다.
예: `sh -c ''echo $$ > 파일; exec sh -c "echo \\$\\$ >> 파일"''`', 'sh -c ''echo $$ > /tmp/fork.txt; sh -c "echo \\$\\$ >> /tmp/fork.txt"''
sh -c ''echo $$ > /tmp/exec.txt; exec sh -c "echo \\$\\$ >> /tmp/exec.txt"''
cat /tmp/fork.txt /tmp/exec.txt

# fork : 자식이 새 PID 를 받는다 (두 값이 다름)
# exec : 같은 프로세스가 내용만 바뀐다 (두 값이 같음)', '["sh", "-c", "true"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/fork.txt)\\" -eq 2 ] ) && ( [ \\"$(sed -n 1p /tmp/fork.txt)\\" != \\"$(sed -n 2p /tmp/fork.txt)\\" ] ) && ( [ \\"$(wc -l < /tmp/exec.txt)\\" -eq 2 ] ) && ( [ \\"$(sed -n 1p /tmp/exec.txt)\\" = \\"$(sed -n 2p /tmp/exec.txt)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "fork.txt 가 두 줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/fork.txt)\\" -eq 2 ]"]}, {"label": "fork 의 부모·자식 PID 가 다르다", "cmd": ["sh", "-c", "[ \\"$(sed -n 1p /tmp/fork.txt)\\" != \\"$(sed -n 2p /tmp/fork.txt)\\" ]"]}, {"label": "exec.txt 가 두 줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/exec.txt)\\" -eq 2 ]"]}, {"label": "exec 전후 PID 가 같다", "cmd": ["sh", "-c", "[ \\"$(sed -n 1p /tmp/exec.txt)\\" = \\"$(sed -n 2p /tmp/exec.txt)\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 10, '프로세스 정보를 파일로 읽기 (/proc)', '이 컨테이너의 **PID 1 프로세스의 명령줄**을 `/proc` 아래 파일에서 읽어 `/tmp/init_cmd.txt` 에 저장하세요. (`/proc/<PID>/cmdline` 은 인자가 NUL 문자로 구분되니 공백으로 바꿔 저장)', '`tr` 로 NUL(`\\0`)을 공백으로 바꿀 수 있습니다: `tr "\\0" " " < 파일`.
확인: `cat /tmp/init_cmd.txt`', 'tr "\\0" " " < /proc/1/cmdline > /tmp/init_cmd.txt
cat /tmp/init_cmd.txt

# /proc 은 커널이 프로세스·시스템 정보를 파일처럼 보여 주는 가상 파일시스템이다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/init_cmd.txt ] ) && ( [ \\"$(cat /tmp/init_cmd.txt)\\" = \\"$(tr \\"\\\\0\\" \\" \\" < /proc/1/cmdline)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/init_cmd.txt ]"]}, {"label": "PID 1 의 명령줄과 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/init_cmd.txt)\\" = \\"$(tr \\"\\\\0\\" \\" \\" < /proc/1/cmdline)\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 85, 11, '디바이스 파일 사용하기 (/dev)', '`/dev/zero` 는 읽으면 0 바이트가 끝없이 나오는 디바이스 파일입니다. 여기서 **정확히 100바이트**를 읽어 `/tmp/zero.bin` 파일로 만드세요.', '`head -c 바이트수` 로 앞의 N 바이트만 읽을 수 있습니다.
확인: `ls -l /tmp/zero.bin` (크기 100)', 'head -c 100 /dev/zero > /tmp/zero.bin
ls -l /tmp/zero.bin

# /dev/null : 쓰면 버려지는 곳, /dev/zero : 0 바이트 공급원 (모든 것은 파일)', '["sh", "-c", "true"]', '["sh", "-c", "( [ \\"$(wc -c < /tmp/zero.bin)\\" -eq 100 ] ) && ( [ \\"$(tr -d \\"\\\\000\\" < /tmp/zero.bin | wc -c)\\" -eq 0 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파일 크기가 100바이트다", "cmd": ["sh", "-c", "[ \\"$(wc -c < /tmp/zero.bin)\\" -eq 100 ]"]}, {"label": "내용이 모두 0 바이트다", "cmd": ["sh", "-c", "[ \\"$(tr -d \\"\\\\000\\" < /tmp/zero.bin | wc -c)\\" -eq 0 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 85 AND order_index = 11);
