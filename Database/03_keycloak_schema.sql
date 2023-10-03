CREATE USER keycloak_user WITH PASSWORD 'keycloak_pass';
CREATE SCHEMA IF NOT EXISTS keycloak AUTHORIZATION keycloak_user;
GRANT ALL PRIVILEGES ON SCHEMA keycloak TO keycloak_user;
