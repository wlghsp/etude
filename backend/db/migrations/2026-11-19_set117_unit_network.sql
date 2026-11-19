-- 세트 117(인프라 장애 상황집: 연결이 안 될 때)을 네트워크 단원 43 으로 바로잡는다.
-- 2026-10-31_infra_trouble_set117.sql 이 분류는 '네트워크'인 이 세트를 스토리지 단원 21 에 넣어서,
-- 네트워크 코스에 "스토리지 기초" 단원이 보이고 단원 69 의 세트 사이에 끼어 있었다. (06_units.sql 의 원본은 단원 43)
-- 여러 번 실행해도 안전하다: 아직 단원 21 에 있을 때만 옮긴다. 순서는 네트워크 분야의 마지막 세트(647) 다음.
UPDATE quest_set SET unit_id = 43, display_order = 648
WHERE id = 117 AND unit_id = 21 AND category = '네트워크'
  AND EXISTS (SELECT 1 FROM unit WHERE id = 43 AND category = '네트워크');
