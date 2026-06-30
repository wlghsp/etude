-- 세트 14: Helm 기초 (order 1~8)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (14, 1, 'Helm repo 추가하기',
   'Bitnami Helm 저장소를 추가하고 목록을 확인하세요.',
   'helm repo add <이름> <URL> 로 저장소를 등록합니다. https://charts.bitnami.com/bitnami 를 bitnami 이름으로 추가하세요.',
   'helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo list',
   NULL,
   '["sh", "-c", "helm repo list | grep -q bitnami"]'),

  (14, 2, 'Helm repo 업데이트하기',
   'Helm 저장소 인덱스를 최신 상태로 갱신하세요.',
   'helm repo update 를 실행합니다.',
   'helm repo update',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null; true"]',
   '["sh", "-c", "helm repo update 2>&1 | grep -qi \\\"update complete\\\\|Successfully\\\""]'),

  (14, 3, '차트 검색하기',
   'Bitnami 저장소에서 nginx 차트를 검색하고 결과를 /tmp/helm_search.txt 에 저장하세요.',
   'helm search repo <키워드> 로 저장소에서 차트를 검색합니다.',
   'helm search repo nginx > /tmp/helm_search.txt',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null; true"]',
   '["sh", "-c", "grep -q \\\"nginx\\\" /tmp/helm_search.txt"]'),

  (14, 4, '차트 설치하기',
   '$NS 네임스페이스에 bitnami/nginx 차트를 my-nginx 이름으로 설치하세요.',
   'helm install <릴리스명> <차트> -n <namespace> 로 설치합니다.',
   'helm install my-nginx bitnami/nginx -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null; true"]',
   '["sh", "-c", "helm list -n $NS | grep -q my-nginx"]'),

  (14, 5, '릴리스 목록 확인하기',
   '$NS 네임스페이스에 설치된 Helm 릴리스 목록을 확인하고 /tmp/helm_list.txt 에 저장하세요.',
   'helm list -n <namespace> 로 릴리스 목록을 확인합니다.',
   'helm list -n $NS > /tmp/helm_list.txt',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null && helm install my-nginx bitnami/nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q \\\"my-nginx\\\" /tmp/helm_list.txt"]'),

  (14, 6, '값을 커스터마이징해서 설치하기',
   '$NS 네임스페이스에 bitnami/nginx 차트를 custom-nginx 이름으로 설치하세요. replicaCount를 2로 지정해서 설치해야 합니다.',
   'helm install <릴리스명> <차트> --set <키>=<값> -n <namespace> 로 값을 오버라이드합니다.',
   'helm install custom-nginx bitnami/nginx --set replicaCount=2 -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null; true"]',
   '["sh", "-c", "helm get values custom-nginx -n $NS | grep -q \\\"replicaCount: 2\\\""]'),

  (14, 7, '릴리스 업그레이드하기',
   '$NS 네임스페이스의 my-nginx 릴리스를 replicaCount=3 으로 업그레이드하세요.',
   'helm upgrade <릴리스명> <차트> --set <키>=<값> -n <namespace> 로 설정을 변경합니다.',
   'helm upgrade my-nginx bitnami/nginx --set replicaCount=3 -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null && helm install my-nginx bitnami/nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "helm history my-nginx -n $NS | grep -c deployed | xargs -I{} test {} -ge 1"]'),

  (14, 8, '릴리스 삭제하기',
   '$NS 네임스페이스의 my-nginx 릴리스를 완전히 삭제하세요.',
   'helm uninstall <릴리스명> -n <namespace> 로 릴리스와 관련 리소스를 모두 제거합니다.',
   'helm uninstall my-nginx -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null && helm install my-nginx bitnami/nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "! helm list -n $NS | grep -q my-nginx"]');
