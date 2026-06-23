CREATE TABLE quest_set (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(100) NOT NULL,
  description TEXT
);

CREATE TABLE quest (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  quest_set_id INT NOT NULL,
  order_index  INT NOT NULL DEFAULT 0,
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL,
  hint         TEXT,
  solution     TEXT,
  grade_cmd    JSON NOT NULL,
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);

INSERT INTO quest_set (title, description) VALUES
  ('리눅스 기초', '기본적인 리눅스 명령어를 실습합니다.');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, grade_cmd) VALUES
  (1, 1, '/tmp/hello 디렉토리 만들기',
   '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
   'mkdir 명령어를 사용하세요.',
   'mkdir /tmp/hello',
   '["test", "-d", "/tmp/hello"]'),
  (1, 2, '파일에 내용 쓰기',
   '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
   'echo 명령어와 리다이렉션(>)을 사용하세요.',
   'echo "done" > /tmp/answer.txt',
   '["grep", "-q", "done", "/tmp/answer.txt"]'),
  (1, 3, '숨김 파일 만들기',
   '/tmp 경로에 .hidden 이라는 이름의 빈 파일을 만드세요.',
   'touch 명령어를 사용하세요. 파일명 앞에 .을 붙이면 숨김 파일이 됩니다.',
   'touch /tmp/.hidden',
   '["test", "-f", "/tmp/.hidden"]');
