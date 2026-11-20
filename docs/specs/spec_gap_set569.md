# 명세 — 세트 569 HTTP 한 줄씩: curl 로 상태 코드·헤더·리다이렉트·Host·POST·타임아웃 읽기

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 47(네트워크 기초), display_order 829. 선행: 156·268. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N6(HTTP curl 실습). 생성: `scripts/content-gen/new_sets/set569.py`. 연습 서버는 setup 이 perl 로 /tmp/webd.pl(127.0.0.1:8081)을 만든다(/old 301, /health 503, /echo Host 반사, /slow 3초, /submit POST 201).

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set569.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 569` 실습 7개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
