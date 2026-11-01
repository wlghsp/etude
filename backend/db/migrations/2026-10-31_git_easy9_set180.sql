-- Git 세트 180. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set180.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 180, 'Git 훅, archive, bundle, 잃은 커밋 찾기, notes, assume-unchanged 한 줄씩', 'Git 을 자동화하고 이력을 지키는 도구를 한 개념씩 반복합니다. .git/hooks 의 이름과 실행 권한, pre-commit 의 종료 코드로 커밋을 막는 것, --no-verify 로 건너뛰기, commit-msg 훅이 받는 메시지 파일, core.hooksPath 로 팀이 훅을 공유하는 것, pre-push 훅, git archive 가 담는 것과 --prefix·zip 형식, export-ignore, git bundle 의 create·verify·clone 과 기준 커밋이 필요한 범위 번들, blame -L 과 log -L, reset --hard 로 잃은 커밋을 reflog·fsck 로 찾아 되살리는 것과 reflog expire·gc 뒤에는 복구할 수 없는 것, git notes, assume-unchanged 와 skip-worktree 를 짧은 객관식·빈칸·순서 문제로 익히고, 훅으로 커밋 막아 보기, 잃은 커밋 되살리기, 저장소를 번들 파일로 옮기기, 공백 문제 확인하고 커밋하기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 180);
UPDATE quest_set SET display_order = 405, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🪝' WHERE id = 180;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 1, '훅의 위치와 실행 권한', 'Git 훅(hook)은 어디에 어떤 이름으로 두면 동작할까요? 실행 권한이 없는 `pre-commit` 파일을 두면 어떻게 될까요?', '정해진 이름의 실행 파일이어야 해요.', NULL, NULL, '[]', 'choice', '["아무 이름이든 `.git/hooks/` 에 두면 동작한다", "실행 권한이 없으면 커밋이 거부된다", "`.git/hooks/` 안에 `pre-commit`, `commit-msg`, `pre-push` 같은 정해진 이름의 실행 파일로 둔다. 실행 권한이 없으면 훅은 무시되고 `hook was ignored because it''s not set as executable` 안내가 나오며 커밋은 그대로 진행된다", "훅은 저장소 루트의 `hooks.txt` 에 적는다"]', 2, '`.git/hooks` 에는 `.sample` 로 끝나는 예시 파일들이 들어 있습니다. 훅으로 쓰려면 이름을 맞추고 `chmod +x` 로 권한을 주세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 2, 'pre-commit 의 종료 코드', '`pre-commit` 훅이 `exit 1` 로 끝나면 `git commit` 은 어떻게 될까요? `exit 0` 이면요?', '훅의 종료 코드가 결정해요.', NULL, NULL, '[]', 'choice', '["훅의 종료 코드와 상관없이 커밋은 만들어진다", "0 이 아닌 코드로 끝나면 커밋이 만들어지지 않고(`git commit` 의 종료 코드도 1) 스테이징한 변경은 그대로 남는다. `exit 0` 이면 커밋이 진행된다", "`exit 1` 이면 스테이징한 변경도 사라진다", "`exit 0` 이면 커밋이 거부된다"]', 1, '훅 안에서는 `git diff --cached --name-only` 로 스테이징된 파일을 읽을 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 3, '--no-verify', '`git commit --no-verify`(또는 `-n`)와 `git push --no-verify` 는 무엇을 할까요?', '훅을 건너뛰어요.', NULL, NULL, '[]', 'choice', '["`commit` 은 `pre-commit` 과 `commit-msg` 훅을 건너뛰고 커밋을 만들고, `push` 는 `pre-push` 훅을 건너뛰고 푸시한다", "검사를 더 엄격하게 실행한다", "커밋 메시지를 비운다", "서버의 검사를 건너뛴다"]', 0, '훅이 막는 데에는 이유가 있으니, 정말 필요할 때만 우회하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 4, 'commit-msg 훅', '`commit-msg` 훅은 어떤 인자를 받고, 메시지가 규칙(예: `feat: ` 로 시작)에 맞지 않을 때 어떻게 막을까요?', '메시지가 담긴 임시 파일이 인자로 와요.', NULL, NULL, '[]', 'choice', '["메시지 문자열을 직접 인자로 받는다", "인자가 없고 환경 변수로만 받는다", "`exit 1` 을 해도 커밋은 만들어진다", "메시지가 담긴 파일의 경로(`COMMIT_EDITMSG`)를 첫 인자로 받는다. 파일을 읽어 규칙에 맞지 않으면 `exit 1` 로 끝나 커밋이 만들어지지 않는다"]', 3, '메시지 규칙을 자동으로 지키게 할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 5, 'core.hooksPath', '`git config core.hooksPath ../hooks-shared` 를 하면 어떻게 될까요? 왜 팀에서 이 설정을 쓸까요?', '훅을 찾는 폴더를 바꿔요.', NULL, NULL, '[]', 'choice', '["지정한 폴더의 훅이 `.git/hooks` 에 자동으로 복사된다", "훅이 모두 비활성화된다", "Git 이 `.git/hooks` 대신 지정한 폴더(`../hooks-shared`)에서 훅을 찾는다. `.git` 안은 커밋되지 않지만 이 폴더를 저장소에 포함해 두면 팀 모두가 같은 훅을 쓸 수 있다", "서버의 훅 폴더가 바뀐다"]', 2, '`git config --unset core.hooksPath` 로 되돌리면 다시 `.git/hooks` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 6, 'pre-push 훅', '`pre-push` 훅이 실패(`exit 1`)하면 `git push` 는 어떻게 될까요?', '푸시 전에 검사해요.', NULL, NULL, '[]', 'choice', '["푸시는 성공하고 경고만 나온다", "푸시가 시작되기 전에 막혀 `failed to push some refs` 오류가 나고 원격 저장소에는 아무것도 올라가지 않는다. `--no-verify` 로 우회할 수 있다", "원격에 일부만 올라간다", "`pre-push` 는 커밋을 삭제한다"]', 1, '테스트를 통과해야만 푸시되게 하고 싶을 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 7, 'git archive', '`git archive HEAD | tar -t` 로 본 목록에는 무엇이 포함될까요? 커밋하지 않은 수정이나 새 파일, `.git` 폴더는요?', '커밋에 있는 파일만 묶어요.', NULL, NULL, '[]', 'choice', '["`HEAD` 커밋에 추적된 파일만 들어 있다. `.git` 폴더, 아직 추적하지 않은 새 파일, 커밋하지 않은 수정은 들어가지 않는다 (`--prefix=proj/` 로 폴더 이름을 붙이고 `--format=zip -o 파일` 로 zip 도 만든다)", "작업 폴더의 모든 파일과 `.git` 이 들어 있다", "커밋하지 않은 수정도 포함된다", "untracked 파일도 포함된다"]', 0, '배포용 소스 압축 파일을 만들 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 8, 'export-ignore', '`.gitattributes` 에 `secret.env export-ignore` 와 `src export-ignore` 를 적고 `git archive HEAD` 를 하면 어떻게 될까요?', 'archive 에서만 빼요.', NULL, NULL, '[]', 'choice', '["`secret.env` 가 저장소에서 삭제된다", "`export-ignore` 는 `git archive` 에 영향이 없다", "`.gitattributes` 도 archive 에서 빠진다", "archive 결과에서 `secret.env` 와 `src` 가 빠지고 나머지 추적 파일(`.gitattributes` 자체도 포함)만 들어간다. 저장소의 추적 상태는 바뀌지 않는다"]', 3, '배포 압축 파일에 넣고 싶지 않은 파일(테스트, 비밀 값)에 쓰지만, 이미 커밋된 비밀 값은 이력에 남아 있으니 주의하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 9, 'git bundle', '`git bundle create repo.bundle --all` 로 만든 파일은 어디에 쓸까요? 이 파일로 복제하면 `origin` 은 무엇일까요? 일부 범위만 담은 번들은요?', '네트워크 없이 저장소를 옮기는 파일이에요.', NULL, NULL, '[]', 'choice', '["번들은 압축된 작업 폴더라 `.git` 이 없다", "번들로 복제하면 `origin` 이 비어 있다", "저장소의 이력을 하나의 파일에 담아 네트워크 없이 옮길 때 쓴다. `git bundle verify` 로 확인하고 `git clone repo.bundle 폴더` 로 복제하면 `origin` 이 그 번들 파일이다. 일부 범위만 담은 번들은 기준 커밋이 없는 저장소에서 `Repository lacks these prerequisite commits` 오류가 난다", "일부 범위 번들도 빈 저장소에서 항상 풀린다"]', 2, '`git bundle list-heads 파일` 로 담긴 브랜치를 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 10, 'blame -L 과 log -L', '`git blame -L 2,3 파일` 과 `git log -L 2,2:파일` 은 각각 무엇을 보여 줄까요?', '줄 범위에 대한 정보예요.', NULL, NULL, '[]', 'choice', '["둘 다 파일 전체의 이력을 보여 준다", "`blame -L 2,3` 은 2~3번째 줄이 마지막으로 바뀐 커밋과 작성자를 줄마다 보여 주고, `log -L 2,2:파일` 은 그 줄의 변경 이력(그 줄을 바꾼 커밋들과 변경 내용)을 시간순으로 보여 준다", "`log -L` 은 줄 수를 세어 준다", "`blame -L` 은 줄을 삭제한다"]', 1, '누가 왜 그 줄을 바꿨는지 추적할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 11, 'reset 으로 잃은 커밋 찾기', '`git reset --hard HEAD~1` 로 커밋 하나가 브랜치에서 사라졌습니다. 어떻게 찾아 되살릴 수 있을까요?', '아직 객체는 남아 있어요.', NULL, NULL, '[]', 'choice', '["`git reflog` 에서 사라진 커밋의 해시를 찾거나 `git fsck --unreachable --no-reflogs` 로 어느 브랜치에서도 닿지 않는 커밋을 찾는다. `git fsck --lost-found` 는 `.git/lost-found/commit` 에도 모아 준다. `git branch recovered 해시` 로 브랜치를 만들어 되살린다", "`reset --hard` 는 커밋을 즉시 완전히 삭제해 찾을 수 없다", "`git log` 에 항상 그대로 나온다", "`git fsck` 는 파일 시스템 오류만 고친다"]', 0, '이력이 사라졌을 때 당황해서 `gc` 를 하지 말고 먼저 해시를 찾아 브랜치를 만드세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 12, 'reflog expire 와 gc', '잃은 커밋의 reflog 기록을 `git reflog expire --expire=now --all` 로 지운 뒤, 이어서 `git gc --prune=now` 를 하면 그 커밋은 어떻게 될까요?', '참조가 없으면 정리돼요.', NULL, NULL, '[]', 'choice', '["`reflog expire` 만으로 객체가 삭제된다", "`gc` 는 reflog 에 없는 커밋도 영원히 보존한다", "`gc --prune=now` 는 이미 삭제된 커밋을 복구한다", "`reflog expire` 만으로는 객체가 남아 있지만(`git cat-file -t 해시` 가 `commit`), `gc --prune=now` 까지 하면 객체가 삭제되어 `git cat-file` 이 실패하고 되살릴 수 없다"]', 3, '`git gc` 는 흩어진 객체를 pack 파일로 묶고(`git count-objects -v` 의 `packs`) 참조되지 않는 객체를 정리합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 13, 'git notes', '`git notes add -m "reviewed by bob" HEAD` 는 무엇을 할까요? 커밋 해시는 바뀔까요? `git clone` 으로 복제하면 notes 도 따라올까요?', '커밋을 바꾸지 않고 메모를 붙여요.', NULL, NULL, '[]', 'choice', '["커밋이 수정되어 해시가 바뀐다", "notes 는 `git clone` 으로 항상 복제된다", "커밋 해시를 바꾸지 않고 별도 참조(`refs/notes/commits`)에 메모를 저장하며 `git notes show` 로 읽는다. 기본 `git clone` 으로는 notes 가 따라오지 않는다", "메모가 커밋 메시지에 합쳐진다"]', 2, '해시가 바뀌지 않아 이미 푸시한 커밋에도 메모를 붙일 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 14, 'assume-unchanged 와 skip-worktree', '추적 중인 `tracked.txt` 에 `git update-index --assume-unchanged tracked.txt` 를 한 뒤 파일을 고치면 `git status`, `git diff`, `git commit -a` 는 어떻게 동작할까요? 상태는 어떻게 확인할까요?', 'Git 이 변경을 보지 않는 척해요.', NULL, NULL, '[]', 'choice', '["`commit -a` 는 변경을 커밋한다", "`status` 와 `diff` 에 변경이 나타나지 않고 `commit -a` 도 그 변경을 커밋하지 않는다(`HEAD` 의 내용은 그대로). `git ls-files -v` 에서 맨 앞 글자가 `h`(`--skip-worktree` 는 `S`)로 보이고, `--no-assume-unchanged` 로 되돌린다", "`status` 에 계속 변경이 나온다", "파일이 저장소에서 삭제된다"]', 1, '변경을 잊어버리기 쉬워 위험하니 임시로만 쓰세요. 팀과 공유할 무시는 `.gitignore` 를 쓰는 편이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 15, '훅 건너뛰기', '`pre-commit` 과 `commit-msg` 훅을 **건너뛰고** 커밋하는 옵션을 채우세요.', '"검증하지 않음"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--no-verify", "--force", "--skip-hooks", "--quiet"]', NULL, '짧게는 `-n` 도 같은 뜻입니다.', '[0]', 'git commit {0} -m "메시지"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 16, '훅 폴더 바꾸기', '훅을 찾는 폴더를 바꾸는 설정 키의 이름을 채우세요.', '"hooks"와 "path"를 이어 붙이고 P 는 대문자예요.', NULL, NULL, '[]', 'fill', '["hooksPath", "hookDir", "hooksDir", "hooks"]', NULL, '지우려면 `git config --unset core.hooksPath` 를 씁니다.', '[0]', 'git config core.{0} ../hooks-shared', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 17, 'zip 으로 묶기', '`git archive` 의 출력 **형식을 zip** 으로 정하는 값을 채우세요.', '압축 파일 확장자와 같아요.', NULL, NULL, '[]', 'fill', '["zip", "tar", "gz", "7z"]', NULL, '형식을 정하지 않으면 tar 로 출력합니다.', '[0]', 'git archive --format={0} HEAD -o out.zip', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 18, '폴더 이름 붙이기', 'archive 안의 모든 경로 앞에 `proj/` 를 **붙이는** 옵션을 채우세요.', '"접두"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--prefix", "--root", "--dir", "--folder"]', NULL, '압축을 풀 때 `proj/` 폴더가 생깁니다.', '[0]', 'git archive {0}=proj/ HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 19, 'archive 에서 제외', '`.gitattributes` 에서 파일을 `git archive` 결과에서 **제외**하는 속성을 채우세요.', '"내보내기 무시"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["export-ignore", "archive-skip", "no-export", "ignore-archive"]', NULL, '저장소의 추적 상태는 바뀌지 않습니다.', '[0]', 'secret.env {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 20, '번들 만들기', '저장소를 하나의 파일로 담는 `bundle` 하위 명령을 채우세요.', '"만들다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["create", "make", "pack", "export"]', NULL, '`git clone repo.bundle 폴더` 로 풀 수 있습니다.', '[0]', 'git bundle {0} repo.bundle --all', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 21, '번들 확인', '번들 파일이 올바른지 **확인하는** `bundle` 하위 명령을 채우세요.', '"검증하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["verify", "check", "test", "validate"]', NULL, '기준 커밋이 없는 저장소에서는 prerequisite 오류가 납니다.', '[0]', 'git bundle {0} repo.bundle', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 22, '줄 범위 지정', '`blame` 에서 **줄 범위**를 정하는 옵션을 채우세요.', '"line"의 첫 글자(대문자)예요.', NULL, NULL, '[]', 'fill', '["-L", "-l", "-n", "-r"]', NULL, '`log` 에서도 `-L 2,2:파일` 처럼 같은 옵션을 씁니다.', '[0]', 'git blame {0} 2,3 multi.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 23, '끊어진 객체 모으기', '어느 참조에서도 닿지 않는 객체를 `.git/lost-found` 에 **모아 주는** `fsck` 옵션을 채우세요.', '"잃어버린 것 찾기"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["lost-found", "recover", "dangling", "rescue"]', NULL, '`dangling commit 해시` 로 나오면 `git branch 이름 해시` 로 되살립니다.', '[0]', 'git fsck --{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 24, '메모 붙이기', '커밋에 **메모를 붙이는** `notes` 하위 명령을 채우세요.', '"더하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["add", "new", "set", "put"]', NULL, '읽을 때는 `git notes show HEAD` 를 씁니다.', '[0]', 'git notes {0} -m "메모" HEAD', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 25, '변경을 Git 이 모르는 척', '추적 중인 파일의 변경을 **일시적으로 무시**하게 하는 `update-index` 옵션 이름을 채우세요.', '"변경되지 않았다고 가정"이라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["assume-unchanged", "ignore-changes", "skip-diff", "no-track"]', NULL, '되돌릴 때는 `--no-assume-unchanged` 를 씁니다.', '[0]', 'git update-index --{0} tracked.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 26, '훅으로 커밋 막아 보기', '`pre-commit` 훅으로 커밋을 막고 우회 여부까지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '훅 작성 → 권한 → 시도 → 결과 확인 순서예요.', NULL, NULL, '[]', 'order', '["`.git/hooks/pre-commit` 에 `exit 1` 로 끝나는 스크립트를 작성한다", "`chmod +x .git/hooks/pre-commit` 으로 실행 권한을 준다", "변경을 스테이징하고 `git commit` 을 해서 훅이 실행되고 커밋이 거부되는지 확인한다", "`git log` 로 커밋이 늘지 않았고 `git diff --cached` 로 스테이징이 그대로인지 확인한다"]', NULL, '훅이 의도대로 막은 뒤에는 훅을 고치거나, 꼭 필요하면 `--no-verify` 로 우회합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 27, 'reset 으로 잃은 커밋 되살리기', '`reset --hard` 로 사라진 커밋을 되살리는 순서입니다. 순서에 맞게 놓아 보세요.', '해시 찾기 → 존재 확인 → 브랜치 만들기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git reflog` 에서 사라진 커밋의 해시를 찾는다", "`git cat-file -t 해시` 로 객체가 아직 `commit` 으로 남아 있는지 확인한다", "`git branch recovered 해시` 로 그 커밋을 가리키는 브랜치를 만든다", "`git log recovered` 로 되살아난 커밋을 확인한다"]', NULL, '`gc --prune=now` 를 하기 전에 해야 합니다. 그 뒤에는 복구할 수 없습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 28, '저장소를 번들 파일로 옮기기', '네트워크 없이 저장소를 다른 곳으로 옮기는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 확인 → 옮기기 → 복제 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git bundle create repo.bundle --all` 로 이력을 한 파일에 담는다", "`git bundle verify repo.bundle` 로 파일이 올바른지 확인한다", "`repo.bundle` 파일을 USB 등으로 다른 곳에 옮긴다", "`git clone repo.bundle 새폴더` 로 복제하고 `git rev-list --count HEAD` 로 커밋 수를 확인한다"]', NULL, '일부 범위만 담은 번들은 받는 쪽 저장소에 기준 커밋이 있어야 풀립니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 180, 29, '공백 문제 확인하고 커밋하기', '커밋 전에 공백 오류(줄 끝 공백 등)를 확인하고 고치는 순서입니다. 순서에 맞게 놓아 보세요.', '점검 → 수정 → 재점검 → 커밋 순서예요.', NULL, NULL, '[]', 'order', '["`git diff --check` 로 줄 끝 공백 같은 문제가 있는지 확인한다 (문제가 있으면 종료 코드 2)", "지적된 줄의 공백을 고친다", "`git diff --check` 를 다시 실행해 아무것도 나오지 않고 종료 코드가 0 인지 확인한다", "`git add` 와 `git commit` 으로 커밋한다"]', NULL, '문제가 없으면 아무것도 출력하지 않고 종료 코드 0 으로 끝납니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 180 AND order_index = 29);
