ALTER TABLE quest_set MODIFY title VARCHAR(200) NOT NULL;
-- 큰 퀴즈 세트 나누기: 리눅스 28개 (원래 세트가 1부, 새 세트가 2부). docs/specs/spec_split_large_quiz_sets.md
-- 여러 번 실행해도 안전하다 (INSERT 는 NOT EXISTS, 문제 이동은 order_index 조건, 제목은 접미사 확인, 순서·기록 맞춤은 절대값/조건 UPDATE).
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 259, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 127 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 259);
UPDATE quest SET quest_set_id = 259, order_index = order_index - 16 WHERE quest_set_id = 127 AND order_index > 16;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 127 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 260, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 129 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 260);
UPDATE quest SET quest_set_id = 260, order_index = order_index - 16 WHERE quest_set_id = 129 AND order_index > 16;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 129 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 261, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 131 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 261);
UPDATE quest SET quest_set_id = 261, order_index = order_index - 16 WHERE quest_set_id = 131 AND order_index > 16;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 131 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 262, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 133 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 262);
UPDATE quest SET quest_set_id = 262, order_index = order_index - 15 WHERE quest_set_id = 133 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 133 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 263, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 135 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 263);
UPDATE quest SET quest_set_id = 263, order_index = order_index - 15 WHERE quest_set_id = 135 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 135 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 264, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 144 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 264);
UPDATE quest SET quest_set_id = 264, order_index = order_index - 15 WHERE quest_set_id = 144 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 144 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 265, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 146 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 265);
UPDATE quest SET quest_set_id = 265, order_index = order_index - 15 WHERE quest_set_id = 146 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 146 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 266, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 150 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 266);
UPDATE quest SET quest_set_id = 266, order_index = order_index - 15 WHERE quest_set_id = 150 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 150 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 267, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 152 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 267);
UPDATE quest SET quest_set_id = 267, order_index = order_index - 15 WHERE quest_set_id = 152 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 152 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 268, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 156 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 268);
UPDATE quest SET quest_set_id = 268, order_index = order_index - 15 WHERE quest_set_id = 156 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 156 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 269, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 162 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 269);
UPDATE quest SET quest_set_id = 269, order_index = order_index - 15 WHERE quest_set_id = 162 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 162 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 270, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 165 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 270);
UPDATE quest SET quest_set_id = 270, order_index = order_index - 15 WHERE quest_set_id = 165 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 165 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 271, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 169 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 271);
UPDATE quest SET quest_set_id = 271, order_index = order_index - 15 WHERE quest_set_id = 169 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 169 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 272, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 173 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 272);
UPDATE quest SET quest_set_id = 272, order_index = order_index - 15 WHERE quest_set_id = 173 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 173 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 273, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 177 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 273);
UPDATE quest SET quest_set_id = 273, order_index = order_index - 15 WHERE quest_set_id = 177 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 177 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 274, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 181 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 274);
UPDATE quest SET quest_set_id = 274, order_index = order_index - 15 WHERE quest_set_id = 181 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 181 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 275, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 185 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 275);
UPDATE quest SET quest_set_id = 275, order_index = order_index - 15 WHERE quest_set_id = 185 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 185 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 276, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 189 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 276);
UPDATE quest SET quest_set_id = 276, order_index = order_index - 15 WHERE quest_set_id = 189 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 189 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 277, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 193 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 277);
UPDATE quest SET quest_set_id = 277, order_index = order_index - 15 WHERE quest_set_id = 193 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 193 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 278, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 197 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 278);
UPDATE quest SET quest_set_id = 278, order_index = order_index - 15 WHERE quest_set_id = 197 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 197 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 279, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 201 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 279);
UPDATE quest SET quest_set_id = 279, order_index = order_index - 15 WHERE quest_set_id = 201 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 201 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 280, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 204 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 280);
UPDATE quest SET quest_set_id = 280, order_index = order_index - 15 WHERE quest_set_id = 204 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 204 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 281, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 207 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 281);
UPDATE quest SET quest_set_id = 281, order_index = order_index - 15 WHERE quest_set_id = 207 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 207 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 282, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 210 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 282);
UPDATE quest SET quest_set_id = 282, order_index = order_index - 15 WHERE quest_set_id = 210 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 210 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 283, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 213 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 283);
UPDATE quest SET quest_set_id = 283, order_index = order_index - 15 WHERE quest_set_id = 213 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 213 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 284, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 216 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 284);
UPDATE quest SET quest_set_id = 284, order_index = order_index - 15 WHERE quest_set_id = 216 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 216 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 285, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 219 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 285);
UPDATE quest SET quest_set_id = 285, order_index = order_index - 15 WHERE quest_set_id = 219 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 219 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 286, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 222 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 286);
UPDATE quest SET quest_set_id = 286, order_index = order_index - 15 WHERE quest_set_id = 222 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 222 AND title NOT LIKE '% (1/2)';
UPDATE quest_attempt a JOIN quest q ON q.id = a.quest_id SET a.quest_set_id = q.quest_set_id WHERE a.quest_set_id <> q.quest_set_id;
UPDATE feedback f JOIN quest q ON q.id = f.quest_id SET f.quest_set_id = q.quest_set_id WHERE f.quest_set_id <> q.quest_set_id;
UPDATE quest_set SET display_order = 5 WHERE id = 42;
UPDATE quest_set SET display_order = 6 WHERE id = 85;
UPDATE quest_set SET display_order = 7 WHERE id = 127;
UPDATE quest_set SET display_order = 8 WHERE id = 259;
UPDATE quest_set SET display_order = 9 WHERE id = 129;
UPDATE quest_set SET display_order = 10 WHERE id = 260;
UPDATE quest_set SET display_order = 11 WHERE id = 131;
UPDATE quest_set SET display_order = 12 WHERE id = 261;
UPDATE quest_set SET display_order = 13 WHERE id = 133;
UPDATE quest_set SET display_order = 14 WHERE id = 262;
UPDATE quest_set SET display_order = 15 WHERE id = 135;
UPDATE quest_set SET display_order = 16 WHERE id = 263;
UPDATE quest_set SET display_order = 17 WHERE id = 144;
UPDATE quest_set SET display_order = 18 WHERE id = 264;
UPDATE quest_set SET display_order = 19 WHERE id = 146;
UPDATE quest_set SET display_order = 20 WHERE id = 265;
UPDATE quest_set SET display_order = 21 WHERE id = 150;
UPDATE quest_set SET display_order = 22 WHERE id = 266;
UPDATE quest_set SET display_order = 23 WHERE id = 152;
UPDATE quest_set SET display_order = 24 WHERE id = 267;
UPDATE quest_set SET display_order = 25 WHERE id = 156;
UPDATE quest_set SET display_order = 26 WHERE id = 268;
UPDATE quest_set SET display_order = 27 WHERE id = 162;
UPDATE quest_set SET display_order = 28 WHERE id = 269;
UPDATE quest_set SET display_order = 29 WHERE id = 165;
UPDATE quest_set SET display_order = 30 WHERE id = 270;
UPDATE quest_set SET display_order = 31 WHERE id = 169;
UPDATE quest_set SET display_order = 32 WHERE id = 271;
UPDATE quest_set SET display_order = 33 WHERE id = 173;
UPDATE quest_set SET display_order = 34 WHERE id = 272;
UPDATE quest_set SET display_order = 35 WHERE id = 177;
UPDATE quest_set SET display_order = 36 WHERE id = 273;
UPDATE quest_set SET display_order = 37 WHERE id = 181;
UPDATE quest_set SET display_order = 38 WHERE id = 274;
UPDATE quest_set SET display_order = 39 WHERE id = 185;
UPDATE quest_set SET display_order = 40 WHERE id = 275;
UPDATE quest_set SET display_order = 41 WHERE id = 189;
UPDATE quest_set SET display_order = 42 WHERE id = 276;
UPDATE quest_set SET display_order = 43 WHERE id = 193;
UPDATE quest_set SET display_order = 44 WHERE id = 277;
UPDATE quest_set SET display_order = 45 WHERE id = 197;
UPDATE quest_set SET display_order = 46 WHERE id = 278;
UPDATE quest_set SET display_order = 47 WHERE id = 201;
UPDATE quest_set SET display_order = 48 WHERE id = 279;
UPDATE quest_set SET display_order = 49 WHERE id = 204;
UPDATE quest_set SET display_order = 50 WHERE id = 280;
UPDATE quest_set SET display_order = 51 WHERE id = 207;
UPDATE quest_set SET display_order = 52 WHERE id = 281;
UPDATE quest_set SET display_order = 53 WHERE id = 210;
UPDATE quest_set SET display_order = 54 WHERE id = 282;
UPDATE quest_set SET display_order = 55 WHERE id = 213;
UPDATE quest_set SET display_order = 56 WHERE id = 283;
UPDATE quest_set SET display_order = 57 WHERE id = 216;
UPDATE quest_set SET display_order = 58 WHERE id = 284;
UPDATE quest_set SET display_order = 59 WHERE id = 219;
UPDATE quest_set SET display_order = 60 WHERE id = 285;
UPDATE quest_set SET display_order = 61 WHERE id = 222;
UPDATE quest_set SET display_order = 62 WHERE id = 286;
UPDATE quest_set SET display_order = 63 WHERE id = 1;
UPDATE quest_set SET display_order = 64 WHERE id = 2;
UPDATE quest_set SET display_order = 65 WHERE id = 43;
UPDATE quest_set SET display_order = 66 WHERE id = 45;
UPDATE quest_set SET display_order = 67 WHERE id = 3;
UPDATE quest_set SET display_order = 68 WHERE id = 34;
UPDATE quest_set SET display_order = 69 WHERE id = 65;
UPDATE quest_set SET display_order = 70 WHERE id = 21;
UPDATE quest_set SET display_order = 71 WHERE id = 50;
UPDATE quest_set SET display_order = 72 WHERE id = 47;
UPDATE quest_set SET display_order = 73 WHERE id = 44;
UPDATE quest_set SET display_order = 74 WHERE id = 48;
UPDATE quest_set SET display_order = 75 WHERE id = 49;
UPDATE quest_set SET display_order = 76 WHERE id = 9;
UPDATE quest_set SET display_order = 77 WHERE id = 7;
UPDATE quest_set SET display_order = 78 WHERE id = 15;
UPDATE quest_set SET display_order = 79 WHERE id = 30;
UPDATE quest_set SET display_order = 80 WHERE id = 17;
UPDATE quest_set SET display_order = 81 WHERE id = 105;
UPDATE quest_set SET display_order = 82 WHERE id = 35;
UPDATE quest_set SET display_order = 83 WHERE id = 4;
UPDATE quest_set SET display_order = 84 WHERE id = 18;
UPDATE quest_set SET display_order = 85 WHERE id = 106;
UPDATE quest_set SET display_order = 86 WHERE id = 36;
UPDATE quest_set SET display_order = 87 WHERE id = 81;
UPDATE quest_set SET display_order = 88 WHERE id = 235;
UPDATE quest_set SET display_order = 89 WHERE id = 24;
UPDATE quest_set SET display_order = 90 WHERE id = 123;
UPDATE quest_set SET display_order = 91 WHERE id = 10;
UPDATE quest_set SET display_order = 92 WHERE id = 16;
UPDATE quest_set SET display_order = 93 WHERE id = 27;
UPDATE quest_set SET display_order = 94 WHERE id = 32;
UPDATE quest_set SET display_order = 95 WHERE id = 75;
UPDATE quest_set SET display_order = 96 WHERE id = 124;
UPDATE quest_set SET display_order = 97 WHERE id = 28;
UPDATE quest_set SET display_order = 98 WHERE id = 226;
UPDATE quest_set SET display_order = 99 WHERE id = 229;
UPDATE quest_set SET display_order = 100 WHERE id = 232;
