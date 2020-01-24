#!/bin/bash
GOGS_PWD=redhat
USERCOUNT=25

#git clone https://github.com/OpenShiftDemos/gogs-openshift-docker
#oc process -f template.yaml --param-file=env --labels="demo=cicd" | oc create -f -



oc new-app -f template.yaml --param-file=env



HOSTNAME=$(grep HOSTNAME env | awk -F \" '{print $2}')

# oc set resources dc/gogs --limits=cpu=400m,memory=512Mi --requests=cpu=100m,memory=128Mi

# Wait for gogs postgresql to be running
echo -e "Waiting for gogs postgresql to be running... \n"
while [ 1 ]; do
  STAT=$(curl -s -w '%{http_code}' -o /dev/null http://$HOSTNAME)
  if [ "$STAT" = 200 ] ; then
    break
  fi
  echo -n .
  sleep 10
done

# Create gogs admin user
STAT=$(curl -s -w '%{http_code}' -o /dev/null -X POST http://$HOSTNAME/user/sign_up \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "user_name=adminuser&password=adminpwd&&retype=adminpwd&&email=adminuser@gogs.com")
if [ "$STAT" = 302 ] || [ "$STAT" = 200 ] ; then
  echo "adminuser is created successfully..."
else
  echo "Failure to create adminuser with $STAT"
fi

# Create gogs users
echo -e "Creating $USERCOUNT gogs users.... \n"
for i in $(eval echo "{0..$USERCOUNT}") ; do
  STAT=$(curl -s -w '%{http_code}' -o /dev/null -X POST http://$HOSTNAME/api/v1/admin/users \
        -H "Content-Type: application/json" \
        -d '{"login_name": "user'"$i"'", "username": "user'"$i"'", "email": "user'"$i"'@gogs.com", "password": "'"$GOGS_PWD"'"}' \
        -u adminuser:adminpwd)
  if [ "$STAT" = 200 ] || [ "$STAT" = 201 ] ; then
    echo "user$i is created successfully..."
  else
    echo "Failure to create user$i with $STAT"
  fi
done
