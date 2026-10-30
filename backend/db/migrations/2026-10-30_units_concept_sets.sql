-- 기초 단원 앞의 '개념 먼저 이해하기' 세트 40(도커)·41(k8s)·42(리눅스). 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set40~42.sql, 05_display_order.sql, 06_units.sql. docs/specs/spec_question_types.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 42, '리눅스 기초 개념 먼저 이해하기', '파일 경로, 권한, 프로세스처럼 리눅스 실습의 바탕이 되는 개념을 터미널 없이 먼저 확인합니다. 순서 맞추기, 빈칸 채우기, 객관식으로 가볍게 풀어요.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 42);
UPDATE quest_set SET display_order = 5, unit_id = (SELECT id FROM unit WHERE id = 1) WHERE id = 42; -- 단원이 있을 때만 연결

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 1, '절대 경로와 상대 경로 구분하기', '지금 위치(현재 디렉터리)가 `/home/kim` 입니다. `/etc/hosts` 와 `docs/memo.txt` 는 각각 어떤 경로일까요?', '경로가 `/` 로 시작하면 어디서든 같은 곳을 가리키는 절대 경로이고, 아니면 지금 위치에서부터 따라가는 상대 경로입니다.', NULL, NULL, '[]', 'choice', '["둘 다 절대 경로다", "`/etc/hosts` 는 절대 경로(맨 앞이 `/`), `docs/memo.txt` 는 상대 경로(현재 위치 `/home/kim` 기준)다", "`/etc/hosts` 는 상대 경로, `docs/memo.txt` 는 절대 경로다", "둘 다 상대 경로다"]', 1, '`/` 로 시작하는 `/etc/hosts` 는 루트부터 시작하는 **절대 경로**라서 어디서 실행해도 같은 파일입니다. `docs/memo.txt` 는 현재 위치 기준이라 `/home/kim/docs/memo.txt` 를 가리키는 **상대 경로**입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 2, '숨김 파일까지 자세히 보는 ls 옵션 채우기', '`/home/kim` 의 파일을 **숨김 파일(이름이 `.` 으로 시작하는 파일)까지 포함해서 자세히** 보려고 합니다. 명령의 빈칸을 채우세요.', '`-l` 은 자세히(권한·크기·날짜), `-a` 는 숨김 파일 포함입니다. 옵션은 붙여 쓸 수 있습니다.', NULL, NULL, '[]', 'fill', '["-l", "-a", "-la", "-R"]', NULL, '`-l` 은 권한·소유자·크기·날짜를 자세히 보여 주고, `-a` 는 `.` 으로 시작하는 숨김 파일까지 보여 줍니다. 둘을 붙여 `-la` 로 쓰면 둘 다 적용됩니다. `-R` 은 하위 디렉터리까지 재귀로 보는 옵션입니다.', '[2]', 'ls {0} /home/kim'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 3, 'ls -l 결과에서 그룹 권한 읽기', '`ls -l` 결과에 `-rwxr-xr--  1 kim dev  120  app.sh` 가 보입니다. 이 파일의 소유자는 `kim`, 그룹은 `dev` 입니다. `dev` 그룹에 속한 **다른 사용자**는 이 파일로 무엇을 할 수 있을까요?', '권한 9칸은 소유자, 그룹, 그 밖의 사람 순서로 세 칸씩 끊어 읽습니다: `rwx` `r-x` `r--`. `r` 읽기, `w` 쓰기, `x` 실행, `-` 없음.', NULL, NULL, '[]', 'choice', '["읽고 실행할 수 있지만 수정(쓰기)은 못 한다", "읽고 쓰고 실행할 수 있다", "읽기만 할 수 있다", "아무것도 못 한다"]', 0, '권한은 `rwx`(소유자) `r-x`(그룹) `r--`(그 밖의 사람)입니다. 그룹은 `r-x` 라서 읽기와 실행은 되지만 쓰기(`w`)는 없습니다. 그 밖의 사람은 `r--` 라서 읽기만 됩니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 4, '새 파일을 만들고 쓰고 확인하고 지우는 순서대로 놓기', '`notes.txt` 라는 파일을 다루는 명령들이 섞여 있습니다. **자연스러운 작업 순서**대로 놓으세요.', '파일이 있어야 쓸 수 있고, 써야 확인할 내용이 있고, 다 쓴 뒤에 지웁니다.', NULL, NULL, '[]', 'order', '["`rm notes.txt` 로 파일 지우기", "`cat notes.txt` 로 내용 확인하기", "`touch notes.txt` 로 빈 파일 만들기", "`echo hello > notes.txt` 로 내용 쓰기"]', NULL, '`touch` 로 빈 파일을 만들고, `echo ... >` 로 내용을 쓰고, `cat` 으로 확인한 뒤, 필요 없으면 `rm` 으로 지웁니다. (`echo ... >` 는 파일이 없으면 스스로 만들기도 하지만, 순서를 익히기 위한 흐름입니다.)', '[2, 3, 1, 0]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 5, 'kill 의 기본 신호 알기', '`kill 1234` 처럼 **신호 종류를 적지 않고** 프로세스를 종료시키려 하면, 기본으로 보내는 신호는 무엇일까요?', '기본 신호는 "정리할 시간을 주고 정상 종료해 달라"는 요청입니다. 강제로 죽이는 신호는 `-9` 를 따로 적어야 합니다.', NULL, NULL, '[]', 'choice', '["`SIGKILL`(9), 즉시 강제로 죽인다", "`SIGTERM`(15), 프로세스에게 정리하고 정상 종료해 달라고 요청한다", "`SIGSTOP`, 프로세스를 일시 중지한다", "아무 신호도 보내지 않는다"]', 1, '`kill` 의 기본 신호는 `SIGTERM`(15)입니다. 프로세스가 열어 둔 파일을 닫는 등 정리하고 끝낼 기회를 줍니다. 말을 듣지 않을 때만 `kill -9`(SIGKILL)로 강제 종료합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 6, '/proc 의 파일이 무엇인지 알기', '`/proc` 디렉터리에는 `cpuinfo`, `meminfo` 같은 파일이 있습니다. 이 파일들은 무엇일까요?', '"리눅스는 모든 것을 파일처럼 다룬다"는 말의 대표적인 예입니다.', NULL, NULL, '[]', 'choice', '["디스크에 저장된 일반 텍스트 파일이다", "커널이 지금의 시스템 상태(CPU, 메모리, 프로세스 등)를 파일처럼 보여 주는 가상 파일이다", "설치된 프로그램의 목록이다", "사용자 비밀번호가 담긴 파일이다"]', 1, '`/proc` 은 커널이 만들어 보여 주는 **가상 파일 시스템**입니다. `cat /proc/meminfo` 처럼 읽으면 그 순간의 메모리 상태가 나옵니다. 디스크에 저장된 파일이 아니라서 읽을 때마다 값이 달라질 수 있습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 42, 7, 'cd ~ 가 이동하는 곳 고르기', '`cd ~` 를 입력하면 어디로 이동할까요?', '`~`(물결표)는 "내 집"을 뜻하는 줄임 표기입니다.', NULL, NULL, '[]', 'choice', '["루트 디렉터리 `/`", "현재 사용자의 홈 디렉터리", "직전에 있던 디렉터리", "부모 디렉터리"]', 1, '`~` 는 현재 사용자의 **홈 디렉터리**를 뜻합니다. `kim` 이라면 `/home/kim` 입니다. 그냥 `cd` 만 써도 홈으로 갑니다. 직전 디렉터리는 `cd -`, 부모 디렉터리는 `cd ..` 입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 42 AND order_index = 7);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 40, 'Docker 개념 먼저 이해하기', '이미지와 컨테이너, 레지스트리, 포트 연결, 볼륨 같은 Docker 의 기본 개념을 터미널 없이 먼저 확인합니다. 순서 맞추기, 빈칸 채우기, 객관식으로 가볍게 풀어요.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 40);
UPDATE quest_set SET display_order = 175, unit_id = (SELECT id FROM unit WHERE id = 5) WHERE id = 40; -- 단원이 있을 때만 연결

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 1, '이미지와 컨테이너의 차이 구분하기', 'Docker 를 처음 쓸 때 가장 헷갈리는 두 낱말입니다. **이미지**와 **컨테이너**의 관계로 알맞은 것은 무엇일까요?', '요리에 비유하면 이미지는 "레시피와 재료 세트", 컨테이너는 그것으로 "만든 요리"입니다.', NULL, NULL, '[]', 'choice', '["이미지는 실행 중인 프로세스이고, 컨테이너는 그것을 저장한 파일이다", "이미지는 컨테이너를 만들기 위한 읽기 전용 설계도(템플릿)이고, 컨테이너는 그 이미지를 실행한 것이다", "이미지와 컨테이너는 같은 것을 부르는 다른 이름이다", "컨테이너는 이미지가 아닌 가상 머신 파일이다"]', 1, '**이미지**는 컨테이너를 만들 때 쓰는 읽기 전용 템플릿입니다. 같은 이미지로 **컨테이너**를 여러 개 실행할 수 있고, 각 컨테이너는 서로 독립된 실행 상태를 가집니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 2, '이미지를 받아 컨테이너를 실행하고 정리하는 순서대로 놓기', 'nginx 이미지로 컨테이너를 실행하고 정리하는 명령이 섞여 있습니다. **일반적인 작업 순서**대로 놓으세요.', '이미지를 받고, 컨테이너로 실행하고, 확인한 뒤, 멈추고, 지웁니다. 실행 중인 컨테이너는 먼저 멈춰야 지울 수 있습니다.', NULL, NULL, '[]', 'order', '["`docker stop web` 으로 멈추기", "`docker ps` 로 실행 중인 컨테이너 확인", "`docker run -d --name web nginx` 로 컨테이너 실행", "`docker rm web` 으로 컨테이너 지우기", "`docker pull nginx` 로 이미지 내려받기"]', NULL, '`pull`(이미지 받기) → `run`(컨테이너 실행) → `ps`(확인) → `stop`(멈추기) → `rm`(컨테이너 지우기) 순서입니다. `docker run` 은 이미지가 없으면 자동으로 받기도 하지만, 단계를 구분해 익히기 위한 흐름입니다.', '[4, 2, 1, 0, 3]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 3, '-p 옵션으로 포트 연결하는 빈칸 채우기', '내 컴퓨터의 **8080 포트**로 접속하면 컨테이너 안 nginx 의 **80 포트**로 연결되도록 명령의 빈칸을 채우세요.', '`-p 내컴퓨터포트:컨테이너포트` 순서입니다. nginx 는 컨테이너 안에서 80 포트를 씁니다.', NULL, NULL, '[]', 'fill', '["8080", "80", "443", "3306"]', NULL, '`-p 호스트포트:컨테이너포트` 입니다. `8080:80` 은 내 컴퓨터 8080 으로 온 요청을 컨테이너의 80 으로 보냅니다. 그러면 `http://localhost:8080` 으로 접속해 nginx 가 응답합니다.', '[0, 1]', 'docker run -d --name web -p {0}:{1} nginx'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 4, 'docker ps 와 docker ps -a 의 차이 알기', '컨테이너를 멈춘 뒤 `docker ps` 를 실행했더니 목록에 보이지 않습니다. 멈춘 컨테이너까지 보려면 어떻게 해야 할까요?', '`docker ps` 는 기본으로 **실행 중인** 컨테이너만 보여 줍니다. 전부 보여 달라는 옵션이 있습니다.', NULL, NULL, '[]', 'choice', '["`docker ps -a` (all 의 약자, 멈춘 컨테이너까지 모두 보여 준다)", "`docker ps -r` (running 만 보여 준다)", "`docker images` (컨테이너 목록을 보여 준다)", "멈춘 컨테이너는 자동으로 지워져서 볼 수 없다"]', 0, '`docker ps` 는 실행 중인 컨테이너만, `docker ps -a` 는 멈춘(종료된) 컨테이너까지 모두 보여 줍니다. 멈춘 컨테이너는 직접 `docker rm` 으로 지우기 전까지 남아 있습니다. `docker images` 는 이미지 목록입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 5, '컨테이너를 지우면 안의 데이터가 어떻게 되는지 알기', '컨테이너 안에서 파일을 만들어 두었습니다. 그 컨테이너를 `docker rm` 으로 지우면 그 파일은 어떻게 될까요? 그리고 데이터를 남기려면 무엇을 써야 할까요?', '컨테이너의 쓰기 공간은 컨테이너와 함께 사라집니다. 컨테이너 밖에 따로 보관하는 저장소가 필요합니다.', NULL, NULL, '[]', 'choice', '["그대로 남는다", "컨테이너와 함께 사라진다. 남기려면 볼륨(volume)이나 바인드 마운트를 쓴다", "이미지에 자동으로 저장된다", "`docker rm` 은 데이터를 지우지 않고 이름만 지운다"]', 1, '컨테이너 안에서 쓴 파일은 그 컨테이너의 쓰기 공간에 저장돼서 컨테이너를 지우면 같이 사라집니다. 데이터를 남기려면 컨테이너 밖에 보관하는 **볼륨**(`-v 이름:/경로`)이나 호스트 폴더를 연결하는 **바인드 마운트**를 씁니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 6, '레지스트리가 하는 일 알기', 'Docker Hub 같은 **레지스트리**는 무엇을 하는 곳일까요?', '`docker pull` 은 어디서 이미지를 내려받을까요? `docker push` 는 어디로 올릴까요?', NULL, NULL, '[]', 'choice', '["컨테이너를 실행하는 서버를 빌려 준다", "이미지를 저장하고 공유하는 저장소다 (`pull` 로 받고 `push` 로 올린다)", "컨테이너 안의 로그를 모아 보여 준다", "Dockerfile 을 자동으로 만들어 준다"]', 1, '레지스트리는 이미지를 저장하고 공유하는 곳입니다. `docker pull` 로 내려받고 `docker push` 로 올립니다. 회사 안에서 쓰는 사설 레지스트리도 같은 방식으로 동작합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 7, '레지스트리에서 이미지만 내려받는 명령 채우기', 'Docker Hub 에서 `nginx:1.25` 이미지를 **내려받기만** 하고 컨테이너는 실행하지 않으려고 합니다. 명령의 빈칸을 채우세요.', '이미지를 내려받는 하위 명령 하나만 필요합니다. 올리는 명령, 만드는 명령, 실행하는 명령과 헷갈리지 마세요.', NULL, NULL, '[]', 'fill', '["pull", "push", "build", "run"]', NULL, '`docker pull` 은 레지스트리에서 이미지를 내려받기만 합니다. `push` 는 올리기, `build` 는 Dockerfile 로 이미지 만들기, `run` 은 컨테이너 실행입니다.', '[0]', 'docker {0} nginx:1.25'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 40, 8, '가상 머신과 컨테이너의 차이 알기', '컨테이너가 가상 머신(VM)보다 가볍고 빠르게 시작되는 가장 큰 이유는 무엇일까요?', 'VM 은 게스트 운영체제를 통째로 하나 더 띄웁니다. 컨테이너는 무엇을 함께 쓸까요?', NULL, NULL, '[]', 'choice', '["컨테이너는 하드웨어를 직접 제어한다", "컨테이너는 호스트의 커널을 공유해서 운영체제를 따로 띄우지 않는다", "컨테이너는 파일을 압축해서 쓴다", "컨테이너는 CPU 를 사용하지 않는다"]', 1, 'VM 은 가상 하드웨어 위에 게스트 운영체제 전체를 띄우지만, 컨테이너는 **호스트의 커널을 공유**하고 프로세스를 격리해서 실행합니다. 그래서 크기가 작고 시작이 빠릅니다. 대신 호스트 커널과 같은 종류의 운영체제만 쓸 수 있습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 40 AND order_index = 8);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 41, 'k8s 개념 먼저 이해하기', 'Pod, Deployment, Service, Namespace, ConfigMap 과 Secret 같은 쿠버네티스의 기본 개념을 터미널 없이 먼저 확인합니다. 순서 맞추기, 빈칸 채우기, 객관식으로 가볍게 풀어요.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 41);
UPDATE quest_set SET display_order = 205, unit_id = (SELECT id FROM unit WHERE id = 6) WHERE id = 41; -- 단원이 있을 때만 연결

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 1, 'Pod 가 무엇인지 알기', '쿠버네티스에서 애플리케이션을 실행하는 가장 작은 배포 단위는 무엇일까요?', '컨테이너를 직접 다루지 않고, 컨테이너를 감싸는 단위를 만듭니다.', NULL, NULL, '[]', 'choice', '["컨테이너 한 개를 반드시 하나만 담는 상자이다", "컨테이너를 하나 이상 담는 가장 작은 배포 단위인 Pod 이다", "여러 대의 서버를 묶은 클러스터이다", "이미지를 저장하는 저장소이다"]', 1, '**Pod** 는 쿠버네티스가 다루는 가장 작은 배포 단위입니다. 보통 컨테이너 하나를 담지만, 함께 움직여야 하는 컨테이너를 여러 개 담을 수도 있고, 같은 Pod 안의 컨테이너는 네트워크(localhost)와 저장소를 나눠 씁니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 2, 'Deployment 가 하는 일 알기', 'Pod 를 직접 만들지 않고 **Deployment** 로 만드는 이유로 알맞은 것은 무엇일까요?', 'Pod 가 죽으면 누가 다시 만들어 줄까요? 개수를 늘리거나 새 버전으로 바꿀 때는요?', NULL, NULL, '[]', 'choice', '["Deployment 가 있어야만 Pod 가 시작된다", "원하는 Pod 개수를 유지하고(죽으면 다시 만든다), 롤링 업데이트와 롤백을 해 준다", "Deployment 는 Pod 보다 항상 빠르다", "Deployment 는 네트워크 접속 주소를 만든다"]', 1, 'Deployment 는 "이 Pod 를 3개 유지해라"를 선언해 두면 개수를 맞춰 주고(죽으면 새로 만들고), 새 버전으로 천천히 바꾸는 롤링 업데이트와 되돌리는 롤백도 해 줍니다. 네트워크 주소는 Service 가 담당합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 3, '앱을 배포하고 늘리고 노출하는 kubectl 순서대로 놓기', 'nginx 앱을 배포하고 Pod 를 늘리고 Service 로 노출하는 명령이 섞여 있습니다. **자연스러운 작업 순서**대로 놓으세요.', '먼저 배포하고 확인한 뒤, 개수를 늘리고, 마지막에 접속할 수 있게 Service 를 만들어 확인합니다.', NULL, NULL, '[]', 'order', '["`kubectl expose deployment web --port=80` 로 Service 만들기", "`kubectl scale deployment web --replicas=3` 로 3개로 늘리기", "`kubectl get pods` 로 Pod 확인", "`kubectl create deployment web --image=nginx` 로 앱 배포", "`kubectl get svc` 로 Service 확인"]', NULL, '`create deployment`(배포) → `get pods`(확인) → `scale`(개수 늘리기) → `expose`(Service 로 노출) → `get svc`(확인) 순서입니다. Service 는 Pod 가 늘거나 바뀌어도 변하지 않는 접속 주소를 줍니다.', '[3, 2, 1, 0, 4]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 4, 'kubectl scale 명령의 빈칸 채우기', 'Deployment `web` 의 Pod 개수를 **3개**로 바꾸려고 합니다. 명령의 빈칸을 채우세요.', '개수를 바꾸는 하위 명령 하나와, `--replicas=` 뒤에 올 숫자가 필요합니다.', NULL, NULL, '[]', 'fill', '["scale", "get", "describe", "3", "80"]', NULL, '`kubectl scale` 은 Deployment 의 복제본(replicas) 개수를 바꿉니다. `get` 은 목록 조회, `describe` 는 자세한 정보 보기입니다. `80` 은 포트 번호처럼 보이지만 개수와는 관계없습니다.', '[0, 3]', 'kubectl {0} deployment web --replicas={1}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 5, 'Service 가 필요한 이유 알기', 'Pod 는 죽었다 다시 만들어질 때마다 **IP 주소가 바뀝니다.** 그런데도 다른 앱이 항상 같은 주소로 접속할 수 있게 해 주는 것은 무엇일까요?', '바뀌지 않는 이름과 주소를 주고, 뒤의 여러 Pod 로 요청을 나눠 줍니다.', NULL, NULL, '[]', 'choice', '["ConfigMap", "Namespace", "Service (고정된 접속 주소를 주고 뒤의 Pod 들로 요청을 나눠 준다)", "Node"]', 2, '**Service** 는 라벨로 고른 Pod 들 앞에 고정된 가상 IP 와 이름을 붙이고, 요청을 그 Pod 들로 나눠 줍니다. Pod 의 IP 가 바뀌어도 Service 주소는 그대로라서 안정적으로 접속할 수 있습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 6, 'Namespace 의 역할 알기', '하나의 클러스터에서 팀이나 환경(예: dev, prod)별로 리소스를 나눠서 쓰고 싶습니다. 어떤 것을 쓰면 될까요?', '같은 이름의 리소스를 서로 다른 구역에 만들 수 있어야 합니다.', NULL, NULL, '[]', 'choice', '["Pod", "Namespace (클러스터 안의 리소스를 이름으로 나누는 구역)", "Deployment", "Secret"]', 1, '**Namespace** 는 한 클러스터 안에서 리소스를 논리적으로 나누는 구역입니다. 같은 이름의 리소스도 Namespace 가 다르면 따로 존재할 수 있고, 권한이나 자원 제한을 구역별로 줄 수도 있습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 7, 'ConfigMap 과 Secret 구분하기', '앱에 넘길 값 두 가지가 있습니다. (가) 로그 레벨 `INFO`, (나) 데이터베이스 비밀번호. 쿠버네티스에서 각각 무엇에 담는 것이 알맞을까요?', '일반 설정과 민감한 값은 따로 다룹니다.', NULL, NULL, '[]', 'choice', '["(가) Secret, (나) ConfigMap", "(가) ConfigMap, (나) Secret", "둘 다 ConfigMap", "둘 다 Namespace"]', 1, '일반 설정 값은 **ConfigMap**, 비밀번호나 토큰 같은 민감한 값은 **Secret** 에 담습니다. Secret 은 기본적으로 base64 로 인코딩될 뿐 암호화는 아니라서, 접근 권한을 제한하고 필요하면 암호화 설정을 함께 써야 합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 41, 8, 'CrashLoopBackOff 상태 읽기', '`kubectl get pods` 에서 어떤 Pod 의 상태가 `CrashLoopBackOff` 로 보입니다. 무슨 뜻일까요?', '컨테이너가 시작되자마자 죽고, 쿠버네티스가 다시 시작하기를 반복하는 상태입니다.', NULL, NULL, '[]', 'choice', '["이미지를 내려받는 중이다", "컨테이너가 시작한 뒤 계속 죽어서 재시작을 반복하고 있다", "노드에 자리가 없어 아직 배치되지 않았다", "정상적으로 종료되었다"]', 1, '`CrashLoopBackOff` 는 컨테이너가 시작 직후 계속 종료되어 쿠버네티스가 재시작을 반복하는 상태입니다(재시작 간격이 점점 길어집니다). 원인은 `kubectl logs` 와 `kubectl describe` 로 찾습니다. 이미지를 받는 중은 `ContainerCreating`/`ImagePullBackOff`, 자리가 없으면 `Pending` 입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 41 AND order_index = 8);

-- 개념 세트 아이콘 (입문 표시)
UPDATE quest_set SET icon = '🔰' WHERE id IN (40, 41, 42);
