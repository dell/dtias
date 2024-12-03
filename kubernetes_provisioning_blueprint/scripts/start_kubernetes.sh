#!/bin/bash

set -e

# Start Kubernetes services
systemctl start kubelet
kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubeconfig for root user
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Flannel as a network add-on
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Allow scheduling pods on the master node (optional)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
