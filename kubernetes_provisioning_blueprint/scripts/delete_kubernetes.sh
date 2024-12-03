#!/bin/bash

set -e

# Delete Kubernetes components and clean up
kubeadm reset -f
rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet
systemctl stop kubelet
docker system prune -a -f

