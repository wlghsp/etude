-- 세트 19(kubectl 속도와 실전) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set19.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 19, 'kubectl 속도와 실전', 'dry-run으로 YAML 뼈대 만들기, 명령형 수정, jsonpath, custom-columns, explain, patch 등 시간 제한 실기(CKA 등)에서 점수를 가르는 kubectl 손기술을 실습합니다.', 'k8s', 'k8s' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  1, 'dry-run으로 Pod YAML 뼈대 만들기',
   'Pod를 실제로 만들지 말고, 이름 web / 이미지 nginx 인 Pod의 YAML 을 /tmp/web.yaml 에 저장하세요. (시험장에서 YAML 을 처음부터 쓰지 않는 방법입니다.)',
   'kubectl run 이름 --image=이미지 에 --dry-run=client -o yaml 을 붙이면 만들지 않고 YAML 만 출력합니다.',
   'kubectl run web --image=nginx --dry-run=client -o yaml > /tmp/web.yaml',
   NULL,
   '["sh", "-c", "grep -q ''kind: Pod'' /tmp/web.yaml && grep -q ''name: web'' /tmp/web.yaml && grep -q ''image: nginx'' /tmp/web.yaml && ! kubectl get pod web -n $NS >/dev/null 2>&1"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  2, 'YAML 을 뽑아 고쳐서 적용하기',
   'nginx 이미지의 Deployment api 를 replicas 3 으로 YAML 에 먼저 저장(/tmp/api.yaml)한 뒤, 그 파일을 $NS 네임스페이스에 적용하세요.',
   'kubectl create deployment 이름 --image=... --replicas=3 --dry-run=client -o yaml > 파일 로 뼈대를 만들고 kubectl apply -f 파일 로 적용합니다.',
   'kubectl create deployment api --image=nginx --replicas=3 --dry-run=client -o yaml > /tmp/api.yaml
kubectl apply -f /tmp/api.yaml -n $NS',
   NULL,
   '["sh", "-c", "[ -s /tmp/api.yaml ] && [ \\\"$(kubectl get deploy api -n $NS -o jsonpath=''{.spec.replicas}'')\\\" = 3 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  3, '명령형으로 Deployment 한 번에 바꾸기',
   '$NS 의 Deployment app 을 YAML 편집 없이 명령어로 바꾸세요: replicas 4, 이미지 nginx:1.25-alpine, 환경변수 APP_ENV=prod.',
   'kubectl scale / kubectl set image / kubectl set env 를 사용합니다. 컨테이너 이름은 이미지 이름(nginx)입니다.',
   'kubectl scale deployment app --replicas=4 -n $NS
kubectl set image deployment/app nginx=nginx:1.25-alpine -n $NS
kubectl set env deployment/app APP_ENV=prod -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.replicas}'')\\\" = 4 ] && kubectl get deploy app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' | grep -q alpine && [ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].env[?(@.name==\\\"APP_ENV\\\")].value}'')\\\" = prod ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  4, '라벨과 어노테이션 붙이기',
   '$NS 의 Deployment app 에 라벨 tier=backend 와 어노테이션 owner=team-a 를 붙이세요.',
   'kubectl label 리소스 키=값, kubectl annotate 리소스 키=값 형식입니다.',
   'kubectl label deployment app tier=backend -n $NS
kubectl annotate deployment app owner=team-a -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.metadata.labels.tier}'')\\\" = backend ] && [ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.metadata.annotations.owner}'')\\\" = team-a ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  5, 'expose 로 Service 만들기',
   '$NS 의 Deployment app 을 80 포트로 노출하는 Service app-svc 를 한 줄 명령으로 만드세요.',
   'kubectl expose deployment 이름 --port=포트 --name=서비스이름 형식입니다.',
   'kubectl expose deployment app --port=80 --name=app-svc -n $NS',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get svc app-svc -n $NS -o jsonpath=''{.spec.ports[0].port}'')\\\" = 80 ] && [ \\\"$(kubectl get svc app-svc -n $NS -o jsonpath=''{.spec.selector.app}'')\\\" = app ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  6, 'jsonpath 로 값 뽑기',
   '$NS 의 Deployment app 이 사용하는 이미지(값만)를 /tmp/image.txt 에 저장하세요.',
   '-o jsonpath=''{.spec.template.spec.containers[0].image}'' 처럼 경로를 지정하면 그 값만 출력됩니다.',
   'kubectl get deployment app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' > /tmp/image.txt',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/image.txt)\\\" = nginx:1.25 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  7, 'custom-columns 로 표 만들기',
   '$NS 의 모든 Deployment 의 이름과 이미지를 "이름 이미지" 형태로 헤더 없이 /tmp/deploys.txt 에 저장하세요.',
   'kubectl get deploy -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image --no-headers 형태입니다.',
   'kubectl get deploy -n $NS -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image --no-headers > /tmp/deploys.txt',
   '["sh", "-c", "kubectl create deployment d-a --image=nginx:1.24 -n $NS 2>/dev/null; kubectl create deployment d-b --image=nginx:1.25 -n $NS 2>/dev/null; kubectl create deployment d-c --image=busybox:1.36 -n $NS -- sleep 3600 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(awk ''{print $1,$2}'' /tmp/deploys.txt | sort | paste -sd, -)\\\" = ''d-a nginx:1.24,d-b nginx:1.25,d-c busybox:1.36'' ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  8, 'kubectl explain 으로 필드 찾기',
   'Pod 컨테이너의 imagePullPolicy 필드 설명을 /tmp/explain.txt 에 저장하세요. 매뉴얼 없이 필드를 찾는 방법입니다.',
   'kubectl explain pod.spec.containers.imagePullPolicy 처럼 점(.)으로 경로를 이어 씁니다.',
   'kubectl explain pod.spec.containers.imagePullPolicy > /tmp/explain.txt',
   NULL,
   '["sh", "-c", "grep -q imagePullPolicy /tmp/explain.txt && grep -q IfNotPresent /tmp/explain.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19,  9, 'patch 로 값 바꾸기',
   '$NS 의 Deployment app 의 replicas 를 kubectl patch 로 5 로 바꾸세요.',
   'kubectl patch deployment 이름 -p ''{"spec":{"replicas":5}}'' 형식입니다.',
   'kubectl patch deployment app -n $NS -p ''{"spec":{"replicas":5}}''',
   '["sh", "-c", "kubectl create deployment app --image=nginx:1.25 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "[ \\\"$(kubectl get deploy app -n $NS -o jsonpath=''{.spec.replicas}'')\\\" = 5 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19, 10, '리소스 약어 찾기',
   'Deployment 의 짧은 이름(약어)을 kubectl api-resources 로 찾아 /tmp/short.txt 에 저장하세요. (약어만)',
   'api-resources 출력에서 deployments 줄의 SHORTNAMES 열입니다. grep -w 와 awk 를 쓰세요.',
   'kubectl api-resources | grep -w deployments | awk ''{print $2}'' > /tmp/short.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/short.txt)\\\" = deploy ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 10);
