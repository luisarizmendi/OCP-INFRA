#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Usage example: $0 node0.baremetalocp.ocp.lablocal node1.baremetalocp.ocp.lablocal node3.baremetalocp.ocp.lablocal" >&2
  exit 1
fi

RESPONSE=$(oc auth can-i create role)

if [ "$RESPONSE" != "yes" ]; then
   echo "You need to be log in as cluster admin user"
   exit -1
fi

INFRA_NODES="$@"

echo "Infra Nodes: $INFRA_NODES"
echo ""
echo "Create a default node selector"
oc patch scheduler cluster --type='json' -p='[{"op": "add", "path": "/spec/defaultNodeSelector", "value":"node-role.kubernetes.io/worker="}]' 

echo ""
echo "Add infra label to the worker nodes"
for i in $INFRA_NODES
do
  oc label node $i node-role.kubernetes.io/infra=""
  oc label node $i node-role.kubernetes.io/worker-
done


echo ""
echo "Move router pods on the infra node(s)"
oc patch ingresscontroller/default --type=merge -n openshift-ingress-operator -p '{"spec": {"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra": ""}}}}}'

echo ""
echo "Move registry pods on the infra node(s)"
oc patch configs.imageregistry.operator.openshift.io/cluster -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra": ""}}}' --type=merge


echo ""
echo "Move monitoring pods on the infra node(s)"

cat <<EOF > monitoring-infra.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |+
    alertmanagerMain:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    prometheusK8s:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    prometheusOperator:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    grafana:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    k8sPrometheusAdapter:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    kubeStateMetrics:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    telemeterClient:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
EOF

oc create -f monitoring-infra.yaml

rm -rf monitoring-infra.yaml

echo ""
echo "DONE"