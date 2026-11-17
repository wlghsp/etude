# 명세 — 가상화 7차 퀴즈 세트 464·465 (libvirt 도메인 XML: 네트워크 인터페이스)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-17). [spec_virt_round6.md](spec_virt_round6.md)에 이어 단원 48 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다. 근거 문서는 libvirt Domain XML format(https://libvirt.org/formatdomain.html)의 Network interfaces 절.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 464 | 48 (640, 🔌) | libvirt 인터페이스 유형 | network(동적·무선 권장)·bridge(정적 유선 권장), forward 모드별 DHCP·DNS 제공, default 네트워크(NAT, 192.168.122.0/24), vnetN tun, ethernet 과 `managed="no"`, direct(macvtap) 기본 모드 vepa, `trustGuestRxFilters` 기본 no, 브리지 연결 순서 |
| 465 | 48 (641, 📶) | libvirt 인터페이스 옵션 | model 값 전달, 예약된 target 접두사, 네트워크 boot order, bandwidth 방향별 제한, vlan 지원 연결과 trunk, port isolated 의 한계, link state, acpi index, 대역폭 제한 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- 뺀 것: 사용자 공간 SLIRP·PCI passthrough·hostdev 세부, 드라이버별 옵션(`<driver>` 의 queues·offload), 코얼레스·ROM BIOS·driver domain 백엔드, Midonet·802.1Qbg/h virtualport 세부, `portgroup`·`portid` 세부.
- 아이콘: 465 는 같은 분야의 세트 381 과 겹치는 🎛️ 대신 📶 을 쓴다.
- 컨테이너에서는 libvirt 를 실행할 수 없어 퀴즈로만 다룬다. 순서 문제 두 개는 일반 절차이다. 화면 확인은 하지 않았다(미검증).
