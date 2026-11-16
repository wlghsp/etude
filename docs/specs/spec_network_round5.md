# 명세 — 네트워크 5차 퀴즈 세트 418·419 (TCP 옵션, ip address)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). [spec_network_round4.md](spec_network_round4.md)에 이어 단원 47 `네트워크 기초` 끝에 세트를 더한다(뒤 세트 1개의 display_order 는 밀렸다). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 418 | 47 (633, ⏱️) | TCP 옵션과 sysctl | TCP_NODELAY(Nagle 끄기)·TCP_CORK, SO_KEEPALIVE 필요, keepalive 기본 7200·75·9, tcp_syncookies 기본 1, tcp_max_syn_backlog 기본 256, tcp_fin_timeout 60초, tcp_retries2, window scaling, syncookies·NODELAY 빈칸, keep-alive 동작 순서 |
| 419 | 47 (634, 🏠) | ip address 깊게 | label 15자, valid_lft·preferred_lft 의 의미와 기본 forever, scope host·link·site, 한 장치의 여러 주소, show 의 up, lft 기본·up 빈칸, 주소 추가·확인·제거 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

man7.org 의 tcp(7), ip-address(8). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(46개) 통과, 네트워크 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- tcp(7) 원문에 없는 흐름 제어 용어, 대역폭 지연 곱 용어, tcp_congestion_control 기본값, keep-alive 소켓 옵션의 기본값은 뺐다. ip-address 에서 broadcast 의 + 와 - 중 어느 쪽이 비트를 켜는지, secondary 와 deprecated 의 관계, prefix 생략 시 기본값은 원문이 명확하지 않거나 없어 뺐다.
- keep-alive 순서 문제의 마지막 단계(프로브 한도 후 연결 종료)는 문서가 직접 적지 않은 일반 절차다. 두 번째 순서 문제도 일반 절차다. 샌드박스에서 실제 소켓·주소를 만들지 않아 퀴즈로만 다룬다.
