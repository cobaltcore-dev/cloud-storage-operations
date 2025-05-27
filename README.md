<!--
# SPDX-FileCopyrightText: Copyright 2024 SAP SE or an SAP affiliate company and cobaltcore-dev contributors
#
# SPDX-License-Identifier: Apache-2.0
-->

# Cloud storage operations

[![REUSE status](https://api.reuse.software/badge/github.com/cobaltcore-dev/cloud-storage-operations)](https://api.reuse.software/info/github.com/cobaltcore-dev/cloud-storage-operations)

This repository contains packaged resources and configuration related to the operations of the vendor-neutral cloud storage backend within the ApeiroRA project.

# Content

The content is structured as follows:

```
cloud-storage-operations
    │
    └── charts/
         │
         └── ceph-operations
              │
              ├── aggregations/             Prometheus aggregation rules for kubernetes.
              │
              ├── alerts/                   Prometheus alerts for kubernetes.
              │
              ├── dashboards/               Plutono dashboards for visualizing key metrics.
              |
              ├── dashboards-global/        Plutono dashboards for visualizing global metrics.
              │
              ├── perses-dashboards/        Perses dashboards for visualizing key metrics.
              │
              ├── perses-dashboards-global/ Perses dashboards for visualizing global metrics.
              │
              ├── playbooks/                Step-by-step instructions for troubleshooting.       
              │
              ├── Chart.yaml                Helm chart manifest.
              │
              └── plugindefintion.yaml      Links the Helm chart to the Greenhouse platform.

```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dashboards.create | bool | `true` | Enables ConfigMap resources with dashboards to be created |
| dashboards.dashboardSelectors | list | `[{"name":"plutono-dashboard","value":"\"true\""}]` | Label selectors for the Plutono dashboards to be picked up by Plutono. |
| dashboards.global.create | bool | `false` | Enables ConfigMap resources with global dashboards to be created |
| dashboards.global.dashboardSelectors | list | `[{"name":"plutono-global","value":"\"true\""}]` | Label selectors for the global Plutono dashboards to be picked up by the global Plutono. |
| dashboards.global.persesDashboardSelectors | list | `[{"name":"perses.dev/global-resource","value":"\"true\""}]` | Label selectors for the global Perses dashboards to be picked up by the global Perses. |
| global.commonLabels | object | `{}` | Common labels to add to all resources # |
| persesDashboards.create | bool | `true` | Enables ConfigMap resources with perses dashboards to be created |
| persesDashboards.dashboardSelectors | list | `[{"name":"perses.dev/resource","value":"\"true\""}]` | Label selectors for the Plutono dashboards to be picked up by Plutono. |
| prometheusRules.additionalRuleAnnotations | object | `{}` | Additional annotations for PrometheusRule alerts |
| prometheusRules.additionalRuleLabels | string | `nil` | Additional labels for PrometheusRule alerts # This is useful for adding additional labels such as "support_group" or "service" for the routing of alerts to each rule |
| prometheusRules.annotations | object | `{}` | Annotations for PrometheusRules |
| prometheusRules.create | bool | `true` | Enables PrometheusRule resources to be created |
| prometheusRules.disabled | object | `{"CephAPodNodePGImbalance":true,"CephNodeInconsistentMTU":true,"CephStorageNodePGImbalance":true}` | Disables specific PrometheusRule alerts |
| prometheusRules.labels | object | `{}` | Labels for PrometheusRules |
| prometheusRules.ruleGroups.absentMetrics | bool | `true` |  |
| prometheusRules.ruleGroups.clusterHealth | bool | `true` |  |
| prometheusRules.ruleGroups.customrules | bool | `true` |  |
| prometheusRules.ruleGroups.generic | bool | `true` |  |
| prometheusRules.ruleGroups.healthChecks | bool | `true` |  |
| prometheusRules.ruleGroups.manager | bool | `false` |  |
| prometheusRules.ruleGroups.mon | bool | `true` |  |
| prometheusRules.ruleGroups.nodes | bool | `true` |  |
| prometheusRules.ruleGroups.osd | bool | `true` |  |
| prometheusRules.ruleGroups.pgr | bool | `true` |  |
| prometheusRules.ruleGroups.pools | bool | `true` |  |
| prometheusRules.ruleGroups.rados | bool | `true` |  |
| prometheusRules.ruleSelectors | string | `nil` |  |

## Support, Feedback, Contributing

This project is open to feature requests/suggestions, bug reports etc. via [GitHub issues](https://github.com/cobaltcore-dev/cloud-storage-operations/issues). Contribution and feedback are encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](CONTRIBUTING.md).

## Security / Disclosure
If you find any bug that may be a security problem, please follow our instructions at [in our security policy](https://github.com/cobaltcore-dev/cloud-storage-operations/security/policy) on how to report it. Please do not create GitHub issues for security-related doubts or problems.

## Code of Conduct

We as members, contributors, and leaders pledge to make participation in our community a harassment-free experience for everyone. By participating in this project, you agree to abide by its [Code of Conduct](https://github.com/SAP/.github/blob/main/CODE_OF_CONDUCT.md) at all times.

## Licensing

Copyright 2024 SAP SE or an SAP affiliate company and cobaltcore-dev contributors. Please see our [LICENSE](LICENSE) for copyright and license information. Detailed information including third-party components and their licensing/copyright information is available [via the REUSE tool](https://api.reuse.software/info/github.com/cobaltcore-dev/cloud-storage-operations).
