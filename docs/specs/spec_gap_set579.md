# 명세 — 세트 579 파일시스템 장애 상황집

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `스토리지`, 단원 71, display_order 839. 선행: 577, 578. 근거: `docs/research/content_gap_2026-11-19/gap_storage.md` 백로그 P1-8. 생성: `scripts/content-gen/new_sets/set579.py`. 슈퍼블록이 망가진 ext4 이미지를 백업 슈퍼블록으로 복구하고 종류 식별·fsck 출력 읽기를 한다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set579.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 579` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
