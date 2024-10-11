{{- if not .Values.prometheusRules.ruleGroups.pgr }}
groups: []
{{- else -}}
groups:
- name: pgs
  rules:
{{- if not (.Values.prometheusRules.disabled.CephPGsInactive | default false) }}
  - alert: CephPGsInactive
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_total - ceph_pg_active) > 0
    for: 5m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.7.1"
      severity: critical
      type: ceph_default
      inhibited_by: cluster-maintenance
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        `{{`{{ $value }}`}}` PGs have been inactive for more than 5 minutes in pool `{{`{{ $labels.name }}`}}`. Inactive placement groups are not able to serve read/write requests.
      summary: "One or more placement groups are inactive"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGsUnclean | default false) }}
  - alert: CephPGsUnclean
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_total - ceph_pg_clean) > 0
    for: 15m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.7.2"
      severity: warning
      type: ceph_default
      inhibited_by: cluster-maintenance
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        `{{`{{ $value }}`}}` PGs have been unclean for more than 15 minutes in pool `{{`{{ $labels.name }}`}}`. Unclean PGs have not recovered from a previous failure.
      summary: "One or more placement groups are marked unclean"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGsDamaged | default false) }}
  - alert: CephPGsDamaged
    expr: ceph_health_detail{name=~"PG_DAMAGED|OSD_SCRUB_ERRORS"} == 1
    for: 5m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.7.4"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        During data consistency checks (scrub), at least one PG has been flagged as being damaged or inconsistent. Check to see which PG is affected, and attempt a manual repair if necessary. To list problematic placement groups, use `rados list-inconsistent-pg <pool>`. To repair PGs use the `ceph pg repair <pg_num>` command.
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pg-damaged"
      summary: "Placement group damaged, manual intervention needed"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGRecoveryAtRisk | default false) }}
  - alert: CephPGRecoveryAtRisk
    expr: ceph_health_detail{name="PG_RECOVERY_FULL"} == 1
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.7.5"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Data redundancy is at risk since one or more OSDs are at or above the `full` threshold. Add more capacity to the cluster, restore down/out OSDs, or delete unwanted data."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pg-recovery-full"
      summary: "OSDs are too full for recovery"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGUnavailableBlockingIO | default false) }}
  - alert: CephPGUnavailableBlockingIO
    expr: ((ceph_health_detail{name="PG_AVAILABILITY"} == 1) - scalar(ceph_health_detail{name="OSD_DOWN"})) == 1
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.7.3"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Data availability is reduced, impacting the cluster's ability to service I/O. One or more placement groups (PGs) are in a state that blocks I/O."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pg-availability"
      summary: "PG is unavailable, blocking I/O"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGBackfillAtRisk | default false) }}
  - alert: CephPGBackfillAtRisk
    expr: ceph_health_detail{name="PG_BACKFILL_FULL"} == 1
    for: 1m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.7.6"
      severity: critical
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Data redundancy may be at risk due to lack of free space within the cluster. One or more OSDs have reached the 'backfillfull' threshold. Add more capacity, or delete unwanted data."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pg-backfill-full"
      summary: "Backfill operations are blocked due to lack of free space"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGNotScrubbed | default false) }}
  - alert: CephPGNotScrubbed
    expr: ceph_health_detail{name="PG_NOT_SCRUBBED"} == 1
    for: 5m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        One or more PGs have not been scrubbed recently. Scrubs check metadata integrity, protecting against bit-rot. They check that metadata is consistent across data replicas. When PGs miss their scrub interval, it may indicate that the scrub window is too small, or PGs were not in a 'clean' state during the scrub window. You can manually initiate a scrub with: `ceph pg scrub <pgid>`
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pg-not-scrubbed"
      summary: "Placement group(s) have not been scrubbed"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGsHighPerOSD | default false) }}
  - alert: CephPGsHighPerOSD
    expr: ceph_health_detail{name="TOO_MANY_PGS"} == 1
    for: 1m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        The number of placement groups per OSD is too high (exceeds the mon_max_pg_per_osd setting).\n Check that the pg_autoscaler has not been disabled for any pools with `ceph osd pool autoscale-status`, and that the profile selected is appropriate. You may also adjust the target_size_ratio of a pool to guide the autoscaler based on the expected relative size of the pool (`ceph osd pool set cephfs.cephfs.meta target_size_ratio .1`) or set the `pg_autoscaler` mode to `warn` and adjust `pg_num` appropriately for one or more pools.
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks/#too-many-pgs"
      summary: "Placement groups per OSD is too high"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGNotDeepScrubbed | default false) }}
  - alert: CephPGNotDeepScrubbed
    expr: ceph_health_detail{name="PG_NOT_DEEP_SCRUBBED"} == 1
    for: 5m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: |
        One or more PGs have not been deep scrubbed recently. Deep scrubs protect against bit-rot. They compare data replicas to ensure consistency. When PGs miss their deep scrub interval, it may indicate that the window is too small or PGs were not in a 'clean' state during the deep-scrub window.
      documentation: "https://docs.ceph.com/en/latest/rados/operations/health-checks#pg-not-deep-scrubbed"
      summary: "Placement group(s) have not been deep scrubbed"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGRemapped | default false) }}
  - alert: CephPGRemapped
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_unknown) > 0
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The ceph-mgr hasn’t yet received any information about the PG’s state from an OSD since mgr started up."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/pg-states/"
      summary: "The ceph-mgr hasn’t yet received any information about the PG’s state from an OSD since mgr started up."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGStale | default false) }}
  - alert: CephPGStale
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_stale) > 0
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The placement group is in an unknown state - the monitors have not received an update for it since the placement group mapping changed."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/pg-states/"
      summary: "The placement group is in an unknown state - the monitors have not received an update for it since the placement group mapping changed."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGWait | default false) }}
  - alert: CephPGWait
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_wait) > 0
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The set of OSDs for this PG has just changed and IO is temporarily paused until the previous interval’s leases expire."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/pg-states/"
      summary: "The set of OSDs for this PG has just changed and IO is temporarily paused until the previous interval’s leases expire."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGCreating | default false) }}
  - alert: CephPGLaggy
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_laggy) > 0
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "A replica is not acknowledging new leases from the primary in a timely fashion; IO is temporarily paused."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/pg-states/"
      summary: "A replica is not acknowledging new leases from the primary in a timely fashion; IO is temporarily paused."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGCreating | default false) }}
  - alert: CephPGPeering
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_peering) > 0
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The placement group is undergoing the peering process"
      documentation: "https://docs.ceph.com/en/latest/rados/operations/pg-states/"
      summary: "The placement group is undergoing the peering process."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephPGPeered | default false) }}
  - alert: CephPGPeered
    expr: ceph_pool_metadata * on(pool_id,instance) group_left() (ceph_pg_peered) > 0
    for: 15m
    labels:
      severity: warning
      type: ceph_default
      {{- include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "The placement group has peered, but cannot serve client IO due to not having enough copies to reach the pool’s configured min_size parameter. Recovery may occur in this state, so the pg may heal up to min_size eventually."
      documentation: "https://docs.ceph.com/en/latest/rados/operations/pg-states/"
      summary: "The placement group has peered, but cannot serve client IO due to not having enough copies to reach the pool’s configured min_size parameter. Recovery may occur in this state, so the pg may heal up to min_size eventually."
{{- end }}
{{- end }}
