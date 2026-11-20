# 명세 — 세트 527 Redis 캐시 패턴 입문: Cache-Aside

> 상태: 작성 중 (2026-11-19). 선행: 세트 60(자료구조·TTL)·99(키 관리). 겹침 회피: 83(분산 락 해제·Lua)·102(상황집). `linux`, 데이터베이스, 단원 31, display_order 748. 생성: `scripts/content-gen/new_sets/set527.py`.

환경: 각 실습 setup 이 `redis-server --daemonize yes --save ''` 를 띄우고 `flushall` 한다. 원본 DB 는 `/tmp/origin_*.txt` 파일로 흉내 낸다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | Cache-Aside 에서 캐시는 애플리케이션이 채운다 | |
| 2 | 실습 | 미스 → 원본 조회 → `SET ... EX 300` | 값 일치, TTL 1~300 |
| 3 | 순서 | 읽기 순서(확인 → 조회 → 저장 → 응답) | |
| 4 | 빈칸 | `SETEX 키 초 값` | |
| 5 | 실습 | 값 갱신 시 TTL 유지(`KEEPTTL`/`EX`) | 값 1500, TTL 1~300 |
| 6 | 객관식 | 원본 변경 시 DB 갱신 후 캐시 `DEL` | |
| 7 | 객관식 | 캐시 스탬피드 개념 | |
| 8 | 실습 | `SET NX EX` 로 한 명만 재생성 | got=OK, 값·TTL, 락 해제 |
| 9 | 객관식 | TTL 무작위 편차(지터) | |
| 10 | 실습 | 세션 Hash + `EXPIRE` | hash, 필드 2개, TTL 1~1800 |
| 11 | 실습 | `MEMORY USAGE` 로 큰 키 찾기·`UNLINK` | big.txt=cart:big, 삭제, dbsize 51 |
| 12 | 객관식 | `--hotkeys` 는 LFU 정책 필요 | |

## 수용 조건

- [ ] `verify:quests --set 527` 실습 5개 모두 정답 통과·무행동 실패
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] `check-content.sh` 통과
