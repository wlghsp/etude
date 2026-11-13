# 명세 — SQL 테이블과 제약 손연습 세트 (CREATE TABLE · 제약 · ALTER TABLE · DROP/TRUNCATE)

> 상태: **구현 중(로컬)** (2026-11-13). 세트 371, 데이터베이스 분야 `SQL 기초` 단원(id 30) 끝(세트 369 뒤), 아이콘 🏗️, 샌드박스 `linux-db`. 근거: 조회(366)·변경(367)·인덱스(369)에 이어 "테이블 만들기와 제약". 사용자가 콘텐츠 세트를 알아서 이어 가라고 위임했다(2026-11-13).

## 목표

`shop` 에서 "CREATE TABLE → DESCRIBE → NOT NULL 위반 → 기본값 컬럼 추가 → AUTO_INCREMENT → FOREIGN KEY → AFTER 위치 → DROP COLUMN → DROP/TRUNCATE TABLE" 을 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1. setup 은 `shop`(customers 3명, 빈 tmp_old, logs 3행)을 새로 만든다.
- 배경은 문제 안에 적는다(1번에 테이블·제약 개념과 시작 상태, 6번에 외래 키 개념).
- 채점은 `information_schema`(컬럼 순서·키·NULL 허용·extra, 참조 제약)와 테이블 상태, 오류 메시지 파일(`2>`)을 직접 본다.
- 한계: 같은 구조를 만드는 다른 문장도 통과한다. 자료형 길이는 채점하지 않는다.
- 문서 링크: mariadb.com/kb 의 create-table·alter-table·foreign-keys·auto_increment·describe·drop-table·truncate-table (200 확인).

## 수용 조건

- [ ] 터미널 9문제 모두 solution 으로 채점 통과 (`verify:quests -- --set 371`).
- [ ] `check-content.sh`, `check-migrations.sh` 통과, 단원 30 끝에 배치.
- [ ] 화면: 단원 `SQL 기초` 끝에 보이고 배경 설명이 읽기 좋게 보인다 (수동 확인).
