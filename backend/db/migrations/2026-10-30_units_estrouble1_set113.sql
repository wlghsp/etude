-- 미들웨어 세트 113. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set113.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 113, 'Elasticsearch 문제 해결 상황집: yellow/red, 미할당 샤드, 디스크', 'Elasticsearch 가 yellow/red 가 되거나 쓰기가 막힐 때 원인을 찾아 해결하는 법을 익힙니다. 클러스터 진단 순서, yellow 와 red 의 의미, 디스크 워터마크 3단계, read-only 블록 해제, allocation/explain 읽기(NODE_LEFT, disk_threshold), 미할당 샤드 찾기, 오래된 인덱스 정리 명령 만들기를 문제와 파일 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 113);
UPDATE quest_set SET display_order = 554, unit_id = (SELECT id FROM unit WHERE id = 22), icon = '🆘' WHERE id = 113;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 1, '상태와 미할당 이유를 보는 주소 채우기', '클러스터가 yellow/red 일 때 ① **전체 상태**를 보고, ② **샤드가 왜 배치되지 않았는지** 이유를 묻는 주소입니다. 빈칸을 채워 보세요.', '상태는 health, 이유를 설명해 달라는 것은 explain 이에요.', NULL, NULL, '[]', 'fill', '["health", "explain", "stats", "settings"]', NULL, '`_cluster/health` 는 green/yellow/red 와 미할당 샤드 수를, `_cluster/allocation/explain` 은 미할당 샤드 하나에 대해 "왜 못 배치됐는지"를 판정 단계(decider)별로 보여 줘요. 원인을 추측하지 않고 시스템에게 물어보는 가장 좋은 방법이에요.', '[0, 1]', 'curl -s localhost:9200/_cluster/{0}
curl -s localhost:9200/_cluster/allocation/{1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 2, 'yellow/red 를 진단하는 순서', '클러스터가 갑자기 yellow(또는 red)가 되었습니다. 원인을 좁혀 가는 흐름을 **앞에서 뒤**로 놓아 보세요.', '전체 상태 → 어느 인덱스·샤드 → 왜 → 해결 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`_cluster/allocation/explain` 으로 그 샤드가 배치되지 않는 이유를 읽는다", "`_cluster/health` 로 상태와 미할당 샤드 수를 확인한다", "원인(디스크, 노드 이탈, 설정)을 해결한 뒤 `_cluster/health` 로 green 이 되는지 확인한다", "`_cat/shards` 로 UNASSIGNED 인 샤드가 어느 인덱스인지 찾는다"]', NULL, '**health → _cat/shards(어느 샤드) → allocation/explain(왜) → 해결 후 확인** 입니다. 샤드가 어떤 인덱스의 primary 인지(red)·replica 인지(yellow)에 따라 긴급도가 달라요.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 3, 'yellow 는 왜 생길까?', '노드가 **하나뿐인** 클러스터에서 인덱스가 `yellow` 입니다. 가장 알맞은 설명은 무엇일까요?', 'replica 샤드는 primary 와 같은 노드에 둘 수 없어요.', NULL, NULL, '[]', 'choice', '["데이터가 모두 사라졌다", "디스크가 가득 찼다", "replica 샤드를 둘 다른 노드가 없어 미할당이다. 데이터(primary)는 안전하지만 복제본이 없다", "검색이 불가능하다"]', 2, 'yellow 는 "primary 는 다 있고 replica 가 일부 없음"이에요. 단일 노드 개발 환경에서는 흔하고, 운영이라면 노드 이탈이나 디스크 부족을 의심해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 4, 'red 는 얼마나 급할까?', '`red` 는 무엇을 뜻하고 어떻게 다뤄야 할까요?', 'primary 샤드가 없다면 그 데이터를 읽을 수 없어요.', NULL, NULL, '[]', 'choice', '["일부 인덱스의 primary 샤드가 미할당이라 그 데이터를 쓸 수 없다. 가장 먼저 원인(노드 이탈, 디스크)을 찾아 복구하고, 필요하면 스냅샷 복원을 준비한다", "정상이니 무시한다", "인터넷이 끊겼다", "로그가 많다는 뜻이다"]', 0, 'red 는 데이터 접근에 영향이 있어요. 그래서 스냅샷을 평소에 떠 두는 것이 중요해요. (백업과 복원은 필수 과정이에요)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 5, '디스크 워터마크 이해하기', '디스크 사용률이 올라가면 Elasticsearch 가 단계적으로 반응합니다. low 85%, high 90%, flood-stage 95% 중 **95%** 에 도달하면 무슨 일이 생길까요?', '가장 위험한 단계예요.', NULL, NULL, '[]', 'choice', '["노드가 즉시 삭제된다", "자동으로 디스크가 늘어난다", "아무 일도 없다", "해당 노드의 인덱스가 읽기 전용(삭제만 허용)으로 바뀌어 새 문서를 쓸 수 없게 된다"]', 3, 'low(85%)는 새 샤드 할당 중단, high(90%)는 샤드를 다른 노드로 옮김, flood-stage(95%)는 읽기 전용 블록이에요. 90% 가 되기 전에 정리하는 것이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 6, '"read-only / allow delete" 오류', '쓰기가 `cluster_block_exception: index [logs] blocked by: [TOO_MANY_REQUESTS/12/disk usage exceeded flood-stage watermark, index has read-only-allow-delete block]` 로 거부됩니다. 올바른 조치는 무엇일까요?', '원인은 디스크 사용률이에요.', NULL, NULL, '[]', 'choice', '["오류를 무시하고 계속 쓴다", "디스크 공간을 먼저 확보(오래된 인덱스 삭제, ILM 정리, 디스크 증설)하고, 여유가 생긴 뒤 `index.blocks.read_only_allow_delete` 를 해제한다", "인덱스 이름을 바꾼다", "노드를 삭제한다"]', 1, '공간이 확보되면 최신 버전은 블록을 자동 해제하기도 하지만, 남아 있다면 설정에서 `null` 로 풀어 줘요. 공간 확보 전에 풀면 곧 다시 막혀요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 7, '미할당 이유 NODE_LEFT', '`allocation/explain` 의 `unassigned_info.reason` 이 `NODE_LEFT` 입니다. 무슨 뜻일까요?', '샤드를 가지고 있던 노드가 사라졌어요.', NULL, NULL, '[]', 'choice', '["샤드가 손상되었다", "인덱스가 만들어진 직후이다", "그 샤드를 가지고 있던 노드가 클러스터에서 빠졌다. 노드가 돌아오기를 잠시 기다리거나, 돌아오지 못하면 다른 노드에 복구한다", "권한이 없다"]', 2, '노드가 잠깐 재시작한 경우라면 돌아온 뒤 자동으로 복구돼요(지연 할당 시간 설정이 있어요). 노드가 완전히 사라졌다면 replica 가 primary 로 승격되었는지 확인해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 8, 'health 응답에서 미할당 샤드 수 뽑기', '`/tmp/health.json` 은 `_cluster/health` 의 응답입니다. **미할당 샤드 수**(`unassigned_shards` 값) 숫자만 **`/tmp/n.txt`** 에 저장하세요.', '`grep` 으로 그 줄을 찾고 숫자만 남기세요(`grep -o "[0-9]*"`).\\n확인: `cat /tmp/health.json`', 'cat /tmp/health.json
grep unassigned_shards /tmp/health.json | grep -o ''[0-9]*'' > /tmp/n.txt
cat /tmp/n.txt

# unassigned_shards 가 0 이 아니면 yellow/red 의 원인이 있다', '["sh", "-c", "printf ''%s\\\\n'' ''{'' ''  \\"cluster_name\\" : \\"prod\\",'' ''  \\"status\\" : \\"yellow\\",'' ''  \\"number_of_nodes\\" : 1,'' ''  \\"active_primary_shards\\" : 10,'' ''  \\"active_shards\\" : 10,'' ''  \\"unassigned_shards\\" : 5'' ''}'' > /tmp/health.json"]', '["sh", "-c", "( [ -s /tmp/n.txt ] ) && ( [ \\"$(cat /tmp/n.txt)\\" = 5 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/n.txt ]"]}, {"label": "값이 5 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/n.txt)\\" = 5 ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 9, 'UNASSIGNED 샤드를 가진 인덱스 찾기', '`/tmp/shards.txt` 는 `_cat/shards` 의 출력입니다. 상태가 **`UNASSIGNED`** 인 샤드를 가진 **인덱스 이름**을 중복 없이 정렬해 **`/tmp/un.txt`** 에 저장하세요.', '4번째 열이 상태, 1번째 열이 인덱스 이름이에요. `awk` 로 고르고 `sort -u` 로 중복을 없애세요.\\n확인: `cat /tmp/shards.txt`', 'cat /tmp/shards.txt
awk ''$4=="UNASSIGNED"{print $1}'' /tmp/shards.txt | sort -u > /tmp/un.txt
cat /tmp/un.txt

# sort -u : 정렬하면서 중복 제거', '["sh", "-c", "printf ''%s\\\\n'' ''logs-1 0 p STARTED    1000 10mb node-1'' ''logs-1 0 r UNASSIGNED'' ''logs-1 1 p STARTED    900  9mb  node-1'' ''logs-1 1 r UNASSIGNED'' ''shop   0 p STARTED    50   1mb  node-1'' ''shop   0 r UNASSIGNED'' > /tmp/shards.txt"]', '["sh", "-c", "( [ -s /tmp/un.txt ] ) && ( [ \\"$(cat /tmp/un.txt | tr \\"\\\\n\\" \\" \\")\\" = \\"logs-1 shop \\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/un.txt ]"]}, {"label": "logs-1 과 shop 이 한 번씩 있다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/un.txt | tr \\"\\\\n\\" \\" \\")\\" = \\"logs-1 shop \\" ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 10, 'allocation/explain 에서 막는 판정자 찾기', '`/tmp/explain.json` 은 `allocation/explain` 의 응답입니다. 샤드 배치를 **막고 있는 판정자(decider)의 이름**만 **`/tmp/decider.txt`** 에 저장하세요.', '`"decider" : "…"` 줄의 값이 판정자 이름이에요. `grep` 과 `cut -d''"''` 로 따옴표 안만 뽑으세요.\\n확인: `cat /tmp/explain.json`', 'cat /tmp/explain.json
grep ''"decider"'' /tmp/explain.json | cut -d''"'' -f4 > /tmp/decider.txt
cat /tmp/decider.txt

# disk_threshold : 디스크 사용률 때문에 배치가 거부됨', '["sh", "-c", "printf ''%s\\\\n'' ''{'' ''  \\"index\\" : \\"logs-1\\",'' ''  \\"shard\\" : 0,'' ''  \\"primary\\" : false,'' ''  \\"current_state\\" : \\"unassigned\\",'' ''  \\"unassigned_info\\" : { \\"reason\\" : \\"NODE_LEFT\\" },'' ''  \\"can_allocate\\" : \\"no\\",'' ''  \\"node_allocation_decisions\\" : ['' ''    {'' ''      \\"node_name\\" : \\"node-1\\",'' ''      \\"deciders\\" : ['' ''        {'' ''          \\"decider\\" : \\"disk_threshold\\",'' ''          \\"decision\\" : \\"NO\\",'' ''          \\"explanation\\" : \\"the node is above the high watermark cluster setting, actual free: [8.2%]\\"'' ''        }'' ''      ]'' ''    }'' ''  ]'' ''}'' > /tmp/explain.json"]', '["sh", "-c", "( [ -s /tmp/decider.txt ] ) && ( [ \\"$(cat /tmp/decider.txt)\\" = disk_threshold ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/decider.txt ]"]}, {"label": "판정자가 disk_threshold 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/decider.txt)\\" = disk_threshold ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 11, '읽기 전용 블록 해제 명령 작성', '디스크 공간을 확보한 뒤, 모든 인덱스의 **`read_only_allow_delete` 블록을 해제**하는 `curl` 명령을 **`/tmp/unblock.txt`** 에 **한 줄**로 적어 두세요. (`PUT`, 주소 `localhost:9200/_all/_settings`, 값 `null`)', '설정 바꾸기는 PUT `_settings` 이고, 본문은 `{"index.blocks.read_only_allow_delete": null}` 이에요. 헤더 `Content-Type: application/json` 도 필요해요.', 'cat > /tmp/unblock.txt <<''EOF''
curl -X PUT localhost:9200/_all/_settings -H ''Content-Type: application/json'' -d ''{"index.blocks.read_only_allow_delete": null}''
EOF
cat /tmp/unblock.txt

# 공간을 먼저 확보한 뒤에 해제해야 다시 막히지 않는다', '["sh", "-c", "rm -f /tmp/unblock.txt"]', '["sh", "-c", "( [ -s /tmp/unblock.txt ] ) && ( grep -q \\"PUT\\" /tmp/unblock.txt ) && ( grep -q \\"_all/_settings\\" /tmp/unblock.txt ) && ( grep -q \\"read_only_allow_delete\\" /tmp/unblock.txt && grep -q \\"null\\" /tmp/unblock.txt ) && ( grep -qi \\"content-type: application/json\\" /tmp/unblock.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/unblock.txt ]"]}, {"label": "PUT 이다", "cmd": ["sh", "-c", "grep -q \\"PUT\\" /tmp/unblock.txt"]}, {"label": "_settings 주소를 쓴다", "cmd": ["sh", "-c", "grep -q \\"_all/_settings\\" /tmp/unblock.txt"]}, {"label": "read_only_allow_delete 를 null 로 푼다", "cmd": ["sh", "-c", "grep -q \\"read_only_allow_delete\\" /tmp/unblock.txt && grep -q \\"null\\" /tmp/unblock.txt"]}, {"label": "Content-Type 헤더가 있다", "cmd": ["sh", "-c", "grep -qi \\"content-type: application/json\\" /tmp/unblock.txt"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 113, 12, '오래된 로그 인덱스 삭제 명령 만들기', '디스크 확보를 위해 **2026년 10월 이전**의 `logs-` 인덱스를 지우려 합니다. `/tmp/indices.txt` 의 인덱스 이름에서 **대상만** 골라 `curl -X DELETE localhost:9200/이름` 형태의 명령을 한 줄씩 **`/tmp/delete.sh`** 에 저장하세요. (**실행은 하지 마세요.** 지우기 전에 목록을 확인하는 습관입니다)', '`grep` 으로 `logs-2026.08`, `logs-2026.09` 로 시작하는 이름만 고르고 `sed` 로 앞에 명령을 붙이세요. `shop` 은 대상이 아니에요.\\n확인: `cat /tmp/indices.txt`', 'cat /tmp/indices.txt
grep -E ''^logs-2026\\.0[89]'' /tmp/indices.txt | sed ''s#^#curl -X DELETE localhost:9200/#'' > /tmp/delete.sh
cat /tmp/delete.sh

# 삭제 명령은 만든 뒤 눈으로 확인하고 실행한다 (인덱스 삭제는 되돌릴 수 없다)', '["sh", "-c", "printf ''%s\\\\n'' ''logs-2026.08.15'' ''logs-2026.09.20'' ''logs-2026.10.05'' ''logs-2026.10.28'' ''shop'' > /tmp/indices.txt"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/delete.sh)\\" -eq 2 ] ) && ( grep -qx \\"curl -X DELETE localhost:9200/logs-2026.08.15\\" /tmp/delete.sh ) && ( grep -qx \\"curl -X DELETE localhost:9200/logs-2026.09.20\\" /tmp/delete.sh ) && ( ! grep -qE \\"2026.10|shop\\" /tmp/delete.sh )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "2줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/delete.sh)\\" -eq 2 ]"]}, {"label": "8월 인덱스 삭제 명령이 있다", "cmd": ["sh", "-c", "grep -qx \\"curl -X DELETE localhost:9200/logs-2026.08.15\\" /tmp/delete.sh"]}, {"label": "9월 인덱스 삭제 명령이 있다", "cmd": ["sh", "-c", "grep -qx \\"curl -X DELETE localhost:9200/logs-2026.09.20\\" /tmp/delete.sh"]}, {"label": "10월 인덱스와 shop 은 포함되지 않는다", "cmd": ["sh", "-c", "! grep -qE \\"2026.10|shop\\" /tmp/delete.sh"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 113 AND order_index = 12);
