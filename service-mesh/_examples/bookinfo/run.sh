#!/bin/bash
#DOMAIN="apps$(oc whoami --show-console | awk -F "apps" '{print $2}')"
#SUBDOMAIN="$(oc project | awk -F \" '{print $2}').${DOMAIN}"


# based on:
#     https://docs.openshift.com/container-platform/4.3/service_mesh/service_mesh_day_two/ossm-example-bookinfo.html
#     https://github.com/istio/istio/tree/master/samples/bookinfo
#

#oc project lab-servicemesh

# If you want to use any other project, remember to include it into the istio memeberroll:
#  $ oc -n <control plane project> patch --type='json' smmr default -p '[{"op": "add", "path": "/spec/members", "value":["'"bookinfo"'"]}]'

# We need to inject the sidecar if using default istio example,
#for i in $(oc get deployments -o jsonpath='{range.items[*]}{.metadata.name}{"\n"}{end}'); do echo $i; oc patch deployment $i -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}'; done




### DEPLOY ########################

#cat bookinfo-deploy.yaml | APP_SUBDOMAIN=productpage-$(echo $SUBDOMAIN) envsubst | oc apply -f -

my_project=$(oc project | awk -F \" '{print $2}')

my_appsdomain="apps.$(oc project | awk -F "https://api." '{print $2}' | awk -F : '{print $1}')"


oc apply -f bookinfo-deploy.yaml


#cat bookinfo-gateway.yaml | APP_SUBDOMAIN=productpage-$(echo $SUBDOMAIN) envsubst | oc apply -f -
#oc apply -f bookinfo-gateway.yaml

oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "bookinfo.${my_appsdomain}"
EOF



sleep 5


oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo-vs
spec:
  hosts:
  - "bookinfo.${my_appsdomain}"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
EOF



export GATEWAY_URL="bookinfo.${my_appsdomain}"


oc apply -f destination-rule-all.yaml

sleep 15

#############################################
# WAITING POD TO BE UP
#############################################
DEPLOYMENTS=$(oc get deployment -n  lab-servicemesh  -o name)
echo ""
echo "Waiting the PODs to be ready"
for DEPLOYMENT_NAME in $DEPLOYMENTS; do
    DEPLOYMENT_STATUS=$(oc get $DEPLOYMENT_NAME | grep $(echo $DEPLOYMENT_NAME | awk -F \/ '{print $2}')  | awk '{print $2}')
    DEPLOYMENT_STATUS_1=$(echo $DEPLOYMENT_STATUS | awk -F \/ '{print $1}')
    DEPLOYMENT_STATUS_2=$(echo $DEPLOYMENT_STATUS | awk -F \/ '{print $2}')
    while [ $DEPLOYMENT_STATUS_1 != $DEPLOYMENT_STATUS_2 ]; do
      POD_STATUS=$(oc get $DEPLOYMENT_NAME | grep $(echo $DEPLOYMENT_NAME | awk -F \/ '{print $2}') | awk '{print $2}')
      DEPLOYMENT_STATUS_1=$(echo $DEPLOYMENT_STATUS | awk -F \/ '{print $1}')
      DEPLOYMENT_STATUS_2=$(echo $DEPLOYMENT_STATUS | awk -F \/ '{print $2}')
      echo -n .
      sleep 10
    done
done
#############################################

echo "Try to connect to http://$GATEWAY_URL/productpage"
## IN ORDER TO GET ONLY THE HTTP CODE:   curl -o /dev/null -s -w "%{http_code}\n" http://$GATEWAY_URL/productpage
