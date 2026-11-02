-- Git 세트 196. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set196.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 196, '참조와 변경 목록: for-each-ref, show-ref, update-ref, --name-status, --follow, -S·-G, sparse-checkout', 'Git 참조와 변경 이력을 읽는 명령의 동작을 한 개념씩 반복합니다. for-each-ref 의 출력과 --format, 주석 태그와 가벼운 태그의 오브젝트 종류, --contains·--merged 와 버전 순서 정렬, show-ref 의 출력과 -d, --verify 의 전체 이름 규칙과 종료 코드, update-ref 로 브랜치 옮기기와 옛 값 검사, 체크아웃한 브랜치에 썼을 때의 상태, diff 의 --name-only·--name-status·--diff-filter·--no-renames, 이름이 바뀐 파일의 --follow 이력, 로그의 -S 와 -G 의 차이, commit 의 --allow-empty 와 --date·--author 의 작성·커밋 날짜 구분을 짧은 객관식·빈칸·순서 문제로 익히고, 백업 참조 만들어 실험하기, 이름 바꾼 파일 이력 추적하기, 문자열이 바뀐 커밋 찾기, 필요한 폴더만 체크아웃하기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 196);
UPDATE quest_set SET display_order = 406, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🪢' WHERE id = 196;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 1, 'for-each-ref 기본 출력', '브랜치 `main`·`feat` 와 태그 `v1`(가벼운 태그)·`v2`(주석 태그)가 있는 저장소에서 `git for-each-ref` 는 무엇을 보여 줄까요?', '한 줄에 참조 하나예요.', NULL, NULL, '[]', 'choice', '["현재 브랜치의 이름 하나만 보여 준다", "브랜치만 보여 주고 태그는 `git tag` 로만 볼 수 있다", "참조마다 한 줄씩 해시, 오브젝트 종류, 참조 전체 이름(`refs/heads/main`, `refs/tags/v1` 등)을 보여 준다. `v2` 의 종류는 `tag` 이고 나머지는 `commit` 이다", "참조 이름 없이 해시만 한 줄씩 보여 준다"]', 2, '`refs/heads` 같은 접두어를 뒤에 붙이면 그 아래 참조만 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 2, 'for-each-ref 출력 모양 바꾸기', '`git for-each-ref --format=''%(refname:short) %(objecttype) %(subject)'' refs/heads` 는 어떻게 나올까요?', '브랜치 이름, 종류, 커밋 제목이에요.', NULL, NULL, '[]', 'choice', '["`--format` 은 쓸 수 없어 오류가 난다", "`refs/heads` 아래 참조만 `이름 종류 제목` 모양으로 `feat commit c2`, `main commit c3` 처럼 한 줄씩 보여 준다", "태그까지 모두 보여 주고 `refs/heads` 는 무시한다", "해시만 보여 주고 이름은 숨긴다"]', 1, '`%(refname:short)` 는 `refs/heads/` 접두어를 뗀 이름입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 3, '주석 태그와 가벼운 태그 구분', '`git for-each-ref --format=''%(refname:short) %(objecttype)'' refs/tags` 에서 가벼운 태그 `v1` 과 주석 태그 `v2` 는 어떻게 다르게 나올까요?', '주석 태그는 태그 오브젝트를 따로 가져요.', NULL, NULL, '[]', 'choice', '["`v1 commit`, `v2 tag` 로 나온다. 주석 태그는 태그 오브젝트를 따로 가지고, 가벼운 태그는 커밋을 바로 가리킨다", "둘 다 `tag` 로 나온다", "둘 다 `commit` 으로 나온다", "`v1` 은 `tag`, `v2` 는 `commit` 으로 나온다"]', 0, '`%(*objecttype)` 은 주석 태그가 가리키는 대상의 종류(`commit`)를 보여 주고 가벼운 태그는 빈 값입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 4, '브랜치를 조건으로 거르기', '`main` 은 `feat` 보다 커밋이 하나 앞서 있습니다(`feat` 는 `main~1` 과 같은 커밋). `git for-each-ref --contains main~1 --format=''%(refname:short)'' refs/heads` 와 `--merged feat` 는 각각 무엇을 보여 줄까요?', '포함하는 브랜치와 포함되는 브랜치를 봐요.', NULL, NULL, '[]', 'choice', '["`--contains main~1` 은 `main` 만, `--merged feat` 는 `feat` 와 `main` 을 보여 준다", "둘 다 `feat` 와 `main` 을 보여 준다", "둘 다 아무것도 보여 주지 않는다", "`--contains main~1` 은 그 커밋을 포함한 `feat` 와 `main` 을, `--merged feat` 는 `feat` 에 이미 포함된 `feat` 만 보여 준다"]', 3, '`--no-merged 브랜치` 는 반대로 그 브랜치에 포함되지 않은 참조를 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 5, '버전 이름 정렬', '태그 `v1.2`, `v1.9`, `v1.10` 이 있을 때 `git tag -l ''v*''` 의 순서와 `git tag --sort=version:refname -l ''v*''` 의 순서는 어떻게 다를까요?', '글자 순서와 숫자 크기 순서예요.', NULL, NULL, '[]', 'choice', '["둘 다 `v1.2`, `v1.9`, `v1.10` 순서이다", "기본은 만든 시각 순서이고 `--sort` 는 글자 순서이다", "기본은 글자 순서라 `v1.10`, `v1.2`, `v1.9` 로, `--sort=version:refname` 은 숫자 크기를 반영해 `v1.2`, `v1.9`, `v1.10` 으로 나온다", "`--sort=version:refname` 은 `v1.10`, `v1.9`, `v1.2` 순서로 나온다"]', 2, '`git for-each-ref --sort=-version:refname` 처럼 앞에 `-` 를 붙이면 큰 버전이 먼저 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 6, 'show-ref 출력과 -d', '`git show-ref --tags` 와 `git show-ref -d --tags` 는 주석 태그 `v2` 에서 어떻게 다를까요?', '가리키는 커밋까지 보여 주는 옵션이에요.', NULL, NULL, '[]', 'choice', '["`-d` 는 태그를 지우는 옵션이다", "`--tags` 는 태그마다 `해시 refs/tags/이름` 한 줄이고, `-d` 를 더하면 주석 태그에 `refs/tags/v2^{}` 줄이 하나 더 생겨 가리키는 커밋의 해시를 보여 준다", "`-d` 를 붙이면 가벼운 태그 `v1` 에도 `^{}` 줄이 생긴다", "`--tags` 는 브랜치까지 함께 보여 준다"]', 1, '`git show-ref` 의 출력은 `for-each-ref` 와 달리 오브젝트 종류 없이 해시와 이름만 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 7, 'show-ref --verify 의 이름 규칙', '브랜치 `main` 이 있을 때 `git show-ref --verify main` 은 어떻게 될까요? `git show-ref --verify refs/heads/main` 은요?', '전체 이름이 필요한지 봐요.', NULL, NULL, '[]', 'choice', '["앞은 `fatal: ''main'' - not a valid ref` 오류와 종료 코드 128 이고, 뒤는 해시와 이름을 출력하며 종료 코드 0 이다. `--verify` 는 전체 이름이 필요하다", "둘 다 `main` 브랜치를 찾아 출력한다", "앞은 종료 코드 1 로 조용히 끝난다", "뒤는 `main` 을 먼저 찾고 없을 때만 `refs/heads/main` 을 찾는다"]', 0, '`--verify -q refs/heads/nope` 처럼 없는 전체 이름은 출력 없이 종료 코드 1 이라 `if` 조건에 쓸 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 8, 'update-ref 로 브랜치 옮기기', '`main` 에서 `git update-ref refs/heads/x HEAD~1` 을 하면 무엇이 일어날까요? 이어서 `x` 가 `HEAD` 가 아닌 곳을 가리킬 때 `git update-ref refs/heads/x HEAD~2 HEAD` 를 하면요?', '세 번째 인자는 예상하는 옛 값이에요.', NULL, NULL, '[]', 'choice', '["앞은 `x` 를 만들면서 `x` 로 체크아웃한다", "뒤는 옛 값이 달라도 `x` 를 `HEAD~2` 로 옮긴다", "앞은 `main` 을 `HEAD~1` 로 되돌린다", "앞은 체크아웃 없이 브랜치 `x` 를 `HEAD~1` 에 만들고 현재 브랜치 `main` 은 그대로다. 뒤는 옛 값이 맞지 않으면 `cannot lock ref` 오류(종료 코드 128)로 끝나고 `x` 는 바뀌지 않는다"]', 3, '옛 값을 함께 주면 그 사이 다른 곳에서 바뀌지 않았을 때만 갱신합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 9, '체크아웃한 브랜치에 update-ref', '`main` 에 체크아웃한 상태에서 `git update-ref refs/heads/main HEAD~1` 을 하면 작업 폴더와 스테이징은 어떻게 될까요?', '브랜치 이름이 가리키는 곳만 바뀌어요.', NULL, NULL, '[]', 'choice', '["작업 폴더와 스테이징도 `HEAD~1` 시점으로 바뀌어 깨끗하다", "체크아웃한 브랜치에는 `update-ref` 가 거부된다", "브랜치 `main` 만 `HEAD~1` 로 옮겨지고 작업 폴더와 스테이징은 그대로라, 되돌려진 커밋의 변경이 스테이징된 상태(`M  파일`)로 보인다", "`main` 은 그대로이고 새 브랜치만 생긴다"]', 2, '`git reset --soft HEAD~1` 과 같은 상태이고, 작업 폴더와 스테이징까지 맞추려면 `git reset --hard` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 10, 'diff --name-status 읽기', '내용이 3줄인 `a.txt` 를 `git mv` 로 `b.txt` 로 바꾸고 한 줄을 덧붙인 뒤 `n.txt` 를 새로 추가해 커밋했습니다. `git diff --name-status HEAD~1 HEAD` 는 어떻게 나올까요? `--no-renames` 를 붙이면요?', '이름 변경은 R 로 시작해요.', NULL, NULL, '[]', 'choice', '["`M a.txt` 와 `A b.txt` 가 나온다", "`R082 a.txt b.txt`(`R` 뒤의 숫자는 유사도 퍼센트)와 `A n.txt` 가 나오고, `--no-renames` 를 붙이면 `D a.txt`, `A b.txt`, `A n.txt` 로 나뉜다", "`D a.txt` 와 `A b.txt` 만 나오고 `--no-renames` 가 `R` 로 합쳐 준다", "`n.txt` 는 `M n.txt` 로 나온다"]', 1, '`git diff --name-only` 는 상태 문자 없이 `b.txt`, `n.txt` 같은 파일 이름만 보여 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 11, '이름이 바뀐 파일의 이력', '커밋 3개에 걸쳐 만든 `a.txt` 를 네 번째 커밋에서 `b.txt` 로 바꿨습니다. `git log --oneline -- b.txt` 와 `git log --oneline --follow -- b.txt` 는 각각 몇 개의 커밋을 보여 줄까요?', '이름이 바뀌기 전 이력까지 따라가는 옵션이에요.', NULL, NULL, '[]', 'choice', '["앞은 이름이 바뀐 커밋 1개만, `--follow` 를 붙이면 이전 이름 `a.txt` 때의 커밋까지 4개를 보여 준다", "둘 다 4개를 보여 준다", "앞은 4개, `--follow` 는 1개를 보여 준다", "`--follow` 는 삭제된 파일의 이력만 보여 준다"]', 0, '`--name-status` 를 함께 쓰면 이름이 바뀐 커밋에 `R082 a.txt b.txt` 같은 줄이 보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 12, '-S 와 -G 의 차이', '`g.txt` 에서 `g2` 커밋은 `beta` 줄을 추가했고 `g3` 커밋은 그 줄을 `beta v2` 로 고쳤습니다. `git log --oneline -S beta -- g.txt` 와 `-G beta` 는 각각 어떤 커밋을 보여 줄까요?', '횟수가 변했는지, 줄이 바뀌었는지 봐요.', NULL, NULL, '[]', 'choice', '["둘 다 `g2` 만 보여 준다", "`-S` 는 `g3` 과 `g2`, `-G` 는 `g2` 만 보여 준다", "`-S` 는 커밋 메시지에서 `beta` 를 찾고 `-G` 는 파일 이름에서 찾는다", "`-S beta` 는 `beta` 가 나오는 횟수가 변한 `g2` 만, `-G beta` 는 `beta` 가 든 줄이 바뀐 `g3` 과 `g2` 를 보여 준다"]', 3, '커밋 메시지에서 찾으려면 `--grep=문자열` 을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 13, '빈 커밋 만들기', '변경이 없는 깨끗한 상태에서 `git commit -m try` 와 `git commit --allow-empty -m trigger` 는 각각 어떻게 될까요?', '변경이 없어도 커밋하려면 옵션이 필요해요.', NULL, NULL, '[]', 'choice', '["앞도 빈 커밋을 만든다", "뒤도 `nothing to commit` 으로 끝난다", "앞은 `nothing to commit` 안내와 함께 종료 코드 1 이고 커밋이 생기지 않는다. 뒤는 파일 변경 없이 부모와 같은 트리를 가진 커밋이 하나 생긴다", "뒤는 직전 커밋을 덮어쓴다"]', 2, '메시지를 비우는 것은 별개라 `-m ''''` 로 커밋하려면 `--allow-empty-message` 도 필요합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 14, '작성 날짜와 커밋 날짜', '`git commit --allow-empty -m dated --date=2020-01-02T03:04:05 --author=''Other <o@x.test>''` 로 커밋한 뒤 `git log -1 --date=iso --format=''%an|%cn|%ad|%cd''` 를 하면 어떻게 나올까요?', '작성한 사람·날짜와 커밋한 사람·날짜가 따로 있어요.', NULL, NULL, '[]', 'choice', '["`--date` 가 커밋 날짜를 바꿔 `%cd` 도 2020년이 된다", "작성자 `%an` 은 `Other`, 커밋한 사람 `%cn` 은 설정된 사용자이고, 작성 날짜 `%ad` 는 `2020-01-02 03:04:05` 로 시작하지만 커밋 날짜 `%cd` 는 지금 시각이다", "`--author` 를 쓰면 커밋한 사람 `%cn` 도 `Other` 가 된다", "`--date` 와 `--author` 는 `git commit` 에서 쓸 수 없다"]', 1, '`git log --since`, `--until` 은 커밋 날짜 기준이라, 이 커밋은 `--since=2020-01-01 --until=2020-12-31` 범위에 나오지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 15, '브랜치 이름만 출력', '`refs/heads/` 접두어를 뗀 브랜치 이름만 출력하도록 `%( )` 안의 이름을 채우세요.', '"참조 이름"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["refname", "name", "ref", "branch"]', NULL, '`feat`, `main` 처럼 접두어 없이 나옵니다.', '[0]', 'git for-each-ref --format=''%({0}:short)'' refs/heads', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 16, '버전 순서로 태그 정렬', '태그를 숫자 크기를 반영한 버전 순서로 나열하도록 정렬 기준을 채우세요.', '"version" 다음에 "refname" 이에요.', NULL, NULL, '[]', 'fill', '["version:refname", "number", "semver", "natural"]', NULL, '`v1.2`, `v1.9`, `v1.10` 순서로 나옵니다.', '[0]', 'git tag --sort={0} -l ''v*''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 17, '주석 태그의 대상까지 보기', '주석 태그가 가리키는 커밋의 해시까지 보여 주는 `git show-ref` 옵션을 채우세요.', '"dereference" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-d", "-a", "-r", "-x"]', NULL, '`refs/tags/v2^{}` 줄이 더 나옵니다.', '[0]', 'git show-ref {0} --tags', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 18, '참조 확인을 조용히', '없는 참조여도 메시지 없이 종료 코드로만 알려 주는 `git show-ref` 옵션을 채우세요.', '"quiet" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-q", "-v", "-n", "-f"]', NULL, '출력 없이 종료 코드 1 로 끝납니다.', '[0]', 'git show-ref --verify {0} refs/heads/nope', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 19, '참조 삭제', '`update-ref` 로 `refs/heads/x` 참조를 지우는 옵션을 채우세요.', '"delete" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-d", "-D", "-r", "--rm"]', NULL, '삭제한 뒤 `git branch --list x` 는 아무것도 보여 주지 않습니다.', '[0]', 'git update-ref {0} refs/heads/x', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 20, 'reflog 에 이유 남기기', '참조를 옮길 때 reflog 에 남길 메시지를 주는 `update-ref` 옵션을 채우세요.', '"message" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-m", "-c", "-l", "--note"]', NULL, '`git reflog show x` 에 `x@{0}: moved by hand` 가 남습니다.', '[0]', 'git update-ref {0} ''moved by hand'' refs/heads/x HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 21, '변경 상태와 이름 보기', '파일 이름과 함께 `A`, `M`, `D`, `R` 같은 상태 문자를 보여 주는 `git diff` 옵션을 채우세요.', '"이름"과 "상태"를 합친 이름이에요.', NULL, NULL, '[]', 'fill', '["--name-status", "--name-type", "--status", "--names-with-state"]', NULL, '`A n.txt` 처럼 상태 문자와 파일 이름이 나옵니다.', '[0]', 'git diff {0} HEAD~1 HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 22, '추가된 파일만 보기', '`a.txt` 를 `b.txt` 로 바꾸고 `n.txt` 를 새로 추가한 커밋에서 새로 추가된 파일의 이름만 보도록 상태 문자를 채우세요.', '"Added" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["A", "D", "M", "R"]', NULL, '`n.txt` 만 나옵니다. 이름이 바뀐 `b.txt` 는 `R` 로 따로 분류됩니다.', '[0]', 'git diff --name-only --diff-filter={0} HEAD~1 HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 23, '이름이 바뀌기 전 이력까지', '파일 이름이 바뀌기 전의 커밋까지 따라가며 이력을 보는 `git log` 옵션을 채우세요.', '"따라가다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--follow", "--rename", "--renames-only", "--track"]', NULL, '`--` 뒤에 경로를 두어 경로임을 분명히 합니다.', '[0]', 'git log --oneline {0} -- b.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 24, '정규식에 맞는 줄이 바뀐 커밋', '정규식 `v[0-9]` 에 맞는 줄이 추가되거나 지워진 커밋을 찾는 `git log` 옵션을 채우세요.', '"grep" 의 대문자 G 예요.', NULL, NULL, '[]', 'fill', '["-G", "-S", "--grep", "-L"]', NULL, '`beta v2` 줄을 만든 `g3` 만 나옵니다. `--grep` 은 커밋 메시지를 검색합니다.', '[0]', 'git log --oneline {0} ''v[0-9]'' -- g.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 25, '변경 없이 커밋', '파일 변경이 없어도 커밋을 만들게 하는 `git commit` 옵션을 채우세요.', '"빈 것을 허용"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--allow-empty", "--empty", "--force", "--no-verify"]', NULL, '부모와 같은 트리를 가진 커밋이 생깁니다.', '[0]', 'git commit {0} -m trigger', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 26, '백업 참조를 만들어 두고 실험하기', '되돌릴 수 있게 백업 참조를 만들고 실험한 뒤 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '백업 → 실험 → 복구 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`git update-ref refs/backup/main HEAD` 로 현재 위치에 백업 참조를 만든다", "`git reset --hard HEAD~1` 로 한 커밋 되돌려 실험한다", "`git reset --hard refs/backup/main` 으로 백업 위치로 돌아온다", "`git update-ref -d refs/backup/main` 으로 백업 참조를 지운다"]', NULL, '`refs/backup/` 처럼 직접 만든 참조는 `git branch` 목록에 나오지 않고 `git for-each-ref refs/backup` 으로 봅니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 27, '이름 바꾼 파일의 이력 추적하기', '파일 이름을 바꾸고 이전 이름 때의 이력까지 따라가 보는 순서입니다. 순서에 맞게 놓아 보세요.', '바꾸기 → 상태 확인 → 일반 로그 → follow 로그 순서예요.', NULL, NULL, '[]', 'order', '["`git mv a.txt b.txt` 로 이름을 바꾸고 커밋한다", "`git diff --name-status HEAD~1 HEAD` 로 `R` 로 시작하는 이름 변경 줄을 확인한다", "`git log --oneline -- b.txt` 로 이름이 바뀐 커밋만 보이는 것을 확인한다", "`git log --oneline --follow -- b.txt` 로 이전 이름 때의 커밋까지 모두 본다"]', NULL, '`--follow` 가 없으면 이름이 바뀐 시점에서 이력이 끊겨 보입니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 28, '문자열이 바뀐 커밋 찾기', '파일에서 문자열이 바뀐 커밋을 찾아 내용을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '좁게 → 넓게 → 내용 → 한 커밋 순서예요.', NULL, NULL, '[]', 'order', '["`git log --oneline -S beta -- g.txt` 로 `beta` 의 개수가 바뀐 커밋을 찾는다", "`git log --oneline -G beta -- g.txt` 로 `beta` 가 든 줄이 바뀐 커밋까지 넓혀 찾는다", "`git log -p -G beta -- g.txt` 로 줄 단위로 바뀐 내용을 본다", "`git show 해시 -- g.txt` 로 찾은 커밋 하나의 변경만 자세히 본다"]', NULL, '`-S` 는 개수가 변한 커밋, `-G` 는 정규식에 맞는 줄이 바뀐 커밋을 찾습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 196, 29, '필요한 폴더만 체크아웃하기', '큰 저장소에서 일부 폴더만 작업 폴더에 두었다가 모두 되돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '정하기 → 확인 → 더하기 → 해제 순서예요.', NULL, NULL, '[]', 'order', '["`git sparse-checkout set d1` 로 `d1` 폴더만 작업 폴더에 둔다", "`git sparse-checkout list` 로 지금 포함된 폴더를 확인한다", "`git sparse-checkout add d2` 로 `d2` 폴더를 더 가져온다", "`git sparse-checkout disable` 로 제한을 풀고 모든 파일을 다시 가져온다"]', NULL, '기본 방식에서는 저장소 최상위의 파일(`b.txt` 등)은 항상 작업 폴더에 남습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 196 AND order_index = 29);
