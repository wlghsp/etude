-- 세트 13 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='PVC 로 저장 공간 요청하기', description='Pod 가 사라져도 데이터를 남기려면 **영구 볼륨**이 필요합니다. 사용자는 PV(실제 저장소)를 직접 만들지 않고 **PVC(저장 공간 요청서)** 만 제출하면, 클러스터가 알맞은 저장소를 자동으로 연결해 줍니다.

`$NS` 네임스페이스에 `pvc-local` 이름의 PVC 를 만드세요.
- 용량: `1Gi`
- 접근 모드: `ReadWriteOnce` (한 노드에서 읽고 쓰기)
(PV 는 직접 만들지 않아도 됩니다. 기본 StorageClass 가 자동으로 만들어 줍니다)', hint='YAML 의 `kind: PersistentVolumeClaim` 에서 `spec.accessModes` 에 접근 모드를, `spec.resources.requests.storage` 에 용량을 씁니다. `storageClassName` 을 생략하면 클러스터 기본 StorageClass 가 쓰입니다.', solution='kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-local
  namespace: $NS
spec:
  accessModes:
  - ReadWriteOnce        # 한 노드에서 읽기/쓰기
  resources:
    requests:
      storage: 1Gi       # 요청 용량
EOF' WHERE quest_set_id = 13 AND order_index = 1;
UPDATE quest SET title='PVC 를 Pod 에 마운트하기', description='PVC 는 Pod 가 볼륨으로 연결해야 실제로 쓸 수 있습니다.

`pvc-local` PVC 를 컨테이너의 `/data` 경로에 마운트한 Pod 를 `$NS` 네임스페이스에 만드세요. Pod 이름은 `pvc-pod`, 이미지는 `nginx` 입니다.', hint='두 곳을 함께 씁니다.
- `spec.volumes` : `persistentVolumeClaim.claimName` 으로 어느 PVC 인지 지정
- `containers[].volumeMounts` : 그 볼륨을 컨테이너의 어느 경로(`mountPath`)에 붙일지 지정
두 곳의 볼륨 `name` 이 같아야 연결됩니다.', solution='kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: data-vol
      mountPath: /data
  volumes:
  - name: data-vol
    persistentVolumeClaim:
      claimName: pvc-local   # 어느 PVC 를 쓸지
EOF' WHERE quest_set_id = 13 AND order_index = 2;
UPDATE quest SET title='PVC 상태 확인하기', description='PVC 가 저장소와 연결(`Bound`)되었는지 확인하는 것은 스토리지 문제의 첫 점검입니다.

`pvc-local` PVC 의 상태를 `/tmp/pvc_status.txt` 에 저장하세요. (Pod 가 사용하기 전에는 `Pending` 일 수 있고, 사용하면 `Bound` 가 됩니다)', hint='`kubectl get pvc <이름> -n <네임스페이스>` 의 `STATUS` 열이 상태입니다. `Bound` 는 저장소와 연결됨, `Pending` 은 연결 대기 중입니다. 결과를 `>` 로 저장하세요.', solution='kubectl get pvc pvc-local -n $NS > /tmp/pvc_status.txt' WHERE quest_set_id = 13 AND order_index = 3;
UPDATE quest SET title='마운트한 볼륨에 데이터 저장하기', description='볼륨에 쓴 파일은 Pod 가 다시 만들어져도 남습니다. 직접 파일을 만들어 확인합니다.

`pvc-pod` 의 `/data` 디렉토리에 `hello.txt` 파일을 만들고, 내용으로 `persisted` 를 쓰세요.', hint='`kubectl exec <Pod> -n <네임스페이스> -- sh -c "<명령>"` 으로 Pod 안에서 쉘 명령을 실행합니다. `sh -c` 는 따옴표 안의 문자열 전체를 하나의 명령으로 실행하며, 그 안에서 `>` 로 파일에 쓸 수 있습니다.', solution='kubectl exec pvc-pod -n $NS -- sh -c ''echo persisted > /data/hello.txt''

# -- 뒤가 Pod 안에서 실행할 명령
# sh -c ''...'' : 따옴표 안의 명령(리다이렉션 포함)을 Pod 안의 쉘이 실행' WHERE quest_set_id = 13 AND order_index = 4;
UPDATE quest SET title='Service 를 만들고 port-forward 로 접근하기', description='클러스터 안의 Service 에는 밖에서 바로 접속할 수 없습니다. 개발·디버깅 때는 `port-forward` 로 내 터미널의 포트를 Service 에 임시로 연결해 접속합니다.

1. `$NS` 에 `nginx` Pod 와 그 Service(포트 80)를 만듭니다.
2. `port-forward` 로 로컬 `9090` 포트를 Service 의 `80` 포트에 연결합니다.
3. `curl` 로 응답을 확인해 `/tmp/pf_result.txt` 에 저장합니다.', hint='`kubectl port-forward svc/<서비스이름> <로컬포트>:<서비스포트> -n <네임스페이스>` 는 실행하는 동안 계속 떠 있어야 해서 끝에 `&` 를 붙여 **백그라운드**로 실행합니다. 연결이 되는 데 몇 초 걸리니 `sleep 3` 뒤에 `curl -s localhost:9090`(`-s` 는 진행 표시 끄기)으로 확인하세요.', solution='kubectl run pf-nginx --image=nginx -n $NS && kubectl expose pod pf-nginx --port=80 -n $NS && kubectl wait --for=condition=ready pod/pf-nginx -n $NS --timeout=60s && (kubectl port-forward svc/pf-nginx 9090:80 -n $NS > /dev/null 2>&1 &) && sleep 3 && curl -s localhost:9090 > /tmp/pf_result.txt

# expose : Pod 를 Service 로 노출, wait : Pod 가 Ready 가 될 때까지 대기
# port-forward 로컬:서비스 : 로컬 9090 → Service 80' WHERE quest_set_id = 13 AND order_index = 5;
UPDATE quest SET title='Pod 로그로 장애 원인 찾기', description='Pod 가 계속 죽었다 살아나는 상태(`CrashLoopBackOff`)일 때는 **로그**에 원인이 남습니다.

`$NS` 네임스페이스에 잘못된 명령 때문에 `CrashLoopBackOff` 가 된 Pod `crash-pod` 가 있습니다. 로그를 확인해 에러 메시지를 `/tmp/crash_log.txt` 에 저장하세요.', hint='`kubectl logs <Pod이름> -n <네임스페이스>` 로 로그를 봅니다. 재시작한 직후에는 현재 컨테이너 로그가 비어 있을 수 있어, 이때는 `--previous`(직전에 죽은 컨테이너의 로그)를 씁니다. 에러 출력까지 담으려면 `2>&1` 을 붙이세요.', solution='kubectl logs crash-pod -n $NS > /tmp/crash_log.txt 2>&1 || kubectl logs crash-pod -n $NS --previous > /tmp/crash_log.txt 2>&1

# --previous : 직전에 죽은 컨테이너의 로그
# || : 앞 명령이 실패하면 뒤 명령 실행' WHERE quest_set_id = 13 AND order_index = 6;
UPDATE quest SET title='describe 로 Pod 상태와 이벤트 확인하기', description='`describe` 는 Pod 의 상태, 재시작 횟수, 그리고 **이벤트**(무슨 일이 있었는지)를 보여 줍니다. 로그에 안 남는 원인(이미지 못 받음, 스케줄 실패 등)을 찾을 수 있습니다.

`$NS` 네임스페이스의 `crash-pod` Pod 의 상세 정보를 `/tmp/describe_result.txt` 에 저장하세요. 저장한 뒤 `Events` 부분에서 문제 원인을 읽어 보세요.', hint='`kubectl describe pod <Pod이름> -n <네임스페이스>` 입니다. 출력 아래쪽의 `State`(현재 상태), `Last State`(직전 상태와 종료 코드), `Events`(시간순 사건)를 주목하세요.', solution='kubectl describe pod crash-pod -n $NS > /tmp/describe_result.txt

# 확인할 곳: State / Last State(Exit Code) / Events' WHERE quest_set_id = 13 AND order_index = 7;
UPDATE quest SET title='emptyDir 로 컨테이너끼리 파일 공유하기', description='한 Pod 안의 여러 컨테이너는 **emptyDir** 볼륨으로 파일을 주고받을 수 있습니다. emptyDir 는 Pod 가 사는 동안만 유지되는 임시 공간입니다(로그 수집 사이드카 패턴 등).

`$NS` 에 Pod `shared-pod` 를 만드세요. `writer`, `reader` 두 컨테이너(둘 다 `busybox`)가 `/shared` 디렉토리를 공유해야 합니다.', hint='`spec.volumes` 에 `emptyDir: {}` 볼륨을 정의하고, **두 컨테이너 모두** `volumeMounts` 에 같은 볼륨 이름과 `mountPath: /shared` 를 넣습니다. busybox 는 바로 종료되므로 `command` 에 `sleep 3600` 을 넣어 계속 실행되게 하세요.', solution='kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: shared-pod
  namespace: $NS
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sh", "-c", "echo hello > /shared/data.txt && sleep 3600"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  - name: reader
    image: busybox
    command: ["sh", "-c", "sleep 3600"]   # 계속 떠 있도록 대기
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  volumes:
  - name: shared-vol
    emptyDir: {}          # Pod 와 수명이 같은 임시 볼륨
EOF' WHERE quest_set_id = 13 AND order_index = 8;
