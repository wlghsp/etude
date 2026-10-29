-- 세트 16 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='디스크를 가장 많이 차지하는 파일 찾기', description='서버 디스크가 꽉 찼다는 알림이 왔습니다. 원인은 대개 덩치 큰 파일 하나입니다.

`/var/data` 아래(하위 디렉토리 포함)에서 **가장 큰 파일 하나**의 전체 경로를 `/tmp/biggest.txt` 에 저장하세요.
예: `/var/data/x/y.bin`', hint='`find /var/data -type f` 로 파일을 나열하고, 크기와 함께 큰 순으로 정렬합니다.
- `du -b <파일>` : 파일 크기(바이트)를 앞에 붙여 출력
- `find <위치> -type f -exec du -b {} +` : 모든 파일의 크기를 구함
- `sort -rn` : 큰 숫자부터 정렬, `head -n 1` : 1등만, `awk ''{print $2}''` : 경로(2번째 칸)만 뽑기', solution='find /var/data -type f -exec du -b {} + | sort -rn | head -n 1 | awk ''{print $2}'' > /tmp/biggest.txt

# find ... -exec du -b {} + : 모든 파일의 크기를 구함
# sort -rn | head -n 1       : 가장 큰 1개
# awk ''{print $2}''           : ''크기 경로'' 에서 경로만' WHERE quest_set_id = 16 AND order_index = 1;
UPDATE quest SET title='용량을 가장 많이 쓰는 디렉토리 찾기', description='디스크가 부족할 때는 파일 하나하나를 보기 전에 **어느 디렉토리가 큰지**부터 좁혀 갑니다.

`/srv/data` 바로 아래 디렉토리들 중 용량이 가장 큰 디렉토리의 경로를 `/tmp/biggest_dir.txt` 에 저장하세요.
예: `/srv/data/appX`', hint='`du -s <경로>` 는 디렉토리의 총 사용량을 한 줄로 보여 줍니다. `du -s /srv/data/*` 로 하위 디렉토리별 사용량을 구하고, 큰 순으로 정렬(`sort -rn`)해서 1등의 경로(2번째 칸)를 뽑으세요.', solution='du -s /srv/data/* | sort -rn | head -n 1 | awk ''{print $2}'' > /tmp/biggest_dir.txt

# du -s : 디렉토리별 총 사용량(요약)
# 사용량이 큰 순으로 정렬한 뒤 1등의 경로를 저장' WHERE quest_set_id = 16 AND order_index = 2;
UPDATE quest SET title='오래된 로그 파일만 골라 삭제하기', description='로그가 쌓여 디스크를 채우고 있습니다. 최근 로그는 남기고 오래된 것만 지웁니다.

`/var/log/old-app` 에서 **7일보다 오래된** `.log` 파일만 삭제하세요. 최근 파일(`recent.log`)은 남겨야 합니다.', hint='`find <위치> -name ''*.log'' -mtime +7` 은 수정한 지 7일이 넘은 `.log` 파일을 찾습니다.
지우기 전에 `-delete` 없이 먼저 실행해 대상이 맞는지 확인하고, 끝에 `-delete` 를 붙이세요.', solution='# 먼저 대상만 확인
find /var/log/old-app -name ''*.log'' -mtime +7

# 맞으면 삭제
find /var/log/old-app -name ''*.log'' -mtime +7 -delete

# -mtime +7 : 7일보다 오래전에 수정됨' WHERE quest_set_id = 16 AND order_index = 3;
UPDATE quest SET title='CPU 를 가장 많이 쓰는 프로세스 찾기', description='서버가 갑자기 느려졌습니다. 범인은 보통 CPU 를 독점하는 프로세스 하나입니다.

지금 CPU 를 **가장 많이 쓰는 프로세스의 PID** 를 `/tmp/hog_pid.txt` 에 저장하세요. (PID 는 프로세스 번호입니다)', hint='`ps -eo pid,pcpu,args --sort=-pcpu` 는 CPU 사용률(pcpu)이 높은 순서로 프로세스를 보여 줍니다. 1번째 줄은 제목이고 2번째 줄이 1등입니다. 첫 번째 칸이 PID 입니다.
먼저 화면으로 확인한 뒤 `sed -n 2p` 와 `awk ''{print $1}''` 로 뽑아 저장하세요. `top` 으로도 볼 수 있습니다.', solution='ps -eo pid,pcpu --sort=-pcpu | sed -n 2p | awk ''{print $1}'' > /tmp/hog_pid.txt

# --sort=-pcpu : CPU 사용률 내림차순
# sed -n 2p    : 2번째 줄(1등)만
# awk ''{print $1}'' : 첫 칸(PID)만' WHERE quest_set_id = 16 AND order_index = 4;
UPDATE quest SET title='CPU 를 독점하는 프로세스 종료하기', description='원인 프로세스를 찾았으면 종료해서 서버를 살립니다.

지금 CPU 를 계속 쓰고 있는 프로세스를 **찾아서 종료**하세요.', hint='1) `ps -eo pid,pcpu,args --sort=-pcpu | head` 로 PID 를 찾습니다.
2) `kill <PID>` 로 종료를 요청합니다.
종료되었는지 `ps` 로 다시 확인하세요.', solution='# 1) PID 찾기
ps -eo pid,pcpu,args --sort=-pcpu | head

# 2) 종료
kill <PID>

# 한 줄로: 1등 프로세스를 바로 종료
kill $(ps -eo pid,pcpu --sort=-pcpu | sed -n 2p | awk ''{print $1}'')' WHERE quest_set_id = 16 AND order_index = 5;
UPDATE quest SET title='포트를 점유한 프로세스 찾기', description='서비스를 띄우려는데 `8080` 포트가 이미 사용 중이라는 에러가 납니다. 누가 쓰고 있는지 찾습니다.

`8080` 포트를 **대기(listen)** 중인 프로세스의 **PID** 를 `/tmp/port_pid.txt` 에 저장하세요.', hint='`ss -ltnp` 는 대기 중인 TCP 포트(`-l`, `-t`), 숫자 포트(`-n`), 프로세스(`-p`)를 보여 줍니다. 출력의 `users:(("이름",pid=번호,...))` 에서 `pid=` 뒤 숫자가 PID 입니다.
`grep '':8080 ''` 로 줄을 고르고 `grep -o ''pid=[0-9]*''` 와 `cut -d= -f2` 로 숫자만 뽑을 수 있습니다.', solution='ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2 > /tmp/port_pid.txt

# grep -o : 일치한 부분만 출력
# cut -d= -f2 : ''='' 로 나눠 두 번째(번호)만' WHERE quest_set_id = 16 AND order_index = 6;
UPDATE quest SET title='포트를 비워서 서비스를 띄울 수 있게 하기', description='점유한 프로세스를 찾았다면 종료해서 포트를 비웁니다.

`8080` 포트를 쓰고 있는 프로세스를 종료해서 포트를 비우세요.', hint='앞 문제처럼 `ss -ltnp` 로 PID 를 찾고 `kill <PID>` 로 종료합니다. 종료 후 `ss -ltn | grep 8080` 에 아무것도 나오지 않으면 성공입니다.', solution='kill $(ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2)

# 확인: 아무것도 나오지 않아야 합니다
ss -ltn | grep 8080' WHERE quest_set_id = 16 AND order_index = 7;
UPDATE quest SET title='실행 권한 오류(Permission denied) 해결하기', description='배포용 스크립트 `/opt/app/run.sh` 를 `deploy` 사용자가 실행하면 `Permission denied` 가 납니다.

`deploy` 사용자가 이 스크립트를 실행할 수 있게 고치세요.
오류 재현: `su deploy -c /opt/app/run.sh`', hint='먼저 `su deploy -c /opt/app/run.sh` 로 오류를 직접 확인하세요. `ls -l /opt/app/run.sh` 로 권한(`rw-r-----`)을 보면 **실행(x) 권한이 없고**, 다른 사용자는 읽을 수도 없습니다. `chmod` 로 모든 사용자가 읽고 실행할 수 있게 하세요(숫자 `755`).', solution='chmod 755 /opt/app/run.sh

# 755 = 소유자 rwx, 그룹 r-x, 다른 사용자 r-x
# 확인
su deploy -c /opt/app/run.sh' WHERE quest_set_id = 16 AND order_index = 8;
UPDATE quest SET title='쓰기 권한 오류 해결하기', description='`deploy` 사용자가 `/srv/app/logs` 에 로그 파일을 만들지 못합니다.

`deploy` 사용자가 이 디렉토리에 파일을 만들 수 있게 고치세요. 단, 아무나 쓸 수 있게 하는 `777` 권한은 쓰면 안 됩니다.
오류 재현: `su deploy -c ''touch /srv/app/logs/t.log''`', hint='`ls -ld /srv/app/logs` 로 디렉토리의 **소유자**를 보세요. root 소유라서 `deploy` 가 쓸 수 없습니다. 권한을 모두에게 여는 대신, 소유자를 바꾸는 `chown <사용자> <경로>` 가 안전합니다.', solution='chown deploy /srv/app/logs

# 소유자를 deploy 로 바꾸면 deploy 만 쓸 수 있습니다 (777 은 보안상 위험)
# 확인
su deploy -c ''touch /srv/app/logs/t.log''' WHERE quest_set_id = 16 AND order_index = 9;
UPDATE quest SET title='명령이 성공했는지 종료 코드로 확인하기', description='쉘 스크립트는 명령이 성공했는지 **종료 코드**로 판단합니다. `0` 은 성공, 그 외는 실패입니다.

`/var/log/app/app.log` 에 `FATAL` 이 있는지 `grep -q` 로 확인하고, 그 명령의 종료 코드를 `/tmp/exit_code.txt` 에 저장하세요. (이 로그에는 `FATAL` 이 없습니다)', hint='`grep -q <글자> <파일>` 은 화면 출력 없이 종료 코드만 남깁니다 (찾으면 `0`, 못 찾으면 `1`). 직전 명령의 종료 코드는 `$?` 에 들어 있으니, 바로 이어서 `echo $?` 로 저장하세요.', solution='grep -q FATAL /var/log/app/app.log; echo $? > /tmp/exit_code.txt

# ; 로 두 명령을 이어 씁니다
# $? : 직전 명령의 종료 코드 (0=성공/찾음, 1=실패/못 찾음)' WHERE quest_set_id = 16 AND order_index = 10;
UPDATE quest SET title='깨진 심볼릭 링크 찾기', description='심볼릭 링크가 가리키는 원본이 삭제되면 링크는 ''깨진'' 상태가 되어 오류를 일으킵니다.

`/etc/app-links` 안에서 **깨진 심볼릭 링크**의 경로를 정렬해서 `/tmp/broken.txt` 에 저장하세요.', hint='`find <위치> -xtype l` 은 가리키는 대상이 없는(깨진) 링크를 찾습니다. 결과를 `sort` 로 정렬해서 파일에 저장하세요.', solution='find /etc/app-links -xtype l | sort > /tmp/broken.txt

# -xtype l : 링크가 가리키는 대상의 종류가 ''링크''(=대상 없음)인 것' WHERE quest_set_id = 16 AND order_index = 11;
