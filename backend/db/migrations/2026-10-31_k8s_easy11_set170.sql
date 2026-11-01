-- k8s 세트 170. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set170.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 170, '자원 요청·한도 읽기: QoS 등급, CPU 스로틀링과 OOMKilled, 노드 예약 현황', 'Pod 의 자원 설정이 실제로 어떻게 동작하는지 한 개념씩 반복합니다. BestEffort·Burstable·Guaranteed 등급이 정해지는 규칙과 확인 방법, limits 만 쓰면 requests 가 같은 값으로 채워지는 것, cpu 만 쓰면 Guaranteed 가 아닌 것, limits 가 cpu.max·memory.max 로 적용되는 것, CPU 한도 초과는 스로틀링이고 메모리 한도 초과는 OOMKilled(종료 코드 137)이며 앱 로그에 남지 않는 것, requests 가 limits 보다 크면 거부되는 것과 requests 가 너무 크면 Pending 이 되는 것, 0.5 와 500m·Mi 와 M 의 단위, kubectl set resources 가 새 롤아웃을 만드는 것, top 의 실제 사용량과 describe node 의 예약량 차이를 짧은 객관식·빈칸·순서 문제로 익히고, OOMKilled 원인 찾기, 자원 부족 Pending 풀기, 한도 적용 확인, Deployment 자원 조정의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 170);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '📏' WHERE id = 170;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 1, 'QoS 세 등급', 'Pod 의 QoS 등급 `BestEffort`, `Burstable`, `Guaranteed` 는 어떻게 정해질까요?', 'requests 와 limits 를 얼마나 썼는지로 정해져요.', NULL, NULL, '[]', 'choice', '["Pod 의 이름으로 정해진다", "네임스페이스로 정해진다", "`requests` 와 `limits` 를 하나도 쓰지 않으면 `BestEffort`, 모든 컨테이너가 `cpu` 와 `memory` 의 requests 와 limits 를 같은 값으로 쓰면 `Guaranteed`, 그 사이(일부만 쓰거나 값이 다름)는 `Burstable` 이다", "이미지 크기로 정해진다"]', 2, '쿠버네티스가 자동으로 정해 `status.qosClass` 에 기록합니다. 노드 자원이 부족할 때 어떤 Pod 를 우선 지킬지의 기준이 되는 등급이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 2, 'limits 만 쓰면', '`resources.limits` 에 `cpu: 300m`, `memory: 96Mi` 만 쓰고 `requests` 는 쓰지 않았습니다. `requests` 와 QoS 등급은 어떻게 될까요?', 'requests 를 안 쓰면 limits 값을 따라가요.', NULL, NULL, '[]', 'choice', '["`requests` 는 0 이 되고 `BestEffort` 가 된다", "`requests` 가 `limits` 와 같은 값(300m, 96Mi)으로 채워지고 QoS 등급은 `Guaranteed` 가 된다", "오류가 나서 Pod 가 만들어지지 않는다", "`requests` 는 비어 있고 `Burstable` 이 된다"]', 1, '`kubectl get pod 이름 -o jsonpath=''{.spec.containers[0].resources}''` 로 채워진 requests 를 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 3, 'cpu 만 쓰면 Guaranteed 가 아니다', '컨테이너에 `cpu` 의 requests 와 limits 를 같은 값(100m)으로만 쓰고 `memory` 는 쓰지 않았습니다. QoS 등급은?', 'cpu 와 memory 둘 다 필요해요.', NULL, NULL, '[]', 'choice', '["`Burstable` (`Guaranteed` 가 되려면 `cpu` 와 `memory` 모두에 requests 와 limits 가 같은 값으로 있어야 한다)", "`Guaranteed`", "`BestEffort`", "등급이 정해지지 않는다"]', 0, 'memory 만 limits 로 쓴 경우도 `Burstable` 입니다. 두 자원 모두 같은 값으로 지정했는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 4, 'QoS 등급 확인하기', 'Pod 의 QoS 등급을 확인하는 방법으로 알맞은 것은?', 'status 안에 기록돼 있어요.', NULL, NULL, '[]', 'choice', '["`kubectl get qos` 로 본다", "`kubectl top pod` 의 열로 본다", "Pod 이름 끝의 문자로 알 수 있다", "`kubectl get pod 이름 -o jsonpath=''{.status.qosClass}''`, `kubectl describe pod 이름` 의 `QoS Class` 줄, 또는 `-o custom-columns=NAME:.metadata.name,QOS:.status.qosClass` 로 본다"]', 3, '`custom-columns` 를 쓰면 Pod 여러 개의 등급을 한 번에 표로 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 5, 'limits 는 컨테이너 한도로 적용된다', '컨테이너에 `cpu: 500m`, `memory: 50Mi` 의 limits 를 주었습니다. 컨테이너 안에서 보면 어떻게 적용되어 있을까요? (cgroup v2)', '100ms 주기마다 쓸 수 있는 CPU 시간과 메모리 바이트 수로 바뀌어요.', NULL, NULL, '[]', 'choice', '["파일이 없고 Pod 이름에만 기록된다", "cpu 는 코어 번호로, memory 는 페이지 수로 기록된다", "`/sys/fs/cgroup/cpu.max` 가 `50000 100000` (100ms 마다 50ms 만 CPU 사용), `/sys/fs/cgroup/memory.max` 가 `52428800` (50Mi 의 바이트 수)이다. limits 가 없으면 둘 다 `max` 이다", "limits 는 스케줄러만 보고 컨테이너에는 적용되지 않는다"]', 2, 'limits 는 실제로 커널이 지키는 한도이고, requests 는 스케줄러가 자리를 계산하는 값입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 6, 'CPU 한도를 넘으면', '`cpu: 100m` limits 를 가진 컨테이너가 계속 CPU 를 최대로 쓰려고 합니다. 어떻게 될까요?', 'CPU 는 나눠 쓰는 자원이에요.', NULL, NULL, '[]', 'choice', '["`OOMKilled` 로 종료된다", "종료되지 않고 계속 `Running` 이며, 한도만큼만 쓰도록 스로틀링(제한)된다 (`kubectl top` 에서 약 100m 근처로 보이고 `cpu.stat` 의 `nr_throttled` 가 늘어난다)", "`Evicted` 되어 삭제된다", "Pod 가 `Pending` 상태로 돌아간다"]', 1, 'CPU 는 압축 가능한 자원이라 제한만 하고, 메모리는 압축할 수 없어서 넘으면 종료합니다. 앱이 느려졌다면 CPU limits 를 의심해 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 7, '메모리 한도를 넘으면', '`memory: 50Mi` limits 를 가진 컨테이너가 메모리를 120MB 쓰려고 합니다. 어떻게 될까요?', '메모리는 나눠 줄 수 없어요.', NULL, NULL, '[]', 'choice', '["커널이 컨테이너를 강제로 종료하고, 상태에 `OOMKilled` 와 종료 코드 `137` 이 기록된다", "CPU 처럼 느려질 뿐 계속 실행된다", "한도가 자동으로 늘어난다", "Pod 가 `Pending` 상태가 된다"]', 0, '한도 안에서 쓰는 컨테이너(예: 100Mi 한도에서 20MB 사용)는 정상으로 계속 실행됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 8, 'OOMKilled 읽기', '메모리 한도를 넘은 Pod 를 `restartPolicy: Never` 로 실행했을 때와 기본 `Always` 로 실행했을 때, 각각 `kubectl get pod` 에서 어떻게 보일까요?', '재시작하느냐에 따라 달라요.', NULL, NULL, '[]', 'choice', '["둘 다 `Completed` 로 보인다", "`Never` 는 `Running`, `Always` 는 `Failed` 로 보인다", "둘 다 아무 흔적이 남지 않는다", "`Never` 는 재시작하지 않아 `STATUS` 가 `OOMKilled`, `phase` 가 `Failed` 이다. `Always` 는 재시작되어 `RESTARTS` 가 늘고 직전 종료 이유가 `lastState` 에 `OOMKilled`(종료 코드 137)로 남는다"]', 3, '재시작이 반복되면 `CrashLoopBackOff` 로 표시될 수 있습니다. 이때도 `describe` 의 `Last State` 에서 `OOMKilled` 를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 9, 'OOM 은 앱 로그에 안 남는다', '메모리 한도를 넘어 종료된 컨테이너에 `kubectl logs` 를 했더니 아무것도 없었습니다. 원인은 어디에서 찾을까요?', '앱이 아니라 커널이 종료시켰어요.', NULL, NULL, '[]', 'choice', '["`kubectl logs` 를 한 번 더 실행하면 나온다", "Pod 를 삭제하면 로그가 생긴다", "앱이 스스로 종료한 것이 아니라 커널이 강제로 종료해서 앱 로그에 오류가 남지 않는다. `kubectl describe pod` 의 `Reason: OOMKilled` 와 `Exit Code: 137` 에서 확인한다", "`kubectl top` 으로 확인한다"]', 2, '종료 코드 137 은 128 + 9 (SIGKILL) 입니다. 메모리 limits 를 올리거나 앱의 메모리 사용을 줄여서 해결해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 10, 'requests 가 limits 보다 크면', '`requests.memory: 200Mi`, `limits.memory: 100Mi` 로 Pod 를 만들면 어떻게 될까요?', '요청이 한도보다 클 수는 없어요.', NULL, NULL, '[]', 'choice', '["Pod 가 만들어지지만 `Pending` 이 된다", "API 서버가 `must be less than or equal to memory limit of 100Mi` 오류로 거부해서 Pod 가 만들어지지 않는다", "requests 가 limits 로 자동으로 낮아진다", "경고만 나오고 Pod 가 만들어진다"]', 1, 'requests 는 limits 보다 작거나 같아야 합니다. 같으면 보장된 만큼만 쓰는 설정이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 11, 'requests 가 너무 크면', '노드에 비해 매우 큰 `requests.cpu` 를 가진 Pod 를 만들었습니다. 어떻게 될까요? 스케줄러는 무엇을 기준으로 자리를 계산할까요?', '스케줄러는 예약해 둔 양을 봐요.', NULL, NULL, '[]', 'choice', '["어느 노드에도 들어갈 수 없어 `Pending` 이 되고 이벤트에 `0/1 nodes are available: 1 Insufficient cpu` 가 나온다. 스케줄러는 실제 사용량이 아니라 Pod 들의 `requests` 합계로 자리를 계산한다", "`OOMKilled` 로 종료된다", "`Running` 이 되고 CPU 를 나눠 쓴다", "자동으로 requests 가 줄어든다"]', 0, '원인을 찾을 때는 `kubectl describe pod` 아래쪽의 Events 를 보세요. requests 를 줄이거나 노드를 늘려야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 12, '단위 읽기', '`cpu: "0.5"` 와 `memory: 128Mi` 는 각각 어떻게 해석될까요? `100M` 과 `100Mi` 는 같은 값일까요?', 'Mi 는 1024 기반, M 은 1000 기반이에요.', NULL, NULL, '[]', 'choice', '["`0.5` 는 5 코어이고 `128Mi` 는 128000000 바이트이다", "`M` 과 `Mi` 는 같은 값이다", "`0.5` 는 오류이고 `500m` 만 쓸 수 있다", "`0.5` 는 `500m`(0.5 코어)로 저장되고 `128Mi` 는 134217728 바이트이다. `100M`(10^8 바이트)과 `100Mi`(100×1048576 바이트)는 서로 다른 값이다"]', 3, '메모리는 `Mi`, `Gi` 처럼 1024 기반 단위를 쓰는 것이 일반적입니다. `M` 과 섞어 쓰면 의도와 다른 한도가 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 13, 'kubectl set resources', '실행 중인 Deployment `web` 에 `kubectl set resources deployment web --limits=memory=64Mi` 를 실행하면 어떻게 될까요?', 'Pod 템플릿이 바뀌는 변경이에요.', NULL, NULL, '[]', 'choice', '["기존 Pod 의 한도가 즉시 바뀌고 Pod 는 그대로 유지된다", "아무 일도 일어나지 않고 다음 배포 때 적용된다", "Pod 템플릿이 바뀌므로 새 ReplicaSet 으로 롤링 업데이트가 일어나고 `rollout history` 에 새 리비전이 생긴다", "Deployment 가 삭제된다"]', 2, '한도를 바꾸면 Pod 가 새로 만들어진다는 점을 기억하세요. `rollout status` 로 완료를 기다리면 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 14, 'top 과 Allocated resources', '`kubectl top pod` 와 `kubectl describe node` 의 `Allocated resources` 는 각각 무엇을 보여 줄까요?', '하나는 실제 사용량, 하나는 예약된 양이에요.', NULL, NULL, '[]', 'choice', '["둘 다 실제 사용량을 보여 준다", "`top` 은 지금 실제로 쓰고 있는 CPU·메모리 사용량(metrics-server 가 필요)이고, `Allocated resources` 는 노드에 배치된 Pod 들의 requests 와 limits 합계와 노드 용량 대비 비율이다 (limits 합계는 100% 를 넘을 수 있다)", "`top` 은 requests 합계, `Allocated resources` 는 실제 사용량이다", "둘 다 limits 만 보여 준다"]', 1, '`describe node` 에는 `Total limits may be over 100 percent, i.e., overcommitted.` 라는 안내가 나옵니다. limits 는 합쳐서 노드 용량을 넘겨도 배치할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 15, 'QoS 필드', 'Pod 의 QoS 등급이 기록되는 `status` 필드 이름을 채우세요.', '"qos"와 "class"를 이어 붙이고 class 는 대문자로 시작해요.', NULL, NULL, '[]', 'fill', '["qosClass", "qos", "quality", "serviceClass"]', NULL, '`Guaranteed`, `Burstable`, `BestEffort` 중 하나가 들어 있습니다.', '[0]', 'kubectl get pod gu -o custom-columns=QOS:.status.{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 16, '아무것도 안 쓴 등급', '`requests` 와 `limits` 를 **하나도 쓰지 않은** Pod 의 QoS 등급을 채우세요.', '"최선을 다하는"이라는 뜻을 가진 이름이에요.', NULL, NULL, '[]', 'fill', '["BestEffort", "Burstable", "Guaranteed", "Basic"]', NULL, '보장되는 자원이 없는 가장 낮은 등급입니다.', '[0]', 'QoS Class: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 17, '보장된 등급', '모든 컨테이너가 `cpu` 와 `memory` 의 requests 와 limits 를 **같은 값**으로 쓴 Pod 의 QoS 등급을 채우세요.', '"보장된"이라는 뜻의 이름이에요.', NULL, NULL, '[]', 'fill', '["Guaranteed", "Burstable", "BestEffort", "Fixed"]', NULL, 'requests 와 limits 가 같아서 쓰는 만큼을 예약해 둔 가장 높은 등급입니다.', '[0]', 'QoS Class: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 18, '메모리 한도 키', '컨테이너의 **메모리 한도**를 적는 키 이름을 채우세요.', '"메모리"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["memory", "mem", "ram", "memoryLimit"]', NULL, '`requests` 아래에도 같은 이름의 키를 씁니다.', '[0]', 'limits: {0}: 64Mi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 19, '0.5 코어', '`cpu: 500m` 과 **같은 값**을 소수로 쓴 것을 채우세요.', '1000m 이 1 코어예요.', NULL, NULL, '[]', 'fill', '["0.5", "5", "50", "0.05"]', NULL, '저장될 때는 `500m` 으로 바뀌어 보입니다.', '[0]', 'cpu: "{0}"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 20, 'OOM 종료 코드', '메모리 한도를 넘어 `OOMKilled` 된 컨테이너의 **종료 코드**를 채우세요.', '128 + 9 (SIGKILL) 예요.', NULL, NULL, '[]', 'fill', '["137", "1", "126", "143"]', NULL, '143 은 SIGTERM(128 + 15) 으로 종료된 경우입니다.', '[0]', 'Exit Code: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 21, 'OOM 종료 이유', '`kubectl describe pod` 의 `Last State` 에서 메모리 한도 초과를 나타내는 **Reason** 값을 채우세요.', '"OOM"과 "Killed"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["OOMKilled", "OutOfMemory", "MemoryExceeded", "Error"]', NULL, '`Error` 는 일반적인 실패이고, 메모리 초과는 이 값으로 구분합니다.', '[0]', 'Reason: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 22, '자원 한도 바꾸기', '실행 중인 Deployment 의 **자원 요청·한도를 바꾸는** `kubectl` 하위 명령을 채우세요.', '"설정하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["set", "patch", "limit", "scale"]', NULL, '`--requests` 와 `--limits` 를 함께 줄 수 있습니다.', '[0]', 'kubectl {0} resources deployment web --limits=memory=64Mi', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 23, '실제 사용량 보기', 'Pod 의 **현재 CPU·메모리 사용량**을 보는 `kubectl` 하위 명령을 채우세요.', '"맨 위"라는 뜻이고 리눅스에서 쓰는 이름과 같아요.', NULL, NULL, '[]', 'fill', '["top", "usage", "stat", "metrics"]', NULL, 'metrics-server 가 있어야 동작합니다.', '[0]', 'kubectl {0} pod', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 24, '노드의 예약 현황', '노드에 **배치된 Pod 의 requests·limits 합계**(`Allocated resources`)를 볼 때 쓰는 하위 명령을 채우세요.', '"설명하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["describe", "top", "explain", "logs"]', NULL, '`top node` 는 예약량이 아니라 실제 사용량을 보여 줍니다.', '[0]', 'kubectl {0} node 노드이름', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 25, 'CPU 한도 초과의 결과', 'CPU 한도를 넘으려는 컨테이너는 종료되지 않고 CPU 사용이 어떻게 된다고 할까요? 영어 단어를 채우세요.', '"조절되다, 억제되다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["throttled", "OOMKilled", "Terminated", "Evicted"]', NULL, '`cpu.stat` 의 `nr_throttled` 가 늘어납니다.', '[0]', 'CPU 한도 초과 시: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 26, 'OOMKilled 원인 찾기', 'Pod 가 자꾸 재시작될 때 메모리 한도 초과를 확인하고 해결하는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 이유 확인 → 비교 → 조정 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 `RESTARTS` 가 늘고 상태가 `OOMKilled` 인 것을 확인한다", "`kubectl describe pod` 로 `Last State` 의 `Reason: OOMKilled` 와 `Exit Code: 137` 을 확인한다", "`kubectl top pod` 의 실제 메모리 사용량과 `limits.memory` 를 비교한다", "`limits.memory` 를 늘리거나 앱의 메모리 사용을 줄인 뒤 재시작이 멈췄는지 확인한다"]', NULL, '앱 로그에는 흔적이 없을 수 있으니 `describe` 를 먼저 보세요. 한도를 올릴 때는 노드의 남은 자원도 확인해야 해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 27, 'Pending 의 자원 부족 원인 찾기', 'Pod 가 `Pending` 인 이유가 자원 부족인지 확인하고 푸는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 이벤트 → 노드 현황 → 조정 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 로 `Pending` 상태를 확인한다", "`kubectl describe pod` 의 Events 에서 `Insufficient cpu` 같은 `FailedScheduling` 메시지를 읽는다", "`kubectl describe node` 의 `Allocated resources` 로 남은 requests 여유를 확인한다", "`requests` 를 줄이거나 노드를 늘린 뒤 Pod 가 `Running` 이 되는지 확인한다"]', NULL, '스케줄러는 실제 사용량이 아니라 requests 합계로 판단합니다. 실제로 한가한 노드라도 requests 가 가득 찼으면 Pending 이 돼요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 28, '자원 한도가 적용됐는지 확인', 'Pod 에 준 자원 한도가 실제 컨테이너에 적용됐는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '적용 → 설정 확인 → 컨테이너 안 확인 → 비교 순서예요.', NULL, NULL, '[]', 'order', '["`limits` 가 있는 Pod 를 `kubectl apply` 로 만든다", "`kubectl get pod -o jsonpath` 로 저장된 `resources` 를 확인한다", "`kubectl exec` 로 컨테이너 안의 `/sys/fs/cgroup/cpu.max` 와 `memory.max` 를 읽는다", "`cpu.max` 의 `50000 100000` 이 `500m` 과 맞는지 등 값을 limits 와 비교한다"]', NULL, 'limits 를 쓰지 않았다면 두 파일은 `max` 로 나옵니다. 이 경로는 cgroup v2 환경 기준이에요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 170, 29, 'Deployment 자원 조정하기', '실행 중인 Deployment 의 자원 요청·한도를 바꾸고 반영을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '변경 → 롤아웃 대기 → 반영 확인 → 이력 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl set resources deployment web --requests=... --limits=...` 로 값을 바꾼다", "`kubectl rollout status deployment web` 으로 새 Pod 로 교체가 끝나기를 기다린다", "`kubectl get deployment web -o jsonpath` 로 바뀐 `resources` 를 확인한다", "`kubectl rollout history deployment web` 에 새 리비전이 생겼는지 확인한다"]', NULL, '문제가 생기면 `kubectl rollout undo deployment web` 으로 이전 값으로 돌아갈 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 170 AND order_index = 29);
