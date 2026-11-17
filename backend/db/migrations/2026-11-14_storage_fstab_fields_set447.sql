-- 퀴즈 세트 447. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 447, '/etc/fstab 읽기: 여섯 필드, UUID 권장, defaults·noauto·nofail, passno', '마운트 설정 파일을 읽습니다. 여섯 필드의 의미, LABEL·UUID 가 권장되는 이유, 스왑과 none 항목, 공백 이스케이프, defaults·noauto·nofail·user 옵션, dump 용 fs_freq 와 fsck 용 fs_passno 를 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 447);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 1, '첫째 필드', '/etc/fstab 한 줄의 **첫째 필드(fs_spec)** 는 무엇을 적을까요?', '대상이에요.', NULL, NULL, '[]', 'choice', '["마운트 지점이 될 디렉터리 경로", "파일시스템의 종류와 하위 유형", "마운트할 장치나 이미지", "부팅 때 점검하는 순서 번호"]', 2, 'fstab 문서는 첫째 필드가 마운트할 블록 특수 장치, 원격 파일시스템, 루프 장치용 이미지, 또는 스왑 대상을 나타낸다고 설명합니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 2, 'UUID 권장', '장치 이름 대신 `UUID=` 나 `LABEL=` 을 쓰는 것이 **권장되는 이유** 는 무엇일까요?', '이름이 바뀔 수 있어요.', NULL, NULL, '[]', 'choice', '["UUID 를 쓰면 파일시스템 읽기 속도가 빨라진다", "장치 이름은 하드웨어 감지 순서에 따라 바뀔 수 있다", "장치 이름은 fstab 에 쓸 수 없는 값이다", "LABEL 을 쓰면 파일시스템이 자동 암호화된다"]', 1, '문서는 장치 이름이 하드웨어 감지 순서의 우연이어서 디스크를 추가하거나 빼면 바뀔 수 있으므로 LABEL·UUID 가 권장된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 3, '스왑 둘째 필드', '스왑 영역 줄의 **둘째 필드(fs_file)** 에는 무엇을 적을까요?', '지점이 없어요.', NULL, NULL, '[]', 'choice', '["none", "swap", "/swap", "0"]', 0, '문서는 스왑 영역의 fs_file 을 none 으로 지정해야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 4, '공백 이스케이프', '마운트 지점 이름에 **공백** 이 들어 있으면 fstab 에서 어떻게 적을까요?', '8진수 코드예요.', NULL, NULL, '[]', 'choice', '["이름 전체를 큰따옴표로만 감싼다", "공백 앞에 백슬래시 하나를 붙인다", "공백을 밑줄로 바꿔야만 한다", "공백을 \\\\040 으로 이스케이프한다"]', 3, '문서는 필드 안의 공백·탭을 \\040·\\011 로 이스케이프해야 하며, 따옴표 안에서도 마찬가지라고 설명합니다. 줄을 먼저 필드로 나눈 뒤 해석하기 때문입니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 5, 'none 유형', '셋째 필드(fs_vfstype)에 `none` 을 적는 것은 어떤 마운트에 유용할까요?', '특수한 마운트예요.', NULL, NULL, '[]', 'choice', '["스왑 영역 활성화", "NFS 원격 마운트", "바인드 마운트나 이동 마운트", "읽기 전용 이미지 마운트"]', 2, '문서는 none 항목이 바인드 또는 이동 마운트에 유용하다고 설명합니다. 스왑 영역은 swap 항목으로 나타냅니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 6, 'defaults', '넷째 필드의 `defaults` 에 대한 설명으로 맞는 것은 무엇일까요?', '고정 목록이 없어요.', NULL, NULL, '[]', 'choice', '["mount 가 항상 ro,noexec 로 고정해 적용한다", "mount 의 고정 목록은 없고 커널·파일시스템마다 다르다", "defaults 는 nofail 과 같은 의미이다", "모든 파일시스템에서 동일한 옵션 묶음이다"]', 1, '문서는 defaults 가 커널과 파일시스템에 따라 다르며 mount 에 하드코딩된 기본 옵션 집합은 없다고 설명합니다. 커널 기본은 보통 rw, suid, dev, exec, auto, nouser, async 입니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 7, 'noauto', '`noauto` 옵션은 무엇을 할까요?', '일괄 마운트에서 빠져요.', NULL, NULL, '[]', 'choice', '["`mount -a` 를 할 때 마운트하지 않는다", "부팅할 때 파일시스템 점검을 건너뛴다", "장치가 없어도 오류를 보고하지 않는다", "일반 사용자의 마운트를 허용한다"]', 0, '문서는 noauto 가 mount -a(예: 부팅 때)를 줄 때 마운트하지 않게 한다고 설명합니다. 오류 무시는 nofail 입니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 8, 'user 옵션', '`user` 옵션은 무엇을 허용할까요?', '권한 옵션이에요.', NULL, NULL, '[]', 'choice', '["장치의 소유자만 마운트하는 것", "모든 사용자의 쓰기 접근", "부팅 때 자동으로 마운트하는 것", "일반 사용자가 마운트하는 것"]', 3, '문서는 user 가 사용자의 마운트를 허용하고 owner 가 장치 소유자의 마운트를 허용한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 9, '다섯째 필드', '다섯째 필드(fs_freq)는 **어떤 도구** 가 쓸까요?', '백업과 관련돼요.', NULL, NULL, '[]', 'choice', '["fsck(8)", "mount(8)", "dump(8)", "swapon(8)"]', 2, '문서는 fs_freq 가 dump(8)가 덤프할 파일시스템을 정할 때 쓰며, 없으면 0(덤프하지 않음)이라고 설명합니다. 점검 순서는 여섯째 필드 fs_passno 입니다.', NULL, NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 10, '루트 passno', '루트 파일시스템의 **여섯째 필드(fs_passno)** 값입니다. 빈칸을 채우세요.', '가장 먼저 점검해요.', NULL, NULL, '[]', 'fill', '["1", "2", "0", "9"]', NULL, '문서는 루트 파일시스템의 fs_passno 를 1 로, 다른 파일시스템을 2 로 지정하라고 설명합니다. 0 이면 점검하지 않습니다.', '[0]', '/dev/sda1 / ext4 defaults 0 {0}', NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 11, 'nofail 옵션', '장치가 없어도 **오류를 보고하지 않게** 하는 옵션입니다. 빈칸을 채우세요.', '실패해도 괜찮아요.', NULL, NULL, '[]', 'fill', '["nofail", "noauto", "user", "owner"]', NULL, 'nofail 은 장치가 존재하지 않아도 오류를 보고하지 않게 합니다. noauto 는 mount -a 때 마운트하지 않는 옵션입니다.', '[0]', 'LABEL=backup /backup ext4 defaults,{0} 0 2', NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 447, 12, 'fstab 항목 추가', 'fstab 에 새 파일시스템을 추가하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '확인 → 기록 → 검증 → 반영이에요.', NULL, NULL, '[]', 'order', '["`blkid` 로 장치의 UUID 를 확인한다", "`/etc/fstab` 에 UUID 를 쓴 줄을 추가한다", "`findmnt --verify` 로 fstab 을 검증한다", "systemd 시스템이면 `systemctl daemon-reload` 를 실행한다"]', NULL, '문서의 UUID 권장, findmnt 의 --verify 설명, fstab 수정 후 daemon-reload 권고를 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "fstab(5) man page", "url": "https://man7.org/linux/man-pages/man5/fstab.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 447 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 635, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '📒' WHERE id = 447;
