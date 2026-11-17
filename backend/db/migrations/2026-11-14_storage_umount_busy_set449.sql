-- 퀴즈 세트 449. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 449, 'umount 로 안전하게 분리하기: busy, -l 지연, -f 강제, -r, -R, 종료 코드', '언마운트 동작을 읽습니다. busy 가 되는 조건, 장치 이름 지정의 한계, -l 지연 언마운트와 권장 용도, -f 강제의 한계, -r 읽기 전용 재마운트, -R 재귀와 지정 방식, 종료 코드를 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 449);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 1, 'umount 역할', 'umount 는 무엇을 할까요?', '떼어 내요.', NULL, NULL, '[]', 'choice', '["파일시스템의 내용을 삭제한다", "블록 장치를 초기화한다", "파일시스템을 파일 계층에서 분리한다", "마운트 옵션을 영구 저장한다"]', 2, 'umount 문서는 언급한 파일시스템을 파일 계층에서 분리(detach)한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 2, 'busy 조건', '파일시스템이 **busy** 라서 언마운트되지 않는 경우는 언제일까요?', '사용 중이에요.', NULL, NULL, '[]', 'choice', '["읽기 전용으로 마운트되어 있을 때", "열린 파일이나 작업 디렉터리가 있을 때", "장치 이름으로 지정했을 때", "파일시스템 유형이 ext4 일 때"]', 1, '문서는 열린 파일이 있거나 어떤 프로세스의 작업 디렉터리가 있거나 스왑 파일이 쓰이는 중이면 언마운트할 수 없다고 설명합니다. umount 자신이 libc 로 파일을 열어 막을 수도 있습니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 3, '장치 이름 지정', '언마운트 대상을 **장치 이름** 으로 주는 방식을 문서는 어떻게 볼까요?', '옛 방식이에요.', NULL, NULL, '[]', 'choice', '["구식이며 여러 곳에 마운트되면 실패한다", "디렉터리 지정보다 더 안전하고 권장된다", "일반 사용자에게만 허용되는 방식이다", "루프 장치에서만 동작하는 방식이다"]', 0, '문서는 장치 이름 지정이 동작할 수도 있으나 구식이며, 장치가 둘 이상의 디렉터리에 마운트돼 있으면 실패한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 4, '-l 지연', '`umount -l` 은 무엇을 할까요?', '나중에 정리해요.', NULL, NULL, '[]', 'choice', '["사용 중인 프로세스를 모두 종료시킨다", "실패하면 읽기 전용으로 다시 마운트한다", "하위 마운트까지 재귀로 해제한다", "지금 분리하고 busy 가 아닐 때 정리한다"]', 3, '문서는 lazy 언마운트가 파일시스템을 지금 계층에서 분리하고 busy 가 아니게 되는 즉시 모든 참조를 정리한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 5, '-l 권장 용도', '문서가 `umount -l` 의 **권장 사용처** 로 드는 상황은 무엇일까요?', '종료 때 멈춰요.', NULL, NULL, '[]', 'choice', '["로컬 디스크를 가장 빠르게 해제하고 싶을 때", "읽기 전용 점검 전에 쓰기를 막고 싶을 때", "닿지 않는 네트워크 공유 때문에 종료 시 멈추는 것을 막을 때", "루프 장치를 다른 곳에 재사용하고 싶을 때"]', 2, '문서는 -l 의 권장 용도가 서버 다운이나 네트워크 단절로 일반 umount 가 멈추는 종료 시 hang 을 막는 것이며, 이후 그 공유의 재마운트는 불가능하다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 6, '-f 한계', '`umount -f` 에 대해 문서가 경고하는 점은 무엇일까요?', '보장이 없어요.', NULL, NULL, '[]', 'choice', '["로컬 파일시스템에서는 항상 데이터를 잃는다", "닿지 않는 NFS 에서 멈춤을 보장 못 한다", "루트 사용자에게는 동작하지 않는다", "실행 후 항상 재부팅이 필요하다"]', 1, '문서는 -f 가 닿지 않는 NFS 를 강제 언마운트하는 용도이며 umount 가 멈추지 않는다고 보장하지는 않고, 심볼릭 링크 없는 절대 경로 사용을 권한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 7, '-r 옵션', '`umount -r` 은 무엇을 할까요?', '실패했을 때예요.', NULL, NULL, '[]', 'choice', '["실패하면 읽기 전용으로 재마운트한다", "언마운트가 성공하면 장치를 읽기 전용으로 둔다", "실패하면 강제로 언마운트한다", "하위 마운트까지 재귀로 해제한다"]', 0, '문서는 -r/--read-only 가 언마운트에 실패했을 때 파일시스템을 읽기 전용으로 다시 마운트해 보게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 8, '-R 지정', '`umount -R` 은 대상을 **어떻게** 지정해야 할까요?', '경로로 줘요.', NULL, NULL, '[]', 'choice', '["장치 이름으로만 지정할 수 있다", "UUID 로만 지정할 수 있다", "장치와 마운트 지점 모두 똑같이 가능하다", "마운트 지점 경로로 지정한다(장치 불가)"]', 3, '문서는 -R 이 지정한 디렉터리를 재귀적으로 언마운트하며, 사슬의 한 단계라도 실패하면 멈추고, 파일시스템은 마운트 지점 경로로 지정해야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 9, '종료 코드 1', 'umount 종료 코드 `1` 은 무엇을 뜻할까요?', '호출 문제예요.', NULL, NULL, '[]', 'choice', '["메모리 부족 같은 시스템 오류", "파일시스템이 busy 라서 실패", "잘못된 호출이거나 권한 문제", "일부 파일시스템만 해제되어 부분 성공"]', 2, '문서는 종료 코드 0 이 성공, 1 이 잘못된 호출 또는 권한, 2 가 시스템 오류(메모리 부족, fork 실패, 루프 장치 부족)이며 비트를 OR 할 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 10, '지연 언마운트', '지금 분리하고 **정리는 나중에** 하는 옵션입니다. 빈칸을 채우세요.', 'lazy 의 l 이에요.', NULL, NULL, '[]', 'fill', '["-l", "-f", "-r", "-R"]', NULL, '-l 은 지연 언마운트입니다. -f 는 강제, -r 은 실패 시 읽기 전용 재마운트, -R 은 재귀입니다.', '[0]', 'umount {0} /mnt/data', NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 11, '재귀 언마운트', '하위 마운트까지 **재귀로** 언마운트하는 옵션입니다. 빈칸을 채우세요.', 'recursive 의 R 이에요.', NULL, NULL, '[]', 'fill', '["-R", "-r", "-l", "-a"]', NULL, '-R 은 지정한 디렉터리를 재귀적으로 언마운트합니다. 소문자 -r 은 읽기 전용 재마운트, -a 는 전체입니다.', '[0]', 'umount {0} /mnt', NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 449, 12, '언마운트 시도', 'busy 파일시스템을 언마운트하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '시도 → 원인 → 재시도 → 최후예요.', NULL, NULL, '[]', 'order', '["`umount /mnt/data` 로 언마운트를 시도한다", "busy 로 실패하면 열린 파일과 작업 디렉터리를 정리한다", "다시 `umount /mnt/data` 를 실행한다", "계속 막히면 `-l` 지연 언마운트를 고려한다"]', NULL, '문서의 busy 설명과 -l 설명을 이은 일반 절차입니다. -l 은 다른 문제를 낳을 수 있어 마지막 수단입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "umount(8) man page", "url": "https://man7.org/linux/man-pages/man8/umount.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 449 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 637, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '⏏️' WHERE id = 449;
