# 가상화 분야 빈틈 분석

분석 대상: `quest_set.category='가상화'` 19개 세트(380·381·394·395·406·407·416·417·459·460·461·462·463·464·465·473·474·475, 그리고 55). 근거: DB 조회(세트·문제 형식), `audit/merged.json` 의 가상화 단원 3개(가상화 기초 / qemu-img·장치 설정·virsh 객체 명령 / 용어 지도), 세트 380·395·459 문제 본문 직접 확인.

## 요약

- 현재 수준: **libvirt/QEMU 의 "설정 옵션 사전"은 두껍고(XML 요소·virsh 객체 명령·qemu-img), 가상화 자체의 원리와 운영 실무는 거의 없다.** 19개 세트 전부 `sandbox_type=quiz`, 문제는 세트당 choice 9 + fill 2 + order 1 = 12문항 고정(55번만 10/1/1). **터미널 실습 0개.** 공개 기준으로는 "libvirt 옵션 이름은 아는데 VM 을 직접 만들고 고쳐 본 적은 없는" 상태.
- 가장 큰 빈틈 3개:
  1. **가상화 원리·CPU/메모리 가상화 없음**: 하이퍼바이저 유형, 풀·반·하드웨어 보조 가상화(VT-x/EPT), vCPU 오버커밋, 메모리 balloon·KSM·스왑, 호스트 준비 확인(`/dev/kvm`, `lscpu`, nested)이 어느 세트에도 없다(380 은 KVM·QEMU·libvirt 관계 + virtio 정도).
  2. **VM 생성·게스트 연동·장애 대응 실습 없음**: `virt-install`, cloud-init, 콘솔 접속, qemu-guest-agent 사용, `/var/log/libvirt/qemu` 로그 읽기, "VM 이 안 뜬다/안 켜진다/느리다" 상황집이 전무. 퀴즈만으로는 "오류 메시지 → 원인 → 해결"을 훈련할 수 없다.
  3. **가상 네트워크·디스크 성능 계층의 실제 구성이 비어 있음**: Linux bridge 를 실제로 만들어 VM 을 붙이는 흐름, OVS, vhost-net/multiqueue, SR-IOV·PCI 패스스루, nwfilter, 디스크 I/O 튜닝의 관찰(측정)이 없고 옵션 이름만 퀴즈로 존재한다. 또 컨테이너와의 차이는 55(제품 지도)의 한두 문항에 그친다.
- 부수 문제: 단원 순서가 "장치별→대응 virsh 명령" 흐름이 아님(audit 지적), 380 은 한 세트에 개념 6개를 넣음. 위 빈틈 신규 세트를 넣으며 기초 단원을 앞에 재배치하는 것을 권장한다.

## 참고 커리큘럼

대상: 사내 인프라 운영자(KVM 기반 사설 클라우드 운영, OpenStack/RHV 연계 맥락). 입문~중급, 현장 우선. 영역 14개.

| # | 영역 | 핵심 주제 |
|---|------|----------|
| D1 | 가상화 개념·하이퍼바이저 | 가상화 목적, Type1/Type2, 풀·반·하드웨어 보조 가상화, KVM/QEMU/libvirt 역할(380), TCG, VMware·Hyper-V·Xen·Proxmox 위치 |
| D2 | 호스트 준비·VM 생성 | VT-x/AMD-V 확인, `/dev/kvm`, `lscpu`/`kvm-ok`, 모듈(`kvm_intel`), nested, `virt-install`, ISO·cloud image·cloud-init, 콘솔(`virsh console`·VNC/SPICE), 기본 디렉터리·XML 위치 |
| D3 | libvirt 구조·XML | libvirtd/virtqemud, 연결 URI(`qemu:///system` vs session), 도메인 XML 골격, `virsh dumpxml/edit`, 영구/일시 정의, 이벤트 동작 |
| D4 | virsh 운영 | list·start·shutdown·destroy·reboot·suspend·undefine·autostart·`dominfo`·`domstate`·`domstats`·`domifaddr`·`domblklist` |
| D5 | CPU 가상화·튜닝 | vcpu, 소켓/코어/스레드 토폴로지, cpu mode(host-passthrough/model), vcpupin·emulatorpin·shares·quota, 오버커밋, steal time, NUMA |
| D6 | 메모리 가상화·튜닝 | memory/currentMemory, balloon, hugepages, KSM, 오버커밋·스왑·OOM, NUMA, 메모리 핫플러그, virtiofs |
| D7 | 가상 디스크·이미지 | raw/qcow2, 씬 프로비저닝, `qemu-img` info/create/resize/convert/check/snapshot/백킹 체인, 사파스/`virt-sparsify`, 디스크 장치 XML, 버스(virtio-blk/scsi/sata), cache·io·discard |
| D8 | 스토리지 풀·볼륨 | 풀 종류, 풀·볼륨 virsh, 공유 스토리지(NFS·iSCSI·Ceph), 디스크 확장·게스트 내 파일시스템 확장 |
| D9 | 가상 네트워크 | NAT/route/isolated, Linux bridge, macvtap, OVS, VLAN, 인터페이스 model(virtio)·vhost-net·멀티큐, bandwidth, nwfilter, SR-IOV·PCI 패스스루, dnsmasq/DHCP |
| D10 | 스냅샷·백업·복제 | 내부/외부 스냅샷, managedsave, 체크포인트·증분 백업, 복제(`virt-clone`), 일관성(fsfreeze·guest agent), 백업 전략 |
| D11 | 라이브 마이그레이션 | 사전 조건, 제어 방식, 스토리지 복사, 대역폭·다운타임·post-copy, CPU 모델 호환, 실패 원인 |
| D12 | 게스트 연동·자동화 | qemu-guest-agent, cloud-init, `virt-customize`/`guestfs`, `virsh qemu-agent-command`, 시간 동기화, 콘솔 로그 |
| D13 | 성능·리소스 관리·모니터링 | `virt-top`/`domstats`, cgroup 연계, I/O 쓰로틀(iotune), steal/ready 해석, 오버커밋 정책, 병목 식별 순서 |
| D14 | 컨테이너와의 차이·보안·장애 대응 | VM vs 컨테이너(격리·성능·이미지), KubeVirt 맥락(55), sVirt/SELinux·AppArmor, 로그 위치, 부팅 실패·디스크 잠금·마이그레이션 실패·네트워크 불통 상황집 |

제외(활용도 낮음): Xen 세부, VMware ESXi 운영 세부, Windows 게스트 드라이버 세부, TPM·vTPM·secure boot 세부(선택으로만 언급).

## 커버리지 표

형식 약어: Q=개념 퀴즈(choice/fill/order)만, T=터미널 실습 포함. 현재는 전부 Q.

| 영역 | 주제 | 다루는 세트 | 깊이 | 형식 |
|------|------|-------------|------|------|
| D1 | KVM·QEMU·libvirt 관계, TCG, 도메인 | 380 (q1~5) | 보통 | Q |
| D1 | Type1/Type2, 풀·반·하드웨어 보조 가상화 | 없음 | 없음 | - |
| D1 | VM vs 컨테이너 격리 차이 | 55 (q7) 1문항, 77(도커) 일부 | 얕음 | Q |
| D1 | 제품 지도(RHV·OSP·OCP·vSphere·KubeVirt) | 55 | 보통 | Q |
| D2 | VT-x/`/dev/kvm`/모듈/nested 확인 | 없음 | 없음 | - |
| D2 | virt-install, ISO/cloud image 설치, cloud-init, 콘솔 | 없음 | 없음 | - |
| D3 | 도메인 XML 골격, `dumpxml/edit`, URI | 380 일부, 395(q11 URI) | 얕음(전용 세트 없음; audit 지적) | Q |
| D3 | 이벤트 동작(on_poweroff·on_crash 등) | 461 | 충분(옵션 사전식) | Q |
| D4 | list/shutdown/destroy/suspend/define/autostart/save | 381 | 보통 | Q |
| D4 | dominfo·domstats·domifaddr·domblklist·console·reboot·reset | 없음 | 없음 | - |
| D5 | vcpu·cputune·cpu mode | 406 | 보통(XML 문법 중심) | Q |
| D5 | CPU 토폴로지·오버커밋·steal time·NUMA 배치 판단 | 407(numatune 일부) | 얕음 | Q |
| D5 | 하드웨어 가상화 원리(VMX, 2단계 주소 변환 EPT) | 없음 | 없음 | - |
| D6 | memory·currentMemory·hugepages·numatune·virtiofs | 407 | 보통 | Q |
| D6 | balloon·KSM·메모리 오버커밋·OOM | 없음 | 없음 | - |
| D7 | qcow2/raw, 스냅샷 개념, 구멍(sparse) | 380 (q7·q8) | 얕음 | Q |
| D7 | qemu-img info/check/resize | 459 | 보통 | Q |
| D7 | 백킹 체인·commit·rebase·convert·compare | 394(q8~10), 460 | 보통(460 과밀) | Q |
| D7 | disk XML(type·device·target·lun), driver(cache·io·discard·iotune) | 462, 463 | 충분(옵션 사전식) | Q |
| D7 | 이미지 변환 실무(thin→thick, sparsify, 게스트 FS 확장) | 없음 | 없음 | - |
| D8 | 풀 종류·볼륨 | 417, 474 | 보통 | Q |
| D8 | 풀 만들기·볼륨 만들어 VM 에 붙이는 전체 흐름 | 없음 | 없음 | - |
| D9 | forward 모드(nat·route·isolated·bridge), default | 416, 473 | 보통 | Q |
| D9 | interface 유형·macvtap 모드·옵션 | 464, 465 | 보통(465 나열형) | Q |
| D9 | 호스트 브리지 만들기 | 475 (iface-bridge) | 얕음 | Q |
| D9 | Open vSwitch(ovs-vsctl, VLAN 포트) | 없음 | 없음 | - |
| D9 | vhost-net/멀티큐/virtio 성능, SR-IOV·PCI 패스스루 | 없음 | 없음 | - |
| D9 | nwfilter(스푸핑 방지), dnsmasq/DHCP 임대 확인 | 없음 | 없음 | - |
| D10 | managedsave·스냅샷·체크포인트·백업 구분 | 394 | 보통 | Q |
| D10 | 스냅샷 실제 생성·되돌리기·삭제(`snapshot-create-as` 등), 복제(`virt-clone`), 백업 절차 | 없음 | 없음(개념만) | - |
| D11 | 마이그레이션 제어·터널링·오프라인·옵션·스토리지 복사 | 395 | 보통 | Q |
| D11 | 대역폭·다운타임·post-copy·CPU 호환·실패 원인 | 없음 | 없음 | - |
| D12 | qemu-guest-agent, cloud-init, virt-customize | 394(동결·에이전트 개념 1문항) | 얕음 | Q |
| D13 | virt-top/domstats, 병목 식별, iotune 사용 | 463(iotune 문법) | 얕음 | Q |
| D14 | sVirt/SELinux·AppArmor, 로그 위치 | 없음 | 없음 | - |
| D14 | 장애 대응 상황집 | 없음 | 없음 | - |

핵심 관찰(근거: 세트 380·395·459 본문 확인): 문제는 "옵션 X 는 무엇을 할까요" 형태의 정의 확인 중심이며, 명령 실행 결과를 읽는 문제는 `qemu-img info` 해석 1~2문항 외에 없다. 터미널 채점 퀘스트가 한 개도 없다(`quest.kind`가 choice/fill/order 만 존재).

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

1. **하이퍼바이저·하드웨어 보조 가상화 기초 개념**(D1) — Type1/2, 풀/반/보조 가상화, VT-x·EPT, KVM 의 위치. 380 은 KVM·QEMU 관계만 다루고 "왜 가능한가"가 없음.
2. **호스트 준비와 VM 만들기 실습**(D2) — `/dev/kvm`·CPU 플래그·모듈 확인, `virt-install`, 콘솔 접속, cloud image+cloud-init. 가상화 입문의 첫 실습이 통째로 없음.
3. **virsh 상태 관찰·일상 운영 실습**(D4) — `dominfo/domstate/domblklist/domifaddr/domstats/console/reboot/reset`. 381 은 시작·종료·정의 개념 퀴즈뿐.
4. **도메인 XML 구조 읽기·고치기**(D3) — audit 가 `missing_bridge` 로 지적(381→406). `dumpxml → edit → 반영 시점(재시작 필요/--live/--config)`, 영구 vs 일시 설정.
5. **CPU 가상화 개념과 오버커밋**(D5) — vCPU 와 물리 코어, 오버커밋 비율, steal time, 토폴로지, host-passthrough 이유. 406 은 XML 문법만.
6. **메모리 가상화 개념(balloon·KSM·오버커밋·OOM)**(D6) — 407 은 hugepages·numatune 옵션 중심, 운영에서 가장 흔한 "메모리 부족으로 VM 죽음"이 없음.
7. **스냅샷·복제·백업 실습**(D10) — 394 는 개념 구분만. 스냅샷 만들고 되돌리고 체인을 정리하는 손 실습 필요.
8. **가상화 장애 대응 상황집**(D14) — 전무(아래 "상황집" 참고).
9. **Linux bridge 로 VM 네트워크 구성 실습**(D9) — 464~465·475 가 옵션만. 브리지 구성→VM 연결→통신 확인 흐름이 없음.

### 권장

10. **qemu-img 실습**(D7) — 459·460 은 퀴즈. 실제 이미지 생성·확장·변환·백킹 체인 실습 필요(터미널로 안전하게 가능).
11. **가상 디스크 실무: 씬/싱 변환, 게스트 FS 확장, 디스크 추가·핫플러그**(D7/D8) — "디스크 꽉 참" 현장 시나리오.
12. **스토리지 풀·볼륨 전체 흐름 실습**(D8) — 417·474 퀴즈를 풀→볼륨→VM 부착 흐름으로 연결.
13. **게스트 연동: qemu-guest-agent·cloud-init·virt-customize**(D12) — 현재 394 의 1문항뿐.
14. **성능 관찰과 병목 식별**(D13) — `virt-top`·`domstats`·steal time·iotune 사용 순서.
15. **라이브 마이그레이션 실습·실패 원인**(D11) — 395 는 옵션 사전. CPU 모델 호환, 다운타임·대역폭, 흔한 실패.
16. **VM vs 컨테이너 비교 정리 세트**(D14/D1) — 55 가 제품 지도에 편중. 격리·부팅 시간·밀도·이미지·사용 판단.
17. **Open vSwitch 기초**(D9) — 사설 클라우드(OpenStack 연계, 413/385 맥락)에서 실제로 마주침. 입문 수준만.
18. **가상 NIC 성능: vhost-net·멀티큐·virtio 확인, 패킷 경로**(D9).
19. **복습(시험형) 세트**(형식 규칙 반영): 가상화 기초 복습, 운영 복습.

### 선택

20. SR-IOV·PCI 패스스루 개념(D9) — GPU/NIC 가속 필요 환경에서만.
21. sVirt/SELinux·AppArmor 와 libvirt 보안 경계(D14).
22. nwfilter(MAC·IP 스푸핑 방지)(D9).
23. 증분 백업·체크포인트 실습(D10) — 394 개념 이후 심화.
24. Windows 게스트(virtio 드라이버)·UEFI/vTPM(D2) — 사내 필요도 낮음(추정).

## 신규 세트 백로그

> 선행 세트가 "없음"이면 가상화 단원 맨 앞(신규 단원 "가상화 입문")에 배치. 현재 단원 구성(가상화 기초 / qemu-img·장치 설정·virsh 객체 명령 / 용어 지도) 앞뒤로 아래 신규 단원 제안: **V0 가상화 원리**, **V1 VM 만들기와 운영 실습**, **V2 CPU·메모리**, **V3 디스크 실습**, **V4 네트워크 실습**, **V5 보존·이동**, **V6 장애 대응·성능**. 기존 380 이후, 406·407 앞에 V0·V1 의 일부를 끼워 넣고, 기존 "장치 설정" 단원은 장치별(디스크→네트워크)로 재배열 권장(audit order_in_unit).

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| 필수 1 | 가상화는 어떻게 가능한가: 하이퍼바이저와 하드웨어 보조 | 개념 퀴즈 | V0 가상화 원리(신규, 380 앞) | 없음 | ① 가상화를 쓰는 이유(통합·격리·유연성) → ② Type1/Type2 → ③ 풀/반/하드웨어 보조 가상화 → ④ VT-x/AMD-V·EPT(2단계 주소 변환) 한 줄 → ⑤ KVM 이 커널 모듈로 하는 일 | 12 |
| 필수 2 | 우리 서버에서 KVM 을 쓸 수 있나: 호스트 확인 손연습 | 터미널 실습 | V1 VM 만들기와 운영 실습(신규) | 가상화 원리 | `lscpu` 가상화 플래그, `/dev/kvm`, `lsmod \| grep kvm`, `virsh version`·`virt-host-validate`, libvirtd 상태, 연결 URI(system vs session), nested 확인 | 8 |
| 필수 3 | virt-install 로 첫 VM 만들기와 접속 | 터미널 실습 | V1 | 2 | `virt-install` 필수 옵션(이름·메모리·vcpu·디스크·네트워크·os-variant), cloud image 사용, `virsh list`, `virsh console`/`vncdisplay`, 만든 VM 의 `dumpxml` 확인 | 8 |
| 필수 4 | cloud-init 으로 VM 초기 설정하기 | 터미널 실습 | V1 | 3 | user-data/meta-data, seed ISO 만들기, 호스트네임·SSH 키·패키지, 첫 부팅에서만 실행되는 이유, 재실행/clean | 7 |
| 필수 5 | virsh 로 VM 상태 살펴보기: dominfo·domstats·domifaddr·domblklist | 터미널 실습 | V1 (기존 381 뒤) | 381, 3 | `dominfo`, `domstate --reason`, `domblklist`, `domiflist`, `domifaddr`, `domstats` 일부, `console`/`reboot`/`reset`/`shutdown` 차이 실습 | 10 |
| 필수 6 | 도메인 XML 읽기와 안전하게 고치기 | 터미널 실습+퀴즈 | V1 (381 뒤·406 앞, audit missing_bridge 해소) | 5 | XML 골격(`domain/os/devices`), `dumpxml`, `virsh edit` 와 문법 검증, `--config` vs `--live`, 변경이 재시작 후 반영되는 항목, 영구 정의 vs 일시 정의 | 10 |
| 필수 7 | CPU 가상화 눈으로 확인하기: vCPU·오버커밋·steal | 개념+터미널 | V2 CPU·메모리 (406 앞) | 6 | vCPU 와 물리 코어/스레드, 오버커밋 비율 계산, `virsh vcpuinfo`·`vcpucount`, 게스트 `top` 의 `st`(steal), 토폴로지(소켓·코어·스레드), host-passthrough 가 필요한 이유, 라이브 마이그레이션과의 관계 | 11 |
| 필수 8 | 메모리 부족이 일어나는 방식: balloon·KSM·오버커밋·OOM | 개념+터미널 | V2 (407 앞) | 7 | 할당 vs 실사용, `currentMemory` 와 `setmem`(balloon), KSM 병합 동작, 호스트 스왑·OOM 이 VM 에 미치는 영향, `domstats --balloon` | 11 |
| 필수 9 | 스냅샷을 만들고 되돌리고 정리하기 | 터미널 실습 | V5 보존·이동(394 뒤) | 394, 460 | `snapshot-create-as`(디스크 전용 vs 메모리 포함), `snapshot-list/revert/delete`, 외부 스냅샷 체인과 `blockcommit`, `virt-clone` 복제, 스냅샷은 백업이 아닌 이유 | 10 |
| 필수 10 | 브리지 네트워크로 VM 연결하기 | 터미널 실습 | V4 네트워크 실습(464 뒤) | 416, 464 | `ip link add br0 type bridge`, 물리 NIC 편입의 위험(원격 접속 끊김)과 `begin/commit/rollback`(475 연계), VM interface `type=bridge`, 외부 통신 확인, `bridge link`·`bridge fdb` | 9 |
| 필수 11 | 가상화 장애 상황집 1: VM 이 켜지지 않는다 | 상황집 | V6 장애 대응(신규) | 5, 6 | 오류 메시지 → 원인 → 해결: 이미지 경로/권한(SELinux·AppArmor), 디스크 잠금(`Failed to get write lock`), 메모리 부족, KVM 접근 불가, XML 오류, 네트워크 미존재, 로그 `/var/log/libvirt/qemu/<vm>.log` | 8 |
| 필수 12 | 가상화 장애 상황집 2: 켜졌는데 접속·통신이 안 된다 | 상황집 | V6 | 10, 11 | IP 못 받음(DHCP/dnsmasq), 브리지 미연결, 방화벽·`nwfilter`, 게스트 NIC 이름 변경, 콘솔로 진입, MTU 불일치 | 8 |
| 권장 13 | qemu-img 로 이미지 만들고 키우고 바꿔 보기 | 터미널 실습 | V3 디스크 실습(459·460 뒤) | 459, 460 | `create -f qcow2`, `info`, `resize` 후 게스트 FS 확장(`growpart`·`resize2fs`), `convert`(raw↔qcow2, 압축), 백킹 체인 `create -b`·`commit`, `check` | 10 |
| 권장 14 | 디스크 꽉 참 상황집: 이미지는 큰데 쓸 수 있는 건 작다 | 상황집 | V6 | 13 | thin 이미지가 호스트를 채움, virtual/disk size, discard·`fstrim`·`virt-sparsify`, 백킹 체인 누적, 호스트 풀 용량 소진 시 VM 일시정지(`error_policy`) | 8 |
| 권장 15 | 스토리지 풀에서 볼륨까지 한 번에 | 터미널 실습 | V3 (474 뒤) | 417, 474 | `pool-define-as`/`pool-start`/`pool-autostart`, `vol-create-as`, `attach-disk --persistent`, `pool-refresh`, 풀 삭제 순서(`pool-destroy`→`undefine`) | 9 |
| 권장 16 | 게스트 에이전트와 호스트-게스트 연동 | 터미널 실습 | V1 또는 V5 | 5 | `qemu-guest-agent` 설치·채널, `domfsfreeze/thaw`, `domifaddr --source agent`, `virsh qemu-agent-command` 간단히, 정상 종료·시간 동기화 | 8 |
| 권장 17 | VM 이 느릴 때 보는 순서: CPU·메모리·디스크·네트워크 | 터미널+상황집 | V6 | 7, 8, 13 | `virt-top`, `domstats --cpu-total/--block/--balloon`, steal/iowait 구분, iotune 로 제한, 호스트 병목 vs 게스트 병목 | 10 |
| 권장 18 | 라이브 마이그레이션 실습과 실패 원인 | 터미널 실습+상황집 | V5 (395 뒤) | 395, 7 | `virsh migrate --live --verbose`, 공유 스토리지 확인, CPU 모델 불일치 오류, 다운타임·대역폭(`--bandwidth`, `migrate-setmaxdowntime`), 진행 모니터(`domjobinfo`), post-copy 개념 | 9 |
| 권장 19 | VM 과 컨테이너, 언제 무엇을 쓰나 | 개념 퀴즈 | V0 (55 뒤) 또는 "용어 지도" 단원 | 55, 77(도커) | 커널 공유 여부, 격리 강도, 부팅 시간·밀도, 이미지 크기, 보안 경계, 상태 보존, KubeVirt 는 둘의 결합 | 10 |
| 권장 20 | Open vSwitch 입문 | 터미널 실습 | V4 | 10 | OVS vs Linux bridge, `ovs-vsctl add-br/add-port`, VM 에 `virtualport type=openvswitch`, VLAN 태그 포트, `ovs-vsctl show` | 8 |
| 권장 21 | 가상 NIC 성능: virtio·vhost-net·멀티큐 | 개념+터미널 | V4 | 465 | 에뮬레이션(e1000) vs virtio, vhost-net, 멀티큐, 게스트에서 `ethtool -l`, MTU, 패킷 경로(게스트→tap→bridge→NIC) | 9 |
| 권장 22 | 가상화 입문 복습(시험형) | 복습 | V0/V1 말미 | 필수 1~6 | 계층 역할·호스트 확인·XML·상태 명령 섞어 출제, 오답 개념 재출제 | 12 |
| 권장 23 | 가상화 운영 복습(시험형) | 복습 | V6 말미 | 전체 | 스냅샷·마이그레이션·장애·성능 시나리오 문제 | 12 |
| 선택 24 | SR-IOV·PCI 패스스루 | 개념 퀴즈 | V4 말미 | 21 | 가상 NIC 한계, VF/PF, IOMMU·vfio, 패스스루 대가(마이그레이션 불가) | 8 |
| 선택 25 | libvirt 보안: sVirt·SELinux·AppArmor | 개념+상황집 | V6 | 11 | 이미지 컨텍스트(`svirt_image_t`), 권한 오류 로그 해석, `qemu.conf` 주요 설정 | 8 |
| 선택 26 | 증분 백업과 체크포인트 실습 | 터미널 | V5 | 9 | `checkpoint-create-as`, `backup-begin`, 풀·증분 구분 | 8 |

예상 합계: 필수 12개(약 110문항), 권장 14개, 선택 3개(총 26개 제안; 아래 최종 응답 수치는 필수/권장 중심 계산).
> 주의: "세트 수는 많지 않게" 원칙에 따라 제작 순서는 필수 1~12 먼저. 필수 2·3·5, 7·8, 11·12 는 현장 활용도가 높아 먼저, 16·17·18 은 이어서, 나머지는 이후.

### 기존 세트 정리 권고(신규는 아님)
- 380: 개념 6개 과밀(audit). 라이브 마이그레이션 조건(q9)은 395 로, 380 q10~12(virsh)는 381 과 경계가 겹침.
- 460·465: 한 세트에 6~7개 독립 주제(audit too_many_new). 신규 실습 세트(13, 21)를 만들면서 460 을 backing/commit·rebase 와 convert/compare 로, 465 를 NIC 모델/성능과 제어(bandwidth·vlan·isolated)로 분리 검토.
- 460 의 qemu-img snapshot(내부) 과 394 의 VM 스냅샷이 용어 중복 혼동(audit 추정) → 신규 9번에서 "내부 vs 외부 스냅샷" 비교 문항 포함.
- 표시 순서: qemu-img(459~460)→XML(461~465)→virsh(473~475) 를 장치별(disk: 459·460·462·463·474 / network: 416·464·465·473·475)로 재배열.

## 형식 균형

- 현황: 19세트 전부 quiz, 총 약 226문항, **터미널 0%**, choice 가 약 75%(세트당 9/12). `kind` 기준 terminal 퀘스트 0개. 가상화는 "손으로 해 보는 것"이 본질인 분야이므로 가장 큰 불균형.
- 권고 비율(분야 전체 세트 기준): **터미널 실습 세트 45~50%**, 상황집(터미널 기반) 15%, 개념 퀴즈 25~30%, 복습 5~10%.
  - 신규 26개 제안 중 터미널/상황집 위주 18개, 개념 6개, 복습 2개.
- 실습이 반드시 필요한 영역(현재 퀴즈뿐): D2 VM 생성, D4 virsh 상태 관찰, D7 qemu-img, D8 풀·볼륨, D9 브리지·OVS, D10 스냅샷, D11 마이그레이션(가능하면 2호스트 환경 대신 `--dry`/`domjobinfo` 관찰 정도로 대체, 추정), D14 상황집.
- 샌드박스 제약(추정, 확인 필요): 컨테이너 샌드박스에서는 `/dev/kvm` 와 nested 가상화를 쓰기 어렵다. 실제 VM 부팅 없이도 가능한 대체안: (a) `qemu-img`·`virsh` 의 `--connect test:///default`(libvirt test 드라이버) 또는 `qemu:///session` 상태 관찰, (b) XML 편집·`virsh define`·`dumpxml` 은 부팅 없이 가능, (c) Linux bridge·OVS 는 컨테이너 안 네트워크 네임스페이스에서 `ip`·`ovs-vsctl` 로 구현 가능, (d) 장애 상황집은 로그·XML·`qemu-img info` 출력을 미리 만들어 둔 파일을 읽고 고치는 방식. 샌드박스 이미지에 `libvirt-clients`, `qemu-utils`, `virtinst`, `cloud-image-utils`, `openvswitch-switch` 추가 필요 여부는 제작 전 확인.

## 상황집

현황: 가상화 분야에 오류 메시지→원인→해결 상황집 **없음**(19개 세트 중 0). 가장 가까운 것은 395 의 `--copy-storage-*` 선택 문제와 459 `check` 종료 코드 해석(q7)뿐이며 재현 실습이 아니다.

필요한 시나리오(일반화, 현장 정보 없음):

| # | 시나리오 | 오류 신호 예 | 원인 후보 | 해결 연습 |
|---|---------|-------------|----------|----------|
| S1 | VM 시작 실패: 디스크 접근 불가 | `Cannot access storage file ... Permission denied` | 소유권/SELinux·AppArmor, 경로 오타 | `ls -lZ`, `chown`, 컨텍스트 복구 |
| S2 | VM 시작 실패: 디스크 잠금 | `Failed to get "write" lock` | 같은 이미지를 두 VM 이 사용, 이전 qemu 프로세스 잔존 | `ps`, `virsh list --all`, `qemu-img info -U` |
| S3 | VM 시작 실패: 메모리/KVM | `cannot allocate memory`, `Could not access KVM kernel module` | 호스트 메모리 부족·hugepages 부족·모듈 미적재·BIOS VT 비활성 | `free`, `/proc/meminfo`, `modprobe` |
| S4 | XML 오류 | `XML error: ...`, `unsupported configuration` | 잘못된 요소/값, 금지 조합(461 개념 연계) | `virsh define` 오류 읽기, `virt-xml-validate` |
| S5 | 네트워크 없음 | `Network not found: default`, `network is not active` | 가상 네트워크 미시작, autostart 없음 | `net-list --all`, `net-start`, `net-autostart` |
| S6 | VM 은 켜졌지만 IP 가 없음 | `domifaddr` 비어 있음 | DHCP 임대 없음, 브리지 미연결, 게스트 NIC 이름 변경 | `net-dhcp-leases`, `bridge link`, 콘솔 |
| S7 | 마이그레이션 실패 | `Unsafe migration: Migration without shared storage is unsafe`, CPU 모델 불일치 | 공유 스토리지 가정(395 q7), CPU 호환 | `--copy-storage-inc`, cpu mode 조정 |
| S8 | 디스크가 꽉 차서 VM 이 멈춤(paused) | `domstate --reason` 이 `paused (ioerror)` | 호스트 풀 용량 소진, thin 이미지 과확장 | `df`, `pool-info`, 공간 확보 후 `resume` |
| S9 | VM 이 느리다 | 게스트 `st` 높음 / iowait 높음 | CPU 오버커밋, 디스크 경합, 메모리 스왑 | `virt-top`, `domstats`, iotune |
| S10 | 스냅샷 체인 고장/누적 | `qemu-img check` 오류, 오버레이 누적 | 백킹 파일 이동·삭제, commit 안 함 | `qemu-img info --backing-chain`, `rebase -u`, `commit` |
| S11 | 호스트 브리지 구성 후 원격 접속 끊김 | SSH 단절 | NIC 를 브리지에 편입하며 IP 이동 누락 | `iface-bridge` 의 `begin/commit/rollback` 연계(475) |
| S12 | 게스트 정상 종료가 안 됨 | `shutdown` 후에도 running | ACPI/에이전트 없음 | `shutdown --mode agent`, 최후 `destroy` |

제작 권고: 필수 11·12 에서 S1~S6, 권장 14(S8·S10), 권장 17(S9), 권장 18(S7), S11 은 필수 10 에 포함. S12 는 필수 5 에 1문항.
