CREATE DATABASE metastore;
CREATE USER hive_user WITH PASSWORD 'hive_password';
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO hive_user;