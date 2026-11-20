-- 세트 518. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set518.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 518, '패키지 설치 실패 상황집: 저장소·서명·lock·의존성', 'apt 설치가 실패할 때 나오는 오류 메시지를 읽고 원인을 찾아 고칩니다. 저장소 경로 오타(File not found), 서명 없는 저장소(is not signed), 목록 갱신 누락(Unable to locate package), 다른 프로세스의 잠금(Could not get lock), 중단된 dpkg(dpkg was interrupted), dpkg -i 의 의존성 문제(apt-get install -f), 고정(hold)된 패키지(kept back), 버전 조건 의존성(unmet dependencies)을 로컬 저장소로 재현된 상황에서 직접 해결합니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 518);
UPDATE quest_set SET display_order = 739, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '🧯' WHERE id = 518;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 1, 'E: Failed to fetch ... File not found: 저장소 경로 오타', '**상황** — 팀에서 만든 사내 연습 저장소가 `/tmp/repo` 에 있고, 이 서버의 저장소 설정 파일은 `/etc/apt/sources.list.d/lab.list` 입니다. `apt-get update` 를 하면 이런 오류가 납니다.

```
E: Failed to fetch file:/tmp/rep/./Packages  File not found - /tmp/rep/./Packages (2: No such file or directory)
E: Some index files failed to download. They have been ignored, or old ones used instead.
```

`file:` 은 이 서버의 디렉터리를 저장소로 쓴다는 뜻입니다. 오류에 나온 주소와 실제 저장소 위치를 비교해 설정을 고치고, `apt-get update` 가 오류 없이 끝난 뒤 **`hello-lab`** 패키지를 설치하세요.', '오류 문장의 주소가 실제 디렉터리와 같은지 `ls /tmp` 로 확인하고, 설정 파일(`cat /etc/apt/sources.list.d/lab.list`)의 해당 부분을 고칩니다.', 'cat /etc/apt/sources.list.d/lab.list
sed -i ''s#/tmp/rep #/tmp/repo #'' /etc/apt/sources.list.d/lab.list
apt-get update
apt-get install -y hello-lab

# File not found = 저장소 주소(경로)에 파일이 없다. 대부분 오타이므로 오류에 찍힌 경로를 실제와 비교한다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb hello-lab 1.0 /tmp/repo; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/rep ./'' > /etc/apt/sources.list.d/lab.list"]', '["sh", "-c", "( apt-get update >/dev/null 2>&1 ) && ( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' hello-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "apt-get update 가 오류 없이 끝난다", "cmd": ["sh", "-c", "apt-get update >/dev/null 2>&1"]}, {"label": "hello-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' hello-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 2, 'The repository ... is not signed: 서명 없는 저장소', '**상황** — 새로 만든 연습 저장소 `file:/tmp/repo` 를 등록했더니 `apt-get update` 가 이렇게 실패합니다.

```
E: The repository ''file:/tmp/repo ./ Release'' is not signed.
N: Updating from such a repository can''t be done securely, and is therefore disabled by default.
```

apt 는 저장소 목록(`Release`)에 **GPG 서명**이 있어야 믿습니다. 이 저장소는 직접 만든 연습용이라 서명이 없습니다. 외부 저장소라면 공개키를 등록하는 것이 정석이지만, **직접 만든 로컬 저장소에 한해** 설정 줄의 대괄호 옵션으로 이 저장소를 신뢰한다고 표시할 수 있습니다. `/etc/apt/sources.list.d/lab.list` 를 고쳐 `apt-get update` 가 성공하게 하고 **`hello-lab`** 을 설치하세요.', '`deb` 와 주소 사이에 `[옵션=값]` 을 넣을 수 있습니다. `man sources.list` 의 옵션 목록에서 서명 검사와 관련된 것을 찾아 보세요. 외부 저장소에는 쓰지 않는 방법입니다.', 'sed -i ''s#^deb #deb [trusted=yes] #'' /etc/apt/sources.list.d/lab.list
cat /etc/apt/sources.list.d/lab.list
apt-get update
apt-get install -y hello-lab

# trusted=yes 는 서명 검사를 건너뛴다. 내가 직접 만든 연습 저장소에만 쓰고, 외부 저장소는 공개키를 받아 signed-by 로 지정한다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb hello-lab 1.0 /tmp/repo; /tmp/mkrepo.sh; echo ''deb file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list"]', '["sh", "-c", "( apt-get update >/dev/null 2>&1 ) && ( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' hello-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "apt-get update 가 오류 없이 끝난다", "cmd": ["sh", "-c", "apt-get update >/dev/null 2>&1"]}, {"label": "hello-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' hello-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 3, 'E: Unable to locate package: 분명 저장소에 올라왔는데 못 찾는다', '**상황** — 오늘 아침 저장소에 새 패키지 **`notice-lab`** 이 올라왔다고 합니다. 그런데 설치하려 하면 이렇게 나옵니다.

```
$ apt-get install -y notice-lab
E: Unable to locate package notice-lab
```

`apt-get install` 은 저장소를 직접 찾아가지 않고, 이 서버에 **미리 받아 둔 패키지 목록**에서 이름을 찾습니다. 저장소 설정(`lab.list`)은 올바릅니다. 원인을 해결하고 `notice-lab` 을 설치하세요.', '목록은 저장소가 바뀌어도 저절로 새로고침되지 않습니다. 목록을 새로 받는 단계를 먼저 하고 설치를 다시 시도하세요.', 'apt-get update
apt-get install -y notice-lab

# Unable to locate package = 내 목록에 그 이름이 없다. 오타가 아니라면 update 로 목록을 새로 받는다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb hello-lab 1.0 /tmp/repo; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1; mkdeb notice-lab 1.0 /tmp/repo; /tmp/mkrepo.sh"]', '["sh", "-c", "( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' notice-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "notice-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' notice-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 4, 'E: Could not get lock: 다른 프로세스가 잠금을 쥐고 있다', '**상황** — 설치를 시도하면 이런 오류가 납니다.

```
E: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 77 (perl)
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```

패키지 도구는 동시에 둘이 돌면 설치 DB 가 깨지므로 **잠금 파일**로 한 번에 하나만 돌게 합니다. 지금은 누군가 잠금을 쥔 채 멈춰 있는 프로세스가 있습니다. (이 서버에는 다른 사용자가 없고, 그 프로세스는 이 실습에서 만든 것이라 종료해도 됩니다.) **어떤 프로세스인지 먼저 확인**하고, 잠금을 풀어 **`hello-lab`** 을 설치하세요.', '오류에 나온 번호가 프로세스 번호(PID)입니다. `ps` 로 그 프로세스가 무엇인지 확인한 뒤 그 프로세스만 종료하세요. 잠금 파일을 지우는 것은 해결이 아닙니다.', 'ps aux | grep ''[p]erl''   # 오류 메시지의 번호(PID)가 어떤 프로세스인지 확인
kill $(pgrep -x perl)
apt-get install -y hello-lab

# 잠금은 쥔 프로세스가 끝나면 풀린다. 진행 중인 apt/dpkg 라면 끝나길 기다리고, 멈춘 프로세스임을 확인한 뒤에만 종료한다. 잠금 파일을 지우지 않는다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb hello-lab 1.0 /tmp/repo; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1; nohup perl -MFcntl -e ''open(F,\\">>\\",\\"/var/lib/dpkg/lock-frontend\\") or die; my $s=pack(\\"ssx4qqi\\",F_WRLCK,0,0,0,0); fcntl(F,F_SETLK,$s) or die; sleep 600'' lab-holder >/dev/null 2>&1 & sleep 1"]', '["sh", "-c", "( ! pgrep -f \\"[l]ab-holder\\" >/dev/null ) && ( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' hello-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "잠금을 쥔 프로세스가 없다", "cmd": ["sh", "-c", "! pgrep -f \\"[l]ab-holder\\" >/dev/null"]}, {"label": "hello-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' hello-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 5, 'dpkg was interrupted: 중단된 설치 이어서 끝내기', '**상황** — 어제 `pend-lab` 을 설치하던 중 서버가 강제로 꺼졌습니다. 이후 다른 패키지를 설치하려 하면 이렇게 나옵니다.

```
$ apt-get install -y other-lab
E: dpkg was interrupted, you must manually run ''dpkg --configure -a'' to correct the problem.
```

패키지 설치는 "풀기(unpack) → 설정(configure)" 단계로 진행되는데, 설정 도중 끊겨 `pend-lab` 이 **반쯤 설치된 상태**(`dpkg -s pend-lab` 의 Status 가 `half-configured`)입니다. 이 상태를 정리해 `pend-lab` 이 정상 설치로 바뀌게 하고, 그다음 **`other-lab`** 도 설치하세요.', '오류 메시지가 해야 할 일을 직접 알려 줍니다. 먼저 중단된 설치를 마무리한 뒤 새 설치를 시도하세요.', 'dpkg -s pend-lab | grep Status
dpkg --configure -a
dpkg -s pend-lab | grep Status
apt-get install -y other-lab

# --configure -a 는 풀어 놓기만 하고 설정이 끝나지 않은 모든 패키지의 설정을 마무리한다. 그 전에는 apt 가 새 작업을 거부한다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb other-lab 1.0 /tmp/repo; mkdeb pend-lab 1.0 /tmp/repo; printf ''#!/bin/sh\\\\nif [ ! -f /var/lib/pend-lab.done ]; then touch /var/lib/pend-lab.done; sleep 600; fi\\\\nexit 0\\\\n'' > /tmp/pk/pend-lab_1.0/DEBIAN/postinst; chmod +x /tmp/pk/pend-lab_1.0/DEBIAN/postinst; dpkg-deb --build /tmp/pk/pend-lab_1.0 /tmp/repo/pend-lab_1.0_all.deb >/dev/null; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1; (nohup dpkg -i /tmp/repo/pend-lab_1.0_all.deb >/dev/null 2>&1 &) ; sleep 2; pkill -9 -x dpkg; pkill -x sleep; sleep 1"]', '["sh", "-c", "( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' pend-lab 2>/dev/null)\\" = installed ] ) && ( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' other-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "pend-lab 이 정상 설치 상태다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' pend-lab 2>/dev/null)\\" = installed ]"]}, {"label": "other-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' other-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 6, 'dependency problems: dpkg -i 가 의존성에서 멈췄다', '**상황** — 내려받은 `/tmp/dl/app-lab_1.0_all.deb` 를 `dpkg -i` 로 설치했더니 이렇게 끝났습니다.

```
$ dpkg -i /tmp/dl/app-lab_1.0_all.deb
dpkg: dependency problems prevent configuration of app-lab:
 app-lab depends on libdep-lab; however:
  Package libdep-lab is not installed.
dpkg: error processing package app-lab (--install):
 dependency problems - leaving unconfigured
```

`dpkg` 는 **.deb 파일 하나만** 설치하고 필요한 다른 패키지는 가져오지 않습니다. 다행히 `libdep-lab` 은 등록된 저장소(`/tmp/repo`)에 있습니다. 저장소 목록에서 필요한 의존 패키지까지 가져와 `app-lab` 설치를 마무리하세요. (`app-lab` 과 `libdep-lab` 모두 설치된 상태가 되어야 합니다.)', '`apt-get` 에는 이미 걸쳐 놓은(풀린) 패키지의 빠진 의존성을 저장소에서 채워 주는 옵션이 있습니다. `apt-get install --help` 나 `man apt-get` 에서 "broken" 을 찾아 보세요.', 'dpkg -s app-lab | grep Status
apt-get install -f -y
dpkg -s app-lab libdep-lab | grep Status

# apt-get install -f (--fix-broken) 는 의존성이 빠진 패키지를 보고 저장소에서 필요한 것을 받아 설치를 마무리한다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb libdep-lab 1.0 /tmp/repo; mkdeb app-lab 1.0 /tmp/dl libdep-lab; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1; dpkg -i /tmp/dl/app-lab_1.0_all.deb >/dev/null 2>&1; true"]', '["sh", "-c", "( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' libdep-lab 2>/dev/null)\\" = installed ] ) && ( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' app-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "libdep-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' libdep-lab 2>/dev/null)\\" = installed ]"]}, {"label": "app-lab 이 정상 설치 상태다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' app-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 7, 'kept back: 고정(hold)된 패키지는 업그레이드되지 않는다', '**상황** — 저장소에 `hello-lab` 2.0 이 올라왔는데 업그레이드하면 1.0 그대로입니다.

```
$ apt-get upgrade -y
The following packages have been kept back:
  hello-lab
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
```

누군가 버전이 바뀌지 않게 이 패키지를 **고정(hold)** 해 둔 상태입니다. 지금은 업그레이드해도 되는 상황입니다. 어떤 패키지가 고정되어 있는지 `apt-mark` 로 확인하고, 고정을 풀어 `hello-lab` 을 **2.0** 으로 올리세요. (작업이 끝나면 고정된 패키지가 없어야 합니다.)', '`apt-mark` 에는 고정된 목록을 보는 동작과 고정을 푸는 동작이 따로 있습니다. 푼 뒤에 업그레이드 명령을 다시 실행하세요.', 'apt-mark showhold
apt-mark unhold hello-lab
apt-get install -y --only-upgrade hello-lab
dpkg-query -W hello-lab

# hold 는 업그레이드를 막는 표시다. 풀지 않고 강제로 바꾸는 옵션도 있지만, 왜 고정했는지 알아본 뒤 푸는 것이 안전하다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb hello-lab 1.0 /tmp/repo; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1; apt-get install -y hello-lab >/dev/null 2>&1; apt-mark hold hello-lab >/dev/null; mkdeb hello-lab 2.0 /tmp/repo; /tmp/mkrepo.sh; apt-get update >/dev/null 2>&1"]', '["sh", "-c", "( [ \\"$(dpkg-query -W -f=''${Version}'' hello-lab 2>/dev/null)\\" = 2.0 ] ) && ( [ -z \\"$(apt-mark showhold)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "hello-lab 이 2.0 이다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${Version}'' hello-lab 2>/dev/null)\\" = 2.0 ]"]}, {"label": "고정된 패키지가 없다", "cmd": ["sh", "-c", "[ -z \\"$(apt-mark showhold)\\" ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 8, 'unmet dependencies: 필요한 버전이 저장소에 없다', '**상황** — `app2-lab` 을 설치하면 이렇게 실패합니다.

```
$ apt-get install -y app2-lab
The following packages have unmet dependencies:
 app2-lab : Depends: libdep2-lab (>= 2.0) but it is not going to be installed
E: Unable to correct problems, you have held broken packages.
```

`app2-lab` 은 `libdep2-lab` 의 **2.0 이상**이 필요한데, 저장소에는 1.0 만 있습니다. 개발팀이 새 버전 파일 `/tmp/extra/libdep2-lab_2.0_all.deb` 를 전달해 왔습니다. 이 파일을 저장소 디렉터리 `/tmp/repo` 에 넣고, 색인 갱신 스크립트 `/tmp/mkrepo.sh` 로 목록을 다시 만든 뒤, apt 가 새 목록을 받아 **`app2-lab`** 이 설치되게 하세요.', '순서는 파일을 저장소에 놓고, 저장소 색인을 다시 만들고, apt 의 목록을 새로 받는 것입니다. 마지막으로 설치를 시도합니다.', 'cp /tmp/extra/libdep2-lab_2.0_all.deb /tmp/repo/
/tmp/mkrepo.sh
apt-get update
apt-get install -y app2-lab
dpkg-query -W libdep2-lab app2-lab

# 버전 조건(>= 2.0)을 만족하는 패키지가 저장소 목록에 있어야 한다. 파일만 복사하면 부족하고, 저장소 색인과 apt 의 목록을 모두 새로 만들어야 보인다', '["sh", "-c", "mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; { printf ''Package: %s\\\\nVersion: %s\\\\nArchitecture: all\\\\nMaintainer: Lab <lab@example.com>\\\\nDescription: lab package %s\\\\n'' $1 $2 $1; [ -n \\"$4\\" ] && printf ''Depends: %s\\\\n'' \\"$4\\"; } > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }\\ncat > /tmp/mkrepo.sh <<''X''\\n#!/bin/sh\\n# /tmp/repo 의 .deb 들로 저장소 색인(Packages, Release)을 다시 만든다\\ncd /tmp/repo || exit 1\\n: > Packages\\nfor f in *.deb; do\\n  dpkg-deb -f \\"$f\\" >> Packages\\n  printf ''Filename: ./%s\\\\nSize: %s\\\\nSHA256: %s\\\\n\\\\n'' \\"$f\\" \\"$(stat -c%s \\"$f\\")\\" \\"$(sha256sum \\"$f\\" | cut -d'' '' -f1)\\" >> Packages\\ndone\\n{ echo ''Origin: Lab''; echo ''Suite: stable''; echo ''Date: Thu, 19 Nov 2026 00:00:00 UTC''; echo ''SHA256:''; printf '' %s %s Packages\\\\n'' \\"$(sha256sum Packages | cut -d'' '' -f1)\\" \\"$(stat -c%s Packages)\\"; } > Release\\nX\\nchmod +x /tmp/mkrepo.sh\\nmkdir -p /tmp/repo /tmp/extra /tmp/dl\\nrm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig\\nmkdeb libdep2-lab 1.0 /tmp/repo; mkdeb app2-lab 1.0 /tmp/repo ''libdep2-lab (>= 2.0)''; mkdeb libdep2-lab 2.0 /tmp/extra; /tmp/mkrepo.sh; echo ''deb [trusted=yes] file:/tmp/repo ./'' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1"]', '["sh", "-c", "( [ \\"$(dpkg-query -W -f=''${Version}'' libdep2-lab 2>/dev/null)\\" = 2.0 ] ) && ( [ \\"$(dpkg-query -W -f=''${db:Status-Status}'' app2-lab 2>/dev/null)\\" = installed ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "libdep2-lab 이 2.0 이다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${Version}'' libdep2-lab 2>/dev/null)\\" = 2.0 ]"]}, {"label": "app2-lab 이 설치되었다", "cmd": ["sh", "-c", "[ \\"$(dpkg-query -W -f=''${db:Status-Status}'' app2-lab 2>/dev/null)\\" = installed ]"]}]', '[{"title": "apt-get 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man8/apt-get.8.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 9, 'NO_PUBKEY 오류의 원인과 올바른 조치', '외부 저장소를 추가한 뒤 `apt update` 를 하니 다음 출력이 나왔습니다. (주소와 키 값은 예시입니다.)

```
W: GPG error: https://repo.example.com/apt stable InRelease: The following signatures couldn''t be verified because the public key is not available: NO_PUBKEY 4F2A9C1D7B3E5A60
E: The repository ''https://repo.example.com/apt stable InRelease'' is not signed.
```

원인과 가장 알맞은 조치는 무엇일까요?', '`NO_PUBKEY` 는 서명을 확인할 공개키가 이 서버에 없다는 뜻입니다. 믿을 수 있는 출처가 어디인지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["저장소 서버가 꺼져 있다. 잠시 뒤 `apt update` 를 다시 실행한다", "저장소가 서명한 공개키가 서버에 없다. 저장소 운영처가 공개한 키를 받아 키 파일로 두고 `signed-by` 로 지정한다", "디스크가 가득 찼다. `apt clean` 으로 공간을 확보한다", "검증이 귀찮으니 모든 외부 저장소 줄에 `[trusted=yes]` 를 붙여 서명 검사를 끈다"]', 1, '`NO_PUBKEY` 는 저장소 목록의 서명을 검증할 공개키가 없다는 뜻이라, 운영처가 공개한 키를 받아 키링에 두고 `signed-by` 로 지정하는 것이 정석입니다. 서버가 꺼졌다면 접속 오류가, 디스크가 가득 찼다면 공간 부족 오류가 나옵니다. `trusted=yes` 는 서명 검사를 통째로 끄는 것이라 변조된 패키지도 막지 못하므로, 직접 만든 로컬 연습 저장소가 아니면 쓰지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 10, '서명 키를 지정하는 옵션', '외부 저장소의 공개키 파일 `/etc/apt/keyrings/example.gpg` 로 이 저장소의 서명만 검증하도록 설정 줄을 완성하세요. (주소는 예시입니다.)', '키 파일 경로를 값으로 받는 옵션입니다. 신뢰 여부를 yes/no 로 적는 옵션과 다릅니다.', NULL, NULL, '[]', 'fill', '["signed-by", "trusted", "check-valid-until", "allow-insecure"]', NULL, '`signed-by=키파일경로` 는 이 저장소는 그 키로 서명된 것만 믿는다는 뜻입니다. `trusted` 는 `yes`/`no` 값을 받아 서명 검사를 끄고 켜는 옵션이고, `check-valid-until` 은 Release 의 유효 기간 검사 여부를 정하며, `allow-insecure` 는 서명 없는 저장소를 허용하는 위험한 옵션입니다.', '[0]', 'deb [{0}=/etc/apt/keyrings/example.gpg] https://repo.example.com/apt stable main', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 11, '패키지 설치 실패를 진단하는 순서', '`apt-get install` 이 실패했을 때의 점검 흐름입니다. 올바른 순서로 놓으세요.', '추측하기 전에 증거를 읽고, 고친 뒤에는 처음 하려던 일이 되는지까지 확인합니다.', NULL, NULL, '[]', 'order', '["설치를 다시 시도한다", "오류 메시지 원문(`E:` 줄)을 읽는다", "저장소 설정을 고치고 `apt-get update` 로 목록을 갱신한다", "`dpkg -s` 로 설치 상태를 확인한다", "오류가 저장소·서명·잠금·의존성 중 어느 종류인지 가른다"]', NULL, '먼저 `E:` 줄의 원문을 읽고, 그것이 저장소·서명·잠금·의존성 중 어느 문제인지 가릅니다. 그 종류에 맞게 원인(여기서는 저장소 설정)을 고치고 목록을 갱신한 뒤 설치를 다시 시도하고, 마지막으로 `dpkg -s` 로 정말 설치되었는지 확인합니다.', '[1, 4, 2, 0, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 518, 12, 'Temporary failure resolving 의 원인', '`apt update` 가 다음과 같이 실패했습니다. (주소는 예시입니다.)

```
Err:1 https://repo.example.com/apt stable InRelease
  Temporary failure resolving ''repo.example.com''
W: Failed to fetch https://repo.example.com/apt/dists/stable/InRelease  Temporary failure resolving ''repo.example.com''
```

가장 먼저 의심할 것은 무엇일까요?', '오류 문장 속 `resolving` 이 어떤 단계의 이름인지 생각해 보세요. 서명이나 잠금, 고정(hold) 과는 다른 단계에서 난 오류입니다.', NULL, NULL, '[]', 'choice', '["저장소 서명용 공개키가 없다. 키를 등록한다", "다른 프로세스가 dpkg 잠금을 쥐고 있다. 그 프로세스를 확인한다", "이름을 IP 주소로 바꾸지 못했다. DNS 설정(`/etc/resolv.conf`)과 서버의 네트워크 연결을 확인한다", "패키지가 hold 되어 있다. `apt-mark unhold` 를 한다"]', 2, '`Temporary failure resolving` 은 저장소 서버 이름을 IP 로 바꾸는 DNS 조회에 실패했다는 뜻이라, DNS 설정과 네트워크 연결부터 봅니다. 공개키 문제는 `NO_PUBKEY`·`is not signed` 로, 잠금은 `Could not get lock` 으로, hold 는 `kept back` 으로 나타납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 518 AND order_index = 12);
