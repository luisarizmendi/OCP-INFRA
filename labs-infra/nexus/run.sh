 #/bin/bash


oc process -f template.yaml --param-file=env | oc create -f -

RESOURCE="nexus"
while [[ $(oc api-resources | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done


oc process -f template2.yaml --param-file=env2 | oc create -f -


STATUS=""
echo "Waiting until pod is ready..."
while [ "$STATUS" != "1/1" ]
do
    sleep 5
    STATUS=$(oc get pod | grep nexus | grep -v operator | awk '{print $2}')
done

sleep 5

export NEXUS_PASSWORD=$(oc rsh $(oc get pod -o name | grep nexus | grep -v operator) cat /nexus-data/admin.password)
echo "Default Nexus password: $NEXUS_PASSWORD"
chmod +x nexus-config.sh
./nexus-config.sh admin $NEXUS_PASSWORD http://$(oc get route nexus3 --template='{{ .spec.host }}')


oc expose deploy nexus3 --port=5000 --name=nexus-registry
oc create route edge nexus-registry --service=nexus-registry --port=5000
