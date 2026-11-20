# 명세 — 세트 529 도커 문제 해결 상황집: 레지스트리 오류 읽기

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md`(상황집 계열). 샌드박스 `docker`, 카테고리 `도커`, 단원 26 (문제 해결), display_order 750. 선행: 521(이미지 받기 실패). 세트 528(레지스트리 쓰기)에는 의존하지 않고, 각 문제의 setup 이 로컬 레지스트리(`registry:2`, `localhost:5000`)를 직접 띄워 이미지를 올린다. 생성: `scripts/content-gen/new_sets/set529.py`.

이미지를 받을 때 레지스트리가 돌려주는 오류를 재현해 읽고 고친다. Docker Hub 에는 접속하지 않는다(베이스 `alpine` 만 미러에서 받음). 레지스트리 `localhost:5000` 에는 `team/app`(1.0·1.1), `team/worker`(1.0), `tools/cli`(1.0) 이 있고 `latest` 는 일부러 없다. 7번 로그인 문제만 htpasswd 가 걸린 `localhost:5001`(실습용 계정 `student`)을 쓴다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 태그 오타(`not found`/`manifest unknown`), 태그 목록 API(`/v2/<repo>/tags/list`) | tags.txt 에 1.0·1.1, `team/app:1.1` 받음 |
| 2 | 실습 | `latest` 가 없는 레지스트리, 태그 생략 = latest | 가장 높은 태그 실행 출력 `app-1.1` |
| 3 | 객관식 | `latest` 는 태그 이름일 뿐 | |
| 4 | 실습 | 저장소 이름 오타, 카탈로그 API(`/v2/_catalog`) | repos.txt, 출력 `worker-1.0` |
| 5 | 실습 | `invalid reference format`(대문자 저장소 이름) | 출력 `app-1.0` |
| 6 | 실습 | `connection refused`(레지스트리 컨테이너 중지) → `docker start` | `reg` Running, 출력 `app-1.1` |
| 7 | 실습 | `server gave HTTP response to HTTPS client`, 루프백(localhost) 예외 | err6.txt 에 메시지, `localhost:5000/team/app:1.0` 받음 |
| 8 | 빈칸 | `daemon.json` 의 `insecure-registries` | |
| 9 | 실습 | `unauthorized`/`no basic auth credentials` → `docker login` | 출력 `private-1.0`, 이미지 받음 |
| 10 | 객관식 | `pull access denied, repository does not exist or may require docker login` 이 둘을 함께 말하는 이유 | |
| 11 | 객관식 | 오류별 원인 구분(서버 닿음 vs 연결·이름 해석·프로토콜) | |
| 12 | 순서 | HTTP 레지스트리 정석 해결(읽기→daemon.json→재시작→재시도) | |

## 수용 조건

- [ ] `verify:quests --set 529` 실습 7개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(터미널·객관식·빈칸·순서), 터미널 7/12
- [ ] 7번은 샌드박스에서 데몬 설정·재시작이 불가능하므로 `localhost` 루프백 우회로 고치고, 정석(insecure-registries)은 8·12번에서 읽기로 다룬다
- [ ] hint 는 방향만, 순서 문제 힌트는 순서를 알려 주지 않음
- [ ] 각 setup 이 앞 문제의 컨테이너(볼륨 포함)·`localhost:` 이미지·로그인 정보·작업 파일을 먼저 지운다
- [ ] `check-content.sh` 통과, 현장 정보 없음 (예시 주소는 `localhost`·`192.0.2.x`·`example.com`)
