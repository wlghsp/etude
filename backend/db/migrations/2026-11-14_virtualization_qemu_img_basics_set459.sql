-- 퀴즈 세트 459. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_virt_round5.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 459, 'qemu-img 기본: 오프라인 원칙, info 의 virtual·disk size, check, resize 주의', '디스크 이미지 도구를 읽습니다. 오프라인에서만 수정해야 하는 이유, -U 공유 조회, 포맷 추정, info 의 virtual size 와 disk size, --backing-chain, check 종료 코드와 -r 수리, resize 의 축소 주의를 봅니다.', 'quiz', '가상화'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 459);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 1, 'qemu-img 역할', 'qemu-img 는 무엇을 하는 도구일까요?', '오프라인 도구예요.', NULL, NULL, '[]', 'choice', '["실행 중인 VM 을 실시간으로 변환한다", "VM 의 CPU 와 메모리를 조정한다", "이미지를 오프라인으로 만들고 변환한다", "호스트 네트워크 브리지를 설정한다"]', 2, 'qemu-img 문서는 디스크 이미지를 오프라인으로 만들고(create), 변환하고(convert), 수정할 수 있으며 QEMU 가 지원하는 모든 이미지 포맷을 다룬다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 2, '실행 중 수정', '**실행 중인 VM 이 쓰는 이미지** 를 qemu-img 로 수정하면 어떻게 될까요?', '경고가 있어요.', NULL, NULL, '[]', 'choice', '["자동으로 잠겨 안전하게 거부된다", "이미지가 망가질 수 있다", "변경이 VM 에 즉시 반영된다", "성능만 잠시 떨어지고 끝난다"]', 1, '문서는 실행 중인 VM 이나 다른 프로세스가 쓰는 이미지를 qemu-img 로 수정하지 말라고 경고하며, 그러면 이미지가 파괴될 수 있고 수정 중인 이미지를 조회하면 불일치 상태를 볼 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 3, '-U 옵션', '`qemu-img info -U` 의 **-U** 는 무엇을 할까요?', '공유 모드예요.', NULL, NULL, '[]', 'choice', '["공유 모드로 읽기 조회를 허용한다", "이미지를 쓰기 가능으로 연다", "이미지를 압축해 저장한다", "이미지를 암호화해서 연다"]', 0, '문서는 --force-share(-U)가 이미지를 공유 모드로 열어 다른 QEMU 프로세스의 쓰기 열기를 허용하며, 실행 중인 게스트의 이미지 정보를 볼 때 쓸 수 있지만 결과가 불일치할 수 있고 읽기 전용으로 열 때만 허용된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 4, '포맷 추정', '`-f` 로 **포맷을 주지 않으면** 어떻게 될까요?', '대부분 알아서 해요.', NULL, NULL, '[]', 'choice', '["항상 raw 로 가정한다", "항상 qcow2 로 가정한다", "반드시 지정하라며 거부한다", "대부분의 경우 자동으로 추정한다"]', 3, '문서는 FMT 가 대부분의 경우 자동으로 추정된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 5, 'disk size', '`qemu-img info` 출력의 **disk size** 는 무엇을 뜻할까요?', '호스트 쪽이에요.', NULL, NULL, '[]', 'choice', '["게스트가 보는 디스크의 크기", "이미지에 할당할 수 있는 최대 크기", "이미지 파일이 호스트에서 차지하는 공간", "압축하기 전 원본의 크기"]', 2, '문서는 virtual size 가 게스트 디스크의 크기이고 disk size 가 이미지 파일이 호스트 파일시스템에서 차지하는 공간이라고 설명합니다. 둘은 다를 수 있습니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 6, '--backing-chain', '`qemu-img info --backing-chain` 은 무엇을 보여 줄까요?', '사슬이에요.', NULL, NULL, '[]', 'choice', '["가장 위의 이미지 정보만 보여 준다", "체인의 모든 이미지 정보를 위에서 아래로 나열한다", "가장 아래 베이스 이미지 정보만 보여 준다", "체인을 하나의 이미지로 합쳐서 보여 준다"]', 1, '문서는 --backing-chain 이 백킹 파일 체인의 각 이미지 정보를 재귀적으로 나열하며, snap2 → snap1 → base 처럼 위에서 베이스 순으로 보여 준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 7, 'check 종료 코드', '`qemu-img check` 의 종료 코드 `63` 은 무엇을 뜻할까요?', '지원 문제예요.', NULL, NULL, '[]', 'choice', '["이미지 포맷이 검사를 지원하지 않는다", "검사 중 내부 오류가 났다", "이미지가 손상되어 있다", "클러스터 누수가 발견되었다"]', 0, '문서는 check 의 종료 코드 0 이 일관됨, 1 이 내부 오류, 2 가 손상, 3 이 클러스터 누수, 63 이 포맷이 검사를 지원하지 않음이라고 설명합니다. qcow2, qed, parallels, vhdx, vmdk, vdi 만 검사를 지원합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 8, 'check -r', '`check -r leaks` 와 `-r all` 의 차이는 무엇일까요?', '범위가 달라요.', NULL, NULL, '[]', 'choice', '["읽기 전용이냐 쓰기 가능이냐", "압축을 하느냐 하지 않느냐", "현재 이미지냐 백킹 파일이냐", "누수만 고치느냐 모든 오류를 고치느냐"]', 3, '문서는 -r leaks 가 클러스터 누수만 고치고 -r all 이 모든 종류의 오류를 고치되 잘못된 수정을 고르거나 이미 생긴 손상을 가릴 위험이 더 크다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 9, '축소 전 준비', '`qemu-img resize` 로 이미지를 **줄이기 전** 반드시 해야 할 일은 무엇일까요?', '데이터 손실을 막아요.', NULL, NULL, '[]', 'choice', '["이미지를 raw 로 변환해 둔다", "백킹 파일을 먼저 커밋한다", "VM 안에서 파일시스템과 파티션을 먼저 줄인다", "--preallocation 을 full 로 정한다"]', 2, '문서는 이미지를 줄이기 전에 VM 안의 파일시스템·파티션 도구로 크기를 먼저 줄여야 하며 그렇지 않으면 데이터를 잃는다고 하고, 줄일 때는 --shrink 옵션이 필요하다고 설명합니다.', NULL, NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 10, '이미지 만들기', '새 디스크 이미지를 **만드는** 하위 명령입니다. 빈칸을 채우세요.', '생성이에요.', NULL, NULL, '[]', 'fill', '["create", "info", "check", "resize"]', NULL, 'create 는 이미지를 만들고, info 는 정보를 보고, check 는 일관성을 검사하고, resize 는 크기를 바꿉니다.', '[0]', 'qemu-img {0} -f qcow2 disk.qcow2 20G', NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 11, '축소 확인', '이미지를 **줄일 때** 데이터 손실을 인정한다는 뜻으로 필요한 옵션입니다. 빈칸을 채우세요.', '줄인다는 뜻이에요.', NULL, NULL, '[]', 'fill', '["--shrink", "--force", "--preallocation", "--bitmaps"]', NULL, '--shrink 는 잘려 나가는 끝부분 데이터를 잃는다는 것을 사용자가 인정한다는 뜻이며 이미지를 줄일 때 반드시 줘야 합니다.', '[0]', 'qemu-img resize {0} disk.qcow2 10G', NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 459, 12, '이미지 확장', '이미지 크기를 늘리는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 정지 → 확장 → 안에서 사용이에요.', NULL, NULL, '[]', 'order', '["`qemu-img info` 로 현재 크기를 확인한다", "VM 을 끄고 이미지를 쓰는 프로세스가 없게 한다", "`qemu-img resize` 로 이미지를 늘린다", "VM 안에서 파티션·파일시스템 도구로 새 공간을 쓴다"]', NULL, '문서의 오프라인 경고와 resize 설명(늘린 뒤 VM 안에서 도구로 새 공간을 써야 함)을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "QEMU disk image utility (qemu-img)", "url": "https://www.qemu.org/docs/master/tools/qemu-img.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 459 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 635, unit_id = (SELECT id FROM unit WHERE id = 48), icon = '🖼️' WHERE id = 459;
