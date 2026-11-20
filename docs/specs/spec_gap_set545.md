# 명세 — 세트 545 네트워크 영구 설정: 호스트명·nmcli·정적 IP·게이트웨이·DNS

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N19. `linux` 샌드박스, 리눅스, 단원 3, display_order 804. 선행: 세트 235(내 서버 네트워크 점검: ip, hostname, getent, resolv.conf).
> 환경 제약(직접 확인): `etude-linux`(Ubuntu 22.04, 비특권)에는 `nmcli`·`hostnamectl`·NetworkManager 가 없고 `ip addr add` 는 `Operation not permitted`. `linux-systemd`(Rocky 9)에도 `nmcli`·`ip` 가 없다. 그래서 **실제 출력·설정 파일과 같은 모양의 샘플 파일**(`/srv/lab/net`)을 `awk`/`grep`/`cut` 으로 읽는 실습 4개와 개념 문제로 구성한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `hostnamectl` 에서 Static vs Transient 호스트 이름 | host.txt = web01.example.com |
| 2 | 객관식 | `hostnamectl set-hostname` 만 영구 (`hostname`·/proc 는 임시) | |
| 3 | 객관식 | `ip addr add` 는 임시, 영구는 연결 프로필 | |
| 4 | 실습 | `nmcli connection show` 에서 eth0 의 연결(프로필) 이름 | conn.txt = lan-main |
| 5 | 실습 | `.nmconnection` 의 `address1=주소/접두사,게이트웨이` 읽기 | ip.txt, gw.txt |
| 6 | 빈칸 | `nmcli connection modify` | |
| 7 | 객관식 | modify 는 저장만, `up` 으로 적용 | |
| 8 | 실습 | `ip route` 의 default via 게이트웨이 (프로필과 비교) | run_gw.txt = 192.0.2.254 |
| 9 | 객관식 | IP 는 되고 이름은 안 됨 → DNS 점검 | |
| 10 | 순서 | modify → up → ip -br a → ip route → getent hosts | |

## 수용 조건

- [ ] `verify:quests --set 545` 실습 4개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 형식 3종 이상(실습·객관식·빈칸·순서), 현장 정보 없음(`example.com`, `192.0.2.x`, `198.51.100.x` 만)
- [ ] 샘플 출력이 실제 `hostnamectl`·`nmcli connection show`·keyfile·`ip route` 형식과 일치
