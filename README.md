# Install MLflow on a Local kind Kubernetes Cluster

This repository contains the commands and reference links for the YouTube demonstration: installing MLflow on a local Kubernetes cluster created with **kind**, using the **Community Charts Helm chart**, and opening the MLflow UI with port-forwarding.

## What you will do

1. Create a local Kubernetes cluster with kind.
2. Add the Community Charts Helm repository.
3. Install MLflow using the Helm chart.
4. Check that the MLflow Pod and Service are running.
5. Access the MLflow UI on your machine using port-forwarding.

## Prerequisites

Install these tools before starting:

- Docker Desktop or Docker Engine
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

Check that the commands are available:

```bash
docker version
kind version
kubectl version --client
helm version
```

## Step 1: Create the kind cluster

Create the cluster:

```bash
kind create cluster --name production-mlflow-setup
```

Verify the cluster:

```bash
kind get clusters
kubectl get nodes
```

## Step 2: Add the Community Charts Helm repository

The Community Charts project maintains a collection of Helm charts, including a chart for MLflow.

A Helm chart packages the Kubernetes resources and configuration needed to install an application. Instead of creating each Kubernetes manifest yourself, you can install the application through Helm.

Add the Community Charts repository and refresh the chart index:

```bash
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

You can search for the MLflow chart:

```bash
helm search repo community-charts/mlflow
```

## Step 3: Install MLflow

Install MLflow into a Kubernetes namespace named `mlflow`:

```bash
helm install mlflow community-charts/mlflow --namespace mlflow --create-namespace
```

Helm creates the namespace if it does not already exist and installs the resources defined by the chart.

Check the Helm release:

```bash
helm list -n mlflow
```

## Step 4: Verify the installation

Check the Pods:

```bash
kubectl get pods -n mlflow
```

Wait until the MLflow Pod shows `Running` and its container is ready.

Check the Service created by the chart:

```bash
kubectl get services -n mlflow
```

## Step 5: Access the MLflow UI using port-forward

Forward local port `5000` to the MLflow Service. The chart's default Service port is `80` and it forwards traffic to the MLflow container port `5000`:

```bash
kubectl port-forward -n mlflow service/mlflow 5000:80
```

Keep this terminal open while using the UI.

Open the following address in your browser:

**http://localhost:5000**

You should now see the MLflow user interface running from your local kind Kubernetes cluster.

## Useful links

- [Community Charts Helm repository](https://community-charts.github.io/helm-charts)
- [Community Charts GitHub repository](https://github.com/community-charts/helm-charts)
- [MLflow Helm chart documentation](https://community-charts.github.io/docs/charts/mlflow/usage)
- [MLflow documentation](https://mlflow.org/docs/latest/)
- [kind documentation](https://kind.sigs.k8s.io/)
- [Kubernetes documentation](https://kubernetes.io/docs/)
- [Helm documentation](https://helm.sh/docs/)

## Clean up

When you have finished experimenting, you can remove the local kind cluster:

```bash
kind delete cluster --name production-mlflow-setup
```
