-- 세트 6 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='클러스터의 노드 목록 확인하기', description='쿠버네티스 클러스터는 여러 서버(노드)로 이루어집니다. 클러스터에 어떤 노드가 있고 정상인지 보는 것이 점검의 시작입니다.

현재 클러스터의 **노드 목록**을 `/tmp/nodes_result.txt` 에 저장하세요.', hint='`kubectl get nodes` 는 노드 이름, 상태(`Ready`), 역할, 버전을 보여 줍니다. 결과를 `>` 로 파일에 저장하세요.', solution='kubectl get nodes > /tmp/nodes_result.txt

# get : 리소스 목록 조회, nodes : 노드' WHERE quest_set_id = 6 AND order_index = 1;
UPDATE quest SET title='네임스페이스 목록 확인하기', description='**네임스페이스**는 클러스터를 논리적으로 나누는 공간입니다. 팀·환경별로 리소스를 분리할 때 씁니다.

클러스터의 **네임스페이스 목록**을 `/tmp/ns_result.txt` 에 저장하세요.', hint='`kubectl get namespaces` (줄여서 `ns`)를 쓰고, 결과를 `>` 로 저장하세요.', solution='kubectl get namespaces > /tmp/ns_result.txt' WHERE quest_set_id = 6 AND order_index = 2;
UPDATE quest SET title='Pod 실행하기', description='**Pod** 는 쿠버네티스에서 컨테이너를 실행하는 가장 작은 단위입니다.

`$NS` 네임스페이스에 `nginx` 이미지로 이름이 `nginx` 인 Pod 를 실행하세요.', hint='`kubectl run <이름> --image=<이미지> -n <네임스페이스>` 형식입니다. `-n` 은 namespace(작업할 네임스페이스 지정)입니다. 확인: `kubectl get pods -n <네임스페이스>`', solution='kubectl run nginx --image=nginx -n $NS

# run : Pod 생성, --image : 사용할 이미지, -n : 네임스페이스' WHERE quest_set_id = 6 AND order_index = 3;
UPDATE quest SET title='Pod 목록 확인하기', description='Pod 가 정상 실행 중인지 확인하는 가장 기본 명령입니다.

`$NS` 네임스페이스의 **Pod 목록**을 `/tmp/pods_result.txt` 에 저장하세요.', hint='`kubectl get pods -n <네임스페이스>` 의 결과를 `>` 로 저장합니다. `STATUS` 열이 `Running` 이면 정상입니다.', solution='kubectl get pods -n $NS > /tmp/pods_result.txt' WHERE quest_set_id = 6 AND order_index = 4;
UPDATE quest SET title='Pod 로그 확인하기', description='Pod 가 이상하게 동작할 때 로그에서 원인을 찾습니다.

`$NS` 네임스페이스의 `nginx` Pod 의 **로그**를 `/tmp/log_result.txt` 에 저장하세요.', hint='`kubectl logs <Pod이름> -n <네임스페이스>` 입니다. 로그가 에러 출력으로 나와도 파일에 담기도록 `2>&1`(에러 출력을 정상 출력과 같은 곳으로)을 함께 쓰세요.', solution='kubectl logs nginx -n $NS > /tmp/log_result.txt 2>&1

# logs : Pod 의 로그 출력, 2>&1 : 에러 출력도 같은 파일로' WHERE quest_set_id = 6 AND order_index = 5;
UPDATE quest SET title='Pod 삭제하기', description='더 이상 필요 없는 Pod 는 삭제해 자원을 돌려줍니다.

`$NS` 네임스페이스의 `nginx` Pod 를 삭제하세요.', hint='`kubectl delete pod <이름> -n <네임스페이스>` 입니다. 삭제는 되돌릴 수 없으니 이름과 네임스페이스를 먼저 확인하세요.', solution='kubectl delete pod nginx -n $NS' WHERE quest_set_id = 6 AND order_index = 6;
UPDATE quest SET title='Deployment 만들기', description='Pod 를 직접 만들면 죽었을 때 되살아나지 않습니다. **Deployment** 는 Pod 의 개수를 유지하고 업데이트를 관리해 주는 실무의 기본 단위입니다.

`$NS` 네임스페이스에 `nginx` 이미지로 `my-app` 이라는 Deployment 를 만드세요.', hint='`kubectl create deployment <이름> --image=<이미지> -n <네임스페이스>` 입니다. 확인: `kubectl get deployment -n <네임스페이스>`', solution='kubectl create deployment my-app --image=nginx -n $NS' WHERE quest_set_id = 6 AND order_index = 7;
UPDATE quest SET title='Deployment 의 Pod 개수 늘리기', description='트래픽이 늘면 Pod 개수를 늘려(scale out) 부하를 나눕니다.

`$NS` 네임스페이스의 `my-app` Deployment 를 **3개**로 늘리세요.', hint='`kubectl scale deployment <이름> --replicas=<개수> -n <네임스페이스>` 입니다. `--replicas` 는 유지할 Pod 복제본 수입니다.', solution='kubectl scale deployment my-app --replicas=3 -n $NS

# --replicas : 유지할 Pod 수' WHERE quest_set_id = 6 AND order_index = 8;
UPDATE quest SET title='Deployment 를 Service 로 노출하기', description='Pod 는 IP 가 자주 바뀌므로 앞에 고정된 접속 지점인 **Service** 를 둡니다.

`$NS` 네임스페이스의 `my-app` Deployment 를 **포트 80** 으로 노출하는 Service 를 만드세요.', hint='`kubectl expose deployment <이름> --port=<포트> -n <네임스페이스>` 입니다. `--port` 는 Service 가 받는 포트입니다. 확인: `kubectl get svc -n <네임스페이스>`', solution='kubectl expose deployment my-app --port=80 -n $NS

# expose : Service 생성, --port : Service 가 받을 포트' WHERE quest_set_id = 6 AND order_index = 9;
UPDATE quest SET title='네임스페이스의 리소스 전체 보기', description='네임스페이스 안에 무엇이 있는지 한눈에 보는 방법입니다. 장애 때 전체 상황 파악에 씁니다.

`$NS` 네임스페이스의 **모든 리소스**(Pod, Service, Deployment 등)를 `/tmp/all_result.txt` 에 저장하세요.', hint='`kubectl get all -n <네임스페이스>` 의 결과를 `>` 로 저장합니다. `all` 은 주요 리소스 종류를 한꺼번에 조회하는 약어입니다.', solution='kubectl get all -n $NS > /tmp/all_result.txt' WHERE quest_set_id = 6 AND order_index = 10;
UPDATE quest SET title='YAML 파일로 Pod 만들기', description='쿠버네티스 리소스는 YAML 파일로 정의하고 `apply` 로 적용하는 것이 실무 방식입니다. 파일이 곧 설정의 기록이 됩니다.

1. `/tmp/pod.yaml` 파일을 작성합니다.
2. 그 파일로 `$NS` 네임스페이스에 `nginx` 이미지의 Pod `yaml-pod` 를 만듭니다.', hint='YAML 은 `apiVersion: v1`, `kind: Pod`, `metadata`(이름·네임스페이스), `spec`(컨테이너 목록) 구조입니다. 직접 쓰기 어려우면 `kubectl run yaml-pod --image=nginx --dry-run=client -o yaml` 로 뼈대를 출력할 수 있습니다. 적용: `kubectl apply -f <파일>` (`-f` 는 file)', solution='cat > /tmp/pod.yaml << EOF
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
kubectl apply -f /tmp/pod.yaml

# apply -f : 파일의 내용대로 리소스를 만들거나 수정' WHERE quest_set_id = 6 AND order_index = 11;
UPDATE quest SET title='Pod 안에서 명령 실행하기', description='Pod 안에서 직접 명령을 실행해 상태나 버전을 확인하는 것은 디버깅의 기본입니다.

`$NS` 네임스페이스의 `yaml-pod` Pod 안에서 `nginx -v`(nginx 버전 확인)를 실행하고, 결과를 `/tmp/exec_result.txt` 에 저장하세요.', hint='`kubectl exec <Pod이름> -n <네임스페이스> -- <명령>` 형식입니다. `--` 뒤가 Pod 안에서 실행될 명령입니다. `nginx -v` 는 버전을 **에러 출력**으로 내보내므로 `2>&1` 을 함께 써야 파일에 담깁니다.', solution='kubectl exec yaml-pod -n $NS -- nginx -v > /tmp/exec_result.txt 2>&1

# -- 뒤의 명령이 컨테이너 안에서 실행됨
# 2>&1 : 에러 출력도 같은 파일로' WHERE quest_set_id = 6 AND order_index = 12;
UPDATE quest SET title='Deployment 이미지 업데이트하기 (롤링 업데이트)', description='새 버전을 배포할 때 Deployment 의 이미지를 바꾸면 Pod 를 **하나씩 새 버전으로 교체**해서 서비스 중단 없이 배포됩니다(롤링 업데이트).

`$NS` 네임스페이스의 `my-app` Deployment 의 이미지를 `nginx:alpine` 으로 업데이트하세요.', hint='`kubectl set image deployment/<이름> <컨테이너이름>=<새이미지> -n <네임스페이스>` 형식입니다. `kubectl create deployment` 로 만든 컨테이너의 이름은 이미지 이름(`nginx`)과 같습니다.', solution='kubectl set image deployment/my-app nginx=nginx:alpine -n $NS

# set image : 컨테이너 이미지 변경, 컨테이너이름=새이미지' WHERE quest_set_id = 6 AND order_index = 13;
UPDATE quest SET title='Deployment 를 이전 버전으로 되돌리기', description='배포한 새 버전에 문제가 생기면 이전 버전으로 즉시 되돌립니다(롤백).

`$NS` 네임스페이스의 `my-app` Deployment 를 **이전 버전으로 롤백**하세요.', hint='`kubectl rollout undo deployment/<이름> -n <네임스페이스>` 입니다. `rollout` 은 배포 이력 관리 명령이고 `undo` 는 직전 버전으로 되돌립니다. 이력은 `kubectl rollout history` 로 볼 수 있습니다.', solution='kubectl rollout undo deployment/my-app -n $NS

# rollout undo : 직전 배포 버전으로 되돌림' WHERE quest_set_id = 6 AND order_index = 14;
