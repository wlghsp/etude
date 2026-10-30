-- 소식 반응 종류(좋아요 외 박수·힘내·불꽃): 한 사람 한 반응이라 기본 키는 그대로다. docs/specs/spec_activity_feed.md
ALTER TABLE feed_like ADD COLUMN IF NOT EXISTS kind VARCHAR(10) NOT NULL DEFAULT 'like';
