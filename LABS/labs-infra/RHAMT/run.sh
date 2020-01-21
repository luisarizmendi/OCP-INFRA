#!/bin/bash

USERCOUNT=25
GOGS_PWD=redhat



sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y jq



oc new-app -f template.json --param-file=env

echo ""
echo -e "Waiting for rhamt to be running... \n"

sleep 5

HOSTNAME=$( oc get route | grep  rhamt | awk '{print $2}' | head -n 1)
HOSTNAME_SECURE=$( oc get route | grep  secure-rhamt | awk '{print $2}')



  while [ 1 ]; do
    STAT=$(curl -s -w '%{http_code}' -o /dev/null http://$HOSTNAME)
    if [ "$STAT" = 200 ] ; then
      break
    fi
    echo -n .
    sleep 10
  done


  echo -e "Getting access token to update RH-SSO theme \n"
  RESULT_TOKEN=$(curl -k -X POST https://$HOSTNAME_SECURE/auth/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d 'password=password' \
  -d 'grant_type=password' \
  -d 'client_id=admin-cli' | jq -r '.access_token')




  echo -e "Updating a master realm with RH-SSO theme \n"
  RES=$(curl -s -w '%{http_code}' -o /dev/null  -k -X PUT https://$HOSTNAME_SECURE/auth/admin/realms/master/ \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $RESULT_TOKEN" \
  -d '{ "displayName": "rh-sso", "displayNameHtml": "<strong>Red Hat</strong><sup>®</sup> Single Sign On", "loginTheme": "rh-sso", "adminTheme": "rh-sso", "accountTheme": "rh-sso", "emailTheme": "rh-sso", "accessTokenLifespan": 6000 }')

  if [ "$RES" = 204 ] ; then
    echo -e "Updated a master realm with RH-SSO theme successfully...\n"
  else
    echo -e "Failure to update a master realm with RH-SSO theme with $RES\n"
  fi

  echo -e "Creating RH-SSO users as many as gogs users \n"
  for i in $(eval echo "{0..$USERCOUNT}") ; do
    RES=$(curl -s -w '%{http_code}' -o /dev/null  -k -X POST https://$HOSTNAME_SECURE/auth/admin/realms/rhamt/users \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $RESULT_TOKEN" \
    -d '{ "username": "user'"$i"'", "enabled": true, "disableableCredentialTypes": [ "password" ] }')
    if [ "$RES" = 200 ] || [ "$RES" = 201 ] || [ "$RES" = 409 ] ; then
      echo -e "Created RH-SSO user$i successfully...\n"
    else
      echo -e "Failure to create RH-SSO user$i with $RES\n"
    fi
  done

  echo -e "Retrieving RH-SSO user's ID list \n"
  USER_ID_LIST=$(curl -k -X GET https://$HOSTNAME_SECURE/auth/admin/realms/rhamt/users/ \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $RESULT_TOKEN")
  echo -e "USER_ID_LIST: $USER_ID_LIST \n"

    echo -e "Getting access token to reset passwords \n"
    export RESULT_TOKEN=$(curl -k -X POST https://$HOSTNAME_SECURE/auth/realms/master/protocol/openid-connect/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin" \
    -d 'password=password' \
    -d 'grant_type=password' \
    -d 'client_id=admin-cli' | jq -r '.access_token')
    echo -e "RESULT_TOKEN: $RESULT_TOKEN \n"

  echo -e "Reset passwords for each RH-SSO user \n"
  for i in $(jq '. | keys | .[]' <<< "$USER_ID_LIST"); do
    USER_ID=$(jq -r ".[$i].id" <<< "$USER_ID_LIST")
    USER_NAME=$(jq -r ".[$i].username" <<< "$USER_ID_LIST")
    if [ "$USER_NAME" != "rhamt" ] ; then
      RES=$(curl -s -w '%{http_code}' -o /dev/null -k -X PUT https://$HOSTNAME_SECURE/auth/admin/realms/rhamt/users/$USER_ID/reset-password \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $RESULT_TOKEN" \
        -d '{ "type": "password", "value": "'"$GOGS_PWD"'", "temporary": true}')
      if [ "$RES" = 204 ] ; then
        echo -e "user$i password is reset successfully...\n"
      else
        echo -e "Failure to reset user$i password with $RES\n"
      fi
    fi
  done
