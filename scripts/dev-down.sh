#!/usr/bin/env bash
# 로컬 개발 환경 정지: MariaDB, k3d 클러스터 (실행 중일 때만)
#
#   scripts/dev-down.sh
#
# 컨테이너와 볼륨은 지우지 않는다(데이터 보존). 완전 초기화가 필요하면
# docs/ops/guide_local_dev_env.md 의 "DB 초기화" 절을 따른다.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT/backend/docker-compose.yml"
K3D_CLUSTER="etude"

echo "==> MariaDB 정지"
docker compose -f "$COMPOSE_FILE" stop db

if command -v k3d >/dev/null && k3d cluster list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$K3D_CLUSTER"; then
  echo "==> k3d 클러스터 정지 ($K3D_CLUSTER)"
  k3d cluster stop "$K3D_CLUSTER"
fi

echo
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E 'NAMES|etude|k3d' || echo "실행 중인 etude/k3d 컨테이너 없음"
