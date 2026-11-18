# Troubleshooting

Start with the failing layer. Avoid reinstalling the entire stack before checking the relevant resource, event or log.

## 1. kind cluster is not ready

```bash
kind get clusters
kubectl get nodes
kubectl get pods -A
```

Confirm Docker is running and the kind node is `Ready`. If the cluster name differs from the one in the notes, check the active Kubernetes context:

```bash
kubectl config current-context
kubectl config get-contexts
```

## 2. MLflow Pod remains in an init state

The Community Charts chart can add init containers for database connectivity checks and schema migrations. Inspect the Pod:

```bash
kubectl get pods -n mlflow
kubectl describe pod <MLFLOW_POD_NAME> -n mlflow
kubectl logs <MLFLOW_POD_NAME> -n mlflow --all-containers=true
kubectl get events -n mlflow --sort-by=.metadata.creationTimestamp
```

Check the RDS endpoint, security-group rule, database name, user, password Secret and database grants.

## 3. RDS connection times out

Check:

- RDS status is `Available`.
- The endpoint and port are correct.
- For a local kind lab, RDS networking permits traffic from the workstation's network path.
- The security group allows TCP 5432 from the correct source IP/CIDR.
- The RDS instance is publicly accessible only if your local demonstration requires it.
- Your public IP has not changed since you created the security-group rule.

Do not open PostgreSQL to `0.0.0.0/0`.

## 4. Password authentication failed

The network connection reached PostgreSQL, but the supplied username or password is incorrect. Confirm the Secret name and key names match the Helm values file:

```bash
kubectl get secret mlflow-db-secret -n mlflow
```

Do not print or decode the Secret in a shared terminal or recording.

## 5. Database `mlflow` does not exist

Connect to RDS as the database administrator and confirm that the dedicated `mlflow` database was created. The database name in the Helm values must match the actual database name.

## 6. Permission denied for schema `public`

Connect to the `mlflow` database as an administrator and verify that the application user has the required schema permissions. Re-run the schema grant from `sql/01-create-mlflow-database.sql` if appropriate.

## 7. Helm release already exists

Inspect the release:

```bash
helm list -n mlflow
helm status mlflow -n mlflow
```

For a deliberate configuration update, use:

```bash
helm upgrade mlflow community-charts/mlflow \
  --namespace mlflow \
  --values values/mlflow-values.yaml
```

Do not run `helm install` repeatedly for an existing release.

## 8. Port-forward command fails

Find the current Pod and Service names:

```bash
kubectl get pods,svc -n mlflow
```

For Pod port-forwarding to the MLflow container port:

```bash
kubectl port-forward -n mlflow pod/<MLFLOW_POD_NAME> 7004:5000
```

If forwarding a Service instead, use the Service port shown by `kubectl get svc -n mlflow`. The Service port may differ from the container port.

## 9. MLflow UI does not open

- Confirm the port-forward command is still running.
- Open `http://localhost:7004` (HTTP, not HTTPS).
- Confirm local port 7004 is not already occupied.
- Confirm the MLflow Pod is ready.

## 10. Capture useful diagnostics

```bash
helm status mlflow -n mlflow
kubectl get pods,svc,deployments -n mlflow
kubectl describe pod <MLFLOW_POD_NAME> -n mlflow
kubectl logs <MLFLOW_POD_NAME> -n mlflow --all-containers=true
kubectl get events -n mlflow --sort-by=.metadata.creationTimestamp
```

Remove passwords, access keys, account IDs and other sensitive information before sharing diagnostic output publicly.
