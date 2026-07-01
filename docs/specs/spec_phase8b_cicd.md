# Phase 8b 명세 — CI/CD (GitHub Actions)

## 목표

Phase 8(서버 배포) 이후 반복되는 재배포 절차(`git pull` → 프론트 빌드 → `docker compose up -d --build`)를 GitHub Actions로 자동화한다.
서버에 직접 SSH 접속하지 않고 GitHub Actions 화면에서 배포를 트리거할 수 있게 만드는 것이 목표다.

---

## 트리거 방식

수동 트리거(`workflow_dispatch`)만 사용한다. master push에 의한 자동 배포는 하지 않는다.

**이유**: 소수 인원이 쓰는 사내 트레이닝 플랫폼이고 스테이징 환경이 없다. master push가 곧바로 프로덕션 배포로 이어지면 실수로 올라간 커밋이나 미완성 작업이 바로 노출될 위험이 있다. GitHub Actions 탭에서 사람이 "Run workflow"를 눌러야 배포가 시작된다.

---

## 배포 절차 (자동화 대상)

기존 [spec_phase8_deploy.md](spec_phase8_deploy.md)의 "재배포 절차"를 그대로 옮긴다.

```
1. git pull
2. npm run build (frontend)
3. docker compose -f deploy/docker-compose.prod.yml up -d --build backend
```

---

## 구성 요소

### GitHub Secrets

| Secret | 용도 |
|--------|------|
| `SSH_PRIVATE_KEY` | 서버 접속용 개인키 (`~/.ssh/etude_oci`) |
| `SSH_HOST` | OCI VM 공인 IP |
| `SSH_USER` | 접속 계정 (`ubuntu`) |

### 워크플로우 파일

`.github/workflows/deploy.yml` — `workflow_dispatch`로만 트리거, SSH로 서버 접속해 재배포 절차 실행.

---

## 범위 밖

- master push 자동 배포 (추후 필요 시 트리거만 변경하면 됨)
- 빌드 실패 시 자동 롤백
- 스테이징 환경 / 배포 전 테스트 파이프라인
- self-hosted runner (GitHub Actions 표준 러너 사용)

---

## 검증 기준

- [ ] GitHub Actions 탭에서 "Run workflow" 클릭 시 배포 시작
- [ ] 배포 완료 후 `http://{공인IP}` 정상 접속
- [ ] SSH 개인키가 GitHub Secrets에만 존재하고 레포에 커밋되지 않음
- [ ] 배포 실패 시 Actions 로그에서 실패 단계 확인 가능
