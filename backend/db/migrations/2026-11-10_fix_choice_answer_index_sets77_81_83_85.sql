-- 객관식 정답 번호 바로잡기 (피드백 #4 점검). 정답 내용은 0번 보기에 있는데 번호가 다른 보기를 가리키던 12건. 여러 번 실행해도 안전하다 (현재 값 조건). 원본: 03_quest_set77·81·83·85.sql
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 77 AND order_index = 4 AND kind = 'choice' AND answer_index = 1;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 77 AND order_index = 5 AND kind = 'choice' AND answer_index = 2;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 81 AND order_index = 2 AND kind = 'choice' AND answer_index = 3;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 81 AND order_index = 4 AND kind = 'choice' AND answer_index = 2;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 81 AND order_index = 5 AND kind = 'choice' AND answer_index = 1;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 81 AND order_index = 6 AND kind = 'choice' AND answer_index = 3;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 81 AND order_index = 8 AND kind = 'choice' AND answer_index = 2;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 83 AND order_index = 4 AND kind = 'choice' AND answer_index = 1;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 83 AND order_index = 5 AND kind = 'choice' AND answer_index = 2;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 83 AND order_index = 7 AND kind = 'choice' AND answer_index = 3;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 83 AND order_index = 8 AND kind = 'choice' AND answer_index = 1;
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 85 AND order_index = 4 AND kind = 'choice' AND answer_index = 1;
