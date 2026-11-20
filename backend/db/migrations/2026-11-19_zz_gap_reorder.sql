-- 빈틈 보강 새 세트(502~541)를 선행 관계에 맞는 자리로 재배치한다 (2026-11-19, scripts/content-gen/reorder_gap_sets.py).
-- 분야별 display_order 를 단원 순서 → 단원 안 순서대로 다시 매기고, 선행 세트가 다른 단원에 있던 상황집 4개의 단원을 옮긴다.
-- 세트 id 는 그대로라 완료 기록은 영향이 없다. 같은 SQL 을 다시 실행해도 결과가 같다.
UPDATE quest_set SET display_order = 618 WHERE id = 599;
UPDATE quest_set SET display_order = 619 WHERE id = 600;
UPDATE quest_set SET display_order = 620 WHERE id = 602;
UPDATE quest_set SET display_order = 633 WHERE id = 601;
