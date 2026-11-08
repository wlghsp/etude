# 명세 (초안) — 피드백 이미지 첨부

> 상태: **확정** (2026-11-07). 사용자 지시: 첨부는 로그인만 허용, 나머지는 구현자가 적절히 선택. 자동 삭제도 포함한다.
> 계기: "피드백을 받을 때 이미지 파일 첨부를 받게 해야 한다. 업로드 용량 제한은 필요하고 서버 공간에 저장해도 된다. 피드백 루프에서 처리한 이미지는 삭제하면 되니 용량 문제는 크게 신경 쓰지 않아도 된다. 게시물의 첨부파일이 아니라서 이렇게 해도 된다."
> 파일 업로드·저장·권한·스키마·배포(볼륨, 프록시)를 바꾸므로 구현 전 사용자 승인과 리뷰 대상이다 (CLAUDE.md "항상 리뷰").

## 현재 구조 (코드 확인)

- 제출: `FeedbackButton.tsx` → `POST /feedback` (JSON: page, questId, questSetId, body). 토큰이 있으면 user_id 를 붙이고 **없어도 접수한다** (`feedback.routes.ts`).
- 저장: `feedback` 테이블(body TEXT, 1000자 제한은 화면에서만). 이미지 저장소 없음.
- 회수: 관리자가 `bash backend/http/fetch-feedback.sh` 로 `GET /admin/feedback` 결과를 `feedback.json` 으로 받아 Claude Code 와 분석한다 (`docs/ops/guide_feedback_review.md`). 관리자 화면에는 피드백 목록이 없다.
- 운영 환경: backend 컨테이너에 **영속 볼륨이 없고**(소켓·kubeconfig 마운트뿐), nginx 에 `client_max_body_size` 설정이 없어 기본 1MB 를 넘는 요청은 413 으로 거부된다.

## 목표

1. 피드백에 스크린샷을 최대 3장 첨부할 수 있다 (붙여넣기·끌어놓기·파일 선택).
2. 서버 디스크에 저장하고, 관리자만 받아 볼 수 있다.
3. 피드백 처리가 끝나면 이미지를 지운다. 글(body)은 남긴다.

## 결정 사항 (확정)

| # | 결정 | 추천 | 이유 |
|---|------|------|------|
| 1 | 비로그인 제출에 첨부 허용? | **로그인한 사용자만 첨부**. 글만 보내는 것은 지금처럼 허용 | 비로그인 업로드는 디스크를 아무나 채울 수 있다. 사내 도구라 로그인 요구가 부담 없다 |
| 2 | 제한 | **3장, 장당 5MB, 합계 10MB**, 형식은 PNG·JPEG·WebP | 화면에서 긴 변 1600px 로 줄여 올리면 보통 1MB 미만이라 제한에 거의 안 걸린다. 서버는 마지막 방어선 |
| 3 | 업로드 방식 | 기존 `POST /feedback` 이 `multipart/form-data` 도 받는다 (JSON 도 그대로) | 한 번의 요청으로 글과 이미지가 같이 저장된다. 의존성 `@fastify/multipart` 1개 추가 |
| 4 | 삭제 | 관리자 삭제 API + 스크립트(처리 후 수동) **와** 자동 삭제: 첨부 생성 후 `FEEDBACK_ATTACHMENT_RETENTION_DAYS`(기본 30)일이 지난 이미지는 백엔드가 기동 시와 24시간마다 지운다 | 처리 후 삭제를 잊어도 디스크가 쌓이지 않는다. 글(body)은 남긴다 |

## 설계

### 저장

- 경로: 환경 변수 `FEEDBACK_UPLOAD_DIR` (기본 `/app/data/feedback`). **웹 루트 밖**이고 정적 서빙하지 않는다.
- 파일명은 서버가 만든다: `{feedbackId}-{순번}-{랜덤 16자 hex}.{ext}`. 원래 파일명은 저장하지 않는다 (경로 조작·개인정보 방지).
- 새 테이블 `feedback_attachment` (id, feedback_id → feedback, stored_name, mime, size_bytes, created_at). 마이그레이션은 `NOT EXISTS` 가드로 여러 번 실행해도 안전하게 쓰고 `00_schema.sql` 에도 반영한다.
- 운영: `deploy/docker-compose.prod.yml` 의 backend 에 named volume (`etude-feedback-files:/app/data/feedback`) 을 추가한다. 없으면 재배포 때 사라진다.

### 검증 (서버)

- **파일 내용(매직 바이트)으로 형식을 판정**한다. 확장자·Content-Type 헤더는 믿지 않는다. PNG·JPEG·WebP 외(SVG·GIF·HTML 등)는 거부한다. SVG 는 스크립트를 담을 수 있어 받지 않는다.
- 장수·장당 크기·합계 크기를 서버에서 다시 검사한다 (`@fastify/multipart` 의 `limits` + 합계 확인). 초과하면 **글도 저장하지 않고** 400 과 이유를 돌려준다 (일부만 저장되는 상태를 만들지 않는다).
- 토큰이 없거나 잘못된 요청에 파일이 있으면 401 로 거부한다.
- 저장 도중 DB 오류가 나면 이미 쓴 파일을 지운다 (고아 파일 방지).

### 회수·삭제 (관리자 전용, `adminMiddleware`)

- `GET /admin/feedback`: 각 피드백에 `attachments: [{ id, mime, sizeBytes }]` 를 추가한다.
- `GET /admin/feedback/attachments/:id`: 이미지 본문. `Content-Type` 은 DB 의 mime, `X-Content-Type-Options: nosniff`, `Content-Disposition: attachment`.
- `DELETE /admin/feedback/attachments/:id` 와 `DELETE /admin/feedback/:id/attachments`: 파일과 행을 지운다. 파일이 이미 없어도 행은 지운다. 피드백 글은 남는다.
- `backend/http/fetch-feedback.sh` 는 이미지를 `feedback_images/` 로 함께 내려받고 `feedback.json` 의 각 항목에 로컬 파일 경로를 적는다. Claude Code 가 그 파일을 열어 볼 수 있다.
- `backend/http/delete-feedback-images.sh` (신규): 관리자 로그인 후 **지울 피드백 id 를 인자로 받아** 해당 이미지만 지운다. 전체 삭제는 하지 않는다.
- `.gitignore` 에 `feedback_images/` 를 추가한다 (스크린샷에 개인 정보가 있을 수 있다. `feedback*.json` 과 같은 이유).

### 프런트 (`FeedbackButton.tsx`)

- 모달에 "이미지 첨부" 영역: 파일 선택 버튼, **클립보드 붙여넣기(Ctrl/⌘+V)**, 끌어놓기. 썸네일 미리보기와 개별 삭제(×), "n / 3".
- 로그인하지 않았으면 첨부 영역을 숨기거나 "로그인하면 이미지를 첨부할 수 있어요" 를 보여 준다.
- 올리기 전에 캔버스로 긴 변 1600px, JPEG/WebP 품질 0.85 로 줄인다 (PNG 투명 필요 없음). 원본이 이미 작으면 그대로 보낸다. 줄이기에 실패하면 원본을 보내고 서버 제한에 맡긴다.
- 안내 문구: "화면에 비밀번호나 개인 정보가 보이면 가려서 올려 주세요."
- 오류(형식·용량·장수)는 모달 안에 이유를 보여 주고 이미 쓴 글은 지우지 않는다.
- 제출 중에는 버튼을 막는다. 성공 토스트는 지금과 같다.

### 문서

- `docs/ops/guide_feedback_review.md` 에 이미지 내려받기·확인·삭제 단계를 추가한다 (Step 순서: 가져오기 → 분석 → 수정 → **처리한 이미지 삭제**).
- 서버 배포 절차(`guide_post_deploy_checklist.md`)에 볼륨과 `client_max_body_size` 확인을 추가한다.

## 배포 영향

- `deploy/nginx.conf`: `POST /feedback` 에만 `client_max_body_size 12m` 를 둔다 (`location = /feedback` 으로 분리해 같은 `@backend` 로 프록시). 전체에 올리지 않는다.
- `deploy/docker-compose.prod.yml`: backend 볼륨 추가.
- 새 마이그레이션 1개 (`feedback_attachment`).
- 의존성: `@fastify/multipart` (백엔드).

## 수용 조건

1. 로그인한 사용자가 PNG 한 장과 글을 보내면 `feedback`·`feedback_attachment` 에 1건씩 저장되고 파일이 `FEEDBACK_UPLOAD_DIR` 에 생긴다.
2. 확장자가 `.png` 라도 내용이 PNG 가 아니면 400 이고 아무것도 저장되지 않는다. SVG·GIF 도 400.
3. 4장째, 장당 5MB 초과, 합계 10MB 초과는 각각 400 이고 아무것도 저장되지 않는다.
4. 토큰 없이 파일을 보내면 401. 토큰 없이 글만 보내는 기존 동작은 그대로 200.
5. JSON 로만 보내는 기존 요청(첨부 없음)이 그대로 동작한다.
6. 관리자가 아닌 사용자는 첨부 조회·삭제 API 에서 403 (또는 기존 `adminMiddleware` 와 같은 응답).
7. 삭제 API 호출 뒤 파일과 `feedback_attachment` 행이 없고 `feedback` 글은 남는다.
8. 저장 중 오류가 나면 이미 쓴 파일이 남지 않는다.
9. 저장 파일명에 원래 파일명이 들어가지 않고, 경로 구분자가 있는 업로드 이름으로도 `FEEDBACK_UPLOAD_DIR` 밖에 쓰이지 않는다.
10. 응답 헤더에 `nosniff` 와 DB 의 mime 이 들어간다.
11. 자동 삭제: 보관 기간이 지난 첨부는 파일과 행이 지워지고 기간 안의 첨부와 피드백 글은 남는다. 파일이 이미 없어도 행은 지운다.

## 범위 밖

- 이미지 외 첨부(로그·동영상), 사용자 본인의 첨부 조회·수정, 관리자 화면에서의 피드백 목록(지금은 스크립트로 회수), 바이러스 검사, 이미지 EXIF 제거(화면에서 다시 그려 올리므로 줄이기에 성공하면 자연히 사라진다. 원본 그대로 올라가는 경우는 남는다).

## 검증

- 백엔드: 라우트 테스트(수용 조건 1~10, 실제 임시 폴더 사용)를 먼저 쓰고 실패(RED)를 확인한 뒤 구현한다.
- 프런트: 타입 검사와 빌드. 화면 동작은 사용자가 확인한다.
- 리뷰: 업로드·인증·스키마·인프라 변경이므로 `--effort high`, 재검토 최대 3회.
