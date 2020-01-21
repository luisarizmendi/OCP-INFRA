#!/bin/bash



echo "Configure authentication"
cd authentication/  ; chmod +x run.sh ; ./run.sh ; cd ..




echo "Configure NFS autoprovisioner (not supported, only for PoC)"
cd nfs-autoprovisioner/  ; chmod +x run.sh ; ./run.sh ; cd ..



# echo "Configure certificates"
# cd certificates/  ; chmod +x run.sh ; ./run.sh ; cd ..
