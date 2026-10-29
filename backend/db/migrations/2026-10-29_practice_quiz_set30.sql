-- 실습 연계 객관식 세트 30(리눅스 터미널로 확인하고 고르기) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set30.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 30, '리눅스 터미널로 확인하고 고르기', '터미널에서 직접 명령을 실행해 로그, 디렉터리 용량, 권한, 종료 코드, 설정 파일을 확인하고 그 결과로 정답을 고르는 실습형 객관식입니다. 정답과 함께 오답이 왜 틀렸는지 해설을 봅니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 30);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  1, '로그 파일에서 ERROR 레벨 줄 수 세기',
   '서버가 자꾸 느려진다는 문의가 왔습니다. 애플리케이션 로그 `/var/log/app/app.log` 에 `ERROR` 레벨로 남은 줄이 **몇 줄**인지 세어 보려 합니다. (로그의 각 줄은 `날짜 시각 레벨 메시지` 형태입니다.)

터미널에서 로그를 직접 확인하고, 아래에서 **`ERROR` 레벨 줄 수**를 고르세요.',
   '`grep 패턴 파일` 은 패턴이 들어 있는 줄을 보여 주고, `-c` 를 붙이면 그 줄의 **개수**를 셉니다. 기본은 대소문자를 구분하고, `-i` 를 붙이면 구분하지 않습니다.',
   NULL,
   '["sh", "-c", "mkdir -p /var/log/app && printf ''%s\\\\n'' ''2026-10-29 10:00:01 ERROR db connection refused'' ''2026-10-29 10:00:02 ERROR db connection refused'' ''2026-10-29 10:00:03 ERROR db connection refused'' ''2026-10-29 10:00:04 ERROR db connection refused'' ''2026-10-29 10:00:05 ERROR db connection refused'' ''2026-10-29 10:00:06 ERROR db connection refused'' ''2026-10-29 10:00:07 ERROR db connection refused'' ''2026-10-29 10:01:01 WARN slow response'' ''2026-10-29 10:01:02 WARN slow response'' ''2026-10-29 10:01:03 WARN slow response'' ''2026-10-29 10:01:04 WARN slow response'' ''2026-10-29 10:02:01 INFO recovered from error on retry'' ''2026-10-29 10:02:02 INFO cache cleared after error'' ''2026-10-29 10:02:03 INFO request ok'' ''2026-10-29 10:02:04 INFO request ok'' ''2026-10-29 10:02:05 INFO request ok'' ''2026-10-29 10:02:06 INFO request ok'' ''2026-10-29 10:02:07 INFO request ok'' ''2026-10-29 10:02:08 INFO request ok'' ''2026-10-29 10:02:09 INFO request ok'' > /var/log/app/app.log"]',
   '[]',
   'choice',
   '["9", "7", "11", "20"]',
   1,
   '정답은 **B 7** 입니다. `grep -c ERROR /var/log/app/app.log` 가 `ERROR` 가 들어 있는 줄의 개수를 센 값이 7 입니다.

**원리:** `grep` 은 파일을 **한 줄씩** 읽어 패턴이 들어 있는지 검사하고, `-c` 는 일치한 **줄의 수**를 셉니다(한 줄에 여러 번 나와도 1줄). 대소문자는 기본으로 구분해서 `error` 와 `ERROR` 는 다른 글자이고, `-i` 가 그 구분을 끕니다. 로그 분석은 "무엇을 세는지"(줄, 레벨, 대소문자)를 정확히 정하는 데서 시작합니다.

- A 9 : `grep -ci error` 처럼 대소문자를 구분하지 않으면, 메시지에 소문자 `error` 가 들어간 INFO 2줄까지 더해져 9 가 됩니다. 레벨이 `ERROR` 인 줄만 세야 합니다.
- C 11 : `ERROR` 7줄에 `WARN` 4줄을 더한 값입니다. `WARN` 은 경고 레벨이라 세지 않습니다.
- D 20 : 파일 전체 줄 수(`wc -l`)입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  2, '접속 로그에서 가장 많이 요청한 IP 찾기',
   '특정 주소에서 요청이 몰리는 것 같습니다. 접속 로그 `/var/log/app/access.log` 의 각 줄은 `IP - 요청 상태코드` 형태이고, **첫 칸이 접속한 IP** 입니다.

터미널에서 로그를 집계해서 **요청을 가장 많이 보낸 IP** 를 고르세요.',
   '`awk ''{print $1}'' 파일` 은 각 줄의 첫 칸(IP)만 뽑습니다. `sort` 로 같은 값을 모으고 `uniq -c` 로 몇 번 나왔는지 세고, `sort -rn` 으로 많은 순서로 정렬하면 1등이 맨 위에 옵니다. (`-r` 은 내림차순, `-n` 은 숫자 기준 정렬)',
   NULL,
   '["sh", "-c", "mkdir -p /var/log/app && printf ''%s\\\\n'' ''10.0.0.2 - GET /index.html 200'' ''10.0.0.5 - GET /index.html 200'' ''10.0.0.9 - GET /index.html 200'' ''10.0.0.5 - GET /index.html 200'' ''10.0.0.2 - GET /index.html 200'' ''10.0.0.5 - GET /index.html 200'' ''10.0.0.9 - GET /index.html 200'' ''10.0.0.7 - GET /index.html 200'' ''10.0.0.5 - GET /index.html 200'' ''10.0.0.9 - GET /index.html 200'' ''10.0.0.2 - GET /index.html 200'' ''10.0.0.5 - GET /index.html 200'' ''10.0.0.9 - GET /index.html 200'' ''10.0.0.5 - GET /index.html 200'' > /var/log/app/access.log"]',
   '[]',
   'choice',
   '["10.0.0.2", "10.0.0.9", "10.0.0.5", "10.0.0.7"]',
   2,
   '정답은 **C 10.0.0.5** 입니다. 집계하면 `10.0.0.5` 가 6번, `10.0.0.9` 가 4번, `10.0.0.2` 가 3번, `10.0.0.7` 이 1번 나옵니다.

**원리:** `sort | uniq -c | sort -rn` 은 "모으기 → 세기 → 정렬" 세 단계입니다. `uniq` 는 **바로 붙어 있는** 같은 줄만 합치기 때문에, 먼저 `sort` 로 같은 값을 이웃하게 모아야 합니다. 로그에서 가장 많은 IP·URL·오류를 찾는 기본 패턴입니다.

- A 10.0.0.2 : 로그의 **맨 첫 줄**에 나오는 IP라서 많아 보이지만 3번뿐입니다.
- B 10.0.0.9 : 4번으로 2등입니다. 숫자가 큰 IP가 아니라 **횟수**로 비교해야 합니다.
- D 10.0.0.7 : 1번뿐입니다.

확인 명령: `awk ''{print $1}'' /var/log/app/access.log | sort | uniq -c | sort -rn | head -n 1`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  3, '디스크를 가장 많이 차지하는 디렉터리 찾기',
   '`/data` 디스크의 사용량이 올라가고 있습니다. `/data` 아래에는 `logs`, `backup`, `cache` 디렉터리가 있습니다.

터미널에서 크기를 확인해서 **용량을 가장 많이 차지하는 디렉터리** 를 고르세요. (파일이 가장 *많은* 곳이 아니라 가장 *큰* 곳입니다.)',
   '`du -sh /data/*` 는 `/data` 아래 항목마다 사용량을 사람이 읽기 쉬운 단위로 한 줄씩 보여 줍니다. (`-s` 는 합계만, `-h` 는 K/M/G 단위) 크기 순으로 보려면 `du -sk /data/* | sort -rn` 처럼 숫자 기준 내림차순으로 정렬합니다.',
   NULL,
   '["sh", "-c", "mkdir -p /data/logs /data/backup /data/cache && for i in $(seq 1 20); do echo log > /data/logs/f$i.log; done && dd if=/dev/zero of=/data/backup/db.dump bs=1M count=9 2>/dev/null && dd if=/dev/zero of=/data/cache/a.bin bs=1M count=3 2>/dev/null && dd if=/dev/zero of=/data/cache/b.bin bs=1M count=2 2>/dev/null"]',
   '[]',
   'choice',
   '["logs", "cache", "backup", "lost+found"]',
   2,
   '정답은 **C backup** 입니다. `backup` 은 파일이 1개지만 9MB 로 가장 큽니다. `cache` 는 5MB, `logs` 는 작은 파일 20개를 합쳐도 훨씬 작습니다.

**원리:** `du` 는 디렉터리 아래 파일들의 **실제 디스크 사용량**을 더해서 보여 줍니다. 용량을 결정하는 것은 파일 개수가 아니라 크기이므로, `du -sk 아래항목 | sort -rn` 으로 큰 쪽부터 한 단계씩 내려가며 원인을 좁힙니다.

- A logs : 파일 **개수**는 20개로 가장 많아서 커 보이지만, 파일이 모두 아주 작습니다.
- B cache : 5MB 로 2등입니다.
- D lost+found : 이 환경에는 없는 디렉터리입니다.

확인 명령: `du -sk /data/* | sort -rn | head -n 1`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  4, 'ls -l 의 권한 문자열을 숫자 권한으로 읽기',
   '`/srv/report.csv` 는 소유자만 쓸 수 있고, 같은 그룹은 읽기만, 나머지는 접근하지 못해야 하는 파일입니다. `ls -l` 에서 권한은 맨 앞 10글자로 나옵니다. (예: `-rw-r-----`)

터미널에서 `/srv/report.csv` 의 권한을 확인하고, 이 파일의 권한을 **숫자(8진수)** 로 나타낸 값을 고르세요.',
   '맨 앞 글자는 파일 종류이고, 그 뒤 9글자를 3글자씩 소유자 / 그룹 / 그 외 순으로 읽습니다. 읽기 `r`=4, 쓰기 `w`=2, 실행 `x`=1 이고 없으면 `-` 는 0 입니다. 한 묶음의 숫자를 더하면 한 자리 숫자가 됩니다. (예: `rw-` = 4+2 = 6)',
   NULL,
   '["sh", "-c", "mkdir -p /srv && echo ''id,amount'' > /srv/report.csv && chmod 640 /srv/report.csv"]',
   '[]',
   'choice',
   '["604", "640", "460", "064"]',
   1,
   '정답은 **B 640** 입니다. `-rw-r-----` 을 3글자씩 끊으면 소유자 `rw-`(4+2=6), 그룹 `r--`(4), 그 외 `---`(0) 이라 640 입니다.

**원리:** 권한 9칸은 **소유자·그룹·그 외** 세 묶음의 읽기/쓰기/실행 비트이고, 숫자는 4(r)+2(w)+1(x)의 합입니다. 필요한 만큼만 주는 **최소 권한** 원칙에서 `640` 같은 값은 "소유자만 수정, 그룹은 읽기만, 그 외는 차단"이라는 의도를 담습니다.

- A 604 : 소유자 `rw-`, 그룹 `---`, 그 외 `r--` 입니다. 순서가 다릅니다.
- C 460 : 소유자 `r--`, 그룹 `rw-` 입니다. 소유자와 그룹이 바뀌었습니다.
- D 064 : 소유자는 아무것도 못 하고 그룹이 쓸 수 있습니다.

확인 명령: `ls -l /srv/report.csv`, 숫자로 바로 보려면 `stat -c %a /srv/report.csv`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  5, '설정 파일에서 실제로 쓰이는 포트 찾기',
   '서비스가 어떤 포트로 뜨는지 확인해야 합니다. 설정 파일 `/etc/app.conf` 에는 `port` 가 여러 번 적혀 있지만, `#` 으로 시작하는 줄은 **주석(무시되는 줄)** 입니다.

터미널에서 파일을 읽고, **실제로 적용되는 `port` 값** 을 고르세요.',
   '`grep port /etc/app.conf` 는 `port` 가 들어간 줄을 모두 보여 줍니다. `^` 는 줄의 시작을 뜻해서 `grep ''^port'' /etc/app.conf` 처럼 쓰면 `port` 로 **시작하는** 줄만 나옵니다. (주석은 `#` 으로 시작하므로 걸러집니다)',
   NULL,
   '["sh", "-c", "printf ''%s\\\\n'' ''# port = 8080'' ''port = 9090'' ''#port=7070'' ''timeout = 30'' ''# old port = 6060'' > /etc/app.conf"]',
   '[]',
   'choice',
   '["8080", "7070", "6060", "9090"]',
   3,
   '정답은 **D 9090** 입니다. 주석이 아닌 줄은 `port = 9090` 하나뿐입니다.

**원리:** 설정 파일에서 `#` 으로 시작하는 줄은 프로그램이 **읽지 않는 주석**이라, `grep port` 로 나온 줄이 모두 실제 설정은 아닙니다. 적용되는 값은 주석이 아닌 줄이고, `^`(줄의 시작)를 붙인 `grep ''^port''` 로 주석을 걸러서 확인합니다.

- A 8080, B 7070, C 6060 : 모두 `#` 으로 시작하는 **주석 줄**에 적힌 값이라 적용되지 않습니다.

확인 명령: `grep ''^port'' /etc/app.conf`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  6, '명령의 종료 코드(exit code) 읽기',
   '스크립트는 직전 명령이 성공했는지를 **종료 코드** 로 판단합니다. `/tmp/words.txt` 에는 `apple`, `banana`, `cherry` 가 한 줄씩 들어 있습니다.

터미널에서 `grep -q mango /tmp/words.txt` 를 실행한 직후 `echo $?` 로 종료 코드를 확인하고, 그 값을 고르세요. (`-q` 는 결과를 출력하지 않고 종료 코드만 남기는 옵션이고, `$?` 는 직전 명령의 종료 코드입니다.)',
   '`grep` 은 찾으면 `0`, **못 찾으면 `1`**, 파일이 없는 등 오류가 나면 `2` 를 돌려줍니다. 명령 자체를 못 찾으면 `127` 입니다. 실행한 뒤 바로 `echo $?` 를 해야 값이 유지됩니다.',
   NULL,
   '["sh", "-c", "printf ''%s\\\\n'' ''apple'' ''banana'' ''cherry'' > /tmp/words.txt"]',
   '[]',
   'choice',
   '["0", "1", "2", "127"]',
   1,
   '정답은 **B 1** 입니다. `mango` 는 파일에 없으므로 `grep` 이 "못 찾음"을 뜻하는 1 을 돌려줍니다.

**원리:** 종료 코드는 명령이 끝날 때 쉘이 `$?` 에 담아 두는 값이고, **다음 명령이 실행되면 덮어쓰여 사라집니다.** 그래서 확인하려는 명령 **바로 뒤에** `echo $?` 를 해야 합니다. `0` 은 성공, 그 외는 실패나 특이 상태이고 `grep` 은 못 찾음(1)과 오류(2)를 구분합니다.

- A 0 : 찾았을 때(성공)의 값입니다.
- C 2 : 파일이 없거나 옵션이 잘못되는 등 **오류**일 때의 값입니다.
- D 127 : 명령어 자체를 찾지 못했을 때의 값입니다.

확인 명령: `grep -q mango /tmp/words.txt; echo $?`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  7, '파일에서 가장 많이 중복된 줄 찾기',
   '`/tmp/dup.txt` 에는 과일 이름이 한 줄에 하나씩 적혀 있고, 같은 이름이 여러 번 나옵니다.

터미널에서 집계해서 **가장 많이 반복된 줄** 을 고르세요.',
   '`sort 파일 | uniq -c` 는 같은 줄을 모아 몇 번 나왔는지 앞에 붙여 줍니다. (`uniq` 는 **붙어 있는** 같은 줄만 합치므로 먼저 `sort` 가 필요합니다.) 거기에 `sort -rn` 을 한 번 더 하면 많이 나온 순서로 정렬됩니다.',
   NULL,
   '["sh", "-c", "printf ''%s\\\\n'' ''apple'' ''banana'' ''apple'' ''cherry'' ''banana'' ''date'' ''banana'' > /tmp/dup.txt"]',
   '[]',
   'choice',
   '["banana", "apple", "cherry", "date"]',
   0,
   '정답은 **A banana** 입니다. `banana` 3번, `apple` 2번, `cherry` 와 `date` 는 1번씩 나옵니다.

**원리:** `uniq` 는 **인접한** 같은 줄만 합칩니다. 중복이 흩어져 있으면 먼저 `sort` 로 같은 줄을 이웃하게 만든 뒤 `uniq -c` 로 개수를 세야 정확합니다. 정렬 없이 `uniq` 만 쓰면 떨어져 있는 중복을 놓칩니다.

- B apple : 2번으로 2등입니다. **첫 줄**에 나와서 눈에 띄지만 가장 많지는 않습니다.
- C cherry, D date : 1번뿐입니다.

확인 명령: `sort /tmp/dup.txt | uniq -c | sort -rn | head -n 1`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 30,  8, '수정 시각으로 가장 최근 파일 찾기',
   '`/opt/releases` 에는 배포 파일이 여러 개 있습니다. 버전 숫자가 크다고 가장 최근에 만든 파일은 아닐 수 있습니다.

터미널에서 **수정 시각이 가장 최근인 파일** 을 확인해서 고르세요.',
   '`ls -l` 은 파일마다 수정 시각을 보여 주고, `-t` 를 붙이면 **최근에 수정된 순서**로 정렬합니다. 가장 위가 가장 최근입니다. (`ls -lt /opt/releases`)',
   NULL,
   '["sh", "-c", "mkdir -p /opt/releases && cd /opt/releases && touch -d ''2025-12-01 09:00'' v0.9.tar && touch -d ''2026-01-10 09:00'' v1.0.tar && touch -d ''2026-05-20 09:00'' v1.1.tar && touch -d ''2026-03-05 09:00'' v1.2.tar"]',
   '[]',
   'choice',
   '["v0.9.tar", "v1.0.tar", "v1.2.tar", "v1.1.tar"]',
   3,
   '정답은 **D v1.1.tar** 입니다. 수정 시각이 `v1.1.tar` 는 5월 20일, `v1.2.tar` 는 3월 5일이라 버전 숫자가 더 작아도 `v1.1.tar` 가 더 최근입니다.

**원리:** "최근"을 결정하는 것은 파일 이름이 아니라 **수정 시각(mtime)** 입니다. 버전 숫자는 사람이 붙인 이름일 뿐이라 만든 순서와 다를 수 있고, `ls -lt` 는 수정 시각 기준으로 정렬해 이를 확인해 줍니다.

- A v0.9.tar : 가장 오래된 파일입니다.
- B v1.0.tar : 1월 10일입니다.
- C v1.2.tar : 버전 숫자는 가장 크지만 수정 시각은 3월 5일입니다. 이름이 아니라 **시각**으로 비교해야 합니다.

확인 명령: `ls -lt /opt/releases`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 30 AND order_index = 8);
