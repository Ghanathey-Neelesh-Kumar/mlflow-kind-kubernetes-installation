-- Connect to the default PostgreSQL database as the RDS master/admin user.
-- Replace the placeholder with a strong password. Do not commit real secrets.

CREATE DATABASE mlflow;

CREATE USER mlflow_user WITH PASSWORD '<REPLACE_WITH_STRONG_PASSWORD>';

GRANT ALL PRIVILEGES ON DATABASE mlflow TO mlflow_user;

-- Switch to the database before granting schema permissions.
\connect mlflow

GRANT ALL PRIVILEGES ON SCHEMA public TO mlflow_user;
