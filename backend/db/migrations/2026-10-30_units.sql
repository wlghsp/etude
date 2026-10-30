-- 단원(unit): 분야 아래 세트 묶음. 한 단원의 세트는 quest_set.display_order 가 이어져야 한다. docs/specs/spec_units.md
CREATE TABLE IF NOT EXISTS unit (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  category      VARCHAR(50) NOT NULL,
  title         VARCHAR(100) NOT NULL,
  display_order INT NOT NULL DEFAULT 0
);
ALTER TABLE quest_set ADD COLUMN IF NOT EXISTS unit_id INT NULL;
ALTER TABLE quest_set ADD COLUMN IF NOT EXISTS is_review BOOLEAN NOT NULL DEFAULT FALSE;
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO unit (id, category, title, display_order) SELECT 2, '리눅스', '도구 다루기', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 2);
INSERT INTO unit (id, category, title, display_order) SELECT 3, '리눅스', '네트워크와 통신', 30 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 3);
INSERT INTO unit (id, category, title, display_order) SELECT 4, '리눅스', '운영과 장애 대응', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 4);
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO unit (id, category, title, display_order) SELECT 6, 'k8s', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 6);
INSERT INTO unit (id, category, title, display_order) SELECT 7, 'k8s', '워크로드와 설정', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 7);
INSERT INTO unit (id, category, title, display_order) SELECT 8, 'k8s', '스토리지와 네트워크', 30 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 8);
INSERT INTO unit (id, category, title, display_order) SELECT 9, 'k8s', '운영과 트러블슈팅', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 9);
UPDATE quest_set SET unit_id = 1 WHERE id IN (1,2,3,34,21);
UPDATE quest_set SET unit_id = 2 WHERE id IN (9,7,15,30,17,35);
UPDATE quest_set SET unit_id = 3 WHERE id IN (4,18,36);
UPDATE quest_set SET unit_id = 4 WHERE id IN (24,10,16,27,32,28);
UPDATE quest_set SET unit_id = 5 WHERE id IN (5,11,8);
UPDATE quest_set SET unit_id = 6 WHERE id IN (6,20,33,19);
UPDATE quest_set SET unit_id = 7 WHERE id IN (12,22);
UPDATE quest_set SET unit_id = 8 WHERE id IN (13,25,37,26);
UPDATE quest_set SET unit_id = 9 WHERE id IN (14,23,31,29);
