# Etude

오케스트로 사내 현장 실습 트레이닝 플랫폼.

브라우저에서 터미널을 열고, 실제 환경과 동일한 샌드박스에서 퀘스트를 풀며 실습한다.

---

## 주요 기능

- **브라우저 터미널** — xterm.js + WebSocket으로 Docker/k8s 샌드박스에 직접 접속
- **퀘스트 채점** — bash 명령 실행 결과를 서버에서 자동 채점
- **진행 추적** — 세트별 완료율, 소요 시간, 힌트/풀이 사용 여부 기록
- **리더보드** — 팀원 전체 진행 현황 공개
- **다중 샌드박스** — 리눅스, Docker-in-Docker, k8s(k3d), SSH 환경 지원

## 퀘스트 세트

| 카테고리 | 세트 |
|----------|------|
| 리눅스 | 파일 탐색과 생성, 삭제·검색·권한, 프로세스와 시스템, 네트워크/파일 전송, 압축과 아카이브, Vim 기초, 현장 운영 |
| 도커 | Docker 기초, 이미지 빌드, 이미지 오프라인 반입 |
| k8s | k8s 기초, ConfigMap과 Secret, 스토리지와 네트워크, Helm 기초 |

---

## 스택

| 영역 | 기술 |
|------|------|
| 프론트엔드 | React + TypeScript (Vite) |
| 백엔드 | Fastify + TypeScript |
| 터미널 | xterm.js + WebSocket |
| 샌드박스 | Docker (dockerode), k3d |
| DB | MariaDB |
| 인증 | JWT + bcrypt |
| 배포 | OCI Free Tier + Docker Compose + nginx |

---

## 로컬 실행

### 사전 요구사항

- Node.js 20+
- Docker
- MariaDB

### 백엔드

```bash
cd backend
cp .env.example .env       # 환경변수 설정
cp db/04_users.sql.example db/04_users.sql  # 유저 시드 작성
npm install
npm run dev
```

### 프론트엔드

```bash
cd frontend
npm install
npm run dev
```

### DB 초기화

```bash
mysql -u root -p etude < backend/db/00_schema.sql
mysql -u root -p etude < backend/db/01_sandbox.sql
# ... 나머지 sql 파일 순서대로 실행
mysql -u root -p etude < backend/db/04_users.sql
```

---

## 환경변수

`backend/.env` (`.env.example` 참고):

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=etude
DB_PASSWORD=
DB_NAME=etude
JWT_SECRET=
KUBECONFIG_PATH=        # k8s 세트 사용 시
K3D_NETWORK=k3d-etude   # k8s 세트 사용 시
```

---

## 유저 관리

가입 화면 없음. 관리자가 API로 직접 생성.

```bash
curl -X POST http://localhost:3001/admin/users \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "홍길동", "email": "hong@example.com", "password": "임시비번"}'
```

---

## 문서

- [`docs/etude_dev_plan.md`](docs/etude_dev_plan.md) — 아키텍처 및 개발 계획
- [`docs/guides/`](docs/guides/) — Phase별 구현 가이드
- [`docs/specs/`](docs/specs/) — Phase별 명세
