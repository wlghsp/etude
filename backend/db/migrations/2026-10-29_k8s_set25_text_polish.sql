-- 세트 25 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='NodePort Service 만들기', description='Service 에는 유형이 있습니다. 기본 `ClusterIP` 는 클러스터 **안**에서만 접근되고, `NodePort` 는 각 노드의 포트로 **밖**에서도 접근됩니다.

`$NS` 의 Deployment `web` 을 80 포트로 노출하되 유형을 `NodePort` 로 하는 Service `web-np` 를 만드세요.', hint='`kubectl expose deployment <이름> --port=<포트> --type=NodePort --name=<서비스이름> -n <ns>` 입니다. `--type` 을 생략하면 ClusterIP 입니다.', solution='kubectl expose deployment web --port=80 --type=NodePort --name=web-np -n $NS

# 확인 (PORT(S) 에 80:3xxxx 형태로 노드 포트가 보입니다)
kubectl get svc web-np -n $NS' WHERE quest_set_id = 25 AND order_index = 1;
UPDATE quest SET title='Service 의 ClusterIP 확인하기', description='Service 는 생성될 때 클러스터 안에서 쓰는 고정 IP(**ClusterIP**)를 받습니다.

`$NS` 의 Service `web-svc` 의 ClusterIP 주소를 `/tmp/cluster_ip.txt` 에 저장하세요.', hint='`kubectl get svc web-svc -n <ns>` 의 `CLUSTER-IP` 열에 나옵니다. 값만 뽑으려면 `-o jsonpath=''{.spec.clusterIP}''` 를 쓰세요.', solution='kubectl get svc web-svc -n $NS -o jsonpath=''{.spec.clusterIP}'' > /tmp/cluster_ip.txt' WHERE quest_set_id = 25 AND order_index = 2;
UPDATE quest SET title='Service 가 연결한 Pod IP 확인하기', description='Service 는 라벨이 맞는 Pod 들을 **엔드포인트**로 삼아 트래픽을 보냅니다. 엔드포인트를 보면 실제로 어느 Pod 로 가는지 알 수 있습니다.

`$NS` 의 Service `web-svc` 의 엔드포인트(실제로 트래픽이 가는 Pod IP)를 `/tmp/ep.txt` 에 저장하세요. (IP 만, 포트는 제외)', hint='`kubectl get endpoints web-svc -n <ns>` 의 `ENDPOINTS` 열은 `IP:포트` 입니다. IP 만 뽑으려면 `-o jsonpath=''{.subsets[0].addresses[0].ip}''` 를 쓰세요.', solution='kubectl get endpoints web-svc -n $NS -o jsonpath=''{.subsets[0].addresses[0].ip}'' > /tmp/ep.txt' WHERE quest_set_id = 25 AND order_index = 3;
UPDATE quest SET title='Service 이름으로 다른 Pod 에서 접근하기', description='클러스터 안의 DNS 는 Service 이름을 IP 로 바꿔 줍니다. 그래서 Pod 끼리는 IP 대신 **Service 이름**으로 접근합니다.

`$NS` 에 `web-svc` Service(뒤에 nginx)와 `client` Pod(busybox)가 있습니다. `client` Pod **안에서** `web-svc` 로 HTTP 요청을 보내, 받은 응답 본문을 `/tmp/svc_resp.txt` 에 저장하세요.', hint='같은 네임스페이스에서는 Service 이름만으로 접근됩니다. Pod 안에서 명령을 실행하는 `kubectl exec <Pod> -n <ns> -- <명령>` 과, busybox 에 들어 있는 `wget -qO- http://<서비스이름>` 을 조합하세요.', solution='kubectl exec client -n $NS -- wget -qO- http://web-svc > /tmp/svc_resp.txt

# wget -qO- : 조용히(-q) 받아서 화면(표준 출력, -O-)으로 출력' WHERE quest_set_id = 25 AND order_index = 4;
UPDATE quest SET title='Service 의 전체 도메인 이름(FQDN) 알아내기', description='다른 네임스페이스의 Pod 에서 Service 에 접근하려면 이름에 네임스페이스까지 붙인 **전체 도메인 이름**을 씁니다.

`$NS` 네임스페이스의 Service `web-svc` 의 전체 도메인 이름(FQDN)을 `/tmp/fqdn.txt` 에 저장하세요.', hint='Service 의 DNS 이름 형식은 `<서비스>.<네임스페이스>.svc.cluster.local` 입니다. `<네임스페이스>` 자리에는 이 문제의 네임스페이스 이름(`$NS`)이 들어갑니다.', solution='echo web-svc.$NS.svc.cluster.local > /tmp/fqdn.txt

# 형식: <서비스>.<네임스페이스>.svc.cluster.local' WHERE quest_set_id = 25 AND order_index = 5;
UPDATE quest SET title='Ingress 규칙 만들기', description='**Ingress** 는 외부 HTTP 요청을 호스트 이름과 경로에 따라 여러 Service 로 나눠 보내는 규칙입니다. (실제로 동작하려면 클러스터에 Ingress 컨트롤러가 필요합니다. 여기서는 규칙을 만드는 연습을 합니다.)

`$NS` 에 호스트 `web.example.com` 으로 들어오는 **모든 경로**를 Service `web-svc` 의 `80` 포트로 보내는 Ingress `web-ing` 을 만드세요.', hint='`kubectl create ingress <이름> -n <ns> --rule="<호스트>/<경로>=<서비스>:<포트>"` 형식입니다. 경로 끝에 `*` 를 붙이면 그 아래 모든 경로(Prefix)입니다.', solution='kubectl create ingress web-ing -n $NS --rule=''web.example.com/*=web-svc:80''

# 호스트/경로=서비스:포트' WHERE quest_set_id = 25 AND order_index = 6;
UPDATE quest SET title='NetworkPolicy: 들어오는 트래픽 전부 막기', description='**NetworkPolicy** 는 Pod 사이의 통신을 허용/차단하는 방화벽 규칙입니다. 보안의 기본은 ''일단 전부 막고 필요한 것만 연다''입니다. (정책이 실제로 적용되려면 클러스터 네트워크 플러그인이 지원해야 합니다. 여기서는 정책을 만드는 연습을 합니다.)

`$NS` 의 **모든 Pod** 로 들어오는 트래픽(Ingress)을 막는 NetworkPolicy `deny-all` 을 만드세요. 허용 규칙은 하나도 없어야 합니다.', hint='`spec.podSelector: {}` 는 네임스페이스의 모든 Pod 를 뜻합니다. `policyTypes` 에 `Ingress` 를 쓰고 `ingress` 규칙은 **쓰지 않으면** 들어오는 트래픽이 모두 차단됩니다. NetworkPolicy 는 `kubectl create` 로 만들 수 없어 YAML 이 필요합니다.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}        # 모든 Pod 가 대상
  policyTypes:
  - Ingress              # 들어오는 트래픽 (허용 규칙 없음 = 전부 차단)
EOF' WHERE quest_set_id = 25 AND order_index = 7;
UPDATE quest SET title='NetworkPolicy: 특정 Pod 에서 오는 트래픽만 허용하기', description='전부 막은 뒤에는 필요한 통신만 허용합니다. 예를 들어 백엔드는 프론트엔드에서 오는 요청만 받게 합니다.

`$NS` 에 NetworkPolicy `allow-front` 를 만드세요.
- 대상: 라벨 `app=backend` 인 Pod
- 허용: 라벨 `app=frontend` 인 Pod 에서 **TCP 80** 포트로 오는 트래픽만', hint='`spec.podSelector.matchLabels` 로 **대상**(backend)을, `spec.ingress[].from[].podSelector.matchLabels` 로 **허용할 출처**(frontend)를, `spec.ingress[].ports[]` 로 포트를 씁니다. `policyTypes` 에는 `Ingress` 를 넣으세요.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-front
spec:
  podSelector:
    matchLabels:
      app: backend         # 보호할 대상
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend    # 허용할 출처
    ports:
    - protocol: TCP
      port: 80
EOF' WHERE quest_set_id = 25 AND order_index = 8;
UPDATE quest SET title='Headless Service 만들기', description='**Headless Service** 는 ClusterIP 없이 DNS 조회 시 Pod IP 들을 직접 돌려줍니다. StatefulSet 처럼 Pod 하나하나를 이름으로 찾아야 할 때(DB 클러스터 등) 씁니다.

`$NS` 에 Headless Service `db-headless` 를 만드세요. 포트는 `3306`, 셀렉터는 `app=db` 입니다.', hint='Service YAML 의 `spec.clusterIP` 를 `None` 으로 지정하면 Headless 입니다. `spec.selector` 에 `app: db`, `spec.ports` 에 `port: 3306` 을 쓰세요.', solution='kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: db-headless
spec:
  clusterIP: None      # Headless
  selector:
    app: db
  ports:
  - port: 3306
EOF' WHERE quest_set_id = 25 AND order_index = 9;
UPDATE quest SET title='Service 의 셀렉터 바꾸기', description='Service 가 어느 Pod 를 가리킬지는 **셀렉터(라벨 조건)** 가 정합니다. 셀렉터를 바꾸면 다른 Deployment 로 트래픽을 옮길 수 있습니다.

`$NS` 의 Service `web-svc` 가 라벨 `app=api` 인 Pod 를 가리키도록 셀렉터를 바꾸세요.', hint='`kubectl set selector service/<이름> <키>=<값> -n <ns>` 한 줄로 됩니다. `kubectl patch` 로도 가능하지만 이 명령이 더 짧습니다.', solution='kubectl set selector service/web-svc app=api -n $NS

# 확인
kubectl describe svc web-svc -n $NS' WHERE quest_set_id = 25 AND order_index = 10;
