#!/usr/bin/env bash
# 배포 전 점검: "마지막으로 성공한 배포 상태의 DB"에서 시작해, 이번에 새로 들어가는 마이그레이션을 이름순으로 적용해 본다.
#   (마이그레이션은 파일 이름순으로 실행되므로, 서로 의존하는 파일의 순서 실수를 서버에 가기 전에 잡는다.)
#   사용법: scripts/check-migrations.sh [기준 커밋]     # 기준을 생략하면 마지막으로 성공한 deploy 실행의 커밋 (gh 필요)
# 로컬 DB 컨테이너(etude-db)에 임시 DB(sim_srv)를 만들었다가 지운다. 실제 데이터는 건드리지 않는다.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
DB_CONTAINER="${DB_CONTAINER:-etude-db}"
BASE="${1:-}"
if [ -z "$BASE" ]; then
  BASE="$(gh run list --workflow deploy.yml --status success --limit 1 --json headSha -q '.[0].headSha' 2>/dev/null || true)"
fi
[ -n "$BASE" ] || { echo "기준 커밋을 알 수 없습니다. 인자로 넘겨 주세요." >&2; exit 1; }
git cat-file -e "$BASE^{commit}" 2>/dev/null || { echo "커밋 $BASE 를 찾을 수 없습니다 (git fetch 필요?)." >&2; exit 1; }

sql() { docker exec -i "$DB_CONTAINER" sh -c 'mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" sim_srv'; }
root_sql() { docker exec -i "$DB_CONTAINER" sh -c 'mariadb -uroot -p"$MYSQL_ROOT_PASSWORD"'; }
trap 'echo "DROP DATABASE IF EXISTS sim_srv;" | root_sql' EXIT

echo "기준(마지막 성공 배포): ${BASE:0:7}"
echo "DROP DATABASE IF EXISTS sim_srv; CREATE DATABASE sim_srv;" | root_sql
for f in 00_schema.sql 01_sandbox.sql 02_quest_set.sql; do git show "$BASE:backend/db/$f" | sql; done
for f in $(git ls-tree --name-only "$BASE" backend/db/ | grep '03_quest_set' | sort); do git show "$BASE:$f" | sql; done

git ls-tree --name-only "$BASE" backend/db/migrations/ 2>/dev/null | xargs -n1 basename | sort > /tmp/check_migrations_applied.txt || : > /tmp/check_migrations_applied.txt
new=0
for f in $(ls backend/db/migrations | sort); do
  grep -qx "$f" /tmp/check_migrations_applied.txt && continue
  echo "==> 적용: $f"
  sql < "backend/db/migrations/$f"
  new=$((new + 1))
done
echo "OK: 새 마이그레이션 ${new}개가 이름순으로 문제없이 적용됩니다."
