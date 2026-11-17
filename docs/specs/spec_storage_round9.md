# 스토리지 9차: lsblk · mkswap · swapon · wipefs 퀴즈 (세트 450~453)

작성일: 2026-11-17. 완성도 평가(`spec_category_completeness.md`)에서 낮게 나온 스토리지 분야를 보충한다.

| 세트 | 제목 | 근거 문서 | 아이콘 / 순서 |
|------|------|-----------|---------------|
| 450 | lsblk 로 블록 장치 보기 | lsblk(8) man page | 🔭 / 638 |
| 451 | mkswap 으로 스왑 영역 만들기 | mkswap(8) man page | 💤 / 639 |
| 452 | swapon·swapoff 로 스왑 켜고 끄기 | swapon(8) man page | 🔌 / 640 |
| 453 | wipefs 로 시그니처 지우기 | wipefs(8) man page | 🧽 / 641 |

스토리지 기초 단원(21) 끝. 세트마다 12문제(객관식 9, 빈칸 2, 순서 1), 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- lsblk: 열 목록, `--filter`·`--ct` 같은 실험 기능, 종료 코드는 뺐다.
- mkswap: 엔디안·오프셋·페이지 크기·`--lock` 세부, 스왑 버전은 뺐다.
- swapon: `--annotate`·`--output-all`·`--fstab` 경로 세부, swapoff 의 우선순위 동작은 뺐다.
- wipefs: 백업 복원 예시(EXAMPLE 절)와 `--lock` 세부는 뺐다.
- 컨테이너에서는 블록 장치와 스왑을 다룰 수 없어 퀴즈로만 다룬다. 순서 문제 네 개는 일반 절차이다. 화면 확인은 하지 않았다(미검증).
