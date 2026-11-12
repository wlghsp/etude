-- OpenStack 세트 354. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_category.md
INSERT INTO unit (id, category, title, display_order) SELECT 36, 'OpenStack', '서비스 지도', 110 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 36);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 354, 'OpenStack 핵심 서비스 지도: Nova·Neutron·Cinder·Glance·Keystone·Horizon', '서비스 이름과 맡은 일을 짝지어 외웁니다. Nova(서버), Neutron(네트워크), Cinder(볼륨), Glance(이미지), Keystone(인증), Horizon(대시보드), Swift(오브젝트), Heat(템플릿)와 서버를 만들 때 서비스들이 나눠 일하는 흐름을 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 354);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 36), icon = '🗺️', display_order = 702 WHERE id = 354;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 1, '서비스 고르기: 가상 서버 만들기', '**가상 서버(인스턴스)** 를 만들고 시작·중지·삭제하며, 어느 물리 서버에서 돌릴지 정하는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Glance", "Cinder", "Nova", "Horizon"]', 2, 'Nova 는 컴퓨트 서비스로, 가상 서버(인스턴스)를 대규모로 만들고 관리합니다. Glance 는 이미지, Cinder 는 볼륨, Horizon 은 대시보드를 맡습니다.', NULL, NULL, NULL, '[{"title": "Nova 문서", "url": "https://docs.openstack.org/nova/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 2, '서비스 고르기: 가상 네트워크', '인스턴스가 쓸 **가상 네트워크, 서브넷, 라우터, 보안 그룹** 을 제공하는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Cinder", "Neutron", "Keystone", "Swift"]', 1, 'Neutron 은 네트워킹 서비스로 IP 주소 관리, DHCP, 보안 그룹 같은 네트워크 기능을 클라우드 사용자에게 제공합니다.', NULL, NULL, NULL, '[{"title": "Neutron 문서", "url": "https://docs.openstack.org/neutron/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 3, '서비스 고르기: 디스크처럼 붙이는 볼륨', '인스턴스에 디스크처럼 붙여 쓰는 **블록 스토리지(볼륨)** 를 만들어 주는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Cinder", "Swift", "Glance", "Neutron"]', 0, 'Cinder 는 블록 스토리지 서비스로, 인스턴스에 영구 볼륨을 만들어 붙이고 떼는 일을 맡습니다. 인스턴스를 지워도 볼륨 데이터는 남겨 둘 수 있습니다.', NULL, NULL, NULL, '[{"title": "Cinder 문서", "url": "https://docs.openstack.org/cinder/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 4, '서비스 고르기: 부팅용 이미지', '서버를 시작할 때 쓰는 **디스크 이미지(부팅 템플릿)** 를 등록하고 찾아 주는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Nova", "Cinder", "Heat", "Glance"]', 3, 'Glance 는 이미지 서비스로, 디스크 이미지를 등록하고 찾고 컴퓨트에 전달하는 일을 맡습니다.', NULL, NULL, NULL, '[{"title": "Glance 문서", "url": "https://docs.openstack.org/glance/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 5, '서비스 고르기: 인증과 권한', '**사용자 인증과 권한 확인**, 그리고 다른 서비스의 위치 목록(서비스 카탈로그)을 맡는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Horizon", "Neutron", "Keystone", "Swift"]', 2, 'Keystone 은 인증 서비스입니다. 자격 증명을 확인해 토큰을 발급하고, 사용자·프로젝트·도메인·역할을 관리하며, 서비스 위치를 알려 주는 카탈로그도 제공합니다.', NULL, NULL, NULL, '[{"title": "Keystone 구조", "url": "https://docs.openstack.org/keystone/latest/getting-started/architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 6, '서비스 고르기: 웹 대시보드', '웹 브라우저에서 자원을 만들고 확인하는 **대시보드(웹 화면)** 를 제공하는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Keystone", "Horizon", "Glance", "Heat"]', 1, 'Horizon 은 대시보드로, 관리자와 사용자가 웹 화면에서 자원을 만들고 관리하고 모니터링하게 해 줍니다.', NULL, NULL, NULL, '[{"title": "Horizon 문서", "url": "https://docs.openstack.org/horizon/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 7, '서비스 고르기: 오브젝트 저장', '파일 같은 임의의 데이터를 **오브젝트** 형태로 저장하고 꺼내 주는 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Swift", "Cinder", "Glance", "Nova"]', 0, 'Swift 는 오브젝트 스토리지로 임의의 데이터를 저장하고 조회합니다. 인스턴스에 붙이는 디스크가 아니라 API 로 파일을 통째로 다루는 저장소입니다.', NULL, NULL, NULL, '[{"title": "Swift 문서", "url": "https://docs.openstack.org/swift/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 8, '서비스 고르기: 템플릿으로 한 번에 만들기', '**템플릿 파일** 하나로 서버, 네트워크, 볼륨 같은 여러 자원을 한 번에 만들어 주는(오케스트레이션) 서비스입니다. 무엇일까요?', '서비스 이름과 맡은 일을 짝지어 보세요.', NULL, NULL, '[]', 'choice', '["Nova", "Horizon", "Swift", "Heat"]', 3, 'Heat 는 오케스트레이션 서비스로, 템플릿에 적어 둔 여러 자원을 한꺼번에 만들고 관리합니다.', NULL, NULL, NULL, '[{"title": "Heat 문서", "url": "https://docs.openstack.org/heat/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 9, 'Cinder 볼륨과 Swift 오브젝트의 차이', '둘 다 "저장" 서비스입니다. 차이로 알맞은 것은 무엇일까요?', '하나는 서버에 디스크처럼 붙이고, 하나는 API 로 파일을 다뤄요.', NULL, NULL, '[]', 'choice', '["Swift 는 인스턴스에 디스크처럼 붙이는 볼륨이고, Cinder 는 API 로 파일을 저장·조회하는 오브젝트 저장소다", "Cinder 와 Swift 는 둘 다 이미지를 등록하는 서비스라서 차이가 없다", "Cinder 는 인스턴스에 디스크처럼 붙이는 볼륨이고, Swift 는 API 로 파일을 저장·조회하는 오브젝트 저장소다", "Cinder 는 네트워크를, Swift 는 CPU 를 관리하는 서비스다"]', 2, 'Cinder 는 블록 스토리지로 인스턴스에 붙이는 영구 볼륨을, Swift 는 오브젝트 스토리지로 임의의 데이터를 API 로 저장·조회하는 저장소를 제공합니다.', NULL, NULL, NULL, '[{"title": "OpenStack 핵심 서비스 소개", "url": "https://docs.openstack.org/security-guide/introduction/introduction-to-openstack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 10, '요청 전 인증', 'OpenStack 에서 서비스를 쓰려면 **먼저 인증을 받아 토큰** 을 얻습니다. 인증을 맡는 서비스의 이름을 채우세요.', '"모든 서비스가 공통 Identity 서비스로 인증한다"는 구조예요.', NULL, NULL, '[]', 'fill', '["Keystone", "Nova", "Glance", "Horizon"]', NULL, 'Keystone 은 자격 증명을 확인하고 토큰을 발급합니다. 다른 서비스는 이 토큰으로 요청한 사람이 누구인지, 무엇을 해도 되는지 확인합니다.', '[0]', '모든 요청은 먼저 {0} 에서 인증을 받아 토큰을 얻는다', NULL, '[{"title": "Keystone 구조", "url": "https://docs.openstack.org/keystone/latest/getting-started/architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 11, 'Horizon 과 CLI 는 어떻게 일할까', '대시보드(Horizon)와 `openstack` CLI 로 같은 서버를 만들 수 있습니다. 둘이 일하는 방식으로 알맞은 것은 무엇일까요?', '둘 다 "클라이언트"예요.', NULL, NULL, '[]', 'choice', '["Horizon 도 CLI 도 각 서비스의 REST API 를 호출해 일한다", "Horizon 은 DB 를 직접 고치고 CLI 만 API 를 호출한다", "CLI 는 Horizon 서버를 거쳐야만 명령이 실행된다", "Horizon 과 CLI 는 서로 다른 별도의 클라우드를 다룬다"]', 0, '공식 문서는 대시보드·CLI·SDK 같은 클라이언트가 결국 각 서비스에 REST API 호출을 보낸다고 설명합니다. 그래서 어느 쪽으로 만들어도 같은 결과입니다.', NULL, NULL, NULL, '[{"title": "OpenStack 서비스 논리 구조", "url": "https://docs.openstack.org/install-guide/get-started-logical-architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 12, '서버를 만들 때 서비스들의 분담', '인스턴스를 만들 때 Nova 는 다른 서비스의 도움을 받습니다. 짝이 알맞은 것은 무엇일까요?', '이미지, 네트워크, 인증을 각각 누가 맡는지 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["부팅 이미지는 Swift, 네트워크 연결은 Cinder, 인증은 Horizon 이 맡는다", "부팅 이미지는 Neutron, 네트워크 연결은 Glance, 인증은 Heat 가 맡는다", "Nova 는 다른 서비스의 도움 없이 혼자 모든 일을 처리한다", "부팅 이미지는 Glance, 네트워크 연결은 Neutron, 인증은 Keystone 이 맡는다"]', 3, '서비스들은 역할을 나눠 서로의 API 를 호출합니다. 이미지는 Glance 가, 네트워크는 Neutron 이, 인증은 Keystone 이 맡고 Nova 가 이를 엮어 인스턴스를 만듭니다.', NULL, NULL, NULL, '[{"title": "OpenStack 서비스 논리 구조", "url": "https://docs.openstack.org/install-guide/get-started-logical-architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 354, 13, '서버 생성 요청이 처리되는 흐름', '사용자가 서버를 만들어 달라고 요청한 뒤 OpenStack 안에서 일어나는 일을 큰 줄기로 놓아 보세요.', '인증 → 요청 → 위치 정하기 → 준비 → 시작 순서예요.', NULL, NULL, '[]', 'order', '["Keystone 에서 인증하고 토큰을 받는다", "Nova API 에 서버 생성을 요청한다", "Nova 스케줄러가 인스턴스를 돌릴 물리 서버(컴퓨트 노드)를 고른다", "컴퓨트 노드가 Glance 에서 이미지를 받고 Neutron 으로 네트워크를 연결한다", "하이퍼바이저가 인스턴스를 시작한다"]', NULL, '큰 줄기만 단순화한 흐름입니다. 토큰으로 인증한 뒤 Nova 가 요청을 받고, 스케줄러가 돌릴 컴퓨트 노드를 고르고, 이미지와 네트워크를 준비해 하이퍼바이저가 시작합니다. 실제 내부 단계는 환경과 버전에 따라 더 많습니다.', '[0, 1, 2, 3, 4]', NULL, NULL, '[{"title": "OpenStack 서비스 논리 구조", "url": "https://docs.openstack.org/install-guide/get-started-logical-architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 354 AND order_index = 13);
