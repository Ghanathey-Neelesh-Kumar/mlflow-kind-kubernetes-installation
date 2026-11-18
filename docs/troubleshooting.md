# Basic installation checks

## Check the kind cluster

```bash
kind get clusters
kubectl get nodes
```

## Check MLflow

```bash
helm list -n mlflow
kubectl get pods -n mlflow
kubectl get services -n mlflow
```

If the Pod is not ready, inspect it:

```bash
kubectl describe pod <POD_NAME> -n mlflow
kubectl logs <POD_NAME> -n mlflow
```

## Check port-forwarding

Make sure the port-forward command is still running:

```bash
kubectl port-forward -n mlflow service/mlflow 5000:80
```

Then open http://localhost:5000 in your browser.
