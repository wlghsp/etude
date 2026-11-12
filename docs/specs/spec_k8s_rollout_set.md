# 명세 — k8s Deployment 롤아웃 손연습 세트 (status · history · undo · pause · patch 전략)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 세트 345. 근거: 세트 230(롤아웃과 복구)이 `set image`, `rollout history`, `rollout undo`, `--to-revision`, `annotate change-cause`, 막힌 이미지 알아채기를 이미 터미널로 다룬다. 세트 26 의 4·5번은 `maxSurge/maxUnavailable` 과 `rollout pause` 를 다루고, 세트 134·157·217 은 같은 개념의 퀴즈형이다. 이 세트는 겹치는 도구를 **다른 목적**으로 쓰는 손연습에 집중한다: 끝날 때까지 기다린 결과 저장, 조건부 `scale`, 버전마다 다른 사유 남기기, `history --revision` 으로 이미지 읽기, `patch` 로 전략 값 바꾸기, `pause` 로 변경 모아 한 번에 배포, 막힌 롤아웃의 가용성 읽기, `progressDeadlineSeconds`, 두 단계 전 버전으로 복구.

## 목표

Deployment 를 업데이트하고 되돌리는 손버릇을 만든다. `kubectl set image` 후 `rollout status` 로 끝까지 기다리고, `rollout history` 로 버전별 정보를 읽고, `patch` 로 `maxSurge`·`maxUnavailable`·`progressDeadlineSeconds` 를 바꾸고, `pause`/`resume` 으로 여러 변경을 한 번에 배포하고, 틀린 이미지로 막힌 롤아웃에서 서비스가 유지되는 모습을 확인하고, `undo --to-revision` 으로 원하는 버전으로 복구한다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. 이미지, 환경변수, 전략 값(`maxSurge`, `maxUnavailable`), `progressDeadlineSeconds`, REVISION 번호, `rollout history` 의 CHANGE-CAUSE, `Progressing` 사유, 저장한 파일의 내용을 확인한다. setup 만 한 상태에서는 채점이 실패해야 한다.
- 새 개념은 한 문제에 하나만. status 기다리기 → 조건부 scale → 버전별 사유 → history `--revision` → (빈칸 `--to-revision`) → (객관식 maxSurge/maxUnavailable) → `patch` 전략 → `pause` 로 모으기 → 막힌 롤아웃의 가용성 → 진행 한도 → 두 단계 전 복구 → (순서) 로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Deployment 와 Pod 의 조회·갱신만 쓴다. 이미지는 `nginx:1.24`, `nginx:1.25`, `nginx:1.27-alpine` 만 쓰고, 일부러 틀린 태그 `nginx:1.27-alpne` 는 받지 못해 막히는 상태를 만드는 용도다.
- 연습 오브젝트는 Deployment `ro-web`(컨테이너 이름 `nginx`) 하나다. setup 정리는 **이 이름만** 지운다 (`--all` 은 쓰지 않는다). 파일은 `/tmp` 에 두고 setup 이 `/tmp/*.txt` 를 지운다.
- 학습자의 풀이에는 `wait` 가 없다. 롤아웃 확인은 `updatedReplicas-readyReplicas-replicas` 가 `n-n-n` 이 될 때까지 **채점이 최대 40초 폴링**한다. 막힌 상태(9·10·11번)의 setup 은 Pod 의 대기 사유가 `ErrImagePull`/`ImagePullBackOff` 로 보일 때까지 기다린다. 10번의 `ProgressDeadlineExceeded` 는 채점이 최대 90초 폴링한다.
- 기본 ServiceAccount 가 volumeMount 를 붙이므로 volumeMounts 는 검사하지 않는다. `set env` 는 키마다 env 항목을 만드므로 `env[0]` 하나를 가정하는 8번은 env 를 하나만 넣는다.
- 3번은 사유 annotation 이 "그 순간의 현재 버전"에 붙는 성질을 쓴다. 업데이트가 시작된 뒤 새 버전이 생기기 전에 annotate 하면 옛 버전에 붙을 수 있으므로 풀이는 `rollout status` 로 새 버전을 확인한 뒤 적는다 (위험 요소로 기록).

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태·파일) |
|---|------|------|----------------|-----------------|
| 1 | 터미널 | rollout status 로 끝날 때까지 기다린 결과 저장하기 | `set image` 후 `rollout status > 파일` | 이미지 `nginx:1.25`, 3-3-3 Ready, `/tmp/status.txt` 에 `successfully rolled out` |
| 2 | 터미널 | 조건을 달아 안전하게 scale 하기 | `scale --current-replicas=2 --replicas=5` | replicas 5, 5-5-5 Ready |
| 3 | 터미널 | 변경 사유를 버전마다 따로 남기기 | annotate 시점과 버전별 CHANGE-CAUSE | history 에 `1 initial 1.24`, `2 upgrade 1.25`, 이미지 `nginx:1.25` |
| 4 | 터미널 | rollout history --revision 으로 옛 버전의 이미지 읽기 | `history --revision=N` 의 `Image:` 줄 | `/tmp/rev2.txt` 가 `nginx:1.25`, 지금 이미지 `nginx:1.27-alpine` 유지 |
| 5 | 빈칸 | undo 로 되돌릴 REVISION 고르기 | `rollout undo --to-revision=N` | 정답 칩 (`--to-revision`) |
| 6 | 객관식 | maxSurge 1, maxUnavailable 0 이면 업데이트 중에는? | 최대 Pod 수와 최소 가용 수 읽기 | 정답 보기 |
| 7 | 터미널 | kubectl patch 로 업데이트 속도 규칙 바꾸기 | `patch -p` 로 `strategy.rollingUpdate` 수정 | `maxSurge 0`, `maxUnavailable 1`, 종류 RollingUpdate, 4-4-4 Ready |
| 8 | 터미널 | pause 로 여러 변경을 모아 한 번에 배포하기 | `pause` → 이미지·env 변경 → `resume` | 이미지 `nginx:1.25`, env `APP_MODE=prod`, REVISION 2, 일시 중지 해제, 3-3-3 Ready |
| 9 | 터미널 | 막힌 업데이트 중에도 서비스가 유지되는지 세어 보기 | `status.availableReplicas`, maxUnavailable 0 의 효과 | `/tmp/avail.txt` 가 `3`, 이미지는 틀린 태그 그대로 |
| 10 | 터미널 | progressDeadlineSeconds 로 막힌 업데이트를 실패로 표시하기 | 진행 한도와 `ProgressDeadlineExceeded` | `progressDeadlineSeconds 20`, `Progressing` 사유 `ProgressDeadlineExceeded`, 이미지 그대로 |
| 11 | 터미널 | 막힌 업데이트를 두 단계 전 버전으로 되돌리기 | `undo --to-revision=1` (바로 전 버전이 아님) | 이미지 `nginx:1.24`, 3-3-3 Ready, 틀린 이미지 Pod 없음 |
| 12 | 순서 | 여러 변경을 모아 배포하는 순서 | pause → set → resume → status → history | 정답 순서 `[2, 3, 0, 4, 1]` |

## 기존 세트와의 겹침

- **세트 230 (가장 크게 겹침)**: 3번(`set image`), 4번(`history`), 7번(`undo`), 9번(`annotate`), 11번(`undo --to-revision`), 12번(막힌 이미지 복구 순서)과 도구가 같다. 이 세트는 목적을 바꿨다: 1번은 `rollout status` 출력 저장, 3번은 **버전마다 다른 사유**(230 의 9번은 현재 버전 하나), 4번은 이력에서 **이미지 값을 읽기**, 11번은 **두 단계 전 버전**으로 복구(바로 전 버전 `undo` 가 아님), 12번은 pause 흐름. 5번 빈칸(`--to-revision`)은 230 의 11번과 개념이 같아 통합 시 중복으로 볼 수 있다.
- **세트 26**: 4번(`maxSurge/maxUnavailable` 설정 YAML), 5번(`rollout pause`)과 개념이 겹친다. 이 세트의 7번은 YAML 이 아니라 `kubectl patch`, 8번은 pause 로 **변경을 모아 REVISION 이 한 번만 오르는 것**을 채점한다.
- **세트 339**: 2번(`set image` 로 틀린 태그 고치기)은 Pod 진단 맥락이라 목적이 다르다.
- 새로운 내용: `scale --current-replicas`, 막힌 롤아웃의 `availableReplicas` 읽기, `progressDeadlineSeconds`, `patch` 로 전략 값 변경, `history --revision` 의 이미지 읽기. 통합 시 중복 정도를 다시 본다.

## 배치

단원·display_order 는 통합 시 정함. 아이콘도 통합 시 정함. 세트 345, `sandbox_type = k8s`, 분야 k8s. 구현: `gen345.py` (gen342.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set345.sql`, `backend/verify/set345.json`, 마이그레이션(`2026-11-13_k8s_rollout_set345.sql`, 세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 345`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [ ] `checks` 가 이미지, env, 전략 값, REVISION, CHANGE-CAUSE, `Progressing` 사유, 파일 내용을 확인한다. 존재 여부만 보지 않는다.
- [ ] 롤아웃 확인이 최대 40초 폴링이라 풀이 직후(wait 없이) 채점해도 통과한다. 10번은 최대 90초 폴링으로 통과한다.
- [ ] 3번이 사유를 잘못된 시점에 적은 풀이(업데이트 전에 둘 다 적기)로는 통과하지 않는다. 8번이 pause 없이 따로 바꾸면(REVISION 3) 통과하지 않는다. 11번이 바로 전 버전 `undo` 로는 통과하지 않는다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (6번). 빈칸 칩에 정답이 둘이 아니다 (5번). 순서 정답 인덱스가 설명과 맞는다 (12번).
- [ ] 각 터미널 문제 `docs` 에 공식 문서 링크가 달려 있다 (링크 200 확인함: deployment, kubectl_rollout, kubectl_set_image, kubectl_scale, update-api-object-kubectl-patch).
- [ ] 각 setup 의 정리가 고정 이름 오브젝트(`ro-web`)만 지운다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
