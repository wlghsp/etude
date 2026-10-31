-- 미들웨어 세트 116. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set116.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 23, '미들웨어', 'CI/CD·레지스트리', 60 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 23);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 116, 'CI/CD·레지스트리 문제 해결 상황집: push/pull 오류, 인증서, 빌드 로그', 'Jenkins·Nexus·Harbor 를 쓰다 만나는 장애를 증상에서 원인으로 좁히는 법을 익힙니다. 이미지 이름과 push 순서, unauthorized 와 denied 의 차이, 사설 CA 인증서 오류(x509), 413 업로드 제한, 릴리스 저장소의 재배포 거절, 빌드 로그에서 첫 실패 찾기, 오래된 태그 정리 목록 만들기, executor 대기 원인을 문제와 파일 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 116);
UPDATE quest_set SET display_order = 564, unit_id = (SELECT id FROM unit WHERE id = 23), icon = '🧰' WHERE id = 116;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 1, '이미지를 레지스트리에 올리는 세 단계', '로컬에서 만든 `app:1.0` 이미지를 사설 레지스트리 `registry.example.com:5000` 의 `team` 프로젝트에 올립니다. **로그인 → 이름 붙이기(tag) → 올리기** 순서로 명령의 빈칸을 채우세요.', '로그인과 올리기에 해당하는 영어 동사예요.', NULL, NULL, '[]', 'fill', '["login", "push", "pull", "build"]', NULL, '레지스트리에 올리려면 이미지 이름이 `레지스트리주소/프로젝트/이미지:태그` 모양이어야 합니다. 그래서 `docker tag` 로 이름을 붙인 뒤 `docker push` 합니다. 로그인(`docker login`)이 안 되어 있으면 push 에서 막혀요.', '[0, 1]', 'docker {0} registry.example.com:5000
docker tag app:1.0 registry.example.com:5000/team/app:1.0
docker {1} registry.example.com:5000/team/app:1.0', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 2, 'pull access denied / unauthorized', 'k8s Pod 가 `ImagePullBackOff` 이고 이벤트에 `pull access denied ... unauthorized: authentication required` 가 보입니다. 사설 레지스트리의 이미지입니다. 가장 알맞은 조치는 무엇일까요?', '레지스트리가 "누구세요?"라고 되묻는 상황이에요.', NULL, NULL, '[]', 'choice', '["이미지 태그를 latest 로 바꾼다", "노드를 재부팅한다", "Pod 의 CPU 요청을 늘린다", "레지스트리 접속 정보를 담은 `imagePullSecret` 을 만들고 Pod(또는 ServiceAccount)에 연결한다"]', 3, '`unauthorized`, `authentication required` 는 인증 문제입니다. 사설 레지스트리는 로그인 정보가 필요하므로 `kubectl create secret docker-registry` 로 시크릿을 만들고 `imagePullSecrets` 로 연결하세요. 이미지가 정말 없을 때는 `not found` 가 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 3, 'x509: certificate signed by unknown authority', '`docker pull registry.example.com/team/app:1.0` 이 `x509: certificate signed by unknown authority` 로 실패합니다. 레지스트리는 내부 인증기관(사설 CA)이 발급한 인증서를 씁니다. 가장 올바른 해결은 무엇일까요?', '인증서를 "누가 발급했는지" 클라이언트가 모르는 상황이에요.', NULL, NULL, '[]', 'choice', '["인증서 검증을 영구히 끄도록 설정한다", "클라이언트(Docker 나 containerd)에 그 사설 CA 인증서를 신뢰하도록 등록한다. insecure 설정은 임시 확인용으로만 쓴다", "레지스트리 서버를 재시작한다", "이미지 이름을 대문자로 바꾼다"]', 1, '인증서 자체가 틀린 것이 아니라 발급자를 모르는 문제입니다. Docker 는 `/etc/docker/certs.d/레지스트리주소/ca.crt` 에 CA 인증서를 두면 신뢰해요. 검증을 끄는 `insecure-registries` 는 중간자 공격에 노출되므로 영구 해결책이 아닙니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 4, '빌드 로그에서 실패한 단계 찾기', '`/tmp/build.log` 는 Jenkins 빌드 로그입니다. ① **처음 나온** `ERROR` 줄을 `/tmp/cause.txt` 에, ② 그 `ERROR` 가 나온 **스테이지 줄**(`stage` 가 들어간 가장 가까운 앞 줄)을 `/tmp/stage.txt` 에 저장하세요.', '첫 ERROR 는 `grep -m1 ERROR`. 스테이지는 `awk ''/stage/{s=$0} /ERROR/{print s; exit}''` 처럼 마지막으로 본 stage 줄을 기억해 두면 돼요.
확인: `cat /tmp/build.log`', 'cat /tmp/build.log
grep -m1 ERROR /tmp/build.log > /tmp/cause.txt
awk ''/stage/{s=$0} /ERROR/{print s; exit}'' /tmp/build.log > /tmp/stage.txt
cat /tmp/cause.txt /tmp/stage.txt

# 뒤에 나온 ERROR 는 앞 실패의 결과인 경우가 많다. 가장 먼저 나온 ERROR 가 원인이다', '["sh", "-c", "rm -f /tmp/cause.txt /tmp/stage.txt && printf ''%s\\\\n'' ''[Pipeline] stage (Checkout)'' ''Cloning repository'' ''[Pipeline] stage (Build)'' ''BUILD OK'' ''[Pipeline] stage (Test)'' ''ERROR: Tests failed: 3 failures in OrderServiceTest'' ''[Pipeline] stage (Deploy)'' ''ERROR: Skipped due to earlier failure'' ''Finished: FAILURE'' > /tmp/build.log"]', '["sh", "-c", "( [ \\"$(cat /tmp/cause.txt)\\" = \\"ERROR: Tests failed: 3 failures in OrderServiceTest\\" ] ) && ( grep -q \\"(Test)\\" /tmp/stage.txt ) && ( ! grep -q Deploy /tmp/stage.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "cause.txt 가 첫 ERROR 줄이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/cause.txt)\\" = \\"ERROR: Tests failed: 3 failures in OrderServiceTest\\" ]"]}, {"label": "stage.txt 에 Test 스테이지가 있다", "cmd": ["sh", "-c", "grep -q \\"(Test)\\" /tmp/stage.txt"]}, {"label": "Deploy 가 원인으로 잘못 잡히지 않았다", "cmd": ["sh", "-c", "! grep -q Deploy /tmp/stage.txt"]}]', '[{"title": "Jenkins Pipeline 문서", "url": "https://www.jenkins.io/doc/book/pipeline/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 5, '이미지 push 가 실패할 때 점검 순서', '레지스트리로 `docker push` 가 실패합니다. 순서에 맞게 놓아 보세요.', '내 쪽 설정에서 서버 쪽 설정으로 점검해요.', NULL, NULL, '[]', 'order', '["오류 메시지(denied, unauthorized, x509, timeout)를 읽어 종류를 구분한다", "`docker login` 상태와 계정이 맞는지 확인한다", "이미지 이름의 레지스트리 주소·프로젝트·태그가 맞는지 확인한다", "프로젝트가 있는지, 내 계정에 push 권한이 있는지 확인한다", "네트워크·인증서·용량(quota) 같은 서버 쪽 문제를 확인한다"]', NULL, '메시지 종류가 가장 큰 단서입니다. 그다음 내 로그인과 이미지 이름처럼 쉽게 확인되는 것부터, 권한과 서버 쪽 문제로 넓혀 가세요.', '[0, 1, 2, 3, 4]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 6, 'denied: requested access to the resource is denied', '로그인은 성공했는데 `docker push registry.example.com/team/app:1.0` 이 `denied: requested access to the resource is denied` 로 실패합니다. 가장 먼저 확인할 것은 무엇일까요?', '로그인은 "누구인지", 권한은 "무엇을 할 수 있는지"예요.', NULL, NULL, '[]', 'choice', '["컨테이너의 메모리 제한", "이미지 크기가 너무 작은지", "`team` 프로젝트가 레지스트리에 있는지, 내 계정이 그 프로젝트에 push 권한(역할)을 가졌는지", "호스트의 시간대 설정"]', 2, '로그인에 성공했는데 denied 라면 인증이 아니라 **권한 또는 대상**의 문제입니다. 프로젝트가 없거나 오타이거나, 내 계정의 역할이 읽기 전용일 수 있어요. Harbor 에서는 프로젝트 멤버 역할을 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 7, '이미지 전체 이름 만들기', '`/tmp/info.txt` 에 `REGISTRY`, `PROJECT`, `IMAGE` 가 적혀 있습니다. 이 값들을 읽어 `레지스트리/프로젝트/이미지` 모양의 **전체 이름**을 `/tmp/tag.txt` 에 저장하세요. (예: `주소/프로젝트/이름:태그`)', '`. /tmp/info.txt` 로 변수를 읽어 들인 뒤 `echo "$REGISTRY/$PROJECT/$IMAGE"` 를 쓰세요.', '. /tmp/info.txt
echo "$REGISTRY/$PROJECT/$IMAGE" > /tmp/tag.txt
cat /tmp/tag.txt

# docker tag 나 push 에 이 이름을 그대로 쓴다. 주소·프로젝트·이름·태그가 한 줄에 모인다', '["sh", "-c", "rm -f /tmp/tag.txt && printf ''%s\\\\n'' ''REGISTRY=registry.example.com:5000'' ''PROJECT=team'' ''IMAGE=nginx:1.25'' > /tmp/info.txt"]', '["sh", "-c", "( [ -s /tmp/tag.txt ] ) && ( [ \\"$(cat /tmp/tag.txt)\\" = \\"registry.example.com:5000/team/nginx:1.25\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "tag.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/tag.txt ]"]}, {"label": "전체 이름이 맞다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/tag.txt)\\" = \\"registry.example.com:5000/team/nginx:1.25\\" ]"]}]', '[{"title": "Jenkins Pipeline 문서", "url": "https://www.jenkins.io/doc/book/pipeline/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 8, '업로드가 413 으로 막혀요', '빌드 결과물(큰 JAR)을 Nexus 로 올리는데 `413 Request Entity Too Large` 가 납니다. Nexus 앞에는 리버스 프록시가 있습니다. 가장 알맞은 해석은 무엇일까요?', '413 은 "요청 본문이 너무 크다"는 뜻이고, 가장 앞단이 먼저 응답해요.', NULL, NULL, '[]', 'choice', '["프록시(예: nginx 의 `client_max_body_size`)가 허용하는 본문 크기를 넘었다. 프록시의 제한을 올린다", "Nexus 의 저장소가 삭제됐다", "클라이언트 계정 비밀번호가 틀렸다", "인증서가 만료됐다"]', 0, '인증 실패는 401, 권한은 403 이고 413 은 크기 제한입니다. 요청은 프록시를 먼저 지나므로 프록시의 본문 크기 제한부터 확인해야 해요. 그 뒤에 Nexus 자체 제한도 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 9, 'curl 로 Nexus 에 파일 올리기', '빌드한 `app-1.0.jar` 를 Nexus 의 릴리스 저장소에 **HTTP PUT 으로 올리는** 명령입니다. `curl` 에서 파일을 업로드하는 옵션을 채우세요. (계정은 예시입니다)', '파일을 "올린다"는 뜻의 옵션이에요.', NULL, NULL, '[]', 'fill', '["--upload-file", "--output", "--head", "--get"]', NULL, '`--upload-file`(또는 `-T`)은 파일을 PUT 으로 올립니다. 반대로 내려받을 때는 `-O` 나 `--output` 을 씁니다. 비밀번호는 명령 기록에 남으니 실제로는 토큰을 환경변수나 설정 파일에서 읽는 편이 안전해요.', '[0]', 'curl -u user:token {0} app-1.0.jar \\
  https://nexus.example.com/repository/maven-releases/com/example/app/1.0/app-1.0.jar', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 10, '릴리스 저장소에 다시 올리면 400', '`app-1.0.jar` 를 수정해서 같은 버전으로 다시 올렸더니 Nexus 가 `400 Repository does not allow updating assets: maven-releases` 라고 거절합니다. 올바른 대응은 무엇일까요?', '릴리스는 "한 번 배포하면 바뀌지 않는 것"이 원칙이에요.', NULL, NULL, '[]', 'choice', '["저장소의 재배포 허용을 켜 같은 버전을 계속 덮어쓴다", "기존 파일을 몰래 삭제하고 올린다", "이 오류는 무시해도 된다", "릴리스 저장소는 재배포를 막는 것이 정상이므로, 버전을 올려(1.0.1) 새로 배포한다. 반복 테스트용은 SNAPSHOT 저장소를 쓴다"]', 3, '같은 버전이 내용이 다르면 누가 받았는지에 따라 결과가 달라져 재현이 불가능해집니다. 릴리스는 불변으로 두고 버전을 올리세요. 개발 중에는 덮어쓸 수 있는 SNAPSHOT 을 쓰는 것이 관례예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 11, '오래된 태그만 골라 정리 목록 만들기', '`/tmp/tags.txt` 는 레지스트리에 쌓인 이미지 태그 목록입니다. `latest` 와 **가장 최신 3개 버전**은 남기고, 나머지 **삭제 대상**을 **버전 순서(오래된 것부터)** 로 `/tmp/delete.txt` 에 저장하세요. (`v1.10` 이 `v1.2` 보다 최신입니다)', '`sort` 만 쓰면 `v1.10` 이 `v1.2` 앞에 와요. 버전 정렬은 `sort -V` 입니다. 끝에서 3개를 빼고 싶으면 `head -n -3`.
확인: `cat /tmp/tags.txt`', 'grep -v ''^latest$'' /tmp/tags.txt | sort -V | head -n -3 > /tmp/delete.txt
cat /tmp/delete.txt

# 지우기 전에 목록부터 만들어 눈으로 확인한다. latest 와 최신 몇 개는 남긴다', '["sh", "-c", "rm -f /tmp/delete.txt && printf ''%s\\\\n'' v1.10 v1.2 v1.9 latest v1.1 v1.12 v1.5 v1.11 v1.3 v1.8 v1.4 v1.7 v1.6 > /tmp/tags.txt"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/delete.txt)\\" -eq 9 ] ) && ( [ \\"$(head -n 1 /tmp/delete.txt)\\" = v1.1 ] && [ \\"$(tail -n 1 /tmp/delete.txt)\\" = v1.9 ] ) && ( ! grep -qE \\"^(latest|v1.10|v1.11|v1.12)$\\" /tmp/delete.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "삭제 대상이 9개이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/delete.txt)\\" -eq 9 ]"]}, {"label": "가장 오래된 v1.1 부터 v1.9 까지이다", "cmd": ["sh", "-c", "[ \\"$(head -n 1 /tmp/delete.txt)\\" = v1.1 ] && [ \\"$(tail -n 1 /tmp/delete.txt)\\" = v1.9 ]"]}, {"label": "latest 와 최신 3개는 포함되지 않는다", "cmd": ["sh", "-c", "! grep -qE \\"^(latest|v1.10|v1.11|v1.12)$\\" /tmp/delete.txt"]}]', '[{"title": "Jenkins Pipeline 문서", "url": "https://www.jenkins.io/doc/book/pipeline/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 116, 12, 'Waiting for next available executor', 'Jenkins 빌드가 시작되지 않고 `Waiting for next available executor` 로 계속 대기합니다. Jenkinsfile 은 `agent { label ''linux-build'' }` 입니다. 가장 먼저 확인할 것은 무엇일까요?', '빌드를 실행할 "일꾼(executor)"이 있는지, 라벨이 맞는지 봐요.', NULL, NULL, '[]', 'choice', '["소스 저장소의 브랜치 이름", "`linux-build` 라벨을 가진 agent 가 온라인인지, 남는 executor 가 있는지", "레지스트리의 디스크 용량", "Jenkinsfile 의 주석 개수"]', 1, '라벨에 맞는 agent 가 없거나 모두 offline, 또는 executor 가 전부 사용 중이면 대기합니다. Manage Nodes 화면에서 라벨, 온라인 여부, 실행 중인 빌드를 확인하세요. 라벨 오타도 흔한 원인이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 116 AND order_index = 12);
