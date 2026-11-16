-- 퀴즈 세트 422. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_round_b.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 422, 'Service 와 Pod 의 DNS: 이름 형식, search 목록, Headless, SRV, hostname·subdomain', '쿠버네티스 DNS 이름을 읽습니다. my-svc.my-namespace.svc 형식, search 목록 확장으로 짧은 이름이 되는 이유, data.prod 같은 다른 네임스페이스 접근, Headless 의 Pod IP 응답, SRV 이름, Pod 의 A 레코드와 hostname·subdomain 을 봅니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 422);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 1, 'Service DNS 이름', 'Service 의 **DNS 이름 형식** 은 무엇일까요?', '이름.네임스페이스.svc 로 시작해요.', NULL, NULL, '[]', 'choice', '["my-namespace.my-svc.service.<클러스터 도메인>", "my-svc.pod.my-namespace.<클러스터 도메인>", "my-svc.my-namespace.svc.<클러스터 도메인>", "svc.my-svc.my-namespace.<클러스터 도메인>"]', 2, '쿠버네티스 문서는 Service 의 DNS 이름을 my-svc.my-namespace.svc.cluster-domain.example 형식으로 설명하며 cluster.local 은 예시 값입니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 2, '짧은 이름', '같은 네임스페이스의 Pod 에서 Service 를 **`data` 만으로** 찾을 수 있는 이유는 무엇일까요?', 'resolv.conf 와 관련 있어요.', NULL, NULL, '[]', 'choice', '["Service 가 모든 네임스페이스에 복제되기 때문", "resolv.conf 의 search 목록이 이름을 확장하기 때문", "kube-proxy 가 이름을 직접 IP 로 바꾸기 때문", "Pod 의 hostname 이 Service 이름이기 때문"]', 1, '문서는 네임스페이스를 지정하지 않은 쿼리가 Pod 의 네임스페이스로 제한되며 resolv.conf 의 search 목록이 data 를 data.test.svc.cluster.local 로 확장한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 3, '다른 네임스페이스', 'test 네임스페이스의 Pod 에서 prod 네임스페이스의 Service `data` 를 찾으려면 어떻게 할까요?', '네임스페이스를 붙여요.', NULL, NULL, '[]', 'choice', '["`data.prod` 처럼 네임스페이스를 명시한다", "`data` 만으로 찾을 수 있다", "`prod.data.test` 로 찾는다", "다른 네임스페이스의 Service 는 찾을 수 없다"]', 0, '문서는 test 네임스페이스의 Pod 에서 data 는 결과가 없고 data.prod 는 prod 의 Service 를 찾는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 4, 'Headless 응답', 'Headless Service(`clusterIP: None`)의 DNS 이름을 조회하면 무엇이 올까요?', '클러스터 IP 가 없어요.', NULL, NULL, '[]', 'choice', '["Service 의 클러스터 IP 하나", "노드의 IP 하나", "응답이 없다(NXDOMAIN)", "선택된 모든 Pod IP"]', 3, '문서는 Headless Service 의 A/AAAA 레코드가 Service 가 선택한 모든 Pod IP 집합으로 응답하며 클라이언트가 이 집합을 쓰거나 라운드로빈으로 선택해야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 5, 'SRV 레코드', '이름 있는 포트의 **SRV 레코드 이름** 형식으로 맞는 것은 무엇일까요?', '밑줄 두 개로 시작해요.', NULL, NULL, '[]', 'choice', '["my-svc._port-name._port-protocol.my-namespace.svc.<클러스터 도메인>", "_my-svc._my-namespace.port-name.<클러스터 도메인>", "_port-name._port-protocol.my-svc.my-namespace.svc.<클러스터 도메인>", "port-name.port-protocol.my-svc.<클러스터 도메인>"]', 2, '문서는 SRV 이름을 _port-name._port-protocol.my-svc.my-namespace.svc.cluster-domain.example 형식으로 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 6, 'Pod 의 A 레코드', 'IP 가 172.17.0.3 인 Pod 의 (구 kube-dns 형식) **A 레코드 이름** 은 무엇일까요?', 'IP 의 점을 하이픈으로 바꿔요.', NULL, NULL, '[]', 'choice', '["172.17.0.3.default.pod.cluster.local", "172-17-0-3.default.pod.cluster.local", "pod-172-17-0-3.default.svc.cluster.local", "3.0.17.172.default.pod.cluster.local"]', 1, '문서는 구 kube-dns 형식을 <pod-IPv4-address>.<namespace>.pod.<cluster-domain> 으로 설명하며 예로 172-17-0-3.default.pod.cluster.local 을 듭니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 7, 'hostname 기본값', 'Pod 의 **hostname 기본값** 은 무엇일까요?', '이름과 관련 있어요.', NULL, NULL, '[]', 'choice', '["metadata.name", "Pod 의 IP 주소", "노드의 호스트 이름", "컨테이너 이미지 이름"]', 0, '문서는 hostname 기본값이 Pod 의 metadata.name 이며 spec.hostname 을 지정하면 이 값이 우선한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 8, 'subdomain', '`spec.hostname: foo`, `spec.subdomain: bar`, 네임스페이스 `my-namespace` 일 때 **FQDN** 은 무엇일까요?', 'hostname.subdomain.네임스페이스.svc 예요.', NULL, NULL, '[]', 'choice', '["bar.foo.my-namespace.svc.cluster.local", "foo.my-namespace.bar.cluster.local", "foo.bar.my-namespace.pod.cluster.local", "foo.bar.my-namespace.svc.cluster.local"]', 3, '문서는 이 경우 FQDN 이 foo.bar.my-namespace.svc.cluster.local 이며 subdomain 과 같은 이름의 headless Service 가 같은 네임스페이스에 있어야 레코드가 반환된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 9, 'Ready 조건', 'Pod 이름의 DNS 레코드가 만들어지려면 **어떤 상태** 여야 할까요?', '준비되어야 해요.', NULL, NULL, '[]', 'choice', '["Pod 가 Running 이기만 하면 된다", "Pod 가 Pending 이어야 한다", "Ready 상태여야 한다", "상태와 무관하게 항상 만들어진다"]', 2, '문서는 Pod 가 Ready 상태여야 레코드가 생기며 Service 에 publishNotReadyAddresses=True 가 설정되어 있으면 예외라고 설명합니다.', NULL, NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 10, '다른 네임스페이스 이름', 'test 네임스페이스의 Pod 에서 prod 의 Service 를 찾는 이름입니다. 빈칸을 채우세요.', '네임스페이스 이름이에요.', NULL, NULL, '[]', 'fill', '["prod", "test", "svc", "local"]', NULL, 'data.prod 처럼 Service 이름 뒤에 대상 네임스페이스를 붙입니다.', '[0]', 'curl http://data.{0}', NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 11, 'Headless 설정', 'Service 를 **Headless** 로 만드는 `clusterIP` 값입니다. 빈칸을 채우세요.', '"없음" 이에요.', NULL, NULL, '[]', 'fill', '["None", "ClusterIP", "Headless", "0.0.0.0"]', NULL, 'clusterIP: None 인 Service 가 Headless Service 이며 DNS 가 선택된 Pod IP 집합으로 응답합니다.', '[0]', 'spec:
  clusterIP: {0}', NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 422, 12, '짧은 이름 해석', 'Pod 가 짧은 이름 `data` 로 Service 를 찾는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '요청 → 확장 → 응답이에요.', NULL, NULL, '[]', 'order', '["Pod 가 `data` 라는 이름을 조회한다", "resolv.conf 의 search 목록이 이름을 `data.test.svc.cluster.local` 로 확장한다", "DNS 가 그 Service 의 클러스터 IP 로 응답한다"]', NULL, '문서의 search 목록 확장과 Service A 레코드 설명을 이은 일반 절차입니다.', '[0, 1, 2]', NULL, NULL, '[{"title": "Service 와 Pod 의 DNS", "url": "https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 422 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 291 WHERE id = 23;
UPDATE quest_set SET display_order = 292 WHERE id = 31;
UPDATE quest_set SET display_order = 293 WHERE id = 29;
UPDATE quest_set SET display_order = 294 WHERE id = 227;
UPDATE quest_set SET display_order = 295 WHERE id = 230;
UPDATE quest_set SET display_order = 296 WHERE id = 233;
UPDATE quest_set SET display_order = 297 WHERE id = 339;
UPDATE quest_set SET display_order = 298 WHERE id = 345;
UPDATE quest_set SET display_order = 299 WHERE id = 119;
UPDATE quest_set SET display_order = 300 WHERE id = 120;
UPDATE quest_set SET display_order = 301 WHERE id = 121;
UPDATE quest_set SET display_order = 302 WHERE id = 14;
UPDATE quest_set SET display_order = 290, unit_id = (SELECT id FROM unit WHERE id = 8), icon = '📛' WHERE id = 422;
