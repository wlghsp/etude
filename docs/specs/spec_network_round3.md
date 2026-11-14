# 명세 — 네트워크 3차 퀴즈 세트 404·405 (iptables, DNS)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). [spec_network_round2.md](spec_network_round2.md)에 이어 단원 47 `네트워크 기초` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 404 | 47 (629) | iptables 기본 | 기본 filter 테이블과 INPUT·FORWARD·OUTPUT, nat 체인, -A·-I(번호 없으면 머리)·-D·-F·-L, RETURN, 위에서부터 평가, -n, --dport 와 -p 확장, 삽입 확인 순서 |
| 405 | 47 (630) | DNS 기본 | A·NS·CNAME·SOA·PTR·MX, TTL 과 TTL 0, UDP 512바이트와 TC, RD·RA 비트, 레이블 63·이름 255 옥텟, 포트 53, 재귀 질의 흐름 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 뒤 세트 1개(117)의 display_order 는 밀렸다.

## 근거 문서

linux.die.net 의 iptables(8) 매뉴얼, RFC 1035. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(32개) 통과, 네트워크 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- iptables 매뉴얼은 security 테이블과 기본 정책의 값을 설명하지 않아 뺐다. 매뉴얼이 오래된 판이라 nftables 는 다루지 않았다.
- RFC 1035 는 일부(뒤 22KB)를 읽지 못했고, EDNS 로 확장된 UDP 크기는 RFC 에 없어 뺐다. 이름 길이는 RFC 기준(레이블 63·이름 255 옥텟)이다.
- 두 순서 문제는 문서 설명을 이은 큰 줄기다. 샌드박스에서 방화벽과 DNS 서버를 실제로 띄우지 않아 퀴즈로만 다룬다.
