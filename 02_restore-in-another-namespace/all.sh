#!/bin/sh

# replace by your value
export ANOTHER_NAMESPACE="another-test"
export STORAGE_CLASS="csi-hostpath-sc"
export CSI_DRIVER="hostpath.csi.k8s.io"
export VOLUME_SNAPSHOT_CLASS="csi-hostpath-snapclass"
# get a snap handle 
# kubectl get volumesnapshotcontent -o jsonpath='{.items[0].status.snapshotHandle}'
export SNAP_HANDLE="3604f47c-a479-11ec-9340-86cc1c59742a"
client="kubectl" # if using openshift replace by oc 

$client create ns $ANOTHER_NAMESPACE

envsubst < 01_restored-snap.yaml | $client create -f -
envsubst < 02_restored-snapcontent.yaml | $client create -f -
envsubst < 03_pvc-clone-from-restored-snap.yaml | $client create -f -
envsubst < 04_pod-on-pvc-clone-from-restored-snap.yaml | $client create -f -