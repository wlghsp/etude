-- 세트 16: 리눅스 장애 진단 실전 (order 1~11)
-- 퀘스트마다 setup_cmd 로 장애 상황을 만들고, 채점은 결과 상태로 판단한다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (16,  1, '디스크를 가장 많이 차지하는 파일 찾기',
   '서버 디스크가 꽉 찼다는 알림이 왔습니다. 원인은 대개 덩치 큰 파일 하나입니다.

`/var/data` 아래(하위 디렉토리 포함)에서 **가장 큰 파일 하나**의 전체 경로를 `/tmp/biggest.txt` 에 저장하세요.
예: `/var/data/x/y.bin`',
   '`find /var/data -type f` 로 파일을 나열하고, 크기와 함께 큰 순으로 정렬합니다.
- `du -b <파일>` : 파일 크기(바이트)를 앞에 붙여 출력
- `find <위치> -type f -exec du -b {} +` : 모든 파일의 크기를 구함
- `sort -rn` : 큰 숫자부터 정렬, `head -n 1` : 1등만, `awk ''{print $2}''` : 경로(2번째 칸)만 뽑기',
   'find /var/data -type f -exec du -b {} + | sort -rn | head -n 1 | awk ''{print $2}'' > /tmp/biggest.txt

# find ... -exec du -b {} + : 모든 파일의 크기를 구함
# sort -rn | head -n 1       : 가장 큰 1개
# awk ''{print $2}''           : ''크기 경로'' 에서 경로만',
   '["sh", "-c", "mkdir -p /var/data/a /var/data/b && dd if=/dev/zero of=/var/data/a/x.bin bs=1k count=100 2>/dev/null && dd if=/dev/zero of=/var/data/b/big.bin bs=1M count=20 2>/dev/null && dd if=/dev/zero of=/var/data/b/y.bin bs=1k count=300 2>/dev/null"]',
   '["sh", "-c", "[ \\"$(cat /tmp/biggest.txt)\\" = /var/data/b/big.bin ]"]'),

  (16,  2, '용량을 가장 많이 쓰는 디렉토리 찾기',
   '디스크가 부족할 때는 파일 하나하나를 보기 전에 **어느 디렉토리가 큰지**부터 좁혀 갑니다.

`/srv/data` 바로 아래 디렉토리들 중 용량이 가장 큰 디렉토리의 경로를 `/tmp/biggest_dir.txt` 에 저장하세요.
예: `/srv/data/appX`',
   '`du -s <경로>` 는 디렉토리의 총 사용량을 한 줄로 보여 줍니다. `du -s /srv/data/*` 로 하위 디렉토리별 사용량을 구하고, 큰 순으로 정렬(`sort -rn`)해서 1등의 경로(2번째 칸)를 뽑으세요.',
   'du -s /srv/data/* | sort -rn | head -n 1 | awk ''{print $2}'' > /tmp/biggest_dir.txt

# du -s : 디렉토리별 총 사용량(요약)
# 사용량이 큰 순으로 정렬한 뒤 1등의 경로를 저장',
   '["sh", "-c", "mkdir -p /srv/data/app1 /srv/data/app2 /srv/data/app3 && dd if=/dev/zero of=/srv/data/app1/f bs=1M count=1 2>/dev/null && dd if=/dev/zero of=/srv/data/app2/f bs=1M count=15 2>/dev/null && dd if=/dev/zero of=/srv/data/app3/f bs=1M count=3 2>/dev/null"]',
   '["sh", "-c", "[ \\"$(cat /tmp/biggest_dir.txt)\\" = /srv/data/app2 ]"]'),

  (16,  3, '오래된 로그 파일만 골라 삭제하기',
   '로그가 쌓여 디스크를 채우고 있습니다. 최근 로그는 남기고 오래된 것만 지웁니다.

`/var/log/old-app` 에서 **7일보다 오래된** `.log` 파일만 삭제하세요. 최근 파일(`recent.log`)은 남겨야 합니다.',
   '`find <위치> -name ''*.log'' -mtime +7` 은 수정한 지 7일이 넘은 `.log` 파일을 찾습니다.
지우기 전에 `-delete` 없이 먼저 실행해 대상이 맞는지 확인하고, 끝에 `-delete` 를 붙이세요.',
   '# 먼저 대상만 확인
find /var/log/old-app -name ''*.log'' -mtime +7

# 맞으면 삭제
find /var/log/old-app -name ''*.log'' -mtime +7 -delete

# -mtime +7 : 7일보다 오래전에 수정됨',
   '["sh", "-c", "mkdir -p /var/log/old-app && cd /var/log/old-app && touch recent.log && touch -d ''30 days ago'' old1.log old2.log && touch -d ''10 days ago'' old3.log"]',
   '["sh", "-c", "[ -f /var/log/old-app/recent.log ] && [ ! -e /var/log/old-app/old1.log ] && [ ! -e /var/log/old-app/old2.log ] && [ ! -e /var/log/old-app/old3.log ]"]'),

  (16,  4, 'CPU 를 가장 많이 쓰는 프로세스 찾기',
   '서버가 갑자기 느려졌습니다. 범인은 보통 **CPU 를 독점하는 프로세스 하나**입니다. 지금 그런 프로세스가 돌고 있습니다.

`PID, CPU 사용률, 명령` 세 열을 **CPU 사용률이 큰 순서**로 정렬해서 `/tmp/cpu_top.txt` 에 저장하세요. (제목 줄 포함)

완료 조건: 제목 바로 아래(2번째 줄)가 CPU 를 가장 많이 쓰는 프로세스여야 합니다.',
   '`ps -eo pid,pcpu,args --sort=-pcpu` 는 CPU 사용률(`pcpu`)이 큰 순서로 프로세스를 보여 줍니다. (`-eo` 는 모든 프로세스를 보여 줄 열을 지정, `--sort=-열이름` 은 큰 값이 먼저 오는 정렬) 결과를 `>` 로 파일에 저장하세요. `top` 으로도 확인할 수 있습니다.',
   'ps -eo pid,pcpu,args --sort=-pcpu > /tmp/cpu_top.txt

# --sort=-pcpu : CPU 사용률 내림차순. 2번째 줄이 1등입니다
# 확인: head -n 3 /tmp/cpu_top.txt',
   '["sh", "-c", "nohup sh -c ''while :; do :; done'' >/dev/null 2>&1 & sleep 2"]',
   '["sh", "-c", "[ \\"$(awk ''NR==2 {print $1}'' /tmp/cpu_top.txt)\\" = \\"$(pgrep -f ''[w]hile :; do'' | head -n 1)\\" ]"]'),

  (16,  5, 'CPU 를 독점하는 프로세스 종료하기',
   '원인 프로세스를 찾았으면 종료해서 서버를 살립니다.

지금 CPU 를 계속 쓰고 있는 프로세스를 **찾아서 종료**하세요.',
   '1) `ps -eo pid,pcpu,args --sort=-pcpu | head` 로 PID 를 찾습니다.
2) `kill <PID>` 로 종료를 요청합니다.
종료되었는지 `ps` 로 다시 확인하세요.',
   '# 1) PID 찾기
ps -eo pid,pcpu,args --sort=-pcpu | head

# 2) 종료
kill <PID>

# 한 줄로: 1등 프로세스를 바로 종료
kill $(ps -eo pid,pcpu --sort=-pcpu | sed -n 2p | awk ''{print $1}'')',
   '["sh", "-c", "nohup sh -c ''while :; do :; done'' >/dev/null 2>&1 & sleep 2"]',
   '["sh", "-c", "! pgrep -f ''[w]hile :; do'' >/dev/null"]'),

  (16,  6, '포트를 점유한 프로세스 찾기',
   '서비스를 띄우려는데 `8080` 포트가 이미 사용 중이라는 에러가 납니다. 누가 쓰고 있는지 찾습니다.

`8080` 포트를 **대기(listen)** 중인 프로세스의 **PID** 를 `/tmp/port_pid.txt` 에 저장하세요.',
   '`ss -ltnp` 는 대기 중인 TCP 포트(`-l`, `-t`), 숫자 포트(`-n`), 프로세스(`-p`)를 보여 줍니다. 출력의 `users:(("이름",pid=번호,...))` 에서 `pid=` 뒤 숫자가 PID 입니다.
`grep '':8080 ''` 로 줄을 고르고 `grep -o ''pid=[0-9]*''` 와 `cut -d= -f2` 로 숫자만 뽑을 수 있습니다.',
   'ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2 > /tmp/port_pid.txt

# grep -o : 일치한 부분만 출력
# cut -d= -f2 : ''='' 로 나눠 두 번째(번호)만',
   '["sh", "-c", "nohup perl -MIO::Socket::INET -e ''$s=IO::Socket::INET->new(Listen=>5,LocalPort=>8080,ReuseAddr=>1) or die; sleep 3600'' >/dev/null 2>&1 &"]',
   '["sh", "-c", "[ -n \\"$(cat /tmp/port_pid.txt)\\" ] && [ \\"$(tr -d ''[:space:]'' < /tmp/port_pid.txt)\\" = \\"$(ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2 | head -n 1)\\" ]"]'),

  (16,  7, '포트를 비워서 서비스를 띄울 수 있게 하기',
   '점유한 프로세스를 찾았다면 종료해서 포트를 비웁니다.

`8080` 포트를 쓰고 있는 프로세스를 종료해서 포트를 비우세요.',
   '앞 문제처럼 `ss -ltnp` 로 PID 를 찾고 `kill <PID>` 로 종료합니다. 종료 후 `ss -ltn | grep 8080` 에 아무것도 나오지 않으면 성공입니다.',
   'kill $(ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2)

# 확인: 아무것도 나오지 않아야 합니다
ss -ltn | grep 8080',
   '["sh", "-c", "nohup perl -MIO::Socket::INET -e ''$s=IO::Socket::INET->new(Listen=>5,LocalPort=>8080,ReuseAddr=>1) or die; sleep 3600'' >/dev/null 2>&1 &"]',
   '["sh", "-c", "! ss -ltn | grep -q '':8080 ''"]'),

  (16,  8, '실행 권한 오류(Permission denied) 해결하기',
   '배포용 스크립트 `/opt/app/run.sh` 를 `deploy` 사용자가 실행하면 `Permission denied` 가 납니다.

`deploy` 사용자가 이 스크립트를 실행할 수 있게 고치세요.
오류 재현: `su deploy -c /opt/app/run.sh`',
   '먼저 `su deploy -c /opt/app/run.sh` 로 오류를 직접 확인하세요. `ls -l /opt/app/run.sh` 로 권한(`rw-r-----`)을 보면 **실행(x) 권한이 없고**, 다른 사용자는 읽을 수도 없습니다. `chmod` 로 모든 사용자가 읽고 실행할 수 있게 하세요(숫자 `755`).',
   'chmod 755 /opt/app/run.sh

# 755 = 소유자 rwx, 그룹 r-x, 다른 사용자 r-x
# 확인
su deploy -c /opt/app/run.sh',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy && mkdir -p /opt/app && printf ''#!/bin/sh\\necho ok\\n'' > /opt/app/run.sh && chmod 640 /opt/app/run.sh"]',
   '["sh", "-c", "su deploy -s /bin/sh -c /opt/app/run.sh >/dev/null 2>&1"]'),

  (16,  9, '쓰기 권한 오류 해결하기',
   '`deploy` 사용자가 `/srv/app/logs` 에 로그 파일을 만들지 못합니다.

`deploy` 사용자가 이 디렉토리에 파일을 만들 수 있게 고치세요. 단, 아무나 쓸 수 있게 하는 `777` 권한은 쓰면 안 됩니다.
오류 재현: `su deploy -c ''touch /srv/app/logs/t.log''`',
   '`ls -ld /srv/app/logs` 로 디렉토리의 **소유자**를 보세요. root 소유라서 `deploy` 가 쓸 수 없습니다. 권한을 모두에게 여는 대신, 소유자를 바꾸는 `chown <사용자> <경로>` 가 안전합니다.',
   'chown deploy /srv/app/logs

# 소유자를 deploy 로 바꾸면 deploy 만 쓸 수 있습니다 (777 은 보안상 위험)
# 확인
su deploy -c ''touch /srv/app/logs/t.log''',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy && mkdir -p /srv/app/logs"]',
   '["sh", "-c", "su deploy -s /bin/sh -c ''touch /srv/app/logs/t.log'' && ! find /srv/app/logs -maxdepth 0 -perm -o+w | grep -q ."]'),

  (16, 10, '명령이 성공했는지 종료 코드로 확인하기',
   '쉘 스크립트는 명령이 성공했는지 **종료 코드**로 판단합니다. `0` 은 성공, 그 외는 실패입니다.

`/var/log/app/app.log` 에 `FATAL` 이 있는지 `grep -q` 로 확인하고, 그 명령의 종료 코드를 `/tmp/exit_code.txt` 에 저장하세요. (이 로그에는 `FATAL` 이 없습니다)',
   '`grep -q <글자> <파일>` 은 화면 출력 없이 종료 코드만 남깁니다 (찾으면 `0`, 못 찾으면 `1`). 직전 명령의 종료 코드는 `$?` 에 들어 있으니, 바로 이어서 `echo $?` 로 저장하세요.',
   'grep -q FATAL /var/log/app/app.log; echo $? > /tmp/exit_code.txt

# ; 로 두 명령을 이어 씁니다
# $? : 직전 명령의 종료 코드 (0=성공/찾음, 1=실패/못 찾음)',
   NULL,
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/exit_code.txt)\\" = 1 ]"]'),

  (16, 11, '깨진 심볼릭 링크 찾기',
   '심볼릭 링크가 가리키는 원본이 삭제되면 링크는 ''깨진'' 상태가 되어 오류를 일으킵니다.

`/etc/app-links` 안에서 **깨진 심볼릭 링크**의 경로를 정렬해서 `/tmp/broken.txt` 에 저장하세요.',
   '`find <위치> -xtype l` 은 가리키는 대상이 없는(깨진) 링크를 찾습니다. 결과를 `sort` 로 정렬해서 파일에 저장하세요.',
   'find /etc/app-links -xtype l | sort > /tmp/broken.txt

# -xtype l : 링크가 가리키는 대상의 종류가 ''링크''(=대상 없음)인 것',
   '["sh", "-c", "mkdir -p /etc/app-links && cd /etc/app-links && touch real1 && ln -sf real1 ok1 && ln -sf missing1 broken1 && ln -sf missing2 broken2"]',
   '["sh", "-c", "[ \\"$(cat /tmp/broken.txt)\\" = \\"$(printf ''/etc/app-links/broken1\\n/etc/app-links/broken2'')\\" ]"]');
