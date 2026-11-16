-- 퀴즈 세트 421. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_round_a.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 421, 'Pod 토폴로지 분산 제약: maxSkew, topologyKey, whenUnsatisfiable, minDomains', 'Pod 를 도메인에 고르게 퍼뜨리는 제약을 읽습니다. maxSkew 와 전역 최소값, topologyKey, whenUnsatisfiable 의 DoNotSchedule 기본과 ScheduleAnyway, minDomains, matchLabelKeys, 같은 조합에 제약 하나를 봅니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 421);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 1, 'maxSkew 의미', '`DoNotSchedule` 일 때 **maxSkew** 는 무엇을 뜻할까요?', '쏠림의 한계예요.', NULL, NULL, '[]', 'choice', '["도메인 하나에 둘 수 있는 Pod 의 최대 개수", "허용되는 도메인의 최대 개수", "일치 Pod 수와 전역 최소값 사이의 최대 허용 차이", "노드 하나가 감당하는 최대 Pod 수"]', 2, '쿠버네티스 문서는 maxSkew 가 필수이며 0보다 커야 하고, DoNotSchedule 일 때 대상 토폴로지의 일치 Pod 수와 전역 최소값 사이의 최대 허용 차이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 2, 'maxSkew 예시', '3개 zone 에 일치 Pod 가 각각 2, 2, 1개이고 maxSkew 가 1 일 때 **전역 최소값** 은 얼마일까요?', '가장 적은 쪽이에요.', NULL, NULL, '[]', 'choice', '["2", "1", "0", "5"]', 1, '문서의 예시는 zone 별 일치 Pod 가 2, 2, 1개이고 maxSkew 가 1 이면 전역 최소값이 1 이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 3, 'topologyKey', '`topologyKey` 는 무엇일까요?', '노드 라벨이에요.', NULL, NULL, '[]', 'choice', '["노드 라벨의 키", "Pod 라벨의 키", "네임스페이스 이름", "노드 IP 의 대역"]', 0, '문서는 topologyKey 가 노드 라벨의 키이며 같은 키와 값을 가진 노드들이 같은 토폴로지(도메인)에 속한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 4, 'whenUnsatisfiable 기본', '`whenUnsatisfiable` 의 **기본값** 은 무엇일까요?', '스케줄하지 않는 쪽이에요.', NULL, NULL, '[]', 'choice', '["ScheduleAnyway", "Preferred", "Required", "DoNotSchedule"]', 3, '문서는 DoNotSchedule 이 기본값이며 스케줄하지 않고, ScheduleAnyway 는 스케줄하되 쏠림을 줄이는 노드를 우선한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 5, 'ScheduleAnyway', '`ScheduleAnyway` 의 동작은 무엇일까요?', '조건을 못 맞춰도 놓아요.', NULL, NULL, '[]', 'choice', '["조건을 못 맞추면 Pod 를 Pending 으로 둔다", "조건을 완전히 무시한다", "스케줄은 하되 쏠림을 줄이는 노드를 우선한다", "쏠림이 생긴 Pod 를 축출한다"]', 2, '문서는 ScheduleAnyway 가 스케줄하되 쏠림을 줄이는 노드를 우선하며 maxSkew 는 이때 우선순위 정도에 영향을 준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 6, 'minDomains', '`minDomains` 는 어떤 `whenUnsatisfiable` 과 함께 쓸 수 있을까요?', '한 값만 돼요.', NULL, NULL, '[]', 'choice', '["ScheduleAnyway 와만", "DoNotSchedule 과만", "둘 다", "어느 쪽과도 쓸 수 없다"]', 1, '문서는 minDomains 가 선택 필드이며 0보다 커야 하고 whenUnsatisfiable: DoNotSchedule 과만 함께 쓸 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 7, 'minDomains 효과', '적격 도메인 수가 `minDomains` 보다 **적으면** 전역 최소값은 어떻게 다룰까요?', '0 으로 봐요.', NULL, NULL, '[]', 'choice', '["0 으로 취급한다", "도메인 수로 취급한다", "1 로 취급한다", "무한대로 취급한다"]', 0, '문서는 적격 도메인 수가 minDomains 보다 적으면 전역 최소값을 0 으로 취급하고, 같거나 많으면 영향이 없으며 지정하지 않으면 1 로 동작한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 8, 'matchLabelKeys', '`matchLabelKeys` 는 무엇을 할까요?', '라벨 값을 합쳐요.', NULL, NULL, '[]', 'choice', '["노드 라벨을 Pod 에 복사한다", "도메인 목록을 자동으로 만든다", "labelSelector 를 대체해 항상 무시한다", "Pod 라벨 값을 labelSelector 에 병합"]', 3, '문서는 matchLabelKeys 가 Pod 생성 시 kube-apiserver 가 이 키로 Pod 라벨의 값을 가져와 기존 labelSelector 와 병합한다고 설명합니다. 같은 키를 matchLabelKeys 와 labelSelector 에 동시에 둘 수 없습니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 9, '제약 조합', '같은 `topologyKey` 와 `whenUnsatisfiable` 조합에는 제약을 **몇 개** 둘 수 있을까요?', '하나뿐이에요.', NULL, NULL, '[]', 'choice', '["둘까지", "개수 제한이 없다", "하나만", "노드 수만큼"]', 2, '문서는 한 topologyKey 와 whenUnsatisfiable 값 조합에는 제약을 하나만 둘 수 있으며 같은 topologyKey 로 제약을 더하려면 whenUnsatisfiable 값이 달라야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 10, '기본 동작', '조건을 못 맞추면 **스케줄하지 않는** 기본값입니다. 빈칸을 채우세요.', '"예약하지 마라" 라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["DoNotSchedule", "ScheduleAnyway", "Required", "Never"]', NULL, 'DoNotSchedule 이 기본값이며 조건을 만족하지 못하면 스케줄하지 않습니다.', '[0]', 'whenUnsatisfiable: {0}', NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 11, '허용 차이', '**필수** 이며 0보다 커야 하는 최대 허용 차이 필드입니다. 빈칸을 채우세요.', '"기울어짐" 이 들어가요.', NULL, NULL, '[]', 'fill', '["maxSkew", "minDomains", "topologyKey", "matchLabelKeys"]', NULL, 'maxSkew 는 필수이며 0보다 커야 합니다. minDomains 와 matchLabelKeys 는 선택 필드입니다.', '[0]', '{0}: 1', NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 421, 12, '분산 제약 쓰기', 'Pod 에 분산 제약을 넣는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '기준 → 허용 차이 → 못 맞출 때 → 대상이에요.', NULL, NULL, '[]', 'order', '["`topologyKey` 로 도메인을 나눌 노드 라벨을 정한다", "`maxSkew` 로 허용할 차이를 정한다", "`whenUnsatisfiable` 로 못 맞출 때의 동작을 정한다", "`labelSelector` 로 개수를 셀 Pod 를 정한다"]', NULL, '문서의 필드 구조 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Pod 토폴로지 분산 제약", "url": "https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 421 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 282 WHERE id = 80;
UPDATE quest_set SET display_order = 283 WHERE id = 13;
UPDATE quest_set SET display_order = 284 WHERE id = 122;
UPDATE quest_set SET display_order = 285 WHERE id = 25;
UPDATE quest_set SET display_order = 286 WHERE id = 108;
UPDATE quest_set SET display_order = 287 WHERE id = 37;
UPDATE quest_set SET display_order = 288 WHERE id = 26;
UPDATE quest_set SET display_order = 289 WHERE id = 348;
UPDATE quest_set SET display_order = 290 WHERE id = 23;
UPDATE quest_set SET display_order = 291 WHERE id = 31;
UPDATE quest_set SET display_order = 292 WHERE id = 29;
UPDATE quest_set SET display_order = 293 WHERE id = 227;
UPDATE quest_set SET display_order = 294 WHERE id = 230;
UPDATE quest_set SET display_order = 295 WHERE id = 233;
UPDATE quest_set SET display_order = 296 WHERE id = 339;
UPDATE quest_set SET display_order = 297 WHERE id = 345;
UPDATE quest_set SET display_order = 298 WHERE id = 119;
UPDATE quest_set SET display_order = 299 WHERE id = 120;
UPDATE quest_set SET display_order = 300 WHERE id = 121;
UPDATE quest_set SET display_order = 301 WHERE id = 14;
UPDATE quest_set SET display_order = 279, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🪜' WHERE id = 421;
