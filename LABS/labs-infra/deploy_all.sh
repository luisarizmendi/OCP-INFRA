#!/bin/bash


oc new-project labs-infra

echo "Installing GOGS..."
cd GOGS
chmod +x run.sh
./run.sh
cd ..



echo "Installing Jenkins..."
cd jenkins
chmod +x run.sh
./run.sh
cd ..



echo "Installing Nexus..."
cd nexus
chmod +x run.sh
./run.sh
cd ..




echo "Installing Sonarqube..."
cd sonarqube
chmod +x run.sh
./run.sh
cd ..



echo "Installing Etherpad..."
cd etherpad
chmod +x run.sh
./run.sh
cd ..



echo "Installing Red Hat Application Migration Tool..."
cd RHAMT
chmod +x run.sh
./run.sh
cd ..
