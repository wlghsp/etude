# 명세 — 세트 533 도커 네트워크 안쪽 들여다보기: bridge·서브넷·이름 해석

> 상태: 작성 (2026-11-19). 샌드박스 `docker`(dind), 카테고리 `도커`, 단원 34, display_order 754. 선행: 세트 228(네트워크 기본), 519(네트워크 상황집). 생성: `scripts/content-gen/new_sets/set533.py`.

519 가 "오류 → 고치기"라면 533 은 **네트워크가 실제로 어떻게 생겼는지** 열어 보는 세트다. 서브넷·게이트웨이 → 컨테이너 안의 IP·기본 경로 → 호스트 쪽 `docker0`·`br-` 인터페이스 → 이름 해석 차이 → NAT 규칙 → connect/disconnect → nc 접속 확인. 이미지는 `alpine` 만 쓴다. (Docker 29 는 `.NetworkSettings.IPAddress` 를 없앴으므로 `.NetworkSettings.Networks.<이름>.IPAddress` 를 쓴다. 컨테이너 이름은 2글자 이상.)

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 기본 bridge 의 서브넷·게이트웨이 (`network inspect`) | 파일 2개가 inspect 값과 일치 |
| 2 | 실습 | 컨테이너 안 `ip addr`·`ip route` | IP·기본 경로 게이트웨이 일치 |
| 3 | 실습 | 호스트 쪽 `ip addr show docker0` | docker0 정보 + 주소 = 게이트웨이 |
| 4 | 실습 | 기본 bridge: IP 로는 ping 성공, 이름은 `bad address` | 두 결과 파일 |
| 5 | 실습 | 사용자 정의 bridge(`--subnet`) 이름 ping | 서브넷·컨테이너·ping 결과 |
| 6 | 객관식 | 내장 DNS `127.0.0.11` | |
| 7 | 실습 | 호스트의 `br-<ID 12자>` 인터페이스 | 인터페이스 이름·게이트웨이 주소 |
| 8 | 실습 | `iptables -t nat` 의 MASQUERADE 규칙 | 서브넷·MASQUERADE |
| 9 | 실습 | `network connect --ip`, 인터페이스 2개 | labnet IP, bridge 유지, eth 2개 |
| 10 | 빈칸 | `docker network {disconnect}` | |
| 11 | 실습 | `nc -w 3 srv 9000` 접속 확인 | 서버 실행 중 + 받은 내용 |
| 12 | 순서 | 만들기 → 띄우기 → ping 성공 → disconnect → ping 실패 | |

## 수용 조건

- [x] `verify:quests --set 533` 실습 9개 전부 통과 (정답 통과, 무행동 실패) — 로컬 미러 사용
- [x] 형식 4종(터미널·객관식·빈칸·순서), 터미널 9/12
- [x] hint 는 방향만(정답 값·명령 전체·순서를 알려 주지 않음)
- [x] `check-content.sh` 통과, 현장 정보 없음 (`198.51.100.0/24` 예시 대역만)
