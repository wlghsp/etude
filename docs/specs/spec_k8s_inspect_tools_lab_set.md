# 명세 — k8s 점검·출력 도구 손연습 세트 (500)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: run --rm 임시 Pod, QoS Guaranteed, events --for, -o name, jsonpath range, go-template, 직전 종료 코드, rollout history --revision, set env --from --prefix.

## 구성 (12문제, 세트 500, sandbox `k8s`, 분야 k8s, 단원 `자원·kubectl 도구·Job·Service 심화(62)` 끝, 🔭)

1~9 터미널(위 주제 순서), 10 객관식(Guaranteed 조건), 11 빈칸(`--restart={0}`), 12 순서(재시작 Pod 원인 좁히기)

- `kubectl debug`(임시 컨테이너·--copy-to)는 샌드박스 계정에 `pods/ephemeralcontainers` 권한이 없어 검증에 실패했고 다른 주제로 바꿨다. `set env --from` 은 `envFrom` 이 아니라 `APP_MODE` env(configMapKeyRef)로 풀린다.
- 알려진 한계: 이벤트 내용은 시점에 따라 달라 `Scheduled` 포함만 확인한다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인 (`검증됨`).
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 탭에서 보이고 1~12번이 풀린다 (수동 확인).
