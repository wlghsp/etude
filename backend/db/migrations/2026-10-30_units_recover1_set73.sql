-- Git 세트 73. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set73.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 24, '미들웨어', '사내 장애 사례', 70 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 24);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 73, '장애 복구 절차 읽기: Galera 와 Kafka', 'Galera 노드 장애와 Kafka 브로커 장애를 복구하는 절차를 읽고 순서와 이유를 익힙니다. 단일 노드 복구 순서, 로그에서 볼 오류 패턴, SST 와 IST, 쿼럼 복구 뒤 노드를 하나씩 올리는 이유, ISR 확인, 강제 리더 선출(unclean)의 위험, 메타데이터 손상 시 백업 우선, 오프셋 초기화를 다룹니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 73);
UPDATE quest_set SET display_order = 572, unit_id = (SELECT id FROM unit WHERE id = 24), icon = '🩹' WHERE id = 73;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 1, 'Galera 노드 하나가 다운되었을 때 복구 순서 놓기', '3노드 Galera 에서 노드 하나가 다운되었습니다. 복구 절차를 **앞에서 뒤**로 놓으세요.', '먼저 상태를 보고, 원인을 찾고, 고치고, 올리고, 확인합니다.', NULL, NULL, '[]', 'order', '["다운된 노드를 재시작한다", "다른 노드에서 클러스터 상태와 다운된 노드를 확인한다", "`wsrep_cluster_size` 가 3 이고 `Synced` 인지 확인한다", "다운된 노드의 서비스 로그와 디스크·메모리를 확인한다", "`grastate.dat` 파일의 상태를 확인하고 필요하면 정리한다"]', NULL, '**상태 확인 → 서비스 로그·디스크·메모리 → `grastate.dat` → 재시작 → 클러스터 크기와 동기화 상태 확인** 순서입니다. 원인을 모른 채 재시작부터 하면 같은 오류로 다시 내려갈 수 있어서, 로그와 자원(디스크 가득, 메모리 부족)을 먼저 봅니다.', '[1, 3, 4, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 2, '로그에서 먼저 볼 오류 패턴', '다운된 Galera 노드가 올라오지 않을 때 서비스 로그(`journalctl -u mariadb`)에서 흔히 찾는 **원인 패턴**으로 알맞은 것은 무엇일까요?', '서버 자원과 포트 쪽입니다.', NULL, NULL, '[]', 'choice', '["InnoDB 오류, 포트 충돌, 디스크 부족 같은 기동 실패 원인", "Kibana 대시보드 설정 오류", "Kafka 토픽 이름 중복", "Istio Gateway 인증서 만료"]', 0, '로그에 나온 원인을 고치지 않고 재시작하면 반복해서 실패합니다. 디스크가 가득 찼는지(`df -h`), 메모리가 부족한지(`free -h`)도 같이 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 3, '쿼럼 복구 뒤 노드를 올리는 방법', '2대가 다운된 뒤 남은 노드를 Primary 로 살려 놓았습니다. 다운되었던 두 노드를 올리는 방법으로 알맞은 것은 무엇일까요?', '한꺼번에가 아니라 한 대씩, 상태를 보면서 합니다.', NULL, NULL, '[]', 'choice', '["두 노드를 동시에 시작해 시간을 줄인다", "**하나씩** 시작하고, 각각 클러스터에 합류해 동기화될 때까지 기다리고 확인한 뒤 다음 노드를 올린다", "데이터 디렉터리를 지우고 시작한다", "남은 노드를 재시작해 처음부터 다시 구성한다"]', 1, '합류하는 노드는 남은 노드로부터 데이터를 받아야(SST/IST) 하므로 동시에 여러 대가 합류하면 도너(데이터를 주는 노드)에 부하가 몰립니다. 한 대씩 `Synced` 를 확인하고 진행합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 4, 'SST 와 IST 구분하기', 'Galera 에서 **SST(State Snapshot Transfer)** 는 무엇일까요?', '뒤처진 노드에 데이터를 맞추는 두 가지 방식이 있습니다.', NULL, NULL, '[]', 'choice', '["쿼럼을 강제로 지정하는 명령이다", "AUTO_INCREMENT 를 재설정하는 방식이다", "새로 합류하거나 너무 뒤처진 노드에 도너 노드의 **전체 데이터를 복사**하는 방식이다 (조금만 뒤처졌으면 변경분만 받는 IST 를 쓴다)", "binlog 를 지우는 방식이다"]', 2, 'SST 는 전체 복사라서 시간이 오래 걸리고 도너 노드의 부하가 큽니다. 상태 값이 `Waiting for SST` 이면 전송 중입니다. 변경분만 받는 IST 가 가능하면 훨씬 빠르게 합류합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 5, '복구 후 검증하는 방법', 'Galera 노드 복구가 끝났다고 판단하려면 무엇을 확인할까요?', '클러스터 크기, 노드 상태, 그리고 필요하면 데이터 자체입니다.', NULL, NULL, '[]', 'choice', '["서비스가 켜져 있으면 끝이다", "`Uptime` 만 길면 정상이다", "로그 파일 크기가 줄었으면 정상이다", "`wsrep_cluster_size` 가 기대한 노드 수이고 `wsrep_local_state_comment` 가 `Synced` 이며, 필요하면 `CHECKSUM TABLE` 로 노드 간 데이터가 같은지 확인한다"]', 3, '`Synced` 는 최대 1~2분 걸릴 수 있습니다. 데이터 일관성이 중요하면 중요한 테이블의 `CHECKSUM TABLE` 값을 노드끼리 비교합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 6, 'Kafka 브로커 하나가 다운되었을 때 복구 순서 놓기', 'Kafka 브로커 한 대가 다운되었습니다. 복구 절차를 **앞에서 뒤**로 놓으세요.', '전체 상태를 보고, 로그와 저장소를 확인한 뒤, 재시작하고, 파티션 상태로 마무리합니다.', NULL, NULL, '[]', 'order', '["토픽 파티션의 Leader 와 ISR 을 확인한다", "다운된 브로커의 프로세스를 재시작한다", "모든 브로커의 상태를 확인한다", "브로커 로그를 확인한다", "메타데이터와 스토리지 손상 여부를 확인한다"]', NULL, '**전체 브로커 상태 → 로그 → 메타데이터·스토리지 확인 → 재시작 → 파티션 Leader·ISR 확인** 순서입니다. 마지막 단계에서 모든 파티션의 ISR 이 충분한지 확인해야 복구가 끝난 것입니다.', '[2, 3, 4, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 7, '복구 후 ISR 확인 기준', '브로커를 재시작한 뒤 `--describe` 로 파티션을 봅니다. 복제 factor 3, `min.insync.replicas=2` 인 토픽에서 **최소한** 어떤 상태여야 정상 복구일까요?', '쓰기를 받으려면 ISR 이 최소 몇 개여야 하는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["각 파티션의 ISR 이 최소 2개 이상 (가능하면 3개 모두 복귀)", "ISR 이 1개여도 충분하다", "ISR 이 0개여야 한다", "Leader 가 없어도 정상이다"]', 0, 'ISR 이 `min.insync.replicas` 미만이면 `acks=all` 쓰기가 거부됩니다. 재시작 직후에는 따라잡는 시간이 필요해 ISR 이 천천히 채워지므로 완전히 복귀할 때까지 지켜봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 8, '브로커 2대 이상 다운의 증상', '3대 중 **2대의 브로커가 다운**되었습니다. 나타나는 증상으로 알맞은 것은 무엇일까요?', 'ISR 이 줄어들면 쓰기와 읽기에 무슨 일이 생길까요?', NULL, NULL, '[]', 'choice', '["아무 증상 없이 정상 동작한다", "ISR 이 `min.insync.replicas` 아래로 떨어져 프로듀서가 쓰지 못하고, consumer 는 읽지 못해 lag 이 늘어난다", "디스크 사용량이 즉시 0 이 된다", "토픽이 자동으로 삭제된다"]', 1, '복구는 다운된 브로커를 **순차로** 재시작하는 것입니다. 한 대가 복귀하면 ISR 이 채워져 쓰기가 재개되는지 확인하고 다음 대를 올립니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 9, '파티션 Leader 가 없을 때의 위험', '복구 중 ISR 에 **남은 복제본이 없어서** 파티션 Leader 를 정할 수 없는 상태입니다. ISR 밖의 뒤처진 복제본을 Leader 로 **강제 선출**(unclean leader election)하면 어떤 일이 생길 수 있을까요?', '그 복제본은 최신 데이터를 갖고 있지 않을 수 있습니다.', NULL, NULL, '[]', 'choice', '["데이터 유실은 절대 없다", "메시지가 두 배로 늘어난다", "뒤처진 복제본에만 없는 메시지가 **영구 유실**될 수 있다. 서비스를 살리는 대신 데이터를 포기하는 마지막 수단이다", "브로커 CPU 가 낮아진다"]', 2, 'unclean 선출은 가용성을 얻는 대신 일관성(유실 없음)을 포기합니다. 가능하면 ISR 에 있던 복제본이 복귀하기를 기다리는 것이 안전하고, 강제 선출은 데이터 유실을 감수할 수 있을 때만 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 10, '메타데이터 손상 복구에서 가장 먼저 할 것', 'Kafka 메타데이터가 손상되어 전체를 정리하고 재시작하는 복구를 하려 합니다. 로그 정리처럼 **데이터를 잃을 수 있는 작업 전에** 가장 먼저 할 일은 무엇일까요?', '되돌릴 수 없는 작업 전에는 항상 같은 일을 합니다.', NULL, NULL, '[]', 'choice', '["바로 모든 브로커의 로그 디렉터리를 삭제한다", "백업 없이 새 클러스터 ID 로 시작한다", "컨슈머를 모두 삭제한다", "메타데이터와 필요한 로그를 **백업(스냅샷)** 해 두고, 손상된 파티션 범위를 확인한다"]', 3, '복구 순서는 **백업 → 손상 범위 확인 → 전체 중지 → 로그·메타데이터 정리 → 재시작 → 토픽 재생성 → 컨슈머 그룹 offset 정리** 입니다. 정리 단계는 데이터 손실이 있으므로, 백업과 범위 확인을 반드시 먼저 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 11, '데이터를 날린 뒤 offset 을 정리하는 이유', 'Kafka 로그를 모두 정리하고 토픽을 재생성했습니다. 기존 consumer group 의 **offset** 도 초기화해야 하는 이유는 무엇일까요?', 'offset 은 "어디까지 읽었는가"의 숫자입니다.', NULL, NULL, '[]', 'choice', '["offset 은 토픽과 무관해서 필요 없다", "기존 offset 이 새 토픽에는 존재하지 않는 위치를 가리켜서, 읽기가 오류가 나거나 새 메시지를 건너뛸 수 있기 때문이다", "초기화하면 데이터가 복구된다", "offset 을 지우면 브로커가 자동으로 재시작된다"]', 1, '정리 전 offset 은 옛 데이터의 위치입니다. 새로 시작하는 토픽에 그대로 두면 읽을 위치가 맞지 않습니다. 그래서 컨슈머 그룹을 멈춘 뒤 offset 을 초기화(reset)하고, 어디서부터 읽을지(처음/최신) 정해서 재개합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 11);
