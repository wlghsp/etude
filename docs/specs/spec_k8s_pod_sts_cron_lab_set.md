# 명세 — k8s Pod·StatefulSet·CronJob 설정 손연습 세트 (497)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: enableServiceLinks, configMapKeyRef optional, hostname·subdomain, podManagementPolicy Parallel, StatefulSet partition, CronJob suspend·`create job --from`, schedulerName, activeDeadlineSeconds, `exec -i`.

## 구성 (12문제, 세트 497, sandbox `k8s`, 분야 k8s, 단원 `Pod 수명주기·보안·네트워크 정책`(61) 끝, 🕹️)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | `enableServiceLinks: false` (`SVC_DEMO_*` 변수 없음) |
| 2 | 터미널 | `configMapKeyRef.optional: true` 로 없는 ConfigMap 을 참조해도 Running |
| 3 | 터미널 | `hostname`·`subdomain` |
| 4 | 터미널 | StatefulSet `podManagementPolicy: Parallel` |
| 5 | 터미널 | StatefulSet `partition: 2` 로 `-2` 만 이미지 변경 |
| 6 | 터미널 | CronJob `suspend: true` + `create job manual --from=cronjob/tick` |
| 7 | 터미널 | 없는 `schedulerName` 으로 Pending 인 Pod 를 다시 만들기 |
| 8 | 터미널 | `activeDeadlineSeconds: 10` → Failed / DeadlineExceeded |
| 9 | 터미널 | `kubectl exec -i` 로 내 파일을 Pod 안에 쓰기 |
| 10 | 객관식 | partition 2 의 동작 |
| 11 | 빈칸 | `podManagementPolicy: {0}` (Parallel) |
| 12 | 순서 | CronJob 정지 → 수동 실행 → 확인 → 재개 |

- 거짓 통과 방지: 무행동 검사 통과(9/9, `검증됨`, k3d).
- 처음 1번은 `KUBERNETES_SERVICE_HOST` 가 항상 주입되어 `SERVICE_HOST` 로 검사하면 실패해, `SVC_DEMO` 로 좁혔다.
- 알려진 한계: partition 을 0 으로 내려 전체를 올리는 단계는 확인하지 않는다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
