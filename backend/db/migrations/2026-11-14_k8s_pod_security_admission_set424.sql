-- 퀴즈 세트 424. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_k8s_round_c.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 424, 'Pod Security Admission: 세 레벨, enforce·audit·warn, 네임스페이스 레이블, 예외', 'Pod Security admission 을 읽습니다. privileged·baseline·restricted 레벨, enforce(거부)·audit(감사 기록)·warn(경고) 모드, pod-security.kubernetes.io/<MODE> 레이블과 -version, 워크로드 리소스에는 enforce 가 적용되지 않는 점, 예외 세 차원을 봅니다.', 'quiz', 'k8s'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 424);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 1, '보안 레벨', 'Pod Security 의 **세 가지 레벨** 은 무엇일까요?', '가장 느슨한 것부터 엄격한 것까지예요.', NULL, NULL, '[]', 'choice', '["low, medium, high", "open, closed, strict", "privileged, baseline, restricted", "permissive, default, hardened"]', 2, '쿠버네티스 문서는 Pod Security admission 이 privileged, baseline, restricted 세 레벨을 Pod 의 Security Context 와 관련 필드에 적용한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 2, 'enforce 모드', '`enforce` 모드에서 정책을 위반한 Pod 는 어떻게 될까요?', '들어오지 못해요.', NULL, NULL, '[]', 'choice', '["허용되고 경고만 표시된다", "거부된다", "허용되고 감사 로그에만 남는다", "허용되고 자동으로 수정된다"]', 1, '문서는 enforce 모드에서 정책 위반 시 Pod 가 거부된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 3, 'audit 모드', '`audit` 모드에서 정책을 위반한 Pod 는 어떻게 될까요?', '기록만 남겨요.', NULL, NULL, '[]', 'choice', '["허용되고 감사 로그에만 기록된다", "거부된다", "허용되고 사용자에게 경고가 표시된다", "허용되고 Pod 가 즉시 종료된다"]', 0, '문서는 audit 모드에서 정책 위반 시 감사 로그 이벤트에 감사 어노테이션이 추가되고 그 외에는 허용된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 4, 'warn 모드', '`warn` 모드에서 정책을 위반한 Pod 는 어떻게 될까요?', '사용자에게 알려요.', NULL, NULL, '[]', 'choice', '["거부된다", "허용되고 감사 로그에만 남는다", "허용되고 다른 네임스페이스로 옮겨진다", "허용되고 사용자에게 경고가 표시된다"]', 3, '문서는 warn 모드에서 정책 위반 시 사용자에게 경고가 표시되고 그 외에는 허용된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 5, '레이블 형식', '네임스페이스에 적용하는 **레이블 형식** 은 무엇일까요?', '모드와 레벨을 담아요.', NULL, NULL, '[]', 'choice', '["security.kubernetes.io/<LEVEL>: <MODE>", "pod-security.kubernetes.io/level: <MODE>", "pod-security.kubernetes.io/<MODE>: <LEVEL>", "pod.kubernetes.io/security: <LEVEL>"]', 2, '문서는 pod-security.kubernetes.io/<MODE>: <LEVEL> 형식(MODE 는 enforce·audit·warn, LEVEL 은 privileged·baseline·restricted)과 선택적인 <MODE>-version 레이블을 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 6, '모드별 레벨', '한 네임스페이스에서 **모드마다 다른 레벨** 을 지정할 수 있을까요?', '모드를 여러 개 켤 수 있어요.', NULL, NULL, '[]', 'choice', '["불가능하다(레벨은 네임스페이스당 하나)", "가능하다(모드마다 다른 레벨)", "enforce 모드만 레벨을 정할 수 있다", "audit 과 warn 은 항상 같은 레벨이어야 한다"]', 1, '문서는 네임스페이스가 모드를 하나 이상 설정할 수 있고 모드마다 다른 레벨을 지정할 수도 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 7, '워크로드 리소스', 'Deployment 같은 **워크로드 리소스** 에 대한 적용으로 맞는 것은 무엇일까요?', 'enforce 만 달라요.', NULL, NULL, '[]', 'choice', '["audit·warn 만 적용, enforce 는 Pod 에만", "세 모드 모두 워크로드 리소스에 적용된다", "enforce 는 워크로드 리소스에 적용되고 audit·warn 은 Pod 에만 적용된다", "어느 모드도 워크로드 리소스에는 적용되지 않는다"]', 0, '문서는 audit 과 warn 이 워크로드 리소스에도 적용되어 위반을 일찍 발견하게 하지만, enforce 는 워크로드 리소스에는 적용되지 않고 결과로 생성되는 Pod 에만 적용된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 8, '예외 차원', 'Pod Security admission 의 **예외** 로 지정할 수 있는 것은 무엇일까요?', '세 가지예요.', NULL, NULL, '[]', 'choice', '["라벨, 어노테이션, 노드 이름", "Pod 이름, 컨테이너 이미지, 포트", "레플리카 수, 리소스 요청, 우선순위", "사용자 이름, 런타임 클래스 이름, 네임스페이스"]', 3, '문서는 예외를 Usernames, RuntimeClassNames, Namespaces 세 차원으로 명시적으로 나열하며 예외 요청은 enforce·audit·warn 동작이 모두 건너뛰어진다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 9, '컨트롤러 예외', '**컨트롤러 서비스 계정**(예: replicaset-controller)에 대한 문서의 권고는 무엇일까요?', '일반적으로 예외로 두지 않아요.', NULL, NULL, '[]', 'choice', '["항상 예외 처리해야 한다", "enforce 모드에서만 예외 처리한다", "일반적으로 예외 처리하지 않아야 한다", "kube-system 에서만 예외 처리한다"]', 2, '문서는 대부분의 Pod 를 컨트롤러가 만들어 최종 사용자를 예외 처리해도 워크로드 리소스 생성에는 적용되지 않으며, 컨트롤러 서비스 계정은 일반적으로 예외 처리하지 않아야 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 10, '거부 모드', '정책을 위반한 Pod 를 **거부** 하는 모드입니다. 빈칸을 채우세요.', '"강제" 라는 뜻이에요.', NULL, NULL, '[]', 'fill', '["enforce", "audit", "warn", "exempt"]', NULL, 'enforce 모드는 정책 위반 시 Pod 를 거부합니다. audit 은 감사 로그, warn 은 경고입니다.', '[0]', 'pod-security.kubernetes.io/{0}: baseline', NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 11, '버전 레이블', '모드별 **버전** 을 정하는 선택적 레이블의 이름 끝부분입니다. 빈칸을 채우세요.', '"버전" 이에요.', NULL, NULL, '[]', 'fill', '["-version", "-level", "-mode", "-policy"]', NULL, '<MODE>-version 레이블로 Kubernetes 마이너 버전 또는 latest 를 지정할 수 있습니다.', '[0]', 'pod-security.kubernetes.io/enforce{0}: latest', NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 424, 12, '네임스페이스에 적용', 'Pod Security 를 네임스페이스에 적용하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '정하기 → 레이블 → 검사 → 결과예요.', NULL, NULL, '[]', 'order', '["적용할 모드와 레벨을 정한다", "네임스페이스에 `pod-security.kubernetes.io/<MODE>: <LEVEL>` 레이블을 붙인다", "Pod 를 만들면 admission 이 정책을 검사한다", "`enforce` 이면 위반 Pod 가 거부된다"]', NULL, '문서의 레이블 형식과 모드 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "Pod Security Admission", "url": "https://kubernetes.io/docs/concepts/security/pod-security-admission/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 424 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 304 WHERE id = 14;
UPDATE quest_set SET display_order = 303, unit_id = (SELECT id FROM unit WHERE id = 29), icon = '🚔' WHERE id = 424;
