-- 피드백 이미지 첨부 테이블. 여러 번 실행해도 안전하다. 원본: 00_schema.sql, docs/specs/spec_feedback_attachments.md
CREATE TABLE IF NOT EXISTS feedback_attachment (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  feedback_id INT NOT NULL,
  stored_name VARCHAR(100) NOT NULL,
  mime        VARCHAR(50) NOT NULL,
  size_bytes  INT NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE
);
