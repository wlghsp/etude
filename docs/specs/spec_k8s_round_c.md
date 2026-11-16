# 명세 — k8s 확장 퀴즈 세트 424·425 (Pod Security Admission, 임시 컨테이너·커스텀 리소스)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-22). [spec_k8s_round_b.md](spec_k8s_round_b.md)에 이어 [spec_k8s_cka_gap_analysis.md](spec_k8s_cka_gap_analysis.md)의 갭 점검에서 얇게 나온 주제를 퀴즈로 보강한다. 424 는 단원 29 `클러스터 운영·보안` 끝, 425 는 단원 9 `운영과 트러블슈팅` 끝에 놓는다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 424 | 29 (304, 🚔) | Pod Security Admission | privileged·baseline·restricted, enforce(거부)·audit(감사 기록)·warn(경고), pod-security.kubernetes.io/<MODE> 레이블·-version, 모드별 다른 레벨, 워크로드 리소스에는 audit·warn 만 적용, 예외 세 차원, 컨트롤러 서비스 계정은 예외 두지 않기, 적용 순서 |
| 425 | 9 (300, 🔭) | 임시 컨테이너와 커스텀 리소스 | 임시 컨테이너 정의, 자동 재시작 없음, ports·probe·resources 불가, 추가 후 변경·제거 불가, ephemeralcontainers 서브리소스(kubectl edit 불가), 기본 admin·edit 에 없는 권한, 정적 Pod 미지원, 커스텀 리소스만으로는 저장·조회, Operator = 커스텀 리소스 + 컨트롤러, 점검 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

kubernetes.io 의 Pod Security Admission, Ephemeral Containers, Custom Resources 페이지. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(52개) 통과, 새 세트의 display_order 중복 없음, 새 세트 아이콘이 k8s 분야에서 유일 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- Pod Security 레벨별 구체 요구사항(Pod Security Standards)과 레이블이 없을 때의 기본 동작은 원문에 없어 뺐다. PodSecurityPolicy 제거 시점(v1.25)은 원문에 "Stable since v1.25"만 있어 묻지 않았다.
- `kubectl debug` 의 사용법(--target, --copy-to, 노드 디버깅)과 `kubectl top`(metrics-server)은 디버깅 문서를 읽을 수 없어 다루지 않았다. 임시 컨테이너 문서에도 --target 은 없다.
- 커스텀 리소스 문서는 뒤 약 19KB 를 읽지 못해 CRD 의 정의·스키마 검증·CRD 와 aggregation 비교는 다루지 않았다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 실습 샌드박스에서 확인하지 않아 퀴즈로만 다룬다.
