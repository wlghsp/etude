-- k8s 세트 174. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set174.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 174, 'kubectl 편집·조회 도구: label·annotate, patch, edit, diff, jsonpath, wait', '리소스를 고치고 골라 보고 기다리는 kubectl 도구를 한 개념씩 반복합니다. 라벨·어노테이션을 덮어쓸 때의 --overwrite 와 지우는 표기, selector 가 쓰는 라벨을 지웠을 때의 동작, Deployment 라벨과 Pod 템플릿 라벨의 차이, change-cause 와 rollout history, patch 의 전략적 병합·JSON 병합·JSON 패치와 목록 필드 처리 차이, kubectl edit 의 결과, set image 와 rollout restart, 적용 전 kubectl diff 와 종료 코드, explain, jsonpath·custom-columns·-o name, --field-selector 와 -l 의 차이, kubectl wait 의 condition met 과 시간 초과를 짧은 객관식·빈칸·순서 문제로 익히고, diff 로 확인하고 적용하기, JSON 패치로 복제 수 바꾸기, 라벨 다루기, 배포가 준비될 때까지 기다리기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 174);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🛠️' WHERE id = 174;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 1, '라벨은 덮어쓰기 확인이 필요하다', '이미 `tier=front` 라벨이 있는 Pod 에 `kubectl label pod 이름 tier=back` 을 하면 어떻게 될까요?', '기존 값을 바꾸려면 명시가 필요해요.', NULL, NULL, '[]', 'choice', '["조용히 값이 `back` 으로 바뀐다", "라벨이 두 개(`front`, `back`)가 된다", "`error: ''tier'' already has a value (front), and --overwrite is false` 오류로 거부된다. `--overwrite` 를 붙이면 값이 바뀐다", "Pod 가 재시작된다"]', 2, '라벨을 지울 때는 키 뒤에 `-` 를 붙입니다. `kubectl label pod 이름 tier-` 처럼 쓰면 `unlabeled` 로 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 2, 'selector 의 라벨을 지우면', 'ReplicaSet 이 관리하는 Pod 에서 `kubectl label pod 이름 app-` 으로 selector 가 쓰는 `app` 라벨을 지웠습니다. 어떻게 될까요?', 'ReplicaSet 은 라벨로 자기 Pod 를 세요.', NULL, NULL, '[]', 'choice', '["그 Pod 가 즉시 삭제된다", "그 Pod 는 ReplicaSet 의 관리 대상에서 빠져 지워지지 않고 계속 남고, ReplicaSet 은 개수를 맞추려고 새 Pod 를 하나 더 만든다 (Pod 가 하나 늘어난다)", "아무 일도 일어나지 않는다", "Deployment 가 삭제된다"]', 1, '라벨을 다시 붙이면 관리 대상으로 돌아옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 3, 'Deployment 의 라벨과 Pod 의 라벨', '`kubectl label deployment web owner=team-a` 를 하면 이 Deployment 가 만드는 Pod 에도 `owner=team-a` 가 붙을까요?', 'Deployment 자신과 Pod 템플릿은 별개예요.', NULL, NULL, '[]', 'choice', '["붙지 않는다 (Deployment 오브젝트의 라벨만 바뀌고, Pod 에 붙는 라벨은 `spec.template.metadata.labels` 가 정한다)", "새로 만들어지는 Pod 에 자동으로 붙는다", "기존 Pod 에만 붙는다", "오류가 난다"]', 0, 'Pod 에 라벨을 붙이려면 템플릿을 고쳐야 하고, 그러면 새 롤아웃이 일어납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 4, 'annotate 와 change-cause', '`kubectl annotate deployment web kubernetes.io/change-cause="bump" --overwrite` 를 하면 `kubectl rollout history` 에서 어떻게 보일까요?', 'history 의 CHANGE-CAUSE 열이에요.', NULL, NULL, '[]', 'choice', '["`rollout history` 에 아무 영향이 없다", "Pod 이름이 `bump` 로 바뀐다", "Deployment 가 삭제된다", "해당 리비전의 `CHANGE-CAUSE` 열에 `bump` 같은 값이 표시된다 (어노테이션도 같은 키를 바꾸려면 `--overwrite` 가 필요하다)"]', 3, '어노테이션은 라벨과 달리 selector 에 쓰이지 않는 설명용 값입니다. 지울 때는 `kubectl annotate deployment web note-` 처럼 `-` 를 붙여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 5, 'patch 의 세 가지 방식', '`kubectl patch` 의 기본 방식과 `--type=merge`, `--type=json` 은 각각 무엇일까요? 같은 패치를 한 번 더 실행하면요?', '기본은 쿠버네티스 방식의 병합이에요.', NULL, NULL, '[]', 'choice', '["셋은 이름만 다르고 완전히 같다", "`--type=json` 이 기본이다", "기본은 전략적 병합(strategic merge)이고, `--type=merge` 는 JSON 병합 패치, `--type=json` 은 `op`·`path`·`value` 로 쓰는 JSON 패치(목록 형식)이다. 이미 같은 값이면 `patched (no change)` 로 나온다", "같은 패치를 다시 하면 항상 오류가 난다"]', 2, 'JSON 패치는 `replace`, `add`, `remove` 같은 작업을 경로와 함께 정확히 적을 때 편합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 6, '목록 필드를 patch 할 때', '`containers` 목록에서 `name` 이 `nginx` 인 컨테이너에 메모리 한도를 추가하려고 합니다. 기본 patch(전략적 병합)와 `--type=merge` 로 컨테이너 목록을 보내면 결과가 어떻게 다를까요?', '목록을 합치느냐, 통째로 바꾸느냐예요.', NULL, NULL, '[]', 'choice', '["두 방식 모두 목록을 합친다", "전략적 병합은 `name` 이 같은 컨테이너를 찾아 필드를 합치므로 기존 설정이 유지되고 한도가 추가되고, JSON 병합(`--type=merge`)은 목록 전체를 보낸 값으로 바꿔서 보내지 않은 필드(예: 앞서 정한 메모리 한도)가 사라진다", "두 방식 모두 목록을 통째로 바꾼다", "`--type=merge` 가 목록을 합치고 전략적 병합이 통째로 바꾼다"]', 1, '목록을 건드릴 때는 어떤 방식인지 꼭 확인하세요. 일부 필드만 바꾸려면 전략적 병합이나 JSON 패치의 경로 지정이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 7, 'kubectl edit', '`KUBE_EDITOR` 로 지정한 에디터로 `kubectl edit deployment web` 을 했을 때, 내용을 바꿨을 때, 바꾸지 않았을 때, 잘못된 값으로 바꿨을 때 각각 어떻게 나올까요?', '저장하면 서버가 검사하고 반영해요.', NULL, NULL, '[]', 'choice', '["바꾸면 `deployment.apps/web edited` 로 반영되고, 바꾸지 않으면 `Edit cancelled, no changes made.`, 잘못된 값이면 `error: ... is invalid` 와 함께 변경 사본이 저장되었다는 안내가 나오고 반영되지 않는다 (`KUBE_EDITOR` 가 `EDITOR` 보다 우선한다)", "바꾸지 않아도 항상 `edited` 로 나온다", "잘못된 값도 일단 반영된 뒤 되돌려진다", "항상 `vi` 만 쓸 수 있다"]', 0, '실수로 큰 변경을 하기 쉬우니 중요한 리소스는 YAML 파일을 수정해 `apply` 하는 편이 기록에 남아 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 8, 'kubectl set image', '`kubectl set image deployment/web nginx=nginx:1.27-alpine` 의 `nginx=` 는 무엇을 뜻할까요? 없는 컨테이너 이름을 쓰면요?', '컨테이너 이름=이미지 형식이에요.', NULL, NULL, '[]', 'choice', '["`nginx` 는 Deployment 이름이다", "`nginx` 는 네임스페이스이다", "없는 이름이면 새 컨테이너가 추가된다", "`nginx` 는 바꿀 컨테이너의 이름이고 `=` 뒤가 새 이미지이다. 없는 컨테이너 이름이면 `error: unable to find container named \\"...\\"` 오류가 난다"]', 3, '이미지를 바꾸면 Pod 템플릿이 바뀌어 롤링 업데이트가 일어납니다. `rollout status` 로 끝났는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 9, 'rollout restart', '이미지와 설정을 하나도 바꾸지 않고 `kubectl rollout restart deployment web` 을 하면 어떻게 될까요?', 'Pod 템플릿에 재시작 표시가 남아요.', NULL, NULL, '[]', 'choice', '["아무 일도 일어나지 않는다", "Deployment 가 삭제된다", "새 리비전이 만들어지고 Pod 가 롤링으로 새로 교체된다 (이미지는 그대로이다)", "Pod 가 모두 한꺼번에 삭제되고 복구되지 않는다"]', 2, 'ConfigMap 을 바꾼 뒤 환경 변수 반영이 필요할 때 간단한 방법입니다. `rollout history` 의 리비전이 하나 늘어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 10, 'kubectl diff', '수정한 YAML 로 `kubectl diff -f 파일` 을 하면 어떻게 될까요? 클러스터는 바뀔까요?', '적용했을 때 달라질 부분만 보여 줘요.', NULL, NULL, '[]', 'choice', '["파일의 내용을 클러스터에 즉시 적용한다", "클러스터는 바꾸지 않고 적용했을 때 달라질 줄을 `-`(현재), `+`(적용 후)로 보여 주며, 차이가 있으면 종료 코드 1, 차이가 없으면 아무것도 출력하지 않고 종료 코드 0 이다", "차이가 있어도 종료 코드는 항상 0 이다", "차이가 없으면 오류가 난다"]', 1, '`apply` 전에 `diff` 로 의도한 변경인지 확인하는 습관이 사고를 줄입니다. 종료 코드는 스크립트에서 변경 여부 판단에 쓸 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 11, 'kubectl explain', '`kubectl explain deployment.spec.replicas` 와 `kubectl explain deployment.spec.strategy --recursive` 는 각각 무엇을 보여 줄까요?', '필드의 설명서예요.', NULL, NULL, '[]', 'choice', '["앞은 그 필드의 타입(`<integer>`)과 설명(DESCRIPTION)을, 뒤는 그 아래의 하위 필드 전체를 나무 모양으로 보여 준다.", "클러스터의 현재 값을 보여 준다", "리소스를 삭제한다", "`--recursive` 는 모든 네임스페이스를 뒤진다"]', 0, 'YAML 을 쓸 때 필드 이름이나 타입이 헷갈리면 `explain` 으로 바로 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 12, 'jsonpath 로 값 뽑기', '`kubectl get pods -o jsonpath=''{.items[*].metadata.name}''` 는 무엇을 출력할까요? 없는 경로를 쓰면요?', '모든 Pod 이름을 공백으로 이어요.', NULL, NULL, '[]', 'choice', '["Pod 이름을 JSON 으로 출력한다", "없는 경로를 쓰면 오류로 종료된다", "Pod 의 라벨을 출력한다", "모든 Pod 이름을 공백으로 이어 한 줄로 출력한다 (줄마다 출력하려면 `{range .items[*]}{.metadata.name}{\\"\\\\n\\"}{end}` 처럼 range 를 쓴다). 없는 경로는 오류 없이 빈 값이 나온다"]', 3, '`-o name` 은 `pod/이름` 형식, `-o custom-columns` 는 표 형식으로 뽑을 때 쓰는 다른 방법입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 13, 'field-selector 와 라벨 셀렉터', '`kubectl get pods -l app=web` 과 `--field-selector status.phase=Running` 은 무엇이 다를까요?', '하나는 라벨, 하나는 리소스의 필드 값으로 걸러요.', NULL, NULL, '[]', 'choice', '["둘은 이름만 다른 같은 옵션이다", "`--field-selector` 는 라벨을 걸러 낸다", "`-l` 은 라벨로, `--field-selector` 는 `status.phase`, `metadata.name` 같은 리소스의 필드 값으로 걸러 낸다. 둘을 함께 쓸 수 있고, 지원하지 않는 필드는 `BadRequest` 오류가 난다", "`-l` 은 필드 값으로 걸러 낸다"]', 2, '임의의 필드로는 걸러 낼 수 없어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 14, 'kubectl wait', '`kubectl wait --for=condition=Ready pod/이름 --timeout=5s` 는 조건이 충족되면 무엇을 출력할까요? 시간이 지나도 충족되지 않으면요?', '조건을 기다리는 명령이에요.', NULL, NULL, '[]', 'choice', '["충족되지 않아도 종료 코드 0 이다", "충족되면 `pod/이름 condition met` 을 출력하고, 시간이 지나도 충족되지 않으면 `error: timed out waiting for the condition on pods/이름` 을 출력하며 종료 코드 1 로 끝난다", "시간 제한 없이 영원히 기다린다", "Pod 를 삭제한다"]', 1, '`--for=condition=Available deployment/web` 이나 `--for=delete` 도 쓸 수 있습니다. 배포 스크립트에서 다음 단계로 넘어가기 전에 쓰기 좋아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 15, '덮어쓰기 옵션', '이미 있는 라벨의 값을 **바꾸려면** 붙이는 옵션을 채우세요.', '"덮어쓰다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--overwrite", "--force", "--replace", "--update"]', NULL, '옵션이 없으면 `already has a value` 오류로 거부됩니다.', '[0]', 'kubectl label pod web tier=back {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 16, '라벨 지우기', 'Pod 의 `tier` 라벨을 **지우는** 표기를 채우세요.', '키 뒤에 붙이는 한 글자예요.', NULL, NULL, '[]', 'fill', '["-", "=", "--remove", "=none"]', NULL, '`unlabeled` 가 출력됩니다. `=none` 은 값을 `none` 으로 바꿀 뿐이에요.', '[0]', 'kubectl label pod web tier{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 17, '라벨 함께 보기', '`kubectl get pods` 의 결과에 **라벨 열을 보여 주는** 옵션을 채우세요.', '"라벨 보기"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["--show-labels", "--labels", "-o labels", "--with-labels"]', NULL, '특정 라벨만 열로 보려면 `-L tier` 처럼 씁니다.', '[0]', 'kubectl get pods {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 18, 'JSON 패치 형식', '`op`, `path`, `value` 로 이루어진 **JSON 패치** 방식의 `--type` 값을 채우세요.', '"JSON"이에요.', NULL, NULL, '[]', 'fill', '["json", "merge", "strategic", "yaml"]', NULL, '`merge` 는 JSON 병합 패치이고 목록을 통째로 바꿉니다.', '[0]', 'kubectl patch deployment web --type={0} -p ...', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 19, '이미지만 바꾸기', 'Deployment 의 컨테이너 **이미지만 바꾸는** `kubectl set` 하위 명령을 채우세요.', '"이미지"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["image", "container", "tag", "version"]', NULL, '컨테이너 이름과 이미지를 `이름=이미지` 로 씁니다.', '[0]', 'kubectl set {0} deployment/web nginx=nginx:1.27-alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 20, '설정은 그대로 재시작', '이미지와 설정을 바꾸지 않고 Pod 를 **롤링으로 새로 교체하는** `rollout` 하위 명령을 채우세요.', '"다시 시작"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["restart", "reload", "redeploy", "refresh"]', NULL, '새 리비전이 하나 만들어집니다.', '[0]', 'kubectl rollout {0} deployment web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 21, '적용 전 미리 비교', '파일을 적용하면 **무엇이 달라질지** 클러스터를 바꾸지 않고 비교하는 명령을 채우세요.', '"차이"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["diff", "compare", "preview", "plan"]', NULL, '차이가 있으면 종료 코드 1 입니다.', '[0]', 'kubectl {0} -f web.yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 22, '필드 설명서', '리소스의 **필드 설명**을 보는 `kubectl` 하위 명령을 채우세요.', '"설명하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["explain", "describe", "help", "man"]', NULL, '`describe` 는 클러스터에 있는 리소스의 상태를 설명하는 다른 명령입니다.', '[0]', 'kubectl {0} deployment.spec.replicas', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 23, 'jsonpath 출력', '출력 형식으로 **JSONPath 식으로 값을 뽑는** 이름을 채우세요.', '"JSON"과 "경로(path)"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["jsonpath", "json-path", "path", "query"]', NULL, '`-o name` 은 `pod/이름` 형식으로 출력합니다.', '[0]', 'kubectl get pods -o {0}=''{.items[*].metadata.name}''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 24, '필드 값으로 거르기', '`status.phase=Running` 처럼 **필드 값으로 거르는** 옵션을 채우세요.', '"필드 선택자"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["field-selector", "selector", "filter", "where"]', NULL, '라벨로 거를 때는 `-l` 을 씁니다.', '[0]', 'kubectl get pods --{0} status.phase=Running', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 25, '조건 기다리기', '리소스의 **조건이 충족될 때까지 기다리는** `kubectl` 하위 명령을 채우세요.', '"기다리다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["wait", "sleep", "until", "watch"]', NULL, '충족되면 `condition met` 이 출력됩니다.', '[0]', 'kubectl {0} --for=condition=Ready pod/web --timeout=20s', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 26, 'diff 로 확인하고 적용하기', '수정한 YAML 파일을 안전하게 클러스터에 반영하는 순서입니다. 순서에 맞게 놓아 보세요.', '비교 → 의도 확인 → 적용 → 완료 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl diff -f 파일` 로 적용했을 때 달라질 부분을 본다", "`-` 와 `+` 줄이 의도한 변경뿐인지 확인한다", "`kubectl apply -f 파일` 로 적용한다", "`kubectl rollout status` 로 교체가 끝났는지 확인한다"]', NULL, '`diff` 는 클러스터를 바꾸지 않으므로 몇 번이든 실행해도 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 27, 'JSON 패치로 복제 수 바꾸기', '`kubectl patch` 로 Deployment 의 복제 수를 바꾸고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '현재 값 → 패치 → 같은 패치 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get deployment web -o jsonpath` 로 현재 복제 수를 확인한다", "`kubectl patch deployment web --type=json -p ...` 로 `replace` 작업을 보낸다", "같은 패치를 한 번 더 보내 `(no change)` 가 나오는지 본다", "`kubectl get deployment web` 으로 원하는 개수가 되었는지 확인한다"]', NULL, '`--type=json` 의 `path` 는 `/spec/replicas` 처럼 슬래시로 구분합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 28, '라벨 다루기', 'Pod 의 라벨을 붙이고 바꾸고 지우며 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '붙이기 → 거부 확인 → 덮어쓰기 → 지우기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl label pod 이름 tier=front` 로 라벨을 붙인다", "같은 키에 다른 값을 주어 `--overwrite is false` 오류로 거부되는 것을 본다", "`--overwrite` 를 붙여 값을 바꾼다", "`kubectl label pod 이름 tier-` 로 지우고 `--show-labels` 로 확인한다"]', NULL, 'selector 가 쓰는 라벨을 지우면 Pod 가 관리 대상에서 빠지니 조심하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 174, 29, '배포가 준비될 때까지 기다리기', 'Deployment 를 적용한 뒤 준비를 기다렸다가 다음 단계로 넘어가는 순서입니다. 순서에 맞게 놓아 보세요.', '적용 → 기다림 → 결과 확인 → 실패 시 조사 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl apply -f deployment.yaml` 로 적용한다", "`kubectl wait --for=condition=Available deployment/web --timeout=60s` 로 기다린다", "`condition met` 이 나오면 다음 단계로 넘어간다", "`timed out waiting for the condition` 과 종료 코드 1 이 나오면 `kubectl describe` 로 원인을 조사한다"]', NULL, '스크립트에서는 종료 코드를 보고 다음 단계로 갈지 멈출지 정할 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 174 AND order_index = 29);
