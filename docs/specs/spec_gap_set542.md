# 세트 542 명세: sudo 위임 실습 (visudo·그룹 위임·특정 명령만·NOPASSWD)

- 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N12. 생성: `scripts/content-gen/new_sets/set542.py`
- 샌드박스 linux (Ubuntu 22.04). category 리눅스, unit 59, display_order 801, 10문제(실습 5).
- 선행: 세트 426(sudoers 읽기), 232. 이 세트는 직접 쓰는 실습이다.
- 직접 확인한 동작: etude-linux 이미지에는 sudo 가 없다(Rocky ubi-init 도 없음). 실습 setup 이 `apt-get install sudo` 로 설치한다(이미 있으면 건너뜀, 약 8초, 네트워크 필요). 학습자는 root 라서 `sudo -l -U 계정`, `su 계정 -s /bin/bash -c "sudo -n ..."` 로 다른 계정의 권한과 실제 실행을 확인한다. `visudo -cf`·`visudo -c`, sudoers.d 의 `.` 포함 이름 무시도 확인.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | visudo 를 쓰는 이유(문법 검사·잠금) | |
| 2 | 실습 | `visudo -cf` 로 오타 초안 고쳐 `/etc/sudoers.d/alice` 0440 설치 | 검사 통과·모드 440·`sudo -l -U` |
| 3 | 실습 | `%ops` 그룹 위임 | carol 허용·dave 거부·%ops 규칙·모드 |
| 4 | 실습 | 특정 명령 두 개만 허용 | restart/reload 보임·ALL·`*` 없음·hank 거부 |
| 5 | 객관식 | 위임한 vim 이 전권이 되는 이유, sudoedit | |
| 6 | 빈칸 | `sudo -l -U` | |
| 7 | 실습 | `frank.rules` 이름의 `.` 때문에 무시되는 규칙 고치기 | `sudo -l -U frank`·`visudo -c` |
| 8 | 실습 | `NOPASSWD: ALL` 을 스크립트 하나로 좁히기 | 스크립트 실행됨·`sudo -n id` 실패 |
| 9 | 객관식 | NOPASSWD: ALL 의 위험 | |
| 10 | 순서 | 초안 → 검사 → 설치 → `-l -U` → 실제 실행 | 순서 고정(설명) |

## 수용 조건

- [x] 10문제, 형식 4종(실습·객관식·빈칸·순서)
- [x] 실습 5개 모두 아무것도 안 하면 실패(초기에는 파일·규칙 없음, 8번은 `sudo -n id` 가 초기에 성공해 실패), `verify:quests` 5/5 통과
- [x] 힌트는 방향만(정답 규칙 문자열 없음), 현장 정보 없음
- [x] `bash scripts/check-content.sh` 통과

## 미해결

- sandbox `linux` 가 apt 로 sudo 를 설치하므로 네트워크가 막힌 환경에서는 실습 2·3·4·7·8 이 실패한다. 이미지(etude-linux)에 sudo 를 넣으면 setup 이 단순해진다(공유 파일이라 오케스트레이터 판단).
