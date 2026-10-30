#!/usr/bin/env bash
# 콘텐츠 점검: 학습자가 막힐 만한 데이터 오류를 찾는다 (로컬 DB 컨테이너 etude-db 기준, 읽기 전용).
#   1) setup_cmd / grade_cmd 의 요소가 문자열이 아닌 문제 (예: ["sh","-c",null] 은 환경 준비를 깨뜨린다)
#   2) 터미널 세트의 객관식·형식 문제인데 설명이 `cd /폴더/하위폴더` 처럼 두 단계 이상 경로로 이동하라고 안내하면서 setup_cmd 가 없는 문제 (폴더가 없어 막힌다)
#   3) 객관식 정답 번호·순서/빈칸 정답 범위가 보기 수 밖인 문제
#   사용법: scripts/check-content.sh        # 문제가 있으면 목록을 보이고 종료 코드 1
set -euo pipefail
DB_CONTAINER="${DB_CONTAINER:-etude-db}"
sql() { docker exec -i "$DB_CONTAINER" sh -c 'mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" -N'; }
out="$(sql <<'SQL'
SELECT '1. 비문자열 요소가 든 명령', quest_set_id, order_index, title FROM quest
 WHERE (setup_cmd IS NOT NULL AND (JSON_TYPE(JSON_EXTRACT(setup_cmd,'$[0]'))='NULL' OR JSON_TYPE(JSON_EXTRACT(setup_cmd,'$[1]'))='NULL' OR JSON_TYPE(JSON_EXTRACT(setup_cmd,'$[2]'))='NULL'))
    OR (kind='terminal' AND (JSON_TYPE(JSON_EXTRACT(grade_cmd,'$[0]'))='NULL' OR JSON_TYPE(JSON_EXTRACT(grade_cmd,'$[1]'))='NULL' OR JSON_TYPE(JSON_EXTRACT(grade_cmd,'$[2]'))='NULL'))
UNION ALL
SELECT '2. 터미널을 안내하는데 환경(setup_cmd)이 없는 객관식·형식 문제', quest_set_id, order_index, title FROM quest
 WHERE kind <> 'terminal' AND setup_cmd IS NULL AND (description REGEXP 'cd /[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+')
   AND quest_set_id IN (SELECT id FROM quest_set WHERE sandbox_type <> 'quiz')
UNION ALL
SELECT '3. 객관식 정답 번호가 보기 수 밖', quest_set_id, order_index, title FROM quest
 WHERE kind = 'choice' AND (answer_index IS NULL OR answer_index < 0 OR answer_index >= JSON_LENGTH(choices))
UNION ALL
SELECT '3. 순서/빈칸 정답 범위가 보기 수 밖', quest_set_id, order_index, title FROM quest
 WHERE kind IN ('order','fill') AND (answer_spec IS NULL OR EXISTS (SELECT 1 FROM JSON_TABLE(answer_spec, '$[*]' COLUMNS (v INT PATH '$')) t WHERE t.v < 0 OR t.v >= JSON_LENGTH(quest.choices)));
SQL
)"
if [ -n "$out" ]; then echo "콘텐츠 점검에서 문제를 찾았습니다:"; echo "$out"; exit 1; fi
echo "OK: 콘텐츠 점검 통과 (비문자열 명령, 환경 없는 안내, 정답 범위)"
