-- 스토리지 퀴즈 세트 377. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_quiz_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 377, 'LVM 과 Ceph 구조: PV·VG·LV 와 OSD·MON·쿼럼', '디스크를 유연하게 나눠 쓰는 LVM(PV·VG·LV, vgextend, lvextend, pvmove)과 분산 스토리지 Ceph 의 구조(블록·파일·오브젝트, OSD, 모니터와 쿼럼, 복제 3 벌, RGW)를 익힙니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 377);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 1, 'LVM 의 세 층', 'LVM 에서 디스크 → 풀 → 사용 단위의 순서로 알맞은 것은 무엇일까요?', 'PV → VG → LV 예요.', NULL, NULL, '[]', 'choice', '["논리 볼륨(LV) → 볼륨 그룹(VG) → 물리 볼륨(PV)", "볼륨 그룹(VG) → 물리 볼륨(PV) → 논리 볼륨(LV)", "물리 볼륨(PV) → 볼륨 그룹(VG) → 논리 볼륨(LV)", "물리 볼륨(PV) → 논리 볼륨(LV) → 볼륨 그룹(VG)"]', 2, 'lvm(8) 의 명령 구성이 이 순서를 보여 줍니다. `pvcreate` 로 디스크를 PV 로 만들고, `vgcreate` 로 VG 에 모으고, `lvcreate` 로 VG 의 여유 공간에서 LV 를 떼어 냅니다. 파일시스템은 LV 위에 만듭니다.', NULL, NULL, NULL, '[{"title": "lvm(8) 매뉴얼", "url": "https://linux.die.net/man/8/lvm"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 2, '볼륨 그룹이 모자랄 때', 'VG 의 여유 공간이 모자라서 디스크를 새로 추가하려 합니다. PV 를 VG 에 더하는 명령은 무엇일까요?', '확장(extend)이에요.', NULL, NULL, '[]', 'choice', '["vgreduce", "vgextend", "lvextend", "pvmove"]', 1, 'lvm(8) 은 `vgextend` 를 "Add Physical Volumes to a Volume Group" 으로 설명합니다. `vgreduce` 는 반대로 PV 를 빼고, `lvextend` 는 LV 의 크기를 늘립니다.', NULL, NULL, NULL, '[{"title": "lvm(8) 매뉴얼", "url": "https://linux.die.net/man/8/lvm"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 3, 'LV 를 늘린 다음', '`lvextend` 로 LV 를 늘렸습니다. 그 위의 파일시스템에서 늘어난 용량을 쓰려면 무엇이 더 필요할까요?', 'lvextend 의 `-r` 옵션도 이걸 해 줘요.', NULL, NULL, '[]', 'choice', '["파일시스템도 늘려야 한다 (resize2fs, xfs_growfs 또는 lvextend -r)", "아무 작업도 필요 없이 파일시스템이 자동으로 같이 늘어난다", "물리 볼륨(PV)을 모두 지우고 처음부터 다시 만든 뒤 복원한다", "서버를 한 번 재부팅하면 자동으로 크기가 맞춰진다"]', 0, 'LV 크기와 그 안의 파일시스템 크기는 별개입니다. lvextend(8) 의 `-r`(`--resizefs`) 옵션은 LV 를 늘리면서 파일시스템도 함께 늘려 줍니다.', NULL, NULL, NULL, '[{"title": "lvextend(8) 매뉴얼", "url": "https://linux.die.net/man/8/lvextend"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 4, 'pvmove 가 하는 일', '디스크를 교체하기 위해 한 PV 안의 데이터를 다른 PV 로 옮길 때 쓰는 명령은 무엇일까요?', '문서는 "Physical Extents 를 옮긴다"고 해요.', NULL, NULL, '[]', 'choice', '["pvcreate", "vgrename", "lvremove", "pvmove"]', 3, 'lvm(8) 은 `pvmove` 를 "Move Physical Extents" 로 설명합니다. 같은 VG 안에서 데이터를 한 디스크에서 다른 디스크로 옮겨 놓은 뒤 `vgreduce` 로 PV 를 뺄 수 있습니다.', NULL, NULL, NULL, '[{"title": "lvm(8) 매뉴얼", "url": "https://linux.die.net/man/8/lvm"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 5, 'Ceph 의 세 가지 저장', 'Ceph 가 하나의 클러스터로 제공하는 **세 종류의 저장 방식** 은 무엇일까요?', '블록, 파일, 그리고...', NULL, NULL, '[]', 'choice', '["블록 스토리지, 메모리 캐시, 자기 테이프 보관", "파일 공유, 데이터베이스 서버, 메시지 큐", "블록(RBD), 파일(CephFS), 오브젝트(RGW)", "오브젝트 저장, 캐시 서버, 로그 수집기"]', 2, 'Ceph 용어집은 Ceph 블록 스토리지가 지원하는 세 종류(블록·오브젝트·파일) 중 하나라고 설명합니다. RBD 는 블록, CephFS 는 POSIX 파일시스템, RGW 는 S3·Swift 호환 오브젝트입니다. 모두 RADOS 위에 만들어집니다.', NULL, NULL, NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 6, 'OSD 의 역할', 'Ceph 의 **OSD** 는 무엇일까요?', '데이터가 실제로 저장되는 곳이에요.', NULL, NULL, '[]', 'choice', '["클러스터 상태 지도를 유지하고 관리하는 데몬", "디스크에 데이터를 저장하는 Object Storage Daemon", "파일시스템의 메타데이터만 따로 관리하는 서버", "S3 요청을 받아서 처리해 주는 웹 게이트웨이"]', 1, 'Ceph 용어집은 OSD 를 Object Storage Daemon, 논리 디스크와 상호작용하는 Ceph 소프트웨어라고 설명합니다. 지도 보관은 모니터(MON), S3 요청은 RGW, 메타데이터는 MDS 의 몫입니다.', NULL, NULL, NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 7, '모니터가 하는 일', 'Ceph **모니터(MON)** 는 무엇을 유지할까요?', '클러스터의 상태를 적은 지도예요.', NULL, NULL, '[]', 'choice', '["모니터 맵·매니저 맵·OSD 맵·CRUSH 맵 같은 클러스터 상태 지도", "사용자가 올린 객체의 본문 데이터와 복제본 전체", "클라이언트의 로그인 계정과 비밀번호 목록 전체", "S3 버킷에 일어난 접근 기록과 사용량 통계"]', 0, 'Ceph 용어집은 모니터를 클러스터 상태 지도(모니터 맵, 매니저 맵, OSD 맵, CRUSH 맵)를 유지하는 데몬이라고 설명합니다. 데이터 본문은 OSD 가 저장합니다.', NULL, NULL, NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 8, '쿼럼', '모니터가 3 대인 Ceph 클러스터에서 **쿼럼(quorum)** 이 유지되려면 최소 몇 대가 살아 있어야 할까요?', '과반수예요.', NULL, NULL, '[]', 'choice', '["1 대", "3 대 모두", "모니터 수와 상관없이 쿼럼은 필요 없다", "2 대"]', 3, 'Ceph 용어집은 쿼럼을 모니터의 과반수가 살아 있는 상태라고 설명합니다. 3 대 중 과반수는 2 대입니다. 그래서 쿼럼이 가능하려면 모니터가 최소 3 대 필요하다고 합니다.', NULL, NULL, NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 9, '복제 3 벌의 의미', 'Ceph 복제 풀이 데이터를 **3 벌**(size = 3) 저장하고 있을 때, 데이터 손실 없이 동시에 고장 나도 되는 OSD 수는 몇 개일까요?', '문서는 "복제본 수 빼기 1"이라고 해요.', NULL, NULL, '[]', 'choice', '["0 개", "1 개", "2 개", "3 개"]', 2, 'Ceph 풀 문서는 복제 풀에서 데이터 손실 없이 동시에 고장 날 수 있는 OSD 수가 복제본 수보다 하나 적다고 설명합니다. 3 벌이면 2 개입니다. 일반적인 구성은 객체당 복제본 3 개입니다.', NULL, NULL, NULL, '[{"title": "Ceph 풀 운영", "url": "https://docs.ceph.com/en/latest/rados/operations/pools/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 10, 'LVM 의 첫 단계', '디스크를 LVM 에서 쓸 수 있게 **초기화하는 명령** 입니다. 빈칸을 채우세요.', 'PV 를 만드는 명령이에요.', NULL, NULL, '[]', 'fill', '["pvcreate", "vgcreate", "lvcreate", "mkfs"]', NULL, 'lvm(8) 은 `pvcreate` 를 "Initialize a disk or partition for use by LVM" 로 설명합니다. `vgcreate` 는 VG, `lvcreate` 는 LV 를 만듭니다.', '[0]', '{0} /dev/sdb', NULL, '[{"title": "lvm(8) 매뉴얼", "url": "https://linux.die.net/man/8/lvm"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 11, 'RGW 가 지원하는 API', 'Ceph 오브젝트 게이트웨이(RGW)가 제공하는 두 API 입니다. 빈칸을 채우세요.', 'OpenStack 의 오브젝트 스토리지 서비스 이름이에요.', NULL, NULL, '[]', 'fill', '["Swift", "Cinder", "Glance", "Nova"]', NULL, 'Ceph 용어집은 RGW 를 Amazon S3 RESTful API 와 OpenStack Swift API 모두에 대한 게이트웨이라고 설명합니다.', '[0]', 'Amazon S3 와 OpenStack {0}', NULL, '[{"title": "Ceph 용어집", "url": "https://docs.ceph.com/en/latest/glossary/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 377, 12, 'LVM 으로 공간 만들어 쓰기', '새 디스크에서 LVM 으로 공간을 만들어 쓰는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '디스크 초기화 → 풀 → 조각 → 파일시스템 → 마운트 순서예요.', NULL, NULL, '[]', 'order', '["`pvcreate` 로 디스크를 PV 로 만든다", "`vgcreate` 로 VG 를 만든다", "`lvcreate` 로 LV 를 만든다", "LV 에 파일시스템을 만들어 마운트한다"]', NULL, 'PV → VG → LV 순서로 쌓고, 마지막에 LV 위에 파일시스템을 만들어 마운트합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "lvm(8) 매뉴얼", "url": "https://linux.die.net/man/8/lvm"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 377 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 622, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '💽' WHERE id = 377;
