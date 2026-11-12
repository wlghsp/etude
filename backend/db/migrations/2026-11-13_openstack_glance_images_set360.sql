-- OpenStack 세트 360. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_category.md
INSERT INTO unit (id, category, title, display_order) SELECT 39, 'OpenStack', '스토리지와 이미지', 113 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 39);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 360, 'Glance 이미지 기초: 이미지 상태·포맷·공개 범위와 저장 서비스 구분', '서버를 시작할 때 쓰는 원본인 이미지를 익힙니다. Glance 의 역할, 변경 불가, queued·active 상태, 디스크·컨테이너 포맷, 공개 범위를 짚고, 이미지·볼륨·오브젝트 저장 서비스를 헷갈리지 않게 구분합니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 360);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 39), icon = '🖼️', display_order = 708 WHERE id = 360;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 1, 'Glance 가 하는 일', 'OpenStack 의 **Glance** 가 맡은 일로 알맞은 것은 무엇일까요?', '서버를 시작할 때 쓰는 원본을 다뤄요.', NULL, NULL, '[]', 'choice', '["가상 네트워크와 라우터를 만드는 일", "사용자의 로그인 정보를 확인하는 일", "가상 머신 이미지를 찾고 등록하고 가져오는 일", "서버에 붙이는 영구 블록 볼륨을 만드는 일"]', 2, '공식 문서는 Glance 를 가상 머신(VM) 이미지를 찾고(discover), 등록하고(register), 가져오는(retrieve) 서비스로 설명합니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 2, '이미지는 바꿀 수 있을까', 'Glance 에 한 번 저장된 **이미지 데이터** 에 대한 설명으로 알맞은 것은 무엇일까요?', '템플릿은 찍어 낸 뒤 그대로 두는 게 안전하죠.', NULL, NULL, '[]', 'choice', '["언제든 같은 이미지에 이어서 덮어쓸 수 있다", "한 번 저장되면 바꿀 수 없다(불변)", "서버가 부팅될 때마다 자동으로 새 내용으로 바뀐다", "서버를 삭제하면 이미지 내용도 함께 지워진다"]', 1, 'Glance API 문서는 이미지 데이터가 한 번 Glance 에 저장되면 변경할 수 없다(immutable)고 설명합니다. 내용을 바꾸려면 새 이미지를 만듭니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 3, 'queued 상태', '이미지 상태가 **queued** 입니다. 무슨 뜻일까요?', '"줄 서 있다"는 이름 그대로예요.', NULL, NULL, '[]', 'choice', '["이미지가 예약(등록)만 되었고 아직 데이터가 올라오지 않았다", "이미지가 삭제되어 복구할 수 없는 상태다", "이미지가 이미 서버에서 실행 중인 상태다", "이미지 데이터가 올라와 바로 쓸 수 있는 상태다"]', 0, 'Glance 문서에 따르면 queued 는 이미지가 예약되었지만 데이터가 아직 없는 상태입니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 4, 'active 상태', '이미지 상태가 **active** 입니다. 무슨 뜻일까요?', '데이터가 올라오면 이 상태가 돼요.', NULL, NULL, '[]', 'choice', '["이미지 데이터가 아직 올라오지 않아 예약만 된 상태다", "이미지가 사용자에게 삭제되어 목록에서 사라진 상태다", "이미지가 오류로 영영 쓸 수 없게 된 상태다", "이미지 데이터가 올라와서 서버를 만들 때 쓸 수 있게 되었다"]', 3, 'Glance 문서에 따르면 예약된 이미지에 데이터가 더해지면 Glance 가 상태를 active 로 바꿉니다. 이제 서버 부팅에 쓸 수 있습니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 5, '컨테이너 포맷으로 알맞은 것', 'Glance 이미지에는 **디스크 포맷** 과 **컨테이너 포맷** 이 따로 있습니다. 다음 중 **컨테이너 포맷** 값은 무엇일까요?', '디스크 포맷은 qcow2·raw 처럼 디스크 파일의 형식이에요.', NULL, NULL, '[]', 'choice', '["qcow2", "raw", "bare", "vmdk"]', 2, 'Glance 문서의 컨테이너 포맷 값에는 aki·ari·ami·bare·ova·ovf·docker 가 있고, qcow2·raw·vmdk 는 디스크 포맷 값입니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 6, '공개 표시가 없는 이미지', '이미지에 **공개(public) 표시가 없으면** 기본적으로 어떻게 다룰까요?', '표시하지 않으면 안전한 쪽으로 봐요.', NULL, NULL, '[]', 'choice', '["모든 프로젝트에 자동으로 공개된다", "공개가 아닌 소유자 이미지로 다룬다", "이미지가 자동으로 삭제된다", "관리자만 볼 수 있고 소유자도 쓸 수 없다"]', 1, 'Glance 문서는 공개 표시가 없는 이미지를 공개가 아니며 한 사용자가 소유한 것으로 간주한다고 설명합니다. 공개(public), 소유(owned), 멤버십 공유 같은 구분이 있습니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 7, '저장 서비스 구분하기', '부팅용 이미지는 어디에서 관리할까요? 서비스와 맡은 일의 짝으로 알맞은 것은 무엇일까요?', '이미지, 블록, 오브젝트를 구분해 보세요.', NULL, NULL, '[]', 'choice', '["부팅용 이미지는 Glance, 붙이는 디스크는 Cinder, 파일 저장은 Swift", "부팅용 이미지는 Cinder, 붙이는 디스크는 Swift, 파일 저장은 Glance", "부팅용 이미지는 Neutron, 붙이는 디스크는 Nova, 파일 저장은 Keystone", "부팅용 이미지도 붙이는 디스크도 파일 저장도 모두 Horizon"]', 0, 'Glance 는 이미지를, Cinder 는 서버에 붙이는 블록 볼륨을, Swift 는 오브젝트(파일) 저장을 맡습니다. 헷갈리면 "이미지=원본, 볼륨=붙이는 디스크, 오브젝트=파일"로 기억합니다.', NULL, NULL, NULL, '[{"title": "OpenStack 핵심 서비스 소개", "url": "https://docs.openstack.org/security-guide/introduction/introduction-to-openstack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 8, '이미지와 볼륨 스냅샷의 차이', '**이미지** 와 **볼륨 스냅샷** 의 차이로 알맞은 것은 무엇일까요?', '하나는 서버 시작용 원본, 하나는 볼륨의 한 시점이에요.', NULL, NULL, '[]', 'choice', '["이미지는 볼륨의 한 시점 기록이고, 스냅샷은 서버를 시작하는 원본이다", "둘은 이름만 다른 같은 것이라 서로 바꿔 써도 된다", "이미지는 네트워크 설정이고 스냅샷은 보안 규칙이다", "이미지는 서버를 시작할 때 쓰는 원본이고, 볼륨 스냅샷은 볼륨의 특정 시점 상태다"]', 3, 'Glance 이미지는 서버를 시작할 때 쓰는 디스크 원본이고, Cinder 스냅샷은 볼륨의 특정 시점 상태를 기록한 것입니다. 쓰이는 서비스와 용도가 다릅니다.', NULL, NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 9, '이미지가 컴퓨트에 전달되는 흐름', '서버를 시작할 때 이미지는 어떻게 쓰일까요?', '이미지를 보관하는 서비스와 서버를 만드는 서비스를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["Neutron 이 이미지를 직접 만들어 Keystone 에 전달한다", "Horizon 이 이미지를 서버 안에 직접 설치해 둔다", "Glance 가 이미지를 찾아 Nova 에 전달해 시작 디스크로 쓴다", "이미지는 서버를 시작할 때 아무 곳에서도 쓰이지 않는다"]', 2, '보안 가이드는 Glance 가 디스크 이미지의 검색·등록·컴퓨트로의 전달을 맡는다고 설명합니다. 서버는 이 이미지를 원본으로 시작합니다.', NULL, NULL, NULL, '[{"title": "OpenStack 핵심 서비스 소개", "url": "https://docs.openstack.org/security-guide/introduction/introduction-to-openstack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 10, '이미지 목록 보기', '쓸 수 있는 **이미지 목록** 을 보는 명령입니다. 빈칸을 채우세요.', '이미지를 영어로 쓰면 돼요.', NULL, NULL, '[]', 'fill', '["image", "template", "iso", "disk"]', NULL, '`openstack image list` 로 Glance 에 등록된 이미지를 확인합니다.', '[0]', 'openstack {0} list', NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 11, '이미지 등록하기', '파일 `cirros.img` 로 이미지를 **등록** 할 때 디스크 포맷을 지정하는 부분입니다. 빈칸을 채우세요. (이 파일은 qcow2 형식이라고 가정합니다)', '디스크 파일의 형식 이름이에요.', NULL, NULL, '[]', 'fill', '["qcow2", "nova", "bare", "yaml"]', NULL, '`--disk-format` 에는 qcow2·raw·iso·vmdk 같은 디스크 포맷을 씁니다. `bare` 는 컨테이너 포맷 값입니다.', '[0]', 'openstack image create --disk-format {0} --file cirros.img cirros', NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 360, 12, '이미지를 등록해 서버를 만들기까지', '새 이미지를 등록해서 서버를 만들기까지의 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '예약 → 데이터 올리기 → 상태 확인 → 서버 순서예요.', NULL, NULL, '[]', 'order', '["이미지를 등록해 예약한다(queued)", "이미지 데이터를 올린다", "이미지 상태가 active 가 되었는지 확인한다", "그 이미지로 서버를 만든다"]', NULL, '이미지는 먼저 예약(queued)되고 데이터가 올라오면 active 가 됩니다. active 가 된 뒤에야 서버를 만드는 데 쓸 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Glance 이미지 API", "url": "https://docs.openstack.org/glance/latest/user/glanceapi.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 360 AND order_index = 12);
