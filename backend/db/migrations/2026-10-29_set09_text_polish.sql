-- 세트 9 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='Vim 으로 파일 열고 저장하기', description='Vim 은 서버에서 설정 파일을 고칠 때 가장 흔히 만나는 편집기인데, 처음에는 **입력 모드와 명령 모드**를 구분해야 해서 막힙니다.

`/tmp/hello.txt` 를 vim 으로 열어 첫 줄에 `hello vim` 을 입력하고 저장한 뒤 종료하세요.', hint='순서: 1) `vim /tmp/hello.txt` 로 열기 2) `i` 를 눌러 **입력 모드** 진입(insert) 3) `hello vim` 입력 4) `ESC` 로 **명령 모드** 복귀 5) `:wq` 입력 후 엔터 (`w` 저장 + `q` 종료)', solution='vim /tmp/hello.txt
  i            # 입력 모드 시작
  hello vim    # 내용 입력
  ESC          # 명령 모드로 돌아감
  :wq          # 저장하고 종료 (write + quit)' WHERE quest_set_id = 9 AND order_index = 1;
UPDATE quest SET title='저장하지 않고 Vim 종료하기', description='잘못 편집했을 때 변경을 버리고 나가는 방법을 모르면 vim 에서 갇힙니다.

`/tmp/test.txt` 를 vim 으로 열어 아무 내용이나 입력한 뒤, **저장하지 않고** 종료하세요. 그 다음 파일이 비어 있는지 확인하세요.', hint='`i` 로 입력 모드에서 아무 내용이나 쓰고, `ESC` 로 명령 모드로 돌아온 뒤 `:q!` 를 입력합니다. `q` 는 종료, `!` 는 ''변경을 무시하고 강제로''라는 뜻입니다.', solution='vim /tmp/test.txt
  i            # 입력 모드
  (아무 내용)
  ESC
  :q!          # 저장 없이 강제 종료' WHERE quest_set_id = 9 AND order_index = 2;
UPDATE quest SET title='특정 줄 번호로 이동해 내용 확인하기', description='긴 설정 파일이나 로그에서 에러가 알려 준 **줄 번호**로 바로 가는 일이 자주 있습니다.

`/tmp/lines.txt` 의 5번째 줄 내용을 `/tmp/result.txt` 에 저장하세요. (vim 에서 `:5` 로 줄을 확인해 보세요)', hint='vim 에서는 `:5` + 엔터로 5번째 줄에 이동합니다. 줄 내용을 파일로 저장하는 것은 `sed -n ''5p'' <파일>` 로 할 수 있습니다. `-n` 은 자동 출력을 끄고, `5p` 는 5번째 줄만 출력(print)하라는 뜻입니다.', solution='sed -n ''5p'' /tmp/lines.txt > /tmp/result.txt

# -n : 기본 출력 끔, ''5p'' : 5번째 줄만 출력' WHERE quest_set_id = 9 AND order_index = 3;
UPDATE quest SET title='단어 검색하기', description='설정 파일에서 특정 설정을 찾을 때 검색을 씁니다.

`/tmp/config.txt` 에서 `port` 라는 단어가 있는 줄의 **줄 번호**를 `/tmp/result.txt` 에 저장하세요. (vim 에서 `/port` 로 검색해 보세요)', hint='vim 에서는 `/port` + 엔터로 검색하고 `n` 으로 다음 결과로 이동합니다. 줄 번호를 파일로 저장하려면 `grep -n "port" <파일>` 을 씁니다. `-n` 은 줄 번호를 앞에 붙이는 옵션입니다.', solution='grep -n "port" /tmp/config.txt > /tmp/result.txt

# -n : 일치한 줄의 번호를 함께 출력' WHERE quest_set_id = 9 AND order_index = 4;
UPDATE quest SET title='줄 삭제하기 (dd)', description='vim 은 마우스 없이 키 조합으로 편집합니다. `dd` 는 한 줄을 통째로 지우는 가장 자주 쓰는 명령입니다.

`/tmp/remove.txt` 의 2번째 줄을 vim 에서 `dd` 로 삭제하고 저장하세요.', hint='순서: `vim /tmp/remove.txt` → `:2` 엔터(2번째 줄로 이동) → `dd`(그 줄 삭제) → `:wq`(저장하고 종료). `dd` 는 명령 모드에서 입력합니다.', solution='vim /tmp/remove.txt
  :2           # 2번째 줄로 이동
  dd           # 현재 줄 삭제 (delete line)
  :wq          # 저장하고 종료' WHERE quest_set_id = 9 AND order_index = 5;
UPDATE quest SET title='줄 복사해서 붙여넣기 (yy, p)', description='같은 내용을 반복해서 넣을 때는 줄을 복사해 붙여넣습니다. vim 에서 복사는 ''당긴다(yank)''고 표현합니다.

`/tmp/copy.txt` 의 **1번째 줄을 복사해서 파일 끝에 붙여넣고** 저장하세요. 파일은 총 3줄이 되어야 합니다.', hint='순서: `gg`(맨 첫 줄로) → `yy`(현재 줄 복사) → `G`(맨 끝 줄로) → `p`(아래에 붙여넣기) → `:wq`. 모두 명령 모드에서 입력합니다.', solution='vim /tmp/copy.txt
  gg           # 파일 맨 처음으로
  yy           # 현재 줄 복사 (yank)
  G            # 파일 맨 끝으로
  p            # 아래에 붙여넣기 (paste)
  :wq' WHERE quest_set_id = 9 AND order_index = 6;
UPDATE quest SET title='단어를 전체 치환하기 (:%s)', description='설정 파일의 주소나 값을 한꺼번에 바꿔야 할 때 씁니다.

`/tmp/app.conf` 에서 `localhost` 를 모두 `192.168.1.10` 으로 치환하고 저장하세요.', hint='vim 명령 모드에서 `:%s/localhost/192.168.1.10/g` 를 입력합니다.
- `%` : 파일 전체 줄
- `s/찾을것/바꿀것/` : 치환(substitute)
- `g` : 한 줄에 여러 개 있어도 모두(global)', solution='vim /tmp/app.conf
  :%s/localhost/192.168.1.10/g    # 전체에서 localhost 를 모두 치환
  :wq' WHERE quest_set_id = 9 AND order_index = 7;
UPDATE quest SET title='비주얼 모드로 여러 줄 삭제하기', description='여러 줄을 한꺼번에 지울 때는 **비주얼 모드**로 범위를 선택합니다.

`/tmp/multi.txt` 에서 2~4번째 줄을 vim 비주얼 모드로 선택해 삭제하고 저장하세요.', hint='순서: `:2`(2번째 줄로) → `V`(대문자 V, 줄 단위 선택 시작) → `jj`(아래로 두 줄 더 선택, `j` 는 아래 이동) → `d`(선택 영역 삭제) → `:wq`', solution='vim /tmp/multi.txt
  :2           # 2번째 줄로 이동
  V            # 비주얼 라인 모드 (줄 단위 선택)
  jj           # 아래로 선택 확장 (2~4번째 줄)
  d            # 선택한 줄 삭제
  :wq' WHERE quest_set_id = 9 AND order_index = 8;
UPDATE quest SET title='단어 교체하기 (cw)', description='`cw` 는 커서가 있는 단어를 지우고 바로 입력 모드로 들어가 다른 단어로 교체합니다.

`/tmp/fix.txt` 의 첫 줄에서 `error` 단어를 vim 의 `cw` 로 `info` 로 바꾸고 저장하세요.', hint='순서: `/error` 엔터(검색해서 단어로 이동) → `cw`(change word: 단어를 지우고 입력 모드 진입) → `info` 입력 → `ESC` → `:wq`', solution='vim /tmp/fix.txt
  /error       # error 로 이동
  cw           # 단어 삭제 후 입력 모드 (change word)
  info         # 새 단어 입력
  ESC
  :wq' WHERE quest_set_id = 9 AND order_index = 9;
UPDATE quest SET title='줄 끝에 내용 추가하기 (A)', description='설정 줄 뒤에 주석을 붙이는 것처럼 **줄 끝에 이어서** 입력할 때 `A` 가 편합니다.

`/tmp/append.txt` 의 첫 줄 끝에 ` # managed by etude` 를 추가하고 저장하세요.', hint='순서: `gg`(첫 줄로) → `A`(대문자 A: 줄 **끝**에서 입력 모드 시작, append) → ` # managed by etude` 입력(앞에 공백 포함) → `ESC` → `:wq`. 소문자 `a` 는 커서 바로 뒤라 결과가 다릅니다.', solution='vim /tmp/append.txt
  gg           # 첫 줄로
  A            # 줄 끝에서 입력 모드 시작
   # managed by etude
  ESC
  :wq' WHERE quest_set_id = 9 AND order_index = 10;
UPDATE quest SET title='실행 취소와 다시 실행 (u, Ctrl+r)', description='실수했을 때 되돌리는 `u` 와, 되돌린 것을 다시 되살리는 `Ctrl+r` 은 vim 의 안전망입니다.

`/tmp/undo.txt` 를 vim 으로 열어 맨 아래에 `redo_done` 한 줄을 추가하세요. `u` 로 취소해 본 뒤 `Ctrl+r` 로 다시 실행해서 **그 줄이 돌아온 상태**로 저장하세요. 파일에 `original content` 와 `redo_done` 이 모두 있어야 합니다.', hint='순서: `o`(현재 줄 아래에 새 줄 열고 입력 모드, open) → `redo_done` 입력 → `ESC` → `u`(undo, 취소: 줄이 사라짐) → `Ctrl+r`(redo, 다시 실행: 줄이 돌아옴) → `:wq`', solution='vim /tmp/undo.txt
  o            # 아래에 새 줄 열기
  redo_done
  ESC
  u            # 취소 (undo)
  Ctrl+r       # 다시 실행 (redo)
  :wq' WHERE quest_set_id = 9 AND order_index = 11;
UPDATE quest SET title='읽기 전용 파일 수정해서 저장하기', description='권한 때문에 저장이 안 될 때, 편집한 내용을 날리지 않고 관리자 권한으로 저장하는 방법이 있습니다.

`/tmp/readonly.txt` 는 root 소유의 읽기 전용 파일입니다. vim 으로 열어 `modified` 한 줄을 추가하고 `:w !sudo tee %` 로 저장하세요.', hint='일반 `:w` 는 권한 오류가 납니다. `:w !sudo tee %` 는 현재 편집 내용(`w`)을 `sudo tee` 명령에 넘겨(`!`) 현재 파일(`%`)에 쓰는 방법입니다. 저장 후 "Press ENTER" 가 나오면 엔터를 누르고 `:q!` 로 종료하세요.', solution='vim /tmp/readonly.txt
  G            # 맨 끝으로
  o            # 새 줄
  modified
  ESC
  :w !sudo tee %   # 관리자 권한(sudo)으로 현재 파일(%)에 저장
# % : 현재 편집 중인 파일 이름' WHERE quest_set_id = 9 AND order_index = 12;
