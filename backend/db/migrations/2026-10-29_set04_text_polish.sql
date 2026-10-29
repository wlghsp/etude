-- 세트 4 문제 문구를 작성 기준(docs/specs/spec_quest_writing_guide.md)에 맞게 개선. 채점 조건(setup_cmd, grade_cmd)은 바꾸지 않는다. 여러 번 실행해도 같은 결과다.
UPDATE quest SET title='curl 로 웹 서버에 요청 보내기', description='`curl` 은 터미널에서 웹 서버에 HTTP 요청을 보내는 도구입니다. 서비스가 응답하는지 확인할 때 가장 먼저 씁니다.

`http://example.com` 에 GET 요청을 보내고, 받은 응답을 `/tmp/curl_result.txt` 에 저장하세요.', hint='`curl <주소>` 는 응답 본문을 화면에 출력합니다. 이 출력을 `>` (리다이렉션)으로 파일에 저장하세요. 확인: `cat /tmp/curl_result.txt`', solution='curl http://example.com > /tmp/curl_result.txt

# curl : 주소로 요청을 보내고 응답을 출력
# >    : 출력을 파일로 저장' WHERE quest_set_id = 4 AND order_index = 1;
UPDATE quest SET title='웹 페이지를 파일로 내려받기', description='`curl` 의 `-o` 옵션을 쓰면 응답을 화면이 아닌 파일로 바로 저장합니다. 파일 다운로드에 씁니다.

`http://example.com` 의 내용을 `/tmp/index.html` 파일로 저장하세요.', hint='`curl -o <저장할파일> <주소>` 형식입니다. `-o` 는 output(출력 파일 이름 지정)입니다.', solution='curl -o /tmp/index.html http://example.com

# -o : 응답을 지정한 파일로 저장' WHERE quest_set_id = 4 AND order_index = 2;
UPDATE quest SET title='ping 으로 네트워크 연결 확인하기', description='`ping` 은 상대 서버까지 네트워크가 닿는지, 응답이 얼마나 걸리는지 확인합니다. 네트워크 장애의 첫 점검 도구입니다.

`8.8.8.8` 주소로 ping 을 **3번만** 보내고, 결과를 `/tmp/ping_result.txt` 에 저장하세요.', hint='`ping` 은 옵션이 없으면 멈출 때까지 계속 보냅니다. `-c <횟수>` 로 보낼 횟수를 정하세요(`-c` 는 count). 결과는 `>` 로 파일에 저장합니다.', solution='ping -c 3 8.8.8.8 > /tmp/ping_result.txt

# -c 3 : 3번만 보내고 종료' WHERE quest_set_id = 4 AND order_index = 3;
UPDATE quest SET title='열려 있는 포트 확인하기', description='서비스가 포트를 열고 대기 중인지(listen) 보는 것은 접속 장애의 기본 점검입니다.

현재 대기(listen) 중인 TCP 포트 목록을 `/tmp/ports.txt` 에 저장하세요.', hint='`ss -tlnp` 를 씁니다. `-t` TCP 만, `-l` 대기(listen) 중인 것만, `-n` 이름 대신 숫자로 표시, `-p` 어떤 프로세스인지 함께 표시입니다. 옵션은 붙여 씁니다.', solution='ss -tlnp > /tmp/ports.txt

# -t : TCP, -l : listen 중, -n : 숫자 표시, -p : 프로세스 표시' WHERE quest_set_id = 4 AND order_index = 4;
UPDATE quest SET title='scp 로 원격 서버에 파일 복사하기', description='`scp` 는 SSH 로 안전하게 파일을 다른 서버에 복사합니다. 설정 파일 배포나 백업 전송에 씁니다.

`/tmp/index.html` 파일을 `root@localhost` 서버의 `/tmp/remote_copy.html` 로 복사하세요. 비밀번호를 물으면 `root` 를 입력합니다.', hint='형식: `scp <로컬파일> <사용자>@<호스트>:<원격경로>`
처음 접속하는 서버는 "계속 연결하시겠습니까?"라는 확인이 나옵니다. `-o StrictHostKeyChecking=no` 옵션을 주면 이 확인을 건너뜁니다(연습 환경에서만 쓰세요).', solution='scp -o StrictHostKeyChecking=no /tmp/index.html root@localhost:/tmp/remote_copy.html

# -o StrictHostKeyChecking=no : 서버 지문 확인 질문을 생략
# 사용자@호스트:경로 : 원격 서버의 대상 위치' WHERE quest_set_id = 4 AND order_index = 5;
UPDATE quest SET title='rsync 로 디렉토리 동기화하기', description='`rsync` 는 두 디렉토리를 비교해 **달라진 파일만** 전송합니다. 큰 디렉토리를 반복해서 복사·백업할 때 `cp`, `scp` 보다 훨씬 효율적입니다.

`/tmp/sync_src` 디렉토리의 내용을 `root@localhost` 서버의 `/tmp/sync_dst` 에 동기화하세요. 비밀번호를 물으면 `root` 를 입력합니다.', hint='형식: `rsync -av -e "ssh -o StrictHostKeyChecking=no" <원본>/ <사용자>@<호스트>:<대상>/`
- `-a` : 권한·날짜 등을 유지하며 디렉토리 전체를 복사(archive)
- `-v` : 진행 과정을 자세히 출력(verbose)
- `-e "ssh ..."` : 전송에 쓸 SSH 명령 지정
- 원본 경로 끝의 `/` 는 ''디렉토리 **안의 내용**''을 뜻합니다.', solution='rsync -av -e "ssh -o StrictHostKeyChecking=no" /tmp/sync_src/ root@localhost:/tmp/sync_dst/

# -a : 아카이브 모드(재귀 + 권한 유지), -v : 자세히 출력
# -e : 전송에 사용할 원격 셸(ssh) 지정' WHERE quest_set_id = 4 AND order_index = 6;
UPDATE quest SET title='원격 서버에서 명령 실행하고 결과 저장하기', description='`ssh` 는 원격 서버에 접속할 뿐 아니라, 접속하지 않고 **명령 하나만 실행**해서 결과를 받아 올 수도 있습니다. 여러 서버를 점검하는 스크립트에 씁니다.

`ssh` 로 `root@localhost` 에서 `hostname` 명령을 실행하고, 그 결과를 `/tmp/hostname.txt` 에 저장하세요. 비밀번호를 물으면 `root` 를 입력합니다.', hint='형식: `ssh <옵션> <사용자>@<호스트> <명령>`
호스트 뒤에 쓴 명령이 원격에서 실행되고, 출력은 내 화면으로 돌아옵니다. 그 출력을 `>` 로 로컬 파일에 저장하세요. `-o StrictHostKeyChecking=no` 는 서버 지문 확인 질문을 생략합니다.', solution='ssh -o StrictHostKeyChecking=no root@localhost hostname > /tmp/hostname.txt

# 호스트 뒤의 hostname 이 원격에서 실행됨
# > 는 내 쪽(로컬) 파일에 저장' WHERE quest_set_id = 4 AND order_index = 7;
