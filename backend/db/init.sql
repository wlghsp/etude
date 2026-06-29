CREATE TABLE sandbox (
  type        VARCHAR(20) PRIMARY KEY,
  image       VARCHAR(100) NOT NULL,
  binds       JSON,
  persistent  BOOLEAN NOT NULL DEFAULT FALSE,
  description TEXT
);

CREATE TABLE quest_set (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  description  TEXT,
  sandbox_type VARCHAR(20) NOT NULL DEFAULT 'linux',
  category     VARCHAR(50) NOT NULL DEFAULT '기타',
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

INSERT INTO sandbox (type, image, binds, persistent, description) VALUES
  ('linux',             'ubuntu',      NULL,                                               FALSE, '기본 리눅스 환경. 파일 조작, 검색, 권한 등 일반 실습용.'),
  ('linux-ssh',         'etude-ssh',   NULL,                                               FALSE, 'SSH 데몬 포함 환경. curl, ping, scp, rsync 등 네트워크/파일 전송 실습용.'),
  ('docker',            'docker:dind', NULL,                                               FALSE, 'Docker-in-Docker 환경. 호스트와 격리된 독립 Docker 데몬. docker 명령어 실습용.'),
  ('docker-persistent', 'docker:dind', NULL,                                               TRUE,  'Docker-in-Docker 환경 (persistent). 퀘스트를 넘겨도 동일 컨테이너 유지. 이미지 반입 등 상태가 이어지는 실습용.'),
  ('k8s',               'etude-k8s',   '["{KUBECONFIG_HOST_PATH}:/root/.kube/config:ro"]', FALSE, 'kubectl 실습 환경. k3d 로컬 클러스터 연결.');

INSERT INTO quest_set (id, title, description, sandbox_type, category) VALUES
  (1, '리눅스 기초 1 — 파일 탐색과 생성', '현재 위치 확인, 디렉토리 이동, 파일/디렉토리 생성과 복사를 실습합니다.', 'linux',             '리눅스'),
  (2, '리눅스 기초 2 — 삭제·검색·권한',  '파일 삭제, 내용 확인, 문자열 검색, 권한 변경, 링크 생성을 실습합니다.',  'linux',             '리눅스'),
  (3, '리눅스 기초 3 — 프로세스와 시스템', '프로세스 확인/종료, 디스크/메모리 확인, 환경변수 설정을 실습합니다.', 'linux',             '리눅스'),
  (4, '리눅스 네트워크/파일 전송',         'curl, ping, scp, rsync 등 네트워크 확인과 서버 간 파일 전송을 실습합니다.', 'linux-ssh',      '리눅스'),
  (5, 'Docker 기초',                       '컨테이너 실행·중지·삭제, 이미지 관리, 로그 확인 등 Docker 기본 조작을 실습합니다.', 'docker',    '도커'),
  (6, 'k8s 기초',                          'kubectl로 Pod, Deployment, Service를 직접 조작해봅니다.', 'k8s',                           'k8s'),
  (7, '리눅스 압축과 아카이브',            'tar, gzip, zip 등 압축/아카이브 명령어를 실습합니다. 오프라인 패키지 반입의 기초입니다.', 'linux', '리눅스'),
  (8, 'Docker 이미지 오프라인 반입',       'tar 파일로 이미지를 save/load하고 로컬 레지스트리에 push하는 현장 패턴을 실습합니다.', 'docker-persistent', '도커'),
  (9, 'Vim 기초',                          '현장에서 가장 자주 막히는 Vim 편집 패턴을 실습합니다. 열고 저장하는 것부터 설정 파일 수정까지.', 'linux', '리눅스'),
  (10, '리눅스 현장 운영',                 'systemd, rpm, 환경변수, 방화벽 등 실제 서버 운영에서 반드시 쓰는 명령어를 실습합니다.', 'linux', '리눅스'),
  (11, 'Docker 이미지 빌드',              'Dockerfile 작성부터 이미지 빌드, 태깅까지 이미지를 직접 만드는 과정을 실습합니다.', 'docker', '도커'),
  (12, 'k8s ConfigMap과 Secret',          'ConfigMap과 Secret을 생성하고 Pod에 환경변수와 볼륨으로 주입하는 패턴을 실습합니다.', 'k8s', 'k8s'),
  (13, 'k8s 스토리지와 네트워크',         'PersistentVolume/PVC로 데이터를 영속 저장하고 port-forward로 클러스터 내부 서비스에 접근하는 패턴을 실습합니다.', 'k8s', 'k8s'),
  (14, 'Helm 기초',                        'Helm으로 차트를 설치하고 값을 커스터마이징하는 현장 패턴을 실습합니다. repo 추가부터 업그레이드·롤백까지.', 'k8s', 'k8s');

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
   '["sh", "-c", "docker pull hello-world"]',
   '["sh", "-c", "grep -q hello-world /tmp/images.txt"]'),

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
   '["sh", "-c", "test -s /tmp/final.txt && ! grep -q my-nginx /tmp/final.txt"]'),

  (5,  9, '실행 중인 컨테이너 안으로 들어가기',
   'my-nginx 컨테이너 안에서 bash 셸을 실행하고, /usr/share/nginx/html/index.html 파일이 존재하는지 확인한 뒤 /tmp/exec_result.txt 에 저장하세요.',
   'docker exec -it <컨테이너명> bash 로 컨테이너 안으로 들어갈 수 있습니다. 컨테이너 밖에서 docker exec <컨테이너명> <명령어> 로도 실행 가능합니다.',
   'docker exec my-nginx ls /usr/share/nginx/html/index.html > /tmp/exec_result.txt',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["sh", "-c", "grep -q ''index.html'' /tmp/exec_result.txt"]'),

  (5, 10, '포트 바인딩으로 컨테이너 실행하기',
   'nginx 컨테이너를 호스트 8080 포트와 컨테이너 80 포트를 연결해서 실행하세요. 컨테이너 이름은 port-nginx 로 지정하세요.',
   'docker run -p <호스트포트>:<컨테이너포트> 형식을 사용하세요.',
   'docker run -d -p 8080:80 --name port-nginx nginx',
   NULL,
   '["sh", "-c", "docker ps | grep port-nginx | grep -q ''0.0.0.0:8080''"]'),

  (5, 11, '환경변수 주입해서 컨테이너 실행하기',
   'ubuntu 컨테이너를 MY_ENV=hello 환경변수를 주입해서 실행하고, 컨테이너 안에서 해당 변수를 출력한 결과를 /tmp/env_result.txt 에 저장하세요.',
   'docker run -e <변수명>=<값> 으로 환경변수를 주입합니다. docker exec로 컨테이너 안에서 printenv 를 실행할 수 있습니다.',
   'docker run -d --name env-test -e MY_ENV=hello ubuntu sleep 60 && docker exec env-test printenv MY_ENV > /tmp/env_result.txt',
   NULL,
   '["sh", "-c", "grep -q ''hello'' /tmp/env_result.txt"]'),

  (5, 12, '볼륨 마운트해서 컨테이너 실행하기',
   '/tmp/webroot 디렉토리를 만들고 index.html 을 생성한 뒤, nginx 컨테이너의 /usr/share/nginx/html 에 마운트해서 실행하세요.',
   'docker run -v <호스트경로>:<컨테이너경로> 형식으로 마운트합니다.',
   'mkdir -p /tmp/webroot && echo "hello" > /tmp/webroot/index.html && docker run -d -v /tmp/webroot:/usr/share/nginx/html --name vol-nginx nginx',
   NULL,
   '["sh", "-c", "docker ps | grep -q vol-nginx && docker exec vol-nginx cat /usr/share/nginx/html/index.html | grep -q hello"]'),

  (5, 13, '컨테이너 상세 정보 확인하기',
   'my-nginx 컨테이너의 상세 정보를 확인하고 IP 주소를 /tmp/inspect.txt 에 저장하세요.',
   'docker inspect <컨테이너명> 으로 상세 정보를 확인할 수 있습니다. grep IPAddress 로 IP만 추출할 수 있어요.',
   'docker run -d --name my-nginx nginx && docker inspect my-nginx | grep IPAddress > /tmp/inspect.txt',
   NULL,
   '["sh", "-c", "grep -q ''IPAddress'' /tmp/inspect.txt"]');

-- 세트 6: k8s 기초 (order 1~10)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (6,  1, '클러스터 노드 확인하기',
   '현재 클러스터에 어떤 노드가 있는지 확인하세요.',
   'kubectl get nodes 명령어를 사용하세요.',
   'kubectl get nodes',
   NULL,
   '["sh", "-c", "kubectl get nodes | grep -i ready"]'),

  (6,  2, '네임스페이스 목록 확인하기',
   '클러스터에 존재하는 네임스페이스 목록을 확인하세요.',
   'kubectl get namespaces 또는 kubectl get ns',
   'kubectl get namespaces',
   NULL,
   '["sh", "-c", "kubectl get ns | grep quest-"]'),

  (6,  3, 'Pod 실행하기',
   '$NS 네임스페이스에 nginx 이미지로 nginx라는 이름의 Pod를 실행하세요.',
   'kubectl run <name> --image=<image> -n <namespace>',
   'kubectl run nginx --image=nginx -n $NS',
   NULL,
   '["sh", "-c", "kubectl get pod nginx -n $NS 2>/dev/null | grep -E ''Running|ContainerCreating''"]'),

  (6,  4, 'Pod 목록 확인하기',
   '$NS 네임스페이스의 Pod 목록을 확인하세요.',
   'kubectl get pods -n <namespace>',
   'kubectl get pods -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pods -n $NS | grep nginx"]'),

  (6,  5, 'Pod 로그 확인하기',
   '$NS 네임스페이스의 nginx Pod 로그를 확인하세요.',
   'kubectl logs <pod-name> -n <namespace>',
   'kubectl logs nginx -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; kubectl wait --for=condition=ready pod/nginx -n $NS --timeout=30s 2>/dev/null; true"]',
   '["sh", "-c", "kubectl logs nginx -n $NS 2>/dev/null; exit 0"]'),

  (6,  6, 'Pod 삭제하기',
   '$NS 네임스페이스의 nginx Pod를 삭제하세요.',
   'kubectl delete pod <name> -n <namespace>',
   'kubectl delete pod nginx -n $NS',
   '["sh", "-c", "kubectl run nginx --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "! kubectl get pod nginx -n $NS 2>/dev/null | grep -q nginx"]'),

  (6,  7, 'Deployment 생성하기',
   '$NS 네임스페이스에 nginx 이미지로 my-app이라는 Deployment를 생성하세요.',
   'kubectl create deployment <name> --image=<image> -n <namespace>',
   'kubectl create deployment my-app --image=nginx -n $NS',
   NULL,
   '["sh", "-c", "kubectl get deploy my-app -n $NS | grep my-app"]'),

  (6,  8, 'Deployment 스케일 조정하기',
   '$NS 네임스페이스의 my-app Deployment를 3개로 스케일 아웃하세요.',
   'kubectl scale deployment <name> --replicas=<n> -n <namespace>',
   'kubectl scale deployment my-app --replicas=3 -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get deploy my-app -n $NS | grep -E ''3/3|3 ''"]'),

  (6,  9, 'Service 생성하기',
   '$NS 네임스페이스의 my-app Deployment를 포트 80으로 노출하는 Service를 생성하세요.',
   'kubectl expose deployment <name> --port=<port> -n <namespace>',
   'kubectl expose deployment my-app --port=80 -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get svc my-app -n $NS | grep my-app"]'),

  (6, 10, '리소스 전체 확인하기',
   '$NS 네임스페이스의 모든 리소스를 한 번에 확인하세요.',
   'kubectl get all -n <namespace>',
   'kubectl get all -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; kubectl expose deployment my-app --port=80 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get all -n $NS | grep -c my-app | xargs -I{} test {} -ge 2"]'),

  (6, 11, 'YAML 파일로 Pod 생성하기',
   '/tmp/pod.yaml 파일을 작성해서 $NS 네임스페이스에 nginx Pod를 생성하세요. Pod 이름은 yaml-pod 로 지정하세요.',
   'kubectl apply -f <파일> 로 yaml 파일을 적용합니다. apiVersion: v1 / kind: Pod 로 시작하는 yaml을 작성하세요.',
   'cat > /tmp/pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: yaml-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
EOF
kubectl apply -f /tmp/pod.yaml',
   NULL,
   '["sh", "-c", "kubectl get pod yaml-pod -n $NS | grep -q yaml-pod"]'),

  (6, 12, 'Pod 안에서 명령어 실행하기',
   '$NS 네임스페이스의 yaml-pod Pod 안에서 nginx -v 명령어를 실행하고 결과를 /tmp/exec_result.txt 에 저장하세요.',
   'kubectl exec <pod명> -n <namespace> -- <명령어> 형식을 사용합니다.',
   'kubectl exec yaml-pod -n $NS -- nginx -v > /tmp/exec_result.txt 2>&1',
   '["sh", "-c", "kubectl run yaml-pod --image=nginx -n $NS 2>/dev/null; kubectl wait pod/yaml-pod -n $NS --for=condition=Ready --timeout=60s 2>/dev/null; true"]',
   '["sh", "-c", "grep -qi ''nginx'' /tmp/exec_result.txt"]'),

  (6, 13, 'Deployment 롤링 업데이트하기',
   '$NS 네임스페이스의 my-app Deployment 이미지를 nginx:alpine 으로 업데이트하세요.',
   'kubectl set image deployment/<name> <container명>=<새이미지> -n <namespace> 를 사용합니다.',
   'kubectl set image deployment/my-app my-app=nginx:alpine -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get deployment my-app -n $NS -o jsonpath=''{.spec.template.spec.containers[0].image}'' | grep -q alpine"]'),

  (6, 14, 'Deployment 롤백하기',
   '$NS 네임스페이스의 my-app Deployment를 이전 버전으로 롤백하세요.',
   'kubectl rollout undo deployment/<name> -n <namespace> 를 사용합니다.',
   'kubectl rollout undo deployment/my-app -n $NS',
   '["sh", "-c", "kubectl create deployment my-app --image=nginx -n $NS 2>/dev/null; kubectl set image deployment/my-app my-app=nginx:alpine -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl rollout history deployment/my-app -n $NS | grep -q ''2\\|3''"]');

-- 세트 7: 리눅스 압축과 아카이브 (order 1~9)
-- 실무 조합: -cvf, -tvf, -xvf, -czvf, -xzvf 중심
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (7,  1, 'tar로 파일 묶기 (-cvf)',
   '/tmp/files 디렉토리를 tar로 묶어 /tmp/files.tar 로 저장하세요. 묶이는 파일 목록이 출력되어야 합니다.',
   'tar -cvf <출력파일> <대상> 형식을 사용하세요. c=생성, v=목록출력, f=파일명 지정. "tar: Removing leading /" 메시지가 출력되어도 정상입니다.',
   'tar -cvf /tmp/files.tar /tmp/files',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && echo world > /tmp/files/b.txt"]',
   '["sh", "-c", "tar -tf /tmp/files.tar | grep -q a.txt"]'),

  (7,  2, 'tar 아카이브 내용 확인하기 (-tvf)',
   '/tmp/files.tar 아카이브에 어떤 파일이 들어있는지 목록을 확인하세요.',
   'tar -tvf 옵션을 사용하세요. t=목록확인, v=상세출력(권한/날짜 포함), f=파일명 지정.',
   'tar -tvf /tmp/files.tar',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -cf /tmp/files.tar /tmp/files"]',
   '["sh", "-c", "tar -tf /tmp/files.tar | grep -q files"]'),

  (7,  3, 'tar 해제하기 (-xvf)',
   '/tmp/files.tar 를 /tmp/extract 디렉토리에 압축 해제하세요. 해제되는 파일 목록이 출력되어야 합니다.',
   'tar -xvf <파일> -C <대상 디렉토리> 형식을 사용하세요. x=해제, v=목록출력, f=파일명 지정. 대상 디렉토리는 먼저 만들어야 합니다.',
   'mkdir -p /tmp/extract && tar -xvf /tmp/files.tar -C /tmp/extract',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -cf /tmp/files.tar /tmp/files"]',
   '["sh", "-c", "find /tmp/extract -name a.txt | grep -q a.txt"]'),

  (7,  4, 'tar.gz 한 번에 만들기 (-czvf)',
   '/tmp/files 디렉토리를 gzip 압축까지 적용해 /tmp/archive.tar.gz 로 만드세요. 묶이는 파일 목록이 출력되어야 합니다.',
   'tar -czvf <출력파일> <대상> 형식을 사용하세요. z=gzip 압축 추가. 현장에서 가장 많이 쓰는 조합입니다.',
   'tar -czvf /tmp/archive.tar.gz /tmp/files',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && echo world > /tmp/files/b.txt"]',
   '["sh", "-c", "tar -tzf /tmp/archive.tar.gz | grep -q a.txt"]'),

  (7,  5, 'tar.gz 내용 확인하기 (-tzvf)',
   '/tmp/archive.tar.gz 아카이브의 내용을 확인하세요.',
   'tar -tzvf 옵션을 사용하세요. z 옵션이 있어야 .gz 파일을 읽을 수 있습니다.',
   'tar -tzvf /tmp/archive.tar.gz',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -czvf /tmp/archive.tar.gz /tmp/files"]',
   '["sh", "-c", "tar -tzf /tmp/archive.tar.gz | grep -q files"]'),

  (7,  6, 'tar.gz 압축 해제하기 (-xzvf)',
   '/tmp/archive.tar.gz 를 /tmp/extract 디렉토리에 압축 해제하세요. 해제되는 파일 목록이 출력되어야 합니다.',
   'tar -xzvf <파일> -C <대상 디렉토리> 형식을 사용하세요.',
   'mkdir -p /tmp/extract && tar -xzvf /tmp/archive.tar.gz -C /tmp/extract',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -czvf /tmp/archive.tar.gz /tmp/files"]',
   '["sh", "-c", "find /tmp/extract -name a.txt | grep -q a.txt"]'),

  (7,  7, 'zip으로 압축하기',
   '/tmp/files 디렉토리를 zip으로 압축해 /tmp/files.zip 으로 만드세요.',
   'zip -r <출력파일> <대상> 형식을 사용하세요. -r은 디렉토리를 재귀적으로 포함합니다.',
   'zip -r /tmp/files.zip /tmp/files',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && echo world > /tmp/files/b.txt"]',
   '["sh", "-c", "unzip -l /tmp/files.zip | grep -q a.txt"]'),

  (7,  8, 'unzip으로 압축 해제하기',
   '/tmp/files.zip 을 /tmp/unzipped 디렉토리에 압축 해제하세요.',
   'unzip <파일> -d <대상 디렉토리> 형식을 사용하세요.',
   'unzip /tmp/files.zip -d /tmp/unzipped',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && zip -r /tmp/files.zip /tmp/files"]',
   '["sh", "-c", "find /tmp/unzipped -name a.txt | grep -q a.txt"]'),

  (7,  9, '압축 파일 크기 비교하기',
   '/tmp/files 디렉토리를 tar.gz와 zip 두 가지로 압축한 뒤, 두 파일의 크기를 확인하고 결과를 /tmp/size_compare.txt 에 저장하세요.',
   'tar -czvf로 tar.gz를, zip -r로 zip을 만든 뒤 ls -lh 로 크기를 비교하세요.',
   'tar -czvf /tmp/compare.tar.gz /tmp/files && zip -r /tmp/compare.zip /tmp/files && ls -lh /tmp/compare.tar.gz /tmp/compare.zip > /tmp/size_compare.txt',
   '["sh", "-c", "mkdir -p /tmp/files && for i in $(seq 1 10); do echo content$i > /tmp/files/file$i.txt; done"]',
   '["sh", "-c", "grep -q compare /tmp/size_compare.txt"]');

-- 세트 8: Docker 이미지 오프라인 반입 (order 1~7)
-- persistent sandbox — 퀘스트를 넘겨도 동일 컨테이너 유지
-- setup_cmd 없음 (재마운트가 없으므로 실행 타이밍이 없음)
-- 실습 흐름: pull → save → load → tag → push → deploy → 확인
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (8,  1, '이미지 tar 파일로 저장하기 (save)',
   'alpine 이미지를 pull한 뒤 /tmp/alpine.tar 파일로 저장하세요. 현장에서 인터넷 연결 없이 이미지를 반입할 때 사용하는 첫 번째 단계입니다.',
   'docker pull alpine 후 docker save -o <파일> <이미지> 형식을 사용하세요.',
   'docker pull alpine && docker save -o /tmp/alpine.tar alpine',
   NULL,
   '["sh", "-c", "test -f /tmp/alpine.tar"]'),

  (8,  2, '로컬 이미지 삭제하기',
   'alpine 이미지를 로컬에서 삭제하세요. 다음 퀘스트에서 tar 파일로 다시 불러오는 실습을 위한 준비입니다.',
   'docker rmi 명령어를 사용하세요.',
   'docker rmi alpine',
   NULL,
   '["sh", "-c", "! docker images alpine | grep -q alpine"]'),

  (8,  3, 'tar 파일에서 이미지 불러오기 (load)',
   '/tmp/alpine.tar 파일에서 이미지를 불러오세요. 이것이 실제 현장에서 반입한 tar 파일을 서버에 올리는 단계입니다.',
   'docker load -i <파일> 형식을 사용하세요.',
   'docker load -i /tmp/alpine.tar',
   NULL,
   '["sh", "-c", "docker images alpine | grep -q alpine"]'),

  (8,  4, '로컬 레지스트리 실행하기',
   'Docker 공식 registry 이미지로 로컬 레지스트리를 포트 5000으로 실행하세요. 현장에서는 Nexus나 Harbor 같은 내부 레지스트리가 이 역할을 합니다.',
   'docker run -d -p 5000:5000 --name registry registry:2',
   'docker run -d -p 5000:5000 --name registry registry:2',
   NULL,
   '["sh", "-c", "docker ps | grep -q registry"]'),

  (8,  5, '이미지 태깅하기',
   'alpine 이미지에 로컬 레지스트리 주소를 포함한 태그를 붙이세요: localhost:5000/alpine:latest',
   'docker tag <원본이미지> <새태그> 형식을 사용하세요.',
   'docker tag alpine localhost:5000/alpine:latest',
   NULL,
   '["sh", "-c", "docker images localhost:5000/alpine | grep -q alpine"]'),

  (8,  6, '레지스트리에 이미지 올리기 (push)',
   'localhost:5000/alpine:latest 이미지를 로컬 레지스트리에 push하세요.',
   'docker push <이미지> 형식을 사용하세요.',
   'docker push localhost:5000/alpine:latest',
   NULL,
   '["sh", "-c", "curl -s http://localhost:5000/v2/alpine/tags/list | grep -q latest"]'),

  (8,  7, '레지스트리에서 이미지 받아 컨테이너 실행하기',
   '로컬 레지스트리(localhost:5000)에서 alpine 이미지를 받아 echo hello 명령어를 실행하세요. 이것이 실제 배포 환경에서 내부 레지스트리 이미지를 사용하는 패턴입니다.',
   'docker run localhost:5000/alpine:latest echo hello',
   'docker run localhost:5000/alpine:latest echo hello',
   NULL,
   '["sh", "-c", "docker images localhost:5000/alpine | grep -q alpine"]');

-- 세트 9: Vim 기초 (order 1~12)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (9,  1, 'Vim으로 파일 열고 저장하기',
   '/tmp/hello.txt 파일을 vim으로 열어 첫 줄에 "hello vim" 을 입력하고 저장 후 종료하세요.',
   'i 키로 입력 모드 진입 → 텍스트 입력 → ESC → :wq',
   'vim /tmp/hello.txt 후 i → hello vim → ESC → :wq',
   NULL,
   '["sh", "-c", "grep -q ''hello vim'' /tmp/hello.txt"]'),

  (9,  2, '저장 없이 Vim 종료하기',
   '/tmp/test.txt 를 vim으로 열어 아무 내용이나 입력한 뒤, 저장하지 않고 종료하세요. 그 다음 파일이 비어있는지 확인하세요.',
   'ESC → :q! 로 저장 없이 강제 종료합니다.',
   'vim /tmp/test.txt 후 i → 내용 입력 → ESC → :q!',
   '["sh", "-c", "touch /tmp/test.txt"]',
   '["sh", "-c", "! grep -q . /tmp/test.txt"]'),

  (9,  3, '특정 줄 번호로 이동하기',
   '/tmp/lines.txt 파일의 5번째 줄 내용을 /tmp/result.txt 에 저장하세요. vim에서 줄 번호로 이동한 뒤 해당 줄을 확인하세요.',
   'vim에서 :5 를 입력하면 5번째 줄로 이동합니다. sed -n ''5p'' 로도 확인할 수 있습니다.',
   'sed -n ''5p'' /tmp/lines.txt > /tmp/result.txt',
   '["sh", "-c", "printf ''line1\\nline2\\nline3\\nline4\\nline5\\nline6\\n'' > /tmp/lines.txt"]',
   '["sh", "-c", "grep -q ''line5'' /tmp/result.txt"]'),

  (9,  4, '단어 검색하기',
   '/tmp/config.txt 에서 "port" 라는 단어를 vim으로 검색하고, 검색된 줄 번호를 /tmp/result.txt 에 저장하세요.',
   'vim에서 /port 로 검색합니다. grep -n 으로도 줄 번호를 확인할 수 있습니다.',
   'grep -n "port" /tmp/config.txt > /tmp/result.txt',
   '["sh", "-c", "printf ''host=localhost\\nport=8080\\nuser=admin\\n'' > /tmp/config.txt"]',
   '["sh", "-c", "grep -q ''2'' /tmp/result.txt"]'),

  (9,  5, '줄 삭제하기 (dd)',
   '/tmp/remove.txt 의 2번째 줄을 vim에서 dd 명령으로 삭제하고 저장하세요.',
   'vim에서 :2 로 이동 후 dd 로 줄을 삭제합니다.',
   'vim /tmp/remove.txt 후 :2 → dd → :wq',
   '["sh", "-c", "printf ''keep\\ndelete_me\\nkeep2\\n'' > /tmp/remove.txt"]',
   '["sh", "-c", "! grep -q ''delete_me'' /tmp/remove.txt"]'),

  (9,  6, '줄 복사 붙여넣기 (yy, p)',
   '/tmp/copy.txt 의 1번째 줄을 복사해서 파일 끝에 붙여넣고 저장하세요. 파일은 총 3줄이 되어야 합니다.',
   'vim에서 gg 로 첫 줄 이동 → yy 로 복사 → G 로 끝으로 이동 → p 로 붙여넣기',
   'vim /tmp/copy.txt 후 gg → yy → G → p → :wq',
   '["sh", "-c", "printf ''hello\\nworld\\n'' > /tmp/copy.txt"]',
   '["sh", "-c", "[ $(wc -l < /tmp/copy.txt) -ge 3 ]"]'),

  (9,  7, '단어 치환하기 (:%s)',
   '/tmp/app.conf 에서 "localhost" 를 "192.168.1.10" 으로 전체 치환하고 저장하세요.',
   'vim에서 :%s/localhost/192.168.1.10/g 를 실행합니다.',
   'vim /tmp/app.conf 후 :%s/localhost/192.168.1.10/g → :wq',
   '["sh", "-c", "printf ''host=localhost\\nbackup=localhost\\n'' > /tmp/app.conf"]',
   '["sh", "-c", "grep -q ''192.168.1.10'' /tmp/app.conf && ! grep -q ''localhost'' /tmp/app.conf"]'),

  (9,  8, '비주얼 모드로 여러 줄 삭제하기',
   '/tmp/multi.txt 에서 2~4번째 줄을 vim 비주얼 모드(V)로 선택해 삭제하고 저장하세요.',
   'vim에서 :2 이동 → V 로 비주얼 라인 모드 → j j 로 선택 확장 → d 로 삭제',
   'vim /tmp/multi.txt 후 :2 → V → jj → d → :wq',
   '["sh", "-c", "printf ''line1\\nline2\\nline3\\nline4\\nline5\\n'' > /tmp/multi.txt"]',
   '["sh", "-c", "[ $(wc -l < /tmp/multi.txt) -eq 2 ]"]'),

  (9,  9, '단어 교체하기 (cw)',
   '/tmp/fix.txt 의 첫 줄에서 "error" 단어를 vim에서 cw 로 "info" 로 바꾸고 저장하세요.',
   'vim에서 /error 로 검색 후 커서를 단어 위에 두고 cw 입력 → info 입력 → ESC → :wq',
   'vim /tmp/fix.txt 후 /error → cw → info → ESC → :wq',
   '["sh", "-c", "printf ''level: error\\n'' > /tmp/fix.txt"]',
   '["sh", "-c", "grep -q ''info'' /tmp/fix.txt && ! grep -q ''error'' /tmp/fix.txt"]'),

  (9, 10, '줄 끝에 내용 추가하기 (A)',
   '/tmp/append.txt 의 첫 줄 끝에 " # managed by etude" 를 추가하고 저장하세요.',
   'vim에서 첫 줄로 이동 후 A 키를 누르면 줄 끝 입력 모드로 진입합니다.',
   'vim /tmp/append.txt 후 gg → A → " # managed by etude" → ESC → :wq',
   '["sh", "-c", "printf ''server_name localhost;\\n'' > /tmp/append.txt"]',
   '["sh", "-c", "grep -q ''managed by etude'' /tmp/append.txt"]'),

  (9, 11, '실행 취소와 다시 실행 (u, Ctrl+r)',
   '/tmp/undo.txt 를 vim으로 열어 내용을 수정했다가 u 로 되돌리고 저장하세요. 파일 내용이 원본과 같아야 합니다.',
   'vim에서 수정 후 ESC → u 로 실행 취소합니다.',
   'vim /tmp/undo.txt 후 수정 → ESC → u → :wq',
   '["sh", "-c", "printf ''original content\\n'' > /tmp/undo.txt"]',
   '["sh", "-c", "grep -q ''original content'' /tmp/undo.txt"]'),

  (9, 12, '읽기 전용 파일 수정 저장하기',
   '/tmp/readonly.txt 는 root 소유의 읽기 전용 파일입니다. vim으로 열어 "modified" 한 줄을 추가하고 :w !sudo tee % 로 저장하세요.',
   'vim에서 일반 :w 가 안 될 때 :w !sudo tee % 로 저장할 수 있습니다.',
   'vim /tmp/readonly.txt 후 G → o → modified → ESC → :w !sudo tee %',
   '["sh", "-c", "echo readonly_content > /tmp/readonly.txt && chmod 444 /tmp/readonly.txt"]',
   '["sh", "-c", "grep -q ''modified'' /tmp/readonly.txt"]');

-- 세트 10: 리눅스 현장 운영 (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (10, 1, 'systemd 서비스 상태 확인하기',
   'cron 서비스의 상태를 확인하고 결과를 /tmp/svc_status.txt 에 저장하세요.',
   'systemctl status <서비스명> 명령어를 사용하세요.',
   'systemctl status cron > /tmp/svc_status.txt 2>&1',
   '["sh", "-c", "apt-get install -y cron > /dev/null 2>&1"]',
   '["sh", "-c", "grep -qi ''cron'' /tmp/svc_status.txt"]'),

  (10, 2, 'systemd 서비스 시작하고 활성화하기',
   'cron 서비스를 시작하고 부팅 시 자동 시작되도록 활성화하세요.',
   'systemctl start 와 systemctl enable 을 사용하세요.',
   'systemctl start cron && systemctl enable cron',
   '["sh", "-c", "apt-get install -y cron > /dev/null 2>&1 && systemctl stop cron 2>/dev/null || true"]',
   '["sh", "-c", "systemctl is-active cron"]'),

  (10, 3, '환경변수 설정하기 (/etc/profile.d)',
   '/etc/profile.d/myapp.sh 파일을 만들어 APP_HOME=/opt/myapp 환경변수를 등록하세요.',
   'export APP_HOME=/opt/myapp 을 파일에 작성하면 됩니다.',
   'echo "export APP_HOME=/opt/myapp" > /etc/profile.d/myapp.sh',
   NULL,
   '["sh", "-c", "grep -q ''APP_HOME=/opt/myapp'' /etc/profile.d/myapp.sh"]'),

  (10, 4, '시스템 계정 생성하기',
   '서비스용 시스템 계정 "myservice" 를 생성하세요. 로그인 셸 없이 시스템 계정으로 만들어야 합니다.',
   'useradd -r -s /sbin/nologin <계정명> 을 사용하세요.',
   'useradd -r -s /sbin/nologin myservice',
   NULL,
   '["sh", "-c", "id myservice"]'),

  (10, 5, '/etc/hosts 에 호스트 등록하기',
   '/etc/hosts 에 "192.168.1.100 db.internal" 항목을 추가하세요.',
   'echo 로 /etc/hosts 에 추가하거나 vim으로 편집하세요.',
   'echo "192.168.1.100 db.internal" >> /etc/hosts',
   NULL,
   '["sh", "-c", "grep -q ''192.168.1.100 db.internal'' /etc/hosts"]'),

  (10, 6, '포트 사용 현황 확인하기',
   '현재 리스닝 중인 TCP 포트 목록을 /tmp/ports.txt 에 저장하세요.',
   'ss -tlnp 또는 netstat -tlnp 를 사용하세요.',
   'ss -tlnp > /tmp/ports.txt',
   NULL,
   '["sh", "-c", "grep -qi ''listen\\|LISTEN'' /tmp/ports.txt"]'),

  (10, 7, 'tar로 디렉토리 백업하기',
   '/etc 디렉토리를 /tmp/etc_backup.tar.gz 로 압축 백업하세요.',
   'tar -czf <출력파일> <대상디렉토리> 를 사용하세요.',
   'tar -czf /tmp/etc_backup.tar.gz /etc 2>/dev/null || true',
   NULL,
   '["sh", "-c", "test -f /tmp/etc_backup.tar.gz"]'),

  (10, 8, '바이너리 실행 파일 PATH 등록하기',
   '/opt/mytool/bin 디렉토리를 만들고 PATH에 추가되도록 /etc/profile.d/mytool.sh 를 작성하세요.',
   'export PATH=$PATH:/opt/mytool/bin 을 profile.d 파일에 작성하세요.',
   'mkdir -p /opt/mytool/bin && echo "export PATH=\$PATH:/opt/mytool/bin" > /etc/profile.d/mytool.sh',
   NULL,
   '["sh", "-c", "grep -q ''/opt/mytool/bin'' /etc/profile.d/mytool.sh"]'),

  (10, 9, '스크립트에 실행 권한 주기 (chmod +x)',
   '/opt/myapp/start.sh 파일에 실행 권한을 부여하세요.',
   'chmod +x <파일경로> 를 사용하세요.',
   'chmod +x /opt/myapp/start.sh',
   '["sh", "-c", "mkdir -p /opt/myapp && echo ''#!/bin/bash'' > /opt/myapp/start.sh"]',
   '["sh", "-c", "[ -x /opt/myapp/start.sh ]"]'),

  (10, 10, '디렉토리 소유권 변경하기 (chown)',
   'myservice 계정을 생성하고 /opt/myapp 디렉토리의 소유자를 myservice 로 변경하세요.',
   'useradd -r -s /sbin/nologin myservice 후 chown -R myservice:myservice /opt/myapp 을 사용하세요.',
   'useradd -r -s /sbin/nologin myservice 2>/dev/null || true && chown -R myservice:myservice /opt/myapp',
   '["sh", "-c", "mkdir -p /opt/myapp"]',
   '["sh", "-c", "[ $(stat -c %U /opt/myapp) = myservice ]"]'),

  (10, 11, '실행 파일 권한 755로 설정하기',
   '/opt/myapp/start.sh 파일 권한을 755 로 설정하세요. 소유자는 읽기/쓰기/실행, 그룹과 기타는 읽기/실행만 허용합니다.',
   'chmod 755 <파일경로> 를 사용하세요.',
   'chmod 755 /opt/myapp/start.sh',
   '["sh", "-c", "mkdir -p /opt/myapp && echo ''#!/bin/bash'' > /opt/myapp/start.sh && chmod 600 /opt/myapp/start.sh"]',
   '["sh", "-c", "[ $(stat -c %a /opt/myapp/start.sh) = 755 ]"]'),

  (10, 12, '설정 파일 권한 제한하기 (chmod 600)',
   '/etc/myapp/secret.conf 에 비밀번호가 담긴 설정 파일이 있습니다. 소유자만 읽고 쓸 수 있도록 권한을 600 으로 변경하세요.',
   'chmod 600 <파일경로> 를 사용하세요. 600 은 소유자만 읽기/쓰기 가능입니다.',
   'chmod 600 /etc/myapp/secret.conf',
   '["sh", "-c", "mkdir -p /etc/myapp && echo ''password=secret'' > /etc/myapp/secret.conf"]',
   '["sh", "-c", "[ $(stat -c %a /etc/myapp/secret.conf) = 600 ]"]');

-- 세트 11: Docker 이미지 빌드 (order 1~6)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (11, 1, 'Dockerfile 작성하기',
   '/tmp/myapp 디렉토리에 Dockerfile을 작성하세요. ubuntu 를 베이스 이미지로 하고, echo "hello" 를 실행하는 CMD를 포함해야 합니다.',
   'FROM <이미지> 로 베이스 이미지를 지정하고 CMD ["echo", "hello"] 로 기본 명령을 설정합니다.',
   'mkdir -p /tmp/myapp && printf ''FROM ubuntu\nCMD ["echo", "hello"]\n'' > /tmp/myapp/Dockerfile',
   NULL,
   '["sh", "-c", "grep -q ''FROM ubuntu'' /tmp/myapp/Dockerfile && grep -q ''CMD'' /tmp/myapp/Dockerfile"]'),

  (11, 2, 'Dockerfile로 이미지 빌드하기',
   '/tmp/myapp/Dockerfile 을 사용해서 my-app:1.0 이미지를 빌드하세요.',
   'docker build -t <이미지명>:<태그> <Dockerfile경로> 형식을 사용합니다.',
   'docker build -t my-app:1.0 /tmp/myapp',
   '["sh", "-c", "mkdir -p /tmp/myapp && printf ''FROM ubuntu\\nCMD [\\\"echo\\\", \\\"hello\\\"]\\n'' > /tmp/myapp/Dockerfile"]',
   '["sh", "-c", "docker images my-app | grep -q 1.0"]'),

  (11, 3, 'RUN으로 패키지 설치하기',
   '/tmp/myapp/Dockerfile 을 수정해서 curl 을 설치하는 RUN 레이어를 추가하고 이미지를 다시 빌드하세요. 이미지명은 my-app:2.0 으로 하세요.',
   'RUN apt-get update && apt-get install -y curl 을 Dockerfile에 추가합니다.',
   'printf ''FROM ubuntu\nRUN apt-get update && apt-get install -y curl\nCMD ["curl", "--version"]\n'' > /tmp/myapp/Dockerfile && docker build -t my-app:2.0 /tmp/myapp',
   '["sh", "-c", "mkdir -p /tmp/myapp"]',
   '["sh", "-c", "docker images my-app | grep -q 2.0"]'),

  (11, 4, 'COPY로 파일 이미지에 포함하기',
   '/tmp/myapp/index.html 을 만들고 Dockerfile에서 COPY 로 이미지 안의 /var/www/html/ 에 복사하도록 작성한 뒤 my-app:3.0 으로 빌드하세요.',
   'COPY <호스트경로> <컨테이너경로> 형식으로 파일을 이미지에 포함합니다.',
   'echo "<h1>hello</h1>" > /tmp/myapp/index.html && printf ''FROM ubuntu\nCOPY index.html /var/www/html/\n'' > /tmp/myapp/Dockerfile && docker build -t my-app:3.0 /tmp/myapp',
   '["sh", "-c", "mkdir -p /tmp/myapp"]',
   '["sh", "-c", "docker images my-app | grep -q 3.0 && docker run --rm my-app:3.0 cat /var/www/html/index.html | grep -q hello"]'),

  (11, 5, '이미지에 태그 추가하기',
   'my-app:3.0 이미지에 my-app:latest 태그를 추가하세요.',
   'docker tag <원본이미지> <새태그> 형식을 사용합니다.',
   'docker tag my-app:3.0 my-app:latest',
   '["sh", "-c", "mkdir -p /tmp/myapp && echo ''<h1>hello</h1>'' > /tmp/myapp/index.html && printf ''FROM ubuntu\\nCOPY index.html /var/www/html/\\n'' > /tmp/myapp/Dockerfile && docker build -t my-app:3.0 /tmp/myapp > /dev/null 2>&1"]',
   '["sh", "-c", "docker images my-app | grep -q latest"]'),

  (11, 6, '이미지로 컨테이너 실행하고 확인하기',
   'my-app:latest 이미지로 컨테이너를 실행해서 /var/www/html/index.html 내용을 출력하고 결과를 /tmp/run_result.txt 에 저장하세요.',
   'docker run --rm <이미지> <명령어> 로 컨테이너를 실행하고 바로 삭제합니다.',
   'docker run --rm my-app:latest cat /var/www/html/index.html > /tmp/run_result.txt',
   '["sh", "-c", "mkdir -p /tmp/myapp && echo ''<h1>hello</h1>'' > /tmp/myapp/index.html && printf ''FROM ubuntu\\nCOPY index.html /var/www/html/\\n'' > /tmp/myapp/Dockerfile && docker build -t my-app:latest /tmp/myapp > /dev/null 2>&1"]',
   '["sh", "-c", "grep -q ''hello'' /tmp/run_result.txt"]');

-- 세트 12: k8s ConfigMap과 Secret (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (12, 1, 'ConfigMap 생성하기',
   '$NS 네임스페이스에 app-config 이름의 ConfigMap을 생성하세요. APP_ENV=production, APP_PORT=8080 두 값을 포함해야 합니다.',
   'kubectl create configmap <name> --from-literal=<key>=<value> -n <namespace> 형식을 사용합니다.',
   'kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS',
   NULL,
   '["sh", "-c", "kubectl get configmap app-config -n $NS -o jsonpath=''{.data.APP_ENV}'' | grep -q production"]'),

  (12, 2, 'ConfigMap 내용 확인하기',
   '$NS 네임스페이스의 app-config ConfigMap 전체 내용을 확인하고 /tmp/cm_result.txt 에 저장하세요.',
   'kubectl get configmap <name> -n <namespace> -o yaml 로 전체 내용을 확인합니다.',
   'kubectl get configmap app-config -n $NS -o yaml > /tmp/cm_result.txt',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''APP_ENV'' /tmp/cm_result.txt"]'),

  (12, 3, 'ConfigMap을 환경변수로 Pod에 주입하기',
   'app-config ConfigMap의 값을 환경변수로 주입한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 cm-pod, 이미지는 nginx 로 하세요.',
   'envFrom.configMapRef 를 사용하면 ConfigMap 전체를 환경변수로 주입할 수 있습니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cm-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod cm-pod -n $NS | grep -q cm-pod"]'),

  (12, 4, 'ConfigMap을 볼륨으로 마운트하기',
   'app-config ConfigMap을 /etc/config 경로에 볼륨으로 마운트한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 cm-vol-pod 로 하세요.',
   'volumes.configMap 과 volumeMounts 를 함께 사용합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cm-vol-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod cm-vol-pod -n $NS | grep -q cm-vol-pod"]'),

  (12, 5, 'Secret 생성하기',
   '$NS 네임스페이스에 db-secret 이름의 Secret을 생성하세요. DB_USER=admin, DB_PASSWORD=s3cur3 두 값을 포함해야 합니다.',
   'kubectl create secret generic <name> --from-literal=<key>=<value> -n <namespace> 형식을 사용합니다. Secret은 base64로 인코딩되어 저장됩니다.',
   'kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS',
   NULL,
   '["sh", "-c", "kubectl get secret db-secret -n $NS | grep -q db-secret"]'),

  (12, 6, 'Secret 값 확인하기',
   '$NS 네임스페이스의 db-secret 에서 DB_USER 값을 디코딩해서 /tmp/secret_result.txt 에 저장하세요.',
   'kubectl get secret <name> -n <namespace> -o jsonpath=''{.data.DB_USER}'' 로 값을 꺼낸 뒤 base64 --decode 로 디코딩합니다.',
   'kubectl get secret db-secret -n $NS -o jsonpath=''{.data.DB_USER}'' | base64 --decode > /tmp/secret_result.txt',
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''admin'' /tmp/secret_result.txt"]'),

  (12, 7, 'Secret을 환경변수로 Pod에 주입하기',
   'db-secret 의 DB_USER, DB_PASSWORD 를 환경변수로 주입한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 secret-pod 로 하세요.',
   'env.valueFrom.secretKeyRef 를 사용해서 Secret의 특정 키를 환경변수로 주입합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASSWORD
EOF',
   '["sh", "-c", "kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod secret-pod -n $NS | grep -q secret-pod"]'),

  (12, 8, 'ConfigMap과 Secret 함께 사용하기',
   'app-config ConfigMap과 db-secret Secret을 모두 환경변수로 주입한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 full-pod 로 하세요.',
   'envFrom 에 configMapRef 와 secretRef 를 함께 나열할 수 있습니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: full-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: db-secret
EOF',
   '["sh", "-c", "kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_PORT=8080 -n $NS 2>/dev/null; kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cur3 -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "kubectl get pod full-pod -n $NS | grep -q full-pod"]');

-- 세트 13: k8s 스토리지와 네트워크 (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (13, 1, 'PersistentVolume 생성하기',
   '$NS 네임스페이스에 pv-local 이름의 PersistentVolume을 생성하세요. 용량은 1Gi, 접근 모드는 ReadWriteOnce, hostPath는 /tmp/pv-data 로 설정하세요.',
   'PersistentVolume은 네임스페이스에 속하지 않는 클러스터 레벨 리소스입니다. kind: PersistentVolume 으로 작성합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local-$NS
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /tmp/pv-data
  claimRef:
    namespace: $NS
    name: pvc-local
EOF',
   NULL,
   '["sh", "-c", "kubectl get pv pv-local-$NS | grep -q pv-local"]'),

  (13, 2, 'PersistentVolumeClaim 생성하기',
   '$NS 네임스페이스에 pvc-local 이름의 PVC를 생성하세요. 용량 1Gi, 접근 모드 ReadWriteOnce 로 요청하세요.',
   'kind: PersistentVolumeClaim 으로 작성하고 resources.requests.storage 로 용량을 지정합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-local
  namespace: $NS
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF',
   '["sh", "-c", "kubectl apply -f - <<EOF\napiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: pv-local-$NS\nspec:\n  capacity:\n    storage: 1Gi\n  accessModes:\n  - ReadWriteOnce\n  hostPath:\n    path: /tmp/pv-data\n  claimRef:\n    namespace: $NS\n    name: pvc-local\nEOF\n"]',
   '["sh", "-c", "kubectl get pvc pvc-local -n $NS | grep -q pvc-local"]'),

  (13, 3, 'PVC 상태 확인하기',
   'pvc-local PVC가 Bound 상태인지 확인하고 결과를 /tmp/pvc_status.txt 에 저장하세요.',
   'kubectl get pvc -n <namespace> 로 상태를 확인합니다. STATUS 컬럼이 Bound 여야 합니다.',
   'kubectl get pvc pvc-local -n $NS > /tmp/pvc_status.txt',
   '["sh", "-c", "kubectl apply -f - <<EOF\napiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: pv-local-$NS\nspec:\n  capacity:\n    storage: 1Gi\n  accessModes:\n  - ReadWriteOnce\n  hostPath:\n    path: /tmp/pv-data\n  claimRef:\n    namespace: $NS\n    name: pvc-local\nEOF\nkubectl apply -f - <<EOF\napiVersion: v1\nkind: PersistentVolumeClaim\nmetadata:\n  name: pvc-local\n  namespace: $NS\nspec:\n  accessModes:\n  - ReadWriteOnce\n  resources:\n    requests:\n      storage: 1Gi\nEOF\n"]',
   '["sh", "-c", "grep -q ''Bound'' /tmp/pvc_status.txt"]'),

  (13, 4, 'PVC를 Pod에 마운트하기',
   'pvc-local PVC를 /data 경로에 마운트한 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 pvc-pod, 이미지는 nginx 로 하세요.',
   'volumes.persistentVolumeClaim.claimName 으로 PVC를 참조하고 volumeMounts 로 마운트 경로를 지정합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
  namespace: $NS
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: data-vol
      mountPath: /data
  volumes:
  - name: data-vol
    persistentVolumeClaim:
      claimName: pvc-local
EOF',
   '["sh", "-c", "kubectl apply -f - <<EOF\napiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: pv-local-$NS\nspec:\n  capacity:\n    storage: 1Gi\n  accessModes:\n  - ReadWriteOnce\n  hostPath:\n    path: /tmp/pv-data\n  claimRef:\n    namespace: $NS\n    name: pvc-local\nEOF\nkubectl apply -f - <<EOF\napiVersion: v1\nkind: PersistentVolumeClaim\nmetadata:\n  name: pvc-local\n  namespace: $NS\nspec:\n  accessModes:\n  - ReadWriteOnce\n  resources:\n    requests:\n      storage: 1Gi\nEOF\n"]',
   '["sh", "-c", "kubectl get pod pvc-pod -n $NS | grep -q pvc-pod"]'),

  (13, 5, 'Service 생성하고 port-forward로 접근하기',
   '$NS 네임스페이스에 nginx Pod와 Service를 생성한 뒤, kubectl port-forward 로 로컬 9090 포트를 Service 80 포트에 연결하고 curl로 응답을 확인해서 /tmp/pf_result.txt 에 저장하세요.',
   'kubectl port-forward svc/<서비스명> <로컬포트>:<서비스포트> -n <namespace> & 로 백그라운드 실행 후 curl localhost:<로컬포트> 로 확인합니다.',
   'kubectl run pf-nginx --image=nginx -n $NS && kubectl expose pod pf-nginx --port=80 -n $NS && sleep 3 && kubectl port-forward svc/pf-nginx 9090:80 -n $NS & sleep 2 && curl -s localhost:9090 > /tmp/pf_result.txt',
   NULL,
   '["sh", "-c", "grep -qi ''nginx\\|html'' /tmp/pf_result.txt"]'),

  (13, 6, 'Pod 로그로 문제 진단하기',
   '$NS 네임스페이스에 잘못된 명령어로 CrashLoopBackOff 상태가 된 Pod가 있습니다. 로그를 확인하고 에러 메시지를 /tmp/crash_log.txt 에 저장하세요.',
   'kubectl logs <pod명> -n <namespace> 로 로그를 확인합니다. 이전 컨테이너 로그는 --previous 옵션을 사용합니다.',
   'kubectl logs crash-pod -n $NS > /tmp/crash_log.txt 2>&1 || kubectl logs crash-pod -n $NS --previous > /tmp/crash_log.txt 2>&1',
   '["sh", "-c", "kubectl run crash-pod --image=ubuntu --restart=Always -n $NS -- sh -c ''echo ERROR: invalid config && exit 1'' 2>/dev/null; true"]',
   '["sh", "-c", "test -s /tmp/crash_log.txt"]'),

  (13, 7, 'kubectl describe로 Pod 상태 진단하기',
   '$NS 네임스페이스의 crash-pod Pod 상세 정보를 확인하고 /tmp/describe_result.txt 에 저장하세요. Events 섹션에서 문제 원인을 찾아보세요.',
   'kubectl describe pod <pod명> -n <namespace> 로 이벤트와 상태를 상세히 확인합니다.',
   'kubectl describe pod crash-pod -n $NS > /tmp/describe_result.txt',
   '["sh", "-c", "kubectl run crash-pod --image=ubuntu --restart=Always -n $NS -- sh -c ''echo ERROR && exit 1'' 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''Events\\|State'' /tmp/describe_result.txt"]'),

  (13, 8, 'EmptyDir 볼륨으로 컨테이너 간 파일 공유하기',
   'emptyDir 볼륨을 사용해서 두 컨테이너가 /shared 디렉토리를 공유하는 Pod를 $NS 네임스페이스에 생성하세요. Pod 이름은 shared-pod, 컨테이너는 writer(busybox)와 reader(busybox)로 구성하세요.',
   'emptyDir 볼륨은 Pod 생명주기와 함께하는 임시 볼륨입니다. 두 컨테이너 모두 volumeMounts 에 같은 볼륨을 마운트합니다.',
   'kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: shared-pod
  namespace: $NS
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sh", "-c", "echo hello > /shared/data.txt && sleep 3600"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  - name: reader
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  volumes:
  - name: shared-vol
    emptyDir: {}
EOF',
   NULL,
   '["sh", "-c", "kubectl get pod shared-pod -n $NS | grep -q shared-pod"]');

-- 세트 14: Helm 기초 (order 1~8)
-- $NS 는 런타임에 quest-{containerId 앞 8자리} 로 치환됨
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (14, 1, 'Helm repo 추가하기',
   'Bitnami Helm 저장소를 추가하고 목록을 확인하세요.',
   'helm repo add <이름> <URL> 로 저장소를 등록합니다. https://charts.bitnami.com/bitnami 를 bitnami 이름으로 추가하세요.',
   'helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo list',
   NULL,
   '["sh", "-c", "helm repo list | grep -q bitnami"]'),

  (14, 2, 'Helm repo 업데이트하기',
   'Helm 저장소 인덱스를 최신 상태로 갱신하세요.',
   'helm repo update 를 실행합니다.',
   'helm repo update',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null; true"]',
   '["sh", "-c", "helm repo update 2>&1 | grep -qi ''update complete\\|Successfully''"]'),

  (14, 3, '차트 검색하기',
   'Bitnami 저장소에서 nginx 차트를 검색하고 결과를 /tmp/helm_search.txt 에 저장하세요.',
   'helm search repo <키워드> 로 저장소에서 차트를 검색합니다.',
   'helm search repo nginx > /tmp/helm_search.txt',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''nginx'' /tmp/helm_search.txt"]'),

  (14, 4, '차트 설치하기',
   '$NS 네임스페이스에 bitnami/nginx 차트를 my-nginx 이름으로 설치하세요.',
   'helm install <릴리스명> <차트> -n <namespace> 로 설치합니다.',
   'helm install my-nginx bitnami/nginx -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null; true"]',
   '["sh", "-c", "helm list -n $NS | grep -q my-nginx"]'),

  (14, 5, '릴리스 목록 확인하기',
   '$NS 네임스페이스에 설치된 Helm 릴리스 목록을 확인하고 /tmp/helm_list.txt 에 저장하세요.',
   'helm list -n <namespace> 로 릴리스 목록을 확인합니다.',
   'helm list -n $NS > /tmp/helm_list.txt',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null && helm install my-nginx bitnami/nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "grep -q ''my-nginx'' /tmp/helm_list.txt"]'),

  (14, 6, '값을 커스터마이징해서 설치하기',
   '$NS 네임스페이스에 bitnami/nginx 차트를 custom-nginx 이름으로 설치하세요. replicaCount를 2로 지정해서 설치해야 합니다.',
   'helm install <릴리스명> <차트> --set <키>=<값> -n <namespace> 로 값을 오버라이드합니다.',
   'helm install custom-nginx bitnami/nginx --set replicaCount=2 -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null; true"]',
   '["sh", "-c", "helm get values custom-nginx -n $NS | grep -q ''replicaCount: 2''"]'),

  (14, 7, '릴리스 업그레이드하기',
   '$NS 네임스페이스의 my-nginx 릴리스를 replicaCount=3 으로 업그레이드하세요.',
   'helm upgrade <릴리스명> <차트> --set <키>=<값> -n <namespace> 로 설정을 변경합니다.',
   'helm upgrade my-nginx bitnami/nginx --set replicaCount=3 -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null && helm install my-nginx bitnami/nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "helm history my-nginx -n $NS | grep -c deployed | xargs -I{} test {} -ge 1"]'),

  (14, 8, '릴리스 삭제하기',
   '$NS 네임스페이스의 my-nginx 릴리스를 완전히 삭제하세요.',
   'helm uninstall <릴리스명> -n <namespace> 로 릴리스와 관련 리소스를 모두 제거합니다.',
   'helm uninstall my-nginx -n $NS',
   '["sh", "-c", "helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null && helm repo update 2>/dev/null && helm install my-nginx bitnami/nginx -n $NS 2>/dev/null; true"]',
   '["sh", "-c", "! helm list -n $NS | grep -q my-nginx"]');
