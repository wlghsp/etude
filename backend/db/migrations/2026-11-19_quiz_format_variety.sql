-- 퀴즈 세트 문제 형식 다양화 (2026-11-19). 형식이 2종 이하인 세트에 빠진 형식의 문제를 추가한다.
-- 문제는 그 세트가 이미 가르친 개념으로 만들었다. order_index 가 이미 있으면 건너뛰므로 여러 번 실행해도 안전하다.

-- 세트 28 #15 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 28, 15, 'inode 사용량을 보는 df 옵션', '`df -h` 로는 용량이 남아 있는데 파일이 만들어지지 않습니다. **inode 사용량(IUse%)** 을 보려면 `df` 에 어떤 옵션을 붙여야 할까요? 빈칸을 채우세요.', '용량(block) 대신 inode 를 세어 보여 주는 옵션입니다. inode 영어 단어를 떠올려 보세요.', NULL, NULL, '[]', 'fill', '["h", "s", "i", "l"]', NULL, '정답은 **`i`** 입니다. `df -i` 는 디스크 용량 대신 inode 사용량(`IUse%`)을 보여 줍니다. 용량이 남아도 inode 가 100% 면 새 파일을 만들 수 없습니다.\n\n- `h` 는 용량을 읽기 쉬운 단위로 보여 줍니다.\n- `l` 은 로컬 파일시스템만 보여 줍니다(NFS 같은 원격 제외).\n- `s` 는 inode 사용량을 보여 주는 옵션이 아닙니다.', '[2]', 'df -{0} /data', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 15);
-- 세트 28 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 28, 16, '리다이렉션을 쉘이 읽는 순서', '`ls /etc/hostname /nonexistent > out.txt 2>&1` 을 실행할 때, 쉘이 이 줄을 처리하는 순서를 **앞에서 뒤로** 놓으세요.', '리다이렉션은 왼쪽에서 오른쪽으로 하나씩 적용됩니다.', NULL, NULL, '[]', 'order', '["`2>&1` 을 만나 2번(에러)을 \'지금 1번이 가는 곳(파일)\'으로 보낸다", "명령이 실행되어 정상 출력과 에러가 모두 `out.txt` 에 쓰인다", "쉘이 명령줄을 왼쪽에서 오른쪽으로 읽는다", "`> out.txt` 를 만나 1번(정상 출력)을 파일로 보낸다"]', NULL, '쉘은 줄을 **왼쪽에서 오른쪽으로** 읽으며 리다이렉션을 차례로 적용합니다. 먼저 `> out.txt` 로 1번(정상 출력)이 파일로 가게 하고, 그다음 `2>&1` 이 2번(에러)을 \'지금 1번이 가는 곳\'인 파일로 보냅니다. 순서가 뒤집히면(`2>&1 > out.txt`) 에러가 화면에 나옵니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 16);
-- 세트 29 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 29, 13, 'Pod 의 라벨을 함께 보는 옵션', 'Service 의 `selector` 와 Pod 의 라벨이 맞는지 비교하려고 합니다. Pod 목록에 **라벨을 함께 표시**하는 옵션을 넣어 명령을 완성하세요. 빈칸을 채우세요.', '목록 오른쪽에 LABELS 열을 덧붙여 보여 주는 옵션입니다.', NULL, NULL, '[]', 'fill', '["--labels", "--show-labels", "--with-labels", "--list-labels"]', NULL, '정답은 **`--show-labels`** 입니다. 목록 오른쪽에 `LABELS` 열이 추가되어 Service 의 `Selector` 와 한눈에 비교할 수 있습니다. 둘이 다르면 endpoints 가 비어 접속이 안 됩니다.\n\n나머지는 `kubectl get` 에 없는 옵션입니다.', '[1]', 'kubectl get pods {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 13);
-- 세트 29 #14 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 29, 14, 'Pod 가 실행되기까지의 순서', 'Deployment 로 만든 Pod 가 **실제로 실행되기까지** 거치는 단계를 앞에서 뒤로 놓으세요. (단계마다 막히면 `Pending`, `ImagePullBackOff` 같은 상태가 보입니다)', '\'어디에 둘지 → 이미지 → 실행\' 순서입니다.', NULL, NULL, '[]', 'order', '["노드가 레지스트리에서 이미지를 받는다", "Pod 를 만들어 달라는 요청이 들어온다", "컨테이너가 실행된다", "스케줄러가 `requests` 를 기준으로 Pod 를 놓을 노드를 고른다"]', NULL, 'Pod 는 **스케줄링 → 이미지 받기 → 컨테이너 실행** 순서로 시작됩니다. 스케줄링에서 막히면 `Pending`, 이미지 받기에서 막히면 `ImagePullBackOff`, 실행 뒤 계속 종료되면 `CrashLoopBackOff` 가 됩니다. 상태를 보면 어느 단계 문제인지 좁힐 수 있습니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 14);
-- 세트 55 #12 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 55, 12, 'KVM 이 들어 있는 곳', 'KVM 이 어디에 들어 있는지 떠올려 보세요. 문장의 빈칸을 채우세요.', 'KVM 은 리눅스의 가장 안쪽 핵심 부분에 들어 있습니다.', NULL, NULL, '[]', 'fill', '["유저스페이스", "웹 콘솔", "레지스트리", "커널"]', NULL, '정답은 **커널** 입니다. KVM 은 리눅스 커널 모듈이라서 CPU·메모리 가상화를 하드웨어 가속으로 처리합니다. 디스크·네트워크 카드 에뮬레이션은 유저스페이스에서 도는 QEMU 가 맡습니다.', '[3]', 'KVM 은 별도 프로그램이 아니라 리눅스 {0} 안에 들어 있는 모듈이며, CPU 의 하드웨어 가상화 기능(VT-x/AMD-V)을 열어 준다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 55 AND order_index = 12);
-- 세트 57 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 57, 13, 'Loki 가 인덱싱하는 것', 'Loki 가 로그를 싸게 저장하는 비결을 떠올려 보세요. 문장의 빈칸을 채우세요.', 'Elasticsearch 와 달리 본문 전체를 색인하지 않습니다. namespace, pod, app 같은 것입니다.', NULL, NULL, '[]', 'fill', '["레이블", "단어", "파티션", "오프셋"]', NULL, '정답은 **레이블** 입니다. Loki 는 namespace·pod·app 같은 레이블만 인덱싱하고, 레이블로 좁힌 로그 스트림 안에서 grep 방식으로 검색합니다. 그래서 인덱스가 작아 저장 비용이 적습니다.\n\n- 본문의 단어마다 인덱스를 만드는 쪽은 Elasticsearch 입니다.\n- 파티션과 오프셋은 Kafka 의 개념입니다.', '[0]', 'Loki 는 로그 본문 전체가 아니라 {0} 만 인덱싱하고, 그 값으로 좁힌 로그 안에서 grep 방식으로 검색한다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 57 AND order_index = 13);
-- 세트 58 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 58, 13, 'Leader 와 Follower 의 개수', 'replication factor 가 3 인 파티션은 서로 다른 브로커 3대에 복사본이 저장됩니다. Follower 가 몇 개일지 빈칸을 채우세요.', '전체 3개 중 Leader 는 한 개입니다.', NULL, NULL, '[]', 'fill', '["0", "1", "2", "3"]', NULL, '정답은 **2** 입니다. replication factor 는 파티션의 **복사본 총 수**이고 Leader 가 그중 1개라서 Follower 는 3 − 1 = 2개입니다. Follower 는 Leader 를 따라가며 Leader 가 죽으면 새 Leader 후보가 됩니다.', '[2]', 'replication factor 3 = Leader 1개 + Follower {0}개', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 58 AND order_index = 13);
-- 세트 59 #14 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 59, 14, '복제가 정상일 때의 필드 값', 'Slave 에서 `SHOW SLAVE STATUS\\G` 를 실행했습니다. 복제가 정상이려면 두 스레드 필드가 어떤 값이어야 할까요? 빈칸을 채우세요.', 'IO 스레드와 SQL 스레드 둘 다 \'동작 중(Yes/No)\' 을 나타냅니다.', NULL, NULL, '[]', 'fill', '["No", "Connecting", "Paused", "Yes"]', NULL, '정답은 **Yes** 입니다. `Slave_IO_Running`(Master 에서 binlog 를 가져옴)과 `Slave_SQL_Running`(받은 내용을 적용함)이 둘 다 `Yes` 여야 정상입니다. 하나라도 `No` 면 `Last_Error` 로 원인을 보고, `Seconds_Behind_Master` 로 지연을 확인합니다.', '[3]', 'Slave_IO_Running 과 Slave_SQL_Running 이 모두 `{0}` 이어야 복제가 정상이다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 59 AND order_index = 14);
-- 세트 61 #14 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 61, 14, 'Ceph 가 제공하는 형태', 'Ceph 는 하나의 클러스터로 세 가지 형태의 스토리지를 제공합니다. 빈칸을 채우세요.', 'S3 호환 저장 방식을 가리키는 말입니다.', NULL, NULL, '[]', 'fill', '["오브젝트", "테이블", "스트림", "캐시"]', NULL, '정답은 **오브젝트** 입니다. Ceph 는 블록, 파일, 오브젝트(S3 호환) 세 형태를 하나의 분산 스토리지로 제공합니다. 그래서 OCP(ODF 경유)와 OpenStack(Cinder 경유) 양쪽의 저장소로 쓰입니다.', '[0]', 'Ceph 는 블록, 파일, {0}(S3 호환) 세 가지 형태의 스토리지를 하나의 클러스터로 제공한다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 61 AND order_index = 14);
-- 세트 62 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 62, 13, '검색 가능하게 만드는 단위', '`refresh` 가 하는 일을 떠올려 보세요. 문장의 빈칸을 채우세요.', '한 번 만들면 수정되지 않는(불변) 단위입니다.', NULL, NULL, '[]', 'fill', '["Shard", "Segment", "Translog", "Replica"]', NULL, '정답은 **Segment** 입니다. `refresh` 는 메모리 버퍼의 문서를 새 Segment 로 만들어 검색 대상에 포함시킵니다. 디스크에 영구 저장(fsync)하는 일은 `flush` 의 몫입니다.\n\n- Shard 는 인덱스를 나눈 단위, Replica 는 Primary 의 복제본입니다.\n- Translog 는 flush 전 장애에 대비한 기록입니다.', '[1]', '`refresh` 는 메모리 버퍼의 문서를 새 {0} 으로 만들어 검색 가능하게 한다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 62 AND order_index = 13);
-- 세트 63 #14 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 63, 14, '다른 서버로 넘기는 옵션', '백엔드 연결이 실패하면 `retries 3` 은 같은 서버에 다시 시도합니다. 재시도 중 **다른 서버로 요청을 넘기는** 옵션을 채워 설정을 완성하세요. 빈칸을 채우세요.', '옵션 이름이 \'다시 배분하다\' 라는 뜻입니다.', NULL, NULL, '[]', 'fill', '["retry", "failover", "redispatch", "rebalance"]', NULL, '정답은 **`redispatch`** 입니다. `retries` 는 같은 서버에 다시 시도하는 횟수이고, `option redispatch` 는 재시도 중 요청을 다른 서버로 넘깁니다. 서버 한 대가 불안정해도 요청이 다른 서버에서 처리될 수 있습니다.\n\n나머지는 HAProxy 옵션 이름이 아닙니다.', '[2]', 'retries 3\noption {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 63 AND order_index = 14);
-- 세트 64 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 64, 13, '이미지에 레지스트리 주소 붙이기', '로컬에서 만든 `api:1.2.0` 이미지에 Harbor 주소가 들어간 새 이름을 붙이려고 합니다. 명령을 완성하세요. 빈칸을 채우세요.', '이미지에 \'이름표를 붙인다\' 는 뜻의 단어입니다.', NULL, NULL, '[]', 'fill', '["tag", "push", "build", "login"]', NULL, '정답은 **`tag`** 입니다. `docker tag 원본 새이름` 은 같은 이미지에 레지스트리 주소가 포함된 새 이름을 붙입니다. 그 뒤 `docker push` 로 올립니다.\n\n- `build` 는 이미지를 만들고, `push` 는 올리고, `login` 은 레지스트리에 로그인합니다. 모두 이 형태(원본, 새 이름)의 명령이 아닙니다.', '[0]', 'docker {0} api:1.2.0 harbor.example.com/myteam/api:1.2.0', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 64 AND order_index = 13);
-- 세트 66 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 66, 13, '재시작해도 남는 큐', '브로커가 재시작해도 큐와 메시지를 남기려면 큐를 어떻게 선언해야 할까요? 문장의 빈칸을 채우세요.', '\'오래 지속되는(내구성 있는)\' 이라는 뜻입니다.', NULL, NULL, '[]', 'fill', '["transient", "exclusive", "auto-delete", "durable"]', NULL, '정답은 **durable** 입니다. 큐가 `durable` 이어야 큐 정의가 재시작 뒤에도 남고, 메시지는 `persistent`(delivery_mode=2)여야 디스크에 기록됩니다. 둘 다 필요합니다.', '[3]', '큐를 {0} 로 선언하고 메시지를 persistent 로 발행하면 브로커가 재시작해도 남는다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 66 AND order_index = 13);
-- 세트 67 #11 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 67, 11, '오래된 메시지를 지우는 정책', 'Kafka 가 보관 기간(또는 크기)이 지난 메시지를 **삭제**하게 하는 `cleanup.policy` 값은 무엇일까요? 빈칸을 채우세요.', '보관 기간이 지난 것을 정리하는 기본 방식입니다. 같은 키의 최신 값만 남기는 compact 와는 반대 성격입니다.', NULL, NULL, '[]', 'fill', '["compact", "delete", "retain", "purge"]', NULL, '정답은 **delete** 입니다. `cleanup.policy=delete` 이면 `retention.ms`·`retention.bytes` 를 넘긴 오래된 세그먼트를 삭제합니다. `compact` 는 같은 키의 최신 값만 남기는 정책이라 `connect-offsets` 같은 내부 토픽에 쓰입니다.', '[1]', 'cleanup.policy={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 67 AND order_index = 11);
-- 세트 67 #12 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 67, 12, '브로커를 순차 재시작하는 순서', 'KRaft 브로커 3대에 설정을 반영하는 안전한 순서를 **앞에서 뒤로** 놓으세요.', '한 대씩, 복귀를 확인한 뒤 다음으로 넘어갑니다.', NULL, NULL, '[]', 'order', '["재시작한 브로커가 정상으로 복귀(ISR·쿼럼)한 것을 확인한다", "마지막 브로커까지 같은 방식으로 반복한 뒤 클러스터 상태를 확인한다", "브로커 한 대를 재시작한다", "다음 브로커 한 대를 재시작한다"]', NULL, '**1대 재시작 → 정상 복귀(ISR·쿼럼) 확인 → 다음 1대 재시작 → 마지막까지 반복** 순서입니다. 동시에 재시작하면 쿼럼과 ISR 이 한꺼번에 무너질 수 있어서, 한 대가 돌아온 것을 확인하고 다음으로 넘어갑니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 67 AND order_index = 12);
-- 세트 68 #11 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 68, 11, '짝수 번호 대역 정하기', '두 DB 의 AUTO_INCREMENT 번호가 겹치지 않게 한쪽은 홀수, 다른 쪽은 짝수로 가릅니다. A 는 `auto_increment_offset=1` 로 홀수를 씁니다. B 가 **짝수**를 쓰려면 offset 을 얼마로 해야 할까요? 빈칸을 채우세요.', 'increment 가 2 이면 offset 에서 시작해 2 씩 늘어납니다. 홀수와 짝수가 겹치지 않아야 합니다.', NULL, NULL, '[]', 'fill', '["1", "2", "3", "5"]', NULL, '정답은 **2** 입니다. increment 가 2 이므로 A(offset 1)는 1, 3, 5… 를, B(offset 2)는 2, 4, 6… 을 씁니다. 번호 대역이 미리 갈라져 있어 서로 PK 가 충돌하지 않습니다.\n\n- 1 은 A 와 같아 충돌합니다.\n- 3, 5 는 홀수라 A 와 겹칩니다.', '[1]', 'A: auto_increment_increment=2, auto_increment_offset=1\nB: auto_increment_increment=2, auto_increment_offset={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 68 AND order_index = 11);
-- 세트 69 #11 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 69, 11, '쿼럼을 잃은 노드의 상태', '3노드 Galera 에서 2대가 다운되어 남은 노드가 Primary 가 되지 못하고 쓰기가 막혔습니다(`quorum is lost`). 이때 `wsrep_ready` 값은 무엇일까요? 빈칸을 채우세요.', '쓰기를 받을 준비가 \'안 된\' 상태입니다.', NULL, NULL, '[]', 'fill', '["ON", "Synced", "OFF", "PRIMARY"]', NULL, '정답은 **OFF** 입니다. 쿼럼을 잃으면 남은 노드는 클러스터로서 동작하지 못해 `wsrep_ready=OFF` 가 되고 쓰기가 막힙니다. 다른 노드가 정말 죽어 있는지 확인한 뒤 `pc.bootstrap=YES` 로 Primary 를 강제 지정해 복구합니다.\n\n- `Synced` 는 `wsrep_local_state_comment` 의 정상 값이고, `PRIMARY` 는 `wsrep_cluster_status` 의 정상 값입니다.', '[2]', '쿼럼을 잃은 노드는 `wsrep_ready` 가 `{0}` 이다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 69 AND order_index = 11);
-- 세트 70 #9 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 70, 9, 'VirtualService 를 Gateway 에 붙이기', 'VirtualService 가 **어느 Gateway 에 붙을지** 가리키는 필드를 채우세요.', 'Gateway 이름을 목록으로 적는 필드예요.', NULL, NULL, '[]', 'fill', '["selector", "listeners", "gateways", "ingress"]', NULL, '`spec.gateways` 가 VirtualService 를 Gateway 에 연결합니다. 이 값이나 `hosts` 가 어긋나면 라우팅이 되지 않습니다. `listeners` 나 `ingress` 는 이 용도의 필드가 아닙니다.', '[2]', 'kind: VirtualService\nspec:\n  {0}:\n    - my-gateway\n  hosts:\n    - app.example.com', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 70 AND order_index = 9);
-- 세트 71 #8 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 71, 8, '새 인덱스로 갈아타는 ILM 동작', '인덱스가 정해 둔 크기나 기간에 도달하면 새 인덱스(`index-000002`)를 만들어 쓰기를 넘기는 ILM 동작입니다. 빈칸을 채우세요.', '"언제 새 인덱스로 갈아탈까"를 정하는 동작이에요.', NULL, NULL, '[]', 'fill', '["rollover", "shrink", "freeze", "restore"]', NULL, '**rollover** 는 인덱스가 50GB 나 1일 같은 기준에 도달하면 새 인덱스로 쓰기를 넘깁니다. 이렇게 인덱스를 쪼개 두어야 나중에 오래된 것을 통째로 지울 수 있습니다.', '[0]', 'ILM 정책의 hot 단계에서 인덱스가 기준에 도달하면 {0} 가 일어난다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 71 AND order_index = 8);
-- 세트 73 #12 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 73, 12, '복구 끝난 노드의 상태 값', '`SHOW STATUS LIKE \'wsrep_local_state_comment\';` 결과가 어떤 값이면 노드가 클러스터와 동기화된 정상 상태일까요? 빈칸을 채우세요.', '복구가 끝나면 다른 노드와 "동기화됨"이라는 뜻의 단어가 나와요.', NULL, NULL, '[]', 'fill', '["Joiner", "Donor", "Closed", "Synced"]', NULL, '`Synced` 는 노드가 클러스터와 완전히 동기화되었다는 뜻입니다. 합류 중에는 `Joiner`, 데이터를 주는 중에는 `Donor` 로 보이므로 `Synced` 가 될 때까지 기다리고 확인합니다.', '[3]', 'wsrep_local_state_comment = {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 73 AND order_index = 12);
-- 세트 74 #12 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 74, 12, 'federation 이 읽는 엔드포인트', 'Prometheus federation 에서 가져오는 쪽은 원천 Prometheus 의 어떤 엔드포인트를 scrape 할까요? `match[]` 로 필요한 시계열만 골라 가져오는 그 엔드포인트를 채우세요.', '원천 Prometheus 가 다른 Prometheus 에게 시계열을 내주는 전용 경로입니다.', NULL, NULL, '[]', 'fill', '["write", "federate", "targets", "query"]', NULL, 'federation 은 `/federate` 엔드포인트를 scrape 하면서 `match[]` 로 가져올 시계열을 선별하는 pull 방식입니다. 원천 Prometheus 의 부담을 줄이고 필요한 메트릭만 받습니다.', '[1]', 'scrape_configs 의 metrics_path: /{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 74 AND order_index = 12);
-- 세트 76 #11 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 76, 11, '재시작 전에 샤드 재배치 멈추기', '노드를 순차 재시작하기 전에 샤드 재배치를 **멈추려면** `cluster.routing.allocation.enable` 을 어떤 값으로 둘까요? 빈칸을 채우세요.', '"하나도 허용하지 않음"을 뜻하는 값이에요.', NULL, NULL, '[]', 'fill', '["off", "stop", "none", "false"]', NULL, '재시작 중 불필요한 샤드 이동을 막으려고 `none` 으로 두고, 작업이 끝나면 반드시 `all` 로 되돌립니다. 되돌리지 않으면 이후 장애에도 샤드가 복구되지 않습니다.', '[2]', 'cluster.routing.allocation.enable = {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 76 AND order_index = 11);
-- 세트 76 #12 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 76, 12, '색인 요청이 처리되는 순서', 'Elasticsearch 에서 문서를 색인할 때 요청이 처리되는 흐름을 **앞에서 뒤**로 놓으세요.', '쓰기는 항상 Primary 부터 시작해요.', NULL, NULL, '[]', 'order', '["Replica 샤드에 문서를 복제한다", "클라이언트가 색인 요청을 보낸다", "복제가 끝난 뒤 클라이언트에 응답한다", "Primary 샤드가 문서를 먼저 처리한다"]', NULL, '**클라이언트 요청 → Primary 샤드 처리 → Replica 복제 → 복제 완료 후 클라이언트 응답** 순서입니다. 쓰기가 항상 Primary 부터 가기 때문에 순서가 일관되게 유지됩니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 76 AND order_index = 12);
-- 세트 78 #12 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 12, '원하는 상태에 맞추는 동작', '컨트롤러가 원하는 상태와 현재 상태를 계속 비교해 맞추는 동작을 무엇이라고 할까요? 빈칸을 채우세요.', '선언형 모델이 동작하는 핵심 반복이에요.', NULL, NULL, '[]', 'fill', '["rollout", "schedule", "replicate", "reconcile"]', NULL, '선언형 모델에서는 "복제본 3개"처럼 원하는 상태를 선언하면 컨트롤러가 현재 상태와 비교해 차이를 계속 메웁니다. 이 지속적인 조정을 **reconcile(reconciliation)** 이라고 합니다.', '[3]', '컨트롤러가 원하는 상태와 현재 상태를 계속 비교해 맞추는 동작을 {0}(조정) 이라고 한다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 12);
-- 세트 79 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 79, 13, '실행 중인 Pod 까지 내보내는 Taint', '`kubectl taint` 의 effect 중, 이 Taint 를 견디지 못하는 **이미 실행 중인 Pod 까지 내보내는**(eviction) 효과를 채우세요.', 'NoSchedule 은 새 배치만 막아요. 실행 중인 것까지 건드리는 효과를 고르세요.', NULL, NULL, '[]', 'fill', '["NoExecute", "NoSchedule", "PreferNoSchedule", "NoEvict"]', NULL, '`NoSchedule` 은 새 Pod 배치만 막고, `PreferNoSchedule` 은 가급적 피할 뿐입니다. `NoExecute` 는 이미 떠 있는 Pod 도 Toleration 이 없으면 내보냅니다.', '[0]', 'kubectl taint nodes node1 key=value:{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 79 AND order_index = 13);
-- 세트 80 #13 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 13, 'Service 에서 Pod 로 가는 포트', 'Service 는 80 포트로 요청을 받아 뒤의 Pod 컨테이너 **8080** 포트로 전달합니다. 빈칸의 필드 이름을 채우세요.', 'Service 의 `port` 와 달리 Pod 쪽 포트를 가리켜요.', NULL, NULL, '[]', 'fill', '["nodePort", "targetPort", "hostPort", "containerPort"]', NULL, '`port` 는 Service 가 받는 포트, `targetPort` 는 Pod 컨테이너가 받는 포트입니다. `nodePort` 는 NodePort 타입에서 노드에 여는 포트이고, 연결이 안 될 때는 이 세 값이 어긋난 경우가 많습니다.', '[1]', 'spec:\n  type: ClusterIP\n  ports:\n    - port: 80\n      {0}: 8080', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 13);
-- 세트 82 #14 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 14, '단일 인스턴스를 위한 배포 전략', 'Jenkins 처럼 단일 인스턴스(RWO PVC, replicas 1)를 업데이트할 때, **옛 Pod 를 먼저 내리고 새 Pod 를 올리는** 전략을 채우세요.', '같은 볼륨을 옛 Pod 와 새 Pod 가 동시에 쥐면 안 돼요.', NULL, NULL, '[]', 'fill', '["RollingUpdate", "Rollback", "Recreate", "Replace"]', NULL, 'RollingUpdate 는 새 Pod 가 뜨는 동안 옛 Pod 가 볼륨을 쥐고 있어 충돌하거나 데이터가 깨질 수 있습니다. `Recreate` 는 옛 Pod 를 먼저 내리므로 짧은 중단이 생기는 대신 데이터를 지킵니다.', '[2]', 'spec:\n  replicas: 1\n  strategy:\n    type: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 14);
-- 세트 86 #14 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 86, 14, '5대 클러스터의 과반수', '합의가 필요한 클러스터를 노드 5대로 구성했습니다. 쓰기를 진행하려면 최소 몇 대가 살아 있어야 할까요? (과반수 = 절반을 넘는 수) 빈칸을 채우세요.', '절반(2.5)을 넘는 가장 작은 정수예요.', NULL, NULL, '[]', 'fill', '["2", "3", "4", "5"]', NULL, '과반수(quorum)는 N/2 + 1 이고 5대면 3대입니다. 그래서 5대 구성은 2대가 죽어도 계속 동작하며, 네트워크가 갈라져도 과반수를 가진 쪽만 쓰기를 진행해 split-brain 을 막습니다.', '[1]', '노드 5대 클러스터는 {0}대 이상 살아 있어야 쓰기를 진행한다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 86 AND order_index = 14);
-- 세트 87 #15 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 87, 15, '복합 인덱스를 쓰는 조건', '복합 인덱스 `(A, B, C)` 가 있습니다. 이 인덱스를 활용하려면 조건에 맨 왼쪽부터 이어지는 컬럼이 있어야 합니다. 아래 쿼리가 인덱스를 활용하도록 빈칸에 들어갈 컬럼을 채우세요.', '인덱스는 맨 왼쪽 컬럼부터 정렬되어 있어요.', NULL, NULL, '[]', 'fill', '["B", "C", "D", "A"]', NULL, 'leftmost prefix 규칙 때문에 `A` 부터 이어지는 조건이어야 인덱스를 씁니다. `B` 나 `C` 만 단독으로 걸면 정렬 구조를 쓸 수 없고, 인덱스에 없는 `D` 는 도움이 되지 않습니다.', '[3]', 'CREATE INDEX idx ON t (A, B, C);\nSELECT * FROM t WHERE {0} = 1 AND C = 3;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 87 AND order_index = 15);
-- 세트 127 #17 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 17, '새 폴더에서 파일 만들기 순서', '`work` 폴더를 만들고, 그 **안에** `notes.txt` 를 만든 뒤, 마지막에 목록으로 확인하는 명령 순서를 **앞에서 뒤**로 놓으세요.', '폴더가 있어야 들어가고, 들어간 다음에 파일을 만들어요.', NULL, NULL, '[]', 'order', '["`touch notes.txt`", "`ls`", "`mkdir work`", "`cd work`"]', NULL, '**mkdir → cd → touch → ls** 순서입니다. 폴더를 먼저 만들어야 `cd` 로 들어갈 수 있고, 안에서 `touch` 로 빈 파일을 만든 뒤 `ls` 로 확인합니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 17);
-- 세트 128 #17 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 17, 'Pod 를 지웠을 때 일어나는 순서', 'Deployment(`replicas: 3`)가 관리하는 Pod 하나를 지웠을 때 벌어지는 일을 **앞에서 뒤**로 놓으세요.', '"원하는 상태를 유지한다"는 성질이 어떻게 작동하는지 떠올려 보세요.', NULL, NULL, '[]', 'order', '["새 Pod 가 노드에서 실행되어 READY 가 `1/1` 이 된다", "`kubectl get pods` 로 Pod 3개가 다시 있는지 확인한다", "Deployment 가 Pod 수가 원하는 3개보다 적은 것을 알아챈다", "`kubectl delete pod` 로 Pod 하나를 지운다", "부족한 개수만큼 새 Pod 를 만든다"]', NULL, '**Pod 삭제 → Deployment 가 개수 부족을 알아챔 → 새 Pod 생성 → 새 Pod 실행 → get pods 로 확인** 순서입니다. Deployment 가 원하는 개수를 유지하므로 사람이 다시 만들지 않아도 됩니다.', '[3, 2, 4, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 17);
-- 세트 129 #17 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 129, 17, '실행 권한 오류를 푸는 순서', '`./run.sh` 를 실행했더니 `Permission denied` 가 났습니다. 문제를 확인하고 해결해 다시 실행하기까지의 순서를 **앞에서 뒤**로 놓으세요.', '권한 문제는 `ls -l` 로 확인하는 것이 첫걸음이에요.', NULL, NULL, '[]', 'order', '["`ls -l` 로 `run.sh` 에 `x` 권한이 없는 것을 확인한다", "다시 `./run.sh` 를 실행하니 정상으로 돈다", "`chmod +x run.sh` 로 실행 권한을 준다", "`./run.sh` 를 실행하니 `Permission denied` 가 난다"]', NULL, '**실행 → 오류 → `ls -l` 로 `x` 확인 → `chmod +x` → 다시 실행** 순서입니다. 원인을 확인한 뒤에 실행 권한을 주고, 마지막에 다시 실행해 해결을 확인합니다.', '[3, 0, 2, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 129 AND order_index = 17);
-- 세트 130 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 130, 16, 'Job Pod 가 끝나기까지', 'Job 이 만든 Pod 가 만들어져서 `Completed` 가 되기까지의 순서를 맞추세요. 위에서부터 먼저 일어나는 순서로 놓으세요.', 'Pod 는 먼저 만들어지고, 노드에 자리를 잡아야 실행됩니다.', NULL, NULL, '[]', 'order', '["컨테이너가 실행되어 `Running` 상태가 된다", "YAML 을 적용해 Job 과 Pod 가 만들어진다", "작업이 정상 종료되어 `Completed` 상태가 된다", "스케줄러가 자원이 충분한 노드에 Pod 를 배치한다"]', NULL, 'YAML 을 적용하면 Pod 가 만들어지고, 스케줄러가 자원이 되는 노드를 골라 배치합니다. 컨테이너가 `Running` 으로 일하다가 작업이 정상으로 끝나면 `Completed` 가 돼요.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 130 AND order_index = 16);
-- 세트 131 #17 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 131, 17, 'curl 요청이 닿는 과정', '`curl http://example.com` 을 실행했을 때 요청이 처리되는 순서를 맞추세요. 위에서부터 먼저 일어나는 순서로 놓으세요.', '이름으로는 길을 찾을 수 없으니 주소부터 알아야 해요.', NULL, NULL, '[]', 'order', '["응답이 돌아와 터미널에 출력된다", "그 IP 의 컴퓨터에 신호가 닿는다", "DNS 가 `example.com` 이름을 IP 주소로 바꿔 준다", "해당 포트에서 `LISTEN` 중인 프로그램이 접속을 받는다"]', NULL, '먼저 DNS 가 이름을 IP 주소로 바꿔 줍니다. 그 IP 의 컴퓨터에 닿으면 포트에서 `LISTEN` 중인 프로그램이 접속을 받고, 그 프로그램이 응답을 보내면 curl 이 터미널에 출력해요.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 131 AND order_index = 17);
-- 세트 132 #17 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 132, 17, 'ConfigMap 을 쓰는 Pod 순서', 'ConfigMap 의 값을 환경 변수로 쓰는 Pod 를 `dev` 네임스페이스에 띄우는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', '참조당하는 것이 먼저 있어야 해요. 없으면 Pod 가 시작하지 못합니다.', NULL, NULL, '[]', 'order', '["ConfigMap 을 참조하는 Pod 를 적용한다", "컨테이너가 환경 변수를 받아 시작된다", "`dev` 네임스페이스를 만든다", "`dev` 안에 ConfigMap 을 만든다"]', NULL, 'ConfigMap 은 네임스페이스 안에 만들어지므로 네임스페이스가 먼저 필요합니다. 또 참조하는 ConfigMap 이 없으면 Pod 가 `CreateContainerConfigError` 가 되기 때문에 ConfigMap 을 Pod 보다 먼저 만들어야 해요.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 132 AND order_index = 17);
-- 세트 133 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 133, 16, '스크립트 만들고 실행하기', '새 스크립트 `backup.sh` 를 만들어 실행하고 결과를 확인하는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', '실행 권한이 없으면 `Permission denied` 가 나요.', NULL, NULL, '[]', 'order', '["`chmod +x backup.sh` 로 실행 권한을 준다", "`echo $?` 로 종료 코드를 확인한다", "첫 줄에 `#!/bin/bash` 를 적어 스크립트 파일을 만든다", "`./backup.sh` 로 실행한다"]', NULL, '파일을 먼저 써야 하고, 첫 줄 `#!/bin/bash` 로 실행할 쉘을 알려 줍니다. 그다음 `chmod +x` 로 실행 권한을 주어야 `./backup.sh` 가 실행되고, 끝난 뒤 `$?` 로 성공(0) 여부를 확인해요.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 133 AND order_index = 16);
-- 세트 134 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 134, 16, '롤링 업데이트의 흐름', 'Deployment `web` 의 이미지를 새 버전으로 바꿀 때 일어나는 일을 순서대로 맞추세요. 위에서부터 먼저 일어나는 순서로 놓으세요.', '새 Pod 가 자리를 잡은 뒤에 옛 Pod 가 빠져야 서비스가 끊기지 않아요.', NULL, NULL, '[]', 'order', '["모든 Pod 가 새 버전이 되어 업데이트가 완료된다", "`kubectl set image` 로 새 이미지를 지정한다", "새 Pod 가 준비되면 옛 버전 Pod 하나가 종료된다", "새 버전 Pod 가 하나 먼저 만들어진다"]', NULL, '`kubectl set image` 로 이미지를 바꾸면 새 버전 Pod 가 먼저 하나 뜨고, 준비가 되면 옛 Pod 가 하나 줄어듭니다. 이를 반복해 모든 Pod 가 새 버전이 되면 업데이트가 끝나요.', '[1, 3, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 134 AND order_index = 16);
-- 세트 135 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 135, 16, '사용자 만들고 그룹에 넣기', '새 사용자 `kim` 을 만들어 `docker` 그룹에서 쓸 수 있게 하는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', '계정이 있어야 그룹에 넣을 수 있고, 그룹 정보는 로그인할 때 읽혀요.', NULL, NULL, '[]', 'order', '["kim 이 다시 로그인한다", "`sudo useradd -m kim` 으로 계정을 만든다", "`id` 로 `docker` 그룹이 보이는지 확인한다", "`sudo usermod -aG docker kim` 으로 그룹에 추가한다"]', NULL, '계정이 먼저 있어야 `usermod -aG` 로 그룹에 추가할 수 있습니다. 그룹 정보는 로그인 때 읽히므로 다시 로그인한 뒤 `id` 를 보면 `docker` 그룹이 나타나요.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 135 AND order_index = 16);
-- 세트 136 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 136, 16, '요청을 받기 시작하는 순서', '새 Pod 의 컨테이너가 시작된 뒤 Service 로 오는 요청을 받게 되기까지의 순서를 맞추세요. 위에서부터 먼저 일어나는 순서로 놓으세요.', 'readinessProbe 가 성공해야 Service 의 대상이 돼요.', NULL, NULL, '[]', 'order', '["`initialDelaySeconds` 만큼 기다린 뒤 첫 점검을 한다", "Pod 가 Endpoints 에 들어가고 Service 의 요청을 받는다", "컨테이너가 시작된다", "`readinessProbe` 가 성공해 Pod 가 Ready 가 된다"]', NULL, '컨테이너가 시작되고 `initialDelaySeconds` 만큼 기다린 뒤 첫 점검을 합니다. `readinessProbe` 가 성공하면 Ready 가 되어 Endpoints 에 들어가고, 그때부터 Service 가 요청을 보내요.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 136 AND order_index = 16);
-- 세트 137 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 137, 16, '이미지 받기부터 정리까지', 'nginx 컨테이너를 받아서 쓰고 정리하는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', '실행 중인 컨테이너에는 exec, 지우려면 먼저 멈춰야 해요.', NULL, NULL, '[]', 'order', '["`docker stop web` 으로 컨테이너를 멈춘다", "`docker pull nginx` 로 이미지를 내려받는다", "`docker rm web` 으로 컨테이너를 삭제한다", "`docker exec -it web sh` 로 컨테이너 안에 들어간다", "`docker run -d --name web nginx` 로 백그라운드 실행한다"]', NULL, '이미지를 먼저 내려받고(`pull`), 백그라운드로 실행한 뒤(`run -d`), 실행 중인 컨테이너 안에 들어갑니다(`exec`). 정리할 때는 `stop` 으로 멈춘 뒤에 `rm` 으로 삭제해요.', '[1, 4, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 137 AND order_index = 16);
-- 세트 138 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 138, 16, '변경을 원격에 올리는 순서', '파일을 고친 뒤 그 변경을 원격 저장소에 올리는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', 'add 로 담고, commit 으로 기록한 뒤에야 push 할 수 있어요.', NULL, NULL, '[]', 'order', '["`git commit -m \\"메시지\\"` 로 커밋을 남긴다", "파일을 고친다", "`git push` 로 원격 저장소에 올린다", "`git add` 로 변경을 스테이징한다"]', NULL, '파일을 고친 뒤 `git add` 로 스테이징 영역에 올리고, `git commit` 으로 기록(커밋)을 남깁니다. 마지막으로 `git push` 로 그 커밋을 원격 저장소에 올려요.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 138 AND order_index = 16);
-- 세트 139 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 16, '쿼리 절 쓰는 순서', '주문 중 금액이 5000 보다 큰 것 가운데 가장 큰 한 건을 구하는 쿼리입니다. 절을 SQL 에서 쓰는 순서대로 놓으세요.', 'SQL 은 절을 쓰는 순서가 정해져 있어요. 조건으로 거르는 절은 정렬하는 절보다 앞에 옵니다.', NULL, NULL, '[]', 'order', '["`ORDER BY amount DESC`", "`SELECT *`", "`LIMIT 1`", "`WHERE amount > 5000`", "`FROM orders`"]', NULL, 'SQL 은 `SELECT` → `FROM` → `WHERE` → `ORDER BY` → `LIMIT` 순서로 씁니다. 순서를 바꾸면 문법 오류가 나요.', '[1, 4, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 16);
-- 세트 140 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 16, '묶어서 걸러내는 순서', '`GROUP BY customer_id HAVING SUM(amount) >= 20000` 이 들어간 쿼리가 처리되는 흐름을 순서대로 맞추세요. 위에서부터 먼저 일어나는 순서로 놓으세요.', 'WHERE 는 묶기 전, HAVING 은 묶은 뒤예요.', NULL, NULL, '[]', 'order', '["묶음마다 `SUM(amount)` 를 계산한다", "`WHERE` 로 조건에 안 맞는 행을 먼저 거른다", "`HAVING` 으로 합계가 조건에 맞는 묶음만 남긴다", "`GROUP BY` 로 같은 고객끼리 묶는다"]', NULL, '`WHERE` 는 묶기 전에 행을 거릅니다. 그다음 `GROUP BY` 로 묶고, 묶음마다 `SUM` 같은 집계를 계산한 뒤, `HAVING` 으로 집계 결과가 조건에 맞는 묶음만 남겨요.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 16);
-- 세트 141 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 16, '주문 없는 고객 찾는 쿼리', '주문이 한 건도 없는 고객을 찾는 쿼리를 이루는 부분입니다. SQL 에서 쓰는 순서대로 놓으세요.', '고객을 기준으로 두고 주문을 이은 뒤, 짝이 없는 행만 골라요.', NULL, NULL, '[]', 'order', '["`WHERE o.id IS NULL`", "`FROM customers c`", "`SELECT c.name`", "`LEFT JOIN orders o ON c.id = o.customer_id`"]', NULL, '`customers` 를 왼쪽에 두고 `LEFT JOIN` 으로 orders 를 잇습니다. 주문이 없으면 `o.id` 가 `NULL` 이므로 `WHERE o.id IS NULL` 로 그런 고객만 거릅니다. 쓰는 순서는 `SELECT` → `FROM` → `JOIN` → `WHERE` 예요.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 16);
-- 세트 142 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 142, 16, '볼륨으로 데이터 지키기', 'DB 컨테이너를 지우고 다시 만들어도 데이터가 남는 것을 확인하는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', '컨테이너를 지우기 전에 볼륨에 데이터가 있어야 해요.', NULL, NULL, '[]', 'order', '["컨테이너를 지운다", "새 컨테이너에서 이전 데이터가 그대로 남아 있음을 확인한다", "`docker volume create data` 로 볼륨을 만든다", "같은 볼륨을 연결한 새 컨테이너를 실행한다", "`-v data:/data` 로 볼륨을 연결해 DB 컨테이너를 실행하고 데이터를 쌓는다"]', NULL, '볼륨을 만들어 DB 컨테이너에 연결하고 데이터를 쌓습니다. 컨테이너를 지워도 볼륨은 남으므로, 같은 볼륨을 연결한 새 컨테이너를 띄우면 데이터가 그대로 보여요.', '[2, 4, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 142 AND order_index = 16);
-- 세트 143 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 16, '마지막 커밋 다시 만들기', '마지막 커밋에서 고칠 점을 발견해, `reset --soft` 로 취소하고 다시 커밋하는 순서를 맞추세요. 위에서부터 먼저 하는 순서로 놓으세요.', 'soft 는 변경을 스테이징 영역에 남겨 줘요.', NULL, NULL, '[]', 'order', '["`git commit` 으로 새 커밋을 만든다", "`git reset --soft HEAD~1` 로 마지막 커밋을 취소한다", "`git show HEAD` 로 마지막 커밋의 변경 내용을 살펴본다", "남아 있는 변경에서 고칠 부분을 수정한다"]', NULL, '`git show` 로 마지막 커밋을 살펴 고칠 점을 확인하고, `git reset --soft HEAD~1` 로 커밋만 취소합니다. 변경은 스테이징에 남으므로 필요한 부분을 고친 뒤 `git commit` 으로 다시 커밋해요.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 16);
-- 세트 144 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 144, 16, 'less 로 로그 검색하기', '`less` 로 큰 로그에서 `ERROR` 를 찾고 끝내는 순서입니다. 카드를 올바른 순서로 놓으세요.', '먼저 열고, 검색하고, 다음 결과로 넘어간 뒤 끝냅니다.', NULL, NULL, '[]', 'order', '["`n` 을 눌러 다음 결과로 이동한다", "`q` 를 눌러 less 를 끝낸다", "`less app.log` 로 로그를 연다", "`/ERROR` 를 입력하고 Enter 를 누른다"]', NULL, '`less` 는 파일을 연 뒤 `/` 로 검색하고 `n` 으로 다음 결과로 넘어갑니다. 다 봤으면 `q` 로 빠져나옵니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 144 AND order_index = 16);
-- 세트 145 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 16, 'YAML 뼈대로 배포하기', 'YAML 뼈대를 만들어 고친 뒤 배포하고 확인하는 순서입니다. 카드를 올바른 순서로 놓으세요.', '실제로 만들기 전에 파일을 먼저 만들어 고칩니다.', NULL, NULL, '[]', 'order', '["`kubectl apply -f web.yaml` 로 적용한다", "`kubectl get rs` 로 ReplicaSet 과 Pod 개수가 맞는지 확인한다", "`kubectl create deployment web --image=nginx --dry-run=client -o yaml > web.yaml` 로 YAML 뼈대를 만든다", "`web.yaml` 을 열어 필요한 값을 고친다"]', NULL, '`--dry-run=client -o yaml` 은 아무것도 만들지 않고 YAML 만 출력하므로 파일로 저장해 고칠 수 있습니다. 고친 파일을 `apply` 로 적용한 뒤 `get rs` 로 개수가 맞는지 확인합니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 16);
-- 세트 146 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 16, 'vi 로 파일 고치고 저장', 'vi 로 파일을 열어 고치고 저장한 뒤 끝내는 순서입니다. 카드를 올바른 순서로 놓으세요.', '처음에는 명령 모드라서 입력 모드로 바꾸는 단계가 먼저 필요합니다.', NULL, NULL, '[]', 'order', '["`Esc` 를 눌러 명령 모드로 돌아온다", "`vi app.conf` 로 파일을 연다", "`:wq` 를 입력하고 Enter 를 눌러 저장하고 종료한다", "`i` 를 눌러 입력 모드로 바꾸고 내용을 고친다"]', NULL, 'vi 는 처음에 명령 모드로 열리므로 `i` 로 입력 모드로 바꿔 내용을 고칩니다. 끝나면 `Esc` 로 명령 모드로 돌아와 `:wq` 로 저장하고 종료합니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 16);
-- 세트 147 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 16, 'chart 점검부터 이력까지', 'chart 를 `lint` 로 점검한 다음 `template` 으로 최종 YAML 을 미리 보고, 설치한 뒤 업그레이드하고 이력을 확인하는 순서입니다. 카드를 올바른 순서로 놓으세요.', '설치 전에는 점검과 미리 보기를, 설치 후에는 변경과 이력 확인을 합니다.', NULL, NULL, '[]', 'order', '["`helm history demo` 로 리비전 목록을 확인한다", "`helm install demo ./mychart` 로 설치한다", "`helm lint ./mychart` 로 문법을 점검한다", "`helm upgrade demo ./mychart --set replicaCount=2` 로 새 설정을 적용한다", "`helm template demo ./mychart` 로 최종 YAML 을 미리 본다"]', NULL, '`helm lint` 로 문법을 점검하고 `helm template` 으로 최종 YAML 을 미리 본 뒤 `helm install` 로 설치합니다. 설치한 release 는 `helm upgrade` 로 바꾸고, `helm history` 로 리비전을 확인합니다.', '[2, 4, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 16);
-- 세트 148 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 148, 16, 'compose 시작부터 정리까지', 'compose 앱을 설정 검사 후 시작하고, 먼저 서비스 상태를 확인한 다음 로그를 보고, 마지막에 정리하는 순서입니다. 카드를 올바른 순서로 놓으세요.', '시작하기 전에 설정을 검사하고, 정리는 맨 마지막에 합니다.', NULL, NULL, '[]', 'order', '["`docker compose logs --tail 20 web` 으로 최근 로그를 본다", "`docker compose down` 으로 컨테이너와 네트워크를 정리한다", "`docker compose ps` 로 서비스 상태를 확인한다", "`docker compose config` 로 설정을 검사한다", "`docker compose up -d` 로 서비스를 시작한다"]', NULL, '`config` 로 설정이 의도대로 해석되는지 먼저 확인하고 `up -d` 로 시작합니다. `ps` 로 상태를, `logs` 로 로그를 본 뒤 다 쓰면 `down` 으로 컨테이너와 네트워크를 정리합니다.', '[3, 4, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 148 AND order_index = 16);
-- 세트 149 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 149, 16, '변경을 확인하고 올리기', '바뀐 내용을 확인하고 커밋해서 처음으로 원격에 올리는 순서입니다. 카드를 올바른 순서로 놓으세요.', '확인, 담기, 커밋, 올리기 순서입니다.', NULL, NULL, '[]', 'order', '["`git commit -m \\"메시지\\"` 로 커밋한다", "`git push -u origin feature` 로 원격에 올린다", "`git diff` 로 바뀐 내용을 확인한다", "`git add app.py` 로 올릴 변경을 담는다"]', NULL, '`git diff` 로 바뀐 내용을 보고, `git add` 로 커밋에 담을 변경을 고른 뒤 커밋합니다. 처음 올릴 때는 `git push -u origin feature` 로 원격 브랜치와 연결합니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 149 AND order_index = 16);
-- 세트 150 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 150, 16, '폴더 만들고 파일 만들기', '`out` 폴더 안에 파일 세 개를 만들고 확인하는 순서입니다. 카드를 올바른 순서로 놓으세요.', '폴더가 있어야 들어갈 수 있고, 들어간 뒤에 파일을 만듭니다.', NULL, NULL, '[]', 'order', '["`cd out` 으로 그 폴더에 들어간다", "`ls *.txt` 로 만들어진 파일을 확인한다", "`mkdir out` 으로 폴더를 만든다", "`touch file{1,2,3}.txt` 로 파일 세 개를 만든다"]', NULL, '`mkdir` 로 폴더를 만들고 `cd` 로 들어간 뒤 `touch file{1,2,3}.txt` 로 파일 세 개를 만듭니다. 마지막으로 `ls *.txt` 로 확인하면 세 파일 이름이 나옵니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 150 AND order_index = 16);
-- 세트 151 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 16, 'Pod 의 시작부터 종료까지', 'Pod 가 시작되어 동작하다가 삭제되는 과정의 순서입니다. 카드를 올바른 순서로 놓으세요.', 'init 컨테이너가 먼저이고, 종료 때는 정중한 요청이 강제 종료보다 앞섭니다.', NULL, NULL, '[]', 'order', '["Pod 를 삭제하면 컨테이너에 종료 신호(SIGTERM)가 간다", "유예 시간(기본 30초)이 지나도 남은 프로세스는 강제 종료된다", "init 컨테이너가 순서대로 실행된다 (`Init:0/1`)", "init 컨테이너가 모두 성공하면 본 컨테이너가 시작되고 `Running` 이 된다"]', NULL, 'init 컨테이너가 먼저 실행되고 모두 성공해야 본 컨테이너가 시작됩니다. 삭제하면 SIGTERM 으로 종료를 요청하고, 유예 시간(기본 30초) 안에 끝나지 않으면 강제 종료합니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 16);
-- 세트 152 #16 (fill)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 16, '인자 개수 읽기', '`./run.sh a b c` 로 실행했을 때 **인자의 개수**를 담고 있는 특수 변수입니다. 빈칸을 채우세요.', '`a b c` 세 개를 센 값이 들어 있는 변수입니다. 모든 인자가 아니라 개수예요.', NULL, NULL, '[]', 'fill', '["$@", "$0", "$#", "$!"]', NULL, '`$#` 은 인자의 개수(여기서는 3)이고, `$@` 는 모든 인자, `$0` 은 스크립트 이름입니다. `$!` 는 마지막 백그라운드 작업의 PID 예요.', '[2]', 'echo "인자 개수: {0}"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 16);
-- 세트 152 #17 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 152, 17, 'while 로 1부터 3까지', '1, 2, 3 을 차례로 출력하고 끝나는 `while` 반복문 스크립트의 줄 순서입니다. 카드를 올바른 순서로 놓으세요.', '변수를 먼저 정하고, 반복 안에서 출력한 뒤 값을 올립니다.', NULL, NULL, '[]', 'order', '["`done`", "`i=$((i+1))`", "`i=1`", "`echo $i`", "`while [ $i -le 3 ]; do`"]', NULL, '`i=1` 로 시작값을 정하고 `while` 조건이 참인 동안 출력합니다. 반복 안에서 `i` 를 올려 주지 않으면 무한 반복이 되고, `done` 으로 반복문을 닫습니다.', '[2, 4, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 152 AND order_index = 17);
-- 세트 154 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 154, 16, '이미지를 오프라인으로 옮기기', '인터넷이 없는 서버로 이미지를 옮겨 실행하는 순서입니다. 카드를 올바른 순서로 놓으세요.', '파일로 묶고, 옮기고, 불러온 뒤에 실행합니다.', NULL, NULL, '[]', 'order', '["`docker load -i app.tar` 로 서버에서 이미지를 불러온다", "`docker run 이미지` 로 컨테이너를 실행한다", "`docker save -o app.tar 이미지` 로 이미지를 파일로 묶는다", "`app.tar` 파일을 대상 서버로 옮긴다"]', NULL, '`docker save` 로 이미지를 tar 파일로 묶고 그 파일을 서버로 옮깁니다. 서버에서 `docker load` 로 불러와야 이미지가 생기므로 실행은 그 뒤에 합니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 154 AND order_index = 16);
-- 세트 156 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 156, 16, 'curl 요청이 지나가는 순서', '`curl http://myapp.test/` 가 요청을 처리하는 단계의 순서입니다. 카드를 올바른 순서로 놓으세요.', '이름을 풀어야 연결할 곳을 알고, 연결해야 요청을 보냅니다.', NULL, NULL, '[]', 'order', '["서버가 응답 헤더를 돌려준다 (`<` 줄)", "이름을 IP 로 바꾼다 (실패하면 종료 코드 6)", "그 IP 의 포트로 연결한다 (거부되면 7, 시간 초과면 28)", "요청 헤더를 보낸다 (`>` 줄)"]', NULL, '먼저 이름을 IP 로 바꾸고(실패하면 6), 그 IP 의 포트로 연결합니다(거부 7, 시간 초과 28). 연결된 뒤 요청 헤더(`>`)를 보내고 서버의 응답 헤더(`<`)를 받습니다.', '[1, 2, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 156 AND order_index = 16);
-- 세트 157 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 16, 'ConfigMap 수정 후 반영하기', '환경 변수로 ConfigMap 을 받는 Deployment 에 수정한 값을 반영하는 순서입니다. 카드를 올바른 순서로 놓으세요.', '환경 변수는 Pod 가 다시 만들어질 때만 새 값을 받습니다.', NULL, NULL, '[]', 'order', '["새 Pod 가 만들어지며 새 환경 변수 값을 읽는다", "`kubectl apply -f cm.yaml` 로 ConfigMap 을 수정한다", "`kubectl get pods` 로 새 Pod 들이 Running 인지 확인한다", "`kubectl rollout restart deployment/web` 로 재시작을 요청한다"]', NULL, '환경 변수로 받은 값은 Pod 를 다시 만들어야 바뀌므로 ConfigMap 을 수정한 뒤 `rollout restart` 를 합니다. 새 Pod 가 만들어질 때 새 값을 읽고, `get pods` 로 모두 Running 인지 확인합니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 16);
-- 세트 158 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 16, '느린 쿼리 멈추는 순서', '서버가 느려서 오래 걸리는 쿼리 하나를 찾아 멈추려고 합니다. 올바른 순서로 늘어놓으세요.', '먼저 목록을 보고, 후보를 고르고, 전체 문장을 확인한 뒤 마지막에 멈춥니다.', NULL, NULL, '[]', 'order', '["`SHOW FULL PROCESSLIST` 로 잘리지 않은 전체 쿼리 문장(`Info`)을 확인한다", "`SHOW PROCESSLIST` 로 연결된 세션과 실행 중인 쿼리 목록을 본다", "`KILL QUERY 번호` 로 그 쿼리만 중단한다", "`Time` 값이 큰 `Query` 행을 찾아 후보로 삼는다"]', NULL, '먼저 `SHOW PROCESSLIST` 로 세션 목록을 보고 `Time` 이 큰 `Query` 를 후보로 고릅니다. 잘린 `Info` 는 `SHOW FULL PROCESSLIST` 로 전체를 확인한 뒤, 마지막에 `KILL QUERY` 로 쿼리만 중단하면 연결은 유지됩니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 16);
-- 세트 159 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 16, 'UPDATE 안전하게 하기', '운영 DB 의 데이터를 `UPDATE` 하기 전후의 안전한 작업 순서입니다. 대상 개수는 트랜잭션을 열기 전에 먼저 확인합니다. 올바르게 늘어놓으세요.', '확인하고, 트랜잭션을 열고, 실행해 보고, 마지막에 확정하거나 되돌립니다.', NULL, NULL, '[]', 'order', '["예상과 같으면 `COMMIT`, 다르면 `ROLLBACK` 한다", "`START TRANSACTION` 으로 트랜잭션을 연다", "같은 `WHERE` 로 `SELECT COUNT(*)` 를 해서 대상 개수를 확인한다", "`UPDATE` 를 실행하고 영향 행 수(`Rows matched`)가 예상과 같은지 본다"]', NULL, '같은 `WHERE` 로 먼저 `SELECT COUNT(*)` 를 해서 대상 개수를 확인하고, 트랜잭션 안에서 `UPDATE` 합니다. 영향 행 수가 예상과 같을 때만 `COMMIT` 하고 다르면 `ROLLBACK` 합니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 16);
-- 세트 161 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 16, 'rebase 충돌 해결 순서', '`git rebase main` 도중 충돌이 났을 때 해결해서 이어 가는 순서를 올바르게 늘어놓으세요.', '충돌 확인 → 파일 정리 → add → continue 의 흐름입니다.', NULL, NULL, '[]', 'order', '["고친 파일을 `git add` 한다", "`git rebase main` 을 실행하다가 `CONFLICT` 가 난다", "`git rebase --continue` 로 이어 간다", "파일을 열어 표시 줄(`<<<<<<<`)을 정리해 고친다", "`git status` 로 충돌 난 파일(`UU`)을 확인한다"]', NULL, '충돌이 나면 `git status` 에서 `UU` 파일을 확인하고, 파일의 표시 줄(`<<<<<<<`)을 정리해 고칩니다. 그 뒤 `git add` 로 해결했음을 알리고 `git rebase --continue` 로 이어 갑니다.', '[1, 4, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 16);
-- 세트 162 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 162, 16, '좀비 프로세스 정리 순서', '좀비 프로세스를 발견하고 정리하는 순서를 올바르게 늘어놓으세요.', '좀비는 `kill -9` 로 안 죽으니 부모를 먼저 살펴봅니다.', NULL, NULL, '[]', 'order', '["`ps` 를 다시 보고 좀비가 정리되었는지 확인한다", "그 좀비의 부모 프로세스가 무엇인지 확인한다", "`top` 의 `Tasks` 줄에서 `zombie` 개수가 0 이 아닌 것을 본다", "부모가 자식을 거두게 하거나 부모를 종료한다", "`ps` 에서 `Z` 상태(`<defunct>`)인 프로세스를 찾는다"]', NULL, '`top` 의 `Tasks` 줄로 좀비가 있는지 보고, `ps` 에서 `Z`(`<defunct>`) 프로세스를 찾습니다. 좀비에 `kill -9` 는 소용없으니 부모가 자식을 거두게 하거나 부모를 종료한 뒤, 다시 확인합니다.', '[2, 4, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 162 AND order_index = 16);
-- 세트 163 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 163, 16, 'StatefulSet Pod 움직임 순서', '`replicas: 3` 인 StatefulSet `db` 를 처음 만들고, 이어서 이미지를 바꿔 롤링 업데이트할 때 Pod 가 움직이는 순서를 올바르게 늘어놓으세요.', '만들 때는 번호가 작은 쪽부터, 교체할 때는 번호가 큰 쪽부터입니다.', NULL, NULL, '[]', 'order', '["이미지를 바꾸면 `db-2` 부터 교체한다", "`db-0` 을 만든다", "`db-1` 이 준비되면 마지막으로 `db-0` 을 교체한다", "`db-1` 이 준비되면 `db-2` 를 만든다", "`db-2` 가 준비되면 `db-1` 을 교체한다", "`db-0` 이 준비되면 `db-1` 을 만든다"]', NULL, '기본 설정에서 Pod 는 `db-0` → `db-1` → `db-2` 순서로, 앞의 Pod 가 준비된 뒤 하나씩 만들어집니다. 이미지를 바꾸는 롤링 업데이트는 반대로 번호가 큰 Pod 부터 하나씩 교체합니다.', '[1, 5, 3, 0, 4, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 163 AND order_index = 16);
-- 세트 164 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 164, 16, '부모·자식 테이블 순서', '`orders.customer_id` 가 `customers(id)` 를 참조하는 외래 키일 때, 두 테이블을 만들고 지우는 올바른 순서로 늘어놓으세요.', '참조당하는 쪽(부모)이 먼저 있어야 만들 수 있고, 자식이 남은 부모는 지울 수 없습니다.', NULL, NULL, '[]', 'order', '["자식 테이블 `orders` 를 `DROP` 한다", "부모 테이블 `customers` 를 만든다", "부모 테이블 `customers` 를 `DROP` 한다", "`customers(id)` 를 참조하는 외래 키가 있는 자식 테이블 `orders` 를 만든다"]', NULL, '외래 키는 이미 있는 부모 테이블을 가리켜야 하므로 부모를 먼저 만듭니다. 자식 행이 있는 부모를 지우거나 `DROP` 하면 `ERROR 1451` 이 나므로, 지울 때는 자식 `orders` 부터 지우고 마지막에 부모를 지웁니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 164 AND order_index = 16);
-- 세트 165 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 165, 16, 'cron 필드 순서', 'cron 식 `*/5 9-18 * * 1-5` 의 다섯 필드를 왼쪽(첫 번째)부터 순서대로 늘어놓으세요.', '짧은 시간 단위에서 긴 단위로 가다가 마지막이 요일입니다.', NULL, NULL, '[]', 'order', '["월", "분", "요일", "시", "일"]', NULL, 'cron 의 다섯 필드는 왼쪽부터 분, 시, 일, 월, 요일 순서입니다. 그래서 이 줄은 평일(월~금) 9시~18시 사이에 5분마다 실행하라는 뜻입니다.', '[1, 3, 4, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 165 AND order_index = 16);
-- 세트 166 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 166, 16, 'NetworkPolicy 적용 단계', '정책이 없는 네임스페이스에 default-deny 를 적용하고, 필요한 접속만 다시 여는 순서를 올바르게 늘어놓으세요.', '열려 있음 → 모두 막음 → 필요한 것만 허용 순으로 진행합니다.', NULL, NULL, '[]', 'order', '["들어오는 접속이 모두 막힌 것을 확인한다", "`role=frontend` Pod 만 접속에 성공하고 다른 Pod 는 여전히 막힌다", "정책이 없는 상태에서는 모든 Pod 가 서로 접속된다", "`role=frontend` 의 80 포트 접속을 허용하는 정책을 추가한다", "`default-deny` 정책(`podSelector: {}`)을 적용한다"]', NULL, '정책이 없으면 모든 Pod 가 서로 접속됩니다. `podSelector: {}` 인 default-deny 로 들어오는 접속을 모두 막은 뒤, 허용 정책을 추가하면 그 정책에 맞는 Pod 만 접속에 성공하고 나머지는 계속 막힙니다.', '[2, 4, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 166 AND order_index = 16);
-- 세트 167 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 167, 16, '캐시를 살리는 Dockerfile 순서', '빌드 캐시를 잘 활용하도록 Dockerfile 의 줄을 위에서 아래로 올바른 순서로 늘어놓으세요.', '잘 안 바뀌는 것을 위에, 자주 바뀌는 소스를 아래에 둡니다.', NULL, NULL, '[]', 'order', '["`COPY src/ src/` 로 자주 바뀌는 소스를 마지막에 복사한다", "`COPY deps.txt .` 로 의존성 목록만 먼저 복사한다", "`FROM` 으로 기반 이미지를 정한다", "`RUN` 으로 의존성을 설치한다"]', NULL, '바뀐 줄 뒤의 단계는 모두 다시 실행되므로, 잘 바뀌지 않는 의존성 목록을 먼저 복사해 설치하고 자주 바뀌는 소스는 마지막에 복사합니다. 그러면 소스만 고쳤을 때 설치 단계는 캐시를 씁니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 167 AND order_index = 16);
-- 세트 168 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 16, '부분 스테이징 순서', '한 파일에서 떨어진 두 곳을 고친 뒤, 첫 번째 변경만 스테이징해서 확인하는 순서를 올바르게 늘어놓으세요.', '고치고, `add -p` 로 고르고, 마지막에 스테이징된 것을 확인합니다.', NULL, NULL, '[]', 'order', '["`git add -p` 를 실행한다", "`git diff --cached` 로 스테이징된 첫 번째 변경을 확인한다", "한 파일에서 서로 떨어진 두 곳을 고친다", "첫 덩어리는 `y`, 두 번째 덩어리는 `n` 으로 답한다"]', NULL, '`git add -p` 는 변경을 덩어리별로 물어봅니다. 첫 덩어리에 `y`, 두 번째에 `n` 이라고 답하면 첫 변경만 스테이징되어 `git diff --cached` 에 나오고, 두 번째는 `git diff` 에 남습니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 16);
-- 세트 169 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 169, 16, '집계 파이프라인 순서', '`words.txt` 의 같은 줄이 몇 번씩 나오는지 세고, 결과를 화면에 보이면서 `result.txt` 에도 저장하려고 합니다. 앞에서 뒤로 흐르는 순서대로 늘어놓으세요.', '`uniq` 는 이웃한 줄만 합치니 정렬이 먼저입니다. 저장은 마지막입니다.', NULL, NULL, '[]', 'order', '["`uniq -c` (이웃한 같은 줄을 세어 합친다)", "`tee result.txt` (화면에 보이면서 파일에도 저장한다)", "`cat words.txt` (줄을 흘려 보낸다)", "`sort` (같은 줄이 이웃하도록 정렬한다)"]', NULL, '`uniq -c` 는 이웃한 같은 줄만 합치므로 먼저 `sort` 로 같은 줄을 이웃하게 만들어야 합니다. 세어 낸 결과를 `tee` 가 화면에 보여 주면서 파일에도 저장하는 것이 마지막 단계입니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 169 AND order_index = 16);
-- 세트 170 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 16, 'OOMKilled 가 남기는 흔적', '메모리 한도를 넘긴 컨테이너가 `restartPolicy: Always` 인 Pod 에서 어떤 일을 겪는지, 일어나는 순서대로 늘어놓으세요.', '한도 초과 → 커널의 강제 종료 → 기록 → 재시작 → 확인 순서입니다.', NULL, NULL, '[]', 'order', '["`Always` 정책에 따라 컨테이너가 재시작되고 `RESTARTS` 가 늘어난다", "컨테이너가 메모리 한도(`limits`)보다 많이 쓰려고 한다", "`kubectl describe pod` 에서 직전 종료 이유(`lastState`)를 확인한다", "종료 이유 `OOMKilled` 와 종료 코드 `137` 이 기록된다", "커널이 컨테이너를 강제로 종료한다"]', NULL, '메모리 한도를 넘으면 커널이 컨테이너를 강제로 종료하고, 상태에 `OOMKilled` 와 종료 코드 `137` 이 기록됩니다. `Always` 이면 재시작되어 `RESTARTS` 가 늘고, 직전 종료 이유는 `describe` 의 `lastState` 에서 확인합니다.', '[1, 4, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 16);
-- 세트 171 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 171, 16, 'docker stop 의 종료 과정', 'PID 1 이 `SIGTERM` 을 처리하지 않는 컨테이너에 `docker stop` 을 했을 때 일어나는 일을 순서대로 늘어놓으세요.', '정중한 요청이 먼저, 강제 종료는 기다린 뒤에 합니다.', NULL, NULL, '[]', 'order', '["컨테이너의 PID 1 에 `SIGTERM` 이 전달된다", "`Exited (137)` 로 기록된다", "PID 1 이 신호를 처리하지 않아 기본 10초를 기다린다", "`docker stop 이름` 을 실행한다", "시간이 지나 `SIGKILL` 로 강제 종료된다"]', NULL, '`docker stop` 은 먼저 `SIGTERM` 으로 종료를 요청하고 기본 10초를 기다립니다. PID 1 이 신호를 처리하지 않으면 끝나지 않으므로 `SIGKILL` 로 강제 종료되고, 종료 코드는 128 + 9 = 137 입니다.', '[3, 0, 2, 4, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 171 AND order_index = 16);
-- 세트 172 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 16, 'fixup 으로 앞 커밋 고치기', '앞쪽 커밋에 빠뜨린 수정을 `fixup` 으로 합쳐 넣는 과정입니다. 올바른 순서대로 나열하세요.', '수정을 먼저 스테이징해야 fixup 커밋에 담깁니다.', NULL, NULL, '[]', 'order', '["고칠 내용을 수정하고 `git add` 로 스테이징한다", "`git commit --fixup 대상커밋` 으로 `fixup!` 커밋을 만든다", "`git log` 로 fixup 커밋이 대상 커밋에 합쳐져 사라진 것을 확인한다", "`git rebase -i --autosquash` 로 이력을 정리한다"]', NULL, '`--fixup` 커밋은 `fixup!` 메시지로 만들어지고, `rebase -i --autosquash` 를 해야 대상 커밋 바로 뒤로 옮겨져 합쳐집니다. 합쳐진 뒤에는 fixup 커밋이 이력에서 사라집니다.', '[0, 1, 3, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 16);
-- 세트 173 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 173, 16, 'umask 로 새 파일 권한 확인', '`umask` 의 원래 값을 먼저 확인한 뒤, 값을 바꾸고 새 파일의 권한을 확인하는 과정입니다. 올바른 순서대로 나열하세요.', '값을 정한 뒤에 만든 파일에만 적용됩니다.', NULL, NULL, '[]', 'order', '["`touch new.txt` 로 새 파일을 만든다", "`ls -l new.txt` 로 권한이 `-rw-------`(600)인지 확인한다", "`umask 077` 로 값을 바꾼다", "`umask` 로 현재 값을 확인한다"]', NULL, '`umask` 는 앞으로 만들 파일의 권한에 적용되고 이미 있는 파일은 바꾸지 않습니다. 그래서 값을 바꾼 뒤에 새 파일을 만들고 확인해야 하며, `077` 이면 새 파일은 600 이 됩니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 173 AND order_index = 16);
-- 세트 174 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 16, 'diff 로 확인하고 적용하기', 'YAML 을 고친 뒤 안전하게 클러스터에 반영하는 과정입니다. 올바른 순서대로 나열하세요.', '적용하기 전에 먼저 눈으로 확인합니다.', NULL, NULL, '[]', 'order', '["`kubectl diff -f 파일` 로 달라질 줄을 미리 본다", "의도한 변경이 맞으면 `kubectl apply -f 파일` 로 적용한다", "`kubectl rollout status` 로 롤아웃이 끝났는지 확인한다", "YAML 파일을 수정한다"]', NULL, '`kubectl diff` 는 클러스터를 바꾸지 않고 차이만 보여 주므로 `apply` 앞에 둡니다. 적용 뒤에는 `rollout status` 로 교체가 끝났는지 확인합니다.', '[3, 0, 1, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 16);
-- 세트 175 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 175, 16, '고아 컨테이너 정리', 'compose 파일에서 서비스를 지운 뒤 남은 컨테이너를 정리하는 과정입니다. 올바른 순서대로 나열하세요.', '경고가 나와야 고아가 있다는 걸 알 수 있습니다.', NULL, NULL, '[]', 'order', '["`docker compose down --remove-orphans` 로 정리한다", "compose 파일에서 서비스 하나를 지운다", "`docker compose up -d` 를 실행한다", "`Found orphan containers ...` 경고를 확인한다"]', NULL, '서비스를 지우고 `up -d` 를 하면 고아 컨테이너 경고가 나오지만 컨테이너는 자동으로 지워지지 않습니다. 경고를 확인한 뒤 `down --remove-orphans` 로 정리합니다.', '[1, 2, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 175 AND order_index = 16);
-- 세트 176 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 176, 16, 'cherry-pick 충돌 해결', '`cherry-pick` 이 충돌 났을 때 해결해서 이어 가는 과정입니다. 올바른 순서대로 나열하세요.', '고친 파일을 스테이징해야 이어 갈 수 있습니다.', NULL, NULL, '[]', 'order', '["`git status --short` 로 `AA conf.txt` 같은 충돌 파일을 확인한다", "`git cherry-pick b1` 을 실행해 충돌이 난다", "파일을 열어 충돌 부분을 고치고 `git add conf.txt` 를 한다", "`git cherry-pick --continue` 로 커밋을 만든다"]', NULL, '충돌 난 파일을 고치고 `git add` 한 뒤에 `--continue` 를 해야 원래 메시지로 커밋이 만들어집니다. 포기하려면 `--abort` 를 쓰면 됩니다.', '[1, 0, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 176 AND order_index = 16);
-- 세트 177 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 177, 16, 'awk 가 실행되는 순서', '`awk \'BEGIN{...} 패턴 {...} END{...}\' 파일` 이 실행되는 순서입니다. 올바른 순서대로 나열하세요.', '`BEGIN` 은 입력을 읽기 전, `END` 는 다 읽은 뒤입니다.', NULL, NULL, '[]', 'order', '["입력이 모두 끝난 뒤 `END` 블록을 실행한다", "그 줄에 패턴과 액션을 적용한다 (줄마다 반복)", "`BEGIN` 블록을 한 번 실행한다", "입력에서 한 줄을 읽어 필드(`$1`, `$2` ...)로 나눈다"]', NULL, '`BEGIN` 은 첫 줄을 읽기 전에 한 번 실행되고, 본문은 줄마다 반복되며, `END` 는 입력이 끝난 뒤에 실행됩니다. 그래서 합계는 `END` 에서 출력합니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 177 AND order_index = 16);
-- 세트 178 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 16, 'taint 로 Pending 만들고 풀기', '노드에 taint 를 붙였다가 지워서 Pod 가 실행되기까지의 과정입니다. 올바른 순서대로 나열하세요.', 'taint 를 지운 뒤에야 Pod 가 움직입니다.', NULL, NULL, '[]', 'order', '["Pod 가 스케줄되어 `Running` 이 된 것을 확인한다", "toleration 이 없는 Pod 를 만들면 `Pending` 이 된다", "`kubectl taint nodes 노드 key=value:NoSchedule` 로 taint 를 붙인다", "이벤트에서 `untolerated taint` 메시지를 확인한다", "`kubectl taint nodes 노드 key-` 로 taint 를 지운다"]', NULL, 'toleration 이 없는 Pod 는 `NoSchedule` taint 가 있는 노드에 올라가지 못해 `Pending` 이 되고 이벤트에 이유가 남습니다. taint 를 `key-` 로 지우면 곧 스케줄되어 `Running` 이 됩니다.', '[2, 1, 3, 4, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 16);
-- 세트 179 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 179, 16, '네트워크 만들고 정리하기', '사용자 정의 네트워크를 만들어 쓰고 지우는 과정입니다. 올바른 순서대로 나열하세요.', '컨테이너가 연결된 동안에는 네트워크를 지울 수 없습니다.', NULL, NULL, '[]', 'order', '["같은 네트워크의 컨테이너 이름이 풀리는지 확인한다", "`docker network rm mynet` 로 네트워크를 지운다", "연결된 컨테이너를 `docker rm` 으로 지운다", "`docker network create mynet` 로 네트워크를 만든다", "`--network mynet` 으로 컨테이너를 실행한다"]', NULL, '네트워크를 먼저 만들어야 컨테이너를 연결할 수 있습니다. 연결된 컨테이너가 있으면 `network rm` 이 `active endpoints` 오류로 거부되므로 컨테이너를 먼저 지운 뒤 네트워크를 지웁니다.', '[3, 4, 0, 2, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 179 AND order_index = 16);
-- 세트 180 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 16, '잃은 커밋 되살리기', '`reset --hard` 로 사라진 커밋을 되살리는 과정입니다. 올바른 순서대로 나열하세요.', '해시를 알아야 브랜치를 만들 수 있습니다.', NULL, NULL, '[]', 'order', '["`git log recovered` 로 커밋이 돌아온 것을 확인한다", "`git branch recovered 해시` 로 그 커밋에 브랜치를 만든다", "`git reset --hard HEAD~1` 로 커밋이 브랜치에서 사라진다", "`git reflog` 에서 사라진 커밋의 해시를 찾는다"]', NULL, '`reset --hard` 뒤에도 객체는 남아 있어서 `reflog` 로 해시를 찾을 수 있습니다. 그 해시로 브랜치를 만들면 커밋이 다시 닿을 수 있게 되어 되살아납니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 16);
-- 세트 182 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 182, 16, 'port-forward 로 Pod 접속하기', '`kubectl port-forward` 로 Pod 에 접속해 보는 과정입니다. 올바른 순서대로 나열하세요.', '전달은 명령이 실행되는 동안에만 됩니다.', NULL, NULL, '[]', 'order', '["Pod 의 8080 포트에서 온 응답을 확인한다", "`Ctrl+C` 로 `port-forward` 를 멈춘다", "`kubectl port-forward pod/solo 18083:8080` 을 실행해 둔다", "다른 터미널에서 `wget http://localhost:18083` 으로 요청한다"]', NULL, '`port-forward` 는 명령이 실행 중일 때만 `localhost` 의 포트를 Pod 포트로 이어 줍니다. 그래서 먼저 켜 두고 요청한 뒤, 끝나면 `Ctrl+C` 로 멈춥니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 182 AND order_index = 16);
-- 세트 183 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 183, 16, '태그 붙이고 이미지 지우기', '이미지에 태그를 하나 더 붙였다가 모두 지우는 과정입니다. 올바른 순서대로 나열하세요.', '마지막 태그를 지울 때 비로소 이미지가 사라집니다.', NULL, NULL, '[]', 'order', '["`docker rmi etude:alias` 를 하면 `Untagged` 만 나온다", "`docker rmi etude:v1` 을 하면 `Untagged` 와 `Deleted` 가 나온다", "`docker tag etude:v1 etude:alias` 로 이름을 하나 더 붙인다", "`docker images` 로 `etude:v1` 이 그대로 남은 것을 확인한다"]', NULL, '같은 이미지에 태그가 둘이면 하나를 지워도 `Untagged` 만 나오고 이미지는 남습니다. 마지막 태그를 지울 때 `Deleted: sha256:...` 가 함께 나오며 이미지가 삭제됩니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 183 AND order_index = 16);
-- 세트 184 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 184, 16, '병합 충돌 해결하기', '`git merge` 충돌을 해결해 병합을 마치는 과정입니다. 올바른 순서대로 나열하세요.', '충돌이 남은 채로는 커밋할 수 없습니다.', NULL, NULL, '[]', 'order', '["`git merge feat` 를 하면 `CONFLICT` 가 나온다", "파일을 열어 `<<<<<<<` 마커를 정리하고 내용을 고친다", "`git add f.txt` 로 해결했음을 알린다", "`git merge --continue` 로 병합 커밋을 만든다", "`git status --short` 로 `UU f.txt` 같은 충돌 파일을 확인한다"]', NULL, '충돌 난 파일을 고치고 `git add` 로 알린 뒤에 `git merge --continue` 를 해야 병합 커밋(부모 2개)이 만들어집니다. 충돌이 남은 채 `git commit` 을 하면 거부됩니다.', '[0, 4, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 184 AND order_index = 16);
-- 세트 185 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 185, 16, 'grep -q 로 조건 검사하기', '`if grep -q 패턴 파일; then ...` 가 동작하는 순서입니다. 올바른 순서대로 나열하세요.', '`grep` 이 먼저 결과(종료 코드)를 만들어야 `if` 가 볼 수 있습니다.', NULL, NULL, '[]', 'order', '["종료 코드가 0 이면 `then` 쪽 명령이 실행된다", "`if` 가 그 종료 코드를 검사한다", "찾으면 종료 코드 0, 못 찾으면 1 이 남는다 (출력은 없다)", "`grep -q \'apple\' file` 을 실행한다"]', NULL, '`-q` 는 출력 없이 종료 코드만 남깁니다. `if` 는 그 종료 코드를 보고 0 이면 `then` 을 실행하므로 `grep` 실행, 종료 코드, 검사, 실행 순서가 됩니다.', '[3, 2, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 185 AND order_index = 16);
-- 세트 186 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 16, '외부 주소 연결 순서', '셀렉터가 없는 Service 에 외부 주소를 연결하고 접속해 보는 과정입니다. 올바른 **순서**대로 놓으세요.', '연결 전과 후를 비교하는 순서입니다.', NULL, NULL, '[]', 'order', '["라벨 `kubernetes.io/service-name: manual` 을 붙이고 `addresses` 와 `ports` 를 적은 `EndpointSlice` 를 만든다", "셀렉터가 없는 Service `manual` 을 만든다", "Service 이름으로 접속해 응답이 오는지 확인한다", "`describe` 로 `Endpoints: <none>` 이어서 접속이 `Connection refused` 인 것을 확인한다"]', NULL, '셀렉터가 없으면 Service 는 Pod 를 자동으로 찾지 못해 엔드포인트가 비어 있고 접속은 `Connection refused` 입니다. 이때 `kubernetes.io/service-name` 라벨이 붙은 `EndpointSlice` 로 주소를 직접 이어 주면 `Endpoints` 에 주소가 생기고 접속됩니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 16);
-- 세트 187 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 187, 16, 'ONBUILD 만들고 쓰기', '부모 이미지에 `ONBUILD` 를 넣고 자식 이미지에서 실행되게 하는 과정입니다. 자식 Dockerfile 은 부모 이미지를 빌드한 뒤에 작성합니다. 올바른 **순서**대로 놓으세요.', '예약은 부모를 빌드할 때, 실행은 자식을 빌드할 때입니다.', NULL, NULL, '[]', 'order', '["부모 이미지를 빌드한다 (명령은 실행되지 않고 `OnBuild` 에 저장된다)", "자식 이미지를 빌드한다 (예약된 명령이 실행되어 `/t.txt` 가 생긴다)", "부모 Dockerfile 에 `ONBUILD RUN echo triggered > /t.txt` 를 적는다", "자식 Dockerfile 에 `FROM 부모` 를 적는다"]', NULL, '`ONBUILD` 명령은 부모 이미지를 빌드할 때 실행되지 않고 설정의 `OnBuild` 에 저장만 됩니다. 자식이 `FROM 부모` 로 빌드될 때 비로소 그 명령이 실행됩니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 187 AND order_index = 16);
-- 세트 188 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 188, 16, '셸 별칭이 실행되는 순서', '`git config alias.who \'!echo shell-alias\'` 로 만든 별칭을 `git who` 로 쓸 때 일어나는 일입니다. 올바른 **순서**대로 놓으세요.', '설정이 먼저이고 그다음 사용입니다.', NULL, NULL, '[]', 'order', '["셸이 `echo shell-alias` 를 실행해 `shell-alias` 가 출력된다", "`git who` 를 실행한다", "`git config alias.who \'!echo shell-alias\'` 로 별칭을 설정한다", "git 이 `who` 별칭의 값이 `!` 로 시작하는 것을 보고 git 하위 명령 대신 셸 명령으로 다룬다"]', NULL, '별칭을 먼저 설정해야 `git who` 로 쓸 수 있습니다. 값이 `!` 로 시작하면 git 은 이를 하위 명령이 아니라 셸 명령으로 실행하고, 그 결과 `shell-alias` 가 출력됩니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 188 AND order_index = 16);
-- 세트 189 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 189, 16, '빈도 순위 파이프 순서', '파일의 단어를 많이 나온 순서대로 세어 보는 파이프입니다. 올바른 **순서**대로 놓으세요.', '`uniq` 는 이웃한 줄만 합치므로 그 앞에 무엇이 필요한지 떠올려 보세요.', NULL, NULL, '[]', 'order', '["`uniq -c` 로 이웃한 같은 줄을 합치고 횟수를 센다", "`sort -nr` 로 횟수가 큰 것부터 숫자 정렬한다", "`sort` 로 같은 단어가 이웃하도록 정렬한다", "`cat words.txt` 로 한 줄에 단어 하나씩 읽어 낸다"]', NULL, '`uniq` 는 이웃한 같은 줄만 합치므로 먼저 `sort` 가 필요합니다. 횟수를 센 뒤에는 `-n` 으로 숫자 크기를, `-r` 로 큰 수부터 정렬해 순위를 만듭니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 189 AND order_index = 16);
-- 세트 190 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 190, 16, '라벨로 안전하게 삭제하기', '라벨 `tier=tmp` 인 ConfigMap 을 지우는 안전한 과정입니다. 올바른 **순서**대로 놓으세요.', '확인, 미리 보기, 실행, 결과 확인의 순서입니다.', NULL, NULL, '[]', 'order', '["`kubectl get cm -l tier=tmp` 로 `No resources found` 가 나오는지 확인한다", "`kubectl get cm -l tier=tmp` 로 지울 대상을 먼저 확인한다", "`kubectl delete cm -l tier=tmp` 로 실제로 삭제한다", "`kubectl delete cm -l tier=tmp --dry-run=client` 로 지울 대상을 미리 본다 (실제로는 지워지지 않는다)"]', NULL, '라벨 셀렉터는 `delete` 에도 같은 문법으로 쓰이고 조건에 맞는 리소스를 모두 지웁니다. 그래서 대상을 먼저 조회하고 `--dry-run=client` 로 미리 본 뒤 삭제하고, 마지막에 사라졌는지 확인합니다.', '[1, 3, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 190 AND order_index = 16);
-- 세트 191 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 191, 16, '실행 중 메모리 한도 조정', '실행 중인 컨테이너의 메모리 한도를 재시작 없이 바꾸는 과정입니다. 바꾸기 전에 실행 중인지부터 확인합니다. 올바른 **순서**대로 놓으세요.', '바꿀 대상이 있어야 바꾸고, 바꾼 뒤에 확인합니다.', NULL, NULL, '[]', 'order', '["`docker ps` 로 컨테이너 `w` 가 실행 중인지 확인한다", "`docker update --memory 64m --memory-swap 64m w` 로 한도를 바꾼다", "`docker run -d --name w alpine sleep 600` 으로 컨테이너를 실행한다", "`docker inspect w` 의 `HostConfig.Memory` 가 `67108864` 인지 확인한다"]', NULL, '`docker update` 는 컨테이너를 다시 만들지 않고 실행 중에 자원 한도를 바꿉니다. 바꾼 값은 `docker inspect` 의 `HostConfig` 에서 읽어 확인합니다.', '[2, 0, 1, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 191 AND order_index = 16);
-- 세트 192 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 192, 16, '패치 파일로 변경 주고받기', '한 저장소의 마지막 커밋을 다른 저장소에 패치로 전달하는 과정입니다. 올바른 **순서**대로 놓으세요.', '만들고, 보내고, 검사하고, 적용합니다.', NULL, NULL, '[]', 'order', '["받는 쪽에서 `git apply --check 패치` 로 적용 가능한지 검사한다", "`git am 패치` 로 적용해 작성자와 메시지가 담긴 커밋을 만든다", "보내는 쪽에서 `git format-patch -1` 로 패치 파일을 만든다", "패치 파일을 받는 쪽에 전달한다"]', NULL, '`format-patch` 는 커밋을 패치 파일로 만들고, `apply --check` 는 적용하지 않고 가능한지만 검사합니다. `am` 은 패치의 작성자와 메시지로 커밋까지 만들어 줍니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 192 AND order_index = 16);
-- 세트 193 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 193, 16, '끊어진 링크 점검하기', '심볼릭 링크가 끊어졌는지 확인하는 과정입니다. 올바른 **순서**대로 놓으세요.', '먼저 링크가 있는지, 그다음 대상이 있는지 묻습니다.', NULL, NULL, '[]', 'order', '["`test -e sym` 이 거짓이라서 가리키는 대상이 없는 끊어진 링크임을 확인한다", "`test -L sym` 이 참이라서 링크 자체는 남아 있음을 확인한다", "`t.txt` 를 만들고 `ln -s t.txt sym` 으로 심볼릭 링크를 만든다", "`rm t.txt` 로 원본 파일을 지운다"]', NULL, '원본을 지워도 심볼릭 링크 파일은 남아 있어 `test -L` 은 참입니다. 하지만 가리키는 대상이 없어 `test -e` 는 거짓이므로 끊어진 링크라고 판단합니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 193 AND order_index = 16);
-- 세트 194 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 16, '여러 변경을 한 번의 롤아웃으로', '이미지와 환경 변수를 한 번의 롤아웃으로 적용하는 과정입니다. 올바른 **순서**대로 놓으세요.', '중지, 변경, 재개, 확인의 순서입니다.', NULL, NULL, '[]', 'order', '["`kubectl rollout resume deploy/web` 으로 재개한다", "`kubectl rollout pause deploy/web` 으로 롤아웃을 일시 중지한다", "`kubectl rollout status deploy/web` 으로 한 번의 롤아웃이 끝났는지 확인한다", "`set image` 와 `set env` 로 변경을 쌓는다 (저장만 되고 롤아웃은 시작되지 않는다)"]', NULL, '일시 중지 중에는 변경이 저장만 되고 롤아웃이 시작되지 않습니다. `resume` 하면 쌓인 변경이 한 번의 롤아웃으로 적용되어 리비전이 한 번만 늘어납니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 16);
-- 세트 195 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 195, 16, '환경 변수 파일로 실행하기', '환경 변수 파일로 컨테이너를 실행하고 확인하는 과정입니다. 올바른 **순서**대로 놓으세요.', '파일 준비, 실행, 확인, 덮어쓰기 실험의 순서입니다.', NULL, NULL, '[]', 'order', '["`docker run --rm --env-file app.env alpine env` 로 실행한다", "`-e X=cli` 를 더해 다시 실행해 `X` 가 `cli` 로 바뀌는지 확인한다", "출력에서 `X=1` 과 `Y=two words` 가 들어갔는지 확인한다", "`X=1` 과 `Y=two words` 가 적힌 `app.env` 파일을 만든다"]', NULL, '`--env-file` 은 파일의 `이름=값` 줄을 환경 변수로 넣습니다. 같은 이름을 `-e` 로 함께 주면 `-e` 의 값이 적용됩니다.', '[3, 0, 2, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 195 AND order_index = 16);
-- 세트 196 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 16, '이름 바꾼 파일 이력 추적', '이름이 바뀐 파일의 이력을 끝까지 따라가는 과정입니다. 올바른 **순서**대로 놓으세요.', '`--follow` 없이 먼저 보고, 그다음 `--follow` 로 비교합니다.', NULL, NULL, '[]', 'order', '["`git log --oneline -- b.txt` 를 실행하면 이름이 바뀐 커밋 1개만 나온다", "`git log --oneline --follow -- b.txt` 를 실행해 이전 이름 `a.txt` 때의 커밋까지 본다", "`git mv a.txt b.txt` 로 이름을 바꾸고 커밋한다", "`--name-status` 를 함께 써서 `R082 a.txt b.txt` 줄로 이름이 바뀐 커밋을 확인한다"]', NULL, '`--follow` 없이는 현재 이름 `b.txt` 의 이력만 나오고, `--follow` 를 붙이면 이전 이름 때의 커밋까지 이어서 보입니다. `--name-status` 를 더하면 이름이 바뀐 커밋에 `R` 줄이 나타납니다.', '[2, 0, 1, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 16);
-- 세트 197 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 197, 16, 'getopts 로 인자 처리하기', '`go.sh -a -b val file1 file2` 를 처리하는 스크립트의 흐름입니다. 올바른 **순서**대로 놓으세요.', '옵션을 모두 읽은 뒤에야 `OPTIND` 가 정해집니다.', NULL, NULL, '[]', 'order', '["루프가 끝나면 `OPTIND` 가 `4` 로 첫 일반 인자의 번호를 가리킨다", "`shift $((OPTIND-1))` 로 옵션 부분을 밀어 낸다", "남은 `\\"$@\\"` (`file1 file2`) 로 파일 인자를 처리한다", "`while getopts \\"ab:\\" o` 루프로 옵션을 하나씩 읽는다 (`b` 의 값은 `OPTARG` 에 담긴다)"]', NULL, '`getopts` 가 옵션을 모두 읽고 나면 `OPTIND` 는 첫 일반 인자의 번호가 됩니다. 그 값에서 1 을 뺀 만큼 `shift` 하면 `file1 file2` 만 남아 `"$@"` 로 처리할 수 있습니다.', '[3, 0, 1, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 197 AND order_index = 16);
-- 세트 198 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 16, 'startupProbe 와 livenessProbe 순서', '시작에 시간이 걸리는 컨테이너에 `startupProbe` 와 `livenessProbe` 를 함께 단 Pod 의 진행 순서입니다. 올바른 **순서**대로 놓으세요.', '`startupProbe` 가 끝나기 전에는 `livenessProbe` 가 실행되지 않습니다.', NULL, NULL, '[]', 'order', '["이후 `livenessProbe` 검사가 시작되고 READY 가 `1/1` 이 된다", "앱이 시작되는 동안 `startupProbe` 만 검사하고 `livenessProbe` 는 미뤄진다 (READY `0/1`)", "두 프로브가 달린 Pod 를 만든다", "`startupProbe` 가 성공한다"]', NULL, '`startupProbe` 가 있으면 성공할 때까지 `livenessProbe` 가 실행되지 않아 느리게 시작하는 앱이 중간에 죽지 않습니다. 성공한 뒤에야 `livenessProbe` 가 시작되고 READY 가 `1/1` 이 됩니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 16);
-- 세트 199 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 199, 16, '만들어 두고 실행해 보기', '컨테이너를 먼저 만들고 나중에 실행하는 과정입니다. 올바른 **순서**대로 놓으세요.', '만들기와 실행은 별개의 단계입니다.', NULL, NULL, '[]', 'order', '["`docker start -a c` 로 시작하고 출력 `hello` 를 바로 본다", "`docker create --name c alpine echo hello` 로 컨테이너를 만든다", "`docker ps -a` 를 다시 보면 상태가 종료(`Exited`)로 바뀌어 있다", "`docker ps -a` 로 `Created` 상태인 것을 확인한다 (`docker ps` 에는 보이지 않는다)"]', NULL, '`docker create` 는 컨테이너를 만들기만 해서 `Created` 상태이고 `docker ps` 에는 보이지 않습니다. `docker start -a` 로 시작하면 출력이 바로 보이고, 명령이 끝나면 종료 상태가 됩니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 199 AND order_index = 16);
-- 세트 200 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 16, '리셋 실수 되돌리는 순서', '`git reset --hard` 로 커밋을 잘못 되돌렸다가 `reflog` 로 복구하는 과정의 **순서**를 맞춰 보세요.', '되돌릴 위치는 `reflog` 에서 찾습니다.', NULL, NULL, '[]', 'order', '["`git reset --hard <찾은 해시>` 로 그 위치로 돌아간다", "`git reset --hard HEAD~1` 로 마지막 커밋을 되돌려 버린다", "`git log --oneline` 으로 커밋이 돌아왔는지 확인한다", "`git reflog` 로 되돌리기 전 위치의 해시를 찾는다"]', NULL, '실수로 `--hard` 리셋을 하면 먼저 `git reflog` 로 이전 위치의 해시를 찾고, 그 해시로 다시 `reset --hard` 를 하면 커밋이 돌아옵니다. 마지막에 `git log` 로 확인합니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 16);
-- 세트 201 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 201, 16, '파일 줄을 배열로 읽기 순서', '파일을 만들고 `mapfile` 로 배열에 읽은 뒤 개수와 마지막 원소를 확인하는 **순서**를 맞춰 보세요. (개수를 먼저 확인하고 마지막 원소를 꺼냅니다)', '파일이 있어야 읽을 수 있고, 배열이 있어야 개수를 셀 수 있습니다.', NULL, NULL, '[]', 'order', '["`mapfile -t lines < f` 로 줄을 배열에 읽는다", "`echo \\"${lines[-1]}\\"` 로 마지막 원소를 꺼낸다", "`printf \'a\\\\nb\\\\n\' > f` 로 두 줄짜리 파일을 만든다", "`echo \\"${#lines[@]}\\"` 로 원소 개수를 확인한다"]', NULL, '`mapfile -t` 는 파일의 줄을 배열 원소로 읽어 줄바꿈을 떼어 냅니다. 그래서 파일을 먼저 만들고, 읽은 뒤에 `${#lines[@]}` 로 개수를, `${lines[-1]}` 로 마지막 원소를 봅니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 201 AND order_index = 16);
-- 세트 202 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 202, 16, '설정 바꿔 롤링하는 순서', '`configMapGenerator` 의 값을 `MODE=a` 에서 `MODE=z` 로 바꿔 새로 롤링하고 정리하는 **순서**를 맞춰 보세요.', '고치기 전에 처음 배포가 있어야 하고, 정리는 맨 마지막입니다.', NULL, NULL, '[]', 'order', '["`kubectl delete cm <옛 이름>` 으로 남은 옛 ConfigMap 을 정리한다", "`MODE=a` 로 `kubectl apply -k` 해 처음 배포한다", "`kubectl apply -k` 로 다시 적용한다 (새 ConfigMap 이 만들어지고 Pod 가 롤링된다)", "`kubectl diff -k` 로 바뀔 부분을 확인한다", "kustomization 의 `literals` 를 `MODE=z` 로 고친다"]', NULL, '생성기 내용을 바꾸면 해시가 달라져 새 ConfigMap 이 생기고 Deployment 가 새로 롤링됩니다. 먼저 `diff -k` 로 확인한 뒤 적용하고, 자동으로 지워지지 않는 옛 ConfigMap 은 마지막에 직접 지웁니다.', '[1, 4, 3, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 202 AND order_index = 16);
-- 세트 203 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 203, 16, 'commit 한 이미지 쓰고 지우기 순서', '컨테이너를 `docker commit` 으로 이미지로 만든 뒤, 그 이미지로 새 컨테이너를 띄우고 모두 정리하는 **순서**를 맞춰 보세요.', '컨테이너가 쓰고 있는 이미지는 지울 수 없습니다.', NULL, NULL, '[]', 'order', '["`docker rm -f web2` 로 그 컨테이너를 지운다", "`docker commit web myimg:v1` 으로 이미지를 만든다", "`docker rmi myimg:v1` 으로 이미지를 지운다", "`docker run -d --name web2 myimg:v1 sleep 300` 으로 새 컨테이너를 띄운다"]', NULL, '이미지가 있어야 새 컨테이너를 띄울 수 있고, 컨테이너가 쓰고 있는 이미지는 `rmi` 로 지워지지 않습니다. 그래서 컨테이너를 먼저 지운 뒤 이미지를 지웁니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 203 AND order_index = 16);
-- 세트 204 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 204, 16, '백그라운드 작업 끝내기 순서', '쉘에서 백그라운드 작업을 띄우고 번호를 확인한 뒤 종료하고 기다리는 **순서**를 맞춰 보세요.', '작업이 있어야 번호가 생기고, `wait` 를 종료 전에 하면 오래 기다리게 됩니다.', NULL, NULL, '[]', 'order', '["`kill %1` 로 작업을 종료한다", "`sleep 301 &` 로 백그라운드에서 실행한다", "`wait %1` 로 끝난 작업을 거두고 종료 코드를 받는다", "`jobs` 로 작업 번호를 확인한다"]', NULL, '`&` 로 작업을 띄우면 `jobs` 에 번호(`%1`)가 보이고, 그 번호로 `kill %1` 을 할 수 있습니다. 종료 뒤에 `wait` 를 하면 바로 끝난 작업의 종료 코드를 받습니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 204 AND order_index = 16);
-- 세트 205 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 16, '네임스페이스 만들고 지우기 순서', '네임스페이스를 만들고 Pod 를 올려 확인한 뒤 통째로 지우는 **순서**를 맞춰 보세요.', '네임스페이스가 있어야 그 안에 Pod 를 만들 수 있습니다.', NULL, NULL, '[]', 'order', '["`kubectl get pod -n dev` 로 Pod 를 확인한다", "`kubectl delete ns dev` 로 네임스페이스를 지운다", "`kubectl create namespace dev` 로 네임스페이스를 만든다", "`kubectl run p1 --image=nginx -n dev` 로 Pod 를 만든다"]', NULL, '네임스페이스를 먼저 만들어야 그 안에 Pod 를 만들 수 있고, `-n dev` 로 확인합니다. 네임스페이스를 지우면 안의 오브젝트도 함께 지워지므로 마지막에 합니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 16);
-- 세트 206 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 206, 16, 'Dockerfile 고친 뒤 반영 순서', '`build:` 로 정의한 서비스의 Dockerfile 을 고친 뒤 새 내용을 반영해 올리고 정리하는 **순서**를 맞춰 보세요.', '이미지를 새로 만들어야 올릴 때 새 내용이 반영됩니다.', NULL, NULL, '[]', 'order', '["`docker compose up -d` 로 새 이미지로 올린다", "`docker compose down` 으로 정리한다", "Dockerfile 을 고친다", "`docker compose build` 로 새 이미지를 만든다"]', NULL, 'Dockerfile 을 고친 뒤에는 `build` 로 이미지를 새로 만들어야 `up -d` 가 새 내용을 씁니다. `down` 은 올린 것을 정리하는 마지막 단계입니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 206 AND order_index = 16);
-- 세트 207 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 207, 16, 'until 반복이 도는 순서', '`i=0; until [ $i -ge 3 ]; do echo $i; i=$((i+1)); done` 에서 **첫 번째 반복**이 실행되는 순서를 맞춰 보세요.', '`until` 은 조건이 거짓인 동안 반복합니다.', NULL, NULL, '[]', 'order', '["조건 `[ $i -ge 3 ]` 을 검사한다 (거짓이라 반복한다)", "`echo $i` 로 `0` 을 출력한다", "`i=0` 으로 시작한다", "`i=$((i+1))` 로 `i` 를 1 로 올린다"]', NULL, '먼저 `i=0` 을 넣고, `until` 이 조건을 검사해 거짓이면 본문을 실행합니다. 본문은 `echo $i` 로 0 을 출력한 뒤 `i` 를 1 올리고, 그 다음에 다시 조건을 검사합니다.', '[2, 0, 1, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 207 AND order_index = 16);
-- 세트 208 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 208, 16, '설정 바꾸고 Pod 에 반영하기 순서', 'ConfigMap 값을 고친 뒤 Deployment 의 Pod 에 새 값이 적용되게 하는 **순서**를 맞춰 보세요.', '환경 변수는 Pod 가 시작할 때만 읽습니다.', NULL, NULL, '[]', 'order', '["`kubectl rollout restart deploy web` 으로 Pod 를 다시 만든다", "`kubectl create cm c1 --from-literal=k1=v1` 으로 ConfigMap 을 만든다", "`kubectl patch cm c1 --type merge -p \'{\\"data\\":{\\"k1\\":\\"v2\\"}}\'` 로 값을 고친다", "`c1` 을 `envFrom` 으로 쓰는 Deployment `web` 을 올린다"]', NULL, 'ConfigMap 을 먼저 만들고 그것을 참조하는 Deployment 를 올립니다. 환경 변수로 넣은 값은 실행 중인 Pod 에 자동 반영되지 않으므로 ConfigMap 을 고친 뒤 `rollout restart` 로 Pod 를 새로 만듭니다.', '[1, 3, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 208 AND order_index = 16);
-- 세트 209 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 16, '포트 충돌 피해 다시 띄우기 순서', '`-p 18217:80` 으로 컨테이너를 띄우고 연결을 확인한 뒤, 같은 호스트 포트로 다른 컨테이너를 다시 띄우는 **순서**를 맞춰 보세요.', '호스트 포트는 한 번에 한 컨테이너만 쓸 수 있습니다.', NULL, NULL, '[]', 'order', '["`docker rm -f web` 으로 컨테이너를 지워 호스트 포트를 비운다", "`docker run -d --name web -p 18217:80 alpine sleep 600` 으로 실행한다", "`docker run -d --name web2 -p 18217:80 alpine sleep 600` 으로 같은 포트로 새로 실행한다", "`docker port web` 으로 연결된 포트를 확인한다"]', NULL, '호스트 포트가 이미 쓰이고 있으면 같은 포트로 실행이 실패합니다. 그래서 연결을 확인한 뒤 컨테이너를 지워 포트를 비우고, 그다음에 같은 포트로 새 컨테이너를 띄웁니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 16);
-- 세트 210 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 210, 16, '프로세스 생존 확인과 종료 순서', '백그라운드 `sleep` 을 띄우고 살아 있는지 확인한 뒤 강제 종료하고 종료 코드를 받는 **순서**를 맞춰 보세요.', '`kill -0` 은 신호를 보내지 않고 존재만 확인합니다.', NULL, NULL, '[]', 'order', '["`wait $!; echo $?` 로 종료 코드(137)를 확인한다", "`kill -9 $!` 로 강제 종료한다", "`sleep 300 &` 로 백그라운드에서 실행한다", "`kill -0 $!` 로 살아 있는지 확인한다"]', NULL, '프로세스가 있어야 `kill -0` 으로 생존을 확인할 수 있고, 그 뒤에 `kill -9` 로 끝냅니다. 신호로 끝난 프로세스의 종료 코드는 128+신호 번호라 `wait` 로 보면 137 입니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 210 AND order_index = 16);
-- 세트 211 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 211, 16, '설정 파일 고쳐 다시 apply 순서', '이미 `apply` 한 ConfigMap 의 YAML 을 고친 뒤 차이를 확인하고 다시 적용하는 **순서**를 맞춰 보세요.', '`diff` 는 클러스터를 바꾸지 않고 차이만 보여 줍니다.', NULL, NULL, '[]', 'order', '["`kubectl apply -f cm.yaml` 로 다시 적용한다 (`configured`)", "`cm.yaml` 의 값을 고친다", "`kubectl apply -f cm.yaml` 로 처음 적용한다 (`created`)", "`kubectl diff -f cm.yaml` 로 바뀔 부분을 확인한다"]', NULL, '처음 적용하면 `created`, 파일을 고친 뒤 `diff` 로 차이를 보고 다시 `apply` 하면 `configured` 가 나옵니다. `diff` 는 적용 전에 확인하는 용도입니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 211 AND order_index = 16);
-- 세트 212 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 212, 16, '컨테이너 종료 코드 확인 순서', '컨테이너를 띄워 강제 종료하고 종료 코드를 확인한 뒤 지우는 **순서**를 맞춰 보세요.', '지우고 나면 종료 코드를 볼 수 없습니다.', NULL, NULL, '[]', 'order', '["`docker rm c1` 으로 컨테이너를 지운다", "`docker run -d --name c1 alpine sleep 300` 으로 실행한다", "`docker wait c1` 로 종료 코드(137)를 확인한다", "`docker kill c1` 로 강제 종료한다"]', NULL, '실행 중인 컨테이너를 `kill` 하면 SIGKILL 로 끝나 종료 코드가 137 입니다. 이미 끝난 컨테이너에 `wait` 를 써도 종료 코드를 알려 주지만, 컨테이너를 지우기 전에 확인해야 합니다.', '[1, 3, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 212 AND order_index = 16);
-- 세트 213 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 213, 16, '함수 호출과 종료 코드 순서', '함수를 정의하고 호출한 뒤 종료 코드를 확인하는 과정의 **순서**를 맞춰 보세요.', '`$?` 는 바로 앞 명령의 종료 코드입니다.', NULL, NULL, '[]', 'order', '["`greet bob x` 로 함수를 호출한다", "`greet() { echo \\"hi $1 ($#)\\"; return 3; }` 로 함수를 정의한다", "`echo $?` 로 종료 코드 `3` 을 확인한다", "`hi bob (2)` 가 출력되고 `return 3` 으로 함수가 끝난다"]', NULL, '함수는 정의한 뒤에 호출할 수 있고, 호출하면 인자 `bob x` 로 `hi bob (2)` 를 출력한 뒤 `return 3` 으로 끝납니다. `$?` 는 직전 명령의 종료 코드라 호출 직후에 확인합니다.', '[1, 0, 3, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 213 AND order_index = 16);
-- 세트 214 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 16, 'liveness 실패가 이어지는 순서', 'nginx 에 `livenessProbe` 로 404 를 돌려주는 `httpGet` 경로를 준 뒤 일어나는 일을 **시간 순서**대로 놓아 보세요.', '점검이 실패해야 이벤트가 남고, 이벤트 다음에 컨테이너 쪽 조치가 따릅니다.', NULL, NULL, '[]', 'order', '["컨테이너가 재시작되어 RESTARTS 가 늘어난다", "`/nope` 경로로 보낸 HTTP 점검이 404 를 받아 실패한다", "계속 실패해서 STATUS 가 `CrashLoopBackOff` 가 된다", "`Liveness probe failed: HTTP probe failed with statuscode: 404` 이벤트가 남는다"]', NULL, 'liveness 점검이 실패하면 `Liveness probe failed` 이벤트가 남고, 컨테이너가 재시작되어 RESTARTS 가 늘어납니다. 실패가 계속되면 STATUS 가 `CrashLoopBackOff` 가 됩니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 16);
-- 세트 215 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 215, 16, 'inspect 로 한 값만 뽑기', '컨테이너 `c1` 의 상태 한 단어를 `docker inspect` 로 뽑아 보는 과정입니다. **순서**대로 놓아 보세요.', '전체를 먼저 보고, 어디에 있는지 찾은 다음, 그 부분만 뽑습니다.', NULL, NULL, '[]', 'order', '["`running` 한 단어만 한 줄로 출력된다", "`State` 아래 `Status` 항목이 원하는 값임을 찾는다", "`docker inspect c1` 로 JSON 전체를 훑어본다", "`docker inspect --format \'{{.State.Status}}\' c1` 을 실행한다"]', NULL, '`docker inspect c1` 은 JSON 전체를 보여 주므로 원하는 항목(`State.Status`)이 어디 있는지 먼저 찾습니다. 그 경로를 `--format \'{{.State.Status}}\'` 에 넣으면 `running` 한 단어만 출력됩니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 215 AND order_index = 16);
-- 세트 216 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 216, 16, '공백 이름을 안전하게 넘기기', '`my file.txt` 처럼 공백이 든 이름도 안 쪼개지게 `find ... -print0 | xargs -0 ls` 가 처리되는 과정을 **순서**대로 놓아 보세요.', '먼저 이름을 어떻게 구분해서 내보내는지가 정해져야 받는 쪽이 읽을 수 있습니다.', NULL, NULL, '[]', 'order', '["`xargs -0` 이 널 문자를 기준으로 이름을 나눈다", "`my file.txt` 가 한 이름으로 `ls` 에 전달된다", "`find . -type f -print0` 이 이름마다 뒤에 널 문자를 붙여 출력한다", "출력이 `|` 를 거쳐 `xargs -0` 으로 넘어간다"]', NULL, '`-print0` 은 이름 사이를 널 문자로 구분해 내보내고, `xargs -0` 은 그 널 문자를 기준으로 이름을 나눕니다. 그래서 공백이 든 `my file.txt` 가 한 이름으로 `ls` 에 전달됩니다.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 216 AND order_index = 16);
-- 세트 217 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 16, '지운 파드가 되살아나는 과정', 'Deployment 의 파드 하나를 `kubectl delete pod` 로 지운 뒤 일어나는 일을 **순서**대로 놓아 보세요.', 'ReplicaSet 은 원하는 개수와 실제 개수를 비교해서 움직입니다.', NULL, NULL, '[]', 'order', '["ReplicaSet 이 실제 파드 수가 원하는 수보다 모자란 것을 알아챈다", "`kubectl get pod` 에 새 이름의 파드가 보이고 개수는 원래대로 돌아온다", "`kubectl delete pod` 로 파드 하나를 지운다", "ReplicaSet 이 이름이 다른 새 파드를 만든다"]', NULL, '파드가 지워지면 ReplicaSet 이 원하는 개수보다 모자란 것을 알아채고 새 파드를 만듭니다. 새 파드는 해시 뒤의 임의 문자가 달라서 이름이 지운 파드와 다릅니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 16);
-- 세트 218 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 218, 16, '별칭 이름 달고 떼기', '`app:1` 에 별칭을 달았다가 떼는 과정입니다. **순서**대로 놓아 보세요.', '이름을 먼저 붙여야 떼어 볼 수 있고, 마지막에 원래 이름이 남았는지 확인합니다.', NULL, NULL, '[]', 'order', '["`docker rmi alias:x` 로 별칭을 지워 `Untagged` 를 확인한다", "`docker tag app:1 alias:x` 로 이름을 하나 더 붙인다", "`docker images` 에서 `app:1` 이 그대로 남았는지 본다", "`docker images` 에서 두 이름의 IMAGE ID 가 같은지 본다"]', NULL, '`docker tag` 는 같은 ID 에 이름만 더 붙이고, `docker rmi alias:x` 는 그 이름만 떼어 `Untagged` 를 보여 줍니다. 원래 이름이 남아 있으므로 이미지 자체는 지워지지 않습니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 218 AND order_index = 16);
-- 세트 219 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 219, 16, '크기 늘리고 줄이기', '`truncate` 로 파일 크기를 늘렸다가 줄이는 과정입니다. **순서**대로 놓아 보세요.', '처음 크기를 만든 뒤 늘리고, 다시 줄이는 순서입니다.', NULL, NULL, '[]', 'order', '["`truncate -s 3 t` 로 줄이면 뒤가 잘려 3바이트가 된다", "`truncate -s 6 t` 로 6바이트로 늘린다", "`printf \'abc\' > t` 로 3바이트 파일을 만든다", "`ls -l t` 로 크기가 6바이트인지 본다"]', NULL, '3바이트 파일에 `truncate -s 6` 을 하면 6바이트가 되고 늘어난 부분은 널 문자로 채워집니다. 그 뒤 `truncate -s 3` 을 하면 뒤가 잘려 3바이트로 돌아갑니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 219 AND order_index = 16);
-- 세트 220 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 220, 16, 'Job 이 재시도하는 과정', '`restartPolicy: Never`, `backoffLimit: 1` 인 Job 의 컨테이너가 계속 실패할 때 일어나는 일을 **순서**대로 놓아 보세요.', 'Never 는 같은 파드를 다시 시작하지 않으니, 재시도는 새 파드로 이루어집니다.', NULL, NULL, '[]', 'order', '["Job 이 새 파드를 만들어 재시도한다", "첫 파드의 컨테이너가 종료 코드 `1` 로 끝난다", "재시도 파드도 실패해서 `Error` 파드가 모두 둘 남는다", "그 파드는 다시 시작되지 않고 `Error` 로 남는다"]', NULL, '`Never` 이면 실패한 파드는 다시 시작되지 않고 `Error` 로 남고, Job 이 새 파드를 만들어 재시도합니다. 결국 `backoffLimit: 1` 이라서 처음 파드와 재시도 파드, 모두 두 개가 `Error` 로 남습니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 220 AND order_index = 16);
-- 세트 221 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 221, 16, 'RUN 과 CMD 가 실행되는 때', '`RUN echo build-time-msg` 와 `CMD ["echo","run-time-msg"]` 가 든 Dockerfile 로 이미지를 만들어 실행하는 과정을 **순서**대로 놓아 보세요.', 'RUN 은 빌드 때, CMD 는 컨테이너를 시작할 때 쓰입니다.', NULL, NULL, '[]', 'order', '["`CMD` 가 실행되어 `run-time-msg` 가 출력된다", "`docker build` 를 시작한다", "`docker run` 으로 컨테이너를 시작한다", "`RUN` 이 실행되어 빌드 로그에 `build-time-msg` 가 보인다"]', NULL, '`RUN` 은 `docker build` 중에 한 번 실행되어 빌드 로그에 보이고 결과가 이미지에 남습니다. `CMD` 는 이미지가 만들어진 뒤 `docker run` 으로 컨테이너를 시작할 때 실행됩니다.', '[1, 3, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 221 AND order_index = 16);
-- 세트 222 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 222, 16, 'printf 서식이 되풀이되는 과정', '`printf \'%s %s\\n\' a b c` 가 인자를 처리하는 과정을 **순서**대로 놓아 보세요.', '인자가 남아 있는 동안에는 서식을 처음부터 다시 씁니다.', NULL, NULL, '[]', 'order', '["첫 번째 `%s` 에 `c` 가 들어간다", "`a` 와 `b` 가 두 `%s` 에 들어가 `a b` 가 출력된다", "모자란 두 번째 `%s` 는 빈 문자열이 되어 `c ` 가 출력된다", "인자 `c` 가 남아 있어서 서식을 처음부터 다시 쓴다"]', NULL, '서식의 `%s` 두 자리에 `a` 와 `b` 가 들어가 첫 줄이 되고, 남은 `c` 때문에 서식이 처음부터 되풀이됩니다. 모자란 두 번째 `%s` 는 빈 문자열이 되어 `c ` 가 출력됩니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 222 AND order_index = 16);
-- 세트 223 #16 (order)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 223, 16, 'Pending 원인 찾아 풀기', '`nodeSelector` 라벨이 맞지 않아 `Pending` 인 파드의 원인을 찾아 푸는 과정을 **순서**대로 놓아 보세요.', '상태를 보고, 이유를 읽고, 고친 뒤, 결과를 봅니다.', NULL, NULL, '[]', 'order', '["`kubectl describe pod` 의 Events 에서 `FailedScheduling` 사유를 읽는다", "파드가 곧 배치되어 `Running` 이 된다", "`kubectl get pod -o wide` 로 `Pending` 이고 NODE 가 `<none>` 인 것을 본다", "`kubectl label node 노드이름 disk=ssd` 로 맞는 라벨을 붙인다"]', NULL, '`Pending` 이고 NODE 가 `<none>` 이면 `describe` 의 Events 에서 `FailedScheduling` 사유를 읽습니다. 노드에 맞는 라벨을 붙이면 파드를 다시 만들지 않아도 곧 배치되어 `Running` 이 됩니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 223 AND order_index = 16);
-- 세트 238 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 238, 15, 'run 과 exec 의 차이', '실행 중인 컨테이너 `web` 에 `docker exec web ls` 를 하면 어떻게 될까요?', 'run 과 exec 가 각각 컨테이너를 새로 만드는지, 이미 있는 것을 쓰는지 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`web` 컨테이너를 멈춘 뒤 `ls` 로 바꿔서 다시 시작한다", "`web` 컨테이너 안에서 `ls` 를 실행하고 결과를 출력한다. 새 컨테이너는 만들어지지 않는다", "`web` 컨테이너의 이름이 `ls` 로 바뀐다", "`web` 의 이미지로 새 컨테이너를 하나 더 만들어 `ls` 를 실행한다"]', 1, '`docker exec` 는 새 컨테이너를 만들지 않고 이미 실행 중인 컨테이너 안에서 명령을 실행합니다. 새 컨테이너를 만들어 명령을 실행하는 것은 `docker run` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 238 AND order_index = 15);
-- 세트 239 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 239, 15, 'unless-stopped 와 직접 멈춤', '`--restart unless-stopped` 로 실행한 컨테이너를 사람이 직접 `docker stop` 으로 멈춰 두었습니다. 서버가 재부팅되면 이 컨테이너는 어떻게 될까요?', '재시작 정책 이름에 든 \'unless\' 가 어떤 경우를 제외하는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["재부팅되면 `unless-stopped` 가 되살려서 다시 시작한다", "재부팅과 함께 컨테이너가 삭제되어 `docker ps -a` 에도 보이지 않는다", "`docker stop` 이 무시되어 컨테이너가 바로 다시 시작된다", "직접 `docker stop` 한 컨테이너는 재부팅 뒤에도 다시 띄우지 않고 그대로 둔다"]', 3, '`unless-stopped` 는 사람이 직접 멈추지 않은 컨테이너만 재부팅 뒤에 다시 띄웁니다. 직접 `docker stop` 한 컨테이너는 그대로 멈춘 채 둡니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 239 AND order_index = 15);
-- 세트 240 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 240, 15, '.gitignore 는 도커 빌드와 무관', '`.gitignore` 에만 `secret.txt` 를 적어 두고 `.dockerignore` 는 없는 폴더에서 `COPY . /app` 으로 이미지를 빌드하면 `secret.txt` 는 어떻게 될까요?', '각 도구는 자기 이름의 ignore 파일만 읽습니다.', NULL, NULL, '[]', 'choice', '["`.gitignore` 도 빌드 때 함께 읽혀서 이미지에 복사되지 않는다", "빌드가 오류로 멈추고 `secret.txt` 때문이라는 메시지가 나온다", "`secret.txt` 가 이미지에 그대로 복사된다", "이미지에는 복사되지만 `docker run` 할 때만 보이지 않게 가려진다"]', 2, '`.gitignore` 는 Git 용이라 도커 빌드에는 영향을 주지 않습니다. 빌드에서 빼려면 빌드 컨텍스트의 최상위에 `.dockerignore` 를 두고 파일 이름을 적어야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 240 AND order_index = 15);
-- 세트 241 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 241, 15, 'ARG 는 실행 중에 안 보인다', 'Dockerfile 에 `ARG VER=1` 만 있고 `ENV` 는 없습니다. 이 이미지로 `docker run --rm app env` 를 하면 `VER` 가 보일까요?', 'ARG 는 "빌드 때만" 쓰는 변수입니다.', NULL, NULL, '[]', 'choice', '["보이지 않는다. `ARG` 값은 빌드 중에만 쓰이고 컨테이너에는 남지 않는다", "`VER=1` 로 보인다. `ARG` 도 환경 변수로 남는다", "`--build-arg` 를 줬을 때만 `VER` 가 보이고 기본값은 보이지 않는다", "오류가 나서 `env` 명령이 실행되지 않는다"]', 0, '`ARG` 는 이미지를 만드는 동안에만 쓰이는 변수라서 실행 중인 컨테이너에는 남지 않습니다. 실행 중에도 쓰려면 `ENV` 로 넘겨야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 241 AND order_index = 15);
-- 세트 242 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 242, 15, '127 이 뜻하는 것', '컨테이너가 `Exited (127)` 로 끝났습니다. 가장 알맞은 원인은 무엇일까요?', '종료 코드를 읽는 기준(127, 126, 125)을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["파일에 실행 권한이 없다", "컨테이너 안에서 실행하려는 명령을 찾지 못했다", "메모리가 부족해 강제 종료됐다", "docker 명령 자체의 옵션이 잘못됐다"]', 1, '127 은 쉘이 실행하려는 명령을 찾지 못했다는 뜻입니다. 실행 권한이 없으면 126, docker 자체의 옵션 오류는 125 이고, 메모리 부족 강제 종료는 137 로 보이는 경우가 많습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 242 AND order_index = 15);
-- 세트 243 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 243, 15, '의존성이 매번 재설치되는 이유', '소스 한 줄만 고쳤는데 빌드할 때마다 의존성 설치(`RUN`) 단계가 캐시를 못 쓰고 다시 실행됩니다. 가장 알맞은 원인은 무엇일까요?', '캐시는 위에서부터 이어지다가 바뀐 줄에서 끊깁니다.', NULL, NULL, '[]', 'choice', '["`FROM` 줄은 캐시를 쓸 수 없어서", "`.dockerignore` 파일이 있어서", "의존성 설치 줄보다 앞에서 소스 전체를 `COPY` 해서", "`docker build` 는 원래 캐시를 쓰지 않아서"]', 2, '의존성 설치 줄보다 앞에서 소스 전체를 `COPY` 하면, 소스가 바뀔 때마다 그 줄부터 뒤쪽 캐시가 모두 무효가 됩니다. 의존성 목록 파일만 먼저 복사하고 설치한 뒤 나머지 소스를 복사하면 캐시가 살아납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 243 AND order_index = 15);
-- 세트 244 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 244, 15, 'docker stop 이 하는 일', '`docker stop` 이 컨테이너를 멈추는 방식으로 맞는 것은 무엇일까요?', '먼저 정중하게 요청하고, 안 되면 강제로 합니다.', NULL, NULL, '[]', 'choice', '["처음부터 SIGKILL 을 보내 바로 끝낸다", "`pause` 처럼 프로세스를 얼려 둔다", "SIGHUP 을 보내고 끝날 때까지 계속 기다린다", "먼저 SIGTERM 을 보내고 기본 10초 안에 끝나지 않으면 SIGKILL 을 보낸다"]', 3, '`docker stop` 은 먼저 SIGTERM 을 보내고 기본 10초를 기다린 뒤, 그래도 끝나지 않으면 SIGKILL 로 강제 종료합니다. 그래서 신호를 처리하지 못하는 앱은 10초 걸리고 `Exited (137)` 로 끝납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 244 AND order_index = 15);
-- 세트 245 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 245, 15, '변수 값이 정해지는 순서', '`docker-compose.yaml` 에 `${GREETING:-hello-default}` 가 있고, `.env` 에는 `GREETING=from-dotenv` 가 있습니다. `GREETING=from-shell docker compose config` 로 실행하면 치환되는 값은 무엇일까요?', '같은 변수를 줄 수 있는 곳이 여러 곳이면 우선순위가 있습니다.', NULL, NULL, '[]', 'choice', '["`from-shell`", "`from-dotenv`", "`hello-default`", "값이 없다는 오류로 멈춘다"]', 0, '쉘 환경 변수가 `.env` 파일보다 우선하고, 둘 다 없을 때만 `:-` 뒤의 기본값이 쓰입니다. 그래서 `from-shell` 이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 245 AND order_index = 15);
-- 세트 246 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 246, 15, '컨테이너를 지운 뒤 볼륨', '명명 볼륨 `data` 를 마운트한 컨테이너에서 파일을 쓴 뒤 컨테이너를 삭제했습니다(`docker rm`, `-v` 없음). 볼륨의 데이터는 어떻게 될까요?', '볼륨의 수명은 컨테이너와 따로 갑니다.', NULL, NULL, '[]', 'choice', '["컨테이너와 함께 항상 삭제된다", "볼륨은 남아 있고, 같은 볼륨을 마운트한 새 컨테이너에서 그대로 읽을 수 있다", "읽기 전용 상태로 바뀐다", "메모리(tmpfs)로 옮겨져 재부팅하면 사라진다"]', 1, '명명 볼륨은 컨테이너와 수명이 따로라서 컨테이너를 지워도 남아 있습니다. 새 컨테이너가 같은 볼륨을 마운트하면 그 파일을 그대로 읽을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 246 AND order_index = 15);
-- 세트 247 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 247, 15, '옵션 없이 import 한 이미지', '`docker export` 로 꺼낸 tar 를 `--change` 없이 `docker import` 해서 이미지를 만들었습니다. 이 이미지에 대한 설명으로 맞는 것은 무엇일까요?', 'export 로 만든 tar 에 무엇이 들어 있는지 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["원래 컨테이너의 `CMD` 가 그대로 이어진다", "이미지 이름이 자동으로 지워진다", "실행할 명령(`Cmd`)이 비어 있어 `docker run` 때 명령을 직접 줘야 한다", "tar 에 설정이 없으면 import 가 거부된다"]', 2, '`import` 는 파일 시스템만 이미지로 만들기 때문에, `--change` 로 `CMD` 를 덧붙이지 않으면 `Cmd` 가 비어 있습니다. 이런 이미지는 `docker run` 때 실행할 명령을 직접 적어 줘야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 247 AND order_index = 15);
-- 세트 248 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 248, 15, 'ONBUILD 가 실행되는 때', '부모 Dockerfile 에 `ONBUILD RUN echo triggered > /t.txt` 를 썼습니다. 이 명령은 언제 실행될까요?', 'ONBUILD 는 지금 실행하지 않고, 나중의 어떤 빌드에 대비해 두는 명령입니다.', NULL, NULL, '[]', 'choice', '["부모 이미지를 빌드하는 순간", "컨테이너가 시작될 때마다", "`docker pull` 로 이미지를 받을 때", "이 이미지를 `FROM` 으로 쓰는 자식 이미지를 빌드할 때"]', 3, '`ONBUILD` 는 그 이미지를 `FROM` 으로 쓰는 자식 이미지를 빌드할 때 실행되도록 예약합니다. 부모 이미지를 빌드할 때나 컨테이너를 실행할 때는 실행되지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 248 AND order_index = 15);
-- 세트 249 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 249, 15, 'on-failure 와 정상 종료', '`docker run -d --restart on-failure:3 alpine sh -c \'exit 0\'` 컨테이너는 종료 후 어떻게 될까요?', '종료 코드가 0 인지 아닌지를 보세요.', NULL, NULL, '[]', 'choice', '["다시 시작하지 않고 `Exited (0)` 으로 남는다", "최대 3번 다시 시작한다", "끝나지 않고 계속 다시 시작한다", "설정이 잘못됐다는 오류가 난다"]', 0, '`on-failure` 는 비정상 종료(종료 코드가 0 이 아닐 때)에만 재시작합니다. 종료 코드 0 은 정상 종료이므로 다시 시작하지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 249 AND order_index = 15);
-- 세트 250 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 250, 15, '네트워크 none 의 장치', '`docker run --rm --network none alpine cat /proc/net/dev` 로 본 네트워크 장치로 맞는 것은 무엇일까요?', '바깥과 이어지는 인터페이스는 없습니다.', NULL, NULL, '[]', 'choice', '["`eth0` 만 있다", "`lo` 만 있고 `eth0` 는 없다", "`eth0` 와 `lo` 가 모두 있다", "장치가 하나도 없다"]', 1, '`--network none` 컨테이너에는 자기 자신과만 통신하는 루프백 `lo` 만 있고, 바깥으로 이어지는 `eth0` 는 없습니다. 그래서 외부와 통신할 수 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 250 AND order_index = 15);
-- 세트 251 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 251, 15, 'create 직후의 모습', '`docker create --name c alpine echo hello` 직후 `docker ps` 와 `docker ps -a` 의 결과로 맞는 것은 무엇일까요?', '만들기만 했지 아직 시작하지는 않았습니다.', NULL, NULL, '[]', 'choice', '["둘 다 `Up` 으로 보인다", "`docker ps` 에서만 `Up` 으로 보인다", "`docker ps` 에는 안 보이고 `docker ps -a` 에 `Created` 로 보인다", "둘 다 아무것도 보이지 않는다"]', 2, '`create` 는 컨테이너를 만들기만 하고 시작하지 않아서 상태가 `Created` 입니다. 실행 중인 것만 보이는 `docker ps` 에는 안 나오고, `-a` 를 붙이면 보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 251 AND order_index = 15);
-- 세트 252 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 252, 15, 'commit 이 담는 것', '`docker commit web myimg:v1` 으로 만든 이미지에는 무엇이 담길까요?', '컨테이너의 현재 모습을 이미지로 저장합니다.', NULL, NULL, '[]', 'choice', '["원본 이미지와 똑같은 내용만 담긴다", "컨테이너가 남긴 로그만 담긴다", "실행 중인 프로세스의 메모리 상태가 담긴다", "컨테이너 안에서 바뀐 파일을 포함한 현재 파일 시스템 상태가 담긴다"]', 3, '`commit` 은 컨테이너의 현재 파일 시스템 상태, 즉 안에서 새로 만들거나 바꾼 파일까지 포함해 새 이미지로 저장합니다. 그래서 그 이미지로 실행하면 바뀐 파일이 들어 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 252 AND order_index = 15);
-- 세트 253 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 253, 15, 'down 뒤의 이름 있는 볼륨', '`docker compose down` 을 옵션 없이 실행하면 이름 있는 볼륨의 데이터는 어떻게 될까요?', '볼륨까지 지우려면 따로 옵션이 필요합니다.', NULL, NULL, '[]', 'choice', '["지워지지 않고 남는다", "항상 함께 지워진다", "읽기 전용으로 바뀐다", "이미지로 자동 저장된다"]', 0, '`down` 은 컨테이너와 네트워크를 지우지만, 이름 있는 볼륨은 `-v` 를 붙여야 지워집니다. 옵션이 없으면 볼륨이 남아서 다시 `up` 했을 때 데이터가 그대로 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 253 AND order_index = 15);
-- 세트 254 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 254, 15, '-p 의 두 번째 숫자', '`docker run -d -p 18080:80 alpine` 에서 `80` 은 무엇을 가리킬까요?', '`-p` 의 두 숫자는 각각 호스트와 컨테이너 중 한쪽을 가리킵니다. 순서를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["호스트에서 여는 포트", "컨테이너 안의 포트", "프로토콜 번호", "허용하는 최대 연결 수"]', 1, '`-p` 는 `호스트포트:컨테이너포트` 순서입니다. 그래서 `80` 은 컨테이너 안의 포트이고, `18080` 은 호스트에서 여는 포트입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 254 AND order_index = 15);
-- 세트 255 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 255, 15, 'pause 한 컨테이너의 모습', '`docker pause c1` 을 한 뒤 `docker ps` 에서 `c1` 은 어떻게 보일까요?', '멈춘 것과 정지(종료)한 것은 다릅니다.', NULL, NULL, '[]', 'choice', '["목록에서 사라진다", "`Exited (0)` 으로 표시된다", "목록에 남고 STATUS 에 `(Paused)` 가 붙는다", "`Created` 로 표시된다"]', 2, '`pause` 는 프로세스를 얼려 둘 뿐이라 컨테이너는 실행 중 목록에 남고 STATUS 에 `(Paused)` 가 붙습니다. `unpause` 하면 이어서 실행됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 255 AND order_index = 15);
-- 세트 256 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 256, 15, 'ps -q 가 출력하는 것', '`docker ps -q` 는 무엇을 출력하나요?', '`-q` 는 quiet(조용히)의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["컨테이너 이름만", "컨테이너 ID 의 앞 12자리만", "컨테이너 ID 64자리 전체", "실행 중인 컨테이너의 개수"]', 1, '`-q` 는 표 없이 컨테이너 ID 만 짧게 출력합니다. 앞 12자리만 나오고, 전체 64자리를 보려면 `--no-trunc` 를 더합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 256 AND order_index = 15);
-- 세트 257 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 257, 15, '이름 하나 더 붙이면', '`docker tag app:1 alias:x` 를 실행하면 어떻게 되나요?', '이미지가 복사되는지 이름만 늘어나는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["이미지가 통째로 복사되어 용량이 두 배가 된다", "`app:1` 이 `alias:x` 로 바뀌고 `app:1` 은 사라진다", "같은 이미지 ID 에 이름이 하나 더 붙는다", "`alias:x` 라는 빈 이미지가 새로 만들어진다"]', 2, '`docker tag` 는 같은 이미지 ID 에 이름만 하나 더 붙입니다. 이미지가 복사되지 않고, 원래 이름 `app:1` 도 그대로 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 257 AND order_index = 15);
-- 세트 258 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 258, 15, '진입점과 인자 합치기', '`ENTRYPOINT ["echo","base"]` 와 `CMD ["default"]` 로 만든 이미지를 `docker run 이미지 b` 로 실행하면 무엇이 출력되나요?', '`run` 뒤에 적은 값이 CMD 자리를 대신해요.', NULL, NULL, '[]', 'choice', '["default", "b", "base default", "base b"]', 3, '`ENTRYPOINT` 는 늘 실행되고, `docker run` 뒤에 적은 값은 `CMD` 를 덮어써서 인자로 붙습니다. 그래서 `echo base b` 가 실행됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 258 AND order_index = 15);
-- 세트 259 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 259, 16, 'mv 뒤의 원본', '`mv b.txt c.txt` 를 실행한 뒤 `b.txt` 는 어떻게 되나요?', '복사(`cp`)와 이동(`mv`)의 차이를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["없어지고 `c.txt` 라는 이름으로 바뀐다", "그대로 남고 `c.txt` 가 복사본으로 생긴다", "`c.txt` 끝에 내용이 덧붙은 뒤 비어서 남는다", "휴지통으로 옮겨져 나중에 복구할 수 있다"]', 0, '`mv` 는 옮기거나 이름을 바꾸는 명령이라 원본 이름이 사라지고 `c.txt` 로 바뀝니다. 원본을 남기고 싶다면 `cp` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 259 AND order_index = 16);
-- 세트 260 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 260, 16, 'kill 과 kill -9 의 차이', '`kill 1234` 와 `kill -9 1234` 의 차이로 맞는 것은?', '정중히 부탁하느냐, 강제로 끝내느냐의 차이예요.', NULL, NULL, '[]', 'choice', '["둘 다 똑같이 즉시 강제로 끝낸다", "`kill` 은 정중한 종료 요청, `-9` 는 강제 종료", "`kill` 은 강제 종료, `-9` 는 정중한 종료 요청", "`kill` 은 프로세스를 잠시 멈추고, `-9` 는 다시 시작한다"]', 1, '`kill PID` 는 종료를 정중히 요청해서 프로세스가 정리할 시간을 줍니다. `kill -9` 는 요청에 응하지 않는 프로세스를 강제로 끝내므로 마지막 수단으로 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 260 AND order_index = 16);
-- 세트 261 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 261, 16, 'LISTEN 상태의 뜻', '서비스가 8080 포트로 떠 있는지 `ss -tln` 으로 확인할 때, 그 포트 줄에서 봐야 하는 상태는 무엇인가요?', '연결을 "기다리는" 상태예요.', NULL, NULL, '[]', 'choice', '["ESTABLISHED", "CLOSED", "LISTEN", "TIME_WAIT"]', 2, '`ss -tln` 의 `LISTEN` 은 서버가 그 포트에서 연결을 기다리고 있다는 뜻입니다. 8080 이 LISTEN 이 아니면 서비스가 안 떠 있거나 다른 포트를 쓰는 것이니 로그를 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 261 AND order_index = 16);
-- 세트 262 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 262, 15, '종료 코드 0 의 뜻', '`./run.sh` 를 실행한 직후 `echo $?` 가 `0` 을 출력했다면 무슨 뜻인가요?', '`$?` 는 직전 명령의 종료 코드예요.', NULL, NULL, '[]', 'choice', '["직전 명령이 실패했다", "실행한 명령이 존재하지 않는다", "권한이 없어서 실행되지 않았다", "직전 명령이 성공했다"]', 3, '`$?` 는 직전 명령의 종료 코드이고, `0` 은 성공을 뜻합니다. 0 이 아닌 값이 나오면 실패한 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 262 AND order_index = 15);
-- 세트 263 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 263, 15, 'PATH 가 하는 일', '`command not found` 가 났을 때 먼저 `echo $PATH` 로 값을 보는 이유는 무엇인가요?', '쉘이 명령을 어디서 찾는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["쉘은 `PATH` 에 적힌 폴더에서만 명령을 찾으므로, 설치 폴더가 거기 있는지 확인하려고", "명령 파일이 삭제됐는지 알려 주기 때문에", "네트워크가 연결됐는지 알려 주기 때문에", "현재 로그인한 사용자의 비밀번호를 보여 주기 때문에"]', 0, '`PATH` 는 쉘이 명령 파일을 찾아보는 폴더 목록입니다. 명령이 설치된 폴더가 여기에 없으면 설치되어 있어도 `command not found` 가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 263 AND order_index = 15);
-- 세트 264 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 264, 15, '여유가 있는데 파일이 안 만들어질 때', '`No space left on device` 오류가 나는데 `df -h` 에는 여유가 충분합니다. 다음으로 확인할 것은?', '용량 말고 파일 개수를 세는 칸이 있어요.', NULL, NULL, '[]', 'choice', '["메모리 사용량(`free`)", "`df -i` 로 본 inode 사용량", "`kill -9` 로 프로세스를 강제 종료", "`journalctl -p err` 의 로그 시간 범위"]', 1, '용량이 남아도 inode 가 다 차면 새 파일을 만들 수 없습니다. `df -i` 로 inode 사용량을 확인하고 작은 파일이 많은 폴더를 찾아 정리합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 264 AND order_index = 15);
-- 세트 265 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 265, 15, '입력 모드로 바꾸기', 'vi 로 파일을 열고 글자를 쳤는데 입력이 되지 않습니다. 글자를 입력할 수 있는 **입력 모드**로 바꾸는 키는?', '글자를 끼워 넣는(삽입하는) 동작을 시작하는 키예요.', NULL, NULL, '[]', 'choice', '["`Esc`", "`Enter`", "`i`", "`dd`"]', 2, 'vi 는 처음에 명령 모드라서 글자를 쳐도 입력되지 않습니다. `i` 를 누르면 입력 모드가 되고, 다 고친 뒤 `Esc` 를 눌러 명령 모드로 돌아갑니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 265 AND order_index = 15);
-- 세트 266 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 266, 15, '|| 의 동작', '`app.log` 에 ERROR 줄이 **있을 때** `grep ERROR app.log || echo "없음"` 을 실행하면 어떻게 되나요?', '`||` 는 앞 명령이 실패했을 때만 뒤를 실행해요.', NULL, NULL, '[]', 'choice', '["ERROR 줄과 \\"없음\\" 이 둘 다 출력된다", "\\"없음\\" 만 출력된다", "오류 메시지가 출력된다", "ERROR 줄만 출력되고 \\"없음\\" 은 출력되지 않는다"]', 3, '`grep` 이 줄을 찾으면 성공(종료 코드 0)이라서 `||` 뒤의 `echo` 는 실행되지 않습니다. 찾는 줄이 없어 실패했을 때만 "없음" 이 출력됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 266 AND order_index = 15);
-- 세트 267 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 267, 16, '백그라운드 작업의 PID', '`sleep 100 &` 로 백그라운드에 띄운 직후, 방금 띄운 작업의 **PID** 를 담고 있는 특별한 변수는?', '백그라운드(background)로 보낸 마지막 작업과 관련된 특수 변수예요.', NULL, NULL, '[]', 'choice', '["`$!`", "`$?`", "`$1`", "`$#`"]', 0, '`$!` 는 가장 최근에 백그라운드로 띄운 작업의 PID 입니다. `$?` 는 직전 명령의 종료 코드, `$1` 은 첫 번째 인자입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 267 AND order_index = 16);
-- 세트 268 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 268, 15, '-C 옵션의 뜻', '`grep -C2 -i error app.log` 에서 `-C2` 가 하는 일은 무엇인가요?', 'C 는 context(맥락)의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["일치한 줄의 개수를 2 로 제한한다", "일치한 줄의 앞뒤 2줄씩을 함께 보여 준다", "일치한 줄 뒤 2줄만 보여 준다", "두 번째로 일치한 줄만 보여 준다"]', 1, '`-C2` 는 일치한 줄의 앞뒤 2줄씩을 함께 보여 줍니다. 에러가 난 앞뒤 상황을 읽을 때 쓰고, `-A` 는 뒤쪽, `-B` 는 앞쪽만 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 268 AND order_index = 15);
-- 세트 269 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 269, 15, '메모리 여유 판단', '`free -h` 에서 메모리 여유가 충분한지 판단할 때 가장 알맞게 봐야 하는 열은?', '캐시로 쓰는 메모리까지 감안해, 새 프로그램에 실제로 줄 수 있는 양을 보여 주는 열이에요.', NULL, NULL, '[]', 'choice', '["`free`", "`used`", "`available`", "`total`"]', 2, '`free` 열이 작아도 캐시로 쓰던 메모리는 필요하면 돌려받을 수 있어서, 실제로 쓸 수 있는 양은 `available` 입니다. `available` 이 충분하면 괜찮습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 269 AND order_index = 15);
-- 세트 270 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 270, 15, '평일 오전 9시 읽기', 'crontab 줄 `0 9 * * 1-5 report.sh` 은 언제 실행될까요?', '필드는 분, 시, 일, 월, 요일 순서이고 `1-5` 는 요일 필드에 있습니다.', NULL, NULL, '[]', 'choice', '["매일 9분마다", "평일 오전 9시 정각", "매주 월요일 오전 9시에만", "매월 1일부터 5일까지 오전 9시"]', 1, '앞의 `0 9` 는 9시 0분, 요일 필드의 `1-5` 는 월요일부터 금요일입니다. 그래서 평일 오전 9시 정각에만 실행돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 270 AND order_index = 15);
-- 세트 271 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 271, 15, 'uniq 가 세는 방식', '`printf \'a\\nb\\na\\n\' | uniq -c` 를 실행하면 어떻게 될까요? (`uniq -c` 는 같은 줄이 연속된 횟수를 앞에 붙입니다)', '`uniq` 는 서로 이웃한 줄만 같은 줄로 봅니다.', NULL, NULL, '[]', 'choice', '["`a` 가 2번, `b` 가 1번으로 합쳐 센다", "오류가 나서 아무것도 출력되지 않는다", "`a`, `b`, `a` 가 각각 1번씩 따로 세어진다", "`b` 한 줄만 출력된다"]', 2, '`uniq` 는 이웃한 줄만 합칩니다. `a`, `b`, `a` 는 서로 이웃하지 않아서 각각 1번씩 세어져요. 먼저 `sort` 로 정렬해야 `a` 가 2번으로 셉니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 271 AND order_index = 15);
-- 세트 272 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 272, 15, '대문자 T 의 뜻', '공유 폴더를 `ls -ld` 로 봤더니 권한 끝 글자가 소문자 `t` 가 아니라 **대문자 `T`** 였습니다. 무슨 뜻일까요?', 'sticky 비트는 "다른 사용자(others)" 실행 자리에 표시됩니다.', NULL, NULL, '[]', 'choice', '["sticky 비트가 꺼져 있다", "setuid 비트가 켜져 있다", "폴더가 아니라 일반 파일이다", "sticky 비트는 켜져 있고 others 의 실행 권한이 없다"]', 3, 'sticky 비트가 켜져 있으면 마지막 글자가 `t` 로 보이는데, 그 자리에 실행 권한이 없으면 대문자 `T` 로 보입니다. 즉 sticky 는 켜져 있고 others 의 실행 권한만 없는 상태예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 272 AND order_index = 15);
-- 세트 273 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 273, 15, 's 플래그 없이 바꾸기', '`echo aaa | sed \'s/a/X/\'` 의 출력은 무엇일까요?', '플래그가 없으면 줄마다 몇 번째 일치까지 바뀔까요?', NULL, NULL, '[]', 'choice', '["`Xaa`", "`XXX`", "`aaX`", "`aaa`"]', 0, '`s` 에 `g` 플래그가 없으면 줄마다 첫 번째 일치만 바뀝니다. 그래서 `Xaa` 가 출력돼요. 모두 바꾸려면 `s/a/X/g` 로 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 273 AND order_index = 15);
-- 세트 274 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 274, 15, '변조된 파일 검증하기', '내려받은 파일이 중간에 변조되어 해시가 달라졌습니다. `sha256sum -c SUMS` 를 실행하면 어떻게 될까요?', '검증 결과는 화면 메시지와 종료 코드 두 가지로 알 수 있습니다.', NULL, NULL, '[]', 'choice', '["`OK` 가 출력되고 종료 코드 0 이다", "`FAILED` 가 출력되고 종료 코드 1 이다", "아무것도 출력되지 않고 종료 코드 0 이다", "파일이 자동으로 삭제된다"]', 1, '해시가 목록과 다르면 `FAILED` 가 출력되고 종료 코드는 1 이 됩니다. 정상이면 `OK` 와 종료 코드 0 이에요. 검증이 실패한 파일은 사용하지 말고 다시 받으세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 274 AND order_index = 15);
-- 세트 275 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 275, 15, 'grep -c 가 세는 것', '파일에 한 줄 `a12 b345` 만 들어 있습니다. `grep -c -E \'[0-9]+\' file` 의 출력은 무엇일까요?', '`-c` 는 숫자 덩어리가 아니라 다른 것을 셉니다.', NULL, NULL, '[]', 'choice', '["0", "2", "1", "5"]', 2, '`-c` 는 일치한 **줄의 수**를 셉니다. 숫자 덩어리가 둘이어도 줄은 하나라서 `1` 이 출력돼요. 숫자 덩어리를 세려면 `-o` 로 뽑아 `wc -l` 에 넘깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 275 AND order_index = 15);
-- 세트 276 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 276, 15, '숫자를 문자로 정렬하면', '옵션 없이 `sort` 하면 `5`, `25`, `100` 이 든 세 줄은 어떤 순서로 나올까요?', '옵션이 없으면 숫자가 아니라 글자를 앞에서부터 비교합니다.', NULL, NULL, '[]', 'choice', '["5, 25, 100", "100, 5, 25", "25, 5, 100", "100, 25, 5"]', 3, '옵션 없는 `sort` 는 글자 순서로 비교합니다. 첫 글자가 `1` 인 `100`, 그다음 `2` 인 `25`, 마지막으로 `5` 가 와요. 숫자 크기대로 정렬하려면 `-n` 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 276 AND order_index = 15);
-- 세트 277 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 277, 15, '원본을 지운 뒤의 링크', '`t.txt` 에 `ln t.txt hard`(하드 링크)와 `ln -s t.txt sym`(심볼릭 링크)을 만든 뒤 `rm t.txt` 를 했습니다. 내용이 그대로 읽히는 것은 어느 쪽일까요?', '이름이 가리키는 것이 "내용"인지 "경로"인지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["하드 링크", "심볼릭 링크", "두 링크 모두 오류가 난다", "`rm t.txt` 가 실행되지 않는다"]', 0, '하드 링크는 같은 내용을 가리키는 또 다른 이름이라 원본 이름을 지워도 읽힙니다. 심볼릭 링크는 경로만 적어 둔 것이라 원본이 없으면 `No such file or directory` 가 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 277 AND order_index = 15);
-- 세트 278 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 278, 15, 'pipefail 없는 파이프 종료 코드', '`set -o pipefail` 을 켜지 않은 상태에서 `false | true; echo $?` 를 실행하면 무엇이 출력될까요?', '기본 상태에서 파이프라인의 종료 코드는 어느 단계의 것일까요?', NULL, NULL, '[]', 'choice', '["1", "0", "2", "아무것도 출력되지 않는다"]', 1, '`pipefail` 이 꺼져 있으면 파이프라인의 종료 코드는 **마지막 단계**의 것입니다. 마지막 `true` 가 0 이므로 `0` 이 나와요. `pipefail` 을 켜면 중간 단계 실패(`false` 의 1)가 반영됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 278 AND order_index = 15);
-- 세트 279 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 279, 15, 'xargs -n 1 실행 횟수', '`printf \'a\\nb\\nc\\n\' | xargs -n 1 echo got` 에서 `echo` 는 모두 몇 번 실행될까요?', '`-n 1` 은 한 번에 입력 몇 개씩 넘기라는 뜻일까요?', NULL, NULL, '[]', 'choice', '["1번", "2번", "3번", "실행되지 않는다"]', 2, '`-n 1` 은 입력을 1개씩 묶어 명령에 넘깁니다. 입력이 3개이므로 `echo got a`, `echo got b`, `echo got c` 처럼 3번 실행돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 279 AND order_index = 15);
-- 세트 280 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 280, 15, '%1 이 가리키는 것', '`kill %1` 에서 `%1` 은 무엇을 가리킬까요?', '`jobs` 를 실행하면 앞에 `[1]` 같은 번호가 보입니다.', NULL, NULL, '[]', 'choice', '["PID 가 1 인 프로세스", "직전 명령 기록의 1번", "신호 번호 1", "`jobs` 목록의 `[1]` 번 작업"]', 3, '`%1` 은 `jobs` 목록에 `[1]` 로 나오는 1번 작업(작업 번호)을 뜻합니다. PID 가 아니라서 PID 를 쓰려면 `%` 없이 숫자를 주어야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 280 AND order_index = 15);
-- 세트 281 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 281, 15, 'EXIT trap 이 안 도는 경우', '스크립트에 `trap "rm -f tmpf" EXIT` 를 걸어 두었습니다. 다음 중 임시 파일이 **지워지지 않고 남을 수 있는** 경우는 어느 것일까요?', '잡을 수 없는 신호가 있습니다.', NULL, NULL, '[]', 'choice', '["`kill -9` 로 강제 종료된 경우", "스크립트가 끝까지 정상 실행된 경우", "`exit 1` 로 끝난 경우", "명령 하나가 오류를 내고 끝난 경우"]', 0, '`kill -9`(SIGKILL)은 프로세스가 잡을 수 없어서 `EXIT` trap 이 실행되지 않습니다. 정상 종료, `exit`, 오류 종료에서는 trap 이 실행돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 281 AND order_index = 15);
-- 세트 282 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 282, 15, 'diff 의 종료 코드', '내용이 서로 다른 두 파일에 `diff a1 a3` 를 실행한 직후의 종료 코드는 무엇일까요?', 'diff 는 두 파일의 같음·다름을 종료 코드로도 알려 줍니다. 오류와 구분되는 값이에요.', NULL, NULL, '[]', 'choice', '["0", "1", "2", "124"]', 1, '`diff` 는 같으면 0, **다르면 1**, 파일이 없는 등 오류가 나면 2 를 돌려줍니다. `cmp` 도 다르면 1 이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 282 AND order_index = 15);
-- 세트 283 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 283, 15, '한 명령에만 준 변수', '`W=once bash -c \'echo "[$W]"\'` 를 실행하면 `[once]` 가 나옵니다. 이어서 같은 쉘에서 `echo "[$W]"` 를 실행하면 (W 는 따로 만든 적이 없다면) 무엇이 출력될까요?', '명령 앞에 붙인 변수는 그 명령 하나에만 보입니다.', NULL, NULL, '[]', 'choice', '["`[once]`", "오류 메시지가 나온다", "`[]`", "`once`"]', 2, '`W=once` 처럼 명령 앞에 붙인 변수는 그 명령이 실행되는 동안만 자식에게 전달되고 현재 쉘에는 남지 않습니다. 그래서 `W` 는 비어 있어 `[]` 가 출력돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 283 AND order_index = 15);
-- 세트 284 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 284, 15, '; 와 + 의 차이', '`find ... -exec 명령 {} +` 처럼 `;` 대신 `+` 로 끝내면 어떻게 동작할까요?', '`;` 와 `+` 가 명령을 몇 번 실행하게 하는지 비교해 보세요.', NULL, NULL, '[]', 'choice', '["찾은 파일마다 명령을 따로 한 번씩 실행한다", "찾은 파일을 모아서 명령 한 번에 넘긴다", "찾은 파일을 바로 지운다", "찾은 이름을 널 문자로 구분해 출력한다"]', 1, '`;` 로 끝내면 찾은 항목마다 명령을 한 번씩 실행하고, `+` 로 끝내면 찾은 항목을 모아 명령 한 번에 넘깁니다. 파일이 많을 때 `+` 가 실행 횟수를 줄여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 284 AND order_index = 15);
-- 세트 285 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 285, 15, 'head -n -2 의 결과', '`seq 1 12 > s12` 로 1부터 12까지 열두 줄짜리 파일을 만든 뒤 `head -n -2 s12` 를 실행하면 무엇이 나올까요?', '`-n` 앞에 빼기가 붙으면 끝에서 덜어내요.', NULL, NULL, '[]', 'choice', '["`11` 과 `12` 두 줄", "`1` 과 `2` 두 줄", "`1` 부터 `10` 까지 열 줄", "`3` 부터 `12` 까지 열 줄"]', 2, '`head -n -2` 는 **끝의 두 줄을 뺀 나머지**를 출력합니다. 열두 줄 중 `11`, `12` 를 뺀 `1` 부터 `10` 까지가 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 285 AND order_index = 15);
-- 세트 286 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 286, 15, '서식 되풀이 줄 수', '`printf \'x%s\\n\' 1 2 3` 을 실행하면 몇 줄이 출력될까요?', '인자가 남으면 서식을 처음부터 다시 써요.', NULL, NULL, '[]', 'choice', '["1줄", "2줄", "6줄", "3줄"]', 3, '`printf` 는 인자가 서식보다 많으면 서식을 되풀이해서 씁니다. 인자 세 개에 `%s` 가 하나이므로 서식이 세 번 쓰여 `x1`, `x2`, `x3` 세 줄이 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 286 AND order_index = 15);
-- 세트 287 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 287, 16, '같은 파일로 apply 두 번', '`kubectl apply -f app.yaml` 을 내용이 그대로인 같은 파일로 두 번 실행하면 어떻게 될까요?', 'apply 는 "선언한 상태로 맞춘다"는 뜻이에요.', NULL, NULL, '[]', 'choice', '["이미 같은 상태라 바꾸지 않고 안전하게 끝난다", "두 번째 실행은 항상 오류가 난다", "Pod 가 두 배로 늘어난다", "처음에 만든 리소스가 지워진다"]', 0, '`apply -f` 는 선언한 상태로 맞추는 명령이라 같은 파일로 다시 실행해도 안전합니다(멱등). 이미 같은 상태이면 바꿀 것이 없어 그대로 둡니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 287 AND order_index = 16);
-- 세트 288 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 288, 16, '엔드포인트가 비어 있을 때', 'Service 를 만들었는데 `kubectl get endpoints` 결과가 비어 있습니다. 가장 먼저 의심할 것은 무엇일까요?', 'Service 가 Pod 를 찾는 방법을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["Pod 의 이미지 태그를 `latest` 로 썼다", "Service 의 `selector` 와 Pod 의 라벨이 서로 다르다", "Deployment 의 `replicas` 가 3 이다", "컨테이너가 80 포트를 알리고 있다"]', 1, 'Service 는 `selector` 의 라벨로 Pod 를 찾습니다. 이 라벨이 Pod 의 `metadata.labels` 와 어긋나면 연결할 Pod 가 없어 엔드포인트가 비어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 288 AND order_index = 16);
-- 세트 289 #16 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 289, 16, 'Secret 값은 암호화일까', 'Secret 을 조회했더니 값이 `MTIzNA==` 로 보입니다. 올바른 설명은 무엇일까요?', '인코딩과 암호화가 같은 것인지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["강하게 암호화되어 있어 풀 수 없다", "ConfigMap 과 달리 환경 변수로는 쓸 수 없다", "base64 로 인코딩된 값이라 `base64 -d` 로 누구나 풀 수 있다", "`kubectl` 로만 풀 수 있다"]', 2, 'Secret 의 값은 base64 로 **인코딩**되어 있을 뿐 암호화가 아닙니다. `base64 -d` 로 누구나 `1234` 로 되돌릴 수 있으니 조회 권한과 화면·기록 노출에 주의해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 289 AND order_index = 16);
-- 세트 290 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 290, 15, '재시작 전 로그 보기', 'Pod `web` 이 계속 재시작되어 지금 컨테이너의 로그가 거의 비어 있습니다. **죽기 전 컨테이너의 로그**를 보려면 어떤 명령을 쓸까요?', '옵션 이름에 "이전"이라는 뜻이 있어요.', NULL, NULL, '[]', 'choice', '["`kubectl get pods -o wide`", "`kubectl rollout status deployment/web`", "`kubectl create job hello --image=busybox`", "`kubectl logs web --previous`"]', 3, '`kubectl logs web --previous` 는 재시작하기 전 컨테이너가 남긴 로그를 보여 줍니다. 지금 컨테이너가 로그를 남기기 전에 죽는 경우 원인을 알려 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 290 AND order_index = 15);
-- 세트 291 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 291, 15, 'READY 0/1 의 원인', 'Pod 가 `Running` 이지만 READY 가 `0/1` 이고 RESTARTS 는 계속 `0` 입니다. 가장 알맞은 설명은 무엇일까요?', 'RESTARTS 가 늘지 않는다는 점과 READY 의 의미를 함께 보세요.', NULL, NULL, '[]', 'choice', '["`readinessProbe` 가 실패해 트래픽 대상에서만 빠져 있다", "`livenessProbe` 가 실패해 컨테이너가 계속 재시작되고 있다", "이미지를 받지 못해 컨테이너가 시작되지 않았다", "노드가 `cordon` 되어 Pod 가 배치되지 못했다"]', 0, '`Running` 은 프로세스가 떠 있다는 뜻이고 READY 는 트래픽을 받을 준비가 됐다는 뜻입니다. `readinessProbe` 가 실패하면 재시작은 하지 않고 Service 대상에서만 빠져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 291 AND order_index = 15);
-- 세트 292 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 292, 15, 'metrics not available', '`kubectl top pods` 를 실행했더니 `metrics not available` 오류가 납니다. 가장 알맞은 원인은 무엇일까요?', '사용량을 모아 주는 구성 요소가 필요해요.', NULL, NULL, '[]', 'choice', '["Service 의 selector 가 틀렸다", "metrics-server 가 없거나 아직 준비되지 않았다", "Deployment 에 `replicas` 가 적혀 있지 않다", "네임스페이스에 라벨이 없다"]', 1, '`kubectl top` 은 metrics-server 가 있어야 동작합니다. 없거나 아직 준비되지 않았으면 이 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 292 AND order_index = 15);
-- 세트 293 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 293, 15, 'TARGETS 가 unknown', 'HPA 의 TARGETS 가 `<unknown>` 으로 나옵니다. 알맞은 원인은 무엇일까요?', '사용률은 "요청한 양" 대비 비율로 계산해요.', NULL, NULL, '[]', 'choice', '["Deployment 이름이 너무 짧다", "Helm release 의 상태가 `deployed` 이다", "Pod 에 CPU requests 가 없어 사용률을 계산할 수 없다", "`kubectl logs` 출력이 비어 있다"]', 2, '사용률(%)은 Pod 에 적은 CPU requests 대비로 계산합니다. requests 가 없으면 사용률을 알 수 없어 `<unknown>` 이 되고, HPA 는 판단할 수 없어 Pod 개수를 바꾸지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 293 AND order_index = 15);
-- 세트 294 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 294, 15, '재시작 안 되는 Pod', 'Pod 가 `Error` 로 끝났는데 RESTARTS 가 `0` 인 채 다시 시작되지 않습니다. 가장 가능성 높은 설정은 무엇일까요?', '실패해도 다시 시작하지 않게 하는 값이 있었죠.', NULL, NULL, '[]', 'choice', '["`restartPolicy: Always`", "`imagePullPolicy: IfNotPresent`", "`initContainers` 를 정의하지 않았다", "`restartPolicy: Never`"]', 3, '`restartPolicy: Never` 이면 컨테이너가 실패해도 다시 시작하지 않아 STATUS 가 `Error` 로 남고 RESTARTS 는 0 입니다. 계속 재시작이 필요하면 `OnFailure` 나 Deployment 를 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 294 AND order_index = 15);
-- 세트 295 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 295, 15, 'runAsNonRoot 로 시작 실패', 'root 로 실행되도록 만든 이미지에 `runAsNonRoot: true` 를 켰더니 Pod 가 `CreateContainerConfigError` 입니다. 알맞은 원인과 해결은 무엇일까요?', '설정이 요구하는 것과 이미지가 하는 것이 어긋났어요.', NULL, NULL, '[]', 'choice', '["이미지가 root 로 실행되어 거부된 것이니 `runAsUser` 를 지정하거나 이미지에 `USER` 를 넣는다", "ResourceQuota 를 넘어서 거부된 것이니 쿼터를 지운다", "레지스트리 인증이 실패한 것이니 `imagePullSecrets` 를 지운다", "ServiceAccount 가 없어서 거부된 것이니 `default` 를 삭제한다"]', 0, '`runAsNonRoot: true` 는 root 로 실행되면 시작을 거부합니다. `runAsUser: 1000` 처럼 일반 사용자를 지정하거나 이미지에 `USER` 를 넣어 해결해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 295 AND order_index = 15);
-- 세트 296 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 296, 15, 'ConfigMap 을 고쳤는데 옛 값', 'ConfigMap 의 값을 고쳤는데, 그 값을 환경 변수로 받은 Pod 의 앱은 여전히 옛 값을 씁니다. 이유와 해결로 알맞은 것은?', '환경 변수는 Pod 가 시작될 때 정해져요.', NULL, NULL, '[]', 'choice', '["ConfigMap 수정은 저장되지 않으므로 다시 만든다", "환경 변수 값은 자동 갱신되지 않으므로 Pod 를 다시 띄운다", "`kubectl get` 으로 보면 항상 옛 값이 나온다", "Secret 으로 바꾸면 바로 반영된다"]', 1, '환경 변수로 받은 값은 자동으로 갱신되지 않습니다. `kubectl rollout restart deployment/이름` 으로 Pod 를 새로 띄우면 바뀐 값을 읽어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 296 AND order_index = 15);
-- 세트 297 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 297, 15, 'StatefulSet 줄일 때', 'StatefulSet `db` 의 Pod 가 `db-0`, `db-1`, `db-2` 일 때 `kubectl scale sts db --replicas=1` 을 실행하면 어떻게 될까요?', '번호가 큰 쪽부터 사라져요.', NULL, NULL, '[]', 'choice', '["`db-0` 부터 삭제되고 PVC 도 함께 삭제된다", "임의의 Pod 가 삭제되고 PVC 도 함께 삭제된다", "번호가 큰 `db-2`, `db-1` 이 삭제되고 PVC 는 남는다", "아무 Pod 도 삭제되지 않는다"]', 2, '줄일 때는 번호가 큰 Pod 부터 삭제되므로 `db-2`, `db-1` 이 사라지고 `db-0` 이 남습니다. PVC 는 지워지지 않고 남아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 297 AND order_index = 15);
-- 세트 298 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 298, 15, 'egress 를 막으면 이름 접속이 안 되는 이유', '`policyTypes: [Egress]` 이고 규칙이 없는 정책이 적용된 Pod 에서 `nslookup web` 이 실패합니다. **가장 알맞은 이유**를 고르세요.', '이름 조회도 DNS 서버로 나가는 접속이라는 점을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["Service `web` 이 삭제되어서", "나가는 접속에 DNS 조회(53 포트)도 포함되어 함께 막혀서", "정책이 DNS 서버 Pod 를 종료시켜서", "들어오는 접속(ingress)이 막혀서"]', 1, 'DNS 조회는 DNS 서버(kube-system)의 53 포트로 나가는 접속이라 egress 정책에 똑같이 막힙니다. 그래서 egress 를 막을 때는 53 포트(UDP·TCP)를 따로 열어 줘야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 298 AND order_index = 15);
-- 세트 299 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 299, 15, 'limits 만 쓰면 requests 는?', '컨테이너에 `limits` 만 쓰고 `requests` 는 쓰지 않았습니다. 이때 `requests` 는 어떻게 될까요?', 'requests 를 비웠을 때 쿠버네티스가 채워 주는 기본 동작을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["0 으로 채워져 아무것도 예약되지 않는다", "오류로 거부된다", "`limits` 와 같은 값으로 자동 채워진다", "노드의 남은 자원 전부로 채워진다"]', 2, '`limits` 만 쓰면 `requests` 가 같은 값으로 채워집니다. 그래서 cpu 와 memory 모두 이렇게 쓰면 requests 와 limits 가 같아져 Guaranteed 등급이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 299 AND order_index = 15);
-- 세트 300 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 300, 15, '이미 있는 라벨 값 바꾸기', '`tier=front` 라벨이 이미 있는 Pod 에 `kubectl label pod web tier=back` 을 실행하면 어떻게 될까요?', '같은 키의 값을 바꿀 때 필요한 옵션이 있었어요.', NULL, NULL, '[]', 'choice', '["`tier` 값이 `back` 으로 바뀐다", "`tier` 라벨이 두 개가 된다", "`tier` 라벨이 지워진다", "`--overwrite` 가 없어서 오류로 거부된다"]', 3, '이미 있는 키의 값을 바꾸려면 `--overwrite` 를 붙여야 합니다. 옵션이 없으면 `--overwrite is false` 오류로 거부되고 값은 그대로 유지됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 300 AND order_index = 15);
-- 세트 301 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 301, 15, 'backoffLimit 1 인 Job 의 실패 Pod', '항상 실패하는 컨테이너로 `restartPolicy: Never`, `backoffLimit: 1` 인 Job 을 만들었습니다. Job 이 포기할 때까지 **실패한 Pod 는 모두 몇 개** 만들어질까요?', '처음 시도 하나에 재시도 횟수를 더해 보세요.', NULL, NULL, '[]', 'choice', '["2개", "1개", "3개", "6개"]', 0, '`backoffLimit: 1` 이면 실패한 Pod 가 2개 생기고 포기합니다. 기본값 6 은 아주 많이 다시 시도하는 값이라 이 경우와 다릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 301 AND order_index = 15);
-- 세트 302 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 302, 15, '재시작 없는 Pod 의 --previous', '한 번도 재시작한 적 없는 Pod 에 `kubectl logs web-pod --previous` 를 실행하면 어떻게 될까요?', '직전 컨테이너라는 것이 아예 없는 상황입니다.', NULL, NULL, '[]', 'choice', '["현재 컨테이너의 로그를 대신 보여 준다", "BadRequest 오류가 난다", "빈 출력으로 정상 종료된다", "Pod 가 재시작되며 이전 로그를 만든다"]', 1, '`--previous` 는 재시작되기 전의 직전 컨테이너 로그를 보는 옵션입니다. 재시작 이력이 없으면 볼 로그가 없어 BadRequest 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 302 AND order_index = 15);
-- 세트 303 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 303, 15, '셀렉터 오타와 ENDPOINTS', 'Service 의 셀렉터가 `app=wbe`(오타)이고 Pod 의 라벨은 `app=web` 입니다. `kubectl get endpoints` 의 `ENDPOINTS` 열에는 무엇이 보일까요?', '셀렉터와 라벨이 맞는 Pod 가 하나도 없다면 어떨까요?', NULL, NULL, '[]', 'choice', '["`Pod주소:포트` 가 정상으로 보인다", "오류가 나서 목록이 출력되지 않는다", "`<none>`", "Pod 이름이 보인다"]', 2, '셀렉터와 라벨이 맞는 Pod 가 없으면 엔드포인트가 비어 `<none>` 으로 보이고 접속도 안 됩니다. 이럴 때는 `describe svc` 의 Selector 와 `get pods --show-labels` 를 비교해 오타를 찾습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 303 AND order_index = 15);
-- 세트 304 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 304, 15, '없는 리소스 삭제하기', '존재하지 않는 Pod 에 `kubectl delete pod nonexist` 를 실행하면 결과는 어떻게 될까요?', '오류 없이 넘어가게 하려면 따로 옵션이 필요했어요.', NULL, NULL, '[]', 'choice', '["아무 일 없이 종료 코드 0 으로 끝난다", "같은 이름의 Pod 가 새로 만들어진다", "default 네임스페이스의 모든 Pod 가 삭제된다", "NotFound 오류가 나고 종료 코드는 1 이다"]', 3, '옵션이 없으면 `NotFound` 오류와 종료 코드 1 로 끝납니다. 대상이 없어도 오류 없이 끝내고 싶을 때만 `--ignore-not-found` 를 붙입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 304 AND order_index = 15);
-- 세트 305 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 305, 15, 'pause 중에 이미지를 바꾸면', '`kubectl rollout pause deploy/web` 으로 일시 중지한 뒤 `kubectl set image` 로 이미지를 바꿨습니다. 어떻게 될까요?', '중지 중에는 롤아웃이 시작되지 않습니다.', NULL, NULL, '[]', 'choice', '["Pod 가 바로 교체되지 않고, `resume` 할 때 한 번에 적용된다", "Pod 가 바로 새 이미지로 교체된다", "변경이 오류로 거부된다", "변경이 버려지고 이전 이미지로 돌아간다"]', 0, 'pause 중의 변경은 롤아웃을 시작하지 않고 쌓여 있다가, `kubectl rollout resume` 을 하면 한 번의 롤아웃으로 적용됩니다. 그래서 여러 변경을 리비전 하나로 묶을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 305 AND order_index = 15);
-- 세트 306 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 306, 15, 'startupProbe 와 livenessProbe', '컨테이너에 `startupProbe` 와 `livenessProbe` 가 모두 있습니다. `startupProbe` 가 아직 성공하지 못한 동안 `livenessProbe` 는 어떻게 동작할까요?', 'startupProbe 가 무엇을 위한 프로브인지 이름에서 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["둘이 동시에 실행된다", "실행되지 않고 미뤄진다", "startupProbe 가 있으면 livenessProbe 는 영영 무시된다", "livenessProbe 가 먼저 성공해야 startupProbe 가 시작된다"]', 1, '`startupProbe` 가 성공하기 전에는 `livenessProbe` 가 실행되지 않습니다. 성공하면 그때부터 livenessProbe 가 동작하므로, 느리게 시작하는 앱이 시작 도중에 재시작되는 것을 막을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 306 AND order_index = 15);
-- 세트 307 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 307, 15, 'kubectl kustomize 의 효과', '`kubectl kustomize ./overlay` 를 실행하면 어떤 일이 일어날까요?', '적용하려면 다른 명령(-k 옵션)이 따로 있었죠.', NULL, NULL, '[]', 'choice', '["overlay 의 리소스가 클러스터에 적용된다", "overlay 폴더의 YAML 파일이 변환된 내용으로 덮어쓰기된다", "클러스터는 바뀌지 않고 변환된 YAML 만 출력된다", "overlay 에 있는 리소스가 클러스터에서 삭제된다"]', 2, '`kubectl kustomize` 는 변환 결과만 출력하고 클러스터를 바꾸지 않습니다. 적용은 `kubectl apply -k` 로 하므로, 출력을 먼저 확인한 뒤 적용하면 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 307 AND order_index = 15);
-- 세트 308 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 308, 15, 'Role 만으로는 권한이 없다', '네임스페이스 `dev` 에 Pod 읽기 권한을 가진 **Role** 을 만들었습니다. 사용자가 실제로 그 권한을 쓰게 하려면 **추가로 필요한 것**은 무엇일까요?', '권한 묶음과 사용할 대상을 이어 주는 리소스가 있습니다.', NULL, NULL, '[]', 'choice', '["Role 이름을 사용자 이름과 똑같이 짓는다", "Pod 를 다시 시작한다", "`kubectl scale` 로 복제 수를 늘린다", "RoleBinding 으로 Role 을 사용자에게 연결한다"]', 3, 'Role 은 어떤 동작을 허용할지 적어 둔 묶음일 뿐이라, Role 만으로는 아무도 권한을 얻지 못합니다. RoleBinding 으로 사용자 등 대상에 연결해야 `auth can-i` 가 `yes` 가 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 308 AND order_index = 15);
-- 세트 309 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 309, 15, 'subPath 마운트 파일의 갱신', 'ConfigMap 의 한 파일을 `subPath` 로 마운트한 Pod 가 있습니다. 나중에 ConfigMap 의 내용을 고치면 Pod 안의 그 파일은 어떻게 될까요?', '파일 하나만 골라 마운트하는 방식의 단점입니다.', NULL, NULL, '[]', 'choice', '["바뀌지 않고 이전 내용 그대로 남는다", "몇 초 안에 새 내용으로 바뀐다", "Pod 가 자동으로 재시작된다", "파일이 삭제된다"]', 0, '`subPath` 로 마운트한 파일은 ConfigMap 이 바뀌어도 갱신되지 않습니다. 반면 폴더 통째로 마운트한 볼륨 파일은 시간이 지나면 바뀝니다. 환경 변수는 어느 쪽이든 Pod 를 다시 시작해야 새 값이 적용돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 309 AND order_index = 15);
-- 세트 310 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 310, 15, '같은 파일을 다시 apply', '`kubectl apply -f cm.yaml` 로 이미 적용한 파일을 **내용 변경 없이** 한 번 더 apply 하면 출력은 어떻게 될까요?', '바뀐 게 없다는 뜻의 단어를 찾으세요.', NULL, NULL, '[]', 'choice', '["`configmap/c1 created`", "`configmap/c1 unchanged`", "`configmap/c1 configured`", "`configmap/c1 deleted`"]', 1, 'apply 는 결과를 `created`(새로 만듦), `configured`(바뀐 내용 적용), `unchanged`(변화 없음) 로 알려 줍니다. 같은 내용을 다시 적용하면 바뀔 것이 없어 `unchanged` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 310 AND order_index = 15);
-- 세트 311 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 311, 15, 'readiness 실패 Pod 의 모습', '`readinessProbe` 가 계속 실패하는 Pod 는 `kubectl get pod` 에서 어떻게 보일까요?', 'liveness 와 달리 readiness 는 컨테이너를 재시작하지 않습니다.', NULL, NULL, '[]', 'choice', '["`CrashLoopBackOff` 로 재시작을 반복한다", "바로 삭제되어 목록에서 사라진다", "`Pending` 상태로 스케줄되지 않는다", "`Running` 이지만 `READY` 는 `0/1` 이고 재시작하지 않는다"]', 3, 'readiness 가 실패하면 컨테이너는 계속 실행되지만 준비되지 않은 것으로 표시되어 `0/1 Running` 이 됩니다. 재시작을 일으키는 것은 liveness 의 실패입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 311 AND order_index = 15);
-- 세트 312 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 312, 15, '이전 ReplicaSet 의 운명', '`kubectl set image` 로 이미지를 바꾼 뒤, **이전 ReplicaSet** 은 어떻게 되나요?', '`kubectl get rs` 를 떠올려 보세요. 되돌릴 때 필요합니다.', NULL, NULL, '[]', 'choice', '["삭제되어 목록에서 사라진다", "파드 수가 그대로 유지되어 계속 일한다", "파드 수가 `0` 이 된 채 남아 있다", "새 ReplicaSet 으로 이름만 바뀐다"]', 2, '새 이미지로 새 ReplicaSet 이 만들어지고, 이전 ReplicaSet 은 파드 수만 `0` 으로 줄어든 채 남습니다. 남겨 두기 때문에 `rollout undo` 로 이전 버전으로 되돌릴 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 312 AND order_index = 15);
-- 세트 313 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 313, 15, 'OnFailure 와 정상 종료', '`restartPolicy: OnFailure` 인 파드의 컨테이너가 **종료 코드 `0`** 으로 끝나면 어떻게 되나요?', '`OnFailure` 는 "실패했을 때만" 이에요.', NULL, NULL, '[]', 'choice', '["다시 시작하지 않고 끝난다", "`Always` 처럼 무조건 다시 시작한다", "`CrashLoopBackOff` 상태가 된다", "`backoffLimit` 만큼 재시도한다"]', 0, '`OnFailure` 는 실패한 경우에만 다시 시작합니다. 종료 코드가 `0` 이면 정상 종료이므로 다시 시작하지 않고 파드는 끝난 상태가 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 313 AND order_index = 15);
-- 세트 314 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 314, 15, 'Insufficient cpu 의 뜻', '`Pending` 파드의 이벤트에 `Insufficient cpu` 가 보입니다. **원인**으로 맞는 것은?', '스케줄러는 실제 사용량이 아니라 무엇으로 판단하나요?', NULL, NULL, '[]', 'choice', '["노드에 필요한 라벨이 붙어 있지 않다", "이미지를 내려받지 못했다", "노드의 실제 CPU 사용률이 100% 라서 배치할 수 없다", "노드들의 남은 CPU 가 파드의 `requests.cpu` 보다 적다"]', 3, '스케줄러는 실제 사용량이 아니라 **요청량(requests)** 을 더해 남은 자원을 계산합니다. 어느 노드도 요청한 CPU 를 채워 줄 수 없으면 `Insufficient cpu` 이벤트와 함께 `Pending` 으로 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 314 AND order_index = 15);
-- 세트 315 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 315, 15, 'pull 이 하는 일', '`git pull` 은 **어떤 두 동작**을 한 번에 하는 명령인가요?', 'pull 의 설명을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["원격에 올리기와 합치기", "원격에서 가져오기와 합치기", "원격에서 가져오기와 커밋 삭제", "브랜치 만들기와 이동하기"]', 1, '`pull` 은 원격의 새 커밋을 가져오는 일과 내 브랜치에 합치는 일을 한 번에 합니다. 원격에 올리는 것은 `push` 의 일이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 315 AND order_index = 15);
-- 세트 316 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 316, 15, 'reset --soft 의 결과', '`git reset --soft HEAD~1` 을 실행한 직후, 취소된 커밋의 **변경 내용**은 어떻게 되나요?', '`--hard` 와 달리 변경을 지우지 않습니다.', NULL, NULL, '[]', 'choice', '["모두 사라진다", "스테이징에서 빠져 작업 폴더에만 남는다", "커밋만 취소되고 변경은 스테이징에 남는다", "커밋은 그대로이고 메시지만 지워진다"]', 2, '`--soft` 는 마지막 커밋만 풀고 변경은 스테이징에 그대로 남겨 둡니다. 변경까지 지워 버리는 것은 `--hard` 라서 훨씬 위험합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 316 AND order_index = 15);
-- 세트 317 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 317, 15, 'stash 와 새 파일', '옵션 없이 `git stash` 를 하면, 새로 만들어 아직 추적하지 않는 파일은 어떻게 되나요?', '새 파일까지 보관하려면 `-u` 가 필요했어요.', NULL, NULL, '[]', 'choice', '["작업 폴더에 그대로 남는다", "함께 보관되어 작업 폴더에서 사라진다", "자동으로 삭제된다", "스테이징 영역에 올라간다"]', 0, '옵션이 없으면 `stash` 는 이미 추적 중인 파일의 변경만 보관하고, 새 파일은 작업 폴더에 그대로 남습니다. 새 파일도 함께 치우려면 `-u` 를 붙입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 317 AND order_index = 15);
-- 세트 318 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 318, 15, 'merge --squash 직후 상태', '`git merge --squash feature` 를 실행한 직후의 상태로 맞는 것은?', '이 명령은 커밋을 만들지 않는다고 했습니다.', NULL, NULL, '[]', 'choice', '["feature 의 커밋들이 그대로 main 에 복사되어 있다", "병합 커밋이 부모 둘로 만들어져 있다", "병합이 자동으로 취소되어 아무 변화가 없다", "커밋은 없고 변경이 스테이징 영역에 올라가 있다"]', 3, '`--squash` 는 feature 의 변경을 하나로 뭉쳐 스테이징까지만 해 줍니다. 커밋은 이어서 `git commit` 으로 직접 한 번 만들어야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 318 AND order_index = 15);
-- 세트 319 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 319, 15, '-m 없이 병합 revert', '병합 커밋을 `git revert 병합커밋` 처럼 **`-m` 없이** 되돌리려 하면 어떻게 되나요?', '부모가 둘이라 기준을 알 수 없습니다.', NULL, NULL, '[]', 'choice', '["첫 번째 부모를 기준으로 자동으로 되돌려진다", "오류가 나서 되돌려지지 않는다", "병합 커밋이 이력에서 지워진다", "두 번째 부모를 기준으로 자동으로 되돌려진다"]', 1, '병합 커밋은 부모가 둘이라 어느 쪽을 기준으로 되돌릴지 정해 줘야 합니다. `-m 1` 처럼 기준 부모를 주지 않으면 `is a merge but no -m` 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 319 AND order_index = 15);
-- 세트 320 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 320, 15, 'HEAD~2 의 뜻', '`HEAD~2` 가 가리키는 커밋은 무엇인가요?', '`^2` 와 `~2` 는 다릅니다.', NULL, NULL, '[]', 'choice', '["두 번째 부모 쪽 커밋", "두 개의 부모를 모두 합친 커밋", "첫 번째 부모를 따라 두 번 올라간 커밋", "두 개 앞의 태그가 붙은 커밋"]', 2, '`~2` 는 첫 번째 부모를 따라 두 번 올라가는 표기입니다. 병합해 온 브랜치 쪽(두 번째 부모)을 가리키려면 `HEAD^2` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 320 AND order_index = 15);
-- 세트 321 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 321, 15, 'main...b1 비교', '`git diff main...b1` (점 세 개)는 **무엇을 비교**하나요?', '점 두 개는 두 브랜치 끝을 직접 비교합니다.', NULL, NULL, '[]', 'choice', '["공통 조상 이후 `b1` 에서 바뀐 것", "두 브랜치의 끝 커밋끼리 직접 비교한 차이", "`main` 에서만 바뀐 것", "두 브랜치의 파일 이름 목록"]', 0, '점 세 개는 두 브랜치의 공통 조상을 기준으로 `b1` 쪽에서 바뀐 것만 보여 줍니다. 점 두 개(`main..b1`)는 두 브랜치 끝을 곧바로 비교합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 321 AND order_index = 15);
-- 세트 322 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 322, 15, 'cherry-pick -x 의 효과', '`git cherry-pick -x 커밋` 으로 가져온 커밋은 **무엇이 달라지나요**?', '메시지에 출처를 남기는 옵션입니다.', NULL, NULL, '[]', 'choice', '["커밋을 만들지 않고 스테이징에만 쌓인다", "충돌이 나도 자동으로 해결된다", "여러 커밋을 한꺼번에 가져온다", "메시지에 원본 커밋의 해시가 덧붙는다"]', 3, '`-x` 는 새 커밋 메시지에 `(cherry picked from commit ...)` 줄을 붙여 어디서 가져왔는지 남깁니다. 커밋 없이 가져오는 옵션은 `-n` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 322 AND order_index = 15);
-- 세트 323 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 323, 15, 'export-ignore 의 효과', '`.gitattributes` 에 `secret.env export-ignore` 를 적으면 어떻게 되나요?', '`git archive` 와 관련된 속성입니다.', NULL, NULL, '[]', 'choice', '["저장소가 그 파일의 추적을 멈춘다", "`git archive` 결과에서만 빠지고 저장소의 추적 상태는 그대로다", "`git add` 가 그 파일을 거부한다", "`git clone` 으로도 그 파일이 내려오지 않는다"]', 1, '`export-ignore` 는 `git archive` 로 묶을 때만 해당 파일을 제외합니다. 저장소의 추적 상태나 clone 결과는 바뀌지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 323 AND order_index = 15);
-- 세트 324 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 324, 15, '--no-ff 의 결과', '빨리감기가 가능한 상황에서 `git merge --no-ff feat` 를 하면 **어떤 커밋**이 만들어지나요?', '부모의 수를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["부모가 하나인 일반 커밋", "커밋이 만들어지지 않고 포인터만 이동한다", "부모가 둘인 병합 커밋", "부모가 없는 첫 커밋"]', 2, '`--no-ff` 는 빨리감기가 가능해도 항상 병합 커밋을 만들게 합니다. 병합 커밋은 부모가 둘이라 브랜치가 합쳐진 흔적이 이력에 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 324 AND order_index = 15);
-- 세트 325 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 325, 15, '설정 범위의 우선순위', '같은 키가 **여러 범위**(system, global, local)에 저장돼 있으면 어느 값이 적용되나요?', '설정 파일을 읽는 순서를 떠올려 보세요. 같은 키가 여러 번 나오면 나중에 읽은 값이 앞의 값을 덮어씁니다.', NULL, NULL, '[]', 'choice', '["더 좁은 범위(저장소)의 값이 적용된다", "더 넓은 범위(컴퓨터 전체)의 값이 적용된다", "가장 먼저 읽힌 값이 적용된다", "항상 `--global` 의 값이 적용된다"]', 0, '값이 여러 파일에 있으면 나중에 읽는, 더 좁은 범위의 값이 적용됩니다. 그래서 저장소별(`--local`) 설정이 사용자 전역 설정보다 우선합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 325 AND order_index = 15);
-- 세트 326 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 326, 15, '분리된 HEAD 에서 브랜치 이름', '분리된 HEAD 상태에서 `git rev-parse --abbrev-ref HEAD` 를 실행하면 무엇이 출력될까요?', '브랜치 위에 있지 않으니 줄여 쓸 브랜치 이름이 없어요.', NULL, NULL, '[]', 'choice', '["오류가 나며 아무것도 출력되지 않는다", "`HEAD`", "직전에 있던 브랜치 이름", "빈 줄"]', 1, '분리된 HEAD 는 브랜치가 아니라 커밋을 직접 가리킵니다. 그래서 줄인 참조 이름으로 `HEAD` 가 그대로 출력됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 326 AND order_index = 15);
-- 세트 327 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 327, 15, '-G 가 찾는 커밋', '`git log -G \'v[0-9]\' -- g.txt` 는 어떤 커밋을 찾을까요?', '`-G` 는 grep 의 G, 즉 정규식이에요.', NULL, NULL, '[]', 'choice', '["커밋 메시지에 `v` 와 숫자가 들어간 커밋", "파일 이름이 `v` 와 숫자로 시작하는 커밋", "정규식에 맞는 줄이 추가되거나 지워진 커밋", "`v` 로 시작하는 태그가 붙은 커밋"]', 2, '`-G` 는 정규식에 맞는 줄이 추가되거나 지워진 커밋을 찾습니다. 커밋 메시지를 검색하는 것은 `--grep` 이고, 문자열의 개수가 바뀐 커밋을 찾는 것은 `-S` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 327 AND order_index = 15);
-- 세트 328 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 328, 15, 'git add -u 의 범위', '`a.txt` 를 수정하고 `new.txt` 를 새로 만든 상태에서 `git add -u` 를 실행하면 무엇이 스테이징될까요?', '`-u` 는 이미 추적 중인 파일만 대상으로 해요.', NULL, NULL, '[]', 'choice', '["`a.txt` 와 `new.txt` 둘 다", "`new.txt` 만", "아무것도 스테이징되지 않는다", "`a.txt` 만"]', 3, '`-u` 는 추적 중인 파일의 수정·삭제만 담습니다. 새 파일까지 모두 담으려면 `-A` 를 써야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 328 AND order_index = 15);
-- 세트 329 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 329, 15, '= NULL 로 찾으면', '`SELECT * FROM customers WHERE email = NULL;` 을 실행하면 어떻게 될까요?', 'NULL 은 `=` 로 비교할 수 없는 값이에요.', NULL, NULL, '[]', 'choice', '["오류 없이 아무 행도 나오지 않는다", "email 이 비어 있는 행이 나온다", "문법 오류가 난다", "모든 행이 나온다"]', 0, '`= NULL` 은 항상 거짓으로 평가되어 오류 없이 아무 행도 나오지 않습니다. 비어 있는 값은 `IS NULL` 로 찾아야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 329 AND order_index = 15);
-- 세트 330 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 330, 15, 'WHERE 에 집계 함수', '`SELECT customer_id, SUM(amount) FROM orders WHERE SUM(amount) >= 20000 GROUP BY customer_id;` 를 실행하면 어떻게 될까요?', '`WHERE` 는 묶기 전에 계산해서 아직 합계가 없어요.', NULL, NULL, '[]', 'choice', '["`GROUP BY` 를 찾을 수 없다는 문법 오류가 난다", "`Invalid use of group function` 오류가 난다", "오류 없이 0행이 나온다", "자동으로 `HAVING` 으로 바뀌어 실행된다"]', 1, '`WHERE` 는 묶기 전에 행을 거르므로 집계 값이 아직 없습니다. 그래서 `Invalid use of group function` 오류가 나며, 집계 결과의 조건은 `GROUP BY` 뒤의 `HAVING` 에 써야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 330 AND order_index = 15);
-- 세트 331 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 331, 15, 'LEFT JOIN 후 COUNT(c.id)', '`LEFT JOIN` 으로 고객별 주문 건수를 세는데 `COUNT(c.id)` 를 썼습니다. 주문이 한 건도 없는 고객의 값은 얼마로 나올까요?', '`c.id` 는 고객 쪽 컬럼이라 주문이 없어도 NULL 이 아니에요.', NULL, NULL, '[]', 'choice', '["0", "NULL", "1", "오류가 난다"]', 2, '주문이 없어도 고객 행은 남고 `c.id` 는 NULL 이 아니므로 1 로 셉니다. 주문 건수가 0 으로 나오게 하려면 주문 쪽 컬럼인 `COUNT(o.id)` 를 써야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 331 AND order_index = 15);
-- 세트 332 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 332, 15, 'SHOW GRANTS 만 쓰면', '계정 이름 없이 `SHOW GRANTS` 만 실행하면 무엇이 나올까요?', '`FOR` 를 붙이면 계정을 고를 수 있어요.', NULL, NULL, '[]', 'choice', '["서버의 모든 계정 권한", "문법 오류가 난다", "아무것도 나오지 않는다", "지금 접속한 내 계정의 권한"]', 3, '`FOR` 없이 `SHOW GRANTS` 만 쓰면 지금 접속한 내 계정의 권한이 나옵니다. 다른 계정의 권한은 `SHOW GRANTS FOR \'계정\'@\'위치\'` 로 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 332 AND order_index = 15);
-- 세트 333 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 333, 15, '트랜잭션 안의 CREATE TABLE', '트랜잭션 안에서 `INSERT` 한 뒤 `CREATE TABLE` 을 실행하고 `ROLLBACK` 하면 `INSERT` 한 행은 어떻게 될까요?', 'DDL 은 트랜잭션 밖에서 실행하는 습관이 필요한 이유예요.', NULL, NULL, '[]', 'choice', '["이미 자동 커밋되어 `ROLLBACK` 해도 남는다", "`ROLLBACK` 으로 함께 취소된다", "`CREATE TABLE` 이 오류로 거부된다", "`INSERT` 한 행이 일시적으로 숨겨졌다 복구된다"]', 0, '`CREATE TABLE` 같은 DDL 이 실행되면 앞의 변경이 자동으로 커밋됩니다. 그래서 이후의 `ROLLBACK` 으로는 `INSERT` 한 행이 되돌려지지 않고 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 333 AND order_index = 15);
-- 세트 334 #15 (choice)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 334, 15, 'UNIQUE 열의 NULL', '`email VARCHAR(50) UNIQUE` 열에 NULL 을 두 행에 넣으면 어떻게 될까요?', 'NULL 은 "값 없음"이라 서로 같다고 보지 않아요.', NULL, NULL, '[]', 'choice', '["두 번째에서 `ERROR 1062` 가 난다", "두 행 모두 들어간다", "두 번째에서 `ERROR 1048` 로 거부된다", "두 번째는 조용히 무시된다"]', 1, '`UNIQUE` 는 같은 값의 중복을 막지만 NULL 은 여러 번 넣을 수 있습니다. 그래서 두 행 모두 들어갑니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 334 AND order_index = 15);
