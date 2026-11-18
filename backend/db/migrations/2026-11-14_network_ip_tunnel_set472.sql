-- 퀴즈 세트 472. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round12.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 472, 'ip tunnel 로 IP 터널 다루기: 모드, local·remote, ttl·tos, dev 바인딩, PMTU·DF, GRE key', 'IP 터널 명령을 읽습니다. 캡슐화 개념, IPv4·IPv6 캡슐화 모드, local 주소 조건, ttl 기본값, tos inherit, dev 바인딩, nopmtudisc 와 고정 ttl 제약, ignore-df, GRE 전용 key·ikey·okey, encaplimit 을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 472);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 1, 'tunnel 개념', 'ip-tunnel 문서가 설명하는 **tunnel** 은 무엇일까요?', '캡슐화예요.', NULL, NULL, '[]', 'choice', '["패킷을 암호화해서 L2 로만 보낸다", "여러 NIC 를 묶어 대역폭을 합친다", "패킷을 IP 패킷에 캡슐화해 IP 인프라로 보낸다", "패킷을 복제해 여러 경로로 보낸다"]', 2, '문서는 tunnel 객체가 패킷을 IP 패킷으로 캡슐화해 IP 인프라로 전송한다고 설명합니다. 바깥(outer) 주소 체계는 -f 옵션으로 정하며 기본은 IPv4 입니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 2, '모드 구분', '다음 중 **IPv6 로 캡슐화**하는 모드로 문서에 나온 것은 무엇일까요?', '이름에 6 이 들어가요.', NULL, NULL, '[]', 'choice', '["ipip", "ipip6", "sit", "gre"]', 1, '문서는 IPv4 캡슐화 모드로 ipip·sit·isatap·vti·gre, IPv6 캡슐화 모드로 ip6ip6·ipip6·ip6gre·vti6·any 를 듭니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 3, 'local', '`local ADDRESS` 에 쓸 수 있는 주소는 무엇일까요?', '다른 인터페이스예요.', NULL, NULL, '[]', 'choice', '["이 호스트 다른 NIC 의 주소", "원격 호스트에 있는 아무 주소", "터널 장치에 새로 만든 주소", "브로드캐스트 주소 중 하나"]', 0, '문서는 local 이 터널 패킷에 쓰는 고정 로컬 주소이며 이 호스트의 다른 인터페이스에 있는 주소여야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 4, 'ttl 기본', '터널 패킷의 TTL·hoplimit 기본값으로 맞는 것은 무엇일까요?', 'IPv4 와 IPv6 가 달라요.', NULL, NULL, '[]', 'choice', '["IPv4 64, IPv6 inherit", "IPv4·IPv6 모두 inherit", "IPv4·IPv6 모두 255", "IPv4 inherit, IPv6 64"]', 3, '문서는 ttl N 이 1~255 의 고정값이며 0 은 TTL 을 상속하라는 특별 값이고, 기본값은 IPv4 터널이 inherit, IPv6 터널이 64 라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 5, 'tos inherit', '`tos inherit` 를 쓰면 터널 패킷의 TOS 필드는 어떻게 정해질까요?', '원래 헤더를 따라요.', NULL, NULL, '[]', 'choice', '["항상 00 으로 고정한다", "라우팅 테이블에서 읽어 온다", "원래 IP 헤더에서 값을 복사한다", "터널 장치 이름에서 계산한다"]', 2, '문서는 inherit 가 필드를 원래 IP 헤더에서 복사하게 하고, inherit/STRING 은 IP 가 아닌 패킷을 터널링할 때 그 값으로 정하며, 기본값은 00 이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 6, 'dev 바인딩', '터널에 `dev NAME` 을 주면 무엇이 달라질까요?', '경로가 바뀔 때를 보세요.', NULL, NULL, '[]', 'choice', '["터널 장치의 이름이 NAME 으로 바뀐다", "엔드포인트 경로가 바뀌어도 그 장치로만 라우팅된다", "터널이 NAME 장치의 MTU 를 복사한다", "터널이 NAME 을 제외한 모든 장치로 나간다"]', 1, '문서는 dev 가 터널을 장치에 묶어 터널 패킷이 그 장치로만 라우팅되고 엔드포인트 경로가 바뀌어도 다른 장치로 빠져나가지 못하게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 7, 'nopmtudisc', '`nopmtudisc` 에 대한 설명으로 맞는 것은 무엇일까요?', '기본은 켜져 있어요.', NULL, NULL, '[]', 'choice', '["터널의 경로 MTU 탐색을 끄며, 고정 ttl 과는 함께 쓸 수 없다", "경로 MTU 탐색을 기본으로 켜며, 고정 ttl 과 함께 써야 한다", "DF 플래그를 항상 무시하며, 고정 ttl 에서만 동작한다", "터널 단편화를 끄며, 모든 모드에 동작한다"]', 0, '문서는 경로 MTU 탐색이 기본 활성이고 nopmtudisc 로 끄며, 고정 ttl 과는 호환되지 않아 고정 ttl 터널은 항상 PMTU 탐색을 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 8, 'ignore-df', '`ignore-df` 의 효과로 맞는 것은 무엇일까요?', 'DF 플래그예요.', NULL, NULL, '[]', 'choice', '["DF 플래그를 항상 켜서 단편화를 막는다", "MTU 를 넘으면 패킷을 조용히 버린다", "경로 MTU 탐색을 강제로 켠다", "DF 를 무시해 MTU 초과도 단편화"]', 3, '문서는 보통 DF 가 있으면 MTU 초과 데이터그램을 단편화하지 않고 ICMP 단편화 필요 메시지를 내지만, ignore-df 를 켜면 DF 플래그를 무시한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 9, 'GRE key', '`key`·`ikey`·`okey` 에 대한 설명으로 맞는 것은 무엇일까요?', 'GRE 전용이에요.', NULL, NULL, '[]', 'choice', '["모든 모드에서 쓰이며 key 는 입력용, okey 는 출력용이다", "GRE 전용이며 key 는 출력용, ikey 는 양방향이다", "GRE 전용이며 key 는 양방향, ikey·okey 는 입출력 따로 정한다", "IPv6 터널 전용이며 숫자만 쓸 수 있다"]', 2, '문서는 key 계열이 GRE 터널 전용이며 key 가 양방향 공통 키, ikey·okey 가 입력·출력 키를 따로 정하고, K 는 숫자나 점으로 구분한 IP 주소 모양이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 10, 'GRE 모드', 'IPv4 로 캡슐화하는 **GRE** 터널을 만드는 모드입니다. 빈칸을 채우세요.', '이름 그대로예요.', NULL, NULL, '[]', 'fill', '["gre", "ip6gre", "ip6ip6", "vti6"]', NULL, '문서는 IPv4 캡슐화 모드에 gre 가 있고 ip6gre 는 IPv6 캡슐화 모드라고 설명합니다.', '[0]', 'ip tunnel add gre1 mode {0} remote 203.0.113.2 local 198.51.100.1', NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 11, 'encaplimit', 'IPv6 터널의 `encaplimit` 기본값입니다. 빈칸을 채우세요.', '한 자리 수예요.', NULL, NULL, '[]', 'fill', '["4", "64", "255", "0"]', NULL, '문서는 encaplimit 이 IPv6 터널 전용 고정 캡슐화 한도이며 기본값이 4 라고 설명합니다.', '[0]', 'encaplimit 의 기본값은 {0}', NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 472, 12, '터널 다루기', '터널을 만들고 확인하고 바꾸고 지우는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '만들고 → 보고 → 바꾸고 → 지워요.', NULL, NULL, '[]', 'order', '["`ip tunnel add gre1 mode gre remote ... local ...` 로 터널을 만든다", "`ip tunnel show` 로 터널 목록을 확인한다", "`ip tunnel change gre1 ttl 64` 로 설정을 바꾼다", "`ip tunnel del gre1` 로 터널을 지운다"]', NULL, '문서의 add·show·change·delete 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "ip-tunnel(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-tunnel.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 472 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 651 WHERE id = 117;
UPDATE quest_set SET display_order = 647, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🚇' WHERE id = 472;
