-- 퀴즈 세트 438. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 438, 'ip link 로 인터페이스 다루기: set 옵션(flag·master·netns), veth 쌍, show 필터', '인터페이스 명령을 읽습니다. arp·promisc·multicast 플래그, master·nomaster 종속, netns 이동, 이름 변경 주의, veth 쌍의 peer name, show 의 up·master·type 필터, 여러 변경 중 실패 시 중단되는 점을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 438);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 1, 'arp off', '`ip link set dev eth0 arp off` 는 어떤 **플래그** 를 바꿀까요?', '반대 이름이에요.', NULL, NULL, '[]', 'choice', '["MULTICAST 플래그를 끈다", "PROMISC 플래그를 켠다", "NOARP 플래그를 켠다", "UP 플래그를 끈다"]', 2, 'ip-link 문서는 arp on|off 가 장치의 NOARP 플래그를 바꾼다고 설명합니다. promisc 는 PROMISC, multicast 는 MULTICAST 플래그입니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 2, 'promisc on', '`ip link set dev eth0 promisc on` 은 무엇을 할까요?', '모든 패킷을 받아요.', NULL, NULL, '[]', 'choice', '["인터페이스를 UP 상태로 바꾼다", "프로미스큐어스 동작을 켠다", "멀티캐스트 수신을 끈다", "ARP 응답을 끄는 설정이다"]', 1, '문서는 promisc on|off 가 장치의 PROMISC 플래그를 바꾸며, 켜면 프로미스큐어스 동작을 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 3, 'master', '`ip link set dev eth0 master br0` 는 무엇을 할까요?', 'enslave 예요.', NULL, NULL, '[]', 'choice', '["eth0 의 마스터 장치를 br0 로 정한다", "br0 를 eth0 의 별칭으로 정한다", "eth0 의 MTU 를 br0 에서 복사한다", "eth0 를 br0 네임스페이스로 옮긴다"]', 0, '문서는 master DEVICE 가 장치의 마스터 장치를 설정(장치를 enslave)한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 4, 'nomaster', '`ip link set dev eth0 nomaster` 는 무엇을 할까요?', 'release 예요.', NULL, NULL, '[]', 'choice', '["장치를 삭제한다", "장치를 DOWN 상태로 만든다", "새 마스터를 자동으로 고른다", "마스터 장치 지정을 해제한다"]', 3, '문서는 nomaster 가 장치의 마스터 장치 지정을 해제(장치를 release)한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 5, 'netns 이동', '`ip link set ... netns PID` 는 무엇을 할까요?', '장치를 옮겨요.', NULL, NULL, '[]', 'choice', '["프로세스를 장치의 네임스페이스로 옮긴다", "장치의 복사본을 만든다", "장치를 그 네임스페이스로 옮긴다", "네임스페이스를 새로 만든다"]', 2, '문서는 netns 가 장치를 PID 에 연결된 네트워크 네임스페이스로 옮긴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 6, 'name 변경', '실행 중인 장치의 `name` 을 바꾸는 것에 대해 문서는 무엇이라 할까요?', '권장하지 않아요.', NULL, NULL, '[]', 'choice', '["항상 안전하다", "권장하지 않는다", "장치를 DOWN 으로 만들어야만 한다", "허용되지 않는다"]', 1, '문서는 name NEWNAME 이 장치 이름을 바꾸며, 장치가 실행 중일 때는 권장하지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 7, 'show up', '`ip link show up` 은 무엇을 보여 줄까요?', '동작 중인 것만이에요.', NULL, NULL, '[]', 'choice', '["동작 중인 인터페이스만", "꺼진 인터페이스만", "마스터가 있는 인터페이스만", "가상 인터페이스만"]', 0, '문서는 show 의 up 이 동작 중(running)인 인터페이스만 보여 준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 8, 'peer name', '`ip link add veth0 type veth peer name veth1` 에서 `peer name` 은 무엇일까요?', '짝 장치예요.', NULL, NULL, '[]', 'choice', '["veth0 의 별칭", "장치가 속할 브리지 이름", "장치 그룹의 이름", "짝 장치의 이름"]', 3, '문서는 peer name 이 veth(또는 vxcan) 터널의 가상 짝 장치 이름을 지정한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 9, '연속 변경', '`ip link set` 으로 **여러 변경** 을 한 번에 요청했는데 중간에 실패하면 어떻게 될까요?', '경고가 있어요.', NULL, NULL, '[]', 'choice', '["성공한 변경은 모두 되돌려진다", "실패한 항목만 건너뛰고 계속한다", "즉시 중단되어 예측 어려운 상태가 될 수 있다", "변경이 전부 취소되고 원래 상태로 남는다"]', 2, '문서는 여러 변경을 한 번에 요청했을 때 하나라도 실패하면 ip 가 즉시 중단하며 시스템이 예측하기 어려운 상태가 될 수 있다고 경고합니다.', NULL, NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 10, '마스터 지정', '장치를 브리지에 **종속시키는** 키워드입니다. 빈칸을 채우세요.', '"주인" 이에요.', NULL, NULL, '[]', 'fill', '["master", "peer", "alias", "netns"]', NULL, 'master DEVICE 는 장치의 마스터 장치를 설정(enslave)합니다.', '[0]', 'ip link set dev eth0 {0} br0', NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 11, '짝 이름', 'veth 쌍의 **반대편 이름** 을 정하는 키워드입니다. 빈칸을 채우세요.', '"짝" 이에요.', NULL, NULL, '[]', 'fill', '["peer", "master", "alias", "group"]', NULL, 'peer name 은 veth 쌍의 짝 장치 이름을 지정합니다.', '[0]', 'ip link add veth0 type veth {0} name veth1', NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 438, 12, 'veth 연결', 'veth 쌍을 만들어 한쪽을 옮기고 쓰는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '생성 → 이동 → 올림 → 확인이에요.', NULL, NULL, '[]', 'order', '["`ip link add ... type veth peer name ...` 으로 쌍을 만든다", "`ip link set ... netns` 로 한쪽을 다른 네임스페이스로 옮긴다", "`ip link set ... up` 으로 장치를 올린다", "`ip link show type veth` 로 확인한다"]', NULL, '문서의 veth peer·set netns·show type 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "ip-link(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-link.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 438 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 643 WHERE id = 117;
UPDATE quest_set SET display_order = 639, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🔗' WHERE id = 438;
