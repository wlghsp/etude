# k8s PersistentVolume 정리 명세 — 세션이 남기는 클러스터 범위 리소스 제거

> 상태: **구현 완료 (Codex 리뷰 대기)**. [채점 검증 러너 명세](spec_grading_verification.md)의 V4 검증 중 발견한 앱 쪽 결함이다.

## 목표

`k8s` 샌드박스 세션이 끝났을 때, 세션이 만든 **클러스터 범위 리소스(`PersistentVolume`)**가 클러스터에 남지 않게 한다.

## 현황 (코드와 클러스터로 확인한 사실)

- 세트 13의 퀘스트(13.1~13.4)는 `PersistentVolume`을 `pv-local-$NS`라는 이름으로 만들고, `claimRef.namespace`를 `$NS`로 지정한다. PV는 **네임스페이스에 속하지 않는 클러스터 범위 리소스**다.
- 세션 종료 시 [terminal.ts](../../backend/src/services/terminal.ts)의 `handleK8sTerminal`은 `kubectl delete namespace`만 실행한다. 네임스페이스를 지워도 PV는 남는다(`Available`/`Released`).
- 실제로 로컬 클러스터에 실제 세션이 남긴 `pv-local-quest-8a1fb9aa`, `pv-local-quest-d0daf6cd`(`Available`)가 있었다. 서버에도 쌓여 있을 수 있다 (`kubectl get pv`로 확인 필요).
- 기동 시 정리 [k8s-namespace.ts](../../backend/src/plugins/k8s-namespace.ts)도 `quest-*` 네임스페이스만 지운다.
- 같은 정리 코드에 **경쟁 상태**가 있다: `delExec.start({})`는 명령을 시작만 하고 끝나길 기다리지 않는데, 곧바로 `removeContainer`가 컨테이너를 중지한다. 컨테이너가 멈추면 안의 `kubectl`도 죽으므로 네임스페이스 삭제 요청이 전달되기 전에 끊길 수 있다.

## 설계

### 1. 세션 종료 시 정리

`k8s` 세션의 정리 순서를 다음으로 한다. 각 명령은 **끝날 때까지 기다린다**(제한 시간 있음).

```
1. 이 세션의 네임스페이스를 claimRef로 가진 PV 삭제
2. 네임스페이스 삭제 (--wait=false: 종료 완료를 기다리지 않는다)
3. 컨테이너 중지·삭제
```

PV 삭제는 `claimRef.namespace == <ns>`로 찾는다 (이름 규칙에 의존하지 않는다). 어느 단계가 실패해도 다음 단계로 진행하고, 컨테이너 삭제는 항상 실행한다.

### 2. 기동 시 정리

`cleanupOrphanQuestNamespaces`가 `quest-*` 네임스페이스를 지운 뒤, **`claimRef.namespace`가 `quest-`로 시작하는 PV**도 지운다. 이미 쌓인 누수(`Available`/`Released`)도 이때 걷힌다. 기동 정리는 원래 `quest-*` 자원을 전부 지우는 동작이므로 대상 범위가 같다.

### 3. 공유 명령

PV를 찾아 지우는 셸 명령은 한 곳(`services/k8s-cleanup.ts`)에서 만들고, 세션 정리와 검증 러너가 함께 쓴다. 지금 러너의 정리 코드가 같은 명령을 따로 갖고 있어 하나로 합친다.

## 수용 조건

- [x] k8s 세션 종료 시 해당 네임스페이스를 claimRef로 가진 PV가 지워진다
- [x] 정리 명령(PV 삭제, 네임스페이스 삭제)이 끝날 때까지 기다린 뒤 컨테이너를 중지한다
- [x] PV 삭제가 실패해도 네임스페이스 삭제와 컨테이너 삭제는 진행된다
- [x] 기동 시 `claimRef.namespace`가 `quest-`로 시작하는 PV가 지워진다
- [x] 다른 접두어의 네임스페이스를 가진 PV와 claimRef가 없는 PV는 지우지 않는다
- [x] 러너와 앱이 같은 PV 정리 명령을 쓴다

## 테스트 전략

- 세션 정리: fake docker로 `exec` 호출 순서(PV → 네임스페이스 → 컨테이너 삭제)와 각 `exec`의 완료 대기를 검증한다
- 기동 정리: `child_process`를 대체해 `get pv` 결과 중 `quest-` 접두어의 claimRef만 삭제 대상이 되는지 검증한다
- 실제 클러스터에서 세트 13을 검증 러너로 돌려 PV가 남지 않는지 확인한다 (이미 확인됨)

## 범위 밖

- 노드의 hostPath 데이터(`/tmp/pv-data`) 삭제. `hostPath` PV를 지워도 노드의 디렉터리는 남고, 모든 세션이 같은 경로(`/tmp/pv-data`)를 공유한다. 세션 간에 데이터가 섞일 수 있는 **별도 위험**이라 퀘스트 설계(세션별 경로) 쪽에서 다룬다.
- 서버에 이미 쌓인 PV의 수동 정리 (기동 정리가 다음 재시작 때 걷어 간다)

## 검증 결과 (2026-10-28)

- 자동 테스트: 공유 명령(`k8s-cleanup.test.ts`), 세션 정리 순서와 완료 대기(`terminal.test.ts`), 기동 정리(`k8s-namespace.test.ts`). 전체 17파일 117건 통과.
- 실제 클러스터(검증됨): 세트 13을 검증 러너로 다시 실행해 8/8 통과했고 `pv-local-verify-*`가 남지 않았다. 러너가 앱의 세션 정리와 같은 `pvCleanupCommand`를 쓴다.
- 실제 클러스터(검증됨, 읽기 전용): 기동 정리가 파싱하는 `kubectl get pv -o jsonpath` 출력 형식이 가정과 일치한다. vcluster pool이 쓰는 정상 PV(`pvc-…`, claimRef `vcluster-pool-*`)는 `quest-` 필터에 걸리지 않는다.
- **미검증:** 앱의 `handleK8sTerminal` 정리 경로를 실제 세션으로 실행해 보지는 못했다(fake docker 단위 테스트와, 같은 명령을 쓰는 러너 실행으로 갈음). 기동 정리의 실제 삭제도 실행하지 않았다 — 로컬 클러스터에 남은 `pv-local-quest-8a1fb9aa`, `pv-local-quest-d0daf6cd`는 다음 backend 기동 때 걷힌다.
- **서버:** 이 변경을 배포하면 다음 backend 재시작 때 서버에 쌓인 `quest-*` 참조 PV가 정리된다. 배포 전에 `kubectl get pv`로 `quest-` claimRef를 가진 PV와 그 안의 데이터를 쓰는 것이 없는지 확인한다.
