import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 547 systemd 한 걸음 더: journalctl 조합·실패 유닛·의존 역추적·부팅 시간·일회성 실행. 명세: docs/specs/spec_gap_set547.md
# 샌드박스(Rocky 9 ubi-init, systemd 252)에서 journalctl·systemd-analyze·systemd-run·list-units --failed·list-dependencies 가 모두 동작함을 직접 확인했다.

CLEAN = ("systemctl stop later547.timer later547.service job547.service app547 db547 slow547 >/dev/null 2>&1; "
         "systemctl reset-failed >/dev/null 2>&1; "
         "rm -f /etc/systemd/system/{db547,app547,slow547,fa547,fb547}.service /tmp/*.txt; systemctl daemon-reload")

def unit(name, body):
    return "cat > /etc/systemd/system/%s.service <<'EOF'\n%s\nEOF\n" % (name, body)

b = SetBuilder(547, 'systemd 한 걸음 더: 로그 조합·실패 유닛·부팅 시간·일회성 실행',
               '서비스 장애와 느린 부팅을 좁혀 가는 systemd 도구를 한 단계 더 익힙니다. `journalctl` 에 `-t`·`-p 범위`·`--since`·`-r` 을 조합해 필요한 로그만 뽑고, `systemctl list-units --failed` 로 실패한 유닛을 모으고 `reset-failed` 로 정리하며, `list-dependencies --reverse` 로 "이 유닛이 멈추면 누가 영향받는지"를 보고, `systemd-analyze blame`·`critical-chain` 으로 느린 부팅을 읽고, `systemd-run` 으로 유닛 파일 없이 명령을 한 번만 돌립니다.',
               'linux-systemd', '리눅스', 58, 806, '🔍',
               [{"title": "journalctl 매뉴얼", "url": "https://www.freedesktop.org/software/systemd/man/latest/journalctl.html"},
                {"title": "systemd-analyze 매뉴얼", "url": "https://www.freedesktop.org/software/systemd/man/latest/systemd-analyze.html"},
                {"title": "systemd-run 매뉴얼", "url": "https://www.freedesktop.org/software/systemd/man/latest/systemd-run.html"}], 3)

# 1 -------------------------------------------------------------
b.nt('태그와 우선순위 범위로 로그 좁히기', '`shopapp` 이라는 이름표(태그)로 로그가 여러 수준으로 남아 있습니다. `journalctl` 은 `-t 이름표` 로 특정 프로그램의 줄만 보고, `-p 낮은수준..높은수준` 처럼 **범위**로 우선순위를 걸 수 있습니다. 심각도는 `emerg(0) > alert > crit > err > warning > notice > info > debug(7)` 순입니다.\n\n`shopapp` 의 로그 중 **warning 부터 err 까지만**(그보다 심각한 crit, 덜 심각한 notice·info 는 제외) **`/tmp/q1.txt`** 에 저장하세요. (`--no-pager` 로 페이저를 끕니다)',
     '`-p` 에는 `이름..이름` 형태로 범위를 줄 수 있습니다. 순서는 어느 쪽이든 되고, 두 수준을 포함한 사이만 남습니다. 대상 프로그램은 `-t` 로 고릅니다.',
     "journalctl -t shopapp -p warning..err --no-pager > /tmp/q1.txt\ncat /tmp/q1.txt\n\n# -p warning 만 쓰면 crit 까지 포함(warning 이상 전부). 범위 warning..err 는 두 수준 사이만 남긴다",
     CLEAN + "\nfor p in crit err warning notice info; do logger -p user.$p -t shopapp \"level-$p\"; done\nsleep 1\n",
     [chk('파일이 있다', '[ -s /tmp/q1.txt ]'), chk('warning 과 err 줄이 있다', 'grep -q level-warning /tmp/q1.txt && grep -q level-err /tmp/q1.txt'),
      chk('crit 는 빠졌다', '! grep -q level-crit /tmp/q1.txt'), chk('notice·info 는 빠졌다', '! grep -q -e level-notice -e level-info /tmp/q1.txt')])
# 2 -------------------------------------------------------------
b.nt('--since 로 특정 시각 이후만 보기', '장애 신고가 들어온 시각 이후의 로그만 보고 싶습니다. `journalctl --since "2026-11-19 14:30:00"` 처럼 시각을 주면 그 이후 줄만, `--until` 을 함께 주면 구간만 나옵니다. (`--since "10 min ago"`, `yesterday`, `09:00` 같은 표현도 됩니다.)\n\n이 서버의 `timedemo` 로그 중에는 **신고 시각 이전** 줄(`old-event`)과 **이후** 줄(`new-event`)이 있습니다. 신고 시각(서버 현재 시간대 기준)은 `/tmp/since.txt` 에 `YYYY-MM-DD HH:MM:SS` 형태로 적혀 있습니다. 이 시각 **이후의** `timedemo` 로그만 **`/tmp/q2.txt`** 에 저장하세요.',
     '`/tmp/since.txt` 를 읽어 그 값을 `--since` 에 넘기세요(값에 공백이 있으니 따옴표로 감싸야 하고, 명령 치환 `$(...)` 을 쓸 수 있습니다). 태그는 `-t` 로 고릅니다.',
     "cat /tmp/since.txt\njournalctl -t timedemo --since \"$(cat /tmp/since.txt)\" --no-pager > /tmp/q2.txt\ncat /tmp/q2.txt\n\n# 구간이 필요하면 --until 도 함께 쓴다. 시각 기준은 서버의 현재 시간대",
     CLEAN + "\nlogger -t timedemo 'old-event'\nsleep 2\ndate '+%F %T' > /tmp/since.txt\nsleep 1\nlogger -t timedemo 'new-event'\nsleep 1\n",
     [chk('파일이 있다', '[ -s /tmp/q2.txt ]'), chk('신고 이후 줄(new-event)이 있다', 'grep -q new-event /tmp/q2.txt'), chk('이전 줄(old-event)은 빠졌다', '! grep -q old-event /tmp/q2.txt')])
# 3 -------------------------------------------------------------
b.choice('어제 하루치 로그만 보려면', '오늘 아침에 어제 하루(어제 0시부터 오늘 0시 전까지)의 `nginx` 서비스 로그만 확인하려고 합니다. 알맞은 명령은 무엇일까요?',
         '하루치는 시작 시각과 끝 시각이 모두 있어야 합니다. `--since`·`--until` 에 줄 수 있는 `yesterday`·`today` 가 각각 몇 시를 뜻하는지 `man journalctl` 의 TIME 구문에서 찾아 보세요.',
         ['`journalctl -u nginx --since yesterday --until today`', '`journalctl -u nginx --since yesterday`', '`journalctl -u nginx --until yesterday`', '`journalctl -u nginx -b -1`'], 0,
         '`--since yesterday --until today` 는 어제 0시 ≤ 시각 < 오늘 0시 구간입니다. `--since yesterday` 만 쓰면 어제부터 **지금까지**(오늘 로그까지 포함)이고, `--until yesterday` 는 어제 0시 **이전** 전부입니다. `-b -1` 은 하루가 아니라 **직전 부팅** 한 회차의 로그입니다(영구 저장된 저널이 있을 때). 구간은 `--since "2026-11-19 09:00" --until "2026-11-19 09:30"` 처럼 정확한 시각으로도 줄 수 있습니다.')
# 4 -------------------------------------------------------------
b.nt('실패한 유닛 한눈에 모으기', '서버에서 서비스 여러 개가 조용히 실패해 있습니다. 하나씩 `status` 를 보기 전에, **실패 상태인 유닛만** 모아 보는 옵션이 있습니다. 목록 열 맞춤 장식(●)과 머리글을 빼면 스크립트로 처리하기 좋습니다.\n\n실패한 유닛의 **이름만** 한 줄에 하나씩 **`/tmp/q4.txt`** 에 저장하세요.',
     '`systemctl list-units` 에 상태를 걸러 주는 옵션이 있습니다(`systemctl --help` 에서 failed 를 찾아 보세요). `--plain`·`--no-legend` 는 장식과 머리글을 없애고, 첫 칸이 유닛 이름이라 `awk` 로 뽑을 수 있습니다.',
     "systemctl list-units --failed --no-pager --plain --no-legend | awk '{print $1}' > /tmp/q4.txt\ncat /tmp/q4.txt   # fa547.service, fb547.service\n\n# 같은 정보를 systemctl --failed 로도 볼 수 있다",
     CLEAN + "\n" + unit('fa547', '[Service]\nType=oneshot\nExecStart=/bin/false') + unit('fb547', '[Service]\nType=oneshot\nExecStart=/bin/false') +
     "systemctl daemon-reload\nsystemctl start fa547 fb547 >/dev/null 2>&1 || true\n",
     [chk('파일이 있다', '[ -s /tmp/q4.txt ]'), chk('실패한 유닛 두 개의 이름이 정확히 저장됐다', '[ "$(sort /tmp/q4.txt | tr "\\n" " ")" = "fa547.service fb547.service " ]')])
# 5 -------------------------------------------------------------
b.nt('확인이 끝난 실패 표시 지우기', '앞의 두 유닛 중 `fa547.service` 는 원인을 확인하고 정리까지 끝났습니다. 하지만 실패 기록이 남아 있으면 모니터링 화면과 `--failed` 목록에 계속 보입니다. 유닛이 **실패(failed) 상태로 남은 기록**만 지우는 명령이 있습니다. (유닛을 다시 시작하는 것이 아니라 상태 표시만 초기화합니다.)\n\n**`fa547.service` 만** 실패 표시를 지우세요. `fb547.service` 는 아직 조사 중이므로 실패 상태 그대로 둡니다.',
     'failed 상태를 초기화하는 하위 명령을 찾아 보세요. 이름을 지정하지 않으면 모든 유닛이 초기화되므로 대상을 꼭 지정하세요.',
     "systemctl reset-failed fa547.service\nsystemctl list-units --failed --no-pager   # fb547 만 남는다\n\n# 이름 없이 systemctl reset-failed 만 치면 전부 지워져 조사 중인 것까지 사라진다",
     CLEAN + "\n" + unit('fa547', '[Service]\nType=oneshot\nExecStart=/bin/false') + unit('fb547', '[Service]\nType=oneshot\nExecStart=/bin/false') +
     "systemctl daemon-reload\nsystemctl start fa547 fb547 >/dev/null 2>&1 || true\n",
     [chk('fa547 의 실패 표시가 없다', '! systemctl is-failed --quiet fa547.service'), chk('fb547 은 실패 상태로 남아 있다', 'systemctl is-failed --quiet fb547.service')])
# 6 -------------------------------------------------------------
b.nt('이 유닛이 멈추면 누가 영향받나', '`db547.service` 를 재시작하려는데, 이것에 **의존해서 같이 영향받는 유닛**이 있는지 먼저 확인하고 싶습니다. `systemctl list-dependencies 유닛` 은 "이 유닛이 필요로 하는 것"을 보여 줍니다. 반대 방향, 즉 "이 유닛을 필요로 하는 것"을 보려면 옵션 하나를 더 붙입니다. (`app547.service` 는 `Requires=db547.service` 로 db 에 의존합니다.)\n\n`db547.service` 를 **필요로 하는 쪽**의 나무를 **`/tmp/q6.txt`** 에 저장하세요.',
     '`list-dependencies` 의 방향을 뒤집는 옵션이 있습니다(영어로 "반대"). `systemctl list-dependencies --help` 또는 `systemctl --help` 에서 찾아 보세요. 페이저는 `--no-pager` 로 끕니다.',
     "systemctl list-dependencies --reverse db547.service --no-pager > /tmp/q6.txt\ncat /tmp/q6.txt\n\n# 첫 줄은 db547.service 자신, 그 아래에 이것에 의존하는 app547.service 가 나온다",
     CLEAN + "\n" + unit('db547', '[Service]\nExecStart=/bin/sleep infinity') + unit('app547', '[Unit]\nRequires=db547.service\nAfter=db547.service\n[Service]\nExecStart=/bin/sleep infinity') +
     "systemctl daemon-reload\nsystemctl start app547\n",
     [chk('파일이 있다', '[ -s /tmp/q6.txt ]'), chk('첫 줄이 db547.service 다', 'head -1 /tmp/q6.txt | grep -q db547.service'), chk('db547 에 의존하는 app547 이 나온다', 'grep -q app547.service /tmp/q6.txt')])
# 7 -------------------------------------------------------------
b.choice('Requires= 로 묶인 유닛을 멈추면', '앞 문제의 `app547.service` 는 `Requires=db547.service` + `After=db547.service` 입니다. 두 유닛이 모두 실행 중일 때 `systemctl stop db547.service` 를 하면 어떻게 될까요?',
         '`Requires=` 는 강한 의존입니다. 필요한 쪽이 멈추면 그것에 기대던 쪽은 어떻게 되는지 생각해 보세요. 반대 방향은 다릅니다.',
         ['`app547` 도 함께 멈춘다', '`app547` 은 영향이 없고 계속 실행된다', '`db547` 은 `app547` 이 필요로 하므로 멈추라는 명령이 거부된다', '`app547` 이 자동으로 `db547` 을 다시 시작해 둘 다 계속 돈다'], 0,
         '`Requires=` 로 의존하는 쪽(app)은 필요한 유닛(db)이 멈추면 **함께 멈춥니다**(stop 이 전파됨). 반대로 app 을 멈춰도 db 는 그대로입니다. 거부되지 않고, 자동으로 되살리지도 않습니다(되살림은 `Restart=` 의 역할). 그래서 운영 중인 서비스를 멈추기 전에 `list-dependencies --reverse` 로 영향 범위를 확인합니다. 약한 의존인 `Wants=` 는 멈춤이 전파되지 않습니다.')
# 8 -------------------------------------------------------------
b.nt('부팅이 느린 유닛 찾기 (blame)', '부팅 때 시간이 오래 걸리는 유닛을 찾을 때 `systemd-analyze blame` 을 씁니다. 유닛마다 **시작에 걸린 시간**을 **오래 걸린 순서**(가장 느린 것이 맨 위)로 보여 줍니다. 이 서버에는 일부러 시작에 3초 걸리는 유닛(`slow547.service`)이 있습니다.\n\n`blame` 결과 중 **가장 오래 걸린 상위 3줄만 `/tmp/q8.txt`** 에 저장하세요. (페이저는 `--no-pager` 로 끄고, 위쪽 몇 줄만 남기는 명령은 `head` 입니다.)',
     '`systemd-analyze` 의 하위 명령 이름은 "누구 탓인지"를 뜻하는 영어 단어입니다. 이미 오래 걸린 순서로 정렬돼 나오므로 위쪽 줄만 자르면 됩니다.',
     "systemd-analyze blame --no-pager | head -3 > /tmp/q8.txt\ncat /tmp/q8.txt   # 3.0s slow547.service 가 맨 위\n\n# 시간 단위가 ms/s/min 으로 섞여 나오니 숫자만 보고 비교하지 말 것",
     CLEAN + "\n" + unit('slow547', '[Service]\nType=oneshot\nRemainAfterExit=yes\nExecStart=/bin/sleep 3') + "systemctl daemon-reload\nsystemctl start slow547\n",
     [chk('파일이 있다', '[ -s /tmp/q8.txt ]'), chk('정확히 3줄이다', '[ "$(wc -l < /tmp/q8.txt)" -eq 3 ]'), chk('가장 느린 slow547.service 가 들어 있다', 'grep -q slow547.service /tmp/q8.txt')])
# 9 -------------------------------------------------------------
b.choice('blame 1등이 곧 부팅 지연의 원인일까', '`systemd-analyze blame` 에서 `foo.service` 가 40초로 1등입니다. 그런데 `systemd-analyze` 의 총 부팅 시간은 20초입니다. 어떻게 해석하는 것이 가장 알맞을까요?',
         'systemd 는 서로 의존하지 않는 유닛을 동시에 시작합니다. 동시에 돌았다면 시간이 겹칩니다.',
         ['`blame` 은 유닛 각자의 시작 소요 시간이라 서로 겹칠 수 있다. 부팅 전체를 실제로 지연시킨 의존 사슬은 `systemd-analyze critical-chain` 으로 따로 확인한다', '`blame` 에 문제가 있어 측정값이 틀린 것이다', '총 부팅 시간이 잘못 표시된 것이다', '`foo.service` 를 지우면 부팅이 반드시 40초 줄어든다'], 0,
         '`blame` 은 유닛별 "활성화되기까지의 시간"이고 유닛들은 병렬로 시작하므로 **합이 총 시간과 같지 않습니다.** 또한 어떤 유닛의 지연이 부팅 완료를 막았는지는 별개입니다. `systemd-analyze critical-chain` 은 목표(기본 target)에 도달하기까지 **기다림이 이어진 의존 사슬**을 `@시작시각`·`+소요시간` 으로 보여 줍니다. 두 도구를 짝으로 씁니다: blame 으로 느린 후보를 찾고, critical-chain 으로 진짜 병목인지 확인합니다.')
# 10 ------------------------------------------------------------
b.nt('유닛 파일 없이 한 번만 실행 (systemd-run)', '점검용 명령을 한 번만, 그것도 서비스처럼 **로그가 저널에 남게** 돌리고 싶을 때 유닛 파일을 만들 필요 없이 `systemd-run` 을 씁니다. 임시(transient) 서비스 유닛이 만들어져 명령을 실행하고, 끝나면 사라집니다. 옵션 `--unit=이름` 으로 유닛 이름을 정하고, `--collect` 를 붙이면 끝난 유닛 기록을 자동으로 치웁니다.\n\n`job547` 이라는 이름의 임시 유닛으로 `sh -c "echo job-done-547"` 을 실행하세요. 그런 다음 그 유닛의 저널(`journalctl -u job547`)을 **`/tmp/q10.txt`** 에 저장하세요.',
     '`systemd-run --unit=이름 --collect 명령...` 형태입니다. 실행 직후 로그를 보려고 `journalctl -u` 를 바로 치면 아직 안 올라올 수 있으니 잠깐 뒤에 확인하세요.',
     "systemd-run --unit=job547 --collect sh -c 'echo job-done-547'\nsleep 1\njournalctl -u job547 --no-pager > /tmp/q10.txt\ncat /tmp/q10.txt\n\n# 임시 유닛이라 /etc/systemd/system 에 파일이 생기지 않는다. 끝나면 유닛은 자동으로 정리된다",
     CLEAN + "\n",
     [chk('job547 유닛의 저널에 출력이 남아 있다', 'journalctl -u job547 --no-pager | grep -q job-done-547'), chk('저장한 파일에 출력이 있다', 'grep -q job-done-547 /tmp/q10.txt'), chk('유닛 파일을 만들지 않았다', '[ ! -e /etc/systemd/system/job547.service ]')])
# 11 ------------------------------------------------------------
b.nt('일정 시간 뒤에 한 번 실행 (--on-active)', '`systemd-run` 에 시간 옵션을 붙이면 **타이머** 도 함께 만들어져 "지금부터 N 뒤에" 한 번 실행할 수 있습니다. `--on-active=30min` 은 지금부터 30분 뒤입니다. (`at` 명령처럼 쓰지만 유닛과 로그로 관리됩니다.)\n\n`later547` 이라는 이름으로 **30분 뒤에** `/usr/bin/touch /tmp/later547.txt` 가 한 번 실행되도록 예약하세요. 예약만 하고, 실제로 실행되기를 기다릴 필요는 없습니다. 예약됐는지는 `systemctl list-timers` 로 확인합니다.',
     '`--on-active=시간` 옵션으로 지연을 주고 `--unit=이름` 으로 이름을 붙입니다. 실행할 명령은 마지막에 적습니다.',
     "systemd-run --on-active=30min --unit=later547 /usr/bin/touch /tmp/later547.txt\nsystemctl list-timers --no-pager | grep later547\n\n# later547.timer 가 만들어져 대기한다. 취소하려면 systemctl stop later547.timer",
     CLEAN + "\n",
     [chk('later547.timer 가 대기 중이다', 'systemctl is-active --quiet later547.timer'), chk('타이머 목록에 later547 이 있다', 'systemctl list-timers --no-pager | grep -q later547'), chk('아직 실행되지 않았다(파일 없음)', '[ ! -e /tmp/later547.txt ]')])
# 12 ------------------------------------------------------------
b.fill('최근 로그를 맨 위에서 보기', '`journalctl` 은 기본적으로 **오래된 줄이 위, 최신 줄이 아래**로 나옵니다. 로그가 길 때 가장 최근 로그부터 보고 싶으면 순서를 뒤집는 옵션을 씁니다. 빈칸을 채우세요.',
       '보기 옵션 중 출력 순서를 뒤집는 것을 고르세요. 계속 따라가며 보는 옵션이나 줄 수를 제한하는 옵션과 구분하세요.',
       'journalctl -u nginx {0}', ['-r', '-f', '-n 20', '-k'], [0],
       '`-r`(`--reverse`)는 최신 줄이 맨 위로 오게 뒤집습니다. `-f` 는 새 줄이 생길 때마다 계속 보여 주고(follow), `-n 20` 은 마지막 20줄만 자르지만 순서는 그대로이며, `-k` 는 커널 메시지만 봅니다. 자주 쓰는 조합은 `journalctl -u 유닛 -b -p warning -r` 처럼 유닛·부팅·우선순위·순서를 함께 거는 것입니다.')

if __name__ == '__main__':
    preview(b)
