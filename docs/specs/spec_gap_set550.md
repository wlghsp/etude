# 명세 — 세트 550 커널 매개변수·모듈 써 보기: sysctl·lsmod·modprobe

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N24. `linux-systemd` 샌드박스, 리눅스, 단원 59, display_order 809. 선행: 세트 432(sysctl 읽기·`-p`·`--system` 순서는 퀴즈로 다룸, 이 세트는 직접 쓰기·모듈로 확장하며 중복하지 않음).
> 환경 제약(직접 확인, 로컬 검증 기준): `sysctl` 읽기와 `/proc/sys` 읽기는 되지만 쓰기(`sysctl -w`, `echo > /proc/sys/...`)는 permission denied / Read-only file system. `lsmod`·`modinfo`·`modprobe`(kmod)는 이미지에 없고 호스트 모듈 목록은 호스트마다 다르다. `/etc/sysctl.d`·`/etc/modprobe.d` 는 이미지에 없어 setup 이 만든다. 따라서 읽기는 실제 `sysctl`, 모듈 출력은 샘플 파일(`/srv/lab/mod`), 설정은 파일 작성으로 구성하고, 채점은 호스트 커널 값·쓰기 성공 여부에 의존하지 않는다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `sysctl -n` 으로 값만 읽기 | ostype.txt = Linux |
| 2 | 실습 | 키 ↔ `/proc/sys` 경로, 값 읽기 | path.txt 경로·value.txt 현재 값 |
| 3 | 객관식 | `-w` 임시 변경은 재부팅 때 사라짐 | |
| 4 | 실습 | `/etc/sysctl.d/90-lab.conf` 영구 설정 파일 작성 | 두 줄 존재 |
| 5 | 실습 | `lsmod` 에서 Used by 0 인 모듈 | unused.txt = br_netfilter, dummy, veth |
| 6 | 실습 | `modinfo` 의 `parm:` 이름 추출 | parms.txt 7개 |
| 7 | 객관식 | `modprobe` vs `insmod` (의존 모듈) | |
| 8 | 빈칸 | `modprobe -r` | |
| 9 | 객관식 | 부팅 자동 로드 `/etc/modules-load.d` | |
| 10 | 실습 | `/etc/modprobe.d/lab.conf` 의 `options`·`blacklist` | 두 줄 존재 |
| 11 | 객관식 | `blacklist` 는 자동 로드만 막음 | |
| 12 | 순서 | lsmod → modinfo → modprobe → dmesg → modules-load.d | |

## 수용 조건

- [ ] `verify:quests --set 550` 실습 6개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] 힌트가 정답을 알려 주지 않고, 객관식 정답이 하나뿐
- [ ] 샘플 출력이 실제 명령 출력 형식과 일치, 특권 환경에서도 채점 결과 동일
