# 명세 — 스토리지 3차 퀴즈 세트 398·399 (NFS)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). [spec_openstack_round6.md](spec_openstack_round6.md)의 Ceph 운영(393)에 이어 단원 21 끝에 NFS 두 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 398 | 21 (624) | NFS 서버 내보내기 | exports 표기(공백 금지), `exportfs -ra`, ro 기본, sync·async, root_squash(기본)·all_squash, 익명 uid 65534, no_subtree_check 기본, secure 포트(1024 미만), 내보내기 순서 |
| 399 | 21 (625) | NFS 클라이언트 마운트 | hard 기본(무기한 재시도), soft 의 조용한 손상 위험과 EIO, timeo(TCP 600 데시초), retrans(UDP 3·TCP 2), rsize·wsize 최대 1MB, nfsvers 4.2 부터 협상, noatime 무효, nolock, actimeo, 재시도 과정 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

man7.org 의 exports(5), nfs(5). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(26개) 통과, 스토리지 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- exports(5) 문서에서 `exportfs -v` 와 `-r`·`-a` 개별 설명은 확인되지 않아 `-ra` 로만 물었다. `_netdev` 는 nfs(5) 에 없어 뺐다.
- iSCSI(open-iscsi `iscsiadm`) 도 조사했으나 `node.startup` 키와 기본 포트 3260 설명이 문서마다 달라 이번 세트에서는 제외했다.
- 두 순서 문제(내보내기 절차, 재시도 과정)는 문서 설명을 이은 큰 줄기다. 샌드박스에서 NFS 를 실제로 띄우지 않으므로 퀴즈로만 다룬다.
