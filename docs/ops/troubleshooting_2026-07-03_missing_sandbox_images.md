# 트러블슈팅 기록 — 배포 후 화면 미반영 + 터미널 연결 실패 (2026-07-03)

## 증상 1 — GitHub Actions는 성공했는데 화면에 새 기능이 안 보임

Phase 7i(비밀번호 변경) 배포 후 GitHub Actions에서 "Run workflow"가 녹색 체크로 성공했는데도, 브라우저 화면에 새로 만든 "비밀번호 변경" 버튼이 안 보임.

**원인**: `Admin.tsx`가 `SideNav`에 `onChangePassword` prop을 전달하지 않아 TypeScript 타입 에러로 `npm run build`가 실패하고 있었다. 그런데 배포 스크립트에 `set -e`가 없어서, 빌드 실패를 무시하고 다음 줄(`docker compose up`)이 그대로 실행됐다. `docker compose up`은 **어제 빌드된 `dist/`**를 그대로 nginx에 마운트했고, 이 마지막 단계만 성공하면 GitHub Actions 전체가 "성공"으로 표시됐다.

**확인 방법**: 서버에서 `ls -la dist/assets/`로 파일 수정 시각을 보니 어제 시각 그대로였음. GitHub Actions 로그(`gh run view {run-id} --log`)를 다시 보니 `npm run build` 단계에 타입 에러가 그대로 찍혀 있었다.

**해결**:
1. `Admin.tsx`에 누락된 `onChangePassword` prop 배선 추가
2. 배포 스크립트(`.github/workflows/deploy.yml`)에 `set -e` 추가 — 앞으로 빌드가 실패하면 워크플로우 자체가 빨간 X로 실패 표시되도록

---

## 증상 2 — 화면은 고쳐졌는데 터미널 연결이 "환경 준비 중"에서 멈춤

빌드 문제를 해결하고 다시 배포한 뒤, 이번엔 리눅스 퀘스트의 터미널 연결이 "환경 준비 중..."에서 진행되지 않음.

**원인**: backend 로그에서 아래 에러 확인.

```
terminal error: Error: (HTTP code 404) no such container - No such image: ubuntu:latest
```

`linux` sandbox 타입이 쓰는 `ubuntu:latest` 이미지가 서버에 없었다. `infra/scripts/setup.sh`는 k3d 이미지(`rancher/k3s`, `rancher/k3d-proxy`)와 vcluster 이미지(`ghcr.io/loft-sh/vcluster-pro`)는 미리 pull하도록 되어 있었지만, `backend/db/01_sandbox.sql`이 실제로 참조하는 외부 이미지(`ubuntu`, `docker:dind`)는 어디에도 사전 pull 목록에 없었다.

Docker는 컨테이너를 처음 만들 때 이미지가 로컬에 없으면 자동으로 pull을 시도하는 게 보통인데, 이번엔 그 자동 pull조차 실패한 것으로 보아 — 정확한 원인(네트워크, Docker 데몬 설정 등)까지는 추적하지 않고, 애초에 사전 pull 목록에 없었다는 근본 원인만 해결.

**해결**: `setup.sh`와 `guide_phase8_deploy.md`에 `docker pull ubuntu:latest`, `docker pull docker:dind` 추가.

```bash
docker pull ubuntu:latest
docker pull docker:dind
```

서버에서 즉시 실행해서 임시로 해결하고, 다음 서버 재구축 시 `setup.sh`가 자동으로 처리하도록 스크립트/가이드에 반영.

---

## 배운 것

- **CI가 "성공"이라고 보고해도, 그 안의 각 단계가 실제로 성공했는지는 로그를 봐야 안다.** 특히 여러 명령을 셸 스크립트로 이어 붙인 배포 파이프라인은 `set -e` 없이는 중간 실패가 조용히 넘어갈 수 있다.
- **`sandbox` 테이블이 참조하는 이미지 목록과 서버의 사전 pull 목록은 별개로 관리되고 있었다** — 새 sandbox 타입이 추가될 때마다 `setup.sh`도 함께 업데이트해야 한다는 점을 놓치기 쉽다. `01_sandbox.sql`을 수정할 때는 `setup.sh`의 사전 pull 목록도 함께 점검하는 습관이 필요하다.
