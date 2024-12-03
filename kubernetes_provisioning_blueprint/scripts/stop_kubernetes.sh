#!/bin/bash

set -e

# Stop Kubernetes services
kubeadm reset -f
systemctl stop kubelet
docker stop $(docker ps -q)

