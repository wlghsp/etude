# 명세 — 긴 단원 나누기 3차 (도커·네트워크·스토리지·가상화)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). [spec_unit_split_round2.md](spec_unit_split_round2.md) 의 후속이다. 규칙은 같다: **단원은 10세트 안팎, 넘으면 나눈다.** 세트 내용·번호·완료 기록·XP 불변, `unit_id`·`display_order` 와 새 `unit` 행만 바뀐다. 이 분야들은 비공개 상태라 열기 전에 구조를 맞춘다.

## 분할안 (단원 id, 단원 순서)

| 분야 | 단원 | 내용 | 세트 수 |
|---|---|---|---|
| 도커 | 컨테이너 다루기 (32, 12) | 상태·종료 신호, run 옵션, exec·attach, cp·restart·kill | 10 |
| 도커 | 컨테이너 조회·종료 코드·실습 (신규 66, 13) | 종료 코드, 출력 형식, 레지스트리, 실습 5개 | 11 |
| 도커 | 이미지와 Dockerfile (33, 14) | 이미지 빌드·관리, 실행 설정 | 9 |
| 도커 | Dockerfile 심화와 이미지 실습 (신규 67, 15) | 심화·지시어, 이미지 실습 | 8 |
| 네트워크 | 네트워크 기초 (47, 5) | 연결 요소, 주소·경로, DHCP, dnsmasq, iptables, DNS, ip route, 정책 라우팅 | 8 |
| 네트워크 | ip·ss·tc 도구 다루기 (신규 68, 6) | TCP sysctl, ip address, ss, neighbour, ethtool, tc, ip link, netns | 8 |
| 네트워크 | 소켓·ARP·브리지·터널 (신규 69, 7) | ip(7), udp(7), arp(7), bridge ×3, ip tunnel | 7 |
| 스토리지 | 스토리지 기초 (21, 20) | 개념, Ceph, NFS, LVM, mdadm | 10 |
| 스토리지 | 파일시스템과 마운트 도구 (신규 70, 21) | lvcreate, mke2fs, fsck, tune2fs, blkid, fstab, findmnt, umount, lsblk | 9 |
| 스토리지 | 스왑·XFS·파티션 도구 (신규 71, 22) | mkswap, swapon, wipefs, XFS 3종, fdisk 2종 | 8 |
| 가상화 | 가상화 기초 (48, 5) | 구조, virsh, 상태 보존, 마이그레이션, CPU·메모리, 네트워크·풀 | 8 |
| 가상화 | qemu-img·장치 설정·virsh 객체 명령 (신규 72, 6) | qemu-img, 이벤트·disk·인터페이스, virsh net·vol·iface | 10 |

- 새 단원 id 는 66~72. 단원 안 세트 순서는 기존 `display_order` 를 따르고, 분야의 기존 `display_order` 값 묶음을 단원 순서대로 다시 배정한다([units.ts](../../frontend/src/units.ts) 는 같은 단원이 이어져 있다고 가정).
- 도커의 `네트워크와 볼륨`(34) 등 이미 10세트 이하인 단원은 그대로다.
- 반영: `migrations/2026-11-18_unit_split_infra_docker.sql` (여러 번 실행해도 안전, 필요한 기존 단원 행을 `NOT EXISTS` 로 함께 넣어 단독 적용 가능), 같은 블록을 `11_new_set_order.sql` 끝에 둔다.

## 수용 조건

- [x] 마이그레이션 후 위 표대로 단원별 세트 수가 맞고 분야 안 `display_order` 중복·단원 섞임이 없다.
- [x] 재실행 시 0개 적용, `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 각 분야를 열었을 때(관리자) 단원이 위 순서로 보인다 (미검증).
