-- 미들웨어 세트 128. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set128.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 6, 'k8s', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 6);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 128, 'k8s 쉬운 문제 1: 용어와 kubectl 기본 명령 한 줄씩', 'k8s 의 기본 용어와 kubectl 명령을 한 개념씩 쉬운 문제로 반복합니다. Pod·Deployment·Service·Namespace·Node 의 역할, READY 와 Pending·ImagePullBackOff·CrashLoopBackOff 읽기, label 과 replicas, get·describe·logs·apply·create·scale·exec·expose·rollout·delete 명령과 -n·-o wide·-A 옵션, 배포하고 확인하는 순서를 짧은 객관식·빈칸·순서 문제로 익힙니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 128);
UPDATE quest_set SET display_order = 204, unit_id = (SELECT id FROM unit WHERE id = 6), icon = '🐣' WHERE id = 128;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 1, 'Pod 는 무엇일까', 'k8s 에서 컨테이너를 실행하는 가장 작은 단위를 무엇이라고 부를까요?', '컨테이너를 감싸는 껍데기예요.', NULL, NULL, '[]', 'choice', '["Node", "Namespace", "Pod", "Service"]', 2, 'Pod 는 하나 이상의 컨테이너를 담는 k8s 의 최소 실행 단위입니다. 컨테이너를 직접 다루지 않고 Pod 를 통해 다뤄요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 2, 'Deployment 의 역할', 'Deployment 가 해 주는 일로 가장 알맞은 것은 무엇일까요?', '"항상 몇 개를 유지해 줘"라고 맡기는 대상이에요.', NULL, NULL, '[]', 'choice', '["컨테이너 이미지를 만든다", "원하는 개수의 Pod 를 항상 유지하고, 업데이트와 되돌리기를 관리한다", "노드를 새로 만든다", "네트워크 선을 연결한다"]', 1, 'Pod 를 직접 만들면 죽어도 되살아나지 않습니다. Deployment 에 맡기면 개수를 유지하고 롤링 업데이트와 롤백도 해 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 3, 'Service 의 역할', 'Service 가 해 주는 일로 가장 알맞은 것은 무엇일까요?', 'Pod 는 자주 바뀌지만 접속 주소는 그대로여야 해요.', NULL, NULL, '[]', 'choice', '["Pod 들 앞에서 고정된 이름과 주소를 주고 요청을 나눠 보낸다", "Pod 를 삭제한다", "이미지를 내려받는다", "로그를 저장한다"]', 0, 'Pod 의 IP 는 다시 만들어질 때마다 바뀝니다. Service 는 변하지 않는 입구 역할을 해서 다른 앱이 이름으로 접속하게 해 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 4, 'Namespace 는 무엇일까', 'Namespace 를 가장 잘 설명한 것은 무엇일까요?', '한 클러스터 안의 "구역"이에요.', NULL, NULL, '[]', 'choice', '["물리적으로 떨어진 서버", "컨테이너 이미지의 이름", "사용자의 비밀번호", "한 클러스터 안에서 리소스를 구역별로 나누는 논리적 칸막이"]', 3, '같은 이름의 리소스도 네임스페이스가 다르면 따로 존재합니다. 팀·환경별로 나눌 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 5, 'Node 는 무엇일까', 'k8s 에서 Pod 가 실제로 실행되는 서버(가상 머신이나 물리 서버)를 무엇이라고 부를까요?', '일꾼 컴퓨터예요.', NULL, NULL, '[]', 'choice', '["Pod", "Namespace", "Node(노드)", "Label"]', 2, '클러스터는 여러 Node 로 이루어지고, Pod 는 그중 한 Node 에 배치되어 실행됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 6, 'kubectl get pods 가 보여 주는 것', '`kubectl get pods` 를 실행하면 무엇이 나올까요?', '현재 네임스페이스의 Pod 목록이에요.', NULL, NULL, '[]', 'choice', '["모든 노드의 CPU 사용률", "현재 네임스페이스에 있는 Pod 의 목록과 상태", "클러스터의 비밀번호", "Pod 안의 파일 내용"]', 1, '`get` 은 목록을 보는 명령입니다. 다른 네임스페이스는 `-n 이름`, 전체는 `-A` 를 붙여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 7, 'READY 1/1 읽기', '`kubectl get pods` 결과의 READY 칸이 `1/1` 입니다. 무슨 뜻일까요?', '분수의 분모는 전체, 분자는 준비된 것이에요.', NULL, NULL, '[]', 'choice', '["Pod 안의 컨테이너 1개 중 1개가 준비됐다", "Pod 가 1개 중 1번째다", "재시작을 1번 했다", "CPU 를 1코어 쓴다"]', 0, '`2/3` 이면 컨테이너 3개 중 2개만 준비된 것이라 아직 문제가 있는 상태입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 8, 'Pending 은 무슨 뜻일까', 'Pod 의 STATUS 가 `Pending` 입니다. 가장 알맞은 해석은 무엇일까요?', '아직 시작하지 못하고 대기 중이에요.', NULL, NULL, '[]', 'choice', '["정상적으로 실행 중이다", "삭제가 끝났다", "이미지를 만드는 중이다", "아직 어느 노드에서도 실행되지 못하고 기다리는 중이다 (자원 부족, 스케줄 조건 등)"]', 3, 'Pending 이 오래가면 `kubectl describe pod` 의 Events 에서 이유(자원 부족, 노드 조건 불일치)를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 9, 'ImagePullBackOff 는 무엇일까', 'Pod 상태가 `ImagePullBackOff` 입니다. 가장 먼저 의심할 것은 무엇일까요?', '이미지를 내려받지 못하고 있어요.', NULL, NULL, '[]', 'choice', '["CPU 가 부족하다", "디스크 이름이 틀렸다", "이미지 이름·태그 오타, 또는 레지스트리 접근 권한", "노드가 꺼졌다"]', 2, '`describe pod` 의 Events 에 어떤 이미지를 왜 못 받았는지 나옵니다. 이미지 이름 오타가 가장 흔한 원인이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 10, 'CrashLoopBackOff 는 무엇일까', 'Pod 상태가 `CrashLoopBackOff` 입니다. 무슨 뜻일까요?', '컨테이너가 시작하자마자 죽는 일이 반복돼요.', NULL, NULL, '[]', 'choice', '["이미지를 내려받는 중이다", "컨테이너가 시작했다가 계속 죽어서 재시작이 반복되고 있다", "정상적으로 종료됐다", "노드가 부족하다"]', 1, '`kubectl logs 파드이름` 으로 죽기 전 출력을 보면 원인(잘못된 명령, 설정 오류)을 찾을 수 있습니다. 이미 재시작됐다면 `--previous` 를 붙여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 11, 'Pod 를 지우면 어떻게 될까', 'Deployment 가 관리하는 Pod 하나를 `kubectl delete pod` 로 지웠습니다. 잠시 후 어떻게 될까요?', 'Deployment 는 원하는 개수를 맞추려고 해요.', NULL, NULL, '[]', 'choice', '["Deployment 가 부족해진 개수를 채우려고 새 Pod 를 자동으로 만든다", "Deployment 도 함께 사라진다", "아무것도 만들어지지 않는다", "클러스터가 멈춘다"]', 0, '이것이 k8s 의 "원하는 상태를 유지한다"는 성질입니다. 정말 없애려면 Pod 가 아니라 Deployment 를 지우거나 replicas 를 줄여야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 12, 'describe 와 logs 의 차이', '`kubectl describe pod` 와 `kubectl logs` 의 차이로 알맞은 것은 무엇일까요?', '하나는 상태·이벤트, 하나는 프로그램의 출력이에요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`describe` 는 삭제, `logs` 는 생성이다", "`logs` 는 노드의 로그만 보여 준다", "`describe` 는 상태와 이벤트(스케줄, 이미지, 오류 기록), `logs` 는 컨테이너 안 프로그램이 출력한 로그를 보여 준다"]', 3, '시작조차 못 할 때는 `describe`(Events), 시작은 했는데 이상할 때는 `logs` 를 먼저 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 13, 'label 은 무엇일까', 'Pod 에 붙은 `app=web` 같은 label(라벨)은 무엇에 쓰일까요?', '꼬리표를 보고 골라낼 때 써요.', NULL, NULL, '[]', 'choice', '["Pod 의 비밀번호다", "Pod 의 CPU 제한이다", "Service 나 명령이 특정 Pod 들을 골라내는 꼬리표로 쓰인다", "이미지의 크기다"]', 2, 'Service 의 selector 가 라벨로 Pod 를 찾습니다. 라벨이 어긋나면 Service 가 Pod 를 못 찾아 연결이 안 돼요. `kubectl get pods -l app=web` 으로도 골라 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 14, 'replicas 는 무엇일까', 'Deployment 의 `replicas: 3` 은 무엇을 뜻할까요?', '복제본 개수예요.', NULL, NULL, '[]', 'choice', '["컨테이너를 3번만 재시작하라", "같은 Pod 를 3개 유지하라", "3분마다 로그를 남겨라", "노드를 3대 만들라"]', 1, 'replicas 를 바꾸면 Pod 수가 늘거나 줄어듭니다. 같은 Pod 가 여럿이라 하나가 죽어도 서비스가 이어져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 15, 'Pod 목록 보기', '현재 네임스페이스의 Pod 목록을 보는 명령입니다. 빈칸을 채우세요.', '"가져오다, 얻다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["get", "show", "list", "view"]', NULL, '`kubectl get 리소스` 가 가장 많이 쓰는 조회 명령입니다. `list` 나 `show` 는 kubectl 에 없는 명령이에요.', '[0]', 'kubectl {0} pods', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 16, '다른 네임스페이스 보기', '`kube-system` 네임스페이스의 Pod 목록을 보는 옵션을 채우세요.', 'namespace 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-n", "-a", "-p", "-o"]', NULL, '`-n`(--namespace)으로 네임스페이스를 고릅니다. 모든 네임스페이스는 `-A`(--all-namespaces) 예요.', '[0]', 'kubectl get pods {0} kube-system', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 17, '노드 위치까지 보기', 'Pod 목록에서 **IP 와 어느 노드에 있는지**까지 넓게 보는 옵션을 채우세요.', 'output 형식을 고르는 옵션이고, 넓게(wide) 보라고 해요.', NULL, NULL, '[]', 'fill', '["wide", "long", "full", "more"]', NULL, '`-o wide` 는 IP, NODE 같은 열을 더 보여 줍니다. `-o yaml` 은 전체 정의를 YAML 로 보여 줘요.', '[0]', 'kubectl get pods -o {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 18, 'Pod 상세 보기', 'Pod `web-1` 의 상세 정보와 **이벤트**를 보는 명령입니다. 빈칸을 채우세요.', '"설명하다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["describe", "get", "logs", "explain"]', NULL, '`describe` 마지막의 Events 에 스케줄 실패, 이미지 오류 같은 단서가 있습니다. 문제 조사의 첫 명령이에요.', '[0]', 'kubectl {0} pod web-1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 19, '로그 보기', 'Pod `web-1` 안 프로그램의 로그를 보는 명령입니다. 빈칸을 채우세요.', '영어로 기록, 로그예요.', NULL, NULL, '[]', 'fill', '["logs", "describe", "cat", "show"]', NULL, '`kubectl logs` 는 컨테이너가 표준 출력으로 남긴 내용을 보여 줍니다. 계속 따라가며 보려면 `-f` 를 붙여요.', '[0]', 'kubectl {0} web-1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 20, 'YAML 파일로 만들기', '`app.yaml` 파일에 적은 리소스를 클러스터에 **적용**(없으면 만들고, 있으면 바꿈)하는 명령입니다. 빈칸을 채우세요.', '파일(file)을 뜻하는 옵션이 붙어요.', NULL, NULL, '[]', 'fill', '["-f", "-n", "-o", "-l"]', NULL, '`apply -f` 는 선언한 상태로 맞춥니다. 같은 파일로 다시 실행해도 안전해서(멱등) 가장 많이 쓰는 배포 명령이에요.', '[0]', 'kubectl apply {0} app.yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 21, 'Deployment 만들기', '이미지 `nginx` 로 `web` 이라는 Deployment 를 만드는 명령입니다. 빈칸을 채우세요.', '"만들다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["create", "make", "new", "run"]', NULL, '`kubectl create deployment 이름 --image=이미지` 로 한 줄에 만들 수 있습니다. 시험이나 실습에서 YAML 보다 빠르게 시작할 때 써요.', '[0]', 'kubectl {0} deployment web --image=nginx', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 22, 'Pod 개수 늘리기', 'Deployment `web` 의 Pod 를 5개로 조정하는 명령입니다. 빈칸을 채우세요.', '"규모를 조정하다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["scale", "resize", "set", "expand"]', NULL, '`scale` 은 replicas 를 바꿉니다. 줄일 때도 같은 명령에 작은 수를 쓰면 돼요.', '[0]', 'kubectl {0} deployment web --replicas=5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 23, 'Pod 안으로 들어가기', 'Pod `web-1` 안에서 쉘을 열어 직접 확인하는 명령입니다. 빈칸을 채우세요.', '실행(execute)의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["exec", "run", "enter", "login"]', NULL, '`exec -it` 는 실행 중인 컨테이너 안에서 명령을 실행합니다. `--` 뒤가 컨테이너 안에서 실행할 명령이에요.', '[0]', 'kubectl {0} -it web-1 -- sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 24, 'Service 로 노출하기', 'Deployment `web` 을 80 포트의 Service 로 노출하는 명령입니다. 빈칸을 채우세요.', '"노출하다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["expose", "open", "publish", "connect"]', NULL, '`expose` 는 Deployment 를 가리키는 Service 를 만들어 줍니다. 유형(`--type=NodePort`)도 고를 수 있어요.', '[0]', 'kubectl {0} deployment web --port=80', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 25, '롤아웃 진행 보기', 'Deployment `web` 의 업데이트가 끝났는지 지켜보는 명령입니다. 빈칸을 채우세요.', '"상태"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["status", "check", "watch", "wait"]', NULL, '`rollout status` 는 새 Pod 가 모두 준비될 때까지 기다리며 진행 상황을 보여 줍니다. 문제가 있으면 `rollout undo` 로 되돌려요.', '[0]', 'kubectl rollout {0} deployment web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 26, '리소스 삭제하기', 'Service `web` 을 삭제하는 명령입니다. 빈칸을 채우세요.', '"삭제하다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["delete", "remove", "rm", "destroy"]', NULL, '`delete` 는 즉시 삭제합니다. 어느 네임스페이스인지 확인하고 실행하세요. `kubectl delete -f app.yaml` 로 파일에 적은 것을 한꺼번에 지울 수 있어요.', '[0]', 'kubectl {0} service web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 27, '모든 네임스페이스 보기', '모든 네임스페이스의 Pod 를 한꺼번에 보는 옵션을 채우세요.', 'all 의 첫 글자를 대문자로 써요.', NULL, NULL, '[]', 'fill', '["-A", "-a", "-all", "-n"]', NULL, '`-A` 는 `--all-namespaces` 의 줄임입니다. 장애 때 어디서 문제인지 모를 때 가장 먼저 씁니다.', '[0]', 'kubectl get pods {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 28, '배포하고 확인하는 순서', 'YAML 파일로 앱을 배포하고 잘 떴는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '배포 → 목록 → 진행 확인 → 접속 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl apply -f app.yaml`", "`kubectl get pods`", "`kubectl rollout status deployment web`", "`kubectl get svc`"]', NULL, '배포하고 끝내지 말고 "정말 떴는지" 확인하는 습관이 중요합니다. Pod 가 Running 이고 Service 가 있는지 보세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 29, '고장 난 Pod 조사 순서', 'Pod 가 이상합니다. 원인을 찾는 순서에 맞게 놓아 보세요.', '목록 → 상세 → 로그 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 상태를 본다", "`kubectl describe pod` 로 Events 를 본다", "`kubectl logs` 로 프로그램 출력을 본다", "원인을 고치고 다시 상태를 확인한다"]', NULL, '상태 → Events → 로그 순서로 좁혀 가면 대부분 원인을 찾습니다. 고친 뒤 다시 `get pods` 로 확인해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 29);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 30, 'Pod 개수 바꾸고 확인하기', 'Deployment 의 Pod 를 3개로 늘리고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '지금 상태 → 변경 → 결과 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get deployment web`", "`kubectl scale deployment web --replicas=3`", "`kubectl get pods`", "`kubectl get deployment web -o wide`"]', NULL, '바꾸기 전과 후를 같은 명령으로 비교하면 변화를 눈으로 확인할 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 30);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 128, 31, 'Service 로 열고 확인하는 순서', 'Deployment 를 만들고 Service 로 노출해 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 노출 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl create deployment web --image=nginx`", "`kubectl expose deployment web --port=80`", "`kubectl get svc web`"]', NULL, 'Deployment 가 있어야 expose 할 수 있습니다. 마지막에 Service 가 만들어졌는지 확인하세요.', '[0, 1, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 128 AND order_index = 31);
