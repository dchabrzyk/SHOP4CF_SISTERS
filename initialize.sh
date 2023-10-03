#!/bin/bash

RAMP_REPO_USERNAME=<repo_user>
RAMP_REPO_CLI_PASSWORD=<repo_cli_password>

NAMESPACE=sisters
DB_HOST=localhost
DB_PORT=31066
DB_NAME=sisters

kubectl create namespace $NAMESPACE
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install --namespace $NAMESPACE postgresql bitnami/postgresql --set primary.service.type=NodePort --set auth.postgresPassword=postgres --set-string primary.service.nodePorts.postgresql=31066

seconds=30
i=0
while (( i < seconds )); do
   printf "\r%*d s" ${#seconds} $(($seconds - $i))
   sleep 1
   ((i++))
done
printf "\r"

PGPASSWORD=$(kubectl get secret --namespace $NAMESPACE postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

echo "Database password: $PGPASSWORD"

cd ./Database

docker run -it --rm --network=host -v "${PWD}":/scripts -e PGPASSWORD="${PGPASSWORD}" postgres /bin/sh /scripts/run-sql.sh "${DB_NAME}" "${DB_HOST}" "${DB_PORT}"
docker run --rm --network=host -v "${PWD}":/liquibase/changelog -w /liquibase/changelog liquibase/liquibase liquibase --changeLogFile=dbchangelog.xml \
  --url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} --username postgres --password ${PGPASSWORD} --log-level=info update

cd ../Helm

helm repo add superset https://apache.github.io/superset
helm repo add --username ${RAMP_REPO_USERNAME} --password ${RAMP_REPO_CLI_PASSWORD} ramp https://docker.ramp.eu/chartrepo/masta-pvt
helm repo update

kubectl create secret docker-registry ramp --docker-server=docker.ramp.eu --docker-username=${RAMP_REPO_USERNAME} --docker-password=${RAMP_REPO_CLI_PASSWORD} --namespace=${NAMESPACE}

helm upgrade --debug --namespace $NAMESPACE --create-namespace --install --wait --atomic --disable-openapi-validation --version 0.0.1 camunda ./camunda-0.0.1.tgz
helm upgrade --debug --namespace $NAMESPACE --create-namespace --install --wait --atomic --disable-openapi-validation --version 0.0.1 mongodb ./mongodb-0.0.1.tgz
helm upgrade --debug --namespace $NAMESPACE --create-namespace --install --wait --atomic --disable-openapi-validation --version 0.0.1 fiware ./fiware-0.0.1.tgz
helm upgrade --debug --namespace $NAMESPACE --create-namespace --install --wait --atomic --disable-openapi-validation --version 0.0.1 rabbitmq ./rabbitmq-0.0.1.tgz
helm upgrade --debug --namespace $NAMESPACE --create-namespace --install --wait --atomic --disable-openapi-validation --version 0.0.1 kafka-stack ./kafka-stack-0.0.1.tgz
helm upgrade --debug --namespace $NAMESPACE --create-namespace --install --wait --atomic --disable-openapi-validation --version 0.0.1 -f ./keycloak-values.yaml keycloak ./keycloak-0.0.1.tgz

kubectl --namespace ${NAMESPACE} apply -f server-configmap.yaml

helm upgrade --debug --namespace sisters --install --wait --atomic -f tupiid-variables.yaml superset superset/superset

helm upgrade --debug --namespace sisters --install --wait --atomic --version 0.0.1 -f extra-hot-mamma-server-variables.yaml extra-hot-mamma-server ramp/extra-hot-mamma-server
helm upgrade --debug --namespace sisters --install --wait --atomic --version 0.0.1 -f extra-hot-mamma-client-variables.yaml extra-hot-mamma-client ramp/extra-hot-mamma-client
helm upgrade --debug --namespace sisters --install --wait --atomic --version 0.0.1 -f mctids-terminal-variables.yaml mctids-terminal ramp/mctids-terminal

echo "Done!"
echo "Application are available under:"
echo "hot-mamma-client: http://localhost:31778"
echo "pepesha-terminal: http://localhost:31779"
