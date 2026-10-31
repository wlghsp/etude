-- 리눅스 세트 144. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set144.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 144, '리눅스 쉬운 문제 6: 로그 읽기, 파일 찾기, 링크, inode, 신호 한 줄씩', '리눅스 서버에서 문제를 찾을 때 자주 쓰는 도구를 한 개념씩 쉬운 문제로 반복합니다. /var/log, journalctl -p·--since, dmesg, 압축된 로그(zcat·zgrep), less 안의 검색, find 의 -name 따옴표·-type·-mtime·-size 부호, 심볼릭 링크와 하드 링크의 차이, df -i 와 inode, kill 과 kill -9 의 차이와 종료 코드, uptime 의 load average 읽기를 짧은 객관식·빈칸·순서 문제로 익히고, 로그로 서비스 오류 찾기, 큰 파일 정리, 용량이 남는데 파일이 안 만들어질 때, 멈춘 프로세스 종료의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 144);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '📜' WHERE id = 144;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 1, '/var/log 는 어떤 곳일까', '리눅스 서버에서 `/var/log` 폴더에는 보통 무엇이 있을까요?', '"기록"을 뜻하는 log 예요.', NULL, NULL, '[]', 'choice', '["설치된 프로그램의 실행 파일", "사용자의 홈 폴더", "시스템과 서비스가 남긴 로그 파일들", "임시로 쓰고 지우는 파일"]', 2, '문제가 생기면 이 폴더에서 시간과 서비스 이름으로 로그를 찾는 것이 첫걸음입니다. 서비스마다 하위 폴더나 파일이 따로 있는 경우도 많아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 2, 'journalctl -p err', '`journalctl -p err` 는 무엇을 보여 줄까요?', '`-p` 는 priority(우선순위)예요.', NULL, NULL, '[]', 'choice', '["모든 로그를 오래된 순서대로", "오류(err) 이상의 심각한 우선순위 로그만", "가장 최근 한 줄만", "로그의 개수만"]', 1, '정보성 로그가 너무 많을 때 `-p err` 로 줄이면 문제의 단서만 모아 볼 수 있습니다. `-p warning` 으로 범위를 넓힐 수도 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 3, 'journalctl --since', '`journalctl -u nginx --since "1 hour ago"` 는 무엇을 보여 줄까요?', '시작 시점을 정해요.', NULL, NULL, '[]', 'choice', '["nginx 서비스의 최근 1시간 로그", "nginx 서비스의 1시간 전 로그 한 줄", "모든 서비스의 1시간치 로그", "nginx 의 설정 변경 이력"]', 0, '문제가 일어난 시각을 알면 `--since`(그 이후)와 `--until`(그 이전)로 범위를 좁힐 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 4, 'dmesg 는 무엇일까', '`dmesg` 는 무엇을 보여 줄까요?', '운영체제의 가장 안쪽에서 남기는 메시지예요.', NULL, NULL, '[]', 'choice', '["사용자가 입력한 명령의 기록", "웹 서버의 접속 기록", "설치된 패키지 목록", "커널(운영체제 핵심)이 남긴 메시지 (하드웨어 오류, 메모리 부족으로 프로세스를 종료한 기록 등)"]', 3, '프로세스가 이유 없이 사라졌다면 `dmesg` 에서 메모리 부족(OOM)으로 종료됐는지 확인해 보세요. 일반 사용자는 권한이 필요할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 5, '오래된 로그 읽기', '`app.log.1.gz` 처럼 이름 끝이 `.gz` 인 로그 안의 `ERROR` 를 찾으려면 어떻게 할까요?', '압축을 풀어서 읽는 도구가 있어요.', NULL, NULL, '[]', 'choice', '["`.gz` 파일은 읽을 수 없으니 지운다", "`cat` 만 쓰면 바로 읽힌다", "`zcat app.log.1.gz | grep ERROR` 처럼 압축을 풀어 내용을 읽는다", "이름에서 `.gz` 를 지우면 읽힌다"]', 2, '로그는 용량 때문에 주기적으로 이름이 바뀌고(`.1`) 압축됩니다(`.gz`). `zcat`, `zgrep`, `zless` 로 풀지 않고 읽을 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 6, 'less 안에서 검색', '`less app.log` 로 큰 로그를 보는 중입니다. `ERROR` 를 검색하려면 어떻게 할까요?', '슬래시를 누르고 단어를 쓰는 방식이에요.', NULL, NULL, '[]', 'choice', '["`find ERROR` 를 입력한다", "`/ERROR` 를 입력하고 Enter, 다음 결과는 `n`, 끝내려면 `q`", "Ctrl+C 를 누른다", "`quit ERROR` 를 입력한다"]', 1, '`less` 는 큰 파일을 한 화면씩 보여 줍니다. `/` 로 아래쪽 검색, `?` 로 위쪽 검색, `G` 로 맨 끝으로 이동해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 7, 'find 의 따옴표', '`find . -name *.log` 처럼 패턴을 따옴표 없이 쓰면 어떤 문제가 생길 수 있을까요?', '쉘이 별표를 먼저 풀어 버릴 수 있어요.', NULL, NULL, '[]', 'choice', '["현재 폴더에 `.log` 파일이 여럿이면 쉘이 먼저 펼쳐서 `find` 가 오류를 낸다. `\\"*.log\\"` 처럼 따옴표로 감싸야 한다", "아무 문제가 없다", "모든 파일이 삭제된다", "`find` 가 더 빨리 끝난다"]', 0, '`*` 를 `find` 에게 그대로 넘기려면 따옴표가 필요합니다. 따옴표를 쓰면 하위 폴더까지 모두 찾아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 8, 'mtime 읽기', '`find . -mtime -1` 은 어떤 파일을 찾을까요?', '`-1` 은 "1일보다 적게"예요.', NULL, NULL, '[]', 'choice', '["1일보다 오래전에 수정된 파일", "정확히 1바이트인 파일", "1개만 찾고 멈춘다", "최근 1일(24시간) 이내에 수정된 파일"]', 3, '`-mtime +1` 은 1일보다 오래된 파일입니다. 부호의 방향을 헷갈리지 않게 `-` 는 "이내", `+` 는 "이전"으로 기억하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 9, '큰 파일 찾기', '`find / -size +100M` 은 어떤 파일을 찾을까요?', '플러스는 "그보다 크다"예요.', NULL, NULL, '[]', 'choice', '["100MB 보다 작은 파일", "이름에 100M 이 들어간 파일", "100MB 보다 큰 파일", "정확히 100MB 인 파일만"]', 2, '디스크가 부족할 때 큰 파일부터 찾는 데 유용합니다. 지우기 전에는 무엇인지 꼭 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 10, '심볼릭 링크', '`ln -s /opt/app/current /srv/app` 로 만든 심볼릭 링크는 무엇일까요?', '바로 가기와 비슷해요.', NULL, NULL, '[]', 'choice', '["원본을 복사한 완전히 독립된 파일", "원본 경로를 가리키는 바로 가기. 원본이 사라지면 링크가 끊긴다", "원본의 권한만 복사한 파일", "원본을 압축한 파일"]', 1, '`ls -l` 에서 `링크 -> 원본` 으로 보입니다. 원본을 지우면 링크를 열 때 `No such file or directory` 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 11, '하드 링크와의 차이', '하드 링크(`ln 원본 이름`)와 심볼릭 링크(`ln -s`)의 차이로 알맞은 것은 무엇일까요?', '하나는 같은 데이터에 이름을 더하고, 하나는 경로를 가리켜요.', NULL, NULL, '[]', 'choice', '["하드 링크는 같은 데이터에 이름을 하나 더 붙이는 것이라 원본 이름을 지워도 데이터가 남고, 심볼릭 링크는 원본이 사라지면 끊긴다", "둘은 완전히 같다", "하드 링크는 원본을 지우면 데이터가 같이 사라진다", "심볼릭 링크는 원본 파일의 복사본이다"]', 0, '서비스의 현재 버전을 가리키는 `current` 링크처럼 버전을 바꿔 가며 쓸 때는 심볼릭 링크를 흔히 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 12, 'inode 가 다 차면', '`df -h` 에서는 디스크 용량이 충분한데 새 파일을 만들면 `No space left on device` 가 납니다. 의심할 것은 무엇일까요?', '용량 말고 "파일의 개수"에도 한계가 있어요.', NULL, NULL, '[]', 'choice', '["메모리가 부족하다", "네트워크가 끊겼다", "파일 이름이 너무 길다", "inode(파일 개수 한도)가 다 찼을 수 있다. `df -i` 로 확인한다"]', 3, '아주 작은 파일이 수백만 개 쌓이면 용량은 남아도 inode 가 바닥납니다. `df -i` 의 `IUse%` 를 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 13, 'kill 과 kill -9', '`kill 1234` 와 `kill -9 1234` 의 차이로 알맞은 것은 무엇일까요?', '하나는 정중히 부탁하고 하나는 강제로 끊어요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`-9` 가 더 안전하다", "`kill` 은 종료를 요청하는 신호(15)를 보내 정리할 시간을 주고, `-9` 는 강제 종료라 정리 없이 즉시 끝낸다", "`kill` 은 파일을 삭제한다"]', 2, '먼저 `kill` 로 요청하고, 그래도 안 죽을 때만 `-9` 를 쓰세요. 종료 코드는 정상 요청이 143, 강제 종료가 137 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 14, 'load average 읽기', '`uptime` 의 `load average: 0.45, 0.66, 0.76` 에서 세 숫자는 무엇일까요?', '1분, 5분, 15분 순서예요.', NULL, NULL, '[]', 'choice', '["CPU, 메모리, 디스크 사용률", "최근 1분, 5분, 15분 동안의 평균 부하", "로그인한 사용자 수 세 개", "프로세스 수의 최솟값, 평균, 최댓값"]', 1, '숫자가 CPU 코어 수보다 계속 크면 일이 밀리고 있다는 신호입니다. 1분 값이 15분 값보다 높으면 부하가 늘고 있는 중이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 15, '끝부분 줄 수 정하기', '로그의 **마지막 50줄**을 보는 옵션입니다. 빈칸을 채우세요.', 'number 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-f", "-s", "-l"]', NULL, '`tail -n 50` 은 마지막 50줄을 한 번 보여 줍니다. `-f` 는 계속 따라가는 것이라 목적이 달라요.', '[0]', 'tail {0} 50 app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 16, '압축된 로그 읽기', '압축된 로그를 풀어 **ERROR 가 든 줄만** 걸러 보려고 합니다. 명령을 채우세요.', '글자를 찾는 명령이에요.', NULL, NULL, '[]', 'fill', '["grep", "find", "less", "sort"]', NULL, '`zcat` 은 압축을 풀어 표준 출력으로 보냅니다. 파이프로 `grep` 에 이어 붙이면 걸러 볼 수 있어요.', '[0]', 'zcat app.log.1.gz | {0} ERROR', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 17, '오류만 보기', '시스템 저널에서 **오류 이상**의 로그만 보는 옵션입니다. 빈칸을 채우세요.', 'priority 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-p", "-u", "-f", "-n"]', NULL, '`-u` 는 서비스를, `-p` 는 심각도를 고릅니다. 둘을 함께 써서 서비스의 오류만 볼 수도 있어요.', '[0]', 'journalctl {0} err', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 18, '시작 시각 정하기', '**최근 1시간** 로그부터 보려고 합니다. 옵션을 채우세요.', '"~이후로"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["since", "after", "from", "last"]', NULL, '`--since "2026-10-31 09:00"` 처럼 구체적인 시각도 쓸 수 있습니다. 문제가 시작된 시점부터 보는 것이 좋아요.', '[0]', 'journalctl --{0} "1 hour ago"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 19, '이름으로 파일 찾기', '`/var/log` 아래에서 **이름이 .log 로 끝나는** 파일을 찾으려고 합니다. 패턴을 채우세요.', '쉘이 먼저 풀지 않도록 따옴표로 감싸요.', NULL, NULL, '[]', 'fill', '["\\"*.log\\"", "log", "-*.log", "(.log)"]', NULL, '따옴표로 감싼 패턴은 `find` 가 직접 해석해서 하위 폴더까지 찾습니다.', '[0]', 'find /var/log -name {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 20, '일반 파일만 찾기', '현재 폴더 아래에서 **일반 파일만** 찾는 옵션입니다. 빈칸을 채우세요.', 'file 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["f", "d", "n", "x"]', NULL, '`-type d` 는 폴더입니다. 파일과 폴더를 섞어 찾으면 결과가 헷갈릴 수 있어요.', '[0]', 'find . -type {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 21, '최근 하루 이내', '`find` 로 **최근 1일 이내** 수정된 파일을 찾는 부호를 채우세요.', '"이내"는 마이너스, "이전"은 플러스예요.', NULL, NULL, '[]', 'fill', '["-", "+", "=", "~"]', NULL, '`-mtime -1` 은 1일 이내, `+1` 은 1일보다 오래된 파일입니다. 부호의 방향을 꼭 외워 두세요.', '[0]', 'find . -mtime {0}1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 22, '큰 파일 기준', '**100MB 보다 큰** 파일을 찾는 부호를 채우세요.', '"그보다 크다"를 뜻하는 부호예요.', NULL, NULL, '[]', 'fill', '["+", "-", ">", "~"]', NULL, '`-size -100M` 은 100MB 보다 작은 파일입니다. 크기 단위는 `k`, `M`, `G` 를 쓸 수 있어요.', '[0]', 'find / -size {0}100M', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 23, '심볼릭 링크 만들기', '`/opt/app/current` 를 가리키는 **심볼릭 링크**를 만드는 옵션입니다. 빈칸을 채우세요.', 'symbolic 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-s", "-h", "-l", "-c"]', NULL, '옵션이 없으면 하드 링크가 만들어집니다. 심볼릭 링크는 `-s` 를 꼭 붙여야 해요.', '[0]', 'ln {0} /opt/app/current /srv/app', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 24, 'inode 사용량 보기', '디스크의 **inode 사용량**을 보는 옵션입니다. 빈칸을 채우세요.', 'inode 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-h", "-a", "-t"]', NULL, '`df -h` 는 용량, `df -i` 는 파일 개수 한도를 보여 줍니다. 용량이 남았는데 못 쓰면 `-i` 도 보세요.', '[0]', 'df {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 25, '강제 종료하기', '정중한 종료에 응하지 않는 프로세스 `1234` 를 **강제 종료**하려고 합니다. 신호 번호를 채우세요.', 'KILL 신호의 번호예요.', NULL, NULL, '[]', 'fill', '["9", "15", "1", "0"]', NULL, '기본 신호는 15(TERM)이고, 9(KILL)는 마지막 수단입니다. 강제 종료된 프로세스는 파일을 정리하지 못할 수 있어요.', '[0]', 'kill -{0} 1234', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 26, '서비스 오류를 로그로 찾기', '서비스가 실패했을 때 로그로 원인을 좁혀 가는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → 최근 로그 → 오류 범위 좁히기 → 고치고 재시작 순서예요.', NULL, NULL, '[]', 'order', '["`systemctl status 서비스` 로 상태와 마지막 로그를 본다", "`journalctl -u 서비스 -n 50` 으로 최근 로그 50줄을 본다", "`journalctl -p err --since \\"1 hour ago\\"` 로 오류만 시간 범위로 좁힌다", "원인을 고치고 `systemctl restart 서비스` 로 다시 시작한다"]', NULL, '넓게 보고 점점 좁히는 순서가 효율적입니다. 시각과 서비스 이름이 단서가 돼요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 27, '디스크 큰 파일 찾아 정리하기', '디스크가 거의 찼을 때 큰 파일을 찾아 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '전체 → 큰 폴더 → 큰 파일 → 정리 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`df -h` 로 어느 파티션이 찼는지 본다", "`du -sh /var/* | sort -h` 로 큰 폴더를 찾는다", "`find /var/log -size +100M` 로 큰 파일을 찾는다", "필요 없는 파일을 정리하고 `df -h` 로 줄었는지 확인한다"]', NULL, '지우기 전에 무엇인지 확인하세요. 실행 중인 서비스가 쓰는 로그는 지우기보다 압축이나 비우기가 안전한 경우가 많아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 28, '용량은 남는데 파일이 안 만들어질 때', '`No space left on device` 인데 `df -h` 에 여유가 있을 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '용량 확인 → inode 확인 → 원인 폴더 찾기 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`df -h` 로 용량 여유를 확인한다", "`df -i` 로 inode 가 다 찼는지 본다", "파일이 많은 폴더를 찾는다 (예: `find /var/spool -type f | wc -l`)", "작은 파일을 정리하고 `df -i` 로 다시 확인한다"]', NULL, '용량과 inode 는 서로 다른 한도입니다. 둘 다 확인해야 원인을 놓치지 않아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 29, '멈춘 프로세스 종료하기', '멈춘 프로세스를 안전하게 종료하는 순서입니다. 순서에 맞게 놓아 보세요.', '찾기 → 정중히 요청 → 확인 → 강제 종료 순서예요.', NULL, NULL, '[]', 'order', '["`ps aux | grep 이름` 으로 PID 를 찾는다", "`kill PID` 로 정중하게 종료를 요청한다", "잠시 뒤 `ps` 로 프로세스가 사라졌는지 확인한다", "그래도 남아 있으면 `kill -9 PID` 로 강제 종료한다"]', NULL, '바로 `kill -9` 를 쓰면 프로세스가 마무리하지 못하고 끝납니다. 먼저 정중하게 요청해 보세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 29);
