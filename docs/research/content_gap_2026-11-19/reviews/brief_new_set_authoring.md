# 새 세트 작성 지침 (병렬 작성, 세트 하나 담당)

저장소: /Users/jihochoi/Documents/okestro/etude  (한국어 프로젝트. 응답·문서·문제는 한국어)
목표: 콘텐츠 빈틈 보고서의 항목 하나를 **새 터미널 실습 세트**로 만든다. 계단식(새 개념 1개씩, 기초→핵심→응용), 쉽고 친절하게.

## 먼저 읽을 것
1. `docs/specs/spec_pilot_gap_sets.md` 와 `scripts/content-gen/gen_pilot_sets.py` — **이미 검증된 파일럿 3개(502·503·504)** 가 작성 방식의 본보기다. `SetBuilder` 의 nt/choice/fill/order, `chk`, `DBUP`, `CLEAN` 을 그대로 가져다 쓴다.
2. 담당 항목: 작업 지시에 있는 보고서 파일(`docs/research/content_gap_2026-11-19/gap_*.md`)의 해당 행(핵심 개념 목록·예상 문제 수).
3. 기존 비슷한 세트의 문제를 DB 에서 읽어 깊이·문체·중복 여부 확인: `docker exec etude-db mariadb -h127.0.0.1 -uroot -proot -N --raw -e "SELECT order_index,kind,title,description FROM quest WHERE quest_set_id=<ID> ORDER BY order_index" etude`. 기존 세트가 이미 가르친 것과 겹치지 말고, 선행 세트가 가르친 개념은 사전지식으로 쓴다.

## 만들 것 (파일 2개만, 공유 파일은 절대 건드리지 마라)
- `scripts/content-gen/new_sets/setNNN.py` : 파일 맨 위에 `import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *` 후 `b = SetBuilder(...)`로 문제를 정의하고, 끝에 `if __name__ == '__main__': preview(b)`. (`emit`·`SETS.append` 호출 금지 — 공유 파일 02·05·06·08·migrations 는 오케스트레이터가 나중에 한 번에 만든다.) 세트 번호 NNN, display_order, unit_id, category, sandbox 는 작업 지시를 따른다. 아이콘은 이모지 하나 직접 고른다.
- `docs/specs/spec_gap_setNNN.md` : 짧은 명세(구성 표: 번호·형식·개념·확인, 수용 조건 체크리스트). 파일럿 명세 형식을 따른다.

## 규칙
- 한 세트 9~12문제, **형식 3종 이상**(터미널 + 객관식 + 빈칸 + 순서). 터미널이 주력(보고서의 권고 비율).
- 터미널 문제: setup(환경 준비)·solution(정답 명령, 주석에 한 줄 설명)·checks(결과물을 직접 보는 조건)·description(상황·배경 포함, 옵션 뜻 설명)·hint(**정답 글자·값·순서 전체를 알려 주지 말고 찾는 방법**). **아무것도 안 하면 반드시 실패**해야 한다(검사가 초기 상태에는 없는 결과물을 본다).
- 객관식은 `b.choice(..., opts, ans, ...)` 에서 ans 는 opts 안에서의 **원래 정답 위치**(생성기가 위치를 섞는다). 순서 문제는 순서가 하나로 고정될 때만, 보기는 섞어서(정답 순서 ≠ 0..n-1). 빈칸은 후보 중 정답이 정확히 하나.
- 현장 정보(IP·도메인·회사·센터 이름) 금지. 예시 값은 `example.com`, `192.0.2.x`, 일반 이름만.
- 정확성 최우선. 확신 없는 사실은 문제로 만들지 말고, 직접 샌드박스에서 실행해 확인한다.
- 두 번째 세션이 필요하면 백그라운드(`&`) + `wait` 패턴(502 참고). 오래 떠 있는 setup 프로세스는 `nohup ... &`.

## 검증 (직접 돌린다)
1. `python3 scripts/content-gen/new_sets/setNNN.py` → 로컬 DB(etude-db)에 세트가 들어가고 `backend/verify/setNNN.json` 이 만들어진다.
2. `cd backend && npm run verify:quests -- --set NNN` → 모든 실습이 ✓ 여야 한다. 실패하면 문제를 고쳐 1·2 반복. (다른 에이전트가 동시에 샌드박스를 돌리므로 부하로 인한 일시 실패는 한 번 재실행해 본다. `pkill -f` 같은 광범위한 종료 명령은 쓰지 마라.)
3. `bash scripts/check-content.sh` 통과.

## 금지
- git 명령 쓰기(commit/add/checkout 등), 다른 세트·공유 파일 수정, DB 의 다른 세트 변경, `.env*` 읽기·출력.
- `backend/verify/setNNN.json` 과 위 2개 파일 외 새 파일 만들기(임시 파일은 스크래치패드에).

## 마지막 응답 (한 줄)
`세트 NNN: 문제 N개(실습 a), 검증 통과/실패 목록, 미해결 사항` 만.
