# Phase 8b 구현 가이드 — CI/CD (GitHub Actions)

명세: [specs/spec_phase8b_cicd.md](../specs/spec_phase8b_cicd.md)

전제: [Phase 8 서버 배포](guide_phase8_deploy.md)가 완료되어 서버가 이미 떠 있는 상태.

---

## 전체 흐름

```
Step 1. GitHub Secrets 등록 (SSH 키, 호스트, 계정)
Step 2. .github/workflows/deploy.yml 작성
Step 3. Actions 탭에서 수동 실행 + 확인
```

---

## Step 1. GitHub Secrets 등록

리포지토리 → Settings → Secrets and variables → Actions → New repository secret

| Name | Value |
|------|-------|
| `SSH_PRIVATE_KEY` | `~/.ssh/etude_oci` 파일 내용 전체 (로컬에서 `cat ~/.ssh/etude_oci`로 확인) |
| `SSH_HOST` | OCI VM 공인 IP |
| `SSH_USER` | `ubuntu` |

> `SSH_PRIVATE_KEY`는 Phase 8에서 VM 접속용으로 만든 키다. 서버의 `~/.ssh/etude_oci.pub`가 이미 authorized_keys에 등록되어 있으므로 별도로 서버에 키를 추가할 필요는 없다.

---

## Step 2. 워크플로우 파일 작성

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SSH_HOST }}
          username: ${{ secrets.SSH_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd ~/etude
            git pull
            cd frontend
            npm ci
            npm run build
            cd ..
            docker compose -f deploy/docker-compose.prod.yml up -d --build backend
```

`workflow_dispatch`만 트리거로 두었으므로 push로는 실행되지 않는다. GitHub Actions 탭에서 수동으로 눌러야 배포가 시작된다.

---

## Step 3. 실행 + 확인

1. 리포지토리 → Actions 탭 → "Deploy" 워크플로우 선택
2. "Run workflow" 버튼 클릭 → 브랜치 선택(보통 `master`) → 실행
3. 로그에서 각 단계(git pull / npm build / docker compose) 성공 여부 확인
4. `http://{공인IP}` 접속해서 반영 확인

### 실패 시 확인 사항

| 증상 | 원인 후보 |
|------|-----------|
| SSH 연결 실패 | `SSH_HOST`/`SSH_USER` 오타, VM의 22번 포트 보안 규칙 |
| `Permission denied (publickey)` | `SSH_PRIVATE_KEY` 값이 잘못 복사됨 (개행 누락 등) |
| `git pull` 실패 | 서버의 deploy key 만료 또는 로컬 변경사항과 충돌 |
| `npm run build` 실패 | 프론트 코드 자체의 타입 에러 — 로컬에서 먼저 `npm run build`로 재현 |
| `docker compose` 실패 | `backend/.env.prod` 누락, k3d 클러스터 미기동 등 [guide_phase8_deploy.md](guide_phase8_deploy.md)의 사전 요구사항 확인 |

---

## 주의사항

- `SSH_PRIVATE_KEY`는 GitHub Secrets에만 존재해야 한다. 절대 레포에 커밋하지 않는다.
- master push 자동 배포로 바꾸고 싶으면 `on:` 블록에 `push: branches: [master]`를 추가하면 된다 — 워크플로우 나머지는 그대로 유지.
