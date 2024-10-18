## Dashboard creation and configuration workflow


1. Create a new dashboard

The following [guide](https://github.com/cloudoperators/greenhouse-extensions/blob/main/plutono/README.md#example-datasource-config) will help you create a new dashboard in the Plutono UI:

2. After creating and modifying the dashboard, you must export it, as it will be lost if it is saved in the browser's local storage.
3. Export the dashboard.
   - Go to **Dashboard settings**.
   - Click **JSON Model**.
   - Copy the JSON model.
4. Come back here to your Github repository and create or modify the JSON files in the `dashboards` directory.
5. update the chart version in both the [Chart.yaml](https://github.com/cobaltcore-dev/cloud-storage-operations/blob/main/charts/ceph-operations/Chart.yaml) file and the [plugindefinition.yaml](https://github.com/cobaltcore-dev/cloud-storage-operations/blob/main/charts/ceph-operations/plugindefinition.yaml) file.
