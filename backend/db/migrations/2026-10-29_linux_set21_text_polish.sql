-- 세트 21 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='와일드카드(*)로 파일 개수 세기', description='`*` 는 ''아무 글자나 여러 개''를 뜻하는 **와일드카드(glob)** 입니다. 파일 이름의 일부만으로 여러 파일을 한꺼번에 지정할 때 씁니다.

`/tmp/g` 디렉토리에는 `a1.txt`, `a2.txt`, `b1.txt`, `c.log` 가 있습니다. 이 중 `.txt` 로 끝나는 파일의 **개수**를 숫자만 `/tmp/g_count.txt` 에 저장하세요.', hint='`ls /tmp/g/*.txt` 는 `.txt` 로 끝나는 파일만 나열합니다. 줄 수를 세는 `wc -l` 을 파이프(`|`)로 이으세요.', solution='ls /tmp/g/*.txt | wc -l > /tmp/g_count.txt

# *.txt : .txt 로 끝나는 모든 이름
# wc -l : 줄 수 세기' WHERE quest_set_id = 21 AND order_index = 1;
UPDATE quest SET title='? 와 [ ] 로 파일 이름 패턴 고르기', description='와일드카드에는 `*` 외에도 `?`(글자 **하나**)와 `[0-9]`(숫자 **하나**)가 있어 더 정확히 고를 수 있습니다.

`/tmp/g` 에는 `a1.txt`, `a2.txt`, `ab.txt`, `b1.txt`, `c.log` 가 있습니다. 이름이 `a` + **숫자 한 글자** + `.txt` 인 파일의 이름만 정렬해서 `/tmp/a_files.txt` 에 저장하세요. (`ab.txt` 는 제외)', hint='패턴 `a[0-9].txt` 는 `a` 다음에 숫자 한 글자가 오는 이름입니다. `ls /tmp/g/a[0-9].txt` 는 경로까지 나오므로 `xargs -n1 basename` 으로 이름만 남기거나, `cd /tmp/g` 로 이동한 뒤 `ls` 하세요.', solution='ls /tmp/g/a[0-9].txt | xargs -n1 basename > /tmp/a_files.txt

# [0-9] : 숫자 한 글자 (? 는 아무 글자 한 개)
# basename : 경로에서 파일 이름만' WHERE quest_set_id = 21 AND order_index = 2;
UPDATE quest SET title='작은따옴표와 큰따옴표의 차이', description='쉘에서 따옴표 종류에 따라 `$변수` 의 처리가 달라집니다. 스크립트가 예상과 다르게 동작할 때 자주 원인이 됩니다.

`GREETING=hi` 변수를 만든 뒤
1. `echo ''$GREETING''` 의 출력을 `/tmp/single.txt` 에
2. `echo "$GREETING"` 의 출력을 `/tmp/double.txt` 에
저장하세요. 두 결과가 어떻게 다른지 확인해 보세요.', hint='작은따옴표 `''...''` 는 안의 글자를 **그대로** 둡니다. 큰따옴표 `"..."` 는 `$변수` 를 값으로 **바꿉니다**. 변수는 `GREETING=hi` 처럼 `=` 양쪽에 공백 없이 만듭니다.', solution='GREETING=hi
echo ''$GREETING'' > /tmp/single.txt   # $GREETING 글자 그대로
echo "$GREETING" > /tmp/double.txt   # hi 로 치환' WHERE quest_set_id = 21 AND order_index = 3;
UPDATE quest SET title='명령의 결과를 변수에 담아 쓰기', description='명령의 출력을 변수에 담아 다시 쓰는 것을 **명령 치환**이라고 하며 스크립트의 핵심 기능입니다.

1. `/etc` 안의 항목 개수를 변수 `count` 에 담습니다.
2. `count=개수` 형태(예: `count=57`)로 `/tmp/count.txt` 에 저장합니다.', hint='`변수=$(명령)` 으로 명령의 출력을 변수에 담습니다. `/etc` 의 항목 개수는 `ls /etc | wc -l` 입니다. 저장은 `echo "count=$count"` 를 `>` 로 파일에 보내세요.', solution='count=$(ls /etc | wc -l)
echo "count=$count" > /tmp/count.txt

# $( ) : 안의 명령을 실행한 결과로 바뀜' WHERE quest_set_id = 21 AND order_index = 4;
UPDATE quest SET title='find 결과를 xargs 로 넘겨 처리하기', description='`find` 로 찾은 파일 목록을 다른 명령(삭제 등)에 **인자로 넘기려면** `xargs` 를 씁니다.

`/tmp/x` 에 `1.tmp`, `2.tmp`, `3.tmp`, `keep.md` 가 있습니다. `.tmp` 파일을 모두 삭제하세요. `keep.md` 는 남겨야 합니다.', hint='`find /tmp/x -name ''*.tmp''` 로 대상을 먼저 확인합니다. 그 결과를 `| xargs rm` 에 연결하면 찾은 파일들이 `rm` 의 인자로 전달됩니다.', solution='# 대상 확인
find /tmp/x -name ''*.tmp''

# 삭제
find /tmp/x -name ''*.tmp'' | xargs rm

# xargs : 앞 명령의 출력을 뒤 명령의 인자로 넘김' WHERE quest_set_id = 21 AND order_index = 5;
UPDATE quest SET title='화면과 파일에 동시에 쓰기 (tee)', description='`tee` 는 입력을 **화면에 출력하면서 동시에** 파일에도 저장합니다. 결과를 보면서 기록을 남길 때 씁니다.

`echo hello` 의 출력을 화면에 보이면서, 동시에 `/tmp/tee1.txt` 와 `/tmp/tee2.txt` 두 파일에 저장하세요.', hint='`<명령> | tee <파일1> <파일2>` 입니다. 파이프(`|`)로 앞 명령의 출력을 `tee` 에 넘깁니다.', solution='echo hello | tee /tmp/tee1.txt /tmp/tee2.txt

# tee : 받은 입력을 화면과 파일(여러 개 가능)에 모두 출력' WHERE quest_set_id = 21 AND order_index = 6;
UPDATE quest SET title='두 파일의 차이 비교하기', description='설정 파일을 바꾼 뒤 무엇이 달라졌는지 확인하는 일은 매우 흔합니다.

`/tmp/v1.conf` 와 `/tmp/v2.conf` 의 **차이**를 `/tmp/diff.txt` 에 저장하세요.', hint='`diff <파일1> <파일2>` 는 다른 줄만 보여 줍니다. `<` 로 시작하는 줄은 첫 번째 파일에만, `>` 로 시작하는 줄은 두 번째 파일에만 있는 내용입니다.', solution='diff /tmp/v1.conf /tmp/v2.conf > /tmp/diff.txt

# < : 첫 번째 파일의 줄, > : 두 번째 파일의 줄' WHERE quest_set_id = 21 AND order_index = 7;
UPDATE quest SET title='명령이 실제로 어디에 있는지 찾기', description='같은 이름의 명령이 여러 곳에 있거나 PATH 가 꼬이면 엉뚱한 명령이 실행됩니다. 실제 실행 파일의 위치를 확인하는 것이 PATH 문제를 풀 때의 첫 단계입니다.

`ls` 명령이 실제로 설치된 **경로**를 `/tmp/ls_path.txt` 에 저장하세요.', hint='`which <명령이름>` 또는 `command -v <명령이름>` 이 경로를 알려 줍니다.', solution='which ls > /tmp/ls_path.txt

# which : PATH 에서 실행될 파일의 위치를 찾음' WHERE quest_set_id = 21 AND order_index = 8;
UPDATE quest SET title='별칭(alias) 영구 등록하기', description='긴 명령을 짧게 줄여 쓰는 것이 **별칭(alias)** 입니다. 현재 터미널에만 쓰면 닫을 때 사라지므로, 설정 파일에 적어 두어야 항상 적용됩니다.

`ll` 을 입력하면 `ls -la` 가 실행되도록 별칭을 `~/.bashrc` 에 등록하세요.', hint='`~/.bashrc` 는 새 터미널을 열 때마다 읽는 설정 파일입니다. 이 파일 끝에 `alias ll=''ls -la''` 한 줄을 추가합니다. 현재 터미널에 바로 적용하려면 `source ~/.bashrc` 를 실행하세요.', solution='echo "alias ll=''ls -la''" >> ~/.bashrc
source ~/.bashrc    # 지금 터미널에도 바로 적용

# >> : 파일 끝에 이어쓰기' WHERE quest_set_id = 21 AND order_index = 9;
UPDATE quest SET title='사용자 ID(UID) 확인하기', description='리눅스는 사용자를 이름이 아닌 숫자 **UID** 로 구분합니다. 파일 권한과 프로세스 소유자를 분석할 때 필요합니다.

`deploy` 사용자의 **UID 숫자**만 `/tmp/deploy_uid.txt` 에 저장하세요.', hint='`id -u <사용자>` 는 UID 숫자만 출력합니다. (`id <사용자>` 는 UID, GID, 소속 그룹을 모두 보여 줍니다)', solution='id -u deploy > /tmp/deploy_uid.txt

# 전체 정보: id deploy' WHERE quest_set_id = 21 AND order_index = 10;
UPDATE quest SET title='사용자를 그룹에 추가하기', description='여러 사용자에게 같은 권한을 주려면 사용자를 **그룹**에 넣습니다.

`deploy` 사용자를 `devs` 그룹에 추가하세요. 기존에 속해 있던 그룹은 유지해야 합니다.', hint='`usermod -aG <그룹> <사용자>` 입니다. `-a`(append) 없이 `-G` 만 쓰면 기존 그룹이 **사라지니** 주의하세요. 확인: `id -nG deploy`', solution='usermod -aG devs deploy

# -a : 기존 그룹을 유지하고 추가, -G : 보조 그룹 지정
# 확인
id -nG deploy' WHERE quest_set_id = 21 AND order_index = 11;
UPDATE quest SET title='다른 사용자로 명령 실행하기', description='권한 문제를 재현할 때는 문제의 사용자로 직접 명령을 실행해 봅니다.

`deploy` 사용자의 권한으로 `whoami` 명령을 실행하고, 그 결과를 `/tmp/who.txt` 에 저장하세요.', hint='`su <사용자> -c ''<명령>''` 은 그 사용자로 명령 하나를 실행합니다. root 는 비밀번호 없이 쓸 수 있습니다.', solution='su deploy -c whoami > /tmp/who.txt

# su 사용자 -c 명령 : 그 사용자 권한으로 명령 실행' WHERE quest_set_id = 21 AND order_index = 12;
UPDATE quest SET title='umask 로 새 파일의 기본 권한 정하기', description='`umask` 는 새로 만드는 파일에서 **빼 버릴 권한**을 정합니다. 민감한 파일을 만들 때 다른 사용자가 못 읽게 하는 데 씁니다.

`umask` 를 `077` 로 정한 뒤 `/tmp/private.txt` 를 만들어, **소유자만 읽고 쓸 수 있는(600)** 파일이 되게 하세요.', hint='`umask 077` 은 그룹과 다른 사용자의 모든 권한을 뺍니다. 설정한 **같은 셸에서 이어서** `touch /tmp/private.txt` 를 실행해야 적용됩니다. 확인: `ls -l /tmp/private.txt`', solution='umask 077
touch /tmp/private.txt

# 파일 기본 권한 666 에서 077 을 빼 600(rw-------)이 됩니다' WHERE quest_set_id = 21 AND order_index = 13;
UPDATE quest SET title='하드링크 만들기', description='하드링크는 같은 파일 내용을 **다른 이름으로도 가리키는** 링크입니다. 원본을 지워도 다른 이름이 남아 있으면 내용은 사라지지 않습니다. (심볼릭 링크는 원본이 사라지면 깨집니다)

`/tmp/orig.txt` 의 **하드링크** `/tmp/hard.txt` 를 만드세요.', hint='`ln <원본> <새이름>` (옵션 없음)이 하드링크이고, `ln -s` 가 심볼릭 링크입니다. 확인: `ls -li` 로 두 파일의 inode 번호가 같은지 보세요.', solution='ln /tmp/orig.txt /tmp/hard.txt

# 확인: 두 파일의 inode 번호가 같습니다
ls -li /tmp/orig.txt /tmp/hard.txt' WHERE quest_set_id = 21 AND order_index = 14;
UPDATE quest SET title='파일 크기를 바이트로 확인하기', description='스크립트에서 파일 크기를 숫자로 얻어야 할 때가 있습니다(용량 검사 등).

`/tmp/data.bin` 의 **크기(바이트 숫자만)** 를 `/tmp/size.txt` 에 저장하세요.', hint='`stat -c %s <파일>` 은 크기를 바이트로 출력합니다. (`stat` 은 파일의 상세 정보를 보여 주는 명령이고 `-c` 로 출력 형식을 정합니다)', solution='stat -c %s /tmp/data.bin > /tmp/size.txt

# %s : 크기(size, 바이트)' WHERE quest_set_id = 21 AND order_index = 15;
