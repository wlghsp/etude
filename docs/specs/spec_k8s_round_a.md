# 명세 — k8s 확장 퀴즈 세트 420·421 (Pod 우선순위, 토폴로지 분산 제약)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-20). 근거: [spec_k8s_cka_gap_analysis.md](spec_k8s_cka_gap_analysis.md)의 갭 점검에서 얇게 나온 주제(우선순위·선점, topologySpread)를 퀴즈로 보강한다. 단원 7 `워크로드와 설정` 끝에 세트를 더한다(뒤 세트 20개의 display_order 는 밀렸다). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 420 | 7 (278, 🎖️) | Pod 우선순위와 선점 | PriorityClass 클러스터 범위, value 32비트·10억 이하, system- 접두사 금지, globalDefault 하나·기존 Pod 불변, 기본 우선순위 0, preemptionPolicy 기본 PreemptLowerPriority·Never, 없는 클래스는 거부, priorityClassName·Never 빈칸, 적용 순서 |
| 421 | 7 (279, 🪜) | 토폴로지 분산 제약 | maxSkew 와 전역 최소값(예시 2·2·1), topologyKey, whenUnsatisfiable 기본 DoNotSchedule·ScheduleAnyway, minDomains(DoNotSchedule 전용, 도메인 부족 시 최소값 0), matchLabelKeys, 같은 조합 제약 하나, 필드 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

kubernetes.io 의 Pod Priority and Preemption, Pod Topology Spread Constraints 페이지. 위 내용은 원문에서 직접 확인했다(앞 약 100KB 범위).

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(48개) 통과, 새 세트의 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 두 문서의 뒤쪽(약 20~25KB)은 읽지 못했다. 선점의 세부 동작(축출·graceful termination·PDB 처리·nominatedNodeName), 우선순위와 노드 압박 축출의 관계, 클러스터 레벨 기본 분산 제약, 재조정 여부, affinity 와의 비교는 확인하지 못해 뺐다. 시스템 클래스(system-cluster-critical 등)의 값은 버전에 따라 달라 묻지 않았다.
- k8s 분야의 아이콘은 기존에 1/2·2/2 세트끼리 같은 아이콘을 쓰는 경우가 많다. 이번 두 세트는 기존 아이콘과 겹치지 않게 골랐다(421 은 ⚖️ 가 351 과 겹쳐 🪜 로 바꿨다).
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 실습 샌드박스에서 스케줄링 동작을 확인하지 않아 퀴즈로만 다룬다.
