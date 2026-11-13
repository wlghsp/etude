# 명세 — 여러 컨테이너가 든 Pod 손연습 세트 (멀티 컨테이너 · logs/exec -c · emptyDir · initContainers)

> 상태: **구현 중(로컬)** (2026-11-13). 세트 375, k8s 분야 `워크로드와 설정` 단원(id 7) 끝(세트 351 뒤), 아이콘 🧩, 샌드박스 `k8s`. 근거: 기존 k8s 실습(6·12·13·19·20·22~26·31·33·37·224·227·230·233·236·336·339·342·345·348·351)에 없는 멀티 컨테이너 Pod. 사용자가 콘텐츠 세트를 알아서 이어 가라고 위임했다(2026-11-13).

## 목표

"컨테이너 둘짜리 Pod → 컨테이너 이름·Ready 읽기 → logs -c → exec -c → emptyDir 공유 → initContainers → Init 에서 멈춘 Pod 원인 → logs --all-containers" 를 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1. 연습 Pod 는 라벨 `etude=lab375` 또는 `mc375-` 접두사 이름이고, setup 은 이것만 지운다(`--all` 은 쓰지 않는다). 파일은 `/tmp` 에 둔다.
- 학습자 kubeconfig 의 기본 네임스페이스가 세션 네임스페이스라 `-n` 은 필요 없다. 정답·채점은 기존 세트처럼 `-n $NS` 를 쓴다.
- 세션 네임스페이스는 Pod Security `baseline` 이므로 특권·호스트 접근은 쓰지 않는다. 이미지는 `busybox:1.36`, `nginx:1.25`.
- 배경은 문제 안에 적는다(1번에 멀티 컨테이너 개념, 5·6번에 emptyDir·initContainers). 미리 만든 Pod 를 주는 문제는 setup 이 Running 까지 기다린다.
- 채점은 Pod 의 `spec`·`status` 를 jsonpath 로 조회하고, 상태가 늦게 변하는 항목은 최대 60초 폴링한다. 저장 파일은 정해진 값과 비교한다.
- 한계: 같은 상태를 만드는 다른 풀이도 통과한다. 8번은 `bad` 컨테이너가 계속 재시작되는 동안에도 ready 목록이 `ok` 로 유지되는 것에 기댄다.
- 문서 링크: kubernetes.io/docs 의 init-containers·pods·volumes·같은 파드 볼륨 공유·kubectl logs (200 확인).

## 수용 조건

- [ ] 터미널 9문제 모두 solution 으로 채점 통과 (`verify:quests -- --set 375`).
- [ ] 풀기 전 상태가 채점에서 실패한다.
- [ ] `check-content.sh`, `check-migrations.sh` 통과, 단원 7 끝에 배치.
- [ ] 화면: 단원 `워크로드와 설정` 끝에 보인다 (수동 확인).
