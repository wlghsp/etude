# 명세 — k8s Service 손연습 세트 (expose · 엔드포인트 · 셀렉터 · targetPort · 헤드리스 · DNS 호출)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 세트 348. 근거: 세트 25·37·227·186·303 이 Service 의 개념, 엔드포인트 읽기, targetPort 고치기, 이름으로 접근을 이미 다룬다. 이 세트는 그 도구를 **다른 목적**으로 쓰는 손연습에 집중한다: Pod 를 `expose` 하기, `--port`/`--target-port` 를 다르게 주기, EndpointSlice 로 연결된 Pod 세기, Pod 라벨로 비어 버린 엔드포인트 고치기, Running 이어도 Ready 가 아니면 빠지는 것, 일회용 Pod 로 이름 호출해 응답 저장, `expose --cluster-ip=None`, 헤드리스 DNS 조회, 셀렉터 전환(블루/그린)과 확인.

## 목표

`kubectl expose` 로 Service 를 만들고, 그 Service 가 어느 Pod 를 고르는지 엔드포인트와 EndpointSlice 로 읽고, 연결이 안 될 때 라벨·셀렉터·준비 상태를 따져 고치고, 클러스터 안의 일회용 Pod 에서 Service **이름**으로 호출해 확인하는 손버릇을 만든다. 12문제, 쉬운 것부터. `kubectl port-forward` 는 채점할 수 없어서 쓰지 않는다.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. Service 의 `type`·`port`·`targetPort`·`selector`·`clusterIP`, 엔드포인트 주소와 포트, Pod 라벨과 Ready 상태, 저장한 응답·조회 파일의 내용을 확인한다. setup 만 한 상태에서는 채점이 실패해야 한다.
- 새 개념은 한 문제에 하나만. Pod expose → port/targetPort → EndpointSlice 세기 → 라벨 오타로 빈 엔드포인트 → (빈칸 NodePort) → Ready 아닌 Pod → (객관식 세 포트의 길) → 이름으로 호출 → 헤드리스 만들기 → 헤드리스 DNS → 셀렉터 전환 → (순서) 로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Pod·Deployment·Service·Endpoints·EndpointSlice 의 조회·갱신, `exec`, `kubectl run` 을 쓴다. NodePort 는 **번호를 고정하지 않는다** (클러스터 전체에서 번호가 겹칠 수 있다).
- 응답하는 Pod 는 `busybox:1.36` 의 `httpd` 가 `8080` 에서 정해진 글자를 돌려준다 (이미지는 기존 세트에서 받아지는 것만 쓴다). 응답이 Pod 마다 다르므로 일회용 Pod 로 실제 호출한 결과만 파일 채점을 통과한다.
- 연습 오브젝트는 라벨 `etude=lab348` 이거나 이름이 `sv348-` 로 시작한다. setup 정리는 이 라벨의 Deployment·Pod 와 고정 이름 Service 만 지운다 (`--all` 은 쓰지 않는다). 파일은 `/tmp` 에 두고 setup 이 `/tmp/*.txt` 를 지운다.
- 학습자의 풀이에는 `wait` 가 없다. 엔드포인트 주소 개수와 Ready 상태는 **채점이 최대 40초 폴링**한다 (readinessProbe 주기 2초 포함). 일회용 Pod 가 남지 않았는지는 최대 20초 폴링한다.
- `kubectl run --rm -i` 는 응답 뒤에 `pod "..." deleted` 한 줄을 같은 출력에 붙이므로, 파일은 **정확히 일치가 아니라 포함 여부**(`grep`)로 채점한다. IP 주소와 도메인 이름은 문제 글에 적지 않는다.

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태·파일) |
|---|------|------|----------------|-----------------|
| 1 | 터미널 | Pod 하나를 expose 로 Service 에 연결하기 | `expose pod`, 셀렉터는 Pod 라벨에서 | `sv348-solo-svc` ClusterIP, 포트 8080, 셀렉터 `run=sv348-solo`, 엔드포인트 1 |
| 2 | 터미널 | expose 로 받는 포트와 Pod 포트를 다르게 하기 | `--port=80 --target-port=8080` | port 80, targetPort 8080, 엔드포인트 2 개 (포트 8080) |
| 3 | 터미널 | EndpointSlice 로 연결된 Pod 개수 세기 | `get endpointslices -l kubernetes.io/service-name=` | `/tmp/count.txt` 가 `3` (Deployment 둘이 한 Service 에 합류) |
| 4 | 터미널 | 엔드포인트가 비어 있을 때 Pod 라벨로 고치기 | `kubectl label --overwrite`, Service 는 두고 Pod 를 고침 | Service 셀렉터 그대로, 두 Pod 라벨 `app=sv348-blue`, 엔드포인트 2 |
| 5 | 빈칸 | 클러스터 밖에서도 노드 포트로 열 Service 유형 | `--type=NodePort` | 정답 칩 (`NodePort`) |
| 6 | 터미널 | Running 인데 엔드포인트에서 빠진 Pod 를 들어오게 하기 | Ready 가 아니면 `notReadyAddresses`, `exec` 로 준비시키기 | Service 그대로, `sv348-rd2` 재시작 0 이고 Ready, 엔드포인트 2 |
| 7 | 객관식 | NodePort Service 에서 세 포트는 어떻게 이어질까 | nodePort → port → targetPort 의 길 | 정답 보기 |
| 8 | 터미널 | Service 이름으로 임시 Pod 에서 호출해 응답 저장하기 | `kubectl run --rm -i --restart=Never` + `wget -qO-` | `/tmp/resp.txt` 에 응답 글자 포함, 남은 일회용 Pod 없음 |
| 9 | 터미널 | expose 로 헤드리스 Service 만들기 | `expose --cluster-ip=None` | clusterIP `None`, 셀렉터·포트, 엔드포인트 3 |
| 10 | 터미널 | 헤드리스 Service 의 DNS 는 Pod IP 를 모두 돌려준다 | 일회용 Pod 의 `nslookup` | `/tmp/lookup.txt` 에 Pod 3개의 IP 와 Service 이름 |
| 11 | 터미널 | Service 셀렉터를 바꿔 새 버전으로 넘기고 확인하기 | `patch` 로 셀렉터 전환 + 호출 확인 | 셀렉터 `version=v2`, 엔드포인트가 v2 Pod IP 와 일치, `/tmp/after.txt` 에 v2 응답만, 남은 일회용 Pod 없음 |
| 12 | 순서 | Service 로 연결이 안 될 때 살펴보는 순서 | service → endpoints → 라벨 비교 → 고치기 → 호출 확인 | 정답 순서 `[3, 1, 4, 0, 2]` |

## 기존 세트와의 겹침

- **세트 25 (가장 크게 겹침)**: 1번(NodePort `expose`), 4번(임시 Pod 로 이름 호출 후 저장), 9번(Headless Service 만들기), 10번(셀렉터 바꾸기)과 도구가 같다. 이 세트의 8번은 같은 호출이되 **포트 매핑이 있는 Service 와 일회용 Pod 정리까지** 채점하고, 9번은 YAML 이 아니라 `expose --cluster-ip=None`, 10번은 **조회 결과의 Pod IP 를 실제 Pod 와 대조**, 11번은 셀렉터 바꾸기에 **호출로 새 버전 확인**을 더했다.
- **세트 37**: 4번(임시 Pod 로 이름 호출)과 7번(port 와 targetPort 로 Service 만들기)이 8번과 2번에 가깝다. 2번은 `expose` 옵션, 8번은 응답 파일과 정리 채점이 다르다.
- **세트 227**: 1번(엔드포인트 보기), 9번(targetPort 고치기), 11번(원인이 둘 겹친 Service)과 4번·6번이 개념상 인접하다. 4번은 **Pod 라벨을 고치는 쪽**, 6번은 라벨이 맞아도 **Ready 가 아니라서 빠지는 경우**다.
- **세트 6·19**: `expose` 로 Deployment 노출하기와 2번이 닮았다 (2번은 port 와 targetPort 를 다르게 줌).
- 새로운 내용: `expose pod`, EndpointSlice 로 세기, 헤드리스 DNS 조회 결과 대조, 블루/그린 셀렉터 전환과 확인. 통합 시 중복 정도를 다시 본다 (특히 8번과 세트 25·37 의 4번).

## 배치

단원·display_order 는 통합 시 정함. 아이콘도 통합 시 정함. 세트 348, `sandbox_type = k8s`, 분야 k8s. 구현: `gen348.py` (gen345.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set348.sql`, `backend/verify/set348.json`, 마이그레이션(`2026-11-13_k8s_service_set348.sql`, 세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 348`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [ ] `checks` 가 Service 필드, 엔드포인트 주소·포트, Pod 라벨과 Ready, 파일 내용을 확인한다. 존재 여부만 보지 않는다.
- [ ] 엔드포인트와 Ready 확인이 최대 40초 폴링이라 풀이 직후(wait 없이) 채점해도 통과한다.
- [ ] 4번이 Service 셀렉터를 바꾼 풀이로는 통과하지 않는다. 6번이 Pod 를 지워 다시 만든 풀이로는 통과하지 않는다 (재시작 0 과 Service 불변 확인). 11번이 셀렉터만 바꾸고 호출 확인 파일이 없으면 통과하지 않는다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (7번). 빈칸 칩에 정답이 둘이 아니다 (5번). 순서 정답 인덱스가 설명과 맞는다 (12번).
- [ ] 각 터미널 문제 `docs` 에 공식 문서 링크가 달려 있다 (링크 200 확인함: service, kubectl_expose, endpoint-slices, dns-pod-service, connect-applications-service).
- [ ] 각 setup 의 정리가 라벨 `etude=lab348` 과 고정 이름(`sv348-*`)만 지운다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
