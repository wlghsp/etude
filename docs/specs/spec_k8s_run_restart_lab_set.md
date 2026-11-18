# 명세 — k8s 컨테이너 실행과 재시작 손연습 세트 (483)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `컨테이너 실행·재시작·Deployment 읽기`는 실습 0개였다). 짝 퀴즈: 198/306·214/311(Pod 스펙·컨테이너 실행), 217/312(Deployment 와 ReplicaSet), 220/313(Pod 종료와 재시작 정책).

## 구성 (12문제, 세트 483, sandbox `k8s`, 분야 k8s)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `command`·`args` | 스펙, Succeeded, 로그 `hello k8s` |
| 2 | 터미널 | `$(VAR)` 치환 | 로그 `hi there` |
| 3 | 터미널 | `workingDir` | 로그 `/etc` |
| 4 | 터미널 | `restartPolicy: Never` | Failed, 재시작 0, 종료 코드 1 |
| 5 | 터미널 | `restartPolicy: OnFailure` | 재시작 ≥ 2 (최대 2분 대기) |
| 6 | 터미널 | `lastState.terminated.exitCode` | 3 |
| 7 | 터미널 | Pod 삭제 후 Deployment 복구 | 삭제한 이름 없음, 다시 2개 |
| 8 | 터미널 | `ownerReferences` | `ReplicaSet Deployment` |
| 9 | 터미널 | ReplicaSet 직접 `scale` 이 되돌아감 | 2 |
| 10 | 객관식 | `restartPolicy` 기본값 | Always |
| 11 | 빈칸 | `{0}: ["echo"]` (command) | |
| 12 | 순서 | Deployment 가 Pod 를 되살리는 흐름 | |

- setup 은 이름이 고정된 이전 흔적(`ca`, `ev`, `wd`, `rn`, `rf`, `crash`, `heal`)을 지운다. 7~9번은 `heal`(nginx, replicas 2)과 삭제 대상 Pod 이름(`/tmp/lab/orig.txt`)을 준비한다.
- 거짓 통과 방지: 7번은 setup 만 하면 원래 Pod 가 남아 있어 실패하고, 5번은 아무 Pod 도 없어 실패한다 (`verify:quests` 무행동 검사).
- 근거: 쿠버네티스 공식 문서(명령·인자 정의, Pod 수명 주기, Deployment, ReplicaSet, 소유자와 종속성).

## 알려진 한계

`preStop`·`postStart` 훅, `terminationGracePeriodSeconds` 동작, 프로브(`startupProbe`)와 재시작, `Job` 의 `backoffLimit`, `imagePullPolicy` 는 다루지 않았다 (기존 339 실습이 프로브·CrashLoop 일부를 다룬다).

## 배치

k8s 단원 `컨테이너 실행·재시작·Deployment 읽기`(64) 끝, display_order 272, 아이콘 ♻️.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`, k3d).
- [x] 객관식 정답을 DB 에서 확인한다. `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
