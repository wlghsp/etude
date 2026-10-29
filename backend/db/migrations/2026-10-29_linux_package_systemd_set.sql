-- 세트 24(리눅스 패키지와 systemd 로그) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set24.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 24, '리눅스 패키지와 systemd 로그', 'rpm 으로 패키지를 조회·검증하고, journalctl·logger 로 로그를 찾고, systemd 유닛을 만들어 시작하고 실패 원인을 찾는 현장 패턴을 실습합니다.', 'linux-systemd', '리눅스' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  1, '설치된 패키지 개수 세기',
   '이 서버에 rpm 으로 설치된 패키지가 몇 개인지 숫자만 /tmp/pkg_count.txt 에 저장하세요.',
   'rpm -qa 는 설치된 모든 패키지를 한 줄씩 보여 줍니다. wc -l 로 줄 수를 세세요.',
   'rpm -qa | wc -l > /tmp/pkg_count.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/pkg_count.txt)\\\" = \\\"$(rpm -qa | wc -l)\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  2, '패키지 버전 확인하기',
   'bash 패키지의 전체 이름(버전 포함)을 /tmp/bash_ver.txt 에 저장하세요.',
   'rpm -q 패키지 는 설치 여부와 버전을 출력합니다.',
   'rpm -q bash > /tmp/bash_ver.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/bash_ver.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/bash_ver.txt)\\\" = \\\"$(rpm -q bash)\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  3, '파일이 어느 패키지 것인지 찾기',
   '/bin/ls 파일을 설치한 패키지 이름을 /tmp/owner.txt 에 저장하세요.',
   'rpm -qf 파일경로 는 그 파일을 설치한 패키지를 알려 줍니다. 장애 때 "이 파일은 어디서 왔지?"를 풀 때 씁니다.',
   'rpm -qf /bin/ls > /tmp/owner.txt',
   NULL,
   '["sh", "-c", "grep -q coreutils /tmp/owner.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  4, '패키지가 설치한 실행 파일 찾기',
   'which 패키지가 설치한 파일 중 실행 파일(경로에 bin/ 이 들어간 것)의 경로를 /tmp/which_bin.txt 에 저장하세요.',
   'rpm -ql 패키지 는 패키지가 설치한 파일 목록입니다. grep 으로 걸러 보세요.',
   'rpm -ql which | grep ''bin/'' > /tmp/which_bin.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/which_bin.txt)\\\" = /usr/bin/which ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  5, '패키지 정보에서 라이선스 찾기',
   'bash 패키지의 라이선스 정보 줄을 /tmp/license.txt 에 저장하세요.',
   'rpm -qi 패키지 는 상세 정보를 보여 줍니다. grep License 로 줄을 고릅니다.',
   'rpm -qi bash | grep License > /tmp/license.txt',
   NULL,
   '["sh", "-c", "grep -q GPL /tmp/license.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  6, '패키지 원본과 달라진 파일 찾기',
   '누군가 /etc/profile 을 수정했습니다. rpm 으로 이 파일이 패키지 원본과 달라졌는지 검사하고, 결과를 /tmp/verify.txt 에 저장하세요.',
   'rpm -Vf 파일 은 파일을 설치한 패키지 기준으로 검증합니다. 출력의 5 는 내용(MD5) 변경, c 는 설정 파일 표시입니다.',
   'rpm -Vf /etc/profile > /tmp/verify.txt',
   '["sh", "-c", "echo ''# local change'' >> /etc/profile"]',
   '["sh", "-c", "grep -q ''/etc/profile'' /tmp/verify.txt && grep -q ''5'' /tmp/verify.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  7, 'logger 로 남긴 로그 찾기',
   'logger 로 myapp 태그(-t)의 disk almost full 메시지를 남기고, journalctl 로 그 태그의 로그를 /tmp/myapp.log 에 저장하세요.',
   'logger -t 태그 "메시지" 로 기록하고 journalctl -t 태그 --no-pager 로 조회합니다. 기록이 반영되는 데 1초쯤 걸립니다.',
   'logger -t myapp ''disk almost full''
sleep 1
journalctl -t myapp --no-pager > /tmp/myapp.log',
   NULL,
   '["sh", "-c", "grep -q ''disk almost full'' /tmp/myapp.log"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  8, '우선순위로 로그 거르기',
   'journal 에 svc 태그로 info 와 err 메시지가 하나씩 남아 있습니다. err 이상 우선순위만 메시지 본문(-o cat)으로 /tmp/err.log 에 저장하세요.',
   'journalctl -p err 는 해당 우선순위 이상만 보여 줍니다. -t 태그, -o cat 은 본문만 출력합니다.',
   'journalctl -p err -t svc --no-pager -o cat > /tmp/err.log',
   '["sh", "-c", "logger -p info -t svc ok-message; logger -p err -t svc boom-message; sleep 1"]',
   '["sh", "-c", "grep -q boom-message /tmp/err.log && ! grep -q ok-message /tmp/err.log"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24,  9, '서비스를 시작하고 그 유닛의 로그 보기',
   'hello 서비스를 시작하고, 그 유닛이 남긴 로그(본문만)를 /tmp/unit.log 에 저장하세요.',
   'systemctl start 서비스 후 journalctl -u 서비스 --no-pager -o cat 입니다.',
   'systemctl start hello
sleep 1
journalctl -u hello --no-pager -o cat > /tmp/unit.log',
   '["sh", "-c", "{ echo ''[Service]''; echo ''ExecStart=/bin/sh -c \\\"echo hello-from-unit; sleep 3600\\\"''; } > /etc/systemd/system/hello.service; systemctl daemon-reload"]',
   '["sh", "-c", "grep -q hello-from-unit /tmp/unit.log"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24, 10, '서비스 유닛 파일 만들고 부팅 시 자동 시작하기',
   '/etc/systemd/system/app.service 를 만들어 /bin/sleep 3600 을 실행하는 서비스를 정의하고, 지금 시작하면서 부팅 때도 자동 시작되게 하세요.',
   '[Service] 에 ExecStart=, [Install] 에 WantedBy=multi-user.target 을 씁니다. 파일을 만든 뒤 systemctl daemon-reload, systemctl enable --now app 순서입니다.',
   'cat > /etc/systemd/system/app.service <<EOF
[Service]
ExecStart=/bin/sleep 3600

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now app',
   NULL,
   '["sh", "-c", "[ \\\"$(systemctl is-active app)\\\" = active ] && [ \\\"$(systemctl is-enabled app)\\\" = enabled ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24, 11, '실패한 서비스 찾기',
   '시스템에서 실패(failed) 상태인 서비스의 이름을 /tmp/failed.txt 에 저장하세요.',
   'systemctl --failed 또는 systemctl list-units --state=failed --no-legend --plain 입니다. 원인은 systemctl status 서비스, journalctl -u 서비스 로 확인합니다.',
   'systemctl list-units --state=failed --no-legend --plain | awk ''{print $1}'' > /tmp/failed.txt',
   '["sh", "-c", "{ echo ''[Service]''; echo ''ExecStart=/bin/nonexistent''; } > /etc/systemd/system/bad.service; systemctl daemon-reload; systemctl start bad || true"]',
   '["sh", "-c", "grep -qx bad.service /tmp/failed.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24, 12, '부팅 시 자동 시작 해제하기',
   'hello 서비스가 부팅 때 자동으로 시작되지 않도록 해제하세요. (서비스를 지울 필요는 없습니다.)',
   'systemctl disable 서비스 입니다. 현재 실행 중인 서비스를 멈추려면 stop 이 따로 필요합니다.',
   'systemctl disable hello',
   '["sh", "-c", "{ echo ''[Service]''; echo ''ExecStart=/bin/sleep 3600''; echo ''''; echo ''[Install]''; echo ''WantedBy=multi-user.target''; } > /etc/systemd/system/hello.service; systemctl daemon-reload; systemctl enable hello"]',
   '["sh", "-c", "[ \\\"$(systemctl is-enabled hello 2>&1)\\\" != enabled ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 24, 13, '타임존 바꾸기',
   '서버의 타임존을 Asia/Seoul 로 바꾸세요.',
   'timedatectl set-timezone 타임존 입니다. 목록은 timedatectl list-timezones 로 봅니다.',
   'timedatectl set-timezone Asia/Seoul',
   NULL,
   '["sh", "-c", "[ \\\"$(timedatectl show -p Timezone --value)\\\" = Asia/Seoul ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 24 AND order_index = 13);
