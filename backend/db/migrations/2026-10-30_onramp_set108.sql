-- 입문 세트 108. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_friendly_audit.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 108, 'k8s 통신 입문: Pod IP, Service, 이름', '통신 방법 익히기(37) 전에 가볍게 보는 입문입니다. Pod 마다 IP 가 있다는 것, IP 가 바뀌는 이유, 그래서 Service 가 필요한 이유, 이름으로 접속하는 길, 레이블과 selector, port 와 targetPort, 다른 네임스페이스 이름, 외부 접속 방식을 쉬운 문제로 익힙니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 108);
UPDATE quest_set SET display_order = 283, unit_id = (SELECT id FROM unit WHERE id = 8), icon = '🔗' WHERE id = 108;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 1, 'Pod 는 각자 주소를 가진다', '쿠버네티스에서 Pod 는 저마다 자기 ___ 를 가지고, 같은 클러스터의 다른 Pod 가 그것으로 접속할 수 있습니다.', '컴퓨터 네트워크의 숫자 주소예요.', NULL, NULL, '[]', 'fill', '["IP 주소", "비밀번호", "디스크", "이메일"]', NULL, '맞아요! Pod 마다 클러스터 안에서 통하는 IP 가 하나씩 있어요. 천천히 한 걸음씩 가 봐요.', '[0]', 'Pod 는 각자 {0} 를 가진다', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 2, 'Pod 를 다시 만들면?', 'Pod 가 죽어서 새로 만들어지면 IP 는 어떻게 될까요?', '새로 만들어진 Pod 는 새 주민이에요.', NULL, NULL, '[]', 'choice', '["항상 같은 IP 를 유지한다", "새 Pod 는 **다른 IP** 를 받는다", "IP 가 없어진다", "노드의 IP 를 쓴다"]', 1, '그래서 Pod IP 를 직접 쓰면 위험해요. IP 가 바뀌면 접속이 끊기니까요. 이걸 해결해 주는 것이 다음 문제의 Service 예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 3, 'Service 가 하는 일', '바뀌지 않는 대표 주소(이름)를 주고, 뒤에서 알맞은 Pod 로 요청을 나눠 주는 것은 무엇일까요?', '"서비스 창구"를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["ConfigMap", "Namespace", "Volume", "Service"]', 3, '맞아요! Service 는 바뀌지 않는 이름과 IP 를 주고, 그 뒤의 Pod 들로 요청을 나눠요. Pod 가 바뀌어도 접속은 유지됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 4, 'Service 이름으로 접속하기', '같은 네임스페이스에서 Service `web` 에 접속하려면 `curl http://___` 처럼 **Service 이름**을 씁니다.', 'Pod IP 가 아니라 이름이에요.', NULL, NULL, '[]', 'fill', '["web", "web-1", "10.1.2.3", "localhost"]', NULL, '같은 네임스페이스라면 이름만 써도 돼요. 클러스터 DNS 가 `web` 을 Service 의 IP 로 바꿔 줍니다.', '[0]', 'curl http://{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 5, '요청이 가는 길', '클라이언트 Pod 가 `curl http://web` 을 했을 때 요청이 가는 길을 앞에서 뒤로 놓아 보세요.', '이름을 IP 로 바꾸고, Service 가 Pod 하나를 고릅니다.', NULL, NULL, '[]', 'order', '["Service 가 뒤의 Pod 중 하나로 요청을 전달한다", "클러스터 DNS 가 `web` 을 Service IP 로 바꿔 준다", "클라이언트가 `web` 이라는 이름으로 접속을 시도한다"]', NULL, '**이름으로 접속 → DNS 가 Service IP 로 변환 → Service 가 Pod 에 전달** 입니다. 어려워 보여도 "이름 → 대표 IP → Pod" 한 줄이에요.', '[2, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 6, 'Service 는 Pod 를 어떻게 찾을까?', 'Service 는 어떤 Pod 로 요청을 보낼지 무엇을 보고 정할까요?', '이름표(스티커)를 붙여 구분해요.', NULL, NULL, '[]', 'choice', '["Pod 의 IP 앞자리", "Pod 를 만든 시각", "Pod 의 **레이블(label)** 과 Service 의 `selector` 가 일치하는지", "Pod 의 CPU 사용량"]', 2, '정확해요! Service 의 `selector: app=web` 은 "레이블이 app=web 인 Pod 로 보내라"는 뜻이에요. 레이블이 틀리면 연결이 안 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 7, 'port 와 targetPort', 'Service 의 `port` 는 **Service 가 받는 포트**, `targetPort` 는 **Pod 컨테이너의 포트**입니다. 웹 사용자는 `80` 으로 접속하고 컨테이너는 `8080` 에서 듣습니다. 빈칸을 채워 보세요.', '받는 쪽이 port(80), 보내는 쪽 목적지가 targetPort(8080)예요.', NULL, NULL, '[]', 'fill', '["80", "8080", "443", "3306"]', NULL, '`port` 로 들어온 요청이 `targetPort` 로 전달돼요. 둘이 달라도 괜찮고, targetPort 가 컨테이너가 실제로 듣는 포트와 같아야 합니다.', '[0, 1]', 'port: {0}
targetPort: {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 8, '다른 네임스페이스의 Service', '`dev` 네임스페이스의 Pod 가 `prod` 네임스페이스의 Service `db` 에 접속하려면 어떤 이름을 쓸까요?', '이름 뒤에 네임스페이스를 점으로 붙여요.', NULL, NULL, '[]', 'choice', '["`db` 만", "`db.prod`", "`prod/db`", "`db-prod-dev`"]', 1, '좋아요! `서비스이름.네임스페이스` 로 부르면 다른 네임스페이스도 찾아가요. 같은 네임스페이스는 이름만으로 충분해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 9, '클러스터 밖에서 접속하려면?', '기본 Service 타입(ClusterIP)은 클러스터 **안**에서만 접속됩니다. 밖에서 접속하게 하려면 무엇을 쓸까요?', '노드 포트를 여는 방법, 외부 로드밸런서, Ingress 등이 있어요.', NULL, NULL, '[]', 'choice', '["더 큰 Pod", "더 많은 ConfigMap", "네임스페이스 삭제", "NodePort, LoadBalancer, Ingress 같은 외부 노출 방식"]', 3, '맞아요! 밖에 열려면 별도 방식이 필요해요. 필요한 만큼만 여는 것이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 108, 10, 'Service 로 접속되게 만드는 순서', 'Deployment 의 Pod 에 이름으로 접속되게 만드는 흐름을 놓아 보세요.', '먼저 Pod 가 있어야 하고, 그 다음 Service, 마지막으로 확인해요.', NULL, NULL, '[]', 'order', '["이름으로 접속(`curl http://web`)해 응답을 확인한다", "Pod 가 있는 Deployment 를 만든다 (레이블 `app=web`)", "`selector: app=web` 인 Service 를 만든다"]', NULL, '**Pod 만들기 → selector 가 같은 Service 만들기 → 이름으로 확인** 입니다. 순서대로 하나씩 하면 어렵지 않아요.', '[1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 108 AND order_index = 10);
