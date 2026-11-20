# 명세: Docker Hub 한도(429) 대책 — 이미지 미러

## 문제

Docker Hub 는 **같은 IP 에서 로그인 없이 받는 횟수를 제한**한다 (6시간에 100회 안팎). 서버의 모든 학습자와 검증 도구가 같은 IP 로 나가고,
실습 세션은 만들 때마다 이미지를 새로 받는다.

- 도커 실습(`docker:dind`): 세션마다 안쪽 도커가 `alpine`·`nginx` 등을 Hub 에서 받는다.
- k8s 실습(k3d 클러스터): 파드가 `nginx`·`busybox` 를 받는다. 태그가 없거나 `latest` 면 매번 확인(`imagePullPolicy: Always`)해서 더 잘 걸린다.
- 한도를 넘으면 `429 Too Many Requests` → 도커는 `docker run` 실패, k8s 는 `ErrImagePull`/`ImagePullBackOff`. **학습자에게는 "정답인데 안 되는" 실습**으로 보인다.
- 2026-11-19 `verify:quests` 전수 검증에서 같은 현상으로 가짜 실패가 대량으로 났다.

## 해법

이미지를 Hub 에서 직접 받지 않고 **서버 안의 미러 레지스트리(`etude-mirror`, `registry:2` 풀스루 캐시)에서 받는다.**
미러는 처음 한 번만 Hub 에서 받아 볼륨에 저장하고 이후에는 저장본을 준다. 한도에 걸리는 것은 "처음 한 번"뿐이다.

```
dind 안쪽 도커 ──(--registry-mirror)──┐
k3d 노드(containerd) ─(registries.yaml)─┼─► etude-mirror ──(처음 한 번만)──► Docker Hub
                                        │     (볼륨에 캐시)
배포 때 미리 받기(mirror-warm.sh) ──────┘
```

| 구성요소 | 위치 | 하는 일 |
|---|---|---|
| 미러 서비스 | `deploy/docker-compose.prod.yml` `mirror` | 풀스루 캐시. `127.0.0.1:5000` 과 docker0 게이트웨이(`MIRROR_BIND_IP`, 기본 `172.17.0.1`)에만 열고 외부에는 열지 않는다. k3d 네트워크에도 붙는다 |
| dind 연결 | `dindMirrorCmd()` (`sandbox-runtime.ts`), 환경변수 `DOCKER_REGISTRY_MIRROR` | dind 컨테이너 `Cmd` 에 `--registry-mirror`·`--insecure-registry` 를 준다. 변수가 없으면 지금처럼 Hub 를 직접 쓴다. 앱(`terminal.ts`)과 검증 러너(`docker-sandbox.ts`)가 같은 함수를 쓴다 |
| k3d 연결 | `scripts/k3d-mirror.sh` | 노드의 `/etc/rancher/k3s/registries.yaml` 에 `docker.io` 미러를 쓴다. 바뀔 때만 노드를 재시작 (여러 번 실행해도 안전) |
| 미리 받기 | `scripts/mirror-warm.sh`, `backend/docker/quest-images.txt` | 퀘스트가 쓰는 이미지를 배포 때 미러로 받아 둔다. 학습자가 처음 쓸 때 걸리지 않게 한다 |
| 배포 | `.github/workflows/deploy.yml` | 배포 끝에 위 두 스크립트를 실행 (실패해도 배포는 막지 않는다) |

## 설정

- `DOCKER_REGISTRY_MIRROR`: compose 가 backend 에 `http://${MIRROR_BIND_IP:-172.17.0.1}:5000` 로 넣는다. 로컬 검증은 셸에서 지정한다.
- `MIRROR_BIND_IP`: 서버의 docker0 게이트웨이가 `172.17.0.1` 이 아니면 `deploy/.env` 에 지정한다 (`docker network inspect bridge -f '{{(index .IPAM.Config 0).Gateway}}'`).
- 선택: Hub 계정으로 받으려면 `deploy/.env` 에 `REGISTRY_PROXY_USERNAME` / `REGISTRY_PROXY_PASSWORD`(액세스 토큰) 를 둔다. 로그인하면 한도가 늘고 캐시를 채울 때 덜 걸린다. 토큰은 저장소에 두지 않는다.
- 새 퀘스트가 새 이미지를 쓰면 `backend/docker/quest-images.txt` 에 한 줄 추가한다.

## 한계와 주의

- 미러에 없는 이미지를 **처음** 받을 때는 Hub 를 거친다. 그때 한도가 이미 소진돼 있으면 실패한다 (미리 받기·계정 로그인으로 줄인다).
- 일부러 틀린 이미지(`nginx:1.99.99` 등)를 쓰는 퀘스트는 미러에도 없어 Hub 로 가서 `404`(없음)가 된다. 한도와 무관하게 의도대로 실패한다.
- 미러는 인증 없는 내부용이다. 외부에 포트를 열지 않는다.
- 미러 볼륨은 이미지 크기만큼 커진다. 디스크 정리는 `guide_server_operations.md` 의 "디스크 정리" 참고.
- 익명 볼륨 누수와는 별개 문제다 (컨테이너를 지울 때 `v: true`).

## 미검증 (2026-11-19 기준)

- 운영 서버에서의 실제 동작 (docker0 게이트웨이 주소, 방화벽, compose 버전).
- 풀스루 캐시가 Hub 에서 새 이미지를 받아 채우는 경로: 로컬은 이미 한도가 소진돼 있어 시드한 일반 레지스트리로 대신 검증했다.
