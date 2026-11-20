import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 538: 패키지 관리 입문 dnf·rpm. 명세: docs/specs/spec_gap_set538.md
# 샌드박스는 인터넷이 막혀 있을 수 있다. 저장소가 필요한 명령(search·install·저장소의 info)은 읽기 문제로,
# 설치된 패키지만 다루는 rpm -q 와 dnf list/info installed/remove/history 는 실습으로 한다.

PRE = "rm -f /tmp/q*.txt\n"

b = SetBuilder(538, '패키지 관리 입문: dnf·rpm 으로 설치·조회·제거',
               'rpm 과 dnf 의 역할 차이를 익히고, 설치된 패키지의 정보(dnf info installed)·파일 소속(rpm -qf)·설정 파일(rpm -qc)을 조회합니다. 지우기 전에 함께 지워질 의존 패키지를 미리 보고(dnf remove --assumeno), 패키지를 제거하고, dnf history 로 이력을 확인합니다. 저장소가 필요한 search·install 은 읽기 문제로 다룹니다.',
               'linux-systemd', '리눅스', 58, 759, '📦',
               [{"title": "DNF 명령 레퍼런스", "url": "https://dnf.readthedocs.io/en/latest/command_ref.html"}, {"title": "rpm 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/rpm.8.html"}], 3)

# 1 ---------------------------------------------------------------
b.nt('dnf 로 설치된 패키지의 정보 보기', 'Rocky Linux 에서는 패키지를 **dnf**(저장소에서 받아 의존성까지 처리하는 도구)로 관리합니다. 먼저 이미 설치된 패키지 하나를 dnf 로 조회해 봅니다.\n\n`curl-minimal` 패키지의 **설치된 정보**(이름·버전·크기·요약 등)를 **`/tmp/q1.txt`** 에 저장하세요. (이 서버는 인터넷이 없어도 되는 명령으로, 이미 설치된 것만 봅니다.)',
     '`dnf info 패키지이름` 은 저장소에서 찾습니다. 이미 설치된 것만 보라고 알려 주는 단어를 앞에 붙이는 방법을 `dnf info --help` 나 `man dnf` 에서 찾아 보세요.',
     "dnf info installed curl-minimal > /tmp/q1.txt\ncat /tmp/q1.txt\n\n# installed 를 붙이면 저장소가 아닌, 이 서버에 설치된 패키지만 조회한다 (Repository 가 @로 시작)",
     PRE + "true",
     [chk('파일이 있다', '[ -s /tmp/q1.txt ]'), chk('curl-minimal 의 정보다', 'grep -Eq "^Name +: curl-minimal" /tmp/q1.txt'), chk('설치된 패키지 조회 결과다 (Repository @)', 'grep -Eq "^Repository +: @" /tmp/q1.txt')])
# 2 ---------------------------------------------------------------
b.choice('rpm 과 dnf 는 무엇이 다를까', '패키지를 다루는 명령에는 `rpm` 과 `dnf` 가 있습니다. 두 도구의 관계를 가장 알맞게 설명한 것은 무엇일까요?',
         '`rpm` 은 패키지 파일 하나와 설치 기록을 직접 다루는 낮은 층, `dnf` 는 저장소와 의존성을 다루는 높은 층입니다.',
         ['`rpm` 은 패키지 파일 하나와 설치 기록을 직접 다루고, `dnf` 는 저장소에서 패키지를 찾아 필요한 의존 패키지까지 함께 설치·제거한다', '`rpm` 은 조회만 되고 설치는 할 수 없으며, 설치는 반드시 `dnf` 로만 한다', '`dnf` 는 `rpm` 과 전혀 관계없는 별도의 패키지 형식을 쓴다', '`rpm` 은 Rocky Linux 용이고 `dnf` 는 Ubuntu 용이다'], 0,
         '`rpm` 은 `.rpm` 파일과 설치된 패키지 기록(rpm 데이터베이스)을 직접 다루는 기본 도구라 `rpm -qa`, `rpm -qf` 같은 조회에 많이 씁니다. `dnf` 는 그 위에서 저장소(repository)를 검색하고 의존 패키지를 계산해 함께 설치·제거해 주며, 실제 설치 작업은 내부에서 rpm 으로 합니다. `rpm -i` 로 파일을 직접 설치할 수도 있지만 의존성은 알아서 해결해 주지 않습니다. Ubuntu 계열의 대응 도구는 `dpkg` 와 `apt` 입니다.')
# 3 ---------------------------------------------------------------
b.nt('이 파일은 어느 패키지가 줬을까', '서버에 있는 `/usr/bin/curl` 명령이 **어느 패키지에서 왔는지** 알아야 할 때가 있습니다. 패키지 이름이 명령 이름과 다를 수 있기 때문입니다.\n\n`/usr/bin/curl` 을 설치한 패키지의 이름(버전 포함)을 **`/tmp/q3.txt`** 에 저장하세요.',
     '`rpm -q` 에 "파일이 속한 패키지" 를 묻는 옵션(file 의 f)을 붙이고, 뒤에 파일의 전체 경로를 씁니다.',
     "rpm -qf /usr/bin/curl > /tmp/q3.txt\ncat /tmp/q3.txt\n\n# -q(질의) + f(file): 이 파일을 설치한 패키지. 결과는 curl 이 아니라 curl-minimal-버전...",
     PRE + "true",
     [chk('파일이 있다', '[ -s /tmp/q3.txt ]'), chk('curl-minimal 패키지가 적혀 있다', 'grep -Eq "^curl-minimal-[0-9]" /tmp/q3.txt')])
# 4 ---------------------------------------------------------------
b.nt('패키지가 둔 설정 파일 찾기', '서버 설정을 바꾸려면 어느 파일이 설정 파일인지 알아야 합니다. 패키지는 자신이 설치한 파일 중 **설정 파일(config)** 을 따로 표시해 둡니다.\n\n`openssl-libs` 패키지가 설치한 **설정 파일만** 보여 줘서 **`/tmp/q4.txt`** 에 저장하세요. (패키지의 모든 파일이 아니라 설정 파일만 나와야 합니다.)',
     '`rpm -q` 에 이 패키지의 파일을 나열하는 옵션이 여러 개 있습니다. 전체 파일(l)이 아니라 설정 파일(config)만 고르는 옵션이 따로 있습니다. `rpm --help | grep -i config` 로 찾을 수 있습니다.',
     "rpm -qc openssl-libs > /tmp/q4.txt\ncat /tmp/q4.txt\n\n# -qc: 설정 파일만(c = config), -ql: 모든 파일(l = list). /etc/pki/tls/openssl.cnf 같은 파일이 나온다",
     PRE + "true",
     [chk('파일이 있다', '[ -s /tmp/q4.txt ]'), chk('openssl.cnf 가 있다', 'grep -qx /etc/pki/tls/openssl.cnf /tmp/q4.txt'), chk('설정 파일만 있다 (/usr 아래 파일 없음)', '! grep -q "^/usr" /tmp/q4.txt')])
# 5 ---------------------------------------------------------------
b.choice('설치할 패키지 이름을 모를 때', '웹 서버를 설치해야 하는데, 패키지의 정확한 이름을 모릅니다. (저장소에 닿을 수 있는 서버라고 합시다. 이 실습 서버는 인터넷이 막혀 있을 수 있어 읽기 문제로 풉니다.)\n\n이름을 찾는 가장 알맞은 첫 단계는 무엇일까요?',
         '`dnf search` 는 이름과 요약 설명에서 키워드를 찾습니다. `info` 는 이름을 알 때 상세 정보를 봅니다.',
         ['`dnf search "web server"` 로 이름·요약에 키워드가 들어간 패키지를 찾는다', '`dnf info web server` 로 정보를 본다', '`dnf remove web server` 로 먼저 지워 본다', '`rpm -qa web server` 로 저장소의 패키지를 찾는다'], 0,
         '이름을 모를 때는 키워드로 검색하는 `dnf search 키워드` 가 시작입니다. 이름과 요약 설명에서 찾아 후보 목록(예: `nginx.x86_64 : A high performance web server ...`)을 보여 줍니다. 이름이 정해지면 `dnf info 이름` 으로 버전·크기·설명을 본 뒤 `dnf install 이름` 으로 설치합니다. `dnf info` 는 정확한 이름이 필요하고, `rpm -qa` 는 이미 설치된 것만 보여 주며 저장소는 보지 않습니다. `remove` 는 설치된 것을 지우는 명령입니다.')
# 6 ---------------------------------------------------------------
b.fill('설치와 제거 명령', '`dnf` 하위 명령입니다. 빈칸을 채우세요. (`-y` 는 "계속할까요?" 질문에 자동으로 yes 로 답하는 옵션입니다.)\n- 저장소에서 받아 설치하기\n- 설치된 패키지 지우기',
       '하위 명령은 영어 동사 한 단어입니다. `search`·`info`·`list` 는 조회만 하는 명령이니 이 셋이 아닌, 설치와 제거를 뜻하는 동사를 고르세요.',
       'dnf {0} -y nginx\ndnf {1} -y nginx', ['install', 'remove', 'search', 'info', 'list'], [0, 1],
       '`dnf install 이름` 은 저장소에서 패키지와 필요한 의존 패키지를 받아 설치하고, `dnf remove 이름` 은 설치된 패키지를 지웁니다. `-y` 는 확인 질문에 자동으로 yes 로 답합니다. 연습이나 스크립트에서는 편하지만, 운영 서버에서는 무엇이 설치·제거되는지 목록을 읽은 뒤 쓰는 것이 안전합니다. `search`·`info`·`list` 는 상태를 바꾸지 않는 조회 명령입니다.')
# 7 ---------------------------------------------------------------
b.nt('지우기 전에 함께 지워질 것 미리 보기', '`dejavu-sans-fonts`(글꼴 패키지)를 지우려고 합니다. 그런데 이 패키지를 필요로 하는 다른 패키지가 있으면 **함께 지워질 수 있습니다.** 실제로 지우기 전에 목록만 미리 보는 것이 안전합니다.\n\n`dnf remove` 로 지울 때 **어떤 패키지가 함께 지워지는지 보여 주되 실제로는 지우지 않는** 방법으로 출력을 **`/tmp/q7.txt`** 에 저장하세요. 끝난 뒤에도 `dejavu-sans-fonts` 는 설치된 채여야 합니다.',
     '`dnf remove` 의 질문("Is this ok [y/N]")에 자동으로 no 라고 답하게 하는 옵션이 있습니다 (`-y` 의 반대). 출력은 `>` 로 저장합니다. 이 명령은 종료 코드가 0 이 아니어도 괜찮습니다.',
     "dnf remove --assumeno dejavu-sans-fonts > /tmp/q7.txt 2>&1\ncat /tmp/q7.txt\nrpm -q dejavu-sans-fonts\n\n# --assumeno: 모든 질문에 no. 'Removing dependent packages' 아래가 함께 지워질 패키지. 'Operation aborted.' 로 끝나 실제 변경은 없다",
     PRE + "true",
     [chk('결과가 저장돼 있다', '[ -s /tmp/q7.txt ]'), chk('함께 지워질 의존 패키지 목록이 있다', 'grep -q "Removing dependent packages" /tmp/q7.txt'), chk('중단되어 실제 제거는 하지 않았다', 'grep -q "Operation aborted" /tmp/q7.txt'), chk('dejavu-sans-fonts 는 그대로 설치돼 있다', 'rpm -q dejavu-sans-fonts >/dev/null')])
# 8 ---------------------------------------------------------------
b.choice('Failed to download metadata 가 나왔다면', '서버에서 `dnf search nginx` 를 했더니 이런 오류가 나왔습니다.\n\n```\nErrors during downloading metadata for repository \'baseos\':\n  - Curl error (6): Couldn\'t resolve host name for https://mirrors.example.com/... [Could not resolve host]\nError: Failed to download metadata for repo \'baseos\'\n```\n\n이 메시지가 뜻하는 것으로 가장 알맞은 것은 무엇일까요?',
         '"Could not resolve host" 는 이름(도메인)을 주소로 바꾸지 못했다는 뜻입니다. `metadata` 는 저장소가 가진 패키지 목록입니다.',
         ['저장소 서버에 연결하지 못해 패키지 목록(metadata)을 받지 못했다. 네트워크·DNS 를 확인한다. 이미 설치된 패키지의 `rpm -q`·`dnf remove` 는 저장소가 필요 없어 계속 동작한다', 'rpm 데이터베이스가 망가져서 설치된 패키지를 알 수 없다', 'nginx 라는 패키지 이름이 틀렸다', 'root 권한이 없어서 검색을 못 한다'], 0,
         '`metadata` 는 저장소가 제공하는 패키지 목록과 의존성 정보이고, 검색·설치·저장소 기준의 `info` 는 이것을 받아야 합니다. `Could not resolve host` 는 저장소 주소의 도메인을 IP 로 바꾸지 못했다는 뜻이라 DNS·인터넷 연결·프록시 설정을 확인하면 됩니다. 이미 설치된 패키지를 조회하는 `rpm -q`, `dnf list installed`, `dnf info installed`, 제거하는 `dnf remove`, 이력 `dnf history` 는 저장소가 필요 없어 오프라인에서도 동작합니다. 패키지 이름이 틀리면 `No match for argument` 가 나옵니다.')
# 9 ---------------------------------------------------------------
b.nt('패키지 제거하기', '`which` 패키지(명령의 위치를 찾아 주는 `which` 명령을 제공)는 이 서버에서 더 이상 필요 없다고 합니다. dnf 로 **`which` 패키지를 제거**하세요. 제거 중 나오는 확인 질문에는 자동으로 yes 로 답하게 합니다.\n\n다른 패키지(`bash` 등)는 지워지면 안 됩니다.',
     '제거 하위 명령 `remove` 에 패키지 이름을 쓰고, 확인 질문을 자동으로 yes 로 넘기는 옵션을 붙입니다. 패키지가 지워졌는지는 `rpm -q which` 로 확인합니다.',
     "dnf remove -y which\nrpm -q which\n\n# 설치한 패키지가 없으면 rpm -q 는 'package which is not installed' 라고 답한다",
     PRE + "true",
     [chk('which 패키지가 제거되었다', '! rpm -q which >/dev/null 2>&1'), chk('which 파일도 사라졌다', '[ ! -e /usr/bin/which ]'), chk('bash 는 그대로 있다', 'rpm -q bash >/dev/null')])
# 10 --------------------------------------------------------------
b.nt('누가 무엇을 지웠는지: dnf history', '동료가 서버에서 `vim-minimal` 패키지를 지웠다고 합니다. 언제, 어떤 명령으로, 무엇이 지워졌는지는 dnf 가 **이력(history)** 으로 남겨 둡니다.\n\n`dnf history` 로 `vim-minimal` 을 지운 **트랜잭션**을 찾아 그 **상세 정보**를 **`/tmp/q10.txt`** 에 저장하세요. (트랜잭션은 dnf 가 한 번에 처리한 작업 묶음이고, 번호(ID)가 붙습니다.)',
     '`dnf history` (또는 `dnf history list`) 로 목록을 보면 Command line 과 Action(s) 열이 있습니다. 지운 작업의 ID 를 찾아 `dnf history info ID` 로 상세를 봅니다.',
     "dnf history list\nID=$(dnf history list | awk '/remove/{print $1; exit}')\ndnf history info $ID > /tmp/q10.txt\ncat /tmp/q10.txt\n\n# list 는 ID·명령·시각·작업을 요약, info ID 는 Packages Altered 에 Removed vim-minimal... 처럼 무엇이 바뀌었는지 보여 준다",
     PRE + "dnf remove -y vim-minimal >/dev/null 2>&1; true",
     [chk('파일이 있다', '[ -s /tmp/q10.txt ]'), chk('트랜잭션 상세(Transaction ID)다', 'grep -q "^Transaction ID" /tmp/q10.txt'), chk('vim-minimal 제거가 적혀 있다', 'grep -Eq "Removed +vim-minimal" /tmp/q10.txt')])
# 11 --------------------------------------------------------------
b.order('패키지를 안전하게 지우는 순서', '운영 서버에서 패키지 하나를 지우는 안전한 흐름입니다. 카드를 알맞은 순서로 놓으세요. (먼저 대상이 설치돼 있는지부터 확인합니다)',
        '\'조회만 하는 단계\'와 \'실제로 바꾸는 단계\'로 나눠 보세요. 바꾸기 전에 해야 할 것들이 앞에 옵니다.',
        ['`dnf remove -y 패키지` 로 실제로 제거한다', '`rpm -q 패키지` 로 설치돼 있는지 확인한다', '`rpm -q 패키지` 로 사라졌는지, `dnf history` 로 기록이 남았는지 확인한다', '`dnf remove --assumeno 패키지` 로 함께 지워질 목록을 미리 본다', '미리 본 목록을 읽고 꼭 필요한 패키지가 섞여 있지 않은지 판단한다'], [1, 3, 4, 0, 2],
        '먼저 `rpm -q` 로 지울 패키지가 정말 있는지 확인하고, `--assumeno` 로 함께 지워질 의존 패키지 목록을 미리 봅니다. 목록을 읽고 필수 패키지가 섞여 있으면(예: dnf 자체) 진행하지 않습니다. 문제가 없을 때만 `dnf remove -y` 로 제거하고, 마지막에 `rpm -q` 와 `dnf history` 로 결과와 기록을 확인합니다. 미리보기 없이 `-y` 부터 쓰면 필요한 패키지까지 지울 수 있습니다.')

if __name__ == '__main__':
    preview(b)
