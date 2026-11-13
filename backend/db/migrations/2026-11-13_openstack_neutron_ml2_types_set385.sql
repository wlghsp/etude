-- OpenStack 퀴즈 세트 385. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round2.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 385, 'Neutron 구조 깊게: ML2 드라이버, 네트워크 유형(flat·vlan·vxlan), L3 에이전트와 NAT', 'Neutron 이 네트워크를 만드는 방식을 익힙니다. flat·vlan·vxlan·gre 유형의 차이, 오버레이를 쓰는 이유, ML2 의 타입 드라이버와 메커니즘 드라이버, 플러그인은 하나만 쓴다는 점, L3 에이전트 장애의 영향, source NAT 와 floating IP 를 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 385);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 1, 'flat 네트워크', 'Neutron 의 **flat** 네트워크 유형은 어떤 모습일까요?', '나눔이 없어요.', NULL, NULL, '[]', 'choice', '["VLAN ID 마다 네트워크가 따로 만들어져 서로 분리된다", "패킷을 캡슐화한 오버레이로 서로 격리되어 통신한다", "모든 인스턴스가 같은 네트워크에 있고 VLAN 태깅 같은 분리를 하지 않는다", "프로젝트마다 자동으로 가상 라우터가 하나씩 생겨난다"]', 2, 'Neutron 문서는 flat 을 "모든 인스턴스가 같은 네트워크에 있으며 호스트와 공유될 수도 있고, VLAN 태깅 같은 분리가 없다"고 설명합니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 2, 'vlan 네트워크', 'Neutron 의 **vlan** 네트워크 유형에 대한 설명으로 알맞은 것은 무엇일까요?', '물리 네트워크의 VLAN 과 대응해요.', NULL, NULL, '[]', 'choice', '["패킷을 UDP 로 감싸서 어떤 물리 망 위에서도 동작한다", "802.1Q VLAN ID 로 물리 VLAN 과 맞물린다", "물리 네트워크와 완전히 무관한 순수 가상 망이다", "한 네트워크에 인스턴스를 하나만 둘 수 있다"]', 1, '문서는 VLAN 유형이 VLAN ID(802.1Q 태그)로 provider 또는 프로젝트 네트워크를 만들며 물리 네트워크에 있는 VLAN 과 대응한다고 설명합니다. 같은 VLAN 의 전용 서버·방화벽과도 통신할 수 있습니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 3, 'VXLAN 과 라우터', 'VXLAN 이나 GRE 프로젝트 네트워크의 트래픽이 **외부로 나가려면** 무엇이 필요할까요?', '문서가 꼭 필요하다고 해요.', NULL, NULL, '[]', 'choice', '["Neutron 라우터", "물리 스위치의 VLAN 설정 변경", "모든 인스턴스에 공인 IP 직접 할당", "추가 설정 없이 자동으로 외부와 연결된다"]', 0, '문서는 VXLAN·GRE 가 캡슐화로 오버레이 네트워크를 만들며, 프로젝트 네트워크 밖으로 트래픽이 흐르려면 Networking 라우터가 필요하다고 설명합니다. 라우터가 floating IP 를 통한 외부 접속도 제공합니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 4, '오버레이를 쓰는 이유', '셀프서비스 네트워크가 VLAN 보다 **VXLAN·GRE 오버레이** 를 주로 쓰는 이유는 무엇일까요?', '규모와 물리 설정 두 가지예요.', NULL, NULL, '[]', 'choice', '["오버레이가 항상 물리 VLAN 보다 훨씬 빠르기 때문이다", "오버레이는 암호화를 자동으로 해 주기 때문이다", "오버레이는 라우터 없이 외부와 통신하기 때문이다", "더 많은 네트워크를 지원하고 물리 네트워크 장비 설정이 덜 필요하다"]', 3, '문서는 오버레이가 VLAN 태깅(802.1Q)보다 훨씬 많은 네트워크를 지원하고, VLAN 은 보통 물리 네트워크 장비의 추가 설정이 필요하다고 설명합니다. 속도나 암호화를 이유로 들지는 않습니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 5, '타입 드라이버', 'ML2 의 **타입 드라이버(type driver)** 는 무엇을 정할까요?', '예시가 VXLAN 이에요.', NULL, NULL, '[]', 'choice', '["트래픽을 처리하는 구체적 소프트웨어(예: Open vSwitch)", "사용자가 로그인할 때 쓰는 인증 방식과 토큰 형식", "네트워크가 기술적으로 어떻게 구현되는지(유형)와 그 상태", "메시지 큐에 연결할 때 쓰는 주소와 비밀번호 설정"]', 2, 'ML2 문서는 타입 드라이버를 "OpenStack 네트워크가 기술적으로 어떻게 구현되는지 정의한다. 예: VXLAN"이라 하고, 유형별 상태를 유지하며 프로젝트 네트워크의 빈 세그먼트를 할당한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Neutron ML2 플러그인", "url": "https://docs.openstack.org/neutron/latest/admin/config-ml2.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 6, '메커니즘 드라이버', 'ML2 의 **메커니즘 드라이버(mechanism driver)** 는 무엇을 할까요?', '예시가 Open vSwitch 예요.', NULL, NULL, '[]', 'choice', '["네트워크 유형(flat, vlan 등)의 종류를 정의해 둔다", "타입 드라이버가 정한 정보를 실제 수단(예: Open vSwitch)에 적용한다", "프로젝트마다 만들 수 있는 네트워크 수에 상한을 둔다", "외부 사용자가 보낸 접속 요청을 대신 인증해 준다"]', 1, 'ML2 문서는 메커니즘 드라이버가 특정 유형의 네트워크에 접근하는 수단을 정의하며 타입 드라이버가 정한 정보를 활성화된 네트워킹 메커니즘에 맞게 적용하는 일을 맡는다고 설명합니다. L2 에이전트를 RPC 로 쓰거나 외부 장치·컨트롤러와 직접 상호작용합니다.', NULL, NULL, NULL, '[{"title": "Neutron ML2 플러그인", "url": "https://docs.openstack.org/neutron/latest/admin/config-ml2.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 7, '플러그인의 수', 'Neutron 에서 **네트워킹 플러그인** 은 한 번에 몇 개까지 쓸 수 있을까요?', '문서가 "하나만"이라고 써요.', NULL, NULL, '[]', 'choice', '["한 번에 하나만 쓸 수 있다", "여러 개를 동시에 마음대로 섞어 쓸 수 있다", "플러그인은 쓰지 않고 에이전트만 쓴다", "프로젝트마다 하나씩, 전체로는 수에 제한이 없다"]', 0, 'Neutron 소개 문서는 "한 번에 하나의 플러그인만 쓸 수 있다"고 설명합니다. 다만 ML2 플러그인 안에서는 여러 타입 드라이버와 메커니즘 드라이버를 함께 쓸 수 있습니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 8, 'L3 에이전트 장애', '가상 라우터를 구현하는 **L3 에이전트** 가 있는 네트워크 노드가 고장 나면 어떤 일이 생길 수 있을까요?', '셀프서비스 네트워크는 모두 이 에이전트를 지나요.', NULL, NULL, '[]', 'choice', '["이미 만들어진 인스턴스의 디스크가 모두 삭제된다", "프로바이더 네트워크 인스턴스만 연결이 끊어진다", "아무 영향이 없고 몇 분 안에 자동으로 복구된다", "많은 셀프서비스 네트워크와 인스턴스가 영향받을 수 있다"]', 3, '문서는 Networking 서비스가 라우터를 보통 하나 이상의 네트워크 노드에 있는 L3 에이전트로 구현하며, 프로바이더 네트워크와 달리 셀프서비스 네트워크는 L3 에이전트를 지나야 하므로 에이전트나 노드의 과부하·장애가 많은 네트워크와 인스턴스에 영향을 준다고 설명합니다. 고가용성 구성을 권합니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 9, '프로바이더 네트워크 관리', '**프로바이더(provider) 네트워크** 를 기본 설정에서 만들거나 고칠 수 있는 사람은 누구일까요?', '물리 네트워크 장비와 닿아 있어요.', NULL, NULL, '[]', 'choice', '["모든 프로젝트 사용자가 자유롭게 만들 수 있다", "프로젝트 소유자만 만들거나 고칠 수 있다", "기본적으로 관리자(권한 있는 사용자)만 가능하다", "Neutron 서버를 재시작한 직후에만 만들 수 있다"]', 2, '문서는 프로바이더 네트워크가 물리 네트워크 인프라와 맞닿아 있어 기본적으로 관리자만 만들거나 고칠 수 있다고 설명합니다. `policy.yaml` 의 매개변수로 허용 대상을 바꿀 수 있습니다.', NULL, NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 10, 'ML2 타입 드라이버', 'ML2 설정의 타입 드라이버 목록입니다. 빈칸에 들어갈 **네트워크 유형** 을 채우세요.', '오버레이 유형이에요.', NULL, NULL, '[]', 'fill', '["vxlan", "ovs", "ovn", "dhcp"]', NULL, 'ML2 문서의 예시는 `type_drivers = flat,vlan,vxlan,gre` 이고 사용 가능한 타입 드라이버로 Flat, VLAN, GRE, VXLAN 을 듭니다. `ovs`·`ovn` 은 메커니즘 드라이버 쪽의 이름입니다.', '[0]', 'type_drivers = flat,vlan,{0},gre', NULL, '[{"title": "Neutron ML2 플러그인", "url": "https://docs.openstack.org/neutron/latest/admin/config-ml2.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 11, '외부로 나갈 때의 변환', 'IPv4 셀프서비스 네트워크가 가상 라우터를 거쳐 프로바이더 네트워크와 통신할 때 쓰는 주소 변환입니다. 빈칸을 채우세요.', 'floating IP 는 destination NAT 예요.', NULL, NULL, '[]', 'fill', '["source", "destination", "static", "reverse"]', NULL, '문서는 IPv4 셀프서비스 네트워크가 가상 라우터의 source NAT 로 프로바이더 네트워크와 통신하고, floating IP 는 같은 라우터의 destination NAT 로 외부에서 인스턴스에 닿게 한다고 설명합니다.', '[0]', '가상 라우터의 {0} NAT', NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 385, 12, '셀프서비스 네트워크를 외부와 잇기', '셀프서비스(프로젝트) 네트워크를 외부 네트워크와 연결하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '네트워크 → 서브넷 → 라우터 → 연결 순서예요.', NULL, NULL, '[]', 'order', '["프로젝트 네트워크를 만든다", "그 네트워크에 서브넷을 만든다", "라우터를 만든다", "라우터에 서브넷을 붙이고 외부 게이트웨이를 지정한다"]', NULL, '문서는 프로젝트 네트워크 밖으로 나가려면 라우터가 필요하고 라우터가 외부 접속을 제공한다고 설명합니다. 네트워크와 서브넷을 만든 뒤 라우터에 서브넷을 붙이고 외부(프로바이더) 네트워크를 게이트웨이로 지정하는 것이 일반적인 순서입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Neutron 네트워킹 소개", "url": "https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 385 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 709 WHERE id = 359;
UPDATE quest_set SET display_order = 710 WHERE id = 360;
UPDATE quest_set SET display_order = 711 WHERE id = 361;
UPDATE quest_set SET display_order = 712 WHERE id = 362;
UPDATE quest_set SET display_order = 713 WHERE id = 363;
UPDATE quest_set SET display_order = 714 WHERE id = 364;
UPDATE quest_set SET display_order = 708, unit_id = (SELECT id FROM unit WHERE id = 38), icon = '🕸️' WHERE id = 385;
