# 명세 — 세트 565 TCP 연결의 일생: LISTEN·ESTABLISHED·TIME_WAIT·CLOSE_WAIT

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 68(ip·ss·tc 도구), display_order 825. 선행: 434·466. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N4(TCP 연결의 일생). 생성: `scripts/content-gen/new_sets/set565.py`. 연결을 받고 닫지 않는 서버는 perl(IO::Socket::INET)로, 클라이언트·서버 소켓은 nc 로 만든다. 비특권 샌드박스에서 127.0.0.1 안에서만 재현.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set565.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 565` 실습 6개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
