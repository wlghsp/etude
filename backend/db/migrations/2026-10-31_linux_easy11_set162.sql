-- 리눅스 세트 162. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set162.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 162, '성능 읽기, top·ps·free·vmstat 와 좀비 프로세스 한 줄씩', '서버 성능 화면을 읽는 기본기를 한 개념씩 쉬운 문제로 반복합니다. top 의 Tasks·%Cpu(us·sy·id·wa)·메모리 줄, ps 의 STAT(R·S·D·Z·T)와 컬럼(%CPU·VSZ·RSS·TIME), VSZ 와 RSS 의 차이, --sort=-%cpu, %CPU 100 의 의미, 좀비 프로세스와 kill -9 로 안 죽는 이유, vmstat 의 첫 행·r·b·si·so, free 의 available 과 /proc/meminfo·/proc/loadavg 읽기를 짧은 객관식·빈칸·순서 문제로 익히고, 서버가 느릴 때 좁혀 가기, CPU 와 입출력 대기 구분, 좀비 정리, 메모리 읽기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 162);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '📈' WHERE id = 162;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 1, 'top 의 Tasks 줄', '`top` 화면의 `Tasks: 5 total, 1 running, 4 sleeping, 0 stopped, 0 zombie` 줄은 무엇을 알려 줄까요?', '프로세스를 상태별로 센 거예요.', NULL, NULL, '[]', 'choice', '["CPU 사용률의 평균", "메모리 사용량의 평균", "프로세스 전체 개수와 상태별 개수(실행 중, 잠든 중, 정지, 좀비). 좀비가 0 이 아니면 정리할 프로세스가 있다는 신호이다", "로그인한 사용자 수"]', 2, '대부분의 프로세스는 `sleeping` 입니다. 이벤트를 기다리며 자는 상태가 정상이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 2, 'top 의 %Cpu 줄', '`%Cpu(s): 1.7 us, 3.4 sy, 0.0 ni, 94.9 id, 0.0 wa, ...` 에서 `us`, `sy`, `id`, `wa` 는 각각 무엇일까요?', '사용자, 시스템(커널), 놀고 있음, 입출력 대기예요.', NULL, NULL, '[]', 'choice', '["`us` 는 사용자 수, `sy` 는 시스템 수, `id` 는 ID, `wa` 는 대기 중인 사용자", "`us` 는 일반 프로그램이 쓴 CPU, `sy` 는 커널이 쓴 CPU, `id` 는 놀고 있는 CPU, `wa` 는 디스크 같은 입출력을 기다린 시간의 비율", "모두 메모리 사용률이다", "`id` 는 에러, `wa` 는 경고이다"]', 1, '`id` 가 높으면 CPU 여유가 있고, `wa` 가 오래 높으면 디스크나 네트워크 저장소를 기다리는 일이 많다는 뜻입니다. 한 번의 값보다 추세를 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 3, '프로세스 상태 문자', '`ps` 의 `STAT` 열에서 `R`, `S`, `D`, `Z`, `T` 는 각각 무엇일까요?', '실행, 잠듦, 입출력 대기, 좀비, 정지예요.', NULL, NULL, '[]', 'choice', '["`R` 실행 중(또는 실행 대기), `S` 잠든 중(이벤트 대기), `D` 입출력 등을 기다리는 깨울 수 없는 잠, `Z` 좀비, `T` 정지", "`R` 재시작, `S` 시작, `D` 삭제, `Z` 압축, `T` 종료", "모두 실행 중이라는 뜻이다", "`R` 읽기, `S` 쓰기, `D` 삭제, `Z` 없음, `T` 전송"]', 0, 'CPU 를 많이 쓰는 프로세스는 `R`, 대기 중인 서비스는 `S` 로 보입니다. `D` 가 오래 이어지면 디스크나 네트워크 저장소 문제를 의심하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 4, '좀비 프로세스란', '`ps` 에 `Z` 상태와 `<defunct>` 로 보이는 프로세스는 무엇일까요?', '이미 끝났지만 아직 흔적이 남은 프로세스예요.', NULL, NULL, '[]', 'choice', '["CPU 를 가장 많이 쓰는 프로세스", "메모리를 가장 많이 쓰는 프로세스", "정지(`Ctrl+Z`)시킨 프로세스", "이미 종료됐지만 부모 프로세스가 종료 상태를 거두지 않아(`wait` 하지 않아) 목록에 남아 있는 프로세스"]', 3, '좀비는 CPU 나 메모리를 거의 쓰지 않지만 프로세스 번호(PID)를 차지합니다. 많이 쌓이면 새 프로세스를 못 만들 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 5, '좀비는 kill -9 로 안 죽는다', '좀비 프로세스(`Z`)에 `kill -9` 를 해도 목록에서 사라지지 않습니다. 정리하려면 어떻게 할까요?', '이미 죽은 프로세스를 다시 죽일 수는 없어요. 거두어야 할 쪽은 부모예요.', NULL, NULL, '[]', 'choice', '["`kill -9` 를 여러 번 반복한다", "서버를 재부팅하는 방법밖에 없다", "그 좀비의 부모 프로세스가 자식을 거두게 하거나 부모를 종료한다. 부모가 끝나면 좀비도 함께 정리된다", "`rm` 으로 프로세스 파일을 지운다"]', 2, '`ps -o ppid= -p 좀비PID` 로 부모를 찾습니다. 부모를 무작정 종료하기 전에 어떤 서비스인지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 6, 'ps aux 의 컬럼', '`ps aux` 결과의 `%CPU`, `%MEM`, `VSZ`, `RSS`, `TIME` 은 각각 무엇일까요?', '비율 둘, 크기 둘, 누적 시간이에요.', NULL, NULL, '[]', 'choice', '["`TIME` 은 현재 시각, `RSS` 는 읽기 속도", "`%CPU` 와 `%MEM` 은 CPU·메모리 사용 비율, `VSZ` 는 가상 메모리 크기, `RSS` 는 실제 물리 메모리 사용량(KB), `TIME` 은 지금까지 쓴 누적 CPU 시간", "`VSZ` 는 디스크 크기, `RSS` 는 네트워크 속도", "모두 파일 크기이다"]', 1, '`TIME` 은 프로세스가 켜져 있던 시간이 아니라 CPU 를 실제로 쓴 시간입니다. 오래 켜져 있어도 `TIME` 이 작을 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 7, 'RSS 와 VSZ', '`ps` 에서 `VSZ` 가 `RSS` 보다 훨씬 큰 것은 정상일까요?', '예약한 주소 공간과 실제로 쓰는 메모리는 달라요.', NULL, NULL, '[]', 'choice', '["정상이다. `VSZ` 는 예약한 가상 주소 공간이라 실제로 쓰는 `RSS` 보다 보통 훨씬 크다. 메모리가 부족한지는 `RSS` 와 `available` 로 판단한다", "비정상이며 메모리 누수의 증거이다", "`VSZ` 와 `RSS` 는 항상 같아야 한다", "`RSS` 가 `VSZ` 보다 항상 크다"]', 0, '`VSZ` 만 보고 메모리를 많이 쓴다고 판단하는 것은 흔한 오해입니다. 실제로 메모리를 차지하는 양은 `RSS` 예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 8, 'ps 정렬의 -', '`ps -eo pid,%cpu,comm --sort=-%cpu` 에서 `-%cpu` 의 `-` 는 무슨 뜻일까요?', '하이픈이 정렬 방향을 정해요.', NULL, NULL, '[]', 'choice', '["작은 값부터 정렬한다", "그 열을 숨긴다", "음수만 보여 준다", "큰 값부터(내림차순) 정렬한다. 그래서 CPU 를 가장 많이 쓰는 프로세스가 맨 위에 온다"]', 3, '`--sort=%cpu` 처럼 `-` 가 없으면 작은 값부터입니다. 부하 원인을 찾을 때는 `-` 를 붙이고 `head` 로 위쪽만 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 9, '%CPU 100 의 의미', '`top` 에서 한 프로세스의 `%CPU` 가 `100` 입니다. 무슨 뜻일까요? (CPU 코어는 4개)', '코어 하나를 꽉 채운 거예요.', NULL, NULL, '[]', 'choice', '["전체 CPU 4개를 모두 쓰고 있다", "프로세스가 100번 실행되었다", "CPU 코어 1개를 100% 쓰고 있다는 뜻이다. 코어가 4개면 전체 CPU 로는 약 25% 이다. 스레드가 여러 개면 100 을 넘을 수도 있다", "메모리를 100MB 쓰고 있다"]', 2, '`nproc` 으로 코어 수를 확인하고, 전체 부하는 `%Cpu(s)` 줄의 `id` 로 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 10, 'vmstat 의 첫 행', '`vmstat 1 5` 의 첫 번째 데이터 행은 다음 행들과 무엇이 다를까요?', '처음 줄은 특별해요.', NULL, NULL, '[]', 'choice', '["첫 행이 가장 최근 1초의 값이다", "첫 행은 부팅 이후의 평균값이고, 그다음 행부터가 지정한 간격(1초) 동안의 값이다. 지금의 상태는 두 번째 행부터 읽는다", "첫 행은 오류 메시지이다", "모든 행이 같은 값이다"]', 1, '한 번만 `vmstat` 를 실행하면 부팅 이후 평균만 보게 되어 현재 상황을 놓칩니다. 간격과 횟수를 주고 두 번째 행부터 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 11, 'vmstat 의 r 과 b', '`vmstat` 의 `r` 과 `b` 는 각각 무엇을 세는 값일까요?', '실행하려는 것과 막혀 있는 것이에요.', NULL, NULL, '[]', 'choice', '["`r` 은 실행 중이거나 CPU 를 기다리는 프로세스 수, `b` 는 입출력 등을 기다리며 막혀(잠들어) 있는 프로세스 수이다. `r` 이 CPU 코어 수보다 계속 크면 CPU 가 모자란 신호이다", "`r` 은 읽은 바이트, `b` 는 쓴 바이트", "`r` 은 재시작 횟수, `b` 는 부팅 횟수", "`r` 은 메모리, `b` 는 디스크"]', 0, 'CPU 를 쓰는 프로세스를 늘리면 `r` 이 늘고 `id` 가 줄어드는 것을 볼 수 있습니다. `b` 가 계속 0 보다 크면 입출력 병목을 의심하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 12, 'vmstat 의 si 와 so', '`vmstat` 에서 `si` 와 `so` 가 계속 0 이 아닌 값입니다. 무슨 뜻일까요?', 'swap 은 메모리가 모자랄 때 디스크를 대신 쓰는 거예요.', NULL, NULL, '[]', 'choice', '["네트워크 송수신량이 많다는 뜻이다", "CPU 온도가 높다는 뜻이다", "정상적인 상태이며 신경 쓸 필요가 없다", "메모리가 부족해 디스크의 swap 영역으로 내보내고(`so`) 다시 들여오는(`si`) 일이 계속되고 있다는 신호이다. 성능이 크게 떨어진다"]', 3, '이 값이 계속 0 이 아니면 메모리 부족을 의심하고 `free` 의 `available` 과 메모리를 많이 쓰는 프로세스를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 13, '/proc/loadavg 읽기', '`cat /proc/loadavg` 의 `0.72 1.12 0.88 1/123 4567` 에서 각 필드는 무엇일까요?', '앞의 세 개는 `uptime` 과 같아요.', NULL, NULL, '[]', 'choice', '["세 값은 CPU, 메모리, 디스크 사용률", "`1/123` 은 로그인한 사용자 수", "앞의 세 값은 1분, 5분, 15분 평균 부하, `1/123` 은 지금 실행 가능한 스케줄링 대상 수 / 전체 수, 마지막 `4567` 은 가장 최근에 만든 프로세스의 PID", "모든 필드가 시각을 뜻한다"]', 2, '`uptime` 의 `load average` 도 같은 값입니다. `nproc` 과 비교해 부하가 코어 수보다 계속 큰지 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 14, 'free 와 available', '`free` 의 `free` 열은 작은데 `available` 열은 큽니다. 메모리가 부족한 상태일까요?', '캐시로 쓰는 메모리는 필요하면 돌려줄 수 있어요.', NULL, NULL, '[]', 'choice', '["부족하다. `free` 열만 보면 된다", "부족하지 않다. 캐시(`buff/cache`)는 필요하면 회수되므로, 새 프로그램이 쓸 수 있는 양은 `available`(`/proc/meminfo` 의 `MemAvailable`)로 판단한다", "`available` 은 swap 크기이다", "`free` 와 `available` 은 항상 같다"]', 1, '리눅스는 남는 메모리를 파일 캐시로 쓰는 것이 정상이라 `free` 열이 작은 것은 흔합니다. `available` 이 작아지고 swap 을 쓰기 시작할 때 걱정하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 15, '한 번만 출력', '`top` 을 **화면 갱신 없이 한 번만** 출력(배치 모드)하려고 합니다. 횟수를 채우세요.', '한 번이라는 숫자예요.', NULL, NULL, '[]', 'fill', '["1", "0", "-1", "once"]', NULL, '`-b` 는 배치 모드, `-n` 은 반복 횟수입니다. 스크립트나 로그에 남길 때 씁니다.', '[0]', 'top -b -n {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 16, 'CPU 순으로 정렬', '`top` 을 **CPU 사용률 순**으로 정렬해 출력하는 옵션 값을 채우세요.', '열 이름이에요.', NULL, NULL, '[]', 'fill', '["%CPU", "CPU", "cpu-use", "-cpu"]', NULL, '`-o` 는 정렬 기준 열을 정합니다. 메모리 순으로는 `%MEM` 을 쓰세요.', '[0]', 'top -b -n 1 -o {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 17, '큰 순서로 정렬', '`ps` 의 결과를 **%CPU 가 큰 순서**로 정렬하는 기호를 채우세요.', '정렬 키 앞에 붙이는 기호예요.', NULL, NULL, '[]', 'fill', '["-", "+", "^", "!"]', NULL, '`+` 나 기호가 없으면 작은 값부터입니다. 원인 찾기에는 `head` 와 함께 쓰세요.', '[0]', 'ps -eo pid,%cpu,comm --sort={0}%cpu', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 18, '상태 열 보기', '`ps` 에 **프로세스 상태 열**을 포함하려고 합니다. 열 이름을 채우세요.', 'R, S, D, Z 가 나오는 열이에요.', NULL, NULL, '[]', 'fill', '["stat", "status", "proc", "flag"]', NULL, '`Z` 가 보이면 좀비입니다. `ppid` 를 함께 보면 부모를 바로 찾을 수 있어요.', '[0]', 'ps -eo pid,ppid,{0},comm', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 19, '좀비 찾기', '`ps aux` 에서 **좀비 프로세스**를 찾으려고 합니다. 검색할 단어를 채우세요.', '좀비는 이 단어와 함께 표시돼요.', NULL, NULL, '[]', 'fill', '["defunct", "zombie", "dead", "Z-state"]', NULL, '`ps` 의 COMMAND 열에 `<defunct>` 로 표시됩니다. `STAT` 열에서 `Z` 를 찾아도 돼요.', '[0]', 'ps aux | grep {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 20, '사람이 읽기 쉬운 단위', '`free` 의 출력을 **사람이 읽기 쉬운 단위**(Mi, Gi)로 보는 옵션을 채우세요.', 'human 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-h", "-m", "-g", "-s"]', NULL, '`-m` 은 메가바이트 숫자로 보여 줍니다. `available` 열이 실제로 쓸 수 있는 메모리예요.', '[0]', 'free {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 21, '부하 파일', '평균 부하 값을 담은 `/proc` 안의 **파일 이름**을 채우세요.', '"부하 평균"을 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["loadavg", "load", "uptime", "cpuload"]', NULL, '`uptime` 과 같은 세 값에 실행 가능 수와 마지막 PID 가 더해져 있습니다.', '[0]', 'cat /proc/{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 22, '메모리 상세 파일', '`MemAvailable` 이 들어 있는 `/proc` 안의 **파일 이름**을 채우세요.', '"메모리 정보"를 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["meminfo", "memory", "free", "mem"]', NULL, '`free` 의 `available` 열과 같은 값입니다. `MemFree` 가 작아도 `MemAvailable` 이 크면 안심해도 돼요.', '[0]', 'grep MemAvailable /proc/{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 23, '1초 간격으로 보기', '`vmstat` 을 **1초 간격으로 5번** 보려고 합니다. 간격을 채우세요.', '첫 숫자가 간격, 둘째가 횟수예요.', NULL, NULL, '[]', 'fill', '["1", "5", "0", "-1"]', NULL, '두 번째 행부터가 각 1초 동안의 값입니다. 첫 행은 부팅 이후 평균이에요.', '[0]', 'vmstat {0} 5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 24, '부모 PID 찾기', '좀비 프로세스의 **부모 PID** 를 알려 주는 열 이름을 채우세요.', 'parent PID 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["ppid", "pid", "pgid", "stat"]', NULL, '부모를 알면 어떤 서비스가 자식을 거두지 않는지 확인할 수 있습니다.', '[0]', 'ps -o {0}= -p 1234', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 25, 'CPU 코어 수', '**CPU 코어 수**를 출력하는 명령을 채우세요.', '"프로세서 수"를 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["nproc", "cpucount", "cores", "ncpu"]', NULL, 'load average 를 해석할 때 이 숫자와 비교합니다. 부하가 코어 수보다 계속 크면 일이 밀리는 거예요.', '[0]', '{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 26, '서버가 느릴 때 큰 그림에서 원인까지', '서버가 느릴 때 전체 상태에서 원인 프로세스까지 좁혀 가는 순서입니다. 순서에 맞게 놓아 보세요.', '부하 → CPU·메모리 → 프로세스 → 조치 순서예요.', NULL, NULL, '[]', 'order', '["`uptime` 으로 load average 가 코어 수보다 큰지 본다", "`top -b -n 1 | head -5` 로 Tasks, %Cpu, 메모리 줄을 본다", "`ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head` 로 CPU 를 많이 쓰는 프로세스를 찾는다", "원인 프로세스의 로그를 확인하고 조치(재시작, 설정 수정 등)한다"]', NULL, '서버 전체 상태를 먼저 보고 점점 좁히는 순서가 효율적입니다. 바로 프로세스를 종료하지 마세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 27, 'CPU 부하인지 입출력 대기인지 구분하기', '느림의 원인이 CPU 인지 입출력 대기인지 구분하는 순서입니다. 순서에 맞게 놓아 보세요.', 'CPU 줄 → 추세 → 갈래 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`top` 의 `%Cpu(s)` 줄에서 `us`·`sy` 와 `wa` 를 비교한다", "`vmstat 1 5` 로 `r`, `b`, `wa`, `id` 의 추세를 본다", "`wa` 와 `b` 가 높으면 디스크나 저장소를, `r` 이 높고 `id` 가 낮으면 CPU 를 의심한다", "의심한 쪽을 확인한다 (디스크 사용량, 느린 쿼리, CPU 많이 쓰는 프로세스)"]', NULL, '한 번의 값이 아니라 몇 초간의 추세를 보세요. `vmstat` 은 두 번째 행부터 읽습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 28, '좀비 프로세스 정리하기', '좀비 프로세스를 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '찾기 → 부모 찾기 → 부모 조치 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`ps aux | grep defunct` 로 좀비의 PID 를 찾는다", "`ps -o ppid= -p 좀비PID` 로 부모 PID 를 찾는다", "부모가 어떤 서비스인지 확인하고 정상 종료를 요청하거나 재시작한다", "`ps` 로 좀비가 사라졌는지 확인한다"]', NULL, '좀비에게 `kill -9` 를 해도 소용없습니다. 근본 해결은 부모가 자식을 거두도록 고치는 것이에요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 29, '메모리 읽고 원인 찾기', '메모리가 부족해 보일 때 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '전체 → 여유 → 프로세스 → 회복 확인 순서예요.', NULL, NULL, '[]', 'order', '["`free -h` 로 전체 메모리와 swap 사용량을 본다", "`available` 이 충분한지 본다 (`free` 가 작아도 `available` 이 크면 괜찮다)", "`ps -eo pid,%mem,rss,comm --sort=-%mem | head` 로 메모리를 많이 쓰는 프로세스를 본다", "조치한 뒤 `free -h` 로 `available` 이 회복됐는지 확인한다"]', NULL, '`vmstat` 의 `si`/`so` 가 계속 0 이 아니라면 swap 을 쓰고 있다는 뜻이니 더 서둘러야 합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 29);
