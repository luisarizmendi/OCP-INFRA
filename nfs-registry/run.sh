 #/bin/bash

echo "****************************"
echo "Configuring NFS for Registry"
echo "****************************"



oc process -f template.yaml --param-file=env | oc create -f -


RESOURCE="cluster"
while [[ $(oc get configs.imageregistry.operator.openshift.io cluster | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done


#oc patch configs.imageregistry.operator.openshift.io cluster --type='json' -p='[{"op": "remove", "path": "/spec/storage" },{"op": "add", "path": "/spec/storage", "value": {"pvc":{"claim": ""}}}]'
oc patch configs.imageregistry.operator.openshift.io cluster --type='json' -p='[{"op": "replace", "path": "/spec/managementState", "value": "Managed" },{"op": "remove", "path": "/spec/storage" },{"op": "add", "path": "/spec/storage", "value": {"pvc":{"claim": ""}}}]'
