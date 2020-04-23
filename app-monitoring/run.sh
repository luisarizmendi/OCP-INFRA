 #/bin/bash

echo "*******************************"
echo "Configuring APP Cluster Logging"
echo "*******************************"

# Enable tech preview feature
oc create -f monitoring-config.yaml -n openshift-monitoring


# Create a role that allows a user to set up metrics collection for a service
oc apply -f role-appmon.yaml
oc adm policy add-role-to-group monitor-crd-edit developers


# Create example app
oc create -f example-app.yaml
