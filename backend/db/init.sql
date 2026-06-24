CREATE TABLE sandbox (
  type        VARCHAR(20) PRIMARY KEY,
  image       VARCHAR(100) NOT NULL,
  binds       JSON,
  description TEXT
);

CREATE TABLE quest_set (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  description  TEXT,
  sandbox_type VARCHAR(20) NOT NULL DEFAULT 'linux',
  FOREIGN KEY (sandbox_type) REFERENCES sandbox(type)
);

CREATE TABLE quest (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  quest_set_id INT NOT NULL,
  order_index  INT NOT NULL DEFAULT 0,
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL,
  hint         TEXT,
  solution     TEXT,
  setup_cmd    JSON,
  grade_cmd    JSON NOT NULL,
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);

INSERT INTO sandbox (type, image, binds, description) VALUES
  ('linux',     'ubuntu',      NULL, '기본 리눅스 환경. 파일 조작, 검색, 권한 등 일반 실습용.'),
  ('linux-ssh', 'etude-ssh',   NULL, 'SSH 데몬 포함 환경. curl, ping, scp, rsync 등 네트워크/파일 전송 실습용.'),
  ('docker',    'docker:dind', NULL, 'Docker-in-Docker 환경. 호스트와 격리된 독립 Docker 데몬. docker 명령어 실습용.'),
  ('k8s',       'etude-k8s',   NULL, 'kubectl 포함 환경. Kubernetes 실습용. (향후 추가)');

INSERT INTO quest_set (id, title, description, sandbox_type) VALUES
  (1, '리눅스 기초 1 — 파일 탐색과 생성', '현재 위치 확인, 디렉토리 이동, 파일/디렉토리 생성과 복사를 실습합니다.', 'linux'),
  (2, '리눅스 기초 2 — 삭제·검색·권한',  '파일 삭제, 내용 확인, 문자열 검색, 권한 변경, 링크 생성을 실습합니다.',  'linux'),
  (3, '리눅스 기초 3 — 프로세스와 시스템', '프로세스 확인/종료, 디스크/메모리 확인, 환경변수 설정을 실습합니다.', 'linux'),
  (4, '리눅스 네트워크/파일 전송',         'curl, ping, scp, rsync 등 네트워크 확인과 서버 간 파일 전송을 실습합니다.', 'linux-ssh'),
  (5, 'Docker 기초',                       '컨테이너 실행·중지·삭제, 이미지 관리, 로그 확인 등 Docker 기본 조작을 실습합니다.', 'docker');

-- 세트 1: 파일 탐색과 생성 (order 1~10)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (1,  1, '현재 위치 확인하기',
   '현재 작업 중인 디렉토리의 경로를 /tmp/pwd_result.txt 에 저장하세요.',
   'pwd 명령어와 리다이렉션(>)을 사용하세요.',
   'pwd > /tmp/pwd_result.txt',
   NULL,
   '["sh", "-c", "grep -q / /tmp/pwd_result.txt"]'),

  (1,  2, '디렉토리 이동하기',
   '/tmp 디렉토리로 이동한 뒤, 현재 위치를 /tmp/pwd_result.txt 에 저장하세요.',
   'cd로 이동 후 pwd > /tmp/pwd_result.txt 로 저장하세요.',
   'cd /tmp && pwd > /tmp/pwd_result.txt',
   NULL,
   '["sh", "-c", "grep -q /tmp /tmp/pwd_result.txt"]'),

  (1,  3, '파일 목록 확인하기',
   '/etc 디렉토리의 파일 목록을 /tmp/ls_result.txt 에 저장하세요.',
   'ls 명령어와 리다이렉션(>)을 사용하세요.',
   'ls /etc > /tmp/ls_result.txt',
   NULL,
   '["sh", "-c", "grep -q passwd /tmp/ls_result.txt"]'),

  (1,  4, '파일 상세 목록 확인하기',
   '/etc 디렉토리의 파일 목록을 숨김 파일 포함 상세하게 /tmp/ls_detail.txt 에 저장하세요.',
   'ls -al 명령어를 사용하세요. -a는 숨김 파일 포함, -l은 상세 출력입니다.',
   'ls -al /etc > /tmp/ls_detail.txt',
   NULL,
   '["sh", "-c", "grep -q ^total /tmp/ls_detail.txt"]'),

  (1,  5, '디렉토리 만들기',
   '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
   'mkdir 명령어를 사용하세요.',
   'mkdir /tmp/hello',
   NULL,
   '["test", "-d", "/tmp/hello"]'),

  (1,  6, '빈 파일 만들기',
   '/tmp/empty.txt 라는 이름의 빈 파일을 만드세요.',
   'touch 명령어를 사용하세요.',
   'touch /tmp/empty.txt',
   NULL,
   '["test", "-f", "/tmp/empty.txt"]'),

  (1,  7, '파일에 내용 쓰기',
   '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
   'echo 명령어와 리다이렉션(>)을 사용하세요.',
   'echo "done" > /tmp/answer.txt',
   NULL,
   '["grep", "-q", "done", "/tmp/answer.txt"]'),

  (1,  8, '숨김 파일 만들기',
   '/tmp 경로에 .hidden 이라는 이름의 빈 파일을 만드세요.',
   'touch 명령어를 사용하세요. 파일명 앞에 .을 붙이면 숨김 파일이 됩니다.',
   'touch /tmp/.hidden',
   NULL,
   '["test", "-f", "/tmp/.hidden"]'),

  (1,  9, '파일 복사하기',
   '/tmp/answer.txt 파일을 /tmp/backup.txt 로 복사하세요.',
   'cp 명령어를 사용하세요.',
   'cp /tmp/answer.txt /tmp/backup.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["test", "-f", "/tmp/backup.txt"]'),

  (1, 10, '파일 이름 바꾸기',
   '/tmp/backup.txt 파일의 이름을 /tmp/renamed.txt 로 변경하세요.',
   'mv 명령어는 파일 이동뿐 아니라 이름 변경에도 사용됩니다.',
   'mv /tmp/backup.txt /tmp/renamed.txt',
   '["sh", "-c", "echo done > /tmp/backup.txt"]',
   '["test", "-f", "/tmp/renamed.txt"]');

-- 세트 2: 삭제·검색·권한 (order 1~10)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (2,  1, '파일 삭제하기',
   '/tmp/renamed.txt 파일을 삭제하세요.',
   'rm 명령어를 사용하세요.',
   'rm /tmp/renamed.txt',
   '["touch", "/tmp/renamed.txt"]',
   '["sh", "-c", "test ! -f /tmp/renamed.txt"]'),

  (2,  2, '디렉토리 삭제하기',
   '/tmp/hello 디렉토리를 삭제하세요.',
   'rm -r 옵션을 사용하면 디렉토리를 삭제할 수 있습니다.',
   'rm -r /tmp/hello',
   '["mkdir", "/tmp/hello"]',
   '["sh", "-c", "test ! -d /tmp/hello"]'),

  (2,  3, '파일 내용 출력하기',
   '/tmp/answer.txt 파일의 내용을 /tmp/cat_result.txt 에 저장하세요.',
   'cat 명령어와 리다이렉션(>)을 사용하세요.',
   'cat /tmp/answer.txt > /tmp/cat_result.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["sh", "-c", "grep -q done /tmp/cat_result.txt"]'),

  (2,  4, '파일에서 문자열 검색하기',
   '/tmp/answer.txt 파일에서 "done" 문자열이 포함된 줄을 출력하세요.',
   'grep 명령어를 사용하세요.',
   'grep "done" /tmp/answer.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["grep", "-q", "done", "/tmp/answer.txt"]'),

  (2,  5, '여러 줄 파일 만들기',
   '/tmp/multiline.txt 파일을 만들고 첫 줄에 "line1", 둘째 줄에 "line2"를 입력하세요.',
   'printf 명령어를 사용하세요. printf "line1\nline2\n" > /tmp/multiline.txt',
   'printf "line1\nline2\n" > /tmp/multiline.txt',
   NULL,
   '["grep", "-q", "line2", "/tmp/multiline.txt"]'),

  (2,  6, '파일 실행 권한 부여하기',
   '/tmp/answer.txt 파일에 실행 권한을 추가하세요.',
   'chmod 명령어를 사용하세요. +x 옵션으로 실행 권한을 추가할 수 있습니다.',
   'chmod +x /tmp/answer.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["sh", "-c", "test -x /tmp/answer.txt"]'),

  (2,  7, '심볼릭 링크 만들기',
   '/tmp/answer.txt 를 가리키는 심볼릭 링크 /tmp/link.txt 를 만드세요.',
   'ln -s 명령어를 사용하세요.',
   'ln -s /tmp/answer.txt /tmp/link.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["sh", "-c", "test -L /tmp/link.txt"]'),

  (2,  8, '중첩 디렉토리 만들기',
   '/tmp/a/b/c 경로를 한 번에 만드세요.',
   'mkdir -p 옵션을 사용하면 중간 디렉토리를 한 번에 만들 수 있습니다.',
   'mkdir -p /tmp/a/b/c',
   NULL,
   '["test", "-d", "/tmp/a/b/c"]'),

  (2,  9, '파일 찾기',
   '/tmp 경로에서 .txt 확장자를 가진 파일을 모두 찾아 /tmp/find_result.txt 에 저장하세요.',
   'find 명령어와 리다이렉션(>)을 사용하세요. find /tmp -name "*.txt"',
   'find /tmp -name "*.txt" > /tmp/find_result.txt',
   '["sh", "-c", "echo done > /tmp/answer.txt"]',
   '["sh", "-c", "grep -q .txt /tmp/find_result.txt"]'),

  (2, 10, '디스크 사용량 확인하기',
   '/tmp 디렉토리의 전체 사용량을 /tmp/du_result.txt 에 저장하세요.',
   'du -sh 명령어와 리다이렉션(>)을 사용하세요.',
   'du -sh /tmp > /tmp/du_result.txt',
   NULL,
   '["sh", "-c", "grep -q /tmp /tmp/du_result.txt"]');

-- 세트 3: 프로세스와 시스템 (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (3,  1, '실행 중인 프로세스 확인하기',
   '현재 실행 중인 모든 프로세스 목록을 /tmp/ps_result.txt 에 저장하세요.',
   'ps aux 명령어와 리다이렉션(>)을 사용하세요.',
   'ps aux > /tmp/ps_result.txt',
   NULL,
   '["test", "-s", "/tmp/ps_result.txt"]'),

  (3,  2, '특정 프로세스 찾기',
   'ps 결과에서 "bash" 프로세스만 필터링해 /tmp/bash_proc.txt 에 저장하세요.',
   'ps aux | grep 형식으로 파이프를 사용하세요.',
   'ps aux | grep bash > /tmp/bash_proc.txt',
   NULL,
   '["sh", "-c", "grep -q bash /tmp/bash_proc.txt"]'),

  (3,  3, '백그라운드 프로세스 실행하기',
   'sleep 60 명령어를 백그라운드로 실행하고, PID를 /tmp/sleep_pid.txt 에 저장하세요.',
   '명령어 끝에 & 를 붙이면 백그라운드로 실행됩니다. echo $! 로 마지막 백그라운드 PID를 확인할 수 있습니다.',
   'sleep 60 & echo $! > /tmp/sleep_pid.txt',
   NULL,
   '["sh", "-c", "test -s /tmp/sleep_pid.txt"]'),

  (3,  4, '프로세스 종료하기',
   '/tmp/sleep_pid.txt 에 저장된 PID의 프로세스를 종료하세요.',
   'kill 명령어에 PID를 전달합니다. $(cat 파일) 로 파일 내용을 명령어 인자로 사용할 수 있습니다.',
   'kill $(cat /tmp/sleep_pid.txt)',
   '["sh", "-c", "sleep 60 & echo $! > /tmp/sleep_pid.txt"]',
   '["sh", "-c", "! kill -0 $(cat /tmp/sleep_pid.txt) 2>/dev/null"]'),

  (3,  5, '디스크 사용량 확인하기',
   '전체 디스크 사용량을 /tmp/df_result.txt 에 저장하세요.',
   'df -h 명령어를 사용하세요. -h 옵션은 사람이 읽기 쉬운 단위로 출력합니다.',
   'df -h > /tmp/df_result.txt',
   NULL,
   '["sh", "-c", "grep -q Filesystem /tmp/df_result.txt"]'),

  (3,  6, '메모리 사용량 확인하기',
   '현재 메모리 사용량을 /tmp/mem_result.txt 에 저장하세요.',
   'free -h 명령어를 사용하세요.',
   'free -h > /tmp/mem_result.txt',
   NULL,
   '["sh", "-c", "grep -q Mem /tmp/mem_result.txt"]'),

  (3,  7, '환경변수 설정하기',
   'MY_NAME 이라는 환경변수에 "etude" 값을 설정하고, 그 값을 /tmp/env_result.txt 에 저장하세요.',
   'export 명령어로 환경변수를 설정하고, echo $변수명 으로 값을 출력할 수 있습니다.',
   'export MY_NAME=etude
echo $MY_NAME > /tmp/env_result.txt',
   NULL,
   '["sh", "-c", "grep -q etude /tmp/env_result.txt"]'),

  (3,  8, '전체 환경변수 저장하기',
   '현재 설정된 모든 환경변수 목록을 /tmp/all_env.txt 에 저장하세요.',
   'env 또는 printenv 명령어를 사용하세요.',
   'env > /tmp/all_env.txt',
   NULL,
   '["sh", "-c", "grep -q PATH /tmp/all_env.txt"]');

-- 세트 4: 리눅스 네트워크/파일 전송 (order 1~7)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (4,  1, 'HTTP 요청 보내기',
   'curl 명령어로 http://example.com 에 GET 요청을 보내고 응답을 출력하세요.',
   'curl 명령어를 사용하세요.',
   'curl http://example.com',
   NULL,
   '["sh", "-c", "curl -s http://example.com | grep -q html"]'),

  (4,  2, '파일 다운로드하기',
   'curl 명령어로 http://example.com 의 내용을 /tmp/index.html 파일로 저장하세요.',
   'curl -o 옵션으로 저장할 파일명을 지정할 수 있습니다.',
   'curl -o /tmp/index.html http://example.com',
   NULL,
   '["test", "-f", "/tmp/index.html"]'),

  (4,  3, '네트워크 연결 확인하기',
   '8.8.8.8 주소로 ping을 3번만 보내고 결과를 확인하세요.',
   'ping -c 옵션으로 횟수를 지정할 수 있습니다.',
   'ping -c 3 8.8.8.8',
   NULL,
   '["sh", "-c", "ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo ok | grep -q ok"]'),

  (4,  4, '열린 포트 확인하기',
   '현재 수신 대기 중인 TCP 포트 목록을 확인하고, 결과를 /tmp/ports.txt 에 저장하세요.',
   'ss -tlnp 명령어를 사용하세요.',
   'ss -tlnp > /tmp/ports.txt',
   '["sh", "-c", "nginx &"]',
   '["sh", "-c", "grep -q :80 /tmp/ports.txt"]'),

  (4,  5, 'SSH로 원격 파일 복사하기',
   '/tmp/index.html 파일을 scp 명령어로 root@localhost:/tmp/remote_copy.html 에 복사하세요. (비밀번호: root)',
   'scp 파일경로 사용자@호스트:대상경로 형식으로 사용합니다. -o StrictHostKeyChecking=no 옵션으로 키 확인을 생략할 수 있습니다.',
   'scp -o StrictHostKeyChecking=no /tmp/index.html root@localhost:/tmp/remote_copy.html',
   '["sh", "-c", "/usr/sbin/sshd && curl -s -o /tmp/index.html http://example.com"]',
   '["test", "-f", "/tmp/remote_copy.html"]'),

  (4,  6, 'rsync로 원격 디렉토리 동기화하기',
   '/tmp/sync_src 디렉토리를 rsync로 root@localhost:/tmp/sync_dst 에 동기화하세요. (비밀번호: root)',
   'rsync -av -e "ssh -o StrictHostKeyChecking=no" /tmp/sync_src/ root@localhost:/tmp/sync_dst/ 형식으로 사용합니다.',
   'rsync -av -e "ssh -o StrictHostKeyChecking=no" /tmp/sync_src/ root@localhost:/tmp/sync_dst/',
   '["sh", "-c", "/usr/sbin/sshd && mkdir -p /tmp/sync_src && touch /tmp/sync_src/file.txt"]',
   '["test", "-f", "/tmp/sync_dst/file.txt"]'),

  (4,  7, '원격 명령 실행 결과 저장하기',
   'ssh로 root@localhost에 접속해 hostname 명령어를 실행하고 결과를 /tmp/hostname.txt 에 저장하세요. (비밀번호: root)',
   'ssh -o StrictHostKeyChecking=no 사용자@호스트 명령어 형식으로 원격 명령을 실행할 수 있습니다.',
   'ssh -o StrictHostKeyChecking=no root@localhost hostname > /tmp/hostname.txt',
   '["sh", "-c", "/usr/sbin/sshd"]',
   '["test", "-s", "/tmp/hostname.txt"]');

-- 세트 5: Docker 기초 (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (5,  1, '로컬 이미지 목록 확인하기',
   'Docker에 저장된 이미지 목록을 확인하고, 결과를 /tmp/images.txt 에 저장하세요.',
   'docker images 명령어를 사용하세요.',
   'docker images > /tmp/images.txt',
   NULL,
   '["test", "-f", "/tmp/images.txt"]'),

  (5,  2, '이미지 받아오기',
   'Docker Hub에서 hello-world 이미지를 받아오세요.',
   'docker pull 명령어를 사용하세요.',
   'docker pull hello-world',
   NULL,
   '["sh", "-c", "docker images hello-world | grep -q hello-world"]'),

  (5,  3, '컨테이너 실행하기',
   'hello-world 이미지로 컨테이너를 실행하세요.',
   'docker run 명령어를 사용하세요.',
   'docker run hello-world',
   NULL,
   '["sh", "-c", "docker ps -a | grep -q hello-world"]'),

  (5,  4, '백그라운드 컨테이너 실행하기',
   'nginx 이미지를 백그라운드로 실행하고 이름을 my-nginx 로 지정하세요.',
   'docker run -d --name 옵션을 사용하세요.',
   'docker run -d --name my-nginx nginx',
   NULL,
   '["sh", "-c", "docker ps | grep -q my-nginx"]'),

  (5,  5, '실행 중인 컨테이너 목록 저장하기',
   '현재 실행 중인 컨테이너 목록을 /tmp/containers.txt 에 저장하세요.',
   'docker ps 명령어를 사용하세요.',
   'docker ps > /tmp/containers.txt',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["test", "-s", "/tmp/containers.txt"]'),

  (5,  6, '컨테이너 로그 확인하기',
   'my-nginx 컨테이너의 로그를 확인하고 결과를 /tmp/nginx_logs.txt 에 저장하세요.',
   'docker logs 명령어를 사용하세요.',
   'docker logs my-nginx > /tmp/nginx_logs.txt 2>&1',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["test", "-f", "/tmp/nginx_logs.txt"]'),

  (5,  7, '컨테이너 중지하기',
   'my-nginx 컨테이너를 중지하세요.',
   'docker stop 명령어를 사용하세요.',
   'docker stop my-nginx',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["sh", "-c", "docker ps | grep -qv my-nginx"]'),

  (5,  8, '컨테이너 삭제하고 결과 저장하기',
   'my-nginx 컨테이너를 삭제한 뒤, 전체 컨테이너 목록(중지 포함)을 /tmp/final.txt 에 저장하세요.',
   'docker rm으로 삭제 후 docker ps -a > /tmp/final.txt 로 저장하세요.',
   'docker rm my-nginx
docker ps -a > /tmp/final.txt',
   '["sh", "-c", "docker run -d --name my-nginx nginx && docker stop my-nginx"]',
   '["sh", "-c", "test -s /tmp/final.txt && ! grep -q my-nginx /tmp/final.txt"]');
