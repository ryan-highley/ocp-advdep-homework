#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo 'usage: create_pvs.sh <server> <base_path> <count>:<capacity>:<reclaim>:<access> [...]'
  echo 'where:'
  echo '  server is the NFSv4 server OCP-internal name, e.g. support1.abcd.internal'
  echo '  base_path is the NFSv4 server path containing exported "pv#" directories'
  echo '  count is the number of PVs to create with the subsequent parameters'
  echo '  capacity is a standard OCP PV size designation, e.g. 5Gi'
  echo '  reclaim is a standard OCP PV reclaimation policy: Retain, Recycle, or Delete'
  echo '  access is a standard OCP PV access mode: ReadWriteOnce, ReadOnlyMany, or ReadWriteMany'
  echo 'Creates OCP PersistentVolume definitions. The currently logged in OCP user must'
  echo '  have "cluster-admin" privileges as this script uses "oc create" to operate.'
  echo 'Multiple <count>:<capacity>:<reclaim>:<access> parameters can be provided.'
  echo 'PV names start with "pv1" and count up for each PV configuration set specified.'
  echo 'NFS export directory paths must match the PV name, e.g. given "base_path" of'
  echo '  "/srv/nfs/user-vols", NFS exports must specify "/srv/nfs/user-vols/pv1",'
  echo '  "/srv/nfs/user-vols/pv2", etc.'
  echo 'example: ./create_pvs.sh support1.3aff.internal /src/nfs/user-vols 25:5Gi:Recycle:ReadWriteOnce 25:10Gi:Retain:ReadWriteMany'
  echo
  exit
fi

server=$1
base_path=$2
shift 2

pvnum=1

for pvspec ; do
  IFS=":" read count capacity reclaim access <<< "${pvspec}"
  if [[ -z "${count}" || -z "${capacity}" || -z "${reclaim}" || -z "${access}" ]]; then
    echo "Invalid PV spec found - skipping ${pvspec}"
    continue
  fi

  for (( i = 0 ; i < ${count} ; i += 1 )); do
    volume="pv${pvnum}"
    echo "Creating PV \"${volume}\": capacity-\"${capacity}\", reclaim policy-\"${reclaim}\", access mode-\"${access}\""

#    cat << EOF | oc create -f -
    cat << EOF
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
        "path": "${base_path}/${volume}",
        "server": "${server}"
    },
    "persistentVolumeReclaimPolicy": "${reclaim}"
  }
}
EOF

  pvnum=$((pvnum + 1))
  done
done
