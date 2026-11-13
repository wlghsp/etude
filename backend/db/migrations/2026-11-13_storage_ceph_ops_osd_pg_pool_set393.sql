-- 퀴즈 세트 393. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round6.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 393, 'Ceph 운영: OSD up/down·in/out, PG 상태, 풀 size·min_size', 'Ceph 클러스터를 읽는 법을 익힙니다. OSD 의 up·down 과 in·out, mon_osd_down_out_interval 과 noout, PG 상태(active+clean·degraded·stale), 풀의 size·min_size·삭제 조건, down OSD 를 되살리는 순서를 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 393);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 1, 'OSD up 과 down', 'Ceph 에서 OSD 의 **up/down** 은 무엇을 가리킬까요?', '실행·도달 가능 여부예요.', NULL, NULL, '[]', 'choice', '["서비스에 포함되어 있으면 up, 빠져 있으면 down", "디스크 사용량이 낮으면 up, 높으면 down", "실행 중이고 도달 가능하면 up, 아니면 down", "데이터가 복제되었으면 up, 아니면 down"]', 2, 'Ceph 문서는 OSD 가 실행 중이고 도달 가능하면 up, 아니면 down 이라고 설명합니다. 서비스에 포함됐는지는 in/out 입니다.', NULL, NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 2, 'down 에서 out 으로', 'down 상태가 된 OSD 는 **언제 out 으로 표시** 될까요?', '기본 600초예요.', NULL, NULL, '[]', 'choice', '["down 이 되는 즉시 곧바로 out 이 되도록 정해져 있다", "기본 600초 동안 down 이면 out 이 된다", "관리자가 직접 지정해야만 out 이 되도록 정해져 있다", "데이터 복제가 모두 끝나야 비로소 out 이 된다"]', 1, '문서는 down 인 OSD 가 모니터가 out 으로 표시할 때까지 in 상태로 남으며, 보통 mon_osd_down_out_interval(기본 600초) 만큼 down 이면 out 이 되고 noout 플래그가 있으면 제외된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 3, 'down 이면서 in', 'OSD 가 **down 이면서 in** 인 상태는 무엇을 뜻할까요?', '문제의 신호예요.', NULL, NULL, '[]', 'choice', '["문제가 있는 상태이고 클러스터가 건강하지 않다", "서비스에서 정상적으로 빠진 상태", "업그레이드가 끝난 정상 상태", "새 OSD 가 막 추가된 정상 상태"]', 0, '문서는 OSD 가 down 이면서 in 이면 문제가 있다고(클러스터가 건강하지 않다고) 설명합니다.', NULL, NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 4, 'active+clean', 'PG 상태 **active+clean** 은 무엇일까요?', '목표가 되는 상태예요.', NULL, NULL, '[]', 'choice', '["복제본이 모자라 복구하고 있는 중인 상태", "OSD 들이 PG 상태를 맞추는 중인 상태", "주 OSD 가 down 이라 통계가 없는 상태", "읽기·쓰기가 되고 복제본이 모두 있는 목표 상태"]', 3, '문서는 active+clean 을 PG 가 읽기·쓰기에 쓰일 수 있고 모든 복제본이 갖춰진 목표 상태로 설명합니다. 맞추는 중은 peering, 통계가 없는 것은 stale 입니다.', NULL, NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 5, 'degraded', 'PG 상태 **degraded** 는 무엇일까요?', '복제본이 모자라요.', NULL, NULL, '[]', 'choice', '["모든 오브젝트가 필요한 횟수만큼 저장된 정상 상태", "주 OSD 가 down 이라 통계가 오지 않는 상태", "일부 오브젝트가 필요한 횟수만큼 저장되지 않은 상태", "복구 때문에 데이터를 이동시키는 중인 상태"]', 2, '문서는 degraded 를 일부 오브젝트가 필요한 횟수만큼 저장되지 않은 상태(예: OSD 가 down)로 설명합니다. 통계가 없는 것은 stale 입니다.', NULL, NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 6, 'stale', 'PG 상태 **stale** 은 무엇일까요?', '주 OSD 와 관련이 있어요.', NULL, NULL, '[]', 'choice', '["복제본이 부족해 새 복제본을 만드는 중인 상태", "주 OSD 가 down 이라 최신 통계가 없는 상태", "용량이 부족해 백필이 막혀 있는 상태", "OSD 들이 PG 상태에 합의하는 중인 상태"]', 1, '문서는 stale 을 주 OSD 가 down 이라 매니저가 PG 의 현재 통계를 갖지 못한 상태로 설명하며 시작 직후에는 peering 이 끝날 때까지 흔하다고 합니다.', NULL, NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 7, '풀의 size', 'Ceph 풀의 **size** 설정은 무엇이며 기본값은 얼마일까요?', '복제본 수예요.', NULL, NULL, '[]', 'choice', '["복제본 수(주 사본 포함), 기본 3", "I/O 가 가능한 최소 복제본 수이며 기본은 1", "풀이 담을 수 있는 최대 용량이며 기본은 3TB", "PG 의 개수를 정하는 값이며 기본은 3"]', 0, '문서는 size 를 풀 오브젝트의 복제본 수(주 사본 포함)로, 기본은 3 이라고 설명합니다. I/O 가능 최소 수는 min_size 입니다.', NULL, NULL, NULL, '[{"title": "Ceph 풀", "url": "https://docs.ceph.com/en/latest/rados/operations/pools/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 8, 'min_size', '풀의 **min_size** 는 무엇을 정할까요?', '이 아래로 떨어지면 I/O 가 멈춰요.', NULL, NULL, '[]', 'choice', '["풀에 만들 수 있는 최소 오브젝트 수를 정한다", "풀을 만들 때 필요한 최소 OSD 수를 정한다", "복구 중 쓰는 최소 네트워크 대역폭을 정한다", "I/O 에 필요한 최소 활성 복제본 수"]', 3, '문서는 min_size 를 PG 가 활성이 되어 I/O 가 진행되기 위한 최소 활성 복제본(또는 샤드) 수로 설명하며, 운영에서 1 로 두면 데이터 손실 위험이 있다고 경고합니다.', NULL, NULL, NULL, '[{"title": "Ceph 풀", "url": "https://docs.ceph.com/en/latest/rados/operations/pools/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 9, '풀 삭제 조건', 'Ceph 풀을 **삭제** 하려면 반드시 필요한 설정은 무엇일까요?', '모니터가 막는 안전장치예요.', NULL, NULL, '[]', 'choice', '["풀이 비어 있으면 언제든 곧바로 삭제할 수 있다", "OSD 를 모두 out 으로 먼저 만들어 두어야 한다", "mon_allow_pool_delete 가 true 여야 한다", "풀 이름 끝에 delete 를 붙여 두어야 한다"]', 2, '문서는 풀 삭제 명령(ceph osd pool delete)에 --yes-i-really-really-mean-it 가 필요하고, mon_allow_pool_delete 가 true 가 아니면 모니터가 삭제를 거부한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Ceph 풀", "url": "https://docs.ceph.com/en/latest/rados/operations/pools/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 10, '이동을 막는 플래그', 'OSD 가 down 이 되어도 모니터가 **out 으로 표시하지 않게** 하는 플래그입니다. 빈칸을 채우세요.', '"no" 로 시작해요.', NULL, NULL, '[]', 'fill', '["noout", "nodown", "noup", "norecover"]', NULL, 'noout 플래그가 설정돼 있으면 down 이 오래 지속돼도 모니터가 OSD 를 out 으로 표시하지 않습니다. 점검처럼 일시적으로 내릴 때 흔히 쓰입니다.', '[0]', 'ceph osd set {0}', NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 11, 'OSD 트리 보기', '각 OSD 의 **up/down 상태를 트리** 로 보여 주는 명령의 마지막 단어입니다. 빈칸을 채우세요.', '나무 모양이에요.', NULL, NULL, '[]', 'fill', '["tree", "stat", "dump", "ls"]', NULL, 'ceph osd tree 는 OSD 를 STATUS(up/down) 와 함께 트리로 보여 줍니다. ceph osd stat 은 총 개수와 up·in 개수 요약입니다.', '[0]', 'ceph osd {0}', NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 393, 12, 'down OSD 를 되살리기', 'OSD 하나가 down 일 때 되살리는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 찾기 → 시작 → 확인이에요.', NULL, NULL, '[]', 'order', '["ceph -s 로 클러스터 상태와 PG 상태를 확인한다", "ceph osd tree 로 down 인 OSD 를 찾는다", "해당 호스트에서 OSD 데몬을 시작한다(ceph orch daemon start 등)", "복구가 끝나 PG 가 active+clean 이 되었는지 확인한다"]', NULL, '문서의 OSD 확인·재시작 안내를 이은 큰 줄기입니다. cephadm 이면 ceph orch daemon start osd.N, 패키지 설치면 systemctl start ceph-osd@N 을 씁니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Ceph OSD·PG 모니터링", "url": "https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 393 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 623, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🩹' WHERE id = 393;
