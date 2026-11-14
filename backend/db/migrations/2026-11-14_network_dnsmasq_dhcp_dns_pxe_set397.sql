-- 퀴즈 세트 397. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 397, 'dnsmasq 로 DHCP·DNS·PXE: 주소 범위, 임대, TFTP, 업스트림, 캐시', '작은 네트워크 서비스 dnsmasq 를 익힙니다. --dhcp-range 와 기본 임대 시간, --dhcp-host, PXE 를 위한 --dhcp-boot·--enable-tftp·--tftp-root·--pxe-service, router 옵션 비우기, --address·--no-resolv·캐시 크기를 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 397);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 1, '기본 임대 시간', 'dnsmasq 에서 **--dhcp-range 에 임대 시간을 주지 않으면** IPv4 기본 임대는 얼마일까요?', '한 시간이에요.', NULL, NULL, '[]', 'choice', '["12시간", "1일", "1시간", "무기한"]', 2, 'dnsmasq 매뉴얼은 임대 시간을 주지 않으면 기본이 IPv4 는 1시간, IPv6 는 1일이며 최소는 2분이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 2, '--dhcp-host', 'dnsmasq 의 **--dhcp-host** 는 무엇에 쓸까요?', '호스트별 설정이에요.', NULL, NULL, '[]', 'choice', '["DHCP 로 나눠 줄 주소 범위를 정한다", "호스트별 설정(MAC·이름·임대)을 준다", "질의를 넘길 업스트림 DNS 서버를 정한다", "TFTP 가 파일을 찾을 루트 디렉터리를 정한다"]', 1, 'dnsmasq 매뉴얼은 --dhcp-host 를 DHCP 서버의 호스트별 파라미터(하드웨어 주소, 호스트 이름, 임대 시간 등)를 지정하는 옵션으로 설명합니다. 범위는 --dhcp-range 입니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 3, '--dhcp-boot', 'dnsmasq 가 TFTP 도 제공할 때 **네트워크 부팅** 을 켜려면 --dhcp-boot 에 무엇을 주면 될까요?', 'BOOTP 파일 이름이에요.', NULL, NULL, '[]', 'choice', '["부팅 파일의 이름만 주면 된다", "TFTP 서버의 전체 URL 을 줘야 한다", "부팅할 커널과 initrd 를 모두 줘야 한다", "부팅할 호스트의 MAC 주소를 줘야 한다"]', 0, 'dnsmasq 매뉴얼은 --dhcp-boot 가 BOOTP 파일 이름을 정하며, dnsmasq 가 TFTP 서비스를 제공한다면 네트워크 부팅을 켜는 데 파일 이름만 있으면 된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 4, '--enable-tftp', '**--enable-tftp** 가 켜는 TFTP 서버의 범위는 어떨까요?', '의도적으로 제한돼요.', NULL, NULL, '[]', 'choice', '["모든 파일 전송 용도로 쓸 수 있는 범용 서버다", "쓰기만 가능하고 읽기는 안 된다", "암호화된 전송만 지원한다", "네트워크 부팅에 필요한 만큼으로 의도적으로 제한된다"]', 3, 'dnsmasq 매뉴얼은 --enable-tftp 가 TFTP 서버 기능을 켜며 의도적으로 클라이언트의 네트워크 부팅에 필요한 만큼으로 제한된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 5, '--tftp-root', '**--tftp-root** 는 무엇을 정할까요?', '파일의 기준 위치예요.', NULL, NULL, '[]', 'choice', '["TFTP 서버가 열 포트 번호", "TFTP 로 받을 수 있는 최대 파일 크기", "TFTP 로 전송할 파일을 찾는 기준 디렉터리", "부팅 메뉴에 보일 항목"]', 2, 'dnsmasq 매뉴얼은 --tftp-root 가 TFTP 로 전송할 파일을 주어진 디렉터리를 기준으로 찾게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 6, 'router 옵션 비우기', '**--dhcp-option=option:router** 처럼 값을 주지 않으면 DHCPv4 에서는 어떻게 될까요?', '값이 없으면 보내지 않아요.', NULL, NULL, '[]', 'choice', '["dnsmasq 호스트 자신을 게이트웨이로 보낸다", "라우터 옵션을 아예 보내지 않는다", "0.0.0.0 을 게이트웨이로 보낸다", "오류로 DHCP 서버가 시작되지 않는다"]', 1, 'dnsmasq 매뉴얼은 DHCPv4 에서 --dhcp-option=option:router 처럼 데이터를 주지 않으면 라우터 옵션이 전송되지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 7, '--address', 'dnsmasq 의 **--address** 는 무엇을 할까요?', '도메인에 고정 답을 줘요.', NULL, NULL, '[]', 'choice', '["도메인에 대해 정해 둔 IP 를 돌려준다", "DHCP 서버가 나눠 줄 주소를 지정해 준다", "업스트림 DNS 서버의 주소를 지정해 준다", "dnsmasq 가 듣는 인터페이스 주소를 지정한다"]', 0, 'dnsmasq 매뉴얼은 --address 를 주어진 도메인의 어떤 호스트든 정해 둔 IP 주소를 돌려주도록 하는 옵션으로 설명합니다. 업스트림 서버는 --server 입니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 8, '--no-resolv', '**--no-resolv** 는 무엇을 할까요?', 'resolv.conf 를 안 읽어요.', NULL, NULL, '[]', 'choice', '["/etc/resolv.conf 를 읽기 전용으로 잠가 둔다", "DNS 캐시를 끄고 항상 업스트림에 묻는다", "이름 풀이를 끄고 DHCP 만 동작하게 둔다", "/etc/resolv.conf 를 읽지 않는다"]', 3, 'dnsmasq 매뉴얼은 --no-resolv 가 /etc/resolv.conf 를 읽지 않고 업스트림 서버를 명령행이나 설정 파일에서만 가져오게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 9, '캐시 크기', 'dnsmasq 의 **DNS 캐시 크기 기본값** 은 얼마일까요?', '150 개예요.', NULL, NULL, '[]', 'choice', '["이름 1500개", "이름 15개", "이름 150개", "캐시를 쓰지 않는다"]', 2, 'dnsmasq 매뉴얼은 --cache-size 의 기본이 150개 이름이며 0 으로 두면 캐시가 꺼진다고 설명합니다.', NULL, NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 10, 'PXE 메뉴 옵션', 'PXE 부팅 메뉴에 나타날 **부팅 항목** 을 정의하는 dnsmasq 옵션입니다. 빈칸을 채우세요.', '"pxe" 로 시작해요.', NULL, NULL, '[]', 'fill', '["pxe-service", "dhcp-boot", "dhcp-host", "tftp-root"]', NULL, '--pxe-service 는 PXE 부팅 메뉴에 나타날 부팅 항목을 지정합니다. --dhcp-boot 는 단순히 부팅 파일 이름을 줍니다.', '[0]', '--{0}', NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 11, '주소 범위 옵션', 'DHCP 로 나눠 줄 **주소 범위** 를 정하고 임대 시간을 줄 수 있는 옵션입니다. 빈칸을 채우세요.', '"range" 가 들어가요.', NULL, NULL, '[]', 'fill', '["dhcp-range", "dhcp-host", "dhcp-boot", "dhcp-option"]', NULL, '--dhcp-range 는 DHCP 로 나눠 줄 주소 범위와 선택적으로 임대 시간(초·분·시간·일·주 또는 infinite)을 정합니다.', '[0]', 'dnsmasq --{0}=192.168.0.50,192.168.0.150,12h', NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 397, 12, 'dnsmasq 로 PXE 부팅 서버 만들기', 'dnsmasq 로 네트워크 부팅을 제공하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '범위 → TFTP → 파일 → 부팅이에요.', NULL, NULL, '[]', 'order', '["--dhcp-range 로 DHCP 주소 범위를 설정한다", "--enable-tftp 로 TFTP 를 켜고 --tftp-root 로 파일 위치를 정한다", "--dhcp-boot 로 부팅 파일 이름을 알려 준다", "클라이언트가 PXE 로 부팅해 파일을 TFTP 로 받는다"]', NULL, '문서가 설명하는 옵션들을 이은 큰 줄기입니다. dnsmasq 가 TFTP 도 제공하면 --dhcp-boot 에는 파일 이름만 있으면 됩니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "dnsmasq 매뉴얼", "url": "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 397 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 632 WHERE id = 117;
UPDATE quest_set SET display_order = 628, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '📡' WHERE id = 397;
