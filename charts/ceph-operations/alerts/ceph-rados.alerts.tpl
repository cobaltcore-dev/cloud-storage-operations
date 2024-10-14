{{- if not .Values.prometheusRules.ruleGroups.rados }}
groups: []
{{- else -}}
groups:
- name: rados
  rules:
{{- if not (.Values.prometheusRules.disabled.CephObjectMissing | default false) }}
  - alert: CephObjectMissing
    expr: (ceph_health_detail{name="OBJECT_UNFOUND"} == 1) * on() (count(ceph_osd_up == 1) == bool count(ceph_osd_metadata)) == 1
    for: 30s
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.10.1"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: 
        The latest version of a RADOS object can not be found, even though all OSDs are up. I/O requests for this object from clients will block (hang). Resolving this issue may require the object to be rolled back to a prior version manually, and manually verified.
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#object-unfound"
      summary: "Object(s) marked UNFOUND"
{{- end }}
{{- end }}
