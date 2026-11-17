# 명세 — 가상화 5차 퀴즈 세트 459·460 (qemu-img)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-17). [spec_virt_round4.md](spec_virt_round4.md)에 이어 단원 48 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다. 근거 문서는 QEMU 공식 qemu-img 문서(https://www.qemu.org/docs/master/tools/qemu-img.html).

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 459 | 48 (635, 🖼️) | qemu-img 기본 | 오프라인 도구, 실행 중 이미지 수정 경고, `-U` 공유 조회, 포맷 자동 추정, `info` 의 virtual size 와 disk size, `--backing-chain`, `check` 종료 코드(63)와 `-r leaks/all`, `resize` 축소 전 준비와 `--shrink`, 이미지 확장 순서 |
| 460 | 48 (636, 🪆) | qemu-img 백킹 체인 | `create -b` 의 차이 이미지와 백킹 파일 보호, `commit` 후 비워짐과 `-b` 의 무효화, `rebase` 지원 포맷과 `-u`, `snapshot -c/-a/-d/-l`, `compare` 종료 코드, `convert -c` 압축의 한계, 오버레이 사용 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- `bench`·`bitmap`·`amend`·`dd`·`map`·`measure`, qcow2 옵션(cluster_size·lazy_refcounts·nocow 등), qcow2 암호화 경고, 다른 포맷(vmdk·vdi 등) 세부는 뺐다.
- `create` 의 `-u`(unsafe 백킹)와 convert 의 세부 옵션(`-S`·`-W`·`-C`·`--salvage`)은 뺐다.
- 컨테이너에서는 이미지를 만들거나 VM 을 돌릴 수 없어 퀴즈로만 다룬다. 순서 문제 두 개는 일반 절차이다. 화면 확인은 하지 않았다(미검증).
