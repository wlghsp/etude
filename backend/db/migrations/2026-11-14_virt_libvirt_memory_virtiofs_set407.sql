-- 퀴즈 세트 407. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round13.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 407, 'libvirt 메모리와 공유: memory·currentMemory·hugepages, numatune, virtiofs', '메모리 설정과 디렉터리 공유를 읽습니다. memory·currentMemory·maxMemory, hugepages, numatune 기본 strict, virtiofs 의 전제(shared 메모리)·마운트 태그·마운트 방법과 스냅샷 제약을 봅니다.', 'quiz', '가상화'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 407);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 1, 'memory 요소', '`<memory>` 는 무엇을 정할까요?', '부팅 때의 최대예요.', NULL, NULL, '[]', 'choice', '["게스트가 지금 실제로 쓰는 메모리 양", "호스트의 전체 물리 메모리 용량", "부팅 시 최대 메모리 할당", "스왑 영역에 잡아 둘 크기"]', 2, '문서는 memory 를 부팅 시점의 게스트 최대 메모리 할당으로 설명하며 기본 단위는 KiB 입니다.', NULL, NULL, NULL, '[{"title": "libvirt 도메인 XML 형식", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 2, 'currentMemory', '`<currentMemory>` 는 무엇이며 생략하면 어떻게 될까요?', '풍선으로 늘릴 여유를 줘요.', NULL, NULL, '[]', 'choice', '["항상 memory 의 절반이며 생략하면 0 이다", "실제 할당(최대보다 작을 수 있음), 생략하면 memory", "호스트의 남는 메모리이며 생략하면 오류", "메모리 상한이며 생략하면 무제한이다"]', 1, '문서는 currentMemory 를 게스트의 실제 메모리 할당으로, 최대 할당보다 작을 수 있어 풍선으로 즉시 늘릴 수 있게 하며, 생략하면 memory 값을 쓴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt 도메인 XML 형식", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 3, 'maxMemory', '`<maxMemory>` 는 무엇을 정할까요?', '핫플러그의 한계예요.', NULL, NULL, '[]', 'choice', '["메모리 핫플러그의 런타임 최대치", "부팅 때 확보해 둘 최소 메모리", "게스트 한 개의 스왑 상한 크기", "호스트에서 줄 수 있는 총합 값"]', 0, '문서는 maxMemory 가 메모리 핫플러그로 도달할 수 있는 런타임 최대치를 정한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt 도메인 XML 형식", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 4, 'hugepages', '`<memoryBacking>` 의 **hugepages** 는 무엇을 뜻할까요?', '큰 페이지를 써요.', NULL, NULL, '[]', 'choice', '["게스트 메모리를 압축해 저장하게 한다", "메모리를 디스크 스왑으로만 쓰게 한다", "게스트 메모리를 암호화해서 쓴다", "메모리를 일반 페이지 대신 큰 페이지로 할당"]', 3, '문서는 hugepages 가 하이퍼바이저에 게스트 메모리를 일반 네이티브 페이지 크기 대신 hugepage 로 할당하라고 알리는 요소라고 설명합니다. 각 page 에는 size 속성이 필요합니다.', NULL, NULL, NULL, '[{"title": "libvirt 도메인 XML 형식", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 5, 'numatune 기본', '`<numatune>` 의 `<memory>` **mode 기본값** 은 무엇일까요?', '엄격한 쪽이에요.', NULL, NULL, '[]', 'choice', '["interleave", "preferred", "strict", "restrictive"]', 2, '문서는 numatune memory 의 mode 가 interleave·strict·preferred·restrictive 이며 기본이 strict 라고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt 도메인 XML 형식", "url": "https://libvirt.org/formatdomain.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 6, 'virtiofs', '**virtiofs** 는 무엇일까요?', '호스트 디렉터리를 공유해요.', NULL, NULL, '[]', 'choice', '["VM 디스크 이미지를 압축해서 저장하는 포맷", "호스트 디렉터리에 접근하게 하는 공유 파일 시스템", "게스트 간 네트워크를 서로 연결하는 드라이버", "메모리를 공유하는 풍선 모양의 드라이버"]', 1, 'libvirt 문서는 virtiofs 를 VM 이 호스트의 디렉터리 트리에 접근하게 하는 공유 파일 시스템으로, 로컬 파일 시스템의 의미와 성능을 목표로 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 7, 'virtiofs 의 전제', 'virtiofs 를 쓰려면 도메인 XML 에 **무엇이 꼭 필요** 할까요?', 'vhost-user 연결을 위해서예요.', NULL, NULL, '[]', 'choice', '["shared 메모리 설정(memoryBacking 의 memfd)", "게스트에 USB 컨트롤러를 추가해 두어야 한다", "디스크 이미지를 qcow2 로 변환해 두어야 한다", "네트워크를 브리지 모드로 변경해 두어야 한다"]', 0, '문서는 virtiofsd 와의 vhost-user 연결을 위해 memoryBacking 에 memfd 소스와 access mode=shared 가 필요하다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 8, '마운트 태그', 'virtiofs 의 `<target dir=...>` 값은 무엇일까요?', '임의의 문자열이에요.', NULL, NULL, '[]', 'choice', '["게스트에서 마운트할 절대 경로 문자열", "호스트 쪽 공유 디렉터리의 경로 문자열", "반드시 호스트 이름과 같아야 하는 이름", "마운트 지점과 같지 않아도 되는 임의의 태그"]', 3, '문서는 target dir 값이 마운트 태그라는 임의의 문자열이며 게스트의 마운트 지점과 같을 필요가 없다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 9, 'virtiofs 와 스냅샷', 'virtiofs 로 공유한 파일은 **libvirt 스냅샷** 에서 어떻게 다뤄질까요?', '스냅샷이 담지 않아요.', NULL, NULL, '[]', 'choice', '["스냅샷이 공유 파일까지 함께 담아 둔다", "공유 파일이 있으면 스냅샷 생성이 금지된다", "공유 파일 상태를 담지 않아 되돌리기를 권장하지 않는다", "되돌릴 때 호스트 파일이 자동으로 복원된다"]', 2, '문서는 libvirt 스냅샷이 virtiofs 로 공유한 파일의 상태를 담지 않으며 이전 상태로 되돌리는 것은 권장되지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 10, '게스트에서 마운트', '게스트 안에서 virtiofs 공유를 마운트하는 **파일 시스템 타입** 입니다. 빈칸을 채우세요.', '이름 그대로예요.', NULL, NULL, '[]', 'fill', '["virtiofs", "nfs", "cifs", "ext4"]', NULL, '게스트에서 mount -t virtiofs mount_tag /mnt/mount/path 로 마운트하며 게스트 커널이 virtiofs 를 지원해야(Linux 5.4 이상) 합니다.', '[0]', 'mount -t {0} mount_tag /mnt/shared', NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 11, '공유 메모리 모드', 'virtiofs 에 필요한 `<access mode=''…''/>` 의 값입니다. 빈칸을 채우세요.', '"공유" 예요.', NULL, NULL, '[]', 'fill', '["shared", "private", "exclusive", "readonly"]', NULL, 'virtiofs 는 memoryBacking 에 access mode=shared 가 있어야 합니다.', '[0]', '<access mode=''{0}''/>', NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 407, 12, 'virtiofs 로 디렉터리 공유', '호스트 디렉터리를 게스트와 공유하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '메모리 → 정의 → 시작 → 마운트예요.', NULL, NULL, '[]', 'order', '["`<memoryBacking>` 에 shared 메모리를 설정한다", "`<filesystem>` 에 virtiofs 드라이버, 호스트 경로, 마운트 태그를 정의한다", "게스트를 시작한다", "게스트에서 mount -t virtiofs 로 태그를 마운트한다"]', NULL, '문서가 설명한 설정과 마운트 절차를 이은 큰 줄기입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "libvirt virtiofs", "url": "https://libvirt.org/kbase/virtiofs.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 407 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 632, unit_id = (SELECT id FROM unit WHERE id = 48), icon = '🧠' WHERE id = 407;
