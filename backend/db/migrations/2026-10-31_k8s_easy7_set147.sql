-- k8s 세트 147. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set147.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 147, 'Helm 기본, 오토스케일(HPA), 이벤트·로그 읽기 한 줄씩', 'k8s 운영에서 자주 만나는 도구를 한 개념씩 반복합니다. Helm 의 chart 와 release 의 차이, repo add·install·--set·template·upgrade·history·rollback(롤백도 새 리비전)·uninstall, HPA 의 min~max 와 TARGETS 가 unknown 일 때의 원인, 컨테이너가 여러 개인 Pod 의 logs -c, get events --sort-by 를 짧은 객관식·빈칸·순서 문제로 익히고, 설치하고 확인하기, 업그레이드 후 되돌리기, 설치 전 점검, HPA unknown 점검의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 147);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '⚓' WHERE id = 147;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 1, 'Helm 은 무엇일까', 'Helm 은 어떤 도구일까요?', '앱을 한 묶음으로 설치하고 관리해 줘요.', NULL, NULL, '[]', 'choice', '["컨테이너 이미지를 만드는 도구", "노드를 추가하는 도구", "쿠버네티스 앱을 chart(묶음)로 설치, 업그레이드, 삭제하게 해 주는 패키지 관리 도구", "로그를 모아서 보여 주는 도구"]', 2, '여러 개의 YAML(Deployment, Service, ConfigMap 등)을 하나로 묶어 두고 값만 바꿔 설치할 수 있습니다. 리눅스의 `apt` 와 비슷한 역할이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 2, 'chart 와 release', 'Helm 에서 chart 와 release 의 차이로 알맞은 것은 무엇일까요?', '설계도와 설계도로 지은 건물에 비유해 보세요.', NULL, NULL, '[]', 'choice', '["chart 는 클러스터에 설치된 것이고 release 는 파일이다", "chart 는 설치 묶음(설계도)이고, release 는 그것을 클러스터에 설치한 결과(이름이 붙은 인스턴스)", "둘은 같은 말이다", "release 는 chart 를 삭제한 상태이다"]', 1, '같은 chart 를 이름을 달리해 여러 번 설치할 수 있고, 그때마다 release 가 하나씩 생깁니다. `helm list` 는 release 의 목록을 보여 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 3, 'helm repo add', '`helm repo add 이름 주소` 는 무엇을 할까요?', '설치가 아니라 "어디서 받을지" 등록하는 거예요.', NULL, NULL, '[]', 'choice', '["chart 를 받아 올 저장소 주소를 등록한다 (아직 아무것도 설치하지 않는다)", "앱을 클러스터에 설치한다", "클러스터에 저장소를 만든다", "기존 release 를 삭제한다"]', 0, '저장소를 등록한 뒤 `helm repo update` 로 목록을 갱신하고 `helm install` 로 설치합니다. 등록한 저장소가 없으면 `helm repo list` 가 "no repositories to show" 라고 알려 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 4, 'helm install', '`helm install demo ./mychart` 에서 `demo` 는 무엇일까요?', 'chart 이름이 아니에요. 설치한 결과에 붙이는 이름이에요.', NULL, NULL, '[]', 'choice', '["chart 의 이름", "네임스페이스의 이름", "Pod 의 이름", "설치한 결과(release)에 붙이는 이름"]', 3, '`./mychart` 는 chart 의 위치입니다. release 이름으로 `helm upgrade demo ...`, `helm rollback demo ...` 처럼 이후 관리해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 5, 'values 로 값 바꾸기', '`helm install demo ./mychart --set replicaCount=2` 의 `--set` 은 무엇을 할까요?', '설치할 때 기본값을 바꿔요.', NULL, NULL, '[]', 'choice', '["chart 의 파일을 수정한다", "클러스터의 설정을 영구히 바꾼다", "chart 의 기본값(values)을 설치 때 덮어쓴다", "네임스페이스를 만든다"]', 2, '기본값은 chart 안의 `values.yaml` 에 있습니다. 값이 많으면 `-f my-values.yaml` 로 파일을 줄 수 있고, `helm get values demo` 로 직접 준 값을 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 6, 'template 으로 미리 보기', '`helm template demo ./mychart` 는 무엇을 할까요?', '설치하지 않고 결과물만 만들어 봐요.', NULL, NULL, '[]', 'choice', '["chart 를 삭제한다", "클러스터에 설치하지 않고, 만들어질 YAML 만 출력한다", "앱을 설치하고 YAML 을 지운다", "release 의 이력을 보여 준다"]', 1, '`helm lint` 로 문법을 점검하고 `helm template` 으로 최종 YAML 을 미리 확인한 뒤 설치하면 실수를 줄일 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 7, 'helm upgrade', '`helm upgrade demo ./mychart --set replicaCount=2` 는 무엇을 할까요?', '이미 설치된 것에 새 설정을 적용해요.', NULL, NULL, '[]', 'choice', '["이미 설치된 release `demo` 에 새 설정을 적용해 새 리비전을 만든다", "demo 를 삭제하고 새로 설치한다", "chart 를 새로 내려받는다", "클러스터의 노드 수를 늘린다"]', 0, '업그레이드할 때마다 리비전 번호가 하나씩 올라갑니다. 리비전이 쌓여 있어 필요하면 이전으로 돌아갈 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 8, 'helm history', '`helm history demo` 는 무엇을 보여 줄까요?', 'release 의 변경 기록이에요.', NULL, NULL, '[]', 'choice', '["클러스터의 이벤트 목록", "chart 의 파일 목록", "Pod 의 로그", "release 의 리비전 목록과 각 리비전의 상태"]', 3, '리비전 번호, 상태(`deployed`, `superseded`), 설명이 나옵니다. 롤백할 번호를 고르기 전에 먼저 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 9, 'helm rollback 의 결과', '`helm rollback demo 1` 을 실행하면 history 는 어떻게 바뀔까요? (이전 history: 1 superseded, 2 deployed)', '이력을 지우지 않고 새 항목을 더해요.', NULL, NULL, '[]', 'choice', '["리비전 2 가 삭제되고 1 이 다시 `deployed` 가 된다", "리비전 번호가 1 로 초기화된다", "리비전 1 의 설정으로 돌아가되, 새 리비전 3 이 만들어져 `deployed` 가 된다 (1 과 2 는 `superseded`)", "아무것도 바뀌지 않는다"]', 2, '롤백도 하나의 변경으로 기록됩니다. 그래서 되돌린 뒤에도 history 에서 무슨 일이 있었는지 확인할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 10, 'helm uninstall', '`helm uninstall demo` 는 무엇을 할까요?', 'release 가 만든 것들을 정리해요.', NULL, NULL, '[]', 'choice', '["chart 파일을 삭제한다", "release `demo` 가 만든 리소스(Deployment, Service 등)를 삭제한다", "클러스터를 삭제한다", "helm 프로그램을 삭제한다"]', 1, '삭제한 뒤에는 `helm list` 에서 사라집니다. 데이터가 든 PVC 는 chart 설정에 따라 남을 수 있으니 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 11, 'HPA 란', 'HPA(HorizontalPodAutoscaler)는 무엇을 할까요?', '사용량에 맞춰 Pod 개수를 알아서 조절해요.', NULL, NULL, '[]', 'choice', '["CPU 같은 사용량에 따라 Pod 의 개수를 정해 둔 범위(min~max) 안에서 자동으로 늘리고 줄인다", "노드의 개수를 자동으로 늘린다", "Pod 의 CPU 상한을 자동으로 바꾼다", "이미지를 자동으로 업데이트한다"]', 0, '평소에는 적게, 몰릴 때는 많게 운영할 수 있습니다. Pod 의 개수를 조절하는 것이지, 노드를 늘리지는 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 12, 'TARGETS 가 unknown', '`kubectl get hpa` 의 TARGETS 가 `cpu: <unknown>/50%` 입니다. 무슨 뜻일까요?', '사용량 값을 가져오지 못한다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["사용량이 정확히 50% 이다", "HPA 가 정상적으로 Pod 를 줄이고 있다", "Pod 가 삭제되었다", "현재 CPU 사용량 지표를 가져오지 못한다. metrics-server 가 없거나 준비되지 않았거나, Pod 에 CPU requests 가 없는 경우가 흔하다"]', 3, '`kubectl top pods` 가 되는지 먼저 확인하세요. HPA 는 "사용량 ÷ requests" 로 비율을 계산하므로 requests 도 꼭 필요합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 13, 'logs -c 의 쓰임', 'Pod 안에 컨테이너가 두 개(`a`, `b`)일 때 `kubectl logs 파드` 만 실행하면 어떻게 될까요?', '오류는 아니고 안내가 나와요.', NULL, NULL, '[]', 'choice', '["항상 오류가 나서 아무것도 안 나온다", "두 컨테이너의 로그를 합쳐서 보여 준다", "`Defaulted container \\"a\\" out of: a, b` 라고 알리고 첫 번째 컨테이너의 로그를 보여 준다. 다른 컨테이너는 `-c b` 로 고른다", "마지막 컨테이너의 로그를 보여 준다"]', 2, '로그를 볼 컨테이너를 명확히 하려면 `-c 이름` 을 쓰세요. 사이드카가 있는 Pod 에서는 엉뚱한 컨테이너 로그를 보는 실수가 흔해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 14, '이벤트를 시간순으로', '`kubectl get events` 의 결과가 뒤죽박죽입니다. 시간순으로 정렬해 최근 일을 보려면 어떻게 할까요?', '정렬 옵션에 시간 필드를 넣어요.', NULL, NULL, '[]', 'choice', '["`kubectl get events --sorted`", "`kubectl get events --sort-by=.lastTimestamp`", "`kubectl get events | sort`", "`kubectl events --time`"]', 1, '이벤트는 문제의 단서를 가장 빨리 보여 줍니다. 시간순으로 정렬하면 마지막에 어떤 일이 일어났는지 바로 보여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 15, 'Helm 으로 설치하기', 'chart `./mychart` 를 release 이름 `demo` 로 **설치하는** 명령입니다. 빈칸을 채우세요.', '"설치하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["install", "create", "apply", "deploy"]', NULL, '`helm create` 는 chart 의 뼈대를 만드는 명령이라 설치와는 다릅니다.', '[0]', 'helm {0} demo ./mychart', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 16, '설치된 release 목록', '설치된 **release 목록**을 보는 명령입니다. 빈칸을 채우세요.', '"목록"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["list", "ls-all", "show", "releases"]', NULL, '`-n 네임스페이스` 를 붙이면 그 네임스페이스의 release 만 봅니다. `-A` 는 전체예요.', '[0]', 'helm {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 17, '값을 바꿔 업그레이드', '이미 설치된 `demo` 에 `replicaCount=2` 를 **적용하는** 명령입니다. 빈칸을 채우세요.', '"올리다, 업그레이드"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["upgrade", "update", "change", "patch"]', NULL, '`helm install` 로는 같은 이름을 다시 쓸 수 없습니다. 이미 설치된 것은 `upgrade` 로 바꾸세요.', '[0]', 'helm {0} demo ./mychart --set replicaCount=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 18, '변경 이력 보기', 'release `demo` 의 **리비전 이력**을 보는 명령입니다. 빈칸을 채우세요.', '"역사"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["history", "log", "revisions", "past"]', NULL, '롤백하기 전에 어느 리비전으로 돌아갈지 번호를 이 명령으로 확인합니다.', '[0]', 'helm {0} demo', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 19, '이전으로 되돌리기', 'release `demo` 를 **리비전 1** 로 되돌리는 명령입니다. 빈칸을 채우세요.', '"되감다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["rollback", "undo", "revert", "back"]', NULL, '롤백하면 새 리비전이 하나 더 만들어집니다. 번호를 생략하면 직전 리비전으로 돌아가요.', '[0]', 'helm {0} demo 1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 20, 'release 삭제하기', 'release `demo` 와 그것이 만든 리소스를 **삭제하는** 명령입니다. 빈칸을 채우세요.', '"설치"의 반대말이에요.', NULL, NULL, '[]', 'fill', '["uninstall", "delete-all", "remove", "destroy"]', NULL, '삭제하기 전에 `helm list` 로 이름이 맞는지 확인하세요. 네임스페이스가 다르면 `-n` 이 필요합니다.', '[0]', 'helm {0} demo', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 21, '설치 없이 YAML 미리 보기', '설치하지 않고 **만들어질 YAML 만 출력**하는 명령입니다. 빈칸을 채우세요.', '"틀, 본"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["template", "render", "preview", "show"]', NULL, '출력을 `kubectl apply --dry-run=client -f -` 에 넘기면 문법을 한 번 더 점검할 수 있습니다.', '[0]', 'helm {0} demo ./mychart', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 22, '설치할 때 값 덮어쓰기', '설치할 때 `replicaCount` 값을 **직접 정해** 주는 옵션입니다. 빈칸을 채우세요.', '"정하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["set", "value", "param", "env"]', NULL, '여러 값은 쉼표로 이어 쓰거나 `--set` 을 반복합니다. 값이 많으면 파일(`-f`)이 편해요.', '[0]', 'helm install demo ./mychart --{0} replicaCount=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 23, 'CPU 50% 기준 오토스케일', '`web` Deployment 를 CPU 사용률 **50% 기준**으로 최소 1개, 최대 3개로 자동 조절하려고 합니다. 값을 채우세요.', '퍼센트 기호가 붙어요.', NULL, NULL, '[]', 'fill', '["50%", "half", "50p", "%50"]', NULL, '예전 옵션인 `--cpu-percent` 는 더 이상 권장되지 않고 `--cpu` 에 퍼센트로 씁니다. 사용률을 계산하려면 Pod 에 CPU requests 가 있어야 해요.', '[0]', 'kubectl autoscale deployment web --cpu={0} --min=1 --max=3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 24, '컨테이너 고르기', 'Pod `web` 의 컨테이너 `app` 의 로그만 보려고 합니다. 옵션을 채우세요.', 'container 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["c", "n", "p", "e"]', NULL, '`-n` 은 네임스페이스를 고르는 옵션이라 컨테이너와 다릅니다. 컨테이너가 하나뿐이면 `-c` 는 생략해도 돼요.', '[0]', 'kubectl logs web -{0} app', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 25, '최근 이벤트 보기', '이벤트를 **마지막 발생 시각 순으로** 정렬하려고 합니다. 값을 채우세요.', '필드 이름 앞에 점을 붙여요.', NULL, NULL, '[]', 'fill', '[".lastTimestamp", ".newest", ".latest", ".when"]', NULL, '시간순으로 정렬하면 가장 아래에 가장 최근 이벤트가 나옵니다. 장애 직전의 사건을 찾을 때 유용해요.', '[0]', 'kubectl get events --sort-by={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 26, 'Helm 으로 설치하고 확인하기', 'chart 를 설치하고 제대로 설치됐는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '설치 → release 목록 → Pod → 상태 순서예요.', NULL, NULL, '[]', 'order', '["`helm install demo ./mychart` 로 설치한다", "`helm list` 로 release 가 `deployed` 인지 본다", "`kubectl get pods` 로 Pod 가 `Running` 인지 본다", "`helm status demo` 로 설치 결과와 안내 메시지를 본다"]', NULL, 'Helm 이 성공이라고 해도 Pod 가 실제로 뜨는지는 별개입니다. `kubectl get pods` 로 꼭 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 27, '업그레이드 후 문제 생기면 되돌리기', '업그레이드한 뒤 문제가 생겨 되돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '적용 → 확인 → 이력 → 롤백 순서예요.', NULL, NULL, '[]', 'order', '["`helm upgrade demo ./mychart --set replicaCount=2` 로 업그레이드한다", "`kubectl get pods` 로 Pod 상태를 확인하고 문제를 발견한다", "`helm history demo` 로 되돌릴 리비전을 찾는다", "`helm rollback demo 1` 로 이전 리비전으로 되돌린다"]', NULL, '롤백은 새 리비전으로 기록됩니다. 되돌린 뒤에도 Pod 상태를 다시 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 28, '설치 전에 미리 점검하기', '실제로 설치하기 전에 chart 를 점검하는 순서입니다. 순서에 맞게 놓아 보세요.', '문법 → 결과물 미리 보기 → 값 바꿔 보기 → 설치 순서예요.', NULL, NULL, '[]', 'order', '["`helm lint ./mychart` 로 chart 의 문법을 점검한다", "`helm template demo ./mychart` 로 만들어질 YAML 을 본다", "`--set` 으로 값을 바꿔 YAML 이 어떻게 달라지는지 확인한다", "`helm install demo ./mychart` 로 실제로 설치한다"]', NULL, '설치 전에 YAML 을 눈으로 보는 습관이 운영 사고를 줄입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 147, 29, 'HPA 의 TARGETS 가 unknown 일 때', 'HPA 의 TARGETS 가 `<unknown>` 일 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 지표 확인 → metrics-server → requests 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get hpa` 로 TARGETS 가 `<unknown>` 인 것을 확인한다", "`kubectl top pods` 로 사용량 지표가 나오는지 본다", "`kubectl get pods -n kube-system` 으로 metrics-server 가 떠 있는지 본다", "Pod 에 CPU requests 가 있는지 확인하고 고친 뒤 다시 `get hpa` 로 본다"]', NULL, '지표를 가져오지 못하면 HPA 는 판단할 수 없어 Pod 개수를 바꾸지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 147 AND order_index = 29);
