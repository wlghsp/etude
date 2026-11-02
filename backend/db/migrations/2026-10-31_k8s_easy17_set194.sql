-- k8s 세트 194. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set194.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 194, '롤아웃 제어와 설정 주입: pause·resume, set env, undo, 진행 기한, envFrom, Downward API, finalizer, replace', 'Deployment 롤아웃과 설정 주입의 동작을 한 개념씩 반복합니다. rollout pause 중의 변경이 롤아웃을 시작하지 않는 것과 resume 으로 한 번에 적용되는 것, pause·resume 오류, set env 가 롤아웃을 만드는 것과 이름 뒤 - 로 지우기, undo 가 리비전 번호를 새로 받는 것과 이전 기록이 없을 때의 오류, progressDeadlineSeconds 와 ProgressDeadlineExceeded, 기본 maxSurge·maxUnavailable, envFrom 과 env 의 우선순위와 prefix, fieldRef·resourceFieldRef 와 downwardAPI 볼륨, 없는 ConfigMap 참조와 optional, generateName 과 ownerReferences, finalizer 가 있는 삭제, replace 와 apply 의 차이, create·replace 오류를 짧은 객관식·빈칸·순서 문제로 익히고, 여러 변경을 한 번의 롤아웃으로, 실패한 롤아웃 복구하기, 환경 변수 주입 확인하기, 지워지지 않는 오브젝트 정리의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 194);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '⏯️' WHERE id = 194;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 1, 'rollout pause 중의 변경', '`kubectl rollout pause deploy/web` 으로 일시 중지한 뒤 `kubectl set image` 와 `kubectl set env` 를 하면 Pod 는 바로 새로 만들어질까요?', '변경은 저장되지만 롤아웃은 시작되지 않아요.', NULL, NULL, '[]', 'choice', '["두 변경마다 새 롤아웃이 바로 시작되어 리비전이 2개 늘어난다", "변경이 저장되지 않고 오류가 난다", "변경은 Deployment 에 저장되지만(`spec.paused` 가 `true`) 롤아웃은 시작되지 않아 리비전과 ReplicaSet 수가 그대로이고 `rollout status` 는 기다리다 시간 초과된다", "일시 중지 중에는 `set image` 를 쓸 수 없다"]', 2, '여러 설정을 고칠 때 롤아웃이 여러 번 일어나지 않게 하려고 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 2, 'rollout resume', '일시 중지 중에 이미지와 환경 변수를 바꾼 뒤 `kubectl rollout resume deploy/web` 을 하면 어떻게 될까요?', '쌓아 둔 변경을 한 번에 적용해요.', NULL, NULL, '[]', 'choice', '["변경마다 롤아웃이 따로 일어나 리비전이 2 늘어난다", "쌓아 둔 변경이 한 번의 롤아웃으로 적용되어 리비전이 1 에서 2 로 한 번만 늘고 새 이미지와 환경 변수가 함께 반영된다. 이미 중지된 것을 `pause` 하면 `is already paused`, 중지되지 않은 것을 `resume` 하면 `is not paused` 오류가 난다", "`resume` 은 변경을 취소하고 이전 상태로 돌린다", "이미 중지된 Deployment 를 `pause` 해도 오류 없이 조용히 넘어간다"]', 1, '`kubectl rollout restart` 도 중지된 Deployment 에는 `can''t restart paused deployment` 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 3, 'set env 와 롤아웃', '`kubectl set env deploy/web A=1 B=2` 를 하면 어떻게 될까요? 값을 지우거나 같은 값을 다시 설정하면요?', 'Pod 템플릿이 바뀌면 새 롤아웃이 생겨요.', NULL, NULL, '[]', 'choice', '["Pod 템플릿이 바뀌므로 새 롤아웃과 리비전이 생긴다. `kubectl set env deploy/web A-` 처럼 이름 뒤에 `-` 를 붙이면 변수를 지워 또 롤아웃이 일어나고, 이미 같은 값(`B=2`)을 다시 설정하면 바뀌는 것이 없어 새 리비전이 생기지 않는다", "환경 변수는 실행 중인 Pod 에 즉시 적용되어 롤아웃이 일어나지 않는다", "`A-` 는 `A` 를 빈 값으로 만든다", "같은 값을 다시 설정해도 항상 새 리비전이 생긴다"]', 0, '`kubectl set env deploy/web --list` 는 `# Deployment web, container c` 로 시작해 현재 변수를 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 4, 'undo 와 리비전 번호', '리비전이 1, 2, 3, 4 인 Deployment 에서 `kubectl rollout undo` 로 직전 상태로 돌아가면 리비전 번호는 어떻게 될까요?', '되돌린 내용이 새 번호를 받아요.', NULL, NULL, '[]', 'choice', '["리비전 번호가 4 에서 3 으로 줄어든다", "리비전 목록은 전혀 바뀌지 않는다", "`undo` 는 새 리비전을 만들지 않고 번호만 되돌린다", "되돌린 상태는 새 리비전 번호(5)를 받고 원래 번호(3)는 목록에서 사라진다 (`--to-revision=1` 까지 하면 목록이 `2 4 5 6` 처럼 바뀐다). `kubectl apply` 로 만든 Deployment 는 마지막 적용 설정과 어긋날 수 있다는 `Warning` 도 나온다"]', 3, '`kubectl rollout history deploy/web --revision=1` 은 그 리비전의 Pod 템플릿을 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 5, 'undo 가 실패하는 경우', '리비전이 1 개뿐인 Deployment 에 `kubectl rollout undo` 를 하면 어떻게 될까요? 없는 리비전을 `--to-revision=99` 로 지정하면요?', '돌아갈 이전 기록이 있어야 해요.', NULL, NULL, '[]', 'choice', '["이전 상태가 없어도 같은 상태로 다시 배포된다", "가장 가까운 리비전으로 자동으로 돌아간다", "이전 기록이 없어 `error: no rollout history found for deployment` 오류가 나고, 없는 리비전은 `error: unable to find specified revision 99 in history` 오류가 난다", "둘 다 오류 없이 종료 코드 0 이다"]', 2, '없는 Deployment 에는 `NotFound` 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 6, '진행 기한 초과', '`progressDeadlineSeconds: 25` 인 Deployment 의 이미지를 없는 태그로 바꾸고 35초쯤 지나면 상태는 어떻게 보일까요? 기존 Pod 는요?', '조건의 이유 문자열을 봐요.', NULL, NULL, '[]', 'choice', '["기존 Pod 도 모두 종료되어 `READY 0/2` 가 된다", "`Progressing` 조건이 `False`, 이유가 `ProgressDeadlineExceeded` 가 되고 `kubectl rollout status` 는 `exceeded its progress deadline` 오류로 종료 코드 1 이다. 새 Pod 는 `ErrImagePull` 이지만 기존 Pod 2개는 `Running` 이어서 `READY 2/2` 가 유지된다", "기한이 지나면 자동으로 이전 리비전으로 되돌아간다", "`rollout status` 는 계속 `successfully rolled out` 을 출력한다"]', 1, '이때 `kubectl rollout undo` 로 이전 템플릿으로 돌아갈 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 7, '실패한 롤아웃 복구', '기한 초과된 롤아웃을 `kubectl rollout undo deploy/web` 로 되돌리면 `Progressing` 조건의 이유는 어떻게 바뀔까요? 롤링 업데이트 기본 `maxSurge` 와 `maxUnavailable` 은요?', '정상 완료의 이유를 봐요.', NULL, NULL, '[]', 'choice', '["이전 템플릿으로 롤아웃이 끝나 `successfully rolled out` 이 되고 이유는 `NewReplicaSetAvailable` 이 된다. 기본 `maxSurge` 와 `maxUnavailable` 은 둘 다 `25%` 이다", "이유가 계속 `ProgressDeadlineExceeded` 로 남는다", "기본 `maxSurge` 는 `1`, `maxUnavailable` 은 `0` 이다", "`undo` 는 기한 초과 상태에서는 쓸 수 없다"]', 0, '복제본이 2개일 때 25% 의 `maxUnavailable` 은 0개, `maxSurge` 는 1개로 계산됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 8, 'envFrom 과 env 의 우선순위', '컨테이너에 `envFrom` 으로 ConfigMap(`K1=v1`)을 연결하고 `env` 에 `K1=override` 도 썼다면 `K1` 은 무엇일까요? `prefix: PFX_` 를 쓰면요?', '직접 쓴 env 가 이겨요.', NULL, NULL, '[]', 'choice', '["`envFrom` 의 `K1=v1` 이 이긴다", "같은 이름이 있으면 Pod 생성이 거부된다", "`prefix` 는 값 앞에 붙는다", "직접 쓴 `env` 의 `K1=override` 가 `envFrom` 의 값을 이긴다. `envFrom` 에 `prefix: PFX_` 를 쓰면 키 앞에 붙어 `PFX_K1=v1`, `PFX_K2=v2` 가 된다. `secretRef` 로 Secret 의 키도 같은 방식으로 주입된다"]', 3, 'ConfigMap 의 키 하나만 가져오려면 `valueFrom.configMapKeyRef` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 9, 'Downward API', '`valueFrom.fieldRef.fieldPath: metadata.name`, `resourceFieldRef` 로 `limits.memory`(64Mi)와 `requests.cpu`(250m) 를 환경 변수로 넣으면 각각 값이 무엇이 될까요?', 'Pod 정보를 환경 변수로 받는 방법이에요.', NULL, NULL, '[]', 'choice', '["`limits.memory` 는 `64Mi` 문자열 그대로이다", "`requests.cpu` 는 `250m` 그대로 나온다", "`metadata.name` 은 Pod 이름(`envp`), `limits.memory` 64Mi 는 바이트 값 `67108864` 이 된다. `requests.cpu` 250m 은 기본 단위(1코어)로 올림되어 `1` 로 나온다. `downwardAPI` 볼륨으로 `metadata.labels` 를 파일로 넣으면 `tier=\\"fe\\"` 처럼 키=\\"값\\" 줄이 된다", "`metadata.labels` 파일은 JSON 한 줄로 들어간다"]', 2, '`metadata.namespace` 도 같은 방식으로 `fieldRef` 로 넣을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 10, '없는 ConfigMap 참조', '`envFrom` 으로 없는 ConfigMap `nocfg` 를 참조한 Pod 는 어떻게 될까요? `optional: true` 를 쓰면요?', '컨테이너를 만들기 전에 막혀요.', NULL, NULL, '[]', 'choice', '["Pod 는 `Running` 이 되고 해당 변수만 비어 있다", "Pod 는 `CreateContainerConfigError` 상태가 되고 `describe` 에 `configmap \\"nocfg\\" not found` 가 나온다. `optional: true` 를 쓰면 없어도 Pod 가 정상 실행되어 `Completed` 가 된다", "`optional: true` 를 써도 같은 오류가 난다", "Pod 생성 요청 자체가 거부된다"]', 1, 'Secret 을 참조할 때도 같은 방식으로 `optional` 을 쓸 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 11, 'generateName 과 소유자', '`metadata.generateName: gen-` 으로 Pod 를 `kubectl create` 하면 이름은 어떻게 정해질까요? 두 번 만들면요? Pod 의 소유자는 누구로 보일까요?', '접두어에 임의 문자가 붙어요.', NULL, NULL, '[]', 'choice', '["`gen-` 뒤에 임의의 5글자가 붙은 이름(예: `gen-hwkdx`)이 만들어지고 두 번 만들면 서로 다른 Pod 2개가 된다. Deployment 의 Pod 는 `ownerReferences` 가 `ReplicaSet`, ReplicaSet 은 `Deployment` 이며 `controller` 는 `true` 이다", "항상 `gen-` 이라는 같은 이름으로 만들어져 두 번째는 실패한다", "임의 문자 없이 숫자 순번이 붙는다", "Deployment 의 Pod 는 소유자가 없다"]', 0, '`generateName` 은 `kubectl apply` 가 아니라 `create` 로 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 12, 'finalizer 가 있는 삭제', '`finalizers` 가 설정된 ConfigMap 을 `kubectl delete` 하면 어떻게 될까요? 어떻게 지울 수 있을까요?', '삭제 표시만 되고 남아 있어요.', NULL, NULL, '[]', 'choice', '["즉시 삭제되어 목록에서 사라진다", "삭제가 거부되고 오류가 난다", "`deletionTimestamp` 가 설정되지 않는다", "`deleted` 라고 출력되지만 실제로는 `deletionTimestamp` 만 설정되고 오브젝트가 목록에 남는다. `kubectl patch cm fin -p ''{\\"metadata\\":{\\"finalizers\\":null} }''` 로 finalizer 를 비우면 사라져 `NotFound` 가 된다"]', 3, 'finalizer 를 직접 지우는 것은 정리 작업을 건너뛰는 일이므로 원인을 먼저 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 13, 'replace 와 apply', '`data` 에 `a`, `keep` 이 있는 ConfigMap 에 `data: {b: "y"}` 만 든 파일로 `kubectl replace -f` 와 `kubectl apply -f` 를 각각 하면 결과는 어떻게 다를까요?', '하나는 통째로 바꾸고 하나는 합쳐요.', NULL, NULL, '[]', 'choice', '["`replace` 는 기존 키를 유지하며 합친다", "`apply` 는 `data` 를 파일 내용으로 통째로 바꾼다", "`replace` 는 오브젝트를 파일 내용으로 통째로 바꿔 `data` 가 `{\\"b\\":\\"y\\"}` 만 남고, `apply` 는 합쳐서 `a`, `keep`, `b` 가 모두 남는다. 이미 `create` 로 만든 오브젝트를 `apply` 하면 `last-applied-configuration` 주석이 없다는 `Warning` 이 나온다", "둘 다 결과가 같다"]', 2, '`kubectl replace --force` 는 지우고 다시 만들어 `deleted` 뒤에 `replaced` 가 출력됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 14, 'create·replace 의 오류', '이미 있는 ConfigMap 을 `kubectl create` 하면, 없는 것을 `replace` 하면, 오래된 `resourceVersion` 으로 `replace` 하면 각각 어떤 오류가 날까요?', '오류 이름이 각각 달라요.', NULL, NULL, '[]', 'choice', '["셋 다 `NotFound` 오류이다", "이미 있는 것을 `create` 하면 `already exists`, 없는 것을 `replace` 하면 `NotFound`, 오래된 `resourceVersion` 이면 `Conflict`(`the object has been modified; please apply your changes to the latest version`) 오류가 난다", "`create` 는 이미 있어도 기존 것을 덮어쓴다", "`resourceVersion` 이 달라도 `replace` 는 항상 성공한다"]', 1, '`Conflict` 는 다른 사람이 먼저 바꾼 최신 버전을 다시 받아 고친 뒤 시도하라는 뜻입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 15, '롤아웃 일시 중지', 'Deployment 의 롤아웃을 일시 중지하는 `rollout` 하위 명령을 채우세요.', '"잠깐 멈춤"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["pause", "stop", "hold", "freeze"]', NULL, '중지 중에 바꾼 설정은 `resume` 할 때 한 번에 적용됩니다.', '[0]', 'kubectl rollout {0} deploy/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 16, '롤아웃 다시 시작', '일시 중지한 롤아웃을 재개하는 `rollout` 하위 명령을 채우세요.', '"다시 시작"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["resume", "start", "continue", "unpause"]', NULL, '중지되지 않은 Deployment 에는 `is not paused` 오류가 납니다.', '[0]', 'kubectl rollout {0} deploy/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 17, '환경 변수 지우기', '`kubectl set env deploy/web A` 뒤에 붙여 변수 `A` 를 지우는 기호를 채우세요.', '이름 뒤에 붙이는 한 글자 기호예요.', NULL, NULL, '[]', 'fill', '["-", "!", "=", "~"]', NULL, '지우면 Pod 템플릿이 바뀌어 롤아웃이 일어납니다.', '[0]', 'kubectl set env deploy/web A{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 18, '환경 변수 목록', '현재 설정된 환경 변수를 보여 주는 `set env` 옵션을 채우세요.', '"목록"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--list", "--show", "--all", "-l"]', NULL, '`# Deployment web, container c` 줄로 시작합니다.', '[0]', 'kubectl set env deploy/web {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 19, '특정 리비전으로 되돌리기', '리비전 1 로 되돌리는 `rollout undo` 옵션을 채우세요.', '"리비전으로"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--to-revision", "--revision", "--rev", "--back-to"]', NULL, '되돌린 상태는 새 리비전 번호를 받습니다.', '[0]', 'kubectl rollout undo deploy/web {0}=1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 20, '리비전 내용 보기', '리비전 1 의 Pod 템플릿을 보는 `rollout history` 옵션을 채우세요.', '"리비전"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--revision", "--rev", "--number", "--show"]', NULL, '출력은 `with revision #1` 로 시작합니다.', '[0]', 'kubectl rollout history deploy/web {0}=1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 21, 'envFrom 접두어', '`envFrom` 항목에 써서, 가져온 키 이름 앞에 `PFX_` 를 붙이는 필드를 채우세요.', '"접두어"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["prefix", "prepend", "namePrefix", "head"]', NULL, '그러면 `K1` 이 `PFX_K1` 이 됩니다.', '[0]', '{0}: PFX_', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 22, '없어도 되는 참조', '`envFrom` 의 `configMapRef` 아래에 써서, 참조한 ConfigMap 이 없어도 Pod 가 시작되게 하는 필드를 채우세요.', '"선택적"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["optional", "ignoreMissing", "allowMissing", "maybe"]', NULL, '없으면 `CreateContainerConfigError` 가 납니다.', '[0]', '{0}: true', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 23, '이름 접두어로 생성', '`metadata` 아래에 써서, Pod 이름을 접두어와 임의 문자로 정하는 필드를 채우세요.', '"이름을 만든다"는 뜻을 이은 이름이에요.', NULL, NULL, '[]', 'fill', '["generateName", "namePrefix", "prefixName", "autoName"]', NULL, '`kubectl apply` 가 아니라 `kubectl create` 로 만듭니다.', '[0]', '{0}: gen-', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 24, '통째로 교체', '파일 내용으로 오브젝트를 통째로 바꾸는 `kubectl` 하위 명령을 채우세요.', '"대체"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["replace", "apply", "patch", "set"]', NULL, '없는 오브젝트에는 `NotFound` 오류가 납니다.', '[0]', 'kubectl {0} -f cm.yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 25, 'Pod 정보 필드 경로', '환경 변수의 `valueFrom.fieldRef` 에서 Pod 의 이름을 가리키는 `fieldPath` 값을 채우세요.', 'metadata 아래의 name 이에요.', NULL, NULL, '[]', 'fill', '["metadata.name", "pod.name", "spec.name", "status.name"]', NULL, '네임스페이스는 `metadata.namespace` 입니다.', '[0]', 'fieldPath: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 26, '여러 변경을 한 번의 롤아웃으로', '이미지와 환경 변수를 함께 바꾸되 롤아웃이 한 번만 일어나게 하는 순서입니다. 순서에 맞게 놓아 보세요.', '중지 → 변경 → 재개 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl rollout pause deploy/web` 으로 롤아웃을 일시 중지한다", "`kubectl set image deploy/web c=busybox:1.35` 와 `kubectl set env deploy/web FOO=bar` 로 변경한다", "`kubectl rollout resume deploy/web` 으로 한꺼번에 적용한다", "`kubectl rollout status deploy/web` 으로 끝났는지 확인하고 리비전이 한 번만 늘었는지 본다"]', NULL, '중지 중에는 `kubectl rollout status` 가 시간 초과될 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 27, '실패한 롤아웃 복구하기', '없는 이미지 태그로 바꿔 롤아웃이 막혔을 때 복구하는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 확인 → 원인 → 되돌리기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl rollout status deploy/web` 으로 `exceeded its progress deadline` 오류를 확인한다", "`kubectl get pods` 로 새 Pod 가 `ErrImagePull` 이고 기존 Pod 는 `Running` 인지 본다", "`kubectl rollout undo deploy/web` 으로 이전 템플릿으로 되돌린다", "`kubectl rollout status deploy/web` 이 `successfully rolled out` 인지 확인한다"]', NULL, '`Progressing` 조건의 이유가 `NewReplicaSetAvailable` 로 바뀝니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 28, '환경 변수 주입 확인하기', 'ConfigMap 과 Secret 을 환경 변수로 넣고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 연결 → 실행 확인 → 오류 점검 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create cm cfg --from-literal=K1=v1` 과 `kubectl create secret generic sec --from-literal=S1=s1` 로 만든다", "Pod 에 `envFrom` 으로 `configMapRef` 와 `secretRef` 를 연결해 `kubectl apply -f` 한다", "`kubectl logs` 로 `K1=v1`, `S1=s1` 이 환경 변수로 들어갔는지 본다", "Pod 가 `CreateContainerConfigError` 이면 `kubectl describe pod` 의 이벤트에서 없는 참조를 찾는다"]', NULL, '`prefix` 를 쓰면 이름 앞에 접두어가 붙습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 194, 29, '지워지지 않는 오브젝트 정리', '`finalizers` 때문에 삭제가 끝나지 않는 ConfigMap 을 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '삭제 → 표시 확인 → 원인 정리 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl delete cm fin --wait=false` 로 삭제를 요청한다", "`kubectl get cm fin -o jsonpath=''{.metadata.deletionTimestamp}''` 로 삭제 표시가 있는지 확인한다", "`kubectl patch cm fin -p ''{\\"metadata\\":{\\"finalizers\\":null} }''` 로 finalizer 를 비운다", "`kubectl get cm fin` 이 `NotFound` 인지 확인한다"]', NULL, 'finalizer 를 지우기 전에 어떤 정리 작업이 걸려 있는지 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 194 AND order_index = 29);
