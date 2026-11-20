# 명세 — 세트 521 도커 문제 해결 상황집: 이미지 받기·빌드가 실패할 때

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` 필수 행(상황집: 이미지 받기·빌드가 실패할 때). 샌드박스 `docker`, 카테고리 `도커`, 단원 26 (문제 해결), display_order 742. 선행: 97(컨테이너가 안 뜰 때), 490·346(Dockerfile·COPY·CMD). 생성: `scripts/content-gen/new_sets/set521.py`.

오류 메시지 → 원인 → 고치기를 재현된 상황에서 직접 한다. 이미지는 `alpine` 만 쓴다(없으면 pull). 태그 오타(1번)는 `FROM` 의 베이스 이미지 확인 때문에 레지스트리에 접속한다(미러가 막히면 429 로 실패할 수 있다).

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 없는 태그(`not found`/`manifest unknown`) 오타 고치기 | 실행 결과 `base-ok` |
| 2 | 실습 | `COPY ../` 컨텍스트 밖 경로 | 실행 결과 `port=8080` |
| 3 | 실습 | `.dockerignore` 가 숨긴 파일 COPY | 실행 결과 `mode=prod` |
| 4 | 실습 | 실패한 `RUN`(대상 폴더 없음, exit code 1) | 실행 결과 `mode=default` |
| 5 | 실습 | 캐시 때문에 안 바뀜 → `--no-cache` | 새 결과가 옛 번호와 다름 |
| 6 | 실습 | `exec format error`(shebang 없음) | 실행 결과 `hello-from-script` |
| 7 | 실습 | `no such file or directory`(alpine 에 bash 없음) | 실행 결과 `hello-from-bash` |
| 8 | 실습 | 시작하자마자 종료(CMD 를 `&` 로 백그라운드) | `q8` 컨테이너 Running |
| 9 | 객관식 | `manifest unknown` 의 뜻 | |
| 10 | 객관식 | `apt-get: not found`(exit 127, alpine 은 apk) | |
| 11 | 빈칸 | `docker build --no-cache` | |
| 12 | 순서 | 빌드 실패 시 고치는 순서 | |

## 수용 조건

- [ ] `verify:quests --set 521` 실습 8개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(터미널·객관식·빈칸·순서), 터미널 8/12
- [ ] hint 는 방향만, 순서 문제 힌트는 순서를 알려 주지 않음
- [ ] `check-content.sh` 통과, 현장 정보 없음
