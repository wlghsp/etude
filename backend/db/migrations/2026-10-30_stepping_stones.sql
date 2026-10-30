-- 보강 문제: 선수 지식 징검다리: 세트 1 에 상대 경로·종료 코드·--help, 세트 3 에 nohup, 세트 19 에 kubectl edit 를 추가한다. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다. docs/specs/spec_curriculum_map.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 1, 11, '상대 경로로 위로 올라가며 파일 만들기',
   '경로는 두 가지로 씁니다. **절대 경로**는 `/` 로 시작해서 항상 같은 곳을 가리키고, **상대 경로**는 **지금 있는 위치를 기준**으로 합니다. 상대 경로에서 `.` 은 지금 디렉터리, `..` 은 **한 단계 위** 디렉터리입니다.

`/tmp/a/b/c` 디렉터리가 있습니다. `cd` 로 `/tmp/a/b/c` 에 들어간 뒤, **절대 경로를 쓰지 말고 상대 경로(`../..`)만 써서** `/tmp/a/x.txt` 빈 파일을 만드세요.

완료 조건: `/tmp/a/x.txt` 가 있어야 합니다.',
   '`/tmp/a/b/c` 에서 `..` 는 `/tmp/a/b`, `../..` 는 `/tmp/a` 입니다. 그래서 `touch ../../x.txt` 는 `/tmp/a/x.txt` 를 만듭니다. (`cd` 는 이동, `touch` 는 빈 파일 만들기) 지금 위치는 `pwd` 로 확인하세요. 두 명령은 `&&` 로 이을 수 있습니다.',
   'cd /tmp/a/b/c && touch ../../x.txt

# .. : 한 단계 위 디렉터리, ../.. : 두 단계 위
# 상대 경로는 지금 위치를 기준으로 해석된다
ls /tmp/a',
   '["sh", "-c", "mkdir -p /tmp/a/b/c"]',
   '["sh", "-c", "[ -f /tmp/a/x.txt ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 1 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 1, 13, '직전 명령의 종료 코드 확인하기 ($?)',
   '명령은 끝날 때 성공(`0`)인지 실패(`0` 이 아닌 값)인지를 **숫자 하나**로 남깁니다. 이 숫자가 **종료 코드**이고, 쉘은 **직전 명령의 종료 코드**를 `$?` 에 담아 둡니다. `&&` 와 `||` 가 바로 이 값을 보고 움직입니다.

없는 디렉터리 `/no/such/dir` 을 `ls` 로 열면 실패합니다. 실행한 **직후**의 종료 코드를 `/tmp/rc.txt` 에 저장하세요.

완료 조건: 파일에 `ls` 가 남긴 종료 코드(`2`)가 들어 있어야 합니다.',
   '`ls /no/such/dir; echo $? > /tmp/rc.txt` 입니다. (`;` 는 앞 명령이 끝난 뒤 다음 명령을 실행, `$?` 는 바로 직전 명령의 종료 코드) `$?` 는 다음 명령을 실행하면 덮어써지므로 **실패한 명령 바로 뒤에** 확인해야 합니다. 성공하면 `0` 입니다.',
   'ls /no/such/dir; echo $? > /tmp/rc.txt

# $? : 직전 명령의 종료 코드 (성공 0, 실패는 0 이 아닌 값)
# ls 는 대상이 없으면 2 를 돌려준다
cat /tmp/rc.txt',
   '["sh", "-c", null]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/rc.txt)\\" = 2 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 1 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 1, 14, '--help 로 옵션 찾아 쓰기',
   '명령의 옵션을 전부 외울 필요는 없습니다. **`명령 --help`** 는 사용법과 옵션 목록을 보여 줍니다. 필요한 옵션은 도움말에서 찾아 쓰면 됩니다.

`/tmp/sz` 에는 크기가 다른 파일 세 개가 있습니다. `ls` 의 도움말에서 **크기순으로 정렬**하는 옵션을 찾아서, 큰 파일이 맨 위에 오도록 `ls -l` 형식의 목록을 `/tmp/ls_size.txt` 에 저장하세요.

완료 조건: 파일에서 가장 큰 파일(`b_big`)이 가장 먼저 나와야 합니다. (`total` 줄은 제외)',
   '도움말은 길어서 `|` 로 `grep` 에 넘겨 필요한 줄만 봅니다. 예: `ls --help | grep -i sort` 로 정렬 관련 옵션을 찾으세요. 크기순으로 정렬하는 옵션을 `-l`(자세히 보기)과 함께 쓰고, 결과를 `>` 로 저장합니다. 옵션을 안 주면 이름순으로 나옵니다.',
   'ls --help | grep -i sort   # 정렬 옵션 찾기 → -S : 크기가 큰 순서
ls -lS /tmp/sz > /tmp/ls_size.txt

# -l : 자세히 보기, -S : 파일 크기 큰 순서로 정렬
cat /tmp/ls_size.txt',
   '["sh", "-c", "mkdir -p /tmp/sz && head -c 3000 /dev/zero > /tmp/sz/b_big && head -c 2000 /dev/zero > /tmp/sz/c_mid && head -c 10 /dev/zero > /tmp/sz/a_small"]',
   '["sh", "-c", "[ \\"$(grep -v ''^total'' /tmp/ls_size.txt | head -n 1 | awk ''{print $NF}'')\\" = b_big ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 1 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 3, 12, '터미널을 닫아도 계속 실행되게 하기 (nohup)',
   '`&` 로 백그라운드에 띄운 프로세스도 **터미널 연결이 끊기면**(창을 닫거나 SSH 가 끊기면) 함께 종료될 수 있습니다. `nohup` 은 연결이 끊길 때 오는 신호(SIGHUP)를 **무시**하게 해서, 터미널이 닫혀도 계속 실행되게 합니다. 서버에서 오래 걸리는 작업을 돌릴 때 씁니다.

`sleep 300` 을 `nohup` 으로 백그라운드에서 실행하세요.

완료 조건: `sleep 300` 프로세스가 실행 중이어야 합니다.',
   '`nohup sleep 300 > /dev/null 2>&1 &` 형태입니다. (`nohup` : 끊김 신호를 무시, `> /dev/null 2>&1` : 출력과 에러를 버림 — 안 하면 `nohup.out` 파일이 생김, 맨 끝 `&` : 백그라운드 실행) 확인은 `pgrep -a sleep` 또는 `ps aux | grep sleep` 로 합니다.',
   'nohup sleep 300 > /dev/null 2>&1 &

# nohup : 터미널이 닫혀도(SIGHUP) 계속 실행
# > /dev/null 2>&1 : 출력을 버려 nohup.out 이 생기지 않게 함, & : 백그라운드
pgrep -a sleep',
   '["sh", "-c", null]',
   '["sh", "-c", "pgrep -f ''[s]leep 300'' >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 3 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 19, 11, 'kubectl edit 로 Deployment 를 직접 고치기',
   '`kubectl edit` 은 리소스의 YAML 을 **편집기(vi)로 열어 직접 고치고**, 저장하면 바로 적용합니다. 명령으로 바꾸기 번거로운 필드를 고칠 때 쓰는, 현장에서 가장 자주 쓰는 방법 중 하나입니다.

`$NS` 의 Deployment `web` 은 Pod 개수(`spec.replicas`)가 **1** 입니다. `kubectl edit` 로 **3** 으로 고치세요.

완료 조건: `web` 의 `replicas` 가 3 이어야 합니다.',
   '`kubectl edit deployment web -n $NS` 를 실행하면 vi 가 열립니다. `/replicas` + 엔터로 찾고, `i` 로 입력 모드에 들어가 숫자를 3 으로 바꾼 뒤, `Esc` 를 누르고 `:wq` 로 저장합니다. 저장하면 바로 적용됩니다. (저장하지 않고 나가면 `:q!`) 같은 결과를 내는 다른 방법(`kubectl scale`)도 있지만 이 문제는 `edit` 를 연습합니다.',
   'kubectl edit deployment web -n $NS
# vi 가 열리면: /replicas 엔터 → i → 1 을 3 으로 → Esc → :wq

# 확인
kubectl get deployment web -n $NS -o jsonpath=''{.spec.replicas}''',
   '["sh", "-c", "kubectl create deployment web --image=nginx --replicas=1 -n $NS >/dev/null 2>&1; true"]',
   '["sh", "-c", "[ \\"$(kubectl get deploy web -n $NS -o jsonpath=''{.spec.replicas}'')\\" = 3 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 19 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 1, 12, '상대 경로 ../.. 가 가리키는 곳 읽기',
   '지금 위치가 `/tmp/h/user/project/src` 일 때 `cat ../../notes.txt` 가 읽는 파일은 어느 것일까요? 이 위치의 각 디렉터리에는 `notes.txt` 가 하나씩 있고 내용이 다릅니다. 터미널에서 `cd /tmp/h/user/project/src` 로 이동해 `pwd` 로 위치를 확인하고, `cat ../../notes.txt` 를 직접 실행해서 확인해 보세요.

`../../notes.txt` 가 가리키는 파일을 고르세요.',
   '`..` 는 **한 단계 위** 디렉터리입니다. `src` 에서 `..` 는 `project`, `../..` 는 그 위입니다. 각 파일에 어느 디렉터리의 것인지 적혀 있으니 `cat` 으로 읽어 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`/tmp/h/user/project/src/notes.txt` (지금 위치의 파일)", "`/tmp/h/user/project/notes.txt`", "`/tmp/h/user/notes.txt`", "`/tmp/h/notes.txt`"]',
   2,
   '정답은 **C `/tmp/h/user/notes.txt`** 입니다. `src` 에서 `..` 는 `project`, `../..` 는 `user` 이므로 `../../notes.txt` 는 `user` 디렉터리의 `notes.txt` 입니다.

**원리:** 상대 경로는 **지금 있는 디렉터리(작업 디렉터리)** 를 출발점으로 해석됩니다. `..` 는 한 단계 위(부모 디렉터리)를 뜻해서, `../..` 는 두 번 올라갑니다. 같은 `../../notes.txt` 도 어디서 실행하느냐에 따라 다른 파일을 가리키므로, 헷갈릴 때는 `pwd` 로 지금 위치부터 확인합니다. 절대 경로(`/` 로 시작)는 어디서 실행해도 같은 파일입니다.

- A 지금 위치의 파일은 `./notes.txt` 또는 `notes.txt` 로 가리킵니다. `..` 가 붙으면 위로 올라갑니다.
- B `..` 한 번(`../notes.txt`)이 가리키는 파일입니다. `../..` 는 한 번 더 올라갑니다.
- D `../../..` 로 세 번 올라가야 닿습니다.

확인: `cd /tmp/h/user/project/src; cat ../../notes.txt`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 1 AND order_index = 12);

