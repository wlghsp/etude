-- 세트 37(k8s 통신 방법 익히기) 추가와 표시 순서 지정(세트 25 바로 뒤). 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set37.sql, 05_display_order.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 37, 'k8s 통신 방법 익히기', 'Pod 끼리 IP 로 통신하기와 그 한계(IP 가 바뀜), 같은 Pod 안의 localhost 통신, 임시 Pod 로 Service 통신 테스트하기, 짧은 이름이 되는 이유(resolv.conf 의 search), Service 의 port 와 targetPort, 외부 접속 방법의 선택 기준을 직접 해 보며 익힙니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 37);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 37, 1, 'Pod IP 로 다른 Pod 에 직접 접속해 보기',
   '쿠버네티스에서 모든 Pod 는 **자기 IP** 를 가지고, 같은 클러스터의 다른 Pod 가 그 IP 로 바로 접속할 수 있습니다. `$NS` 에는 웹 서버 Deployment `web`(nginx)과 접속을 시험할 Pod `client`(busybox)가 있습니다.

1. `web` Pod 의 **IP** 를 알아냅니다.
2. `client` Pod 안에서 그 IP 로 웹 서버에 접속해 응답을 `/tmp/ip_resp.txt` 에 저장하세요.

완료 조건: 파일에 nginx 환영 페이지(`Welcome to nginx`)가 있어야 합니다.',
   '`kubectl get pods -o wide -n $NS` 의 `IP` 열에 Pod IP 가 나옵니다. (`-o wide` 는 열을 더 보여 주는 옵션) IP 만 뽑으려면 `kubectl get pod -l app=web -n $NS -o jsonpath=''{.items[0].status.podIP}''` 입니다. 그다음 `kubectl exec client -n $NS -- wget -qO- http://<IP>` 는 `client` Pod **안에서** `wget`(웹 요청 도구)을 실행합니다. (`--` 뒤가 Pod 안에서 실행할 명령, `-q` 조용히, `-O-` 응답을 화면(표준 출력)으로) 결과는 `>` 로 파일에 저장합니다.',
   '# 1) web Pod 의 IP 확인
IP=$(kubectl get pod -l app=web -n $NS -o jsonpath=''{.items[0].status.podIP}'')
echo $IP
# 2) client Pod 안에서 그 IP 로 접속해 응답 저장
kubectl exec client -n $NS -- wget -qO- http://$IP > /tmp/ip_resp.txt

# -o jsonpath : 필요한 값만 뽑기, wget -qO- : 응답을 화면(표준 출력)으로
head -n 4 /tmp/ip_resp.txt',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl run client --image=busybox -n $NS --command -- sleep 3600 >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/client -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "grep -q ''Welcome to nginx'' /tmp/ip_resp.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 37, 2, 'Pod 를 다시 만들면 IP 가 바뀌는 것 확인하기',
   'Pod 는 죽었다가 다시 만들어지면 **다른 IP** 를 받습니다. Deployment `web` 의 Pod 를 지우면 Deployment 가 새 Pod 를 만들어 줍니다. 이렇게 IP 가 바뀐다는 사실이 **Pod IP 로 직접 접속하면 안 되는 이유**이고, 그래서 Service 를 씁니다.

1. 지금 `web` Pod 의 IP 를 `/tmp/ip_before.txt` 에 저장합니다.
2. 그 Pod 를 삭제하고, Deployment 가 만든 새 Pod 가 `Running` 이 될 때까지 기다립니다.
3. 새 Pod 의 IP 를 `/tmp/ip_after.txt` 에 저장하세요.

완료 조건: 두 파일의 IP 가 서로 다르고, `ip_after.txt` 가 현재 `web` Pod 의 IP 와 같아야 합니다.',
   'IP 는 `kubectl get pod -l app=web -n $NS -o jsonpath=''{.items[0].status.podIP}''` 로 뽑습니다. (`-l app=web` 은 라벨이 `app=web` 인 Pod 만 고르는 옵션) Pod 삭제는 `kubectl delete pod -l app=web -n $NS`, 새 Pod 를 기다리는 것은 `kubectl rollout status deployment/web -n $NS` 입니다. 지운 Pod 가 아직 `Terminating` 으로 남아 있을 수 있으니 `kubectl get pods -n $NS` 로 `Running` 인 새 Pod 인지 확인하고 IP 를 뽑으세요.',
   '# 1) 지우기 전 IP
kubectl get pod -l app=web -n $NS -o jsonpath=''{.items[0].status.podIP}'' > /tmp/ip_before.txt
# 2) Pod 삭제 → Deployment 가 새 Pod 생성, 준비될 때까지 대기
kubectl delete pod -l app=web -n $NS
kubectl rollout status deployment/web -n $NS
sleep 3
# 3) 새 Pod(Running) 의 IP
P=$(kubectl get pods -n $NS -l app=web --no-headers | awk ''$3=="Running" {print $1}'' | head -n 1)
kubectl get pod $P -n $NS -o jsonpath=''{.status.podIP}'' > /tmp/ip_after.txt
cat /tmp/ip_before.txt; echo; cat /tmp/ip_after.txt',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "b=$(tr -d ''[:space:]'' < /tmp/ip_before.txt); a=$(tr -d ''[:space:]'' < /tmp/ip_after.txt); p=$(kubectl get pods -n $NS -l app=web --no-headers | awk ''$3==\\"Running\\" {print $1}'' | head -n 1); cur=$(kubectl get pod $p -n $NS -o jsonpath=''{.status.podIP}''); [ -n \\"$b\\" ] && [ -n \\"$a\\" ] && [ \\"$b\\" != \\"$a\\" ] && [ \\"$a\\" = \\"$cur\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 37, 3, 'Pod 안의 두 컨테이너가 localhost 로 통신하기',
   '같은 Pod 의 컨테이너들은 **네트워크를 함께 씁니다.** 그래서 서로 `localhost` 로 접속할 수 있습니다. 메인 앱 옆에서 도와주는 보조(사이드카) 컨테이너가 메인 앱에 접속하는 구조에서 씁니다. `$NS` 의 Pod `duo2` 에는 `web`(nginx)과 `helper`(busybox) 컨테이너가 함께 들어 있습니다.

`helper` 컨테이너 **안에서** `localhost` 로 `web` 컨테이너(nginx)에 접속해, 응답을 `/tmp/local_resp.txt` 에 저장하세요.

완료 조건: 파일에 `Welcome to nginx` 가 있어야 합니다.',
   '컨테이너가 둘 이상인 Pod 에서는 `kubectl exec Pod이름 -n $NS -c 컨테이너이름 -- 명령` 으로 어느 컨테이너에서 실행할지 정합니다. (`-c` 는 컨테이너 이름) `helper` 안에서 `wget -qO- http://localhost` 를 실행하세요. 컨테이너 이름은 `kubectl get pod duo2 -n $NS -o jsonpath=''{.spec.containers[*].name}''` 로 확인할 수 있습니다.',
   'kubectl exec duo2 -n $NS -c helper -- wget -qO- http://localhost > /tmp/local_resp.txt

# -c helper : helper 컨테이너 안에서 실행
# http://localhost : 같은 Pod 의 다른 컨테이너(nginx, 80 포트)
head -n 4 /tmp/local_resp.txt',
   '["sh", "-c", "printf ''%s\\\\n'' ''apiVersion: v1'' ''kind: Pod'' ''metadata:'' ''  name: duo2'' ''spec:'' ''  containers:'' ''  - name: web'' ''    image: nginx'' ''  - name: helper'' ''    image: busybox'' ''    command: [\\"sleep\\", \\"3600\\"]'' | kubectl apply -n $NS -f - >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/duo2 -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "grep -q ''Welcome to nginx'' /tmp/local_resp.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 37, 4, '임시 Pod 로 Service 통신 테스트하기',
   'Service 가 제대로 동작하는지 확인하려면 **클러스터 안의 Pod 에서** 접속해 봐야 합니다. 이때 일회용 Pod 를 띄워 명령 하나만 실행하고 바로 지우는 방법을 가장 많이 씁니다. `$NS` 에는 Deployment `web` 과 그 앞의 Service `web`(포트 80)이 있습니다.

임시 Pod 를 띄워 Service **이름** `web` 으로 접속하고, 응답을 `/tmp/svc_resp.txt` 에 저장하세요. (임시 Pod 는 끝나면 자동으로 지워집니다)

완료 조건: 파일에 `Welcome to nginx` 가 있어야 합니다.',
   '`kubectl run tmp --rm -i --restart=Never --image=busybox -n $NS -- wget -qO- http://web` 입니다. (`--image=busybox` 가벼운 도구 모음 이미지, `--rm` 끝나면 Pod 삭제, `-i` 출력을 받기 위해 입력 연결, `--restart=Never` 한 번 실행하고 끝나는 Pod 로 만듦, `--` 뒤는 Pod 안에서 실행할 명령) 접속 주소는 Pod IP 가 아니라 **Service 이름** `web` 입니다. 결과는 `>` 로 파일에 저장합니다.',
   'kubectl run tmp --rm -i --restart=Never --image=busybox -n $NS -- wget -qO- http://web > /tmp/svc_resp.txt

# --rm : 끝나면 Pod 삭제, --restart=Never : 한 번만 실행
# http://web : Service 이름으로 접속 (같은 네임스페이스라 짧은 이름이 된다)
head -n 4 /tmp/svc_resp.txt',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl expose deployment web --port=80 -n $NS >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "grep -q ''Welcome to nginx'' /tmp/svc_resp.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 37, 5, 'Pod 의 /etc/resolv.conf 읽고 짧은 이름이 되는 이유 알기',
   'Pod 안에서 `web` 같은 **짧은 이름**으로 Service 에 접속할 수 있는 이유는, Pod 의 `/etc/resolv.conf` 에 이름 뒤에 **자동으로 붙여 볼 주소(search 도메인)** 가 적혀 있기 때문입니다. 시스템은 `web` 을 이 목록으로 하나씩 이어 붙여 찾습니다. `$NS` 에는 Pod `client`(busybox)가 있습니다.

`client` Pod 안의 `/etc/resolv.conf` 내용을 `/tmp/resolv.txt` 에 저장하고, `search` 줄을 읽어 보세요.

완료 조건: 파일에 `search` 줄이 있고, 그 줄에 `$NS.svc.cluster.local` 이 들어 있어야 합니다.',
   '`kubectl exec client -n $NS -- cat /etc/resolv.conf` 는 `client` Pod 안에서 그 파일을 읽어 보여 줍니다. (`cat` 은 파일 내용 출력) 결과를 `>` 로 저장하세요. 파일의 `nameserver` 는 이름을 IP 로 바꿔 주는 서버(클러스터 DNS), `search` 는 이름 뒤에 붙여 볼 주소 목록입니다.',
   'kubectl exec client -n $NS -- cat /etc/resolv.conf > /tmp/resolv.txt

# search 줄 : 이름 뒤에 차례로 붙여 보는 주소 (내 네임스페이스 → svc.cluster.local → cluster.local)
# nameserver : 클러스터 DNS 서버 주소
cat /tmp/resolv.txt',
   '["sh", "-c", "kubectl run client --image=busybox -n $NS --command -- sleep 3600 >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/client -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "grep -q ''^search'' /tmp/resolv.txt && grep -q \\"$NS.svc.cluster.local\\" /tmp/resolv.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 37, 7, 'Service 의 port 와 targetPort 를 맞춰 만들기',
   'Service 는 **받는 포트**(`port`)와 **Pod 로 보내는 포트**(`targetPort`)를 따로 정할 수 있습니다. 컨테이너가 `80` 포트로 뜨더라도 Service 는 다른 번호로 열 수 있습니다. `$NS` 에는 `80` 포트로 뜨는 nginx Deployment `web` 과 시험용 Pod `client` 가 있습니다.

Deployment `web` 앞에 Service `web-svc` 를 만들어서, **`8080` 포트로 접속하면 컨테이너의 `80` 포트로 전달**되게 하세요.

완료 조건: `client` Pod 에서 `http://web-svc:8080` 으로 접속하면 nginx 응답이 와야 합니다.',
   '`kubectl expose deployment web --name=web-svc --port=8080 --target-port=80 -n $NS` 입니다. (`--port` Service 가 받는 포트, `--target-port` Pod 컨테이너로 보내는 포트, `--name` 만들 Service 이름) 만든 뒤 `kubectl get svc web-svc -n $NS` 로 확인하고, `kubectl exec client -n $NS -- wget -qO- http://web-svc:8080` 으로 접속해 보세요.',
   'kubectl expose deployment web --name=web-svc --port=8080 --target-port=80 -n $NS

# --port=8080 : Service 가 받는 포트 (클라이언트가 쓰는 번호)
# --target-port=80 : Pod 컨테이너가 실제로 듣는 포트
kubectl exec client -n $NS -- wget -qO- http://web-svc:8080 | head -n 4',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl run client --image=busybox -n $NS --command -- sleep 3600 >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/client -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "kubectl exec client -n $NS -- wget -T 5 -qO- http://web-svc:8080 | grep -q nginx"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 37, 6, '다른 네임스페이스의 Service 는 이름을 어떻게 불러야 하는지 이해하기',
   '앞 문제에서 읽은 `/etc/resolv.conf` 의 `search` 줄은 `내네임스페이스.svc.cluster.local svc.cluster.local cluster.local` 형태입니다. 네임스페이스 `shop` 의 Pod 에서 같은 네임스페이스의 Service `web` 은 `web` 만으로 접속됩니다. 그런데 **다른 네임스페이스 `data` 의 Service `db`** 에 `db` 만 쓰면 접속이 안 됩니다.

`db` 만으로는 안 되는 **이유**와 올바른 이름을 고르세요. (`client` Pod 의 `search` 줄을 다시 읽어 보면 힌트가 있습니다)',
   '`search` 줄의 첫 항목에는 **자기 네임스페이스 이름**이 들어 있습니다. 시스템은 `db` 뒤에 `search` 목록을 하나씩 붙여 `db.shop.svc.cluster.local`, `db.svc.cluster.local`, `db.cluster.local` 순으로 찾아봅니다. 이 이름들 중에 네임스페이스 `data` 의 Service 가 있을까요?',
   NULL,
   '["sh", "-c", "kubectl run client --image=busybox -n $NS --command -- sleep 3600 >/dev/null 2>&1; kubectl wait --for=condition=Ready pod/client -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["Service 이름은 클러스터에서 유일해야 해서, 같은 이름 `db` 를 다른 네임스페이스에서 쓸 수 없기 때문이다", "`db` 만 쓰면 `search` 목록에 따라 **자기 네임스페이스(`shop`)의 `db`** 로 완성되어, `data` 의 Service 를 찾지 못한다. `db.data`(또는 `db.data.svc.cluster.local`)처럼 **네임스페이스를 붙여야** 한다", "다른 네임스페이스의 Service 는 클러스터 안에서는 접속할 수 없기 때문이다", "짧은 이름은 포트 번호를 함께 써야 하기 때문이다"]',
   1,
   '정답은 **B** 입니다. Service 의 전체 이름은 `서비스.네임스페이스.svc.cluster.local` 입니다. 짧은 이름 `db` 는 Pod 의 `search` 목록에서 **자기 네임스페이스**(`shop`)가 가장 먼저 붙어 `db.shop.svc.cluster.local` 로 완성되므로, `data` 에 있는 Service 는 찾지 못합니다. 네임스페이스를 붙여 `db.data` 로 부르면 `search` 의 `svc.cluster.local` 이 이어 붙어 `db.data.svc.cluster.local` 이 되어 접속됩니다.

**원리:** 클러스터 DNS(`nameserver`)는 Service 마다 `서비스.네임스페이스.svc.cluster.local` 이름을 등록해 두고, 각 Pod 의 `/etc/resolv.conf` 의 `search` 는 **그 Pod 의 네임스페이스를 첫 번째로** 둡니다. 그래서 같은 네임스페이스는 짧은 이름, 다른 네임스페이스는 `서비스.네임스페이스` 로 부릅니다. 이름 해석 단계가 리눅스의 `/etc/resolv.conf` 와 같은 구조라는 점이 핵심입니다.

- A 같은 이름은 다른 네임스페이스에서 **쓸 수 있습니다.** 네임스페이스가 이름 공간을 나눕니다.
- C 다른 네임스페이스의 Service 도 클러스터 안에서 접속됩니다. (NetworkPolicy 로 막지 않은 한)
- D 포트는 이름 해석과 무관합니다.

확인: `kubectl exec client -n $NS -- cat /etc/resolv.conf`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 37, 8, 'Service 의 포트 세 가지 역할 구분하기',
   '`$NS` 에는 NodePort 유형의 Service `web-svc` 가 있습니다. `kubectl get svc web-svc -n $NS` 의 `PORT(S)` 열은 `8080:3xxxx/TCP` 처럼 나오고, `kubectl describe svc web-svc -n $NS` 에는 `Port`, `TargetPort`, `NodePort` 가 따로 나옵니다. 값을 확인해 보세요.

**클러스터 안의 다른 Pod 가** `web-svc` 로 접속할 때 쓰는 포트는 무엇일까요?',
   '`describe` 의 `Port`(Service 가 받는 포트), `TargetPort`(Pod 컨테이너로 보내는 포트), `NodePort`(각 노드에서 밖으로 여는 포트) 세 가지를 비교해 보세요. 클러스터 **안**에서 Service 로 접속할 때는 노드가 아니라 Service 자체의 포트를 씁니다.',
   NULL,
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl expose deployment web --name=web-svc --port=8080 --target-port=80 --type=NodePort -n $NS >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '[]',
   'choice',
   '["`TargetPort` 인 `80` (컨테이너가 듣는 포트)", "`Port` 인 `8080` (Service 가 받는 포트)", "`NodePort` 인 `3xxxx` (노드가 밖으로 여는 포트)", "아무 포트나 쓸 수 있다"]',
   1,
   '정답은 **B `Port` 인 `8080`** 입니다. 클러스터 안의 Pod 는 `http://web-svc:8080` 으로 접속하고, Service 가 그 요청을 Pod 컨테이너의 `TargetPort`(`80`)로 전달합니다.

**원리:** Service 에는 포트가 세 가지 있고 각각 **누가 쓰는지**가 다릅니다.
- `port` : Service 가 받는 포트. **클러스터 안의 클라이언트**가 쓰는 번호입니다.
- `targetPort` : Service 가 요청을 넘기는 **Pod 컨테이너의 포트**입니다.
- `nodePort` : NodePort 유형일 때 **각 노드가 밖으로 여는 포트**입니다. 클러스터 **밖**에서 `노드IP:nodePort` 로 접속할 때 씁니다.

- A `TargetPort` 80 : Pod 컨테이너 쪽 포트입니다. Service 를 거치지 않고 Pod IP 로 직접 접속할 때 쓰는 번호입니다.
- C `NodePort` : 노드의 IP 로 밖에서 접속할 때 쓰는 포트입니다. 클러스터 안에서는 Service 이름과 `port` 를 씁니다.
- D 아무 포트나 : Service 는 정해진 `port` 로만 받습니다.

확인: `kubectl describe svc web-svc -n $NS`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 37, 9, '상황에 맞는 외부 접속 방법 고르기',
   '클러스터 안의 앱에 **밖에서 접속하는 방법**은 여러 가지입니다. 상황에 따라 알맞은 것이 다릅니다. 개발자가 자기 PC 에서 `web` Pod 안의 앱이 잘 응답하는지 **잠깐 확인**하려고 합니다. 이 앱을 다른 사람에게 열어 줄 필요는 없고, 클러스터 설정도 바꾸고 싶지 않습니다.

이 상황에 가장 알맞은 방법을 고르세요.',
   '각 방법의 성격을 떠올려 보세요. `NodePort` 는 모든 노드의 포트를 열고, `Ingress` 는 도메인 규칙과 Ingress 컨트롤러가 필요하고, `ClusterIP` 는 클러스터 안에서만 접속됩니다. `kubectl port-forward` 는 내 PC 의 포트를 Pod 나 Service 로 **임시로** 연결합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`NodePort` Service 를 만들어 모든 노드의 포트를 연다", "`kubectl port-forward` 로 내 PC 의 포트를 Pod 에 임시로 연결한다", "`Ingress` 와 도메인을 만들어 외부에 공개한다", "`ClusterIP` Service 를 만들고 PC 에서 그 IP 로 접속한다"]',
   1,
   '정답은 **B `kubectl port-forward`** 입니다. 내 PC 의 포트를 Pod 나 Service 로 **임시로** 연결하고, 명령을 끝내면 연결도 사라집니다. 클러스터에 아무것도 만들지 않고 나만 접속하는 가장 가벼운 방법입니다.

**원리:** 외부 접속 방법은 **누가, 얼마나 오래, 어떤 범위로** 접속하는지에 따라 고릅니다. `port-forward` 는 개발자의 임시 확인용(나만, 잠깐), `NodePort` 는 노드 IP 로 간단히 여는 방법(모든 노드의 포트가 열려 보안과 관리가 부담), `Ingress` 는 도메인과 경로 규칙으로 여러 서비스를 공개하는 정식 방법(Ingress 컨트롤러 필요)입니다.

- A `NodePort` : 모든 노드의 포트가 열려 필요 이상으로 노출되고, 클러스터에 리소스를 만들어야 합니다.
- C `Ingress` : 외부 공개용 정식 방법입니다. 잠깐 확인하려고 쓰기에는 과하고 컨트롤러가 필요합니다.
- D `ClusterIP` : 클러스터 **안**에서만 접속되는 가상 IP 라 PC 에서는 닿지 않습니다.

확인: `kubectl port-forward pod/<Pod이름> 8080:80 -n $NS`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 37 AND order_index = 9);

UPDATE quest_set SET display_order = 285 WHERE id = 37;
