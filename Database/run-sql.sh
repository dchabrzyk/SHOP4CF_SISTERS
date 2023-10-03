#!/bin/bash
sed "s/%DB_NAME%/$1/" /scripts/01_create_database.sql | psql -h "$2" -p "$3" -U postgres -w
psql -f /scripts/02_initialization.sql -d "$1" -h "$2" -p "$3" -U postgres -w
psql -f /scripts/03_keycloak_schema.sql -d "$1" -h "$2" -p "$3" -U postgres -w
