-- 네트워크 퀴즈 세트 379. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_quiz_sets.md
INSERT INTO unit (id, category, title, display_order) SELECT 47, '네트워크', '네트워크 기초', 5 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 47);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 379, '네트워크 주소와 경로: 사설 주소·CIDR·게이트웨이·라우팅·ARP', '패킷이 목적지까지 가는 길을 읽습니다. 사설 주소 대역과 CIDR 호스트 수, 기본 게이트웨이와 default 경로, 가장 길게 일치하는 경로, metric, ip route get, ARP, ss 로 듣는 포트 확인을 익힙니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 379);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🛣️', display_order = 626 WHERE id = 379;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 1, '사설 주소가 아닌 것', '다음 중 **사설(private) 주소가 아닌 것** 은 무엇일까요?', 'RFC 1918 의 세 대역을 떠올려 보세요. 172 대역이 함정이에요.', NULL, NULL, '[]', 'choice', '["10.20.30.40", "172.20.1.1", "172.32.0.1", "192.168.10.5"]', 2, 'RFC 1918 의 사설 대역은 10.0.0.0/8, 172.16.0.0/12(172.16~172.31), 192.168.0.0/16 입니다. 172.32.0.1 은 이 범위를 벗어난 공인 주소입니다.', NULL, NULL, NULL, '[{"title": "RFC 1918 사설 주소", "url": "https://www.rfc-editor.org/rfc/rfc1918"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 2, '/24 서브넷의 호스트 수', '`192.168.1.0/24` 서브넷에서 **장비에 줄 수 있는 호스트 주소** 는 몇 개일까요?', '주소 256 개에서 네트워크 주소와 브로드캐스트를 빼요.', NULL, NULL, '[]', 'choice', '["256 개", "254 개", "255 개", "24 개"]', 1, '/24 는 호스트 부분이 8비트로 주소가 256 개이고, 네트워크 주소(.0)와 브로드캐스트 주소(.255)를 빼면 254 개입니다. 접두 길이 표기는 CIDR(RFC 4632)입니다.', NULL, NULL, NULL, '[{"title": "RFC 4632 CIDR", "url": "https://www.rfc-editor.org/rfc/rfc4632"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 3, '기본 게이트웨이', '**기본 게이트웨이** 의 역할로 알맞은 것은 무엇일까요?', '내 서브넷 밖으로 나갈 때 거치는 곳이에요.', NULL, NULL, '[]', 'choice', '["같은 서브넷 밖의 목적지로 가는 패킷을 넘겨 줄 라우터", "이름을 IP 주소로 바꿔 주는 DNS 서버", "IP 주소를 자동으로 나눠 주는 서버", "같은 서브넷의 MAC 주소를 보관하는 스위치"]', 0, '목적지가 내 서브넷 밖이면 기본 게이트웨이(라우터)에게 패킷을 넘깁니다. 리눅스에서는 `default via 게이트웨이주소` 경로로 나타납니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 4, 'default 경로', '`ip route` 에서 `default via 10.0.0.1 dev eth0` 줄은 무슨 뜻일까요?', '더 구체적인 경로가 없을 때 쓰는 경로예요.', NULL, NULL, '[]', 'choice', '["10.0.0.1 로 가는 패킷만 eth0 로 보낸다", "이 장비가 10.0.0.1 주소를 가진다는 뜻이다", "eth0 로 들어오는 패킷을 모두 막는다", "다른 경로에 맞지 않는 모든 목적지를 10.0.0.1 로 보낸다"]', 3, '`default` 는 0.0.0.0/0 과 같아서, 더 구체적인 경로가 없는 목적지는 `via` 로 지정한 게이트웨이로 보냅니다. ip-route(8) 는 `via` 를 다음 홉으로 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 5, '가장 구체적인 경로', '라우팅 테이블에 `10.0.0.0/8` 과 `10.1.2.0/24` 가 모두 있습니다. 목적지 `10.1.2.7` 은 어느 경로로 갈까요?', '접두 길이가 긴 쪽이 더 구체적이에요.', NULL, NULL, '[]', 'choice', '["`10.0.0.0/8` (먼저 적힌 경로)", "`10.0.0.0/8` (범위가 더 넓어서 우선)", "`10.1.2.0/24` (가장 길게 일치하는 경로)", "두 경로 중 무작위로 하나를 쓴다"]', 2, '인터넷 전달은 longest-match(가장 길게 일치) 원칙으로 이뤄진다고 RFC 4632 는 설명합니다. `/24` 가 `/8` 보다 더 구체적이라 우선합니다.', NULL, NULL, NULL, '[{"title": "RFC 4632 CIDR", "url": "https://www.rfc-editor.org/rfc/rfc4632"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 6, 'ip route get', '`ip route get 8.8.8.8` 은 무엇을 보여 줄까요?', '커널이 실제로 고르는 경로예요.', NULL, NULL, '[]', 'choice', '["8.8.8.8 서버의 현재 응답 시간", "그 목적지로 가기 위해 커널이 실제로 고르는 경로", "8.8.8.8 이 열어 둔 포트 목록", "8.8.8.8 까지 거치는 모든 라우터의 목록"]', 1, 'ip-route(8) 는 `ip route get` 이 목적지로 가는 경로 하나를 커널이 보는 그대로 출력한다고 설명합니다. 응답 시간은 ping, 거치는 라우터는 traceroute 로 봅니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 7, 'metric 의 의미', '같은 목적지로 가는 경로가 둘 있을 때 `metric`(preference) 값이 **작은 쪽** 은 어떻게 될까요?', '낮을수록...', NULL, NULL, '[]', 'choice', '["더 우선하여 선택된다", "덜 우선하여 뒤로 밀린다", "두 경로 모두 무시된다", "값과 상관없이 먼저 만든 경로가 쓰인다"]', 0, 'ip-route(8) 는 metric(preference)을 임의의 32비트 값으로, 값이 낮은 경로가 우선된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 8, 'ARP 가 하는 일', '같은 서브넷의 장비에 패킷을 보내기 전에 **ARP** 는 무엇을 알아낼까요?', 'IP 로는 선을 탈 수 없어요.', NULL, NULL, '[]', 'choice', '["상대 장비의 호스트 이름", "상대 장비가 열어 둔 포트 번호", "상대 장비까지의 홉 수", "상대 IP 주소에 대응하는 MAC 주소"]', 3, 'ip-neighbour(8) 는 이웃 테이블이 같은 링크의 프로토콜 주소와 링크 계층 주소를 묶으며 IPv4 의 이웃 테이블이 곧 ARP 테이블이라고 설명합니다. `ip neigh` 으로 봅니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 9, '127.0.0.1 로만 듣는 서버', '서버에서 `ss -tln` 을 했더니 `127.0.0.1:8080` 으로 듣고 있습니다. 다른 PC 에서 접속하면 어떻게 될까요?', '루프백 주소는 자기 자신이에요.', NULL, NULL, '[]', 'choice', '["접속은 되지만 응답이 아주 느려진다", "방화벽만 열면 접속된다", "접속되지 않는다 (서버 자신 안에서만 접속된다)", "같은 서브넷에 있는 PC 에서는 접속된다"]', 2, '`127.0.0.1` 은 루프백 주소라 그 장비 안에서만 쓰입니다. 바깥에서 접속하게 하려면 `0.0.0.0` 이나 서버의 실제 주소로 듣도록 설정해야 합니다. ss(8) 로 듣는 주소와 포트를 확인합니다.', NULL, NULL, NULL, '[{"title": "ss(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 10, '/26 의 호스트 수', '`10.0.0.0/26` 서브넷에서 장비에 줄 수 있는 호스트 주소의 개수를 채우세요.', '주소 64 개에서 둘을 빼요.', NULL, NULL, '[]', 'fill', '["62", "64", "126", "30"]', NULL, '/26 은 호스트 부분이 6비트라 주소가 2^6 = 64 개이고, 네트워크 주소와 브로드캐스트 주소를 빼면 62 개입니다.', '[0]', '사용 가능한 호스트: {0} 개', NULL, '[{"title": "RFC 4632 CIDR", "url": "https://www.rfc-editor.org/rfc/rfc4632"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 11, '듣고 있는 포트 보기', '서버에서 **듣고 있는(listening) TCP 포트** 만 숫자로 보는 명령입니다. 빈칸을 채우세요.', 'listening 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-l", "-u", "-x", "-r"]', NULL, 'ss(8) 에서 `-l` 은 listening 소켓만, `-t` 는 TCP, `-n` 은 서비스 이름을 풀지 않고 숫자로 보여 줍니다. `-u` 는 UDP, `-x` 는 유닉스 소켓, `-r` 은 주소를 이름으로 풀어 줍니다.', '[0]', 'ss -t {0} -n', NULL, '[{"title": "ss(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 379, 12, '패킷이 목적지로 가는 길', '내 서버가 다른 네트워크의 서버로 패킷을 보낼 때의 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '내 서브넷인지 → 경로 → MAC → 전송 순서예요.', NULL, NULL, '[]', 'order', '["목적지 IP 가 내 서브넷 안에 있는지 확인한다", "아니라면 라우팅 테이블에서 가장 구체적인 경로(없으면 default)를 찾는다", "그 경로의 다음 홉(게이트웨이)의 MAC 주소를 ARP 로 알아낸다", "게이트웨이로 프레임을 보내 다음 네트워크로 넘긴다"]', NULL, '서브넷 안이면 직접 ARP 로 보내고, 밖이면 가장 길게 일치하는 경로(없으면 default)의 게이트웨이에게 보냅니다. 게이트웨이도 같은 링크에 있어서 MAC 주소는 ARP 로 알아냅니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "ip-route(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 379 AND order_index = 12);
