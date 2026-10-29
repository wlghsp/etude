-- 세트 완료 기록 테이블과 기존 사용자 기록 이전. 여러 번 실행해도 안전하다 (IF NOT EXISTS, INSERT IGNORE + 고유 키).
CREATE TABLE IF NOT EXISTS set_completion (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  user_id             INT NOT NULL,
  quest_set_id        INT NOT NULL,
  session_id          VARCHAR(36) NOT NULL,
  completed_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  quest_count         INT NOT NULL,
  total_seconds       INT NOT NULL,
  hint_free_count     INT NOT NULL,
  solution_free_count INT NOT NULL,
  detail              JSON,
  UNIQUE KEY uq_set_completion_session (user_id, quest_set_id, session_id),
  KEY idx_set_completion_set (quest_set_id)
  -- 외래 키는 두지 않는다: 기존 테이블의 id 타입(INT/BIGINT)이 환경마다 달라 맞추기 어렵고, 이 값은 서버가 검증한 뒤에만 쓴다.
);

-- 이전: 지금까지 쌓인 quest_attempt 에서 세트의 모든 퀘스트를 통과한 적이 있는 (사용자, 세트)는 1번 완료한 것으로 옮긴다.
-- 세션 단위 정보가 없어 session_id 는 'backfill', 문제별 내역(detail)은 비운다. 시간·힌트·풀이는 문제별 최단 통과 기록을 쓴다.
INSERT IGNORE INTO set_completion
  (user_id, quest_set_id, session_id, completed_at, quest_count, total_seconds, hint_free_count, solution_free_count, detail)
SELECT b.user_id, b.quest_set_id, 'backfill', MAX(b.attempted_at), COUNT(*),
       COALESCE(SUM(b.elapsed_sec), 0), SUM(b.hint_used = 0), SUM(b.solution_used = 0), NULL
FROM (
  SELECT qa.user_id, qa.quest_set_id, qa.quest_id, qa.elapsed_sec, qa.hint_used, qa.solution_used, qa.attempted_at,
         ROW_NUMBER() OVER (
           PARTITION BY qa.user_id, qa.quest_id
           ORDER BY (qa.elapsed_sec IS NULL), qa.elapsed_sec, qa.attempted_at
         ) AS rn
  FROM quest_attempt qa
  WHERE qa.passed = 1
) b
WHERE b.rn = 1
GROUP BY b.user_id, b.quest_set_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM quest q WHERE q.quest_set_id = b.quest_set_id);
