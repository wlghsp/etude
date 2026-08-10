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
