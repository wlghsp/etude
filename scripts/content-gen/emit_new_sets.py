# new_sets/setNNN.py 의 세트를 공유 파일(02·05·06·08, 03, verify, migrations)에 한 번에 반영한다. 사용: python3 emit_new_sets.py 505 506 ...
# 이미 반영한 세트 번호를 다시 넣지 않는다 (02 에 행이 중복된다).
import importlib.util, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gen_pilot_sets as g
sys.path.insert(0, os.path.join(HERE, 'new_sets'))
import review_fixes
REWRITE = '--rewrite' in sys.argv  # 이미 반영한 세트의 03·verify·마이그레이션·로컬 DB 만 다시 쓴다 (02·05·06·08 은 건드리지 않음)
for n in [a for a in sys.argv[1:] if not a.startswith('--')]:
    p = os.path.join(HERE, 'new_sets', f'set{n}.py')
    spec = importlib.util.spec_from_file_location(f'set{n}', p)
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    review_fixes.apply(m.b)
    if REWRITE:
        rows, answers = g.rows_of(m.b)
        open(f'{g.ROOT}/backend/db/03_quest_set{n}.sql', 'w').write(open(f'{g.ROOT}/backend/db/03_quest_set{n}.sql').read().split('INSERT INTO quest')[0] + f"INSERT INTO quest ({g.COLS}) VALUES\n  " + ',\n  '.join(rows) + ';\n')
        import json
        json.dump(dict(setId=m.b.sid, answers=answers), open(f'{g.ROOT}/backend/verify/set{n}.json', 'w'), ensure_ascii=False, indent=2)
        open(f'{g.ROOT}/backend/db/migrations/2026-11-19_gap_set{n}.sql', 'w').write(g.mig_sql(m.b, rows))
        g.preview(m.b)
    else:
        g.emit(m.b, f'2026-11-19_gap_set{n}.sql')
