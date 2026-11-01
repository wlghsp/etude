-- 세트 설명에서 '쉬운 문제' 표기를 뺀다 (규칙: docs/specs/spec_content_reinforcement.md, 2026-11-01).
-- 이미 적용한 02_quest_set.sql / 마이그레이션의 설명을 고쳐도 서버 DB 는 바뀌지 않으므로 새 마이그레이션으로 맞춘다.
-- 해당 문구가 들어 있는 설명에서 그 문구만 바꾼다 (설명의 다른 부분은 건드리지 않고, 여러 번 실행해도 안전하다).

UPDATE quest_set SET description = REPLACE(description, '쉬운 문제로 반복합니다', '반복합니다') WHERE id IN (127, 128, 129, 130, 131, 132) AND description LIKE '%쉬운 문제로 반복합니다%';
UPDATE quest_set SET description = REPLACE(description, '쉬운 문제로 익힙니다', '문제로 익힙니다') WHERE id IN (105, 106, 107, 108, 110) AND description LIKE '%쉬운 문제로 익힙니다%';
UPDATE quest_set SET description = REPLACE(description, '쉬운 문제 모음입니다', '문제 모음입니다') WHERE id IN (125) AND description LIKE '%쉬운 문제 모음입니다%';
