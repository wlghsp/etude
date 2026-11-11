# 명세 — k8s 출력 뽑아내기 세트 (jsonpath · custom-columns · sort-by)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 근거: 사용자 질문("KodeKloud 에서는 JSON 읽는 훈련을 많이 하던데 그건 없나?"). 현재는 `jsonpath`·`custom-columns` 가 세트 12·19·20·25·26·33·37 에 문제 하나씩 흩어져 있고(터미널 문제 15개), 이것만 집중해서 반복하는 세트는 없다. 갭 분석: [spec_k8s_cka_gap_analysis.md](spec_k8s_cka_gap_analysis.md).

## 목표

`kubectl get -o json` 이 주는 JSON 의 **구조를 읽고 원하는 값만 뽑는** 손버릇을 만든다. 실무(스크립트, 장애 때 이미지·노드·IP 확인)와 CKA 형식 시험에서 매번 나오는 기술이다. 세트 하나에서 쉬운 것부터 차례로 12문제.

## 원칙

- 모두 **터미널 실습**이고 채점은 결과 파일(`/tmp/*.txt`)의 내용으로 한다 (기존 k8s 세트와 같은 방식, `jq` 는 이미지에 없으므로 쓰지 않는다).
- 새 개념은 한 문제에 하나만. 앞 문제의 표현을 다음 문제가 한 칸씩 확장한다 (피드백 #7: 배우기 전에 푸는 순서 문제를 피한다).
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). 노드·네임스페이스 조회는 쓰지 않고 Pod·Deployment·Secret·ConfigMap 만 쓴다.
- `jsonpath` 출력은 끝에 줄바꿈이 없다. 첫 문제 힌트에서 이를 알리고(`; echo` 또는 `> 파일` 후 `cat`), 셸은 줄바꿈 없는 출력 뒤에도 프롬프트가 줄 처음에 나오게 고쳐져 있다 (피드백 #12).
- 이미지는 `nginx`, `busybox` 만 쓴다 (노드 캐시 공유, 서버 부담 최소).

## 세트 구성 (12개, 구현됨: 세트 224)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1 (형식을 섞는 규칙). 피드백 #2 로 터미널이 필요 없는 문제에서는 터미널 창이 보이지 않는다.

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | JSON 구조 눈으로 보기 | `-o json`, `items` 안의 `metadata`·`spec`·`status` |
| 2 | 터미널 | 첫 번째 Pod 이름만 | `-o jsonpath='{.items[0].metadata.name}'` |
| 3 | 터미널 | 이름을 한 줄에 하나씩 | `{range .items[*]}…{"\n"}{end}` |
| 4 | 터미널 | 이름과 이미지를 함께 | range 안에 값 둘, `{"\t"}` |
| 5 | 빈칸 | Deployment 의 이미지 경로 | `.spec.template.spec.containers` |
| 6 | 터미널 | 점이 들어 있는 키 | `example\.io/owner` |
| 7 | 터미널 | 조건으로 고르기 | `?(@.status.phase=="Running")` |
| 8 | 터미널 | 열을 골라 표로 | `-o custom-columns=NAME:…,IMAGE:…` |
| 9 | 터미널 | 만든 순서로 정렬 | `--sort-by=.metadata.creationTimestamp` |
| 10 | 객관식 | 두 번째 컨테이너 이미지 경로 | 배열 번호는 0부터 |
| 11 | 터미널 | Secret 값 풀어 읽기 | `{.data.password}` → `base64 -d` |
| 12 | 순서 | 이미지별 개수 세기 | jsonpath → sort → uniq -c → sort -rn |

- 1~2번은 도움을 많이 준다(`-o json` 을 먼저 저장해 구조를 보고, 거기서 경로를 한 칸씩 따라가도록).
- 터미널 문제 setup 은 Pod 세 개(db-1, web-1, web-2)를 만들고 Ready 를 기다린다. 7번만 잘못된 이미지의 Pod `bad-1`, 9번은 시간차를 둔 `zeta`·`alpha` 를 쓴다.

## 배치

- 분야 k8s, 단원 **6 기초**의 `kubectl 속도와 실전`(세트 19) 뒤 (jsonpath 첫 접촉이 세트 19·20 이므로 그 다음). 세트 224, `display_order` 241, 아이콘 🔬 ([spec_units.md](spec_units.md)). 아이콘은 새로 고른다.
- 세트 종류: `sandbox_type = k8s`, `time_limit_sec` 없음, 첫 완료 XP 는 같은 크기의 k8s 터미널 세트와 같다.
- 구현: `scripts/content-gen/example_practice_set.py` 를 복사해 만든다 (예시를 직접 실행하지 않는다). `backend/db/03_quest_setN.sql`, 마이그레이션, `backend/verify/setN.json`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 224`, 9/9, 검증됨).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다 (거짓 통과 없음, 검증됨).
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인했다 (10번: `{.spec.containers[1].image}`).
- [x] 각 문제의 `checks` 가 결과 파일의 **내용**(이름·이미지·정렬 순서)을 확인한다. 파일이 존재하는지만 보지 않는다.
- [x] 각 문제 `docs` 에 해당 문법의 공식 문서 링크가 달려 있다 (kubernetes.io jsonpath / kubectl 참조).
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 홈 k8s 탭 `기초` 단원에 보이고, 1번부터 12번까지 순서대로 풀린다 (수동 확인).

## 결정이 필요한 것

| 결정 | 기본안 |
|------|--------|
| 한 세트 12문제 vs 쉬운 6 + 어려운 6 두 세트 | 12문제 한 세트 (10문제 넘으면 화면이 단계로 나눠 보여 준다) |
| `jq` 를 이미지에 추가해 `-o json \| jq` 도 가르칠지 | 추가하지 않는다. 이 세트는 `kubectl` 내장 출력만 (jq 는 별도 검토) |
