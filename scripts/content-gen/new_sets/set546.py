import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 546 로그 체계 한눈에: /var/log·rsyslog·logrotate. 명세: docs/specs/spec_gap_set546.md
# linux-systemd 는 전용 이미지(etude-linux-systemd)에 logrotate·rsyslog 가 들어 있다. 옛 공식 이미지로 돌아가도 되도록 setup 은 없을 때만 dnf 로 설치한다.
# rsyslogd 는 띄우지 않고(컨테이너에 journal 소켓 없음) 설정 파일 읽기·`rsyslogd -N1` 검증만 쓴다. logrotate 는 실제로 돈다.

INST = "rpm -q logrotate rsyslog >/dev/null 2>&1 || dnf -y -q install logrotate rsyslog >/dev/null 2>&1; mkdir -p /var/lib/logrotate; "
CLEAN = INST + "rm -rf /var/log/myapp /var/log/myapp.log /etc/logrotate.d/myapp /etc/rsyslog.d/myapp.conf /tmp/q*.txt /var/lib/logrotate/logrotate.status; mkdir -p /var/log/myapp; "
CFG = lambda n: "printf '/var/log/myapp/app.log {\\n    daily\\n    rotate %d\\n    compress\\n    missingok\\n    notifempty\\n    create 0644 root root\\n}\\n' > /etc/logrotate.d/myapp; " % n
APPLOG = "seq 1 50 | sed 's/^/MARK-line /' > /var/log/myapp/app.log; "
SETLINES = lambda f: f"tr -s ' \\n' '\\n' < {f} | grep -v '^$' | sort | tr '\\n' ' '"

b = SetBuilder(546, '로그 체계 한눈에: /var/log·rsyslog·logrotate',
               '서버의 로그가 어디서 어떻게 파일이 되는지 한눈에 익힙니다. `/var/log` 의 주요 파일이 각각 무엇을 담는지, rsyslog 가 "종류.중요도 → 파일" 규칙으로 파일에 쓰는 흐름을 설정 파일에서 읽고 규칙을 추가해 봅니다. 이어서 로그가 디스크를 채우지 않게 돌려 가며 보관하는 logrotate 의 설정을 읽고, `-d` 로 미리 점검하고 `-f` 로 강제 회전하며 보존 개수와 압축을 직접 확인합니다. 샌드박스에서 logrotate 는 실제로 동작합니다.',
               'linux-systemd', '리눅스', 58, 805, '🗂️',
               [{"title": "logrotate 매뉴얼 (man 8 logrotate)", "url": "https://man7.org/linux/man-pages/man8/logrotate.8.html"},
                {"title": "rsyslog 설정 형식", "url": "https://www.rsyslog.com/doc/configuration/index.html"}], 2)

# 1 -------------------------------------------------------------
b.nt('rsyslog 가 파일에 쓰는 목적지 모으기', '리눅스에서 많은 로그는 **rsyslog** 라는 로그 수집 데몬이 받아 `/var/log` 아래 파일로 적어 줍니다. 어느 파일에 무엇을 쓸지는 `/etc/rsyslog.conf` 의 규칙이 정합니다. 규칙 한 줄은 `종류.중요도 action(type="omfile" file="파일경로")` 모양이고, `omfile` 은 "파일에 쓴다"는 출력 방식입니다. (이 서버에는 rsyslog 가 설치돼 있습니다. 서비스를 띄우지는 않고 설정 파일만 읽습니다.)\n\n`/etc/rsyslog.conf` 에서 **켜져 있는 규칙**(앞에 `#` 가 없는 줄)이 `/var/log` 아래에 쓰는 **로그 파일 경로**를 한 줄에 하나씩 **`/tmp/q1.txt`** 에 저장하세요. (경로만, 따옴표는 빼고. `#` 로 시작하는 줄은 주석이라 꺼진 규칙이고, `include(file=...)` 줄은 설정 파일을 불러오는 것이지 로그 파일이 아닙니다.)',
     '먼저 주석 줄을 걸러 낸 뒤, 경로 조각만 뽑으세요. `grep -o` 로 조각만 잘라 내고, 따옴표를 기준으로 나누면 경로만 남습니다.',
     "cat /etc/rsyslog.conf\ngrep -v '^#' /etc/rsyslog.conf | grep -o 'file=\"/var/log[^\"]*\"' | cut -d'\"' -f2 > /tmp/q1.txt\ncat /tmp/q1.txt   # messages, secure, maillog, cron, spooler, boot.log 여섯 파일",
     CLEAN,
     [chk('파일 경로 6개가 정확히 저장돼 있다', '[ "$(' + SETLINES('/tmp/q1.txt') + ')" = "/var/log/boot.log /var/log/cron /var/log/maillog /var/log/messages /var/log/secure /var/log/spooler " ]')])
# 2 -------------------------------------------------------------
b.choice('/var/log 주요 파일의 역할', 'Rocky·RHEL 계열 서버에서 "누가 SSH 로 로그인에 실패했는지, `sudo` 를 쓰고 `su` 로 계정을 바꿨는지" 같은 **인증·보안 관련 기록**을 가장 먼저 찾아볼 파일은 무엇일까요?',
         '`/etc/rsyslog.conf` 에서 `authpriv`(인증·권한 관련) 종류가 어느 파일로 가는지 찾아보세요.',
         ['`/var/log/secure`', '`/var/log/messages`', '`/var/log/dnf.log`', '`/var/log/maillog`'], 0,
         '`/var/log/secure` 는 SSH 로그인 성공·실패, `sudo`, `su` 같은 인증 기록입니다(Ubuntu 계열의 `/var/log/auth.log` 에 해당). `/var/log/messages` 는 시스템 전반의 일반 로그, `/var/log/dnf.log` 는 패키지 설치·갱신 기록, `/var/log/maillog` 는 메일 서버 기록입니다. 시스템 로그(`/var/log/messages` 등)는 rsyslog 가 쓰지만 `dnf.log` 처럼 프로그램이 직접 쓰는 파일도 같은 폴더에 있습니다. 파일마다 권한도 `secure` 는 root 만 읽도록 좁게 걸려 있습니다.')
# 3 -------------------------------------------------------------
b.nt('messages 규칙 읽기: 어떤 로그가 빠질까', '`/etc/rsyslog.conf` 에서 `/var/log/messages` 에 쓰는 규칙은 `종류.중요도;종류.none;...` 모양입니다. 앞의 `종류.중요도` 에서 `*` 는 모든 종류, `info` 는 "info 이상 중요도 전부"입니다. `;` 뒤의 `종류.none` 은 **그 종류는 제외**한다는 뜻입니다.\n\n`/var/log/messages` 에 쓰는 규칙을 찾아, 그 규칙에서 **제외되는 종류의 이름**을 한 줄에 하나씩 **`/tmp/q3.txt`** 에 저장하세요. (`.none` 은 빼고 종류 이름만)',
     '`/var/log/messages` 가 적힌 줄을 먼저 찾고, 그 줄에서 `.none` 앞 단어만 뽑으세요. 한 줄에 하나씩 나누려면 `tr` 로 `;` 를 줄바꿈으로 바꾸는 방법이 있습니다.',
     "grep messages /etc/rsyslog.conf\ngrep '/var/log/messages' /etc/rsyslog.conf | awk '{print $1}' | tr ';' '\\n' | grep '\\.none$' | sed 's/\\.none$//' > /tmp/q3.txt\ncat /tmp/q3.txt   # mail, authpriv, cron (이 종류들은 각자 다른 파일로 간다)",
     CLEAN,
     [chk('제외 종류 3개가 정확히 저장돼 있다', '[ "$(' + SETLINES('/tmp/q3.txt') + ')" = "authpriv cron mail " ]')])
# 4 -------------------------------------------------------------
b.nt('내 앱 로그를 파일로 받는 rsyslog 규칙 추가', '앱이 로그를 `local5` 라는 종류(facility)로 보내도록 되어 있습니다. `local0`~`local7` 은 사용자가 마음대로 쓰라고 비워 둔 종류입니다. 이 로그를 모두 `/var/log/myapp.log` 파일에 쓰는 규칙을 **`/etc/rsyslog.d/myapp.conf`** 에 추가하세요. (`/etc/rsyslog.conf` 가 `/etc/rsyslog.d/*.conf` 를 불러오므로 본 설정은 건드리지 않고 파일을 따로 두는 것이 관례입니다.)\n\n규칙 모양은 앞에서 읽은 것과 같습니다. 종류는 `local5`, 중요도는 `*`(전부), 출력은 `omfile` 입니다. 작성한 뒤 `rsyslogd -N1` 로 문법을 점검해 `End of config validation run` 이 오류 없이 나오는지 확인하세요. (`-N1` 은 실제로 띄우지 않고 설정만 검증합니다.)',
     '규칙 한 줄이면 됩니다. 앞 문제에서 읽은 줄의 모양을 본떠 종류와 경로만 바꾸세요. 따옴표와 괄호가 빠지면 `-N1` 이 오류를 알려 줍니다.',
     "echo 'local5.* action(type=\"omfile\" file=\"/var/log/myapp.log\")' > /etc/rsyslog.d/myapp.conf\nrsyslogd -N1   # End of config validation run. 오류 없음\n# 적용은 rsyslog 서비스 재시작(systemctl restart rsyslog)으로 한다. 샌드박스에서는 띄우지 않았다.",
     CLEAN,
     [chk('규칙 파일에 local5 종류가 있다', 'grep -qE "^[[:space:]]*local5\\.\\*[[:space:]]" /etc/rsyslog.d/myapp.conf'),
      chk('출력 파일이 /var/log/myapp.log 다', 'grep -qE "^[[:space:]]*local5\\.\\*[[:space:]].*/var/log/myapp\\.log" /etc/rsyslog.d/myapp.conf'),
      chk('rsyslog 설정 검증이 통과한다', 'rsyslogd -N1 >/dev/null 2>&1')])
# 5 -------------------------------------------------------------
b.nt('logrotate 전역 설정 읽기: 주기와 보존 개수', '쌓이기만 하는 로그는 디스크를 채웁니다. **logrotate** 는 로그를 일정 주기로 이름을 바꿔(`messages` → `messages.1`...) 돌려 가며 보관하고 오래된 것은 지웁니다. 기본 설정은 `/etc/logrotate.conf`, 파일별 설정은 `/etc/logrotate.d/` 에 있습니다. 파일별 설정에 없는 항목은 `/etc/logrotate.conf` 의 값이 적용됩니다. (`#` 로 시작하는 줄은 주석입니다.)\n\n`/etc/logrotate.conf` 의 **회전 주기**(`daily`·`weekly`·`monthly` 중 하나)와 **보존 개수**(`rotate` 뒤 숫자)를 **`/tmp/q5.txt`** 에 한 줄씩, 주기 → 개수 순서로 저장하세요. (첫 줄은 주기 단어, 둘째 줄은 숫자만)',
     '주석을 빼고 읽으면 짧습니다. 주기 줄은 줄 전체가 단어 하나이고, 개수 줄은 `rotate` 와 숫자 두 칸이라 `awk` 로 둘째 칸만 뽑을 수 있습니다.',
     "grep -v '^#' /etc/logrotate.conf | grep -v '^$'\ngrep -E '^(daily|weekly|monthly)$' /etc/logrotate.conf > /tmp/q5.txt\nawk '$1==\"rotate\" {print $2}' /etc/logrotate.conf >> /tmp/q5.txt\ncat /tmp/q5.txt   # weekly, 4  (4주치 보관)",
     CLEAN,
     [chk('주기 줄과 개수 줄이 순서대로 저장돼 있다', '[ -s /tmp/q5.txt ] && [ "$(cat /tmp/q5.txt)" = "$(grep -E "^(daily|weekly|monthly)$" /etc/logrotate.conf; awk \'$1=="rotate" {print $2}\' /etc/logrotate.conf)" ]')])
# 6 -------------------------------------------------------------
b.fill('실제로 돌리지 않고 미리 점검하기', '새로 만든 logrotate 설정이 맞는지 **로그 파일을 건드리지 않고** "만약 돌리면 이렇게 하겠다"는 계획만 출력해 보는 옵션이 있습니다. 빈칸을 채우세요.\n\n`-d` · `-f` · `-v` 가 헷갈릴 수 있으니 주의하세요. 하나는 실제로 파일을 바꿉니다.',
       '`man logrotate` 에서 옵션 설명을 읽어 보세요. 파일을 바꾸지 않고 메시지만 출력한다고 적힌 옵션이 답입니다.',
       'logrotate {0} /etc/logrotate.d/myapp', ['-d', '-f', '-v', '-s'], [0],
       '`-d`(debug)는 **아무것도 바꾸지 않고** 설정을 읽어 무엇을 할지만 출력합니다. 새 설정을 만들었을 때 문법 오류와 "어떤 파일을 몇 번 보관할지"를 먼저 확인하는 안전한 방법입니다. `-f`(force)는 주기가 안 됐어도 **강제로 실제 회전**을 하고, `-v`(verbose)는 자세히 출력하면서 **실제로 회전**도 합니다(`-d` 처럼 보여도 아닙니다). `-s` 는 상태 파일 경로를 지정하는 옵션이라 뒤에 경로가 더 필요합니다.')
# 7 -------------------------------------------------------------
b.nt('앱 로그용 logrotate 설정 작성', '앱이 `/var/log/myapp/app.log` 에 로그를 남깁니다. 이 로그가 디스크를 채우지 않게 **`/etc/logrotate.d/`** 안에 설정 파일을 만드세요. 파일 이름은 자유입니다. 설정은 `로그경로 { 옵션들 }` 모양이고, 필요한 옵션은 다음과 같습니다.\n- `daily` : 하루에 한 번 회전\n- `rotate 7` : 회전된 옛 로그를 7개까지 보관, 그보다 오래된 것은 삭제\n- `compress` : 회전된 옛 로그를 gzip 으로 압축\n- `missingok` : 로그 파일이 없어도 오류로 치지 않음\n- `notifempty` : 비어 있으면 회전하지 않음\n\n작성한 뒤 `logrotate -d` 로 점검만 하고(실제 회전인 `-f` 는 하지 마세요)  `rotating pattern: /var/log/myapp/app.log  after 1 days (7 rotations)` 같은 줄이 나오는지 확인하세요.',
     '`/etc/logrotate.d/` 의 기존 파일(예: `cat /etc/logrotate.d/dnf`)이 모양의 본보기입니다. 경로, 중괄호, 옵션을 한 줄에 하나씩 적고, `-d` 에 설정 파일을 지정해 확인합니다.',
     "cat > /etc/logrotate.d/myapp <<'EOF'\n/var/log/myapp/app.log {\n    daily\n    rotate 7\n    compress\n    missingok\n    notifempty\n}\nEOF\nlogrotate -d /etc/logrotate.d/myapp   # after 1 days (7 rotations)\n# -d 는 아무것도 바꾸지 않는다. 설정이 맞는지 보는 용도",
     CLEAN + APPLOG,
     [chk('logrotate 가 /var/log/myapp/app.log 를 매일·7개 보관으로 읽는다', 'logrotate -d /etc/logrotate.conf 2>&1 | grep -q "rotating pattern: /var/log/myapp/app.log  after 1 days (7 rotations)"'),
      chk('압축(compress) 옵션이 설정돼 있다', 'f=$(grep -rl "/var/log/myapp/app.log" /etc/logrotate.d /etc/logrotate.conf); [ -n "$f" ] && grep -qw compress $f'),
      chk('옛 로그가 아직 압축·삭제되지 않았다(점검만 했다)', '[ "$(wc -l < /var/log/myapp/app.log)" = 50 ] && ! ls /var/log/myapp/app.log.* >/dev/null 2>&1')])
# 8 -------------------------------------------------------------
b.nt('강제로 한 번 회전시키고 결과 보기', '`/var/log/myapp/app.log` 에는 로그 50줄이 쌓여 있고 `/etc/logrotate.d/myapp` 설정도 이미 있습니다. (설정에는 매일 회전, 3개 보관, 압축, 새 파일 생성 옵션이 들어 있습니다.) 그런데 logrotate 는 보통 하루 한 번 돌기 때문에 지금 결과를 보려면 주기와 상관없이 **강제로** 돌려야 합니다.\n\n`/etc/logrotate.d/myapp` 설정으로 **지금 강제 회전**을 실행하세요. 실행 후 `ls -l /var/log/myapp` 에서 이름이 바뀌고 압축된 파일과 새로 만들어진 빈 `app.log` 를 확인해 보세요.',
     '앞 문제에서 구분한 옵션 중 "주기가 안 됐어도 실제로 회전"하는 쪽입니다. 설정 파일 경로를 뒤에 적습니다.',
     "logrotate -f /etc/logrotate.d/myapp\nls -l /var/log/myapp   # app.log(빈 새 파일), app.log.1.gz(압축된 옛 로그)\nzcat /var/log/myapp/app.log.1.gz | head -3",
     CLEAN + CFG(3) + APPLOG,
     [chk('옛 로그가 app.log.1.gz 로 압축돼 있다', '[ "$(zcat /var/log/myapp/app.log.1.gz | grep -c MARK-line)" = 50 ]'),
      chk('새 빈 app.log 가 만들어져 있다', '[ -f /var/log/myapp/app.log ] && [ ! -s /var/log/myapp/app.log ]')])
# 9 -------------------------------------------------------------
b.nt('보존 개수를 줄이면 오래된 것이 사라진다', '`/var/log/myapp/` 에는 지금 `app.log.1.gz`, `app.log.2.gz`, `app.log.3.gz` 세 개의 옛 로그가 있고 `app.log` 에는 최신 로그가 쌓여 있습니다. 설정(`/etc/logrotate.d/myapp`)은 `rotate 3` 입니다. 디스크가 부족해 **2개만 보관**하기로 했습니다.\n\n설정의 보존 개수를 **2** 로 바꾸고 **강제 회전**을 실행해, 가장 오래된 `app.log.3.gz` 가 사라지고 `app.log.1.gz`·`app.log.2.gz` 만 남게 하세요. (최신 로그는 `app.log.1.gz` 로 압축돼 이어져야 합니다. 파일을 `rm` 으로 직접 지우지 마세요.)',
     '설정 파일의 숫자 하나를 고친 뒤(`sed -i` 도 쓸 수 있습니다), 앞 문제처럼 강제로 돌립니다. 회전 때 보존 개수를 넘는 옛 파일은 logrotate 가 지웁니다.',
     "sed -i 's/rotate 3/rotate 2/' /etc/logrotate.d/myapp\nlogrotate -f /etc/logrotate.d/myapp\nls -l /var/log/myapp   # app.log.1.gz, app.log.2.gz 만 남는다",
     CLEAN + CFG(3) + APPLOG + "for i in 1 2 3; do echo old$i | gzip > /var/log/myapp/app.log.$i.gz; done",
     [chk('설정이 2개 보관이다', 'logrotate -d /etc/logrotate.conf 2>&1 | grep -q "rotating pattern: /var/log/myapp/app.log  after 1 days (2 rotations)"'),
      chk('가장 오래된 app.log.3.gz 가 없다', '[ ! -e /var/log/myapp/app.log.3.gz ] && [ -e /var/log/myapp/app.log.2.gz ]'),
      chk('최신 로그가 app.log.1.gz 로 회전됐다(rm 이 아니라 logrotate)', 'zcat /var/log/myapp/app.log.1.gz | grep -q MARK-line')])
# 10 ------------------------------------------------------------
b.choice('logrotate 는 누가 언제 실행할까', '서버에 logrotate 라는 상주 프로세스(데몬)는 보이지 않는데도 매일 로그가 회전됩니다. Rocky 9 에서 이 회전은 어떻게 일어날까요?',
         '`rpm -ql logrotate` 로 패키지 파일 목록을 보고 `/usr/lib/systemd/system/` 아래 유닛 파일을 찾아 보세요. 앞 세트에서 배운 systemd 유닛 종류를 떠올려 보세요.',
         ['systemd 의 `logrotate.timer` 가 하루에 한 번 `logrotate.service` 를 실행한다. logrotate 는 한 번 돌고 끝나는 프로그램이다', 'logrotate 데몬이 부팅 때부터 상주하며 파일 크기를 실시간으로 감시한다', 'rsyslog 가 로그를 쓸 때마다 logrotate 를 직접 호출한다', '커널이 로그 파일이 커지면 자동으로 회전한다'], 0,
         'logrotate 는 **상주하지 않는 일회성 프로그램**입니다. Rocky 9 는 `logrotate.timer`(`OnCalendar=daily`)가 `logrotate.service` 를 하루 한 번 실행하고, 예전 배포판은 `/etc/cron.daily/logrotate` 가 같은 일을 했습니다. 실행될 때 설정을 읽어 "이번에 돌릴 때가 된 파일"만 회전합니다. 그래서 `daily` 설정도 실제로는 타이머가 도는 시각에 한 번만 확인되고, 즉시 확인하려면 `-f` 를 씁니다. 이 샌드박스에서는 `logrotate.timer` 가 비활성이라 자동 회전은 일어나지 않지만 구성은 같습니다.')
# 11 ------------------------------------------------------------
b.choice('회전 뒤에도 앱이 옛 파일에 계속 쓸 때', '로그를 계속 열어 두고 쓰는 서버 프로그램의 로그를 logrotate 로 회전했더니, `app.log` 는 새로 만들어졌는데 프로그램은 **이름이 바뀐 옛 파일(`app.log.1`)에 계속 로그를 쓰고** 있습니다. 새 `app.log` 는 비어 있습니다. 이 문제를 해결하는 방법으로 가장 알맞은 것은 무엇일까요?',
         '프로그램은 파일 이름이 아니라 이미 열어 둔 파일에 씁니다. 이름이 바뀐 뒤에도 같은 파일에 쓰는 이유를 생각해 보세요.',
         ['`postrotate` 로 회전 뒤 프로그램에 로그를 다시 열라는 신호를 보내거나(`systemctl kill -s HUP` 등), 다시 열기를 지원하지 않으면 `copytruncate` 옵션으로 복사 후 원본을 비운다', '`compress` 옵션을 빼면 해결된다', '`rotate` 숫자를 크게 하면 옛 파일에 쓰지 않게 된다', '`notifempty` 를 넣으면 새 파일을 알아서 찾아 쓴다'], 0,
         '프로그램은 이름이 아니라 **열어 둔 파일**에 씁니다. 이름이 바뀐 뒤에도 같은 파일에 쓰므로, 회전 뒤 `postrotate ... endscript` 안에서 재열기 신호(예: `cat /etc/logrotate.d/rsyslog` 의 `postrotate` 줄에 있는 `HUP`)를 보내는 것이 정석입니다. 재열기를 지원하지 않는 프로그램은 `copytruncate`(내용을 복사한 뒤 원본을 0 바이트로 비움)를 씁니다. 복사와 비우기 사이에 쓰인 몇 줄이 유실될 수 있어 차선책입니다. `compress`·`rotate` 개수·`notifempty` 는 이 문제와 무관합니다. 참고로 `/etc/logrotate.d/rsyslog` 가 바로 `postrotate` 로 rsyslog 에 HUP 를 보내는 예입니다.')
# 12 ------------------------------------------------------------
b.order('새 앱 로그에 logrotate 를 적용하는 순서', '새 앱의 로그에 logrotate 를 처음 적용할 때의 알맞은 순서로 카드를 놓으세요. (설정 파일이 있어야 시작할 수 있고, 파일을 바꾸는 단계는 안전 점검 뒤에 둡니다. 마지막 단계는 결과 확인입니다)',
        '각 카드가 파일을 바꾸는지, 바꾸지 않고 보기만 하는지 나눠 보세요. 설정 파일이 없으면 어느 단계도 할 수 없습니다.',
        ['`logrotate -f` 로 강제 회전을 한 번 실행한다', '`ls -l` 로 회전된 파일과 새 로그 파일을 확인한다', '`/etc/logrotate.d/` 에 앱 로그용 설정 파일을 만든다', '`logrotate -d` 로 설정을 미리 점검한다'], [2, 3, 0, 1],
        '설정 작성 → `-d` 로 안전 점검(문법·보존 개수 확인, 파일은 그대로) → `-f` 로 시험 회전 → `ls -l` 로 결과 확인입니다. `-d` 없이 바로 `-f` 를 돌리면 설정 실수가 곧바로 실제 로그에 반영되므로, 점검을 앞에 둡니다. 시험이 끝나면 앱이 새 파일에 정상적으로 쓰는지(필요하면 `postrotate`)도 한 번 확인합니다.')

if __name__ == '__main__':
    preview(b)
