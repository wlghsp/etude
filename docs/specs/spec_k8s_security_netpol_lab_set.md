# 명세 — k8s Pod 보안과 NetworkPolicy 손연습 세트 (481)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `Pod 수명주기·보안·네트워크 정책`은 실습 0개였다). 짝 퀴즈: 153/295(컨테이너 보안 기본·ServiceAccount), 166/298(NetworkPolicy 기초).

## 구성 (12문제, 세트 481, sandbox `k8s`, 분야 k8s)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `runAsUser`·`runAsNonRoot` | 스펙 + `id -u` = 1000 |
| 2 | 터미널 | `readOnlyRootFilesystem` + `emptyDir` /tmp | `/` 쓰기 실패, `/tmp` 성공 |
| 3 | 터미널 | `capabilities drop ALL`, `allowPrivilegeEscalation: false` | 스펙 |
| 4 | 터미널 | ServiceAccount + `automountServiceAccountToken: false` | 토큰 폴더 없음 |
| 5 | 터미널 | Pod·컨테이너 수준 설정 우선순위 | 3000 |
| 6 | 터미널 | NetworkPolicy 기본 거부 | 접속 차단 (정책 적용 대기 재시도) |
| 7 | 터미널 | 라벨·포트 허용 정책 | client 허용, other 차단 |
| 8 | 터미널 | 잘못된 포트를 `patch` 로 수정 | 80, client 접속 |
| 9 | 터미널 | `jsonpath` 로 보안 설정 읽기 | 2000-3000 |
| 10 | 객관식 | 정책이 없을 때 트래픽 | 모두 허용 |
| 11 | 빈칸 | `runAsNon{0}` (Root) | |
| 12 | 순서 | 접근을 줄여 가는 순서 | |

- 모든 리소스 이름은 고정(`sec-*`, `np-*`, `app-sa`, `deny-all`, `allow-client`)이고 setup 이 이전 흔적을 지운다. NetworkPolicy 적용에는 시간이 걸려 채점이 **2초 간격으로 최대 40초 재시도**한다.
- 거짓 통과 방지: 6·7·8번은 setup 만 한 상태에서 접속 결과가 기대와 달라 채점이 실패한다 (`verify:quests` 의 무행동 검사).
- 검증 환경: k3d `etude`(k3s 내장 NetworkPolicy 컨트롤러가 정책을 집행한다). 근거: 쿠버네티스 공식 문서(보안 컨텍스트, 서비스 어카운트, 네트워크 정책).

## 알려진 한계

egress 정책, `namespaceSelector`·`ipBlock`, Pod Security Admission 라벨, RBAC(Role·RoleBinding), seccomp·AppArmor, `runAsGroup`·`fsGroup` 은 다루지 않았다.

## 배치

k8s 단원 `Pod 수명주기·보안·네트워크 정책`(61) 끝, display_order 240, 아이콘 🛡️.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`, k3d).
- [x] 객관식 정답을 DB 에서 확인한다. `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인, k3d 환경).
