#!/bin/bash

# based on:
#     https://docs.openshift.com/container-platform/4.3/service_mesh/service_mesh_day_two/ossm-example-bookinfo.html
#     https://github.com/istio/istio/tree/master/samples/bookinfo
#

oc project lab-servicemesh

# If you want to use any other project, remember to include it into the istio memeberroll:
#  $ oc -n <control plane project> patch --type='json' smmr default -p '[{"op": "add", "path": "/spec/members", "value":["'"bookinfo"'"]}]'



oc apply -f httpbin.yaml

sleep 5

# We need to inject the sidecar if using default istio example,
oc patch deployment httpbin -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}'


# FORTIO client
oc apply -f sample-client/fortio-deploy.yaml

# How to log and run load:
# FORTIO_POD=$(oc get pod | grep fortio | awk '{ print $1 }')
# oc exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -curl  http://httpbin:8000/get
# With 2 concurrent connections:
# oc  exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get
