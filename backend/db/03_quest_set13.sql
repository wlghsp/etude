-- 세트 13: k8s 스토리지와 네트워크 (order 1~8)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
-- 13.1~13.4는 학습자가 PersistentVolume(클러스터 범위)을 만들 수 없는 제한 권한에서 풀 수 있게 PVC 중심으로 구성한다 (동적 프로비저닝)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (13, 1, 'PersistentVolumeClaim 생성하기',
   '$NS 네임스페이스에 pvc-local 이름의 PVC를 생성하세요. 용량 1Gi, 접근 모드 ReadWriteOnce 로 요청하세요. (PV는 직접 만들지 않아도 됩니다. 클러스터의 기본 StorageClass가 PVC에 맞춰 자동으로 만들어 줍니다.)',
   'kind: PersistentVolumeClaim 으로 작성하고 resources.requests.storage 로 용량을 지정합니다. storageClassName 을 생략하면 기본 StorageClass 를 씁니다.',
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
   NULL,
   '["sh", "-c", "kubectl get pvc pvc-local -n $NS | grep -q pvc-local"]'),

  (13, 2, 'PVC를 Pod에 마운트하기',
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
   '["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\nEOF"]',
   '["sh", "-c", "kubectl get pod pvc-pod -n $NS | grep -q pvc-pod"]'),

  (13, 3, 'PVC 상태 확인하기',
   'pvc-local PVC가 Bound 상태인지 확인하고 결과를 /tmp/pvc_status.txt 에 저장하세요. (이 PVC는 Pod가 사용하기 전까지는 Pending 상태일 수 있습니다.)',
   'kubectl get pvc -n <namespace> 로 상태를 확인합니다. STATUS 컬럼이 Bound 여야 합니다.',
   'kubectl get pvc pvc-local -n $NS > /tmp/pvc_status.txt',
   '["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: pvc-pod\\n  namespace: $NS\\nspec:\\n  containers:\\n  - name: nginx\\n    image: nginx\\n    volumeMounts:\\n    - name: data-vol\\n      mountPath: /data\\n  volumes:\\n  - name: data-vol\\n    persistentVolumeClaim:\\n      claimName: pvc-local\\nEOF\\nkubectl wait --for=condition=ready pod/pvc-pod -n $NS --timeout=90s"]',
   '["sh", "-c", "grep -q Bound /tmp/pvc_status.txt"]'),

  (13, 4, '마운트한 볼륨에 데이터 저장하기',
   'pvc-pod 의 /data 에 hello.txt 파일을 만들고, 내용으로 persisted 를 저장하세요.',
   'kubectl exec <pod> -n <namespace> -- sh -c "명령" 으로 Pod 안에서 명령을 실행할 수 있습니다.',
   'kubectl exec pvc-pod -n $NS -- sh -c ''echo persisted > /data/hello.txt''',
   '["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: pvc-pod\\n  namespace: $NS\\nspec:\\n  containers:\\n  - name: nginx\\n    image: nginx\\n    volumeMounts:\\n    - name: data-vol\\n      mountPath: /data\\n  volumes:\\n  - name: data-vol\\n    persistentVolumeClaim:\\n      claimName: pvc-local\\nEOF\\nkubectl wait --for=condition=ready pod/pvc-pod -n $NS --timeout=90s"]',
   '["sh", "-c", "kubectl exec pvc-pod -n $NS -- cat /data/hello.txt | grep -q persisted"]'),

  (13, 5, 'Service 생성하고 port-forward로 접근하기',
   '$NS 네임스페이스에 nginx Pod와 Service를 생성한 뒤, kubectl port-forward 로 로컬 9090 포트를 Service 80 포트에 연결하고 curl로 응답을 확인해서 /tmp/pf_result.txt 에 저장하세요.',
   'kubectl port-forward svc/<서비스명> <로컬포트>:<서비스포트> -n <namespace> & 로 백그라운드 실행 후 curl localhost:<로컬포트> 로 확인합니다.',
   'kubectl run pf-nginx --image=nginx -n $NS && kubectl expose pod pf-nginx --port=80 -n $NS && kubectl wait --for=condition=ready pod/pf-nginx -n $NS --timeout=60s && (kubectl port-forward svc/pf-nginx 9090:80 -n $NS > /dev/null 2>&1 &) && sleep 3 && curl -s localhost:9090 > /tmp/pf_result.txt',
   NULL,
   '["sh", "-c", "grep -qiE \\\"nginx|html\\\" /tmp/pf_result.txt"]'),

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
   '["sh", "-c", "grep -qE \\\"Events|State\\\" /tmp/describe_result.txt"]'),

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
