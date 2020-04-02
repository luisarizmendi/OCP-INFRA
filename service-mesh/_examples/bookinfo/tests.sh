#!/bin/bash

echo "*********************************************************************************"
echo "                                   Only v1"
echo "*********************************************************************************"
echo ""
echo "100% of requests go to v1 (no stars)"
echo ""
read -p "                       PRESS ENTER TO CONFIGURE IT"
echo ""
oc apply -f networking/virtual-service-all-v1.yaml


echo "*********************************************************************************"
echo "                                   Route 80/20"
echo "*********************************************************************************"
echo ""
echo "80% of requests go to v1 (no stars) and 20% to v2 (black stars) "
echo ""
read -p "                       PRESS ENTER TO CONFIGURE IT"
echo ""

oc apply -f networking/virtual-service-reviews-80-20.yaml

echo ""
read -p "Done!, Press enter to continue with the next test"
echo ""

echo "*********************************************************************************"
echo "                          Route based on user identity"
echo "*********************************************************************************"
echo ""
echo "User jason will get stars in the ratings (v2). All other user don't see them (v1)"
echo ""
read -p "                       PRESS ENTER TO CONFIGURE IT"
echo ""

oc apply -f networking/virtual-service-reviews-test-v2.yaml

echo ""
read -p "Done!, Press enter to continue with the next test"
echo ""


echo "*********************************************************************************"
echo "                          Injecting an HTTP delay fault"
echo "*********************************************************************************"
echo ""
echo "A 7s delay between the reviews:v2 and ratings microservices for user jason. This"
echo "test will uncover a bug that was intentionally introduced into the Bookinfo app."
echo ""
echo "the 7s delay you introduced doesn’t affect the reviews service because the timeout"
echo "between the reviews and ratings service is hard-coded at 10s. However, there is also"
echo "a hard-coded timeout between the productpage and the reviews service, coded as 3s + 1"
echo "retry for 6s total."
echo ""
read -p "                       PRESS ENTER TO CONFIGURE IT"
echo ""

oc apply -f networking/virtual-service-ratings-test-delay.yaml

echo ""
read -p "Done!, Press enter to continue with the next test"
echo ""



echo "*********************************************************************************"
echo "                          Injecting an HTTP abort fault"
echo "*********************************************************************************"
echo ""
echo "Introduce an HTTP abort to the ratings microservices for the test user jason."
echo ""
read -p "                       PRESS ENTER TO CONFIGURE IT"
echo ""

oc apply -f networking/virtual-service-ratings-test-abort.yaml

echo ""
read -p "Done!, Press enter to continue with the next test"
echo ""





echo "*********************************************************************************"
echo "                               Request timeouts"
echo "*********************************************************************************"
echo ""
echo "override the reviews service timeout to 1 second. To see its effect, however, you"
echo "also introduce an artificial 2 second delay in calls to the ratings service."
echo ""
read -p "                       PRESS ENTER TO CONFIGURE IT"
echo ""

oc apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
EOF

oc apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 100
        fixedDelay: 2s
    route:
    - destination:
        host: ratings
        subset: v1
EOF

echo ""
echo "Now you have a Route requests to v2 of the reviews service and a 2 second delay"
echo "to calls to the ratings service. Bookinfo application working normally."
echo ""
echo ""
read -p "Press Enter to override the timeout"
echo ""
oc apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
    timeout: 0.5s
EOF

echo ""
read -p "Done!, Press enter to continue with the next test"
echo ""












echo ""
read -p "Done!, Press enter to finish"
echo ""
