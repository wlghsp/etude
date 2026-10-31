-- 미들웨어 세트 119. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set119.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 29, 'k8s', '클러스터 운영·보안', 45 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 29);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 119, 'k8s 권한(RBAC) 읽기: Role, RoleBinding, ServiceAccount', 'k8s 에서 누가 무엇을 할 수 있는지 정하는 RBAC 를 읽고 쓰는 법을 익힙니다. Role·RoleBinding·ServiceAccount 의 역할, Role 과 ClusterRole 의 차이, Role YAML, forbidden 오류 읽기, 권한을 주는 순서, auth can-i, RoleBinding 의 네임스페이스, 최소 권한 원칙, default 계정의 위험, 명령으로 만들기를 빈칸·순서·객관식으로 다룹니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 119);
UPDATE quest_set SET display_order = 335, unit_id = (SELECT id FROM unit WHERE id = 29), icon = '🪪' WHERE id = 119;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 1, 'RBAC 의 세 가지 구성 요소', 'k8s 에서 "누가 무엇을 할 수 있는지"를 정하는 것이 RBAC 입니다. `Role` 은 **할 수 있는 일의 목록**입니다. 이 목록을 **누구에게 연결**하는 리소스, 그리고 사람 대신 **앱(Pod)이 쓰는 계정**의 이름을 채우세요.', '연결(binding)하는 것과, 서비스를 위한 계정(account)이에요.', NULL, NULL, '[]', 'fill', '["RoleBinding", "ServiceAccount", "Namespace", "ConfigMap"]', NULL, 'Role 만 만들어서는 아무 효과가 없고, **RoleBinding** 으로 사용자·그룹·ServiceAccount 에 연결해야 권한이 생깁니다. Pod 안의 앱이 API 서버에 접근할 때는 **ServiceAccount** 의 신분으로 접근해요.', '[0, 1]', 'Role: 할 수 있는 일의 목록
{0}: Role 을 누군가에게 연결
{1}: Pod 가 쓰는 계정', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 2, '노드 목록을 읽게 하려면', '모니터링 앱이 `kubectl get nodes` 와 같은 조회를 할 수 있어야 합니다. 노드는 네임스페이스에 속하지 않는 클러스터 단위 리소스입니다. 알맞은 권한 구성은 무엇일까요?', '네임스페이스 밖의 리소스는 네임스페이스용 Role 로 줄 수 없어요.', NULL, NULL, '[]', 'choice', '["`Role` 을 default 네임스페이스에 만든다", "`ClusterRole`(nodes 의 get, list)을 만들고 `ClusterRoleBinding` 으로 연결한다", "`RoleBinding` 만 만들고 Role 은 만들지 않는다", "Pod 에 `privileged: true` 를 준다"]', 1, '`Role`/`RoleBinding` 은 한 네임스페이스 안에서만 효력이 있습니다. 노드, PV, 네임스페이스 자체처럼 **클러스터 단위** 리소스는 `ClusterRole` 로 정의하고 `ClusterRoleBinding` 으로 연결해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 3, 'Role YAML 빈칸 채우기', '`dev` 네임스페이스에서 Pod 를 **조회**(get, list)만 할 수 있는 Role 입니다. 핵심 칸을 채우세요. (apiGroups 의 빈 문자열은 pods 같은 기본(core) 그룹을 뜻합니다)', '기본 그룹은 빈 문자열이고, 목록 조회 동사는 list 입니다.', NULL, NULL, '[]', 'fill', '["\\"\\"", "apps", "list", "delete"]', NULL, 'pods 는 core 그룹이라 `apiGroups: [""]` 입니다. Deployment 는 `apps` 그룹이에요. `verbs` 에는 `get`, `list`, `watch`, `create`, `update`, `delete` 중 필요한 것만 적습니다. `delete` 를 넣으면 지울 수도 있게 되니 주의하세요.', '[0, 2]', 'kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
- apiGroups: [{0}]
  resources: ["pods"]
  verbs: ["get", "{1}"]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 4, 'Forbidden 오류 읽기', '앱 로그에 다음 오류가 찍힙니다. 알맞은 해석과 조치는 무엇일까요?

`pods is forbidden: User "system:serviceaccount:dev:app" cannot list resource "pods" in API group "" in the namespace "dev"`', '오류 문장에 누가, 무엇을, 어디서 못 하는지가 모두 들어 있어요.', NULL, NULL, '[]', 'choice', '["`app` 이라는 Pod 가 없어서 생긴 오류이므로 Pod 를 만든다", "클러스터 인증서가 만료됐다", "네임스페이스 `dev` 를 지우면 해결된다", "`dev` 네임스페이스의 ServiceAccount `app` 에 pods 를 list 할 권한이 없다. 그 권한을 가진 Role 을 만들고 RoleBinding 으로 `app` 에 연결한다"]', 3, '`forbidden` 은 **인증은 됐지만 권한이 없다**는 뜻입니다(인증 실패는 `Unauthorized`). 문장에서 주체(`system:serviceaccount:dev:app`), 동작(`list`), 대상(`pods`), 위치(`dev`)를 뽑아 그만큼만 권한을 주세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 5, '앱에 읽기 권한을 주는 순서', 'Pod 안의 앱이 같은 네임스페이스의 Pod 목록을 읽게 하려 합니다. 순서에 맞게 놓아 보세요.', '계정 → 규칙 → 연결 → 사용 → 확인 순이에요.', NULL, NULL, '[]', 'order', '["ServiceAccount 를 만든다", "필요한 동작만 적은 Role 을 만든다", "RoleBinding 으로 ServiceAccount 에 Role 을 연결한다", "Pod 의 `serviceAccountName` 에 그 ServiceAccount 를 지정한다", "`kubectl auth can-i` 로 권한이 생겼는지 확인한다"]', NULL, 'Role 이 있어도 연결이 없으면, 연결이 있어도 Pod 가 그 계정을 쓰지 않으면 권한이 적용되지 않습니다. 마지막에 `auth can-i` 로 결과를 확인하는 습관이 중요해요.', '[0, 1, 2, 3, 4]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 6, 'can-i 로 권한 확인하기', '`dev` 네임스페이스에서 ServiceAccount `app` 이 Pod 를 list 할 수 있는지 **다른 계정의 입장에서** 확인하는 명령입니다. 빈칸을 채우세요.', '확인은 can-i, 다른 주체로 가정하는 옵션은 --as 예요.', NULL, NULL, '[]', 'fill', '["can-i", "--as", "--user", "get", "--token"]', NULL, '`kubectl auth can-i 동사 리소스` 는 yes 또는 no 로 답합니다. `--as` 로 다른 사용자나 ServiceAccount 의 입장에서 확인할 수 있어서, 권한을 준 뒤 "정말 되는지" 검증할 때 가장 안전한 방법이에요. (이 연습 환경은 권한이 제한돼 있어 직접 실행은 어려울 수 있습니다)', '[0, 1]', 'kubectl auth {0} list pods -n dev {1} system:serviceaccount:dev:app', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 7, '권한을 줬는데 안 먹어요', '`dev` 네임스페이스에 Role `pod-reader` 를 만들고, RoleBinding 은 실수로 `default` 네임스페이스에 만들었습니다. 결과는 어떻게 될까요?', 'RoleBinding 은 자신이 속한 네임스페이스 안에서만 효력이 있어요.', NULL, NULL, '[]', 'choice', '["`default` 네임스페이스의 RoleBinding 은 `default` 안에서만 효력이 있어(그리고 같은 네임스페이스의 Role 을 가리켜야 하므로) `dev` 의 권한은 생기지 않는다. `dev` 에 RoleBinding 을 만들어야 한다", "자동으로 모든 네임스페이스에 적용된다", "권한은 생기지만 로그만 안 남는다", "RoleBinding 은 네임스페이스와 상관없이 항상 동작한다"]', 0, 'RoleBinding 은 자기 네임스페이스 안에서만 권한을 줍니다. 권한을 주려는 네임스페이스에 만들어야 해요. 여러 네임스페이스에 같은 권한을 주려면 ClusterRole 을 각 네임스페이스의 RoleBinding 에서 참조하는 방법이 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 8, '최소 권한 원칙', '앱이 ConfigMap 하나를 읽기만 하면 되는데, 귀찮아서 앱의 ServiceAccount 에 `cluster-admin` 을 연결했습니다. 무엇이 문제일까요?', '앱이 침해당했을 때 무엇까지 할 수 있게 되는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["문제없다. 권한은 많을수록 안전하다", "`cluster-admin` 은 읽기 전용이다", "앱이 뚫리거나 버그가 생기면 클러스터 전체(Secret 읽기, 리소스 삭제)를 조작할 수 있게 된다. 필요한 리소스·동사만 가진 Role 을 만들어 써야 한다", "성능이 느려질 뿐이다"]', 2, '권한은 **필요한 만큼만** 주는 것이 원칙입니다(최소 권한). 예를 들어 `resources: ["configmaps"]`, `verbs: ["get"]` 처럼 좁게 정의하고 필요하면 `resourceNames` 로 특정 이름만 허용할 수도 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 9, 'default ServiceAccount 에 권한 주기', '네임스페이스의 `default` ServiceAccount 에 Secret 읽기 권한을 주면 편해 보입니다. 왜 피하는 것이 좋을까요?', 'serviceAccountName 을 지정하지 않은 Pod 는 어떤 계정을 쓸까요?', NULL, NULL, '[]', 'choice', '["`default` 는 삭제할 수 없어서", "계정을 지정하지 않은 모든 Pod 가 `default` 를 쓰므로, 그 네임스페이스의 의도하지 않은 Pod 까지 같은 권한을 갖게 된다. 앱마다 전용 ServiceAccount 를 만든다", "`default` 에는 권한을 줄 수 없어서", "이름이 짧아서"]', 1, 'Pod 에 `serviceAccountName` 을 쓰지 않으면 `default` 가 자동으로 쓰입니다. 여기에 권한을 주면 그 네임스페이스에서 뜨는 모든 Pod 가 권한을 공유해요. 앱별 전용 계정이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 119, 10, '명령으로 Role 과 RoleBinding 만들기', 'YAML 을 쓰지 않고 `kubectl` 명령 한 줄로도 만들 수 있습니다. ① Role `pod-reader`(Pod 를 get, list), ② 그 Role 을 ServiceAccount `app` 에 연결하는 RoleBinding `read-pods` 를 만드는 명령의 빈칸을 채우세요.', '만드는 리소스의 종류 이름이 들어가요. 연결 리소스는 한 단어(소문자)예요.', NULL, NULL, '[]', 'fill', '["role", "rolebinding", "clusterrole", "serviceaccount"]', NULL, '`kubectl create role`, `kubectl create rolebinding` 은 시험이나 실무에서 YAML 보다 빠릅니다. ServiceAccount 는 `네임스페이스:이름` 형식으로 적어요. `--dry-run=client -o yaml` 을 붙이면 YAML 뼈대도 얻을 수 있습니다.', '[0, 1]', 'kubectl create {0} pod-reader --verb=get,list --resource=pods -n dev
kubectl create {1} read-pods --role=pod-reader --serviceaccount=dev:app -n dev', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 119 AND order_index = 10);
