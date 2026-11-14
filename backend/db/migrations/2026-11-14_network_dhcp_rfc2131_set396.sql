-- 퀴즈 세트 396. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 396, 'DHCP 동작: 메시지 흐름, 포트, 임대 갱신(T1·T2), 릴레이, 주소 충돌', '주소를 나눠 주는 DHCP 를 익힙니다. DISCOVER→OFFER→REQUEST→ACK 흐름, 서버 67·클라이언트 68 포트, BROADCAST 비트, 릴레이의 giaddr, ARP 확인과 DECLINE, NAK, 임대 갱신 T1·T2 기본값, RELEASE·INFORM 을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 396);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 1, 'DHCP 포트', 'DHCP 에서 **서버와 클라이언트** 가 쓰는 UDP 포트는 각각 무엇일까요?', '서버 67, 클라이언트 68 이에요.', NULL, NULL, '[]', 'choice', '["서버 68번, 클라이언트 67번", "서버 53번, 클라이언트 67번", "서버 67번, 클라이언트 68번", "서버 80번, 클라이언트 68번"]', 2, 'RFC 2131 은 클라이언트에서 서버로 가는 메시지를 DHCP 서버 포트(67)로, 서버에서 클라이언트로 가는 메시지를 DHCP 클라이언트 포트(68)로 보낸다고 설명합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 2, 'DHCPDISCOVER', '**DHCPDISCOVER** 는 어떤 메시지일까요?', '서버를 찾는 첫 메시지예요.', NULL, NULL, '[]', 'choice', '["서버가 클라이언트에게 주소를 제안하는 메시지", "사용 가능한 서버를 찾으려고 클라이언트가 브로드캐스트하는 메시지", "클라이언트가 받은 주소를 쓰겠다고 확정하는 메시지", "서버가 주소 사용을 거절하는 메시지"]', 1, 'RFC 2131 의 메시지 표는 DHCPDISCOVER 를 사용 가능한 서버를 찾기 위한 클라이언트 브로드캐스트로 설명합니다. 클라이언트는 하드웨어 브로드캐스트 주소와 0xffffffff IP 브로드캐스트 주소로 보냅니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 3, 'BROADCAST 비트', '클라이언트가 **설정이 끝나기 전에 유니캐스트 IP 를 받을 수 없다** 면 flags 의 BROADCAST 비트를 어떻게 해야 할까요?', '서버가 브로드캐스트로 응답해야 해요.', NULL, NULL, '[]', 'choice', '["1 로 설정한다", "0 으로 설정한다", "비워 둔다 (필드가 없다)", "서버 주소로 바꾼다"]', 0, 'RFC 2131 은 설정 전에 유니캐스트 IP 를 받을 수 없는 클라이언트가 flags 의 BROADCAST 비트를 1 로 설정해야 한다(SHOULD)고 설명합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 4, '릴레이 에이전트', '릴레이 에이전트를 거친 요청에서 **giaddr 가 0 이 아니면** 서버는 응답을 어디로 보낼까요?', '릴레이 주소가 giaddr 에 있어요.', NULL, NULL, '[]', 'choice', '["클라이언트의 하드웨어 주소로 곧바로 직접", "네트워크 전체에 무조건 브로드캐스트", "서버 쪽의 DHCP 클라이언트 포트(68)", "giaddr 릴레이 에이전트의 서버 포트"]', 3, 'RFC 2131 은 giaddr 가 0 이 아니면 서버가 giaddr 에 있는 BOOTP 릴레이 에이전트의 DHCP 서버 포트로 메시지를 돌려보낸다고 설명합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 5, 'ARP 로 주소 확인', '클라이언트는 받은 주소를 쓰기 전에 **ARP 로 확인** 할 수 있는데, 이미 쓰이고 있음을 발견하면 어떻게 할까요?', '서버에 알리고 처음부터 다시 해요.', NULL, NULL, '[]', 'choice', '["DHCPRELEASE 를 보내고 그 주소를 계속 쓴다", "DHCPNAK 로 서버를 막고 종료한다", "DHCPDECLINE 을 보내고 설정 과정을 다시 시작한다", "그 주소를 그대로 쓰고 충돌을 무시한다"]', 2, 'RFC 2131 은 클라이언트가 제안된 주소가 이미 쓰이고 있음(예: ARP)을 발견하면 DHCPDECLINE 을 보내고 설정을 다시 시작해야 한다고 설명합니다. 서버는 그 주소를 사용 불가로 표시합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 6, 'T1 기본값', '임대 갱신 타이머 **T1** 의 기본값은 임대 기간의 얼마일까요?', '절반이에요.', NULL, NULL, '[]', 'choice', '["임대 기간의 0.875 배", "임대 기간의 0.5 배", "임대 기간의 0.25 배", "임대 기간과 같다"]', 1, 'RFC 2131 4.4.5 는 T1 이 기본으로 (0.5 × 임대 기간)이라고 설명합니다. T1 이 만료되면 클라이언트는 임대를 준 서버에 DHCPREQUEST 를 보내 갱신(RENEWING)합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 7, 'T2 기본값', '임대 재결합 타이머 **T2** 의 기본값은 임대 기간의 얼마일까요?', '7/8 이에요.', NULL, NULL, '[]', 'choice', '["임대 기간의 0.875 배", "임대 기간의 0.5 배", "임대 기간의 0.75 배", "임대 기간의 0.95 배"]', 0, 'RFC 2131 4.4.5 는 T2 가 기본으로 (0.875 × 임대 기간)이라고 설명합니다. T2 가 만료되면 클라이언트는 브로드캐스트 DHCPREQUEST 를 보내 재결합(REBINDING)합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 8, 'DHCPRELEASE', '**DHCPRELEASE** 를 받은 서버는 무엇을 할까요?', '주소를 돌려받아요.', NULL, NULL, '[]', 'choice', '["그 주소를 사용 불가로 표시하고 다시 쓰지 않는다", "클라이언트에게 새 주소를 즉시 제안한다", "임대 시간을 두 배로 늘린다", "그 네트워크 주소를 할당되지 않은 것으로 표시한다"]', 3, 'RFC 2131 은 DHCPRELEASE 를 받은 서버가 해당 주소를 할당되지 않은 것으로 표시하며, 클라이언트는 할당된 주소가 더 필요 없을 때 보낸다고 설명합니다. 주소를 사용 불가로 표시하는 것은 DHCPDECLINE 입니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 9, 'DHCPINFORM', '**DHCPINFORM** 은 언제 쓰일까요?', '주소는 이미 있어요.', NULL, NULL, '[]', 'choice', '["주소를 처음 요청하는 단계에서 쓴다", "주소 임대를 연장하는 단계에서 쓴다", "주소는 있고 설정 값만 얻을 때", "주소를 서버에 반납하는 단계에서 쓴다"]', 2, 'RFC 2131 은 클라이언트가 이미 외부에서 할당받은 주소가 있을 때 DHCPINFORM 으로 설정 파라미터를 얻으며, 서버는 그 주소로 직접 DHCPACK 을 보낸다고 설명합니다.', NULL, NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 10, '주소 사용 중 알림', '클라이언트가 제안된 주소가 **이미 쓰이고 있다** 고 서버에 알리는 메시지입니다. 빈칸을 채우세요.', '"DHCP" 다음에 와요.', NULL, NULL, '[]', 'fill', '["DECLINE", "RELEASE", "INFORM", "DISCOVER"]', NULL, 'DHCPDECLINE 은 클라이언트가 제안된 주소가 이미 쓰이고 있음을 알릴 때 보내며, 서버는 그 주소를 사용 불가로 표시합니다. DHCPRELEASE 는 더 쓰지 않는 주소를 반납합니다.', '[0]', 'DHCP{0}', NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 11, '잘못된 요청 거절', '클라이언트가 요청한 IP 주소가 올바르지 않을 때 **서버가 보내는** 메시지입니다. 빈칸을 채우세요.', '긍정 응답(ACK)의 반대예요.', NULL, NULL, '[]', 'fill', '["NAK", "OFFER", "DECLINE", "INFORM"]', NULL, 'RFC 2131 4.3.2 는 요청한 IP 주소가 올바르지 않으면 서버가 DHCPNAK 을 보내야 한다고 설명하며, NAK 를 받은 클라이언트는 네트워크 설정을 다시 시작합니다.', '[0]', 'DHCP{0}', NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 396, 12, '주소를 받는 기본 순서', '처음 네트워크에 붙은 클라이언트가 주소를 받는 순서입니다. 순서에 맞게 놓아 보세요.', 'D → O → R → A 예요.', NULL, NULL, '[]', 'order', '["클라이언트가 DHCPDISCOVER 를 브로드캐스트한다", "서버가 DHCPOFFER 로 주소를 제안한다", "클라이언트가 DHCPREQUEST 로 제안을 선택한다", "서버가 DHCPACK 으로 주소 사용을 확정한다"]', NULL, 'RFC 2131 의 기본 흐름은 DISCOVER → OFFER → REQUEST → ACK 입니다. 클라이언트가 ARP 로 주소 충돌을 발견하면 DECLINE 을 보내고 처음부터 다시 합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "RFC 2131 DHCP", "url": "https://www.rfc-editor.org/rfc/rfc2131"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 396 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 631 WHERE id = 117;
UPDATE quest_set SET display_order = 627, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '📬' WHERE id = 396;
