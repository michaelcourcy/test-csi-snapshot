# Test your csi snapshot capacity 

## Goal 

This serie of test aims to check out of the Kasten workflow that you can run basic CSI operation: 

- Create a pvc 
- Attach an application on the pvc 
- Snaphot the pvc 
- Restore a new PVC from the snapshot 
- Reattach an app to the restored PVC 

Those operations are tested in both the same namespace and in another namespace. 

If those operations failed Kasten won't be able to follow up the snapshot workflow.

## First test restoration of a stateful workload in the same namespace

```
cd 01_restore-in-same-namespace
vi all.sh
#change the exported variable accordingly to your env
sh all.sh 
```

If everything went fine you should have this output
```
namespace/test created
persistentvolumeclaim/original-pvc created
pod/pod-on-original-pvc created
pod/pod-on-original-pvc condition met
volumesnapshot.snapshot.storage.k8s.io/snap-original-pvc created
persistentvolumeclaim/pvc-clone-from-snap-original-pvc created
pod/pod-on-pvc-clone-from-snap-original-pvc created
pod/pod-on-pvc-clone-from-snap-original-pvc condition met
test data
```

## Second test restoration in another namespace

```
cd ../02_restore-in-another-namespace/
# get the snapshothandle of the previous snapshotcontent 
kubectl get volumesnapshotcontent -o jsonpath='{.items[0].status.snapshotHandle}'
vi all.sh 
#change the exported variable accordingly to your env and to the volume handle 
sh all.sh
```

If everything went fine you should have this output
```
namespace/another-test created
volumesnapshot.snapshot.storage.k8s.io/restored-snap created
volumesnapshotcontent.snapshot.storage.k8s.io/restored-snapcontent created
persistentvolumeclaim/pvc-clone-from-restored-snap created
pod/pod-on-pvc-clone-from-restored-snap created
```

Then control the new volumesnapshotcontent and volumesnapshot 
```
kubectl get volumesnapshotcontent 
NAME                                               READYTOUSE   RESTORESIZE   DELETIONPOLICY   DRIVER                VOLUMESNAPSHOTCLASS      VOLUMESNAPSHOT      VOLUMESNAPSHOTNAMESPACE   AGE
restored-snapcontent                               true         3221225472    Delete           hostpath.csi.k8s.io   csi-hostpath-snapclass   restored-snap       another-test              14s
snapcontent-bc8dba61-767d-48ea-8fea-3db732008315   true         3221225472    Delete           hostpath.csi.k8s.io   csi-hostpath-snapclass   snap-original-pvc   test                      2m11s

kubectl get volumesnapshot -A
NAMESPACE      NAME                READYTOUSE   SOURCEPVC      SOURCESNAPSHOTCONTENT   RESTORESIZE   SNAPSHOTCLASS            SNAPSHOTCONTENT                                    CREATIONTIME   AGE
another-test   restored-snap       true                        restored-snapcontent    3Gi           csi-hostpath-snapclass   restored-snapcontent                               2m18s          21s
test           snap-original-pvc   true         original-pvc                           3Gi           csi-hostpath-snapclass   snapcontent-bc8dba61-767d-48ea-8fea-3db732008315   2m18s          2m18s
```

All should be ready to use 

The pod should be running as well
```
kubectl get po -n another-test
NAME                                  READY   STATUS    RESTARTS   AGE
pod-on-pvc-clone-from-restored-snap   1/1     Running   0          47s
```