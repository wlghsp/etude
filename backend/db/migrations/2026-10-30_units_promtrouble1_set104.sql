-- 미들웨어 세트 104. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set104.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 104, 'Prometheus 문제 해결 상황집: 타깃 DOWN, 빈 쿼리, 알림 안 옴', 'Prometheus 로 감시하다 막혔을 때 원인을 찾는 법을 익힙니다. Targets 에러(connection refused, context deadline exceeded, 401)로 원인 가르기, 쿼리가 빈 결과일 때 레이블 확인, 로그에서 가장 흔한 수집 에러 찾기, promtool 오류 읽고 규칙 고치기, 알림이 라우트에 안 맞아 전달되지 않는 문제를 문제와 파일 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 104);
UPDATE quest_set SET display_order = 524, unit_id = (SELECT id FROM unit WHERE id = 18), icon = '🆘' WHERE id = 104;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 1, 'Prometheus 점검·반영 명령 채우기', '① 설정 파일의 문법을 **검사**하고, ② 알림 규칙 파일을 **검사**하고, ③ 서버를 재시작하지 않고 설정을 **다시 읽게** 하는 명령입니다. 빈칸을 채우세요.', '검사는 `promtool check 대상`, 다시 읽기는 `-/reload` 엔드포인트입니다.', NULL, NULL, '[]', 'fill', '["config", "rules", "reload", "healthy", "metrics"]', NULL, '`promtool check config` 는 설정을, `check rules` 는 규칙 파일을 검사합니다. 적용 전에 항상 먼저 실행합니다. `POST /-/reload` 는 `--web.enable-lifecycle` 옵션이 켜진 경우에 동작하며, 검사에 실패한 설정은 반영되지 않고 기존 설정이 유지됩니다.', '[0, 1, 2]', 'promtool check {0} prometheus.yml
promtool check {1} rules.yml
curl -X POST localhost:9090/-/{2}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 2, '쿼리 결과가 비어 있을 때 진단 순서', 'Grafana 패널이 "No data" 입니다. 원인을 좁혀 가는 흐름을 **앞에서 뒤**로 놓으세요.', '수집이 되는지 → 메트릭이 있는지 → 레이블이 맞는지 → 시간 범위 순서로 좁힙니다.', NULL, NULL, '[]', 'order', '["메트릭 이름만 단독으로 조회해 데이터가 있는지 본다", "쿼리의 레이블 셀렉터(`job`, `instance`)를 실제 레이블 값과 비교한다", "해당 job 의 `up` 이 1 인지, Targets 에 에러가 없는지 확인한다", "패널의 시간 범위와 수집 시점이 겹치는지 확인한다"]', NULL, '**up/Targets → 메트릭 이름 단독 조회 → 레이블 셀렉터 → 시간 범위** 입니다. 대부분은 수집 실패(up 0)이거나 레이블 오타입니다. 메트릭이 사라진 직후 몇 분 동안은 staleness 때문에 빈 결과가 나오기도 합니다.', '[2, 0, 1, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 3, 'Targets 에러: connection refused', 'Targets 화면의 Error 가 `Get "http://10.0.0.5:9100/metrics": dial tcp 10.0.0.5:9100: connect: connection refused` 입니다. 가장 알맞은 해석은 무엇일까요?', 'IP 에는 도달했지만 그 포트에서 받는 프로세스가 없습니다.', NULL, NULL, '[]', 'choice', '["방화벽이 패킷을 버리고 있다 (이 경우는 보통 timeout)", "인증 정보가 틀렸다", "그 주소의 포트에서 듣는 프로세스가 없다 — exporter 가 안 떠 있거나 포트·주소가 설정과 다르다", "Prometheus 의 디스크가 가득 찼다"]', 2, '`connection refused` 는 상대 서버가 즉시 거절한 것이라 "서버는 살아 있는데 그 포트는 닫혀 있음"을 뜻합니다. 서버에서 `ss -ltnp | grep 9100` 으로 실제 포트를 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 4, 'Targets 에러: context deadline exceeded', 'Error 가 `context deadline exceeded` 입니다. 가장 먼저 의심할 것은 무엇일까요?', '시간 안에 응답을 받지 못했습니다.', NULL, NULL, '[]', 'choice', '["규칙 파일이 없다", "메트릭 이름이 틀렸다", "레이블이 너무 많다", "`scrape_timeout` 안에 응답이 오지 않았다 — 방화벽이 패킷을 버리거나, 네트워크 경로 문제, exporter 가 너무 느린 경우"]', 3, '`refused`(즉시 거절)와 달리 `deadline exceeded` 는 **응답이 없어서** 기다리다 끝난 것입니다. 해당 서버에서 `curl -m 5 http://대상/metrics` 로 직접 확인해 경로 문제와 exporter 지연을 구분합니다. 수집 대상이 큰 경우 `scrape_timeout` 을 늘리기 전에 exporter 가 느린 이유를 먼저 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 5, 'Targets 에러: HTTP status 401', 'Error 가 `server returned HTTP status 401 Unauthorized` 입니다. 올바른 조치는 무엇일까요?', '연결은 됐는데 인증에서 막혔습니다.', NULL, NULL, '[]', 'choice', '["`scrape_interval` 을 줄인다", "해당 job 에 `basic_auth` 또는 `authorization`(bearer token) 설정을 넣는다. 자격 증명은 파일로 분리해 참조하고 권한을 제한한다", "job 이름을 바꾼다", "exporter 를 재설치한다"]', 1, '401/403 은 네트워크가 아니라 **인증·권한** 문제입니다. 비밀번호를 설정 파일에 직접 쓰기보다 `password_file`, `credentials_file` 로 분리하면 설정을 공유해도 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 6, '쿼리 결과가 비는 대표 원인', '`rate(http_requests_total{job="api-server"}[5m])` 가 빈 결과입니다. `http_requests_total` 단독 조회에서는 `job="api"` 로 데이터가 보입니다. 원인은 무엇일까요?', '셀렉터의 레이블 값을 실제 값과 비교해 보세요.', NULL, NULL, '[]', 'choice', '["rate 함수는 5분 구간을 쓸 수 없다", "Prometheus 가 꺼져 있다", "`job` 레이블 값이 실제(`api`)와 달라 일치하는 시계열이 없다. 레이블 값을 맞추면 해결된다", "카운터에는 rate 를 쓰면 안 된다"]', 2, '셀렉터가 맞는 시계열이 없으면 오류 없이 **조용히 빈 결과**가 나옵니다. 오타를 막으려면 Grafana 의 변수나 자동완성으로 값을 고르게 하고, 레이블 값 목록은 `label_values(...)` 로 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 7, '알림 규칙은 firing 인데 메신저에 안 올 때', 'Prometheus 의 Alerts 화면에서 알림이 `firing` 인데 담당자 메신저에는 아무것도 오지 않습니다. 다음에 볼 것으로 가장 알맞은 것은 무엇일까요?', 'Prometheus 의 역할은 전달 서버로 보내는 데까지입니다.', NULL, NULL, '[]', 'choice', '["Alertmanager 쪽을 본다 — 알림이 도착했는지, 적용 중인 silence 가 없는지, `route` 의 matchers 가 알림의 레이블과 맞아 수신자로 연결되는지", "알림 규칙의 이름을 바꾼다", "Prometheus 의 retention 을 늘린다", "exporter 를 재시작한다"]', 0, '"규칙 평가 → Alertmanager 도착 → 라우팅 → 수신자 → 메신저" 중 어디서 끊겼는지 단계별로 확인합니다. 흔한 원인: severity 레이블 값 불일치로 라우트에 매칭되지 않음, 만료되지 않은 silence, 수신자(webhook) 주소·토큰 오류입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 8, 'scrape 대상 포트 오타 고치기', '`/tmp/prometheus.yml` 의 job `node` 가 `localhost:9101` 을 수집하려 하지만 exporter 는 **다른 포트**에서 동작 중입니다(`connection refused`). 실제로 듣고 있는 포트를 찾아 `targets` 를 올바르게 고치세요.', '`ss -ltn` 으로 듣고 있는 포트를 확인하고(9100 대인지), 설정의 포트를 맞추세요.\\n확인: `curl -s localhost:포트`', 'ss -ltn | grep 91
sed -i ''s/9101/9100/'' /tmp/prometheus.yml
cat /tmp/prometheus.yml
curl -s localhost:9100

# connection refused: 설정에 적은 포트에서 듣는 프로세스가 없다', '["sh", "-c", "nohup etude-httpd 9100 NODE >/dev/null 2>&1 & sleep 1; printf ''%s\\\\n'' ''global:'' ''  scrape_interval: 15s'' ''scrape_configs:'' ''  - job_name: node'' ''    static_configs:'' ''      - targets: [\\"localhost:9101\\"]'' > /tmp/prometheus.yml"]', '["sh", "-c", "( grep -q ''localhost:9100'' /tmp/prometheus.yml ) && ( ! grep -q 9101 /tmp/prometheus.yml ) && ( curl -s localhost:9100 | grep -q NODE )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "targets 가 localhost:9100 이다", "cmd": ["sh", "-c", "grep -q ''localhost:9100'' /tmp/prometheus.yml"]}, {"label": "잘못된 포트 9101 이 없다", "cmd": ["sh", "-c", "! grep -q 9101 /tmp/prometheus.yml"]}, {"label": "그 포트에서 exporter 가 응답한다", "cmd": ["sh", "-c", "curl -s localhost:9100 | grep -q NODE"]}]', '[{"title": "Prometheus 공식 문서", "url": "https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 9, '로그에서 가장 흔한 수집 에러 찾기', '`/tmp/prom.log` 는 Prometheus 의 수집 경고 로그입니다. `err="..."` 값 중 **가장 자주 나온 에러 메시지**(따옴표 안의 내용만)를 **`/tmp/top.txt`** 에 저장하세요.', '`grep -o` 로 `err="…"` 부분만 뽑고 `sort | uniq -c | sort -rn` 으로 빈도를 셉니다. `sed` 로 따옴표 안 내용만 남기세요.\\n확인: `cat /tmp/prom.log`', 'cat /tmp/prom.log
grep -o ''err="[^"]*"'' /tmp/prom.log | sort | uniq -c | sort -rn | head -n 1 | sed ''s/.*err="\\(.*\\)"/\\1/'' > /tmp/top.txt
cat /tmp/top.txt

# 가장 흔한 에러부터 원인을 좁힌다', '["sh", "-c", "printf ''%s\\\\n'' ''level=warn target=http://10.0.0.5:9100/metrics err=\\"connection refused\\"'' ''level=warn target=http://10.0.0.6:9100/metrics err=\\"connection refused\\"'' ''level=warn target=http://10.0.0.7:9104/metrics err=\\"context deadline exceeded\\"'' ''level=warn target=http://10.0.0.5:9100/metrics err=\\"connection refused\\"'' ''level=warn target=http://10.0.0.8:8080/metrics err=\\"server returned HTTP status 401 Unauthorized\\"'' > /tmp/prom.log"]', '["sh", "-c", "( [ -s /tmp/top.txt ] ) && ( [ \\"$(cat /tmp/top.txt)\\" = \\"connection refused\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/top.txt ]"]}, {"label": "가장 흔한 에러가 connection refused 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/top.txt)\\" = \\"connection refused\\" ]"]}]', '[{"title": "Prometheus 공식 문서", "url": "https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 10, '레이블 오타로 비는 쿼리 고치기', '`/tmp/query.txt` 의 쿼리가 빈 결과를 냅니다. `/tmp/metrics.txt`(수집된 메트릭)에 실제로 있는 `job` 값을 확인하고, 쿼리의 `job` 값을 **맞게 고치세요.**', '`cat /tmp/metrics.txt` 에서 `http_requests_total` 의 `job="…"` 값을 찾아 쿼리와 비교하세요.\\n확인: `cat /tmp/query.txt`', 'cat /tmp/metrics.txt
cat /tmp/query.txt
sed -i ''s/api-server/api/'' /tmp/query.txt
cat /tmp/query.txt

# 셀렉터가 맞는 시계열이 없으면 오류 없이 빈 결과가 나온다', '["sh", "-c", "printf ''%s\\\\n'' ''http_requests_total{job=\\"api\\",code=\\"200\\"} 1027'' ''http_requests_total{job=\\"api\\",code=\\"500\\"} 3'' ''http_requests_total{job=\\"web\\",code=\\"200\\"} 88'' > /tmp/metrics.txt && printf ''%s\\\\n'' ''rate(http_requests_total{job=\\"api-server\\",code=\\"500\\"}[5m])'' > /tmp/query.txt"]', '["sh", "-c", "( grep -q ''job=\\"api\\"'' /tmp/query.txt ) && ( ! grep -q ''api-server'' /tmp/query.txt ) && ( grep -q ''rate(http_requests_total'' /tmp/query.txt && grep -q ''code=\\"500\\"'' /tmp/query.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "쿼리의 job 이 api 이다", "cmd": ["sh", "-c", "grep -q ''job=\\"api\\"'' /tmp/query.txt"]}, {"label": "잘못된 값이 없다", "cmd": ["sh", "-c", "! grep -q ''api-server'' /tmp/query.txt"]}, {"label": "나머지 쿼리는 그대로다", "cmd": ["sh", "-c", "grep -q ''rate(http_requests_total'' /tmp/query.txt && grep -q ''code=\\"500\\"'' /tmp/query.txt"]}]', '[{"title": "Prometheus 공식 문서", "url": "https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 11, '알림이 라우트에 안 맞을 때 고치기', '`/tmp/rules.yml` 의 알림은 `severity` 레이블이 **무엇인지** 확인하세요. `/tmp/alertmanager.yml` 의 라우트가 **다른 값**을 기다려서 이 알림이 `oncall` 에게 가지 못합니다. 라우트의 매처를 규칙의 `severity` 값에 **맞게** 고치세요.', '두 파일을 모두 `cat` 해서 `severity` 값을 비교하세요. 알림 쪽(rules)이 기준이고, 라우트(alertmanager)가 거기 맞춰야 합니다.', 'cat /tmp/rules.yml
cat /tmp/alertmanager.yml
sed -i ''s/severity="page"/severity="critical"/'' /tmp/alertmanager.yml
cat /tmp/alertmanager.yml

# 알림의 레이블 값과 라우트 matchers 가 일치해야 수신자로 간다', '["sh", "-c", "printf ''%s\\\\n'' ''groups:'' ''  - name: basic'' ''    rules:'' ''      - alert: InstanceDown'' ''        expr: up == 0'' ''        for: 5m'' ''        labels:'' ''          severity: critical'' > /tmp/rules.yml && printf ''%s\\\\n'' ''route:'' ''  receiver: team-mail'' ''  routes:'' ''    - matchers: [severity=\\"page\\"]'' ''      receiver: oncall'' ''receivers:'' ''  - name: team-mail'' ''  - name: oncall'' > /tmp/alertmanager.yml"]', '["sh", "-c", "( grep -q ''severity=\\"critical\\"'' /tmp/alertmanager.yml ) && ( ! grep -q ''severity=\\"page\\"'' /tmp/alertmanager.yml ) && ( grep -A1 ''severity=\\"critical\\"'' /tmp/alertmanager.yml | grep -q ''receiver: oncall'' ) && ( grep -qx ''          severity: critical'' /tmp/rules.yml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "라우트 매처가 critical 이다", "cmd": ["sh", "-c", "grep -q ''severity=\\"critical\\"'' /tmp/alertmanager.yml"]}, {"label": "page 매처가 없다", "cmd": ["sh", "-c", "! grep -q ''severity=\\"page\\"'' /tmp/alertmanager.yml"]}, {"label": "수신자 oncall 라우트가 유지된다", "cmd": ["sh", "-c", "grep -A1 ''severity=\\"critical\\"'' /tmp/alertmanager.yml | grep -q ''receiver: oncall''"]}, {"label": "규칙 파일은 그대로다", "cmd": ["sh", "-c", "grep -qx ''          severity: critical'' /tmp/rules.yml"]}]', '[{"title": "Prometheus 공식 문서", "url": "https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 104, 12, 'promtool 오류 메시지 읽고 규칙 고치기', '`/tmp/check.out` 은 `promtool check rules` 의 오류 출력입니다. 메시지를 읽고 `/tmp/rules.yml` 의 **문법 오류**를 고치세요. (`up` 이 0 인지 비교하는 규칙입니다)', '`cat /tmp/check.out` 에 몇 번째 줄에서 무엇이 잘못되었는지 나옵니다. PromQL 에서 "같다" 비교는 `==` 입니다.\\n확인: `cat -n /tmp/rules.yml`', 'cat /tmp/check.out
sed -i ''s/expr: up = 0/expr: up == 0/'' /tmp/rules.yml
cat -n /tmp/rules.yml

# PromQL 비교 연산자: ==, !=, >, <, >=, <=  (단일 = 는 문법 오류)', '["sh", "-c", "printf ''%s\\\\n'' ''groups:'' ''  - name: basic'' ''    rules:'' ''      - alert: InstanceDown'' ''        expr: up = 0'' ''        for: 5m'' ''        labels:'' ''          severity: critical'' > /tmp/rules.yml && printf ''%s\\\\n'' ''Checking /tmp/rules.yml'' ''  FAILED:'' ''/tmp/rules.yml: 5:15: group \\"basic\\", rule 1, \\"InstanceDown\\": could not parse expression: 1:4: parse error: unexpected \\"=\\"'' > /tmp/check.out"]', '["sh", "-c", "( grep -qx ''        expr: up == 0'' /tmp/rules.yml ) && ( grep -qx ''        for: 5m'' /tmp/rules.yml && grep -qx ''          severity: critical'' /tmp/rules.yml ) && ( ! grep -q ''expr: up = 0'' /tmp/rules.yml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "expr 가 up == 0 이다", "cmd": ["sh", "-c", "grep -qx ''        expr: up == 0'' /tmp/rules.yml"]}, {"label": "for 와 severity 가 그대로다", "cmd": ["sh", "-c", "grep -qx ''        for: 5m'' /tmp/rules.yml && grep -qx ''          severity: critical'' /tmp/rules.yml"]}, {"label": "단일 = 비교가 남아 있지 않다", "cmd": ["sh", "-c", "! grep -q ''expr: up = 0'' /tmp/rules.yml"]}]', '[{"title": "Prometheus 공식 문서", "url": "https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 104 AND order_index = 12);
