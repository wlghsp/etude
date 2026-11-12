-- OpenStack 세트 355. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_category.md
INSERT INTO unit (id, category, title, display_order) SELECT 37, 'OpenStack', '인스턴스', 111 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 37);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 355, 'OpenStack 인스턴스의 일생: 상태와 기본 동작', '서버(인스턴스)가 거치는 상태 BUILD·ACTIVE·SHUTOFF·ERROR 를 읽고, stop/start, pause/suspend, 소프트·하드 재부팅, shelve 의 차이를 한 개념씩 익힙니다. 서버를 끄고 다시 켜는 순서도 짚어 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 355);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 37), icon = '🔄', display_order = 703 WHERE id = 355;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 1, '아직 만드는 중인 서버의 상태', '`openstack server list` 의 **Status** 열에서 서버가 아직 처음 만들기를 끝내지 못했을 때 보이는 상태는 무엇일까요?', '상태 이름은 "하는 일"을 그대로 영어로 쓴 거예요.', NULL, NULL, '[]', 'choice', '["ACTIVE", "SHUTOFF", "BUILD", "PAUSED"]', 2, 'BUILD 는 서버가 처음 만들기(빌드) 과정을 아직 끝내지 못한 상태입니다. 다 만들어져 실행되면 ACTIVE 가 됩니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 2, '실행 중인 서버의 상태', '서버가 정상적으로 만들어져 **실행 중** 일 때 Status 열에 보이는 상태는 무엇일까요?', '상태 이름은 "하는 일"을 그대로 영어로 쓴 거예요.', NULL, NULL, '[]', 'choice', '["BUILD", "ACTIVE", "ERROR", "SHUTOFF"]', 1, 'ACTIVE 는 서버가 활성화되어 실행 중인 상태입니다. 접속해서 쓰려면 먼저 ACTIVE 인지 확인합니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 3, '전원이 꺼진 서버의 상태', '서버의 **전원이 꺼져 있지만 디스크 이미지는 그대로 남아 있을 때** 보이는 상태는 무엇일까요?', '상태 이름은 "하는 일"을 그대로 영어로 쓴 거예요.', NULL, NULL, '[]', 'choice', '["SHUTOFF", "DELETED", "BUILD", "ACTIVE"]', 0, 'SHUTOFF 는 서버의 전원이 꺼졌지만 디스크 이미지는 남아 있는 상태입니다. 다시 start 하면 ACTIVE 로 돌아옵니다. DELETED 는 서버가 완전히 삭제된 상태입니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 4, '문제가 생긴 서버의 상태', '서버를 만들거나 다루다가 **오류가 났을 때** 보이는 상태는 무엇일까요?', '상태 이름은 "하는 일"을 그대로 영어로 쓴 거예요.', NULL, NULL, '[]', 'choice', '["UNKNOWN", "PAUSED", "REBOOT", "ERROR"]', 3, 'ERROR 는 서버가 오류 상태라는 뜻입니다. UNKNOWN 은 상태를 알 수 없을 때(클라우드 제공자에게 문의하라는 안내)이므로 구분해서 기억합니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 5, '중지(stop)와 삭제(delete)의 차이', '`stop` 으로 서버를 멈춘 것과 `delete` 로 지운 것의 차이로 알맞은 것은 무엇일까요?', '멈춘 서버는 다시 켤 수 있어요.', NULL, NULL, '[]', 'choice', '["멈추면 서버가 곧바로 사라지고, 삭제하면 SHUTOFF 로 보관된다", "둘은 같은 동작이라 서비스 결과 상태도 똑같이 나타난다", "멈추면 SHUTOFF 로 남아 다시 켤 수 있고, 삭제하면 서버가 사라진다", "멈추면 디스크가 모두 지워지고 CPU 정보만 따로 남는다"]', 2, 'stop 은 전원을 끄는 동작이라 서버는 SHUTOFF 로 남고 start 로 다시 켤 수 있습니다. delete 는 서버를 삭제해 DELETED 상태가 됩니다.', NULL, NULL, NULL, '[{"title": "Nova VM 상태와 명령", "url": "https://docs.openstack.org/nova/latest/reference/vm-states.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 6, '일시정지(pause)와 일시중단(suspend)의 차이', '`pause` 와 `suspend` 는 둘 다 서버를 잠시 멈추지만 상태를 보관하는 곳이 다릅니다. 알맞은 설명은 무엇일까요?', 'RAM 에 두느냐, 디스크에 쓰느냐가 달라요.', NULL, NULL, '[]', 'choice', '["pause 는 상태를 디스크에 쓰고 멈추고, suspend 는 RAM 에 두고 얼어붙은 채 실행된다", "pause 는 상태를 RAM 에 두고 얼어붙은 채 계속 실행되고, suspend 는 상태를 디스크에 쓰고 멈춘다", "pause 와 suspend 는 서버를 삭제하는 서로 다른 방법이다", "pause 는 네트워크만 끊고 suspend 는 디스크만 끊는다"]', 1, '공식 API 문서는 PAUSED 를 "상태가 RAM 에 저장되고 서버는 얼어붙은 채 계속 실행"으로, SUSPENDED 를 "상태를 디스크에 쓰고 서버를 멈춤(자원은 예약 유지)"으로 설명합니다. 자원을 비우려면 suspend 대신 shelve 를 쓰라고 안내합니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 7, '소프트 재부팅과 하드 재부팅', '서버를 재부팅하는 방법에는 **소프트** 와 **하드** 가 있습니다. 하드 재부팅은 무엇에 비유할 수 있을까요?', '서버가 먹통일 때 쓰는 마지막 수단이에요.', NULL, NULL, '[]', 'choice', '["물리 서버의 전원 플러그를 뽑았다가 다시 꽂는 것", "운영체제에 정상 종료를 요청하고 다시 켜는 것", "서버를 삭제하고 같은 이름으로 새로 만드는 것", "서버의 이미지를 새 버전으로 바꾸는 것"]', 0, '공식 API 문서는 HARD_REBOOT 를 물리 서버의 전원 플러그를 뽑았다 꽂는 것과 같다고 설명합니다. 소프트 재부팅은 운영체제에 정상적으로 재시작을 요청하는 방식이라 먼저 시도합니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 8, '꺼진 서버 다시 켜기', '전원이 꺼진 서버(`SHUTOFF`) `web1` 을 **다시 켜는** 명령입니다. 빈칸을 채우세요.', '켜기(시작)를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["start", "resume", "unpause", "boot"]', NULL, '`openstack server start` 는 SHUTOFF 서버를 켭니다. `resume` 은 SUSPENDED 서버를, `unpause` 는 PAUSED 서버를 되돌리는 명령이라 상태에 맞게 구분합니다.', '[0]', 'openstack server {0} web1', NULL, '[{"title": "Nova VM 상태와 명령", "url": "https://docs.openstack.org/nova/latest/reference/vm-states.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 9, '서버 상태를 한눈에 보는 곳', '프로젝트의 서버들이 지금 어떤 상태인지 **목록으로** 확인하는 방법으로 알맞은 것은 무엇일까요?', '목록 명령의 열 이름을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`openstack flavor list` 결과의 Status 열을 본다", "`openstack image list` 로 서버의 Status 를 본다", "`openstack server list` 결과의 Status 열을 본다", "`openstack project list` 로 서버의 Status 를 본다"]', 2, '서버 목록(`openstack server list`)에 이름·상태(Status)·네트워크·이미지가 나옵니다. flavor·image·project 목록은 서버 상태를 보여 주지 않습니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 10, 'ERROR 상태의 서버는 어떻게 할까', '서버가 `ERROR` 상태가 되었습니다. 문서에 따르면 이 상태에서 허용되는 동작으로 알맞은 것은 무엇일까요?', '고장 난 서버를 치울 수 있어야 해요.', NULL, NULL, '[]', 'choice', '["삭제할 수 없고 영원히 그대로 둬야 한다", "삭제(delete)할 수 있다", "삭제는 안 되고 pause 만 할 수 있다", "자동으로 ACTIVE 로 바뀌므로 아무것도 할 수 없다"]', 1, 'Nova 문서의 VM 상태 표에서 ERROR 상태에서 허용되는 명령은 소프트 삭제와 삭제(delete)입니다. 원인을 확인한 뒤 서버를 지우고 다시 만들 수 있습니다.', NULL, NULL, NULL, '[{"title": "Nova VM 상태와 명령", "url": "https://docs.openstack.org/nova/latest/reference/vm-states.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 11, 'suspend 대신 shelve 를 쓰는 때', '일시중단(suspend)한 서버도 **자원을 계속 예약**해 둡니다. 컴퓨트 호스트의 자원을 실제로 비우고 싶을 때 공식 문서가 권하는 동작은 무엇일까요?', '이름이 책장에 올려 둔다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["shelve(보관)", "pause(일시정지)", "reboot(재부팅)", "rescue(구조 모드)"]', 0, '공식 API 문서는 suspend 한 서버가 자원을 예약해 둔 상태라, 자원을 풀어야 하면 shelve 하라고 안내합니다. SHELVED_OFFLOADED 는 서버가 컴퓨트 호스트에서 내려진 상태이고 다시 쓰려면 unshelve 가 필요합니다.', NULL, NULL, NULL, '[{"title": "Compute API 레퍼런스(서버 상태값)", "url": "https://docs.openstack.org/api-ref/compute/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 355, 12, '서버를 끄고 다시 켜는 순서', '실행 중인 서버를 끄고 다시 켜서 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 끄기 → 확인 → 켜기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["서버 목록에서 상태가 ACTIVE 인지 본다", "`openstack server stop web1` 로 서버를 끈다", "상태가 SHUTOFF 로 바뀌었는지 본다", "`openstack server start web1` 로 서버를 켠다", "상태가 다시 ACTIVE 가 되었는지 본다"]', NULL, '끄기 전에 상태를 확인하고, stop 뒤에는 SHUTOFF 를, start 뒤에는 ACTIVE 를 확인하며 진행합니다. 상태가 바뀌는 데 시간이 걸릴 수 있어 확인 단계가 필요합니다.', '[0, 1, 2, 3, 4]', NULL, NULL, '[{"title": "Nova VM 상태와 명령", "url": "https://docs.openstack.org/nova/latest/reference/vm-states.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 355 AND order_index = 12);
