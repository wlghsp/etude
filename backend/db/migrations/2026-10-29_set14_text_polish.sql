-- 세트 14 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='Helm 저장소 추가하기', description='**Helm** 은 쿠버네티스용 패키지 관리자입니다. 여러 YAML 을 **차트**라는 묶음으로 설치·업그레이드할 수 있고, 차트는 **저장소(repo)** 에서 받습니다.

Bitnami 저장소(`https://charts.bitnami.com/bitnami`)를 `bitnami` 이름으로 추가하고, 등록된 저장소 목록을 확인하세요.', hint='`helm repo add <이름> <URL>` 로 저장소를 등록하고, `helm repo list` 로 목록을 확인합니다. 두 명령을 `&&`(앞 명령이 성공하면 이어서 실행)로 이을 수 있습니다.', solution='helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo list

# repo add 이름 URL : 저장소 등록, repo list : 등록 목록 확인' WHERE quest_set_id = 14 AND order_index = 1;
UPDATE quest SET title='Helm 저장소 목록 갱신하기', description='저장소에 새 차트나 버전이 올라와도, 내 쪽 목록을 갱신해야 보입니다.

등록한 저장소들의 차트 목록을 **최신으로 갱신**하고, 출력 결과를 `/tmp/helm_update.txt` 에 저장하세요.', hint='`helm repo update` 를 실행합니다. 진행 메시지가 에러 출력으로 나올 수 있어 `> 파일 2>&1` (정상·에러 출력을 같은 파일로)로 저장합니다.', solution='helm repo update > /tmp/helm_update.txt 2>&1

# repo update : 저장소의 최신 차트 목록을 내려받음
# 2>&1 : 에러 출력도 같은 파일로' WHERE quest_set_id = 14 AND order_index = 2;
UPDATE quest SET title='차트 검색하기', description='설치하기 전에 저장소에 어떤 차트가 있는지 검색합니다.

Bitnami 저장소에서 `nginx` 차트를 검색하고, 결과를 `/tmp/helm_search.txt` 에 저장하세요.', hint='`helm search repo <키워드>` 는 등록한 저장소의 차트를 키워드로 찾습니다. 결과를 `>` 로 저장하세요.', solution='helm search repo nginx > /tmp/helm_search.txt

# search repo : 등록된 저장소에서 차트 검색' WHERE quest_set_id = 14 AND order_index = 3;
UPDATE quest SET title='차트 설치하기', description='차트를 설치하면 그 결과물(Deployment, Service 등)이 **릴리스**라는 이름으로 관리됩니다.

`$NS` 네임스페이스에 `bitnami/nginx` 차트를 `my-nginx` 라는 릴리스 이름으로 설치하세요.', hint='`helm install <릴리스이름> <저장소/차트> -n <네임스페이스>` 형식입니다. 릴리스 이름은 내가 정하는 설치본의 이름이고, `-n` 은 설치할 네임스페이스입니다.', solution='helm install my-nginx bitnami/nginx -n $NS

# install 릴리스이름 저장소/차트 : 차트를 설치' WHERE quest_set_id = 14 AND order_index = 4;
UPDATE quest SET title='설치된 릴리스 목록 확인하기', description='무엇이 어떤 버전으로 설치되어 있는지 확인하는 기본 명령입니다.

`$NS` 네임스페이스에 설치된 Helm 릴리스 목록을 `/tmp/helm_list.txt` 에 저장하세요.', hint='`helm list -n <네임스페이스>` 는 릴리스 이름, 상태(`deployed`), 차트 버전을 보여 줍니다. 결과를 `>` 로 저장하세요.', solution='helm list -n $NS > /tmp/helm_list.txt' WHERE quest_set_id = 14 AND order_index = 5;
UPDATE quest SET title='값을 바꿔서 설치하기', description='차트는 `values` 라는 설정값을 갖고 있어, 설치할 때 일부를 바꿀 수 있습니다(복제본 수, 이미지 버전 등).

`$NS` 네임스페이스에 `bitnami/nginx` 차트를 `custom-nginx` 릴리스로 설치하되, `replicaCount`(Pod 복제본 수)를 **2** 로 지정하세요.', hint='`helm install <릴리스> <차트> --set <키>=<값> -n <네임스페이스>` 형식입니다. `--set` 은 차트의 기본 값을 덮어쓰는 옵션이고, 값 목록은 `helm show values <차트>` 로 볼 수 있습니다.', solution='helm install custom-nginx bitnami/nginx --set replicaCount=2 -n $NS

# --set 키=값 : 차트의 기본 값을 덮어씀' WHERE quest_set_id = 14 AND order_index = 6;
UPDATE quest SET title='릴리스 업그레이드하기', description='이미 설치한 릴리스의 설정을 바꾸거나 새 버전으로 올리는 것이 **업그레이드**입니다. 변경 이력이 남아 롤백도 가능합니다.

`$NS` 네임스페이스의 `my-nginx` 릴리스를 `replicaCount=3` 으로 업그레이드하세요.', hint='`helm upgrade <릴리스> <차트> --set <키>=<값> -n <네임스페이스>` 형식입니다. 설치 때와 같은 차트를 적고 바꿀 값을 `--set` 으로 지정합니다.', solution='helm upgrade my-nginx bitnami/nginx --set replicaCount=3 -n $NS

# upgrade : 설치된 릴리스를 변경 (이력이 남음)' WHERE quest_set_id = 14 AND order_index = 7;
UPDATE quest SET title='릴리스 삭제하기', description='더 이상 필요 없는 릴리스는 삭제하면 그 릴리스가 만든 Deployment, Service 등 관련 리소스가 한꺼번에 정리됩니다.

`$NS` 네임스페이스의 `my-nginx` 릴리스를 완전히 삭제하세요.', hint='`helm uninstall <릴리스> -n <네임스페이스>` 입니다. 릴리스와 관련 리소스를 모두 제거합니다. 확인: `helm list -n <네임스페이스>`', solution='helm uninstall my-nginx -n $NS

# uninstall : 릴리스와 관련 리소스를 모두 제거' WHERE quest_set_id = 14 AND order_index = 8;
