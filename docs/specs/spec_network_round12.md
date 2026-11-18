# 네트워크 12차: ip tunnel 퀴즈 (세트 472)

작성일: 2026-11-18. 완성도 평가(`spec_category_completeness.md`)에서 낮게 나온 네트워크 분야를 보충한다.

| 세트 | 제목 | 근거 문서 | 아이콘 / 순서 |
|------|------|-----------|---------------|
| 472 | ip tunnel 로 IP 터널 다루기 | ip-tunnel(8) man page | 🚇 / 647 |

네트워크 기초 단원(47) 끝. 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- ip-maddress(8)는 내용이 짧아(정적 링크 계층 멀티캐스트 주소 add·del·show) 세트로 만들지 않았다.
- ip-tunnel: csum·seq 계열(seq 는 문서가 "동작하지 않는다" 고 적음), prl(ISATAP), 6rd, flowlabel, allow-localremote 는 다루지 않았다. 문서는 2011년판 렌더링이라 최신 모드(vxlan·geneve 등은 ip link)와 다르다.
- 순서 문제는 문서 설명을 이은 일반 절차이다. 컨테이너에서 실습할 수 없어 퀴즈로만 다룬다. 화면 확인은 하지 않았다(미검증).
