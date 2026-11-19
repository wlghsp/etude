# 명세 — k8s 워크로드 운영 옵션 손연습 세트 (499)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: DaemonSet OnDelete, CronJob timeZone·이력, --from-env-file, imagePullSecrets, create token, wait --for=delete, replace --force, externalTrafficPolicy, 이름 있는 targetPort.

## 구성 (12문제, 세트 499, sandbox `k8s`, 분야 k8s, 단원 `스케줄링과 워크로드 실습(65)` 끝, 🧮)

1~9 터미널(위 주제 순서), 10 객관식(OnDelete), 11 빈칸(`--for={0}`), 12 순서(immutable 필드 교체)

- DaemonSet OnDelete 는 `rollout status` 를 지원하지 않아 처음에 실패했고 `kubectl wait --for=jsonpath` 로 바꿨다.
- 알려진 한계: 실제 토큰 인증·NodePort 접속·시간대에 따른 실행 시각은 확인하지 않는다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인 (`검증됨`).
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 탭에서 보이고 1~12번이 풀린다 (수동 확인).
