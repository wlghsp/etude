CREATE TABLE sandbox (
  type        VARCHAR(20) PRIMARY KEY,
  image       VARCHAR(100) NOT NULL,
  binds       JSON,
  persistent  BOOLEAN NOT NULL DEFAULT FALSE,
  description TEXT
);

CREATE TABLE quest_set (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  description  TEXT,
  sandbox_type VARCHAR(20) NOT NULL DEFAULT 'linux',
  category     VARCHAR(50) NOT NULL DEFAULT '기타',
  is_public    BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (sandbox_type) REFERENCES sandbox(type)
);

CREATE TABLE quest (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  quest_set_id INT NOT NULL,
  order_index  INT NOT NULL DEFAULT 0,
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL,
  hint         TEXT,
  solution     TEXT,
  setup_cmd    JSON,
  grade_cmd    JSON NOT NULL,
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);

CREATE TABLE user (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(200) NOT NULL UNIQUE,
  password   VARCHAR(200) NOT NULL,
  role       ENUM('member', 'admin') NOT NULL DEFAULT 'member',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quest_set_access (
  quest_set_id INT NOT NULL,
  user_id      INT NOT NULL,
  granted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (quest_set_id, user_id),
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id),
  FOREIGN KEY (user_id)      REFERENCES user(id)
);

-- 중복 허용 — 반복 시도가 쌓이는 구조 (Phase 9 분석의 원본 데이터)
CREATE TABLE quest_attempt (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  user_id        INT NOT NULL,
  quest_id       INT NOT NULL,
  quest_set_id   INT NOT NULL,
  session_id     VARCHAR(36) NOT NULL,
  elapsed_sec    INT,
  hint_used      BOOLEAN NOT NULL DEFAULT FALSE,
  solution_used  BOOLEAN NOT NULL DEFAULT FALSE,
  passed         BOOLEAN NOT NULL DEFAULT FALSE,
  attempted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)      REFERENCES user(id),
  FOREIGN KEY (quest_id)     REFERENCES quest(id),
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);

CREATE TABLE IF NOT EXISTS feedback (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT,
  page         VARCHAR(100),
  quest_id     INT,
  quest_set_id INT,
  body         TEXT NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id)
);