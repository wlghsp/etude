-- 퀴즈 세트 409. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round4.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 409, '정책 라우팅: ip rule, 기본 규칙 3개, 선택자와 동작', '출발지 등으로 경로를 달리 정하는 정책 라우팅을 읽습니다. 기본 규칙 3개(local·main·default)와 priority 순서, from·to·fwmark·iif·oif 선택자, blackhole·unreachable·prohibit 동작을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 409);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 1, '정책 라우팅', '전통 라우팅과 비교한 **정책 라우팅** 의 특징은 무엇일까요?', '목적지 말고도 보아요.', NULL, NULL, '[]', 'choice', '["목적지 주소만 보고 경로를 정한다", "경로를 한 번 정하면 영구히 고정한다", "출발지·프로토콜·포트도 보고 경로를 정한다", "라우팅 테이블을 하나만 쓰도록 강제한다"]', 2, 'ip-rule 문서는 정책 라우팅이 목적지 외에 출발지 주소·IP 프로토콜·포트 등도 보고 경로를 정하며, 목적지 기반 테이블을 규칙을 차례로 실행하는 RPDB 로 대체한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 2, '규칙 처리 순서', '`ip rule` 규칙은 어떤 순서로 처리될까요?', '숫자가 작을수록 먼저예요.', NULL, NULL, '[]', 'choice', '["priority 값이 높은 것부터 낮은 순으로", "priority 값이 낮은 것부터 높은 순으로", "추가된 순서의 반대 방향으로", "선택자가 가장 긴 규칙부터"]', 1, '문서는 규칙을 priority 가 낮은 것부터 높은 순으로 처리하며 숫자가 작을수록 우선순위가 높다고 설명합니다. 선택자가 맞고 동작이 성공하면 조회가 끝납니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 3, 'priority 0 규칙', '커널 기본 규칙 중 **priority 0** 은 무엇을 조회할까요?', '로컬·브로드캐스트 주소용이에요.', NULL, NULL, '[]', 'choice', '["local 테이블(ID 255)", "main 테이블(ID 254)", "default 테이블(ID 253)", "table 100"]', 0, '문서의 기본 규칙에서 priority 0 은 모든 패킷에 대해 local 테이블(255)을 조회하며 로컬·브로드캐스트 주소용 제어 경로가 들어 있습니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 4, 'priority 32766 규칙', '커널 기본 규칙 중 **priority 32766** 은 무엇을 조회할까요?', '일반 경로가 담긴 기본 테이블이에요.', NULL, NULL, '[]', 'choice', '["local 테이블(ID 255)", "default 테이블(ID 253)", "unspec 테이블(ID 0)", "main 테이블(ID 254)"]', 3, '문서의 기본 규칙에서 priority 32766 은 main 테이블(254)을 조회하며 관리자가 삭제하거나 다른 규칙으로 덮어쓸 수 있습니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 5, 'priority 32767 규칙', '커널 기본 규칙 중 **priority 32767** 의 default 테이블(ID 253)은 어떤 상태일까요?', '비어 있어요.', NULL, NULL, '[]', 'choice', '["모든 일반 경로가 들어 있는 주 테이블이다", "로컬 주소의 제어 경로가 들어 있는 테이블이다", "비어 있고 앞선 규칙이 못 다룬 패킷용이다", "관리자가 만든 경로만 들어 있는 테이블이다"]', 2, '문서는 default 테이블이 비어 있으며 앞선 규칙이 패킷을 처리하지 못했을 때의 후처리용이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 6, 'fwmark 선택자', '`ip rule` 의 **fwmark** 선택자는 무엇을 맞춰 볼까요?', '패킷에 붙은 표식이에요.', NULL, NULL, '[]', 'choice', '["패킷의 출발지 포트 번호", "패킷의 fwmark 값", "패킷의 TTL 값 전체", "들어온 인터페이스의 이름"]', 1, '문서는 fwmark 선택자가 fwmark 값을 매칭하며 마스크를 줄 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 7, 'iif lo', '`iif lo` 선택자는 어떤 패킷에 맞을까요?', '루프백이 들어온 인터페이스예요.', NULL, NULL, '[]', 'choice', '["로컬에서 발생한 패킷에만 맞는다", "외부에서 들어온 패킷에만 맞는다", "모든 패킷에 맞는다", "브로드캐스트 패킷에만 맞는다"]', 0, '문서는 iif 가 들어오는 인터페이스를 맞추며, 루프백(lo)이면 로컬에서 발생한 패킷만 매칭된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 8, 'oif 선택자', '`oif` 선택자는 어떤 패킷에 적용될까요?', '소켓이 장치에 묶여 있어야 해요.', NULL, NULL, '[]', 'choice', '["모든 포워딩 패킷에 적용된다", "들어오는 모든 패킷에만 적용된다", "IPv6 패킷에만 적용된다", "장치에 바인딩된 로컬 소켓의 패킷에만 적용"]', 3, '문서는 oif 가 나가는 인터페이스를 맞추며 장치에 바인딩된 로컬 소켓의 패킷에만 적용된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 9, 'prohibit 규칙', '`ip rule` 의 **prohibit** 동작은 무엇일까요?', '관리상 금지예요.', NULL, NULL, '[]', 'choice', '["\\"네트워크에 도달할 수 없음\\" 오류를 낸다", "패킷을 조용히 버린다", "\\"관리상 통신 금지\\" 오류를 낸다", "출발지 주소를 다른 주소로 바꾼다"]', 2, '문서는 prohibit 이 관리상 통신 금지 오류를, unreachable 이 네트워크 도달 불가 오류를, blackhole 이 조용한 폐기를 낸다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 10, '규칙 우선순위 지정', '규칙의 **우선순위 값** 을 지정하는 키워드입니다. 빈칸을 채우세요.', '"우선" 이에요.', NULL, NULL, '[]', 'fill', '["priority", "fwmark", "iif", "metric"]', NULL, 'priority 로 규칙의 우선순위를 정하며 숫자가 작을수록 먼저 처리됩니다.', '[0]', 'ip rule add from 192.168.1.0/24 table 100 {0} 1000', NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 11, '목적지 선택자', '**목적지 prefix** 를 맞추는 선택자입니다. 빈칸을 채우세요.', '"~로" 라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["to", "from", "iif", "oif"]', NULL, 'to 는 목적지 prefix 를, from 은 출발지 prefix 를 맞춥니다.', '[0]', 'ip rule add {0} 10.0.0.0/8 table 200', NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 409, 12, '출발지별로 다른 경로', '출발지 주소에 따라 다른 테이블을 쓰게 하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '테이블 → 규칙 → 확인이에요.', NULL, NULL, '[]', 'order', '["별도 테이블(예: 100)에 경로를 넣는다", "`ip rule add from ... table 100` 으로 출발지 규칙을 추가한다", "`ip rule show` 로 규칙과 우선순위를 확인한다"]', NULL, '문서의 table·from 선택자 설명을 이은 일반 절차입니다.', '[0, 1, 2]', NULL, NULL, '[{"title": "ip-rule(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-rule.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 409 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 636 WHERE id = 117;
UPDATE quest_set SET display_order = 632, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🚦' WHERE id = 409;
