# 명세 — Helm 차트 직접 만들기 손연습 (세트 383)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). 세트 14(저장소에서 받아 설치)와 퀴즈 147·293(개념·명령 빈칸)이 다룬 "쓰는 쪽"에서 한 걸음 나아가, **차트를 직접 다루는 쪽**을 실습한다. 저장소(네트워크)가 필요 없게 모두 로컬 차트를 쓴다.

## 구성

- 샌드박스 `k8s`, 분야 k8s, 단원 7 끝. 12문제: 실습 9 + 객관식 1 + 빈칸 1 + 순서 1. 문제마다 **배경** 포함.
- 실습용 차트 `/tmp/lab/demo` 는 문제 setup 이 만든다(ConfigMap 하나, 값 `greeting`·`replicas`).

| # | 주제 | 확인하는 것 |
|---|---|---|
| 1 | `helm create` | 차트 뼈대(Chart.yaml 이름, values.yaml, templates/deployment.yaml) |
| 2 | `helm show values` | 기본값 출력 |
| 3 | `helm template` | 릴리스 이름이 렌더링에 들어감 |
| 4 | `--set` | 값이 바뀌고 기본값은 사라짐 |
| 5 | `-f 값파일` | 파일 값이 적용됨 |
| 6 | `helm lint` | version 누락 오류를 고쳐 통과 |
| 7 | `helm package -d` | `demo-0.1.0.tgz` |
| 8 | `helm install` 로컬 차트 | 릴리스와 ConfigMap 값 |
| 9 | `helm rollback` | 값이 v1 로 복귀, 이력은 3 리비전 |
| 10 | (객관식) 값 우선순위 | `--set` > `-f` > 차트 기본값 |
| 11 | (빈칸) `helm lint` | |
| 12 | (순서) create → 고치기 → lint·template → install | |

근거: helm.sh 문서(create·template·lint·package·install·rollback, 값 파일 가이드의 우선순위 설명).

## 수용 조건

- [x] `verify:quests --set 383` 실습 9/9 통과 (k3d 클러스터, helm v3.22.1) — `검증됨`
- [x] `check-content.sh`, `check-migrations.sh`(10개) 통과 — `검증됨`
- [x] 풀지 않으면 실패: 1~7번은 `etude-k8s` 컨테이너에서 실행해 확인 — `검증됨`. 8·9번은 클러스터가 없는 환경에서만 돌려 본 것이라 자명하게 실패한 것이며, 클러스터 상태를 직접 보는 검사 구조로 `코드상 확인됨`.
- [ ] 화면 확인 (`미검증`)

## 알려진 사항

- 이 세트를 단원 7 끝에 두면서 같은 분야의 뒤 세트 display_order 가 하나씩 밀렸다(`place.py` 의 기존 방식).
- 문제 setup 의 마지막 명령이 실패 코드를 내면 setup 이 실패로 처리된다(`helm uninstall` 정리 뒤 `true` 필요).
