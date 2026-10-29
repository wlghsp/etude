-- 세트 11 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='Dockerfile 작성하기', description='**Dockerfile** 은 이미지를 어떻게 만들지 적은 설계 파일입니다. 같은 이미지를 누가 언제 만들어도 똑같이 만들어지게 해 줍니다.

`/tmp/myapp` 디렉토리에 `Dockerfile` 을 작성하세요. 베이스 이미지는 `ubuntu` 이고, `echo "hello"` 를 실행하는 `CMD` 가 있어야 합니다.', hint='Dockerfile 의 기본 구조:
- `FROM <이미지>` : 어떤 이미지를 바탕으로 만들지(베이스 이미지)
- `CMD ["echo", "hello"]` : 컨테이너가 시작될 때 실행할 기본 명령(JSON 배열 형식)
한 줄씩 `printf` 로 파일에 쓸 수 있고, 줄바꿈은 `\\n` 입니다.', solution='mkdir -p /tmp/myapp && printf ''FROM ubuntu\\nCMD ["echo", "hello"]\\n'' > /tmp/myapp/Dockerfile

# FROM : 베이스 이미지, CMD : 컨테이너 시작 시 실행할 명령' WHERE quest_set_id = 11 AND order_index = 1;
UPDATE quest SET title='Dockerfile 로 이미지 빌드하기', description='Dockerfile 을 이미지로 만드는 것이 **빌드**입니다.

`/tmp/myapp/Dockerfile` 로 `my-app:1.0` 이미지를 빌드하세요. (이름 `my-app`, 태그 `1.0`)', hint='`docker build -t <이름>:<태그> <Dockerfile이 있는 디렉토리>` 형식입니다. `-t` 는 tag(이미지 이름과 태그 지정)입니다. 마지막의 경로는 빌드 대상 디렉토리(컨텍스트)입니다. 확인: `docker images`', solution='docker build -t my-app:1.0 /tmp/myapp

# -t 이름:태그 : 만들 이미지의 이름
# 마지막 인자 : Dockerfile 이 있는 디렉토리' WHERE quest_set_id = 11 AND order_index = 2;
UPDATE quest SET title='RUN 으로 이미지에 패키지 설치하기', description='이미지에 필요한 프로그램은 빌드할 때 `RUN` 으로 설치해 두면, 실행할 때마다 설치할 필요가 없습니다.

`/tmp/myapp/Dockerfile` 을 수정해 `curl` 을 설치하는 `RUN` 을 추가하고, `my-app:2.0` 으로 빌드하세요.', hint='`RUN <명령>` 은 빌드 중에 명령을 실행해 그 결과를 이미지에 남깁니다. 패키지 설치는 `RUN apt-get update && apt-get install -y curl` 처럼 씁니다 (`-y` 는 설치 확인 질문에 자동으로 ''예''). 빌드: `docker build -t my-app:2.0 /tmp/myapp`', solution='printf ''FROM ubuntu\\nRUN apt-get update && apt-get install -y curl\\nCMD ["curl", "--version"]\\n'' > /tmp/myapp/Dockerfile && docker build -t my-app:2.0 /tmp/myapp

# RUN : 빌드할 때 실행되어 이미지에 반영됨 (CMD 는 컨테이너 시작할 때)' WHERE quest_set_id = 11 AND order_index = 3;
UPDATE quest SET title='COPY 로 파일을 이미지에 포함하기', description='애플리케이션 파일(웹 페이지, 설정 등)을 이미지 안에 넣으려면 `COPY` 를 씁니다.

`/tmp/myapp/index.html` 을 만들고, Dockerfile 에서 `COPY` 로 이미지 안의 `/var/www/html/` 에 복사하도록 작성한 뒤 `my-app:3.0` 으로 빌드하세요.', hint='`COPY <빌드 디렉토리 안의 파일> <이미지 안의 경로>` 형식입니다. 원본 파일은 빌드하는 디렉토리(`/tmp/myapp`) 안에 있어야 하므로 `index.html` 을 거기에 만드세요. 그다음 Dockerfile 을 다시 쓰고 `docker build -t my-app:3.0 /tmp/myapp` 하세요.', solution='echo "<h1>hello</h1>" > /tmp/myapp/index.html && printf ''FROM ubuntu\\nCOPY index.html /var/www/html/\\n'' > /tmp/myapp/Dockerfile && docker build -t my-app:3.0 /tmp/myapp

# COPY 원본 대상 : 빌드 디렉토리의 파일을 이미지 안으로 복사' WHERE quest_set_id = 11 AND order_index = 4;
UPDATE quest SET title='이미지에 태그 추가하기', description='같은 이미지에 이름표(태그)를 여러 개 붙일 수 있습니다. 보통 구체적인 버전과 `latest` 를 함께 둡니다.

`my-app:3.0` 이미지에 `my-app:latest` 태그를 추가하세요.', hint='`docker tag <원본이미지> <새이름>` 입니다. 이미지가 복사되는 것이 아니라 이름표만 하나 더 붙습니다. 확인: `docker images` 에서 같은 IMAGE ID 가 두 줄로 보입니다.', solution='docker tag my-app:3.0 my-app:latest' WHERE quest_set_id = 11 AND order_index = 5;
UPDATE quest SET title='이미지로 컨테이너 실행해 내용 확인하기', description='빌드한 이미지가 의도대로 만들어졌는지 컨테이너로 실행해 확인합니다.

`my-app:latest` 이미지로 컨테이너를 실행해 `/var/www/html/index.html` 의 내용을 출력하고, 결과를 `/tmp/run_result.txt` 에 저장하세요.', hint='`docker run --rm <이미지> <명령>` 형식입니다. `--rm` 은 실행이 끝나면 컨테이너를 자동으로 삭제합니다. 컨테이너 안에서 `cat <파일>` 을 실행하고 그 출력을 `>` 로 저장하세요.', solution='docker run --rm my-app:latest cat /var/www/html/index.html > /tmp/run_result.txt

# --rm : 끝나면 컨테이너 자동 삭제' WHERE quest_set_id = 11 AND order_index = 6;
