import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 512 PV·StorageClass 손연습. 명세: docs/specs/spec_gap_set512.md
# k8s 샌드박스의 학습자는 자기 네임스페이스 안에서만 일한다. PV(클러스터 범위)·StorageClass 는 만들거나 읽을 수 없고 hostPath 파드도 막혀 있어서,
# PV 를 직접 만드는 실습은 하지 않는다. 대신 PVC 쪽에서 보이는 상태 변화(Pending → Bound, 이벤트, 거부 메시지, Terminating)를 손으로 확인한다.

CLEAN = ("rm -rf /tmp/*.txt /tmp/lab; kubectl delete pod --all -n $NS --grace-period=1 --wait=true --timeout=90s >/dev/null 2>&1; "
         "kubectl delete pvc --all -n $NS --wait=true --timeout=90s >/dev/null 2>&1")


def PVC(name, mode='ReadWriteOnce', sc=None):
    s = f'  storageClassName: {sc}\n' if sc is not None else ''
    return (f"kubectl apply -n $NS -f - <<EOF\napiVersion: v1\nkind: PersistentVolumeClaim\nmetadata:\n  name: {name}\nspec:\n  accessModes:\n  - {mode}\n{s}  resources:\n    requests:\n      storage: 1Gi\nEOF")


def POD(name, claim):
    return (f"kubectl apply -n $NS -f - <<EOF\napiVersion: v1\nkind: Pod\nmetadata:\n  name: {name}\nspec:\n  containers:\n  - name: nginx\n    image: nginx\n    volumeMounts:\n    - name: vol\n      mountPath: /data\n"
            f"  volumes:\n  - name: vol\n    persistentVolumeClaim:\n      claimName: {claim}\nEOF")


def WAIT(name): return f"kubectl wait --for=condition=ready pod/{name} -n $NS --timeout=90s"


# 이벤트(ProvisioningFailed)가 생길 때까지 최대 40초 기다린다
WAIT_FAIL = "for i in $(seq 1 40); do kubectl describe pvc data -n $NS | grep -q ProvisioningFailed && break; sleep 1; done"

BOUND_POD = CLEAN + "\n" + PVC('pvc-a') + "\n" + POD('app', 'pvc-a') + "\n" + WAIT('app')
RWX_STATE = CLEAN + "\n" + PVC('data', 'ReadWriteMany') + "\n" + POD('web', 'data') + "\n" + WAIT_FAIL

b = SetBuilder(512, 'PV·StorageClass 손연습: 정적 바인딩, 접근 모드, 보존 정책',
               'PVC 가 Pending 에서 Bound 가 되는 순간, 이벤트에 적힌 실패 이유, 접근 모드(ReadWriteMany) 불일치, 없는 StorageClass, storageClassName 을 빈 문자열로 둔 정적 바인딩 대기, 용량 확장 거부, 사용 중인 PVC 삭제 보호(Terminating)를 직접 확인합니다. 정적 PV(hostPath)를 만드는 YAML, 바인딩 조건, Retain 정책 뒤의 Released 상태, 정적 바인딩 순서는 문제로 익힙니다.',
               'k8s', 'k8s', 8, 733, '💽',
               [{"title": "Kubernetes 퍼시스턴트 볼륨", "url": "https://kubernetes.io/docs/concepts/storage/persistent-volumes/"}, {"title": "스토리지 클래스", "url": "https://kubernetes.io/docs/concepts/storage/storage-classes/"}], 5)

# 1 -------------------------------------------------------------
b.nt('PVC 를 만들면 왜 Pending 일까', 'PVC(저장 공간 요청서)를 만들었는데 바로 `Bound`(연결됨)가 되지 않는 경우가 많습니다. 이 클러스터의 기본 StorageClass 는 **Pod 가 PVC 를 쓰려고 나타날 때까지 볼륨 만들기를 미루기** 때문입니다(`WaitForFirstConsumer`).\n\n`$NS` 네임스페이스에 PVC 를 만드세요.\n- 이름: `pvc-a`\n- 용량: `1Gi`\n- 접근 모드: `ReadWriteOnce` (한 노드에서 읽고 쓰기)\n\n그리고 만든 직후 **PVC 의 상태(phase)** 를 `/tmp/phase.txt` 에 저장하세요. (값만)',
     'PVC 는 `kubectl apply -f -` 로 만듭니다. 상태는 `kubectl get pvc 이름 -o jsonpath=\'{.status.phase}\'` 로 값만 뽑을 수 있습니다.',
     PVC('pvc-a') + "\nsleep 2\nkubectl get pvc pvc-a -n $NS -o jsonpath='{.status.phase}' > /tmp/phase.txt\ncat /tmp/phase.txt\n\n# 사용하는 Pod 가 없어서 Pending. Pod 가 생기면 그때 볼륨이 만들어지고 Bound 가 된다",
     CLEAN,
     [chk('pvc-a 가 있다', 'kubectl get pvc pvc-a -n $NS >/dev/null 2>&1'),
      chk('용량이 1Gi 이다', '[ "$(kubectl get pvc pvc-a -n $NS -o jsonpath=\'{.spec.resources.requests.storage}\' 2>/dev/null)" = 1Gi ]'),
      chk('저장한 상태가 Pending 이다', '[ "$(cat /tmp/phase.txt)" = Pending ]')])
# 2 -------------------------------------------------------------
b.nt('Pod 가 쓰기 시작하면 Bound', '`pvc-a` 는 아직 쓰는 Pod 가 없어 `Pending` 입니다. `$NS` 네임스페이스에 **`app`** 이라는 Pod(이미지 `nginx`)를 만들어 PVC `pvc-a` 를 `/data` 에 마운트하세요. 그러면 볼륨이 만들어지고 PVC 가 `Bound` 가 됩니다.',
     'Pod 의 `volumes` 에 `persistentVolumeClaim.claimName` 으로 PVC 이름을 쓰고, 컨테이너의 `volumeMounts` 로 경로를 연결합니다. Pod 가 Ready 가 된 뒤 `kubectl get pvc` 로 상태를 확인하세요.',
     POD('app', 'pvc-a') + "\n" + WAIT('app') + "\nkubectl get pvc pvc-a -n $NS\n\n# Pod 가 스케줄되는 순간 볼륨이 만들어지고 PVC 가 Bound 로 바뀐다",
     CLEAN + "\n" + PVC('pvc-a'),
     [chk('app Pod 가 pvc-a 를 쓴다', '[ "$(kubectl get pod app -n $NS -o jsonpath=\'{.spec.volumes[0].persistentVolumeClaim.claimName}\' 2>/dev/null)" = pvc-a ]'),
      chk('PVC 가 Bound 다', '[ "$(kubectl get pvc pvc-a -n $NS -o jsonpath=\'{.status.phase}\' 2>/dev/null)" = Bound ]')])
# 3 -------------------------------------------------------------
b.nt('Bound 된 PVC 에서 PV 정보 읽기', 'PVC 가 `Bound` 가 되면 클러스터가 만든 **PV(실제 저장소)** 가 연결됩니다. `$NS` 의 PVC `pvc-a` 를 쓰는 Pod `app` 이 이미 떠 있습니다. 아래 세 가지를 각각 파일에 저장하세요. (값만)\n- `/tmp/pv.txt` : 연결된 **PV 이름**\n- `/tmp/cap.txt` : PVC 가 받은 **용량** (`status.capacity.storage`)\n- `/tmp/mode.txt` : PVC 의 **접근 모드**',
     '모두 `kubectl get pvc pvc-a -o jsonpath=\'{...}\'` 로 뽑습니다. PV 이름은 `.spec.volumeName`, 용량은 `.status.capacity.storage`, 접근 모드는 `.status.accessModes[0]` 입니다.',
     "kubectl get pvc pvc-a -n $NS -o jsonpath='{.spec.volumeName}' > /tmp/pv.txt\nkubectl get pvc pvc-a -n $NS -o jsonpath='{.status.capacity.storage}' > /tmp/cap.txt\nkubectl get pvc pvc-a -n $NS -o jsonpath='{.status.accessModes[0]}' > /tmp/mode.txt\ncat /tmp/pv.txt /tmp/cap.txt /tmp/mode.txt\n\n# 동적으로 만든 PV 는 pvc-<긴 ID> 같은 이름을 갖는다. PVC 의 volumeName 이 연결된 PV 를 가리킨다",
     BOUND_POD,
     [chk('PV 이름이 PVC 의 volumeName 과 같다', '[ -s /tmp/pv.txt ] && [ "$(cat /tmp/pv.txt)" = "$(kubectl get pvc pvc-a -n $NS -o jsonpath=\'{.spec.volumeName}\' 2>/dev/null)" ]'),
      chk('용량이 1Gi 이다', '[ "$(cat /tmp/cap.txt)" = 1Gi ]'),
      chk('접근 모드가 ReadWriteOnce 이다', '[ "$(cat /tmp/mode.txt)" = ReadWriteOnce ]')])
# 4 -------------------------------------------------------------
b.nt('접근 모드가 안 맞을 때: 실패 이유 읽기', '`$NS` 에 PVC `data`(접근 모드 `ReadWriteMany`, 여러 노드가 동시에 읽고 쓰기)와 이를 쓰는 Pod `web` 이 만들어져 있습니다. 그런데 Pod 는 `Pending` 에서 움직이지 않습니다.\n\nPVC `data` 의 **이벤트에서 볼륨 만들기가 실패했다는 줄**(`ProvisioningFailed`)을 `/tmp/why.txt` 에 저장하세요. 이유가 적혀 있습니다.',
     '`kubectl describe pvc data` 의 맨 아래 `Events` 에 이유가 있습니다. 출력을 `grep` 으로 걸러 `>` 로 저장하세요.',
     "kubectl describe pvc data -n $NS | grep ProvisioningFailed > /tmp/why.txt\ncat /tmp/why.txt\n\n# 이 클러스터의 기본 스토리지(local-path)는 노드 한 곳의 디렉터리라서 ReadWriteOnce 만 지원한다",
     RWX_STATE,
     [chk('파일에 실패 줄이 있다', 'grep -q ProvisioningFailed /tmp/why.txt'),
      chk('지원하는 접근 모드가 적혀 있다', 'grep -q "only supports ReadWriteOnce" /tmp/why.txt')])
# 5 -------------------------------------------------------------
b.nt('접근 모드 고쳐서 Pod 띄우기', '앞 문제와 같은 상태입니다. PVC `data` 는 `ReadWriteMany` 를 요구하는데 이 저장소는 `ReadWriteOnce` 만 지원해서 Pod `web` 이 뜨지 못합니다. PVC `data` 를 **`ReadWriteOnce`(1Gi)** 로 바꿔 Pod `web` 이 `Running` 이 되게 하세요.\n\n(이미 만들어진 PVC 의 접근 모드는 수정할 수 없습니다.)',
     '`accessModes` 는 생성 후 바꿀 수 없으니 PVC 를 지우고 같은 이름으로 다시 만듭니다. Pod 가 이미 있다면 PVC 를 새로 만든 뒤 Pod 가 Running 이 될 때까지 기다리세요. Pod 가 안 움직이면 Pod 도 다시 만드세요.',
     "kubectl delete pod web -n $NS --grace-period=1 --wait=true\nkubectl delete pvc data -n $NS --wait=true\n" + PVC('data') + "\n" + POD('web', 'data') + "\n" + WAIT('web') + "\nkubectl get pvc data -n $NS\n\n# accessModes 는 불변이라 지우고 다시 만든다. 새 PVC 가 RWO 이면 local-path 가 볼륨을 만들 수 있다",
     RWX_STATE,
     [chk('접근 모드가 ReadWriteOnce 이다', '[ "$(kubectl get pvc data -n $NS -o jsonpath=\'{.spec.accessModes[0]}\' 2>/dev/null)" = ReadWriteOnce ]'),
      chk('PVC 가 Bound 다', '[ "$(kubectl get pvc data -n $NS -o jsonpath=\'{.status.phase}\' 2>/dev/null)" = Bound ]'),
      chk('web Pod 가 Running 이다', '[ "$(kubectl get pod web -n $NS -o jsonpath=\'{.status.phase}\' 2>/dev/null)" = Running ]')])
# 6 -------------------------------------------------------------
b.nt('없는 StorageClass 를 요구하면', '`$NS` 에 PVC `pvc-fast` 가 만들어져 있고 계속 `Pending` 입니다. 이 PVC 는 `storageClassName` 으로 특정 StorageClass 를 요구합니다. 아래 두 가지를 파일에 저장하세요.\n- `/tmp/sc.txt` : PVC 가 요구하는 **StorageClass 이름** (값만)\n- `/tmp/why.txt` : 이벤트에서 `ProvisioningFailed` 가 적힌 줄',
     '이름은 `kubectl get pvc pvc-fast -o jsonpath=\'{.spec.storageClassName}\'`, 이유는 `kubectl describe pvc` 의 Events 에서 찾습니다.',
     "kubectl get pvc pvc-fast -n $NS -o jsonpath='{.spec.storageClassName}' > /tmp/sc.txt\nkubectl describe pvc pvc-fast -n $NS | grep ProvisioningFailed > /tmp/why.txt\ncat /tmp/sc.txt /tmp/why.txt\n\n# 요구한 이름의 StorageClass 가 클러스터에 없으면 볼륨을 만들 곳이 없어 영원히 Pending",
     CLEAN + "\n" + PVC('pvc-fast', sc='fast') + "\nsleep 3",
     [chk('요구하는 클래스 이름이 fast 다', '[ "$(cat /tmp/sc.txt)" = fast ]'),
      chk('이유 줄에 not found 가 있다', 'grep -q "not found" /tmp/why.txt')])
# 7 -------------------------------------------------------------
b.nt('storageClassName 을 빈 문자열로: 기존 PV 만 찾기', '`storageClassName: ""`(빈 문자열)로 쓰면 "동적으로 만들지 말고, **미리 만들어 둔 PV 중에서만** 찾아라" 라는 뜻입니다(정적 바인딩). 이 클러스터에는 미리 만든 PV 가 없습니다.\n\n`$NS` 에 PVC `pvc-static`(1Gi, `ReadWriteOnce`, `storageClassName: ""`)을 만들고, 이벤트에 적힌 **바인딩 못 한 이유**를 `/tmp/static.txt` 에 저장하세요.',
     '`storageClassName: ""` 는 따옴표 두 개입니다(줄을 아예 빼면 기본 StorageClass 가 붙습니다). 이벤트는 `kubectl describe pvc` 에서 `FailedBinding` 줄을 찾으세요. 만든 직후엔 이벤트가 늦을 수 있습니다.',
     PVC('pvc-static', sc='""') + "\nfor i in $(seq 1 20); do kubectl describe pvc pvc-static -n $NS | grep -q FailedBinding && break; sleep 1; done\nkubectl describe pvc pvc-static -n $NS | grep FailedBinding > /tmp/static.txt\ncat /tmp/static.txt\n\n# storageClassName 을 빈 문자열로 두면 동적 생성이 꺼진다. 조건에 맞는 PV 가 미리 있어야 Bound",
     CLEAN,
     [chk('storageClassName 이 빈 문자열이다', 'kubectl get pvc pvc-static -n $NS >/dev/null 2>&1 && [ -z "$(kubectl get pvc pvc-static -n $NS -o jsonpath=\'{.spec.storageClassName}\' 2>/dev/null)" ]'),
      chk('Pending 이다', '[ "$(kubectl get pvc pvc-static -n $NS -o jsonpath=\'{.status.phase}\' 2>/dev/null)" = Pending ]'),
      chk('이유가 파일에 있다', 'grep -q "no persistent volumes available" /tmp/static.txt')])
# 8 -------------------------------------------------------------
b.nt('쓰는 중에 용량을 늘려 보기', '`$NS` 의 PVC `pvc-a`(1Gi)는 Pod `app` 이 쓰는 중입니다. 용량을 **2Gi 로 늘려 보세요**. 이 클러스터의 StorageClass 는 확장을 허용하지 않아 거부됩니다. 거부 메시지(표준 에러)를 `/tmp/resize.txt` 에 저장하세요.\n\n(용량은 PVC 의 `spec.resources.requests.storage` 입니다. `kubectl patch pvc 이름 -p \'JSON\'` 으로 바꿀 수 있습니다.)',
     '`kubectl patch` 에 `-p \'{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}\'` 형태로 새 용량을 주고, 오류는 `2>` 로 파일에 저장합니다.',
     "kubectl patch pvc pvc-a -n $NS -p '{\"spec\":{\"resources\":{\"requests\":{\"storage\":\"2Gi\"}}}}' 2> /tmp/resize.txt\ncat /tmp/resize.txt\n\n# 확장하려면 StorageClass 에 allowVolumeExpansion: true 가 있어야 한다. 늘리는 것만 되고 줄이는 것은 안 된다",
     BOUND_POD,
     [chk('거부 메시지가 있다', 'grep -q "must support resize" /tmp/resize.txt'),
      chk('용량은 1Gi 그대로다', '[ "$(kubectl get pvc pvc-a -n $NS -o jsonpath=\'{.spec.resources.requests.storage}\' 2>/dev/null)" = 1Gi ]')])
# 9 -------------------------------------------------------------
b.nt('쓰는 중인 PVC 를 지우면 Terminating', '`$NS` 의 PVC `pvc-a` 를 Pod `app` 이 쓰는 중입니다. 쓰는 중인 PVC 는 바로 지워지지 않고 **보호**됩니다(`pvc-protection`).\n\n1. PVC `pvc-a` 를 지우는 명령을 `--wait=false` 로 실행하고, **바로 이어서** `kubectl get pvc pvc-a` 의 출력을 `/tmp/term.txt` 에 저장하세요. (`Terminating` 이 보여야 합니다)\n2. 그다음 Pod `app` 을 지워 PVC 가 **완전히 사라지게** 하세요.',
     '`kubectl delete pvc ... --wait=false` 는 기다리지 않고 바로 돌아옵니다. 상태 열을 눈여겨보세요. PVC 를 쓰는 Pod 가 없어지면 보호가 풀립니다. Pod 는 `--grace-period=1` 로 빨리 지울 수 있습니다.',
     "kubectl delete pvc pvc-a -n $NS --wait=false\nkubectl get pvc pvc-a -n $NS > /tmp/term.txt\ncat /tmp/term.txt\nkubectl delete pod app -n $NS --grace-period=1 --wait=true\nsleep 3\nkubectl get pvc -n $NS\n\n# 쓰는 Pod 가 있는 동안 PVC 는 Terminating 으로 남고, Pod 가 사라지면 그때 지워진다. 데이터가 든 볼륨을 실수로 잃지 않게 막는 장치",
     BOUND_POD,
     [chk('Terminating 이 기록돼 있다', 'grep -q Terminating /tmp/term.txt'),
      chk('PVC 가 없어졌다', '! kubectl get pvc pvc-a -n $NS >/dev/null 2>&1'),
      chk('Pod 도 없어졌다', '! kubectl get pod app -n $NS >/dev/null 2>&1')])
# 10 ------------------------------------------------------------
b.choice('PVC 가 PV 와 바인딩되는 조건', '관리자가 정적 PV(`storage: 10Gi`, `accessModes: [ReadWriteOnce]`, `storageClassName: manual`)를 만들어 두었습니다. 다음 중 이 PV 에 **바인딩될 수 있는 PVC** 는 어느 것일까요?',
         '세 조건을 모두 봅니다. 용량은 요청 이상이어야 하고, 접근 모드는 PV 가 지원하는 것이어야 하고, 클래스 이름은 같아야 합니다.',
         ['`storage: 5Gi`, `ReadWriteOnce`, `storageClassName: manual`', '`storage: 20Gi`, `ReadWriteOnce`, `storageClassName: manual`', '`storage: 5Gi`, `ReadWriteMany`, `storageClassName: manual`', '`storage: 5Gi`, `ReadWriteOnce`, `storageClassName: fast`'], 0,
         'PV 의 용량이 PVC 요청 이상이고(10Gi ≥ 5Gi), PVC 의 접근 모드를 PV 가 지원하고, `storageClassName` 이 같으면 바인딩됩니다. 20Gi 는 PV 보다 커서, ReadWriteMany 는 PV 가 지원하지 않아서, `fast` 는 클래스 이름이 달라서 바인딩되지 않고 Pending 으로 남습니다. 바인딩되면 5Gi 를 요청했어도 PV 전체(10Gi)가 PVC 하나에 묶입니다.')
# 11 ------------------------------------------------------------
b.fill('정적 PV(hostPath) YAML 채우기', '관리자가 노드의 `/mnt/data` 디렉터리를 쓰는 **정적 PV** 를 만듭니다. PVC 가 `storageClassName: manual` 로 이 PV 를 찾아오게 하고, **PVC 를 지워도 데이터가 남도록** 하려는 YAML 의 세 빈칸을 채우세요. (PV 는 클러스터 범위라 이 실습 환경에서는 만들 수 없고, 읽고 쓰는 연습만 합니다. 운영에서 hostPath 는 개발·단일 노드용입니다.)',
       '노드의 디렉터리를 가리키는 필드 이름, 문제에 적힌 클래스 이름, 데이터를 지우지 않고 남기는 보존 정책 값을 고릅니다.',
       'apiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: pv-manual\nspec:\n  capacity:\n    storage: 10Gi\n  accessModes:\n  - ReadWriteOnce\n  storageClassName: {1}\n  persistentVolumeReclaimPolicy: {2}\n  hostPath:\n    {0}: /mnt/data',
       ['path', 'dir', 'manual', 'local-path', 'Retain', 'Delete'], [0, 2, 4],
       '`hostPath` 아래에는 노드의 경로를 `path` 로 적습니다. PVC 의 `storageClassName` 과 PV 의 `storageClassName` 이 같아야 정적 바인딩이 됩니다. 이 문제에서는 `manual` 입니다. `local-path` 는 이 클러스터의 기본 StorageClass 이름이라 동적 생성 쪽입니다. `Retain` 은 PVC 를 지워도 PV 와 데이터를 남깁니다. 이때 PV 는 `Released` 가 되고, 옛 PVC 의 연결 정보(claimRef)가 남아 있어 관리자가 정리하기 전에는 새 PVC 에 바로 붙지 않습니다. `Delete` 는 PV 와 저장소를 함께 지우며 hostPath 는 지원하지 않습니다.')
# 12 ------------------------------------------------------------
b.order('정적 바인딩의 흐름', '관리자가 PV 를 미리 만들어 두는 **정적 프로비저닝**에서 Pod 가 볼륨을 쓰기까지의 순서입니다. 카드를 알맞게 놓으세요.',
        '저장소를 만드는 사람(관리자)이 먼저, 요청하는 사람(사용자)이 그다음입니다. Pod 는 PVC 를 통해서만 PV 를 씁니다.',
        ['컨트롤러가 용량·접근 모드·클래스가 맞는 PV 와 PVC 를 묶어 Bound 로 만든다', 'Pod 의 volumes 에 claimName 으로 PVC 를 지정해 마운트한다', '사용자가 필요한 용량·접근 모드로 PVC 를 만든다', '관리자가 PV 를 만든다 (Available 상태)'], [3, 2, 0, 1],
        '관리자가 PV(Available)를 만들면, 사용자가 PVC 를 제출합니다. 컨트롤러가 조건에 맞는 PV 를 찾아 서로 묶으면 둘 다 Bound 가 되고, Pod 는 PVC 이름만 알면 마운트할 수 있습니다. 사용자는 PV 의 실제 위치(hostPath 등)를 몰라도 됩니다.')

if __name__ == '__main__':
    preview(b)
