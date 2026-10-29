-- 세트 21: 리눅스 쉘 기본기와 사용자·권한 (order 1~15)
-- 와일드카드, 인용부호, xargs, tee, diff, which, alias, id, usermod, su, umask, 하드링크, stat. history 는 대화형이라 채점할 수 없어 제외했다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (21,  1, '와일드카드로 파일 개수 세기',
   '/tmp/g 디렉토리의 .txt 파일 개수를 숫자만 /tmp/g_count.txt 에 저장하세요.',
   '* 는 아무 글자나 여러 개와 일치합니다. ls /tmp/g/*.txt 의 결과 줄 수를 wc -l 로 셉니다.',
   'ls /tmp/g/*.txt | wc -l > /tmp/g_count.txt',
   '["sh", "-c", "mkdir -p /tmp/g && cd /tmp/g && touch a1.txt a2.txt b1.txt c.log"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/g_count.txt)\\\" = 3 ]"]'),

  (21,  2, '? 와 [ ] 로 파일 고르기',
   '/tmp/g 디렉토리에서 이름이 a 로 시작하고 그 뒤 한 글자(숫자)가 오는 .txt 파일의 이름만 정렬해서 /tmp/a_files.txt 에 저장하세요.',
   '? 는 글자 하나, [0-9] 는 숫자 하나와 일치합니다. 예: a[0-9].txt (a 다음에 숫자 하나)',
   'ls /tmp/g/a[0-9].txt | xargs -n1 basename > /tmp/a_files.txt',
   '["sh", "-c", "mkdir -p /tmp/g && cd /tmp/g && touch a1.txt a2.txt ab.txt b1.txt c.log"]',
   '["sh", "-c", "[ \\\"$(paste -sd, - < /tmp/a_files.txt)\\\" = a1.txt,a2.txt ]"]'),

  (21,  3, '작은따옴표와 큰따옴표 차이',
   'GREETING=hi 를 설정한 뒤, echo ''$GREETING'' 의 출력을 /tmp/single.txt 에, echo "$GREETING" 의 출력을 /tmp/double.txt 에 저장하세요.',
   '작은따옴표는 안의 글자를 그대로 두고, 큰따옴표는 $변수를 값으로 바꿉니다.',
   'GREETING=hi
echo ''$GREETING'' > /tmp/single.txt
echo "$GREETING" > /tmp/double.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(cat /tmp/single.txt)\\\" = ''$GREETING'' ] && [ \\\"$(cat /tmp/double.txt)\\\" = hi ]"]'),

  (21,  4, '명령 결과를 변수에 담기',
   '/etc 안의 항목 개수를 변수 count 에 담고, count=개수 형태로 /tmp/count.txt 에 저장하세요. 예: count=57',
   'count=$(명령) 으로 명령의 출력을 변수에 담습니다. 개수는 ls /etc | wc -l 입니다.',
   'count=$(ls /etc | wc -l)
echo "count=$count" > /tmp/count.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(cat /tmp/count.txt)\\\" = \\\"count=$(ls /etc | wc -l)\\\" ]"]'),

  (21,  5, 'find 결과를 xargs 로 처리하기',
   '/tmp/x 에서 .tmp 파일을 모두 삭제하세요. keep.md 는 남겨야 합니다.',
   'find 디렉토리 -name ''*.tmp'' | xargs rm 처럼 앞 명령의 출력을 인자로 넘깁니다. (-delete 도 가능하지만 xargs 를 연습해 보세요.)',
   'find /tmp/x -name ''*.tmp'' | xargs rm',
   '["sh", "-c", "mkdir -p /tmp/x && cd /tmp/x && touch 1.tmp 2.tmp 3.tmp keep.md"]',
   '["sh", "-c", "[ -e /tmp/x/keep.md ] && [ -z \\\"$(find /tmp/x -name ''*.tmp'')\\\" ]"]'),

  (21,  6, '화면과 파일 두 곳에 동시에 쓰기',
   'echo hello 의 출력을 화면에 보이면서 동시에 /tmp/tee1.txt 와 /tmp/tee2.txt 두 파일에 저장하세요.',
   'tee 는 입력을 파일로 쓰고 그대로 출력합니다. echo hello | tee 파일1 파일2',
   'echo hello | tee /tmp/tee1.txt /tmp/tee2.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/tee1.txt)\\\" = hello ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/tee2.txt)\\\" = hello ]"]'),

  (21,  7, '두 파일의 차이 보기',
   '/tmp/v1.conf 와 /tmp/v2.conf 의 차이를 /tmp/diff.txt 에 저장하세요.',
   'diff 파일1 파일2 는 다른 줄을 < (첫 파일)와 > (둘째 파일)로 표시합니다.',
   'diff /tmp/v1.conf /tmp/v2.conf > /tmp/diff.txt',
   '["sh", "-c", "{ echo host=localhost; echo port=8080; echo mode=prod; } > /tmp/v1.conf; { echo host=localhost; echo port=9090; echo mode=prod; } > /tmp/v2.conf"]',
   '["sh", "-c", "grep -q ''^< port=8080'' /tmp/diff.txt && grep -q ''^> port=9090'' /tmp/diff.txt"]'),

  (21,  8, '명령의 실제 경로 찾기',
   'ls 명령이 실제로 어디에 있는지 경로를 /tmp/ls_path.txt 에 저장하세요.',
   'which 명령이름 또는 command -v 명령이름 이 경로를 알려 줍니다. PATH 문제를 풀 때 첫 번째로 쓰는 도구입니다.',
   'which ls > /tmp/ls_path.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/ls_path.txt)\\\" = \\\"$(which ls)\\\" ]"]'),

  (21,  9, '별칭(alias) 영구 등록하기',
   'll 을 입력하면 ls -la 가 실행되도록 별칭을 ~/.bashrc 에 등록하세요.',
   'alias ll=''ls -la'' 를 ~/.bashrc 에 한 줄 추가합니다. 새 셸을 열면 적용됩니다 (source ~/.bashrc 로 즉시 적용).',
   'echo "alias ll=''ls -la''" >> ~/.bashrc',
   NULL,
   '["sh", "-c", "bash -ic ''alias ll'' 2>/dev/null | grep -q ''ls -la''"]'),

  (21, 10, '사용자 ID 확인하기',
   'deploy 사용자의 UID 숫자만 /tmp/deploy_uid.txt 에 저장하세요.',
   'id -u 사용자이름 은 UID 를 출력합니다. id 사용자이름 은 UID, GID, 소속 그룹을 모두 보여 줍니다.',
   'id -u deploy > /tmp/deploy_uid.txt',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy"]',
   '["sh", "-c", "[ -s /tmp/deploy_uid.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/deploy_uid.txt)\\\" = \\\"$(id -u deploy)\\\" ]"]'),

  (21, 11, '사용자를 그룹에 추가하기',
   'deploy 사용자를 devs 그룹에 추가하세요. (기존 그룹은 유지해야 합니다.)',
   'usermod -aG 그룹 사용자 에서 -a(append) 를 빼면 기존 그룹이 사라집니다. 확인은 id -nG 사용자.',
   'usermod -aG devs deploy',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy; getent group devs >/dev/null || groupadd devs"]',
   '["sh", "-c", "id -nG deploy | grep -qw devs"]'),

  (21, 12, '다른 사용자로 명령 실행하기',
   'deploy 사용자의 권한으로 whoami 를 실행하고, 결과를 /tmp/who.txt 에 저장하세요.',
   'su 사용자 -c ''명령'' 은 그 사용자로 명령을 실행합니다. root 는 비밀번호 없이 쓸 수 있습니다.',
   'su deploy -c whoami > /tmp/who.txt',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/who.txt)\\\" = deploy ]"]'),

  (21, 13, 'umask 로 기본 권한 정하기',
   'umask 를 077 로 정한 뒤 /tmp/private.txt 를 만들어, 소유자만 읽고 쓸 수 있는(600) 파일이 되게 하세요.',
   'umask 는 새 파일에서 뺄 권한입니다. umask 077; touch 파일 처럼 같은 셸에서 이어서 실행하세요.',
   'umask 077
touch /tmp/private.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(stat -c %a /tmp/private.txt)\\\" = 600 ]"]'),

  (21, 14, '하드링크 만들기',
   '/tmp/orig.txt 의 하드링크 /tmp/hard.txt 를 만드세요. (심볼릭 링크가 아닙니다.)',
   'ln 원본 새이름 (옵션 없음) 이 하드링크입니다. stat 으로 inode 번호와 링크 수를 확인할 수 있습니다.',
   'ln /tmp/orig.txt /tmp/hard.txt',
   '["sh", "-c", "echo data > /tmp/orig.txt; rm -f /tmp/hard.txt"]',
   '["sh", "-c", "[ \\\"$(stat -c %i /tmp/orig.txt)\\\" = \\\"$(stat -c %i /tmp/hard.txt)\\\" ] && [ \\\"$(stat -c %h /tmp/orig.txt)\\\" = 2 ] && [ ! -L /tmp/hard.txt ]"]'),

  (21, 15, '파일 정보에서 크기 뽑기',
   '/tmp/data.bin 의 크기(바이트 숫자만)를 /tmp/size.txt 에 저장하세요.',
   'stat -c %s 파일 은 크기를 바이트로 출력합니다. ls -l 의 5번째 열과도 같습니다.',
   'stat -c %s /tmp/data.bin > /tmp/size.txt',
   '["sh", "-c", "head -c 1234 /dev/zero > /tmp/data.bin"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/size.txt)\\\" = 1234 ]"]');
