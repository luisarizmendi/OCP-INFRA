#!/bin/bash

if [ $# -ne 4 ];
    then echo "Illegal number of parameters, usage:"
    echo ""
    echo "$0 --reponame <NAME> --repo <git repo>"
    echo ""
    echo ""
    exit -1
fi



while [[ $# -gt 0 ]] && [[ ."$1" = .--* ]] ;
do
    opt="$1";
    shift;              #expose next argument
    case "$opt" in
        "--" ) break 2;;
        "--reponame" )
           REPO_NAME=$1;shift;;
        "--repo" )
           CLONE_ADDR=$1;shift;;
        "*" )
           echo "Option $opt not recognized"; exit -1;;
   esac
done

USERCOUNT=25
GOGS_PWD=R3dhat01

#CLONE_ADDR=https://github.com/RedHat-Middleware-Workshops/cloud-native-workshop-v2m$MODULE_NO-labs.git
#REPO_NAME=cloud-native-workshop-v2m$MODULE_NO-labs


#oc get route gogs -o=go-template --template='{{ .spec.host }}' -n $NAMESPACE
HOSTNAME_GOGS=$( oc get route --all-namespaces | grep  gogs | awk '{print $3}' | head -n 1)
HOSTNAME_SUFFIX=$(echo $HOSTNAME_GOGS  | cut -f2- -d '.')

MASTER_URL=$(oc whoami --show-server)
CONSOLE_URL=$(oc whoami --show-console)


NAMESPACE="labs-infra"




echo "Creating repos in GOGS"

for i in $(eval echo "{0..$USERCOUNT}") ; do
  USER_ID=$(($i + 2))
  STAT=$(curl -s -w '%{http_code}' -o /dev/null -X POST http://$HOSTNAME_GOGS/api/v1/repos/migrate \
      -H "Content-Type: application/json" \
      -d '{"clone_addr": "'"$CLONE_ADDR"'", "uid": '"$USER_ID"', "repo_name": "'"$REPO_NAME"'" }' \
      -u "user${i}:${GOGS_PWD}")
  if [ "$STAT" = 201 ] ; then
    echo "user$i $MODULE repo is created successfully..."
  else
    echo "Failure to create user$i $MODULE repo with $STAT"
  fi
done
