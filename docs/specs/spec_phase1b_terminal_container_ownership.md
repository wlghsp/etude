# Phase 1b 명세 — containerId 관리 주체를 Terminal로 이전

## 목표

`App.tsx`가 `containerId` state를 들고 있다가 `Terminal`에 넘겨주는 지금 구조를, `Terminal`이 스스로 "새 컨테이너로 시작할지 기존 컨테이너에 재접속할지"를 판단하도록 바꾼다. 부모(`App.tsx`)가 퀘스트 전환 지점마다 수동으로 `containerId`를 리셋해줘야 하는 부담을 없앤다.

배경: 팀원 오픈 직전 실사용 중 `docker`(비영속) sandbox 타입에서 퀘스트를 넘기면 터미널이 "환경 준비 중"에서 멈추는 버그 발견. `App.tsx`가 이전 퀘스트에서 연결됐던 `containerId`를 리셋 없이 그대로 `Terminal`에 넘겨, 이미 정리됐거나 무관한 컨테이너로 재접속을 시도한 게 원인. 1차로 `onNext`/`onPrev`에 리셋 코드를 추가해 임시 봉합했으나(`f3d44e8`), "새로 마운트한다(`key` 변경)"는 신호와 "새 컨테이너로 시작한다(`containerId` 리셋)"는 신호가 원래 하나여야 하는데 둘로 쪼개져 있고 그 동기화를 개발자가 매 전환 지점마다 수동으로 맞춰야 한다는 구조적 문제가 남음.

---

## 현재 구조의 문제

```
App.tsx
  ├─ containerId state 소유
  ├─ Terminal key={...questIndex...} — 퀘스트 바뀌면 리마운트
  ├─ Terminal에 containerId prop 전달
  └─ onNext/onPrev — questIndex만 바꾸고 containerId는 그대로 (버그 원인)

Terminal.tsx
  └─ containerId prop이 있으면 무조건 URL에 실어 재접속 시도
```

`key` 변경(리마운트 트리거)과 `containerId` 리셋(새 컨테이너 신호)이 서로 다른 코드 경로에 있어서, 새 전환 지점이 추가될 때마다 두 개를 동시에 맞춰야 한다. 하나라도 빠뜨리면 이번과 같은 버그가 재발한다.

---

## 목표 구조

`sandboxType`이 `docker-persistent`(세트 전체에서 컨테이너 유지가 의도된 유일한 타입)가 아니면, `Terminal`은 부모가 준 `containerId`를 애초에 참고하지 않고 항상 새 컨테이너를 요청한다. "재사용 여부 판단"을 `Terminal` 내부로 캡슐화해서, `App.tsx`는 더 이상 이 판단에 관여할 필요가 없어진다.

```
Terminal.tsx
  └─ sandboxType이 docker-persistent가 아니면 containerId prop을 무시
  └─ docker-persistent면 containerId prop을 그대로 사용(재접속)
```

`App.tsx`의 `onNext`/`onPrev`에서 추가했던 `if (sandboxType !== 'docker-persistent') setContainerId('')` 임시 코드는 이 변경 후 불필요해지므로 제거한다.

---

## 범위 밖

- `containerId` state를 `App.tsx`에서 완전히 없애는 것 — `QuestPanel`의 채점(`gradeQuest`) 호출에 `containerId`가 여전히 필요하므로, `onConnected` 콜백을 통해 `App.tsx`가 값을 받아 보관하는 구조 자체는 유지한다. 이 Phase는 "받은 값을 다음 마운트에서 어떻게 쓰느냐"만 바꾼다.
- WebSocket 재연결/네트워크 끊김 복구 로직 — 별도 주제.

---

## 검증 기준

- [ ] `docker`(비영속) 세트에서 퀘스트를 여러 번 넘겨도 매번 새 터미널이 정상 연결되는지 확인
- [ ] `docker-persistent` 세트에서 퀘스트를 넘겨도 같은 컨테이너가 유지되는지(기존 동작 회귀 없음) 확인
- [ ] `linux`, `k8s` 등 나머지 sandbox 타입도 퀘스트 전환 시 정상 연결되는지 확인
- [ ] `App.tsx`의 `onNext`/`onPrev`에서 임시로 추가했던 `setContainerId('')` 코드 제거 후에도 위 시나리오가 모두 통과하는지 확인
