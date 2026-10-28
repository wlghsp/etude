#!/usr/bin/env bash
# 로컬 개발 환경 기동: MariaDB + k3d 클러스터
#
#   scripts/dev-up.sh            # DB + k3d 클러스터 (기본)
#   scripts/dev-up.sh --no-k8s   # DB만 (k8s 샌드박스를 안 쓸 때, 메모리 절약)
#
# 백엔드(bootRun)와 프론트(npm run dev)는 IDE에서 자주 재시작하므로 포함하지 않는다.
# 자세한 설명: docs/ops/guide_local_dev_env.md

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT/backend/docker-compose.yml"
DB_CONTAINER="etude-db"
K3D_CLUSTER="etude"
WITH_K8S=true

for arg in "$@"; do
  case "$arg" in
    --no-k8s) WITH_K8S=false ;;
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "알 수 없는 옵션: $arg (사용법: dev-up.sh [--no-k8s])" >&2; exit 1 ;;
  esac
done

command -v docker >/dev/null || { echo "docker가 필요합니다." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker 데몬에 연결할 수 없습니다. (colima/Docker Desktop 실행 여부 확인)" >&2; exit 1; }

echo "==> MariaDB 기동 ($DB_CONTAINER)"
docker compose -f "$COMPOSE_FILE" up -d db

# 첫 기동 시 초기화 SQL을 돌리는 임시 서버는 네트워크를 끄고 떠 있으므로
# 소켓이 아니라 TCP(127.0.0.1)로 붙어야 "진짜 서버가 준비됨"을 확인할 수 있다.
echo -n "    준비 대기"
for _ in $(seq 1 60); do
  if docker exec "$DB_CONTAINER" mariadb -h127.0.0.1 -uroot -proot -e 'SELECT 1' >/dev/null 2>&1; then
    echo " - OK"
    break
  fi
  echo -n "."
  sleep 2
done
docker exec "$DB_CONTAINER" mariadb -h127.0.0.1 -uroot -proot -e 'SELECT 1' >/dev/null 2>&1 \
  || { echo; echo "DB가 120초 안에 준비되지 않았습니다: docker logs $DB_CONTAINER" >&2; exit 1; }

TABLES=$(docker exec "$DB_CONTAINER" mariadb -h127.0.0.1 -uroot -proot -N -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='etude'")
echo "    etude 스키마 테이블 수: $TABLES"
if [ "$TABLES" = "0" ]; then
  echo "    (!) 테이블이 없습니다. 초기화 SQL이 실행되지 않았습니다: docker logs $DB_CONTAINER" >&2
fi

if $WITH_K8S; then
  command -v k3d >/dev/null || { echo "k3d가 필요합니다. (brew install k3d)" >&2; exit 1; }
  echo "==> k3d 클러스터 ($K3D_CLUSTER)"
  if k3d cluster list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$K3D_CLUSTER"; then
    k3d cluster start "$K3D_CLUSTER"
  else
    k3d cluster create "$K3D_CLUSTER"
  fi
fi

echo
echo "==> 현재 상태"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E 'NAMES|etude|k3d' || true
echo
echo "다음: cd backend-kotlin && ./gradlew :apps:backend:bootRun   /   cd frontend && npm run dev"
