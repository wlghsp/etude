# 명세 — 세트 584 가상화 상황집(2)

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `가상화`, 단원 72. 선행: 583. 근거: `docs/research/content_gap_2026-11-19/` 의 gap_virt.md 상황집 S6·S7·S9·S10·S12. 생성: `scripts/content-gen/new_sets/set584.py`. IP 없음·마이그레이션·steal·스냅샷 체인·종료를 샘플 출력에서 읽고 명령을 적는다. 샌드박스에는 libvirt·OpenStack 이 없어 현장 출력(샘플)을 읽는 방식이다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set584.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 584` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
