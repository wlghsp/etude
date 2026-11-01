-- Git 세트 155. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set155.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 155, '병합 방식, 원격 관리, detached HEAD, 안전한 푸시 한 줄씩', '팀으로 Git 을 쓸 때 만나는 개념과 명령을 한 개념씩 쉬운 문제로 반복합니다. merge 의 --no-ff·--squash·--abort 와 충돌 상태 UU, remote -v·set-url, branch -r·-a, push --delete 와 fetch --prune, detached HEAD 와 작업 구하기, pull 과 pull --rebase 의 차이, --force-with-lease 와 --force, 태그를 따로 올리는 것을 짧은 객관식·빈칸·순서 문제로 익히고, 스쿼시 병합, 병합 중단, detached HEAD 에서 작업 구하기, push 거절을 rebase 로 풀기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 155);
UPDATE quest_set SET display_order = 405, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🌿' WHERE id = 155;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 1, 'merge --no-ff', '`feature` 가 갈라진 뒤 `main` 에 새 커밋이 없어서 fast-forward 가 가능한데도 `git merge --no-ff feature` 를 쓰면 어떻게 될까요?', 'no-ff 는 "앞으로 감기를 하지 않는다"는 뜻이에요.', NULL, NULL, '[]', 'choice', '["아무 일도 일어나지 않는다", "`feature` 브랜치가 삭제된다", "병합 커밋이 항상 만들어져서 \\"이 브랜치에서 작업하고 합쳤다\\"는 흔적이 이력에 남는다", "충돌이 항상 난다"]', 2, '기능 단위로 작업이 묶여 보이는 이력을 원할 때 씁니다. 반대로 일직선 이력을 원하면 fast-forward 를 그대로 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 2, 'fast-forward 와 병합 커밋', 'fast-forward 병합과 `--no-ff` 병합의 이력 차이로 알맞은 것은 무엇일까요?', '이력이 일직선이냐, 갈라졌다 합쳐진 모양이냐의 차이예요.', NULL, NULL, '[]', 'choice', '["둘은 이력이 완전히 같다", "fast-forward 는 일직선 이력이 되고, `--no-ff` 는 갈라졌다 합쳐지는 모양과 병합 커밋이 생긴다", "fast-forward 만 병합 커밋을 만든다", "`--no-ff` 는 이력을 지운다"]', 1, '`git log --oneline --graph` 로 모양을 비교할 수 있습니다. 팀의 규칙에 맞춰 한쪽으로 통일하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 3, 'merge --squash', '`git merge --squash feature` 는 무엇을 할까요?', 'feature 의 여러 커밋을 하나로 뭉쳐요.', NULL, NULL, '[]', 'choice', '["`feature` 의 변경을 모두 스테이징만 하고, 내가 한 번 커밋하면 부모가 하나인 단일 커밋이 된다 (병합 커밋이 아니다)", "`feature` 의 커밋 이력이 그대로 `main` 에 복사된다", "병합 커밋이 자동으로 만들어진다", "`feature` 의 변경이 모두 버려진다"]', 0, '작은 커밋이 많은 브랜치를 한 커밋으로 정리해 `main` 의 이력을 단순하게 만들 때 씁니다. 스쿼시 후에는 `feature` 의 개별 커밋 메시지가 main 에 남지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 4, 'merge --abort', '병합 중 `CONFLICT` 가 나서 당장 해결하기 어렵습니다. `git merge --abort` 는 무엇을 할까요?', 'abort 는 "중단하고 원래대로"예요.', NULL, NULL, '[]', 'choice', '["충돌 난 파일을 모두 삭제한다", "충돌을 자동으로 해결한다", "`feature` 브랜치를 삭제한다", "병합을 중단하고 병합을 시작하기 전 상태로 되돌린다"]', 3, '충돌 해결을 마치기 전에만 쓸 수 있습니다. 중단한 뒤 상태가 깨끗한지 `git status` 로 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 5, 'status 의 UU', '병합 충돌 중 `git status` 에 `UU app.py` 가 보입니다. 무슨 뜻일까요?', 'U 는 unmerged 예요.', NULL, NULL, '[]', 'choice', '["파일이 업데이트되어 완료되었다", "파일이 삭제되었다", "양쪽 브랜치가 모두 같은 파일을 수정해서 아직 합쳐지지 않은(unmerged) 충돌 상태", "파일이 추적되지 않는다"]', 2, '파일을 열어 충돌 표시를 정리하고 `git add app.py` 로 해결했다고 알려야 목록에서 사라집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 6, '원격 주소 바꾸기', '저장소 주소가 바뀌어서 `origin` 이 가리키는 주소를 새 주소로 바꾸려면 어떻게 할까요?', '원격은 별명과 주소의 짝이에요.', NULL, NULL, '[]', 'choice', '["`git clone` 을 다시 한다", "`git remote set-url origin 새주소`", "`git remote add origin 새주소` 를 한 번 더 한다", "`git config origin 새주소`"]', 1, '`git remote -v` 로 현재 주소를 확인하고, 바꾼 뒤에도 한 번 더 확인하세요. `add` 는 이미 있는 이름에는 쓸 수 없어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 7, 'branch -r 과 -a', '`git branch -r` 과 `git branch -a` 는 각각 무엇을 보여 줄까요?', 'r 은 remote, a 는 all 이에요.', NULL, NULL, '[]', 'choice', '["`-r` 은 원격 추적 브랜치(`origin/main` 등)만, `-a` 는 로컬과 원격을 모두", "`-r` 은 로컬만, `-a` 는 원격만", "둘 다 로컬 브랜치만", "`-r` 은 삭제, `-a` 는 추가"]', 0, '원격 브랜치는 마지막으로 `fetch` 한 시점의 모습입니다. 최신으로 보려면 먼저 `git fetch` 하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 8, 'push --delete', '`git push origin --delete f1` 은 무엇을 지울까요?', '원격 쪽 브랜치예요.', NULL, NULL, '[]', 'choice', '["로컬 `f1` 만 지운다", "원격과 로컬 모두 지운다", "저장소 전체를 지운다", "원격 `origin` 의 `f1` 브랜치를 지운다 (내 컴퓨터의 로컬 `f1` 브랜치는 그대로 남는다)"]', 3, '로컬 브랜치까지 지우려면 `git branch -d f1` 을 따로 실행하세요. 원격 브랜치 삭제는 다른 사람에게도 영향을 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 9, 'fetch --prune', '다른 사람이 원격에서 `f1` 을 지웠는데 내 `git branch -r` 에는 `origin/f1` 이 계속 보입니다. 정리하려면 어떻게 할까요?', '내 컴퓨터에 남은 흔적을 정리해요.', NULL, NULL, '[]', 'choice', '["`git push --prune`", "`git branch -D origin/f1` 만 하면 된다", "`git fetch --prune` 으로 원격에서 사라진 브랜치의 추적 참조를 정리한다", "아무것도 하지 않아도 자동으로 사라진다"]', 2, '`fetch` 만으로는 지워진 브랜치의 흔적이 남습니다. 자주 쓴다면 `git config fetch.prune true` 로 항상 정리되게 할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 10, 'detached HEAD', '`git checkout 커밋번호` 뒤 `git status` 에 `HEAD detached at ...` 가 보입니다. 무슨 뜻일까요?', 'HEAD 가 브랜치 대신 특정 커밋을 직접 가리켜요.', NULL, NULL, '[]', 'choice', '["저장소가 손상되었다", "HEAD 가 어느 브랜치도 가리키지 않고 특정 커밋을 직접 가리키는 상태. 여기서 만든 커밋은 브랜치로 옮기지 않으면 잃기 쉽다", "원격 저장소와 연결이 끊겼다", "브랜치가 삭제되었다"]', 1, '옛 커밋을 살펴볼 때는 정상적인 상태입니다. 다만 여기서 작업하려면 새 브랜치를 만들어야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 11, 'detached HEAD 에서 작업 구하기', 'detached HEAD 상태에서 커밋을 했습니다. 이 작업을 잃지 않으려면 어떻게 할까요?', '커밋에 브랜치 이름표를 붙여요.', NULL, NULL, '[]', 'choice', '["`git switch -c 새브랜치` 로 그 자리에서 브랜치를 만든다", "`git switch main` 으로 그냥 돌아간다", "`git reset --hard` 를 한다", "아무것도 하지 않는다. 자동으로 저장된다"]', 0, '브랜치 없이 돌아가도 커밋은 `reflog` 에 잠시 남아 있어 찾을 수 있지만 오래가지 않습니다. 가능하면 바로 브랜치를 만드세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 12, 'pull --rebase', '내 커밋이 있고 원격에 새 커밋이 있을 때, `git pull` 과 `git pull --rebase` 의 차이로 알맞은 것은 무엇일까요?', '병합 커밋이 생기느냐, 일직선이 되느냐의 차이예요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`--rebase` 는 내 커밋을 삭제한다", "`pull` 은 아무것도 합치지 않는다", "`pull` 은 병합 커밋을 만들고, `--rebase` 는 내 커밋을 원격 최신 뒤에 이어 붙여 일직선으로 만든다 (내 커밋의 해시가 바뀐다)"]', 3, '이미 push 한 커밋을 rebase 하면 다른 사람과 어긋나니, 아직 올리지 않은 내 커밋에만 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 13, 'force-with-lease', '`git push --force-with-lease` 가 `--force` 보다 안전한 이유는 무엇일까요?', '내가 마지막으로 본 상태와 비교해요.', NULL, NULL, '[]', 'choice', '["항상 성공하기 때문이다", "원격 이력을 자동으로 백업하기 때문이다", "내가 마지막으로 가져온 뒤 원격이 바뀌었다면(`stale info`) 거부해서 다른 사람의 커밋을 덮어쓰지 않게 해 준다", "로컬 커밋을 삭제하기 때문이다"]', 2, '`--force` 는 원격의 남의 커밋을 지울 수 있습니다. 강제로 올려야 한다면 `--force-with-lease` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 14, '태그는 따로 올린다', '`git tag v1` 로 태그를 만든 뒤 `git push origin main` 만 했습니다. 원격에 태그가 올라갔을까요?', '태그는 브랜치와 별개로 올려요.', NULL, NULL, '[]', 'choice', '["`push` 하면 태그도 항상 함께 올라간다", "올라가지 않는다. `git push origin v1` 로 하나를, `git push origin --tags` 로 모든 태그를 따로 올려야 한다", "태그는 원격에 올릴 수 없다", "`git tag` 를 만들면 자동으로 올라간다"]', 1, '릴리스 표시를 팀원이 볼 수 있게 하려면 태그를 따로 올려야 합니다. 원격의 태그는 `git ls-remote --tags origin` 로 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 15, '병합 커밋 항상 만들기', 'fast-forward 가 가능해도 **병합 커밋을 만드는** 옵션을 채우세요.', '"앞으로 감기 없음"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--no-ff", "--no-merge", "--keep", "--always"]', NULL, '이력에 브랜치가 갈라졌다 합쳐진 흔적을 남깁니다. 팀의 병합 규칙에 따라 정하세요.', '[0]', 'git merge {0} feature', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 16, '하나로 뭉쳐 합치기', '`feature` 의 커밋들을 **하나로 뭉쳐 스테이징**하는 옵션을 채우세요.', '"짓누르다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--squash", "--flat", "--one", "--combine"]', NULL, '이 명령은 커밋을 만들지 않습니다. 이어서 `git commit` 으로 한 번 커밋하세요.', '[0]', 'git merge {0} feature', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 17, '병합 중단하기', '충돌이 난 병합을 **중단하고 원래대로** 돌리는 옵션을 채우세요.', '"중단하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--abort", "--cancel", "--undo", "--quit"]', NULL, '`--quit` 은 병합을 잊어버리되 변경은 남겨 두는 다른 옵션입니다. 되돌리려면 `--abort` 예요.', '[0]', 'git merge {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 18, '원격 주소 바꾸기', '`origin` 의 **주소를 바꾸는** 하위 명령을 채우세요.', '"URL 을 설정한다"는 뜻이에요.', NULL, NULL, '[]', 'fill', '["set-url", "change", "update", "url"]', NULL, '바꾼 뒤에는 `git remote -v` 로 주소가 맞는지 확인하세요.', '[0]', 'git remote {0} origin 새주소', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 19, '원격 브랜치만 보기', '**원격 추적 브랜치만** 목록으로 보는 옵션을 채우세요.', 'remote 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-r", "-a", "-v", "-l"]', NULL, '`-a` 는 로컬과 원격을 모두 보여 줍니다. 원격 목록은 마지막 `fetch` 시점의 모습이에요.', '[0]', 'git branch {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 20, '원격 브랜치 지우기', '원격 `origin` 의 `f1` 브랜치를 **지우는** 옵션을 채우세요.', '"삭제하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--delete", "--remove", "--rm", "--drop"]', NULL, '로컬 `f1` 은 따로 `git branch -d f1` 로 지워야 합니다.', '[0]', 'git push origin {0} f1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 21, '사라진 원격 브랜치 정리', '원격에서 사라진 브랜치의 **추적 참조를 정리**하는 옵션을 채우세요.', '"가지치기"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--prune", "--clean", "--purge", "--trim"]', NULL, '`git config fetch.prune true` 로 설정하면 `fetch` 때마다 자동으로 정리됩니다.', '[0]', 'git fetch {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 22, '그 자리에서 브랜치 만들기', 'detached HEAD 상태에서 **새 브랜치를 만들며 이동**하는 옵션을 채우세요.', 'create 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-c", "-b", "-n", "-r"]', NULL, '`git switch` 는 `-c` 를 씁니다. `-b` 는 옛 `git checkout` 의 옵션이에요.', '[0]', 'git switch {0} rescue', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 23, 'rebase 로 받아오기', '원격의 새 커밋을 **내 커밋 앞에 두고 이어 붙이며** 받는 옵션을 채우세요.', '"다시 기반을 두다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--rebase", "--linear", "--flat", "--replay"]', NULL, '내 커밋의 해시가 바뀌므로, 이미 push 한 커밋에는 쓰지 마세요.', '[0]', 'git pull {0} origin main', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 24, '안전하게 강제로 올리기', '내가 본 뒤 원격이 바뀌었다면 **거부하는** 안전한 강제 푸시 옵션을 채우세요.', '"임대 기간이 있는 강제"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--force-with-lease", "--safe-force", "--force-if-same", "--lease"]', NULL, '`--force` 는 남의 커밋을 지울 수 있으니 가능하면 쓰지 마세요.', '[0]', 'git push {0} origin main', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 25, '태그 한꺼번에 올리기', '로컬에 만든 **모든 태그를 원격에 올리는** 옵션을 채우세요.', '"태그들"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--tags", "--tag-all", "--all-tags", "-t"]', NULL, '`git push origin main` 만으로는 태그가 올라가지 않습니다. 하나만 올릴 때는 `git push origin v1` 이에요.', '[0]', 'git push origin {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 26, '기능 브랜치를 한 커밋으로 합치기', '`feature` 브랜치를 하나의 커밋으로 `main` 에 합치는 순서입니다. 순서에 맞게 놓아 보세요.', '이동 → 스쿼시 → 확인 → 커밋 순서예요.', NULL, NULL, '[]', 'order', '["`git switch main` 으로 main 으로 이동한다", "`git merge --squash feature` 로 변경을 스테이징한다", "`git status` 로 스테이징된 변경을 확인한다", "`git commit -m \\"feature 추가\\"` 로 한 번에 커밋한다"]', NULL, '스쿼시 병합은 커밋을 만들지 않고 스테이징까지만 합니다. 커밋 메시지를 직접 정리해 한 번에 남기세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 27, '병합이 부담스러울 때 중단하기', '병합 충돌이 난 뒤 중단하고 상태를 살피는 순서입니다. 순서에 맞게 놓아 보세요.', '충돌 확인 → 상태 확인 → 중단 → 비교 순서예요.', NULL, NULL, '[]', 'order', '["`git merge feature` 에서 `CONFLICT` 메시지를 확인한다", "`git status` 에서 `UU` 인 파일을 확인한다", "해결하기 어렵다면 `git merge --abort` 로 병합 전 상태로 돌아간다", "`git status` 가 깨끗한지 확인하고 `git diff main feature` 로 차이를 먼저 살펴본다"]', NULL, '무리해서 해결하다가 상태가 꼬이는 것보다, 중단하고 차이를 이해한 뒤 다시 시도하는 편이 낫습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 28, 'detached HEAD 에서 작업 구하기', 'detached HEAD 에서 한 작업을 브랜치로 구하는 순서입니다. 순서에 맞게 놓아 보세요.', '이동 → 상태 확인 → 브랜치 만들기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git checkout 커밋번호` 로 옛 커밋으로 이동한다", "`git status` 에서 `HEAD detached` 를 확인한다", "작업을 커밋한 뒤 `git switch -c rescue` 로 브랜치를 만든다", "`git switch main` 으로 돌아가도 `git log rescue` 에 작업이 남아 있는지 확인한다"]', NULL, '브랜치를 만드는 시점이 빠를수록 안전합니다. 옛 커밋을 살펴보기만 한다면 그냥 `git switch -` 로 돌아오세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 155, 29, 'push 거절을 일직선 이력으로 풀기', '`git push` 가 거절됐을 때 내 커밋을 원격 최신 뒤로 이어 붙여 올리는 순서입니다. 순서에 맞게 놓아 보세요.', '거절 확인 → rebase 로 받기 → 이력 확인 → 올리기 순서예요.', NULL, NULL, '[]', 'order', '["`git push` 가 `rejected` 로 거절되는 것을 확인한다", "`git pull --rebase origin main` 으로 내 커밋을 원격 최신 뒤에 이어 붙인다", "`git log --oneline --graph` 로 이력이 일직선인지 확인한다", "`git push origin main` 으로 다시 올린다"]', NULL, '아직 올리지 않은 내 커밋에만 rebase 를 쓰세요. 충돌이 나면 해결한 뒤 `git rebase --continue` 로 마무리합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 155 AND order_index = 29);
