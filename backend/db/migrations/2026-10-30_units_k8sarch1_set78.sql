-- Git 세트 78. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set78.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 6, 'k8s', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 6);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 78, 'k8s 구조 이해하기: 컨트롤 플레인, 노드, 선언형 모델', 'kubectl 로 명령을 내리기 전에 쿠버네티스가 안에서 어떻게 움직이는지 큰 그림을 잡습니다. 컨트롤 플레인(API Server, etcd, Scheduler, Controller), 노드의 kubelet·컨테이너 런타임·kube-proxy, 선언형 모델과 reconcile, CRD 와 Operator 를 문제로 정리합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 78);
UPDATE quest_set SET display_order = 206, unit_id = (SELECT id FROM unit WHERE id = 6), icon = '🏛️' WHERE id = 78;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 1, 'API Server 의 역할 알기', '쿠버네티스 클러스터에서 `kubectl` 명령도, 내부 컴포넌트의 상태 조회·변경도 모두 **한 곳**을 거칩니다. 그곳은 어디일까요?', '클러스터의 단일 진입점입니다.', NULL, NULL, '[]', 'choice', '["etcd 에 직접 접속한다", "kubelet 이 모든 요청을 받는다", "kube-apiserver (REST API 를 제공하는 단일 진입점이며 자체는 상태를 저장하지 않는다)", "Scheduler 가 모든 요청을 받는다"]', 2, '개발자·운영자도, Scheduler·Controller·kubelet 같은 내부 컴포넌트도 API Server 를 통해서만 상태를 읽고 씁니다. API Server 는 stateless 이고 상태는 etcd 에 있습니다. 그래서 API Server 가 죽으면 새 명령을 내릴 수 없지만 이미 떠 있는 Pod 는 계속 돕니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 2, 'etcd 에 접근하는 주체', '클러스터의 모든 상태를 저장하는 분산 key-value 저장소 **etcd** 에 직접 접근하는 컴포넌트는 무엇일까요?', '다른 컴포넌트들은 이곳을 통해서만 상태를 읽고 씁니다.', NULL, NULL, '[]', 'choice', '["kube-apiserver 만 etcd 에 직접 접근하고, 나머지는 API Server 를 통한다", "모든 컴포넌트가 etcd 에 직접 접근한다", "kubelet 만 etcd 에 접근한다", "kube-proxy 가 etcd 를 관리한다"]', 0, 'etcd 는 "/etc + distributed" 로, 분산된 설정(상태) 저장소라는 이름입니다. 클러스터 상태의 유일한 원본이라 etcd 백업이 곧 클러스터 백업이고, 접근을 API Server 하나로 모아 일관성과 보안을 지킵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 3, 'Scheduler 와 Controller 구분하기', '**"새로 만든 Pod 를 어느 노드에서 실행할지"** 를 결정하는 컴포넌트는 무엇일까요?', '자원 여유와 요구사항을 고려해 노드를 고릅니다.', NULL, NULL, '[]', 'choice', '["Controller Manager", "kubelet", "etcd", "Scheduler"]', 3, 'Scheduler 는 노드의 가용 자원과 Pod 의 요구사항(requests, nodeSelector, taint 등)을 보고 배치할 노드를 정합니다. Controller 들은 "원하는 상태와 현재 상태"를 비교해 맞추는 일을 하며, 예를 들어 Deployment Controller 는 복제본 수를 유지합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 4, 'kubelet 이 하는 일', '각 노드에서 **그 노드에 배정된 Pod 의 명세를 확인하고, 정상 동작을 감시하며 상태를 컨트롤 플레인에 보고**하는 구성요소는 무엇일까요?', '노드의 "현장 소장"에 비유됩니다.', NULL, NULL, '[]', 'choice', '["kube-scheduler", "kubelet", "etcd", "Ingress controller"]', 1, 'kubelet 은 노드마다 하나씩 도는 에이전트(Kubernetes 의 "작은 버전")입니다. 실제 컨테이너 생성은 컨테이너 런타임(containerd 등)에게 CRI 로 지시합니다. kubelet 과 런타임이 없는 노드는 지시를 받을 수도, 컨테이너를 띄울 수도 없는 빈 컴퓨터입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 5, 'kubelet 과 컨테이너 런타임의 관계', 'kubelet 이 컨테이너를 시작·중지할 때 **직접 실행하지 않고** 지시를 내리는 대상과 그 통신 규약으로 알맞은 것은 무엇일까요?', '런타임을 갈아 끼울 수 있게 표준 인터페이스를 둡니다.', NULL, NULL, '[]', 'choice', '["Docker 데몬에게 REST 로만 지시한다", "etcd 에게 컨테이너를 만들게 한다", "containerd 같은 컨테이너 런타임에게 CRI(Container Runtime Interface)로 지시한다", "Scheduler 에게 대신 실행시킨다"]', 2, 'CRI 덕분에 쿠버네티스는 CRI 를 구현한 어떤 런타임(containerd, CRI-O)이든 쓸 수 있습니다. 컨테이너를 실제로 만드는 저수준 실행은 OCI 호환 런타임(runc 등)이 맡습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 6, 'Docker 가 빠진 이유', '쿠버네티스가 Docker 지원(Dockershim)을 제거한 이유로 알맞은 것은 무엇일까요?', 'Docker 는 CRI 를 구현하지 않았습니다.', NULL, NULL, '[]', 'choice', '["Docker 는 CRI 를 구현하지 않아 중간 변환 계층(Dockershim)을 쿠버네티스 팀이 직접 유지해야 했고, 그 부담을 없애기 위해서이다 (Docker 로 만든 이미지는 그대로 쓸 수 있다)", "Docker 이미지를 쓸 수 없게 되었기 때문이다", "Docker 가 유료화되었기 때문이다", "컨테이너를 지원하지 않기 때문이다"]', 0, '흐름이 Kubernetes → Dockershim → Docker daemon → containerd → runc 로 불필요하게 길었습니다. 지금은 Kubernetes → CRI → containerd → runc 로 줄었고, Docker 가 만든 OCI 이미지는 그대로 동작합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 7, 'kube-proxy 가 하는 일', 'Service 의 고정 IP 로 들어온 요청이 살아 있는 Pod 로 가도록 하는 **kube-proxy** 의 동작으로 알맞은 것은 무엇일까요?', '이름에 "proxy" 가 있지만 모든 패킷이 거치는 프로그램은 아닙니다.', NULL, NULL, '[]', 'choice', '["모든 패킷이 kube-proxy 프로세스를 통과해 전달된다", "apiserver 를 watch 하다가 Service·EndpointSlice 가 바뀌면 노드의 네트워크 규칙(iptables/IPVS)을 갱신한다. 실제 트래픽은 커널이 그 규칙으로 전달한다", "Pod 를 직접 생성한다", "컨테이너 이미지를 내려받는다"]', 1, 'kube-proxy 는 "교환원"처럼 연결 규칙을 만들어 둘 뿐 트래픽을 직접 나르지 않습니다. 그래서 kube-proxy 가 잠깐 멈춰도 이미 만들어진 규칙으로는 통신이 계속되지만, 새 Service·Pod 변경은 반영되지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 8, 'kube-proxy 기본 모드의 분산 방식', 'kube-proxy 의 **기본인 iptables 모드**에서 한 Service 뒤의 Pod 3개로 요청이 나뉘는 방식은 무엇일까요?', '순서대로 도는 방식이 아닙니다.', NULL, NULL, '[]', 'choice', '["항상 첫 번째 Pod 로만 보낸다", "가장 부하가 낮은 Pod 를 자동 선택한다", "Pod 이름순으로 번갈아 보낸다", "순서대로 도는 라운드로빈이 아니라 **확률 규칙으로 무작위** 선택한다 (분산 방식을 고르고 싶으면 IPVS 모드)"]', 3, 'iptables 규칙이 확률로 Pod 를 고릅니다. 연결 수 기반 같은 정교한 알고리즘이 필요하면 IPVS 모드나 서비스 메시·Ingress 의 로드밸런싱을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 9, '선언형 모델이란', '쿠버네티스가 **선언형(declarative)** 이라는 말의 의미로 알맞은 것은 무엇일까요?', '"어떻게 해라"가 아니라 "어떤 상태여야 한다"입니다.', NULL, NULL, '[]', 'choice', '["원하는 상태(desired state)를 manifest 로 선언해 제출하면, 컨트롤러가 현재 상태와 계속 비교해 맞춘다", "실행 절차를 한 단계씩 직접 명령한다", "한 번 실행하면 이후에는 감시하지 않는다", "YAML 을 쓸 수 없다"]', 0, '"복제본 3개가 떠 있어야 한다"고 선언하면 하나가 죽어도 컨트롤러가 다시 만들고, 노드가 장애 나면 다른 노드에 재배치합니다. 핵심은 원하는 상태와 현재 상태의 **지속적인 조정(reconciliation)** 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 10, 'kubectl apply 후 Pod 가 뜨기까지 순서 놓기', '`kubectl apply -f deployment.yaml` 로 Deployment 를 만들었을 때 Pod 가 실제로 실행되기까지의 흐름을 **앞에서 뒤**로 놓으세요.', '선언을 저장 → 컨트롤러가 Pod 를 만듦 → 노드 배정 → 노드가 실행 순서입니다.', NULL, NULL, '[]', 'order', '["kubelet 이 자기 노드에 배정된 Pod 를 감지해 컨테이너 런타임에게 컨테이너 시작을 지시한다", "Deployment Controller 가 원하는 개수만큼 Pod(ReplicaSet 경유)를 만든다", "kube-apiserver 가 요청을 받아 etcd 에 원하는 상태를 저장한다", "Scheduler 가 아직 노드가 없는 Pod 에 실행할 노드를 배정한다"]', NULL, '**API Server 저장(etcd) → Controller 가 Pod 생성 → Scheduler 가 노드 배정 → kubelet 이 감지해 런타임으로 실행** 순서입니다. 모든 단계가 API Server 를 통해 상태를 읽고 쓰며, 서로 직접 통신하지 않습니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 78, 11, 'CRD 와 Operator 의 관계', '쿠버네티스에 새 종류의 리소스를 **CRD** 로 등록했습니다. 그 CR(Custom Resource)을 만들면 어떤 일이 일어날까요?', 'CRD 는 저장 형식(설계도)일 뿐입니다.', NULL, NULL, '[]', 'choice', '["CRD 를 등록하면 자동으로 Pod 가 만들어진다", "CR 은 다른 리소스처럼 etcd 에 저장될 뿐이고, 실제 동작은 그 CR 을 지켜보다가 상태를 맞춰 주는 컨트롤러(Operator)가 있어야 일어난다", "CR 은 etcd 에 저장되지 않는다", "Operator 는 CRD 없이 동작하는 kubelet 의 별명이다"]', 1, 'CRD = "이런 종류가 있고 필드는 이렇다"는 설계도, CR = 그 설계도로 만든 객체, Operator = CR 을 watch 해서 일반 리소스(StatefulSet, ConfigMap 등)를 만들거나 고치는 컨트롤러입니다. 이 반복이 reconcile 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 78 AND order_index = 11);
