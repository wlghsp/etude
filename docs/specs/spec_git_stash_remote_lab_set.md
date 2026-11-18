# 명세 — Git 보관·원격 정리 손연습 세트 (495)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (Git 40% 목표). 로컬 bare 저장소를 원격으로 써서 네트워크 없이 연습한다.

## 구성 (12문제, 세트 495, sandbox `linux`, 분야 Git, 단원 `원격과 협업`(15) 끝, 📤)

| # | 형식 | 내용 |
|---|---|---|
| 1 | 터미널 | `stash -u` |
| 2 | 터미널 | `stash apply` (보관함 유지) |
| 3 | 터미널 | `stash branch rescue` |
| 4 | 터미널 | 태그만 `push origin v1.0` |
| 5 | 터미널 | `push origin --delete old` |
| 6 | 터미널 | `fetch --prune` |
| 7 | 터미널 | `branch --set-upstream-to`, `@{upstream}` |
| 8 | 터미널 | `--amend` 후 `push --force-with-lease` |
| 9 | 터미널 | `commit --amend --author --no-edit` |
| 10 | 객관식 | `--force` vs `--force-with-lease` |
| 11 | 빈칸 | `push origin --{0} old` (delete) |
| 12 | 순서 | 다 쓴 브랜치 정리 순서 |

- 거짓 통과 방지: 무행동 검사 통과(9/9, `검증됨`).
- 알려진 한계: 실제 원격 서비스(GitHub 인증·PR)는 다루지 않는다. 서브모듈·sparse-checkout·bundle 은 후속 후보.

## 수용 조건

- [x] `verify:quests` 9/9, 무행동 실패 확인.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: Git 탭에서 보이고 1~12번이 풀린다 (수동 확인).
