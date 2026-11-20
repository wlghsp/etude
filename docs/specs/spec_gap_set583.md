# 명세 — 세트 583 가상화 상황집(1) VM 시작 실패

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `가상화`, 단원 72. 선행: 461, 475. 근거: `docs/research/content_gap_2026-11-19/` 의 gap_virt.md 상황집 S1·S2·S3·S5·S8. 생성: `scripts/content-gen/new_sets/set583.py`. 디스크 권한·쓰기 잠금·KVM·가상 네트워크·paused ioerror 를 현장 출력(샘플)에서 읽는다. 샌드박스에는 libvirt·OpenStack 이 없어 현장 출력(샘플)을 읽는 방식이다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set583.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 583` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
