-- Git 세트 143. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set143.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 143, 'Git 쉬운 문제 2: 설정, 복제, 이력 다루기 한 줄씩', 'Git 을 일상에서 쓸 때 자주 만나는 개념과 명령을 한 개념씩 쉬운 문제로 반복합니다. user.name·user.email 설정, clone 과 origin·remote -v, fast-forward 병합, branch -d 와 -D, commit --amend 와 push 후의 주의, show·blame·reflog 로 이력 읽기와 복구, tag, cherry-pick, reset --soft 와 --hard 의 차이, rebase 와 merge 의 차이를 짧은 객관식·빈칸·순서 문제로 익히고, 처음 설정과 복제, 마지막 커밋 메시지 고치기, reset 후 되살리기, 릴리스 표시의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 143);
UPDATE quest_set SET display_order = 405, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🏷️' WHERE id = 143;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 1, 'user.name 과 user.email', '`git config --global user.name "kim"` 와 `user.email` 을 설정하는 이유는 무엇일까요?', '커밋에 "누가 만들었는지"가 적혀요.', NULL, NULL, '[]', 'choice', '["Git 이 설치되려면 꼭 필요하기 때문이다", "원격 저장소의 비밀번호를 정하기 때문이다", "커밋마다 작성자 이름과 이메일이 기록되기 때문이다", "브랜치 이름을 정하기 때문이다"]', 2, '설정하지 않으면 커밋할 때 경고나 오류가 납니다. `--global` 은 이 컴퓨터의 모든 저장소에 적용한다는 뜻이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 2, 'git clone 은 무엇을 할까', '`git clone 주소` 는 무엇을 할까요?', '복사본을 통째로 내려받아요.', NULL, NULL, '[]', 'choice', '["원격 저장소에 내 파일을 올린다", "원격 저장소를 이력까지 통째로 내려받아 내 컴퓨터에 새 저장소로 만든다", "현재 폴더를 새 저장소로 초기화만 한다", "파일 하나만 다운로드한다"]', 1, 'clone 을 하면 모든 커밋 이력과 브랜치 정보가 함께 옵니다. 그래서 받자마자 `git log` 로 이력을 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 3, 'origin 은 무엇일까', 'clone 한 저장소에서 `origin` 은 무엇일까요?', '자주 쓰는 원격 주소에 붙인 이름이에요.', NULL, NULL, '[]', 'choice', '["복제해 온 원격 저장소의 기본 별명", "가장 처음 만든 브랜치의 이름", "내 컴퓨터의 사용자 이름", "가장 오래된 커밋의 이름"]', 0, '`git push origin main` 의 `origin` 은 원격 주소를 짧게 부르는 이름입니다. `git remote -v` 로 실제 주소를 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 4, 'remote -v', '`git remote -v` 는 무엇을 보여 줄까요?', '"원격"과 "자세히(verbose)"예요.', NULL, NULL, '[]', 'choice', '["원격 저장소의 모든 커밋", "내 컴퓨터의 브랜치 목록", "마지막으로 push 한 시각", "등록된 원격 저장소의 이름과 주소 (fetch, push 용)"]', 3, '푸시가 엉뚱한 곳으로 가지 않는지 주소를 확인하고 싶을 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 5, 'fast-forward 병합', '`main` 에서 갈라진 뒤 `main` 에는 새 커밋이 없고 `feature` 에만 있을 때, `main` 에서 `git merge feature` 를 하면 어떻게 될까요?', '길이 갈라지지 않았다면 포인터만 앞으로 옮기면 돼요.', NULL, NULL, '[]', 'choice', '["항상 충돌이 난다", "`feature` 브랜치가 삭제된다", "별도의 병합 커밋 없이 `main` 이 `feature` 의 끝으로 그냥 따라간다 (fast-forward)", "모든 커밋이 사라진다"]', 2, '양쪽에 서로 다른 새 커밋이 있어 길이 갈라졌을 때만 병합 커밋이 만들어집니다. 갈라지지 않았다면 간단히 앞으로 이동만 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 6, 'branch -d 와 -D', '아직 합치지 않은 브랜치에 `git branch -d wip` 를 하면 어떻게 될까요?', '`-d` 는 안전한 삭제, 대문자 `-D` 는 강제 삭제예요.', NULL, NULL, '[]', 'choice', '["경고 없이 바로 삭제된다", "아직 병합되지 않았다고 거부한다. 정말 버릴 때만 `-D` 로 강제 삭제한다", "자동으로 main 에 병합된다", "Git 이 멈춘다"]', 1, '`-d` 는 합쳐지지 않은 커밋이 사라지는 사고를 막아 줍니다. `-D` 는 되돌리기 어려우니 정말 버려도 되는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 7, 'commit --amend', '`git commit --amend -m "새 메시지"` 는 무엇을 할까요?', 'amend 는 "고치다"예요.', NULL, NULL, '[]', 'choice', '["마지막 커밋을 새 커밋으로 바꿔 메시지(또는 내용)를 고친다", "새 커밋을 하나 더 만든다", "마지막 커밋을 삭제하고 변경도 지운다", "원격 저장소의 커밋을 고친다"]', 0, '커밋의 해시가 바뀝니다. 이미 push 한 커밋을 amend 하면 다른 사람의 이력과 어긋나니 push 전에만 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 8, 'git show', '`git show 커밋` 은 무엇을 보여 줄까요?', '하나의 커밋을 자세히 펼쳐 봐요.', NULL, NULL, '[]', 'choice', '["원격 저장소의 주소", "브랜치 전체의 이력", "삭제된 파일 목록", "그 커밋의 작성자, 메시지, 변경 내용"]', 3, '`git log` 로 커밋 번호를 찾고 `git show` 로 구체적으로 무엇이 바뀌었는지 확인하는 흐름이 흔합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 9, 'git blame', '`git blame app.py` 는 무엇을 보여 줄까요?', '비난이 아니라 "누가 바꿨나"를 찾는 도구예요.', NULL, NULL, '[]', 'choice', '["파일의 오류가 있는 줄", "파일을 삭제한 사람", "파일의 각 줄을 마지막으로 바꾼 사람과 커밋, 시각", "파일의 전체 이력 요약"]', 2, '이상한 줄이 왜 생겼는지 맥락을 찾을 때 씁니다. 결과로 나온 커밋을 `git show` 로 보면 이유를 알 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 10, 'git reflog', '`git reset --hard` 로 커밋을 잃어버린 것 같을 때 단서를 찾을 수 있는 명령은 무엇일까요?', 'HEAD 가 움직인 기록을 남겨 둬요.', NULL, NULL, '[]', 'choice', '["`git status`", "`git reflog` (HEAD 가 가리켰던 위치의 기록)", "`git diff`", "`git init`"]', 1, '`reflog` 에서 되돌아갈 커밋을 찾아 `git reset --hard 커밋` 으로 복구합니다. 커밋된 내용에 한해서이고, 커밋하지 않은 변경은 찾을 수 없어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 11, 'git tag', '`git tag -a v1.0 -m "첫 릴리스"` 는 무엇을 할까요?', '특정 시점에 이름표를 붙여요.', NULL, NULL, '[]', 'choice', '["현재 커밋에 `v1.0` 이라는 이름표(버전 표시)를 붙인다", "v1.0 브랜치를 만든다", "모든 커밋을 v1.0 으로 합친다", "원격에 자동으로 올린다"]', 0, '태그는 버전처럼 의미 있는 시점을 표시하는 이름표입니다. 원격에 보내려면 `git push origin v1.0` 처럼 따로 올려야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 12, 'cherry-pick', '`git cherry-pick abc1234` 는 무엇을 할까요?', '체리를 골라 담듯 커밋 하나만 가져와요.', NULL, NULL, '[]', 'choice', '["abc1234 브랜치 전체를 합친다", "현재 브랜치를 삭제한다", "abc1234 커밋을 삭제한다", "다른 브랜치의 `abc1234` 커밋 하나만 현재 브랜치에 가져와 적용한다"]', 3, '다른 브랜치의 특정 수정만 급히 가져올 때 씁니다. 같은 변경이 두 곳에 각각 다른 커밋으로 남는다는 점에 유의하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 13, 'reset --soft', '`git reset --soft HEAD~1` 은 어떻게 동작할까요?', 'soft 는 "부드럽게"예요. 변경은 남겨 둬요.', NULL, NULL, '[]', 'choice', '["마지막 커밋과 변경 내용을 모두 지운다", "아무 일도 일어나지 않는다", "마지막 커밋을 취소하지만 그 변경은 스테이징 영역에 그대로 남는다", "원격 저장소의 커밋을 지운다"]', 2, '`--soft` 는 커밋만 풀고, `--hard` 는 작업 폴더의 변경까지 지웁니다. 커밋을 다시 정리하고 싶을 때 안전한 쪽이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 14, 'rebase 와 merge', 'rebase 는 merge 와 무엇이 다를까요?', '이력의 모양이 달라져요.', NULL, NULL, '[]', 'choice', '["두 브랜치를 그대로 두고 병합 커밋만 만든다", "내 커밋을 다른 브랜치 끝에 이어 붙여 이력을 일직선으로 만든다 (이미 공유한 브랜치에는 쓰지 않는다)", "브랜치를 삭제한다", "원격 저장소의 이력을 지운다"]', 1, 'rebase 는 커밋을 새로 만들어 이력을 바꿉니다. 다른 사람이 이미 받은 브랜치에 쓰면 이력이 어긋나니 내 개인 브랜치에서만 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 15, '작성자 이름 정하기', '모든 저장소에 쓸 **작성자 이름**을 정하는 설정 키입니다. 빈칸을 채우세요.', '"사용자 이름"을 뜻하는 설정이에요.', NULL, NULL, '[]', 'fill', '["user.name", "name", "author", "user"]', NULL, '이메일은 `user.email` 로 정합니다. 둘 다 정해야 커밋에 작성자 정보가 제대로 남아요.', '[0]', 'git config --global {0} "kim"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 16, '저장소 복제하기', '저장소를 이력까지 **통째로 내려받는** 명령입니다. 빈칸을 채우세요.', '"복제하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["clone", "copy", "pull", "fork"]', NULL, '`clone` 은 처음 한 번만 하고, 그 뒤에는 `pull` 로 새 내용을 받습니다.', '[0]', 'git {0} /srv/repo.git', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 17, '원격 주소 확인', '등록된 **원격 저장소와 주소**를 자세히 보는 옵션입니다. 빈칸을 채우세요.', 'verbose 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-v", "-a", "-l", "--list-all"]', NULL, '`origin` 의 fetch, push 주소가 나옵니다. 푸시 전에 주소를 한 번 확인하는 습관이 좋아요.', '[0]', 'git remote {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 18, '안전하게 브랜치 지우기', '합쳐진 `feature` 브랜치를 **안전하게 삭제**하는 옵션입니다. 빈칸을 채우세요.', 'delete 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-d", "-r", "-a", "-m"]', NULL, '합치지 않은 브랜치는 거부하니 안전합니다. 대문자 `-D` 는 강제 삭제예요.', '[0]', 'git branch {0} feature', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 19, '마지막 커밋 고치기', '마지막 커밋을 **고쳐 쓰는** 옵션입니다. 빈칸을 채우세요.', '"고치다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--amend", "--redo", "--fix", "--again"]', NULL, '메시지뿐 아니라 빠뜨린 파일을 `add` 한 뒤 `--amend` 하면 마지막 커밋에 포함할 수도 있습니다. push 전에만 쓰세요.', '[0]', 'git commit {0} -m "새 메시지"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 20, '줄마다 작성자 보기', '`app.py` 의 **각 줄을 누가 바꿨는지** 보는 명령입니다. 빈칸을 채우세요.', '"책임을 돌리다"는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["blame", "who", "author", "trace"]', NULL, '이름은 무서워 보이지만 이유를 찾는 도구입니다. 줄의 커밋을 `git show` 로 보면 맥락을 알 수 있어요.', '[0]', 'git {0} app.py', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 21, 'HEAD 이동 기록 보기', 'HEAD 가 움직인 **기록**을 보는 명령입니다. 빈칸을 채우세요.', 'reference 와 log 를 합친 이름이에요.', NULL, NULL, '[]', 'fill', '["reflog", "history", "undo-log", "recent"]', NULL, '실수로 커밋을 잃었을 때 되돌아갈 위치를 찾는 데 씁니다. 커밋된 내용이 대상이에요.', '[0]', 'git {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 22, '릴리스 이름표 붙이기', '현재 커밋에 `v1.0` **이름표를 붙이는** 명령입니다. 빈칸을 채우세요.', '버전 이름을 적어요.', NULL, NULL, '[]', 'fill', '["v1.0", "-v", "1.0 -x", "--v1.0"]', NULL, '`-a` 는 설명이 달린 태그를 만듭니다. 목록은 `git tag` 로 봅니다.', '[0]', 'git tag -a {0} -m "첫 릴리스"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 23, '커밋 하나만 가져오기', '다른 브랜치의 커밋 `abc1234` **하나만** 현재 브랜치에 가져오는 명령입니다. 빈칸을 채우세요.', '체리를 골라 담는 그림을 떠올려 보세요.', NULL, NULL, '[]', 'fill', '["cherry-pick", "pick", "copy-commit", "take"]', NULL, '충돌이 나면 `merge` 처럼 파일을 고치고 `git add`, `git cherry-pick --continue` 로 마무리합니다.', '[0]', 'git {0} abc1234', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 24, '커밋만 취소하기', '마지막 커밋을 취소하되 **변경은 스테이징에 남기는** 옵션입니다. 빈칸을 채우세요.', '"부드러운"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--soft", "--light", "--keep-all", "--stage"]', NULL, '`--soft` 는 커밋만 풀고 변경은 남깁니다. `--hard` 는 변경까지 지우니 훨씬 위험해요.', '[0]', 'git reset {0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 25, '이력을 그림으로 보기', '커밋 이력을 **가지 모양 그림**으로 함께 보는 옵션입니다. 빈칸을 채우세요.', '"그래프"의 영어 단어 그대로예요.', NULL, NULL, '[]', 'fill', '["--graph", "--tree", "--chart", "--map"]', NULL, '브랜치가 어디서 갈라지고 합쳐졌는지 한눈에 보입니다. `--all` 을 더하면 모든 브랜치가 나와요.', '[0]', 'git log --oneline {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 26, '처음 설정하고 복제하기', '새 컴퓨터에서 Git 을 설정하고 저장소를 받아 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '이름 → 이메일 → 복제 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git config --global user.name \\"kim\\"` 으로 이름을 정한다", "`git config --global user.email \\"이메일\\"` 으로 이메일을 정한다", "`git clone 주소` 로 저장소를 내려받는다", "`git log --oneline` 으로 이력이 따라왔는지 확인한다"]', NULL, '설정은 한 번만 하면 됩니다. clone 뒤에는 이력과 원격(`origin`)이 자동으로 준비돼요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 27, '마지막 커밋 메시지 고치기', '마지막 커밋의 메시지를 고치는 순서입니다. 순서에 맞게 놓아 보세요.', 'push 여부 확인 → 고치기 → 확인 → 올리기 순서예요.', NULL, NULL, '[]', 'order', '["`git status` 로 아직 push 하지 않은 커밋인지 확인한다", "`git commit --amend -m \\"새 메시지\\"` 로 마지막 커밋의 메시지를 고친다", "`git log --oneline -1` 로 바뀌었는지 확인한다", "`git push` 로 원격에 올린다"]', NULL, '이미 push 한 커밋은 amend 하지 않는 것이 원칙입니다. 확인이 첫 단계예요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 28, '실수로 reset 한 뒤 되살리기', '`git reset --hard` 로 커밋을 잃은 뒤 되살리는 순서입니다. 순서에 맞게 놓아 보세요.', '기록 보기 → 위치 찾기 → 되돌리기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git reflog` 로 HEAD 가 움직인 기록을 본다", "기록에서 되돌아갈 커밋 번호를 찾는다", "`git reset --hard 커밋번호` 로 그 위치로 되돌린다", "`git log --oneline` 으로 잃었던 커밋이 돌아왔는지 확인한다"]', NULL, '커밋된 내용은 `reflog` 로 복구할 수 있지만, 커밋하지 않은 변경은 복구할 수 없습니다. `--hard` 전에는 항상 상태를 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 143, 29, '릴리스 표시하기', '현재 시점에 버전 이름표를 붙여 올리는 순서입니다. 순서에 맞게 놓아 보세요.', '상태 확인 → 태그 만들기 → 확인 → 올리기 순서예요.', NULL, NULL, '[]', 'order', '["`git log --oneline` 으로 표시할 커밋의 상태를 확인한다", "`git tag -a v1.0 -m \\"첫 릴리스\\"` 로 태그를 만든다", "`git tag` 로 태그가 만들어졌는지 확인한다", "`git push origin v1.0` 으로 태그를 원격에 올린다"]', NULL, '태그는 `git push` 만으로 올라가지 않아서 따로 올려야 합니다. 올리기 전에 이름이 맞는지 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 143 AND order_index = 29);
