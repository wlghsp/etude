-- 인프라 대분류를 가상화·스토리지·네트워크로 나눈다. 여러 번 실행해도 안전하다. docs/specs/spec_infra_category_split.md
UPDATE unit SET category = '가상화' WHERE id = 16 AND category = '인프라';
UPDATE unit SET category = '스토리지', title = '스토리지 기초' WHERE id = 21 AND category = '인프라';
INSERT INTO unit (id, category, title, display_order) SELECT 43, '네트워크', '연결이 안 될 때', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 43);
UPDATE quest_set SET category = '가상화' WHERE id = 55 AND category = '인프라';
UPDATE quest_set SET category = '스토리지' WHERE id = 61 AND category = '인프라';
UPDATE quest_set SET category = '네트워크', unit_id = 43 WHERE id = 117 AND category = '인프라';
