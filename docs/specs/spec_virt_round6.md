# 명세 — 가상화 6차 퀴즈 세트 461~463 (libvirt 도메인 XML: 이벤트, 디스크)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-17). [spec_virt_round5.md](spec_virt_round5.md)에 이어 단원 48 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다. 근거 문서는 libvirt Domain XML format(https://libvirt.org/formatdomain.html)의 Events configuration, Power Management, Hard drives·floppy disks·CDROMs 절.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 461 | 48 (637, 🔔) | libvirt 이벤트 동작 | `on_poweroff`·`on_reboot`·`on_crash`, destroy·restart·preserve, QEMU 금지 조합, `coredump-destroy`·`preserve-running`, `on_lockfailure` 의 pause, `pm` 절전 광고의 한계, 설치 후 재구성 순서 |
| 462 | 48 (638, 💿) | libvirt disk 요소 | `disk` 의 역할, `type`·`device`(기본 disk)·`lun`, `snapshot` 모드, cdrom 의 읽기 전용, `startupPolicy`(기본 mandatory), `target dev` 가 순서 힌트, `bus` 추정, 디스크 추가 순서 |
| 463 | 48 (639, 🎚️) | libvirt 디스크 driver | qemu 드라이버 name, `cache` 의 directsync·unsafe, `error_policy`(enospace)와 `rerror_policy`, `io`, `discard`, `copy_on_read`, `iotune` 의 0, `transient`, I/O 제한 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 문제마다 원문 링크.

## 수용 조건

1. 마이그레이션 재실행 시 0개 적용. 2. `check-content.sh`·`check-migrations.sh` 통과. 3. 12문제, 분야 내 display_order·아이콘 중복 없음. 4. 정답 길이 경고 0.

## 알려진 한계

- 이벤트: `rename-restart`(libxl 전용)와 `virDomainSetLifecycleAction` API 는 빈칸 설명에서만 언급했다. 하이퍼바이저별 지원 차이는 다루지 않았다.
- 디스크: 소스 세부(네트워크 프로토콜별 host·auth), 암호화, 스로틀 그룹(`throttlegroups`), `serial`·`address`, `detect_zeroes`·`iothread`·`ioeventfd`·`event_idx` 세부는 뺐다.
- 문서의 `since` 버전 표기는 문제에 넣지 않았다. 컨테이너에서는 libvirt 를 실행할 수 없어 퀴즈로만 다룬다. 순서 문제 세 개는 일반 절차이다. 화면 확인은 하지 않았다(미검증).
