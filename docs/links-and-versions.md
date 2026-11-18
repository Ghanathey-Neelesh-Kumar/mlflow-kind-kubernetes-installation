# Links used in the video

The installation walkthrough uses the Community Charts MLflow Helm chart.

- Helm repository: https://community-charts.github.io/helm-charts
- Source repository: https://github.com/community-charts/helm-charts
- MLflow chart documentation: https://community-charts.github.io/docs/charts/mlflow
- MLflow documentation: https://mlflow.org/docs/latest/
- kind documentation: https://kind.sigs.k8s.io/
- Kubernetes documentation: https://kubernetes.io/docs/
- Helm documentation: https://helm.sh/docs/
- Amazon RDS for PostgreSQL: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
- PostgreSQL documentation: https://www.postgresql.org/docs/

Add the Helm repository and search for the chart:

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
helm search repo community-charts/mlflow
```

The chart version and MLflow application version are different. The video notes do not establish the exact chart version used in the recording, so check the available versions in Helm rather than assuming a version number.
