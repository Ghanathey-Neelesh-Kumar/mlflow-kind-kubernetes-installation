# Quick checks if the installation does not work

## Check the kind cluster

```bash
kind get clusters
kubectl get nodes
kubectl config current-context
```

## Check the MLflow namespace and Pod

```bash
kubectl get all -n mlflow
kubectl get pods -n mlflow -w
kubectl describe pod <MLFLOW_POD_NAME> -n mlflow
kubectl logs <MLFLOW_POD_NAME> -n mlflow --all-containers=true
```

## If the PostgreSQL connection check fails

Check the RDS endpoint, port (`5432`), database name (`mlflow`), username and password in your local values file.

Also check that the RDS security group permits your current public IP address on TCP port 5432. Do not open PostgreSQL to `0.0.0.0/0`.

## If the MLflow UI does not open

Confirm that the MLflow Pod is ready and that the port-forward command is still running:

```bash
kubectl get pods -n mlflow
kubectl port-forward -n mlflow pod/<MLFLOW_POD_NAME> 7004:5000
```

Then open http://localhost:7004.
