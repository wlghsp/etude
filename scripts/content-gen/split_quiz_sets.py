# 큰 퀴즈 세트(문제 26개 이상)를 1부·2부로 나누는 생성기. docs/specs/spec_split_large_quiz_sets.md
# 사용법: python3 scripts/content-gen/split_quiz_sets.py <분야>    (예: 도커, 리눅스, k8s, Git, 데이터베이스)
# 로컬 DB(etude-db 컨테이너)에서 대상 세트를 읽어 다음을 만든다. 쓰기 전에 DOCKER_HOST 를 맞춰 둔다.
#   - backend/db/migrations/2026-11-12_split_quiz_sets_<분야 슬러그>.sql  (이미 있는 DB 용, 여러 번 실행해도 안전)
#   - backend/db/10_split_sets.sql 에 같은 문장 추가                       (새 DB 용)
#   - backend/verify/quiz-proofs.json 의 (set, order) 를 옮긴 문제에 맞게 수정
# 한 번 나눈 세트는 문제 수가 26 미만이 되어 다음 실행에서 대상이 아니다. 적용은 scripts/migrate.sh 로 한다.
import json, os, subprocess, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
MIN_QUESTS = 26
SLUG = {'도커': 'docker', '리눅스': 'linux', 'k8s': 'k8s', 'Git': 'git', '데이터베이스': 'database'}


def query(sql):
    out = subprocess.run(['docker', 'exec', '-i', 'etude-db', 'sh', '-c', 'mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" -N --raw'],
                         input=sql, capture_output=True, text=True, check=True).stdout
    return [line.split('\t') for line in out.strip().split('\n') if line != '']


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in SLUG:
        sys.exit(f'사용법: split_quiz_sets.py <{"|".join(SLUG)}>')
    category = sys.argv[1]

    sets = query(f"""SELECT s.id, s.sandbox_type, s.time_limit_sec IS NOT NULL, s.is_review, s.display_order, COALESCE(u.display_order, 999999), COALESCE(s.unit_id, 0),
                            (SELECT COUNT(*) FROM quest q WHERE q.quest_set_id = s.id),
                            (SELECT COALESCE(MIN(order_index), 1) = 1 AND COALESCE(MAX(order_index), 0) = COUNT(*) FROM quest q WHERE q.quest_set_id = s.id)
                     FROM quest_set s LEFT JOIN unit u ON u.id = s.unit_id WHERE s.category = '{category}'""")
    rows = [dict(id=int(r[0]), sandbox=r[1], exam=r[2] == '1', review=r[3] == '1', order=int(r[4]), unit_order=int(r[5]), unit=int(r[6]), n=int(r[7]), contiguous=r[8] == '1') for r in sets]
    targets = [r for r in rows if r['sandbox'] == 'quiz' and not r['exam'] and not r['review'] and r['n'] >= MIN_QUESTS]
    if not targets:
        sys.exit(f'{category}: 나눌 세트가 없습니다 (이미 나눴거나 대상이 아닙니다).')
    bad = [t['id'] for t in targets if not t['contiguous']]
    if bad:
        sys.exit(f'order_index 가 1..n 으로 이어지지 않는 세트가 있어 중단합니다: {bad}')

    next_id = int(query('SELECT MAX(id) FROM quest_set')[0][0]) + 1
    targets.sort(key=lambda t: t['id'])
    plan = {}  # 원래 번호 -> (1부 문제 수 m, 2부 번호)
    for t in targets:
        plan[t['id']] = (-(-t['n'] // 2), next_id)
        next_id += 1

    sql = [f'-- 큰 퀴즈 세트 나누기: {category} {len(targets)}개 (원래 세트가 1부, 새 세트가 2부). docs/specs/spec_split_large_quiz_sets.md',
           '-- 여러 번 실행해도 안전하다 (INSERT 는 NOT EXISTS, 문제 이동은 order_index 조건, 제목은 접미사 확인, 순서·기록 맞춤은 절대값/조건 UPDATE).']
    for sid, (m, new_id) in plan.items():
        sql.append(f"INSERT INTO quest_set (id, title, description, sandbox_type, category, is_public, is_review, icon, unit_id)\n"
                   f"SELECT {new_id}, CONCAT(title, ' (2/2)'), description, sandbox_type, category, is_public, is_review, icon, unit_id FROM quest_set\n"
                   f"WHERE id = {sid} AND title NOT LIKE '% (1/2)' AND NOT EXISTS (SELECT 1 FROM quest_set WHERE id = {new_id});")
        sql.append(f"UPDATE quest SET quest_set_id = {new_id}, order_index = order_index - {m} WHERE quest_set_id = {sid} AND order_index > {m};")
        sql.append(f"UPDATE quest_set SET title = CONCAT(title, ' (1/2)') WHERE id = {sid} AND title NOT LIKE '% (1/2)';")
    sql.append("UPDATE quest_attempt a JOIN quest q ON q.id = a.quest_id SET a.quest_set_id = q.quest_set_id WHERE a.quest_set_id <> q.quest_set_id;")
    sql.append("UPDATE feedback f JOIN quest q ON q.id = f.quest_id SET f.quest_set_id = q.quest_set_id WHERE f.quest_set_id <> q.quest_set_id;")

    # display_order: 분야 전체를 (단원 순서, 단원 안 순서, 번호) 로 줄 세우고 2부를 1부 바로 뒤에 넣어 현재 최솟값부터 1씩 올린다
    rows.sort(key=lambda r: (r['unit_order'], r['unit'], r['order'], r['id']))
    ordered = []
    for r in rows:
        ordered.append(r['id'])
        if r['id'] in plan:
            ordered.append(plan[r['id']][1])
    start = min(r['order'] for r in rows)
    for i, sid in enumerate(ordered):
        sql.append(f"UPDATE quest_set SET display_order = {start + i} WHERE id = {sid};")
    body = '\n'.join(sql) + '\n'

    slug = SLUG[category]
    with open(f'{ROOT}/backend/db/migrations/2026-11-12_split_quiz_sets_{slug}.sql', 'w') as f:
        f.write("ALTER TABLE quest_set MODIFY title VARCHAR(200) NOT NULL;\n" + body)
    with open(f'{ROOT}/backend/db/10_split_sets.sql', 'a') as f:
        f.write(body + '\n')

    # verify:quiz 가 읽는 증명 파일: (set, order) 로 문제를 가리키므로 옮긴 문제는 새 세트 번호와 새 순번으로 바꾼다
    path = f'{ROOT}/backend/verify/quiz-proofs.json'
    proofs = json.load(open(path))
    moved = 0
    for p in proofs:
        if p['set'] in plan and p['order'] > plan[p['set']][0]:
            m, new_id = plan[p['set']]
            p['set'], p['order'] = new_id, p['order'] - m
            moved += 1
    json.dump(proofs, open(path, 'w'), ensure_ascii=False, indent=2)
    open(path, 'a').write('\n')
    print(f'{category}: {len(targets)}개 세트를 나눔 (새 번호 {min(v[1] for v in plan.values())}~{max(v[1] for v in plan.values())}), 증명 {moved}건 이동')


main()
