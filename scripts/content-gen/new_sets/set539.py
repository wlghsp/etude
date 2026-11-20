import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 539 패키지 관리 입문: apt·dpkg 조회와 rpm·dnf 대응표. 명세: docs/specs/spec_gap_set539.md
# etude-linux 는 Ubuntu 22.04(root). 외부 네트워크 없이 동작하도록 dpkg 조회, 이미지에 있는 패키지, 직접 만든 .deb, file: 로컬 저장소만 쓴다.

# 518 과 같은 보조: .deb 를 만드는 셸 함수 mkdeb(이름 버전 저장할폴더)와 로컬 저장소 색인 스크립트
MK = r"""mkdeb() { d=/tmp/pk/$1_$2; mkdir -p $d/DEBIAN $d/usr/share/$1 $3; printf 'Package: %s\nVersion: %s\nArchitecture: all\nMaintainer: Lab <lab@example.com>\nDescription: lab package %s\n' $1 $2 $1 > $d/DEBIAN/control; echo $1 $2 > $d/usr/share/$1/version; dpkg-deb --build $d $3/$1_$2_all.deb >/dev/null; }
cat > /tmp/mkrepo.sh <<'X'
#!/bin/sh
cd /tmp/repo || exit 1
: > Packages
for f in *.deb; do
  dpkg-deb -f "$f" >> Packages
  printf 'Filename: ./%s\nSize: %s\nSHA256: %s\n\n' "$f" "$(stat -c%s "$f")" "$(sha256sum "$f" | cut -d' ' -f1)" >> Packages
done
{ echo 'Origin: Lab'; echo 'Suite: stable'; echo 'Date: Thu, 19 Nov 2026 00:00:00 UTC'; echo 'SHA256:'; printf ' %s %s Packages\n' "$(sha256sum Packages | cut -d' ' -f1)" "$(stat -c%s Packages)"; } > Release
X
chmod +x /tmp/mkrepo.sh
mkdir -p /tmp/repo
rm -f /etc/apt/sources.list.d/*; [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.orig
"""
INST = lambda p: f'[ "$(dpkg-query -W -f=\'${{db:Status-Status}}\' {p} 2>/dev/null)" = installed ]'
ONE = lambda f: f"\"$(tr -d '[:space:]' < {f} 2>/dev/null)\""

b = SetBuilder(539, '패키지 관리 입문: apt·dpkg 조회와 rpm·dnf 대응표',
               '패키지 관리의 기본 도구를 조회부터 익힙니다. dpkg -l/-s 로 설치 상태와 버전 보기, dpkg -S 로 파일이 어느 패키지 것인지 찾기, sources.list 읽기, apt-cache policy 로 설치 버전과 후보 버전 비교, dpkg-deb 로 직접 .deb 를 만들어 설치·완전 삭제하기를 인터넷 없이 실습하고, 잠금 파일의 의미와 Rocky 계열의 rpm·dnf 대응 명령까지 정리합니다.',
               'linux', '리눅스', 58, 760, '📦',
               [{"title": "dpkg 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man1/dpkg.1.html"}, {"title": "sources.list 매뉴얼", "url": "https://manpages.ubuntu.com/manpages/jammy/man5/sources.list.5.html"}, {"title": "dnf 명령 참고", "url": "https://dnf.readthedocs.io/en/latest/command_ref.html"}], 1)

# 1 dpkg -l / -s
b.nt('설치된 패키지의 버전 확인하기',
     '리눅스의 프로그램은 **패키지** 단위로 설치됩니다. Ubuntu 는 `dpkg` 가 "무엇이 설치되어 있는지"를 기록한 장부를 관리합니다. `dpkg -l 이름` 은 설치 목록을, `dpkg -s 이름` 은 한 패키지의 상세 정보(상태·버전 등)를 보여 줍니다. (네트워크가 필요 없는 조회 명령입니다.)\n\n이 서버에 설치된 **`bash`** 패키지의 버전을 찾아 `/tmp/bash_version.txt` 에 **버전 문자열만** 저장하세요.',
     '`dpkg -s bash` 출력에 `Version:` 으로 시작하는 줄이 있습니다. 그 줄에서 값만 골라 파일로 보냅니다.',
     "dpkg -l bash\ndpkg -s bash | grep '^Version'\ndpkg-query -W -f='${Version}' bash > /tmp/bash_version.txt\n\n# dpkg -l 의 ii 는 설치 완료 표시. 버전만 뽑을 땐 dpkg-query -W -f 가 편하다 (awk 로 -l 의 3번째 열을 써도 된다)",
     "rm -f /tmp/bash_version.txt",
     [chk('버전 문자열이 bash 의 설치 버전과 같다', f'[ {ONE("/tmp/bash_version.txt")} = "$(dpkg-query -W -f=\'${{Version}}\' bash)" ]')])

# 2 dpkg -S
b.nt('이 파일은 어느 패키지가 설치했나: dpkg -S',
     '`pgrep` 으로 프로세스를 찾다가 "이 명령은 어느 패키지에 들어 있지?" 궁금해졌습니다. 파일 경로에서 패키지를 거꾸로 찾는 명령이 `dpkg -S 경로` 입니다. 출력은 `패키지이름: 파일경로` 모양입니다.\n\n`/usr/bin/pgrep` 파일을 설치한 **패키지 이름만** 한 줄로 `/tmp/owner.txt` 에 저장하세요.',
     '`dpkg -S` 에 경로를 주면 `:` 앞이 패키지 이름입니다. `cut` 으로 그 부분만 잘라 보세요.',
     "dpkg -S /usr/bin/pgrep\ndpkg -S /usr/bin/pgrep | cut -d: -f1 > /tmp/owner.txt\n\n# 명령 위치가 궁금하면 which pgrep 으로 경로를 먼저 찾는다. 패키지가 안 준 파일(직접 만든 파일)은 no path found 라고 나온다",
     "rm -f /tmp/owner.txt",
     [chk('owner.txt 가 pgrep 파일을 준 패키지 이름이다', f'[ {ONE("/tmp/owner.txt")} = "$(dpkg -S /usr/bin/pgrep | cut -d: -f1)" ]')])

# 3 dpkg -l 상태 열
b.choice('dpkg -l 첫 열의 ii 와 rc',
         '`dpkg -l` 출력의 맨 앞 두 글자는 패키지의 상태입니다. (왼쪽부터 "원하는 상태", "현재 상태".)\n\n```\nii  bash        5.1-6ubuntu1.1  amd64  GNU Bourne Again SHell\nrc  oldtool     1.2-1           all    example old tool\n```\n\n`oldtool` 줄의 `rc` 는 무슨 뜻일까요?',
         '첫 글자는 \'원하는 상태\', 두 번째 글자는 \'지금 상태\'입니다. 두 글자가 각각 무엇을 줄인 것인지 `man dpkg` 의 `-l` 항목에서 찾아보세요.',
         ['프로그램은 제거됐지만 설정 파일은 남아 있다', '설치가 끝났고 정상이다', '설치 도중 멈춰 반쯤만 설치되었다', '저장소에서 새 버전이 나와 업그레이드 대기 중이다'], 0,
         '`rc` 는 remove 로 지웠지만 config-files(설정 파일)가 남은 상태입니다. 정상 설치는 `ii` 이고, 설정 도중 멈춘 상태는 `dpkg -s` 의 `half-configured` 로 보이며, 업그레이드 대기 정보는 `dpkg -l` 이 아니라 apt 의 목록에 있습니다. 설정 파일까지 지우려면 `--purge` 를 씁니다.')

# 4 sources.list 읽기
b.nt('저장소 목록 파일 읽기: sources.list',
     '`apt` 는 패키지를 **저장소**에서 받아 오고, 어떤 저장소를 쓸지는 `/etc/apt/sources.list`(와 `sources.list.d/` 폴더의 `.list` 파일)에 한 줄씩 적혀 있습니다. 한 줄은 `deb 주소 배포판이름 구성요소...` 모양이고, `#` 로 시작하면 주석(무시), `deb-src` 는 소스 코드 저장소입니다.\n\n연습용 사본 `/tmp/lab-sources.list` 를 읽고, **실제로 적용되는 `deb` 줄**(주석 아님, `deb-src` 아님)의 개수를 숫자만 `/tmp/deb_count.txt` 에 저장하세요.',
     '`cat` 으로 파일을 먼저 읽어 보세요. 줄 맨 앞이 정확히 `deb ` 로 시작하는 줄만 세면 됩니다 (`grep` 의 `^` 와 `-c`).',
     "cat /tmp/lab-sources.list\ngrep -c '^deb ' /tmp/lab-sources.list > /tmp/deb_count.txt\n\n# ^ 는 줄의 시작. '^deb ' 는 '# deb' 주석과 deb-src 를 모두 제외한다",
     "rm -f /tmp/deb_count.txt; printf '%s\\n' '# 연습용 저장소 목록 (example.com 은 예시 주소)' 'deb http://archive.example.com/ubuntu jammy main restricted' '# deb http://archive.example.com/ubuntu jammy universe' 'deb-src http://archive.example.com/ubuntu jammy main' 'deb http://archive.example.com/ubuntu jammy-updates main restricted' 'deb http://security.example.com/ubuntu jammy-security main' > /tmp/lab-sources.list",
     [chk('deb_count.txt 가 적용 중인 deb 줄 수와 같다', f'[ {ONE("/tmp/deb_count.txt")} = 3 ]')])

# 5 빈칸: 배포판 이름
b.fill('sources.list 줄의 배포판 이름', '이 서버는 Ubuntu **22.04 LTS** 입니다. 22.04 의 코드 이름(배포판 이름)을 넣어 저장소 줄을 완성하세요. (주소는 예시입니다. `cat /etc/os-release` 의 `VERSION_CODENAME` 에서 확인할 수 있습니다.)', '`.list` 의 세 번째 칸은 버전 번호가 아니라 코드 이름입니다. 20.04 는 focal 입니다.',
       'deb http://archive.example.com/ubuntu {0} main', ['jammy', 'focal', 'stable', 'ubuntu'], [0],
       '`jammy` 가 Ubuntu 22.04 의 코드 이름입니다. `focal` 은 20.04, `stable` 은 Debian 계열의 별칭이고 `ubuntu` 는 이미 주소에 들어 있는 이름입니다. 뒤의 `-updates`, `-security` 는 같은 배포판의 갱신·보안 패치 구역입니다.')

# 6 apt-cache policy
b.nt('설치 버전과 후보 버전: apt-cache policy',
     '`apt-cache policy 이름` 은 그 패키지의 **설치된 버전(Installed)** 과 앞으로 설치될 **후보 버전(Candidate)**, 그리고 어느 저장소에 어떤 버전이 있는지를 보여 줍니다. 저장소의 목록은 `apt-get update` 로 받아 둔 사본을 읽으므로, 조회 자체는 네트워크가 필요 없습니다. (이 서버에는 직접 만든 로컬 저장소 `file:/tmp/repo` 가 등록되어 있고 목록 갱신도 끝났습니다.)\n\n`hello-lab` 은 1.0 이 설치되어 있고 저장소에는 더 새 버전이 올라와 있습니다. **Candidate 로 표시되는 버전**을 `/tmp/candidate.txt` 에 저장하세요. (설치·업그레이드는 하지 마세요. 조회만 합니다.)',
     '`apt-cache policy hello-lab` 출력의 `Candidate:` 줄을 보세요. `grep` 과 `awk` 로 값만 뽑을 수 있습니다.',
     "apt-cache policy hello-lab\napt-cache policy hello-lab | awk '/Candidate:/ {print $2}' > /tmp/candidate.txt\n\n# Installed 와 Candidate 가 다르면 업그레이드할 수 있는 버전이 있다는 뜻이다. 이 명령은 목록만 읽고 아무것도 바꾸지 않는다",
     MK + "rm -f /tmp/candidate.txt; mkdeb hello-lab 1.0 /tmp/repo; /tmp/mkrepo.sh; echo 'deb [trusted=yes] file:/tmp/repo ./' > /etc/apt/sources.list.d/lab.list; apt-get update >/dev/null 2>&1; apt-get install -y hello-lab >/dev/null 2>&1; mkdeb hello-lab 2.0 /tmp/repo; /tmp/mkrepo.sh; apt-get update >/dev/null 2>&1",
     [chk('candidate.txt 가 후보 버전(2.0)이다', f'[ {ONE("/tmp/candidate.txt")} = 2.0 ]'),
      chk('hello-lab 은 아직 1.0 이다 (조회만 했다)', '[ "$(dpkg-query -W -f=\'${Version}\' hello-lab)" = 1.0 ]')])

# 7 순서: .deb 만들어 설치
b.order('.deb 패키지를 직접 만들어 설치하는 순서', '파일 구조를 갖춘 폴더에서 `.deb` 를 만들어 설치하고 확인하는 흐름입니다. 올바른 순서로 놓으세요. (폴더 안에 프로그램 파일을 먼저 두었다고 가정합니다.)', '설치할 파일(.deb)이 어떻게 만들어지는지, 그리고 확인은 언제 가능한지 생각해 보세요.',
        ['`dpkg -i` 로 만든 .deb 를 설치한다', '`dpkg -s` 로 설치 상태를 확인한다', '`DEBIAN/control` 파일에 이름·버전 등 패키지 정보를 적는다', '`dpkg-deb --build` 로 폴더를 .deb 로 포장한다'], [2, 3, 0, 1],
        '`.deb` 는 파일들이 놓일 경로 구조(예: `usr/local/bin/...`)와 `DEBIAN/control`(패키지 이름·버전·설명) 로 이루어집니다. control 을 먼저 적어야 `dpkg-deb --build` 로 포장할 수 있고, 포장된 .deb 를 `dpkg -i` 로 설치한 뒤 `dpkg -s` 로 상태가 `install ok installed` 인지 확인합니다.')

# 8 dpkg-deb 로 만들고 설치
b.nt('내가 만든 .deb 포장하고 설치하기',
     '배포용 패키지를 만들어 보겠습니다. `/tmp/work/hello-etude/` 폴더에 패키지 정보 `DEBIAN/control` 과 설치될 프로그램 `usr/local/bin/hello-etude` 가 이미 준비되어 있습니다. `dpkg-deb --build 폴더 [출력경로]` 는 폴더를 `.deb` 파일 하나로 포장하고, `dpkg -i 파일.deb` 는 그 파일을 설치합니다. (저장소 없이 파일 하나를 설치하므로 네트워크가 필요 없습니다.)\n\n이 폴더를 `/tmp/work/hello-etude.deb` 로 포장해 설치하고, `hello-etude` 명령이 실행되게 하세요.',
     '폴더 구조는 `find /tmp/work/hello-etude` 로 볼 수 있습니다. 포장 → 설치 두 단계이며, 설치 뒤 `dpkg -S /usr/local/bin/hello-etude` 로 방금 설치한 패키지가 파일의 주인으로 나오는지 확인해 보세요.',
     "find /tmp/work/hello-etude -type f\ncat /tmp/work/hello-etude/DEBIAN/control\ndpkg-deb --build /tmp/work/hello-etude /tmp/work/hello-etude.deb\ndpkg -i /tmp/work/hello-etude.deb\nhello-etude\ndpkg -S /usr/local/bin/hello-etude\n\n# DEBIAN/ 폴더는 패키지 정보용이고, 나머지 경로가 그대로 시스템의 / 아래로 설치된다",
     "dpkg --purge hello-etude >/dev/null 2>&1; rm -rf /tmp/work; mkdir -p /tmp/work/hello-etude/DEBIAN /tmp/work/hello-etude/usr/local/bin; printf 'Package: hello-etude\\nVersion: 1.0\\nArchitecture: all\\nMaintainer: Lab <lab@example.com>\\nDescription: etude hello tool\\n' > /tmp/work/hello-etude/DEBIAN/control; printf '#!/bin/sh\\necho hello from etude\\n' > /tmp/work/hello-etude/usr/local/bin/hello-etude; chmod 755 /tmp/work/hello-etude/usr/local/bin/hello-etude",
     [chk('hello-etude 패키지가 설치 상태다', INST('hello-etude')),
      chk('hello-etude 명령이 실행된다', '/usr/local/bin/hello-etude | grep -q etude')])

# 9 purge
b.nt('패키지 완전 삭제: remove 와 purge',
     '`conf-lab` 패키지가 설치되어 있고, 설정 파일 `/etc/conf-lab.conf` 가 함께 들어 있습니다. 이제 필요 없어 **프로그램과 설정 파일까지 모두** 지우려 합니다.\n\n`dpkg -r 이름`(`--remove`)은 프로그램만 지우고 **설정 파일은 남겨 둡니다**(그래서 `dpkg -l` 에 `rc` 로 남습니다). 설정까지 지우는 옵션은 따로 있습니다. `conf-lab` 을 완전히 삭제해 `/etc/conf-lab.conf` 도 없어지게 하세요.',
     '`dpkg --help` 나 `man dpkg` 에서 설정 파일(conffile)까지 지우는 동작을 찾아 보세요. 끝난 뒤 `dpkg -l conf-lab` 도 확인합니다.',
     "dpkg -l conf-lab\nls /etc/conf-lab.conf\ndpkg --purge conf-lab\nls /etc/conf-lab.conf\ndpkg -l conf-lab\n\n# -r 로만 지우면 설정 파일이 남아 상태가 rc 가 된다. --purge (-P) 는 설정 파일까지 지운다. 설정을 다시 쓸 일이 있으면 remove 만 하는 편이 안전하다",
     "dpkg --purge conf-lab >/dev/null 2>&1; rm -rf /tmp/pk/conf-lab; mkdir -p /tmp/pk/conf-lab/DEBIAN /tmp/pk/conf-lab/etc /tmp/pk/conf-lab/usr/share/conf-lab; printf 'Package: conf-lab\\nVersion: 1.0\\nArchitecture: all\\nMaintainer: Lab <lab@example.com>\\nDescription: lab package with a config file\\n' > /tmp/pk/conf-lab/DEBIAN/control; echo /etc/conf-lab.conf > /tmp/pk/conf-lab/DEBIAN/conffiles; echo 'mode=lab' > /tmp/pk/conf-lab/etc/conf-lab.conf; echo conf-lab > /tmp/pk/conf-lab/usr/share/conf-lab/info; dpkg-deb --build /tmp/pk/conf-lab /tmp/conf-lab_1.0_all.deb >/dev/null; dpkg -i /tmp/conf-lab_1.0_all.deb >/dev/null 2>&1",
     [chk('설정 파일 /etc/conf-lab.conf 도 없다', '[ ! -e /etc/conf-lab.conf ]'),
      chk('conf-lab 이 설치도 rc 도 아니다', '! dpkg -l conf-lab 2>/dev/null | grep -q "^[a-z][a-z] *conf-lab"')])

# 10 lock 읽기
b.choice('Could not get lock 은 왜 나올까',
         '다음 두 터미널에서 같은 시각에 패키지 도구를 돌렸습니다.\n\n```\n터미널 A: apt-get install -y some-package      (진행 중)\n터미널 B: apt-get install -y other-package\nE: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 1234 (apt-get)\n```\n\n이 오류가 가리키는 사실로 알맞은 것은 무엇일까요?',
         '오류 메시지에 "held by process" 와 프로세스 번호가 있습니다. 패키지 DB 를 동시에 고치면 어떻게 될지 생각해 보세요.',
         ['패키지 DB 가 깨지지 않도록 한 번에 하나만 쓰게 하는 잠금이 걸려 있고, 지금은 다른 프로세스가 쥐고 있다', '저장소 서버가 응답하지 않는다', '현재 사용자에게 패키지를 설치할 권한이 없다', '디스크가 가득 차서 쓸 수 없다'], 0,
         'apt/dpkg 는 설치 DB 를 동시에 고치지 않도록 `/var/lib/dpkg/lock*` 잠금 파일을 씁니다. 메시지의 번호(PID)가 지금 잠금을 쥔 프로세스이고, 보통은 끝날 때까지 기다리는 것이 맞습니다(`ps` 로 확인). 권한 부족은 `Permission denied`, 디스크 부족은 `No space left on device`, 저장소 문제는 `Failed to fetch` 계열로 나타납니다. 잠금 파일을 함부로 지우지 않습니다.')

# 11 rpm -qf
b.choice('Rocky 에서 파일 주인 패키지 찾기',
         '이제 Rocky Linux 같은 RHEL 계열로 넘어갑니다. 이 계열은 `.rpm` 패키지를 쓰고, 설치 장부를 읽는 도구가 `rpm` 입니다. 앞에서 Ubuntu 로 한 `dpkg -S /usr/bin/pgrep`("이 파일은 어느 패키지 것?")에 **가장 가까운** Rocky 명령은 무엇일까요?',
         '`rpm` 의 조회 옵션은 `-q`(query)에 글자를 붙입니다. "file 의 주인"에 해당하는 글자를 떠올려 보세요 (`-qa` 는 전체 목록).',
         ['`rpm -qf /usr/bin/pgrep`', '`rpm -ql /usr/bin/pgrep`', '`rpm -qi /usr/bin/pgrep`', '`dnf install /usr/bin/pgrep`'], 0,
         '`rpm -qf 파일` 이 파일의 주인 패키지를 알려 줍니다(`-q` query, `f` file). `rpm -ql 패키지` 는 `dpkg -L` 처럼 패키지가 설치한 파일 목록, `rpm -qi 패키지` 는 `dpkg -s` 처럼 상세 정보이며, `rpm -qa` 는 `dpkg -l` 과 비슷한 전체 목록입니다. `dnf install` 은 설치 명령입니다.')

# 12 틀린 대응
b.choice('apt·dpkg 와 dnf·rpm 대응 중 틀린 것',
         'Ubuntu(apt·dpkg)와 Rocky(dnf·rpm)의 명령을 짝지어 놓았습니다. **잘못 짝지은 것**은 무엇일까요?',
         '"목록만 새로 받는" 동작과 "실제로 새 버전으로 바꾸는" 동작을 구분해 보세요.',
         ['`apt-get update`(저장소 목록만 갱신) = `dnf update`(패키지를 새 버전으로 업그레이드)', '`apt-get install 이름` = `dnf install 이름`', '`dpkg -i 파일.deb` = `rpm -ivh 파일.rpm`', '`dpkg -l` = `rpm -qa`'], 0,
         '`apt-get update` 는 설치 가능한 패키지 **목록만** 새로 받고, 패키지를 바꾸지 않습니다. `dnf update` 는 목록 확인과 함께 **업그레이드까지** 하므로 `apt-get update && apt-get upgrade` 쪽에 가깝고, 목록만 갱신하는 쪽은 `dnf makecache` 입니다. 나머지 셋은 알맞은 짝입니다. 저장소 설정 파일도 apt 는 `/etc/apt/sources.list`, dnf 는 `/etc/yum.repos.d/*.repo` 로 다릅니다.')

if __name__ == '__main__':
    preview(b)
