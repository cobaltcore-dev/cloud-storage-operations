{{- if not .Values.prometheusRules.ruleGroups.generic }}
groups: []
{{- else }}
groups:
- name: generic
  rules:
{{- if not (.Values.prometheusRules.disabled.CephDaemonCrash | default false) }}
  - alert: CephDaemonCrash
    expr: ceph_health_detail{name="RECENT_CRASH"} == 1
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.1.2"
      severity: critical
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "One or more daemons have crashed recently, and need to be acknowledged. This notification ensures that software crashes do not go unseen. To acknowledge a crash, use the 'ceph crash archive <id>' command."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks/#recent-crash"
      summary: "One or more Ceph daemons have crashed, and are pending acknowledgement"
{{- end }}
{{- end }}
