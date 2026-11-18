# 명세 — k8s 워크로드 관계와 설정 손연습 세트 (487)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `워크로드와 설정`은 실습 0개였다). 짝 퀴즈: 220~229(네임스페이스·ConfigMap·Secret, Deployment·Job, Service·프로브, 워크로드 관계 한 줄씩).

## 구성 (12문제, 세트 487, sandbox `k8s`, 분야 k8s)

setup 은 이전 흔적(`tool`, `envpod`, `cmpod`, `probepod`, `evpod`, `evother`, `sapod`, ConfigMap·Secret·ServiceAccount)을 지우고 문제별 준비물을 만든다. 기존 세트(12, 22, 236, 233, 339, 375)와 겹치지 않는 주제만 골랐다.

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `ownerReferences` 로 Pod→ReplicaSet→Deployment 읽기 | 두 줄 일치 |
| 2 | 터미널 | `envFrom` + `prefix` | `APP_A`·`APP_B` |
| 3 | 터미널 | ConfigMap 볼륨 `items` | 파일 하나만 마운트 |
| 4 | 터미널 | `create secret docker-registry` | 타입·서버 주소 |
| 5 | 터미널 | ConfigMap `immutable` | true, 값 불변 |
| 6 | 터미널 | `startupProbe` | 주기·임계값·Running |
| 7 | 터미널 | `get events --field-selector` | 대상 Pod 만 |
| 8 | 터미널 | `logs -l --prefix` | Pod 이름 접두어 2줄 |
| 9 | 터미널 | ServiceAccount + `serviceAccountName` | 지정 일치 |
| 10 | 객관식 | Pod 의 직접 주인 | ReplicaSet |
| 11 | 빈칸 | `create secret {0}` | docker-registry |
| 12 | 순서 | startupProbe 가 있는 Pod 의 프로브 순서 | |

- 거짓 통과 방지: 각 터미널 문제는 setup 만 한 상태에서 실패한다 (`verify:quests` 무행동 검사).
- 근거: 쿠버네티스 공식 문서(소유자·종속, ConfigMap, 사설 레지스트리, 프로브, 서비스 어카운트, kubectl).

## 알려진 한계

네임스페이스 생성은 학습자 권한상 불가라 다루지 않았다. HPA·Helm·StatefulSet 심화·Ingress·RBAC(Role/RoleBinding)는 후속 세트 후보다.

## 배치

k8s 단원 `워크로드와 설정`(7) 끝, display_order 230, 아이콘 🧬. 뒤 세트 78개의 display_order 가 1씩 밀렸다.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`, k3d).
- [x] 객관식 정답 DB 확인, `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
