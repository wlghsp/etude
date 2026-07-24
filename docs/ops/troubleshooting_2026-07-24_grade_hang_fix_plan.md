# 수정 방향 — 채점(execCheck) 무한 대기 문제

## 증상

k8s 기초 세트 14번("Deployment 롤백하기") 퀘스트에서 "채점하기"를 눌러도 정답/오답 응답이 오지 않고 그대로 멈춰 있음.

## 원인

`backend/src/services/quest.ts`의 `execCheck` 함수에 타임아웃이 없다.

```ts
async function execCheck(container: Docker.Container, cmd: string[]): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    await new Promise((r) => setTimeout(r, 100))
  }
}
```

`grade_cmd`(컨테이너 안에서 실행되는 채점 명령)가 어떤 이유로든 끝나지 않으면 이 `while(true)` 루프가 영원히 돌고, `/grade` API 요청도 응답을 못 받아 프론트는 무한 로딩(=무반응)처럼 보인다.

## 수정 방향

`execCheck`에 타임아웃을 추가해서, 일정 시간 안에 안 끝나면 오답(`false`)으로 처리한다.

```ts
async function execCheck(container: Docker.Container, cmd: string[], timeoutMs = 15000): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  const start = Date.now()
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    if (Date.now() - start > timeoutMs) return false
    await new Promise((r) => setTimeout(r, 100))
  }
}
```

- `timeoutMs` 기본값 15초 — 대부분의 `kubectl` 조회/조작 명령은 이 안에 끝난다. 실제 grade_cmd들의 평소 응답 시간을 보고 조정 가능.
- 타임아웃 시 오답 처리되므로, 사용자는 "무한 로딩" 대신 "오답, 다시 시도"를 보게 된다.

## 남은 과제 — 14번이 왜 느려지거나 멈추는지는 별도 확인 필요

이 수정은 **증상(무한 대기로 응답 없음)을 없애는 안전장치**이지, 14번 grade_cmd(`kubectl rollout history deployment/my-app -n $NS | grep -q '2\|3'`)가 실제로 왜 느려지거나 멈추는지의 근본 원인을 밝히는 건 아니다.

타임아웃 적용 후에도 14번이 계속 "오답"으로만 뜬다면, 아래를 서버에서 직접 확인해 원인을 좁혀야 한다.

```bash
docker ps --filter "ancestor=etude-k8s" --format "table {{.ID}}\t{{.CreatedAt}}\t{{.Names}}"

# 문제의 세션 컨테이너 ID와 네임스페이스(quest-{ID앞8자리})로:
time docker exec <컨테이너ID> sh -c "kubectl rollout history deployment/my-app -n quest-<앞8자리>"
```

- 즉시 끝나고 리비전이 1개뿐이면 → 13번(이미지 업데이트)을 아직 안 거쳤을 가능성. grade_cmd 문제가 아니라 진행 순서 문제.
- 15초 넘게 멈추면 → `kubectl`이 API 서버 응답을 못 받는 것. 클러스터/네트워크 상태 확인 필요.
