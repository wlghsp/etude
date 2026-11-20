# 명세 — 세트 612 가상 NIC 성능

> 상태: 작성 (2026-11-20). 카테고리 `가상화`, 단원 72. 근거: `docs/research/content_gap_2026-11-19/gap_virt.md` 의 권장 21. 샌드박스 linux 에는 libvirt·ethtool 설정 권한 가 없어 명령은 파일에 적고 출력은 샘플로 읽는다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set612.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] 실습은 `verify:quests --set 612` 통과 (정답 통과, 무행동 실패)
- [x] 객관식 정답 길이 ÷ 오답 평균 ≤ 1.5 (스크립트로 계산)
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
