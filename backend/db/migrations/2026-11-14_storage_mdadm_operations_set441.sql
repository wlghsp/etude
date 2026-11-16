-- 퀴즈 세트 441. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round5.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 441, 'mdadm 으로 배열 운영하기: 디스크 교체, detail·examine, 메타데이터, 비트맵', '소프트웨어 RAID 운영을 읽습니다. --detail 과 --examine 의 대상, --fail·--remove·--add·--replace 로 장치 교체, --stop, --zero-superblock, 메타데이터 1.2 기본, write-mostly, 내부 비트맵을 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 441);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 1, 'detail 과 examine', '`--detail` 과 `--examine` 의 **대상** 은 어떻게 다를까요?', '활성 배열 대 구성 장치예요.', NULL, NULL, '[]', 'choice', '["--detail 은 구성 장치, --examine 은 활성 배열", "둘 다 활성 배열의 커널 로그를 보여 준다", "--detail 은 활성 배열, --examine 은 구성 장치", "둘 다 장치의 SMART 정보를 보여 준다"]', 2, '문서는 --detail 이 md 장치의 상세를 출력하고 --examine 이 지정한 장치에 저장된 메타데이터 내용을 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 2, '--fail', '`mdadm /dev/md0 --fail /dev/sdb` 는 무엇을 할까요?', '표시만 해요.', NULL, NULL, '[]', 'choice', '["장치를 배열에서 제거한다", "장치를 결함(faulty)으로 표시한다", "장치를 여유 장치로 추가한다", "장치의 superblock 을 지운다"]', 1, '문서는 --fail(-f)이 나열한 장치를 결함으로 표시한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 3, '--remove', '`--remove` 는 **어떤 장치** 에만 쓸 수 있을까요?', '활성 상태면 안 돼요.', NULL, NULL, '[]', 'choice', '["활성 상태가 아닌 장치", "활성 상태인 장치", "여유 장치가 없는 배열의 장치", "결함이 아닌 모든 장치"]', 0, '문서는 --remove(-r)가 더 이상 활성이 아닌 장치를 제거하며 장치는 활성이 아니어야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 4, '--replace', '`--replace` 는 장치를 어떻게 바꿀까요?', '쓰는 동안 재구축해요.', NULL, NULL, '[]', 'choice', '["기존 장치를 즉시 결함으로 표시하고 제거한다", "기존 장치의 내용을 지우고 새로 만든다", "배열을 중지한 뒤 장치를 바꾼다", "여유 장치가 재구축되는 동안 기존 장치를 계속 사용한다"]', 3, '문서는 --replace 가 장치를 교체 대상으로 표시하되 여유 장치가 재구축될 때까지 계속 사용 상태로 둔다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 5, '--stop', '`mdadm --stop /dev/md0` 은 무엇을 할까요?', '비활성화예요.', NULL, NULL, '[]', 'choice', '["배열의 데이터를 지운다", "배열의 superblock 을 지운다", "비활성화하고 자원을 해제한다", "배열을 재구축한다"]', 2, '문서는 --stop 이 배열을 비활성화하고 모든 자원을 해제한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 6, 'zero-superblock', '`--zero-superblock` 은 무엇을 할까요?', '메타데이터를 지워요.', NULL, NULL, '[]', 'choice', '["배열의 모든 데이터를 0 으로 덮어쓴다", "superblock 블록을 0 으로 덮어쓴다", "장치를 결함 상태로 표시해 둔다", "장치의 파티션 표를 통째로 지운다"]', 1, '문서는 --zero-superblock 이 장치에 유효한 md superblock 이 있으면 그 블록을 0 으로 덮어쓴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 7, '메타데이터 기본', '`--metadata` 의 1.x 형식에서 **기본값** 은 무엇일까요?', '1.2 예요.', NULL, NULL, '[]', 'choice', '["1.2", "0.90", "1.0", "1.1"]', 0, '문서는 1.x 형식(1, 1.0, 1.1, 1.2)에서 기본값이 1.2 라고 설명합니다. 0.90 은 원래 형식이며 구성 장치 28개, 2TB 제한이 있습니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 8, 'write-mostly', '`--write-mostly` 가 표시된 장치는 **어떻게** 쓰일까요?', 'RAID1 에서만 의미가 있어요.', NULL, NULL, '[]', 'choice', '["RAID5 에서 패리티를 저장한다", "그 장치로의 쓰기를 거부한다", "그 장치에서 읽기만 허용한다", "RAID1 에서 읽기를 피한다"]', 3, '문서는 --write-mostly 가 RAID1 에만 적용되며 드라이버가 가능하면 그 장치에서 읽지 않도록 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 9, 'internal bitmap', '`--bitmap=internal` 은 비트맵을 **어디** 에 저장할까요?', '메타데이터와 함께예요.', NULL, NULL, '[]', 'choice', '["별도의 파일 한 개에만 저장된다", "여유 장치 한 개에만 저장된다", "메타데이터와 함께 모든 장치에 복제된다", "RAM 에만 저장되고 재부팅하면 사라진다"]', 2, '문서는 internal 비트맵이 배열의 메타데이터와 함께 저장되어 모든 장치에 복제된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 10, '결함 표시', '장치를 **결함으로 표시하는** 옵션입니다. 빈칸을 채우세요.', 'fail 이에요.', NULL, NULL, '[]', 'fill', '["--fail", "--remove", "--add", "--replace"]', NULL, '--fail(-f)은 장치를 결함으로 표시합니다. --remove 는 활성이 아닌 장치를 제거합니다.', '[0]', 'mdadm /dev/md0 {0} /dev/sdb', NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 11, 'superblock 지우기', '장치의 **md superblock 을 0 으로 덮어쓰는** 옵션입니다. 빈칸을 채우세요.', 'zero 가 들어가요.', NULL, NULL, '[]', 'fill', '["--zero-superblock", "--examine", "--stop", "--detail"]', NULL, '--zero-superblock 은 유효한 md superblock 이 있으면 그 블록을 0 으로 덮어씁니다.', '[0]', 'mdadm {0} /dev/sdb', NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 441, 12, '디스크 교체', '결함 장치를 교체하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '표시 → 제거 → 추가 → 확인이에요.', NULL, NULL, '[]', 'order', '["`--fail` 로 문제 장치를 결함으로 표시한다", "`--remove` 로 활성이 아닌 그 장치를 제거한다", "`--add` 로 새 장치를 핫 추가한다", "`--detail` 로 배열 상태를 확인한다"]', NULL, '문서의 --fail·--remove·--add·--detail 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "mdadm(8) man page", "url": "https://man7.org/linux/man-pages/man8/mdadm.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 441 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 629, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🔧' WHERE id = 441;
