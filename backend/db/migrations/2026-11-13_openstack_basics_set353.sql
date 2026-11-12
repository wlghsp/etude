-- OpenStack 세트 353. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_category.md
INSERT INTO unit (id, category, title, display_order) SELECT 36, 'OpenStack', '서비스 지도', 110 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 36);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 353, 'OpenStack 이 하는 일: 클라우드·IaaS·셀프서비스 기초', 'OpenStack 이 무엇이고 왜 쓰는지부터 익힙니다. IaaS, 셀프서비스, API, 하이퍼바이저, 인스턴스, 프라이빗 클라우드, 프로젝트(테넌트)를 한 개념씩 짚고, 서버를 요청해 쓰기까지의 흐름을 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 353);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 36), icon = '☁️', display_order = 701 WHERE id = 353;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 1, 'OpenStack 은 무엇일까', 'OpenStack 을 한 문장으로 설명하면 무엇일까요?', '건물 하나에 있는 서버·디스크·네트워크를 "빌려 쓰게" 해 주는 소프트웨어예요.', NULL, NULL, '[]', 'choice', '["물리 서버 한 대 안에서만 돌아가는 단일 백업 프로그램", "개발자가 소스 코드의 변경 이력을 기록하는 버전 관리 도구", "서버·디스크·네트워크를 요청하는 대로 만들어 주는 오픈소스 클라우드 플랫폼", "웹 브라우저에서 문서를 편집하게 해 주는 오피스 서비스"]', 2, 'OpenStack 은 오픈소스 클라우드 컴퓨팅 플랫폼입니다. 여러 서비스가 함께 서버(컴퓨트), 스토리지, 네트워크 같은 인프라를 요청에 따라 만들어 줍니다.', NULL, NULL, NULL, '[{"title": "OpenStack 설치 안내: 개요", "url": "https://docs.openstack.org/install-guide/overview.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 2, 'IaaS 는 무엇을 빌려 쓰는 방식일까', '클라우드 서비스는 IaaS, PaaS, SaaS 로 나눕니다. **IaaS** 는 무엇을 빌려 쓰는 방식일까요?', 'I 는 Infrastructure(기반 설비)의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["완성된 메일이나 문서 편집 같은 응용 프로그램", "가상 서버·네트워크·디스크 같은 기반 설비", "코드만 올리면 되는 개발자용 실행 환경", "건물에 들어가는 전기와 냉방 같은 시설"]', 1, 'IaaS(Infrastructure as a Service)는 가상 서버·네트워크·스토리지 같은 **기반 설비**를 빌려 쓰는 방식입니다. 응용 프로그램을 그대로 쓰는 것은 SaaS, 코드를 올려 돌리는 실행 환경은 PaaS 입니다. OpenStack 공식 문서는 OpenStack 을 IaaS 솔루션으로 설명합니다.', NULL, NULL, NULL, '[{"title": "OpenStack 설치 안내: 개요", "url": "https://docs.openstack.org/install-guide/overview.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 3, '셀프서비스란', '클라우드의 **셀프서비스** 는 무엇을 뜻할까요?', '담당자에게 요청서를 내고 며칠 기다리는 방식과 비교해 보세요.', NULL, NULL, '[]', 'choice', '["필요한 서버를 사용자가 직접 요청하면 담당자를 거치지 않고 바로 만들어진다", "사용자가 서버를 물리적으로 직접 가져와 설치해야 한다", "관리자가 요청서를 받아 며칠 뒤 수동으로 서버를 만들어 준다", "서버를 한 번 만들면 사용자가 크기를 바꿀 수 없다"]', 0, '클라우드의 핵심은 사용자가 화면이나 API 로 직접 요청하면 시스템이 자원을 바로 만들어 주는 **셀프서비스** 입니다. 사람이 일일이 서버를 설치해 주는 방식과 다릅니다.', NULL, NULL, NULL, '[{"title": "OpenStack 설치 안내: 개요", "url": "https://docs.openstack.org/install-guide/overview.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 4, 'API 로도 만들 수 있다는 것의 이점', 'OpenStack 은 웹 화면뿐 아니라 **API** 로도 서버를 만들 수 있습니다. 이것이 주는 이점으로 알맞은 것은 무엇일까요?', '사람이 클릭하는 대신 프로그램이 같은 요청을 보낼 수 있어요.', NULL, NULL, '[]', 'choice', '["웹 화면이 필요 없어져 대시보드는 모두 삭제해야 한다", "요청 횟수와 상관없이 서버 사용료가 항상 무료가 된다", "한 번 만든 서버는 어떤 방법으로도 지울 수 없게 된다", "스크립트나 자동화 도구가 같은 요청을 보내 서버 생성을 자동으로 반복할 수 있다"]', 3, '각 서비스는 API 를 제공하고, 대시보드·CLI·SDK 는 결국 이 REST API 를 호출합니다. 그래서 사람이 화면에서 하는 일을 스크립트나 자동화 도구도 똑같이 할 수 있습니다.', NULL, NULL, NULL, '[{"title": "OpenStack 서비스 논리 구조", "url": "https://docs.openstack.org/install-guide/get-started-logical-architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 5, '하이퍼바이저는 무엇일까', '물리 서버 한 대에서 여러 가상 서버(VM)를 동시에 돌릴 수 있게 해 주는 소프트웨어를 무엇이라고 할까요?', 'hyper(위에서) + visor(감독)라는 이름에서 왔어요.', NULL, NULL, '[]', 'choice', '["로드 밸런서", "컴파일러", "하이퍼바이저", "방화벽"]', 2, '하이퍼바이저는 물리 서버의 CPU·메모리를 나눠 여러 가상 서버를 돌리게 해 주는 소프트웨어입니다. OpenStack 의 컴퓨트 노드에서 이 하이퍼바이저가 인스턴스를 실행합니다.', NULL, NULL, NULL, '[{"title": "Nova 문서", "url": "https://docs.openstack.org/nova/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 6, '인스턴스는 무엇일까', 'OpenStack 에서 **인스턴스** 라고 부르는 것은 무엇일까요?', '클라우드 안에서 실제로 돌아가는 서버를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["물리 서버에 달린 전원 장치 하나", "클라우드에서 실제로 돌아가는 가상 서버(VM) 하나", "서비스 이름을 적어 둔 설정 파일 하나", "클라우드 사용자의 로그인 계정 하나"]', 1, 'OpenStack 에서 인스턴스는 클라우드에서 실행 중인 **가상 서버(VM)** 하나입니다. 컴퓨트 서비스(Nova)가 인스턴스를 만들고 관리합니다.', NULL, NULL, NULL, '[{"title": "Nova 문서", "url": "https://docs.openstack.org/nova/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 7, '프라이빗 클라우드란', 'OpenStack 은 오픈소스라서 회사가 자기 데이터센터에 설치해 **한 조직이 전용으로** 쓰는 클라우드로 운영할 수 있습니다. 이런 클라우드를 무엇이라고 할까요?', '"사유(private)"라는 이름 그대로예요.', NULL, NULL, '[]', 'choice', '["프라이빗 클라우드: 한 조직이 전용으로 쓰는 클라우드", "퍼블릭 클라우드: 불특정 다수가 가입해 쓰는 외부 클라우드", "하이브리드 클라우드: 퍼블릭과 프라이빗을 섞어 쓰는 방식", "멀티 리전: 같은 서비스를 여러 지역에 나눠 두는 방식"]', 0, '한 조직이 자기 인프라 위에 전용으로 운영하는 클라우드는 프라이빗 클라우드입니다. 누구나 가입해 쓰는 외부 클라우드는 퍼블릭 클라우드, 둘을 섞어 쓰는 방식은 하이브리드 클라우드입니다.', NULL, NULL, NULL, '[{"title": "OpenStack 설치 안내: 개요", "url": "https://docs.openstack.org/install-guide/overview.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 8, '가상화와 클라우드의 차이', '**가상화** 기술만 있으면 클라우드가 되는 걸까요? 둘의 관계로 알맞은 것은 무엇일까요?', '가상화는 "나누는 기술", 클라우드는 "빌려 쓰는 서비스"에 가까워요.', NULL, NULL, '[]', 'choice', '["가상화와 클라우드는 이름만 다른 같은 말이라 차이가 전혀 없다", "클라우드는 가상화를 쓰면 안 되고 물리 서버만 사용해야 한다", "가상화는 클라우드가 만든 서버를 물리 서버로 되돌리는 기술이다", "가상화는 서버를 나누는 기술이고, 클라우드는 그 위에 셀프서비스와 API 를 더한 것이다"]', 3, '가상화는 물리 서버 하나를 여러 가상 서버로 나누는 **기술**입니다. 클라우드는 그 위에 사용자가 직접 요청하는 셀프서비스, 자원 풀, API 같은 **서비스 방식**을 더한 것입니다.', NULL, NULL, NULL, '[{"title": "OpenStack 설치 안내: 개요", "url": "https://docs.openstack.org/install-guide/overview.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 9, '프로젝트(테넌트)가 있는 이유', '같은 OpenStack 을 여러 팀이 함께 씁니다. 자원을 **프로젝트** 별로 나누는 이유로 알맞은 것은 무엇일까요?', '프로젝트는 "누구 것인가"를 나누는 단위예요.', NULL, NULL, '[]', 'choice', '["서버마다 서로 다른 운영체제를 쓰도록 강제로 나누려고", "사용자가 하이퍼바이저의 종류를 직접 고르게 하려고", "여러 팀이 같은 클라우드를 쓰되 자원을 팀별로 나눠 갖게 하려고", "서버를 만들 때마다 사용료를 자동으로 깎아 주려고"]', 2, 'Keystone 문서는 프로젝트를 OpenStack 에서 **소유의 기본 단위**라고 설명합니다. 팀마다 프로젝트를 두면 같은 클라우드를 쓰면서도 서버·네트워크 같은 자원을 팀별로 나눠 가질 수 있습니다.', NULL, NULL, NULL, '[{"title": "Keystone 구조", "url": "https://docs.openstack.org/keystone/latest/getting-started/architecture.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 10, '인스턴스 목록 보기', '`openstack` 명령으로 **인스턴스(서버) 목록** 을 보려고 합니다. 빈칸을 채우세요.', '인스턴스를 CLI 에서는 server 라고 불러요.', NULL, NULL, '[]', 'fill', '["server", "instance", "vm", "compute"]', NULL, '`openstack server list` 는 프로젝트의 인스턴스(서버) 목록을 보여 줍니다. CLI 에서 인스턴스는 `server` 라고 부릅니다.', '[0]', 'openstack {0} list', NULL, '[{"title": "OpenStack 클라이언트 문서", "url": "https://docs.openstack.org/python-openstackclient/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 11, '서버 만들기', '`openstack` 명령으로 서버를 **만드는** 명령입니다. 빈칸을 채우세요.', '"만들다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["create", "make", "new", "build"]', NULL, '`openstack server create` 로 서버를 만듭니다. `--flavor` 는 서버의 크기를, `--image` 는 부팅에 쓸 이미지를, 마지막 `web1` 은 서버 이름을 정합니다. 네트워크 등 다른 옵션이 더 필요할 수 있습니다.', '[0]', 'openstack server {0} --flavor m1.small --image cirros web1', NULL, '[{"title": "OpenStack 클라이언트 문서", "url": "https://docs.openstack.org/python-openstackclient/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 353, 12, '서버를 요청해서 쓰기까지', '사용자가 OpenStack 에서 서버를 하나 받아 쓰기까지의 순서입니다. 순서에 맞게 놓아 보세요.', '준비 → 선택 → 요청 → 확인 → 접속 순서예요.', NULL, NULL, '[]', 'order', '["인증 정보(자격 증명)를 준비해 로그인한다", "이미지, 플레이버(크기), 네트워크를 고른다", "서버 생성을 요청한다", "서버 상태가 ACTIVE 가 되었는지 확인한다", "SSH 같은 방법으로 접속해 사용한다"]', NULL, '먼저 로그인하고, 쓸 이미지·크기·네트워크를 고른 뒤 생성을 요청합니다. 상태가 `ACTIVE` 가 되면 서버가 실행 중이라는 뜻이라 그때 접속합니다. 실제 화면과 옵션은 환경마다 조금씩 다를 수 있습니다.', '[0, 1, 2, 3, 4]', NULL, NULL, '[{"title": "Nova 문서", "url": "https://docs.openstack.org/nova/latest/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 353 AND order_index = 12);
