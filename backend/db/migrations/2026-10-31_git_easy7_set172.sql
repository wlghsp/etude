-- Git 세트 172. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set172.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 172, 'worktree, fixup, 범위 비교(.. 와 ...), 줄바꿈 정책, 서브모듈 기본 한 줄씩', '작업 폴더와 이력을 다루는 도구를 한 개념씩 반복합니다. worktree 로 같은 저장소의 폴더를 하나 더 만드는 것과 같은 브랜치를 두 곳에서 쓸 수 없는 것, worktree 에서의 커밋과 remove, commit --fixup 과 rebase --autosquash, merge-base, 두 점(..)과 세 점(...)의 log·diff 차이와 rev-list --left-right, CRLF 와 LF 그리고 ls-files --eol, core.autocrlf=input, .gitattributes 의 text·eol·binary 와 check-attr, 서브모듈의 .gitmodules 와 160000 포인터, 복제 뒤 비어 있는 서브모듈과 submodule update --init 을 짧은 객관식·빈칸·순서 문제로 익히고, 다른 브랜치를 동시에 작업하기, fixup 으로 앞 커밋 고치기, 줄바꿈 정책 적용하기, 서브모듈을 최신 커밋으로 올리기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 172);
UPDATE quest_set SET display_order = 405, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🌿' WHERE id = 172;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 1, 'worktree 란', '`git worktree add ../wt feat` 은 무엇을 할까요?', '저장소를 복제하는 것과는 달라요.', NULL, NULL, '[]', 'choice', '["저장소 전체를 새로 복제한다", "`feat` 브랜치를 삭제한다", "같은 저장소를 공유하면서 `../wt` 라는 폴더를 하나 더 만들어 `feat` 브랜치를 동시에 체크아웃한다 (저장소를 통째로 복제하지 않고 `.git` 을 공유한다)", "원격 저장소에 `feat` 를 올린다"]', 2, '새 폴더의 `.git` 은 파일이고 `gitdir: ...` 로 원래 저장소 안의 `worktrees` 폴더를 가리킵니다. 브랜치를 바꾸지 않고 급한 수정을 병행할 때 유용해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 2, '같은 브랜치는 한 곳에서만', '`feat` 브랜치가 이미 다른 worktree 에서 체크아웃되어 있습니다. `git worktree add ../wt2 feat` 과 원래 폴더에서 `git switch feat` 은 어떻게 될까요?', '한 브랜치는 한 곳에서만 쓸 수 있어요.', NULL, NULL, '[]', 'choice', '["둘 다 성공하고 두 폴더가 같은 브랜치를 쓴다", "둘 다 `fatal: ''feat'' is already used by worktree at ...` 오류로 거부된다", "`worktree add` 는 성공하고 `switch` 만 실패한다", "기존 worktree 가 자동으로 삭제된다"]', 1, '같은 브랜치를 두 곳에서 바꾸면 서로 꼬일 수 있어서 막아 둡니다. 새 브랜치를 만들며 추가하려면 `-b` 를 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 3, 'worktree 에서 한 커밋', '다른 worktree 에서 `topic` 브랜치에 커밋했습니다. 원래 폴더에서 `git branch` 를 하면 어떻게 보일까요?', '같은 저장소를 공유해요.', NULL, NULL, '[]', 'choice', '["`topic` 브랜치가 그 커밋과 함께 보이고, 다른 worktree 에서 체크아웃 중인 브랜치라는 표시로 이름 앞에 `+` 가 붙는다", "보이지 않는다 (worktree 의 브랜치는 따로 저장된다)", "원래 폴더의 현재 브랜치와 합쳐진다", "`*` 표시가 `topic` 으로 옮겨 간다"]', 0, '커밋과 브랜치는 저장소 하나에 모여 있고 작업 폴더만 여러 개입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 4, 'worktree remove', '`git worktree remove ../wt` 를 하면 폴더와 브랜치는 어떻게 될까요? 그 폴더에 커밋하지 않은 파일이 있다면요?', '폴더만 정리하고 브랜치는 남겨요.', NULL, NULL, '[]', 'choice', '["브랜치도 함께 삭제되고 파일이 있어도 바로 지워진다", "폴더는 남고 목록에서만 빠진다", "항상 오류가 난다", "폴더가 삭제되고 목록에서 빠지지만 브랜치는 남는다. 수정되었거나 추적하지 않는 파일이 있으면 `contains modified or untracked files, use --force to delete it` 로 거부된다"]', 3, '`--force` 는 커밋하지 않은 작업을 잃을 수 있으니 확인 후에 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 5, '--fixup 과 --autosquash', '`git commit --fixup 커밋` 으로 만든 커밋은 어떻게 쓰일까요?', '나중에 앞 커밋에 합쳐질 임시 커밋이에요.', NULL, NULL, '[]', 'choice', '["대상 커밋이 삭제된다", "새 브랜치가 만들어진다", "메시지가 `fixup! 원래 메시지` 인 커밋이 만들어지고, `git rebase -i --autosquash` 를 하면 대상 커밋 바로 뒤로 옮겨져 그 커밋에 합쳐진다 (합쳐진 뒤 fixup 커밋은 이력에서 사라진다)", "원격 저장소에 바로 반영된다"]', 2, '앞선 커밋의 오타나 빠뜨린 파일을 고칠 때 `rebase -i` 에서 순서를 손으로 바꾸는 수고를 덜어 줍니다. 이미 공유한 커밋에는 쓰지 마세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 6, 'merge-base', '`git merge-base main b1` 은 무엇을 출력할까요?', '두 브랜치가 갈라진 지점이에요.', NULL, NULL, '[]', 'choice', '["두 브랜치의 마지막 커밋 해시", "`main` 과 `b1` 의 가장 가까운 공통 조상 커밋의 해시", "두 브랜치를 병합한 결과 커밋", "충돌이 난 파일 목록"]', 1, '`git log -1 $(git merge-base main b1)` 로 그 커밋을 볼 수 있습니다. 병합과 `...` 비교의 기준점이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 7, '두 점과 세 점 log', '`main` 과 `b1` 이 갈라진 뒤 각각 커밋이 하나씩 있습니다. `git log main..b1`, `git log b1..main`, `git log main...b1` 은 각각 무엇을 보여 줄까요?', '점이 둘이면 한쪽 방향, 셋이면 양쪽이에요.', NULL, NULL, '[]', 'choice', '["`main..b1` 은 `b1` 에만 있는 커밋, `b1..main` 은 `main` 에만 있는 커밋이고, `main...b1` 은 둘 중 한쪽에만 있는 커밋을 모두(두 커밋) 보여 준다", "세 명령 모두 같은 결과를 보여 준다", "`...` 는 공통 커밋만 보여 준다", "`..` 는 오류가 난다"]', 0, '병합 전에 ''내 브랜치에만 있는 것''을 볼 때 두 점을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 8, 'diff 의 두 점과 세 점', '`main` 에는 `y.txt`, `b1` 에는 `x.txt` 가 각각 갈라진 뒤에 추가되었습니다. `git diff --name-only main..b1` 과 `git diff --name-only main...b1` 의 결과는?', '세 점은 공통 조상을 기준으로 해요.', NULL, NULL, '[]', 'choice', '["두 명령 모두 `x.txt` 만 나온다", "두 명령 모두 `x.txt` 와 `y.txt` 가 나온다", "`...` 는 오류가 난다", "`main..b1` 은 두 브랜치 끝을 직접 비교해 `x.txt` 와 `y.txt` 가 모두 나오고, `main...b1` 은 공통 조상 이후 `b1` 에서 바뀐 `x.txt` 만 나온다"]', 3, '''내 브랜치가 바꾼 것만'' 보려면 세 점(`main...b1`)이 알맞습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 9, 'rev-list --left-right', '`git rev-list --left-right --count main...b1` 이 `1 1` 이라고 출력했습니다. 무슨 뜻일까요?', '왼쪽 브랜치에만, 오른쪽 브랜치에만 있는 커밋 수예요.', NULL, NULL, '[]', 'choice', '["전체 커밋이 2개라는 뜻이다", "충돌이 1개 있다는 뜻이다", "`main` 에만 있는 커밋이 1개, `b1` 에만 있는 커밋이 1개라는 뜻이다 (앞쪽 숫자가 왼쪽 브랜치 몫)", "병합이 1번 일어났다는 뜻이다"]', 2, '브랜치가 얼마나 갈라졌는지 숫자로 볼 때 씁니다. `git rev-list --count main..b1` 은 한쪽 방향의 개수예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 10, '줄바꿈과 ls-files --eol', 'CRLF(윈도 방식) 줄바꿈 파일과 LF 파일을 `core.autocrlf` 설정 없이 커밋했습니다. `git ls-files --eol` 은 무엇을 보여 줄까요?', 'i 는 index(저장된 것), w 는 working(작업 폴더)이에요.', NULL, NULL, '[]', 'choice', '["항상 LF 로 바뀌어 저장된다", "`i/crlf w/crlf` 처럼 저장된(index) 줄바꿈과 작업 폴더의 줄바꿈을 파일마다 보여 주며, 설정이 없으면 CRLF 도 변환 없이 그대로 저장된다", "CRLF 파일은 커밋되지 않는다", "파일 크기만 보여 준다"]', 1, '팀원마다 운영체제가 다르면 같은 파일의 줄바꿈이 섞여 diff 가 지저분해질 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 11, 'core.autocrlf=input', '`git config core.autocrlf input` 으로 설정하고 CRLF 파일을 `git add` 하면 어떻게 될까요?', '커밋으로 들어갈 때 LF 로 바꿔요.', NULL, NULL, '[]', 'choice', '["`warning: ... CRLF will be replaced by LF the next time Git touches it` 경고가 나오고, 저장된(index) 내용은 LF 가 되며 작업 폴더의 파일은 CRLF 로 그대로 남는다", "작업 폴더의 파일이 즉시 LF 로 바뀐다", "`add` 가 거부된다", "저장된 내용도 CRLF 로 남는다"]', 0, '`input` 은 커밋할 때만 CRLF 를 LF 로 바꾸고, 체크아웃할 때는 바꾸지 않는 설정입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 12, '.gitattributes', '저장소에 `.gitattributes` 로 `* text=auto eol=lf`, `*.bat text eol=crlf`, `*.bin binary` 를 적었습니다. 무슨 효과가 있을까요?', '줄바꿈 정책을 저장소에 함께 둬요.', NULL, NULL, '[]', 'choice', '["개인의 `~/.gitconfig` 에만 적용된다", "파일을 모두 삭제한다", "`.gitattributes` 는 Git 이 읽지 않는다", "팀 모두에게 같은 규칙이 적용되어 텍스트 파일은 저장소 안에서 LF 로 정리되고, `.bat` 은 CRLF 로 체크아웃되며, `binary` 로 지정한 파일은 텍스트 변환을 하지 않는다. `git check-attr` 로 적용된 속성을 확인할 수 있다"]', 3, '개인 설정(`core.autocrlf`)과 달리 저장소에 커밋되므로 팀원 모두가 같은 정책을 따릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 13, '서브모듈이란', '서브모듈(`git submodule add ../sub libs/sub`)을 추가하면 상위 저장소에는 무엇이 기록될까요?', '다른 저장소의 특정 커밋을 가리켜요.', NULL, NULL, '[]', 'choice', '["`libs/sub` 의 모든 파일이 상위 저장소에 복사된다", "아무것도 기록되지 않는다", "`.gitmodules` 에 경로와 주소가 기록되고, `libs/sub` 은 파일 내용이 아니라 `160000` 모드의 커밋 포인터(`git ls-tree` 에서 `160000 commit`)로 저장된다", "원격 저장소 비밀번호가 기록된다"]', 2, '상위 저장소는 서브모듈의 ''어느 커밋을 쓰는지''만 기억합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 14, '복제하면 서브모듈은 비어 있다', '서브모듈이 있는 저장소를 `git clone` 하면 `libs/sub` 은 어떻게 보일까요? 어떻게 채울까요?', '기본 clone 은 서브모듈 내용을 받지 않아요.', NULL, NULL, '[]', 'choice', '["clone 만 해도 자동으로 모두 채워진다", "빈 폴더이고 `git submodule status` 맨 앞에 `-` 가 보인다. `git submodule update --init` 으로 채우거나 처음부터 `git clone --recurse-submodules` 를 쓴다 (채운 서브모듈은 브랜치가 아닌 특정 커밋에 고정된 detached HEAD 상태이다)", "서브모듈 폴더가 삭제된다", "오류가 나서 clone 이 실패한다"]', 1, '채운 뒤 서브모듈 안에서 작업하려면 브랜치를 체크아웃하고 시작하세요. detached HEAD 에서 한 커밋은 잃기 쉽습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 15, 'worktree 추가', '새 폴더에 브랜치를 **체크아웃하는** `worktree` 하위 명령을 채우세요.', '"더하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["add", "new", "create", "open"]', NULL, '새 브랜치를 만들며 추가하려면 `-b` 를 붙입니다.', '[0]', 'git worktree {0} ../wt feat', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 16, 'worktree 목록', '현재 저장소의 **worktree 목록**을 보는 하위 명령을 채우세요.', '"목록"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["list", "ls-tree", "show", "status"]', NULL, '경로, 커밋, 브랜치가 한 줄씩 나옵니다.', '[0]', 'git worktree {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 17, 'worktree 제거', 'worktree 를 **정리(삭제)하는** 하위 명령을 채우세요.', '"제거하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["remove", "delete", "rm-tree", "close"]', NULL, '브랜치는 남고 폴더만 사라집니다.', '[0]', 'git worktree {0} ../wt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 18, '새 브랜치와 함께', 'worktree 를 추가하면서 **새 브랜치 `topic` 도 만드는** 옵션을 채우세요.', '"branch"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-b", "-n", "-t", "-c"]', NULL, '`git switch -c` 와 비슷한 역할입니다.', '[0]', 'git worktree add {0} topic ../wt-topic', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 19, 'fixup 커밋', '앞 커밋에 합칠 **fixup 커밋을 만드는** 옵션 이름을 채우세요.', '"고치다, 바로잡다"라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["fixup", "amend", "squash", "fix"]', NULL, '`--amend` 는 마지막 커밋만 고칠 수 있지만 `--fixup` 은 더 앞의 커밋도 대상으로 삼을 수 있어요.', '[0]', 'git commit --{0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 20, '자동으로 합치기', '`rebase -i` 에서 `fixup!` 커밋을 **자동으로 대상 옆에 옮겨 합치는** 옵션을 채우세요.', '"자동"과 "합치다(squash)"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["autosquash", "autofix", "autosort", "squash-all"]', NULL, '`fixup!` 로 시작하는 커밋을 대상 커밋 옆으로 옮겨 합칩니다.', '[0]', 'git rebase -i --{0} HEAD~3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 21, '공통 조상 찾기', '두 브랜치의 **공통 조상**을 구하는 하위 명령을 채우세요.', '"병합"과 "기준"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["merge-base", "common", "fork-point", "ancestor"]', NULL, '병합할 때 Git 이 비교의 기준으로 삼는 커밋입니다.', '[0]', 'git {0} main b1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 22, '공통 조상 이후만 비교', '공통 조상 이후 `b1` 에서 바뀐 것만 보도록 두 브랜치 사이에 쓰는 표기를 채우세요.', '점이 세 개예요.', NULL, NULL, '[]', 'fill', '["...", "..", "--", "::"]', NULL, '점 두 개는 두 브랜치 끝을 직접 비교합니다.', '[0]', 'git diff main{0}b1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 23, '줄바꿈 상태 보기', '저장된(index) 줄바꿈과 작업 폴더의 줄바꿈을 **함께 보여 주는** `ls-files` 옵션을 채우세요.', '줄바꿈을 뜻하는 "end of line"의 줄임이에요.', NULL, NULL, '[]', 'fill', '["--eol", "--crlf", "--newline", "--lines"]', NULL, '`i/lf w/crlf` 처럼 나옵니다.', '[0]', 'git ls-files {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 24, '적용된 속성 확인', '`.gitattributes` 로 파일에 **적용된 속성을 보는** 하위 명령을 채우세요.', '"속성 확인"을 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["check-attr", "attr", "show-attr", "ls-attr"]', NULL, '`text: auto`, `eol: lf` 처럼 출력됩니다.', '[0]', 'git {0} text eol -- n.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 25, '서브모듈 채우기', '복제 뒤 비어 있는 서브모듈을 **초기화하고 내용을 받는** `submodule update` 옵션을 채우세요.', '"초기화"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--init", "--force", "--merge", "--clone"]', NULL, '처음부터 받으려면 `git clone --recurse-submodules` 를 씁니다.', '[0]', 'git submodule update {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 26, '다른 브랜치를 동시에 작업하기', '작업 중인 폴더를 두고 급한 브랜치를 별도 폴더에서 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '폴더 추가 → 작업 → 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`git worktree add ../wt hotfix` 로 새 폴더에 브랜치를 체크아웃한다", "`../wt` 에서 수정하고 `git commit` 한다", "원래 폴더에서 `git log hotfix` 로 새 커밋이 보이는지 확인한다", "작업이 끝나면 `git worktree remove ../wt` 로 폴더를 정리한다"]', NULL, '브랜치는 남으므로 병합이나 푸시는 그 뒤에 하면 됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 27, 'fixup 으로 앞 커밋 고치기', '세 커밋 전에 만든 커밋의 빠뜨린 내용을 이력을 깔끔하게 유지하며 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '수정 → 담기 → fixup → 합치기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["빠뜨린 내용을 고치고 `git add` 로 스테이징한다", "`git commit --fixup 대상커밋` 으로 `fixup!` 커밋을 만든다", "`git rebase -i --autosquash 대상커밋의_앞` 으로 합친다", "`git log` 로 `fixup!` 커밋이 사라지고 내용이 대상 커밋에 반영되었는지 확인한다"]', NULL, '아직 푸시하지 않은 커밋에만 쓰세요. 이력이 바뀌므로 공유한 뒤에는 위험합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 28, '줄바꿈 정책 적용하기', '저장소에 줄바꿈 정책을 `.gitattributes` 로 정하고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '작성 → 담기 → 상태 확인 → 커밋 순서예요.', NULL, NULL, '[]', 'order', '["`.gitattributes` 에 `* text=auto eol=lf` 를 적는다", "`git add .gitattributes` 로 스테이징한다", "`git ls-files --eol` 로 저장된 파일의 줄바꿈이 LF 인지 확인한다", "`git commit` 으로 정책을 저장소에 기록한다"]', NULL, '커밋해 두면 팀원 모두에게 같은 정책이 적용됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 172, 29, '서브모듈을 최신 커밋으로 올리기', '서브모듈이 가리키는 커밋을 최신으로 바꿔 상위 저장소에 기록하는 순서입니다. 순서에 맞게 놓아 보세요.', '갱신 → 변경 확인 → 담기 → 커밋 순서예요.', NULL, NULL, '[]', 'order', '["`git submodule update --remote` 로 서브모듈을 원격의 최신 커밋으로 갱신한다", "`git status` 에서 ` M libs/sub` 로 서브모듈 포인터가 바뀐 것을 확인한다", "`git add libs/sub` 로 새 포인터를 스테이징한다", "`git commit` 으로 상위 저장소에 기록한다"]', NULL, '커밋하기 전에 `git diff` 의 `Subproject commit` 줄로 이전과 새 커밋을 볼 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 172 AND order_index = 29);
