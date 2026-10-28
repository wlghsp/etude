# 컨테이너 종료 시 정리 가이드

> **상태: 미구현**
> 아래 구현 내용은 아직 코드에 반영되지 않았다.
> `index.ts`에 `onClose` 훅과 SIGTERM/SIGINT 핸들러가 없는 상태.
> phase5c(label 추가)가 먼저 완료되어야 이 가이드의 label 기반 정리가 동작한다.

서버가 정상 종료될 때 실행 중인 샌드박스 컨테이너를 함께 제거한다.
시작 시 정리(phase5c)는 크래시 이후 찌꺼기를 잡고, 종료 시 정리는 정상 흐름에서 발생하는 컨테이너를 책임진다.

---

## 정리 시점 비교

| 시점 | 커버 범위 | 한계 |
|------|-----------|------|
| 서버 시작 시 (phase5c) | 크래시·강제 종료 후 남은 찌꺼기 | 정상 종료 직후는 잡지 않음 |
| 서버 종료 시 (이 가이드) | 정상 `Ctrl+C` / SIGTERM 종료 | 크래시로 죽으면 실행 안 됨 |

두 가지를 모두 구현해야 어떤 종료 상황에서도 컨테이너가 남지 않는다.

---

## 판단 기준

phase5c와 동일하게 `etude=sandbox` label로 필터링한다.
이미지 이름이나 컨테이너 이름으로 판단하면 다른 용도의 컨테이너를 잘못 삭제할 수 있다.

---

## 구현

### index.ts — graceful shutdown 훅 추가

Fastify의 `onClose` 훅을 사용한다. 서버가 `fastify.close()`를 받으면 실행된다.

```typescript
fastify.addHook('onClose', async () => {
    const containers = await docker.listContainers({
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
})
```

### SIGTERM / SIGINT 처리

Node.js 프로세스가 시그널을 받으면 `fastify.close()`를 호출해 onClose 훅이 실행되도록 연결한다.

```typescript
const shutdown = async () => {
    await fastify.close()
    process.exit(0)
}

process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)
```

---

## 검증

1. 퀘스트 세트 진입 → 컨테이너 생성 확인 (`docker ps --filter label=etude=sandbox`)
2. 백엔드 서버 `Ctrl+C` 종료
3. `docker ps -a --filter label=etude=sandbox` — 컨테이너 없어야 성공
