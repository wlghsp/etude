-- 세트 85 피드백 반영. 여러 번 실행해도 안전하다 (현재 값 조건). 원본: 03_quest_set85.sql
-- ① "모든 것은 파일이다" 정답 번호가 오답 보기를 가리키던 것을 바로잡는다 (2 → 0).
UPDATE quest SET answer_index = 0 WHERE quest_set_id = 85 AND order_index = 5 AND kind = 'choice' AND answer_index = 2;
-- ② 터미널 문제 3개에 붙어 있던 HAProxy 문서 링크를 문제 주제에 맞는 문서로 바꾼다.
UPDATE quest SET docs = '[{"title": "Linux execve(2) 매뉴얼", "url": "https://man7.org/linux/man-pages/man2/execve.2.html"}]' WHERE quest_set_id = 85 AND order_index = 9 AND docs LIKE '%docs.haproxy.org%';
UPDATE quest SET docs = '[{"title": "Linux proc(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/proc.5.html"}]' WHERE quest_set_id = 85 AND order_index = 10 AND docs LIKE '%docs.haproxy.org%';
UPDATE quest SET docs = '[{"title": "Linux null(4)·zero(4) 매뉴얼", "url": "https://man7.org/linux/man-pages/man4/null.4.html"}]' WHERE quest_set_id = 85 AND order_index = 11 AND docs LIKE '%docs.haproxy.org%';
