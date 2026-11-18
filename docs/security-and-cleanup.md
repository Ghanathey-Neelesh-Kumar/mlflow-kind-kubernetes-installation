# Security and cleanup

## RDS access in a local kind demonstration

The walkthrough connects a workstation-hosted kind cluster to an Amazon RDS PostgreSQL endpoint. Depending on the network design, this may require temporary public accessibility for the RDS instance.

If you use this approach:

- Restrict inbound TCP 5432 to your current public IP using `/32`.
- Never allow `0.0.0.0/0` for PostgreSQL.
- Use a dedicated MLflow database user, not the RDS master user.
- Use a strong password and do not commit it to GitHub.
- Remove temporary inbound rules and disable public accessibility when no longer required.

For a real EKS deployment, prefer private RDS networking and a managed identity or secret-injection mechanism.

## Secrets

The repository includes only `values/mlflow-values.example.yaml`. Copy it locally to `values/mlflow-values.yaml`, fill in the endpoint, and keep the real file untracked.

Do not commit:

- Database passwords
- AWS access keys or secret keys
- Full PostgreSQL connection strings containing credentials
- Decoded Kubernetes Secret values
- `.env` files containing secrets

The Kubernetes Secret in this lab is a teaching mechanism. Kubernetes Secrets are not a complete secrets-management solution by themselves; use encryption at rest, RBAC and an external secret manager for production.

## Cost and deletion checklist

After the lab:

1. Stop port-forwarding with `Ctrl+C`.
2. Uninstall the Helm release:

   ```bash
   helm uninstall mlflow -n mlflow
   ```

3. Delete the namespace if it is no longer needed:

   ```bash
   kubectl delete namespace mlflow
   ```

4. Delete the kind cluster:

   ```bash
   kind delete cluster --name production-mlflow-setup
   ```

5. In AWS, delete the RDS instance and temporary security-group rules only after checking whether you need a final snapshot or retained data.
6. Review AWS billing and remove unused resources.

Deleting the kind cluster does not delete an Amazon RDS instance. AWS resources must be cleaned up separately.
