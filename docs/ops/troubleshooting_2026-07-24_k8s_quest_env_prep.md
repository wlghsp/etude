# 트러블슈팅 기록 — k8s 퀘스트 "환경 준비 중" 멈춤 (2026-07-24)

## 증상

k8s 기초(세트 6) 퀘스트에 들어가면 터미널이 "환경 준비 중..."에서 멈추고 넘어가지 않음. 다른 sandbox 타입(linux 등)은 정상.

두 가지 원인이 겹쳐 있었다. 순서대로 확인하며 해결.

---

## 원인 1 — `etude-k8s` 이미지가 서버에 없음

**확인**: `docker logs etude-backend --tail 100`에서 아래 에러 확인.

```
terminal error: Error: (HTTP code 404) no such container - No such image: etude-k8s:latest
```

`docker images | grep etude`로 서버에 있는 이미지를 보니 `etude-backend`, `etude-linux`만 있고 `etude-k8s`가 없었다. `01_sandbox.sql`의 `k8s`, `k8s-isolated` sandbox 타입이 참조하는 이미지인데, Phase 6d에서 `etude-linux` 커스텀 이미지를 도입할 때 `etude-k8s`는 서버에 빌드/전달되지 않은 상태였던 것으로 보인다.

`backend/docker/Dockerfile.k8s`는 레포에 존재했다 (정의는 있었으나 서버 빌드 누락).

**해결**: 서버 아키텍처(`uname -m` → `aarch64`) 확인 후, `Dockerfile.k8s`가 arm64 kubectl을 받도록 되어 있어 그대로 빌드.

```bash
cd ~/etude/backend
docker build -f docker/Dockerfile.k8s -t etude-k8s:latest .
```

> 서버가 x86_64였다면 `Dockerfile.k8s`의 `linux/arm64/kubectl` 부분을 `linux/amd64/kubectl`로 고쳐야 했다.

---

## 원인 2 — `KUBECONFIG_PATH`가 재기동 전 값이라 컨테이너에 반영 안 됨

이미지를 빌드한 뒤에도 새로 생성된 실습 컨테이너 안에서 `kubectl get nodes`가 아래 에러를 냈다.

```
error: error loading config file "/root/.kube/config": read /root/.kube/config: is a directory
```

**원인 분석**:

- `handleK8sTerminal`(`backend/src/services/terminal.ts`)이 새 실습 컨테이너를 만들 때 쓰는 바인드 마운트 소스는 `getSandboxConfig()`(`backend/src/services/sandbox.ts`)가 `process.env.KUBECONFIG_PATH`를 읽어서 조립한다.
- `etude-backend`는 `/var/run/docker.sock`을 호스트에서 직접 마운트받아 호스트 dockerd를 제어한다(dind 아님). 따라서 이 바인드 마운트 소스 경로는 **호스트 파일시스템 기준 경로**여야 한다.
- 그런데 당시 실행 중이던 `etude-backend` 컨테이너의 `KUBECONFIG_PATH`가 `/root/.kube/config-etude`(컨테이너 내부 경로)로 남아 있었다. `backend/.env.prod`는 이미 올바른 값(`/home/ubuntu/.kube/config-etude`, 호스트 경로)으로 수정되어 있었지만, **`etude-backend` 컨테이너가 그 값을 반영해 재기동되지 않은 상태**였다.
- 호스트 dockerd 입장에서 `/root/.kube/config-etude`라는 경로는 존재하지 않았고(권한도 root 소유라 `ubuntu` 유저가 접근 불가), Docker는 바인드 마운트 소스가 없으면 자동으로 디렉토리를 생성해버리는 동작을 한다. 그 결과 새 컨테이너 안 `/root/.kube/config`가 파일이 아니라 빈 디렉토리로 마운트됐다.

**해결**: `backend/.env.prod`의 `KUBECONFIG_PATH=/home/ubuntu/.kube/config-etude` 값을 반영하도록 `etude-backend`를 재빌드/재기동.

```bash
cd ~/etude
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

재기동 후 `docker exec etude-backend printenv KUBECONFIG_PATH`로 값이 갱신됐는지 확인하고, 다시 k8s 퀘스트에 들어가 정상 동작 확인.

---

## 배운 것

- **`.env.prod` 파일을 고쳐도 실행 중인 컨테이너에는 즉시 반영되지 않는다.** 컨테이너를 `--build`로 재기동해야 새 환경변수 값이 들어간다. `printenv`로 실제 반영 여부를 확인하는 습관이 필요하다.
- **dockerode가 호스트 dockerd를 직접 쓰는 구조(`/var/run/docker.sock` 마운트)에서는, 바인드 마운트 경로가 "백엔드 컨테이너 관점 경로"가 아니라 "호스트 관점 경로"여야 한다.** 이 둘을 헷갈리기 쉽다 — `KUBECONFIG_PATH` 같은 값을 설정할 때 어느 쪽 기준인지 주석으로 명시해두면 좋다.
- **`sandbox` 테이블이 참조하는 이미지가 서버에 실제로 존재하는지는 별도로 확인해야 한다.** [troubleshooting_2026-07-03_missing_sandbox_images.md](troubleshooting_2026-07-03_missing_sandbox_images.md)에서도 같은 유형의 문제(사전 pull 누락)가 있었다. 새 sandbox 타입/이미지가 추가되거나 이미지 체계가 바뀔 때는 서버의 `docker images` 목록을 함께 점검하는 절차가 필요해 보인다.
