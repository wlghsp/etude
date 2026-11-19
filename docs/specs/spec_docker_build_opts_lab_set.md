# 명세 — 도커 Dockerfile·빌드 옵션 손연습 세트 (501)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-19). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (도커 40% 목표). 겹치지 않는 주제: --target, STOPSIGNAL, ONBUILD, COPY --chmod, ADD 압축 해제, EXPOSE, -t 여러 번, commit --change, 빌드 시크릿.

## 구성 (12문제, 세트 501, sandbox `docker`, 분야 도커, 단원 `Dockerfile 심화와 이미지 실습(67)` 끝, 🪤)

1~9 터미널(위 주제 순서), 10 객관식(ONBUILD 실행 시점), 11 빈칸(`--{0}`), 12 순서(빌드 시크릿)

- 이미지는 `alpine` 하나만 써서 Docker Hub 요청 한도 소모를 줄였다.
- 알려진 한계: 시크릿이 `docker history` 에 없는지는 파일 존재만 확인한다.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인 (`검증됨`).
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: 탭에서 보이고 1~12번이 풀린다 (수동 확인).
