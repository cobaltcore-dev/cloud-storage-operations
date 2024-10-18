# Ceph operations

This Helm chart packages resources and configuration for Ceph operations.

# Content

The content is structured as follows:

```
 ceph-operations
    │
    ├── alerts                      Prometheus alerts for Ceph.
    │
    ├── playbooks                   Playbooks outlining resoluting steps for an individual alert.
    │
    ├── dashboards                  Plutono dashboards visulizing relevant metrics.
    │
    ├── Chart.yaml                  Helm chart manifest. Increase the version number when making changes.
    │
    └── plugindefinition.yaml       Links the Helm chart to the Greenhouse platform. Increase the version number when making changes.
```

# Contributing

When contributing to the `ceph-operations` chart, update the respective content and increment the version in the [Chart.yaml](https://github.com/cobaltcore-dev/cloud-storage-operations/blob/main/charts/ceph-operations/Chart.yaml).
If you're using [Greenhouse](https://github.com/cloudoperators/greenhouse), update the version in the [plugindefinition.yaml](https://github.com/cobaltcore-dev/cloud-storage-operations/blob/main/charts/ceph-operations/plugindefinition.yaml) as well and let the operations platform handle the rollout.
