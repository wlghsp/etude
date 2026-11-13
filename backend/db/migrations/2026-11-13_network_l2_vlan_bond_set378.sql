-- 네트워크 퀴즈 세트 378. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_quiz_sets.md
INSERT INTO unit (id, category, title, display_order) SELECT 47, '네트워크', '네트워크 기초', 5 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 47);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 378, '네트워크 연결 요소: VLAN·브리지·본딩·MTU', '같은 링크 안에서 일어나는 연결의 기본기를 익힙니다. VLAN 과 트렁크, 리눅스 브리지, 본딩 모드(balance-rr·active-backup·802.3ad)와 miimon, MTU 1500 과 점보 프레임, 관련 ip 명령을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 378);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🔌', display_order = 625 WHERE id = 378;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 1, 'VLAN 이란', '**VLAN** 은 무엇을 위한 기술일까요?', '물리 장비는 하나인데 논리적으로 나눠요.', NULL, NULL, '[]', 'choice', '["두 개의 물리 회선을 합쳐 속도를 두 배로 만든다", "서버의 디스크를 네트워크로 나눠 공유한다", "하나의 물리 네트워크를 논리적으로 나눠 브로드캐스트 영역을 분리한다", "IP 주소를 자동으로 나눠 주는 서비스를 만든다"]', 2, 'VLAN(IEEE 802.1Q)은 같은 스위치와 선을 쓰면서도 프레임에 VLAN 번호를 붙여 서로 다른 논리 네트워크로 나눕니다. 서로 다른 VLAN 은 라우터를 거쳐야 통신합니다. 회선을 합치는 것은 본딩이고, 주소를 나눠 주는 것은 DHCP 입니다.', NULL, NULL, NULL, '[{"title": "IEEE 802.1Q (위키백과)", "url": "https://en.wikipedia.org/wiki/IEEE_802.1Q"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 2, 'VLAN 번호의 범위', '802.1Q 의 VLAN ID(VID)는 12비트입니다. 0 과 4095 는 예약되어 있을 때 **쓸 수 있는 VLAN 은 최대 몇 개** 일까요?', '2 의 12 제곱에서 예약 두 개를 빼요.', NULL, NULL, '[]', 'choice', '["256 개", "4,094 개", "1,024 개", "65,536 개"]', 1, '위키백과 802.1Q 문서는 VID 가 12비트 필드이고 0 과 4095 가 예약되어 최대 4,094 개의 VLAN 을 쓸 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "IEEE 802.1Q (위키백과)", "url": "https://en.wikipedia.org/wiki/IEEE_802.1Q"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 3, '트렁크와 액세스', '스위치에서 **여러 VLAN 의 트래픽을 한 선으로** 함께 나르는 포트를 무엇이라 부를까요?', '한 선에 여러 VLAN 태그가 실려요.', NULL, NULL, '[]', 'choice', '["트렁크(trunk) 포트", "액세스(access) 포트", "루프백(loopback) 포트", "관리(console) 포트"]', 0, '트렁크 포트는 802.1Q 태그를 붙여 여러 VLAN 을 한 링크로 보냅니다. 액세스 포트는 한 VLAN 에만 속하고 보통 태그 없는 프레임을 주고받습니다.', NULL, NULL, NULL, '[{"title": "IEEE 802.1Q (위키백과)", "url": "https://en.wikipedia.org/wiki/IEEE_802.1Q"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 4, '리눅스 브리지', '리눅스의 **브리지(bridge)** 인터페이스는 무엇처럼 동작할까요?', '가상 머신의 네트워크 선을 모으는 곳이에요.', NULL, NULL, '[]', 'choice', '["패킷을 IP 주소로 골라 다른 네트워크로 보내는 라우터", "여러 회선을 묶어 속도를 늘려 주는 본딩 장치", "외부 주소를 내부 주소로 바꿔 주는 NAT 장비", "여러 인터페이스를 같은 L2 네트워크로 묶어 주는 소프트웨어 스위치"]', 3, 'ip-link(8) 의 장치 종류에는 `bridge`, `bond`, `vlan`, `veth` 가 모두 있습니다. 브리지는 붙은 인터페이스(물리 NIC, 가상 머신의 tap, 컨테이너의 veth)를 MAC 주소로 전달하는 스위치처럼 이어 줍니다. 가상화에서 VM 을 같은 망에 놓을 때 쓰입니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 5, '본딩의 기본 모드', '리눅스 본딩 드라이버의 **기본 모드** 는 무엇일까요?', '문서가 "기본은 ○○"이라고 말해요.', NULL, NULL, '[]', 'choice', '["active-backup (대기 전환)", "802.3ad (LACP 집계)", "balance-rr (번갈아 전송)", "broadcast (전체 복제)"]', 2, '커널 본딩 문서는 mode 의 기본값이 `balance-rr`(라운드 로빈)이라고 설명합니다. 운영에서는 목적에 맞게 `active-backup` 이나 `802.3ad` 를 명시해 쓰는 경우가 많습니다.', NULL, NULL, NULL, '[{"title": "리눅스 커널 본딩 문서", "url": "https://docs.kernel.org/networking/bonding.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 6, 'active-backup 모드', '본딩 **active-backup** 모드의 동작으로 알맞은 것은 무엇일까요?', '이름 그대로 평소엔 하나만 일해요.', NULL, NULL, '[]', 'choice', '["모든 슬레이브가 동시에 전송해서 속도가 모두 합쳐진다", "슬레이브 하나만 활성이며, 그것이 고장 나야 다른 하나가 이어받는다", "모든 슬레이브가 같은 패킷을 전부 중복해서 한꺼번에 보낸다", "트래픽을 해시로 나눠 서로 다른 슬레이브에 분산해 보낸다"]', 1, '커널 문서는 active-backup 이 "슬레이브 하나만 활성이며 활성 슬레이브가 고장 났을 때만 다른 슬레이브가 활성이 된다"고 설명합니다. 스위치에 특별한 설정이 필요 없어 장애 대비용으로 흔합니다.', NULL, NULL, NULL, '[{"title": "리눅스 커널 본딩 문서", "url": "https://docs.kernel.org/networking/bonding.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 7, '802.3ad 모드', '본딩 **802.3ad** 모드에 대한 설명으로 알맞은 것은 무엇일까요?', 'LACP 라고도 부르는 동적 링크 집계예요.', NULL, NULL, '[]', 'choice', '["동적 링크 집계로, 속도·duplex 가 같은 슬레이브끼리 그룹을 만든다", "스위치와 상관없이 서로 다른 속도의 포트를 자유롭게 섞어 묶는다", "슬레이브 하나만 쓰고 나머지는 전원을 꺼 두는 방식이다", "패킷을 슬레이브 순서대로 한 개씩 번갈아 가며 보내는 방식"]', 0, '커널 문서는 802.3ad 를 동적 링크 집계로 설명합니다. 같은 속도·duplex 를 가진 슬레이브로 집계 그룹을 만들고 전송 해시 정책으로 슬레이브를 고릅니다. 스위치 쪽에서도 LACP 를 설정해야 맞물립니다.', NULL, NULL, NULL, '[{"title": "리눅스 커널 본딩 문서", "url": "https://docs.kernel.org/networking/bonding.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 8, 'miimon 이란', '본딩 옵션 **miimon** 은 무엇을 정할까요?', 'MII 링크 감시예요.', NULL, NULL, '[]', 'choice', '["본딩에 쓸 수 있는 슬레이브의 최대 수", "프레임의 최대 크기(MTU)", "본딩 인터페이스의 MAC 주소", "링크 상태를 점검하는 주기(밀리초)"]', 3, '커널 문서는 miimon 을 MII 링크 감시 주기(밀리초)로 설명합니다. 0 이면 감시를 끄고, 100 이 시작점으로 좋으며 `arp_interval` 이 없으면 기본이 100 입니다. 문서는 miimon 이나 ARP 감시 중 하나는 꼭 설정하라고 경고합니다.', NULL, NULL, NULL, '[{"title": "리눅스 커널 본딩 문서", "url": "https://docs.kernel.org/networking/bonding.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 9, 'MTU 의 기본', '일반적인 이더넷(Ethernet II)에서 **MTU 의 표준값** 은 얼마일까요?', '바이트 단위예요.', NULL, NULL, '[]', 'choice', '["576 바이트", "9000 바이트", "1500 바이트", "65535 바이트"]', 2, '위키백과 MTU 문서는 Ethernet II 의 MTU 를 1500 으로 정리합니다. 점보 프레임(보통 9000 근처)은 경로의 모든 장비가 같은 값으로 맞춰져야 쓸 수 있습니다.', NULL, NULL, NULL, '[{"title": "최대 전송 단위 MTU (위키백과)", "url": "https://en.wikipedia.org/wiki/Maximum_transmission_unit"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 10, 'VLAN 인터페이스 만들기', '물리 인터페이스 `eth0` 위에 VLAN 100 인터페이스를 만드는 명령입니다. 빈칸을 채우세요.', '장치 종류(type)를 적어요.', NULL, NULL, '[]', 'fill', '["vlan", "bond", "bridge", "veth"]', NULL, 'ip-link(8) 의 `type vlan id 번호` 로 VLAN 하위 인터페이스를 만듭니다. `bond` 는 본딩, `bridge` 는 브리지, `veth` 는 가상 이더넷 쌍입니다.', '[0]', 'ip link add link eth0 name eth0.100 type {0} id 100', NULL, '[{"title": "ip-link(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 11, 'MTU 바꾸기', '`eth0` 의 MTU 를 9000 으로 바꾸는 명령입니다. 빈칸을 채우세요.', '옵션 이름이 그대로 MTU 예요.', NULL, NULL, '[]', 'fill', '["mtu", "speed", "mode", "queue"]', NULL, 'ip-link(8) 문법의 `mtu MTU` 항목입니다. 경로의 다른 장비 MTU 가 작으면 큰 패킷만 막히는 문제가 생기니 양 끝과 중간 장비를 함께 맞춰야 합니다.', '[0]', 'ip link set dev eth0 {0} 9000', NULL, '[{"title": "ip-link(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 378, 12, '브리지에 NIC 붙이기', '리눅스 브리지를 만들고 인터페이스를 붙여 쓰는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 붙이기 → 올리기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`ip link add br0 type bridge` 로 브리지를 만든다", "`ip link set eth1 master br0` 로 인터페이스를 브리지에 붙인다", "`ip link set br0 up` 으로 브리지를 올린다", "`bridge link` 로 붙은 포트를 확인한다"]', NULL, 'ip-link(8) 의 `type bridge` 로 만들고 `master` 로 인터페이스를 붙이며 `up` 으로 올립니다. `bridge link` 는 bridge(8) 의 포트 확인 명령입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "bridge(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/bridge.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 378 AND order_index = 12);
