# 명세 — 세트 519 도커 문제 해결 상황집: 네트워크가 안 될 때

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 필수 행(D13 네트워크 문제: 이름 해석 실패·접속 거부·다른 네트워크). 샌드박스 `docker`(dind), 카테고리 `도커`, 단원 26, display_order 740. 선행: 세트 97(컨테이너가 안 뜰 때), 179·228(네트워크 기본). 생성: `scripts/content-gen/new_sets/set519.py`.

오류 메시지 → 원인 → 고치기를 재현된 상황에서 직접 한다. 이미지는 `alpine`, `nginx:alpine` 만 쓴다. 각 문제의 setup 은 앞 문제가 남긴 컨테이너·네트워크를 먼저 지운다.

## 구성

| # | 형식 | 상황 | 고치면 |
|---|---|---|---|
| 1 | 실습 | `bad address 'db'` — 기본 bridge 는 이름이 안 풀림 | 사용자 정의 네트워크에 두 컨테이너를 붙여 ping 성공, 결과 저장 |
| 2 | 실습 | 서로 다른 사용자 정의 네트워크 | db 의 네트워크 이름 저장 + web 을 추가로 연결(front 유지) |
| 3 | 실습 | `Connection refused` — 스크립트의 포트가 틀림 | 80 으로 고쳐 nginx 화면 저장 |
| 4 | 실습 | `-p 8080:8080` 로 열었으나 응답 없음 | `-p 8080:80` 으로 재생성, 호스트 8080 에서 응답 |
| 5 | 실습 | `network has active endpoints` | 컨테이너는 두고 disconnect 후 네트워크 삭제 |
| 6 | 실습 | `Pool overlaps with other one` — 서브넷 겹침 | 다른 대역(또는 생략)으로 newnet 생성, app 실행, oldnet·legacy 유지 |
| 7 | 실습 | `--internal` 네트워크는 기본 경로가 없음 | `ip route` 에 default 가 생기게 수정, 결과 저장 |
| 8 | 실습 | 설정의 `localhost` 는 컨테이너 자신 | `DB_HOST=db` 로 고쳐 접속 성공, 결과 저장 |
| 9 | 객관식 | `bad address` = 이름 해석 실패 | |
| 10 | 객관식 | 이름은 풀렸는데 `Connection refused` = 포트·서버 | |
| 11 | 빈칸 | `docker network {connect} appnet db` | |
| 12 | 순서 | 점검 순서: 실행 중 → 같은 네트워크 → 이름 → 포트 | |

## 수용 조건

- [ ] `verify:quests --set 519` 실습 8개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(터미널·객관식·빈칸·순서), 터미널 8/12
- [ ] hint 는 방향만(정답 값·명령 전체·순서를 알려 주지 않음)
- [ ] `check-content.sh` 통과, 현장 정보 없음 (`10.77.0.0/24` 등 예시 대역만)
