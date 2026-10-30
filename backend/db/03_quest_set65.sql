-- 세트 65: 권한과 소유자: chmod, chown, umask
-- 기본기 사다리(docs/specs/spec_foundations_ladder.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs) VALUES
  (65, 1, 'ls -l 의 권한 문자열 읽기', '`-rwxr-xr--` 는 파일 권한입니다. **소유자 / 그룹 / 그 외 사용자**가 각각 할 수 있는 일로 알맞은 것은 무엇일까요?', '맨 앞 `-` 는 파일 종류이고, 이어서 세 글자씩 소유자, 그룹, 그 외입니다.', NULL, NULL, '[]', 'choice', '["소유자는 읽기·쓰기·실행, 그룹은 읽기·실행, 그 외는 읽기만 가능하다", "소유자는 읽기만, 그룹은 읽기·쓰기, 그 외는 모두 가능하다", "모든 사용자가 읽기·쓰기·실행 모두 가능하다", "소유자만 읽을 수 있고 나머지는 접근할 수 없다"]', 0, '`-rwxr-xr--` 는 파일 종류(`-`), 소유자(`rwx`), 그룹(`r-x`), 그 외(`r--`) 순서입니다. `r` 읽기, `w` 쓰기, `x` 실행이고 `-` 는 그 권한이 없다는 뜻입니다. 디렉터리는 맨 앞이 `d` 이고, `x` 는 "그 안으로 들어갈 수 있음" 의 뜻이 됩니다.', NULL, NULL, NULL, NULL),
  (65, 2, '숫자 권한 읽기', '`chmod 644 file` 의 `644` 는 무슨 뜻일까요? (읽기 `r`=4, 쓰기 `w`=2, 실행 `x`=1 로 더합니다)', '자리마다 소유자, 그룹, 그 외 순서입니다. 6 = 4 + 2 입니다.', NULL, NULL, '[]', 'choice', '["소유자는 읽기+쓰기+실행, 나머지는 읽기만", "소유자는 읽기+쓰기(`rw-`), 그룹과 그 외는 읽기만(`r--`)", "모든 사용자가 읽기·쓰기만 가능하다", "소유자는 읽기만, 나머지는 쓰기만 가능하다"]', 1, '`644` = 소유자 `6`(4+2 = 읽기+쓰기), 그룹 `4`(읽기), 그 외 `4`(읽기) 입니다. 자주 쓰는 값은 파일 `644`(일반), 실행 파일·디렉터리 `755`, 비밀 파일 `600`, 비밀 디렉터리 `700` 입니다.', NULL, NULL, NULL, NULL),
  (65, 3, 'chmod 777 이 위험한 이유 알기', '"권한 오류가 나서 `chmod -R 777 /app` 으로 풀었다" 는 방법의 문제는 무엇일까요?', '777 은 누구에게 무엇을 허용하는 값일까요?', NULL, NULL, '[]', 'choice', '["특별히 문제가 없고 가장 좋은 방법이다", "파일이 삭제된다", "**모든 사용자**가 읽기·쓰기·실행을 할 수 있게 되어 보안이 무너진다. 원인(소유자·그룹)을 확인해 필요한 최소 권한만 주는 것이 맞다", "777 은 읽기 전용이다"]', 2, '777 은 소유자·그룹·그 외 모두에게 `rwx` 를 줍니다. 권한 오류의 원인은 보통 소유자나 그룹이 맞지 않는 것이므로 `chown`/`chgrp` 로 바로잡거나 필요한 최소 권한(예: 755, 640)만 주는 것이 안전합니다. 복사해 온 명령에 `777` 이 보이면 한 번 더 의심하세요.', NULL, NULL, NULL, NULL),
  (65, 4, '실행 권한 주기 (chmod +x)', '`/tmp/run.sh` 는 스크립트인데 실행 권한이 없어서 `./run.sh` 를 하면 `Permission denied` 가 납니다. **실행할 수 있게** 권한을 주세요. (소유자가 실행 가능해야 합니다)', '찾는 방법: `chmod --help`. 권한을 문자로 더하는 방법(`+x`)이 있습니다. 먼저 `ls -l /tmp/run.sh` 로 현재 권한을 보세요.
확인: `/tmp/run.sh` 를 실행해 `ok` 가 출력되는지', 'chmod +x /tmp/run.sh
/tmp/run.sh

# +x : 실행 권한을 더한다 (a+x 와 같음)', '["sh", "-c", "printf ''#!/bin/sh\\\\necho ok\\\\n'' > /tmp/run.sh && chmod 644 /tmp/run.sh"]', '["sh", "-c", "( [ -x /tmp/run.sh ] ) && ( [ \\"$(/tmp/run.sh)\\" = ok ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "실행 권한이 있다", "cmd": ["sh", "-c", "[ -x /tmp/run.sh ]"]}, {"label": "실행하면 ok 가 출력된다", "cmd": ["sh", "-c", "[ \\"$(/tmp/run.sh)\\" = ok ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 5, '비밀 파일은 소유자만 (chmod 600)', '`/tmp/secret.txt` 에 비밀번호가 들어 있습니다. **소유자만 읽고 쓸 수 있고** 그룹과 다른 사용자는 아무것도 못 하게 숫자 권한으로 바꾸세요.', '소유자 `rw-` = 6, 그룹 `---` = 0, 그 외 `---` = 0 입니다.
확인: `ls -l /tmp/secret.txt` (`-rw-------`)', 'chmod 600 /tmp/secret.txt
ls -l /tmp/secret.txt

# 600 = 소유자 rw-, 그룹 ---, 그 외 ---', '["sh", "-c", "echo pw > /tmp/secret.txt && chmod 644 /tmp/secret.txt"]', '["sh", "-c", "( [ \\"$(stat -c %a /tmp/secret.txt)\\" = 600 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "권한이 600 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/secret.txt)\\" = 600 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 6, '숫자로 한 번에 권한 정하기', '`/tmp/deploy.sh` 의 권한을 **소유자는 읽기·쓰기·실행, 그룹은 읽기·실행, 그 외는 아무것도 못 하게** 숫자로 설정하세요.', '소유자 `rwx` = 7, 그룹 `r-x` = 5, 그 외 `---` = 0 입니다.
확인: `stat -c %a /tmp/deploy.sh`', 'chmod 750 /tmp/deploy.sh

# 7(rwx) 5(r-x) 0(---)', '["sh", "-c", "echo ''#!/bin/sh'' > /tmp/deploy.sh && chmod 644 /tmp/deploy.sh"]', '["sh", "-c", "( [ \\"$(stat -c %a /tmp/deploy.sh)\\" = 750 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "권한이 750 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/deploy.sh)\\" = 750 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 7, '다른 사용자의 쓰기 권한만 빼기 (기호 모드)', '`/tmp/shared.txt` 의 권한이 `666`(모두 읽기·쓰기)입니다. 다른 설정은 그대로 두고 **"그 외(other)" 사용자의 쓰기 권한만 제거**하세요.', '기호 모드는 `대상 연산자 권한` 입니다. 대상 `u`(소유자) `g`(그룹) `o`(그 외) `a`(전체), 연산자 `+`(더함) `-`(뺌) `=`(지정).
확인: `stat -c %a /tmp/shared.txt` (664 가 되어야 합니다)', 'chmod o-w /tmp/shared.txt

# o : 그 외 사용자, -w : 쓰기 제거', '["sh", "-c", "echo hi > /tmp/shared.txt && chmod 666 /tmp/shared.txt"]', '["sh", "-c", "( [ \\"$(stat -c %a /tmp/shared.txt)\\" = 664 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "권한이 664 이다 (그 외의 쓰기만 빠졌다)", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/shared.txt)\\" = 664 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 8, '파일 소유자 바꾸기 (chown)', '`/tmp/app.conf` 의 소유자가 `root` 입니다. 이 파일의 **소유자를 `deploy` 사용자로** 바꾸세요. (`deploy` 사용자는 이미 만들어져 있습니다)', '찾는 방법: `chown --help`. 형태는 `chown 새소유자 파일` 입니다. 소유자 변경은 보통 관리자 권한이 필요합니다.
확인: `ls -l /tmp/app.conf`', 'chown deploy /tmp/app.conf
ls -l /tmp/app.conf

# chown 사용자 파일 : 소유자 변경', '["sh", "-c", "useradd -m deploy 2>/dev/null; groupadd ops 2>/dev/null; true && echo conf > /tmp/app.conf"]', '["sh", "-c", "( [ \\"$(stat -c %U /tmp/app.conf)\\" = deploy ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "소유자가 deploy 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %U /tmp/app.conf)\\" = deploy ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 9, '소유자와 그룹을 한 번에 바꾸기', '`/tmp/data.db` 의 소유자를 **`deploy`**, 그룹을 **`ops`** 로 한 번에 바꾸세요. (둘 다 이미 있습니다)', '`chown` 은 `소유자:그룹` 형태로 둘을 함께 줄 수 있습니다.
확인: `ls -l /tmp/data.db`', 'chown deploy:ops /tmp/data.db

# 소유자:그룹 형태로 한 번에
# 그룹만 바꿀 때는 chgrp ops 파일 또는 chown :ops 파일', '["sh", "-c", "useradd -m deploy 2>/dev/null; groupadd ops 2>/dev/null; true && echo data > /tmp/data.db"]', '["sh", "-c", "( [ \\"$(stat -c %U /tmp/data.db)\\" = deploy ] ) && ( [ \\"$(stat -c %G /tmp/data.db)\\" = ops ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "소유자가 deploy 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %U /tmp/data.db)\\" = deploy ]"]}, {"label": "그룹이 ops 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %G /tmp/data.db)\\" = ops ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 10, '새 파일의 기본 권한 정하기 (umask)', '앞으로 만드는 파일이 **소유자만 읽고 쓸 수 있는 권한(600)** 으로 만들어지게 `umask` 를 설정한 뒤, 그 상태에서 `/tmp/private.txt` 를 새로 만드세요. (내용은 비어 있어도 됩니다)', '`umask` 는 "기본 권한에서 **빼는** 값"입니다. 파일의 기본은 666 이므로 600 이 되려면 666 에서 무엇을 빼야 할까요? 설정한 뒤 같은 쉘에서 파일을 만들어야 적용됩니다.
확인: `ls -l /tmp/private.txt`', 'umask 077
touch /tmp/private.txt
ls -l /tmp/private.txt

# 파일 기본 666 - 077 = 600
# 디렉터리 기본 777 - 077 = 700', '["sh", "-c", "true"]', '["sh", "-c", "( [ \\"$(stat -c %a /tmp/private.txt)\\" = 600 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "새 파일의 권한이 600 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/private.txt)\\" = 600 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]'),
  (65, 11, '합쳐서 쓰기: 배포 폴더 권한 정리하기', '`/tmp/release` 폴더 안의 `start.sh` 를 **배포 담당(`deploy`:`ops`)** 이 쓰도록 정리하세요. ① 폴더 안 **모든 파일의 소유자를 `deploy`, 그룹을 `ops`** 로 바꾸고, ② `start.sh` 는 **소유자 읽기·쓰기·실행, 그룹 읽기·실행, 그 외 없음(750)** 으로 하세요.', '폴더 아래 전체에 적용하는 옵션이 있습니다(`chown -R`, `chmod -R`). 하지만 이번에는 `start.sh` 만 750 으로 하면 됩니다. 순서: ① `chown -R deploy:ops /tmp/release` ② `chmod 750 /tmp/release/start.sh`.', 'chown -R deploy:ops /tmp/release
chmod 750 /tmp/release/start.sh
ls -l /tmp/release

# -R : 하위 항목까지 재귀적으로', '["sh", "-c", "useradd -m deploy 2>/dev/null; groupadd ops 2>/dev/null; true && mkdir -p /tmp/release && echo ''#!/bin/sh'' > /tmp/release/start.sh && echo cfg > /tmp/release/app.cfg && chmod 666 /tmp/release/start.sh"]', '["sh", "-c", "( [ \\"$(stat -c %U:%G /tmp/release/start.sh)\\" = deploy:ops ] ) && ( [ \\"$(stat -c %U:%G /tmp/release/app.cfg)\\" = deploy:ops ] ) && ( [ \\"$(stat -c %a /tmp/release/start.sh)\\" = 750 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "start.sh 의 소유자가 deploy, 그룹이 ops 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %U:%G /tmp/release/start.sh)\\" = deploy:ops ]"]}, {"label": "app.cfg 도 deploy:ops 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %U:%G /tmp/release/app.cfg)\\" = deploy:ops ]"]}, {"label": "start.sh 권한이 750 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/release/start.sh)\\" = 750 ]"]}]', '[{"title": "GNU coreutils 매뉴얼", "url": "https://www.gnu.org/software/coreutils/manual/coreutils.html"}]');
