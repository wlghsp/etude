# 명세 — k8s Deployment 배포 옵션 손연습 세트 (496)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: Recreate, rollout pause·resume, minReadySeconds, revisionHistoryLimit, create deployment -- 명령, generateName, shareProcessNamespace, change-cause, 현재 ReplicaSet.

## 구성 (12문제, 세트 496, sandbox `k8s`, 분야 k8s, 단원 `컨테이너 실행·재시작·Deployment 읽기`(64) 끝, 🎞️)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | `strategy: Recreate` (rollingUpdate 를 null 로) |
| 2 | 터미널 | `rollout pause` → `set image`·`set env` → `resume`, 개정 2개 |
| 3 | 터미널 | `minReadySeconds: 10` |
| 4 | 터미널 | `revisionHistoryLimit: 1` + 이미지 3회 변경 → ReplicaSet 2개 |
| 5 | 터미널 | `create deployment --replicas=2 -- sleep 3600` |
| 6 | 터미널 | `generateName` 파일로 `create` 2회 |
| 7 | 터미널 | `shareProcessNamespace: true`, 사이드카 `ps` |
| 8 | 터미널 | `kubernetes.io/change-cause` 어노테이션과 `rollout history` |
| 9 | 터미널 | 현재 Pod 를 거느린 ReplicaSet 이름 |
| 10 | 객관식 | Recreate 가 알맞은 경우 |
| 11 | 빈칸 | `kubectl rollout {0}` (pause) |
| 12 | 순서 | 변경을 모아 한 번의 롤아웃으로 배포 |

- 거짓 통과 방지: 무행동 검사 통과(9/9, `검증됨`, k3d).
- 알려진 한계: 롤아웃 중 무중단 여부·`minReadySeconds` 의 지연 효과는 확인하지 않는다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
