-- 시간 제한 세트(시험형): 제한 시간과 서버가 기록하는 시작 시각. docs/specs/spec_units.md
ALTER TABLE quest_set ADD COLUMN IF NOT EXISTS time_limit_sec INT NULL;
CREATE TABLE IF NOT EXISTS set_run (
  user_id      INT NOT NULL,
  quest_set_id INT NOT NULL,
  session_id   VARCHAR(36) NOT NULL,
  started_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, quest_set_id, session_id)
);
