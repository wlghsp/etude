# 명세 — k8s 출력 뽑아내기 세트 (jsonpath · custom-columns · sort-by)

> 상태: **초안** (2026-11-11). 근거: 사용자 질문("KodeKloud 에서는 JSON 읽는 훈련을 많이 하던데 그건 없나?"). 현재는 `jsonpath`·`custom-columns` 가 세트 12·19·20·25·26·33·37 에 문제 하나씩 흩어져 있고(터미널 문제 15개), 이것만 집중해서 반복하는 세트는 없다. 갭 분석: [spec_k8s_cka_gap_analysis.md](spec_k8s_cka_gap_analysis.md).

## 목표

`kubectl get -o json` 이 주는 JSON 의 **구조를 읽고 원하는 값만 뽑는** 손버릇을 만든다. 실무(스크립트, 장애 때 이미지·노드·IP 확인)와 CKA 형식 시험에서 매번 나오는 기술이다. 세트 하나에서 쉬운 것부터 차례로 12문제.

## 원칙

- 모두 **터미널 실습**이고 채점은 결과 파일(`/tmp/*.txt`)의 내용으로 한다 (기존 k8s 세트와 같은 방식, `jq` 는 이미지에 없으므로 쓰지 않는다).
- 새 개념은 한 문제에 하나만. 앞 문제의 표현을 다음 문제가 한 칸씩 확장한다 (피드백 #7: 배우기 전에 푸는 순서 문제를 피한다).
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). 노드·네임스페이스 조회는 쓰지 않고 Pod·Deployment·Secret·ConfigMap 만 쓴다.
- `jsonpath` 출력은 끝에 줄바꿈이 없다. 첫 문제 힌트에서 이를 알리고(`; echo` 또는 `> 파일` 후 `cat`), 셸은 줄바꿈 없는 출력 뒤에도 프롬프트가 줄 처음에 나오게 고쳐져 있다 (피드백 #12).
- 이미지는 `nginx`, `busybox` 만 쓴다 (노드 캐시 공유, 서버 부담 최소).

## 세트 구성 (12개, 안)

| # | 제목 | 새로 익히는 것 | 결과 예 |
|---|------|----------------|---------|
| 1 | JSON 구조 눈으로 보기 | `-o json`, `items` 목록 안의 `metadata`·`spec`·`status` | 파일에 저장 후 읽기 |
| 2 | 첫 번째 Pod 이름만 | `-o jsonpath='{.items[0].metadata.name}'` | 이름 1개 |
| 3 | 모든 Pod 이름을 한 줄로 | `{.items[*].metadata.name}` | 공백으로 이어진 이름 |
| 4 | 한 줄에 하나씩 | `{range .items[*]}…{"\n"}{end}` | 줄 단위 이름 |
| 5 | 이름과 이미지를 같이 | range 안에 필드 두 개, `{"\t"}` | `이름<TAB>이미지` |
| 6 | 단일 객체의 깊은 경로 | `get deploy X -o jsonpath='{.spec.template.spec.containers[0].image}'` | 이미지 1개 |
| 7 | 레이블 값 뽑기 | `{.metadata.labels.app}`, 점 있는 키는 `\.` 로 | 레이블 값 |
| 8 | 조건으로 고르기 | `{.items[?(@.status.phase=="Running")].metadata.name}` | Running 인 Pod 만 |
| 9 | 표로 보기 | `-o custom-columns=NAME:.metadata.name,IMAGE:…` | 제목 줄 포함 표 |
| 10 | 정렬해서 보기 | `--sort-by=.metadata.creationTimestamp` | 오래된 순 이름 |
| 11 | Secret 값 풀어 읽기 | `{.data.password}` → `base64 -d` | 평문 한 줄 |
| 12 | 종합: 이미지 목록 정리 | 앞의 것 조합 + `sort -u` | 중복 없는 이미지 목록 |

- 1~2번은 도움을 많이 준다(`-o json` 을 먼저 저장해 구조를 보고, 거기서 경로를 한 칸씩 따라가도록). 11·12번은 힌트에서 단계를 나눈다.
- 한 번 풀면 같은 경로 읽기가 다른 리소스(Service, Node)에도 통한다는 점을 해설 한 줄로 짚는다 (다른 문제 종류 객관식은 넣지 않는다. 터미널 문제만).

## 배치

- 분야 k8s, 단원 **6 기초**의 `kubectl 속도와 실전`(세트 19) 뒤 (jsonpath 첫 접촉이 세트 19·20 이므로 그 다음). 세트 번호·`display_order` 는 새 세트를 만들 때 정한다 ([spec_units.md](spec_units.md)). 아이콘은 새로 고른다.
- 세트 종류: `sandbox_type = k8s`, `time_limit_sec` 없음, 첫 완료 XP 는 같은 크기의 k8s 터미널 세트와 같다.
- 구현: `scripts/content-gen/example_practice_set.py` 를 복사해 만든다 (예시를 직접 실행하지 않는다). `backend/db/03_quest_setN.sql`, 마이그레이션, `backend/verify/setN.json`.

## 수용 조건

- [ ] 12문제 모두 `solution` 을 그대로 실행하면 채점이 통과한다 (`verify` 스크립트).
- [ ] 12문제 모두 풀이를 하지 않고 setup 만 한 상태에서는 채점이 실패한다 (거짓 통과 없음).
- [ ] 각 문제의 `checks` 가 결과 파일의 **내용**(이름·이미지·정렬 순서)을 확인한다. 파일이 존재하는지만 보지 않는다.
- [ ] 각 문제 `docs` 에 해당 문법의 공식 문서 링크가 달려 있다 (kubernetes.io jsonpath / kubectl 참조).
- [ ] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 홈 k8s 탭 `기초` 단원에 보이고, 1번부터 12번까지 순서대로 풀린다 (수동 확인).

## 결정이 필요한 것

| 결정 | 기본안 |
|------|--------|
| 한 세트 12문제 vs 쉬운 6 + 어려운 6 두 세트 | 12문제 한 세트 (10문제 넘으면 화면이 단계로 나눠 보여 준다) |
| `jq` 를 이미지에 추가해 `-o json \| jq` 도 가르칠지 | 추가하지 않는다. 이 세트는 `kubectl` 내장 출력만 (jq 는 별도 검토) |
