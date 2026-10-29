-- 세트 8 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='이미지를 tar 파일로 저장하기 (save)', description='인터넷이 막힌 현장 서버에는 이미지를 직접 받을 수 없어서, 외부에서 받은 이미지를 **파일로 만들어 반입**합니다. 그 첫 단계입니다.

`alpine` 이미지를 받은 뒤, `/tmp/alpine.tar` 파일로 저장하세요.', hint='1) `docker pull alpine` : 이미지 받기
2) `docker save -o <파일> <이미지>` : 이미지를 tar 파일로 저장
`-o` 는 output(저장할 파일 이름 지정)입니다.', solution='docker pull alpine && docker save -o /tmp/alpine.tar alpine

# save : 이미지를 tar 파일로 내보냄, -o : 저장할 파일
# && : 앞 명령이 성공하면 이어서 실행' WHERE quest_set_id = 8 AND order_index = 1;
UPDATE quest SET title='로컬 이미지 삭제하기', description='다음 문제에서 tar 파일로 이미지를 다시 불러오는 연습을 하려면, 먼저 서버에서 이미지를 지워 둡니다. 실제로 이미지가 없는 서버를 흉내 내는 단계입니다.

`alpine` 이미지를 로컬에서 삭제하세요.', hint='`docker rmi <이미지>` 입니다(`rmi` 는 remove image). 확인: `docker images` 에서 `alpine` 이 사라져야 합니다.', solution='docker rmi alpine

# rmi : 이미지 삭제 (rm 은 컨테이너 삭제)' WHERE quest_set_id = 8 AND order_index = 2;
UPDATE quest SET title='tar 파일에서 이미지 불러오기 (load)', description='이것이 현장에서 반입한 tar 파일을 서버의 Docker 에 올리는 단계입니다.

`/tmp/alpine.tar` 파일에서 이미지를 불러오세요.', hint='`docker load -i <파일>` 입니다. `-i` 는 input(읽어 들일 파일)입니다. 확인: `docker images`', solution='docker load -i /tmp/alpine.tar

# load : tar 파일의 이미지를 Docker 에 등록, -i : 입력 파일' WHERE quest_set_id = 8 AND order_index = 3;
UPDATE quest SET title='로컬 레지스트리 실행하기', description='**레지스트리**는 이미지를 저장하고 나눠 주는 서버입니다. 현장에서는 Nexus, Harbor 같은 내부 레지스트리가 이 역할을 하고, 여기서는 Docker 공식 `registry` 이미지로 흉내 냅니다.

`registry:2` 이미지로 로컬 레지스트리를 **포트 5000** 으로 백그라운드 실행하세요. (이름 `registry`)', hint='`docker run -d -p 5000:5000 --name registry registry:2`
- `-d` : 백그라운드 실행
- `-p 5000:5000` : 호스트 5000 포트를 컨테이너 5000 포트에 연결
- `--name registry` : 컨테이너 이름', solution='docker run -d -p 5000:5000 --name registry registry:2

# -d : 백그라운드, -p 호스트:컨테이너 : 포트 연결, --name : 이름 지정' WHERE quest_set_id = 8 AND order_index = 4;
UPDATE quest SET title='이미지에 레지스트리 주소 태그 붙이기', description='이미지를 특정 레지스트리에 올리려면, 이미지 이름에 **레지스트리 주소**가 들어 있어야 합니다. 태그(tag)는 이미지에 붙이는 또 하나의 이름표입니다.

`alpine` 이미지에 `localhost:5000/alpine:latest` 라는 태그를 붙이세요.', hint='`docker tag <원본이미지> <새이름>` 입니다. 새 이름의 형식은 `<레지스트리주소>/<이미지이름>:<태그>` 입니다. 확인: `docker images` 에 두 이름이 같은 이미지로 보입니다.', solution='docker tag alpine localhost:5000/alpine:latest

# tag : 같은 이미지에 새 이름 추가 (복사가 아니라 이름표)' WHERE quest_set_id = 8 AND order_index = 5;
UPDATE quest SET title='레지스트리에 이미지 올리기 (push)', description='내부 레지스트리에 이미지를 올려 두면 다른 서버에서도 받아 쓸 수 있습니다.

`localhost:5000/alpine:latest` 이미지를 로컬 레지스트리에 **push** 하세요.', hint='`docker push <이미지이름>` 입니다. 이름에 포함된 레지스트리 주소(`localhost:5000`)로 올라갑니다.', solution='docker push localhost:5000/alpine:latest

# push : 이미지를 이름에 적힌 레지스트리로 업로드' WHERE quest_set_id = 8 AND order_index = 6;
UPDATE quest SET title='레지스트리의 이미지로 컨테이너 실행하기', description='배포 서버는 보통 내부 레지스트리의 이미지를 받아 실행합니다. 지금까지 만든 흐름의 마지막 단계입니다.

로컬 레지스트리(`localhost:5000`)의 `alpine` 이미지로 `echo hello` 를 실행하고, 출력 결과를 `/tmp/run_result.txt` 에 저장하세요.', hint='`docker run <이미지> <명령>` 에서 이미지 이름에 레지스트리 주소를 포함하면 그 레지스트리에서 받아 실행합니다. 컨테이너 안의 `echo hello` 출력을 `>` 로 파일에 저장하세요.', solution='docker run localhost:5000/alpine:latest echo hello > /tmp/run_result.txt

# 이미지 뒤의 echo hello 는 컨테이너 안에서 실행할 명령' WHERE quest_set_id = 8 AND order_index = 7;
