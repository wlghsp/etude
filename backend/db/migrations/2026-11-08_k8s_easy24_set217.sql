-- k8s 세트 217. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set217.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 217, 'Deployment 와 ReplicaSet: 파드 이름, 소유 관계, 재생성, 직접 scale, 라벨 떼기, cascade, set image, restart, 이력', 'Deployment 가 ReplicaSet 을 거쳐 파드를 관리하는 방식을 한 개념씩 반복합니다. 파드 이름에 붙는 해시, get rs 의 열, create deployment 의 기본값, ownerReferences 로 이어지는 소유 관계, 파드나 ReplicaSet 을 지웠을 때의 재생성, ReplicaSet 을 직접 scale 했을 때 되돌아가는 동작, 파드의 라벨을 떼면 생기는 일, scale 0 의 결과, delete 와 --cascade=orphan 의 차이, set image 와 rollout restart 가 만드는 새 ReplicaSet, CHANGE-CAUSE 어노테이션, 셀렉터를 바꿀 수 없다는 점을 짧은 객관식·빈칸·순서 문제로 익히고, 파드가 되살아나는 과정, 새 이미지로 롤아웃, 이력과 변경 사유, 삭제 방식 비교의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 217);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🪄' WHERE id = 217;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 1, '파드 이름의 모양', '`kubectl create deployment web --image=...` 로 만든 Deployment 의 파드 이름은 어떤 모양일까요?', '이름에서 소속을 읽을 수 있어요.', NULL, NULL, '[]', 'choice', '["`web-0`, `web-1` 처럼 0 부터 이어지는 번호가 붙는다", "`web` 이라는 같은 이름이 모든 파드에 그대로 붙는다", "`web-` 뒤에 ReplicaSet 해시와 임의 문자가 붙는다", "`web-` 뒤에 파드가 만들어진 시각이 붙는다"]', 2, '가운데 해시는 ReplicaSet 이름에도 들어 있고, 파드의 `pod-template-hash` 라벨 값과 같습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 2, 'get rs 의 열', '`kubectl get rs` 는 어떤 열을 보여 줄까요?', '개수를 비교하는 열이에요.', NULL, NULL, '[]', 'choice', '["`NAME`, `STATUS`, `RESTARTS` 열로 파드의 재시작 횟수를 보여 준다", "`DESIRED`, `CURRENT`, `READY` 열로 원하는 개수와 현재 개수를 보여 준다", "`REVISION`, `CHANGE-CAUSE` 열로 배포 이력을 한 줄씩 보여 준다", "`TYPE`, `CLUSTER-IP`, `PORT(S)` 열로 서비스의 주소를 보여 준다"]', 1, '`kubectl get deploy` 는 `READY`, `UP-TO-DATE`, `AVAILABLE` 열을 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 3, 'create deployment 의 기본값', '`kubectl create deployment web --image=nginx` 로 만든 Deployment 의 복제본 수와 선택하는 라벨은 무엇일까요?', '옵션을 주지 않았을 때의 값이에요.', NULL, NULL, '[]', 'choice', '["복제본은 1개이고 `app=web` 라벨로 파드를 고른다", "복제본은 3개이고 `app=web` 라벨로 파드를 고른다", "복제본은 1개이고 `name=web` 라벨로 파드를 고른다", "복제본은 0개이고 라벨 없이 이름으로 파드를 고른다"]', 0, '`--replicas=2` 처럼 만들 때 개수를 정할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 4, '소유 관계', 'Deployment 가 만든 파드의 `ownerReferences` 는 누구를 가리킬까요? 그 소유자의 소유자는요?', '소유 관계가 사슬로 이어져요.', NULL, NULL, '[]', 'choice', '["파드의 소유자는 Deployment 이고 ReplicaSet 은 따로 소유자가 없이 독립적으로 존재한다", "파드의 소유자는 노드이고 노드의 소유자는 클러스터이다", "파드는 소유자가 없고 ReplicaSet 만 Deployment 가 소유하며 파드는 네임스페이스에 속한다", "파드의 소유자는 ReplicaSet 이고 ReplicaSet 의 소유자는 Deployment 이다"]', 3, '소유 관계 덕분에 Deployment 를 지우면 ReplicaSet 과 파드도 함께 지워집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 5, '파드를 지우면', 'Deployment 의 파드 하나를 `kubectl delete pod` 로 지우면 어떻게 될까요?', '개수를 맞추는 쪽이 누구일까요?', NULL, NULL, '[]', 'choice', '["지운 파드와 같은 이름의 파드가 같은 노드의 같은 자리에 그대로 다시 만들어진다", "Deployment 의 복제본 수가 하나 줄어들고 지운 파드는 다시 만들어지지 않는다", "ReplicaSet 이 개수를 맞추려고 이름이 다른 새 파드를 만든다", "새 파드는 만들어지지 않고 ReplicaSet 이 함께 지워진다"]', 2, '그래서 파드를 지우는 것은 개수를 줄이는 방법이 아니고 `scale` 을 써야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 6, 'ReplicaSet 을 지우면', 'Deployment 가 관리하는 ReplicaSet 을 `kubectl delete rs` 로 지우면 어떻게 될까요?', 'Deployment 가 원하는 상태를 지켜요.', NULL, NULL, '[]', 'choice', '["Deployment 도 함께 지워져서 파드와 ReplicaSet 이 아무것도 남지 않고 사라진다", "Deployment 가 같은 이름의 ReplicaSet 을 다시 만들고 파드도 새로 만들어진다", "ReplicaSet 은 다시 만들어지지 않고 이미 있던 파드만 소유자 없이 그대로 남는다", "Deployment 의 복제본 수가 0 으로 바뀌어 파드가 없어진다"]', 1, 'ReplicaSet 이름의 해시는 파드 템플릿이 같으면 같게 계산됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 7, 'ReplicaSet 을 직접 scale 하면', 'Deployment 의 ReplicaSet 을 `kubectl scale rs ... --replicas=3` 으로 직접 늘리면 어떻게 될까요?', '원하는 개수를 정하는 쪽은 Deployment 예요.', NULL, NULL, '[]', 'choice', '["Deployment 가 원래 복제본 수로 되돌려서 얼마 뒤 다시 줄어든다", "Deployment 의 복제본 수도 3 으로 바뀌어 그대로 유지된다", "ReplicaSet 이 삭제되고 새 ReplicaSet 이 3개 만들어진다", "명령이 오류로 거부되어 개수가 전혀 바뀌지 않는다"]', 0, '개수를 바꿀 때는 Deployment 에 `kubectl scale deploy` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 8, '파드의 라벨을 떼면', 'Deployment 의 파드 하나에서 `kubectl label pod 이름 app-` 으로 `app` 라벨을 떼면 어떻게 될까요?', 'ReplicaSet 은 라벨로 파드를 세요.', NULL, NULL, '[]', 'choice', '["라벨을 뗀 파드가 즉시 지워지고 같은 이름으로 같은 노드에 다시 만들어진다", "아무 일도 일어나지 않고 파드는 그대로 ReplicaSet 이 관리한다", "Deployment 가 오류를 내며 모든 파드를 한꺼번에 지우고 처음부터 다시 만든다", "ReplicaSet 이 새 파드를 만들고 라벨을 뗀 파드는 소유자 없이 남는다"]', 3, '라벨을 뗀 파드는 따로 남아서 조사할 수 있어서 디버깅에 쓰기도 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 9, 'scale 을 0 으로', '`kubectl scale deploy web --replicas=0` 을 하면 무엇이 남을까요?', '개수만 0 이 돼요.', NULL, NULL, '[]', 'choice', '["Deployment 도 함께 지워져서 `kubectl get deploy` 에 나오지 않는다", "파드는 `Pending` 상태로 모두 남아 자원을 계속 쓴다", "파드는 모두 지워지고 Deployment 와 ReplicaSet 은 `0/0` 으로 남는다", "ReplicaSet 만 지워지고 Deployment 는 `Pending` 이 된다"]', 2, '다시 `--replicas=1` 로 늘리면 같은 ReplicaSet 이 파드를 만듭니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 10, 'Deployment 를 지우면', '`kubectl delete deploy web` 은 ReplicaSet 과 파드를 어떻게 할까요? `--cascade=orphan` 을 붙이면요?', '소유 관계를 따라가요.', NULL, NULL, '[]', 'choice', '["파드만 지우고 ReplicaSet 은 남기며, `--cascade=orphan` 이면 ReplicaSet 도 함께 지운다", "함께 지우고, `--cascade=orphan` 이면 ReplicaSet 과 파드가 그대로 남는다", "ReplicaSet 과 파드를 그대로 남기고, `--cascade=orphan` 이면 파드까지 모두 지운다", "항상 둘 다 함께 지우고 `--cascade` 값은 영향이 없다"]', 1, '남은 ReplicaSet 과 파드는 소유자 없이 남아서 직접 지워야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 11, 'set image', '`kubectl set image deploy/web nginx=nginx:1.26-alpine` 을 하면 ReplicaSet 은 어떻게 바뀔까요?', '템플릿이 바뀌면 새 ReplicaSet 이 필요해요.', NULL, NULL, '[]', 'choice', '["새 ReplicaSet 이 만들어지고 이전 ReplicaSet 은 0개로 남는다", "기존 ReplicaSet 의 파드가 재시작 없이 그 자리에서 이미지만 바뀐다", "이전 ReplicaSet 이 즉시 삭제되고 새 ReplicaSet 하나만 남게 된다", "ReplicaSet 은 그대로이고 Deployment 만 새로 만들어진다"]', 0, '이전 ReplicaSet 이 남아 있기 때문에 `rollout undo` 로 되돌릴 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 12, 'rollout restart', '이미지를 바꾸지 않고 `kubectl rollout restart deploy/web` 을 하면 ReplicaSet 은 어떻게 될까요?', '재시작도 롤아웃의 한 가지예요.', NULL, NULL, '[]', 'choice', '["기존 파드가 재시작될 뿐 ReplicaSet 은 하나로 그대로이다", "이미지가 같아서 아무 일도 일어나지 않고 명령만 성공한다", "모든 파드가 동시에 지워지고 같은 ReplicaSet 이 다시 만든다", "새 ReplicaSet 이 만들어지고 파드가 하나씩 새것으로 바뀐다"]', 3, '재시작할 때마다 이력의 `REVISION` 번호가 하나 늘어납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 13, 'CHANGE-CAUSE', '`kubectl rollout history deploy/web` 의 `CHANGE-CAUSE` 는 기본으로 무엇이고, 어떻게 채울까요?', '배포한 이유를 적는 열이에요.', NULL, NULL, '[]', 'choice', '["기본은 실행한 명령 전체이고 `kubectl rollout history --message` 옵션으로 바꿀 수 있다", "기본은 새로 배포한 이미지 이름이고 `rollout history --reason` 옵션으로 바꾼다", "기본은 `<none>` 이고 `kubernetes.io/change-cause` 어노테이션으로 채운다", "기본은 배포한 사용자이고 `kubectl config` 로 바꾼다"]', 2, '어노테이션을 단 뒤 다시 보면 최신 `REVISION` 줄에 적은 사유가 나타납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 14, '셀렉터는 바꿀 수 없다', '이미 만든 Deployment 의 `spec.selector.matchLabels` 를 `kubectl patch` 로 다른 값으로 바꾸면 어떻게 될까요?', '한 번 정하면 못 바꾸는 필드가 있어요.', NULL, NULL, '[]', 'choice', '["오류 없이 바뀌고 파드가 새 라벨을 달고 모두 다시 만들어진다", "`field is immutable` 오류로 거부되어 바뀌지 않는다", "바뀌지만 기존 ReplicaSet 은 이전 셀렉터를 계속 쓰면서 공존한다", "`Pending` 상태가 되어 다음 롤아웃 때 적용된다"]', 1, '셀렉터를 바꾸려면 Deployment 를 지우고 새로 만들어야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 15, 'ReplicaSet 목록', 'ReplicaSet 목록을 보는 `kubectl get` 의 **짧은 리소스 이름**을 채우세요.', '"ReplicaSet" 의 두 글자 줄임이에요.', NULL, NULL, '[]', 'fill', '["rep", "rset", "rsets", "rs"]', NULL, '`DESIRED`, `CURRENT`, `READY` 열이 나옵니다.', '[3]', 'kubectl get {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 16, '복제본 수 바꾸기', 'Deployment 의 **복제본 수를 바꾸는** 하위 명령을 채우세요.', '"크기를 조절한다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["scale", "resize", "replicas", "expand"]', NULL, '`--replicas=0` 이면 파드가 모두 사라집니다.', '[0]', 'kubectl {0} deploy web --replicas=3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 17, '이미지 바꾸기', '`kubectl set` 아래에서 **컨테이너 이미지를 바꾸는** 하위 명령을 채우세요.', '"이미지"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["container", "image", "tag", "version"]', NULL, '새 ReplicaSet 이 만들어집니다.', '[1]', 'kubectl set {0} deploy/web nginx=nginx:1.26-alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 18, '롤아웃 다시 시작', '`kubectl rollout` 아래에서 **파드를 새것으로 바꾸며 다시 시작하는** 하위 명령을 채우세요.', '"다시 시작"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["reload", "redo", "restart", "reset"]', NULL, '이미지가 같아도 새 ReplicaSet 이 만들어집니다.', '[2]', 'kubectl rollout {0} deploy/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 19, '롤아웃 이력', '`kubectl rollout` 아래에서 **지난 버전 목록을 보여 주는** 하위 명령을 채우세요.', '"역사"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["log", "revisions", "list", "history"]', NULL, '`REVISION` 과 `CHANGE-CAUSE` 열이 나옵니다.', '[3]', 'kubectl rollout {0} deploy/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 20, '직전 버전으로', '`kubectl rollout` 아래에서 **이전 버전으로 되돌리는** 하위 명령을 채우세요.', '"되돌리다, 취소하다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["undo", "back", "revert", "rewind"]', NULL, '이전 ReplicaSet 이 남아 있어서 가능합니다.', '[0]', 'kubectl rollout {0} deploy/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 21, '롤아웃 진행 확인', '`kubectl rollout` 아래에서 **롤아웃이 끝났는지 기다리며 보여 주는** 하위 명령을 채우세요.', '"상태"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["watch", "status", "wait", "progress"]', NULL, '끝나면 `successfully rolled out` 이 나옵니다.', '[1]', 'kubectl rollout {0} deploy/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 22, '소유자 없이 남기기', '`kubectl delete deploy` 가 **ReplicaSet 과 파드를 지우지 않고 남기게** 하는 `--cascade` 값을 채우세요.', '"고아"를 영어로 써요.', NULL, NULL, '[]', 'fill', '["keep", "none", "orphan", "skip"]', NULL, '남은 것은 직접 지워야 합니다.', '[2]', 'kubectl delete deploy web --cascade={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 23, '라벨 떼기', '`kubectl label` 에서 **`app` 라벨을 떼려면** 키 뒤에 붙일 기호를 채우세요.', '빼기를 뜻하는 기호예요.', NULL, NULL, '[]', 'fill', '["=", "!", "~", "-"]', NULL, '라벨을 뗀 파드는 ReplicaSet 의 관리에서 빠집니다.', '[3]', 'kubectl label pod web-abc app{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 24, '변경 사유 적기', '롤아웃 이력의 `CHANGE-CAUSE` 를 채우는 **어노테이션 키의 끝부분**을 채우세요.', '"변경의 원인"을 영어로 이어 써요.', NULL, NULL, '[]', 'fill', '["change-cause", "reason", "comment", "note"]', NULL, '`rollout history` 에 적은 사유가 나타납니다.', '[0]', 'kubectl annotate deploy/web kubernetes.io/{0}="bump"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 25, '한 버전만 자세히', '`kubectl rollout history` 에서 **특정 번호의 버전을 자세히 보는** 옵션 이름을 채우세요.', '"개정판 번호"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["version", "revision", "rev-no", "step"]', NULL, '그 버전의 이미지 같은 템플릿이 나옵니다.', '[1]', 'kubectl rollout history deploy/web --{0}=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 26, '파드가 되살아나는 과정', 'Deployment 의 파드를 지웠을 때 다시 만들어지는 것을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → rs 확인 → 지우기 → 새 이름 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 이름이 다른 새 파드가 만들어졌는지 확인한다", "`kubectl delete pod` 로 그 파드를 지운다", "`kubectl create deployment web --image=nginx:1.27-alpine` 으로 Deployment 를 만든다", "`kubectl get rs` 로 `DESIRED` 와 `CURRENT` 가 `1` 인지 확인한다"]', NULL, 'ReplicaSet 의 개수는 그대로 `1` 입니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 27, '새 이미지로 롤아웃', '이미지를 바꿔 새 ReplicaSet 으로 넘어가는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 바꾸기 → 기다리기 → rs 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl rollout status deploy/web` 으로 롤아웃이 끝날 때까지 기다린다", "`kubectl get rs` 로 이전 ReplicaSet 이 `0`, 새 ReplicaSet 이 `1` 인지 확인한다", "`kubectl set image deploy/web nginx=nginx:1.26-alpine` 으로 이미지를 바꾼다", "`kubectl create deployment web --image=nginx:1.27-alpine` 으로 Deployment 를 만든다"]', NULL, '이전 ReplicaSet 은 되돌릴 때 쓰려고 남아 있습니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 28, '이력과 변경 사유', '롤아웃 이력에 변경 사유를 남기는 순서입니다. 순서에 맞게 놓아 보세요.', '버전 만들기 → 이력 → 어노테이션 → 다시 이력 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl annotate deploy/web kubernetes.io/change-cause=\\"bump\\"` 로 사유를 적는다", "Deployment 를 만들고 `kubectl set image` 로 이미지를 바꿔 새 `REVISION` 을 만든다", "`kubectl rollout history deploy/web` 에 적은 사유가 보이는지 다시 확인한다", "`kubectl rollout history deploy/web` 에서 `CHANGE-CAUSE` 가 `<none>` 인지 본다"]', NULL, '사유는 가장 최근 `REVISION` 줄에 나타납니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 217, 29, '삭제 방식 비교', 'Deployment 를 소유자 없이 지워 보는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → orphan 삭제 → 남은 것 확인 → 직접 정리 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl delete deploy w2 --cascade=orphan` 으로 Deployment 만 지운다", "남은 ReplicaSet 을 `kubectl delete rs` 로 지우고 파드도 정리되는지 확인한다", "`kubectl create deployment w2 --image=nginx:1.27-alpine --replicas=2` 로 Deployment 를 만든다", "`kubectl get rs,pods` 로 ReplicaSet 과 파드 두 개가 남아 있는지 확인한다"]', NULL, '일반 삭제라면 마지막 단계가 필요 없습니다.', '[2, 0, 3, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 217 AND order_index = 29);
