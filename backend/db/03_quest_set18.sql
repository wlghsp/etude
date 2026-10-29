-- 세트 18: 리눅스 네트워크 진단 (order 1~10)
-- 서비스(etude-httpd)와 curl, nc, ss, /etc/hosts 로 연결 문제를 확인한다. etude-httpd 는 etude-linux 이미지에 들어 있다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (18,  1, 'HTTP 상태 코드 확인하기',
   'localhost:8080 서비스가 응답하는지 확인하려고 합니다. 응답의 HTTP 상태 코드(숫자만)를 /tmp/status.txt 에 저장하세요.',
   'curl 의 -s 는 진행 표시를 끄고, -o /dev/null 은 본문을 버리고, -w ''%{http_code}'' 는 상태 코드를 출력합니다.',
   'curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8080/ > /tmp/status.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/status.txt)\\\" = 200 ]"]'),

  (18,  2, '응답 본문 저장하기',
   'http://localhost:8080/ 의 응답 본문을 /tmp/body.txt 에 저장하세요.',
   'curl -s URL 은 본문만 출력합니다. 리다이렉션(>)으로 저장하세요.',
   'curl -s http://localhost:8080/ > /tmp/body.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/body.txt)\\\" = healthy ]"]'),

  (18,  3, '응답 헤더 확인하기',
   'http://localhost:8080/ 응답 헤더 중 X-Env 의 값만 /tmp/env.txt 에 저장하세요.',
   'curl -I 는 헤더만 가져옵니다. grep -i 로 헤더 이름을 찾고 awk 로 값을 뽑습니다. 줄 끝의 \r 은 tr -d 로 지웁니다.',
   'curl -sI http://localhost:8080/ | grep -i ''^x-env'' | awk ''{print $2}'' | tr -d ''\r'' > /tmp/env.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/env.txt)\\\" = prod ]"]'),

  (18,  4, '헬스체크 상태 확인하기',
   'http://localhost:8080/health 의 HTTP 상태 코드(숫자만)를 /tmp/health.txt 에 저장하세요. 서비스가 정상인지 판단하는 첫걸음입니다.',
   '-w ''%{http_code}'' 로 상태 코드를 출력합니다. 200 은 정상, 5xx 는 서버 오류입니다.',
   'curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8080/health > /tmp/health.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/health.txt)\\\" = 503 ]"]'),

  (18,  5, '열려 있는 포트 찾기',
   'localhost 의 8080, 9999 포트 중 연결되는(열려 있는) 포트 번호만 /tmp/open_ports.txt 에 한 줄씩 저장하세요.',
   'nc -z 호스트 포트 는 데이터를 보내지 않고 연결만 시도하며, 성공하면 종료 코드 0 입니다. for 문과 && 를 조합하세요.',
   'for p in 8080 9999; do nc -z localhost $p && echo $p; done > /tmp/open_ports.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/open_ports.txt)\\\" = 8080 ]"]'),

  (18,  6, 'listen 중인 포트 목록 만들기',
   '이 서버가 listen 중인 TCP 포트 번호를 작은 순서로 한 줄씩 /tmp/ports.txt 에 저장하세요.',
   'ss -ltn 의 Local Address 열에서 마지막 : 뒤가 포트입니다. awk -F: 로 나누고 sort -n 으로 정렬합니다.',
   'ss -ltn | awk ''NR>1 {print $4}'' | awk -F: ''{print $NF}'' | sort -n > /tmp/ports.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & nohup etude-httpd 8081 >/dev/null 2>&1 & nohup etude-httpd 8082 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(paste -sd, - < /tmp/ports.txt)\\\" = 8080,8081,8082 ]"]'),

  (18,  7, '이름으로 접속하기',
   'myapp.local 이라는 이름이 127.0.0.1 을 가리키게 /etc/hosts 에 등록하고, http://myapp.local:8080/ 의 응답 본문을 /tmp/by_name.txt 에 저장하세요.',
   '/etc/hosts 의 형식은 "IP 이름" 입니다. 이 환경에서는 echo ... >> /etc/hosts 로 추가할 수 있습니다.',
   'echo ''127.0.0.1 myapp.local'' >> /etc/hosts
curl -s http://myapp.local:8080/ > /tmp/by_name.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "grep -q myapp.local /etc/hosts && [ \\\"$(tr -d ''[:space:]'' < /tmp/by_name.txt)\\\" = healthy ]"]'),

  (18,  8, '서비스를 띄우고 확인하기',
   'etude-httpd 9090 으로 작은 웹 서비스를 9090 포트에 백그라운드로 띄우고, 응답 상태 코드가 200 인지 확인할 수 있게 해 두세요.',
   '명령 끝에 & 를 붙이면 백그라운드로 실행됩니다. nohup 과 출력 리다이렉션을 함께 쓰면 안전합니다. 뜨는 데 1초쯤 걸립니다.',
   'nohup etude-httpd 9090 >/dev/null 2>&1 &
sleep 1
curl -s -o /dev/null -w ''%{http_code}'' http://localhost:9090/',
   NULL,
   '["sh", "-c", "[ \\\"$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:9090/)\\\" = 200 ]"]'),

  (18,  9, '연결 실패의 종료 코드 확인하기',
   '아무것도 떠 있지 않은 9999 포트로 curl http://localhost:9999/ 를 실행하고, curl 의 종료 코드를 /tmp/curl_rc.txt 에 저장하세요.',
   '직전 명령의 종료 코드는 $? 입니다. curl 은 연결을 거부당하면 7 로 끝납니다.',
   'curl -s http://localhost:9999/; echo $? > /tmp/curl_rc.txt',
   NULL,
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/curl_rc.txt)\\\" = 7 ]"]'),

  (18, 10, 'POST 요청 보내기',
   'http://localhost:8080/ 에 name=etude 를 POST 로 보내고, 응답 본문을 /tmp/post.txt 에 저장하세요.',
   'curl -X POST -d 본문 URL 형식입니다. -d 만 써도 POST 가 됩니다.',
   'curl -s -X POST -d ''name=etude'' http://localhost:8080/ > /tmp/post.txt',
   '["sh", "-c", "nohup etude-httpd 8080 >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/post.txt)\\\" = got:name=etude ]"]');
