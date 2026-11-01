-- 리눅스 세트 156. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set156.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 156, '네트워크 읽기(경로, DNS, curl, LISTEN)와 텍스트 도구 심화 한 줄씩', '서버의 네트워크 문제를 읽는 도구와 텍스트 도구의 옵션을 한 개념씩 쉬운 문제로 반복합니다. ip route 의 default via 와 게이트웨이가 없을 때의 증상, resolv.conf 의 nameserver 와 getent hosts, curl 의 상태 코드와 -f·-m·-I·-v 및 종료 코드 7·6·28, ss 의 LISTEN 주소(127.0.0.1 과 0.0.0.0 의 차이), grep 의 -i·-l·-w·-A/-B/-C, awk 의 조건과 합계, sort -k·-n, tail -n +2 를 짧은 객관식·빈칸·순서 문제로 익히고, 이름→경로→응답 점검, 로그 에러 맥락 보기, 표의 합계·평균, 헤더 있는 CSV 의 최댓값 찾기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 156);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🌐' WHERE id = 156;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 1, 'default via 읽기', '`ip route` 결과에 `default via 게이트웨이주소 dev eth0` 줄이 있습니다. 무슨 뜻일까요?', '목적지를 모를 때 보내는 기본 출구예요.', NULL, NULL, '[]', 'choice', '["이 컴퓨터의 IP 주소", "DNS 서버의 주소", "같은 망에 없는 목적지로 가는 패킷을 이 게이트웨이로 보낸다는 기본 경로", "방화벽이 막은 주소"]', 2, '`default` 줄이 없으면 같은 망 밖(인터넷 등)으로 나갈 길이 없습니다. 외부 접속이 안 될 때 가장 먼저 보는 줄이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 2, '게이트웨이가 없을 때', '`ip route` 에 `default` 경로가 없다면 어떤 증상이 생길까요?', '같은 망 안은 되지만 밖으로 나갈 출구가 없어요.', NULL, NULL, '[]', 'choice', '["같은 망 안에서도 통신이 전혀 안 된다", "같은 망 안의 서버와는 통신되지만 인터넷 같은 바깥 망으로는 나가지 못한다", "이름을 IP 로 바꾸지 못한다", "디스크가 가득 찬다"]', 1, '같은 망에는 `scope link` 로 표시된 직접 연결 경로가 있어서 통신됩니다. 바깥으로 나가려면 기본 게이트웨이가 필요해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 3, 'resolv.conf 의 nameserver', '`/etc/resolv.conf` 의 `nameserver 주소` 줄은 무엇일까요?', '이름을 번호로 바꿔 줄 서버예요.', NULL, NULL, '[]', 'choice', '["이름(도메인)을 IP 로 바꿔 줄 DNS 서버의 주소", "기본 게이트웨이의 주소", "이 컴퓨터의 이름", "접속을 허용할 서버 목록"]', 0, '이름으로만 접속이 안 되고 IP 로는 되면 이 파일의 DNS 서버가 맞는지 확인하세요. `getent hosts 이름` 으로 실제 해석 결과를 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 4, 'getent hosts', '`getent hosts myapp.test` 는 무엇을 보여 줄까요?', '시스템이 실제로 이름을 푸는 방식을 따라가 봐요.', NULL, NULL, '[]', 'choice', '["그 이름의 서버가 켜져 있는지", "그 이름이 가리키는 서버의 포트 목록", "그 이름의 소유자", "`/etc/hosts` 와 DNS 설정을 포함해, 시스템이 그 이름을 어떤 IP 로 해석하는지 (찾지 못하면 종료 코드 2)"]', 3, '`/etc/hosts` 에 등록한 이름도 `getent` 에는 나옵니다. `nslookup` 같은 도구는 DNS 서버만 보므로 결과가 다를 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 5, 'curl 과 404', '`curl -s -o /dev/null http://서버/nope` 가 404 를 받았을 때 `echo $?` 의 값은 무엇일까요?', 'curl 은 "전송이 성공했는가"를 기준으로 해요.', NULL, NULL, '[]', 'choice', '["항상 `404`", "항상 `1`", "`0` (서버가 응답을 줬으므로 성공으로 본다). HTTP 오류를 실패로 취급하려면 `-f` 를 주며, 그러면 `22` 가 된다", "항상 `22`"]', 2, '스크립트에서 서비스 상태를 확인할 때 `-f` 를 빼먹으면 404 나 500 도 성공으로 처리되는 실수가 흔합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 6, 'curl 종료 코드', '`curl` 의 종료 코드 `7`, `6`, `28` 은 각각 무엇을 뜻할까요?', '연결, 이름, 시간과 관련 있어요.', NULL, NULL, '[]', 'choice', '["`7` 은 DNS, `6` 은 시간 초과, `28` 은 연결 거부", "`7` 은 연결 거부(그 포트에서 듣는 프로그램 없음), `6` 은 이름을 IP 로 못 바꿈(DNS), `28` 은 시간 초과", "셋 모두 같은 뜻이다", "`7` 은 성공, `6` 과 `28` 은 실패이다"]', 1, '종료 코드만 봐도 어느 단계에서 막혔는지 짐작할 수 있습니다. `7` 이면 서버 쪽 서비스를, `6` 이면 이름 해석을, `28` 이면 방화벽·경로를 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 7, 'curl -I 와 -v', '`curl -I` 와 `curl -v` 의 차이로 알맞은 것은 무엇일까요?', '하나는 헤더만, 하나는 과정을 모두 보여 줘요.', NULL, NULL, '[]', 'choice', '["`-I` 는 본문 없이 응답 헤더(상태 줄 포함)만 가져오고, `-v` 는 요청(`>`)과 응답(`<`) 헤더 과정을 자세히 보여 준다", "둘은 완전히 같다", "`-I` 는 파일을 저장하고 `-v` 는 삭제한다", "`-v` 는 본문 없이 헤더만 가져온다"]', 0, '연결이 안 될 때는 `-v` 로 어느 단계에서 멈추는지 보고, 응답만 간단히 확인할 때는 `-I` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 8, 'LISTEN 주소 읽기', '`ss -tln` 에 `127.0.0.1:9000` 과 `0.0.0.0:9001` 이 LISTEN 입니다. 다른 컴퓨터(컨테이너)에서 접속되는 쪽은 어느 것일까요?', '앞은 자기 자신에게만 열려 있어요.', NULL, NULL, '[]', 'choice', '["둘 다 접속된다", "`127.0.0.1:9000` 만 접속된다", "둘 다 접속되지 않는다", "`0.0.0.0:9001` 만 접속된다. `127.0.0.1:9000` 은 그 컴퓨터 자신만 접속할 수 있어 밖에서는 `Connection refused` 가 난다"]', 3, '서비스는 떠 있는데 밖에서만 안 된다면 설정에서 듣는 주소를 `0.0.0.0` 으로 바꿔야 하는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 9, 'grep -i 와 -l', '`grep -il error *.log` 에서 `-i` 와 `-l` 은 각각 무엇일까요?', '하나는 대소문자, 하나는 파일 이름이에요.', NULL, NULL, '[]', 'choice', '["`-i` 는 줄 번호, `-l` 은 줄 수", "`-i` 는 반대로 찾기, `-l` 은 재귀 검색", "`-i` 는 대소문자를 구분하지 않고, `-l` 은 일치하는 줄 대신 일치한 파일의 이름만 보여 준다", "둘 다 결과를 정렬한다"]', 2, '`error` 가 어느 로그 파일에 있는지 먼저 찾고 그 파일만 열어 볼 때 `-l` 이 편합니다. 대소문자가 섞인 로그에는 `-i` 가 필수예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 10, 'grep -w', '`grep -w cat w.txt` 와 `grep cat w.txt` 의 차이로 알맞은 것은 무엇일까요? (파일에는 `cat`, `category`, `the cat sat` 가 있다)', 'w 는 word(단어)예요.', NULL, NULL, '[]', 'choice', '["둘은 같다", "`-w` 는 독립된 단어로 일치하는 줄만 찾아 `category` 는 제외한다 (2줄). 옵션이 없으면 `category` 도 포함한다 (3줄)", "`-w` 가 더 많은 줄을 찾는다", "`-w` 는 줄 전체가 일치해야 한다"]', 1, '짧은 단어를 찾을 때 긴 단어에 포함된 것까지 걸러지는 것을 막아 줍니다. 줄 전체가 일치해야 하는 옵션은 `-x` 예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 11, 'grep 앞뒤 줄', '`grep -A1 ERR c.txt`, `-B1`, `-C1` 은 각각 무엇을 함께 보여 줄까요?', 'After, Before, Context 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["`-A1` 은 일치한 줄의 뒤 1줄, `-B1` 은 앞 1줄, `-C1` 은 앞뒤 1줄을 함께 보여 준다", "`-A1` 은 앞 1줄, `-B1` 은 뒤 1줄", "모두 일치한 줄만 보여 준다", "`-C1` 은 파일 전체를 보여 준다"]', 0, '에러 한 줄만으로는 원인을 알기 어려울 때 앞뒤 줄이 단서가 됩니다. 숫자를 늘려 `-C5` 처럼 더 넓게 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 12, 'awk 조건', '`awk ''$2 > 28 {print $1}'' p.txt` 는 무엇을 출력할까요? (각 줄은 `이름 나이 도시` 모양)', '조건에 맞는 줄만 처리해요.', NULL, NULL, '[]', 'choice', '["모든 줄의 첫 번째 칸", "나이가 28 이하인 줄의 이름", "두 번째 칸의 합계", "두 번째 칸(나이)이 28 보다 큰 줄의 첫 번째 칸(이름)"]', 3, '`awk` 는 `조건 {동작}` 모양입니다. 조건만 쓰고 동작을 생략하면 조건에 맞는 줄 전체를 출력해요(`awk ''$3=="Seoul"''`).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 13, 'awk 합계', '`awk ''{s+=$2} END{print s}'' p.txt` 는 무엇을 계산할까요?', 'END 는 모든 줄을 읽은 뒤 한 번 실행돼요.', NULL, NULL, '[]', 'choice', '["줄마다 두 번째 칸을 출력한다", "두 번째 칸의 최댓값을 출력한다", "모든 줄의 두 번째 칸 값을 더해 마지막에 한 번 출력한다 (합계)", "줄의 개수를 출력한다"]', 2, '평균은 같은 방식으로 `END{print s/NR}` 처럼 `NR`(읽은 줄 수)로 나눕니다. 합계, 개수, 평균을 로그 분석에서 자주 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 14, 'sort 숫자 정렬', '`sort -t, -k1 n.csv` 와 `sort -t, -k1 -n n.csv` 의 결과 차이로 알맞은 것은 무엇일까요? (첫 칸 값은 10, 9, 100)', '문자로 정렬하면 숫자의 크기와 달라요.', NULL, NULL, '[]', 'choice', '["둘 다 `9 10 100`", "`-n` 이 없으면 문자(사전순)라서 `10 100 9`, `-n` 을 주면 숫자 크기순이라 `9 10 100` 이 된다", "둘 다 `10 100 9`", "`-n` 을 주면 역순이 된다"]', 1, '`-t,` 는 구분 문자를 쉼표로, `-k1` 은 첫 번째 칸을 기준으로 정합니다. 숫자 칸을 정렬할 때는 항상 `-n` 을 붙이세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 15, '경로 보기', '시스템의 **경로(라우팅) 표**를 보는 명령입니다. 빈칸을 채우세요.', '"길"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["route", "gateway", "path", "net"]', NULL, '`default via ...` 줄이 기본 게이트웨이입니다. `ip addr` 은 주소, `ip route` 는 길을 보여 줘요.', '[0]', 'ip {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 16, '대소문자 무시', '`error` 를 **대소문자 구분 없이** 찾는 옵션입니다. 빈칸을 채우세요.', 'ignore case 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-v", "-w", "-x"]', NULL, '`Error`, `ERROR`, `error` 를 모두 찾습니다. 반대로 찾기(`-v`)와 헷갈리지 마세요.', '[0]', 'grep {0} error log.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 17, '파일 이름만 보기', '`error` 가 **들어 있는 파일의 이름만** 보는 옵션입니다. 빈칸을 채우세요.', 'list 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-l", "-c", "-n", "-h"]', NULL, '어느 파일에 있는지 먼저 찾을 때 씁니다. 줄 수는 `-c`, 줄 번호는 `-n` 이에요.', '[0]', 'grep {0} error *.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 18, '단어 단위로 찾기', '`cat` 을 **독립된 단어로만** 찾는 옵션입니다. 빈칸을 채우세요.', 'word 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-w", "-x", "-v", "-o"]', NULL, '`-w` 가 없으면 `category` 처럼 글자가 들어 있는 줄도 모두 나옵니다. `-x` 는 줄 전체가 일치할 때만이에요.', '[0]', 'grep {0} cat w.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 19, '뒤 한 줄 함께 보기', '일치한 줄과 그 **뒤 한 줄**을 함께 보는 옵션을 채우세요.', 'After 의 첫 글자와 숫자 1 이에요.', NULL, NULL, '[]', 'fill', '["-A1", "-B1", "-C1", "-N1"]', NULL, '`-B1` 은 앞 줄, `-C1` 은 앞뒤 줄입니다. 로그에서 에러의 앞뒤 맥락을 볼 때 씁니다.', '[0]', 'grep {0} ERR c.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 20, '상태 코드만 출력', '`curl` 이 받은 **HTTP 상태 코드만** 출력하는 옵션을 채우세요. (본문은 버립니다)', 'write-out 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-w", "-o", "-f", "-m"]', NULL, '`-o /dev/null` 은 본문을 버립니다. 서비스가 200 으로 응답하는지 스크립트에서 확인할 때 자주 써요.', '[0]', 'curl -s -o /dev/null {0} "%{http_code}" http://localhost/', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 21, 'HTTP 오류를 실패로', '`curl` 이 404 나 500 같은 HTTP 오류를 **실패(종료 코드 22)로 취급**하게 하는 옵션입니다. 빈칸을 채우세요.', 'fail 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-s", "-I", "-L"]', NULL, '`-f` 가 없으면 404 에도 종료 코드가 `0` 입니다. 상태 점검 스크립트에는 꼭 필요해요.', '[0]', 'curl {0} http://localhost/nope', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 22, '시간 제한 두기', '`curl` 이 **2초 안에** 끝나지 않으면 포기하게 하는 옵션입니다. 빈칸을 채우세요.', 'max-time 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-m", "-t", "-w", "-T"]', NULL, '시간이 초과되면 종료 코드 `28` 로 끝납니다. 응답이 없는 서버에 무한히 매달리는 것을 막아 줘요.', '[0]', 'curl {0} 2 http://localhost/', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 23, '칸 값 비교하기', '`awk` 에서 **두 번째 칸이 28 보다 큰** 줄을 고르는 비교 연산자를 채우세요.', '"크다"를 뜻하는 기호예요.', NULL, NULL, '[]', 'fill', '[">", "=>", "gt", "-gt"]', NULL, '`awk` 안에서는 일반 비교 기호를 씁니다. `-gt` 는 쉘의 `[ ]` 에서 쓰는 방식이에요.', '[0]', 'awk ''$2 {0} 28 {print $1}'' p.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 24, '두 번째 칸으로 숫자 정렬', '`sort` 로 **두 번째 칸을 숫자로** 정렬하는 옵션을 채우세요.', '칸 번호와 숫자 정렬을 함께 써요.', NULL, NULL, '[]', 'fill', '["-k2 -n", "-n2", "-key 2", "--col 2 -n"]', NULL, '`-k2` 는 두 번째 칸을 기준으로, `-n` 은 숫자로 비교한다는 뜻입니다. 큰 순서는 `-r` 을 더해요.', '[0]', 'sort {0} p.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 25, '헤더 줄 건너뛰기', '첫 줄(헤더)을 건너뛰고 **두 번째 줄부터** 출력하려고 합니다. 옵션을 채우세요.', '플러스가 붙으면 "그 줄부터"예요.', NULL, NULL, '[]', 'fill', '["-n +2", "-n 2", "-2", "+2"]', NULL, '`tail -n 2` 는 마지막 2줄입니다. `-n +2` 처럼 `+` 가 붙으면 2번째 줄부터 끝까지예요.', '[0]', 'tail {0} data.csv', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 26, '접속이 안 될 때 이름 → 길 → 응답 순서로 점검', '서비스에 접속이 안 될 때 이름 해석부터 서버의 LISTEN 까지 좁혀 가는 순서입니다. 순서에 맞게 놓아 보세요.', '이름 → 길 → 응답 → 서버 쪽 순서예요.', NULL, NULL, '[]', 'order', '["`getent hosts 이름` 으로 이름이 IP 로 해석되는지 본다", "`ip route` 로 기본 게이트웨이가 있는지 본다", "`curl -sv http://서버/` 로 연결과 응답 단계를 본다", "서버에서 `ss -tlnp` 로 그 포트가 올바른 주소로 LISTEN 중인지 본다"]', NULL, '아래(내 쪽)에서 위(서버 쪽)로 좁히면 원인 범위가 빠르게 줄어듭니다. 종료 코드 `6`, `7`, `28` 이 어느 단계 문제인지 알려 줘요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 27, '로그에서 에러의 앞뒤 맥락 보기', '로그에서 에러를 찾아 앞뒤 맥락까지 살피는 순서입니다. 순서에 맞게 놓아 보세요.', '개수 → 위치 → 앞뒤 → 구간 순서예요.', NULL, NULL, '[]', 'order', '["`grep -ci error app.log` 로 에러가 몇 줄인지 본다", "`grep -ni error app.log` 로 줄 번호를 확인한다", "`grep -C2 -i error app.log` 로 앞뒤 2줄씩 함께 본다", "`sed -n ''120,130p'' app.log` 로 의심 구간을 넓게 읽는다"]', NULL, '한 줄씩 열어 보는 것보다 개수와 위치를 먼저 파악하면 시간이 크게 줄어듭니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 28, '표에서 조건에 맞는 값의 합계와 평균', '공백으로 나뉜 표에서 `Seoul` 줄의 나이 합계와 평균을 구하는 순서입니다. 순서에 맞게 놓아 보세요.', '모양 확인 → 행 고르기 → 합계 → 평균 순서예요.', NULL, NULL, '[]', 'order', '["`head -n 3 p.txt` 로 칸의 모양을 확인한다", "`awk ''$3==\\"Seoul\\"'' p.txt` 로 Seoul 인 줄만 골라 본다", "`awk ''$3==\\"Seoul\\" {s+=$2} END{print s}'' p.txt` 로 나이 합계를 구한다", "`awk ''$3==\\"Seoul\\" {s+=$2; n++} END{print s/n}'' p.txt` 로 평균을 구한다"]', NULL, '합계를 낼 때는 먼저 조건에 맞는 줄이 의도한 대로 골라지는지 눈으로 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 29, '헤더가 있는 CSV 에서 최댓값 찾기', '헤더가 있는 CSV 의 두 번째 칸에서 최댓값을 찾는 순서입니다. 순서에 맞게 놓아 보세요.', '헤더 확인 → 헤더 제거 → 칸 뽑기 → 최댓값 순서예요.', NULL, NULL, '[]', 'order', '["`head -n 1 data.csv` 로 헤더와 칸 순서를 확인한다", "`tail -n +2 data.csv` 로 헤더를 건너뛴다", "`cut -d, -f2` 로 두 번째 칸만 뽑는다", "`sort -n | tail -n 1` 로 가장 큰 값을 본다"]', NULL, '헤더를 빼지 않으면 문자 헤더가 정렬에 섞입니다. 숫자 정렬에는 `-n` 을 꼭 쓰세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 29);
