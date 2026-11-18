# Links and version notes

## Chart used by this walkthrough

The walkthrough uses the Community Charts MLflow chart:

- Helm repository: https://community-charts.github.io/helm-charts
- Helm repository alias: `community-charts`
- Chart reference: `community-charts/mlflow`
- Source repository: https://github.com/community-charts/helm-charts
- Chart usage documentation: https://community-charts.github.io/docs/charts/mlflow/usage
- PostgreSQL backend guide: https://community-charts.github.io/docs/charts/mlflow/postgresql-backend-installation
- ArtifactHub package: https://artifacthub.io/packages/helm/community-charts/mlflow

Add and refresh the repository:

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

Inspect available versions and the chart's values:

```bash
helm search repo community-charts/mlflow --versions
helm show chart community-charts/mlflow
helm show values community-charts/mlflow
```

The chart and MLflow application versions are separate. At the time this repository was prepared (18 November 2026), the Community Charts chart metadata declared chart version `1.11.7` and MLflow application version `3.16.0`. This is a current reference point, **not a claim that the same versions were used in the original recording**. For repeatable deployment, select and pin a chart version you have tested with `--version <CHART_VERSION>`.

## Official MLflow project

- Official MLflow GitHub: https://github.com/mlflow/mlflow
- Official MLflow documentation: https://mlflow.org/docs/latest/
- Official Kubernetes Helm deployment documentation: https://mlflow.org/docs/latest/self-hosting/kubernetes-helm
- Official chart source: https://github.com/mlflow/mlflow/tree/master/charts
- Official chart OCI reference: `oci://ghcr.io/mlflow/charts/mlflow`

### Important chart distinction

This walkthrough uses `community-charts/mlflow` because that is the Community Charts approach demonstrated in the course material. MLflow also publishes an official Helm chart as an OCI artifact. These are different charts with different values schemas. Do not copy values from one chart into the other.

## Kubernetes and Helm

- kind: https://kind.sigs.k8s.io/
- kind quick start: https://kind.sigs.k8s.io/docs/user/quick-start/
- Kubernetes documentation: https://kubernetes.io/docs/home/
- kubectl installation: https://kubernetes.io/docs/tasks/tools/
- Helm documentation: https://helm.sh/docs/
- Helm install command: https://helm.sh/docs/helm/helm_install/
- Helm repositories: https://helm.sh/docs/helm/helm_repo/

## AWS and PostgreSQL

- Amazon RDS for PostgreSQL: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
- RDS security groups: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html
- PostgreSQL documentation: https://www.postgresql.org/docs/
- psql reference: https://www.postgresql.org/docs/current/app-psql.html
