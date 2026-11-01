-- k8s 세트 186. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set186.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 186, 'Service 와 Endpoints 심화: 셀렉터·targetPort, EndpointSlice, 헤드리스, ExternalName, DNS', 'Service 가 Pod 로 연결되는 과정을 한 개념씩 반복합니다. Endpoints 와 EndpointSlice 읽기와 Endpoints 의 deprecated 경고, describe svc 의 Selector·Port·TargetPort·Endpoints 와 3개까지만 보이는 목록, 셀렉터 오타로 엔드포인트가 비는 것, targetPort 가 틀리거나 이름으로 쓸 때, 포트가 둘 이상일 때 필요한 이름과 NodePort 범위 오류, readinessProbe 와 notReadyAddresses, sessionAffinity: ClientIP, 서비스 환경 변수가 생기는 시점, Service DNS 이름 형태와 다른 네임스페이스에서의 접속과 resolv.conf, 헤드리스 Service 의 조회 결과와 포트 변환이 없는 것, ExternalName, 셀렉터 없는 Service 에 EndpointSlice 로 주소 연결하기, kubectl expose 를 짧은 객관식·빈칸·순서 문제로 익히고, 엔드포인트가 비어 있는 원인 찾기, targetPort 점검, 준비되지 않은 Pod 확인, 셀렉터 없는 Service 에 외부 주소 연결하기의 순서를 연습합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 186);
UPDATE quest_set SET display_order = 249, unit_id = (SELECT id FROM unit WHERE id = 7), icon = '🔗' WHERE id = 186;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 1, 'Endpoints 와 EndpointSlice', '`kubectl get endpoints web` 의 `ENDPOINTS` 열과 `kubectl get endpointslices -l kubernetes.io/service-name=web` 는 각각 무엇을 보여 줄까요? 실행하면 어떤 경고가 나올까요?', 'Service 가 보내는 대상 목록이에요.', NULL, NULL, '[]', 'choice', '["`Endpoints` 는 Service 의 ClusterIP 하나만 보여 준다", "`EndpointSlice` 는 Pod 의 로그를 보여 준다", "`ENDPOINTS` 열에는 Service 가 트래픽을 보내는 `Pod주소:targetPort` 목록이 나오고, `EndpointSlice` 는 같은 정보를 `discovery.k8s.io/v1` 리소스로 보여 준다(`ports` 에 8080, 주소 목록, 슬라이스 하나에 5개까지 확인). `kubectl get endpoints` 는 `v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice` 경고를 낸다", "`kubectl get endpoints` 는 경고 없이 항상 최신 방식이다"]', 2, '`EndpointSlice` 는 `kubernetes.io/service-name` 라벨로 어느 Service 의 것인지 표시합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 2, 'describe svc 읽기', '`kubectl describe svc web` 의 `Selector`, `Port`, `TargetPort`, `Endpoints` 는 각각 무엇을 뜻할까요? Pod 가 5개일 때 `Endpoints` 줄은 어떻게 보일까요?', 'Service 가 Pod 를 찾고 보내는 방식이에요.', NULL, NULL, '[]', 'choice', '["`Port` 는 Pod 가 여는 포트이고 `TargetPort` 는 Service 포트이다", "`Selector` 는 대상 Pod 를 고르는 라벨, `Port` 는 Service 가 받는 포트(`<unset> 80/TCP`), `TargetPort` 는 Pod 로 보내는 포트(`8080/TCP`), `Endpoints` 는 실제 대상 목록이다. Pod 가 5개면 3개만 보이고 `+ 2 more...` 로 줄여 보여 준다", "`Endpoints` 는 항상 모든 주소를 보여 준다", "`Selector` 는 Service 의 이름이다"]', 1, '전체 목록은 `kubectl get endpointslices` 에서 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 3, '셀렉터가 맞지 않으면', 'Service 의 셀렉터를 `app=wbe` 로 잘못 고쳤습니다(Pod 라벨은 `app=web`). 엔드포인트와 접속, Service 와 Pod 의 상태는 어떻게 될까요?', 'Service 는 남아 있지만 대상이 없어요.', NULL, NULL, '[]', 'choice', '["엔드포인트가 `<none>` 이 되고 `describe` 의 `Endpoints:` 도 비며, Service 에 접속하면 `Connection refused` 로 실패한다. Service 의 ClusterIP 는 그대로이고 Pod 도 `1/1` 로 정상이다. 셀렉터를 `app=web` 으로 고치면 엔드포인트가 다시 생긴다", "Service 가 삭제되고 Pod 가 재시작된다", "엔드포인트는 그대로이고 접속도 성공한다", "Pod 가 `Pending` 이 된다"]', 0, '`Endpoints` 가 비면 Service 의 셀렉터와 Pod 의 라벨(`kubectl get pods --show-labels`)을 비교하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 4, 'targetPort 가 틀리면', 'Service 의 `targetPort` 를 컨테이너가 열지 않은 9999 로 바꿨습니다. 엔드포인트와 접속은 어떻게 될까요? `targetPort: http` 처럼 이름을 쓰면요?', '엔드포인트에는 보이지만 닫힌 포트예요.', NULL, NULL, '[]', 'choice', '["엔드포인트가 비고 Service 가 삭제된다", "`targetPort` 는 이름으로 쓸 수 없다", "포트가 달라도 접속은 항상 성공한다", "엔드포인트에 `Pod주소:9999` 가 나타나지만 그 포트를 여는 프로세스가 없어서 접속은 `Connection refused` 이다. `targetPort: http` 처럼 이름을 쓰면 컨테이너의 `ports` 에서 `name: http` 인 포트(8080)로 연결되어 접속된다"]', 3, '엔드포인트가 있는데 접속이 안 되면 `targetPort` 와 컨테이너 포트가 같은지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 5, 'Service 포트 이름과 targetPort 기본값', 'Service 에 포트를 두 개 쓰면서 `name` 을 생략하면 어떻게 될까요? `kubectl create service clusterip dflt --tcp=8081` 의 `targetPort` 는요?', '포트가 여러 개면 구분할 이름이 필요해요.', NULL, NULL, '[]', 'choice', '["이름이 없어도 포트는 몇 개든 만들어진다", "`targetPort` 를 생략하면 80 이 된다", "`spec.ports[0].name: Required value`, `spec.ports[1].name: Required value` 오류로 거부되고(이름을 주면 만들어진다), `--tcp=8081` 은 `port` 와 `targetPort` 가 같은 8081/8081 로 만들어진다", "오류 없이 두 번째 포트가 무시된다"]', 2, '`kubectl get svc` 의 PORT(S) 열에 `80/TCP,81/TCP` 처럼 여러 포트가 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 6, 'NodePort 범위', '`type: NodePort` 에 `nodePort: 80` 을 쓰면 어떻게 될까요? 지정하지 않으면요? `PORT(S)` 열은 어떻게 보일까요?', 'NodePort 는 정해진 범위에서만 열려요.', NULL, NULL, '[]', 'choice', '["`nodePort` 는 1~65535 어느 값이든 쓸 수 있다", "`provided port is not in the valid range. The range of valid ports is 30000-32767` 오류로 거부된다. 지정하지 않으면 30000~32767 에서 자동 할당되고 `PORT(S)` 열은 `80:3xxxx/TCP` 처럼 Service 포트와 노드 포트가 함께 나온다", "지정하지 않으면 80 이 할당된다", "`PORT(S)` 열에는 노드 포트가 나오지 않는다"]', 1, '`kubectl expose deployment web --type=NodePort --port=80 --target-port=http` 로도 만듭니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 7, 'readinessProbe 와 엔드포인트', '`readinessProbe` 가 실패하는 Pod(`READY 0/1`)가 `web` Service 의 셀렉터에 맞는 라벨을 가지고 있습니다. 엔드포인트와 요청은 어떻게 될까요?', '준비되지 않은 Pod 는 트래픽을 받지 않아요.', NULL, NULL, '[]', 'choice', '["그 Pod 는 엔드포인트의 `notReadyAddresses` 에 들어가고(EndpointSlice 의 `ready` 조건은 `false`) 준비된 Pod 만 주소 목록에 남는다. 20번 요청해도 그 Pod 가 응답한 적이 없다", "준비되지 않아도 요청을 받는다", "Pod 가 Service 에서 삭제된다", "Service 의 ClusterIP 가 바뀐다"]', 0, '배포 중 준비가 안 된 새 Pod 로 요청이 가지 않게 하는 장치입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 8, 'sessionAffinity', 'Service 에 20번 요청하면 Pod 2개에 어떻게 나뉠까요? `sessionAffinity: ClientIP` 로 바꾸면 15번 요청은요? 기본 유지 시간은요?', '같은 클라이언트는 같은 Pod 로 보내요.', NULL, NULL, '[]', 'choice', '["기본에서도 항상 한 Pod 로만 간다", "`ClientIP` 는 요청을 모든 Pod 로 균등하게 나눈다", "유지 시간 기본값은 10초이다", "기본(`None`)에서는 Pod 2개가 모두 응답한다. `ClientIP` 로 바꾸면 같은 클라이언트 IP 의 요청은 모두 같은 Pod 로 가서 응답한 Pod 가 1개이고, `timeoutSeconds` 기본값은 10800(3시간)이다"]', 3, '`kubectl get svc web -o jsonpath` 로 `spec.sessionAffinity` 값을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 9, '서비스 환경 변수', 'Service `web` 이 있는 상태에서 새로 만든 Pod 의 환경 변수에는 무엇이 생길까요? Pod 가 시작된 뒤에 만든 Service 는요?', 'Pod 가 시작될 때의 Service 목록으로 정해져요.', NULL, NULL, '[]', 'choice', '["Service 를 만들면 실행 중인 모든 Pod 에 변수가 생긴다", "서비스 환경 변수는 만들어지지 않는다", "`WEB_SERVICE_HOST`, `WEB_SERVICE_PORT`, `WEB_PORT=tcp://ClusterIP:80` 이 생긴다. Pod 가 시작된 뒤에 만든 Service(예: `np2`)의 변수(`NP2_SERVICE_HOST`)는 이미 실행 중인 Pod 에 생기지 않는다", "변수는 NodePort Service 에만 생긴다"]', 2, '이미 실행 중인 Pod 에서 새 Service 를 부르려면 DNS 이름을 쓰면 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 10, 'Service DNS 이름', '같은 네임스페이스의 Pod 에서 `web`, `web.네임스페이스`, `web.네임스페이스.svc`, `web.네임스페이스.svc.cluster.local` 로 접속하면 어떻게 될까요? 다른 네임스페이스의 Pod 에서 `web` 만 쓰면요? `/etc/resolv.conf` 는요?', '짧은 이름은 검색 도메인으로 완성돼요.', NULL, NULL, '[]', 'choice', '["다른 네임스페이스에서도 `web` 만으로 접속된다", "네 가지 이름 모두 접속된다. 다른 네임스페이스에서는 `web` 만으로 `bad address ''web''` 이고 `web.네임스페이스` 로 써야 한다. `/etc/resolv.conf` 에는 `search 네임스페이스.svc.cluster.local svc.cluster.local cluster.local` 과 `options ndots:5` 가 있다", "짧은 이름은 같은 네임스페이스에서도 접속되지 않는다", "`search` 줄이 없다"]', 1, '없는 이름(`webb`)은 `bad address` 로 실패합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 11, 'Headless Service', '`clusterIP: None` 인 헤드리스 Service 는 `kubectl get svc` 의 CLUSTER-IP 에 무엇이 보일까요? 이름을 조회하면 일반 Service 와 어떻게 다를까요? Service 포트 80 으로 접속하면요?', '가상 IP 가 없으니 Pod 주소가 그대로 나와요.', NULL, NULL, '[]', 'choice', '["CLUSTER-IP 가 `None` 이다. 일반 Service 는 이름이 ClusterIP 하나로 풀리고, 헤드리스는 이름이 Pod 들의 IP 전체(예: 2개)로 풀린다. 가상 IP 가 없어 `port`→`targetPort` 변환이 일어나지 않으므로 Service 포트 80 은 거부되고 Pod 가 실제로 여는 8080 으로 접속해야 한다", "헤드리스도 이름이 ClusterIP 하나로 풀린다", "헤드리스는 포트 80 으로 접속하면 8080 으로 자동 전달된다", "헤드리스 Service 는 CLUSTER-IP 가 `Pending` 이다"]', 0, 'StatefulSet 처럼 Pod 하나하나를 이름으로 가리켜야 할 때 헤드리스를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 12, 'ExternalName', '`type: ExternalName`, `externalName: web.네임스페이스.svc.cluster.local` 인 Service `alias` 는 `kubectl get svc` 에서 어떻게 보일까요? `alias` 로 접속하면 어떻게 될까요?', '다른 이름으로 연결하는 별칭이에요.', NULL, NULL, '[]', 'choice', '["`ExternalName` 도 ClusterIP 를 새로 할당받는다", "`alias` 는 접속되지 않는다", "`ExternalName` 은 셀렉터로 Pod 를 고른다", "`TYPE` 이 `ExternalName`, `CLUSTER-IP` 는 `<none>`, `EXTERNAL-IP` 열에 그 이름이 보인다. `alias` 의 DNS 조회 결과는 `web` Service 의 ClusterIP 와 같고 `alias` 로 접속하면 `web` 의 Pod 가 응답한다"]', 3, '클러스터 밖의 서비스를 클러스터 안 이름으로 부르게 할 때 씁니다(여기서는 클러스터 안의 이름으로 확인했습니다).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 13, '셀렉터 없는 Service', '셀렉터가 없는 Service `manual` 은 `describe` 에서 어떻게 보일까요? 접속은 될까요? `kubernetes.io/service-name: manual` 라벨을 붙여 `EndpointSlice` 를 만들면요? `Endpoints` 오브젝트를 직접 만들면요?', '대상을 직접 연결해 주어야 해요.', NULL, NULL, '[]', 'choice', '["셀렉터가 없어도 Pod 를 자동으로 찾아 연결한다", "`EndpointSlice` 를 만들어도 접속되지 않는다", "`Selector: <none>`, `Endpoints: <none>` 이고 접속은 `Connection refused` 이다. 라벨 `kubernetes.io/service-name: manual` 이 붙은 `EndpointSlice`(addresses 와 ports 지정)를 만들면 `Endpoints` 에 주소가 생기고 접속된다. `Endpoints` 오브젝트도 동작하며 슬라이스로 미러링되지만 `deprecated` 경고가 나온다", "`Endpoints` 오브젝트는 만들 수 없다"]', 2, '클러스터 밖의 데이터베이스 같은 주소를 Service 이름으로 부르게 할 때 이 방식을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 14, 'kubectl expose', '`kubectl expose deployment web --name=exp --port=8082 --target-port=http` 는 무엇을 만들까요? 라벨이 없는 Pod 에 `kubectl expose pod client --port=80` 을 하면요?', '대상의 라벨로 셀렉터를 만들어요.', NULL, NULL, '[]', 'choice', '["라벨이 없어도 모든 Pod 를 대상으로 하는 Service 가 만들어진다", "Deployment 의 Pod 라벨(`app=web`)을 셀렉터로 하는 ClusterIP Service(`8082/TCP`)를 만든다. 라벨이 없는 Pod 는 `couldn''t retrieve selectors via --selector flag or introspection: the pod has no labels` 오류가 난다", "`expose` 는 Service 를 삭제한다", "셀렉터는 항상 빈 값으로 만들어진다"]', 1, '`--selector` 로 직접 정할 수도 있습니다(여기서는 오류 문구만 확인했습니다).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 15, '엔드포인트 보기', 'Service 가 트래픽을 보내는 **대상 목록**을 보는 `kubectl get` 대상을 채우세요.', '"끝점들"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["endpoints", "targets", "backends", "pods-of"]', NULL, '실행하면 `EndpointSlice` 를 쓰라는 경고가 함께 나옵니다.', '[0]', 'kubectl get {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 16, 'EndpointSlice 조회', '`discovery.k8s.io/v1` 의 **엔드포인트 조각**을 보는 `kubectl get` 대상을 채우세요.', '"endpoint"와 "slice"의 복수형을 이어요.', NULL, NULL, '[]', 'fill', '["endpointslices", "epslices", "slices", "endpoints-v2"]', NULL, '한 슬라이스에 여러 Pod 주소가 들어 있습니다.', '[0]', 'kubectl get {0} -l kubernetes.io/service-name=web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 17, '서비스 라벨 키', '`EndpointSlice` 가 **어느 Service 의 것인지** 표시하는 라벨 키를 채우세요.', '"kubernetes.io/" 뒤에 service 와 name 이 붙어요.', NULL, NULL, '[]', 'fill', '["kubernetes.io/service-name", "app.kubernetes.io/name", "service", "kubernetes.io/svc"]', NULL, '셀렉터 없는 Service 에 직접 만든 슬라이스에도 이 라벨이 필요합니다.', '[0]', 'kubectl get endpointslices -l {0}=web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 18, 'Pod 포트로 보낼 포트', '`kubectl expose` 에서 Pod 로 보낼 **대상 포트**를 정하는 옵션을 채우세요.', '"target"과 "port"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["target-port", "pod-port", "container-port", "to-port"]', NULL, '생략하면 `--port` 와 같은 값이 됩니다.', '[0]', 'kubectl expose deployment web --port=80 --{0}=8080', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 19, '같은 Pod 로 유지', '같은 클라이언트의 요청을 **같은 Pod 로** 보내는 `sessionAffinity` 값을 채우세요.', '"클라이언트"와 "IP"를 이어 붙여요.', NULL, NULL, '[]', 'fill', '["ClientIP", "SourcePod", "Sticky", "Session"]', NULL, '기본값은 `None` 입니다.', '[0]', 'sessionAffinity: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 20, '헤드리스', '가상 IP 가 **없는** 헤드리스 Service 를 만드는 `clusterIP` 값을 채우세요.', '"없음"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["None", "null", "0", "Headless"]', NULL, '이름 조회가 Pod IP 들로 풀립니다.', '[0]', 'clusterIP: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 21, 'DNS 별칭 Service', '다른 DNS 이름의 **별칭**으로 동작하는 Service `type` 값을 채우세요.', '"외부 이름"을 이어 붙여요.', NULL, NULL, '[]', 'fill', '["ExternalName", "Alias", "CNAME", "ExternalDNS"]', NULL, 'ClusterIP 를 할당받지 않습니다.', '[0]', 'type: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 22, '별칭이 가리킬 이름', '`ExternalName` Service 가 **연결할 이름**을 적는 필드를 채우세요.', '"external"과 "name"을 이어 붙이고 앞은 소문자예요.', NULL, NULL, '[]', 'fill', '["externalName", "target", "cname", "dnsName"]', NULL, '`describe` 에는 `External Name:` 으로 나옵니다.', '[0]', '{0}: web.ns.svc.cluster.local', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 23, '포트 이름 필드', 'Service 에 포트가 여러 개일 때 **반드시 정해야 하는** 포트 항목의 필드를 채우세요.', '"이름"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["name", "id", "label", "title"]', NULL, '생략하면 `Required value` 오류가 납니다.', '[0]', 'ports: [ { {0}: a, port: 80 } ]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 24, 'NodePort 값', '자동으로 할당되는 범위(30000~32767) **안의** `nodePort` 값을 채우세요.', '30000 보다 큰 값이에요.', NULL, NULL, '[]', 'fill', '["30080", "8080", "80", "3000"]', NULL, '범위 밖의 값은 거부됩니다.', '[0]', 'nodePort: {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 25, '준비 안 된 주소', '`Endpoints` 의 `subsets` 에서 **준비되지 않은 Pod** 가 들어가는 필드를 채우세요.', '"준비 안 됨"과 "주소들"을 이어요.', NULL, NULL, '[]', 'fill', '["notReadyAddresses", "pendingAddresses", "unreadyIPs", "downAddresses"]', NULL, '`readinessProbe` 가 통과하면 `addresses` 로 옮겨 갑니다.', '[0]', 'kubectl get endpoints web -o jsonpath=''.subsets[0].{0}''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 26, '엔드포인트가 비어 있는 원인 찾기', 'Service 에 접속이 안 될 때 엔드포인트가 비어 있는 원인을 찾아 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 셀렉터 → 라벨 비교 → 수정 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get endpoints web` 의 `ENDPOINTS` 가 `<none>` 인 것을 확인한다", "`kubectl describe svc web` 의 `Selector` 값을 확인한다", "`kubectl get pods --show-labels` 로 Pod 라벨과 셀렉터를 비교해 오타를 찾는다", "셀렉터(또는 라벨)를 고친 뒤 엔드포인트에 `Pod주소:포트` 가 생겼는지와 접속을 확인한다"]', NULL, '엔드포인트가 있는데도 안 되면 `targetPort` 를 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 27, 'targetPort 를 점검하기', '엔드포인트는 있는데 `Connection refused` 가 날 때 포트를 점검하는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 설정 확인 → 비교 → 수정 순서예요.', NULL, NULL, '[]', 'order', '["다른 Pod 에서 `wget http://web` 을 해서 `Connection refused` 를 확인한다", "`kubectl describe svc web` 의 `TargetPort` 를 확인한다", "`kubectl get endpoints web` 의 포트가 컨테이너가 실제로 여는 포트(`ports` 의 8080)와 같은지 비교한다", "`targetPort` 를 8080 이나 포트 이름(`http`)으로 고치고 다시 접속한다"]', NULL, '`targetPort` 에 포트 이름을 쓰면 컨테이너 포트 번호가 바뀌어도 Service 를 고치지 않아도 됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 28, '준비되지 않은 Pod 로 트래픽이 안 갈 때', '일부 Pod 에 요청이 가지 않을 때 준비 상태를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', 'READY → 엔드포인트 → 원인 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`kubectl get pods` 에서 해당 Pod 의 `READY` 가 `0/1` 인 것을 확인한다", "`kubectl get endpoints web -o jsonpath` 로 그 Pod 가 `notReadyAddresses` 에 있는지 본다", "`kubectl describe pod` 의 이벤트에서 `readinessProbe` 가 실패하는 이유를 찾는다", "고친 뒤 `READY` 가 `1/1` 이 되고 엔드포인트 주소 수가 늘었는지 확인한다"]', NULL, 'EndpointSlice 의 `conditions.ready` 에서도 같은 정보를 볼 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 186, 29, '셀렉터 없는 Service 에 외부 주소 연결하기', '셀렉터가 없는 Service 에 직접 만든 주소를 연결하고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', 'Service 만들기 → 비어 있음 확인 → 슬라이스 → 접속 확인 순서예요.', NULL, NULL, '[]', 'order', '["`selector` 가 없는 Service `manual` 을 만든다", "`kubectl describe svc manual` 에서 `Selector: <none>`, `Endpoints: <none>` 인지 확인한다", "`kubernetes.io/service-name: manual` 라벨과 주소를 가진 `EndpointSlice` 를 만든다", "다른 Pod 에서 `wget http://manual` 로 응답이 오는지 확인한다"]', NULL, '`Endpoints` 오브젝트를 직접 만들면 deprecated 경고가 나오므로 `EndpointSlice` 를 권장합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 186 AND order_index = 29);
