-- Git 세트 161. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set161.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 12, 'Git', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 12);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 161, '이력 다듬기, rebase 충돌, 병합 되돌리기, 무시 규칙, 이력 검색 한 줄씩', 'Git 이력을 다듬고 되돌리는 기술을 한 개념씩 반복합니다. reset 의 --soft·--mixed·--hard 차이, rebase -i 의 pick·squash·fixup·drop·reword 와 순서 바꾸기, rebase 충돌 때의 UU·--continue·--abort·--skip, rebase 뒤의 일직선 이력, 병합 커밋 revert -m 1, .gitignore 의 !·폴더·/ 패턴과 check-ignore -v, log --grep·-S·shortlog -sn HEAD, config 의 local 이 global 보다 우선하는 것과 alias 를 짧은 객관식·빈칸·순서 문제로 익히고, 커밋 하나로 정리, rebase 충돌 해결, 병합 되돌리기, drop 한 커밋 되살리기의 순서를 연습합니다.', 'quiz', 'Git'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 161);
UPDATE quest_set SET display_order = 405, unit_id = (SELECT id FROM unit WHERE id = 12), icon = '🧹' WHERE id = 161;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 1, 'reset 의 세 가지 방식', '커밋 3개(c1, c2, c3) 중 마지막 커밋을 `git reset --soft HEAD~1`, `git reset HEAD~1`, `git reset --hard HEAD~1` 로 각각 취소했을 때 마지막 커밋의 변경 내용은 어떻게 될까요?', 'soft, mixed(기본), hard 는 변경이 어디에 남느냐가 달라요.', NULL, NULL, '[]', 'choice', '["세 방식 모두 변경이 사라진다", "세 방식 모두 변경이 스테이징에 남는다", "`--soft` 는 변경이 스테이징 영역에 남고, 기본(`--mixed`)은 스테이징은 풀리고 작업 폴더에 남고, `--hard` 는 변경까지 모두 사라진다", "`--hard` 만 변경이 남는다"]', 2, '`status` 로 보면 soft 는 `M ` (스테이징), mixed 는 ` M ` (작업 폴더), hard 는 깨끗합니다. 어떤 방식을 쓸지 모르겠다면 안전한 쪽(soft, mixed)부터 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 2, 'rebase -i 란', '`git rebase -i HEAD~3` 은 무엇을 하는 명령일까요?', 'i 는 interactive(대화형)예요.', NULL, NULL, '[]', 'choice', '["최근 3개 커밋을 원격에 올린다", "최근 커밋 3개의 목록을 편집기로 열어 각 커밋에 `pick`, `squash`, `fixup`, `drop`, `reword` 등을 지정해 이력을 정리한다", "3개의 브랜치를 합친다", "최근 3개 커밋을 삭제하고 되돌릴 수 없게 한다"]', 1, '목록은 `pick 해시 # 제목` 모양입니다. 이미 push 해서 남이 받은 커밋은 정리하지 마세요. 아직 올리지 않은 내 커밋을 다듬을 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 3, 'squash 와 fixup', '`rebase -i` 에서 `squash` 와 `fixup` 의 차이로 알맞은 것은 무엇일까요?', '둘 다 앞 커밋에 합쳐요. 메시지를 어떻게 하느냐가 달라요.', NULL, NULL, '[]', 'choice', '["둘 다 바로 앞 커밋에 합치며, `squash` 는 합치는 커밋의 메시지도 모아 편집하게 하고 `fixup` 은 그 메시지를 버린다", "`squash` 는 합치고 `fixup` 은 삭제한다", "둘은 완전히 같다", "`fixup` 은 앞 커밋을 삭제한다"]', 0, '작은 수정을 앞 커밋에 조용히 흡수하려면 `fixup`, 메시지를 정리해서 남기려면 `squash` 를 씁니다. 첫 줄은 항상 `pick` 으로 두어야 합칠 대상이 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 4, 'drop 의 효과와 주의', '`rebase -i` 에서 중간 커밋 하나를 `drop` 하면 어떻게 될까요?', '그 커밋의 변경이 이력에서 빠져요.', NULL, NULL, '[]', 'choice', '["그 커밋의 파일만 남고 메시지가 지워진다", "뒤 커밋이 모두 함께 삭제된다", "항상 충돌 없이 깨끗하게 끝난다", "그 커밋의 변경이 이력에서 사라진다. 뒤의 커밋이 같은 줄을 고쳤다면 충돌이 날 수 있다. 버린 커밋은 `reflog` 에 잠시 남는다"]', 3, '서로 다른 파일을 고친 커밋은 깔끔하게 빠지지만, 같은 파일의 같은 줄을 이어서 고친 커밋은 충돌합니다. 잘못 버렸다면 `git reflog` 에서 해시를 찾아 `cherry-pick` 으로 되살릴 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 5, 'reword 의 효과', '`rebase -i` 에서 `reword` 를 지정한 커밋은 무엇이 바뀔까요?', '내용은 그대로, 메시지를 고쳐요.', NULL, NULL, '[]', 'choice', '["파일 내용이 바뀐다", "커밋 해시가 그대로 유지된다", "코드 내용은 그대로이고 커밋 메시지만 바뀐다. 그래도 커밋의 해시는 새로 만들어진다", "커밋이 삭제된다"]', 2, '커밋 해시는 내용과 메시지를 포함해 계산되므로 메시지만 고쳐도 바뀝니다. 그래서 이미 push 한 커밋의 메시지를 고치는 것은 조심해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 6, '커밋 순서 바꾸기', '`rebase -i` 의 목록에서 두 줄의 순서를 바꾸면 어떻게 될까요?', '목록의 위쪽이 더 오래된 커밋이에요.', NULL, NULL, '[]', 'choice', '["아무 변화가 없다", "두 커밋의 적용 순서가 바뀐다. 두 커밋이 서로 다른 파일을 고쳤다면 깔끔하게 바뀌고, 서로 의존하면 충돌할 수 있다", "두 커밋이 하나로 합쳐진다", "항상 오류가 난다"]', 1, '위쪽 줄이 먼저 적용됩니다. 순서를 바꾼 뒤에는 결과 파일이 의도대로인지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 7, 'rebase 충돌 상태', '`git rebase main` 도중 `CONFLICT` 가 났습니다. `git status` 에는 무엇이 보일까요?', '병합 충돌과 비슷하지만 rebase 가 진행 중이라는 표시가 있어요.', NULL, NULL, '[]', 'choice', '["충돌 난 파일이 `UU` 로 보이고 rebase 가 진행 중이라는 안내가 나온다. 파일을 고치고 `git add` 한 뒤 `git rebase --continue` 로 이어 간다", "아무 표시가 없고 자동으로 해결된다", "브랜치가 삭제되었다고 나온다", "저장소가 손상되었다고 나온다"]', 0, '충돌은 커밋마다 한 번씩 날 수 있어서 `--continue` 를 여러 번 해야 할 수도 있습니다. 해결 전에 표시 줄(`<<<<<<<`)을 모두 정리하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 8, '--abort 와 --skip', 'rebase 중 충돌이 났을 때 `--abort` 와 `--skip` 의 차이로 알맞은 것은 무엇일까요?', '하나는 전체를 취소하고 하나는 그 커밋만 버려요.', NULL, NULL, '[]', 'choice', '["둘은 같은 동작이다", "`--abort` 는 충돌을 자동 해결하고 `--skip` 은 중단한다", "`--skip` 은 rebase 전체를 취소한다", "`--abort` 는 rebase 를 시작하기 전 상태로 완전히 되돌리고, `--skip` 은 충돌 난 그 커밋만 버리고 나머지를 계속 적용한다"]', 3, '`--skip` 은 그 커밋의 변경을 영구히 버리는 것이니 정말 필요 없는 커밋일 때만 쓰세요. 확신이 없다면 `--abort` 로 돌아가 다시 생각해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 9, 'rebase 후의 이력 모양', '갈라진 `feat` 브랜치에서 `git rebase main` 을 한 뒤 `git log --oneline --graph` 는 어떤 모양일까요?', '내 커밋을 main 의 끝에 이어 붙여요.', NULL, NULL, '[]', 'choice', '["병합 커밋이 생기며 갈라졌다 합쳐진 모양이 된다", "`feat` 브랜치의 커밋이 모두 삭제된다", "병합 커밋 없이 `main` 의 최신 커밋 위에 `feat` 의 커밋이 이어지는 일직선 이력이 된다 (내 커밋의 해시는 바뀐다)", "이력이 그대로 유지된다"]', 2, '일직선 이력은 읽기 쉽지만 커밋을 새로 만드는 일이라 이미 공유한 브랜치에는 쓰지 않는 것이 원칙입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 10, '병합 커밋을 revert 할 때', '병합 커밋에 `git revert 병합커밋` 만 실행하면 `is a merge but no -m option was given` 오류가 납니다. 왜일까요?', '병합 커밋은 부모가 둘이라 어느 쪽으로 되돌릴지 정해야 해요.', NULL, NULL, '[]', 'choice', '["revert 는 병합 커밋을 지원하지 않는다", "병합 커밋은 부모가 둘이라 어느 부모를 기준(mainline)으로 되돌릴지 `-m 1` 처럼 정해 줘야 한다. 보통 `-m 1` 은 병합을 받은 쪽(main)을 기준으로 side 의 변경을 되돌린다", "권한이 없어서 거부된 것이다", "저장소가 손상되었다"]', 1, '`git revert -m 1 병합커밋` 으로 병합이 들여온 변경만 되돌릴 수 있습니다. 나중에 같은 브랜치를 다시 병합하려면 revert 한 사실을 먼저 고려해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 11, '.gitignore 의 패턴', '`.gitignore` 에 `*.log`, `!keep.log`, `build/`, `/todo.txt` 를 적었습니다. 각각 무슨 뜻일까요?', '느낌표는 예외, 슬래시는 폴더나 루트를 뜻해요.', NULL, NULL, '[]', 'choice', '["`*.log` 는 모든 로그 파일 무시, `!keep.log` 는 그것만 예외로 추적, `build/` 는 `build` 폴더 전체 무시, `/todo.txt` 는 저장소 최상위의 `todo.txt` 만 무시(하위 폴더의 `todo.txt` 는 무시되지 않는다)", "네 줄 모두 같은 뜻이다", "`!` 는 오류를 뜻한다", "`/todo.txt` 는 모든 폴더의 `todo.txt` 를 무시한다"]', 0, '이미 추적 중인 파일은 `.gitignore` 에 적어도 계속 추적되므로 `git rm --cached` 로 추적을 끊어야 합니다. 맨 앞 `/` 는 최상위로 고정한다는 뜻이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 12, 'check-ignore -v', '`git check-ignore -v a.log` 는 무엇을 알려 줄까요?', '어떤 규칙 때문에 무시되는지 알려 줘요.', NULL, NULL, '[]', 'choice', '["파일의 내용을 보여 준다", "파일을 삭제한다", "파일의 마지막 수정 시각을 보여 준다", "그 파일을 무시하는 규칙이 어느 파일의 몇 번째 줄에 적힌 어떤 패턴인지 (예: `.gitignore:1:*.log`)"]', 3, '파일이 왜 `git status` 에 안 보이는지 찾을 때 씁니다. 예외 규칙(`!keep.log`)이 적용된 경우도 그 규칙을 보여 줘요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 13, '이력 검색', '`git log --grep=fix`, `git log -S timeout`, `git shortlog -sn HEAD` 는 각각 무엇을 찾을까요?', '메시지, 코드 변화, 작성자별 개수예요.', NULL, NULL, '[]', 'choice', '["셋 모두 파일 이름을 찾는다", "`-S` 는 메시지를 찾고 `--grep` 은 코드를 찾는다", "`--grep` 은 커밋 메시지에 `fix` 가 든 커밋, `-S timeout` 은 `timeout` 문자열이 추가되거나 삭제된 커밋, `shortlog -sn HEAD` 는 작성자별 커밋 수", "`shortlog` 는 커밋을 삭제한다"]', 2, '스크립트처럼 입력이 터미널이 아니면 `git shortlog -sn` 은 입력을 기다리며 비어 나오니 `HEAD` 를 줘야 합니다. `-S` 는 설정 값이 언제 바뀌었는지 찾을 때 유용해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 14, 'config 의 범위와 alias', '`user.name` 이 전역(`--global`)에도 있고 저장소 안(`--local`)에도 있습니다. 이 저장소에서 `git config user.name` 은 무엇을 돌려줄까요? 그리고 옵션이 든 alias 를 만들려면 어떻게 할까요?', '좁은 범위가 우선하고, 공백이 든 값은 따옴표로 감싸요.', NULL, NULL, '[]', 'choice', '["항상 전역 값이 우선한다", "저장소 안(local)의 값이 전역(global)보다 우선한다. 옵션이 든 alias 는 `git config --global alias.st \\"status -s\\"` 처럼 값을 따옴표로 감싼다", "두 값이 이어 붙어서 나온다", "옵션이 든 alias 는 만들 수 없다"]', 1, '`git config --show-scope --list` 로 어느 범위의 값인지 볼 수 있습니다. 회사와 개인 저장소의 작성자를 다르게 쓰고 싶을 때 local 설정이 유용해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 15, '커밋만 취소하고 변경은 스테이징에', '마지막 커밋을 취소하되 **변경은 스테이징에 남기는** 옵션을 채우세요.', '"부드러운"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--soft", "--mixed", "--hard", "--keep"]', NULL, '`--mixed`(기본)는 스테이징도 풀어 작업 폴더에만 남깁니다. `--hard` 는 변경까지 버려요.', '[0]', 'git reset {0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 16, '변경까지 모두 버리기', '마지막 커밋을 취소하고 **변경까지 모두 버리는** 옵션을 채우세요.', '"단단한"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--hard", "--soft", "--force", "--erase"]', NULL, '되돌릴 수 없는 방식이라 커밋하지 않은 변경이 사라집니다. 쓰기 전에 `git status` 로 확인하세요.', '[0]', 'git reset {0} HEAD~1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 17, '대화형으로 이력 정리', '최근 3개 커밋을 **대화형으로 정리**하는 옵션을 채우세요.', 'interactive 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-r", "-a", "-e"]', NULL, '편집기가 열리고 `pick`, `squash`, `fixup`, `drop`, `reword` 같은 명령을 줄 앞에 적습니다.', '[0]', 'git rebase {0} HEAD~3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 18, '앞 커밋에 합치기', '`rebase -i` 의 목록에서 이 커밋을 **바로 앞 커밋에 합치며 메시지도 편집**하려고 합니다. 명령어를 채우세요.', '"짓누르다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["squash", "merge", "join", "combine"]', NULL, '메시지를 버리고 합치려면 `fixup` 입니다. 첫 줄은 항상 `pick` 이어야 해요.', '[0]', '{0} 74a0cf1 c3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 19, '커밋 버리기', '`rebase -i` 의 목록에서 이 커밋을 **이력에서 제거**하려고 합니다. 명령어를 채우세요.', '"떨어뜨리다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["drop", "remove", "skip", "delete"]', NULL, '줄을 지워도 같은 효과입니다. 버린 커밋은 `reflog` 에서 찾아 되살릴 수 있어요.', '[0]', '{0} 74a0cf1 c3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 20, '메시지만 고치기', '`rebase -i` 의 목록에서 이 커밋의 **메시지만 고치려고** 합니다. 명령어를 채우세요.', '"말을 다시 쓰다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["reword", "rename", "edit-msg", "amend"]', NULL, '저장하면 메시지를 입력하는 편집기가 한 번 더 열립니다. 해시가 바뀌므로 push 한 커밋에는 쓰지 마세요.', '[0]', '{0} 74a0cf1 c3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 21, '충돌 해결 후 이어 가기', '충돌을 해결하고 `git add` 한 뒤 rebase 를 **이어 가는** 옵션을 채우세요.', '"계속하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--continue", "--resume", "--next", "--go"]', NULL, '충돌은 커밋마다 날 수 있으므로 여러 번 반복할 수 있습니다. 끝나면 `git log --oneline --graph` 로 이력을 확인하세요.', '[0]', 'git rebase {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 22, 'rebase 취소하기', 'rebase 를 **시작하기 전 상태로 완전히 되돌리는** 옵션을 채우세요.', '"중단하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--abort", "--cancel", "--undo", "--quit"]', NULL, '`--quit` 은 중단만 하고 파일 상태는 그대로 두는 다른 옵션입니다. 되돌리려면 `--abort` 예요.', '[0]', 'git rebase {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 23, '충돌 난 커밋 건너뛰기', 'rebase 중 충돌 난 **그 커밋만 버리고** 계속하는 옵션을 채우세요.', '"건너뛰다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--skip", "--ignore", "--drop", "--pass"]', NULL, '건너뛴 커밋의 변경은 새 이력에 남지 않습니다. 정말 필요 없는 커밋일 때만 쓰세요.', '[0]', 'git rebase {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 24, '병합 커밋 되돌리기', '병합 커밋을 되돌릴 때 **기준이 되는 부모를 정하는** 옵션을 채우세요.', 'mainline 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-m", "-p", "-n", "-M"]', NULL, '`-m 1` 은 첫 번째 부모(보통 병합을 받은 브랜치)를 기준으로 합니다. 옵션이 없으면 오류가 나요.', '[0]', 'git revert {0} 1 병합커밋', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 25, '무시 규칙 찾기', '파일을 무시하는 **규칙의 위치와 패턴을 자세히** 보는 옵션을 채우세요.', 'verbose 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-v", "-a", "-l", "-i"]', NULL, '`.gitignore:1:*.log` 처럼 파일 이름, 줄 번호, 패턴이 나옵니다. 규칙이 의도대로 적용되는지 확인할 때 쓰세요.', '[0]', 'git check-ignore {0} a.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 26, '커밋 3개를 하나로 정리하기', 'push 하기 전에 작은 커밋 3개를 하나로 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '대상 확인 → 대화형 시작 → 합치기 지정 → 결과 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git log --oneline` 으로 정리할 커밋 3개를 확인한다", "`git rebase -i HEAD~3` 으로 목록을 연다", "첫 줄은 `pick` 으로 두고 나머지 두 줄을 `squash` 나 `fixup` 으로 바꿔 저장한다", "`git log --oneline` 으로 커밋이 하나로 합쳐졌는지 확인한다"]', NULL, '아직 push 하지 않은 내 커밋에만 하세요. 합친 뒤 메시지가 의도대로인지도 꼭 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 27, 'rebase 충돌 해결하기', '`git rebase main` 도중 충돌이 났을 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '충돌 확인 → 고치기 → 스테이징 → 이어 가기 순서예요.', NULL, NULL, '[]', 'order', '["`git status` 에서 `UU` 인 파일을 확인한다", "파일을 열어 충돌 표시 줄을 정리해 남길 내용을 정한다", "`git add 파일` 로 해결했다고 알린다", "`git rebase --continue` 로 이어 가고 `git log --oneline --graph` 로 일직선 이력을 확인한다"]', NULL, '해결이 어렵다면 `git rebase --abort` 로 시작 전 상태로 돌아갈 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 28, '병합 커밋 되돌리기', '이미 합친 브랜치의 변경을 되돌리는 순서입니다. 순서에 맞게 놓아 보세요.', '병합 찾기 → 오류 확인 → -m 으로 되돌리기 → 결과 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git log --merges --oneline` 으로 되돌릴 병합 커밋을 찾는다", "`git revert 병합커밋` 이 `is a merge but no -m` 오류를 내는 것을 확인한다", "`git revert -m 1 병합커밋` 으로 병합이 들여온 변경을 되돌린다", "파일과 `git log` 로 해당 브랜치의 변경이 사라졌는지 확인한다"]', NULL, 'revert 는 이력을 지우지 않고 되돌리는 새 커밋을 만들기 때문에 이미 공유한 이력에도 안전합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 161, 29, '잘못 버린 커밋 되살리기', '`rebase -i` 에서 실수로 `drop` 한 커밋을 되살리는 순서입니다. 순서에 맞게 놓아 보세요.', '기록 보기 → 해시 찾기 → 가져오기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`git reflog` 로 rebase 이전의 기록을 본다", "버려진 커밋의 해시를 찾는다", "`git cherry-pick 해시` 로 그 커밋을 현재 브랜치에 다시 가져온다", "`git log --oneline` 과 파일로 커밋이 돌아왔는지 확인한다"]', NULL, '`reflog` 의 기록은 영구적이지 않으니 실수를 알아챈 즉시 되살리세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 161 AND order_index = 29);
