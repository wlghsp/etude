# 명세 — 세트 538 패키지 관리 입문: dnf·rpm 으로 설치·조회·제거

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N7. 샌드박스 `linux-systemd`(Rocky 9, root), 카테고리 `리눅스`, 단원 58, display_order 759. 선행: 24(rpm 조회). 겹치지 않는 세트: 518(apt 설치 실패 상황집). 생성: `scripts/content-gen/new_sets/set538.py`.

## 환경 제약 (설계의 전제)

샌드박스에 인터넷이 없을 수 있다. 직접 확인한 결과, 저장소 캐시가 없어 `dnf search/install/info 이름` 은 `Failed to download metadata` 로 실패한다(`rpmbuild`·`createrepo_c` 도 없어 로컬 저장소를 만들 수 없다). 반면 `dnf list installed`, `dnf info installed`, `dnf remove`(--assumeno 포함), `dnf history`, `rpm -q*` 는 저장소 없이 동작한다. 그래서 **저장소가 필요한 search·install 은 읽기 문제(객관식·빈칸)로 대체**하고, 설치된 패키지를 다루는 조회·제거·이력은 실습으로 한다. 제거 대상 패키지는 문제마다 다르게 해(which, vim-minimal) 문제끼리 간섭하지 않는다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `dnf info installed 패키지` | /tmp/q1.txt 에 Name·Repository @ |
| 2 | 객관식 | rpm(파일·기록)과 dnf(저장소·의존성)의 역할 차이 | |
| 3 | 실습 | `rpm -qf` 로 파일의 소속 패키지(curl → curl-minimal) | /tmp/q3.txt |
| 4 | 실습 | `rpm -qc` 설정 파일만 (-ql 과 구분) | /tmp/q4.txt, /usr 파일 없음 |
| 5 | 객관식 | 이름을 모를 때 `dnf search` (읽기형) | |
| 6 | 빈칸 | `dnf install` / `dnf remove` (읽기형) | |
| 7 | 실습 | `dnf remove --assumeno` 로 의존 패키지 미리 보기 | 목록·Operation aborted, 패키지 그대로 |
| 8 | 객관식 | `Failed to download metadata` 의 뜻과 오프라인에서 되는 명령 | |
| 9 | 실습 | `dnf remove -y which` | which 제거, bash 유지 |
| 10 | 실습 | `dnf history` 에서 제거 트랜잭션 찾아 `history info ID` | Transaction ID, Removed vim-minimal |
| 11 | 순서 | 안전한 제거 흐름(확인→미리보기→판단→제거→확인) | |

## 수용 조건

- [x] `verify:quests --set 538` 실습 6개 전부 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종(터미널 6·객관식 3·빈칸 1·순서 1), 11문제
- [x] 외부 네트워크 의존 없음 (search·install 은 읽기형)
- [x] 힌트는 방향만 제시, 순서 문제 힌트는 순서를 나열하지 않음
- [x] 현장 정보 없음
