-- 퀴즈 세트 468. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round10.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 468, 'arp(7) ARP 캐시: 주소 변환, ioctl, 재조사 순서, 프록시 ARP, gc_thresh, neigh 설정', '리눅스 ARP 모듈을 읽습니다. L2·IPv4 주소 변환, SIOCSARP·DARP·GARP 와 권한, permanent 항목, 데몬→유니캐스트→브로드캐스트 재조사 순서, 긍정 피드백, 프록시 ARP, gc_thresh1~3, base_reachable_time, unres_qlen 을 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 468);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 1, 'ARP 역할', 'arp(7) 이 설명하는 리눅스 ARP 모듈의 역할은 무엇일까요?', 'RFC 826 이에요.', NULL, NULL, '[]', 'choice', '["원격 망의 호스트 이름을 IPv4 주소로 변환한다", "게이트웨이까지의 최적 경로를 계산해 알려 준다", "직접 연결된 망에서 L2 하드웨어 주소와 IPv4 주소를 변환한다", "프레임 단편화와 재조립을 맡아서 처리한다"]', 2, '문서는 이 커널 모듈이 RFC 826 의 ARP 를 구현하며 직접 연결된 네트워크에서 L2 하드웨어 주소와 IPv4 프로토콜 주소를 변환하는 데 쓰인다고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 2, 'ARP ioctl', '`SIOCSARP`·`SIOCDARP` 로 ARP 매핑을 설정·삭제하려면 무엇이 필요할까요?', '특권 작업이에요.', NULL, NULL, '[]', 'choice', '["CAP_NET_BIND_SERVICE 권한이다", "CAP_NET_ADMIN 이나 유효 UID 0", "어떤 일반 사용자든 가능하다", "CAP_SYS_BOOT 권한이 필요하다"]', 1, '문서는 SIOCSARP·SIOCDARP·SIOCGARP 가 각각 매핑을 설정·삭제·조회하며, 설정과 삭제는 CAP_NET_ADMIN 이나 유효 UID 0 인 프로세스만 할 수 있는 특권 작업이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 3, 'permanent', 'ARP 캐시의 **permanent** 로 표시된 항목은 어떻게 다뤄질까요?', '가비지 컬렉터와 관련돼요.', NULL, NULL, '[]', 'choice', '["가비지 컬렉터가 절대 지우지 않는다", "일정 시간이 지나면 가비지 컬렉터가 지운다", "재부팅 후에도 파일에 저장돼 남는다", "새 응답이 오면 자동으로 덮어쓴다"]', 0, '문서는 캐시 크기가 제한되어 오래되고 덜 쓰이는 항목이 수거되지만, permanent 로 표시된 항목은 가비지 컬렉터가 절대 지우지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 4, '재조사 순서', '긍정적 피드백이 없을 때 ARP 가 MAC 주소를 다시 확인하는 순서로 맞는 것은 무엇일까요?', '데몬 → 유니캐스트 → 브로드캐스트예요.', NULL, NULL, '[]', 'choice', '["브로드캐스트 요청 → 유니캐스트 프로브 → 로컬 arp 데몬", "유니캐스트 프로브 → 로컬 arp 데몬 → 멀티캐스트 요청", "항상 처음부터 브로드캐스트 요청만 보낸다", "로컬 arp 데몬 → 유니캐스트 프로브 → 브로드캐스트 요청"]', 3, '문서는 먼저 로컬 arp 데몬에 app_solicit 번, 실패하고 옛 MAC 을 알면 유니캐스트 프로브를 ucast_solicit 번, 그것도 실패하면 새 ARP 요청을 브로드캐스트한다고 설명합니다. 요청은 보낼 데이터가 큐에 있을 때만 보냅니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 5, '긍정 피드백', '기존 매핑이 stale 이 되지 않게 하는 **긍정적 피드백** 의 예로 문서가 드는 것은 무엇일까요?', '상위 계층에서 와요.', NULL, NULL, '[]', 'choice', '["수신한 ICMP echo 요청, 또는 SO_KEEPALIVE 설정", "라우팅 테이블 갱신, 또는 인터페이스 MTU 변경", "성공한 TCP ACK, 또는 sendmsg 의 MSG_CONFIRM 플래그", "사용자 공간의 arp -d 명령 실행"]', 2, '문서는 상위 계층(예: 성공한 TCP ACK)이 긍정적 피드백을 줄 수 있고, 다른 프로토콜은 sendmsg(2) 의 MSG_CONFIRM 플래그로 진행 상황을 알린다고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 6, 'proxy arp', '프록시 ARP 가 켜진 인터페이스가 자신이 포워딩하는 주소에 대한 요청을 받으면 어떻게 될까요?', '자동으로 항목이 생겨요.', NULL, NULL, '[]', 'choice', '["영구(permanent) 항목을 설정 파일에 기록한다", "비영구 프록시 항목을 자동 추가한다", "요청을 무시하고 아무 항목도 만들지 않는다", "항상 reject 경로를 만들어 응답한다"]', 1, '문서는 프록시 ARP 가 수신 인터페이스에서 켜져 있고 해당 주소로 포워딩하는 경우 비영구 프록시 항목을 자동 추가하며, 대상에 reject 경로가 있으면 추가하지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 7, 'gc_thresh3', '`gc_thresh3` 는 어떤 값일까요?', '세 개 중 가장 커요.', NULL, NULL, '[]', 'choice', '["ARP 캐시의 하드 최대치(기본 1024)다", "유지할 최소 항목 수(기본 128)다", "5초 동안 초과를 허용하는 소프트 최대치(기본 512)다", "미해결 주소당 큐 패킷 수(기본 3)다"]', 0, '문서는 gc_thresh1 이 최소 유지 항목(128), gc_thresh2 가 5초간 초과를 허용하는 소프트 최대(512), gc_thresh3 가 하드 최대(1024)이며 넘으면 가비지 컬렉터가 항상 실행된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 8, 'base_reachable_time', '`base_reachable_time` 은 이웃 항목의 유효 시간을 어떻게 정할까요?', '무작위 범위가 있어요.', NULL, NULL, '[]', 'choice', '["정확히 base 초 뒤에 항상 만료되고 기본은 60초다", "피드백이 있어도 연장되지 않고 기본은 5초다", "0 으로 두면 영구 항목이 되고 기본은 1초다", "base/2~3*base/2 무작위 값 이상이다"]', 3, '문서는 이웃이 발견되면 base_reachable_time/2 ~ 3*base_reachable_time/2 사이 무작위 값 이상 유효하며 상위 계층의 긍정적 피드백이 있으면 연장되고, 기본은 30초(_ms 는 30000)라고 설명합니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 9, 'unres_qlen', '`unres_qlen` 은 무엇을 정할까요?', '아직 해소 안 된 주소예요.', NULL, NULL, '[]', 'choice', '["캐시 전체에 보관할 항목 수(기본 1024)", "프록시 ARP 주소로 갈 큐 패킷 수(기본 64)", "미해결 주소당 큐 패킷 수(기본 3)다", "멀티캐스트 해소 시도 횟수(기본 3)"]', 2, '문서는 unres_qlen 이 각 미해결 주소에 대해 다른 네트워크 계층이 큐에 넣을 수 있는 최대 패킷 수이며 기본 3 이라고 설명합니다. proxy_qlen 은 프록시 ARP 주소용(64)입니다.', NULL, NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 10, 'neigh 디렉터리', '새로 생기는 장치에 적용되는 설정이 들어 있는 `/proc/sys/net/ipv4/neigh/` 하위 디렉터리입니다. 빈칸을 채우세요.', '"기본" 이에요.', NULL, NULL, '[]', 'fill', '["default", "all", "lo", "global"]', NULL, '문서는 각 인터페이스가 neigh 아래 자기 디렉터리를 가지며 default 디렉터리의 설정이 새로 만들어지는 모든 장치에 쓰인다고 설명합니다.', '[0]', '/proc/sys/net/ipv4/neigh/{0}/', NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 11, 'SIOCGARP', 'ARP 매핑을 **조회** 하는 ioctl 입니다. 빈칸을 채우세요.', 'Get 의 G 예요.', NULL, NULL, '[]', 'fill', '["GARP", "SARP", "DARP", "CARP"]', NULL, '문서는 SIOCSARP·SIOCDARP·SIOCGARP 가 각각 매핑을 설정(Set)·삭제(Delete)·조회(Get)한다고 설명합니다.', '[0]', 'ioctl(fd, SIOC{0}, &arpreq)', NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 468, 12, 'MAC 재확인', '긍정적 피드백이 없는 ARP 항목을 다시 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '데몬 → 유니캐스트 → 브로드캐스트예요.', NULL, NULL, '[]', 'order', '["보낼 데이터가 큐에 있고 항목이 stale 이 된다", "로컬 arp 데몬에 app_solicit 번 갱신을 요청한다", "옛 MAC 을 알면 ucast_solicit 번 유니캐스트 프로브를 보낸다", "그래도 실패하면 새 ARP 요청을 브로드캐스트한다"]', NULL, '문서의 재조사 설명을 순서대로 이은 것입니다. 요청은 보낼 데이터가 큐에 있을 때만 보냅니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "arp(7) man page", "url": "https://man7.org/linux/man-pages/man7/arp.7.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 468 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 647 WHERE id = 117;
UPDATE quest_set SET display_order = 643, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '📇' WHERE id = 468;
