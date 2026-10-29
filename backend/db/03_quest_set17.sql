-- 세트 17: 리눅스 쉘 스크립트 기초 (order 1~10)
-- 학습자가 스크립트를 만들고, 채점은 스크립트를 다른 입력으로 실행해 결과를 본다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (17,  1, '첫 쉘 스크립트 만들기',
   '쉘 스크립트는 명령어를 파일에 적어 두고 한 번에 실행하는 방법으로, 반복 작업 자동화의 시작입니다.

`/tmp/hello.sh` 를 만들어, 실행하면 화면에 `hello etude` 가 출력되게 하세요. 파일이 **직접 실행**(`/tmp/hello.sh`)되어야 합니다.',
   '스크립트 파일의 필수 요소 두 가지입니다.
1) 첫 줄에 `#!/bin/bash` (이 파일을 bash 로 실행하라는 표시, shebang)
2) 실행 권한: `chmod +x <파일>`
파일은 `cat > /tmp/hello.sh <<''EOF''` 와 `EOF` 사이에 내용을 적어서 만들거나 vim 으로 만듭니다.',
   'cat > /tmp/hello.sh <<''EOF''
#!/bin/bash
echo "hello etude"
EOF
chmod +x /tmp/hello.sh

# 실행해서 확인
/tmp/hello.sh',
   NULL,
   '["sh", "-c", "[ -x /tmp/hello.sh ] && head -n 1 /tmp/hello.sh | grep -q ''^#!'' && [ \\"$(/tmp/hello.sh)\\" = ''hello etude'' ]"]'),

  (17,  2, '인자를 받아 인사하는 스크립트 만들기',
   '스크립트는 실행할 때 값을 넘겨 받을 수 있습니다. 이 값을 **인자**라고 합니다.

`/tmp/greet.sh` 를 만드세요. 첫 번째 인자를 받아 `Hello, 인자` 형식으로 출력합니다.
예: `/tmp/greet.sh Kim` → `Hello, Kim`',
   '스크립트 안에서 첫 번째 인자는 `$1`, 두 번째는 `$2` 입니다. 앞 문제처럼 `#!/bin/bash` 로 시작하고 `chmod +x` 를 잊지 마세요. 출력에 변수를 넣으려면 큰따옴표를 씁니다: `echo "Hello, $1"`',
   'cat > /tmp/greet.sh <<''EOF''
#!/bin/bash
echo "Hello, $1"
EOF
chmod +x /tmp/greet.sh

# 확인
/tmp/greet.sh Kim',
   NULL,
   '["sh", "-c", "[ -x /tmp/greet.sh ] && head -n 1 /tmp/greet.sh | grep -q ''^#!'' && [ \\"$(/tmp/greet.sh Kim)\\" = ''Hello, Kim'' ] && [ \\"$(/tmp/greet.sh Lee)\\" = ''Hello, Lee'' ]"]'),

  (17,  3, '받은 인자의 개수 세기',
   '인자가 몇 개 들어왔는지 확인해야 하는 경우(필수 인자 검사 등)가 많습니다.

`/tmp/count_args.sh` 를 만드세요. 받은 인자의 **개수**를 출력합니다.
예: `/tmp/count_args.sh a b c` → `3`',
   '`$#` 는 인자의 개수, `$@` 는 모든 인자를 뜻합니다. 인자가 없으면 `0` 이 출력되어야 합니다.',
   'cat > /tmp/count_args.sh <<''EOF''
#!/bin/bash
echo $#
EOF
chmod +x /tmp/count_args.sh

# $# : 인자의 개수',
   NULL,
   '["sh", "-c", "[ -x /tmp/count_args.sh ] && head -n 1 /tmp/count_args.sh | grep -q ''^#!'' && [ \\"$(/tmp/count_args.sh a b c)\\" = 3 ] && [ \\"$(/tmp/count_args.sh)\\" = 0 ]"]'),

  (17,  4, '파일이 있는지 확인하는 스크립트 만들기',
   '스크립트는 **조건**에 따라 다르게 동작할 수 있습니다. 가장 자주 쓰는 조건이 파일 존재 확인입니다.

`/tmp/check_file.sh` 를 만드세요. 첫 번째 인자 경로가 **존재하면** `exists`, **없으면** `missing` 을 출력합니다.
예: `/tmp/check_file.sh /etc/hostname` → `exists`',
   '`if [ -e "$1" ]; then ... else ... fi` 형태입니다. `[ ]` 안쪽에는 양쪽에 **공백**이 있어야 합니다. `-e` 는 ''존재하는가''를 검사하는 옵션입니다.',
   'cat > /tmp/check_file.sh <<''EOF''
#!/bin/bash
if [ -e "$1" ]; then echo exists; else echo missing; fi
EOF
chmod +x /tmp/check_file.sh

# [ -e 경로 ] : 그 경로가 존재하면 참',
   NULL,
   '["sh", "-c", "[ -x /tmp/check_file.sh ] && head -n 1 /tmp/check_file.sh | grep -q ''^#!'' && [ \\"$(/tmp/check_file.sh /etc/hostname)\\" = exists ] && [ \\"$(/tmp/check_file.sh /nonexistent)\\" = missing ]"]'),

  (17,  5, '숫자를 비교하는 스크립트 만들기',
   '숫자를 비교해 분기하는 일은 임계값 검사(용량, 개수 등)의 기본입니다.

`/tmp/is_big.sh` 를 만드세요. 첫 번째 인자가 **100 이상이면** `big`, 아니면 `small` 을 출력합니다.
예: `/tmp/is_big.sh 250` → `big`, `/tmp/is_big.sh 99` → `small`',
   '쉘에서 숫자 비교는 `>` 가 아니라 `-ge`(크거나 같다), `-gt`(크다), `-lt`(작다), `-eq`(같다) 를 씁니다. (`>` 는 파일로 내보내기 기호입니다)
형태: `if [ "$1" -ge 100 ]; then ...`',
   'cat > /tmp/is_big.sh <<''EOF''
#!/bin/bash
if [ "$1" -ge 100 ]; then echo big; else echo small; fi
EOF
chmod +x /tmp/is_big.sh

# -ge : 크거나 같다 (greater or equal)',
   NULL,
   '["sh", "-c", "[ -x /tmp/is_big.sh ] && head -n 1 /tmp/is_big.sh | grep -q ''^#!'' && [ \\"$(/tmp/is_big.sh 100)\\" = big ] && [ \\"$(/tmp/is_big.sh 99)\\" = small ] && [ \\"$(/tmp/is_big.sh 250)\\" = big ]"]'),

  (17,  6, '반복문으로 1부터 N까지 더하기',
   '같은 일을 여러 번 해야 할 때 **반복문**을 씁니다.

`/tmp/seq_sum.sh` 를 만드세요. 첫 번째 인자 N 에 대해 1부터 N 까지의 **합**을 출력합니다.
예: `/tmp/seq_sum.sh 10` → `55`',
   '`for i in $(seq 1 $1); do ... done` 으로 1부터 N까지 반복합니다 (`seq 1 5` 는 1 2 3 4 5 를 출력). 합은 변수에 계속 더합니다: `sum=$((sum+i))`. 반복 전에 `sum=0` 으로 초기화하고, 반복이 끝난 뒤 `echo $sum` 하세요.',
   'cat > /tmp/seq_sum.sh <<''EOF''
#!/bin/bash
sum=0
for i in $(seq 1 $1); do
  sum=$((sum+i))
done
echo $sum
EOF
chmod +x /tmp/seq_sum.sh

# $(( )) : 산술 계산
# $(seq 1 $1) : 1 부터 $1 까지의 숫자 목록',
   NULL,
   '["sh", "-c", "[ -x /tmp/seq_sum.sh ] && head -n 1 /tmp/seq_sum.sh | grep -q ''^#!'' && [ \\"$(/tmp/seq_sum.sh 10)\\" = 55 ] && [ \\"$(/tmp/seq_sum.sh 100)\\" = 5050 ]"]'),

  (17,  7, '디렉토리 안의 로그 파일 개수 세기',
   '반복문으로 파일을 하나씩 처리하는 것은 스크립트의 가장 흔한 패턴입니다.

`/tmp/count_logs.sh` 를 만드세요. 첫 번째 인자 **디렉토리 안의 `.log` 파일 개수**를 출력합니다. 파일이 하나도 없으면 `0` 입니다.',
   '`for f in "$1"/*.log; do ... done` 으로 `.log` 파일을 하나씩 돕니다. 파일이 없으면 `*.log` 글자 그대로 남으므로 `[ -e "$f" ]` 로 실제 파일인지 확인한 뒤 개수(`n=$((n+1))`)를 올리세요.',
   'cat > /tmp/count_logs.sh <<''EOF''
#!/bin/bash
n=0
for f in "$1"/*.log; do
  [ -e "$f" ] && n=$((n+1))
done
echo $n
EOF
chmod +x /tmp/count_logs.sh

# [ -e "$f" ] && ... : 파일이 실제로 있을 때만 실행',
   NULL,
   '["sh", "-c", "[ -x /tmp/count_logs.sh ] && head -n 1 /tmp/count_logs.sh | grep -q ''^#!'' && d=$(mktemp -d); touch $d/a.log $d/b.log $d/c.log $d/x.txt; e=$(mktemp -d); [ \\"$(/tmp/count_logs.sh $d)\\" = 3 ] && [ \\"$(/tmp/count_logs.sh $e)\\" = 0 ]"]'),

  (17,  8, '종료 코드로 성공·실패 알리기',
   '스크립트가 성공했는지 실패했는지는 **종료 코드**로 다른 프로그램에 전달합니다. (`0` 성공, 그 외 실패)

`/tmp/must_have.sh` 를 만드세요. 첫 번째 인자 파일 안에 `OK` 가 **있으면 종료 코드 0**, **없으면 1** 로 끝나야 합니다. 화면 출력은 필요 없습니다.',
   '`exit 0` 은 성공, `exit 1` 은 실패로 스크립트를 끝냅니다. `grep -q OK "$1"` 의 결과(찾으면 성공)를 `if` 로 판단하세요. 확인은 실행 직후 `echo $?` 입니다.',
   'cat > /tmp/must_have.sh <<''EOF''
#!/bin/bash
if grep -q OK "$1"; then exit 0; else exit 1; fi
EOF
chmod +x /tmp/must_have.sh

# 확인
echo ''status OK'' > /tmp/yes.txt
/tmp/must_have.sh /tmp/yes.txt; echo $?   # 0 이 나와야 합니다',
   NULL,
   '["sh", "-c", "[ -x /tmp/must_have.sh ] && head -n 1 /tmp/must_have.sh | grep -q ''^#!'' && echo ''status OK'' > /tmp/yes.txt; echo ''status FAIL'' > /tmp/no.txt; /tmp/must_have.sh /tmp/yes.txt; a=$?; /tmp/must_have.sh /tmp/no.txt; b=$?; [ $a -eq 0 ] && [ $b -eq 1 ]"]'),

  (17,  9, '에러 개수가 기준을 넘으면 경고하는 스크립트',
   '모니터링 스크립트의 기본형입니다. 로그의 에러 개수를 세어 기준을 넘으면 실패로 알립니다.

`/tmp/alert.sh` 를 만드세요. 첫 번째 인자 로그 파일에서 `ERROR` 가 들어간 줄의 개수를 세어 `ERROR count: 개수` 로 출력하고, **개수가 3 이상이면 종료 코드 1, 아니면 0** 으로 끝냅니다.
연습용 로그: `/tmp/svc.log` (`ERROR` 4줄)',
   '`n=$(grep -c ERROR "$1")` 처럼 명령의 출력을 변수에 담을 수 있습니다. 출력(`echo "ERROR count: $n"`) 후 `if [ "$n" -ge 3 ]; then exit 1; fi` 로 종료 코드를 정하고 마지막에 `exit 0` 합니다.',
   'cat > /tmp/alert.sh <<''EOF''
#!/bin/bash
n=$(grep -c ERROR "$1")
echo "ERROR count: $n"
if [ "$n" -ge 3 ]; then exit 1; fi
exit 0
EOF
chmod +x /tmp/alert.sh

# 확인
/tmp/alert.sh /tmp/svc.log; echo $?',
   '["sh", "-c", "{ echo INFO ok; echo ERROR a; echo ERROR b; echo INFO ok; echo ERROR c; echo ERROR d; } > /tmp/svc.log"]',
   '["sh", "-c", "[ -x /tmp/alert.sh ] && head -n 1 /tmp/alert.sh | grep -q ''^#!'' && o=$(/tmp/alert.sh /tmp/svc.log); a=$?; echo ERROR x > /tmp/svc2.log; p=$(/tmp/alert.sh /tmp/svc2.log); b=$?; [ \\"$o\\" = ''ERROR count: 4'' ] && [ $a -eq 1 ] && [ \\"$p\\" = ''ERROR count: 1'' ] && [ $b -eq 0 ]"]'),

  (17, 10, 'CSV 파일에서 관리자만 뽑기',
   '파일을 한 줄씩 읽어 처리하는 `while read` 는 로그와 목록 처리에 자주 씁니다.

`/tmp/admins.sh` 를 만드세요. 첫 번째 인자 CSV(한 줄이 `이름,역할`)에서 역할이 `admin` 인 사람의 **이름만** 한 줄씩 출력합니다.
연습용 파일: `/tmp/members.csv`',
   '`while IFS=, read -r name role; do ... done < "$1"` 은 파일을 한 줄씩 읽으며 쉼표(`IFS=,`)로 나눠 `name`, `role` 변수에 넣습니다. 안에서 `if [ "$role" = admin ]; then echo "$name"; fi` 로 거릅니다.',
   'cat > /tmp/admins.sh <<''EOF''
#!/bin/bash
while IFS=, read -r name role; do
  if [ "$role" = admin ]; then echo "$name"; fi
done < "$1"
EOF
chmod +x /tmp/admins.sh

# 확인
/tmp/admins.sh /tmp/members.csv',
   '["sh", "-c", "{ echo kim,admin; echo park,dev; echo lee,admin; echo choi,ops; } > /tmp/members.csv"]',
   '["sh", "-c", "[ -x /tmp/admins.sh ] && head -n 1 /tmp/admins.sh | grep -q ''^#!'' && [ \\"$(/tmp/admins.sh /tmp/members.csv | paste -sd, -)\\" = kim,lee ]"]');
