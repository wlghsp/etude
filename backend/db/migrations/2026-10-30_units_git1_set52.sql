-- Git 세트 52. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set52.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 52, 'Git 기초: 저장소 만들고 기록하기', 'CI/CD 의 출발점인 Git 을 터미널에서 직접 익힙니다. 사용자 설정, 저장소 만들기, 상태 확인(`status`), 기록(`add`·`commit`), 변경 확인(`diff`), 이력 보기(`log`), 일부만 커밋, `.gitignore` 까지 한 걸음씩 연습합니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 52);
UPDATE quest_set SET display_order = 410, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🌱' WHERE id = 52;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 1, 'Git 이 하는 일 알기', '배포 자동화(CI/CD)의 출발점은 모두 Git 입니다. Git 이 하는 가장 기본적인 일은 무엇일까요?', '파일 이름을 `final`, `final2`, `진짜final` 로 복사해 두던 일을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["파일이 바뀐 이력을 **커밋(저장 시점)** 으로 남겨 두고, 언제든 이전 상태를 보거나 되돌리고, 여러 사람이 합칠 수 있게 한다", "서버에 프로그램을 자동으로 설치한다", "컨테이너 이미지를 실행한다", "파일을 압축해서 용량을 줄인다"]', 0, 'Git 은 **버전 관리 도구**입니다. 바뀐 내용을 **커밋**이라는 저장 시점으로 차곡차곡 쌓아서, 누가 언제 무엇을 바꿨는지 보고 이전 상태로 돌아갈 수 있게 합니다. CI/CD 는 이 이력(커밋)이 올라오면 빌드·테스트·배포를 자동으로 실행하는 것입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 2, '파일을 고치고 기록하는 기본 흐름 놓기', '`hello.txt` 를 고쳐서 Git 에 기록하려고 합니다. 일반적인 순서대로 놓으세요.', '고치고 → 기록할 것을 고르고 → 기록하고 → 기록을 확인합니다.', NULL, NULL, '[]', 'order', '["`git commit -m \\"메시지\\"` 로 커밋한다", "`git log` 로 기록을 확인한다", "`hello.txt` 를 수정한다", "`git add hello.txt` 로 기록할 변경을 고른다"]', NULL, '**수정 → `git add`(스테이징: 이번 커밋에 넣을 변경 고르기) → `git commit`(기록) → `git log`(확인)** 순서입니다. `add` 를 거치기 때문에 고친 파일 중 일부만 골라서 커밋할 수 있습니다. 중간중간 `git status` 로 지금 상태를 확인하는 습관을 들이세요.', '[2, 3, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 3, '작업 폴더, 스테이징, 저장소 구분하기', '`git add a.txt` 를 실행하면 `a.txt` 는 어디로 옮겨질까요?', 'Git 에는 "고친 것"과 "기록한 것" 사이에 한 단계가 더 있습니다.', NULL, NULL, '[]', 'choice', '["작업 폴더에서 **스테이징 영역**(다음 커밋에 들어갈 후보)으로 올라간다", "바로 커밋으로 기록된다", "원격 서버로 올라간다", "파일이 삭제된다"]', 0, '`git add` 는 변경을 **스테이징 영역**에 올립니다. 아직 기록(커밋)된 것은 아닙니다. `git commit` 을 해야 스테이징에 올라 있는 것들이 하나의 커밋으로 저장소에 기록됩니다. 서버(원격)로 올리는 것은 `git push` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 4, 'Git 사용자 이름과 이메일 설정하기 (git config)', '커밋에는 **누가 기록했는지**가 남습니다. Git 에 사용자 **이름을 `dev`**, **이메일을 `dev@example.com`** 으로 전체(모든 저장소)에 적용되게 설정하세요.', '찾는 방법: `git config --help` 또는 `git help config` 에서 `--global` 을 찾아보세요. 형태는 `git config --global 항목 값` 이고, 항목은 `user.name`, `user.email` 입니다.
확인: `git config --global --list`', 'git config --global user.name dev
git config --global user.email dev@example.com

# --global : 이 사용자의 모든 저장소에 적용 (저장소 하나에만 적용하려면 생략)', '["sh", "-c", "true"]', '["sh", "-c", "( [ \\"$(git config --global user.name)\\" = dev ] ) && ( [ \\"$(git config --global user.email)\\" = dev@example.com ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "이름이 dev 로 설정되었다", "cmd": ["sh", "-c", "[ \\"$(git config --global user.name)\\" = dev ]"]}, {"label": "이메일이 dev@example.com 으로 설정되었다", "cmd": ["sh", "-c", "[ \\"$(git config --global user.email)\\" = dev@example.com ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 5, '저장소 만들기 (git init)', '`/tmp/myapp` 폴더를 만들고 그 안을 **Git 저장소**로 만드세요.', '저장소를 만드는 명령은 `git init` 입니다. 폴더 안에서 실행해야 합니다. (`git init 폴더` 처럼 폴더를 지정할 수도 있습니다.)
확인: `ls -a /tmp/myapp` (`.git` 폴더가 보여야 합니다)', 'mkdir /tmp/myapp
cd /tmp/myapp
git init

# .git 폴더 : 모든 이력이 들어 있는 저장소 본체', '["sh", "-c", "true"]', '["sh", "-c", "( [ -d /tmp/myapp ] ) && ( git -C /tmp/myapp rev-parse --git-dir >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/tmp/myapp 폴더가 있다", "cmd": ["sh", "-c", "[ -d /tmp/myapp ]"]}, {"label": "그 안이 Git 저장소다 (.git 이 있다)", "cmd": ["sh", "-c", "git -C /tmp/myapp rev-parse --git-dir >/dev/null 2>&1"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 6, '첫 커밋 만들기 (status, add, commit)', '`/tmp/proj` 저장소에는 아직 기록되지 않은 `README.md` 가 있습니다. `git status` 로 상태를 확인하고, 이 파일을 **`first commit`** 이라는 메시지로 커밋하세요.', '순서: `cd /tmp/proj` → `git status` (빨간 untracked 파일 확인) → `git add 파일` → `git commit -m "메시지"`.
확인: `git log --oneline`', 'cd /tmp/proj
git status
git add README.md
git commit -m "first commit"

# add : 이번 커밋에 넣을 파일 고르기
# commit -m : 메시지와 함께 기록', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''# demo\\\\n'' > README.md"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git rev-list --count HEAD 2>/dev/null)\\" = 1 ] ) && ( cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"first commit\\" ] ) && ( cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx README.md ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "커밋이 1개 있다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git rev-list --count HEAD 2>/dev/null)\\" = 1 ]"]}, {"label": "커밋 메시지가 `first commit` 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"first commit\\" ]"]}, {"label": "README.md 가 커밋에 들어 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx README.md"]}, {"label": "작업 폴더가 깨끗하다 (남은 변경 없음)", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 7, '무엇이 바뀌었는지 보기 (git diff)', '`/tmp/proj` 의 `hello.txt` 맨 아래에 `world` 한 줄을 추가하세요. **커밋하기 전에** `git diff` 의 결과를 `/tmp/diff.txt` 에 저장하세요. (바뀐 내용이 어떻게 보이는지 확인하는 연습입니다)', '줄 추가는 `echo world >> hello.txt` 입니다. `git diff` 는 아직 add 하지 않은 변경을 `+`(추가) `-`(삭제) 로 보여 줍니다. 결과는 `>` 로 저장합니다.
확인: `cat /tmp/diff.txt`', 'cd /tmp/proj
echo world >> hello.txt
git diff > /tmp/diff.txt

# git diff : 아직 add 하지 않은 변경
# + 로 시작하는 줄이 추가된 줄', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init"]', '["sh", "-c", "( tail -n 1 /tmp/proj/hello.txt | grep -qx world ) && ( [ -s /tmp/diff.txt ] ) && ( grep -qx \\"+world\\" /tmp/diff.txt ) && ( cd /tmp/proj && [ \\"$(git rev-list --count HEAD)\\" = 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "hello.txt 에 world 줄이 추가되었다", "cmd": ["sh", "-c", "tail -n 1 /tmp/proj/hello.txt | grep -qx world"]}, {"label": "결과 파일 /tmp/diff.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/diff.txt ]"]}, {"label": "diff 에 +world 가 보인다", "cmd": ["sh", "-c", "grep -qx \\"+world\\" /tmp/diff.txt"]}, {"label": "아직 커밋하지 않았다 (커밋 1개 그대로)", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git rev-list --count HEAD)\\" = 1 ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 8, '일부만 골라서 커밋하기', '`/tmp/proj` 에서 `a.txt` 와 `b.txt` 를 **둘 다 수정**했습니다. 그런데 이번 커밋에는 **`a.txt` 만** `update a` 라는 메시지로 기록하고, `b.txt` 는 수정된 채로 남겨 두세요.', '`git add` 에 파일 이름을 주면 그 파일만 스테이징됩니다. `git add .` 는 전부 올리니 이번에는 쓰지 마세요.
확인: `git status` (b.txt 만 수정됨으로 남아야 합니다)', 'cd /tmp/proj
git add a.txt
git commit -m "update a"

# add 에 파일을 지정하면 그것만 커밋에 들어간다
# b.txt 는 수정된 채 남는다', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''a1\\\\n'' > a.txt && printf ''b1\\\\n'' > b.txt && git add . && git commit -qm init && printf ''a2\\\\n'' > a.txt && printf ''b2\\\\n'' > b.txt"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"update a\\" ] ) && ( cd /tmp/proj && [ \\"$(git show --name-only --format= HEAD)\\" = a.txt ] ) && ( cd /tmp/proj && git status --porcelain | grep -q \\"^ M b.txt\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "마지막 커밋 메시지가 `update a` 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"update a\\" ]"]}, {"label": "마지막 커밋에는 a.txt 만 들어 있다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git show --name-only --format= HEAD)\\" = a.txt ]"]}, {"label": "b.txt 는 아직 수정된 채 남아 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git status --porcelain | grep -q \\"^ M b.txt\\""]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 9, '기록 훑어보기 (git log)', '`/tmp/proj` 에는 커밋이 3개 있습니다. 커밋을 **한 줄씩 짧게** 보는 방식으로 이력을 `/tmp/history.txt` 에 저장하세요. (줄마다 짧은 커밋 번호와 메시지가 한 줄에 보입니다)', '찾는 방법: `git log --help | grep -i oneline`
확인: `cat /tmp/history.txt` (3줄이어야 합니다)', 'cd /tmp/proj
git log --oneline > /tmp/history.txt

# --oneline : 커밋 하나를 한 줄로 (짧은 번호 + 메시지)', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && for i in 1 2 3; do echo $i >> f.txt; git add f.txt; git commit -qm \\"step $i\\"; done"]', '["sh", "-c", "( [ -s /tmp/history.txt ] ) && ( [ \\"$(wc -l < /tmp/history.txt)\\" -eq 3 ] ) && ( head -n 1 /tmp/history.txt | grep -q \\"step 3\\" ) && ( head -n 1 /tmp/history.txt | grep -qE \\"^[0-9a-f]{7} \\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/history.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/history.txt ]"]}, {"label": "3줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/history.txt)\\" -eq 3 ]"]}, {"label": "가장 위가 최신 커밋(step 3)이다", "cmd": ["sh", "-c", "head -n 1 /tmp/history.txt | grep -q \\"step 3\\""]}, {"label": "한 줄 형식이다 (짧은 번호로 시작)", "cmd": ["sh", "-c", "head -n 1 /tmp/history.txt | grep -qE \\"^[0-9a-f]{7} \\""]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 10, '기록하지 않을 파일 정하기 (.gitignore)', '`/tmp/proj` 에는 로그 파일(`app.log`, `debug.log`)이 생겨서 `git status` 에 계속 보입니다. **`.log` 로 끝나는 파일은 Git 이 무시하도록** 설정하고, 그 설정 파일을 `add ignore log` 라는 메시지로 커밋하세요.', '프로젝트 폴더에 `.gitignore` 파일을 만들고 무시할 패턴을 한 줄에 하나씩 적습니다. 패턴은 쉘의 와일드카드와 비슷합니다(`*`).
확인: `git status` (더 이상 .log 파일이 안 보이고, 깨끗해야 합니다)', 'cd /tmp/proj
echo "*.log" > .gitignore
git add .gitignore
git commit -m "add ignore log"

# .gitignore 자체도 커밋해서 팀이 같이 쓴다', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''print(1)\\\\n'' > main.py && git add main.py && git commit -qm init && echo x > app.log && echo y > debug.log"]', '["sh", "-c", "( cd /tmp/proj && git check-ignore -q app.log ) && ( cd /tmp/proj && git check-ignore -q debug.log ) && ( cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx .gitignore ) && ( cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"add ignore log\\" ] ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "app.log 가 무시된다", "cmd": ["sh", "-c", "cd /tmp/proj && git check-ignore -q app.log"]}, {"label": "debug.log 도 무시된다", "cmd": ["sh", "-c", "cd /tmp/proj && git check-ignore -q debug.log"]}, {"label": ".gitignore 가 커밋되었다", "cmd": ["sh", "-c", "cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx .gitignore"]}, {"label": "마지막 커밋 메시지가 `add ignore log` 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"add ignore log\\" ]"]}, {"label": "작업 폴더가 깨끗하다", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 52, 11, '합쳐서 쓰기: 파일 만들고 두 번에 나눠 기록하기', '`/tmp/proj` 는 빈 저장소입니다. ① `notes.txt` 를 만들어 `first` 한 줄을 쓰고 **`add notes`** 로 커밋하고, ② 이어서 `second` 한 줄을 **추가**해서 **`update notes`** 로 커밋하세요. 마지막에는 커밋이 2개이고 작업 폴더가 깨끗해야 합니다.', '줄 추가는 `echo second >> notes.txt` 입니다. 커밋 전에 `git status` 로 확인하는 습관을 들이세요.
확인: `git log --oneline`', 'cd /tmp/proj
echo first > notes.txt
git add notes.txt
git commit -m "add notes"
echo second >> notes.txt
git add notes.txt
git commit -m "update notes"', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git rev-list --count HEAD 2>/dev/null)\\" = 2 ] ) && ( cd /tmp/proj && [ \\"$(git log --reverse --format=%s | head -n 1)\\" = \\"add notes\\" ] ) && ( cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"update notes\\" ] ) && ( cd /tmp/proj && [ \\"$(cat notes.txt)\\" = \\"first\\nsecond\\" ] ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "커밋이 2개다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git rev-list --count HEAD 2>/dev/null)\\" = 2 ]"]}, {"label": "첫 커밋 메시지가 `add notes` 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git log --reverse --format=%s | head -n 1)\\" = \\"add notes\\" ]"]}, {"label": "마지막 커밋 메시지가 `update notes` 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"update notes\\" ]"]}, {"label": "notes.txt 가 first, second 두 줄이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(cat notes.txt)\\" = \\"first\\nsecond\\" ]"]}, {"label": "작업 폴더가 깨끗하다", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 52 AND order_index = 11);
