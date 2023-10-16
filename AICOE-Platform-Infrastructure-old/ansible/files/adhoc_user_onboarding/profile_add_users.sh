#!/bin/bash
namespace=$1
users=$2

# apply role binding and auth policy for all users
echo "Adding users to the namespace"
for i in $users
do
    cat authpol.yaml | sed  -e "s/NAMESPACE/$namespace/g" | sed  -e "s/USERNAME/$i/g" | kubectl apply -f -
    cat rolebind.yaml | sed  -e "s/NAMESPACE/$namespace/g" | sed  -e "s/USERNAME/$i/g" | kubectl apply -f -
done