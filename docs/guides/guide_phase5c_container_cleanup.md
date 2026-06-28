# 컨테이너 고아 처리 가이드

서버 재시작 또는 브라우저 강제 종료 시 실습 컨테이너가 stop/remove 되지 않고 남는 문제.
서버 시작 시 자동으로 정리하도록 구현한다.

---

## 판단 기준 — Docker Label

이미지 이름으로 판단하면 다른 용도로 쓰는 동명 컨테이너까지 삭제할 위험이 있다.
컨테이너 생성 시 `etude=sandbox` label을 붙이고, 정리 시 그 label로만 필터링한다.

---

## 구현

### 1. terminal.ts — 컨테이너 생성 시 label 추가

`handleDefaultTerminal`과 `handleDockerTerminal` 양쪽의 `createContainer` 호출에 추가:

```typescript
await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox' },
    // ... 나머지 옵션
})
```

### 2. index.ts — 서버 시작 시 label 기반 정리

`docker` 선언 직후, `fastify.register` 전에 추가:

```typescript
async function cleanupOrphanedContainers() {
    const containers = await docker.listContainers({
        all: true,
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
}

await cleanupOrphanedContainers()
```

---

## 검증

1. 브라우저에서 퀘스트 세트 진입 후 강제로 탭 닫기
2. 백엔드 서버 재시작
3. `docker ps -a --filter label=etude=sandbox` — 컨테이너 없어야 성공
