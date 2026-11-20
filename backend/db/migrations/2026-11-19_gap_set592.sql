-- 세트 592. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set592.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 592, '파일시스템이란: 블록·inode·슈퍼블록, 저널링, 링크, ext4 와 XFS, 마운트', '디스크를 쓰기 전에 알아야 할 파일시스템의 기본 개념입니다. 블록과 inode 가 각각 무엇을 담는지, 슈퍼블록의 역할, 작은 파일이 블록을 낭비하는 이유, 저널링이 비정상 종료 뒤에 해 주는 일, 하드 링크와 심볼릭 링크의 차이, 파일을 지울 때 일어나는 일, ext4 와 XFS 의 선택 기준, 마운트 지점의 의미를 문제로 풀어 봅니다.', 'linux', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 592);
UPDATE quest_set SET display_order = 852, unit_id = (SELECT id FROM unit WHERE id = 70), icon = '📚' WHERE id = 592;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 1, 'inode 가 담는 것', '리눅스 파일시스템에서 파일의 크기·소유자·권한·시각과 **데이터가 있는 블록의 위치**를 담는 구조는 무엇일까요?', '파일 이름이 아니라 파일의 속성과 데이터 위치입니다.', NULL, NULL, '[]', 'choice', '["inode 가 속성과 데이터 블록 위치를 담는다", "디렉터리의 이름 목록이 모든 속성을 담는다", "슈퍼블록이 파일마다의 속성을 직접 담는다", "저널이 파일의 실제 내용을 담고 있다"]', 0, 'inode 는 파일 하나의 메타데이터(크기·소유자·권한·시각·데이터 블록 위치)를 담습니다. 파일 이름은 inode 가 아니라 디렉터리 항목이 inode 번호와 짝지어 가지고 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 2, '슈퍼블록의 역할', '파일시스템의 **슈퍼블록**이 담고 있는 정보로 가장 알맞은 것은?', '파일 하나가 아니라 파일시스템 전체에 대한 정보입니다.', NULL, NULL, '[]', 'choice', '["파일마다의 소유자와 권한 같은 개별 정보", "사용자가 저장한 파일의 실제 데이터 내용", "네트워크 마운트 대상의 주소와 인증 정보", "블록 크기·전체 크기·inode 수 등 전체 정보"]', 3, '슈퍼블록은 파일시스템의 크기·블록 크기·inode 수·상태·마운트 횟수 등 전체 정보를 담은 가장 중요한 구조입니다. 손상되면 마운트가 안 되지만 여러 곳에 백업이 있어 복구할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 3, '작은 파일과 블록 낭비', '블록 크기가 4KiB 인 파일시스템에 **1바이트짜리 파일**을 만들면 디스크는 대략 얼마를 차지할까요?', '파일시스템은 블록 단위로만 공간을 나눠 줍니다.', NULL, NULL, '[]', 'choice', '["정확히 1바이트만 차지한다", "블록 크기와 무관하게 512바이트를 차지한다", "블록 하나(4KiB)를 차지한다", "아무 공간도 차지하지 않는다"]', 2, '블록은 공간을 할당하는 최소 단위라 1바이트 파일도 블록 하나를 씁니다. 작은 파일이 아주 많으면 이런 낭비가 쌓이고 inode 도 파일마다 하나씩 소모됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 4, '저널링의 효과', '정전으로 서버가 갑자기 꺼졌습니다. 저널을 쓰는 ext4 파일시스템이 부팅 때 얻는 이점으로 알맞은 것은?', '저널은 변경 내용을 먼저 기록해 두는 로그입니다.', NULL, NULL, '[]', 'choice', '["모든 파일의 내용이 자동으로 복원된다", "저널을 재생해 메타데이터 일관성을 빠르게 복구한다", "디스크 전체를 처음부터 검사해야 한다", "삭제된 파일이 복구되어 되돌아온다"]', 1, '저널은 메타데이터 변경을 먼저 기록해 두어, 비정상 종료 뒤 전체 검사 없이 저널만 재생해 일관성을 회복합니다. 저널링이 모든 데이터 내용을 보장하는 것은 아닙니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 5, '하드 링크와 심볼릭 링크', '파일 `a` 의 하드 링크 `b` 와 심볼릭 링크 `c` 를 만든 뒤 원본 `a` 를 삭제했습니다. 이후 상태로 알맞은 것은?', '하드 링크는 같은 inode 를, 심볼릭 링크는 경로 문자열을 가리킵니다.', NULL, NULL, '[]', 'choice', '["b 는 읽히고 c 는 끊어진다", "b 와 c 모두 그대로 읽힌다", "b 와 c 모두 끊어져 읽을 수 없다", "b 는 끊어지고 c 는 읽힌다"]', 0, '하드 링크는 같은 inode 에 이름을 하나 더 붙인 것이라 이름 하나를 지워도 링크 수가 남아 데이터가 유지됩니다. 심볼릭 링크는 경로를 저장한 별도 파일이라 대상이 사라지면 끊어집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 6, '파일을 지울 때', '파일을 `rm` 으로 지웠는데 디스크 공간이 바로 돌아오지 않습니다. 원인으로 알맞은 설명은?', 'inode 의 링크 수와 열려 있는 프로세스를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["rm 은 파일 내용을 지우지 않고 이름만 바꾼다", "지운 파일은 항상 한 시간 뒤에 공간이 돌아온다", "공간은 서버를 재부팅해야만 돌아온다", "프로세스가 그 파일을 열고 있어 inode 가 해제되지 않는다"]', 3, '파일의 이름(링크)이 모두 사라지고 열려 있는 프로세스도 없어야 inode 와 블록이 해제됩니다. 프로세스가 열고 있으면 이름이 없어도 공간을 차지해 프로세스를 닫거나 재시작해야 돌아옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 7, 'ext4 와 XFS 의 선택', '다음 설명 중 ext4 와 XFS 에 대해 사실에 맞는 것은?', '크기를 줄이는 것과 늘리는 것은 지원이 다릅니다.', NULL, NULL, '[]', 'choice', '["두 파일시스템 모두 마운트한 채로 자유롭게 줄일 수 있다", "XFS 는 줄일 수 있지만 ext4 는 늘릴 수 없다", "XFS 는 줄일 수 없고, ext4 는 언마운트 후 줄일 수 있다", "두 파일시스템 모두 늘릴 수도 줄일 수도 없다"]', 2, 'ext4 는 온라인 확장과 오프라인 축소가 가능하고, XFS 는 온라인 확장만 가능하며 축소를 지원하지 않습니다. 배포판 기본 선택도 다릅니다(RHEL 계열은 XFS, 많은 Ubuntu 설치는 ext4).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 8, '마운트 지점의 파일', '`/data` 디렉터리에 파일이 몇 개 있는 상태에서, 새 디스크의 파일시스템을 `/data` 에 마운트했습니다. 마운트 중에 원래 있던 파일은?', '마운트는 그 디렉터리에 다른 파일시스템을 덮어씌웁니다.', NULL, NULL, '[]', 'choice', '["새 디스크 쪽으로 자동으로 모두 복사된다", "마운트 중에는 가려지고, 언마운트하면 다시 보인다", "마운트하는 순간 모두 삭제되어 사라진다", "그대로 보이면서 새 디스크 파일과 합쳐진다"]', 1, '마운트하면 마운트 지점의 원래 내용은 가려지고 새 파일시스템의 내용이 보입니다. 삭제되지는 않아 언마운트하면 다시 보이며, df 와 du 의 용량 차이의 원인이 되기도 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 9, 'lsblk 로 확인하기', '디스크에 어떤 파일시스템이 만들어져 있는지와 UUID 를 한눈에 보려고 합니다. 가장 알맞은 방법은?', '블록 장치 목록에 파일시스템 정보를 더해 보는 옵션이 있습니다.', NULL, NULL, '[]', 'choice', '["`lsblk -f` 로 종류와 UUID 를 본다", "`ls /dev` 로 장치 이름만 본다", "`ping` 으로 장치에 응답이 오는지 본다", "`top` 으로 디스크 사용률을 본다"]', 0, '`lsblk -f` 는 블록 장치와 파티션별 파일시스템 종류·레이블·UUID·마운트 지점을 보여 줍니다. `blkid` 도 비슷한 정보를 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 10, '심볼릭 링크 만들기', '`target` 을 가리키는 **심볼릭 링크** `link` 를 만드는 명령입니다. 빈칸을 채우세요.', '옵션 없이 `ln` 만 쓰면 하드 링크가 만들어집니다.', NULL, NULL, '[]', 'fill', '["-s", "-f", "-v", "-i"]', NULL, '`ln -s` 가 심볼릭 링크를 만듭니다. `-f` 는 기존 대상을 강제로 덮어쓰고, `-v` 는 자세히 출력, `-i` 는 덮어쓰기 전에 확인하는 옵션입니다.', '[0]', 'ln {0} target link', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 11, '파일시스템 정보 보기', '블록 장치마다 **파일시스템 종류와 UUID** 를 보여 주는 `lsblk` 옵션을 채우세요.', '옵션 설명은 `lsblk --help` 에서 FSTYPE·UUID 열을 내는 항목을 찾아보세요.', NULL, NULL, '[]', 'fill', '["f", "a", "b", "t"]', NULL, '`-f` 는 파일시스템 종류·레이블·UUID·마운트 지점을 보여 줍니다. `-a` 는 빈 장치까지 모두, `-b` 는 바이트 단위 크기, `-t` 는 토폴로지 정보입니다.', '[0]', 'lsblk -{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 592, 12, '새 디스크를 쓰기까지', '서버에 새 디스크가 추가되었습니다. 쓸 수 있게 만들고, 재부팅 후에도 유지되게 하려 합니다. 올바른 순서로 놓으세요.', '각 단계가 앞 단계의 결과물을 필요로 하는지 따져 보세요.', NULL, NULL, '[]', 'order', '["`/etc/fstab` 에 영구 마운트 항목을 등록한다", "파티션 위에 파일시스템을 만든다", "파티션을 만든다", "마운트 지점에 마운트하고 동작을 확인한다"]', NULL, '파티션 → 파일시스템 생성 → 마운트·확인 → fstab 등록 순서입니다. fstab 은 잘못되면 부팅이 막힐 수 있어 마운트가 되는 것을 확인한 뒤 UUID 로 등록합니다.', '[2, 1, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 592 AND order_index = 12);
