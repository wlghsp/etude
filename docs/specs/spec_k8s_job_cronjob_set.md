# 명세 — k8s Job 과 CronJob 실습 세트 (create job · logs · backoffLimit · completions · create job --from · suspend)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 233. 근거: 인접 세트 134(Job·CronJob 개념), 163(CronJob 기본값·suspend), 178(Job 필드)은 모두 객관식·빈칸·순서로 "읽고 맞히기"이고, 터미널로 Job 을 직접 만들고 고치는 문제는 세트 22(Job 만들기·완료 횟수·CronJob·중지)뿐이다. 이 세트는 같은 주제를 **결과(클러스터 상태)로 채점하는 실습**으로 채운다: 실패한 Job 읽고 고치기, completions/parallelism 매니페스트, `create job --from` 시험 실행을 더한다.

## 목표

`kubectl create job` 으로 Job 을 만들고 `get jobs` 의 COMPLETIONS 와 `logs job/이름` 을 읽는 것에서 시작해, 실패한 Job(backoffLimit)을 알아채고 고쳐 다시 만들고, completions/parallelism 으로 여러 번 실행하고, CronJob 을 만들어 `create job --from` 으로 지금 한 번 실행하고 `patch` 로 멈추는 손버릇을 만든다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. "Job `hello` 의 `status.succeeded` 가 1 이다", "`completions`=6, `parallelism`=2, 성공 6번", "CronJob `schedule` 이 `*/30 * * * *` 이다", "`spec.suspend` 가 true 이다" 처럼 클러스터 상태를 확인한다. 읽기 문제(2, 3, 4번)는 결과 파일의 내용을 확인한다.
- 새 개념은 한 문제에 하나만. create job → COMPLETIONS 읽기 → logs → 실패 로그 읽기 → (backoffLimit 개념) → 고쳐 다시 만들기 → completions/parallelism → (ttl 개념) → create cronjob → create job --from → suspend 순서로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Job·CronJob·Pod 만 쓴다.
- 이미지는 `busybox:1.36` 만 쓴다. Job 이름은 `hello`, `flaky`, `batch`, `manual-run`, CronJob 은 `nightly` 로 고정하고, 각 setup 은 이 이름들만 지운다(`--all` 은 쓰지 않는다).
- 끝나야 하는 Job 은 `kubectl wait --for=condition=complete --timeout` 으로 기다린다. 일부러 실패시킨 Job(`flaky`)은 `backoffLimit: 0` 매니페스트로 만들어 Pod 가 한 번 실패하면 끝나게 하고, `status.failed >= 1` 이 될 때까지 폴링한다(재시도 대기에 의존하지 않는다).
- CronJob 은 **실제로 돌 때를 기다리지 않는다.** 일정이 먼 `0 0 1 1 *` 로 setup 하고, 실행 확인은 `create job --from` 으로 한다. 9번의 `*/30` 은 일정 값만 채점한다.
- `ttlSecondsAfterFinished` 는 개념(빈칸)으로만 다룬다. 지워지는 시점에 의존한 채점은 하지 않는다.
- 상태 확인은 jsonpath 로 하고, 반영 지연을 고려해 최대 15~90초 다시 확인한다(`poll`).

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태) |
|---|------|------|----------------|------------|
| 1 | 터미널 | Job 만들어 한 번 실행하기 | `create job 이름 --image -- 명령` | hello 성공 1, 로그 `hello etude` |
| 2 | 터미널 | get jobs 의 COMPLETIONS 읽기 | `get jobs`, `성공/필요` 칸 | 파일에 hello 1/1, flaky 0/1 |
| 3 | 터미널 | logs job/이름 으로 결과 읽기 | `logs job/이름` | 파일에 로그 내용 |
| 4 | 터미널 | 실패한 Job 의 이유 찾기 | 실패해도 Pod·로그가 남음 | 파일에 `ech0: not found` |
| 5 | 객관식 | backoffLimit 가 0 이면 | 재시도 횟수, 바로 Failed | 정답 보기 |
| 6 | 터미널 | 고쳐서 다시 만들기 | 템플릿 불변 → delete 후 create | flaky 성공 1, 로그 `done`, 실패 흔적 없음 |
| 7 | 터미널 | completions 와 parallelism 으로 여러 번 실행 | 매니페스트 apply, 총 횟수 vs 동시 수 | completions 6, parallelism 2, 성공 6 |
| 8 | 빈칸 | 끝난 Job 을 자동으로 지우는 필드 | `ttlSecondsAfterFinished` (개념만) | 정답 칩 |
| 9 | 터미널 | CronJob 으로 정해진 때마다 실행 | `create cronjob --schedule`, `get cronjob` | schedule `*/30 * * * *` |
| 10 | 터미널 | create job --from 으로 지금 한 번 실행 | `create job --from=cronjob/이름` | manual-run 성공 1, instantiate=manual, 일정 그대로 |
| 11 | 터미널 | patch 로 CronJob 잠시 멈추기 | `patch cronjob -p '{"spec":{"suspend":true}}'` | suspend true, 일정 그대로 |
| 12 | 순서 | 정기 작업을 만들고 시험해 보는 순서 | create → get → create job --from → logs → patch suspend → delete job | 정답 순서 |

## 배치

k8s 단원 9 운영과 트러블슈팅 끝, display_order 333, 아이콘 ⏰. 아이콘도 통합 시 정함. 세트 233, `sandbox_type = k8s`, 분야 k8s. 구현: `gen233.py` (gen230.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set233.sql`, `backend/verify/set233.json`, 마이그레이션(세트 INSERT 와 문제 INSERT 만)을 만든다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 233`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 Job 성공 횟수·completions/parallelism·schedule·suspend·로그/파일 내용 같은 **실제 상태**를 확인한다. 존재 여부만 보지 않는다.
- [x] 2·4·6번 setup 의 실패 Job(`flaky`)이 `status.failed >= 1` 이 되면 안정적으로 끝난다 (재시도 대기 없음).
- [x] 10번이 CronJob 이 실제로 도는 시각에 의존하지 않고 `create job --from` 으로만 통과한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (5번). 빈칸 칩에 정답이 둘이 아니다 (8번).
- [x] 각 터미널 문제 `docs` 에 Job·CronJob·kubectl create job 공식 문서 링크가 달려 있다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
