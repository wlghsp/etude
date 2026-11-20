-- 세트 511. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set511.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 511, 'RBAC 읽고 판단하기: Role·ClusterRole·Binding, Forbidden 오류, 최소 권한', 'k8s 권한(RBAC)을 읽고 판단하는 연습입니다. Role 이 할 수 있는 일의 목록이고 RoleBinding 이 그 목록을 받을 대상이라는 구분, Role 과 ClusterRole 의 범위, ClusterRole 을 RoleBinding 으로 연결할 때의 효과, Forbidden 오류 메시지 읽기, get 과 list 의 차이, API 그룹, ServiceAccount 주체 표기, 최소 권한 원칙, 권한 회수와 시험 순서를 다룹니다. 학습 환경에서는 권한 객체를 만들 수 없어 문제 풀이로 진행합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 511);
UPDATE quest_set SET display_order = 732, unit_id = (SELECT id FROM unit WHERE id = 29), icon = '🪪' WHERE id = 511;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 1, 'Role 과 RoleBinding 의 역할', 'RBAC 에서 `Role` 과 `RoleBinding` 은 각각 무엇을 정할까요?', '하나는 "무엇을", 다른 하나는 "누구에게"입니다.', NULL, NULL, '[]', 'choice', '["Role 은 할 수 있는 일의 목록, RoleBinding 은 그 목록을 받을 대상을 잇는다", "Role 은 권한을 받을 사용자 목록, RoleBinding 은 할 수 있는 일의 목록이다", "Role 은 클러스터 전체의 권한, RoleBinding 은 한 Pod 의 권한이다", "Role 은 인증 방법, RoleBinding 은 암호화 방법이다"]', 0, 'Role 은 verb(동작)와 resource(대상)의 짝으로 이뤄진 권한 목록이고, RoleBinding 은 그 목록을 사용자·그룹·ServiceAccount 에 연결합니다. Role 만 있고 연결이 없으면 아무도 그 권한을 쓸 수 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 2, 'Role 과 ClusterRole 의 범위', '노드나 PersistentVolume 처럼 **네임스페이스에 속하지 않는 리소스**의 권한을 정의하려면 무엇을 써야 할까요?', '네임스페이스 안에서만 유효한 객체로는 네임스페이스 밖의 리소스를 가리킬 수 없습니다.', NULL, NULL, '[]', 'choice', '["각 네임스페이스에 같은 Role 을 만든다", "ServiceAccount 에 직접 권한을 적는다", "Pod 의 annotation 에 권한을 적는다", "ClusterRole 로 정의한다"]', 3, 'Role 은 한 네임스페이스 안의 리소스만 다룰 수 있습니다. 노드·PV·네임스페이스 같은 클러스터 범위 리소스는 ClusterRole 로 정의하고 ClusterRoleBinding 으로 연결합니다. ServiceAccount 나 annotation 은 권한을 정의하는 곳이 아닙니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 3, 'ClusterRole 을 RoleBinding 으로 연결하면', '`ClusterRole view` 를 **네임스페이스 dev 의 RoleBinding** 으로 사용자 jane 에게 연결했습니다. jane 이 볼 수 있는 범위는?', '권한의 내용은 ClusterRole 이, 적용 범위는 연결하는 객체가 정합니다.', NULL, NULL, '[]', 'choice', '["모든 네임스페이스에서 볼 수 있다", "아무 곳에서도 볼 수 없다", "dev 네임스페이스 안으로 한정된다", "클러스터 범위 리소스까지 볼 수 있다"]', 2, 'ClusterRole 을 RoleBinding 으로 연결하면 그 RoleBinding 이 속한 네임스페이스 안에서만 권한이 적용됩니다. 여러 네임스페이스에서 같은 권한 목록을 재사용하면서 범위는 좁게 줄 때 쓰는 방식입니다. 전체 범위로 주려면 ClusterRoleBinding 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 4, 'Forbidden 오류 읽기', '`kubectl get secrets -n dev --as=jane` 의 결과가 `Error from server (Forbidden): secrets is forbidden: User "jane" cannot list resource "secrets" in API group "" in the namespace "dev"` 입니다. 가장 알맞은 해석은?', '메시지는 누가·무엇을·어떤 동작·어디서 거부됐는지를 모두 알려 줍니다.', NULL, NULL, '[]', 'choice', '["jane 이라는 사용자가 클러스터에 등록되어 있지 않다", "인증됐지만 dev 의 secrets 를 list 할 권한이 없다", "dev 네임스페이스가 존재하지 않아 찾을 수 없다", "API 서버에 접속하지 못해 요청이 전달되지 않았다"]', 1, 'Forbidden 은 인증은 통과했지만 권한이 없다는 뜻입니다. 메시지가 사용자(jane)·동작(list)·리소스(secrets)·네임스페이스(dev)를 알려 주므로 그 조합을 허용하는 Role 과 RoleBinding 이 있는지 확인합니다. 인증 실패는 Unauthorized 로 나타납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 5, 'get 만 있고 list 가 없을 때', 'Role 의 rules 가 `resources: ["pods"]`, `verbs: ["get"]` 뿐입니다. 이 권한으로 가능한 것은?', '이름을 지정해 하나만 가져오는 동작과 목록을 가져오는 동작은 verb 가 다릅니다.', NULL, NULL, '[]', 'choice', '["`kubectl get pod web-1` 은 되지만 `kubectl get pods` 는 거부된다", "`kubectl get pods` 도 `kubectl get pod web-1` 도 모두 된다", "두 명령 모두 거부된다", "`kubectl get pods` 는 되지만 `kubectl get pod web-1` 은 거부된다"]', 0, '이름을 지정한 조회는 `get`, 목록 조회는 `list` 가 필요합니다. get 만 있으면 이름을 아는 Pod 하나만 볼 수 있고 `kubectl get pods` 는 list 가 없어 Forbidden 입니다. 목록과 상세를 모두 보게 하려면 get, list 를 함께 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 6, 'API 그룹 때문에 안 되는 Role', 'Deployment 를 읽게 하려고 `apiGroups: [""]`, `resources: ["deployments"]`, `verbs: ["get","list"]` 인 Role 을 만들었는데 권한이 적용되지 않습니다. 가장 알맞은 원인은?', 'Pod·ConfigMap 과 Deployment 는 같은 API 그룹이 아닙니다.', NULL, NULL, '[]', 'choice', '["verbs 에 delete 가 빠져서 읽기가 막혀 있다", "Role 이 아니라 Pod 정의 안에 권한을 적어야 한다", "resources 이름은 항상 대문자로 적어야 한다", "Deployment 는 apps 그룹이라 apps 가 필요하다"]', 3, '빈 문자열 그룹은 core 그룹(Pod·ConfigMap·Secret·Service 등)입니다. Deployment 는 `apps` 그룹이라 `apiGroups: ["apps"]` 로 적어야 하고, kubectl 에서는 `--resource=deployments.apps` 처럼 씁니다. 그룹이 다르면 같은 이름의 규칙이어도 적용되지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 7, 'ServiceAccount 를 연결할 때', 'Pod 안의 앱이 API 에 접근할 때 쓰는 계정은 사람이 아니라 ServiceAccount 입니다. 그 계정에 RoleBinding 으로 권한을 줄 때 주체(subject)를 가리키는 방법으로 알맞은 것은?', '이 계정은 네임스페이스에 속하므로 이름만으로는 부족할 수 있습니다.', NULL, NULL, '[]', 'choice', '["kind 를 User 로 하고 이름만 적는다", "Pod 의 이름을 적으면 그 Pod 에 적용된다", "kind 는 ServiceAccount, 이름·네임스페이스를 적는다", "노드의 이름을 적으면 그 노드의 Pod 에 적용된다"]', 2, 'ServiceAccount 는 네임스페이스에 속한 계정이라 subject 에 kind: ServiceAccount, name, namespace 를 적습니다. 사용자(User)와는 다른 종류입니다. 시험할 때의 주체 이름은 `system:serviceaccount:네임스페이스:이름` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 8, '최소 권한 원칙', '앱 하나가 ConfigMap 을 읽기만 하면 되는데, 편하게 쓰려고 `resources: ["*"]`, `verbs: ["*"]` 로 Role 을 만들자는 의견이 나왔습니다. 가장 알맞은 판단은?', '필요한 것보다 큰 권한은 사고 때 피해 범위를 키웁니다.', NULL, NULL, '[]', 'choice', '["와일드카드로 한 번에 주는 것이 가장 안전하다", "필요한 resource·verb 만 적은 Role 로 준다", "권한은 많을수록 관리가 쉬워 좋다", "네임스페이스와 무관해 신경 쓸 필요가 없다"]', 1, '최소 권한 원칙에 따라 필요한 리소스·동작만 주고 범위도 좁게(네임스페이스 Role) 둡니다. 와일드카드는 나중에 추가된 리소스까지 자동으로 포함해 앱이 탈취됐을 때 피해가 커집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 9, '권한 회수', '사용자 jane 에게 주었던 Pod 읽기 권한을 거두려 합니다. 그 Role 은 다른 사용자에게도 연결되어 있습니다. 가장 알맞은 방법은?', '목록은 그대로 두고 연결만 끊는 방법을 생각해 보세요.', NULL, NULL, '[]', 'choice', '["jane 을 가리키는 RoleBinding 을 삭제한다", "그 Role 을 삭제해 모든 연결을 없앤다", "네임스페이스를 삭제해 모든 것을 정리한다", "jane 의 Pod 를 모두 삭제해 권한을 없앤다"]', 0, '권한은 RoleBinding 이 대상과 Role 을 잇는 것이므로 연결을 지우면 그 사용자의 권한이 사라집니다. Role 을 지우면 같은 Role 을 쓰는 다른 사용자의 권한까지 사라집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 10, '다른 사용자 입장에서 권한 시험', '`dev` 네임스페이스에서 사용자 `jane` 이 Deployment 를 **delete** 할 수 있는지 **jane 의 입장에서** 확인하는 명령입니다. 빈칸을 채우세요.', '다른 사용자인 것처럼 요청을 보내는 옵션입니다.', NULL, NULL, '[]', 'fill', '["--as", "--user", "--token", "--impersonate"]', NULL, '`--as=사용자` 는 그 사용자의 입장에서 요청을 보냅니다(impersonation). `--user` 는 kubeconfig 의 자격 증명 이름을 고르는 옵션이라 권한 시험과 다르고, `--token` 은 토큰을 직접 지정하는 옵션입니다. `--impersonate` 는 kubectl 옵션이 아닙니다.', '[0]', 'kubectl auth can-i delete deployments -n dev {0}=jane', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 11, 'ServiceAccount 에 연결', 'ServiceAccount `app` 에 Role `pod-reader` 를 연결하는 명령입니다. 빈칸에 들어갈 옵션을 채우세요. (네임스페이스 dev)', '사용자를 가리키는 옵션과 ServiceAccount 를 가리키는 옵션은 다릅니다.', NULL, NULL, '[]', 'fill', '["serviceaccount", "user", "group", "clusterrole"]', NULL, '`--serviceaccount=네임스페이스:이름` 으로 ServiceAccount 를 가리킵니다. `--user` 는 사용자, `--group` 은 그룹이고 `--clusterrole` 은 연결할 역할의 종류를 정하는 옵션입니다.', '[0]', 'kubectl create rolebinding app-read --role=pod-reader --{0}=dev:app -n dev', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 511, 12, '권한을 주고 시험하는 순서', '새 사용자 `jane` 이 `dev` 네임스페이스의 Pod 를 읽게 하려 합니다. 카드를 알맞은 순서로 놓으세요.', '무엇을 줄지 정한 뒤 누구에게 줄지 잇고, 준 것이 맞는지 마지막에 확인합니다.', NULL, NULL, '[]', 'order', '["can-i --as=jane 으로 시험한다", "RoleBinding 으로 jane 에게 연결한다", "Forbidden 이 나오면 verb·resource·네임스페이스를 점검해 고친다", "Role 로 할 수 있는 일(get·list pods)을 정한다"]', NULL, 'Role(무엇을) → RoleBinding(누구에게) → can-i --as(시험) 순서입니다. 시험에서 no 나 Forbidden 이 나오면 verb·resource·API 그룹·네임스페이스·Binding 대상 이름을 차례로 점검해 고칩니다.', '[3, 1, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 511 AND order_index = 12);
