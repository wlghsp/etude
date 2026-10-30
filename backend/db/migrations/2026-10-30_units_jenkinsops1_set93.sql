-- 리눅스 세트 93. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set93.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 23, '미들웨어', 'CI/CD·레지스트리', 60 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 23);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 93, 'Jenkins 운영 실무: PVC 속 결과물 찾기, 도구 컨테이너로 git 쓰기', '쿠버네티스에서 Jenkins 를 운영할 때 자주 부딪히는 일을 익힙니다. 빌드 결과물이 들어 있는 PVC 폴더를 찾는 흐름(Pod → PVC → PV → 실제 경로), agent Pod 방식에서 workspace 가 어디에 있는지, PVC 가 가득 찼을 때 큰 job 찾기, 그리고 호스트에 git 이 없을 때 git 이 든 컨테이너 이미지로 소스를 다루는 방법과 dubious ownership 오류를 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 93);
UPDATE quest_set SET display_order = 563, unit_id = (SELECT id FROM unit WHERE id = 23), icon = '🧰' WHERE id = 93;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 1, 'PVC 에서 실제 저장 위치까지 따라가기', '`jenkins` 네임스페이스의 Jenkins 가 **어느 PVC 를 쓰고, 그 PVC 가 가리키는 PV 가 실제로 어디에 있는지** 확인하는 명령 흐름입니다. 빈칸을 채우세요.', 'PVC 는 요청서, PV 는 실제 저장소입니다. PVC 를 먼저 보고 PV 로 넘어갑니다. 같은 칩을 두 칸에 써도 됩니다.', NULL, NULL, '[]', 'fill', '["pvc", "pv", "pod"]', NULL, '`describe pvc` 의 `Volume:` 줄이 연결된 **PV 이름**입니다. 그 PV 의 yaml 에서 실제 저장 방식이 보입니다(`nfs.server`·`nfs.path`, `local.path`, `hostPath.path`, 또는 CSI 볼륨 정보). 그 위치를 알면 해당 서버나 노드에 들어가 폴더를 열 수 있습니다.', '[0, 0, 1]', 'kubectl get {0} -n jenkins
kubectl describe {1} jenkins -n jenkins | grep Volume
kubectl get {2} <위에서 나온 PV 이름> -o yaml', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 2, 'Pod 안의 결과물을 내 PC 로 꺼내기', '실행 중인 `jenkins-0` Pod 의 `/var/jenkins_home/jobs/app/builds/12/archive` 폴더를 **현재 위치의 `./out`** 으로 복사하려고 합니다. 빈칸을 채우세요.', '파일이나 폴더를 Pod 와 로컬 사이에서 복사하는 kubectl 하위 명령입니다.', NULL, NULL, '[]', 'fill', '["cp", "exec", "get", "logs"]', NULL, '`kubectl cp 네임스페이스/Pod:경로 로컬경로` 형식입니다. Pod 안에 `tar` 가 있어야 동작합니다. PVC 를 직접 열 수 없을 때 이 방법으로 결과물을 꺼낼 수 있습니다.', '[0]', 'kubectl {0} jenkins/jenkins-0:/var/jenkins_home/jobs/app/builds/12/archive ./out', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 3, '호스트에 git 이 없을 때: 도구 컨테이너로 실행', '서버에 git 을 설치하지 않고, **git 이 들어 있는 컨테이너 이미지**에 현재 폴더를 연결해 `git status` 를 실행하려고 합니다. 빈칸을 채우세요.', '이미지 이름과 그 이미지에 넘길 git 인자를 고릅니다. (이 이미지는 실행 시 `git` 이 자동으로 호출됩니다)', NULL, NULL, '[]', 'fill', '["alpine/git", "busybox", "status", "git status"]', NULL, '`-v` 로 호스트 폴더를 컨테이너에 연결하고 `-w` 로 작업 위치를 정하면, 서버에 아무것도 설치하지 않고 이미지 안의 git 을 쓸 수 있습니다. `--rm` 은 끝나면 컨테이너를 지웁니다. `alpine/git` 은 진입점이 `git` 이라 인자만 `status` 로 넘기고, `git status` 로 쓰면 `git git status` 가 됩니다. (Jenkins 의 Kubernetes agent 이미지에도 git 이 들어 있는 것이 흔합니다.)', '[0, 2]', 'docker run --rm -v "$PWD":/work -w /work {0} {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 4, 'Jenkins 결과물이 있는 PVC 폴더를 찾는 순서 놓기', 'Kubernetes 에서 Jenkins 빌드 결과물이 들어 있는 **실제 폴더**를 찾아가는 순서를 **앞에서 뒤**로 놓으세요.', 'Pod 에서 시작해 저장소의 실제 위치까지 한 단계씩 내려갑니다.', NULL, NULL, '[]', 'order', '["그 PV 의 실제 저장 방식(NFS 경로, 로컬 경로 등)을 확인한다", "Pod 가 사용하는 PVC 이름을 확인한다 (`describe pod` 의 Volumes)", "해당 서버(또는 Pod 안)에서 `jobs/<job>/builds/<번호>/archive` 폴더를 연다", "PVC 가 연결된 PV 이름을 확인한다 (`describe pvc` 의 Volume)"]', NULL, '**Pod → PVC → PV → 실제 저장 위치 → 폴더** 순서입니다. 저장소 종류에 따라 NFS 서버의 export 경로, 노드의 local 경로 등이 나옵니다. 위치를 몰라도 Pod 안에서 `ls /var/jenkins_home` 로 바로 볼 수도 있습니다.', '[1, 3, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 5, 'agent Pod 방식에서 workspace 의 위치', 'Jenkins 를 **빌드마다 agent Pod 를 만드는 방식**으로 쓸 때, 빌드 중에 소스를 내려받아 작업하는 **workspace** 는 어디에 있을까요?', '빌드가 끝나면 agent Pod 는 삭제됩니다.', NULL, NULL, '[]', 'choice', '["항상 컨트롤러의 PVC 안 `workspace` 폴더에 영구 보관된다", "노드의 `/tmp` 에만 있다", "agent Pod 안(보통 emptyDir)에 있어 빌드가 끝나 Pod 가 지워지면 사라진다. 컨트롤러의 PVC 에는 보관하도록 지정한 아카이브·로그·설정이 남는다", "etcd 에 저장된다"]', 2, '그래서 "빌드 결과물이 PVC 에 없다"는 일이 생깁니다. 남겨야 할 파일은 파이프라인에서 **아티팩트로 아카이브**(`archiveArtifacts`)하거나 외부 저장소에 올려야 합니다. 아카이브된 결과물은 컨트롤러의 `jobs/<job>/builds/<번호>/archive` 아래에 쌓입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 6, '서버에 git 이 없을 때의 선택', '서버에 git 이 없고 패키지 저장소에서도 받을 수 없습니다. **도구 컨테이너로 git 을 쓰는 방식**의 장점으로 알맞은 것은 무엇일까요?', '호스트를 깨끗하게 유지하는 방법입니다.', NULL, NULL, '[]', 'choice', '["서버에 아무것도 설치하지 않고, 이미 가진 이미지(예: Jenkins agent 이미지)에 들어 있는 git 으로 작업할 수 있으며 끝나면 컨테이너와 함께 사라진다", "컨테이너 안에서 한 작업은 호스트 폴더에 절대 반영되지 않는다", "컨테이너를 쓰면 git 인증이 필요 없어진다", "이미지를 받는 데 인터넷이 항상 필요하다"]', 0, '볼륨으로 연결한 폴더에는 결과가 그대로 남습니다. 컨테이너 안의 설정(`git config --global`)은 `--rm` 이면 컨테이너와 함께 사라지므로 다시 띄울 때마다 설정해야 합니다. 이 방식은 폐쇄된 환경에서 설치 없이 도구를 쓰는 흔한 방법입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 7, 'PVC 가 가득 찼을 때', 'Jenkins 의 PVC 가 **가득 차서** 빌드가 실패하기 시작했습니다. 가장 알맞은 대응 순서는 무엇일까요?', '무엇이 용량을 차지하는지부터 알아야 합니다.', NULL, NULL, '[]', 'choice', '["PVC 안의 파일을 한꺼번에 모두 삭제한다", "볼륨을 통째로 삭제하고 새로 만든다", "재부팅하면 용량이 늘어난다", "어떤 job 이 용량을 많이 쓰는지 찾아(`du`), 오래된 빌드와 아카이브를 정리하고 **빌드 보관 정책**(보관할 빌드 수·기간)을 설정한 뒤 필요하면 PVC 용량을 늘린다"]', 3, '빌드 기록과 아티팩트가 계속 쌓이는 것이 흔한 원인입니다. 정리 없이 PVC 만 늘리면 같은 일이 반복됩니다. 스토리지가 확장을 지원하는지(`allowVolumeExpansion`)도 확인해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 8, '가장 최근 빌드의 결과물 폴더 찾기', '`/tmp/lab/jenkins_home/jobs/app/builds/` 아래에는 빌드 번호별 폴더가 있습니다. **번호가 가장 큰(최근) 빌드의 `archive` 폴더 전체 경로**를 `/tmp/lab/latest.txt` 에 저장하세요.', '폴더 이름은 숫자인데 `ls` 의 기본 정렬은 글자순이라 `9` 가 `10` 보다 뒤에 옵니다. 숫자로 정렬하는 옵션을 쓰세요.\\n확인: `ls /tmp/lab/jenkins_home/jobs/app/builds`', 'N=$(ls /tmp/lab/jenkins_home/jobs/app/builds | sort -n | tail -n 1)
echo "/tmp/lab/jenkins_home/jobs/app/builds/$N/archive" > /tmp/lab/latest.txt
cat /tmp/lab/latest.txt

# sort -n : 숫자 크기로 정렬 (글자순이면 9 가 10 보다 뒤)', '["sh", "-c", "rm -rf /tmp/lab && for i in 1 2 3 9 10 12; do mkdir -p /tmp/lab/jenkins_home/jobs/app/builds/$i/archive; echo x > /tmp/lab/jenkins_home/jobs/app/builds/$i/archive/app.jar; done"]', '["sh", "-c", "( [ -s /tmp/lab/latest.txt ] ) && ( [ \\"$(cat /tmp/lab/latest.txt)\\" = \\"/tmp/lab/jenkins_home/jobs/app/builds/12/archive\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/latest.txt ]"]}, {"label": "가장 큰 번호(12)의 archive 경로다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lab/latest.txt)\\" = \\"/tmp/lab/jenkins_home/jobs/app/builds/12/archive\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 9, '용량을 가장 많이 쓰는 job 찾기', '`/tmp/lab/jenkins_home/jobs/` 아래 job 폴더들 중 **용량이 가장 큰 job 의 이름**(폴더 이름만)을 `/tmp/lab/biggest.txt` 에 저장하세요.', '`du -s` 로 폴더별 크기를 구하고 `sort -rn` 으로 큰 순서로 정렬해 맨 위를 봅니다. 경로에서 이름만 남기려면 `basename` 이나 `awk -F/` 를 씁니다.', 'du -s /tmp/lab/jenkins_home/jobs/* | sort -rn | head -n 1 | awk ''{print $2}'' | xargs basename > /tmp/lab/biggest.txt
cat /tmp/lab/biggest.txt

# du -s : 폴더 전체 크기, sort -rn : 큰 숫자부터', '["sh", "-c", "rm -rf /tmp/lab && for j in app web batch; do mkdir -p /tmp/lab/jenkins_home/jobs/$j/builds/1/archive; done; head -c 1000000 /dev/zero > /tmp/lab/jenkins_home/jobs/app/builds/1/archive/a.bin; head -c 100000 /dev/zero > /tmp/lab/jenkins_home/jobs/web/builds/1/archive/w.bin; head -c 3000000 /dev/zero > /tmp/lab/jenkins_home/jobs/batch/builds/1/archive/b.bin"]', '["sh", "-c", "( [ -s /tmp/lab/biggest.txt ] ) && ( [ \\"$(cat /tmp/lab/biggest.txt)\\" = batch ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/biggest.txt ]"]}, {"label": "가장 큰 job 은 batch 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lab/biggest.txt)\\" = batch ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 93, 10, 'dubious ownership 오류 해결하기', '`/tmp/lab/work/app` 은 다른 사용자 소유의 git 저장소라 `git status` 가 **`detected dubious ownership`** 오류로 막힙니다. 이 저장소를 **안전한 디렉터리로 등록**해서 `git status` 가 동작하게 하고, `git status -sb` 의 **첫 줄**을 `/tmp/lab/status.txt` 에 저장하세요.', '오류 메시지가 안내하는 설정(`git config --global --add safe.directory 경로`)을 쓰세요. 먼저 `cd /tmp/lab/work/app && git status` 로 오류를 확인해 보세요.', 'cd /tmp/lab/work/app
git status                    # 오류
git config --global --add safe.directory /tmp/lab/work/app
git status -sb | head -n 1 > /tmp/lab/status.txt
cat /tmp/lab/status.txt

# 마운트한 폴더의 소유자가 컨테이너 사용자와 다를 때 자주 생긴다. ''*'' 로 모두 허용할 수도 있지만 보안상 필요한 경로만 등록하는 편이 안전하다', '["sh", "-c", "rm -rf /tmp/lab && git config --global user.name tester && git config --global user.email tester@example.com && git config --global --unset-all safe.directory 2>/dev/null; mkdir -p /tmp/lab/work/app && cd /tmp/lab/work/app && git init -q -b main && echo a > f && git add . && git commit -qm init && chown -R 1000:1000 /tmp/lab/work"]', '["sh", "-c", "( [ -s /tmp/lab/status.txt ] ) && ( [ \\"$(cat /tmp/lab/status.txt)\\" = \\"## main\\" ] ) && ( git config --global --get-all safe.directory | grep -qE \\"^(/tmp/lab/work/app|\\\\*)$\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/status.txt ]"]}, {"label": "첫 줄이 ## main 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lab/status.txt)\\" = \\"## main\\" ]"]}, {"label": "저장소가 안전한 디렉터리로 등록되었다", "cmd": ["sh", "-c", "git config --global --get-all safe.directory | grep -qE \\"^(/tmp/lab/work/app|\\\\*)$\\""]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 93 AND order_index = 10);
