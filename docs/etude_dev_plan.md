# Etude 개발 계획

## 확정 스택

- 프론트: React (TypeScript)
- 백엔드: Node.js + Fastify (TypeScript)
- DB: MariaDB
- 터미널: xterm.js (프론트) + WebSocket (Fastify)
- Docker 제어: dockerode
- 샌드박스: Docker 컨테이너 (퀘스트마다 독립 환경)
- 배포: 프론트 Vercel / 백엔드 Railway 무료 티어

TypeScript로 프론트와 백엔드 언어가 통일된다.

---

## MVP 범위

- 브라우저 터미널 실행 (xterm.js + WebSocket + Docker 샌드박스)
- 퀘스트 1~2개 하드코딩 (DB 없이 시작)
- 채점 — 특정 명령어 실행 결과를 서버가 확인해서 성공/실패 판정
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
    └── 사용자별 격리된 Linux 환경
        명령어 실행 결과가 여기서 나옴
        퀘스트 종료 시 컨테이너 제거
```

---

## Phase 1 — 터미널 샌드박스 단독 작동

목표: 브라우저에서 터미널 열고 명령어 실행되는 것만 확인

### 백엔드 (Fastify)
- Fastify 프로젝트 초기화 (TypeScript)
- dockerode로 컨테이너 생성/실행/제거 기본 구현
- `@fastify/websocket` 플러그인으로 WebSocket 엔드포인트 구현
- 입력 받아서 컨테이너에 전달, 출력 브라우저로 스트리밍

```typescript
// 핵심 흐름
fastify.get('/ws/terminal', { websocket: true }, (socket, req) => {
  const container = await docker.createContainer({ Image: 'ubuntu' })
  // 입력 → 컨테이너 exec → 출력 → 브라우저
})
```

### 프론트 (React + TypeScript)
- React 프로젝트 초기화 (Vite + TypeScript)
- xterm.js 설치 및 터미널 컴포넌트 구현
- WebSocket 연결해서 입출력 연동

### 검증
- 브라우저 터미널에서 `ls`, `pwd`, `echo hello` 실행되면 Phase 1 완료

---

## Phase 2 — 퀘스트 붙이기

목표: 퀘스트 지문 + 터미널 레이아웃 + 채점

### 화면 구성
```
┌─────────────────┬─────────────────┐
│   퀘스트 지문    │    터미널        │
│                 │                 │
│ 미션: /tmp에    │ $ mkdir /tmp/   │
│ hello 디렉토리  │ hello           │
│ 를 만드세요     │ $               │
│                 │                 │
│ [채점하기]      │                 │
└─────────────────┴─────────────────┘
```

### 백엔드
- 퀘스트 하드코딩 (TypeScript 객체)
- 채점 API — 컨테이너 안에서 조건 확인 후 성공/실패 반환

```typescript
// 채점 예시: /tmp/hello 디렉토리 존재 여부 확인
async function gradeQuest(container: Container, questId: string) {
  const exec = await container.exec({ Cmd: ['test', '-d', '/tmp/hello'] })
  const result = await exec.start({})
  return result.StatusCode === 0
}
```

### 퀘스트 예시 2개
1. 리눅스 기초 — `/tmp/hello` 디렉토리 만들기
2. 파일 조작 — 특정 파일에 특정 내용 쓰기

### 검증
- 퀘스트 읽고 터미널에서 풀고 채점까지 한 사이클 완료되면 Phase 2 완료

---

## Phase 3 — 로컬에서 직접 써보기 ✅ 완료

목표: 실제로 써보면서 UX 문제 발견 및 수정

- 채점 중 로딩 표시
- 마지막 퀘스트 완료 후 안내 메시지
- 터미널 폰트/스타일 개선

---

## Phase 4 — MariaDB 연동 + 퀘스트 세트 구조

목표: 퀘스트를 DB에서 관리하는 인프라 교체. 기존 2개 퀘스트를 DB로 마이그레이션하고 세트 선택 화면 추가. 기능은 지금과 동일하게 동작하는 것이 목표.

### DB 스키마

```
quest_set — 퀘스트 세트 (id, title, description)
quest     — 개별 퀘스트 (id, quest_set_id, title, description, hint, grade_cmd)
```

### 백엔드

- MariaDB 연결 (mysql2 드라이버)
- `/quest-sets` API — 세트 목록
- `/quest-sets/:id/quests` API — 세트별 퀘스트 목록
- `/grade` API — 기존 유지, containerId + questId 방식
- 기존 하드코딩 퀘스트 2개 → DB seed로 이전

### 프론트

- 세트 선택 화면 추가 (세트 목록 → 세트 선택 → 퀘스트 진행)
- 기존 퀘스트 진행 화면 재활용

### 검증

- 세트 선택 → 퀘스트 진행 → 채점 한 사이클 완료
- 퀘스트 추가 시 코드 수정 없이 DB에만 추가하면 반영됨

---

## Phase 5 — 퀘스트 콘텐츠 확장

목표: DB 구조 위에 리눅스 기초 세트, Docker 기초 세트 퀘스트를 충실하게 작성. 팀원이 실제로 써보고 "쓸 만하다"는 느낌을 받을 수 있는 수준.

### 퀘스트 세트

1. **리눅스 기초 세트** — 파일 조작, 권한 설정, 프로세스 관리, 네트워크 확인
2. **Docker 기초 세트** — 컨테이너 실행/중지/삭제, 이미지 관리, 로그 확인

### 작업 기준

- 퀘스트마다 지문/힌트/채점이 완성된 것만 추가
- 난이도 순서로 배치 (쉬운 것부터)
- 채점은 기존 방식 (명령어 실행 결과 확인) 유지

### 검증

- 리눅스 세트 전체 퀘스트를 처음부터 끝까지 풀 수 있음
- Docker 세트 전체 퀘스트를 처음부터 끝까지 풀 수 있음
- 지문만 보고 힌트 없이 풀 수 있는 수준인지 확인

---

## Phase 6 — k8s 기초 실습 세트

목표: kubectl 실습 환경 제공. k3d로 로컬 클러스터를 띄우고, kubectl이 설치된 컨테이너를 터미널로 연결해 k8s 기초 퀘스트를 풀 수 있게 한다.

### 샌드박스 구조

```
[k3d 로컬 클러스터]  ← kubeconfig 마운트
       ↑
[etude-k8s 컨테이너]  ← 사용자 터미널 접속
  kubectl get pods → 클러스터에 실제 요청
```

- k3d로 로컬에 단일 노드 k3s 클러스터 구동 (Docker 위, ~500MB)
- `etude-k8s` 이미지: kubectl + kubeconfig만 포함 (경량)
- kubeconfig는 컨테이너 시작 시 볼륨 마운트로 주입
- 사용자별 namespace 격리 (user-{id} 형식)

### sandbox 테이블 추가

```
sandbox_type: k8s
image: etude-k8s
binds: ["{kubeconfig_path}:/root/.kube/config:ro"]
```

### 퀘스트 세트

6. **k8s 기초 세트** — pod/deployment/service 조작, kubectl 기본 명령어

### 검증

- k3d 클러스터 기동 확인
- etude-k8s 컨테이너에서 kubectl get nodes 실행
- 퀘스트 채점 (grade_cmd: kubectl 명령어 결과 확인)

---

## Phase 7 — 사용자 인증 + 진행 추적

목표: 누가 어떤 퀘스트를 완료했는지 추적, 팀원/팀장이 현황 확인 가능

### DB 스키마 추가

```
user            — 사용자 (이름, 이메일, 역할)
quest_progress  — 퀘스트 완료 이력 (user_id, quest_id, completed_at)
```

### 기능

- 로그인 (사내 이메일 기반, JWT)
- 퀘스트 완료 시 progress 기록
- 대시보드 — 내 완료 현황, 세트별 진행률
- 팀장 뷰 — 팀원 전체 완료 현황

### 검증

- 로그인 → 퀘스트 풀기 → 완료 기록 → 대시보드에서 확인

---

## Phase 8 — 현장 실무 세트

목표: k8s 환경 위에 현장 밀착형 퀘스트 세트 추가

### 퀘스트 세트

- **배포 작업** — deployment 롤링 업데이트, 롤백
- **이관 작업** — configmap/secret 관리
- **트러블슈팅** — 502, OOM, CrashLoopBackOff 등

### 검증

- 지문만 보고 퀘스트를 처음부터 끝까지 풀 수 있음

---

## 향후 (시점 미정)

- **퀘스트 관리 UI** — 어드민에서 퀘스트/세트 CRUD (채점 로직 작성 방식 확정 후)
- **AI 퀘스트 생성** — 실무자 입력 → Claude API → 퀘스트 자동 변환 (플랫폼 안정화 후)
- **UI 개선** — KodeKloud 레이아웃 참고 (상단 헤더바, 탭 구조, 진행 표시, 하단 네비게이션)
- **로딩 화면** — 세트 선택 후 컨테이너 준비 중 로딩 표시 (containerId 수신 전까지). KodeKloud "Lab provisioned. Getting ready..." 스타일 참고

---

## 프로젝트 구조

```
etude/
├── frontend/                   # React + TypeScript
│   ├── src/
│   │   ├── components/
│   │   │   ├── Terminal.tsx    # xterm.js 터미널
│   │   │   └── QuestPanel.tsx  # 퀘스트 지문 + 채점 버튼
│   │   └── App.tsx
│   └── package.json
│
└── backend/                    # Fastify + TypeScript
    ├── src/
    │   ├── index.ts            # Fastify 앱 진입점
    │   ├── terminal.ts         # WebSocket + Docker 제어
    │   └── quest.ts            # 퀘스트 데이터 + 채점 로직
    ├── package.json
    └── tsconfig.json
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
- @types/dockerode — TypeScript 타입 지원

---

## 미결 사항

- [ ] DB 스키마 확정 — quest_set/quest/user/quest_progress 관계 설계
- [ ] 채점 로직 DB 저장 방식 — 채점 함수는 코드에 있고 quest_id로 매핑, 또는 채점 명령어를 DB에 저장
- [ ] k8s 샌드박스 격리 수준 — namespace 공유 vs 클러스터 per user (Phase 7 명세 시점에 확정)
- [ ] 로그인 방식 — 사내 이메일 자체 발급 vs SSO 연동 (Phase 6 명세 시점에 확정)
- [ ] Docker 이미지 — 현재 ubuntu 기본 이미지 사용 중, Docker 세트용 커스텀 이미지 필요 여부
- [ ] 테스트 코드 도입 시점 — Phase 6 (인증) 전후가 적기. DB + API 구조가 확정되고 인증이 붙으면 검증 필요성이 높아짐. Fastify `inject()` + vitest 조합 사용 예정
