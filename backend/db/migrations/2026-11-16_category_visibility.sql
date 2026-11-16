-- 대분류 공개 제어 (docs/specs/spec_visibility_categories.md). 여러 번 실행해도 안전하다.
-- 대분류에 행이 없으면 공개로 본다 (기존 동작 유지).
CREATE TABLE IF NOT EXISTS category_setting (
  category  VARCHAR(50) PRIMARY KEY,
  is_public BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE IF NOT EXISTS category_access (
  category   VARCHAR(50) NOT NULL,
  user_id    INT NOT NULL,
  granted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (category, user_id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);
