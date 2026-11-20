# 명세 — 세트 567 서브넷 계산 손연습

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 47(네트워크 기초), display_order 827. 선행: 379(사설 주소·CIDR). 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N2(서브넷 계산 손연습). 생성: `scripts/content-gen/new_sets/set567.py`. ipcalc·python·bc 가 없어 셸 산술을 쓰고, setup 이 학습용 명령 ip2int·int2ip(awk)를 /usr/local/bin 에 만든다. 검증 하니스가 sh(dash)로 실행하므로 ** 대신 << 를 쓴다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set567.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 567` 실습 7개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
