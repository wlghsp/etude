-- 기본기 사다리 2: 세트 45(리눅스 명령어 해부하기)·46(kubectl 명령과 YAML 해부하기). 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set45/46.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 45, '명령어 해부하기: 복사하기 전에 읽는 법', '인터넷에서 복사한 명령을 무슨 뜻인지 모른 채 붙여 넣고 있진 않나요? 명령·옵션·인자를 나눠 읽는 법, 낯선 명령을 쓸 때의 안전한 순서, 위험한 명령을 알아보는 눈, 실행 결과를 미리 짐작하는 연습을 터미널 없이 합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 45);
UPDATE quest_set SET display_order = 28, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🔬' WHERE id = 45;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 1, '명령, 옵션, 인자 구분해서 읽기', '`tar -czvf backup.tgz /etc` 를 처음 봤습니다. 이 한 줄을 **명령 / 옵션 / 인자**로 나눠 읽으면 어떻게 될까요?', '맨 앞이 실행할 프로그램(명령), `-` 로 시작하는 것이 동작을 바꾸는 옵션, 나머지는 명령이 다룰 대상(인자)입니다.', NULL, NULL, '[]', 'choice', '["명령 `tar`, 옵션 `-czvf`, 인자 `backup.tgz` 와 `/etc`", "명령 `tar -czvf`, 옵션 `backup.tgz`, 인자 `/etc`", "명령 `-czvf`, 옵션 `tar`, 인자 `backup.tgz /etc`", "전부 명령이다"]', 0, '명령(프로그램)은 맨 앞의 `tar`, `-` 로 시작하는 `-czvf` 는 옵션(동작을 바꾸는 스위치), 나머지 `backup.tgz`(만들 파일)와 `/etc`(묶을 대상)는 인자입니다. 모르는 명령은 **이렇게 세 조각으로 나눠 놓고 한 조각씩** 의미를 찾으면 읽을 수 있습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 2, 'tar 옵션 뜻을 읽고 빈칸 채우기', '`/etc` 를 **묶고(create) gzip 으로 압축해서** `backup.tgz` 파일로 만들려고 합니다. 옵션의 뜻은 `c` 묶기(create), `z` gzip 압축, `f` 파일 이름 지정입니다. 빈칸을 채우세요.', '묶으려면 `c`, 압축하려면 `z`, 만들 파일 이름을 바로 뒤에 쓰려면 `f` 가 필요합니다. 풀기(`x`)나 목록 보기(`t`)와 헷갈리지 마세요.', NULL, NULL, '[]', 'fill', '["-czf", "-xzf", "-tzf", "-cf"]', NULL, '`-czf` = create(묶기) + gzip 압축 + file(파일 이름 지정)입니다. `-xzf` 는 압축을 **풀 때**(extract), `-tzf` 는 안에 무엇이 있는지 **목록만 볼 때**(list), `-cf` 는 묶기만 하고 압축은 하지 않습니다. 옵션은 한 글자씩 뜻이 있으니 하나씩 풀어 읽으면 됩니다.', '[0]', 'tar {0} backup.tgz /etc'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 3, '낯선 명령을 쓰기 전의 안전한 순서대로 놓기', '인터넷에서 본 `rm /tmp/old*` 라는 명령을 써 보려고 합니다. 그냥 붙여 넣지 않고 **안전한 순서**로 해 보려면 어떻게 해야 할까요? 순서대로 놓으세요.', '뜻을 먼저 알아보고, 지울 대상이 맞는지 눈으로 확인한 뒤, 실행하고, 결과를 확인합니다. 삭제는 되돌릴 수 없습니다.', NULL, NULL, '[]', 'order', '["`rm /tmp/old*` 로 실제 지우기", "`ls /tmp/old*` 로 지울 대상이 맞는지 먼저 보기", "`rm --help` 로 명령과 옵션의 뜻 읽기", "`ls /tmp` 로 결과 확인하기"]', NULL, '**뜻 읽기(`--help`/`man`) → 대상 미리 보기(같은 패턴을 `ls` 로) → 실행 → 결과 확인** 순서입니다. 특히 `*` 같은 패턴은 생각보다 많이 잡힐 수 있어서, 지우기 전에 `ls` 로 같은 패턴을 먼저 보는 습관이 사고를 막아 줍니다.', '[2, 1, 0, 3]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 4, '복사해서 붙이기 전에 가장 조심해야 할 명령 고르기', '인터넷에서 찾은 명령 네 개 중 **붙여 넣기 전에 가장 조심해서 읽어야 하는** 것은 무엇일까요?', '되돌릴 수 없고 범위가 넓은 명령이 위험합니다. `~` 는 홈 디렉터리, `*` 는 전부를 뜻합니다.', NULL, NULL, '[]', 'choice', '["`ls -l /etc`", "`cat /etc/hosts`", "`rm -rf ~/*`", "`pwd`"]', 2, '`rm -rf ~/*` 는 홈 디렉터리 안의 **모든 것을 확인 없이 지웁니다.** (`-r` 하위 폴더까지, `-f` 묻지 않고) `ls`, `cat`, `pwd` 는 읽기만 하는 명령이라 위험하지 않습니다. 지우는(`rm`), 덮어쓰는(`>`), 권한을 바꾸는(`chmod -R`) 명령은 특히 의미를 확인하고 실행하세요.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 5, '> 로 덮어쓰기가 위험한 이유 알기', '`/etc/hosts` 에 줄 하나를 추가하려고 `echo "10.0.0.5 web" > /etc/hosts` 를 실행했습니다. 무슨 일이 생길까요?', '`>` 는 파일을 새로 만들며 **기존 내용을 지웁니다.** 기존 내용 뒤에 붙이는 기호는 따로 있습니다.', NULL, NULL, '[]', 'choice', '["기존 내용 뒤에 한 줄이 추가된다", "기존 내용이 모두 지워지고 그 한 줄만 남는다", "아무 일도 일어나지 않는다", "파일이 읽기 전용으로 바뀐다"]', 1, '`>` 는 파일을 **덮어씁니다.** 이 명령은 `/etc/hosts` 의 기존 내용을 모두 지우고 한 줄만 남깁니다. 줄을 **추가**하려면 `>>` 를 씁니다. 중요한 설정 파일에 쓰기 전에는 `cp` 로 백업해 두는 습관이 좋습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 6, 'curl 결과를 바로 sh 에 넘기는 명령의 위험 알기', '설치 안내에 `curl -s https://example.com/install.sh | sh` 라고 적혀 있습니다. 이 한 줄의 위험은 무엇일까요?', '`|` 는 앞 명령의 출력을 뒤 명령에 넘깁니다. 내려받은 글이 그대로 쉘의 입력이 되면 어떻게 될까요?', NULL, NULL, '[]', 'choice', '["위험이 없다", "내려받은 스크립트의 내용을 보지 않고 바로 실행하게 된다 (내용이 바뀌거나 악의가 있어도 알 수 없다)", "속도가 너무 느려진다", "파일이 두 번 저장된다"]', 1, '`curl ... | sh` 는 내려받은 글(스크립트)을 **읽어 보지도 않고 곧바로 실행**합니다. 더 안전한 방법은 먼저 파일로 받고(`curl -o install.sh ...`), 내용을 읽어 본 뒤(`less`/`cat`) 실행하는 것입니다. 믿을 수 있는 출처인지도 확인하세요.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 7, '명령 앞 sudo 의 뜻 알기', '복사한 명령 앞에 `sudo` 가 붙어 있습니다. 이것은 무슨 뜻이고, 왜 더 조심해야 할까요?', '`sudo` 는 다른 사용자(보통 관리자 root)의 권한으로 실행하라는 뜻입니다.', NULL, NULL, '[]', 'choice', '["명령을 천천히 실행한다", "관리자(root) 권한으로 실행한다. 시스템 전체에 영향을 줄 수 있어 더 신중히 읽어야 한다", "명령을 취소한다", "명령 결과를 저장한다"]', 1, '`sudo` 는 관리자 권한으로 명령을 실행합니다. 일반 사용자라면 막힐 일(시스템 파일 수정, 서비스 중지, 삭제)도 되어 버리므로, `sudo` 가 붙은 명령은 **무엇을 어디에 하는지** 더 꼼꼼히 확인하고 붙여 넣어야 합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 8, 'ls 옵션 -lh 읽기', '`ls -lh /var/log` 에서 `-l` 과 `-h` 는 각각 무슨 뜻일까요?', '`-l` 은 길게(long) 자세히, `-h` 는 사람이 읽기 쉽게(human-readable) 입니다. 크기가 어떻게 표시될까요?', NULL, NULL, '[]', 'choice', '["`-l` 숨김 파일까지, `-h` 도움말", "`-l` 자세히(권한·크기·날짜), `-h` 크기를 K·M 같은 읽기 쉬운 단위로", "`-l` 이름 순서, `-h` 최근 것 먼저", "`-l` 한 줄로, `-h` 숨기기"]', 1, '`-l` 은 권한·소유자·크기·날짜를 한 줄씩 **자세히** 보여 주고, `-h`(human-readable)는 크기를 바이트 대신 `4.0K`, `1.2M` 처럼 읽기 쉬운 단위로 바꿉니다. 옵션은 `-lh` 처럼 붙여 쓸 수 있습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 9, 'df 옵션으로 읽기 쉬운 용량 보기', '디스크 사용량을 보는 `df` 명령의 결과가 바이트 숫자로 길게 나옵니다. **사람이 읽기 쉬운 단위(GB, MB)** 로 보려면 어떤 옵션을 붙여야 할까요? 빈칸을 채우세요.', '앞 문제의 `ls -lh` 의 `h` 와 같은 뜻입니다.', NULL, NULL, '[]', 'fill', '["-h", "-a", "-i", "-T"]', NULL, '`-h`(human-readable)는 `df` 와 `ls`, `du`, `free` 등 여러 명령에서 **읽기 쉬운 단위**를 뜻하는 공통 옵션입니다. `-a` 는 모두, `-i` 는 inode, `-T` 는 파일 시스템 종류를 보여 줍니다. 같은 글자가 명령마다 비슷한 뜻을 가진다는 것을 알아 두면 읽기 쉬워집니다.', '[0]', 'df {0}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 10, '명령을 실행하기 전에 결과 예측하기', '`echo "a b c" | wc -w` 를 실행하면 화면에 무엇이 나올까요? (`wc -w` 는 단어 수를 센다)', '`echo` 가 `a b c` 를 내보내고, `|` 로 `wc -w` 에 넘깁니다. 공백으로 나뉜 덩어리가 단어입니다.', NULL, NULL, '[]', 'choice', '["1", "3", "5", "오류가 난다"]', 1, '`echo "a b c"` 가 `a b c` 를 출력하고 파이프(`|`)로 `wc -w` 가 받아서 공백으로 나뉜 단어 `a`, `b`, `c` 세 개를 셉니다. 실행하기 전에 **결과를 미리 짐작**해 보는 습관은 명령을 이해했는지 확인하는 가장 좋은 방법입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 45, 11, '연결 기호가 든 명령 한 줄 풀어 읽기', '`cd /tmp && ls | wc -l` 을 풀어서 읽으면 어떻게 될까요?', '`&&` 는 앞이 성공해야 뒤를 실행, `|` 는 앞의 출력을 뒤로 넘깁니다. 왼쪽부터 한 덩어리씩 읽습니다.', NULL, NULL, '[]', 'choice', '["`/tmp` 로 이동하는 데 성공하면, 그곳의 항목 목록을 만들어 개수를 센다", "`/tmp` 와 `ls` 를 동시에 실행한다", "`ls` 의 결과를 `/tmp` 로 이동시킨다", "`/tmp` 가 있든 없든 항상 `wc -l` 만 실행한다"]', 0, '왼쪽부터 읽으면 `cd /tmp` (이동) → 성공하면(`&&`) → `ls`(목록) → 그 출력을 파이프(`|`)로 → `wc -l`(줄 수 세기)입니다. 즉 "/tmp 로 가서 그 안의 항목이 몇 개인지 센다"입니다. 연결 기호를 만나면 거기서 끊어서 한 덩어리씩 읽으세요.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 45 AND order_index = 11);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 46, 'kubectl 명령과 YAML 해부하기', 'kubectl 명령이 어떤 구조로 이루어져 있는지, Deployment YAML 의 각 부분이 무슨 뜻인지, 라벨과 셀렉터가 어떻게 이어지는지를 클러스터 없이 읽고 맞춰 봅니다. 복사해서 붙이기 전에 읽는 힘을 기릅니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 46);
UPDATE quest_set SET display_order = 207, unit_id = (SELECT id FROM unit WHERE id = 6), icon = '🔬' WHERE id = 46;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 1, 'kubectl 명령의 구조 읽기', '`kubectl get pods -n dev -o wide` 를 조각으로 나누면 어떻게 읽을까요?', 'kubectl 은 `동사 자원 이름 옵션` 순서로 읽습니다. `-n` 은 어느 구역(네임스페이스)에서인지, `-o` 는 어떤 형식으로 보여 줄지입니다.', NULL, NULL, '[]', 'choice', '["동사 `get`, 자원 `pods`, 네임스페이스 `dev`, 출력 형식 `wide`(자세히)", "동사 `pods`, 자원 `get`, 네임스페이스 `wide`, 출력 형식 `dev`", "동사 `kubectl`, 자원 `get`, 이름 `pods`", "전부 옵션이다"]', 0, '`kubectl <동사> <자원> [이름] [옵션]` 구조입니다. `get`(조회) `pods`(Pod 들) `-n dev`(dev 네임스페이스에서) `-o wide`(IP·노드까지 자세히)로 읽습니다. 동사를 `delete`, `describe`, `logs` 등으로 바꾸면 같은 구조로 다른 일을 합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 2, 'kubectl 명령 빈칸 채우기: dev 의 Pod 목록', '`dev` 네임스페이스에 있는 **Pod 목록을 조회**하려고 합니다. 명령의 빈칸을 채우세요.', '조회하는 동사와 네임스페이스 이름이 필요합니다. 지우는 동사(`delete`)와 헷갈리지 마세요.', NULL, NULL, '[]', 'fill', '["get", "delete", "dev", "logs", "wide"]', NULL, '`get` 은 조회, `-n` 은 네임스페이스를 지정합니다. `-n dev` 를 빼면 현재 기본 네임스페이스(보통 `default`)를 봅니다. `delete` 는 지우는 동사라서, 복사한 명령에서 동사가 `delete` 인지 `get` 인지를 가장 먼저 확인하세요.', '[0, 2]', 'kubectl {0} pods -n {1}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 3, 'Deployment YAML 의 최상위 항목 순서대로 놓기', 'Deployment 를 만드는 YAML 파일의 **최상위 항목**이 섞여 있습니다. 일반적으로 쓰는 순서대로 놓으세요.', '"무슨 버전의 API 로, 어떤 종류를, 이름과 라벨은, 원하는 상태는"이라고 읽으면 순서가 보입니다.', NULL, NULL, '[]', 'order', '["`spec:` (원하는 상태: 개수, 컨테이너 등)", "`kind: Deployment` (자원의 종류)", "`apiVersion: apps/v1` (사용할 API 버전)", "`metadata:` (이름, 라벨 같은 식별 정보)"]', NULL, '쿠버네티스 YAML 은 거의 모두 `apiVersion` → `kind` → `metadata` → `spec` 입니다. 무슨 API 로(`apiVersion`) 어떤 종류(`kind`)를 어떤 이름으로(`metadata`) 어떤 상태로(`spec`) 만들지 순서대로 적습니다.', '[2, 1, 3, 0]', NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 4, 'YAML 들여쓰기의 의미 알기', 'YAML 에서 줄 앞의 **들여쓰기(공백)** 는 무슨 의미일까요?', 'YAML 은 괄호가 아니라 들여쓰기로 "안에 들어 있다"를 표현합니다. 탭 문자는 쓰지 않습니다.', NULL, NULL, '[]', 'choice', '["보기 좋게 하려는 장식이라 의미가 없다", "위아래 항목의 포함 관계(어디 안에 속하는지)를 나타내서, 어긋나면 의미가 달라지거나 오류가 난다", "들여쓴 줄은 주석으로 처리된다", "들여쓴 줄은 무시된다"]', 1, 'YAML 의 들여쓰기는 **계층(포함 관계)** 입니다. 같은 깊이는 같은 단계이고, 더 들여쓴 줄은 바로 위 항목의 하위입니다. 공백 수가 어긋나면 엉뚱한 곳에 속하거나 오류가 납니다. 탭 문자는 허용되지 않으니 공백(보통 2칸)을 쓰세요.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 5, 'Pod 개수를 정하는 YAML 필드 찾기', 'Deployment YAML 에서 **Pod 를 몇 개 유지할지** 정하는 필드는 무엇이고 어디에 쓸까요?', 'Deployment 에게 "원하는 상태"를 알려 주는 부분 안에 있습니다.', NULL, NULL, '[]', 'choice', '["`metadata.replicas`", "`spec.replicas` (spec 아래에 `replicas: 3` 처럼 쓴다)", "`kind.replicas`", "`apiVersion.replicas`"]', 1, '원하는 Pod 개수는 `spec` 아래의 `replicas` 입니다. `metadata` 는 이름·라벨 같은 식별 정보이고, "몇 개를 원하는가"는 원하는 상태인 `spec` 에 속합니다. `kubectl scale --replicas=3` 도 같은 값을 바꿉니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 6, 'Deployment YAML 의 kind 와 replicas 빈칸 채우기', '아래 YAML 로 이름이 `web` 인 **Deployment** 를 만들고 Pod 를 **3개** 유지하려고 합니다. 빈칸을 채우세요.', '`kind` 에는 자원의 종류를, `replicas` 에는 유지할 Pod 개수를 씁니다.', NULL, NULL, '[]', 'fill', '["Deployment", "Service", "Pod", "3", "80"]', NULL, '`apps/v1` 은 Deployment 가 속한 API 그룹/버전이라서 `kind` 는 `Deployment` 입니다. `replicas: 3` 은 Pod 를 3개 유지하라는 뜻입니다. `Service` 나 `Pod` 는 다른 종류(`v1`)이고, `80` 은 개수가 아니라 포트 번호처럼 쓰는 값입니다.', '[0, 3]', 'apiVersion: apps/v1
kind: {0}
metadata:
  name: web
spec:
  replicas: {1}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 7, 'Service 가 Pod 를 찾는 방법 알기', 'Deployment 의 Pod 템플릿에는 `labels: app: web` 이 있습니다. 이 Pod 들 앞에 Service 를 만들려면 Service 에 무엇이 필요할까요?', 'Service 는 **라벨**로 어떤 Pod 로 요청을 보낼지 고릅니다.', NULL, NULL, '[]', 'choice', '["Pod 이름을 하나씩 모두 적는다", "`selector: app: web` 처럼 Pod 의 라벨과 같은 값을 적는다", "아무것도 필요 없다. 자동으로 연결된다", "Deployment 의 이름을 `kind` 에 적는다"]', 1, 'Service 는 **셀렉터(selector)** 가 라벨이 일치하는 Pod 들을 찾아 요청을 나눠 줍니다. Service 의 `selector` 와 Pod 의 `labels` 가 **서로 맞아야** 연결됩니다. 접속이 안 될 때 가장 먼저 의심할 곳이 이 라벨·셀렉터 불일치입니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 8, 'kubectl apply 와 create 의 차이 알기', '같은 YAML 파일에 대해 `kubectl create -f web.yaml` 과 `kubectl apply -f web.yaml` 을 **두 번 이상** 실행합니다. 차이는 무엇일까요?', '이미 같은 이름의 자원이 있을 때 어떻게 동작할지를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`create` 는 이미 있으면 오류가 나고, `apply` 는 없으면 만들고 있으면 파일의 내용대로 바꾼다", "`apply` 는 한 번만 실행할 수 있다", "`create` 는 지우는 명령이다"]', 1, '`create` 는 **새로 만들기**만 해서 이미 있으면 `AlreadyExists` 오류가 납니다. `apply` 는 없으면 만들고 **있으면 변경점만 반영**해서 같은 파일을 여러 번 실행해도 됩니다. 그래서 YAML 파일 기반 작업은 보통 `apply -f` 를 씁니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 9, '--dry-run=client -o yaml 의 용도 알기', '`kubectl create deployment web --image=nginx --dry-run=client -o yaml` 은 무엇을 할까요?', '`--dry-run=client` 는 "실제로는 하지 말고 흉내만", `-o yaml` 은 "YAML 로 보여 줘"입니다.', NULL, NULL, '[]', 'choice', '["nginx Deployment 를 만들고 YAML 파일로 저장한다", "실제로 만들지 않고, 만들었다면 사용할 YAML 을 화면에 출력한다 (YAML 뼈대를 얻는 데 쓴다)", "nginx 를 삭제한다", "클러스터의 모든 Deployment 를 보여 준다"]', 1, '`--dry-run=client` 는 실제로 만들지 않고 흉내만 내고, `-o yaml` 은 그 결과를 YAML 로 출력합니다. YAML 을 처음부터 쓰기 어려울 때 이 명령으로 **뼈대를 얻어서** (`> web.yaml` 로 저장) 필요한 부분만 고치면 편합니다. 복사한 YAML 보다 자기가 만든 뼈대가 더 이해하기 쉽습니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 10, 'delete --all 의 범위 알기', '`kubectl delete pods --all` 을 **네임스페이스 지정 없이** 실행하면 무엇이 지워질까요?', '`-n` 이 없으면 현재 사용 중인 기본 네임스페이스를 대상으로 합니다. `--all` 은 "전부"입니다.', NULL, NULL, '[]', 'choice', '["클러스터 전체의 모든 Pod", "현재 네임스페이스(보통 `default`)의 모든 Pod", "이름이 `all` 인 Pod 하나", "아무것도 지워지지 않는다"]', 1, '네임스페이스를 지정하지 않으면 **현재 네임스페이스**가 대상이라서, `--all` 은 그 안의 모든 Pod 를 지웁니다. (Deployment 가 관리하는 Pod 는 다시 만들어지지만, 직접 만든 Pod 는 사라집니다.) 지우는 명령은 실행 전에 `kubectl get pods -n <네임스페이스>` 로 대상을 먼저 확인하세요.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template)
SELECT 46, 11, 'apiVersion 이 자원마다 다른 이유 알기', 'Pod 와 Service 의 `apiVersion` 은 `v1` 이고 Deployment 는 `apps/v1` 입니다. 이렇게 다른 이유로 알맞은 것은 무엇일까요?', '쿠버네티스 API 는 기능별로 **그룹**을 나눕니다. 가장 기본이 되는 자원은 그룹 이름이 없습니다.', NULL, NULL, '[]', 'choice', '["오타다. 모두 `v1` 로 써도 된다", "API 가 그룹으로 나뉘어 있어서, 기본(core) 자원(Pod, Service 등)은 `v1`, 워크로드(Deployment 등)는 `apps/v1` 처럼 그룹이 붙는다", "Deployment 는 오래된 버전이라 그렇다", "Service 는 사용하지 않는 버전이라 그렇다"]', 1, '쿠버네티스 API 는 그룹으로 나뉩니다. 기본(core) 자원인 Pod, Service, ConfigMap 등은 `v1`, Deployment·StatefulSet 같은 워크로드는 `apps/v1` 입니다. 새 자원의 `apiVersion` 이 헷갈리면 `kubectl api-resources` 나 `kubectl explain <자원>` 로 확인합니다.', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 46 AND order_index = 11);
