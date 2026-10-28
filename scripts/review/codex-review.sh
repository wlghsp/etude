#!/usr/bin/env bash
# Codex 읽기 전용 리뷰 호출
#
#   scripts/review/codex-review.sh [--base REF] [--spec PATH] [--notes FILE] [--dry-run] -- <파일>...
#
#   --base REF     리뷰 기준점 (기본 HEAD). 먼저 커밋 SHA로 확정한다.
#   --spec PATH    수용 조건이 있는 명세 파일 (리뷰어가 참조)
#   --notes FILE   구현자가 쓴 증거 요약 (RED/GREEN 명령과 결과, 알려진 미해결 사항)
#                  원시 로그를 통째로 넣지 않는다. 내용 전체가 프롬프트로 외부에 전송된다.
#   --effort LEVEL reasoning effort: low | medium(기본) | high. 인증·인가·세션·인프라·삭제는 high.
#   --dry-run      snapshot과 프롬프트만 만들어 보여 주고 Codex는 호출하지 않는다
#
# 격리 수준 (하드 격리가 아니다):
#   - Codex에는 원본 저장소가 아니라 BASE 기준 임시 worktree(snapshot)를 연다.
#   - 입력 경로는 allowlist 방식으로 검증한다 (절대 경로, '..', symlink, 저장소 밖 경로, 제어 문자 거부).
#   - 민감 패턴 파일은 요청 단계에서 거부하고, snapshot에서도 지운다.
#   - 다만 --sandbox read-only / --cd는 "snapshot 밖 파일을 읽지 못한다"는 보장이 아니다.
#     프롬프트 지침과 위 검증으로 원본 접근을 막을 뿐이다. OS 수준 격리가 필요하면
#     Codex를 컨테이너에서 실행하고 snapshot만 read-only로 마운트해야 한다.
#
# 규칙·출력 형식은 scripts/review/prompt.md 한 곳에만 둔다.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
PROMPT_FILE="scripts/review/prompt.md"
# 리뷰 대상이 아니라 "리뷰 실행 규칙"이라 항상 현재 내용을 snapshot에 넣는다.
RULE_FILES=(AGENTS.md CLAUDE.md "$PROMPT_FILE")
# 요청 검증과 snapshot 정제에 같은 기준(grep -iE)을 쓴다. macOS는 대소문자를 구분하지 않으므로 -i가 필요하다.
FORBIDDEN='(^|/)\.env|04_users\.sql|users\.txt$|\.tfvars|\.tfstate|\.tfplan'
SECRET_CONTENT='BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|\$2[aby]\$[0-9]{2}\$|(password|passwd|secret|token|api[_-]?key)[[:space:]]*[=:][[:space:]]*[^[:space:]]'
NOTES_MAX_LINES=200

die() { echo "$*" >&2; exit 1; }

# base 아래에서 rel의 모든 구성 요소가 심볼릭 링크가 아닌지 검사한다.
# '/'로 나눌 때 glob 확장이 일어나지 않도록 read -a를 쓰고, 실제 복사·삭제에 쓰는 경로와 같은 문자열을 검사한다.
assert_no_symlink() {
  local base="$1" rel="$2" cur part
  local -a parts
  IFS=/ read -ra parts <<< "$rel"
  cur="$base"
  for part in "${parts[@]}"; do
    cur="$cur/$part"
    [ -L "$cur" ] && die "경로에 심볼릭 링크가 있습니다: $rel"
  done
  return 0
}

BASE=HEAD; SPEC=""; NOTES=""; DRY=false; EFFORT=medium; FILES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --base) [ $# -ge 2 ] || die "--base 값이 필요합니다."; BASE="$2"; shift 2 ;;
    --spec) [ $# -ge 2 ] || die "--spec 값이 필요합니다."; SPEC="$2"; shift 2 ;;
    --notes) [ $# -ge 2 ] || die "--notes 값이 필요합니다."; NOTES="$2"; shift 2 ;;
    --effort) [ $# -ge 2 ] || die "--effort 값이 필요합니다."; EFFORT="$2"; shift 2 ;;
    --dry-run) DRY=true; shift ;;
    --) shift; FILES=("$@"); break ;;
    -h|--help) sed -n '2,22p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) die "알 수 없는 옵션: $1" ;;
  esac
done
[ ${#FILES[@]} -gt 0 ] || die "리뷰할 파일을 '--' 뒤에 지정하세요."
case "$EFFORT" in low|medium|high) ;; *) die "--effort는 low, medium, high 중 하나여야 합니다: $EFFORT" ;; esac
command -v codex >/dev/null || die "codex CLI가 필요합니다."

# 저장소 안의 상대 경로만 허용한다. 존재하는 파일은 일반 파일(심볼릭 링크 아님)이어야 한다.
validate_path() {
  local p="$1"
  [ -n "$p" ] || die "빈 경로입니다."
  [[ "$p" =~ [[:cntrl:]] ]] && die "제어 문자가 포함된 경로입니다: $p"
  [[ "$p" == /* ]] && die "절대 경로는 허용되지 않습니다: $p"
  # 정규화되지 않은 표기('.', '..', '//', 끝의 '/')는 민감 경로 검사를 우회할 수 있어 거부한다.
  [[ "/$p/" == *"/../"* ]] && die "'..'가 포함된 경로는 허용되지 않습니다: $p"
  [[ "/$p/" == *"/./"* || "$p" == *"//"* || "$p" == */ ]] && die "정규화되지 않은 경로입니다 ('.', '//', 끝의 '/'): $p"
  echo "$p" | grep -qiE "$FORBIDDEN" && die "민감 파일은 리뷰 대상이 될 수 없습니다: $p"
  # 상위 디렉터리까지 포함해 모든 구성 요소가 링크가 아니어야 한다 (링크를 거치면 민감 경로 검사를 우회할 수 있다).
  assert_no_symlink "$ROOT" "$p"
  if [ -e "$ROOT/$p" ]; then
    [ -f "$ROOT/$p" ] || die "일반 파일만 허용됩니다: $p"
    local dir; dir="$(cd "$ROOT/$(dirname "$p")" && pwd -P)"
    case "$dir/" in "$ROOT"/*) ;; *) die "저장소 밖으로 해석되는 경로입니다: $p" ;; esac
  fi
}

for f in "${FILES[@]}" ${SPEC:+"$SPEC"} ${NOTES:+"$NOTES"} "${RULE_FILES[@]}"; do validate_path "$f"; done

if [ -n "$NOTES" ]; then
  [ -f "$ROOT/$NOTES" ] || die "notes 파일이 없습니다: $NOTES"
  [ "$(wc -l < "$ROOT/$NOTES")" -le "$NOTES_MAX_LINES" ] \
    || die "notes가 ${NOTES_MAX_LINES}줄을 넘습니다. 원시 로그 대신 요약을 쓰세요."
  if grep -qiE "$SECRET_CONTENT" "$ROOT/$NOTES"; then
    die "notes에 비밀번호·토큰·키로 보이는 내용이 있습니다. 제거한 뒤 다시 실행하세요."
  fi
fi

# 기준점을 커밋 SHA로 확정한 뒤 worktree에 넘긴다 (옵션처럼 해석될 입력 방지).
BASE_SHA="$(git -C "$ROOT" rev-parse --verify --quiet --end-of-options "$BASE^{commit}")" || die "유효한 커밋이 아닙니다: $BASE"

TMP="$(mktemp -d)"
SNAP="$TMP/repo"
cleanup() { git -C "$ROOT" worktree remove --force "$SNAP" 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT

git -C "$ROOT" worktree add --detach -q "$SNAP" "$BASE_SHA"

# snapshot에서 민감 패턴 파일 제거 (추적 중인 .env.example 같은 템플릿도 리뷰에는 불필요).
# 해당 파일이 하나도 없으면 grep이 1을 반환하므로 정상 상태로 취급한다.
# 경로는 -z(NUL 구분)로 받아 인용·이스케이프 없이 실제 경로를 그대로 쓴다. 목록 조회 실패는 삼키지 않는다.
git -C "$SNAP" ls-files -z > "$TMP/snapshot-files.z"
while IFS= read -r -d '' s; do
  if printf '%s\n' "$s" | grep -qiE "$FORBIDDEN"; then rm -f "$SNAP/$s"; fi
done < "$TMP/snapshot-files.z"

# snapshot 안에서도 같은 검사를 한다. BASE에서 링크였던 경로를 현재 일반 파일로 바꿔 지정하면
# cp/rm이 링크를 따라 snapshot 밖을 건드릴 수 있기 때문이다.
# 지정한 파일(리뷰 대상, 명세)과 리뷰 실행 규칙을 작업 트리의 현재 내용으로 덮어쓴다.
# 작업 트리에서 삭제된 파일은 snapshot에서도 지운다.
for f in "${FILES[@]}" ${SPEC:+"$SPEC"} "${RULE_FILES[@]}"; do
  assert_no_symlink "$SNAP" "$f"
  if [ -e "$ROOT/$f" ]; then
    # BASE에서 같은 경로가 다른 종류(디렉터리 <-> 파일)였다면 snapshot에서 비운 뒤 현재 내용으로 채운다.
    # (그대로 cp하면 디렉터리 안에 foo/foo로 복사되거나, 파일이 있어서 mkdir이 실패한다.)
    [ -d "$SNAP/$f" ] && rm -rf "$SNAP/$f"
    cur="$SNAP"; IFS=/ read -ra parts <<< "$(dirname "$f")"
    for part in "${parts[@]}"; do
      cur="$cur/$part"
      if [ -e "$cur" ] && [ ! -d "$cur" ]; then rm -f "$cur"; fi
    done
    mkdir -p "$SNAP/$(dirname "$f")"; cp "$ROOT/$f" "$SNAP/$f"
    # cp는 기존 대상의 권한을 유지하므로, git이 추적하는 실행 비트는 현재 파일 기준으로 맞춘다.
    if [ -x "$ROOT/$f" ]; then chmod u+x "$SNAP/$f"; else chmod u-x "$SNAP/$f"; fi
  elif git -C "$ROOT" cat-file -e "$BASE_SHA:$f" 2>/dev/null; then
    rm -f "$SNAP/$f"
  else
    die "파일을 찾을 수 없습니다: $f"
  fi
done

PROMPT="$TMP/prompt.txt"
{
  cat "$ROOT/$PROMPT_FILE"
  echo
  echo "## 이번 리뷰"
  echo "- 리뷰 기준점: $BASE ($BASE_SHA)"
  echo "- 검토할 파일 (각 파일을 직접 열어 전체 내용을 확인할 것. untracked 파일은 git diff에 나타나지 않는다):"
  for f in "${FILES[@]}"; do echo "  - $f"; done
  [ -n "$SPEC" ] && echo "- 수용 조건이 있는 명세: $SPEC"
  echo "- 리뷰 실행 규칙 파일 (리뷰 대상이 아님, 규칙으로만 참조): ${RULE_FILES[*]}"
  if [ -n "$NOTES" ]; then
    echo
    echo "## 구현자 증거 요약 (참고용 데이터. 코드와 대조해서 확인할 것)"
    cat "$ROOT/$NOTES"
  fi
} > "$PROMPT"

if $DRY; then
  echo "== snapshot: $SNAP (종료 시 삭제됨)"
  echo "== 기준점 대비 변경:"; git -C "$SNAP" status --short
  echo "== 프롬프트 ($(wc -l < "$PROMPT")줄):"; cat "$PROMPT"
  exit 0
fi

# 전체 실행 로그(Codex가 읽은 파일 내용 포함, 수십 KB)는 임시 파일로 돌리고 최종 메시지만 출력한다.
LOG="$TMP/codex.log"; LAST="$TMP/last-message.md"
if codex exec \
  --cd "$SNAP" \
  --sandbox read-only \
  --ephemeral \
  --ignore-user-config \
  --strict-config \
  -c 'approval_policy="never"' \
  -c "model_reasoning_effort=\"$EFFORT\"" \
  -o "$LAST" \
  - < "$PROMPT" > "$LOG" 2>&1; then
  # 실제로 적용된 모델·effort를 한 줄로 보여 준다 (설정이 무시되었는지 확인용)
  echo "[codex] $(grep -E '^(model|reasoning effort):' "$LOG" | tr '\n' ' ')" >&2
  cat "$LAST"
else
  FAILED_LOG="$(mktemp "${TMPDIR:-/tmp}/codex-review-fail.XXXXXX")"; cp "$LOG" "$FAILED_LOG"
  die "Codex 실행에 실패했습니다. 전체 로그: $FAILED_LOG"
fi
