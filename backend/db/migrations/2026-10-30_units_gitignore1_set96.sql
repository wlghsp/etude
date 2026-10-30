-- 리눅스 세트 96. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set96.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 96, 'Git .gitignore: 올리면 안 되는 파일 다루기', '비밀 파일·빌드 산출물·로그를 저장소에 올리지 않는 법을 익힙니다. 패턴 문법(`*`, 폴더 `/`, 예외 `!`), 이미 추적 중인 파일을 `git rm --cached` 로 끊기, 어떤 규칙이 무시하는지 `git check-ignore -v` 로 찾기, 전역 무시 파일, 빈 폴더를 `.gitkeep` 으로 남기는 법을 문제와 실습으로 다룹니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 96);
UPDATE quest_set SET display_order = 415, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🙈' WHERE id = 96;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 1, '.gitignore 패턴 채우기', '`.gitignore` 를 작성합니다. ① 모든 `.log` 파일 무시, ② `build` **폴더 전체** 무시, ③ 단 `keep.log` 만은 **예외로 추적**. 빈칸에 알맞은 패턴을 고르세요.', '폴더는 끝에 `/` 를 붙이고, 예외는 맨 앞에 `!` 를 붙여 **뒤쪽 줄**에 씁니다.', NULL, NULL, '[]', 'fill', '["*.log", "build/", "!keep.log", "keep.log!", "build", ".log"]', NULL, '`*.log` 는 이름이 .log 로 끝나는 모든 파일, `build/` 는 build **폴더**(끝의 `/`), `!keep.log` 는 앞선 규칙의 예외입니다. 예외는 무시 규칙보다 **뒤에** 써야 적용됩니다(나중 규칙이 이깁니다).', '[0, 1, 2]', '{0}
{1}
{2}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 2, '비밀 파일을 올리지 않고 첫 커밋하는 순서', '새 프로젝트 폴더에 비밀번호가 든 `.env` 가 있습니다. **한 번도 push 하지 않은 채** 안전하게 첫 커밋을 만드는 흐름을 **앞에서 뒤**로 놓으세요.', '저장소를 만들고, 무시 규칙을 먼저 정하고, 확인한 뒤 올립니다. 무시 규칙보다 add 가 먼저면 안 됩니다.', NULL, NULL, '[]', 'order', '["`git add .` 후 `git commit -m \\"init\\"` 한다", "`git status` 로 `.env` 가 목록에 없는지 확인한다", "`git init` 으로 저장소를 만든다", "`.gitignore` 에 `.env` 를 적는다"]', NULL, '**init → .gitignore 작성 → status 로 확인 → add·commit** 입니다. 한 번 add·commit 한 파일은 나중에 `.gitignore` 에 넣어도 계속 추적되고, 이력에도 남기 때문에 **처음 add 전에** 정하는 것이 가장 안전합니다.', '[2, 3, 1, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 3, '`/build` 와 `build/` 와 `build` 의 차이', '`.gitignore` 에서 `build`, `build/`, `/build` 의 의미가 각각 다릅니다. **저장소 최상위의 build 폴더만** 무시하고, `src/build` 같은 하위 폴더는 무시하지 않으려면 어떻게 써야 할까요?', '앞의 `/` 는 `.gitignore` 가 있는 위치부터라는 뜻입니다.', NULL, NULL, '[]', 'choice', '["`build` (이름이 같은 파일·폴더를 어느 깊이에서든 무시)", "`build/` (어느 깊이의 build 폴더든 무시)", "`/build/` (앞의 `/` 는 최상위 기준, 끝의 `/` 는 폴더만)", "`*build`"]', 2, '패턴에 `/` 가 중간이나 앞에 없으면 **모든 깊이**에서 이름이 맞는 것을 무시합니다. 앞에 `/` 를 붙이면 그 `.gitignore` 위치 기준 최상위만, 끝에 `/` 를 붙이면 폴더만 대상입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 4, '폴더를 무시했는데 안의 파일 예외가 안 먹을 때', '`.gitignore` 에 `logs/` 와 `!logs/keep.txt` 를 차례로 적었는데 `keep.txt` 가 계속 무시됩니다. 왜일까요?', 'Git 은 무시된 폴더 안으로 들어가지 않습니다.', NULL, NULL, '[]', 'choice', '["폴더 자체를 무시하면 Git 이 그 안을 보지 않아, 안의 파일에 대한 예외(`!`)가 동작하지 않는다. `logs/*` 로 바꿔 **안의 내용만** 무시하면 예외가 적용된다", "`!` 는 파일 이름이 대문자일 때만 동작한다", "규칙의 순서를 반대로 쓰면 항상 해결된다", "keep.txt 확장자가 txt 라서 예외가 안 된다"]', 0, '`logs/` 는 폴더를 통째로 제외하고, `logs/*` 는 폴더 안의 항목을 제외합니다. 후자를 쓰면 `!logs/keep.txt` 로 예외를 둘 수 있습니다. 빈 폴더를 저장소에 남기는 `.gitkeep` 기법도 이 방식입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 5, '어떤 규칙이 파일을 무시하는지 찾기', '`.gitignore` 가 여러 개이고 규칙도 많습니다. `config.local` 파일이 **어느 파일의 몇 번째 줄 규칙** 때문에 무시되는지 알려 주는 명령은 무엇일까요?', '무시 여부를 검사하는 전용 명령입니다.', NULL, NULL, '[]', 'choice', '["`git status --short`", "`git log --ignored`", "`git diff .gitignore`", "`git check-ignore -v config.local`"]', 3, '`-v` 를 붙이면 `파일:줄번호:패턴<TAB>경로` 형식으로 원인 규칙을 보여 줍니다. 무시된 파일 목록은 `git status --ignored` 로 볼 수 있습니다. 아무 출력이 없으면 무시되지 않는 파일(또는 이미 추적 중인 파일)입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 6, '모든 프로젝트에서 .DS_Store 무시하기', '내 컴퓨터의 편집기·OS 가 만드는 `.DS_Store`, `*.swp` 를 **프로젝트마다 `.gitignore` 에 쓰지 않고** 내가 만드는 모든 저장소에서 무시하고 싶습니다. 알맞은 방법은 무엇일까요?', '개인 환경에만 해당하는 규칙은 팀 저장소에 넣지 않습니다.', NULL, NULL, '[]', 'choice', '["모든 프로젝트의 `.gitignore` 에 복사해 커밋한다", "전역 무시 파일을 만들고 `git config --global core.excludesFile ~/.gitignore_global` 로 지정한다", "`git rm` 으로 한 번만 지운다", "운영체제를 다시 설치한다"]', 1, '팀 공통 규칙(빌드 산출물, 비밀 파일)은 저장소 `.gitignore` 에 커밋하고, **개인 환경** 규칙은 전역 파일로 분리합니다. 한 저장소에서만 개인적으로 무시하려면 커밋되지 않는 `.git/info/exclude` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 7, '빈 폴더를 저장소에 남기기', '`logs/` 폴더는 저장소에 있어야 하지만 안의 로그는 올리면 안 됩니다. 그런데 **빈 폴더는 Git 이 추적하지 않아** 팀원 쪽에서 폴더가 없습니다. 흔한 해결은 무엇일까요?', 'Git 은 파일만 추적하고 폴더는 파일을 통해서만 존재합니다.', NULL, NULL, '[]', 'choice', '["폴더 이름 끝에 `.git` 을 붙인다", "`git add -A` 만 하면 빈 폴더도 올라간다", "폴더에 `.gitkeep` 같은 빈 파일을 넣고, `.gitignore` 에서 그 파일만 예외로 두어 추적한다", "폴더를 압축해서 `.gitignore` 에 쓴다"]', 2, '`.gitkeep` 은 Git 의 공식 기능이 아니라 **관례**입니다(어떤 이름의 빈 파일이든 됩니다). `logs/*` 와 `!logs/.gitkeep` 조합이 흔한 패턴입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 8, '비밀 파일을 무시하고 첫 커밋', '`app.py` 와 비밀번호가 든 `.env` 가 있는 새 폴더입니다. **`.env` 는 추적하지 않고**, `.gitignore` 와 `app.py` 만 **`init`** 메시지로 커밋하세요.', '.gitignore 를 먼저 만들고 add 하세요. 확인: `git status`, `git ls-files`', 'cd /tmp/lab/proj
echo ''.env'' > .gitignore
git status --short
git add .
git commit -m init
git ls-files

# add 하기 전에 .gitignore 를 먼저 둔다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && mkdir proj && cd proj && git init -q -b main && echo ''print(1)'' > app.py && echo ''DB_PASSWORD=secret'' > .env"]', '["sh", "-c", "( git -C /tmp/lab/proj ls-files | grep -qx app.py ) && ( git -C /tmp/lab/proj ls-files | grep -qx .gitignore ) && ( ! git -C /tmp/lab/proj ls-files | grep -qx .env ) && ( [ -f /tmp/lab/proj/.env ] ) && ( [ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = init ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "app.py 가 추적된다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj ls-files | grep -qx app.py"]}, {"label": ".gitignore 가 추적된다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj ls-files | grep -qx .gitignore"]}, {"label": ".env 는 추적되지 않는다", "cmd": ["sh", "-c", "! git -C /tmp/lab/proj ls-files | grep -qx .env"]}, {"label": ".env 파일은 폴더에 남아 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/proj/.env ]"]}, {"label": "커밋 메시지가 init 이다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = init ]"]}]', '[{"title": "Git 공식 문서 - gitignore", "url": "https://git-scm.com/docs/gitignore"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 9, '이미 올라간 node_modules 추적 끊기', '`node_modules/` 폴더의 파일들이 **이미 커밋**되어 버렸습니다. 폴더는 그대로 두고 **추적만 끊은 뒤**, 다시 올라가지 않도록 `.gitignore` 에 `node_modules/` 를 넣고 **`ignore deps`** 메시지로 커밋하세요.', '폴더 단위로 추적을 끊으려면 재귀 옵션(`-r`)과 `--cached` 가 모두 필요합니다.\\n확인: `git ls-files`', 'cd /tmp/lab/proj
git rm -r --cached node_modules
echo ''node_modules/'' >> .gitignore
git add .gitignore
git commit -m ''ignore deps''
git ls-files

# -r : 폴더 안까지, --cached : 파일은 남기고 추적만 중단', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && mkdir proj && cd proj && git init -q -b main && mkdir -p node_modules/a node_modules/b && echo 1 > node_modules/a/i.js && echo 2 > node_modules/b/i.js && echo x > app.js && git add . && git commit -qm init"]', '["sh", "-c", "( [ -f /tmp/lab/proj/node_modules/a/i.js ] ) && ( ! git -C /tmp/lab/proj ls-files | grep -q node_modules ) && ( grep -q node_modules /tmp/lab/proj/.gitignore ) && ( git -C /tmp/lab/proj ls-files | grep -qx app.js ) && ( [ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = \\"ignore deps\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "node_modules 폴더가 그대로 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/proj/node_modules/a/i.js ]"]}, {"label": "node_modules 안 파일이 추적되지 않는다", "cmd": ["sh", "-c", "! git -C /tmp/lab/proj ls-files | grep -q node_modules"]}, {"label": ".gitignore 에 node_modules 규칙이 있다", "cmd": ["sh", "-c", "grep -q node_modules /tmp/lab/proj/.gitignore"]}, {"label": "app.js 는 계속 추적된다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj ls-files | grep -qx app.js"]}, {"label": "마지막 커밋 메시지가 ignore deps 이다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = \\"ignore deps\\" ]"]}]', '[{"title": "Git 공식 문서 - gitignore", "url": "https://git-scm.com/docs/gitignore"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 10, '파일을 무시하는 규칙 찾기', '`app.log` 가 `git status` 에 나타나지 않습니다. `.gitignore` 에 규칙이 여러 개인데, **`app.log` 를 무시하는 패턴**이 무엇인지 찾아 그 패턴 문자열만 `/tmp/lab/rule.txt` 에 저장하세요.', '무시 원인을 보여 주는 `check-ignore` 에 `-v` 를 붙입니다. 출력은 `파일:줄:패턴` 뒤에 탭으로 경로가 나옵니다. `cut` 으로 자르세요.\\n확인: `git check-ignore -v app.log`', 'cd /tmp/lab/proj
git check-ignore -v app.log
git check-ignore -v app.log | cut -f1 | cut -d: -f3 > /tmp/lab/rule.txt
cat /tmp/lab/rule.txt

# 출력: .gitignore:3:*.log<TAB>app.log  → 3번째 필드가 패턴', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && mkdir proj && cd proj && git init -q -b main && printf ''%s\\\\n'' ''node_modules/'' ''.env'' ''*.log'' ''dist/'' > .gitignore && echo x > app.log && echo y > main.c"]', '["sh", "-c", "( [ -s /tmp/lab/rule.txt ] ) && ( [ \\"$(cat /tmp/lab/rule.txt)\\" = \\"*.log\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/lab/rule.txt ]"]}, {"label": "패턴이 *.log 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lab/rule.txt)\\" = \\"*.log\\" ]"]}]', '[{"title": "Git 공식 문서 - gitignore", "url": "https://git-scm.com/docs/gitignore"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 11, '예외 규칙으로 파일 하나만 추적하기', '`.gitignore` 에 `*.log` 가 있어 `keep.log` 도 무시됩니다. **`keep.log` 만 추적**하고 나머지 `.log` 는 계속 무시하도록 `.gitignore` 를 고친 뒤, 모두 `add` 하고 **`track keep`** 메시지로 커밋하세요.', '무시 규칙 **뒤에** 예외 규칙(앞에 `!`)을 추가합니다.\\n확인: `git status --short` 에 `keep.log` 만 새로 보여야 합니다.', 'cd /tmp/lab/proj
echo ''!keep.log'' >> .gitignore
git add .
git commit -m ''track keep''
git ls-files

# 예외 규칙은 무시 규칙보다 뒤에 둔다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && mkdir proj && cd proj && git init -q -b main && echo ''*.log'' > .gitignore && git add .gitignore && git commit -qm init && echo 1 > keep.log && echo 2 > a.log"]', '["sh", "-c", "( git -C /tmp/lab/proj ls-files | grep -qx keep.log ) && ( ! git -C /tmp/lab/proj ls-files | grep -qx a.log ) && ( [ -f /tmp/lab/proj/a.log ] ) && ( [ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = \\"track keep\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "keep.log 가 추적된다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj ls-files | grep -qx keep.log"]}, {"label": "a.log 는 추적되지 않는다", "cmd": ["sh", "-c", "! git -C /tmp/lab/proj ls-files | grep -qx a.log"]}, {"label": "a.log 파일은 남아 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/proj/a.log ]"]}, {"label": "마지막 커밋 메시지가 track keep 이다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = \\"track keep\\" ]"]}]', '[{"title": "Git 공식 문서 - gitignore", "url": "https://git-scm.com/docs/gitignore"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 96, 12, '내용은 무시하고 logs 폴더만 남기기', '`logs/*` 가 무시되어 있어 `logs/` 폴더가 저장소에 없습니다. **`logs/app.log` 는 올리지 않고**, 빈 파일 `logs/.gitkeep` 만 추적해 **`keep logs dir`** 메시지로 커밋하세요.', '`.gitkeep` 파일을 만들고, 그 파일만 예외(`!`)로 두거나 `git add -f` 로 강제로 추가할 수 있습니다.\\n확인: `git ls-tree -r HEAD --name-only`', 'cd /tmp/lab/proj
touch logs/.gitkeep
echo ''!logs/.gitkeep'' >> .gitignore
git add .
git commit -m ''keep logs dir''
git ls-tree -r HEAD --name-only

# logs/ 가 아니라 logs/* 로 무시해야 예외가 동작한다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && mkdir proj && cd proj && git init -q -b main && mkdir logs && echo ''logs/*'' > .gitignore && git add .gitignore && git commit -qm init && echo l > logs/app.log"]', '["sh", "-c", "( git -C /tmp/lab/proj ls-tree -r HEAD --name-only | grep -qx logs/.gitkeep ) && ( ! git -C /tmp/lab/proj ls-tree -r HEAD --name-only | grep -qx logs/app.log ) && ( [ -f /tmp/lab/proj/logs/app.log ] ) && ( [ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = \\"keep logs dir\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "logs/.gitkeep 이 커밋에 있다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj ls-tree -r HEAD --name-only | grep -qx logs/.gitkeep"]}, {"label": "logs/app.log 는 커밋에 없다", "cmd": ["sh", "-c", "! git -C /tmp/lab/proj ls-tree -r HEAD --name-only | grep -qx logs/app.log"]}, {"label": "logs/app.log 파일은 남아 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/proj/logs/app.log ]"]}, {"label": "마지막 커밋 메시지가 keep logs dir 이다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/proj log -1 --format=%s)\\" = \\"keep logs dir\\" ]"]}]', '[{"title": "Git 공식 문서 - gitignore", "url": "https://git-scm.com/docs/gitignore"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 96 AND order_index = 12);
