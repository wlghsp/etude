import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 543 ACL과 특수 권한 직접 해 보기. 명세: docs/specs/spec_gap_set543.md
# linux-systemd(Rocky 9) 샌드박스는 root 이고 getfacl/setfacl·useradd·su 가 실제로 동작한다(직접 확인). 파일시스템 ACL 도 된다.

CLEAN = "rm -rf /srv/acl /srv/old /srv/proj /srv/shared /srv/drop /srv/team /tmp/*.txt; mkdir -p /srv"
USERS = ("for u in kim lee outsider; do id $u >/dev/null 2>&1 || useradd $u; done\n"
         "getent group dev >/dev/null || groupadd dev\nusermod -aG dev kim\nusermod -aG dev lee\n")

b = SetBuilder(543, 'ACL과 특수 권한 직접 해 보기: setfacl·default ACL·setgid·sticky',
               '권한이 "소유자·그룹·기타" 세 칸으로는 모자랄 때 쓰는 ACL 을 직접 만지고, 협업 폴더에 쓰는 특수 권한(setgid·sticky)을 켜 봅니다. `getfacl`·`setfacl -m`·`-x`·`-R` 로 특정 사용자만 허용·제거하고, `-d` 로 앞으로 만들 파일에 물려줄 default ACL 을 설정하며, 폴더에 setgid 를 켜 그룹이 상속되게 하고, sticky 로 남의 파일 삭제를 막습니다. 샌드박스에서 실제로 동작하는 명령으로 결과를 `getfacl`·`ls -l` 로 직접 확인합니다.',
               'linux-systemd', '리눅스', 59, 802, '🔐',
               [{"title": "setfacl 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/setfacl.1.html"}, {"title": "acl 개요(7)", "url": "https://man7.org/linux/man-pages/man5/acl.5.html"}, {"title": "chmod 매뉴얼: setuid·setgid·sticky", "url": "https://man7.org/linux/man-pages/man1/chmod.1.html"}], 1)

# 1 -------------------------------------------------------------
b.nt('ls -l 의 + 표시로 ACL 있는 파일 찾기', '`/srv/acl` 폴더에 파일이 세 개 있습니다. 그중 일부에는 ACL(기본 소유자·그룹·기타 외의 추가 권한 항목)이 붙어 있습니다. ACL 이 붙은 파일은 `ls -l` 의 권한 문자열 **맨 끝에 `+`** 가 붙습니다. (예: `-rw-r--r--+`)\n\n**ACL 이 붙은 파일의 이름**을 한 줄에 하나씩 **`/tmp/acl_files.txt`** 에 저장하세요.',
     '`ls -l` 결과에서 첫 칸(권한 문자열)의 끝 글자만 보고 줄을 고르세요. `getfacl` 로 각 파일을 하나씩 열어 확인해도 됩니다.',
     "ls -l /srv/acl\nls -l /srv/acl | awk '$1 ~ /\\+$/ {print $NF}' > /tmp/acl_files.txt\ncat /tmp/acl_files.txt   # a.txt, c.txt\n# + 는 getfacl 로 보면 user:이름 같은 추가 항목이 있다는 표시",
     CLEAN + "\n" + USERS + "mkdir /srv/acl; cd /srv/acl; touch a.txt b.txt c.txt\nsetfacl -m u:kim:r a.txt\nsetfacl -m u:lee:rw c.txt\n",
     [chk('ACL 이 붙은 파일 이름이 정확히 두 개다', '[ "$(sort /tmp/acl_files.txt | tr "\\n" " ")" = "a.txt c.txt " ]')])
# 2 -------------------------------------------------------------
b.nt('특정 사용자 한 명에게만 읽기·쓰기 허용 (setfacl -m)', '`/srv/acl/report.txt` 는 소유자 root, 모드 `640`(root 외 다른 사용자는 읽을 수도 없음)입니다. 사용자 **kim 에게만** 이 파일의 읽기·쓰기를 허용하세요. 다른 사용자(`lee` 등)는 여전히 접근할 수 없어야 하고, 모드(`chmod`)는 바꾸지 않습니다.\n\n`setfacl -m` 의 `-m` 은 modify(항목 추가·수정)입니다. 항목은 `종류:이름:권한` 형식이고 종류 `u` 는 사용자입니다. 끝나면 `getfacl 파일` 로 확인하세요.',
     '`setfacl -m` 뒤에 `u:사용자:권한문자` 를 쓰고 대상 파일을 적습니다. 권한 문자는 `ls -l` 에서 보던 r·w·x 입니다.',
     "setfacl -m u:kim:rw /srv/acl/report.txt\ngetfacl /srv/acl/report.txt\n# user:kim:rw- 항목이 생긴다. 모드(chmod)는 그대로이고 다른 사용자는 막혀 있다",
     CLEAN + "\n" + USERS + "mkdir /srv/acl; echo secret > /srv/acl/report.txt; chmod 640 /srv/acl/report.txt\n",
     [chk('kim 항목이 rw- 로 있다', 'getfacl -p /srv/acl/report.txt | grep -q "^user:kim:rw-"'),
      chk('kim 이 실제로 쓸 수 있다', 'su kim -c "test -w /srv/acl/report.txt"'),
      chk('lee 는 여전히 읽을 수 없다', '! su lee -c "test -r /srv/acl/report.txt"')])
# 3 -------------------------------------------------------------
b.fill('ACL 항목 하나만 지우기', '`/srv/acl/memo.txt` 에는 kim 과 lee 두 사용자 항목이 있습니다. **lee 항목만** 지우고 kim 항목은 남기려 합니다. 빈칸을 채우세요.\n\n`setfacl` 의 옵션: `-m` 항목 추가·수정, `-x` 지정한 항목 제거, `-b` 확장 ACL 전부 제거, `-k` default ACL 제거.',
       '지울 대상을 `u:lee` 처럼 지정하는 옵션과, 지정 없이 전부 지우는 옵션을 구분하세요. `setfacl --help` 에도 설명이 있습니다.',
       'setfacl {0} u:lee /srv/acl/memo.txt', ['-x', '-b', '-m', '-k'], [0],
       '`-x u:lee` 는 lee 항목 하나만 지웁니다(권한 문자는 쓰지 않습니다). `-b` 는 kim 항목까지 확장 ACL 을 전부 지우고, `-k` 는 폴더의 default ACL 만 지우며, `-m` 은 항목을 추가·수정하는 옵션이라 권한 문자 없이는 오류입니다. 지운 뒤에는 `getfacl` 로 남은 항목을 확인합니다.')
# 4 -------------------------------------------------------------
b.nt('이미 있는 폴더 전체에 ACL 주기 (-R 과 대문자 X)', '`/srv/old` 폴더 안에 파일 `a.txt` 와 하위 폴더 `sub`(안에 `b.txt`)가 이미 있고, 모두 root 만 접근할 수 있습니다(`640`/`750`). **lee 에게** 파일은 읽기·쓰기(`rw-`), 폴더는 들어가서 목록을 볼 수 있게(`rwx`) 허용하세요. `/srv/old` 자신과 그 안의 모든 파일·폴더에 적용합니다.\n\n`-R` 은 하위까지 재귀 적용입니다. 권한 문자에는 `r w x` 외에 **대문자 `X`** 가 있어, "폴더이거나 이미 실행 권한이 있는 파일일 때만 x 를 준다"는 뜻입니다. 일반 파일에 실행 권한을 주지 않으면서 폴더에는 x 를 주는 데 씁니다.',
     '`-m` 에 재귀 옵션을 더하고, 권한 문자 자리에는 r, w 와 설명에 나온 문자를 조합합니다. 끝나면 `getfacl -R /srv/old` 로 파일마다 확인하세요.',
     "setfacl -R -m u:lee:rwX /srv/old\ngetfacl -R /srv/old | grep -E '^# file|user:lee'\n# 파일: user:lee:rw-, 폴더: user:lee:rwx",
     CLEAN + "\n" + USERS + "mkdir -p /srv/old/sub; echo a > /srv/old/a.txt; echo b > /srv/old/sub/b.txt; chmod 640 /srv/old/a.txt /srv/old/sub/b.txt; chmod 750 /srv/old /srv/old/sub\n",
     [chk('a.txt 에 lee rw- 가 있다', 'getfacl -p /srv/old/a.txt | grep -q "^user:lee:rw-$"'),
      chk('sub/b.txt 에도 lee rw- 가 있다', 'getfacl -p /srv/old/sub/b.txt | grep -q "^user:lee:rw-$"'),
      chk('폴더 sub 와 /srv/old 에 lee rwx 가 있다', 'getfacl -p /srv/old/sub | grep -q "^user:lee:rwx$" && getfacl -p /srv/old | grep -q "^user:lee:rwx$"'),
      chk('lee 가 b.txt 를 쓸 수 있다', 'su lee -c "test -w /srv/old/sub/b.txt"')])
# 5 -------------------------------------------------------------
b.nt('앞으로 만들 파일에 물려줄 default ACL (setfacl -d)', '`/srv/proj` 폴더는 누구나 들어갈 수 있습니다(`755`). 그런데 이 폴더 안에 **앞으로 만들어질 파일**마다 매번 `setfacl` 을 하기는 번거롭습니다. 폴더에 **default ACL** 을 걸어 두면, 안에 새로 만들어지는 파일·폴더가 그 항목을 물려받습니다. 이 폴더에 새로 만든 파일을 **lee 가 읽고 쓸 수 있도록** default ACL 을 설정하세요.\n\n`setfacl -d` 는 default 항목을 다루는 옵션입니다. 설정 뒤 `getfacl /srv/proj` 에 `default:` 로 시작하는 줄이 보이면 됩니다. (이미 있는 파일은 대상이 아닙니다.)',
     '`-m` 에 default 를 뜻하는 옵션 하나를 더합니다. 대상은 파일이 아니라 폴더 `/srv/proj` 입니다. 결과는 `getfacl` 의 `default:` 줄로 확인하세요.',
     "setfacl -d -m u:lee:rw /srv/proj\ngetfacl /srv/proj\ntouch /srv/proj/new.txt; getfacl /srv/proj/new.txt\n# default:user:lee:rw- 가 생기고, 새 파일에 user:lee:rw- 가 자동으로 붙는다",
     CLEAN + "\n" + USERS + "mkdir /srv/proj; chmod 755 /srv/proj\n",
     [chk('폴더에 default:user:lee 항목이 있다', 'getfacl -p /srv/proj | grep -q "^default:user:lee:rw"'),
      chk('새로 만든 파일을 lee 가 쓸 수 있다 (umask 027 로 만들어도)', '( umask 027; touch /srv/proj/new.txt; su lee -c "test -w /srv/proj/new.txt"; r=$?; rm -f /srv/proj/new.txt; exit $r )')])
# 6 -------------------------------------------------------------
b.choice('default ACL 을 걸었는데 기존 파일은 그대로', '`/srv/proj` 에 `setfacl -d -m u:lee:rw /srv/proj` 를 실행했습니다. 그 뒤 새로 만든 `new.txt` 에는 lee 항목이 붙었는데, 폴더에 **원래 있던** `old.txt` 에는 lee 항목이 없습니다. 가장 알맞은 설명과 조치는 무엇일까요?',
         '`default:` 항목이 언제 쓰이는지, 즉 "이미 있는 것"과 "앞으로 생길 것" 중 어느 쪽에 작동하는지 생각해 보세요.',
         ['default ACL 은 이후에 새로 만들어지는 항목에만 물려준다. 기존 파일은 `setfacl -R -m u:lee:rwX /srv/proj` 처럼 직접 ACL 을 걸어야 한다', 'default ACL 은 폴더 소유자(root)가 만든 파일에는 적용되지 않는다', 'default ACL 은 재부팅 뒤에야 기존 파일까지 적용된다', '`chmod` 로 폴더 모드를 다시 지정하면 기존 파일에도 ACL 이 복사된다'], 0,
         'default ACL 은 폴더에 대한 "상속 규칙"이라 **새로 만들어지는** 파일·폴더가 만들어지는 순간 물려받습니다. 이미 있는 파일은 건드리지 않으므로 `-R -m` 으로 따로 걸어야 합니다. root 가 만든 파일에도 적용되고(앞 실습처럼), 재부팅이나 `chmod` 와는 무관합니다.')
# 7 -------------------------------------------------------------
b.nt('협업 폴더: 새 파일의 그룹이 폴더 그룹을 따르게 (setgid)', '`/srv/shared` 는 그룹 `dev` 가 쓰는 협업 폴더입니다(소유 그룹 dev, 모드 `770`, kim·lee 가 dev 멤버). 지금은 kim 이 파일을 만들면 파일의 그룹이 kim 의 기본 그룹(`kim`)이 되어, 같은 dev 멤버라도 그룹 권한으로 다루기 어렵습니다.\n\n폴더에 **setgid 비트**를 켜면 그 안에서 새로 만든 파일·폴더의 그룹이 **만든 사람의 그룹이 아니라 폴더의 그룹(dev)** 으로 상속됩니다. 폴더 모드가 `770` 인 상태를 유지하면서 setgid 를 켜세요. 켜지면 `ls -ld` 의 그룹 칸에 `x` 대신 `s` 가 보입니다.',
     '`chmod` 로 그룹에 `s` 를 더하는 기호 모드가 있습니다. 숫자 모드로 쓰려면 권한 세 자리 앞에 네 번째 자리가 붙습니다(setgid 는 그 자리의 값 하나).',
     "chmod g+s /srv/shared      # 또는 chmod 2770 /srv/shared\nls -ld /srv/shared          # drwxrws--- 로 바뀐다\nsu kim -c 'touch /srv/shared/k.txt'; ls -l /srv/shared/k.txt   # 그룹이 dev",
     CLEAN + "\n" + USERS + "mkdir /srv/shared; chgrp dev /srv/shared; chmod 770 /srv/shared\n",
     [chk('폴더 모드가 2770 이다', '[ "$(stat -c %a /srv/shared)" = 2770 ]'),
      chk('kim 이 만든 파일의 그룹이 dev 다', 'su kim -c "touch /srv/shared/k.txt"; g=$(stat -c %G /srv/shared/k.txt); rm -f /srv/shared/k.txt; [ "$g" = dev ]')])
# 8 -------------------------------------------------------------
b.choice('권한 문자열의 대문자 S', '`chmod 2740 /srv/shared` 로 설정한 뒤 `ls -ld` 를 하니 `drwxr-S---` 로 보입니다. (`2770` 이었다면 `drwxrws---`) 소문자 `s` 가 아니라 **대문자 `S`** 가 보이는 이유는 무엇일까요?',
         '`2740` 에서 그룹 자리의 숫자(4)가 어떤 권한 조합인지 풀어 보세요.',
         ['setgid 는 켜져 있지만 그룹에 실행(x) 권한이 없어서 대문자로 표시한다', 'setgid 가 꺼져 있어 S 로 표시한다', 'S 는 sticky 비트를 뜻한다', 'S 는 sticky 와 setuid 가 함께 켜졌다는 뜻이다'], 0,
         '특수 비트는 해당 칸의 x 자리에 겹쳐 표시됩니다. x 가 **있으면 소문자** `s`(`t`), **없으면 대문자** `S`(`T`)입니다. `2740` 의 그룹 권한 `4`는 `r--` 라 x 가 없어 `S` 로 나옵니다. setgid 자체는 켜져 있습니다. 폴더에서 setgid 가 의미 있게 동작하려면 보통 그룹 x 도 필요하므로 `S` 는 점검 신호입니다. sticky 는 기타(others) 칸 끝의 `t` 로 보입니다.')
# 9 -------------------------------------------------------------
b.choice('setgid 만 켰는데 동료가 수정하지 못할 때', 'umask 가 022 인 환경에서 `/srv/shared` 에 setgid 를 켰습니다. (umask 는 새 파일을 만들 때 기본 권한에서 **빼는** 권한 값입니다. 022 면 파일은 644 로 만들어집니다.) kim 이 새 파일을 만들면 그룹은 dev 로 잘 상속됩니다. 그런데 같은 dev 멤버 lee 가 그 파일을 수정하려 하면 `Permission denied` 가 납니다. `ls -l` 은 `-rw-r--r-- 1 kim dev` 입니다. 원인과 해결로 가장 알맞은 것은 무엇일까요?',
         '파일의 그룹은 dev 로 맞는데, 그 그룹에 부여된 권한 칸(가운데 세 글자)을 보세요. 새 파일의 기본 모드는 무엇이 정할까요?',
         ['새 파일의 기본 모드가 umask(022) 때문에 644 라 그룹에 쓰기 권한이 없다. 사용자 umask 를 002 로 하거나, 폴더에 그룹을 위한 default ACL(예: `setfacl -d -m g:dev:rwx`)을 건다', 'setgid 는 그룹 쓰기 권한을 막는 비트라서 꺼야 한다', 'lee 를 폴더 소유자로 바꾸면 모든 새 파일을 쓸 수 있다', '파일을 한 번 `chmod 777` 로 열면 앞으로 만들 파일에도 적용된다'], 0,
         'setgid 는 새 파일의 **그룹**만 폴더 그룹으로 정하고, **권한 비트**는 만든 사람의 umask(보통 022 → 파일 644)가 정합니다. 그래서 그룹에는 쓰기가 없습니다. 해법은 umask 를 002 로 바꾸는 것(사용자마다 설정해야 함)이나, 폴더에 default ACL 을 걸어 새 파일이 그룹 쓰기 권한을 물려받게 하는 것입니다. `chmod 777` 은 보안상 위험하고 기존 파일 한 개에만 적용됩니다.')
# 10 ------------------------------------------------------------
b.nt('남의 파일은 지우지 못하게: sticky 비트', '`/srv/drop` 은 누구나 파일을 올릴 수 있는 폴더(`777`)이고, 안에 kim 의 파일 `kim.txt` 가 있습니다. 폴더에 쓰기 권한이 있으면 **다른 사용자의 파일도 지울 수 있기** 때문에, 지금은 lee 가 kim 의 파일을 지울 수 있습니다.\n\n폴더에 **sticky 비트**를 켜서 "파일 소유자(와 root·폴더 소유자)만 그 파일을 지우거나 이름을 바꿀 수 있게" 하세요. 각자 자기 파일을 만들고 지우는 것은 계속 되어야 합니다. 켜지면 `ls -ld` 의 마지막 칸에 `t` 가 보입니다. (`/tmp` 가 `drwxrwxrwt` 인 이유와 같습니다.)',
     '`chmod` 기호 모드에는 sticky 를 뜻하는 글자가 있습니다. 바꾼 뒤 `ls -ld /srv/drop` 과 `ls -ld /tmp` 를 비교해 보세요.',
     "chmod +t /srv/drop     # 또는 chmod 1777 /srv/drop\nls -ld /srv/drop /tmp   # 둘 다 끝이 t\n# 이제 lee 가 kim.txt 를 지우려 하면 Operation not permitted",
     CLEAN + "\n" + USERS + "mkdir /srv/drop; chmod 777 /srv/drop; touch /srv/drop/kim.txt; chown kim:kim /srv/drop/kim.txt\n",
     [chk('폴더 마지막 칸이 t 다', '[ "$(stat -c %A /srv/drop | cut -c10)" = t ]'),
      chk('lee 가 kim 의 파일을 지우지 못한다', 'su lee -c "rm -f /srv/drop/kim.txt" 2>/dev/null; [ -e /srv/drop/kim.txt ]'),
      chk('lee 는 자기 파일을 만들고 지울 수 있다', 'su lee -c "touch /srv/drop/lee.txt && rm /srv/drop/lee.txt"')])
# 11 ------------------------------------------------------------
b.order('협업 폴더를 만드는 순서', '새 팀 협업 폴더 `/srv/team` 을 만들고 있습니다. 목표는 dev 그룹 멤버 kim 이 폴더에서 새 파일을 만들면 그 파일의 그룹이 dev 가 되도록 setgid 가 켜진 폴더입니다. 알맞은 순서로 카드를 놓으세요. (그룹을 준비하는 일[그룹 만들기 → 멤버 넣기]을 모두 끝낸 뒤 폴더를 만들고, 폴더에 그룹을 지정한 다음에 setgid 모드를 설정하며, 마지막에 결과를 확인합니다.)',
        '"무엇이 먼저 있어야 다음 명령이 성립하는가"를 따져 보세요. 확인은 마지막입니다.',
        ['`ls -ld /srv/team` 으로 결과를 확인한다', '`chmod 2770 /srv/team` 으로 setgid 모드를 설정한다', '`usermod -aG dev kim` 으로 kim 을 그룹에 넣는다', '`mkdir /srv/team` 으로 폴더를 만든다', '`groupadd dev` 로 그룹을 만든다', '`chgrp dev /srv/team` 으로 폴더의 그룹을 dev 로 지정한다'], [4, 2, 3, 5, 1, 0],
        '`groupadd` 로 그룹을 만들어야 `usermod -aG` 로 멤버를 넣을 수 있습니다. 폴더를 만든 뒤 `chgrp` 로 그룹을 dev 로 지정하고, `chmod 2770` 으로 setgid(2)와 소유자·그룹 전체 권한, 기타 없음(770)을 한 번에 설정합니다. 마지막에 `ls -ld` 로 `drwxrws---` 인지 확인합니다. (`-aG` 의 `-a` 를 빼면 kim 의 기존 보조 그룹이 모두 사라지니 주의합니다.)')
# 12 ------------------------------------------------------------
b.nt('합쳐서 쓰기: 안전한 팀 협업 폴더', '`/srv/team` 은 소유 그룹 dev, 모드 `770` 인 팀 폴더입니다(kim·lee 가 dev 멤버, `outsider` 는 아님). 다음을 모두 만족하도록 설정하세요.\n- 폴더 안에서 새로 만든 파일·폴더의 그룹이 항상 dev 가 된다 (setgid)\n- 한 멤버가 만든 새 파일을 다른 dev 멤버가 수정할 수 있다 (umask 에 상관없이 되도록 default ACL 로 해결)\n- dev 가 아닌 사용자는 읽을 수 없다\n\n끝나면 `getfacl /srv/team` 과 `ls -ld /srv/team` 으로 확인하세요.',
     '앞의 두 실습(setgid 켜기, default ACL 걸기)을 한 폴더에 함께 합니다. default ACL 의 대상은 사용자(`u:`)가 아니라 그룹입니다.',
     "chmod g+s /srv/team                     # 새 파일의 그룹이 dev 로 상속\nsetfacl -d -m g:dev:rwx /srv/team       # 새 파일에 dev 그룹의 읽기·쓰기를 물려줌\nls -ld /srv/team; getfacl /srv/team",
     CLEAN + "\n" + USERS + "mkdir /srv/team; chgrp dev /srv/team; chmod 770 /srv/team\n",
     [chk('폴더에 setgid 가 켜져 있다', '[ "$(stat -c %A /srv/team | cut -c7)" = s ]'),
      chk('폴더에 dev 그룹 default ACL 이 있다', 'getfacl -p /srv/team | grep -q "^default:group:dev:rw"'),
      chk('kim 이 만든 파일이 그룹 dev 이고 lee 가 쓸 수 있으며 outsider 는 읽을 수 없다', '( umask 022; su kim -c "touch /srv/team/n.txt"; g=$(stat -c %G /srv/team/n.txt); su lee -c "test -w /srv/team/n.txt"; r1=$?; su outsider -c "test -r /srv/team/n.txt"; r2=$?; rm -f /srv/team/n.txt; [ "$g" = dev ] && [ $r1 = 0 ] && [ $r2 != 0 ] )')])

if __name__ == '__main__':
    preview(b)
