-- 세트 20: k8s 일상 운영 기본기 (order 1~12)
-- 조회·접속·로그·이벤트·롤아웃·라벨 셀렉터 등 매일 쓰는 kubectl 기본 명령. 네임스페이스 생성은 학습자 권한(자기 네임스페이스 edit)으로 불가해 제외했다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (20,  1, '기본 네임스페이스 확인하기',
   '지금 kubectl 이 기본으로 사용하는 네임스페이스 이름만 /tmp/ns.txt 에 저장하세요. (-n 을 생략했을 때 쓰이는 값입니다.)',
   'kubectl config view --minify 는 현재 컨텍스트의 설정만 보여 줍니다. -o jsonpath 로 namespace 값을 뽑습니다.',
   'kubectl config view --minify -o jsonpath=''{..namespace}'' > /tmp/ns.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/ns.txt)\\\" = $NS ]"]'),

  (20,  2, 'Pod 가 실행 중인 노드 확인하기',
   '$NS 의 Pod web 이 실행 중인 노드 이름을 /tmp/node.txt 에 저장하세요.',
   'kubectl get pod web -o wide 의 NODE 열이나, -o jsonpath=''{.spec.nodeName}'' 으로 알 수 있습니다.',
   'kubectl get pod web -n $NS -o jsonpath=''{.spec.nodeName}'' > /tmp/node.txt',
   '["sh", "-c", "kubectl run web --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=Ready pod/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ -s /tmp/node.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/node.txt)\\\" = \\\"$(kubectl get pod web -n $NS -o jsonpath=''{.spec.nodeName}'')\\\" ]"]'),

  (20,  3, 'Pod IP 확인하기',
   '$NS 의 Pod web 의 IP 주소를 /tmp/pod_ip.txt 에 저장하세요.',
   'kubectl get pod web -o wide 의 IP 열이나 -o jsonpath=''{.status.podIP}'' 를 사용합니다.',
   'kubectl get pod web -n $NS -o jsonpath=''{.status.podIP}'' > /tmp/pod_ip.txt',
   '["sh", "-c", "kubectl run web --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=Ready pod/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ -s /tmp/pod_ip.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/pod_ip.txt)\\\" = \\\"$(kubectl get pod web -n $NS -o jsonpath=''{.status.podIP}'')\\\" ]"]'),

  (20,  4, '컨테이너 안에서 명령 실행하기',
   '$NS 의 Pod web 안에서 hostname 명령을 실행한 결과를 /tmp/host.txt 에 저장하세요.',
   'kubectl exec Pod이름 -- 명령 형식입니다. 직접 들어가 보려면 kubectl exec -it Pod이름 -- bash 를 씁니다.',
   'kubectl exec web -n $NS -- hostname > /tmp/host.txt',
   '["sh", "-c", "kubectl run web --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=Ready pod/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/host.txt)\\\" = web ]"]'),

  (20,  5, '로그 마지막 줄만 보기',
   '$NS 의 Pod logger 가 출력한 로그의 마지막 3줄을 /tmp/tail3.txt 에 저장하세요.',
   'kubectl logs Pod이름 --tail=3 입니다. 실시간으로 따라가려면 -f 를 붙입니다 (Ctrl+C 로 종료).',
   'kubectl logs logger -n $NS --tail=3 > /tmp/tail3.txt',
   '["sh", "-c", "kubectl run logger --image=busybox -n $NS -- sh -c ''for i in 1 2 3 4 5 6 7 8; do echo line$i; done; sleep 3600'' 2>/dev/null; kubectl wait --for=condition=Ready pod/logger -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(paste -sd, - < /tmp/tail3.txt)\\\" = line6,line7,line8 ]"]'),

  (20,  6, '라벨 셀렉터로 조회하기',
   '$NS 에서 라벨 app=web 인 Pod 의 이름만 정렬해서 한 줄씩 /tmp/web_pods.txt 에 저장하세요.',
   'kubectl get pods -l app=web 으로 라벨 셀렉터를 지정합니다. -o name 은 pod/이름 형태로 출력합니다.',
   'kubectl get pods -n $NS -l app=web -o name | sed ''s#^pod/##'' | sort > /tmp/web_pods.txt',
   '["sh", "-c", "kubectl run p1 --image=nginx --labels=app=web -n $NS 2>/dev/null; kubectl run p2 --image=nginx --labels=app=db -n $NS 2>/dev/null; kubectl run p3 --image=nginx --labels=app=web -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(sed ''s#^pod/##'' /tmp/web_pods.txt | sort | paste -sd, -)\\\" = p1,p3 ]"]'),

  (20,  7, '라벨 셀렉터로 삭제하기',
   '$NS 에서 라벨 app=db 인 Pod 만 삭제하세요. 다른 Pod 는 그대로 두어야 합니다.',
   'kubectl delete pod -l app=db 처럼 이름 대신 셀렉터로 지울 수 있습니다. 지우기 전에 같은 -l 로 get 해서 대상을 확인하세요.',
   'kubectl delete pod -n $NS -l app=db',
   '["sh", "-c", "kubectl run p1 --image=nginx --labels=app=web -n $NS 2>/dev/null; kubectl run p2 --image=nginx --labels=app=db -n $NS 2>/dev/null; kubectl run p3 --image=nginx --labels=app=web -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get pods -n $NS -l app=db -o name | wc -l)\\\" -eq 0 ] && kubectl get pod p1 -n $NS >/dev/null 2>&1 && kubectl get pod p3 -n $NS >/dev/null 2>&1"]'),

  (20,  8, '이벤트로 Pod 이력 확인하기',
   '$NS 의 Pod web 에 대해 쿠버네티스가 남긴 이벤트의 Reason 열(값만)을 /tmp/reasons.txt 에 저장하세요.',
   'kubectl get events --field-selector involvedObject.name=web 로 해당 Pod 이벤트만 걸러냅니다. kubectl describe pod 의 Events 와 같은 내용입니다.',
   'kubectl get events -n $NS --field-selector involvedObject.name=web -o custom-columns=REASON:.reason --no-headers > /tmp/reasons.txt',
   '["sh", "-c", "kubectl run web --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=Ready pod/web -n $NS --timeout=90s 2>/dev/null; true"]',
   '["sh", "-c", "grep -q Scheduled /tmp/reasons.txt && grep -q Started /tmp/reasons.txt"]'),

  (20,  9, '배포 이력 확인하기',
   '$NS 의 Deployment app 이 지금까지 몇 번 배포(리비전)됐는지 숫자만 /tmp/revisions.txt 에 저장하세요.',
   'kubectl rollout history deployment/app 은 리비전 목록을 보여 줍니다. 숫자로 시작하는 줄을 세세요.',
   'kubectl rollout history deployment/app -n $NS | grep -c ''^[0-9]'' > /tmp/revisions.txt',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; kubectl set image deployment/app nginx=nginx:alpine -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/revisions.txt)\\\" = 2 ]"]'),

  (20, 10, 'Deployment 재시작하기',
   '$NS 의 Deployment app 의 Pod 들을 이미지 변경 없이 다시 시작(롤링 재시작)하세요.',
   'kubectl rollout restart deployment/이름 입니다. 진행 상황은 kubectl rollout status 로 봅니다.',
   'kubectl rollout restart deployment/app -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; kubectl set image deployment/app nginx=nginx:alpine -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get deployment app -n $NS -o yaml | grep -q restartedAt"]'),

  (20, 11, '리소스를 YAML 로 백업하기',
   '$NS 의 Deployment app 을 YAML 로 /tmp/app-backup.yaml 에 백업하세요.',
   'kubectl get 리소스 이름 -o yaml 입니다. 이 파일을 kubectl apply -f 하면 다시 만들 수 있습니다.',
   'kubectl get deployment app -n $NS -o yaml > /tmp/app-backup.yaml',
   '["sh", "-c", "kubectl create deployment app --image=nginx -n $NS 2>/dev/null; kubectl set image deployment/app nginx=nginx:alpine -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''kind: Deployment'' /tmp/app-backup.yaml && grep -q ''name: app'' /tmp/app-backup.yaml"]'),

  (20, 12, '한 번만 실행하는 Pod 로 확인하기',
   'busybox 이미지로 echo hello 를 한 번만 실행하는 Pod hello 를 $NS 에 만들고(--restart=Never), 그 출력을 로그에서 읽어 /tmp/hello.txt 에 저장하세요.',
   'kubectl run 이름 --image=이미지 --restart=Never -- 명령. 끝난 뒤 kubectl logs 이름 으로 출력을 봅니다. 완료까지 몇 초 걸립니다.',
   'kubectl run hello --image=busybox --restart=Never -n $NS -- echo hello
kubectl wait --for=jsonpath=''{.status.phase}''=Succeeded pod/hello -n $NS --timeout=90s
kubectl logs hello -n $NS > /tmp/hello.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/hello.txt)\\\" = hello ]"]');
