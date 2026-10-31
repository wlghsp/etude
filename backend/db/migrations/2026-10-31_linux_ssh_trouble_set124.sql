-- 미들웨어 세트 124. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set124.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 4, '리눅스', '운영과 장애 대응', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 4);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 124, 'SSH 접속 문제 해결 상황집: publickey, 권한, 호스트 키, 설정 파일', 'SSH 접속이 안 될 때 원인을 좁히는 법을 익힙니다. ssh -v 읽기, Permission denied (publickey), 호스트 키 변경 경고와 ssh-keygen -R, .ssh 폴더와 키 파일 권한(700/600), 서버의 bad ownership or modes 로그, 점검 순서, Too many authentication failures 와 IdentitiesOnly, ~/.ssh/config 별칭, 비밀번호 로그인 차단 전 주의점을 문제와 파일 실습으로 다룹니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 124);
UPDATE quest_set SET display_order = 165, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '🔐' WHERE id = 124;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 1, 'ssh 로 원인 찾을 때 쓰는 옵션', '접속이 안 될 때는 과정을 자세히 보는 옵션과, **어떤 비밀키를 쓸지** 지정하는 옵션을 씁니다. 빈칸을 채우세요.', '자세히는 verbose 의 v, 키 파일 지정은 identity 의 i 예요.', NULL, NULL, '[]', 'fill', '["-v", "~/.ssh/id_ed25519", "~/.ssh/id_ed25519.pub", "~/.ssh/known_hosts"]', NULL, '`-v` 는 어떤 키를 시도하고 어떤 단계에서 거절당했는지 보여 줍니다. `-vv`, `-vvv` 로 더 자세히 볼 수 있어요. `-i` 에는 **비밀키**(`.pub` 이 아닌 것)를 지정합니다.', '[0, 1]', 'ssh {0} user@server.example.com
ssh -i {1} user@server.example.com', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 2, 'Permission denied (publickey)', '`ssh user@server.example.com` 이 `Permission denied (publickey)` 로 실패합니다. 가장 알맞은 점검 방향은 무엇일까요?', '서버가 내 공개키를 인정하지 않는 거예요. 키, 사용자 이름, 등록 상태를 보세요.', NULL, NULL, '[]', 'choice', '["서버의 디스크가 가득 찼는지만 본다", "비밀번호를 여러 번 입력해 본다", "로컬 시간을 바꾼다", "`ssh -v` 로 어떤 키를 제시했는지 보고, 그 공개키가 서버 계정의 `authorized_keys` 에 있는지, 사용자 이름과 파일 권한이 맞는지 확인한다"]', 3, '`publickey` 인증 실패는 대부분 ① 다른 키를 쓰고 있거나 ② 서버에 공개키가 없거나 ③ 권한 때문에 서버가 무시하거나 ④ 사용자 이름이 틀린 경우입니다. `-v` 출력으로 어느 쪽인지 좁혀 가세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 3, 'REMOTE HOST IDENTIFICATION HAS CHANGED', '평소 잘 접속하던 서버에 접속하니 `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` 가 크게 나옵니다. 올바른 대응은 무엇일까요?', '서버의 "신분증"이 바뀌었다는 경고예요. 정당한 이유인지 먼저 따져야 해요.', NULL, NULL, '[]', 'choice', '["경고를 무시하고 `StrictHostKeyChecking no` 를 영구히 켠다", "서버를 재설치했거나 주소가 다른 서버로 바뀐 것 같은 정당한 이유가 있는지 먼저 확인하고, 확인되면 `ssh-keygen -R 호스트` 로 옛 항목을 지운 뒤 새 지문을 확인하고 접속한다", "known_hosts 파일 전체를 지운다", "서버 비밀번호를 바꾼다"]', 1, '이 경고는 중간자 공격의 신호일 수도 있어서 이유 확인이 먼저입니다. 정당한 변경이면 `ssh-keygen -R` 로 해당 항목만 지우고 지문을 확인하세요. 검증을 끄는 설정을 습관으로 두면 보호가 사라집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 4, '.ssh 폴더와 키 파일 권한 고치기', '`/tmp/sshhome/.ssh` 의 권한이 모두 너무 열려 있어 서버가 키를 무시합니다. 올바른 권한으로 고치세요: **`.ssh` 폴더 700**, **비밀키 `id_ed25519` 600**, **`authorized_keys` 600**.', '폴더는 소유자만 들어가게(700), 파일은 소유자만 읽고 쓰게(600) 합니다. `chmod 700 폴더`, `chmod 600 파일`.
확인: `ls -ld /tmp/sshhome/.ssh; ls -l /tmp/sshhome/.ssh`', 'ls -ld /tmp/sshhome/.ssh; ls -l /tmp/sshhome/.ssh
chmod 700 /tmp/sshhome/.ssh
chmod 600 /tmp/sshhome/.ssh/id_ed25519 /tmp/sshhome/.ssh/authorized_keys
ls -ld /tmp/sshhome/.ssh; ls -l /tmp/sshhome/.ssh

# 그룹·타인이 쓰거나 읽을 수 있으면 sshd 가 "bad ownership or modes" 로 키를 무시한다', '["sh", "-c", "rm -rf /tmp/sshhome && mkdir -p /tmp/sshhome/.ssh && echo key > /tmp/sshhome/.ssh/id_ed25519 && echo pub > /tmp/sshhome/.ssh/authorized_keys && chmod 777 /tmp/sshhome/.ssh && chmod 644 /tmp/sshhome/.ssh/id_ed25519 && chmod 666 /tmp/sshhome/.ssh/authorized_keys"]', '["sh", "-c", "( [ \\"$(stat -c %a /tmp/sshhome/.ssh)\\" = 700 ] ) && ( [ \\"$(stat -c %a /tmp/sshhome/.ssh/id_ed25519)\\" = 600 ] ) && ( [ \\"$(stat -c %a /tmp/sshhome/.ssh/authorized_keys)\\" = 600 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": ".ssh 폴더가 700 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/sshhome/.ssh)\\" = 700 ]"]}, {"label": "비밀키가 600 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/sshhome/.ssh/id_ed25519)\\" = 600 ]"]}, {"label": "authorized_keys 가 600 이다", "cmd": ["sh", "-c", "[ \\"$(stat -c %a /tmp/sshhome/.ssh/authorized_keys)\\" = 600 ]"]}]', '[{"title": "ssh(1) 매뉴얼", "url": "https://man.openbsd.org/ssh"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 5, 'bad ownership or modes', '키를 정확히 등록했는데도 접속이 안 되고, 서버의 인증 로그에 `Authentication refused: bad ownership or modes for directory /home/app/.ssh` 가 있습니다. 가장 알맞은 해석은 무엇일까요?', 'sshd 는 보안을 위해 권한이 느슨한 키 파일을 신뢰하지 않아요.', NULL, NULL, '[]', 'choice', '["`.ssh` 폴더(또는 홈, `authorized_keys`)의 소유자나 권한이 느슨해서 sshd 가 키를 무시한다. 소유자를 맞추고 `.ssh` 는 700, `authorized_keys` 는 600 으로 고친다", "비밀키가 만료됐다", "서버의 포트가 닫혀 있다", "로컬의 known_hosts 가 가득 찼다"]', 0, '서버 쪽 로그(예: `/var/log/auth.log`, `journalctl -u ssh`)에는 클라이언트에 보이지 않는 거절 이유가 적혀 있습니다. 홈 디렉터리가 그룹 쓰기 가능이어도 거절될 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 6, 'known_hosts 에서 한 서버만 지우기', '`/tmp/known_hosts` 에 서버 3대(`hosta`, `hostb`, `hostc`)의 지문이 있습니다. 서버 `hostb` 가 재설치되어 옛 항목만 지워야 합니다. **`hostb` 항목만** 지우고 나머지는 그대로 두세요. (`ssh-keygen -R` 을 쓸 수 있어요)', '`ssh-keygen -R 호스트 -f 파일` 로 해당 호스트의 줄을 지웁니다.
확인: `cat /tmp/known_hosts`', 'cat /tmp/known_hosts
ssh-keygen -R hostb -f /tmp/known_hosts
cat /tmp/known_hosts

# 파일 전체를 지우면 다른 서버의 확인 기록까지 사라진다. 바뀐 서버의 항목만 지운다', '["sh", "-c", "rm -f /tmp/known_hosts /tmp/known_hosts.old /tmp/k_host*; for h in hosta hostb hostc; do ssh-keygen -q -t ed25519 -N '''' -f /tmp/k_$h; echo \\"$h $(cut -d'' '' -f1,2 /tmp/k_$h.pub)\\" >> /tmp/known_hosts; done"]', '["sh", "-c", "( ! grep -q \\"^hostb \\" /tmp/known_hosts ) && ( grep -q \\"^hosta \\" /tmp/known_hosts ) && ( grep -q \\"^hostc \\" /tmp/known_hosts )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "hostb 항목이 없다", "cmd": ["sh", "-c", "! grep -q \\"^hostb \\" /tmp/known_hosts"]}, {"label": "hosta 항목이 남아 있다", "cmd": ["sh", "-c", "grep -q \\"^hosta \\" /tmp/known_hosts"]}, {"label": "hostc 항목이 남아 있다", "cmd": ["sh", "-c", "grep -q \\"^hostc \\" /tmp/known_hosts"]}]', '[{"title": "ssh(1) 매뉴얼", "url": "https://man.openbsd.org/ssh"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 7, 'SSH 접속 실패 점검 순서', 'SSH 접속이 안 됩니다. 순서에 맞게 놓아 보세요.', '메시지 → 자세히 → 도달 → 내 설정 → 서버 로그 순이에요.', NULL, NULL, '[]', 'order', '["오류 메시지(refused, timed out, publickey 거부)를 읽어 종류를 구분한다", "`ssh -v` 로 어느 단계에서 막히는지 본다", "서버의 22번 포트에 닿는지 확인한다 (`nc -zv`)", "사용자 이름, 키 파일, `authorized_keys`, 권한을 확인한다", "서버의 인증 로그에서 거절 이유를 확인한다"]', NULL, '메시지 종류가 가장 큰 단서입니다. 연결 단계(refused, timeout)와 인증 단계(publickey)는 원인이 완전히 달라서, 어느 층에서 막혔는지를 먼저 가르세요.', '[0, 1, 2, 3, 4]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 8, 'Too many authentication failures', '`ssh user@server.example.com` 이 `Too many authentication failures` 로 끊깁니다. 로컬에는 키가 여러 개 있고 ssh-agent 에도 여러 개가 올라가 있습니다. 가장 알맞은 해결은 무엇일까요?', '서버는 시도 횟수를 제한해요. 여러 키를 차례로 내밀다가 한도에 걸린 거예요.', NULL, NULL, '[]', 'choice', '["서버를 재부팅한다", "키를 모두 삭제한다", "`-o IdentitiesOnly=yes -i 사용할키` 로 지정한 키만 시도하게 한다 (`~/.ssh/config` 의 Host 항목에 적어도 된다)", "포트를 바꾼다"]', 2, 'ssh 는 agent 의 키를 차례로 모두 제시하는데, 서버의 `MaxAuthTries`(기본 6) 를 넘으면 끊습니다. `IdentitiesOnly yes` 로 쓸 키를 고정하면 해결돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 9, 'ssh config 별칭 읽기', '`~/.ssh/config` 에 별칭 `dev` 를 만들어 `ssh dev` 로 접속하려 합니다. 사용자는 `deploy`, 비밀키는 `~/.ssh/id_ed25519` 입니다. 빈칸을 채우세요.', '접속할 계정 이름과, 비밀키(공개키가 아닌) 경로가 들어가요.', NULL, NULL, '[]', 'fill', '["deploy", "~/.ssh/id_ed25519", "root", "~/.ssh/id_ed25519.pub"]', NULL, '`Host` 는 별칭, `HostName` 은 실제 주소입니다. `IdentityFile` 에는 비밀키를 적어요. 별칭을 쓰면 긴 옵션을 매번 치지 않아도 되고 "어떤 키로 접속하는지"가 파일에 남습니다.', '[0, 1]', 'Host dev
  HostName server.example.com
  User {0}
  IdentityFile {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 10, 'ssh 설정 파일 직접 쓰기', '`/tmp/ssh_config` 에 별칭 `dev` 설정을 쓰세요. 주소 `server.example.com`, 사용자 `deploy`, 비밀키 `~/.ssh/id_ed25519` 입니다. 완성하면 `ssh -G -F /tmp/ssh_config dev` 로 적용된 값을 볼 수 있어요.', '`printf` 로 `Host dev`, `  HostName ...`, `  User ...`, `  IdentityFile ...` 네 줄을 쓰세요.
확인: `ssh -G -F /tmp/ssh_config dev | grep -iE "^(hostname|user|identityfile) "`', 'printf ''%s\\n'' ''Host dev'' ''  HostName server.example.com'' ''  User deploy'' ''  IdentityFile ~/.ssh/id_ed25519'' > /tmp/ssh_config
ssh -G -F /tmp/ssh_config dev | grep -iE ''^(hostname|user|identityfile) ''

# ssh -G 는 접속하지 않고 "이 설정이면 실제로 이렇게 적용된다"를 보여 준다', '["sh", "-c", "rm -f /tmp/ssh_config"]', '["sh", "-c", "( ssh -G -F /tmp/ssh_config dev | grep -qx \\"hostname server.example.com\\" ) && ( ssh -G -F /tmp/ssh_config dev | grep -qx \\"user deploy\\" ) && ( ssh -G -F /tmp/ssh_config dev | grep -q \\"^identityfile .*id_ed25519$\\" )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "주소가 맞다", "cmd": ["sh", "-c", "ssh -G -F /tmp/ssh_config dev | grep -qx \\"hostname server.example.com\\""]}, {"label": "사용자가 deploy 이다", "cmd": ["sh", "-c", "ssh -G -F /tmp/ssh_config dev | grep -qx \\"user deploy\\""]}, {"label": "비밀키 경로가 지정됐다", "cmd": ["sh", "-c", "ssh -G -F /tmp/ssh_config dev | grep -q \\"^identityfile .*id_ed25519$\\""]}]', '[{"title": "ssh(1) 매뉴얼", "url": "https://man.openbsd.org/ssh"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 124, 11, '비밀번호 로그인을 막기 전에', '보안을 위해 서버의 `PasswordAuthentication no` 로 바꾸려 합니다. 적용 전에 가장 중요한 주의사항은 무엇일까요?', '설정을 잘못하면 아무도 로그인하지 못하게 될 수 있어요.', NULL, NULL, '[]', 'choice', '["재부팅을 먼저 한다", "키로 로그인이 되는 것을 **다른 세션에서 먼저 확인**하고, 현재 접속한 세션은 닫지 않은 채 설정을 적용·시험한다", "키 없이 바로 적용한다", "모든 사용자의 비밀번호를 지운다"]', 1, '설정을 잘못하면 서버에서 잠겨 나올 수 있습니다. 열어 둔 세션을 유지한 채 새 세션으로 키 접속이 되는지 확인하고 나서 닫으세요. `sshd -t` 로 설정 문법을 먼저 검사하는 것도 좋은 습관이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 124 AND order_index = 11);
