# 명세 — k8s YAML 작성 워크플로 실습 세트 (dry-run 뼈대 → 편집 → diff → apply → delete -f)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 342. 근거: 세트 19(1·2·8번)가 `--dry-run=client -o yaml` 뼈대, 파일 저장 후 apply, `explain imagePullPolicy` 를 이미 다룬다. 세트 26 의 10번은 `kubectl diff`, 세트 46 은 YAML 구조·dry-run 개념 퀴즈, 세트 211·310 은 diff·apply 출력 퀴즈다. 이 세트는 **뼈대를 만든 뒤 "파일을 고치는" 단계**(replicas·라벨·env·resources 를 `sed`/heredoc 으로 수정)와 파일 단위 작업(여러 오브젝트를 한 파일에 묶기, `delete -f`, 실행 중인 오브젝트 갱신, `get -o yaml | grep`)을 **파일 내용과 클러스터 상태**로 채점한다.

## 목표

실무와 시험에서 쓰는 YAML 작업 흐름을 몸에 익힌다. `kubectl run`/`create ... --dry-run=client -o yaml > 파일` 로 뼈대를 만들고, 파일을 고치고(`sed`, heredoc, 편집기), `kubectl diff -f` 로 차이를 보고, `kubectl apply -f` 로 적용하고, `kubectl explain` 으로 필드를 찾고, `get -o yaml | grep` 으로 실제 값을 확인하고, `delete -f` 로 파일 기준으로 지운다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. 저장한 YAML 의 내용(`kind`, 이름, 라벨, 포트, `replicas`)과 클러스터 상태(`replicas`, 템플릿 라벨, env, `resources`, Service 포트, ConfigMap 데이터)를 둘 다 확인한다. 풀기 전(setup 만 한 상태)에는 모두 실패해야 한다.
- 새 개념은 한 문제에 하나만. 뼈대 + 옵션(`run --labels --port`) → (빈칸 `create deployment --replicas`) → `sed` 로 replicas 수정 후 apply → `kubectl diff` → 라벨·env 추가 → (객관식 빈 값 줄) → `explain` 경로 → resources 를 채워 실행 중인 Deployment 갱신 → 여러 오브젝트 한 파일 → `get -o yaml | grep` → `delete -f` → (순서) 로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Pod·Deployment·Service·ConfigMap 의 조회·생성·갱신·삭제만 쓴다. 이미지는 `nginx` 만 쓴다.
- 연습 오브젝트 이름은 고정(`yw-pod`, `yw-web`, `yw-api`, `yw-cfg`, `yw-svc`, `yw-old-web`, `yw-old-svc`, `yw-old-cfg`, `yw-keep`)이다. setup 정리는 **이 이름만** 지운다 (`--all` 은 쓰지 않는다). 파일은 `/tmp` 에 두고 setup 이 `/tmp/*.yaml`, `*.txt`, `/tmp/uid342` 를 지운다.
- 학습자의 풀이에는 `wait` 가 없다. Deployment 롤아웃 확인은 `updatedReplicas-readyReplicas-replicas` 가 `n-n-n` 이 될 때까지 **채점이 최대 40초 폴링**한다.
- 기본 ServiceAccount 가 volumeMount 를 붙이므로 volumeMounts 는 검사하지 않는다. `kubectl` 부수 효과가 아니라 관찰 가능한 값(`jsonpath`)과 파일 내용만 본다. "다시 만들지 않고 갱신했다"는 setup 이 `/tmp/uid342` 에 적은 uid 와 비교한다.
- `kubectl diff` 는 차이가 있으면 종료 코드 1 이다. 4번은 출력을 `>` 로 저장하는 형태라 종료 코드와 무관하게 채점한다.
- 시작 YAML 은 `kubectl create deployment --dry-run=client -o yaml` 이 만드는 모양(`creationTimestamp: null`, `strategy: {}`, `resources: {}`, `status: {}` 포함)과 같게 setup 이 heredoc 으로 쓴다. 들여쓰기가 고정이라 `sed` 풀이가 가능하다.

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태·파일) |
|---|------|------|----------------|-----------------|
| 1 | 터미널 | --dry-run=client 로 Pod YAML 을 파일로 만들기 | `run --labels --port --dry-run=client -o yaml > 파일` | `/tmp/pod.yaml` 에 `kind: Pod`, `yw-pod`, `nginx`, `tier: front`, `containerPort: 8080`. 클러스터에 Pod 없음 |
| 2 | 빈칸 | create deployment 에 복제본 수 미리 넣기 | `create deployment --replicas=3` | 정답 칩 |
| 3 | 터미널 | sed 로 YAML 의 replicas 를 고쳐 apply 하기 | `sed -i` 로 파일 수정 후 `apply -f` | 파일 `replicas: 3`, Deployment replicas 3, 3-3-3 Ready |
| 4 | 터미널 | kubectl diff 로 적용 전에 차이 미리 보기 | `diff -f 파일 > 파일` | `/tmp/diff.txt` 에 `-  replicas: 2`, `+  replicas: 4`. 클러스터 replicas 는 그대로 2 |
| 5 | 터미널 | YAML 에 라벨과 env 를 추가해 apply 하기 | 템플릿 라벨·`env` 의 위치와 들여쓰기 | 템플릿 라벨 `tier=web`, env `APP_MODE=prod`, 2-2-2 Ready |
| 6 | 객관식 | YAML 속 creationTimestamp: null 과 status: {} 는? | 빈 값 줄은 자리표시 값이라 그대로 apply 해도 된다 | 정답 보기 |
| 7 | 터미널 | kubectl explain 으로 resources 필드 찾기 | `explain pod.spec.containers.resources` | `/tmp/explain.txt` 에 `resources`, `limits`, `requests` |
| 8 | 터미널 | YAML 의 resources: {} 를 채워 실행 중인 Deployment 갱신하기 | 같은 이름에 `apply` 하면 갱신 | requests `cpu 50m`·`memory 32Mi`, limits `memory 64Mi`, uid 동일, 1-1-1 Ready |
| 9 | 터미널 | ConfigMap 과 Service YAML 을 한 파일로 묶어 한 번에 적용하기 | `create configmap/service --dry-run=client -o yaml`, `---` 로 한 파일에 묶기 | 파일에 `---`·`kind: ConfigMap`·`kind: Service`, ConfigMap `MODE=prod`, Service `80-80` |
| 10 | 터미널 | get -o yaml 과 grep 으로 실제 env 값 읽기 | `get -o yaml \| grep -A1` | `/tmp/mode.txt` 가 `blue-42`. Deployment 유지 |
| 11 | 터미널 | delete -f 로 파일에 적힌 오브젝트만 한 번에 지우기 | `delete -f 파일` | 파일의 세 오브젝트 삭제, `yw-keep` 남음, 파일 유지 |
| 12 | 순서 | YAML 로 작업하는 순서 | dry-run 뼈대 → 편집 → diff → apply → get | 정답 순서 |

## 기존 세트와의 겹침

- 세트 19: 1번(Pod 뼈대 저장), 2번(Deployment 뼈대 저장 후 apply), 8번(`explain imagePullPolicy`)과 시작점이 같다. 이 세트는 **저장한 파일을 고치는 단계**(3·5·8번), 옵션으로 라벨·포트 지정(1번), 다른 필드 경로(7번), 여러 오브젝트 묶기(9번), `delete -f`(11번)가 새롭다. 세트 26 의 10번(`kubectl diff` 미리 확인)은 4번과 개념이 겹치지만 4번은 **출력을 파일에 저장해 내용으로 채점**한다. 세트 46·211·310 은 퀴즈형이다. 통합 시 중복 정도를 다시 본다.
- `get -o yaml | grep`, 실행 중인 Deployment 를 파일로 갱신(`resources`), `delete -f` 는 기존 터미널 세트에서 찾지 못했다.

## 배치

k8s 단원 6 기초 끝, display_order 219, 아이콘 📄. 세트 342, `sandbox_type = k8s`, 분야 k8s. 구현: `gen342.py` (gen339b.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set342.sql`, `backend/verify/set342.json`, 마이그레이션(`2026-11-13_k8s_yaml_workflow_set342.sql`, 세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 342`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 YAML 파일의 실제 내용과 클러스터 상태(`replicas`, 라벨, env, `resources`, Service 포트, ConfigMap 데이터)를 확인한다. 존재 여부만 보지 않는다.
- [x] 롤아웃 확인이 최대 40초 폴링이라 `apply` 직후 채점해도 통과한다.
- [x] 4번: `kubectl diff` 가 샌드박스에서 동작하고(`diff` 명령 존재, `edit` 권한으로 서버 dry-run 가능) 종료 코드 1 이어도 파일 저장이 채점된다.
- [x] 8번이 "지우고 새로 만들기"로 통과하지 않는다 (uid 동일 확인). 11번이 `--all` 같은 넓은 삭제로 `yw-keep` 을 지우면 실패한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (6번). 빈칸 칩에 정답이 둘이 아니다 (2번). 순서 정답 인덱스가 설명과 맞는다 (12번).
- [x] 각 터미널 문제 `docs` 에 공식 문서 링크가 달려 있다 (링크 200 확인함: quick-reference, kubectl_explain, declarative-config, deployment, configmap).
- [x] 각 setup 의 정리가 고정 이름 오브젝트만 지운다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
