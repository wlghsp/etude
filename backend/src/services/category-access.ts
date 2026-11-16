import { db } from '../db.js'

/** 관리자용: 대분류 목록과 공개 여부, 접근 사용자. 대분류는 quest_set.category 에서 모은다. */
export async function getCategoriesForAdmin() {
  const [cats] = await db.query<any[]>(`
    SELECT s.category, COUNT(*) AS set_count, COALESCE(MIN(cs.is_public), TRUE) AS is_public
    FROM quest_set s
    LEFT JOIN category_setting cs ON cs.category = s.category
    GROUP BY s.category
    ORDER BY MIN(s.display_order)`)
  const [access] = await db.query<any[]>(`
    SELECT ca.category, u.id AS userId, u.name, u.email
    FROM category_access ca JOIN user u ON u.id = ca.user_id`)
  return cats.map((c) => ({
    category: c.category as string,
    setCount: Number(c.set_count),
    is_public: Boolean(c.is_public),
    accessUsers: access.filter((a) => a.category === c.category).map((a) => ({ id: a.userId, name: a.name, email: a.email })),
  }))
}

/** 존재하는 대분류인지. 임의 문자열이 설정 테이블에 쌓이지 않게 한다. */
export async function categoryExists(category: string): Promise<boolean> {
  const [rows] = await db.query<any[]>('SELECT 1 FROM quest_set WHERE category = ? LIMIT 1', [category])
  return rows.length > 0
}

export async function setCategoryPublic(category: string, isPublic: boolean) {
  await db.query(
    'INSERT INTO category_setting (category, is_public) VALUES (?, ?) ON DUPLICATE KEY UPDATE is_public = VALUES(is_public)',
    [category, isPublic])
}

export async function grantCategoryAccess(category: string, userId: number) {
  await db.query('INSERT IGNORE INTO category_access (category, user_id) VALUES (?, ?)', [category, userId])
}

export async function revokeCategoryAccess(category: string, userId: number) {
  await db.query('DELETE FROM category_access WHERE category = ? AND user_id = ?', [category, userId])
}
