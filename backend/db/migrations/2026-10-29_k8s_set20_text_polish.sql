-- 세트 20 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='기본 네임스페이스 확인하기', description='`kubectl` 은 `-n` 을 생략하면 **기본 네임스페이스**를 씁니다. 엉뚱한 네임스페이스에서 작업하는 실수를 막으려면 지금 어디에 있는지 알아야 합니다.

현재 `kubectl` 이 기본으로 사용하는 네임스페이스 이름만 `/tmp/ns.txt` 에 저장하세요.', hint='`kubectl config view --minify` 는 현재 컨텍스트의 설정만 보여 줍니다. `-o jsonpath=''{..namespace}''` 를 붙이면 namespace 값만 출력됩니다.', solution='kubectl config view --minify -o jsonpath=''{..namespace}'' > /tmp/ns.txt

# --minify : 현재 컨텍스트에 해당하는 설정만' WHERE quest_set_id = 20 AND order_index = 1;
UPDATE quest SET title='Pod 가 실행 중인 노드 확인하기', description='Pod 가 어느 노드에서 돌고 있는지는 장애 분석 때 가장 먼저 확인하는 정보입니다.

`$NS` 네임스페이스의 `web` Pod 가 실행 중인 **노드 이름**을 `/tmp/node.txt` 에 저장하세요. (`web` Pod 는 이미 만들어져 있습니다)', hint='`kubectl get pod web -n <네임스페이스> -o wide` 의 `NODE` 열에 나옵니다. 값만 뽑으려면 `-o jsonpath=''{.spec.nodeName}''` 를 쓰세요.', solution='kubectl get pod web -n $NS -o jsonpath=''{.spec.nodeName}'' > /tmp/node.txt

# 눈으로 보려면: kubectl get pod web -n $NS -o wide' WHERE quest_set_id = 20 AND order_index = 2;
UPDATE quest SET title='Pod IP 확인하기', description='Pod 마다 클러스터 안에서 쓰는 고유한 IP 가 있습니다. 네트워크 문제를 볼 때 필요합니다.

`$NS` 네임스페이스의 `web` Pod 의 **IP 주소**를 `/tmp/pod_ip.txt` 에 저장하세요.', hint='`kubectl get pod web -n <네임스페이스> -o wide` 의 `IP` 열에 나옵니다. 값만 뽑으려면 `-o jsonpath=''{.status.podIP}''` 를 쓰세요.', solution='kubectl get pod web -n $NS -o jsonpath=''{.status.podIP}'' > /tmp/pod_ip.txt' WHERE quest_set_id = 20 AND order_index = 3;
UPDATE quest SET title='컨테이너 안에서 명령 실행하기', description='Pod 안에서 직접 명령을 실행해 상태를 확인하는 것은 디버깅의 기본입니다.

`$NS` 의 `web` Pod 안에서 `hostname` 명령을 실행하고, 그 결과를 `/tmp/host.txt` 에 저장하세요.
(참고: 안에서 계속 작업하고 싶으면 `kubectl exec -it web -- bash` 로 접속합니다)', hint='`kubectl exec <Pod이름> -n <네임스페이스> -- <명령>` 형식입니다. `--` 뒤가 Pod 안에서 실행될 명령입니다.', solution='kubectl exec web -n $NS -- hostname > /tmp/host.txt

# -- 뒤의 명령이 컨테이너 안에서 실행됩니다
# 대화형 접속: kubectl exec -it web -n $NS -- bash' WHERE quest_set_id = 20 AND order_index = 4;
UPDATE quest SET title='로그의 마지막 몇 줄만 보기', description='로그가 길면 최근 몇 줄만 봅니다. 실시간으로 따라가려면 `-f` 를 씁니다.

`$NS` 의 `logger` Pod 가 출력한 로그의 **마지막 3줄**을 `/tmp/tail3.txt` 에 저장하세요.', hint='`kubectl logs <Pod이름> -n <네임스페이스> --tail=<줄수>` 입니다. (`-f` 를 붙이면 새 로그를 계속 보여 주며 Ctrl+C 로 종료합니다)', solution='kubectl logs logger -n $NS --tail=3 > /tmp/tail3.txt

# 실시간으로 따라가기: kubectl logs logger -n $NS -f' WHERE quest_set_id = 20 AND order_index = 5;
UPDATE quest SET title='라벨로 Pod 골라서 조회하기', description='Pod 가 많을 때는 **라벨**로 골라서 봅니다.

`$NS` 에는 `p1`, `p2`, `p3` Pod 가 있고 각각 `app=web`, `app=db`, `app=web` 라벨이 붙어 있습니다.
라벨이 `app=web` 인 Pod 의 **이름**만 한 줄씩 정렬해서 `/tmp/web_pods.txt` 에 저장하세요.', hint='`kubectl get pods -n <네임스페이스> -l app=web` 의 `-l` 이 라벨 셀렉터입니다. `-o name` 을 붙이면 `pod/p1` 처럼 나오고, `sed ''s#^pod/##''` 로 앞의 `pod/` 를 지울 수 있습니다.', solution='kubectl get pods -n $NS -l app=web -o name | sed ''s#^pod/##'' | sort > /tmp/web_pods.txt

# -l app=web : 라벨이 app=web 인 것만' WHERE quest_set_id = 20 AND order_index = 6;
UPDATE quest SET title='라벨로 골라서 삭제하기', description='이름 대신 라벨로 여러 리소스를 한꺼번에 지울 수도 있습니다. 대상을 잘못 고르면 큰 사고라서, 삭제 전에 같은 조건으로 먼저 조회하는 습관이 중요합니다.

`$NS` 에는 `p1`(`app=web`), `p2`(`app=db`), `p3`(`app=web`) Pod 가 있습니다. 라벨이 `app=db` 인 Pod **만** 삭제하세요. 나머지는 남겨야 합니다.', hint='삭제 전: `kubectl get pods -n <네임스페이스> -l app=db` 로 대상이 `p2` 하나인지 확인합니다.
삭제: `kubectl delete pod -n <네임스페이스> -l app=db`', solution='# 먼저 대상 확인
kubectl get pods -n $NS -l app=db

# 확인한 대상만 삭제
kubectl delete pod -n $NS -l app=db' WHERE quest_set_id = 20 AND order_index = 7;
UPDATE quest SET title='이벤트로 Pod 의 이력 확인하기', description='쿠버네티스는 Pod 에 일어난 일(스케줄됨, 이미지 받음, 시작됨, 실패 등)을 **이벤트**로 남깁니다. 원인을 찾을 때 가장 먼저 보는 곳입니다.

`$NS` 의 `web` Pod 에 대한 이벤트의 **Reason 값**(예: `Scheduled`)만 `/tmp/reasons.txt` 에 저장하세요.', hint='`kubectl get events -n <네임스페이스> --field-selector involvedObject.name=web` 으로 `web` Pod 의 이벤트만 걸러 봅니다. `-o custom-columns=REASON:.reason --no-headers` 를 붙이면 Reason 열만 나옵니다. (`kubectl describe pod web` 아래쪽의 Events 와 같은 내용입니다)', solution='kubectl get events -n $NS --field-selector involvedObject.name=web \\
  -o custom-columns=REASON:.reason --no-headers > /tmp/reasons.txt' WHERE quest_set_id = 20 AND order_index = 8;
UPDATE quest SET title='Deployment 의 배포 이력 확인하기', description='Deployment 는 이미지를 바꿀 때마다 **리비전(배포 이력)** 이 쌓이고, 이 이력으로 이전 버전으로 되돌릴 수 있습니다.

`$NS` 의 `app` Deployment 가 지금까지 **몇 번 배포(리비전)** 되었는지 숫자만 `/tmp/revisions.txt` 에 저장하세요.', hint='`kubectl rollout history deployment/<이름> -n <네임스페이스>` 가 리비전 목록을 보여 줍니다. 숫자로 시작하는 줄이 리비전이므로 `grep -c ''^[0-9]''` 로 개수를 세세요.', solution='kubectl rollout history deployment/app -n $NS | grep -c ''^[0-9]'' > /tmp/revisions.txt

# grep -c : 일치하는 줄의 개수' WHERE quest_set_id = 20 AND order_index = 9;
UPDATE quest SET title='Deployment 의 Pod 를 다시 시작하기', description='이미지나 설정을 바꾸지 않고 Pod 만 새로 띄우고 싶을 때(메모리 누수 해소, 설정 다시 읽기 등) **롤링 재시작**을 씁니다. 서비스가 끊기지 않게 하나씩 교체됩니다.

`$NS` 의 `app` Deployment 의 Pod 를 다시 시작하세요.', hint='`kubectl rollout restart deployment/<이름> -n <네임스페이스>` 입니다. 진행 상황은 `kubectl rollout status deployment/<이름> -n <네임스페이스>` 로 볼 수 있습니다.', solution='kubectl rollout restart deployment/app -n $NS

# 진행 확인
kubectl rollout status deployment/app -n $NS' WHERE quest_set_id = 20 AND order_index = 10;
UPDATE quest SET title='리소스를 YAML 로 백업하기', description='수정하기 전에 현재 상태를 YAML 로 백업해 두면 문제가 생겼을 때 바로 복구할 수 있습니다.

`$NS` 의 `app` Deployment 를 YAML 로 `/tmp/app-backup.yaml` 에 저장하세요.', hint='`kubectl get <종류> <이름> -n <네임스페이스> -o yaml` 은 현재 상태를 YAML 로 출력합니다. 이 파일은 나중에 `kubectl apply -f` 로 다시 적용할 수 있습니다.', solution='kubectl get deployment app -n $NS -o yaml > /tmp/app-backup.yaml

# 복구할 때: kubectl apply -f /tmp/app-backup.yaml' WHERE quest_set_id = 20 AND order_index = 11;
UPDATE quest SET title='한 번만 실행하는 Pod 로 명령 결과 확인하기', description='일회성 작업은 한 번 실행하고 끝나는 Pod 로 돌립니다.

1. `busybox` 이미지로 `echo hello` 를 한 번만 실행하는 Pod `hello` 를 `$NS` 에 만듭니다. (끝난 뒤 다시 시작되지 않게 `--restart=Never`)
2. 완료되면 그 Pod 의 로그에서 출력을 읽어 `/tmp/hello.txt` 에 저장합니다.', hint='Pod 생성: `kubectl run hello --image=busybox --restart=Never -n <네임스페이스> -- echo hello` (`--` 뒤가 컨테이너 안에서 실행할 명령)
완료까지 몇 초 걸립니다. 상태가 `Completed` 가 된 뒤 `kubectl logs hello -n <네임스페이스>` 로 출력을 읽으세요.', solution='kubectl run hello --image=busybox --restart=Never -n $NS -- echo hello
kubectl wait --for=jsonpath=''{.status.phase}''=Succeeded pod/hello -n $NS --timeout=90s
kubectl logs hello -n $NS > /tmp/hello.txt

# kubectl wait : 조건이 될 때까지 기다림 (Pod 가 끝날 때까지)' WHERE quest_set_id = 20 AND order_index = 12;
