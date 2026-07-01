INSERT INTO sandbox (type, image, binds, persistent, description) VALUES
  ('linux',             'ubuntu',      NULL,                                               FALSE, '기본 리눅스 환경. 파일 조작, 검색, 권한 등 일반 실습용.'),
  ('linux-ssh',         'etude-ssh',   NULL,                                               FALSE, 'SSH 데몬 포함 환경. curl, ping, scp, rsync 등 네트워크/파일 전송 실습용.'),
  ('docker',            'docker:dind', NULL,                                               FALSE, 'Docker-in-Docker 환경. 호스트와 격리된 독립 Docker 데몬. docker 명령어 실습용.'),
  ('docker-persistent', 'docker:dind', NULL,                                               TRUE,  'Docker-in-Docker 환경 (persistent). 퀘스트를 넘겨도 동일 컨테이너 유지. 이미지 반입 등 상태가 이어지는 실습용.'),
  ('k8s',               'etude-k8s',   '["{KUBECONFIG_HOST_PATH}:/root/.kube/config:ro"]', FALSE, 'kubectl 실습 환경. k3d 로컬 클러스터 연결.'),
  ('k8s-isolated',      'etude-k8s',   NULL,                                               FALSE, 'kubectl 실습 환경 (vcluster 완전 격리 — KLID CMP 현장실습용). binds는 세션마다 pool에서 동적으로 배정되므로 DB에 고정하지 않음.');
