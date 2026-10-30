# 명세 — 문제마다 공식 문서 링크

> 상태: **구현 완료(로컬)** (2026-10-30). 계기: "KodeKloud 는 k8s 문제 위에 문서 링크를 넣어 공식 문서를 참조하게 한다. 공식 문서를 읽는 것도 능력이다."

- `quest.docs` (JSON, 선택): `[{ "title": "Deployment", "url": "https://..." }]`. 없으면 링크 줄이 보이지 않는다.
- 문제 조회(`GET /quest-sets/:id/quests`)가 `docs` 를 내보낸다. **https 주소만** 내보내고(`javascript:`, `http:` 등은 걸러 낸다) 모양이 틀리거나 JSON 이 깨졌으면 `null` 이다 (`getQuests` 의 `parseDocs`, 테스트 2개).
- 화면: 문제 탭 맨 위에 `📖 참고 문서` 칩들. 새 탭으로 열고(`target="_blank"`, `rel="noopener noreferrer"`), 스크린리더에 "새 탭에서 열림"을 알린다.
- 링크는 **공식 출처**만 쓴다: kubernetes.io, docs.docker.com, GNU 매뉴얼(gnu.org), man7.org. 주소는 문서 구조가 바뀌면 깨질 수 있으니 주기적으로 확인한다.
- 초기화 `00_schema.sql`, 기존 DB 는 `migrations/2026-10-30_00_quest_docs.sql`, 값은 `09_quest_docs.sql` 과 `migrations/2026-10-30_zz_quest_docs.sql`.
- 검증: 백엔드 테스트(조회·https 필터·깨진 JSON), 프론트 타입 검사·빌드. 링크가 실제로 열리는지는 사람이 확인한다.
