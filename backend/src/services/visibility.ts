// 세트 가시성 규칙의 단일 출처. 세트가 보이는 조건 = 대분류 가시 AND 세트 가시. (docs/specs/spec_visibility_categories.md)
// 대분류 설정 행이 없으면 공개로 본다. 더 넓은 쪽(대분류)이 비공개면 세트 접근 목록에 있어도 보이지 않는다.

const categoryHidden = (a: string) =>
  `EXISTS (SELECT 1 FROM category_setting cs WHERE cs.category = ${a}.category AND cs.is_public = FALSE)`

/** 사용자별 가시성 조건. 파라미터는 sql 안의 ? 순서(role, userId, role, userId)대로 돌려준다. */
export function visibleSet(alias: string, userId: number, role: string): { sql: string; params: Array<string | number> } {
  const a = alias
  const sql = `(
    (${a}.is_public = TRUE
      OR ? = 'admin'
      OR EXISTS (SELECT 1 FROM quest_set_access qsa WHERE qsa.quest_set_id = ${a}.id AND qsa.user_id = ?))
    AND (
      ? = 'admin'
      OR NOT ${categoryHidden(a)}
      OR EXISTS (SELECT 1 FROM category_access ca WHERE ca.category = ${a}.category AND ca.user_id = ?))
  )`
  return { sql, params: [role, userId, role, userId] }
}

/** 사용자와 무관한 집계(소식·배지)용: 세트가 공개이고 대분류도 비공개가 아닐 때만. */
export function publicSet(alias: string): string {
  return `(${alias}.is_public = TRUE AND NOT ${categoryHidden(alias)})`
}
