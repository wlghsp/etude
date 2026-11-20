import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 515: 서비스가 뜨지 않을 때 상황집. 명세: docs/specs/spec_gap_set515.md

def UNIT(name, body, extra_unit=''):
    return f"cat > /etc/systemd/system/{name}.service <<'EOF'\n[Unit]\nDescription={name}{extra_unit}\n\n[Service]\n{body}\nEOF\n"

RELOAD = "systemctl daemon-reload\n"
OK = lambda n: f'[ "$(systemctl is-active {n})" = active ]'

b = SetBuilder(515, '서비스가 뜨지 않을 때 상황집: 203/EXEC, 환경 파일, 포트 충돌, 권한, 의존 실패',
               '서비스가 Failed to start 로 실패한 상황을 직접 재현해 놓고 고칩니다. systemctl status 와 journalctl -xeu 로 원인을 찾아 실행 파일 경로·실행 권한·환경 파일·포트 충돌·없는 계정·디렉터리 권한·의존 서비스 실패를 하나씩 해결합니다.',
               'linux-systemd', '리눅스', 4, 736, '🚑',
               [{"title": "systemd.exec: 종료 상태(203/EXEC 등)", "url": "https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Process%20Exit%20Codes"}, {"title": "journalctl 매뉴얼", "url": "https://www.freedesktop.org/software/systemd/man/latest/journalctl.html"}], 5)

# 1 ---------------------------------------------------------------
b.nt('실패한 서비스의 상태와 종료 코드 읽기', '`crashy1` 서비스를 시작했더니 `Failed to start` 로 실패했습니다. 서비스가 왜 안 떴는지 알아보는 첫 단계는 현재 상태와 **종료 코드**를 보는 것입니다.\n\n`crashy1` 의 상태 출력을 **`/tmp/q1.txt`** 에 저장하세요. (이 문제는 고치지 않고, 실패한 상태를 읽는 연습입니다.)',
     '서비스 하나의 현재 상태·종료 코드·최근 로그 몇 줄을 한 번에 보여 주는 `systemctl` 하위 명령이 있습니다. 실패 상태이면 종료 코드가 0 이 아니어도 `>` 로 저장할 수 있고, 페이저는 `--no-pager` 로 끕니다.',
     "systemctl status crashy1 --no-pager > /tmp/q1.txt\ncat /tmp/q1.txt\n\n# Active: failed 와 (code=exited, status=203/EXEC) 가 보인다. 203/EXEC 는 실행 파일을 실행하지 못했다는 뜻",
     CLEAN + "\n" + UNIT('crashy1', 'ExecStart=/usr/bin/slepp 3600') + RELOAD + "systemctl start crashy1 2>/dev/null; true",
     [chk('파일이 있다', '[ -s /tmp/q1.txt ]'), chk('failed 상태가 적혀 있다', 'grep -q "Active: failed" /tmp/q1.txt'), chk('종료 코드 203/EXEC 가 적혀 있다', 'grep -q "203/EXEC" /tmp/q1.txt')])
# 2 ---------------------------------------------------------------
b.choice('status=203/EXEC 는 무슨 뜻일까', '서비스가 `(code=exited, status=203/EXEC)` 로 실패했습니다. 이 종료 상태가 가리키는 문제로 가장 알맞은 것은 무엇일까요?',
         '`EXEC` 는 systemd 가 `ExecStart=` 의 프로그램을 실행하려는 단계를 말합니다.',
         ['`ExecStart=` 의 프로그램을 실행하지 못했다 (경로 오타, 파일 없음, 실행 권한 없음 등)', '프로그램은 실행됐지만 설정이 틀려 스스로 종료했다', '이미 다른 프로세스가 같은 포트를 쓰고 있다', '서비스가 메모리 부족으로 강제 종료됐다'], 0,
         '`203/EXEC` 는 프로그램이 돌기 전, systemd 가 `ExecStart=` 의 파일을 실행(exec)하는 단계에서 실패했다는 뜻입니다. 대표 원인은 경로 오타·파일 없음·실행 권한(`x`) 없음·스크립트의 `#!` 인터프리터 경로 오류입니다. 프로그램이 일단 실행된 뒤 스스로 끝낸 경우는 `status=1/FAILURE` 처럼 프로그램이 정한 종료 코드로 나타납니다.')
# 3 ---------------------------------------------------------------
b.nt('실행 파일 경로가 틀렸을 때', '`hello3` 서비스가 시작되지 않습니다. 상태에는 `203/EXEC` 가 보입니다. 로그에서 **어떤 파일을 못 찾았다고 하는지** 확인하고, 실제 있는 프로그램을 가리키도록 고쳐서 `hello3` 가 **active** 가 되게 하세요.\n\n(유닛 파일은 `/etc/systemd/system/hello3.service` 입니다. 실행 파일은 `/usr/local/bin` 아래에 있습니다.)',
     '`journalctl -xeu hello3` 에서 `Failed to locate executable` 줄의 경로를 보고, `ls /usr/local/bin` 의 실제 이름과 비교하세요. 유닛을 고친 뒤에는 systemd 에 알려야 반영됩니다.',
     "sed -i 's#/usr/local/bin/hello-srv#/usr/local/bin/hello_srv#' /etc/systemd/system/hello3.service\nsystemctl daemon-reload\nsystemctl restart hello3\nsystemctl is-active hello3\n\n# 로그의 Failed to locate executable /usr/local/bin/hello-srv 와 실제 파일명(hello_srv)을 비교해 오타를 고친다",
     CLEAN + "\nprintf '#!/bin/sh\\nexec sleep 3600\\n' > /usr/local/bin/hello_srv; chmod 755 /usr/local/bin/hello_srv\n" + UNIT('hello3', 'ExecStart=/usr/local/bin/hello-srv') + RELOAD + "systemctl start hello3 2>/dev/null; true",
     [chk('hello3 가 active 다', OK('hello3')), chk('유닛이 실제 있는 파일을 가리킨다', 'f=$(systemctl show -p ExecStart --value hello3 | sed "s/.*path=\\([^ ;]*\\).*/\\1/"); [ -x "$f" ]')])
# 4 ---------------------------------------------------------------
b.nt('파일은 있는데 실행 권한이 없을 때', '`perm4` 서비스는 `/opt/perm4/run.sh` 스크립트를 실행합니다. 파일은 분명히 있는데도 시작되지 않고 `203/EXEC` 로 실패합니다. 로그의 원인 문장을 확인하고 **유닛 파일은 그대로 둔 채** 원인을 고쳐 `perm4` 가 **active** 가 되게 하세요.',
     '로그 끝의 `No such file` 인지 `Permission denied` 인지가 갈림길입니다. 파일 권한은 `ls -l` 로 확인하고, 파일의 실행 권한 비트를 켜 줍니다. 유닛 파일은 안 고쳤으니 `daemon-reload` 는 필요 없지만 다시 시작은 해야 합니다.',
     "chmod +x /opt/perm4/run.sh\nsystemctl restart perm4\nsystemctl is-active perm4\n\n# 로그의 Permission denied: 파일이 있어도 x 비트가 없으면 exec 가 거부된다",
     CLEAN + "\nmkdir -p /opt/perm4; printf '#!/bin/sh\\nexec sleep 3600\\n' > /opt/perm4/run.sh; chmod 644 /opt/perm4/run.sh\n" + UNIT('perm4', 'ExecStart=/opt/perm4/run.sh') + RELOAD + "systemctl start perm4 2>/dev/null; true",
     [chk('perm4 가 active 다', OK('perm4')), chk('유닛 파일은 그대로다', 'grep -q "^ExecStart=/opt/perm4/run.sh$" /etc/systemd/system/perm4.service'), chk('스크립트에 실행 권한이 있다', '[ -x /opt/perm4/run.sh ]')])
# 5 ---------------------------------------------------------------
b.nt('환경 파일이 없을 때', '`envfail5` 서비스는 `EnvironmentFile=` 로 설정 파일을 읽도록 되어 있는데 시작되지 않습니다. 상태에는 이번에는 `203/EXEC` 같은 종료 코드가 없고 `Result: resources` 가 보입니다.\n\n로그가 말하는 **없는 파일**을 만들고, 그 안에 **`APP_PORT=9090`** 한 줄을 적어 서비스가 **active** 가 되게 하세요. (서비스는 `APP_PORT` 값을 `/tmp/port5.out` 에 기록합니다.)',
     '`journalctl -xeu envfail5` 에 `Failed to load environment files` 가 있습니다. 어떤 파일인지는 로그가 아니라 유닛 내용(`systemctl cat envfail5`)에서 읽습니다. 환경 파일은 `KEY=값` 형식입니다.',
     "echo 'APP_PORT=9090' > /etc/envfail5.env\nsystemctl restart envfail5\nsleep 1; cat /tmp/port5.out\n\n# 프로그램이 실행되기도 전에 환경 파일을 못 읽어 실패했다. 파일을 만들고 다시 시작하면 된다",
     CLEAN + "\nrm -f /etc/envfail5.env /tmp/port5.out\n" + UNIT('envfail5', "EnvironmentFile=/etc/envfail5.env\nExecStart=/bin/sh -c 'echo \"port=$APP_PORT\" > /tmp/port5.out; sleep 3600'") + RELOAD + "systemctl start envfail5 2>/dev/null; true",
     [chk('envfail5 가 active 다', OK('envfail5')), chk('서비스가 9090 을 읽었다', 'grep -qx port=9090 /tmp/port5.out')])
# 6 ---------------------------------------------------------------
b.nt('포트가 이미 사용 중일 때', '`web6` 서비스는 `8081` 포트로 간단한 웹 서버를 띄우는데 `Address already in use` 로 실패합니다. 이미 같은 포트를 쓰는 다른 서비스 `old6` 가 돌고 있고, **`old6` 는 끄면 안 됩니다.**\n\n`web6` 가 **`8082`** 포트를 쓰도록 유닛 파일(`/etc/systemd/system/web6.service`)을 고쳐 `web6` 도 **active** 가 되게 하세요. (`old6` 는 계속 8081 에서 응답해야 합니다.)',
     '`journalctl -xeu web6` 에서 `Address already in use` 를 확인하세요. 포트 번호는 유닛의 `ExecStart=` 줄 끝에 있습니다. 고친 뒤 systemd 에 알리고 다시 시작합니다.',
     "sed -i 's/8081/8082/' /etc/systemd/system/web6.service\nsystemctl daemon-reload\nsystemctl restart web6\nsleep 1; systemctl is-active web6 old6\n\n# 한 포트는 한 프로세스만 쓸 수 있다. 기존 서비스를 두고 새 서비스의 포트를 바꿨다",
     CLEAN + "\n" + UNIT('old6', 'ExecStart=/usr/bin/python3 -m http.server 8081 --bind 127.0.0.1') + UNIT('web6', 'ExecStart=/usr/bin/python3 -m http.server 8081 --bind 127.0.0.1') + RELOAD + "systemctl start old6; sleep 2; systemctl start web6 2>/dev/null; true",
     [chk('web6 가 active 다', OK('web6')), chk('old6 도 계속 active 다', OK('old6')),
      chk('web6 가 8082 에서 응답한다', 'python3 -c "import urllib.request as u; u.urlopen(\'http://127.0.0.1:8082\', timeout=3)"'),
      chk('old6 가 8081 에서 응답한다', 'python3 -c "import urllib.request as u; u.urlopen(\'http://127.0.0.1:8081\', timeout=3)"')])
# 7 ---------------------------------------------------------------
b.nt('서비스 계정이 없을 때', '`user7` 서비스는 보안을 위해 전용 계정 `appsvc7` 로 실행하도록(`User=appsvc7`) 되어 있는데 시작되지 않습니다. 이번 종료 상태는 `203` 이 아닌 `217/USER` 입니다.\n\n**유닛 파일은 그대로 두고** 시스템에 필요한 계정을 만들어 `user7` 이 **active** 가 되게 하세요. (로그인할 필요 없는 서비스용 계정이라 `-r` 로 만들고 셸은 `/sbin/nologin` 으로 합니다.)',
     '로그 `Failed to determine user credentials` 는 계정을 찾지 못했다는 뜻입니다. `getent passwd 계정명` 으로 있는지 확인하고, `useradd` 로 시스템 계정을 만든 뒤 다시 시작하세요.',
     "useradd -r -s /sbin/nologin appsvc7\nsystemctl restart user7\nsystemctl is-active user7\n\n# 217/USER 는 User= 의 계정을 찾지 못했다는 뜻. 계정을 만들면 유닛은 고칠 필요가 없다",
     CLEAN + "\nuserdel appsvc7 2>/dev/null\n" + UNIT('user7', 'User=appsvc7\nExecStart=/bin/sleep 3600') + RELOAD + "systemctl start user7 2>/dev/null; true",
     [chk('user7 가 active 다', OK('user7')), chk('유닛은 appsvc7 로 실행한다', '[ "$(systemctl show -p User --value user7)" = appsvc7 ]'), chk('계정이 있다', 'getent passwd appsvc7 >/dev/null')])
# 8 ---------------------------------------------------------------
b.nt('서비스 계정이 쓸 디렉터리에 권한이 없을 때', '`data8` 서비스는 `nobody` 계정으로 실행되며 `/var/lib/data8/state` 파일에 기록합니다. 시작하자마자 종료되며 로그에 `Permission denied` 가 보입니다.\n\n**`User=nobody` 는 그대로 두고**, 디렉터리 `/var/lib/data8` 의 **소유자를 `nobody` 로 바꿔** 서비스가 **active** 가 되고 `state` 파일에 `ok` 가 기록되게 하세요.',
     '`ls -ld /var/lib/data8` 로 지금 소유자와 권한을 확인하세요. 디렉터리 소유자를 바꾸는 명령을 쓰고, 서비스를 다시 시작합니다. 서비스를 `root` 로 바꾸는 방법은 이 문제의 답이 아닙니다.',
     "chown nobody /var/lib/data8\nsystemctl restart data8\nsleep 1; cat /var/lib/data8/state\n\n# 서비스 계정이 쓸 데이터 디렉터리는 그 계정 소유여야 한다. root 로 실행하게 바꾸면 보안이 약해진다",
     CLEAN + "\nrm -rf /var/lib/data8; mkdir -p /var/lib/data8; chown root:root /var/lib/data8; chmod 755 /var/lib/data8\n" + UNIT('data8', "User=nobody\nExecStart=/bin/sh -c 'echo ok > /var/lib/data8/state; exec sleep 3600'") + RELOAD + "systemctl start data8 2>/dev/null; true",
     [chk('data8 이 active 다', OK('data8')), chk('여전히 nobody 로 실행한다', '[ "$(systemctl show -p User --value data8)" = nobody ]'), chk('state 에 ok 가 있다', 'grep -qx ok /var/lib/data8/state')])
# 9 ---------------------------------------------------------------
b.nt('의존하는 서비스가 실패해서 못 뜰 때', '`front9` 는 `back9` 가 필요해서(`Requires=back9.service`) `front9` 를 시작하면 `Dependency failed` 로 실패합니다. 진짜 원인은 `front9` 가 아니라 **`back9` 쪽**에 있습니다.\n\n`back9` 의 로그에서 원인을 찾아 고치고 **`front9` 와 `back9` 가 모두 active** 가 되게 하세요. (두 유닛 파일은 고치지 않고, 필요한 파일을 만들면 됩니다.)',
     '실패 서비스 이름이 두 개일 때는 가장 아래 의존 대상부터 봅니다. `journalctl -xeu back9` 의 마지막 오류 문장이 필요한 파일의 이름을 알려 줍니다. 내용은 아무 문자열이나 괜찮습니다.',
     "echo 'mode=prod' > /etc/back9.conf\nsystemctl start front9\nsystemctl is-active front9 back9\n\n# front9 의 실패는 결과일 뿐. back9 가 없는 /etc/back9.conf 때문에 먼저 실패했다. 고친 뒤 front9 를 시작하면 back9 도 함께 뜬다",
     CLEAN + "\nrm -f /etc/back9.conf\n" + UNIT('back9', "ExecStart=/bin/sh -c 'cat /etc/back9.conf > /dev/null && exec sleep 3600'") + UNIT('front9', "ExecStart=/bin/sleep 3600", "\nRequires=back9.service\nAfter=back9.service") + RELOAD + "systemctl start front9 2>/dev/null; true",
     [chk('back9 가 active 다', OK('back9')), chk('front9 가 active 다', OK('front9')), chk('설정 파일이 있다', '[ -f /etc/back9.conf ]'), chk('front9 유닛은 그대로 back9 를 요구한다', 'systemctl show -p Requires --value front9 | grep -q back9.service')])
# 10 --------------------------------------------------------------
b.fill('실패 원인을 찾는 두 명령', '서비스가 `Failed to start` 로 실패했을 때 쓰는 명령입니다. 빈칸을 채우세요.\n- 첫째: 현재 상태와 종료 코드, 최근 로그 몇 줄을 한눈에 보기\n- 둘째: `web6` 서비스의 로그만 골라서 설명 문장까지 보기',
       '첫째는 유닛의 현재 상태를 요약해 주는 하위 명령, 둘째는 로그를 유닛 하나로 거르는 옵션입니다. `-f` 는 계속 따라 보기, `-k` 는 커널 메시지입니다.',
       'systemctl {0} web6\njournalctl -xe{1} web6', ['status', 'restart', 'u', 'f', 'k', 'enable'], [0, 2],
       '`systemctl status 유닛` 은 Active 상태, Main PID 와 종료 코드(`code=exited, status=...`), 최근 로그 몇 줄을 보여 줍니다. 더 자세한 로그는 `journalctl -xeu 유닛` 입니다. `-u` 가 유닛으로 거르기, `-e` 가 끝부분으로 이동, `-x` 가 오류 설명 덧붙이기입니다. `restart` 와 `enable` 은 상태를 바꾸는 명령이라 원인 조사 단계에 맞지 않습니다.')
# 11 --------------------------------------------------------------
b.order('서비스 장애 대응의 큰 흐름', '서비스가 안 뜰 때 원인을 찾아 해결하는 흐름입니다. 카드를 알맞은 순서로 놓으세요.',
        '문제를 눈으로 확인하는 단계, 원인을 좁히는 단계, 조치하는 단계, 적용하는 단계, 결과를 검증하는 단계로 나뉩니다. 유닛 파일을 고쳤을 때만 필요한 단계가 하나 있습니다.',
        ['원인에 맞게 실행 파일·설정 파일·유닛 파일을 고친다', '`systemctl restart` 로 서비스를 다시 시작한다', '`systemctl status` 로 active (running) 인지 다시 확인한다', '`journalctl -xeu` 로 오류 문장을 찾는다', '유닛 파일을 고쳤다면 `systemctl daemon-reload` 로 다시 읽게 한다', '`systemctl status` 로 실패 상태와 종료 코드를 확인한다'], [5, 3, 0, 4, 1, 2],
        '먼저 status 로 증상(실패 상태와 종료 코드)을 보고, journalctl 로 원인 문장을 찾습니다. 원인에 맞게 고친 뒤, 유닛 파일을 고쳤다면 daemon-reload 로 systemd 가 다시 읽게 하고 restart 로 적용합니다. 마지막에 status 로 정말 active 가 되었는지 확인해야 해결이 끝난 것입니다.')

if __name__ == '__main__':
    preview(b)
