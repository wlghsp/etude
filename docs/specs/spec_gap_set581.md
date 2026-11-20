# 명세 — 세트 581 백업·복원 손연습

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `스토리지`, 단원 21, display_order 841. 선행: 리눅스 338. 근거: `docs/research/content_gap_2026-11-19/gap_storage.md` 백로그 P1-6·P1-7. 생성: `scripts/content-gen/new_sets/set581.py`. rsync 가 없어 tar·sha256sum 으로 전체·증분 백업, 체크섬, 부분 복원, 복원 순서를 한다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set581.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 581` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
