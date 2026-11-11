# 명세 — k8s Deployment 롤아웃과 복구 세트 (set image · history · undo · restart)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 230. 근거: 인접 세트 134(업데이트·Job·상태 읽기), 157(배포 전략·설정), 194(롤아웃 제어와 설정 주입), 217(Deployment 와 ReplicaSet)은 모두 객관식·빈칸·순서로 "읽고 맞히기"이고 롤아웃 주제의 터미널 문제가 없다. 이 세트는 같은 주제를 **직접 바꾸고 고쳐 보는 실습**으로 채운다. 인접 세트 227(Service 디버깅)과는 대상(Deployment 업데이트·복구)이 다르다.

## 목표

Deployment 를 만들고 키우고 이미지를 바꾸는 흐름에서 시작해, 업데이트 이력(REVISION, CHANGE-CAUSE)을 읽고, 잘못된 이미지 태그로 업데이트가 막혔을 때 알아채고(`ErrImagePull`/`ImagePullBackOff`) 되돌리는(`rollout undo`, `--to-revision`) 손버릇을 만든다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. "Deployment `web` 의 이미지가 `nginx:1.27-alpine` 이다", "ready/updated/replicas 가 모두 N 이다", "REVISION 이 4 이다", "change-cause annotation 이 …이다" 처럼 클러스터 상태를 확인한다. 읽기 문제(4, 5번)는 결과 파일의 내용을 확인한다.
- 새 개념은 한 문제에 하나만. 만들기 → scale → set image → history 읽기 → 이미지 오류 알아채기 → undo → 사유 적기 → restart → `--to-revision` 순서로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Deployment·ReplicaSet·Pod 만 쓴다.
- 이미지는 `nginx`(1.24, 1.25, 1.27-alpine), `busybox` 만 쓴다. 일부러 틀린 태그(`nginx:1.27-alpne`)는 받아 오지 못하는 상태를 만드는 용도다.
- 각 문제의 setup 은 앞선 문제의 흔적을 지우고(`delete deploy web --cascade=foreground`, `--all` 은 쓰지 않는다) 같은 이름으로 다시 만든다. 정상 상태는 `kubectl rollout status --timeout` 으로 기다린다. 일부러 막힌 상태(5·7번)는 Ready 가 아니라 **Pod 의 대기 사유가 `ErrImagePull`/`ImagePullBackOff` 로 보일 때까지** 기다린다.
- 롤아웃 채점은 `readyReplicas/updatedReplicas/replicas` 가 모두 N 인지로 "업데이트 완료"를 확인하고, 반영 지연을 고려해 최대 15~40초 다시 확인한다(`poll`).
- 변경 사유 채점은 Deployment 의 annotation 과 `rollout history` 출력(REVISION 2 줄)을 함께 본다.

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | Deployment 만들기 | `create deployment --image --replicas`, `rollout status` |
| 2 | 터미널 | 복제본 수 늘리기 | `kubectl scale --replicas` |
| 3 | 터미널 | set image 로 이미지 바꾸기 | `set image 컨테이너=이미지`, 롤링 업데이트 |
| 4 | 터미널 | rollout history 로 REVISION 보기 | `rollout history`, REVISION 번호 |
| 5 | 터미널 | get pods 로 이미지 오류 알아채기 | `ErrImagePull`/`ImagePullBackOff`, 이전 Pod 는 아직 Running |
| 6 | 객관식 | 이미지를 못 받는 이유는 어디서 볼까 | `describe pod` 의 Events |
| 7 | 터미널 | rollout undo 로 이전 버전으로 되돌리기 | `rollout undo` |
| 8 | 빈칸 | 변경 사유를 적는 annotation | `kubernetes.io/change-cause` |
| 9 | 터미널 | annotate 로 CHANGE-CAUSE 채우기 | `kubectl annotate`, history 의 CHANGE-CAUSE |
| 10 | 터미널 | rollout restart 로 Pod 새로 띄우기 | `rollout restart`(이미지 그대로, REVISION 증가) |
| 11 | 터미널 | rollout undo --to-revision 으로 옛 버전 골라 가기 | `history --revision=N`, `undo --to-revision`, 새 번호로 올라가는 이력 |
| 12 | 순서 | 이미지 업데이트가 막혔을 때 복구하는 순서 | 바꾸기 → 기다리기 → 증상 → 이유 → undo → 재확인 |

## 배치

k8s 단원 9 운영과 트러블슈팅 끝, display_order 332, 아이콘 ⏪. 아이콘도 통합 시 정함. 세트 230, `sandbox_type = k8s`, 분야 k8s. 구현: `gen230.py` (예시 생성기 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set230.sql`, `backend/verify/set230.json`, 마이그레이션(세트 INSERT 와 문제 INSERT 만)을 만든다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 230`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 이미지·ready/updated/replicas·REVISION 번호·change-cause·파일 내용 같은 **실제 상태**를 확인한다. 존재 여부만 보지 않는다.
- [x] 5·7번 setup 이 Ready 를 기다리지 않고(이미지 당기기 실패 사유가 보일 때까지만 대기) 안정적으로 끝난다.
- [x] 9번에서 annotate 후 `rollout history` 의 REVISION 2 줄에 사유가 15초 안에 나타난다.
- [x] 10번 restart 후 REVISION 이 2, 11번 `--to-revision=1` 후 REVISION 이 4 가 되는지 클러스터에서 확인한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (6번: `describe pod` Events). 빈칸 칩에 정답이 둘이 아니다.
- [x] 각 문제 `docs` 에 Deployment·kubectl rollout·Pod 디버깅 공식 문서 링크가 달려 있다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
