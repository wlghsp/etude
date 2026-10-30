-- 문제마다 참고할 공식 문서 링크 [{title, url}]. docs/specs/spec_question_docs.md
ALTER TABLE quest ADD COLUMN IF NOT EXISTS docs JSON NULL;
