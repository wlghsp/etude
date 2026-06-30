# Matt Pocock Skills 진단 노트

작성: 2026-06-30
목적: etude 프로젝트에서 Matt Pocock Skills를 어떻게 활용할지 정리한 외부 세션 진단.
설치: `npx skills@latest add mattpocock/skills`

---

## 현재 프로젝트 상태 요약

- Phase 1~6 완료. Phase 7(사용자 인증 + 진행 추적) 진행 예정.
- 백엔드: Node.js + Fastify + TypeScript, 총 ~600줄 (아직 작고 깔끔)
- 핵심 복잡 파일: `terminal.ts` (196줄) — WebSocket + Docker + sandbox 분기 혼재
- CLAUDE.md에 Spec-First 원칙 명시되어 있음. 코드 전 문서 먼저.
- 테스트 코드 없음. dev_plan.md에 "인증 붙기 전에 도입 예정" 명시.

---

## 스킬 활용 권장 순서

### 1순위: /grill-with-docs — Phase 7 명세 작성 전에

Phase 7은 인증이다. 나중에 바꾸기 어려운 결정들이 몰려 있다.

확정해야 할 것들:
- 로그인 방식: 사내 이메일 자체 발급 vs SSO 연동 (dev_plan.md 미결 사항)
- JWT 전략: 액세스 토큰만 vs 리프레시 토큰 포함
- 관리자 계정 생성 흐름: 초기 시드 vs API vs 수동 SQL
- attempt 기록 타이밍: 채점 성공 시만 vs 시도할 때마다
- 세션과 attempt 관계: session_id는 어디서 발급하고 어디서 끊는가

`/grill-with-docs`를 실행하면 에이전트가 이 결정들을 하나씩 질문하면서
CONTEXT.md에 `user`, `attempt`, `session`, `role` 같은 용어를 확정해준다.
명세(docs/specs/) 작성 전에 실행하는 게 맞다.

사용법:
```
/grill-with-docs Phase 7 인증 설계 — JWT 기반 로그인, attempt 기록, 관리자 뷰
```

---

### 2순위: /diagnosing-bugs 원칙 — 버그 발생 즉시 적용

스킬 설치 없이 원칙만 적용해도 된다.

etude의 버그 재현이 어려운 이유:
- 컨테이너 상태에 의존하는 코드가 많다 (terminal.ts)
- WebSocket + Docker + MariaDB가 동시에 물려있다
- 브라우저 강제 종료 → 고아 컨테이너 → 다음 세션에서 이상 동작

핵심 원칙 하나만 기억한다:
> 코드 읽기 전에 재현 명령어부터. `http/terminal.http`가 이미 있으니 여기서 시작.

재현 루프 체크리스트:
1. `http/terminal.http`로 HTTP 요청 재현 가능한가?
2. 안 되면 — 최소 curl 스크립트
3. 안 되면 — 컨테이너만 띄운 throwaway 하네스
4. 피드백 루프가 생기면 그다음에 코드를 읽는다

디버그 로그는 `[DEBUG-xxxx]` 접두사 붙이기. 나중에 grep으로 한 번에 삭제.

---

### 3순위: /to-prd → /to-issues — Phase 7 킥오프 시

dev_plan.md Phase 7 내용이 있지만 실행 단위로 쪼개져 있지 않다.

흐름:
1. `/grill-with-docs`로 설계 확정
2. `/to-prd`로 현재 대화 → PRD 문서화 (docs/specs/phase7.md)
3. `/to-issues`로 수직 슬라이스 이슈로 분해

Phase 7은 로그인 → attempt 기록 → 대시보드 순서로 의존성이 있어서
이슈를 수직 슬라이스로 쪼개지 않으면 "어디서 막혔지?"가 불명확해진다.

예상 슬라이스:
- 슬라이스 1: 로그인 API + JWT 발급 (DB: user 테이블)
- 슬라이스 2: 인증 미들웨어 + 보호된 엔드포인트
- 슬라이스 3: 채점 시 attempt 기록
- 슬라이스 4: 내 진행률 대시보드
- 슬라이스 5: 관리자 뷰 (/admin/progress)

---

### 4순위: /tdd — 인증 로직 구현 시

dev_plan.md 미결 사항에 "테스트 코드 도입 시점 — 인증 붙기 전. Fastify inject() + vitest 조합 예정" 명시되어 있다.

인증은 테스트하기 가장 좋은 영역이다. 순수한 입출력이 많고 외부 의존성(Docker)이 없다.

적용 순서:
1. `vitest` + Fastify `inject()` 세팅
2. `/tdd` 실행
3. 테스트 하나 → 구현 하나 → 반복

주의: 테스트 전체를 먼저 쓰지 말 것. 수직 슬라이스로만.
`auth.ts`가 38줄인 지금이 테스트 붙이기 가장 쉬운 시점이다.

---

## 지금 당장 하나만 한다면

Phase 7 들어가기 전에 `/grill-with-docs` 한 번.

```
/grill-with-docs Phase 7 인증 설계 시작
```

에이전트가 로그인 방식, JWT 전략, attempt 기록 타이밍을 하나씩 질문한다.
그 답이 나오면 CONTEXT.md와 docs/specs/phase7.md가 자동으로 채워진다.
그다음 코드를 짠다.
