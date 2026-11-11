# 명세 — k8s Service 연결 안 될 때 원인 좁히기 세트 (Endpoints · selector · targetPort · readiness)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 227. 근거: 세트 186 `Service 와 Endpoints 심화` 는 객관식·빈칸·순서 29문제로 "읽고 맞히기"뿐이고 터미널 문제가 0개다. 이 세트는 같은 주제를 **직접 고쳐 보는 실습**으로 채운다. 인접 세트: 166(NetworkPolicy, 접속이 막히는 정책), 223(Pending 원인), 220(재시작 정책)은 원인 범위가 다르다.

## 목표

Service 에 접속이 안 될 때 **Endpoints 를 보고 원인을 좁히는** 손버릇을 만든다. 결과(Endpoints)를 먼저 보고, Service 쪽(selector, targetPort)과 Pod 쪽(라벨, READY)을 비교해 어긋난 곳을 직접 고친 뒤, Endpoints 에 주소가 채워졌는지로 확인한다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. "Service `web` 의 Endpoints 에 Pod 주소가 있다", "selector 가 `app=web` 이다", "Endpoints 포트가 80 이다" 처럼 클러스터 상태를 확인한다. 읽기 문제(1~3, 7번)는 결과 파일의 내용을 확인한다.
- 새 개념은 한 문제에 하나만. 한 가지 고장 → 고치는 도구 순서로 쌓는다(라벨 고치기 → selector 고치기 → 준비 안 된 Pod → targetPort → 겹친 원인).
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Pod·Service·Endpoints 만 쓴다.
- 이미지는 `nginx`, `busybox` 만 쓴다.
- 각 문제의 setup 은 앞선 문제의 흔적을 지우고(`delete pod,svc,deploy --all`) 같은 이름으로 다시 만든다. 일부러 Ready 가 아닌 Pod(8번)는 Ready 가 아니라 `Running` 을 기다린다.
- 채점의 Endpoints 확인은 반영 지연을 고려해 최대 10~15초 다시 확인한다(`poll`).
- 8번은 Pod 안에 `/tmp/ready` 파일이 있어야 통과하는 `exec` readinessProbe 를 쓴다(Pod 의 probe 는 고칠 수 없어서, 파일을 만들어 통과시키는 방식).

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | Endpoints 로 연결 상태 보기 | `kubectl get endpoints web`, ENDPOINTS 칸 |
| 2 | 터미널 | describe svc 에서 Selector 와 TargetPort 읽기 | `describe svc` 의 Selector·TargetPort |
| 3 | 터미널 | Pod 라벨 보기 | `get pods --show-labels`, selector 와 라벨 비교 |
| 4 | 터미널 | kubectl label 로 Pod 라벨 고치기 | `kubectl label ... --overwrite` |
| 5 | 빈칸 | selector 를 고치는 patch | `kubectl patch svc` 의 selector JSON |
| 6 | 터미널 | kubectl patch 로 selector 고치기 | Service 쪽을 고치기 |
| 7 | 터미널 | -l 로 Service 가 고르는 Pod 만 모으기 | `-l a=b,c=d` (둘 다 맞아야 함) |
| 8 | 터미널 | Ready 가 아닌 Pod 를 Ready 로 만들기 | READY 0/1, readiness 실패, Ready 가 아니면 Endpoints 에서 빠짐 |
| 9 | 터미널 | targetPort 가 틀린 Service 고치기 | Endpoints 에 주소는 있는데 포트가 틀린 경우 |
| 10 | 객관식 | Endpoints 가 비었는데 Pod 는 1/1 Running | 원인 우선순위(selector 불일치) |
| 11 | 터미널 | 문제가 두 개 겹친 Service 고치기 | 일부 Pod 만 빠지고 포트도 틀림, 하나씩 고치며 재확인 |
| 12 | 순서 | 연결 안 될 때 원인 좁히는 순서 | Endpoints → describe svc → show-labels → 고치기 → 재확인 |

## 배치

k8s 단원 9 운영과 트러블슈팅 끝, display_order 331, 아이콘 🩺. 세트 227, `sandbox_type = k8s`, 분야 k8s, 아이콘도 통합 시 정함. 구현: `gen227.py` (예시 생성기 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set227.sql`, `backend/verify/set227.json`, 마이그레이션(세트 INSERT 와 문제 INSERT 만)을 만든다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 227`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 파일 내용·Service selector·Pod 라벨·Endpoints 주소와 포트 같은 **실제 상태**를 확인한다. 존재 여부만 보지 않는다.
- [x] 8번 setup 이 Ready 를 기다리지 않아도 안정적으로 끝나고(`Running` 만 대기), 해결 후 채점이 15초 안에 통과한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (10번: selector 와 라벨 불일치).
- [x] 각 문제 `docs` 에 Service 디버깅·Service·라벨·readiness 공식 문서 링크가 달려 있다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
