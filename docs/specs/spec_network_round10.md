# 네트워크 10차: arp(7) · bridge 퀴즈 (세트 468·469)

작성일: 2026-11-18. 완성도 평가(`spec_category_completeness.md`)에서 낮게 나온 네트워크 분야를 보충한다.

| 세트 | 제목 | 근거 문서 | 아이콘 / 순서 |
|------|------|-----------|---------------|
| 468 | arp(7) ARP 캐시 | arp(7) man page (man-pages 6.19) | 📇 / 643 |
| 469 | bridge 로 브리지 포트와 fdb 다루기 | bridge(8) man page | 🌉 / 644 |

네트워크 기초 단원(47) 끝. 세트마다 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- arp(7): ioctl 의 arp_flags 표(ATF_*)와 anycast_delay·proxy_delay·locktime·retrans_time 세부는 문제로 만들지 않았다.
- bridge(8): link set 의 나머지 옵션(learning·flood·isolated·locked·mab 등), mdb·mst·vlan·vni·monitor 객체, fdb 의 VXLAN 전용 인자는 다루지 않았다. 문서가 최신판이라 구버전 iproute2 와 옵션이 다를 수 있다.
- 순서 문제 두 개는 문서 설명을 이은 절차이다. 컨테이너에서 실습할 수 없어 퀴즈로만 다룬다. 화면 확인은 하지 않았다(미검증).
