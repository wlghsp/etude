-- 퀴즈 세트 435. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round6.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 435, 'ip neighbour 로 이웃 테이블 다루기: NUD 상태, show·flush 기본, add·replace·delete', '이웃(ARP) 테이블 명령을 읽습니다. permanent·noarp·stale·failed 같은 NUD 상태, show 가 none·noarp 를 빼는 점, flush 가 인자 없이는 거부되고 permanent·noarp 를 남기는 점, add·replace·delete·get 을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 435);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 1, 'permanent', 'NUD 상태 `permanent` 는 무엇을 뜻할까요?', '관리자가 지울 때까지예요.', NULL, NULL, '[]', 'choice', '["도달성 시간이 지나면 저절로 만료된다", "유효하지만 의심스러운 상태다", "영구히 유효하고 관리자만 제거한다", "확인이 지연되고 있는 상태다"]', 2, 'ip-neighbour 문서는 permanent 를 영구히 유효하며 관리적으로만 제거되는 상태라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 2, 'noarp', 'NUD 상태 `noarp` 는 무엇을 뜻할까요?', '검증을 시도하지 않아요.', NULL, NULL, '[]', 'choice', '["영구히 유효하고 관리자만 제거할 수 있다", "유효하며 검증하지 않고 수명이 끝나면 제거될 수 있다", "최대 탐색 횟수를 넘겨 검증에 실패한 상태다", "아직 링크 주소가 해석되지 않은 상태다"]', 1, '문서는 noarp 를 유효하지만 검증을 시도하지 않고 수명이 만료되면 제거될 수 있는 상태라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 3, 'show 기본', '`ip neigh show` 를 `nud` 없이 실행하면 **어떤 상태가 제외** 될까요?', '둘이 빠져요.', NULL, NULL, '[]', 'choice', '["none 과 noarp", "stale 과 failed", "permanent 와 noarp", "incomplete 와 delay"]', 0, '문서는 nud 를 주지 않으면 none 과 noarp 를 제외한 모든 상태를 보여 준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 4, 'flush 인자', '`ip neigh flush` 를 인자 없이 실행하면 어떻게 될까요?', '안전장치가 있어요.', NULL, NULL, '[]', 'choice', '["모든 상태의 항목을 지운다", "permanent 만 지운다", "현재 인터페이스의 항목만 지운다", "실행을 거부한다"]', 3, '문서는 flush 가 show 와 같은 인자를 받지만 인자 없이는 실행을 거부한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 5, 'flush 기본 상태', '`ip neigh flush` 가 **기본으로 지우지 않는** 상태는 무엇일까요?', '영구 항목과 검증 없는 항목이에요.', NULL, NULL, '[]', 'choice', '["stale 과 failed", "reachable 과 delay", "permanent 와 noarp", "incomplete 와 probe"]', 2, '문서는 flush 의 기본 대상에서 permanent 와 noarp 상태가 제외된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 6, 'failed 상태', 'NUD 상태 `failed` 는 무엇을 뜻할까요?', '탐색을 다 썼어요.', NULL, NULL, '[]', 'choice', '["도달성 시간이 지나 의심스럽다", "최대 탐색 횟수를 넘겨 검증에 실패했다", "아직 해석을 시도하지 않았다", "지연 후 탐색을 시작했다"]', 1, '문서는 failed 를 최대 탐색 횟수를 초과해 검증에 실패한 상태라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 7, 'stale 상태', 'NUD 상태 `stale` 은 무엇을 뜻할까요?', '유효하지만 의심스러워요.', NULL, NULL, '[]', 'choice', '["유효하지만 의심스럽다", "영구히 유효하다", "검증에 실패했다", "확인이 진행 중이다"]', 0, '문서는 stale 을 유효하지만 의심스러운 상태라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 8, 'delete 인자', '`ip neigh delete` 는 `add` 와 같은 인자를 받는데, **무시되는 인자** 는 무엇일까요?', '주소와 상태 쪽이에요.', NULL, NULL, '[]', 'choice', '["dev 와 to", "proxy 와 router", "nomaster 와 vrf", "lladdr 와 nud"]', 3, '문서는 delete 가 add 와 같은 인자를 받되 lladdr 와 nud 는 무시한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 9, 'replace 동작', '`ip neigh replace` 는 무엇을 할까요?', '둘 중 하나예요.', NULL, NULL, '[]', 'choice', '["기존 항목이 없으면 오류를 낸다", "모든 항목을 새로 고친다", "항목을 새로 만들거나 기존 항목을 바꾼다", "항목을 지우고 다시 학습한다"]', 2, '문서는 replace 가 새 항목을 추가하거나 기존 항목을 바꾼다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 10, '항목 추가', '이웃 항목을 **새로 추가** 하는 하위 명령입니다. 빈칸을 채우세요.', '"더하다" 예요.', NULL, NULL, '[]', 'fill', '["add", "get", "flush", "show"]', NULL, 'add 는 새 이웃 항목을 추가하며 lladdr 와 nud 로 링크 주소와 상태를 지정합니다.', '[0]', 'ip neigh {0} 192.0.2.1 lladdr 00:11:22:33:44:55 dev eth0 nud permanent', NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 11, '주소로 조회', '특정 목적지의 이웃 항목을 **조회** 하는 하위 명령입니다. 빈칸을 채우세요.', '"얻다" 예요.', NULL, NULL, '[]', 'fill', '["get", "add", "flush", "replace"]', NULL, 'get 은 지정한 장치에서 목적지의 이웃 항목을 조회합니다.', '[0]', 'ip neigh {0} 192.0.2.1 dev eth0', NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 435, 12, '고정 항목 관리', '이웃 항목을 고정으로 넣고 확인한 뒤 지우는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '추가 → 목록 → 조회 → 삭제예요.', NULL, NULL, '[]', 'order', '["`ip neigh add` 로 `nud permanent` 항목을 넣는다", "`ip neigh show` 로 목록에서 확인한다", "`ip neigh get` 으로 특정 주소를 조회한다", "`ip neigh delete` 로 항목을 제거한다"]', NULL, '문서의 add·show·get·delete 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "ip-neighbour(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-neighbour.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 435 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 640 WHERE id = 117;
UPDATE quest_set SET display_order = 636, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '👥' WHERE id = 435;
