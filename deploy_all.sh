#!/bin/bash



echo "Configure authentication"
cd authentication/  ; chmod +x run.sh ; ./run.sh ; cd ..




echo "Configure NFS autoprovisioner (not supported, only for PoC)"
cd nfs-autoprovisioner/  ; chmod +x run.sh ; ./run.sh ; cd ..



# echo "Configure certificates"
# cd certificates/  ; chmod +x run.sh ; ./run.sh ; cd ..




####################################################################
# OPTIONAL
####################################################################


echo "Configure Cluster logging"
cd cluster-logging   ; chmod +x run.sh ; ./run.sh ; cd ..



echo "Configure Metering"
cd metering   ; chmod +x run.sh ; ./run.sh ; cd ..




echo "Configure CNV"
cd cnv   ; chmod +x run.sh ; ./run.sh ; cd ..




echo "Configure Tekton Pipelines"
cd tekton   ; chmod +x run.sh ; ./run.sh ; cd ..



echo "Configure Service Mesh"
cd service-mesh   ; chmod +x run.sh ; ./run.sh ; cd ..



echo "Configure Knative"
cd knative   ; chmod +x run.sh ; ./run.sh ; cd ..


echo "Configure Code Ready Workspaces"
cd workspaces   ; chmod +x run.sh ; ./run.sh ; cd ..
