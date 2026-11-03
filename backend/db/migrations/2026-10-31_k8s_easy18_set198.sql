-- k8s 세트 198. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set198.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 198, 'Pod 스펙 필드 읽기: command·args, $(VAR), startupProbe, tolerations, hostAliases, 사이드카, --from-env-file', 'Pod 스펙의 필드가 실제로 만드는 동작을 한 개념씩 반복합니다. command 와 args 가 이미지의 ENTRYPOINT·CMD 를 바꾸는 방식, $(VAR) 치환과 $$ 이스케이프, kubectl run 의 -- 뒤 인자와 --command 와 --expose, securityContext 의 runAsUser·runAsGroup·fsGroup 과 runAsNonRoot, startupProbe 가 있는 동안 livenessProbe 가 미뤄지는 것과 실패했을 때의 이벤트, 자동으로 붙는 tolerationSeconds 300, hostAliases 와 /etc/hosts, shareProcessNamespace 와 PID 1, hostNetwork 의 Pod IP, restartPolicy: Always 인 init 컨테이너(사이드카), --from-env-file 과 --from-file 의 키, get --raw 의 healthz·readyz, kubectl version --client, generateName 과 create·apply 를 짧은 객관식·빈칸·순서 문제로 익히고, command·args 확인하기, 느리게 시작하는 앱에 startupProbe 달기, 클라이언트와 API 서버 상태 확인하기, 사이드카가 있는 Pod 확인하기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 198);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🔩' WHERE id = 198;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 1, 'command 와 args 함께 쓰기', '컨테이너에 `command: ["echo","A"]` 와 `args: ["B","C"]` 를 함께 지정하면 어떤 명령이 실행되고 무엇을 출력할까요?', 'command 는 프로그램, args 는 그 인자예요.', NULL, NULL, '[]', 'choice', '["`A` 만 출력한다. `args` 는 무시된다", "`B C` 만 출력한다. `args` 가 `command` 를 덮어쓴다", "`echo A B C` 가 실행되어 `A B C` 를 출력한다. `command` 가 실행할 프로그램이고 `args` 가 그 뒤에 붙는 인자이다", "둘을 함께 쓰면 오류로 Pod 가 만들어지지 않는다"]', 2, '`args` 만 쓰면 이미지의 ENTRYPOINT 는 그대로 두고 이미지의 CMD 만 바꿉니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 2, 'command 만 지정하면 이미지 설정은', '이미지가 `nginx` 를 띄우도록 만들어져 있을 때 컨테이너에 `command: ["echo","nginx-cmd"]` 만 지정하고 `restartPolicy: Never` 로 실행하면 어떻게 될까요?', 'command 는 이미지의 시작 명령을 대체해요.', NULL, NULL, '[]', 'choice', '["`nginx-cmd` 를 출력한 뒤 이미지의 CMD 대로 nginx 도 시작한다", "이미지의 ENTRYPOINT 와 CMD 가 모두 대체되어 `nginx-cmd` 한 줄만 출력하고 끝나며, nginx 서버는 시작되지 않는다", "이미지에 이미 시작 명령이 있으므로 `command` 는 무시된다", "`args` 가 없어서 Pod 가 만들어지지 않는다"]', 1, '`kubectl logs` 로 출력을, `kubectl get pod` 로 `Completed` 상태를 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 3, '$(VAR) 치환', '컨테이너에 `env: [{name: MSG, value: hi}]` 가 있고 `command: ["echo","$(MSG)","$MSG","$$(MSG)"]` 일 때 출력은 무엇일까요?', '쿠버네티스가 치환하는 것은 한 가지 모양이에요.', NULL, NULL, '[]', 'choice', '["`hi $MSG $(MSG)` 를 출력한다. 쿠버네티스가 `$(MSG)` 만 값으로 바꾸고, 쉘이 없어 `$MSG` 는 그대로이며, `$$(MSG)` 는 `$(MSG)` 글자로 이스케이프된다", "`hi hi hi` 를 출력한다", "`$(MSG) $MSG $$(MSG)` 를 그대로 출력한다", "`hi hi $(MSG)` 를 출력한다"]', 0, '정의되지 않은 이름 `$(NOPE)` 는 치환되지 않고 글자 그대로 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 4, 'kubectl run 의 -- 뒤 인자', '`kubectl run r1 --image=busybox:1.36 --dry-run=client -o yaml -- sleep 5` 와 `--command` 를 더한 `kubectl run r2 ... --command -- sleep 5` 는 YAML 에서 어떻게 다를까요?', '하나는 인자, 하나는 명령이에요.', NULL, NULL, '[]', 'choice', '["둘 다 `command` 에 들어간다", "둘 다 `args` 에 들어간다", "기본은 `command` 이고 `--command` 를 붙이면 `args` 에 들어간다", "`--` 뒤의 `sleep 5` 는 기본으로 `args` 에 들어가고, `--command` 를 붙이면 `command` 에 들어간다"]', 3, '`-- sh -c ''echo a b''` 는 `args: [sh, -c, echo a b]` 로 들어갑니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 5, 'kubectl run --expose', '`kubectl run web --image=nginx:1.27-alpine --port=80 --expose` 를 실행하면 무엇이 만들어질까요?', 'Pod 말고도 하나가 더 만들어져요.', NULL, NULL, '[]', 'choice', '["Deployment `web` 과 Service `web` 이 만들어진다", "Pod `web` 만 만들어지고 `--expose` 는 무시된다", "Pod `web`(라벨 `run=web`)과 같은 이름의 ClusterIP Service `web`(포트 80, 셀렉터 `run=web`)이 함께 만들어진다", "NodePort Service `web` 만 만들어지고 Pod 는 만들어지지 않는다"]', 2, '`kubectl get svc web -o jsonpath=''{.spec.selector}''` 로 셀렉터를 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 6, 'securityContext 의 사용자와 그룹', 'Pod 에 `securityContext: {runAsUser: 1000, runAsGroup: 3000, fsGroup: 2000}` 와 `emptyDir` 볼륨 `/data` 를 지정하고 `id` 와 `ls -ld /data` 를 하면 어떻게 보일까요?', '기본 그룹, 보조 그룹, 볼륨의 그룹을 따로 봐요.', NULL, NULL, '[]', 'choice', '["`uid=1000 gid=2000` 만 나오고 3000 은 나오지 않는다", "`uid=1000 gid=3000 groups=2000,3000` 으로 나오고 `/data` 는 그룹이 2000 이며 `drwxrwsrwx` 처럼 그룹 상속 비트(`s`)가 켜져 있다. 거기서 만든 파일의 그룹도 2000 이다", "`/data` 의 그룹은 항상 root 이다", "`fsGroup` 은 컨테이너의 기본 그룹 `gid` 를 바꾼다"]', 1, '`runAsNonRoot: true` 인데 이미지가 root 로 실행되면 `CreateContainerConfigError` 가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 7, 'startupProbe 가 있는 동안', '시작에 약 8초 걸리는 컨테이너에 `startupProbe` 와, 처음부터 실행되면 바로 실패할 `livenessProbe` 를 함께 달았습니다. 시작하는 동안 Pod 는 어떻게 보일까요?', 'startupProbe 가 성공하기 전에는 다른 프로브가 기다려요.', NULL, NULL, '[]', 'choice', '["`startupProbe` 가 성공할 때까지 `livenessProbe` 가 실행되지 않아 `Liveness probe failed` 이벤트가 생기지 않고, READY 는 `0/1` 에서 성공 뒤 `1/1` 이 된다", "시작 중에도 `livenessProbe` 가 실행되어 곧바로 `Killing` 이벤트가 생긴다", "READY 는 시작하자마자 `1/1` 이다", "`startupProbe` 는 이벤트를 남기지 않는다"]', 0, '`startupProbe` 가 실패하는 동안의 `Startup probe failed` 경고는 이벤트에 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 8, 'startupProbe 가 계속 실패하면', '`startupProbe: {exec: {command: [cat, /tmp/never]}, periodSeconds: 1, failureThreshold: 2}` 인 Pod 의 이벤트에는 무엇이 남을까요?', '실패 경고 뒤에 재시작 안내가 와요.', NULL, NULL, '[]', 'choice', '["`Liveness probe failed` 경고가 남는다", "이벤트는 남지 않고 Pod 가 `Error` 상태가 된다", "`failureThreshold` 와 상관없이 Pod 가 바로 삭제된다", "`Startup probe failed: cat: can''t open ''/tmp/never''...` 경고가 남고, 실패 횟수가 한도에 이르면 `Container c failed startup probe, will be restarted` 로 `Killing` 이벤트가 남는다"]', 3, '`kubectl describe pod` 의 `Events` 에서도 같은 내용을 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 9, '자동으로 붙는 tolerations', '`tolerations` 를 쓰지 않고 `kubectl run tol --image=busybox:1.36 --restart=Never -- sleep 30` 으로 만든 Pod 의 `spec.tolerations` 에는 무엇이 들어 있을까요?', '노드에 문제가 생겼을 때 잠시 견디는 설정이에요.', NULL, NULL, '[]', 'choice', '["비어 있다", "`node-role.kubernetes.io/control-plane` 톨러레이션만 들어 있다", "`node.kubernetes.io/not-ready` 와 `node.kubernetes.io/unreachable` 에 대한 `NoExecute` 톨러레이션이 `tolerationSeconds: 300` 으로 자동으로 들어 있다", "`tolerationSeconds: 0` 인 톨러레이션이 들어 있다"]', 2, '그래서 노드가 `NotReady` 가 되어도 이 Pod 는 기본으로 300초 동안 쫓겨나지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 10, 'hostAliases', 'Pod 에 `spec.hostAliases` 로 주소 하나에 이름 `foo.local`, `bar.local` 을 지정하면 컨테이너 안의 `/etc/hosts` 는 어떻게 될까요?', 'hosts 파일을 kubelet 이 관리해요.', NULL, NULL, '[]', 'choice', '["DNS 서버에 레코드가 등록되어 다른 Pod 에서도 해당 이름이 해석된다", "파일 끝에 `# Entries added by HostAliases.` 주석과 지정한 주소, 이름 `foo.local bar.local` 줄이 추가된다", "컨테이너 안에서 `/etc/hosts` 를 직접 고쳐야 반영된다", "노드의 `/etc/hosts` 가 바뀐다"]', 1, 'Pod 안의 컨테이너만 영향을 받고 클러스터 DNS 는 바뀌지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 11, 'shareProcessNamespace', '한 Pod 의 컨테이너 `a`(`sleep 3600`)와 `b`(`sleep 1234`)에 `shareProcessNamespace: true` 를 주면 `a` 에서 `ps` 를 했을 때 무엇이 보일까요? 설정하지 않으면요?', '프로세스 목록을 공유하는지 봐요.', NULL, NULL, '[]', 'choice', '["`b` 의 `sleep 1234` 도 보이고 PID 1 은 `/pause` 이다. 설정하지 않으면 다른 컨테이너의 프로세스는 보이지 않는다", "설정하지 않아도 `b` 의 프로세스가 보인다", "설정해도 자기 컨테이너 프로세스만 보인다", "PID 1 이 `sleep 3600` 이다"]', 0, '`hostPID: true` 는 컨테이너끼리가 아니라 노드의 프로세스를 보게 하는 다른 설정입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 12, 'hostNetwork 의 Pod IP', '`hostNetwork: true` 인 Pod 와 일반 Pod 의 `.status.podIP` 는 어떻게 다를까요?', '네트워크 네임스페이스를 노드와 공유해요.', NULL, NULL, '[]', 'choice', '["둘 다 Pod 대역의 별도 IP 를 받는다", "`hostNetwork: true` 인 Pod 는 IP 가 비어 있다", "`hostNetwork: true` 인 Pod 는 Service IP 를 받는다", "`hostNetwork: true` 인 Pod 는 `.status.podIP` 가 노드의 `.status.hostIP` 와 같고, 일반 Pod 는 Pod 대역의 별도 IP 를 받는다"]', 3, '`hostNetwork` 를 켜면 Pod 안의 포트가 노드의 포트를 그대로 쓰기 때문에 충돌할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 13, 'restartPolicy: Always 인 init 컨테이너', '`initContainers` 에 `restartPolicy: Always` 인 컨테이너 `logger` 와 일반 init 컨테이너 `setup`, 앱 컨테이너 `app` 이 있는 Pod 가 시작되면 어떻게 보일까요?', '사이드카는 init 단계 뒤에도 계속 실행돼요.', NULL, NULL, '[]', 'choice', '["`logger` 도 `setup` 처럼 끝난 뒤 종료되어 `1/1` 로 보인다", "`restartPolicy` 는 init 컨테이너에 쓸 수 없어 Pod 가 만들어지지 않는다", "`setup` 은 실행을 마치고 종료되고, `logger` 는 계속 실행되며 Pod 는 `2/2 Running`(`logger` 와 `app`)으로 보인다", "`app` 이 `logger` 보다 먼저 시작된다"]', 2, '`kubectl logs side -c logger` 로 사이드카의 로그를 따로 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 14, 'ConfigMap 을 파일에서 만들 때', '`kubectl create cm c-env --from-env-file=app.env`(`# comment`, `A=1`, 빈 줄, `B=two words` 가 든 파일)와 `kubectl create cm c-file --from-file=conf.txt` 의 `data` 는 각각 어떻게 될까요?', '하나는 줄마다 키와 값, 하나는 파일 전체가 값이에요.', NULL, NULL, '[]', 'choice', '["앞은 파일 전체를 `app.env` 키 하나에 넣는다", "앞은 주석과 빈 줄을 무시하고 `A=1`, `B=two words` 를 각각 키와 값으로 넣고, 뒤는 파일 이름 `conf.txt` 가 키이고 파일 전체 내용이 값이다", "앞은 `# comment` 도 키로 넣는다", "뒤는 줄마다 키와 값으로 나누어 넣는다"]', 1, '`--from-file=my=conf.txt` 처럼 쓰면 키 이름을 `my` 로 정할 수 있고, `--from-env-file` 과 `--from-file` 은 함께 쓸 수 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 15, '인자가 아니라 명령으로 넣기', '`kubectl run` 에서 `--` 뒤의 `sleep 5` 를 `args` 가 아닌 `command` 로 넣게 하는 옵션을 채우세요.', '"명령"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--command", "--cmd", "--exec", "--entrypoint"]', NULL, '옵션이 없으면 `args` 에 들어갑니다.', '[0]', 'kubectl run r1 --image=busybox:1.36 {0} -- sleep 5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 16, '환경 변수 파일로 ConfigMap 만들기', '`KEY=값` 줄로 된 파일에서 ConfigMap 을 만드는 옵션 이름을 채우세요.', '"from" 다음에 "env", "file" 이에요.', NULL, NULL, '[]', 'fill', '["from-env-file", "from-envfile", "env-file", "from-dotenv"]', NULL, '`#` 로 시작하는 줄과 빈 줄은 무시합니다.', '[0]', 'kubectl create configmap c --{0}=app.env', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 17, '준비 상태 항목별로 보기', 'API 서버의 준비 상태를 항목별로 보여 주는 요청 경로를 채우세요.', '"readyz" 에 "verbose" 를 붙여요.', NULL, NULL, '[]', 'fill', '["/readyz?verbose", "/readyz?detail", "/readyz/all", "/status?verbose"]', NULL, '마지막 줄에 `readyz check passed` 가 나옵니다.', '[0]', 'kubectl get --raw ''{0}''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 18, '서버 연결 없이 버전 보기', 'API 서버에 연결하지 않고 kubectl 클라이언트 버전만 출력하는 옵션을 채우세요.', '"클라이언트"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--client", "--local", "--short", "--offline"]', NULL, '`--short` 는 지금 없는 옵션이라 `unknown flag` 오류가 납니다.', '[0]', 'kubectl version {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 19, 'generateName 으로 만들기', '`metadata.generateName` 만 있고 `name` 이 없는 파일로 Pod 를 만들 때 쓸 수 있는 명령을 채우세요.', 'apply 는 `cannot use generate name with apply` 오류가 나요.', NULL, NULL, '[]', 'fill', '["create", "apply", "replace", "patch"]', NULL, '실행할 때마다 `gn-` 뒤에 무작위 5글자가 붙은 새 Pod 가 만들어집니다.', '[0]', 'kubectl {0} -f gn.yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 20, '우선순위 값 정하기', 'PriorityClass 의 우선순위 값을 정하는 `kubectl create priorityclass` 옵션을 채우세요.', '"값"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["value", "priority", "number", "level"]', NULL, '이 클래스를 쓰는 Pod 의 `spec.priority` 가 1000 이 됩니다.', '[0]', 'kubectl create priorityclass high --{0}=1000', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 21, '볼륨의 그룹 지정', 'Pod 의 볼륨 파일이 그룹 2000 으로 접근되게 하는 `securityContext` 필드 이름을 채우세요.', '"file" 과 "group" 을 합친 이름이에요.', NULL, NULL, '[]', 'fill', '["fsGroup", "groupId", "volumeGroup", "gid"]', NULL, '컨테이너의 보조 그룹에도 2000 이 들어갑니다.', '[0]', 'spec.securityContext.{0}: 2000', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 22, '프로세스 목록 공유', '한 Pod 의 컨테이너들이 서로의 프로세스를 보게 하는 필드 이름을 채우세요.', '"share" 로 시작하는 긴 이름이에요.', NULL, NULL, '[]', 'fill', '["shareProcessNamespace", "hostPID", "sharePID", "processShare"]', NULL, 'PID 1 은 `/pause` 가 됩니다.', '[0]', 'spec.{0}: true', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 23, 'hosts 파일에 줄 추가', 'Pod 의 `/etc/hosts` 에 주소와 이름 줄을 추가하는 필드 이름을 채우세요.', '"host" 와 "alias" 를 합친 이름이에요.', NULL, NULL, '[]', 'fill', '["hostAliases", "hosts", "extraHosts", "dnsHosts"]', NULL, '`# Entries added by HostAliases.` 주석 아래에 들어갑니다.', '[0]', 'spec.{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 24, '느린 시작을 기다리는 프로브', '시작이 끝날 때까지 다른 프로브를 미루는 컨테이너 필드 이름을 채우세요.', '"startup" 과 "probe" 를 합친 이름이에요.', NULL, NULL, '[]', 'fill', '["startupProbe", "bootProbe", "initProbe", "warmupProbe"]', NULL, '성공하기 전에는 `livenessProbe` 가 실행되지 않습니다.', '[0]', 'spec.containers[].{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 25, '사이드카 만들기', '`initContainers` 의 컨테이너를 끝나지 않고 계속 실행되는 사이드카로 만드는 필드를 채우세요.', '값은 `Always` 예요.', NULL, NULL, '[]', 'fill', '["restartPolicy", "sidecar", "keepAlive", "runPolicy"]', NULL, 'Pod 의 READY 개수에 사이드카도 포함됩니다.', '[0]', 'spec.initContainers[].{0}: Always', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 26, 'command 와 args 확인하기', '`command` 와 `args` 를 넣은 Pod 가 실제로 무엇을 실행하는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → 적용 → 끝나기를 기다림 → 로그 순서예요.', NULL, NULL, '[]', 'order', '["Pod YAML 의 컨테이너에 `command` 와 `args` 를 쓰고 `restartPolicy: Never` 로 둔다", "`kubectl apply -f p.yaml` 로 Pod 를 만든다", "`kubectl wait --for=jsonpath=''{.status.phase}''=Succeeded pod/p` 로 끝나기를 기다린다", "`kubectl logs p` 로 출력을 확인한다"]', NULL, '`restartPolicy: Never` 가 아니면 끝난 컨테이너가 다시 시작됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 27, '느리게 시작하는 앱에 startupProbe 달기', '시작이 느린 앱에 `startupProbe` 를 달고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '시간 계산 → 적용 → 상태 → 이벤트 순서예요.', NULL, NULL, '[]', 'order', '["앱이 시작하는 데 걸리는 최대 시간을 재고 `periodSeconds × failureThreshold` 가 그보다 크게 정한다", "`startupProbe` 를 추가한 Pod 를 `kubectl apply` 로 만든다", "`kubectl get pod` 로 READY 가 `0/1` 에서 `1/1` 로 바뀌는지 본다", "실패하면 `kubectl get events --field-selector involvedObject.name=Pod이름` 으로 `Startup probe failed` 이벤트를 확인한다"]', NULL, '한도를 넘기면 컨테이너가 `failed startup probe, will be restarted` 로 다시 시작됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 28, 'kubectl 과 API 서버 상태 확인하기', '클라이언트 버전과 API 서버의 상태를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '클라이언트 → 서버 포함 → 준비 → 항목별 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl version --client` 로 서버에 연결하지 않고 클라이언트 버전을 본다", "`kubectl version` 으로 `Server Version` 까지 본다", "`kubectl get --raw /readyz` 로 API 서버가 준비되었는지 본다", "`kubectl get --raw ''/readyz?verbose''` 로 항목별 결과를 본다"]', NULL, '`/healthz`, `/livez`, `/readyz` 는 정상이면 `ok` 를 출력합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 198, 29, '사이드카가 있는 Pod 확인하기', '사이드카가 있는 Pod 를 만들고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → 준비 대기 → 상태 → 로그 순서예요.', NULL, NULL, '[]', 'order', '["`initContainers` 에 `restartPolicy: Always` 인 사이드카 `logger` 와 일반 init 컨테이너 `setup` 을 쓰고 앱 컨테이너를 둔다", "`kubectl wait --for=condition=Ready pod/side` 로 Pod 가 준비될 때까지 기다린다", "`kubectl get pod side` 에서 `2/2 Running` 인지 확인한다", "`kubectl logs side -c logger` 로 사이드카의 로그를 확인한다"]', NULL, '일반 init 컨테이너 `setup` 은 `kubectl logs side -c setup` 으로 끝난 뒤의 로그를 볼 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 198 AND order_index = 29);
