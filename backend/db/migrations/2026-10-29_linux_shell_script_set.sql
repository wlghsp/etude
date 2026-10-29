-- 세트 17(리눅스 쉘 스크립트 기초) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set17.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 17, '리눅스 쉘 스크립트 기초', '변수와 인자, 조건문, 반복문, 종료 코드로 현장에서 쓰는 작은 쉘 스크립트를 직접 작성합니다.', 'linux', '리눅스' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  1, '첫 쉘 스크립트 만들기',
   '/tmp/hello.sh 를 만들어 실행하면 hello etude 가 출력되게 하세요. 직접 실행할 수 있어야 합니다 (./hello.sh).',
   '첫 줄에 #!/bin/bash (shebang)를 쓰고, chmod +x 로 실행 권한을 줍니다.',
   'cat > /tmp/hello.sh <<''EOF''
#!/bin/bash
echo "hello etude"
EOF
chmod +x /tmp/hello.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/hello.sh ] && head -n 1 /tmp/hello.sh | grep -q ''^#!'' && [ \\\"$(/tmp/hello.sh)\\\" = ''hello etude'' ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  2, '인자를 받아 인사하기',
   '/tmp/greet.sh 를 만드세요. 첫 번째 인자를 받아 Hello, 인자 형식으로 출력합니다. 예: ./greet.sh Kim → Hello, Kim',
   '스크립트 안에서 첫 번째 인자는 $1 입니다.',
   'cat > /tmp/greet.sh <<''EOF''
#!/bin/bash
echo "Hello, $1"
EOF
chmod +x /tmp/greet.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/greet.sh ] && head -n 1 /tmp/greet.sh | grep -q ''^#!'' && [ \\\"$(/tmp/greet.sh Kim)\\\" = ''Hello, Kim'' ] && [ \\\"$(/tmp/greet.sh Lee)\\\" = ''Hello, Lee'' ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  3, '인자 개수 세기',
   '/tmp/count_args.sh 를 만드세요. 받은 인자의 개수를 출력합니다. 예: ./count_args.sh a b c → 3',
   '$# 는 인자의 개수, $@ 는 모든 인자입니다.',
   'cat > /tmp/count_args.sh <<''EOF''
#!/bin/bash
echo $#
EOF
chmod +x /tmp/count_args.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/count_args.sh ] && head -n 1 /tmp/count_args.sh | grep -q ''^#!'' && [ \\\"$(/tmp/count_args.sh a b c)\\\" = 3 ] && [ \\\"$(/tmp/count_args.sh)\\\" = 0 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  4, '파일이 있는지 확인하기',
   '/tmp/check_file.sh 를 만드세요. 첫 번째 인자 경로가 존재하면 exists, 없으면 missing 을 출력합니다.',
   'if [ -e "$1" ]; then ... else ... fi 형태입니다. [ ] 안쪽에는 양쪽에 공백이 필요합니다.',
   'cat > /tmp/check_file.sh <<''EOF''
#!/bin/bash
if [ -e "$1" ]; then echo exists; else echo missing; fi
EOF
chmod +x /tmp/check_file.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/check_file.sh ] && head -n 1 /tmp/check_file.sh | grep -q ''^#!'' && [ \\\"$(/tmp/check_file.sh /etc/hostname)\\\" = exists ] && [ \\\"$(/tmp/check_file.sh /nonexistent)\\\" = missing ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  5, '숫자 비교하기',
   '/tmp/is_big.sh 를 만드세요. 첫 번째 인자가 100 이상이면 big, 아니면 small 을 출력합니다.',
   '숫자 비교는 [ "$1" -ge 100 ] 처럼 -ge, -lt, -eq 를 씁니다. (> 는 문자 비교가 아니라 리다이렉션입니다.)',
   'cat > /tmp/is_big.sh <<''EOF''
#!/bin/bash
if [ "$1" -ge 100 ]; then echo big; else echo small; fi
EOF
chmod +x /tmp/is_big.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/is_big.sh ] && head -n 1 /tmp/is_big.sh | grep -q ''^#!'' && [ \\\"$(/tmp/is_big.sh 100)\\\" = big ] && [ \\\"$(/tmp/is_big.sh 99)\\\" = small ] && [ \\\"$(/tmp/is_big.sh 250)\\\" = big ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  6, '반복문으로 합계 구하기',
   '/tmp/seq_sum.sh 를 만드세요. 첫 번째 인자 N 에 대해 1부터 N 까지의 합을 출력합니다. 예: ./seq_sum.sh 10 → 55',
   'for i in $(seq 1 $1); do ... done 과 sum=$((sum+i)) 를 사용합니다.',
   'cat > /tmp/seq_sum.sh <<''EOF''
#!/bin/bash
sum=0
for i in $(seq 1 $1); do
  sum=$((sum+i))
done
echo $sum
EOF
chmod +x /tmp/seq_sum.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/seq_sum.sh ] && head -n 1 /tmp/seq_sum.sh | grep -q ''^#!'' && [ \\\"$(/tmp/seq_sum.sh 10)\\\" = 55 ] && [ \\\"$(/tmp/seq_sum.sh 100)\\\" = 5050 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  7, '디렉토리의 로그 파일 개수 세기',
   '/tmp/count_logs.sh 를 만드세요. 첫 번째 인자 디렉토리 안의 .log 파일 개수를 출력합니다.',
   'for f in "$1"/*.log; do ... done 으로 파일을 하나씩 처리합니다. 파일이 없으면 패턴이 그대로 남으니 [ -e "$f" ] 로 확인하세요.',
   'cat > /tmp/count_logs.sh <<''EOF''
#!/bin/bash
n=0
for f in "$1"/*.log; do
  [ -e "$f" ] && n=$((n+1))
done
echo $n
EOF
chmod +x /tmp/count_logs.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/count_logs.sh ] && head -n 1 /tmp/count_logs.sh | grep -q ''^#!'' && d=$(mktemp -d); touch $d/a.log $d/b.log $d/c.log $d/x.txt; e=$(mktemp -d); [ \\\"$(/tmp/count_logs.sh $d)\\\" = 3 ] && [ \\\"$(/tmp/count_logs.sh $e)\\\" = 0 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  8, '종료 코드로 결과 알리기',
   '/tmp/must_have.sh 를 만드세요. 첫 번째 인자 파일 안에 OK 가 있으면 종료 코드 0, 없으면 1 로 끝나야 합니다. 출력은 필요 없습니다.',
   'exit 0 은 성공, exit 1 은 실패입니다. grep -q 의 종료 코드를 if 로 판단합니다.',
   'cat > /tmp/must_have.sh <<''EOF''
#!/bin/bash
if grep -q OK "$1"; then exit 0; else exit 1; fi
EOF
chmod +x /tmp/must_have.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/must_have.sh ] && head -n 1 /tmp/must_have.sh | grep -q ''^#!'' && echo ''status OK'' > /tmp/yes.txt; echo ''status FAIL'' > /tmp/no.txt; /tmp/must_have.sh /tmp/yes.txt; a=$?; /tmp/must_have.sh /tmp/no.txt; b=$?; [ $a -eq 0 ] && [ $b -eq 1 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17,  9, '에러 개수가 기준을 넘으면 경고하기',
   '/tmp/alert.sh 를 만드세요. 첫 번째 인자 로그 파일에서 ERROR 줄 개수를 세어 ERROR count: N 으로 출력하고, N 이 3 이상이면 종료 코드 1, 아니면 0 으로 끝냅니다. (예시 로그: /tmp/svc.log)',
   'n=$(grep -c ERROR "$1") 처럼 명령 결과를 변수에 담습니다. 출력 후 조건에 따라 exit 합니다.',
   'cat > /tmp/alert.sh <<''EOF''
#!/bin/bash
n=$(grep -c ERROR "$1")
echo "ERROR count: $n"
if [ "$n" -ge 3 ]; then exit 1; fi
exit 0
EOF
chmod +x /tmp/alert.sh',
   '["sh", "-c", "{ echo INFO ok; echo ERROR a; echo ERROR b; echo INFO ok; echo ERROR c; echo ERROR d; } > /tmp/svc.log"]',
   '["sh", "-c", "[ -x /tmp/alert.sh ] && head -n 1 /tmp/alert.sh | grep -q ''^#!'' && o=$(/tmp/alert.sh /tmp/svc.log); a=$?; echo ERROR x > /tmp/svc2.log; p=$(/tmp/alert.sh /tmp/svc2.log); b=$?; [ \\\"$o\\\" = ''ERROR count: 4'' ] && [ $a -eq 1 ] && [ \\\"$p\\\" = ''ERROR count: 1'' ] && [ $b -eq 0 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 17, 10, 'CSV에서 관리자만 뽑기',
   '/tmp/admins.sh 를 만드세요. 첫 번째 인자 CSV(이름,역할)에서 역할이 admin 인 사람의 이름만 한 줄씩 출력합니다. (예시 파일: /tmp/members.csv)',
   'while IFS=, read -r name role; do ... done < "$1" 로 줄을 읽으며 쉼표로 나눕니다.',
   'cat > /tmp/admins.sh <<''EOF''
#!/bin/bash
while IFS=, read -r name role; do
  if [ "$role" = admin ]; then echo "$name"; fi
done < "$1"
EOF
chmod +x /tmp/admins.sh',
   '["sh", "-c", "{ echo kim,admin; echo park,dev; echo lee,admin; echo choi,ops; } > /tmp/members.csv"]',
   '["sh", "-c", "[ -x /tmp/admins.sh ] && head -n 1 /tmp/admins.sh | grep -q ''^#!'' && [ \\\"$(/tmp/admins.sh /tmp/members.csv | paste -sd, -)\\\" = kim,lee ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 17 AND order_index = 10);
