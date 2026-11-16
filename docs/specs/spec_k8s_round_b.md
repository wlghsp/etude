# 명세 — k8s 확장 퀴즈 세트 422·423 (Service·Pod DNS, finalizer)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-21). [spec_k8s_round_a.md](spec_k8s_round_a.md)에 이어 [spec_k8s_cka_gap_analysis.md](spec_k8s_cka_gap_analysis.md)의 갭 점검에서 얇게 나온 주제를 퀴즈로 보강한다. 422 는 단원 8 `스토리지와 네트워크` 끝, 423 은 단원 9 `운영과 트러블슈팅` 끝에 놓는다(뒤 세트는 각각 12개·4개 display_order 가 밀렸다). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 422 | 8 (290, 📛) | Service 와 Pod 의 DNS | my-svc.my-namespace.svc 형식, search 목록 확장으로 짧은 이름, data.prod 로 다른 네임스페이스, Headless 의 Pod IP 집합, SRV 이름 형식, 172-17-0-3.default.pod 형식, hostname 기본 metadata.name, hostname·subdomain FQDN, Ready 조건, prod·None 빈칸, 짧은 이름 해석 순서 |
| 423 | 9 (299, 🏁) | Finalizer 와 삭제가 멈출 때 | finalizer 는 삭제 전 기다리게 하는 키, deletionTimestamp·Terminating, finalizers 가 남으면 삭제 안 됨, 컨트롤러가 제거, pv-protection, ownerReferences 기반 정리, 삭제 뒤 추가 불가·되살리기 불가, 수동 제거의 위험, 필드 빈칸 2개, 삭제 흐름 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

kubernetes.io 의 DNS for Services and Pods, Finalizers 페이지. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(50개) 통과, 새 세트의 display_order 중복 없음, 새 세트 아이콘이 k8s 분야에서 유일 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- DNS 문서는 뒤 약 9KB 를 읽지 못했다. dnsPolicy 값과 기본값, dnsConfig, ndots 기본값은 확인하지 못해 뺐다(예시에 options ndots:5 가 보이지만 기본값이라는 문장은 없다). 클러스터 도메인은 문서가 cluster-domain.example 로 쓰고 cluster.local 은 예시 값이다.
- finalizer 문서에는 pvc-protection 예시, 삭제 전파 정책(Foreground·Background·Orphan), foregroundDeletion, blockOwnerDeletion 이 없어 뺐다. 사용자 정의 finalizer 이름 규칙은 다루지 않았다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 실습 샌드박스에서 DNS 조회와 삭제 지연을 확인하지 않아 퀴즈로만 다룬다.
