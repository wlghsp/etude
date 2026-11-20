import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 520 Docker 문제 해결 상황집: 볼륨·권한·디스크. 명세: docs/specs/spec_gap_set520.md
# 상황집: 문제마다 "증상/오류 메시지 → 원인 → 고치기" 를 setup 이 만든 상황에서 직접 고친다. 작은 이미지(alpine)만 쓴다.

CLEAN = ("rm -rf /tmp/*.txt /tmp/img /tmp/notes /tmp/note /tmp/out /tmp/emptydir; docker rm -f $(docker ps -aq) >/dev/null 2>&1; "
         "docker volume rm -f $(docker volume ls -q) >/dev/null 2>&1; docker rmi -f webimg app:1 tool:1 >/dev/null 2>&1; true")


def BUILD(tag, body, d='/tmp/img'):
    return f"mkdir -p {d} && printf 'FROM alpine\\n{body}\\n' > {d}/Dockerfile && docker build -q -t {tag} {d} >/dev/null"


b = SetBuilder(520, 'Docker 문제 해결 상황집: 볼륨·권한·디스크',
               '컨테이너를 쓰다 보면 반드시 만나는 저장소 문제를 재현된 상황에서 직접 고칩니다. 마운트 경로 오타로 비어 보이는 디렉터리, Permission denied(uid 불일치), Read-only file system, 바인드 마운트가 이미지 파일을 가리는 현상, 낡은 볼륨이 새 이미지를 가리는 현상, 디스크가 찼을 때 docker system df 로 원인 찾기와 안전하게 정리하기를 다룹니다.',
               'docker', '도커', 26, 741, '🩺',
               [{"title": "Docker 볼륨", "url": "https://docs.docker.com/engine/storage/volumes/"}, {"title": "docker system df", "url": "https://docs.docker.com/reference/cli/docker/system/df/"}], 6)

# 1 -------------------------------------------------------------
b.nt('마운트했는데 디렉터리가 비어 있다', '`/tmp/notes` 폴더에는 `hello.txt` 가 있습니다. 이 폴더를 컨테이너 `app` 의 `/data` 에 붙여 쓰려고 했는데, 컨테이너 안에서 `ls /data` 를 하면 **아무것도 없습니다.** 에러도 나지 않았습니다.\n\n원인을 찾아 고치세요. 컨테이너 `app` 이 **실행 중**이고, 컨테이너 안 `/data/hello.txt` 가 보이게 하면 됩니다. (이미지 `alpine`, 명령 `sleep 3600`)',
     '실행 중인 컨테이너의 마운트 정보는 `docker inspect` 로 볼 수 있습니다. 호스트 쪽 경로를 한 글자씩 실제 폴더와 비교해 보세요. 마운트 설정은 컨테이너를 만들 때만 정할 수 있습니다.',
     "docker inspect -f '{{range .Mounts}}{{.Source}}{{end}}' app\ndocker rm -f app\ndocker run -d --name app -v /tmp/notes:/data alpine sleep 3600\ndocker exec app cat /data/hello.txt\n\n# -v 의 호스트 경로가 없으면 도커가 빈 폴더를 새로 만들어 붙인다(오류 없음). 오타가 있어도 조용히 빈 폴더가 보인다",
     CLEAN + "; mkdir -p /tmp/notes && echo hello > /tmp/notes/hello.txt; docker run -d --name app -v /tmp/note:/data alpine sleep 3600 >/dev/null 2>&1; true",
     [chk('app 이 실행 중이다', '[ "$(docker inspect -f \'{{.State.Running}}\' app 2>/dev/null)" = true ]'),
      chk('컨테이너 안에서 hello.txt 가 보인다', '[ "$(docker exec app cat /data/hello.txt 2>/dev/null)" = hello ]')])
# 2 -------------------------------------------------------------
b.nt('Permission denied: 호스트 폴더의 주인이 다르다', '컨테이너를 일반 사용자(uid 1000)로 실행해 호스트 폴더 `/tmp/out` 에 파일을 쓰려는데 실패합니다. 폴더 `/tmp/out` 은 호스트의 root 소유입니다.\n\n1. 아래 명령을 실행해 나오는 **오류 메시지**를 `/tmp/perm.txt` 에 저장하세요.\n`docker run --rm --user 1000:1000 -v /tmp/out:/out alpine sh -c \'echo ok > /out/result.txt\'`\n2. 원인을 고쳐 **같은 명령이 성공**하게 하세요. 끝나면 `/tmp/out/result.txt` 가 있고, 그 파일의 주인은 uid `1000` 이어야 합니다.',
     '`--user` 는 컨테이너 안 프로세스의 uid 를 정합니다. 바인드 마운트한 폴더의 권한은 호스트에서 `ls -ln` 으로 숫자 uid 까지 확인하세요. 두 uid 가 어긋난 쪽을 맞추면 됩니다. 오류는 표준 오류(`2>`)로 저장합니다.',
     "CMD='echo ok > /out/result.txt'\ndocker run --rm --user 1000:1000 -v /tmp/out:/out alpine sh -c \"$CMD\" 2> /tmp/perm.txt\ncat /tmp/perm.txt\nls -ln /tmp\nchown 1000:1000 /tmp/out\ndocker run --rm --user 1000:1000 -v /tmp/out:/out alpine sh -c \"$CMD\"\nls -ln /tmp/out\n\n# 바인드 마운트는 호스트의 권한 그대로 보인다. 컨테이너 프로세스의 uid 와 폴더 주인(uid)·권한이 맞아야 쓸 수 있다",
     CLEAN + "; mkdir -p /tmp/out; chown 0:0 /tmp/out; chmod 755 /tmp/out",
     [chk('오류 메시지가 저장돼 있다', 'grep -q "Permission denied" /tmp/perm.txt'),
      chk('result.txt 에 ok 가 있다', '[ "$(cat /tmp/out/result.txt 2>/dev/null)" = ok ]'),
      chk('파일 주인이 uid 1000 이다', '[ "$(stat -c %u /tmp/out/result.txt 2>/dev/null)" = 1000 ]')])
# 3 -------------------------------------------------------------
b.nt('Read-only file system: 읽기 전용 컨테이너', '보안을 위해 컨테이너를 `--read-only` 로 실행했더니 `app` 이 시작하자마자 종료됩니다. 이 컨테이너는 시작할 때 `/tmp/state` 에 `started` 를 써야 합니다.\n\n1. 종료된 `app` 의 **로그**를 `/tmp/err.txt` 에 저장하세요.\n2. `app` 을 지우고 다시 실행하세요. 조건은 **읽기 전용은 유지**하되 쓰기가 필요한 `/tmp` 만 쓸 수 있게 하는 것입니다. (이미지 `alpine`, 같은 명령은 `sh -c \'echo started > /tmp/state && sleep 3600\'`)',
     '`docker logs` 의 출력에 원인이 적혀 있습니다. `--read-only` 를 빼는 것은 답이 아닙니다. 읽기 전용 루트 파일시스템에서 일부 경로만 쓰기 가능하게 하는 옵션을 `docker run --help` 에서 찾아보세요.',
     "docker logs app > /tmp/err.txt 2>&1\ncat /tmp/err.txt\ndocker rm app\ndocker run -d --name app --read-only --tmpfs /tmp alpine sh -c 'echo started > /tmp/state && sleep 3600'\ndocker exec app cat /tmp/state\n\n# --read-only 는 컨테이너의 루트 파일시스템 전체를 막는다. 쓸 곳만 --tmpfs(메모리)나 볼륨으로 열어 준다",
     CLEAN + "; docker run -d --name app --read-only alpine sh -c 'echo started > /tmp/state && sleep 3600' >/dev/null 2>&1; sleep 1; true",
     [chk('오류 로그가 저장돼 있다', 'grep -q "Read-only file system" /tmp/err.txt'),
      chk('app 이 실행 중이고 읽기 전용이다', '[ "$(docker inspect -f \'{{.State.Running}} {{.HostConfig.ReadonlyRootfs}}\' app 2>/dev/null)" = "true true" ]'),
      chk('/tmp/state 가 만들어졌다', 'for i in 1 2 3 4 5; do [ "$(docker exec app cat /tmp/state 2>/dev/null)" = started ] && exit 0; sleep 1; done; exit 1')])
# 4 -------------------------------------------------------------
b.nt('바인드 마운트가 이미지 파일을 가린다', '이미지 `webimg` 는 `/app/index.txt`(내용 `welcome`)를 품고 있습니다. 그런데 데이터를 남기려고 빈 호스트 폴더 `/tmp/emptydir` 을 `/app` 에 붙여 실행했더니 컨테이너 `web` 안에서 `/app/index.txt` 가 **사라졌습니다.**\n\n`web` 을 다시 실행해, **이미지의 `/app/index.txt` 가 보이면서** `/app` 의 데이터가 볼륨 **`webdata`** 에 저장되게 하세요. (명령은 이미지 기본값 그대로)',
     '바인드 마운트는 그 경로에 있던 이미지 내용을 가립니다. 이름 있는 볼륨은 비어 있을 때 처음 한 번 이미지의 내용을 채워 받습니다. 마운트 형태가 어떻게 달라지는지 비교해 보세요.',
     "docker exec web ls /app\ndocker rm -f web\ndocker run -d --name web -v webdata:/app webimg\ndocker exec web cat /app/index.txt\n\n# 바인드 마운트(호스트 폴더)는 이미지의 해당 경로를 덮어 가린다. 비어 있는 새 이름 있는 볼륨은 처음에 이미지 내용을 복사해 채운다",
     CLEAN + "; " + BUILD('webimg', 'RUN mkdir /app && echo welcome > /app/index.txt\\nCMD [\"sleep\",\"3600\"]') + " && mkdir -p /tmp/emptydir && docker run -d --name web -v /tmp/emptydir:/app webimg >/dev/null 2>&1; true",
     [chk('web 이 실행 중이다', '[ "$(docker inspect -f \'{{.State.Running}}\' web 2>/dev/null)" = true ]'),
      chk('이미지의 index.txt 가 보인다', '[ "$(docker exec web cat /app/index.txt 2>/dev/null)" = welcome ]'),
      chk('webdata 볼륨을 쓴다', '[ "$(docker inspect -f \'{{range .Mounts}}{{.Name}}{{end}}\' web 2>/dev/null)" = webdata ]')])
# 5 -------------------------------------------------------------
b.nt('이미지를 새로 만들었는데 옛 내용이 나온다', '이미지 `app:1` 은 `/conf/ver` 에 버전을 담고 있습니다. 처음에는 `v1` 이었다가 `v2` 로 **이미지를 다시 빌드**했습니다. 그런데 컨테이너 `app`(볼륨 `confvol` 을 `/conf` 에 마운트)을 새로 띄워도 `docker exec app cat /conf/ver` 가 여전히 **`v1`** 을 보여 줍니다.\n\n컨테이너 `app` 이 **`v2`** 를 보여 주도록 고치세요. 마운트는 그대로 볼륨 `confvol` 을 `/conf` 에 붙입니다. (설정 파일은 이미지 안에만 있고 따로 보관할 값은 없습니다.)',
     '이미지는 이미 `v2` 입니다. 이름 있는 볼륨은 한 번 채워지면 컨테이너를 지워도 남고, 이후에는 이미지 내용으로 다시 채워지지 않습니다. 지울 것이 무엇인지 생각하세요.',
     "docker run --rm app:1 cat /conf/ver\ndocker exec app cat /conf/ver\ndocker rm -f app\ndocker volume rm confvol\ndocker run -d --name app -v confvol:/conf app:1\ndocker exec app cat /conf/ver\n\n# 볼륨은 비어 있을 때만 이미지 내용을 받는다. 옛 값이 든 볼륨이 남아 있으면 새 이미지의 파일을 가린다",
     CLEAN + "; " + BUILD('app:1', 'RUN mkdir /conf && echo v1 > /conf/ver\\nCMD [\"sleep\",\"3600\"]') + " && docker run -d --name app -v confvol:/conf app:1 >/dev/null && docker rm -f app >/dev/null && " + BUILD('app:1', 'RUN mkdir /conf && echo v2 > /conf/ver\\nCMD [\"sleep\",\"3600\"]') + " && docker run -d --name app -v confvol:/conf app:1 >/dev/null; true",
     [chk('app 이 실행 중이다', '[ "$(docker inspect -f \'{{.State.Running}}\' app 2>/dev/null)" = true ]'),
      chk('v2 가 보인다', '[ "$(docker exec app cat /conf/ver 2>/dev/null)" = v2 ]'),
      chk('confvol 을 쓴다', '[ "$(docker inspect -f \'{{range .Mounts}}{{.Name}}{{end}}\' app 2>/dev/null)" = confvol ]')])
# 6 -------------------------------------------------------------
b.nt('디스크가 찼다: 어떤 볼륨이 가장 큰가', '서버 디스크가 거의 찼습니다. 도커가 쓰는 공간 중 **볼륨**이 의심됩니다. 볼륨 세 개(`bigvol`, `midvol`, `smallvol`)가 있습니다. 이름이 크기를 말해 주지는 않으니, 도커가 보고하는 **항목별 사용량**을 보고 **가장 큰 볼륨의 이름**만 `/tmp/big.txt` 에 저장하세요.',
     '`docker system df` 만으로는 종류별 합계만 나옵니다. 항목 하나하나의 이름과 크기를 보여 주는 옵션이 있습니다. 출력에서 `Local Volumes` 구역을 보세요.',
     "docker system df\ndocker system df -v\ndocker system df -v | grep -E '^(bigvol|midvol|smallvol)'\necho bigvol > /tmp/big.txt   # SIZE 열이 가장 큰 볼륨 이름\n\n# docker system df : 이미지·컨테이너·볼륨·빌드 캐시별 합계. -v 를 붙이면 항목별 상세",
     CLEAN + "; for p in big:30 mid:8 small:1; do n=${p%%:*}; m=${p##*:}; docker run --rm -v ${n}vol:/d alpine sh -c \"dd if=/dev/urandom of=/d/f bs=1M count=$m 2>/dev/null\"; done; true",
     [chk('가장 큰 볼륨 이름이 적혀 있다', '[ "$(cat /tmp/big.txt)" = bigvol ]')])
# 7 -------------------------------------------------------------
b.nt('안전하게 정리하기: system prune 의 범위', '디스크 확보를 위해 도커가 쌓아 둔 찌꺼기를 정리합니다. 지금 상태입니다.\n- 실행 중: `keep`\n- 종료된 컨테이너: `old1`, `old2`\n- 태그 없는(`<none>`) 이전 버전 이미지 1개\n- 지금은 쓰는 컨테이너가 없지만 **지우면 안 되는 볼륨 `precious`**\n\n`keep` 과 `precious` 는 그대로 두고, 종료된 컨테이너와 태그 없는 이미지를 지우세요.',
     '`docker system prune` 이 기본으로 지우는 것과 지우지 않는 것을 `--help` 에서 확인하세요. 볼륨을 지우는 옵션은 따로 있고, 한 번 지우면 되돌릴 수 없습니다. 정리 전에 `docker ps -a`, `docker images`, `docker volume ls` 로 현재 상태를 기록해 두면 좋습니다.',
     "docker ps -a\ndocker images\ndocker volume ls\ndocker system prune -f\ndocker ps -a\ndocker images\ndocker volume ls\n\n# 기본값: 종료된 컨테이너·태그 없는 이미지·안 쓰는 네트워크·빌드 캐시를 지운다. 볼륨은 --volumes 를 줘야 지우므로 기본에서는 안전하다",
     CLEAN + "; " + BUILD('tool:1', 'RUN echo a > /a') + " && " + BUILD('tool:1', 'RUN echo b > /b') + " && docker volume create precious >/dev/null && docker run -d --name keep alpine sleep 3600 >/dev/null && docker run --name old1 alpine true >/dev/null && docker run --name old2 alpine true >/dev/null; true",
     [chk('keep 이 실행 중이다', '[ "$(docker inspect -f \'{{.State.Running}}\' keep 2>/dev/null)" = true ]'),
      chk('종료된 컨테이너가 없다', '[ -z "$(docker ps -aq -f status=exited)" ]'),
      chk('태그 없는 이미지가 없다', '[ -z "$(docker images -q -f dangling=true)" ]'),
      chk('precious 볼륨이 남아 있다', 'docker volume inspect precious >/dev/null 2>&1')])
# 8 -------------------------------------------------------------
b.nt('Permission denied: 이름 있는 볼륨의 주인이 root 다', '비어 있는 볼륨 `appdata` 는 root 소유로 만들어져 있습니다. 컨테이너를 일반 사용자(uid 1000)로 실행해 이 볼륨에 파일을 쓰려는데 실패합니다. 이번에는 호스트 폴더가 아니라 **볼륨**이라 `chown` 을 호스트에서 바로 하기가 마땅치 않습니다.\n\n1. 아래 명령의 **오류 메시지**를 `/tmp/perm.txt` 에 저장하세요.\n`docker run --rm --user 1000:1000 -v appdata:/data alpine sh -c \'echo ok > /data/out.txt\'`\n2. 원인을 고쳐 **같은 명령이 성공**하게 하세요. (볼륨은 지우지 마세요.)',
     '볼륨 안의 소유권은 컨테이너 안에서도 바꿀 수 있습니다. 권한을 바꿀 수 있는 사용자(root)로 잠깐 도는 일회용 컨테이너에 같은 볼륨을 붙여 소유자를 바꾼 뒤, 원래 명령을 다시 실행하세요.',
     "W='echo ok > /data/out.txt'\ndocker run --rm --user 1000:1000 -v appdata:/data alpine sh -c \"$W\" 2> /tmp/perm.txt\ncat /tmp/perm.txt\ndocker run --rm -v appdata:/data alpine chown 1000:1000 /data\ndocker run --rm --user 1000:1000 -v appdata:/data alpine sh -c \"$W\"\ndocker run --rm -v appdata:/data alpine ls -ln /data\n\n# 볼륨 루트 폴더의 주인을 일회용 root 컨테이너로 바꿔 준다. 컨테이너 uid 와 볼륨 안 소유자가 맞아야 쓸 수 있다",
     CLEAN + "; docker volume create appdata >/dev/null",
     [chk('오류 메시지가 저장돼 있다', 'grep -q "Permission denied" /tmp/perm.txt'),
      chk('볼륨에 out.txt 가 있다', '[ "$(docker run --rm -v appdata:/data alpine cat /data/out.txt 2>/dev/null)" = ok ]'),
      chk('out.txt 의 주인이 uid 1000 이다', '[ "$(docker run --rm -v appdata:/data alpine stat -c %u /data/out.txt 2>/dev/null)" = 1000 ]')])
# 9 -------------------------------------------------------------
b.choice('마운트가 이미지 파일을 가리는 경우', '이미지의 `/app` 안에 `index.txt` 가 들어 있습니다. 다음 중 컨테이너를 실행했을 때 **`/app/index.txt` 가 보이는** 경우는 어느 것일까요?',
         '바인드 마운트와 이름 있는 볼륨은 이미지 내용을 대하는 방식이 다릅니다. 호스트 폴더가 비어 있는지, 볼륨이 새것인지를 보세요.',
         ['처음 만들어지는 빈 이름 있는 볼륨 `-v newvol:/app`', '비어 있는 호스트 폴더 `-v /tmp/empty:/app`', '옛 버전의 파일이 이미 들어 있는 이름 있는 볼륨 `-v oldvol:/app`', '존재하지 않는 호스트 경로 `-v /tmp/typo:/app`'], 0,
         '처음 쓰는 빈 이름 있는 볼륨은 컨테이너가 시작될 때 이미지의 해당 경로 내용이 복사되어 채워집니다. 호스트 폴더(바인드 마운트)는 비어 있어도 이미지 내용을 가리고, 없는 경로는 도커가 빈 폴더를 만들어 붙이므로 마찬가지입니다. 이미 내용이 있는 볼륨은 이미지가 바뀌어도 다시 채워지지 않아 옛 파일이 보입니다.')
# 10 ------------------------------------------------------------
b.fill('디스크 사용량 보는 명령 채우기', '디스크가 찼을 때 쓰는 명령입니다. 줄마다 설명에 맞게 빈칸을 채우세요. (볼륨은 지우지 않습니다.)',
       '첫 줄은 사용량 요약의 하위 명령, 둘째 줄은 항목별 이름과 크기를 보는 옵션, 셋째 줄은 컨테이너가 쓰지 않는 이미지를 태그가 있어도 모두 지우는 옵션입니다.',
       'docker system {0}               # 이미지·컨테이너·볼륨·빌드 캐시별 사용량 요약\ndocker system df {1}            # 항목별 이름과 크기까지 상세 출력\ndocker system prune {2}         # 안 쓰는 이미지까지 모두 정리(볼륨은 제외)',
       ['df', 'prune', '-v', '-a', '--volumes', '-f'], [0, 2, 3],
       '`docker system df` 는 종류별 합계를, `-v` 를 붙이면 이미지·컨테이너·볼륨 하나하나의 크기를 보여 줍니다. `docker system prune` 은 기본으로 종료된 컨테이너·태그 없는 이미지·안 쓰는 네트워크·빌드 캐시를 지우고, `-a` 를 주면 쓰이지 않는 이미지 전체를 지웁니다. 볼륨은 `--volumes` 를 줘야만 지워지니 데이터가 든 호스트에서는 특히 조심하세요. `-f` 는 확인 질문만 건너뜁니다.')
# 11 ------------------------------------------------------------
b.order('Permission denied 를 푸는 순서', '컨테이너가 마운트한 곳에 파일을 쓰다가 `Permission denied` 가 났습니다. 원인을 찾아 고치는 흐름을 **앞에서 뒤**로 놓으세요.',
        '막힌 증상이 무엇인지부터 읽고, 비교하고, 고치고, 다시 해 보는 순서입니다. 비교 단계에서는 숫자 uid 를 봅니다.',
        ['컨테이너 안 프로세스의 uid(`id`)와 마운트한 곳의 소유자·권한(`ls -ln`)을 비교한다', '같은 명령을 다시 실행해 쓰기가 되는지 확인한다', '오류 메시지에서 어느 경로를 쓰다 막혔는지 읽는다', '소유자(`chown`)를 맞추거나 `--user` 로 uid 를 맞춘다'], [2, 0, 3, 1],
        '메시지에서 어떤 경로가 막혔는지 읽은 뒤, 컨테이너 프로세스의 uid 와 그 경로의 소유자·권한(숫자 uid)을 비교해 어긋난 곳을 찾습니다. 그다음 `chown` 으로 소유자를 바꾸거나 `--user` 로 컨테이너 uid 를 맞춘 뒤 다시 실행해 해결을 확인합니다. 이름이 같아 보여도 컨테이너와 호스트의 uid 는 서로 다른 사용자 목록에서 나온 숫자일 수 있어 이름이 아닌 숫자로 비교해야 합니다.')
# 12 ------------------------------------------------------------
b.choice('디스크 정리 중 가장 위험한 명령', '운영 호스트의 디스크가 찼습니다. 다음 중 **데이터를 잃을 위험이 가장 큰 명령**은 어느 것일까요?',
         '이름 있는 볼륨에는 데이터베이스 파일 같은 보존해야 할 데이터가 들어 있을 수 있습니다. 어느 명령이 볼륨까지 건드리는지 보세요.',
         ['`docker system prune -a --volumes -f`', '`docker system df -v`', '`docker container prune -f`', '`docker image prune -f`'], 0,
         '`--volumes` 를 주면 컨테이너가 쓰지 않는 볼륨까지 지우고, `-a` 는 쓰이지 않는 이미지 전체를, `-f` 는 확인 없이 실행합니다. 지금 멈춰 있는 컨테이너의 볼륨이면 영구 데이터도 사라질 수 있습니다. `df -v` 는 조회만 하고, `container prune` 과 `image prune` 은 각각 종료된 컨테이너와 태그 없는 이미지만 지웁니다. 정리 전에는 `docker system df -v` 와 `docker volume ls` 로 무엇이 지워질지 먼저 확인하세요.')

if __name__ == '__main__':
    preview(b)
