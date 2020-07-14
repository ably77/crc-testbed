#!/bin/bash

# Codeready Parameters
CODEREADY_DEVFILE_URL="https://raw.githubusercontent.com/ably77/openshift-testbed-apps/master/codeready-workspaces/dev-file/openshift-testbed-dev-file.yaml"

#### Create artemis CRDs
oc create -f extras/crds/

# run argocd install script
./argocd/runme.sh

### deploy shared components in argocd
echo deploying shared components
oc create -f https://raw.githubusercontent.com/ably77/crc-testbed/master/argocd/apps/meta/meta-shared.yaml
sleep 5

### deploy operators in argocd
echo deploying operators
oc create -f https://raw.githubusercontent.com/ably77/crc-testbed/master/argocd/apps/meta/meta-operators.yaml

### check kafka operator deployment status
echo waiting for kafka deployment to complete
./extras/waitfor-pod -t 10 strimzi-cluster-operator-v0.18.0

### check openshift pipelines operator deployment status
echo checking grafana deployment status before deploying applications
./extras/waitfor-pod -t 10 openshift-pipelines-operator

### deploy backend services in argocd
echo deploying backend app services
oc create -f https://raw.githubusercontent.com/ably77/crc-testbed/master/argocd/apps/meta/meta-backend-apps.yaml

### check kafka deployment status
echo waiting for kafka deployment to complete
./extras/waitfor-pod -t 20 my-cluster-kafka-0

### deploy frontend apps in argocd
echo deploying frontend apps
oc create -f https://raw.githubusercontent.com/ably77/crc-testbed/master/argocd/apps/meta/meta-frontend-apps.yaml

### Wait for IoT Demo
./extras/waitfor-pod -t 10 consumer-app

### open IoT demo app route
echo opening consumer-app route
iot_route=$(oc get routes --all-namespaces | grep consumer-app-iotdemo-app.apps | awk '{ print $3 }')
open http://${iot_route}

### open manuELA IoT dashboard route
#echo opening manuELA IoT dashboard route
#manuela_route=$(oc get routes --all-namespaces | grep line-dashboard-manuela- | awk '{ print $3 }')
#open http://${manuela_route}

### end
echo
echo installation complete
echo
echo
echo links to relevant demo routes:
echo
echo temperature sensors iot demo dashboard:
echo http://${iot_route}
echo
echo argocd console:
echo http://${argocd_route}
echo
echo manuELA IoT dashboard:
echo http://${manuela_route}
echo
