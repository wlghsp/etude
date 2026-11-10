#!/usr/bin/env bash
# 처리가 끝난 피드백의 첨부 이미지를 서버에서 지운다 (글은 남는다). docs/ops/guide_feedback_review.md Step 5.
#   사용법: bash backend/http/delete-feedback-images.sh <서버 주소> <관리자 이메일> <피드백 id> [<피드백 id> ...]
# 지울 피드백 id 를 직접 적어야 하며, 전체 삭제는 하지 않는다. 비밀번호는 입력창 또는 환경 변수 ETUDE_ADMIN_PASSWORD 로만 받는다.
# 보관 기간(기본 30일)이 지난 이미지는 서버가 알아서 지운다.
set -euo pipefail

SERVER="${1:?'서버 주소를 입력하세요 (예: https://etude.example.com)'}"
EMAIL="${2:?'관리자 이메일을 입력하세요'}"
shift 2
[ "$#" -gt 0 ] || { echo "지울 피드백 id 를 하나 이상 적어주세요." >&2; exit 1; }
for ID in "$@"; do
  case "$ID" in ''|*[!0-9]*) echo "피드백 id 는 숫자여야 합니다: $ID" >&2; exit 1;; esac
done
SERVER="${SERVER%/}"

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

for ID in "$@"; do
  curl -sS -f -X DELETE "$SERVER/admin/feedback/$ID/attachments" -H "Authorization: Bearer $TOKEN" >/dev/null
  echo "피드백 $ID 의 이미지를 지웠습니다."
done
unset TOKEN
