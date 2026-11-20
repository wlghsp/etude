# 명세 — 세트 528 사설 레지스트리 쓰기: 이름 구조·tag·push·pull·login

> 상태: 작성 (2026-11-19). 샌드박스 `docker`, 카테고리 `도커`, 단원 33, display_order 749. 선행: 도커 기초(이미지·컨테이너·포트), 볼륨(세트 520). 생성: `scripts/content-gen/new_sets/set528.py`.

`registry:2` 를 `localhost:5000` 으로 띄워 tag → push → pull 과 카탈로그·태그 목록 확인을 직접 하고, 볼륨 보관과 login 개념(인증 레지스트리는 환경 제약상 개념 문제)을 익힌다. localhost 는 http 접속이 허용되므로 TLS 설정 없이 동작한다. API 확인은 샌드박스 기본 도구 `wget -qO-` 를 쓴다. 이미지는 `alpine`, `registry:2` 만 쓴다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 이름 구조 `주소:포트/저장소:태그` | |
| 2 | 실습 | `docker run -d --name reg -p 5000:5000 registry:2` | reg 실행 중, `/v2/` 응답 |
| 3 | 실습 | `docker tag` 로 주소 붙은 이름 만들기 | 새 이름 존재 |
| 4 | 실습 | `docker push` | 카탈로그에 myalpine |
| 5 | 실습 | `/v2/_catalog` 저장 | 파일에 repositories·app·tools |
| 6 | 빈칸 | 카탈로그 주소 `_catalog` | |
| 7 | 실습 | `/v2/app/tags/list` 저장 | 파일에 tags·1.0·2.0 |
| 8 | 실습 | 레지스트리에서 pull 후 다른 이름 tag | `myapp:local`, 출처 localhost:5000/app |
| 9 | 객관식 | 주소 생략 시 `docker.io/library/…:latest` | |
| 10 | 객관식 | 주소 없는 이름 push 거부(denied) 원인 | |
| 11 | 실습 | 레지스트리 데이터 볼륨(`regdata`) | 마운트 확인 |
| 12 | 객관식 | `docker login`·`logout`, `~/.docker/config.json` | |
| 13 | 순서 | 띄우기→tag→push→rmi→pull | |

## 수용 조건

- [ ] `verify:quests --set 528` 실습 7개 전부 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(터미널·객관식·빈칸·순서), 터미널 7/13
- [ ] hint 는 방향만, 순서 문제 힌트는 순서를 알려 주지 않음
- [ ] `check-content.sh` 통과, 현장 정보 없음
