-- 세트 33(k8s 쉬운 장애 고치기) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set33.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 33, 'k8s 쉬운 장애 고치기', '이미지 태그·주소 오류 고치기, ConfigMap 변경 후 재시작, Pod 개수 늘리기, 없는 StorageClass 때문에 Pending 인 PVC 를 기본값으로 고치기, 실패한 배포 되돌리기, 컨테이너 2개짜리 Pod 와 kubectl 정렬 옵션까지 현장에서 가장 자주 만나는 쉬운 장애와 기본 작업을 직접 고칩니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 33);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  1, '이미지 태그가 틀려 시작되지 않는 Pod 고치기',
   '`$NS` 네임스페이스의 Deployment `web` 을 배포했는데 Pod 가 시작되지 않습니다. 이미지를 받아 오지 못하는 문제입니다. 이미지는 `이름:태그` 형태이고, 이 Deployment 는 이름(`nginx`)은 맞는데 **태그(`:` 뒤의 버전)가 틀렸습니다.**

원인을 찾아 고치세요. 올바른 이미지는 `nginx:latest` 입니다.

완료 조건: `web` Deployment 가 정상 실행(Available)되어야 합니다.',
   '조사 순서입니다.
1) `kubectl get pods -n $NS` : 상태가 `ErrImagePull` 또는 `ImagePullBackOff` 인지 확인
2) `kubectl describe pod <Pod이름> -n $NS` : 아래쪽 Events 에서 `not found` 같은 이유 확인
3) `kubectl set image deployment/web <컨테이너이름>=nginx:latest -n $NS` 로 이미지를 바꿉니다. (`set image` 는 `배포이름 컨테이너이름=새이미지` 형식이고, 이미지를 바꾸면 새 Pod 가 자동으로 다시 만들어집니다)
컨테이너 이름은 `kubectl get deployment web -n $NS -o jsonpath=''{.spec.template.spec.containers[*].name}''` 로 확인합니다.',
   '# 1) 증상 확인: ImagePullBackOff
kubectl get pods -n $NS
# 2) 원인 확인: Events 의 "manifest for nginx:lates not found"
kubectl describe pod -l app=web -n $NS | tail -n 8
# 3) 이미지 태그 고치기 (컨테이너 이름은 nginx)
kubectl set image deployment/web nginx=nginx:latest -n $NS
# 4) 정상 실행 확인
kubectl rollout status deployment/web -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=nginx:lates -n $NS >/dev/null 2>&1; true"]',
   '["sh", "-c", "img=$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}''); case \\"$img\\" in nginx|nginx:latest) ;; *) exit 1;; esac; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  2, '이미지 주소가 틀려 시작되지 않는 Pod 고치기',
   '`$NS` 네임스페이스의 Deployment `api` 의 Pod 가 시작되지 않습니다. 이미지 주소는 `레지스트리주소/경로/이름:태그` 형태이고, 이 Deployment 는 **레지스트리 주소(맨 앞 `myregistry.invalid`)가 존재하지 않는 곳**을 가리킵니다. Docker Hub 의 공식 이미지는 주소를 생략하고 `nginx` 처럼 쓰면 됩니다.

원인을 찾아 고치세요. 올바른 이미지는 `nginx` 입니다.

완료 조건: `api` Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl describe pod -l app=api -n $NS` 의 Events 에서 이미지를 받는 곳(주소)과 실패 이유를 확인합니다. (`-l app=api` 는 라벨이 `app=api` 인 Pod 만 고르는 옵션입니다)
2) `kubectl set image deployment/api <컨테이너이름>=nginx -n $NS` 로 이미지 전체를 바르게 바꿉니다. 컨테이너 이름은 `kubectl get deployment api -n $NS -o jsonpath=''{.spec.template.spec.containers[*].name}''` 로 확인합니다.',
   '# 1) 원인 확인: Events 에서 존재하지 않는 레지스트리 주소(myregistry.invalid) 확인
kubectl describe pod -l app=api -n $NS | tail -n 8
# 2) 이미지 주소 전체를 올바르게 교체 (컨테이너 이름은 nginx)
kubectl set image deployment/api nginx=nginx -n $NS
kubectl rollout status deployment/api -n $NS',
   '["sh", "-c", "kubectl create deployment api --image=myregistry.invalid/library/nginx:latest -n $NS >/dev/null 2>&1; true"]',
   '["sh", "-c", "img=$(kubectl get deploy api -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}''); case \\"$img\\" in nginx|nginx:latest) ;; *) exit 1;; esac; kubectl wait --for=condition=Available deployment/api -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  3, 'ConfigMap 을 고친 뒤 Pod 를 다시 시작해 새 값 적용하기',
   '`$NS` 네임스페이스의 Deployment `web` 은 ConfigMap `app-config` 의 `MODE` 값을 **환경변수**로 읽습니다. 방금 ConfigMap 의 `MODE` 를 `new` 로 바꿨는데, 실행 중인 Pod 는 여전히 옛 값을 쓰고 있습니다. 환경변수는 **Pod 가 시작될 때 한 번** 읽기 때문입니다.

Pod 를 다시 시작해서 새 값 `new` 를 쓰게 하세요.

완료 조건: `web` 의 모든 Pod 안에서 환경변수 `MODE` 가 `new` 이고 Deployment 가 정상 실행되어야 합니다.',
   '1) 현재 값 확인: `kubectl exec deploy/web -n $NS -- printenv MODE` (`exec` 는 Pod 안에서 명령을 실행하고, `printenv 이름` 은 그 환경변수 값을 출력합니다)
2) `kubectl rollout restart deployment/web -n $NS` 는 같은 설정으로 Pod 를 **하나씩 새로 만들어** 교체합니다. (서비스 중단 없이 다시 시작하는 방법입니다)
3) `kubectl rollout status deployment/web -n $NS` 로 끝날 때까지 기다립니다.',
   '# 옛 값 확인
kubectl exec deploy/web -n $NS -- printenv MODE   # old
# Pod 를 새로 만들어 교체 (환경변수는 시작할 때 읽는다)
kubectl rollout restart deployment/web -n $NS
kubectl rollout status deployment/web -n $NS
# 새 값 확인
kubectl exec deploy/web -n $NS -- printenv MODE   # new',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=MODE=old -n $NS >/dev/null 2>&1; kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl set env deployment/web --from=configmap/app-config -n $NS >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; kubectl create configmap app-config --from-literal=MODE=new -n $NS --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1; true"]',
   '["sh", "-c", "kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1 || exit 1; pods=$(kubectl get pods -n $NS -l app=web --no-headers | awk ''$3==\\"Running\\" {print $1}''); [ -n \\"$pods\\" ] || exit 1; for p in $pods; do [ \\"$(kubectl exec $p -n $NS -- printenv MODE)\\" = new ] || exit 1; done"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  4, '접속이 몰려 Pod 개수 늘리기',
   '`$NS` 네임스페이스의 Deployment `web` 은 지금 Pod 가 **1개**입니다. 접속이 늘어 1개로는 감당이 안 되니 **3개**로 늘려야 합니다. Pod 개수는 Deployment 의 `replicas` 값이고, 값을 바꾸면 ReplicaSet 이 부족한 만큼 Pod 를 만들어 줍니다.

Deployment `web` 의 Pod 를 3개로 늘리세요.

완료 조건: `web` 의 사용 가능한(Available) Pod 가 3개여야 합니다.',
   '`kubectl scale deployment/<이름> --replicas=<개수> -n $NS` 입니다. (`--replicas` 는 원하는 Pod 개수입니다) 늘린 뒤 `kubectl get pods -n $NS` 로 `Running` 이 3개인지 확인합니다. 개수는 `kubectl get deployment web -n $NS` 의 `READY` 열(`3/3`)에서도 볼 수 있습니다.',
   '# 현재 1개 확인
kubectl get deployment web -n $NS
# 3개로 늘리기
kubectl scale deployment/web --replicas=3 -n $NS
# 3/3 이 될 때까지 확인
kubectl get deployment web -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=nginx --replicas=1 -n $NS >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; true"]',
   '["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.replicas}'')\\" = 3 ] && kubectl wait --for=jsonpath=''{.status.availableReplicas}''=3 deployment/web -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  5, '없는 StorageClass 를 지정해 Pending 인 PVC 를 기본값으로 고치기',
   'PVC(저장 공간 요청서)는 **StorageClass**(어떤 종류의 저장소를 어떻게 만들지 정해 둔 규칙)를 보고 저장소(PV)를 자동으로 만듭니다. `$NS` 네임스페이스의 PVC `data` 는 `fast-ssd` 라는 StorageClass 를 지정했는데, 이 클러스터에는 그런 이름이 없어서 저장소가 만들어지지 않습니다. 이 클러스터에는 **기본(default) StorageClass** 가 있어서, PVC 에서 `storageClassName` 을 **쓰지 않으면** 자동으로 기본값이 적용됩니다.

1. PVC `data` 가 왜 안 되는지 확인합니다.
2. `storageClassName` 을 쓰지 않은 PVC `data` 로 다시 만드세요. (용량 `1Gi`, 접근 모드 `ReadWriteOnce` 는 그대로)

완료 조건: PVC `data` 의 StorageClass 가 `fast-ssd` 가 아니고 용량이 `1Gi` 여야 합니다. (Pod 가 쓰기 전까지는 `Pending` 으로 보일 수 있습니다. 그건 정상입니다)',
   '1) `kubectl describe pvc data -n $NS` 의 Events 에서 `storageclass ... not found` 를 확인합니다.
2) PVC 의 `storageClassName` 은 **만든 뒤에는 바꿀 수 없어서**, `kubectl delete pvc data -n $NS` 로 지우고 같은 이름으로 다시 만듭니다.
3) YAML 에서 `spec.storageClassName` 줄을 **빼고** `kubectl apply -f` 로 적용합니다. (`kubectl get pvc data -n $NS -o jsonpath=''{.spec.storageClassName}''` 로 자동 적용된 기본 StorageClass 이름을 볼 수 있습니다)',
   '# 1) 원인: storageclass "fast-ssd" not found
kubectl describe pvc data -n $NS | tail -n 5
# 2) storageClassName 은 만든 뒤 못 바꾸므로 지우고 다시 만든다 (storageClassName 줄을 뺀다 → 기본값 적용)
kubectl delete pvc data -n $NS
kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
# 3) 기본 StorageClass 가 적용됐는지 확인
kubectl get pvc data -n $NS -o jsonpath=''{.spec.storageClassName}''',
   '["sh", "-c", "printf ''%s\\\\n'' ''apiVersion: v1'' ''kind: PersistentVolumeClaim'' ''metadata:'' ''  name: data'' ''spec:'' ''  accessModes:'' ''  - ReadWriteOnce'' ''  storageClassName: fast-ssd'' ''  resources:'' ''    requests:'' ''      storage: 1Gi'' | kubectl apply -n $NS -f - >/dev/null 2>&1; true"]',
   '["sh", "-c", "sc=$(kubectl get pvc data -n $NS -o jsonpath=''{.spec.storageClassName}''); [ -n \\"$sc\\" ] && [ \\"$sc\\" != fast-ssd ] && [ \\"$(kubectl get pvc data -n $NS -o jsonpath=''{.spec.resources.requests.storage}'')\\" = 1Gi ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  6, '새 버전 배포가 실패했을 때 이전 버전으로 되돌리기',
   '`$NS` 네임스페이스의 Deployment `web` 에 새 버전(`nginx:no-such-tag`)을 배포했더니 새 Pod 가 시작되지 않습니다. 이전 버전은 정상이었습니다. 이럴 때는 원인을 고치기 전에 **일단 이전 정상 버전으로 되돌리는 것**이 가장 빠릅니다. Deployment 는 배포할 때마다 이력(리비전)을 남겨서 되돌릴 수 있습니다.

`web` 을 이전 버전으로 되돌리세요.

완료 조건: `web` 의 이미지가 `nginx` 로 돌아가고 Deployment 가 정상 실행(Available)되어야 합니다.',
   '1) `kubectl rollout history deployment/web -n $NS` : 배포 이력(리비전)을 봅니다.
2) `kubectl rollout undo deployment/web -n $NS` : 직전 리비전으로 되돌립니다. (`--to-revision=<번호>` 를 붙이면 원하는 리비전으로 되돌립니다)
3) `kubectl rollout status deployment/web -n $NS` 로 끝날 때까지 기다립니다.',
   '# 이력 확인 (리비전 1: 정상, 2: 잘못된 태그)
kubectl rollout history deployment/web -n $NS
# 직전 정상 버전으로 되돌리기
kubectl rollout undo deployment/web -n $NS
kubectl rollout status deployment/web -n $NS',
   '["sh", "-c", "kubectl create deployment web --image=nginx -n $NS >/dev/null 2>&1; kubectl rollout status deployment/web -n $NS --timeout=90s >/dev/null 2>&1; kubectl set image deployment/web nginx=nginx:no-such-tag -n $NS >/dev/null 2>&1; true"]',
   '["sh", "-c", "img=$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}''); case \\"$img\\" in nginx|nginx:latest) ;; *) exit 1;; esac; kubectl wait --for=condition=Available deployment/web -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  7, '컨테이너 2개가 함께 실행되는 Pod 만들기',
   'Pod 는 컨테이너 하나만 담는 것이 아니라, **같은 Pod 안에 여러 컨테이너**를 함께 둘 수 있습니다. 같은 Pod 의 컨테이너들은 같은 네트워크(`localhost`)를 쓰고 항상 같은 노드에서 함께 실행됩니다. (예: 앱 옆에서 로그를 모으는 보조 컨테이너)

`$NS` 네임스페이스에 Pod `duo` 를 만드세요.
- 첫 번째 컨테이너: 이름 `web`, 이미지 `nginx`
- 두 번째 컨테이너: 이름 `helper`, 이미지 `busybox`, 명령 `sleep 3600` (`busybox` 는 명령이 없으면 바로 종료되므로 필요합니다)

완료 조건: Pod `duo` 의 컨테이너가 2개이고, 모두 준비(Ready)되어야 합니다.',
   '`kubectl run duo --image=nginx -n $NS --dry-run=client -o yaml > duo.yaml` 로 YAML 뼈대를 만들고(`--dry-run=client` 는 실제로 만들지 않고 출력만 하는 옵션), `spec.containers` 목록에 두 번째 항목을 추가한 뒤 `kubectl apply -f duo.yaml` 로 만듭니다. 컨테이너 항목은 `- name: ...`, `image: ...`, `command: ["sleep", "3600"]` 로 씁니다. 준비 상태는 `kubectl get pod duo -n $NS` 의 `READY` 열이 `2/2` 인지 보면 됩니다.',
   'kubectl apply -n $NS -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: duo
spec:
  containers:
  - name: web
    image: nginx
  - name: helper
    image: busybox
    command: ["sleep", "3600"]
EOF
# READY 가 2/2 인지 확인
kubectl get pod duo -n $NS',
   NULL,
   '["sh", "-c", "[ \\"$(kubectl get pod duo -n $NS -o jsonpath=''{.spec.containers[*].name}'' | wc -w)\\" -eq 2 ] && imgs=$(kubectl get pod duo -n $NS -o jsonpath=''{.spec.containers[*].image}'') && echo \\"$imgs\\" | grep -q nginx && echo \\"$imgs\\" | grep -q busybox && kubectl wait --for=condition=Ready pod/duo -n $NS --timeout=90s"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 33,  8, 'Pod 목록을 만든 순서대로 정렬해 저장하기',
   '`$NS` 네임스페이스에는 Pod `web-a`, `web-b`, `web-c` 가 있습니다. 이름순이 아니라 **만들어진 시각 순서**(가장 오래된 것이 위)로 보고 싶습니다. `kubectl` 은 출력을 스스로 정렬하는 옵션을 가지고 있어서, `sort` 같은 다른 명령으로 가공하지 않아도 됩니다.

Pod 목록을 **만든 순서대로** 정렬해서 `/tmp/pods_by_age.txt` 에 저장하세요. (제목 줄 `NAME READY ...` 도 그대로 포함됩니다)

완료 조건: 파일의 첫 번째 열(제목 줄 제외)이 만든 순서대로 나와야 합니다.',
   '`kubectl get pods --sort-by=<JSONPath>` 는 그 값으로 정렬해서 보여 줍니다. (`--sort-by` 는 정렬 기준, JSONPath 는 `.metadata.creationTimestamp` 처럼 객체 안의 위치입니다) 만든 시각은 `.metadata.creationTimestamp` 이고 값이 작은(오래된) 것이 위로 옵니다. 결과를 파일로 저장하려면 `>` 를 씁니다.',
   '# 만든 시각(.metadata.creationTimestamp) 기준 오름차순 정렬 → 파일 저장
kubectl get pods -n $NS --sort-by=.metadata.creationTimestamp > /tmp/pods_by_age.txt
cat /tmp/pods_by_age.txt',
   '["sh", "-c", "kubectl run web-c --image=nginx -n $NS >/dev/null 2>&1; sleep 2; kubectl run web-a --image=nginx -n $NS >/dev/null 2>&1; sleep 2; kubectl run web-b --image=nginx -n $NS >/dev/null 2>&1; true"]',
   '["sh", "-c", "[ -s /tmp/pods_by_age.txt ] && [ \\"$(awk ''NR>1 {printf \\"%s \\", $1}'' /tmp/pods_by_age.txt)\\" = \\"web-c web-a web-b \\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 33 AND order_index = 8);
