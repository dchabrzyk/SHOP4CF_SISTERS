#!/bin/bash

echo "************************************"
echo " Admin Import "
echo "************************************"

# Set the needed parameter for the authorization
USER=$1
PASSWORD=$2
GRANT_TYPE=password
CLIENT_ID=admin-cli
KEYCLOAK_URL=$3
CDEMS_API_URL=$4
SETTING_METADATA=setting-metadata.json
GLOBAL_SETTINGS=global-settings.json
GLOBAL_I18N_SETTINGS=global-i18n-settings.json

TMP_FILE=.token
touch $TMP_FILE

# Execute the CURL command to request the access-token
printf "Acquiring access token     : ..."
echo curl --write-out '%{http_code}' -s -o "$TMP_FILE" -d "client_id=$CLIENT_ID" -d "username=$USER" -d "password=$PASSWORD" -d "grant_type=$GRANT_TYPE" "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token"
result=$(curl --write-out '%{http_code}' -s -o "$TMP_FILE" -d "client_id=$CLIENT_ID" -d "username=$USER" -d "password=$PASSWORD" -d "grant_type=$GRANT_TYPE" "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token") #
printf "\b\b\b$result\n"

cat $TMP_FILE
access_token=$(cat $TMP_FILE | sed -n 's|.*"access_token":"\([^"]*\)".*|\1|p')
rm $TMP_FILE
printf "Access token              : \n$access_token\n"

# Execute the CURL command to request user and organization
printf "Testing token             : ..."
result=$(curl --write-out '%{http_code}' -o /dev/null -H "Authorization: Bearer $access_token" -s $CDEMS_API_URL/api/Test/auth)
printf "\b\b\b$result\n"

# # Execute the CURL command to intialize auth service (Keycloak)
printf "Initializing auth         : ..."
result=$(curl -X POST --write-out '%{http_code}' -o "$TMP_FILE" -s  -i -L -H "Authorization: Bearer $access_token" $CDEMS_API_URL/api/Import/auth_initialization)
printf "\b\b\b$result\n"

client_secret=$(cat $TMP_FILE | sed -n 's|.*"clientSecret":"\([^"]*\)".*|\1|p')
rm $TMP_FILE
printf "Client secret             : \n$client_secret\n"

# Execute the CURL command to import setting metadata
printf "Importing metdata         : ..."
result=$(curl --write-out '%{http_code}' -o /dev/null -s -i -L -d @./$SETTING_METADATA -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" $CDEMS_API_URL/api/Import/admin)
printf "\b\b\b$result\n"

# Execute the CURL command to import global settings
printf "Importing global settings : ..."
result=$(curl --write-out '%{http_code}' -o /dev/null -i -L -d @./$GLOBAL_SETTINGS -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" -s $CDEMS_API_URL/api/Import/admin)
printf "\b\b\b$result\n"

# Execute the CURL command to import global i18n settings
printf "Importing global i18n settings : ..."
result=$(curl --write-out '%{http_code}' -o /dev/null -i -L -d @./$GLOBAL_I18N_SETTINGS -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" -s $CDEMS_API_URL/api/Import/admin)
printf "\b\b\b$result\n"

