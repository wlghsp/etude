# 명세 — k8s 설정 주입 실습 세트 (ConfigMap·Secret · 환경변수/볼륨 · 설정 오류 진단 · rollout restart)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 236. 근거: 인접 세트 12(ConfigMap·Secret 만들기와 기본 주입 터미널 8문제)가 있고, 132·194·208 은 객관식·빈칸·순서로 "읽고 맞히기"다. 이 세트는 기본 생성은 짧게 하고, **`--from-file`, 키 참조 YAML, 볼륨 마운트 파일 읽기, CreateContainerConfigError 진단과 복구, `set env --from`, "환경변수는 안 바뀌고 파일은 바뀐다" 와 `rollout restart` 반영**을 클러스터 상태로 채점하는 실습으로 채운다.

## 목표

ConfigMap 과 Secret 을 만들고(`--from-literal`, `--from-file`, `secret generic`), Pod 에 환경변수(`valueFrom` 키 참조, `set env --from`)와 볼륨 파일로 주입해 `kubectl exec` 로 확인하는 것에서 시작해, 참조한 ConfigMap 이 없어 `CreateContainerConfigError` 가 난 Pod 를 `describe` 로 진단하고 고치고, ConfigMap 을 고쳐도 환경변수는 그대로라 `rollout restart` 가 필요하다는 것까지 손에 익힌다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. "ConfigMap `app-cfg` 의 `data.LEVEL` 이 `info` 다", "Secret 의 `password` 를 base64 로 풀면 `change-me-123` 이다", "Pod 안에서 `printenv GREETING` 이 `hello-etude` 다", "마운트한 파일의 내용이 `hello-etude` 다", "`describe` 결과 파일에 `CreateContainerConfigError` 와 없는 ConfigMap 이름이 있다" 처럼 클러스터 상태, `kubectl exec` 출력, 저장한 파일 내용을 확인한다. 풀기 전(setup 만 한 상태)에는 모두 실패해야 한다.
- 새 개념은 한 문제에 하나만. from-literal → from-file → secret generic → valueFrom 키 참조 → (secretKeyRef 빈칸) → 볼륨 마운트 → 오류 진단 → 오류 복구 → (환경변수 vs 파일 갱신 개념) → set env --from → 값 바꾸고 rollout restart → 전체 순서로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). ConfigMap·Secret·Pod·Deployment 만 쓴다.
- 이미지는 `busybox:1.36`(Pod)과 `nginx:1.25`(Deployment `api`)만 쓴다. 오브젝트 이름은 ConfigMap `app-cfg`·`file-cfg`·`pay-cfg`, Secret `db-secret`, Pod `envdemo`·`volpod`·`broken`, Deployment `api` 로 고정하고, 각 setup 은 이 이름들만 지운다(`--all` 은 쓰지 않는다).
- Secret 값은 눈에 띄는 연습용 더미(`change-me-123`, `etude`)만 쓴다.
- 일부러 망가뜨린 Pod `broken` 은 없는 ConfigMap `pay-cfg` 를 `configMapKeyRef` 로 참조한다. setup 은 `.status.containerStatuses[0].state.waiting.reason` 이 `CreateContainerConfigError` 가 될 때까지 최대 60초 폴링한다(고정 sleep 에 의존하지 않는다). 8번 복구 채점은 kubelet 의 재시도를 기다리므로 최대 60초 폴링한다.
- Pod·Deployment 안의 값은 `kubectl exec ... printenv` / `cat` 으로 확인하고, 롤링 업데이트 중 옛 Pod 가 걸릴 수 있어 일치할 때까지 폴링한다.
- `--from-file` 문제(2번)는 학습자가 `/tmp/app.properties` 를 직접 만든다(setup 이 파일을 만들어 두는 것에 의존하지 않는다).

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태) |
|---|------|------|----------------|------------|
| 1 | 터미널 | --from-literal 로 ConfigMap 만들기 | `create configmap --from-literal` | `app-cfg` 의 GREETING·LEVEL 값 |
| 2 | 터미널 | --from-file 로 파일째 ConfigMap 만들기 | `--from-file`, 파일 이름이 키 | `file-cfg` 의 `app.properties` 에 두 줄 |
| 3 | 터미널 | create secret generic 으로 Secret 만들기 | `create secret generic`, base64 저장 | `db-secret` 의 user·password 를 풀면 더미 값 |
| 4 | 터미널 | valueFrom 으로 키 하나를 환경변수로 | `env.valueFrom.configMapKeyRef` | 스펙이 키 참조, Pod 안 `GREETING` |
| 5 | 빈칸 | Secret 의 키를 가리키는 필드 | `secretKeyRef` (vs `configMapKeyRef`) | 정답 칩 |
| 6 | 터미널 | ConfigMap 을 볼륨으로 마운트해 파일로 읽기 | `volumes.configMap` + `volumeMounts`, 키가 파일 이름 | 마운트 경로, Pod 안 파일 내용, 저장한 파일 |
| 7 | 터미널 | describe 로 CreateContainerConfigError 원인 찾기 | STATUS 와 describe 의 State·Events | 파일에 `CreateContainerConfigError` 와 `pay-cfg ... not found` |
| 8 | 터미널 | 없는 ConfigMap 만들어 Pod 살리기 | 참조 대상만 채우면 Pod 가 저절로 시작 | `pay-cfg` MODE=live, Pod Ready, Pod 안 `MODE` |
| 9 | 객관식 | ConfigMap 을 고친 뒤 이미 떠 있는 Pod 는 | 파일은 갱신, 환경변수는 재시작 전까지 옛 값 | 정답 보기 |
| 10 | 터미널 | kubectl set env --from 으로 Deployment 에 연결 | `set env deployment/이름 --from=configmap/이름` (envFrom) | `envFrom` 이 `app-cfg` 를 가리킴, 새 Pod 안 GREETING·LEVEL |
| 11 | 터미널 | ConfigMap 을 고치고 rollout restart 로 반영 | patch 후 `rollout restart` 로 환경변수 갱신 | `LEVEL=debug`, envFrom 유지, Pod 안 `LEVEL` |
| 12 | 순서 | 설정 값을 바꿔서 앱에 반영하는 순서 | create → set env → exec → patch → restart → exec | 정답 순서 |

## 기존 세트와의 겹침

- 세트 12 의 1~8번(ConfigMap·Secret 만들기, 내용 확인, env 와 볼륨 주입)과 주제가 가깝다. 이 세트는 만들기를 1·3번에서 짧게 하고, 12번에 없는 `--from-file`, `secretKeyRef`/`configMapKeyRef` 직접 작성, **오류 진단·복구(7·8번)**, `set env --from`, **갱신 동작과 rollout restart(9·11번)** 를 더한다.
- 세트 208 의 9번("ConfigMap 을 고치면 Pod 에는")·12번("없는 ConfigMap 참조"), 132 의 7·8번, 194 의 3·10번과 개념이 겹친다. 이 세트는 같은 개념을 **직접 일으키고 고쳐서 상태로 채점**한다. 9번 객관식은 환경변수와 볼륨을 한 문장에서 비교하는 시나리오로 써서 208 의 9번과 문장을 달리한다. 통합 시 중복 정도를 다시 본다.

## 배치

k8s 단원 7 워크로드와 설정 끝, display_order 261, 아이콘 🧰. 세트 236, `sandbox_type = k8s`, 분야 k8s. 구현: `gen236.py` (gen233.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set236.sql`, `backend/verify/set236.json`, 마이그레이션(세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 236`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 ConfigMap·Secret 값, Pod 안 `printenv`/`cat` 출력, 저장한 파일 내용 같은 **실제 상태**를 확인한다. 존재 여부만 보지 않는다.
- [x] 7·8번 setup 의 Pod `broken` 이 `CreateContainerConfigError` 가 될 때까지 기다린 뒤 끝나고(고정 sleep 없음), 8번 복구가 kubelet 재시도 지연이 있어도 폴링 한도 안에 통과한다.
- [x] 10·11번의 `kubectl exec deploy/api` 확인이 롤링 업데이트 중에도 안정적으로 통과한다 (일치할 때까지 폴링).
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (9번). 빈칸 칩에 정답이 둘이 아니다 (5번).
- [x] 각 터미널 문제 `docs` 에 ConfigMap·Secret·컨테이너 환경 변수 정의 공식 문서 링크가 달려 있다.
- [x] 각 setup 의 정리가 위 고정 이름만 지운다. 다른 세트 문제와 오브젝트 이름이 부딪쳐도 서로 영향이 없다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
