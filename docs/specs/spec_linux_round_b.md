# 명세 — 리눅스 보강 퀴즈 세트 428·429 (strace, tcpdump 필터)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-24). [spec_linux_round_a.md](spec_linux_round_a.md)에 이어 [spec_category_completeness.md](spec_category_completeness.md)의 리눅스 공백(strace·tcpdump 해당 세트 0개)을 퀴즈로 보강한다. 단원 4 `운영과 장애 대응` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 428 | 4 (111, 🧫) | strace 로 시스템 호출 보기 | 기본 출력(이름·인자·반환값, 표준 에러), -f, -c, -T, -tt, -s 기본 32, -y, 추적 시 느려짐, -1 ENOENT 읽기, -e trace=%file·-f 빈칸, 실패 원인 찾는 순서 |
| 429 | 4 (112, 🕵️) | tcpdump 필터 읽기 | primitive(한정자+id), 한정자 type·dir·proto, and·or·not, host 는 출발지 또는 목적지, dir 생략 시 src or dst, portrange, icmp 는 ip proto 1 의 축약형, less·greater, vlan, port·src 빈칸, 필터 만드는 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

man7.org 의 strace(1), pcap-filter(7). 위 내용은 원문에서 직접 확인했다. tcpdump 필터 문법은 pcap-filter 문서가 정의한다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(56개) 통과, 리눅스 분야 display_order 중복 없음, 새 세트 아이콘이 유일 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- strace 문서에 ptrace 사용과 "프로세스당 tracer 하나"는 명시적 문장이 없어 뺐다. 오래된 `trace=file` 표기(% 없음)는 deprecated 라 `%file` 만 썼다.
- pcap-filter 에서 icmp 는 proto 한정자 목록에 없고 `ip proto 1` 의 축약형이라 그렇게 출제했다. TCP 플래그 검사(`tcp[tcpflags]`)와 `ip proto` 세부, tcpdump 명령 옵션(-i, -n, -w)은 다루지 않았다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 샌드박스에서 실제 strace·tcpdump 를 실행하지 않아 퀴즈로만 다룬다. 실습 세트 후보(`strace -c`, `tcpdump -r` 로 미리 만든 pcap 읽기)는 별도 검토 대상이다.
