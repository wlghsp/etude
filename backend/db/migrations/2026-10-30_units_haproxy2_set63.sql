-- Git 세트 63. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set63.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 13, '미들웨어', '로드밸런서', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 13);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 63, 'HAProxy 심화: 분산 방식, 연결 제한, TLS, 이중화', 'HAProxy 의 분산 알고리즘(leastconn, source), 세션 고정, 타임아웃과 maxconn·queue, SSL Termination 과 Passthrough, SNI, 그리고 VIP·Keepalived·VRRP 로 HAProxy 자체를 이중화하는 흐름, rate limiting, retry 와 redispatch 를 문제로 정리합니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 63);
UPDATE quest_set SET display_order = 511, unit_id = (SELECT id FROM unit WHERE id = 13), icon = '🛡️' WHERE id = 63;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 1, '분산 알고리즘 고르기: leastconn', '요청마다 처리 시간 편차가 큽니다(어떤 요청은 몇 초 걸리는 긴 연결). roundrobin 을 쓰면 특정 서버에 **미완료 연결이 쌓일** 수 있습니다. 이럴 때 알맞은 알고리즘은 무엇일까요?', '"현재 활성 연결 수"를 기준으로 고르는 알고리즘입니다.', NULL, NULL, '[]', 'choice', '["`balance leastconn` (현재 연결 수가 가장 적은 서버로 보낸다)", "`balance roundrobin` 을 그대로 쓴다", "`balance source` (IP 해시)", "`balance first` 는 항상 첫 서버로만 보낸다"]', 0, '**leastconn** 은 각 서버의 현재 연결 수를 추적해 가장 적은 서버를 고릅니다. 처리 시간이 들쭉날쭉하거나 연결이 오래 유지되는 서비스에 적합하고, 연결 수가 같으면 roundrobin 처럼 순서대로 고릅니다. roundrobin 은 처리 중인 요청 수를 신경 쓰지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 2, 'balance source 의 특징 알기', '`balance source` 는 어떤 방식으로 서버를 고를까요? 그리고 주의할 점은 무엇일까요?', '클라이언트의 어떤 정보를 해싱할까요?', NULL, NULL, '[]', 'choice', '["URL 경로를 해싱한다. 서버 수가 바뀌어도 변하지 않는다", "클라이언트 **소스 IP 를 해싱**해 같은 IP 는 (서버가 살아 있는 한) 항상 같은 서버로 보낸다. 서버 수가 바뀌면 해시 결과가 달라져 **다른 서버로 옮겨질 수 있다**", "무작위로 고른다", "응답이 가장 빠른 서버를 고른다"]', 1, '`source` 는 IP 해시로 서버를 고정하므로 TCP 모드에서도 세션 고정 효과를 냅니다. 다만 서버가 추가·제거되면 해시 결과가 달라질 수 있고, 같은 NAT 뒤의 많은 사용자가 한 서버로 쏠릴 수 있습니다. 쿠키 기반 고정(sticky session)은 HTTP 모드에서 쓰는 방법입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 3, 'Sticky Session 이 필요한 이유 알기', '세션 데이터를 **서버 메모리**에 저장하는 구조에서, 요청이 번갈아 다른 서버로 가면 사용자의 **로그인이 풀리는** 문제가 생깁니다. 이를 막는 HAProxy 기능은 무엇일까요?', '같은 클라이언트를 같은 서버로 고정하는 기능입니다.', NULL, NULL, '[]', 'choice', '["SSL Termination", "Rate Limiting", "Sticky Session (쿠키 기반 세션 고정): 응답에 서버를 식별하는 쿠키를 심어 이후 요청을 같은 서버로 보낸다", "Health Check"]', 2, '세션이 서버 메모리에 있으면 다른 서버는 그 세션을 모릅니다. HAProxy 가 쿠키로 서버를 식별해 고정하면 이를 막을 수 있습니다. 근본적으로는 세션을 Redis 같은 외부 저장소에 두면 고정이 필요 없어집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 4, 'timeout 종류 구분하기 (1): connect', '`timeout connect 5s` 는 어떤 구간의 제한일까요?', 'HAProxy 가 백엔드와 처음 연결을 맺는 구간입니다.', NULL, NULL, '[]', 'choice', '["클라이언트가 아무것도 보내지 않고 멈춰 있는 시간", "서버가 응답을 내려보내지 않고 멈춰 있는 시간", "HTTP 요청 헤더가 모두 도착할 때까지의 시간", "HAProxy 가 백엔드 서버와 **TCP 연결을 맺을 때까지** 기다리는 시간 (넘으면 서버가 죽은 것으로 보고 다른 서버를 시도)"]', 3, '`timeout connect` 는 보통 짧게(3~5초) 둡니다. `timeout client` 는 클라이언트 쪽 비활성 시간, `timeout server` 는 서버 쪽 비활성 시간(처리 시간이 긴 API 면 넉넉히), `timeout http-request` 는 요청 헤더 전체가 도착할 때까지의 시간입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 5, 'timeout http-request 의 용도 알기', '공격자가 HTTP 헤더를 **아주 천천히** 보내 연결을 오래 붙잡아 두는 공격(Slowloris)을 방어하려면 어떤 설정이 도움이 될까요?', '요청 헤더 전체가 도착할 때까지 기다리는 시간을 제한합니다.', NULL, NULL, '[]', 'choice', '["`timeout http-request` 를 짧게 설정한다", "`timeout connect` 를 길게 설정한다", "`balance roundrobin` 으로 바꾼다", "`stats enable` 을 켠다"]', 0, '`timeout http-request` 는 헤더가 이 시간 안에 다 도착하지 않으면 연결을 끊습니다. 느리게 보내며 연결 슬롯을 점유하는 Slowloris 류 공격을 막는 데 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 6, 'maxconn 과 queue 동작 알기', '백엔드 서버의 `maxconn` 이 100 이고 이미 100개가 모두 처리 중일 때 새 요청이 들어오면 HAProxy 는 어떻게 할까요?', '즉시 거부하지 않고 잠시 기다리게 하는 버퍼가 있습니다.', NULL, NULL, '[]', 'choice', '["즉시 연결을 끊고 아무 응답도 하지 않는다", "요청을 **queue** 에 넣고 기존 연결이 끝나면 꺼내 보낸다. `timeout queue` 안에 서버를 배정받지 못하면 **503** 을 반환한다", "서버의 maxconn 을 자동으로 늘린다", "다른 사용자의 연결을 강제 종료한다"]', 1, '`maxconn` 은 global(프로세스 전체), frontend(리스너), server(서버 한 대) 레벨에서 따로 둘 수 있습니다. 서버 maxconn 이 꽉 차면 HAProxy 의 queue 가 대신 기다려 주어 서버를 과부하에서 보호하고, 대기 시간이 길면 503 이 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 7, 'SSL Termination 알기', '클라이언트와 HAProxy 사이에서만 TLS 를 처리하고, HAProxy 가 **복호화한 뒤 백엔드에는 평문 HTTP** 로 전달하는 방식은 무엇일까요?', '이 방식은 HAProxy 가 HTTP 내용을 볼 수 있어 경로·헤더 기반 라우팅이 가능합니다.', NULL, NULL, '[]', 'choice', '["SSL Passthrough", "Sticky Session", "SSL Termination", "VRRP"]', 2, '**SSL Termination** 은 HAProxy 가 TLS 를 종료(복호화)해 백엔드 서버가 TLS 부담을 지지 않고 인증서를 한 곳에서 관리할 수 있습니다. **SSL Passthrough** 는 복호화 없이 암호화된 패킷을 그대로 백엔드로 전달하며 TCP 모드에서만 동작하고 end-to-end 암호화를 유지합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 8, 'SNI 가 필요한 이유 알기', '하나의 IP 에서 여러 도메인(`a.example.com`, `b.example.com`)의 HTTPS 를 서비스하려면, TLS 핸드셰이크 초기에 **어느 도메인으로 접속하려는지** 서버가 알아야 알맞은 인증서를 내려줄 수 있습니다. 이를 가능하게 하는 것은 무엇일까요?', 'ClientHello 에 도메인 이름을 담는 TLS 확장입니다.', NULL, NULL, '[]', 'choice', '["VRRP", "WAL", "DLQ", "SNI (Server Name Indication)"]', 3, 'HTTPS 는 TLS 핸드셰이크가 HTTP 요청보다 먼저라, 핸드셰이크 시점에는 Host 헤더를 볼 수 없습니다. **SNI** 는 ClientHello 에 도메인명을 포함해서 이 문제를 풉니다. HAProxy 에서는 SNI 로 도메인별 인증서를 고르거나 다른 backend 로 라우팅할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 9, 'VIP 가 필요한 이유 알기', 'HAProxy 를 Active/Passive 두 대로 이중화했습니다. 클라이언트가 **VIP(가상 IP)** 로 접속하게 하는 이유는 무엇일까요?', 'Active 가 바뀌어도 클라이언트 설정을 바꾸지 않아야 합니다.', NULL, NULL, '[]', 'choice', '["Active 가 죽어 Passive 로 전환되어도 **VIP 만 새 서버로 옮겨 가므로** 클라이언트는 같은 IP 로 계속 접속할 수 있다", "VIP 는 HAProxy 를 더 빠르게 만든다", "VIP 는 서버의 디스크를 늘린다", "VIP 는 로그를 암호화한다"]', 0, '실제 IP 로 접속하게 하면 장애 시 클라이언트 설정을 바꿔야 합니다. VIP 는 특정 서버에 고정되지 않고 Active 의 네트워크 인터페이스에 추가 IP 로 붙어 있다가, Active 가 죽으면 Passive 로 이동합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 10, 'Keepalived 와 VRRP 역할 알기', 'HAProxy 는 **백엔드 서버**의 장애는 감지하지만 **HAProxy 자신**이 죽으면 대응하지 못합니다. 이때 HAProxy 노드 간 VIP 를 옮기는 역할을 하는 것은 무엇일까요?', 'VRRP 프로토콜을 이용해 VIP 소유권을 관리하는 데몬입니다.', NULL, NULL, '[]', 'choice', '["Logstash", "Keepalived (VRRP 로 VIP 소유권을 관리하며, 같은 `virtual_router_id` 그룹에서 priority 가 가장 높은 노드가 Master 가 되어 VIP 를 가진다)", "Prometheus", "Debezium"]', 1, 'Keepalived 는 VRRP 로 노드들이 하나의 가상 라우터처럼 보이게 합니다. Master 는 주기적으로 advertisement(heartbeat)를 보내고, Backup 이 일정 시간 받지 못하면 priority 가 가장 높은 Backup 이 새 Master 가 되어 VIP 를 가져갑니다. (HAProxy 프로세스 자체의 상태를 보는 스크립트 체크도 함께 쓰는 것이 일반적입니다.)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 11, 'Active HAProxy 가 죽었을 때 VIP 가 넘어가는 순서 놓기', 'Active HAProxy(Keepalived 포함)가 장애로 죽었을 때 VIP 가 Passive 로 넘어가는 흐름을 **앞에서 뒤 순서**대로 놓으세요.', 'Master 가 보내던 heartbeat 가 끊기는 것에서 시작합니다.', NULL, NULL, '[]', 'order', '["Backup 이 일정 시간 advertisement 를 받지 못해 Master 가 죽었다고 판단한다", "priority 가 가장 높은 Backup 이 새 Master 가 되어 VIP 를 자신의 인터페이스에 붙인다", "Active 가 죽어 VRRP advertisement(heartbeat)가 끊긴다", "클라이언트는 같은 VIP 로 계속 접속하고 새 Master 가 트래픽을 받는다"]', NULL, '**heartbeat 끊김 → Backup 이 timeout 으로 Master 사망 판단 → 최고 priority Backup 이 새 Master 가 되어 VIP 획득 → 클라이언트는 그대로 같은 VIP 로 접속** 순서입니다. 클라이언트 입장에서는 같은 IP 로 계속 접속하므로 전환이 투명합니다.', '[2, 0, 1, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 12, 'Rate Limiting 의 원리 알기', 'HAProxy 에서 **IP 별 요청 수를 제한**(rate limiting)할 때 요청 수를 추적하는 저장소는 무엇일까요?', 'HAProxy 내부의 인메모리 상태 저장소입니다.', NULL, NULL, '[]', 'choice', '["Translog", "Stick Table (IP 별 요청 수·연결 수 등을 인메모리에 추적하고, 기준을 넘으면 거부하는 규칙과 함께 쓴다)", "Consumer Group", "Persistent Volume"]', 1, '`stick-table type ip size 1m expire 10s store http_req_rate(10s)` 처럼 IP 별 10초 동안의 요청률을 저장하고, ACL 로 기준 초과 시 거부(`http-request deny`)하는 식으로 씁니다. 동시 연결 수 제한(connection limiting)과는 다른 개념입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 13, 'retry 와 redispatch 구분하기', '백엔드 연결이 실패했을 때 `retries 3` 은 무엇을 하고, **redispatch** 는 무엇을 할까요?', '하나는 같은 서버에 다시 시도하고, 하나는 다른 서버로 넘깁니다.', NULL, NULL, '[]', 'choice', '["둘 다 서버를 재시작한다", "`retries` 는 로그를 지우고 redispatch 는 로그를 쓴다", "`retries` 는 연결 실패 시 **같은 서버에 재시도**하는 횟수이고, `option redispatch` 는 재시도 중 **다른 서버로 요청을 넘기는** 것이다", "`retries` 는 백엔드를 추가하고 redispatch 는 삭제한다"]', 2, '서버가 일시적으로 연결을 못 받을 때 같은 서버에 몇 번 더 시도(retries)하고, 그래도 안 되면 다른 건강한 서버로 넘기는(redispatch) 구성이 흔합니다. 쓰기 요청처럼 중복 실행이 위험한 경우에는 재시도 범위를 신중히 정해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 13);
