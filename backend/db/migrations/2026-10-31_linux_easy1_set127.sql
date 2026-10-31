-- 미들웨어 세트 127. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set127.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 127, '리눅스 쉬운 문제 1: 파일과 폴더 명령 한 줄씩', '리눅스의 가장 기본 명령을 한 줄 개념씩 쉬운 문제로 반복합니다. pwd·ls·cd·mkdir·touch·cp·mv·rm·cat·less·head 의 뜻, ls -l 첫 글자와 숨김 파일, ~ 와 ., .., 자주 쓰는 옵션(-p, -r, -l, -a, -h, -f), 덮어쓰기(>)와 덧붙이기(>>), find -name 과 grep -i, 파일 다루는 순서를 짧은 객관식·빈칸·순서 문제로 익힙니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 127);
UPDATE quest_set SET display_order = 7, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🌱' WHERE id = 127;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 1, 'pwd 는 무엇을 할까', '터미널에서 `pwd` 를 입력하면 무엇이 나올까요?', '"지금 내가 어디 있지?"를 알려 줘요.', NULL, NULL, '[]', 'choice', '["현재 로그인한 사용자 이름", "비밀번호", "지금 있는 위치(현재 디렉터리의 경로)", "현재 시각"]', 2, '`pwd` 는 print working directory 의 줄임말로 현재 위치를 보여 줍니다. 길을 잃으면 가장 먼저 쳐 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 2, 'ls 는 무엇을 할까', '`ls` 는 무엇을 보여 줄까요?', 'list(목록)의 줄임말이에요.', NULL, NULL, '[]', 'choice', '["실행 중인 프로세스 목록", "현재 폴더 안의 파일과 폴더 목록", "네트워크 연결 목록", "설치된 패키지 목록"]', 1, '`ls` 는 폴더의 내용을 나열합니다. 옵션(`-l`, `-a`)으로 더 자세히 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 3, 'cd .. 은 어디로 갈까', '`cd ..` 를 입력하면 어디로 이동할까요?', '점 두 개는 "위"를 뜻해요.', NULL, NULL, '[]', 'choice', '["한 단계 위(상위) 폴더", "홈 디렉터리", "루트(/) 디렉터리", "직전에 있던 폴더"]', 0, '`..` 는 상위 폴더, `.` 는 현재 폴더입니다. 홈으로는 `cd ~`, 직전 위치로는 `cd -` 를 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 4, 'mkdir 는 무엇을 할까', '`mkdir reports` 를 실행하면 무슨 일이 일어날까요?', 'make directory 의 줄임말이에요.', NULL, NULL, '[]', 'choice', '["`reports` 파일이 삭제된다", "`reports` 폴더로 이동한다", "`reports` 의 내용이 출력된다", "`reports` 라는 새 폴더가 만들어진다"]', 3, '`mkdir` 은 폴더를 만듭니다. 이미 있으면 "File exists" 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 5, 'touch 는 무엇을 할까', '아직 없는 `notes.txt` 에 `touch notes.txt` 를 실행하면 어떻게 될까요?', '내용은 쓰지 않아요.', NULL, NULL, '[]', 'choice', '["`notes.txt` 가 폴더로 만들어진다", "오류가 나고 아무것도 안 된다", "내용이 빈 `notes.txt` 파일이 만들어진다", "`notes.txt` 가 삭제된다"]', 2, '`touch` 는 파일이 없으면 빈 파일을 만들고, 있으면 수정 시각만 갱신합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 6, 'cp 는 무엇을 할까', '`cp a.txt b.txt` 를 실행하면 어떻게 될까요?', 'copy 의 줄임말이에요.', NULL, NULL, '[]', 'choice', '["`a.txt` 가 `b.txt` 로 이름이 바뀐다", "`a.txt` 는 그대로 두고 같은 내용의 `b.txt` 가 생긴다", "`a.txt` 가 삭제된다", "`b.txt` 가 `a.txt` 에 덮어써진다"]', 1, '`cp 원본 대상` 순서입니다. 대상이 이미 있으면 덮어쓰니 주의하세요. 덮어쓰기 전에 물어보려면 `cp -i` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 7, 'mv 의 두 가지 쓰임', '`mv` 명령으로 할 수 있는 일로 알맞은 것은 무엇일까요?', '이동하거나, 같은 곳에서 이름만 바꿀 수 있어요.', NULL, NULL, '[]', 'choice', '["파일을 다른 곳으로 옮기거나 이름을 바꾼다", "파일을 복사한다", "파일 내용을 보여 준다", "파일을 압축한다"]', 0, '`mv a.txt b.txt` 는 같은 폴더 안에서 이름 바꾸기, `mv a.txt dir/` 는 이동입니다. 둘 다 원본이 남지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 8, 'rm 은 되돌릴 수 있을까', '`rm old.txt` 로 파일을 지웠습니다. 휴지통에서 복원할 수 있을까요?', '리눅스 터미널에는 휴지통이 없어요.', NULL, NULL, '[]', 'choice', '["예. 휴지통에서 바로 복원된다", "예. `undo` 명령으로 되돌린다", "예. 재부팅하면 복원된다", "아니다. `rm` 은 휴지통을 거치지 않고 바로 삭제하므로 신중히 써야 한다"]', 3, '`rm` 은 즉시 삭제입니다. 중요한 파일은 지우기 전에 `ls` 로 이름을 확인하고, 불안하면 `rm -i` 로 물어보게 하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 9, 'cat 은 무엇을 할까', '`cat app.log` 를 실행하면 무엇이 나올까요?', '파일을 이어(concatenate) 보여 줘요.', NULL, NULL, '[]', 'choice', '["`app.log` 가 삭제된다", "`app.log` 의 크기만 나온다", "`app.log` 의 전체 내용이 화면에 출력된다", "`app.log` 가 편집기로 열린다"]', 2, '`cat` 은 파일 내용을 그대로 출력합니다. 큰 파일은 `less` 나 `head`, `tail` 로 일부만 보는 편이 좋아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 10, 'less 에서 나가는 법', '`less app.log` 로 파일을 열었는데 어떻게 나가야 할지 모르겠습니다. 알맞은 키는 무엇일까요?', 'quit 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["`Ctrl+S`", "`q`", "`:wq`", "`exit` 를 입력하고 Enter"]', 1, '`less` 에서는 `q` 로 나가고, `/글자` 로 검색, 스페이스로 다음 쪽 이동입니다. `:wq` 는 vim 의 저장 후 종료예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 11, 'head -n 3', '`head -n 3 app.log` 는 무엇을 보여 줄까요?', 'head 는 머리, 즉 앞부분이에요.', NULL, NULL, '[]', 'choice', '["파일의 처음 3줄", "파일의 마지막 3줄", "파일의 3번째 줄만", "파일의 글자 3개"]', 0, '`head` 는 앞부분, `tail` 은 뒷부분입니다. 로그의 맨 끝을 볼 때는 `tail`, 형식을 확인할 때는 `head` 가 편해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 12, 'ls -l 의 첫 글자 d', '`ls -l` 결과의 맨 앞 글자가 `d` 입니다 (예: `drwxr-xr-x`). 무엇을 뜻할까요?', '파일 종류를 나타내는 글자예요.', NULL, NULL, '[]', 'choice', '["삭제된 파일", "숨김 파일", "실행 파일", "디렉터리(폴더)"]', 3, '첫 글자는 종류입니다. `-` 는 일반 파일, `d` 는 디렉터리, `l` 은 링크예요. 나머지 9글자가 권한입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 13, '이름이 점으로 시작하면', '`.bashrc` 처럼 이름이 점(`.`)으로 시작하는 파일은 `ls` 에서 어떻게 보일까요?', '"숨김 파일"이라고 불러요.', NULL, NULL, '[]', 'choice', '["항상 맨 위에 보인다", "읽기 전용이라 표시된다", "기본으로는 보이지 않는다. `ls -a` 로 보인다", "삭제 예정 파일이라 보이지 않는다"]', 2, '점으로 시작하는 파일은 설정 파일이 많아서 목록이 지저분해지지 않도록 숨겨집니다. `ls -a` 로 모두 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 14, '~ 는 어디일까', '`cd ~` 에서 `~` 는 무엇을 뜻할까요?', '로그인한 사용자 개인의 공간이에요.', NULL, NULL, '[]', 'choice', '["루트 디렉터리", "현재 사용자의 홈 디렉터리", "임시 폴더", "직전 폴더"]', 1, '`~` 는 홈 디렉터리의 줄임입니다. 그냥 `cd` 만 입력해도 홈으로 가요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 15, '부모 폴더까지 한 번에 만들기', '`a/b/c` 폴더를 만들고 싶은데 `a` 도 `b` 도 아직 없습니다. 부모 폴더까지 함께 만드는 옵션을 채우세요.', 'parent 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-p", "-r", "-f", "-a"]', NULL, '`-p` 는 필요한 상위 폴더까지 만들고, 이미 있어도 오류를 내지 않습니다.', '[0]', 'mkdir {0} a/b/c', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 16, '폴더 통째로 복사하기', '폴더 `data` 를 `backup` 으로 **안의 내용까지** 복사하는 옵션을 채우세요.', 'recursive(재귀)의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-r", "-l", "-v", "-q"]', NULL, '폴더는 `-r`(recursive) 없이 `cp` 하면 "omitting directory" 오류가 납니다.', '[0]', 'cp {0} data backup', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 17, '폴더 통째로 지우기', '폴더 `olddir` 를 **안의 내용까지** 지우는 옵션을 채우세요. (신중히 써야 해요)', '복사할 때와 같은 글자예요.', NULL, NULL, '[]', 'fill', '["-r", "-i", "-v", "-q"]', NULL, '`rm -r` 은 폴더 안을 모두 지웁니다. 되돌릴 수 없으니 경로를 꼭 확인하세요. 특히 `rm -rf /` 같은 실수는 치명적이에요.', '[0]', 'rm {0} olddir', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 18, '자세하게 보기', '파일의 **권한, 소유자, 크기, 수정 시각**까지 자세히 보는 `ls` 옵션을 채우세요.', 'long(긴 형식)의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-l", "-a", "-r", "-t"]', NULL, '`ls -l` 은 한 줄에 파일 하나씩 자세한 정보를 보여 줍니다. `-a` 는 숨김 파일까지, `-t` 는 시간순 정렬이에요.', '[0]', 'ls {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 19, '숨김 파일까지 보기', '점으로 시작하는 **숨김 파일까지** 모두 보는 `ls` 옵션을 채우세요.', 'all 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-a", "-l", "-r", "-t"]', NULL, '`ls -a` 는 `.bashrc` 같은 숨김 파일과 `.`, `..` 도 보여 줍니다. 보통 `ls -la` 로 함께 써요.', '[0]', 'ls {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 20, '크기를 읽기 쉽게', '`ls -l` 의 파일 크기를 `1.5K`, `2.3M` 처럼 **사람이 읽기 쉬운** 단위로 보려 합니다. 옵션 글자를 채우세요.', 'human 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["h", "a", "r", "t"]', NULL, '`-h` 는 human-readable 입니다. `df -h`, `du -h`, `free -h` 에도 같은 뜻으로 쓰여요.', '[0]', 'ls -l{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 21, '줄 수 세기', '`app.log` 가 **몇 줄**인지 세는 옵션을 채우세요.', 'line 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-l", "-w", "-c", "-m"]', NULL, '`wc -l` 은 줄 수, `-w` 는 단어 수, `-c` 는 바이트 수입니다. `grep ERROR 파일 | wc -l` 로 에러 줄 수를 셀 수 있어요.', '[0]', 'wc {0} app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 22, '로그를 실시간으로 따라가기', '로그 파일의 **끝부분을 계속 따라가며** 새 줄이 생길 때마다 보여 주는 옵션을 채우세요. (끝내려면 Ctrl+C)', 'follow 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-f", "-n", "-c", "-q"]', NULL, '`tail -f` 는 장애를 지켜볼 때 가장 많이 쓰는 명령입니다. 처음 몇 줄을 함께 보려면 `tail -n 50 -f app.log` 처럼 씁니다.', '[0]', 'tail {0} app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 23, '파일에 쓰기: 덮어쓰기', '`echo hello` 의 출력을 `a.txt` 에 **저장**합니다. 이미 있던 내용은 지워지고 새 내용으로 **덮어씁니다**. 기호를 채우세요.', '화살표 모양 기호 하나예요.', NULL, NULL, '[]', 'fill', '[">", ">>", "|", "<"]', NULL, '`>` 는 덮어쓰기입니다. 같은 파일에 `>` 를 다시 쓰면 기존 내용이 사라지니 주의하세요.', '[0]', 'echo hello {0} a.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 24, '파일에 쓰기: 덧붙이기', '`echo more` 의 출력을 `a.txt` 의 **끝에 덧붙입니다**. 기존 내용은 유지됩니다. 기호를 채우세요.', '화살표 모양 기호 두 개예요.', NULL, NULL, '[]', 'fill', '[">>", ">", "|", "<"]', NULL, '`>>` 는 이어 붙이기입니다. 로그를 쌓을 때 쓰고, 파일이 없으면 새로 만듭니다.', '[0]', 'echo more {0} a.txt', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 25, '직전 위치로 돌아가기', '다른 폴더로 갔다가 **바로 전에 있던 폴더**로 되돌아가는 명령입니다. 빈칸을 채우세요.', '빼기(하이픈) 기호 하나예요.', NULL, NULL, '[]', 'fill', '["-", "..", "~", "/"]', NULL, '`cd -` 는 이전 위치로 돌아가고 그 경로를 출력합니다. 두 폴더를 오갈 때 편해요.', '[0]', 'cd {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 26, '이름으로 파일 찾기', '현재 폴더 아래에서 이름이 `.log` 로 끝나는 파일을 찾습니다. 이름으로 찾는 옵션을 채우세요.', '"이름"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["-name", "-type", "-size", "-mtime"]', NULL, '`-name` 은 이름, `-type` 은 종류(f 파일, d 폴더), `-size` 는 크기, `-mtime` 은 수정 일수입니다. 패턴은 따옴표로 감싸야 쉘이 먼저 풀지 않아요.', '[0]', 'find . {0} "*.log"', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 27, '대소문자 구분 없이 찾기', '`app.log` 에서 `error` 를 **대소문자 구분 없이**(`Error`, `ERROR` 도 포함) 찾는 옵션을 채우세요.', 'ignore case 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-v", "-n", "-c"]', NULL, '`-i` 는 대소문자를 무시합니다. `-n` 은 줄 번호, `-c` 는 일치하는 줄 수, `-v` 는 일치하지 않는 줄이에요.', '[0]', 'grep {0} error app.log', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 28, '파일 만들고 확인하고 지우기', '새 파일을 만들어 내용을 쓰고, 확인한 뒤 지우는 순서입니다. 순서에 맞게 놓아 보세요.', '만들고 → 쓰고 → 보고 → 지워요.', NULL, NULL, '[]', 'order', '["`touch a.txt`", "`echo hello > a.txt`", "`cat a.txt`", "`rm a.txt`"]', NULL, '이 흐름(만들기, 쓰기, 확인, 삭제)이 파일 다루기의 기본기입니다. 지우기 전에 `ls` 로 확인하는 습관도 좋아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 29, '폴더 만들고 들어가기', '새 폴더를 만들고 그 안에 들어가 위치를 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '만들고 → 들어가고 → 확인해요.', NULL, NULL, '[]', 'order', '["`mkdir work`", "`cd work`", "`pwd`", "`ls`"]', NULL, '새 폴더는 비어 있어서 `ls` 에 아무것도 안 나옵니다. `pwd` 로 내가 어디 있는지 확인하는 습관은 사고를 막아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 29);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 30, '복사하고 이름 바꾸기', '`a.txt` 를 복사해 `b.txt` 를 만든 뒤 `c.txt` 로 이름을 바꾸고 확인하는 순서입니다.', '복사 → 이름 변경 → 목록 확인 순서예요.', NULL, NULL, '[]', 'order', '["`cp a.txt b.txt`", "`mv b.txt c.txt`", "`ls`"]', NULL, '`cp` 는 원본을 남기고, `mv` 는 원본이 사라집니다. 마지막 `ls` 에는 `a.txt` 와 `c.txt` 가 보여요.', '[0, 1, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 30);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 127, 31, '폴더 통째로 백업하기', '`data` 폴더를 `backup` 폴더 안으로 통째로 복사하고 확인하는 순서입니다.', '백업 폴더 만들기 → 복사 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`mkdir backup`", "`cp -r data backup/`", "`ls backup`"]', NULL, '폴더를 복사할 때는 `-r` 을 꼭 붙입니다. 복사 후 `ls` 로 결과를 확인하는 습관이 중요해요.', '[0, 1, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 127 AND order_index = 31);
