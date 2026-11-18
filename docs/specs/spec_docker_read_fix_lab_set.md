# 명세 — Dockerfile·compose 읽고 고치기 손연습 세트 (490)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `Dockerfile·compose 읽기`는 실습 0개였다). 짝 퀴즈: 38, 39.

## 구성 (12문제, 세트 490, sandbox `docker`, 분야 도커, 단원 `Dockerfile·compose 읽기`(10) 끝, 🧾)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | COPY 경로 오류 Dockerfile 고쳐 빌드·실행 |
| 2 | 터미널 | exec 형식 CMD 에서 `$변수` 가 안 풀리는 문제 |
| 3 | 터미널 | ENTRYPOINT 유지, run 인자로 CMD 대체 |
| 4 | 터미널 | `${PORT:-8080}` 를 `PORT=9090 compose config` 로 확인 |
| 5 | 터미널 | `--profile debug config --services` |
| 6 | 터미널 | `-f base -f prod` 병합 결과 읽기 |
| 7 | 터미널 | FROM 앞 ARG + `--build-arg TAG=3.19` |
| 8 | 터미널 | `env_file` vs `environment` 우선순위 |
| 9 | 터미널 | 오타(`imag:`) 고치고 `config -q && echo valid` |
| 10 | 객관식 | run 인자는 CMD 만 대체 |
| 11 | 빈칸 | `docker compose --{0} debug` (profile) |
| 12 | 순서 | Dockerfile 고치고 확인하는 순서 |

## 알려진 한계·운영 메모

- 7번은 `alpine:3.19` 를 Docker Hub 에서 받는다(네트워크 필요). 검증 중 Docker Hub 익명 요청 한도(429, 시간당 100회)에 걸려 한 번 중단됐다. 샌드박스가 매번 Hub 에서 `alpine` 을 받으므로 **동시 접속이 많으면 학습자도 같은 한도에 걸릴 수 있다** (운영 위험, 미검증).

## 수용 조건

- [x] 터미널 9문제 `verify:quests` 9/9, 무행동 실패 확인 (`검증됨`).
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 도커 탭에서 보이고 1~12번이 풀린다 (수동 확인).
