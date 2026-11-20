# 명세 — 세트 556 네트워크 드라이버 개념 정리: none·host·overlay·macvlan·ipvlan

> 상태: 작성 (2026-11-20). 샌드박스 `docker`(dind), 카테고리 `도커`, 단원 34, display_order 816. 선행: 228(네트워크 기본), 519, 533. 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 의 '네트워크 드라이버 개념 정리'. 생성: `scripts/content-gen/new_sets/set556.py`.

개념 퀴즈 위주에, 샌드박스에서 되는 `--network none|host` 와 `-d macvlan` 만 터미널 실습으로 확인한다. overlay 는 Swarm 이 필요해 실습 대신 오류 해설 퀴즈·순서·빈칸으로 다룬다. 533(bridge 안쪽)·519·530 과 겹치지 않게 bridge 내부와 `-p` 는 다루지 않는다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 기본 네트워크 3개(bridge·host·none) | |
| 2 | 실습 | `--network none`, 컨테이너 안 `ip -o addr` | 모드 none, lo 만(eth0 없음) |
| 3 | 객관식 | host 모드의 성격(포트 충돌·NAT 없음) | |
| 4 | 실습 | `--network host`, 인터페이스 목록에 docker0 | 모드 host, docker0 포함 |
| 5 | 객관식 | overlay 는 Swarm 필요(오류 해설) | |
| 6 | 빈칸 | `--attachable` | |
| 7 | 순서 | swarm init → overlay 생성 → SCOPE 확인 → 컨테이너 붙이기 | |
| 8 | 실습 | `network create -d macvlan --subnet --gateway -o parent=eth0` | 드라이버·서브넷·게이트웨이·parent |
| 9 | 객관식 | macvlan(고유 MAC) vs ipvlan(MAC 공유) | |
| 10 | 객관식 | 상황별 선택(사용자 정의 bridge) | |
| 11 | 객관식 | k8s `hostNetwork` = `--network host` | |
| 12 | 객관식 | k8s CNI 는 overlay 와 같은 종류의 문제를 푼다 | |

## 수용 조건

- [x] `verify:quests --set 556` 실습 3개 통과 (정답 통과, 무행동 실패) — 로컬 미러 사용
- [x] 형식 4종(터미널·객관식·빈칸·순서), 12문제
- [x] hint 는 방향만, 복수 정답 없음
- [ ] `check-content.sh` 통과 확인
