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
