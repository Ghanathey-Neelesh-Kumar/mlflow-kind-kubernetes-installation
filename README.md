# Install MLflow on a kind Kubernetes Cluster using Helm

This repository contains the notes and configuration used in the YouTube video demonstrating how to install **MLflow on a local kind Kubernetes cluster** and connect it to an **Amazon RDS PostgreSQL database**.

The aim is to help you repeat the same installation shown in the video. Follow the steps in order.

## What we will do

1. Create an Amazon RDS PostgreSQL database.
2. Connect to PostgreSQL and create a dedicated `mlflow` database and `mlflow_user`.
3. Create a local Kubernetes cluster using kind.
4. Install MLflow in the cluster using the Community Charts Helm chart.
5. Connect to the MLflow UI using `kubectl port-forward`.

## Prerequisites

Install the following tools:

- Docker Desktop or Docker Engine
- kind
- kubectl
- Helm 3
- PostgreSQL client (`psql`)
- An AWS account for the RDS PostgreSQL instance

Check that the tools are available:

```bash
docker version
kind version
kubectl version --client
helm version
psql --version
```

Installation links are listed at the end of this README.

## Step 1: Create an Amazon RDS PostgreSQL instance

In the AWS Console:

1. Open **RDS → Databases → Create database**.
2. Choose **PostgreSQL**.
3. Select **Easy create**.
4. Choose a small sandbox/development instance for this learning demonstration.
5. Enter a unique DB instance identifier.
6. Set a master password and keep it available for the next step.
7. Create the database and wait until its status is **Available**.

Open the database details and copy its endpoint. The default PostgreSQL port is `5432`.

### Allow your local machine to connect

The kind cluster runs on your local machine, outside the AWS VPC. For this demonstration, the RDS instance must be reachable from your machine.

If you enable public accessibility, also update the RDS security group's inbound rules to allow PostgreSQL TCP port `5432` from **your current public IP address only** (a `/32` source). Do not allow access from `0.0.0.0/0`.

If your environment already provides private connectivity to RDS, use that instead.

## Step 2: Create the MLflow database and user

Use the PostgreSQL client to connect to the RDS instance. Replace the endpoint and master username with your own values:

```bash
psql -h <RDS_ENDPOINT> -p 5432 -U <RDS_MASTER_USERNAME> -d postgres
```

Enter the RDS master password when prompted.

At the PostgreSQL prompt, create a separate database and user for MLflow:

```sql
CREATE DATABASE mlflow;

CREATE USER mlflow_user WITH PASSWORD 'YOUR_MLFLOW_PASSWORD';

GRANT ALL PRIVILEGES ON DATABASE mlflow TO mlflow_user;

\connect mlflow

GRANT ALL PRIVILEGES ON SCHEMA public TO mlflow_user;
```

You can also find these commands in [sql/01-create-mlflow-database.sql](sql/01-create-mlflow-database.sql). Replace the password placeholder before running the script.

## Step 3: Create the kind Kubernetes cluster

Create the cluster using the same name as the video:

```bash
kind create cluster --name production-mlflow-setup
```

Check that the cluster and node are ready:

```bash
kind get clusters
kubectl get nodes
kubectl cluster-info --context kind-production-mlflow-setup
```

## Step 4: Add the MLflow Helm chart repository

This demonstration uses the Community Charts MLflow Helm chart.

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
helm search repo community-charts/mlflow
```

## Step 5: Create the MLflow namespace

```bash
kubectl create namespace mlflow
```

## Step 6: Configure the RDS connection

Copy the example values file:

```bash
cp values/mlflow-values.example.yaml values/mlflow-values.yaml
```

Open `values/mlflow-values.yaml` and replace:

- `<RDS_ENDPOINT>` with your RDS endpoint.
- `<YOUR_MLFLOW_PASSWORD>` with the password you assigned to `mlflow_user`.

The configuration enables the PostgreSQL backend, database migration and the database connection check.

**Do not commit your completed `values/mlflow-values.yaml` file or real database password to GitHub.** The repository's `.gitignore` excludes that local file.

## Step 7: Install MLflow using Helm

Run:

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

## Step 8: Verify the MLflow Pod

Watch the Pod until it becomes ready:

```bash
kubectl get pods -n mlflow -w
```

The chart runs an init container to check the PostgreSQL connection before the MLflow server starts. Once the init container completes and the MLflow container is ready, check the Pod:

```bash
kubectl get pods -n mlflow
```

If the Pod does not start, inspect its details and logs:

```bash
kubectl describe pod <MLFLOW_POD_NAME> -n mlflow
kubectl logs <MLFLOW_POD_NAME> -n mlflow --all-containers=true
```

## Step 9: Open the MLflow UI

Get the MLflow Pod name:

```bash
kubectl get pods -n mlflow
```

Forward local port `7004` to the MLflow server port `5000`:

```bash
kubectl port-forward -n mlflow pod/<MLFLOW_POD_NAME> 7004:5000
```

Keep the port-forward terminal running and open this URL in your browser:

**http://localhost:7004**

You should now see the MLflow UI running from your kind Kubernetes cluster.

## Step 10: Clean up after the demonstration

Stop the port-forward with `Ctrl+C`.

Remove the Helm release and local cluster when you have finished:

```bash
helm uninstall mlflow -n mlflow
kubectl delete namespace mlflow
kind delete cluster --name production-mlflow-setup
```

Also delete the RDS instance in the AWS Console if you no longer need it. Remember that AWS RDS can continue to incur charges even after the local kind cluster has been deleted.

## Important note about this demonstration

The video configures Amazon RDS PostgreSQL as the **MLflow backend store** for tracking metadata. It does not configure Amazon S3 as an artifact store.

## Useful links

- [Community Charts Helm repository](https://community-charts.github.io/helm-charts)
- [Community Charts source code](https://github.com/community-charts/helm-charts)
- [Community Charts MLflow documentation](https://community-charts.github.io/docs/charts/mlflow)
- [MLflow documentation](https://mlflow.org/docs/latest/)
- [kind documentation](https://kind.sigs.k8s.io/)
- [Kubernetes documentation](https://kubernetes.io/docs/)
- [Helm documentation](https://helm.sh/docs/)
- [Amazon RDS for PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [PostgreSQL client (psql)](https://www.postgresql.org/docs/current/app-psql.html)
