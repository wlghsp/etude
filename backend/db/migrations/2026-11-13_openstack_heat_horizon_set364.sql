-- OpenStack 세트 364. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_category.md
INSERT INTO unit (id, category, title, display_order) SELECT 41, 'OpenStack', '오브젝트와 자동화', 115 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 41);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 364, 'Heat 와 Horizon 기초: 템플릿·스택과 대시보드', '여러 자원을 템플릿으로 한꺼번에 만드는 Heat 와 웹 대시보드 Horizon 을 익힙니다. HOT 템플릿의 항목(버전·parameters·resources·outputs), 스택 만들기·지우기 명령, 서버 자원 타입을 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 364);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 41), icon = '📜', display_order = 712 WHERE id = 364;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 1, 'Heat 가 하는 일', 'OpenStack 의 **Heat** 는 어떤 일을 하는 서비스일까요?', '오케스트라 지휘자처럼 여러 자원을 한꺼번에 다뤄요.', NULL, NULL, '[]', 'choice', '["가상 머신 이미지를 등록하고 가져온다", "사용자의 로그인과 권한을 확인한다", "선언적 템플릿으로 여러 자원을 오케스트레이션한다", "서버에 붙이는 영구 볼륨을 만든다"]', 2, 'Heat 문서는 "복합 클라우드 애플리케이션을 오케스트레이션하는 서비스"이며 선언적 템플릿 형식과 OpenStack 고유 REST API 를 쓴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Heat 소개", "url": "https://docs.openstack.org/heat/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 2, '템플릿이 담는 것', 'Heat **템플릿** 은 무엇을 담은 파일일까요?', '텍스트 파일 하나에 적어요.', NULL, NULL, '[]', 'choice', '["서버 안에서 실행되는 프로그램의 실행 파일", "클라우드 애플리케이션의 인프라를 설명하는 텍스트", "사용자들의 비밀번호 목록", "서비스가 남긴 오류 로그의 기록"]', 1, 'Heat 문서는 "템플릿이 클라우드 애플리케이션의 인프라를 텍스트 파일로 설명한다"고 합니다.', NULL, NULL, NULL, '[{"title": "Heat 소개", "url": "https://docs.openstack.org/heat/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 3, '자원 사이의 관계', '템플릿에서 **자원 사이의 관계** 를 적어 두면 Heat 는 무엇을 해 줄까요?', '무엇을 먼저 만들어야 하는지 알 수 있어요.', NULL, NULL, '[]', 'choice', '["알맞은 순서로 자원을 만들어 준다", "자원을 모두 동시에 한 번에 지운다", "자원의 이름을 자동으로 바꿔 준다", "자원 사이의 관계는 Heat 가 무시한다"]', 0, 'Heat 문서는 템플릿이 자원 사이의 관계를 정의하므로 Heat 가 자원을 올바른 순서로 만들 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Heat 소개", "url": "https://docs.openstack.org/heat/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 4, '필수 버전 항목', 'HOT 템플릿에 **반드시** 있어야 하는 최상위 항목은 무엇일까요?', '템플릿 형식의 버전을 적어요.', NULL, NULL, '[]', 'choice', '["description (템플릿 설명)", "outputs (돌려줄 값)", "parameters (입력 값)", "heat_template_version (버전)"]', 3, 'HOT 가이드는 `heat_template_version` 이 필수이며 `2015-10-15` 같은 유효한 버전을 적어야 한다고 설명합니다. `description` 은 선택(권장)입니다.', NULL, NULL, NULL, '[{"title": "Heat HOT 템플릿 가이드", "url": "https://docs.openstack.org/heat/latest/template_guide/hot_guide.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 5, 'resources 항목', 'HOT 템플릿의 **resources** 항목에 대한 설명으로 알맞은 것은 무엇일까요?', '실제로 만들 것들을 적는 곳이에요.', NULL, NULL, '[]', 'choice', '["선택이며 비워 둬도 된다", "사용자가 배포 때 입력하는 값을 적는 곳이다", "필수이며 자원 정의가 최소 하나는 있어야 한다", "템플릿을 실행한 결과 값을 돌려주는 곳이다"]', 2, 'HOT 가이드는 `resources` 가 필수이며 자원 정의가 최소 하나 있어야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Heat HOT 템플릿 가이드", "url": "https://docs.openstack.org/heat/latest/template_guide/hot_guide.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 6, 'parameters 항목', 'HOT 템플릿의 **parameters** 항목은 무엇일까요?', '배포하는 사람이 정해 주는 값이에요.', NULL, NULL, '[]', 'choice', '["템플릿이 끝난 뒤 돌려주는 결과 값", "배포할 때 사용자가 넣어 주는 입력 값", "만들어질 자원의 목록", "템플릿 작성자의 이름과 연락처"]', 1, '문서는 `parameters` 가 배포 때 사용자가 주는 입력 값이며, 기본값·숨김·제약 조건을 둘 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Heat HOT 템플릿 가이드", "url": "https://docs.openstack.org/heat/latest/template_guide/hot_guide.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 7, 'outputs 항목', 'HOT 템플릿의 **outputs** 항목은 무엇일까요?', '배포가 끝난 뒤 사용자에게 알려 줘요.', NULL, NULL, '[]', 'choice', '["사용자에게 돌려주는 값", "배포할 때 사용자가 넣어 주는 입력 값", "만들어질 자원의 정의 목록", "템플릿 형식의 버전 번호"]', 0, '문서는 `outputs` 가 사용자에게 돌려주는 값이며 보통 `get_attr` 같은 내장 함수로 구한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Heat HOT 템플릿 가이드", "url": "https://docs.openstack.org/heat/latest/template_guide/hot_guide.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 8, 'Horizon 이란', 'OpenStack 의 **Horizon** 은 무엇일까요?', '화면으로 서비스를 다뤄요.', NULL, NULL, '[]', 'choice', '["서버를 만들 때 쓰는 가상 머신 이미지", "서버에 붙이는 영구 볼륨 저장소", "서비스 사이를 잇는 가상 네트워크", "서비스를 웹으로 다루는 대시보드"]', 3, 'Horizon 문서는 Horizon 을 OpenStack 대시보드의 표준 구현으로, Nova·Swift·Keystone 등 서비스를 위한 웹 기반 사용자 인터페이스라고 설명합니다.', NULL, NULL, NULL, '[{"title": "Horizon 문서", "url": "https://docs.openstack.org/horizon/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 9, '스택 이름', '이미 만든 Heat **스택의 이름** 에 대해 문서가 알려 주는 것은 무엇일까요?', '이름표는 한 번 붙이면...', NULL, NULL, '[]', 'choice', '["언제든 같은 명령으로 이름을 바꿀 수 있다", "이름은 스택을 지울 때만 쓰이고 만들 때는 없다", "시작한 뒤에는 이름을 바꿀 수 없다", "이름이 같은 스택은 자동으로 합쳐진다"]', 2, 'Heat 시작 문서는 "스택은 시작한 뒤에는 이름을 바꿀 수 없다"고 설명합니다.', NULL, NULL, NULL, '[{"title": "Heat 스택 만들기", "url": "https://docs.openstack.org/heat/latest/getting_started/create_a_stack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 10, '스택 만들기', '템플릿 파일로 스택을 **만드는** 명령입니다. 빈칸을 채우세요.', '만든다는 동사예요.', NULL, NULL, '[]', 'fill', '["create", "run", "build", "apply"]', NULL, '문서 예시는 `openstack stack create -t 템플릿 --parameter ... teststack` 입니다.', '[0]', 'openstack stack {0} -t template.yaml teststack', NULL, '[{"title": "Heat 스택 만들기", "url": "https://docs.openstack.org/heat/latest/getting_started/create_a_stack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 11, '서버 리소스 타입', '컨테이너가 아니라 컴퓨트 **인스턴스** 를 정의하는 자원 타입입니다. 빈칸을 채우세요.', '타입 이름 마지막 부분이에요.', NULL, NULL, '[]', 'fill', '["Server", "Network", "Volume", "Stack"]', NULL, 'HOT 가이드 예시는 컴퓨트 인스턴스를 `type: OS::Nova::Server` 로 정의하며 키페어·이미지·플레이버를 속성으로 줍니다.', '[0]', 'type: OS::Nova::{0}', NULL, '[{"title": "Heat HOT 템플릿 가이드", "url": "https://docs.openstack.org/heat/latest/template_guide/hot_guide.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 364, 12, '스택 만들고 지우기', '템플릿으로 스택을 만들어 쓰고 지우는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '쓰기 → 만들기 → 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["템플릿 파일을 쓴다", "`openstack stack create` 로 스택을 만든다", "`openstack stack show` 로 상태를 확인한다", "필요 없으면 `openstack stack delete` 로 지운다"]', NULL, '문서의 명령(create, list, show, delete)을 이은 큰 줄기입니다. 상태는 `CREATE_COMPLETE` 같은 값으로 보입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Heat 스택 만들기", "url": "https://docs.openstack.org/heat/latest/getting_started/create_a_stack.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 364 AND order_index = 12);
