-- 스토리지 퀴즈 세트 376. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_quiz_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 376, '스토리지 개념 지도: 블록·파일·오브젝트, NFS·iSCSI, RAID', '저장 방식 세 가지(블록·파일·오브젝트)를 구분하고, 대표 프로토콜 NFS 와 iSCSI 의 차이, RAID 0·1·5 의 특징과 용량 계산, RAID 는 백업이 아니라는 점, 디스크 고장 뒤 복구 순서를 익힙니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 376);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 1, '블록 스토리지', '서버에 **디스크처럼** 붙여서, 서버가 직접 파티션을 나누고 파일시스템을 만들어 쓰는 저장 방식은 무엇일까요?', '운영체제가 "새 디스크가 생겼다"고 보는 방식이에요.', NULL, NULL, '[]', 'choice', '["파일(오브젝트) 스토리지", "오브젝트 스토리지", "블록 스토리지", "메모리 캐시 스토리지"]', 2, '블록 스토리지는 데이터를 일정 크기의 블록 단위로 다루고, 서버가 그 위에 파일시스템을 직접 올립니다. Ceph 용어집도 저장 방식을 블록·오브젝트·파일 세 가지로 구분합니다. (오브젝트 스토리지는 이름으로 객체를 주고받고, 파일 스토리지는 디렉터리 구조를 서버끼리 공유합니다.)', NULL, NULL, NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 2, '파일 스토리지', '여러 서버가 **같은 디렉터리와 파일** 을 네트워크로 함께 읽고 쓰게 해 주는 방식은 무엇일까요?', 'NFS 가 대표적이에요.', NULL, NULL, '[]', 'choice', '["블록 스토리지 (예: iSCSI 로 붙인 디스크)", "파일 스토리지 (예: NFS)", "오브젝트 스토리지의 버킷", "서버 안에 있는 로컬 디스크"]', 1, '파일 스토리지는 파일시스템을 서버 쪽에서 관리하고 클라이언트가 이름과 경로로 접근합니다. NFS 가 대표적입니다. 블록 스토리지는 클라이언트가 파일시스템을 직접 만들기 때문에 보통 서버 한 대가 씁니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 3, '오브젝트 스토리지', '`S3` 나 `Swift` 같은 **HTTP API** 로 버킷에 객체를 올리고 내려받는 저장 방식은 무엇일까요?', '파일시스템을 마운트하지 않아요.', NULL, NULL, '[]', 'choice', '["오브젝트 스토리지", "블록 스토리지", "NFS 같은 파일 스토리지", "RAID 로 묶은 로컬 디스크"]', 0, 'Ceph 의 RGW 는 Amazon S3 와 OpenStack Swift 두 API 를 제공하는 오브젝트 게이트웨이입니다. 객체 스토리지는 마운트하지 않고 API 로 접근합니다.', NULL, NULL, NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 4, 'NFS 의 기본 동작', 'NFS 서버가 응답하지 않을 때, 마운트 옵션을 따로 주지 않으면 클라이언트는 어떻게 동작할까요?', '옵션 `hard` 가 기본값이에요.', NULL, NULL, '[]', 'choice', '["몇 번 시도한 뒤 오류를 돌려준다", "바로 자동으로 마운트를 해제한다", "로컬 디스크에 임시로 복사해 둔다", "요청을 끝없이 다시 시도한다"]', 3, 'nfs(5) 는 옵션이 없거나 `hard` 이면 NFS 요청을 무한히 재시도하고, `soft` 나 `softerr` 이면 `retrans` 횟수만큼 보낸 뒤 실패시킨다고 설명합니다. 그래서 NFS 서버가 멎으면 클라이언트의 프로세스가 멈춘 듯 보일 수 있습니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 5, 'iSCSI 의 두 역할', 'iSCSI 에서 디스크를 **제공하는 쪽** 과 **붙여 쓰는 쪽** 을 부르는 이름은 무엇일까요?', '제공은 target, 사용은 initiator 예요.', NULL, NULL, '[]', 'choice', '["제공하는 쪽은 이니시에이터(initiator), 쓰는 쪽은 타깃(target)", "제공하는 쪽은 마스터(master), 쓰는 쪽은 슬레이브(slave)", "제공하는 쪽은 타깃(target), 쓰는 쪽은 이니시에이터(initiator)", "둘 다 그냥 노드(node)라고만 부르며 역할 이름은 따로 없다"]', 2, 'RFC 7143 은 iSCSI 노드를 타깃(저장소를 내주는 쪽)과 이니시에이터(요청하는 쪽)로 나눕니다. 이니시에이터 서버에는 타깃의 디스크가 블록 장치로 보입니다.', NULL, NULL, NULL, '[{"title": "RFC 7143 iSCSI 프로토콜", "url": "https://www.rfc-editor.org/rfc/rfc7143"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 6, 'RAID 0', 'RAID 0 에 대한 설명으로 알맞은 것은 무엇일까요?', '이름 그대로 중복이 0 이에요.', NULL, NULL, '[]', 'choice', '["같은 데이터를 두 디스크에 똑같이 써서 하나가 고장 나도 데이터가 안전하다", "데이터를 여러 디스크에 나눠 쓰며(스트라이핑) 디스크 하나만 고장 나도 전체를 잃는다", "패리티를 두 개 계산해 써서 디스크 두 개가 고장 나도 견딘다", "디스크 한 개를 전용 예비(스페어)로 비워 두고 평소에는 쓰지 않는다"]', 1, '커널 md 문서는 RAID 레벨 `0` 을 striped 모드로 소개합니다. 속도와 용량은 늘지만 중복이 없어서 디스크 하나가 고장 나면 전체 데이터가 사라집니다.', NULL, NULL, NULL, '[{"title": "리눅스 커널 md 문서", "url": "https://docs.kernel.org/admin-guide/md.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 7, 'RAID 1', 'RAID 1 의 특징으로 알맞은 것은 무엇일까요?', '거울(미러)처럼 똑같이 써요.', NULL, NULL, '[]', 'choice', '["같은 데이터를 두 디스크 이상에 똑같이 쓰며, 쓸 수 있는 용량은 디스크 한 개 분이다", "데이터를 디스크에 나눠 써서 쓸 수 있는 용량이 디스크 수만큼 늘어난다", "패리티 계산 값을 디스크 하나에 모아 두어 고장에 대비한다", "디스크가 고장 나면 어레이가 모든 데이터를 지우고 새로 시작한다"]', 0, 'RAID 1 은 미러링입니다. 디스크 하나가 고장 나도 다른 디스크에 같은 데이터가 있습니다. 대신 용량 효율은 디스크 두 개를 묶으면 50% 입니다.', NULL, NULL, NULL, '[{"title": "표준 RAID 레벨 (위키백과)", "url": "https://en.wikipedia.org/wiki/Standard_RAID_levels"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 8, 'RAID 5 의 내결함성', 'RAID 5 는 디스크가 몇 개까지 고장 나도 데이터를 지킬 수 있을까요?', '패리티가 하나예요.', NULL, NULL, '[]', 'choice', '["0 개 (고장 나면 바로 손실)", "2 개까지", "디스크 수의 절반까지", "1 개까지"]', 3, 'RAID 5 는 디스크마다 돌아가며 패리티를 하나 두어 디스크 1 개 고장을 견딥니다. 패리티가 두 개인 RAID 6 은 2 개까지 견딥니다. 커널 md 문서는 raid5·raid6 의 패리티를 신뢰할 수 없을 때(dirty 이면서 degraded) 데이터가 손상될 수 있다고 경고합니다.', NULL, NULL, NULL, '[{"title": "리눅스 커널 md 문서", "url": "https://docs.kernel.org/admin-guide/md.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 9, 'RAID 는 백업이 아니다', 'RAID 1 로 묶인 디스크에서 실수로 파일을 `rm` 했습니다. 어떻게 될까요?', '미러는 지우는 것도 똑같이 따라해요.', NULL, NULL, '[]', 'choice', '["미러 디스크에 파일이 남아 있어서 바로 복구할 수 있다", "다음에 재부팅할 때 어레이가 자동으로 파일을 되살려 준다", "두 디스크에서 같이 지워져서 RAID 만으로는 되돌릴 수 없다", "패리티 정보로부터 지운 파일이 자동으로 다시 만들어진다"]', 2, 'RAID 는 디스크 고장에 대비한 중복이지 백업이 아닙니다. 삭제·덮어쓰기·랜섬웨어는 모든 복제본에 똑같이 반영되므로 별도의 백업이 필요합니다.', NULL, NULL, NULL, '[{"title": "표준 RAID 레벨 (위키백과)", "url": "https://en.wikipedia.org/wiki/Standard_RAID_levels"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 10, 'NFS 표준 포트', 'NFS 클라이언트가 쓰는 **표준 포트 번호** 를 채우세요.', 'nfs(5) 의 `port` 옵션 설명에 나와요.', NULL, NULL, '[]', 'fill', '["2049", "3260", "443", "111"]', NULL, 'nfs(5) 는 `port` 옵션이 없으면 클라이언트가 표준 NFS 포트 2049 를 쓴다고 설명합니다. 3260 은 iSCSI 의 기본 포트입니다.', '[0]', 'NFS 표준 포트: {0}', NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 11, 'RAID 5 의 사용 용량', '2 TB 디스크 **4 개** 를 RAID 5 로 묶으면 쓸 수 있는 용량(TB)을 채우세요.', '패리티로 디스크 1 개 분이 쓰여요.', NULL, NULL, '[]', 'fill', '["6", "8", "4", "2"]', NULL, 'RAID 5 의 사용 용량은 (디스크 수 - 1) × 디스크 크기입니다. (4 - 1) × 2 TB = 6 TB 입니다. 8 TB 는 RAID 0, 4 TB 는 RAID 10 의 값입니다.', '[0]', '사용 용량: {0} TB', NULL, '[{"title": "표준 RAID 레벨 (위키백과)", "url": "https://en.wikipedia.org/wiki/Standard_RAID_levels"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 376, 12, '디스크가 고장 났을 때', 'RAID 5 어레이에서 디스크 하나가 고장 났을 때 복구하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '알아챔 → 빼냄 → 새로 넣음 → 다시 채움 순서예요.', NULL, NULL, '[]', 'order', '["어레이가 degraded 상태가 된 것을 알아챈다", "고장 난 디스크를 어레이에서 분리한다", "새 디스크를 어레이에 추가한다", "재구성(rebuild)이 끝나 정상 상태로 돌아온다"]', NULL, 'degraded 는 중복이 줄어든 채로 동작하는 상태입니다. 고장 디스크를 빼고 새 디스크를 추가하면 남은 디스크와 패리티로 데이터를 다시 채웁니다(rebuild). 재구성 중에 디스크가 하나 더 고장 나면 RAID 5 는 데이터를 잃습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "리눅스 커널 md 문서", "url": "https://docs.kernel.org/admin-guide/md.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 376 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 621, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🗄️' WHERE id = 376;
