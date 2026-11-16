-- 퀴즈 세트 442. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round6.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 442, 'lvcreate 로 LV 만들기: -L·-l, %FREE·%VG, 스냅샷, 미러·줄무늬, -Z', '논리 볼륨 생성 명령을 읽습니다. -L 크기와 -l 익스텐트, %FREE·%VG 접미사, 이름 생략 시 lvol#, COW·씬 스냅샷, raid1 기본과 legacy mirror, -i 가 암시하는 striped, -m 의미, -Z 기본값을 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 442);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 1, '-l 옵션', '`lvcreate -l` 은 새 LV 의 크기를 **어떤 단위** 로 정할까요?', 'extents 예요.', NULL, NULL, '[]', 'choice', '["바이트 수", "디스크 블록 수", "논리 익스텐트 수", "볼륨 그룹 이름"]', 2, 'lvcreate 문서는 -l/--extents 가 새 LV 의 크기를 논리 익스텐트로 정하고, -L/--size 는 크기 값으로 정한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 2, '%FREE', '`-l 100%FREE` 에서 `%FREE` 는 무엇을 뜻할까요?', '남은 공간이에요.', NULL, NULL, '[]', 'choice', '["VG 전체 크기", "VG 에 남은 여유 공간", "가장 큰 PV 의 크기", "기존 LV 들의 합계"]', 1, '문서는 %FREE 접미사가 VG 의 남은 여유 공간을 뜻하며, 퍼센트는 새 LV 의 논리 익스텐트 수 상한을 정한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 3, '%VG', '`-l 50%VG` 에서 `%VG` 는 무엇을 뜻할까요?', '전체예요.', NULL, NULL, '[]', 'choice', '["VG 전체 크기", "VG 에 남은 여유 공간", "새 LV 의 크기", "원본 LV 의 크기"]', 0, '문서는 %VG 접미사가 VG 의 전체 크기를 뜻한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 4, '이름 생략', '`-n` 으로 **이름을 주지 않으면** LV 이름은 어떻게 될까요?', '자동 이름이에요.', NULL, NULL, '[]', 'choice', '["VG 이름과 같은 이름이 쓰인다", "생성이 오류로 거부된다", "숫자 0 하나만 쓰인다", "lvol# 형태의 이름이 생성된다"]', 3, '문서는 -n/--name 으로 새 LV 이름을 정하며 생략하면 lvol# 같은 이름이 생성된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 5, 'COW 스냅샷', '`lvcreate -s` 로 **크기를 주면** 어떤 스냅샷이 만들어질까요?', '쓰기 시 복사예요.', NULL, NULL, '[]', 'choice', '["씬 스냅샷", "미러 스냅샷", "COW 스냅샷", "캐시 스냅샷"]', 2, '문서는 -s 가 원본 LV 의 고정된 이미지를 만들며 크기를 주면 COW 스냅샷, 원본이 씬 LV 이고 크기를 주지 않으면 씬 스냅샷이 만들어진다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 6, 'mirror 와 raid1', '`--type mirror` 와 `raid1` 의 관계에 대해 문서는 무엇이라 할까요?', 'mirror 는 옛 구현이에요.', NULL, NULL, '[]', 'choice', '["mirror 가 기본이고 raid1 은 옛 구현이다", "raid1 이 기본이고 mirror 는 옛 구현이다", "둘은 서로 다른 RAID 수준이다", "둘 다 씬 LV 전용이다"]', 1, '문서는 raid1 이 -m 의 기본이며 mirror 는 legacy 구현이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 7, '-i 와 striped', '`-i` 를 주면 LV 의 **유형** 은 어떻게 될까요?', '암시돼요.', NULL, NULL, '[]', 'choice', '["--type striped 가 암시된다", "--type linear 가 암시된다", "--type thin 이 암시된다", "--type cache 가 암시된다"]', 0, '문서는 -i/--stripes 가 줄무늬(stripe) 개수를 정하며 --type striped 가 -i 로 암시된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 8, '-Z 기본', '`-Z` 는 무엇을 제어하며 **기본값** 은 무엇일까요?', '처음 4KiB 예요.', NULL, NULL, '[]', 'choice', '["새 LV 전체 0 채우기, 기본 n", "새 LV 첫 4KiB 의 0 채우기, 기본 n", "새 LV 전체 서명 삭제, 기본 y", "새 LV 첫 4KiB 의 0 채우기, 기본 y"]', 3, '문서는 -Z/--zero 가 새 LV 첫 4KiB 의 0 채우기를 제어하며 기본값이 y 라고 설명합니다. 서명 삭제는 -W 입니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 9, '-m 옵션', '`lvcreate -m 1` 의 `1` 은 무엇을 뜻할까요?', '원본 말고 추가예요.', NULL, NULL, '[]', 'choice', '["전체 미러 이미지 수", "미러 로그의 개수", "추가 미러 이미지 수", "스트라이프 개수"]', 2, '문서는 -m/--mirrors 가 원본 LV 이미지 외에 추가로 둘 미러 이미지의 수를 정한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 10, '크기 지정', 'LV 의 **크기 값** 을 정하는 옵션입니다. 빈칸을 채우세요.', '대문자 L 이에요.', NULL, NULL, '[]', 'fill', '["-L", "-l", "-i", "-m"]', NULL, '-L/--size 는 크기 값을 정합니다. 소문자 -l 은 논리 익스텐트 수입니다.', '[0]', 'lvcreate {0} 5G -n mylv vg00', NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 11, '여유 공간 전부', 'VG 에 **남은 공간 전부** 를 쓰는 접미사입니다. 빈칸을 채우세요.', 'free 예요.', NULL, NULL, '[]', 'fill', '["FREE", "VG", "LV", "PV"]', NULL, '%FREE 는 VG 의 남은 여유 공간을, %VG 는 VG 전체 크기를 뜻합니다.', '[0]', 'lvcreate -l 100%{0} -n mylv vg00', NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 442, 12, 'LV 생성 조립', '줄무늬 LV 를 만드는 명령을 조립하는 순서입니다. 순서에 맞게 놓아 보세요.', '크기 → 이름 → 형태 → VG 예요.', NULL, NULL, '[]', 'order', '["`-L` 로 크기를 준다", "`-n` 으로 이름을 준다", "`-i` 와 `-I` 로 줄무늬 개수와 크기를 정한다", "마지막에 LV 를 만들 VG 이름을 적는다"]', NULL, '문서의 -L·-n·-i·-I 설명을 이은 조립 순서입니다. 옵션 순서 규칙은 원문이 직접 정하지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "lvcreate(8) man page", "url": "https://man7.org/linux/man-pages/man8/lvcreate.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 442 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 630, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🧮' WHERE id = 442;
