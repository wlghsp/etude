# Phase 6b 명세 — k8s namespace 고아 정리

## 목표

`k8s`(namespace 격리) sandbox 타입에서 세션 종료 시 정리되지 않고 남는 `quest-*` namespace를 서버 기동 시 자동으로 정리한다.

배경: 팀원 계정 오픈을 앞두고 실사용 트래픽이 늘어나기 전에, Phase 10에서 vcluster 고아 정리(`cleanupOrphanVclusters`)를 만들며 발견한 것과 동일한 유형의 문제가 `k8s` 타입에도 있음을 확인 — 지금까지는 실제 정리 로직이 없었다.

---

## 문제

`terminal.ts`의 `handleK8sTerminal()`은 세션 종료 시 namespace를 지우지만, 이는 **정상 종료 흐름(WebSocket `close` 이벤트)에서만** 동작한다.

```typescript
socket.on('close', async () => {
  // namespace 삭제 후 컨테이너 제거
  ...
})
```

아래 경우엔 이 코드 자체가 실행되지 않아 namespace가 클러스터에 그대로 남는다.

- 서버 프로세스가 비정상 종료(크래시, `kill -9`, 배포 중 강제 재시작)
- 네트워크 단절로 `close` 이벤트가 서버에 전달되지 않는 경우

`cleanupOrphanContainers()`(Docker 컨테이너)와 `cleanupOrphanVclusters()`(vcluster)는 이미 존재하지만, **`quest-*` namespace를 정리하는 로직은 없다.**

---

## 해결 방향

Docker/vcluster 고아 정리와 동일한 철학: 서버 기동 시점에는 이전 상태를 신뢰하지 않고, `quest-` 접두사를 가진 namespace를 전부 조회해 삭제한 뒤 시작한다.

### 대상 식별

`k8s` 타입의 namespace 명명 규칙은 `quest-{containerId 앞 8자리}` ([terminal.ts:174](../../backend/src/services/terminal.ts#L174)). 이 접두사로 필터링한다.

### 실행 시점

`index.ts`에서 서버 기동 시, `cleanupOrphanContainers()`/`initPool()`과 같은 자리에서 호출한다.

---

## 범위 밖

- `k8s-isolated`(vcluster) 관련 정리는 이미 Phase 10에서 구현됨 — 이 Phase는 `k8s`(namespace 격리) 타입에 한정.
- 세션 종료 시 정상 정리 로직 자체는 이미 있으므로 변경하지 않음. 이 Phase는 "비정상 종료 시 놓친 것"을 잡는 안전망 추가에 한정.

---

## 검증 기준

- [ ] `k8s` 세트로 터미널을 연 뒤 서버 프로세스를 강제 종료(`kill -9`)해 namespace가 남는 것을 재현
- [ ] 서버 재기동 시 `kubectl get ns | grep quest-`로 남아있던 namespace가 정리되는지 확인
- [ ] 서버 기동 로그에서 정리 함수가 실행되는지 확인 (에러 없이 통과)
- [ ] 정상 세션 종료 흐름(WebSocket close)이 기존과 동일하게 동작하는지 회귀 확인
