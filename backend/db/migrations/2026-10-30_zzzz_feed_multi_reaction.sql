-- 소식 반응을 한 사람이 여러 개 달 수 있게: 기본 키를 (completion_id, user_id, kind) 로 넓힌다. 기존 행은 한 사람 한 반응이라 그대로 유효하다. docs/specs/spec_activity_feed.md
ALTER TABLE feed_like DROP PRIMARY KEY, ADD PRIMARY KEY (completion_id, user_id, kind);
