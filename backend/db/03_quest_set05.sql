-- 세트 5: Docker 기초 (order 1~13)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (5,  1, 'Docker 이미지 목록 저장하기',
   '이미지는 컨테이너를 만드는 설계도입니다. 서버에 어떤 이미지가 받아져 있는지 보는 것이 Docker 작업의 시작입니다.

지금 Docker 에 저장된 **이미지 목록**을 `/tmp/images.txt` 에 저장하세요.',
   '`docker images` 는 로컬에 있는 이미지 목록(이름, 태그, 크기)을 보여 줍니다. 결과를 `>` 로 파일에 저장하세요.',
   'docker images > /tmp/images.txt',
   '["sh", "-c", "docker pull hello-world"]',
   '["sh", "-c", "grep -q hello-world /tmp/images.txt"]'),

  (5,  2, '이미지 받아오기',
   '컨테이너를 실행하려면 먼저 이미지가 필요합니다. 레지스트리(Docker Hub 등)에서 받아 오는 것이 `pull` 입니다.

Docker Hub 에서 `hello-world` 이미지를 받아 오세요.',
   '`docker pull <이미지이름>` 입니다. 태그를 생략하면 `latest` 가 받아집니다.',
   'docker pull hello-world

# 확인: docker images',
   NULL,
   '["sh", "-c", "docker images hello-world | grep -q hello-world"]'),

  (5,  3, '컨테이너 실행하기',
   '이미지를 실제로 실행한 것이 컨테이너입니다.

`hello-world` 이미지로 컨테이너를 실행하세요. 설치가 정상이면 환영 메시지가 출력됩니다.',
   '`docker run <이미지>` 는 이미지가 없으면 받아 오고, 컨테이너를 만들어 실행합니다.',
   'docker run hello-world',
   NULL,
   '["sh", "-c", "docker ps -a | grep -q hello-world"]'),

  (5,  4, '백그라운드로 컨테이너 실행하기',
   '서비스(웹 서버 등)는 터미널을 점유하지 않고 계속 돌아야 하므로 **백그라운드**로 실행합니다. 이름을 붙여 두면 이후에 이름으로 다룰 수 있습니다.

`nginx` 이미지를 백그라운드로 실행하고, 컨테이너 이름을 `my-nginx` 로 지정하세요.',
   '`docker run -d --name <이름> <이미지>` 형식입니다.
- `-d` : 백그라운드(detached)로 실행
- `--name` : 컨테이너 이름 지정
확인: `docker ps`',
   'docker run -d --name my-nginx nginx

# -d : 백그라운드 실행, --name : 컨테이너에 이름 부여',
   NULL,
   '["sh", "-c", "docker ps | grep -q my-nginx"]'),

  (5,  5, '실행 중인 컨테이너 목록 저장하기',
   '지금 어떤 컨테이너가 돌고 있는지 확인하는 것은 운영의 기본 점검입니다.

현재 **실행 중인 컨테이너 목록**을 `/tmp/containers.txt` 에 저장하세요.',
   '`docker ps` 는 실행 중인 컨테이너만 보여 줍니다(중지된 것까지 보려면 `-a`). 결과를 `>` 로 저장하세요.',
   'docker ps > /tmp/containers.txt

# ps : process status, 실행 중인 컨테이너 목록',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["test", "-s", "/tmp/containers.txt"]'),

  (5,  6, '컨테이너 로그 확인하기',
   '컨테이너가 이상할 때 가장 먼저 보는 것이 로그입니다.

`my-nginx` 컨테이너의 로그를 `/tmp/nginx_logs.txt` 에 저장하세요.',
   '`docker logs <컨테이너>` 로 로그를 봅니다. 일부 로그는 에러 출력(표준 에러)으로 나와서 `>` 만으로는 파일에 안 담길 수 있으니 `2>&1` 을 함께 쓰세요.
형태: `docker logs <이름> > <파일> 2>&1`',
   'docker logs my-nginx > /tmp/nginx_logs.txt 2>&1

# 2>&1 : 에러 출력(2번)도 같은 파일로 보냄',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["test", "-f", "/tmp/nginx_logs.txt"]'),

  (5,  7, '컨테이너 중지하기',
   '더 이상 필요 없거나 점검이 필요할 때 컨테이너를 멈춥니다.

`my-nginx` 컨테이너를 중지하세요.',
   '`docker stop <컨테이너>` 입니다. 중지된 컨테이너는 `docker ps -a` 로 볼 수 있습니다.',
   'docker stop my-nginx',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["sh", "-c", "! docker ps | grep -q my-nginx"]'),

  (5,  8, '컨테이너 삭제하고 전체 목록 저장하기',
   '중지한 컨테이너도 디스크를 차지하므로 필요 없으면 삭제합니다.

1. `my-nginx` 컨테이너를 삭제합니다.
2. 중지된 것까지 포함한 **전체 컨테이너 목록**을 `/tmp/final.txt` 에 저장합니다.',
   '삭제: `docker rm <컨테이너>`
목록: `docker ps -a` 의 `-a` 는 all(중지된 컨테이너 포함)입니다. 결과를 `>` 로 저장하세요.',
   'docker rm my-nginx
docker ps -a > /tmp/final.txt

# rm : 컨테이너 삭제, ps -a : 중지된 것까지 모두',
   '["sh", "-c", "docker run -d --name my-nginx nginx && docker stop my-nginx"]',
   '["sh", "-c", "test -s /tmp/final.txt && ! grep -q my-nginx /tmp/final.txt"]'),

  (5,  9, '실행 중인 컨테이너 안에서 명령 실행하기',
   '컨테이너 안의 파일이나 상태를 직접 확인하려면 `docker exec` 로 안에서 명령을 실행합니다.

`my-nginx` 컨테이너 안에서 `/usr/share/nginx/html/index.html` 파일이 있는지 확인(`ls` 사용)하고, 그 결과를 `/tmp/exec_result.txt` 에 저장하세요.',
   '`docker exec <컨테이너> <명령>` 은 실행 중인 컨테이너 안에서 명령을 실행합니다. 안에서 계속 작업하고 싶으면 `-it` 옵션(`-i` 입력 유지, `-t` 터미널 연결)으로 `docker exec -it <컨테이너> bash` 를 씁니다. 여기서는 결과만 저장하면 되니 `-it` 없이 `ls <경로>` 를 실행하고 `>` 로 저장하세요.',
   'docker exec my-nginx ls /usr/share/nginx/html/index.html > /tmp/exec_result.txt

# exec : 실행 중인 컨테이너 안에서 명령 실행
# 대화형으로 들어가려면: docker exec -it my-nginx bash',
   '["sh", "-c", "docker run -d --name my-nginx nginx"]',
   '["sh", "-c", "grep -q ''index.html'' /tmp/exec_result.txt"]'),

  (5, 10, '포트를 연결해서 컨테이너 실행하기',
   '컨테이너 안의 서비스에 밖에서 접속하려면 호스트의 포트를 컨테이너의 포트에 **연결(바인딩)** 해야 합니다.

`nginx` 컨테이너를 백그라운드로 실행하되, 호스트의 `8080` 포트를 컨테이너의 `80` 포트에 연결하세요. 컨테이너 이름은 `port-nginx` 입니다.',
   '형식: `docker run -d -p <호스트포트>:<컨테이너포트> --name <이름> <이미지>`
- `-p 8080:80` : 호스트 8080 으로 오는 요청을 컨테이너 80 으로 전달
- `-d` : 백그라운드, `--name` : 이름 지정',
   'docker run -d -p 8080:80 --name port-nginx nginx

# -p 호스트:컨테이너 : 포트 연결',
   NULL,
   '["sh", "-c", "docker ps | grep port-nginx | grep -q ''0.0.0.0:8080''"]'),

  (5, 11, '환경변수를 넣어서 컨테이너 실행하기',
   '컨테이너의 설정(DB 주소, 모드 등)은 보통 **환경변수**로 전달합니다.

`ubuntu` 컨테이너를 `MY_ENV=hello` 환경변수를 주입해서 실행하고(이름 `env-test`), 컨테이너 안에서 그 변수를 출력한 결과를 `/tmp/env_result.txt` 에 저장하세요.',
   '1) 실행: `docker run -d --name env-test -e MY_ENV=hello ubuntu sleep 60` (`-e` 는 환경변수 주입, `sleep 60` 은 컨테이너가 바로 종료되지 않게 60초 유지)
2) 확인: `docker exec env-test printenv MY_ENV` 는 안에서 그 변수 값을 출력합니다. 결과를 `>` 로 저장하세요.',
   'docker run -d --name env-test -e MY_ENV=hello ubuntu sleep 60 && docker exec env-test printenv MY_ENV > /tmp/env_result.txt

# -e : 환경변수 주입, && : 앞 명령이 성공하면 이어서 실행
# printenv 변수명 : 환경변수 값 출력',
   NULL,
   '["sh", "-c", "grep -q ''hello'' /tmp/env_result.txt"]'),

  (5, 12, '볼륨을 마운트해서 컨테이너 실행하기',
   '컨테이너가 사라져도 데이터가 남게 하거나 호스트의 파일을 컨테이너에 넘기려면 **볼륨 마운트**를 씁니다.

1. `/tmp/webroot` 디렉토리를 만들고 그 안에 `index.html`(내용 `hello`)을 만듭니다.
2. `nginx` 컨테이너(이름 `vol-nginx`)를 백그라운드로 실행하면서, `/tmp/webroot` 를 컨테이너의 `/usr/share/nginx/html` 에 마운트합니다.',
   '형식: `docker run -d -v <호스트경로>:<컨테이너경로> --name <이름> <이미지>`
`-v` 는 호스트의 디렉토리를 컨테이너 안의 경로로 연결합니다. 디렉토리는 `mkdir -p`(중간 경로까지 생성)로, 파일은 `echo "hello" > 파일` 로 만드세요.',
   'mkdir -p /tmp/webroot && echo "hello" > /tmp/webroot/index.html && docker run -d -v /tmp/webroot:/usr/share/nginx/html --name vol-nginx nginx

# -v 호스트경로:컨테이너경로 : 디렉토리 연결 (컨테이너가 이 파일을 보게 됨)',
   NULL,
   '["sh", "-c", "docker ps | grep -q vol-nginx && docker exec vol-nginx cat /usr/share/nginx/html/index.html | grep -q hello"]'),

  (5, 13, '컨테이너 상세 정보에서 IP 주소 찾기',
   '`docker inspect` 는 컨테이너의 네트워크, 설정, 상태 같은 모든 상세 정보를 JSON 으로 보여 줍니다. 문제 분석에서 자주 씁니다.

`my-nginx` 컨테이너(없으면 `nginx` 이미지로 `my-nginx` 이름으로 실행)의 상세 정보에서 **IP 주소 줄**을 `/tmp/inspect.txt` 에 저장하세요.',
   '`docker inspect <컨테이너>` 출력이 길어서 필요한 줄만 `grep IPAddress` 로 거릅니다. 파이프(`|`)는 앞 명령의 출력을 뒤 명령으로 넘기고, 마지막에 `>` 로 저장하세요.',
   'docker run -d --name my-nginx nginx && docker inspect my-nginx | grep IPAddress > /tmp/inspect.txt

# | grep IPAddress : 출력 중 IPAddress 가 들어간 줄만',
   NULL,
   '["sh", "-c", "grep -q ''IPAddress'' /tmp/inspect.txt"]');
