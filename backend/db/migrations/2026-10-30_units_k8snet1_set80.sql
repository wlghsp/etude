-- Git 세트 80. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set80.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 8, 'k8s', '스토리지와 네트워크', 30 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 8);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 80, 'k8s 네트워크와 외부 노출: CNI, Service, NodePort, NFS', 'Pod 가 서로, 그리고 밖과 어떻게 통신하는지 구조를 잡습니다. CNI 와 같은 노드·다른 노드 통신, Flannel 과 Calico 의 차이, NetworkPolicy, Service 가 iptables 로 L4 로드밸런싱하는 방식과 IPVS, ClusterIP·NodePort·LoadBalancer, port 와 targetPort, NFS 볼륨이 필요한 이유를 문제로 정리합니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 80);
UPDATE quest_set SET display_order = 208, unit_id = (SELECT id FROM unit WHERE id = 8), icon = '🔌' WHERE id = 80;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 1, 'CNI 가 하는 일', '쿠버네티스는 Pod 네트워크를 **직접 구성하지 않고** 어떤 표준 인터페이스에 위임합니다. Pod 에 IP 를 할당하고 라우팅·가상 인터페이스를 연결하는 플러그인 규격은 무엇일까요?', '컨테이너 네트워크의 표준 인터페이스입니다.', NULL, NULL, '[]', 'choice', '["CRI (Container Runtime Interface)", "CSI (Container Storage Interface)", "OCI (Open Container Initiative)", "CNI (Container Network Interface) — Flannel, Calico 같은 플러그인이 구현한다"]', 3, 'kubelet 이 Pod 를 만들 때 CNI 플러그인을 호출해 IP 할당, 라우팅, veth 연결을 시킵니다. CRI 는 런타임, CSI 는 스토리지, OCI 는 이미지·런타임 표준입니다. "모든 Pod 는 고유 IP 를 가진다"는 원칙을 CNI 가 구현합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 2, '같은 노드 안의 Pod 통신', '같은 노드에 있는 Pod A 와 Pod B 가 통신할 때 패킷이 지나는 경로로 알맞은 것은 무엇일까요?', '노드 밖으로 나가지 않습니다.', NULL, NULL, '[]', 'choice', '["항상 노드 밖의 라우터를 거쳐 되돌아온다", "각 Pod 의 가상 인터페이스(veth)에서 노드의 가상 브리지(cni0 같은)로 올라가 **MAC 주소로 바로 전달**된다", "kube-apiserver 를 거쳐 전달된다", "etcd 를 거쳐 전달된다"]', 1, '같은 노드는 L2 브리지로 처리됩니다. 노드 밖으로 나가지 않아 빠릅니다. 다른 노드의 Pod 와 통신할 때는 L3 라우팅이나 오버레이가 필요합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 3, 'Flannel 의 방식', '**Flannel(VXLAN)** 이 다른 노드의 Pod 로 패킷을 보내는 방식으로 알맞은 것은 무엇일까요?', '물리 네트워크 위에 가상 네트워크를 올립니다.', NULL, NULL, '[]', 'choice', '["원본 패킷을 UDP 로 **캡슐화**해 노드 간에 보내고 받는 쪽에서 풀어서 전달한다 (설정은 단순하지만 캡슐화 비용이 있다)", "BGP 로 라우팅 정보를 교환해 원본 패킷을 그대로 보낸다", "패킷을 etcd 에 저장했다가 전달한다", "Pod IP 를 외부 IP 로 직접 노출한다"]', 0, 'Flannel 은 물리 네트워크 설정을 건드리지 않아도 되어 온프레미스·소규모에 간단합니다. 대신 캡슐화/해제 오버헤드로 성능이 약간 떨어집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 4, 'Calico 의 방식', '**Calico** 가 다른 노드의 Pod 로 패킷을 보내는 대표 방식으로 알맞은 것은 무엇일까요?', '캡슐화 없이 라우팅 정보를 교환합니다.', NULL, NULL, '[]', 'choice', '["UDP 로 모든 패킷을 감싸서 보낸다", "Service IP 로만 통신하게 한다", "노드 간에 **BGP** 로 라우팅 정보를 교환해 캡슐화 없이 원본 패킷을 그대로 전달한다 (성능이 좋지만 네트워크 장비 지원·설정이 필요하다)", "Ingress 를 통해서만 통신하게 한다"]', 2, 'Calico 는 NetworkPolicy 를 세밀하게 제어하는 데도 강하고 대규모 클러스터에 많이 씁니다. 캡슐화가 필요한 환경에서는 IP-in-IP/VXLAN 모드도 지원합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 5, 'NetworkPolicy 를 지원하는 CNI', '"Pod 간 트래픽을 허용/차단하는 **NetworkPolicy**" 를 구현하는 것은 누구의 일일까요?', 'NetworkPolicy 는 리소스일 뿐, 실제로 적용하는 쪽이 필요합니다.', NULL, NULL, '[]', 'choice', '["kube-apiserver 가 직접 패킷을 차단한다", "etcd 가 차단한다", "kubectl 이 차단한다", "CNI 플러그인이 구현한다. 일부 플러그인(Flannel 단독)은 지원하지 않아 Calico 같은 정책 엔진을 붙이기도 한다"]', 3, 'NetworkPolicy 오브젝트를 만들어도 이를 지원하는 CNI 가 없으면 아무 효과가 없습니다. 지원하는 CNI(Calico 등)는 iptables 나 eBPF 규칙으로 구현합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 6, 'Service 가 iptables 로 하는 일', 'Service 의 ClusterIP 로 보낸 요청이 실제 Pod 로 가는 것은 iptables 의 어떤 기능 덕분일까요?', '목적지 주소를 바꿔치기합니다.', NULL, NULL, '[]', 'choice', '["SNAT 로 응답만 바꾼다", "**DNAT**(목적지 NAT): 목적지 IP/포트를 Service IP 에서 실제 Pod IP 로 변환한다. kube-proxy 가 Pod 변화에 따라 규칙을 갱신한다", "패킷을 모두 차단한다", "패킷을 etcd 로 보낸다"]', 1, '클라이언트는 `Service IP:port` 로 보내지만 커널 규칙이 Pod IP 중 하나로 바꿔 전달합니다. Pod 가 교체되어도 Service IP 는 그대로이므로 클라이언트는 신경 쓰지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 7, 'iptables 방식의 한계와 IPVS', 'Pod 와 Service 가 **아주 많아지면** iptables 모드의 문제와 해결책으로 알맞은 것은 무엇일까요?', '규칙을 순서대로 훑는 구조입니다.', NULL, NULL, '[]', 'choice', '["규칙 수가 수만 개로 늘면 선형 탐색이라 느려진다. kube-proxy 를 **IPVS 모드**(해시 테이블)로 바꾸면 규칙 수에 덜 민감하다", "규칙이 많을수록 빨라진다", "해결책은 Pod 를 줄이는 것뿐이다", "IPVS 는 UDP 만 지원한다"]', 0, 'IPVS 는 해시 기반이라 대규모에서 유리하고 분산 알고리즘도 고를 수 있습니다. 규모가 작으면 기본 iptables 모드로도 충분합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 8, 'Service 타입 구분하기 (1)', '**클러스터 내부에서만** 접근 가능한 가상 IP 를 주는 기본 Service 타입은 무엇일까요?', '타입을 생략하면 이것이 됩니다.', NULL, NULL, '[]', 'choice', '["NodePort", "LoadBalancer", "ClusterIP", "ExternalName"]', 2, 'ClusterIP 는 마이크로서비스끼리의 내부 통신에 씁니다. 외부 클라이언트는 직접 접근할 수 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 9, 'Service 타입 구분하기 (2)', '**모든 노드의 특정 포트**(예: 30000~32767)를 열어 외부에서 `노드IP:포트` 로 접근하게 하는 Service 타입은 무엇일까요?', '외부 접근의 가장 기본 방법입니다.', NULL, NULL, '[]', 'choice', '["ClusterIP", "NodePort (그 포트로 들어오면 다시 ClusterIP 로 DNAT 되어 Pod 로 간다)", "ExternalName", "Headless"]', 1, '경로는 외부 → 노드IP:NodePort → ClusterIP → Pod 입니다. 앞에 로드밸런서나 HAProxy 를 두고 노드들의 NodePort 로 넘기는 구성이 흔합니다. LoadBalancer 는 클라우드 LB 를 자동으로 붙여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 10, 'port 와 targetPort', 'Service 정의에서 `port: 80`, `targetPort: 8080` 이라고 하면 무슨 뜻일까요?', '하나는 Service 가 받는 포트, 하나는 Pod 가 받는 포트입니다.', NULL, NULL, '[]', 'choice', '["Pod 는 80, Service 는 8080 이다", "둘 다 외부에 열리는 노드 포트이다", "같은 포트를 두 번 쓴 오류이다", "Service 는 80 포트로 요청을 받고, 뒤의 Pod 는 **8080** 포트로 전달한다"]', 3, '`port` 는 Service 의 포트, `targetPort` 는 Pod 컨테이너의 포트, NodePort 타입이면 `nodePort` 가 노드의 포트입니다. 연결이 안 될 때 이 세 값이 어긋난 경우가 매우 흔합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 11, '외부 요청이 Pod 에 도달하는 경로 놓기', '외부 클라이언트가 **NodePort Service** 를 통해 Pod 에 도달하는 경로를 **앞에서 뒤**로 놓으세요.', '외부 → 노드 → ClusterIP → Pod 입니다.', NULL, NULL, '[]', 'order', '["Service 의 ClusterIP 로 변환(DNAT)된다", "외부 클라이언트가 `노드IP:NodePort` 로 요청한다", "목적지가 실제 Pod IP 로 변환(DNAT)되어 Pod 에 도착한다", "노드의 iptables 규칙이 요청을 받는다"]', NULL, '**외부 → 노드IP:NodePort → 노드 iptables → ClusterIP 로 DNAT → Pod IP 로 DNAT → Pod** 입니다. NodePort 는 ClusterIP 위에 얹힌 한 겹이고, LoadBalancer 는 그 앞에 클라우드 LB 가 한 겹 더 붙은 것입니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 80, 12, 'NFS 볼륨이 필요한 이유', 'Pod 가 재시작되어 **다른 노드에 뜨면** 이전 노드 로컬 디스크의 데이터를 쓸 수 없습니다. 이 문제를 풀려고 NFS 같은 **네트워크 스토리지**를 PV 로 쓰는 이유는 무엇일까요?', '어느 노드에서 떠도 같은 데이터에 접근해야 합니다.', NULL, NULL, '[]', 'choice', '["NFS 는 Pod 가 죽어도 컨테이너 레이어를 보존해서이다", "NFS 는 Pod 를 항상 같은 노드에 고정해서이다", "노드와 무관하게 네트워크로 같은 디렉터리를 마운트해, Pod 가 어느 노드에 다시 뜨든 같은 데이터를 쓸 수 있고 여러 Pod 가 동시에 읽고 쓸 수도 있다 (ReadWriteMany)", "NFS 는 인터넷 속도를 빠르게 해서이다"]', 2, 'PV 의 `server`, `path` 값은 수동으로 `mount -t nfs 서버:경로 /mnt` 할 때 쓰는 값과 같습니다. 노드가 대신 mount 를 실행하는 구조입니다. 동적으로 PV 를 만들려면 NFS 용 StorageClass(프로비저너)가 필요하고, 읽기·쓰기 속도는 네트워크에 의존합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 80 AND order_index = 12);
