# 명세 — k8s Job·프로브·수명주기 설정 손연습 세트 (493)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: Job 재시도·시간 제한·TTL·Indexed, exec·tcpSocket 프로브, postStart, imagePullPolicy 기본값, 종료 메시지.

## 구성 (12문제, 세트 493, sandbox `k8s`, 분야 k8s, 단원 `컨테이너 실행·재시작·Deployment 읽기`(64) 끝, 🧯)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | Job `backoffLimit` |
| 2 | 터미널 | Job `activeDeadlineSeconds` |
| 3 | 터미널 | Job `ttlSecondsAfterFinished` (600초: 채점 중 삭제 방지) |
| 4 | 터미널 | Indexed Job, 3개 성공 |
| 5 | 터미널 | exec `readinessProbe`, Ready |
| 6 | 터미널 | tcpSocket `livenessProbe` |
| 7 | 터미널 | `postStart` 훅 |
| 8 | 터미널 | `:latest` → Always, 고정 태그 → IfNotPresent |
| 9 | 터미널 | `/dev/termination-log` 종료 메시지 읽기 |
| 10 | 객관식 | liveness·readiness 실패 시 동작 차이 |
| 11 | 빈칸 | `ttlSecondsAfter{0}` |
| 12 | 순서 | Pod 가 트래픽을 받기까지 |

- 8번은 `busybox:latest` 를 지정하지만 이미지를 받을 때까지 기다리지 않고 API 필드만 채점한다.
- 알려진 한계: CronJob 심화, Pod 우선순위·토폴로지 분산은 후속 후보.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인 (`검증됨`).
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
