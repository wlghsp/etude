# 명세 — 세트 532 도커 보안 기본: 권한·소켓·시크릿

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_docker.md` (도커 보안). 샌드박스 `docker`, 카테고리 `도커`, 단원 66, display_order 753. 생성: `scripts/content-gen/new_sets/set532.py`.
> 겹침 방지: 160(옵션 퀴즈)·242(빈칸)·340(자원·권한 옵션 실습)이 `--user`·`--read-only`·`--cap-drop` 옵션 자체를 다루므로, 이 세트는 docker 그룹·docker.sock·시크릿 노출에 무게를 두고 옵션은 6·7번에서 "겹쳐 쓰기"로만 다룬다. 이미지는 `alpine` 만 쓴다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | docker 그룹 = 호스트 root 급 권한 | |
| 2 | 실습 | 호스트 폴더를 붙인 컨테이너가 root 소유 파일을 만듦 | 파일 내용, 소유자 UID 0 |
| 3 | 객관식 | docker.sock 마운트가 위험한 이유 | |
| 4 | 실습 | 소켓·docker 바이너리를 붙인 컨테이너 안에서 호스트 컨테이너 목록 | 목록에 `target-app` |
| 5 | 객관식 | 소켓에 `:ro` 를 붙여도 안전하지 않다 | |
| 6 | 실습 | 컨테이너 안 root 와 `--user 1000:1000` 의 `id` 비교 | 두 `id` 출력 |
| 7 | 실습 | `--user`·`--read-only`·`--cap-drop ALL`·`--tmpfs` 겹쳐 실행 | inspect 값, `/tmp` 쓰기 성공·`/` 쓰기 실패 |
| 8 | 실습 | ENV 로 넣은 비밀번호가 `docker history --no-trunc` 에 보임 | 저장 출력에 값 |
| 9 | 실습 | `docker inspect` 로 `-e` 환경변수 읽기 | 저장 출력에 값 |
| 10 | 실습 | 시크릿을 읽기 전용 파일로 런타임 주입 | 파일 읽힘, RW=false, Env 에 값 없음 |
| 11 | 빈칸 | `usermod -aG docker alice` | |
| 12 | 순서 | 노출된 시크릿 정리 (확인→무효화→ENV 삭제→재빌드→런타임 주입) | |

## 수용 조건

- [ ] `DOCKER_REGISTRY_MIRROR=http://host.docker.internal:5055 npm run verify:quests -- --set 532` 실습 7개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(터미널·객관식·빈칸·순서), 터미널 7/12
- [ ] hint 는 방향만, 순서 문제 힌트는 순서를 나열하지 않음
- [ ] 4번은 호스트의 `docker` 실행 파일을 컨테이너에 붙여 쓴다 (alpine 에 docker CLI 가 없음). 샌드박스에서 검증됨
- [ ] `check-content.sh` 통과, 현장 정보 없음 (예시 비밀번호·토큰은 데모 값)
