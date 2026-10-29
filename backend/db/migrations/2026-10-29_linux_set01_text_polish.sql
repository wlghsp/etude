-- 세트 1 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='지금 어느 디렉토리에 있는지 확인하기', description='터미널에서는 항상 어떤 디렉토리(폴더)에서 작업 중인지 알아야 파일을 정확히 다룰 수 있습니다.

현재 작업 중인 디렉토리의 **경로**를 `/tmp/pwd_result.txt` 파일에 저장하세요.', hint='`pwd` 는 현재 디렉토리의 경로를 출력하는 명령입니다. 화면에 나온 결과를 파일에 저장하려면 `>` (리다이렉션)을 씁니다.
형태: `<명령> > <파일>`
확인: `cat /tmp/pwd_result.txt`', solution='pwd > /tmp/pwd_result.txt

# pwd : 현재 디렉토리의 경로를 출력 (print working directory)
# >   : 출력을 화면 대신 파일로 보냄' WHERE quest_set_id = 1 AND order_index = 1;
UPDATE quest SET title='디렉토리를 이동한 뒤 위치 확인하기', description='`cd` 로 디렉토리를 옮겨 다니는 것은 터미널 사용의 기본입니다.

1. `/tmp` 디렉토리로 이동합니다.
2. 이동한 뒤의 현재 위치를 `/tmp/pwd_result.txt` 에 저장합니다.', hint='`cd <경로>` 로 이동하고, 그다음 `pwd > /tmp/pwd_result.txt` 로 저장합니다. 두 명령을 한 줄에 이어 쓰려면 `&&` 를 씁니다(앞 명령이 성공하면 뒤 명령 실행).', solution='cd /tmp && pwd > /tmp/pwd_result.txt

# cd : 디렉토리 이동 (change directory)' WHERE quest_set_id = 1 AND order_index = 2;
UPDATE quest SET title='디렉토리의 파일 목록 저장하기', description='어떤 파일이 있는지 보는 것이 파일 작업의 첫걸음입니다.

`/etc` 디렉토리에 있는 파일과 디렉토리의 **이름 목록**을 `/tmp/ls_result.txt` 에 저장하세요.', hint='`ls <경로>` 는 그 디렉토리의 목록을 출력합니다. 결과를 `>` 로 파일에 저장하세요.', solution='ls /etc > /tmp/ls_result.txt

# ls : 목록 출력 (list)' WHERE quest_set_id = 1 AND order_index = 3;
UPDATE quest SET title='숨김 파일까지 상세 목록 저장하기', description='이름이 `.` 으로 시작하는 파일은 숨김 파일이라 `ls` 만으로는 보이지 않습니다. 옵션을 붙이면 숨김 파일과 권한·크기·날짜 같은 상세 정보까지 볼 수 있습니다.

`/etc` 디렉토리의 목록을 **숨김 파일 포함, 상세 형식**으로 `/tmp/ls_detail.txt` 에 저장하세요.', hint='`ls -al <경로>` 를 씁니다. `-a` 는 숨김 파일까지(all), `-l` 은 상세 정보(long)입니다. 두 옵션은 `-al` 처럼 붙여 쓸 수 있습니다.', solution='ls -al /etc > /tmp/ls_detail.txt

# -a : 숨김 파일 포함, -l : 상세 출력' WHERE quest_set_id = 1 AND order_index = 4;
UPDATE quest SET title='디렉토리 만들기', description='작업 공간을 정리하려고 새 디렉토리를 만드는 일은 아주 흔합니다.

`/tmp` 안에 `hello` 라는 이름의 디렉토리를 만드세요.', hint='`mkdir <경로>` 로 디렉토리를 만듭니다(make directory). 확인: `ls -ld /tmp/hello`', solution='mkdir /tmp/hello' WHERE quest_set_id = 1 AND order_index = 5;
UPDATE quest SET title='빈 파일 만들기', description='내용이 없는 파일을 미리 만들어 둘 때는 `touch` 를 씁니다.

`/tmp/empty.txt` 라는 **빈 파일**을 만드세요.', hint='`touch <파일>` 은 파일이 없으면 빈 파일을 만들고, 이미 있으면 수정 시각만 갱신합니다.', solution='touch /tmp/empty.txt' WHERE quest_set_id = 1 AND order_index = 6;
UPDATE quest SET title='파일에 내용 쓰기', description='명령의 출력을 파일에 저장하는 `>` 는 설정 파일이나 메모를 만들 때도 씁니다.

`/tmp/answer.txt` 파일을 만들고, 첫 줄에 `done` 을 쓰세요.', hint='`echo <내용>` 은 내용을 그대로 출력하는 명령이고, 이 출력을 `>` 로 파일에 보내면 파일이 만들어집니다. 확인: `cat /tmp/answer.txt`', solution='echo "done" > /tmp/answer.txt

# echo : 글자를 출력, > : 그 출력을 파일에 저장 (파일이 없으면 새로 만듦)' WHERE quest_set_id = 1 AND order_index = 7;
UPDATE quest SET title='숨김 파일 만들기', description='리눅스에서 **파일 이름이 `.` 으로 시작하면 숨김 파일**이 됩니다. 설정 파일(`.bashrc` 등)이 이런 이름을 씁니다.

`/tmp` 안에 `.hidden` 이라는 이름의 빈 파일을 만드세요.', hint='`touch` 로 빈 파일을 만들되 이름 앞에 `.` 을 붙입니다. `ls /tmp` 에는 안 보이고 `ls -a /tmp` 로 보입니다.', solution='touch /tmp/.hidden

# 이름이 . 으로 시작하면 ls 에 기본으로 보이지 않습니다 (ls -a 로 확인)' WHERE quest_set_id = 1 AND order_index = 8;
UPDATE quest SET title='파일 복사하기', description='수정하기 전에 백업을 만들려고 파일을 복사하는 일이 많습니다.

`/tmp/answer.txt` 파일을 `/tmp/backup.txt` 로 복사하세요. 원본은 그대로 남아야 합니다.', hint='`cp <원본> <사본>` 입니다(copy). 확인: `ls /tmp` 에 두 파일이 모두 보여야 합니다.', solution='cp /tmp/answer.txt /tmp/backup.txt' WHERE quest_set_id = 1 AND order_index = 9;
UPDATE quest SET title='파일 이름 바꾸기', description='리눅스에는 이름 변경 전용 명령이 없고, 파일을 옮기는 `mv` 로 이름도 바꿉니다.

`/tmp/backup.txt` 파일의 이름을 `/tmp/renamed.txt` 로 바꾸세요.', hint='`mv <현재이름> <새이름>` 입니다(move). 같은 디렉토리에서 이름만 바꾸는 것도 이동의 한 종류로 취급합니다.', solution='mv /tmp/backup.txt /tmp/renamed.txt' WHERE quest_set_id = 1 AND order_index = 10;
