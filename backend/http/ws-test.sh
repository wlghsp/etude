#!/bin/bash
# terminal.ts 재현 루프 — 버그 발생 시 여기서 시작
#
# 사용법:
#   bash http/ws-test.sh [시나리오]
#
# 시나리오:
#   linux              — 기본 linux sandbox (handleDefaultTerminal)
#   docker             — docker sandbox 신규 컨테이너 (handleDockerTerminal)
#   docker-reuse <id>  — docker-persistent 기존 컨테이너 재사용
#   k8s                — k8s sandbox + namespace 생성 (handleK8sTerminal)
#
# 전제: 백엔드가 localhost:3001에서 실행 중이어야 함
# 출력: connected JSON 수신 여부 + containerId

BASE="ws://localhost:3001"
SCENARIO="${1:-linux}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== ws-test.sh: $SCENARIO ==="

case "$SCENARIO" in
  linux)
    echo ">> linux sandbox 연결 테스트"
    node "$SCRIPT_DIR/ws-test.mjs" "${BASE}/ws/terminal?sandboxType=linux&questId=1"
    ;;
  docker)
    echo ">> docker sandbox 연결 테스트 (새 컨테이너)"
    node "$SCRIPT_DIR/ws-test.mjs" "${BASE}/ws/terminal?sandboxType=docker&questId=1"
    ;;
  docker-reuse)
    CONTAINER_ID="${2:?'사용법: bash ws-test.sh docker-reuse <containerId>'}"
    echo ">> docker-persistent 재사용 테스트: containerId=${CONTAINER_ID}"
    node "$SCRIPT_DIR/ws-test.mjs" "${BASE}/ws/terminal?sandboxType=docker-persistent&questId=1&containerId=${CONTAINER_ID}"
    ;;
  k8s)
    echo ">> k8s sandbox 연결 테스트 (namespace 생성 포함)"
    node "$SCRIPT_DIR/ws-test.mjs" "${BASE}/ws/terminal?sandboxType=k8s&questId=1"
    ;;
  *)
    echo "알 수 없는 시나리오: $SCENARIO"
    echo "사용 가능: linux | docker | docker-reuse <id> | k8s"
    exit 1
    ;;
esac
