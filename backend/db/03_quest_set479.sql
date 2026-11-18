-- 세트 479: 쉘 스크립트 손연습: "$@"·shift, getopts, set -eu, 배열·연관 배열, read 와 here-string, 함수 local, trap EXIT
-- 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다. docs/specs/spec_linux_script_lab_set.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (479, 1, '인자를 하나씩 따로 다루기 ("$@")', '**배경** — 스크립트가 받은 인자는 `$1 $2 …` 이고, 전부는 `"$@"` 로 씁니다. 큰따옴표 안의 `"$@"` 는 **인자 하나하나를 그대로 따로** 넘겨서, 공백이 든 인자(`"a b"`)도 한 덩어리로 유지됩니다. (`$*` 는 다르게 동작합니다.)

**문제** — `/tmp/lab/args.sh` 를 만드세요. 받은 인자를 **한 줄에 하나씩** 출력해야 합니다. `bash /tmp/lab/args.sh "a b" c` 를 실행하면 `a b` 와 `c` 두 줄이 나와야 합니다.', '`for a in "$@"; do echo "$a"; done` — 반드시 큰따옴표로 감싸요.', 'cat > /tmp/lab/args.sh <<''EOF''
#!/bin/bash
for a in "$@"; do echo "$a"; done
EOF
bash /tmp/lab/args.sh "a b" c

# "$@" 는 인자 경계를 보존한다. 따옴표 없이 $@ 를 쓰면 공백에서 쪼개진다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ -f /tmp/lab/args.sh ] ) && ( [ \\"$(bash /tmp/lab/args.sh \\"a b\\" c | wc -l)\\" -eq 2 ] ) && ( [ \\"$(bash /tmp/lab/args.sh \\"a b\\" c | head -n 1)\\" = \\"a b\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파일이 있다", "cmd": ["sh", "-c", "[ -f /tmp/lab/args.sh ]"]}, {"label": "인자 2개가 2줄로 나온다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/args.sh \\"a b\\" c | wc -l)\\" -eq 2 ]"]}, {"label": "첫 줄이 \\"a b\\" 다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/args.sh \\"a b\\" c | head -n 1)\\" = \\"a b\\" ]"]}]', '[{"title": "Bash 매뉴얼 — 위치 매개변수", "url": "https://www.gnu.org/software/bash/manual/bash.html#Positional-Parameters"}]'),
  (479, 2, '인자를 하나씩 밀어내며 합 구하기 (shift)', '**배경** — `shift` 는 인자를 **왼쪽으로 한 칸씩 밀어** `$1` 을 버리고 `$2` 가 `$1` 이 되게 합니다. `$#`(남은 인자 수)와 함께 `while [ $# -gt 0 ]` 로 인자를 모두 소비하는 반복을 만듭니다.

**문제** — `/tmp/lab/sum.sh` 를 만드세요. 받은 **모든 숫자 인자의 합**을 한 줄로 출력해야 합니다. `bash /tmp/lab/sum.sh 1 2 3 4` 는 `10` 을 출력합니다. (`while` 과 `shift` 를 쓰세요.)', '`total=0; while [ $# -gt 0 ]; do total=$((total + $1)); shift; done; echo $total`', 'cat > /tmp/lab/sum.sh <<''EOF''
#!/bin/bash
total=0
while [ $# -gt 0 ]; do
  total=$((total + $1))
  shift
done
echo $total
EOF
bash /tmp/lab/sum.sh 1 2 3 4

# shift 로 $1 을 소비하며 $# 가 0 이 될 때까지 돈다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/sum.sh 1 2 3 4)\\" = 10 ] ) && ( [ \\"$(bash /tmp/lab/sum.sh 5 7)\\" = 12 ] ) && ( [ \\"$(bash /tmp/lab/sum.sh)\\" = 0 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "1 2 3 4 의 합은 10", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/sum.sh 1 2 3 4)\\" = 10 ]"]}, {"label": "5 와 7 의 합은 12", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/sum.sh 5 7)\\" = 12 ]"]}, {"label": "인자가 없으면 0", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/sum.sh)\\" = 0 ]"]}]', '[{"title": "Bash 매뉴얼 — shift 내장 명령", "url": "https://www.gnu.org/software/bash/manual/bash.html#Bourne-Shell-Builtins"}]'),
  (479, 3, '옵션 해석하기 (getopts)', '**배경** — 명령줄 옵션(`-n 이름`, `-v`)은 `getopts` 로 해석합니다. `getopts "n:v" opt` 에서 `n:` 의 콜론은 **값을 받는 옵션**이라는 뜻이고, 받은 값은 `$OPTARG` 에 들어갑니다. `while getopts … ; do case $opt in … esac; done` 형태로 씁니다.

**문제** — `/tmp/lab/greet.sh` 를 만드세요. `-n 이름` 으로 받은 이름으로 `hello 이름` 을 출력하고, `-v` 가 있으면 **그 다음 줄에** `verbose` 를 출력합니다. `bash /tmp/lab/greet.sh -v -n lee` 는 `hello lee` 와 `verbose` 두 줄을 냅니다.', '옵션 문자열은 `"n:v"`. `-n` 의 값은 `$OPTARG`, 출력은 루프가 끝난 뒤에 해요.', 'cat > /tmp/lab/greet.sh <<''EOF''
#!/bin/bash
name=""; verbose=0
while getopts "n:v" opt; do
  case $opt in
    n) name=$OPTARG ;;
    v) verbose=1 ;;
  esac
done
echo "hello $name"
[ $verbose -eq 1 ] && echo verbose
EOF
bash /tmp/lab/greet.sh -v -n lee

# 옵션 순서는 상관없다. 루프에서 값만 모으고 출력은 루프 뒤에 한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/greet.sh -n kim)\\" = \\"hello kim\\" ] ) && ( [ \\"$(bash /tmp/lab/greet.sh -v -n lee | tr \\"\\\\n\\" ,)\\" = \\"hello lee,verbose,\\" ] ) && ( [ \\"$(bash /tmp/lab/greet.sh -n lee -v | tr \\"\\\\n\\" ,)\\" = \\"hello lee,verbose,\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "-n kim 은 hello kim 한 줄", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/greet.sh -n kim)\\" = \\"hello kim\\" ]"]}, {"label": "-v -n lee 는 hello lee, verbose 두 줄", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/greet.sh -v -n lee | tr \\"\\\\n\\" ,)\\" = \\"hello lee,verbose,\\" ]"]}, {"label": "-n lee -v 처럼 순서가 달라도 같다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/greet.sh -n lee -v | tr \\"\\\\n\\" ,)\\" = \\"hello lee,verbose,\\" ]"]}]', '[{"title": "Bash 매뉴얼 — getopts 내장 명령", "url": "https://www.gnu.org/software/bash/manual/bash.html#Bourne-Shell-Builtins"}]'),
  (479, 4, '오류에서 멈추는 스크립트 (set -eu)', '**배경** — 스크립트 맨 위의 `set -e` 는 **명령 하나가 실패하면 즉시 종료**하게 하고, `set -u` 는 **정의되지 않은 변수를 쓰면 오류**로 멈추게 합니다. 오타 난 변수로 엉뚱한 곳(`rm -rf "$DIR/"`)을 지우는 사고를 막는 기본 습관입니다. 합쳐서 `set -eu` 로 씁니다.

**문제** — `/tmp/lab/strict.sh` 를 만드세요. 첫 줄에 `set -eu` 를 두고, `start` 를 출력한 뒤 **정의되지 않은 변수 `$UNSET_VAR`** 를 출력하는 `echo` 를 실행하고, 마지막에 `end` 를 출력합니다. 실행하면 `start` 만 나오고 **0 이 아닌 종료 코드**로 끝나야 합니다.', '`set -eu` → `echo start` → `echo "$UNSET_VAR"` → `echo end`', 'cat > /tmp/lab/strict.sh <<''EOF''
#!/bin/bash
set -eu
echo start
echo "$UNSET_VAR"
echo end
EOF
bash /tmp/lab/strict.sh; echo "종료 코드: $?"

# set -u 라서 정의 안 된 변수를 읽는 순간 멈춘다. end 는 출력되지 않는다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/strict.sh 2>/dev/null)\\" = start ] ) && ( bash /tmp/lab/strict.sh >/dev/null 2>&1; [ $? -ne 0 ] ) && ( grep -q \\"set -eu\\" /tmp/lab/strict.sh )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 start 뿐이다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/strict.sh 2>/dev/null)\\" = start ]"]}, {"label": "종료 코드가 0 이 아니다", "cmd": ["sh", "-c", "bash /tmp/lab/strict.sh >/dev/null 2>&1; [ $? -ne 0 ]"]}, {"label": "스크립트에 set -eu 가 있다", "cmd": ["sh", "-c", "grep -q \\"set -eu\\" /tmp/lab/strict.sh"]}]', '[{"title": "Bash 매뉴얼 — set 내장 명령", "url": "https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin"}]'),
  (479, 5, '배열 만들고 더하기', '**배경** — 배열은 `names=(kim lee park)` 로 만들고, `${#names[@]}` 는 **원소 개수**, `${names[2]}` 는 **인덱스 2의 원소**(0부터 셉니다), `names+=(choi)` 는 **끝에 추가**입니다.

**문제** — `/tmp/lab/arr.sh` 를 만드세요. 배열 `kim lee park` 에 `choi` 를 **추가**한 뒤, 첫 줄에 **원소 개수**, 둘째 줄에 **마지막 원소(`choi`)** 를 출력합니다. (인덱스 번호로 꺼내세요.)', '`names=(kim lee park)` → `names+=(choi)` → `${#names[@]}` 와 `${names[3]}`', 'cat > /tmp/lab/arr.sh <<''EOF''
#!/bin/bash
names=(kim lee park)
names+=(choi)
echo ${#names[@]}
echo ${names[3]}
EOF
bash /tmp/lab/arr.sh

# ${#배열[@]} 는 개수, 인덱스는 0부터. 마지막 원소 인덱스는 개수 - 1', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/arr.sh | tr \\"\\\\n\\" ,)\\" = \\"4,choi,\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 4 와 choi 두 줄이다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/arr.sh | tr \\"\\\\n\\" ,)\\" = \\"4,choi,\\" ]"]}]', '[{"title": "Bash 매뉴얼 — 배열", "url": "https://www.gnu.org/software/bash/manual/bash.html#Arrays"}]'),
  (479, 6, '이름으로 찾는 배열 (연관 배열)', '**배경** — `declare -A age` 로 **연관 배열**(키-값)을 만듭니다. `age[kim]=30` 처럼 넣고, `${age[kim]}` 로 꺼내고, `${!age[@]}` 는 **키 목록**입니다. 키 순서는 보장되지 않으므로 출력하려면 `sort` 로 정렬합니다.

**문제** — `/tmp/lab/assoc.sh` 를 만드세요. `kim` 은 30, `lee` 는 25 로 저장하고, 각 키마다 `키=값` 을 한 줄씩 **키 알파벳순**으로 출력합니다 (`kim=30`, `lee=25`).', '`declare -A age` → 값 넣기 → `for k in "${!age[@]}"; do echo "$k=${age[$k]}"; done | sort`', 'cat > /tmp/lab/assoc.sh <<''EOF''
#!/bin/bash
declare -A age
age[kim]=30
age[lee]=25
for k in "${!age[@]}"; do echo "$k=${age[$k]}"; done | sort
EOF
bash /tmp/lab/assoc.sh

# 연관 배열은 bash 4 이상. 키 순서가 일정하지 않아 sort 로 고정한다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/assoc.sh | tr \\"\\\\n\\" ,)\\" = \\"kim=30,lee=25,\\" ] ) && ( grep -q \\"declare -A\\" /tmp/lab/assoc.sh )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "kim=30, lee=25 순서로 나온다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/assoc.sh | tr \\"\\\\n\\" ,)\\" = \\"kim=30,lee=25,\\" ]"]}, {"label": "declare -A 를 썼다", "cmd": ["sh", "-c", "grep -q \\"declare -A\\" /tmp/lab/assoc.sh"]}]', '[{"title": "Bash 매뉴얼 — 배열", "url": "https://www.gnu.org/software/bash/manual/bash.html#Arrays"}]'),
  (479, 7, '문자열을 변수로 쪼개기 (read 와 here-string)', '**배경** — `read -r a b <<< "10 20"` 에서 `<<<` 는 **here-string**(문자열을 표준입력으로 넣기)이고, `read` 는 공백으로 나눠 `a`, `b` 에 담습니다. 파이프(`echo … | read`)와 달리 현재 쉘에서 실행되어 변수가 남습니다.

**문제** — `/tmp/lab/split.sh` 를 만드세요. here-string `"10 20"` 을 `read` 로 변수 두 개에 나눠 담고 **두 수의 합 `30`** 을 출력합니다.', '`read -r a b <<< "10 20"` 뒤 `echo $((a + b))`', 'cat > /tmp/lab/split.sh <<''EOF''
#!/bin/bash
read -r a b <<< "10 20"
echo $((a + b))
EOF
bash /tmp/lab/split.sh

# echo "10 20" | read a b 는 서브쉘에서 읽어 변수가 사라진다. <<< 는 그렇지 않다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/split.sh)\\" = 30 ] ) && ( grep -q \\"<<<\\" /tmp/lab/split.sh )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 30 이다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/split.sh)\\" = 30 ]"]}, {"label": "here-string 을 썼다", "cmd": ["sh", "-c", "grep -q \\"<<<\\" /tmp/lab/split.sh"]}]', '[{"title": "Bash 매뉴얼 — Here 문자열", "url": "https://www.gnu.org/software/bash/manual/bash.html#Redirections"}]'),
  (479, 8, '함수로 둘 중 큰 값 고르기 (local)', '**배경** — 함수는 `이름() { … }` 로 만들고, 받은 인자는 함수 안에서 `$1 $2` 입니다. 함수 안에서만 쓰는 변수는 `local` 로 선언해 바깥 변수를 덮어쓰지 않게 합니다. 값을 돌려줄 때는 보통 `echo` 로 출력하고 `$( … )` 로 받습니다.

**문제** — `/tmp/lab/max.sh` 를 만드세요. 함수 `max` 가 두 인자 중 **큰 수**를 출력하고, 스크립트는 받은 두 인자(`$1`, `$2`)로 `max` 를 호출해 결과를 출력합니다. `bash /tmp/lab/max.sh 3 9` 는 `9` 입니다.', '`max() { local a=$1 b=$2; if [ "$a" -gt "$b" ]; then echo "$a"; else echo "$b"; fi; }` → `max "$1" "$2"`', 'cat > /tmp/lab/max.sh <<''EOF''
#!/bin/bash
max() {
  local a=$1 b=$2
  if [ "$a" -gt "$b" ]; then echo "$a"; else echo "$b"; fi
}
max "$1" "$2"
EOF
bash /tmp/lab/max.sh 3 9
bash /tmp/lab/max.sh 12 4

# local 은 함수 안에서만 쓰는 변수. 결과는 echo 로 내보낸다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/max.sh 3 9)\\" = 9 ] ) && ( [ \\"$(bash /tmp/lab/max.sh 12 4)\\" = 12 ] ) && ( grep -q \\"local \\" /tmp/lab/max.sh )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "3 9 → 9", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/max.sh 3 9)\\" = 9 ]"]}, {"label": "12 4 → 12", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/max.sh 12 4)\\" = 12 ]"]}, {"label": "local 을 썼다", "cmd": ["sh", "-c", "grep -q \\"local \\" /tmp/lab/max.sh"]}]', '[{"title": "Bash 매뉴얼 — 쉘 함수", "url": "https://www.gnu.org/software/bash/manual/bash.html#Shell-Functions"}]'),
  (479, 9, '끝날 때 꼭 정리하기 (trap EXIT)', '**배경** — `trap ''명령'' EXIT` 는 스크립트가 **어떤 이유로 끝나든**(정상, `exit 1`, 오류) 마지막에 그 명령을 실행합니다. 임시 파일 삭제 같은 **정리**에 씁니다. 종료 코드는 `trap` 이 있어도 원래 값이 유지됩니다.

**문제** — `/tmp/lab/cleanup.sh` 를 만드세요. `EXIT` 에 `cleanup` 을 출력하는 `trap` 을 걸고, `work` 를 출력한 뒤 `exit 3` 으로 끝냅니다. 실행하면 `work`, `cleanup` 이 이 순서로 나오고 종료 코드는 `3` 입니다.', '`trap ''echo cleanup'' EXIT` 를 먼저 걸고 → `echo work` → `exit 3`', 'cat > /tmp/lab/cleanup.sh <<''EOF''
#!/bin/bash
trap ''echo cleanup'' EXIT
echo work
exit 3
EOF
bash /tmp/lab/cleanup.sh; echo "종료 코드: $?"

# EXIT trap 은 exit 로 끝나도 실행된다. 종료 코드는 3 그대로다', '["sh", "-c", "rm -rf /tmp/lab /tmp/q*; mkdir -p /tmp/lab"]', '["sh", "-c", "( [ \\"$(bash /tmp/lab/cleanup.sh | tr \\"\\\\n\\" ,)\\" = \\"work,cleanup,\\" ] ) && ( bash /tmp/lab/cleanup.sh >/dev/null; [ $? -eq 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "출력이 work, cleanup 순서다", "cmd": ["sh", "-c", "[ \\"$(bash /tmp/lab/cleanup.sh | tr \\"\\\\n\\" ,)\\" = \\"work,cleanup,\\" ]"]}, {"label": "종료 코드가 3 이다", "cmd": ["sh", "-c", "bash /tmp/lab/cleanup.sh >/dev/null; [ $? -eq 3 ]"]}]', '[{"title": "Bash 매뉴얼 — trap 내장 명령", "url": "https://www.gnu.org/software/bash/manual/bash.html#Bourne-Shell-Builtins"}]'),
  (479, 10, '"$@" 와 "$*" 의 차이', '큰따옴표 안에서 `"$@"` 와 `"$*"` 의 차이로 맞는 것은 무엇일까요?', '인자의 경계가 어떻게 되는지 봐요.', NULL, NULL, '[]', 'choice', '["\\"$@\\" 는 하나의 문자열로 이어 주고, \\"$*\\" 는 인자를 하나씩 따로 준다", "\\"$@\\" 는 인자를 하나씩 따로, \\"$*\\" 는 하나의 문자열로 이어 준다", "둘은 같고 따옴표를 쓰지 않을 때만 동작이 달라진다", "\\"$@\\" 는 첫 번째 인자만, \\"$*\\" 는 마지막 인자만 준다"]', 1, 'Bash 매뉴얼은 큰따옴표 안의 "$@" 가 각 인자를 별개의 단어로 확장하고, "$*" 는 첫 글자 IFS 로 이어 붙인 단어 하나로 확장한다고 설명합니다. 인자를 그대로 넘길 때는 "$@" 를 씁니다.', NULL, NULL, NULL, '[{"title": "Bash 매뉴얼 — 위치 매개변수", "url": "https://www.gnu.org/software/bash/manual/bash.html#Positional-Parameters"}]'),
  (479, 11, '오류가 나면 즉시 중단하기', '스크립트에서 명령 하나가 **실패하면 곧바로 종료**하게 하는 옵션입니다. 빈칸을 채우세요.', '"error" 의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["e", "x", "v", "n"]', NULL, 'Bash 매뉴얼은 set -e 가 명령이 0 이 아닌 상태로 끝나면 쉘을 즉시 종료하게 한다고 설명합니다. -x 는 실행 과정을 출력하고, -v 는 읽은 줄을 출력하며, -n 은 실행 없이 문법만 검사합니다.', '[0]', 'set -{0}', NULL, '[{"title": "Bash 매뉴얼 — set 내장 명령", "url": "https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin"}]'),
  (479, 12, '견고한 스크립트 뼈대 순서', '관례적으로 많이 쓰는 스크립트 뼈대의 순서입니다. 순서에 맞게 놓아 보세요.', '실행기 → 안전장치 → 정리 → 본 작업이에요.', NULL, NULL, '[]', 'order', '["첫 줄에 `#!/bin/bash` 로 실행할 쉘을 정한다", "`set -eu` 로 오류와 미정의 변수에서 멈추게 한다", "`trap` 으로 종료할 때 할 정리 동작을 등록한다", "`getopts` 로 옵션을 해석한 뒤 본 작업을 한다"]', NULL, 'shebang 으로 실행기를 정하고, set 으로 안전장치를 켜고, trap 으로 정리를 예약한 뒤 본 작업을 하는 것이 관례적인 순서입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Bash 매뉴얼 — set 내장 명령", "url": "https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin"}]');
