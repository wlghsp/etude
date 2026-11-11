-- 큰 퀴즈 세트 나누기: 도커 21개 (원래 세트가 1부, 새 세트가 2부). docs/specs/spec_split_large_quiz_sets.md
-- 여러 번 실행해도 안전하다 (INSERT 는 NOT EXISTS, 문제 이동은 order_index 조건, 제목은 접미사 확인, 순서·기록 맞춤은 절대값/조건 UPDATE).
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 238, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 137 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 238);
UPDATE quest SET quest_set_id = 238, order_index = order_index - 15 WHERE quest_set_id = 137 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 137 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 239, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 142 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 239);
UPDATE quest SET quest_set_id = 239, order_index = order_index - 15 WHERE quest_set_id = 142 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 142 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 240, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 148 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 240);
UPDATE quest SET quest_set_id = 240, order_index = order_index - 15 WHERE quest_set_id = 148 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 148 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 241, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 154 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 241);
UPDATE quest SET quest_set_id = 241, order_index = order_index - 15 WHERE quest_set_id = 154 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 154 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 242, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 160 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 242);
UPDATE quest SET quest_set_id = 242, order_index = order_index - 15 WHERE quest_set_id = 160 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 160 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 243, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 167 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 243);
UPDATE quest SET quest_set_id = 243, order_index = order_index - 15 WHERE quest_set_id = 167 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 167 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 244, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 171 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 244);
UPDATE quest SET quest_set_id = 244, order_index = order_index - 15 WHERE quest_set_id = 171 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 171 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 245, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 175 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 245);
UPDATE quest SET quest_set_id = 245, order_index = order_index - 15 WHERE quest_set_id = 175 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 175 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 246, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 179 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 246);
UPDATE quest SET quest_set_id = 246, order_index = order_index - 15 WHERE quest_set_id = 179 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 179 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 247, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 183 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 247);
UPDATE quest SET quest_set_id = 247, order_index = order_index - 15 WHERE quest_set_id = 183 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 183 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 248, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 187 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 248);
UPDATE quest SET quest_set_id = 248, order_index = order_index - 15 WHERE quest_set_id = 187 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 187 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 249, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 191 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 249);
UPDATE quest SET quest_set_id = 249, order_index = order_index - 15 WHERE quest_set_id = 191 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 191 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 250, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 195 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 250);
UPDATE quest SET quest_set_id = 250, order_index = order_index - 15 WHERE quest_set_id = 195 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 195 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 251, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 199 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 251);
UPDATE quest SET quest_set_id = 251, order_index = order_index - 15 WHERE quest_set_id = 199 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 199 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 252, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 203 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 252);
UPDATE quest SET quest_set_id = 252, order_index = order_index - 15 WHERE quest_set_id = 203 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 203 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 253, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 206 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 253);
UPDATE quest SET quest_set_id = 253, order_index = order_index - 15 WHERE quest_set_id = 206 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 206 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 254, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 209 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 254);
UPDATE quest SET quest_set_id = 254, order_index = order_index - 15 WHERE quest_set_id = 209 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 209 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 255, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 212 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 255);
UPDATE quest SET quest_set_id = 255, order_index = order_index - 15 WHERE quest_set_id = 212 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 212 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 256, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 215 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 256);
UPDATE quest SET quest_set_id = 256, order_index = order_index - 15 WHERE quest_set_id = 215 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 215 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 257, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 218 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 257);
UPDATE quest SET quest_set_id = 257, order_index = order_index - 15 WHERE quest_set_id = 218 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 218 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 258, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 221 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 258);
UPDATE quest SET quest_set_id = 258, order_index = order_index - 15 WHERE quest_set_id = 221 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 221 AND title NOT LIKE '% (1/2)';
UPDATE quest_attempt a JOIN quest q ON q.id = a.quest_id SET a.quest_set_id = q.quest_set_id WHERE a.quest_set_id <> q.quest_set_id;
UPDATE feedback f JOIN quest q ON q.id = f.quest_id SET f.quest_set_id = q.quest_set_id WHERE f.quest_set_id <> q.quest_set_id;
UPDATE quest_set SET display_order = 175 WHERE id = 40;
UPDATE quest_set SET display_order = 176 WHERE id = 77;
UPDATE quest_set SET display_order = 177 WHERE id = 5;
UPDATE quest_set SET display_order = 178 WHERE id = 137;
UPDATE quest_set SET display_order = 179 WHERE id = 238;
UPDATE quest_set SET display_order = 180 WHERE id = 171;
UPDATE quest_set SET display_order = 181 WHERE id = 244;
UPDATE quest_set SET display_order = 182 WHERE id = 191;
UPDATE quest_set SET display_order = 183 WHERE id = 249;
UPDATE quest_set SET display_order = 184 WHERE id = 195;
UPDATE quest_set SET display_order = 185 WHERE id = 250;
UPDATE quest_set SET display_order = 186 WHERE id = 199;
UPDATE quest_set SET display_order = 187 WHERE id = 251;
UPDATE quest_set SET display_order = 188 WHERE id = 203;
UPDATE quest_set SET display_order = 189 WHERE id = 252;
UPDATE quest_set SET display_order = 190 WHERE id = 212;
UPDATE quest_set SET display_order = 191 WHERE id = 255;
UPDATE quest_set SET display_order = 192 WHERE id = 215;
UPDATE quest_set SET display_order = 193 WHERE id = 256;
UPDATE quest_set SET display_order = 194 WHERE id = 160;
UPDATE quest_set SET display_order = 195 WHERE id = 242;
UPDATE quest_set SET display_order = 196 WHERE id = 225;
UPDATE quest_set SET display_order = 197 WHERE id = 231;
UPDATE quest_set SET display_order = 198 WHERE id = 11;
UPDATE quest_set SET display_order = 199 WHERE id = 167;
UPDATE quest_set SET display_order = 200 WHERE id = 243;
UPDATE quest_set SET display_order = 201 WHERE id = 218;
UPDATE quest_set SET display_order = 202 WHERE id = 257;
UPDATE quest_set SET display_order = 203 WHERE id = 183;
UPDATE quest_set SET display_order = 204 WHERE id = 247;
UPDATE quest_set SET display_order = 205 WHERE id = 221;
UPDATE quest_set SET display_order = 206 WHERE id = 258;
UPDATE quest_set SET display_order = 207 WHERE id = 154;
UPDATE quest_set SET display_order = 208 WHERE id = 241;
UPDATE quest_set SET display_order = 209 WHERE id = 187;
UPDATE quest_set SET display_order = 210 WHERE id = 248;
UPDATE quest_set SET display_order = 211 WHERE id = 8;
UPDATE quest_set SET display_order = 212 WHERE id = 234;
UPDATE quest_set SET display_order = 213 WHERE id = 142;
UPDATE quest_set SET display_order = 214 WHERE id = 239;
UPDATE quest_set SET display_order = 215 WHERE id = 179;
UPDATE quest_set SET display_order = 216 WHERE id = 246;
UPDATE quest_set SET display_order = 217 WHERE id = 209;
UPDATE quest_set SET display_order = 218 WHERE id = 254;
UPDATE quest_set SET display_order = 219 WHERE id = 228;
UPDATE quest_set SET display_order = 220 WHERE id = 148;
UPDATE quest_set SET display_order = 221 WHERE id = 240;
UPDATE quest_set SET display_order = 222 WHERE id = 175;
UPDATE quest_set SET display_order = 223 WHERE id = 245;
UPDATE quest_set SET display_order = 224 WHERE id = 206;
UPDATE quest_set SET display_order = 225 WHERE id = 253;
UPDATE quest_set SET display_order = 226 WHERE id = 237;
UPDATE quest_set SET display_order = 227 WHERE id = 38;
UPDATE quest_set SET display_order = 228 WHERE id = 39;
UPDATE quest_set SET display_order = 229 WHERE id = 97;

