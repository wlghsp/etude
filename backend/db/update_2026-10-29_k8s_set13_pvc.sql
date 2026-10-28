-- 세트 13(k8s 스토리지)을 학습자가 PersistentVolume을 만들 수 없는 제한 권한에서 풀 수 있게 PVC 중심(동적 프로비저닝)으로 재설계.
-- 원본은 03_quest_set13.sql. 이미 떠 있는 DB에는 이 파일을 한 번 실행한다. 대상은 (quest_set_id, order_index)로 지정하고 quest.id는 바꾸지 않는다.

UPDATE quest SET title='PersistentVolumeClaim 생성하기', description='$NS 네임스페이스에 pvc-local 이름의 PVC를 생성하세요. 용량 1Gi, 접근 모드 ReadWriteOnce 로 요청하세요. (PV는 직접 만들지 않아도 됩니다. 클러스터의 기본 StorageClass가 PVC에 맞춰 자동으로 만들어 줍니다.)', hint='kind: PersistentVolumeClaim 으로 작성하고 resources.requests.storage 로 용량을 지정합니다. storageClassName 을 생략하면 기본 StorageClass 를 씁니다.', solution='kubectl apply -f - <<EOF
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
EOF', setup_cmd=NULL, grade_cmd='["sh", "-c", "kubectl get pvc pvc-local -n $NS | grep -q pvc-local"]' WHERE quest_set_id = 13 AND order_index = 1;
UPDATE quest SET title='PVC를 Pod에 마운트하기', description='pvc-local PVC를 /data 경로에 마운트한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 pvc-pod, 이미지는 nginx 로 하세요.', hint='volumes.persistentVolumeClaim.claimName 으로 PVC를 참조하고 volumeMounts 로 마운트 경로를 지정합니다.', solution='kubectl apply -f - <<EOF
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
EOF', setup_cmd='["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\nEOF"]', grade_cmd='["sh", "-c", "kubectl get pod pvc-pod -n $NS | grep -q pvc-pod"]' WHERE quest_set_id = 13 AND order_index = 2;
UPDATE quest SET title='PVC 상태 확인하기', description='pvc-local PVC가 Bound 상태인지 확인하고 결과를 /tmp/pvc_status.txt 에 저장하세요. (이 PVC는 Pod가 사용하기 전까지는 Pending 상태일 수 있습니다.)', hint='kubectl get pvc -n <namespace> 로 상태를 확인합니다. STATUS 컬럼이 Bound 여야 합니다.', solution='kubectl get pvc pvc-local -n $NS > /tmp/pvc_status.txt', setup_cmd='["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: pvc-pod\\n  namespace: $NS\\nspec:\\n  containers:\\n  - name: nginx\\n    image: nginx\\n    volumeMounts:\\n    - name: data-vol\\n      mountPath: /data\\n  volumes:\\n  - name: data-vol\\n    persistentVolumeClaim:\\n      claimName: pvc-local\\nEOF\\nkubectl wait --for=condition=ready pod/pvc-pod -n $NS --timeout=90s"]', grade_cmd='["sh", "-c", "grep -q Bound /tmp/pvc_status.txt"]' WHERE quest_set_id = 13 AND order_index = 3;
UPDATE quest SET title='마운트한 볼륨에 데이터 저장하기', description='pvc-pod 의 /data 에 hello.txt 파일을 만들고, 내용으로 persisted 를 저장하세요.', hint='kubectl exec <pod> -n <namespace> -- sh -c "명령" 으로 Pod 안에서 명령을 실행할 수 있습니다.', solution='kubectl exec pvc-pod -n $NS -- sh -c ''echo persisted > /data/hello.txt''', setup_cmd='["sh", "-c", "kubectl apply -f - <<EOF\\napiVersion: v1\\nkind: PersistentVolumeClaim\\nmetadata:\\n  name: pvc-local\\n  namespace: $NS\\nspec:\\n  accessModes:\\n  - ReadWriteOnce\\n  resources:\\n    requests:\\n      storage: 1Gi\\n---\\napiVersion: v1\\nkind: Pod\\nmetadata:\\n  name: pvc-pod\\n  namespace: $NS\\nspec:\\n  containers:\\n  - name: nginx\\n    image: nginx\\n    volumeMounts:\\n    - name: data-vol\\n      mountPath: /data\\n  volumes:\\n  - name: data-vol\\n    persistentVolumeClaim:\\n      claimName: pvc-local\\nEOF\\nkubectl wait --for=condition=ready pod/pvc-pod -n $NS --timeout=90s"]', grade_cmd='["sh", "-c", "kubectl exec pvc-pod -n $NS -- cat /data/hello.txt | grep -q persisted"]' WHERE quest_set_id = 13 AND order_index = 4;
