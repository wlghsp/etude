-- 세트 92: 서비스 메시 YAML 읽고 고치기: Gateway, VirtualService
-- 기본기 사다리(docs/specs/spec_foundations_ladder.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (92, 1, 'Gateway 로 HTTPS 를 받는 설정 채우기', '`app.example.com` 의 **443 포트 HTTPS** 를 메시의 **ingress gateway** 가 받아 **TLS 를 종료**하게 하는 Gateway 리소스입니다. 빈칸을 채우세요.', 'selector 는 어느 gateway Pod 에 적용할지, `tls.mode` 는 인증서를 gateway 가 풀어 읽을지(종료) 그대로 통과시킬지입니다.', NULL, NULL, '[]', 'fill', '["ingressgateway", "sidecar", "443", "80", "SIMPLE", "PASSTHROUGH"]', NULL, '`istio: ingressgateway` 레이블이 붙은 gateway Pod 에 이 설정이 적용됩니다. `SIMPLE` 은 gateway 가 TLS 를 **종료**(인증서는 Secret 로 지정)하고, `PASSTHROUGH` 는 복호화하지 않고 뒤로 넘기는 방식입니다. `sidecar` 는 Pod 옆에 붙는 프록시라 gateway 의 selector 값이 아닙니다.', '[0, 2, 4]', 'apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: web-gateway
spec:
  selector:
    istio: {0}
  servers:
    - port:
        number: {1}
        name: https
        protocol: HTTPS
      tls:
        mode: {2}
      hosts: ["app.example.com"]', NULL, NULL),
  (92, 2, 'VirtualService 로 카나리 배포하기', '`web` 서비스의 v1 에 **90%**, 새 버전 v2 에 **10%** 만 트래픽을 보내 카나리 배포를 하려는 VirtualService 의 일부입니다. 빈칸을 채우세요.', '두 가중치의 합은 100 이어야 합니다.', NULL, NULL, '[]', 'fill', '["90", "10", "50", "100"]', NULL, '코드나 앱 재배포 없이 YAML 만 바꿔 비율을 조절할 수 있는 것이 서비스 메시의 장점입니다. 문제가 없으면 10 → 50 → 100 으로 올리고, 문제가 있으면 v2 를 0 으로 되돌립니다. 가중치 합이 100 이 아니면 설정이 거부됩니다.', '[0, 1]', 'http:
  - route:
      - destination:
          host: web
          subset: v1
        weight: {0}
      - destination:
          host: web
          subset: v2
        weight: {1}', NULL, NULL),
  (92, 3, 'VirtualService 로 경로 나누기', '`/api` 로 시작하는 요청은 `api-svc` 로, 나머지는 `web-svc` 로 보내려고 합니다. 앞의 규칙을 채우세요.', '`match` 로 조건을 주고, `route` 로 목적지를 정합니다.', NULL, NULL, '[]', 'fill', '["/api", "/", "api-svc", "web-svc"]', NULL, '규칙은 **위에서 아래로** 처음 맞는 것이 적용됩니다. 조건 없는 마지막 규칙이 나머지를 받는 기본 경로입니다. 순서가 바뀌어 조건 없는 규칙이 앞에 오면 뒤의 규칙은 영원히 쓰이지 않습니다.', '[0, 2]', 'http:
  - match:
      - uri:
          prefix: {0}
    route:
      - destination:
          host: {1}
  - route:
      - destination:
          host: web-svc', NULL, NULL),
  (92, 4, '새 서비스를 메시로 노출하는 순서 놓기', '새 서비스를 클러스터 밖에서 도메인으로 접근할 수 있게 할 때의 흐름을 **앞에서 뒤**로 놓으세요. (Gateway 는 이미 있다고 가정합니다)', '서비스를 먼저 띄우고, 라우팅 규칙을 만들고, 적용하고, 확인합니다.', NULL, NULL, '[]', 'order', '["도메인으로 요청해 응답이 오는지 확인한다", "서비스(Deployment 와 Service)를 배포하고 Pod 가 Ready 인지 확인한다", "`kubectl apply` 로 VirtualService 를 적용하고 `kubectl get virtualservice` 로 반영을 확인한다", "해당 도메인(host)과 목적지 서비스를 가리키는 VirtualService 를 작성한다"]', NULL, '**서비스 배포 → VirtualService 작성 → apply·조회 → 도메인 호출 확인** 입니다. Gateway 가 이미 TLS 와 포트를 처리하므로 보통 VirtualService 만 추가합니다. 목적지 서비스가 준비되지 않은 채 라우팅부터 만들면 503 이 나옵니다.', '[1, 3, 2, 0]', NULL, NULL, NULL),
  (92, 5, 'Gateway 와 VirtualService 가 연결되는 방법', 'Gateway 를 만들었는데도 VirtualService 로 요청이 **404** 입니다. 가장 먼저 확인할 것은 무엇일까요?', '둘은 이름과 host 로 서로를 가리킵니다.', NULL, NULL, '[]', 'choice', '["Pod 이름이 너무 긴지", "VirtualService 의 `gateways` 가 Gateway 이름을 정확히 가리키는지, `hosts` 가 Gateway 의 hosts 와 일치하는지", "노드의 CPU 개수", "Kubernetes 버전 번호"]', 1, '`VirtualService.spec.gateways` 에 Gateway 이름이 틀리거나 `hosts` 가 어긋나면 어느 규칙에도 맞지 않아 404 가 납니다. 이름 오타가 가장 흔한 원인입니다.', NULL, NULL, NULL, NULL),
  (92, 6, '서비스 메시가 과한 경우', '서비스가 몇 개 안 되고 서비스 간 통신 제어(mTLS, 재시도, 카나리)가 필요 없습니다. 이때의 판단으로 알맞은 것은 무엇일까요?', '메시는 sidecar 와 컨트롤 플레인이라는 추가 구성이 필요합니다.', NULL, NULL, '[]', 'choice', '["무조건 서비스 메시를 도입하는 것이 항상 이득이다", "Ingress Controller 는 외부 트래픽을 전혀 다룰 수 없다", "서비스 수와 상관없이 메시가 가장 가볍다", "일반 Ingress Controller 로 충분할 수 있다. 메시는 sidecar·컨트롤 플레인 때문에 운영 복잡도와 리소스 비용이 늘기 때문이다"]', 3, 'Ingress Controller 는 외부→내부(North-South) 트래픽만, 메시는 서비스 간(East-West)까지 같은 방식으로 제어합니다. 서비스 수가 늘어 통신 관심사(재시도, mTLS, 추적)가 반복될 때 메시의 가치가 커집니다.', NULL, NULL, NULL, NULL),
  (92, 7, 'Gateway 이름 오타 고치기', '`/tmp/lab/vs.yaml` 의 VirtualService 가 가리키는 Gateway 이름이 **`web-gatway`**(오타)로 되어 있어 라우팅이 되지 않습니다. 실제 Gateway 이름 **`web-gateway`** 로 고치세요. (다른 줄은 그대로)', '`grep gateway /tmp/lab/vs.yaml` 로 현재 값을 확인하고 `sed -i` 로 그 값만 바꿉니다.', 'grep gateway /tmp/lab/vs.yaml
sed -i ''s/web-gatway/web-gateway/'' /tmp/lab/vs.yaml
grep gateway /tmp/lab/vs.yaml

# gateways 에 적는 이름은 Gateway 리소스의 metadata.name 과 같아야 한다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''apiVersion: networking.istio.io/v1beta1\\\\nkind: VirtualService\\\\nmetadata:\\\\n  name: web\\\\nspec:\\\\n  hosts: [\\"app.example.com\\"]\\\\n  gateways:\\\\n    - web-gatway\\\\n  http:\\\\n    - route:\\\\n        - destination:\\\\n            host: web-svc\\\\n'' > /tmp/lab/vs.yaml"]', '["sh", "-c", "( grep -qx \\"    - web-gateway\\" /tmp/lab/vs.yaml ) && ( ! grep -q gatway /tmp/lab/vs.yaml ) && ( grep -q \\"host: web-svc\\" /tmp/lab/vs.yaml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Gateway 이름이 web-gateway 이다", "cmd": ["sh", "-c", "grep -qx \\"    - web-gateway\\" /tmp/lab/vs.yaml"]}, {"label": "오타가 남아 있지 않다", "cmd": ["sh", "-c", "! grep -q gatway /tmp/lab/vs.yaml"]}, {"label": "목적지 서비스는 그대로다", "cmd": ["sh", "-c", "grep -q \\"host: web-svc\\" /tmp/lab/vs.yaml"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'),
  (92, 8, '가중치 합이 100 이 되게 고치기', '`/tmp/lab/canary.yaml` 의 카나리 설정에서 v1 의 가중치가 **80**, v2 가 **10** 이라 합이 100 이 아닙니다. v1 을 **90** 으로 고쳐 합이 100 이 되게 하세요. (v2 는 그대로)', '`grep weight` 로 두 줄을 먼저 확인하세요. `sed` 로 80 인 줄만 바꿉니다.', 'grep weight /tmp/lab/canary.yaml
sed -i ''s/weight: 80/weight: 90/'' /tmp/lab/canary.yaml
grep weight /tmp/lab/canary.yaml

# 가중치 합이 100 이 아니면 설정이 거부된다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''http:\\\\n  - route:\\\\n      - destination:\\\\n          host: web\\\\n          subset: v1\\\\n        weight: 80\\\\n      - destination:\\\\n          host: web\\\\n          subset: v2\\\\n        weight: 10\\\\n'' > /tmp/lab/canary.yaml"]', '["sh", "-c", "( grep -q \\"weight: 90\\" /tmp/lab/canary.yaml ) && ( grep -q \\"weight: 10\\" /tmp/lab/canary.yaml ) && ( [ \\"$(grep -oE \\"weight: [0-9]+\\" /tmp/lab/canary.yaml | awk \\"{s+=\\\\$2} END{print s}\\")\\" = 100 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "v1 가중치가 90 이다", "cmd": ["sh", "-c", "grep -q \\"weight: 90\\" /tmp/lab/canary.yaml"]}, {"label": "v2 가중치는 10 이다", "cmd": ["sh", "-c", "grep -q \\"weight: 10\\" /tmp/lab/canary.yaml"]}, {"label": "가중치 합이 100 이다", "cmd": ["sh", "-c", "[ \\"$(grep -oE \\"weight: [0-9]+\\" /tmp/lab/canary.yaml | awk \\"{s+=\\\\$2} END{print s}\\")\\" = 100 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'),
  (92, 9, '한 파일 속 리소스 종류 세기', '`/tmp/lab/mesh.yaml` 에는 `---` 로 구분된 여러 리소스가 들어 있습니다. 그중 **VirtualService 가 몇 개**인지 숫자만 `/tmp/lab/vs_count.txt` 에 저장하세요.', '각 리소스는 `kind:` 줄로 종류를 밝힙니다. `grep -c` 는 맞는 줄의 개수를 셉니다.\\n확인: `grep kind /tmp/lab/mesh.yaml`', 'grep -c ''^kind: VirtualService'' /tmp/lab/mesh.yaml > /tmp/lab/vs_count.txt
cat /tmp/lab/vs_count.txt

# 한 파일에 --- 로 여러 리소스를 묶을 수 있다', '["sh", "-c", "mkdir -p /tmp/lab && printf ''apiVersion: networking.istio.io/v1beta1\\\\nkind: Gateway\\\\nmetadata:\\\\n  name: web-gateway\\\\n---\\\\napiVersion: networking.istio.io/v1beta1\\\\nkind: VirtualService\\\\nmetadata:\\\\n  name: web\\\\n---\\\\napiVersion: networking.istio.io/v1beta1\\\\nkind: VirtualService\\\\nmetadata:\\\\n  name: api\\\\n---\\\\napiVersion: networking.istio.io/v1beta1\\\\nkind: DestinationRule\\\\nmetadata:\\\\n  name: web\\\\n'' > /tmp/lab/mesh.yaml"]', '["sh", "-c", "( [ -s /tmp/lab/vs_count.txt ] ) && ( [ \\"$(tr -d \\"[:space:]\\" < /tmp/lab/vs_count.txt)\\" = 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/vs_count.txt ]"]}, {"label": "VirtualService 가 2개다", "cmd": ["sh", "-c", "[ \\"$(tr -d \\"[:space:]\\" < /tmp/lab/vs_count.txt)\\" = 2 ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]');
