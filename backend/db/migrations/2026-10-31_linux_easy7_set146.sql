-- 리눅스 세트 146. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set146.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 146, '리눅스 쉬운 문제 7: vi 편집기, ssh·scp, 날짜 형식, 방화벽, 서버 정보 한 줄씩', '서버에 접속해 파일을 고치고 옮길 때 자주 쓰는 도구를 한 개념씩 쉬운 문제로 반복합니다. vi 의 명령 모드와 입력 모드, :wq·:q!, dd·u·yy·p, /검색, ssh user@host 의 모양과 -p·-i, scp 의 방향과 -P·-r(ssh 와 scp 의 포트 옵션 대소문자 차이), date +%Y-%m-%d 형식, 서비스는 LISTEN 인데 접속이 안 될 때의 방화벽 점검, /etc/os-release 와 uname 을 짧은 객관식·빈칸·순서 문제로 익히고, vi 로 파일 고치기, 원격에 파일 보내고 확인하기, 방화벽 점검, 서버 정보 파악의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 146);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '✏️' WHERE id = 146;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 1, 'vi 의 두 가지 모드', '`vi app.conf` 로 파일을 열었더니 글자를 입력해도 아무것도 써지지 않고 이상하게 동작합니다. 이유는 무엇일까요?', 'vi 는 처음 열면 "입력"이 아니라 다른 모드로 시작해요.', NULL, NULL, '[]', 'choice', '["파일이 읽기 전용이라서 절대 쓸 수 없다", "키보드가 고장 났다", "처음에는 명령 모드라서 글자가 입력되지 않는다. `i` 를 눌러 입력 모드로 바꿔야 쓸 수 있다", "vi 는 입력을 지원하지 않는다"]', 2, '`Esc` 는 명령 모드로, `i` 는 입력 모드로 돌아가는 키입니다. 헷갈리면 일단 `Esc` 를 두세 번 눌러 보세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 2, '저장하고 나가기', 'vi 에서 입력을 마치고 **저장한 뒤 종료**하려면 어떻게 할까요?', '`Esc` 로 명령 모드로 돌아온 다음 콜론으로 시작해요.', NULL, NULL, '[]', 'choice', '["`Ctrl+S` 를 누른다", "`Esc` 를 누르고 `:wq` 를 입력한 뒤 Enter", "`exit` 를 입력한다", "창을 그냥 닫는다"]', 1, '`:w` 는 저장, `:q` 는 종료, `:wq` 는 둘을 합친 것입니다. 저장만 하고 계속 편집하려면 `:w` 만 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 3, '저장하지 않고 나가기', '잘못 고쳐서 **변경을 버리고** vi 를 종료하려면 어떻게 할까요?', '느낌표는 "강제로"를 뜻해요.', NULL, NULL, '[]', 'choice', '["`Esc` 를 누르고 `:q!` 를 입력한 뒤 Enter", "`:wq` 를 입력한다", "`Ctrl+Z` 를 누른다", "`:save` 를 입력한다"]', 0, '`:q` 만 쓰면 변경이 있을 때 종료를 거부합니다. `:q!` 는 변경을 버리고 나가는 가장 안전한 탈출구예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 4, 'dd 와 u', 'vi 의 명령 모드에서 `dd` 를 눌렀더니 줄이 하나 사라졌습니다. 되돌리려면 어떻게 할까요?', 'undo 의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["`Ctrl+C` 를 누른다", "`:q!` 로 나갔다가 다시 연다", "되돌릴 수 없다", "`u` 를 눌러 직전 동작을 되돌린다"]', 3, '`dd` 는 현재 줄 삭제, `u` 는 되돌리기입니다. 여러 번 누르면 더 이전 단계로 돌아가요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 5, 'vi 에서 검색', 'vi 에서 `ERROR` 라는 글자를 찾으려면 어떻게 할까요?', '`less` 와 같은 방식이에요.', NULL, NULL, '[]', 'choice', '["`find ERROR` 를 입력한다", "`Ctrl+F` 를 누른다", "명령 모드에서 `/ERROR` 를 입력하고 Enter, 다음 결과는 `n`", "`grep ERROR` 를 입력한다"]', 2, '`/` 는 아래쪽, `?` 는 위쪽으로 검색합니다. 큰 설정 파일에서 원하는 줄을 빨리 찾을 때 유용해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 6, '줄 복사하고 붙여넣기', 'vi 에서 현재 줄을 복사해 아래에 붙여넣으려면 어떻게 할까요?', 'yank(끌어당기다)와 put(놓다)의 첫 글자를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`Ctrl+C` 와 `Ctrl+V` 를 누른다", "명령 모드에서 `yy` 로 복사하고 `p` 로 붙여넣는다", "`copy` 와 `paste` 를 입력한다", "`dd` 와 `u` 를 차례로 입력한다"]', 1, '`yy` 는 현재 줄 복사, `p` 는 커서 아래에 붙여넣기입니다. `dd` 로 지운 줄도 `p` 로 붙여넣을 수 있어 "잘라내기"처럼 쓸 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 7, 'ssh 의 기본 모양', '`ssh ubuntu@host` 에서 `ubuntu` 와 `host` 는 각각 무엇일까요?', '골뱅이 앞은 누구로, 뒤는 어디에 접속할지예요.', NULL, NULL, '[]', 'choice', '["`ubuntu` 는 원격 서버의 사용자 이름, `host` 는 접속할 서버(주소나 이름)", "`ubuntu` 는 서버 이름, `host` 는 사용자 이름", "둘 다 내 컴퓨터의 계정", "`ubuntu` 는 비밀번호, `host` 는 포트"]', 0, '원격 서버에 있는 계정으로 접속하는 것이라 내 컴퓨터의 사용자 이름과는 다를 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 8, 'ssh -p 와 scp -P', '접속 포트를 정할 때 `ssh` 는 `-p`, `scp` 는 `-P` 를 씁니다. 이 차이에 대한 설명으로 알맞은 것은 무엇일까요?', '`scp` 에서 소문자 `-p` 는 다른 일을 해요.', NULL, NULL, '[]', 'choice', '["둘 다 소문자 `-p` 를 쓴다", "둘 다 대문자 `-P` 를 쓴다", "포트는 옵션이 아니라 이름 뒤에 쓴다", "`ssh` 는 소문자 `-p`, `scp` 는 대문자 `-P` 로 포트를 정한다. `scp -p` 는 파일 시간을 보존하는 옵션이라 헷갈리면 안 된다"]', 3, '`scp -p 2222` 로 쓰면 포트가 아니라 시간 보존 옵션으로 읽혀 오류가 납니다. 이 차이는 `ssh` 와 `scp` 의 도움말에서 확인할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 9, 'ssh -i', '`ssh -i ~/.ssh/mykey user@host` 에서 `-i` 는 무엇을 뜻할까요?', 'identity(신원)의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["접속 후 실행할 명령을 지정한다", "포트 번호를 지정한다", "접속할 때 사용할 개인키 파일을 지정한다", "암호화를 끈다"]', 2, '개인키 파일의 권한은 본인만 읽을 수 있게(`chmod 600`) 해야 합니다. 권한이 열려 있으면 ssh 가 키를 무시해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 10, 'scp 방향', '`scp backup.tar.gz user@host:/tmp/` 는 파일을 어느 방향으로 복사할까요?', '앞이 원본, 뒤가 복사 위치예요.', NULL, NULL, '[]', 'choice', '["원격 서버의 파일을 내 컴퓨터로 가져온다", "내 컴퓨터의 `backup.tar.gz` 를 원격 서버의 `/tmp/` 로 보낸다", "원격 서버 안에서 복사한다", "파일을 압축한다"]', 1, '원격에서 가져오려면 두 인자의 순서를 바꿉니다: `scp user@host:/tmp/backup.tar.gz .` 처럼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 11, 'scp -r', '폴더 `backup/` 를 통째로 원격에 복사하려면 `scp` 에 어떤 옵션이 필요할까요?', 'recursive(재귀)의 첫 글자예요.', NULL, NULL, '[]', 'choice', '["`-r` (폴더 안의 모든 것을 반복해서 복사)", "`-f`", "`-x`", "옵션이 필요 없다"]', 0, '`-r` 이 없으면 폴더는 "not a regular file" 같은 오류로 복사되지 않습니다. 큰 폴더는 `rsync` 가 더 효율적일 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 12, 'date 로 날짜 만들기', '`date +%Y-%m-%d` 는 무엇을 출력할까요?', '+ 뒤에 원하는 모양을 적어요.', NULL, NULL, '[]', 'choice', '["현재 시각만 `14:30:00` 모양으로", "달력 전체", "시간대 이름", "`2026-10-31` 처럼 연-월-일 모양의 오늘 날짜"]', 3, '`%Y` 는 네 자리 연도, `%m` 은 월, `%d` 는 일입니다. 백업 파일 이름에 날짜를 넣을 때 자주 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 13, '서비스는 떠 있는데 접속이 안 돼요', '서버에서 `ss -tln` 으로 보면 서비스가 `LISTEN` 인데, 다른 컴퓨터에서 접속하면 시간이 지나도 응답이 없습니다. 의심할 것은 무엇일까요?', '문이 열려 있어도 문지기가 막을 수 있어요.', NULL, NULL, '[]', 'choice', '["디스크가 가득 찼다", "`sudo` 권한이 없다", "서버의 방화벽이 그 포트를 막고 있을 수 있다. 방화벽 규칙을 확인하고 필요한 포트를 허용한다", "파일 이름이 길다"]', 2, '`Connection refused` 는 서비스가 없다는 뜻이고, 응답 없이 기다리다 끝나는 증상은 방화벽이 패킷을 버리는 경우가 흔합니다. 방화벽 도구는 배포판마다 `ufw`, `firewalld` 등으로 달라요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 14, 'os-release 와 uname', '서버의 배포판 이름과 버전(예: Ubuntu 22.04)을 확인하려면 어떤 파일을 볼까요?', '운영체제의 정보를 담은 파일이에요.', NULL, NULL, '[]', 'choice', '["`cat /etc/passwd`", "`cat /etc/os-release`", "`cat /var/log/syslog`", "`cat ~/.bashrc`"]', 1, '`uname -r` 은 커널 버전, `/etc/os-release` 는 배포판 이름과 버전을 알려 줍니다. 패키지나 문서를 고를 때 가장 먼저 확인하는 정보예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 15, '저장하고 나가기', 'vi 에서 **저장하고 종료**하는 명령입니다. 콜론 뒤를 채우세요.', '"write" 와 "quit" 의 첫 글자를 이어 붙여요.', NULL, NULL, '[]', 'fill', '["wq", "q!", "quit", "save"]', NULL, '`Esc` 로 명령 모드에서 콜론으로 시작하는 명령을 입력하고 Enter 를 누릅니다.', '[0]', ':{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 16, '변경 버리고 나가기', 'vi 에서 **저장하지 않고 강제 종료**하는 명령입니다. 콜론 뒤를 채우세요.', 'quit 에 느낌표를 붙여요.', NULL, NULL, '[]', 'fill', '["q!", "wq", "w", "save!"]', NULL, '`:w` 는 저장만 하고 종료하지 않는 명령입니다. 변경을 버리려면 느낌표(`!`)가 있어야 해요.', '[0]', ':{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 17, '줄 삭제하기', 'vi 명령 모드에서 **현재 줄을 삭제**하는 키입니다. 빈칸을 채우세요.', 'delete 의 첫 글자를 두 번 눌러요.', NULL, NULL, '[]', 'fill', '["dd", "x", "yy", "p"]', NULL, '`x` 는 글자 하나만 지웁니다. 줄 전체를 지울 때는 `dd` 예요.', '[0]', '{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 18, '줄 복사하기', 'vi 명령 모드에서 **현재 줄을 복사**하는 키입니다. 빈칸을 채우세요.', 'yank 의 첫 글자를 두 번 눌러요.', NULL, NULL, '[]', 'fill', '["yy", "dd", "pp", "cc"]', NULL, '복사한 뒤 붙여넣을 위치로 가서 `p` 를 누르세요. 여러 번 `p` 를 누르면 여러 번 붙여넣어요.', '[0]', '{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 19, '아래쪽으로 검색', 'vi 명령 모드에서 **아래쪽 방향으로 검색**을 시작하는 키입니다. 빈칸을 채우세요.', '`less` 에서도 같은 키를 썼어요.', NULL, NULL, '[]', 'fill', '["/", "?", "!", "#"]', NULL, '`/ERROR` 를 입력하고 Enter 를 누르면 찾습니다. `?` 는 위쪽 방향 검색이에요.', '[0]', '{0}ERROR', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 20, 'ssh 포트 정하기', '포트 `2222` 로 ssh 에 접속하려고 합니다. 옵션을 채우세요.', 'port 의 첫 글자를 소문자로 써요.', NULL, NULL, '[]', 'fill', '["-p", "-P", "-t", "-s"]', NULL, '`ssh` 는 소문자 `-p`, `scp` 는 대문자 `-P` 입니다. 서로 다르니 헷갈리지 마세요.', '[0]', 'ssh {0} 2222 user@host', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 21, 'scp 포트 정하기', '포트 `2222` 로 `scp` 로 파일을 보내려고 합니다. 옵션을 채우세요.', 'ssh 와 달리 대문자예요.', NULL, NULL, '[]', 'fill', '["-P", "-p", "-t", "-s"]', NULL, '`scp -p` 는 파일의 시간 정보를 보존하는 옵션이라 포트 번호를 넘기면 오류가 납니다.', '[0]', 'scp {0} 2222 file.txt user@host:/tmp/', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 22, '폴더 통째로 보내기', '폴더 `backup` 을 **통째로** 원격에 보내려고 합니다. 옵션을 채우세요.', 'recursive 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-r", "-R", "-d", "-a"]', NULL, '`-r` 은 폴더 안을 반복해서 복사합니다. 큰 폴더를 자주 동기화한다면 `rsync` 도 고려하세요.', '[0]', 'scp {0} backup user@host:/tmp/', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 23, '개인키 지정하기', 'ssh 로 접속할 때 **개인키 파일**을 지정하는 옵션입니다. 빈칸을 채우세요.', 'identity 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-i", "-k", "-p", "-f"]', NULL, '`-i` 는 접속에 쓸 키 파일입니다. 자주 쓴다면 `~/.ssh/config` 에 적어 두면 편해요.', '[0]', 'ssh {0} ~/.ssh/mykey user@host', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 24, '오늘 날짜 모양 만들기', '`2026-10-31` 처럼 **연-월-일** 모양으로 날짜를 출력하는 형식을 채우세요.', '연도는 대문자 Y, 월은 소문자 m 이에요.', NULL, NULL, '[]', 'fill', '["%Y-%m-%d", "%y-%M-%d", "Y-m-d", "-%Y%m%d"]', NULL, '`%M` 은 월이 아니라 분(minute)입니다. 대소문자가 다르면 전혀 다른 값이 나와요.', '[0]', 'date +{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 25, '배포판 정보 파일', '서버의 **배포판 이름과 버전**이 적힌 파일을 보려고 합니다. 파일 이름을 채우세요.', '"운영체제 릴리스"를 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["os-release", "os", "version", "distro"]', NULL, '`ID`, `NAME`, `VERSION_ID` 같은 항목이 들어 있어 스크립트에서 배포판을 구분할 때도 씁니다.', '[0]', 'cat /etc/{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 26, 'vi 로 파일 고치고 저장하기', 'vi 로 설정 파일을 고치고 저장하는 순서입니다. 순서에 맞게 놓아 보세요.', '열기 → 입력 모드 → 고치기 → 저장 순서예요.', NULL, NULL, '[]', 'order', '["`vi app.conf` 로 파일을 연다", "`i` 를 눌러 입력 모드로 바꾼다", "내용을 고친다", "`Esc` 를 누르고 `:wq` 로 저장하고 종료한다"]', NULL, '고치기 전에 `cp app.conf app.conf.bak` 으로 백업해 두면 안전합니다. 잘못 고쳤다면 `:q!` 로 버리고 나갈 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 27, '원격에 파일 보내고 확인하기', '파일을 원격 서버에 보내 풀어서 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '보내기 → 접속 → 확인 → 풀기 순서예요.', NULL, NULL, '[]', 'order', '["`scp app.tar.gz user@host:/tmp/` 로 파일을 보낸다", "`ssh user@host` 로 서버에 접속한다", "`ls -l /tmp/app.tar.gz` 로 파일이 도착했는지 확인한다", "`tar -xzf /tmp/app.tar.gz -C /opt/app` 로 풀어서 배치한다"]', NULL, '보낸 뒤 크기를 확인하면 전송이 끊기지 않았는지 알 수 있습니다. 파일을 푼 뒤에는 소유자와 권한도 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 28, '접속이 안 될 때 방화벽 점검', '서비스는 떠 있는데 외부에서 접속이 안 될 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '서비스 확인 → 방화벽 확인 → 허용 → 접속 확인 순서예요.', NULL, NULL, '[]', 'order', '["`ss -tln` 으로 서비스가 그 포트에서 LISTEN 중인지 본다", "서버의 방화벽이 그 포트를 허용하는지 확인한다", "필요하면 그 포트를 허용하는 규칙을 추가한다", "다른 컴퓨터에서 `nc -zv 서버 포트` 로 접속되는지 확인한다"]', NULL, '서비스(LISTEN)와 방화벽은 별개의 점검입니다. 포트를 열 때는 꼭 필요한 포트만 허용하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 146, 29, '서버 정보 파악하기', '처음 접속한 서버의 기본 정보를 파악하는 순서입니다. 순서에 맞게 놓아 보세요.', '이름 → 배포판 → 커널 → CPU·메모리 순서예요.', NULL, NULL, '[]', 'order', '["`hostname` 으로 서버 이름을 본다", "`cat /etc/os-release` 로 배포판과 버전을 본다", "`uname -r` 로 커널 버전을 본다", "`nproc` 과 `free -h` 로 CPU 코어 수와 메모리를 본다"]', NULL, '처음 보는 서버에서는 이 정보를 먼저 정리해 두면 이후 문제를 풀 때 기준이 됩니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 146 AND order_index = 29);
