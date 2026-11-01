-- k8s 세트 157. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set157.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 157, '배포 전략, 설정 반영 시점, 삭제 연쇄, 노드·DNS 읽기 한 줄씩', 'k8s 운영 중 헷갈리기 쉬운 동작을 한 개념씩 반복합니다. 기본 RollingUpdate(25%)와 Recreate 의 차이와 쓰임, 롤링 중 두 버전이 함께 도는 것, ConfigMap 을 바꿨을 때 환경 변수·볼륨·subPath 가 반영되는 시점과 rollout restart, emptyDir 의 수명, Deployment 삭제의 연쇄와 --cascade=orphan, 노드의 Capacity·Allocatable·Conditions 읽기, 클러스터 DNS 이름(서비스.네임스페이스.svc.cluster.local)을 짧은 객관식·빈칸·순서 문제로 익히고, 설정 반영 안 될 때, bad address 풀기, 고아로 지우기, 노드 상태 점검의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 157);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🧭' WHERE id = 157;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 1, '기본 배포 전략', 'Deployment 의 `strategy` 를 적지 않으면 기본 전략과 값은 무엇일까요?', '조금씩 바꾸는 방식이 기본이에요.', NULL, NULL, '[]', 'choice', '["`Recreate` 이고 값은 없다", "`RollingUpdate` 이고 `maxSurge` 는 0%, `maxUnavailable` 은 100%", "`RollingUpdate` 이고 `maxSurge` 와 `maxUnavailable` 은 각각 25%", "전략이 없어서 업데이트가 거부된다"]', 2, '`kubectl get deploy 이름 -o jsonpath=''{.spec.strategy}''` 로 확인할 수 있습니다. 대부분의 웹 서비스는 기본값으로 충분해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 2, 'Recreate 전략', '`strategy.type: Recreate` 인 Deployment 의 이미지를 바꾸면 어떻게 교체될까요?', '옛 것을 먼저 모두 내려요.', NULL, NULL, '[]', 'choice', '["새 Pod 를 먼저 올리고 옛 Pod 를 하나씩 줄인다", "옛 Pod 를 모두 내린 뒤에 새 Pod 를 올린다 (그 사이 잠깐 서비스가 끊긴다)", "옛 Pod 의 이미지만 그 자리에서 바꾼다", "교체하지 않고 이전 버전을 계속 쓴다"]', 1, '이벤트에서 `Scaled down ... to 0` 이 `Scaled up` 보다 먼저 나옵니다. 중단이 있어도 괜찮은 경우에만 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 3, 'Recreate 를 쓰는 경우', '다음 중 `Recreate` 전략이 알맞은 경우는 무엇일까요?', '두 버전이 동시에 떠 있으면 문제가 되는 경우를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["옛 버전과 새 버전이 동시에 떠 있으면 안 되는 앱 (데이터베이스 구조 변경, 단일 인스턴스 잠금 등)", "무중단 배포가 가장 중요한 웹 서비스", "Pod 가 100개인 서비스", "상태가 전혀 없는 간단한 API"]', 0, '대부분은 `RollingUpdate` 가 알맞습니다. `Recreate` 는 중단과 맞바꾸는 방식이니 정말 필요할 때만 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 4, '롤링 중의 두 버전', '`RollingUpdate` 로 배포하는 동안 요청은 어떻게 처리될까요?', '옛 Pod 와 새 Pod 가 잠시 함께 있어요.', NULL, NULL, '[]', 'choice', '["새 버전만 요청을 처리한다", "옛 버전만 요청을 처리한다", "배포 중에는 요청이 모두 거부된다", "옛 버전과 새 버전의 Pod 가 잠시 함께 떠서 둘 다 요청을 처리할 수 있다. 그래서 두 버전이 호환되어야 한다"]', 3, '이벤트에서 새 ReplicaSet 이 하나 늘고 옛 것이 하나 줄기를 번갈아 하는 것을 볼 수 있습니다. 이 때문에 API 나 DB 구조를 바꿀 때는 호환성을 먼저 챙겨야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 5, '환경 변수와 ConfigMap 변경', 'Pod 가 ConfigMap 의 값을 환경 변수(`configMapKeyRef`)로 받고 있습니다. ConfigMap 을 수정하면 실행 중인 Pod 의 환경 변수는 어떻게 될까요?', '환경 변수는 컨테이너가 시작할 때 한 번 정해져요.', NULL, NULL, '[]', 'choice', '["즉시 새 값으로 바뀐다", "1분 뒤 자동으로 바뀐다", "바뀌지 않는다. Pod 를 다시 만들어야 새 값이 들어간다", "Pod 가 자동으로 삭제된다"]', 2, '컨테이너가 시작될 때 환경 변수가 정해지기 때문입니다. 값을 바꾼 뒤에는 Pod 를 새로 띄워야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 6, '볼륨으로 마운트한 ConfigMap', 'ConfigMap 을 볼륨으로 마운트한 Pod 에서 ConfigMap 을 수정하면 마운트된 파일은 어떻게 될까요?', '파일은 환경 변수와 달리 갱신돼요. 다만 즉시는 아니에요.', NULL, NULL, '[]', 'choice', '["절대 갱신되지 않는다", "시간이 지나면 새 값으로 자동 갱신된다 (kubelet 이 주기적으로 동기화하므로 즉시는 아니다)", "수정하는 순간 갱신된다", "Pod 를 삭제해야만 갱신된다"]', 1, '갱신 시간이 수십 초에서 몇 분까지 걸릴 수 있습니다. 앱이 파일 변경을 다시 읽도록 만들어져 있어야 실제로 반영돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 7, 'subPath 의 함정', '`subPath` 로 ConfigMap 의 파일 하나를 마운트했습니다. ConfigMap 을 수정하면 이 파일은 어떻게 될까요?', 'subPath 는 일반 볼륨 마운트와 달라요.', NULL, NULL, '[]', 'choice', '["자동으로 갱신되지 않는다. Pod 를 다시 만들어야 새 값이 보인다", "일반 볼륨처럼 자동 갱신된다", "파일이 삭제된다", "ConfigMap 수정이 거부된다"]', 0, '`subPath` 는 파일 하나를 복사해 두는 방식이라 갱신되지 않습니다. 자동 갱신이 필요하면 폴더 전체를 마운트하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 8, '설정 변경을 반영하는 가장 간단한 방법', 'ConfigMap 을 수정한 뒤 Deployment 의 Pod 들이 새 값을 확실히 읽게 하려면 어떻게 할까요?', '재시작하면 새로 시작하며 새 값을 읽어요.', NULL, NULL, '[]', 'choice', '["`kubectl delete configmap` 을 한다", "노드를 재부팅한다", "아무것도 하지 않아도 항상 즉시 반영된다", "`kubectl rollout restart deployment/이름` 으로 Pod 를 롤링 방식으로 다시 띄운다"]', 3, '롤링 방식이라 서비스가 끊기지 않습니다. 환경 변수와 `subPath` 로 받는 설정은 이 방법이 필요해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 9, 'emptyDir 의 수명', '`emptyDir` 볼륨에 쓴 파일은 언제 사라질까요?', 'Pod 의 수명과 같이 가요.', NULL, NULL, '[]', 'choice', '["컨테이너가 재시작되면 사라지고 Pod 를 삭제하면 남는다", "노드를 재부팅해도 항상 남는다", "Pod 가 삭제되면 함께 사라진다. 컨테이너만 재시작되는 경우에는 남아 있다", "만든 지 1시간이 지나면 사라진다"]', 2, '같은 Pod 의 컨테이너끼리 파일을 공유하거나 임시 작업 공간으로 쓰기에 알맞습니다. 영구 저장이 필요하면 PVC 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 10, 'Deployment 를 지우면', '`kubectl delete deployment web` 을 하면 그 Deployment 가 만든 ReplicaSet 과 Pod 는 어떻게 될까요?', '소유 관계를 따라 함께 정리돼요.', NULL, NULL, '[]', 'choice', '["ReplicaSet 과 Pod 는 그대로 남는다", "기본으로 소유 관계를 따라 ReplicaSet 과 Pod 도 함께 삭제된다", "Pod 만 남고 ReplicaSet 만 삭제된다", "삭제가 거부된다"]', 1, '`kubectl describe pod` 의 `Controlled By` 가 ReplicaSet, ReplicaSet 의 `Controlled By` 가 Deployment 로 이어지는 연쇄 구조 때문이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 11, '--cascade=orphan', '`kubectl delete deployment web --cascade=orphan` 은 무엇을 할까요?', 'orphan 은 "고아"예요.', NULL, NULL, '[]', 'choice', '["Deployment 만 삭제하고 ReplicaSet 과 Pod 는 남겨 둔다 (소유자가 없어진 고아 상태가 된다)", "모든 것을 즉시 삭제한다", "삭제를 취소한다", "Pod 만 삭제한다"]', 0, '남은 ReplicaSet 은 직접 지워야 하고 지우면 Pod 도 함께 사라집니다. Pod 를 유지한 채 관리 방식만 바꿔야 할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 12, 'Capacity 와 Allocatable', '`kubectl describe node` 의 `Capacity` 와 `Allocatable` 은 무엇일까요?', '전체와 실제로 쓸 수 있는 양이에요.', NULL, NULL, '[]', 'choice', '["둘은 항상 같은 값이다", "`Allocatable` 은 노드의 전체 자원이다", "`Capacity` 는 Pod 의 requests 합이다", "`Capacity` 는 노드의 전체 자원이고 `Allocatable` 은 그중 Pod 에 배정할 수 있는 양이다. 시스템용으로 따로 예약하면 `Allocatable` 이 더 작아진다"]', 3, '스케줄러는 `Allocatable` 에서 이미 배정된 requests 를 뺀 만큼만 새 Pod 를 올립니다. 이 노드처럼 예약이 없으면 두 값이 같을 수도 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 13, 'Conditions 읽기', '`kubectl describe node` 의 Conditions 에 `Ready True`, `MemoryPressure False`, `DiskPressure False`, `PIDPressure False` 가 보입니다. 상태는 어떨까요?', 'Ready 는 True 가, Pressure 는 False 가 정상이에요.', NULL, NULL, '[]', 'choice', '["메모리가 부족한 상태이다", "노드가 준비되지 않은 상태이다", "정상이다. Ready 가 True 이고 메모리·디스크·프로세스 압박이 없다", "디스크가 가득 찬 상태이다"]', 2, '`Ready` 가 `False` 나 `Unknown` 이면 NotReady, 어떤 Pressure 가 `True` 이면 그 자원이 부족하다는 뜻입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 14, '클러스터 안 이름 부르기', '`web` 네임스페이스의 Pod 에서 같은 네임스페이스의 Service `api` 는 `api` 로 접속되는데, 다른 네임스페이스 `prod` 의 Pod 에서 `api` 라고만 부르면 어떻게 될까요?', '짧은 이름은 자기 네임스페이스에서만 풀려요.', NULL, NULL, '[]', 'choice', '["항상 성공한다", "`bad address` 로 실패한다. `api.web` 처럼 네임스페이스를 붙이거나 `api.web.svc.cluster.local` 전체 이름을 써야 한다", "모든 네임스페이스에서 자동으로 찾아 준다", "Service 를 새로 만들어야 한다"]', 1, 'Pod 의 `/etc/resolv.conf` 의 `search` 줄이 자기 네임스페이스를 먼저 붙여 찾기 때문입니다. 다른 네임스페이스의 Service 는 이름에 네임스페이스를 포함하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 15, '모두 내렸다 올리는 전략', '옛 Pod 를 **모두 내린 뒤 새로 올리는** 전략의 이름을 채우세요.', '"다시 만들다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["Recreate", "Replace", "StopStart", "Rebuild"]', NULL, '`strategy:` 아래에 `type: Recreate` 를 적습니다. 이 경우 `rollingUpdate` 설정은 쓰지 않아요.', '[0]', 'type: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 16, 'Pod 를 다시 띄우기', '설정을 바꾼 뒤 Deployment 의 Pod 를 **롤링 방식으로 다시 띄우는** 하위 명령을 채우세요.', '"다시 시작하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["restart", "reload", "refresh", "reapply"]', NULL, '이미지를 바꾸지 않아도 Pod 가 새로 만들어집니다. 새 Pod 는 바뀐 ConfigMap 과 Secret 을 읽어요.', '[0]', 'kubectl rollout {0} deployment/web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 17, 'Pod 는 남기고 지우기', 'Deployment 만 삭제하고 **Pod 는 남기는** 값을 채우세요.', '"고아"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["orphan", "keep", "retain", "detach"]', NULL, '남은 ReplicaSet 과 Pod 는 직접 정리해야 합니다. 정리하지 않으면 계속 떠 있어요.', '[0]', 'kubectl delete deployment web --cascade={0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 18, '소유자 줄 찾기', '`kubectl describe pod` 에서 **Pod 를 만든 소유자**가 적힌 줄을 찾으려고 합니다. 단어를 채우세요.', '"~에 의해 제어됨"이라는 줄이에요.', NULL, NULL, '[]', 'fill', '["Controlled", "Owner", "Parent", "Created"]', NULL, '`Controlled By: ReplicaSet/...` 로 보입니다. ReplicaSet 을 describe 하면 `Controlled By: Deployment/...` 가 나와요.', '[0]', 'kubectl describe pod web-abc | grep {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 19, '임시 공유 볼륨', 'Pod 가 사라지면 함께 사라지는 **임시 볼륨** 종류를 채우세요.', '"비어 있는 폴더"를 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["emptyDir", "tmpDir", "shared", "scratch"]', NULL, '같은 Pod 의 컨테이너끼리 파일을 주고받을 때 씁니다. 컨테이너가 재시작해도 남지만 Pod 를 지우면 사라져요.', '[0]', 'volumes: [{ name: d, {0}: {} }]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 20, '노드 자세히 보기', '노드의 **자세한 정보(Capacity, Conditions 등)**를 보는 대상을 채우세요.', '리소스 종류는 "노드"예요.', NULL, NULL, '[]', 'fill', '["node", "host", "machine", "server"]', NULL, '`Conditions`, `Capacity`, `Allocatable`, `Allocated resources`, `Taints`, 이벤트가 한 번에 나옵니다. 노드에 문제가 있을 때 가장 먼저 보세요.', '[0]', 'kubectl describe {0} 노드이름', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 21, '노드 목록 자세히', '노드 목록에 **IP 와 OS 같은 추가 열**을 함께 보는 값을 채우세요.', '"넓은"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["wide", "long", "detail", "full"]', NULL, '`INTERNAL-IP`, `OS-IMAGE`, `KERNEL-VERSION` 같은 열이 더해집니다. Pod 와 노드에서 모두 쓰는 옵션이에요.', '[0]', 'kubectl get nodes -o {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 22, '다른 네임스페이스 부르기', '네임스페이스 `prod` 의 Service `api` 를 **짧게** 부르는 올바른 이름을 채우세요.', '서비스 이름 뒤에 네임스페이스를 붙여요.', NULL, NULL, '[]', 'fill', '["prod", "svc.prod", "prod.svc.cluster", "cluster.local"]', NULL, '`api.prod` 는 다른 네임스페이스에서도 통합니다. 가장 완전한 이름은 `api.prod.svc.cluster.local` 이에요.', '[0]', 'wget -qO- http://api.{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 23, '가장 완전한 서비스 이름', 'Service 의 **전체 이름(FQDN)** 에서 빈칸을 채우세요.', '"서비스"와 "클러스터"가 들어가요.', NULL, NULL, '[]', 'fill', '["svc.cluster.local", "cluster.local", "svc.local", "prod.local"]', NULL, '`svc` 를 빼먹고 `api.prod.cluster.local` 로 쓰면 이름이 풀리지 않습니다. 형식은 `서비스.네임스페이스.svc.cluster.local` 이에요.', '[0]', 'http://api.prod.{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 24, 'DNS 설정 파일 보기', 'Pod 안에서 **DNS 검색 도메인(search)** 이 적힌 파일을 보려고 합니다. 경로를 채우세요.', '리눅스의 DNS 설정 파일이에요.', NULL, NULL, '[]', 'fill', '["/etc/resolv.conf", "/etc/hosts", "/etc/dns", "/etc/search"]', NULL, '`search 자기네임스페이스.svc.cluster.local svc.cluster.local cluster.local` 모양입니다. 짧은 이름이 풀리는 이유를 보여 줘요.', '[0]', 'kubectl exec c1 -- grep ^search {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 25, '노드 상태 섹션 찾기', '`describe node` 의 출력에서 **Ready, MemoryPressure 등이 있는 섹션**을 앞뒤 6줄과 함께 찾으려고 합니다. 단어를 채우세요.', '"상태 조건"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["Conditions", "Status", "Health", "State"]', NULL, '`Ready` 가 `True` 이고 각 `Pressure` 가 `False` 이면 정상입니다. 이상하면 이벤트도 함께 보세요.', '[0]', 'kubectl describe node 노드이름 | grep -A6 {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 26, '설정을 바꿨는데 앱에 반영이 안 될 때', 'ConfigMap 을 수정했는데 앱이 옛 값을 쓰는 경우의 조사 순서입니다. 순서에 맞게 놓아 보세요.', '값 확인 → Pod 안 확인 → 방식 파악 → 재시작 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get configmap 이름 -o yaml` 로 새 값이 들어갔는지 확인한다", "`kubectl exec` 로 Pod 안의 환경 변수나 파일에서 실제 값을 본다", "환경 변수나 `subPath` 로 받은 값은 자동 갱신되지 않는다는 것을 파악한다", "`kubectl rollout restart deployment/이름` 으로 다시 띄우고 값을 다시 확인한다"]', NULL, '볼륨(폴더 전체)으로 받은 값은 시간이 지나면 갱신되지만 앱이 다시 읽어야 합니다. 확실히 반영하려면 재시작이 가장 간단해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 27, '다른 네임스페이스 서비스 호출 실패 풀기', '다른 네임스페이스의 Service 를 부르다 `bad address` 가 날 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '오류 → 네임스페이스 찾기 → 이름 고치기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`bad address` 오류가 났음을 확인한다", "`kubectl get svc -A` 로 그 Service 가 어느 네임스페이스에 있는지 본다", "`서비스.네임스페이스` 또는 전체 이름(`.svc.cluster.local`)으로 바꿔 부른다", "다시 호출해 응답이 오는지 확인한다"]', NULL, '짧은 이름은 자기 네임스페이스에서만 풀립니다. 설정 파일에 적는 주소도 네임스페이스를 포함하는 것이 안전해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 28, 'Deployment 만 지우고 Pod 는 남기기', 'Deployment 만 삭제하고 Pod 는 잠시 유지한 뒤 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '관계 확인 → 고아로 삭제 → 남은 것 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get deploy,rs,pods` 로 소유 관계를 확인한다", "`kubectl delete deployment web --cascade=orphan` 으로 Deployment 만 삭제한다", "`kubectl get rs,pods` 로 ReplicaSet 과 Pod 가 남아 있는지 확인한다", "다 쓴 뒤 `kubectl delete rs -l app=web` 으로 남은 ReplicaSet 을 정리한다 (Pod 도 함께 사라진다)"]', NULL, '고아가 된 ReplicaSet 과 Pod 는 아무도 관리하지 않으므로 정리를 잊지 마세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 157, 29, '노드 상태 점검하기', '노드의 상태와 자원 여유를 점검하는 순서입니다. 순서에 맞게 놓아 보세요.', '목록 → 자세히 → 상태 → 자원 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get nodes -o wide` 로 노드 목록과 상태를 본다", "`kubectl describe node 이름` 으로 자세한 정보를 연다", "Conditions 에서 `Ready` 가 `True` 이고 Pressure 가 모두 `False` 인지 본다", "Allocatable 과 Allocated resources 로 requests 가 얼마나 찼는지 본다"]', NULL, '스케줄링이 안 되는 Pod 는 `Allocated resources` 가 `Allocatable` 에 가까운지 먼저 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 157 AND order_index = 29);
