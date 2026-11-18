# Install MLflow on a kind Kubernetes Cluster with Helm and Amazon RDS PostgreSQL

This repository accompanies the YouTube walkthrough demonstrating how to run the **MLflow Tracking Server inside a local kind Kubernetes cluster** while using **Amazon RDS for PostgreSQL as the external backend store**.

The walkthrough uses the community-maintained `community-charts/mlflow` Helm chart.

> **Scope:** The implementation covered here configures PostgreSQL as MLflow's backend store for tracking metadata. It does **not** configure Amazon S3 as the artifact store. Do not assume this lab provides durable, shared artifact storage. See [Architecture and scope](docs/architecture.md).
>
> **Learning lab, not a production blueprint:** kind runs locally on your workstation. Any public RDS access used for a laptop-to-RDS demonstration must be temporary and tightly restricted. A production deployment needs private network connectivity, managed secrets, TLS, authentication, monitoring, backups and tested recovery procedures.

## What you will build

```text
Browser / MLflow client
        |
        | http://localhost:7004
        v
kubectl port-forward
        |
        v
kind Kubernetes cluster
        |
        v
MLflow Tracking Server Pod :5000
        |
        | PostgreSQL TCP :5432
        v
Amazon RDS for PostgreSQL
        |
        +-- experiments
        +-- runs
        +-- parameters
        +-- metrics
        +-- tags
```

## Repository contents

```text
mlflow-kind-kubernetes-installation/
├── README.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── links-and-versions.md
│   ├── security-and-cleanup.md
│   └── troubleshooting.md
├── sql/
│   └── 01-create-mlflow-database.sql
└── values/
    └── mlflow-values.example.yaml
```

## 1. Prerequisites

Install and verify:

- Docker Desktop (or Docker Engine) running
- kind
- kubectl
- Helm 3
- Git
- An AWS account with permission to create/manage an RDS PostgreSQL instance
- A `psql` client compatible with your PostgreSQL server

Check your installations:

```bash
docker version
kind version
kubectl version --client
helm version
git --version
psql --version
```

Useful installation links are listed in [docs/links-and-versions.md](docs/links-and-versions.md).

## 2. Create the PostgreSQL database in Amazon RDS

The walkthrough uses Amazon RDS for PostgreSQL as the external MLflow backend store.

In the AWS Console:

1. Open **RDS → Databases → Create database**.
2. Select **PostgreSQL**.
3. Choose a development configuration appropriate for your account and budget.
4. Give the DB instance a name, for example `mlflow-postgres-demo`.
5. Set and securely store the master password.
6. Record the endpoint, port and AWS Region after the instance becomes available.

The default PostgreSQL port is `5432`.

### Network access for a local kind lab

Your kind cluster runs on your workstation, so the MLflow Pod needs network connectivity to the RDS endpoint.

If your particular local lab requires RDS public accessibility, restrict the RDS security group's inbound rule to your current public IP address only:

| Setting | Value |
|---|---|
| Type | PostgreSQL |
| Protocol | TCP |
| Port | 5432 |
| Source | `YOUR_PUBLIC_IP/32` |

Never open the database to `0.0.0.0/0`. Public accessibility alone does not guarantee connectivity; subnet routing, network ACLs, security groups and database status must also permit the connection.

For EKS or another production cluster, prefer private RDS connectivity inside the VPC. See [Security and cleanup](docs/security-and-cleanup.md).

### Connect with psql

Replace the endpoint placeholder:

```bash
psql -h <RDS_ENDPOINT> -p 5432 -U postgres -d postgres
```

Enter the master password when prompted. Avoid placing passwords directly in shell commands or command history.

### Create a dedicated database and application user

Run the SQL statements in [sql/01-create-mlflow-database.sql](sql/01-create-mlflow-database.sql). Replace the password placeholder with a strong password that you store securely.

The script creates:

- Database: `mlflow`
- Application user: `mlflow_user`
- Database and `public` schema permissions for the application user

Use the dedicated `mlflow_user` account for the MLflow application. Do not configure the application to use the RDS master account.

## 3. Create the kind cluster

The course demonstration uses the cluster name `production-mlflow-setup`:

```bash
kind create cluster --name production-mlflow-setup
```

Verify the cluster:

```bash
kind get clusters
kubectl cluster-info --context kind-production-mlflow-setup
kubectl get nodes
```

Wait until the kind node reports `Ready` before continuing.

## 4. Add the Community Charts Helm repository

The walkthrough uses the MLflow chart published by the Community Charts project.

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

Verify the repository and inspect the MLflow chart:

```bash
helm repo list
helm search repo community-charts/mlflow --versions
helm show chart community-charts/mlflow
helm show values community-charts/mlflow
```

The Helm chart version and MLflow application version are different version numbers. Check the chart metadata before installation. For repeatable deployments, select and pin a chart version that you have tested; do not assume that the latest chart will behave exactly like the version used in the recording.

## 5. Create the `mlflow` namespace

```bash
kubectl create namespace mlflow
kubectl get namespace mlflow
```

If the namespace already exists, continue without recreating it.

## 6. Create a Kubernetes Secret for the database credentials

Do not commit database credentials to GitHub or put real passwords in the example values file.

Create a Secret in the same namespace as the MLflow Helm release:

```bash
kubectl create secret generic mlflow-db-secret \
  --namespace mlflow \
  --from-literal=username=mlflow_user \
  --from-literal=password='<YOUR_MLFLOW_DB_PASSWORD>'
```

Verify only that the Secret exists:

```bash
kubectl get secret mlflow-db-secret -n mlflow
```

Do not print or decode the Secret during the recording. For production, use a managed secret solution such as External Secrets Operator with AWS Secrets Manager or another approved secrets platform.

## 7. Configure the Helm values file

Copy the example values file:

```bash
cp values/mlflow-values.example.yaml values/mlflow-values.yaml
```

Edit `values/mlflow-values.yaml` and replace `<RDS_ENDPOINT>` with your RDS PostgreSQL endpoint.

The values file configures:

- PostgreSQL as the external backend store
- The MLflow database name and endpoint
- Database schema migration
- A database connection-check init container
- The existing Kubernetes Secret containing the database username and password

The `databaseConnectionCheck` setting adds a database availability check before the main tracking server starts. The `databaseMigration` setting enables the chart's database migration step.

The real `values/mlflow-values.yaml` file is excluded by `.gitignore`. Commit only the example file, never a file containing credentials.

## 8. Install MLflow with Helm

Install the release:

```bash
helm install mlflow community-charts/mlflow \
  --namespace mlflow \
  --values values/mlflow-values.yaml
```

Check the Helm release:

```bash
helm list -n mlflow
helm status mlflow -n mlflow
```

Helm should report the release as `deployed` when installation has completed successfully.

## 9. Verify Kubernetes resources and database connectivity

Watch the Pod:

```bash
kubectl get pods -n mlflow -w
```

In another terminal, inspect the resources:

```bash
kubectl get pods,svc,deployments -n mlflow
kubectl get events -n mlflow --sort-by=.metadata.creationTimestamp
```

The MLflow Pod may run init containers for the database connection check and schema migration before the main container starts. If the Pod does not become ready, inspect it:

```bash
kubectl describe pod <MLFLOW_POD_NAME> -n mlflow
kubectl logs <MLFLOW_POD_NAME> -n mlflow --all-containers=true
```

The init containers should complete successfully and the MLflow application container should become ready.

## 10. Access the MLflow UI with port-forwarding

Find the MLflow Pod:

```bash
kubectl get pods -n mlflow
```

Forward local port `7004` to container port `5000`:

```bash
kubectl port-forward -n mlflow pod/<MLFLOW_POD_NAME> 7004:5000
```

Keep this terminal open. Open the following address in your browser:

```text
http://localhost:7004
```

The port-forward is temporary. Stopping the command closes the tunnel; it does not stop the MLflow Pod or delete the database.

You can inspect the Service name and port with:

```bash
kubectl get svc -n mlflow
```

If you forward the Service instead of the Pod, use the Service port shown by that command. Do not assume the Service port is the same as the container port.

## 11. Verify metadata persistence

1. Open the MLflow UI.
2. Create a test experiment, for example `kind-rds-persistence-check`.
3. Confirm that the experiment appears in the UI.
4. In a separate terminal, identify the MLflow Pod and delete only that Pod:

```bash
kubectl get pods -n mlflow
kubectl delete pod <MLFLOW_POD_NAME> -n mlflow
kubectl get pods -n mlflow -w
```

5. Wait for the Deployment to create a replacement Pod and for it to become ready.
6. Restart the port-forward if necessary and refresh the MLflow UI.
7. Confirm that the experiment is still present.

This demonstrates that MLflow tracking metadata is stored in the external PostgreSQL database rather than only in the MLflow Pod's writable container filesystem.

> This test proves metadata persistence across replacement of the MLflow Pod. It does not prove that artifact files are stored in S3, or that the overall deployment has high availability or disaster recovery.

## 12. Cleanup

Stop port-forwarding with `Ctrl+C`.

Uninstall the Helm release:

```bash
helm uninstall mlflow -n mlflow
```

Delete the namespace if it is no longer needed:

```bash
kubectl delete namespace mlflow
```

Delete the local kind cluster:

```bash
kind delete cluster --name production-mlflow-setup
```

Delete the RDS instance and temporary AWS resources only when you are certain they are no longer required. Check snapshots and backups before deletion, and review AWS billing afterwards.

## 13. Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md) for common issues involving RDS connectivity, PostgreSQL permissions, init containers, Pod readiness, Helm releases and port-forwarding.

## Useful links

- [Community Charts Helm repository](https://community-charts.github.io/helm-charts)
- [Community Charts GitHub repository](https://github.com/community-charts/helm-charts)
- [MLflow chart documentation — PostgreSQL backend](https://community-charts.github.io/docs/charts/mlflow/postgresql-backend-installation)
- [Official MLflow project](https://github.com/mlflow/mlflow)
- [Official MLflow documentation](https://mlflow.org/docs/latest/)

See [docs/links-and-versions.md](docs/links-and-versions.md) for the complete reference list and the distinction between the Community Charts chart used here and the official MLflow Helm chart.
