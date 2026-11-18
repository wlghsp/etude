# 명세 — k8s Kustomize 손연습 세트 (482)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `롤아웃·Pod 스펙·Kustomize·ConfigMap`은 실습 0개였다). 짝 퀴즈: 202/307(Kustomize 와 일회성 실행).

## 구성 (12문제, 세트 482, sandbox `k8s`, 분야 k8s)

setup 이 `/tmp/lab/base`(Deployment `web`, nginx:1.25, replicas 2)를 만든다. 학습자는 `/tmp/lab/overlay/kustomization.yaml` 을 직접 쓴다. 채점은 `kubectl kustomize` 렌더링 결과와 `apply -k` 로 만든 클러스터 상태를 확인한다.

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `kubectl kustomize` 렌더링 | Deployment, replicas 2 |
| 2 | 터미널 | `namePrefix: dev-` | name: dev-web, base 불변 |
| 3 | 터미널 | `images` `newTag` | nginx:1.26, 옛 태그 없음 |
| 4 | 터미널 | `replicas` | 4, 옛 값 없음 |
| 5 | 터미널 | `labels` + `includeSelectors` | env: dev 3곳 |
| 6 | 터미널 | `configMapGenerator` | 해시 이름, LEVEL: debug |
| 7 | 터미널 | `apply -k` | dev-web 생성, web 없음 |
| 8 | 터미널 | `patches` (환경 변수 추가) | APP_MODE=dev, 접두사·이미지 유지 |
| 9 | 터미널 | `delete -k` | dev-web 없음 |
| 10 | 객관식 | base 와 overlay 의 역할 | |
| 11 | 빈칸 | `kubectl {0} -k` (apply) | |
| 12 | 순서 | base → overlay → 미리보기 → 적용 | |

근거: 쿠버네티스 문서(Kustomize 로 오브젝트 관리), kustomization.yaml 레퍼런스.

## 알려진 한계

`components`, 원격 base(URL), `secretGenerator`, `replacements`, `transformers` 플러그인, `helmCharts` 는 다루지 않았다. `commonLabels` 는 폐기 예정이라 `labels` 를 쓴다.

## 배치

k8s 단원 `롤아웃·Pod 스펙·Kustomize·ConfigMap`(63) 끝, display_order 261, 아이콘 🧵.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`, k3d).
- [x] 객관식 정답을 DB 에서 확인한다. `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
