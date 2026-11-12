# 명세 — k8s 리소스 requests·limits 손연습 세트 (set resources · QoS · LimitRange · ResourceQuota)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 세트 351. 근거: 자원 요청·한도는 객관식·빈칸·순서 세트(170, 299, 153, 295, 223, 314)가 개념으로 이미 다루지만, **터미널 손연습은 세트 22 의 6번 하나뿐**이다. 이 세트는 값을 직접 정하고, 읽고, 등급을 바꾸고, 기본값과 쿼터를 **이벤트·상태로 확인**하는 손연습에 집중한다.

## 목표

`kubectl set resources` 와 YAML 로 `requests`/`limits` 를 정하고, jsonpath 로 읽고, Pod 의 `.status.qosClass` 를 읽어 `Guaranteed`/`Burstable` 로 바꾸고, `LimitRange` 가 리소스를 안 쓴 Pod 에 기본값을 채우는 것과 컨테이너 상한(max)을 넘으면 Pod 가 안 생기는 것, `ResourceQuota` 의 Used/Hard 읽기와 쿼터 초과로 일부만 뜨는 Deployment 를 고치는 손버릇을 만든다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. Deployment 템플릿과 Pod 의 `resources`, `qosClass`, 쿼터 상태, 저장한 파일 내용을 확인한다. setup 만 한 상태에서는 채점이 실패해야 한다.
- 새 개념은 한 문제에 하나만. set resources → jsonpath 읽기 → YAML → qosClass 읽기 → (빈칸 qosClass 키) → Guaranteed 로 바꾸기 → LimitRange 기본값 → (객관식 기본값) → 쿼터 Used/Hard → LimitRange max → 쿼터 초과 → (순서) 로 쌓는다.
- **학습자 세션 네임스페이스에는 이미 쿼터 `etude-quota` 와 LimitRange `etude-limits` 가 있고** ([k8s-session.ts](../../backend/src/services/k8s-session.ts)), 학습자는 이를 만들거나 고칠 수 없다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). 그래서 이 세트는 쿼터·LimitRange 를 만들지 않고 **이미 있는 것을 읽고 그 한도 안/밖에서 동작**하게 한다. 채점은 기본값·한도 숫자를 하드코딩하지 않고 클러스터에서 읽은 값과 비교한다 (단일 진실 공급원은 `k8s-session.ts`). 문제의 setup 값(700Mi 등)만 이 한도에 맞춰 둔다: 컨테이너 상한(cpu 1, memory 1Gi) 안이고 쿼터(requests.memory 2Gi) 합계는 넘는다.
- 이 네임스페이스에서는 LimitRange 때문에 **`BestEffort` Pod 를 만들 수 없다** (기본값이 채워져 `Burstable`). 그래서 BestEffort 는 손연습에 넣지 않고 객관식 설명에서만 다룬다. 메모리 limits 초과 `OOMKilled` 는 채점이 불안정해 쓰지 않는다. 자원 부족 `Pending`(FailedScheduling)은 상한(max)·쿼터 때문에 만들 수 없어 넣지 않았다 (세트 223 객관식·세트 314 빈칸이 다룸).
- 이미지는 기존 세트에서 받아지는 `nginx:1.25` 만 쓴다. 학습자 권한은 자기 네임스페이스 `edit` 와 쿼터·LimitRange **조회**다.
- 연습 오브젝트는 라벨 `etude=lab351` 이거나 이름이 `rs351-` 로 시작한다. setup 정리는 이 라벨의 Deployment·Pod 와 고정 이름 Pod(`rs351-plain`, `rs351-yaml`)만 지운다 (`--all` 은 쓰지 않는다). 파일은 `/tmp` 에 두고 setup 이 `/tmp/*.txt` 를 지운다.
- 학습자의 풀이에는 `wait` 가 없다. Pod 교체·복제본 Ready·쿼터 Used 갱신은 **채점이 폴링**한다 (20~90초).

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태·파일) |
|---|------|------|----------------|-----------------|
| 1 | 터미널 | kubectl set resources 로 requests 와 limits 정하기 | `set resources --requests --limits` | `rs351-web` 템플릿 100m/64Mi, 200m/128Mi, 교체된 Pod 하나만 Running |
| 2 | 터미널 | jsonpath 로 메모리 limits 값만 읽어 저장하기 | `-o jsonpath` 로 `resources.limits.memory` | `/tmp/memlimit.txt` 가 Pod 의 현재 값과 같음 |
| 3 | 터미널 | YAML 로 requests 와 limits 가 있는 Pod 만들기 | `resources:` 블록 | `rs351-yaml` 50m/32Mi, 100m/64Mi, Running |
| 4 | 터미널 | Pod 의 QoS 등급 읽어 저장하기 | `.status.qosClass` | `/tmp/qos.txt` 가 Pod 의 qosClass 와 같음 |
| 5 | 빈칸 | QoS 등급 칸을 한 번에 보기 | custom-columns 의 `qosClass` 키 | 정답 칩 (`qosClass`) |
| 6 | 터미널 | requests 와 limits 를 같게 해서 Guaranteed 로 만들기 | requests = limits → Guaranteed | `rs351-gu` 복제본 1, Pod 하나가 Running 이고 Guaranteed |
| 7 | 터미널 | 리소스를 안 쓴 Pod 에 채워진 기본값 읽기 | LimitRange `default`/`defaultRequest` 가 Pod 에 채워짐 | `rs351-plain` Running, memory limits 가 LimitRange default 와 같음, `/tmp/default.txt` 일치 |
| 8 | 객관식 | YAML 에 리소스를 안 썼는데 LimitRange 기본값이 있으면 | 기본값은 생성 시점에 채워짐 | 정답 보기 |
| 9 | 터미널 | ResourceQuota 의 Used 와 Hard 읽어 저장하기 | `describe quota`, `.status.used/.hard` | `/tmp/pods.txt` 가 `사용/한도` 현재 값과 같음 |
| 10 | 터미널 | 컨테이너 상한을 넘어 Pod 가 안 생기는 Deployment 고치기 | LimitRange `max`, ReplicaSet 이벤트 `FailedCreate` | `rs351-over` requests.cpu 그대로, limits.cpu 가 2 가 아님, Pod Running |
| 11 | 터미널 | 쿼터 때문에 일부만 뜨는 Deployment 고치기 | 쿼터 합계 초과(`exceeded quota`), 값 줄이기 | `rs351-fat` 복제본 3 그대로, requests·limits 남김, 700Mi 아님, 3/3/3 Ready |
| 12 | 순서 | QoS 를 Guaranteed 로 바꾸는 순서 | 읽기 → 바꾸기 → 교체 대기 → 다시 읽기 | 정답 순서 `[2, 3, 0, 1]` |

## 기존 세트와의 겹침

- **세트 170·299 (QoS·자원 읽기, 객관식/빈칸/순서)**: QoS 세 등급, `.status.qosClass`, `kubectl set resources` 가 개념 문제로 나온다. 이 세트의 4·5·6·12번과 주제가 겹치지만 **직접 읽어 파일로 저장하고 Pod 를 Guaranteed 로 바꾼 결과**를 채점하는 터미널이라 형식이 다르다. 통합 시 5·12번(빈칸·순서)은 299 와 중복 정도를 다시 본다.
- **세트 153·295 (자원 한도 Quota, LimitRange 객관식·빈칸·순서)**: 쿼터·LimitRange 의 개념, `quota 때문에 Pod 가 안 만들어질 때` 순서가 있다. 이 세트의 8·9·10·11번과 겹치되 **실제 이벤트를 읽고 Deployment 를 고치는 손연습**이다. 겹침이 가장 큰 곳은 8번(객관식)이고, 통합 시 8번을 빼도 된다.
- **세트 223·314 (Pending 원인 읽기)**: `Insufficient cpu` 를 객관식·빈칸으로 다룬다. 이 세트는 학습자가 만들 수 없는 조건이라 Pending 을 넣지 않았다.
- **세트 22 의 6번 (CPU·메모리 requests 와 limits 설정하기)**: 터미널 중 유일하게 겹친다. 1·3번이 같은 도구를 쓰지만, 1번은 `set resources`, 3번은 YAML 로 나눴고 이후 문제가 읽기·등급·기본값·쿼터로 이어진다.
- 새로운 내용: 터미널로 하는 QoS 읽기·Guaranteed 전환, LimitRange 기본값 읽기, max 초과 Deployment 고치기, 쿼터 Used/Hard 읽기와 초과 고치기.

## 배치

단원·display_order 는 통합 시 정함. 아이콘도 통합 시 정함. 세트 351, `sandbox_type = k8s`, 분야 k8s. 구현: `gen351.py` (gen348.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set351.sql`, `backend/verify/set351.json`, 마이그레이션(`2026-11-13_k8s_resources_set351.sql`, 세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 351`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [ ] `checks` 가 Deployment 템플릿·Pod 의 `resources`, `qosClass`, 쿼터 상태, 파일 내용을 확인한다. 존재 여부만 보지 않는다.
- [ ] Pod 교체·복제본 Ready·쿼터 Used 확인이 폴링이라 풀이 직후(wait 없이) 채점해도 통과한다.
- [ ] LimitRange 기본값·쿼터 한도 숫자를 채점에 하드코딩하지 않는다 (클러스터에서 읽어 비교). 세션 네임스페이스의 쿼터·LimitRange 가 있는 상태에서 검증한다.
- [ ] 10번이 requests 를 지운 풀이로는 통과하지 않는다. 11번이 복제본을 줄이거나 resources 를 지운 풀이로는 통과하지 않는다. 6번이 Deployment 를 지워 다시 만든 풀이는 setup 의 Deployment 와 이름만 같아 통과할 수 있으니 통합 시 허용 여부를 정한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (8번). 빈칸 칩에 정답이 둘이 아니다 (5번). 순서 정답 인덱스가 설명과 맞는다 (12번).
- [ ] 각 터미널 문제 `docs` 에 공식 문서 링크가 달려 있다 (링크 200 확인함: manage-resources-containers, quality-service-pod, limit-range, resource-quotas).
- [ ] 각 setup 의 정리가 라벨 `etude=lab351` 과 고정 이름(`rs351-plain`, `rs351-yaml`)만 지운다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
