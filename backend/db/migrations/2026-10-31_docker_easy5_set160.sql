-- 도커 세트 160. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set160.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 160, '종료 코드 읽기, 컨테이너 보안 기본, 레지스트리와 digest 한 줄씩', '컨테이너 문제를 읽고 안전하게 운영하는 기본기를 한 개념씩 반복합니다. 종료 코드 127(명령 없음)·126(실행 불가)·125(docker 오류)와 앱 종료 코드 전달, 137 이 항상 OOM 은 아니라는 점과 OOMKilled 확인, --user·--read-only(--tmpfs)·--cap-drop/--cap-add·--privileged 의 위험·no-new-privileges, docker diff 의 A·C·D 와 docker top·logs --since, 레지스트리 주소가 든 이름으로 tag·push 하기, 움직이는 태그와 고정된 digest 를 짧은 객관식·빈칸·순서 문제로 익히고, 바로 종료되는 컨테이너 조사, 단계적 보안 강화, 로컬 레지스트리에 올리기, 컨테이너 안 변경 살펴보기의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 160);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🔏' WHERE id = 160;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 1, '종료 코드 127', '`docker run alpine nosuchcmd` 를 실행했더니 `OCI runtime create failed: ... executable file not found` 오류와 함께 종료 코드가 `127` 입니다. 무슨 뜻일까요?', '명령을 찾지 못했다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["컨테이너가 메모리 부족으로 종료되었다", "권한이 없어서 실행하지 못했다", "컨테이너 안에서 실행할 명령(파일)을 찾지 못했다. 명령 이름의 오타이거나 이미지에 그 프로그램이 없거나 PATH 에 없는 경우이다", "docker 의 옵션이 틀렸다"]', 2, '`ENTRYPOINT`/`CMD` 의 경로가 틀렸거나 쉘이 없는 이미지에서 `sh` 를 호출할 때도 이 오류를 만납니다. 이미지에 그 명령이 있는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 2, '종료 코드 126', '종료 코드가 `126` 이면 무엇을 의심할까요?', '명령은 찾았는데 실행하지 못한 경우예요.', NULL, NULL, '[]', 'choice', '["명령을 찾지 못했다", "명령(파일)은 있지만 실행할 수 없다. 실행 권한이 없거나 실행 파일이 아닌 파일을 실행하려는 경우이다", "docker 옵션이 틀렸다", "메모리가 부족했다"]', 1, '`docker run alpine /etc/passwd` 처럼 실행 파일이 아닌 파일을 실행하면 126 이 됩니다. 스크립트라면 `chmod +x` 를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 3, '종료 코드 125', '`docker run --nosuchflag alpine` 처럼 존재하지 않는 옵션을 줬을 때 종료 코드는 얼마일까요?', '컨테이너 안의 앱이 아니라 docker 명령 자체의 문제예요.', NULL, NULL, '[]', 'choice', '["125 (컨테이너가 시작되기 전에 `docker` 명령 자체가 실패한 경우)", "127", "0", "137"]', 0, '125 는 docker 가 컨테이너를 만들거나 시작하지 못했다는 뜻입니다. 옵션 오타, 이미 있는 이름, 포트 충돌 같은 경우예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 4, '앱의 종료 코드', '`docker run alpine sh -c ''exit 3''` 이후 `echo $?` 는 무엇일까요?', '컨테이너 안의 마지막 명령의 종료 코드가 그대로 전달돼요.', NULL, NULL, '[]', 'choice', '["항상 0", "항상 1", "125", "3 (컨테이너 안 프로세스의 종료 코드가 `docker run` 의 종료 코드로 그대로 전달된다. 0 은 성공)"]', 3, '스크립트나 CI 에서 `docker run` 의 결과로 성공 여부를 판단할 수 있는 이유입니다. 앱이 정한 값은 `docker inspect` 의 `ExitCode` 로도 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 5, '137 은 항상 OOM 일까', '컨테이너가 종료 코드 `137` 로 끝났습니다. 항상 메모리 부족(OOM) 때문일까요?', '137 은 강제 종료 신호를 뜻해요. 누가 보냈는지는 따로 확인해야 해요.', NULL, NULL, '[]', 'choice', '["그렇다. 137 은 항상 OOM 이다", "137 은 명령을 찾지 못했다는 뜻이다", "아니다. `docker stop` 의 유예 시간이 지나 강제 종료되어도 137 이 된다. OOM 인지는 `docker inspect -f ''{{.State.OOMKilled}}'' 이름` 의 값으로 확정한다", "137 은 정상 종료이다"]', 2, '강제로 멈춘 컨테이너는 `exit=137 oom=false` 로 나옵니다. 137 만 보고 메모리 한도를 올리는 실수를 하지 마세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 6, '--user', '`docker run --user 1000 alpine id -u` 의 출력과 이 옵션의 목적으로 알맞은 것은 무엇일까요?', '컨테이너 안에서 누구 권한으로 실행할지 정해요.', NULL, NULL, '[]', 'choice', '["`0` 이 출력되고 관리자 권한으로 실행된다", "`1000` 이 출력된다. root 가 아닌 사용자(UID 1000)로 프로세스를 실행해 침해되었을 때의 피해 범위를 줄이려는 옵션이다", "호스트에 사용자 1000 을 만든다", "컨테이너를 1000번 재시작한다"]', 1, '이미지의 `USER` 를 바꾸지 않고도 실행할 때 정할 수 있습니다. 쓰기 권한이 없는 폴더에서는 앱이 실패할 수 있으니 로그도 함께 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 7, '--read-only', '`docker run --read-only alpine sh -c ''touch /x''` 는 어떻게 될까요? 그리고 일부 폴더에만 쓰게 하려면 어떻게 할까요?', '루트 파일 시스템을 쓰기 금지로 만들었어요.', NULL, NULL, '[]', 'choice', '["`touch: /x: Read-only file system` 오류가 난다. 쓸 곳만 `--tmpfs /tmp` 나 볼륨으로 따로 열어 준다", "정상적으로 파일이 만들어진다", "컨테이너가 시작되지 않는다", "쓰기 오류가 나지만 `--tmpfs` 로도 해결할 수 없다"]', 0, '공격자가 파일을 심기 어렵게 하는 효과가 있습니다. 앱이 `/tmp` 등에 써야 한다면 `--tmpfs /tmp` 로 그 경로만 쓸 수 있게 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 8, '--cap-drop ALL', '`docker run --cap-drop ALL alpine sh -c ''chown 1234 /etc/hostname''` 은 어떻게 될까요?', '리눅스의 세부 권한(capability)을 모두 뺐어요.', NULL, NULL, '[]', 'choice', '["기본과 똑같이 성공한다", "컨테이너가 삭제된다", "호스트의 파일이 바뀐다", "`chown: ... Operation not permitted` 오류가 난다. 기본으로는 허용되던 특권 동작이 막히고, 필요한 권한만 `--cap-add` 로 다시 준다"]', 3, '컨테이너 안의 root 도 기본으로 일부 특권을 갖습니다. 필요 없는 권한을 빼는 것이 최소 권한 원칙이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 9, '--privileged 의 위험', '`docker run --privileged` 가 위험한 이유로 알맞은 것은 무엇일까요?', '컨테이너와 호스트 사이의 경계가 크게 약해져요.', NULL, NULL, '[]', 'choice', '["컨테이너가 더 빨라지기 때문이다", "이미지가 삭제되기 때문이다", "호스트의 장치와 거의 모든 권한에 접근할 수 있어 (예: `/dev` 항목이 15개에서 191개로 늘어난다) 컨테이너가 침해되면 호스트까지 위험해진다", "네트워크가 끊기기 때문이다"]', 2, '꼭 필요한 특수한 경우(예: 컨테이너 안에서 도커 실행) 외에는 쓰지 마세요. 필요한 권한만 `--cap-add` 로 주는 편이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 10, 'no-new-privileges', '`--security-opt no-new-privileges` 의 목적으로 알맞은 것은 무엇일까요?', '실행 중에 권한이 더 올라가는 것을 막아요.', NULL, NULL, '[]', 'choice', '["컨테이너가 사용자 계정을 만들지 못하게 한다", "컨테이너 안의 프로세스가 실행 중에 (예: setuid 프로그램으로) 더 높은 권한을 얻지 못하게 막는다", "이미지를 새로 받지 못하게 한다", "네트워크 접속을 막는다"]', 1, '권한을 낮춘 컨테이너에서 권한 상승 경로를 줄이는 보조 장치입니다. `--user` 와 `--cap-drop` 과 함께 쓰는 경우가 흔해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 11, 'docker diff', '`docker diff 컨테이너` 의 출력에서 `A`, `C`, `D` 는 각각 무엇일까요?', '이미지와 비교해 바뀐 점이에요.', NULL, NULL, '[]', 'choice', '["`A` 는 추가(Added), `C` 는 변경(Changed), `D` 는 삭제(Deleted) 된 파일이나 폴더", "`A` 는 접근, `C` 는 복사, `D` 는 다운로드", "`A` 는 활성, `C` 는 완료, `D` 는 중단", "셋 모두 같은 뜻이다"]', 0, '컨테이너 안에서 앱이 어떤 파일을 만들고 고치는지 확인할 때 씁니다. 그 내용을 유지해야 한다면 이미지나 볼륨에 반영해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 12, 'docker top', '`docker top 컨테이너` 는 무엇을 보여 줄까요?', '컨테이너 안에서 도는 일들의 목록이에요.', NULL, NULL, '[]', 'choice', '["컨테이너의 CPU 사용률 그래프", "컨테이너의 이미지 목록", "컨테이너의 로그", "컨테이너 안에서 실행 중인 프로세스의 목록 (UID, PID, 명령 등)"]', 3, '`docker stats` 는 자원 사용량, `docker top` 은 프로세스 목록입니다. 컨테이너 안에 뜻하지 않은 프로세스가 있는지 볼 때 유용해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 13, '레지스트리 주소가 들어간 이름', '로컬 레지스트리(`localhost:5055`)에 이미지를 올리려면 이름을 어떻게 만들어야 할까요?', '어디로 보낼지가 이름 앞에 들어가요.', NULL, NULL, '[]', 'choice', '["`docker push alpine` 만 하면 로컬 레지스트리로 올라간다", "`localhost` 만 앞에 붙이면 된다", "`docker tag alpine localhost:5055/etudev/alpine:1` 처럼 이름 앞에 `호스트:포트` 를 붙이고 그 이름으로 `docker push` 한다", "레지스트리 주소는 이름이 아니라 `docker login` 에만 필요하다"]', 2, '푸시한 뒤 `curl localhost:5055/v2/_catalog` 로 올라간 저장소 목록을 볼 수 있습니다. 주소가 없는 이름은 기본 레지스트리를 가리켜요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 14, '태그와 digest', '같은 태그 `app:1` 에 다른 이미지를 다시 push 했습니다. 태그와 digest 에 대한 설명으로 알맞은 것은 무엇일까요?', '하나는 움직일 수 있는 이름, 하나는 내용을 가리키는 지문이에요.', NULL, NULL, '[]', 'choice', '["태그가 같으면 이미지 내용도 항상 같다", "태그는 다른 이미지로 옮겨 갈 수 있는 이름이라 이전과 digest 가 달라진다. `app@sha256:...` 처럼 digest 로 지정하면 항상 같은 내용을 가리킨다", "digest 는 태그가 바뀌면 함께 바뀐다", "digest 는 도커 허브에서만 쓸 수 있다"]', 1, '배포를 재현해야 한다면 태그가 아니라 digest 로 고정하세요. `docker images --digests` 로 digest 를 볼 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 15, '실행 사용자 정하기', '컨테이너를 **UID 1000 으로** 실행하는 옵션 이름을 채우세요.', '"사용자"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["user", "uid", "as", "run-as"]', NULL, '`id -u` 가 `1000` 으로 나오는지 확인합니다. 이미지에 `USER` 를 넣는 방법과 같은 효과를 실행할 때 정하는 거예요.', '[0]', 'docker run --{0} 1000 alpine id -u', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 16, '쓰기 금지로 실행', '컨테이너의 **루트 파일 시스템을 읽기 전용**으로 만드는 옵션 이름을 채우세요.', '"읽기"와 "전용"을 하이픈으로 이어요.', NULL, NULL, '[]', 'fill', '["read-only", "readonly", "ro", "no-write"]', NULL, '쓰기를 하면 `Read-only file system` 오류가 납니다. 앱이 써야 하는 곳은 따로 열어 줘야 해요.', '[0]', 'docker run --{0} alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 17, '임시 쓰기 공간 열기', '읽기 전용 컨테이너에서 `/tmp` **만 쓸 수 있게** 하는 옵션 이름을 채우세요.', '메모리 기반 임시 파일 시스템의 이름이에요.', NULL, NULL, '[]', 'fill', '["tmpfs", "tmp", "scratch", "temp"]', NULL, '`--tmpfs` 로 만든 경로는 컨테이너가 끝나면 사라집니다. 영구 저장이 필요하면 볼륨을 쓰세요.', '[0]', 'docker run --read-only --{0} /tmp alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 18, '권한 빼기', '컨테이너의 **리눅스 capability 를 모두 제거**하는 옵션의 빈칸을 채우세요.', '"떨어뜨리다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["drop", "remove", "off", "deny"]', NULL, '필요한 권한만 `--cap-add` 로 하나씩 다시 줍니다. 모두 제거한 채로 앱이 동작하는지 먼저 확인해 보세요.', '[0]', 'docker run --cap-{0} ALL alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 19, '필요한 권한만 주기', '`NET_ADMIN` capability **하나만** 다시 추가하는 옵션의 빈칸을 채우세요.', '"더하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["add", "grant", "allow", "give"]', NULL, '`--cap-drop ALL` 로 모두 뺀 뒤 필요한 것만 `--cap-add` 하는 것이 최소 권한 방식입니다.', '[0]', 'docker run --cap-drop ALL --cap-{0} NET_ADMIN alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 20, '달라진 파일 보기', '컨테이너 `web` 이 **이미지와 비교해 바꾼 파일**을 보는 명령입니다. 빈칸을 채우세요.', '"차이"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["diff", "changes", "status", "compare"]', NULL, '`A`(추가), `C`(변경), `D`(삭제) 로 표시됩니다. 컨테이너가 불필요하게 많은 파일을 쓰는지 볼 수 있어요.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 21, '컨테이너 안의 프로세스', '컨테이너 `web` 안에서 **실행 중인 프로세스**를 보는 명령입니다. 빈칸을 채우세요.', '리눅스의 프로세스 상위 목록 명령과 같은 이름이에요.', NULL, NULL, '[]', 'fill', '["top", "ps", "procs", "tasks"]', NULL, '`docker ps` 는 컨테이너 목록이고 `docker top` 은 한 컨테이너 안의 프로세스입니다. 혼동하지 마세요.', '[0]', 'docker {0} web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 22, '레지스트리 주소 붙이기', '이미지 이름 앞에 **로컬 레지스트리의 주소**를 붙여 태그를 만들려고 합니다. 주소를 채우세요.', '호스트와 포트를 함께 써요.', NULL, NULL, '[]', 'fill', '["localhost:5055", "localhost", "5055", "http://localhost:5055"]', NULL, '`http://` 는 이름에 쓰지 않습니다. 포트가 있다면 `호스트:포트` 모양으로 써요.', '[0]', 'docker tag alpine {0}/etudev/alpine:1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 23, 'digest 로 받기', '이미지를 **내용(digest)으로 지정해 받을** 때 이름과 digest 를 잇는 기호를 채우세요.', '골뱅이 모양의 기호예요.', NULL, NULL, '[]', 'fill', '["@", ":", "#", "/"]', NULL, '`이름@sha256:...` 모양입니다. `:` 는 태그를 잇는 기호라 digest 에는 쓰지 않아요.', '[0]', 'docker pull alpine{0}sha256:0123abcd', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 24, 'OOM 여부 확인', '컨테이너가 **메모리 부족으로 종료됐는지** 확인하는 값의 이름을 채우세요.', '"메모리 부족으로 죽임"을 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["OOMKilled", "OutOfMemory", "MemoryKilled", "Killed"]', NULL, '`true` 이면 메모리 한도 때문에 종료된 것입니다. 종료 코드 137 만으로는 확정할 수 없어요.', '[0]', 'docker inspect -f ''{{.State.{0}}}'' web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 25, '최근 로그만 보기', '컨테이너 `web` 의 로그 중 **최근 10분 동안의 것만** 보는 옵션을 채우세요.', '"~이후로"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--since", "--after", "--from", "--last"]', NULL, '`--tail 20` 은 마지막 줄 수, `--since` 는 시간 범위로 거릅니다. 문제가 생긴 시각을 알 때 편해요.', '[0]', 'docker logs {0} 10m web', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 26, '바로 종료되는 컨테이너 조사', '컨테이너가 시작하자마자 종료될 때 종료 코드로 원인을 좁히는 순서입니다. 순서에 맞게 놓아 보세요.', '종료 확인 → 코드 읽기 → 로그 → 고치기 순서예요.', NULL, NULL, '[]', 'order', '["`docker ps -a` 로 `Exited (코드)` 를 확인한다", "코드를 읽는다 (127 명령 없음, 126 실행 불가, 137 강제 종료, 앱이 정한 값 등)", "`docker logs 이름` 으로 종료 직전의 출력을 본다", "원인(명령 경로, 권한, 환경 변수 등)을 고쳐 다시 실행한다"]', NULL, '137 이면 `OOMKilled` 도 `docker inspect` 로 함께 확인하세요. 코드 하나로 원인을 확정하지 마세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 27, '비root 와 읽기 전용으로 단계적으로 강화', '컨테이너를 단계적으로 안전하게 만드는 순서입니다. 순서에 맞게 놓아 보세요.', '정상 확인 → 사용자 → 읽기 전용 → 필요한 곳만 열기 순서예요.', NULL, NULL, '[]', 'order', '["평소 옵션으로 실행해 앱이 정상 동작하는지 먼저 확인한다", "`--user 1000` 을 추가해 일반 사용자로도 동작하는지 확인한다", "`--read-only` 를 추가하고 쓰기 오류가 나는 경로를 로그에서 찾는다", "그 경로만 `--tmpfs` 나 볼륨으로 열어 다시 실행해 확인한다"]', NULL, '한 번에 모두 적용하면 어떤 옵션이 문제인지 알기 어렵습니다. 하나씩 더하며 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 28, '로컬 레지스트리에 이미지 올리기', '임시 로컬 레지스트리에 이미지를 올리고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '레지스트리 실행 → 이름 붙이기 → 올리기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d -p 5055:5000 registry:2` 로 레지스트리를 띄운다", "`docker tag alpine localhost:5055/etudev/alpine:1` 로 레지스트리 주소가 든 이름을 붙인다", "`docker push localhost:5055/etudev/alpine:1` 로 올린다", "`curl localhost:5055/v2/_catalog` 로 올라간 저장소 목록을 확인한다"]', NULL, '실습이 끝나면 레지스트리 컨테이너와 이미지를 지워 정리하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 160, 29, '컨테이너 안에서 바뀐 것 살펴보기', '컨테이너가 안에서 무엇을 하는지 살펴보는 순서입니다. 순서에 맞게 놓아 보세요.', '파일 → 프로세스 → 로그 → 반영 순서예요.', NULL, NULL, '[]', 'order', '["`docker diff 이름` 으로 이미지와 달라진 파일(A, C, D)을 본다", "`docker top 이름` 으로 컨테이너 안에서 도는 프로세스를 본다", "`docker logs --since 10m 이름` 으로 최근 로그를 본다", "남겨야 하는 변경은 Dockerfile 이나 볼륨으로 옮겨 반영한다"]', NULL, '컨테이너 안에서 바뀐 파일은 컨테이너를 지우면 사라집니다. 지속해야 하는 데이터는 볼륨으로 빼 두세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 160 AND order_index = 29);
