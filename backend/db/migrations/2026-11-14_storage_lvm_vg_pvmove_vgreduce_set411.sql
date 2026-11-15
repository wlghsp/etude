-- 퀴즈 세트 411. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round4.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 411, 'LVM 볼륨 그룹과 PV 이동: vgcreate, pvmove, vgreduce', '볼륨 그룹을 만들고 PV 를 옮기고 빼는 명령을 읽습니다. PE 기본 4MiB 와 변경의 어려움, PV 자동 초기화, LV 수 제한, pvmove 의 -n·재개·--abort, vgreduce 로 빈 PV 제거를 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 411);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 1, 'PE 기본 크기', '`vgcreate` 의 physical extent 크기 **기본값** 은 얼마일까요?', '4 로 시작해요.', NULL, NULL, '[]', 'choice', '["1 MiB", "16 MiB", "4 MiB", "64 MiB"]', 2, 'vgcreate 문서는 -s 의 기본값이 4 MiB 이며 최소 1 KiB 이고 2 의 거듭제곱이어야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "vgcreate(8) man page", "url": "https://linux.die.net/man/8/vgcreate"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 2, 'PE 크기 변경', '한번 정한 **PE 크기** 를 바꾸는 것에 대한 설명으로 맞는 것은 무엇일까요?', '쉽지 않아요.', NULL, NULL, '[]', 'choice', '["언제든 옵션 하나로 즉시 바꿀 수 있다", "보통은 VG 를 다시 만들고 데이터를 백업·복원해야 한다", "실행 중인 LV 가 있으면 자동으로 바뀐다", "PV 를 추가하면 새 크기로 바뀐다"]', 1, '문서는 extent 크기를 바꾸기가 어려워 보통 VG 를 다시 만들고 백업·복원해야 하며, extent 이동이 필요 없으면 vgchange -s 로 바꿀 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "vgcreate(8) man page", "url": "https://linux.die.net/man/8/vgcreate"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 3, 'PV 자동 초기화', '`vgcreate` 에 **pvcreate 하지 않은 장치** 를 주면 어떻게 될까요?', '알아서 해 줘요.', NULL, NULL, '[]', 'choice', '["pvcreate 와 같은 기본값으로 자동 초기화된다", "오류가 나므로 먼저 pvcreate 해야 한다", "장치가 자동으로 포맷되어 ext4 가 된다", "초기화 없이 VG 에서 건너뛴다"]', 0, '문서는 장치가 pvcreate 로 설정되지 않았다면 pvcreate 와 같은 기본값으로 초기화된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "vgcreate(8) man page", "url": "https://linux.die.net/man/8/vgcreate"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 4, 'LV 수 제한', 'LVM2 형식 VG 에서 `-l`(maxlogicalvolumes)의 **기본값 0** 은 무엇을 뜻할까요?', '숫자 0 의 특별한 의미예요.', NULL, NULL, '[]', 'choice', '["LV 를 만들 수 없다", "255 개로 제한한다", "1 개로 제한한다", "제한이 없다"]', 3, '문서는 LVM2 형식에서 -l 의 기본값이 0 이며 0 은 제한이 없음을 뜻한다고 설명합니다. LVM1 은 255 로 제한됩니다.', NULL, NULL, NULL, '[{"title": "vgcreate(8) man page", "url": "https://linux.die.net/man/8/vgcreate"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 5, 'pvmove 의 일', '`pvmove` 는 무엇을 할까요?', 'extent 를 옮겨요.', NULL, NULL, '[]', 'choice', '["PV 를 새 VG 로 그대로 복제해 둔다", "파일을 다른 디렉터리로 옮겨 둔다", "소스 PV 의 extent 를 다른 PV 로 옮긴다", "LV 의 이름을 새로 바꿔 둔다"]', 2, 'pvmove 문서는 소스 PV 의 할당된 physical extent 를 하나 이상의 다른 PV 로 옮긴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "pvmove(8) man page", "url": "https://linux.die.net/man/8/pvmove"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 6, 'pvmove 대상 생략', '`pvmove /dev/sdb1` 처럼 **대상 PV 를 생략** 하면 어떻게 될까요?', 'VG 의 규칙을 따라요.', NULL, NULL, '[]', 'choice', '["오류가 나서 실행되지 않는다", "VG 의 일반 할당 규칙으로 정해진다", "항상 가장 작은 PV 로 옮긴다", "옮길 extent 가 삭제된다"]', 1, '문서는 대상 PV 를 지정하지 않으면 볼륨 그룹의 일반 할당 규칙이 적용된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "pvmove(8) man page", "url": "https://linux.die.net/man/8/pvmove"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 7, 'pvmove -n', '`pvmove -n lv1 /dev/sdb1` 의 **-n** 은 무엇을 할까요?', 'LV 하나로 한정해요.', NULL, NULL, '[]', 'choice', '["지정한 LV 의 extent 만 옮긴다", "새 PV 의 이름을 지정한다", "이동 후 소스 PV 를 삭제한다", "이동을 시험만 하고 옮기지 않는다"]', 0, '문서는 -n 이 지정한 논리 볼륨에 속한 extent 만 소스 PV 에서 옮긴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "pvmove(8) man page", "url": "https://linux.die.net/man/8/pvmove"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 8, 'pvmove 재개', '`pvmove` 가 **중단** 되었을 때 이어서 하려면 어떻게 할까요?', '인자가 없어요.', NULL, NULL, '[]', 'choice', '["처음부터 다시 pvcreate 한다", "vgreduce 로 PV 를 제거한 뒤 다시 한다", "재개는 불가능하고 데이터를 복원해야 한다", "PV 인자 없이 pvmove 를 다시 실행한다"]', 3, '문서는 중단되면 PV 인자 없이 pvmove 를 다시 실행해 마지막 체크포인트 이후의 진행 중이던 이동을 재시작한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "pvmove(8) man page", "url": "https://linux.die.net/man/8/pvmove"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 9, 'vgreduce', '`vgreduce` 는 무엇을 할까요?', '쓰이지 않는 PV 만이에요.', NULL, NULL, '[]', 'choice', '["VG 의 크기를 더 늘린다", "LV 의 크기를 줄인다", "VG 에서 쓰지 않는 PV 를 뺀다", "PV 의 데이터를 지운다"]', 2, 'vgreduce 문서는 볼륨 그룹에서 사용되지 않는 PV 를 하나 이상 제거할 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "vgreduce(8) man page", "url": "https://linux.die.net/man/8/vgreduce"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 10, '이동 중단', '진행 중인 **pvmove 를 마지막 체크포인트에서 중단** 하는 옵션입니다. 빈칸을 채우세요.', '"중단" 이에요.', NULL, NULL, '[]', 'fill', '["--abort", "--all", "--force", "--test"]', NULL, '--abort 는 마지막 체크포인트에서 이동을 중단합니다.', '[0]', 'pvmove {0}', NULL, '[{"title": "pvmove(8) man page", "url": "https://linux.die.net/man/8/pvmove"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 11, '빈 PV 전부 제거', 'PV 를 지정하지 않고 **비어 있는 PV 를 모두** 제거하는 옵션입니다. 빈칸을 채우세요.', '"전부" 예요.', NULL, NULL, '[]', 'fill', '["--all", "--force", "--test", "--removemissing"]', NULL, '-a/--all 은 명령줄에 PV 를 지정하지 않으면 비어 있는 PV 를 모두 제거합니다.', '[0]', 'vgreduce {0} vg0', NULL, '[{"title": "vgreduce(8) man page", "url": "https://linux.die.net/man/8/vgreduce"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 411, 12, 'PV 를 VG 에서 빼기', '쓰던 PV 를 VG 에서 빼는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '옮기고 → 빼고 → 확인이에요.', NULL, NULL, '[]', 'order', '["`pvmove` 로 그 PV 의 extent 를 다른 PV 로 옮긴다", "`vgreduce` 로 비게 된 PV 를 VG 에서 제거한다", "`pvs` 와 `vgs` 로 결과를 확인한다"]', NULL, 'pvmove 와 vgreduce 문서의 설명을 이은 일반 절차입니다. 두 문서 모두 이 순서를 직접 적지는 않습니다.', '[0, 1, 2]', NULL, NULL, '[{"title": "vgreduce(8) man page", "url": "https://linux.die.net/man/8/vgreduce"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 411 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 627, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🔁' WHERE id = 411;
