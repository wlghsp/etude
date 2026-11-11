ALTER TABLE quest_set MODIFY title VARCHAR(200) NOT NULL;
-- 큰 퀴즈 세트 나누기: Git 14개 (원래 세트가 1부, 새 세트가 2부). docs/specs/spec_split_large_quiz_sets.md
-- 여러 번 실행해도 안전하다 (INSERT 는 NOT EXISTS, 문제 이동은 order_index 조건, 제목은 접미사 확인, 순서·기록 맞춤은 절대값/조건 UPDATE).
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 315, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 138 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 315);
UPDATE quest SET quest_set_id = 315, order_index = order_index - 15 WHERE quest_set_id = 138 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 138 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 316, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 143 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 316);
UPDATE quest SET quest_set_id = 316, order_index = order_index - 15 WHERE quest_set_id = 143 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 143 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 317, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 149 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 317);
UPDATE quest SET quest_set_id = 317, order_index = order_index - 15 WHERE quest_set_id = 149 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 149 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 318, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 155 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 318);
UPDATE quest SET quest_set_id = 318, order_index = order_index - 15 WHERE quest_set_id = 155 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 155 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 319, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 161 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 319);
UPDATE quest SET quest_set_id = 319, order_index = order_index - 15 WHERE quest_set_id = 161 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 161 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 320, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 168 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 320);
UPDATE quest SET quest_set_id = 320, order_index = order_index - 15 WHERE quest_set_id = 168 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 168 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 321, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 172 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 321);
UPDATE quest SET quest_set_id = 321, order_index = order_index - 15 WHERE quest_set_id = 172 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 172 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 322, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 176 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 322);
UPDATE quest SET quest_set_id = 322, order_index = order_index - 15 WHERE quest_set_id = 176 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 176 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 323, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 180 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 323);
UPDATE quest SET quest_set_id = 323, order_index = order_index - 15 WHERE quest_set_id = 180 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 180 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 324, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 184 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 324);
UPDATE quest SET quest_set_id = 324, order_index = order_index - 15 WHERE quest_set_id = 184 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 184 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 325, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 188 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 325);
UPDATE quest SET quest_set_id = 325, order_index = order_index - 15 WHERE quest_set_id = 188 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 188 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 326, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 192 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 326);
UPDATE quest SET quest_set_id = 326, order_index = order_index - 15 WHERE quest_set_id = 192 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 192 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 327, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 196 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 327);
UPDATE quest SET quest_set_id = 327, order_index = order_index - 15 WHERE quest_set_id = 196 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 196 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 328, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 200 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 328);
UPDATE quest SET quest_set_id = 328, order_index = order_index - 15 WHERE quest_set_id = 200 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 200 AND title NOT LIKE '% (1/2)';
UPDATE quest_attempt a JOIN quest q ON q.id = a.quest_id SET a.quest_set_id = q.quest_set_id WHERE a.quest_set_id <> q.quest_set_id;
UPDATE feedback f JOIN quest q ON q.id = f.quest_id SET f.quest_set_id = q.quest_set_id WHERE f.quest_set_id <> q.quest_set_id;
UPDATE quest_set SET display_order = 405 WHERE id = 138;
UPDATE quest_set SET display_order = 406 WHERE id = 315;
UPDATE quest_set SET display_order = 407 WHERE id = 143;
UPDATE quest_set SET display_order = 408 WHERE id = 316;
UPDATE quest_set SET display_order = 409 WHERE id = 149;
UPDATE quest_set SET display_order = 410 WHERE id = 317;
UPDATE quest_set SET display_order = 411 WHERE id = 155;
UPDATE quest_set SET display_order = 412 WHERE id = 318;
UPDATE quest_set SET display_order = 413 WHERE id = 161;
UPDATE quest_set SET display_order = 414 WHERE id = 319;
UPDATE quest_set SET display_order = 415 WHERE id = 168;
UPDATE quest_set SET display_order = 416 WHERE id = 320;
UPDATE quest_set SET display_order = 417 WHERE id = 172;
UPDATE quest_set SET display_order = 418 WHERE id = 321;
UPDATE quest_set SET display_order = 419 WHERE id = 176;
UPDATE quest_set SET display_order = 420 WHERE id = 322;
UPDATE quest_set SET display_order = 421 WHERE id = 180;
UPDATE quest_set SET display_order = 422 WHERE id = 323;
UPDATE quest_set SET display_order = 423 WHERE id = 184;
UPDATE quest_set SET display_order = 424 WHERE id = 324;
UPDATE quest_set SET display_order = 425 WHERE id = 188;
UPDATE quest_set SET display_order = 426 WHERE id = 325;
UPDATE quest_set SET display_order = 427 WHERE id = 192;
UPDATE quest_set SET display_order = 428 WHERE id = 326;
UPDATE quest_set SET display_order = 429 WHERE id = 196;
UPDATE quest_set SET display_order = 430 WHERE id = 327;
UPDATE quest_set SET display_order = 431 WHERE id = 200;
UPDATE quest_set SET display_order = 432 WHERE id = 328;
UPDATE quest_set SET display_order = 433 WHERE id = 52;
UPDATE quest_set SET display_order = 434 WHERE id = 96;
UPDATE quest_set SET display_order = 435 WHERE id = 53;
UPDATE quest_set SET display_order = 436 WHERE id = 54;
UPDATE quest_set SET display_order = 437 WHERE id = 94;
UPDATE quest_set SET display_order = 438 WHERE id = 56;
UPDATE quest_set SET display_order = 439 WHERE id = 95;
