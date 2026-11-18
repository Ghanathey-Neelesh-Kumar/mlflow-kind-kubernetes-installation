# References for the MLflow kind installation video

## Community Charts

- Helm repository: https://community-charts.github.io/helm-charts
- GitHub repository: https://github.com/community-charts/helm-charts
- MLflow chart documentation: https://community-charts.github.io/docs/charts/mlflow/usage

## MLflow and Kubernetes

- MLflow documentation: https://mlflow.org/docs/latest/
- kind documentation: https://kind.sigs.k8s.io/
- Kubernetes documentation: https://kubernetes.io/docs/
- Helm documentation: https://helm.sh/docs/

## Commands shown in the walkthrough

```bash
kind create cluster --name production-mlflow-setup

helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update

helm install mlflow community-charts/mlflow --namespace mlflow --create-namespace

kubectl get pods -n mlflow
kubectl get services -n mlflow

kubectl port-forward -n mlflow service/mlflow 5000:80
```

Open http://localhost:5000 while the port-forward command is running.
