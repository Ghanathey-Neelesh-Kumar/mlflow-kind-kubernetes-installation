# Architecture and scope

## Architecture used in the walkthrough

```text
Developer / Data Scientist workstation
       |                         |
       | browser                 | MLflow client
       |                         |
       +---------- localhost:7004+
                     |
              kubectl port-forward
                     |
                     v
          kind Kubernetes cluster
                     |
              MLflow Tracking Pod :5000
                     |
              PostgreSQL TCP :5432
                     |
                     v
          Amazon RDS PostgreSQL
          MLflow backend metadata
```

## What PostgreSQL stores

The backend store contains structured MLflow tracking metadata, including experiments, runs, parameters, metrics, tags and related run metadata.

The RDS instance is external to the local kind cluster. Replacing the MLflow Pod does not delete records stored in that database, provided the database remains available and the replacement Pod uses the same connection details.

## What this walkthrough does not demonstrate

The recorded installation configures PostgreSQL as the external backend store. It does not show an Amazon S3 artifact store being configured. Do not describe this specific deployment as having durable S3 artifact storage.

For a complete shared production architecture, configure a durable object store for artifacts (for example, Amazon S3), private network connectivity, managed secrets, TLS, authentication, monitoring, backups and tested recovery procedures. These are separate design tasks and should not be assumed from the RDS backend installation.

## Why use a dedicated database user?

The RDS master user is used for initial database administration only. MLflow connects using a dedicated application user (`mlflow_user`) with permissions on the `mlflow` database. This separates application access from database administration.

## Why are there database init containers?

The Community Charts MLflow chart supports `backendStore.databaseConnectionCheck`. When enabled with the PostgreSQL backend, the chart adds a database availability init container. The main MLflow application container waits until that check succeeds. The chart also supports `backendStore.databaseMigration` for schema migrations.
