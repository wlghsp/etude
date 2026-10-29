-- 세트 15(리눅스 로그와 텍스트 처리) 추가. 샘플 데이터가 etude-linux 이미지에 있어 이미지 빌드가 먼저 필요하다 (deploy.yml이 순서를 보장).
-- 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set15.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 15, '리눅스 로그와 텍스트 처리', '로그에서 필요한 줄과 숫자를 뽑아내는 현장 패턴을 실습합니다. grep, 리다이렉션, sort/uniq, awk, sed.', 'linux', '리눅스' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  1, '로그 마지막 5줄 저장하기',
   '/var/log/app/app.log 의 마지막 5줄을 /tmp/last5.txt 에 저장하세요.',
   'tail -n 숫자 로 파일의 끝부분을 볼 수 있습니다. 결과는 리다이렉션(>)으로 저장합니다.',
   'tail -n 5 /var/log/app/app.log > /tmp/last5.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/last5.txt ] && tail -n 5 /var/log/app/app.log | cmp -s - /tmp/last5.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  2, 'ERROR 줄만 추출하기',
   '/var/log/app/app.log 에서 ERROR 가 들어간 줄만 뽑아 /tmp/errors.txt 에 저장하세요.',
   'grep 패턴 파일 은 패턴이 들어간 줄만 출력합니다.',
   'grep ERROR /var/log/app/app.log > /tmp/errors.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/errors.txt ] && grep ERROR /var/log/app/app.log | cmp -s - /tmp/errors.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  3, 'ERROR 줄 개수 세기',
   '/var/log/app/app.log 에서 ERROR 줄이 몇 개인지 세어 숫자만 /tmp/error_count.txt 에 저장하세요.',
   'grep -c 는 일치하는 줄 수를 출력합니다. (grep 결과를 wc -l 로 세어도 됩니다.)',
   'grep -c ERROR /var/log/app/app.log > /tmp/error_count.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/error_count.txt)\\\" = \\\"$(grep -c ERROR /var/log/app/app.log)\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  4, 'ERROR 또는 WARN 줄 추출하기',
   '/var/log/app/app.log 에서 ERROR 또는 WARN 이 들어간 줄을 모두 뽑아 /tmp/err_warn.txt 에 저장하세요.',
   'grep -E ''A|B'' 처럼 확장 정규식의 | 로 여러 패턴 중 하나와 일치하는 줄을 찾습니다.',
   'grep -E ''ERROR|WARN'' /var/log/app/app.log > /tmp/err_warn.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/err_warn.txt ] && grep -E ''ERROR|WARN'' /var/log/app/app.log | cmp -s - /tmp/err_warn.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  5, 'DEBUG 줄 제외하기',
   '/var/log/app/app.log 에서 DEBUG 줄을 제외한 나머지 줄을 /tmp/no_debug.txt 에 저장하세요.',
   'grep -v 패턴 은 패턴이 없는 줄만 출력합니다.',
   'grep -v DEBUG /var/log/app/app.log > /tmp/no_debug.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/no_debug.txt ] && grep -v DEBUG /var/log/app/app.log | cmp -s - /tmp/no_debug.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  6, '에러 메시지까지 파일로 저장하기',
   'ls /etc/hostname /nonexistent 를 실행해서 정상 출력과 에러 메시지를 모두 /tmp/both.txt 에 저장하세요. 화면에는 아무것도 나오지 않아야 합니다.',
   '> 는 정상 출력(1번)만 저장합니다. 에러(2번)까지 같은 파일로 보내려면 2>&1 을 뒤에 붙입니다.',
   'ls /etc/hostname /nonexistent > /tmp/both.txt 2>&1',
   NULL,
   '["sh", "-c", "grep -q ''/etc/hostname'' /tmp/both.txt && grep -q ''No such file'' /tmp/both.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  7, '기존 파일에 내용 이어 쓰기',
   '/tmp/notes.txt 에 이미 한 줄이 있습니다. 기존 내용을 지우지 말고 ''second line'' 한 줄을 뒤에 추가하세요.',
   '> 는 덮어쓰고 >> 는 이어 씁니다.',
   'echo ''second line'' >> /tmp/notes.txt',
   '["sh", "-c", "echo ''first line'' > /tmp/notes.txt"]',
   '["sh", "-c", "[ \\\"$(head -n 1 /tmp/notes.txt)\\\" = ''first line'' ] && [ \\\"$(sed -n 2p /tmp/notes.txt)\\\" = ''second line'' ] && [ \\\"$(wc -l < /tmp/notes.txt)\\\" -eq 2 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  8, '접속 IP 목록 뽑기',
   '/var/log/app/access.log 의 각 줄에서 첫 번째 칸(접속 IP)만 뽑아 /tmp/ips.txt 에 저장하세요.',
   'cut -d" " -f1 처럼 구분자와 필드 번호를 지정하거나, awk ''{print $1}'' 을 사용합니다.',
   'cut -d'' '' -f1 /var/log/app/access.log > /tmp/ips.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/ips.txt ] && awk ''{print $1}'' /var/log/app/access.log | cmp -s - /tmp/ips.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15,  9, '고유 IP만 남기기',
   '/var/log/app/access.log 에 접속한 IP를 중복 없이 정렬해서 /tmp/unique_ips.txt 에 저장하세요.',
   'uniq 는 바로 이웃한 중복만 합치므로 먼저 sort 로 정렬해야 합니다.',
   'awk ''{print $1}'' /var/log/app/access.log | sort | uniq > /tmp/unique_ips.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/unique_ips.txt ] && awk ''{print $1}'' /var/log/app/access.log | sort -u | cmp -s - /tmp/unique_ips.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15, 10, '접속 많은 IP 상위 3개',
   '/var/log/app/access.log 에서 접속 횟수가 많은 IP 상위 3개를 횟수와 함께 /tmp/top3.txt 에 저장하세요. (많은 순서)',
   'sort | uniq -c 로 횟수를 세고, sort -rn 으로 큰 숫자부터 정렬한 뒤 head -n 3 으로 자릅니다.',
   'awk ''{print $1}'' /var/log/app/access.log | sort | uniq -c | sort -rn | head -n 3 > /tmp/top3.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/top3.txt ] && [ \\\"$(awk ''{print $1,$2}'' /tmp/top3.txt)\\\" = \\\"$(awk ''{print $1}'' /var/log/app/access.log | sort | uniq -c | sort -rn | head -n 3 | awk ''{print $1,$2}'')\\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15, 11, '500 에러가 난 URL만 뽑기',
   '/var/log/app/access.log 에서 상태 코드가 500 인 요청의 URL(7번째 칸)만 뽑아 /tmp/err_urls.txt 에 저장하세요.',
   'awk 는 조건과 동작을 함께 씁니다: awk ''$9==500 {print $7}'' 파일. 9번째 칸이 상태 코드입니다.',
   'awk ''$9==500 {print $7}'' /var/log/app/access.log > /tmp/err_urls.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/err_urls.txt ] && awk ''$9==500 {print $7}'' /var/log/app/access.log | cmp -s - /tmp/err_urls.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 15, 12, '설정 값 한 줄 바꾸기',
   '/etc/app/app.conf 의 port=8080 을 port=9090 으로 바꾸세요. 다른 줄은 그대로 두어야 합니다.',
   'sed -i ''s/찾을것/바꿀것/'' 파일 은 파일을 직접 고칩니다.',
   'sed -i ''s/port=8080/port=9090/'' /etc/app/app.conf',
   NULL,
   '["sh", "-c", "F=/etc/app/app.conf; grep -qx ''port=9090'' $F && grep -qx ''host=0.0.0.0'' $F && grep -qx ''timeout=30'' $F && ! grep -q 8080 $F && [ \\\"$(wc -l < $F)\\\" -eq 6 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 15 AND order_index = 12);
