-- 미들웨어 세트 98. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set98.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 98, 'HAProxy 문제 해결 상황집: 503, DOWN, 안 뜰 때', '로드밸런서가 503 을 돌려주거나, 서버가 DOWN 이거나, 설정을 적용하지 못할 때 원인을 찾아 고치는 법을 익힙니다. 503·502·504 구분, 헬스체크 실패 사유(Layer4/Layer7) 읽기, stats CSV 로 DOWN 서버 찾기, 설정 검사(-c)로 오타 잡기, 포트 충돌 피하기, 끊김 없는 재적용(-sf)을 문제와 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 98);
UPDATE quest_set SET display_order = 515, unit_id = (SELECT id FROM unit WHERE id = 13), icon = '🆘' WHERE id = 98;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 1, 'HAProxy 점검 명령 채우기', '설정을 바꾼 뒤 ① **문법만 검사**하고(서비스에는 영향 없음), ② 이상이 없으면 **백그라운드(데몬)로 실행**하는 옵션입니다. 빈칸을 채우세요.', '검사는 check 의 첫 글자, 데몬은 대문자 D 입니다.', NULL, NULL, '[]', 'fill', '["c", "D", "sf", "v", "f"]', NULL, '`-c` 는 설정 파일을 검사만 하고 끝납니다. **적용 전에 항상 먼저** 실행합니다. `-D` 는 백그라운드로 실행합니다. `-sf 이전PID` 를 함께 쓰면 새 프로세스가 뜬 뒤 기존 프로세스가 연결을 마무리하고 종료되는 무중단 재적용(soft reload)이 됩니다.', '[0, 1]', 'haproxy -{0} -f /tmp/haproxy.cfg
haproxy -{1} -f /tmp/haproxy.cfg', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 2, '503 응답이 나올 때 진단 순서', '사용자들이 `503 Service Unavailable` 을 받습니다. HAProxy 뒤의 서비스 문제를 좁혀 가는 흐름을 **앞에서 뒤**로 놓으세요.', '바깥에서 안쪽으로: 현상 → 로드밸런서가 본 상태 → 서버 직접 확인 → 수정과 검증.', NULL, NULL, '[]', 'order', '["백엔드 서버 주소로 직접 `curl` 해 서버가 실제로 응답하는지 본다", "고친 설정을 `haproxy -c` 로 검사한 뒤 다시 적용한다", "`curl -i` 로 503 이 HAProxy 에서 나오는지 확인한다", "stats 페이지나 로그에서 backend 서버가 DOWN 인지 확인한다"]', NULL, '**현상 확인 → HAProxy 가 본 서버 상태(DOWN?) → 서버 직접 확인 → 수정·검사·적용** 입니다. 503 은 대개 "쓸 수 있는 서버가 없다"는 뜻이라, 서버가 죽었거나 주소·포트·헬스체크가 어긋난 경우가 많습니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 3, '503 "No server is available"', 'HAProxy 응답이 `503 Service Unavailable` 이고 본문에 `No server is available to handle this request.` 가 보입니다. 가장 흔한 원인은 무엇일까요?', '503 은 쓸 수 있는 서버가 없다는 뜻입니다.', NULL, NULL, '[]', 'choice', '["클라이언트 브라우저 버전이 낮다", "backend 의 모든 서버가 헬스체크에 실패해 DOWN 이거나, 지정된 backend 에 서버가 하나도 없다", "HAProxy 가 TLS 를 쓰지 않는다", "로그 파일이 너무 크다"]', 1, 'HAProxy 는 헬스체크를 통과한(UP) 서버에만 요청을 보냅니다. 전부 DOWN 이면 요청을 받아도 보낼 곳이 없어 503 을 돌려줍니다. stats 의 서버 상태와 서버 로그의 `Layer4 connection problem`, `Layer7 wrong status` 같은 사유를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 4, '502, 503, 504 구분하기', '`504 Gateway Time-out` 이 나옵니다. 의미와 점검 방향으로 알맞은 것은 무엇일까요?', '504 는 기다리다 시간이 초과된 경우입니다.', NULL, NULL, '[]', 'choice', '["백엔드 서버가 모두 DOWN 이다 (이 경우는 503)", "클라이언트가 인증서를 가지고 있지 않다", "백엔드가 연결은 됐지만 `timeout server` 시간 안에 응답하지 못했다. 백엔드의 처리 지연(느린 쿼리 등)을 먼저 보고, 정말 오래 걸리는 요청이면 timeout 값을 조정한다", "frontend 의 bind 포트가 틀렸다"]', 2, '대략 503 = 보낼 서버 없음, 502 = 백엔드가 잘못된 응답을 주거나 연결이 중간에 끊김, 504 = 응답 시간 초과입니다. timeout 만 무작정 늘리면 느린 백엔드를 가릴 뿐이라, 지연 원인을 먼저 찾습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 5, '"cannot bind socket" 오류', 'HAProxy 시작 시 `Starting frontend web: cannot bind socket [0.0.0.0:8080]` 이 나옵니다. 올바른 점검은 무엇일까요?', '같은 포트를 다른 프로세스가 쓰고 있을 수 있습니다.', NULL, NULL, '[]', 'choice', '["`ss -ltnp | grep 8080` 으로 그 포트를 이미 쓰는 프로세스(이전 HAProxy 등)를 찾아 정리하거나 bind 포트를 바꾼다. 1024 미만 포트라면 권한도 확인한다", "백엔드 서버를 재부팅한다", "timeout 값을 늘린다", "`balance` 방식을 바꾼다"]', 0, 'bind 실패는 대개 ① 포트를 이미 다른 프로세스가 점유, ② 일반 사용자가 1024 미만 포트 사용, ③ 존재하지 않는 IP 지정입니다. `ss -ltnp` 가 PID 와 프로세스 이름을 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 6, '설정 적용 전 반드시 할 일', '`haproxy.cfg` 를 고친 뒤 `[ALERT] ... unable to find required backend ''appp''` 같은 오류를 **운영 중에 처음** 만나는 일을 막으려면 어떻게 해야 할까요?', '적용 전에 검사만 하는 옵션이 있습니다.', NULL, NULL, '[]', 'choice', '["검사 없이 재시작해 보고 안 되면 되돌린다", "적용 전에 항상 `haproxy -c -f 설정파일` 로 문법과 참조를 검사하고, 통과했을 때만 reload 한다", "설정 파일을 읽기 전용으로 만든다", "서비스를 중지한 뒤 고친다"]', 1, '`-c` 는 실행 중인 서비스에 영향이 없습니다. 이름 오타(backend, acl), 빠진 `bind`, 잘못된 옵션은 대부분 여기서 걸립니다. 수정 전 설정을 `cp` 로 백업해 두면 되돌리기도 쉽습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 7, '헬스체크가 "Layer7 wrong status" 로 실패', 'stats 에서 서버가 DOWN 이고 사유가 `Layer7 wrong status: 404` 입니다. 서버 프로세스는 살아 있습니다. 원인은 무엇일까요?', 'L4 는 포트 연결, L7 은 HTTP 응답 검사입니다.', NULL, NULL, '[]', 'choice', '["서버 포트가 닫혀 있다 (이 경우는 Layer4 오류)", "HAProxy 가 IPv6 를 지원하지 않는다", "balance 방식이 roundrobin 이다", "`option httpchk` 로 확인하는 경로(예: `/health`)가 서버에 없거나 2xx·3xx 가 아닌 응답을 줘서 헬스체크가 실패한다. 경로를 맞추거나 서버에 해당 경로를 구현한다"]', 3, 'Layer4 connection problem = 포트에 연결도 안 됨, Layer7 wrong status = 연결은 되지만 HTTP 응답 코드가 기대와 다름, Layer7 timeout = 응답이 늦음입니다. 사유 문구가 원인 좁히기의 출발점입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 8, '503 원인: 서버 포트 오타 고치기', '`http://localhost:8080` 이 `503` 을 돌려줍니다. 백엔드 서버(`B1`)는 포트 **9001** 에서 정상 동작 중입니다. 설정의 서버 주소를 바로잡아 **다시 적용**하고, 응답 코드를 **`/tmp/code.txt`** 에 저장하세요.', '`curl -i localhost:8080` 으로 확인하고, 설정의 `server` 줄을 보세요. 설정을 바꾼 뒤에는 `haproxy -c` 로 검사하고 새 설정으로 다시 실행해야 반영됩니다.\\n확인: `pgrep haproxy`', 'curl -s -o /dev/null -w ''%{http_code}\\n'' localhost:8080
sed -i ''s/9009/9001/'' /tmp/haproxy.cfg
haproxy -c -f /tmp/haproxy.cfg
pkill haproxy; sleep 1
haproxy -D -f /tmp/haproxy.cfg
sleep 1
curl -s -o /dev/null -w ''%{http_code}'' localhost:8080 > /tmp/code.txt

# 서버 주소가 틀리면 헬스체크 실패 → 모든 서버 DOWN → 503', '["sh", "-c", "nohup etude-httpd 9001 B1 >/dev/null 2>&1 & nohup etude-httpd 9002 B2 >/dev/null 2>&1 & sleep 1 && printf ''%s\\\\n'' ''defaults'' ''    mode http'' ''    timeout connect 5s'' ''    timeout client 30s'' ''    timeout server 30s'' ''frontend web'' ''    bind *:8080'' ''    default_backend app'' ''backend app'' ''    server s1 127.0.0.1:9009 check inter 500ms'' > /tmp/haproxy.cfg && haproxy -D -f /tmp/haproxy.cfg && sleep 2"]', '["sh", "-c", "( haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1 ) && ( pgrep haproxy >/dev/null ) && ( grep -q \\"127.0.0.1:9001\\" /tmp/haproxy.cfg ) && ( [ \\"$(cat /tmp/code.txt)\\" = 200 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "설정 파일이 문법 검사를 통과한다", "cmd": ["sh", "-c", "haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1"]}, {"label": "haproxy 가 실행 중이다", "cmd": ["sh", "-c", "pgrep haproxy >/dev/null"]}, {"label": "설정의 서버가 9001 이다", "cmd": ["sh", "-c", "grep -q \\"127.0.0.1:9001\\" /tmp/haproxy.cfg"]}, {"label": "응답 코드 200 이 저장되어 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/code.txt)\\" = 200 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 9, 'stats 로 DOWN 서버 찾기', '`app` backend 에 서버 `s1`, `s2` 가 있는데 일부가 응답하지 않는다는 제보가 있습니다. stats 페이지(`http://localhost:8404/stats`)의 CSV 에서 **DOWN 상태인 서버 이름**을 찾아 **`/tmp/down.txt`** 에 저장하세요.', 'CSV 는 `curl ''localhost:8404/stats;csv''` 로 받을 수 있고, 2번째 열이 서버 이름, 18번째 열이 상태입니다. `grep` 과 `cut` 을 쓰세요.\\n확인: `curl -s ''localhost:8404/stats;csv'' | cut -d, -f1,2,18`', 'curl -s ''localhost:8404/stats;csv'' | cut -d, -f1,2,18
curl -s ''localhost:8404/stats;csv'' | grep '',DOWN,'' | cut -d, -f2 > /tmp/down.txt
cat /tmp/down.txt

# stats CSV : 1열 proxy 이름, 2열 서버 이름, 18열 status', '["sh", "-c", "nohup etude-httpd 9001 B1 >/dev/null 2>&1 & sleep 1 && printf ''%s\\\\n'' ''defaults'' ''    mode http'' ''    timeout connect 5s'' ''    timeout client 30s'' ''    timeout server 30s'' ''frontend web'' ''    bind *:8080'' ''    default_backend app'' ''backend app'' ''    server s1 127.0.0.1:9001 check inter 500ms fall 2 rise 1'' ''    server s2 127.0.0.1:9002 check inter 500ms fall 2 rise 1'' ''listen stats'' ''    bind *:8404'' ''    stats enable'' ''    stats uri /stats'' > /tmp/haproxy.cfg && haproxy -D -f /tmp/haproxy.cfg && sleep 3"]', '["sh", "-c", "( [ -s /tmp/down.txt ] ) && ( [ \\"$(cat /tmp/down.txt)\\" = s2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/down.txt ]"]}, {"label": "DOWN 서버 이름이 s2 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/down.txt)\\" = s2 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 10, '설정 오타 찾아 고치고 적용하기', '`haproxy.cfg` 를 수정한 뒤 적용하려 하니 **설정 검사에서 오류**가 납니다. 오류 메시지를 읽고 설정을 고쳐 검사를 통과시킨 뒤, **서비스를 새 설정으로 다시 실행**하고 응답 코드를 **`/tmp/code.txt`** 에 저장하세요.', '`haproxy -c -f /tmp/haproxy.cfg` 가 어느 줄에서 무엇을 못 찾는지 알려 줍니다.\\n확인: `grep default_backend /tmp/haproxy.cfg`', 'haproxy -c -f /tmp/haproxy.cfg
sed -i ''s/appp/app/'' /tmp/haproxy.cfg
haproxy -c -f /tmp/haproxy.cfg
pkill haproxy; sleep 1
haproxy -D -f /tmp/haproxy.cfg
sleep 1
curl -s -o /dev/null -w ''%{http_code}'' localhost:8080 > /tmp/code.txt

# ''unable to find required backend'' : default_backend 가 가리키는 이름이 실제 backend 와 다르다', '["sh", "-c", "nohup etude-httpd 9001 B1 >/dev/null 2>&1 & nohup etude-httpd 9002 B2 >/dev/null 2>&1 & sleep 1 && printf ''%s\\\\n'' ''defaults'' ''    mode http'' ''    timeout connect 5s'' ''    timeout client 30s'' ''    timeout server 30s'' ''frontend web'' ''    bind *:8080'' ''    default_backend app'' ''backend app'' ''    server s1 127.0.0.1:9001 check'' > /tmp/haproxy.cfg && haproxy -D -f /tmp/haproxy.cfg && sleep 1 && sed -i ''s/default_backend app/default_backend appp/'' /tmp/haproxy.cfg"]', '["sh", "-c", "( haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1 ) && ( pgrep haproxy >/dev/null ) && ( grep -qx \\"    default_backend app\\" /tmp/haproxy.cfg ) && ( [ \\"$(cat /tmp/code.txt)\\" = 200 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "설정 파일이 문법 검사를 통과한다", "cmd": ["sh", "-c", "haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1"]}, {"label": "haproxy 가 실행 중이다", "cmd": ["sh", "-c", "pgrep haproxy >/dev/null"]}, {"label": "default_backend 가 app 이다", "cmd": ["sh", "-c", "grep -qx \\"    default_backend app\\" /tmp/haproxy.cfg"]}, {"label": "응답 코드 200 이 저장되어 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/code.txt)\\" = 200 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 11, '포트 충돌로 HAProxy 가 안 뜰 때', '`haproxy -D -f /tmp/haproxy.cfg` 가 **`cannot bind socket [0.0.0.0:8080]`** 로 실패합니다. 8080 은 이미 다른 프로세스가 쓰고 있고 **건드리면 안 됩니다.** HAProxy 의 `bind` 포트를 **8081** 로 바꿔 실행하고, 8081 의 응답 코드를 **`/tmp/code.txt`** 에 저장하세요.', '`ss -ltnp | grep 8080` 으로 누가 쓰는지 확인하세요. bind 줄의 포트만 바꾸면 됩니다.\\n확인: `grep bind /tmp/haproxy.cfg`', 'ss -ltnp | grep 8080
sed -i ''s/\\*:8080/*:8081/'' /tmp/haproxy.cfg
haproxy -D -f /tmp/haproxy.cfg
sleep 1
curl -s -o /dev/null -w ''%{http_code}'' localhost:8081 > /tmp/code.txt

# 이미 쓰는 포트는 바꾸지 말고 HAProxy 쪽 bind 를 옮긴다', '["sh", "-c", "nohup etude-httpd 9001 B1 >/dev/null 2>&1 & nohup etude-httpd 9002 B2 >/dev/null 2>&1 & sleep 1 && nohup etude-httpd 8080 OTHER >/dev/null 2>&1 & sleep 1; printf ''%s\\\\n'' ''defaults'' ''    mode http'' ''    timeout connect 5s'' ''    timeout client 30s'' ''    timeout server 30s'' ''frontend web'' ''    bind *:8080'' ''    default_backend app'' ''backend app'' ''    server s1 127.0.0.1:9001 check'' > /tmp/haproxy.cfg"]', '["sh", "-c", "( haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1 ) && ( pgrep haproxy >/dev/null ) && ( grep -q \\"bind \\\\*:8081\\" /tmp/haproxy.cfg ) && ( curl -s localhost:8080 | grep -q OTHER ) && ( [ \\"$(cat /tmp/code.txt)\\" = 200 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "설정 파일이 문법 검사를 통과한다", "cmd": ["sh", "-c", "haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1"]}, {"label": "haproxy 가 실행 중이다", "cmd": ["sh", "-c", "pgrep haproxy >/dev/null"]}, {"label": "bind 가 8081 이다", "cmd": ["sh", "-c", "grep -q \\"bind \\\\*:8081\\" /tmp/haproxy.cfg"]}, {"label": "8080 을 쓰던 프로세스는 그대로다", "cmd": ["sh", "-c", "curl -s localhost:8080 | grep -q OTHER"]}, {"label": "응답 코드 200 이 저장되어 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/code.txt)\\" = 200 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 98, 12, '끊김 없이 서버 추가하기 (soft reload)', '`app` backend 에 서버가 `s1` 하나뿐입니다. 포트 **9002** 의 서버를 **`s2`** 로 추가하고, **기존 연결을 끊지 않는 soft reload**(`-sf`)로 적용하세요. 적용 뒤 요청 6번의 응답을 **`/tmp/r.txt`** 에 저장했을 때 `B1` 과 `B2` 가 **모두** 보여야 합니다. (현재 PID 는 `/tmp/hp.pid`)', '`-p /tmp/hp.pid` 로 PID 를 파일에 남기고, `-sf $(cat /tmp/hp.pid)` 로 이전 프로세스에게 "연결을 마무리하고 종료"하라고 알립니다.\\n확인: `curl -s localhost:8080`', 'printf ''    server s2 127.0.0.1:9002 check\\n'' >> /tmp/haproxy.cfg
haproxy -c -f /tmp/haproxy.cfg
haproxy -D -f /tmp/haproxy.cfg -p /tmp/hp.pid -sf $(cat /tmp/hp.pid)
sleep 1
for i in 1 2 3 4 5 6; do curl -s localhost:8080; echo; done > /tmp/r.txt

# -sf PID : 새 프로세스가 뜬 뒤 이전 프로세스가 기존 연결을 마치고 종료', '["sh", "-c", "nohup etude-httpd 9001 B1 >/dev/null 2>&1 & nohup etude-httpd 9002 B2 >/dev/null 2>&1 & sleep 1 && printf ''%s\\\\n'' ''defaults'' ''    mode http'' ''    timeout connect 5s'' ''    timeout client 30s'' ''    timeout server 30s'' ''frontend web'' ''    bind *:8080'' ''    default_backend app'' ''backend app'' ''    server s1 127.0.0.1:9001 check'' > /tmp/haproxy.cfg && haproxy -D -f /tmp/haproxy.cfg -p /tmp/hp.pid && sleep 1"]', '["sh", "-c", "( haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1 ) && ( pgrep haproxy >/dev/null ) && ( grep -q \\"server s2 127.0.0.1:9002\\" /tmp/haproxy.cfg ) && ( grep -q B1 /tmp/r.txt ) && ( grep -q B2 /tmp/r.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "설정 파일이 문법 검사를 통과한다", "cmd": ["sh", "-c", "haproxy -c -f /tmp/haproxy.cfg >/dev/null 2>&1"]}, {"label": "haproxy 가 실행 중이다", "cmd": ["sh", "-c", "pgrep haproxy >/dev/null"]}, {"label": "설정에 s2 가 있다", "cmd": ["sh", "-c", "grep -q \\"server s2 127.0.0.1:9002\\" /tmp/haproxy.cfg"]}, {"label": "응답에 B1 이 있다", "cmd": ["sh", "-c", "grep -q B1 /tmp/r.txt"]}, {"label": "응답에 B2 도 있다", "cmd": ["sh", "-c", "grep -q B2 /tmp/r.txt"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 98 AND order_index = 12);
