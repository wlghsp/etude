-- 활동 피드(docs/specs/spec_activity_feed.md): 좋아요, 댓글, 소식 탭을 마지막으로 본 시각. 외래 키는 두지 않는다 (set_completion 과 같은 이유).
CREATE TABLE IF NOT EXISTS feed_like (
  completion_id INT NOT NULL,
  user_id       INT NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (completion_id, user_id),
  KEY idx_feed_like_user (user_id, created_at)
);
CREATE TABLE IF NOT EXISTS feed_comment (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  completion_id INT NOT NULL,
  user_id       INT NOT NULL,
  body          VARCHAR(300) NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at    DATETIME NULL,
  KEY idx_feed_comment_completion (completion_id, created_at),
  KEY idx_feed_comment_user (user_id, created_at)
);
CREATE TABLE IF NOT EXISTS feed_seen (
  user_id INT PRIMARY KEY,
  seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
