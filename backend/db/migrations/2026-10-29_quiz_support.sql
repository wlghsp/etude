-- 객관식 퀴즈 세트 지원 (docs/specs/spec_quiz_sets.md). 여러 번 실행해도 안전하다 (IF NOT EXISTS, NOT EXISTS 가드).
ALTER TABLE quest ADD COLUMN IF NOT EXISTS kind VARCHAR(10) NOT NULL DEFAULT 'terminal';
ALTER TABLE quest ADD COLUMN IF NOT EXISTS choices JSON NULL;
ALTER TABLE quest ADD COLUMN IF NOT EXISTS answer_index INT NULL;
ALTER TABLE quest ADD COLUMN IF NOT EXISTS explanation TEXT NULL;

INSERT INTO sandbox (type, image, binds, persistent, description)
SELECT 'quiz', 'none', NULL, FALSE, '터미널 없이 푸는 객관식 퀴즈. 컨테이너를 만들지 않는다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sandbox WHERE type = 'quiz');
