# 네트워크 11차: bridge vlan · bridge mdb 퀴즈 (세트 470·471)

작성일: 2026-11-18. 완성도 평가(`spec_category_completeness.md`)에서 낮게 나온 네트워크 분야를 보충한다.

| 세트 | 제목 | 근거 문서 | 아이콘 / 순서 |
|------|------|-----------|---------------|
| 470 | bridge vlan 으로 VLAN 필터 다루기 | bridge(8) man page | 🏷️ / 645 |
| 471 | bridge mdb 로 멀티캐스트 그룹 표 다루기 | bridge(8) man page | 📻 / 646 |

네트워크 기초 단원(47) 끝. 세트마다 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- bridge vlan: tunnel_info·vlan_tunnel, global 의 mcast_* 타이머 세부, msti 연결, tunnelshow 는 다루지 않았다.
- bridge mdb: VXLAN 전용 인자(dst·dst_port·vni·src_vni·via), flush 세부, (S, G)·(*, G) 의 전달 의미는 문서에 정의가 없어 뺐다.
- 순서 문제 두 개는 문서 설명을 이은 일반 절차이다. 컨테이너에서 실습할 수 없어 퀴즈로만 다룬다. 화면 확인은 하지 않았다(미검증).
