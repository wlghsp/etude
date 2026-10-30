-- 입문 세트 106. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_friendly_audit.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 106, '이름으로 통신 입문: 이름표, 전화번호부, 포트', '이름으로 통신하기(36) 전에 가볍게 보는 입문입니다. 왜 이름이 필요한지, /etc/hosts 와 DNS 의 차이, 이름을 찾는 순서, 포트 번호, Name or service not known 과 Connection refused 의 차이, 접속 장애를 좁히는 순서를 쉬운 문제로 익힙니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 106);
UPDATE quest_set SET display_order = 110, unit_id = (SELECT id FROM unit WHERE id = 3), icon = '📒' WHERE id = 106;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 1, '왜 이름이 필요할까?', '컴퓨터끼리는 숫자 주소(IP)로 통신하지만 사람은 `web1` 같은 이름이 편합니다. 그러려면 무엇이 필요할까요?', '이름표를 숫자 주소로 바꿔 주는 안내표가 있어야 해요.', NULL, NULL, '[]', 'choice', '["더 빠른 인터넷", "이름을 IP 주소로 바꿔 주는 곳 (hosts 파일이나 DNS)", "더 큰 모니터", "서버를 껐다 켜기"]', 1, '맞아요! 이름 → IP 로 바꿔 주는 안내표가 있어야 이름으로 접속할 수 있어요. 대표적인 곳이 `/etc/hosts` 와 DNS 서버예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 2, '/etc/hosts 는 무엇일까?', '`/etc/hosts` 파일을 가장 알맞게 설명한 것은 무엇일까요?', '내 컴퓨터 안에 있는 작은 전화번호부를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["인터넷 전체의 주소록", "비밀번호가 저장된 파일", "프로그램 설치 목록", "이름과 IP 를 짝지어 적어 둔, 내 컴퓨터 안의 작은 전화번호부"]', 3, '잘했어요! 한 줄에 `IP 이름` 을 적어 두면 그 이름이 곧바로 그 IP 로 바뀌어요. 내 컴퓨터에서만 통하는 개인 전화번호부예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 3, 'hosts 한 줄 쓰는 법', '`web1` 이라는 이름을 IP `10.0.0.10` 에 연결하는 `/etc/hosts` 한 줄입니다. 빈칸을 채워 보세요. (형식: IP 다음에 이름)', 'IP 가 먼저, 이름이 나중입니다.', NULL, NULL, '[]', 'fill', '["10.0.0.10", "web1", "web1.example.com", "80"]', NULL, '`IP 이름` 순서예요. 한 줄에 이름을 여러 개 적으면 별칭도 가능합니다(`10.0.0.10 web1 web`).', '[0, 1]', '{0} {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 4, 'DNS 서버 주소가 적힌 파일', '내 컴퓨터가 질문을 보낼 **DNS 서버 주소**가 적힌 파일은 `/etc/___` 입니다.', 'resolve(해석)라는 단어에서 온 이름이에요.', NULL, NULL, '[]', 'fill', '["resolv.conf", "hosts", "passwd", "fstab"]', NULL, '`/etc/resolv.conf` 의 `nameserver` 줄에 DNS 서버 주소가 있어요. hosts 에 없는 이름은 여기 적힌 서버에 물어봅니다.', '[0]', '/etc/{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 5, '이름을 IP 로 찾는 순서', '`web1` 이라는 이름으로 접속할 때 시스템이 IP 를 찾는 흐름을 **앞에서 뒤**로 놓아 보세요.', '내 전화번호부를 먼저 보고, 없으면 큰 전화번호부(DNS)에 물어요.', NULL, NULL, '[]', 'order', '["받은 IP 로 접속한다", "`/etc/hosts` 에 `web1` 이 있는지 먼저 본다", "없으면 DNS 서버에게 `web1` 의 IP 를 묻는다"]', NULL, '**hosts 먼저 → 없으면 DNS 질의 → 얻은 IP 로 접속** 입니다. 그래서 hosts 에 적어 두면 DNS 보다 우선해요.', '[1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 6, '포트는 무엇일까?', '같은 IP 의 서버가 웹(80), SSH(22)를 동시에 제공할 수 있는 이유는 무엇일까요?', '건물 주소(IP) 아래 호수(포트)가 있다고 생각해 보세요.', NULL, NULL, '[]', 'choice', '["서비스마다 다른 컴퓨터라서", "이름이 달라서", "서비스마다 **포트 번호**가 달라서 구분된다", "시간이 달라서"]', 2, '그렇죠! IP 가 건물 주소라면 포트는 호수예요. 같은 건물(IP)에서 80호는 웹, 22호는 SSH 처럼 구분합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 7, '자주 보는 포트 번호', 'SSH 의 기본 포트는 ___, 웹(HTTP)의 기본 포트는 ___ 입니다.', '다음 문제에서 계속 나오는 번호예요. 외워 두면 편해요.', NULL, NULL, '[]', 'fill', '["22", "80", "443", "3306"]', NULL, 'SSH 는 22, HTTP 는 80, HTTPS 는 443, MariaDB(MySQL)는 3306 이 기본이에요. 외워 두면 장애 때 "어느 서비스가 안 되나"를 빨리 가려낼 수 있어요.', '[0, 1]', 'SSH: {0} / HTTP: {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 8, '"Name or service not known"', '접속하려는데 `Name or service not known` 오류가 나옵니다. 어느 단계에서 막힌 걸까요?', '이름이 숫자로 바뀌기 전 단계예요.', NULL, NULL, '[]', 'choice', '["IP 에는 갔지만 포트가 닫혀 있다", "비밀번호가 틀렸다", "디스크가 가득 찼다", "이름을 IP 로 바꾸지 못했다 (hosts 에도 DNS 에도 없음)"]', 3, '좋아요! 이름 → IP 변환이 실패한 거예요. hosts 에 줄을 추가하거나 DNS 설정을 확인하면 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 9, '"Connection refused"', '`Connection refused` 오류는 이름 해석과 관련해 무엇을 알려 줄까요?', '주소는 찾았는데 문을 두드렸더니 거절당한 상황입니다.', NULL, NULL, '[]', 'choice', '["이름을 못 찾았다", "이름은 IP 로 바뀌어 IP 에는 도달했지만, 그 포트에서 듣는 서비스가 없다", "인터넷이 끊겼다", "컴퓨터가 꺼져 있다"]', 1, '맞아요! 이름 해석은 성공했어요. 이제 그 서버에서 서비스가 떠 있는지, 포트가 맞는지를 보면 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 106, 10, '접속이 안 될 때 좁혀 가는 순서', '이름으로 서버에 접속이 안 됩니다. **바깥에서 안쪽으로** 확인하는 순서를 놓아 보세요.', '이름 → IP 도달 → 포트 → 서비스 순서예요.', NULL, NULL, '[]', 'order', '["`nc -zv 서버 포트` 로 그 포트가 열려 있는지 본다", "`getent hosts 이름` 으로 이름이 IP 로 바뀌는지 본다", "서버의 서비스 로그를 확인한다", "`ping IP` 로 그 IP 에 닿는지 본다"]', NULL, '**이름 해석 → IP 도달 → 포트 → 서비스 로그** 순서예요. 한 단계씩 통과하면 막힌 지점이 어디인지 정확히 알 수 있어요.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 106 AND order_index = 10);
