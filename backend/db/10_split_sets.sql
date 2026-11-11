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

