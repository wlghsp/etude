-- k8s 세트 151. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set151.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 151, 'Pod 수명주기, 이미지 정책, 라벨 셀렉터, 출력 고르기 한 줄씩', 'Pod 가 시작되고 끝나는 과정과 라벨로 고르는 방법을 한 개념씩 반복합니다. init 컨테이너와 Init:0/1 읽기, restartPolicy 의 Always·OnFailure·Never 와 Completed, imagePullPolicy 기본값과 IfNotPresent 의 함정, terminationGracePeriodSeconds 와 삭제가 30초 걸리는 이유, 라벨 셀렉터의 in·!=·존재·부재·쉼표(AND), custom-columns, scale 을 짧은 객관식·빈칸·순서 문제로 익히고, Init 에서 멈춘 Pod, 재시작하지 않는 Pod, 라벨로 좁히기, 삭제가 느릴 때의 조사 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 151);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '⏳' WHERE id = 151;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 1, 'init 컨테이너란', 'Pod 의 `initContainers` 는 무엇일까요?', '본 컨테이너가 시작되기 전에 준비 작업을 해요.', NULL, NULL, '[]', 'choice', '["본 컨테이너와 동시에 계속 실행되는 보조 컨테이너", "본 컨테이너가 끝난 뒤에 실행되는 정리용 컨테이너", "본 컨테이너보다 먼저 순서대로 실행되고, 모두 성공해야 본 컨테이너가 시작되는 준비용 컨테이너", "Pod 를 삭제할 때만 실행되는 컨테이너"]', 2, '데이터베이스가 준비될 때까지 기다리거나 설정 파일을 미리 만들어 둘 때 씁니다. init 컨테이너가 실패하면 본 컨테이너는 시작되지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 2, 'Init:0/1 읽기', '`kubectl get pods` 에서 STATUS 가 `Init:0/1` 입니다. 무슨 뜻일까요?', '분수는 init 컨테이너의 진행 상황이에요.', NULL, NULL, '[]', 'choice', '["본 컨테이너가 1개 중 0개 준비됐다", "init 컨테이너 1개 중 0개가 완료됐다. 아직 준비 작업 중이라 본 컨테이너는 시작되지 않았다 (READY `0/1`)", "Pod 가 0번 재시작했고 1번 남았다", "Pod 가 삭제되는 중이다"]', 1, 'init 가 끝나면 `PodInitializing` 을 거쳐 `Running` 이 됩니다. 오래 `Init:0/1` 이면 `kubectl logs 파드 -c init이름` 으로 init 컨테이너의 로그를 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 3, 'Init:Error 의 의미', 'STATUS 가 `Init:Error` 또는 `Init:CrashLoopBackOff` 입니다. 먼저 어디를 볼까요?', '본 컨테이너가 아니라 준비 컨테이너 쪽이에요.', NULL, NULL, '[]', 'choice', '["init 컨테이너의 로그(`kubectl logs 파드 -c init이름`)와 `describe` 의 이벤트", "본 컨테이너의 로그", "노드의 디스크 사용량", "Service 의 포트 설정"]', 0, '본 컨테이너는 아직 시작하지 않았으니 로그가 없습니다. 어느 init 컨테이너가 실패했는지 `describe` 에서 찾아 그 컨테이너의 로그를 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 4, 'restartPolicy 의 기본값', 'Pod 의 `restartPolicy` 를 적지 않으면 기본값은 무엇일까요?', '컨테이너가 끝나면 다시 시작하는 쪽이에요.', NULL, NULL, '[]', 'choice', '["`Never`", "`OnFailure`", "`Once`", "`Always` (정상 종료든 실패든 컨테이너가 끝나면 다시 시작한다)"]', 3, 'Deployment 의 Pod 는 항상 `Always` 입니다. 그래서 끝나는 작업(Job)은 `Never` 나 `OnFailure` 를 따로 정해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 5, 'restartPolicy: Never', '`restartPolicy: Never` 인 Pod 의 컨테이너가 실패(종료 코드 1)하면 어떻게 될까요?', '다시 시도하지 않아요.', NULL, NULL, '[]', 'choice', '["무한히 재시작한다", "Pod 가 자동으로 삭제된다", "다시 시작하지 않고 `Error` 상태로 남는다 (RESTARTS 는 0)", "다른 노드로 옮겨져 다시 시작한다"]', 2, '한 번만 실행하고 결과를 확인하려는 작업에 알맞습니다. 실패 이유는 `kubectl logs` 로 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 6, 'restartPolicy: OnFailure', '`restartPolicy: OnFailure` 는 무엇을 뜻할까요?', '이름 그대로 실패했을 때만이에요.', NULL, NULL, '[]', 'choice', '["성공했을 때만 다시 시작한다", "컨테이너가 0 이 아닌 코드로 종료(실패)했을 때만 다시 시작한다", "항상 다시 시작한다", "절대 다시 시작하지 않는다"]', 1, '정상 종료(0)하면 `Completed` 로 끝납니다. 실패하면 재시작하므로 RESTARTS 숫자가 늘어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 7, 'Never 와 Completed', '`restartPolicy: Never` 인 Pod 가 `echo done` 을 하고 정상 종료했습니다. STATUS 는 어떻게 보일까요?', '끝났지만 성공한 상태예요.', NULL, NULL, '[]', 'choice', '["`Completed` (READY 는 `0/1`). 오류가 아니라 정상 종료이다", "`Error`", "`CrashLoopBackOff`", "`Pending`"]', 0, '성공한 Pod 는 로그를 볼 수 있도록 남겨 둡니다. 더 이상 필요 없으면 직접 삭제하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 8, 'imagePullPolicy 기본값', '이미지를 `nginx` (태그 없음)로 쓸 때와 `nginx:1.27` 로 쓸 때, 기본 `imagePullPolicy` 는 각각 무엇일까요?', '`latest` 인지 버전 태그인지에 따라 달라요.', NULL, NULL, '[]', 'choice', '["둘 다 `Never`", "둘 다 `Always`", "태그가 없으면 `IfNotPresent`, 버전 태그면 `Always`", "태그가 없거나 `latest` 면 `Always`, 버전 태그면 `IfNotPresent`"]', 3, '`Always` 는 시작할 때마다 레지스트리를 확인하고, `IfNotPresent` 는 노드에 이미지가 있으면 다시 받지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 9, 'IfNotPresent 의 함정', '같은 태그 `app:1.0` 의 이미지 내용을 새로 빌드해 레지스트리에 덮어썼습니다. `imagePullPolicy: IfNotPresent` 인 Pod 를 다시 띄우면 어떻게 될까요?', '노드에 같은 이름의 이미지가 있으면 받지 않아요.', NULL, NULL, '[]', 'choice', '["항상 새 내용을 받아 온다", "Pod 가 시작되지 않는다", "노드에 `app:1.0` 이 이미 있으면 다시 받지 않아 예전 내용이 그대로 실행될 수 있다. 새 태그를 쓰는 것이 안전하다", "레지스트리가 자동으로 알려 준다"]', 2, '그래서 버전 태그를 바꿔 가며 배포하는 것이 권장됩니다. 같은 태그를 덮어쓰는 방식은 노드마다 다른 버전이 도는 사고로 이어질 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 10, '종료 유예 시간', 'Pod 를 삭제하면 컨테이너에 종료 신호(SIGTERM)를 보낸 뒤 기본으로 몇 초를 기다렸다가 강제 종료할까요?', '`terminationGracePeriodSeconds` 의 기본값이에요.', NULL, NULL, '[]', 'choice', '["0초(즉시)", "30초", "5초", "10분"]', 1, '이 시간 안에 앱이 스스로 정리하고 종료하면 좋습니다. 앱이 오래 걸리면 `terminationGracePeriodSeconds` 를 늘릴 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 11, '삭제가 30초 걸리는 이유', 'Pod 를 삭제했더니 `Terminating` 에서 30초 가까이 걸렸습니다. 흔한 이유는 무엇일까요?', '프로세스가 종료 신호에 반응하지 않는 경우예요.', NULL, NULL, '[]', 'choice', '["컨테이너의 첫 프로세스(PID 1)가 SIGTERM 에 반응하지 않아 유예 시간(30초)을 모두 기다린 뒤 강제 종료되었다", "노드가 꺼져 있어서", "이미지를 지우느라", "Service 가 연결되어 있어서"]', 0, '`--grace-period=1` 처럼 줄이면 빨리 지워지지만 앱이 정리할 시간이 없습니다. 근본 해결은 앱이 종료 신호를 처리하게 만드는 것이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 12, '라벨 in 셀렉터', '`kubectl get pods -l ''app in (a,b)''` 는 어떤 Pod 를 보여 줄까요?', '"목록 중 하나"를 뜻하는 in 이에요.', NULL, NULL, '[]', 'choice', '["`app` 라벨이 `a` 와 `b` 를 동시에 가진 Pod", "`app` 라벨이 없는 Pod", "이름이 `a` 나 `b` 인 Pod", "`app` 라벨의 값이 `a` 이거나 `b` 인 Pod"]', 3, '`app!=a` 는 값이 a 가 아닌 Pod(라벨 없는 것 포함), `-l tier` 는 `tier` 라벨이 있는 Pod, `-l ''!tier''` 는 없는 Pod 를 고릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 13, '쉼표는 AND', '`kubectl get pods -l app=a,tier=web` 에서 쉼표는 어떤 뜻일까요?', '두 조건을 모두 만족해야 해요.', NULL, NULL, '[]', 'choice', '["둘 중 하나만 만족해도 고른다 (OR)", "두 라벨을 같은 값으로 바꾼다", "두 조건을 모두 만족하는 Pod 만 고른다 (AND)", "쉼표 뒤의 조건은 무시한다"]', 2, 'OR 가 필요하면 `-l ''app in (a,b)''` 처럼 `in` 을 쓰세요. 조건을 겹쳐 쓸수록 결과는 좁아집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 14, 'custom-columns', '`kubectl get pods -o custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image` 는 무엇을 할까요?', '원하는 칸만 골라 표로 보여 줘요.', NULL, NULL, '[]', 'choice', '["Pod 를 만든다", "지정한 필드(이름, 첫 컨테이너의 이미지)만 열로 뽑아 표로 보여 준다", "이미지를 바꾼다", "Pod 의 로그를 보여 준다"]', 1, '`-o yaml` 은 너무 길 때, 필요한 필드만 한눈에 모아 보는 데 유용합니다. `-o jsonpath` 도 비슷하게 필드를 골라낼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 15, '라벨 지우기', 'Pod `web` 의 `tier` 라벨을 **삭제하는** 올바른 모양입니다. 빈칸을 채우세요.', '키 이름 뒤에 붙는 기호예요.', NULL, NULL, '[]', 'fill', '["-", "--", "=", "!"]', NULL, '`tier-` 처럼 키 뒤에 하이픈을 붙이면 그 라벨이 지워집니다. 값을 바꿀 때는 `--overwrite` 가 필요해요.', '[0]', 'kubectl label pod web tier{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 16, '실패해도 다시 시작하지 않기', '컨테이너가 실패해도 **다시 시작하지 않게** 하는 값을 채우세요.', '"절대 아니다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["Never", "Once", "No", "Stop"]', NULL, '`Never` 와 `OnFailure` 는 끝나는 작업에, `Always` 는 계속 떠 있어야 하는 서비스에 씁니다.', '[0]', 'restartPolicy: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 17, '이미지는 없을 때만 받기', '노드에 이미지가 **없을 때만** 받아 오는 값을 채우세요.', '"있지 않을 때만"을 영어로 이어 붙여요.', NULL, NULL, '[]', 'fill', '["IfNotPresent", "OnlyOnce", "Cached", "Local"]', NULL, '버전 태그를 쓰는 이미지의 기본값입니다. 같은 태그를 덮어써서 배포하면 반영되지 않을 수 있어요.', '[0]', 'imagePullPolicy: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 18, '값이 목록 중 하나', '`app` 라벨이 `a` 또는 `b` 인 Pod 를 고르는 키워드입니다. 빈칸을 채우세요.', '"~ 안에 있는"이라는 뜻의 아주 짧은 영어 단어예요.', NULL, NULL, '[]', 'fill', '["in", "of", "is", "has"]', NULL, '`notin` 으로 "목록에 없는 것"도 고를 수 있습니다. 괄호 안 값은 쉼표로 구분해요.', '[0]', 'kubectl get pods -l ''app {0} (a,b)''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 19, '두 조건 모두', '`app=a` 이면서 `tier=web` 인 Pod 를 고릅니다. 두 조건을 잇는 기호를 채우세요.', '공백 없이 쉼표 하나예요.', NULL, NULL, '[]', 'fill', '[",", "&", "+", ";"]', NULL, '쉼표는 AND 입니다. 쉘에서 `&` 나 `;` 를 쓰면 명령이 둘로 나뉘니 주의하세요.', '[0]', 'kubectl get pods -l app=a{0}tier=web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 20, '라벨이 없는 것', '`tier` 라벨이 **없는** Pod 를 고르는 기호를 채우세요.', '"아니다"를 뜻하는 느낌표예요.', NULL, NULL, '[]', 'fill', '["!", "-", "~", "^"]', NULL, '`-l tier` 는 `tier` 라벨이 있는 것, `-l ''!tier''` 는 없는 것입니다. 쉘이 느낌표를 해석하지 않도록 따옴표로 감싸세요.', '[0]', 'kubectl get pods -l ''{0}tier''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 21, '필요한 열만 표로', '이름과 이미지만 열로 보려고 합니다. 출력 형식 이름을 채우세요.', '"사용자 지정 열"이라는 뜻의 이름이에요.', NULL, NULL, '[]', 'fill', '["custom-columns", "columns", "table", "fields"]', NULL, '`열이름:필드경로` 쌍을 쉼표로 이어 씁니다. 자주 쓰는 조합은 별칭이나 스크립트로 남겨 두세요.', '[0]', 'kubectl get pods -o {0}=NAME:.metadata.name,IMAGE:.spec.containers[0].image', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 22, '개수 바꾸기', 'Deployment `web` 의 Pod 개수를 **3개로 바꾸는** 옵션 이름을 채우세요.', '"복제본"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--replicas", "--count", "--size", "--pods"]', NULL, '`scale` 은 YAML 파일은 그대로 두고 개수만 바꿉니다. 영구적으로 바꾸려면 YAML 의 `replicas` 도 고쳐야 해요.', '[0]', 'kubectl scale deployment web {0}=3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 23, '종료 유예 시간 줄이기', 'Pod `web` 을 **유예 시간 1초**로 삭제하려고 합니다. 옵션 이름을 채우세요.', '"유예 기간"이라는 뜻의 영어 이름이에요.', NULL, NULL, '[]', 'fill', '["--grace-period", "--wait", "--timeout", "--force-time"]', NULL, '유예 시간이 짧으면 앱이 정리할 시간이 없습니다. 급할 때만 쓰고 평소에는 기본값을 두세요.', '[0]', 'kubectl delete pod web {0}=1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 24, '준비 컨테이너 정의', 'Pod 스펙에서 **본 컨테이너보다 먼저 실행할** 컨테이너를 정의하는 키 이름을 채우세요.', '"초기화"를 뜻하는 init 이 들어가요.', NULL, NULL, '[]', 'fill', '["initContainers", "preContainers", "setupContainers", "bootContainers"]', NULL, '`initContainers` 는 `containers` 와 같은 모양으로 적습니다. 여러 개면 위에서부터 차례대로 실행해요.', '[0]', '{0}:', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 25, '라벨을 함께 보기', 'Pod 목록에 **라벨**을 함께 보는 옵션을 채우세요.', '"라벨"이라는 영어 단어가 들어가요.', NULL, NULL, '[]', 'fill', '["labels", "tags", "names", "keys"]', NULL, '라벨을 보고 셀렉터(`-l`)를 만들어 쓰면 편합니다. Service 가 Pod 를 못 찾을 때도 첫 확인이에요.', '[0]', 'kubectl get pods --show-{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 26, 'Init 에서 멈춘 Pod 조사', 'Pod 가 `Init:0/1` 에서 오래 멈춰 있을 때의 조사 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → init 정의 → init 로그 → 고친 뒤 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 STATUS 가 `Init:0/1` 인 것을 확인한다", "`kubectl describe pod` 에서 init 컨테이너의 상태와 이벤트를 본다", "`kubectl logs 파드 -c init이름` 으로 init 컨테이너의 로그를 본다", "원인을 고치고 `Running` 이 되는지 확인한다"]', NULL, '본 컨테이너 로그는 아직 없으니 init 컨테이너의 로그를 보는 것이 핵심입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 27, '재시작하지 않는 Pod 이해하기', 'Pod 가 `Error` 인데 RESTARTS 가 0 이라 재시작되지 않을 때의 조사 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → 정책 확인 → 실패 이유 → 고치기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 에서 STATUS 가 `Error` 이고 RESTARTS 가 0 인 것을 본다", "`kubectl get pod 이름 -o yaml` 에서 `restartPolicy` 를 확인한다", "`kubectl logs 이름` 으로 실패한 이유를 본다", "계속 재시작이 필요하면 Deployment 로 바꾸거나 `OnFailure` 로 고친다"]', NULL, '`Never` 는 의도한 설정일 수 있으니 "재시작 안 함"이 문제인지 먼저 판단하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 28, '라벨로 Pod 좁혀 고르기', '라벨로 원하는 Pod 만 골라내는 순서입니다. 순서에 맞게 놓아 보세요.', '라벨 보기 → 한 조건 → 조건 더하기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods --show-labels` 로 붙은 라벨을 본다", "`-l app=a` 로 한 조건으로 골라 본다", "`-l app=a,tier=web` 로 조건을 더해 좁힌다", "고른 Pod 가 맞는지 확인한 뒤 그 라벨로 작업한다"]', NULL, '작업(삭제 등)을 하기 전에 같은 셀렉터로 `get` 해서 대상이 맞는지 보는 것이 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 151, 29, 'Pod 삭제가 느릴 때', 'Pod 삭제가 `Terminating` 에서 30초 가까이 걸릴 때의 조사 순서입니다. 순서에 맞게 놓아 보세요.', '증상 확인 → 유예 시간 → 앱 종료 처리 → 필요 시 줄이기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl delete pod` 후 `Terminating` 이 길게 이어지는 것을 확인한다", "`kubectl get pod 이름 -o yaml` 로 `terminationGracePeriodSeconds`(기본 30)를 확인한다", "앱의 첫 프로세스가 종료 신호(SIGTERM)를 처리하는지 확인한다", "급하면 `--grace-period` 로 줄여 삭제하되 앱이 종료 신호를 처리하도록 고친다"]', NULL, '유예 시간만 줄이는 것은 임시방편입니다. 근본적으로는 앱이 종료 신호를 받으면 정리하고 끝나게 만들어야 해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 151 AND order_index = 29);
