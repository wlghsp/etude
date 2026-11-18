-- 퀴즈 세트 467. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round9.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 467, 'udp(7) UDP 소켓: 비연결형, 자동 포트, MSG_TRUNC, 경로 MTU, 오류 전달, 오프로드 옵션', '리눅스 UDP 구현을 읽습니다. 순서 바뀜·중복 가능한 데이터그램, ip_local_port_range 자동 배정, 수신 한 번에 패킷 하나와 MSG_TRUNC, connect 의 기본 목적지, MSG_DONTROUTE, 경로 MTU 와 EMSGSIZE, 오류 전달, udp_mem, UDP_CORK·SEGMENT·GRO 를 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 467);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 1, 'UDP 성격', 'udp(7) 문서가 설명하는 리눅스 UDP 의 성격으로 맞는 것은 무엇일까요?', 'RFC 768 이에요.', NULL, NULL, '[]', 'choice', '["연결형이며 순서를 항상 보장해 준다", "비연결형이지만 재전송을 보장해 준다", "비연결형이며 순서 바뀜·중복이 가능하다", "체크섬 없이 가볍고 빠르게 보낸다"]', 2, '문서는 UDP 가 비연결형의 신뢰할 수 없는 데이터그램 서비스이고, 패킷이 순서가 바뀌거나 중복될 수 있으며 체크섬을 만들고 검사한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 2, '자동 포트', 'bind 하지 않은 UDP 소켓으로 데이터를 보내면 로컬 포트는 어떻게 정해질까요?', '/proc 파일이 있어요.', NULL, NULL, '[]', 'choice', '["항상 포트 0 번으로 내보내게 된다", "ip_local_port_range 의 빈 포트다", "목적지 포트와 같은 번호가 배정된다", "데이터를 보낼 수 없고 오류가 난다"]', 1, '문서는 bind 하지 않으면 소켓 계층이 /proc/sys/net/ipv4/ip_local_port_range 의 범위에서 빈 포트를 배정하고 INADDR_ANY 에 묶는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 3, '수신 단위', 'UDP 소켓의 수신 호출 한 번은 무엇을 돌려줄까요?', '한 번에 한 패킷이에요.', NULL, NULL, '[]', 'choice', '["패킷 하나를 주고, 버퍼보다 크면 잘리며 MSG_TRUNC 가 켜진다", "버퍼가 찰 때까지 여러 패킷을 이어 붙여 돌려준다", "패킷이 클 때는 나머지를 다음 호출에서 이어서 돌려준다", "MSG_WAITALL 을 주면 버퍼가 찰 때까지 기다린다"]', 0, '문서는 모든 수신 동작이 패킷 하나만 반환하고, 패킷이 버퍼보다 크면 잘리며 MSG_TRUNC 가 설정된다고 설명합니다. MSG_WAITALL 은 지원하지 않습니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 4, 'connect', 'UDP 소켓에 `connect(2)` 를 부르면 무엇이 달라질까요?', 'TCP 의 연결 수립과는 달라요.', NULL, NULL, '[]', 'choice', '["목적지와 3-way 핸드셰이크로 연결이 수립된다", "다른 목적지로는 더 이상 보낼 수 없게 된다", "수신 패킷의 순서가 보장되게 된다", "기본 목적지가 정해져 주소 없이 보낼 수 있다"]', 3, '문서는 connect(2) 가 기본 목적지 주소를 정해 send(2)·write(2) 로 주소 없이 보낼 수 있게 하며, sendto·sendmsg 에 주소를 주면 다른 목적지로도 보낼 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 5, 'MSG_DONTROUTE', '송신에 `MSG_DONTROUTE` 를 주면 목적지 주소에 어떤 제약이 생길까요?', '라우팅을 건너뛰어요.', NULL, NULL, '[]', 'choice', '["반드시 브로드캐스트 주소여야 한다", "반드시 기본 게이트웨이 주소여야 한다", "로컬 인터페이스 주소여야 한다", "제약 없이 모든 주소로 직접 나간다"]', 2, '문서는 MSG_DONTROUTE 를 주면 목적지 주소가 로컬 인터페이스 주소여야 하며 패킷이 그 인터페이스로만 보내진다고 설명합니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 6, '경로 MTU', '리눅스 UDP 의 기본 경로 MTU 탐색 동작으로 맞는 것은 무엇일까요?', 'EMSGSIZE 가 나와요.', NULL, NULL, '[]', 'choice', '["MTU 를 넘으면 항상 커널이 알아서 단편화한다", "MTU 를 추적하다 넘으면 EMSGSIZE 를 준다", "경로 MTU 를 전혀 추적하지 않는다", "MTU 를 넘으면 패킷을 조용히 버린다"]', 1, '문서는 기본적으로 목적지 IP 별 MTU 를 추적하며 쓰기가 MTU 를 넘으면 EMSGSIZE 를 돌려준다고 설명합니다. 탐색을 끄면 인터페이스 MTU 를 넘는 패킷을 단편화하지만 권장하지 않습니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 7, '오류 전달', 'UDP 소켓의 비동기 오류 전달에 대한 설명으로 맞는 것은 무엇일까요?', 'RFC 1122 가 정한 동작이에요.', NULL, NULL, '[]', 'choice', '["연결하지 않은 소켓에도 치명적 오류가 오류 반환으로 전달된다", "연결(connect)한 소켓에만 오류가 전달된다", "오류는 항상 조용히 무시된다", "IP_RECVERR 가 있어야 오류가 처음 전달된다"]', 0, '문서는 치명적 오류가 소켓이 연결되지 않았어도 사용자에게 오류 반환으로 전달되며 이는 RFC 1122 가 요구한 동작이라고 설명합니다. 이전 패킷의 오류가 나중 호출에 보일 수 있습니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 8, 'udp_mem', '`/proc/sys/net/ipv4/udp_mem` 은 어떤 값일까요?', '정수 세 개예요.', NULL, NULL, '[]', 'choice', '["포트 범위의 시작과 끝을 담은 두 값이다", "소켓 하나가 쓸 바이트 수를 담은 값이다", "재전송 횟수와 간격을 담은 값이다", "min·pressure·max 세 정수다"]', 3, '문서는 udp_mem 이 모든 UDP 소켓의 큐잉 허용 페이지 수를 정하는 세 정수(min·pressure·max)이고 기본값은 부팅 때 가용 메모리로 계산된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 9, 'UDP_SEGMENT', '`UDP_SEGMENT` 옵션에 대한 설명으로 맞는 것은 무엇일까요?', '4.18 부터예요.', NULL, NULL, '[]', 'choice', '["수신한 여러 데이터그램을 하나로 합쳐 주는 옵션이다", "출력을 모아 한 데이터그램으로 보내는 옵션이다", "큰 패킷을 늦게 나눠 보내는 오프로드이며 0 이면 꺼진다", "체크섬 계산을 건너뛰게 하는 옵션이다"]', 2, '문서는 UDP_SEGMENT(Linux 4.18~) 가 여러 데이터그램 분량을 하나의 큰 패킷으로 커널 송신 경로에 넘기고 가능한 늦게 분할하며, 0 이면 비활성이라고 설명합니다. 수신쪽은 UDP_GRO 입니다.', NULL, NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 10, 'UDP_CORK', '출력 데이터를 **하나의 데이터그램으로 모았다가** 옵션을 끌 때 보내는 UDP 옵션입니다. 빈칸을 채우세요.', 'TCP 에도 비슷한 이름이 있어요.', NULL, NULL, '[]', 'fill', '["CORK", "SEGMENT", "GRO", "NODELAY"]', NULL, '문서는 UDP_CORK 를 켜면 소켓의 모든 출력이 하나의 데이터그램으로 모이고 옵션을 끌 때 전송된다고 설명합니다.', '[0]', 'UDP_{0}', NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 11, 'FIONREAD', '다음 대기 데이터그램의 **크기(바이트)** 를 돌려주는 ioctl 입니다. 빈칸을 채우세요.', 'READ 가 들어 있어요.', NULL, NULL, '[]', 'fill', '["FIONREAD", "TIOCOUTQ", "SIOCGSTAMP", "FIONBIO"]', NULL, '문서는 FIONREAD(SIOCINQ) 가 다음 대기 데이터그램 크기를 바이트로 돌려주며 없으면 0 이지만, 길이 0 데이터그램과 구분할 수 없어 select·poll·epoll 이 더 안전하다고 설명합니다.', '[0]', 'ioctl(udp_socket, {0}, &value)', NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 467, 12, 'UDP 수신 준비', 'UDP 로 패킷을 받아 처리하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '만들고 → 묶고 → 읽어요.', NULL, NULL, '[]', 'order', '["`socket(AF_INET, SOCK_DGRAM, 0)` 으로 소켓을 만든다", "`bind(2)` 로 로컬 주소를 정한다", "수신 호출로 패킷을 하나씩 읽는다", "버퍼보다 큰 패킷은 잘려 MSG_TRUNC 가 설정됨을 확인한다"]', NULL, '문서는 패킷을 받으려면 먼저 bind 하고, 수신 호출 한 번에 패킷 하나만 돌려주며 큰 패킷은 잘린다고 설명합니다. 일반적인 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "udp(7) man page", "url": "https://man7.org/linux/man-pages/man7/udp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 467 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 646 WHERE id = 117;
UPDATE quest_set SET display_order = 642, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '📮' WHERE id = 467;
