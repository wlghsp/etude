#!/usr/bin/env bash
# 관리자 피드백을 feedback.json으로 저장한다 (docs/ops/guide_feedback_review.md Step 1~2).
#   사용법: bash backend/http/fetch-feedback.sh <서버 주소, 예: https://etude.example.com> <관리자 이메일>
# 비밀번호는 인자로 받지 않는다. 입력창 또는 환경 변수 ETUDE_ADMIN_PASSWORD 로만 받는다 (터미널 히스토리에 남기지 않는다).
set -euo pipefail

SERVER="${1:?'서버 주소를 입력하세요 (예: https://etude.example.com)'}"
EMAIL="${2:?'관리자 이메일을 입력하세요'}"
SERVER="${SERVER%/}"
OUT="${FEEDBACK_OUT:-feedback.json}"

command -v jq >/dev/null || { echo "jq가 필요합니다." >&2; exit 1; }

# 환경 변수 ETUDE_ADMIN_PASSWORD 가 있으면 입력창을 건너뛴다 (없으면 입력창에서만 받는다).
PASSWORD="${ETUDE_ADMIN_PASSWORD:-}"
if [ -z "$PASSWORD" ]; then read -r -s -p "관리자 비밀번호: " PASSWORD; echo; fi
TOKEN="$(jq -n --arg e "$EMAIL" --arg p "$PASSWORD" '{email:$e,password:$p}' \
  | curl -sS "$SERVER/auth/login" -H "Content-Type: application/json" -d @- \
  | jq -r '.token // empty')"
unset PASSWORD

if [ -z "$TOKEN" ]; then
  echo "로그인 실패. 주소와 이메일/비밀번호를 확인하세요." >&2
  exit 1
fi

curl -sS "$SERVER/admin/feedback" -H "Authorization: Bearer $TOKEN" | jq '.' > "$OUT"

# 첨부 이미지를 feedback_images/ 로 내려받고, 각 항목에 localFiles(로컬 경로)를 적는다.
# 이미지에 개인 정보가 있을 수 있어 .gitignore(feedback_images/)로 커밋되지 않는다.
IMG_DIR="${FEEDBACK_IMAGES_OUT:-feedback_images}"
EXT_OF() { case "$1" in image/png) echo png;; image/jpeg) echo jpg;; image/webp) echo webp;; *) echo bin;; esac; }
if [ "$(jq '[.[].attachments | length] | add // 0' "$OUT")" -gt 0 ]; then
  mkdir -p "$IMG_DIR"
  MAP="$(mktemp)"; echo '{}' > "$MAP"
  while IFS=$'\t' read -r FID AID MIME; do
    DEST="$IMG_DIR/feedback-$FID-$AID.$(EXT_OF "$MIME")"
    curl -sS -f "$SERVER/admin/feedback/attachments/$AID" -H "Authorization: Bearer $TOKEN" -o "$DEST"
    jq --arg k "$FID" --arg v "$DEST" '.[$k] += [$v]' "$MAP" > "$MAP.new" && mv "$MAP.new" "$MAP"
  done < <(jq -r '.[] | .id as $f | .attachments[] | [$f, .id, .mime] | @tsv' "$OUT")
  jq --slurpfile m "$MAP" 'map(. + {localFiles: ($m[0][(.id|tostring)] // [])})' "$OUT" > "$OUT.new" && mv "$OUT.new" "$OUT"
  rm -f "$MAP"
  echo "이미지 저장 완료: $IMG_DIR/ ($(ls "$IMG_DIR" | wc -l | tr -d ' ')장)"
fi
unset TOKEN

echo "저장 완료: $OUT ($(jq length "$OUT")건)"
