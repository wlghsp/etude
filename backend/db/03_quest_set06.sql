-- 세트 6: k8s 기초 (order 1~14)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (6,  1, '클러스터 노드 확인하기',
   '현재 클러스터에 어떤 노드가 있는지 확인하세요.',
   'kubectl get nodes 명령어를 사용하세요.',
   'kubectl get nodes',
   NULL,
   '["sh", "-c", "kubectl get nodes | grep -i ready"]'),

  (6,  2, '네임스페이스 목록 확인하기',
   '클러스터에 존재하는 네임스페이스 목록을 확인하세요.',
   'kubectl get namespaces 또는 kubectl get ns',
   'kubectl get namespaces',
   NULL,
   '["sh", "-c", "kubectl get ns | grep quest-"]'),

  (6,  3, 'Pod 실행하기',
   '$NS 네임스페이스에 nginx 이미지로 nginx라는 이름의 Pod를 실행하세요.',
   'kubectl run <name> --image=<image> -n <namespace>',
   'kubectl run nginx --image=nginx -n $NS',
   NULL,
   '["sh", "-c", "kubectl get pod nginx -n $NS 2>/dev/null | grep -E ''Running|ContainerCreating''"]'),

  (6,  4, 'Pod 목록 확인하기',
   '$NS 네임스페이스의 Pod 목록을 확인하세요.',
   'kubectl get pods -n <namespace>',
   'kubectl get pods -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pods -n $NS | grep nginx"]'),

  (6,  5, 'Pod 로그 확인하기',
   '$NS 네임스페이스의 nginx Pod 로그를 확인하세요.',
   'kubectl logs <pod-name> -n <namespace>',
   'kubectl logs nginx -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=ready pod/nginx -n $NS --timeout=30s 2>/dev/null; true"]',
   '["sh", "-c", "kubectl logs nginx -n $NS 2>/dev/null; exit 0"]'),

  (6,  6, 'Pod 삭제하기',
   '$NS 네임스페이스의 nginx Pod를 삭제하세요.',
   'kubectl delete pod <name> -n <namespace>',
   'kubectl delete pod nginx -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "! kubectl get pod nginx -n $NS 2>/dev/null | grep -q nginx"]'),

  (6,  7, 'Deployment 생성하기',
   '$NS 네임스페이스에 nginx 이미지로 my-app이라는 Deployment를 생성하세요.',
   'kubectl create deployment <name> --image=<image> -n <namespace>',
   'kubectl create deployment my-app --image=nginx -n $NS',
   NULL,
   '["sh", "-c", "kubectl get deploy my-app -n $NS | grep my-app"]'),

  (6,  8, 'Deployment 스케일 조정하기',
   '$NS 네임스페이스의 my-app Deployment를 3개로 스케일 아웃하세요.',
   'kubectl scale deployment <name> --replicas=<n> -n <namespace>',
   'kubectl scale deployment my-app --replicas=3 -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get deploy my-app -n $NS | grep -E ''3/3|3 ''"]'),

  (6,  9, 'Service 생성하기',
   '$NS 네임스페이스의 my-app Deployment를 포트 80으로 노출하는 Service를 생성하세요.',
   'kubectl expose deployment <name> --port=<port> -n <namespace>',
   'kubectl expose deployment my-app --port=80 -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get svc my-app -n $NS | grep my-app"]'),

  (6, 10, '리소스 전체 확인하기',
   '$NS 네임스페이스의 모든 리소스를 한 번에 확인하세요.',
   'kubectl get all -n <namespace>',
   'kubectl get all -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; kubectl expose deployment my-app --port=80 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get all -n $NS | grep -c my-app | xargs -I{} test {} -ge 2"]'),

  (6, 11, 'YAML 파일로 Pod 생성하기',
   '/tmp/pod.yaml 파일을 작성해서 $NS 네임스페이스에 nginx Pod를 생성하세요. Pod 이름은 yaml-pod 로 지정하세요.',
   'kubectl apply -f <파일> 로 yaml 파일을 적용합니다. apiVersion: v1 / kind: Pod 로 시작하는 yaml을 작성하세요.',
   'cat > /tmp/pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: yaml-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
EOF
kubectl apply -f /tmp/pod.yaml',
   NULL,
   '["sh", "-c", "kubectl get pod yaml-pod -n $NS | grep -q yaml-pod"]'),

  (6, 12, 'Pod 안에서 명령어 실행하기',
   '$NS 네임스페이스의 yaml-pod Pod 안에서 nginx -v 명령어를 실행하고 결과를 /tmp/exec_result.txt 에 저장하세요.',
   'kubectl exec <pod명> -n <namespace> -- <명령어> 형식을 사용합니다.',
   'kubectl exec yaml-pod -n $NS -- nginx -v > /tmp/exec_result.txt 2>&1',
   '["sh", "-c", "kubectl run yaml-pod --image=nginx -n $NS 2>/dev/null; kubectl wait pod/yaml-pod -n $NS --for=condition=Ready --timeout=60s 2>/dev/null; true"]',
   '["sh", "-c", "grep -qi ''nginx'' /tmp/exec_result.txt"]'),

  (6, 13, 'Deployment 롤링 업데이트하기',
   '$NS 네임스페이스의 my-app Deployment 이미지를 nginx:alpine 으로 업데이트하세요.',
   'kubectl set image deployment/<name> <container명>=<새이미지> -n <namespace> 를 사용합니다.',
   'kubectl set image deployment/my-app my-app=nginx:alpine -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get deployment my-app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' | grep -q alpine"]'),

  (6, 14, 'Deployment 롤백하기',
   '$NS 네임스페이스의 my-app Deployment를 이전 버전으로 롤백하세요.',
   'kubectl rollout undo deployment/<name> -n <namespace> 를 사용합니다.',
   'kubectl rollout undo deployment/my-app -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; kubectl set image deployment/my-app my-app=nginx:alpine -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl rollout history deployment/my-app -n $NS | grep -q ''2\\|3''"]');
