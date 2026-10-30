-- 미들웨어 세트 101. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set101.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 27, '미들웨어', '동시성·이벤트', 90 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 27);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 101, '이벤트 스트리밍 기본기: 컨슈머 그룹, 오프셋, 전달 보장, 순서', '이벤트 스트리밍(Kafka)을 안전하게 쓰기 위한 기본기를 익힙니다. 컨슈머 그룹과 리밸런싱, 오프셋 커밋과 자동 커밋의 함정, lag 읽기, at-least-once·at-most-once·exactly-once, 파티션 단위 순서와 키 설계, 멱등한 처리, DLQ, Outbox 패턴을 빈칸·순서·객관식으로 다룹니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 101);
UPDATE quest_set SET display_order = 561, unit_id = (SELECT id FROM unit WHERE id = 27), icon = '🌊' WHERE id = 101;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 1, '컨슈머 그룹 점검 명령 채우기', '① 컨슈머 그룹 `orders` 의 **파티션별 현재 오프셋과 lag** 를 보고, ② 토픽 `orders` 를 **처음 메시지부터** 읽어 보는 명령입니다. 빈칸을 채우세요.', '그룹의 상세는 describe, 처음부터는 from-beginning 입니다.', NULL, NULL, '[]', 'fill', '["describe", "from-beginning", "list", "delete", "offsets"]', NULL, '`--describe` 는 파티션별 `CURRENT-OFFSET`(읽은 위치), `LOG-END-OFFSET`(끝 위치), `LAG`(차이)를 보여 줍니다. `--from-beginning` 은 저장된 맨 앞 메시지부터 읽으며, 실제 처리와는 별개로 **내용을 확인할 때** 씁니다.', '[0, 1]', 'kafka-consumer-groups.sh --bootstrap-server broker:9092 --{0} --group orders
kafka-console-consumer.sh --bootstrap-server broker:9092 --topic orders --{1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 2, '전달 보장 수준 짝 맞추기', '메시지를 **처리한 뒤** 오프셋을 커밋하면 장애 시 같은 메시지를 다시 받을 수 있고(유실 없음), **커밋한 뒤** 처리하면 장애 시 그 메시지가 사라질 수 있습니다(중복 없음). 각 방식의 이름을 채우세요.', '"적어도 한 번"은 중복 가능, "많아야 한 번"은 유실 가능입니다.', NULL, NULL, '[]', 'fill', '["at-least-once", "at-most-once", "exactly-once", "never"]', NULL, '`at-least-once` 는 **유실은 없지만 중복이 가능**해, 소비자를 **멱등**하게 만들어 중복을 흡수합니다(가장 흔한 선택). `at-most-once` 는 중복은 없지만 유실이 가능합니다. `exactly-once` 는 정확히 한 번 처리한 것처럼 보이게 하는 것으로, 범위와 조건이 있습니다.', '[0, 1]', '처리 → 커밋:  {0}
커밋 → 처리:  {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 3, '순서 보장 범위 채우기', '같은 **키**를 가진 메시지는 같은 **파티션**으로 가서 그 안에서 순서가 보장됩니다. 문장의 빈칸을 채우세요.', '순서는 토픽 전체가 아니라 더 작은 단위에서 보장됩니다.', NULL, NULL, '[]', 'fill', '["키(key)", "파티션", "토픽", "오프셋"]', NULL, 'Kafka 의 순서 보장은 **파티션 단위**입니다. 한 주문의 이벤트(생성→결제→배송) 순서가 중요하면 주문 ID 를 키로 보내 같은 파티션에 모읍니다. 키를 바꾸거나 파티션 수를 늘리면 같은 키의 파티션이 달라질 수 있어 순서가 깨질 수 있습니다.', '[0, 1]', '같은 {0} 의 메시지는 같은 {1} 으로 가므로 그 안에서 순서가 유지된다', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 4, '중복에 안전한 메시지 처리 순서', '`at-least-once` 로 메시지를 소비할 때, 장애가 나도 **결과가 틀어지지 않게** 한 건을 처리하는 흐름을 **앞에서 뒤**로 놓으세요.', '가져오고, 이미 처리했는지 보고, 처리하고, 마지막에 커밋합니다.', NULL, NULL, '[]', 'order', '["처리가 끝난 뒤에 오프셋을 커밋한다", "메시지의 고유 ID 로 이미 처리했는지 확인한다 (이미 했으면 건너뛴다)", "결과를 저장하면서 처리한 ID 도 함께 기록한다", "브로커에서 메시지를 가져온다 (poll)"]', NULL, '**poll → 중복 확인 → 처리·결과와 ID 기록 → 커밋** 입니다. 커밋 직전에 죽으면 같은 메시지가 다시 오지만, 처리한 ID 가 기록되어 있어 건너뜁니다. 결과 저장과 ID 기록은 한 트랜잭션으로 묶는 것이 안전합니다.', '[3, 1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 5, '리밸런싱이 일어나는 과정', '컨슈머 그룹에 **새 컨슈머가 합류**했을 때 일어나는 일을 **앞에서 뒤**로 놓으세요.', '합류 → 감지 → 재배정 → 재개 순서입니다.', NULL, NULL, '[]', 'order', '["컨슈머가 새로 배정된 파티션의 마지막 커밋 오프셋부터 읽기를 재개한다", "그룹 코디네이터가 멤버 변화를 감지해 리밸런싱을 시작한다", "새 컨슈머가 같은 그룹 ID 로 그룹에 합류한다", "파티션 소유권이 컨슈머들에게 다시 나뉜다"]', NULL, '**합류 → 감지 → 파티션 재배정 → 마지막 커밋 오프셋부터 재개** 입니다. 리밸런싱 동안은 소비가 잠시 멈추므로, 컨슈머가 자주 죽고 살아나면 소비가 계속 끊기는 "리밸런싱 폭주"가 생깁니다. 커밋하지 않은 메시지는 새 소유자가 다시 처리합니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 6, '처리 실패 메시지를 DLQ 로 보내는 흐름', '특정 메시지가 **계속 처리에 실패**합니다. 전체 소비를 막지 않고 처리하는 흐름을 **앞에서 뒤**로 놓으세요.', '재시도 → 한도 초과 → 격리 → 사후 처리 순서입니다.', NULL, NULL, '[]', 'order', '["원인을 분석하고 고친 뒤 DLQ 의 메시지를 다시 투입한다", "처리 실패를 감지하고 정해 둔 횟수만큼 재시도한다", "재시도가 모두 실패하면 메시지를 DLQ(Dead Letter Queue) 토픽으로 옮기고 다음 메시지를 계속 처리한다", "DLQ 에 쌓인 건수를 모니터링하고 알림을 보낸다"]', NULL, '**재시도 → DLQ 격리 → 모니터링·알림 → 원인 수정 후 재투입** 입니다. 문제 메시지 하나 때문에 뒤의 정상 메시지가 모두 막히는(poison pill) 일을 막습니다. 재투입하려면 처리가 멱등해야 안전합니다.', '[1, 2, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 7, '컨슈머 수와 파티션 수', '토픽의 파티션이 **3개**인데 같은 그룹의 컨슈머를 **5개** 띄웠습니다. 어떻게 될까요?', '한 파티션은 같은 그룹 안에서 한 컨슈머만 읽습니다.', NULL, NULL, '[]', 'choice', '["5개가 파티션을 쪼개 나눠 읽는다", "메시지가 5배로 복제된다", "3개 컨슈머가 파티션을 하나씩 맡고, 나머지 2개는 할당받지 못해 **놀게** 된다. 처리량을 늘리려면 파티션 수도 늘려야 한다", "오류가 나서 그룹이 멈춘다"]', 2, '같은 그룹 안에서는 파티션 수가 병렬 처리의 상한입니다. 반대로 **다른 그룹**은 각자 전체 메시지를 받습니다(팬아웃). 파티션 수는 늘리기는 쉬워도 줄일 수 없고, 키 기반 순서에 영향을 주므로 처음에 여유를 두고 정합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 8, '자동 커밋의 함정', '`enable.auto.commit=true` 로 두었는데, 컨슈머가 메시지를 **받은 직후 처리 중에 죽자** 그 메시지가 사라진 것처럼 처리되지 않았습니다. 왜일까요?', '커밋은 "여기까지 읽었다"는 표시입니다.', NULL, NULL, '[]', 'choice', '["토픽의 보관 기간이 끝났다", "자동 커밋이 **처리 완료와 상관없이 일정 주기**로 오프셋을 올려, 처리 전에 커밋되어 버렸다. 처리 후 수동 커밋(또는 처리 완료를 보장하는 설정)을 쓴다", "브로커가 메시지를 삭제했다", "파티션이 줄어들었다"]', 1, '자동 커밋은 편하지만 처리 완료를 알지 못합니다. 유실이 허용되지 않으면 `enable.auto.commit=false` 로 두고 처리 성공 후 `commitSync` 하는 방식이 일반적입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 9, 'lag 이 계속 늘어날 때', '컨슈머 그룹의 `LAG` 가 몇 시간째 **계속 증가**합니다. 가장 알맞은 해석과 대응은 무엇일까요?', 'lag = 끝 위치 - 읽은 위치 입니다.', NULL, NULL, '[]', 'choice', '["생산 속도가 소비 속도보다 빠르다. 컨슈머를 (파티션 수 한도 안에서) 늘리거나, 처리 로직의 병목(느린 DB 호출 등)을 줄인다", "브로커 디스크가 줄어드는 중이라 정상이다", "토픽을 삭제하면 해결된다", "컨슈머 그룹 이름을 바꾸면 lag 이 사라진다"]', 0, '일시적 급증 뒤 줄어든다면 정상, 계속 늘면 소비가 못 따라가는 것입니다. 컨슈머 로그와 처리 시간, 리밸런싱이 잦은지도 함께 봅니다. 그룹 ID 를 바꾸면 lag 이 사라진 듯 보여도 읽기 위치가 달라져 유실이나 중복이 생깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 10, 'Outbox 패턴이 필요한 이유', '주문을 DB 에 저장한 뒤 Kafka 로 이벤트를 보내는 코드가 있습니다. DB 저장은 성공했는데 **발행 직전에 서버가 죽으면** 이벤트가 사라집니다. 이를 해결하는 Outbox 패턴의 핵심은 무엇일까요?', '두 시스템에 동시에 쓰는 것은 원자적이지 않습니다.', NULL, NULL, '[]', 'choice', '["발행을 먼저 하고 DB 저장은 나중에 한다", "주문 저장과 같은 **DB 트랜잭션 안에서 outbox 테이블에도 이벤트를 기록**하고, 별도 프로세스(또는 CDC)가 그 테이블을 읽어 Kafka 로 발행한다", "이벤트를 발행하지 않는다", "DB 를 두 개로 나눈다"]', 1, 'DB 와 브로커 둘에 한꺼번에 쓰는 일은 한쪽만 성공할 수 있습니다(이중 쓰기 문제). Outbox 는 DB 하나에만 원자적으로 쓰고, 발행은 나중에 **at-least-once** 로 보장하므로 소비자는 멱등해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 11, 'exactly-once 의 한계', 'Kafka 의 멱등 프로듀서와 트랜잭션으로 "정확히 한 번"을 켰습니다. 그런데 소비자가 메시지로 **외부 DB 를 갱신**하는 곳에서 중복 반영이 생겼습니다. 이유로 알맞은 것은 무엇일까요?', '보장은 Kafka 안에서의 읽기-처리-쓰기 범위입니다.', NULL, NULL, '[]', 'choice', '["exactly-once 의 보장은 Kafka 내부(토픽 간 읽기·쓰기)에 한정되어, 외부 시스템 반영은 재처리 시 중복될 수 있다. 소비자 쪽을 멱등하게 만들어야 한다", "DB 가 너무 느리다", "exactly-once 는 원래 동작하지 않는다", "파티션이 하나라서 그렇다"]', 0, '외부 시스템(DB, API, 메일)에 대한 부작용은 Kafka 가 되돌릴 수 없습니다. 실무에서는 `at-least-once` + 멱등 처리(유니크 키, upsert)로 "결과가 한 번 처리한 것과 같게" 만드는 방식이 많이 쓰입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 101, 12, '키 없이 보내면 순서는?', '주문 이벤트(생성, 결제, 취소)를 **키 없이** 여러 파티션 토픽에 보냈더니 소비자가 "취소"를 "결제"보다 먼저 받는 경우가 생겼습니다. 올바른 개선은 무엇일까요?', '순서가 필요한 이벤트는 한 파티션에 모여야 합니다.', NULL, NULL, '[]', 'choice', '["주문 ID 를 **메시지 키**로 지정해 같은 주문의 이벤트가 같은 파티션으로 가게 한다", "파티션 수를 더 늘린다", "컨슈머를 더 늘린다", "메시지를 압축한다"]', 0, '키가 없으면 메시지가 여러 파티션으로 흩어져 파티션 간 순서는 보장되지 않습니다. 모든 이벤트의 전체 순서가 필요하면 파티션을 1개로 두는 방법도 있지만 처리량이 제한되므로, 보통은 "관련 있는 것끼리 같은 키"로 설계합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 101 AND order_index = 12);
