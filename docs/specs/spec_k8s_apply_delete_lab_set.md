# 명세 — k8s 적용·삭제 방식 손연습 세트 (492)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: apply 선언형, server-side apply, cascade, 상태별 삭제, 유예 삭제, 권한 조회, finalizer.

## 구성 (12문제, 세트 492, sandbox `k8s`, 분야 k8s, 단원 `자원·kubectl 도구·Job·Service 심화`(62) 끝, 🗑️)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | 파일 고쳐 `apply` (replicas 3) |
| 2 | 터미널 | `apply --server-side --field-manager=trainer` |
| 3 | 터미널 | `delete --cascade=orphan` (RS·Pod 유지) |
| 4 | 터미널 | `delete --field-selector status.phase=Succeeded` |
| 5 | 터미널 | 신호 무시 Pod 를 `--now` 로 삭제 |
| 6 | 터미널 | `auth can-i` (yes / no) |
| 7 | 터미널 | `api-resources --namespaced=true -o name` |
| 8 | 터미널 | `set serviceaccount` |
| 9 | 터미널 | finalizer 로 Terminating 인 ConfigMap 풀기 |
| 10 | 객관식 | `--cascade=orphan` 효과 |
| 11 | 빈칸 | `--cascade={0}` |
| 12 | 순서 | Terminating 처리 순서 |

- 거짓 통과 방지: 무행동 검사 통과(9/9, `검증됨`, k3d).
- 알려진 한계: `apply --prune`, `replace --force`, `--force --grace-period=0` 의 위험은 다루지 않았다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
