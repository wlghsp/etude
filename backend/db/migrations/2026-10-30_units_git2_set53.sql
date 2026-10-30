-- Git 세트 53. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set53.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 14, 'Git', '브랜치와 병합', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 14);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 53, 'Git 브랜치와 병합: 갈라지고 합치고 충돌 풀기', 'CI/CD 의 핵심인 브랜치 작업을 익힙니다. 브랜치 만들기와 이동(`switch`), 목록(`branch`), 병합(`merge`)의 두 종류(fast-forward, 병합 커밋), 충돌 읽고 해결하기, 합친 브랜치 정리, 긴급 수정 흐름 종합까지 연습합니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 53);
UPDATE quest_set SET display_order = 420, unit_id = (SELECT id FROM unit WHERE id = 14), icon = '🔀' WHERE id = 53;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 1, '브랜치가 필요한 이유 알기', '팀원 여러 명이 같은 프로젝트를 동시에 고치고, 배포용 코드(`main`)는 항상 안전해야 합니다. 이때 Git 의 **브랜치**를 쓰는 이유는 무엇일까요?', '브랜치는 "복사본"이 아니라 이력의 갈래입니다.', NULL, NULL, '[]', 'choice', '["`main` 은 그대로 두고, 각자 별도의 갈래에서 작업한 뒤 검토해서 합칠 수 있다", "파일을 압축해서 용량을 줄인다", "서버에 자동으로 배포한다", "커밋 이력을 삭제한다"]', 0, '브랜치는 커밋 이력의 **독립된 갈래**입니다. 새 기능(`feature/login`)이나 긴급 수정(`hotfix`)을 따로 작업하고, 리뷰를 거쳐 `main` 에 **병합(merge)** 합니다. CI/CD 에서는 보통 브랜치가 올라오면 테스트를 돌리고, `main` 에 합쳐지면 배포합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 2, 'fast-forward 병합과 병합 커밋의 차이 알기', '`main` 에서 갈라진 `feature` 에만 커밋이 2개 있고, 그동안 `main` 에는 새 커밋이 **없습니다.** `main` 에서 `git merge feature` 를 하면 어떻게 될까요?', '`main` 이 그 사이 한 걸음도 나아가지 않았다면 합칠 것이 따로 없습니다.', NULL, NULL, '[]', 'choice', '["`main` 의 포인터가 `feature` 의 끝까지 **앞으로 감기** 듯 이동한다 (fast-forward, 병합 커밋이 생기지 않는다)", "항상 새로운 병합 커밋이 만들어진다", "충돌이 반드시 발생한다", "`feature` 브랜치가 삭제된다"]', 0, '`main` 이 갈라진 이후 움직이지 않았다면 Git 은 `main` 포인터를 `feature` 끝으로 옮기기만 합니다. 이것을 **fast-forward** 라고 합니다. 양쪽에 각자 새 커밋이 생겨 **갈라진 경우**에는 두 이력을 합치는 **병합 커밋**이 새로 만들어집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 3, '충돌 표시 읽기', '병합 후 파일에 아래와 같은 표시가 생겼습니다. 이것은 무슨 뜻일까요?

<<<<<<< HEAD
port=9090
=======
port=8080
>>>>>>> feature', '`=======` 를 기준으로 위와 아래는 각각 어느 쪽 내용일까요?', NULL, NULL, '[]', 'choice', '["같은 줄을 양쪽이 다르게 고쳐서 충돌했다. 위(`HEAD`)는 지금 브랜치의 내용, 아래는 합치려는 `feature` 의 내용이다", "파일이 손상되었다", "`port` 설정이 두 번 적용된다", "Git 이 자동으로 알맞은 값을 골랐다"]', 0, '같은 줄을 두 브랜치가 다르게 바꾸면 Git 은 어느 쪽이 맞는지 알 수 없어 **충돌(conflict)** 로 표시합니다. `<<<<<<< HEAD` 부터 `=======` 까지가 지금 브랜치 내용, `=======` 부터 `>>>>>>> feature` 까지가 합치려는 브랜치 내용입니다. 사람이 원하는 내용만 남기고 표시(`<<<<<<<`, `=======`, `>>>>>>>`)를 **모두 지운 뒤** `git add` 와 `git commit` 으로 마무리합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 4, '새 브랜치를 만들고 이동하기 (git switch -c)', '`/tmp/proj` 저장소에 **`feature`** 브랜치를 새로 만들고, 그 브랜치로 이동해 있으세요. (마지막에 현재 브랜치가 `feature` 여야 합니다)', '찾는 방법: `git switch --help | grep -i create` 또는 `git branch --help`. 현재 브랜치는 `git branch` 또는 `git status` 로 볼 수 있습니다.
확인: `git branch` (현재 브랜치 앞에 `*`)', 'cd /tmp/proj
git switch -c feature

# switch -c : 새 브랜치를 만들면서 이동 (옛 방식: git checkout -b feature)', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init"]', '["sh", "-c", "( cd /tmp/proj && git rev-parse --verify -q feature >/dev/null ) && ( cd /tmp/proj && [ \\"$(git branch --show-current)\\" = feature ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "feature 브랜치가 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git rev-parse --verify -q feature >/dev/null"]}, {"label": "현재 브랜치가 feature 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --show-current)\\" = feature ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 5, '브랜치에서 작업하고 커밋하기', '`/tmp/proj` 에서 **`feature/login`** 브랜치를 만들어 이동하고, `login.txt` 파일(내용은 아무거나)을 만들어 **`add login`** 메시지로 커밋하세요. `main` 에는 아무 변화가 없어야 합니다.', '브랜치를 만들고 이동한 뒤 작업합니다. 브랜치 이름에 `/` 를 써도 됩니다(분류용).
확인: `git log --oneline --all` 과 `git branch`', 'cd /tmp/proj
git switch -c feature/login
echo login > login.txt
git add login.txt
git commit -m "add login"

# main 은 그대로이고 feature/login 에만 커밋이 생긴다', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git branch --show-current)\\" = feature/login ] ) && ( cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"add login\\" ] ) && ( cd /tmp/proj && ! git ls-tree --name-only main | grep -qx login.txt ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "현재 브랜치가 feature/login 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --show-current)\\" = feature/login ]"]}, {"label": "마지막 커밋 메시지가 `add login` 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git log -1 --format=%s)\\" = \\"add login\\" ]"]}, {"label": "main 에는 login.txt 가 없다", "cmd": ["sh", "-c", "cd /tmp/proj && ! git ls-tree --name-only main | grep -qx login.txt"]}, {"label": "작업 폴더가 깨끗하다", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 6, '브랜치 목록 보기 (git branch)', '`/tmp/proj` 에는 브랜치가 여러 개 있습니다. **브랜치 이름 목록**을 `/tmp/branches.txt` 에 저장하세요.', '`git branch` 는 로컬 브랜치 목록을 보여 주고 현재 브랜치 앞에 `*` 를 붙입니다.
확인: `cat /tmp/branches.txt`', 'cd /tmp/proj
git branch > /tmp/branches.txt

# * 가 붙은 것이 현재 브랜치', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init && git branch dev && git branch feature/a"]', '["sh", "-c", "( [ -s /tmp/branches.txt ] ) && ( grep -q main /tmp/branches.txt && grep -q dev /tmp/branches.txt && grep -q feature/a /tmp/branches.txt ) && ( [ \\"$(wc -l < /tmp/branches.txt)\\" -eq 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/branches.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/branches.txt ]"]}, {"label": "3개 브랜치가 모두 들어 있다", "cmd": ["sh", "-c", "grep -q main /tmp/branches.txt && grep -q dev /tmp/branches.txt && grep -q feature/a /tmp/branches.txt"]}, {"label": "3줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/branches.txt)\\" -eq 3 ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 7, '브랜치를 main 에 합치기 (fast-forward)', '`feature` 브랜치에는 `main` 에 없는 커밋이 하나 있습니다. **`main` 으로 이동해서** `feature` 를 병합하세요. (합친 뒤 `main` 에 `feature` 의 파일이 있어야 합니다)', '합칠 때는 **받는 쪽 브랜치**(`main`)에 있어야 합니다. 순서: `git switch main` → `git merge feature`.
확인: `git log --oneline`', 'cd /tmp/proj
git switch main
git merge feature

# 받는 쪽(main)에서 실행한다
# main 이 갈라지지 않았으므로 fast-forward 로 합쳐진다', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init && git switch -qc feature && echo f > feat.txt && git add feat.txt && git commit -qm ''add feat'' && git switch -q main"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ] ) && ( cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx feat.txt ) && ( cd /tmp/proj && [ \\"$(git rev-list --merges --count HEAD)\\" = 0 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "현재 브랜치가 main 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ]"]}, {"label": "main 에 feat.txt 가 들어왔다", "cmd": ["sh", "-c", "cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx feat.txt"]}, {"label": "병합 커밋 없이 합쳐졌다 (fast-forward)", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git rev-list --merges --count HEAD)\\" = 0 ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 8, '갈라진 브랜치 합치기 (병합 커밋)', '`main` 과 `feature` 가 **서로 다른 파일**을 각각 고쳐서 갈라졌습니다. `main` 에서 `feature` 를 병합하세요. 병합 커밋이 만들어지고 두 파일이 모두 있어야 합니다.', '`git merge feature` 를 하면 병합 커밋 메시지를 적는 편집기(vim)가 열릴 수 있습니다. 그대로 저장하고 종료하면 됩니다(`:wq`). 편집기를 열고 싶지 않다면 도움말에서 `--no-edit` 를 찾아보세요.
확인: `git log --oneline --graph`', 'cd /tmp/proj
git merge feature --no-edit

# 양쪽이 서로 다른 파일을 고쳤으므로 충돌 없이 자동으로 합쳐진다
# 병합 커밋이 1개 생긴다', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init && git switch -qc feature && echo f > feat.txt && git add feat.txt && git commit -qm ''add feat'' && git switch -q main && echo m > main.txt && git add main.txt && git commit -qm ''add main''"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ] ) && ( cd /tmp/proj && [ \\"$(git rev-list --merges --count HEAD)\\" = 1 ] ) && ( cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx feat.txt && git ls-tree --name-only HEAD | grep -qx main.txt ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "현재 브랜치가 main 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ]"]}, {"label": "병합 커밋이 1개 만들어졌다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git rev-list --merges --count HEAD)\\" = 1 ]"]}, {"label": "feat.txt 와 main.txt 가 모두 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx feat.txt && git ls-tree --name-only HEAD | grep -qx main.txt"]}, {"label": "작업 폴더가 깨끗하다", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 9, '충돌 해결하기', '`main` 과 `feature` 가 `config.txt` 의 **같은 줄**을 다르게 고쳐서 병합하면 충돌이 납니다. `main` 에서 `feature` 를 병합하고, **`port=8080`**(feature 쪽 값)으로 충돌을 해결해 병합을 완료하세요. 파일에 충돌 표시(`<<<<<<<` 등)가 남으면 안 됩니다.', '순서: ① `git merge feature` → 충돌 안내 ② `git status` 로 충돌 파일 확인 ③ 파일을 열어 원하는 내용만 남기고 `<<<<<<<`, `=======`, `>>>>>>>` 줄을 지움 ④ `git add 파일` ⑤ `git commit`(편집기가 열리면 저장·종료).
파일 고치기는 `vim` 또는 `echo "port=8080" > config.txt` 처럼 통째로 쓸 수도 있습니다.', 'cd /tmp/proj
git merge feature          # 충돌이 난다
echo "port=8080" > config.txt   # 원하는 내용만 남긴다
git add config.txt
git commit --no-edit

# 충돌 파일을 고친 뒤 add 하면 "해결됨" 표시가 된다', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''port=80\\\\n'' > config.txt && git add . && git commit -qm init && git switch -qc feature && printf ''port=8080\\\\n'' > config.txt && git commit -qam ''port 8080'' && git switch -q main && printf ''port=9090\\\\n'' > config.txt && git commit -qam ''port 9090''"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git rev-list --merges --count HEAD)\\" = 1 ] ) && ( cd /tmp/proj && [ \\"$(cat config.txt)\\" = \\"port=8080\\" ] ) && ( cd /tmp/proj && ! grep -qE \\"^(<<<<<<<|=======|>>>>>>>)\\" config.txt ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] && [ ! -f .git/MERGE_HEAD ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합이 완료되었다 (병합 커밋 1개)", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git rev-list --merges --count HEAD)\\" = 1 ]"]}, {"label": "config.txt 가 port=8080 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(cat config.txt)\\" = \\"port=8080\\" ]"]}, {"label": "충돌 표시가 남아 있지 않다", "cmd": ["sh", "-c", "cd /tmp/proj && ! grep -qE \\"^(<<<<<<<|=======|>>>>>>>)\\" config.txt"]}, {"label": "작업 폴더가 깨끗하다 (병합 진행 중이 아니다)", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] && [ ! -f .git/MERGE_HEAD ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 10, '합친 브랜치 정리하기 (git branch -d)', '`feature` 는 이미 `main` 에 병합되었습니다. 더 이상 필요 없으니 **`feature` 브랜치를 삭제**하세요. (`main` 에서 실행하세요)', '찾는 방법: `git branch --help | grep -i delete`
병합이 안 된 브랜치는 소문자 옵션이 막아 주어 안전합니다. 대문자 옵션은 강제 삭제이니 주의하세요.
확인: `git branch`', 'cd /tmp/proj
git branch -d feature

# -d : 병합이 끝난 브랜치만 삭제 (안전)
# -D : 병합 여부와 상관없이 강제 삭제 (주의)', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init && git switch -qc feature && echo f > feat.txt && git add feat.txt && git commit -qm ''add feat'' && git switch -q main && git merge -q feature"]', '["sh", "-c", "( cd /tmp/proj && ! git rev-parse --verify -q feature >/dev/null ) && ( cd /tmp/proj && git ls-tree --name-only main | grep -qx feat.txt ) && ( cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "feature 브랜치가 없다", "cmd": ["sh", "-c", "cd /tmp/proj && ! git rev-parse --verify -q feature >/dev/null"]}, {"label": "main 에 feat.txt 는 그대로 남아 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git ls-tree --name-only main | grep -qx feat.txt"]}, {"label": "현재 브랜치가 main 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 53, 11, '합쳐서 쓰기: 긴급 수정을 브랜치로 하고 합친 뒤 정리하기', '`main` 에서 시작해 ① **`hotfix`** 브랜치를 만들어 이동하고, ② `fix.txt` 를 만들어 **`fix bug`** 로 커밋하고, ③ `main` 으로 돌아와 `hotfix` 를 병합한 뒤, ④ `hotfix` 브랜치를 삭제하세요. 마지막에 `main` 에 `fix.txt` 가 있고 브랜치는 `main` 하나만 남아야 합니다.', '`switch -c` → 작업·커밋 → `switch main` → `merge` → `branch -d` 순서입니다. 각 단계 사이에 `git status` 와 `git branch` 로 확인하세요.', 'cd /tmp/proj
git switch -c hotfix
echo fix > fix.txt
git add fix.txt
git commit -m "fix bug"
git switch main
git merge hotfix
git branch -d hotfix', '["sh", "-c", "git config --global user.name tester && git config --global user.email tester@example.com && git config --global init.defaultBranch main && mkdir -p /tmp/proj && cd /tmp/proj && git init -q && printf ''hello\\\\n'' > hello.txt && git add hello.txt && git commit -qm init"]', '["sh", "-c", "( cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ] ) && ( cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx fix.txt ) && ( cd /tmp/proj && git log --format=%s | grep -qx \\"fix bug\\" ) && ( cd /tmp/proj && [ \\"$(git branch --format=%\\\\(refname:short\\\\))\\" = main ] ) && ( cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "현재 브랜치가 main 이다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --show-current)\\" = main ]"]}, {"label": "main 에 fix.txt 가 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git ls-tree --name-only HEAD | grep -qx fix.txt"]}, {"label": "`fix bug` 커밋이 이력에 있다", "cmd": ["sh", "-c", "cd /tmp/proj && git log --format=%s | grep -qx \\"fix bug\\""]}, {"label": "브랜치는 main 하나만 남았다", "cmd": ["sh", "-c", "cd /tmp/proj && [ \\"$(git branch --format=%\\\\(refname:short\\\\))\\" = main ]"]}, {"label": "작업 폴더가 깨끗하다", "cmd": ["sh", "-c", "cd /tmp/proj && [ -z \\"$(git status --porcelain)\\" ]"]}]', '[{"title": "Git 공식 문서", "url": "https://git-scm.com/docs"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 53 AND order_index = 11);
