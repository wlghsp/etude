# 명세 — 세트 553 도커 이미지 작게·안전하게 만들기

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 권장 행(이미지 작게·안전하게 만들기). 샌드박스 `docker`, 카테고리 `도커`, 단원 67, display_order 813. 선행: 485(레이어 줄이기·멀티 스테이지 기초)·346(USER 기초)·521. 생성: `scripts/content-gen/new_sets/set553.py`.

중복 회피: 485·346 은 "만드는 방법"이고, 이 세트는 **크기를 재고(image ls·inspect·history) 줄었는지 확인**하는 데 초점을 둔다. 패키지 설치·빌드 도구는 `dd` 로 만든 큰 파일로 흉내 내 네트워크 없이 크기만 본다. 이미지는 alpine:3.19, nginx:1.27, nginx:1.27-alpine 만 쓴다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 기본 nginx 와 alpine 판 크기 비교(`inspect -f '{{.Size}}'`) | 더 큰 이미지의 바이트 값 |
| 2 | 객관식 | alpine·slim·기본 이미지의 차이와 주의점 | |
| 3 | 실습 | `docker history` 로 가장 큰 레이어 찾기 | 그 레이어가 만든 파일 이름 |
| 4 | 실습 | 캐시를 설치와 같은 RUN 에서 지우기 | 이미지가 alpine+5MB 이내, 결과 `ready` |
| 5 | 객관식 | 어떤 RUN 구성이 가장 작게 남는가 | |
| 6 | 실습 | 멀티 스테이지로 빌드 도구 제거 | 결과 `built-app`, 도구 파일 없음, 크기 이내 |
| 7 | 실습 | root 로 돌릴 때의 문제와 `--user 1000:1000` | 호스트 파일 소유자 uid 1000 |
| 8 | 실습 | USER app 뒤 Permission denied → chown | 결과 `saved`, 이미지 User=app |
| 9 | 객관식 | `latest` 태그의 문제(재현성) | |
| 10 | 빈칸 | `docker image ls --digests` | |
| 11 | 실습 | `FROM alpine` → `alpine:3.19` 고정 | Dockerfile 고정, 결과 3.19.x |

## 수용 조건

- [x] `verify:quests --set 553` 실습 7개 통과 (2026-11-20, 로컬 미러)
- [x] 형식 3종(터미널·객관식·빈칸), 터미널 7/11
- [x] 무행동 실패: 모든 실습의 검사는 초기 상태에 없는 결과물(저장 파일·빌드한 이미지·소유자)을 본다
- [x] hint 는 방향만, 현장 정보 없음, `check-content.sh` 통과
