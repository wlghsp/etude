# 명세 — 세트 555 docker context 와 원격 데몬

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 의 "docker context 와 원격 데몬" 행. 샌드박스 `docker`, 카테고리 `도커`, 단원 66, display_order 815. 생성: `scripts/content-gen/new_sets/set555.py`.
> 범위: context 는 만들기·전환·확인만 한다(원격 접속 없음, 주소는 `192.0.2.x`). 532(도커 보안)와 겹치지 않게 docker 그룹·소켓 위험은 다루지 않고 2375 평문 노출만 다룬다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | context = 이름 + 데몬 접속 정보 | |
| 2 | 실습 | ssh 주소 context 만들기, inspect 로 주소 추출 | context 존재, 설명, 저장된 주소 |
| 3 | 객관식 | ssh:// 방식의 동작과 전제(SSH 로그인·docker 권한) | |
| 4 | 실습 | 로컬 소켓 context 만들고 use 로 전환, show, 되돌리기 | 저장 이름 alt, 현재 default |
| 5 | 객관식 | DOCKER_HOST 가 context 선택보다 우선 | |
| 6 | 실습 | 깨진 context 선택 상태에서 `--context default` 로 한 번만 우회 | 목록에 webapp, 선택은 broken 유지 |
| 7 | 객관식 | 2375 평문·무인증 노출 위험, 대안(ssh·TLS 2376) | |
| 8 | 빈칸 | `host=ssh://...` | |
| 9 | 순서 | SSH 확인 → create → use → 사용 → default 복귀 | |

## 수용 조건

- [x] `verify:quests -- --set 555` 실습 3개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 터미널 3/9
- [x] hint 는 방향만, 순서 문제 힌트는 순서를 나열하지 않음
- [x] `check-content.sh` 통과, 현장 정보 없음
