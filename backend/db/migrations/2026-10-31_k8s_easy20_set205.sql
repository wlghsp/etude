-- k8s 세트 205. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set205.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 205, '네임스페이스·조회·권한 기본: -n·-A, get all 범위, -o name, -w, --sort-by, auth can-i, annotate, scale 0', '네임스페이스와 조회, 권한 확인의 기본 동작을 한 개념씩 반복합니다. 네임스페이스를 중복해 만들 때의 AlreadyExists 오류, -n 을 생략하면 기본 네임스페이스만 보는 것, -A 가 NAMESPACE 열을 붙여 모두 보여 주는 것, get all 에 ConfigMap 과 Secret 이 나오지 않는 것, -o name 의 종류/이름 형식, --sort-by 의 만든 시각 정렬, -w 로 변화를 계속 지켜보는 것, version 과 cluster-info 의 차이, auth can-i 의 yes·no 와 종료 코드, Role 만으로는 권한이 없고 RoleBinding 으로 연결해야 하는 것, annotate 의 --overwrite 와 키 뒤 - 삭제, replicas 0 으로 줄여도 Deployment 가 남는 것, Pod 를 지우면 새 Pod 가 만들어지는 것, 네임스페이스를 지우면 안의 리소스가 함께 사라지는 것을 짧은 객관식·빈칸·순서 문제로 익히고, 실습 네임스페이스 만들어 쓰고 지우기, 읽기 권한 열어 주기, Deployment 내렸다 되살리기, Pod 변화 지켜보기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 205);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🪟' WHERE id = 205;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 1, '네임스페이스 만들기', '`kubectl create namespace dev` 를 한 번 실행한 뒤 같은 명령을 다시 실행하면 어떻게 될까요?', '이미 있는 이름은 만들 수 없어요.', NULL, NULL, '[]', 'choice', '["두 번째는 조용히 성공하고 아무것도 바꾸지 않는다", "두 번째는 기존 네임스페이스를 지우고 새로 만든다", "처음에는 만들어지고, 두 번째는 `AlreadyExists` 오류가 난다. 네임스페이스 이름은 클러스터에서 하나뿐이다", "두 번째는 `dev-1` 처럼 번호가 붙은 이름으로 만들어진다"]', 2, '`kubectl get ns` 로 목록을 보면 처음부터 `default`, `kube-system`, `kube-public`, `kube-node-lease` 가 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 2, '-n 을 생략하면', '`dev` 네임스페이스에 Pod `p1` 이 있습니다. `kubectl get pod p1` 을 `-n` 없이 실행하면 어떻게 될까요?', '생략하면 현재 컨텍스트의 기본 네임스페이스를 봐요.', NULL, NULL, '[]', 'choice', '["모든 네임스페이스에서 찾아 `p1` 을 보여 준다", "기본 네임스페이스(보통 `default`)에서 찾으므로 `NotFound` 오류가 난다. `kubectl get pod p1 -n dev` 로 써야 보인다", "`dev` 가 가장 최근에 만든 네임스페이스라서 자동으로 `dev` 를 본다", "오류 없이 빈 목록만 출력한다"]', 1, '`-n` 을 매번 쓰기 싫으면 컨텍스트의 기본 네임스페이스를 바꿉니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 3, '-A 로 모든 네임스페이스 보기', '`kubectl get pod -A` 는 `kubectl get pod` 와 어떻게 다를까요?', '`--all-namespaces` 의 줄임말이에요.', NULL, NULL, '[]', 'choice', '["모든 네임스페이스의 Pod 를 보여 주고, 맨 앞에 `NAMESPACE` 열이 추가된다", "현재 네임스페이스의 Pod 중 실행 중인 것만 보여 준다", "모든 네임스페이스의 Pod 를 보여 주지만 열은 같다", "`-A` 는 Pod 이름을 알파벳순으로 정렬하는 옵션이다"]', 0, '같은 이름의 Pod 가 여러 네임스페이스에 있어도 `NAMESPACE` 열로 구분됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 4, 'kubectl get all 의 범위', '`kubectl get all -n dev` 의 결과에는 무엇이 나오고 무엇이 나오지 않을까요?', '이름과 달리 모든 종류는 아니에요.', NULL, NULL, '[]', 'choice', '["ConfigMap 과 Secret 을 포함해 그 네임스페이스의 모든 리소스가 나온다", "Pod 만 나온다", "Service 와 ConfigMap 만 나온다", "Pod, Service, Deployment, ReplicaSet, Job, CronJob 같은 워크로드는 나오지만 ConfigMap 과 Secret 은 나오지 않는다. 함께 보려면 `kubectl get all,cm,secret` 처럼 종류를 이어 쓴다"]', 3, '쉼표로 종류를 이어 쓰면 한 번에 볼 수 있습니다. 예: `kubectl get pod,svc -n dev`.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 5, '-o name 의 출력', '`kubectl get pod -n dev -o name` 은 어떻게 출력할까요?', '종류와 이름을 슬래시로 이어요.', NULL, NULL, '[]', 'choice', '["`p1` 처럼 이름만 출력한다", "이름과 상태를 표로 출력한다", "`pod/p1` 처럼 `종류/이름` 한 줄씩만 출력한다. 헤더와 다른 열은 나오지 않는다", "각 Pod 의 YAML 을 출력한다"]', 2, '`kubectl get deploy,svc -o name` 처럼 종류가 섞여도 `deployment.apps/web`, `service/web` 으로 구분됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 6, '--sort-by 로 정렬하기', '`kubectl get pod --sort-by=.metadata.creationTimestamp` 는 어떤 순서로 보여 줄까요?', '만들어진 시각 기준이에요.', NULL, NULL, '[]', 'choice', '["나중에 만든 Pod 가 위에 나온다", "먼저 만들어진 Pod 가 위에, 나중에 만든 Pod 가 아래에 나온다. 정렬 옵션이 없으면 이름순이다", "정렬 옵션이 없어도 항상 만든 순서로 나온다", "Pod 의 CPU 사용량이 큰 순서로 나온다"]', 1, '경로는 `-o jsonpath` 와 같은 방식으로 씁니다. 이름순은 `--sort-by=.metadata.name` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 7, '-w 로 변화 지켜보기', '`kubectl get pod -n dev -w` 는 어떻게 동작할까요?', '끝나지 않고 기다려요.', NULL, NULL, '[]', 'choice', '["현재 목록을 먼저 출력하고 끝나지 않은 채 기다리면서, Pod 상태가 바뀔 때마다 새 줄을 계속 출력한다. `Ctrl+C` 로 끝낸다", "목록을 한 번 출력하고 바로 끝난다", "5초마다 목록을 처음부터 다시 출력한다", "`-w` 는 경고(warning)만 출력하는 옵션이다"]', 0, '새 Pod 를 만들면 `Pending`, `ContainerCreating`, `Completed` 처럼 상태가 바뀔 때마다 줄이 추가됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 8, 'kubectl version 과 cluster-info', '`kubectl version` 과 `kubectl cluster-info` 는 각각 무엇을 보여 줄까요?', '하나는 버전, 하나는 접속 주소 요약이에요.', NULL, NULL, '[]', 'choice', '["`version` 은 Pod 이미지의 버전을, `cluster-info` 는 노드 목록을 보여 준다", "`version` 은 서버 버전만, `cluster-info` 는 클라이언트 버전만 보여 준다", "둘은 같은 내용을 보여 준다", "`kubectl version` 은 클라이언트(kubectl)와 서버(클러스터)의 버전을, `kubectl cluster-info` 는 컨트롤 플레인과 CoreDNS 같은 핵심 구성 요소의 주소를 보여 준다"]', 3, '클라이언트 버전만 보려면 `kubectl version --client` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 9, 'auth can-i 로 권한 확인', '`kubectl auth can-i create pods -n dev` 는 무엇을 알려 줄까요? 권한이 없으면 종료 코드는요?', '현재 사용자의 권한을 물어봐요.', NULL, NULL, '[]', 'choice', '["Pod 를 실제로 하나 만들어 본다", "권한이 없으면 오류 메시지와 함께 종료 코드가 0 이다", "지금 사용자가 `dev` 에서 Pod 를 만들 수 있는지 `yes` 또는 `no` 로 알려 준다. `no` 이면 종료 코드가 1 이다", "클러스터에 있는 모든 사용자의 권한 목록을 출력한다"]', 2, '`--as=system:serviceaccount:dev:viewer` 를 붙이면 그 서비스 어카운트 입장에서 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 10, 'Role 과 RoleBinding', 'ServiceAccount `viewer` 를 만든 뒤 `get, list pods` 를 허용하는 Role `pod-reader` 만 만들었습니다. `viewer` 는 Pod 를 `list` 할 수 있을까요? RoleBinding 으로 연결한 뒤에는요?', 'Role 은 권한 묶음이고 연결은 따로 해요.', NULL, NULL, '[]', 'choice', '["Role 을 만든 것만으로 `viewer` 는 모든 네임스페이스에서 `list` 할 수 있다", "Role 만 만든 상태에서는 `no` 이고, RoleBinding 으로 `viewer` 에 연결하면 그 네임스페이스에서 `list` 가 `yes` 가 된다. 다른 네임스페이스의 Pod 나 `delete` 는 여전히 `no` 이다", "RoleBinding 을 만들면 `viewer` 는 `delete` 도 할 수 있게 된다", "RoleBinding 을 만들어도 ServiceAccount 에는 적용되지 않는다"]', 1, 'Role 은 한 네임스페이스 안에서만 유효하고, 클러스터 전체에 주려면 ClusterRole 과 ClusterRoleBinding 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 11, 'annotate 와 --overwrite', 'Pod 에 `kubectl annotate pod p1 note=hello` 를 한 뒤 `kubectl annotate pod p1 note=again` 을 실행하면 어떻게 될까요?', '이미 값이 있는 키예요.', NULL, NULL, '[]', 'choice', '["`--overwrite is false` 오류가 나고 값은 `hello` 로 남는다. 바꾸려면 `--overwrite` 를 붙이고, 지우려면 `note-` 처럼 키 뒤에 `-` 를 붙인다", "조용히 `again` 으로 바뀐다", "`note` 키가 하나 더 생겨 값이 둘이 된다", "annotation 은 한 번 달면 바꾸거나 지울 수 없다"]', 0, 'annotation 은 `-l note=again` 으로 Pod 를 고를 수 없습니다. 고를 때 쓰는 것은 label 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 12, 'replicas 를 0 으로', '`kubectl scale deploy web --replicas=0` 을 하면 어떻게 될까요?', '지우는 것이 아니라 개수를 0 으로 맞춰요.', NULL, NULL, '[]', 'choice', '["Deployment 가 삭제된다", "Pod 가 모두 일시 중지되어 그대로 남아 있다", "오류가 나서 `--replicas` 는 1 이상만 쓸 수 있다", "Deployment 는 남아 `0/0` 으로 보이고 그 Pod 들은 모두 사라진다. 다시 `--replicas=2` 로 올리면 Pod 가 새로 만들어진다"]', 3, '`--current-replicas=5` 를 함께 주면 현재 값이 5 일 때만 바꾸고, 다르면 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 13, 'Deployment 의 Pod 를 지우면', 'Deployment `web` 의 Pod 를 `kubectl delete pod -l app=web` 으로 지우면 어떻게 될까요?', 'Deployment 는 원하는 개수를 맞춰요.', NULL, NULL, '[]', 'choice', '["Pod 가 영구히 사라진다", "Deployment 도 함께 삭제된다", "Deployment 의 ReplicaSet 이 원하는 개수를 맞추려고 새 Pod 를 만들어 다시 하나가 생긴다. Pod 를 없애려면 Deployment 를 줄이거나 지운다", "새 Pod 는 만들어지지 않고 오류만 기록된다"]', 2, '지운 Pod 가 되살아나는 것이 아니라 같은 역할의 새 Pod 가 만들어지는 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 14, '네임스페이스를 지우면', '`kubectl delete ns dev` 를 하면 `dev` 안의 ConfigMap, Secret, Service, Deployment 는 어떻게 될까요?', '안에 든 것까지 함께 정리돼요.', NULL, NULL, '[]', 'choice', '["네임스페이스만 지워지고 안의 리소스는 `default` 로 옮겨진다", "네임스페이스 안의 리소스가 모두 함께 삭제된다. 삭제 후 `kubectl get ns dev` 는 `NotFound` 이다", "안에 리소스가 남아 있으면 삭제가 거부된다", "Deployment 만 삭제되고 ConfigMap 과 Secret 은 남는다"]', 1, '삭제는 되돌릴 수 없으므로 실습 네임스페이스에서만 연습합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 15, '네임스페이스 만들기', '새 **네임스페이스를 만드는** `kubectl create` 의 대상 종류를 채우세요.', '"이름 공간"을 영어로 이어 써요.', NULL, NULL, '[]', 'fill', '["namespace", "space", "project", "group"]', NULL, '줄임말은 `ns` 입니다.', '[0]', 'kubectl create {0} dev', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 16, '네임스페이스 지정 옵션', '특정 **네임스페이스를 지정하는** 옵션을 채우세요.', '"namespace"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-m", "-o", "-t"]', NULL, '긴 이름은 `--namespace` 입니다.', '[0]', 'kubectl get pod {0} dev', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 17, '모든 네임스페이스', '**모든 네임스페이스**의 리소스를 한꺼번에 보는 옵션을 채우세요.', '"all"의 머리글자이고 대문자예요.', NULL, NULL, '[]', 'fill', '["-A", "-a", "-N", "-n"]', NULL, '긴 이름은 `--all-namespaces` 입니다.', '[0]', 'kubectl get pod {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 18, '워크로드 한꺼번에 보기', 'Pod, Service, Deployment 같은 **주요 워크로드를 한꺼번에 보여 주는** 종류 이름을 채우세요.', '"전부"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["all", "every", "any", "full"]', NULL, 'ConfigMap 과 Secret 은 나오지 않습니다.', '[0]', 'kubectl get {0} -n dev', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 19, '이름만 출력', '`kubectl get` 이 **`종류/이름` 만 출력하게** 하는 `-o` 형식을 채우세요.', '"이름"을 영어로 쓰세요.', NULL, NULL, '[]', 'fill', '["name", "names", "id", "short"]', NULL, '`pod/p1` 처럼 나옵니다.', '[0]', 'kubectl get pod -o {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 20, '만든 시각으로 정렬', 'Pod 를 **만든 시각 순으로 정렬하는** `--sort-by` 값을 채우세요.', 'metadata 아래의 시각 필드예요.', NULL, NULL, '[]', 'fill', '[".metadata.creationTimestamp", ".metadata.created", ".status.createdAt", ".spec.age"]', NULL, '먼저 만든 것이 위에 나옵니다.', '[0]', 'kubectl get pod --sort-by={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 21, '변화 지켜보기', '**변경을 계속 지켜보는** `kubectl get` 옵션을 채우세요.', '"watch"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-w", "-f", "-t", "-v"]', NULL, '`Ctrl+C` 로 끝냅니다.', '[0]', 'kubectl get pod {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 22, '권한 확인 하위 명령', '`kubectl auth` 아래에서 **내가 할 수 있는 동작인지 확인하는** 하위 명령을 채우세요.', '"할 수 있나?"를 영어로 이어 써요.', NULL, NULL, '[]', 'fill', '["can-i", "check", "test", "allow"]', NULL, '`yes` 또는 `no` 로 답합니다.', '[0]', 'kubectl auth {0} create pods', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 23, '주석 달기', '리소스에 **annotation 을 다는** `kubectl` 하위 명령을 채우세요.', '"주석"을 뜻하는 영어 동사예요.', NULL, NULL, '[]', 'fill', '["annotate", "comment", "note", "describe"]', NULL, 'label 을 다는 명령은 `label` 입니다.', '[0]', 'kubectl {0} pod p1 note=hello', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 24, 'annotation 덮어쓰기', '이미 있는 annotation 값을 **바꾸도록 허용하는** 옵션을 채우세요.', '"덮어쓰다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["--overwrite", "--force", "--replace", "--update"]', NULL, '키 뒤에 `-` 를 붙이면 지웁니다.', '[0]', 'kubectl annotate pod p1 note=again {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 25, '개수 정하는 옵션', '`kubectl scale` 에서 **Pod 개수를 정하는** 옵션을 채우세요.', '"복제본"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["--replicas", "--count", "--size", "--pods"]', NULL, '`0` 으로 하면 Pod 가 모두 사라지고 Deployment 는 남습니다.', '[0]', 'kubectl scale deploy web {0}=0', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 26, '네임스페이스 만들어 쓰고 지우기', '실습용 네임스페이스를 만들어 쓰고 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 실행 → 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create ns dev` 로 네임스페이스를 만든다", "`kubectl run p1 -n dev --image=busybox:1.36 --restart=Never -- sleep 600` 으로 Pod 를 만든다", "`kubectl get pod -n dev` 로 `p1` 이 보이는지 확인한다", "`kubectl delete ns dev` 로 네임스페이스와 그 안의 리소스를 한꺼번에 지운다"]', NULL, '`-n dev` 없이 `kubectl get pod` 를 하면 `default` 를 보므로 `p1` 이 보이지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 27, '읽기 권한 열어 주기', 'ServiceAccount 에 Pod 읽기 권한을 열어 주고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '계정 만들기 → 권한 확인(없음) → 권한 연결 → 권한 확인(있음) 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create sa viewer -n dev` 로 ServiceAccount 를 만든다", "`kubectl auth can-i list pods -n dev --as=system:serviceaccount:dev:viewer` 가 `no` 인지 확인한다", "Role 과 RoleBinding 을 만들어 `viewer` 에 `get, list pods` 권한을 연결한다", "같은 `can-i` 가 `yes` 로 바뀌었는지 확인한다"]', NULL, '`delete pods` 는 Role 에 넣지 않았으므로 여전히 `no` 입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 28, 'Deployment 잠시 멈췄다 되살리기', 'Deployment 의 Pod 를 모두 내렸다가 되살리는 순서입니다. 순서에 맞게 놓아 보세요.', '줄이기 → 확인 → 되살리기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl scale deploy web --replicas=0` 으로 개수를 0 으로 줄인다", "`kubectl get deploy web` 이 `0/0` 이고 Pod 가 없는지 확인한다", "`kubectl scale deploy web --replicas=2` 로 개수를 다시 올린다", "`kubectl get deploy web` 이 `2/2` 가 되는지 확인한다"]', NULL, 'Deployment 를 지운 것이 아니므로 설정은 그대로 남아 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 205, 29, 'Pod 변화 지켜보기', 'Pod 상태가 바뀌는 것을 지켜보는 순서입니다. 순서에 맞게 놓아 보세요.', '지켜보기 시작 → 새 Pod 만들기 → 변화 확인 → 끝내기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pod -n dev -w` 로 목록을 출력하고 기다린다", "다른 터미널에서 `kubectl run w1 -n dev --image=busybox:1.36 --restart=Never -- echo done` 으로 Pod 를 만든다", "`w1` 이 `Pending`, `ContainerCreating`, `Completed` 로 바뀌며 줄이 추가되는지 본다", "`Ctrl+C` 로 `-w` 를 끝낸다"]', NULL, '`Completed` 는 명령이 정상적으로 끝난 Pod 의 상태입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 205 AND order_index = 29);
