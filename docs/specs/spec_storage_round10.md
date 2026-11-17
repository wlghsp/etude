# 스토리지 10차: mkfs.xfs · xfs_repair · xfs_growfs 퀴즈 (세트 454~456)

작성일: 2026-11-17. 완성도 평가(`spec_category_completeness.md`)에서 낮게 나온 스토리지 분야를 보충한다.

| 세트 | 제목 | 근거 문서 | 아이콘 / 순서 |
|------|------|-----------|---------------|
| 454 | mkfs.xfs 로 XFS 만들기 | mkfs.xfs(8) man page | ⚙️ / 642 |
| 455 | xfs_repair 로 XFS 수리하기 | xfs_repair(8) man page | 🔨 / 643 |
| 456 | xfs_growfs 로 XFS 늘리기 | xfs_growfs(8) man page | 📏 / 644 |

스토리지 기초 단원(21) 끝. 세트마다 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- mkfs.xfs: 데이터·inode·로그·이름·실시간 영역 옵션과 기능 플래그(crc·reflink·bigtime 등)의 세부, 설정 파일 형식, protofile 은 뺐다.
- xfs_repair: `-o` 하위 옵션, `-c`, `-m`, 쿼터 검증, 진단 메시지 목록, `-d` 의 세부는 뺐다.
- xfs_growfs: 실시간 영역(-r·-e), `-t`, 축소 동작의 세부는 뺐다. 축소는 문서가 부분 구현이라고 적어 문제로 만들지 않았다.
- 컨테이너에서는 XFS 를 만들거나 수리할 수 없어 퀴즈로만 다룬다. 순서 문제 세 개는 일반 절차이다. 화면 확인은 하지 않았다(미검증).
- 아이콘: 🧱 이 같은 분야의 세트 61 과 겹쳐 454 는 ⚙️ 로 바꿨다.
