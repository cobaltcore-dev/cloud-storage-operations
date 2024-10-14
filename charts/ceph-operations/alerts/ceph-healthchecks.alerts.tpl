{{- if not .Values.prometheusRules.ruleGroups.healthChecks }}
groups: []
{{- else -}}
groups:
- name: healthchecks
  rules:
{{- if not (.Values.prometheusRules.disabled.CephSlowOps | default false) }}
  - alert: CephSlowOps
    expr: ceph_healthcheck_slow_ops > 0
    for: 30s
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "`{{`{{ $value }}`}}` OSD requests are taking too long to process (osd_op_complaint_time exceeded)"
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#slow-ops"
      summary: "OSD operations are slow to complete"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephDaemonSlowOps | default false) }}
  - alert: CephDaemonSlowOps
    for: 30s
    expr: ceph_daemon_health_metrics{type="SLOW_OPS"} > 0
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      summary: "`{{`{{ $labels.ceph_daemon }}`}}` operations are slow to complete"
      description: "`{{`{{ $labels.ceph_daemon }}`}}` operations are taking too long to process (complaint time exceeded)"
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#slow-ops"
{{- end }}
{{- end }}
