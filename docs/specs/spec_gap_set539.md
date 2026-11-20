# 명세 — 세트 539 패키지 관리 입문: apt·dpkg 조회와 rpm·dnf 대응표

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N8. 샌드박스 `linux`(Ubuntu 22.04, root), 카테고리 `리눅스`, 단원 58, display_order 760. 생성: `scripts/content-gen/new_sets/set539.py`. 518(설치 실패 상황집)과 겹치지 않게 조회·.deb 제작·제거·rpm 대응을 다룬다.

## 환경 제약 (설계의 전제)

이미지에는 apt 목록(`/var/lib/apt/lists`)이 비어 있어 `apt update` 는 네트워크가 필요하다. 그래서 외부 접속 없이 되는 것만 쓴다: `dpkg -l/-s/-S/-L/-W`(dpkg 장부 조회), 파일 읽기(`/tmp/lab-sources.list` 사본 — 실제 sources.list 는 아키텍처마다 주소가 달라 쓰지 않음), `apt-cache policy`(로컬 `file:` 저장소를 setup 이 만들고 update, 518 과 같은 방식), `dpkg-deb --build`/`dpkg -i`/`--purge`(직접 만든 .deb). rpm·dnf 는 샌드박스에 없어 객관식으로만 다룬다. 이미지 아키텍처(arm64/amd64)에 따라 달라지는 값은 check 가 동적으로 계산한다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `dpkg -l/-s` 로 bash 버전 | 파일 값 = 설치 버전 |
| 2 | 실습 | `dpkg -S` 파일의 주인 패키지(procps) | 파일 값 = 패키지명 |
| 3 | 객관식 | `dpkg -l` 상태 `ii`/`rc` | |
| 4 | 실습 | sources.list 읽기: 유효한 `deb` 줄 수 | 값 = 3 |
| 5 | 빈칸 | 배포판 코드 이름 jammy | |
| 6 | 실습 | `apt-cache policy` 후보 버전 | 값 = 2.0, 설치는 1.0 유지 |
| 7 | 순서 | control → build → -i → -s | |
| 8 | 실습 | `dpkg-deb --build` + `dpkg -i` | 설치 상태, 명령 실행 |
| 9 | 실습 | `dpkg --purge`(설정 파일까지) | conf 파일 없음, rc 아님 |
| 10 | 객관식 | lock 의미(읽기형) | |
| 11 | 객관식 | `dpkg -S` ↔ `rpm -qf` | |
| 12 | 객관식 | 틀린 대응(`apt-get update` ≠ `dnf update`) | |

## 수용 조건

- [x] `verify:quests --set 539` 실습 6개 전부 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종(터미널 6·객관식 4·빈칸·순서), 네트워크 없이 검증
- [x] 힌트는 방향만, 순서 문제 힌트는 순서를 나열하지 않음
- [x] `check-content.sh` 통과
- [x] 현장 정보 없음 (`example.com` 만 사용)
