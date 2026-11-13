-- 가상화 퀴즈 세트 380. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_virt_quiz_sets.md
INSERT INTO unit (id, category, title, display_order) SELECT 48, '가상화', '가상화 기초', 5 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 48);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 380, '가상화 구조: KVM·QEMU·libvirt 와 디스크 이미지', '가상 머신이 돌아가는 층을 익힙니다. KVM 과 QEMU 의 관계, TCG, KVM API, libvirt 와 도메인, virtio, qcow2 와 VM 스냅샷, raw 이미지의 공간, 라이브 마이그레이션, virsh 기본 명령을 봅니다.', 'quiz', '가상화'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 380);
UPDATE quest_set SET unit_id = (SELECT id FROM unit WHERE id = 48), icon = '🖥️', display_order = 627 WHERE id = 380;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 1, 'KVM 과 QEMU', 'KVM 과 QEMU 의 관계로 알맞은 것은 무엇일까요?', 'QEMU 문서의 "가속기(accelerator)" 표를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["KVM 이 가상 머신을 만들고 QEMU 는 그 위에서 도는 모니터링 도구다", "둘은 서로 경쟁하는 별개의 하이퍼바이저라서 함께 쓸 수 없다", "QEMU 가 가상 머신을 만들고, KVM 은 QEMU 가 쓰는 가속기(리눅스 커널 기능)다", "KVM 은 윈도우 전용이고 QEMU 는 리눅스 전용이다"]', 2, 'QEMU 문서는 QEMU 가 여러 가속기(KVM, Xen, hvf, whpx 등)를 지원한다고 설명하며 KVM 은 호스트 OS 가 리눅스인 가속기입니다. 가속기를 쓰지 않으면 TCG(JIT 에뮬레이션)로 돕니다.', NULL, NULL, NULL, '[{"title": "QEMU 시스템 에뮬레이션 소개", "url": "https://www.qemu.org/docs/master/system/introduction.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 2, 'TCG 란', 'QEMU 에서 KVM 같은 가속기 없이 CPU 를 소프트웨어로 흉내 내는 방식의 이름은 무엇일까요?', 'JIT 방식이에요.', NULL, NULL, '[]', 'choice', '["TPM (Trusted Platform Module)", "TCG (Tiny Code Generator)", "NUMA (Non-Uniform Memory Access)", "SR-IOV (Single Root I/O Virtualization)"]', 1, 'QEMU 문서는 TCG 를 많은 CPU 를 에뮬레이션할 수 있는 JIT 로 소개합니다. KVM 은 하드웨어 가상화 지원을 써서 더 빠르게 돕니다.', NULL, NULL, NULL, '[{"title": "QEMU 시스템 에뮬레이션 소개", "url": "https://www.qemu.org/docs/master/system/introduction.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 3, 'KVM 의 제어 방식', '리눅스 커널의 **KVM API** 는 어떤 방식으로 가상 머신을 제어할까요?', '커널 문서의 첫 설명을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["파일 디스크립터에 대한 ioctl 호출 묶음으로 제어한다", "REST API 를 HTTP 로 호출해서 제어한다", "설정 파일을 고친 뒤 서비스를 재시작해 제어한다", "데이터베이스에 명령을 적어 두면 읽어 가서 제어한다"]', 0, '커널 문서는 kvm API 를 서로 다른 종류의 파일 디스크립터에 발행하는 ioctl 묶음이라고 설명합니다. `KVM_CREATE_VM` 으로 VM 파일 디스크립터를, `KVM_CREATE_VCPU` 로 가상 CPU 를 만듭니다.', NULL, NULL, NULL, '[{"title": "커널 KVM API", "url": "https://docs.kernel.org/virt/kvm/api.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 4, 'libvirt 의 역할', '**libvirt** 와 `virsh` 는 무엇일까요?', '여러 하이퍼바이저를 같은 방식으로 다뤄요.', NULL, NULL, '[]', 'choice', '["KVM 을 대체하는 새로운 하이퍼바이저 제품", "가상 머신 안에서 실행되는 게스트 운영체제", "VM 디스크 이미지만 만들어 주는 변환 도구", "가상화를 공통 방식으로 다루는 도구 모음과 명령행"]', 3, 'libvirt 는 리눅스의 가상화 기능과 상호작용하는 C 도구 모음이고 `virsh` 는 도메인을 만들고 멈추고 목록을 보는 명령행 프로그램입니다. 실제 가상 머신은 QEMU/KVM 같은 하이퍼바이저가 돌립니다.', NULL, NULL, NULL, '[{"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 5, '도메인이란', 'libvirt 에서 말하는 **도메인(domain)** 은 무엇일까요?', '`virsh list` 의 한 줄이 한 개예요.', NULL, NULL, '[]', 'choice', '["DNS 의 도메인 이름", "가상 머신을 담아 두는 디스크 풀", "하이퍼바이저가 실행하는 가상 머신 하나", "호스트 서버의 네트워크 대역"]', 2, 'libvirt 문서는 virsh 가 도메인을 만들고 멈춘다고 하며 `virsh list` 의 각 줄이 도메인(가상 머신)입니다. 이름·ID·상태를 보여 줍니다.', NULL, NULL, NULL, '[{"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 6, 'virtio 를 쓰는 이유', '게스트의 디스크와 네트워크 장치를 **virtio** 로 설정하는 이유로 알맞은 것은 무엇일까요?', '준가상화예요.', NULL, NULL, '[]', 'choice', '["호스트의 CPU 개수를 늘려 주기 때문이다", "준가상화(paravirtualized) 장치로 에뮬레이션보다 성능이 좋다", "게스트가 호스트의 파일을 마음대로 읽게 해 주기 때문이다", "가상 머신이 라이브 마이그레이션을 못 하도록 막아 주기 때문이다"]', 1, 'libvirt 위키는 virtio 가 준가상화의 성능 이점 대부분을 준다고 설명합니다. 게스트 쪽에도 virtio 드라이버가 필요하며 리눅스는 커널 2.6.25 이상이면 쓸 수 있다고 합니다.', NULL, NULL, NULL, '[{"title": "libvirt virtio 안내", "url": "https://wiki.libvirt.org/Virtio.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 7, 'qcow2 와 VM 스냅샷', 'QEMU 의 **VM 스냅샷** 에 필요한 조건은 무엇일까요?', '디스크 이미지 형식이 관건이에요.', NULL, NULL, '[]', 'choice', '["쓰기 가능한 디스크 하나 이상이 qcow2 형식이어야 한다", "쓰기 가능한 모든 디스크가 raw 형식이어야 한다", "스냅샷을 만들 때 게스트가 반드시 꺼져 있어야 한다", "호스트에 공유 스토리지가 반드시 구성되어 있어야 한다"]', 0, 'QEMU 문서는 VM 스냅샷(CPU 상태·RAM·장치 상태·쓰기 가능한 모든 디스크 내용 포함)을 쓰려면 이동식이 아닌 쓰기 가능한 블록 장치 중 하나 이상이 qcow2 형식이어야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU 디스크 이미지", "url": "https://www.qemu.org/docs/master/system/images.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 8, 'raw 이미지의 공간', '`raw` 형식 디스크 이미지를 **구멍(hole)을 지원하는 파일시스템** 에 만들면 공간은 어떻게 쓰일까요?', '`qemu-img info` 로 실제 크기를 볼 수 있어요.', NULL, NULL, '[]', 'choice', '["만들 때 지정한 크기가 전부 즉시 할당된다", "쓴 데이터의 두 배가 항상 할당된다", "파일시스템과 관계없이 공간을 쓰지 않는다", "실제로 쓴 섹터만 공간을 차지한다"]', 3, 'QEMU 문서는 파일시스템이 구멍을 지원하면(예: ext 계열, NTFS) raw 이미지에서 쓴 섹터만 공간을 예약한다고 설명하며 실제 사용량은 `qemu-img info` 로 확인하라고 합니다.', NULL, NULL, NULL, '[{"title": "QEMU 디스크 이미지", "url": "https://www.qemu.org/docs/master/system/images.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 9, '라이브 마이그레이션 조건', 'libvirt 로 가상 머신을 다른 호스트로 옮길 때, **공유 스토리지가 없는** 경우 필요한 것은 무엇일까요?', '디스크도 같이 옮겨야 해요.', NULL, NULL, '[]', 'choice', '["아무것도 필요 없고 디스크는 자동으로 따라온다", "게스트를 삭제하고 새로 만든다", "디스크도 함께 복사하는 비공유 디스크 마이그레이션 옵션", "목적지 호스트에서 같은 이름으로 undefine 해 둔다"]', 2, 'libvirt 마이그레이션 문서에 비공유 스토리지 마이그레이션 플래그(`VIR_MIGRATE_NON_SHARED_DISK`)가 나옵니다. 공유 스토리지가 있으면 디스크는 옮기지 않고 메모리와 상태만 옮깁니다.', NULL, NULL, NULL, '[{"title": "libvirt 마이그레이션", "url": "https://libvirt.org/migration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 10, '가상 머신 목록', '꺼진 가상 머신까지 **모두** 보는 명령입니다. 빈칸을 채우세요.', '옵션 이름이 그대로 "전부"예요.', NULL, NULL, '[]', 'fill', '["all", "every", "full", "state"]', NULL, 'virsh 문서는 `list` 가 옵션이 없으면 실행 중인 도메인만 보여 주고 `--all` 이나 `--inactive` 로 범위를 넓힌다고 설명합니다.', '[0]', 'virsh list --{0}', NULL, '[{"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 11, '정상 종료', '게스트 OS 와 협의해 **정상적으로 종료** 하는 명령입니다. 빈칸을 채우세요.', '반대로 destroy 는 전원을 뽑는 것과 같아요.', NULL, NULL, '[]', 'fill', '["shutdown", "destroy", "undefine", "suspend"]', NULL, 'virsh 문서는 `shutdown` 을 게스트 OS 와 협조하는 정상 종료로, `destroy` 를 전원 코드를 뽑는 것과 같은 즉시 종료로 설명합니다.', '[0]', 'virsh {0} vm1', NULL, '[{"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 380, 12, 'VM 정의하고 지우기', 'XML 파일로 VM 을 등록해 쓰고 정리하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '등록 → 시작 → 종료 → 등록 해제 순서예요.', NULL, NULL, '[]', 'order', '["`virsh define vm1.xml` 로 도메인을 등록한다", "`virsh start vm1` 으로 시작한다", "`virsh shutdown vm1` 으로 정상 종료한다", "`virsh undefine vm1` 으로 등록을 지운다"]', NULL, '`define` 은 등록만 하고 시작하지 않으며, `undefine` 은 도메인 설정을 지웁니다. 스토리지 볼륨은 `--storage` 같은 옵션을 주지 않으면 지우지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 380 AND order_index = 12);
