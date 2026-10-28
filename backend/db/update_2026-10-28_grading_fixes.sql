-- 채점 검증 러너(V1)가 찾은 결함 수정: 아무것도 안 해도 채점이 통과하던 퀘스트 4건.
-- 원본은 03_quest_set02.sql, 03_quest_set07.sql, 03_quest_set09.sql (새로 만든 DB에는 자동 반영된다).
-- 이미 떠 있는 DB에는 이 파일을 한 번 실행한다. 대상은 (quest_set_id, order_index)로 지정한다.

UPDATE quest SET
  description = '/tmp/answer.txt 파일에서 "done" 문자열이 포함된 줄을 찾아 결과를 /tmp/grep_result.txt 에 저장하세요.',
  hint        = 'grep 명령어와 리다이렉션(>)을 사용하세요.',
  solution    = 'grep "done" /tmp/answer.txt > /tmp/grep_result.txt',
  grade_cmd   = '["grep", "-q", "done", "/tmp/grep_result.txt"]'
WHERE quest_set_id = 2 AND order_index = 4;

UPDATE quest SET
  description = '/tmp/files.tar 아카이브에 어떤 파일이 들어있는지 목록을 확인하고, 결과를 /tmp/tar_list.txt 에 저장하세요.',
  hint        = 'tar -tvf 옵션과 리다이렉션(>)을 사용하세요. t=목록확인, v=상세출력(권한/날짜 포함), f=파일명 지정.',
  solution    = 'tar -tvf /tmp/files.tar > /tmp/tar_list.txt',
  grade_cmd   = '["sh", "-c", "grep -q a.txt /tmp/tar_list.txt"]'
WHERE quest_set_id = 7 AND order_index = 2;

UPDATE quest SET
  description = '/tmp/archive.tar.gz 아카이브의 내용을 확인하고, 결과를 /tmp/targz_list.txt 에 저장하세요.',
  hint        = 'tar -tzvf 옵션과 리다이렉션(>)을 사용하세요. z 옵션이 있어야 .gz 파일을 읽을 수 있습니다.',
  solution    = 'tar -tzvf /tmp/archive.tar.gz > /tmp/targz_list.txt',
  grade_cmd   = '["sh", "-c", "grep -q a.txt /tmp/targz_list.txt"]'
WHERE quest_set_id = 7 AND order_index = 5;

UPDATE quest SET
  description = '/tmp/undo.txt 를 vim으로 열어 맨 아래에 redo_done 한 줄을 추가하세요. u 로 취소해 본 뒤 Ctrl+r 로 다시 실행해서 그 줄이 돌아온 상태로 저장하세요. 파일에 original content 와 redo_done 이 모두 있어야 합니다.',
  hint        = 'o 로 새 줄을 열어 redo_done 입력 → ESC → u (취소) → Ctrl+r (다시 실행) → :wq',
  solution    = 'vim /tmp/undo.txt 후 o → redo_done → ESC → u → Ctrl+r → :wq',
  grade_cmd   = '["sh", "-c", "grep -q ''original content'' /tmp/undo.txt && grep -q redo_done /tmp/undo.txt"]'
WHERE quest_set_id = 9 AND order_index = 11;
