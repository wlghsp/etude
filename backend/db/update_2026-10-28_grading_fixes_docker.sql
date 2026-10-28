-- 채점 검증 러너(V2)가 찾은 docker 세트 결함 3건 수정.
-- 원본은 03_quest_set05.sql, 03_quest_set08.sql (새로 만든 DB에는 자동 반영된다). 이미 떠 있는 DB에는 이 파일을 한 번 실행한다.

-- 5.7: `grep -qv`는 "my-nginx가 없는 줄이 하나라도 있으면 성공"이라 헤더 줄 때문에 컨테이너가 떠 있어도 통과했다
UPDATE quest SET grade_cmd = '["sh", "-c", "! docker ps | grep -q my-nginx"]'
WHERE quest_set_id = 5 AND order_index = 7;

-- 8.6: docker:dind 이미지에는 curl이 없어 정답을 해도 영원히 실패했다 (busybox wget은 있다)
UPDATE quest SET grade_cmd = '["sh", "-c", "wget -qO- http://localhost:5000/v2/alpine/tags/list | grep -q latest"]'
WHERE quest_set_id = 8 AND order_index = 6;

-- 8.7: 채점식이 8.5와 같아 풀기 전부터 통과했다. 실행 결과를 파일로 저장하게 하고 그 파일을 채점한다
UPDATE quest SET
  description = '로컬 레지스트리(localhost:5000)에서 alpine 이미지를 받아 echo hello 명령어를 실행하고, 출력 결과를 /tmp/run_result.txt 에 저장하세요. 이것이 실제 배포 환경에서 내부 레지스트리 이미지를 사용하는 패턴입니다.',
  hint        = 'docker run localhost:5000/alpine:latest echo hello 를 실행하고 리다이렉션(>)으로 저장하세요.',
  solution    = 'docker run localhost:5000/alpine:latest echo hello > /tmp/run_result.txt',
  grade_cmd   = '["sh", "-c", "grep -q hello /tmp/run_result.txt"]'
WHERE quest_set_id = 8 AND order_index = 7;
