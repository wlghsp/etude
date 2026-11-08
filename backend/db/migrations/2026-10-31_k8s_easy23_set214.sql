-- k8s 세트 214. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set214.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 214, '컨테이너 실행과 점검: command·args, workingDir, 프로브, logs -c, --cascade=orphan, set env·resources, 서비스 DNS', '컨테이너 실행 설정과 점검, 확인 도구의 기본 동작을 한 개념씩 반복합니다. command 와 args 가 ENTRYPOINT 와 CMD 를 덮어쓰는 것, workingDir, liveness 의 httpGet 실패와 재시작, readiness 의 tcpSocket 실패가 0/1 Running 과 ready false 로 보이는 것, exec probe 의 종료 코드, 컨테이너가 둘인 Pod 의 logs 와 -c, --all-containers, --prefix, 없는 컨테이너 이름의 오류, --cascade=orphan 으로 ReplicaSet 과 Pod 를 남기는 것, set env 와 set resources 가 롤아웃을 일으키는 것, Pod 에는 set env 가 거부되는 것, 다른 네임스페이스의 서비스 DNS 이름, get --raw 의 healthz 와 kubectl version 읽기를 짧은 객관식·빈칸·순서 문제로 익히고, 명령과 작업 폴더 정하기, 준비 점검 실패 읽기, 환경 변수를 바꾸고 롤아웃, liveness 실패 읽기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 214);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🛰️' WHERE id = 214;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 1, 'command 와 args', 'Pod 의 컨테이너에 `command: ["echo", "cmd"]` 와 `args: ["x"]` 를 주면 컨테이너는 무엇을 실행하고 무엇을 출력할까요?', 'command 는 실행할 프로그램, args 는 그 뒤에 붙는 인자예요.', NULL, NULL, '[]', 'choice', '["`echo x` 를 실행해 `x` 만 출력한다", "`args` 가 `command` 를 덮어써서 `x` 를 명령으로 실행하려다 실패한다", "`echo cmd x` 를 실행해 `cmd x` 를 출력한다. `command` 는 이미지의 ENTRYPOINT 를, `args` 는 이미지의 CMD 를 덮어쓴다", "둘 다 무시되고 이미지의 기본 명령이 실행된다"]', 2, '이미지에 ENTRYPOINT 가 없는 `busybox` 는 `args` 만 줘도 그 값을 명령으로 실행합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 2, 'workingDir', '컨테이너에 `workingDir: /tmp` 를 주고 `pwd` 를 실행하면 무엇이 출력될까요?', '시작할 때의 현재 폴더를 정해요.', NULL, NULL, '[]', 'choice', '["`/` 가 출력되고 `workingDir` 은 무시된다", "`/tmp` 가 출력된다. `workingDir` 은 컨테이너 명령이 시작할 때의 작업 폴더를 정한다", "`/root` 가 출력된다", "`workingDir` 은 Pod 를 만들 때 오류가 난다"]', 1, '이미지가 정한 기본 작업 폴더보다 `workingDir` 이 우선합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 3, 'liveness probe 실패', 'nginx 컨테이너에 `livenessProbe` 로 `httpGet: path /nope, port 80` 를 주었습니다. 이 경로는 404 를 돌려줍니다. 어떻게 될까요?', 'liveness 실패는 재시작이에요.', NULL, NULL, '[]', 'choice', '["`Liveness probe failed: HTTP probe failed with statuscode: 404` 이벤트가 나고 컨테이너가 재시작되어 RESTARTS 가 늘어난다. 계속 실패하면 `CrashLoopBackOff` 가 된다", "아무 일도 없고 Pod 는 `1/1 Running` 으로 유지된다", "Pod 가 삭제되고 새 이름으로 다시 만들어진다", "READY 만 `0/1` 이 되고 재시작은 하지 않는다"]', 0, '`httpGet` 은 `path` 와 `port` 로 HTTP 요청을 보내 점검합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 4, 'readiness probe 실패', 'nginx 컨테이너에 `readinessProbe` 로 `tcpSocket: port 81` 을 주었습니다. 81 번 포트는 닫혀 있습니다. Pod 의 상태는 어떻게 보일까요?', 'readiness 실패는 재시작이 아니에요.', NULL, NULL, '[]', 'choice', '["재시작이 계속되어 `CrashLoopBackOff` 가 된다", "READY 가 `1/1` 로 보이고 이벤트만 쌓인다", "Pod 가 `Pending` 에서 벗어나지 못한다", "STATUS 는 `Running` 이지만 READY 는 `0/1` 이고 RESTARTS 는 `0` 이다. Ready 조건이 `False` 이고 엔드포인트 슬라이스에서는 `ready` 가 `false` 로 표시된다"]', 3, '준비 점검이 실패한 Pod 는 서비스의 대상에서 준비 안 됨으로 표시됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 5, 'exec probe', '`livenessProbe` 에 `exec: command: [cat, /tmp/healthy]` 를 주고 컨테이너가 `/tmp/healthy` 파일을 지웠습니다. 어떻게 될까요?', '명령이 실패하면 probe 도 실패예요.', NULL, NULL, '[]', 'choice', '["파일이 없어도 probe 는 성공으로 처리된다", "종료 코드와 상관없이 출력이 있으면 성공이다", "`cat` 이 실패하므로 `Liveness probe failed: cat: can''t open ''/tmp/healthy''...` 이벤트가 난다. exec probe 는 명령의 종료 코드가 `0` 이면 성공, 아니면 실패이다", "exec probe 는 Pod 를 만들 때만 한 번 실행된다"]', 2, '`initialDelaySeconds`, `periodSeconds`, `failureThreshold` 로 점검 시기와 횟수를 정합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 6, '컨테이너가 둘인 Pod 의 logs', '컨테이너 `c1`, `c2` 가 있는 Pod `mc` 에 `kubectl logs mc` 를 하면 어떻게 될까요? `c2` 의 로그를 보려면, 두 컨테이너 로그를 모두 보려면요?', '컨테이너 이름을 -c 로 정해요.', NULL, NULL, '[]', 'choice', '["오류로 끝나고 로그가 나오지 않는다", "`Defaulted container \\"c1\\" out of: c1, c2` 안내가 나오고 첫 번째 컨테이너 `c1` 의 로그를 보여 준다. `c2` 는 `-c c2`, 모두 보려면 `--all-containers` 를 쓰고 `--prefix` 를 더하면 줄 앞에 `[pod/mc/c1]` 처럼 붙는다", "두 컨테이너의 로그가 모두 자동으로 나온다", "`-c` 는 `kubectl logs` 에서 쓸 수 없다"]', 1, '`kubectl exec` 도 `-c` 가 없으면 같은 안내와 함께 첫 번째 컨테이너를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 7, '없는 컨테이너 이름', '컨테이너 `c1`, `c2` 가 있는 Pod `mc` 에 `kubectl exec mc -c nosuch -- echo x` 를 하면 어떻게 될까요?', '오류 메시지가 후보를 알려 줘요.', NULL, NULL, '[]', 'choice', '["`error: container nosuch is not valid for pod mc out of: c1, c2` 오류가 나서 가능한 이름을 알려 준다", "첫 번째 컨테이너에서 `echo x` 가 실행된다", "`nosuch` 컨테이너가 새로 만들어진다", "아무 출력 없이 종료 코드 `0` 으로 끝난다"]', 0, '컨테이너 이름은 `kubectl get pod mc -o jsonpath` 로 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 8, '--cascade=orphan', 'Deployment `dd` 를 `kubectl delete deploy dd --cascade=orphan` 으로 지우면 ReplicaSet 과 Pod 는 어떻게 될까요? 그냥 지우면요?', 'orphan 은 고아로 남긴다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["`--cascade=orphan` 이어도 ReplicaSet 과 Pod 가 모두 함께 지워진다", "Deployment 는 남고 ReplicaSet 만 지워진다", "Pod 만 지워지고 ReplicaSet 은 Deployment 에 그대로 연결된다", "Deployment 만 지워지고 ReplicaSet 과 Pod 는 남으며 소유자 정보(`ownerReferences`)가 사라진다. 그냥 `kubectl delete deploy dd` 로 지우면 ReplicaSet 도 함께 지워진다"]', 3, '남은 ReplicaSet 을 지우면 그 Pod 도 지워집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 9, 'kubectl set env', '`kubectl set env deploy/de GREET=hello` 를 하면 어떤 일이 일어날까요? 값을 보려면, 지우려면요?', 'Pod 템플릿이 바뀌면 롤아웃이 일어나요.', NULL, NULL, '[]', 'choice', '["실행 중인 Pod 에 바로 반영되고 새 ReplicaSet 은 만들어지지 않는다", "Deployment 가 아니라 노드의 환경 변수가 바뀐다", "Pod 템플릿에 환경 변수가 추가되어 새 ReplicaSet 으로 롤아웃된다. 값은 `kubectl set env deploy/de --list`, 지울 때는 `GREET-` 처럼 이름 뒤에 `-` 를 붙인다", "`set env` 는 읽기 전용이라 값을 바꿀 수 없다"]', 2, '`kubectl rollout status deploy/de` 로 롤아웃이 끝났는지 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 10, 'Pod 에는 set env 가 안 된다', '단독으로 만든 Pod `mc` 에 `kubectl set env pod/mc X=1` 을 하면 어떻게 될까요?', 'Pod 는 대부분의 필드를 만든 뒤에 못 바꿔요.', NULL, NULL, '[]', 'choice', '["Pod 가 재시작되며 `X=1` 이 적용된다", "`pod updates may not change fields other than ...` 오류로 거부된다. 환경 변수는 Pod 를 다시 만들거나 Deployment 같은 상위 객체의 템플릿에서 바꾼다", "오류 없이 적용되고 `kubectl set env pod/mc --list` 에 보인다", "Pod 가 삭제되고 같은 이름으로 다시 만들어진다"]', 1, '그래서 보통 Deployment 의 Pod 템플릿을 고쳐 롤아웃합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 11, 'kubectl set resources', '`kubectl set resources deploy/de --limits=cpu=200m,memory=64Mi --requests=cpu=100m` 을 하면 무엇이 일어날까요? `requests` 에 memory 를 따로 주지 않았다면 Pod 의 memory requests 는요?', 'limits 만 주면 requests 가 같은 값으로 채워져요.', NULL, NULL, '[]', 'choice', '["Pod 템플릿의 `resources` 가 바뀌어 롤아웃된다. memory `requests` 는 따로 주지 않아도 limits 와 같은 `64Mi` 로 채워진다. 이 경우 QoS 는 `Burstable` 이다", "실행 중인 Pod 에 바로 적용되며 롤아웃은 일어나지 않는다", "memory `requests` 는 `0` 이 된다", "memory `requests` 를 주지 않으면 오류가 난다"]', 0, '`kubectl get pod -o jsonpath=''{.status.qosClass}''` 로 QoS 를 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 12, '서비스 DNS 이름', '같은 네임스페이스의 Pod 에서는 Service `web` 에 `http://web` 으로 접근됩니다. 다른 네임스페이스의 Pod 에서 `http://web` 으로 접근하면 어떻게 될까요? 어떻게 써야 할까요?', '서비스 이름 뒤에 네임스페이스를 붙여요.', NULL, NULL, '[]', 'choice', '["다른 네임스페이스에서도 `web` 만으로 접근된다", "다른 네임스페이스의 Service 에는 접근할 수 없다", "`web:네임스페이스` 로 써야 한다", "`bad address ''web''` 처럼 이름을 찾지 못한다. `web.네임스페이스` 또는 `web.네임스페이스.svc.cluster.local` 로 쓰면 접근된다"]', 3, 'Pod 의 `/etc/resolv.conf` 의 `search` 줄에 자기 네임스페이스가 먼저 들어 있어서 짧은 이름이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 13, 'API 서버 상태 확인', '`kubectl get --raw /healthz` 는 무엇을 출력할까요? 없는 경로 `/nosuch` 를 주면요?', '정상이면 짧게 한 단어예요.', NULL, NULL, '[]', 'choice', '["`healthy` 라는 단어와 노드 목록을 출력한다", "없는 경로도 빈 JSON 을 출력하고 성공한다", "정상이면 `ok` 를 출력한다. 없는 경로는 `Error from server (NotFound): the server could not find the requested resource` 오류가 난다. `/readyz`, `/livez` 도 같은 방식이다", "`--raw` 는 관리자만 쓸 수 있어서 오류가 난다"]', 2, '`kubectl get --raw /version` 은 JSON 으로 서버 버전을 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 14, 'kubectl version 읽기', '`kubectl version` 의 출력에 나오는 세 가지 항목은 무엇일까요?', '내 kubectl 과 서버의 버전을 함께 보여 줘요.', NULL, NULL, '[]', 'choice', '["`Client Version`, `Node Version`, `Pod Version` 이다", "`Client Version`, `Kustomize Version`, `Server Version` 이다. 내 kubectl 의 버전과 연결된 클러스터 서버의 버전을 함께 보여 준다", "`Kubectl Version` 만 나오고 서버 버전은 나오지 않는다", "`Master Version`, `Worker Version`, `Etcd Version` 이다"]', 1, '`kubectl cluster-info` 는 control plane 과 CoreDNS 의 주소를 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 15, '컨테이너 실행 파일 정하기', '컨테이너가 **시작할 프로그램을 정하는** 필드를 채우세요.', '"명령"을 영어로 써요.', NULL, NULL, '[]', 'fill', '["command", "entrypoint", "exec", "run"]', NULL, '이미지의 ENTRYPOINT 를 덮어씁니다.', '[0]', 'image: busybox:1.36, {0}: [''echo''], args: [''hi'']', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 16, '명령의 인자 정하기', '`command` 뒤에 붙는 **인자를 정하는** 필드를 채우세요.', '"arguments"를 줄인 말이에요.', NULL, NULL, '[]', 'fill', '["args", "params", "argv", "cmd"]', NULL, '이미지의 CMD 를 덮어씁니다.', '[0]', 'command: [''echo''], {0}: [''hi'']', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 17, '작업 폴더 정하기', '컨테이너 명령이 **시작할 작업 폴더를 정하는** 필드를 채우세요.', '"working"과 "Dir"을 이어요.', NULL, NULL, '[]', 'fill', '["workingDir", "workdir", "cwd", "dir"]', NULL, '대소문자를 정확히 써야 합니다.', '[0]', 'image: busybox:1.36, {0}: /tmp', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 18, 'HTTP 로 점검', 'probe 가 **HTTP 요청으로 점검하는** 필드를 채우세요.', '"http"와 "Get"을 이어요.', NULL, NULL, '[]', 'fill', '["httpGet", "httpRequest", "httpCheck", "httpPing"]', NULL, '404 같은 오류 응답이면 실패입니다.', '[0]', 'livenessProbe: {0}: path /healthz, port 80', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 19, 'TCP 연결로 점검', 'probe 가 **TCP 포트 연결로 점검하는** 필드를 채우세요.', '"tcp"와 "Socket"을 이어요.', NULL, NULL, '[]', 'fill', '["tcpSocket", "tcpPort", "tcpCheck", "tcpConnect"]', NULL, '포트에 연결되면 성공입니다.', '[0]', 'readinessProbe: {0}: port 80', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 20, '컨테이너 고르기', '여러 컨테이너 중 **하나를 고르는** `kubectl logs` 옵션을 채우세요.', '"container"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-c", "-C", "--ctr", "-k"]', NULL, '`kubectl exec` 에서도 같습니다.', '[0]', 'kubectl logs mc {0} c2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 21, '모든 컨테이너 로그', 'Pod 의 **모든 컨테이너 로그를 한꺼번에 보는** 옵션을 채우세요.', '"all"과 "containers"를 이어요.', NULL, NULL, '[]', 'fill', '["--all-containers", "--all", "--every", "--containers"]', NULL, '`--prefix` 를 더하면 줄 앞에 컨테이너 이름이 붙습니다.', '[0]', 'kubectl logs mc {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 22, '고아로 남기기', 'Deployment 를 지울 때 **ReplicaSet 과 Pod 를 남기는** `--cascade` 값을 채우세요.', '"고아"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["orphan", "keep", "skip", "detach"]', NULL, '소유자 정보가 사라집니다.', '[0]', 'kubectl delete deploy dd --cascade={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 23, '환경 변수 바꾸기', 'Deployment 의 **환경 변수를 바꾸는** `kubectl set` 하위 명령을 채우세요.', '"environment"를 줄인 말이에요.', NULL, NULL, '[]', 'fill', '["env", "var", "config", "param"]', NULL, '롤아웃이 일어납니다.', '[0]', 'kubectl set {0} deploy/de GREET=hello', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 24, '자원 값 바꾸기', 'Deployment 의 **requests 와 limits 를 바꾸는** `kubectl set` 하위 명령을 채우세요.', '"resources"예요.', NULL, NULL, '[]', 'fill', '["resources", "limits", "quota", "cpu"]', NULL, '롤아웃이 일어납니다.', '[0]', 'kubectl set {0} deploy/de --limits=cpu=200m', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 25, 'API 경로 직접 요청', '`kubectl get` 으로 **API 서버의 경로를 그대로 요청하는** 옵션을 채우세요.', '"날것"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["--raw", "--url", "--path", "--api"]', NULL, '정상이면 `ok` 가 출력됩니다.', '[0]', 'kubectl get {0} /healthz', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 26, '명령과 작업 폴더 정하기', '컨테이너가 실행할 명령과 작업 폴더를 정하고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '정의 → 끝남 확인 → 로그 → 작업 폴더 순서예요.', NULL, NULL, '[]', 'order', '["`command: [\\"echo\\"]` 와 `args: [\\"a\\", \\"b\\"]` 를 준 Pod `c1` 을 `restartPolicy: Never` 로 만든다", "`kubectl get pod c1 -o jsonpath=''{.status.phase}''` 가 `Succeeded` 인지 확인한다", "`kubectl logs c1` 에 `a b` 가 출력되는지 확인한다", "`workingDir: /tmp` 와 `pwd` 를 준 새 Pod 의 로그에 `/tmp` 가 나오는지 확인한다"]', NULL, '한 번 실행하고 끝나는 Pod 는 `restartPolicy: Never` 로 만듭니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 27, '준비 점검 실패 읽기', 'readiness probe 가 실패하는 Pod 를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 상태 → 엔드포인트 → 비교 순서예요.', NULL, NULL, '[]', 'order', '["`readinessProbe` 가 닫힌 포트(`tcpSocket`)를 가리키는 Pod 를 만든다", "`kubectl get pod` 에서 READY `0/1`, STATUS `Running`, RESTARTS `0` 인지 확인한다", "`kubectl get endpointslices` 의 해당 Pod 항목에서 `ready` 가 `false` 인지 본다", "올바른 포트를 가리키는 Pod 는 `1/1` 이고 `ready` 가 `true` 인지 비교한다"]', NULL, 'liveness 와 달리 readiness 는 재시작하지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 28, '환경 변수를 바꾸고 롤아웃', 'Deployment 의 환경 변수를 바꾸고 롤아웃을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 바꾸기 → 롤아웃 → 값 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create deploy de --image=nginx:1.27-alpine` 으로 만들고 `kubectl rollout status deploy/de` 로 기다린다", "`kubectl set env deploy/de GREET=hello` 로 환경 변수를 추가한다", "`kubectl rollout status deploy/de` 후 `kubectl get rs` 에 ReplicaSet 이 두 개 보이는지 확인한다", "`kubectl set env deploy/de --list` 에 `GREET=hello` 가 나오는지 확인한다"]', NULL, '지울 때는 `kubectl set env deploy/de GREET-` 입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 214, 29, 'liveness 실패 읽기', 'liveness probe 가 실패하는 Pod 를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 재시작 확인 → 이벤트 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`livenessProbe` 의 `httpGet` 경로가 없는 경로인 nginx Pod 를 만든다", "`kubectl get pod` 에서 RESTARTS 가 늘어나는지 본다", "`kubectl events --for pod/lh` 에서 `Liveness probe failed: HTTP probe failed with statuscode: 404` 를 확인한다", "`kubectl delete pod lh` 로 Pod 를 지운다"]', NULL, '계속 실패하면 STATUS 가 `CrashLoopBackOff` 로 보입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 214 AND order_index = 29);
