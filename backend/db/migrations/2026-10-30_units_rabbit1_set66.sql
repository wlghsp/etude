-- Git 세트 66. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set66.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 19, '미들웨어', '메시징·CDC', 30 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 19);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 66, 'RabbitMQ 입문: Exchange·Queue·Binding과 안정적 전달', 'RabbitMQ(AMQP)의 Exchange·Queue·Binding·routing key 구조와 exchange 타입(direct, fanout, topic), ack 와 재전달, prefetch, 재시작에도 유지하는 durable·persistent, Dead Letter Exchange, 그리고 Kafka 와 어느 상황에 무엇을 쓰는지 문제로 정리합니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 66);
UPDATE quest_set SET display_order = 531, unit_id = (SELECT id FROM unit WHERE id = 19), icon = '🐰' WHERE id = 66;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 1, 'RabbitMQ 에서 메시지가 전달되는 흐름 놓기', 'producer 가 보낸 메시지가 consumer 에게 전달되는 AMQP 흐름을 **앞에서 뒤 순서**대로 놓으세요.', 'producer 는 큐 이름이 아니라 "어디에(Exchange) 어떤 키로" 보냅니다.', NULL, NULL, '[]', 'order', '["Queue 에 메시지가 쌓인다", "Exchange 가 Binding 과 routing key 를 보고 보낼 Queue 를 정한다", "consumer 가 Queue 에서 메시지를 받아 처리한다", "producer 가 Exchange 에 routing key 와 함께 메시지를 보낸다"]', NULL, '**producer → Exchange → (Binding + routing key) → Queue → consumer** 순서입니다. producer 는 Exchange 이름과 routing key 만 알면 되고, 어느 큐로 가는지는 몰라도 됩니다. 라우팅 로직이 브로커 안에 있다는 것이 RabbitMQ(AMQP)의 특징입니다.', '[3, 1, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 2, 'producer 는 어디로 보내는지 알기', 'RabbitMQ 에서 producer 는 메시지를 **어디에** 보낼까요?', 'producer 는 큐를 직접 지정하지 않습니다.', NULL, NULL, '[]', 'choice', '["Queue 에 직접 보낸다", "consumer 에 직접 보낸다", "Exchange 에 보내고, Exchange 가 라우팅 규칙에 따라 Queue 로 전달한다", "디스크 파일에 쓰고 consumer 가 읽어 간다"]', 2, 'AMQP 에서 producer 는 **Exchange** 에 보냅니다. Exchange 가 타입(direct, fanout, topic, headers)과 Binding 규칙에 따라 메시지를 어떤 Queue 로 보낼지 결정합니다. (기본 Exchange 를 쓰면 큐 이름을 routing key 로 써서 큐에 직접 보내는 것처럼 보이지만, 실제로는 Exchange 를 거칩니다.)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 3, 'Exchange 타입 구분하기 (1)', 'routing key 가 **정확히 일치하는** Queue 로만 메시지를 보내는 Exchange 타입은 무엇일까요?', '네 가지 타입이 있습니다: direct, fanout, topic, headers.', NULL, NULL, '[]', 'choice', '["fanout", "topic", "headers", "direct"]', 3, '**direct** 는 routing key 가 Binding 의 키와 정확히 같을 때만 전달합니다. **fanout** 은 키와 상관없이 연결된 모든 큐로(브로드캐스트), **topic** 은 패턴 매칭, **headers** 는 메시지 헤더 값으로 라우팅합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 4, 'Exchange 타입 구분하기 (2)', '주문 이벤트를 **결제, 알림, 통계 서비스 세 곳이 모두** 받아야 합니다. 각 서비스가 자기 큐를 가지고 있고, 키와 관계없이 연결된 큐 **모두에게** 복사해 보내고 싶다면 어떤 Exchange 가 알맞을까요?', '브로드캐스트에 쓰는 타입입니다.', NULL, NULL, '[]', 'choice', '["fanout", "direct", "topic 의 `order.*` 패턴만", "headers"]', 0, '**fanout** 은 routing key 를 무시하고 바인딩된 **모든 큐**에 메시지를 복사해 보냅니다. 같은 메시지를 여러 서비스가 각자 독립적으로 받고 싶을 때 씁니다(각자 자기 큐를 가집니다).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 5, 'topic 패턴 읽기', 'topic Exchange 의 Binding 키가 `order.*` 입니다. 이 큐로 **전달되는** routing key 는 무엇일까요? (`*` 는 정확히 **한 단어**, `#` 는 0개 이상의 단어)', '`order.` 다음에 단어가 정확히 하나 와야 합니다.', NULL, NULL, '[]', 'choice', '["order.item.created", "order.created", "payment.created", "orders"]', 1, '`*` 는 점(`.`)으로 구분된 **단어 하나**와 맞습니다. `order.created` 는 맞지만 `order.item.created` 는 단어가 둘이라 맞지 않습니다(그 경우는 `order.#` 가 맞습니다). `payment.created` 와 `orders` 는 앞 단어가 다릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 6, 'Binding 이 무엇인지 알기', 'RabbitMQ 의 **Binding** 은 무엇일까요?', 'Exchange 와 Queue 사이를 이어 주는 설정입니다.', NULL, NULL, '[]', 'choice', '["메시지를 디스크에 저장하는 방식", "consumer 가 메시지를 받았다고 알리는 신호", "Exchange 와 Queue 를 연결하는 규칙 (\\"이 Exchange 에서 이 routing key 의 메시지는 저 Queue 로\\")", "브로커의 접속 포트"]', 2, 'Binding 은 Exchange 와 Queue 를 잇는 규칙입니다. Binding 이 없으면 Exchange 는 메시지를 보낼 곳이 없어 **버려질** 수 있습니다(라우팅되지 않은 메시지). 큐를 만들고 바인딩을 안 해서 메시지가 안 들어오는 것은 흔한 실수입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 7, 'ack 의 의미 알기', 'RabbitMQ 의 consumer 가 메시지를 받아 처리하던 중 **ack 를 보내기 전에 죽었습니다.** 이 메시지는 어떻게 될까요?', '브로커는 "처리 완료" 신호를 받아야 큐에서 지웁니다.', NULL, NULL, '[]', 'choice', '["큐에서 즉시 영구 삭제되어 사라진다", "자동으로 DLQ 로 간다", "다시 큐로 돌아가(requeue) 다른 consumer 에게 전달된다. 그래서 같은 메시지가 두 번 처리될 수 있어 처리 로직은 중복에 안전해야 한다", "브로커가 종료된다"]', 2, '수동 ack 모드에서 브로커는 **ack 를 받아야** 메시지를 지웁니다. consumer 연결이 끊기면 ack 받지 못한 메시지는 다시 큐에 넣어 다른 consumer 에게 전달합니다. 이것이 at-least-once(최소 한 번) 전달이고, 그래서 처리 로직을 멱등하게 만드는 것이 중요합니다. 처리에 실패해 되돌리고 싶으면 `nack` 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 8, 'prefetch 의 역할 알기', '느린 consumer 하나가 메시지를 한꺼번에 잔뜩 받아 쌓아 두고, 빠른 consumer 는 놀게 되는 문제를 줄이려면 어떤 설정을 조정할까요?', '한 consumer 에게 **ack 전 상태로 한 번에 보낼 수 있는 메시지 수**를 제한합니다.', NULL, NULL, '[]', 'choice', '["prefetch (QoS) 값을 작게 두어 ack 되지 않은 메시지를 한 번에 몇 개까지 받을지 제한한다", "Exchange 타입을 fanout 으로 바꾼다", "queue 를 durable 로 바꾼다", "routing key 를 길게 만든다"]', 0, '**prefetch** 를 1~수십 정도로 두면 브로커는 consumer 가 ack 하기 전에는 그 수 이상을 더 보내지 않습니다. 그래서 처리가 끝난 빠른 consumer 가 다음 메시지를 받아 부하가 고르게 분산됩니다. 값이 너무 크면 한 consumer 에 메시지가 쏠리고 너무 작으면 처리량이 떨어집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 9, '브로커가 재시작해도 메시지를 지키려면', 'RabbitMQ 브로커가 **재시작해도** 큐와 메시지가 남아 있게 하려면 어떻게 해야 할까요?', '큐도, 메시지도 각각 "남기겠다"고 표시해야 합니다.', NULL, NULL, '[]', 'choice', '["큐를 durable 로 선언하고, 메시지도 persistent(delivery_mode=2)로 발행한다", "Exchange 이름을 길게 짓는다", "consumer 를 두 개 이상 둔다", "ack 를 보내지 않는다"]', 0, '큐가 **durable** 이어야 큐 정의가 재시작 뒤에도 남고, 메시지가 **persistent** 여야 디스크에 기록됩니다. 둘 중 하나만 해서는 안 됩니다. 더 높은 안정성이 필요하면 quorum queue 로 여러 노드에 복제합니다. 다만 persistent 는 처리 속도에 비용이 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 10, 'Dead Letter Exchange 알기', 'consumer 가 `nack`(requeue 안 함) 한 메시지, TTL 이 만료된 메시지, 큐 길이 제한을 넘은 메시지를 **버리지 않고 따로 모아** 원인을 분석하고 싶습니다. RabbitMQ 의 기능은 무엇일까요?', 'Kafka 의 DLQ 와 같은 목적의 기능입니다.', NULL, NULL, '[]', 'choice', '["Dead Letter Exchange(DLX) — 위 사유로 죽은 메시지를 지정한 Exchange/Queue(DLQ)로 보낸다", "Fanout Exchange 하나만 만들면 된다", "prefetch 를 0 으로 둔다", "브로커를 재시작한다"]', 0, '큐에 `x-dead-letter-exchange` 를 지정하면 **nack(requeue=false), TTL 만료, 큐 길이 초과** 같은 사유의 메시지가 그 Exchange 로 넘어가 DLQ 에 쌓입니다. 재처리할 수 없는 poison message 가 정상 메시지 처리를 막는 것을 방지하고 원인 분석 자료로 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 11, 'RabbitMQ 와 Kafka 중 고르기', '다음 요구에 **더 알맞은 것은** 무엇일까요? "회원가입 시 이메일을 보내는 **작업 큐**. 한 번 보내면 끝이고, 실패한 작업은 따로 모아 다시 시도하고 싶다. 하루 수만 건 수준이다."', '"전달하고 끝" 이고 라우팅·재시도가 브로커의 일입니다.', NULL, NULL, '[]', 'choice', '["Kafka — 과거 이벤트를 다시 읽을 수 있어야 하기 때문에", "둘 다 부적합하다", "파일 서버가 알맞다", "RabbitMQ — 전달하고 끝나는 작업 큐에 맞고, DLX 로 실패 작업을 모아 다시 처리하기 쉽다"]', 3, 'RabbitMQ 는 "전달" 이 목적이라 이메일·알림 같은 **작업 큐**에 알맞고, 복잡한 라우팅과 DLX 를 브로커가 처리합니다. Kafka 는 이벤트를 로그처럼 쌓아 두고 여러 곳에서 **다시 읽는** 요구(데이터 파이프라인, 이벤트 재처리, 초고처리량)에 알맞습니다. "대용량이라서" 가 아니라 요구의 성격으로 고르는 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 12, 'RabbitMQ 의 기본 포트 알기', 'RabbitMQ 의 **AMQP 접속 포트**와 **관리 웹 UI(Management Plugin) 포트** 기본값은 각각 무엇일까요?', '응용 프로그램은 앞의 포트로 접속하고, 사람은 뒤의 포트로 브라우저 접속을 합니다.', NULL, NULL, '[]', 'choice', '["AMQP 15672, 관리 UI 5672", "AMQP 9092, 관리 UI 2181", "AMQP 5672, 관리 UI 15672", "AMQP 3306, 관리 UI 6379"]', 2, '기본값은 **AMQP 5672**, 관리 UI **15672** 입니다. (9092 는 Kafka 브로커, 2181 은 ZooKeeper, 3306 은 MariaDB/MySQL, 6379 는 Redis 의 기본 포트입니다.) 큐 쌓임, 연결, consumer 수 같은 상태는 관리 UI 에서 보는 것이 가장 빠릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 12);
