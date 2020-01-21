#!/bin/bash



######################################################
echo "Red Hat Bugzilla – Bug 1712525"
exit 0
######################################################


cd  cert_generate
chmod +x cert_generate.sh


rm -rf OUTPUT/*
./cert_generate.sh 1.250.20.2 api.ocp4.example.com
mkdir -p ../CERTS/API/
mv OUTPUT/* ../CERTS/API/


rm -rf OUTPUT/*
./cert_generate.sh 1.250.20.2 *.apps.ocp4.example.com
mkdir -p ../CERTS/APPS/
mv OUTPUT/* ../CERTS/APPS/

cd ..


# APPS


oc create secret tls appscert \
     --cert=CERTS/APPS/server.crt.pem \
     --key=CERTS/APPS/server.key.pem \
     -n openshift-ingress


oc patch ingresscontroller.operator default \
     --type=merge -p \
     '{"spec":{"defaultCertificate": {"name": "appscert"}}}' \
     -n openshift-ingress-operator



sleep 5

# API

oc create secret tls apicert \
     --cert=CERTS/API/server.crt.pem \
     --key=CERTS/API/server.key.pem \
     -n openshift-config


oc patch apiserver cluster \
     --type=merge -p \
     '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.ocp4.example.com"],"servingCertificate": {"name": "apicert"}}]}}}'



# Trust CA cert in this node

cp cert_generate/conf-input/cacert.pem /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

#oc adm config set  clusters.ocp4.certificate-authority-data $(cat cert_generate/conf-input/cacert.pem  | base64 -w 0)
#sleep 60
