-- 퀴즈 세트 474. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_virt_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 474, 'virsh 로 스토리지 볼륨 다루기: vol-create·create-as·clone·delete·upload·wipe·resize', 'virsh 볼륨 명령을 읽습니다. vol-create 의 XML 정의, create-as 의 capacity 단위와 --print-xml·--format, clone 의 --reflink, delete 의 --delete-snapshots, upload 의 --sparse, wipe 방식과 trim, resize 의 --shrink·--delta 를 봅니다.', 'quiz', '가상화'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 474);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 1, 'vol-create', '`virsh vol-create POOL FILE` 의 FILE 은 무엇이고 어떻게 쉽게 만들까요?', 'dumpxml 을 쓰라고 해요.', NULL, NULL, '[]', 'choice', '["볼륨에 채울 디스크 이미지이며 qemu-img 로 만든다", "풀 정의 XML 이며 pool-dumpxml 출력을 쓴다", "볼륨 정의 XML 이며 vol-dumpxml 출력을 고쳐 쓰면 쉽다", "볼륨 크기만 한 줄 적은 텍스트 파일이다"]', 2, '문서는 vol-create 가 XML 파일의 볼륨 정의로 볼륨을 만들며, vol-dumpxml 로 기존 볼륨의 정의를 얻어 파일을 만드는 것이 쉽다고 설명합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 2, 'vol-create-as', '`vol-create-as` 에서 capacity 를 접미사 없이 쓰면 단위는 무엇일까요?', 'scaled integer 예요.', NULL, NULL, '[]', 'choice', '["킬로바이트", "바이트", "메가바이트", "기가바이트"]', 1, '문서는 capacity 가 scaled integer 이며 접미사가 없으면 바이트가 기본이라고 설명합니다. --allocation 도 같은 규칙입니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 3, '--print-xml', '`vol-create-as ... --print-xml` 은 어떻게 동작할까요?', '출력만 해요.', NULL, NULL, '[]', 'choice', '["볼륨을 만들지 않고 볼륨 객체의 XML 만 출력한다", "볼륨을 만든 뒤 XML 을 파일로 저장한다", "볼륨을 만들고 풀의 XML 도 갱신한다", "기존 볼륨의 XML 을 화면에 출력한다"]', 0, '문서는 --print-xml 을 주면 실제 객체를 만들지 않고 볼륨 객체의 XML 만 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 4, '--format', '`vol-create-as --format` 에 대한 설명으로 맞는 것은 무엇일까요?', '풀 종류가 중요해요.', NULL, NULL, '[]', 'choice', '["모든 풀에서 파일시스템 종류를 정한다", "네트워크 풀에서만 압축 방식을 정한다", "디스크 풀에서 파티션 테이블 종류를 정한다", "파일 기반 풀에서 볼륨 파일 형식을 정한다"]', 3, '문서는 --format 이 파일 기반 스토리지 풀에서 볼륨 파일 형식(raw·bochs·qcow·qcow2·vmdk·qed)을 정하며, 디스크 풀에서는 확장 파티션을 만들 때 extended 를 쓴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 5, 'vol-clone', '`virsh vol-clone SRC NAME --reflink` 에서 reflink 가 불가능하면 어떻게 될까요?', 'COW 복사예요.', NULL, NULL, '[]', 'choice', '["일반 전체 복사로 대신한다", "빈 볼륨만 만들고 끝난다", "복제가 실패한다", "원본 볼륨이 삭제된다"]', 2, '문서는 --reflink 가 데이터 블록을 수정될 때만 복사하는 COW 경량 복사를 하며, 불가능하면 복사가 실패한다고 설명합니다. vol-clone 은 같은 풀 안에서 복제합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 6, 'vol-delete', '`vol-delete --delete-snapshots` 에 대한 설명으로 맞는 것은 무엇일까요?', '드라이버 제한이 있어요.', NULL, NULL, '[]', 'choice', '["볼륨과 같은 풀의 모든 볼륨을 지우며 file 풀만 지원한다", "볼륨의 스냅샷도 함께 지우며 현재는 rbd 만 지원한다", "스냅샷만 지우고 볼륨은 남기며 모든 풀이 지원한다", "삭제 전 스냅샷을 만들어 두며 qcow2 만 지원한다"]', 1, '문서는 --delete-snapshots 가 볼륨에 딸린 스냅샷도 함께 삭제하게 하며 모든 스토리지 드라이버가 아니라 현재는 rbd 만 지원한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 7, 'vol-upload', '`vol-upload` 의 `--sparse` 는 무엇을 할까요?', '희소 파일이에요.', NULL, NULL, '[]', 'choice', '["희소성(sparseness)을 유지한다", "업로드 데이터를 압축해서 저장한다", "볼륨 앞부분을 0 으로 미리 채운다", "볼륨을 읽기 전용으로 만들어 둔다"]', 0, '문서는 --sparse 를 주면 업로드가 볼륨의 sparseness 를 보존한다고 설명하며, --offset 은 쓰기를 시작할 위치, --length 는 업로드 양의 상한이라고 합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 8, 'vol-wipe', '`vol-wipe` 의 기본 지우기 방식과 `trim` 에 대한 설명으로 맞는 것은 무엇일까요?', 'zero 가 기본이에요.', NULL, NULL, '[]', 'choice', '["기본은 35회 덮어쓰기이고, trim 은 모든 풀이 지원한다", "기본은 trim 이고, zero 는 sparse 볼륨에 안전하다", "기본은 난수 1회이고, trim 은 데이터를 암호화한다", "기본은 0 으로 덮어쓰기이고, trim 은 드라이버에 TRIM·DISCARD 를 맡긴다"]', 3, '문서는 기본이 0 으로 덮어쓰는 방식이며 sparse·rbd 볼륨에서는 꽉 찬 것처럼 보일 수 있다고 하고, trim 은 드라이버가 바이트를 버리게 하되 모든 드라이버·볼륨이 지원하지는 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 9, 'vol-resize', '`vol-resize` 로 볼륨 크기를 **줄이려면** 무엇이 필요할까요?', '안전장치예요.', NULL, NULL, '[]', 'choice', '["--allocate 옵션을 줘야 한다", "--delta 옵션에 음수를 줘야 한다", "--shrink 옵션을 줘야 한다", "축소는 어떤 옵션으로도 불가능하다"]', 2, '문서는 줄이려는 시도가 --shrink 없이는 실패하며, --delta 는 기존 크기에 더하는 값이고 이 명령은 활성 게스트가 쓰지 않는 볼륨에만 안전하다(실시간은 blockresize)고 설명합니다.', NULL, NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 10, 'vol-wipe 명령', '볼륨에 있던 데이터를 **읽을 수 없게 지우는** 명령입니다. 빈칸을 채우세요.', '"닦다" 예요.', NULL, NULL, '[]', 'fill', '["wipe", "delete", "clone", "resize"]', NULL, '문서는 vol-wipe 가 볼륨에 있던 데이터를 이후 읽기로 접근할 수 없게 지운다고 설명합니다. vol-delete 는 볼륨 자체를 지웁니다.', '[0]', 'virsh vol-{0} VOL --pool default', NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 11, '--delta', '`vol-resize` 에서 새 크기가 아니라 **기존 크기에 더하는** 값으로 쓰게 하는 옵션입니다. 빈칸을 채우세요.', '"변화량" 이에요.', NULL, NULL, '[]', 'fill', '["delta", "allocate", "shrink", "sparse"]', NULL, '문서는 --delta 가 있으면 capacity 가 새 크기가 아니라 기존 크기에 더해지는 값이라고 설명합니다.', '[0]', 'virsh vol-resize VOL 10G --{0}', NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 474, 12, '볼륨 확장', '사용 중이 아닌 볼륨의 크기를 늘리고 확인하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 늘림 → 확인이에요.', NULL, NULL, '[]', 'order', '["그 볼륨을 쓰는 활성 게스트가 없는지 확인한다", "`virsh vol-resize VOL 20G --pool default` 로 용량을 늘린다", "`virsh vol-info VOL` 로 새 capacity 를 확인한다", "`virsh vol-info VOL --physical` 로 호스트의 실제 물리 크기도 확인한다"]', NULL, '문서는 vol-resize 가 활성 게스트가 쓰지 않는 볼륨에만 안전하다고 설명하며, vol-info --physical 은 allocation 대신 호스트 물리 크기를 보여 준다고 합니다. 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "virsh command reference", "url": "https://libvirt.org/manpages/virsh.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 474 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 643, unit_id = (SELECT id FROM unit WHERE id = 48), icon = '🗄️' WHERE id = 474;
