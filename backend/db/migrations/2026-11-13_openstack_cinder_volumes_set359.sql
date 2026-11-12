-- OpenStack 세트 359. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_category.md
INSERT INTO unit (id, category, title, display_order) SELECT 39, 'OpenStack', '스토리지와 이미지', 113 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 39);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 359, 'Cinder 볼륨 기초: 볼륨·스냅샷·백업과 서버에 붙이기', '서버에 붙였다 뗄 수 있는 블록 스토리지인 볼륨을 한 개념씩 익힙니다. 볼륨, 스냅샷, 백업의 차이와 백업 저장소, 이미지로 만든 볼륨, 지우기 전에 떼기, 임시 디스크와의 구분, 볼륨을 만들어 서버에서 쓰기까지의 순서를 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 359);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 39), icon = '💾', display_order = 707 WHERE id = 359;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 1, '볼륨이란', 'Cinder 의 **볼륨(volume)** 은 무엇일까요?', '문서는 USB 외장 하드에 비유해요.', NULL, NULL, '[]', 'choice', '["서버를 만들 때 쓰는 운영체제 이미지 파일", "서버로 들어오는 트래픽을 거르는 규칙 모음", "서버에 붙였다 뗄 수 있는 블록 스토리지 장치", "서버의 CPU 와 메모리 크기를 정한 규격표"]', 2, '공식 문서는 볼륨을 "USB 하드 드라이브와 비슷한, 떼어 낼 수 있는 블록 스토리지 장치"라고 설명합니다. 서버를 지워도 볼륨 데이터는 따로 남겨 둘 수 있습니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 2, '블록 스토리지 서비스의 일', 'OpenStack 의 **블록 스토리지(Cinder)** 서비스가 맡은 일로 알맞은 것은 무엇일까요?', '이름이 가리키는 대로 서버에 디스크를 만들어 줘요.', NULL, NULL, '[]', 'choice', '["인스턴스가 쓸 가상 네트워크와 라우터를 만든다", "컴퓨트 인스턴스에 영구 블록 스토리지를 만들어 붙이고 관리한다", "사용자의 로그인과 권한을 확인해 토큰을 발급한다", "템플릿 파일로 여러 자원을 한꺼번에 만들어 준다"]', 1, '보안 가이드는 Cinder 를 컴퓨트 인스턴스에 영구적인 블록 스토리지를 제공하고, 볼륨의 생성부터 연결·해제까지 관리하는 서비스로 설명합니다.', NULL, NULL, NULL, '[{"title": "OpenStack 핵심 서비스 소개", "url": "https://docs.openstack.org/security-guide/introduction/introduction-to-openstack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 3, '볼륨은 한 번에 몇 대에 붙을까', '문서의 기본 설명으로, 볼륨 하나는 한 번에 서버 몇 대에 붙일 수 있을까요?', 'USB 하드 드라이브를 한 번에 몇 대 PC 에 꽂을 수 있는지 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["한 번에 서버 한 대에만 붙인다", "항상 서버 두 대 이상에 동시에 붙여야 한다", "프로젝트의 모든 서버에 자동으로 붙는다", "한 번 붙이면 서버를 지우기 전에는 뗄 수 없다"]', 0, 'Cinder 문서는 볼륨이 이식 가능한 블록 장치이며 한 번에 하나의 인스턴스에만 붙일 수 있다고 설명합니다. 사용이 끝나면 떼어 다른 서버에 붙일 수 있습니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 4, '이미지에서 볼륨 만들기', '서버를 만들기 전에 **이미지** 를 원본으로 해서 볼륨을 만들 수 있을까요?', '볼륨의 내용을 이미지로 채울 수 있는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["불가능하다. 볼륨은 항상 비어 있는 채로만 만들어진다", "이미지가 아니라 플로팅 IP 에서만 만들 수 있다", "서버가 삭제된 뒤에만 이미지 기반으로 만들 수 있다", "가능하다. 이미지를 기반으로 크기를 정해 볼륨을 만들 수 있다"]', 3, 'Cinder 문서에는 이미지를 기반으로 크기와 가용 영역을 정해 새 볼륨을 만드는 절차가 있습니다. 이렇게 만든 볼륨은 서버의 시작 디스크로 쓸 수 있습니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 5, '스냅샷이란', '볼륨의 **스냅샷(snapshot)** 은 무엇일까요?', '사진을 찍듯 그 순간을 남기는 거예요.', NULL, NULL, '[]', 'choice', '["볼륨을 영구히 지우는 명령의 이름", "볼륨에 연결된 서버의 CPU 사용 기록", "볼륨의 특정 시점 상태를 기록해 둔 것", "볼륨에 접근할 수 있는 사용자의 목록"]', 2, '공식 문서는 스냅샷을 "볼륨의 특정 시점 버전"이라고 설명합니다. 그 시점의 볼륨 상태를 기록해 두는 용도입니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 6, '볼륨을 지우려면', '볼륨을 **삭제** 하려고 합니다. 문서가 안내하는 순서로 알맞은 것은 무엇일까요?', '붙어 있는 디스크를 뽑지 않고 지울 수는 없어요.', NULL, NULL, '[]', 'choice', '["서버에 붙인 채로 곧바로 삭제해야 한다", "먼저 서버에서 볼륨을 떼어 낸 뒤 삭제한다", "삭제하기 전에 서버의 이미지부터 지워야 한다", "볼륨은 한 번 만들면 삭제할 수 없다"]', 1, 'Cinder 문서는 볼륨을 삭제하려면 먼저 서버에서 분리(detach)해야 한다고 안내합니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 7, '백업이 저장되는 곳', 'Cinder 볼륨의 **백업** 은 기본적으로 어디에 저장될까요?', '파일을 통째로 저장하는 서비스를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["기본은 Swift 오브젝트 스토어이고 NFS 로 바꿀 수도 있다", "항상 서버의 CPU 캐시 안에만 저장된다", "기본은 Keystone 의 토큰 저장소이고 바꿀 수 없다", "기본은 Neutron 의 라우터 설정 파일 안이다"]', 0, '공식 문서는 백업 저장소로 기본적으로 Swift 오브젝트 스토어를 쓰며, NFS 공유를 쓰도록 설정할 수도 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 백업", "url": "https://docs.openstack.org/cinder/latest/admin/volume-backups.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 8, '백업을 만들 수 있는 원본', '볼륨의 백업은 무엇으로부터 만들 수 있을까요?', '원본이 하나만 있는 건 아니에요.', NULL, NULL, '[]', 'choice', '["이미지 파일 한 가지로만", "플로팅 IP 와 보안 그룹의 조합으로만", "키페어를 등록한 사용자로만", "볼륨 자체, 또는 그 볼륨의 스냅샷"]', 3, '백업은 볼륨으로도, 볼륨의 스냅샷(`--snapshot` 옵션)으로도 만들 수 있습니다.', NULL, NULL, NULL, '[{"title": "Cinder 볼륨 백업", "url": "https://docs.openstack.org/cinder/latest/admin/volume-backups.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 9, '임시(ephemeral) 디스크란', '서버 안에서 쓰는 **임시(ephemeral) 디스크** 에 대한 설명으로 알맞은 것은 무엇일까요?', 'Cinder 볼륨과 달리 하이퍼바이저 쪽 디스크예요.', NULL, NULL, '[]', 'choice', '["서버에 붙였다 뗐다 하는 Cinder 블록 볼륨", "오브젝트 형태로 저장되는 파일 모음", "하이퍼바이저의 로컬 스토리지에 만들어지는 빈 디스크", "네트워크로 연결되는 가상 라우터 한 대"]', 2, 'Nova 문서의 블록 디바이스 매핑 설명에서 `blank` 소스를 `local` 로 두면 하이퍼바이저 로컬 스토리지의 빈 임시 디스크(또는 스왑 디스크)가 됩니다. Cinder 볼륨과 달리 서버에 딸린 로컬 디스크입니다.', NULL, NULL, NULL, '[{"title": "Nova 블록 디바이스 매핑", "url": "https://docs.openstack.org/nova/latest/user/block-device-mapping.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 10, '서버에 볼륨 붙이기', '서버 `web1` 에 볼륨 `data1` 을 **붙이는** 명령입니다. 빈칸을 채우세요.', '서버에 무언가를 더한다는 뜻의 동사예요.', NULL, NULL, '[]', 'fill', '["add", "attach", "mount", "connect"]', NULL, '`openstack server add volume SERVER VOLUME` 으로 볼륨을 서버에 붙입니다. 뗄 때는 `openstack server remove volume` 을 씁니다.', '[0]', 'openstack server {0} volume web1 data1', NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 11, '볼륨 백업 만들기', '볼륨 `data1` 의 **백업** 을 만드는 명령입니다. 빈칸을 채우세요.', '백업을 영어로 쓰면 돼요.', NULL, NULL, '[]', 'fill', '["backup", "copy", "clone", "save"]', NULL, '`openstack volume backup create VOLUME` 으로 볼륨의 백업을 만듭니다. 스냅샷에서 만들 때는 `--snapshot` 옵션을 더합니다.', '[0]', 'openstack volume {0} create data1', NULL, '[{"title": "Cinder 볼륨 백업", "url": "https://docs.openstack.org/cinder/latest/admin/volume-backups.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 359, 12, '볼륨을 만들어 서버에서 쓰기까지', '새 볼륨을 만들어 서버에서 실제로 쓰기까지의 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 붙이기 → 확인 → 쓰기 순서예요.', NULL, NULL, '[]', 'order', '["볼륨을 만든다", "서버에 볼륨을 붙인다", "서버 안에서 새 디스크 장치가 보이는지 확인한다", "파일 시스템을 만들고 마운트해서 쓴다"]', NULL, '볼륨은 만들 때 비어 있어서 서버에 붙인 뒤 서버 안에서 장치를 확인하고 파일 시스템을 만들어 마운트해야 씁니다. 이미지 기반 볼륨은 이미 내용이 들어 있어 이 마지막 단계가 다를 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Cinder 볼륨 관리", "url": "https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 359 AND order_index = 12);
