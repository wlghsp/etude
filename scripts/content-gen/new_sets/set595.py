import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 595: iSCSI 와 NFS 장애 읽기. 명세: docs/specs/spec_gap_set595.md
# 샌드박스 linux(비특권, iSCSI·NFS 없음). iscsiadm·multipath·showmount·mount 출력 샘플을 읽고 명령을 적는다.

S95 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/iscsi_session.log <<'EOF'
tcp: [1] 192.0.2.50:3260,1 iqn.2026-11.com.example:storage.disk1 (non-flash)
tcp: [2] 198.51.100.50:3260,2 iqn.2026-11.com.example:storage.disk1 (non-flash)
EOF
cat > /tmp/multipath.log <<'EOF'
mpatha (3600a0980000000000000000000000001) dm-2 EXAMPLE,VOL
size=100G features='1 queue_if_no_path' hwhandler='0' wp=rw
|-+- policy='service-time 0' prio=50 status=active
| `- 3:0:0:1 sdb 8:16 active ready running
`-+- policy='service-time 0' prio=10 status=enabled
  `- 4:0:0:1 sdc 8:32 failed faulty running
EOF
cat > /tmp/showmount.log <<'EOF'
Export list for nfs01.example.com:
/data   192.0.2.0/24
/backup 198.51.100.10
/pub    *
EOF
cat > /tmp/nfs_errors.log <<'EOF'
$ cat /mnt/data/report.txt
cat: /mnt/data/report.txt: Stale file handle
$ mount -t nfs nfs01.example.com:/backup /mnt/backup
mount.nfs: access denied by server while mounting nfs01.example.com:/backup
$ mount -t nfs nfs01.example.com:/pub /mnt/pub
mount.nfs: Connection timed out
EOF
cat > /tmp/proc_mounts.log <<'EOF'
nfs01.example.com:/data /mnt/data nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,hard,proto=tcp,timeo=600,retrans=2 0 0
EOF
true"""

b = SetBuilder(595, 'iSCSI 와 NFS 읽기: 세션·경로, multipath, export 목록, Stale·access denied, hard 마운트',
               '네트워크 스토리지를 다룰 때 마주치는 출력을 읽는 연습입니다. iSCSI 세션에서 타깃 이름(IQN)과 접속 주소를, multipath 에서 정상·장애 경로를, NFS 서버의 export 목록에서 허용 대상을, 마운트 오류 문구로 원인(Stale file handle, access denied, 시간 초과)을, 마운트 옵션에서 hard 의 의미를 읽고 로그인 명령을 적어 봅니다. 샌드박스에는 해당 서비스가 없어 샘플 출력을 읽는 방식입니다.',
               'linux', '스토리지', 21, 855, '🔌',
               [{"title": "open-iscsi 문서", "url": "https://github.com/open-iscsi/open-iscsi"}, {"title": "nfs 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}], 5)

b.nt('iSCSI 타깃 이름', '`/tmp/iscsi_session.log` 는 `iscsiadm -m session` 의 출력입니다. 각 줄은 `접속 주소:포트,그룹 타깃이름` 형식입니다. 연결된 **타깃의 IQN**(`iqn.` 으로 시작하는 이름)을 한 번만 `/tmp/iqn.txt` 에 저장하세요. (두 세션의 타깃은 같습니다)',
     '`iqn.` 으로 시작하는 칸을 뽑고 중복을 없애세요.',
     "cat /tmp/iscsi_session.log\ngrep -o 'iqn[^ ]*' /tmp/iscsi_session.log | sort -u > /tmp/iqn.txt\ncat /tmp/iqn.txt\n\n# IQN 은 iSCSI 타깃·이니시에이터의 고유 이름이다(iqn.연월.도메인:이름). 같은 타깃에 경로 두 개(두 포털 주소)로 연결된 것은 멀티패스 구성이다",
     S95, [chk('타깃이 하나다', '[ "$(cat /tmp/iqn.txt)" = "iqn.2026-11.com.example:storage.disk1" ]')])
b.nt('접속 포털의 주소', '같은 `/tmp/iscsi_session.log` 에서 타깃에 접속한 **포털의 IP 주소**(포트 제외)를 **이름순으로 한 줄에 하나씩** `/tmp/portals.txt` 에 저장하세요.',
     '각 줄의 둘째 칸에서 `:` 앞이 주소입니다.',
     "grep -o '[0-9][0-9.]*:3260' /tmp/iscsi_session.log | cut -d: -f1 | sort > /tmp/portals.txt\ncat /tmp/portals.txt\n\n# 3260 은 iSCSI 의 기본 포트다. 서버(타깃)가 경로마다 다른 IP 를 가지면 한 네트워크가 끊겨도 다른 경로로 접근할 수 있다",
     S95, [chk('두 주소다', '[ "$(tr "\\n" " " < /tmp/portals.txt | xargs)" = "192.0.2.50 198.51.100.50" ]')])
b.nt('multipath 에서 장애 경로', '`/tmp/multipath.log` 는 `multipath -ll` 의 출력입니다. 장치로 가는 경로 하나가 `failed faulty` 입니다. **장애인 경로의 장치 이름**(`sdc` 처럼)을 `/tmp/failed_path.txt` 에 저장하세요.',
     '`failed` 가 들어간 줄에서 장치 이름 칸을 찾으세요.',
     "cat /tmp/multipath.log\ngrep 'failed' /tmp/multipath.log | awk '{print $3}' > /tmp/failed_path.txt\ncat /tmp/failed_path.txt\n\n# 경로 하나가 끊겨도 다른 경로(sdb, active ready)로 I/O 가 계속된다. 하지만 이제 중복이 없으니 끊긴 경로를 빨리 복구해야 한다",
     S95, [chk('sdc 다', '[ "$(cat /tmp/failed_path.txt)" = sdc ]')])
b.nt('NFS export 의 허용 대상', '`/tmp/showmount.log` 는 NFS 서버의 `showmount -e` 출력입니다. **`/backup` 을 마운트할 수 있도록 허용된 대상**(두 번째 칸)을 `/tmp/allowed.txt` 에 저장하세요. (값만)',
     '경로로 시작하는 줄에서 두 번째 칸입니다.',
     "cat /tmp/showmount.log\ngrep '^/backup' /tmp/showmount.log | awk '{print $2}' > /tmp/allowed.txt\ncat /tmp/allowed.txt\n\n# 192.0.2.0/24 는 이 대역 전체, 호스트 하나만 허용(198.51.100.10), * 는 모두 허용이다. access denied 는 접속하는 클라이언트 주소가 이 목록에 없을 때 난다",
     S95, [chk('198.51.100.10 이다', '[ "$(cat /tmp/allowed.txt)" = 198.51.100.10 ]')])
b.nt('Stale file handle 줄 찾기', '`/tmp/nfs_errors.log` 에는 NFS 마운트 관련 오류 세 가지가 있습니다. **`Stale file handle` 이 나온 줄이 어떤 명령 다음에 나왔는지**, 그 **명령의 대상 파일 경로**를 `/tmp/stale_path.txt` 에 저장하세요. (경로 전체, 값만)',
     '오류 줄 바로 위의 명령 줄(`$` 로 시작)을 보세요.',
     "cat /tmp/nfs_errors.log\ngrep -B1 'Stale file handle' /tmp/nfs_errors.log | head -1 | awk '{print $3}' > /tmp/stale_path.txt\ncat /tmp/stale_path.txt\n\n# Stale 은 서버에서 파일이나 디렉터리가 지워지거나 export 가 바뀌어 클라이언트가 가진 핸들이 무효가 된 것이다. 보통 언마운트 후 다시 마운트하면 해결된다",
     S95, [chk('/mnt/data/report.txt 다', '[ "$(cat /tmp/stale_path.txt)" = /mnt/data/report.txt ]')])
b.nt('iSCSI 로그인 명령 적기', '`discovery` 로 찾은 타깃에 **로그인**(접속)하는 `iscsiadm` 명령 한 줄을 `/tmp/login.txt` 에 적으세요. 타깃은 `iqn.2026-11.com.example:storage.disk1`, 포털은 `192.0.2.50` 입니다. (샌드박스에는 iSCSI 가 없어 실행하지 않습니다)',
     'iscsiadm 의 모드·타깃·포털·동작 옵션을 `man iscsiadm` 의 node 모드 예시에서 찾아보세요.',
     "echo 'iscsiadm -m node -T iqn.2026-11.com.example:storage.disk1 -p 192.0.2.50 --login' > /tmp/login.txt\ncat /tmp/login.txt\n\n# 로그인하면 서버의 LUN 이 새 블록 장치(sdX)로 보인다. 그 뒤 파티션·파일시스템은 클라이언트가 직접 만든다. 같은 LUN 을 여러 서버가 동시에 마운트하면 안 된다",
     S95, [chk('iscsiadm 로그인 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?iscsiadm .*(--login|-l)([[:space:]]|$)" /tmp/login.txt'), chk('타깃과 포털이 맞다', 'grep -q "iqn.2026-11.com.example:storage.disk1" /tmp/login.txt && grep -q "192.0.2.50" /tmp/login.txt')])
b.choice('같은 LUN 을 두 서버가', '같은 iSCSI LUN 을 서버 A 와 서버 B 가 모두 ext4 로 읽기·쓰기 마운트했습니다. 어떤 일이 생길 위험이 있을까요?', '일반 파일시스템은 자기만 쓴다고 가정합니다.',
         ['두 서버가 서로 모르게 메타데이터를 바꿔 파일시스템이 손상된다', '두 서버의 데이터가 자동으로 동기화되어 안전해진다', '두 번째 서버의 마운트는 자동으로 거부된다', '속도가 두 배로 빨라질 뿐 문제는 없다'], 0,
         'iSCSI 는 블록 장치를 넘겨 줄 뿐 파일시스템은 클라이언트가 만듭니다. 일반 파일시스템(ext4·XFS)은 한 서버만 쓴다고 가정해 동시에 마운트하면 메타데이터가 서로 덮어써 깨집니다. 공유가 필요하면 클러스터 파일시스템을 쓰거나 NFS 를 씁니다.')
b.choice('NFS hard 마운트', '`/tmp/proc_mounts.log` 는 NFS 클라이언트의 `/proc/mounts` 일부입니다. 마운트 옵션에 `hard` 가 있는 상태에서 NFS 서버가 갑자기 응답하지 않으면, 이 마운트에 접근한 프로세스는?', '`hard` 와 `soft` 가 요청 실패를 다루는 방식이 어떻게 다른지 떠올려 보세요.',
         ['서버가 돌아올 때까지 멈춘 채로 재시도하며 기다린다', '오류를 즉시 반환하고 계속 실행된다', '자동으로 다른 서버로 전환된다', '데이터를 로컬에 임시 저장하고 계속 진행한다'], 0,
         'hard 는 서버가 응답할 때까지 무한히 재시도해 데이터 무결성은 지키지만 프로세스가 D 상태로 멈춰 보일 수 있습니다. soft 는 일정 횟수 뒤 오류를 돌려주지만 쓰기 손실 위험이 있어 주의해서 씁니다.')
b.choice('access denied by server', '`mount.nfs: access denied by server while mounting` 오류의 원인으로 가장 알맞은 것은?', '네트워크가 아니라 서버의 허용 설정과 관련된 거절입니다.',
         ['서버 export 설정이 이 클라이언트를 허용하지 않는다', '클라이언트의 디스크가 가득 차서 쓸 수가 없다', '서버의 전원이 꺼져 있어 접속이 불가능하다', '클라이언트의 DNS 서버가 응답하지 않는다'], 0,
         'access denied 는 서버에 도달했지만 export 목록(`/etc/exports`)이 그 클라이언트 주소나 옵션을 허용하지 않아 거절된 것입니다. 서버 꺼짐이나 방화벽은 시간 초과(Connection timed out)로 나타납니다.')
b.fill('NFS export 목록 확인', 'NFS 서버가 어떤 경로를 누구에게 export 하는지 **클라이언트에서** 확인하는 명령입니다. 빈칸을 채우세요.', '서버의 export 목록을 보여 주는 `-e` 옵션을 쓰는 명령입니다.',
       '{0} -e nfs01.example.com', ['showmount', 'exportfs', 'mount', 'nfsstat'], [0],
       '`showmount -e 서버` 는 서버의 export 목록을 보여 줍니다. `exportfs` 는 서버에서 export 를 관리하는 명령이고, `mount` 는 마운트 명령, `nfsstat` 는 NFS 통계 명령입니다.')
b.order('iSCSI 디스크를 쓸 수 있게 만들기', '스토리지 서버의 iSCSI LUN 을 클라이언트에서 쓰려 합니다. 올바른 순서로 놓으세요.', '타깃을 찾아야 로그인할 수 있고, 장치가 보여야 그 위에 파일시스템을 만들 수 있습니다.',
        ['새로 보이는 블록 장치에 파일시스템을 만들고 마운트한다', '타깃에 로그인한다', '`lsblk` 로 새 블록 장치가 보이는지 확인한다', '포털에서 타깃을 찾는다(discovery)'], [3, 1, 2, 0],
        'discovery 로 타깃을 찾고, 로그인하면 LUN 이 블록 장치로 나타나며, lsblk 로 확인한 뒤 클라이언트가 파티션·파일시스템을 만들어 마운트합니다.')

if __name__ == '__main__':
    preview(b)
