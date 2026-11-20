# 명세 — 세트 512 PV·StorageClass 손연습: 정적 바인딩, 접근 모드, 보존 정책

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_k8s.md` 필수 행(PV·StorageClass 손연습). 샌드박스 `k8s`, 카테고리 `k8s`, 단원 8 (스토리지와 네트워크), display_order 733. 선행: 13·122. 생성: `scripts/content-gen/new_sets/set512.py`.

## 환경 제약 (설계의 전제)

`k8s` 샌드박스 학습자는 자기 네임스페이스 안에서만 권한이 있다(`edit` RoleBinding + 노드·네임스페이스 읽기). **PV 생성(`create persistentvolumes`)은 거부**되고, PV·StorageClass 조회도 안 되며, hostPath 볼륨 Pod 는 Pod Security 가 막는다(`backend/src/verify/permission-probes.ts`). 따라서 정적 PV 를 직접 만드는 실습은 하지 않는다. 터미널 문제는 PVC 쪽에서 보이는 상태 변화(Pending → Bound, 이벤트, 거부 메시지, Terminating)를 다루고, PV 를 만드는 YAML·바인딩 조건·Retain 정책·정적 바인딩 순서는 객관식·빈칸·순서로 익힌다. 네임스페이스 쿼터(PVC 4개)를 넘지 않도록 각 setup 은 앞 문제의 Pod·PVC 를 먼저 지운다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | PVC 를 만들면 Pod 가 없어 Pending (`WaitForFirstConsumer`) | 파일에 Pending, PVC 1Gi |
| 2 | 실습 | Pod 가 PVC 를 마운트하면 Bound | PVC Bound, Pod 의 claimName |
| 3 | 실습 | Bound PVC 에서 PV 이름·용량·접근 모드 읽기 | 파일 3개가 실제 값과 일치 |
| 4 | 실습 | ReadWriteMany 를 요구해 실패, 이벤트 이유 읽기 | 파일에 `only supports ReadWriteOnce` |
| 5 | 실습 | 접근 모드는 불변: 지우고 ReadWriteOnce 로 재생성 | PVC RWO·Bound, Pod Running |
| 6 | 실습 | 없는 StorageClass 이름을 요구한 Pending 진단 | 클래스 이름·`not found` 이유 |
| 7 | 실습 | `storageClassName: ""` 는 정적 바인딩만, PV 없어 Pending | 빈 문자열, `no persistent volumes available` |
| 8 | 실습 | 확장 불가 StorageClass 에서 용량 늘리기 거부 | 파일에 `must support resize`, 용량 1Gi |
| 9 | 실습 | 사용 중 PVC 삭제는 Terminating (pvc-protection) | 파일에 Terminating, PVC·Pod 사라짐 |
| 10 | 객관식 | 정적 PV 에 바인딩되는 PVC 조건(용량·접근 모드·클래스) | |
| 11 | 빈칸 | 정적 PV(hostPath) YAML: `path`, `manual`, `Retain` | |
| 12 | 순서 | 정적 바인딩 흐름(PV 생성 → PVC → Bound → Pod 마운트) | |

## 수용 조건

- [ ] `verify:quests --set 512` 실습 9개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 한 세트 형식 4종(터미널·객관식·빈칸·순서), 터미널 9/12
- [ ] `check-content.sh` 통과
- [ ] 현장 정보 없음 (`example.com` 등 일반 이름만)
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
