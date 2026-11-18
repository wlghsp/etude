# 명세 — k8s 서비스 노출과 볼륨 설정 손연습 세트 (489)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (k8s 40% 목표). 겹치지 않는 주제: Ingress·ExternalName·NodePort, hostAliases, downwardAPI 볼륨, Secret defaultMode, StatefulSet PVC, CronJob concurrencyPolicy.

## 구성 (12문제, 세트 489, sandbox `k8s`, 분야 k8s, 단원 `스토리지와 네트워크`(8) 끝, 🚪)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `create ingress` 규칙 | 호스트·백엔드 web:80 |
| 2 | 터미널 | 경로 `*` → `pathType Prefix` | Prefix, /api |
| 3 | 터미널 | `create service externalname` | 타입·externalName |
| 4 | 터미널 | NodePort 노출, 번호 읽기 | 파일 = 실제 nodePort |
| 5 | 터미널 | `hostAliases` | /etc/hosts 항목 |
| 6 | 터미널 | downwardAPI 볼륨(라벨) | labels 파일 |
| 7 | 터미널 | Secret 볼륨 `defaultMode: 0400` | 권한 400 |
| 8 | 터미널 | StatefulSet `volumeClaimTemplates` | PVC Bound, Pod Running |
| 9 | 터미널 | CronJob `concurrencyPolicy` | Forbid |
| 10 | 객관식 | 경로 끝 `*` 의 의미 | Prefix |
| 11 | 빈칸 | `create service {0}` | externalname |
| 12 | 순서 | Ingress 요청 흐름 | |

- 거짓 통과 방지: 무행동 검사 통과. NodePort 는 고정 번호를 쓰지 않아(공유 클러스터 충돌 방지) 배정 번호를 읽게 했다.
- 알려진 한계: 실제 트래픽(Ingress 컨트롤러 경유)은 확인하지 않는다. TLS·RBAC 는 후속 후보.

## 수용 조건

- [x] 터미널 9문제 `verify:quests` 9/9 (`검증됨`, k3d), 무행동 실패 확인.
- [x] 객관식 DB 확인, `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: k8s 탭에서 보이고 1~12번이 풀린다 (수동 확인).
