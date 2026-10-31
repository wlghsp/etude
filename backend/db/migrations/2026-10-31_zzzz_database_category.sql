-- 대분류 '데이터베이스' 신설: 단원 20(MariaDB 운영) 재정의, 단원 30(SQL 기초)·31(Redis) 추가, 세트 11개의 분야·단원·순서 이동. 여러 번 실행해도 안전하다. 원본: 02_quest_set.sql, 05_display_order.sql, 06_units.sql
INSERT INTO unit (id, category, title, display_order) SELECT 30, '데이터베이스', 'SQL 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 30);
INSERT INTO unit (id, category, title, display_order) SELECT 31, '데이터베이스', 'Redis', 30 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 31);
UPDATE unit SET category = '데이터베이스', title = 'MariaDB 운영', display_order = 20 WHERE id = 20;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 20), display_order = 540 WHERE id = 59;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 31), display_order = 545 WHERE id = 60;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 31), display_order = 547 WHERE id = 83;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 20), display_order = 541 WHERE id = 87;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 20), display_order = 542 WHERE id = 91;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 31), display_order = 546 WHERE id = 99;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 31), display_order = 548 WHERE id = 102;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 20), display_order = 543 WHERE id = 109;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 31), display_order = 549 WHERE id = 118;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 30), display_order = 538 WHERE id = 125;
UPDATE quest_set SET category = '데이터베이스', unit_id = (SELECT id FROM unit WHERE id = 30), display_order = 539 WHERE id = 126;
