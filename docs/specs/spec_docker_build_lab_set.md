# 명세 — 도커 이미지 빌드 손연습 세트 (485)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md). 기존 도커 실습이 거의 다루지 않은 멀티 스테이지·`--target`·`ARG`→`ENV`·`.dockerignore`·빌드 캐시·레이어를 손으로 해 본다. 짝 퀴즈: 167/243(이미지 빌드 읽기), 154/241(Dockerfile 심화·멀티스테이지), 218/257(이미지 목록과 빌드).

## 구성 (12문제, 세트 485, sandbox `docker`, 분야 도커)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | 멀티 스테이지 Dockerfile 직접 작성 | 실행 출력 `built`, 최종 이미지에 `/out.txt` 없음 |
| 2 | 터미널 | `--target build` | 이미지에 `/out.txt` 있음, `/app.txt` 없음 |
| 3 | 터미널 | `--build-arg VERSION=2.5` | 실행 출력 `2.5` |
| 4 | 터미널 | `ARG` → `ENV` | `printenv APP_V` = 3 |
| 5 | 터미널 | `.dockerignore` | `keep.txt` 있음, `secret.env` 없음 |
| 6 | 터미널 | 캐시 확인 (`CACHED`/`--no-cache`) | 진행 출력의 RUN 줄이 CACHED / DONE |
| 7 | 터미널 | `RUN` 합쳐 레이어 줄이기 | 레이어 수 2 |
| 8 | 터미널 | `-f Dockerfile.prod` | 실행 출력 `prod` |
| 9 | 터미널 | `-t` 두 번 (태그 2개) | 두 태그의 이미지 ID 동일 |
| 10 | 객관식 | `ARG` 의 유효 범위 | 빌드 중에만 |
| 11 | 빈칸 | `docker build --{0} build` (target) | |
| 12 | 순서 | 멀티 스테이지 작성 순서 | |

- 6번은 처음에 "캐시 빌드끼리 이미지 ID 가 같다"로 설계했으나, 이 환경(BuildKit, Docker 28)에서는 **캐시를 써도 생성 시각 때문에 ID 가 달라져** 실패했다(`verify:quests` 로 발견). 그래서 `--progress=plain` 출력의 `CACHED`/`DONE` 표시로 판정한다.
- setup 은 이전 컨테이너·이미지·`/tmp/work` 를 지우고 `alpine` 이 없으면 받는다. 근거: 도커 공식 문서(멀티 스테이지, 빌드 변수, 빌드 컨텍스트, 캐시, buildx build).

## 알려진 한계

`--cache-from`·`--mount=type=cache`(BuildKit 캐시 마운트), `docker buildx bake`, 이미지 서명·SBOM, 빌드 비밀(`--secret`)은 다루지 않았다. 6번의 `CACHED` 표시는 BuildKit 기반 빌더를 전제로 한다.

## 배치

도커 단원 `이미지와 Dockerfile`(33) 끝, display_order 211, 아이콘 🧅.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`).
- [x] 객관식 정답을 DB 에서 확인한다. `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 도커 탭에서 보이고 1~12번이 풀린다 (수동 확인).
