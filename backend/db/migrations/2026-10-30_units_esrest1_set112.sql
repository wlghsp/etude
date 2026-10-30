-- 미들웨어 세트 112. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set112.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 112, 'Elasticsearch REST 기본기: curl 로 상태 보고 넣고 검색하기', 'Elasticsearch 를 curl 로 다루는 기본기를 익힙니다. 9200/9300 포트, _cat/health·_cat/indices 읽기, 문서 저장·조회 메서드, 색인 후 검색 순서, _search 응답(took, hits) 읽기, query DSL, 오류 응답(index_not_found_exception) 읽기, _bulk 형식 만들기를 문제와 파일 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 112);
UPDATE quest_set SET display_order = 551, unit_id = (SELECT id FROM unit WHERE id = 22), icon = '🔎' WHERE id = 112;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 1, '클러스터 상태 보는 REST 주소 채우기', 'Elasticsearch 는 HTTP(9200 포트)로 조작합니다. ① **클러스터 상태**(green/yellow/red), ② **인덱스 목록**을 표로 보는 주소입니다. 빈칸을 채워 보세요.', '`_cat` 뒤에 보고 싶은 것의 이름이 와요.', NULL, NULL, '[]', 'fill', '["health", "indices", "nodes", "shards", "master"]', NULL, '`_cat/health` 는 클러스터 색깔과 샤드 수를, `_cat/indices` 는 인덱스별 상태·문서 수·크기를 보여 줘요. `?v` 는 제목 줄(verbose)을 붙여서 읽기 편하게 해요.', '[0, 1]', 'curl -s localhost:9200/_cat/{0}?v
curl -s localhost:9200/_cat/{1}?v', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 2, '9200 과 9300', 'Elasticsearch 의 기본 포트 `9200` 과 `9300` 의 역할로 알맞은 것은 무엇일까요?', '사람이 curl 로 접속하는 쪽은 어느 쪽일까요?', NULL, NULL, '[]', 'choice', '["9200 은 노드끼리, 9300 은 사람이 접속", "9200 은 HTTP REST API(사람·앱이 접속), 9300 은 노드끼리 통신(transport)", "둘 다 HTTP", "둘 다 SSH"]', 1, '맞아요! curl 로 부르는 것은 9200 이에요. 9300 은 클러스터 안의 노드들이 서로 이야기하는 통로라서, 외부에 열지 않는 것이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 3, '문서 저장과 조회 메서드', 'REST 에서 **문서를 저장**할 때와 **조회**할 때 쓰는 HTTP 메서드입니다. 빈칸을 채워 보세요.', '저장은 PUT, 읽기는 GET 이에요.', NULL, NULL, '[]', 'fill', '["PUT", "GET", "DELETE", "HEAD"]', NULL, '`PUT 인덱스/_doc/ID` 는 그 ID 로 문서를 저장(같은 ID 면 덮어쓰기), `GET` 은 읽기, `DELETE` 는 삭제예요. ID 를 자동으로 만들고 싶으면 `POST 인덱스/_doc` 을 써요.', '[0, 1]', 'curl -X {0} localhost:9200/shop/_doc/1 -d @doc.json
curl -X {1} localhost:9200/shop/_doc/1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 4, '문서를 넣고 검색하는 순서', '상품 문서를 Elasticsearch 에 넣고 검색해서 결과를 읽는 흐름을 **앞에서 뒤**로 놓아 보세요.', '넣고, 반영을 기다리고, 검색하고, 결과를 읽어요.', NULL, NULL, '[]', 'order', '["`_search` 로 조건을 보내 검색한다", "`PUT shop/_doc/1` 로 문서를 색인한다", "응답의 `hits` 에서 일치한 문서와 개수를 읽는다", "잠시 뒤(refresh 후) 문서가 검색 가능해진다"]', NULL, '**색인 → refresh 로 검색 가능 → _search → hits 읽기** 입니다. 방금 넣은 문서가 바로 검색되지 않는 것은 정상이고, 기본 1초 정도 뒤에 보여요. (62번 세트의 refresh 를 떠올려 보세요)', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 5, '_cat/indices 의 docs.count', '`_cat/indices` 표의 `docs.count` 열은 무엇을 뜻할까요?', '이름 그대로 "문서 수"예요.', NULL, NULL, '[]', 'choice', '["인덱스의 크기(MB)", "샤드의 개수", "검색 횟수", "그 인덱스에 들어 있는 문서의 개수"]', 3, '`docs.count` 는 문서 수, `store.size` 는 디스크 크기, `pri`/`rep` 는 primary/replica 샤드 수예요. 표를 읽는 연습이 장애 때 큰 도움이 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 6, '_search 응답 읽기', '`_search` 응답에 `"took": 12`, `"hits": {"total": {"value": 37}}` 이 있습니다. 올바른 해석은 무엇일까요?', 'took 은 걸린 시간, total 은 일치한 문서 수예요.', NULL, NULL, '[]', 'choice', '["검색에 12 ms 가 걸렸고 조건에 일치하는 문서가 37개다", "12개를 찾았고 37 ms 걸렸다", "37 개 인덱스를 검색했다", "12 개 샤드가 실패했다"]', 0, '`took` 은 밀리초 단위 소요 시간, `hits.total.value` 는 일치한 문서 수예요. `hits.hits` 배열에는 기본으로 상위 10개만 들어 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 7, '복잡한 검색은 어떻게?', '"message 에 error 가 있고, 최근 1시간이며, 레벨이 ERROR 인 문서"처럼 조건이 여러 개인 검색을 하려면 무엇을 쓸까요?', 'URL 한 줄로 쓰기엔 조건이 많아요.', NULL, NULL, '[]', 'choice', '["파일을 직접 열어 찾는다", "`ls` 로 찾는다", "`_search` 에 JSON 본문(query DSL: `bool`, `match`, `term`, `range`)으로 조건을 보낸다", "Elasticsearch 는 조건 검색을 못 한다"]', 2, '`?q=error` 같은 간단한 방식도 있지만, 조건이 늘면 JSON 본문의 query DSL 이 명확해요. 조건을 `bool` 안에 `must`/`filter` 로 쌓아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 8, '_cat/health 출력에서 상태 읽기', '`/tmp/health.txt` 는 `curl -s localhost:9200/_cat/health?v` 의 출력입니다. **클러스터 상태**(green/yellow/red) 단어만 **`/tmp/status.txt`** 에 저장하세요.', '첫 줄은 제목, 둘째 줄이 값이에요. 4번째 열이 상태예요. `awk` 의 `NR==2` 와 `$4` 를 써 보세요.\\n확인: `cat /tmp/health.txt`', 'cat /tmp/health.txt
awk ''NR==2{print $4}'' /tmp/health.txt > /tmp/status.txt
cat /tmp/status.txt

# awk 는 공백으로 열을 나눈다: NR 줄 번호, $4 네 번째 열', '["sh", "-c", "printf ''%s\\\\n'' ''epoch      timestamp cluster status node.total node.data shards pri relo init unassign pending_tasks active_shards_percent'' ''1730000000 10:00:00  prod    yellow          1         1     10  10    0    0        5             0                  66.7%'' > /tmp/health.txt"]', '["sh", "-c", "( [ -s /tmp/status.txt ] ) && ( [ \\"$(cat /tmp/status.txt)\\" = yellow ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/status.txt ]"]}, {"label": "상태가 yellow 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/status.txt)\\" = yellow ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 9, '문서가 가장 많은 인덱스 찾기', '`/tmp/indices.txt` 는 `_cat/indices?v` 의 출력입니다. **`docs.count` 가 가장 큰 인덱스의 이름**만 **`/tmp/biggest.txt`** 에 저장하세요.', '인덱스 이름은 3번째 열, `docs.count` 는 7번째 열이에요. 제목 줄을 빼고 7번째 열 숫자로 큰 순으로 정렬하세요.\\n확인: `cat /tmp/indices.txt`', 'cat /tmp/indices.txt
awk ''NR>1'' /tmp/indices.txt | sort -k7 -nr | head -n 1 | awk ''{print $3}'' > /tmp/biggest.txt
cat /tmp/biggest.txt

# sort -k7 -nr : 7번째 열을 숫자 기준 내림차순', '["sh", "-c", "printf ''%s\\\\n'' ''health status index              uuid pri rep docs.count docs.deleted store.size'' ''green  open   logs-2026.10.28   aaa  1   1   120000     0            200mb'' ''green  open   shop              bbb  1   1   3500       12           8mb'' ''yellow open   logs-2026.10.29   ccc  1   1   450000     5            760mb'' ''green  open   users             ddd  1   1   900        0            2mb'' > /tmp/indices.txt"]', '["sh", "-c", "( [ -s /tmp/biggest.txt ] ) && ( [ \\"$(cat /tmp/biggest.txt)\\" = logs-2026.10.29 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/biggest.txt ]"]}, {"label": "가장 큰 인덱스가 logs-2026.10.29 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/biggest.txt)\\" = logs-2026.10.29 ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 10, '검색 JSON 의 따옴표 빠진 곳 고치기', '`/tmp/query.json` 은 `message` 필드에 `error` 가 들어 있는 문서를 찾는 검색 본문인데, **값에 따옴표가 빠져** JSON 이 올바르지 않습니다. 값 `error` 를 **문자열(따옴표)** 로 고치세요.', 'JSON 에서 문자열 값은 큰따옴표로 감싸야 해요. 고친 뒤에는 `{` 와 `}` 개수가 같은지도 확인해 보세요.\\n확인: `cat /tmp/query.json`', 'cat /tmp/query.json
sed -i ''s/: error }/: "error" }/'' /tmp/query.json
cat /tmp/query.json

# JSON 문자열은 큰따옴표로 감싼다', '["sh", "-c", "printf ''%s\\\\n'' ''{ \\"query\\": { \\"match\\": { \\"message\\": error } } }'' > /tmp/query.json"]', '["sh", "-c", "( grep -q ''\\"message\\": *\\"error\\"'' /tmp/query.json ) && ( [ \\"$(tr -cd \\"{\\" < /tmp/query.json | wc -c)\\" = \\"$(tr -cd \\"}\\" < /tmp/query.json | wc -c)\\" ] ) && ( grep -q ''\\"match\\"'' /tmp/query.json )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 문자열 \\"error\\" 이다", "cmd": ["sh", "-c", "grep -q ''\\"message\\": *\\"error\\"'' /tmp/query.json"]}, {"label": "중괄호 짝이 맞는다", "cmd": ["sh", "-c", "[ \\"$(tr -cd \\"{\\" < /tmp/query.json | wc -c)\\" = \\"$(tr -cd \\"}\\" < /tmp/query.json | wc -c)\\" ]"]}, {"label": "match 쿼리 구조가 그대로다", "cmd": ["sh", "-c", "grep -q ''\\"match\\"'' /tmp/query.json"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 11, '에러 응답에서 원인 종류 뽑기', '`/tmp/resp.txt` 는 Elasticsearch 가 돌려준 **오류 응답**입니다. 오류의 `type`(원인 종류) 한 단어만 **`/tmp/type.txt`** 에 저장하세요.', '첫 번째 `"type":"…"` 값이 원인 종류예요. `grep -o` 로 뽑고 `cut` 으로 따옴표 안만 남기세요.\\n확인: `cat /tmp/resp.txt`', 'cat /tmp/resp.txt
grep -o ''"type":"[^"]*"'' /tmp/resp.txt | head -n 1 | cut -d''"'' -f4 > /tmp/type.txt
cat /tmp/type.txt

# 404 + index_not_found_exception: 인덱스 이름이 없거나 틀림', '["sh", "-c", "printf ''%s\\\\n'' ''{\\"error\\":{\\"root_cause\\":[{\\"type\\":\\"index_not_found_exception\\",\\"reason\\":\\"no such index [shopp]\\"}],\\"type\\":\\"index_not_found_exception\\",\\"reason\\":\\"no such index [shopp]\\"},\\"status\\":404}'' > /tmp/resp.txt"]', '["sh", "-c", "( [ -s /tmp/type.txt ] ) && ( [ \\"$(cat /tmp/type.txt)\\" = index_not_found_exception ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/type.txt ]"]}, {"label": "원인 종류가 index_not_found_exception 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/type.txt)\\" = index_not_found_exception ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 112, 12, '_bulk 형식 만들기', '`_bulk` API 는 문서마다 **두 줄**(① 어떤 동작인지 `{"index":{"_index":"shop"}}`, ② 문서 내용)이 필요합니다. `/tmp/docs.txt` 의 이름(한 줄에 하나)으로 `{"name":"이름"}` 문서를 만들어, 이 두 줄 형식으로 **`/tmp/bulk.ndjson`** 에 저장하세요.', '이름마다 동작 줄 하나, 문서 줄 하나를 `echo` 하는 반복문(`while read`)을 만들어 보세요.\\n확인: `cat /tmp/bulk.ndjson`', 'cat /tmp/docs.txt
while read n; do
  echo ''{"index":{"_index":"shop"}}''
  echo "{\\"name\\":\\"$n\\"}"
done < /tmp/docs.txt > /tmp/bulk.ndjson
cat /tmp/bulk.ndjson

# _bulk 은 줄마다 JSON 한 개 (NDJSON). 동작 줄 + 문서 줄이 한 쌍', '["sh", "-c", "printf ''%s\\\\n'' pen book > /tmp/docs.txt"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/bulk.ndjson)\\" -eq 4 ] ) && ( [ \\"$(sed -n 1p /tmp/bulk.ndjson)\\" = ''{\\"index\\":{\\"_index\\":\\"shop\\"}}'' ] ) && ( [ \\"$(sed -n 2p /tmp/bulk.ndjson)\\" = ''{\\"name\\":\\"pen\\"}'' ] ) && ( [ \\"$(sed -n 4p /tmp/bulk.ndjson)\\" = ''{\\"name\\":\\"book\\"}'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "4줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/bulk.ndjson)\\" -eq 4 ]"]}, {"label": "첫 줄이 동작 줄이다", "cmd": ["sh", "-c", "[ \\"$(sed -n 1p /tmp/bulk.ndjson)\\" = ''{\\"index\\":{\\"_index\\":\\"shop\\"}}'' ]"]}, {"label": "둘째 줄이 pen 문서이다", "cmd": ["sh", "-c", "[ \\"$(sed -n 2p /tmp/bulk.ndjson)\\" = ''{\\"name\\":\\"pen\\"}'' ]"]}, {"label": "넷째 줄이 book 문서이다", "cmd": ["sh", "-c", "[ \\"$(sed -n 4p /tmp/bulk.ndjson)\\" = ''{\\"name\\":\\"book\\"}'' ]"]}]', '[{"title": "Elasticsearch 공식 문서", "url": "https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 112 AND order_index = 12);
