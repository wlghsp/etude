-- 미들웨어 세트 131. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set131.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 131, '리눅스 쉬운 문제 3: 네트워크 기본과 텍스트 도구 한 줄씩', '리눅스 네트워크와 텍스트 처리의 기본을 한 개념씩 쉬운 문제로 반복합니다. IP·포트·localhost·DNS, ping·curl·ss·nc·ip addr 의 쓰임과 refused 읽기, grep -v/-c/-r/-n, sort -nr·uniq -c, sed 치환, awk 칸 뽑기, tee, 연결이 안 될 때와 로그에서 IP 별 접속 수 세기의 점검 순서를 짧은 객관식·빈칸·순서 문제로 익힙니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 131);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🔌' WHERE id = 131;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 1, 'IP 주소는 무엇일까', '네트워크에서 IP 주소는 무엇을 가리킬까요?', '집 주소처럼 컴퓨터를 찾는 번호예요.', NULL, NULL, '[]', 'choice', '["프로그램을 구분하는 번호", "파일의 위치", "네트워크에서 컴퓨터(장치)를 구분하는 주소", "사용자의 비밀번호"]', 2, 'IP 는 "어느 컴퓨터"를 가리키고, 포트는 그 컴퓨터 안의 "어느 프로그램(문)"을 가리킵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 2, '포트는 무엇일까', '`80`, `443`, `22` 같은 포트 번호는 무엇을 구분할까요?', '건물의 호수 같은 거예요.', NULL, NULL, '[]', 'choice', '["컴퓨터의 위치", "한 컴퓨터 안에서 통신하는 프로그램(서비스)", "파일의 크기", "사용자 계정"]', 1, '웹은 보통 80(HTTP), 443(HTTPS), SSH 는 22 포트를 씁니다. IP 와 포트를 합쳐야 정확한 접속 대상이 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 3, 'localhost 는 어디일까', '`curl http://localhost:8080` 에서 `localhost` 는 어느 컴퓨터를 가리킬까요?', '"나 자신"을 뜻하는 이름이에요.', NULL, NULL, '[]', 'choice', '["지금 명령을 실행하는 바로 이 컴퓨터(자기 자신)", "인터넷의 어딘가에 있는 서버", "같은 회사의 다른 서버", "게이트웨이 장비"]', 0, '`localhost`(127.0.0.1)는 자기 자신입니다. 컨테이너 안에서는 컨테이너 자신이고, 다른 컨테이너나 호스트가 아니에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 4, 'ping 은 무엇을 확인할까', '`ping 8.8.8.8` 은 무엇을 확인해 줄까요?', '상대에게 작은 신호를 보내 답을 기다려요.', NULL, NULL, '[]', 'choice', '["상대 컴퓨터의 파일 목록", "상대의 비밀번호", "상대 서비스의 버전", "상대 컴퓨터까지 신호가 오가는지와 걸리는 시간"]', 3, 'ping 이 되면 길은 열려 있다는 뜻이지만, 보안 설정으로 ping 만 막아 둔 서버도 많습니다. 안 된다고 서버가 죽었다는 뜻은 아니에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 5, 'curl 은 무엇일까', '`curl http://example.com` 은 무엇을 할까요?', '터미널에서 웹 요청을 보내 보는 도구예요.', NULL, NULL, '[]', 'choice', '["웹 브라우저를 설치한다", "웹 서버를 새로 만든다", "그 주소로 HTTP 요청을 보내고 응답을 터미널에 출력한다", "파일을 압축한다"]', 2, '`curl` 은 API 나 웹 서비스가 응답하는지 확인할 때 가장 많이 씁니다. `-I` 는 헤더만, `-v` 는 과정을 자세히 보여 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 6, 'DNS 는 무엇일까', 'DNS 는 어떤 일을 할까요?', '전화번호부와 같아요.', NULL, NULL, '[]', 'choice', '["IP 주소를 이름으로 숨긴다", "이름(example.com)을 IP 주소로 바꿔 준다", "파일을 암호화한다", "프로세스를 종료한다"]', 1, '사람은 이름을, 컴퓨터는 숫자를 씁니다. 이름으로는 접속이 안 되고 IP 로는 된다면 DNS(이름 해석)를 의심하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 7, 'listen 이라는 상태', '`ss -tln` 결과에서 포트 8080 이 `LISTEN` 입니다. 무슨 뜻일까요?', '문을 열고 손님을 기다리는 상태예요.', NULL, NULL, '[]', 'choice', '["그 포트에서 프로그램이 접속을 기다리고 있다", "그 포트가 막혀 있다", "그 포트로 방금 접속이 실패했다", "그 포트가 삭제됐다"]', 0, '서비스가 떠 있는지는 포트가 LISTEN 인지로 확인합니다. LISTEN 이 없다면 서비스가 안 떠 있는 거예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 8, 'Connection refused', '`curl: (7) Failed to connect ... Connection refused` 는 무슨 뜻일까요?', '"거절"은 그곳에 듣는 프로그램이 없다는 신호예요.', NULL, NULL, '[]', 'choice', '["이름을 IP 로 바꾸지 못했다", "비밀번호가 틀렸다", "디스크가 가득 찼다", "서버 컴퓨터에는 닿았지만 그 포트에서 듣는 프로그램이 없다"]', 3, '서비스가 꺼져 있거나 다른 포트로 떠 있는 경우입니다. 서버 쪽에서 `ss -tln` 으로 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 9, 'IP 확인하는 명령', '이 컴퓨터가 가진 IP 주소를 확인하는 명령으로 알맞은 것은 무엇일까요?', 'address 의 줄임말이 들어가요.', NULL, NULL, '[]', 'choice', '["`ls -l`", "`df -h`", "`ip addr`", "`ps aux`"]', 2, '`ip addr` 은 네트워크 인터페이스와 IP 를 보여 줍니다. 옛날 명령 `ifconfig` 도 비슷하지만 `ip` 가 표준이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 10, 'grep -v 의 의미', '`grep -v ERROR app.log` 는 어떤 줄을 보여 줄까요?', 'v 는 반대(invert)를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["ERROR 가 있는 줄", "ERROR 가 **없는** 줄", "ERROR 의 줄 번호", "ERROR 의 개수"]', 1, '`-v` 는 일치하지 않는 줄을 보여 줍니다. 노이즈를 걸러낼 때 `grep -v 불필요한패턴` 을 이어 붙여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 11, 'grep -c 와 wc -l', '`grep -c ERROR app.log` 는 무엇을 출력할까요?', 'c 는 count(세기)예요.', NULL, NULL, '[]', 'choice', '["ERROR 가 든 줄의 개수", "ERROR 가 든 줄 전체", "파일의 전체 줄 수", "ERROR 의 위치"]', 0, '`grep -c` 는 일치하는 줄 수를 바로 셉니다. `grep ERROR app.log | wc -l` 과 같은 결과예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 12, 'grep -r 은 무엇일까', '`grep -r timeout /etc/app` 에서 `-r` 은 무엇을 뜻할까요?', '폴더 안의 하위 폴더까지 들어가요.', NULL, NULL, '[]', 'choice', '["대소문자를 구분하지 않는다", "결과를 거꾸로 정렬한다", "일치하는 줄을 지운다", "폴더 안의 모든 하위 폴더까지 뒤져서 찾는다"]', 3, '`-r` 은 recursive(재귀)입니다. 설정이 어느 파일에 있는지 모를 때 폴더 전체를 훑어 찾는 데 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 13, 'sed 로 바꾸기', '`sed ''s/old/new/'' file.txt` 는 무엇을 할까요?', 's 는 substitute(치환)예요.', NULL, NULL, '[]', 'choice', '["파일에서 old 줄을 삭제한다", "파일 이름을 바꾼다", "각 줄에서 처음 나오는 old 를 new 로 바꿔 출력한다 (파일 자체는 그대로)", "old 의 개수를 센다"]', 2, '`sed` 는 기본으로 출력만 바꾸고 파일은 건드리지 않습니다. 파일을 바로 수정하려면 `-i` 를 쓰며, 그때는 백업을 권합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 14, 'awk 로 첫 칸 뽑기', '`awk ''{print $1}'' access.log` 는 무엇을 출력할까요?', '$1 은 첫 번째 칸이에요.', NULL, NULL, '[]', 'choice', '["각 줄의 마지막 단어", "각 줄의 첫 번째 칸(공백으로 나뉜 첫 단어)", "파일의 첫 줄만", "줄의 개수"]', 1, '`awk` 는 칸 단위 처리에 강합니다. 접속 로그의 첫 칸이 보통 IP 라서, IP 별 개수를 세는 데 `awk | sort | uniq -c` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 15, 'IP 주소 보기', '이 컴퓨터의 IP 주소를 보는 명령입니다. 빈칸을 채우세요.', 'address 의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["addr", "link", "route", "dns"]', NULL, '`ip addr` 은 주소, `ip route` 는 길(라우팅), `ip link` 는 인터페이스 상태를 보여 줍니다.', '[0]', 'ip {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 16, '열린 포트 보기', '듣고 있는(LISTEN) TCP 포트를 숫자로 보는 명령입니다. 빈칸을 채우세요.', 'tcp, listening, numeric 의 첫 글자를 모았어요.', NULL, NULL, '[]', 'fill', '["tln", "abc", "xyz", "ls"]', NULL, '`ss -tln` 은 열린 TCP 포트를, `-p` 를 더하면 어느 프로세스인지도 보여 줍니다(권한 필요).', '[0]', 'ss -{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 17, 'ping 횟수 정하기', '`ping` 을 **3번만** 보내고 끝내는 옵션을 채우세요.', 'count 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-c", "-n", "-t", "-s"]', NULL, '리눅스의 `ping` 은 멈추지 않고 계속 보내서 Ctrl+C 로 끝내야 합니다. `-c 횟수` 를 쓰면 스크립트에서도 편해요.', '[0]', 'ping {0} 3 example.com', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 18, '응답 헤더만 보기', '`curl` 로 응답 본문 없이 **헤더만** 확인하는 옵션을 채우세요.', 'head 를 뜻하는 대문자 I 예요.', NULL, NULL, '[]', 'fill', '["-I", "-v", "-o", "-s"]', NULL, '`-I` 는 상태 코드(200, 404)와 헤더만 가져옵니다. 서비스가 살아 있는지 빠르게 볼 때 유용해요.', '[0]', 'curl {0} http://localhost:8080', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 19, '포트 열렸는지 확인', '서버 `192.0.2.10` 의 22번 포트가 **열렸는지만** 가볍게 확인하는 명령입니다. 옵션을 채우세요.', 'zero-I/O 와 verbose 의 약자예요.', NULL, NULL, '[]', 'fill', '["-zv", "-ls", "-ok", "-rf"]', NULL, '`nc -zv 호스트 포트` 는 접속만 시도하고 결과를 알려 줍니다. `succeeded` 가 보이면 포트가 열려 있는 거예요.', '[0]', 'nc {0} 192.0.2.10 22', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 20, '줄 번호와 함께 찾기', '`app.log` 에서 `ERROR` 를 **줄 번호와 함께** 찾는 옵션을 채우세요.', 'number 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-v", "-c", "-r"]', NULL, '`-n` 은 줄 번호를 붙여 줍니다. 로그의 몇 번째 줄 근처인지 볼 때 편해요.', '[0]', 'grep {0} ERROR app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 21, '일치하지 않는 줄 보기', '`app.log` 에서 `DEBUG` 가 **없는** 줄만 보는 옵션을 채우세요.', '반대(invert)의 v 예요.', NULL, NULL, '[]', 'fill', '["-v", "-n", "-i", "-c"]', NULL, '`-v` 는 반대 조건입니다. 시끄러운 DEBUG 줄을 빼고 진짜 문제를 보는 데 씁니다.', '[0]', 'grep {0} DEBUG app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 22, '큰 수 먼저 정렬', '숫자를 **큰 것부터** 정렬해 보여 주는 옵션 조합을 채우세요.', '숫자(numeric)로, 거꾸로(reverse)예요.', NULL, NULL, '[]', 'fill', '["-nr", "-ab", "-xy", "-zz"]', NULL, '`sort -n` 은 숫자로, `-r` 은 거꾸로 정렬합니다. 문자로 정렬하면 `10` 이 `2` 보다 앞에 오는 것에 주의하세요.', '[0]', 'sort {0} numbers.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 23, '빈도 순위 만들기', '정렬된 줄을 `uniq -c` 로 센 뒤 **많은 순서로** 다시 정렬하는 마지막 단계를 채우세요.', '이미 앞에서 배운 옵션 조합이에요.', NULL, NULL, '[]', 'fill', '["-rn", "-ab", "-xy", "-zz"]', NULL, '`sort | uniq -c | sort -rn` 은 로그 분석의 대표 조합입니다. 가장 많이 나온 값이 위에 와요.', '[0]', 'sort names.txt | uniq -c | sort {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 24, '글자 바꾸기', '각 줄에서 `old` 를 `new` 로 바꿔 출력하는 `sed` 의 빈칸을 채우세요.', 'substitute 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["s", "d", "p", "q"]', NULL, '`s/찾을것/바꿀것/` 이 치환입니다. 뒤에 `g` 를 붙이면 한 줄의 모든 일치를 바꿔요.', '[0]', 'sed ''{0}/old/new/'' file.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 25, '마지막 칸 뽑기', '`awk` 로 각 줄의 **마지막 칸**을 출력하는 빈칸을 채우세요.', 'Number of Fields 를 뜻하는 변수예요.', NULL, NULL, '[]', 'fill', '["NF", "NR", "FS", "OFS"]', NULL, '`$NF` 는 마지막 칸입니다. `NF` 는 칸의 개수, `NR` 은 줄 번호예요.', '[0]', 'awk ''{print ${0}}'' file.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 26, '결과를 화면과 파일에 둘 다', '명령의 출력을 **화면에도 보여 주고 파일에도 저장**하는 명령입니다. 빈칸을 채우세요.', 'T 자 배관 모양에서 이름이 왔어요.', NULL, NULL, '[]', 'fill', '["tee", "cat", "cut", "tr"]', NULL, '`tee` 는 입력을 화면과 파일로 동시에 보냅니다. 추가는 `tee -a` 예요.', '[0]', 'ls | {0} out.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 27, '이름으로 접속 확인', '`example.com` 의 **IP 주소를 조회**하는 도구입니다. 빈칸을 채우세요.', 'name server lookup 의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["nslookup", "traceroute", "ping6", "netstat"]', NULL, '`nslookup`(또는 `dig`)은 이름을 IP 로 바꿔 보여 줍니다. 이름 해석이 되는지 따로 확인할 수 있어요.', '[0]', '{0} example.com', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 28, '서비스에 연결이 안 될 때', '이름으로 접속이 안 될 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '내 주소 → 이름 → 도달 → 포트 순서예요.', NULL, NULL, '[]', 'order', '["`ip addr` 로 내 IP 가 정상인지 본다", "`nslookup 이름` 으로 이름이 IP 로 바뀌는지 본다", "`ping IP` 로 상대에게 닿는지 본다", "`nc -zv IP 포트` 로 포트가 열렸는지 본다"]', NULL, '아래 층(내 쪽)에서 위 층으로 좁혀 가면 원인 범위가 줄어듭니다. ping 이 막힌 환경에서는 포트 확인이 더 정확해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 29, '로그에서 IP 별 접속 수 세기', '접속 로그의 첫 칸이 IP 입니다. IP 별 접속 횟수를 많은 순으로 보는 조합입니다. 순서에 맞게 놓아 보세요.', '뽑기 → 정렬 → 세기 → 순위 순서예요.', NULL, NULL, '[]', 'order', '["`awk ''{print $1}'' access.log`", "`sort`", "`uniq -c`", "`sort -rn`"]', NULL, '`uniq` 는 이웃한 줄만 합치므로 먼저 `sort` 가 필요합니다. 이 조합은 로그 분석에서 매우 자주 써요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 29);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 30, '설정 파일에서 값 찾기', '설정 폴더에서 `timeout` 설정이 어느 파일에 있는지 찾는 순서입니다. 순서에 맞게 놓아 보세요.', '찾기 → 줄 번호 → 열어 보기 순서예요.', NULL, NULL, '[]', 'order', '["`grep -rn timeout /etc/app` 로 파일과 줄 번호를 찾는다", "찾은 파일을 `cat` 이나 `less` 로 주변을 본다", "값을 확인하고 수정한다", "수정한 뒤 `grep` 으로 다시 확인한다"]', NULL, '`grep -rn` 은 폴더 전체에서 파일 이름과 줄 번호까지 알려 줍니다. 수정 전에 백업하는 습관도 잊지 마세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 30);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 31, '포트가 열렸는지 로컬에서 확인', '내 컴퓨터에서 서비스가 8080 으로 떠 있는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '포트 목록 → 응답 확인 순서예요.', NULL, NULL, '[]', 'order', '["`ss -tln` 으로 8080 이 LISTEN 인지 본다", "`curl -I http://localhost:8080` 으로 응답을 본다", "응답이 없으면 서비스 로그를 본다", "원인을 고치고 다시 `curl` 로 확인한다"]', NULL, '포트가 열려 있는지(LISTEN)와 실제로 응답하는지(curl)는 다른 확인입니다. 둘 다 해 보세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 31);
