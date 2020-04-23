 #/bin/bash


oc process -f template.yaml --param-file=env | oc -n openshift-operators delete -f -
