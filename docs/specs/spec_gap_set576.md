# 명세 — 세트 576 연결 장애 상황집(3) 이름·TLS·HTTP

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 43(연결이 안 될 때), display_order 836. 선행: 117, 570, 569, 566. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N13(상황집). 생성: `scripts/content-gen/new_sets/set576.py`. curl 오류·프록시 로그·인증서 날짜는 샘플을 읽고, /etc/hosts 의 낡은 항목은 실제로 고친다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set576.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 576` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
