-- Git 세트 200. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set200.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 200, 'Git 로그·diff 읽기: --is-ancestor, --exit-code, --numstat, --all-match, --ancestry-path, blame -w', 'Git 이력과 변경을 읽는 명령과 옵션의 동작을 한 개념씩 반복합니다. merge-base --is-ancestor 의 종료 코드, diff 의 --exit-code 와 --quiet, --stat·--numstat·--shortstat 의 차이, format 과 tformat 의 줄바꿈, 여러 --grep 의 OR 과 --all-match·--invert-grep·-i, --author 와 --committer, tag·branch 의 --points-at, --ancestry-path, --left-right --cherry-pick 과 git cherry, ^@ 와 ^!, 병합 커밋의 show -m 과 --first-parent, blame 의 -w·--ignore-rev·ignoreRevsFile, git merge-file 의 종료 코드와 --ours·--theirs·--union, -n·--skip·--reverse 의 적용 순서를 짧은 객관식·빈칸·순서 문제로 익히고, 브랜치가 이미 들어갔는지 확인하기, 변경량을 단계별로 보기, blame 에서 들여쓰기 커밋 건너뛰기, cherry-pick 한 커밋 구분하기의 순서를 연습합니다.', 'quiz', 'Git'
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
SELECT 200, 5, '--grep 의 여러 조건', '`git log --grep=A --grep=B` 는 어떤 커밋을 보여 줄까요? `--all-match` 를 붙이면요? `--invert-grep` 은요? `--grep=FEAT` 는 소문자 `feat` 제목과 맞을까요?', '여러 `--grep` 은 기본이 "또는"이에요.', NULL, NULL, '[]', 'choice', '["`--grep` 을 여럿 쓰면 모두 맞아야 보인다", "`--invert-grep` 은 맞는 커밋만 더 깊게 보여 준다", "`A` 나 `B` 중 하나라도 맞는 커밋(OR)을 보여 주고, `--all-match` 를 붙이면 둘 다 맞는 커밋만, `--invert-grep` 은 맞지 않는 커밋만 보여 준다. `--grep` 은 대소문자를 구분해서 `FEAT` 는 맞지 않고 `-i` 를 붙이면 맞는다", "`--grep` 은 대소문자를 구분하지 않는다"]', 2, '`-i` 는 `--regexp-ignore-case` 의 짧은 이름입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 6, '--author 와 --committer', '작성자가 Alice 인 커밋을 다른 사람 Carol 이 `git commit --amend` 로 다시 만들었습니다. `git log --author=Carol` 과 `--committer=Carol` 은 각각 이 커밋을 찾을까요?', '작성한 사람과 커밋을 만든 사람은 따로 기록돼요.', NULL, NULL, '[]', 'choice', '["둘 다 이 커밋을 찾는다", "`--author=Carol` 은 찾지 못하고(작성자는 그대로 Alice) `--committer=Carol` 은 찾는다. 작성자(author)는 원래 변경을 쓴 사람, 커밋터(committer)는 이 커밋을 마지막으로 만든 사람이다", "`--author=Carol` 만 이 커밋을 찾는다", "둘 다 이 커밋을 찾지 못한다"]', 1, '`git log --format=''%an/%cn''` 으로 작성자와 커밋터 이름을 함께 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 7, '--points-at', '`git tag --points-at feat` 과 `git branch --points-at feat` 은 무엇을 보여 줄까요? 태그가 `feat` 보다 한 커밋 앞을 가리키면 `--points-at feat` 에 나올까요? 그런 태그를 찾으려면요?', '"정확히 그 커밋을" 가리키는 것만 찾아요.', NULL, NULL, '[]', 'choice', '["정확히 `feat` 커밋을 가리키는 태그(또는 브랜치)만 보여 주고 한 커밋 앞을 가리키는 태그는 나오지 않는다. 그 커밋을 조상으로 포함하는 태그는 `git tag --contains <커밋>` 으로 찾는다", "`feat` 에서 도달 가능한 모든 태그를 보여 준다", "한 커밋 앞 태그도 함께 보여 준다", "`--points-at` 은 태그에만 쓸 수 있고 브랜치에는 쓸 수 없다"]', 0, '`git branch --points-at <커밋>` 으로 브랜치도 같은 방식으로 찾을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 8, '--ancestry-path', '`c1 - c2` 에서 `feat` 가 `f1 - f2` 로 갈라지고 `main` 에는 `m1` 이 따로 있으며 `feat` 를 병합한 커밋 `M` 이 있습니다. `git log feat~1..main` 과 `git log --ancestry-path feat~1..main` 은 각각 무엇을 보여 줄까요?', '`feat~1` 은 `f1` 이에요.', NULL, NULL, '[]', 'choice', '["`--ancestry-path` 를 붙여도 결과가 같다", "`--ancestry-path` 는 `f1` 의 조상인 `c2`, `c1` 만 보여 준다", "`--ancestry-path` 는 `m1` 만 보여 준다", "앞의 것은 `M`, `m1`, `f2` 이고, `--ancestry-path` 를 붙이면 `f1` 의 후손(`f1` 에서 이어진 경로)인 `M` 과 `f2` 만 남고 `m1` 은 빠진다"]', 3, '특정 변경이 어떤 경로로 `main` 에 들어왔는지 좁혀 볼 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 9, '--left-right --cherry-pick', '`rel` 에서 `feat` 의 `f1`, `f2` 를 `cherry-pick -x` 로 가져오고 `r1` 을 더했습니다. `main` 은 `feat` 를 병합했고 `m1` 이 따로 있습니다. `git log --left-right --cherry-pick main...rel` 은 무엇을 보여 줄까요?', '같은 변경의 커밋은 빼요.', NULL, NULL, '[]', 'choice', '["`f1`, `f2` 가 양쪽에 모두 나온다", "`r1` 만 보여 준다", "병합 커밋과 `m1` 은 왼쪽(`<`), `r1` 은 오른쪽(`>`)으로 보이고 양쪽에 같은 변경으로 있는 `f1`, `f2` 는 빠진다. `--cherry-pick` 이 없으면 `f1`, `f2` 가 양쪽에 모두 나온다. `git cherry -v main rel` 로 보면 `f1`, `f2` 는 `-`, `r1` 은 `+` 이다", "`m1` 과 `r1` 만 보여 준다"]', 2, '`...` 는 두 쪽에서 한쪽에만 있는 커밋을, `--left-right` 는 어느 쪽인지를 `<` 와 `>` 로 알려 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 10, '부모를 고르는 ^@ 와 ^!', '병합 커밋 `main` 에서 `main^`, `main^2`, `git log main^@`, `git log main^!` 은 각각 무엇일까요?', '`^!` 는 "그 커밋만"이에요.', NULL, NULL, '[]', 'choice', '["`main^@` 는 첫 번째 부모 하나만 가리킨다", "`main^` 은 첫 번째 부모, `main^2` 는 두 번째 부모이다. `main^@` 는 모든 부모를 한꺼번에 가리켜 두 부모에서 이어진 기록이 모두 나오고, `main^!` 는 그 커밋 하나만(부모들은 제외) 나온다", "`main^!` 는 그 커밋과 모든 조상을 보여 준다", "`main^2` 는 첫 번째 부모이다"]', 1, '`git rev-parse main^@` 는 부모 해시를 한 줄씩 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 11, '병합 커밋의 diff', '충돌 없이 `--no-ff` 로 병합한 커밋에서 `git show main`, `git show -m main`, `git show --first-parent main`, `git log -p -1 main` 은 각각 어떻게 보일까요?', '병합 커밋은 부모가 둘이라 기준을 정해야 해요.', NULL, NULL, '[]', 'choice', '["깨끗한 병합은 기본 `git show` 가 변경 내용을 보여 주지 않고(결합 diff 는 충돌 해결로 달라진 부분만 보임) `git log -p` 도 제목만 나온다. `-m` 은 부모마다 따로 diff 를 보여 주고(첫 부모 기준과 둘째 부모 기준), `--first-parent` 는 첫 번째 부모 기준 diff 만 보여 준다", "기본 `git show` 가 두 부모의 변경을 모두 합쳐 보여 준다", "`-m` 은 병합 커밋의 diff 를 숨긴다", "`--first-parent` 는 두 번째 부모 기준 diff 를 보여 준다"]', 0, '병합으로 들어온 변경을 보려면 `git show -m` 이나 `git diff main^ main` 처럼 기준 부모를 정해 비교합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 12, 'blame 에서 서식 커밋 무시하기', '들여쓰기만 바꾼 커밋 `H` 때문에 `git blame` 이 그 줄의 작성 커밋을 `H` 로 보여 줍니다. `git blame -w`, `--ignore-rev H`, `--ignore-revs-file`, `blame.ignoreRevsFile` 설정은 각각 어떻게 도울까요?', '공백만 바뀐 줄을 원래 커밋으로 돌려요.', NULL, NULL, '[]', 'choice', '["`-w` 는 서식 커밋을 이력에서 지운다", "`--ignore-rev` 는 해당 줄을 blame 결과에서 숨긴다", "무시 목록 파일에는 주석을 쓸 수 없다", "`-w` 는 공백 차이를 무시하고, `--ignore-rev H` 는 그 커밋을 건너뛰고, `--ignore-revs-file 파일` 은 파일에 적힌 커밋을 모두 건너뛴다. `blame.ignoreRevsFile` 설정에 같은 파일을 지정하면 매번 옵션을 쓰지 않아도 되고, 파일에는 `#` 주석도 쓸 수 있다. 없는 커밋을 주면 `cannot find revision ... to ignore` 오류가 난다"]', 3, '서식 일괄 변경 커밋은 `.git-blame-ignore-revs` 같은 파일에 모아 두는 방식이 널리 쓰입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 13, 'git merge-file', '공통 조상 `base`, 내 것 `ours`, 상대 것 `theirs` 파일이 있습니다. `git merge-file ours base theirs` 의 결과는 어디에 쓰일까요? 종료 코드는요? 서로 인접한 줄을 각각 바꾸면요?', '세 파일을 3-way 로 합쳐요.', NULL, NULL, '[]', 'choice', '["결과는 `base` 파일에 쓰인다", "충돌이 있어도 종료 코드는 항상 0 이다", "결과는 `ours` 파일에 덮어쓰이고(`-p` 를 주면 표준 출력), 종료 코드는 충돌 개수(없으면 0)이다. 떨어진 줄을 각각 바꾸면 자동으로 합쳐지고 인접한 줄이나 같은 줄을 바꾸면 충돌 표시가 남는다. `--ours`, `--theirs`, `--union` 은 충돌을 자동으로 해결해 종료 코드가 0 이다", "인접한 줄의 변경은 자동으로 합쳐진다"]', 2, '`-L` 을 세 번 주면 충돌 표시의 이름을 `mine`, `orig`, `other` 처럼 바꿀 수 있습니다.', NULL, NULL, NULL, NULL
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
SELECT 200, 19, '모든 조건에 일치', '`git log` 에서 여러 `--grep` 이 **모두 맞는 커밋만** 보이게 하는 옵션을 채우세요.', '"all"과 "match"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--all-match", "--and", "--both", "--match-all"]', NULL, '붙이지 않으면 하나만 맞아도 보입니다.', '[0]', 'git log --grep=fix --grep=login {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 20, '맞지 않는 커밋만', '`--grep` 에 **맞지 않는 커밋만** 보여 주는 `git log` 옵션을 채우세요.', '"invert"와 "grep"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--invert-grep", "--not-grep", "--exclude-grep", "--no-grep"]', NULL, '`wip` 가 들어간 커밋을 빼고 볼 때 씁니다.', '[0]', 'git log {0} --grep=wip', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 21, '커밋을 만든 사람', '작성자가 아니라 **커밋을 만든(적용한) 사람**으로 거르는 `git log` 옵션 이름을 채우세요.', '"commit"에 사람을 뜻하는 "-er"를 붙여요.', NULL, NULL, '[]', 'fill', '["committer", "author", "maker", "pusher"]', NULL, '`--author` 는 원래 변경을 쓴 사람입니다.', '[0]', 'git log --{0}=Carol', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 22, '정확히 그 커밋', '특정 커밋을 **정확히 가리키는** 태그만 보여 주는 `git tag` 옵션을 채우세요.', '"points"와 "at"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--points-at", "--at", "--commit", "--target"]', NULL, '`git branch` 에서도 같은 옵션을 씁니다.', '[0]', 'git tag {0} HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 23, '후손만 보기', '`A..B` 범위에서 **A 의 후손 경로에 있는 커밋만** 남기는 `git log` 옵션을 채우세요.', '"ancestry"와 "path"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--ancestry-path", "--first-parent", "--descendants", "--only-after"]', NULL, '`A` 와 무관하게 `main` 에만 있던 커밋은 빠집니다.', '[0]', 'git log {0} feat~1..main', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 24, 'blame 에서 커밋 건너뛰기', '`git blame` 에서 **지정한 커밋을 건너뛰고** 그 이전 작성자를 찾는 옵션을 채우세요.', '"ignore"와 "rev"를 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["--ignore-rev", "--skip-rev", "--ignore-commit", "--exclude-rev"]', NULL, '여러 커밋은 `--ignore-revs-file` 로 모읍니다.', '[0]', 'git blame {0} abc1234 file.c', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 25, '세 파일 합치기', '공통 조상, 내 것, 상대 것 **세 파일을 3-way 로 합치는** `git` 하위 명령을 채우세요.', '"merge"와 "file"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["merge-file", "merge-three", "merge-files", "three-way"]', NULL, '종료 코드는 충돌 개수입니다.', '[0]', 'git {0} -p ours base theirs', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 26, '브랜치가 이미 들어갔는지 확인하기', '`feat` 브랜치가 `main` 에 이미 포함됐는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '묻기 → 코드 읽기 → 빠진 것 보기 → 합치고 재확인 순서예요.', NULL, NULL, '[]', 'order', '["`git merge-base --is-ancestor feat main` 을 실행한다", "`echo $?` 로 종료 코드를 확인한다(0 이면 포함, 1 이면 미포함)", "1 이면 `git log --oneline main..feat` 로 아직 들어오지 않은 커밋을 본다", "`git merge feat` 로 합친 뒤 같은 명령이 0 을 돌려 주는지 다시 확인한다"]', NULL, '없는 이름을 주면 종료 코드 128 이 나와 "미포함(1)"과 구분됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 27, '변경량을 단계별로 보기', '두 커밋 사이의 변경량을 개요에서 요약까지 보는 순서입니다. 순서에 맞게 놓아 보세요.', '개요 → 상세 → 한 줄 요약 → 차이 여부 순서예요.', NULL, NULL, '[]', 'order', '["`git diff --stat A B` 로 파일별 변경량과 막대를 본다", "`git diff --numstat A B` 로 추가·삭제 줄 수를 탭으로 나눠 본다", "`git diff --shortstat A B` 로 전체 합계 한 줄을 본다", "`git diff --quiet A B` 와 `echo $?` 로 차이가 있는지만 확인한다"]', NULL, '`--quiet` 는 출력 없이 종료 코드(0 또는 1)만 돌려 줍니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 28, 'blame 에서 들여쓰기 커밋 건너뛰기', '서식만 바꾼 커밋 때문에 `git blame` 이 엉뚱한 커밋을 가리킬 때 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '증상 → 원인 찾기 → 무시 목록 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git blame s.c` 에서 들여쓰기만 바꾼 커밋이 그 줄의 작성 커밋으로 나오는 것을 확인한다", "`git log -- s.c` 로 서식만 바꾼 커밋의 해시를 찾는다", "해시를 `.git-blame-ignore-revs` 파일에 적고 `git config blame.ignoreRevsFile .git-blame-ignore-revs` 로 지정한다", "`git blame s.c` 가 원래 줄을 쓴 커밋을 가리키는지 다시 확인한다"]', NULL, '한 번만 시험하려면 `--ignore-rev <해시>` 옵션을 쓰면 됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 200, 29, 'cherry-pick 한 커밋 구분하기', '`cherry-pick` 한 커밋과 아직 안 옮긴 커밋을 구분하는 순서입니다. 순서에 맞게 놓아 보세요.', '옮기기 → 비교 → 표시 읽기 → 판단 순서예요.', NULL, NULL, '[]', 'order', '["`rel` 에서 `git cherry-pick -x f1 f2` 로 `feat` 의 커밋을 옮긴다", "`git log --left-right --cherry-pick main...rel` 로 같은 변경의 커밋이 빠진 비교 결과를 본다", "`git cherry -v main rel` 로 각 커밋 앞의 `-`(이미 있음)와 `+`(없음)를 확인한다", "`+` 가 붙은 커밋만 `main` 에 반영할지 판단한다"]', NULL, '`-x` 를 쓰면 메시지에 `(cherry picked from commit ...)` 가 남습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 200 AND order_index = 29);
