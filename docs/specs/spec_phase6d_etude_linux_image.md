# Phase 6d 명세 — etude-linux 커스텀 이미지 도입

## 목표

`linux` sandbox 타입이 쓰는 기본 이미지를 `ubuntu:22.04`(패키지 미설치)에서 `etude-linux`(vim, iproute2 사전 설치된 커스텀 이미지)로 교체한다. 매 퀘스트 `setup_cmd`에서 `apt-get install`을 반복하는 방식의 문제(설치 시간 지연, 네트워크 의존, 패키지 선택 실수 위험)를 없앤다.

배경: 세트 9(Vim 기초)가 `vim`/`vi` 자체가 설치되지 않은 채 배포되어 있었음. 1차로 `setup_cmd`에 `apt-get install -y vim-tiny`를 추가했으나(`56e01e2`), 실제 실습 중 `vim-tiny`가 insert 모드 등 정상적인 vim 키바인딩을 온전히 지원하지 못하는 문제를 발견 — `vim`(풀버전)으로 교체 검증 완료. 이 과정에서 "매번 컨테이너 안에서 설치하는 방식 자체가 불안정하니 커스텀 이미지로 가자"는 방향으로 전환.

---

## 검증 완료 사항 (로컬 실측)

`backend/docker/Dockerfile.linux`:

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    vim iproute2 \
    && rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]
```

- `docker build -f docker/Dockerfile.linux -t etude-linux .` 빌드 성공
- `expect`로 실제 tty 입력을 흉내내 `vim` insert 모드(`i` → 텍스트 입력 → `ESC` → `:wq`) 전 과정이 정상 동작하고 파일에 올바르게 저장됨을 확인 (`vim-tiny`에서 실패했던 것과 대조적으로 정상)
- `ss`(iproute2) 명령 정상 설치 확인

---

## 범위

**포함**:
- `backend/docker/Dockerfile.linux` 신규 (기존 `Dockerfile.k8s`, `Dockerfile.ssh`와 같은 패턴)
- `sandbox` 테이블의 `linux` 타입 image를 `ubuntu` → `etude-linux`로 변경
- 세트 9(Vim 기초)의 `setup_cmd`에서 `apt-get install vim-tiny` 제거 (이미지에 이미 포함되므로 불필요), 힌트/풀이/setup_cmd를 다시 `vim`으로 되돌림 (`vi`가 아니라)
- Phase 8 배포 가이드(`guide_phase8_deploy.md`)의 Step 5(커스텀 이미지 빌드)에 `etude-linux` 빌드 단계 추가

**제외 (범위 밖)**:
- `linux-ssh`(`etude-ssh`), `linux-systemd`(Phase 6c, Rocky) 등 다른 sandbox 타입에는 영향 없음 — 이 Phase는 순수 `linux` 타입 이미지 교체에 한정.
- 패키지 목록 확장 — 지금은 `vim`, `iproute2` 두 개만. 이후 콘텐츠 확장 시 필요한 패키지가 생기면 그때 추가.

---

## 왜 이미지 사전 설치 방식이 나은가

| | setup_cmd에서 매번 apt-get install | 커스텀 이미지에 사전 설치 |
|---|---|---|
| 매 퀘스트 지연 | 설치 시간만큼 매번 발생 | 없음 (이미지에 이미 포함) |
| 네트워크 의존 | apt 저장소 접근 실패 시 퀘스트 자체가 막힘 | 이미지 빌드 시점에만 필요 |
| 패키지 선택 실수 | 잘못 고르면(예: vim-tiny) 실습 중간에 발견 | 이미지 빌드 시 미리 검증 가능 |
| 일관성 | 세트마다 제각각 설치 여부 다를 수 있음 | 이미지 하나로 통일 |

---

## 검증 기준

- [ ] `etude-linux` 이미지 빌드 성공
- [ ] `linux` sandbox 타입으로 터미널 연결 시 `vim`, `ss` 명령이 별도 설치 없이 바로 동작
- [ ] 세트 9(Vim 기초) 12문제를 처음부터 끝까지 풀어 grade_cmd 모두 통과 확인 (특히 insert 모드 기반 문제들)
- [ ] 세트 1, 2, 3, 7(기타 linux 세트) 회귀 확인 — 이미지 교체로 영향 없는지
- [ ] 서버 배포 시 `etude-linux` 이미지가 정상적으로 빌드/사용되는지 확인
