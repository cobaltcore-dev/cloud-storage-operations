{{- if not .Values.prometheusRules.ruleGroups.mon }}
groups: []
{{- else }}
groups:
- name: mon
  rules:
{{- if not (.Values.prometheusRules.disabled.CephMonDownQuorumAtRisk | default false) }}
  - alert: CephMonDownQuorumAtRisk
    expr: |
      (
        (ceph_health_detail{name="MON_DOWN"} == 1) * on() (
          count(ceph_mon_quorum_status == 1) == bool (floor(count(ceph_mon_metadata) / 2) + 1)
        )
      ) == 1
    for: 30s
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.3.1"
      severity: critical
      type: ceph_default
      inhibited_by: cluster-maintenance
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        {{`{{ $min := query \"floor(count(ceph_mon_metadata) / 2) + 1\" | first | value }}`}}Quorum requires a majority of monitors (x `{{`{{ $min }}`}}`) to be active. Without quorum the cluster will become inoperable, affecting all services and connected clients. The following monitors are down: `{{`{{- range query \"(ceph_mon_quorum_status == 0) + on(ceph_daemon) group_left(hostname) (ceph_mon_metadata * 0)\" }} - {{ .Labels.ceph_daemon }} on {{ .Labels.hostname }} {{- end }}`}}`
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#mon-down"
      summary: "Monitor quorum is at risk"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephMonDown | default false) }}
  - alert: CephMonDown
    expr: |
      count(ceph_mon_quorum_status == 0) <= (count(ceph_mon_metadata) - floor(count(ceph_mon_metadata) / 2) + 1)
    for: 30s
    labels:
      severity: warning
      type: ceph_default
      inhibited_by: cluster-maintenance
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        {{`{{ $down := query "count(ceph_mon_quorum_status == 0)" | first | value }}{{ $s := "" }}{{ if gt $down 1.0 }}{{ $s = "s" }}{{ end }}`}}You have `{{`{{ $down }}`}}` monitor `{{`{{ $s }}`}}` down. Quorum is still intact, but the loss of an additional monitor will make your cluster inoperable.  The following monitors are down: `{{`{{- range query "(ceph_mon_quorum_status == 0) + on(ceph_daemon) group_left(hostname) (ceph_mon_metadata * 0)" }}   - {{ .Labels.ceph_daemon }} on {{ .Labels.hostname }} {{- end }}`}}`
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#mon-down"
      summary: "One or more monitors down"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephMonDiskspaceCritical | default false) }}
  - alert: CephMonDiskspaceCritical
    expr: ceph_health_detail{name="MON_DISK_CRIT"} == 1
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.3.2"
      severity: critical
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        The free space available to a monitor's store is critically low. You should increase the space available to the monitor(s). The default directory is `/var/lib/ceph/mon-*/data/store.db` on traditional deployments, and `/var/lib/rook/mon-*/data/store.db` on the mon pod's worker node for Rook. Look for old, rotated versions of `*.log` and `MANIFEST*`. Do NOT touch any `*.sst` files. Also check any other directories under `/var/lib/rook` and other directories on the same filesystem, often `/var/log` and `/var/tmp` are culprits. Your monitor hosts are; `{{`{{- range query \"ceph_mon_metadata\"}} - {{ .Labels.hostname }} {{- end }}`}}`
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#mon-disk-crit"
      summary: "Filesystem space on at least one monitor is critically low"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephMonDiskspaceLow | default false) }}
  - alert: CephMonDiskspaceLow
    expr: ceph_health_detail{name="MON_DISK_LOW"} == 1
    for: 5m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        The space available to a monitor's store is approaching full (>70% is the default). You should increase the space available to the monitor(s). The default directory is `/var/lib/ceph/mon-*/data/store.db` on traditional deployments, and `/var/lib/rook/mon-*/data/store.db` on the mon pod's worker node for Rook. Look for old, rotated versions of `*.log` and `MANIFEST*`.  Do NOT touch any `*.sst` files. Also check any other directories under `/var/lib/rook` and other directories on the same filesystem, often `/var/log` and `/var/tmp` are culprits. Your monitor hosts are; `{{`{{- range query \"ceph_mon_metadata\"}} - {{ .Labels.hostname }} {{- end }}`}}`
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#mon-disk-low"
      summary: "Drive space on at least one monitor is approaching full"
  {{- end }}

{{- if not (.Values.prometheusRules.disabled.CephMonClockSkew | default false) }}
  - alert: CephMonClockSkew
    expr: ceph_health_detail{name="MON_CLOCK_SKEW"} == 1
    for: 1m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        Ceph monitors rely on closely synchronized time to maintain quorum and cluster consistency. This event indicates that the time on at least one mon has drifted too far from the lead mon. Review cluster status with ceph -s. This will show which monitors are affected. Check the time sync status on each monitor host with `ceph time-sync-status` and the state and peers of your ntpd or chrony daemon.
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#mon-clock-skew"
      summary: "Clock skew detected among monitors"
{{- end }}
{{- end }}
