# Etude 개발 계획

## 확정 스택

- 프론트: React + TypeScript (Vite)
- 백엔드: Node.js + Fastify + TypeScript
- DB: MariaDB
- 터미널: xterm.js (프론트) + WebSocket (Fastify)
- Docker 제어: dockerode
- 샌드박스: Docker 컨테이너 (퀘스트마다 독립 환경)
- 배포: 사내 서버 (추후)

---

## MVP 범위

- 브라우저 터미널 실행 (xterm.js + WebSocket + Docker 샌드박스)
- 퀘스트 세트 선택 → 퀘스트 진행 → 채점
- 로그인 없음, 리더보드 없음, AI 퀘스트 생성 없음

핵심 검증 목표: "브라우저에서 터미널을 열고, 명령어를 실행하고, 채점까지 되는가"

---

## 아키텍처

```
브라우저 (React)
    ├── xterm.js 터미널 UI
    └── WebSocket 연결 → Fastify

Fastify 서버 (Node.js + TypeScript)
    ├── WebSocket 엔드포인트 — 터미널 입출력 스트리밍
    ├── Docker 컨테이너 생성/제거 (dockerode)
    ├── 퀘스트 API — 퀘스트 지문, 채점 기준 제공
    └── 채점 API — 컨테이너 상태 확인 후 성공/실패 반환

Docker 컨테이너 (샌드박스)
    └── 퀘스트마다 격리된 Linux 환경
        명령어 실행 결과가 여기서 나옴
        퀘스트 종료 시 컨테이너 제거 (persistent 타입 제외)
```

---

## Phase 1 — 터미널 샌드박스 단독 작동 ✅ 완료

목표: 브라우저에서 터미널 열고 명령어 실행되는 것만 확인

- Fastify + dockerode로 컨테이너 생성/실행/제거
- WebSocket 엔드포인트 구현, 입출력 스트리밍
- xterm.js 터미널 컴포넌트 구현

---

## Phase 2 — 퀘스트 붙이기 ✅ 완료

목표: 퀘스트 지문 + 터미널 레이아웃 + 채점

- 퀘스트 하드코딩 (TypeScript 객체)
- 채점 API — 컨테이너 안에서 조건 확인 후 성공/실패 반환
- 퀘스트 지문 패널 + 터미널 좌우 레이아웃

---

## Phase 3 — 로컬에서 직접 써보기 ✅ 완료

목표: 실제로 써보면서 UX 문제 발견 및 수정

- 채점 중 로딩 표시
- 마지막 퀘스트 완료 후 안내 메시지
- 터미널 폰트/스타일 개선

---

## Phase 4 — MariaDB 연동 + 퀘스트 세트 구조 ✅ 완료

목표: 퀘스트를 DB에서 관리하는 인프라 교체. 기존 2개 퀘스트를 DB로 마이그레이션하고 세트 선택 화면 추가.

- MariaDB 연결 (mysql2), `init.sql`로 스키마 + 시드 관리
- `/quest-sets`, `/quest-sets/:id/quests`, `/grade` API
- 세트 선택 화면 → 퀘스트 진행 흐름

### DB 스키마 (현재)

```
sandbox   — 샌드박스 환경 (type, image, binds, persistent)
quest_set — 퀘스트 세트 (id, title, description, sandbox_type, category)
quest     — 개별 퀘스트 (id, quest_set_id, title, description, hint, grade_cmd, setup_cmd)
```

---

## Phase 5 — 퀘스트 콘텐츠 확장 ✅ 완료

목표: 팀원이 실제로 써보고 "쓸 만하다"는 느낌을 받을 수 있는 수준의 퀘스트 세트 구축.

### 퀘스트 세트 현황

| 세트 | 제목 | sandbox | 퀘스트 수 |
|------|------|---------|---------|
| 1 | 리눅스 기초 1 — 파일 탐색과 생성 | linux | 10 |
| 2 | 리눅스 기초 2 — 삭제·검색·권한 | linux | 10 |
| 3 | 리눅스 기초 3 — 프로세스와 시스템 | linux | 8 |
| 4 | 리눅스 네트워크/파일 전송 | linux-ssh | 8 |
| 5 | Docker 기초 | docker | 10 |
| 7 | 리눅스 압축과 아카이브 | linux | 9 |
| 8 | Docker 이미지 오프라인 반입 | docker-persistent | 7 |

### Persistent Sandbox

퀘스트를 넘겨도 동일 컨테이너 유지. `docker save → load → tag → push` 같이 상태가 이어져야 하는 실습에 사용.

- `sandbox.persistent` 컬럼으로 제어
- `docker-persistent` 타입: 퀘스트 간 컨테이너 재사용, 세트 종료 시 `/session/end`로 정리

### SetSelect UI

- `quest_set.category` 컬럼 기준 카테고리 아코디언 (리눅스 🐧 / 도커 🐳 / k8s ☸️)

---

## Phase 6 — k8s 기초 실습 세트 ✅ 완료

목표: kubectl 실습 환경 제공. k3d 로컬 클러스터 + etude-k8s 컨테이너.

- k3d로 로컬 단일 노드 k3s 클러스터 구동
- `etude-k8s` 이미지: kubectl + kubeconfig 마운트
- 사용자별 namespace 격리
- 세트 6: k8s 기초 (pod/deployment/service/namespace 조작)

---

## Phase 7 — 사용자 인증 + 진행 추적

목표: 팀원이 로그인하고 퀘스트를 풀면 시도 이력이 기록된다. 관리자는 전체 팀원 현황을 조회할 수 있다.

### DB 스키마 추가

```
user            — 사용자 (이름, 이메일, 역할: member/admin)
quest_attempt   — 퀘스트 시도 이력 (user_id, quest_id, session_id, elapsed_sec, hint_used, solution_used, passed)
```

`quest_attempt`는 중복 허용 — 반복 시도가 쌓이는 구조. Phase 9 분석의 원본 데이터.

### 기능

- 로그인 (사내 이메일 기반, JWT) + 관리자가 계정 직접 생성
- 퀘스트 채점 시 attempt 기록 (소요 시간, 힌트/풀이 사용 여부 포함)
- 대시보드 — 내 세트별 진행률 (passed attempt 기준)
- 관리자 뷰 — 전체 팀원 세트별 진행 현황

### 검증

- 로그인 → 퀘스트 풀기 → attempt 기록 → 대시보드 확인
- 관리자 계정으로 /admin/progress 조회

---

## Phase 8 — 서버 배포 (OCI Free Tier)

목표: OCI Always Free VM에 Etude를 배포한다. 팀원이 브라우저로 접속해서 퀘스트를 풀 수 있는 상태를 만든다.
Phase 7 (인증) 완료 후 배포한다.

### 인프라

- **서버**: OCI Always Free ARM VM (4 OCPU / 24GB RAM)
- **프로비저닝**: Terraform (`infra/terraform/`)
- **앱 구성**: docker-compose.prod.yml — nginx + backend + MariaDB
- **배포 방식**: 수동 (`git pull` + `docker compose up`) — CI/CD는 추후 검토

### 구성

- nginx — 프론트 정적 서빙 + `/api`, `/ws` 리버스 프록시
- backend — Fastify 빌드 이미지
- MariaDB — 기존과 동일
- k3d 클러스터 — VM에 별도 설치, k8s 퀘스트용

### 피드백 수집

피드백은 누가 쓰는지 알아야 의미가 있으므로 인증 완료 후 붙인다.

- 화면 우하단 고정 피드백 버튼
- 클릭 시 textarea 팝업 (현재 페이지 + 로그인 사용자 자동 포함)
- `POST /feedback` → `feedback.jsonl` 에 append

저장 형식:

```json
{"ts": "2025-06-26T10:30:00Z", "user": "홍길동", "page": "quest", "text": "채점 버튼이 어디있는지 모르겠음"}
```

### 검증

- `http://{공인IP}` 접속 → 세트 선택 화면 로드
- linux / docker / k8s 퀘스트 세트 터미널 + 채점 동작 확인
- 팀원이 실제로 접속해서 퀘스트를 풀고 피드백을 남길 수 있음

---

## Phase 9 — 퀘스트 콘텐츠 확장 2

목표: 현장 밀착형 + 시험 준비용 퀘스트 세트 추가.

### 현장 실무 세트

- **CMP 배포 세트** — KLID CMP 배포 가이드 기반, 이미지 반입 → 배포 → 재시작 흐름
- **k8s 현장 세트** — deployment 업데이트, 롤백, 트러블슈팅 (502/OOM/CrashLoop)

### 시험 준비 세트

- **CKA 준비 세트** — kubectl 심화, pod/deployment/pv/pvc/rbac 등 CKA 시험 빈출 영역
  - k8s 기초 세트(세트 6) 위에 난이도를 높인 구성

---

## MVP 이후 로드맵

### 1단계 — 사용자 인증 + 실배포 (Phase 7~8)

팀원들이 실제로 쓸 수 있는 환경을 만드는 단계.

- 로그인 → 진행 추적 → 서버 배포
- 이 단계 완료 = "팀원 누구나 언제든 접속해서 퀘스트를 풀 수 있다"

### 2단계 — 피드백 수집 후 안정화 (Phase 8 이후)

실사용 데이터를 바탕으로 품질을 올리는 단계.

- 피드백으로 불편한 점 수집
- 퀘스트 품질 개선 — 지문 모호한 거, 채점 안 되는 거 수정
- 목표: 외부 플랫폼(KodeKloud) 없이 우리 현장 퀘스트를 풀 수 있다는 것 확인

### 3단계 — 콘텐츠 심화 (Phase 9~)

플랫폼이 안정화된 뒤 콘텐츠를 쌓는 단계.

- CKA 준비 세트, CMP 배포 세트 등 현장/시험 밀착형 퀘스트

---

## 향후 (시점 미정)

- **퀘스트 관리 UI** — 어드민에서 퀘스트/세트 CRUD
- **AI 퀘스트 생성** — 실무자 입력 → Claude API → 퀘스트 자동 변환 (플랫폼 안정화 후 가장 마지막 단계)
- **게임 모드 (Token Scrooge)** — 적은 AI 토큰으로 퀘스트를 완수한 사람이 이기는 경쟁 게임 모드. 팀 행사/평가 자리에서 사용. AI 채팅 인터페이스 + 토큰 측정 + 리더보드 + 결과 리포트 필요. 플랫폼 안정화 후 추가.
- **로딩 화면** — 세트 선택 후 컨테이너 준비 중 로딩 표시
- **고아 컨테이너 GC** — 브라우저 강제 종료 시 `docker-persistent` 컨테이너 미정리 문제
- **UI 개선** — KodeKloud 레이아웃 참고 (상단 헤더바, 탭 구조, 진행 표시)
- **오픈스택 퀘스트** — 서버 자원이 충분할 때. 공유 DevStack 1개 + 사용자별 프로젝트(테넌트) 격리. VM/네트워크/볼륨은 프로젝트 단위로 분리되어 다른 사용자 실습에 영향 없음. 컴퓨트 자원은 quota로 제한. k8s namespace 격리와 같은 맥락 (자원 제약으로 인한 공유 인프라 위 논리적 격리)

---

## 프로젝트 구조

```
etude/
├── frontend/src/
│   ├── components/
│   │   ├── Terminal.tsx        # xterm.js 터미널, containerId prop
│   │   ├── QuestPanel.tsx      # 퀘스트 지문 + 채점 버튼
│   │   └── FeedbackButton.tsx  # (Phase 8) 전역 피드백 버튼
│   ├── pages/
│   │   └── SetSelect.tsx       # 카테고리 아코디언 세트 선택 화면
│   ├── App.tsx                 # persistent sandbox 세션 관리
│   ├── api.ts                  # fetchQuestSets, fetchQuests, gradeQuest, endSession, submitFeedback
│   └── types.ts
│
├── backend/src/
│   ├── index.ts      # Fastify 앱, /session/end, /feedback 엔드포인트
│   ├── terminal.ts   # WebSocket + Docker 제어, persistent 분기
│   ├── sandbox.ts    # sandbox 설정 조회
│   └── quest.ts      # 퀘스트 데이터 + 채점 로직
│
├── infra/
│   ├── terraform/    # OCI VM + 네트워크 프로비저닝
│   └── scripts/
│       └── setup.sh  # 서버 초기 세팅 (Docker, k3d, kubectl)
│
└── deploy/
    ├── docker-compose.prod.yml  # 프로덕션 compose
    └── nginx.conf               # 리버스 프록시 설정
```

---

## 주요 라이브러리

### 프론트
- xterm — 브라우저 터미널 UI
- @xterm/addon-fit — 터미널 크기 자동 조절

### 백엔드
- fastify — 웹 프레임워크
- @fastify/websocket — WebSocket 플러그인
- dockerode — Docker 컨테이너 제어
- mysql2 — MariaDB 드라이버

---

## 미결 사항

- [x] `init.sql` 재초기화 — `sandbox.persistent`, `quest_set.category` 컬럼 반영 완료
- [x] 컨테이너 label 누락 — `terminal.ts`의 `createContainer` 3곳에 `Labels: { etude: 'sandbox' }` 미추가. phase5c 가이드 참고
- [x] 컨테이너 정리 미구현 — 서버 시작 시 고아 정리(phase5c), 서버 종료 시 정리(phase5e) 모두 `index.ts`에 미반영
- [ ] k8s 샌드박스 격리 수준 — 현재 namespace 격리. OCI 서버(24GB RAM)에서 vcluster per user 검토 가능
- [ ] 로그인 방식 — 사내 이메일 자체 발급 vs SSO 연동 (Phase 7 명세 시점에 확정)
- [ ] 테스트 코드 도입 시점 — 인증 붙기 전. Fastify inject() + vitest 조합 예정
- [ ] frontend API URL — 배포 전 `localhost:3001` → 상대경로(`/api`, `/ws`) 수정 필요
