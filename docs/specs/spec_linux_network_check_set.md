# 명세 — 리눅스 로컬 네트워크 점검 세트 (ip · hostname · getent · /etc/hosts · nc · ss · curl)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 235. 근거: 기존 세트는 `curl`·`ping`·포트 확인(4·10·16·18·229), `/etc/hosts` 등록(10·18·36·81), 포트 점유 프로세스(16·229)를 각자 따로 묻는다. "내 주소와 경로 → 이름 풀이 → 포트 열기·확인 → 응답 코드 읽기"를 **인터넷 없이 서버 안에서 살아 있는 상태로 이어서 점검하는 한 줄기**는 없고, `ip -br a`·`ip route get`·`hostname`·`getent hosts`·`/etc/resolv.conf`·`curl` 종료 코드는 다뤄진 적이 없다.

## 목표

서버 안에서 네트워크가 어떻게 생겼는지 직접 읽고 만져 본다. `ip -br a` 로 주소를, `ip route get` 으로 경로를, `hostname`·`getent hosts`·`/etc/resolv.conf` 로 이름 풀이를, `nc -l` 과 `ss -ltn` 으로 포트 열기를, `curl` 의 HTTP 상태 코드와 종료 코드로 응답을 읽는다. 쉬운 것부터 차례로 12문제.

## 원칙

- 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1 (형식을 섞는 규칙).
- **인터넷과 컨테이너 IP 에 의존하지 않는다.** 대상은 루프백 `127.0.0.1` 과 `/etc/hosts` 에만 쓰는 문서용 대역(`192.0.2.x`, 이름은 `*.example.test`)뿐이다. 환경마다 다른 값(호스트 이름, DNS 서버)은 고정값이 아니라 같은 명령의 현재 출력과 비교한다.
- setup 은 `api.example.test`(192.0.2.20)를 `/etc/hosts` 에 덧붙이고, `127.0.0.1:8088` 에서 항상 HTTP 503 을 돌려주는 `nc` 반복 서버(`/tmp/lab/resp503.sh`, `setsid nohup`)를 띄운다. 별도 exec 사이에도 살아 있다.
- **재실행해도 안전하다.** 옛 응답 서버(PID 파일)와 `nc` 를 죽이고, `/etc/hosts` 에서 `example.test` 줄만 지운 뒤 다시 덧붙인다. 이 환경의 `/etc/hosts` 는 bind mount 라 `sed -i` 가 실패하므로 `grep -v … > 임시; cat 임시 > /etc/hosts` 로 inode 를 유지한다 (검증됨).
- 채점은 파일 **내용**과 살아 있는 상태를 본다: `getent hosts` 풀이 결과, `ss -ltn` 의 LISTEN, 종료 코드, 상태 코드. 채점에서 `nc` 로 접속하지 않는다 (대기 중인 `nc -l` 이 끝나 버리기 때문).
- 이미지(`etude-linux`)에 있는 것만 쓴다: `ip ss nc(OpenBSD) curl getent ping hostname awk`. `dig nslookup python3 ncat wget` 은 없다.
- 새 개념은 한 문제에 하나만. 객관식은 `Could not resolve host`(이름 풀이 단계 실패)와 연결 거부의 구분. 빈칸은 `nc -z` (칩 `-z -l -k -p`, 확인만 하는 옵션은 `-z` 하나뿐).

## 세트 구성 (12개, 세트 235)

| # | 형식 | 제목 | 새로 익히는 것 | 채점 |
|---|------|------|----------------|------|
| 1 | 터미널 | 루프백 인터페이스 주소 보기 (ip -br a) | `ip -br addr show lo` | 한 줄, `lo` 로 시작, `127.0.0.1/8` 포함 |
| 2 | 터미널 | 이 서버의 호스트 이름 저장하기 (hostname) | `hostname` | 파일 == `hostname` 출력 |
| 3 | 터미널 | 127.0.0.1 로 가는 길목 찾기 (ip route get) | `ip route get`, `dev` 뒤 단어 | 파일 == 경로의 인터페이스 이름(`lo`) |
| 4 | 터미널 | 이름이 가리키는 IP 풀어 보기 (getent hosts) | `getent hosts 이름` | 파일 == 풀이된 IP, IP 모양 한 줄 |
| 5 | 빈칸 | 포트가 열렸는지 연결만 해 보기 | `nc -z` (칩 `-z -l -k -p`) | 칸 1개 |
| 6 | 터미널 | DNS 서버 주소 읽기 (/etc/resolv.conf) | `nameserver` 줄 | 파일 == 첫 nameserver 주소 |
| 7 | 객관식 | Could not resolve host 는 무슨 뜻일까 | 이름 풀이 실패 vs 연결 거부 | 정답: 이름 풀이 단계 실패 |
| 8 | 터미널 | 이름을 127.0.0.1 로 연결하기 (/etc/hosts) | `>>` 덧붙이기 (`>` 는 통째로 덮어씀) | 새 이름 → 127.0.0.1, localhost·api 줄 유지 |
| 9 | 터미널 | 포트를 직접 열고 확인하기 (nc -l, ss -ltn) | 백그라운드 `nc -l -p` + `ss -ltn` | 9090 LISTEN, nc 프로세스 존재 |
| 10 | 터미널 | 연결이 거부될 때의 종료 코드 확인하기 (curl) | `$?`, curl 종료 코드 7 | 파일 == 7, 8099 닫혀 있음 |
| 11 | 터미널 | 서버가 돌려준 HTTP 상태 코드 읽기 (curl -w) | `curl -s -o /dev/null -w '%{http_code}'` | 파일 == 503 (서버가 정함) |
| 12 | 순서 | 서버에 접속이 안 될 때 점검하는 순서 | 주소 → 경로 → 이름 → 포트 → 응답 | 5조각 |

- 객관식 정답은 보기 목록의 첫 번째로 적고, 도우미가 섞는다. 해설은 보기와 모순되지 않게 쓴다.
- 빈칸·순서·객관식은 터미널이 필요 없어 터미널 창이 보이지 않는다.
- 겹침 점검: 세트 10·18·36·81 이 `/etc/hosts` 등록을, 4·16·18·102·229 가 포트 확인을, 4·98 이 `curl` 을 다루지만, 이 세트는 읽기 도구(`ip`·`getent`·`resolv.conf`)와 `curl` 상태·종료 코드 해석으로 차별화한다. 8번(hosts 덧붙이기)과 9번(포트 열기·확인)이 가장 가깝다.

## 배치

단원·display_order 는 통합 시 정한다. 세트 종류: `sandbox_type = linux`, 분야 `리눅스`, `time_limit_sec` 없음.
구현: `scratchpad/gen235.py` 생성기로 `backend/db/03_quest_set235.sql`, 마이그레이션(`2026-11-11_linux_network_check_set235.sql`), `backend/verify/set235.json`, `02_quest_set.sql` 끝 행을 만든다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (새 컨테이너에서 setup 후, 별도 exec 로).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다 (거짓 통과 없음).
- [x] setup 을 연달아 두 번 실행해도 오류 없이 같은 상태가 된다 (`example.test` 줄 하나, 응답 서버 하나).
- [x] 8번은 `>` 로 `/etc/hosts` 를 덮어쓰면 실패한다.
- [x] 11번의 503 응답 서버가 연속 요청에도 계속 응답한다.
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다.
- [x] 빈칸의 칩에 정답이 둘 이상 되는 값이 없다 (`-z` 만 정답).
- [x] 각 문제의 `checks` 가 상태의 **내용**을 확인한다. 컨테이너 IP 를 고정하지 않는다.
- [x] 각 문제 `docs` 에 ip·ss·hosts·resolv.conf 매뉴얼 링크가 달려 있다.
- [x] 내용에 IP·도메인·회사·내부 시스템 이름이 없다 (`127.0.0.1`, `192.0.2.x`, `*.example.test` 제외).
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 홈 리눅스 탭에 보이고, 1번부터 12번까지 순서대로 풀린다 (수동 확인).
