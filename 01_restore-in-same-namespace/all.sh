#!/bin/sh

# replace by your value
export NAMESPACE="test"
export STORAGE_CLASS="csi-hostpath-sc"
export VOLUME_SNAPSHOT_CLASS="csi-hostpath-snapclass"
client="kubectl" # if using openshift replace by oc 

$client create ns $NAMESPACE

envsubst < 01_original-pvc.yaml | $client create -f -
envsubst < 02_pod-on-original-pvc.yaml | $client create -f -
$client -n $NAMESPACE wait --for=condition=Ready pod/pod-on-original-pvc
envsubst < 03_snap-original-pvc.yaml | $client create -f -
envsubst < 04_pvc-clone-from-snap-original-pvc.yaml | $client create -f -
envsubst < 05_pod-on-pvc-clone-from-snap-original-pvc.yaml | $client create -f -
$client -n $NAMESPACE wait --for=condition=Ready pod/pod-on-pvc-clone-from-snap-original-pvc
$client -n $NAMESPACE exec -it pod-on-pvc-clone-from-snap-original-pvc -- cat /data/test-file

