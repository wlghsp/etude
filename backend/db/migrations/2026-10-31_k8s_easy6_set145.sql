-- k8s 세트 145. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set145.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 145, '워크로드 관계, 리소스 단위, kubectl 작업 도구 한 줄씩', 'k8s 워크로드를 다루는 기본기를 한 개념씩 반복합니다. Deployment·ReplicaSet·Pod 의 관계와 Pod 를 지우면 되살아나는 이유, 업데이트 뒤 DESIRED 0 으로 남는 ReplicaSet, DaemonSet 과 StatefulSet, get all 의 범위, CPU 500m·1 과 메모리 Mi 단위, create 와 apply 의 차이, --dry-run=client -o yaml, exec·port-forward·top 을 짧은 객관식·빈칸·순서 문제로 익히고, Deployment 에서 Pod 까지 따라가기, YAML 뼈대 만들어 적용하기, Pod 안에서 확인하기, 임시 접속하기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 145);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🔧' WHERE id = 145;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 1, 'Deployment 와 ReplicaSet 과 Pod', 'Deployment, ReplicaSet, Pod 의 관계로 알맞은 것은 무엇일까요?', '위에서 아래로 관리하는 구조예요.', NULL, NULL, '[]', 'choice', '["Pod 가 Deployment 를 만들고 ReplicaSet 이 이를 지킨다", "셋은 서로 아무 관계가 없다", "Deployment 가 ReplicaSet 을 만들어 관리하고, ReplicaSet 이 Pod 의 개수를 유지한다", "ReplicaSet 이 Deployment 를 관리한다"]', 2, '사용자는 Deployment 만 다루면 되고 ReplicaSet 은 자동으로 생깁니다. Pod 의 `Controlled By` 를 보면 소유자를 알 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 2, 'Pod 를 직접 지우면', 'Deployment 가 관리하는 Pod 중 하나를 `kubectl delete pod` 로 지우면 어떻게 될까요?', 'ReplicaSet 이 "원하는 개수"를 지켜요.', NULL, NULL, '[]', 'choice', '["Pod 가 영구히 하나 줄어든다", "ReplicaSet 이 부족한 만큼 새 Pod 를 자동으로 만든다 (이름은 새로 정해진다)", "Deployment 가 함께 삭제된다", "Pod 가 같은 이름으로 그대로 되살아난다"]', 1, '그래서 Deployment 가 관리하는 Pod 를 지워서는 "서비스를 끄는" 효과를 낼 수 없습니다. 끄려면 replicas 를 0 으로 줄이세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 3, '업데이트하면 ReplicaSet 은', '이미지를 바꿔 업데이트한 뒤 `kubectl get rs` 를 보면 ReplicaSet 이 두 개 보입니다. 하나는 DESIRED 가 `0` 입니다. 이유는 무엇일까요?', '새 버전용과 옛 버전용이 따로 있어요.', NULL, NULL, '[]', 'choice', '["새 버전용 ReplicaSet 이 만들어지고, 옛 버전용은 0 으로 줄어든 채 남아 있다", "업데이트에 실패한 흔적이다", "버그라서 지워야 한다", "노드에 문제가 생긴 것이다"]', 0, '옛 ReplicaSet 은 롤백(`rollout undo`)을 위해 남겨 둡니다. 남겨 두는 개수는 `revisionHistoryLimit` 로 정해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 4, 'get rs 읽기', '`kubectl get rs` 의 `DESIRED 2  CURRENT 2  READY 2` 는 무슨 뜻일까요?', '원하는 수, 현재 수, 준비된 수예요.', NULL, NULL, '[]', 'choice', '["Pod 가 2번 재시작했다", "ReplicaSet 이 2개 있다", "노드가 2대다", "원하는 Pod 가 2개이고, 지금 2개가 만들어져 있고, 2개 모두 준비됐다"]', 3, '세 숫자가 서로 다르면 아직 맞추는 중이거나 문제가 있다는 신호입니다. 특히 READY 가 낮다면 Pod 의 상태를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 5, 'DaemonSet 이란', 'DaemonSet 은 어떤 일에 알맞을까요?', '"모든 노드에 하나씩"을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["웹 서버를 3개로 늘리는 일", "하루에 한 번 실행하는 백업 작업", "각 노드마다 Pod 를 하나씩 띄워야 하는 일 (로그 수집, 모니터링 에이전트 등)", "데이터베이스의 저장소를 만드는 일"]', 2, '노드가 늘면 자동으로 Pod 가 하나 더 생기고, 노드가 빠지면 그 Pod 도 사라집니다. 노드 1대짜리 클러스터에서는 Pod 도 1개예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 6, 'StatefulSet 이란', 'StatefulSet 은 Deployment 와 무엇이 다를까요?', '이름과 저장소를 기억해야 하는 일에 써요.', NULL, NULL, '[]', 'choice', '["Pod 를 가능한 한 빨리 삭제한다", "Pod 마다 고정된 이름(`db-0`, `db-1`)과 저장소를 유지한다. 데이터베이스처럼 상태가 있는 앱에 쓴다", "Pod 이름이 매번 무작위로 바뀐다", "컨테이너를 사용하지 않는다"]', 1, 'Deployment 의 Pod 는 서로 구별 없이 교체돼도 되는 앱에 알맞습니다. 상태가 있는 앱은 순서와 이름이 중요해서 StatefulSet 을 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 7, 'get all 의 범위', '`kubectl get all` 은 네임스페이스의 모든 리소스를 보여 줄까요?', '이름은 all 이지만 정말로 "전부"는 아니에요.', NULL, NULL, '[]', 'choice', '["아니다. Pod, Deployment, ReplicaSet, Service 같은 대표 리소스만 보이고 ConfigMap, Secret 등은 빠진다", "예, ConfigMap 과 Secret 도 모두 보인다", "아니다. Pod 만 보인다", "예, 모든 네임스페이스의 것이 보인다"]', 0, '설정이나 비밀이 있는지는 `kubectl get configmap`, `kubectl get secret` 으로 따로 봐야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 8, '500m 은 얼마일까', 'CPU `requests` 에 `500m` 이라고 적으면 어느 정도일까요?', 'm 은 milli, 1000분의 1 이에요.', NULL, NULL, '[]', 'choice', '["CPU 500 코어", "CPU 5 코어", "CPU 0.05 코어", "CPU 코어의 절반 (0.5 코어)"]', 3, '`1000m` 이 코어 1개입니다. 숫자만 `500` 이라고 쓰면 500 코어라서 스케줄링이 안 되니 단위를 꼭 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 9, 'cpu: "1" 은', '`limits` 에 `cpu: "1"` 이라고 적으면 무슨 뜻일까요?', '숫자만 쓰면 코어 단위예요.', NULL, NULL, '[]', 'choice', '["CPU 의 1%", "CPU 1 밀리코어", "CPU 코어 1개 (= 1000m)", "CPU 사용 제한 없음"]', 2, '`cpu: "1"` 과 `cpu: 1000m` 은 같은 뜻입니다. 따옴표로 감싼 것은 숫자를 문자열로 안전하게 적기 위해서예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 10, 'Mi 는 무엇일까', '`memory: 256Mi` 의 `Mi` 는 무엇을 뜻할까요?', '메모리는 MB 와 비슷하지만 조금 달라요.', NULL, NULL, '[]', 'choice', '["밀리코어", "메비바이트 (약 256 MB 에 해당하는 크기)", "분(minute)", "메가 비트"]', 1, '`256Mi` 는 256 × 1024 × 1024 바이트입니다. 소문자 `m` 은 메모리에서 의미가 달라서 `256m` 처럼 쓰면 엉뚱한 값이 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 11, 'create 와 apply', '이미 만든 리소스에 같은 파일로 `kubectl create -f` 를 한 번 더 하면 어떻게 될까요?', 'apply 와 달리 create 는 "새로 만들기"만 해요.', NULL, NULL, '[]', 'choice', '["`AlreadyExists` 오류가 난다. `apply` 는 있으면 필요한 만큼만 바꾸고 변화가 없으면 `unchanged` 로 끝난다", "항상 성공하고 값이 덮어써진다", "리소스가 삭제된다", "파일이 자동으로 수정된다"]', 0, '반복해서 적용해야 하는 YAML 은 `apply` 를 쓰는 것이 기본입니다. 같은 파일을 여러 번 적용해도 안전하기 때문이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 12, 'dry-run 은 무엇일까', '`kubectl create deployment web --image=nginx --dry-run=client -o yaml` 은 무엇을 할까요?', '"연습 실행"이라는 뜻의 dry-run 이에요.', NULL, NULL, '[]', 'choice', '["Deployment 를 만들고 YAML 을 지운다", "Pod 를 바로 실행한다", "이미지를 내려받기만 한다", "실제로 만들지 않고, 만들어질 YAML 만 출력한다"]', 3, '출력을 파일로 저장해 고친 뒤 `apply` 하면 YAML 뼈대를 손쉽게 만들 수 있습니다. 실제로 아무것도 만들어지지 않아 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 13, 'kubectl exec', '`kubectl exec -it web-abc -- sh` 에서 `--` 뒤의 `sh` 는 무엇일까요?', '컨테이너 안에서 실행할 명령이에요.', NULL, NULL, '[]', 'choice', '["kubectl 의 옵션", "Pod 의 이름", "컨테이너 안에서 실행할 명령 (쉘을 열어 직접 들어간다)", "컨테이너의 이미지 이름"]', 2, '`--` 는 "여기서부터는 kubectl 이 아니라 컨테이너 안의 명령"이라는 구분선입니다. 쉘이 없는 이미지에서는 `sh` 가 실패할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 14, 'port-forward 는 무엇일까', '`kubectl port-forward deploy/web 18080:80` 은 무엇을 할까요?', '내 컴퓨터의 문을 Pod 의 문과 이어 줘요.', NULL, NULL, '[]', 'choice', '["Service 를 영구히 만든다", "내 컴퓨터의 18080 포트를 Pod 의 80 포트로 임시 연결한다 (명령을 실행하는 동안만)", "Pod 의 포트를 80 에서 18080 으로 바꾼다", "방화벽을 해제한다"]', 1, 'Service 를 만들지 않고도 `curl localhost:18080` 으로 Pod 에 접속해 볼 수 있습니다. Ctrl+C 로 끝내면 연결도 사라져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 15, 'ReplicaSet 목록 보기', 'ReplicaSet 목록을 보는 명령입니다. 줄임말을 채우세요.', 'replicaset 의 앞글자 두 개예요.', NULL, NULL, '[]', 'fill', '["rs", "rset", "replica", "repl"]', NULL, '`rs` 는 `replicaset` 의 줄임말입니다. 줄임말로는 `po`(pods), `svc`(services), `deploy`(deployments) 도 자주 써요.', '[0]', 'kubectl get {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 16, '라벨로 Pod 찾기', '라벨이 `app=web` 인 **Pod 만** 보는 명령입니다. 빈칸을 채우세요.', '키=값 모양이에요.', NULL, NULL, '[]', 'fill', '["app=web", "app:web", "-app=web", "app web"]', NULL, '`-l` 은 label selector 입니다. Deployment 가 만든 Pod 를 한꺼번에 볼 때 편해요.', '[0]', 'kubectl get pods -l {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 17, '노드마다 하나씩', '노드마다 Pod 를 하나씩 띄우는 리소스 종류입니다. 빈칸을 채우세요.', '"모든 노드에 하나씩"을 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["DaemonSet", "DaemonPod", "NodeSet", "EachNode"]', NULL, 'DaemonSet 은 로그 수집기나 모니터링 에이전트처럼 모든 노드에 있어야 하는 프로그램에 씁니다.', '[0]', 'kind: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 18, 'CPU 반 코어', 'CPU 를 **반 코어**로 요청하려고 합니다. 값을 채우세요.', 'm 은 1000분의 1 이에요.', NULL, NULL, '[]', 'fill', '["500m", "0.5m", "500", "5m"]', NULL, '`500` 은 500 코어, `0.5m` 은 사실상 아주 작은 값입니다. `500m` 또는 `0.5` 라고 써야 반 코어예요.', '[0]', 'cpu: "{0}"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 19, '메모리 256Mi', '메모리를 **256Mi** 로 요청하려고 합니다. 올바른 모양을 채우세요.', '대문자 M 과 소문자 i 가 들어가요.', NULL, NULL, '[]', 'fill', '["256Mi", "256m", "256", "256mb"]', NULL, '`256` 은 256 바이트이고 `256mb` 는 올바른 단위가 아닙니다. `Mi`, `Gi` 를 쓰세요.', '[0]', 'memory: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 20, '파일로 적용하기', 'YAML 파일 `app.yaml` 을 **적용하는** 명령입니다. 빈칸을 채우세요.', '"적용하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["apply", "make", "run", "send"]', NULL, '`apply` 는 없으면 만들고 있으면 필요한 만큼만 바꿉니다. 같은 파일을 여러 번 적용해도 안전해요.', '[0]', 'kubectl {0} -f app.yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 21, '만들지 않고 YAML 만 보기', 'Deployment 를 **만들지 않고 YAML 만** 출력하려고 합니다. 값을 채우세요.', '클라이언트 쪽에서만 시험해 보는 방식이에요.', NULL, NULL, '[]', 'fill', '["client", "local", "dry", "simulate"]', NULL, '`--dry-run=client` 는 서버에도 보내지 않고 YAML 만 만들어 줍니다. 파일로 저장해 고친 뒤 `apply` 하세요.', '[0]', 'kubectl create deployment x --image=nginx --dry-run={0} -o yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 22, 'Pod 안에서 쉘 열기', '실행 중인 Pod `web` 안에서 **쉘을 여는** 명령의 마지막 부분을 채우세요.', '가장 기본적인 쉘의 이름이에요.', NULL, NULL, '[]', 'fill', '["sh", "ls", "exit", "kubectl"]', NULL, '`ls` 처럼 명령만 쓰면 그 명령을 한 번 실행하고 끝납니다. 직접 들어가려면 쉘(`sh`, `bash`)을 실행하세요.', '[0]', 'kubectl exec -it web -- {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 23, '컨테이너 쪽 포트', 'nginx Pod 의 80 포트에 내 컴퓨터 `18080` 을 연결하려고 합니다. 오른쪽 값을 채우세요.', '`내컴퓨터:Pod` 순서에서 오른쪽이에요.', NULL, NULL, '[]', 'fill', '["80", "18080", "8080", "443"]', NULL, '오른쪽은 Pod 안의 앱이 실제로 듣고 있는 포트여야 합니다. nginx 는 기본으로 80 을 씁니다.', '[0]', 'kubectl port-forward deploy/web 18080:{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 24, '파일에 적힌 것 지우기', 'YAML 파일에 적힌 리소스를 **지우는** 명령입니다. 빈칸을 채우세요.', '파일을 뜻하는 file 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-n", "-o", "-l"]', NULL, '`apply -f` 로 만든 것은 `delete -f` 로 같은 파일을 가리켜 지울 수 있습니다.', '[0]', 'kubectl delete {0} app.yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 25, '사용량 보기', 'Pod 별 **CPU·메모리 사용량**을 보는 명령입니다. 대상을 채우세요.', '리소스 종류를 복수형으로 써요.', NULL, NULL, '[]', 'fill', '["pods", "pod-use", "cpu", "usage"]', NULL, '`kubectl top` 은 metrics-server 가 있어야 동작합니다. 없거나 아직 준비되지 않았으면 `metrics not available` 오류가 나요.', '[0]', 'kubectl top {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 26, 'Deployment 가 만든 것 따라가기', 'Deployment 에서 시작해 실제로 만들어진 것들을 위에서 아래로 따라가는 순서입니다. 순서에 맞게 놓아 보세요.', '큰 것에서 작은 것으로 내려가요.', NULL, NULL, '[]', 'order', '["`kubectl get deployment` 로 Deployment 를 본다", "`kubectl get rs` 로 만들어진 ReplicaSet 을 본다", "`kubectl get pods` 로 Pod 를 본다", "`kubectl describe pod` 의 `Controlled By` 로 소유자가 ReplicaSet 임을 확인한다"]', NULL, '위에서 아래로 따라가면 문제가 어느 계층에서 생겼는지 알 수 있습니다. 예를 들어 RS 는 있는데 Pod 가 없다면 스케줄링 문제예요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 27, 'YAML 뼈대 만들어 적용하기', '직접 쓰기 어려운 YAML 을 뼈대부터 만들어 적용하는 순서입니다. 순서에 맞게 놓아 보세요.', '뼈대 출력 → 고치기 → 적용 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create deployment web --image=nginx --dry-run=client -o yaml > web.yaml` 로 뼈대를 파일로 저장한다", "`web.yaml` 을 열어 replicas 같은 값을 고친다", "`kubectl apply -f web.yaml` 로 적용한다", "`kubectl get pods` 로 Pod 가 만들어졌는지 확인한다"]', NULL, '처음부터 직접 쓰는 것보다 실수가 적습니다. `kubectl explain` 으로 필드의 뜻도 확인해 보세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 28, 'Pod 안에서 확인하기', 'Pod 안에 직접 들어가 확인하고 나오는 순서입니다. 순서에 맞게 놓아 보세요.', '이름 찾기 → 들어가기 → 확인 → 나오기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 Pod 이름을 찾는다", "`kubectl exec -it Pod이름 -- sh` 로 쉘을 연다", "안에서 `ls`, `env` 같은 명령으로 상태를 확인한다", "`exit` 로 나온다"]', NULL, '컨테이너 안에서 바꾼 내용은 Pod 가 재시작하면 사라집니다. 확인용으로만 쓰고 설정은 YAML 에 반영하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 145, 29, 'port-forward 로 임시 접속하기', 'Service 없이 Pod 에 임시로 접속해 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 확인 → 연결 → 접속 → 끝내기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 대상 Pod 가 Running 인지 본다", "`kubectl port-forward deploy/web 18080:80` 으로 포트를 연결한다", "다른 터미널에서 `curl localhost:18080` 으로 응답을 확인한다", "확인이 끝나면 Ctrl+C 로 연결을 끝낸다"]', NULL, 'port-forward 는 명령이 실행되는 동안만 유지됩니다. 터미널을 하나 더 열어서 접속을 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 145 AND order_index = 29);
