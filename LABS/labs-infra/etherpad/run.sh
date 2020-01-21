#!/bin/bash

oc new-app -f template.yaml --param-file=env
echo ""
echo -e "Waiting for database to be running... \n"

sleep 15

POD_NAME=$(oc get pod | grep mysql | grep -v deploy | awk '{print $1}')
POD_STATUS=$(oc get pod $POD_NAME -o wide | grep $POD_NAME | awk '{print $2}')


while [ $POD_STATUS != "1/1" ]; do
  POD_STATUS=$(oc get pod $POD_NAME -o wide | grep $POD_NAME | awk '{print $2}')
  echo -n .
  sleep 10
done


oc new-app -f template2.yaml --param-file=env2
