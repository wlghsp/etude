-- 세트 35: 리눅스 반복 작업 한 줄로 끝내기 (order 1~10, 9·10 은 객관식)
-- for / while read 반복문을 터미널 한 줄로 직접 해 보며 익힌다. docs/specs/spec_loop_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (35, 1, 'for 로 같은 일을 여러 번 반복하기',
   '같은 명령을 값만 바꿔 여러 번 실행해야 할 때가 많습니다. `for` 반복문은 **목록의 항목을 하나씩 변수에 담아** 같은 명령을 반복합니다. 형태는 `for 변수 in 항목1 항목2 ...; do 명령; done` 입니다. 명령 안에서는 `$변수` 로 지금 항목을 꺼냅니다.

`a`, `b`, `c` 세 글자를 `for` 로 **한 줄에 하나씩** 출력하고, 그 결과를 `/tmp/for1.txt` 에 저장하세요.

완료 조건: 파일이 `a`, `b`, `c` 세 줄이어야 합니다.',
   '`for x in a b c; do echo $x; done` 처럼 씁니다. (`for x in a b c` : `x` 에 a, b, c 를 차례로 담음, `do ... done` : 그 사이 명령을 반복, `;` : 명령을 끝내고 다음으로) 반복문 전체의 출력은 `done` 뒤에 `> 파일` 을 붙여 저장합니다.',
   'for x in a b c; do echo $x; done > /tmp/for1.txt

# for x in a b c : x 에 a, b, c 를 차례로 담는다
# do echo $x; done : 담긴 값을 출력하는 것을 3번 반복
# > /tmp/for1.txt : 반복문 전체의 출력을 파일에 저장',
   NULL,
   '["sh", "-c", "[ \\"$(tr ''\\\\n'' '','' < /tmp/for1.txt)\\" = ''a,b,c,'' ]"]'),

  (35, 2, '파일 여러 개를 한 번에 처리하기 (*.log 반복)',
   '`/tmp/logs` 에는 `.log` 파일이 여러 개 있습니다. 파일마다 같은 일을 해야 할 때는 `for` 의 목록 자리에 **와일드카드(`*`)** 를 씁니다. 쉘이 `*.log` 를 실제 파일 이름 목록으로 바꿔 줍니다.

`/tmp/logs` 의 `.log` 파일을 하나씩 돌며 **줄 수만** 한 줄씩 `/tmp/line_counts.txt` 에 저장하세요. (파일 이름은 빼고 숫자만, 파일 이름순으로)

완료 조건: 파일이 `1`, `2`, `3` 세 줄이어야 합니다.',
   '`for f in /tmp/logs/*.log; do ...; done` 으로 파일을 하나씩 `f` 에 담습니다. 파일 이름 없이 숫자만 얻으려면 `wc -l < $f` 처럼 `<` 로 입력을 넣습니다. (`wc -l 파일` 은 뒤에 파일 이름이 붙습니다) 반복문 전체 출력을 `done > 파일` 로 저장합니다.',
   'for f in /tmp/logs/*.log; do wc -l < $f; done > /tmp/line_counts.txt

# /tmp/logs/*.log : 쉘이 .log 파일 목록으로 바꿔 줌 (이름순)
# wc -l < $f : 파일 이름 없이 줄 수만
# done > ... : 반복 결과를 한 파일에 저장',
   '["sh", "-c", "mkdir -p /tmp/logs && printf ''x\\\\n'' > /tmp/logs/a.log && printf ''x\\\\ny\\\\n'' > /tmp/logs/b.log && printf ''x\\\\ny\\\\nz\\\\n'' > /tmp/logs/c.log"]',
   '["sh", "-c", "[ \\"$(tr -d '' '' < /tmp/line_counts.txt | tr ''\\\\n'' '','')\\" = ''1,2,3,'' ]"]'),

  (35, 3, 'seq 로 숫자 범위를 반복해 파일 만들기',
   '숫자를 1부터 N까지 반복해야 할 때는 `seq` 를 씁니다. `seq 1 5` 는 `1 2 3 4 5` 를 한 줄씩 출력합니다. 쉘에서 `$(명령)` 은 **명령의 결과로 바뀌므로**, `for i in $(seq 1 5)` 는 `for i in 1 2 3 4 5` 와 같습니다.

`/tmp/seq` 디렉터리에 `file1.txt` 부터 `file5.txt` 까지 **5개의 빈 파일**을 반복문으로 만드세요.

완료 조건: `/tmp/seq` 에 `file1.txt` ... `file5.txt` 가 있어야 합니다.',
   '`for i in $(seq 1 5); do touch /tmp/seq/file$i.txt; done` 입니다. (`seq 1 5` : 1부터 5까지 숫자 출력, `$(...)` : 괄호 안 명령의 결과로 대체, `touch` : 빈 파일 만들기, `file$i.txt` : `$i` 자리에 숫자가 들어감) bash 에서는 `{1..5}` 로도 쓸 수 있습니다.',
   'for i in $(seq 1 5); do touch /tmp/seq/file$i.txt; done

# $(seq 1 5) : 1 2 3 4 5 로 대체
# file$i.txt : file1.txt ~ file5.txt
ls /tmp/seq',
   '["sh", "-c", "mkdir -p /tmp/seq"]',
   '["sh", "-c", "[ \\"$(ls /tmp/seq | wc -l)\\" -eq 5 ] && [ -f /tmp/seq/file1.txt ] && [ -f /tmp/seq/file5.txt ]"]'),

  (35, 4, '확장자를 한꺼번에 바꾸기',
   '파일이 수십 개일 때 이름을 하나씩 바꾸는 것은 비효율적입니다. 반복문과 **변수에서 일부를 떼는 문법**으로 한 번에 바꿀 수 있습니다. `${f%.txt}` 는 변수 `f` 의 값에서 **끝의 `.txt` 를 뗀 값**입니다. (예: `f=/tmp/a.txt` 이면 `/tmp/a`)

`/tmp/ren` 의 `.txt` 파일을 모두 `.bak` 로 이름을 바꾸세요. (예: `a.txt` → `a.bak`)

완료 조건: `.bak` 파일이 3개이고 `.txt` 파일은 없어야 합니다.',
   '`for f in /tmp/ren/*.txt; do mv "$f" "${f%.txt}.bak"; done` 입니다. (`mv 옛이름 새이름` : 이름 바꾸기, `${f%.txt}` : `f` 에서 끝의 `.txt` 를 뗌, 뒤에 `.bak` 를 붙여 새 이름, 큰따옴표 `"..."` : 이름에 공백이 있어도 안전하게) 실행 전에 `echo mv ...` 처럼 앞에 `echo` 를 붙여 먼저 확인해 보는 습관을 들이세요.',
   'for f in /tmp/ren/*.txt; do mv "$f" "${f%.txt}.bak"; done

# ${f%.txt} : f 의 값에서 끝의 .txt 를 뗀 값
# mv "$f" "...bak" : 옛 이름을 새 이름으로
ls /tmp/ren',
   '["sh", "-c", "mkdir -p /tmp/ren && touch /tmp/ren/a.txt /tmp/ren/b.txt /tmp/ren/c.txt"]',
   '["sh", "-c", "[ \\"$(ls /tmp/ren/*.bak | wc -l)\\" -eq 3 ] && ! ls /tmp/ren/*.txt >/dev/null 2>&1"]'),

  (35, 5, '서버 목록을 돌며 이름이 해석되는지 확인하기',
   '서버가 여러 대일 때 하나씩 확인하는 일을 반복문으로 합니다. 이 서버에는 `web1`, `web2`, `db1` 세 이름이 등록되어 있습니다. `getent hosts 이름` 은 그 이름이 **어떤 IP 로 해석되는지** 보여 줍니다.

세 이름을 반복문으로 돌며 `getent hosts` 결과를 `/tmp/hosts_check.txt` 에 저장하세요.

완료 조건: 파일에 `web1`, `web2`, `db1` 이 한 줄씩 모두 있어야 합니다.',
   '`for h in web1 web2 db1; do getent hosts $h; done > /tmp/hosts_check.txt` 입니다. (`for h in 목록` : 서버 이름을 `h` 에 하나씩 담음, `getent hosts $h` : 그 이름의 IP 를 출력) 이름 목록이 길면 공백으로 계속 이어 쓰면 됩니다.',
   'for h in web1 web2 db1; do getent hosts $h; done > /tmp/hosts_check.txt

# for h in web1 web2 db1 : 서버 이름을 하나씩 h 에
# getent hosts $h : 이름 → IP 해석 결과
cat /tmp/hosts_check.txt',
   '["sh", "-c", "printf ''127.0.0.2 web1\\\\n127.0.0.3 web2\\\\n127.0.0.4 db1\\\\n'' >> /etc/hosts"]',
   '["sh", "-c", "[ \\"$(grep -cE ''web1|web2|db1'' /tmp/hosts_check.txt)\\" = 3 ]"]'),

  (35, 6, 'while read 로 파일을 한 줄씩 읽어 처리하기',
   '`for` 가 **정해진 목록**을 도는 반면, `while read` 는 **파일을 한 줄씩 읽으며** 반복합니다. 목록을 파일로 관리할 때 씁니다. 형태는 `while read 변수; do 명령; done < 파일` 이고, 끝의 `< 파일` 이 읽을 파일을 반복문 전체의 입력으로 넣습니다.

`/tmp/users.txt` 에는 이름이 한 줄에 하나씩 있습니다. 각 이름 앞에 `hello ` 를 붙인 줄(예: `hello alice`)을 `/tmp/hello.txt` 에 저장하세요.

완료 조건: 파일이 `hello alice`, `hello bob`, `hello carol` 세 줄이어야 합니다.',
   '`while read name; do echo "hello $name"; done < /tmp/users.txt > /tmp/hello.txt` 입니다. (`read name` : 한 줄을 읽어 `name` 에 담고, 더 읽을 줄이 없으면 반복이 끝남, `done < 파일` : 읽을 파일을 지정, 맨 뒤 `> 파일` : 결과 저장) `< 파일` 이 `done` 바로 뒤에 온다는 점에 주의하세요.',
   'while read name; do echo "hello $name"; done < /tmp/users.txt > /tmp/hello.txt

# read name : 한 줄을 읽어 name 에 담음 (끝나면 반복 종료)
# done < /tmp/users.txt : 반복문 전체가 이 파일을 읽음
cat /tmp/hello.txt',
   '["sh", "-c", "printf ''alice\\\\nbob\\\\ncarol\\\\n'' > /tmp/users.txt"]',
   '["sh", "-c", "[ \\"$(tr ''\\\\n'' '','' < /tmp/hello.txt)\\" = ''hello alice,hello bob,hello carol,'' ]"]'),

  (35, 7, '반복문 안에서 조건으로 골라 처리하기',
   '반복문 안에 조건을 넣으면 **골라서** 처리할 수 있습니다. `/tmp/chk` 에는 내용이 있는 파일과 **크기가 0인(빈) 파일**이 섞여 있습니다. `[ -s 파일 ]` 은 파일 **크기가 0이 아니면 참**입니다.

`/tmp/chk` 의 `.txt` 파일을 하나씩 확인해서 **빈 파일만 삭제**하세요. (내용이 있는 파일은 남깁니다)

완료 조건: `/tmp/chk` 에 내용이 있는 `a.txt` 와 `d.txt` 만 남아야 합니다.',
   '`for f in /tmp/chk/*.txt; do [ -s "$f" ] || rm "$f"; done` 입니다. (`[ -s "$f" ]` : 파일 크기가 0이 아니면 성공, `||` : 앞이 **실패했을 때만** 뒤 명령을 실행하므로 빈 파일일 때만 `rm`) `if [ ! -s "$f" ]; then rm "$f"; fi` 로도 쓸 수 있습니다. (`!` 는 반대)',
   'for f in /tmp/chk/*.txt; do [ -s "$f" ] || rm "$f"; done

# [ -s "$f" ] : 크기가 0 이 아니면 참
# || rm "$f" : 빈 파일일 때(앞이 실패)만 삭제
ls /tmp/chk',
   '["sh", "-c", "mkdir -p /tmp/chk && echo data > /tmp/chk/a.txt && : > /tmp/chk/b.txt && : > /tmp/chk/c.txt && echo data > /tmp/chk/d.txt"]',
   '["sh", "-c", "[ \\"$(ls /tmp/chk | tr ''\\\\n'' '','')\\" = ''a.txt,d.txt,'' ]"]'),

  (35, 8, '조건을 만나면 반복을 멈추기 (break)',
   '반복 도중에 **특정 조건을 만나면 멈추고** 싶을 때 `break` 를 씁니다. (`continue` 는 그 차례만 건너뛰고 다음 항목으로 갑니다) `/tmp/brk` 에는 `a.txt b.txt c.txt stop.txt z.txt` 가 있습니다.

`/tmp/brk` 의 파일을 이름순으로 돌며 **파일 이름을 한 줄씩** `/tmp/seen.txt` 에 기록하되, 이름이 `stop.txt` 인 파일을 만나면 **그 파일은 기록하지 않고 반복을 멈추세요.**

완료 조건: 파일이 `a.txt`, `b.txt`, `c.txt` 세 줄이어야 합니다.',
   '`for f in /tmp/brk/*; do n=$(basename $f); [ "$n" = stop.txt ] && break; echo $n; done > /tmp/seen.txt` 입니다. (`basename 경로` : 경로에서 파일 이름만, `[ "$n" = stop.txt ]` : 같으면 참, `&& break` : 참이면 반복을 멈춤) `break` 가 실행되면 그 뒤의 `echo` 는 실행되지 않습니다.',
   'for f in /tmp/brk/*; do n=$(basename $f); [ "$n" = stop.txt ] && break; echo $n; done > /tmp/seen.txt

# basename $f : 경로에서 파일 이름만
# && break : stop.txt 이면 반복을 멈춤 (그 뒤 echo 는 안 함)
cat /tmp/seen.txt',
   '["sh", "-c", "mkdir -p /tmp/brk && touch /tmp/brk/a.txt /tmp/brk/b.txt /tmp/brk/c.txt /tmp/brk/stop.txt /tmp/brk/z.txt"]',
   '["sh", "-c", "[ \\"$(tr ''\\\\n'' '','' < /tmp/seen.txt)\\" = ''a.txt,b.txt,c.txt,'' ]"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation) VALUES
  (35, 9, 'for f in $(ls) 가 공백이 있는 파일 이름에서 깨지는 이유',
   '`/tmp/sp` 에는 파일이 **2개** 있습니다. `my file.txt`(이름에 공백이 있음)와 `b.txt` 입니다. 터미널에서 `cd /tmp/sp` 로 이동해 아래 두 가지를 실행하고 결과를 비교해 보세요.

- `for f in $(ls); do echo "[$f]"; done`
- `for f in *; do echo "[$f]"; done`

첫 번째는 **3개 항목**으로 나오고 두 번째는 **2개**로 나옵니다. 첫 번째가 파일 이름을 잘못 나누는 **이유**를 고르세요.',
   '`$(ls)` 는 `ls` 의 출력 **글자**로 바뀐 뒤 쉘이 공백을 기준으로 **단어를 나눕니다.** 반면 `*` 는 쉘이 파일 이름 목록을 직접 만들어서, 이름 안의 공백을 건드리지 않습니다.',
   NULL,
   '["sh", "-c", "mkdir -p /tmp/sp && touch ''/tmp/sp/my file.txt'' /tmp/sp/b.txt"]',
   '[]',
   'choice',
   '["`ls` 가 공백이 있는 파일 이름을 잘못 출력해서", "`$(ls)` 의 결과를 쉘이 **공백으로 단어를 나누기** 때문에 `my file.txt` 가 `my` 와 `file.txt` 둘로 쪼개진다", "`for` 가 한 번에 3개씩만 처리해서", "리눅스는 이름에 공백이 있는 파일을 지원하지 않아서"]',
   1,
   '정답은 **B** 입니다. `for f in $(ls)` 에서 쉘은 `ls` 의 출력 `my file.txt`, `b.txt` 를 글자로 받아 **공백을 기준으로 단어를 나눕니다.** 그래서 `my`, `file.txt`, `b.txt` 3개 항목이 됩니다. `for f in *` 는 쉘이 파일 이름 목록을 직접 만들어 공백이 있어도 `my file.txt` 를 한 항목으로 둡니다.

**원리:** 쉘은 명령을 실행하기 전에 `$( )` 같은 치환 결과를 **단어 분리(word splitting)** 합니다. 공백, 탭, 줄바꿈이 구분자입니다. 와일드카드(`*`)는 분리가 아니라 파일 이름 자체를 항목으로 만들기 때문에 안전합니다. 변수를 쓸 때 `"$f"` 처럼 큰따옴표로 감싸는 이유도 같습니다. (감싸면 값 안의 공백으로 나뉘지 않습니다)

- A `ls` 는 파일 이름을 정확히 출력합니다. 나뉘는 건 그다음 쉘의 처리입니다.
- C `for` 에는 개수 제한이 없습니다.
- D 공백이 있는 이름도 지원합니다. 다만 다룰 때 따옴표나 `*` 로 조심해야 합니다.

확인: `cd /tmp/sp; for f in $(ls); do echo "[$f]"; done`'),

  (35, 10, '반복문 뒤에 파이프를 이어 결과 읽기',
   '반복문 전체의 출력도 하나의 결과이므로 `done` 뒤에 파이프(`|`)를 이어 다른 명령에 넘길 수 있습니다. `/tmp/g` 에는 `.txt` 파일 3개와 `.log` 파일 1개가 있습니다.

터미널에서 아래 한 줄을 실행해 보고, 이 명령이 **화면에 출력하는 값**을 고르세요.

`for f in /tmp/g/*.txt; do echo $f; done | wc -l`',
   '반복문은 `/tmp/g/*.txt` 에 해당하는 파일마다 `echo` 로 한 줄을 출력합니다. 그 전체 출력이 `|` 로 `wc -l` 에 넘어가 **줄 수**를 셉니다. `*.txt` 는 `.txt` 파일만 고른다는 점에 주의하세요.',
   NULL,
   '["sh", "-c", "mkdir -p /tmp/g && touch /tmp/g/a.txt /tmp/g/b.txt /tmp/g/c.txt /tmp/g/d.log"]',
   '[]',
   'choice',
   '["4", "3", "1", "0"]',
   1,
   '정답은 **B 3** 입니다. `*.txt` 에 해당하는 파일은 `a.txt`, `b.txt`, `c.txt` 세 개이므로 `echo` 가 3줄을 출력하고, `wc -l` 이 그 줄 수 3 을 셉니다.

**원리:** `for ... done` 은 하나의 명령 묶음이라 **전체 출력**을 파이프나 리다이렉션으로 이어 쓸 수 있습니다. 반복 한 번마다 출력된 줄이 쌓여 뒤 명령에 한꺼번에 흘러갑니다. 반복문 안에서 파이프로 처리한 결과와 반복문 밖에서 합쳐 처리한 결과는 다를 수 있으니, 어디에 파이프를 거는지가 중요합니다.

- A 4 : `d.log` 까지 센 값입니다. `*.txt` 에는 `.log` 가 포함되지 않습니다.
- C 1 : 반복 한 번의 출력 줄 수입니다. 반복문 전체 출력은 3줄입니다.
- D 0 : `.txt` 파일이 있으므로 0이 아닙니다.

확인: `for f in /tmp/g/*.txt; do echo $f; done | wc -l`');
