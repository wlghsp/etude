-- Git 세트 69. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set69.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 24, '미들웨어', '사내 장애 사례', 70 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 24);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 69, '연쇄 장애 읽기: 증상 뒤의 원인 찾기', '운영에서 흔히 겪는 연쇄 장애를 바탕으로 한 사례로, 증상에서 원인으로 거슬러 올라가는 법을 익힙니다. Kafka CPU 폭증의 진짜 원인(NetworkPolicy 로 막힌 ES), 파이프라인 구간별 유실 여부, Galera 노드 복구와 쿼럼 상실, 비대칭 라우팅, 장애 테스트 전 기록을 다룹니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 69);
UPDATE quest_set SET display_order = 571, unit_id = (SELECT id FROM unit WHERE id = 24), icon = '🧯' WHERE id = 69;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 1, 'Kafka CPU 폭증의 진짜 원인을 거슬러 올라가는 순서 놓기', 'Kafka 브로커 CPU 가 갑자기 치솟았습니다. 실제 원인은 **파이프라인 뒤쪽**이었습니다. **원인에서 증상 방향**으로 연쇄를 놓으세요.', '증상(CPU)이 가장 마지막입니다.', NULL, NULL, '[]', 'order', '["Kafka 에 메시지가 계속 쌓여 브로커 CPU 가 폭증한다", "Logstash 가 Kafka 에서 소비(consume)를 멈춘다", "ES 클러스터가 내부 통신이 막혀 master 를 못 뽑는다 (quorum 붕괴)", "네임스페이스 전체에 걸린 NetworkPolicy 가 ES 통신 포트를 차단한다", "Logstash 가 ES 로 전송하지 못한다"]', NULL, '**NetworkPolicy 차단 → ES quorum 붕괴 → Logstash 전송 실패 → consume 중단 → Kafka 적체 → CPU 폭증** 입니다. Kafka CPU 는 증상이었고 원인은 맨 뒤의 ES 였습니다. 이런 연쇄는 앞 단계의 신호만 보면 엉뚱한 곳을 고치게 됩니다.', '[3, 2, 4, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 2, '증상과 원인을 구분하기', 'Kafka 브로커의 **로그에는 ERROR 가 없고, ISR 도 모두 정상**인데 CPU 만 높습니다. 어떻게 판단할까요?', '브로커 자체가 아니라 그 주변에서 원인을 찾아야 합니다.', NULL, NULL, '[]', 'choice', '["브로커 자체나 복제 문제가 아니라 **소비 쪽(consumer lag)·뒤의 파이프라인**에서 막혀 메시지가 적체되어 생긴 증상일 수 있다고 보고, 뒤쪽으로 진단을 넓힌다", "브로커 하드웨어 고장이므로 즉시 교체한다", "ISR 이 정상이니 아무 문제가 없다", "CPU 지표가 틀린 것이다"]', 0, '진단은 "문제가 보이는 곳"에서 시작하되 "원인이 있는 곳"으로 이동해야 합니다. 로그에 오류가 없고 복제도 정상이면 브로커 자체는 아니라는 증거이고, consumer lag(적체)와 소비자 상태로 시선을 옮깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 3, 'Kafka CPU 폭증 시 역방향 진단 순서 놓기', 'Kafka CPU 폭증에서 원인을 찾는 **역방향 진단 순서**를 앞에서 뒤로 놓으세요.', '가까운 곳(소비 적체)에서 먼 곳(네트워크 정책) 순서입니다.', NULL, NULL, '[]', 'order', '["ES 클러스터 상태(health)와 master 선출 상태를 확인한다", "consumer group 의 lag(적체)를 확인한다", "NetworkPolicy 등 네트워크 차단 정책이 있는지 확인한다", "Logstash 의 상태와 처리 로그를 확인한다"]', NULL, '**consumer lag → Logstash → ES 상태 → NetworkPolicy** 순서입니다. 앞에서부터 "여기는 정상"을 하나씩 지워 나가는 방식이고, 각 단계에서 정상이면 다음 단계로, 비정상이면 그 지점의 원인을 파고듭니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 4, 'NetworkPolicy 가 위험한 이유 알기', '`podSelector: {}` 이고 특정 포트(예: 8080)만 허용하는 NetworkPolicy 가 네임스페이스에 만들어졌습니다. 어떤 일이 생길까요?', '`podSelector: {}` 는 그 네임스페이스의 모든 Pod 에 적용됩니다.', NULL, NULL, '[]', 'choice', '["지정한 포트만 차단되고 나머지는 열린다", "네임스페이스의 **모든 Pod** 에 적용되어, 허용되지 않은 포트(예: ES 의 9200·9300)의 통신이 차단된다", "아무 Pod 에도 적용되지 않는다", "Ingress 만 막히고 Egress 는 영향이 없다"]', 1, 'NetworkPolicy 는 선택된 Pod 에 대해 **허용 목록**(allow list)처럼 동작해서, 정책이 하나라도 적용되면 명시하지 않은 통신은 막힙니다. 테스트용으로 만든 정책을 지우지 않아 운영 통신이 끊기는 일이 실제로 많습니다. 의심되면 `get networkpolicy` 와 `describe` 로 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 5, '파이프라인 구간별 유실 여부 알기', 'Vector → Kafka → Logstash → Elasticsearch 파이프라인에서 **Elasticsearch 가 멈췄을 때** 데이터는 어떻게 될까요? (Logstash 에 Persistent Queue 가 있음)', '소비 후 전송 단계의 버퍼를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["전부 즉시 사라진다", "Kafka 의 데이터가 삭제된다", "Logstash 가 Persistent Queue(디스크 버퍼)에 쌓아 두므로 **유실 없이** 복구 후 전송된다. 단 큐 용량을 넘기면 안 된다", "Vector 가 데이터를 복제해 보낸다"]', 2, '구간마다 버퍼가 다릅니다. Logstash 중지는 Kafka 에 offset 이 남아 유실이 없고, ES 장애는 Logstash PQ 가, Kafka·Vector 중지는 Vector 디스크 버퍼가 받아 줍니다. 반면 수집 원천(Prometheus)이 멈추면 그 시간의 scrape 데이터는 유실됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 6, '수집 원천이 멈추면 유실될까', '파이프라인의 맨 앞 **Prometheus 가 정지**되었다가 복구되었습니다. 정지된 시간의 메트릭은 어떻게 될까요?', 'Prometheus 는 pull 방식입니다.', NULL, NULL, '[]', 'choice', '["Kafka 가 자동으로 과거 값을 만들어 채운다", "복구하면 모두 자동으로 되살아난다", "Vector 가 보관하고 있다가 복구 후 보낸다", "정지된 동안은 아무도 scrape 하지 않으므로 그 시간의 데이터는 **유실**된다 (뒤쪽 버퍼가 대신 채워 줄 수 없다)"]', 3, '뒤쪽 버퍼(Vector, PQ, Kafka)는 "이미 들어온 데이터"를 지켜 줄 뿐 아직 수집하지 못한 데이터는 어디에도 없습니다. 그래서 수집 원천의 가용성(이중화)이 별도로 중요하고, 장애 후에는 유실 구간을 문서화해 둡니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 7, 'Galera 노드 하나가 다운되었을 때 확인할 것', '3노드 Galera 에서 노드 하나가 내려갔다가 다시 올라옵니다. **정상 복귀**를 확인하는 두 가지 상태값은 무엇일까요?', '클러스터 크기와 노드의 동기화 상태입니다.', NULL, NULL, '[]', 'choice', '["`wsrep_cluster_size` 가 3 이고 `wsrep_local_state_comment` 가 `Synced` 인지", "`Threads_connected` 와 `Uptime` 만 본다", "`max_connections` 와 `wsrep_provider` 만 본다", "서비스가 켜져 있으면 정상이므로 확인할 것이 없다"]', 0, '복귀 후에는 `wsrep_cluster_size` 가 기대한 노드 수(3)인지, 그 노드가 `Synced` 인지(동기화에 1~2분 걸릴 수 있음) 봅니다. 시작이 안 되면 서비스 로그, 디스크·메모리, 그리고 `grastate.dat` 의 상태를 순서대로 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 8, 'Galera 쿼럼을 잃었을 때', '3노드 Galera 에서 **2대가 동시에 다운**되어 남은 노드가 PRIMARY 가 되지 못하고 쓰기가 모두 막혔습니다(`wsrep_ready=OFF`, "quorum is lost"). 가장 적절한 긴급 조치는 무엇일까요?', '남은 노드가 "나 혼자서도 클러스터를 진행하겠다"고 선언해야 합니다.', NULL, NULL, '[]', 'choice', '["남은 노드를 그대로 두고 기다린다", "남은 노드에서 `SET GLOBAL wsrep_provider_options=\\"pc.bootstrap=YES\\"` 로 Primary 를 **강제 지정**한다 (다른 노드가 정말 죽어 있는지 먼저 확인한 뒤)", "남은 노드의 데이터 디렉터리를 지운다", "`wsrep_cluster_size` 를 직접 3 으로 설정한다"]', 1, '과반을 잃으면 split-brain 을 막으려고 클러스터가 멈춥니다. 정말 다른 노드가 죽은 것이 확실할 때만 남은 노드를 bootstrap 해서 서비스를 살리고, 이후 죽은 노드를 하나씩 복귀시킵니다. 다른 노드가 살아 있는데 강제로 하면 데이터가 분기됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 9, '비대칭 라우팅 이해하기', '클라이언트 서버가 프록시 서버의 한 IP 로 TCP 연결을 시도하면 **타임아웃**이 납니다. 프록시 서버는 NIC 2개(대역 A, B)를 갖고 있고 클라이언트는 대역 B 와 같은 대역입니다. 원인으로 가장 알맞은 것은 무엇일까요?', '응답 패킷이 어느 NIC 로 나가는지 보세요.', NULL, NULL, '[]', 'choice', '["방화벽이 SYN 을 영구적으로 차단한다", "HAProxy 의 `timeout connect` 가 짧아서이다", "요청은 대역 A 의 IP 로 들어왔지만, 응답은 커널 라우팅이 **대역 B 쪽 NIC 로** 내보내서 클라이언트가 다른 연결로 보고 무시한다 (비대칭 라우팅)", "DNS 가 잘못된 주소를 돌려줘서이다"]', 2, '들어온 NIC 와 응답이 나가는 NIC 가 다르면 SYN-ACK 의 출발 IP 가 달라져 연결이 성립하지 않습니다. 해결은 **정책 라우팅**(`ip rule`/`ip route` 별도 테이블)으로 "대역 A 의 IP 에서 출발하는 응답은 대역 A 의 NIC 로" 나가게 하는 것입니다. 임시 적용은 재부팅하면 사라지므로 영구 설정이 필요합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 10, '장애 테스트 전 기록해 둘 것', '파이프라인 장애를 일부러 일으켜 테스트하기 전에 **반드시 기록해 둘** 것으로 알맞은 것은 무엇일까요?', '복구 후 "유실이 있었는가"를 비교할 기준이 필요합니다.', NULL, NULL, '[]', 'choice', '["오직 서버 이름만 기록하면 충분하다", "기록 없이 바로 시작해도 비교할 수 있다", "테스트 후에 지난 값을 추정하면 된다", "장애 시작 시각, 현재 ES 문서 수, 버퍼 크기(Logstash PQ·Vector), Kafka lag 같은 **기준값**"]', 3, '복구 후 문서 수나 lag 를 장애 전 값과 비교해야 유실 여부를 판단할 수 있고, 시작·복구 시각으로 확인 쿼리의 범위를 정합니다. 쉬운 장애부터(Logstash 정지) 어려운 것 순으로 진행하고, 각 테스트 전에 이 기록을 남기는 것이 절차입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 10);
