-- 잘못된 setup_cmd 바로잡기. 세트 1 #13·세트 3 #12 의 setup_cmd 가 ["sh","-c",null] 이라 환경 준비가 실패했다 (설정이 필요 없는 문제이므로 NULL).
-- 세트 1 #12(객관식)는 "터미널에서 직접 확인"하라면서 폴더가 없었다: 각 폴더의 notes.txt 내용을 폴더 이름과 같게 만들어 둔다.
UPDATE quest SET setup_cmd = NULL WHERE (quest_set_id = 1 AND order_index = 13) OR (quest_set_id = 3 AND order_index = 12);
UPDATE quest SET setup_cmd = '["sh", "-c", "mkdir -p /tmp/h/user/project/src && echo src > /tmp/h/user/project/src/notes.txt && echo project > /tmp/h/user/project/notes.txt && echo user > /tmp/h/user/notes.txt && echo h > /tmp/h/notes.txt"]' WHERE quest_set_id = 1 AND order_index = 12;
