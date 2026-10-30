-- 세트 1: 리눅스 기초 1 — 파일 탐색과 생성 (order 1~10)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (1,  1, '지금 어느 디렉토리에 있는지 확인하기',
   '터미널에서는 항상 어떤 디렉토리(폴더)에서 작업 중인지 알아야 파일을 정확히 다룰 수 있습니다.

현재 작업 중인 디렉토리의 **경로**를 `/tmp/pwd_result.txt` 파일에 저장하세요.',
   '`pwd` 는 현재 디렉토리의 경로를 출력하는 명령입니다. 화면에 나온 결과를 파일에 저장하려면 `>` (리다이렉션)을 씁니다.
형태: `<명령> > <파일>`
확인: `cat /tmp/pwd_result.txt`',
   'pwd > /tmp/pwd_result.txt

# pwd : 현재 디렉토리의 경로를 출력 (print working directory)
# >   : 출력을 화면 대신 파일로 보냄',
   NULL,
   '["sh", "-c", "grep -q / /tmp/pwd_result.txt"]'),

  (1,  2, '디렉토리를 이동한 뒤 위치 확인하기',
   '`cd` 로 디렉토리를 옮겨 다니는 것은 터미널 사용의 기본입니다.

1. `/tmp` 디렉토리로 이동합니다.
2. 이동한 뒤의 현재 위치를 `/tmp/pwd_result.txt` 에 저장합니다.',
   '`cd <경로>` 로 이동하고, 그다음 `pwd > /tmp/pwd_result.txt` 로 저장합니다. 두 명령을 한 줄에 이어 쓰려면 `&&` 를 씁니다(앞 명령이 성공하면 뒤 명령 실행).',
   'cd /tmp && pwd > /tmp/pwd_result.txt

# cd : 디렉토리 이동 (change directory)',
   NULL,
   '["sh", "-c", "grep -q /tmp /tmp/pwd_result.txt"]'),

  (1,  3, '디렉토리의 파일 목록 저장하기',
   '어떤 파일이 있는지 보는 것이 파일 작업의 첫걸음입니다.

`/etc` 디렉토리에 있는 파일과 디렉토리의 **이름 목록**을 `/tmp/ls_result.txt` 에 저장하세요.',
   '`ls <경로>` 는 그 디렉토리의 목록을 출력합니다. 결과를 `>` 로 파일에 저장하세요.',
   'ls /etc > /tmp/ls_result.txt

# ls : 목록 출력 (list)',
   NULL,
   '["sh", "-c", "grep -q passwd /tmp/ls_result.txt"]'),

  (1,  4, '숨김 파일까지 상세 목록 저장하기',
   '이름이 `.` 으로 시작하는 파일은 숨김 파일이라 `ls` 만으로는 보이지 않습니다. 옵션을 붙이면 숨김 파일과 권한·크기·날짜 같은 상세 정보까지 볼 수 있습니다.

`/etc` 디렉토리의 목록을 **숨김 파일 포함, 상세 형식**으로 `/tmp/ls_detail.txt` 에 저장하세요.',
   '`ls -al <경로>` 를 씁니다. `-a` 는 숨김 파일까지(all), `-l` 은 상세 정보(long)입니다. 두 옵션은 `-al` 처럼 붙여 쓸 수 있습니다.',
   'ls -al /etc > /tmp/ls_detail.txt

# -a : 숨김 파일 포함, -l : 상세 출력',
   NULL,
   '["sh", "-c", "grep -q ^total /tmp/ls_detail.txt"]'),

  (1,  5, '디렉토리 만들기',
   '작업 공간을 정리하려고 새 디렉토리를 만드는 일은 아주 흔합니다.

`/tmp` 안에 `hello` 라는 이름의 디렉토리를 만드세요.',
   '`mkdir <경로>` 로 디렉토리를 만듭니다(make directory). 확인: `ls -ld /tmp/hello`',
   'mkdir /tmp/hello',
   NULL,
   '["test", "-d", "/tmp/hello"]'),

  (1,  6, '빈 파일 만들기',
   '내용이 없는 파일을 미리 만들어 둘 때는 `touch` 를 씁니다.

`/tmp/empty.txt` 라는 **빈 파일**을 만드세요.',
   '`touch <파일>` 은 파일이 없으면 빈 파일을 만들고, 이미 있으면 수정 시각만 갱신합니다.',
   'touch /tmp/empty.txt',
   NULL,
   '["test", "-f", "/tmp/empty.txt"]'),

  (1,  7, '파일에 내용 쓰기',
   '명령의 출력을 파일에 저장하는 `>` 는 설정 파일이나 메모를 만들 때도 씁니다.

`/tmp/answer.txt` 파일을 만들고, 첫 줄에 `done` 을 쓰세요.',
   '`echo <내용>` 은 내용을 그대로 출력하는 명령이고, 이 출력을 `>` 로 파일에 보내면 파일이 만들어집니다. 확인: `cat /tmp/answer.txt`',
   'echo "done" > /tmp/answer.txt

# echo : 글자를 출력, > : 그 출력을 파일에 저장 (파일이 없으면 새로 만듦)',
   NULL,
   '["grep", "-q", "done", "/tmp/answer.txt"]'),

  (1,  8, '숨김 파일 만들기',
   '리눅스에서 **파일 이름이 `.` 으로 시작하면 숨김 파일**이 됩니다. 설정 파일(`.bashrc` 등)이 이런 이름을 씁니다.

`/tmp` 안에 `.hidden` 이라는 이름의 빈 파일을 만드세요.',
   '`touch` 로 빈 파일을 만들되 이름 앞에 `.` 을 붙입니다. `ls /tmp` 에는 안 보이고 `ls -a /tmp` 로 보입니다.',
   'touch /tmp/.hidden

# 이름이 . 으로 시작하면 ls 에 기본으로 보이지 않습니다 (ls -a 로 확인)',
   NULL,
   '["test", "-f", "/tmp/.hidden"]'),

  (1,  9, '파일 복사하기',
   '수정하기 전에 백업을 만들려고 파일을 복사하는 일이 많습니다.

`/tmp/answer.txt` 파일을 `/tmp/backup.txt` 로 복사하세요. 원본은 그대로 남아야 합니다.',
   '`cp <원본> <사본>` 입니다(copy). 확인: `ls /tmp` 에 두 파일이 모두 보여야 합니다.',
   'cp /tmp/answer.txt /tmp/backup.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["test", "-f", "/tmp/backup.txt"]'),

  (1, 10, '파일 이름 바꾸기',
   '리눅스에는 이름 변경 전용 명령이 없고, 파일을 옮기는 `mv` 로 이름도 바꿉니다.

`/tmp/backup.txt` 파일의 이름을 `/tmp/renamed.txt` 로 바꾸세요.',
   '`mv <현재이름> <새이름>` 입니다(move). 같은 디렉토리에서 이름만 바꾸는 것도 이동의 한 종류로 취급합니다.',
   'mv /tmp/backup.txt /tmp/renamed.txt',
   '["sh", "-c", "echo done > /tmp/backup.txt"]',
   '["test", "-f", "/tmp/renamed.txt"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (1, 11, '상대 경로로 위로 올라가며 파일 만들기',
   '경로는 두 가지로 씁니다. **절대 경로**는 `/` 로 시작해서 항상 같은 곳을 가리키고, **상대 경로**는 **지금 있는 위치를 기준**으로 합니다. 상대 경로에서 `.` 은 지금 디렉터리, `..` 은 **한 단계 위** 디렉터리입니다.

`/tmp/a/b/c` 디렉터리가 있습니다. `cd` 로 `/tmp/a/b/c` 에 들어간 뒤, **절대 경로를 쓰지 말고 상대 경로(`../..`)만 써서** `/tmp/a/x.txt` 빈 파일을 만드세요.

완료 조건: `/tmp/a/x.txt` 가 있어야 합니다.',
   '`/tmp/a/b/c` 에서 `..` 는 `/tmp/a/b`, `../..` 는 `/tmp/a` 입니다. 그래서 `touch ../../x.txt` 는 `/tmp/a/x.txt` 를 만듭니다. (`cd` 는 이동, `touch` 는 빈 파일 만들기) 지금 위치는 `pwd` 로 확인하세요. 두 명령은 `&&` 로 이을 수 있습니다.',
   'cd /tmp/a/b/c && touch ../../x.txt

# .. : 한 단계 위 디렉터리, ../.. : 두 단계 위
# 상대 경로는 지금 위치를 기준으로 해석된다
ls /tmp/a',
   '["sh", "-c", "mkdir -p /tmp/a/b/c"]',
   '["sh", "-c", "[ -f /tmp/a/x.txt ]"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (1, 13, '직전 명령의 종료 코드 확인하기 ($?)',
   '명령은 끝날 때 성공(`0`)인지 실패(`0` 이 아닌 값)인지를 **숫자 하나**로 남깁니다. 이 숫자가 **종료 코드**이고, 쉘은 **직전 명령의 종료 코드**를 `$?` 에 담아 둡니다. `&&` 와 `||` 가 바로 이 값을 보고 움직입니다.

없는 디렉터리 `/no/such/dir` 을 `ls` 로 열면 실패합니다. 실행한 **직후**의 종료 코드를 `/tmp/rc.txt` 에 저장하세요.

완료 조건: 파일에 `ls` 가 남긴 종료 코드(`2`)가 들어 있어야 합니다.',
   '`ls /no/such/dir; echo $? > /tmp/rc.txt` 입니다. (`;` 는 앞 명령이 끝난 뒤 다음 명령을 실행, `$?` 는 바로 직전 명령의 종료 코드) `$?` 는 다음 명령을 실행하면 덮어써지므로 **실패한 명령 바로 뒤에** 확인해야 합니다. 성공하면 `0` 입니다.',
   'ls /no/such/dir; echo $? > /tmp/rc.txt

# $? : 직전 명령의 종료 코드 (성공 0, 실패는 0 이 아닌 값)
# ls 는 대상이 없으면 2 를 돌려준다
cat /tmp/rc.txt',
   '["sh", "-c", null]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/rc.txt)\\" = 2 ]"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (1, 14, '--help 로 옵션 찾아 쓰기',
   '명령의 옵션을 전부 외울 필요는 없습니다. **`명령 --help`** 는 사용법과 옵션 목록을 보여 줍니다. 필요한 옵션은 도움말에서 찾아 쓰면 됩니다.

`/tmp/sz` 에는 크기가 다른 파일 세 개가 있습니다. `ls` 의 도움말에서 **크기순으로 정렬**하는 옵션을 찾아서, 큰 파일이 맨 위에 오도록 `ls -l` 형식의 목록을 `/tmp/ls_size.txt` 에 저장하세요.

완료 조건: 파일에서 가장 큰 파일(`b_big`)이 가장 먼저 나와야 합니다. (`total` 줄은 제외)',
   '도움말은 길어서 `|` 로 `grep` 에 넘겨 필요한 줄만 봅니다. 예: `ls --help | grep -i sort` 로 정렬 관련 옵션을 찾으세요. 크기순으로 정렬하는 옵션을 `-l`(자세히 보기)과 함께 쓰고, 결과를 `>` 로 저장합니다. 옵션을 안 주면 이름순으로 나옵니다.',
   'ls --help | grep -i sort   # 정렬 옵션 찾기 → -S : 크기가 큰 순서
ls -lS /tmp/sz > /tmp/ls_size.txt

# -l : 자세히 보기, -S : 파일 크기 큰 순서로 정렬
cat /tmp/ls_size.txt',
   '["sh", "-c", "mkdir -p /tmp/sz && head -c 3000 /dev/zero > /tmp/sz/b_big && head -c 2000 /dev/zero > /tmp/sz/c_mid && head -c 10 /dev/zero > /tmp/sz/a_small"]',
   '["sh", "-c", "[ \\"$(grep -v ''^total'' /tmp/ls_size.txt | head -n 1 | awk ''{print $NF}'')\\" = b_big ]"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation) VALUES
  (1, 12, '상대 경로 ../.. 가 가리키는 곳 읽기',
   '지금 위치가 `/tmp/h/user/project/src` 일 때 `cat ../../notes.txt` 가 읽는 파일은 어느 것일까요? 이 위치의 각 디렉터리에는 `notes.txt` 가 하나씩 있고 내용이 다릅니다. 터미널에서 `cd /tmp/h/user/project/src` 로 이동해 `pwd` 로 위치를 확인하고, `cat ../../notes.txt` 를 직접 실행해서 확인해 보세요.

`../../notes.txt` 가 가리키는 파일을 고르세요.',
   '`..` 는 **한 단계 위** 디렉터리입니다. `src` 에서 `..` 는 `project`, `../..` 는 그 위입니다. 각 파일에 어느 디렉터리의 것인지 적혀 있으니 `cat` 으로 읽어 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`/tmp/h/user/project/src/notes.txt` (지금 위치의 파일)", "`/tmp/h/user/project/notes.txt`", "`/tmp/h/user/notes.txt`", "`/tmp/h/notes.txt`"]',
   2,
   '정답은 **C `/tmp/h/user/notes.txt`** 입니다. `src` 에서 `..` 는 `project`, `../..` 는 `user` 이므로 `../../notes.txt` 는 `user` 디렉터리의 `notes.txt` 입니다.

**원리:** 상대 경로는 **지금 있는 디렉터리(작업 디렉터리)** 를 출발점으로 해석됩니다. `..` 는 한 단계 위(부모 디렉터리)를 뜻해서, `../..` 는 두 번 올라갑니다. 같은 `../../notes.txt` 도 어디서 실행하느냐에 따라 다른 파일을 가리키므로, 헷갈릴 때는 `pwd` 로 지금 위치부터 확인합니다. 절대 경로(`/` 로 시작)는 어디서 실행해도 같은 파일입니다.

- A 지금 위치의 파일은 `./notes.txt` 또는 `notes.txt` 로 가리킵니다. `..` 가 붙으면 위로 올라갑니다.
- B `..` 한 번(`../notes.txt`)이 가리키는 파일입니다. `../..` 는 한 번 더 올라갑니다.
- D `../../..` 로 세 번 올라가야 닿습니다.

확인: `cd /tmp/h/user/project/src; cat ../../notes.txt`');
