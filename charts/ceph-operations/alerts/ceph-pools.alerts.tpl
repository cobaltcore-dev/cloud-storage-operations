{{- if not .Values.prometheusRules.ruleGroups.pools }}
groups: []
{{- else }}
groups:
- name: pools
  rules:
{{- if not (.Values.prometheusRules.disabled.CephPoolBackfillFull | default false) }}
  - alert: CephPoolBackfillFull
    expr: ceph_health_detail{name="POOL_BACKFILLFULL"} > 0
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "A pool is approaching the near full threshold, which will prevent recovery/backfill operations from completing. Consider adding more capacity."
      summary: "Free space in a pool is too low for recovery/backfill"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPoolFull | default false) }}
  - alert: CephPoolFull
    expr: ceph_health_detail{name="POOL_FULL"} > 0
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.9.1"
      severity: critical
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        A pool has reached its MAX quota, or OSDs supporting the pool have reached the FULL threshold. Until this is resolved, writes to the pool will be blocked. Pool Breakdown (top 5) `{{`{{- range query \"topk(5, sort_desc(ceph_pool_percent_used * on(pool_id) group_right ceph_pool_metadata))\" }} - {{ .Labels.name }} at {{ .Value }}% {{- end }}`}}` Increase the pool's quota, or add capacity to the cluster first then increase the pool's quota (e.g. `ceph osd pool set quota <pool_name> max_bytes <bytes>`)
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pool-full"
      summary: "Pool is full - writes are blocked"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPoolNearFull | default false) }}
  - alert: CephPoolNearFull
    expr: ceph_health_detail{name="POOL_NEAR_FULL"} > 0
    for: 5m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        A pool has exceeded the warning (percent full) threshold, or OSDs supporting the pool have reached the NEARFULL threshold. Writes may continue, but you are at risk of the pool going read-only if more capacity isn't made available. Determine the affected pool with `ceph df detail`, looking at QUOTA BYTES and STORED. Increase the pool's quota, or add capacity to the cluster first then increase the pool's quota (e.g. `ceph osd pool set quota <pool_name> max_bytes <bytes>`). Also ensure that the balancer is active.
      summary: "One or more Ceph pools are nearly full"
{{- end }}
{{- end }}
