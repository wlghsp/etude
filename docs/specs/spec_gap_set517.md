# 명세 — 세트 517 접근이 막힐 때 상황집: 권한 거부 vs 접속 거부 vs 시간 초과

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N17(S5·S6). `linux` 샌드박스, 리눅스, 단원 4, display_order 738. 선행: 세트 65(권한), 427(ACL 읽기).
> 환경 제약: Debian 계열이라 SELinux 없음. `getfacl`·`setfacl`·`iptables` 없음 → ACL·방화벽(timed out)은 개념 문제, 접속 거부는 로컬 perl 서버(`/opt/lab/web.pl 주소 포트`)로 재현. 일반 계정 시험은 `runuser -u nobody -- 명령`.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 소유자가 달라 Permission denied (모드 600 유지, chown) | nobody 읽기 + 모드 600 + 소유자 nobody |
| 2 | 실습 | 그 외 사용자 읽기 권한 없음 (chmod o+r) | nobody 읽기 + 소유자 root + 다른 사용자 쓰기 없음 |
| 3 | 실습 | 그룹 미소속 (usermod -aG) | nobody 읽기 + 그 외 권한 0 유지 |
| 4 | 실습 | 상위 디렉터리 x 권한 부족 (namei -l) | nobody 읽기 + 파일 644 유지 |
| 5 | 실습 | Connection refused: 서비스 안 떠 있음 (ss -ltn, 기동) | 8080 LISTEN + 응답 저장 |
| 6 | 실습 | 127.0.0.1 로만 바인드 → 0.0.0.0 | 서버 주소로 응답 |
| 7 | 실습 | 포트 틀림, ss 로 실제 포트 찾기 | 9091 응답 저장 |
| 8 | 실습 | refused vs timed out 로그 분류 (grep -l) | 분류 파일 2개 |
| 9 | 객관식 | ls -l 의 `+` = ACL | |
| 10 | 객관식 | timed out 원인 = 중간 방화벽 | |
| 11 | 빈칸 | `nc -z` | |
| 12 | 순서 | Connection refused 점검 순서 | |

## 수용 조건

- [ ] `verify:quests --set 517` 실습 8개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 형식 3종 이상(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] 정확성 점검 차단 없음
