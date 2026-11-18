-- Git 실습 세트 491. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_git_tools_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 491, 'Git 작업공간과 조회 도구 손연습: worktree, grep -n, shortlog -sn, describe, archive, branch --merged·-m, pre-commit 훅, diff --name-status', '저장소를 다루는 보조 도구를 직접 써 봅니다. worktree 로 작업 폴더 추가, git grep 으로 추적 파일 검색, shortlog 로 작성자별 커밋 수, describe 로 태그 기준 버전 문자열, archive 로 .git 없는 소스 묶음, branch --merged 와 -m, pre-commit 훅으로 FIXME 커밋 막기, diff --name-status 를 실습합니다.', 'linux', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 491);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 1, '작업 폴더를 하나 더 만들기 (git worktree add)', '**배경** — `git worktree add 경로 브랜치` 는 **같은 저장소의 다른 브랜치를 별도 폴더에** 펼칩니다. 브랜치를 바꾸지 않고(작업 중인 파일을 치우지 않고) 긴급 수정·리뷰를 병행할 때 씁니다. `.git` 은 공유됩니다. `/tmp/lab/proj` 는 `main` 에 있고 브랜치 `wip` 이 있습니다.

**문제** — 브랜치 `wip` 을 **`/tmp/lab/wt`** 폴더에 worktree 로 펼치세요. (`/tmp/lab/wt/w.txt` 가 보여야 합니다.)', '`cd /tmp/lab/proj && git worktree add /tmp/lab/wt wip`', 'cd /tmp/lab/proj
git worktree add /tmp/lab/wt wip
git worktree list
ls /tmp/lab/wt

# 같은 브랜치를 두 곳에서 동시에 체크아웃할 수는 없다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( [ -f /tmp/lab/wt/w.txt ] ) && ( git -C /tmp/lab/proj worktree list | grep -q \\"/tmp/lab/wt\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "wt 폴더에 w.txt 가 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/wt/w.txt ]"]}, {"label": "worktree 목록에 wt 가 있다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj worktree list | grep -q \\"/tmp/lab/wt\\""]}]', '[{"title": "git-worktree 문서", "url": "https://git-scm.com/docs/git-worktree"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 2, '저장소에서 글자 찾기 (git grep -n)', '**배경** — `git grep 패턴` 은 **추적 중인 파일만** 대상으로 빠르게 찾습니다(`.gitignore` 된 빌드 산출물은 제외). `-n` 은 줄 번호를 붙입니다. 결과는 `파일:줄번호:내용` 형태입니다.

**문제** — `/tmp/lab/proj` 에서 `TODO` 가 있는 줄을 **줄 번호와 함께** **`/tmp/q2.txt`** 에 저장하세요. (`app.txt` 와 `b.txt` 두 줄)', '`cd /tmp/lab/proj && git grep -n TODO > /tmp/q2.txt`', 'cd /tmp/lab/proj
git grep -n TODO > /tmp/q2.txt
cat /tmp/q2.txt

# app.txt:1:TODO: a 처럼 나온다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/q2.txt)\\" -eq 2 ] ) && ( grep -q \\"app.txt:1:TODO\\" /tmp/q2.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "2줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/q2.txt)\\" -eq 2 ]"]}, {"label": "줄 번호 형식이다", "cmd": ["sh", "-c", "grep -q \\"app.txt:1:TODO\\" /tmp/q2.txt"]}]', '[{"title": "git-grep 문서", "url": "https://git-scm.com/docs/git-grep"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 3, '누가 몇 커밋 했나 (git shortlog -sn)', '**배경** — `git shortlog` 는 커밋을 **작성자별로 묶어** 보여 줍니다. `-s` 는 개수만, `-n` 은 **많은 순**으로 정렬합니다. 기여도를 대충 훑어볼 때 씁니다. `main` 의 커밋은 alice 2개, bob 1개입니다.

**문제** — `HEAD` 의 작성자별 커밋 수를 **많은 순**으로 **`/tmp/q3.txt`** 에 저장하세요. (첫 줄이 alice 여야 합니다. 리비전 없이 쓰면 터미널이 아닐 때 표준입력을 읽으므로 `HEAD` 를 붙이세요.)', '`git shortlog -sn HEAD > /tmp/q3.txt` (끝에 `HEAD` 를 붙여요)', 'cd /tmp/lab/proj
git shortlog -sn HEAD > /tmp/q3.txt
cat /tmp/q3.txt

# 개수<탭>이름. 터미널이 아닌 곳(스크립트·리다이렉트)에서는 리비전을 안 주면 표준입력을 읽으므로 HEAD 를 붙인다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( head -n 1 /tmp/q3.txt | grep -q alice ) && ( [ \\"$(wc -l < /tmp/q3.txt)\\" -eq 2 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "첫 줄이 alice 다", "cmd": ["sh", "-c", "head -n 1 /tmp/q3.txt | grep -q alice"]}, {"label": "작성자 2명이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/q3.txt)\\" -eq 2 ]"]}]', '[{"title": "git-shortlog 문서", "url": "https://git-scm.com/docs/git-shortlog"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 4, '가장 가까운 태그로 현재 위치 표현하기 (git describe)', '**배경** — `git describe --tags` 는 현재 커밋을 **가장 가까운 태그 + 그 뒤의 커밋 수 + 해시**(`v1.0-2-g1a2b3c4`)로 표현합니다. 빌드 번호나 버전 문자열을 자동으로 만들 때 씁니다. 태그 `v1.0` 은 첫 커밋에 있고 그 뒤로 `main` 에 커밋이 2개 더 있습니다.

**문제** — 현재 커밋의 `describe` 결과를 **`/tmp/q4.txt`** 에 저장하세요. (`v1.0-2-g` 로 시작해야 합니다.)', '`git describe --tags > /tmp/q4.txt`', 'cd /tmp/lab/proj
git describe --tags > /tmp/q4.txt
cat /tmp/q4.txt

# 태그 위면 v1.0 만, 그 뒤에 커밋이 있으면 -개수-g해시 가 붙는다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( grep -q \\"^v1\\\\.0-2-g\\" /tmp/q4.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "v1.0-2-g 로 시작한다", "cmd": ["sh", "-c", "grep -q \\"^v1\\\\.0-2-g\\" /tmp/q4.txt"]}]', '[{"title": "git-describe 문서", "url": "https://git-scm.com/docs/git-describe"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 5, '.git 없이 현재 상태만 압축하기 (git archive)', '**배경** — `git archive` 는 커밋 하나의 **파일 스냅샷만** 묶어 `tar`·`zip` 으로 만듭니다. `.git` 폴더와 이력이 들어가지 않아 **배포용 소스 묶음**을 만들 때 씁니다. `-o 파일` 로 출력 파일을 정하며 확장자로 형식이 정해집니다.

**문제** — `/tmp/lab/proj` 의 `HEAD` 를 **`/tmp/q5.tar`** 로 묶으세요. (`.git` 은 들어가면 안 됩니다.)', '`git archive -o /tmp/q5.tar HEAD`', 'cd /tmp/lab/proj
git archive -o /tmp/q5.tar HEAD
tar tf /tmp/q5.tar

# app.txt, b.txt, c.txt 만 들어 있다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( tar tf /tmp/q5.tar | grep -q app.txt ) && ( ! tar tf /tmp/q5.tar | grep -q \\"^\\\\.git\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "app.txt 가 들어 있다", "cmd": ["sh", "-c", "tar tf /tmp/q5.tar | grep -q app.txt"]}, {"label": ".git 은 없다", "cmd": ["sh", "-c", "! tar tf /tmp/q5.tar | grep -q \\"^\\\\.git\\""]}]', '[{"title": "git-archive 문서", "url": "https://git-scm.com/docs/git-archive"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 6, 'main 에 이미 합쳐진 브랜치만 보기 (branch --merged)', '**배경** — `git branch --merged 기준` 은 **기준 브랜치에 이미 합쳐진** 브랜치만 나열합니다. 지워도 안전한 브랜치를 찾을 때 씁니다. 반대는 `--no-merged` 입니다. 브랜치 `done`(main 과 같은 위치)과 `wip`(main 에 없는 커밋 있음)이 있습니다.

**문제** — `main` 에 합쳐진 브랜치 목록을 **`/tmp/q6.txt`** 에 저장하세요. (`done` 은 있고 `wip` 은 없어야 합니다.)', '`git branch --merged main > /tmp/q6.txt`', 'cd /tmp/lab/proj
git branch --merged main > /tmp/q6.txt
cat /tmp/q6.txt

# wip 에는 main 에 없는 커밋이 있어 목록에 안 나온다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( grep -qw done /tmp/q6.txt ) && ( ! grep -qw wip /tmp/q6.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "done 이 있다", "cmd": ["sh", "-c", "grep -qw done /tmp/q6.txt"]}, {"label": "wip 은 없다", "cmd": ["sh", "-c", "! grep -qw wip /tmp/q6.txt"]}]', '[{"title": "git-branch 문서", "url": "https://git-scm.com/docs/git-branch"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 7, '브랜치 이름 바꾸기 (git branch -m)', '**배경** — `git branch -m 옛이름 새이름` 은 브랜치 이름만 바꿉니다. 커밋은 그대로입니다. 이미 원격에 올렸다면 원격에는 옛 이름이 남으므로 따로 처리해야 합니다.

**문제** — `wip` 브랜치의 이름을 **`feature-x`** 로 바꾸세요.', '`git branch -m wip feature-x`', 'cd /tmp/lab/proj
git branch -m wip feature-x
git branch

# 현재 브랜치 이름을 바꿀 때는 git branch -m 새이름 만 써도 된다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( git -C /tmp/lab/proj rev-parse --verify -q feature-x >/dev/null ) && ( ! git -C /tmp/lab/proj rev-parse --verify -q wip >/dev/null )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "feature-x 가 있다", "cmd": ["sh", "-c", "git -C /tmp/lab/proj rev-parse --verify -q feature-x >/dev/null"]}, {"label": "wip 은 없다", "cmd": ["sh", "-c", "! git -C /tmp/lab/proj rev-parse --verify -q wip >/dev/null"]}]', '[{"title": "git-branch 문서", "url": "https://git-scm.com/docs/git-branch"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 8, 'FIXME 가 든 커밋을 막는 훅 (pre-commit)', '**배경** — **훅(hook)** 은 커밋·푸시 같은 시점에 자동으로 실행되는 스크립트입니다. `.git/hooks/pre-commit` 이 **0 이 아닌 종료 코드**로 끝나면 커밋이 **취소**됩니다. 실행 권한(`chmod +x`)이 있어야 동작합니다. `git diff --cached` 는 이번에 커밋될 변경을 보여 줍니다.

**문제** — `/tmp/lab/proj` 에 **스테이징된 변경에 `FIXME` 가 있으면 커밋을 막는** `pre-commit` 훅을 만드세요. (`FIXME` 가 없으면 커밋은 되어야 합니다.)', '`.git/hooks/pre-commit` 에 `git diff --cached | grep -q FIXME && exit 1` 을 쓰고 `chmod +x`', 'cd /tmp/lab/proj
printf ''#!/bin/sh\\nif git diff --cached | grep -q FIXME; then echo "FIXME 가 있어 커밋을 막습니다"; exit 1; fi\\n'' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 훅은 저장소(.git) 안에 있어 clone 으로는 전달되지 않는다', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( [ -x /tmp/lab/proj/.git/hooks/pre-commit ] ) && ( rm -rf /tmp/lab/chk && cp -r /tmp/lab/proj /tmp/lab/chk && cd /tmp/lab/chk && echo FIXME > x.txt && git add x.txt && ! git commit -qm t ) && ( cd /tmp/lab/chk && git reset -q && echo ok > y.txt && git add y.txt && git commit -qm t )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "훅이 실행 가능하다", "cmd": ["sh", "-c", "[ -x /tmp/lab/proj/.git/hooks/pre-commit ]"]}, {"label": "FIXME 가 든 커밋은 막힌다", "cmd": ["sh", "-c", "rm -rf /tmp/lab/chk && cp -r /tmp/lab/proj /tmp/lab/chk && cd /tmp/lab/chk && echo FIXME > x.txt && git add x.txt && ! git commit -qm t"]}, {"label": "FIXME 없는 커밋은 된다", "cmd": ["sh", "-c", "cd /tmp/lab/chk && git reset -q && echo ok > y.txt && git add y.txt && git commit -qm t"]}]', '[{"title": "githooks 문서", "url": "https://git-scm.com/docs/githooks"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 9, '두 시점 사이에 바뀐 파일과 상태 보기 (diff --name-status)', '**배경** — `git diff --name-status 이전 이후` 는 두 커밋 사이에 **어떤 파일이 어떻게** 바뀌었는지 한 글자 상태(`A` 추가, `M` 수정, `D` 삭제, `R` 이름 변경)와 함께 나열합니다. 릴리스 사이 변경 파일을 훑을 때 씁니다.

**문제** — 태그 **`v1.0` 과 `HEAD`** 사이에 바뀐 파일과 상태를 **`/tmp/q9.txt`** 에 저장하세요. (`b.txt`, `c.txt` 가 `A` 로 나옵니다.)', '`git diff --name-status v1.0 HEAD > /tmp/q9.txt`', 'cd /tmp/lab/proj
git diff --name-status v1.0 HEAD > /tmp/q9.txt
cat /tmp/q9.txt

# A<탭>b.txt, A<탭>c.txt', '["sh", "-c", "rm -f ~/.gitconfig; rm -rf /tmp/lab /tmp/q*.txt && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com && git config --global init.defaultBranch main && mkdir proj && cd proj && git init -q && echo ''TODO: a'' > app.txt && git add app.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c1 && git tag v1.0 && echo ''TODO: b'' > b.txt && git add b.txt && git -c user.name=bob -c user.email=b@x.com commit -qm c2 && echo x > c.txt && git add c.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c3 && git branch done && git switch -qc wip && echo w > w.txt && git add w.txt && git -c user.name=alice -c user.email=a@x.com commit -qm c4 && git switch -q main"]', '["sh", "-c", "( grep -Eq \\"^A[[:space:]]+b.txt\\" /tmp/q9.txt ) && ( grep -Eq \\"^A[[:space:]]+c.txt\\" /tmp/q9.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "b.txt 가 A 다", "cmd": ["sh", "-c", "grep -Eq \\"^A[[:space:]]+b.txt\\" /tmp/q9.txt"]}, {"label": "c.txt 가 A 다", "cmd": ["sh", "-c", "grep -Eq \\"^A[[:space:]]+c.txt\\" /tmp/q9.txt"]}]', '[{"title": "git-diff 문서", "url": "https://git-scm.com/docs/git-diff"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 10, 'git worktree 를 쓰는 이유', '`git worktree add` 로 두 번째 작업 폴더를 만드는 가장 큰 이점은 무엇일까요?', '저장소를 다시 내려받지 않아도 돼요.', NULL, NULL, '[]', 'choice', '["저장소를 통째로 복제해 이력을 따로 둔다", "다른 브랜치를 동시에 열어 둔다", "두 브랜치를 자동으로 합쳐 준다", "원격 저장소에 자동으로 올려 준다"]', 1, 'worktree 는 .git 을 공유하면서 다른 브랜치를 별도 폴더에 체크아웃합니다. 복제(clone)와 달리 이력·객체를 공유해 가볍고, 작업 중인 파일을 stash 하지 않고도 긴급 수정을 병행할 수 있습니다.', NULL, NULL, NULL, '[{"title": "git-worktree 문서", "url": "https://git-scm.com/docs/git-worktree"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 11, '작업 폴더를 하나 더', '현재 폴더를 그대로 두고 브랜치 `feature` 를 다른 폴더에 펼치는 명령입니다. 빈칸을 채우세요.', '"작업 트리" 의 영어예요.', NULL, NULL, '[]', 'fill', '["worktree", "stash", "switch", "clone"]', NULL, 'git worktree add 경로 브랜치 는 같은 저장소의 브랜치를 새 폴더에 체크아웃합니다. stash 는 임시 보관, switch 는 현재 폴더의 브랜치 이동, clone 은 저장소 복제입니다.', '[0]', 'git {0} add ../wt feature', NULL, '[{"title": "git-worktree 문서", "url": "https://git-scm.com/docs/git-worktree"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 491, 12, 'worktree 로 긴급 수정하고 정리하는 순서', '작업 중인 폴더를 건드리지 않고 worktree 로 긴급 수정을 반영하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 수정·커밋 → 합치기 → 치우기예요.', NULL, NULL, '[]', 'order', '["`git worktree add ../hotfix hotfix` 로 수정용 폴더를 만든다", "`../hotfix` 에서 고치고 커밋한다", "원래 폴더에서 `git merge hotfix` 로 합친다", "`git worktree remove ../hotfix` 로 폴더를 치운다"]', NULL, 'worktree 는 별도 폴더에서 수정하고 커밋한 뒤, 원래 폴더에서 그 브랜치를 합치고, 끝나면 remove 로 정리합니다. 원래 폴더의 작업 파일은 건드리지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "git-worktree 문서", "url": "https://git-scm.com/docs/git-worktree"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 491 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 446, unit_id = (SELECT id FROM unit WHERE id = 50), icon = '🗂️' WHERE id = 491;
