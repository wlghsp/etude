# CLAUDE.md

## 프로젝트: Etude

오케스트로 사내 현장 실습 트레이닝 플랫폼.
실무자가 현장 작업/장애 사례를 입력하면 AI가 퀘스트로 변환하고, 구성원이 브라우저 터미널에서 직접 실습한다.

### 스택

- **프론트**: React + TypeScript (Vite) — `frontend/`
- **백엔드**: Node.js + Fastify + TypeScript — `backend/`
- **터미널**: xterm.js + WebSocket
- **샌드박스**: Docker 컨테이너 (dockerode)
- **DB**: MariaDB (MVP 이후 도입, 현재는 하드코딩)
- **AI**: Claude API (퀘스트 자동 생성, MVP 이후)

### 문서

- `docs/product/okestro_training_platform.md` — 제품 기획/요구사항
- `docs/etude_dev_plan.md` — 개발 계획 및 아키텍처
- `docs/etude_dev_guide.md` — Phase별 가이드 인덱스
- `docs/guides/` — Phase별 구현 가이드
- `docs/ops/` — 운영 가이드 (배포 후 반복 운영 절차), 트러블슈팅 기록 (`troubleshooting_{날짜}_{주제}.md`)
- `docs/specs/` — Phase별 명세
- `docs/glossary/` — 개념 설명
- `docs/research/` — 개발 방법론/AI 연구

---

## 개발 방식

### 역할 분담 (구현자 / 리뷰어 / 사용자)

AI 구현 + 독립 AI 리뷰 + 사용자 승인으로 진행한다. 구현 가이드는 쓰지 않는다. 명세와 수용 조건이 작업 지시서다.

| 역할 | 담당 | 하는 일 |
|------|------|---------|
| 구현자 (Implementer) | 기본값 Claude | 명세·테스트·코드를 작성하고 수정한다. 리뷰 지적을 반영한다. |
| 리뷰어 (Reviewer) | 기본값 Codex | **읽기 전용**으로 명세와 고정된 diff만 검토한다. 수정하지 않는다. |
| 사용자 | — | 최종 결정, 수동 검증(화면·서버), 커밋·푸시 승인 |

- **한 작업 조각 안에서는 역할을 바꾸지 않는다.** 구현한 쪽이 자기 결과를 리뷰하지 않는다.
- 구현자는 **사용자가 요청한 범위 안에서** 소스(`backend/`, `frontend/` 등)를 직접 수정한다. 범위를 넘는 변경은 먼저 묻는다.
- 문제가 생기면 원인을 설명한 뒤 수정한다. 막힌 곳이 설계 선택이면 선택지와 추천을 제시하고 사용자가 정한다.

### 작업 조각 진행 방식

명세의 구현 순서를 조각 단위로 나눠 한 번에 하나씩 진행한다.

1. 수용 조건을 테스트로 먼저 작성하고, 실패(RED)를 확인한다.
2. 구현하고, 통과(GREEN)를 확인한다.
3. 구현자가 작업을 멈추면, 리뷰어가 읽기 전용으로 검토한다.
4. 지적 사항을 구현자가 반영한다.
5. 사용자가 확인한 뒤 커밋을 요청한다.

**리뷰 요청 시 구현자가 함께 전달하는 것**

- 리뷰 기준점 (예: `HEAD` 대비 작업 트리, 특정 커밋, 브랜치). 관련 없는 변경이 섞여 있으면 리뷰할 파일 범위를 명시한다.
- 변경 파일 목록
- 수용 조건별 구현 위치
- RED에서 실패한 테스트
- GREEN에서 통과한 명령과 결과
- 알려진 미해결 사항

**동시 수정 금지**

리뷰가 끝날 때까지 구현자는 같은 작업 트리를 수정하지 않는다. 병렬 구현은 브랜치·worktree가 분리된 경우에만 한다.

**리뷰어 호출**

- 구현자가 `scripts/review/codex-review.sh`로 호출한다 (읽기 전용 sandbox, 정제한 임시 worktree에서 실행. 우발적 민감 파일 노출을 막는 allowlist 방식이며 OS 수준의 하드 격리는 아니다). 규칙과 출력 형식(`차단 / 권고 / 참고`, 판정 `PASS | CHANGES_REQUIRED`)은 `scripts/review/prompt.md` 한 곳에만 둔다. 호출마다 프롬프트를 새로 쓰지 않는다.
- 호출은 구현이 완전히 멈춘 뒤에만 한다. **첫 호출은 사용자 승인을 받는다** (저장소 내용이 외부 서비스로 전송된다).
- 리뷰어의 결과는 구현자가 축약하지 않고 사용자에게 그대로 전달한다. 구현자는 지적을 반영하거나, 동의하지 않으면 근거를 적어 반박한다. 최종 결정은 사용자가 한다.
- 리뷰어는 테스트를 실행하지 않는다. 실행 증거는 구현자가 메모로 제공하고 리뷰어는 코드와 대조한다. 명세가 없는 작업은 notes에 목적과 수용 조건 3~5개를 적는다.
- **승인 주체:** 외부 전송, 상태 변경, 커밋·푸시는 사용자만 승인한다. 리뷰어의 "승인"은 기술적 동의일 뿐 사용자 권한을 대신하지 않는다. 사용자는 첫 승인 때 "같은 파일 범위에서 최대 N회 재검토"까지 함께 승인할 수 있다.
- **재검토 상한:** 기본 최대 2회, 보안·인프라·데이터 변경은 최대 3회. 상한에 도달하면 자동으로 반복하지 않는다. 남은 차단과 수용 사유를 기록하고 사용자가 판단한다 (자동 PASS 취급 아님). 새 차단은 신뢰된 단일 개발자·로컬 도구라는 위협 모델에 해당하는지 먼저 판단한다.
- **reasoning effort:** 일반 코드·테스트 `medium`, 인증·인가·세션·인프라·삭제 `high`, 문서·오탈자는 리뷰 생략 또는 `low` (`--effort`).
- **검증 표현:** 주장은 `검증됨`(실행 명령과 결과 있음) / `코드상 확인됨`(정적 확인만) / `미검증·추정`(운영·UI·인프라 확인 필요)으로 구분해서 쓴다.
- **응답은 결론·현재 상태·다음 행동 중심으로 짧게 쓴다.** 근거는 요청받을 때 펼친다. 리뷰어 호출은 최종 메시지만 읽고, 전체 로그는 실패했을 때만 연다.

**리뷰 대상 (위험도 기준)**

- 항상: 명세와 수용 조건, 인증·인가·세션·소유권, 인프라·배포·CI, 삭제·정리·마이그레이션, DB 스키마·데이터 변경, API/WebSocket 계약, 동시성·수명주기·재시도, 의존성 추가·업그레이드, 테스트 기반·보안 테스트
- 조건부: 일반 기능 구현, 동작을 유지하는 리팩터링, 의미 있는 테스트 케이스 추가
- 생략 가능: 오탈자·포맷팅·링크 경로 수정, 자동 생성 산출물, 의미가 바뀌지 않는 비규범 문서 정리. 단, `specs/`·운영 절차·보안 문서는 문서여도 리뷰한다.

병렬 트랙(worktree 분리와 교차 리뷰)은 단일 트랙에서 3~5개 조각을 안정적으로 반복한 뒤 검토한다.

**리뷰 결과 기록**

모든 리뷰 대화를 문서화하지 않는다. 지속 가치가 있는 설계 결정과 위험만 명세에 반영하고, 오타나 구현 실수는 diff에서 고치는 것으로 충분하다.

### 민감 파일 (모든 에이전트 공통)

다음은 출력·커밋하지 않는다: `.env*`, `backend/db/04_users.sql`, `backend/db/users/users.txt`, Terraform `terraform.tfvars`·state·plan(`*.tfplan`). 필요한 값은 사용자가 직접 확인하게 안내한다.

### 커밋/푸시 규칙

- **사용자가 명시적으로 요청하기 전에는 커밋/푸시하지 않는다.** (구현자·리뷰어 모두)
- 버그 수정이나 기능 변경 후에는 사용자가 결과를 확인한 뒤 커밋을 요청할 때까지 기다린다.
- 규칙·거버넌스 문서의 변경과 기능 구현은 별개의 논리적 변경이므로 커밋을 분리한다.

---

## 개발 프로세스

### 명세 선행 (Spec-First)

기능 구현 전 반드시 문서를 먼저 작성하거나 확인한다.

```
1. docs/ 에서 관련 명세 확인 또는 작성
2. 구현 계획을 한 줄로 명시 ("이 문서의 X를 보고 Y를 구현합니다")
3. 구현
4. 검증 기준 확인 (dev_guide의 Phase 검증 항목 기준)
```

새 기능이나 설계 변경이 생기면 코드보다 문서를 먼저 업데이트한다.
문서와 코드가 어긋나면 문서가 기준이다.

### 트러블슈팅 기록

실제 배포/서버 운영 중 "가이드대로 했는데 안 됨 → 원인 파악 → 해결"을 여러 단계 거친 문제는 세션 로그와 별개로 `docs/ops/troubleshooting_{날짜}_{주제}.md`로 남긴다. 증상-원인-해결 흐름을 비개발자도 따라올 수 있게 쉬운 말로 정리한다. 로컬 개발 중 사소한 오타 수정 정도는 대상이 아니다.

### 컨텍스트 제공 방식

구현 질문 시 관련 문서를 함께 제공한다:
- 터미널/WebSocket 관련 → `@docs/etude_dev_guide.md`
- 퀘스트/채점 관련 → `@docs/etude_dev_guide.md` + `@docs/etude_dev_plan.md`
- 제품 방향/기능 범위 관련 → `@docs/okestro_training_platform.md`

---

## 설계 원칙

### 단일 진실 공급원 (Single Source of Truth)

모든 설정과 데이터는 한 곳에만 존재해야 한다. 같은 정보가 두 곳 이상에 있으면 반드시 하나를 기준으로 삼고 나머지는 참조하게 만든다.

| 정보 | 유일한 출처 |
|------|------------|
| 샌드박스 환경 설정 (이미지, 마운트) | `sandbox` 테이블 |
| 퀘스트/세트 내용 | `backend/db/03_quest_set*.sql` |
| API 엔드포인트 URL | `frontend/src/api/` |

### 레이어 역할 분리

각 레이어는 자신의 역할만 안다. 아래 방향으로만 의존한다.

```
DB → 백엔드 서비스 → 라우터 → 프론트엔드
```

- `terminal.ts` — 컨테이너 생성/연결만. 라우팅 모름.
- `index.ts` — 요청 파싱/응답만. 컨테이너 생성 방법 모름.
- `Terminal.tsx` — WebSocket 연결만. 퀘스트 내용 모름.

### 프론트엔드 폴더 구조

`pages/`는 `components/`를 참조할 수 있지만, `components/`는 `pages/`를 참조하지 않는다 (단방향 의존).

- 컴포넌트가 특정 페이지 하나에서만 쓰이면 해당 페이지 폴더 안에 둔다.
- 컴포넌트가 두 개 이상의 페이지에서 쓰이면 `components/`로 옮긴다.
- 지금 규모(수십 파일 이하)에서는 이 정도로 충분하다. entities/features 같은 레이어를 미리 만들지 않는다 — 같은 도메인 로직이 여러 페이지에서 중복되기 시작할 때만 해당 도메인을 슬라이스로 분리한다.

### 확장 비용 기준

새 기능 추가 시 이 기준을 먼저 확인한다:
- 이 변경이 기존 레이어 역할을 침범하는가?
- 같은 정보가 두 곳에 생기지는 않는가?
- 코드에 ID나 문자열을 하드코딩하지는 않는가?

---

## 코딩 가이드라인

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.