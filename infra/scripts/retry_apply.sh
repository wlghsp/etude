#!/bin/bash
# ARM Always Free 용량 부족(Out of host capacity)으로 실패할 때 terraform apply를 반복 재시도한다.
# 성공하면 자동으로 멈춘다.

set -uo pipefail

INTERVAL_SEC="${1:-60}"
TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../terraform" && pwd)"

cd "$TF_DIR"

attempt=1
while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] attempt #$attempt — terraform apply -auto-approve"

  if terraform apply -auto-approve; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 성공. 종료합니다."
    break
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 실패 (Out of host capacity 등). ${INTERVAL_SEC}초 후 재시도."
  attempt=$((attempt + 1))
  sleep "$INTERVAL_SEC"
done
