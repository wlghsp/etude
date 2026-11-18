# 가상화 8차: virsh 네트워크 · 볼륨 · 호스트 인터페이스 명령 퀴즈 (세트 473~475)

작성일: 2026-11-18. 가상화 분야를 보충한다. 근거는 모두 virsh 명령 레퍼런스(libvirt.org/manpages/virsh.html).

| 세트 | 제목 | 아이콘 / 순서 |
|------|------|---------------|
| 473 | virsh 로 가상 네트워크 다루기 (net-*) | 🕸️ / 642 |
| 474 | virsh 로 스토리지 볼륨 다루기 (vol-*) | 🗄️ / 643 |
| 475 | virsh 로 호스트 인터페이스 다루기 (iface-*) | 🪢 / 644 |

가상화 단원(48) 끝. 세트마다 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- net-*: net-desc·net-metadata·net-event·net-port-* 명령과 net-dumpxml 옵션은 다루지 않았다.
- vol-*: vol-create-from, vol-download, vol-list·vol-path·vol-key 계열, 지우기 알고리즘별 세부(nnsa·dod 등)는 뺐다. 순서 문제의 마지막 단계는 vol-info --physical 설명을 이은 것이다.
- iface-*: iface-dumpxml·edit·list·name·mac 은 다루지 않았다.
- 컨테이너에서 libvirt 를 실행할 수 없어 퀴즈로만 다룬다. 순서 문제 세 개는 문서 설명을 이은 일반 절차이다. 화면 확인은 하지 않았다(미검증).
