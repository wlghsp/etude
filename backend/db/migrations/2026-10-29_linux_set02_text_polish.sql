-- 세트 2 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='파일 삭제하기', description='필요 없는 파일은 `rm` 으로 지웁니다. 주의: 리눅스에는 휴지통이 없어 지운 파일은 복구할 수 없습니다.

`/tmp/renamed.txt` 파일을 삭제하세요.', hint='`rm <파일>` 입니다(remove). 지우기 전에 `ls /tmp/renamed.txt` 로 대상이 맞는지 확인하는 습관을 들이세요.', solution='rm /tmp/renamed.txt' WHERE quest_set_id = 2 AND order_index = 1;
UPDATE quest SET title='디렉토리 삭제하기', description='`rm` 만으로는 디렉토리를 지울 수 없고 **재귀(recursive) 옵션**이 필요합니다. 디렉토리 안의 내용까지 모두 지우므로 경로를 꼭 확인하세요.

`/tmp/hello` 디렉토리를 삭제하세요.', hint='`rm -r <디렉토리>` 입니다. `-r` 은 디렉토리와 그 안의 모든 내용을 지웁니다.', solution='rm -r /tmp/hello

# -r : 디렉토리 안의 내용까지 재귀적으로 삭제' WHERE quest_set_id = 2 AND order_index = 2;
UPDATE quest SET title='파일 내용 출력하기', description='파일의 내용을 터미널에서 확인하는 가장 기본적인 명령은 `cat` 입니다.

`/tmp/answer.txt` 의 내용을 읽어서 `/tmp/cat_result.txt` 에 저장하세요.', hint='`cat <파일>` 은 파일 내용을 화면에 출력합니다. 그 출력을 `>` 로 다른 파일에 저장하세요.', solution='cat /tmp/answer.txt > /tmp/cat_result.txt

# cat : 파일 내용을 출력' WHERE quest_set_id = 2 AND order_index = 3;
UPDATE quest SET title='파일에서 문자열 찾기', description='긴 파일에서 필요한 줄만 골라 볼 때 `grep` 을 씁니다. 로그 분석에서 가장 많이 쓰는 명령입니다.

`/tmp/answer.txt` 에서 `done` 이 들어간 줄을 찾아 `/tmp/grep_result.txt` 에 저장하세요.', hint='`grep "<찾을글자>" <파일>` 은 그 글자가 들어 있는 줄만 출력합니다. 결과를 `>` 로 저장하세요.', solution='grep "done" /tmp/answer.txt > /tmp/grep_result.txt

# grep : 글자가 들어 있는 줄만 골라냄' WHERE quest_set_id = 2 AND order_index = 4;
UPDATE quest SET title='여러 줄 파일 만들기', description='`echo` 는 한 줄만 쓰기 쉽습니다. 여러 줄을 한 번에 쓰려면 줄바꿈 기호 `\\n` 을 해석하는 `printf` 가 편합니다.

`/tmp/multiline.txt` 파일을 만들고 첫 줄에 `line1`, 둘째 줄에 `line2` 를 쓰세요.', hint='`printf "<내용>"` 에서 `\\n` 은 줄바꿈입니다. 각 줄 끝에 `\\n` 을 쓰고 `>` 로 파일에 저장하세요. 확인: `cat /tmp/multiline.txt`', solution='printf "line1\\nline2\\n" > /tmp/multiline.txt

# \\n : 줄바꿈 (printf 는 이를 해석합니다)' WHERE quest_set_id = 2 AND order_index = 5;
UPDATE quest SET title='파일에 실행 권한 주기', description='스크립트나 프로그램을 실행하려면 파일에 **실행(x) 권한**이 있어야 합니다. `ls -l` 의 맨 앞 `-rw-r--r--` 같은 부분이 권한입니다.

`/tmp/answer.txt` 에 실행 권한을 추가하세요.', hint='`chmod +x <파일>` 은 실행 권한을 추가합니다. 확인: `ls -l /tmp/answer.txt` 에서 `x` 가 생겼는지 보세요.', solution='chmod +x /tmp/answer.txt

# chmod : 권한 변경 (change mode), +x : 실행 권한 추가' WHERE quest_set_id = 2 AND order_index = 6;
UPDATE quest SET title='심볼릭 링크 만들기', description='심볼릭 링크는 다른 파일을 가리키는 **바로가기**입니다. 긴 경로를 짧게 쓰거나 버전을 바꿔 가리킬 때 씁니다.

`/tmp/answer.txt` 를 가리키는 심볼릭 링크 `/tmp/link.txt` 를 만드세요.', hint='`ln -s <원본> <링크이름>` 입니다(`-s` 는 symbolic). 확인: `ls -l /tmp/link.txt` 에 `->` 로 원본이 표시됩니다.', solution='ln -s /tmp/answer.txt /tmp/link.txt

# 순서: 원본 먼저, 링크 이름은 나중' WHERE quest_set_id = 2 AND order_index = 7;
UPDATE quest SET title='중첩 디렉토리를 한 번에 만들기', description='`mkdir` 는 중간 디렉토리가 없으면 실패합니다. 깊은 경로를 한 번에 만들 때 쓰는 옵션이 있습니다.

`/tmp/a/b/c` 경로를 한 번에 만드세요. (`/tmp/a`, `/tmp/a/b` 는 아직 없습니다)', hint='`mkdir -p <경로>` 의 `-p`(parents)는 중간 디렉토리까지 모두 만듭니다.', solution='mkdir -p /tmp/a/b/c

# -p : 없는 중간 디렉토리도 함께 생성' WHERE quest_set_id = 2 AND order_index = 8;
UPDATE quest SET title='확장자로 파일 찾기', description='어디에 있는지 모르는 파일은 `find` 로 찾습니다. 서버 점검에서 아주 자주 씁니다.

`/tmp` 아래(하위 디렉토리 포함)에서 확장자가 `.txt` 인 파일을 모두 찾아, 경로 목록을 `/tmp/find_result.txt` 에 저장하세요.', hint='`find <시작경로> -name "<패턴>"` 형태입니다. `*` 는 아무 글자나 뜻하므로 `"*.txt"` 는 `.txt` 로 끝나는 이름입니다. 결과를 `>` 로 저장하세요.', solution='find /tmp -name "*.txt" > /tmp/find_result.txt

# -name : 이름 패턴으로 찾기' WHERE quest_set_id = 2 AND order_index = 9;
UPDATE quest SET title='디렉토리가 차지하는 용량 확인하기', description='디스크가 부족할 때 어느 디렉토리가 얼마나 차지하는지 `du` 로 확인합니다.

`/tmp` 디렉토리의 **전체 사용량**을 `/tmp/du_result.txt` 에 저장하세요.', hint='`du -sh <경로>` 를 씁니다. `-s` 는 하위 항목을 하나하나 보여 주지 않고 합계만(summary), `-h` 는 사람이 읽기 쉬운 단위(KB, MB)입니다.', solution='du -sh /tmp > /tmp/du_result.txt

# -s : 합계만, -h : 읽기 쉬운 단위' WHERE quest_set_id = 2 AND order_index = 10;
