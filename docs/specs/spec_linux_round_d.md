# 명세 — 리눅스 보강 퀴즈 세트 432·433 (sysctl, modprobe)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-26). [spec_linux_round_c.md](spec_linux_round_c.md)에 이어 [spec_category_completeness.md](spec_category_completeness.md)의 리눅스 공백(sysctl·modprobe 해당 세트 0개)을 퀴즈로 보강한다. 단원 4 `운영과 장애 대응` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 432 | 4 (115, 🎚️) | sysctl 로 커널 매개변수 다루기 | -a(deprecated 제외), -p 기본 /etc/sysctl.conf, --system 의 디렉터리 순서(/etc/sysctl.d 먼저)·sysctl.conf 마지막, 사전식 정렬, 같은 이름 파일은 높은 디렉터리만, -n·-e·-r(확장 정규식), -n·-p 빈칸, 값 바꾸고 반영하는 순서 |
| 433 | 4 (116, 🧲) | modprobe 로 커널 모듈 다루기 | modules.dep.bin 으로 의존 모듈 자동 추가, -r, -n, -v, -a, -f(= --force-vermagic + --force-modversion), -c, -S, - 와 _ 동일 취급, -n·-r 빈칸, depmod 부터 로드까지의 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

man7.org 의 sysctl(8), modprobe(8). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(60개) 통과, 리눅스 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- sysctl 문서에는 재부팅 후 유지, 설정 파일 형식(# 과 ; 주석)이 없어 뺐다. '/' 가 '.' 대신 쓰인다는 점은 있지만 /proc/sys 경로와의 직접 대응은 명시가 없어 문제로 만들지 않았다. 순서 문제(조회 → -w → 파일 → --system)는 문서가 직접 적지 않은 일반 절차다.
- modprobe 문서에는 /etc/modprobe.d 경로(modprobe.d(5) 참조), softdep, insmod 와의 비교, blacklist 의 자동 로드 방지 설명이 없어 뺐다. 의존 정보 파일은 문서에 modules.dep.bin 으로 적혀 있어 그대로 썼다.
- 샌드박스에서 sysctl·modprobe 를 실제로 실행하지 않아(컨테이너에서는 커널 설정 변경이 제한됨) 퀴즈로만 다룬다.
