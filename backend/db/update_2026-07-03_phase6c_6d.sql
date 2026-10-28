-- Phase 6c(Rocky Linux systemd sandbox 타입) + Phase 6d(etude-linux 커스텀 이미지) 서버 반영용 UPDATE
-- 대상 DB에서 1회 실행. 원본은 backend/db/01_sandbox.sql, 02_quest_set.sql, 03_quest_set09.sql, 03_quest_set10.sql

-- 1) Phase 6d — linux 타입 이미지를 ubuntu에서 etude-linux(vim, iproute2 사전 설치)로 변경
UPDATE sandbox SET image = 'etude-linux' WHERE type = 'linux';

-- 2) Phase 6c — linux-systemd sandbox 타입 신규 추가
INSERT INTO sandbox (type, image, binds, persistent, description)
SELECT 'linux-systemd', 'rockylinux/rockylinux:9-ubi-init', NULL, FALSE,
       'Rocky Linux systemd 환경. 실제 systemctl 명령이 동작하는 서비스 관리 실습용.'
WHERE NOT EXISTS (SELECT 1 FROM sandbox WHERE type = 'linux-systemd');

-- 3) Phase 6c — 세트 10의 sandbox_type을 linux-systemd로 전환
UPDATE quest_set SET sandbox_type = 'linux-systemd' WHERE id = 10;

-- 4) Phase 6d — 세트 9(Vim 기초) setup_cmd에서 vim-tiny 설치 명령 제거 (etude-linux에 vim 사전 설치됨)
UPDATE quest SET setup_cmd = NULL
WHERE quest_set_id = 9 AND order_index = 1;

UPDATE quest SET setup_cmd = '["sh", "-c", "touch /tmp/test.txt"]'
WHERE quest_set_id = 9 AND order_index = 2;

-- 5) Phase 6c — 세트 10 1,2번 문제를 systemctl 기반으로 원복 (Rocky 기준 cronie/crond)
UPDATE quest SET
  title = 'systemd 서비스 상태 확인하기',
  hint = 'systemctl status <서비스명> 명령어를 사용하세요.',
  solution = 'systemctl status crond > /tmp/svc_status.txt 2>&1',
  setup_cmd = '["sh", "-c", "dnf install -y cronie > /dev/null 2>&1"]',
  grade_cmd = '["sh", "-c", "grep -qi ''crond'' /tmp/svc_status.txt"]'
WHERE quest_set_id = 10 AND order_index = 1;

UPDATE quest SET
  title = 'systemd 서비스 시작하고 활성화하기',
  hint = 'systemctl start 와 systemctl enable 을 사용하세요.',
  solution = 'systemctl start crond && systemctl enable crond',
  setup_cmd = '["sh", "-c", "dnf install -y cronie > /dev/null 2>&1 && systemctl stop crond 2>/dev/null || true"]',
  grade_cmd = '["sh", "-c", "systemctl is-active crond"]'
WHERE quest_set_id = 10 AND order_index = 2;

-- 6) Phase 6c — 세트 10 6번 문제, ss 사용을 위한 iproute + 리스닝 포트 확보용 sshd 설치
UPDATE quest SET
  hint = 'ss -tlnp 를 사용하세요.',
  solution = 'ss -tlnp > /tmp/ports.txt',
  setup_cmd = '["sh", "-c", "dnf install -y iproute openssh-server > /dev/null 2>&1 && systemctl start sshd"]'
WHERE quest_set_id = 10 AND order_index = 6;
