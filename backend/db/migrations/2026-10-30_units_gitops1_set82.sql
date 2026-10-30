-- Git 세트 82. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set82.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 23, '미들웨어', 'CI/CD·레지스트리', 60 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 23);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 82, 'GitOps 와 k8s 위의 CI/CD: Argo CD, Jenkins Pod, 이미지 빌드', 'GitOps 와 Argo CD(Git 을 진실로 두고 클러스터가 당겨서 맞춘다), push 와 pull 배포의 차이, merge 가 배포이고 revert 가 롤백인 이유, 그리고 Jenkins·Gitea 같은 상태 있는 서비스를 Pod 로 운영할 때 달라지는 것(PVC, Recreate, agent Pod, daemon 없는 이미지 빌드, 설정의 코드화)과 IaC 도구(Pulumi)를 문제로 정리합니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 82);
UPDATE quest_set SET display_order = 562, unit_id = (SELECT id FROM unit WHERE id = 23), icon = '🔄' WHERE id = 82;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 1, 'GitOps 가 무엇인지 알기', '**GitOps** 의 핵심 아이디어로 알맞은 것은 무엇일까요?', '"Git 이 유일한 진실"이라는 말이 핵심입니다.', NULL, NULL, '[]', 'choice', '["운영자가 서버에 접속해 직접 명령으로 배포한다", "배포는 항상 사람이 UI 에서 클릭한다", "원하는 상태를 Git 에 선언해 두고, 시스템이 실제 환경을 그 상태에 맞춘다. 사람은 클러스터를 직접 바꾸지 않고 Git 에 커밋한다", "Git 은 코드 저장에만 쓰고 배포와 무관하다"]', 2, 'GitOps 에서는 Git 저장소를 보면 클러스터가 "어떤 상태여야 하는지"와 과거 이력을 알 수 있습니다. 클러스터가 Git 과 다르면 그것이 틀린 것으로 보고 교정합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 2, 'merge 가 배포, revert 가 롤백', 'GitOps 에서 **배포**와 **롤백**은 각각 무엇으로 이루어질까요?', '별도의 "배포 명령"이 없습니다.', NULL, NULL, '[]', 'choice', '["배포 = 원하는 상태를 적은 YAML 을 브랜치에 merge 하는 것, 롤백 = 그 커밋을 revert 하는 것이다. `git log` 가 곧 배포 로그가 된다", "배포 = `kubectl apply`, 롤백 = 서버 재부팅", "배포는 CI 서버 UI 에서만 가능하다", "롤백은 불가능하다"]', 0, '배포 기록과 Git 이력이 같은 것이라, "언제 무엇이 배포되었는가"를 따로 추적할 시스템이 필요 없습니다. 이 덕분에 앞서 배운 Git 의 revert 가 실무에서 곧바로 롤백이 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 3, 'push 와 pull 배포의 차이', 'CI 가 빌드 뒤 클러스터에 직접 `kubectl apply` 하는 **push 방식**과, 클러스터 안의 에이전트가 Git 을 당겨 오는 **pull 방식**(Argo CD)의 가장 큰 보안상 차이는 무엇일까요?', '누가 클러스터 접근 자격 증명을 들고 있어야 하나요?', NULL, NULL, '[]', 'choice', '["pull 은 Git 접근이 필요 없다", "push 가 항상 더 안전하다", "둘은 자격 증명 측면에서 완전히 같다", "push 는 CI 가 클러스터 자격 증명을 들고 있어야 하지만, pull 은 클러스터 **안**의 에이전트가 Git 을 읽기만 하면 되어 CI 가 클러스터 자격 증명을 가질 필요가 없다"]', 3, '클러스터 밖에 있는 CI 가 클러스터 관리자급 권한을 들고 있으면 CI 가 뚫릴 때 클러스터까지 위험합니다. pull 방식은 이 노출을 줄입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 4, 'Argo CD 의 핵심 루프', 'Argo CD 의 핵심 동작 루프로 알맞은 것은 무엇일까요?', '원하는 상태, 실제 상태, 비교, 맞춤입니다.', NULL, NULL, '[]', 'choice', '["클러스터를 한 번 배포한 뒤에는 더 이상 확인하지 않는다", "Git 의 원하는 상태(Desired)와 클러스터의 실제 상태(Live)를 비교(diff)하고, 다르면 실제를 원하는 상태에 맞춘다(sync). 이를 계속 반복한다", "Git 을 수정해서 클러스터 상태에 맞춘다", "Pod 를 무작위로 재시작한다"]', 1, '이 루프는 쿠버네티스의 선언형 모델(reconcile)과 같은 원리를 "Git ↔ 클러스터" 사이로 넓힌 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 5, '수동 수정이 되돌려지는 이유', '누군가 클러스터에서 `kubectl edit` 으로 Deployment 의 이미지를 직접 고쳤는데, 잠시 뒤 **원래대로 돌아갔습니다.** 가장 가능한 이유는 무엇일까요?', 'Argo CD 가 계속 비교하고 있습니다.', NULL, NULL, '[]', 'choice', '["쿠버네티스가 kubectl edit 를 막아서이다", "Pod 가 자동으로 삭제되어서이다", "Argo CD 가 다음 확인 주기에 Git 에 적힌 원래 상태와 차이를 발견해 Git 쪽으로 되돌렸기 때문이다 (Git 이 유일한 진실이라는 원칙이 강제되는 방식)", "브라우저 캐시 때문이다"]', 2, '긴급 수정이 필요하면 클러스터를 직접 고치는 대신 Git 에 변경을 커밋(또는 일시적으로 자동 동기화를 끔)해야 합니다. 직접 고치면 반영되지 않거나 곧 사라져 혼란이 생깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 6, 'GitOps 배포 흐름 놓기', '소스 코드를 수정해 push 한 뒤, GitOps 방식으로 **새 버전이 클러스터에 반영**되기까지의 흐름을 **앞에서 뒤**로 놓으세요.', '코드 → 이미지 → 매니페스트 → 클러스터 순서입니다.', NULL, NULL, '[]', 'order', '["Argo CD 가 매니페스트 저장소의 변경을 감지해 클러스터에 sync 한다", "CI 가 소스를 빌드·테스트하고 새 이미지를 레지스트리에 올린다", "매니페스트 저장소의 이미지 태그를 새 버전으로 바꾸는 커밋을 merge 한다", "개발자가 소스 저장소에 변경을 push 한다"]', NULL, '**소스 push → CI 빌드·이미지 push → 매니페스트 저장소의 이미지 태그 변경 merge → Argo CD 가 감지해 sync** 입니다. CI 는 클러스터에 직접 배포하지 않고 매니페스트 저장소까지만 건드립니다.', '[3, 1, 2, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 7, 'Pod 로 운영하는 CI 서버의 데이터', 'Jenkins 를 VM 이 아니라 **Pod** 로 운영할 때 job 설정·플러그인·빌드 이력이 쌓이는 디렉터리는 어떻게 해야 할까요?', 'Pod 의 컨테이너 파일시스템은 재시작하면 사라집니다.', NULL, NULL, '[]', 'choice', '["컨테이너 안의 임시 디렉터리에 그대로 둔다", "Pod 밖의 **PVC 로 분리**해 둔다. 그렇지 않으면 Pod 가 재시작될 때 데이터가 사라진다", "etcd 에 저장한다", "Pod 를 절대 재시작하지 않는다"]', 1, 'VM 에서는 로컬 디스크가 당연해서 의식하지 않던 경계를, Pod 에서는 직접 그어야 합니다. 상태 있는(stateful) 서비스를 휘발성 환경에 올릴 때 가장 먼저 정하는 일입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 8, '단일 인스턴스 서비스의 배포 전략', 'Jenkins 같은 **단일 인스턴스** 서비스(RWO PVC, replicas 1)를 업데이트할 때 `RollingUpdate` 대신 **`Recreate`** 를 쓰는 이유는 무엇일까요?', '같은 데이터 디렉터리를 두 프로세스가 동시에 쓰면 어떻게 되나요?', NULL, NULL, '[]', 'choice', '["Recreate 가 더 빨라서이다", "RollingUpdate 는 쓸 수 없는 값이라서이다", "Recreate 는 PVC 를 삭제해서이다", "RollingUpdate 는 새 Pod 가 뜨는 동안 옛 Pod 가 같은 볼륨을 쥐고 있어 충돌하거나 데이터가 깨질 수 있어서, 옛 Pod 를 먼저 내리고 새 Pod 를 올린다"]', 3, '대신 업데이트 중 짧은 중단이 생깁니다. 이 서비스들은 본질적으로 단일 인스턴스라 고가용성보다 데이터 보호를 우선합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 9, '빌드마다 뜨는 agent Pod', 'Jenkins Kubernetes plugin 이 **빌드마다 agent Pod 를 만들고 끝나면 지우는** 방식의 장단점으로 알맞은 것은 무엇일까요?', '도구는 이미지에 담기고, Pod 는 매번 새로 뜹니다.', NULL, NULL, '[]', 'choice', '["빌드가 몰리면 클러스터 자원만큼 늘고 없으면 0개라 효율적이지만, 매번 새 Pod 라 Gradle/Maven 같은 **빌드 캐시가 사라진다** (캐시용 PVC 로 보완)", "캐시가 항상 유지되어 빌드가 빨라진다", "agent 는 항상 한 대로 고정된다", "빌드 도구를 서버에 미리 설치해 둔다"]', 0, '도구는 설치하는 것이 아니라 이미지에 담습니다. 일회용 환경이라 빌드의 재현성이 좋아지는 장점도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 10, 'daemon 없는 이미지 빌드', '클러스터 런타임이 containerd 라서 빌드 agent Pod 에 **docker.sock 이 없습니다.** 이미지를 빌드하는 방법으로 권한 부담이 더 적은 것은 무엇일까요?', 'daemon 없이 Pod 안에서 이미지를 빌드하는 도구가 있습니다.', NULL, NULL, '[]', 'choice', '["호스트의 docker.sock 을 모든 Pod 에 마운트한다", "빌드를 하지 않고 이미지를 직접 손으로 만든다", "Kaniko, BuildKit, buildah 처럼 **daemon 없이** 빌드하는 도구 (DinD 는 privileged 가 필요해 보안 부담이 크다)", "privileged 로 DinD 를 항상 쓰는 것이 가장 안전하다"]', 2, 'VM 에서는 호스트의 docker.sock 으로 끝났지만 Pod 환경에서는 선택지를 정해야 합니다. 권한 요구를 줄이는 방향이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 11, '설정을 코드로 관리하기', 'Pod 로 운영하는 Jenkins 와 Gitea 의 설정을 **재배포해도 유지**되게 하는 방법으로 알맞은 것은 무엇일까요?', 'UI 클릭이나 파일 직접 수정은 재시작 때 어긋납니다.', NULL, NULL, '[]', 'choice', '["UI 에서 설정한 뒤 Pod 를 절대 재시작하지 않는다", "Jenkins 는 JCasC(YAML), Gitea 는 `GITEA__section__key` 환경변수, 값은 Helm values 에, 비밀번호·토큰은 Secret 에 두어 설정을 코드로 선언한다", "컨테이너 안의 설정 파일을 손으로 고친다", "비밀번호도 Helm values 평문에 둔다"]', 1, '이렇게 하면 클러스터를 다시 만들어도 같은 CI/CD 환경이 재현됩니다. VM 의 "손으로 키운 서버"와 가장 대비되는 점입니다. 비밀은 Secret 으로 분리합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 12, 'IaC 도구: Pulumi 의 특징', '**Pulumi** 가 Terraform 과 다른 점으로 알맞은 것은 무엇일까요?', '목표는 같고 인프라를 "무엇으로" 쓰는가가 다릅니다.', NULL, NULL, '[]', 'choice', '["Pulumi 는 상태 파일이 필요 없다", "Pulumi 는 인프라를 코드로 쓰지 않는다", "Terraform 은 범용 언어만 지원한다", "Terraform 은 전용 선언형 언어(HCL)로 쓰지만 Pulumi 는 TypeScript, Python, Go 같은 **범용 프로그래밍 언어**로 인프라를 선언한다 (반복문·조건문·테스트를 그대로 쓸 수 있다)"]', 3, '둘 다 "원하는 상태"를 선언하고 차이만 만듭니다. 로직이 복잡할 때 범용 언어가 유리하지만, 결과 형태가 사람마다 갈릴 수 있고 Terraform 의 생태계가 더 큽니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 82, 13, 'CI/CD 를 클러스터 위에 두면 생기는 순환 의존', 'CI/CD 서버를 **같은 클러스터 위**에 올렸을 때 조심할 점으로 알맞은 것은 무엇일까요?', '클러스터가 죽었을 때 그것을 고칠 도구는 어디에 있나요?', NULL, NULL, '[]', 'choice', '["클러스터가 장애로 죽으면 그것을 고칠 배포 도구도 함께 죽는 **순환 의존**이 생긴다. 그래서 CI/CD 만 클러스터 밖에 두는 구성도 고려한다", "아무 문제가 없다", "클러스터가 죽어도 배포 도구는 항상 살아 있다", "백업이 필요 없어진다"]', 0, '이 때문에 백업(PVC 스냅샷, Velero, `gitea dump`)도 다시 설계해야 합니다. 이미 클러스터가 있고 빌드 부하가 들쭉날쭉하면 Pod, 단순하고 안정적인 CI 한 대가 목표면 VM 이 쉬울 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 82 AND order_index = 13);
