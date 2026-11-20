#!/usr/bin/env python3
"""빈틈 보강 새 세트(502~541)를 단원 안에서 선행 관계에 맞는 자리로 옮긴다 (2026-11-19).

- UNIT_ORDER: 새 세트가 들어간 단원의 최종 세트 순서(옛 세트의 상대 순서는 그대로, 새 세트만 끼워 넣음).
- UNIT_MOVE: 선행 개념이 다른 단원에 있어서 단원을 옮기는 세트.
- 분야(category)별로 단원 순서 → 단원 안 순서대로 display_order 를 다시 매긴다.
  분야의 첫 display_order(최솟값)는 그대로라 분야 순서는 바뀌지 않는다 (category-access 가 MIN(display_order)로 분야를 정렬).
- 결과: backend/db/migrations/2026-11-19_zz_gap_reorder.sql, 05_display_order.sql·06_units.sql 의 해당 줄 갱신, 로컬 DB(etude-db) 반영.
사용: python3 scripts/content-gen/reorder_gap_sets.py [--dry]
"""
import re, subprocess, sys, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DRY = '--dry' in sys.argv

UNIT_MOVE = {515: 58, 516: 58, 518: 58, 517: 59}   # 서비스·디스크·패키지 상황집은 systemd·df/du·패키지 세트 뒤로, 접근 거부는 sudo·ACL·방화벽 뒤로

UNIT_ORDER = {
    30: [125, 126, 139, 329, 140, 330, 509, 366],
    44: [141, 331, 510, 522, 372, 523, 374],
    46: [164, 334, 371, 525, 526, 369, 505, 506],
    20: [158, 332, 502, 503, 507, 524, 402, 403, 513, 109, 508, 59, 414, 415, 91, 514, 87],
    31: [60, 99, 527, 83, 102, 400, 118, 401],
    15: [54, 94, 504, 495],
    8: [108, 37, 25, 348, 422, 80, 489, 13, 122, 512, 26],
    66: [212, 255, 478, 215, 256, 225, 231, 554, 349, 160, 242, 340, 532, 343, 555],
    34: [142, 239, 533, 228, 551, 179, 246, 209, 254, 530, 352, 498, 556],
    35: [206, 253, 148, 240, 175, 245, 237, 552],
    67: [154, 241, 234, 346, 187, 248, 501, 553, 8, 337],
    4: [10, 24, 123, 16, 75, 124, 549, 27, 548, 32, 534, 535, 536, 537, 28],
    3: [106, 4, 18, 36, 235, 545, 81],
    58: [226, 229, 232, 544, 382, 430, 431, 547, 515, 516, 538, 539, 546, 518],
    59: [426, 542, 427, 543, 428, 429, 432, 433, 550, 540, 541, 517],
}


def q(sql):
    r = subprocess.run(['docker', 'exec', 'etude-db', 'mariadb', '-h127.0.0.1', '-uroot', '-proot', '-N', '--raw', '-e', sql, 'etude'],
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr)
    return [l.split('\t') for l in r.stdout.strip().split('\n') if l]


rows = q("SELECT q.id, q.category, IFNULL(q.unit_id,0), IFNULL(u.display_order,999999), q.display_order FROM quest_set q LEFT JOIN unit u ON u.id=q.unit_id")
sets = {int(i): dict(cat=c, unit=int(un), uord=int(uo), order=int(o)) for i, c, un, uo, o in rows}
for sid, un in UNIT_MOVE.items():
    sets[sid]['unit'] = un
    sets[sid]['uord'] = int(q(f"SELECT display_order FROM unit WHERE id={un}")[0][0])

# 단원별 최종 순서: 지정한 단원은 그대로, 나머지는 현재 display_order 순
by_unit = {}
for sid, s in sets.items():
    by_unit.setdefault(s['unit'], []).append(sid)
final_unit = {}
for un, ids in by_unit.items():
    if un in UNIT_ORDER:
        want = UNIT_ORDER[un]
        missing = set(ids) - set(want)
        extra = set(want) - set(ids)
        if missing or extra:
            sys.exit(f'단원 {un}: 목록 불일치 missing={sorted(missing)} extra={sorted(extra)}')
        final_unit[un] = want
    else:
        final_unit[un] = sorted(ids, key=lambda i: (sets[i]['order'], i))

# 분야별로 단원 순서대로 이어 붙여 display_order 를 다시 매긴다 (시작은 그 분야의 현재 최솟값)
cats = {}
for un, ids in final_unit.items():
    for i in ids:
        cats.setdefault(sets[i]['cat'], []).append((sets[i]['uord'], un, ids.index(i), i))
new_order = {}
for cat, lst in cats.items():
    lst.sort()
    start = min(sets[i]['order'] for _, _, _, i in lst)
    for n, (_, _, _, i) in enumerate(lst):
        new_order[i] = start + n

changed_order = {i: o for i, o in new_order.items() if o != sets[i]['order']}
changed_unit = {i: u for i, u in UNIT_MOVE.items() if int(q(f"SELECT IFNULL(unit_id,0) FROM quest_set WHERE id={i}")[0][0]) != u}

lines = ['-- 빈틈 보강 새 세트(502~541)를 선행 관계에 맞는 자리로 재배치한다 (2026-11-19, scripts/content-gen/reorder_gap_sets.py).',
         '-- 분야별 display_order 를 단원 순서 → 단원 안 순서대로 다시 매기고, 선행 세트가 다른 단원에 있던 상황집 4개의 단원을 옮긴다.',
         '-- 세트 id 는 그대로라 완료 기록은 영향이 없다. 같은 SQL 을 다시 실행해도 결과가 같다.']
for i, u in sorted(changed_unit.items()):
    lines.append(f'UPDATE quest_set SET unit_id = {u} WHERE id = {i};')
for i, o in sorted(changed_order.items(), key=lambda x: x[1]):
    lines.append(f'UPDATE quest_set SET display_order = {o} WHERE id = {i};')
sql = '\n'.join(lines) + '\n'
print(f'display_order 변경 {len(changed_order)}개, 단원 이동 {len(changed_unit)}개')
if DRY:
    sys.exit(0)

open(os.path.join(ROOT, 'backend/db/migrations/2026-11-19_zz_gap_reorder.sql'), 'w').write(sql)

# 시드 파일의 해당 줄 갱신 (같은 id 의 줄이 이미 있다)
def patch(path, pat, repl_for):
    txt = open(path).read()
    for i, v in repl_for.items():
        txt, n = re.subn(pat.format(id=i), lambda m: m.group(1) + str(v) + m.group(2), txt)
        if n == 0:   # 이 파일에 줄이 없던 세트(다른 마이그레이션이 정한 값)는 줄을 추가한다
            col = 'display_order' if 'display_order' in pat else 'unit_id'
            txt = txt.rstrip('\n') + f'\nUPDATE quest_set SET {col} = {v} WHERE id = {i};\n'
        # n > 1: 같은 세트의 줄이 여러 번 있으면 모두 같은 값으로 바꾼다 (뒤의 줄이 이긴다)
    open(path, 'w').write(txt)

patch(os.path.join(ROOT, 'backend/db/05_display_order.sql'), r'(UPDATE quest_set SET display_order = )\d+( WHERE id = {id};)', changed_order)
patch(os.path.join(ROOT, 'backend/db/06_units.sql'), r'(UPDATE quest_set SET unit_id = )\d+( WHERE id = {id};)', changed_unit)

# 로컬 DB 반영
r = subprocess.run(['docker', 'exec', '-i', 'etude-db', 'mariadb', '-h127.0.0.1', '-uroot', '-proot', 'etude'], input=sql, text=True, capture_output=True)
if r.returncode:
    sys.exit(r.stderr)
print('로컬 DB 반영 완료')
