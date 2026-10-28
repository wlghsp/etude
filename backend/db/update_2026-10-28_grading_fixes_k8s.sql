-- 채점 검증 러너(V4)가 찾은 k8s 세트(6, 12, 13, 14) 결함 7건 수정.
-- 원본은 03_quest_set06/12/13/14.sql (새로 만든 DB에는 자동 반영된다). 이미 떠 있는 DB에는 이 파일을 한 번 실행한다.

-- 6.4: 보기만 하는 퀘스트라 흔적이 없고 setup이 만든 파드가 채점을 통과시켰다. 결과를 파일로 저장하게 한다
UPDATE quest SET
  description = '$NS 네임스페이스의 Pod 목록을 확인하고, 결과를 /tmp/pods_result.txt 에 저장하세요.',
  hint        = 'kubectl get pods -n <namespace> 의 결과를 리다이렉션(>)으로 저장하세요.',
  solution    = 'kubectl get pods -n $NS > /tmp/pods_result.txt',
  grade_cmd   = '["sh", "-c", "grep -q nginx /tmp/pods_result.txt"]'
WHERE quest_set_id = 6 AND order_index = 4;

-- 6.13: kubectl create deployment가 만드는 컨테이너 이름은 my-app이 아니라 nginx다. 풀이대로 하면 "unable to find container"로 항상 실패했다
UPDATE quest SET
  hint     = 'kubectl set image deployment/<name> <container명>=<새이미지> -n <namespace> 를 사용합니다. kubectl create deployment 로 만든 컨테이너의 이름은 이미지 이름(nginx)입니다.',
  solution = 'kubectl set image deployment/my-app nginx=nginx:alpine -n $NS'
WHERE quest_set_id = 6 AND order_index = 13;

-- 6.14: setup의 set image가 같은 이유로 조용히 실패했고, 채점식(rollout history에 2|3)은 setup만으로도 통과했다. 롤백 후 이미지가 alpine이 아니어야 통과한다
UPDATE quest SET
  setup_cmd = '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; kubectl set image deployment/my-app nginx=nginx:alpine -n $NS 2>/dev/null; true"]',
  grade_cmd = '["sh", "-c", "! kubectl get deployment my-app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' | grep -q alpine"]'
WHERE quest_set_id = 6 AND order_index = 14;

-- 12.6: etude-k8s는 busybox라 base64 --decode를 지원하지 않는다 (-d만 된다). 힌트대로 하면 항상 실패했다
UPDATE quest SET
  hint     = 'kubectl get secret <name> -n <namespace> -o jsonpath=''{.data.DB_USER}'' 로 값을 꺼낸 뒤 base64 -d 로 디코딩합니다.',
  solution = 'kubectl get secret db-secret -n $NS -o jsonpath=''{.data.DB_USER}'' | base64 -d > /tmp/secret_result.txt'
WHERE quest_set_id = 12 AND order_index = 6;

-- 13.5: 풀이의 `a && b && c & sleep 2 && curl`은 체인 전체가 백그라운드로 가서 curl이 port-forward보다 먼저 실행됐다. 순서가 맞는 풀이로 바꾼다
UPDATE quest SET
  solution = 'kubectl run pf-nginx --image=nginx -n $NS && kubectl expose pod pf-nginx --port=80 -n $NS && kubectl wait --for=condition=ready pod/pf-nginx -n $NS --timeout=60s && (kubectl port-forward svc/pf-nginx 9090:80 -n $NS > /dev/null 2>&1 &) && sleep 3 && curl -s localhost:9090 > /tmp/pf_result.txt'
WHERE quest_set_id = 13 AND order_index = 5;

-- 14.2: 채점식이 helm repo update를 스스로 실행해서 아무것도 안 해도 통과했다. 출력을 파일로 저장하게 한다
UPDATE quest SET
  description = 'Helm 저장소 인덱스를 최신 상태로 갱신하고, 출력 결과를 /tmp/helm_update.txt 에 저장하세요.',
  hint        = 'helm repo update 를 실행하고 리다이렉션(> 파일 2>&1)으로 저장합니다.',
  solution    = 'helm repo update > /tmp/helm_update.txt 2>&1',
  grade_cmd   = '["sh", "-c", "grep -qi ''update complete'' /tmp/helm_update.txt"]'
WHERE quest_set_id = 14 AND order_index = 2;

-- 14.7: `grep -c deployed >= 1`은 setup의 최초 설치만으로 통과했다. 업그레이드한 값(replicaCount: 3)을 채점한다
UPDATE quest SET
  grade_cmd = '["sh", "-c", "helm get values my-nginx -n $NS | grep -q ''replicaCount: 3''"]'
WHERE quest_set_id = 14 AND order_index = 7;
