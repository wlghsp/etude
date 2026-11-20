# 명세 — 세트 573 라우팅 테이블 읽기

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 47, display_order 833. 선행: 379, 567. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N10(경로·라우터). 생성: `scripts/content-gen/new_sets/set573.py`. 경로를 바꿀 권한이 없어 ip route 샘플을 읽고, 이 컨테이너의 실제 경로 조회와 경로 추가 명령 작성을 더한다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set573.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 573` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
