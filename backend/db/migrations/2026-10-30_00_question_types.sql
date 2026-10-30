-- 가벼운 문제 형식: 순서 맞추기(order)·빈칸 채우기(fill). docs/specs/spec_question_types.md
ALTER TABLE quest ADD COLUMN IF NOT EXISTS answer_spec JSON NULL;
ALTER TABLE quest ADD COLUMN IF NOT EXISTS template TEXT NULL;
