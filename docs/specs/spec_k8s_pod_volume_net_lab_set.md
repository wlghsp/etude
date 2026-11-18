# 명세 — k8s Pod·볼륨·네트워크 설정 손연습 세트 (494)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: port-forward, emptyDir Memory, projected, subPath, resourceFieldRef, sessionAffinity, topologySpread, HPA v2, dnsConfig.

## 구성 (12문제, 세트 494, sandbox `k8s`, 분야 k8s, 단원 `롤아웃·Pod 스펙·Kustomize·ConfigMap`(63) 끝, 🪣)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | `port-forward svc/web 8080:80` 후 `curl` |
| 2 | 터미널 | `emptyDir {medium: Memory}` → tmpfs |
| 3 | 터미널 | projected 볼륨(ConfigMap+Secret) |
| 4 | 터미널 | `subPath` 로 파일 하나만 마운트 |
| 5 | 터미널 | `resourceFieldRef` + `divisor` |
| 6 | 터미널 | `sessionAffinity: ClientIP` |
| 7 | 터미널 | `topologySpreadConstraints` (ScheduleAnyway) |
| 8 | 터미널 | HPA `autoscaling/v2` 메모리 80% |
| 9 | 터미널 | `dnsConfig` ndots 2 |
| 10 | 객관식 | `DoNotSchedule` 의 동작 | 
| 11 | 빈칸 | `medium: {0}` (Memory) |
| 12 | 순서 | port-forward 확인 순서 |

- 거짓 통과 방지: 무행동 검사 통과(9/9, `검증됨`, k3d).
- 처음 CLEAN 의 `kill $(pgrep -f 'kubectl port-forward')` 가 setup 쉘 자신을 죽여(종료 코드 143) `pkill -x kubectl` 로 고쳤다.
- 알려진 한계: HPA 실제 동작(부하)·`kubectl top`·노드 2개 이상의 분산 효과는 확인하지 않는다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
