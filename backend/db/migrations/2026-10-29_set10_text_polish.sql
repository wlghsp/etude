-- 세트 10 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='서비스 상태 확인하기', description='서버 점검의 시작은 서비스가 실행 중인지 보는 것입니다. 리눅스(systemd)에서는 `systemctl` 로 서비스를 관리합니다.

`cron`(정기 작업을 실행하는 서비스, 이름은 `crond`)의 **상태**를 `/tmp/svc_status.txt` 에 저장하세요.', hint='`systemctl status <서비스이름>` 은 실행 여부, 부팅 시 자동 시작 여부, 최근 로그를 보여 줍니다. 결과를 `>` 로 저장하세요. 서비스가 멈춰 있으면 에러 출력이 섞이므로 `2>&1`(에러도 같은 파일로)을 함께 쓰세요.', solution='systemctl status crond > /tmp/svc_status.txt 2>&1

# status : 서비스 상태 확인
# 2>&1 : 에러 출력도 같은 파일로' WHERE quest_set_id = 10 AND order_index = 1;
UPDATE quest SET title='서비스 시작하고 부팅 시 자동 시작 켜기', description='서비스를 지금 켜는 것(start)과 서버가 재부팅되어도 자동으로 켜지게 하는 것(enable)은 별개입니다. 운영 서비스는 보통 둘 다 합니다.

`crond` 서비스를 **시작**하고, **부팅 시 자동 시작**되도록 활성화하세요.', hint='`systemctl start <서비스>` 는 지금 시작, `systemctl enable <서비스>` 는 부팅 시 자동 시작 등록입니다. 두 명령을 `&&` 로 이어 쓸 수 있습니다. (`systemctl enable --now` 로 한 번에도 가능)', solution='systemctl start crond && systemctl enable crond

# start : 지금 시작, enable : 부팅 때 자동 시작 등록
# && : 앞 명령이 성공하면 이어서 실행' WHERE quest_set_id = 10 AND order_index = 2;
UPDATE quest SET title='전체 사용자에게 환경변수 등록하기 (/etc/profile.d)', description='`export` 로 설정한 환경변수는 그 터미널에서만 유효합니다. 모든 사용자의 로그인 시 적용하려면 `/etc/profile.d/` 에 스크립트 파일을 둡니다.

`/etc/profile.d/myapp.sh` 파일을 만들어 환경변수 `APP_HOME=/opt/myapp` 을 등록하세요.', hint='`/etc/profile.d/*.sh` 파일은 로그인할 때마다 자동으로 실행됩니다. 파일 안에 `export APP_HOME=/opt/myapp` 한 줄을 쓰면 됩니다. `echo "..." > 파일` 로 만들 수 있습니다.', solution='echo "export APP_HOME=/opt/myapp" > /etc/profile.d/myapp.sh

# /etc/profile.d/ 의 .sh 파일은 로그인할 때 자동 실행됩니다' WHERE quest_set_id = 10 AND order_index = 3;
UPDATE quest SET title='서비스용 시스템 계정 만들기', description='서비스는 root 로 돌리지 않고, 로그인이 불가능한 전용 계정으로 돌리는 것이 보안의 기본입니다.

서비스용 시스템 계정 `myservice` 를 만드세요. 로그인용 셸이 없는(로그인 불가) 시스템 계정이어야 합니다.', hint='`useradd -r -s /sbin/nologin <계정이름>` 입니다.
- `-r` : 시스템 계정(system account)으로 생성
- `-s /sbin/nologin` : 로그인 셸을 로그인 불가로 지정', solution='useradd -r -s /sbin/nologin myservice

# -r : 시스템 계정, -s /sbin/nologin : 로그인 불가' WHERE quest_set_id = 10 AND order_index = 4;
UPDATE quest SET title='/etc/hosts 에 호스트 이름 등록하기', description='DNS 없이 이름으로 서버를 찾게 하려면 `/etc/hosts` 에 `IP 이름` 을 적습니다. 내부 서버 접속 설정에 자주 씁니다.

`/etc/hosts` 에 `192.168.1.100 db.internal` 항목을 추가하세요. (기존 내용은 지우면 안 됩니다)', hint='형식은 `IP 이름` 한 줄입니다. 기존 내용을 지우지 않으려면 덮어쓰기 `>` 가 아니라 **이어쓰기 `>>`** 를 쓰세요: `echo "..." >> /etc/hosts`', solution='echo "192.168.1.100 db.internal" >> /etc/hosts

# >> : 파일 끝에 이어쓰기 (> 는 덮어써서 기존 내용이 사라집니다)' WHERE quest_set_id = 10 AND order_index = 5;
UPDATE quest SET title='포트 사용 현황 확인하기', description='어떤 서비스가 어떤 포트를 열고 있는지 확인하는 것은 접속 장애와 보안 점검의 기본입니다.

현재 대기(listen) 중인 TCP 포트 목록을 `/tmp/ports.txt` 에 저장하세요.', hint='`ss -tlnp` 를 씁니다. `-t` TCP, `-l` 대기(listen) 중인 것만, `-n` 숫자로 표시, `-p` 프로세스 표시. 결과를 `>` 로 저장하세요.', solution='ss -tlnp > /tmp/ports.txt

# -t : TCP, -l : listen, -n : 숫자, -p : 프로세스' WHERE quest_set_id = 10 AND order_index = 6;
UPDATE quest SET title='디렉토리를 tar.gz 로 압축 백업하기', description='설정을 바꾸기 전에 백업하는 것은 현장의 기본 수칙입니다.

`/etc` 디렉토리를 `/tmp/etc_backup.tar.gz` 로 압축 백업하세요.', hint='`tar -czf <만들파일> <대상>` 형식입니다. `c` 생성, `z` gzip 압축, `f` 파일 이름 지정. 일부 파일은 읽을 수 없어 경고가 날 수 있으니 `2>/dev/null`(에러 출력 버리기)을 붙이면 화면이 깔끔합니다.', solution='tar -czf /tmp/etc_backup.tar.gz /etc 2>/dev/null || true

# c : 만들기, z : gzip 압축, f : 파일 이름
# 2>/dev/null : 에러 메시지를 버림' WHERE quest_set_id = 10 AND order_index = 7;
UPDATE quest SET title='실행 파일 디렉토리를 PATH 에 등록하기', description='직접 설치한 프로그램을 경로 없이 이름만으로 실행하려면 그 디렉토리를 `PATH` 환경변수에 추가해야 합니다.

1. `/opt/mytool/bin` 디렉토리를 만듭니다.
2. 로그인 때 PATH 에 추가되도록 `/etc/profile.d/mytool.sh` 를 작성합니다.', hint='1) `mkdir -p /opt/mytool/bin` (`-p` 는 중간 경로까지 한 번에 생성)
2) 파일 안에 `export PATH=$PATH:/opt/mytool/bin` 을 씁니다. 기존 PATH 뒤에 이어 붙이는 방식이라 `$PATH` 를 빼먹으면 기존 명령을 못 찾게 됩니다.', solution='mkdir -p /opt/mytool/bin && echo ''export PATH=$PATH:/opt/mytool/bin'' > /etc/profile.d/mytool.sh

# $PATH:경로 : 기존 PATH 뒤에 새 경로를 추가
# 작은따옴표로 감싸야 $PATH 가 지금 치환되지 않고 파일에 그대로 기록됩니다' WHERE quest_set_id = 10 AND order_index = 8;
UPDATE quest SET title='스크립트에 실행 권한 주기 (chmod +x)', description='스크립트 파일은 **실행 권한**이 있어야 `./start.sh` 처럼 실행할 수 있습니다. 새로 만든 파일은 기본적으로 실행 권한이 없습니다.

`/opt/myapp/start.sh` 파일에 실행 권한을 부여하세요.', hint='`chmod +x <파일>` 입니다. `+x` 는 실행(execute) 권한 추가. 확인: `ls -l /opt/myapp/start.sh` 에서 `x` 가 생겼는지 보세요.', solution='chmod +x /opt/myapp/start.sh

# chmod : 권한 변경, +x : 실행 권한 추가' WHERE quest_set_id = 10 AND order_index = 9;
UPDATE quest SET title='디렉토리 소유자 바꾸기 (chown)', description='서비스 계정이 자기 디렉토리를 읽고 쓰려면 그 디렉토리의 **소유자**가 서비스 계정이어야 합니다.

`myservice` 계정을 만들고(없다면), `/opt/myapp` 디렉토리와 그 안의 모든 파일의 소유자를 `myservice` 로 바꾸세요.', hint='1) `useradd -r -s /sbin/nologin myservice` (시스템 계정 만들기)
2) `chown -R myservice:myservice /opt/myapp`
- `-R` : 디렉토리 안의 모든 파일까지(Recursive)
- `사용자:그룹` : 소유자와 소유 그룹을 함께 지정', solution='useradd -r -s /sbin/nologin myservice 2>/dev/null || true && chown -R myservice:myservice /opt/myapp

# chown -R 사용자:그룹 경로 : 소유자 변경 (하위 전체)' WHERE quest_set_id = 10 AND order_index = 10;
UPDATE quest SET title='실행 파일 권한을 755 로 설정하기', description='권한은 숫자 세 자리(소유자/그룹/기타)로도 씁니다. `r`=4, `w`=2, `x`=1 을 더한 값입니다. 서비스 스크립트의 표준 권한이 `755` 입니다.

`/opt/myapp/start.sh` 의 권한을 `755` 로 설정하세요. (소유자는 읽기·쓰기·실행, 그룹과 기타는 읽기·실행만 가능)', hint='`chmod 755 <파일>` 입니다. 7 = 4+2+1(읽기+쓰기+실행), 5 = 4+1(읽기+실행). 자리 순서는 소유자·그룹·기타입니다.', solution='chmod 755 /opt/myapp/start.sh

# 7(rwx) 5(r-x) 5(r-x) = 소유자 전체, 그룹·기타는 읽기·실행' WHERE quest_set_id = 10 AND order_index = 11;
UPDATE quest SET title='비밀번호 설정 파일 권한 제한하기 (chmod 600)', description='비밀번호가 담긴 파일을 다른 사용자가 읽을 수 있으면 보안 사고입니다. 소유자만 접근하게 줄입니다.

`/etc/myapp/secret.conf` 에 비밀번호가 담긴 설정 파일이 있습니다. **소유자만 읽고 쓸 수 있도록** 권한을 `600` 으로 바꾸세요.', hint='`chmod 600 <파일>` 입니다. 6 = 4+2(읽기+쓰기), 0 = 권한 없음. 자리 순서는 소유자·그룹·기타라서 그룹과 기타는 아무 권한이 없게 됩니다.', solution='chmod 600 /etc/myapp/secret.conf

# 6(rw-) 0(---) 0(---) : 소유자만 읽기·쓰기' WHERE quest_set_id = 10 AND order_index = 12;
