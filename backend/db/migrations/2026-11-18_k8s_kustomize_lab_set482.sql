-- Git 실습 세트 482. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_kustomize_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 482, 'k8s Kustomize 손연습: kubectl kustomize, namePrefix, images, replicas, labels, configMapGenerator, patches, apply -k·delete -k', '복사 없이 YAML 을 겹쳐 환경별 설정을 만들어 봅니다. base 와 overlay, kubectl kustomize 로 렌더링 확인, namePrefix·images·replicas·labels 변환, configMapGenerator 의 해시 이름, patches 로 필요한 부분만 덮어쓰기, apply -k 와 delete -k 로 적용·삭제를 실습합니다.', 'k8s', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 482);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 1, 'kustomization 으로 YAML 합쳐 보기 (kubectl kustomize)', '**배경** — Kustomize 는 YAML 을 **복사·수정하지 않고** 기본 틀(base)에 변경을 겹쳐 최종 매니페스트를 만듭니다. 폴더에 `kustomization.yaml` 을 두고 `resources:` 로 파일을 나열하면, `kubectl kustomize 폴더` 가 합친 결과를 **화면에 출력**합니다(클러스터에는 아무것도 적용하지 않습니다). `/tmp/lab/base` 에 `deployment.yaml`(Deployment `web`)과 `kustomization.yaml` 이 준비되어 있습니다.

**문제** — `/tmp/lab/base` 를 kustomize 로 렌더링한 결과를 **`/tmp/q1.txt`** 에 저장하세요. (`kind: Deployment` 와 `replicas: 2` 가 보입니다.)', '`kubectl kustomize /tmp/lab/base > /tmp/q1.txt`', 'kubectl kustomize /tmp/lab/base > /tmp/q1.txt
cat /tmp/q1.txt

# kustomize 는 출력만 한다. 적용은 apply -k 로 따로 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\n"]', '["sh", "-c", "( grep -q \\"kind: Deployment\\" /tmp/q1.txt ) && ( grep -q \\"replicas: 2\\" /tmp/q1.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "Deployment 가 렌더링됐다", "cmd": ["sh", "-c", "grep -q \\"kind: Deployment\\" /tmp/q1.txt"]}, {"label": "replicas 가 2 다", "cmd": ["sh", "-c", "grep -q \\"replicas: 2\\" /tmp/q1.txt"]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 2, '이름 앞에 접두사 붙이기 (namePrefix)', '**배경** — base 를 가리키는 **overlay** 폴더에 `kustomization.yaml` 을 두고 `resources: [../base]` 로 불러온 뒤 `namePrefix: dev-` 를 쓰면 **모든 리소스 이름 앞에 `dev-`** 가 붙습니다. 같은 base 로 환경별(dev·prod) 리소스를 이름만 다르게 만들 때 씁니다.

**문제** — `/tmp/lab/overlay/kustomization.yaml` 을 만드세요. `../base` 를 불러오고 **`namePrefix: dev-`** 를 지정합니다. `kubectl kustomize /tmp/lab/overlay` 결과에 `name: dev-web` 이 있어야 합니다.', '`resources:` 에 `../base`, 그 아래에 `namePrefix: dev-`', 'cat > /tmp/lab/overlay/kustomization.yaml <<''EOF''
resources:
- ../base
namePrefix: dev-
EOF
kubectl kustomize /tmp/lab/overlay | head -5

# base 는 그대로 두고 overlay 에서 이름만 바꿨다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\n"]', '["sh", "-c", "( kubectl kustomize /tmp/lab/overlay | grep -q \\"name: dev-web\\" ) && ( grep -q \\"name: web$\\" /tmp/lab/base/deployment.yaml )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이름이 dev-web 이다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"name: dev-web\\""]}, {"label": "base 파일은 바뀌지 않았다", "cmd": ["sh", "-c", "grep -q \\"name: web$\\" /tmp/lab/base/deployment.yaml"]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}, {"title": "kustomization.yaml 레퍼런스", "url": "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 3, '이미지 태그 바꾸기 (images)', '**배경** — `images:` 는 **이미지 이름은 그대로 두고 태그만** 바꿉니다. YAML 의 `image:` 를 직접 고치지 않고 환경마다 다른 버전을 쓸 수 있습니다. 형식은 `- name: 기존이미지이름` / `newTag: "새태그"` 입니다.

**문제** — overlay 의 `kustomization.yaml` 에서 `nginx` 이미지 태그를 **`1.26`** 으로 바꾸세요. 렌더링하면 `image: nginx:1.26` 이어야 합니다. (`../base` 도 불러와야 합니다.)', '`images:` 아래 `- name: nginx` + `newTag: "1.26"`', 'cat > /tmp/lab/overlay/kustomization.yaml <<''EOF''
resources:
- ../base
images:
- name: nginx
  newTag: "1.26"
EOF
kubectl kustomize /tmp/lab/overlay | grep image:

# images 는 이름 기준으로 찾아 태그(또는 이름)를 바꾼다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\n"]', '["sh", "-c", "( kubectl kustomize /tmp/lab/overlay | grep -q \\"image: nginx:1.26\\" ) && ( ! kubectl kustomize /tmp/lab/overlay | grep -q \\"nginx:1.25\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이미지가 nginx:1.26 이다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"image: nginx:1.26\\""]}, {"label": "옛 태그는 없다", "cmd": ["sh", "-c", "! kubectl kustomize /tmp/lab/overlay | grep -q \\"nginx:1.25\\""]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}, {"title": "kustomization.yaml 레퍼런스", "url": "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 4, '복제본 수 바꾸기 (replicas)', '**배경** — `replicas:` 는 **이름으로 지정한** Deployment 의 복제본 수를 바꿉니다. base 의 `replicas: 2` 를 건드리지 않고 overlay 에서 늘릴 수 있습니다. 형식은 `- name: 리소스이름` / `count: 숫자` 입니다.

**문제** — overlay 에서 `web` 의 복제본을 **4** 로 바꾸세요. 렌더링하면 `replicas: 4` 여야 합니다.', '`replicas:` 아래 `- name: web` + `count: 4`', 'cat > /tmp/lab/overlay/kustomization.yaml <<''EOF''
resources:
- ../base
replicas:
- name: web
  count: 4
EOF
kubectl kustomize /tmp/lab/overlay | grep replicas

# name 은 base 의 리소스 이름(접두사 적용 전)을 쓴다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\n"]', '["sh", "-c", "( kubectl kustomize /tmp/lab/overlay | grep -q \\"replicas: 4\\" ) && ( ! kubectl kustomize /tmp/lab/overlay | grep -q \\"replicas: 2\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "replicas 가 4 다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"replicas: 4\\""]}, {"label": "옛 값 2 는 없다", "cmd": ["sh", "-c", "! kubectl kustomize /tmp/lab/overlay | grep -q \\"replicas: 2\\""]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}, {"title": "kustomization.yaml 레퍼런스", "url": "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 5, '리소스에 라벨 붙이기 (labels)', '**배경** — `labels:` 는 모든 리소스에 **같은 라벨**을 붙입니다. `includeSelectors: true` 를 주면 셀렉터(`selector.matchLabels`)와 Pod 템플릿 라벨에도 반영됩니다. 형식은 `- pairs:` 아래 `키: 값`, 그리고 `includeSelectors` 입니다.

**문제** — overlay 에서 모든 리소스에 라벨 **`env: dev`** 를 붙이고 셀렉터에도 포함하세요. 렌더링 결과에 `env: dev` 가 **3곳**(Deployment 라벨, 셀렉터, Pod 템플릿 라벨)에 나와야 합니다.', '`labels:` → `- pairs:` → `env: dev`, 그리고 `includeSelectors: true`', 'cat > /tmp/lab/overlay/kustomization.yaml <<''EOF''
resources:
- ../base
labels:
- pairs:
    env: dev
  includeSelectors: true
EOF
kubectl kustomize /tmp/lab/overlay | grep -c ''env: dev''

# includeSelectors 를 빼면 Deployment 자신의 라벨에만 붙는다 (셀렉터는 변경하면 위험하다)', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(kubectl kustomize /tmp/lab/overlay | grep -c \\"env: dev\\")\\" -ge 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "env: dev 가 3곳에 있다", "cmd": ["sh", "-c", "[ \\"$(kubectl kustomize /tmp/lab/overlay | grep -c \\"env: dev\\")\\" -ge 3 ]"]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}, {"title": "kustomization.yaml 레퍼런스", "url": "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 6, 'ConfigMap 을 파일 없이 만들기 (configMapGenerator)', '**배경** — `configMapGenerator` 는 `literals:` 로 **ConfigMap 을 자동 생성**합니다. 생성된 이름 뒤에는 내용 **해시**(`app-config-k9t6…`)가 붙어, 내용이 바뀌면 이름이 바뀌고 참조하는 Pod 가 롤링 업데이트됩니다. 형식은 `- name: 이름` / `literals:` 아래 `- KEY=값` 입니다.

**문제** — overlay 에서 이름이 **`app-config`** 이고 **`LEVEL=debug`** 를 담은 ConfigMap 을 생성하게 하세요. 렌더링 결과에 `name: app-config-` 로 시작하는 ConfigMap 과 `LEVEL: debug` 가 있어야 합니다.', '`configMapGenerator:` → `- name: app-config` → `literals:` → `- LEVEL=debug`', 'cat > /tmp/lab/overlay/kustomization.yaml <<''EOF''
resources:
- ../base
configMapGenerator:
- name: app-config
  literals:
  - LEVEL=debug
EOF
kubectl kustomize /tmp/lab/overlay | grep -A4 ''kind: ConfigMap''

# 이름 뒤 해시는 내용이 바뀌면 달라진다. 이를 참조하는 리소스는 자동으로 새 이름을 쓰게 바뀐다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\n"]', '["sh", "-c", "( kubectl kustomize /tmp/lab/overlay | grep -q \\"kind: ConfigMap\\" ) && ( kubectl kustomize /tmp/lab/overlay | grep -q \\"name: app-config-\\" ) && ( kubectl kustomize /tmp/lab/overlay | grep -q \\"LEVEL: debug\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "ConfigMap 이 있다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"kind: ConfigMap\\""]}, {"label": "이름이 app-config- 로 시작한다 (해시 포함)", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"name: app-config-\\""]}, {"label": "LEVEL 이 debug 다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"LEVEL: debug\\""]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}, {"title": "kustomization.yaml 레퍼런스", "url": "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 7, '한 번에 클러스터에 적용하기 (apply -k)', '**배경** — 렌더링한 결과를 클러스터에 적용하는 명령은 **`kubectl apply -k 폴더`** 입니다(`-k` 가 kustomize 를 뜻합니다). 접두사가 있는 overlay 를 적용하면 이름이 바뀐 리소스가 만들어집니다. `/tmp/lab/overlay` 에는 `../base` 와 `namePrefix: dev-` 가 이미 준비되어 있습니다.

**문제** — overlay 를 **현재 네임스페이스(`$NS`)에 적용**하세요. Deployment **`dev-web`** 이 만들어져 있어야 합니다.', '`kubectl apply -k /tmp/lab/overlay -n $NS`', 'kubectl apply -k /tmp/lab/overlay -n $NS
kubectl get deploy -n $NS

# apply -k 는 kustomize 로 렌더링한 결과를 apply 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\ncat > /tmp/lab/overlay/kustomization.yaml <<''EOF''\\nresources:\\n- ../base\\nnamePrefix: dev-\\nEOF\\n"]', '["sh", "-c", "( kubectl get deployment dev-web -n $NS >/dev/null 2>&1 ) && ( ! kubectl get deployment web -n $NS >/dev/null 2>&1 ) && ( [ \\"$(kubectl get deployment dev-web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.25 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "dev-web Deployment 가 있다", "cmd": ["sh", "-c", "kubectl get deployment dev-web -n $NS >/dev/null 2>&1"]}, {"label": "원래 이름 web 은 없다", "cmd": ["sh", "-c", "! kubectl get deployment web -n $NS >/dev/null 2>&1"]}, {"label": "이미지가 nginx:1.25 다", "cmd": ["sh", "-c", "[ \\"$(kubectl get deployment dev-web -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' 2>/dev/null)\\" = nginx:1.25 ]"]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 8, '일부만 덮어쓰기 (patches)', '**배경** — 라벨·이미지처럼 정해진 필드가 아니라 **원하는 부분을 덮어쓰려면** `patches:` 로 패치 파일을 지정합니다. 패치 파일은 **바꾸려는 부분만** 쓴 YAML 이고, 대상은 `kind`·`name` 으로 맞춥니다(전략적 병합). 컨테이너는 `name` 으로 짝을 찾습니다.

**문제** — overlay 에 `env-patch.yaml` 을 만들어 Deployment `web` 의 컨테이너 `web` 에 환경 변수 **`APP_MODE=dev`** 를 추가하고, `kustomization.yaml` 의 `patches:` 에 `- path: env-patch.yaml` 로 연결하세요. (이름 접두사 `dev-` 는 그대로입니다.) 렌더링 결과에 `APP_MODE` 와 `value: dev` 가 있어야 합니다.', '패치 파일은 `apiVersion`·`kind`·`metadata.name: web` 과 `containers` 의 `name: web` + `env` 만 쓰면 돼요. `kustomization.yaml` 에는 `patches:` / `- path: env-patch.yaml`', 'cat > /tmp/lab/overlay/env-patch.yaml <<''EOF''
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  template:
    spec:
      containers:
      - name: web
        env:
        - name: APP_MODE
          value: dev
EOF
cat >> /tmp/lab/overlay/kustomization.yaml <<''EOF''
patches:
- path: env-patch.yaml
EOF
kubectl kustomize /tmp/lab/overlay | grep -B1 -A2 APP_MODE

# 패치는 바꿀 필드만 적는다. 대상 이름은 접두사가 붙기 전 base 의 이름(web)으로 맞춘다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\ncat > /tmp/lab/overlay/kustomization.yaml <<''EOF''\\nresources:\\n- ../base\\nnamePrefix: dev-\\nEOF\\n"]', '["sh", "-c", "( [ -f /tmp/lab/overlay/env-patch.yaml ] ) && ( kubectl kustomize /tmp/lab/overlay | grep -A1 \\"APP_MODE\\" | grep -q \\"value: dev\\" ) && ( kubectl kustomize /tmp/lab/overlay | grep -q \\"name: dev-web\\" ) && ( kubectl kustomize /tmp/lab/overlay | grep -q \\"image: nginx:1.25\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "패치 파일이 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/overlay/env-patch.yaml ]"]}, {"label": "APP_MODE 가 dev 로 렌더링된다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -A1 \\"APP_MODE\\" | grep -q \\"value: dev\\""]}, {"label": "이름은 여전히 dev-web 이다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"name: dev-web\\""]}, {"label": "원래 이미지도 유지된다", "cmd": ["sh", "-c", "kubectl kustomize /tmp/lab/overlay | grep -q \\"image: nginx:1.25\\""]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}, {"title": "kustomization.yaml 레퍼런스", "url": "https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 9, 'kustomize 로 만든 것 지우기 (delete -k)', '**배경** — `kubectl apply -k` 로 만든 리소스는 **`kubectl delete -k 폴더`** 로 **같은 목록 그대로** 지웁니다. 어떤 리소스를 만들었는지 이름을 하나씩 적을 필요가 없습니다. 지금 `/tmp/lab/overlay` 를 적용해 `dev-web` 이 만들어져 있습니다.

**문제** — `delete -k` 로 overlay 가 만든 리소스를 **지우세요**. `dev-web` Deployment 가 없어야 합니다.', '`kubectl delete -k /tmp/lab/overlay -n $NS`', 'kubectl delete -k /tmp/lab/overlay -n $NS
kubectl get deploy -n $NS

# apply -k 와 delete -k 는 같은 폴더를 가리키면 대칭이다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*.txt; kubectl delete deploy web dev-web -n $NS --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1; kubectl delete cm -l app=web -n $NS --ignore-not-found >/dev/null 2>&1; mkdir -p /tmp/lab/base /tmp/lab/overlay; cat > /tmp/lab/base/deployment.yaml <<''EOF''\\napiVersion: apps/v1\\nkind: Deployment\\nmetadata:\\n  name: web\\n  labels:\\n    app: web\\nspec:\\n  replicas: 2\\n  selector:\\n    matchLabels:\\n      app: web\\n  template:\\n    metadata:\\n      labels:\\n        app: web\\n    spec:\\n      containers:\\n      - name: web\\n        image: nginx:1.25\\n        ports:\\n        - containerPort: 80\\nEOF\\ncat > /tmp/lab/base/kustomization.yaml <<''EOF''\\nresources:\\n- deployment.yaml\\nEOF\\ncat > /tmp/lab/overlay/kustomization.yaml <<''EOF''\\nresources:\\n- ../base\\nnamePrefix: dev-\\nEOF\\nkubectl apply -k /tmp/lab/overlay -n $NS >/dev/null 2>&1\\n"]', '["sh", "-c", "( ! kubectl get deployment dev-web -n $NS >/dev/null 2>&1 ) && ( [ -f /tmp/lab/overlay/kustomization.yaml ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "dev-web 이 없다", "cmd": ["sh", "-c", "! kubectl get deployment dev-web -n $NS >/dev/null 2>&1"]}, {"label": "overlay 폴더는 그대로다", "cmd": ["sh", "-c", "[ -f /tmp/lab/overlay/kustomization.yaml ]"]}]', '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 10, 'base 와 overlay 의 역할', 'Kustomize 에서 **base** 와 **overlay** 의 역할로 맞는 것은 무엇일까요?', '공통은 한 곳에, 차이만 겹쳐요.', NULL, NULL, '[]', 'choice', '["환경별 설정은 base 에 두고 공통 설정만 overlay 에서 덮어쓴다", "공통 설정은 base 에 두고 환경별 차이만 overlay 에서 덮어쓴다", "base 는 클러스터에 적용되고 overlay 는 문서화용 주석 파일이다", "overlay 가 base 파일을 복사해 수정하므로 base 는 삭제해도 된다"]', 1, 'Kustomize 문서는 base 를 공통으로 재사용할 리소스 모음으로, overlay 를 base 를 불러와 환경별 변경(접두사, 이미지, 복제본, 패치 등)을 겹치는 폴더로 설명합니다. 원본 YAML 을 복사·수정하지 않습니다.', NULL, NULL, NULL, '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 11, 'overlay 를 클러스터에 적용하기', 'kustomize 폴더를 **클러스터에 적용**하는 명령입니다. 빈칸을 채우세요.', '"만들거나 갱신" 이에요.', NULL, NULL, '[]', 'fill', '["apply", "kustomize", "get", "explain"]', NULL, 'Kubectl 문서는 kubectl apply -k 디렉터리가 kustomization 으로 렌더링한 오브젝트를 적용한다고 설명합니다. kubectl kustomize 는 렌더링 결과를 출력만 합니다.', '[0]', 'kubectl {0} -k /tmp/lab/overlay', NULL, '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 482, 12, 'kustomize 로 환경 배포하는 순서', 'base 위에 환경별 overlay 를 만들어 배포하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '틀 → 차이 → 미리보기 → 적용이에요.', NULL, NULL, '[]', 'order', '["공통 리소스와 `kustomization.yaml` 로 base 를 만든다", "base 를 불러오고 접두사·이미지·패치를 적은 overlay 를 만든다", "`kubectl kustomize overlay` 로 최종 결과를 미리 확인한다", "`kubectl apply -k overlay` 로 클러스터에 적용한다"]', NULL, 'Kustomize 문서의 base·overlay 흐름입니다. 적용 전에 렌더링 결과를 눈으로 확인하는 것이 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Kustomize 로 쿠버네티스 오브젝트 관리하기", "url": "https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 482 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 262 WHERE id = 208;
UPDATE quest_set SET display_order = 263 WHERE id = 309;
UPDATE quest_set SET display_order = 264 WHERE id = 211;
UPDATE quest_set SET display_order = 265 WHERE id = 310;
UPDATE quest_set SET display_order = 266 WHERE id = 214;
UPDATE quest_set SET display_order = 267 WHERE id = 311;
UPDATE quest_set SET display_order = 268 WHERE id = 217;
UPDATE quest_set SET display_order = 269 WHERE id = 312;
UPDATE quest_set SET display_order = 270 WHERE id = 220;
UPDATE quest_set SET display_order = 271 WHERE id = 313;
UPDATE quest_set SET display_order = 272 WHERE id = 223;
UPDATE quest_set SET display_order = 273 WHERE id = 314;
UPDATE quest_set SET display_order = 274 WHERE id = 12;
UPDATE quest_set SET display_order = 275 WHERE id = 22;
UPDATE quest_set SET display_order = 276 WHERE id = 236;
UPDATE quest_set SET display_order = 277 WHERE id = 351;
UPDATE quest_set SET display_order = 278 WHERE id = 375;
UPDATE quest_set SET display_order = 279 WHERE id = 383;
UPDATE quest_set SET display_order = 280 WHERE id = 420;
UPDATE quest_set SET display_order = 281 WHERE id = 421;
UPDATE quest_set SET display_order = 284 WHERE id = 80;
UPDATE quest_set SET display_order = 285 WHERE id = 13;
UPDATE quest_set SET display_order = 286 WHERE id = 122;
UPDATE quest_set SET display_order = 287 WHERE id = 25;
UPDATE quest_set SET display_order = 288 WHERE id = 108;
UPDATE quest_set SET display_order = 289 WHERE id = 37;
UPDATE quest_set SET display_order = 290 WHERE id = 26;
UPDATE quest_set SET display_order = 291 WHERE id = 348;
UPDATE quest_set SET display_order = 292 WHERE id = 422;
UPDATE quest_set SET display_order = 293 WHERE id = 23;
UPDATE quest_set SET display_order = 294 WHERE id = 31;
UPDATE quest_set SET display_order = 295 WHERE id = 29;
UPDATE quest_set SET display_order = 296 WHERE id = 227;
UPDATE quest_set SET display_order = 297 WHERE id = 230;
UPDATE quest_set SET display_order = 298 WHERE id = 233;
UPDATE quest_set SET display_order = 299 WHERE id = 339;
UPDATE quest_set SET display_order = 300 WHERE id = 345;
UPDATE quest_set SET display_order = 301 WHERE id = 423;
UPDATE quest_set SET display_order = 302 WHERE id = 425;
UPDATE quest_set SET display_order = 303 WHERE id = 119;
UPDATE quest_set SET display_order = 304 WHERE id = 120;
UPDATE quest_set SET display_order = 305 WHERE id = 121;
UPDATE quest_set SET display_order = 306 WHERE id = 424;
UPDATE quest_set SET display_order = 307 WHERE id = 14;
UPDATE quest_set SET display_order = 261, unit_id = (SELECT id FROM unit WHERE id = 63), icon = '🧵' WHERE id = 482;
