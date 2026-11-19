-- Git 실습 세트 501. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_docker_build_opts_lab_set.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 501, 'Dockerfile·빌드 옵션 손연습: --target, STOPSIGNAL, ONBUILD, COPY --chmod, ADD 압축 해제, EXPOSE, -t 여러 번, commit --change, 빌드 시크릿', '멀티 스테이지 --target, STOPSIGNAL, ONBUILD 트리거, COPY --chmod, ADD 로 압축 풀기, EXPOSE 메타데이터, -t 여러 번, commit -c 로 명령 바꾸기, 이미지에 비밀을 남기지 않는 빌드 시크릿을 실습합니다.', 'docker', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 501);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 1, '여러 단계 중 중간 단계까지만 빌드하기 (--target)', '**배경** — 멀티 스테이지 Dockerfile 은 `FROM … AS 이름` 으로 단계를 나눕니다. **`docker build --target 단계이름`** 은 그 단계까지만 빌드해 이미지를 만듭니다. 최종 이미지가 아니라 **빌드 도구가 든 중간 단계**를 디버깅하거나 테스트 단계만 돌릴 때 씁니다. `/tmp/work/q1` 의 Dockerfile 은 `build` 와 `final` 두 단계이며 `build` 단계에서 `/build.txt` 를 만듭니다.

**문제** — **`build` 단계까지만** 빌드해 이미지 **`t1`** 을 만들고, `t1` 의 `/build.txt` 내용을 **`/tmp/q1.txt`** 에 저장하세요. (`t1` 에는 `final` 단계의 `/final.txt` 가 없어야 합니다.)', '`docker build --target build -t t1 /tmp/work/q1` → `docker run --rm t1 cat /build.txt > /tmp/q1.txt`', 'docker build --target build -t t1 /tmp/work/q1
docker run --rm t1 cat /build.txt > /tmp/q1.txt
cat /tmp/q1.txt

# --target 이 없으면 마지막 단계(final)까지 빌드한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q1; cat > /tmp/work/q1/Dockerfile <<''EOF''\\nFROM alpine AS build\\nRUN echo built > /build.txt\\nFROM alpine AS final\\nCOPY --from=build /build.txt /final.txt\\nRUN echo done >> /final.txt\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q1.txt 2>/dev/null)\\" = built ] ) && ( ! docker run --rm t1 test -e /final.txt >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "q1 이 built 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q1.txt 2>/dev/null)\\" = built ]"]}, {"label": "t1 에 final.txt 가 없다", "cmd": ["sh", "-c", "! docker run --rm t1 test -e /final.txt >/dev/null 2>&1"]}]', '[{"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}, {"title": "docker build 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 2, '종료 신호를 Dockerfile 에 정해 두기 (STOPSIGNAL)', '**배경** — `docker stop` 은 기본으로 `SIGTERM` 을 보내지만 앱에 따라 정상 종료 신호가 다릅니다(nginx 는 `SIGQUIT`). Dockerfile 의 **`STOPSIGNAL 신호`** 로 이미지에 기본 종료 신호를 박아 두면 실행할 때마다 `--stop-signal` 을 적지 않아도 됩니다. `/tmp/work/q2` 에 Dockerfile 이 있습니다.

**문제** — Dockerfile 에 **`STOPSIGNAL SIGQUIT`** 을 추가해 이미지 **`t2`** 로 빌드하세요. (`docker image inspect` 의 종료 신호가 `SIGQUIT` 이어야 합니다.)', 'Dockerfile 에 `STOPSIGNAL SIGQUIT` 한 줄을 더하고 `docker build -t t2 /tmp/work/q2`', 'echo ''STOPSIGNAL SIGQUIT'' >> /tmp/work/q2/Dockerfile
docker build -t t2 /tmp/work/q2
docker image inspect -f ''{{.Config.StopSignal}}'' t2

# 컨테이너를 --stop-signal 로 따로 실행하면 그 값이 우선한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q2; cat > /tmp/work/q2/Dockerfile <<''EOF''\\nFROM alpine\\nCMD [\\"sleep\\", \\"3600\\"]\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(docker image inspect -f ''{{.Config.StopSignal}}'' t2 2>/dev/null)\\" = SIGQUIT ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "종료 신호가 SIGQUIT 이다", "cmd": ["sh", "-c", "[ \\"$(docker image inspect -f ''{{.Config.StopSignal}}'' t2 2>/dev/null)\\" = SIGQUIT ]"]}]', '[{"title": "Dockerfile STOPSIGNAL", "url": "https://docs.docker.com/reference/dockerfile/#stopsignal"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 3, '이 이미지를 베이스로 쓰면 실행되는 명령 (ONBUILD)', '**배경** — **`ONBUILD 명령`** 은 이 이미지를 **베이스(`FROM`)로 삼아 다른 이미지를 빌드할 때** 비로소 실행되는 **예약 명령**입니다. 자기 빌드에서는 실행되지 않습니다. 언어별 베이스 이미지가 "소스를 복사해 의존성을 설치" 하는 단계를 자식 이미지에 대신 끼워 넣을 때 쓰입니다. `/tmp/work/q3a` 의 Dockerfile 에 `ONBUILD RUN echo triggered > /trig.txt` 가 있습니다.

**문제** — `q3a` 를 이미지 **`t3a`** 로 빌드하고, `FROM t3a` 한 줄짜리 Dockerfile(`/tmp/work/q3b`)을 이미지 **`t3b`** 로 빌드해 **`t3b` 에서만 `/trig.txt` 가 생기게** 하세요. (`t3a` 에는 `/trig.txt` 가 없어야 합니다.)', '`docker build -t t3a /tmp/work/q3a` → `docker build -t t3b /tmp/work/q3b`', 'docker build -t t3a /tmp/work/q3a
docker build -t t3b /tmp/work/q3b
docker run --rm t3b cat /trig.txt

# t3a 에는 트리거만 저장돼 있다(docker image inspect 의 Config.OnBuild). 자식 빌드 때 실행된다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q3a; cat > /tmp/work/q3a/Dockerfile <<''EOF''\\nFROM alpine\\nONBUILD RUN echo triggered > /trig.txt\\nEOF\\nmkdir -p /tmp/work/q3b; cat > /tmp/work/q3b/Dockerfile <<''EOF''\\nFROM t3a\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(docker run --rm t3b cat /trig.txt 2>/dev/null)\\" = triggered ] ) && ( ! docker run --rm t3a test -e /trig.txt >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "t3b 에 /trig.txt 가 있다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm t3b cat /trig.txt 2>/dev/null)\\" = triggered ]"]}, {"label": "t3a 에는 없다", "cmd": ["sh", "-c", "! docker run --rm t3a test -e /trig.txt >/dev/null 2>&1"]}]', '[{"title": "Dockerfile ONBUILD", "url": "https://docs.docker.com/reference/dockerfile/#onbuild"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 4, '복사하면서 권한 정하기 (COPY --chmod)', '**배경** — `COPY` 로 넣은 파일은 원본 권한을 따라가, 호스트에서 실행 권한이 없던 스크립트는 컨테이너에서 `Permission denied` 가 납니다. **`COPY --chmod=755 원본 대상`** 은 복사와 동시에 권한을 정해 별도의 `RUN chmod` 레이어(이미지 크기 증가)를 만들지 않습니다. `/tmp/work/q4` 에 실행 권한 없는 `run.sh` 와 Dockerfile 이 있습니다.

**문제** — Dockerfile 이 `/run.sh` 를 **권한 `755`** 로 복사하도록 고쳐 이미지 **`t4`** 를 빌드하세요. (컨테이너에서 `/run.sh` 의 권한이 `755` 여야 합니다.)', '`COPY --chmod=755 run.sh /run.sh` 로 고치고 `docker build -t t4 /tmp/work/q4`', 'sed -i ''s#^COPY run.sh#COPY --chmod=755 run.sh#'' /tmp/work/q4/Dockerfile
docker build -t t4 /tmp/work/q4
docker run --rm t4 stat -c %a /run.sh

# --chmod 는 BuildKit 에서 지원한다. --chown 도 같은 방식이다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q4; cat > /tmp/work/q4/Dockerfile <<''EOF''\\nFROM alpine\\nCOPY run.sh /run.sh\\nCMD [\\"/run.sh\\"]\\nEOF\\ncat > /tmp/work/q4/run.sh <<''EOF''\\n#!/bin/sh\\necho ok\\nEOF\\nchmod 644 /tmp/work/q4/run.sh"]', '["sh", "-c", "( [ \\"$(docker run --rm t4 stat -c %a /run.sh 2>/dev/null)\\" = 755 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "권한이 755 다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm t4 stat -c %a /run.sh 2>/dev/null)\\" = 755 ]"]}]', '[{"title": "Dockerfile COPY (--chmod)", "url": "https://docs.docker.com/reference/dockerfile/#copy"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 5, '압축 파일을 풀어서 넣기 (ADD)', '**배경** — `ADD` 는 `COPY` 와 비슷하지만 **로컬 tar 압축 파일(`.tar`, `.tar.gz`)을 대상 경로에 자동으로 풀어** 줍니다(URL 에서 받기도 가능). 압축 해제까지 필요 없는 단순 복사에는 동작이 명확한 `COPY` 가 권장됩니다. `/tmp/work/q5` 에 `app.tar.gz`(안에 `hello.txt`, 내용 `hi`)와 Dockerfile 이 있습니다.

**문제** — Dockerfile 이 `app.tar.gz` 를 `/opt/app/` 로 **풀어서** 넣도록 `ADD` 로 고쳐 이미지 **`t5`** 를 빌드하세요. (`/opt/app/hello.txt` 가 있어야 합니다.)', '`ADD app.tar.gz /opt/app/` 로 고치고 `docker build -t t5 /tmp/work/q5`', 'sed -i ''s#^COPY app.tar.gz#ADD app.tar.gz#'' /tmp/work/q5/Dockerfile
docker build -t t5 /tmp/work/q5
docker run --rm t5 cat /opt/app/hello.txt

# COPY 는 압축 파일 그대로 복사한다(풀지 않는다)', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q5; cat > /tmp/work/q5/Dockerfile <<''EOF''\\nFROM alpine\\nCOPY app.tar.gz /opt/app/\\nEOF\\ncd /tmp/work/q5 && echo hi > hello.txt && tar czf app.tar.gz hello.txt && rm hello.txt"]', '["sh", "-c", "( [ \\"$(docker run --rm t5 cat /opt/app/hello.txt 2>/dev/null)\\" = hi ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/opt/app/hello.txt 가 hi 다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm t5 cat /opt/app/hello.txt 2>/dev/null)\\" = hi ]"]}]', '[{"title": "Dockerfile ADD", "url": "https://docs.docker.com/reference/dockerfile/#add"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 6, '이미지에 포트 정보 남기기 (EXPOSE)', '**배경** — **`EXPOSE 포트/프로토콜`** 은 이미지가 어떤 포트를 쓰는지 **알려 주는 메타데이터**일 뿐 포트를 열지는 않습니다. 실제로 호스트에 열려면 `-p` 로 게시해야 하고, `docker run -P` 는 EXPOSE 한 포트를 무작위 호스트 포트에 게시합니다. `docker image inspect` 의 `ExposedPorts` 에서 확인합니다. `/tmp/work/q6` 에 Dockerfile 이 있습니다.

**문제** — Dockerfile 에 **`EXPOSE 8080/tcp`** 를 추가해 이미지 **`t6`** 를 빌드하고, `ExposedPorts` 의 키를 **`/tmp/q6.txt`** 에 저장하세요. (`8080/tcp`)', '`EXPOSE 8080/tcp` 추가 → `docker build -t t6 /tmp/work/q6` → `docker image inspect -f ''{{json .Config.ExposedPorts}}'' t6`', 'echo ''EXPOSE 8080/tcp'' >> /tmp/work/q6/Dockerfile
docker build -t t6 /tmp/work/q6
docker image inspect -f ''{{range $p, $_ := .Config.ExposedPorts}}{{$p}}{{end}}'' t6 > /tmp/q6.txt
cat /tmp/q6.txt

# EXPOSE 만으로는 호스트에서 접속되지 않는다. docker run -p 8080:8080 으로 게시한다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q6; cat > /tmp/work/q6/Dockerfile <<''EOF''\\nFROM alpine\\nCMD [\\"sleep\\", \\"3600\\"]\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/q6.txt 2>/dev/null)\\" = 8080/tcp ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "q6 이 8080/tcp 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/q6.txt 2>/dev/null)\\" = 8080/tcp ]"]}]', '[{"title": "Dockerfile EXPOSE", "url": "https://docs.docker.com/reference/dockerfile/#expose"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 7, '한 번 빌드로 태그 여러 개 붙이기 (-t 반복)', '**배경** — `docker build` 에 **`-t` 를 여러 번** 주면 같은 이미지에 태그를 한꺼번에 붙입니다. 릴리스 때 `1.2.3` 과 `latest` 를 동시에 달 때 씁니다. 태그가 달라도 **이미지 ID 는 같습니다**(한 이미지의 별명). `/tmp/work/q7` 에 Dockerfile 이 있습니다.

**문제** — 이미지를 **`t7:a`** 와 **`t7:b`** 두 태그로 **한 번의 빌드**로 만드세요. (두 태그의 이미지 ID 가 같아야 합니다.)', '`docker build -t t7:a -t t7:b /tmp/work/q7`', 'docker build -t t7:a -t t7:b /tmp/work/q7
docker image ls t7

# IMAGE ID 가 같다. 한 이미지에 이름이 두 개 붙은 것이다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q7; cat > /tmp/work/q7/Dockerfile <<''EOF''\\nFROM alpine\\nRUN echo v > /v.txt\\nEOF\\n"]', '["sh", "-c", "( docker image inspect t7:a >/dev/null 2>&1 ) && ( [ \\"$(docker image inspect -f ''{{.Id}}'' t7:a 2>/dev/null)\\" = \\"$(docker image inspect -f ''{{.Id}}'' t7:b 2>/dev/null)\\" ] && [ -n \\"$(docker image inspect -f ''{{.Id}}'' t7:a 2>/dev/null)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "t7:a 가 있다", "cmd": ["sh", "-c", "docker image inspect t7:a >/dev/null 2>&1"]}, {"label": "두 태그의 ID 가 같다", "cmd": ["sh", "-c", "[ \\"$(docker image inspect -f ''{{.Id}}'' t7:a 2>/dev/null)\\" = \\"$(docker image inspect -f ''{{.Id}}'' t7:b 2>/dev/null)\\" ] && [ -n \\"$(docker image inspect -f ''{{.Id}}'' t7:a 2>/dev/null)\\" ]"]}]', '[{"title": "docker build 레퍼런스", "url": "https://docs.docker.com/reference/cli/docker/buildx/build/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 8, '컨테이너 변경을 이미지로 굳히며 명령 바꾸기 (commit --change)', '**배경** — `docker commit 컨테이너 이미지` 는 **실행 중이던 컨테이너의 파일 변경을 새 이미지**로 만듭니다. **`-c "CMD [...]"`**(`--change`)로 Dockerfile 명령(`CMD`, `ENV`, `EXPOSE` 등)을 함께 적용할 수 있습니다. 재현 가능한 방법은 Dockerfile 이지만, 급히 상태를 보존하거나 실험할 때 씁니다. 컨테이너 `work` 에서 `/note.txt` 를 만들어 두었습니다.

**문제** — 컨테이너 `work` 를 이미지 **`t8`** 로 commit 하되 **기본 명령을 `["cat","/note.txt"]`** 로 바꾸세요. (`docker run --rm t8` 이 `kept` 를 출력해야 합니다.)', '`docker commit -c ''CMD ["cat","/note.txt"]'' work t8`', 'docker commit -c ''CMD ["cat","/note.txt"]'' work t8
docker run --rm t8

# commit 이미지는 만든 과정이 남지 않아 재현이 어렵다. 가능하면 Dockerfile 로 만든다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; docker run -d --name work alpine sh -c ''echo kept > /note.txt; sleep 3600'' >/dev/null; sleep 1"]', '["sh", "-c", "( [ \\"$(docker run --rm t8 2>/dev/null)\\" = kept ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "t8 실행 출력이 kept 다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm t8 2>/dev/null)\\" = kept ]"]}]', '[{"title": "docker commit", "url": "https://docs.docker.com/reference/cli/docker/container/commit/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 9, '이미지에 비밀을 남기지 않고 빌드하기 (build secret)', '**배경** — `ARG`·`COPY` 로 비밀 값을 넣으면 **이미지 레이어와 이력에 그대로 남습니다**. BuildKit 의 **`RUN --mount=type=secret,id=이름`** 은 빌드 중에만 `/run/secrets/이름` 으로 비밀을 보여 주고 **이미지에는 남기지 않습니다**. 빌드할 때 `--secret id=이름,src=파일` 로 값을 건넵니다. `/tmp/work/q9` 에 `token.txt`(내용 `s3cr3t`)와, 이 비밀을 읽어 **길이만** `/len.txt` 에 기록하는 Dockerfile 이 있습니다.

**문제** — 이미지 **`t9`** 를 **`--secret id=tok,src=/tmp/work/q9/token.txt`** 로 빌드하세요. (`/len.txt` 는 `6` 이고 이미지 안에 `/run/secrets/tok` 은 남지 않아야 합니다.)', '`docker build --secret id=tok,src=/tmp/work/q9/token.txt -t t9 /tmp/work/q9`', 'docker build --secret id=tok,src=/tmp/work/q9/token.txt -t t9 /tmp/work/q9
docker run --rm t9 cat /len.txt

# 비밀 값은 이미지 어디에도 남지 않는다. ARG 로 넘기면 docker history 에 보인다', '["sh", "-c", "docker rm -f $(docker ps -aq) >/dev/null 2>&1; docker rmi -f t1 t2 t3a t3b t4 t5 t6 t7:a t7:b t8 t9 >/dev/null 2>&1; rm -rf /tmp/work /tmp/q*.txt; mkdir -p /tmp/work; docker image inspect alpine >/dev/null 2>&1 || docker pull -q alpine >/dev/null 2>&1; true; mkdir -p /tmp/work/q9; cat > /tmp/work/q9/Dockerfile <<''EOF''\\nFROM alpine\\nRUN --mount=type=secret,id=tok wc -c < /run/secrets/tok | tr -d \\" \\" > /len.txt\\nEOF\\ncat > /tmp/work/q9/token.txt <<''EOF''\\ns3cr3t\\nEOF\\nprintf s3cr3t > /tmp/work/q9/token.txt"]', '["sh", "-c", "( [ \\"$(docker run --rm t9 cat /len.txt 2>/dev/null)\\" = 6 ] ) && ( ! docker run --rm t9 test -e /run/secrets/tok >/dev/null 2>&1 )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "/len.txt 가 6 이다", "cmd": ["sh", "-c", "[ \\"$(docker run --rm t9 cat /len.txt 2>/dev/null)\\" = 6 ]"]}, {"label": "비밀 파일이 이미지에 없다", "cmd": ["sh", "-c", "! docker run --rm t9 test -e /run/secrets/tok >/dev/null 2>&1"]}]', '[{"title": "빌드 시크릿", "url": "https://docs.docker.com/build/building/secrets/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 10, 'ONBUILD 가 실행되는 때', '`ONBUILD RUN …` 으로 적은 명령은 **언제** 실행될까요?', '"빌드할 때" 가 누구의 빌드인지를 생각해 보세요.', NULL, NULL, '[]', 'choice', '["이 이미지를 빌드하는 마지막 단계에서", "이 이미지를 FROM 으로 쓰는 다른 이미지를 빌드할 때", "이 이미지로 컨테이너를 실행할 때마다", "이 이미지를 레지스트리에 올릴 때"]', 1, 'ONBUILD 는 자기 빌드에서는 실행되지 않고 트리거로 저장되었다가 이 이미지를 베이스로 삼는 자식 빌드의 FROM 직후에 실행됩니다. 컨테이너 실행이나 푸시와는 관계가 없습니다.', NULL, NULL, NULL, '[{"title": "Dockerfile ONBUILD", "url": "https://docs.docker.com/reference/dockerfile/#onbuild"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 11, '여러 단계 중 일부만 빌드', '멀티 스테이지 Dockerfile 에서 특정 단계까지만 빌드하는 옵션입니다. 빌드 옵션을 채우세요.', '"목표" 의 영어예요.', NULL, NULL, '[]', 'fill', '["target", "stage", "until", "from"]', NULL, '--target 단계이름 은 그 단계까지만 빌드합니다. --stage·--until 은 docker build 옵션이 아니고, from 은 Dockerfile 명령이지 빌드 옵션이 아닙니다.', '[0]', 'docker build --{0} build -t t1 .', NULL, '[{"title": "멀티 스테이지 빌드", "url": "https://docs.docker.com/build/building/multi-stage/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 501, 12, '비밀을 남기지 않고 이미지를 만드는 순서', '빌드 시크릿으로 이미지를 만들고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '준비 → 빌드 → 확인이에요.', NULL, NULL, '[]', 'order', '["Dockerfile 의 RUN 에 `--mount=type=secret,id=tok` 를 적는다", "비밀 값이 든 파일을 준비한다", "`docker build --secret id=tok,src=파일` 로 빌드한다", "이미지 안에 `/run/secrets/tok` 과 `docker history` 에 값이 남지 않았는지 확인한다"]', NULL, 'Dockerfile 에서 비밀이 필요한 RUN 을 정의하고, 값을 파일로 준비해 빌드 때 건네고, 결과 이미지와 이력에 비밀이 남지 않았는지 확인합니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "빌드 시크릿", "url": "https://docs.docker.com/build/building/secrets/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 501 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 224 WHERE id = 142;
UPDATE quest_set SET display_order = 225 WHERE id = 239;
UPDATE quest_set SET display_order = 226 WHERE id = 179;
UPDATE quest_set SET display_order = 227 WHERE id = 246;
UPDATE quest_set SET display_order = 228 WHERE id = 209;
UPDATE quest_set SET display_order = 229 WHERE id = 254;
UPDATE quest_set SET display_order = 230 WHERE id = 228;
UPDATE quest_set SET display_order = 231 WHERE id = 352;
UPDATE quest_set SET display_order = 232 WHERE id = 498;
UPDATE quest_set SET display_order = 234 WHERE id = 148;
UPDATE quest_set SET display_order = 235 WHERE id = 240;
UPDATE quest_set SET display_order = 236 WHERE id = 175;
UPDATE quest_set SET display_order = 237 WHERE id = 245;
UPDATE quest_set SET display_order = 238 WHERE id = 206;
UPDATE quest_set SET display_order = 239 WHERE id = 253;
UPDATE quest_set SET display_order = 240 WHERE id = 237;
UPDATE quest_set SET display_order = 241 WHERE id = 38;
UPDATE quest_set SET display_order = 242 WHERE id = 39;
UPDATE quest_set SET display_order = 243 WHERE id = 490;
UPDATE quest_set SET display_order = 246 WHERE id = 97;
UPDATE quest_set SET display_order = 223, unit_id = (SELECT id FROM unit WHERE id = 67), icon = '🪤' WHERE id = 501;
