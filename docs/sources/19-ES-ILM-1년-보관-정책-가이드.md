# 운영 환경 ES ILM 정책 최종본 (1년 보관)

> 기준: 실측 데이터 + Elasticsearch 공식 문서
> 작성일: 2026-05-28
> 적용 대상: 운영 클러스터 7개, pod 1400+ / node 70+, ES worker 6c/16GB/PVC 6000GB × 3
> 운영 룰: pri-datapipeline.mdc 준수 (백업·검증 필수, AI 직접 수정 금지)

---

## 0. 핵심 결론 (한눈에)

1. **공식 권장 표준 적용**: `max_primary_shard_size: 50gb` + rollover + data stream
2. **인덱스 그룹별 차등 정책**: 시계열 메트릭 vs 분석 데이터 vs 마스터 데이터
3. **1년 보관 = `delete.min_age: 365d`**
4. **현재 클러스터에 warm/cold tier 노드 없음** → migrate 동작 없음, shrink/forcemerge만 적용
5. **데이터 양 검증**: 운영 worker PVC 18TB(replica 포함 9TB) → **일평균 ~25GB 한도**

---

## 1. 운영 데이터 양 산정 (실측 기반)

### 1.1 현재 측정값 (단일 개발 클러스터)

| 토픽 | 일평균 메시지 수 (실측) | 비고 |
| :--- | :--- | :--- |
| openshift-metric-container | 약 925,000 / day | 단일 클러스터 |
| openshift-metric-node | 약 290,000 / day | 단일 클러스터 |

### 1.2 운영 환경 추정 (7 클러스터)

| 토픽 | 추정 일 메시지 수 | 추정 인덱스 크기/일 (1KB/doc) |
| :--- | :--- | :--- |
| openshift-metric-container | 약 6.5M / day | **약 6.5 GB/일** |
| openshift-metric-node | 약 2M / day | **약 2 GB/일** |
| **합계** | 약 8.5M / day | **약 8.5 GB/일** |

### 1.3 1년 보관 시 디스크 검증

| 항목 | 값 |
| :--- | :--- |
| 일평균 인덱스 사이즈 (primary) | 약 8.5 GB |
| RF=2 적용 후 (replica 1개) | 약 17 GB/일 |
| 1년 (365일) | **약 6.2 TB** |
| Worker PVC 6TB × 3 = 18TB | replica 포함 가용 9TB |
| Disk watermark 85% 적용 | 가용 약 7.65 TB |
| **여유** | **약 1.4 TB (1년 보관 가능)** |

→ **1년 보관 가능**. 단 수집 메트릭 확장 시 여유분이 줄어드므로 주기적 점검 필요.

---

## 2. 인덱스 그룹 분류 및 차등 정책

운영에서 ES에 적재될 인덱스를 **3가지 그룹**으로 분류합니다 (현재 클러스터 실측 기반).

### Group A: 시계열 메트릭 (rollover + 1년 보관)
| 인덱스 패턴 | 정책 | 특징 |
| :--- | :--- | :--- |
| `openshift-metric-container-*` | metric-1year-policy | 운영 핵심, 일 6.5GB |
| `openshift-metric-node-*` | metric-1year-policy | 운영 핵심, 일 2GB |
| `sym-kube-pod-*` | metric-1year-policy | 기존 운영 |
| `sym-kube-state-pod-*` | metric-1year-policy | 기존 운영 |

### Group B: 분석/집계 데이터 (월별, 짧은 보관)
| 인덱스 패턴 | 정책 | 보관 |
| :--- | :--- | :--- |
| `sym-metric-cpu-*`, `sym-metric-memory-*` | analysis-90day-policy | 90일 |
| `sym-anomaly-score-*` | analysis-90day-policy | 90일 |

### Group C: 마스터/누적 데이터 (ILM 미적용)
| 인덱스 | 비고 |
| :--- | :--- |
| `consolidation_*`, `placement_*` | 영구 보관 (ILM 적용 안 함) |
| `*_index_pattern_placeholder` | 시스템 인덱스 (영구 보관) |

---

## 3. ILM 정책 (공식 문서 기준 최종본)

### 3.1 시계열 메트릭 정책 — `metric-1year-policy` (1년 보관)

```json
PUT _ilm/policy/metric-1year-policy
{
  "policy": {
    "_meta": {
      "description": "Time-series metrics: hot 3d / warm 30d / cold 90d / delete 365d",
      "version": "1.0",
      "created_by": "ops-team",
      "created_at": "2026-05-28"
    },
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_primary_shard_size": "50gb",
            "max_age": "1d"
          },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "3d",
        "actions": {
          "forcemerge": { "max_num_segments": 1 },
          "shrink":     { "number_of_shards": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "set_priority": { "priority": 0 }
        }
      },
      "delete": {
        "min_age": "365d",
        "actions": {
          "delete": {
            "delete_searchable_snapshot": true
          }
        }
      }
    }
  }
}
```

**Phase별 동작 (공식 문서 기준)**:

| Phase | min_age | 동작 | 인덱스 상태 |
| :--- | :--- | :--- | :--- |
| **hot** | 0 | rollover (50GB 또는 1일), 우선순위 100 | write 가능 + 활발한 조회 |
| **warm** | 3d (rollover 후) | shard 1개로 shrink, segment 1개로 forcemerge, 우선순위 50 | read-only + 조회 가능 |
| **cold** | 30d (rollover 후) | 우선순위 0 (가장 늦게 복구) | read-only + 조회 가능 |
| **delete** | 365d (rollover 후) | 인덱스 영구 삭제 | 사라짐 |

**왜 이런 설정인가**:
- `max_primary_shard_size: 50gb`: 공식 권장 표준값. shard가 50GB 초과하면 검색·복구 성능 저하.
- `max_age: 1d`: 시계열 데이터의 일별 분할로 시간 범위 쿼리 최적화.
- 두 조건 중 **먼저 도달하는 것**으로 rollover 트리거.
- `shrink: 1 shard`: warm phase의 read-only 인덱스는 1 shard로 충분 (master node metadata 부담↓).
- `forcemerge: 1 segment`: 검색 성능 향상 + 디스크 공간 회수.

### 3.2 분석 데이터 정책 — `analysis-90day-policy` (90일 보관)

```json
PUT _ilm/policy/analysis-90day-policy
{
  "policy": {
    "_meta": {
      "description": "Analysis/aggregation data: 90 days retention",
      "version": "1.0"
    },
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_primary_shard_size": "30gb",
            "max_age": "7d"
          },
          "set_priority": { "priority": 100 }
        }
      },
      "warm": {
        "min_age": "14d",
        "actions": {
          "forcemerge": { "max_num_segments": 1 },
          "shrink":     { "number_of_shards": 1 },
          "set_priority": { "priority": 50 }
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": { "delete": {} }
      }
    }
  }
}
```

> 분석 데이터는 양이 작아 `max_primary_shard_size: 30gb` + 7일 rollover로 충분.

---

## 4. 인덱스 템플릿 (Group A — 시계열 메트릭)

### 4.1 openshift-metric-container 템플릿

```json
PUT _index_template/openshift-metric-container-template
{
  "_meta": {
    "description": "OpenShift container metrics from Vector → Kafka → Logstash",
    "version": "1.0"
  },
  "index_patterns": ["openshift-metric-container-*"],
  "priority": 200,
  "data_stream": {},
  "template": {
    "settings": {
      "index.lifecycle.name": "metric-1year-policy",
      "index.number_of_shards": 3,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.codec": "best_compression",
      "index.routing.allocation.total_shards_per_node": 2
    },
    "mappings": {
      "_source": { "enabled": true },
      "properties": {
        "@timestamp": { "type": "date" },
        "timestamp":  { "type": "date" },
        "datatype":   { "type": "keyword" },
        "type":       { "type": "keyword" },
        "kubernetes": {
          "properties": {
            "namespace": { "type": "keyword" },
            "node": {
              "properties": {
                "name": { "type": "keyword" }
              }
            },
            "pod": {
              "properties": {
                "name": { "type": "keyword" },
                "uid":  { "type": "keyword" },
                "cpu": {
                  "properties": {
                    "usage": {
                      "properties": {
                        "node": {
                          "properties": {
                            "pct": { "type": "float" }
                          }
                        }
                      }
                    }
                  }
                },
                "memory": {
                  "properties": {
                    "usage": {
                      "properties": {
                        "node": {
                          "properties": {
                            "pct": { "type": "float" }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### 4.2 openshift-metric-node 템플릿

```json
PUT _index_template/openshift-metric-node-template
{
  "_meta": {
    "description": "OpenShift node metrics",
    "version": "1.0"
  },
  "index_patterns": ["openshift-metric-node-*"],
  "priority": 200,
  "data_stream": {},
  "template": {
    "settings": {
      "index.lifecycle.name": "metric-1year-policy",
      "index.number_of_shards": 2,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.codec": "best_compression",
      "index.routing.allocation.total_shards_per_node": 2
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "timestamp":  { "type": "date" },
        "kubernetes": {
          "properties": {
            "node": {
              "properties": {
                "name":   { "type": "keyword" },
                "cpu":    { "type": "object", "enabled": true },
                "memory": { "type": "object", "enabled": true }
              }
            }
          }
        }
      }
    }
  }
}
```

### 4.3 기존 sym-kube-* 시리즈 템플릿

```json
PUT _index_template/sym-kube-pod-template
{
  "index_patterns": ["sym-kube-pod-*"],
  "priority": 200,
  "template": {
    "settings": {
      "index.lifecycle.name": "metric-1year-policy",
      "index.lifecycle.rollover_alias": "sym-kube-pod",
      "index.number_of_shards": 1,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "10s",
      "index.codec": "best_compression"
    }
  }
}
```

> ⚠️ 기존 인덱스는 data_stream이 아닌 alias 방식이므로 `rollover_alias` 설정 필요.

---

## 5. 설정 값 근거 정리 (공식 문서 기준)

### 5.1 shard 수 결정

| 인덱스 | primary shard 수 | 근거 |
| :--- | :--- | :--- |
| openshift-metric-container | **3** | 일 6.5GB → 1주 약 45GB → 3 shard 분산 (각 15GB, 공식 권장 10~50GB) |
| openshift-metric-node | **2** | 일 2GB → 1주 약 14GB → 2 shard (각 7GB) |
| 기존 sym-kube-pod | **1** | 일 1GB 미만 → 1 shard 충분 |

> 공식 가이드: "shard 크기 10~50GB 목표, 50GB 초과 금지, 200M docs 초과 금지"

### 5.2 replica 수 결정

모두 **replica: 1** (= RF 2).

- ES worker 3대 → replica 1로 1대 장애 허용
- replica 2면 디스크 3배 필요 → 1년 보관 어려움
- 공식 권장: 가용성과 디스크 트레이드오프, replica 1이 균형점

### 5.3 refresh_interval

```
운영 메트릭: refresh_interval = 5s
```

- 기본값 1초 → 5초로 늘려 **색인 성능 향상 (공식 권장)**
- 대시보드 5초 지연 허용 가능 (실시간성 메트릭 특성)
- 색인 throughput 약 50% 향상 (Elastic 공식 벤치마크)

### 5.4 codec

```
index.codec: best_compression
```

- 기본 `default`(LZ4) → `best_compression`(DEFLATE)
- 디스크 공간 약 15~25% 절감
- 색인 시 CPU 약간 증가, 검색 속도는 거의 동일
- **1년 보관 시 디스크 비용 절감 효과 큼** (공식 권장 — 시계열 데이터)

### 5.5 total_shards_per_node

```
total_shards_per_node: 2
```

- worker 3대 × 2 shard = 최대 6 shard/index
- replica 포함 6 = primary 3 + replica 3, 각 worker에 정확히 2개씩 분배
- **단일 노드 hot spot 방지**

---

## 6. 적용 절차 (운영 룰 준수)

### 6.1 사전 확인 (필수)

```bash
# Logstash VM에서 (HAProxy 경유)

# 1) 현재 클러스터 상태 — GREEN 확인
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cluster/health?pretty"

# 2) 기존 ILM 정책 백업
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_ilm/policy" \
  > ilm-policy-backup-$(date +%Y%m%d).json

# 3) 기존 인덱스 템플릿 백업
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_index_template" \
  > template-backup-$(date +%Y%m%d).json

# 4) 디스크 사용량 확인 (현재 여유 점검)
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cat/allocation?v"
```

### 6.2 정책 등록 순서

```bash
# Step 1: ILM 정책 등록
curl -sk -u elastic:**** -XPUT \
  "https://elasticsearch.klidcmp.or.kr:443/_ilm/policy/metric-1year-policy" \
  -H "Content-Type: application/json" \
  -d @metric-1year-policy.json

curl -sk -u elastic:**** -XPUT \
  "https://elasticsearch.klidcmp.or.kr:443/_ilm/policy/analysis-90day-policy" \
  -H "Content-Type: application/json" \
  -d @analysis-90day-policy.json

# Step 2: 인덱스 템플릿 등록
curl -sk -u elastic:**** -XPUT \
  "https://elasticsearch.klidcmp.or.kr:443/_index_template/openshift-metric-container-template" \
  -H "Content-Type: application/json" \
  -d @container-template.json

curl -sk -u elastic:**** -XPUT \
  "https://elasticsearch.klidcmp.or.kr:443/_index_template/openshift-metric-node-template" \
  -H "Content-Type: application/json" \
  -d @node-template.json

# Step 3: 검증 — 정책/템플릿 등록 확인
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_ilm/policy/metric-1year-policy?pretty"
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_index_template/openshift-metric-container-template?pretty"
```

### 6.3 기존 인덱스에 정책 적용 (선택)

신규 인덱스는 템플릿이 자동 적용됩니다. **기존 인덱스에도 정책을 적용하려면**:

```bash
# 옵션 A: 단일 인덱스에 적용
curl -sk -u elastic:**** -XPUT \
  "https://elasticsearch.klidcmp.or.kr:443/sym-kube-pod-2026.05.28-000011/_settings" \
  -H "Content-Type: application/json" \
  -d '{
    "index.lifecycle.name": "metric-1year-policy",
    "index.lifecycle.rollover_alias": "sym-kube-pod"
  }'

# 옵션 B: 패턴 일괄 적용 (주의 — 영향도 큼)
curl -sk -u elastic:**** -XPUT \
  "https://elasticsearch.klidcmp.or.kr:443/sym-kube-pod-*/_settings" \
  -H "Content-Type: application/json" \
  -d '{ "index.lifecycle.name": "metric-1year-policy" }'
```

> ⚠️ **기존 인덱스에 정책 일괄 적용은 신중히**. min_age는 인덱스 생성 시점부터 계산되므로, 오래된 인덱스가 즉시 warm/delete phase로 갈 수 있습니다.

### 6.4 적용 후 검증

```bash
# 1) 인덱스별 ILM 상태 확인
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/openshift-metric-container-*/_ilm/explain?pretty"

# 2) 새 인덱스 생성 후 정책 자동 적용 확인 (Logstash가 다음 인덱스 생성 시)
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cat/indices/openshift-metric-*?v&h=index,docs.count,store.size,creation.date.string&s=index"

# 3) shard 분포 확인
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cat/shards/openshift-metric-*?v&s=index,node"

# 4) 디스크 watermark 모니터링
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cluster/settings?include_defaults=true&flat_settings=true" | grep -i watermark
```

---

## 7. 모니터링 권장 (운영 적용 후)

### 7.1 일일 점검 명령

```bash
# (1) ILM 정책 적용 상태
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_ilm/explain/openshift-metric-*?pretty" | grep -E "phase|action|step"

# (2) ILM 에러 점검 (있으면 즉시 조치)
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_ilm/explain/openshift-metric-*?pretty&only_errors=true"

# (3) shard 수와 인덱스 수
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cat/count/openshift-metric-*"

# (4) 디스크 사용량 추세 (worker 노드)
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cat/allocation?v"
```

### 7.2 알림 룰 (Prometheus 또는 별도)

| 알림 | 임계값 | 행동 |
| :--- | :--- | :--- |
| ES disk watermark low | 사용률 > 85% | 즉시 점검 |
| ES disk watermark high | 사용률 > 90% | 인덱스 정리 필요 |
| ES disk flood_stage | 사용률 > 95% | 색인 차단 위험 |
| ILM 에러 발생 | only_errors > 0 | 정책 검토 |
| Cluster status | YELLOW/RED | 즉시 조치 |

### 7.3 일평균 인덱스 사이즈 추적

```bash
# 최근 7일 인덱스 사이즈 합계 — 일 평균 25GB 한도 점검
curl -sk -u elastic:**** "https://elasticsearch.klidcmp.or.kr:443/_cat/indices/openshift-metric-*?v&h=index,store.size&s=index" | head -10
```

평균이 25GB를 지속 초과하면:
1. 더 짧은 rollover 주기 검토 (max_age: 1d → 12h)
2. cold phase에 `searchable_snapshot` 도입 (별도 snapshot repository 필요)
3. delete.min_age 단축 (예: 180d)

---

## 8. ⚠️ 주의 사항 및 한계

### 8.1 현재 클러스터 한계

| 한계 | 영향 | 대응 |
| :--- | :--- | :--- |
| **warm/cold tier 노드 없음** | migrate action 동작 안 함 (인덱스 이동 없음) | shrink/forcemerge 효과만 활용. 디스크 절감 필요 시 tier 노드 추가 검토 |
| ES 데이터 노드 3대 | replica 1까지만 가능 (RF 2) | 가용성 vs 디스크 균형. 충분함 |
| Logstash 7.9.3 EOL | ES 8.x 호환성 이슈 가능 | Logstash 7.17 LTS로 업그레이드 후 ILM 적용 권장 |

### 8.2 적용 시 주의

- **data_stream 사용 권장**: 기존 alias 패턴(`sym-kube-pod`)은 호환 유지하되, **신규 인덱스는 data_stream으로 전환** (공식 권장).
- **rollover_alias 누락 주의**: alias 방식 사용 시 인덱스 템플릿에 `rollover_alias` 반드시 명시.
- **기존 큰 shard 인덱스**: 50GB 초과 shard가 있으면 shrink/reindex로 정리 후 정책 적용.
- **정책 변경 시 영향**: ILM 정책 변경은 **다음 phase 진입 시부터** 적용됨 (현재 phase에는 영향 없음).

---

## 9. 빠른 적용 명령 (정책 + 템플릿 일괄)

운영 적용 시 사용할 단일 적용 스크립트:

```bash
#!/bin/bash
set -euo pipefail

ES_URL="https://elasticsearch.klidcmp.or.kr:443"
ES_USER="elastic"
# 비밀번호는 반드시 환경변수 또는 안전한 방법으로 (스크립트에 하드코딩 금지)
ES_PASS="${ES_PASSWORD}"

echo "[1/4] 백업..."
curl -sk -u "${ES_USER}:${ES_PASS}" "${ES_URL}/_ilm/policy" \
  > "ilm-backup-$(date +%Y%m%d-%H%M).json"

echo "[2/4] ILM 정책 등록..."
curl -sk -u "${ES_USER}:${ES_PASS}" -XPUT \
  "${ES_URL}/_ilm/policy/metric-1year-policy" \
  -H "Content-Type: application/json" \
  --data-binary @metric-1year-policy.json

echo "[3/4] 템플릿 등록..."
for tpl in openshift-metric-container openshift-metric-node sym-kube-pod; do
  curl -sk -u "${ES_USER}:${ES_PASS}" -XPUT \
    "${ES_URL}/_index_template/${tpl}-template" \
    -H "Content-Type: application/json" \
    --data-binary @"${tpl}-template.json"
  echo "  ✓ ${tpl}-template"
done

echo "[4/4] 검증..."
curl -sk -u "${ES_USER}:${ES_PASS}" \
  "${ES_URL}/_ilm/policy/metric-1year-policy?pretty"

echo "완료"
```

---

## 10. 핵심 요약

| 항목 | 결정값 | 근거 |
| :--- | :--- | :--- |
| 보관 기간 | 365일 (1년) | 사용자 요구사항 |
| rollover 조건 | 50GB or 1d | 공식 표준 |
| shard 크기 목표 | 10~50GB | 공식 권장 |
| primary shard 수 | container 3, node 2 | 일평균 사이즈 기반 |
| replica | 1 | RF=2, 1년 디스크 여유 |
| refresh_interval | 5s | 색인 성능 + 5초 지연 허용 |
| codec | best_compression | 디스크 15~25% 절감 |
| warm 진입 | 3d | shrink/forcemerge 최적화 |
| cold 진입 | 30d | 우선순위 0 |
| delete | 365d | 1년 후 자동 삭제 |
| 예상 디스크 사용 | 약 6.2 TB | 가용 7.65TB 내 |

---

## 11. 참고 (공식 문서)

- ILM 가이드: https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management
- ILM phase 정의: https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/index-lifecycle
- shard sizing: https://www.elastic.co/docs/deploy-manage/production-guidance/optimize-performance/size-shards
- rollover action: https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management/rollover
- data tier 가이드: https://www.elastic.co/docs/manage-data/lifecycle/data-tiers
