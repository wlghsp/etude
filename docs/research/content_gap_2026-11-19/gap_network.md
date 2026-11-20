# 네트워크 분야 빈틈 분석

분석 기준일 2026-11-19. 읽기 전용 조사(DB 조회, merged.json). 근거는 세트 id·단원 id로 표기. 단원 id는 merged.json 의 `unit_id`.

## 요약

- 현재 `네트워크` 분류는 4개 단원(47 네트워크 기초, 68 ip·ss·tc 도구, 69 소켓·ARP·브리지·터널, 43 연결이 안 될 때)에 세트 24개. 이 중 **23개가 객관식 9 + 빈칸 2 + 순서 1(= 12문항)의 퀴즈**이고, 터미널 실습은 상황집 117(11문항 중 3개)뿐이다. 분야 전체 287문항 중 터미널은 3문항(약 1%)이다. 다른 분류(리눅스 235·81)에 터미널 9+3문항이 더 있으나 네트워크 분류가 아니다.
- 현재 깊이는 "도구 매뉴얼 깊이 읽기(ip route/neigh/link/netns, ss, tc, ethtool, bridge vlan/mdb, ip tunnel, ip(7)/udp(7)/arp(7) man 페이지)"에 편중돼 있다. 반면 **입문~중급의 뼈대**가 비어 있다. OSI/TCP-IP 모델, 서브넷 계산, TCP 3-way·상태·TIME_WAIT, HTTP/TLS, NAT, ICMP·ping·traceroute, IPv6, 로드밸런싱 개념이 이 분류에 전혀 없거나 한두 문항 수준이다.
- 가장 큰 빈틈 3개:
  1. **터미널 실습 전반 부재** — ping·traceroute·dig·curl·tcpdump·ss·ip 를 실제로 치고 출력을 읽는 세트가 없음(429 tcpdump 는 "필터 읽기" 퀴즈).
  2. **NAT·방화벽 실전(iptables 규칙을 직접 쓰고 확인)·conntrack·nftables/firewalld** — 404 는 퀴즈 12문항뿐이고 NAT 는 어디에서도 가르치지 않음(단원 47 이슈에도 기록됨).
  3. **TCP 동작(핸드셰이크·상태·TIME_WAIT·재전송)과 HTTP/TLS(인증서 체인·만료·openssl s_client)** — 434·418 이 전제하지만 가르치는 곳 없음.
- 그 밖에 OSI·캡슐화·서브넷 계산 기초, ICMP·진단 도구 계열, 상황집이 1세트(117)뿐인 점도 크다.
- 제안: 빈틈 24개(필수 10, 권장 10, 선택 4), 신규 세트 20개(필수 11, 권장 7, 선택 2). 신규 세트의 대부분을 터미널 실습·상황집으로 하여 분야 터미널 비중을 약 1%에서 35~40%로 끌어올린다.

## 참고 커리큘럼

대상: 사내 인프라 운영자. 현장 실무 우선, 활용도 극히 낮은 주제(EIGRP·MPLS 세부, 무선 규격 등)는 제외. 18개 영역.

| 영역 | 핵심 주제 |
|---|---|
| D1 네트워크 모델·기초 | OSI 7계층/TCP-IP 4계층, 캡슐화(프레임·패킷·세그먼트), 계층별 주소(MAC·IP·포트), 허브·스위치·라우터 역할, 유니캐스트·브로드캐스트·멀티캐스트 |
| D2 L2 (이더넷·ARP·스위칭) | MAC 학습·fdb, ARP·GARP, VLAN·트렁크, 리눅스 브리지, 본딩 모드, STP 기본, LACP, MTU |
| D3 IPv4 주소·서브넷 | 이진/십진, CIDR·마스크, 네트워크·브로드캐스트 주소, 서브넷 분할·계산, 사설·특수 주소(루프백·링크로컬·APIPA), 같은 서브넷 판정 |
| D4 IPv6 기초 | 주소 표기·축약, link-local, SLAAC, NDP, 이중 스택, 진단(ping6·ip -6) |
| D5 라우팅 | 라우팅 테이블, default·최장 일치·metric, ip route 조작, ip_forward, 정책 라우팅, 비대칭 경로, 동적 라우팅(OSPF·BGP) 개념 |
| D6 ICMP·진단 도구 | ping(TTL·loss·RTT), traceroute·mtr 읽기, ICMP 유형(unreachable·time exceeded·frag needed), PMTU |
| D7 TCP/UDP·소켓 | 포트·well-known, 3-way·4-way, 상태 머신, TIME_WAIT·CLOSE_WAIT, RST, 재전송·윈도우·혼잡, UDP 특성, 소켓 bind·listen |
| D8 DNS | 계층·재귀/반복, 레코드, TTL·캐시, dig/nslookup, resolv.conf·nsswitch·hosts, 지연·장애 패턴, 스플릿 DNS |
| D9 부트스트랩·시간 서비스 | DHCP, PXE, NTP/chrony |
| D10 HTTP | 메서드, 상태 코드(2xx·3xx·4xx·5xx), 헤더(Host·Content-Type·Cache), keep-alive, 리다이렉트, 쿠키, curl 활용(-v·-I·-w·-H·--resolve) |
| D11 TLS·인증서 | 핸드셰이크 흐름, 인증서 체인·CA·SAN·만료, openssl s_client/x509, SNI, mTLS 개념, 흔한 오류 |
| D12 방화벽·NAT | netfilter 훅·체인, iptables filter/nat, SNAT/DNAT/MASQUERADE, conntrack·상태 기반, nftables, firewalld·ufw, 포트포워딩, 규칙 디버깅 |
| D13 로드밸런싱·프록시·HA | L4/L7 차이, 분산 방식, 헬스체크, 리버스 프록시, VRRP/keepalived·VIP, 세션 유지 |
| D14 패킷 캡처·분석 | tcpdump 실행·필터·옵션(-nn -i -w -c), pcap 읽기, 핸드셰이크·재전송 식별, wireshark 대체 읽기 |
| D15 가상·컨테이너 네트워크 | netns·veth·브리지, docker/k8s 네트워크 모델 연결, VXLAN·GRE·WireGuard, 오버레이와 MTU |
| D16 성능·튜닝 | tc, ethtool, sysctl(backlog·conntrack·port range), 대역폭·지연 측정(iperf3), 소켓 버퍼 |
| D17 원격 접속·터널링 | ssh 접속·키·포트포워딩(-L/-R/-D), 점프 호스트, scp/rsync 네트워크 관점 |
| D18 장애 대응(상황집) | 층별 점검(L1·L2·L3·이름·포트·TLS·MTU), 오류 메시지 → 원인 → 해결 재현 |

## 커버리지 표

깊이: 없음 / 얕음 / 보통 / 충분. 형식: Q=개념 퀴즈만, T=터미널 실습 포함. 다른 분류의 세트는 `(타분류)` 표시. 퀴즈 세트는 모두 객관식 9·빈칸 2·순서 1 구조(조회 결과).

| 영역 | 주제 | 현재 세트 (id) | 깊이 | 형식 |
|---|---|---|---|---|
| D1 | OSI 7계층 | 81 q8 용어 1문항(타분류) | 얕음 | Q |
| D1 | TCP/IP 4계층·캡슐화 | 없음 | 없음 | - |
| D1 | 브로드캐스트·유니캐스트·멀티캐스트 | 378·396 전제로만 사용, 471 멀티캐스트(IGMP) 스누핑 심화 | 얕음(기초 없이 심화) | Q |
| D1 | 허브·스위치·라우터 역할 | 없음 | 없음 | - |
| D2 | MAC·이더넷 프레임 | 378 assumed(가르치지 않음) | 없음 | - |
| D2 | ARP | 379 q8, 435, 468 | 충분(Q), 실습 없음 | Q |
| D2 | VLAN·트렁크·브리지·본딩·MTU | 378, 469, 470 | 보통 | Q |
| D2 | STP·BPDU 개념 | 469 에서 포트 상태만(assumed: 가르치는 곳 없음) | 얕음 | Q |
| D2 | LACP/802.3ad | 378 q7 | 얕음 | Q |
| D2 | 멀티캐스트·IGMP | 471 | 보통(기초 없이 심화) | Q |
| D3 | 사설 주소·CIDR·/24·/26 호스트 수 | 379 q1·q2·q10 | 얕음 | Q |
| D3 | 이진 변환·서브넷 분할·같은 서브넷 판정 | 없음 | 없음 | - |
| D3 | 특수 주소(루프백·링크로컬·브로드캐스트) | 466 일부, 235(타분류) 루프백 | 얕음 | 일부 T |
| D3 | ip address 조작(scope·label·lft) | 419 | 충분(Q) | Q |
| D4 | IPv6 전반 | 419 에 scope 일부, 466 IPv4 한정. IPv6 전용 세트 없음 | 없음 | - |
| D5 | 라우팅 테이블·default·최장 일치·metric | 379, 408 | 보통 | Q |
| D5 | 경로 타입·scope·proto·nexthop | 408 | 충분 | Q |
| D5 | 정책 라우팅 ip rule | 409, 75 q5(타분류, 개념) | 보통 | Q |
| D5 | ip route 직접 추가·삭제·확인(실습) | 235 q3 `ip route get` 1문항(타분류) | 얕음 | T(1문항) |
| D5 | ip_forward·라우터로 쓰기 | 없음(NAT 와 함께 부재) | 없음 | - |
| D5 | 동적 라우팅(OSPF·BGP) 개념 | 없음 | 없음 | - |
| D6 | ping·traceroute·mtr | 없음(236 외 제목 검색 0건; 157·156 일부 curl 만) | 없음 | - |
| D6 | ICMP 유형·PMTU | 429 q7 필터, 467 PMTU(UDP 관점), 117 q11 MTU | 얕음 | Q+T 1문항 |
| D7 | 포트·well-known·ss LISTEN | 379 q9·q11, 434, 235(T) | 보통 | 일부 T(타분류) |
| D7 | TCP 3-way·4-way·상태 머신 | 가르치는 곳 없음(434·418 이 전제, 단원 68 이슈) | 없음 | - |
| D7 | TIME_WAIT·CLOSE_WAIT·RST·재전송 | 418 일부(fin_timeout·retries2) | 얕음 | Q |
| D7 | 소켓·bind·listen·UDP | 466, 467 | 보통(man 페이지식) | Q |
| D7 | TCP 옵션·sysctl 튜닝 | 418, 432(타분류) | 보통 | Q |
| D8 | DNS 레코드·TTL·UDP 512·RD/RA | 405 | 보통 | Q |
| D8 | 재귀/반복 질의 흐름 | 405 q12 순서 1문항 | 얕음 | Q |
| D8 | ndots·네거티브 캐시·hosts vs dig·TCP 53 | 81(타분류) q1~7 | 보통 | Q |
| D8 | dig 로 질의·+short·+trace·@서버 | 없음(81 q10 이름 해석 순서만) | 없음 | - |
| D8 | /etc/hosts·resolv.conf·nsswitch 실습 | 81 q9~11, 235 q4·q6·q8(타분류) | 보통 | T(타분류) |
| D8 | k8s·Docker DNS | 422·186·348·498(타분류) | 충분(타분류) | 일부 T |
| D9 | DHCP | 396, 397 | 보통 | Q |
| D9 | PXE·TFTP | 397 | 얕음 | Q |
| D9 | NTP/chrony | 75 q2·q3(타분류), 117 q10 | 얕음 | Q·T 1문항 |
| D10 | HTTP 메서드·상태 코드 | 156 q5~7, 268, 235 q10·q11(타분류) | 얕음~보통 | 일부 T |
| D10 | 헤더·Host·리다이렉트·쿠키·캐시 | 없음 | 없음 | - |
| D10 | curl 옵션 활용(-v -H -d --resolve -L) | 156·268 에서 -I -v -w -f -m 정도 | 얕음 | Q(fill) |
| D11 | TLS 핸드셰이크·인증서 체인·SAN | 없음(120 k8s 인증서, 116 registry 인증서 오류만) | 없음 | - |
| D11 | openssl s_client·x509 | 없음 | 없음 | - |
| D11 | 인증서 만료·시간 어긋남 | 117 q9·q10 | 얕음 | Q |
| D12 | iptables 테이블·체인·옵션 | 404 | 얕음~보통 | Q(12문항) |
| D12 | iptables 규칙 직접 작성·확인·삭제 | 없음 | 없음 | - |
| D12 | NAT(SNAT/DNAT/MASQUERADE)·포트포워딩 | 404 q3(체인 이름), 385(OpenStack L3 NAT 개념) | 얕음 | Q |
| D12 | conntrack | 없음 | 없음 | - |
| D12 | nftables·firewalld·ufw | 146·265(타분류) 방화벽 점검 순서 1문항 | 없음 | Q |
| D13 | L4/L7·분산 방식·헬스체크·VIP | 51·63·72·84·98 HAProxy(미들웨어) | 충분(미들웨어) | 일부 T |
| D13 | VRRP/keepalived | 63 이중화 일부(추정) | 얕음 | Q |
| D14 | tcpdump 필터 읽기 | 429(타분류) | 보통 | Q |
| D14 | tcpdump 실행·pcap 읽기·플래그 | 없음 | 없음 | - |
| D15 | netns·veth·브리지 | 438·439, 378 | 보통 | Q |
| D15 | VXLAN·GRE | 472(GRE·IPIP), 385(VXLAN 한 줄) | 얕음~보통 | Q |
| D15 | WireGuard/VPN | 없음 | 없음 | - |
| D15 | docker/k8s 네트워크 모델 | 498·494·348·186(타분류) | 보통 | T(타분류) |
| D16 | tc·ethtool | 436, 437 | 보통 | Q |
| D16 | iperf3 등 측정 | 없음 | 없음 | - |
| D17 | ssh 접속·키·장애 | 146·265·75·124(타분류) | 보통 | 124 T |
| D17 | ssh 포트포워딩·점프 호스트 | 없음 | 없음 | - |
| D18 | 층별 장애 상황집 | 117(1세트), 124 ssh, 98 HAProxy, 116 레지스트리(타분류) | 얕음 | 117 T 3문항 |

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

1. **TCP/IP 4계층·OSI·캡슐화 기초** — 없음. 378·379·396·405 가 MAC·프레임·브로드캐스트·IP 를 "전제"로만 사용(merged.json 단원 47 prereq_gap). 81 q8 용어 1문항만 있음.
2. **서브넷 계산(이진·CIDR·같은 서브넷 판정·게이트웨이 도달 가능성)** — 379 q1·q2·q10 세 문항이 전부. 실무 필수.
3. **TCP 동작(3-way·4-way·상태 머신·TIME_WAIT·CLOSE_WAIT·RST)** — 가르치는 곳 없음. 434(state 필터)·418(fin_timeout)이 전제(단원 68 prereq_gap).
4. **ping·traceroute·mtr 읽기와 ICMP** — 분류 전체에 없음. 현장 장애 대응 첫 도구.
5. **dig 로 DNS 직접 질의(+short, +trace, @서버)** — 405 는 개념 퀴즈, 81 q10 은 이름 해석 순서만. dig 실습 없음.
6. **HTTP/curl 실습(상태 코드·헤더·리다이렉트·Host·-v 읽기)** — 156·268·235 에 얕게 분산. HTTP 개념 단원 없음.
7. **TLS·인증서(체인·만료·SAN·openssl s_client)** — 없음. 117 q9 한 문항만(전제 개념 부재).
8. **iptables 규칙 직접 작성·확인(filter) 실습** — 404 는 퀴즈만. 터미널로 규칙을 넣고 `-L -n -v` 읽는 세트가 없음.
9. **NAT(SNAT·DNAT·MASQUERADE)·ip_forward·포트포워딩** — 없음. 404·409 가 전제(단원 47 prereq_gap), 385 는 OpenStack 개념.
10. **tcpdump 실제 캡처·읽기** — 429 는 필터 문법 퀴즈. 실행·출력 해석 없음. 4~7과 연결되는 핵심 진단 도구.

### 권장

11. **상황집 확충** — 117 한 세트로 이름·포트·시간·MTU 를 압축(단원 43 missing_bridge). L2/L3, 방화벽·NAT, TLS, 라우팅 비대칭 등 층별 상황집 필요.
12. **ip 명령 실습(addr·link·route 조작)** — 419·438·408 은 매뉴얼 퀴즈. 실제로 추가·삭제·확인하는 터미널 세트 없음(235 는 읽기 중심).
13. **ss 실습(상태 필터·-p·타이머)** — 434 퀴즈만. 터미널 실습 없음.
14. **conntrack·상태 기반 방화벽** — 없음. NAT·성능 이슈(테이블 가득 참)와 연결.
15. **nftables·firewalld·ufw** — 146·265 는 방화벽 점검 순서 1문항만. 배포판별 기본 방화벽이 다름.
16. **ssh 포트포워딩·점프 호스트** — 없음. 사내 접근 경로에 흔히 필요.
17. **IPv6 기초** — 없음. 사내 운영에는 이중 스택 점검 정도 필요.
18. **L4/L7·VIP·keepalived(VRRP) 개념 세트** — HAProxy 세트(미들웨어)는 도구 중심, 네트워크 분류에 개념·VRRP 없음.
19. **STP·LACP·멀티캐스트 기초** — 469·470·471 가 전제(assumed: 가르치는 곳 없음).
20. **VXLAN·오버레이와 MTU 계산, WireGuard 기본** — 472 는 GRE/IPIP 중심, VXLAN은 385 한 줄.

### 선택

21. **iperf3 로 대역폭·지연 측정, 병목 찾기** — 성능 영역 실습.
22. **동적 라우팅(OSPF·BGP) 개념** — 서버 운영자는 읽기만 필요. 개념 퀴즈 1세트.
23. **HTTP/2·HTTP/3·gRPC 차이, WebSocket** — 선택 개념.
24. **netcat/socat 으로 간단한 서버·클라이언트 만들기** — 235 q5·q9 에 일부 있음. 확장은 선택.

## 신규 세트 백로그

문제 수는 기존 12문항 구조 대신, 터미널 세트는 8~10문항(터미널 6~7 + 보조 퀴즈 2~3)을 권장. 선행은 기존 id 또는 아래 신규 번호(N1…). 단원 id 는 merged.json, "신단원"은 새 단원 제안.

| 우선순위 | 번호·제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| 필수 | N1. 네트워크 큰 그림: 계층 모델과 캡슐화 | 개념 퀴즈(시각 자료 연계) | 신단원 "네트워크 첫걸음"을 단원 47 앞에 둠 | 없음 | ① TCP/IP 4계층·OSI 대응 ② 계층별 주소(MAC·IP·포트) ③ 캡슐화(프레임·패킷·세그먼트) ④ 스위치·라우터가 보는 계층 ⑤ 유니/브로드/멀티캐스트 | 12 |
| 필수 | N2. 서브넷 계산 손연습 | 터미널 실습(`ipcalc` 또는 python/bc, `ip -br a`) + 퀴즈 | 신단원 "네트워크 첫걸음" | N1 | ① 마스크와 CIDR 표기 ② 네트워크·브로드캐스트·호스트 수 ③ 같은 서브넷 판정 ④ 서브넷 쪼개기 ⑤ 사설·특수 주소 ⑥ 내 서버 주소로 계산해 보기 | 12(터미널 5) |
| 필수 | N3. ping·traceroute·mtr 읽기 | 터미널 실습 | 단원 47 379 뒤(경로 기초 직후) 또는 신단원 "진단 도구 첫걸음" | 379 | ① ping 결과(TTL·RTT·loss) ② 응답 없음의 여러 원인 ③ traceroute 홉 읽기, `* * *` 의미 ④ mtr 손실 구간 읽기 ⑤ ICMP unreachable·time exceeded ⑥ DF 로 PMTU 확인(`ping -M do -s`) | 10(터미널 7) |
| 필수 | N4. TCP 연결의 일생 | 개념 퀴즈 + 터미널(ss·nc) | 단원 68 434 앞 또는 단원 47 뒤 | N1 | ① 3-way 핸드셰이크 ② 4-way 종료 ③ 상태(LISTEN·ESTABLISHED·TIME_WAIT·CLOSE_WAIT) ④ RST·refused vs timeout ⑤ TIME_WAIT 누적·CLOSE_WAIT 누수 해석 ⑥ nc·ss 로 상태 만들어 보기 | 12(터미널 4) |
| 필수 | N5. dig 로 DNS 질의 손연습 | 터미널 실습 | 단원 47 405 바로 뒤(397보다 앞, 순서 이슈 해소) | 405 | ① dig 기본 출력 읽기 ② +short·타입 지정 ③ @서버 지정 ④ +trace 재귀 흐름 ⑤ TTL 감소 확인 ⑥ resolv.conf 와 dig 결과 차이 | 10(터미널 7) |
| 필수 | N6. HTTP 한 줄씩: curl 로 요청·응답 읽기 | 터미널 실습 | 신단원 "웹 통신(HTTP·TLS)" 을 단원 47 뒤에 둠 | N4 | ① 요청·응답 구조 ② 상태 코드 2xx/3xx/4xx/5xx ③ 헤더(Host·Content-Type) ④ 리다이렉트 -L ⑤ -v 읽기 ⑥ --resolve·-H Host 로 호스트 지정 ⑦ keep-alive·타임아웃 | 12(터미널 7) |
| 필수 | N7. TLS와 인증서 읽기 | 개념 퀴즈 + 터미널(openssl) | 신단원 "웹 통신(HTTP·TLS)" | N6 | ① 핸드셰이크 큰 흐름 ② CA·체인·루트 ③ SAN·유효기간 ④ openssl s_client 출력 읽기 ⑤ openssl x509 -dates ⑥ 흔한 오류(만료·이름 불일치·체인 누락) | 12(터미널 5) |
| 필수 | N8. iptables 손연습 (1) 필터 규칙 | 터미널 실습 | 단원 47 404 바로 뒤 | 404 | ① -L -n -v --line-numbers ② -A/-I/-D 로 허용·차단 ③ 순서와 기본 정책 ④ 상태 기반(ESTABLISHED,RELATED) ⑤ 규칙 저장·초기화 시 주의 | 10(터미널 7) |
| 필수 | N9. NAT와 포트포워딩 손연습 | 개념 퀴즈 + 터미널(netns 2개 구성 포함) | 단원 47 N8 뒤 | N8, N10 | ① NAT가 필요한 이유 ② MASQUERADE·SNAT ③ DNAT·포트포워딩 ④ ip_forward ⑤ POSTROUTING·PREROUTING 위치 ⑥ netns 로 작은 망 재현 | 12(터미널 6) |
| 필수 | N10. 라우터 만들기: 경로 추가와 전달 | 터미널 실습(netns) | 단원 47 408 앞 | 379 | ① ip route add·del·replace ② default 경로 설정 ③ ip_forward ④ 경로 없을 때 증상 ⑤ 되돌아오는 경로(비대칭) ⑥ ip route get 로 검증 | 10(터미널 7) |
| 필수 | N11. tcpdump 로 직접 보기 | 터미널 실습 | 단원 68 또는 신단원 "패킷으로 확인하기"(429 뒤) | 429, N4 | ① -i·-nn·-c 기본 ② 필터 적용(429 연결) ③ SYN/ACK/RST 플래그 읽기 ④ DNS·HTTP 패킷 식별 ⑤ -w 로 저장·-r 로 읽기 ⑥ 재전송·응답 없음 식별 | 10(터미널 8) |
| 필수 | N12. 연결 장애 상황집 (2): 방화벽·NAT·경로 | 상황집(터미널) | 단원 43 117 뒤 | N8, N9, N10 | ① REJECT vs DROP 증상 ② 목적지는 열려 있는데 되돌아오지 못함 ③ default 경로 누락 ④ DNAT 후 응답 불일치 ⑤ 규칙 순서 실수 | 8(터미널 7) |
| 필수 | N13. 연결 장애 상황집 (3): 이름·TLS·HTTP | 상황집(터미널) | 단원 43 | N5, N7 | ① search·ndots 로 인한 지연 ② /etc/hosts 가 덮는 DNS ③ 인증서 이름 불일치·만료 ④ 3xx 루프 ⑤ 502·504 구분 | 8(터미널 7) |
| 권장 | N14. ip·ss 실전 점검 실습 | 터미널 실습 | 단원 68 419 뒤 | 419, 434 | ① ip -br·-s 로 상태·카운터 ② ip addr·link up/down ③ ss -tnp·-s ④ state 필터 ⑤ 오류 카운터(drop·error) 읽기 | 10(터미널 8) |
| 권장 | N15. conntrack 과 상태 기반 방화벽 | 터미널 + 퀴즈 | 단원 47 N9 뒤 | N8, N9 | ① 연결 추적 개념 ② conntrack -L 읽기 ③ 상태 NEW/ESTABLISHED ④ 테이블 가득 참 증상 ⑤ 타임아웃 | 10(터미널 5) |
| 권장 | N16. nftables·firewalld·ufw 한눈에 | 개념 퀴즈 + 터미널 | 단원 47 N8 뒤 | N8 | ① iptables 와의 관계 ② firewall-cmd zone·service·port ③ ufw allow/deny ④ nft list ruleset 읽기 ⑤ 영구/임시 반영 | 10(터미널 5) |
| 권장 | N17. ssh 터널링과 점프 호스트 | 터미널 실습 | 단원 69 또는 리눅스 단원 4 연계 | 124 | ① -L 로컬 포워딩 ② -R 원격 포워딩 ③ -D SOCKS ④ ProxyJump ⑤ 터널 확인(ss) | 8(터미널 6) |
| 권장 | N18. IPv6 기초 | 개념 퀴즈 + 터미널 | 단원 47 N2 뒤 | N2 | ① 표기·축약 ② link-local·global ③ SLAAC·NDP ④ ip -6·ping6 ⑤ 이중 스택에서 AAAA 우선 문제 | 10(터미널 4) |
| 권장 | N19. 부하 분산과 VIP 개념: L4/L7, 헬스체크, VRRP | 개념 퀴즈 | 신단원 "서비스 앞단 구성" 또는 단원 47 끝 | N6 | ① L4 vs L7 ② 분산 방식 ③ 헬스체크 ④ VIP·VRRP·failover ⑤ 세션 유지 | 12 |
| 권장 | N20. 연결 장애 상황집 (4): L2·MTU·성능 | 상황집(터미널) | 단원 43 | N3, N11 | ① ARP 응답 없음·중복 IP ② 링크 duplex/오류 카운터 ③ 큰 패킷만 실패(MTU, DF) ④ 포트 고갈·TIME_WAIT 증가 ⑤ 지연 vs 손실 구분 | 8(터미널 7) |
| 선택 | N21. VXLAN·WireGuard 기본 | 개념 퀴즈 + 터미널 | 단원 69 472 뒤 | 472, N10 | ① 오버레이 개념 ② VXLAN 구성(VNI) ③ MTU 감소 계산 ④ WireGuard 키·피어 | 10(터미널 4) |
| 선택 | N22. iperf3 로 성능 재기 | 터미널 | 단원 68 436·437 뒤 | N14 | ① 서버/클라이언트 ② 처리량·UDP 손실 ③ 병목 위치 추정 | 8(터미널 6) |

세트 수 22개(필수 13, 권장 7, 선택 2). 필수가 많아 단계적 제작 권고: 1차 N3·N5·N8·N10·N2·N11(실습 중심 6개) → 2차 N4·N6·N7·N9 → 3차 N12·N13 및 권장.

중복 회피 메모: N8 은 404 개념 퀴즈의 실습판이며 404 와 개념이 겹치지 않도록 "직접 입력·결과 확인"에 집중. N11 은 429(필터 문법) 다음 단계로 실행·해석. N14 는 419·434 개념 실습판(새 개념 거의 없음, 복습 성격). N10 은 379·408 의 실습판.

## 형식 균형

현황(조회 결과): 네트워크 분류 287문항 중 객관식 약 211, 빈칸 약 48, 순서 약 25, 터미널 3(1%). 터미널 세트는 117 하나. 리눅스 분류의 235(9/12 터미널)·81(3/11)을 합쳐도 네트워크 학습 경로 전체로는 실습이 매우 적다.

문제점:
- 단원 68·69 는 `ip`·`ss`·`bridge`·`tc`·`ethtool`·`ip netns` 명령을 주제로 하면서 **전 세트가 퀴즈**다. 명령 학습인데 명령을 치지 않는다.
- 단원 47 의 라우팅·DNS·DHCP·iptables 도 모두 퀴즈. 설정을 바꾸고 결과를 확인하는 경험이 없다.
- 반대로 개념 이해가 우선인 영역(OSI·TCP 상태·TLS 핸드셰이크·VRRP)은 개념 퀴즈가 적절하나, 그 앞단 기초 세트가 없어 심화만 존재.

권고 비율(분야 전체 문항 기준):
| 형식 | 현재 | 권고 |
|---|---|---|
| 터미널 실습 | 1% | **35~40%** (신규 세트 대부분을 실습으로, 기존 퀴즈 세트 일부에 터미널 3~4문항 삽입) |
| 객관식 | ~73% | 30~35% |
| 빈칸·순서·읽고 고치기 | ~26% | 25% (출력 읽기·"틀린 설정 고치기" 형식 추가) |

영역별 권고:
- 라우팅·NAT·방화벽·ip/ss·tcpdump·dig·curl·openssl·ssh 터널: **터미널 60% 이상**. 샌드박스 이미지에 `ping traceroute dig tcpdump openssl nc ss iptables conntrack ipcalc` 가 있어야 한다(sandbox_type linux 가 이 도구를 제공하는지는 확인 필요, 추정).
- netns 를 이용한 "작은 망 재현"으로 NAT·라우팅·방화벽을 안전하게 실습(컨테이너 권한 `NET_ADMIN` 필요, 추정).
- 기존 퀴즈 세트(378~472)는 유지하되, 실습 세트와 쌍으로 연결(예: 408 → N10, 434 → N14, 404 → N8, 429 → N11).
- 순서 정리·빈칸은 명령 문법 학습에 유용하므로 터미널 세트에서도 1~2문항 유지.

## 상황집

현황: 이 분야의 상황집은 **117 "연결이 안 될 때 층별로 좁히기"(단원 43) 1세트**(터미널 3·객관식 5·빈칸 2·순서 1). 11문항에 이름·포트 거부/시간초과·DNS 타임아웃·인증서·시간·MTU 를 압축했고 터미널 재현은 3문항(q4·q6·q8)이 텍스트 파일 가공이다. 실제 장애를 샌드박스에서 만들어 두고 고치는 형식이 아니다. 인접 분류에 124(SSH 접속), 98(HAProxy 503·DOWN), 116(레지스트리·인증서)이 있으나 네트워크 계층 장애는 아니다.

부족한 시나리오(오류 메시지 → 원인 → 해결, 재현 가능하게):

| 층 | 오류·증상 | 원인 후보 | 해결 실습 |
|---|---|---|---|
| L1/L2 | `Destination Host Unreachable`, ARP FAILED/INCOMPLETE | 케이블·VLAN 불일치·중복 IP·ARP 미응답 | `ip neigh`, `ip -s link`, 주소 충돌 확인 |
| L3 | `Network is unreachable`, 일부 대역만 안 됨 | default 누락, 잘못된 마스크, 비대칭 경로 | `ip route`, `ip route get`, 경로 추가 |
| 라우터/NAT | 내부는 되는데 외부 안 됨, 응답이 안 돌아옴 | ip_forward=0, MASQUERADE 누락, DNAT 후 반환 경로 | sysctl, iptables -t nat, conntrack |
| 방화벽 | `Connection timed out`(DROP) vs `refused`(REJECT/미리스닝) | 규칙 순서·기본 정책·포트 | `iptables -L -n -v` 카운터, `ss -ltn` |
| 이름 해석 | `Could not resolve host`, 처음만 느림, 일부 도메인만 실패 | resolv.conf·search·ndots·hosts 덮어쓰기·죽은 서버 | dig @서버, getent, 설정 수정 |
| TCP | 연결 후 멈춤, 연결 수 폭증 | TIME_WAIT/CLOSE_WAIT 누적, 백로그 가득, 포트 고갈 | `ss -s`, 상태 필터, sysctl |
| HTTP | 301 루프, 403/404/502/504 구분 | 리다이렉트 설정, Host 헤더, 업스트림 | `curl -v -L`, 헤더 확인 |
| TLS | `certificate has expired`, `no alternative certificate subject name`, `unable to get local issuer` | 만료·시간 어긋남·SAN 불일치·체인 누락 | `openssl s_client`, `x509 -dates`, 시간 동기화 |
| MTU | 작은 요청만 성공, 큰 전송만 멈춤 | 터널·오버레이 MTU 불일치, ICMP 차단(PMTU black hole) | `ping -M do -s`, `ip link set mtu` |
| 성능 | 느림, 간헐적 끊김 | 패킷 손실·링크 오류·duplex 불일치 | `mtr`, `ip -s link`, `ethtool` |

제안: 기존 117(개요형)을 "1층: 한눈에"로 유지하고 N12(방화벽·NAT·경로), N13(이름·TLS·HTTP), N20(L2·MTU·성능)을 추가하여 **상황집 총 4세트**. 모두 터미널 70% 이상이어야 하며, 117 의 q5(점검 순서)는 마지막 문제로 이동 권고(단원 43 이슈 order_in_set). 상황집은 각 층 기초 세트(N3~N11) 완료 후 배치.

## 부록: 기존 단원 순서 이슈 메모 (신규 계획과 연동)

merged.json 에서 이미 지적된 순서 문제는 신규 세트 위치 결정에 영향을 준다.
- 단원 47: 397(dnsmasq)이 405(DNS 기본)보다 앞 — 405→N5→397 순으로 재배치 권고. 408·409 가 379 와 떨어져 있음 → 379 → N10 → 408 → 409.
- 단원 68: 첫 세트 418(TCP 옵션)이 가장 고급. N4(TCP 연결의 일생)를 앞에 두거나 418 을 소켓 단원 뒤로 이동 권고.
- 단원 69: 466 이 소켓 기본 설명 없이 시작 — N4 선행으로 보완. 471·470 의 멀티캐스트·STP 전제는 N1(멀티캐스트 한 단락)·N19 로 일부 해소, 필요 시 STP·멀티캐스트 기초 소형 세트 추가(권장 19, 현재 백로그 미포함: 활용도 낮다고 판단, 추정).
