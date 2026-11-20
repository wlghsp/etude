-- linux-systemd 샌드박스를 전용 이미지(etude-linux-systemd: Rocky 9 ubi-init + logrotate·rsyslog)로 바꾼다. 여러 번 실행해도 안전하다.
-- 되돌리기: UPDATE sandbox SET image = 'rockylinux/rockylinux:9-ubi-init' WHERE type = 'linux-systemd';  (546 의 setup 이 dnf 로 설치하므로 옛 이미지에서도 동작하되 외부망이 필요하다)
-- 이미지는 backend/ 에서 `docker build -f docker/Dockerfile.linux-systemd -t etude-linux-systemd:latest .` 로 먼저 빌드해 둬야 한다. 원본: 01_sandbox.sql
UPDATE sandbox SET image = 'etude-linux-systemd',
  description = 'Rocky Linux systemd 환경 (logrotate·rsyslog 포함). 실제 systemctl 명령이 동작하는 서비스 관리 실습용.'
WHERE type = 'linux-systemd' AND image <> 'etude-linux-systemd';
