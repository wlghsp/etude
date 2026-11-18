# 명세 — 도커 컨테이너 다루기 손연습 세트 (488)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `컨테이너 다루기`는 실습 0개였다). 짝 퀴즈: 171/244, 191/249, 195/250, 199/251, 203/252.

## 구성 (12문제, 세트 488, sandbox `docker`, 분야 도커)

setup 은 모든 컨테이너를 지우고 문제별 준비물을 만든다. 기존 도커 실습(231·340·343·349·478)과 겹치지 않는 옵션만 골랐다.

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `exec -u -w -e` | 출력 `hi /tmp nobody` |
| 2 | 터미널 | `rename` | 새 이름 running, 옛 이름 없음 |
| 3 | 터미널 | `--volumes-from` | 볼륨 파일 내용 |
| 4 | 터미널 | `--add-host` | `/etc/hosts` 항목 |
| 5 | 터미널 | `--cidfile` | 파일 값 = 컨테이너 ID |
| 6 | 터미널 | `--init` | `HostConfig.Init` true |
| 7 | 터미널 | `--ulimit nofile` | `ulimit -n` = 1024 |
| 8 | 터미널 | `--shm-size` | `/dev/shm` 128.0M |
| 9 | 터미널 | `--network container:` | localhost 로 상대 응답 |
| 10 | 객관식 | `--volumes-from` 의 의미 | |
| 11 | 빈칸 | `--network {0}:web` | container |
| 12 | 순서 | create → start → exec → stop·rm | |

- 거짓 통과 방지: 각 터미널 문제는 setup 만 한 상태에서 실패한다 (`verify:quests` 무행동 검사).
- 9번 응답 서버는 alpine 에 `httpd` 가 없어 `nc -l` 반복으로 만든다 (처음 `httpd` 로 만들었다가 실패해 고쳤다).

## 알려진 한계

`--sysctl`, `--pid`, `--ipc`, `--dns`, `--stop-signal`, `docker events`·`stats` 는 다루지 않았다 (후속 후보).

## 배치

도커 단원 `컨테이너 다루기`(32) 끝, display_order 190, 아이콘 🔧.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`).
- [x] 객관식 정답 DB 확인, `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 도커 탭에서 보이고 1~12번이 풀린다 (수동 확인).
