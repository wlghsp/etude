# 명세 — 세트 566 TLS 와 인증서 읽기: 만료·SAN·체인 검증·s_client·직접 만들기

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 47(네트워크 기초), display_order 826. 선행: 117(인증서 오류 한 문항). 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N7(TLS와 인증서 읽기). 생성: `scripts/content-gen/new_sets/set566.py`. 인증서는 setup 이 EC 키로 만든다. 만료된 인증서는 openssl ca 의 -startdate/-enddate 로 과거 날짜를 지정해 만든다. OpenSSL 3.0.2 기준.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set566.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 566` 실습 7개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
