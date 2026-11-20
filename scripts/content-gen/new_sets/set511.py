import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *

# 세트 511: RBAC 손연습 (1/2). docs/specs/spec_gap_set511.md
CLEAN_K = "rm -f /tmp/*.txt; kubectl delete rolebinding,role --all -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete sa app -n $NS --ignore-not-found >/dev/null 2>&1; kubectl delete cm app-config -n $NS --ignore-not-found >/dev/null 2>&1; "
ROLE = "kubectl create role pod-reader --verb=get,list --resource=pods -n $NS >/dev/null; "
BIND = "kubectl create rolebinding read-pods --role=pod-reader --user=jane -n $NS >/dev/null; "
S = lambda extra='': CLEAN_K + extra + "true"
CANI = lambda verb, res, who='jane': f'kubectl auth can-i {verb} {res} -n $NS --as={who}'

b = SetBuilder(511, 'RBAC 손연습 (1/2): Role·RoleBinding 만들고 권한 시험하기',
               'k8s 권한(RBAC)을 직접 만들고 시험해 봅니다. kubectl create role 로 할 수 있는 일의 목록을, create rolebinding 으로 사용자·ServiceAccount 연결을 만들고, auth can-i 와 --as 로 그 사람 입장에서 권한을 확인합니다. Forbidden 오류를 읽고 빠진 verb 를 채우는 일, 권한 회수, can-i --list 까지 가상 클러스터에서 실습합니다.',
               'k8s', 'k8s', 29, 732, '🪪',
               [{"title": "Using RBAC Authorization", "url": "https://kubernetes.io/docs/reference/access-authn-authz/rbac/"}, {"title": "kubectl auth can-i", "url": "https://kubernetes.io/docs/reference/kubectl/generated/kubectl_auth/kubectl_auth_can-i/"}], 1)

b.nt('Role 만들기: Pod 를 읽을 수 있는 목록',
     '**배경** — RBAC 에서 `Role` 은 **한 네임스페이스 안에서 할 수 있는 일의 목록**입니다. 목록은 `verb`(동작: get·list·create·delete 등)와 `resource`(대상: pods·configmaps 등)의 짝으로 적습니다. 아직 누구에게도 연결하지 않았으므로 이것만으로는 아무도 권한이 생기지 않습니다.\n\n**할 일** — 네임스페이스 `$NS` 에 Role `pod-reader` 를 만들어 **Pod 를 `get`, `list`** 할 수 있게 하세요. (`get` 은 하나 조회, `list` 는 목록 조회)',
     '`kubectl create role 이름 --verb=동작들 --resource=대상 -n $NS` 형태입니다. 동작이 여러 개면 쉼표로 잇습니다. `kubectl get role pod-reader -n $NS -o yaml` 로 rules 를 확인할 수 있습니다.',
     "kubectl create role pod-reader --verb=get,list --resource=pods -n $NS\nkubectl get role pod-reader -n $NS -o yaml\n\n# --verb 는 할 수 있는 동작, --resource 는 그 대상. rules 에 apiGroups·resources·verbs 로 들어간다",
     S(), [chk('Role pod-reader 가 있다', 'kubectl get role pod-reader -n $NS >/dev/null 2>&1'),
           chk('대상이 pods 다', 'kubectl get role pod-reader -n $NS -o jsonpath="{.rules[*].resources[*]}" | grep -qw pods'),
           chk('get 과 list 가 있다', 'V=$(kubectl get role pod-reader -n $NS -o jsonpath="{.rules[*].verbs[*]}"); echo $V | grep -qw get && echo $V | grep -qw list')])

b.nt('RoleBinding 만들기: 사용자 jane 에게 연결',
     '**배경** — Role 은 목록일 뿐입니다. 그 목록을 **누구에게** 줄지 잇는 것이 `RoleBinding` 입니다. 사용자는 `--user=이름`, 앱(Pod)이 쓰는 계정은 `--serviceaccount=네임스페이스:이름` 으로 지정합니다. 이 샌드박스에는 사용자 `jane` 이 따로 없어도 됩니다. RBAC 는 **이름 문자열**만 보고 판단합니다.\n\n**할 일** — 이미 만들어진 Role `pod-reader` 를 사용자 `jane` 에게 연결하는 RoleBinding `read-pods` 를 `$NS` 에 만드세요.',
     '`kubectl create rolebinding 이름 --role=Role이름 --user=사용자 -n $NS` 입니다. `kubectl describe rolebinding read-pods -n $NS` 로 Role 과 Subject 를 볼 수 있습니다.',
     "kubectl create rolebinding read-pods --role=pod-reader --user=jane -n $NS\nkubectl describe rolebinding read-pods -n $NS\n\n# --role 은 어떤 목록을, --user 는 누구에게. 이제 jane 은 $NS 안에서 Pod 를 get·list 할 수 있다",
     S(ROLE), [chk('RoleBinding read-pods 가 있다', 'kubectl get rolebinding read-pods -n $NS >/dev/null 2>&1'),
               chk('Role pod-reader 를 가리킨다', '[ "$(kubectl get rolebinding read-pods -n $NS -o jsonpath="{.roleRef.name}")" = pod-reader ]'),
               chk('대상이 사용자 jane 이다', '[ "$(kubectl get rolebinding read-pods -n $NS -o jsonpath="{.subjects[0].kind}/{.subjects[0].name}")" = User/jane ]')])

b.nt('auth can-i 로 권한 확인하기',
     '**배경** — 권한을 줬으면 **정말 되는지** 시험해야 합니다. `kubectl auth can-i 동작 리소스` 는 "내가 이것을 할 수 있나?"에 `yes` 또는 `no` 로만 답합니다. `--as=jane` 을 붙이면 **jane 의 입장에서** 대신 물어봅니다. (관리자 권한이 있어야 대신 물어볼 수 있습니다.) 지금 `jane` 에게는 `pod-reader` 가 연결되어 있습니다.\n\n**할 일** — `$NS` 에서 jane 이 Pod 를 **list** 할 수 있는지의 답을 `/tmp/yes.txt` 에, Pod 를 **delete** 할 수 있는지의 답을 `/tmp/no.txt` 에 저장하세요. (결과 글자만 저장됩니다)',
     '`kubectl auth can-i list pods -n $NS --as=jane` 처럼 씁니다. 답은 표준 출력으로 나오므로 `>` 로 저장합니다. delete 의 답은 `no` 입니다.',
     CANI('list', 'pods') + " > /tmp/yes.txt\n" + CANI('delete', 'pods') + " > /tmp/no.txt\ncat /tmp/yes.txt /tmp/no.txt\n\n# 허용되면 yes, 아니면 no. can-i 는 no 일 때 종료 코드가 1 이라 스크립트에서 조건으로도 쓴다",
     S(ROLE + BIND), [chk('list 답이 yes 다', '[ "$(cat /tmp/yes.txt)" = yes ]'), chk('delete 답이 no 다', '[ "$(cat /tmp/no.txt)" = no ]')])

b.nt('--as 로 jane 처럼 직접 읽어 보기',
     '**배경** — `--as=사용자` 는 `can-i` 뿐 아니라 **모든 kubectl 명령**에 붙여, 그 사람이 명령을 실행한 것처럼 만들 수 있습니다. 권한 문제를 재현할 때 계정을 바꿔 로그인하지 않아도 되어 편합니다. 지금 `$NS` 에는 ConfigMap `app-config` 가 있고, jane 은 ConfigMap 을 get·list 할 수 있는 Role `cm-reader` 를 받았습니다.\n\n**할 일** — **jane 의 입장으로** ConfigMap `app-config` 의 `data.mode` 값을 읽어 `/tmp/mode.txt` 에 저장하세요.',
     '`kubectl get configmap app-config -n $NS --as=jane -o jsonpath=...` 형태입니다. 값은 `{.data.mode}` 로 읽습니다. 권한이 있어 오류 없이 나와야 합니다.',
     "kubectl get configmap app-config -n $NS --as=jane -o jsonpath='{.data.mode}' > /tmp/mode.txt\ncat /tmp/mode.txt\n\n# --as 로 jane 의 입장에서 실행했고, cm-reader 가 get 을 허용하므로 값이 나온다",
     S("kubectl create configmap app-config --from-literal=mode=blue -n $NS >/dev/null; kubectl create role cm-reader --verb=get,list --resource=configmaps -n $NS >/dev/null; kubectl create rolebinding read-cm --role=cm-reader --user=jane -n $NS >/dev/null; "),
     [chk('파일에 값이 있다', '[ "$(cat /tmp/mode.txt)" = blue ]'), chk('jane 은 ConfigMap 을 읽을 수 있다', CANI('get', 'configmaps') + ' | grep -qx yes')])

b.choice('Forbidden 오류 읽기', '`kubectl get secrets -n dev --as=jane` 를 실행했더니 다음 오류가 나왔습니다.\n\n`Error from server (Forbidden): secrets is forbidden: User "jane" cannot list resource "secrets" in API group "" in the namespace "dev"`\n\n이 메시지에서 **빠진 권한**을 가장 정확히 읽은 것은 무엇일까요?',
         '메시지는 "누가(User) · 무엇을(resource) · 어떤 동작(cannot list) · 어디서(namespace)" 순서로 알려 줍니다.',
         ['jane 에게 네임스페이스 dev 의 secrets 를 list 하는 권한이 없다', 'Secret 이 dev 네임스페이스에 존재하지 않는다', 'kubectl 이 API 서버에 접속하지 못했다', 'jane 이라는 사용자가 클러스터에 가입되어 있지 않다'], 0,
         'Forbidden 은 **인증은 됐지만 권한이 없다**는 뜻입니다. 메시지가 사용자(jane), 동작(list), 리소스(secrets), 네임스페이스(dev)를 모두 알려 주므로 그 조합을 허용하는 Role 과 RoleBinding 을 만들면 됩니다. 없는 Secret 은 NotFound, 접속 실패는 connection refused, 없는 사용자 이름도 RBAC 는 이름 문자열로만 판단하므로 모두 다른 상황입니다.')

b.nt('Forbidden 고치기: 빠진 verb 채우기',
     '**배경** — jane 이 `kubectl get pods --as=jane` 은 되는데, 같은 계정으로 `kubectl get pods`(목록)를 하면 `cannot list resource "pods"` 로 거부됩니다. Role `pod-reader` 에는 **`get` 만** 있고 `list` 가 빠져 있기 때문입니다. 단건 조회(get)와 목록 조회(list)는 **별개의 동작**입니다.\n\n**할 일** — Role `pod-reader` 에 `list` 를 **추가**해, jane 이 `$NS` 에서 Pod 를 get 과 list **둘 다** 할 수 있게 고치세요. (기존 get 은 유지)',
     '`kubectl edit role pod-reader -n $NS` 로 verbs 에 list 를 더하거나, 같은 이름으로 다시 만들어도 됩니다. 고친 뒤 `kubectl auth can-i list pods -n $NS --as=jane` 로 확인하세요.',
     "kubectl delete role pod-reader -n $NS\nkubectl create role pod-reader --verb=get,list --resource=pods -n $NS\nkubectl auth can-i list pods -n $NS --as=jane\n\n# RoleBinding 은 Role 을 이름으로 가리키므로 Role 을 다시 만들어도 연결은 그대로다. 실무에서는 kubectl edit 나 apply 로 verbs 를 고친다",
     S("kubectl create role pod-reader --verb=get --resource=pods -n $NS >/dev/null; " + BIND), [chk('jane 이 list 할 수 있다', CANI('list', 'pods') + ' | grep -qx yes'), chk('jane 이 get 도 할 수 있다', CANI('get', 'pods') + ' | grep -qx yes'), chk('연결(RoleBinding)이 그대로 있다', 'kubectl get rolebinding read-pods -n $NS >/dev/null 2>&1')])

b.nt('ServiceAccount 에 권한 연결하기',
     '**배경** — Pod 안의 앱은 사람이 아니라 **ServiceAccount** 로 API 에 접근합니다. 이 계정을 RoleBinding 에 연결할 때는 `--user` 가 아니라 `--serviceaccount=네임스페이스:이름` 으로 적습니다. `--as` 로 시험할 때는 `system:serviceaccount:네임스페이스:이름` 이라는 이름을 씁니다.\n\n**할 일** — 이미 있는 ServiceAccount `app` 과 Role `pod-reader` 를 이어 주는 RoleBinding `app-read` 를 `$NS` 에 만드세요. 그러면 `app` 이 Pod 를 list 할 수 있습니다.',
     '`kubectl create rolebinding app-read --role=pod-reader --serviceaccount=$NS:app -n $NS` 입니다. 확인은 `--as=system:serviceaccount:$NS:app`.',
     "kubectl create rolebinding app-read --role=pod-reader --serviceaccount=$NS:app -n $NS\nkubectl auth can-i list pods -n $NS --as=system:serviceaccount:$NS:app\n\n# ServiceAccount 는 네임스페이스에 속하므로 '네임스페이스:이름' 으로 쓴다. 시험할 때의 이름은 system:serviceaccount:네임스페이스:이름",
     S("kubectl create sa app -n $NS >/dev/null; " + ROLE), [chk('RoleBinding app-read 가 있다', 'kubectl get rolebinding app-read -n $NS >/dev/null 2>&1'),
                                                          chk('대상이 ServiceAccount app 이다', '[ "$(kubectl get rolebinding app-read -n $NS -o jsonpath="{.subjects[0].kind}/{.subjects[0].name}")" = ServiceAccount/app ]'),
                                                          chk('app 이 list 할 수 있다', CANI('list', 'pods', 'system:serviceaccount:$NS:app') + ' | grep -qx yes')])

b.nt('다른 리소스 그룹: Deployment 읽기 Role',
     '**배경** — Pod·ConfigMap 처럼 기본(core) 그룹이 아닌 리소스는 **API 그룹**이 붙습니다. Deployment 는 `apps` 그룹이라 `--resource=deployments.apps` 처럼 `리소스.그룹` 으로 적습니다. 그룹을 빼먹으면 core 그룹에서 찾다가 실패합니다.\n\n**할 일** — `$NS` 에 Role `deploy-viewer` 를 만들어 **Deployment 를 get, list** 할 수 있게 하고, 사용자 `jane` 에게 RoleBinding `view-deploy` 로 연결하세요.',
     '`kubectl create role deploy-viewer --verb=get,list --resource=deployments.apps -n $NS` 후 `create rolebinding` 으로 연결합니다. `can-i list deployments.apps --as=jane` 으로 확인하세요.',
     "kubectl create role deploy-viewer --verb=get,list --resource=deployments.apps -n $NS\nkubectl create rolebinding view-deploy --role=deploy-viewer --user=jane -n $NS\nkubectl auth can-i list deployments.apps -n $NS --as=jane\n\n# deployments 는 apps 그룹이라 '리소스.그룹' 으로 쓴다. 대부분의 워크로드(Deployment·StatefulSet·DaemonSet)가 apps 그룹",
     S(), [chk('jane 이 Deployment 를 list 할 수 있다', CANI('list', 'deployments.apps') + ' | grep -qx yes'),
           chk('jane 이 Deployment 를 delete 할 수 없다', CANI('delete', 'deployments.apps') + ' | grep -qx no'),
           chk('Role 이 apps 그룹을 가리킨다', 'kubectl get role deploy-viewer -n $NS -o jsonpath="{.rules[*].apiGroups[*]}" | grep -qw apps')])

b.nt('can-i --list 로 가진 권한 한눈에 보기',
     '**배경** — 하나씩 묻지 않고 **그 사람이 가진 권한 전체**를 보려면 `kubectl auth can-i --list` 를 씁니다. 리소스별로 허용된 동작(Verbs)이 표로 나옵니다. 최소 권한을 점검할 때 "생각보다 많이 열려 있지 않은가?"를 확인하는 데 씁니다. (기본으로 누구나 갖는 일부 권한도 같이 나옵니다)\n\n**할 일** — `$NS` 에서 jane 의 권한 목록을 `/tmp/list.txt` 에 저장하세요.',
     '`kubectl auth can-i --list -n $NS --as=jane > /tmp/list.txt` 입니다. 표에서 `pods` 줄을 찾아 보세요.',
     "kubectl auth can-i --list -n $NS --as=jane > /tmp/list.txt\ncat /tmp/list.txt\n\n# 표의 Resources 에 pods, Verbs 에 [get list] 가 보이면 pod-reader 가 적용된 것",
     S(ROLE + BIND), [chk('파일이 있다', '[ -s /tmp/list.txt ]'), chk('pods 줄에 get 과 list 가 있다', 'grep -E "^pods " /tmp/list.txt | grep -q "get" && grep -E "^pods " /tmp/list.txt | grep -q "list"')])

b.nt('권한 회수: RoleBinding 지우기',
     '**배경** — 권한을 거두려면 **연결(RoleBinding)을 지웁니다.** Role 은 그대로 두어도 연결이 없으면 아무도 쓰지 못하고, 다른 사용자에게 다시 연결하는 데 재사용할 수 있습니다. 지금 jane 은 `read-pods` 로 Pod 를 읽을 수 있습니다.\n\n**할 일** — jane 이 더 이상 `$NS` 에서 Pod 를 list 하지 못하게 하세요. 단, **Role `pod-reader` 는 남겨 둡니다.**',
     '지울 대상은 Role 이 아니라 연결입니다. `kubectl delete rolebinding 이름 -n $NS` 후 `can-i list pods --as=jane` 이 no 인지 확인하세요.',
     "kubectl delete rolebinding read-pods -n $NS\nkubectl auth can-i list pods -n $NS --as=jane\n\n# 연결만 지우면 권한이 사라지고 Role 은 남는다. 권한 회수는 RoleBinding 삭제",
     S(ROLE + BIND), [chk('jane 이 list 할 수 없다', CANI('list', 'pods') + ' | grep -qx no'), chk('Role pod-reader 는 남아 있다', 'kubectl get role pod-reader -n $NS >/dev/null 2>&1')])

b.fill('can-i 로 대신 물어보기', '`dev` 네임스페이스에서 사용자 `jane` 이 Deployment 를 **delete** 할 수 있는지 **jane 의 입장에서** 확인하는 명령입니다. 빈칸을 채우세요.', '다른 사용자의 입장에서 명령을 실행하게 하는 옵션입니다. 사람 이름과 함께 씁니다.',
       'kubectl auth can-i delete deployments -n dev {0}=jane', ['--as', '--user', '--token', '--impersonate'], [0],
       '`--as=사용자` 는 그 사용자의 입장에서 요청을 보냅니다(impersonation). `--user` 는 kubeconfig 의 자격 증명 이름을 고르는 옵션이라 권한 시험과 다르고, `--token` 은 토큰을 직접 주는 옵션입니다. `--impersonate` 는 kubectl 옵션이 아닙니다.')

b.order('권한을 주고 시험하는 순서', '새 사용자 `jane` 이 `dev` 네임스페이스의 Pod 를 읽게 하려 합니다. 카드를 알맞은 순서로 놓으세요.', '먼저 할 수 있는 일의 목록을 만들고, 그것을 누구에게 줄지 잇고, 정말 되는지 시험하는 흐름입니다.',
        ['can-i --as=jane 으로 시험한다', 'RoleBinding 으로 jane 에게 연결한다', 'Forbidden 이 나오면 verb·resource·namespace 를 점검해 고친다', 'Role 로 할 수 있는 일(get·list pods)을 만든다'], [3, 1, 0, 2],
        'Role(무엇을) → RoleBinding(누구에게) → can-i --as(시험) 순서입니다. 시험에서 no 나 Forbidden 이 나오면 verb·resource·네임스페이스·Binding 대상 이름을 차례로 점검해 고칩니다.')

if __name__ == '__main__':
    preview(b)
