-- 퀴즈 세트 464. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_virt_round7.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 464, 'libvirt 인터페이스 유형: network·bridge·ethernet·direct, 권장 환경, macvtap 모드', '도메인 XML 의 interface 유형을 읽습니다. network 와 bridge 의 권장 환경, forward 모드별 DHCP·DNS 제공, default 네트워크, vnetN tun 장치, ethernet 과 managed no, direct 의 macvtap 모드와 trustGuestRxFilters 를 봅니다.', 'quiz', '가상화'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 464);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 1, 'network 권장', '`<interface type="network">` 가 **권장되는 환경** 은 무엇일까요?', '동적이에요.', NULL, NULL, '[]', 'choice', '["정적 유선 네트워크 호스트", "SR-IOV 전용 호스트", "동적·무선 네트워크 호스트", "컨테이너 전용 호스트"]', 2, 'libvirt 도메인 XML 문서는 가상 네트워크 연결을 동적·무선 네트워크 구성의 호스트(또는 호스트 하드웨어를 <network> 정의에서 따로 설명하는 다중 호스트 환경)에서 일반 게스트 연결에 권장한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 2, 'bridge 권장', '`<interface type="bridge">` 가 **권장되는 환경** 은 무엇일까요?', '정적이에요.', NULL, NULL, '[]', 'choice', '["동적·무선 네트워크 호스트", "정적 유선 네트워크 호스트", "NAT 만 쓸 수 있는 호스트", "게스트가 하나뿐인 호스트"]', 1, '문서는 LAN 으로의 브리지가 정적 유선 네트워크 구성의 호스트에서 일반 게스트 연결에 권장되며, 게스트가 물리 머신처럼 완전한 송수신 접근을 가진다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 3, 'DHCP·DNS', 'libvirt 가 가상 네트워크에서 **DHCP·DNS 를 직접 제공** 하는 forward 모드는 무엇일까요?', '내부에서 처리해요.', NULL, NULL, '[]', 'choice', '["격리(isolated)·nat·route", "bridge·private·vepa", "passthrough 만", "모든 forward 모드"]', 0, '문서는 bridge·private·vepa·passthrough 에서는 호스트에 필요한 DNS·DHCP 가 libvirt 밖에 이미 설정돼 있다고 가정하고, 격리·nat·routed 네트워크에서는 libvirt 가 DHCP·DNS 를 제공한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 4, 'default 네트워크', '기본으로 제공되는 `default` 가상 네트워크는 어떤 모양일까요?', 'NAT 예요.', NULL, NULL, '[]', 'choice', '["브리지, 192.168.1.0/24", "라우팅, 10.0.0.0/8", "격리, 172.16.0.0/12", "NAT, 192.168.122.0/24"]', 3, '문서는 default 라는 가상 네트워크 하나가 기본으로 설정돼 있어 기본 경로로 NAT 하며 IP 범위가 192.168.122.0/255.255.255.0 이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 5, 'tun 이름', '게스트마다 만들어지는 tun 장치의 **기본 이름 패턴** 은 무엇일까요?', '번호가 붙어요.', NULL, NULL, '[]', 'choice', '["ethN", "tapN", "vnetN", "virbrN"]', 2, '문서는 각 게스트에 vnetN 이름의 tun 장치가 만들어지며 <target> 요소로 바꿀 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 6, 'ethernet 유형', '`<interface type="ethernet">` 는 무엇을 쓸까요?', '외부에서 준비해요.', NULL, NULL, '[]', 'choice', '["물리 NIC 에 macvtap 으로 직접 붙는다", "외부에서 준비한 tap 장치", "libvirt 네트워크 정의에 연결한다", "호스트 브리지에 직접 붙는다"]', 1, '문서는 ethernet 이 일부 또는 전부 libvirt 밖(게스트 시작 전이나 스크립트로 시작 중)에서 설정한 새 tap 또는 기존 tap(veth 쌍)을 쓰는 방법이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 7, 'managed no', '`<target dev="mytap1" managed="no"/>` 가 **유용한 이유** 는 무엇일까요?', '권한과 관련돼요.', NULL, NULL, '[]', 'choice', '["비특권 libvirtd 도 tap NIC 사용 가능", "MAC 주소를 자동으로 생성해 준다", "tap 장치를 종료 때 자동 삭제한다", "NIC 모델을 virtio 로 고정한다"]', 0, '문서는 이미 만든 tap 장치에 managed="no" 를 주면 libvirt 가 기본 설정(MAC·IFF_UP)조차 하지 않고 하이퍼바이저에 넘기며, 비특권 libvirtd 가 관리하는 VM 이 tap 기반 에뮬레이션 NIC 를 쓸 수 있게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 8, 'direct 기본 모드', '`type="direct"`(macvtap)의 **기본 모드** 는 무엇일까요?', 'VEPA 예요.', NULL, NULL, '[]', 'choice', '["bridge", "private", "passthrough", "vepa"]', 3, '문서는 macvtap 모드로 vepa, bridge, private 를 고를 수 있으며 vepa 가 기본이라고 설명합니다. passthrough 는 SR-IOV VF 를 직접 붙입니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 9, 'trustGuestRxFilters', '`trustGuestRxFilters` 의 **기본값** 은 무엇일까요?', '보안 때문이에요.', NULL, NULL, '[]', 'choice', '["yes(성능상 이유)", "yes(호환성상 이유)", "no(보안상 이유)", "장치에 따라 자동 감지"]', 2, '문서는 trustGuestRxFilters 의 기본값이 보안상 이유로 no 이며, 지원은 virtio 모델과 호스트의 macvtap 연결에 한한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 10, '연결 유형', '호스트의 **브리지(br0)** 로 게스트를 붙이는 유형입니다. 빈칸을 채우세요.', 'bridge 예요.', NULL, NULL, '[]', 'fill', '["bridge", "network", "direct", "ethernet"]', NULL, 'bridge 유형은 호스트 브리지에 연결합니다. network 는 가상 네트워크 정의, direct 는 macvtap, ethernet 은 외부 tap 입니다.', '[0]', '<interface type="{0}"><source bridge="br0"/></interface>', NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 11, 'macvtap 모드', 'macvtap 의 **기본 동작 모드** 입니다. 빈칸을 채우세요.', 'Virtual Ethernet Port Aggregator 예요.', NULL, NULL, '[]', 'fill', '["vepa", "bridge", "private", "passthrough"]', NULL, 'vepa 는 모든 VM 의 패킷을 외부 브리지로 보내며, 같은 호스트 안 목적지의 패킷은 VEPA 지원 브리지가 되돌려 줍니다.', '[0]', '<source dev="eth0" mode="{0}"/>', NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 464, 12, '브리지 연결', '게스트를 호스트 브리지에 붙이는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '브리지 → 정의 → 반영 → 시작이에요.', NULL, NULL, '[]', 'order', '["호스트에 브리지(br0)를 만들고 물리 NIC 를 붙인다", "`<interface type=\\"bridge\\">` 에 `<source bridge=\\"br0\\"/>` 를 쓴다", "도메인 XML 을 정의해 반영한다", "게스트를 시작하면 vnetN tun 장치가 브리지에 붙는다"]', NULL, '문서의 "Bridge to LAN" 설명(호스트 브리지 전제, vnetN tun 장치가 브리지에 붙음)을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "libvirt Domain XML format", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 464 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 640, unit_id = (SELECT id FROM unit WHERE id = 48), icon = '🔌' WHERE id = 464;
