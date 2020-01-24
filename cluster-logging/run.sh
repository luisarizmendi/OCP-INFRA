 #/bin/bash

echo "****************************"
echo "Configuring Cluster Logging"
echo "****************************"

oc process -f template.yaml --param-file=env | oc create -f -

RESOURCE="ClusterLogging"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done

oc process -f template2.yaml --param-file=env2 | oc create -f -