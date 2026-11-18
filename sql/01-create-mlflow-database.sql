-- Connect to the default PostgreSQL database on your RDS instance
-- as the RDS master user before running these commands.
-- Replace the password with your own value.

CREATE DATABASE mlflow;

CREATE USER mlflow_user WITH PASSWORD '<YOUR_MLFLOW_PASSWORD>';

GRANT ALL PRIVILEGES ON DATABASE mlflow TO mlflow_user;

\connect mlflow

GRANT ALL PRIVILEGES ON SCHEMA public TO mlflow_user;
