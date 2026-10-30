CREATE TABLE sandbox (
  type        VARCHAR(20) PRIMARY KEY,
  image       VARCHAR(100) NOT NULL,
  binds       JSON,
  persistent  BOOLEAN NOT NULL DEFAULT FALSE,
  description TEXT
);

CREATE TABLE unit (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  category      VARCHAR(50) NOT NULL,
  title         VARCHAR(100) NOT NULL,
  display_order INT NOT NULL DEFAULT 0
);
CREATE TABLE quest_set (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  description  TEXT,
  sandbox_type VARCHAR(20) NOT NULL DEFAULT 'linux',
  category     VARCHAR(50) NOT NULL DEFAULT '기타',
  is_public    BOOLEAN NOT NULL DEFAULT TRUE,
  display_order INT NOT NULL DEFAULT 0,
  unit_id      INT NULL,
  is_review    BOOLEAN NOT NULL DEFAULT FALSE,
  icon         VARCHAR(16) NULL, -- 홈의 세트 길에 보이는 이모지 (08_set_icons.sql)
  time_limit_sec INT NULL, -- 시험형 세트의 제한 시간(초). NULL 이면 제한 없음
  FOREIGN KEY (sandbox_type) REFERENCES sandbox(type),
  FOREIGN KEY (unit_id) REFERENCES unit(id)
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
  -- 객관식 퀴즈(docs/specs/spec_quiz_sets.md): kind='choice' 이면 choices/answer_index/explanation 을 쓰고 grade_cmd 는 []
  kind         VARCHAR(10) NOT NULL DEFAULT 'terminal',
  choices      JSON NULL,
  answer_index INT NULL,
  explanation  TEXT NULL,
  -- 순서 맞추기(order)·빈칸 채우기(fill) (docs/specs/spec_question_types.md): answer_spec 은 서버 전용 정답, template 은 빈칸이 {0} {1} 로 표시된 명령 줄
  answer_spec  JSON NULL,
  template     TEXT NULL,
  -- 참고 공식 문서 링크 [{title, url}] (https 만): 문제 화면 위쪽에 보인다 (docs/specs/spec_question_docs.md)
  docs         JSON NULL,
  -- 조건별 채점(docs/specs/spec_grade_checks.md): [{label, cmd}]. 없으면 grade_cmd 하나로 채점한다.
  checks       JSON NULL,
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

-- 세트 완료 기록: 한 번 입장해서 세트의 모든 퀘스트를 통과하면 1건. 서버가 quest_attempt 로 확인한 뒤에만 저장한다.
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

-- 활동 피드(docs/specs/spec_activity_feed.md): 좋아요, 댓글, 소식 탭을 마지막으로 본 시각. 외래 키는 두지 않는다 (set_completion 과 같은 이유).
CREATE TABLE IF NOT EXISTS feed_like (
  completion_id INT NOT NULL,
  user_id       INT NOT NULL,
  kind          VARCHAR(10) NOT NULL DEFAULT 'like', -- 반응 종류: like, clap, strong, fire (한 사람 한 반응)
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

-- 시간 제한 세트(시험형)의 시작 시각: 서버가 기록하고 마감을 판단한다. 외래 키는 두지 않는다 (set_completion 과 같은 이유). docs/specs/spec_units.md
CREATE TABLE IF NOT EXISTS set_run (
  user_id      INT NOT NULL,
  quest_set_id INT NOT NULL,
  session_id   VARCHAR(36) NOT NULL,
  started_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, quest_set_id, session_id)
);
