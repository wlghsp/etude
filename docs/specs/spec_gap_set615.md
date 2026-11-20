# 명세 — 세트 615 iperf3 로 성능 재기

> 상태: 작성 (2026-11-20). 카테고리 `네트워크`, 단원 68. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 의 선택 N22. 샌드박스 linux 에는 iperf3 가 없어 명령은 파일에 적고 출력은 샘플로 읽는다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set615.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] 실습은 `verify:quests --set 615` 통과 (정답 통과, 무행동 실패)
- [x] 객관식 정답 길이 ÷ 오답 평균 ≤ 1.5 (스크립트로 계산)
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
