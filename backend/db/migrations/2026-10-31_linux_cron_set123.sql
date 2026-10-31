-- 미들웨어 세트 123. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set123.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 4, '리눅스', '운영과 장애 대응', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 4);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 123, 'cron 작업 예약: 문법, 환경 차이, 로그, 겹침 방지', '정기 작업을 cron 으로 안전하게 예약하는 법을 익힙니다. 다섯 칸 문법(분 시 일 월 요일), */N 간격, 터미널과 cron 의 환경 차이(PATH), crontab 한 줄 직접 쓰기, 출력·오류 로그 남기기, % 이스케이프, flock 으로 겹침 방지, 등록 절차, 실행 여부 확인, crontab -r 의 위험을 문제와 파일 실습으로 다룹니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 123);
UPDATE quest_set SET display_order = 125, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '⏰' WHERE id = 123;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 1, 'cron 의 다섯 칸', 'crontab 한 줄은 `분 시 일 월 요일 명령` 순서입니다. **매일 새벽 2시 30분**에 `/opt/backup.sh` 를 실행하려면 분 칸과 시 칸에 무엇을 적어야 할까요?', '분이 먼저 나오고 시가 그다음이에요.', NULL, NULL, '[]', 'fill', '["30", "2", "*/5", "7"]', NULL, '왼쪽부터 `분(0-59) 시(0-23) 일(1-31) 월(1-12) 요일(0-7)` 입니다. 시를 먼저 쓰는 실수가 흔해요. `30 2 * * *` 는 "매일 2시 30분"이고 `2 30 * * *` 는 존재하지 않는 시각입니다.', '[0, 1]', '{0} {1} * * *  /opt/backup.sh', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 2, '*/10 은 무슨 뜻일까', 'crontab 줄이 `*/10 * * * * /opt/check.sh` 입니다. 언제 실행될까요?', '`*/N` 은 "N 간격마다"를 뜻해요. 어느 칸에 있는지 보세요.', NULL, NULL, '[]', 'choice', '["10시간마다", "매시 10분에 한 번", "10분마다 (0, 10, 20, 30, 40, 50 분)", "10일에 한 번"]', 2, '첫 번째 칸이 분이고, `*/10` 은 "10 간격마다"입니다. 매시 10분에 한 번은 `10 * * * *` 이에요. `*/10` 이 어느 칸에 있느냐가 의미를 정합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 3, '손으로 하면 되는데 cron 에서는 안 돼요', '`/opt/job.sh` 를 터미널에서 실행하면 잘 되는데, crontab 에 등록하면 `command not found` 로 실패합니다. 가장 알맞은 원인은 무엇일까요?', 'cron 은 로그인할 때처럼 환경을 갖춰 주지 않아요.', NULL, NULL, '[]', 'choice', '["cron 은 최소한의 환경(짧은 PATH)으로 실행해서, 평소에 쓰던 PATH 와 환경 변수가 없다. 스크립트 안에서 PATH 를 지정하거나 명령을 절대 경로로 쓴다", "스크립트에 실행 권한이 있어서", "cron 은 쉘 스크립트를 실행할 수 없다", "서버 시간이 UTC 라서"]', 0, 'cron 의 PATH 는 보통 `/usr/bin:/bin` 정도라 `/usr/local/bin` 같은 곳의 명령은 못 찾습니다. 스크립트 맨 위에 `PATH=...` 를 두거나 `/usr/local/bin/tool` 처럼 절대 경로를 쓰세요. 환경 변수(`.bashrc` 설정)도 불러오지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 4, '평일 아침 9시 크론 줄 쓰기', '**월~금 오전 9시 정각**에 `/opt/report.sh` 를 실행하는 crontab **한 줄**을 `/tmp/cron.txt` 에 저장하세요. (요일 칸에 `1-5` 를 쓸 수 있어요)', '순서는 `분 시 일 월 요일 명령` 이에요. 일과 월은 `*`.
확인: `cat /tmp/cron.txt`', 'echo ''0 9 * * 1-5 /opt/report.sh'' > /tmp/cron.txt
cat /tmp/cron.txt

# 분 시 일 월 요일. 요일은 0(또는 7)=일요일, 1=월요일 ... 5=금요일', '["sh", "-c", "rm -f /tmp/cron.txt"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/cron.txt)\\" -eq 1 ] ) && ( awk ''{exit !($1==0 && $2==9 && $3==\\"*\\" && $4==\\"*\\")}'' /tmp/cron.txt ) && ( awk ''{exit !($5==\\"1-5\\" || $5==\\"1,2,3,4,5\\" || $5==\\"MON-FRI\\" || $5==\\"mon-fri\\")}'' /tmp/cron.txt ) && ( awk ''{exit !($6==\\"/opt/report.sh\\")}'' /tmp/cron.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "한 줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/cron.txt)\\" -eq 1 ]"]}, {"label": "분 0, 시 9, 일·월 * 이다", "cmd": ["sh", "-c", "awk ''{exit !($1==0 && $2==9 && $3==\\"*\\" && $4==\\"*\\")}'' /tmp/cron.txt"]}, {"label": "요일이 월~금이다", "cmd": ["sh", "-c", "awk ''{exit !($5==\\"1-5\\" || $5==\\"1,2,3,4,5\\" || $5==\\"MON-FRI\\" || $5==\\"mon-fri\\")}'' /tmp/cron.txt"]}, {"label": "명령이 /opt/report.sh 이다", "cmd": ["sh", "-c", "awk ''{exit !($6==\\"/opt/report.sh\\")}'' /tmp/cron.txt"]}]', '[{"title": "crontab(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/crontab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 5, '출력과 오류를 로그로 남기기', '`*/15 * * * *`(15분마다)로 `/opt/job.sh` 를 실행하되, **출력과 오류를 모두** `/var/log/job.log` 에 **이어 붙이도록** 한 줄을 `/tmp/cron2.txt` 에 저장하세요.', '`>>` 는 이어 붙이기, `2>&1` 은 오류를 같은 곳으로 보내기예요. 순서는 `>> 파일 2>&1` 입니다.', 'echo ''*/15 * * * * /opt/job.sh >> /var/log/job.log 2>&1'' > /tmp/cron2.txt
cat /tmp/cron2.txt

# 로그가 없으면 실패해도 원인을 알 수 없다. 오류까지 파일로 남기는 것이 기본이다', '["sh", "-c", "rm -f /tmp/cron2.txt"]', '["sh", "-c", "( awk ''{exit !($1==\\"*/15\\")}'' /tmp/cron2.txt ) && ( awk ''{exit !($6==\\"/opt/job.sh\\")}'' /tmp/cron2.txt ) && ( grep -q ''>> /var/log/job.log 2>&1'' /tmp/cron2.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "15분마다이다", "cmd": ["sh", "-c", "awk ''{exit !($1==\\"*/15\\")}'' /tmp/cron2.txt"]}, {"label": "명령이 /opt/job.sh 이다", "cmd": ["sh", "-c", "awk ''{exit !($6==\\"/opt/job.sh\\")}'' /tmp/cron2.txt"]}, {"label": "출력과 오류를 로그에 이어 붙인다", "cmd": ["sh", "-c", "grep -q ''>> /var/log/job.log 2>&1'' /tmp/cron2.txt"]}]', '[{"title": "crontab(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/crontab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 6, '날짜 명령이 cron 에서만 이상해요', 'crontab 에 `0 1 * * * tar czf /backup/data-$(date +%Y%m%d).tgz /data` 를 넣었더니 백업 파일이 만들어지지 않습니다. 같은 명령을 터미널에서는 잘 됩니다. 원인으로 알맞은 것은 무엇일까요?', 'crontab 에서 특별한 의미를 갖는 글자가 있어요.', NULL, NULL, '[]', 'choice', '["`tar` 는 cron 에서 쓸 수 없다", "`date` 명령이 없어서", "연도는 cron 에서 계산되지 않아서", "crontab 에서 `%` 는 줄바꿈으로 해석되어 명령이 잘린다. `\\\\%Y\\\\%m\\\\%d` 처럼 이스케이프하거나, 날짜를 만드는 일을 스크립트 파일 안으로 옮긴다"]', 3, 'crontab 의 `%` 는 "줄바꿈, 이후는 표준 입력"이라는 뜻이라 명령이 잘립니다. `\\%` 로 쓰거나, 복잡한 명령은 스크립트 파일로 만들고 crontab 에는 스크립트 경로만 적는 것이 가장 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 7, 'cron 작업을 안전하게 등록하는 순서', '새 정기 작업을 등록합니다. 순서에 맞게 놓아 보세요.', '먼저 손으로 되는지 보고, 등록하고, 실제로 도는지 봐요.', NULL, NULL, '[]', 'order', '["스크립트를 절대 경로로 손으로 실행해 동작을 확인한다", "실행 권한을 준다 (`chmod +x`)", "`crontab -e` 로 줄을 추가한다", "`crontab -l` 로 등록된 내용을 확인한다", "다음 실행 시각 뒤에 로그와 결과물로 실제로 돌았는지 확인한다"]', NULL, '손으로도 안 되는 스크립트를 cron 에 넣으면 원인을 찾기가 훨씬 어렵습니다. 등록 후에는 "돌았는지"를 반드시 확인하세요. 처음에는 `* * * * *`(매분)로 테스트하다가 원래 주기로 바꾸는 방법도 있어요.', '[0, 1, 2, 3, 4]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 8, '작업이 겹치지 않게 flock 으로 감싸기', '5분마다 `/opt/job.sh` 가 도는데 가끔 10분씩 걸려 겹칩니다. `flock -n /tmp/job.lock` 으로 감싸 **이미 실행 중이면 새로 시작하지 않는** crontab 한 줄을 `/tmp/cron3.txt` 에 저장하세요.', '`*/5 * * * * flock -n 락파일 명령` 모양이에요. `-n` 은 기다리지 않고 포기하는 옵션입니다.', 'echo ''*/5 * * * * flock -n /tmp/job.lock /opt/job.sh'' > /tmp/cron3.txt
cat /tmp/cron3.txt

# 이전 실행이 끝나지 않았으면 이번 실행은 건너뛴다 (작업 겹침 방지)', '["sh", "-c", "rm -f /tmp/cron3.txt"]', '["sh", "-c", "( awk ''{exit !($1==\\"*/5\\")}'' /tmp/cron3.txt ) && ( grep -q ''flock -n /tmp/job.lock'' /tmp/cron3.txt ) && ( grep -q ''/opt/job.sh'' /tmp/cron3.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "5분마다이다", "cmd": ["sh", "-c", "awk ''{exit !($1==\\"*/5\\")}'' /tmp/cron3.txt"]}, {"label": "flock -n 으로 락 파일을 쓴다", "cmd": ["sh", "-c", "grep -q ''flock -n /tmp/job.lock'' /tmp/cron3.txt"]}, {"label": "/opt/job.sh 를 실행한다", "cmd": ["sh", "-c", "grep -q ''/opt/job.sh'' /tmp/cron3.txt"]}]', '[{"title": "crontab(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/crontab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 9, 'cron 이 돌긴 한 걸까?', '정기 작업의 결과물이 안 만들어집니다. 먼저 "cron 이 그 시각에 작업을 **시작은 했는지**"를 확인하려 합니다. 알맞은 방법은 무엇일까요?', '시스템 로그에 cron 이 작업을 시작한 기록이 남아요.', NULL, NULL, '[]', 'choice', '["서버를 재부팅한다", "시스템 로그(예: `journalctl -u cron`, `grep CRON /var/log/syslog`)에서 해당 시각에 실행 기록이 있는지 본다. 기록이 있는데 결과가 없으면 스크립트 자체의 실패(출력 로그, PATH)를 의심한다", "`crontab -r` 로 전부 지우고 다시 등록한다", "크론 줄을 주석 처리한다"]', 1, '시작 기록이 없으면 등록·문법·cron 서비스 문제이고, 시작 기록이 있으면 스크립트가 실패한 것입니다. 이렇게 나눠 보면 원인 범위가 반으로 줄어요. 출력을 로그 파일로 남겨 두면 다음번에 훨씬 빨라집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 10, 'crontab 명령 옵션', '내 crontab 을 ① **목록으로 보고**, ② **편집기로 수정**하는 명령입니다. 빈칸을 채우세요. (`-r` 은 확인 없이 전부 삭제합니다)', '목록은 list 의 l, 편집은 edit 의 e 예요.', NULL, NULL, '[]', 'fill', '["-l", "-e", "-r", "-i"]', NULL, '`-l` 은 보기, `-e` 는 편집입니다. `-r` 은 **확인 없이 전체 삭제**라 `-e` 와 키가 붙어 있어 오타가 위험해요. 수정 전에는 `crontab -l > crontab.bak` 으로 백업해 두세요.', '[0, 1]', 'crontab {0}
crontab {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 123, 11, 'crontab -r 을 쳐 버렸어요', '`crontab -e` 를 치려다 `crontab -r` 을 쳐서 등록된 작업이 모두 사라졌습니다. 앞으로를 위한 가장 좋은 습관은 무엇일까요?', '되돌리는 기능이 없으니 미리 사본을 만들어 두어야 해요.', NULL, NULL, '[]', 'choice', '["`-r` 은 안전하니 신경 쓰지 않는다", "모든 작업을 root 의 crontab 에만 둔다", "crontab 내용을 파일로 백업해 두고(`crontab -l > backup`), 중요한 작업은 `/etc/cron.d/` 나 저장소에 파일로 관리해 사본을 남긴다", "crontab 을 쓰지 않고 터미널에서 수동으로 돌린다"]', 2, '`crontab -r` 은 복구할 수 없습니다. 설정을 코드처럼 파일(저장소)로 관리하면 사고가 나도 다시 적용할 수 있어요. 작업 정의가 서버 안에만 있는 것은 위험한 상태입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 123 AND order_index = 11);
