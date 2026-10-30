-- 리눅스 세트 90. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set90.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 18, '미들웨어', '관측 (모니터링·로그)', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 18);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 90, '관측 쿼리와 설정 다루기: PromQL, LogQL, 메트릭 읽기', 'Prometheus 의 PromQL 과 Loki 의 LogQL 을 빈칸으로 채워 읽고, 장애를 메트릭 → 로그 → 트레이스로 좁혀 가는 순서를 놓고, Prometheus 가 노출하는 텍스트 형식의 메트릭을 grep·awk 로 직접 읽고 계산하며 알림 규칙의 오류를 고칩니다. 카디널리티가 왜 위험한지도 직접 세어 봅니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 90);
UPDATE quest_set SET display_order = 522, unit_id = (SELECT id FROM unit WHERE id = 18), icon = '🔭' WHERE id = 90;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 1, 'PromQL: 초당 요청 수 구하기', '`job="api"` 의 `http_requests_total`(누적 counter)에서 **최근 5분 동안의 초당 평균 증가율**을 구하는 쿼리입니다. 빈칸을 채우세요. (※ PromQL 문법은 노트에 없는 일반 지식)', 'counter 는 계속 증가하는 누적값이라 그대로 보지 않고 변화율을 봅니다. 구간은 `[5m]` 처럼 씁니다.', NULL, NULL, '[]', 'fill', '["rate", "sum", "increase", "5m", "1h"]', NULL, '`rate()` 는 구간 동안의 **초당 평균 증가율**, `increase()` 는 구간 동안의 **총 증가량**입니다. `sum` 은 시계열을 합치는 집계라 단독으로는 변화율을 구하지 못합니다. counter 는 재시작하면 0 으로 돌아가는데 rate 가 이를 보정해 줍니다.', '[0, 3]', '{0}(http_requests_total{job="api"}[{1}])', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 2, 'PromQL: 상태 코드별로 합치기', '앞의 초당 요청 수를 **상태 코드(`code`)별로 합산**하려고 합니다. 빈칸을 채우세요.', '레이블 값별로 묶어 합치는 집계는 `sum by (레이블)` 입니다.', NULL, NULL, '[]', 'fill', '["code", "job", "instance", "pod"]', NULL, '`by` 에 적은 레이블 값별로 시계열을 묶어 합칩니다. `instance` 로 묶으면 서버별, `job` 으로 묶으면 수집 묶음별 합계가 됩니다. 레이블이 너무 다양하면(카디널리티) 시계열이 폭증하므로 `by` 를 신중히 고릅니다.', '[0]', 'sum by ({0}) (rate(http_requests_total[5m]))', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 3, 'LogQL: error 가 든 로그만 찾기', 'Loki 에서 레이블 `app="api"` 인 로그 중 **`error` 라는 글자가 들어 있는 줄만** 찾는 쿼리입니다. 빈칸을 채우세요. (※ LogQL 문법은 노트에 없는 일반 지식)', '먼저 레이블로 로그 스트림을 좁힌 뒤, 그 안에서 글자를 grep 하듯 거릅니다.', NULL, NULL, '[]', 'fill', '["|=", "!=", "=~", "=="]', NULL, '`|=` 는 "포함", `!=` 는 "포함하지 않음", `=~` 는 정규식 일치(필터 파이프에서는 `|~`)입니다. Loki 는 레이블만 인덱싱하고 본문은 이렇게 스트림 안에서 grep 하므로, 레이블로 먼저 좁히는 것이 성능의 핵심입니다.', '[0]', '{app="api"} {0} "error"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 4, '메트릭 → 로그 → 트레이스로 좁혀 가는 순서 놓기', '대시보드에서 응답 지연 경보가 울렸습니다. 원인을 좁혀 가는 흐름을 **앞에서 뒤**로 놓으세요.', '전체 상태(메트릭)에서 시작해 특정 사건(로그), 요청 하나의 경로(트레이스)로 내려갑니다.', NULL, NULL, '[]', 'order', '["trace id 로 느린 요청이 지난 서비스 구간을 보고 병목 서비스를 확정한다", "메트릭 대시보드에서 어느 서비스·언제부터 느려졌는지 범위를 확인한다", "그 시간대·서비스의 로그에서 오류·타임아웃 메시지를 찾아 요청의 trace id 를 얻는다"]', NULL, '**메트릭(전체 상태, "지금 전반적으로 어떤가") → 로그(그 순간 무슨 일이 있었나) → 트레이스(요청 하나가 어디서 느려졌나)** 입니다. 세 신호를 같은 trace id 와 레이블로 연결해 두면 이 이동이 쉬워진다는 것이 OpenTelemetry 가 신호를 한 틀로 묶는 이유입니다.', '[1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 5, 'counter 와 gauge', '"현재 접속자 수", "메모리 사용량"처럼 **오르내리는 값**의 메트릭 타입과, "누적 요청 수"처럼 **계속 증가하는 값**의 타입은 각각 무엇일까요? (※ 일반 지식)', '하나는 순간 값, 하나는 누적 값입니다.', NULL, NULL, '[]', 'choice', '["둘 다 counter 이다", "오르내리는 값이 counter, 누적 값이 gauge 이다", "오르내리는 값은 gauge, 누적해서 증가하는 값은 counter 이다 (counter 는 `rate()` 로 변화율을 본다)", "둘 다 histogram 이다"]', 2, 'gauge 는 현재 값을 그대로 그래프로 보고, counter 는 그대로 보면 계속 올라가기만 해서 의미가 없으므로 rate 로 변화율을 봅니다. histogram 은 응답 시간 분포(분위수) 같은 용도입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 6, '레이블에 user_id 를 넣으면', '메트릭 레이블에 **`user_id`** 처럼 값의 종류가 아주 많은 항목을 넣으면 어떤 일이 생길까요?', '레이블 조합 하나마다 별도의 시계열이 생깁니다.', NULL, NULL, '[]', 'choice', '["레이블 값 조합마다 시계열이 생겨 **시계열 수가 폭증**하고, 메모리·디스크·쿼리 비용이 커진다 (카디널리티 문제)", "시계열이 줄어 저장 공간이 절약된다", "아무 영향이 없다", "Prometheus 가 자동으로 값을 합쳐 준다"]', 0, '이름과 레이블 집합이 시계열을 식별하므로 사용자 ID, 요청 ID, 전체 URL 같은 값은 레이블에 넣지 않습니다. 그런 정보는 로그나 트레이스로 남기는 것이 맞습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 7, '메트릭 텍스트 형식 읽고 합산하기', '`/tmp/lab/metrics.txt` 는 Prometheus 가 `/metrics` 로 노출하는 텍스트입니다. **상태 코드가 5xx 인 요청의 합계**(줄 끝의 값)를 계산해 `/tmp/lab/errors.txt` 에 숫자만 저장하세요.', '형식은 `이름{레이블,...} 값` 입니다. 5xx 줄은 `code="5` 로 시작하는 줄이고, 값은 공백으로 나눈 두 번째 열입니다. `awk ''/code="5/ { s += $2 } END { print s }''`\\n확인: `cat /tmp/lab/metrics.txt`', 'awk ''/code="5/ { s += $2 } END { print s }'' /tmp/lab/metrics.txt > /tmp/lab/errors.txt
cat /tmp/lab/errors.txt

# 레이블이 다르면 별개의 시계열이다. 여기서는 5xx 시계열의 값을 합쳤다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''# HELP http_requests_total Total requests\\\\n# TYPE http_requests_total counter\\\\nhttp_requests_total{code=\\"200\\",method=\\"GET\\"} 1027\\\\nhttp_requests_total{code=\\"404\\",method=\\"GET\\"} 21\\\\nhttp_requests_total{code=\\"500\\",method=\\"GET\\"} 12\\\\nhttp_requests_total{code=\\"503\\",method=\\"POST\\"} 3\\\\n'' > /tmp/lab/metrics.txt"]', '["sh", "-c", "( [ -s /tmp/lab/errors.txt ] ) && ( [ \\"$(cat /tmp/lab/errors.txt)\\" = 15 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/errors.txt ]"]}, {"label": "5xx 합계가 15 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lab/errors.txt)\\" = 15 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 8, '카디널리티 직접 세어 보기', '`/tmp/lab/series.txt` 의 각 줄은 메트릭 하나입니다. 레이블 `user_id` 의 **서로 다른 값의 개수**를 세어 `/tmp/lab/user_count.txt` 에 숫자만 저장하세요. (이 값이 곧 사용자 ID 때문에 생기는 시계열의 개수입니다)', '`grep -o` 로 레이블 부분만 뽑고 `sort -u` 로 중복을 없앤 뒤 `wc -l` 로 셉니다.\\n확인: `cat /tmp/lab/series.txt`', 'grep -o ''user_id="[^"]*"'' /tmp/lab/series.txt | sort -u | wc -l > /tmp/lab/user_count.txt
cat /tmp/lab/user_count.txt

# 사용자가 100만이면 시계열도 100만 — 이런 값은 레이블이 아니라 로그로 남긴다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''login_total{user_id=\\"u1\\"} 3\\\\nlogin_total{user_id=\\"u2\\"} 1\\\\nlogin_total{user_id=\\"u3\\"} 5\\\\nlogin_total{user_id=\\"u2\\"} 2\\\\nlogin_total{user_id=\\"u4\\"} 7\\\\nlogin_total{user_id=\\"u1\\"} 9\\\\n'' > /tmp/lab/series.txt"]', '["sh", "-c", "( [ -s /tmp/lab/user_count.txt ] ) && ( [ \\"$(tr -d \\"[:space:]\\" < /tmp/lab/user_count.txt)\\" = 4 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/user_count.txt ]"]}, {"label": "서로 다른 user_id 가 4개다", "cmd": ["sh", "-c", "[ \\"$(tr -d \\"[:space:]\\" < /tmp/lab/user_count.txt)\\" = 4 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 90, 9, '뒤집힌 알림 조건 고치기', '`/tmp/lab/rules.yml` 의 알림 규칙 `InstanceDown` 은 **서버가 내려갔을 때** 울려야 하는데, 조건이 `up == 1`(살아 있을 때)로 **뒤집혀** 있습니다. 서버가 죽었을 때 울리도록 조건을 고치세요. (다른 줄은 그대로)', 'Prometheus 의 `up` 은 scrape 가 성공하면 1, 실패하면 0 입니다. `grep expr` 로 현재 조건을 보고 `sed -i` 로 고치세요.\\n확인: `grep expr /tmp/lab/rules.yml`', 'grep expr /tmp/lab/rules.yml
sed -i ''s/up == 1/up == 0/'' /tmp/lab/rules.yml
grep expr /tmp/lab/rules.yml

# up : 수집 성공 1, 실패 0. 알림은 이상 상태를 조건으로 건다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''groups:\\\\n  - name: availability\\\\n    rules:\\\\n      - alert: InstanceDown\\\\n        expr: up == 1\\\\n        for: 5m\\\\n        labels:\\\\n          severity: critical\\\\n'' > /tmp/lab/rules.yml"]', '["sh", "-c", "( grep -q \\"expr: up == 0\\" /tmp/lab/rules.yml ) && ( grep -q \\"for: 5m\\" /tmp/lab/rules.yml && grep -q \\"severity: critical\\" /tmp/lab/rules.yml ) && ( grep -q \\"alert: InstanceDown\\" /tmp/lab/rules.yml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "조건이 up == 0 이다", "cmd": ["sh", "-c", "grep -q \\"expr: up == 0\\" /tmp/lab/rules.yml"]}, {"label": "for 와 severity 는 그대로다", "cmd": ["sh", "-c", "grep -q \\"for: 5m\\" /tmp/lab/rules.yml && grep -q \\"severity: critical\\" /tmp/lab/rules.yml"]}, {"label": "알림 이름도 그대로다", "cmd": ["sh", "-c", "grep -q \\"alert: InstanceDown\\" /tmp/lab/rules.yml"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 90 AND order_index = 9);
