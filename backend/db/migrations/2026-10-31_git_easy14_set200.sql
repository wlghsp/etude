-- Git 세트 200. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set200.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 200, 'Git 일상 명령 정리: commit -a, add -A, stash, restore, reset, tag, clone --depth, fetch, diff --exit-code', 'Git 일상 작업의 동작을 한 개념씩 반복합니다. commit -a 가 담는 변경과 새 파일, add . 와 -A 와 -u 의 범위 차이, stash 와 -u·-m·pop·apply, restore 와 --staged, reset 의 --soft·기본·--hard 와 reflog, 태그를 만들고 push 하고 지우는 법과 로컬·원격 태그의 차이, clone 의 --depth·-b·--single-branch, fetch 와 pull 의 차이와 --all·--prune, merge-base --is-ancestor 의 종료 코드, diff 의 --exit-code 와 --quiet, --stat·--numstat·--shortstat 의 차이, format 과 tformat 의 줄바꿈, 여러 --grep 의 OR 과 -i, -n·--skip·--reverse 의 적용 순서를 짧은 객관식·빈칸·순서 문제로 익히고, 브랜치가 이미 들어갔는지 확인하기, 변경량을 단계별로 보기, 급한 수정 전에 작업 치워 두기, 태그 만들고 올리고 지우기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 200);
UPDATE quest_set SET display_order = 406, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🪡' WHERE id = 200;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 1, '--is-ancestor 종료 코드', '`git merge-base --is-ancestor A B` 의 결과는 어디로 알려 줄까요? A 가 B 의 조상일 때, 아닐 때, A 와 B 가 같은 커밋일 때, 없는 이름을 줄 때 종료 코드는 각각 얼마일까요?', '출력이 아니라 종료 코드로 답해요.', NULL, NULL, '[]', 'choice', '["조상이면 `yes` 를 출력하고 종료 코드는 항상 0 이다", "같은 커밋이면 조상이 아니므로 1 이다", "화면에 출력하지 않고 종료 코드로 알려 준다. 조상이면 0, 아니면 1, 같은 커밋이면 0(자기 자신도 조상으로 본다), 없는 이름이면 오류(128)이다", "없는 이름은 조상이 아니라는 뜻으로 1 이 나온다"]', 2, '`if git merge-base --is-ancestor feat main; then ...` 처럼 쉘 조건문에 바로 쓸 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 2, 'diff 의 --exit-code 와 --quiet', '`git diff --exit-code` 는 변경이 없을 때와 있을 때 종료 코드가 얼마일까요? `--quiet` 는 무엇이 다를까요? 스테이징된 변경은 어떻게 검사할까요?', '차이가 있으면 0 이 아니에요.', NULL, NULL, '[]', 'choice', '["변경이 있으면 0, 없으면 1 이다", "변경이 없으면 0, 있으면 1 이다. `--quiet` 는 출력을 아예 하지 않고 같은 종료 코드(`--exit-code` 포함)만 돌려 준다. 스테이징된 변경은 `git diff --cached --quiet` 로 검사한다", "`--quiet` 는 출력만 줄이고 종료 코드는 항상 0 이다", "`git diff --quiet` 는 스테이징된 변경도 함께 검사한다"]', 1, 'CI 에서 "작업 트리가 깨끗한가"를 확인하는 스크립트에 자주 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 3, '--stat, --numstat, --shortstat', '`git diff --stat`, `--numstat`, `--shortstat` 은 각각 무엇을 보여 줄까요? 바이너리 파일은 `--numstat` 에서 어떻게 나올까요?', '같은 변경량을 보여 주는 세 가지 모양이에요.', NULL, NULL, '[]', 'choice', '["`--stat` 은 파일별 변경 줄 수와 `+`/`-` 막대, 맨 아래 요약을 보여 준다. `--numstat` 은 추가 줄, 삭제 줄, 파일 이름을 탭으로 나눠 한 줄씩 보여 주고 바이너리 파일은 줄 수 자리에 `-` 두 개가 나온다. `--shortstat` 은 `2 files changed, 3 insertions(+)` 같은 요약 한 줄만 보여 준다", "`--numstat` 은 파일별 막대 그래프를 보여 준다", "`--shortstat` 은 파일 이름만 한 줄씩 보여 준다", "바이너리 파일은 `--numstat` 에서 0 0 으로 나온다"]', 0, '`--numstat` 은 사람이 아니라 스크립트가 읽기 좋은 모양이라 변경량을 집계할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 4, 'format 과 tformat', '`git log --pretty=format:''%s'' -2` 와 `--pretty=tformat:''%s'' -2` 는 출력 끝에서 무엇이 다를까요? `--format=''%s''` 는 둘 중 어느 쪽과 같을까요?', '구분자와 종결자의 차이예요.', NULL, NULL, '[]', 'choice', '["`format:` 이 마지막 줄 끝에 줄바꿈을 더 붙인다", "`--format` 은 `format:` 과 같아 마지막 줄바꿈이 없다", "둘은 완전히 같아 차이가 없다", "`format:` 은 커밋 사이에만 줄바꿈을 넣어 마지막 줄 끝에는 줄바꿈이 없고, `tformat:` 은 커밋마다 줄바꿈으로 끝낸다. `--format=''%s''` 는 `tformat:` 처럼 마지막에도 줄바꿈이 붙는다"]', 3, '`%H` 는 40자 전체 해시, `%h` 는 짧은 해시(작은 저장소에서 7자), `%an` 은 작성자 이름, `%s` 는 제목입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 5, '--grep 의 여러 조건', '`git log --grep=A --grep=B` 는 어떤 커밋을 보여 줄까요? `--grep=FEAT` 는 소문자 `feat` 제목과 맞을까요? `-i` 를 붙이면요?', '여러 `--grep` 은 기본이 "또는"이에요.', NULL, NULL, '[]', 'choice', '["`--grep` 을 여럿 쓰면 모두 맞아야 보인다", "`--grep` 은 대소문자를 구분하지 않는다", "`A` 나 `B` 중 하나라도 제목·본문에 맞는 커밋(OR)을 보여 준다. `--grep` 은 대소문자를 구분해서 `FEAT` 는 `feat` 와 맞지 않고 `-i` 를 붙이면 맞는다", "`-i` 를 붙이면 오히려 맞지 않는 커밋만 보인다"]', 2, '`-i` 는 `--regexp-ignore-case` 의 짧은 이름입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 6, 'commit -a 가 담는 것', '수정한 파일 `a.txt`, 삭제한 파일 `del.txt`, 새로 만든 파일 `newfile.txt` 가 있을 때 `git commit -a -m "msg"` 는 무엇을 커밋할까요? 커밋 뒤 `newfile.txt` 는요? `-am` 은 무엇이 다를까요?', '이미 추적 중인 파일만 대상이에요.', NULL, NULL, '[]', 'choice', '["새 파일 `newfile.txt` 도 함께 커밋된다", "추적 중인 파일의 수정(`a.txt`)과 삭제(`del.txt`)를 자동으로 스테이징해 커밋하고, 새로 만든 `newfile.txt` 는 포함되지 않아 `??`(추적 안 됨)로 남는다. `-am \\"msg\\"` 는 `-a -m \\"msg\\"` 를 줄여 쓴 것이다", "삭제한 `del.txt` 는 직접 `git rm` 해야 커밋된다", "`-am` 은 `-a` 와 달리 새 파일도 포함한다"]', 1, '새 파일은 한 번 `git add` 로 추적을 시작해야 이후 `-a` 로 담깁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 7, 'add . 와 -A 와 -u', '하위 폴더 `sub` 안에서 `git add .`, `git add -A`, `git add -u` 를 각각 하면 저장소 루트의 수정 파일과 새 파일, `sub` 안의 새 파일은 어떻게 될까요?', '`.` 은 현재 폴더예요.', NULL, NULL, '[]', 'choice', '["`git add .` 는 현재 폴더(`sub`) 이하의 새 파일·수정·삭제만 스테이징하고 루트의 변경은 담지 않는다. `git add -A` 는 저장소 전체의 새 파일·수정·삭제를 모두 담는다. `git add -u` 는 저장소 전체에서 이미 추적 중인 파일의 수정·삭제만 담고 새 파일은 담지 않는다", "`git add .` 는 어느 폴더에서 실행해도 저장소 전체를 담는다", "`git add -u` 는 새 파일도 함께 담는다", "`git add -A` 는 현재 폴더 이하만 담는다"]', 0, '루트에서 실행하면 `git add .` 와 `git add -A` 의 결과가 같아 보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 8, 'stash 로 작업 치우기', '작업 중인 수정 파일과 새로 만든 파일(`untracked.txt`)이 있을 때 `git stash` 와 `git stash -u -m "wip"` 는 각각 무엇을 치울까요? `pop` 과 `apply` 는 어떻게 다를까요?', '`-u` 는 추적 안 되는 파일까지 포함해요.', NULL, NULL, '[]', 'choice', '["`git stash` 는 새 파일도 함께 치운다", "`pop` 은 되돌린 뒤에도 stash 를 목록에 남긴다", "`apply` 는 되돌린 뒤 stash 를 자동으로 지운다", "`git stash` 는 추적 중인 파일의 수정만 치우고 새 파일은 그대로 남는다. `-u` 를 주면 새 파일까지 치워 작업 폴더가 깨끗해지고 `-m` 은 목록에 보일 이름을 정한다. `pop` 은 변경을 되돌리고 stash 를 목록에서 지우고 `apply` 는 되돌리되 stash 를 남긴다(`drop` 으로 따로 지운다)"]', 3, '되돌릴 때 충돌이 나면 `pop` 도 stash 를 지우지 않고 남겨 두니 `git stash list` 로 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 9, 'restore 로 변경 되돌리기', '`a.txt` 를 수정한 뒤 `git restore a.txt`, `git restore .`, 새로 만든 `un.txt` 가 있을 때의 결과는 어떨까요? 스테이징한 뒤에는 `git restore a.txt` 와 `git restore --staged a.txt` 가 각각 무엇을 할까요?', '`--staged` 는 스테이징을 취소해요.', NULL, NULL, '[]', 'choice', '["`git restore .` 는 새 파일도 함께 지운다", "`git restore a.txt` 는 스테이징된 변경도 취소한다", "`git restore a.txt` 는 작업 폴더의 수정을 버리고 마지막 스테이징·커밋 상태로 되돌리며 `git restore .` 는 추적 중인 파일 전체에 그렇게 한다. 새 파일 `un.txt` 는 그대로 남는다. 이미 스테이징했다면 `git restore a.txt` 는 아무것도 바꾸지 않고 `--staged` 는 스테이징만 취소해 수정 내용은 작업 폴더에 남긴다", "`git restore --staged a.txt` 는 수정 내용까지 버린다"]', 2, '없는 경로를 주면 `pathspec ... did not match any file(s) known to git` 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 10, 'reset 의 세 가지 모드', '마지막 커밋 `k2` 를 `git reset --soft HEAD~1`, `git reset HEAD~1`(기본), `git reset --hard HEAD~1` 로 각각 되돌리면 `k2` 가 추가한 파일은 어떻게 될까요?', '`--hard` 는 파일까지 버려요.', NULL, NULL, '[]', 'choice', '["`--soft` 는 파일 내용까지 지운다", "`--soft` 는 커밋만 취소하고 변경을 스테이징된 상태로 남기고, 기본(`--mixed`)은 커밋과 스테이징을 취소하되 파일 내용은 작업 폴더에 남긴다(새 파일이면 추적 안 됨 `??`). `--hard` 는 파일까지 지워 작업 폴더가 깨끗해진다. `git reflog` 로 이전 위치를 찾아 `reset --hard` 로 되돌릴 수 있다", "기본 `git reset` 은 `--hard` 와 같다", "`--hard` 로 되돌린 커밋은 `reflog` 에서도 찾을 수 없다"]', 1, '`git reset a.txt` 처럼 파일 이름을 주면 그 파일의 스테이징만 취소합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 11, '태그 만들고 올리고 지우기', '`git tag v1` 과 `git tag -a v2 -m "msg"` 는 어떻게 다를까요? `git push origin main` 은 태그를 올릴까요? `git tag -d v1` 후 원격의 `v1` 은요? 원격 태그를 지우려면요?', '태그는 push 를 따로 해요.', NULL, NULL, '[]', 'choice', '["`v1` 은 가벼운 태그(커밋을 가리킴), `-a` 는 메시지가 있는 주석 태그(태그 객체)이다. `git push origin main` 은 태그를 올리지 않아 `git push origin v1` 이나 `git push --tags` 를 해야 한다. `git tag -d v1` 은 로컬 태그만 지우고 원격의 `v1` 은 남아 있어서 `git push origin --delete v1` 로 지운다", "`git push origin main` 이 태그도 함께 올린다", "`git tag -d v1` 이 원격의 `v1` 도 함께 지운다", "같은 이름의 태그를 다시 만들면 자동으로 덮어쓴다"]', 0, '이미 있는 이름으로 `git tag v1` 을 하면 `already exists` 오류가 나고 `-f` 로 옮길 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 12, 'clone 옵션', '`git clone --depth 1 URL`, `git clone -b feat URL`, `git clone --single-branch -b feat URL`, `git clone URL mydir` 는 각각 무엇을 할까요?', '`--depth` 는 이력을 얕게 가져와요.', NULL, NULL, '[]', 'choice', '["`--depth 1` 은 브랜치를 하나만 가져온다", "`-b feat` 는 `feat` 브랜치만 가져온다", "`mydir` 은 원격 저장소 이름이다", "`--depth 1` 은 최신 커밋 하나만 가져와 얕은 저장소(`rev-parse --is-shallow-repository` 가 `true`)가 되고 `git fetch --unshallow` 로 전체 이력을 받을 수 있다. `-b feat` 는 `feat` 브랜치를 체크아웃하고(다른 브랜치의 원격 추적 정보도 받음), `--single-branch` 를 더하면 그 브랜치만 받는다. 마지막 인자 `mydir` 은 폴더 이름이다"]', 3, '이미 내용이 있는 폴더 이름을 주면 `destination path ... already exists and is not an empty directory` 오류가 납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 13, 'fetch 와 pull', '원격에 새 커밋이 올라온 뒤 `git fetch` 를 하면 내 `main` 과 작업 폴더는 어떻게 될까요? `git status -sb` 에는 무엇이 보일까요? `git pull` 은요? 원격에서 지워진 브랜치는 `fetch --prune` 에서 어떻게 될까요?', '`fetch` 는 가져오기만 해요.', NULL, NULL, '[]', 'choice', '["`git fetch` 가 현재 브랜치에 새 커밋을 합친다", "`fetch --prune` 은 로컬 브랜치를 지운다", "`git fetch` 는 `origin/main` 같은 원격 추적 브랜치만 갱신하고 내 `main` 과 작업 폴더는 바꾸지 않아서 `status -sb` 에 `[behind 1]` 처럼 뒤처진 정도가 보인다. `git pull` 은 가져온 뒤 현재 브랜치에 합친다. 원격에서 삭제된 브랜치의 `origin/feat` 는 그냥 `fetch` 로는 남고 `--prune` 을 주면 정리된다. `fetch --all` 은 등록된 모든 원격에서 가져온다", "`fetch --all` 은 현재 원격 하나만 가져온다"]', 2, '`git remote -v` 로 등록된 원격 목록을 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 14, '-n, --skip, --reverse 의 순서', '`git log --oneline` 에서 `-1 --reverse`, `-2 --reverse`, `--skip=1 -n 1`, `--skip=100` 은 각각 무엇을 보여 줄까요? (커밋이 6개 있다고 합시다)', '개수 제한이 뒤집기보다 먼저예요.', NULL, NULL, '[]', 'choice', '["`-1 --reverse` 는 가장 오래된 커밋을 보여 준다", "`-1 --reverse` 는 최근 1개만 고른 뒤 뒤집으므로 가장 최근 커밋 하나이고, `-2 --reverse` 는 최근 2개를 오래된 순으로 보여 준다. `--skip=1 -n 1` 은 건너뛰고 한 개라 두 번째로 최근 커밋이고, `--skip=100` 은 아무것도 나오지 않는다", "`--skip=100` 은 오류로 끝난다", "`--reverse` 를 먼저 적용한 뒤 `-n` 으로 자른다"]', 1, '가장 오래된 커밋 몇 개를 보려면 `git rev-list --reverse` 결과를 `head` 로 자르는 방식을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 15, '조상인지 묻는 옵션', '`git merge-base` 에서 **앞의 커밋이 뒤 커밋의 조상인지** 종료 코드로 알려 주는 옵션을 채우세요.', '"is"와 "ancestor"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--is-ancestor", "--is-parent", "--contains", "--ancestor-of"]', NULL, '조상이면 0, 아니면 1 입니다.', '[0]', 'git merge-base {0} feat main', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 16, '차이 있으면 실패', '`git diff` 가 **차이가 있으면 종료 코드 1 을 돌려 주게** 하는 옵션을 채우세요.', '"exit"와 "code"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--exit-code", "--status", "--check", "--fail"]', NULL, '출력까지 없애려면 `--quiet` 를 씁니다.', '[0]', 'git diff {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 17, '변경량을 탭으로', '추가 줄, 삭제 줄, 파일 이름을 **탭으로 나눠 한 줄씩** 보여 주는 `git diff` 옵션을 채우세요.', '"num"과 "stat"를 이어요.', NULL, NULL, '[]', 'fill', '["--numstat", "--count", "--lines", "--summary"]', NULL, '바이너리 파일은 줄 수 자리에 `-` 가 나옵니다.', '[0]', 'git diff {0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 18, '변경 요약 한 줄', '`2 files changed, 3 insertions(+)` 같은 **요약 한 줄만** 보여 주는 `git diff` 옵션을 채우세요.', '"short"와 "stat"를 이어요.', NULL, NULL, '[]', 'fill', '["--shortstat", "--short", "--brief", "--oneline"]', NULL, '파일별 목록 없이 전체 합계만 나옵니다.', '[0]', 'git diff {0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 19, '추적 안 되는 파일까지', '저장소 전체의 **새 파일·수정·삭제를 모두 스테이징하는** `git add` 옵션을 채우세요.', '"All"의 머리글자(대문자)예요.', NULL, NULL, '[]', 'fill', '["-A", "-u", "-x", "-r"]', NULL, '`-u` 는 추적 중인 파일의 수정·삭제만 담습니다.', '[0]', 'git add {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 20, 'stash 에 이름 붙여 만들기', '변경을 **이름(`-m`)과 함께 stash 에 넣는** `git stash` 하위 명령을 채우세요.', '"밀어 넣다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["push", "put", "keep", "hold"]', NULL, '추적 안 되는 파일까지 넣으려면 `-u` 를 함께 씁니다.', '[0]', 'git stash {0} -m wip', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 21, '커밋만 취소', '마지막 커밋만 취소하고 **변경은 스테이징된 채로 남기는** `git reset` 옵션을 채우세요.', '"부드러운"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--soft", "--keep-index", "--light", "--safe"]', NULL, '`--hard` 는 파일 변경까지 버립니다.', '[0]', 'git reset {0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 22, '로컬 태그 지우기', '**로컬 태그를 삭제하는** `git tag` 옵션을 채우세요.', '"delete"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-d", "-r", "-x", "-D"]', NULL, '원격 태그는 `git push origin --delete v1` 로 따로 지웁니다.', '[0]', 'git tag {0} v1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 23, '태그 한꺼번에 올리기', '로컬 태그를 **모두 원격에 올리는** `git push` 옵션을 채우세요.', '"tag"의 복수형이에요.', NULL, NULL, '[]', 'fill', '["--tags", "--all-tags", "--with-tags", "--release"]', NULL, '`git push origin main` 만으로는 태그가 올라가지 않습니다.', '[0]', 'git push origin {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 24, '얕게 복제', '최신 커밋만 가져오도록 **이력의 깊이를 제한하는** `git clone` 옵션을 채우세요.', '"depth"는 깊이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--depth", "--shallow", "--limit", "--last"]', NULL, '`git fetch --unshallow` 로 나중에 전체 이력을 받을 수 있습니다.', '[0]', 'git clone {0} 1 URL', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 25, '모든 원격에서 가져오기', '등록된 **모든 원격 저장소에서 한꺼번에 가져오는** `git fetch` 옵션을 채우세요.', '"all"과 같은 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--all", "--every", "--remotes", "--full"]', NULL, '원격에서 지워진 브랜치 정보까지 정리하려면 `--prune` 을 함께 씁니다.', '[0]', 'git fetch {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 26, '브랜치가 이미 들어갔는지 확인하기', '`feat` 브랜치가 `main` 에 이미 포함됐는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '묻기 → 코드 읽기 → 빠진 것 보기 → 합치고 재확인 순서예요.', NULL, NULL, '[]', 'order', '["`git merge-base --is-ancestor feat main` 을 실행한다", "`echo $?` 로 종료 코드를 확인한다(0 이면 포함, 1 이면 미포함)", "1 이면 `git log --oneline main..feat` 로 아직 들어오지 않은 커밋을 본다", "`git merge feat` 로 합친 뒤 같은 명령이 0 을 돌려 주는지 다시 확인한다"]', NULL, '없는 이름을 주면 종료 코드 128 이 나와 "미포함(1)"과 구분됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 27, '변경량을 단계별로 보기', '두 커밋 사이의 변경량을 개요에서 요약까지 보는 순서입니다. 순서에 맞게 놓아 보세요.', '개요 → 상세 → 한 줄 요약 → 차이 여부 순서예요.', NULL, NULL, '[]', 'order', '["`git diff --stat A B` 로 파일별 변경량과 막대를 본다", "`git diff --numstat A B` 로 추가·삭제 줄 수를 탭으로 나눠 본다", "`git diff --shortstat A B` 로 전체 합계 한 줄을 본다", "`git diff --quiet A B` 와 `echo $?` 로 차이가 있는지만 확인한다"]', NULL, '`--quiet` 는 출력 없이 종료 코드(0 또는 1)만 돌려 줍니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 28, '급한 수정 전에 작업 치워 두기', '작업 중인 변경을 stash 로 치우고 급한 수정을 한 뒤 되돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '치우기 → 이동·수정 → 복귀 → 되돌리기 순서예요.', NULL, NULL, '[]', 'order', '["`git stash push -u -m wip` 으로 작업 중인 변경을 치운다(`git status` 가 깨끗해진다)", "`git switch hotfix` 로 다른 브랜치로 이동해 급한 수정을 커밋한다", "`git switch feature` 로 원래 브랜치로 돌아온다", "`git stash pop` 으로 치워 둔 변경을 되돌린다"]', NULL, '`pop` 중 충돌이 나면 stash 가 남으니 `git stash list` 로 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 29, '태그 만들고 올리고 지우기', '릴리스 태그를 만들어 원격에 올리고 확인한 뒤 지우는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 올리기 → 확인 → 지우기 순서예요.', NULL, NULL, '[]', 'order', '["`git tag -a v1 -m \\"release 1\\"` 로 주석 태그를 만든다", "`git push origin v1` 로 태그를 원격에 올린다", "`git ls-remote --tags origin` 으로 원격에 태그가 있는지 확인한다", "`git tag -d v1` 과 `git push origin --delete v1` 로 로컬과 원격 태그를 지운다"]', NULL, '로컬 태그를 지워도 원격 태그는 남아 있어 따로 삭제해야 합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 29);
