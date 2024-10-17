{{- if not .Values.prometheusRules.ruleGroups.clusterHealth }}
groups: []
{{- else -}}
groups:
- name: cluster-health
  rules:
{{- if not (.Values.prometheusRules.disabled.CephHealthError | default false) }}
  - alert: CephHealthError
    expr: ceph_health_status == 2
    for: 5m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.2.1"
      severity: critical
      type: ceph_default
      inhibited_by: cluster-maintenance
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The cluster state has been HEALTH_ERROR for more than 5 minutes. Please check `ceph health detail` for more information."
      summary: "Ceph is in the ERROR state"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephHealthWarning | default false) }}
  - alert: CephHealthWarning
    expr: ceph_health_status == 1
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      inhibited_by: cluster-maintenance
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The cluster state has been HEALTH_WARN for more than 15 minutes. Please check `ceph health detail` for more information."
      summary: "Ceph is in the WARNING state"
{{- end }}
{{- end }}
