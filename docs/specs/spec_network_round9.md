# 네트워크 9차: ip(7) · udp(7) 퀴즈 (세트 466·467)

작성일: 2026-11-18. 완성도 평가(`spec_category_completeness.md`)에서 낮게 나온 네트워크 분야를 보충한다.

| 세트 | 제목 | 근거 문서 | 아이콘 / 순서 |
|------|------|-----------|---------------|
| 466 | ip(7) IPv4 소켓 | ip(7) man page (man-pages 6.19) | 🧭 / 641 |
| 467 | udp(7) UDP 소켓 | udp(7) man page (man-pages 6.19) | 📮 / 642 |

네트워크 기초 단원(47) 끝. 세트마다 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- ip(7): 소켓 옵션(IPPROTO_IP(2const))과 /proc 인터페이스(proc_sys_net_ipv4(5))는 문서가 다른 페이지로 넘겨서 다루지 않았다. 오류 코드(EADDRINUSE 등)는 일부만 해설에 언급했다.
- udp(7): /proc 의 udp_rmem_min·udp_wmem_min 세부, UDP_GRO 단독 문제, TIOCOUTQ 는 뺐다. 호출 실습은 컨테이너에서 할 수 없어 퀴즈로만 다룬다.
- 순서 문제 두 개는 문서 설명을 이은 일반 절차이다. 화면 확인은 하지 않았다(미검증).
