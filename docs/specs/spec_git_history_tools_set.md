# 명세 — Git 이력 다듬기와 버그 찾기 손연습 세트 (rebase · squash · bisect · clean · alias · restore --source · log -S)

> 상태: **구현 중(로컬)** (2026-11-13). 세트 373, Git 분야 `브랜치와 병합` 단원(id 14) 끝(세트 368 뒤), 아이콘 🔧, 샌드박스 `linux`. 근거: 기존 Git 실습(52~56, 94~96, 365, 368)에 없는 rebase·squash·bisect·clean·alias·restore --source·log -S. 사용자가 콘텐츠 세트를 알아서 이어 가라고 위임했다(2026-11-13).

## 목표

"bisect run 으로 나쁜 커밋 찾기 → rebase → merge --squash → clean(-n 후 -f) → alias → restore --source → 충돌 난 rebase 풀기 → merge --abort → log -S" 를 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1. **문제마다 setup 이 다르다**(저장소 상태가 문제별로 필요). 날짜는 고정해 커밋 해시가 항상 같다. 편집기 호출을 막으려 `core.editor true` 를 설정한다.
- 배경은 문제 안에 적는다(bisect·rebase·squash·clean·alias·충돌 rebase·log -S).
- 채점은 `git -C /tmp/lab/proj ...` 로 상태를 조회한다(`merge-base`, `rev-list --count`, `ls-tree`, `status --short`, 진행 중 표시 파일 유무).
- 한계: 같은 결과를 만드는 다른 명령도 통과한다(예: 1번을 수동 bisect 로, 3번을 일반 커밋으로 모아 만든 경우는 해시·메시지가 맞으면 통과).
- 문서 링크: git-scm.com/docs 의 rebase·merge·bisect·clean·restore·log·config.

## 수용 조건

- [ ] 터미널 9문제 모두 solution 으로 채점 통과 (`verify:quests -- --set 373`).
- [ ] `check-content.sh`, `check-migrations.sh` 통과, 단원 14 끝에 배치.
- [ ] 화면: 단원 `브랜치와 병합` 끝에 보이고 배경 설명이 읽기 좋게 보인다 (수동 확인).
