# 트러블슈팅 — 배포 직후 backend가 한 번 죽었다가 다시 뜬다 (2026-10-29)

## 증상

배포(`gh workflow run deploy.yml`) 직후 `docker logs etude-backend`를 보면 이런 오류가 맨 앞에 있고, 그 뒤에 `Server listening ...`이 다시 나온다.

```
Error: Command failed: vcluster create pool-xxxxxxxx --connect=false ...
fatal fork/exec /root/.vcluster/bin/helm: permission denied
Node.js v20...
```

사용자 눈에는 배포 직후 몇 초간 서비스가 응답하지 않을 수 있다. 시간이 지나면 저절로 정상이 된다 (`restart: unless-stopped` 때문).

## 원인 (코드상 확인됨, 서버에서 재현은 하지 않음)

1. 배포할 때마다 backend 컨테이너가 **새로 만들어진다.** 새 컨테이너에는 `helm`이 없다.
2. backend는 시작할 때 격리용 가상 클러스터(vcluster)를 **2개 미리 만들어 둔다** (pool). 이 두 개를 **동시에** 만든다.
3. `vcluster` 명령은 처음 실행될 때 `helm`을 내려받아 `/root/.vcluster/bin/helm`에 저장한다. 두 명령이 동시에 같은 파일을 내려받으면, 한쪽이 **아직 실행 권한이 붙지 않은 파일을 실행하려다** `permission denied`로 실패한다.
4. 기존 코드는 pool 생성이 하나라도 실패하면 오류를 던졌고, 기동 코드가 이를 처리하지 않아 **프로세스가 종료**됐다.
5. 컨테이너가 다시 시작되면 먼저 내려받은 `helm`이 컨테이너 안에 남아 있어서 이번에는 성공한다.

## 해결

[vcluster-pool.ts](../../backend/src/services/vcluster-pool.ts)의 `initPool`을 바꿨다.

- 하나가 실패해도 프로세스를 **죽이지 않는다.** 실패는 로그로 남긴다.
- 실패한 만큼은 **순차로 한 번 더** 시도한다. 그때는 `helm`이 이미 내려받아져 있어 성공한다.
- 그래도 안 되면 pool이 비어 있는 채로 기동한다. 사용자가 `k8s-isolated` 세트를 열면 그 자리에서 만든다(`assignFromPool`의 기존 대체 경로).

## 확인 방법

배포 후 다음을 본다.

```bash
docker logs etude-backend 2>&1 | grep -E "vcluster|permission denied|Server listening"
```

- 정상: `[vcluster] pool 생성 실패, 순차로 다시 시도합니다`가 한 번 보일 수는 있지만, 그 뒤에 `Server listening`이 **같은 프로세스에서** 이어지고 컨테이너가 재시작되지 않는다 (`docker ps`의 `Up` 시간이 배포 시각과 같다).
- `kubectl get ns | grep vcluster-pool`에 pool 네임스페이스가 2개 있으면 pool이 채워진 것이다.

## 남은 일

- 이 수정은 단위 테스트(`vcluster-pool-init.test.ts`)로만 확인했고, **실제 서버 배포에서의 확인은 아직 안 했다.** 다음 배포 때 위 로그로 확인한다.
- 근본적으로는 helm을 이미지에 미리 넣거나 `/root/.vcluster`를 볼륨으로 유지하면 첫 기동의 내려받기 자체가 없어진다. 지금은 실패해도 서비스에 영향이 없게 만드는 데 그쳤다.
