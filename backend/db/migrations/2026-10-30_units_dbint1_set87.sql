-- Git 세트 87. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set87.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 20, '미들웨어', '데이터베이스', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 20);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 87, 'DB 내부 이해: 격리 수준, MVCC, 로그, 인덱스, EXPLAIN', '데이터베이스가 동시성과 장애 복구를 어떻게 처리하는지 InnoDB 기준으로 정리합니다. 트랜잭션 격리 수준과 dirty·non-repeatable·phantom read, Read View 와 MVCC, undo·redo·binlog 로그와 WAL, 크래시 복구 시 2단계 커밋, 복합 인덱스의 leftmost prefix 와 EXPLAIN 읽기를 문제로 익힙니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 87);
UPDATE quest_set SET display_order = 547, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🧬' WHERE id = 87;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 1, '격리 수준의 의미', '트랜잭션 **격리 수준**이 높아질수록 어떤 변화가 생길까요?', '일관성과 동시성은 맞바꿈 관계입니다.', NULL, NULL, '[]', 'choice', '["일관성과 동시성이 모두 높아진다", "동시성만 높아지고 일관성은 낮아진다", "다른 트랜잭션의 변경이 덜 보여 **일관성은 높아지지만 동시성은 낮아진다**", "격리 수준은 성능과 무관하다"]', 2, '격리 수준은 "트랜잭션이 다른 트랜잭션의 변경을 얼마나 볼 수 있는가"를 정합니다. READ UNCOMMITTED → READ COMMITTED → REPEATABLE READ → SERIALIZABLE 순으로 높아집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 2, 'dirty read', '**dirty read** 는 어떤 현상일까요?', '"더럽다"는 아직 확정되지 않았다는 뜻입니다.', NULL, NULL, '[]', 'choice', '["다른 트랜잭션이 **커밋하지 않은** 변경을 읽는 것이다 (그 트랜잭션이 롤백하면 없던 데이터를 읽은 셈이 된다). READ UNCOMMITTED 에서만 발생한다", "커밋된 변경을 읽는 것이다", "같은 쿼리의 결과 행 수가 달라지는 것이다", "디스크가 가득 차서 읽기가 실패하는 것이다"]', 0, '실무에서는 거의 쓰이지 않는 수준입니다. 커밋된 변경만 읽는 READ COMMITTED 부터가 현실적인 선택입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 3, 'non-repeatable read 와 phantom read 의 차이', '같은 트랜잭션에서 같은 조건으로 두 번 조회했을 때, **기존 행의 값이 바뀌어** 있으면 무슨 현상이고, **행 수 자체가 달라지면** 무슨 현상일까요?', '값이 바뀌는 것과 행이 생기거나 사라지는 것은 다릅니다.', NULL, NULL, '[]', 'choice', '["값이 바뀌면 phantom read, 행 수가 바뀌면 non-repeatable read", "둘 다 dirty read 이다", "둘 다 같은 현상의 다른 이름이다", "기존 행의 값 변경은 non-repeatable read, 새 행의 출현·소멸(행 수 변화)은 phantom read 이다"]', 3, 'non-repeatable read 는 UPDATE 로, phantom read 는 INSERT/DELETE 로 생깁니다. READ COMMITTED 까지 non-repeatable read 가 생기고 REPEATABLE READ 부터 방지되며, phantom 은 SERIALIZABLE 에서 막힙니다(InnoDB 는 gap lock 으로 REPEATABLE READ 에서도 대부분 방어).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 4, 'READ COMMITTED 와 REPEATABLE READ 의 차이', '둘은 모두 MVCC 를 쓰는데, **차이는 Read View 를 언제 만드느냐**입니다. 알맞은 설명은 무엇일까요?', '한쪽은 쿼리마다, 한쪽은 트랜잭션에서 한 번입니다.', NULL, NULL, '[]', 'choice', '["READ COMMITTED 는 트랜잭션 시작 시 한 번, REPEATABLE READ 는 쿼리마다 만든다", "READ COMMITTED 는 **쿼리를 실행할 때마다** Read View 를 새로 만들고, REPEATABLE READ 는 **트랜잭션 시작 시 한 번** 만들어 재사용한다 (그래서 같은 SELECT 를 반복해도 결과가 같다)", "둘은 Read View 를 만들지 않는다", "둘은 락 방식만 다르다"]', 1, 'MySQL InnoDB 의 기본값은 REPEATABLE READ, Oracle 의 기본값은 READ COMMITTED 입니다. 같은 쿼리를 두 번 실행했는데 결과가 다르다면 Read View 가 고정되지 않은 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 5, 'MVCC 가 해결하는 문제', '**MVCC(다중 버전 동시성 제어)** 를 쓰는 이유로 알맞은 것은 무엇일까요?', '읽기와 쓰기가 서로 기다리지 않게 합니다.', NULL, NULL, '[]', 'choice', '["락을 더 많이 걸기 위해서이다", "디스크 공간을 줄이기 위해서이다", "데이터의 이전 버전을 유지해 두고 **읽기는 락 없이 이전 버전을 보여 주며, 쓰기는 새 버전을 만들어** 읽기와 쓰기가 서로 블로킹하지 않게 하기 위해서이다", "쓰기를 금지하기 위해서이다"]', 2, 'InnoDB 는 행마다 마지막으로 수정한 트랜잭션 ID(`DB_TRX_ID`)와 이전 버전을 가리키는 포인터(`DB_ROLL_PTR`)를 숨겨 두고, undo log 체인을 따라가며 Read View 에 보이는 버전을 찾습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 6, 'undo log 의 두 가지 역할', 'InnoDB 의 **undo log** 는 무엇을 위해 쓰일까요?', '"되돌리기"와 "과거 버전 읽기"입니다.', NULL, NULL, '[]', 'choice', '["수정 전 값을 보관해 **ROLLBACK 시 원상복구**하고, MVCC 에서 **과거 버전을 읽을 때** 따라가는 데 쓰인다", "커밋된 변경을 디스크에 보장한다", "복제본으로 변경을 전달한다", "쿼리 실행 계획을 저장한다"]', 0, 'DML 실행 시점에 데이터 페이지를 바꾸기 전에 기록됩니다. 더 이상 참조하는 트랜잭션이 없으면 purge 가 정리합니다. 아주 오래 열린 트랜잭션이 있으면 undo 가 쌓여 공간이 커질 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 7, 'redo log 와 WAL', '**WAL(Write-Ahead Logging)** 원칙을 가장 정확하게 설명한 것은 무엇일까요?', '로그와 데이터 중 무엇이 먼저일까요?', NULL, NULL, '[]', 'choice', '["데이터를 먼저 쓰고 로그는 나중에 쓴다", "로그를 아예 쓰지 않는다", "로그는 복제 전용이라 복구에 쓰이지 않는다", "데이터 페이지를 디스크에 쓰기 **전에** 변경 로그를 **먼저** 기록한다. 서버가 죽어도 redo log 를 재생해 커밋된 변경을 복구할 수 있다"]', 3, '디스크 쓰기는 원자적이지 않아 페이지를 쓰는 도중 죽으면 깨질 수 있습니다. COMMIT 완료는 "redo log 가 fsync 된 시점"이지 데이터 파일이 바뀐 시점이 아닙니다. 데이터 페이지(dirty page)는 나중에 백그라운드로 flush 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 8, 'dirty page', 'InnoDB 에서 **dirty page** 는 무엇일까요?', 'COMMIT 때 생기는 것이 아닙니다.', NULL, NULL, '[]', 'choice', '["COMMIT 후에만 생기는 페이지이다", "Buffer Pool(메모리)에서 수정되었지만 **아직 디스크에 반영되지 않은** 페이지로, 쿼리가 실행되어 페이지가 바뀌는 시점에 이미 생긴다", "디스크에서 삭제된 페이지이다", "바이너리 로그 파일의 다른 이름이다"]', 1, '변경 내용은 redo log 에 먼저 기록되어 있어서 dirty page 가 디스크에 쓰이기 전에 서버가 죽어도 복구됩니다. 쓰기를 모아서 나중에 쓰는 write-behind 전략이라 빠르지만, 로그가 없다면 유실 위험이 있는 구조입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 9, 'InnoDB 커밋 시 2단계 순서 놓기', 'redo log 와 binlog 가 **모두** 일관되게 기록되도록 InnoDB 가 커밋할 때 쓰는 내부 2단계 커밋의 순서를 **앞에서 뒤**로 놓으세요.', 'prepare → binlog → commit 순서입니다.', NULL, NULL, '[]', 'order', '["redo log 의 상태를 commit 으로 바꾸고 fsync 한 뒤 클라이언트에 완료를 응답한다", "redo log 에 \\"prepare\\" 상태로 기록한다 (아직 확정 아님)", "binlog 에 트랜잭션 이벤트를 기록하고 fsync 한다"]', NULL, '**redo prepare → binlog 기록 → redo commit** 입니다. 둘 중 하나만 기록된 채 크래시가 나면 마스터와 슬레이브가 달라지므로 이 순서가 필요합니다. 크래시 복구에서는 redo 가 prepare 이고 binlog 에 그 트랜잭션이 있으면 커밋으로 인정하고, 없으면 롤백합니다.', '[1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 10, 'binlog 기록 여부가 커밋 인정의 기준인 이유', '크래시 복구에서 redo log 가 **prepare** 상태이고 binlog 에 그 트랜잭션이 **있으면** 커밋으로 처리합니다. 이유로 알맞은 것은 무엇일까요?', '복제본에는 이미 전달되었을 수 있습니다.', NULL, NULL, '[]', 'choice', '["binlog 까지 기록되었다면 이미 슬레이브로 전파됐을 수 있으므로, 롤백하면 마스터와 슬레이브가 어긋나기 때문에 커밋으로 처리해 일관성을 유지한다", "binlog 는 데이터 파일이라 항상 우선이기 때문이다", "redo log 는 믿을 수 없기 때문이다", "커밋 여부와 상관없이 항상 롤백하기 때문이다"]', 0, '두 로그의 일관성이 복제 정합성의 핵심입니다. CDC(Debezium)도 binlog 를 읽으므로 같은 기준 위에서 동작합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 11, '복합 인덱스의 leftmost prefix', '복합 인덱스 `(A, B, C)` 가 있을 때 인덱스를 **온전히 활용할 수 있는** 조건은 무엇일까요?', '맨 왼쪽 컬럼부터 순서대로여야 합니다.', NULL, NULL, '[]', 'choice', '["C 만 조건으로 걸어도 항상 활용된다", "`A` 만, `A, B`, 또는 `A, B, C` 를 조건으로 거는 경우 (B 나 C 만 단독으로 걸면 인덱스를 활용하지 못한다)", "B, C 만 걸어도 활용된다", "컬럼 순서는 아무 상관이 없다"]', 1, '인덱스는 맨 왼쪽 컬럼부터 정렬되어 있어 중간을 건너뛰면 정렬 구조를 쓸 수 없습니다. 그래서 자주 쓰는 조건 순서에 맞춰 컬럼 순서를 정합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 12, '등치 조건과 범위 조건의 배치', '`WHERE status = ''ACTIVE'' AND created_at BETWEEN ... AND fee >= ...` 쿼리를 위한 복합 인덱스에서 **컬럼 배치 원칙**으로 알맞은 것은 무엇일까요?', '범위 조건 뒤의 컬럼은 정렬 순서가 보장되지 않습니다.', NULL, NULL, '[]', 'choice', '["범위 조건 컬럼을 맨 앞에 둔다", "순서는 항상 컬럼 이름의 알파벳순이다", "등치 조건은 인덱스에 넣지 않는다", "**등치(=) 조건 컬럼을 앞에**, 범위 조건 컬럼을 뒤에 둔다. 범위 조건 뒤에 오는 컬럼은 인덱스로 찾지 못하고 범위를 읽은 뒤 걸러내는 방식이 된다"]', 3, '다만 최적의 순서는 쿼리 패턴과 값의 분포(카디널리티)에 따라 달라질 수 있으므로, 규칙을 외워 적용하기보다 실제 쿼리로 EXPLAIN 을 확인해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 13, 'EXPLAIN 읽기', '`EXPLAIN` 결과에서 **`type: ALL`**, **`key: NULL`**, **`rows`** 가 테이블 전체 행 수에 가깝습니다. 어떤 신호일까요?', '어떤 인덱스도 쓰지 않고 있습니다.', NULL, NULL, '[]', 'choice', '["인덱스를 쓰지 못하고 테이블 전체를 훑는 **풀 스캔**이다. 조건에 맞는 인덱스를 만들거나 복합 인덱스의 컬럼 순서를 점검한다", "인덱스를 완벽하게 사용 중이라는 뜻이다", "쿼리가 실행되지 않았다는 뜻이다", "캐시에서 읽고 있다는 뜻이다"]', 0, '`type` 이 `ref`·`range`·`const` 이면 인덱스를 활용하는 것이고, `key` 가 가리키는 인덱스가 있어도 `rows` 가 크면 그 인덱스가 조건을 충분히 좁히지 못하는 것입니다. 개선 전후를 비교할 때는 데이터 규모, 쿼리 파라미터, 워밍업 상태를 같게 해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 14, '오래 열린 트랜잭션의 영향', '트랜잭션을 **시작해 놓고 오래 커밋하지 않으면** InnoDB 에서 어떤 문제가 생길 수 있을까요?', '과거 버전을 참조하는 트랜잭션이 있으면 정리를 못 합니다.', NULL, NULL, '[]', 'choice', '["아무 영향이 없다", "자동으로 롤백되어 undo 가 줄어든다", "그 트랜잭션이 참조하는 과거 버전 때문에 undo log 와 delete-marked 행을 purge 하지 못해 **undo 공간과 히스토리가 계속 쌓이고** 성능이 떨어질 수 있다", "redo log 가 즉시 삭제된다"]', 2, 'DELETE 된 행도 과거 시점을 읽는 트랜잭션에게는 필요하므로 purge 는 "참조하는 트랜잭션이 없을 때"만 지웁니다. 그래서 배치·리포트 쿼리의 긴 트랜잭션이나 커밋 누락이 운영 문제의 흔한 원인입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 14);
