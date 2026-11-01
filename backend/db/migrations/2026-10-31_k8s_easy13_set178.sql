-- k8s 세트 178. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set178.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 178, 'Job 심화와 스케줄링 제약: completions, TTL·deadline, taint·toleration, nodeAffinity, PDB', '일회성 작업과 Pod 배치 제약을 한 개념씩 반복합니다. Job 의 기본값(completions 1·parallelism 1·backoffLimit 6)과 completions·parallelism 의 동작, get job 의 STATUS·COMPLETIONS 열, ttlSecondsAfterFinished 의 자동 삭제, activeDeadlineSeconds 와 DeadlineExceeded, backoffLimit 초과(BackoffLimitExceeded), suspend 로 대기시켰다 시작하기, Job 삭제와 logs job/, 노드 taint 와 Pending(untolerated taint), toleration 의 Equal 과 Exists, taint 의 추가·제거 표기, nodeAffinity 의 required 와 preferred 와 연산자(In·NotIn·Exists)와 IgnoredDuringExecution, PodDisruptionBudget 의 ALLOWED DISRUPTIONS 를 짧은 객관식·빈칸·순서 문제로 익히고, Job 이 실패한 이유 읽기, Pending 의 스케줄링 원인 풀기, taint 로 노드 막고 풀기, Job 을 대기시켰다 시작하기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 178);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '📆' WHERE id = 178;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 1, 'Job 의 기본값', '`completions`, `parallelism`, `backoffLimit` 을 쓰지 않고 Job 을 만들면 기본값은 무엇일까요? 끝난 뒤 Job 은 어떻게 될까요?', '한 번만 성공하면 되고, 한 번에 하나씩 실행해요.', NULL, NULL, '[]', 'choice', '["모두 0 이다", "`completions` 는 3, `parallelism` 은 3 이다", "`completions` 는 1, `parallelism` 은 1, `backoffLimit` 은 6 이다. 끝난 Job 은 `Complete` 상태로 남아 있다 (자동으로 지워지지 않는다)", "끝나면 Job 이 즉시 자동 삭제된다"]', 2, '자동으로 지우려면 `ttlSecondsAfterFinished` 를 써야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 2, 'completions 와 parallelism', '`completions: 4`, `parallelism: 2` 인 Job 은 어떻게 실행될까요?', '총 성공 횟수와 동시 실행 개수예요.', NULL, NULL, '[]', 'choice', '["Pod 4개를 항상 한꺼번에 실행한다", "Pod 를 동시에 2개씩 실행하며 성공한 Pod 가 모두 4개가 될 때까지 계속한다 (초기에 `active` 가 2 이고 끝나면 Completed Pod 4개가 남는다)", "Pod 2개만 실행하고 끝난다", "`parallelism` 은 재시도 횟수이다"]', 1, '`completions: 3`, `parallelism: 1` 이면 하나씩 차례로 3번 실행합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 3, 'get job 의 열', '`kubectl get job` 의 `STATUS` 와 `COMPLETIONS` 열은 실행 중과 끝난 뒤에 어떻게 보일까요?', 'COMPLETIONS 는 성공한 수/목표 수예요.', NULL, NULL, '[]', 'choice', '["실행 중에는 `STATUS` 가 `Running`, `COMPLETIONS` 가 `0/3` 처럼 보이고, 모두 성공하면 `Complete` 와 `3/3` 이 된다. 중지한 Job 은 `Suspended`, 실패하면 `Failed` 이다", "`STATUS` 에는 Pod 이름이 나온다", "`COMPLETIONS` 는 남은 시간이다", "끝나도 `COMPLETIONS` 는 `0/3` 으로 남는다"]', 0, '`DURATION` 은 실행에 걸린 시간입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 4, 'ttlSecondsAfterFinished', '`ttlSecondsAfterFinished: 5` 인 Job 이 끝나면 어떻게 될까요? 이 값이 없는 Job 은요?', '끝난 뒤 정리까지의 시간이에요.', NULL, NULL, '[]', 'choice', '["Job 은 남고 Pod 만 삭제된다", "실행 시간이 5초로 제한된다", "5초 뒤 Job 이 다시 실행된다", "끝난 뒤 5초쯤 지나면 Job 과 그 Pod 가 모두 자동으로 삭제된다. 이 값이 없으면 끝난 Job(`Complete`)이 계속 남는다"]', 3, '끝난 Job 이 쌓이지 않게 정리하려면 이 값을 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 5, 'activeDeadlineSeconds', '`activeDeadlineSeconds: 5` 인 Job 이 `sleep 600` 을 실행합니다. 5초가 지나면 어떻게 될까요?', 'Job 전체의 실행 시간 상한이에요.', NULL, NULL, '[]', 'choice', '["Pod 가 다시 시작되어 계속 실행된다", "Job 이 `Complete` 로 끝난다", "Job 이 `Failed` 가 되고 이유는 `DeadlineExceeded`(`Job was active longer than specified deadline`)이며, 실행 중이던 Pod 도 삭제된다", "`backoffLimit` 만큼 재시도한 뒤에야 실패한다"]', 2, '`backoffLimit` 이 남아 있어도 시간 제한이 먼저 적용됩니다. 멈추는 작업을 막을 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 6, 'backoffLimit 초과', '`backoffLimit: 1` 이고 `restartPolicy: Never` 인 Job 이 `exit 3` 으로 계속 실패하면 어떻게 될까요?', '재시도 횟수를 넘으면 포기해요.', NULL, NULL, '[]', 'choice', '["무한히 재시도한다", "실패한 Pod 가 2개(처음 시도와 재시도 1번) 생기고 Job 은 `Failed` 가 되며 이유는 `BackoffLimitExceeded` 이다", "Pod 가 1개만 만들어진다", "Job 이 `Complete` 가 된다"]', 1, '실패한 Pod 는 `Error` 상태로 남습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 7, 'Job 의 suspend', '`suspend: true` 로 만든 Job 은 어떻게 될까요? `suspend` 를 `false` 로 바꾸면요?', '만들었지만 아직 시작하지 않아요.', NULL, NULL, '[]', 'choice', '["Pod 가 하나도 만들어지지 않고 `STATUS` 가 `Suspended` 이다. `false` 로 바꾸면(`kubectl patch job ...`) Pod 가 만들어져 실행되고 끝나면 `Complete` 가 된다", "Pod 가 만들어지지만 멈춰 있다", "Job 이 삭제된다", "`suspend` 는 Job 에서 쓸 수 없다"]', 0, '준비가 끝날 때까지 작업을 대기시켜 두었다가 시작할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 8, 'Job 삭제와 logs', 'Job 을 `kubectl delete job 이름` 으로 지우면 그 Pod 는 어떻게 될까요? Pod 가 여러 개인 Job 에 `kubectl logs job/이름` 을 하면요?', 'Job 이 Pod 를 관리해요.', NULL, NULL, '[]', 'choice', '["Pod 는 남는다", "여러 Pod 의 로그를 모두 합쳐 보여 준다", "`logs job/` 는 쓸 수 없다", "Job 이 만든 Pod 도 함께 삭제된다. `kubectl logs job/이름` 은 Pod 중 하나를 골라 `Found 3 pods, using pod/...` 같은 안내와 함께 그 로그를 보여 준다"]', 3, '특정 Pod 의 로그를 보려면 `kubectl get pods -l job-name=이름` 으로 이름을 찾아 `kubectl logs pod/이름` 을 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 9, 'taint 와 Pending', '노드에 `etude-test=1:NoSchedule` taint 를 붙인 뒤 toleration 이 없는 새 Pod 를 만들면 어떻게 될까요? taint 를 지우면요?', 'taint 는 노드가 Pod 를 밀어내요.', NULL, NULL, '[]', 'choice', '["그대로 `Running` 이 된다", "Pod 가 삭제된다", "Pod 가 `Pending` 이 되고 이벤트에 `1 node(s) had untolerated taint(s)` 가 나온다. taint 를 지우면 곧 스케줄되어 `Running` 이 된다", "taint 를 지워도 계속 `Pending` 이다"]', 2, 'Pending 원인은 `kubectl describe pod` 아래쪽의 Events 에서 읽습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 10, 'toleration 의 Equal 과 Exists', 'taint 가 `etude-test=1:NoSchedule` 일 때, `operator: Equal`, `value: "1"`, `operator: Exists`, `operator: Equal`, `value: "2"` 인 toleration 을 가진 Pod 는 각각 어떻게 될까요?', 'Equal 은 값까지 일치해야 해요.', NULL, NULL, '[]', 'choice', '["값이 달라도 `Equal` 은 항상 통과한다", "`Equal` 과 `value: \\"1\\"`(값 일치)은 `Running`, `Exists`(key 만 일치)도 `Running` 이고, `value: \\"2\\"`(값 불일치)는 여전히 `Pending` 이다", "`Exists` 는 value 를 반드시 써야 한다", "toleration 은 스케줄에 영향을 주지 않는다"]', 1, 'toleration 은 ''허용''일 뿐 그 노드로 가라는 뜻은 아닙니다. 노드가 하나뿐이면 허용된 Pod 만 올 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 11, 'taint 추가와 제거', '노드에 taint 를 붙이는 명령과 지우는 명령은 각각 어떻게 쓸까요?', '지울 때는 키 뒤에 - 를 붙여요.', NULL, NULL, '[]', 'choice', '["붙일 때는 `kubectl taint nodes 노드 key=value:NoSchedule`, 지울 때는 `kubectl taint nodes 노드 key-` 이다 (`kubectl get node 노드 -o jsonpath` 로 `spec.taints` 를 확인한다)", "지울 때는 `kubectl delete taint` 이다", "taint 는 한 번 붙이면 지울 수 없다", "붙일 때 `effect` 는 생략해야 한다"]', 0, '라벨을 지울 때(`label 키-`)와 같은 방식입니다. 확인한 뒤에는 꼭 제거해 두세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 12, 'nodeAffinity 의 required 와 preferred', '노드에 `disk=ssd` 라벨이 없을 때 `requiredDuringSchedulingIgnoredDuringExecution` 과 `preferredDuringSchedulingIgnoredDuringExecution`(`disk In ssd`)을 쓴 Pod 는 각각 어떻게 될까요?', 'required 는 필수, preferred 는 선호예요.', NULL, NULL, '[]', 'choice', '["둘 다 `Pending` 이 된다", "둘 다 `Running` 이 된다", "`preferred` 가 `Pending` 이 되고 `required` 가 `Running` 이 된다", "`required` 는 맞는 노드가 없어 `Pending`(이벤트: `didn''t match Pod''s node affinity/selector`)이고, `preferred` 는 선호 조건이 맞지 않아도 다른 노드에 스케줄되어 `Running` 이 된다"]', 3, '조건이 맞는 노드가 생기면(라벨을 붙이면) `Pending` 이던 Pod 가 `Running` 이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 13, 'affinity 연산자와 IgnoredDuringExecution', '라벨 `disk` 가 없는 노드에서 `disk NotIn [hdd]` 와 `disk Exists` 를 required 로 쓴 Pod 는 각각 어떻게 될까요? 이미 실행 중인 Pod 가 있고 노드의 `disk` 라벨을 지우면요?', '라벨이 없으면 NotIn 은 통과해요.', NULL, NULL, '[]', 'choice', '["`NotIn` 은 라벨이 없으면 `Pending` 이다", "라벨을 지우면 실행 중인 Pod 도 즉시 삭제된다", "`NotIn` 은 라벨이 없어도 조건을 만족해 `Running`, `Exists` 는 라벨이 없어 `Pending` 이며 `disk=ssd` 를 붙이면 `Running` 이 된다. 이미 실행 중인 Pod 는 라벨을 지워도 쫓겨나지 않는다 (`IgnoredDuringExecution`)", "`Exists` 는 라벨 없이도 `Running` 이 된다"]', 2, 'affinity 는 스케줄하는 순간에만 평가됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 14, 'PodDisruptionBudget', '`web` Deployment 의 Pod 3개에 `minAvailable: 2` 인 PDB 를 만들었습니다. `ALLOWED DISRUPTIONS` 는 얼마일까요? 복제 수를 2개로 줄이면요? `minAvailable` 과 `maxUnavailable` 을 함께 지정하면?', '남겨야 하는 개수에서 허용량이 나와요.', NULL, NULL, '[]', 'choice', '["3개일 때 2, 2개일 때 1 이다", "3개일 때 1, 2개로 줄이면 0 이 된다 (`maxUnavailable: 1` 이나 `minAvailable: 50%` 도 3개에서 1). 둘을 함께 지정하면 `min-available and max-unavailable cannot be both specified` 오류가 난다", "PDB 는 `ALLOWED DISRUPTIONS` 를 보여 주지 않는다", "둘을 함께 지정해도 된다"]', 1, 'selector 에 맞는 Pod 가 하나도 없으면 `ALLOWED DISRUPTIONS` 는 0 입니다. PDB 의 selector 는 Pod 라벨과 맞아야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 15, '동시 실행 개수', 'Job 이 **동시에 실행할 Pod 수**를 정하는 필드 이름을 채우세요.', '"병렬"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["parallelism", "completions", "replicas", "concurrency"]', NULL, '`completions` 는 성공해야 하는 총 횟수입니다.', '[0]', '{0}: 2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 16, '총 성공 횟수', 'Job 이 **성공해야 하는 총 횟수**를 정하는 필드 이름을 채우세요.', '"완료"라는 뜻을 가진 영어 단어의 복수형이에요.', NULL, NULL, '[]', 'fill', '["completions", "parallelism", "backoffLimit", "successes"]', NULL, '`kubectl get job` 의 `COMPLETIONS` 열에 `n/4` 로 보입니다.', '[0]', '{0}: 4', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 17, '끝난 뒤 자동 삭제', '끝난 Job 을 **일정 시간 뒤 자동으로 지우는** 필드 이름을 채우세요.', '"끝난 뒤 몇 초"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["ttlSecondsAfterFinished", "deleteAfterSeconds", "cleanupSeconds", "expireSeconds"]', NULL, 'Job 과 그 Pod 가 함께 삭제됩니다.', '[0]', '{0}: 5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 18, '실행 시간 상한', 'Job 이 **실행될 수 있는 시간의 상한**을 정하는 필드 이름을 채우세요.', '"활성"과 "기한"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["activeDeadlineSeconds", "timeoutSeconds", "maxRuntime", "deadline"]', NULL, '넘으면 `DeadlineExceeded` 로 실패합니다.', '[0]', '{0}: 5', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 19, 'backoffLimit 기본값', 'Job 의 `backoffLimit` **기본값**을 채우세요.', '한 자리 숫자예요.', NULL, NULL, '[]', 'fill', '["6", "3", "0", "10"]', NULL, '`backoffLimit: 1` 이면 실패한 Pod 가 2개 생기고 포기합니다.', '[0]', 'backoffLimit: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 20, 'Job 을 대기시키기', 'Job 을 **만들어 두고 시작하지 않는** 필드의 값을 채우세요.', '"참"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["true", "wait", "hold", "pause"]', NULL, '`false` 로 바꾸면 시작됩니다.', '[0]', 'suspend: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 21, 'taint 지우기', '노드의 `etude-test` taint 를 **지우는** 표기를 채우세요.', '키 뒤에 붙이는 한 글자예요.', NULL, NULL, '[]', 'fill', '["-", "=", "--rm", "=none"]', NULL, '라벨을 지울 때와 같은 방식입니다.', '[0]', 'kubectl taint nodes node1 etude-test{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 22, 'key 만으로 허용', 'toleration 이 값은 보지 않고 **key 만 일치하면 허용**하게 하는 operator 를 채우세요.', '"존재한다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["Exists", "Equal", "In", "Contains"]', NULL, '`Equal` 은 key 와 value 가 모두 일치해야 합니다.', '[0]', 'operator: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 23, '새 Pod 스케줄 금지', 'taint 가 **새 Pod 의 스케줄을 막도록** 하는 effect 를 채우세요.', '"스케줄 없음"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["NoSchedule", "Deny", "Block", "NoPod"]', NULL, 'toleration 이 없는 Pod 는 `Pending` 이 됩니다.', '[0]', 'kubectl taint nodes node1 k=v:{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 24, '필수 조건 이름', 'nodeAffinity 에서 **조건이 맞아야만 스케줄**하는 규칙의 앞부분 이름을 채우세요.', '"필수의"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["required", "preferred", "must", "hard"]', NULL, '`preferred` 는 선호일 뿐이라 맞지 않아도 스케줄됩니다.', '[0]', '{0}DuringSchedulingIgnoredDuringExecution', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 25, 'PDB 최소 개수', 'PDB 를 만들 때 **항상 남겨 둬야 하는 최소 Pod 수**를 정하는 옵션을 채우세요.', '"최소 가용"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["min-available", "max-unavailable", "replicas", "min"]', NULL, '`max-unavailable` 과는 함께 쓸 수 없습니다.', '[0]', 'kubectl create pdb web --selector=app=web --{0}=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 26, 'Job 이 실패한 이유 읽기', 'Job 이 실패했을 때 이유를 찾아 읽는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 → 실패 이유 → 실패한 Pod → 로그 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get job` 의 `STATUS` 가 `Failed` 인 것을 확인한다", "`kubectl get job 이름 -o jsonpath` 로 `Failed` 조건의 `reason`(`BackoffLimitExceeded`, `DeadlineExceeded` 등)을 읽는다", "`kubectl get pods -l job-name=이름` 으로 실패한 Pod 가 몇 개인지 본다", "`kubectl logs pod/이름` 으로 실패 원인을 확인한다"]', NULL, '`backoffLimit` 과 `activeDeadlineSeconds` 중 어느 한도에 걸렸는지가 이유로 나옵니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 27, 'Pending 의 스케줄링 원인 풀기', 'Pod 가 `Pending` 일 때 taint 와 affinity 문제를 찾아 푸는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 이벤트 → 노드 확인 → 고치기 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 `Pending` 상태를 확인한다", "`kubectl describe pod` 의 Events 에서 `untolerated taint` 나 `didn''t match Pod''s node affinity` 메시지를 읽는다", "`kubectl get node 노드 -o jsonpath` 로 `spec.taints` 와 라벨을 확인한다", "toleration 을 더하거나 라벨·affinity 를 고친 뒤 Pod 가 `Running` 이 되는지 확인한다"]', NULL, '원인이 자원 부족이면 같은 Events 에 `Insufficient cpu` 처럼 나옵니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 28, 'taint 로 노드를 막고 풀기', '노드에 taint 를 붙여 새 Pod 의 스케줄을 막았다가 푸는 순서입니다. 순서에 맞게 놓아 보세요.', '붙이기 → 막힘 확인 → 지우기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl taint nodes 노드 etude-test=1:NoSchedule` 로 taint 를 붙인다", "toleration 이 없는 새 Pod 가 `Pending` 이 되는 것을 확인한다", "`kubectl taint nodes 노드 etude-test-` 로 taint 를 지운다", "Pod 가 `Running` 이 되고 `spec.taints` 가 비었는지 확인한다"]', NULL, '시험이 끝나면 taint 를 꼭 지워서 다른 Pod 에 영향이 없게 하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 178, 29, 'Job 을 대기시켰다 시작하기', '`suspend` 로 대기시킨 Job 을 시작하고 완료까지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '대기 상태 확인 → 시작 → 기다림 → 완료 확인 순서예요.', NULL, NULL, '[]', 'order', '["`suspend: true` 인 Job 을 만들고 `STATUS` 가 `Suspended` 이고 Pod 가 없는 것을 확인한다", "`kubectl patch job 이름` 으로 `suspend` 를 `false` 로 바꾼다", "`kubectl wait --for=condition=complete job/이름 --timeout=40s` 로 끝나기를 기다린다", "`kubectl get job` 에서 `Complete` 이고 Pod 가 `Completed` 인지 확인한다"]', NULL, '끝난 Job 은 `kubectl delete job 이름` 으로 지우면 Pod 도 함께 지워집니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 178 AND order_index = 29);
