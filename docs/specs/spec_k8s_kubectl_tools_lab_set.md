# 명세 — k8s kubectl 편집·점검 도구 손연습 세트 (484)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `자원·kubectl 도구·Job·Service 심화`는 실습 0개였다). 짝 퀴즈: 174/300(kubectl 편집·조회 도구), 190/304(컨텍스트·출력·삭제), 211/310(kubectl 도구 모음).

## 구성 (12문제, 세트 484, sandbox `k8s`, 분야 k8s)

setup 은 이전 흔적(`tool`, `tool-pod`, `slowpod`)을 지우고 Deployment `tool`(nginx:1.25, replicas 2)을 준비한다.

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `patch` (strategic) 이미지 변경 | nginx:1.26 |
| 2 | 터미널 | `patch --type json` replicas | 5 |
| 3 | 터미널 | `KUBE_EDITOR` 와 `sed` 로 `edit` | replicas 4 |
| 4 | 터미널 | `set env` | MODE=prod |
| 5 | 터미널 | `annotate --overwrite` | team-b |
| 6 | 터미널 | `kubectl diff` | 변경 미리 보기, 클러스터 불변 |
| 7 | 터미널 | `kubectl cp` | 파일 내용 일치 |
| 8 | 터미널 | `kubectl wait` | `&&` 로 ready 기록, Pod Ready |
| 9 | 터미널 | `kubectl explain` | Recreate·RollingUpdate 설명 |
| 10 | 객관식 | `patch` 기본 방식 | strategic |
| 11 | 빈칸 | `kubectl set {0}` (env) | |
| 12 | 순서 | diff → apply → rollout status → undo | |

- 거짓 통과 방지: 각 터미널 문제는 setup 만 한 상태에서 결과가 기대와 달라 실패한다 (`verify:quests` 무행동 검사).
- 근거: 쿠버네티스 공식 문서(kubectl patch, 레퍼런스, 치트 시트).

## 알려진 한계

`kubectl port-forward`(백그라운드 프로세스 필요), `kubectl debug`, `kubectl replace --force`, `kubectl apply --prune`, `kubectl label`·`custom-columns`(다른 세트가 다룸), Job 심화(completions·ttl)·Service 심화는 다루지 않았다 (후속 세트 후보).

## 배치

k8s 단원 `자원·kubectl 도구·Job·Service 심화`(62) 끝, display_order 251, 아이콘 🪚.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`, k3d).
- [x] 객관식 정답을 DB 에서 확인한다. `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
