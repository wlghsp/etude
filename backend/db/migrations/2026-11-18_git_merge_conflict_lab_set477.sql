-- Git 실습 세트 477. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_git_merge_conflict_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 477, 'Git 병합 충돌 손연습: 충돌 해결, merge --abort, --ours·--theirs, -X·-s, --ff-only·--no-ff, 충돌 파일 목록, rerere', '직접 병합하고 충돌을 풀어 봅니다. 충돌 난 병합을 손으로 해결하고 --abort 로 취소하기, --ours·--theirs 로 한쪽 고르기, -X theirs 와 -s ours 의 차이, --ff-only 와 --no-ff, diff --diff-filter=U 로 충돌 파일 목록 뽑기, rerere 로 같은 충돌 재활용하기를 실습합니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 477);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 1, '충돌 난 병합을 손으로 풀기', '**배경** — `main` 과 `feature` 가 `f.txt` 의 같은 줄을 서로 다르게 바꿨습니다(`mode=main`, `mode=feature`). `git merge feature` 는 **충돌**로 멈추고, 파일에 `<<<<<<<` `=======` `>>>>>>>` 표시를 남깁니다. 파일을 원하는 내용으로 고치고 `git add` 로 해결을 알린 뒤 커밋하면 병합이 끝납니다.

**문제** — `/tmp/lab/proj` 에서 `main` 에 `feature` 를 병합하세요. 충돌은 `f.txt` 를 **`mode=both`** 한 줄로 해결하고, 병합 커밋까지 만드세요.', '충돌 → `echo mode=both > f.txt` → `git add f.txt` → `git commit --no-edit`', 'cd /tmp/lab/proj
git merge feature
echo mode=both > f.txt
git add f.txt
git commit -q --no-edit
cat f.txt
git log --oneline --graph

# 충돌이 나면 병합은 멈춘 상태(MERGE_HEAD). 고치고 add 한 뒤 commit 으로 끝낸다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt mode=base base && git checkout -q -b feature && ci f.txt mode=feature ''feature change'' && git checkout -q main && ci f.txt mode=main ''main change'' && git rev-parse main > /tmp/lab/orig.txt"]', '["sh", "-c", "( cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ] ) && ( cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=both ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합이 끝났다 (진행 중 아님)", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ]"]}, {"label": "f.txt 가 mode=both 다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=both ]"]}, {"label": "병합 커밋이 1개다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 2, '충돌난 병합을 취소하기 (merge --abort)', '**배경** — 병합 중 충돌이 나서 "일단 되돌리고 싶다" 면 `git merge --abort` 가 **병합을 시작하기 전 상태**로 돌려놓습니다. 충돌 중에는 `git status -s` 가 충돌 파일을 `UU` 로 보여 줍니다.

**문제** — `main` 에서 `git merge feature` 를 실행해 충돌이 나게 하고, 그때의 `git status -s` 출력을 **`/tmp/q2.txt`** 에 저장한 다음, 병합을 **취소**하세요. 끝나면 `f.txt` 는 `mode=main` 이고 병합 중 상태가 아니어야 합니다.', '`git merge feature` → `git status -s > /tmp/q2.txt` → `git merge --abort`', 'cd /tmp/lab/proj
git merge feature
git status -s > /tmp/q2.txt
git merge --abort
cat /tmp/q2.txt
cat f.txt

# UU 는 양쪽이 수정한 충돌 파일. --abort 는 병합 전으로 되돌린다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt mode=base base && git checkout -q -b feature && ci f.txt mode=feature ''feature change'' && git checkout -q main && ci f.txt mode=main ''main change'' && git rev-parse main > /tmp/lab/orig.txt"]', '["sh", "-c", "( grep -q \\"^UU f.txt\\" /tmp/q2.txt ) && ( cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ] ) && ( cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=main ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-parse main)\\" = \\"$(cat /tmp/lab/orig.txt)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "충돌 때의 상태(UU f.txt)를 저장했다", "cmd": ["sh", "-c", "grep -q \\"^UU f.txt\\" /tmp/q2.txt"]}, {"label": "병합이 진행 중이 아니다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ]"]}, {"label": "f.txt 가 mode=main 이다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=main ]"]}, {"label": "main 이 병합 전 커밋 그대로다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-parse main)\\" = \\"$(cat /tmp/lab/orig.txt)\\" ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 3, '충돌에서 한쪽 내용 고르기 (--ours / --theirs)', '**배경** — 병합 충돌에서 파일 전체를 **한쪽 것으로** 정하려면 `git checkout --ours 파일`(지금 브랜치 쪽) 또는 `--theirs 파일`(병합해 오는 쪽)을 씁니다. 병합 중에서 `ours` 는 현재 브랜치, `theirs` 는 `git merge` 에 넘긴 브랜치입니다.

**문제** — `main` 에 `feature` 를 병합하다 충돌이 나면 **`feature` 쪽 내용**(`mode=feature`)을 골라 병합을 끝내세요. `--theirs` 를 쓰고, `add` 후 커밋합니다.', '`git merge feature` → `git checkout --theirs f.txt` → `git add f.txt` → `git commit --no-edit`', 'cd /tmp/lab/proj
git merge feature
git checkout --theirs f.txt
git add f.txt
git commit -q --no-edit
cat f.txt

# 병합 중에는 ours=지금 브랜치(main), theirs=가져오는 브랜치(feature). 리베이스에서는 반대가 된다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt mode=base base && git checkout -q -b feature && ci f.txt mode=feature ''feature change'' && git checkout -q main && ci f.txt mode=main ''main change'' && git rev-parse main > /tmp/lab/orig.txt"]', '["sh", "-c", "( cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ] ) && ( cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=feature ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합이 끝났다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ]"]}, {"label": "f.txt 가 mode=feature 다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=feature ]"]}, {"label": "병합 커밋이 1개다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 4, '충돌 구간만 자동으로 한쪽 고르기 (merge -X theirs)', '**배경** — `git merge -X theirs 브랜치` 는 병합하다 **충돌이 나는 구간에서만** 상대(`theirs`) 쪽을 자동으로 고릅니다. 충돌이 없는 변경은 평소처럼 합쳐집니다. 손으로 풀지 않고 한 번에 끝낼 때 쓰지만, 어느 쪽 변경이 버려지는지 알고 써야 합니다.

**문제** — `main` 에 `feature` 를 `-X theirs` 로 병합하세요. 충돌 없이 한 번에 끝나고 `f.txt` 는 `mode=feature` 여야 합니다.', '`git merge -X theirs feature`', 'cd /tmp/lab/proj
git merge -X theirs feature -m ''merge feature''
cat f.txt
git log --oneline --graph

# -X theirs 는 ''충돌 구간만'' 상대 쪽을 고르는 전략 옵션이다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt mode=base base && git checkout -q -b feature && ci f.txt mode=feature ''feature change'' && git checkout -q main && ci f.txt mode=main ''main change'' && git rev-parse main > /tmp/lab/orig.txt"]', '["sh", "-c", "( cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ] ) && ( cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=feature ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합이 끝났다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ]"]}, {"label": "f.txt 가 mode=feature 다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=feature ]"]}, {"label": "병합 커밋이 1개다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 5, '내용은 그대로 두고 병합 기록만 남기기 (merge -s ours)', '**배경** — `git merge -s ours 브랜치` 는 **상대의 변경을 전부 버리고** 현재 브랜치 내용 그대로 병합 커밋만 만듭니다. "이 브랜치는 이미 반영했거나 필요 없지만, 병합했다는 기록은 남기고 싶다" 할 때 씁니다. (`-X ours` 와 다릅니다: 그쪽은 충돌 구간만 우리 쪽으로 고릅니다.)

**문제** — `main` 에 `feature` 를 `-s ours` 로 병합하세요. `f.txt` 는 `mode=main` 그대로이고, `feature` 가 `main` 의 조상이 되어야 합니다.', '`git merge -s ours feature`', 'cd /tmp/lab/proj
git merge -s ours feature -m ''merge feature (keep ours)''
cat f.txt
git log --oneline --graph

# -s ours 는 상대 변경을 전부 버리고 병합 기록만 남긴다. 충돌 자체가 생기지 않는다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt mode=base base && git checkout -q -b feature && ci f.txt mode=feature ''feature change'' && git checkout -q main && ci f.txt mode=main ''main change'' && git rev-parse main > /tmp/lab/orig.txt"]', '["sh", "-c", "( cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ] ) && ( cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=main ] ) && ( cd /tmp/lab/proj && git merge-base --is-ancestor feature main ) && ( cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합이 끝났다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ ! -e .git/MERGE_HEAD ]"]}, {"label": "f.txt 가 mode=main 이다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=main ]"]}, {"label": "feature 가 main 의 조상이다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && git merge-base --is-ancestor feature main"]}, {"label": "병합 커밋이 1개다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 6, '빨리 감기만 허용하기 (merge --ff-only)', '**배경** — `git merge --ff-only 브랜치` 는 **빨리 감기(fast-forward)가 가능할 때만** 병합하고, 갈라져서 병합 커밋이 필요하면 **실패**합니다. 실수로 불필요한 병합 커밋이 생기는 것을 막습니다. 준비된 저장소에서 `feature` 는 `main` 보다 앞서 있고(빨리 감기 가능), `other` 는 `main` 과 갈라져 있습니다(불가능).

**문제** — 먼저 `main` 에서 `other` 를 `--ff-only` 로 병합해 보고 **종료 코드**를 `/tmp/q6.txt` 에 저장하세요(실패해야 하므로 0 이 아닙니다). 그런 다음 `feature` 를 `--ff-only` 로 병합해 `main` 이 `feature` 와 같은 커밋이 되게 하세요.', '`git merge --ff-only other; echo $? > /tmp/q6.txt` 후 `git merge --ff-only feature`', 'cd /tmp/lab/proj
git merge --ff-only other
echo $? > /tmp/q6.txt
git merge --ff-only feature
git log --oneline --graph --all

# 갈라진 브랜치는 ff-only 가 거부한다. 앞서 있는 브랜치는 병합 커밋 없이 포인터만 옮긴다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci base.txt base base && git checkout -q -b other && ci o.txt o1 ''other 1'' && git checkout -q main && ci m.txt m ''main 2'' && git checkout -q -b feature && ci x.txt x ''feature 1'' && git checkout -q main"]', '["sh", "-c", "( [ \\"$(cat /tmp/q6.txt)\\" -ne 0 ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-parse main)\\" = \\"$(git rev-parse feature)\\" ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 0 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "갈라진 브랜치 병합은 실패했다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q6.txt)\\" -ne 0 ]"]}, {"label": "main 이 feature 와 같은 커밋이다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-parse main)\\" = \\"$(git rev-parse feature)\\" ]"]}, {"label": "병합 커밋이 없다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 0 ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 7, '빨리 감기가 가능해도 병합 커밋 만들기 (--no-ff)', '**배경** — 병합이 빨리 감기로 가능해도 `git merge --no-ff 브랜치` 는 **항상 병합 커밋을 만듭니다**. 브랜치가 있었다는 흔적이 이력에 남습니다. `feature` 는 `main` 보다 앞서 있어 평소엔 빨리 감기가 됩니다.

**문제** — `main` 에 `feature` 를 `--no-ff` 로 병합하고 병합 커밋 메시지를 **`merge feature`** 로 하세요. 병합 커밋의 첫 부모는 병합 전 `main` 이어야 합니다.', '`git merge --no-ff feature -m "merge feature"`', 'cd /tmp/lab/proj
git merge --no-ff feature -m ''merge feature''
git log --oneline --graph

# --no-ff 는 ff 가능해도 병합 커밋을 만든다. 첫 부모(HEAD^1)가 병합 전 main 이다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci base.txt base base && git checkout -q -b other && ci o.txt o1 ''other 1'' && git checkout -q main && ci m.txt m ''main 2'' && git checkout -q -b feature && ci x.txt x ''feature 1'' && git checkout -q main"]', '["sh", "-c", "( cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ] ) && ( cd /tmp/lab/proj && [ \\"$(git log -1 --format=%s)\\" = \\"merge feature\\" ] ) && ( cd /tmp/lab/proj && [ \\"$(git rev-parse HEAD^2)\\" = \\"$(git rev-parse feature)\\" ] ) && ( cd /tmp/lab/proj && ! git log --format=%s HEAD^1 | grep -qx \\"feature 1\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "병합 커밋이 1개다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-list --merges --count HEAD)\\" -eq 1 ]"]}, {"label": "제목이 merge feature 다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git log -1 --format=%s)\\" = \\"merge feature\\" ]"]}, {"label": "두 번째 부모가 feature 다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git rev-parse HEAD^2)\\" = \\"$(git rev-parse feature)\\" ]"]}, {"label": "첫 부모 쪽에 feature 의 커밋이 없다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && ! git log --format=%s HEAD^1 | grep -qx \\"feature 1\\""]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 8, '충돌한 파일 목록 뽑기', '**배경** — 병합이 충돌로 멈췄을 때 **충돌한 파일만** 뽑는 방법은 `git diff --name-only --diff-filter=U` 입니다(`U` = unmerged). 파일이 많을 때 어디부터 고칠지 파악합니다. 이번 저장소는 `f.txt`, `g.txt` 가 충돌하고 `h.txt` 는 충돌 없이 합쳐집니다.

**문제** — `main` 에 `feature` 를 병합해 충돌이 나게 한 뒤, **충돌한 파일 이름**만 **`/tmp/q8.txt`** 에 저장하세요. (`f.txt`, `g.txt` 만 있어야 합니다.)', '`git merge feature` → `git diff --name-only --diff-filter=U > /tmp/q8.txt`', 'cd /tmp/lab/proj
git merge feature
git diff --name-only --diff-filter=U > /tmp/q8.txt
cat /tmp/q8.txt

# --diff-filter=U 는 병합이 안 된(충돌) 파일만 고른다. h.txt 는 자동 병합돼서 빠진다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt f-base base && ci g.txt g-base ''add g'' && ci h.txt h-base ''add h'' && git checkout -q -b feature && echo f-feature > f.txt && echo g-feature > g.txt && echo h-feature > h.txt && git add -A && git commit -qm ''feature change'' && git checkout -q main && echo f-main > f.txt && echo g-main > g.txt && git add -A && git commit -qm ''main change''"]', '["sh", "-c", "( [ \\"$(sort /tmp/q8.txt | tr \\"\\\\n\\" ,)\\" = \\"f.txt,g.txt,\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "f.txt 와 g.txt 만 있다", "cmd": ["sh", "-c", "[ \\"$(sort /tmp/q8.txt | tr \\"\\\\n\\" ,)\\" = \\"f.txt,g.txt,\\" ]"]}]', '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 9, '같은 충돌을 두 번 안 풀기 (rerere)', '**배경** — `rerere`("reuse recorded resolution")는 **충돌을 어떻게 풀었는지 기억했다가**, 같은 충돌이 다시 나면 자동으로 적용합니다. 같은 브랜치를 여러 번 병합·리베이스할 때 유용합니다. `git config rerere.enabled true` 로 켭니다.

**문제** — (1) `rerere` 를 켠 뒤 `main` 에 `feature` 를 병합해 충돌을 **`mode=both`** 로 풀고 커밋하세요. (2) 그 병합을 `git reset --hard HEAD~1` 로 되돌린 다음 **다시** `git merge feature` 하세요. 두 번째에는 `f.txt` 가 손대지 않아도 `mode=both` 로 채워져 있어야 합니다.', '`git config rerere.enabled true` → 병합·해결·커밋 → `git reset --hard HEAD~1` → `git merge feature`', 'cd /tmp/lab/proj
git config rerere.enabled true
git merge feature
echo mode=both > f.txt
git add f.txt
git commit -q --no-edit
git reset -q --hard HEAD~1
git merge feature
cat f.txt

# 두 번째 병합에서 ''Resolved f.txt using previous resolution'' 이 나오며 이전 해결이 자동 적용된다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && ci() { echo \\"$2\\" > \\"$1\\"; git add \\"$1\\"; git commit -qm \\"$3\\"; }; ci f.txt mode=base base && git checkout -q -b feature && ci f.txt mode=feature ''feature change'' && git checkout -q main && ci f.txt mode=main ''main change'' && git rev-parse main > /tmp/lab/orig.txt"]', '["sh", "-c", "( cd /tmp/lab/proj && [ \\"$(git config rerere.enabled)\\" = true ] ) && ( cd /tmp/lab/proj && [ \\"$(ls .git/rr-cache | wc -l)\\" -ge 1 ] ) && ( cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=both ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "rerere 가 켜져 있다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(git config rerere.enabled)\\" = true ]"]}, {"label": "해결 기록이 저장됐다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(ls .git/rr-cache | wc -l)\\" -ge 1 ]"]}, {"label": "두 번째 병합에서 f.txt 가 자동으로 mode=both 다", "cmd": ["sh", "-c", "cd /tmp/lab/proj && [ \\"$(cat f.txt)\\" = mode=both ]"]}]', '[{"title": "git-rerere 문서", "url": "https://git-scm.com/docs/git-rerere"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 10, '-X ours 와 -s ours 의 차이', '`git merge -X ours 브랜치` 와 `git merge -s ours 브랜치` 의 차이로 맞는 것은 무엇일까요?', '하나는 충돌 구간만, 하나는 전체예요.', NULL, NULL, '[]', 'choice', '["-X ours 는 상대 변경을 전부 버리고, -s ours 는 충돌 구간만 우리 쪽으로 한다", "-X ours 는 충돌 구간만 우리 쪽으로, -s ours 는 상대 변경을 전부 버린다", "둘 다 충돌 구간만 우리 쪽으로 하고 나머지 병합은 하지 않는다", "-s ours 는 충돌이 없을 때만 동작하고 -X ours 는 충돌이 있어야 동작한다"]', 1, 'git-merge 문서는 ours 전략 옵션(-X ours)이 충돌하는 부분만 우리 쪽으로 해결하고 나머지는 평소처럼 합치는 반면, ours 병합 전략(-s ours)은 다른 쪽의 모든 변경을 무시하고 병합 기록만 남긴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 11, '충돌난 병합을 취소하기', '충돌로 멈춘 병합을 **병합 전 상태로 되돌리는** 명령입니다. 빈칸을 채우세요.', '"중단" 이에요.', NULL, NULL, '[]', 'fill', '["abort", "quit", "reset", "undo"]', NULL, 'git-merge 문서는 git merge --abort 가 병합 과정을 중단하고 병합 전 상태를 되살린다고 설명합니다. --quit 는 상태를 되돌리지 않고 병합 진행 정보만 버립니다.', '[0]', 'git merge --{0}', NULL, '[{"title": "git-merge 문서", "url": "https://git-scm.com/docs/git-merge"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 477, 12, 'rerere 로 충돌을 재활용하는 순서', 'rerere 가 이전 해결을 다시 쓰게 되는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '켜기 → 해결 → 되돌리기 → 다시 병합이에요.', NULL, NULL, '[]', 'order', '["`git config rerere.enabled true` 로 rerere 를 켠다", "처음 병합에서 난 충돌을 손으로 풀고 커밋한다", "병합을 되돌린다 (예: `git reset --hard HEAD~1`)", "같은 브랜치를 다시 병합하면 이전 해결이 자동 적용된다"]', NULL, 'git-rerere 문서의 설명을 이은 절차입니다. 해결 기록은 .git/rr-cache 에 저장됩니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "git-rerere 문서", "url": "https://git-scm.com/docs/git-rerere"}, {"title": "Pro Git — 고급 병합", "url": "https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 477 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 430 WHERE id = 54;
UPDATE quest_set SET display_order = 431 WHERE id = 94;
UPDATE quest_set SET display_order = 432 WHERE id = 56;
UPDATE quest_set SET display_order = 433 WHERE id = 95;
UPDATE quest_set SET display_order = 434 WHERE id = 365;
UPDATE quest_set SET display_order = 435 WHERE id = 168;
UPDATE quest_set SET display_order = 436 WHERE id = 320;
UPDATE quest_set SET display_order = 437 WHERE id = 180;
UPDATE quest_set SET display_order = 438 WHERE id = 323;
UPDATE quest_set SET display_order = 439 WHERE id = 188;
UPDATE quest_set SET display_order = 440 WHERE id = 325;
UPDATE quest_set SET display_order = 441 WHERE id = 192;
UPDATE quest_set SET display_order = 442 WHERE id = 326;
UPDATE quest_set SET display_order = 443 WHERE id = 196;
UPDATE quest_set SET display_order = 444 WHERE id = 327;
UPDATE quest_set SET display_order = 429, unit_id = (SELECT id FROM unit WHERE id = 49), icon = '🧩' WHERE id = 477;
