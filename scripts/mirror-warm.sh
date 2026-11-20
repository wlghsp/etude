#!/usr/bin/env bash
# 퀘스트 이미지를 미러(etude-mirror)에 미리 받아 둔다. 학습자가 처음 쓸 때 Docker Hub 한도(429)에 걸리지 않게 한다.
#   scripts/mirror-warm.sh            # backend/docker/quest-images.txt 의 이미지를 미러로 받는다
# 미러가 없거나 일부가 실패해도 배포를 막지 않는다 (종료 코드 0). 결과만 출력한다.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$ROOT/backend/docker/quest-images.txt"
MIRROR="${MIRROR_ADDR:-127.0.0.1:5000}"

if ! curl -fsS "http://$MIRROR/v2/" >/dev/null 2>&1; then
  echo "미러($MIRROR)에 연결할 수 없어 건너뜁니다."; exit 0
fi
ok=0; fail=0
while read -r img; do
  case "$img" in ''|\#*) continue ;; esac
  ref="$img"; case "$img" in */*) ;; *) ref="library/$img" ;; esac   # 네임스페이스가 없으면 library/
  if docker pull -q "$MIRROR/$ref" >/dev/null 2>&1; then ok=$((ok + 1)); docker rmi "$MIRROR/$ref" >/dev/null 2>&1 || true
  else fail=$((fail + 1)); echo "  받지 못함: $img"; fi
done < "$LIST"
echo "미러 준비: 성공 $ok, 실패 $fail"
exit 0
