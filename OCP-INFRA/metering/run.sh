 #/bin/bash

echo "****************************"
echo "Configuring Cluster Metering"
echo "****************************"

#CHANNEL_METERING=$(oc get packagemanifest metering-ocp -n openshift-marketplace -o jsonpath='{.status.channels[].name}')



oc process -f template.yaml --param-file=env | oc create -f -

RESOURCE="MeteringConfig"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done

RESOURCE="Report"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done


oc process -f template2.yaml --param-file=env2 | oc create -f -
