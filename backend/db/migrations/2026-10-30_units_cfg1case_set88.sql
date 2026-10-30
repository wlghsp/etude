-- 리눅스 세트 88. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set88.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 25, '미들웨어', '설정 읽기·고치기', 90 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 25);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 88, '설정 파일 읽고 고치기: Kafka, Prometheus, Elasticsearch', 'Kafka 의 리스너 설정, Prometheus 의 scrape 설정, Elasticsearch 의 ILM 정책 JSON 을 빈칸으로 채워 읽고, 설정을 안전하게 바꾸는 순서를 익힌 뒤, 샌드박스에서 설정 파일의 오류를 직접 찾아 고칩니다. 객관식뿐 아니라 빈칸, 순서, 직접 수정으로 구성했습니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 88);
UPDATE quest_set SET display_order = 590, unit_id = (SELECT id FROM unit WHERE id = 25), icon = '🛠️' WHERE id = 88;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 1, 'Kafka 리스너 설정 읽고 채우기', 'Kafka 브로커가 **모든 네트워크 인터페이스에서 접속을 받고**, 클라이언트에게는 **자신이 접근 가능한 이름**으로 다시 연결하라고 알려 주는 설정입니다. 빈칸을 채우세요.', '`listeners` 는 브로커가 **바인드(listen)하는 주소**, `advertised.listeners` 는 클라이언트에게 **알려 줄 주소**입니다.', NULL, NULL, '[]', 'fill', '["0.0.0.0", "broker1.example.com", "localhost", "127.0.0.1"]', NULL, '`0.0.0.0` 은 "모든 인터페이스에서 받는다"는 뜻이라 listen 주소로는 맞지만, 클라이언트에게 알려 줄(advertised) 주소로는 쓸 수 없습니다. 클라이언트는 그 주소로 다시 접속하기 때문에 **클라이언트가 닿을 수 있는 이름**(`broker1.example.com`)이어야 합니다. `localhost` 를 알리면 클라이언트는 자기 자신에게 접속하려고 합니다.', '[0, 1]', 'listeners=INTERNAL://{0}:9092
advertised.listeners=INTERNAL://{1}:9092', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 2, 'Prometheus scrape 설정 채우기', '`app.example.com` 의 9100 포트에서 `/metrics` 경로로 노출하는 메트릭을 **`node`** 라는 job 이름으로 수집하려고 합니다. 빈칸을 채우세요.', '`job_name` 은 수집 묶음의 이름, `metrics_path` 는 scrape 할 경로, `targets` 는 대상 `주소:포트` 입니다.', NULL, NULL, '[]', 'fill', '["node", "/metrics", "/federate", "app.example.com", "kafka"]', NULL, 'Prometheus 는 pull 방식이라 대상의 `/metrics`(기본값)를 주기적으로 긁어 옵니다. `/federate` 는 다른 Prometheus 에서 메트릭을 가져올 때 쓰는 별도 경로입니다.', '[0, 1, 3]', 'scrape_configs:
  - job_name: ''{0}''
    metrics_path: {1}
    static_configs:
      - targets: [''{2}:9100'']', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 3, 'Prometheus 설정을 안전하게 바꾸는 순서 놓기', '운영 중인 Prometheus 의 `prometheus.yml` 에 새 job 을 추가할 때 안전한 순서를 **앞에서 뒤**로 놓으세요.', '고치고, 문법을 검사하고, 적용하고, 확인합니다.', NULL, NULL, '[]', 'order', '["Prometheus 를 reload 해 새 설정을 적용한다", "`promtool check config` 로 설정 문법을 검사한다", "`prometheus.yml` 을 백업하고 새 job 을 추가한다", "targets 화면에서 새 job 이 UP 인지 확인한다"]', NULL, '**백업·수정 → 문법 검사 → reload → targets 확인** 입니다. 검사 없이 reload 하면 잘못된 설정이 적용 시도되어 서버가 설정을 거부하거나 기동에 실패할 수 있고, 적용한 뒤에는 실제로 수집되는지(UP)를 눈으로 확인해야 끝난 것입니다.', '[2, 1, 0, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 4, 'Elasticsearch ILM 정책 채우기', 'hot 단계에서 **50GB 를 넘거나 1일이 지나면 새 인덱스로 rollover** 하고, **365일이 지나면 삭제**하는 ILM 정책의 일부입니다. 빈칸을 채우세요.', 'rollover 는 크기(`max_size`)와 나이(`max_age`) 중 먼저 오는 조건이고, 삭제는 `delete` 단계의 `min_age` 입니다.', NULL, NULL, '[]', 'fill', '["50gb", "1d", "365d", "10mb", "1y"]', NULL, '`max_size` 와 `max_age` 중 **하나라도** 먼저 만족하면 rollover 합니다. 시간 단위는 `d`(일)를 쓰고 `1y` 같은 단위는 지원하지 않습니다. 인덱스를 날짜·크기로 쪼개 두어야 오래된 것을 통째로 삭제할 수 있습니다.', '[0, 1, 2]', '"hot": { "actions": { "rollover": { "max_size": "{0}", "max_age": "{1}" } } },
"delete": { "min_age": "{2}", "actions": { "delete": {} } }', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 5, 'Xms 와 Xmx 를 같게 하는 이유', 'Elasticsearch 의 `jvm.options` 에서 **`-Xms` 와 `-Xmx` 를 같은 값**으로 두라고 권장하는 이유는 무엇일까요?', '힙이 실행 중에 크기를 바꾸면 어떤 비용이 있을까요?', NULL, NULL, '[]', 'choice', '["두 값을 다르게 하면 JVM 이 시작되지 않기 때문이다", "메모리를 아낄 수 있기 때문이다", "실행 중에 힙 크기를 늘리고 줄이는 **재조정 비용과 지연**을 없애고 시작부터 필요한 메모리를 확보하기 위해서이다", "두 값은 서로 다른 설정이라 같아도 상관없다"]', 2, '`-Xms` 는 시작 힙, `-Xmx` 는 최대 힙입니다. 같게 두면 힙 리사이즈가 없어 GC 지연이 예측 가능합니다. 힙은 보통 물리 메모리의 절반 이하로 잡고, 나머지는 OS 파일 캐시가 쓰게 둡니다. (컨테이너라면 limit 보다 여유 있게 잡아야 OOMKilled 를 피합니다.)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 6, '유효한 설정만 골라 보기', '설정 파일에는 `#` 로 시작하는 주석과 빈 줄이 많아서 **실제 적용되는 줄만** 보고 싶습니다. 가장 알맞은 방법은 무엇일까요?', '주석 줄과 빈 줄을 제외합니다.', NULL, NULL, '[]', 'choice', '["`grep \\"#\\" 파일`", "`cat 파일 | wc -l`", "`ls -l 파일`", "`grep -vE \\"^[[:space:]]*(#|$)\\" 파일` (주석과 빈 줄을 제외한다)"]', 3, '`grep -v` 는 패턴과 맞는 줄을 **뺀 나머지**를 보여 줍니다. 앞서 배운 grep 옵션의 대표적인 실무 활용입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 7, '잘못된 advertised 주소 고치기', '`/tmp/lab/server.properties` 의 `advertised.listeners` 가 **`0.0.0.0`** 으로 되어 있어서 클라이언트가 다시 연결하지 못합니다. 호스트 부분을 **`broker1.example.com`** 으로 고치세요. (다른 줄은 그대로 둡니다)', '`sed -i` 로 한 줄만 바꿀 수 있습니다. 바꾸기 전에 `grep advertised /tmp/lab/server.properties` 로 현재 값을 확인하세요.', 'grep advertised /tmp/lab/server.properties
sed -i ''/^advertised.listeners=/s/0.0.0.0/broker1.example.com/'' /tmp/lab/server.properties
grep advertised /tmp/lab/server.properties

# advertised 주소는 클라이언트가 접속 가능한 이름이어야 한다 (0.0.0.0 은 listen 용)', '["sh", "-c", "mkdir -p /tmp/lab && printf ''broker.id=1\\\\nlisteners=INTERNAL://0.0.0.0:9092\\\\nadvertised.listeners=INTERNAL://0.0.0.0:9092\\\\nlog.retention.hours=168\\\\n'' > /tmp/lab/server.properties"]', '["sh", "-c", "( grep -qx \\"advertised.listeners=INTERNAL://broker1.example.com:9092\\" /tmp/lab/server.properties ) && ( grep -qx \\"listeners=INTERNAL://0.0.0.0:9092\\" /tmp/lab/server.properties ) && ( grep -qx \\"broker.id=1\\" /tmp/lab/server.properties && grep -qx \\"log.retention.hours=168\\" /tmp/lab/server.properties )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "advertised.listeners 가 broker1.example.com 이다", "cmd": ["sh", "-c", "grep -qx \\"advertised.listeners=INTERNAL://broker1.example.com:9092\\" /tmp/lab/server.properties"]}, {"label": "listeners(바인드 주소)는 그대로 0.0.0.0 이다", "cmd": ["sh", "-c", "grep -qx \\"listeners=INTERNAL://0.0.0.0:9092\\" /tmp/lab/server.properties"]}, {"label": "다른 줄은 그대로다", "cmd": ["sh", "-c", "grep -qx \\"broker.id=1\\" /tmp/lab/server.properties && grep -qx \\"log.retention.hours=168\\" /tmp/lab/server.properties"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 8, '로그 보관 기간 바꾸기', 'Kafka 의 로그 보관 기간이 **7일(168시간)** 입니다. `/tmp/lab/server.properties` 에서 이를 **30일(720시간)** 로 바꾸세요. 설정 이름은 파일에서 직접 찾으세요.', '먼저 `grep retention /tmp/lab/server.properties` 로 보관 기간과 관련된 줄을 찾습니다. 30일 × 24시간 = 720 입니다.', 'grep retention /tmp/lab/server.properties
sed -i ''s/^log.retention.hours=.*/log.retention.hours=720/'' /tmp/lab/server.properties
grep retention /tmp/lab/server.properties

# 값을 바꾼 뒤에는 브로커를 순차 재시작해 적용한다 (한꺼번에 재시작 금지)', '["sh", "-c", "mkdir -p /tmp/lab && printf ''broker.id=1\\\\nlog.retention.hours=168\\\\nlog.segment.bytes=1073741824\\\\n'' > /tmp/lab/server.properties"]', '["sh", "-c", "( grep -qx \\"log.retention.hours=720\\" /tmp/lab/server.properties ) && ( grep -qx \\"broker.id=1\\" /tmp/lab/server.properties && grep -qx \\"log.segment.bytes=1073741824\\" /tmp/lab/server.properties )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "보관 기간이 720 시간이다", "cmd": ["sh", "-c", "grep -qx \\"log.retention.hours=720\\" /tmp/lab/server.properties"]}, {"label": "다른 설정은 그대로다", "cmd": ["sh", "-c", "grep -qx \\"broker.id=1\\" /tmp/lab/server.properties && grep -qx \\"log.segment.bytes=1073741824\\" /tmp/lab/server.properties"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 9, '힙 크기를 같게 맞추기', '`/tmp/lab/jvm.options` 의 힙이 `-Xms512m`, `-Xmx2g` 로 **서로 다릅니다.** 두 값을 모두 **`2g`** 로 맞추세요. (다른 줄은 그대로)', '`sed -i` 로 `-Xms` 줄만 바꾸면 됩니다. 시작 힙과 최대 힙을 같게 두는 이유는 앞 문제에서 배웠습니다.', 'grep -E ''^-Xm[sx]'' /tmp/lab/jvm.options
sed -i ''s/^-Xms.*/-Xms2g/'' /tmp/lab/jvm.options
grep -E ''^-Xm[sx]'' /tmp/lab/jvm.options

# Xms == Xmx : 힙 리사이즈 비용을 없앤다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''## heap\\\\n-Xms512m\\\\n-Xmx2g\\\\n-XX:+UseG1GC\\\\n'' > /tmp/lab/jvm.options"]', '["sh", "-c", "( grep -qx -- \\"-Xms2g\\" /tmp/lab/jvm.options ) && ( grep -qx -- \\"-Xmx2g\\" /tmp/lab/jvm.options ) && ( grep -qx -- \\"-XX:+UseG1GC\\" /tmp/lab/jvm.options )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "-Xms 가 2g 이다", "cmd": ["sh", "-c", "grep -qx -- \\"-Xms2g\\" /tmp/lab/jvm.options"]}, {"label": "-Xmx 가 2g 이다", "cmd": ["sh", "-c", "grep -qx -- \\"-Xmx2g\\" /tmp/lab/jvm.options"]}, {"label": "다른 줄은 그대로다", "cmd": ["sh", "-c", "grep -qx -- \\"-XX:+UseG1GC\\" /tmp/lab/jvm.options"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 10, '새 scrape job 추가하기', '`/tmp/lab/prometheus.yml` 에는 job `prometheus` 하나만 있습니다. **job 이름 `node`, 대상 `app.example.com:9100`** 인 scrape job 을 **파일 끝에 추가**하세요. (기존 내용은 그대로 둡니다)', '`cat >> 파일 <<EOF` 로 끝에 붙입니다. YAML 은 **들여쓰기**가 중요하니 기존 job 의 모양을 `cat` 으로 보고 같은 깊이로 맞추세요.', 'cat >> /tmp/lab/prometheus.yml <<''EOF''
  - job_name: ''node''
    static_configs:
      - targets: [''app.example.com:9100'']
EOF
cat /tmp/lab/prometheus.yml

# 적용 전에는 promtool check config 로 문법을 검사한다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''scrape_configs:\\\\n  - job_name: \\"prometheus\\"\\\\n    static_configs:\\\\n      - targets: [\\"localhost:9090\\"]\\\\n'' > /tmp/lab/prometheus.yml"]', '["sh", "-c", "( grep -q \\"job_name: \\\\\\"prometheus\\\\\\"\\" /tmp/lab/prometheus.yml && grep -q \\"localhost:9090\\" /tmp/lab/prometheus.yml ) && ( grep -qE \\"job_name: .node.\\" /tmp/lab/prometheus.yml ) && ( grep -q \\"app.example.com:9100\\" /tmp/lab/prometheus.yml ) && ( [ \\"$(grep -c job_name /tmp/lab/prometheus.yml)\\" -eq 2 ] ) && ( [ \\"$(grep -cE \\"^  - job_name\\" /tmp/lab/prometheus.yml)\\" -eq 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "기존 prometheus job 이 그대로 있다", "cmd": ["sh", "-c", "grep -q \\"job_name: \\\\\\"prometheus\\\\\\"\\" /tmp/lab/prometheus.yml && grep -q \\"localhost:9090\\" /tmp/lab/prometheus.yml"]}, {"label": "node job 이 추가되었다", "cmd": ["sh", "-c", "grep -qE \\"job_name: .node.\\" /tmp/lab/prometheus.yml"]}, {"label": "대상이 app.example.com:9100 이다", "cmd": ["sh", "-c", "grep -q \\"app.example.com:9100\\" /tmp/lab/prometheus.yml"]}, {"label": "job 이 정확히 2개다", "cmd": ["sh", "-c", "[ \\"$(grep -c job_name /tmp/lab/prometheus.yml)\\" -eq 2 ]"]}, {"label": "새 job 이 scrape_configs 목록 안에 같은 들여쓰기로 들어갔다", "cmd": ["sh", "-c", "[ \\"$(grep -cE \\"^  - job_name\\" /tmp/lab/prometheus.yml)\\" -eq 2 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 88, 11, '유효한 설정만 뽑아 보기', '`/tmp/lab/app.conf` 에는 주석(`#`)과 빈 줄이 섞여 있습니다. **실제로 적용되는 줄만** `/tmp/lab/active.txt` 에 저장하세요.', '`grep -v` 와 정규식으로 주석 줄과 빈 줄을 제외합니다. 줄 앞에 공백이 있는 주석도 고려하세요.\\n확인: `cat /tmp/lab/active.txt`', 'grep -vE ''^[[:space:]]*(#|$)'' /tmp/lab/app.conf > /tmp/lab/active.txt
cat /tmp/lab/active.txt

# -v : 패턴과 맞는 줄을 제외한 나머지', '["sh", "-c", "mkdir -p /tmp/lab && printf ''# main config\\\\nport=8080\\\\n\\\\n  # indented comment\\\\ndebug=false\\\\n\\\\nhost=0.0.0.0\\\\n'' > /tmp/lab/app.conf"]', '["sh", "-c", "( [ -s /tmp/lab/active.txt ] ) && ( [ \\"$(cat /tmp/lab/active.txt)\\" = \\"port=8080\\ndebug=false\\nhost=0.0.0.0\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/active.txt ]"]}, {"label": "설정 줄 3개만 남았다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lab/active.txt)\\" = \\"port=8080\\ndebug=false\\nhost=0.0.0.0\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 88 AND order_index = 11);
