# 명세 — Git 병합 충돌 손연습 세트 (477)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md). 퀴즈 184/324(병합 전략·충돌 도구)가 `--ours`·`-X`·`rerere` 를 읽기만 해서 손으로 해 보는 짝 세트로 만든다. 476(rebase 손연습)과 한 쌍이다.

## 목표

병합 충돌을 만났을 때 하는 일(손으로 풀기, 취소, 한쪽 고르기, 전략 옵션, 충돌 파일 목록, 같은 충돌 재활용)과 병합 방식(`--ff-only`, `--no-ff`)을 직접 쳐서 익힌다.

## 구성 (12문제, 세트 477, sandbox `linux`, 분야 Git)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | 충돌 손으로 풀고 병합 커밋 | MERGE_HEAD 없음, mode=both, 병합 커밋 1개 |
| 2 | 터미널 | `merge --abort` | 충돌 때 `UU f.txt` 저장 + 원래 상태 복귀 |
| 3 | 터미널 | `checkout --theirs` | mode=feature, 병합 커밋 |
| 4 | 터미널 | `merge -X theirs` | 충돌 없이 mode=feature |
| 5 | 터미널 | `merge -s ours` | mode=main, feature 가 조상 |
| 6 | 터미널 | `--ff-only` (실패 종료 코드 + 성공) | q6≠0, main==feature, 병합 커밋 0 |
| 7 | 터미널 | `--no-ff` | 병합 커밋, 제목, 두 번째 부모 |
| 8 | 터미널 | `diff --name-only --diff-filter=U` | f.txt, g.txt 만 |
| 9 | 터미널 | `rerere` | 켜짐, rr-cache, 두 번째 병합 자동 해결 |
| 10 | 객관식 | `-X ours` 와 `-s ours` 의 차이 | |
| 11 | 빈칸 | `git merge --{0}` (abort) | |
| 12 | 순서 | rerere 재활용 순서 | |

- 2번은 아무것도 안 해도 저장소가 원래 상태라, 충돌 때의 `git status -s` 를 파일로 남기게 해 "충돌을 실제로 만들었는지"를 확인한다 (거짓 통과 방지).
- 근거: git-merge·git-rerere 공식 문서, Pro Git "고급 병합".

## 알려진 한계

`merge.conflictStyle`(diff3), `git mergetool`, `--squash` 병합, 서브트리 병합, `git revert -m` 은 다루지 않았다.

## 배치

Git 단원 `병합과 이력 다듬기 심화`(49) 끝(476 다음), display_order 429, 아이콘 🧩. 단원이 12세트가 되었다.

## 수용 조건

- [x] 터미널 9문제의 `solution` 이 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`).
- [x] 각 문제 `docs` 에 git-merge·git-rerere·Pro Git 링크가 있다.
- [x] 객관식 정답을 DB 에서 확인한다.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: Git 탭에서 보이고 1~12번이 풀린다 (수동 확인).
