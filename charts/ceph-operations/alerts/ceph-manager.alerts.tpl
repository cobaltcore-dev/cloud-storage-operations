{{- if not .Values.prometheusRules.ruleGroups.manager }}
groups: []
{{- else -}}
groups:
- name: mds
  rules:
{{- if not (.Values.prometheusRules.disabled.CephFilesystemDamaged | default false) }}
  - alert: CephFilesystemDamaged
    expr: ceph_health_detail{name="MDS_DAMAGE"} > 0
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.5.1"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Filesystem metadata has been corrupted. Data may be inaccessible. Analyze metrics from the MDS daemon admin socket, or escalate to support."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messagescephfs-health-messages"
      summary: "CephFS filesystem is damaged."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephFilesystemOffline | default false) }}
  - alert: CephFilesystemOffline
    expr: ceph_health_detail{name="MDS_ALL_DOWN"} > 0
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.5.3"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "All MDS ranks are unavailable. The MDS daemons managing metadata are down, rendering the filesystem offline."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messages/mds-all-down"
      summary: "CephFS filesystem is offline"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephFilesystemDegraded | default false) }}
  - alert: CephFilesystemDegraded
    expr: ceph_health_detail{name="FS_DEGRADED"} > 0
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.5.4"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "One or more metadata daemons (MDS ranks) are failed or in a damaged state. At best the filesystem is partially available, at worst the filesystem is completely unusable."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messages/fs-degraded"
      summary: "CephFS filesystem is degraded"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephFilesystemMDSRanksLow | default false) }}
  - alert: CephFilesystemMDSRanksLow
    expr: ceph_health_detail{name="MDS_UP_LESS_THAN_MAX"} > 0
    for: 1m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The filesystem's 'max_mds' setting defines the number of MDS ranks in the filesystem. The current number of active MDS daemons is less than this value."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messages/mds-up-less-than-max"
      summary: "Ceph MDS daemon count is lower than configured"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephFilesystemInsufficientStandby | default false) }}
  - alert: CephFilesystemInsufficientStandby
    expr: ceph_health_detail{name=\"MDS_INSUFFICIENT_STANDBY\"} > 0
    for: 1m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The minimum number of standby daemons required by standby_count_wanted is less than the current number of standby daemons. Adjust the standby count or increase the number of MDS daemons."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messages/mds-insufficient-standby"
      summary: "Ceph filesystem standby daemons too few"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephFilesystemFailureNoStandby | default false) }}
  - alert: CephFilesystemFailureNoStandby
    expr: ceph_health_detail{name="FS_WITH_FAILED_MDS"} > 0
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.5.5"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "An MDS daemon has failed, leaving only one active rank and no available standby. Investigate the cause of the failure or add a standby MDS."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messages/fs-with-failed-mds"
      summary: "MDS daemon failed, no further standby available"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephFilesystemReadOnly | default false) }}
  - alert: CephFilesystemReadOnly
    expr: ceph_health_detail{name="MDS_HEALTH_READ_ONLY"} > 0
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.5.2"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The filesystem has switched to READ ONLY due to an unexpected error when writing to the metadata pool. Either analyze the output from the MDS daemon admin socket, or escalate to support."
      documentation: "https://docs.ceph.com/en/latest/cephfs/health-messagescephfs-health-messages"
      summary: "CephFS filesystem in read only mode due to write error(s)"
{{- end }}
{{- end }}
