-- 세트 24 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='설치된 패키지 개수 세기', description='서버에 무엇이 설치되어 있는지 파악하는 것은 점검과 보안 감사의 시작입니다. Rocky Linux 는 `rpm` 으로 패키지를 관리합니다.

이 서버에 설치된 패키지가 **몇 개인지** 숫자만 `/tmp/pkg_count.txt` 에 저장하세요.', hint='`rpm -qa` 는 설치된 모든 패키지를 한 줄에 하나씩 보여 줍니다. 줄 수를 세는 `wc -l` 을 파이프(`|`)로 이으세요.', solution='rpm -qa | wc -l > /tmp/pkg_count.txt

# rpm -qa : query all, 설치된 모든 패키지' WHERE quest_set_id = 24 AND order_index = 1;
UPDATE quest SET title='패키지 버전 확인하기', description='문제가 특정 버전에서만 나는지 확인하려면 설치된 정확한 버전을 알아야 합니다.

`bash` 패키지의 **전체 이름(버전 포함)** 을 `/tmp/bash_ver.txt` 에 저장하세요. (예: `bash-5.1.8-...`)', hint='`rpm -q <패키지이름>` 은 설치 여부와 버전을 출력합니다.', solution='rpm -q bash > /tmp/bash_ver.txt

# rpm -q : query, 패키지의 설치 여부와 버전' WHERE quest_set_id = 24 AND order_index = 2;
UPDATE quest SET title='이 파일은 어느 패키지에서 왔을까?', description='서버에서 낯선 파일이나 명령을 발견했을 때, 어느 패키지가 설치했는지 알면 용도와 업데이트 방법을 알 수 있습니다.

`/bin/ls` 파일을 설치한 **패키지 이름**을 `/tmp/owner.txt` 에 저장하세요.', hint='`rpm -qf <파일경로>` 는 그 파일을 설치한 패키지를 알려 줍니다. (`-f` 는 file)', solution='rpm -qf /bin/ls > /tmp/owner.txt

# -qf : 이 파일(file)은 어느 패키지 것인지' WHERE quest_set_id = 24 AND order_index = 3;
UPDATE quest SET title='패키지가 설치한 실행 파일 찾기', description='패키지가 어떤 파일을 설치했는지 알면 어떤 명령이 추가되었는지 알 수 있습니다.

`which` 패키지가 설치한 파일 중 **실행 파일**(경로에 `bin/` 이 들어간 것)의 경로를 `/tmp/which_bin.txt` 에 저장하세요.', hint='`rpm -ql <패키지>` 는 패키지가 설치한 모든 파일을 나열합니다. (`-l` 은 list) 그중 `bin/` 이 들어간 줄만 `grep` 으로 고르세요.', solution='rpm -ql which | grep ''bin/'' > /tmp/which_bin.txt

# -ql : 패키지가 설치한 파일 목록(list)' WHERE quest_set_id = 24 AND order_index = 4;
UPDATE quest SET title='패키지 정보에서 라이선스 찾기', description='상용 서비스에 쓰기 전에 라이선스를 확인하는 일이 있습니다.

`bash` 패키지의 **라이선스 정보 줄**(`License` 로 시작하는 줄)을 `/tmp/license.txt` 에 저장하세요.', hint='`rpm -qi <패키지>` 는 패키지의 상세 정보(버전, 설명, 라이선스 등)를 보여 줍니다. `grep License` 로 해당 줄만 고르세요.', solution='rpm -qi bash | grep License > /tmp/license.txt

# -qi : 패키지 상세 정보(info)' WHERE quest_set_id = 24 AND order_index = 5;
UPDATE quest SET title='패키지 원본과 달라진 파일 찾기', description='누군가 설정 파일을 수정했는지, 변조되지 않았는지는 패키지 원본과 비교해 알 수 있습니다.

누군가 `/etc/profile` 을 수정했습니다. `rpm` 으로 이 파일이 패키지 원본과 달라졌는지 검사하고, 그 결과를 `/tmp/verify.txt` 에 저장하세요.', hint='`rpm -Vf <파일>` 은 그 파일을 설치한 패키지를 기준으로 **검증**합니다 (`-V` 검증, `-f` 파일). 출력의 `5` 는 내용(MD5)이 바뀐 것, `c` 는 설정 파일 표시입니다. 바뀐 게 없으면 아무것도 출력되지 않습니다.', solution='rpm -Vf /etc/profile > /tmp/verify.txt

# 출력 예: S.5....T.  c /etc/profile
# S 크기, 5 내용(MD5), T 수정 시각이 달라졌다는 뜻' WHERE quest_set_id = 24 AND order_index = 6;
UPDATE quest SET title='logger 로 남긴 로그 찾아보기', description='systemd 시스템의 로그는 **journal** 에 모이고 `journalctl` 로 조회합니다. `logger` 명령으로 직접 로그를 남겨 볼 수 있습니다.

1. `logger` 로 태그 `myapp` 에 메시지 `disk almost full` 을 남깁니다.
2. `journalctl` 로 태그 `myapp` 의 로그를 조회해 `/tmp/myapp.log` 에 저장합니다.', hint='기록: `logger -t <태그> ''<메시지>''`
조회: `journalctl -t <태그> --no-pager` (`--no-pager` 는 한 화면씩 끊지 않고 전부 출력)
기록이 반영되는 데 1초쯤 걸리니 두 명령 사이에 `sleep 1` 을 넣으세요.', solution='logger -t myapp ''disk almost full''
sleep 1
journalctl -t myapp --no-pager > /tmp/myapp.log

# -t : 태그(식별 이름)' WHERE quest_set_id = 24 AND order_index = 7;
UPDATE quest SET title='우선순위로 로그 걸러 보기', description='로그에는 우선순위(info, warning, err 등)가 있고, 문제를 찾을 때는 **err 이상**만 보는 것이 효율적입니다.

journal 에 태그 `svc` 로 `info` 와 `err` 우선순위 메시지가 하나씩 남아 있습니다. `err` 이상 우선순위만, **메시지 본문만**(시각 등 제외) `/tmp/err.log` 에 저장하세요.', hint='`journalctl -p err -t svc --no-pager -o cat` 에서 `-p err` 는 err 이상 우선순위만, `-t svc` 는 태그, `-o cat` 은 시각 같은 부가 정보 없이 본문만 출력하는 옵션입니다.', solution='journalctl -p err -t svc --no-pager -o cat > /tmp/err.log

# -p err : 우선순위 err 이상, -o cat : 본문만' WHERE quest_set_id = 24 AND order_index = 8;
UPDATE quest SET title='서비스를 시작하고 그 유닛의 로그 보기', description='서비스가 이상할 때 그 서비스(유닛)가 남긴 로그만 따로 보는 것이 가장 흔한 조사 방법입니다.

`hello` 서비스를 시작하고, 그 유닛이 남긴 로그(본문만)를 `/tmp/unit.log` 에 저장하세요.', hint='시작: `systemctl start <서비스>`
로그: `journalctl -u <서비스> --no-pager -o cat` (`-u` 는 unit, 특정 서비스의 로그만)
서비스가 로그를 남기는 데 1초쯤 걸리니 사이에 `sleep 1` 을 넣으세요.', solution='systemctl start hello
sleep 1
journalctl -u hello --no-pager -o cat > /tmp/unit.log

# -u : 특정 유닛(서비스)의 로그만' WHERE quest_set_id = 24 AND order_index = 9;
UPDATE quest SET title='서비스 유닛 파일을 만들고 부팅 시 자동 시작하기', description='직접 만든 프로그램을 **systemd 서비스**로 등록하면 부팅 때 자동 시작과 재시작 관리를 받을 수 있습니다.

`/etc/systemd/system/app.service` 파일을 만들어 `/bin/sleep 3600` 을 실행하는 서비스를 정의하고, **지금 시작하면서 부팅 때도 자동 시작**되게 하세요.

완료 조건: `app` 서비스가 `active` 이고 `enabled` 여야 합니다.', hint='유닛 파일의 기본 구조입니다.
- `[Service]` 아래에 `ExecStart=<실행할 명령>`
- `[Install]` 아래에 `WantedBy=multi-user.target` (부팅 시 시작 대상)
파일을 만든 뒤 `systemctl daemon-reload`(새 파일 읽기), `systemctl enable --now app`(자동 시작 등록 + 지금 시작) 순서입니다.', solution='cat > /etc/systemd/system/app.service <<EOF
[Service]
ExecStart=/bin/sleep 3600

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload        # 새 유닛 파일을 읽음
systemctl enable --now app     # 부팅 시 자동 시작 등록 + 지금 시작' WHERE quest_set_id = 24 AND order_index = 10;
UPDATE quest SET title='실패한 서비스 찾기', description='서버에 문제가 생기면 먼저 **실패한 서비스가 있는지** 봅니다.

시스템에서 `failed` 상태인 서비스의 **이름**을 `/tmp/failed.txt` 에 저장하세요.', hint='`systemctl list-units --state=failed --no-legend --plain` 은 실패한 유닛을 한 줄씩 보여 줍니다. 첫 번째 칸이 이름이므로 `awk ''{print $1}''` 로 뽑으세요. (`systemctl --failed` 로 눈으로 먼저 봐도 됩니다. 원인은 `systemctl status <이름>` 과 `journalctl -u <이름>` 으로 봅니다.)', solution='systemctl list-units --state=failed --no-legend --plain | awk ''{print $1}'' > /tmp/failed.txt

# 원인 확인
systemctl status bad.service
journalctl -u bad.service --no-pager' WHERE quest_set_id = 24 AND order_index = 11;
UPDATE quest SET title='부팅 시 자동 시작 해제하기', description='더 이상 쓰지 않는 서비스가 부팅 때 자동으로 시작되지 않게 합니다. 서비스 파일을 지우는 것과는 다릅니다.

`hello` 서비스가 **부팅 때 자동으로 시작되지 않도록** 해제하세요.', hint='`systemctl disable <서비스>` 입니다. 지금 실행 중인 서비스를 멈추는 것은 `systemctl stop` 이 따로 필요합니다. 확인: `systemctl is-enabled hello`', solution='systemctl disable hello

# 확인 (disabled 가 나와야 합니다)
systemctl is-enabled hello' WHERE quest_set_id = 24 AND order_index = 12;
UPDATE quest SET title='서버 타임존 바꾸기', description='로그의 시각이 맞지 않으면 장애 분석이 어려워집니다. 서버의 타임존은 올바르게 맞춰야 합니다.

서버의 타임존을 `Asia/Seoul` 로 바꾸세요.', hint='`timedatectl set-timezone <타임존>` 입니다. 가능한 타임존 목록은 `timedatectl list-timezones` 로 볼 수 있고, 현재 설정은 `timedatectl` 로 확인합니다.', solution='timedatectl set-timezone Asia/Seoul

# 확인
timedatectl' WHERE quest_set_id = 24 AND order_index = 13;
