-- 채점 검증 러너(V3)가 찾은 linux-ssh 세트(4) 결함 3건 수정.
-- 원본은 03_quest_set04.sql (새로 만든 DB에는 자동 반영된다). 이미 떠 있는 DB에는 이 파일을 한 번 실행한다.

-- 4.1: 채점식이 curl을 스스로 다시 실행해서 아무것도 안 해도 통과했다. 응답을 파일로 저장하게 하고 그 파일을 채점한다
UPDATE quest SET
  description = 'curl 명령어로 http://example.com 에 GET 요청을 보내고, 응답을 /tmp/curl_result.txt 에 저장하세요.',
  hint        = 'curl 명령어와 리다이렉션(>)을 사용하세요.',
  solution    = 'curl http://example.com > /tmp/curl_result.txt',
  grade_cmd   = '["sh", "-c", "grep -qi html /tmp/curl_result.txt"]'
WHERE quest_set_id = 4 AND order_index = 1;

-- 4.3: 4.1과 같은 문제(ping을 채점식이 스스로 실행). 응답 대신 "3 packets transmitted"가 적힌 결과 파일을 채점한다
UPDATE quest SET
  description = '8.8.8.8 주소로 ping을 3번만 보내고, 결과를 /tmp/ping_result.txt 에 저장하세요.',
  hint        = 'ping -c 옵션으로 횟수를 지정하고, 리다이렉션(>)으로 저장하세요.',
  solution    = 'ping -c 3 8.8.8.8 > /tmp/ping_result.txt',
  grade_cmd   = '["sh", "-c", "grep -q ''3 packets transmitted'' /tmp/ping_result.txt"]'
WHERE quest_set_id = 4 AND order_index = 3;

-- 4.4: etude-ssh 이미지에 nginx가 없어 setup이 실패하고 80번 포트가 존재하지 않아 정답을 해도 풀 수 없었다.
--      이미지는 건드리지 않고 setup을 sshd 시작으로, 채점을 22번 포트로 바꾼다
UPDATE quest SET
  setup_cmd = '["sh", "-c", "/usr/sbin/sshd"]',
  grade_cmd = '["sh", "-c", "grep -q '':22 '' /tmp/ports.txt"]'
WHERE quest_set_id = 4 AND order_index = 4;
