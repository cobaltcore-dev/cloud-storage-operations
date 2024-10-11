{{- if not .Values.prometheusRules.ruleGroups.nodes }}
groups: []
{{- else }}
groups:
- name: nodes
  rules:
{{- if not (.Values.prometheusRules.disabled.CephNodeRootFilesystemFull | default false) }}
  - alert: CephNodeRootFilesystemFull
    expr: node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} * 100 < 5
    for: 5m
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.8.1"
      severity: critical
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Root volume is dangerously full: `{{`{{ $value | humanize }}`}}`% free."
      summary: "Root filesystem is dangerously full"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeNetworkPacketDrops | default false) }}
  - alert: CephNodeNetworkPacketDrops
    expr: |
      (
        rate(node_network_receive_drop_total{device="bond0"}[1m]) +
        rate(node_network_transmit_drop_total{device="bond0"}[1m])
      ) / (
        rate(node_network_receive_packets_total{device="bond0"}[1m]) +
        rate(node_network_transmit_packets_total{device="bond0"}[1m])
      ) >= 0.0050000000000000001 and (
        rate(node_network_receive_drop_total{device="bond0"}[1m]) +
        rate(node_network_transmit_drop_total{device="bond0"}[1m])
      ) >= 10
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.8.2"
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Node `{{`{{ $labels.instance }}`}}` experiences packet drop > 0.5% or > 10 packets/s on interface `{{`{{ $labels.device }}`}}."
      summary: "One or more NICs reports packet drops"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeNetworkPacketErrors | default false) }}
  - alert: CephNodeNetworkPacketErrors
    expr: |
      (
        rate(node_network_receive_errs_total{device="bond0"}[1m]) +
        rate(node_network_transmit_errs_total{device="bond0"}[1m])
      ) / (
        rate(node_network_receive_packets_total{device="bond0"}[1m]) +
        rate(node_network_transmit_packets_total{device="bond0"}[1m])
      ) >= 0.0001 or (
        rate(node_network_receive_errs_total{device="bond0"}[1m]) +
        rate(node_network_transmit_errs_total{device="bond0"}[1m])
      ) >= 10
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.8.3"
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Node `{{`{{ $labels.instance }}`}}` experiences packet errors > 0.01% or > 10 packets/s on interface `{{`{{ $labels.device }}`}}`."
      summary: "One or more NICs reports packet errors"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeNetworkBondDegraded | default false) }}
  - alert: CephNodeNetworkBondDegraded
    expr: node_bonding_slaves - node_bonding_active != 0
    for: 10m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      summary: "Degraded Bond on Node `{{`{{ $labels.instance }}`}}`"
      description: "Bond `{{`{{ $labels.master }}`}}` is degraded on Node `{{`{{ $labels.instance }}`}}`."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeBondInterfacesMismatch | default false) }}
  - alert: CephNodeBondInterfacesMismatch
    expr: node_bonding_active != 2
    for: 10m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      summary: "Degraded Bond on Node `{{`{{ $labels.node }}`}}`"
      description: "Bond `{{`{{ $labels.master }}`}}` does not have 2 active interfaces on Node `{{`{{ $labels.node }}`}}`."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeBondMetricsAbsent | default false) }}
  - alert: CephNodeBondMetricsAbsent
    expr: max_over_time(node_bonding_active[6h]) unless ignoring(instance, pod) node_bonding_active
    for: 30m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      summary: "Bond metrics are absent on Node `{{`{{ $labels.node }}`}}`"
      description: "Bond metrics are absent on Node `{{`{{ $labels.node }}`}}`. Check the network status of the node."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeExporterMissing | default false) }}
  - alert: CephNodeExporterMissing
    expr: up{job="node-exporter"} == 0
    for: 10m
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      summary: "Node exporter is not running on Node `{{`{{ $labels.node }}`}}`"
      description: "Node exporter is not running on Node `{{`{{ $labels.node }}`}}`. Check the node exporter pod and network status of the node."
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeDiskspaceWarning | default false) }}
  - alert: CephNodeDiskspaceWarning
    expr: predict_linear(node_filesystem_free_bytes{device=~"/.*", mountpoint!="/boot"}[2d], 3600 * 24 * 5) *on(instance) group_left(nodename) node_uname_info < 0
    labels:
      oid: "1.3.6.1.4.1.50495.1.2.1.8.4"
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Mountpoint `{{`{{ $labels.mountpoint }}`}}` on `{{`{{ $labels.nodename }}`}}` will be full in less than 5 days based on the 48 hour trailing fill rate."
      summary: "Host filesystem free space is getting low"
{{- end }}

{{- if not (.Values.prometheusRules.disabled.CephNodeInconsistentMTU | default false) }}
  - alert: CephNodeInconsistentMTU
    expr: |
      node_network_mtu_bytes * (node_network_up{device!="lo"} > 0) ==  scalar(    max by (device) (node_network_mtu_bytes * (node_network_up{device!="lo"} > 0)) !=      quantile by (device) (.5, node_network_mtu_bytes * (node_network_up{device!="lo"} > 0))  )or node_network_mtu_bytes * (node_network_up{device!="lo"} > 0) ==  scalar(    min by (device) (node_network_mtu_bytes * (node_network_up{device!="lo"} > 0)) !=      quantile by (device) (.5, node_network_mtu_bytes * (node_network_up{device!="lo"} > 0))  )
    labels:
      severity: warning
      type: ceph_default
      {{ include "cloud-storage-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: "Node `{{`{{ $labels.instance }}`}}` has a different MTU size (`{{`{{ $value }}`}}`) than the median of devices named `{{`{{ $labels.device }}`}}`."
      summary: "MTU settings across Ceph hosts are inconsistent"
{{- end }}
{{- end }}
