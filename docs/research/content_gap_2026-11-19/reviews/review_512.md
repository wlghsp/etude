# 세트 512 점검 (읽기 전용)

차단: 없음. 정답 정확성·복수 정답·K8s 사실(accessModes 불변, WaitForFirstConsumer, local-path 의 RWO 한정, FailedBinding 문구, allowVolumeExpansion, pvc-protection, Retain 시 Released/claimRef, 용량 ≥ 요청 바인딩) 모두 이상 없음. 현장 정보 없음.

## 권고
- 512:5 — 힌트 순서 모호. "PVC 를 지우고 ... Pod 가 이미 있다면 ..." 은 Pod 가 PVC 를 잡고 있어 PVC 삭제가 Terminating 에서 멈출 수 있음(9번에서 배운 내용). 수정안(hint): "accessModes 는 생성 후 바꿀 수 없으니, 쓰는 Pod 를 먼저 지우고 → PVC 를 지우고 → 같은 이름으로 PVC 를 다시 만든 뒤 → Pod 를 다시 만듭니다. Pod 가 Running 이 될 때까지 기다리세요." (단계 전체를 알려 주는 편이라 더 줄이려면 앞 두 절만 남겨도 됨)
- 512:8 — 힌트가 정답 패치 JSON 을 통째로 알려 줌(description 도 형식을 안내). 수정안(hint): "`kubectl patch pvc` 에 `-p` 로 `spec.resources.requests.storage` 만 담은 JSON 을 주고, 오류 출력은 `2>` 로 파일에 저장합니다."
- 512:3 — 힌트가 세 jsonpath 를 모두 알려 줌. 실습 성격상 허용 가능하나, 줄이려면 수정안(hint): "모두 `kubectl get pvc pvc-a -o jsonpath` 로 뽑습니다. PV 이름은 spec 쪽, 용량과 접근 모드는 status 쪽 필드에 있습니다. `-o yaml` 로 먼저 구조를 보세요."
- 512:12 — 순서 고정이 약함. Pod 마운트와 Bound 는 비동기라 "PVC 생성 → Pod 마운트 → 바인딩" 도 현실적으로 가능. 수정안(description): "관리자가 PV 를 미리 만들어 두는 **정적 프로비저닝**에서 볼륨이 쓰이기까지의 순서입니다. Pod 는 PVC 가 `Bound` 가 된 다음에 마운트하는 것으로 봅니다. 카드를 알맞게 놓으세요."
- 512:4 — (참고) 해설 주석의 "local-path 는 ReadWriteOnce 만 지원" 은 정확히는 RWO·RWOP. 채점 문자열("only supports ReadWriteOnce")은 실제 메시지와 일치하므로 그대로 둬도 무방.

## ok
512:1, 512:2, 512:6, 512:7, 512:9, 512:10, 512:11
(5·8·3·12 는 위 권고 반영 시 ok)
