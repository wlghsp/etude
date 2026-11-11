ALTER TABLE quest_set MODIFY title VARCHAR(200) NOT NULL;
-- 큰 퀴즈 세트 나누기: 데이터베이스 6개 (원래 세트가 1부, 새 세트가 2부). docs/specs/spec_split_large_quiz_sets.md
-- 여러 번 실행해도 안전하다 (INSERT 는 NOT EXISTS, 문제 이동은 order_index 조건, 제목은 접미사 확인, 순서·기록 맞춤은 절대값/조건 UPDATE).
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 329, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 139 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 329);
UPDATE quest SET quest_set_id = 329, order_index = order_index - 15 WHERE quest_set_id = 139 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 139 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 330, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 140 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 330);
UPDATE quest SET quest_set_id = 330, order_index = order_index - 15 WHERE quest_set_id = 140 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 140 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 331, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 141 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 331);
UPDATE quest SET quest_set_id = 331, order_index = order_index - 15 WHERE quest_set_id = 141 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 141 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 332, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 158 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 332);
UPDATE quest SET quest_set_id = 332, order_index = order_index - 15 WHERE quest_set_id = 158 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 158 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 333, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 159 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 333);
UPDATE quest SET quest_set_id = 333, order_index = order_index - 15 WHERE quest_set_id = 159 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 159 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 334, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 164 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 334);
UPDATE quest SET quest_set_id = 334, order_index = order_index - 15 WHERE quest_set_id = 164 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 164 AND title NOT LIKE '% (1/2)';
UPDATE quest_attempt a JOIN quest q ON q.id = a.quest_id SET a.quest_set_id = q.quest_set_id WHERE a.quest_set_id <> q.quest_set_id;
UPDATE feedback f JOIN quest q ON q.id = f.quest_id SET f.quest_set_id = q.quest_set_id WHERE f.quest_set_id <> q.quest_set_id;
UPDATE quest_set SET display_order = 538 WHERE id = 125;
UPDATE quest_set SET display_order = 539 WHERE id = 126;
UPDATE quest_set SET display_order = 540 WHERE id = 139;
UPDATE quest_set SET display_order = 541 WHERE id = 329;
UPDATE quest_set SET display_order = 542 WHERE id = 140;
UPDATE quest_set SET display_order = 543 WHERE id = 330;
UPDATE quest_set SET display_order = 544 WHERE id = 141;
UPDATE quest_set SET display_order = 545 WHERE id = 331;
UPDATE quest_set SET display_order = 546 WHERE id = 159;
UPDATE quest_set SET display_order = 547 WHERE id = 333;
UPDATE quest_set SET display_order = 548 WHERE id = 164;
UPDATE quest_set SET display_order = 549 WHERE id = 334;
UPDATE quest_set SET display_order = 550 WHERE id = 158;
UPDATE quest_set SET display_order = 551 WHERE id = 332;
UPDATE quest_set SET display_order = 552 WHERE id = 59;
UPDATE quest_set SET display_order = 553 WHERE id = 87;
UPDATE quest_set SET display_order = 554 WHERE id = 91;
UPDATE quest_set SET display_order = 555 WHERE id = 109;
UPDATE quest_set SET display_order = 556 WHERE id = 60;
UPDATE quest_set SET display_order = 557 WHERE id = 99;
UPDATE quest_set SET display_order = 558 WHERE id = 83;
UPDATE quest_set SET display_order = 559 WHERE id = 102;
UPDATE quest_set SET display_order = 560 WHERE id = 118;
