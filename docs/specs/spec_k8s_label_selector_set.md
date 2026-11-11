# 명세 — k8s 라벨·셀렉터·어노테이션 실습 세트 (라벨 조회·셀렉터 · 붙이기·바꾸기·떼기 · 어노테이션 · 셀렉터로 지우기)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 336. 근거: 라벨 관련 문제는 세트 20(라벨 조회·삭제), 227(Service 안 붙을 때 라벨 고치기), 174·300(label·annotate 퀴즈), 211·310, 217·312 등에 한두 문제씩 흩어져 있고 대부분 객관식이거나 한 가지 명령만 다룬다. 이 세트는 **라벨·셀렉터·어노테이션만을 주제로**, 조회 옵션(`--show-labels`, `-L`, `-l`, `in (...)`, `--field-selector`)부터 `label`(붙이기·`--overwrite`·`키-`), `annotate`, `delete -l` 까지 클러스터 상태와 저장한 파일 내용으로 채점하는 실습으로 채운다.

## 목표

Pod 의 라벨을 여러 방식으로 보고(`--show-labels`, `-L`), 라벨 셀렉터(`-l key=value`, `-l 'key in (a,b)'`)와 필드 셀렉터(`--field-selector status.phase=Running`)로 원하는 Pod 만 고르고, `kubectl label` 로 라벨을 붙이고 바꾸고 떼고, `kubectl annotate` 로 어노테이션을 달고, Service 의 selector 가 라벨만 본다는 것을 이해하고, 라벨 셀렉터로 Pod 를 한 번에 지우는 것까지 손에 익힌다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. "저장한 파일에 `LABELS` 열과 `app=web` 이 있다", "`/tmp/web.txt` 에 `pod/lab-web1`·`pod/lab-web2` 가 있고 다른 Pod 는 없다", "Pod `lab-api` 의 `.metadata.labels.version` 이 `v2` 다", "`lab-cache` 의 `debug` 라벨이 없고 다른 라벨은 그대로다", "어노테이션 `owner` 가 `ops-team` 이고 라벨로는 안 붙었다", "`env=dev` Pod 가 사라지고 나머지는 남아 있다" 처럼 상태·파일 내용을 확인한다. 풀기 전(setup 만 한 상태)에는 모두 실패해야 한다.
- 새 개념은 한 문제에 하나만. `--show-labels` → `-L` → `-l 키=값`(+`-o name`) → `in (a,b)` → (`--field-selector` 빈칸) → `label` 붙이기 → `--overwrite` → `키-` 로 떼기 → `annotate` → (Service selector 객관식) → `delete -l` → 전체 순서로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Pod 조회·라벨·어노테이션·삭제만 쓴다.
- 이미지는 `busybox:1.36` 만 쓴다. 연습용 Pod 5개를 setup 이 만든다(`kubectl run ... --restart=Never --labels=... -- sleep 3600`, `kubectl wait --for=condition=Ready`로 대기).

  | Pod | 라벨 |
  |-----|------|
  | `lab-web1` | `app=web,tier=front,env=prod` |
  | `lab-web2` | `app=web,tier=front,env=dev` |
  | `lab-api` | `app=api,tier=back,env=prod` |
  | `lab-db` | `app=db,tier=back,env=prod` |
  | `lab-cache` | `app=cache,tier=back,env=dev,debug=true` |

  전부 `etude=lab336` 라벨이 더 붙는다. setup 의 정리는 `-l etude=lab336` 로 지우고, 라벨이 변했을 경우를 대비해 위 고정 이름으로도 한 번 더 지운다(`--all` 은 쓰지 않는다).
- 파일은 학습자가 직접 `>` 로 만든다(`/tmp/labels.txt`, `columns.txt`, `web.txt`, `inset.txt`). setup 이 `/tmp/*.txt` 를 지워 둔다.
- 라벨 값 검증은 `-o jsonpath='{.metadata.labels.키}'` 로 하고 `kubectl` 플래그의 부수 효과에 기대지 않는다. Pod 를 지우는 문제(11번)는 종료 유예(30초)를 기다리지 않도록 "없거나 `deletionTimestamp` 가 있다" 를 사라진 것으로 본다.
- 안 건드려야 할 Pod 의 라벨이 그대로인지도 같이 본다(범위 밖 변경 방지). 존재 확인과 값 확인을 함께 해서 Pod 가 없을 때 빈 값이 우연히 통과하지 않게 한다.

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태) |
|---|------|------|----------------|------------|
| 1 | 터미널 | --show-labels 로 Pod 의 라벨 보기 | `get pods --show-labels` | 파일에 LABELS 열, `lab-web1` 의 `app=web`, `lab-db` 의 `tier=back` |
| 2 | 터미널 | -L 로 라벨 값을 열로 펼치기 | `get pods -L app,env` | 파일 헤더 APP·ENV, `lab-web2` web/dev, `lab-db` db/prod |
| 3 | 터미널 | -l 로 라벨이 같은 Pod 만 고르기 | `-l app=web`, `-o name` | `/tmp/web.txt` 에 web 두 개만 |
| 4 | 터미널 | -l 'key in (a,b)' 로 여러 값 중 고르기 | 집합 기반 셀렉터 | `/tmp/inset.txt` 에 web·api 만 |
| 5 | 빈칸 | --field-selector 로 상태가 Running 인 Pod 만 | `status.phase=Running` | 정답 칩 |
| 6 | 터미널 | kubectl label 로 라벨 붙이기 | `label pod 이름 키=값` | `lab-api` 의 `version=v2`, 다른 Pod 에는 없음 |
| 7 | 터미널 | --overwrite 로 라벨 값 바꾸기 | 있는 키는 `--overwrite` | `lab-web2` 의 `env=prod`, 나머지 라벨 그대로 |
| 8 | 터미널 | 라벨 이름 뒤에 - 를 붙여 라벨 떼기 | `label pod 이름 키-` | `lab-cache` 의 `debug` 없음, 나머지 라벨 그대로 |
| 9 | 터미널 | kubectl annotate 로 어노테이션 달기 | `annotate pod 이름 키=값`, 라벨과 구분 | 어노테이션 `owner=ops-team`, 라벨 아님, `-l owner=...` 결과 없음 |
| 10 | 객관식 | Service 의 selector 는 어떤 Pod 를 고를까 | 라벨만 본다, 다른 라벨이 더 있어도 됨 | 정답 보기 |
| 11 | 터미널 | -l 로 골라서 한 번에 지우기 | `delete pods -l env=dev` | `lab-web2`·`lab-cache` 사라짐, 나머지 남음 |
| 12 | 순서 | 라벨로 골라서 안전하게 지우는 순서 | show-labels → get -l → delete -l → get -l → show-labels | 정답 순서 |

## 기존 세트와의 겹침

- 세트 20 의 4·6·7번(라벨 붙이기, 라벨로 조회, 라벨로 삭제), 227 의 3·4번(Pod 라벨 보기·`label` 로 고치기), 25·23 의 셀렉터 문제와 개념이 겹친다. 이 세트는 **`-L`, `in (...)`, `--field-selector`, `--overwrite`, `키-` 로 떼기, `annotate` 와 라벨의 구분** 을 따로 한 문제씩 다루고 모든 문제를 상태·파일로 채점한다. 세트 174·300(label·annotate 퀴즈)과는 퀴즈형이라 채점 방식이 다르다. 통합 시 중복 정도를 다시 본다.
- 새로 만든 객관식(10번)은 Service 셀렉터 개념이 227·303 과 겹치므로 문장을 "이름·어노테이션·추가 라벨" 비교로 써서 다르게 했다.

## 배치

k8s 단원 6 기초 끝, display_order 218, 아이콘 🏷️. 세트 336, `sandbox_type = k8s`, 분야 k8s. 구현: `gen336.py` (gen236.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set336.sql`, `backend/verify/set336.json`, 마이그레이션(세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 336`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 라벨·어노테이션 값, 저장한 파일 내용, 남은 Pod 같은 **실제 상태**를 확인한다. 존재 여부만 보지 않는다.
- [x] setup 이 Pod 5개를 만들고 모두 Ready 가 된 뒤 끝난다. 같은 이름 Pod 가 지워지는 중이어도 다시 setup 해서 재현된다(정리가 삭제 완료까지 기다린다).
- [x] 11번 채점이 종료 유예(30초) 때문에 늦지 않는다 (`deletionTimestamp` 허용).
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (10번). 빈칸 칩에 정답이 둘이 아니다 (5번). 순서 정답 인덱스가 설명과 맞는다 (12번).
- [x] 각 터미널 문제 `docs` 에 라벨·어노테이션·필드 셀렉터 공식 문서 링크가 달려 있다 (링크 200 확인함).
- [x] 각 setup 의 정리가 `etude=lab336` 라벨과 고정 Pod 이름만 지운다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
