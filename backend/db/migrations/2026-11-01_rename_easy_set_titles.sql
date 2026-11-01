-- 세트 127~132 의 제목에서 '쉬운 문제 N:' 접두를 뺀다 (제목 규칙: docs/specs/spec_content_reinforcement.md).
-- 이미 적용한 02_quest_set.sql / 03_quest_set*.sql 의 제목을 고쳐도 서버 DB 는 바뀌지 않으므로 새 마이그레이션으로 맞춘다.
-- 옛 제목 그대로일 때만 바꾼다 (다른 값으로 고친 제목은 건드리지 않고, 여러 번 실행해도 안전하다).

UPDATE quest_set SET title = '파일과 폴더 명령 한 줄씩' WHERE id = 127 AND title = '리눅스 쉬운 문제 1: 파일과 폴더 명령 한 줄씩';
UPDATE quest_set SET title = '용어와 kubectl 기본 명령 한 줄씩' WHERE id = 128 AND title = 'k8s 쉬운 문제 1: 용어와 kubectl 기본 명령 한 줄씩';
UPDATE quest_set SET title = '권한, 프로세스, 용량, 텍스트 도구 한 줄씩' WHERE id = 129 AND title = '리눅스 쉬운 문제 2: 권한, 프로세스, 용량, 텍스트 도구 한 줄씩';
UPDATE quest_set SET title = 'YAML 필드와 Pod 상태 읽기' WHERE id = 130 AND title = 'k8s 쉬운 문제 2: YAML 필드와 Pod 상태 읽기';
UPDATE quest_set SET title = '네트워크 기본과 텍스트 도구 한 줄씩' WHERE id = 131 AND title = '리눅스 쉬운 문제 3: 네트워크 기본과 텍스트 도구 한 줄씩';
UPDATE quest_set SET title = '네임스페이스, ConfigMap, Secret 한 줄씩' WHERE id = 132 AND title = 'k8s 쉬운 문제 3: 네임스페이스, ConfigMap, Secret 한 줄씩';
