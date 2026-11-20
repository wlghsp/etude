# 명세 — 세트 590 IPv6 기초

> 상태: 작성 (2026-11-20). 카테고리 `네트워크`, 단원 47, display_order 850. 선행: 567. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N18. 루프백 ::1·ping -6 은 실제로 확인하고, link-local·전역 주소·경로는 문서용 대역(2001:db8::/32) 샘플을 읽는다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set590.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] 실습은 `verify:quests --set 590` 통과 (정답 통과, 무행동 실패)
- [x] 객관식 정답 길이 ÷ 오답 평균 ≤ 1.5 (스크립트로 계산)
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
