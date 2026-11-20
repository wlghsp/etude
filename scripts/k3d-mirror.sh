#!/usr/bin/env bash
# k3d 클러스터가 Docker Hub 대신 미러(etude-mirror)에서 이미지를 받게 설정한다. 여러 번 실행해도 안전하다 (바뀔 때만 노드를 재시작).
#   scripts/k3d-mirror.sh                 # 클러스터 etude (노드 k3d-etude-server-0)
#   K3D_NODE=k3d-xxx-server-0 scripts/k3d-mirror.sh
# 미러 컨테이너가 k3d 네트워크에 붙어 있어야 한다 (compose 가 붙인다). 설명: docs/specs/spec_registry_mirror.md
set -euo pipefail
NODE="${K3D_NODE:-k3d-etude-server-0}"
NET="${K3D_NETWORK:-k3d-etude}"
MIRROR="etude-mirror"

docker inspect "$NODE" >/dev/null 2>&1 || { echo "노드 $NODE 가 없습니다. 건너뜁니다."; exit 0; }
docker inspect "$MIRROR" >/dev/null 2>&1 || { echo "미러 $MIRROR 가 없습니다. 건너뜁니다."; exit 0; }
# 미러를 k3d 네트워크에 연결 (이미 연결돼 있으면 무시)
docker network connect "$NET" "$MIRROR" >/dev/null 2>&1 || true

WANT=$'mirrors:\n  docker.io:\n    endpoint:\n      - "http://'"$MIRROR"$':5000"'
HAVE="$(docker exec "$NODE" cat /etc/rancher/k3s/registries.yaml 2>/dev/null || true)"
if [ "$HAVE" = "$WANT" ]; then echo "k3d 미러 설정이 이미 적용돼 있습니다."; exit 0; fi

printf '%s\n' "$WANT" | docker exec -i "$NODE" sh -c 'mkdir -p /etc/rancher/k3s && cat > /etc/rancher/k3s/registries.yaml'
echo "k3d 미러 설정을 적용하고 노드를 재시작합니다 ($NODE)..."
docker restart "$NODE" >/dev/null
for _ in $(seq 1 60); do
  kubectl get nodes 2>/dev/null | grep -q " Ready" && { echo "노드 준비됨."; exit 0; }
  sleep 3
done
echo "노드가 3분 안에 준비되지 않았습니다: kubectl get nodes 를 확인하세요." >&2; exit 1
