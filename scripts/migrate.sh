#!/usr/bin/env bash
# backend/db/migrations/*.sql 중 아직 적용하지 않은 파일을 이름순으로 실행한다.
# 적용 기록은 DB의 schema_migrations 테이블에 남는다. (docs/ops/guide_db_migrations.md)
#   사용법: scripts/migrate.sh            # DB 컨테이너 etude-db 기준
#           DB_CONTAINER=other scripts/migrate.sh
# 비밀번호는 컨테이너 환경변수를 쓰므로 스크립트와 인자에 남지 않는다.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_CONTAINER="${DB_CONTAINER:-etude-db}"
DIR="$ROOT/backend/db/migrations"

sql() { docker exec -i "$DB_CONTAINER" sh -c 'mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'; }

echo "CREATE TABLE IF NOT EXISTS schema_migrations (name VARCHAR(200) PRIMARY KEY, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP);" | sql

applied=0
for f in "$DIR"/*.sql; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  done_count="$(echo "SELECT COUNT(*) FROM schema_migrations WHERE name='$name';" | sql | tail -n 1)"
  if [ "$done_count" != "0" ]; then continue; fi
  echo "==> 적용: $name"
  sql < "$f"
  echo "INSERT INTO schema_migrations (name) VALUES ('$name');" | sql
  applied=$((applied + 1))
done
echo "완료: $applied 개 적용"
