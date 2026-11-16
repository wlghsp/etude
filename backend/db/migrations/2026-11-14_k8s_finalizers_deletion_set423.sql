-- 퀴즈 세트 423. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_round_b.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 423, 'Finalizer 와 삭제가 멈출 때: deletionTimestamp, Terminating, ownerReferences', '삭제가 끝나지 않을 때를 읽습니다. finalizer 가 삭제 전 대기시키는 키 목록인 점, deletionTimestamp 와 Terminating, 컨트롤러의 제거, pv-protection 예, ownerReferences 기반 정리, 삭제 뒤에는 추가 불가·되살리기 불가, 수동 제거의 위험을 봅니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 423);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 1, 'finalizer 란', '**finalizer** 의 설명으로 맞는 것은 무엇일까요?', '삭제 전에 기다리게 해요.', NULL, NULL, '[]', 'choice', '["리소스를 즉시 삭제하는 명령", "리소스의 복사본을 만드는 컨트롤러", "삭제 전에 조건 충족을 기다리게 하는 키", "리소스를 읽기 전용으로 만드는 라벨"]', 2, '쿠버네티스 문서는 finalizer 를 삭제 표시된 리소스를 완전히 지우기 전에 특정 조건이 충족될 때까지 기다리라고 알리는 네임스페이스 키이며 보통 실행 코드가 아니라 어노테이션 비슷한 키 목록이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 2, '삭제 요청', 'finalizer 가 있는 오브젝트에 **삭제를 요청** 하면 어떻게 될까요?', 'deletionTimestamp 가 채워져요.', NULL, NULL, '[]', 'choice', '["즉시 완전히 삭제된다", "Terminating 상태로 남는다", "삭제 요청이 거부된다", "finalizer 가 자동으로 모두 지워진다"]', 1, '문서는 삭제 요청 시 API 가 .metadata.deletionTimestamp 를 채워 삭제 표시를 하고 202 를 반환하며 대상 오브젝트는 종료 중(terminating) 상태로 남는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 3, '삭제가 멈춘 이유', '`Terminating` 상태에서 오브젝트가 **사라지지 않는** 흔한 이유는 무엇일까요?', 'metadata 의 목록이에요.', NULL, NULL, '[]', 'choice', '["finalizers 에 항목이 남아 있다", "deletionTimestamp 가 비어 있기 때문", "ownerReferences 가 없기 때문", "라벨이 너무 많기 때문"]', 0, '문서는 metadata.finalizers 의 항목이 모두 제거될 때까지 오브젝트가 지워지지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 4, '누가 제거하나', '조건이 충족되었을 때 finalizer 키는 **누가** 제거할까요?', '해당 리소스를 다루는 쪽이에요.', NULL, NULL, '[]', 'choice', '["kubectl get 이 자동으로 제거한다", "노드의 kubelet 이 항상 제거한다", "시간이 지나면 저절로 사라진다", "컨트롤러가 조건을 충족할 때마다 제거한다"]', 3, '문서는 finalizer 조건이 충족될 때마다 컨트롤러가 그 키를 finalizers 필드에서 제거하고 필드가 비면 deletionTimestamp 가 있는 오브젝트가 자동으로 삭제된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 5, 'pv-protection', '`kubernetes.io/pv-protection` finalizer 의 용도는 무엇일까요?', 'PV 를 보호해요.', NULL, NULL, '[]', 'choice', '["Pod 의 이미지 풀을 막는다", "Service 의 포트 충돌을 막는다", "PV 의 우발적 삭제를 막는다", "Node 의 재부팅을 막는다"]', 2, '문서는 kubernetes.io/pv-protection 이 PersistentVolume 오브젝트의 우발적 삭제를 막는 흔한 예이며 Pod 가 PV 를 쓰는 동안 finalizer 가 유지된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 6, 'owner 와 정리', 'Job 을 삭제할 때 실행 중이던 Pod 를 **정리할 대상으로 정하는 근거** 는 무엇일까요?', '라벨이 아니에요.', NULL, NULL, '[]', 'choice', '["라벨 셀렉터 값", "소유자 참조", "Pod 이름 접두사", "노드의 어노테이션"]', 1, '문서는 Job 을 지울 때 쿠버네티스가 라벨이 아니라 owner references 로 정리할 Pod 를 판단한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 7, '삭제 뒤 추가', '삭제가 **요청된 뒤** 의 finalizer 에 대한 설명으로 맞는 것은 무엇일까요?', '제거만 돼요.', NULL, NULL, '[]', 'choice', '["기존 finalizer 는 제거할 수 있지만 새로 추가할 수는 없다", "새 finalizer 를 얼마든지 추가할 수 있다", "finalizer 를 제거하거나 추가할 수 없다", "deletionTimestamp 를 다시 수정할 수 있다"]', 0, '문서는 삭제 요청 뒤에는 기존 finalizer 를 제거할 수만 있고 새 finalizer 를 추가할 수 없으며 deletionTimestamp 도 한번 설정되면 수정할 수 없다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 8, '되살리기', '삭제가 한번 요청된 오브젝트는 **되살릴 수** 있을까요?', '없어요.', NULL, NULL, '[]', 'choice', '["finalizer 를 모두 지우면 되살릴 수 있다", "deletionTimestamp 를 지우면 되살릴 수 있다", "1시간 안에는 취소할 수 있다", "되살릴 수 없고 같은 형태의 새 오브젝트를 만들어야 한다"]', 3, '문서는 한번 삭제가 요청된 오브젝트는 되살릴 수 없으며 같은 형태의 새 오브젝트를 만들어야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 9, '직접 제거', '삭제가 멈췄을 때 **finalizer 를 직접 지우는 것** 에 대한 문서의 권고는 무엇일까요?', '이유가 있어서 붙은 거예요.', NULL, NULL, '[]', 'choice', '["항상 먼저 지우는 것이 표준 절차다", "아무 영향이 없어 바로 지워도 된다", "강제 제거는 문제를 일으킬 수 있어 피한다", "노드를 재시작하는 것과 같다"]', 2, '문서는 삭제를 진행시키려고 finalizer 를 수동으로 제거하는 것을 피하라고 하며, finalizer 는 대개 이유가 있어 붙으므로 강제로 제거하면 클러스터에 문제가 생길 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 10, '삭제 시각', '삭제가 요청되면 채워지는 metadata 필드입니다. 빈칸을 채우세요.', '"삭제 시각" 이에요.', NULL, NULL, '[]', 'fill', '["deletionTimestamp", "finalizers", "ownerReferences", "creationTimestamp"]', NULL, '삭제 요청 시 API 가 .metadata.deletionTimestamp 를 채웁니다. finalizers 는 지우기 전에 기다리게 하는 키 목록입니다.', '[0]', 'metadata.{0}', NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 11, 'finalizer 필드', '삭제 전 기다릴 키를 담는 metadata 필드입니다. 빈칸을 채우세요.', '"마무리 하는 것들" 이에요.', NULL, NULL, '[]', 'fill', '["finalizers", "ownerReferences", "annotations", "labels"]', NULL, 'metadata.finalizers 의 항목이 모두 제거될 때까지 오브젝트가 지워지지 않습니다.', '[0]', 'metadata:
  {0}:
  - example.com/cleanup', NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 423, 12, 'finalizer 가 있는 삭제', 'finalizer 가 있는 오브젝트가 삭제되는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '요청 → 대기 → 제거 → 삭제예요.', NULL, NULL, '[]', 'order', '["삭제를 요청하면 `deletionTimestamp` 가 채워지고 Terminating 상태가 된다", "컨트롤러가 정리 조건이 충족될 때마다 finalizer 키를 제거한다", "`finalizers` 가 비면 오브젝트가 자동으로 삭제된다"]', NULL, '문서의 삭제 흐름 설명을 이은 일반 절차입니다.', '[0, 1, 2]', NULL, NULL, '[{"title": "Finalizer", "url": "https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 423 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 300 WHERE id = 119;
UPDATE quest_set SET display_order = 301 WHERE id = 120;
UPDATE quest_set SET display_order = 302 WHERE id = 121;
UPDATE quest_set SET display_order = 303 WHERE id = 14;
UPDATE quest_set SET display_order = 299, unit_id = (SELECT id FROM unit WHERE id = 9), icon = '🏁' WHERE id = 423;
