# 스토리지 분야 콘텐츠 빈틈 분석

분석 기준: audit/merged.json 의 스토리지 단원 3개(21, 70, 71), DB 의 quest_set/quest 조회(읽기 전용), 일부 세트 문제 본문 확인(376, 377, 393, 410, 456).
연관 분야 참고: OpenStack(359·386 Cinder, 391 Swift), 리눅스(226 df/du 실습, 338 tar 백업 실습, 129/260 용량 한 줄씩), 도커(352), k8s(208/309 PVC 일부), 데이터베이스(109 MariaDB 백업, 118 Redis 백업).

## 요약

- 현재 스토리지 분야는 세트 27개(단원 3개), 문제 326개 전부가 `quiz`(choice 246 / fill 53 / order 27)다. **터미널 실습 세트가 0개(0%)**. 세트마다 choice 9 + fill 2 + order 1 로 형식이 똑같다. 세트 61 만 choice 12 / fill 1 / order 1 이다.
- 깊이는 "도구 옵션 암기"에 치우쳐 있다. mke2fs·fsck·tune2fs·fdisk·mkswap·xfs_* 같은 개별 명령 옵션 세트가 18개(442~458 등)인 반면, 운영자가 실제로 겪는 **용량 부족·I/O 성능 저하·디스크 장애·마운트 실패** 흐름을 다루는 세트는 없다.
- 가장 큰 빈틈 3개: (1) **터미널 실습 전무**(루프 디바이스·LVM·mdadm·mkfs·마운트·확장을 실제로 해 보는 세트 없음), (2) **용량·성능 진단**(df/du 는 리눅스 226 에 있으나 inode 고갈·삭제됐지만 열린 파일·iostat·fio 는 없음), (3) **백업·복구·스냅샷 개념**(3-2-1, RPO/RTO, 증분/차등, 복원 테스트, 스냅샷≠백업이 스토리지 분야에 없음)과 **장애 대응 상황집**.
- 그 외 필수급 빈틈: iSCSI·멀티패스 실제 흐름, Ceph 의 CRUSH·RBD·용량 경고(nearfull/full)·scrub, 파일시스템 기초(inode·저널·ext4 vs XFS 비교)가 "기초 세트" 없이 옵션 세트로 바로 시작하는 문제.
- 단원 구성 문제: 단원 21 내 순서 역전(61 이 맨 앞인데 376/377 개념을 전제), 단원 70/71 내 선수 지식 역전(447 fstab → 444 fsck, 457 fdisk → 451/453), 410 과 442 lvcreate 중복(audit 이슈). 신규 세트 도입 시 단원 재편이 필요하다.

## 참고 커리큘럼

학습자는 사내 인프라 운영자(리눅스·k8s·OpenStack 운영). 현장 우선. 활용도 낮은 주제(FC 스위치 존 설정, ZFS/Btrfs 심화, 테이프, 중복제거 알고리즘, GlusterFS 등)는 제외.

| # | 영역 | 핵심 주제 |
|---|------|-----------|
| D1 | 스토리지 개념 | 블록·파일·오브젝트, DAS·NAS·SAN, 매체(HDD·SSD·NVMe), IOPS·처리량·지연 시간, 읽기/쓰기 패턴(순차·랜덤) |
| D2 | 디스크·블록 장치·파티션 | /dev 이름(sd·nvme·vd), 섹터·블록, lsblk·blkid, MBR vs GPT, fdisk·parted, 파티션 정렬, 디스크 추가 후 재스캔, 루프 디바이스 |
| D3 | 파일시스템 기초 | inode·블록·슈퍼블록·저널, ext4 vs XFS 비교, mkfs, mount·umount, fstab, 마운트 옵션(noatime·ro), 확장·축소(resize2fs, xfs_growfs), 점검·복구(fsck, xfs_repair) |
| D4 | 용량 진단 | df·du, inode 고갈, 삭제됐지만 열려 있는 파일(lsof), 예약 블록, 큰 파일·디렉터리 찾기, 로그·캐시 정리, thin 과대 할당 |
| D5 | 성능 진단 | iostat(await·%util·큐), iotop, vmstat·%iowait, 페이지 캐시, fio 로 측정, I/O 스케줄러, 병목 위치 판단(디스크/네트워크/CPU) |
| D6 | LVM | PV·VG·LV, 생성·확장·축소, 스냅샷, thin pool, 디스크 교체(pvmove), 장치 이름(/dev/mapper), 메타데이터 백업·복구 |
| D7 | RAID | 레벨별 용량·내결함성(0/1/5/6/10), mdadm 생성·운영, /proc/mdstat 읽기, 디스크 교체와 재구축, 핫스페어, 하드웨어 vs 소프트웨어 RAID, RAID≠백업 |
| D8 | 네트워크 파일/블록 | NFS(서버·클라이언트·옵션·장애), SMB/CIFS 개념, iSCSI(target·initiator·LUN·IQN), 멀티패스, FC/SAN 개념 |
| D9 | 오브젝트 스토리지 | S3 API 개념(버킷·객체·키), 버저닝, 수명주기, 멀티파트, 일관성, Swift·RGW |
| D10 | Ceph | 구성요소(MON·OSD·MGR·MDS·RGW), CRUSH·PG·풀, RBD·CephFS·RGW, 상태 읽기(ceph -s·df), 장애·복구·nearfull/full, scrub |
| D11 | 클라우드·컨테이너 스토리지 연계 | Cinder 볼륨, PV·PVC·StorageClass·CSI, 볼륨 확장, 스냅샷, 퍼시스턴트 데이터와 컨테이너 수명 |
| D12 | 백업·복구 | 3-2-1, RPO·RTO, 전체·증분·차등, rsync·tar, 스냅샷 vs 백업, 일관성(앱 정지·freeze), 복원 테스트, 보존 정책 |
| D13 | 데이터 보호·효율 | 복제 vs 이레이저 코딩, 장애 도메인, thin provisioning, 압축·중복제거 개념, 쿼터 |
| D14 | 보안·암호화 | 파일 권한·ACL, NFS 접근 제어, LUKS(dm-crypt) 개념, 삭제·초기화(wipe) |
| D15 | 하드웨어·모니터링 | SMART, SSD 마모, RAID 컨트롤러·캐시·BBU, 디스크 장애 징후, 용량 추세 모니터링 |
| D16 | 장애 대응(상황집) | 디스크 가득 참, 읽기 전용 전환, 마운트 안 됨, 부팅 멈춤(fstab), RAID degraded, NFS stale·hang, LVM 활성화 실패, Ceph HEALTH_WARN/ERR |

## 커버리지 표

깊이: 없음 / 얕음 / 보통 / 충분. 형식: Q=개념 퀴즈만, T=터미널 실습 포함. 스토리지 분야 세트는 전부 Q.

| 영역 | 주제 | 다루는 세트(id) | 깊이 | 형식 |
|------|------|-----------------|------|------|
| D1 | 블록·파일·오브젝트 | 376 | 보통 | Q |
| D1 | DAS·NAS·SAN 용어 | 없음 | 없음 | - |
| D1 | HDD·SSD·NVMe 차이, IOPS·처리량·지연 | 없음 | 없음 | - |
| D2 | lsblk·blkid | 446, 450 | 충분(옵션 암기형) | Q |
| D2 | MBR vs GPT, fdisk | 457, 458 (453 wipefs) | 보통(옵션 위주) | Q |
| D2 | parted, 파티션 정렬 실습 | 458 일부(정렬) | 얕음 | Q |
| D2 | 디스크 추가 후 재스캔, /dev 이름 규칙, 루프 디바이스 | 없음 | 없음 | - |
| D3 | inode·블록·저널 개념 | 443·445 일부(암기 중 일부만) | 얕음 | Q |
| D3 | ext4 vs XFS 비교·선택 기준 | 없음 | 없음 | - |
| D3 | mke2fs·mkfs.xfs | 443, 454 | 충분(옵션 암기형) | Q |
| D3 | mount·마운트 옵션(noatime·ro·bind) | 447 일부, 리눅스 135/263 일부 | 얕음 | Q |
| D3 | fstab, findmnt, umount | 447, 448, 449 | 보통 | Q |
| D3 | 확장(xfs_growfs, lvextend -r) | 456, 410 | 보통 | Q |
| D3 | resize2fs(ext4 확장·축소) | 없음 (410 이 "전제"만) | 없음 | - |
| D3 | fsck·xfs_repair·tune2fs | 444, 455, 445 | 보통 | Q |
| D3 | 스왑 | 451, 452 | 보통 | Q |
| D4 | df·du·큰 파일 찾기 | 리눅스 226(실습), 129/260 | 보통 | T(리눅스 분야) |
| D4 | inode 고갈, 삭제됐지만 열린 파일(lsof), 예약 블록으로 인한 "찬 것 같지 않은데 가득" | 144/264 의 inode 개념 일부, 443·445 예약 블록(옵션) | 얕음 | Q |
| D4 | 도커 디스크 정리 | 352 | 보통 | T(도커 분야) |
| D5 | iostat·iotop·await·%util | 없음 | 없음 | - |
| D5 | fio·페이지 캐시·%iowait | 없음 | 없음 | - |
| D6 | PV·VG·LV 개념·생성·확장 | 377, 410, 411, 442 | 충분(442 는 410 중복) | Q |
| D6 | LVM 스냅샷·thin | 410, 442(옵션 수준) | 얕음 | Q |
| D6 | pvmove 로 디스크 교체 | 377, 411 | 보통 | Q |
| D6 | LVM 장애(VG 인식 안 됨, 메타데이터 복구, 비활성 LV) | 없음 | 없음 | - |
| D7 | RAID 0/1/5 개념·용량 | 376 | 보통 | Q |
| D7 | RAID 6·10, 핫스페어, 재구축 시간·위험 | 440 일부(레벨) | 얕음 | Q |
| D7 | mdadm 생성·운영·교체 | 440, 441 | 보통 | Q |
| D7 | /proc/mdstat 출력 읽기 | 441 일부 추정 | 얕음 | Q |
| D8 | NFS 서버·클라이언트 | 398, 399 (376 개념) | 충분(옵션 암기형) | Q |
| D8 | NFS 장애(stale file handle, hang, 권한 거부) | 399 일부(hard/soft) | 얕음 | Q |
| D8 | iSCSI 개념 | 376 (용어 수준) | 얕음 | Q |
| D8 | iSCSI 실제 흐름(discovery·login·LUN·IQN), 멀티패스, FC/SAN | 없음 | 없음 | - |
| D8 | SMB/CIFS | 없음 | 없음 | - |
| D9 | S3 개념·버저닝·수명주기 | 없음(376 에 "S3 HTTP API" 한 줄) | 얕음 | Q |
| D9 | Swift(링·핸드오프·EC), RGW | OpenStack 391, 377(RGW 한 줄) | 보통 | Q |
| D10 | Ceph 구성요소·복제·쿼럼 | 377, 61 | 보통 | Q |
| D10 | OSD up/down·in/out, PG 상태, 풀 size/min_size | 393 | 보통 | Q |
| D10 | CRUSH·장애 도메인, RBD·CephFS, ceph df, nearfull/full, scrub·inconsistent, 리밸런싱 | 없음 | 없음 | - |
| D11 | Cinder 볼륨·스냅샷·백업 | OpenStack 359, 386 | 보통 | Q |
| D11 | PV·PVC·StorageClass | k8s 208/309(PVC 일부), 120 | 얕음 | Q |
| D11 | CSI·볼륨 확장·동적 프로비저닝 | 없음(추정, k8s 분야 점검 필요) | 없음 | - |
| D12 | tar·cp -a·체크섬 백업 실습 | 리눅스 338 | 보통 | T(리눅스 분야) |
| D12 | DB 백업·복원 | 데이터베이스 109, 118 | 보통 | T |
| D12 | 3-2-1, RPO·RTO, 전체/증분/차등, 스냅샷≠백업, 복원 테스트, rsync 증분 | 376("RAID≠백업" 1문항), VM 스냅샷 394, Cinder 386(증분) | 얕음(원칙 없음) | Q |
| D13 | 복제 vs 이레이저 코딩 | 391(Swift EC), 377(Ceph 복제) | 얕음 | Q |
| D13 | thin provisioning·압축·중복제거·쿼터 | 410(thin pool 옵션) | 얕음 | Q |
| D14 | LUKS·ACL·쿼터 | 없음 | 없음 | - |
| D14 | 안전 삭제(wipefs 시그니처) | 453 | 보통(wipe 의 의미 위주) | Q |
| D15 | SMART·SSD 마모·디스크 장애 징후 | 없음 | 없음 | - |
| D15 | RAID 컨트롤러·캐시·BBU, 용량 추세 모니터링 | 없음 | 없음 | - |
| D16 | 상황집(장애 대응) | 없음(스토리지 분야). 리눅스 339 류 k8s 상황집은 있으나 스토리지 아님 | 없음 | - |

확인한 깊이(문제 본문 표본): 376 은 정의 한 줄씩 묻는 choice 위주 + 용량 계산 fill 1 + 순서 1. 393 은 OSD·PG 상태 정의 암기. 410 은 lvcreate 옵션·lvreduce 전 할 일. 456 은 xfs_growfs 옵션(-d·-D·-n·-m·-i) 설명 맞히기. 즉 "개념 정의/옵션 의미" 수준이고 **출력 읽기·진단·복구 의사결정**은 거의 없다. 단 한 세트에 출력 읽기형 문제가 있는지는 전수 확인하지 않았다(추정: 거의 없음).

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

| # | 빈틈 | 근거 |
|---|------|------|
| G1 | **스토리지 터미널 실습 전무** (루프 디바이스에 파티션·파일시스템·마운트·확장·복구를 직접 해 보기) | 27세트 전부 quiz. 도커·k8s·리눅스·DB·Git 은 터미널 세트가 있는데 스토리지만 0%. |
| G2 | **LVM 실습**(PV→VG→LV→mkfs→mount→확장→스냅샷→pvmove) | 377·410·411·442 모두 quiz. 실제 확장 순서(lvextend 후 파일시스템 확장)를 직접 해 본 적 없음. 410 이 "파일시스템 확장 전제"만 하고 가르치는 곳 없음(audit 이슈). |
| G3 | **RAID 실습**(mdadm 생성→장애 주입→교체→재구축, /proc/mdstat 읽기) | 440·441 quiz. RAID 장애 대응은 운영자 핵심 업무. |
| G4 | **용량 진단**: inode 고갈, 삭제됐지만 열린 파일(lsof), 예약 블록, "df 와 du 가 다르다" | df/du 기본은 리눅스 226 뿐. 스토리지 분야에 "디스크 가득 참" 대응 흐름 없음. 현장 최빈 장애. |
| G5 | **파일시스템 기초(inode·블록·저널·ext4 vs XFS)** | 443 앞에 기초 세트 없음(audit 이슈: "암기에 가깝다"). 445 저널·예약 블록 전제 미교육. |
| G6 | **백업·복구 원칙**(3-2-1, RPO·RTO, 전체/증분/차등, 스냅샷≠백업, 복원 테스트) | 분야 내 "백업" 문항은 376 의 RAID≠백업 1문항뿐. 작업 지시 기준(백업 개념)에 해당하는 세트 없음. |
| G7 | **장애 대응 상황집**(디스크 가득, 읽기 전용 전환, 마운트 실패, RAID degraded, NFS hang 등) | 스토리지 상황집 0개. |
| G8 | **성능 진단**(iostat·await·%util·iowait, fio 측정) | 성능 진단 세트 없음. 작업 지시 기준(용량·성능 진단). |

### 권장

| # | 빈틈 | 근거 |
|---|------|------|
| G9 | **iSCSI 실제 흐름**(target·initiator·IQN·LUN·discovery·login, 멀티패스 개념, SAN/FC 위치) | 376 에 이름 수준만. NFS 는 두 세트인데 iSCSI 는 0세트. |
| G10 | **Ceph 심화**: CRUSH·장애 도메인, RBD/CephFS/RGW 사용처, ceph -s·df 읽기, nearfull/full, scrub·inconsistent, 리밸런싱·backfill | 377/393 은 구조와 상태 정의까지. 실제 `ceph -s` 출력 해석과 용량 경고 대응 없음. |
| G11 | **디스크 추가·재스캔·장치 이름 규칙**(sd/vd/nvme, 핫애드 후 인식, udev 이름 변동과 UUID 사용 이유) | 450·446 은 옵션 암기. VM·OpenStack 에서 볼륨을 붙인 뒤 OS 에서 쓰는 마지막 구간이 없음(359 Cinder 와 연결 필요). |
| G12 | **ext4 확장·축소(resize2fs)** 와 파티션·LV 확장 연계 | 456 은 XFS 만, 410 은 "전제". ext4 가 기본인 환경이 많음. |
| G13 | **스토리지 매체·성능 개념**(HDD·SSD·NVMe, IOPS·처리량·지연, 순차·랜덤, RAID 쓰기 패널티) | 전체 분야에 개념 없음. 성능 진단(G8) 선행. |
| G14 | **LVM 스냅샷·thin 과대 할당·VG 장애 복구**(인식 안 됨, 비활성, 메타데이터 백업) | 410/442 가 옵션 수준. |
| G15 | **k8s·OpenStack 스토리지 연계**: PV·PVC·StorageClass·CSI·볼륨 확장, Cinder 볼륨을 VM 에서 파일시스템 올리기 | k8s 208/309 의 PVC 일부 외 없음(추정, k8s 분야 분석과 교차 확인). 단원 소속 조정 필요. |
| G16 | **SMART·디스크 장애 징후·SSD 마모·모니터링 항목** | 없음. |
| G17 | **S3 오브젝트 스토리지 개념**(버킷·키·버저닝·수명주기·멀티파트·프리사인드 URL) | 376 한 줄, 391 은 Swift 심화. 사내에서 Ceph RGW/Swift 사용 시 입문용 필요(추정). |

### 선택

| # | 빈틈 | 근거 |
|---|------|------|
| G18 | LUKS(디스크 암호화) 개념과 기본 실습 | 전혀 없음. 현장 활용도는 환경에 따라 다름. |
| G19 | 쿼터·ACL | 없음. 공유 스토리지(NFS) 운영에서 가끔. |
| G20 | SMB/CIFS 개념 | 없음. 리눅스 인프라 중심이면 낮음. |
| G21 | 복제 vs 이레이저 코딩 비교, 중복제거·압축 개념 | 391·377 에 일부. 비교 정리 세트는 선택. |
| G22 | 하드웨어 RAID 컨트롤러·캐시·BBU 개념 | 현장 접근성 낮음(클라우드·가상화 중심이면). |

제외(활용도 매우 낮음): FC 스위치 존 구성, ZFS·Btrfs 심화, 테이프 백업, GlusterFS, 파일시스템 내부 비트맵 해부, CHS 지오메트리 상세.

## 신규 세트 백로그

전제 환경 메모 (중요):
- 현재 sandbox 테이블에는 스토리지용 환경이 없다. `linux`(etude-linux)는 일반 실습용이다. 루프 디바이스·LVM·mdadm·mount 는 보통 **특권(privileged) 컨테이너** 또는 `CAP_SYS_ADMIN` 과 `/dev/loop*`·`/dev/mapper` 접근이 필요하다(추정, 실제 etude-linux 이미지의 권한은 확인하지 않음). 신규 sandbox 타입 `linux-storage`(lvm2·mdadm·xfsprogs·e2fsprogs·util-linux·parted·fio·sysstat·lsof 설치, 호스트와 격리된 환경) 설계가 선행되어야 한다. 보안상 호스트 디바이스는 노출하지 않고 `truncate` 로 만든 sparse 파일 + `losetup` 만 쓴다.
- 특권이 불가하면 대체: `linux` 환경에서 sparse 이미지 파일에 `mkfs.ext4 -F`, `mkfs.xfs`, `fdisk`/`parted`(파일 대상), `mkswap`, `e2fsck`, `xfs_repair`, `dumpe2fs`, `tune2fs`, `resize2fs`, `blkid`, `wipefs` 는 마운트 없이 실행 가능(추정). 마운트·LVM·mdadm·iSCSI·NFS 서버는 불가 → 이 부분은 **출력 읽기 실습**(setup_cmd 로 미리 만든 `/proc/mdstat`·`lvs`·`ceph -s`·`iostat` 출력 파일을 읽고 진단하는 문제, `df`·`du`·`lsof` 는 실제 파일 생성으로 가능)으로 설계.
- 각 세트 12문제 기준(기존 규칙: 한 세트 형식 3종 이상, 객관식 편중 금지). 터미널 세트는 `linux`/`linux-storage` 로 실제 명령을 채점한다.
- 현장 정보(IP·호스트명 등)는 일반 예시 값(`/dev/loop0`, `vg0`, `md0`)만 쓴다.

### A. 필수

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P1-1 | 디스크 가득 참 대응 실습: df·du, inode 고갈, 삭제됐지만 열린 파일 | 터미널 실습 | 신규 단원 "용량 진단과 정리"(스토리지 분야, 단원 21 뒤) | 리눅스 226(df/du) | ① df 와 du 가 다른 이유 → ② inode 고갈(`df -i`, 작은 파일 수만 개) → ③ 삭제했는데 안 줄어듦(`lsof +L1`, 프로세스 재시작/truncate) → ④ 예약 블록·마운트 아래 가려진 파일 → ⑤ 정리 순서(로그 로테이션·큰 파일 찾기) | 12 |
| P1-2 | 파일시스템이란: 블록·inode·저널, ext4 와 XFS 고르기 | 개념 퀴즈(+출력 읽기) | 단원 70 맨 앞(443 보다 앞) | 없음 | ① 블록·inode·슈퍼블록 → ② 저널링과 비정상 종료 → ③ ext4 vs XFS(확장·축소, 용도) → ④ 마운트와 마운트 포인트 | 12 |
| P1-3 | 루프 디바이스로 디스크 만들기: 파티션→mkfs→마운트→확장 | 터미널 실습 | 신규 단원 "스토리지 실습 입문"(단원 70 의 앞 또는 단원 21 뒤) | P1-2, 450 lsblk, 457 fdisk 기초 | ① `truncate`+`losetup` → ② 파티션(fdisk/parted) → ③ mkfs.ext4/xfs → ④ mount·fstab 한 줄(nofail) → ⑤ 파일 확장(`truncate` 늘리고 `losetup -c`, resize2fs/xfs_growfs) → ⑥ umount·정리 | 12 |
| P1-4 | LVM 직접 해 보기: 만들고, 늘리고, 디스크 바꾸기 | 터미널 실습 | 단원 21 뒤 신규 단원 "LVM·RAID 실습" | P1-3, 377, 410, 411 | ① pvcreate·vgcreate·lvcreate → ② 마운트 후 데이터 기록 → ③ vgextend+lvextend -r 로 무중단 확장 → ④ 스냅샷으로 되돌리기 → ⑤ pvmove·vgreduce 로 PV 교체 → ⑥ `pvs/vgs/lvs` 출력 읽기 | 12 |
| P1-5 | mdadm 으로 RAID 만들고 장애 내기 | 터미널 실습 | 단원 21 뒤 "LVM·RAID 실습" | P1-3, 440, 441 | ① RAID1/5 생성 → ② `/proc/mdstat`·`--detail` 읽기 → ③ `--fail`·`--remove` 로 장애 주입 → ④ 새 디스크 `--add`, 재구축 관찰 → ⑤ `mdadm --detail --scan` 으로 설정 저장 → ⑥ 두 번째 장애로 데이터 손실 확인(RAID5 한계) | 12 |
| P1-6 | 백업의 기본: 3-2-1, RPO·RTO, 전체·증분·차등, 스냅샷은 백업이 아니다 | 개념 퀴즈(시나리오 위주) | 신규 단원 "백업과 복구"(스토리지 분야 맨 끝) | 376(RAID≠백업) | ① 백업이 필요한 이유(삭제·변조·장애·재해) → ② 3-2-1 → ③ RPO·RTO → ④ 전체/증분/차등 복원 순서 → ⑤ 스냅샷·복제·백업 구분 → ⑥ 복원 테스트와 보존 정책 | 12 |
| P1-7 | 백업·복원 직접 해 보기: rsync 증분, tar, 복원 검증 | 터미널 실습 | 단원 "백업과 복구" | P1-6, 리눅스 338 | ① rsync -a·--delete 시험(-n) → ② `--link-dest` 증분 스냅샷 방식 → ③ 체크섬 비교 → ④ 일부 파일 복원 → ⑤ 복원 테스트 습관 | 10 (338 과 겹치지 않게 tar 기초 제외) |
| P1-8 | 스토리지 장애 상황집 (1/2): 디스크·파일시스템 | 상황집(터미널 재현) | 신규 단원 "스토리지 장애 상황집" | P1-1, P1-3 | ① No space left on device → ② 읽기 전용으로 재마운트됨(`remount-ro`) → ③ 부팅 중 fstab 오류(emergency)와 nofail → ④ `wrong fs type, bad superblock` → ⑤ `target is busy` → ⑥ xfs 로그 손상·`xfs_repair` 순서 | 12 |
| P1-9 | 스토리지 장애 상황집 (2/2): RAID·LVM·NFS | 상황집(터미널 재현 + 출력 읽기) | 단원 "스토리지 장애 상황집" | P1-4, P1-5, 398/399 | ① md degraded 판단과 교체 → ② VG 에 PV 가 없음(missing) → ③ LV 비활성(`lvchange -ay`) → ④ NFS `Stale file handle` / `Permission denied`(squash) / hang(hard) → ⑤ 장애 시 데이터부터 지키는 순서 | 12 |
| P1-10 | I/O 성능 읽기: iostat·iowait·fio | 개념 + 터미널(fio 가능, iostat 출력은 파일 읽기 병행) | 신규 단원 "용량·성능 진단"(P1-1 과 같은 단원) | P1-1, 매체 개념(P2-1 권장) | ① IOPS·처리량·지연 → ② `iostat -x` 의 await·%util·aqu-sz → ③ `%iowait` 와 CPU 구분 → ④ fio 로 순차/랜덤 읽기·쓰기 측정(작은 파일) → ⑤ 병목이 디스크인지 네트워크인지 가르기 | 12 |

### B. 권장

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념 | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P2-1 | 스토리지 매체와 성능 용어: HDD·SSD·NVMe, IOPS·처리량·지연, RAID 쓰기 비용 | 개념 퀴즈 | 단원 21 맨 앞(376 앞) 또는 376 바로 뒤 | 없음 | ① 매체별 강점 → ② IOPS vs MB/s → ③ 순차·랜덤 → ④ RAID 별 쓰기 패널티 → ⑤ 큐·지연 | 10 |
| P2-2 | iSCSI 동작 흐름: target·initiator·IQN·LUN, 멀티패스 | 개념 퀴즈(출력 읽기 포함) | 단원 21 에서 NFS 뒤 | 376 | ① target/initiator → ② IQN·LUN → ③ discovery→login→새 블록 장치 → ④ 파일시스템은 클라이언트가 만든다(공유 주의) → ⑤ 멀티패스 개념, `multipath -ll` 읽기 → ⑥ iSCSI vs NFS vs FC 선택 | 12 |
| P2-3 | 디스크 붙이고 쓰기까지: 새 볼륨 인식, 장치 이름, UUID | 터미널 실습(루프로 모사)+상황 | 단원 "스토리지 실습 입문" | P1-3, 446 | ① 새 디스크 인식(`lsblk`, 재스캔 개념) → ② 장치 이름이 바뀌는 이유 → ③ UUID 로 fstab → ④ OpenStack/Cinder·VM 디스크 확장 후 OS 안에서 파티션·파일시스템 확장 순서 | 10 |
| P2-4 | ext4 확장·축소: resize2fs, 파티션·LV 와 순서 | 터미널 실습 | 단원 "LVM·RAID 실습" 또는 70 | P1-3, 410 | ① ext4 온라인 확장 → ② 축소는 언마운트+fsck+resize2fs 후 LV 축소 → ③ XFS 는 축소 불가 → ④ 순서 틀리면 데이터 손상(읽고 고치기) | 10 |
| P2-5 | Ceph 상태 읽기: ceph -s, df, nearfull·full, scrub | 개념 퀴즈(출력 읽기 중심) | 단원 21 의 393 뒤 또는 별도 단원 "Ceph 운영" | 377, 393 | ① `ceph -s` 구성 읽기 → ② HEALTH_OK/WARN/ERR 원인 → ③ `ceph df`·nearfull/backfillfull/full 비율 → ④ scrub·inconsistent PG → ⑤ 리밸런싱·backfill 이 느린 이유 | 12 |
| P2-6 | Ceph 구조 2: CRUSH·장애 도메인, RBD·CephFS·RGW 고르기 | 개념 퀴즈 | "Ceph 운영" 단원 | 377 | ① CRUSH 가 데이터 위치를 정함 → ② 장애 도메인(호스트·랙) → ③ RBD(블록)/CephFS(파일)/RGW(오브젝트) 매핑(376 개념 연결) → ④ OpenStack·k8s 가 Ceph 를 쓰는 방식(61 연결) | 10 |
| P2-7 | LVM 문제 복구: 스냅샷 가득 참, thin 과대 할당, PV missing, 메타데이터 백업 | 상황집(출력 읽기+터미널) | 단원 "LVM·RAID 실습" 뒤 | P1-4 | ① 스냅샷이 가득 차면 무효화 ② thin pool 사용률 감시 ③ `vgcfgbackup/vgcfgrestore` ④ 비활성 VG 활성화 | 10 |
| P2-8 | 컨테이너·쿠버네티스 스토리지 연계: PV·PVC·StorageClass·CSI·볼륨 확장 | 개념 퀴즈 + k8s 실습 | k8s 분야 단원 협의(스토리지 분야 단원 아님이 더 자연스러움) | k8s 208/309 | ① PV·PVC 바인딩 → ② StorageClass 동적 프로비저닝 → ③ 접근 모드(RWO/RWX)와 NFS·Ceph 연결 → ④ 볼륨 확장·스냅샷 | 12 (k8s 분야 분석 결과와 교차해 중복 방지) |
| P2-9 | S3 오브젝트 스토리지 입문: 버킷·객체·버저닝·수명주기 | 개념 퀴즈 | 단원 "오브젝트·Ceph" | 376, OpenStack 391 | ① 버킷·키·메타데이터 → ② 버저닝·삭제 마커 → ③ 수명주기·만료 → ④ 멀티파트·프리사인드 URL → ⑤ 파일 시스템과 다른 점(디렉터리 없음, 일관성) | 10 |
| P2-10 | 디스크 건강 점검: SMART, SSD 마모, 장애 징후, 모니터링 항목 | 개념 퀴즈(출력 읽기) | 단원 "스토리지 장애 상황집" 앞 | P2-1 | ① SMART 주요 속성(재할당 섹터·대기 섹터·온도) → ② SSD 마모·쓰기량 → ③ 교체 시점 → ④ 감시할 지표(용량 추세·I/O 지연·RAID 상태) | 10 |

### C. 선택

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념 | 예상 문제 수 |
|---|---|---|---|---|---|---|
| P3-1 | LUKS 디스크 암호화 맛보기 | 터미널 실습 | 단원 "스토리지 실습 입문" 확장 | P1-3 | luksFormat·open·mkfs·close, 키 분실 시 복구 불가 | 8 |
| P3-2 | 쿼터와 ACL 로 공유 공간 관리 | 터미널 실습 | 신규 | 리눅스 권한 | setfacl·getfacl, 쿼터 개념 | 8 |
| P3-3 | 복제 vs 이레이저 코딩 비교와 효율(압축·중복제거) | 개념 퀴즈 | "Ceph 운영" 단원 | 377, 391 | 사용 가능 용량 계산, 복구 부하 | 8 |

백로그 요약: 필수 10개, 권장 10개, 선택 3개 (합계 23). 우선 제작 권고는 **P1-1, P1-3, P1-4, P1-5, P1-8**(실습 기반 확보) → P1-2, P1-6, P1-10 → P1-7, P1-9 순.

### 단원 재편 제안 (기존 세트 이동만, 신규 아님)

- 단원 21 "스토리지 기초": 61(OpenStack 구분)을 이 단원에서 빼서 376·377 뒤로(또는 OpenStack 단원으로). NFS(398·399), LVM(410·411), RAID(440·441), Ceph(393)로 주제별 묶음. 442 는 410 과 중복이므로 삭제 또는 (1/2)(2/2) 쌍으로 재정의(audit 이슈).
- 단원 70/71: 순서를 "개념(P1-2) → 식별(446·450) → 파티션(457·458·453) → 파일시스템 생성(443·454) → 마운트·fstab(447·448) → 점검(444·455·445) → 확장(456) → 분리(449) → 스왑(451·452)"로 재배치(audit 의 order_in_unit·prereq_gap 이슈 해소).

## 형식 균형

현재: 스토리지 분야 27세트, 터미널 0%, choice 75%(246/326), fill 16%, order 8%. 세트마다 9/2/1 고정 패턴(audit 추정과 일치). 다른 분야는 리눅스 40/114(35%), 도커 21/66, k8s 39/113, 미들웨어 16/36, Git 15/43, DB 14/35 가 터미널 세트다.

권고:
- **세트 수 기준 터미널 비중 25~35% 를 목표.** 현재 27세트 + 신규 23세트가 되면 터미널 8~9개(P1-1, 1-3, 1-4, 1-5, 1-7, 1-8, 1-9, 1-10 일부, 2-3, 2-4)로 약 25~30%. 필수 터미널 세트(P1-1, 1-3, 1-4, 1-5, 1-8) 5개를 먼저 만들면 기초 확보.
- **실습이 반드시 필요한 영역인데 퀴즈뿐인 곳**: LVM(377·410·411·442), RAID(440·441), 파일시스템 생성·마운트·확장(443·454·456), 마운트·fstab(447·448·449), 점검·복구(444·455), 파티션(457·458). 이 영역은 각 단원 뒤에 "손연습" 세트를 붙인다(P1-3, P1-4, P1-5, P2-4).
- **퀴즈로 충분한 영역**(실습 환경 불가 또는 비용 큼): NFS 서버·클라이언트 옵션(398·399), iSCSI, Ceph(운영·구조), S3, 매체·성능 개념. 단, 정의 암기 대신 **출력 읽기·시나리오 판단·읽고 고치기(설정 한 줄, `ceph -s`, `mdstat`, `iostat -x`)** 문제로 형식을 바꾼다. 기존 세트(특히 398·399·444·447·457)는 choice 9 → 5~6 으로 줄이고 `읽고 고치기`/`출력 해석`형 4~5 문제로 교체 권고(추정, 문제 수 변경 시 채점 영향 확인).
- 세트 내 고정 패턴(choice→fill→order) 완화: 터미널 세트는 `실행 후 검증(grade_cmd)` 위주, 퀴즈 세트는 형식 3종 이상.
- 실습 환경 가정: 루프 디바이스·LVM·mdadm 은 특권 필요. 불가 시 "파일 대상 mkfs/fsck/xfs_repair + 출력 파일 읽기"로 대체(위 전제 환경 메모 참고). NFS·iSCSI·Ceph 는 실습 불가(또는 비용 과다)로 판단, 퀴즈·출력 읽기로 유지.

## 상황집

현황: 스토리지 분야에 "오류 메시지 → 원인 → 해결"을 재현하는 상황집 세트는 **0개**. 간접적으로 리눅스(226 df/du 실습)·도커(352 정리)·k8s(339 깨진 Pod 진단)에 유사 형식이 있으나 스토리지 장애를 다루지 않는다. 기존 스토리지 세트에서 장애 판단 문제가 있는 곳은 376 문제 9(RAID 는 백업 아님), 399(NFS hard/soft), 393(OSD down 복구 순서), 441(디스크 교체 순서) 정도로 **개념 질문 형태**다.

필요한 시나리오(재현 가능성 표시: ◎ 특권 없이도 가능 / ○ 특권 필요 / △ 출력 읽기로 대체):

| # | 증상(오류 메시지) | 원인 후보 | 해결 흐름 | 재현 | 세트 |
|---|------------------|-----------|-----------|------|------|
| S1 | `No space left on device` (df 는 여유) | inode 고갈 | `df -i` → 파일 수 많은 디렉터리 찾기 → 정리 | ◎ | P1-1 |
| S2 | 파일 지웠는데 용량 그대로 | 삭제됐지만 프로세스가 열고 있음 | `lsof +L1` → 프로세스 재시작/truncate | ◎ | P1-1 |
| S3 | df 와 du 가 크게 다름 | 마운트 아래 가려진 파일, 예약 블록 | `du -x`, 마운트 확인 | ◎(마운트는 ○) | P1-1 |
| S4 | `Read-only file system` | 오류로 remount-ro | 로그(`dmesg`) 확인 → 언마운트 → fsck → 재마운트 | ○ | P1-8 |
| S5 | `wrong fs type, bad option, bad superblock` | 파일시스템 없음/손상, 잘못된 타입 | `blkid`·`file -s` → mkfs 전 데이터 확인 → `fsck`/`xfs_repair` | ◎(이미지 파일) | P1-8 |
| S6 | `target is busy` | 사용 중 프로세스 | `lsof`/`fuser` → 정리 → umount(-l 의 위험) | ○ | P1-8 |
| S7 | 재부팅 후 emergency mode | fstab 오타·없는 UUID | nofail 의 의미, `findmnt --verify` 로 사전 점검 | ◎(--verify) | P1-8 |
| S8 | XFS `Structure needs cleaning` | 비정상 종료 후 로그 손상 | 마운트로 로그 재생 → 실패 시 `xfs_repair`, `-L` 은 최후 | ◎(이미지 파일) | P1-8 |
| S9 | `/proc/mdstat` 에 `[U_]` | RAID 디스크 장애 | `--detail` → 고장 디스크 식별 → 교체 → 재구축 관찰 | ○ 또는 △ | P1-9 |
| S10 | `Couldn't find device with uuid` | VG 의 PV 사라짐 | `pvs`, `vgreduce --removemissing`, 백업 메타데이터 | ○ 또는 △ | P1-9, P2-7 |
| S11 | LV 가 inactive / 마운트 안 됨 | 비활성 | `lvchange -ay`, `vgchange -ay` | ○ | P1-9 |
| S12 | NFS `Stale file handle` | 서버 쪽 export/파일 바뀜 | 재마운트, 서버 export 확인 | △ | P1-9 |
| S13 | NFS `Permission denied` (root 로 쓰기) | root_squash | exports 옵션 읽고 고치기 | ◎(설정 파일 읽기) | P1-9 |
| S14 | NFS 마운트 후 명령이 멈춤(hang) | hard 마운트 + 서버 다운 | `timeo/soft` 의미와 위험 판단 | △ | P1-9 |
| S15 | 서비스 I/O 지연, 디스크 100% | 병목 디스크 | `iostat -x` 로 %util·await 읽기, 원인 프로세스(iotop) | △ | P1-10 |
| S16 | Ceph `HEALTH_WARN: nearfull osd`, `HEALTH_ERR: pg inconsistent` | 용량 편중, scrub 오류 | `ceph df`·`ceph osd df`·`ceph health detail` 읽기 → 대응 | △ | P2-5 |
| S17 | 볼륨 확장 후에도 OS 에서 크기 그대로 | 파티션·파일시스템 미확장 | `lsblk` → growpart/resize → 파일시스템 확장 | ○ 또는 △ | P2-3 |

상황집 설계 원칙: 오류 메시지를 먼저 보여 주고(학습자가 읽도록) → 원인 가설 → 확인 명령 → 해결, 마지막에 "처음부터 막으려면"(nofail, 모니터링)으로 마무리한다. 데이터가 걸린 작업(`-L`, `-f`, `lvreduce`)은 "하기 전에 확인할 것"을 한 문제로 꼭 넣는다.
