-- DB 실습용 샌드박스 타입 linux-db. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 01_sandbox.sql
INSERT INTO sandbox (type, image, binds, persistent, description)
SELECT 'linux-db', 'etude-linux-db', NULL, FALSE, 'MariaDB 서버·클라이언트가 설치된 리눅스 환경. mysqldump 백업·복원 등 DB 실습용 (서버는 퀘스트 setup 이 필요할 때 띄운다).'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sandbox WHERE type = 'linux-db');
