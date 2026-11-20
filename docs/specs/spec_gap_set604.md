# 명세 — 세트 604 VM 스냅샷과 qemu-img

> 상태: 작성 (2026-11-20). 카테고리 `가상화`, 단원 72. 선행: 601. 근거: `docs/research/content_gap_2026-11-19/gap_virt.md` 의 필수 9·권장 13. libvirt·qemu-img 가 없어 샘플 출력을 읽고 명령을 적는다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set604.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] 실습은 `verify:quests --set 604` 통과 (정답 통과, 무행동 실패) — 퀴즈 세트는 해당 없음
- [x] 객관식 정답 길이 ÷ 오답 평균 ≤ 1.5 (스크립트로 계산)
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
