 #/bin/bash

echo "****************************"
echo "Configuring CNV"
echo "****************************"

oc process -f template.yaml --param-file=env | oc create -f -

RESOURCE="HyperConverged"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done

#oc process -f template2.yaml --param-file=env2 | oc create -f -
oc process -f template2.yaml | oc create -f -




### I don't have such subscription so I included the rpm file
################3
###sudo subscription-manager repos --enable rhel-7-server-cnv-2.1-rpms
###sudo yum install -y kubevirt-virtctl
############3
sudo yum install -y kubevirt-virtctl-0.20.8-5.el7.x86_64.rpm
###########
#
