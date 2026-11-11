ALTER TABLE quest_set MODIFY title VARCHAR(200) NOT NULL;
-- 큰 퀴즈 세트 나누기: k8s 28개 (원래 세트가 1부, 새 세트가 2부). docs/specs/spec_split_large_quiz_sets.md
-- 여러 번 실행해도 안전하다 (INSERT 는 NOT EXISTS, 문제 이동은 order_index 조건, 제목은 접미사 확인, 순서·기록 맞춤은 절대값/조건 UPDATE).
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 287, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 128 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 287);
UPDATE quest SET quest_set_id = 287, order_index = order_index - 16 WHERE quest_set_id = 128 AND order_index > 16;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 128 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 288, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 130 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 288);
UPDATE quest SET quest_set_id = 288, order_index = order_index - 15 WHERE quest_set_id = 130 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 130 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 289, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 132 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 289);
UPDATE quest SET quest_set_id = 289, order_index = order_index - 16 WHERE quest_set_id = 132 AND order_index > 16;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 132 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 290, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 134 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 290);
UPDATE quest SET quest_set_id = 290, order_index = order_index - 15 WHERE quest_set_id = 134 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 134 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 291, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 136 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 291);
UPDATE quest SET quest_set_id = 291, order_index = order_index - 15 WHERE quest_set_id = 136 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 136 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 292, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 145 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 292);
UPDATE quest SET quest_set_id = 292, order_index = order_index - 15 WHERE quest_set_id = 145 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 145 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 293, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 147 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 293);
UPDATE quest SET quest_set_id = 293, order_index = order_index - 15 WHERE quest_set_id = 147 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 147 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 294, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 151 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 294);
UPDATE quest SET quest_set_id = 294, order_index = order_index - 15 WHERE quest_set_id = 151 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 151 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 295, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 153 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 295);
UPDATE quest SET quest_set_id = 295, order_index = order_index - 15 WHERE quest_set_id = 153 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 153 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 296, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 157 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 296);
UPDATE quest SET quest_set_id = 296, order_index = order_index - 15 WHERE quest_set_id = 157 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 157 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 297, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 163 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 297);
UPDATE quest SET quest_set_id = 297, order_index = order_index - 15 WHERE quest_set_id = 163 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 163 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 298, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 166 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 298);
UPDATE quest SET quest_set_id = 298, order_index = order_index - 15 WHERE quest_set_id = 166 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 166 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 299, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 170 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 299);
UPDATE quest SET quest_set_id = 299, order_index = order_index - 15 WHERE quest_set_id = 170 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 170 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 300, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 174 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 300);
UPDATE quest SET quest_set_id = 300, order_index = order_index - 15 WHERE quest_set_id = 174 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 174 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 301, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 178 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 301);
UPDATE quest SET quest_set_id = 301, order_index = order_index - 15 WHERE quest_set_id = 178 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 178 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 302, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 182 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 302);
UPDATE quest SET quest_set_id = 302, order_index = order_index - 15 WHERE quest_set_id = 182 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 182 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 303, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 186 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 303);
UPDATE quest SET quest_set_id = 303, order_index = order_index - 15 WHERE quest_set_id = 186 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 186 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 304, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 190 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 304);
UPDATE quest SET quest_set_id = 304, order_index = order_index - 15 WHERE quest_set_id = 190 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 190 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 305, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 194 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 305);
UPDATE quest SET quest_set_id = 305, order_index = order_index - 15 WHERE quest_set_id = 194 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 194 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 306, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 198 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 306);
UPDATE quest SET quest_set_id = 306, order_index = order_index - 15 WHERE quest_set_id = 198 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 198 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 307, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 202 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 307);
UPDATE quest SET quest_set_id = 307, order_index = order_index - 15 WHERE quest_set_id = 202 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 202 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 308, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 205 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 308);
UPDATE quest SET quest_set_id = 308, order_index = order_index - 15 WHERE quest_set_id = 205 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 205 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 309, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 208 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 309);
UPDATE quest SET quest_set_id = 309, order_index = order_index - 15 WHERE quest_set_id = 208 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 208 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 310, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 211 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 310);
UPDATE quest SET quest_set_id = 310, order_index = order_index - 15 WHERE quest_set_id = 211 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 211 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 311, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 214 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 311);
UPDATE quest SET quest_set_id = 311, order_index = order_index - 15 WHERE quest_set_id = 214 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 214 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 312, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 217 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 312);
UPDATE quest SET quest_set_id = 312, order_index = order_index - 15 WHERE quest_set_id = 217 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 217 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 313, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 220 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 313);
UPDATE quest SET quest_set_id = 313, order_index = order_index - 15 WHERE quest_set_id = 220 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 220 AND title NOT LIKE '% (1/2)';
INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)
SELECT 314, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set
WHERE id = 223 AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 314);
UPDATE quest SET quest_set_id = 314, order_index = order_index - 15 WHERE quest_set_id = 223 AND order_index > 15;
UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = 223 AND title NOT LIKE '% (1/2)';
UPDATE quest_attempt a JOIN quest q ON q.id = a.quest_id SET a.quest_set_id = q.quest_set_id WHERE a.quest_set_id <> q.quest_set_id;
UPDATE feedback f JOIN quest q ON q.id = f.quest_id SET f.quest_set_id = q.quest_set_id WHERE f.quest_set_id <> q.quest_set_id;
UPDATE quest_set SET display_order = 204 WHERE id = 128;
UPDATE quest_set SET display_order = 205 WHERE id = 287;
UPDATE quest_set SET display_order = 206 WHERE id = 130;
UPDATE quest_set SET display_order = 207 WHERE id = 288;
UPDATE quest_set SET display_order = 208 WHERE id = 41;
UPDATE quest_set SET display_order = 209 WHERE id = 78;
UPDATE quest_set SET display_order = 210 WHERE id = 46;
UPDATE quest_set SET display_order = 211 WHERE id = 79;
UPDATE quest_set SET display_order = 212 WHERE id = 6;
UPDATE quest_set SET display_order = 213 WHERE id = 20;
UPDATE quest_set SET display_order = 214 WHERE id = 107;
UPDATE quest_set SET display_order = 215 WHERE id = 33;
UPDATE quest_set SET display_order = 216 WHERE id = 19;
UPDATE quest_set SET display_order = 217 WHERE id = 224;
UPDATE quest_set SET display_order = 218 WHERE id = 132;
UPDATE quest_set SET display_order = 219 WHERE id = 289;
UPDATE quest_set SET display_order = 220 WHERE id = 134;
UPDATE quest_set SET display_order = 221 WHERE id = 290;
UPDATE quest_set SET display_order = 222 WHERE id = 136;
UPDATE quest_set SET display_order = 223 WHERE id = 291;
UPDATE quest_set SET display_order = 224 WHERE id = 145;
UPDATE quest_set SET display_order = 225 WHERE id = 292;
UPDATE quest_set SET display_order = 226 WHERE id = 147;
UPDATE quest_set SET display_order = 227 WHERE id = 293;
UPDATE quest_set SET display_order = 228 WHERE id = 151;
UPDATE quest_set SET display_order = 229 WHERE id = 294;
UPDATE quest_set SET display_order = 230 WHERE id = 153;
UPDATE quest_set SET display_order = 231 WHERE id = 295;
UPDATE quest_set SET display_order = 232 WHERE id = 157;
UPDATE quest_set SET display_order = 233 WHERE id = 296;
UPDATE quest_set SET display_order = 234 WHERE id = 163;
UPDATE quest_set SET display_order = 235 WHERE id = 297;
UPDATE quest_set SET display_order = 236 WHERE id = 166;
UPDATE quest_set SET display_order = 237 WHERE id = 298;
UPDATE quest_set SET display_order = 238 WHERE id = 170;
UPDATE quest_set SET display_order = 239 WHERE id = 299;
UPDATE quest_set SET display_order = 240 WHERE id = 174;
UPDATE quest_set SET display_order = 241 WHERE id = 300;
UPDATE quest_set SET display_order = 242 WHERE id = 178;
UPDATE quest_set SET display_order = 243 WHERE id = 301;
UPDATE quest_set SET display_order = 244 WHERE id = 182;
UPDATE quest_set SET display_order = 245 WHERE id = 302;
UPDATE quest_set SET display_order = 246 WHERE id = 186;
UPDATE quest_set SET display_order = 247 WHERE id = 303;
UPDATE quest_set SET display_order = 248 WHERE id = 190;
UPDATE quest_set SET display_order = 249 WHERE id = 304;
UPDATE quest_set SET display_order = 250 WHERE id = 194;
UPDATE quest_set SET display_order = 251 WHERE id = 305;
UPDATE quest_set SET display_order = 252 WHERE id = 198;
UPDATE quest_set SET display_order = 253 WHERE id = 306;
UPDATE quest_set SET display_order = 254 WHERE id = 202;
UPDATE quest_set SET display_order = 255 WHERE id = 307;
UPDATE quest_set SET display_order = 256 WHERE id = 205;
UPDATE quest_set SET display_order = 257 WHERE id = 308;
UPDATE quest_set SET display_order = 258 WHERE id = 208;
UPDATE quest_set SET display_order = 259 WHERE id = 309;
UPDATE quest_set SET display_order = 260 WHERE id = 211;
UPDATE quest_set SET display_order = 261 WHERE id = 310;
UPDATE quest_set SET display_order = 262 WHERE id = 214;
UPDATE quest_set SET display_order = 263 WHERE id = 311;
UPDATE quest_set SET display_order = 264 WHERE id = 217;
UPDATE quest_set SET display_order = 265 WHERE id = 312;
UPDATE quest_set SET display_order = 266 WHERE id = 220;
UPDATE quest_set SET display_order = 267 WHERE id = 313;
UPDATE quest_set SET display_order = 268 WHERE id = 223;
UPDATE quest_set SET display_order = 269 WHERE id = 314;
UPDATE quest_set SET display_order = 270 WHERE id = 12;
UPDATE quest_set SET display_order = 271 WHERE id = 22;
UPDATE quest_set SET display_order = 272 WHERE id = 236;
UPDATE quest_set SET display_order = 273 WHERE id = 80;
UPDATE quest_set SET display_order = 274 WHERE id = 13;
UPDATE quest_set SET display_order = 275 WHERE id = 122;
UPDATE quest_set SET display_order = 276 WHERE id = 25;
UPDATE quest_set SET display_order = 277 WHERE id = 108;
UPDATE quest_set SET display_order = 278 WHERE id = 37;
UPDATE quest_set SET display_order = 279 WHERE id = 26;
UPDATE quest_set SET display_order = 280 WHERE id = 23;
UPDATE quest_set SET display_order = 281 WHERE id = 31;
UPDATE quest_set SET display_order = 282 WHERE id = 29;
UPDATE quest_set SET display_order = 283 WHERE id = 227;
UPDATE quest_set SET display_order = 284 WHERE id = 230;
UPDATE quest_set SET display_order = 285 WHERE id = 233;
UPDATE quest_set SET display_order = 286 WHERE id = 119;
UPDATE quest_set SET display_order = 287 WHERE id = 120;
UPDATE quest_set SET display_order = 288 WHERE id = 121;
UPDATE quest_set SET display_order = 289 WHERE id = 14;
