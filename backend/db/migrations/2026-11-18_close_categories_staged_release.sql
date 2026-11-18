-- 단계적 공개: 1차는 리눅스·k8s 만 연다. 나머지 분야는 비공개(관리자·접근 허용자만).
-- INSERT IGNORE: 관리자가 화면에서 이미 바꾼 분야는 덮어쓰지 않는다.
INSERT IGNORE INTO category_setting (category, is_public) VALUES
  ('도커', FALSE),
  ('Git', FALSE),
  ('미들웨어', FALSE),
  ('데이터베이스', FALSE),
  ('OpenStack', FALSE),
  ('네트워크', FALSE),
  ('가상화', FALSE),
  ('스토리지', FALSE);
