-- 세트 544. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set544.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 544, '계정 정책: shadow 필드·잠금·만료·nologin·로그인 기록', '/etc/shadow 의 필드를 읽고, passwd -l/-u 와 usermod -L/-U 로 계정을 잠그고 풉니다. chage 로 비밀번호 사용 기간과 계정 만료일을 읽고 바꾸며, 로그인이 필요 없는 계정은 nologin 셸로 막고, lastlog 로 로그인 기록을 확인합니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 544);
UPDATE quest_set SET display_order = 803, unit_id = (SELECT id FROM unit WHERE id = 58), icon = '🔐' WHERE id = 544;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 1, '/etc/shadow 의 비밀번호 칸 읽기', '`/etc/passwd` 는 누구나 읽을 수 있어서, 비밀번호 해시는 root 만 읽을 수 있는 `/etc/shadow` 에 따로 둡니다. shadow 한 줄은 `계정명:해시:마지막변경일:최소일:최대일:경고일:유예일:만료일:` 처럼 `:` 로 나뉩니다. 두 번째 칸(해시)에 대한 설명으로 알맞은 것은 무엇일까요?', '해시 앞에 붙은 기호의 모양과, 해시 자리에 기호만 있는 경우를 나눠서 생각해 보세요.', NULL, NULL, '[]', 'choice', '["해시 앞에 `!` 가 붙어 있으면 비밀번호가 곧 만료된다는 뜻이고, `*` 이면 비밀번호가 영원히 바뀌지 않는다는 뜻이다", "해시 앞에 `!` 가 붙어 있으면 그 계정의 비밀번호 로그인이 잠긴 것이고, 해시 자리에 `*` 만 있으면 비밀번호로 로그인할 수 없게 만든 계정(주로 시스템 계정)이다", "해시 칸이 비어 있어야 안전한 계정이고, `!` 나 `*` 가 보이면 해킹당한 계정이다", "`!` 와 `*` 는 계정이 삭제 예정이라는 표시이고, 다음 로그인 때 자동으로 지워진다"]', 1, '해시 앞의 `!` 는 "잠금 표시"입니다(`passwd -l`·`usermod -L` 이 붙이고 `-u`·`-U` 가 뗍니다). 해시 자체는 그대로 남아 있어서 잠금을 풀면 같은 비밀번호로 다시 로그인됩니다. `*` 는 해시 자리에 유효한 값이 없다는 뜻이라 어떤 비밀번호로도 로그인할 수 없고, `daemon`·`www-data` 같은 시스템 계정에 흔합니다. 해시 칸이 비어 있으면 오히려 비밀번호 없이 로그인되는 위험한 상태입니다. 둘 다 삭제 예정이나 해킹 표시가 아닙니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 2, 'shadow 에서 비밀번호 최대 사용일 뽑기', '계정 `alice` 의 비밀번호는 일정 기간이 지나면 바꿔야 하도록 설정돼 있습니다. shadow 의 칸은 앞에서부터 ① 계정명 ② 해시 ③ 마지막으로 바꾼 날 ④ 최소 사용일 ⑤ **최대 사용일** ⑥ 경고일 ⑦ 유예일 ⑧ 만료일 입니다.

`/etc/shadow` 에서 `alice` 줄의 **⑤ 최대 사용일 값만** 뽑아 **`/tmp/q2.txt`** 에 저장하세요. (숫자 하나만 들어가야 합니다.)', '`grep` 으로 alice 줄만 고른 뒤, `cut` 이나 `awk` 에 구분자를 `:` 로 알려 주고 다섯 번째 칸을 꺼냅니다. `getent shadow 계정명` 도 같은 줄을 보여 줍니다.', 'grep ''^alice:'' /etc/shadow | cut -d: -f5 > /tmp/q2.txt
cat /tmp/q2.txt

# 같은 방법: getent shadow alice | awk -F: ''{print $5}''. 값은 60', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash alice\\necho ''alice:Passw0rd-x1'' | chpasswd\\nchage -M 60 -W 10 alice\\n"]', '["sh", "-c", "( [ -s /tmp/q2.txt ] ) && ( [ \\"$(cat /tmp/q2.txt)\\" = 60 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/q2.txt ]"]}, {"label": "값이 60 한 줄이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q2.txt)\\" = 60 ]"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 3, '퇴사자 계정의 비밀번호 로그인 잠그기', '퇴사한 팀원의 계정 `bob` 이 아직 살아 있습니다. 계정을 지우기 전에, 일단 **비밀번호로는 로그인할 수 없게 잠그세요.** 계정과 홈 디렉터리, 비밀번호 해시는 그대로 두어야 합니다. (잠그면 shadow 의 해시 앞에 `!` 가 붙습니다.)

`passwd` 명령으로 하는 방법과 `usermod` 로 하는 방법이 모두 있습니다. 어느 쪽이든 괜찮습니다.', '`passwd --help` 의 옵션 설명에서 잠그기(lock)를 찾아 보세요. 잠근 뒤 `passwd -S bob` 으로 상태를 확인하세요.', 'passwd -l bob
passwd -S bob
grep ''^bob:'' /etc/shadow | cut -d: -f2 | cut -c1-2

# 또는 usermod -L bob. 해시 앞에 !가 붙는다. 상태 칸이 L(Locked)이 된다', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash bob\\necho ''bob:Passw0rd-x1'' | chpasswd\\n"]', '["sh", "-c", "( [ \\"$(passwd -S bob | awk ''{print $2}'')\\" = L ] ) && ( getent shadow bob | cut -d: -f2 | grep -q ''^!\\\\$'' ) && ( id bob >/dev/null && [ -d /home/bob ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "상태가 잠금(L)이다", "cmd": ["sh", "-c", "[ \\"$(passwd -S bob | awk ''{print $2}'')\\" = L ]"]}, {"label": "해시는 남아 있다 (! 뒤에 $)", "cmd": ["sh", "-c", "getent shadow bob | cut -d: -f2 | grep -q ''^!\\\\$''"]}, {"label": "계정과 홈이 남아 있다", "cmd": ["sh", "-c", "id bob >/dev/null && [ -d /home/bob ]"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 4, '잠그기와 풀기 옵션 짝맞추기', '`dave` 계정에 대해 두 가지를 하려고 합니다. 빈칸에 알맞은 옵션을 채우세요.
- `passwd` 로 비밀번호를 **잠근다**
- `usermod` 로 잠긴 계정을 **푼다**', '`passwd` 와 `usermod` 는 같은 동작에 쓰는 옵션 글자의 대소문자가 서로 다릅니다. 각 명령의 `--help` 에서 lock·unlock 설명을 찾아보세요.', NULL, NULL, '[]', 'fill', '["l", "u", "U", "S", "e"]', NULL, '`passwd -l` 은 잠금, `passwd -u` 는 해제이고, `usermod` 에서는 대문자로 `-L`(잠금)·`-U`(해제)입니다. `passwd -S` 는 상태를 보기만 하고 바꾸지 않습니다. `usermod -u` 는 UID 를 바꾸는 옵션이라 값이 필요하고, `usermod -e` 는 만료일을 정하는 옵션이라 잠금 해제와 다릅니다.', '[0, 2]', 'passwd -{0} dave
usermod -{1} dave', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 5, '잠긴 계정 풀기', '휴직했던 팀원의 계정 `carol` 이 잠겨 있습니다. 복직했으니 **같은 비밀번호로 다시 로그인할 수 있게 잠금을 푸세요.** 비밀번호를 새로 만들 필요는 없습니다. 먼저 지금 상태를 `passwd -S carol` 로 보고(`L` 이면 잠김, `P` 이면 정상), 푼 뒤에 다시 확인하세요.', '잠글 때 쓴 옵션의 짝입니다. `passwd` 든 `usermod` 든 소문자·대문자 짝을 떠올려 보세요.', 'passwd -S carol
passwd -u carol
passwd -S carol

# 또는 usermod -U carol. 해시 앞의 !가 사라져 상태가 P가 된다', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash carol\\necho ''carol:Passw0rd-x1'' | chpasswd\\npasswd -l carol >/dev/null\\n"]', '["sh", "-c", "( [ \\"$(passwd -S carol | awk ''{print $2}'')\\" = P ] ) && ( getent shadow carol | cut -d: -f2 | grep -q ''^\\\\$'' )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "상태가 정상(P)이다", "cmd": ["sh", "-c", "[ \\"$(passwd -S carol | awk ''{print $2}'')\\" = P ]"]}, {"label": "해시가 살아 있다 (! 없이 $ 로 시작)", "cmd": ["sh", "-c", "getent shadow carol | cut -d: -f2 | grep -q ''^\\\\$''"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 6, '잠근 계정으로 SSH 키 로그인이 될까', '서버에서 `passwd -l grace` 로 계정을 잠갔습니다. 그런데 grace 의 공개키가 등록돼 있으면 **SSH 키 인증으로는 여전히 로그인된다**는 보고가 들어왔습니다. 이유와 해결로 알맞은 것은 무엇일까요?', '`!` 는 shadow 의 비밀번호 칸을 바꿨을 뿐입니다. 이 칸이 어떤 인증에만 쓰이는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["`passwd -l` 은 비밀번호 인증만 막는 잠금이라 키 인증은 영향이 없다. 완전히 막으려면 계정 만료(`usermod -e 1` 등)나 nologin 셸을 함께 쓴다", "`passwd -l` 은 반드시 재부팅해야 적용되므로 재부팅하면 키 로그인도 막힌다", "`passwd -l` 은 실제로 SSH 키 로그인도 막으니 보고가 잘못된 것이다", "키 로그인이 되는 것은 `/etc/passwd` 의 UID 가 0 이라서 생기는 일이다"]', 0, '`passwd -l`(= `usermod -L`)은 shadow 의 해시 앞에 `!` 를 붙여 **비밀번호로 확인하는 인증**만 불가능하게 만듭니다. 공개키 인증은 비밀번호 칸을 보지 않으므로 통과할 수 있습니다. 퇴사자 계정을 확실히 막으려면 계정 만료일을 과거로 두거나(`chage -E 0`, `usermod -e 1`) 셸을 nologin 으로 바꿉니다. 재부팅은 필요 없고, UID 와도 관계없습니다. 참고로 nologin 은 셸만 막으므로 키 인증의 포트 포워딩은 `AllowTcpForwarding no` 나 `authorized_keys` 의 `restrict` 로 따로 막습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 7, 'chage -l 로 비밀번호 정책 읽기', '`erin` 계정에 비밀번호 사용 기간 규칙이 걸려 있습니다. 이 규칙은 `chage` 명령으로 읽습니다. **`erin` 의 비밀번호·계정 만료 정보를 보여 주는 출력**을 **`/tmp/q7.txt`** 에 저장하세요. `Maximum number of days between password change` 줄에 최대 사용일이 보이면 맞습니다.

(`chage` 는 change age 의 줄임말이고, 이 문제는 읽기만 하는 작업입니다.)', '`chage` 에 "목록으로 보여 주기"를 뜻하는 옵션이 있습니다. `chage --help` 에서 확인하세요.', 'chage -l erin > /tmp/q7.txt
cat /tmp/q7.txt

# 마지막 변경일, 만료일, 최소/최대 일수, 경고일이 보인다. 최대 일수는 30', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash erin\\necho ''erin:Passw0rd-x1'' | chpasswd\\nchage -M 30 -m 3 erin\\n"]', '["sh", "-c", "( [ -s /tmp/q7.txt ] ) && ( grep -E \\"^Maximum number of days between password change[[:space:]]*:[[:space:]]*30$\\" /tmp/q7.txt ) && ( grep -E \\"^Minimum number of days between password change[[:space:]]*:[[:space:]]*3$\\" /tmp/q7.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/q7.txt ]"]}, {"label": "최대 사용일 줄(30)이 있다", "cmd": ["sh", "-c", "grep -E \\"^Maximum number of days between password change[[:space:]]*:[[:space:]]*30$\\" /tmp/q7.txt"]}, {"label": "최소 사용일 줄(3)이 있다", "cmd": ["sh", "-c", "grep -E \\"^Minimum number of days between password change[[:space:]]*:[[:space:]]*3$\\" /tmp/q7.txt"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 8, '비밀번호 최대 사용일과 경고일 바꾸기', '`frank` 계정의 비밀번호 정책은 아직 기본값(사실상 무기한)입니다. 보안 정책에 따라 다음과 같이 바꾸세요.
- **최대 사용일을 90일로** (`chage -M 일수`). 90일이 지나면 비밀번호를 바꿔야 합니다.
- 만료 **14일 전부터 경고**를 보여 줍니다.

경고 일수를 정하는 옵션은 `man chage` 에서 찾아 보세요. 다른 값(최소 사용일 등)은 건드리지 않습니다.', '`chage --help` 의 옵션 목록에서 설명에 `warn` 이 들어간 줄을 찾으세요. 바꾼 뒤 `chage -l frank` 로 결과를 확인합니다.', 'chage -M 90 -W 14 frank
chage -l frank

# shadow 의 5번째 칸이 90, 6번째 칸이 14가 된다', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash frank\\necho ''frank:Passw0rd-x1'' | chpasswd\\n"]', '["sh", "-c", "( [ \\"$(getent shadow frank | cut -d: -f5)\\" = 90 ] ) && ( [ \\"$(getent shadow frank | cut -d: -f6)\\" = 14 ] ) && ( [ \\"$(getent shadow frank | cut -d: -f4)\\" = 0 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "최대 사용일이 90이다", "cmd": ["sh", "-c", "[ \\"$(getent shadow frank | cut -d: -f5)\\" = 90 ]"]}, {"label": "경고일이 14이다", "cmd": ["sh", "-c", "[ \\"$(getent shadow frank | cut -d: -f6)\\" = 14 ]"]}, {"label": "최소 사용일은 그대로다 (0)", "cmd": ["sh", "-c", "[ \\"$(getent shadow frank | cut -d: -f4)\\" = 0 ]"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 9, '계정 만료일 정하기', '외부 협력사 직원이 쓰는 계정 `grace` 는 **2030년 1월 1일까지만** 쓰게 하려고 합니다. 그 날짜가 지나면 비밀번호가 맞아도 로그인이 거부됩니다. (비밀번호 만료와는 별개인 **계정 만료일**입니다.)

`chage` 로 `grace` 의 계정 만료일을 `2030-01-01` 로 정하세요. 날짜는 `YYYY-MM-DD` 형식으로 넣을 수 있습니다. 설정한 뒤 `chage -l grace` 의 `Account expires` 줄을 확인하세요.', '`chage --help` 에서 `expire` 가 들어간 옵션을 찾습니다. 옵션은 대문자입니다. 소문자 `-M` 은 비밀번호 쪽 설정입니다.', 'chage -E 2030-01-01 grace
chage -l grace | grep ''Account expires''

# shadow 의 8번째 칸에 1970-01-01 부터 센 날수가 저장된다', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash grace\\necho ''grace:Passw0rd-x1'' | chpasswd\\n"]', '["sh", "-c", "( [ \\"$(getent shadow grace | cut -d: -f8)\\" = \\"$(( $(date -u -d 2030-01-01 +%s) / 86400 ))\\" ] ) && ( getent shadow grace | cut -d: -f2 | grep -q ''^\\\\$'' ) && ( [ \\"$(getent shadow grace | cut -d: -f5)\\" = 99999 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "만료일이 2030-01-01 이다", "cmd": ["sh", "-c", "[ \\"$(getent shadow grace | cut -d: -f8)\\" = \\"$(( $(date -u -d 2030-01-01 +%s) / 86400 ))\\" ]"]}, {"label": "해시는 안 바뀌었다 (잠금 아님)", "cmd": ["sh", "-c", "getent shadow grace | cut -d: -f2 | grep -q ''^\\\\$''"]}, {"label": "최대 사용일은 그대로다", "cmd": ["sh", "-c", "[ \\"$(getent shadow grace | cut -d: -f5)\\" = 99999 ]"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 10, '로그인이 필요 없는 계정을 nologin 으로', '서비스를 돌리려고 만든 계정 `svc01` 이 `/bin/bash` 셸을 가지고 있어서 누군가 로그인하면 셸이 열립니다. 이 계정은 서비스 실행용이라 **로그인할 수 없게** 해야 합니다. 계정 자체와 홈 디렉터리는 지우지 마세요.

로그인 셸을 **nologin** 으로 바꾸면, 로그인을 시도할 때 "This account is currently not available." 라는 안내만 나오고 끝납니다. 셸을 바꾼 뒤 `getent passwd svc01` 의 마지막 칸이 nologin 인지 확인하세요.', '계정을 만들 때 셸을 정한 옵션을 기억하나요? 이미 있는 계정을 고치는 명령에도 같은 이름의 옵션이 있습니다. nologin 의 위치는 `command -v nologin` 으로 찾을 수 있습니다.', 'usermod -s /usr/sbin/nologin svc01
getent passwd svc01
su - svc01 -c id

# 마지막 칸이 nologin 이 되고, su 를 하면 This account is currently not available. 가 나온다', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash svc01\\necho ''svc01:Passw0rd-x1'' | chpasswd\\n"]', '["sh", "-c", "( getent passwd svc01 | cut -d: -f7 | grep -q \\"/nologin$\\" ) && ( id svc01 >/dev/null && [ -d /home/svc01 ] ) && ( su - svc01 -c id 2>&1 | grep -q \\"not available\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "셸이 nologin 이다", "cmd": ["sh", "-c", "getent passwd svc01 | cut -d: -f7 | grep -q \\"/nologin$\\""]}, {"label": "계정과 홈이 남아 있다", "cmd": ["sh", "-c", "id svc01 >/dev/null && [ -d /home/svc01 ]"]}, {"label": "로그인 시도가 거부된다", "cmd": ["sh", "-c", "su - svc01 -c id 2>&1 | grep -q \\"not available\\""]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 11, '로그인한 적 없는 일반 계정 찾기', '`lastlog` 는 **계정마다 마지막 로그인 시각**을 보여 줍니다. 한 번도 로그인하지 않은 계정은 `**Never logged in**` 으로 나옵니다. 사람이 쓰는 일반 계정(UID 1000 이상)만 보려면 `lastlog -u 1000-60000` 처럼 범위를 줍니다.

지금 이 서버의 일반 계정 중 **한 번도 로그인하지 않은 계정의 이름만** 한 줄에 하나씩 **`/tmp/q11.txt`** 에 저장하세요. (`ops01`, `ops02` 가 들어가야 하고, `root` 같은 시스템 계정은 들어가면 안 됩니다.)', '`lastlog -u` 에 UID 범위를 주고, `grep` 이나 `awk` 로 `Never` 가 든 줄을 거른 뒤 첫 번째 열(계정명)만 뽑습니다.', 'lastlog -u 1000-60000 | awk ''/Never logged in/ {print $1}'' > /tmp/q11.txt
cat /tmp/q11.txt

# 일반 계정 범위만 보므로 root·daemon 은 빠진다. 출력 첫 열이 계정명이다', '["sh", "-c", "for u in alice bob carol dave erin frank grace svc01 ops01 ops02; do userdel -r $u >/dev/null 2>&1; done; rm -f /tmp/*.txt\\nuseradd -m -s /bin/bash ops01\\necho ''ops01:Passw0rd-x1'' | chpasswd\\nuseradd -m -s /bin/bash ops02\\necho ''ops02:Passw0rd-x1'' | chpasswd\\n"]', '["sh", "-c", "( [ -s /tmp/q11.txt ] ) && ( grep -qx ops01 /tmp/q11.txt && grep -qx ops02 /tmp/q11.txt ) && ( ! grep -qx root /tmp/q11.txt ) && ( ! grep -q \\"[[:space:]]\\" /tmp/q11.txt ) && ( while read n; do u=$(id -u \\"$n\\") || exit 1; [ \\"$u\\" -ge 1000 ] && [ \\"$u\\" -lt 65534 ] || exit 1; done < /tmp/q11.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/q11.txt ]"]}, {"label": "ops01·ops02 가 있다", "cmd": ["sh", "-c", "grep -qx ops01 /tmp/q11.txt && grep -qx ops02 /tmp/q11.txt"]}, {"label": "시스템 계정(root)은 없다", "cmd": ["sh", "-c", "! grep -qx root /tmp/q11.txt"]}, {"label": "줄마다 계정명만 있다", "cmd": ["sh", "-c", "! grep -q \\"[[:space:]]\\" /tmp/q11.txt"]}, {"label": "시스템 계정(daemon·bin·nobody 등)이 없다: 모두 UID 1000 이상", "cmd": ["sh", "-c", "while read n; do u=$(id -u \\"$n\\") || exit 1; [ \\"$u\\" -ge 1000 ] && [ \\"$u\\" -lt 65534 ] || exit 1; done < /tmp/q11.txt"]}]', '[{"title": "shadow(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/shadow.5.html"}, {"title": "chage(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/chage.1.html"}, {"title": "passwd(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/passwd.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 544, 12, 'last, lastlog, lastb 의 차이', '로그인 기록을 보는 명령이 비슷하게 생겼습니다. 설명으로 알맞은 것은 무엇일까요?', '세 명령은 읽는 파일이 서로 다릅니다. 각각 어떤 파일(wtmp·lastlog·btmp)에서 무엇을 읽는지 이름에서 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`last` 는 실패한 로그인만, `lastlog` 는 성공한 로그인만, `lastb` 는 재부팅 기록만 보여 준다", "세 명령은 이름만 다를 뿐 같은 파일을 읽어 같은 내용을 보여 준다", "`last` 는 로그인·재부팅 기록을 시간 순서로, `lastlog` 는 계정마다 마지막 로그인 한 줄씩, `lastb` 는 로그인 실패 기록을 보여 준다", "`last` 는 현재 로그인한 사용자 목록, `lastlog` 는 sudo 사용 기록, `lastb` 는 파일 백업 목록이다"]', 2, '`last` 는 `/var/log/wtmp`(로그인·로그아웃·재부팅 기록)를 시간 순서로 보여 줍니다. `lastlog` 는 `/var/log/lastlog` 에서 계정마다 가장 최근 로그인 한 줄만 보여 주고, 한 번도 안 한 계정은 `**Never logged in**` 입니다. `lastb` 는 `/var/log/btmp`(실패한 로그인 시도)를 보여 주며 보통 root 권한이 필요합니다. 현재 접속자는 `who`·`w` 로 봅니다. 장기간 쓰지 않는 계정을 정리할 때 `lastlog` 가 특히 유용합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 544 AND order_index = 12);
