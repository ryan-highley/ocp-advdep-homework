#!/bin/bash

export GUID=`hostname|awk -F. '{print $2}'`

capacity="5Gi"
reclaim="Recycle"
access="ReadWriteOnce"

for volume in pv{1..25} ; do
cat << EOF | oc create -f -
{
  "apiVersion": "v1",
  "kind": "PersistentVolume",
  "metadata": {
    "name": "${volume}"
  },
  "spec": {
    "capacity": {
        "storage": "${capacity}"
    },
    "accessModes": [ "${access}" ],
    "nfs": {
        "path": "/srv/nfs/user-vols/${volume}",
        "server": "support1.${GUID}.internal"
    },
    "persistentVolumeReclaimPolicy": "${reclaim}"
  }
}
EOF

done

capacity="10Gi"
reclaim="Retain"
access="ReadWriteMany"

for volume in pv{26..50} ; do
cat << EOF | oc create -f -
{
  "apiVersion": "v1",
  "kind": "PersistentVolume",
  "metadata": {
    "name": "${volume}"
  },
  "spec": {
    "capacity": {
        "storage": "${capacity}"
    },
    "accessModes": [ "${access}" ],
    "nfs": {
        "path": "/srv/nfs/user-vols/${volume}",
        "server": "support1.${GUID}.internal"
    },
    "persistentVolumeReclaimPolicy": "${reclaim}"
  }
}
EOF

done

