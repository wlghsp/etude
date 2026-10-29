-- 세트 16(리눅스 장애 진단 실전) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set16.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 16, '리눅스 장애 진단 실전', '디스크 부족, 과다 CPU, 포트 충돌, 권한 오류 등 장애 상황에서 원인을 찾고 해결하는 패턴을 실습합니다.', 'linux', '리눅스' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  1, '큰 파일 찾기',
   '디스크가 부족합니다. /var/data 아래에서 가장 큰 파일의 경로를 /tmp/biggest.txt 에 저장하세요.',
   'find 로 파일을 나열하고 크기(du -b, 또는 find -printf %s)로 정렬합니다. sort -rn 은 큰 숫자 순서입니다.',
   'find /var/data -type f -exec du -b {} + | sort -rn | head -n 1 | awk ''{print $2}'' > /tmp/biggest.txt',
   '["sh", "-c", "mkdir -p /var/data/a /var/data/b && dd if=/dev/zero of=/var/data/a/x.bin bs=1k count=100 2>/dev/null && dd if=/dev/zero of=/var/data/b/big.bin bs=1M count=20 2>/dev/null && dd if=/dev/zero of=/var/data/b/y.bin bs=1k count=300 2>/dev/null"]',
   '["sh", "-c", "[ \\\"$(cat /tmp/biggest.txt)\\\" = /var/data/b/big.bin ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  2, '용량을 많이 쓰는 디렉토리 찾기',
   '/srv/data 아래 하위 디렉토리 중 용량이 가장 큰 디렉토리의 경로를 /tmp/biggest_dir.txt 에 저장하세요.',
   'du -s /srv/data/* 로 디렉토리별 사용량을 구하고 sort -rn 으로 정렬합니다.',
   'du -s /srv/data/* | sort -rn | head -n 1 | awk ''{print $2}'' > /tmp/biggest_dir.txt',
   '["sh", "-c", "mkdir -p /srv/data/app1 /srv/data/app2 /srv/data/app3 && dd if=/dev/zero of=/srv/data/app1/f bs=1M count=1 2>/dev/null && dd if=/dev/zero of=/srv/data/app2/f bs=1M count=15 2>/dev/null && dd if=/dev/zero of=/srv/data/app3/f bs=1M count=3 2>/dev/null"]',
   '["sh", "-c", "[ \\\"$(cat /tmp/biggest_dir.txt)\\\" = /srv/data/app2 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  3, '오래된 로그 정리하기',
   '/var/log/old-app 에 로그가 쌓였습니다. 7일보다 오래된 .log 파일만 삭제하고 최근 파일은 남기세요.',
   'find 디렉토리 -name "*.log" -mtime +7 은 7일보다 오래된 파일을 찾습니다. -delete 를 붙이면 지웁니다. 먼저 -delete 없이 결과를 확인하세요.',
   'find /var/log/old-app -name ''*.log'' -mtime +7 -delete',
   '["sh", "-c", "mkdir -p /var/log/old-app && cd /var/log/old-app && touch recent.log && touch -d ''30 days ago'' old1.log old2.log && touch -d ''10 days ago'' old3.log"]',
   '["sh", "-c", "[ -f /var/log/old-app/recent.log ] && [ ! -e /var/log/old-app/old1.log ] && [ ! -e /var/log/old-app/old2.log ] && [ ! -e /var/log/old-app/old3.log ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  4, 'CPU를 점유하는 프로세스 찾기',
   '서버가 느립니다. CPU를 가장 많이 쓰는 프로세스의 PID를 /tmp/hog_pid.txt 에 저장하세요.',
   'ps -eo pid,pcpu,args --sort=-pcpu 는 CPU 사용률이 높은 순서로 보여 줍니다. top 으로도 볼 수 있습니다.',
   'ps -eo pid,pcpu --sort=-pcpu | sed -n 2p | awk ''{print $1}'' > /tmp/hog_pid.txt',
   '["sh", "-c", "nohup sh -c ''while :; do :; done'' >/dev/null 2>&1 & sleep 2"]',
   '["sh", "-c", "[ -n \\\"$(cat /tmp/hog_pid.txt)\\\" ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/hog_pid.txt)\\\" = \\\"$(pgrep -f ''[w]hile :; do'' | head -n 1)\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  5, 'CPU를 점유하는 프로세스 종료하기',
   '서버가 느립니다. CPU를 계속 쓰고 있는 프로세스를 찾아 종료하세요.',
   'ps 나 top 으로 PID 를 찾고 kill PID 로 종료합니다.',
   'kill $(ps -eo pid,pcpu --sort=-pcpu | sed -n 2p | awk ''{print $1}'')',
   '["sh", "-c", "nohup sh -c ''while :; do :; done'' >/dev/null 2>&1 & sleep 2"]',
   '["sh", "-c", "! pgrep -f ''[w]hile :; do'' >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  6, '포트를 쓰는 프로세스 찾기',
   '8080 포트가 이미 사용 중이라 서비스가 뜨지 않습니다. 8080 포트를 listen 중인 프로세스의 PID를 /tmp/port_pid.txt 에 저장하세요.',
   'ss -ltnp 는 listen 중인 포트와 프로세스를 함께 보여 줍니다. users:(("이름",pid=번호,...)) 부분을 보세요.',
   'ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2 > /tmp/port_pid.txt',
   '["sh", "-c", "nohup perl -MIO::Socket::INET -e ''$s=IO::Socket::INET->new(Listen=>5,LocalPort=>8080,ReuseAddr=>1) or die; sleep 3600'' >/dev/null 2>&1 &"]',
   '["sh", "-c", "[ -n \\\"$(cat /tmp/port_pid.txt)\\\" ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/port_pid.txt)\\\" = \\\"$(ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2 | head -n 1)\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  7, '포트를 비우기',
   '8080 포트를 점유한 프로세스를 종료해서 포트를 비우세요.',
   'ss -ltnp 로 PID 를 찾아 kill 합니다.',
   'kill $(ss -ltnp | grep '':8080 '' | grep -o ''pid=[0-9]*'' | cut -d= -f2)',
   '["sh", "-c", "nohup perl -MIO::Socket::INET -e ''$s=IO::Socket::INET->new(Listen=>5,LocalPort=>8080,ReuseAddr=>1) or die; sleep 3600'' >/dev/null 2>&1 &"]',
   '["sh", "-c", "! ss -ltn | grep -q '':8080 ''"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  8, '실행 권한 오류 해결하기',
   'deploy 사용자가 /opt/app/run.sh 를 실행하면 Permission denied 가 납니다. deploy 사용자가 실행할 수 있게 고치세요.',
   'su deploy -c /opt/app/run.sh 로 직접 재현해 보세요. ls -l 로 권한을 보고 chmod 로 고칩니다.',
   'chmod 755 /opt/app/run.sh',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy && mkdir -p /opt/app && printf ''#!/bin/sh\\necho ok\\n'' > /opt/app/run.sh && chmod 640 /opt/app/run.sh"]',
   '["sh", "-c", "su deploy -s /bin/sh -c /opt/app/run.sh >/dev/null 2>&1"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16,  9, '쓰기 권한 오류 해결하기',
   'deploy 사용자가 /srv/app/logs 에 파일을 만들 수 없습니다. deploy 가 쓸 수 있게 하되, 아무나 쓰는 777 은 쓰지 마세요.',
   'ls -ld 로 소유자를 확인합니다. 모든 사용자에게 열지 말고 소유자를 바꾸는 chown 이 안전합니다.',
   'chown deploy /srv/app/logs',
   '["sh", "-c", "id deploy >/dev/null 2>&1 || useradd -m deploy && mkdir -p /srv/app/logs"]',
   '["sh", "-c", "su deploy -s /bin/sh -c ''touch /srv/app/logs/t.log'' && ! find /srv/app/logs -maxdepth 0 -perm -o+w | grep -q ."]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16, 10, '명령의 종료 코드 확인하기',
   '/var/log/app/app.log 에 FATAL 이 있는지 grep -q 로 확인하고, 그 명령의 종료 코드를 /tmp/exit_code.txt 에 저장하세요.',
   '직전 명령의 종료 코드는 $? 입니다. 0 은 성공(찾음), 1 은 못 찾음입니다. grep -q 는 출력 없이 종료 코드만 남깁니다.',
   'grep -q FATAL /var/log/app/app.log; echo $? > /tmp/exit_code.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/exit_code.txt)\\\" = 1 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 16, 11, '깨진 심볼릭 링크 찾기',
   '/etc/app-links 안에서 가리키는 대상이 없는 깨진 심볼릭 링크의 경로를 정렬해서 /tmp/broken.txt 에 저장하세요.',
   'find -xtype l 은 깨진 심볼릭 링크를 찾습니다.',
   'find /etc/app-links -xtype l | sort > /tmp/broken.txt',
   '["sh", "-c", "mkdir -p /etc/app-links && cd /etc/app-links && touch real1 && ln -sf real1 ok1 && ln -sf missing1 broken1 && ln -sf missing2 broken2"]',
   '["sh", "-c", "[ \\\"$(cat /tmp/broken.txt)\\\" = \\\"$(printf ''/etc/app-links/broken1\\n/etc/app-links/broken2'')\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 16 AND order_index = 11);
