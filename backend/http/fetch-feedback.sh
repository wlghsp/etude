#!/usr/bin/env bash
# 관리자 피드백을 feedback.json으로 저장한다 (docs/ops/guide_feedback_review.md Step 1~2).
#   사용법: bash backend/http/fetch-feedback.sh <서버 주소, 예: https://etude.example.com> <관리자 이메일>
# 비밀번호는 인자로 받지 않고 입력창에서만 받는다 (터미널 히스토리에 남기지 않는다).
set -euo pipefail

SERVER="${1:?'서버 주소를 입력하세요 (예: https://etude.example.com)'}"
EMAIL="${2:?'관리자 이메일을 입력하세요'}"
SERVER="${SERVER%/}"
OUT="${FEEDBACK_OUT:-feedback.json}"

command -v jq >/dev/null || { echo "jq가 필요합니다." >&2; exit 1; }

read -r -s -p "관리자 비밀번호: " PASSWORD; echo
TOKEN="$(jq -n --arg e "$EMAIL" --arg p "$PASSWORD" '{email:$e,password:$p}' \
  | curl -sS "$SERVER/auth/login" -H "Content-Type: application/json" -d @- \
  | jq -r '.token // empty')"
unset PASSWORD

if [ -z "$TOKEN" ]; then
  echo "로그인 실패. 주소와 이메일/비밀번호를 확인하세요." >&2
  exit 1
fi

curl -sS "$SERVER/admin/feedback" -H "Authorization: Bearer $TOKEN" | jq '.' > "$OUT"
unset TOKEN

echo "저장 완료: $OUT ($(jq length "$OUT")건)"
