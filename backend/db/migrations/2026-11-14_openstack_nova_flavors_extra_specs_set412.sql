-- 퀴즈 세트 412. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round7.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 412, 'Nova 플레이버 깊게: 생성 속성, extra specs, 비공개 접근, 수정·resize', '플레이버를 운영 관점에서 읽습니다. 생성 때 정하는 속성, disk 0, 기본 플레이버 제거, extra specs 와 quota 키, private 플레이버의 프로젝트 할당, description 만 수정 가능한 점, resize 가 cold migration 인 점을 봅니다.', 'quiz', 'OpenStack'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 412);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 1, '플레이버가 정하는 것', '플레이버에서 **생성 때 지정하는 속성** 으로 맞는 묶음은 무엇일까요?', '이름·ID 와 자원 크기예요.', NULL, NULL, '[]', 'choice', '["이름, 키페어, 보안 그룹, 네트워크, 이미지", "이름, 가용 영역, 호스트 집합, 서버 그룹, 볼륨", "이름, ID, RAM, 루트 디스크, vCPU 수", "이름, 프로젝트, 도메인, 역할, 토큰"]', 2, 'Nova 문서는 플레이버 생성 때 이름, ID, RAM, 루트 디스크, vCPU 수를 지정하며 목록에는 ephemeral 과 swap 도 함께 보인다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 2, 'disk 0', '플레이버를 `--disk 0` 으로 만들면 문서는 무엇이라고 설명할까요?', '디스크 공간이 없다는 쪽이에요.', NULL, NULL, '[]', 'choice', '["디스크를 무제한으로 쓰는 플레이버", "디스크 공간이 없는 플레이버", "디스크 크기를 이미지가 정하는 플레이버", "디스크 생성에 실패한 플레이버"]', 1, '문서는 --disk 0 으로 만든 m1.extra_tiny 예를 들며 이를 디스크 공간이 없다는 뜻(no disk space)으로 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 3, '기본 플레이버', '문서에서 **기본 플레이버**(m1.tiny ~ m1.xlarge)는 어떻게 되었다고 할까요?', 'Newton 에서 달라졌어요.', NULL, NULL, '[]', 'choice', '["Newton 에서 기본 제공이 제거되었다", "Newton 에서 처음 기본 제공되었다", "모든 버전에서 항상 기본 제공된다", "Mitaka 이후에만 기본 제공된다"]', 0, '문서는 기본 플레이버 제공이 Newton 에서 제거되었고, 문서의 기본 플레이버 표는 Mitaka 이전 버전에 해당한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 4, 'extra specs', '플레이버의 **extra specs** 는 무엇일까요?', '기동 때 영향을 줘요.', NULL, NULL, '[]', 'choice', '["플레이버의 가격을 적어 두는 청구용 항목이다", "이미지에만 붙일 수 있는 메타데이터이다", "플레이버 이름의 별칭을 모아 둔 목록이다", "기동 때 인스턴스에 영향을 주는 속성"]', 3, '문서는 extra specs 가 기존 플레이버에 설정·해제할 수 있는 속성이며 인스턴스 기동 시 인스턴스에 직접 영향을 줄 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 5, 'quota 키', '`quota:vif_outbound_peak=65536` 같은 extra spec 의 효과는 무엇일까요?', '네트워크 대역폭이에요.', NULL, NULL, '[]', 'choice', '["인스턴스의 디스크 용량을 늘린다", "인스턴스의 CPU 를 고정한다", "아웃바운드 피크 대역폭을 제한한다", "볼륨 개수를 제한한다"]', 2, '문서는 quota:vif_outbound_peak=65536 을 아웃바운드 피크 대역폭을 512 Mbps 이하로 제한하는 예로 듭니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 6, '비공개 플레이버', '**private** 플레이버를 특정 프로젝트가 쓰게 하려면 어떻게 할까요?', '프로젝트를 지정해요.', NULL, NULL, '[]', 'choice', '["`openstack flavor create --default` 를 쓴다", "`flavor set --project PROJECT_ID` 로 할당한다", "`openstack server set --flavor` 를 쓴다", "프로젝트 이름을 플레이버 이름에 넣는다"]', 1, '문서는 --public 과 --private 로 공개 여부를 정하고 private 플레이버의 프로젝트 접근은 flavor set --project 로 할당한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 7, '플레이버 수정', '만든 플레이버에서 **나중에 수정할 수 있는 필드** 는 무엇일까요?', 'microversion 2.55 부터예요.', NULL, NULL, '[]', 'choice', '["description 필드만 수정할 수 있다", "RAM 과 vCPU 수를 자유롭게 수정할 수 있다", "이름과 ID 만 수정할 수 있다", "아무 필드도 수정할 수 없다"]', 0, '문서는 microversion 2.55 부터 수정 가능한 필드가 description 뿐이라고 하며, 다른 속성은 삭제 후 새로 만들어야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 8, 'extra specs 갱신', '플레이버의 **extra specs 를 갱신** 하면 이미 만든 인스턴스는 어떻게 될까요?', '내장된 플레이버예요.', NULL, NULL, '[]', 'choice', '["실행 중인 인스턴스가 즉시 새 값으로 바뀐다", "모든 인스턴스가 자동으로 재부팅된다", "변경이 거부되어 갱신할 수 없다", "내장된 플레이버는 갱신되지 않는다"]', 3, '문서는 extra specs 를 API 로 갱신할 수 있지만 기존 인스턴스에 내장된 플레이버는 갱신되지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 9, 'resize 의 성격', '기존 인스턴스에 새 플레이버를 적용하려고 쓰는 **resize** 는 어떤 성격일까요?', '이동을 동반해요.', NULL, NULL, '[]', 'choice', '["라이브 마이그레이션이라 테넌트가 알 수 없다", "재부팅 없이 즉시 적용되는 동작이다", "cold migration 이라 투명하지 않다", "관리자만 호출할 수 있는 동작이다"]', 2, '문서는 resize 가 cold migration 이므로 테넌트에게 투명하지 않다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 10, '프로젝트 접근', 'private 플레이버를 **프로젝트에 할당** 할 때 쓰는 옵션입니다. 빈칸을 채우세요.', '"프로젝트" 예요.', NULL, NULL, '[]', 'fill', '["--project", "--domain", "--user", "--group"]', NULL, 'flavor set --project 로 private 플레이버에 프로젝트 접근을 할당합니다.', '[0]', 'openstack flavor set {0} PROJECT_ID m1.private', NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 11, '공개 여부', '모든 프로젝트가 쓰지 못하게 **비공개 플레이버** 로 만드는 옵션입니다. 빈칸을 채우세요.', '공개의 반대예요.', NULL, NULL, '[]', 'fill', '["--private", "--public", "--default", "--hidden"]', NULL, '--public 과 --private 로 공개 여부를 정하며 private 플레이버는 특정 사용자나 그룹을 위한 것입니다.', '[0]', 'openstack flavor create {0} --ram 2048 --disk 20 --vcpus 2 m1.team', NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 412, 12, '비공개 플레이버 준비', '비공개 플레이버를 만들어 쓰게 하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '만들고 → 할당 → 확인이에요.', NULL, NULL, '[]', 'order', '["`flavor create --private` 로 플레이버를 만든다", "`flavor set --project` 로 쓸 프로젝트를 할당한다", "`flavor show` 로 속성과 접근 설정을 확인한다"]', NULL, '문서의 create·set --project 설명을 이은 일반 절차입니다.', '[0, 1, 2]', NULL, NULL, '[{"title": "Nova 플레이버 관리", "url": "https://docs.openstack.org/nova/latest/admin/flavors.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 412 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 708 WHERE id = 357;
UPDATE quest_set SET display_order = 709 WHERE id = 358;
UPDATE quest_set SET display_order = 710 WHERE id = 385;
UPDATE quest_set SET display_order = 711 WHERE id = 359;
UPDATE quest_set SET display_order = 712 WHERE id = 360;
UPDATE quest_set SET display_order = 713 WHERE id = 386;
UPDATE quest_set SET display_order = 714 WHERE id = 388;
UPDATE quest_set SET display_order = 715 WHERE id = 361;
UPDATE quest_set SET display_order = 716 WHERE id = 362;
UPDATE quest_set SET display_order = 717 WHERE id = 387;
UPDATE quest_set SET display_order = 718 WHERE id = 389;
UPDATE quest_set SET display_order = 719 WHERE id = 363;
UPDATE quest_set SET display_order = 720 WHERE id = 364;
UPDATE quest_set SET display_order = 721 WHERE id = 391;
UPDATE quest_set SET display_order = 722 WHERE id = 392;
UPDATE quest_set SET display_order = 707, unit_id = (SELECT id FROM unit WHERE id = 37), icon = '🏷️' WHERE id = 412;
