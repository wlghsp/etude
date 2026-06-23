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

### 현재 MVP 범위

브라우저 터미널 실행 + 퀘스트 2개 하드코딩 + 채점. 로그인/DB/AI 없음.

Phase 1 (터미널 작동) → Phase 2 (퀘스트 + 채점) → Phase 3 (UX 개선)

### 문서

- `docs/product/okestro_training_platform.md` — 제품 기획/요구사항
- `docs/etude_dev_plan.md` — 개발 계획 및 아키텍처
- `docs/etude_dev_guide.md` — Phase별 가이드 인덱스
- `docs/guides/` — Phase별 구현 가이드
- `docs/specs/` — Phase별 명세
- `docs/glossary/` — 개념 설명
- `docs/research/` — 개발 방법론/AI 연구

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

### 컨텍스트 제공 방식

구현 질문 시 관련 문서를 함께 제공한다:
- 터미널/WebSocket 관련 → `@docs/etude_dev_guide.md`
- 퀘스트/채점 관련 → `@docs/etude_dev_guide.md` + `@docs/etude_dev_plan.md`
- 제품 방향/기능 범위 관련 → `@docs/okestro_training_platform.md`

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