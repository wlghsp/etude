# Phase 8 명세 — 서버 배포 (OCI Free Tier)

## 목표

OCI(Oracle Cloud Infrastructure) Always Free VM에 Etude를 배포한다.
팀원이 브라우저로 접속해서 퀘스트를 풀 수 있는 상태를 만드는 것이 목표다.

현재 Phase (Phase 6 완료) 기준으로 인증 없이 배포한다.
Phase 7 (인증) 완료 후 동일 서버에 재배포한다.

---

## 인프라 구성

### OCI Always Free 리소스

| 리소스 | 사양 | 비고 |
|--------|------|------|
| Compute VM | ARM Ampere A1 — 4 OCPU / 24GB RAM | Always Free |
| Block Volume | 200GB | Always Free |
| 아웃바운드 트래픽 | 10TB/월 | Always Free |

### VM 구성

| 항목 | 값 |
|------|-----|
| OS | Ubuntu 22.04 (ARM64) |
| 접근 | SSH 키 인증 |
| 공인 IP | OCI Reserved Public IP (고정) |

---

## 아키텍처

```
브라우저
  └─ HTTP :80 ──▶ nginx (Docker)
                    ├─ / ──────────▶ frontend (정적 빌드)
                    └─ /api, /ws ──▶ backend (Fastify :3001)

backend
  ├─ MariaDB :3306 (Docker)
  ├─ Docker socket (dockerode로 샌드박스 컨테이너 제어)
  └─ k3d 네트워크 (k8s 퀘스트용)
```

### 포트

| 포트 | 용도 | 외부 노출 |
|------|------|-----------|
| 80 | nginx (HTTP) | ✅ |
| 22 | SSH | ✅ (관리용) |
| 3001 | Fastify | ❌ (nginx 내부 프록시) |
| 3306 | MariaDB | ❌ (내부 전용) |

도메인 미확보 상태이므로 공인 IP로 접근한다.
HTTPS는 도메인 확보 후 Let's Encrypt로 추가한다.

---

## 컴포넌트 구성

### Docker Compose (프로덕션)

`deploy/docker-compose.prod.yml`

| 서비스 | 이미지 | 역할 |
|--------|--------|------|
| db | mariadb:11 | 데이터베이스 |
| backend | 로컬 빌드 | Fastify API + WebSocket |
| nginx | nginx:alpine | 리버스 프록시 + 프론트 서빙 |

### 프론트엔드

Vite로 정적 빌드 후 nginx가 서빙한다.
`frontend/dist/`를 nginx 컨테이너에 볼륨 마운트한다.

---

## 환경변수 (서버)

`backend/.env.prod` — 서버에만 존재, 깃에 올리지 않음

```
DB_HOST=db
DB_PORT=3306
DB_USER=etude
DB_PASSWORD={비밀번호}
DB_NAME=etude
KUBECONFIG_PATH=/root/.kube/config-etude
K3D_NETWORK=k3d-etude
```

---

## 사전 요구사항

서버 기동 전 VM에 설치되어 있어야 하는 것:

| 항목 | 설치 방법 |
|------|-----------|
| Docker + Docker Compose | `setup.sh` |
| k3d | `setup.sh` |
| kubectl | `setup.sh` |
| k3d 클러스터 (`etude`) | 수동 1회 |
| config-etude (kubeconfig) | 수동 1회 |
| etude-k8s 이미지 | 수동 빌드 1회 |
| etude-ssh 이미지 | 수동 빌드 1회 |

---

## Terraform 범위

Terraform이 관리하는 리소스:

- VCN (Virtual Cloud Network)
- Public Subnet
- Internet Gateway
- Security List (포트 22, 80 오픈)
- Reserved Public IP
- ARM Compute Instance (Ubuntu 22.04)

Terraform이 관리하지 않는 것:

- 앱 설치 및 실행 (`setup.sh` + 수동)
- 환경변수 파일
- k3d 클러스터 설정

---

## 배포 절차 (최초)

```
1. terraform apply          → VM + 네트워크 생성
2. ssh + setup.sh 실행      → Docker, k3d, kubectl 설치
3. k3d 클러스터 생성         → k3d cluster create etude
4. kubeconfig 생성          → config-etude 생성
5. 이미지 빌드              → etude-k8s, etude-ssh
6. 소스 복사                → git clone (private repo → SSH 키 설정)
7. 환경변수 작성            → backend/.env.prod
8. 프론트 빌드              → npm run build
9. docker-compose up        → 서비스 기동
10. 브라우저 접속 확인      → http://{공인IP}
```

## 재배포 절차 (업데이트)

```
1. git pull
2. npm run build (frontend)
3. docker-compose -f deploy/docker-compose.prod.yml up -d --build backend
```

---

## 검증 기준

- [ ] `http://{공인IP}` 로 세트 선택 화면 접속 가능
- [ ] linux 퀘스트 세트 — 터미널 연결 + 채점 동작
- [ ] docker 퀘스트 세트 — DinD 터미널 연결 + 채점 동작
- [ ] k8s 퀘스트 세트 — kubectl 동작 + namespace 격리 확인
- [ ] 서버 재시작 후에도 서비스 자동 복구 (Docker restart policy)
