-- 세트 504. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set504.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 504, 'Git 인증·접근: SSH 키 만들기, 권한, 원격 주소, 자격 증명 저장', 'Git 서버에 접속하는 두 방식(https 와 ssh)을 이해하고, SSH 키 쌍(개인키·공개키)을 만들어 권한을 맞추고, 서버에 등록할 공개키를 구분하고, 원격 주소를 https 에서 ssh 형식으로 바꾸고, credential.helper 와 core.sshCommand 를 설정합니다. 실제 서버 없이 키 파일과 설정만으로 연습합니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 504);
UPDATE quest_set SET display_order = 725, unit_id = (SELECT id FROM unit WHERE id = 15), icon = '🔑' WHERE id = 504;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 1, 'SSH 키 쌍 만들기', '`/tmp/lab/id_demo` 라는 이름으로 **ed25519 방식의 SSH 키 쌍**을 만드세요. 비밀번호(passphrase)는 비워 둡니다. 개인키 `id_demo` 와 공개키 `id_demo.pub` 두 파일이 생겨야 합니다.', '`ssh-keygen -t 방식 -f 파일경로 -N 비밀번호` 형태입니다. `-N ''''` 는 비밀번호 없음입니다.', 'ssh-keygen -q -t ed25519 -N '''' -f /tmp/lab/id_demo
ls -l /tmp/lab

# ssh-keygen 은 개인키(id_demo)와 공개키(id_demo.pub) 한 쌍을 만든다. 개인키는 내 컴퓨터에만 둔다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab"]', '["sh", "-c", "( [ -f /tmp/lab/id_demo ] ) && ( [ -f /tmp/lab/id_demo.pub ] ) && ( grep -q \\"^ssh-ed25519 \\" /tmp/lab/id_demo.pub )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "개인키가 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/id_demo ]"]}, {"label": "공개키가 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/id_demo.pub ]"]}, {"label": "ed25519 방식이다", "cmd": ["sh", "-c", "grep -q \\"^ssh-ed25519 \\" /tmp/lab/id_demo.pub"]}]', '[{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 2, '개인키 권한을 600 으로', '개인키 파일 `/tmp/lab/id_demo` 의 권한이 너무 열려 있어(`644`), ssh 가 `UNPROTECTED PRIVATE KEY FILE!` 경고를 내며 키를 **거부**합니다. **나만 읽고 쓸 수 있는 권한**으로 바꾸세요.', '`chmod` 로 권한을 숫자로 줍니다. 읽기=4, 쓰기=2, 실행=1 을 더해 소유자/그룹/기타 순서로 적습니다. 소유자만 읽기·쓰기이면 어떤 숫자일까요?', 'chmod 600 /tmp/lab/id_demo
stat -c ''%a'' /tmp/lab/id_demo

# 개인키는 소유자만 읽을 수 있어야 한다(600). 다른 사람이 읽을 수 있으면 ssh 가 키 사용을 거부한다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && ssh-keygen -q -t ed25519 -N '''' -C demo@example.com -f /tmp/lab/id_demo && chmod 644 /tmp/lab/id_demo"]', '["sh", "-c", "( [ \\"$(stat -c %a /tmp/lab/id_demo)\\" = 600 ] ) && ( [ -f /tmp/lab/id_demo.pub ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "권한이 600 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/lab/id_demo)\\" = 600 ]"]}, {"label": "공개키는 그대로다", "cmd": ["sh", "-c", "[ -f /tmp/lab/id_demo.pub ]"]}]', '[{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 3, '서버에 등록할 공개키 꺼내기', 'Git 서비스에 SSH 키를 등록할 때 붙여 넣는 것은 **공개키** 입니다. 공개키 파일의 내용을 `/tmp/lab/register.txt` 에 저장하세요. (개인키는 절대 넣지 않습니다)', '`.pub` 으로 끝나는 파일입니다. `cat 파일 > 새파일` 로 복사할 수 있어요.', 'cat /tmp/lab/id_demo.pub > /tmp/lab/register.txt
cat /tmp/lab/register.txt

# 서버에는 공개키(.pub)만 등록한다. 개인키가 유출되면 누구나 내 계정으로 접속할 수 있다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && ssh-keygen -q -t ed25519 -N '''' -C demo@example.com -f /tmp/lab/id_demo"]', '["sh", "-c", "( cmp -s /tmp/lab/register.txt /tmp/lab/id_demo.pub ) && ( ! grep -q \\"PRIVATE KEY\\" /tmp/lab/register.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "공개키와 내용이 같다", "cmd": ["sh", "-c", "cmp -s /tmp/lab/register.txt /tmp/lab/id_demo.pub"]}, {"label": "개인키 내용이 섞이지 않았다", "cmd": ["sh", "-c", "! grep -q \\"PRIVATE KEY\\" /tmp/lab/register.txt"]}]', '[{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 4, '원격 주소를 https 에서 ssh 로', '`/tmp/lab/proj` 저장소의 `origin` 이 `https://git.example.com/team/app.git` 입니다. SSH 키로 접속하도록 **ssh 형식 주소 `git@git.example.com:team/app.git`** 로 바꾸세요.', '`git remote set-url 원격이름 새주소` 로 바꿉니다. 확인은 `git remote -v`.', 'cd /tmp/lab/proj
git remote set-url origin git@git.example.com:team/app.git
git remote -v

# https 는 토큰·비밀번호로, ssh 는 키로 인증한다. 주소 형식도 다르다 (https://호스트/경로 ↔ git@호스트:경로)', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git init -q proj && cd proj && git remote add origin https://git.example.com/team/app.git"]', '["sh", "-c", "( [ \\"$(git -C /tmp/lab/proj remote get-url origin)\\" = git@git.example.com:team/app.git ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "origin 이 ssh 주소다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/proj remote get-url origin)\\" = git@git.example.com:team/app.git ]"]}]', '[{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 5, '자격 증명을 저장하는 도우미 켜기', 'https 주소를 쓸 때는 push 할 때마다 사용자 이름과 토큰을 물어봅니다. 한 번 입력한 값을 **파일에 저장해 다시 묻지 않게** 하는 `credential.helper` 를 `store` 로 전역(`--global`) 설정하세요.', '`git config --global credential.helper 값` 입니다. `store` 는 평문 파일(~/.git-credentials)에 저장합니다.', 'git config --global credential.helper store
git config --global credential.helper

# store 는 ~/.git-credentials 에 평문 저장(공용 PC 에서는 위험). cache 는 메모리에 잠시만 둔다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab"]', '["sh", "-c", "( [ \\"$(git config --global credential.helper)\\" = store ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "credential.helper 가 store 다", "cmd": ["sh", "-c", "[ \\"$(git config --global credential.helper)\\" = store ]"]}]', '[{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 6, '이 저장소만 특정 키로 접속하기', '`/tmp/lab/proj` 저장소만 **`/tmp/lab/id_demo` 키**로 ssh 접속하게 만드세요. 저장소 설정 `core.sshCommand` 에 `ssh -i /tmp/lab/id_demo` 를 넣습니다. (전역이 아니라 이 저장소에만 적용)', '`git config core.sshCommand "ssh -i 키경로"` 를 저장소 안에서 실행합니다. `--global` 을 쓰지 마세요.', 'cd /tmp/lab/proj
git config core.sshCommand ''ssh -i /tmp/lab/id_demo''
git config core.sshCommand

# 계정이 여러 개일 때 저장소마다 다른 키를 쓰게 한다. -i 는 사용할 개인키 파일을 지정한다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && ssh-keygen -q -t ed25519 -N '''' -C demo@example.com -f /tmp/lab/id_demo && git init -q proj"]', '["sh", "-c", "( [ \\"$(git -C /tmp/lab/proj config --local core.sshCommand)\\" = \\"ssh -i /tmp/lab/id_demo\\" ] ) && ( [ -z \\"$(git config --global core.sshCommand)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "저장소 설정에 값이 있다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/proj config --local core.sshCommand)\\" = \\"ssh -i /tmp/lab/id_demo\\" ]"]}, {"label": "전역에는 설정하지 않았다", "cmd": ["sh", "-c", "[ -z \\"$(git config --global core.sshCommand)\\" ]"]}]', '[{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 7, 'Permission denied (publickey)', '`git push` 가 `Permission denied (publickey).` 로 실패했습니다. 이 오류의 **가장 흔한 원인**은 무엇인가요?', '이 방식은 서버가 "내가 아는 공개키인가"를 보고 허락합니다.', NULL, NULL, '[]', 'choice', '["커밋 메시지가 너무 길다", "브랜치 이름에 한글이 들어 있다", "저장소 크기가 너무 크다", "서버에 내 공개키가 등록되어 있지 않거나, 다른 키로 접속하고 있다"]', 3, 'ssh 인증은 서버에 등록된 공개키와 내가 가진 개인키가 짝이 맞는지로 판단합니다. 공개키를 등록하지 않았거나 다른 키 파일이 쓰이면 publickey 거부가 납니다. 나머지는 인증과 관계없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 8, '서버에 등록하는 파일', '서버에 등록할 **공개키 파일**을 출력하는 명령입니다. 빈칸을 채우세요. (키 파일 이름은 `id_ed25519`)', '공개키 파일에는 특별한 확장자가 붙습니다.', NULL, NULL, '[]', 'fill', '[".pub", ".key", ".pem", ".public"]', NULL, 'ssh-keygen 은 개인키 `id_ed25519` 와 공개키 `id_ed25519.pub` 를 만듭니다. 서버에는 `.pub` 의 내용만 등록합니다.', '[0]', 'cat ~/.ssh/id_ed25519{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 504, 9, 'SSH 키로 첫 push 까지', '새 컴퓨터에서 SSH 키로 Git 서버에 **처음 push** 하기까지의 순서대로 놓으세요. (원격 주소는 이미 ssh 형식)', '서버가 나를 알아보려면 무엇이 먼저 있어야 하는지 생각해 보세요. push 는 접속이 확인된 뒤의 마지막 단계입니다.', NULL, NULL, '[]', 'order', '["git push", "공개키(.pub)를 Git 서비스에 등록", "ssh-keygen 으로 키 쌍 만들기", "ssh -T 로 접속 확인"]', NULL, '키 쌍을 만든 뒤 공개키를 서버에 등록해야 서버가 나를 알아봅니다. ssh 로 접속이 되는지 확인한 다음 push 합니다. (`ssh -T git@호스트` 는 접속·인증만 확인하는 명령입니다.)', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 504 AND order_index = 9);
