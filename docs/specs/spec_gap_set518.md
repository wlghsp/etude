# 명세 — 세트 518 패키지 설치 실패 상황집: 저장소·서명·lock·의존성

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N18(S7). 샌드박스 `linux`(Ubuntu 22.04, root), 카테고리 `리눅스`, 단원 4, display_order 739. 선행: 24·135(패키지 조회·한 줄씩). 생성: `scripts/content-gen/new_sets/set518.py`.

## 환경 제약 (설계의 전제)

샌드박스는 Debian 계열이라 보고서의 dnf 문구를 apt/dpkg 로 바꿨다. 네트워크가 없을 수 있어 외부 저장소는 쓰지 않고, setup 이 직접 만든 .deb 로 `/tmp/repo` 로컬 저장소(`file:` 소스)를 만들어 오류를 재현한다(`/tmp/mkrepo.sh` 가 Packages·Release 색인을 만든다). 외부 저장소 전용 오류(`NO_PUBKEY`, `Temporary failure resolving`)는 출력을 읽는 객관식으로 다룬다. 서명이 없는 로컬 저장소의 해결책은 `[trusted=yes]` 이므로 문제와 해설에 "직접 만든 연습 저장소 한정"을 명시하고, 외부 저장소의 정석(`signed-by`)은 9·10번에서 가르친다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `Failed to fetch ... File not found`: sources 경로 오타 | update 성공, hello-lab 설치 |
| 2 | 실습 | `repository is not signed`: 로컬 저장소 `trusted=yes` | update 성공, hello-lab 설치 |
| 3 | 실습 | `Unable to locate package`: 새 패키지는 update 후 설치 | notice-lab 설치 |
| 4 | 실습 | `Could not get lock`: PID 확인 후 프로세스 종료 | 잠금 프로세스 없음, hello-lab 설치 |
| 5 | 실습 | `dpkg was interrupted`: `dpkg --configure -a` | pend-lab·other-lab 설치 상태 |
| 6 | 실습 | `dpkg -i` 의존성 문제: `apt-get install -f` | libdep-lab·app-lab 설치 상태 |
| 7 | 실습 | `kept back`: `apt-mark unhold` 후 업그레이드 | hello-lab 2.0, hold 없음 |
| 8 | 실습 | `unmet dependencies`: 새 버전 파일 → 색인 → update → 설치 | libdep2-lab 2.0, app2-lab 설치 |
| 9 | 객관식 | `NO_PUBKEY`: 공개키 등록과 signed-by (trusted=yes 는 오답) | |
| 10 | 빈칸 | `signed-by=` 옵션 | |
| 11 | 순서 | 설치 실패 진단 흐름 | |
| 12 | 객관식 | `Temporary failure resolving`: DNS·네트워크 확인 | |

## 수용 조건

- [x] `verify:quests --set 518` 실습 8개 전부 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종(터미널·객관식·빈칸·순서), 터미널 8/12
- [x] 힌트는 방향만 제시, 순서 문제 힌트는 순서를 알려 주지 않음
- [x] `check-content.sh` 통과
- [x] 현장 정보 없음 (`example.com` 등 일반 이름만)
