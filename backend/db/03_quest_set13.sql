-- 세트 13: k8s 스토리지와 네트워크 (order 1~8)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (13, 1, 'PersistentVolume 생성하기',
   '$NS 네임스페이스에 pv-local 이름의 PersistentVolume을 생성하세요. 용량은 1Gi, 접근 모드는 ReadWriteOnce, hostPath는 /tmp/pv-data 로 설정하세요.',
   'PersistentVolume은 네임스페이스에 속하지 않는 클러스터 레벨 리소스입니다. kind: PersistentVolume 으로 작성합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local-$NS
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /tmp/pv-data
  claimRef:
    namespace: $NS
    name: pvc-local
EOF',
   NULL,
   '["sh", "-c", "kubectl get pv pv-local-$NS | grep -q pv-local"]'),

  (13, 2, 'PersistentVolumeClaim 생성하기',
   '$NS 네임스페이스에 pvc-local 이름의 PVC를 생성하세요. 용량 1Gi, 접근 모드 ReadWriteOnce 로 요청하세요.',
   'kind: PersistentVolumeClaim 으로 작성하고 resources.requests.storage 로 용량을 지정합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-local
  namespace: $NS
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF',
   '["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolume\\nmetadata:\\n  name: pv-local-$NS\\nspec:\\n  capacity:\\n    storage: 1Gi\\n  accessModes:\\n  - ReadWriteOnce\\n  hostPath:\\n    path: /tmp/pv-data\\n  claimRef:\\n    namespace: $NS\\n    name: pvc-local\\nEOF"]',
   '["sh", "-c", "kubectl get pvc pvc-local -n $NS | grep -q pvc-local"]'),

  (13, 3, 'PVC 상태 확인하기',
   'pvc-local PVC가 Bound 상태인지 확인하고 결과를 /tmp/pvc_status.txt 에 저장하세요.',
   'kubectl get pvc -n <namespace> 로 상태를 확인합니다. STATUS 컬럼이 Bound 여야 합니다.',
   'kubectl get pvc pvc-local -n $NS > /tmp/pvc_status.txt',
   '["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolume\\nmetadata:\\n  name: pv-local-$NS\\nspec:\\n  capacity:\\n    storage: 1Gi\\n  accessModes:\\n  - ReadWriteOnce\\n  hostPath:\\n    path: /tmp/pv-data\\n  claimRef:\\n    namespace: $NS\\n    name: pvc-local\\nEOF\\nkubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\nEOF"]',
   '["sh", "-c", "grep -q \\\"Bound\\\" /tmp/pvc_status.txt"]'),

  (13, 4, 'PVC를 Pod에 마운트하기',
   'pvc-local PVC를 /data 경로에 마운트한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 pvc-pod, 이미지는 nginx 로 하세요.',
   'volumes.persistentVolumeClaim.claimName 으로 PVC를 참조하고 volumeMounts 로 마운트 경로를 지정합니다.',
   'kubectl apply -f - <<EOF
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
      claimName: pvc-local
EOF',
   '["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolume\\nmetadata:\\n  name: pv-local-$NS\\nspec:\\n  capacity:\\n    storage: 1Gi\\n  accessModes:\\n  - ReadWriteOnce\\n  hostPath:\\n    path: /tmp/pv-data\\n  claimRef:\\n    namespace: $NS\\n    name: pvc-local\\nEOF\\nkubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\nEOF"]',
   '["sh", "-c", "kubectl get pod pvc-pod -n $NS | grep -q pvc-pod"]'),

  (13, 5, 'Service 생성하고 port-forward로 접근하기',
   '$NS 네임스페이스에 nginx Pod와 Service를 생성한 뒤, kubectl port-forward 로 로컬 9090 포트를 Service 80 포트에 연결하고 curl로 응답을 확인해서 /tmp/pf_result.txt 에 저장하세요.',
   'kubectl port-forward svc/<서비스명> <로컬포트>:<서비스포트> -n <namespace> & 로 백그라운드 실행 후 curl localhost:<로컬포트> 로 확인합니다.',
   'kubectl run pf-nginx --image=nginx -n $NS && kubectl expose pod pf-nginx --port=80 -n $NS && sleep 3 && kubectl port-forward svc/pf-nginx 9090:80 -n $NS & sleep 2 && curl -s localhost:9090 > /tmp/pf_result.txt',
   NULL,
   '["sh", "-c", "grep -qi \\\"nginx\\\\|html\\\" /tmp/pf_result.txt"]'),

  (13, 6, 'Pod 로그로 문제 진단하기',
   '$NS 네임스페이스에 잘못된 명령어로 CrashLoopBackOff 상태가 된 Pod가 있습니다. 로그를 확인하고 에러 메시지를 /tmp/crash_log.txt 에 저장하세요.',
   'kubectl logs <pod명> -n <namespace> 로 로그를 확인합니다. 이전 컨테이너 로그는 --previous 옵션을 사용합니다.',
   'kubectl logs crash-pod -n $NS > /tmp/crash_log.txt 2>&1 || kubectl logs crash-pod -n $NS --previous > /tmp/crash_log.txt 2>&1',
   '["sh", "-c", "kubectl run crash-pod --image=ubuntu --restart=Always -n $NS -- sh -c \\\"echo ERROR: invalid config && exit 1\\\" 2>/dev/null; true"]',
   '["sh", "-c", "test -s /tmp/crash_log.txt"]'),

  (13, 7, 'kubectl describe로 Pod 상태 진단하기',
   '$NS 네임스페이스의 crash-pod Pod 상세 정보를 확인하고 /tmp/describe_result.txt 에 저장하세요. Events 섹션에서 문제 원인을 찾아보세요.',
   'kubectl describe pod <pod명> -n <namespace> 로 이벤트와 상태를 상세히 확인합니다.',
   'kubectl describe pod crash-pod -n $NS > /tmp/describe_result.txt',
   '["sh", "-c", "kubectl run crash-pod --image=ubuntu --restart=Always -n $NS -- sh -c \\\"echo ERROR && exit 1\\\" 2>/dev/null; true"]',
   '["sh", "-c", "grep -q \\\"Events\\\\|State\\\" /tmp/describe_result.txt"]'),

  (13, 8, 'EmptyDir 볼륨으로 컨테이너 간 파일 공유하기',
   'emptyDir 볼륨을 사용해서 두 컨테이너가 /shared 디렉토리를 공유하는 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 shared-pod, 컨테이너는 writer(busybox)와 reader(busybox)로 구성하세요.',
   'emptyDir 볼륨은 Pod 생명주기와 함께하는 임시 볼륨입니다. 두 컨테이너 모두 volumeMounts 에 같은 볼륨을 마운트합니다.',
   'kubectl apply -f - <<EOF
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
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  volumes:
  - name: shared-vol
    emptyDir: {}
EOF',
   NULL,
   '["sh", "-c", "kubectl get pod shared-pod -n $NS | grep -q shared-pod"]');
