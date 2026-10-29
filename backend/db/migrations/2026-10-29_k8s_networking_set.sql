-- 세트 25(k8s 서비스와 네트워킹) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set25.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 25, 'k8s 서비스와 네트워킹', 'Service 유형, 엔드포인트, 클러스터 DNS, Ingress, NetworkPolicy, Headless Service 등 k8s 네트워킹의 기본 구성을 실습합니다.', 'k8s', 'k8s' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  1, 'NodePort Service 만들기',
   '$NS 의 Deployment web 을 80 포트로 노출하되 유형을 NodePort 로 하는 Service web-np 를 만드세요.',
   'kubectl expose deployment 이름 --port=80 --type=NodePort --name=서비스이름 입니다. ClusterIP(기본)는 클러스터 안에서만, NodePort 는 각 노드의 포트로도 접근됩니다.',
   'kubectl expose deployment web --port=80 --type=NodePort --name=web-np -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get svc web-np -n $NS -o jsonpath=''{.spec.type}'')\\\" = NodePort ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  2, 'Service 의 ClusterIP 확인하기',
   '$NS 의 Service web-svc 의 ClusterIP 주소를 /tmp/cluster_ip.txt 에 저장하세요.',
   'kubectl get svc web-svc 의 CLUSTER-IP 열이나 -o jsonpath=''{.spec.clusterIP}'' 를 사용합니다.',
   'kubectl get svc web-svc -n $NS -o jsonpath=''{.spec.clusterIP}'' > /tmp/cluster_ip.txt',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS 2>/dev/null; kubectl expose deployment web --port=80 --name=web-svc -n $NS 2>/dev/null; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ -s /tmp/cluster_ip.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/cluster_ip.txt)\\\" = \\\"$(kubectl get svc web-svc -n $NS -o jsonpath=''{.spec.clusterIP}'')\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  3, 'Service 가 연결한 Pod IP 확인하기',
   'Service web-svc 의 엔드포인트(실제로 트래픽이 가는 Pod IP)를 /tmp/ep.txt 에 저장하세요.',
   'kubectl get endpoints web-svc 의 ENDPOINTS 는 IP:포트 입니다. IP 만 jsonpath 로 뽑아 보세요: {.subsets[0].addresses[0].ip}',
   'kubectl get endpoints web-svc -n $NS -o jsonpath=''{.subsets[0].addresses[0].ip}'' > /tmp/ep.txt',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS 2>/dev/null; kubectl expose deployment web --port=80 --name=web-svc -n $NS 2>/dev/null; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ -s /tmp/ep.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/ep.txt)\\\" = \\\"$(kubectl get pod -n $NS -l app=web -o jsonpath=''{.items[0].status.podIP}'')\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  4, 'Service 이름으로 다른 Pod 에서 접근하기',
   'Pod client 안에서 Service 이름 web-svc 로 HTTP 요청을 보내 응답 본문을 /tmp/svc_resp.txt 에 저장하세요. (클러스터 DNS 가 이름을 IP 로 바꿔 줍니다.)',
   '같은 네임스페이스에서는 Service 이름만으로 접근됩니다. kubectl exec client -- wget -qO- http://web-svc 처럼 Pod 안에서 요청합니다.',
   'kubectl exec client -n $NS -- wget -qO- http://web-svc > /tmp/svc_resp.txt',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS 2>/dev/null; kubectl expose deployment web --port=80 --name=web-svc -n $NS 2>/dev/null; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s 2>/dev/null; true; kubectl run client --image=busybox -n $NS -- sleep 3600 2>/dev/null; kubectl wait --for=condition=Ready pod/client -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''Welcome to nginx'' /tmp/svc_resp.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  5, 'Service 전체 도메인 이름 알아내기',
   '다른 네임스페이스의 Pod 에서 $NS 의 Service web-svc 에 접근할 때 쓰는 전체 도메인 이름(FQDN, 서비스.네임스페이스.svc.cluster.local 형식)을 /tmp/fqdn.txt 에 저장하세요.',
   'Service 의 DNS 이름은 <서비스>.<네임스페이스>.svc.cluster.local 입니다. 같은 네임스페이스면 서비스 이름만, 다른 네임스페이스면 서비스.네임스페이스 이상이 필요합니다.',
   'echo web-svc.$NS.svc.cluster.local > /tmp/fqdn.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/fqdn.txt)\\\" = web-svc.$NS.svc.cluster.local ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  6, 'Ingress 규칙 만들기',
   '호스트 web.example.com 으로 들어오는 모든 경로를 Service web-svc 의 80 포트로 보내는 Ingress web-ing 을 만드세요.',
   'kubectl create ingress 이름 --rule="호스트/경로=서비스:포트" 형식입니다. 경로 끝에 *를 붙이면 Prefix 경로입니다. Ingress 가 동작하려면 클러스터에 Ingress 컨트롤러가 있어야 합니다.',
   'kubectl create ingress web-ing -n $NS --rule=''web.example.com/*=web-svc:80''',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS 2>/dev/null; kubectl expose deployment web --port=80 --name=web-svc -n $NS 2>/dev/null; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].host}'')\\\" = web.example.com ] && [ \\\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].backend.service.name}'')\\\" = web-svc ] && [ \\\"$(kubectl get ingress web-ing -n $NS -o jsonpath=''{.spec.rules[0].http.paths[0].backend.service.port.number}'')\\\" = 80 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  7, 'NetworkPolicy: 들어오는 트래픽 전부 막기',
   '$NS 의 모든 Pod 로 들어오는 트래픽(Ingress)을 막는 NetworkPolicy deny-all 을 만드세요. (허용 규칙이 없어야 합니다.)',
   'spec.podSelector: {} 는 네임스페이스의 모든 Pod 를 뜻합니다. policyTypes 에 Ingress 를 쓰고 ingress 규칙을 쓰지 않으면 모두 차단입니다. NetworkPolicy 는 CNI 가 지원해야 실제로 적용됩니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get networkpolicy deny-all -n $NS -o jsonpath=''{.spec.policyTypes[0]}'')\\\" = Ingress ] && [ -z \\\"$(kubectl get networkpolicy deny-all -n $NS -o jsonpath=''{.spec.ingress}'')\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  8, 'NetworkPolicy: 특정 Pod 에서 오는 트래픽만 허용하기',
   '라벨 app=backend 인 Pod 로 들어오는 트래픽 중, 라벨 app=frontend 인 Pod 에서 80 포트로 오는 것만 허용하는 NetworkPolicy allow-front 를 만드세요.',
   'spec.podSelector 로 대상(backend)을, ingress[].from[].podSelector 로 허용 출처(frontend)를, ingress[].ports 로 포트를 씁니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-front
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get networkpolicy allow-front -n $NS -o jsonpath=''{.spec.podSelector.matchLabels.app}'')\\\" = backend ] && [ \\\"$(kubectl get networkpolicy allow-front -n $NS -o jsonpath=''{.spec.ingress[0].from[0].podSelector.matchLabels.app}'')\\\" = frontend ] && [ \\\"$(kubectl get networkpolicy allow-front -n $NS -o jsonpath=''{.spec.ingress[0].ports[0].port}'')\\\" = 80 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25,  9, 'Headless Service 만들기',
   'ClusterIP 없이 Pod IP 를 직접 돌려주는 Headless Service db-headless 를 만드세요. 포트는 3306, 셀렉터는 app=db 입니다.',
   'Service YAML 에서 spec.clusterIP: None 으로 지정합니다. StatefulSet 처럼 각 Pod 를 이름으로 찾을 때 씁니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: db-headless
spec:
  clusterIP: None
  selector:
    app: db
  ports:
  - port: 3306
EOF',
   NULL,
   '["sh", "-c", "[ \\\"$(kubectl get svc db-headless -n $NS -o jsonpath=''{.spec.clusterIP}'')\\\" = None ] && [ \\\"$(kubectl get svc db-headless -n $NS -o jsonpath=''{.spec.selector.app}'')\\\" = db ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 25, 10, 'Service 의 셀렉터 바꾸기',
   'Service web-svc 가 라벨 app=api 인 Pod 를 가리키도록 셀렉터를 바꾸세요.',
   'kubectl set selector service/이름 키=값 입니다. kubectl patch 로도 가능하지만 한 줄 명령이 빠릅니다.',
   'kubectl set selector service/web-svc app=api -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS 2>/dev/null; kubectl expose deployment web --port=80 --name=web-svc -n $NS 2>/dev/null; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get svc web-svc -n $NS -o jsonpath=''{.spec.selector.app}'')\\\" = api ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 25 AND order_index = 10);
