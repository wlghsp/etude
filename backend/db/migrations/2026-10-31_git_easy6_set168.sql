-- Git 세트 168. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set168.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 168, 'Git 객체와 이력 주소 읽기, 부분 스테이징, 브랜치 정리 한 줄씩', 'Git 이 이력을 저장하고 가리키는 방식을 한 개념씩 반복합니다. commit·tree·blob 객체와 cat-file, 커밋 객체의 tree·parent, 같은 내용은 같은 해시, ls-files 와 ls-tree, HEAD~1·HEAD^·HEAD^2 의 차이와 병합 커밋의 부모, describe 읽기, 경량 태그와 주석 태그, add -p 로 덩어리만 스테이징, branch --merged·--no-merged, switch - 와 오류 메시지, branch -vv 의 업스트림 표시, restore --source 와 --staged, status 의 두 글자 읽기를 짧은 객관식·빈칸·순서 문제로 익히고, 커밋 구조 따라가기, 한 파일의 변경을 나눠 커밋하기, 병합된 브랜치 정리하기, 예전 파일 상태 되살리기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 168);
UPDATE quest_set SET display_order = 405, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🧬' WHERE id = 168;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 1, 'Git 이 저장하는 세 가지', '`git cat-file -t` 로 `HEAD`, `HEAD^{tree}`, `HEAD:a.txt` 의 종류를 물으면 각각 무엇이 나올까요?', '커밋, 폴더, 파일 내용에 해당해요.', NULL, NULL, '[]', 'choice', '["셋 모두 `commit` 이다", "`HEAD` 는 `blob`, `HEAD:a.txt` 는 `commit` 이다", "`HEAD` 는 `commit`, `HEAD^{tree}` 는 `tree`, `HEAD:a.txt` 는 `blob` 이다", "`HEAD` 는 `tree`, `HEAD^{tree}` 는 `commit` 이다"]', 2, '커밋은 폴더 구조(tree)를 가리키고, tree 는 파일 내용(blob)을 가리킵니다. Git 은 이 세 종류의 객체로 이력을 저장해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 2, '커밋 객체의 내용', '`git cat-file -p HEAD` 로 커밋을 열면 어떤 정보가 보일까요?', '그 시점의 폴더와 바로 앞 커밋을 가리켜요.', NULL, NULL, '[]', 'choice', '["변경된 줄만 모은 diff 가 보인다", "그 시점의 폴더를 가리키는 `tree`, 앞 커밋을 가리키는 `parent`, `author`, `committer`, 그리고 커밋 메시지가 보인다", "파일 내용 전체가 그대로 보인다", "원격 저장소 주소가 보인다"]', 1, '커밋은 변경 내용이 아니라 그 시점의 전체 스냅샷(tree)을 가리킵니다. diff 는 두 스냅샷을 비교해서 만들어 보여 주는 것이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 3, '같은 내용은 같은 해시', '내용이 똑같은 파일을 서로 다른 저장소에서 `git hash-object` 로 해시하면 어떻게 될까요?', '해시는 내용으로 정해져요.', NULL, NULL, '[]', 'choice', '["같은 해시가 나온다 (객체의 이름은 내용으로 정해진다)", "저장소마다 다른 해시가 나온다", "파일 이름이 다르면 해시도 다르다", "시간마다 해시가 바뀐다"]', 0, '내용이 같으면 한 번만 저장하므로 같은 파일을 여러 커밋에 두어도 저장 공간이 늘지 않습니다. 파일 이름은 해시에 들어가지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 4, 'ls-files 와 ls-tree', '`git ls-files` 와 `git ls-tree HEAD` 는 각각 무엇을 보여 줄까요?', '하나는 지금의 스테이징 영역, 하나는 커밋의 스냅샷이에요.', NULL, NULL, '[]', 'choice', '["둘 다 작업 폴더의 모든 파일을 보여 준다", "`ls-files` 는 원격 파일이고 `ls-tree` 는 로컬 파일이다", "둘 다 삭제된 파일만 보여 준다", "`ls-files` 는 Git 이 추적 중인 파일(스테이징 영역) 목록이고, `ls-tree HEAD` 는 `HEAD` 커밋이 가리키는 폴더 안의 항목(`100644 blob 해시 이름`)이다"]', 3, '`100644` 는 일반 파일, `blob` 은 파일 내용 객체를 뜻합니다. 추적하지 않는 새 파일은 `ls-files` 에 나오지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 5, 'HEAD~1 과 HEAD^', '한 줄로 이어진 이력에서 `HEAD~1` 과 `HEAD^` 는 무엇을 가리킬까요? `HEAD~0` 은요?', '둘 다 바로 앞 커밋이에요.', NULL, NULL, '[]', 'choice', '["`HEAD^` 는 두 커밋 앞이다", "`HEAD~1` 은 다음 커밋이다", "`HEAD~1` 과 `HEAD^` 는 둘 다 바로 앞 커밋이고, `HEAD~0` 은 `HEAD` 자신이다", "`HEAD~0` 은 가장 첫 커밋이다"]', 2, '`HEAD~2` 는 두 번 거슬러 올라간 커밋입니다. 병합 커밋에서만 `~` 와 `^` 의 차이가 생겨요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 6, '병합 커밋의 부모', '병합 커밋에서 `HEAD^1`, `HEAD^2`, `HEAD~2` 는 각각 무엇을 가리킬까요? (main 에서 `feat` 브랜치를 병합한 직후)', '부모가 둘이에요.', NULL, NULL, '[]', 'choice', '["`HEAD^2` 는 두 커밋 앞의 main 커밋이다", "`HEAD^1` 은 병합을 받은 쪽(main)의 앞 커밋, `HEAD^2` 는 병합해 온 브랜치(feat)의 마지막 커밋이고, `HEAD~2` 는 첫 번째 부모를 따라 두 번 올라간 커밋이다", "`HEAD^1` 과 `HEAD^2` 는 항상 같은 커밋이다", "병합 커밋에는 부모가 없다"]', 1, '`git log -1 --format=%p` 로 부모를 볼 수 있고 병합 커밋은 부모가 둘입니다. `^` 뒤의 숫자는 몇 번째 부모인지를 뜻해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 7, 'git describe 읽기', '`git describe --tags` 가 `v1.0-4-g1a2b3c4` 라고 출력했습니다. 무슨 뜻일까요?', '가장 가까운 태그와 거리를 알려 줘요.', NULL, NULL, '[]', 'choice', '["가장 가까운 태그 `v1.0` 에서 4개 커밋 뒤이고, 현재 커밋의 해시는 `1a2b3c4` 로 시작한다 (`g` 는 git 을 뜻하는 접두어)", "태그가 4개 있다", "`v1.0` 브랜치의 4번째 커밋이다", "4번째로 만든 태그이다"]', 0, '현재 커밋에 정확히 태그가 붙어 있으면 `v2.0` 처럼 태그 이름만 나옵니다. 빌드 버전 이름을 만들 때 자주 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 8, '경량 태그와 주석 태그', '`git tag v2.0` 과 `git tag -a v3.0 -m "메모"` 의 차이는 무엇일까요? `git describe` 는 기본으로 어느 쪽을 사용할까요?', '하나는 이름만 붙이고, 하나는 메모를 가진 객체예요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "경량 태그는 원격에 올릴 수 없다", "`describe` 는 경량 태그만 사용한다", "`v2.0` 은 커밋을 직접 가리키는 경량 태그이고 `v3.0` 은 메모와 작성자를 가진 별도의 `tag` 객체이다. `describe` 는 기본으로 주석 태그만 사용하고 `--tags` 를 주면 경량 태그도 쓴다"]', 3, '릴리스 표시에는 주석 태그를 권장합니다. 누가 언제 왜 붙였는지 남아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 9, 'add -p 의 효과', '한 파일에 서로 떨어진 두 곳을 고친 뒤 `git add -p` 에서 첫 덩어리는 `y`, 두 번째는 `n` 이라고 답했습니다. 결과는 어떻게 될까요?', '덩어리(hunk) 단위로 골라요.', NULL, NULL, '[]', 'choice', '["두 변경이 모두 스테이징된다", "두 변경이 모두 버려진다", "첫 번째 변경만 스테이징되어 `git diff --cached` 에 나오고, 두 번째 변경은 스테이징되지 않아 `git diff` 에 남는다", "파일 전체가 스테이징되지 않는다"]', 2, '한 파일의 변경을 목적별로 나눠 커밋할 때 씁니다. 커밋 전에 `git diff --cached` 로 담긴 내용을 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 10, '--merged 와 --no-merged', '`git branch --merged` 와 `git branch --no-merged` 는 각각 무엇을 보여 줄까요?', '현재 브랜치를 기준으로 해요.', NULL, NULL, '[]', 'choice', '["`--merged` 는 원격 브랜치, `--no-merged` 는 로컬 브랜치이다", "`--merged` 는 현재 브랜치에 이미 병합된 브랜치, `--no-merged` 는 아직 병합되지 않은 브랜치 목록이다", "`--merged` 는 삭제된 브랜치이다", "둘 다 모든 브랜치를 보여 준다"]', 1, '`--merged` 목록은 지워도 이력을 잃지 않는 정리 후보입니다(현재 브랜치 자신도 포함되니 주의). `--no-merged` 는 지우기 전에 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 11, 'switch - 와 오류', '`git switch -` 는 무엇을 할까요? 없는 브랜치 `nope` 로 `git switch nope` 를 하면 어떤 오류가 날까요?', '직전에 있던 곳으로 돌아가요.', NULL, NULL, '[]', 'choice', '["`switch -` 는 직전에 있던 브랜치로 돌아가고, 없는 이름은 `fatal: invalid reference: nope` 오류가 난다", "`switch -` 는 현재 브랜치를 삭제하고, 없는 이름은 새로 만든다", "`switch -` 는 `main` 으로 이동한다", "없는 이름은 오류 없이 빈 브랜치를 만든다"]', 0, '새 브랜치를 만들며 이동하려면 `git switch -c 이름` 입니다. 이미 있는 이름이면 `a branch named ''x'' already exists` 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 12, 'branch -vv', '`git branch -vv` 에서 `main  a1b2c3d [origin/main] 메시지` 처럼 `[origin/main]` 이 보이는 브랜치와 아무것도 안 보이는 브랜치는 무엇이 다를까요?', '추적하는 원격 브랜치를 보여 줘요.', NULL, NULL, '[]', 'choice', '["보이는 쪽이 더 최신 커밋이다", "보이는 쪽이 삭제 예정인 브랜치이다", "안 보이는 쪽이 원격에서 삭제된 브랜치이다", "`[origin/main]` 이 보이는 브랜치는 업스트림(추적하는 원격 브랜치)이 설정된 것이고, 안 보이는 브랜치는 업스트림이 없다"]', 3, '업스트림이 없는 브랜치는 `git push -u origin 이름` 으로 연결합니다. 연결해 두면 `git pull` 과 `git push` 에서 대상을 생략할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 13, 'restore --source', '`f.txt` 가 세 번 커밋(v1, v2, v3)되었습니다. `git restore --source=HEAD~2 f.txt` 를 실행하면 어떻게 될까요?', '기본 대상은 작업 폴더예요.', NULL, NULL, '[]', 'choice', '["파일이 v1 로 바뀌고 자동으로 커밋된다", "아무 일도 일어나지 않는다", "작업 폴더의 `f.txt` 가 v1 로 바뀌지만 스테이징되지는 않아 `git status` 에 ` M f.txt` (작업 폴더만 수정됨)로 나온다", "v1 커밋으로 `HEAD` 가 이동한다"]', 2, '`HEAD` 와 이력은 그대로이고 파일 내용만 가져옵니다. 마음에 들면 `git add`, `git commit` 으로 새 커밋을 만드세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 14, 'status 의 두 글자 읽기', '`git restore --source=HEAD~1 --staged f.txt` 를 실행한 뒤 `git status --short` 가 `MM f.txt` 로 나왔습니다. 무슨 뜻일까요?', '첫 글자는 스테이징, 둘째 글자는 작업 폴더예요.', NULL, NULL, '[]', 'choice', '["파일이 두 번 수정되어 충돌 상태이다", "첫 글자 `M` 은 스테이징 영역이 `HEAD` 와 다르다는 뜻이고, 둘째 `M` 은 작업 폴더가 스테이징 영역과 다르다는 뜻이다 (여기서는 스테이징 영역만 v2 로 바뀌었다)", "삭제된 파일이 두 개이다", "첫 글자가 작업 폴더, 둘째 글자가 스테이징 영역이다"]', 1, '`--staged` 는 스테이징 영역만, 기본은 작업 폴더만 바꿉니다. 둘 다 바꾸려면 `--staged --worktree` 를 함께 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 15, '객체 종류 묻기', '`HEAD` 가 **어떤 종류의 객체인지** 묻는 `cat-file` 옵션을 채우세요.', '"type"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-p", "-s", "-e"]', NULL, '결과는 `commit` 입니다. `HEAD^{tree}` 는 `tree`, `HEAD:파일` 은 `blob` 이 나와요.', '[0]', 'git cat-file {0} HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 16, '객체 내용 보기', '`HEAD` 커밋의 **내용을 읽기 좋게 출력**하는 `cat-file` 옵션을 채우세요.', '"pretty"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-p", "-t", "-v", "-a"]', NULL, '`tree`, `parent`, `author`, `committer`, 메시지가 보입니다.', '[0]', 'git cat-file {0} HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 17, '커밋의 폴더 보기', '`HEAD` 커밋이 가리키는 **폴더 안의 항목**을 보는 하위 명령을 채우세요.', '"트리를 나열하다"를 줄인 이름이에요.', NULL, NULL, '[]', 'fill', '["ls-tree", "ls-files", "list-tree", "tree"]', NULL, '각 줄은 `모드 종류 해시 이름` 모양입니다.', '[0]', 'git {0} HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 18, '추적 중인 파일 목록', 'Git 이 **추적 중인 파일 목록**을 보는 하위 명령을 채우세요.', '"파일을 나열하다"를 줄인 이름이에요.', NULL, NULL, '[]', 'fill', '["ls-files", "ls-tree", "list", "files"]', NULL, '추적하지 않는 새 파일은 목록에 나오지 않습니다.', '[0]', 'git {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 19, '두 번째 부모', '병합 커밋의 **두 번째 부모**를 가리키는 표기를 채우세요.', '캐럿(^) 뒤에 부모의 순번을 써요.', NULL, NULL, '[]', 'fill', '["^2", "~2", "^^", "@2"]', NULL, '`HEAD^2` 는 병합해 온 브랜치 쪽 커밋입니다. `~2` 는 첫 번째 부모를 따라 두 번 올라가는 표기예요.', '[0]', 'git log -1 HEAD{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 20, '가장 가까운 태그로 표현', '현재 커밋을 **가장 가까운 태그로 설명**해 주는 하위 명령을 채우세요.', '"묘사하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["describe", "name", "which", "tagname"]', NULL, '`v1.0-4-g1a2b3c4` 처럼 태그, 거리, 해시로 나옵니다.', '[0]', 'git {0} --tags', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 21, '덩어리 골라 스테이징', '변경을 **덩어리(hunk) 단위로 골라** 스테이징하는 옵션을 채우세요.', '"patch"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-p", "-a", "-i", "-u"]', NULL, '덩어리마다 `y`(담기)와 `n`(건너뛰기)로 고릅니다.', '[0]', 'git add {0} big.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 22, '병합된 브랜치 보기', '현재 브랜치에 **이미 병합된 브랜치만** 보는 옵션을 채우세요.', '"병합된"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--merged", "--done", "--joined", "--combined"]', NULL, '지워도 이력을 잃지 않는 브랜치를 찾을 때 씁니다.', '[0]', 'git branch {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 23, '브랜치 이름 바꾸기', '브랜치 `old` 의 이름을 `new` 로 **바꾸는** 옵션을 채우세요.', '"move"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-m", "-r", "-n", "-c"]', NULL, '현재 브랜치의 이름을 바꿀 때는 `git branch -m 새이름` 으로 한 이름만 씁니다.', '[0]', 'git branch {0} old new', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 24, '바뀐 파일 상태 보기', '`HEAD` 와 비교해 **파일 이름과 상태 글자(A·M·D)** 만 보는 옵션을 채우세요.', '"이름"과 "상태"를 이어 붙인 옵션이에요.', NULL, NULL, '[]', 'fill', '["--name-status", "--stat", "--short", "--summary"]', NULL, '`A` 는 추가, `M` 은 수정, `D` 는 삭제입니다. `--name-only` 는 이름만 보여 줘요.', '[0]', 'git diff HEAD {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 25, '특정 커밋에서 가져오기', '파일 내용을 **지정한 커밋에서 가져오는** `restore` 옵션을 채우세요.', '"출처"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--source", "--from", "--commit", "--origin"]', NULL, '기본으로 작업 폴더만 바뀝니다. 스테이징 영역까지 바꾸려면 `--staged` 를 더해요.', '[0]', 'git restore {0}=HEAD~2 f.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 26, '커밋의 구조 따라가 보기', '커밋에서 시작해 파일 내용까지 따라가며 Git 의 객체를 읽는 순서입니다. 순서에 맞게 놓아 보세요.', '종류 → 커밋 내용 → 폴더 → 파일 순서예요.', NULL, NULL, '[]', 'order', '["`git cat-file -t HEAD` 로 `commit` 인지 확인한다", "`git cat-file -p HEAD` 로 `tree` 와 `parent` 를 읽는다", "`git ls-tree HEAD` 로 폴더 안의 항목과 `blob` 을 본다", "`git cat-file -p HEAD:파일이름` 으로 파일 내용을 읽는다"]', NULL, '커밋 → tree → blob 으로 이어지는 구조를 한 번 따라가 보면 Git 이 이력을 어떻게 저장하는지 감이 옵니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 27, '한 파일의 변경을 나눠 커밋하기', '한 파일에서 목적이 다른 두 변경을 서로 다른 커밋으로 나누는 순서입니다. 순서에 맞게 놓아 보세요.', '고르기 → 확인 → 커밋 → 나머지 반복 순서예요.', NULL, NULL, '[]', 'order', '["`git add -p 파일` 로 첫 번째 변경 덩어리만 `y` 로 고른다", "`git diff --cached` 로 담긴 내용이 의도한 변경뿐인지 확인한다", "`git commit -m` 으로 첫 번째 변경을 커밋한다", "남은 변경을 같은 방법으로 고르고 확인한 뒤 두 번째 커밋을 만든다"]', NULL, '나눠 커밋하면 되돌리기와 리뷰가 쉬워집니다. `git status` 로 남은 변경도 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 28, '병합된 브랜치 정리하기', '이미 병합된 브랜치를 안전하게 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '기준 브랜치로 이동 → 목록 → 대상 확인 → 삭제 순서예요.', NULL, NULL, '[]', 'order', '["`git switch main` 으로 기준이 되는 브랜치로 이동한다", "`git branch --merged` 로 이미 병합된 브랜치 목록을 본다", "목록에서 `main` 같은 남겨야 할 브랜치를 빼고 지울 브랜치를 정한다", "`git branch -d 이름` 으로 지운다 (병합되지 않았다면 거부된다)"]', NULL, '`-d` 는 병합되지 않은 브랜치를 `not fully merged` 로 거부해서 안전합니다. 확신이 있을 때만 `-D` 를 쓰세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 168, 29, '예전 파일 상태 되살리기', '한 파일을 예전 커밋의 내용으로 되돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '커밋 찾기 → 내용 확인 → 가져오기 → 확인 후 커밋 순서예요.', NULL, NULL, '[]', 'order', '["`git log --oneline 파일` 로 되돌리고 싶은 시점의 커밋을 찾는다", "`git show 커밋:파일` 로 그 시점의 내용이 맞는지 본다", "`git restore --source=커밋 파일` 로 작업 폴더에 가져온다", "`git diff` 로 바뀐 내용을 확인한 뒤 `git add`, `git commit` 으로 새 커밋을 만든다"]', NULL, '이력을 지우지 않고 새 커밋으로 남기므로 안전합니다. 되돌린 이유를 커밋 메시지에 적어 두세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 168 AND order_index = 29);
