-- Git 실습 세트 495. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_git_stash_remote_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 495, 'Git 보관·원격 정리 손연습: stash -u·apply·branch, 태그 push, push --delete, fetch --prune, --set-upstream-to, --force-with-lease, --amend --author', '로컬 원격 저장소로 실제 흐름을 연습합니다. stash -u 로 추적 안 하는 파일까지 보관, stash apply 와 stash branch, 태그만 push, 원격 브랜치 삭제, fetch --prune 으로 낡은 추적 브랜치 정리, 업스트림 지정, --force-with-lease 로 안전하게 덮어쓰기, --amend --author 를 실습합니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 495);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 1, '추적하지 않는 파일까지 치워 두기 (stash -u)', '**배경** — `git stash` 는 **추적 중인 파일의 변경**만 보관합니다. 새로 만든 **추적 안 하는 파일**은 그대로 남습니다. **`-u`**(`--include-untracked`)를 주면 그 파일까지 함께 치워 작업 폴더가 깨끗해집니다. `/tmp/lab/work` 에 고친 `a.txt` 와 새 파일 `new.txt` 가 있습니다.

**문제** — 변경과 `new.txt` 를 **모두 stash 로 치워** 작업 폴더를 깨끗하게 만드세요.', '`cd /tmp/lab/work && git stash -u`', 'cd /tmp/lab/work
git stash -u
git status --short
git stash list

# -u 가 없으면 new.txt 는 그대로 남는다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && echo mod >> a.txt && echo n > new.txt"]', '["sh", "-c", "( [ ! -e /tmp/lab/work/new.txt ] ) && ( [ \\"$(git -C /tmp/lab/work stash list | wc -l)\\" -eq 1 ] ) && ( [ -z \\"$(git -C /tmp/lab/work status --porcelain)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "new.txt 가 없다", "cmd": ["sh", "-c", "[ ! -e /tmp/lab/work/new.txt ]"]}, {"label": "stash 가 1개다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work stash list | wc -l)\\" -eq 1 ]"]}, {"label": "작업 폴더가 깨끗하다", "cmd": ["sh", "-c", "[ -z \\"$(git -C /tmp/lab/work status --porcelain)\\" ]"]}]', '[{"title": "git-stash 문서", "url": "https://git-scm.com/docs/git-stash"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 2, '치워 둔 변경을 돌려받되 보관함에는 남기기 (stash apply)', '**배경** — `git stash pop` 은 변경을 되돌리고 보관함에서 **지웁니다**. **`git stash apply`** 는 되돌리기만 하고 **보관함에 남겨 둡니다**. 같은 변경을 **여러 브랜치에 적용**하거나, 충돌이 날 때 안전하게 재시도하려고 씁니다. 보관함에 `a.txt` 변경이 1개 들어 있습니다.

**문제** — 보관한 변경을 작업 폴더에 되돌리되 **보관함에는 그대로 남겨 두세요.**', '`git stash apply`', 'cd /tmp/lab/work
git stash apply
git stash list
cat a.txt

# pop = apply + drop. apply 는 stash 가 남는다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && echo mod >> a.txt && git stash -q"]', '["sh", "-c", "( grep -q mod /tmp/lab/work/a.txt ) && ( [ \\"$(git -C /tmp/lab/work stash list | wc -l)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "a.txt 에 mod 가 돌아왔다", "cmd": ["sh", "-c", "grep -q mod /tmp/lab/work/a.txt"]}, {"label": "stash 가 아직 1개다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work stash list | wc -l)\\" -eq 1 ]"]}]', '[{"title": "git-stash 문서", "url": "https://git-scm.com/docs/git-stash"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 3, '치워 둔 변경으로 새 브랜치 만들기 (stash branch)', '**배경** — stash 를 만든 **그 시점의 커밋에서 새 브랜치**를 만들고 변경을 적용한 뒤 stash 를 지워 주는 명령이 **`git stash branch 이름`** 입니다. 시간이 지나 현재 브랜치와 **충돌 나서 pop 이 안 되는** stash 를 살릴 때 씁니다. 보관함에 변경 1개가 있습니다.

**문제** — 그 stash 로 브랜치 **`rescue`** 를 만들어 변경을 되살리세요. (현재 브랜치가 `rescue` 이고 보관함은 비어야 합니다.)', '`git stash branch rescue`', 'cd /tmp/lab/work
git stash branch rescue
git status --short
git stash list

# stash 를 만든 커밋에서 분기하므로 충돌 없이 적용되고 stash 는 지워진다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && echo mod >> a.txt && git stash -q"]', '["sh", "-c", "( [ \\"$(git -C /tmp/lab/work branch --show-current)\\" = rescue ] ) && ( grep -q mod /tmp/lab/work/a.txt ) && ( [ -z \\"$(git -C /tmp/lab/work stash list)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "현재 브랜치가 rescue 다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work branch --show-current)\\" = rescue ]"]}, {"label": "변경이 되살아났다", "cmd": ["sh", "-c", "grep -q mod /tmp/lab/work/a.txt"]}, {"label": "stash 는 비었다", "cmd": ["sh", "-c", "[ -z \\"$(git -C /tmp/lab/work stash list)\\" ]"]}]', '[{"title": "git-stash 문서", "url": "https://git-scm.com/docs/git-stash"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 4, '태그를 원격에 올리기 (push 태그)', '**배경** — `git push` 는 **태그를 기본으로 올리지 않습니다**. 태그 하나는 `git push origin 태그이름`, 모두는 `git push --tags` 로 올립니다. 릴리스 태그는 원격에 올려야 다른 사람이 볼 수 있습니다. 로컬에 주석 태그 `v1.0` 이 있습니다.

**문제** — 태그 **`v1.0` 만** 원격 `origin` 에 올리세요.', '`git push origin v1.0`', 'cd /tmp/lab/work
git push origin v1.0
git ls-remote --tags origin

# 로컬 태그는 push 해야 원격에 생긴다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && git tag -a v1.0 -m release"]', '["sh", "-c", "( git -C /tmp/lab/work ls-remote --tags origin | grep -q \\"refs/tags/v1.0\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "원격에 v1.0 이 있다", "cmd": ["sh", "-c", "git -C /tmp/lab/work ls-remote --tags origin | grep -q \\"refs/tags/v1.0\\""]}]', '[{"title": "git-push 문서", "url": "https://git-scm.com/docs/git-push"}, {"title": "git-tag 문서", "url": "https://git-scm.com/docs/git-tag"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 5, '원격 브랜치 지우기 (push --delete)', '**배경** — 로컬 `git branch -d` 는 원격 브랜치를 지우지 못합니다. 원격 쪽은 **`git push origin --delete 브랜치`** (또는 `:브랜치`)로 지웁니다. 다 쓴 작업 브랜치를 원격에서 정리할 때 씁니다. 원격에 브랜치 `old` 가 있습니다.

**문제** — 원격 `origin` 의 **`old` 브랜치를 삭제**하세요.', '`git push origin --delete old`', 'cd /tmp/lab/work
git push origin --delete old
git ls-remote --heads origin

# git push origin :old 도 같은 뜻이다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && git switch -qc old && ci o.txt 1 co && git push -q origin old && git switch -q main"]', '["sh", "-c", "( ! git -C /tmp/lab/work ls-remote --heads origin | grep -q \\"refs/heads/old\\" ) && ( git -C /tmp/lab/work ls-remote --heads origin | grep -q \\"refs/heads/main\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "원격에 old 가 없다", "cmd": ["sh", "-c", "! git -C /tmp/lab/work ls-remote --heads origin | grep -q \\"refs/heads/old\\""]}, {"label": "main 은 남아 있다", "cmd": ["sh", "-c", "git -C /tmp/lab/work ls-remote --heads origin | grep -q \\"refs/heads/main\\""]}]', '[{"title": "git-push 문서", "url": "https://git-scm.com/docs/git-push"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 6, '이미 지워진 원격 브랜치 흔적 정리하기 (fetch --prune)', '**배경** — 원격에서 브랜치가 지워져도 내 저장소의 **원격 추적 브랜치**(`origin/이름`)는 남아 `git branch -r` 에 계속 보입니다. **`git fetch --prune`** 은 가져오면서 **원격에 더 이상 없는 것**을 정리합니다. 원격에서 `gone` 브랜치가 삭제됐지만 `origin/gone` 이 남아 있습니다.

**문제** — 낡은 원격 추적 브랜치 **`origin/gone` 을 정리**하세요.', '`git fetch --prune` (`git fetch -p`)', 'cd /tmp/lab/work
git branch -r
git fetch --prune
git branch -r

# 설정 fetch.prune=true 로 항상 자동 정리할 수도 있다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && git switch -qc gone && ci g.txt 1 cg && git push -q origin gone && git switch -q main && git --git-dir=/tmp/lab/remote.git branch -D gone >/dev/null"]', '["sh", "-c", "( ! git -C /tmp/lab/work branch -r | grep -q gone ) && ( git -C /tmp/lab/work branch -r | grep -q \\"origin/main\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "origin/gone 이 없다", "cmd": ["sh", "-c", "! git -C /tmp/lab/work branch -r | grep -q gone"]}, {"label": "origin/main 은 남아 있다", "cmd": ["sh", "-c", "git -C /tmp/lab/work branch -r | grep -q \\"origin/main\\""]}]', '[{"title": "git-fetch 문서", "url": "https://git-scm.com/docs/git-fetch"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 7, '브랜치가 따라갈 원격 브랜치 정하기 (--set-upstream-to)', '**배경** — 로컬 브랜치의 **업스트림**(추적 대상)을 정해 두면 `git pull`·`git push`·`git status` 가 그 원격 브랜치를 기준으로 동작합니다. 이미 있는 브랜치에는 **`git branch --set-upstream-to=origin/이름 브랜치`** 로 정합니다. `@{upstream}` 은 현재 업스트림을 가리킵니다. 로컬 `feat` 가 있고 원격에도 `origin/feat` 가 있지만 연결되어 있지 않습니다.

**문제** — `feat` 의 업스트림을 **`origin/feat`** 로 정하고, `git rev-parse --abbrev-ref feat@{upstream}` 의 결과를 **`/tmp/q7.txt`** 에 저장하세요.', '`git branch --set-upstream-to=origin/feat feat` 후 `git rev-parse --abbrev-ref feat@{upstream} > /tmp/q7.txt`', 'cd /tmp/lab/work
git branch --set-upstream-to=origin/feat feat
git rev-parse --abbrev-ref feat@{upstream} > /tmp/q7.txt
cat /tmp/q7.txt
git branch -vv

# push -u 도 같은 연결을 만든다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && git switch -qc feat && ci f.txt 1 cf && git push -q origin feat && git switch -q main"]', '["sh", "-c", "( [ \\"$(cat /tmp/q7.txt)\\" = origin/feat ] ) && ( [ \\"$(git -C /tmp/lab/work rev-parse --abbrev-ref feat@{upstream} 2>/dev/null)\\" = origin/feat ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값이 origin/feat 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q7.txt)\\" = origin/feat ]"]}, {"label": "feat 의 업스트림이 설정됐다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work rev-parse --abbrev-ref feat@{upstream} 2>/dev/null)\\" = origin/feat ]"]}]', '[{"title": "git-branch 문서", "url": "https://git-scm.com/docs/git-branch"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 8, '고쳐 쓴 이력을 안전하게 덮어 올리기 (--force-with-lease)', '**배경** — 이미 올린 커밋을 `--amend` 로 고치면 이력이 갈라져 일반 `git push` 가 **거절**됩니다. `--force` 는 원격을 무조건 덮어써 **남이 올린 커밋을 날릴 수 있고**, **`--force-with-lease`** 는 "내가 마지막으로 본 상태 그대로일 때만" 덮어써서 안전합니다. 방금 올린 마지막 커밋의 메시지를 `--amend` 로 고쳐 둔 상태입니다(일반 push 는 거절됩니다).

**문제** — 고친 `main` 을 **`--force-with-lease`** 로 원격에 올려 원격 `main` 이 로컬 `main` 과 같아지게 하세요.', '`git push --force-with-lease origin main`', 'cd /tmp/lab/work
git push origin main || true
git push --force-with-lease origin main
git log --oneline -2

# 그 사이 남이 올린 커밋이 있으면 lease 가 실패해 덮어쓰지 않는다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && ci a.txt 3 c3 && git push -q origin main && git commit -q --amend -m c3-fixed"]', '["sh", "-c", "( [ \\"$(git -C /tmp/lab/work rev-parse main)\\" = \\"$(git --git-dir=/tmp/lab/remote.git rev-parse main)\\" ] ) && ( [ \\"$(git --git-dir=/tmp/lab/remote.git log -1 --format=%s main)\\" = c3-fixed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "원격 main 이 로컬과 같다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work rev-parse main)\\" = \\"$(git --git-dir=/tmp/lab/remote.git rev-parse main)\\" ]"]}, {"label": "원격 최신 메시지가 c3-fixed 다", "cmd": ["sh", "-c", "[ \\"$(git --git-dir=/tmp/lab/remote.git log -1 --format=%s main)\\" = c3-fixed ]"]}]', '[{"title": "git-push 문서", "url": "https://git-scm.com/docs/git-push"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 9, '마지막 커밋의 작성자 고치기 (--amend --author)', '**배경** — 마지막 커밋의 **작성자**를 잘못 남겼다면 `git commit --amend --author="이름 <메일>" --no-edit` 로 **메시지는 그대로** 두고 작성자만 고칩니다. 커밋 해시는 바뀝니다. 아직 올리지 않은 커밋에만 안전합니다.

**문제** — 마지막 커밋의 작성자를 **`Bob <bob@x.com>`** 로 바꾸세요. (메시지는 그대로, 커밋 수도 그대로여야 합니다.)', '`git commit --amend --author="Bob <bob@x.com>" --no-edit`', 'cd /tmp/lab/work
git commit --amend --author="Bob <bob@x.com>" --no-edit
git log -1 --format=''%an <%ae> %s''

# 작성자(author)와 커밋한 사람(committer)은 따로다. --author 는 작성자만 바꾼다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && git init -q --bare remote.git && git clone -q remote.git work 2>/dev/null && cd work && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci a.txt 1 c1 && ci a.txt 2 c2 && git push -q origin main && ci a.txt 3 c3"]', '["sh", "-c", "( [ \\"$(git -C /tmp/lab/work log -1 --format=%an)\\" = Bob ] ) && ( [ \\"$(git -C /tmp/lab/work log -1 --format=%s)\\" = c3 ] ) && ( [ \\"$(git -C /tmp/lab/work rev-list --count HEAD)\\" -eq 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "마지막 작성자가 Bob 이다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work log -1 --format=%an)\\" = Bob ]"]}, {"label": "메시지는 c3 그대로다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work log -1 --format=%s)\\" = c3 ]"]}, {"label": "커밋 수는 3개다", "cmd": ["sh", "-c", "[ \\"$(git -C /tmp/lab/work rev-list --count HEAD)\\" -eq 3 ]"]}]', '[{"title": "git-commit 문서", "url": "https://git-scm.com/docs/git-commit"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 10, '--force 와 --force-with-lease 의 차이', '이미 올린 이력을 덮어써야 할 때 `--force-with-lease` 가 `--force` 보다 안전한 이유는?', '"빌려 쓴다(lease)" 는 뜻이에요.', NULL, NULL, '[]', 'choice', '["원격에 쓰기 권한이 없어도 덮어쓸 수 있다", "내가 본 원격 상태일 때만 덮어써 남의 커밋을 지킨다", "덮어쓰기 전에 원격 이력을 자동으로 백업한다", "로컬 커밋 해시를 바꾸지 않고 올린다"]', 1, '--force-with-lease 는 원격 브랜치가 내가 마지막으로 가져온 값과 같을 때만 덮어씁니다. 그 사이 다른 사람이 올렸다면 거절해 남의 작업을 날리는 사고를 막습니다. 권한·백업과는 무관합니다.', NULL, NULL, NULL, '[{"title": "git-push 문서", "url": "https://git-scm.com/docs/git-push"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 11, '원격 브랜치 삭제', '원격 `origin` 의 브랜치 `old` 를 지우는 명령입니다. 빈칸을 채우세요.', '"삭제" 의 영어예요.', NULL, NULL, '[]', 'fill', '["delete", "remove", "prune", "force"]', NULL, 'git push origin --delete 브랜치 가 원격 브랜치를 지웁니다. --prune 은 원격에 없는 로컬 ref 정리에 쓰이고 --force 는 덮어쓰기입니다. remove 라는 옵션은 없습니다.', '[0]', 'git push origin --{0} old', NULL, '[{"title": "git-push 문서", "url": "https://git-scm.com/docs/git-push"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 495, 12, '다 쓴 브랜치를 로컬과 원격에서 정리하는 순서', '병합이 끝난 작업 브랜치를 정리하는 일반적인 순서입니다. 순서에 맞게 놓아 보세요.', '병합 확인 → 로컬 삭제 → 원격 삭제 → 흔적 정리예요.', NULL, NULL, '[]', 'order', '["`git branch --merged main` 으로 이미 합쳐진 브랜치를 확인한다", "`git branch -d 브랜치` 로 로컬 브랜치를 지운다", "`git push origin --delete 브랜치` 로 원격 브랜치를 지운다", "다른 PC 에서는 `git fetch --prune` 으로 낡은 원격 추적 브랜치를 정리한다"]', NULL, '합쳐진 것을 확인하고 로컬을 지운 뒤 원격을 지웁니다. 원격 삭제는 다른 저장소의 origin/이름 을 자동으로 지우지 않아 fetch --prune 이 필요합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "git-branch 문서", "url": "https://git-scm.com/docs/git-branch"}, {"title": "git-push 문서", "url": "https://git-scm.com/docs/git-push"}, {"title": "git-fetch 문서", "url": "https://git-scm.com/docs/git-fetch"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 495 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 433 WHERE id = 56;
UPDATE quest_set SET display_order = 434 WHERE id = 95;
UPDATE quest_set SET display_order = 435 WHERE id = 365;
UPDATE quest_set SET display_order = 436 WHERE id = 168;
UPDATE quest_set SET display_order = 437 WHERE id = 320;
UPDATE quest_set SET display_order = 438 WHERE id = 180;
UPDATE quest_set SET display_order = 439 WHERE id = 323;
UPDATE quest_set SET display_order = 440 WHERE id = 188;
UPDATE quest_set SET display_order = 441 WHERE id = 325;
UPDATE quest_set SET display_order = 442 WHERE id = 192;
UPDATE quest_set SET display_order = 443 WHERE id = 326;
UPDATE quest_set SET display_order = 444 WHERE id = 196;
UPDATE quest_set SET display_order = 445 WHERE id = 327;
UPDATE quest_set SET display_order = 446 WHERE id = 486;
UPDATE quest_set SET display_order = 447 WHERE id = 491;
UPDATE quest_set SET display_order = 432, unit_id = (SELECT id FROM unit WHERE id = 15), icon = '📤' WHERE id = 495;
