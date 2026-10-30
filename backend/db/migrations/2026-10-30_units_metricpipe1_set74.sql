-- Git 세트 74. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set74.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 18, '미들웨어', '관측 (모니터링·로그)', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 18);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 74, '메트릭 파이프라인 읽기: Prometheus → Vector → Kafka', '클러스터 내부 Prometheus 에서 federate 로 메트릭을 가져와 recording rule 로 가공하고 Vector 로 변환·집계해 Kafka 로 보내는 메트릭 파이프라인을 읽습니다. federation 과 remote_write, recording rule, Vector 의 변환 단계와 reduce, 토픽 분리, HAProxy 를 거치는 federate 통신, 토큰 권한 오류와 단계별 진단을 다룹니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 74);
UPDATE quest_set SET display_order = 521, unit_id = (SELECT id FROM unit WHERE id = 18), icon = '🚰' WHERE id = 74;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 1, '메트릭 파이프라인의 전체 흐름 놓기', '메트릭이 원천에서 Kafka 까지 가는 흐름을 **앞에서 뒤**로 놓으세요.', '가져오고, 가공하고, 변환하고, 전송합니다.', NULL, NULL, '[]', 'order', '["Vector 가 변환·집계한다", "Kafka 토픽으로 전송된다", "수집 서버가 원천 Prometheus 의 `/federate` 에서 필요한 메트릭을 가져와 규칙으로 가공한다", "원천 Prometheus 가 컨테이너·노드 메트릭을 가지고 있다"]', NULL, '**원천 Prometheus → 수집 서버(federate 수집·recording rule 가공) → Vector(변환·집계) → Kafka** 입니다. 원천 Prometheus 를 직접 건드리지 않고 필요한 메트릭만 가져오는 것이 federation 의 목적입니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 2, 'federation 이 무엇인지 알기', 'Prometheus 의 **federation** 은 어떤 구조일까요?', '가져오는 쪽이 `/federate` 엔드포인트를 scrape 합니다.', NULL, NULL, '[]', 'choice', '["한 Prometheus 가 다른 Prometheus 의 `/federate` 엔드포인트를 **scrape** 해서 필요한 메트릭만 선별해 가져오는 구조이다", "한 Prometheus 가 다른 Prometheus 로 모든 데이터를 자동 푸시한다", "두 Prometheus 가 하나의 디스크를 공유한다", "Kafka 를 거쳐서만 가능하다"]', 0, '`match[]` 로 가져올 시계열을 지정하므로 원천 Prometheus 의 부담을 줄이고 필요한 것만 받을 수 있습니다. 가져오는 방향은 pull 이고, 인증이 필요하면 bearer token 을 함께 보냅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 3, 'recording rule 이 필요한 이유', 'raw 메트릭(예: `node_cpu_seconds_total`)을 그대로 쓰기 어려워서 **recording rule** 로 미리 계산해 저장합니다. 이유로 알맞은 것은 무엇일까요?', 'counter 의 누적값, 여러 코어 합산 같은 문제를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["raw 메트릭은 저장할 수 없어서이다", "counter 는 누적값이라 rate 계산이 필요하고, CPU 코어 등을 합산해야 하므로 **미리 계산해 새 메트릭 이름으로 저장**해 두면 이후 사용이 쉽고 쿼리 부담이 준다", "recording rule 은 알림을 메일로 보내기 위해서이다", "메트릭 이름을 길게 만들기 위해서이다"]', 1, 'recording rule 은 주기(예: 25초)마다 쿼리를 평가해 결과를 새로운 시계열로 저장합니다. 무거운 계산을 쿼리 시점이 아니라 미리 해 두는 것입니다. (알림은 alerting rule 의 일입니다.)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 4, 'remote_write 방향 알기', 'Prometheus 에서 Vector 로 메트릭을 보낼 때 **remote_write** 의 방향으로 알맞은 것은 무엇일까요?', 'Vector 가 포트를 열어 두고 기다립니다.', NULL, NULL, '[]', 'choice', '["Vector 가 Prometheus 를 scrape 한다", "Kafka 가 Prometheus 로 전송한다", "Vector 가 수신 포트를 열어 두고, Prometheus 가 `remote_write` 로 그곳에 메트릭을 **밀어 넣는(push)** 방식이다", "Prometheus 가 Vector 의 디스크를 마운트한다"]', 2, 'Prometheus 의 기본은 pull 이지만 remote_write 는 외부 시스템으로 샘플을 **push** 하는 기능입니다. federation(pull)으로 가져온 뒤, 가공한 결과를 Vector 로 push 하는 구성이 흔합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 5, 'Vector 의 3단계 구조 알기', 'Vector 설정의 기본 구성 요소 세 가지 순서로 알맞은 것은 무엇일까요?', 'Logstash 의 input → filter → output 과 같은 구조입니다.', NULL, NULL, '[]', 'choice', '["source → transform → sink", "sink → source → transform", "transform → source → sink", "input → output → filter"]', 0, 'source 는 데이터 수집(여기서는 Prometheus remote_write 수신), transform 은 가공(filter, VRL, reduce 등, 선택), sink 는 전달(Kafka 등)입니다. Vector 는 로그뿐 아니라 메트릭도 같은 단위로 다룹니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 6, 'reduce 가 필요한 이유', 'Prometheus 는 같은 노드의 `cpu_total`, `cpu_iowait`, `cpu_cores` 를 **별개의 시계열**로 보냅니다. Vector 의 **reduce** 를 쓰는 이유는 무엇일까요?', 'Kafka 에는 노드 하나당 메시지 하나로 보내고 싶습니다.', NULL, NULL, '[]', 'choice', '["메시지를 더 많이 만들기 위해서이다", "데이터를 암호화하기 위해서이다", "시계열을 삭제하기 위해서이다", "같은 노드(또는 VM)의 여러 이벤트를 식별자(merge key)로 묶어 **하나의 메시지로 합치기 위해서**이다"]', 3, '`merge_key` 로 그룹핑하고 필드별 병합 규칙(예: `max`)으로 합칩니다. 그러면 소비 쪽(Logstash, 대시보드)이 노드당 한 건의 완성된 데이터를 받습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 7, 'ends_when 과 expire_after 알기', 'reduce 에 `ends_when`(필요한 필드가 모두 모이면 즉시 완료)과 `expire_after_ms`(20초 안에 안 모이면 강제 완료)를 함께 두는 이유는 무엇일까요?', '스크랩 주기 안에 모든 조각이 모이지 않을 수도 있습니다.', NULL, NULL, '[]', 'choice', '["둘은 같은 기능이라 하나만 있으면 된다", "`ends_when` 은 다 모였을 때 **기다리지 않고 바로 보내는** 최적화이고, `expire_after` 는 일부 조각이 끝내 오지 않을 때 **무한정 기다리지 않게** 하는 안전장치이다", "expire 는 메시지를 영구 삭제하기 위해서이다", "ends_when 은 Vector 를 종료시키기 위해서이다"]', 1, 'expire 만 쓰면 모든 조각이 모여도 시간까지 기다려 지연이 생기고, ends_when 만 쓰면 조각이 빠졌을 때 영원히 완료되지 않습니다. 둘을 함께 써서 지연과 안전을 모두 챙깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 8, '토픽을 나눠 보내는 이유', '컨테이너·노드·VM 메트릭을 **서로 다른 Kafka 토픽**으로 나눠 보냅니다. 이점으로 알맞은 것은 무엇일까요?', '소비하는 쪽의 처리 방식과 보관 정책이 종류마다 다를 수 있습니다.', NULL, NULL, '[]', 'choice', '["토픽을 나누면 Kafka 가 메시지를 삭제한다", "토픽 하나에는 한 종류만 저장할 수 있어서이다", "종류별로 컨슈머·보관 기간·파티션 수를 따로 정할 수 있고, 한 종류의 폭주나 장애가 다른 종류에 덜 영향을 준다", "컨슈머를 쓸 수 없게 만들기 위해서이다"]', 2, '토픽은 소비·보관·확장의 단위입니다. 종류별로 나누면 컨테이너 메트릭이 폭증해도 노드·VM 토픽의 소비는 영향이 적고, 각자 retention 도 달리할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 9, '프록시가 HTTP 요청을 HTTPS 로 중계하는 방식', 'Prometheus 는 `http://proxy.example.com:8080` 으로 보내는데 실제 대상은 `https://target.example.com:443` 입니다. 중간의 프록시(HAProxy)가 하는 일로 알맞은 것은 무엇일까요?', '한쪽은 평문, 한쪽은 TLS 입니다. 이름(도메인)으로 라우팅하는 대상에서는 Host 가 중요합니다.', NULL, NULL, '[]', 'choice', '["HAProxy 는 토큰을 새로 발급한다", "HAProxy 가 메트릭을 직접 계산한다", "HAProxy 는 DNS 서버 역할을 한다", "프록시가 HTTP 요청을 받아 **HTTPS 로 변환해 대상으로 연결**하고, SNI 와 Host 헤더를 알맞게 넣어 준다"]', 3, '도메인으로 라우팅하는 대상(Ingress, 가상 호스트)은 요청의 Host/SNI 로 어느 서비스인지 판단합니다. 프록시가 이를 넣어 주지 않으면 엉뚱한 곳으로 가거나 거부됩니다. 프록시를 거치게 하려면 클라이언트가 도메인을 프록시 IP 로 풀어야 합니다(`/etc/hosts` 나 DNS).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 10, '인증이 필요한 scrape 가 403 일 때 원인', 'Prometheus 가 bearer 토큰이 필요한 대상을 scrape 하는데 **403 Forbidden** 이 납니다. 토큰 파일은 존재하고 내용도 맞는데, 가장 먼저 확인할 것은 무엇일까요?', 'Prometheus 는 어떤 사용자로 실행되고 있을까요?', NULL, NULL, '[]', 'choice', '["토큰 파일의 **소유자·권한**: Prometheus 를 실행하는 사용자(`prometheus`)가 읽을 수 있어야 한다. root 소유에 `600` 이면 읽기에 실패한다", "토큰 파일 이름이 너무 길다", "Kafka 토픽이 없다", "HAProxy 의 `balance` 설정이 틀렸다"]', 0, '파일 내용이 맞아도 Prometheus 프로세스가 읽지 못하면 빈 토큰으로 요청해 403 이 납니다. 해결은 파일을 `prometheus:prometheus` 소유에 `640` 정도로 맞추는 것입니다. (파일 권한은 리눅스 권한 세트에서 연습했던 내용입니다.)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 11, '프록시를 거치는 scrape 실패 진단 순서 놓기', '프록시를 거쳐 대상을 scrape 하는 Prometheus 가 실패할 때 **가까운 곳에서 먼 곳** 순서로 진단 순서를 놓으세요.', '내 서버의 DNS, 중간 프록시, 원천 직접 호출, 마지막으로 Prometheus 화면입니다.', NULL, NULL, '[]', 'order', '["프록시 서버에서 대상으로 직접 curl 해서 HTTP 200 인지(400/403 이면 토큰 문제) 확인한다", "Prometheus UI 의 targets 화면에서 상태와 오류 메시지를 확인한다", "Prometheus 서버의 `/etc/hosts` 와 실제 연결 테스트로 올바른 IP 로 보내는지 확인한다", "프록시가 해당 포트에서 LISTEN 중인지, 로그에 요청이 들어오는지 확인한다"]', NULL, '**hosts·연결 → 프록시 LISTEN·로그 → 프록시에서 대상으로 직접 호출 → targets 화면** 입니다. 직접 호출이 200 이면 프록시 설정, 400/403 이면 토큰 쪽 문제로 범위가 좁혀집니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 11);
