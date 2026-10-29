-- 세트 18: 리눅스 네트워크 진단 (order 1~10)
-- 서비스(etude-httpd)와 curl, nc, ss, /etc/hosts 로 연결 문제를 확인한다. etude-httpd 는 etude-linux 이미지에 들어 있다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (18,  1, '서비스가 응답하는지 상태 코드로 확인하기',
   '서비스가 살아 있는지 확인하는 가장 빠른 방법은 HTTP **상태 코드**를 보는 것입니다. `200` 은 정상, `5xx` 는 서버 오류입니다.

`localhost:8080` 에 웹 서비스가 떠 있습니다. 이 서비스의 HTTP 상태 코드(숫자만)를 `/tmp/status.txt` 에 저장하세요.',
   '`curl` 옵션: `-s`(진행 표시 끄기), `-o /dev/null`(본문 버리기), `-w ''%{http_code}''`(상태 코드만 출력)
형태: `curl -s -o /dev/null -w ''%{http_code}'' <주소> > <파일>`',
   'curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8080/ > /tmp/status.txt

# -o /dev/null : 본문은 버림
# -w ''%{http_code}'' : 상태 코드만 출력',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/status.txt)\\" = 200 ]"]'),

  (18,  2, '응답 본문을 파일로 저장하기',
   '서비스가 돌려주는 내용을 확인하거나 보관하려면 응답 **본문**을 저장합니다.

`http://localhost:8080/` 의 응답 본문을 `/tmp/body.txt` 에 저장하세요.',
   '`curl -s <주소>` 는 진행 표시 없이 본문만 출력합니다. 리다이렉션(`>`)으로 파일에 저장하세요.',
   'curl -s http://localhost:8080/ > /tmp/body.txt

# -s : 진행 표시와 에러 메시지를 숨김(silent)',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/body.txt)\\" = healthy ]"]'),

  (18,  3, '응답 헤더에서 값 하나 꺼내기',
   '응답 **헤더**에는 서버 정보, 환경 구분 같은 부가 정보가 들어 있습니다.

`http://localhost:8080/` 의 응답 헤더 중 `X-Env` 의 **값**만 `/tmp/env.txt` 에 저장하세요. (예: 헤더가 `X-Env: abc` 라면 `abc`)',
   '`curl -I <주소>` 는 본문 없이 헤더만 가져옵니다. 그중 `X-Env` 줄을 `grep -i ''^x-env''` 로 고르고(`-i` 는 대소문자 무시), `awk ''{print $2}''` 로 값을 뽑으세요. 줄 끝에 숨어 있는 `\\r` 문자는 `tr -d ''\\r''` 로 지웁니다.',
   'curl -sI http://localhost:8080/ | grep -i ''^x-env'' | awk ''{print $2}'' | tr -d ''\\r'' > /tmp/env.txt

# -I : 헤더만 가져옴
# tr -d ''\\r'' : 줄 끝의 캐리지 리턴 문자 제거',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/env.txt)\\" = prod ]"]'),

  (18,  4, '헬스체크 주소의 상태 확인하기',
   '서비스는 보통 `/health` 같은 점검용 주소를 제공합니다. 메인 화면은 떠도 점검 주소가 오류면 문제가 있는 것입니다.

`http://localhost:8080/health` 의 HTTP 상태 코드(숫자만)를 `/tmp/health.txt` 에 저장하세요.',
   '첫 문제와 같은 방법입니다. `-w ''%{http_code}''` 로 상태 코드를 출력합니다. `200` 은 정상, `5xx` 는 서버 오류입니다.',
   'curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8080/health > /tmp/health.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/health.txt)\\" = 503 ]"]'),

  (18,  5, '열려 있는 포트 찾기',
   '서비스가 붙지 않을 때 먼저 **포트가 열려 있는지** 확인합니다.

`localhost` 의 `8080`, `9999` 두 포트 중 **연결이 되는(열려 있는) 포트 번호만** `/tmp/open_ports.txt` 에 한 줄씩 저장하세요.',
   '`nc -z <호스트> <포트>` 는 데이터를 보내지 않고 연결만 시도하며, 성공하면 종료 코드 `0` 입니다. `for p in 8080 9999; do nc -z localhost $p && echo $p; done` 형태로 반복하세요.',
   'for p in 8080 9999; do nc -z localhost $p && echo $p; done > /tmp/open_ports.txt

# nc -z : 연결만 시도 (성공하면 && 뒤가 실행되어 포트 번호가 출력)',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/open_ports.txt)\\" = 8080 ]"]'),

  (18,  6, '서버가 대기 중인 포트 목록 만들기',
   '서버가 어떤 포트를 열고 있는지 한눈에 파악하는 것은 점검의 기본입니다.

지금 이 서버가 대기(listen) 중인 TCP **포트 번호**를 작은 순서로 한 줄씩 `/tmp/ports.txt` 에 저장하세요.',
   '`ss -ltn` 의 `Local Address` 열(4번째 칸)은 `주소:포트` 형태입니다. `awk ''NR>1 {print $4}''` 로 그 열을 뽑고(`NR>1` 은 제목 줄 제외), `awk -F: ''{print $NF}''` 로 마지막 `:` 뒤(포트)만 남기고, `sort -n` 으로 숫자 정렬하세요.',
   'ss -ltn | awk ''NR>1 {print $4}'' | awk -F: ''{print $NF}'' | sort -n > /tmp/ports.txt

# $NF : 마지막 칸 (:로 나눴을 때 포트 번호)',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & nohup etude-httpd 8081 >/dev/null 2>&1 & nohup etude-httpd 8082 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(paste -sd, - < /tmp/ports.txt)\\" = 8080,8081,8082 ]"]'),

  (18,  7, '이름으로 접속하기 (/etc/hosts)',
   'IP 대신 이름으로 접속하려면 이름과 IP 의 대응이 필요합니다. 가장 단순한 방법이 `/etc/hosts` 파일입니다.

1. `myapp.local` 이라는 이름이 `127.0.0.1` 을 가리키도록 `/etc/hosts` 에 등록합니다.
2. `http://myapp.local:8080/` 의 응답 본문을 `/tmp/by_name.txt` 에 저장합니다.',
   '`/etc/hosts` 한 줄의 형식은 `IP 이름` 입니다. 이 환경에서는 `echo ''127.0.0.1 myapp.local'' >> /etc/hosts` 로 추가할 수 있습니다(`>>` 는 이어쓰기). 등록한 뒤 `curl -s http://myapp.local:8080/` 로 확인하세요.',
   'echo ''127.0.0.1 myapp.local'' >> /etc/hosts
curl -s http://myapp.local:8080/ > /tmp/by_name.txt

# /etc/hosts : 이름 → IP 를 직접 적어 두는 파일',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "grep -q myapp.local /etc/hosts && [ \\"$(tr -d ''[:space:]'' < /tmp/by_name.txt)\\" = healthy ]"]'),

  (18,  8, '서비스를 띄우고 응답 확인하기',
   '서비스를 직접 띄운 뒤 제대로 응답하는지 확인하는 것이 배포의 기본 흐름입니다.

1. `etude-httpd 9090` 으로 작은 웹 서비스를 `9090` 포트에 **백그라운드**로 띄웁니다.
2. `curl` 로 상태 코드가 `200` 인지 확인합니다. (서비스는 떠 있는 상태로 남겨 두세요)',
   '명령 끝에 `&` 를 붙이면 백그라운드로 실행됩니다. 터미널과 무관하게 유지되도록 `nohup` 과 출력 리다이렉션을 함께 씁니다: `nohup etude-httpd 9090 >/dev/null 2>&1 &`. 서비스가 뜨는 데 1초쯤 걸리니 `sleep 1` 뒤에 확인하세요.',
   'nohup etude-httpd 9090 >/dev/null 2>&1 &
sleep 1
curl -s -o /dev/null -w ''%{http_code}'' http://localhost:9090/

# & : 백그라운드 실행, nohup : 터미널과 무관하게 유지',
   NULL,
   '["sh", "-c", "[ \\"$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:9090/)\\" = 200 ]"]'),

  (18,  9, '연결이 거부될 때의 종료 코드 확인하기',
   '`curl` 이 실패하는 이유에 따라 종료 코드가 다릅니다. 스크립트에서 장애 종류를 구분할 때 쓰입니다.

아무것도 떠 있지 않은 `9999` 포트에 `curl http://localhost:9999/` 를 실행하고, `curl` 의 **종료 코드**를 `/tmp/curl_rc.txt` 에 저장하세요.',
   '직전 명령의 종료 코드는 `$?` 입니다. 명령을 실행한 **바로 다음에** `echo $? > /tmp/curl_rc.txt` 하세요. `curl` 은 연결을 거부당하면 `7` 로 끝납니다.',
   'curl -s http://localhost:9999/; echo $? > /tmp/curl_rc.txt

# curl 종료 코드: 0 성공, 7 연결 실패, 28 시간 초과',
   NULL,
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/curl_rc.txt)\\" = 7 ]"]'),

  (18, 10, 'POST 요청으로 데이터 보내기',
   '웹 API 를 호출할 때는 데이터를 **POST** 로 보내는 일이 많습니다.

`http://localhost:8080/` 에 `name=etude` 를 POST 로 보내고, 응답 본문을 `/tmp/post.txt` 에 저장하세요.',
   '`curl -X POST -d ''<보낼데이터>'' <주소>` 형식입니다 (`-d` 만 써도 POST 가 됩니다). 응답 본문만 필요하니 `-s` 를 붙이고 `>` 로 저장하세요.',
   'curl -s -X POST -d ''name=etude'' http://localhost:8080/ > /tmp/post.txt

# -X POST : POST 방식, -d : 보낼 데이터',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/post.txt)\\" = got:name=etude ]"]');
