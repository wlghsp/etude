# 명세 — 네트워크 2차 퀴즈 세트 396·397

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). [spec_network_quiz_sets.md](spec_network_quiz_sets.md)에 이어 단원 47 `네트워크 기초` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 396 | 47 네트워크 기초 (627) | DHCP 동작 | 서버 67·클라이언트 68, DISCOVER(브로드캐스트), BROADCAST 비트, giaddr 릴레이, ARP 확인 후 DECLINE, NAK, T1=0.5·T2=0.875, RELEASE, INFORM, DORA 순서 |
| 397 | 47 네트워크 기초 (628) | dnsmasq 로 DHCP·DNS·PXE | 기본 임대 1시간(최소 2분), --dhcp-host, --dhcp-boot(파일 이름만), --enable-tftp(네트워크 부팅 한정), --tftp-root, router 옵션 비우기, --address, --no-resolv, 캐시 150, --pxe-service, --dhcp-range, PXE 구성 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 뒤 세트 1개(117, 🌐)의 display_order 는 두 세트를 놓으면서 뒤로 밀렸다.

## 근거 문서

RFC 2131(DHCP), dnsmasq 매뉴얼(thekelleys.org.uk). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(24개) 통과 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0), 분야 내 아이콘 중복 없음 — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- RFC 본문 일부(OFFER·REQUEST·ACK 의 역할)는 세부 설명 대신 메시지 표와 상태도에 의존한다. 순서 문제(DORA)와 PXE 구성 순서는 문서 설명을 이은 큰 줄기다.
- dnsmasq 매뉴얼은 일부(`--dhcp-match`, `--domain` 단독 항목)를 읽지 못해 뺐다.
- 실제 DHCP·PXE 부팅은 샌드박스에서 실습할 수 없어 퀴즈로만 다룬다.
