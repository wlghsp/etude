-- 빈틈 보강 새 세트(502~541)를 선행 관계에 맞는 자리로 재배치한다 (2026-11-19, scripts/content-gen/reorder_gap_sets.py).
-- 분야별 display_order 를 단원 순서 → 단원 안 순서대로 다시 매기고, 선행 세트가 다른 단원에 있던 상황집 4개의 단원을 옮긴다.
-- 세트 id 는 그대로라 완료 기록은 영향이 없다. 같은 SQL 을 다시 실행해도 결과가 같다.
UPDATE quest_set SET display_order = 623 WHERE id = 614;
UPDATE quest_set SET display_order = 624 WHERE id = 610;
UPDATE quest_set SET display_order = 629 WHERE id = 568;
UPDATE quest_set SET display_order = 632 WHERE id = 593;
UPDATE quest_set SET display_order = 633 WHERE id = 594;
UPDATE quest_set SET display_order = 634 WHERE id = 595;
UPDATE quest_set SET display_order = 635 WHERE id = 596;
UPDATE quest_set SET display_order = 636 WHERE id = 597;
UPDATE quest_set SET display_order = 637 WHERE id = 598;
UPDATE quest_set SET display_order = 638 WHERE id = 582;
