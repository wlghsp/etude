# k8s 분야 콘텐츠 빈틈 분석

분석 기준: `merged.json`(k8s 단원 12개, 세트 약 113개)와 DB(`quest_set`, `quest`)를 읽기 전용으로 확인. 터미널 실습 환경은 `sandbox_type=k8s`(k3d 로컬 단일 노드 k3s, 공유 kubeconfig)이다. 퀴즈는 `quiz`(컨테이너 없음).
수치는 DB 쿼리 결과(검증됨), 해석은 코드·문제 제목 기반(코드상 확인됨), 환경 제약 판단은 `추정`으로 표시한다.

## 요약

- 현재 수준: 워크로드·kubectl 조작·YAML·트러블슈팅(Pod 단위)은 세트 수와 깊이 모두 풍부하다(공개 가능 수준 이상). 반면 CKA/CKAD 의 **보안·클러스터 운영·스토리지·네트워킹 심화** 는 대부분 개념 퀴즈에만 있고 터미널 실습이 거의 없다.
- 전체 세트의 약 절반이 `(1/2)·(2/2)` 쌍으로 된 "한 줄씩" 퀴즈(약 60개)이고, 터미널 세트는 약 40개. 기초~중급 kubectl 은 과잉, 영역별 균형은 나쁘다.
- 가장 큰 빈틈 3개:
  1. **RBAC 실습 전무**: Role·RoleBinding·ClusterRole 터미널 실습이 0개(세트 119 퀴즈 10문제뿐). `--as` 로 권한 시험하는 문제도 없음.
  2. **PV(정적)·StorageClass·스냅샷 실습 얕음**: PVC 만 만들어 보는 세트 13 이 전부. PV hostPath/Retain·Reclaim, 접근 모드 동작, 데이터 보존 실습 없음.
  3. **노드 유지보수(cordon/drain/taint)·kubectl top·HPA 부하 실습 없음, 상황집이 Pod/Service 중심**: 노드 NotReady·DNS·권한 오류·PVC Pending·Ingress 502 계열 상황집이 없음.
- 그 외: Ingress 컨트롤러·TLS, Gateway API 는 개념/YAML 읽기 수준. Helm 은 세트 2개(14, 383)로 기본은 되지만 values 파일·의존성·hook 은 없음.

## 참고 커리큘럼

학습자는 사내 인프라 운영자이므로 CKA 중심, CKAD 의 앱 개발 영역은 운영에 유용한 범위만 포함. 활용도 낮은 것(CSI 드라이버 개발, 커스텀 스케줄러, 감사 로그 정책 상세 등)은 제외.

| # | 영역 | 핵심 주제 |
|---|------|-----------|
| D1 | 클러스터 아키텍처 | 컨트롤 플레인 구성요소, kubelet·런타임, kube-proxy, 선언형 모델, API 그룹·버전, 네임스페이스 |
| D2 | kubectl·YAML 기본기 | get/describe/logs/exec, dry-run, apply/diff/patch/edit, 출력 형식(jsonpath, custom-columns), explain, 컨텍스트 |
| D3 | 워크로드 | Pod, Deployment·ReplicaSet, 롤아웃·롤백, StatefulSet, DaemonSet, Job·CronJob, 멀티 컨테이너·init |
| D4 | 설정 | ConfigMap, Secret, env/envFrom/볼륨 주입, 갱신 반영, immutable |
| D5 | 프로브·수명주기·리소스 | liveness/readiness/startup, restartPolicy, preStop·graceful, requests/limits, QoS, LimitRange, ResourceQuota |
| D6 | 스케줄링 | nodeSelector, affinity/anti-affinity, taint/toleration, topology spread, PriorityClass·선점, Pending 원인 |
| D7 | 서비스·DNS | ClusterIP/NodePort/LoadBalancer, Endpoints·EndpointSlice, Headless, ExternalName, CoreDNS·FQDN |
| D8 | Ingress·Gateway | Ingress 규칙·pathType·TLS, 컨트롤러, 502/404 진단, Gateway API 개념 |
| D9 | 네트워크 정책·CNI | NetworkPolicy(ingress/egress), 기본 거부, CNI 역할, kube-proxy 모드 |
| D10 | 스토리지 | emptyDir, hostPath, PV/PVC 바인딩, 접근 모드, reclaimPolicy, StorageClass·동적 프로비저닝, 확장, 스냅샷 개념, StatefulSet PVC |
| D11 | 보안·RBAC | Role/ClusterRole/Binding, ServiceAccount·토큰, `can-i`·`--as`, securityContext, Pod Security Admission, Secret 보안, 이미지 풀 시크릿 |
| D12 | 오토스케일·모니터링 | metrics-server·`kubectl top`, HPA, 리소스 부족 신호, 이벤트·로그 |
| D13 | 트러블슈팅(앱) | ImagePull/CrashLoop/OOM/Pending/Service 불통/probe 실패 진단 |
| D14 | 트러블슈팅(클러스터·노드) | NotReady, kubelet·런타임 로그, 컨트롤 플레인 정적 Pod, DNS 장애, 인증서 만료, 디스크·메모리 압박 |
| D15 | 클러스터 유지보수 | cordon/drain/uncordon, PDB, kubeadm 업그레이드 순서, etcd 백업·복원, 인증서 갱신, 노드 추가·제거 |
| D16 | 패키징 | Helm(repo, install, values, upgrade, rollback, template, 차트 작성), Kustomize(base/overlay, patches, generators) |
| D17 | 확장 개념 | CRD·Operator, 임시 컨테이너(`kubectl debug`), finalizer, API 확장 |

## 커버리지 표

범례: 깊이 = 없음/얕음/보통/충분. 형식 = Q(개념 퀴즈만) / T(터미널 실습 포함). 세트 id 는 DB 기준.

| 영역 | 주제 | 다루는 세트 id | 깊이 | 형식 |
|------|------|---------------|------|------|
| D1 | 컨트롤 플레인·kubelet·kube-proxy·선언형 | 78 | 보통 | Q |
| D1 | CRD·Operator | 78(개념), 425 | 얕음 | Q |
| D1 | 네임스페이스 | 20, 132, 289, 205·308 | 충분 | T+Q |
| D2 | get/describe/logs/exec/기본 흐름 | 6, 20, 19, 128·287, 182·302 | 충분 | T+Q |
| D2 | dry-run, apply, diff, patch, edit | 342, 46, 19, 174·300, 484, 492, 211·310 | 충분 | T+Q |
| D2 | jsonpath, custom-columns, sort-by | 224, 19, 500, 190·304 | 충분 | T+Q |
| D2 | explain, api-resources, 컨텍스트 | 19, 190·304, 492 | 보통 | T+Q |
| D3 | Pod·멀티 컨테이너·init | 6, 375, 130·288, 198·306 | 충분 | T+Q |
| D3 | Deployment 롤아웃·롤백 | 6, 20, 230, 345, 496, 217·312, 194·305 | 충분 | T+Q |
| D3 | StatefulSet | 26(1문제), 163·297, 497, 489(PVC) | 보통 | 대부분 Q |
| D3 | DaemonSet | 22(1문제), 499(OnDelete), 79(개념) | 얕음 | 일부 T |
| D3 | Job·CronJob | 22, 233, 493, 178·301, 163·297 | 충분 | T+Q |
| D4 | ConfigMap·Secret | 12, 236, 33, 132·289, 208·309, 487 | 충분 | T+Q |
| D5 | requests/limits·QoS·LimitRange·Quota | 22, 351, 170·299, 153·295 | 충분 | T+Q |
| D5 | 프로브(liveness/readiness/startup) | 22, 339, 493, 214·311, 487 | 보통 | T+Q |
| D5 | restartPolicy·종료 코드·graceful | 220·313, 26(preStop), 483 | 보통 | T+Q |
| D6 | nodeSelector·affinity·toleration·topology·priority | 22, 26, 223·314, 420, 421, 178·301, 494 | 보통 | T는 26 위주(퀴즈 다수) |
| D6 | taint 를 직접 붙이기·cordon·drain | 26(toleration만), 79, 121(cordon 1문제) | 얕음 | Q (T 없음) |
| D7 | Service 종류·Endpoints·Headless·DNS | 25, 37, 348, 227, 186·303, 422, 108, 136·291 | 충분 | T+Q |
| D7 | CoreDNS 점검·DNS 장애 | 37(resolv.conf), 422, 157·296 | 얕음 | Q |
| D8 | Ingress 규칙·pathType | 25, 489, 79 | 얕음 | T 약간 |
| D8 | Ingress TLS·컨트롤러·Gateway API | 79(개념만) | 없음~얕음 | Q |
| D9 | NetworkPolicy | 166·298, 481, 25 | 보통 | T 약간 |
| D9 | CNI·kube-proxy 모드 | 80, 78 | 얕음 | Q |
| D10 | emptyDir·PVC 사용 | 13, 33, 208·309, 351 | 보통 | T |
| D10 | PV(정적)·reclaimPolicy·hostPath | 122(개념), 136·291 | 얕음 | Q (T 없음) |
| D10 | StorageClass·동적 프로비저닝·확장 | 122, 33(기본 SC) | 얕음 | 대부분 Q |
| D10 | 볼륨 스냅샷·백업 | 없음 | 없음 | - |
| D11 | RBAC | 119(10문제), 487·481·499(ServiceAccount 일부) | 얕음 | Q (T 없음) |
| D11 | securityContext·capabilities | 153·295, 481 | 보통 | T 약간 |
| D11 | Pod Security Admission | 424 | 얕음 | Q |
| D11 | 이미지 풀 시크릿 | 153·295, 487, 499 | 보통 | T 약간 |
| D12 | HPA | 22(기본), 494(v2 메모리), 147·293 | 보통 | T |
| D12 | metrics-server·`kubectl top`·부하 | 없음(퀴즈 언급 정도) | 없음 | - |
| D13 | 앱 장애 진단 | 23, 339, 227, 33, 107, 31 | 충분 | T |
| D14 | 노드·컨트롤 플레인 장애 | 121 | 얕음 | Q |
| D14 | 인증서 만료·kubeconfig | 120(한 문제) | 얕음 | Q |
| D15 | cordon/drain·PDB | 26(PDB), 79, 121, 178·301 | 얕음 | Q (drain 실습 없음) |
| D15 | etcd 백업·복원·kubeadm 업그레이드 | 120 | 보통(개념) | Q |
| D16 | Helm | 14, 383, 147·293 | 보통 | T |
| D16 | Kustomize | 202·307, 482 | 보통 | T+Q |
| D17 | 임시 컨테이너·`kubectl debug` | 425, 182·302 | 얕음 | Q |
| D17 | finalizer | 423, 194·305, 492 | 보통 | Q+T 약간 |

세트 형식 집계(검증됨): 터미널 단독 세트(`k8s` sandbox) 약 40개, 개념 퀴즈(`quiz` sandbox) 약 73개. 신규성 높은 `4xx` 퀴즈 세트(420~425)는 모두 12문제 퀴즈이며 터미널 연계가 없다.

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

1. **RBAC 실습** (D11): `kubectl create role/rolebinding/clusterrole`, `auth can-i --as=system:serviceaccount:...`, Forbidden 재현 후 수정. 근거: DB 에서 터미널 문제 중 RoleBinding/ClusterRole/`--as` 사용 0건. 세트 119 는 퀴즈 10문제뿐. CKA 에서 매 시험 출제되는 영역.
2. **PV·StorageClass 실습** (D10): 정적 PV(hostPath)↔PVC 바인딩, `reclaimPolicy`(Retain/Delete), `accessModes`, `storageClassName` 불일치로 Pending, PVC 확장. 근거: 터미널은 세트 13(PVC만), 33(기본 SC 고치기)뿐이고 PV 가 등장하지 않음(`PersistentVolume` 검색은 13·33·492 의 부수 언급). 122 는 퀴즈.
3. **노드 유지보수 실습** (D15·D6): `cordon`/`uncordon`/`drain`, taint 직접 붙이기·`NoSchedule`·`NoExecute`, drain 이 막히는 상황(PDB·DaemonSet·emptyDir). 근거: 터미널 쿼리에서 cordon 0건, drain 은 세트 26 의 PDB 문제 1건에 부수 언급. 환경 제약: 공유 k3d 클러스터에서 노드 조작은 다른 세션에 영향(추정) → `k8s-isolated`(vcluster) 로 제공하거나 가상 노드 환경이 필요. 불가하면 상황 읽기형 퀴즈+명령 해석형으로 대체.
4. **Pod 외 상황집: 클러스터·네트워크 장애** (D14, D7, D8): NotReady·DNS 해석 실패·Ingress 502/404·권한 Forbidden·PVC Pending 원인 파악. 근거: 상황집 세트 23·227·339 는 Pod/Service 층까지. 121 은 퀴즈.

### 권장

5. **Ingress 실습 보강** (D8): 컨트롤러(k3s 기본 traefik 가능 여부는 `추정`) 위에서 host/path 라우팅, pathType 차이, TLS 시크릿, 존재하지 않는 backend 진단. 근거: 터미널 언급은 25·489 의 일부 문제뿐이고 TLS 는 어디에도 없음.
6. **`kubectl top`·metrics-server·HPA 부하 시험** (D12): top pod/node, requests 없으면 HPA 안 도는 이유, 부하 발생 후 스케일 아웃 관찰. 근거: 문제 검색에서 `kubectl top` 0건. HPA 는 22·494 에서 선언만.
7. **NetworkPolicy 심화 실습** (D9): egress, namespaceSelector, ipBlock, DNS egress 허용 누락. 근거: 166·298 퀴즈 2쌍, 터미널은 481 의 일부 문제만.
8. **Pod Security Admission 실습** (D11): 네임스페이스 라벨 `pod-security.kubernetes.io/enforce` 적용 후 privileged Pod 거부 확인. 근거: 424 퀴즈 1개뿐.
9. **DaemonSet 독립 실습** (D3): 노드마다 1개, 노드 셀렉터, 롤링 업데이트. 근거: 22 의 1문제와 499 의 OnDelete 정도.
10. **CoreDNS·DNS 디버깅 실습** (D7·D14): `nslookup`, resolv.conf search, CoreDNS ConfigMap·로그 확인, 잘못된 서비스 이름. 근거: DNS 는 퀴즈(422)와 37 의 일부.
11. **`kubectl debug`·임시 컨테이너 실습** (D17): 셸 없는 이미지에 붙어서 디버깅, 노드 디버깅. 근거: `kubectl debug` 터미널 문제 0건(425 는 퀴즈).
12. **Helm 심화** (D16): values 파일 병합 우선순위, `helm diff`/`--dry-run`, 의존성, 실패한 upgrade 복구. 근거: 14(8문제), 383, 147·293 퀴즈. 차트 작성은 383 에서 다룸.
13. **kubeconfig·컨텍스트·인증서 읽기** (D14): `kubectl config` 로 context/user/cluster 구조 읽기, 인증서 만료일 읽기(`openssl x509`). 근거: config 는 190·304 퀴즈에서 일부, 인증서는 120 한 문제.

### 선택

14. **Gateway API** (D8): 개념 퀴즈 1세트(HTTPRoute, GatewayClass 관계). 근거: 79 에 이름만 등장.
15. **볼륨 스냅샷·백업 개념** (D10): 퀴즈 1세트. 근거: 없음. 사내 CMP 환경에서 활용도는 중간(`추정`).
16. **CKA 모의시험형 복습 세트** (복습): 시간 제한·다영역 혼합 터미널 문제. 근거: 29 는 14문제 객관식 종합뿐.
17. **API 확장 실습**(CRD 직접 만들기): 425 개념 위에 `kubectl get crd`, 커스텀 리소스 만들기 정도.
18. **Static Pod·kubelet 설정 읽기** (D14): 120 에서 한 문제, 121 에서 일부. 퀴즈 또는 읽기 전용 터미널.

## 신규 세트 백로그

단원 id 는 merged.json 의 `unit_id`(6=기초, 60~65=kubectl 실습 기초~스케줄링과 워크로드 실습, 7, 8, 9, 29=클러스터 운영·보안, 11=Helm)이다. 예상 문제 수는 세트당 9~12(터미널 9 + 보조 3 형식 혼합, 기존 관행 따름).

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---------|------|------|-------------|------|-------------------|-------------|
| 필수 | RBAC 손연습 (1/2): Role·RoleBinding 만들고 권한 시험하기 | 터미널 실습 | 단원 29 클러스터 운영·보안 (119 뒤) | 119, 481(ServiceAccount) | ① `create role --verb --resource` ② `create rolebinding --user/--serviceaccount` ③ `auth can-i`(-n) ④ `--as` 로 대신 해 보기 ⑤ Forbidden 읽고 고치기 | 12 |
| 필수 | RBAC 손연습 (2/2): ClusterRole·ServiceAccount·다른 네임스페이스 | 터미널 실습 | 단원 29 | RBAC (1/2) | ① ClusterRole+RoleBinding vs ClusterRoleBinding ② ServiceAccount 토큰으로 API 호출 ③ 최소 권한 점검(`can-i --list`) ④ aggregate 는 제외 | 11 |
| 필수 | RBAC 상황집: 권한 오류 고치기 | 상황집 | 단원 29 또는 9 | RBAC 손연습 | ① `forbidden: User cannot list` ② 네임스페이스 틀림 ③ ServiceAccount 이름 오타 ④ verb 누락 ⑤ ClusterRole 을 RoleBinding 으로 묶기 | 8 |
| 필수 | PV·StorageClass 손연습: 정적 바인딩, 접근 모드, 보존 정책 | 터미널 실습 | 단원 8 스토리지와 네트워크 (122 뒤) | 13, 122 | ① hostPath PV 만들기 ② PVC 가 PV 에 바인딩되는 조건(용량·accessModes) ③ `reclaimPolicy`(Retain/Delete) 와 삭제 후 상태 ④ `storageClassName` 불일치 Pending ⑤ PVC 확장 | 12 |
| 필수 | 스토리지 상황집: PVC Pending·마운트 실패 | 상황집 | 단원 9 운영과 트러블슈팅 | PV 손연습 | ① no persistent volumes available ② accessMode 불일치 ③ 없는 StorageClass ④ Pod 가 PVC 를 못 찾음 ⑤ 삭제가 Terminating 에 걸림(pvc-protection) | 8 |
| 필수 | 노드 유지보수 손연습: cordon·drain·taint | 터미널 실습 (`k8s-isolated` 또는 노드 조작 가능한 환경) | 단원 65 스케줄링과 워크로드 실습 또는 29 | 26, 79, 178 | ① `cordon` 후 새 Pod 가 안 올라감 ② `drain` 옵션(`--ignore-daemonsets`, `--delete-emptydir-data`) ③ PDB 때문에 drain 이 멈춤 ④ taint NoSchedule/NoExecute 직접 붙이고 떼기 ⑤ `uncordon` | 10 |
| 필수 | 클러스터·노드 상황집: 노드 NotReady 와 DNS·Ingress 불통 | 상황집 (읽기+터미널 혼합) | 단원 9 | 121, 227, 25 | ① NotReady 의 describe node Conditions ② kubelet 로그 읽기 ③ CoreDNS 장애로 이름 해석 실패 ④ Ingress 404/502 구분 ⑤ 인증서 만료 오류 | 10 |
| 권장 | Ingress 손연습: 규칙·pathType·TLS | 터미널 실습 | 단원 8 | 25, 489 | ① host/path 라우팅 ② pathType Prefix vs Exact ③ backend 없는 서비스 진단 ④ TLS Secret 만들기 ⑤ 기본 백엔드 | 9 |
| 권장 | metrics-server 와 HPA 손연습: top 으로 보고 스케일 아웃하기 | 터미널 실습 | 단원 65 | 351, 22 | ① `top pod/node` ② requests 없으면 HPA `<unknown>` ③ HPA 생성·조건 읽기 ④ 부하 후 스케일 아웃/인 관찰 | 9 |
| 권장 | NetworkPolicy 심화 손연습: egress·네임스페이스·DNS 허용 | 터미널 실습 | 단원 61 Pod 수명주기·보안·네트워크 정책 (481 뒤) | 166, 298, 481 | ① egress 기본 거부 ② namespaceSelector ③ DNS(53) 허용 누락 증상 ④ ipBlock ⑤ 정책 겹침 | 9 |
| 권장 | Pod Security Admission 손연습: 네임스페이스 레벨 적용 | 터미널 실습 | 단원 29 | 424, 481 | ① enforce 라벨 ② privileged Pod 거부 메시지 ③ restricted 에 맞게 securityContext 고치기 ④ warn/audit | 8 |
| 권장 | DaemonSet 손연습: 노드마다 하나씩 | 터미널 실습 | 단원 65 | 22, 499 | ① 만들기·노드 수와 비교 ② nodeSelector 로 일부 노드만 ③ updateStrategy ④ taint 노드 허용(toleration) | 8 |
| 권장 | DNS 점검 손연습: 이름이 안 풀릴 때 | 터미널 실습/상황집 | 단원 8 | 37, 422 | ① `nslookup` 임시 Pod ② search 목록·ndots ③ CoreDNS ConfigMap·로그 ④ 서비스 이름 오타 | 9 |
| 권장 | kubectl debug 와 임시 컨테이너 손연습 | 터미널 실습 | 단원 9 | 425, 182 | ① `debug -it --image` ② `--target` 프로세스 공유 ③ Pod 복사본으로 디버깅(`--copy-to`) ④ 노드 디버깅 | 8 |
| 권장 | Helm 심화: values 병합·dry-run·실패 복구 | 터미널 실습 | 단원 11 Helm (14 뒤) | 14, 383 | ① `-f` 와 `--set` 우선순위 ② `--dry-run --debug` ③ `helm get values/manifest` ④ upgrade 실패 후 rollback ⑤ 의존성(dependency) | 9 |
| 권장 | kubeconfig·인증서 읽기 | 터미널 실습(읽기 전용) | 단원 29 | 120 | ① config 구조(cluster·user·context) ② `config view --minify` ③ 인증서 만료일 읽기 ④ context 바꿔 쓰기 | 8 |
| 선택 | Gateway API 개념 | 개념 퀴즈 | 단원 8 | 25, 489 | GatewayClass·Gateway·HTTPRoute 관계, Ingress 와 차이 | 10 |
| 선택 | 볼륨 스냅샷·백업 개념 | 개념 퀴즈 | 단원 8 | PV 손연습 | VolumeSnapshot, 복원, StatefulSet 백업 관점 | 10 |
| 선택 | 쿠버네티스 종합 복습 (CKA 형식) | 복습 | 단원 9 뒤 | 단원 6~9, 29 | 혼합 터미널·퀴즈, 영역별 4~5문제 | 20 |
| 선택 | CRD 손연습 | 터미널 실습 | 단원 29 | 425 | CRD 정의→커스텀 리소스 생성→조회 | 8 |

총 20개 제안(필수 7, 권장 9, 선택 4 중 선택 항목은 18번 Static Pod 를 제외하면 위 4개). 소규모로 먼저 갈 경우 필수 7개 + 권장 중 Ingress·HPA·NetworkPolicy 만 우선 제작 권장.

## 형식 균형

- 현재 비율(검증됨): 터미널 약 40세트, 퀴즈 약 73세트. 이 중 퀴즈 약 60개가 "한 줄씩 (1/2)(2/2)" 쌍이며 kubectl·YAML·워크로드에 집중돼 있다. D1~D5 영역은 터미널과 퀴즈 균형이 괜찮다.
- 영역별 불균형:
  - **보안·RBAC(D11)**: 퀴즈만(119, 424). 권고: 터미널 70% 이상.
  - **스토리지(D10)**: 터미널은 PVC 기초(13)뿐, 개념은 퀴즈(122). 권고: 터미널 60%.
  - **클러스터 유지보수·노드 장애(D14·D15)**: 퀴즈만(120, 121). 환경상 etcd·kubeadm 은 실습이 불가능(k3d, 공유 클러스터)해 **퀴즈·명령 해석형 유지**가 맞다. 대신 cordon·drain·taint 는 격리 환경에서 실습 가능하도록 권고(추정: vcluster 에서 노드 조작은 제한적일 수 있음, 확인 필요).
  - **Ingress·NetworkPolicy·DNS(D7~D9)**: 터미널이 일부 문제 안에 흩어져 있고 독립 세트가 없음. 권고: 터미널 50~60%.
  - **스케줄링(D6)**: 420·421(퀴즈) 은 터미널 연계 없음. 권고: 해당 개념을 26 이나 새 노드 유지보수 세트에서 손연습으로 보완.
- 전체 권고: 한 분야 터미널 비중 50% 이상(현재 약 35%). 신규 세트는 터미널/상황집 위주로 제작하고, 기존 "한 줄씩" 퀴즈는 더 늘리지 않는다.
- 참고(추정): 세트 41·46·128·287·130·288 등 기초 퀴즈 6개 세트에 용어 중복이 있다(`merged.json` issues). 신규 제작보다 정리 우선.

## 상황집

현재 상황집 성격 세트(검증됨): 23(12문제, Pod 장애 고치기), 33(쉬운 장애 고치기), 107(Pod 상태 한마디씩, 퀴즈), 227(Service 연결 안 될 때), 339(깨진 Pod 진단), 31(터미널 결과 읽고 고르기), 230(롤아웃 복구). 오류 메시지→원인→해결 흐름이 **Pod·Deployment·Service 층** 까지는 잘 갖춰져 있다.

부족한 시나리오(필수는 위 백로그에 포함):
1. **권한**: `Error from server (Forbidden): pods is forbidden: User ... cannot list resource` — 원인(Role 누락·네임스페이스 틀림·SA 틀림)과 `can-i` 로 확인.
2. **스토리지**: PVC 가 Pending(`no persistent volumes available`, SC 없음, accessMode 불일치), 볼륨 마운트 실패, Terminating 에 걸린 PVC.
3. **네트워크·DNS**: `no such host`/`could not resolve`, 서비스 이름 오타, CoreDNS 장애, NetworkPolicy 가 DNS 를 막아 이름 해석 실패, Ingress 404(규칙 틀림)/502(backend 포트 틀림).
4. **노드·클러스터**: NotReady, DiskPressure 로 Pod 축출, drain 이 멈춤(PDB), `x509: certificate has expired`, `connection refused`. 일부(121)는 퀴즈로 이미 있으므로 읽기+명령 해석형으로 보강.
5. **리소스**: ResourceQuota 초과로 생성 거부(`exceeded quota`), LimitRange 위반, HPA 가 `<unknown>`(requests 없음).
6. **보안**: Pod Security 위반으로 생성 거부, imagePullSecrets 누락으로 비공개 이미지 `ErrImagePull`(153 에 개념은 있음), securityContext 로 인한 CrashLoop(readOnlyRootFilesystem).
7. **배포 실패**: 롤아웃이 `ProgressDeadlineExceeded` 로 멈춤(230 에 이미지 오류 위주, 리소스·프로브 원인은 부족), Job `BackoffLimitExceeded`.

이 중 1~3 은 위 필수/권장 세트에 포함했고, 5~7 은 기존 상황집(23·339·230)을 확장하는 새 세트(`k8s 상황집 2: 리소스·보안·배포 실패`, 9문제, 선택~권장)로 묶어 제작하는 것을 권한다.
