# 운영 가이드 — 피드백 수집 및 반영 사이클

## 목적

배포 후 팀원들이 남긴 피드백을 로컬에서 꺼내와 Claude Code와 함께 분석하고 개선 작업으로 연결하는 흐름을 정리한다.

---

## 전체 흐름

```
1. 서버에서 피드백 가져오기  →  feedback.json (로컬)
2. Claude Code와 함께 분석  →  개선 항목 정리
3. 코드 수정 + 재배포
```

---

## Step 1~2. 피드백 가져오기

관리자 로그인이 필요하다. 스크립트가 비밀번호를 입력창에서만 받는다 (인자·환경변수·히스토리에 남기지 않는다).

```bash
bash backend/http/fetch-feedback.sh https://{서버 도메인} {관리자 이메일}
# 비밀번호 입력 후: 저장 완료: feedback.json (12건)
```

- `feedback.json`은 저장소 루트에 생기고 `.gitignore`(`feedback*.json`)로 커밋되지 않는다. 개인 정보가 있을 수 있어 로컬에서만 읽는다.
- 저장 위치를 바꾸려면 `FEEDBACK_OUT=경로`를 앞에 붙인다.
- 건수가 `0`이면 아직 피드백이 없는 것이고, 로그인 실패 메시지가 나오면 주소·계정을 확인한다.

피드백 한 건의 필드: `id`, `userName`, `page`(제출 시점 화면), `questSetTitle`, `questTitle`, `body`, `createdAt`.

---

## Step 3. Claude Code와 분석

`feedback.json`을 열고 요청한다:

```
feedback.json 읽고 아래 분류로 정리해줘. 근거가 된 id를 같이 적어줘.
```

분류 기준:

| 분류 | 예 | 해결 방식 |
|------|----|----------|
| 채점 오류 | "정답을 해도 실패", "이미 통과로 나옴" | 채점 검증 러너로 재현 → 퀘스트 SQL 수정 → 러너로 재검증 ([명세](../specs/spec_grading_verification.md)) |
| 지문·힌트 | "지문이 모호", "힌트가 어렵다" | 퀘스트 SQL 수정 (콘텐츠) |
| 환경·연결 | "터미널이 안 열림", "준비 중에서 멈춤" | 서버 로그 확인 → 원인 파악 후 수정. 여러 단계 거친 문제는 `troubleshooting_*.md`로 기록 |
| 화면·사용성 | "버튼을 못 찾겠다" | 프론트 수정 |
| 기능 요청 | "이런 퀘스트가 있으면" | 로드맵에 반영할지 사용자가 정한다 |

중요도는 **얼마나 많은 사람이 겪는지**와 **퀘스트를 풀 수 없게 막는지**로 정한다. 한 명의 취향 의견보다 여러 명이 겪는 막힘을 먼저 본다.

특정 화면이나 퀘스트에 집중할 때:

```
feedback.json에서 page가 "quest"인 항목만 정리해줘
```

---

## Step 4. 하나씩 고치고 반영

1. 분석 결과에서 순번을 정한다 (사용자가 최종 결정).
2. 항목마다: 재현 → 수정 → 확인 → 사용자 확인 후 커밋 (기능 변경은 사용자가 결과를 확인하기 전에 커밋하지 않는다).
3. 한 묶음이 끝나면 서버에 반영한다.

```bash
# 서버에서
cd ~/etude
git pull

# 프론트 변경 시
cd frontend && npm run build && cd ..

# 재시작 (.env.prod를 고쳤다면 반드시 --build)
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

배포 후에는 [배포 직후 체크리스트](guide_post_deploy_checklist.md)를 훑는다.
