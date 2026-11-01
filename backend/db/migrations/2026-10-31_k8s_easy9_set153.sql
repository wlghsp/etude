-- k8s 세트 153. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set153.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 153, '자원 한도(Quota), 컨테이너 보안 기본, ServiceAccount, 비공개 이미지 한 줄씩', '여러 사람이 쓰는 클러스터를 안전하게 운영하는 기본기를 한 개념씩 쉬운 문제로 반복합니다. ResourceQuota 와 exceeded quota 오류, must specify requests 오류와 LimitRange 의 기본값, Quota 와 LimitRange 의 차이, securityContext 의 runAsNonRoot·runAsUser·readOnlyRootFilesystem, ServiceAccount 와 토큰 마운트 끄기, imagePullSecrets 와 ImagePullBackOff 를 짧은 객관식·빈칸·순서 문제로 익히고, quota 거부 조사, requests 오류 풀기, root 이미지 보안 적용, 비공개 레지스트리 이미지 쓰기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 153);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🛂' WHERE id = 153;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 1, 'ResourceQuota 란', '네임스페이스에 `ResourceQuota` 를 만들면 무엇이 정해질까요?', '네임스페이스 전체가 쓸 수 있는 몫이에요.', NULL, NULL, '[]', 'choice', '["Pod 한 개가 쓸 수 있는 CPU 의 상한", "클러스터 전체의 노드 개수", "그 네임스페이스 전체가 쓸 수 있는 총량(Pod 개수, CPU, 메모리 등)의 상한", "Pod 의 이미지 크기의 상한"]', 2, '여러 팀이 한 클러스터를 나눠 쓸 때 한 팀이 자원을 독차지하지 못하게 합니다. Pod 하나하나의 범위는 `LimitRange` 가 정해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 2, 'quota 를 넘으면', '`pods: "2"` 로 제한된 네임스페이스에 이미 Pod 가 2개 있습니다. 세 번째 Pod 를 만들면 어떻게 될까요?', '이미 있는 것은 건드리지 않고 새 것만 막아요.', NULL, NULL, '[]', 'choice', '["가장 오래된 Pod 가 자동으로 삭제된다", "`exceeded quota` 오류(Forbidden)로 새 Pod 의 생성이 거부된다. 이미 있는 Pod 는 그대로 둔다", "세 번째 Pod 가 Pending 으로 만들어진다", "제한이 자동으로 늘어난다"]', 1, '오류 메시지에 `requested`, `used`, `limited` 가 나와서 얼마나 넘었는지 알 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 3, 'quota 사용량 보기', 'ResourceQuota 로 제한된 네임스페이스에서 사용량과 한도를 한눈에 보려면 어떻게 할까요?', 'describe 로 자세히 봐요.', NULL, NULL, '[]', 'choice', '["`kubectl describe quota 이름` 의 Used 와 Hard 열", "`kubectl get pods` 의 STATUS 열", "`kubectl top nodes`", "`kubectl logs quota`"]', 0, '`Used` 가 현재 사용량, `Hard` 가 한도입니다. 새 Pod 를 만들기 전에 여유가 있는지 확인할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 4, 'quota 와 requests', '네임스페이스에 `requests.cpu` 를 제한하는 ResourceQuota 가 있을 때, CPU requests 를 적지 않은 Pod 를 만들면 어떻게 될까요?', '사용량을 계산하려면 requests 가 있어야 해요.', NULL, NULL, '[]', 'choice', '["requests 가 0 으로 계산되어 통과한다", "Pod 가 Pending 으로 만들어진다", "쿼터가 자동으로 꺼진다", "`must specify requests.cpu` 오류로 거부된다. Pod 에 requests 를 적거나 `LimitRange` 로 기본값을 줘야 한다"]', 3, '사용량을 계산할 수 없으니 막는 것입니다. 그래서 쿼터와 LimitRange 를 함께 쓰는 경우가 흔해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 5, 'LimitRange 란', '`LimitRange` 는 무엇을 정할까요?', '컨테이너 하나하나에 대한 규칙이에요.', NULL, NULL, '[]', 'choice', '["네임스페이스 전체의 총량", "노드의 CPU 개수", "네임스페이스의 컨테이너에 대한 기본값과 최소·최대 범위 (적지 않으면 기본값이 채워진다)", "이미지를 받아 올 수 있는 레지스트리"]', 2, '기본값이 정해져 있으면 requests 를 적지 않은 Pod 도 기본 requests 와 limits 가 자동으로 채워집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 6, 'Quota 와 LimitRange', 'ResourceQuota 와 LimitRange 의 차이로 알맞은 것은 무엇일까요?', '하나는 합계, 하나는 개별 범위예요.', NULL, NULL, '[]', 'choice', '["둘은 같은 것이다", "ResourceQuota 는 네임스페이스 전체의 총량을, LimitRange 는 컨테이너 하나의 기본값과 범위를 정한다", "ResourceQuota 는 컨테이너 하나, LimitRange 는 네임스페이스 전체를 정한다", "둘 다 노드에 적용된다"]', 1, '쿼터가 "네임스페이스에 총 몇 개"라면 LimitRange 는 "컨테이너 하나는 얼마부터 얼마까지"입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 7, 'securityContext 란', 'Pod 나 컨테이너의 `securityContext` 는 무엇을 정할까요?', '실행 권한과 관련된 설정이에요.', NULL, NULL, '[]', 'choice', '["컨테이너를 어떤 사용자로 실행할지, 파일 시스템을 읽기 전용으로 할지 같은 보안 설정", "컨테이너의 CPU 사용량", "컨테이너의 이미지 이름", "컨테이너가 접속할 포트"]', 0, '기본은 이미지에 정해진 사용자(보통 root)로 실행됩니다. 피해 범위를 줄이려면 securityContext 로 권한을 낮추세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 8, 'runAsNonRoot', '`securityContext` 에 `runAsNonRoot: true` 를 쓰고, root 로 실행되는 이미지를 쓰면 어떻게 될까요?', '"root 가 아니어야 한다"고 못 박았어요.', NULL, NULL, '[]', 'choice', '["자동으로 일반 사용자로 바뀌어 실행된다", "경고만 나오고 정상 실행된다", "Pod 가 삭제된다", "컨테이너가 시작되지 않고 `CreateContainerConfigError`(container has runAsNonRoot and image will run as root)가 난다"]', 3, '`runAsUser: 1000` 처럼 사용자를 직접 정하거나, 이미지에서 `USER` 를 지정해 해결합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 9, 'runAsUser', '`securityContext` 의 `runAsUser: 1000` 은 무엇을 뜻할까요?', '숫자는 사용자 ID 예요.', NULL, NULL, '[]', 'choice', '["컨테이너를 1000번 재시작한다", "1000MB 까지 쓸 수 있게 한다", "컨테이너의 프로세스를 UID 1000 인 사용자로 실행한다", "사용자를 1000명까지 허용한다"]', 2, 'UID 0 은 root 이므로 0 이 아닌 값을 쓰면 일반 사용자로 실행됩니다. 컨테이너 안에서 `id -u` 로 확인할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 10, 'readOnlyRootFilesystem', '`readOnlyRootFilesystem: true` 인 컨테이너 안에서 `touch /x` 를 하면 어떻게 될까요?', '파일 시스템을 읽기 전용으로 만들었어요.', NULL, NULL, '[]', 'choice', '["정상적으로 파일이 만들어진다", "`Read-only file system` 오류가 난다. 써야 하는 곳은 볼륨(`emptyDir` 등)으로 따로 마련한다", "컨테이너가 재시작된다", "Pod 가 삭제된다"]', 1, '공격자가 파일을 심기 어렵게 만드는 효과가 있습니다. 앱이 `/tmp` 등에 써야 한다면 그 경로만 볼륨으로 열어 주세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 11, 'ServiceAccount 란', 'ServiceAccount 는 무엇일까요?', 'Pod 가 API 서버에 말을 걸 때의 신원이에요.', NULL, NULL, '[]', 'choice', '["Pod 가 쿠버네티스 API 서버에 접근할 때 쓰는 신원(계정). 네임스페이스마다 `default` 가 기본으로 있다", "사람이 kubectl 로 로그인하는 계정", "컨테이너 이미지를 받는 계정", "Service 의 이름"]', 0, 'Pod 에 `serviceAccountName` 을 적지 않으면 `default` 를 씁니다. 권한은 RBAC(Role, RoleBinding)으로 따로 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 12, 'ServiceAccount 토큰', '특별히 설정하지 않은 Pod 안에는 어디에 ServiceAccount 토큰이 있을까요?', '표준 경로에 파일로 놓여요.', NULL, NULL, '[]', 'choice', '["환경 변수 `TOKEN` 에만 들어 있다", "노드의 `/etc` 에만 있다", "아무 데도 없다", "`/var/run/secrets/kubernetes.io/serviceaccount` 에 `token`, `ca.crt`, `namespace` 파일로 마운트된다. 필요 없으면 `automountServiceAccountToken: false` 로 끈다"]', 3, 'API 서버를 쓰지 않는 앱에는 토큰이 필요 없으니 끄는 것이 안전합니다. 토큰이 노출되면 그 ServiceAccount 의 권한이 노출됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 13, 'imagePullSecrets', '비공개 레지스트리의 이미지를 쓰는 Pod 에 `imagePullSecrets` 를 적는 이유는 무엇일까요?', '이미지를 받아 올 때 쓸 로그인 정보예요.', NULL, NULL, '[]', 'choice', '["컨테이너의 비밀번호를 정하려고", "이미지를 암호화하려고", "이미지를 받아 올 때 쓸 레지스트리 인증 정보(Secret)를 가리키려고", "Pod 의 네트워크를 막으려고"]', 2, '`kubectl create secret docker-registry` 로 만든 Secret(타입 `kubernetes.io/dockerconfigjson`)을 가리킵니다. 같은 네임스페이스에 있어야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 14, '인증이 없으면', '비공개 레지스트리의 이미지를 쓰는데 `imagePullSecrets` 가 없거나 틀리면 Pod 는 어떻게 될까요?', '이미지를 받아 오지 못해요.', NULL, NULL, '[]', 'choice', '["컨테이너가 일반 사용자로 시작된다", "`ErrImagePull` 후 `ImagePullBackOff` 가 되고, `describe` 의 이벤트에 이유가 나온다", "이미지가 자동으로 공개로 바뀐다", "Pod 가 즉시 삭제된다"]', 1, '이벤트에서 `unauthorized`, `not found`, `no such host` 중 무엇인지 보면 이름 문제인지 인증 문제인지 구분됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 15, '쿼터 리소스', '네임스페이스의 **총량을 제한**하는 리소스 종류를 채우세요.', '"자원"과 "몫"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["ResourceQuota", "LimitQuota", "NamespaceQuota", "QuotaLimit"]', NULL, '`spec.hard` 아래에 `pods`, `requests.cpu`, `limits.memory` 같은 상한을 적습니다.', '[0]', 'kind: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 16, '쿼터 사용량 보기', '`ResourceQuota` `q` 의 **사용량과 한도**를 보는 명령입니다. 대상 이름을 채우세요.', '리소스 종류의 줄임 이름이에요.', NULL, NULL, '[]', 'fill', '["quota", "limit", "usage", "budget"]', NULL, '`Used` 와 `Hard` 를 비교합니다. 자원이 부족하다고 거부되면 먼저 이것부터 확인하세요.', '[0]', 'kubectl describe {0} q', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 17, '컨테이너 기본값 리소스', '컨테이너의 **기본값과 범위**를 정하는 리소스 종류를 채우세요.', '"한계"와 "범위"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["LimitRange", "RangeLimit", "DefaultRange", "ContainerLimit"]', NULL, '`type: Container` 아래에 `default`(limits 기본), `defaultRequest`(requests 기본), `min`, `max` 를 적습니다.', '[0]', 'kind: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 18, 'root 로 실행 금지', '컨테이너가 **root 로 실행되면 시작하지 못하게** 하는 설정 키를 채우세요.', '"root 가 아닌 사용자로 실행"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["runAsNonRoot", "noRoot", "rootless", "denyRoot"]', NULL, '이미지가 root 로 도는 경우 이 설정만 켜면 시작이 거부됩니다. `runAsUser` 도 함께 지정하세요.', '[0]', '{0}: true', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 19, '실행 사용자 번호', '컨테이너를 root 가 아닌 **일반 사용자**로 실행하려고 합니다. UID 를 채우세요.', '0 은 root 예요.', NULL, NULL, '[]', 'fill', '["1000", "root", "0", "-1"]', NULL, '`0` 은 root 이므로 일반 사용자는 0 이 아닌 숫자를 씁니다. 이미지 안에 해당 UID 의 사용자가 없어도 실행은 됩니다.', '[0]', 'runAsUser: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 20, '파일 시스템 읽기 전용', '컨테이너의 **파일 시스템을 읽기 전용**으로 만드는 설정 키를 채우세요.', '"루트 파일 시스템"을 "읽기 전용"으로 이어 붙여요.', NULL, NULL, '[]', 'fill', '["readOnlyRootFilesystem", "readOnly", "noWrite", "rootReadOnly"]', NULL, '앱이 쓸 곳(`/tmp` 등)은 `emptyDir` 볼륨을 마운트해 열어 주면 됩니다.', '[0]', '{0}: true', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 21, 'ServiceAccount 만들기', 'ServiceAccount `app-sa` 를 **만드는** 명령입니다. 대상 이름을 채우세요.', '리소스 종류의 전체 이름이에요.', NULL, NULL, '[]', 'fill', '["serviceaccount", "account", "user", "identity"]', NULL, '줄임 이름 `sa` 도 쓸 수 있습니다. 만든 뒤에는 Pod 의 `serviceAccountName` 에 적어 사용해요.', '[0]', 'kubectl create {0} app-sa', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 22, 'Pod 에 ServiceAccount 지정', 'Pod 가 **`app-sa`** ServiceAccount 를 쓰도록 값을 채우세요.', '앞에서 만든 이름이에요.', NULL, NULL, '[]', 'fill', '["app-sa", "serviceAccount", "sa:app", "app.sa"]', NULL, '적지 않으면 `default` 를 씁니다. 용도별로 ServiceAccount 를 나누고 필요한 권한만 주는 것이 좋아요.', '[0]', 'serviceAccountName: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 23, '토큰 마운트 끄기', 'API 서버를 쓰지 않는 Pod 에서 **토큰 자동 마운트를 끄는** 값을 채우세요.', '"참"의 반대예요.', NULL, NULL, '[]', 'fill', '["false", "nil", "disable", "never"]', NULL, '끄면 `/var/run/secrets/kubernetes.io/serviceaccount` 가 만들어지지 않습니다. 쓰지 않는 권한은 없애는 것이 기본이에요.', '[0]', 'automountServiceAccountToken: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 24, '레지스트리 Secret 만들기', '비공개 레지스트리 인증용 Secret 을 만드는 **종류**를 채우세요.', '"도커 레지스트리"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["docker-registry", "registry", "image-pull", "generic"]', NULL, '이렇게 만든 Secret 의 타입은 `kubernetes.io/dockerconfigjson` 입니다. 비밀번호는 명령 기록에 남지 않게 주의하세요.', '[0]', 'kubectl create secret {0} reg --docker-server=레지스트리주소 --docker-username=u --docker-password=p', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 25, 'Pod 에서 Secret 사용하기', 'Pod 스펙에서 이미지를 받아 올 때 쓸 **Secret 을 지정하는** 키를 채우세요.', '"이미지를 끌어오는 비밀"을 뜻해요.', NULL, NULL, '[]', 'fill', '["imagePullSecrets", "pullSecrets", "registrySecrets", "imageSecrets"]', NULL, '`- name: reg` 처럼 Secret 이름을 목록으로 적습니다. 같은 네임스페이스의 Secret 만 쓸 수 있어요.', '[0]', '{0}:', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 26, 'quota 때문에 Pod 가 안 만들어질 때', 'Pod 생성이 `exceeded quota` 로 거부될 때의 조사 순서입니다. 순서에 맞게 놓아 보세요.', '오류 읽기 → 사용량 확인 → 정리·조정 → 다시 만들기 순서예요.', NULL, NULL, '[]', 'order', '["오류 메시지의 `requested`, `used`, `limited` 를 읽는다", "`kubectl describe quota` 로 Used 와 Hard 를 확인한다", "필요 없는 Pod 를 정리하거나 quota 상향을 요청한다", "Pod 를 다시 만들어 보고 성공하는지 확인한다"]', NULL, '쿼터는 관리자가 정한 정책이므로 임의로 지우지 말고 필요한 만큼의 상향을 요청하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 27, 'requests 때문에 거부될 때', '`must specify requests.cpu` 오류가 났을 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '오류 → 원인 → 고치기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["오류 메시지 `must specify requests.cpu` 를 읽는다", "네임스페이스에 requests 를 제한하는 ResourceQuota 가 있음을 파악한다", "Pod 에 `resources.requests` 를 적거나 `LimitRange` 로 기본값을 만든다", "다시 적용하고 `describe quota` 로 사용량이 올라간 것을 확인한다"]', NULL, '기본값은 LimitRange 로 한 번에 주는 편이 모든 Pod 에 일일이 적는 것보다 실수가 적어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 28, 'root 이미지를 안전하게 쓰기', 'root 로 도는 이미지에 보안 설정을 적용했다가 막혔을 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '설정 → 오류 확인 → 원인 → 고치기 순서예요.', NULL, NULL, '[]', 'order', '["`securityContext` 에 `runAsNonRoot: true` 를 넣고 적용한다", "Pod 가 `CreateContainerConfigError` 인 것을 확인하고 `describe` 의 이벤트를 읽는다", "이미지가 root 로 실행되도록 만들어진 것이 원인임을 파악한다", "`runAsUser: 1000` 을 지정하거나 이미지에 `USER` 를 넣어 다시 배포한다"]', NULL, '권한을 낮추면 앱이 쓰기 권한이 없는 폴더에서 실패할 수 있으니 로그도 함께 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 153, 29, '비공개 레지스트리 이미지 쓰기', '비공개 레지스트리의 이미지를 Pod 가 받아 오게 하는 순서입니다. 순서에 맞게 놓아 보세요.', 'Secret 만들기 → Pod 에 지정 → 적용 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create secret docker-registry` 로 인증 정보 Secret 을 만든다", "Pod 스펙에 `imagePullSecrets` 로 그 Secret 을 지정한다", "`kubectl apply -f` 로 적용한다", "`ImagePullBackOff` 라면 `describe` 의 이벤트에서 이유를 확인한다"]', NULL, 'Secret 은 Pod 와 같은 네임스페이스에 있어야 합니다. 이름 오타와 인증 실패는 이벤트 문구로 구분돼요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 153 AND order_index = 29);
